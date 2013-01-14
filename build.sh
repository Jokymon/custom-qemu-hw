#!/bin/bash

export SCRIPT_PATH=$(dirname $(readlink -f $0))
export PACKAGES=${PACKAGES:-${SCRIPT_PATH}/../pkg}
export PREFIX=${PREFIX:-${SCRIPT_PATH}/local}
export BUILD=${BUILD:-${SCRIPT_PATH}/build}

export CROSS_COMPILER_PATH=${CROSS_COMPILER_PATH:-${PREFIX}/x-tools/arm-unknown-linux-uclibcgnueabi/bin}
export CROSS_COMPILE=${CROSS_COMPILE:-arm-linux-}

export ARCH=${ARCH:-arm}

function die()
{
	echo ""
	echo "ERROR: $1"
	echo ""
	exit -1
}

function show_dir_exists()
{
	if [ -d $1 ] ; then
		echo -n "(E)"
	else
		echo -n "(N)"
	fi
}

function show_exe_exists()
{
	if [ -x $1 ] ; then
		echo -n "(E)"
	else
		echo -n "(N)"
	fi
}

function show_info()
{
	echo ""
	echo -n "SCRIPT_PATH         "; show_dir_exists ${SCRIPT_PATH}         ; echo " = ${SCRIPT_PATH}"
	echo -n "PACKAGES            "; show_dir_exists ${PACKAGES}            ; echo " = ${PACKAGES}"
	echo -n "PREFIX              "; show_dir_exists ${PREFIX}              ; echo " = ${PREFIX}"
	echo -n "BUILD               "; show_dir_exists ${BUILD}               ; echo " = ${BUILD}"
	echo ""
	echo "ARCH                    = ${ARCH}"
	echo ""
	echo -n "CROSS_COMPILER_PATH "; show_dir_exists ${CROSS_COMPILER_PATH} ; echo " = ${CROSS_COMPILER_PATH}"
	echo -n "CROSS_COMPILE       "; show_exe_exists ${CROSS_COMPILER_PATH}/${CROSS_COMPILE}gcc ; echo " = ${CROSS_COMPILE}gcc"
	echo ""
	echo -n "QEMU                "; show_exe_exists ${PREFIX}/bin/qemu-system-${ARCH}; echo " = qemu-system-${ARCH}"
	echo -n "LINUX (versatile)   "; show_exe_exists ${PREFIX}/zImage-versatile ; echo " = zImage-versatile"
	echo ""
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

function build_qemu()
{
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

function build_kernel_versatile()
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

	cp ${SCRIPT_PATH}/kernel/config-versatile ${BUILD}/linux-2.6.38/.config
	if [ $? -ne 0 ] ; then
		die "cannot copy kernel configuration"
	fi

	cd ${BUILD}/linux-2.6.38
	make all
	if [ $? -ne 0 ] ; then
		die "cannot build kernel"
	fi

	cp arch/arm/boot/zImage ${PREFIX}/zImage-versatile
	if [ $? -ne 0 ] ; then
		die "cannot copy kernel to ${PREFIX}"
	fi
}

function build_busybox()
{
	prepare_build
	prepare_prefix

	export PATH=${CROSS_COMPILER_PATH}:${PATH}

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
	echo "  info"
	echo "  toolchain"
	echo "  qemu"
	echo "  kernel-versatile"
	echo "  busybox"
	echo "  clean"
	echo ""
	exit 1
fi

case $1 in
	info)
		show_info
		;;

	toolchain)
		unpack_toolchain
		;;

	qemu)
		build_qemu
		;;

	kernel-versatile)
		build_kernel_versatile
		;;

	busybox)
		build_busybox
		;;

	clean)
		cleanup
		;;

	*)
		die "unknown target: $1"
		;;
esac
exit 0

