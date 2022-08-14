#!/bin/sh

set -e

BUILDDIR="./build-aarch64"

./util/strip_rootfs.sh

./util/mkinitfs.sh \
	$BUILDDIR/rootfs/ \
	$BUILDDIR/tmp/initramfs

cat $BUILDDIR/rootfs/boot/vmlinuz-* $BUILDDIR/rootfs/boot/board.dtb > $BUILDDIR/tmp/vmlinuz-dtb

../lk2nd/lk2nd/scripts/mkbootimg \
	--kernel $BUILDDIR/tmp/vmlinuz-dtb \
	--ramdisk $BUILDDIR/tmp/initramfs \
	--cmdline "$(cat $BUILDDIR/rootfs/boot/cmdline.txt)" \
	-o $BUILDDIR/tmp/boot.img

du -sh $BUILDDIR/tmp/boot.img


