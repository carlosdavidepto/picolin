PICOLIN_LINUX_SRC=linux-4.4
PICOLIN_LINUX_PKG=linux-4.4.tar.xz
PICOLIN_LINUX_URL=https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.4.tar.xz

PICOLIN_BUSYBOX_SRC=busybox-1.24.1
PICOLIN_BUSYBOX_PKG=busybox-1.24.1.tar.bz2
PICOLIN_BUSYBOX_URL=http://busybox.net/downloads/busybox-1.24.1.tar.bz2


all: picolin-kernel picolin-initrd


# build linux kernel

picolin-kernel: out/bzImage

out/bzImage: src/$(PICOLIN_LINUX_SRC)/.config
	cd "src/$(PICOLIN_LINUX_SRC)" && make -j2
	cp "src/$(PICOLIN_LINUX_SRC)/arch/x86/boot/bzImage" out/bzImage

src/$(PICOLIN_LINUX_SRC)/.config: pkg/$(PICOLIN_LINUX_PKG)
	cd src && tar xvf "../pkg/$(PICOLIN_LINUX_PKG)" && cd "$(PICOLIN_LINUX_SRC)" && make allnoconfig

pkg/$(PICOLIN_LINUX_PKG):
	cd pkg && wget "$(PICOLIN_LINUX_URL)"

# build initial ramdisk

picolin-initrd: out/initrd

out/initrd: src/$(PICOLIN_BUSYBOX_SRC)/busybox rootfs
	cd src/rootfs && find . -print0 | cpio --null -ov --format=newc | gzip -9 > ../../out/initrd

rootfs: src/$(PICOLIN_BUSYBOX_SRC)/busybox
	cd src/rootfs && mkdir -p bin sbin etc proc sys usr/bin usr/sbin
	cp -av src/$(PICOLIN_BUSYBOX_SRC)/_install/* src/rootfs/

src/$(PICOLIN_BUSYBOX_SRC)/busybox: src/$(PICOLIN_BUSYBOX_SRC)/.config
	cd "src/$(PICOLIN_BUSYBOX_SRC)" && make -j2 && make install

src/$(PICOLIN_BUSYBOX_SRC)/.config: pkg/$(PICOLIN_BUSYBOX_PKG)
	cd src && tar xvf "../pkg/$(PICOLIN_BUSYBOX_PKG)" && cd "$(PICOLIN_BUSYBOX_SRC)" && make alldefconfig

pkg/$(PICOLIN_BUSYBOX_PKG):
	cd pkg && wget "$(PICOLIN_BUSYBOX_URL)"
