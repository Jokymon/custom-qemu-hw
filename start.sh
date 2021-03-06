#!/bin/bash

if [ $# -ne 1 ] ; then
	echo ""
	echo "usage: $(basename $0) demo"
	echo ""
	echo "Demo:"
	echo "  cpio"
	echo "  ext2"
	echo "  ext2-2"
	echo "  busybox"
	echo "  cpio-bbv"
	echo "  busybox-bbv"
	echo ""
	exit -1
fi

case $1 in
	cpio)
		${QEMU} \
			-M versatilepb \
			-kernel ${PREFIX}/zImage-versatile \
			-initrd ${SRC_PATH}/rootfs/cpio/rootfs \
			-append "root=/dev/ram rdinit=/test"
		;;

	ext2)
		${QEMU} \
			-M versatilepb \
			-kernel ${PREFIX}/zImage-versatile \
			-initrd ${SRC_PATH}/rootfs/ext2/ramdisk \
			-append "root=/dev/ram rootfstype=ext2 rdinit=/sbin/init"
		;;

	ext2-2)
		${QEMU} \
			-M versatilepb \
			-kernel ${PREFIX}/zImage-versatile \
			-initrd ${SRC_PATH}/rootfs/ext2-2/ramdisk \
			-append "root=/dev/ram rootfstype=ext2 rdinit=/sbin/init"
		;;

	busybox)
		${QEMU} \
			-M versatilepb \
			-kernel ${PREFIX}/zImage-versatile \
			-initrd ${SRC_PATH}/rootfs/busybox/ramdisk \
			--show-cursor \
			-append "root=/dev/ram rw ramdisk_size=8192 rootfstype=ext2 init=/sbin/init"
		;;

	cpio-bbv)
		${QEMU} \
			-M versatile-bbv \
			-kernel ${PREFIX}/zImage-versatile-bbv \
			-initrd ${SRC_PATH}/rootfs/cpio/rootfs \
			-append "root=/dev/ram rdinit=/test"
		;;

	busybox-bbv)
		${QEMU} \
			-M versatile-bbv \
			-kernel ${PREFIX}/zImage-versatile-bbv \
			-initrd ${SRC_PATH}/rootfs/busybox/ramdisk \
			--show-cursor \
			-append "root=/dev/ram rw ramdisk_size=8192 rootfstype=ext2 init=/sbin/init"
		;;

	*)
		echo "ERROR: unknown target: $1"
		exit -1
		;;
esac
exit 0

