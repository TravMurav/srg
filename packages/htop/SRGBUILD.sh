pkgname=htop
pkgver=3.2.1
pkgrel=0
pkgdesc="Interactive process viewer"
url="https://htop.dev/"

depends="ncurses"

source="
	https://github.com/htop-dev/htop/archive/$pkgver.tar.gz
"

builddir="$srcdir/$pkgname-$pkgver"

build() {
	./autogen.sh
	./configure \
		--build=$CBUILD \
		--host=$CHOST \
		--prefix=/usr \
		--sysconfdir=/etc \
		--mandir=/usr/share/man \
		--localstatedir=/var \
		--enable-cgroup \
		--enable-taskstats
	make
}

package() {
	make DESTDIR="$pkgdir" install
}

build_oln="408"
package_oln="12"
