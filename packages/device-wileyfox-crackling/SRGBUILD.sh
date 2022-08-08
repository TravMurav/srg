pkgname=device-wileyfox-crackling
pkgver=1
pkgrel=0
pkgdesc="Device package for Wileyfox Swift"
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

	cat > "$pkgdir"/etc/modules-load.d/device-l8150.conf <<-EOF
		pm8916-lbc
		pm8916-bms-vm
		panel-longcheer-booyi-otm1287
		msm
		rmi-i2c

	EOF

	cat > "$pkgdir"/boot/cmdline.txt <<-EOF
		earlycon console=ttyMSM0,115200

	EOF
}
