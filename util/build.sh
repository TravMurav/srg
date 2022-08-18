#!/bin/sh
# SPDX-License-Identifier: MIT

# Will just delete and recreate the package builddirs
clean_builddir() {
	rm -rf "$pkgdir" "$srcdir"
	mkdir -p "$pkgdir" "$srcdir"
	if [ -f "$BUILD_LOGFILE" ]
	then
		mv "$BUILD_LOGFILE" "$BUILD_LOGFILE.old"
	fi
}

# Will convert sual arch to chost.
get_toolchain_chost() {
	local tc="$1"
	case "$tc" in
		aarch64)	tc="aarch64-linux-musl" ;;
		arm*)		tc="arm-linux-musleabi" ;;
		*)		assert "Unknown arch" ;;
	esac
	echo "$tc"
}

# Will compile the toolchain if absent
prepare_toolchain() {
	if [ ! -e "$TOOLCHAIN_DIR/bin/$CHOST-gcc" ]
	then
		echo "Toolchain for $CHOST must be built."
		printf "Proceed? [Y] "; read

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
}

# Will cleanup after the previous package
clear_srgbuild_vars() {
	pkgname="xxx"
	pkgver=""
	pkgrel=""
	pkgdesc=""
	url=""
	depends=""
	source=""
	builddir=""
	build_oln="0"
	package_oln="0"
}

# Will compile the single package
# this depends on the recepie being sourced and
# some other vars set
build_package() {
	if [ ! -f "$PKGCACHE_DIR/$pkg_file" ]
	then
		printf "Need to build package %s\n" "$pretty_pkg_name"
		clean_builddir
		cd $srcdir
		for src in $source ; do
			cached_wget $pkgname $src
			fname=$(basename $src)
			cp $DLCACHE_DIR/$pkgname/$fname $srcdir

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
}

