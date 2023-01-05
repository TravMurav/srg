pkgname=linux-msm8916
pkgver=6.1
pkgrel=0
pkgdesc="Linux kernel (msm8916)"
url="https://github.com/msm8916-mainline/linux"

_tag=v${pkgver//_/-}-msm8916
_arch="arm64"

source="
	$url/archive/$_tag.tar.gz
	https://gitlab.com/postmarketOS/pmaports/-/raw/47e1660711bfb770ca1b6bb87603f5c4831803ef/device/community/linux-postmarketos-qcom-msm8916/config-postmarketos-qcom-msm8916.aarch64
"

builddir="$srcdir/linux-${_tag#v}"

build() {

	for p in "$srcdir"/*.patch
	do
		cat "$p" | patch -p1
	done

	mkdir "$builddir/out"
	cp "$srcdir/config-postmarketos-qcom-msm8916.aarch64" "$builddir/out/.config"
	make \
		O="$builddir/out" \
		ARCH="$_arch" \
		olddefconfig

	make \
		O="$builddir/out" \
		ARCH="$_arch" \
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
		ARCH="$_arch" \
		INSTALL_MOD_PATH="$pkgdir" \
		INSTALL_MOD_STRIP=1 \
		INSTALL_PATH="$pkgdir/boot" \
		INSTALL_DTBS_PATH="$pkgdir/boot/dtbs"
}


build_oln="4663"
package_oln="910"
