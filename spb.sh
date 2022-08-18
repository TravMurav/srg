#!/bin/sh
# SPDX-License-Identifier: MIT

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")"; pwd)"

# Check the cli flags first so modules can access the
# settings applied here.

usage()
{
	echo "Usage:  $0 [option]... [package]..."
	echo "Compile and install packages into the rootfs"
	echo
	echo "Options:"
	echo "  -a arch   Set build arch (Will be saved)"
	echo "  -h        Display this message"
	echo
}

while getopts ":ha:" opt
do
	case $opt in
		a)
			echo "$OPTARG" > "$SCRIPT_DIR/.target_arch"
			;;
		h)
			usage
			exit 0 ;;
		*)
			usage
			echo "Unkown option: -$OPTARG"
			echo
			exit 1 ;;
	esac
done
shift $(($OPTIND-1))

# Find where we are and import other modules
. "$SCRIPT_DIR/util/util.sh"
. "$SCRIPT_DIR/util/color.sh"
. "$SCRIPT_DIR/util/build.sh"
. "$SCRIPT_DIR/util/progress.sh"
. "$SCRIPT_DIR/util/meson.sh"

if ! [ -f "$SCRIPT_DIR/.target_arch" ]
then
	echo "Target arch is not set, use -a"
	exit 1
fi

BUILD_ARCH="$(cat "$SCRIPT_DIR/.target_arch")"
echo "Target arch: $BUILD_ARCH"

export CHOST="$(get_toolchain_chost $BUILD_ARCH)"

RECEPIE_DIR="$SCRIPT_DIR/packages"

# Create the build dir structure
BASE_DIR="$SCRIPT_DIR/build-$BUILD_ARCH"
TOOLCHAIN_DIR="$BASE_DIR/toolchain"
DLCACHE_DIR="$BASE_DIR/cache"
PKGCACHE_DIR="$BASE_DIR/packages"
ROOTFS_DIR="$BASE_DIR/rootfs"
TMP_DIR="$BASE_DIR/tmp"
BUILD_LOGFILE="$BASE_DIR/build/build.log"

pkgdir="$BASE_DIR/build/pkgdir"
srcdir="$BASE_DIR/build/srcdir"

mkdir -p \
	$TMP_DIR \
	$TOOLCHAIN_DIR \
	$DLCACHE_DIR \
	$PKGCACHE_DIR \
	$ROOTFS_DIR

# Prepare the cross-compilation tools
export MAKEFLAGS="-j$(nproc)"
prepare_toolchain

# Prepare the environment
export PATH="$TOOLCHAIN_DIR/bin/:$PATH"
export CROSS_COMPILE="$TOOLCHAIN_DIR/bin/$CHOST-"
export CROSS_PREFIX="$CROSS_COMPILE"
export PKG_CONFIG_PATH="$ROOTFS_DIR/usr/lib/pkgconfig/"
export PKG_CONFIG_LIBDIR="$PKG_CONFIG_PATH"
export PKG_CONFIG_SYSROOT_DIR="$ROOTFS_DIR"

export CC="$CHOST-gcc"
export CFLAGS="-w -Os --sysroot=$ROOTFS_DIR"
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
BUILDPKGS="$(get_deps $INSTALLPKGS)"

echo "Will be installed:"
echo "$(mark_unbuilt $BUILDPKGS)" | fold -sw 60 | sed 's/^/\t/'

printf "Proceed? [Y] "; read

mkdir -p "$ROOTFS_DIR/var/srg/"

for PKG in $BUILDPKGS ; do
	recepie="$RECEPIE_DIR/$PKG/SRGBUILD.sh"

	clear_srgbuild_vars
	. $recepie

	pkg_file="$pkgname-$pkgver-r$pkgrel.tar.gz"
	pretty_pkg_name="$clr_bld$pkgname$clr_rst-$pkgver-r$pkgrel"

	printf "%-40s - %s\n" "$pretty_pkg_name" "$pkgdesc"

	build_package

	tar -xf "$PKGCACHE_DIR/$pkg_file" \
		-C "$ROOTFS_DIR"

	[ -z "${INSTALLPKGS##*$PKG*}" ] && echo "$PKG" >> "$ROOTFS_DIR/var/srg/world"
done

echo "Done! ($(du -sh "$ROOTFS_DIR" | awk '{print $1}'))"

