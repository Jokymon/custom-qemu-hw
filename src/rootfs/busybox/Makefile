.PHONY: all
.PHONY: clean
.PHONY: rootfs-init
.PHONY: busybox
.PHONY: busybox-install
.PHONY: ramdisk-create
.PHONY: ramdisk-mount
.PHONY: ramdisk-umount
.PHONY: app-install

export CONFIG_PREFIX=$(CURDIR)/mnt

ifeq ($(shell which arm-linux-gcc),)
  $(error Cross toolchain not in path)
endif

all : gpio_toggle
	$(MAKE) ramdisk-create
	$(MAKE) ramdisk-mount
	$(MAKE) rootfs-init
	$(MAKE) busybox-install
	$(MAKE) -C modules
	$(MAKE) modules-install
	$(MAKE) app-install
	$(MAKE) ramdisk-umount

gpio_toggle : gpio_toggle.o
	$(CC) -o $@ $^

rootfs-init :
	(cd mnt \
		&& sudo mkdir -p proc sys dev etc sbin mnt \
		&& sudo mkdir -p var var/log \
		&& sudo mkdir -p root home \
		&& sudo mkdir -p lib/modules/2.6.38qemu \
		&& cd dev \
		&& sudo mknod null c 1 3 \
		&& sudo mknod console c 5 1 \
		&& sudo chmod 777 * \
	)
	sudo cp -a --preserve $(SYSROOT)/lib/lib*.so* mnt/lib
	sudo cp -a --preserve $(SYSROOT)/lib/ld-*.so* mnt/lib

busybox-install :
	(cd $(BUILD)/busybox-1.20.2 \
		&& sudo env PATH=$${PATH} make CROSS_COMPILE=$(CROSS_COMPILE) ARCH=$(ARCH) CONFIG_PREFIX=$(CONFIG_PREFIX) install \
	)
	sudo chmod u+s mnt/bin/busybox
	sudo cp -R etc/* mnt/etc
	sudo mkdir -p mnt/home/user
	sudo chown 1000:1000 mnt/home/user

modules-install :
	sudo cp modules/simple_km.ko $(CONFIG_PREFIX)/lib/modules/2.6.38qemu

app-install :
	sudo mkdir -p mnt/usr/local/bin \
		&& sudo cp gpio_toggle mnt/usr/local/bin/

ramdisk-mount :
	mkdir -p mnt
	sudo mount -o loop ramdisk mnt

ramdisk-umount :
	sudo sync
	sudo umount mnt

ramdisk-create :
	dd if=/dev/zero of=ramdisk bs=1024 count=8192
	sudo losetup /dev/loop0 ramdisk
	sudo mkfs.ext2 /dev/loop0
	sudo losetup -d /dev/loop0

clean :
	rm -f ramdisk*
	rm -fr mnt
	rm -f *.o
	rm -f gpio_toggle
	$(MAKE) -C modules clean

%.o : %.c
	$(CC) -o $@ -c $< $(CFLAGS)

