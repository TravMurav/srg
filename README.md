srg - Stupid Rootfs Generator
=============================

srg is a small and simple rootfs generator that aims to provide a
package-manager-ish workflow for creating an rootfs from scratch.

All packages are built from the source and the cross-compilation is
used. The built packages are cached so they don't need to be rebuilt
for a different OS configuration

The "base os" is just busybox and musl as the libc.

Dependencies
------------

srg will build the cross-compilation toolchain using
[musl-cross-make](https://github.com/richfelker/musl-cross-make) so you
should just need the basic compilation toolchain to build that.

In addition, due to the simplicity of the build system, you may need the build
dependencies for the packages you're giong to build.

Extra dependencies include:
`qemu-user-static` - to run various postinstall scripts in the chroot.

Usage
-----

Invoking `./spb.sh [list of packages]` should be sufficient. The script will
check the cache and build the toolchain and missing packages if needed.

You should get your rootfs in `build-ARCH/rootfs`

### Example booting in qemu

```
./spb.sh linux-virt busybox srg-baselayout
mkdir build-aarch64/tmp/
./util/mkinitfs.sh ./build-aarch64/rootfs/ ./build-aarch64/tmp/initramfs
qemu-system-aarch64 \
	-nographic \
	-machine virt,gic-version=3 \
	-cpu max \
	-m 512M \
	-smp 4 \
	-kernel build-aarch64/rootfs/boot/vmlinuz-5.19.0 \
	-append "earlycon console=ttyAMA0 rdinit=/linuxrc" \
	-initrd build-aarch64/tmp/initramfs
```

You should land into the root shell

License
-------

The scritps are licensed under the MIT (Expat) license.
