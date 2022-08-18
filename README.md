srg - Stupid Rootfs Generator
=============================

srg is a small and simple rootfs generator that aims to provide a
package-manager-ish workflow for creating a rootfs from scratch.

All packages are built from the source and the cross-compilation is
used. The built packages are cached so they don't need to be rebuilt
for a different OS configuration.

The "base os" is just busybox and musl as the libc.

This project is a small experiment "for fun" and is not really intended to
be production-ready for some real world tasks. There is no "high quality"
standarts for the code or the commit history. It's attempted to be at least
POSIX shell compatible.

Dependencies
------------

srg will build the cross-compilation toolchain using
[musl-cross-make](https://github.com/richfelker/musl-cross-make) so you
should just need the basic compilation toolchain to build that.

In addition, due to the simplicity of the build system, you will need the build
dependencies for the packages you're giong to build. This includes stuff like
`make`, `automake`, `meson` and so on... You will have to get this from your
distro's repos.

Usage
-----

Invoking `./spb.sh [list of packages]` should be sufficient. The script will
check the cache and build the toolchain and missing packages if needed.

First time launching `spb.sh` you must set the target arch with the `-a` flag.
On subsequent executions it will be saved.

You should get your rootfs in `build-ARCH/rootfs`

### Example booting in qemu

```
./spb.sh -a aarch64 linux-virt busybox srg-baselayout
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

You should land into the root shell.

Theory of operation
-------------------

The tool starts from building the cross-compilation toolchain.

Then it will build the install list by recursivey checking the recepies for
their dependencies. this means that the "repository index" is the packages/ dir
with the said build recepies. If the package was aleredy built, the .tar.gz is
unpacked from the cache, otherwise the package will be compiled. Build process
will use the same resulting rootfs that at that point should have all the
dependencies installed.

No file/package tracking is done, every time you request packages to be
installed, all packages will be re-repacked into the rootfs.

Adding packages
---------------

In general you should be able to mostly copy Alpine's APKBUILDs and simplify
them. In some cases you might get into the trouble in case the project build
system fails to recognize the cross-compiling toolchain.

The recepies are simple, i.e. subpackages are not supported.

License
-------

The scritps are licensed under the MIT (Expat) license unless otherwise stated.
