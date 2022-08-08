pkgname=srg-baselayout
pkgver=1
pkgrel=0
pkgdesc="Base FS layout for the system rootfs"
url=""

source=""

builddir="$srcdir/"

build() {
	# Nothing to do
	true
}

package() {
	cd "$pkgdir"
	install -m 0755 -d \
		dev \
		dev/pts \
		dev/shm \
		etc \
		etc/conf.d \
		etc/crontabs \
		etc/init.d \
		etc/rcS.d \
		mnt \
		proc \
		opt \
		run \
		sbin \
		srv \
		sys \
		usr/bin \
		usr/local/bin \
		usr/local/lib \
		usr/local/share \
		usr/sbin \
		usr/share \
		usr/share/man \
		usr/share/misc \
		var/cache \
		var/cache/misc \
		var/lib \
		var/lib/misc \
		var/local \
		var/lock/subsys \
		var/log \
		var/opt \
		var/spool \
		var/spool/cron \
		var/mail

	ln -s /run var/run
	install -d -m 0555 var/empty
	install -d -m 0700 "$pkgdir"/root
	install -d -m 1777 "$pkgdir"/tmp "$pkgdir"/var/tmp

	echo "localhost" > "$pkgdir"/etc/hostname
	cat > "$pkgdir"/etc/hosts <<-EOF
		127.0.0.1	localhost localhost.localdomain
		::1		localhost localhost.localdomain
	EOF

	cat > "$pkgdir"/etc/shells <<-EOF
		# valid login shells
		/bin/sh
		/bin/ash
	EOF

	cat > "$pkgdir"/etc/motd <<-EOF
		Welcome to an srg-based rootfs!

		The list of  installed packages should be
		available in /var/srg/world

	EOF

	cat > "$pkgdir"/etc/init.d/rcS <<-EOF
		#!/bin/sh

		mount -t proc none /proc                                                        
		mount -t sysfs none /sys                                                        
		mount -t devpts none /dev/pts                                                   
		mount -t ramfs none /tmp

		mdev -s

		for script in /etc/rcS.d/S*
		do
			echo [rcS] Starting \$(basename \$script)
			\$script
		done
	EOF

	cat > "$pkgdir"/etc/rcS.d/S99_local <<-EOF
		#!/bin/sh

	EOF

	chmod +x \
		"$pkgdir"/etc/init.d/rcS \
		"$pkgdir"/etc/rcS.d/S99_local
}


