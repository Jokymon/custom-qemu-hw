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

	tar -xjf ${PACKAGES}/x-tools$1.tar.bz2 -C ${PREFIX}
	if [ $? -ne 0 ] ; then
		die "cannot unpack toolchain"
	fi
}

function build_toolchain()
{
	export CROSSTOOL_VERSION=crosstool-ng-1.17.0

	prepare_build
	prepare_prefix

	tar -xjf ${PACKAGES}/${CROSSTOOL_VERSION}.tar.bz2 -C ${BUILD}
	if [ $? -ne 0 ] ; then
		die "cannot unpack crosstool-ng"
	fi

	cd ${BUILD}/${CROSSTOOL_VERSION}
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

	cp ${BASE_PATH}/config/ctng ${BUILD}/${CROSSTOOL_VERSION}/.config
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
	prepare_build
	prepare_prefix

	# different preparations for different sources

	case $1 in
		submodule)
			if [ ! -r ${BASE_PATH}/src/qemu/configure ] ; then
				die "submodule qemu not present (update/pull sources)"
			fi

			cd ${BASE_PATH}/src/qemu
			;;

		tarball)
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
			;;

		*)
			die "no source of qemu specified, possible values: submodule, tarball"
			;;
	esac

	# now build

	./configure \
		--prefix=${PREFIX} \
		--target-list=arm-linux-user,arm-softmmu \
		--with-lua=${PREFIX}
	if [ $? -ne 0 ] ; then
		die "configuration of qemu failed"
	fi

	make
	if [ $? -ne 0 ] ; then
		die "build of qemu failed"
	fi
exit 0
	make install
	if [ $? -ne 0 ] ; then
		die "installation of qemu failed"
	fi
}

function build_kernel()
{
	export LINUX_VERSION=linux-2.6.38

	prepare_build
	prepare_prefix

	if [ -d ${BUILD}/${LINUX_VERSION} ] ; then
		rm -fr ${BUILD}/${LINUX_VERSION}
		if [ $? -ne 0 ] ; then
			die "cannot cleanup prior building linux"
		fi
	fi

	tar -xjf ${PACKAGES}/${LINUX_VERSION}.tar.bz2 -C ${BUILD}
	if [ $? -ne 0 ] ; then
		die "cannot unpack linux sources"
	fi

	cp ${BASE_PATH}/config/kernel-$1 ${BUILD}/${LINUX_VERSION}/.config
	if [ $? -ne 0 ] ; then
		die "cannot copy kernel configuration"
	fi

	cd ${BUILD}/${LINUX_VERSION}
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
	export BUSYBOX_VERSION=busybox-1.20.2

	prepare_build
	prepare_prefix

	if [ -d ${BUILD}/${BUSYBOX_VERSION} ] ; then
		rm -fr ${BUILD}/${BUSYBOX_VERSION}
		if [ $? -ne 0 ] ; then
			die "cannot cleanup prior building busybox"
		fi
	fi

	tar -xjf ${PACKAGES}/${BUSYBOX_VERSION}.tar.bz2 -C ${BUILD}
	if [ $? -ne 0 ] ; then
		die "cannot unpack busybox sources"
	fi

	cd ${BUILD}/${BUSYBOX_VERSION}
	make defconfig
	if [ $? -ne 0 ] ; then
		die "cannot configure busybox"
	fi

	make
	if [ $? -ne 0 ] ; then
		die "cannot build busybox"
	fi
}

function build_lua()
{
	export LUA_VERSION=lua-5.2.1

	prepare_build
	prepare_prefix

	if [ -d ${BUILD}/${LUA_VERSION} ] ; then
		rm -fr ${BUILD}/${LUA_VERSION}
		if [ $? -ne 0 ] ; then
			die "cannot cleanup prior building Lua"
		fi
	fi

	tar -xzf ${PACKAGES}/${LUA_VERSION}.tar.gz -C ${BUILD}
	if [ $? -ne 0 ] ; then
		die "cannot unpack Lua sources"
	fi

	sed -i 's/^INSTALL_TOP.*$/INSTALL_TOP=\$(PREFIX)/' ${BUILD}/${LUA_VERSION}/Makefile
	sed -i 's/^MYCFLAGS=.*$/MYCFLAGS=-fPIC/' ${BUILD}/${LUA_VERSION}/src/Makefile

	cd ${BUILD}/${LUA_VERSION}
	make linux
	if [ $? -ne 0 ] ; then
		die "cannot build Lua"
	fi

	make install
	if [ $? -ne 0 ] ; then
		die "cannot install Lua"
	fi
}

