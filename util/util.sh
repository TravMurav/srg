#!/bin/sh
# SPDX-License-Identifier: MIT

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

