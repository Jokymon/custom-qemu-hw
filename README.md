INTRODUCTION
============

This project is a demonstration how to simulate custom hardware using qemu.
The custom hardware will have the ability to be used as test environment
for automatic (scripted) tests.


USAGE
=====

The general usage is:

```bash
qtb.sh command
```

To check your environment:
```bash
qtb.sh info
```

If you like to change a specific variable:
```bash
QEMU_PATH=$HOME/qemu/bin ./qtb.sh info
```


BUILDING FROM SOURCE
====================

Source packages are expected to be in the package directory. It is not implemented (yet) to
automatically download any pacakges, they are expected to be present.

TOOLCHAIN
---------

The toolchain can be unpacked using the command:

```bash
qtb.sh build toolchain
```

This unpacks the precompiled toolchain (compiled for Linux x86). If you like
to build the toolchain from scratch:

```bash
qtb.sh build toolchain-scratch
```


BUSYBOX
-------

This requires the presence of a cross-toolchain.

Build it with:

```bash
qtb.sh build busybox
```

Please note: this does build the busybox, it does not install it anywhere.


LINUX
-----

Currently there are two kernels supported to be built by the scripts:
- versatile
- versatile-bbv

Build the desired kernel:

```bash
qtb.sh build kernel-versatile
```

or

```bash
qtb.sh build kernel-versatile-bbv
```


BUILD AND START THE DEMOS
=========================

The toolbox can also be used to start the demos. After building all necessary packages
you may build and start the examples:

```bash
qtb.sh build demo ext2
```
Then start the example:
```bash
qtb.sh start ext2
```

Please note: for most demos to be built, sudo is used. Therefore you will need to
specify the password in order to build the demo. Starting it will not require
superuser privileges.


MISCELLANEOUS
=============

It is possible to use the scripts to download necessary packages without building
them. This feature is to prevent to add third party packages to the repository, but
not to have to copy all those packages offline. Using this feature you will only
use whats within the repository to use this project.

Obtain information about downloading pacakges using:
```bash
qtb.sh download info
```

The toolchain building script (uses crosstool-NG) also has a package download
mechanism.


LINKS
=====

- qemu: http://wiki.qemu.org/Main_Page
- GNU (gcc, binutils, etc.): https://gnu.org
- Linux: https://www.kernel.org
- busybox: http://www.busybox.net/
- crosstool-ng: http://crosstool-ng.org
- ARM/PrimeCell Documentation : http://infocenter.arm.com/help/index.jsp?topic=/com.arm.doc.ddi0194g/index.html


