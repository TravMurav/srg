
# The symlinks must be installed
postinstall() {
	echo "Installing the busybox symlinks"
	cp "$(which qemu-$ARCH-static)" "$ROOTFS_DIR/"

	sudo chroot "$ROOTFS_DIR/" "/qemu-$ARCH-static" /bin/busybox --install -s

	rm "$ROOTFS_DIR/qemu-$ARCH-static"
}

