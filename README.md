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

Extra dependencies include:
`qemu-user-static` - to run various postinstall scripts in the chroot.

Usage
-----

Invoking `./spb.sh [list of packages]` should be sufficient. The script will
check the cache and build the toolchain and missing packages if needed.

You should get your rootfs in `build-ARCH/rootfs`

License
-------

The scritps are licensed under the MIT (Expat) license.
