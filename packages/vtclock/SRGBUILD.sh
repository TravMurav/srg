pkgname=vtclock
pkgver=git_20220813
pkgrel=1
pkgdesc="a giant text-mode clock"
url="https://github.com/dse/vtclock"

_commit="8ca96dc31751a1b5dc4d0270ee9beab6f2f687e3"

depends="ncurses"

source="
	https://github.com/dse/vtclock/archive/$_commit.tar.gz
"

builddir="$srcdir/$pkgname-$_commit"

build() {
	cat "$srcdir/0001-Shrink-the-small-font-so-it-can-fit-on-a-VERY-snall-.patch" | patch

	make \
		CC="$CROSS_COMPILE"gcc \
		prefix="/usr"
}

package() {
	make \
		DESTDIR="$pkgdir" \
		prefix="/usr" \
		install
}

build_oln="7"
package_oln="2"