function build_index()
{
	rm -f tags cscope.files cscope.out

	if [ -d src ] ; then
		find src -name "*.c" -o -name "*.h" >> cscope.files
	fi

	ctags -L cscope.files
	cscope -b
}

function build_demo()
{
	export CC=${CROSS_COMPILER_PATH}/${CROSS_COMPILE}gcc
	export STRIP=${CROSS_COMPILER_PATH}/${CROSS_COMPILE}strip

	case $1 in
		clean)
			make -C src/rootfs/cpio clean
			make -C src/rootfs/ext2 clean
			make -C src/rootfs/ext2-2 clean
			make -C src/rootfs/busybox clean
			;;

		cpio)
			make -C src/rootfs/$1
			;;

		ext2)
			make -C src/rootfs/$1
			;;

		ext2-2)
			make -C src/rootfs/$1
			;;

		busybox)
			make -C src/rootfs/$1
			;;

		*)
			die "unknown target $1"
			;;
	esac
}

function build_host()
{
	export CC=gcc
	export STRIP=strip

	case $1 in
		all)
			make -C src/host
			;;

		clean)
			make -C src/host clean
			;;

		*)
			die "unknown target $1"
			;;
	esac
}

function cleanup()
{
	build_host clean
	build_demo clean

	rm -f tags cscope.files cscope.out

	if [ -d ${PREFIX}/x-tools ] ; then
		chmod -R u+w ${PREFIX}/x-tools
	fi

	if [ -d ${BASE_PATH}/src/qemu ] ; then
		if [ -r ${BASE_PATH}/src/qemu/Makefile ] ; then
			(cd ${BASE_PATH}/src/qemu ; make distclean)
		fi
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

function print_usage()
{
	echo ""
	echo "usage: $(basename $0) command"
	echo ""
	echo "Commands:"
	echo "  clean                : cleans up build and local deployment directories"
	echo "  index                : builds ctags/cscope indices"
	echo "  all                  : only for convenience, builds (in this order): toolchain, lua, qemu, busybox, kernel-*"
	echo "  toolchain            : extracts the toolchain (x86 based, name: x-tools.tar.bz2)"
	echo "  toolchain-64         : extracts the toolchain (64bit based, name: x-tools-64.tar.bz2)"
	echo "  toolchain-scratch    : builds toolchain from scratch"
	echo "  lua                  : builds Lua"
	echo "  qemu                 : builds standard qemu from submodule"
	echo "  qemu-tarball         : builds standard qemu from source tarball"
	echo "  busybox              : builds busyboard"
	echo "  kernel-versatile     : builds Linux kernel for the versatile board"
	echo "  kernel-versatile-bbv : builds Linux kernel for the versatile bbv custom board"
	echo "  demo [demo]          : builds a demo"
	echo "  host [target]        : builds all host tools"
	echo ""
}


if [ $# -eq 0 ] ; then
	print_usage $0
	exit 1
fi

case $1 in
	clean)
		cleanup
		;;

	all)
		unpack_toolchain
		build_lua
		build_qemu "submodule"
		build_busybox
		build_kernel "versatile"
		build_kernel "versatile-bbv"
		;;

	toolchain)
		unpack_toolchain
		;;

	toolchain-64)
		unpack_toolchain "-64"
		;;

	toolchain-scratch)
		build_toolchain
		;;

	lua)
		build_lua
		;;

	qemu)
		build_qemu "submodule"
		;;

	qemu-tarball)
		build_qemu "tarball"
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

	demo)
		if [ $# -ne 2 ] ; then
			print_usage $0
			die "invalid demo"
		fi
		build_demo $2
		;;

	host)
		if [ $# -ne 2 ] ; then
			print_usage $0
			die "invalid host"
		fi
		build_host $2
		;;

	index)
		build_index
		;;

	*)
		die "unknown target: $1"
		;;
esac
exit 0

