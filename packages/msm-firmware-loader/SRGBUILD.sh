pkgname=msm-firmware-loader
pkgver=1.0
pkgrel=0
pkgdesc="Automatically load the firmware for the device"
url="https://gitlab.com/postmarketOS/msm-firmware-loader"

source="
	https://gitlab.com/postmarketOS/msm-firmware-loader/-/archive/$pkgver/msm-firmware-loader-$pkgver.tar.bz2
"

builddir="$srcdir/$pkgname-$pkgver"

build() {
	true
}

package() {
	install -Dm755 "$srcdir/S50-msm-firmware-loader.initd" \
		"$pkgdir/etc/rcS.d/S50-msm-firmware-loader"
	install -Dm755 "$srcdir/S90-msm-firmware-loader-unpack.initd" \
		"$pkgdir/etc/rcS.d/S90-msm-firmware-loader-unpack"

	# Create mountpoint for the scripts
	mkdir -p "$pkgdir/lib/firmware/msm-firmware-loader"

	install -Dm755 msm-firmware-loader.sh \
		"$pkgdir/usr/sbin/msm-firmware-loader.sh"
	install -Dm755 msm-firmware-loader-unpack.sh \
		"$pkgdir/usr/sbin/msm-firmware-loader-unpack.sh"
}

