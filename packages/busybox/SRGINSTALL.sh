
# The symlinks must be installed
postinstall() {
	echo "Installing the busybox symlinks"
	cp "$(which qemu-$BUILD_ARCH-static)" "$ROOTFS_DIR/"

	sudo chroot "$ROOTFS_DIR/" "/qemu-$BUILD_ARCH-static" /bin/busybox --install -s

	rm "$ROOTFS_DIR/qemu-$BUILD_ARCH-static"
}

