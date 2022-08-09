#!/bin/sh
# SPDX-License-Identifier: MIT

set -e

BUILD_ARCH="aarch64"

SCRIPT_DIR="$(cd "$(dirname "$1")"; pwd)"
. "$SCRIPT_DIR/util/util.sh"

BASE_DIR="$SCRIPT_DIR/build-$BUILD_ARCH"
RECEPIE_DIR="$SCRIPT_DIR/packages"
TOOLCHAIN_DIR="$BASE_DIR/toolchain"
DLCACHE_DIR="$BASE_DIR/cache/downloads"
PKGCACHE_DIR="$BASE_DIR/cache/packages"
ROOTFS_DIR="$BASE_DIR/rootfs"

# Create the build dir
mkdir -p $BASE_DIR/tmp $TOOLCHAIN_DIR $DLCACHE_DIR $PKGCACHE_DIR $ROOTFS_DIR

pkgdir="$BASE_DIR/build/pkgdir"
srcdir="$BASE_DIR/build/srcdir"
clean_builddir() {
	rm -rf "$pkgdir" "$srcdir"
	mkdir -p "$pkgdir" "$srcdir"
}

# Prepare the cross-compilation tools

export MAKEFLAGS="-j$(nproc)"

if [ ! -e "$TOOLCHAIN_DIR/bin/$BUILD_ARCH-linux-musl-gcc" ]
then
	clean_builddir
	cd "$srcdir"
	. "$SCRIPT_DIR/host/musl_cross_make.sh"
	tar \
		--sort=name \
		--mtime=0 \
		--owner=0 \
		--group=0 \
		--numeric-owner \
		-cf "$PKGCACHE_DIR/_host_musl_cross_make.tar.gz" \
		-C "$pkgdir" .
	cp -r "$pkgdir"/* $TOOLCHAIN_DIR

	echo "Toolchain was built"
fi

export PATH="$TOOLCHAIN_DIR/bin/:$PATH"
export CHOST="$BUILD_ARCH-linux-musl"
export CROSS_COMPILE="$TOOLCHAIN_DIR/bin/$CHOST-"
export CROSS_PREFIX="$CROSS_COMPILE"
export PKG_CONFIG_PATH="$ROOTFS_DIR/usr/lib/pkgconfig/"
export PKG_CONFIG_LIBDIR="$PKG_CONFIG_PATH"
export PKG_CONFIG_SYSROOT_DIR="$ROOTFS_DIR"

export CFLAGS="-Os --sysroot=$ROOTFS_DIR"
export LDFLAGS="--sysroot=$ROOTFS_DIR"

if [ $# -lt 1 ]
then
	echo "No package names supplied"
	exit 0
fi

INSTALLPKGS="$@"

echo "Requested packages: $INSTALLPKGS"

# recursively build the dependencies

getdep_rec() {
	PKG="$1"
	recepie="$RECEPIE_DIR/$PKG/SRGBUILD.sh"
	if [ ! -f "$recepie" ]
	then
		echo "ERROR: No recepie for $PKG" >&2
		exit 1
	fi

	depends=""
	. $recepie
	
	for dep in $depends ; do
		getdep_rec $dep
	done
	
	echo $1
}

get_deps() {
	PKGS="$@"

	{
		for dep in $PKGS ; do
			getdep_rec $dep
		done
	} | awk '!x[$0]++' | tr '\n' ' '
	# https://stackoverflow.com/a/11532197 
}

BUILDPKGS="$(get_deps $INSTALLPKGS)"

echo "Will be installed: $BUILDPKGS"

printf "Proceed? [Y] "
read

for PKG in $BUILDPKGS ; do
	recepie="$RECEPIE_DIR/$PKG/SRGBUILD.sh"

	pkgname=""
	pkgver=""
	pkgrel=""
	pkgdesc=""
	url=""
	depends=""
	source=""
	builddir=""

	. $recepie
	pkg_file="$pkgname-$pkgver-r$pkgrel.tar.gz"
	echo "$pkg_file - $pkgdesc"

	if [ ! -f "$PKGCACHE_DIR/$pkg_file" ]
	then
		echo "Need to build this package"
		clean_builddir
		cd $srcdir
		for src in $source ; do
			cached_wget $src
			fname=$(basename $src)
			cp $DLCACHE_DIR/$fname $srcdir

			case $fname in
				*.tar|*.tar.*)
					tar -xf $fname
			esac
		done

		cp "$RECEPIE_DIR/$PKG"/* "$srcdir"
		
		cd $builddir

		echo "Build stage:"
		build

		echo "Package stage:"
		package

		tar \
			--sort=name \
			--mtime=0 \
			--owner=0 \
			--group=0 \
			--numeric-owner \
			-cf "$PKGCACHE_DIR/$pkg_file" \
			-C "$pkgdir" .

		echo "Package $PKG was built."
	fi

	tar -xf "$PKGCACHE_DIR/$pkg_file" \
		-C "$ROOTFS_DIR"

	installscript="$RECEPIE_DIR/$PKG/SRGINSTALL.sh"

	if [ -f "$installscript" ]
	then
		. "$installscript"
		postinstall
	fi

done

mkdir -p "$ROOTFS_DIR/var/srg/"
for PKG in $INSTALLPKGS ; do
	echo "$PKG" > "$ROOTFS_DIR/var/srg/world"
done

