#!/bin/sh
# SPDX-License-Identifier: MIT

_name="musl-cross-make"
_ver="git_20220807"
_commit="fe915821b652a7fa37b34a596f47d8e20bc72338"
_uri="https://github.com/richfelker/musl-cross-make/archive/$_commit.tar.gz"
_filename="$_name-$_ver.tar.gz"

_builddir="$srcdir/$_name-$_commit"

build_oln="24324"

cached_wget $_uri $_filename
cp $DLCACHE_DIR/$_filename .

tar -xf "$_filename"
cd $_builddir

build() {
	cat "$SCRIPT_DIR/host/_mcm_silent_tar.patch" | ./cowpatch.sh

	make \
		TARGET="$CHOST"

	make \
		TARGET="$CHOST" \
		OUTPUT="$pkgdir" \
		install
}

