pkgname=ttf-dejavu
pkgver=2.37
pkgrel=0
pkgdesc="Font family based on the Bitstream Vera Fonts with a wider range of characters"
url="https://dejavu-fonts.github.io/"

depends=""

source="
	https://downloads.sourceforge.net/project/dejavu/dejavu/$pkgver/dejavu-fonts-ttf-$pkgver.tar.bz2
	https://downloads.sourceforge.net/project/dejavu/dejavu/$pkgver/dejavu-lgc-fonts-ttf-$pkgver.tar.bz2
"

builddir="$srcdir"

build() {
	true
}

package() {
	mkdir -p \
		"$pkgdir"/usr/share/fonts/$pkgname \
		"$pkgdir"/etc/fonts/conf.avail \
		"$pkgdir"/etc/fonts/conf.d

	install -m644 "$srcdir"/dejavu-fonts-ttf-$pkgver/ttf/*.ttf \
		"$srcdir"/dejavu-lgc-fonts-ttf-$pkgver/ttf/*.ttf \
		"$pkgdir"/usr/share/fonts/$pkgname

	install -m644 "$srcdir"/dejavu-fonts-ttf-$pkgver/fontconfig/*.conf \
		"$srcdir"/dejavu-lgc-fonts-ttf-$pkgver/fontconfig/*.conf \
		"$pkgdir"/etc/fonts/conf.avail
}





