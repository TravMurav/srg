#!/bin/sh
# SPDX-License-Identifier: MIT

# Kill the app if something fails.
# For conditional can use
# [ false ] || assert "This is borked"
assert() {
	MSG="$1"
	echo "*** Assertion ***"
	echo "LINE=$LINENO"
	echo "$MSG"
	exit 1
}

# Will download file if not in cache yet.
cached_wget() {
	URI="$1"
	FILENAME="$2"
	if [ -z "$FILENAME" ]
	then
		FILENAME="$(basename $URI)"
	fi

	if [ ! -f "$DLCACHE_DIR/$FILENAME" ]
	then
		wget -q --show-progress "$URI" -O "$DLCACHE_DIR/$FILENAME"
	else
		echo "$FILENAME was already in the cache."
	fi
}

_getdep_rec() {
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
		_getdep_rec $dep
	done
	
	echo $1
}

# Will perform a tree traversal then deduplicate the output.
# This should result in a topologically sorted list of dependencies
# given a list of packages requested.
get_deps() {
	PKGS="$@"

	{
		for dep in $PKGS ; do
			_getdep_rec $dep
		done
	} | awk '!x[$0]++' | tr '\n' ' '
	# https://stackoverflow.com/a/11532197 
}

# Given a list of packages, will put a star before each
# that will have to be built.
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

