pkgname=vtclock
pkgver=git_20220813
pkgrel=0
pkgdesc="a giant text-mode clock"
url="https://github.com/dse/vtclock"

_commit="8ca96dc31751a1b5dc4d0270ee9beab6f2f687e3"

depends="ncurses"

source="
	https://github.com/dse/vtclock/archive/$_commit.tar.gz
"

builddir="$srcdir/$pkgname-$_commit"

build() {
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



