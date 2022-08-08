pkgname=freetype
pkgver=2.12.1
pkgrel=0
pkgdesc="TrueType font rendering library"
url="https://www.freetype.org/"

depends=""

source="
	https://download.savannah.gnu.org/releases/freetype/freetype-$pkgver.tar.xz
	https://download.savannah.gnu.org/releases/freetype/ft2demos-$pkgver.tar.xz
"

builddir="$srcdir/$pkgname-$pkgver"

build() {
	mv ../ft2demos-$pkgver ft2demos

	./configure \
		--build=$BUILD_ARCH \
		--host="x86_64" \
		--prefix=/usr \
		--sysconfdir=/etc \
		--mandir=/usr/share/man \
		--infodir=/usr/share/info \
		--enable-static \
		--enable-freetype-config

	make
	make -C ft2demos TOP_DIR=".."
}

package() {
	make DESTDIR="$pkgdir" install
	make -C ft2demos TOP_DIR=".." DESTDIR="$pkgdir" install
}



