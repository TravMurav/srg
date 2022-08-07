pkgname=busybox
pkgver=1.35.0
pkgrel=0
pkgdesc="Size optimized toolbox of many common UNIX utilities"
url="https://busybox.net/"

depends="musl"

source="
	https://busybox.net/downloads/busybox-$pkgver.tar.bz2 
"

builddir="$srcdir/$pkgname-$pkgver"

build() {
	make defconfig
	make
}

package() {
	mkdir -p \
		"$pkgdir"/usr/sbin \
		"$pkgdir"/usr/bin \
		"$pkgdir"/tmp \
		"$pkgdir"/var/cache/misc \
		"$pkgdir"/bin \
		"$pkgdir"/sbin \
		"$pkgdir"/usr/share/man/man1
	
	chmod 1777 "$pkgdir"/tmp

	install -m755 busybox "$pkgdir"/bin/busybox

	ln -s /bin/busybox "$pkgdir"/bin/sh 
}
