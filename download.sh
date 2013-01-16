#!/bin/bash

PACKS_BASE=(
	http://www.kernel.org/pub/linux/kernel/v2.6/linux-2.6.38.tar.bz2
	http://www.busybox.net/downloads/busybox-1.20.1.tar.bz2
	http://www.crosstool-ng.org/download/crosstool-ng/crosstool-ng-1.17.0.tar.bz2
	http://wiki.qemu-project.org/download/qemu-1.3.0.tar.bz2
)

PACKS_TOOLCHAIN=(
	http://ftp.gnu.org/gnu/binutils/binutils-2.19.1a.tar.bz2
	http://ftp.gnu.org/gnu/gcc/gcc-4.4.3/gcc-4.4.3.tar.bz2
	http://ftp.gnu.org/gnu/gdb/gdb-6.8a.tar.bz2
	http://ftp.gnu.org/gnu/gmp/gmp-4.3.2.tar.bz2
	http://ftp.gnu.org/gnu/mpfr/mpfr-2.4.2.tar.bz2
	http://ftp.gnu.org/pub/gnu/ncurses/ncurses-5.9.tar.gz
	http://ignum.dl.sourceforge.net/project/expat/expat/2.1.0/expat-2.1.0.tar.gz
	http://www.mr511.de/software/libelf-0.8.13.tar.gz
	http://heanet.dl.sourceforge.net/project/strace/strace/4.5.19/strace-4.5.19.tar.bz2
	http://www.uclibc.org/downloads/uClibc-0.9.30.2.tar.bz2
	http://ltrace.sourcearchive.com/downloads/0.5.3/ltrace_0.5.3.orig.tar.gz
)

function die()
{
	echo ""
	echo "ERROR: $1"
	echo ""
	exit -1
}

function download_base()
{
	if [ ! -d ${PACKAGES} ] ; then
		mkdir -p ${PACKAGES}
		if [ $? -ne 0 ] ; then
			die "cannot create package directory: ${PACKAGES}"
		fi
	fi

	for pack in ${PACKS_BASE[*]} ; do
		if [ ! -r ${PACKAGES}/$(basename ${pack}) ] ; then
			wget ${pack} -O ${PACKAGES}/$(basename ${pack})
		fi
	done
}

function download_toolchain()
{
	if [ ! -d ${PACKAGES_TOOLCHAIN} ] ; then
		mkdir -p ${PACKAGES_TOOLCHAIN}
		if [ $? -ne 0 ] ; then
			die "cannot create package directory: ${PACKAGES_TOOLCHAIN}"
		fi
	fi

	for pack in ${PACKS_TOOLCHAIN[*]} ; do
		if [ ! -r ${PACKAGES_TOOLCHAIN}/$(basename ${pack}) ] ; then
			wget ${pack} -O ${PACKAGES_TOOLCHAIN}/$(basename ${pack})
		fi
	done
}

function show_info()
{
	echo ""
	echo "Base Packages:"
	for pack in ${PACKS_BASE[*]} ; do
		echo "  $(basename ${pack})"
	done
	echo ""
	echo "Toolchain Packages:"
	for pack in ${PACKS_TOOLCHAIN[*]} ; do
		echo "  $(basename ${pack})"
	done
	echo ""
}

if [ $# -eq 0 ] ; then
	echo ""
	echo "usage: $(basename $0) command"
	echo ""
	echo "Commands:"
	echo "  info      : shows all packages to download"
	echo "  base      : download of base packages"
	echo "  toolchain : download of toolchain packages"
	echo ""
	exit 1
fi

case $1 in
	info)
		show_info
		;;

	base)
		download_base
		;;

	toolchain)
		download_toolchain
		;;

	*)
		die "unknown target: $1"
		;;
esac
exit 0

