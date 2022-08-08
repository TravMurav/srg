pkgname=fbkeyboard
pkgver=0.4
pkgrel=3
pkgdesc="Framebuffer softkeyboard for use on devices with touchscreen input like smartphones"
url="https://github.com/bakonyiferenc/fbkeyboard"

depends="freetype ttf-dejavu"

source="https://github.com/bakonyiferenc/fbkeyboard/archive/refs/tags/$pkgver.tar.gz"

builddir="$srcdir/$pkgname-$pkgver"

build() {
	${CROSS_COMPILE}gcc -o fbkeyboard $(pkg-config --cflags freetype2) fbkeyboard.c $(pkg-config --libs freetype2)
}

package() {
	install -Dm755 fbkeyboard "$pkgdir"/usr/bin/fbkeyboard

	install -m 0755 -d \
		"$pkgdir"/etc/rcS.d

	cat > "$pkgdir"/etc/rcS.d/S95_fbkeyboard <<-EOF
		#!/bin/sh
		
		/usr/bin/fbkeyboard &
	EOF

	chmod +x \
		"$pkgdir"/etc/rcS.d/S*
}

