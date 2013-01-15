.PHONY: all
.PHONY: clean
.PHONY: check-toolchain
.PHONY: cpio ext2 ext2-2 busybox

export CC=$(CROSS_COMPILER_PATH)/$(CROSS_COMPILE)gcc
export STRIP=$(CROSS_COMPILER_PATH)/$(CROSS_COMPILE)strip

ifeq ($(shell which arm-linux-gcc),)
  $(error Cross toolchain not in path)
endif

all :
	$(MAKE) -C rootfs/cpio
	$(MAKE) -C rootfs/ext2
	$(MAKE) -C rootfs/ext2-2
	$(MAKE) -C rootfs/busybox

cpio :
	$(MAKE) -C rootfs/cpio

ext2 :
	$(MAKE) -C rootfs/ext2

ext2-2 :
	$(MAKE) -C rootfs/ext2-2

busybox :
	$(MAKE) -C rootfs/busybox

clean :
	$(MAKE) -C rootfs/cpio clean
	$(MAKE) -C rootfs/ext2 clean
	$(MAKE) -C rootfs/ext2-2 clean
	$(MAKE) -C rootfs/busybox clean

