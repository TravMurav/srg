#!/bin/sh
# SPDX-License-Identifier: MIT

set -e

if ! [ -f "$SCRIPT_DIR/.target_arch" ]
then
	echo "Target arch is not set, use \"spb -a\""
	exit 1
fi

BUILD_ARCH="$(cat "$SCRIPT_DIR/.target_arch")"
echo "Target arch: $BUILD_ARCH"

BUILDDIR="./build-$BUILD_ARCH"

./util/strip_rootfs.sh $BUILDDIR

./util/mkinitfs.sh \
	$BUILDDIR/rootfs/ \
	$BUILDDIR/tmp/initramfs

cat $BUILDDIR/rootfs/boot/vmlinuz-* $BUILDDIR/rootfs/boot/board.dtb > $BUILDDIR/tmp/vmlinuz-dtb

../util/mkbootimg \
	--kernel $BUILDDIR/tmp/vmlinuz-dtb \
	--ramdisk $BUILDDIR/tmp/initramfs \
	--cmdline "$(cat $BUILDDIR/rootfs/boot/cmdline.txt)" \
	-o $BUILDDIR/tmp/boot.img

du -sh $BUILDDIR/tmp/boot.img


