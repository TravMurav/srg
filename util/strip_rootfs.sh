#!/bin/sh
set -e

BASE_DIR="./build-aarch64"
ROOTFS_DIR="$BASE_DIR/rootfs"

du -sh $ROOTFS_DIR

#find $ROOTFS_DIR -iwholename '*/include/*.h' -delete

rm -rf \
	$ROOTFS_DIR/usr/include \
	$ROOTFS_DIR/usr/lib/pkgconfig \
	$ROOTFS_DIR/usr/share/aclocal \
	$ROOTFS_DIR/usr/share/man

find $ROOTFS_DIR -iwholename '*/lib/*.a' -delete

du -sh $ROOTFS_DIR

