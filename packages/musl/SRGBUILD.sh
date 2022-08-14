pkgname=musl
pkgver=1.2.3
pkgrel=0
pkgdesc="the musl c library (libc) implementation"
url="https://musl.libc.org/"

source="
	https://musl.libc.org/releases/musl-$pkgver.tar.gz
"

builddir="$srcdir/$pkgname-$pkgver"

build() {

	./configure \
		--prefix=/usr \
		--sysconfdir=/etc \
		--mandir=/usr/share/man \
		--infodir=/usr/share/info

	make
}

package() {
	make DESTDIR="$pkgdir" install
}

build_oln="2836"
package_oln="234"
