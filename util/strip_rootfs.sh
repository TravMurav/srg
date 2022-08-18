#!/bin/sh
# SPDX-License-Identifier: MIT

set -e

if [ $# -ne 1 ]
then
	echo "Usage: $0 rootfs"
	exit 1
fi

ROOTFS_DIR="$1"

du -sh $ROOTFS_DIR

# Drop common -dev bits like headers
rm -rf \
	$ROOTFS_DIR/usr/include \
	$ROOTFS_DIR/usr/lib/pkgconfig \
	$ROOTFS_DIR/usr/share/aclocal \
	$ROOTFS_DIR/usr/share/man

# Drop static library artifacts
find $ROOTFS_DIR -iwholename '*/lib/*.a' -delete

# Drop most terminfo entries
# all the usual ones seem to be in the /etc anyway, symlinks will be kept
find "$ROOTFS_DIR/usr/share/terminfo" -type f -delete

du -sh $ROOTFS_DIR

