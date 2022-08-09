pkgname=zlib
pkgver=1.2.12
pkgrel=0
pkgdesc="A compression/decompression Library"
url="https://zlib.net/"

depends="musl"

source="
	https://zlib.net/zlib-$pkgver.tar.gz
"

builddir="$srcdir/$pkgname-$pkgver"

build() {

	CHOST="$CHOST" ./configure \
		--prefix=/usr \
		--libdir=/usr/lib \
		--shared

	make
}

package() {
	make install \
		pkgconfigdir="/usr/lib/pkgconfig" \
		DESTDIR="$pkgdir"
}



