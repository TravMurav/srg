pkgname=unudhcpd
pkgver=0.2.1
pkgrel=5
pkgdesc="extremely basic DHCP server that only issues 1 IP address to any client"
url="https://gitlab.com/postmarketOS/unudhcpd"

depends="musl srg-baselayout"

source="
	https://gitlab.com/postmarketOS/unudhcpd/-/archive/$pkgver/unudhcpd-$pkgver.tar.gz
"

builddir="$srcdir/$pkgname-$pkgver"

build() {
	abuild_meson output
	meson compile -C output
}

package() {
	DESTDIR="$pkgdir" meson install --no-rebuild -C output
	install -Dm755 "$srcdir/S70_unudhcpd.rc" "$pkgdir"/etc/rcS.d/S70_unudhcpd
}

build_oln="62"
package_oln="1"
