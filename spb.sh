#!/bin/sh
# SPDX-License-Identifier: MIT

set -e

BUILD_ARCH="aarch64"

SCRIPT_DIR="$(cd "$(dirname "$1")"; pwd)"
. "$SCRIPT_DIR/util/util.sh"
. "$SCRIPT_DIR/util/progress.sh"

BASE_DIR="$SCRIPT_DIR/build-$BUILD_ARCH"
RECEPIE_DIR="$SCRIPT_DIR/packages"
TOOLCHAIN_DIR="$BASE_DIR/toolchain"
DLCACHE_DIR="$BASE_DIR/cache"
PKGCACHE_DIR="$BASE_DIR/packages"
ROOTFS_DIR="$BASE_DIR/rootfs"

# Create the build dir
mkdir -p $BASE_DIR/tmp $TOOLCHAIN_DIR $DLCACHE_DIR $PKGCACHE_DIR $ROOTFS_DIR

pkgdir="$BASE_DIR/build/pkgdir"
srcdir="$BASE_DIR/build/srcdir"

BUILD_LOGFILE="$BASE_DIR/build/build.log"

clean_builddir() {
	rm -rf "$pkgdir" "$srcdir"
	mkdir -p "$pkgdir" "$srcdir"
	if [ -f "$BUILD_LOGFILE" ]; then mv "$BUILD_LOGFILE" "$BUILD_LOGFILE.old"; fi
}

# Prepare the cross-compilation tools

export MAKEFLAGS="-j$(nproc)"

if [ ! -e "$TOOLCHAIN_DIR/bin/$BUILD_ARCH-linux-musl-gcc" ]
then
	clean_builddir
	cd "$srcdir"
	. "$SCRIPT_DIR/host/musl_cross_make.sh"
	build 2>&1 | tee "$BUILD_LOGFILE" | progress_bar $build_oln "Toolchain"
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

echo "Requested packages:"
echo "$INSTALLPKGS" | fold -sw 60 | sed 's/^/\t/'

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

mark_unbuilt() {
	PKGS="$@"
	{
		for PKG in $PKGS ; do
			recepie="$RECEPIE_DIR/$PKG/SRGBUILD.sh"
			. $recepie
			pkg_file="$pkgname-$pkgver-r$pkgrel.tar.gz"
			if [ ! -f "$PKGCACHE_DIR/$pkg_file" ]
			then
				echo "*$PKG"
			else
				echo "$PKG"
			fi

		done
	} | tr '\n' ' '
}

echo "Will be installed:"
echo "$(mark_unbuilt $BUILDPKGS)" | fold -sw 60 | sed 's/^/\t/'

printf "Proceed? [Y] "
read

mkdir -p "$ROOTFS_DIR/var/srg/"

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
	build_oln="0"
	package_oln="0"

	. $recepie
	pkg_file="$pkgname-$pkgver-r$pkgrel.tar.gz"
	_bld=$(printf '\033[1m')
	_rst=$(printf '\033[0m')
	pretty_pkg_name="$_bld$pkgname$_rst-$pkgver-r$pkgrel"

	printf "%-40s - %s\n" "$pretty_pkg_name" "$pkgdesc"

	if [ ! -f "$PKGCACHE_DIR/$pkg_file" ]
	then
		printf "Need to build package %s\n" "$pretty_pkg_name"
		clean_builddir
		cd $srcdir
		for src in $source ; do
			cached_wget $src
			fname=$(basename $src)
			cp $DLCACHE_DIR/$fname $srcdir

			case $fname in
				*.tar|*.tar.*|*.tgz)
					tar -xf $fname
			esac
		done

		cp "$RECEPIE_DIR/$PKG"/* "$srcdir"

		cd $builddir

		build 2>&1 | tee "$BUILD_LOGFILE" | progress_bar $build_oln "Build"

		build_len=$(wc -l "$BUILD_LOGFILE" | awk '{ print $1; }' )

		package 2>&1 | tee -a "$BUILD_LOGFILE" | progress_bar $package_oln "Package"

		pkg_len=$(wc -l "$BUILD_LOGFILE" | awk '{ print $1; }' )

		if [ $build_oln -eq 0 ] && [ "$pkg_len" -ne 0 ]; then
			pkg_len=$(( ($pkg_len - $build_len) ))
			printf '\nbuild_oln="%d"\npackage_oln="%d"\n' $build_len $pkg_len >> "$recepie"
			echo "Build timings were added to the recepie for $PKG!"
		fi

		tar \
			--sort=name \
			--mtime=0 \
			--owner=0 \
			--group=0 \
			--numeric-owner \
			-cf "$PKGCACHE_DIR/$pkg_file" \
			-C "$pkgdir" .

		printf "Package %s was built.\n" "$pretty_pkg_name"
	fi

	tar -xf "$PKGCACHE_DIR/$pkg_file" \
		-C "$ROOTFS_DIR"

	installscript="$RECEPIE_DIR/$PKG/SRGINSTALL.sh"

	if [ -f "$installscript" ]
	then
		. "$installscript"
		postinstall
	fi

	[ -z "${INSTALLPKGS##*$PKG*}" ] && echo "$PKG" > "$ROOTFS_DIR/var/srg/world"
done

echo "Done! ($(du -sh "$ROOTFS_DIR" | awk '{print $1}'))"

