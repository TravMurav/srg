pkgname=linux-virt
pkgver=5.19
pkgrel=0
pkgdesc="Linux kernel (virt)"
url="https://kernel.org/"

_alpine_config_commit="c9dd40c101e97005ae02df44aee7f7125dcf131a"

source="
	https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-$pkgver.tar.xz
	https://gitlab.alpinelinux.org/alpine/aports/-/raw/$_alpine_config_commit/main/linux-lts/virt.aarch64.config
	https://gitlab.alpinelinux.org/alpine/aports/-/raw/$_alpine_config_commit/main/linux-lts/virt.x86_64.config
"

builddir="$srcdir/linux-$pkgver"

_kernelarch() {
	local arch="$1"
	case "$arch" in
		aarch64*)	arch="arm64" ;;
		arm*)		arch="arm" ;;
		mips*)		arch="mips" ;;
		ppc*)		arch="powerpc" ;;
		s390*)		arch="s390" ;;
	esac
	echo "$arch"
}

build() {
	mkdir "$builddir/out"
	cp "$srcdir/virt.$BUILD_ARCH.config" "$builddir/out/.config"
	make \
		O="$builddir/out" \
		ARCH="$(_kernelarch $BUILD_ARCH)" \
		olddefconfig

	make \
		O="$builddir/out" \
		ARCH="$(_kernelarch $BUILD_ARCH)" \
		KBUILD_BUILD_VERSION="$((pkgrel + 1 ))-srg"
}

package() {
	mkdir -p \
		"$pkgdir"/boot \
		"$pkgdir"/lib/modules

	local _install
	case "$BUILD_ARCH" in
		arm*|aarch64)	_install="zinstall dtbs_install";;
		*)		_install="install";;
	esac

	make -j1 \
		O="$builddir/out" \
		modules_install $_install \
		ARCH="$(_kernelarch $BUILD_ARCH)" \
		INSTALL_MOD_PATH="$pkgdir" \
		INSTALL_PATH="$pkgdir/boot" \
		INSTALL_DTBS_PATH="$pkgdir/boot/dtbs"

	ln -s /boot/vmlinuz-5.19.0 "$pkgdir"/boot/vmlinuz
}

