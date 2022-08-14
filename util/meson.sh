#!/bin/sh -e

# https://gitlab.alpinelinux.org/alpine/aports/-/blob/8e75d7e0c984f9578b3458240c45415477c630ce/main/meson/abuild-meson
# Licensing unclear but package recepie specifies Apache-2.0

# Highly opinionated wrapper for Alpine Linux packaging

abuild_meson() {
	#. /usr/share/abuild/functions.sh

	# mostly taken from https://github.com/void-linux/void-packages/blob/22bf95cf356bf1a09212733d775d447d011f70b0/common/build-style/meson.sh
	if [ "$CHOST" != "$CBUILD" ]; then
		#_target_arch="$(hostspec_to_arch $CHOST)"
		_target_arch="$BUILD_ARCH"
		_meson_crossfile="abuild-meson.cross"
		_meson_target_endian=little
		# just the first part of the hostspec
		_meson_target_cpu=${CHOST%%-*}
		case "$_target_arch" in
		arm*)
			_meson_cpu_family=arm
			;;
		x86)
			_meson_cpu_family=x86
			;;
		ppc64le)
			_meson_cpu_family=ppc64
			;;
		s390x)
			_meson_cpu_family=s390x
			_meson_target_endian=big
			;;
		riscv64)
			_meson_cpu_family=riscv64
			;;
		x86_64)
			_meson_cpu_family=x86_64
			;;
		aarch64)
			_meson_cpu_family=aarch64
			;;
		esac
		cat > $_meson_crossfile <<-EOF
		[binaries]
		strip = '${CROSS_COMPILE}strip'
		readelf = '${CROSS_COMPILE}readelf'
		objcopy = '${CROSS_COMPILE}objcopy'
		[properties]
		needs_exe_wrapper = true
		[host_machine]
		system = 'linux'
		cpu_family = '$_meson_cpu_family'
		cpu = '$_meson_target_cpu'
		endian = '$_meson_target_endian'
		EOF
		unset _meson_target_cpu _meson_target_endian _meson_cpu_family _target_arch
	fi

	# TODO: enable LTO once our GCC works with LTO by default
	meson setup \
			--prefix=/usr \
			--libdir=/usr/lib \
			--libexecdir=/usr/libexec \
			--bindir=/usr/bin \
			--sbindir=/usr/sbin \
			--includedir=/usr/include \
			--datadir=/usr/share \
			--mandir=/usr/share/man \
			--infodir=/usr/share/info \
			--localedir=/usr/share/locale \
			--sysconfdir=/etc \
			--localstatedir=/var \
			--sharedstatedir=/var/lib \
			--buildtype=plain \
			--auto-features=auto \
			--wrap-mode=nodownload \
			-Db_lto=false \
			-Db_staticpic=true \
			-Db_pie=true \
			${_meson_crossfile:+--cross-file=$_meson_crossfile} \
			"$@"

}