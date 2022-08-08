pkgname=unudhcpd
pkgver=0.2.1
pkgrel=0
pkgdesc="extremely basic DHCP server that only issues 1 IP address to any client"
url="https://gitlab.com/postmarketOS/unudhcpd"

depends="musl"

source="
	https://gitlab.com/postmarketOS/unudhcpd/-/archive/$pkgver/unudhcpd-$pkgver.tar.gz
"

builddir="$srcdir/$pkgname-$pkgver"

build() {
	meson _build \
		--prefix=/usr

	meson compile -C _build
}

package() {
	DESTDIR="$pkgdir" meson install --no-rebuild -C _build
}


