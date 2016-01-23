PICOLIN_LINUX_SRC=linux-4.4
PICOLIN_LINUX_PKG=linux-4.4.tar.xz
PICOLIN_LINUX_URL=https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.4.tar.xz

PICOLIN_BUSYBOX_SRC=busybox-1.24.1
PICOLIN_BUSYBOX_PKG=busybox-1.24.1.tar.bz2
PICOLIN_BUSYBOX_URL=http://busybox.net/downloads/busybox-1.24.1.tar.bz2

all: setup picolin-kernel picolin-initrd

boot:
	qemu-system-x86_64 -enable-kvm -kernel out/bzImage -initrd out/initrd -append init=/bin/sh

# build linux kernel

picolin-kernel: out/bzImage

out/bzImage: src/$(PICOLIN_LINUX_SRC)/.config
	cd "src/$(PICOLIN_LINUX_SRC)" && make -j2
	cp "src/$(PICOLIN_LINUX_SRC)/arch/x86/boot/bzImage" out/bzImage


# build initial ramdisk

picolin-initrd: out/initrd

out/initrd: src/$(PICOLIN_BUSYBOX_SRC)/busybox rootfs
	cd src/rootfs && find . -print0 | cpio --null -ov --format=newc | gzip -9 > ../../out/initrd

rootfs: src/$(PICOLIN_BUSYBOX_SRC)/busybox
	mkdir -p src/rootfs
	rm -r src/rootfs/* || true
	cd src/rootfs && mkdir -p bin sbin etc proc sys usr/bin usr/sbin
	cp -av src/$(PICOLIN_BUSYBOX_SRC)/_install/* src/rootfs/

src/$(PICOLIN_BUSYBOX_SRC)/busybox: src/$(PICOLIN_BUSYBOX_SRC)/.config
	cd "src/$(PICOLIN_BUSYBOX_SRC)" && make -j2 && make install


# download packages and uncompress
setup:      download uncompress
uncompress: src/$(PICOLIN_LINUX_SRC)/README src/$(PICOLIN_BUSYBOX_SRC)/README
download:   pkg/$(PICOLIN_LINUX_PKG)        pkg/$(PICOLIN_BUSYBOX_PKG)

src/$(PICOLIN_LINUX_SRC)/README:
	cd src && tar xvf "../pkg/$(PICOLIN_LINUX_PKG)"
	cd src/$(PICOLIN_LINUX_SRC) && ln -s ../../etc/linux-config .config

src/$(PICOLIN_BUSYBOX_SRC)/README:
	cd src && tar xvf "../pkg/$(PICOLIN_BUSYBOX_PKG)"
	cd src/$(PICOLIN_BUSYBOX_SRC) && ln -s ../../etc/busybox-config .config

pkg/$(PICOLIN_LINUX_PKG):
	cd pkg && wget "$(PICOLIN_LINUX_URL)"

pkg/$(PICOLIN_BUSYBOX_PKG):
	cd pkg && wget "$(PICOLIN_BUSYBOX_URL)"
