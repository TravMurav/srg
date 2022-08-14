pkgname=ncurses
pkgver=6.3_p20220729
_pkgver=${pkgver/_p/-}
pkgrel=0
pkgdesc="Console display library"
url="https://invisible-island.net/ncurses/"

depends="musl"

source="
	https://invisible-mirror.net/archives/ncurses/current/ncurses-$_pkgver.tgz
"

builddir="$srcdir/$pkgname-$_pkgver"

# Terminfo definitions to be included in ncurses-terminfo-base.
_basic_terms="
	alacritty
	ansi
	console
	dumb
	gnome
	gnome-256color
	konsole
	konsole-256color
	konsole-linux
	linux
	putty
	putty-256color
	rxvt
	rxvt-256color
	screen
	screen-256color
	st-*
	sun
	terminator
	terminology*
	tmux
	tmux-256color
	vt100
	vt102
	vt200
	vt220
	vt52
	vte
	vte-256color
	xterm
	xterm-256color
	xterm-color
	xterm-kitty
	xterm-xfree86
	"

build() {
	./configure \
		--build=$CBUILD \
		--host=$CHOST \
		--mandir=/usr/share/man \
		--without-ada \
		--without-tests \
		--disable-termcap \
		--disable-rpath-hack \
		--disable-stripping \
		--with-pkg-config-libdir=/usr/lib/pkgconfig \
		--without-cxx-binding \
		--with-terminfo-dirs="/etc/terminfo:/usr/share/terminfo:/lib/terminfo:/usr/lib/terminfo" \
		--enable-pc-files \
		--with-shared \
		--enable-widec

	make
}

package() {
	make -j1 DESTDIR="$pkgdir" install

	cd "$pkgdir"

	# force link against *w.so
	local lib; for lib in ncurses ncurses++ form panel menu; do
		ln -s ${lib}w.pc usr/lib/pkgconfig/$lib.pc
		ln -s lib${lib}w.a usr/lib/lib$lib.a
		echo "INPUT(-l${lib}w)" > usr/lib/lib$lib.so
	done

	# link curses -> ncurses
	ln -s libncurses.a usr/lib/libcurses.a
	ln -s libncurses.so usr/lib/libcurses.so
	echo 'INPUT(-lncursesw)' > usr/lib/libcursesw.so

	# Install basic terms in /etc/terminfo
	local i; for i in $_basic_terms; do
		local termfiles=$(find usr/share/terminfo/ -name "$i" 2>/dev/null) || true

		[ -z "$termfiles" ] && continue

		for termfile in $termfiles; do
			local basedir=$(basename "$(dirname "$termfile")")
			install -d etc/terminfo/$basedir
			mv "$termfile" etc/terminfo/$basedir/
			ln -s "../../../../etc/terminfo/$basedir/${termfile##*/}" \
				"usr/share/terminfo/$basedir/${termfile##*/}"
		done
	done
}

build_oln="1827"
package_oln="1035"
