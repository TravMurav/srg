#!/bin/sh

if [ $# -ne 2 ]
then
	echo "usage: $0 dir initramfs"
	exit 1
fi

(cd "$1"; find . | cpio -o -H newc -R root:root | zstd -19) > "$2"

