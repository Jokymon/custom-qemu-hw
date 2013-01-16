#!/bin/bash

function die()
{
	echo ""
	echo "ERROR: $1"
	echo ""
	exit -1
}

function prepare_build()
{
	if [ ! -d ${BUILD} ] ; then
		mkdir -p ${BUILD}
		if [ $? -ne 0 ] ; then
			die "cannot create build directory: ${BUILD}"
		fi
	fi
}

function prepare_prefix()
{
	if [ ! -d ${PREFIX} ] ; then
		mkdir -p ${PREFIX}
		if [ $? -ne 0 ] ; then
			die "cannot create installation directory: ${PREFIX}"
		fi
	fi
}

function unpack_toolchain()
{
	prepare_prefix

	tar -xjf ${PACKAGES}/x-tools.tar.bz2 -C ${PREFIX}
	if [ $? -ne 0 ] ; then
		die "cannot unpack toolchain"
	fi
}

function build_toolchain()
{
	prepare_build
	prepare_prefix

	tar -xjf ${PACKAGES}/crosstool-ng-1.17.0.tar.bz2 -C ${BUILD}
	if [ $? -ne 0 ] ; then
		die "cannot unpack crosstool-ng"
	fi

	cd ${BUILD}/crosstool-ng-1.17.0
	./configure --enable-local
	if [ $? -ne 0 ] ; then
		die "cannot configure crosstool-ng"
	fi

	make
	if [ $? -ne 0 ] ; then
		die "cannot make crosstool-ng"
	fi

	make install
	if [ $? -ne 0 ] ; then
		die "cannot install crosstool-ng"
	fi

	cp ${BASE_PATH}/config/ctng ${BUILD}/crosstool-ng-1.7.0/.config
	if [ $? -ne 0 ] ; then
		die "cannot copy crosstool-ng configuration"
	fi

	./ct-ng build
	if [ $? -ne 0 ] ; then
		die "cannot build toolchain using crosstool-ng"
	fi
}

function build_qemu()
{
	# TODO:mk: qemu from which source? bbv patch or forked (submodule) repository?

	prepare_build
	prepare_prefix

	if [ -d ${BUILD}/qemu-1.3.0 ] ; then
		rm -fr ${BUILD}/qemu-1.3.0
		if [ $? -ne 0 ] ; then
			die "cannot cleanup prior building qemu"
		fi
	fi

	tar -xjf ${PACKAGES}/qemu-1.3.0.tar.bz2 -C ${BUILD}
	if [ $? -ne 0 ] ; then
		die "cannot unpack qemu sources"
	fi

	cd ${BUILD}/qemu-1.3.0
	./configure --prefix=${PREFIX} --target-list=arm-linux-user,arm-softmmu
	if [ $? -ne 0 ] ; then
		die "configuration of qemu failed"
	fi

	make
	if [ $? -ne 0 ] ; then
		die "build of qemu failed"
	fi

	make install
	if [ $? -ne 0 ] ; then
		die "installation of qemu failed"
	fi
}

function build_kernel()
{
	prepare_build
	prepare_prefix

	export PATH=${CROSS_COMPILER_PATH}:${PATH}

	if [ -d ${BUILD}/linux-2.6.38 ] ; then
		rm -fr ${BUILD}/linux-2.6.38
		if [ $? -ne 0 ] ; then
			die "cannot cleanup prior building linux"
		fi
	fi

	tar -xjf ${PACKAGES}/linux-2.6.38.tar.bz2 -C ${BUILD}
	if [ $? -ne 0 ] ; then
		die "cannot unpack linux sources"
	fi

	cp ${BASE_PATH}/config/kernel-$1 ${BUILD}/linux-2.6.38/.config
	if [ $? -ne 0 ] ; then
		die "cannot copy kernel configuration"
	fi

	cd ${BUILD}/linux-2.6.38
	make all
	if [ $? -ne 0 ] ; then
		die "cannot build kernel"
	fi

	cp arch/arm/boot/zImage ${PREFIX}/zImage-$1
	if [ $? -ne 0 ] ; then
		die "cannot copy kernel to ${PREFIX}"
	fi
}

function build_busybox()
{
	prepare_build
	prepare_prefix

	if [ -d ${BUILD}/busybox-1.20.2 ] ; then
		rm -fr ${BUILD}/busybox-1.20.2
		if [ $? -ne 0 ] ; then
			die "cannot cleanup prior building busybox"
		fi
	fi

	tar -xjf ${PACKAGES}/busybox-1.20.2.tar.bz2 -C ${BUILD}
	if [ $? -ne 0 ] ; then
		die "cannot unpack busybox sources"
	fi

	cd ${BUILD}/busybox-1.20.2
	make defconfig
	if [ $? -ne 0 ] ; then
		die "cannot configure busybox"
	fi

	make
	if [ $? -ne 0 ] ; then
		die "cannot build busybox"
	fi
}

function cleanup()
{
	if [ -d ${PREFIX}/x-tools ] ; then
		chmod -R u+w ${PREFIX}/x-tools
	fi

	rm -fr ${PREFIX}
	if [ $? -ne 0 ] ; then
		die "cannot remove ${PREFIX}"
	fi

	rm -fr ${BUILD}
	if [ $? -ne 0 ] ; then
		die "cannot remove ${BUILD}"
	fi
}

if [ $# -eq 0 ] ; then
	echo ""
	echo "usage: $0 command"
	echo ""
	echo "Commands:"
	echo "  clean                : cleans up build and local deployment directories"
	echo "  all                  : only for convenience, contains toolchain, qemu, busybox, kernel-*"
	echo "  toolchain            : extracts the toolchain (x86 based)"
	echo "  toolchain-scratch    : builds toolchain from scratch"
	echo "  qemu                 : builds standard qemu from source"
	echo "  busybox              : builds busyboard"
	echo "  kernel-versatile     : builds Linux kernel for the versatile board"
	echo "  kernel-versatile-bbv : builds Linux kernel for the versatile bbv custom board"
	echo ""
	exit 1
fi

case $1 in
	clean)
		cleanup
		;;

	all)
		unpack_toolchain
		build_qemu
		build_busybox
		build_kernel "versatile"
		build_kernel "versatile-bbv"
		;;

	toolchain)
		unpack_toolchain
		;;

	toolchain-scratch)
		build_toolchain
		;;

	qemu)
		build_qemu
		;;

	busybox)
		build_busybox
		;;

	kernel-versatile)
		build_kernel "versatile"
		;;

	kernel-versatile-bbv)
		build_kernel "versatile-bbv"
		;;

	*)
		die "unknown target: $1"
		;;
esac
exit 0

