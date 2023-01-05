pkgname=device-zhihe-uf896
pkgver=1
pkgrel=2
pkgdesc="Device package for uf896 4g usb stick"
url=""

source=""

builddir="$srcdir/"

build() {
	# Nothing to do
	true
}

package() {
	cd "$pkgdir"
	install -m 0755 -d \
		etc/modules-load.d \
		boot

	cat > "$pkgdir"/boot/cmdline.txt <<-EOF
		earlycon console=ttyMSM0,115200 rdinit=/linuxrc

	EOF

	ln -s dtbs/qcom/msm8916-zhihe-uf896.dtb "$pkgdir"/boot/board.dtb
}
