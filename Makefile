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
	$(MAKE) -C src/rootfs/cpio
	$(MAKE) -C src/rootfs/ext2
	$(MAKE) -C src/rootfs/ext2-2
	$(MAKE) -C src/rootfs/busybox

cpio :
	$(MAKE) -C src/rootfs/cpio

ext2 :
	$(MAKE) -C src/rootfs/ext2

ext2-2 :
	$(MAKE) -C src/rootfs/ext2-2

busybox :
	$(MAKE) -C src/rootfs/busybox

clean :
	$(MAKE) -C src/rootfs/cpio clean
	$(MAKE) -C src/rootfs/ext2 clean
	$(MAKE) -C src/rootfs/ext2-2 clean
	$(MAKE) -C src/rootfs/busybox clean

