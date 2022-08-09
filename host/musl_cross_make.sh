#!/bin/sh
# SPDX-License-Identifier: MIT

_name="musl-cross-make"
_ver="git_20220807"
_commit="fe915821b652a7fa37b34a596f47d8e20bc72338"
_uri="https://github.com/richfelker/musl-cross-make/archive/$_commit.tar.gz"
_filename="$_name-$_ver.tar.gz"

echo "== Preparing the cross-compile toolchain =="
cached_wget $_uri $_filename
cp $DLCACHE_DIR/$_filename .

_builddir="$srcdir/$_name-$_commit"

tar -xf "$_filename"
cd $_builddir

echo "Building the toolchain..."
make \
	TARGET="$BUILD_ARCH-linux-musl"

echo "Installing the toolchain..."
make \
	TARGET="$BUILD_ARCH-linux-musl" \
	OUTPUT="$pkgdir" \
	install



