#!/bin/bash

export SCRIPT_PATH=$(dirname $(readlink -f $0))
export BASE_PATH=${BASE_PATH:-${SCRIPT_PATH}}
export SRC_PATH=${SRC_PATH:-${BASE_PATH}/src}
export PACKAGES=${PACKAGES:-${SCRIPT_PATH}/../pkg}
export PACKAGES_TOOLCHAIN=${PACKAGES_TOOLCHAIN:-${PACKAGES}/toolchain}
export PREFIX=${PREFIX:-${SCRIPT_PATH}/local}
export BUILD=${BUILD:-${SCRIPT_PATH}/build}

export TOOLCHAIN=${TOOLCHAIN:-arm-unknown-linux-uclibcgnueabi}
export TOOLCHAIN_PATH=${TOOLCHAIN_PATH:-${PREFIX}/x-tools/${TOOLCHAIN}}
export CROSS_COMPILER_PATH=${CROSS_COMPILER_PATH:-${TOOLCHAIN_PATH}/bin}
export CROSS_COMPILE=${CROSS_COMPILE:-arm-linux-}
export SYSROOT=${TOOLCHAIN_PATH}/${TOOLCHAIN}/sysroot

export ARCH=${ARCH:-arm}

export QEMU_PATH=${QEMU_PATH:-${PREFIX}/bin}
export QEMU=${QEMU:-${QEMU_PATH}/qemu-system-${ARCH}}

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
	echo -n "SCRIPT_PATH           "; show_dir_exists ${SCRIPT_PATH}        ; echo " = ${SCRIPT_PATH}"
	echo -n "BASE_PATH             "; show_dir_exists ${BASE_PATH}          ; echo " = ${BASE_PATH}"
	echo -n "SRC_PATH              "; show_dir_exists ${SRC_PATH}           ; echo " = ${SRC_PATH}"
	echo -n "PACKAGES              "; show_dir_exists ${PACKAGES}           ; echo " = ${PACKAGES}"
	echo -n "PACKAGES_TOOLCHAIN    "; show_dir_exists ${PACKAGES_TOOLCHAIN} ; echo " = ${PACKAGES_TOOLCHAIN}"
	echo -n "PREFIX                "; show_dir_exists ${PREFIX}             ; echo " = ${PREFIX}"
	echo -n "BUILD                 "; show_dir_exists ${BUILD}              ; echo " = ${BUILD}"
	echo ""
	echo "ARCH                      = ${ARCH}"
	echo "TOOLCHAIN                 = ${TOOLCHAIN}"
	echo ""
	echo -n "TOOLCHAIN_PATH        "; show_dir_exists ${TOOLCHAIN_PATH} ; echo " = ${TOOLCHAIN_PATH}"
	echo -n "SYSROOT               "; show_dir_exists ${SYSROOT}        ; echo " = ${SYSROOT}"
	echo -n "CROSS_COMPILER_PATH   "; show_dir_exists ${CROSS_COMPILER_PATH} ; echo " = ${CROSS_COMPILER_PATH}"
	echo -n "CROSS_COMPILE         "; show_exe_exists ${CROSS_COMPILER_PATH}/${CROSS_COMPILE}gcc ; echo " = ${CROSS_COMPILE}gcc"
	echo ""
	echo -n "QEMU_PATH             "; show_dir_exists ${QEMU_PATH}   ; echo " = ${QEMU_PATH}"
	echo -n "QEMU                  "; show_exe_exists ${QEMU}        ; echo " = ${QEMU}"
	echo ""
	echo -n "LINUX (versatile)     "; show_exe_exists ${PREFIX}/zImage-versatile     ; echo " = zImage-versatile"
	echo -n "LINUX (versatile-bbv) "; show_exe_exists ${PREFIX}/zImage-versatile-bbv ; echo " = zImage-versatile-bbv"
	echo ""
	echo "PATH                      = ${PATH}"
	echo ""
	echo -n "QT_BIN                "; show_dir_exists ${QT_BIN}   ; echo " = ${QT_BIN}"
	echo -n "qmake                 "; show_exe_exists ${QT_BIN}/qmake
	echo ""
}

if [ $# -eq 0 ] ; then
	echo ""
	echo "usage: $(basename $0) command"
	echo ""
	echo "Commands:"
	echo "  info             : displays information about the environment"
	echo "  sh               : starts a shell (bash) with all environment variables defined"
	echo "  download command : download of packages"
	echo "  build command    : invokes a build with specified command"
	echo "  start command    : starts the qemu with specified command"
	echo ""
	exit 1
fi

case $1 in
	info)
		show_info
		;;

	sh)
		export PATH=$PATH:${CROSS_COMPILER_PATH}
		/bin/bash --rcfile bashrc.local -i
		;;

	download)
		shift
		${SCRIPT_PATH}/download.sh $*
		;;

	build)
		export PATH=$PATH:${CROSS_COMPILER_PATH}
		shift
		${SCRIPT_PATH}/build.sh $*
		;;

	start)
		shift
		${SCRIPT_PATH}/start.sh $*
		;;

	*)
		die "unknown target: $1"
		;;
esac
exit 0

