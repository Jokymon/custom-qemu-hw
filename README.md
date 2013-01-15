
USAGE
=====

The general usage is:

```bash
qtb.sh command
```


BUILDING FROM SOURCE
====================

TOOLCHAIN
---------

The toolchain can be unpacked using the

```bash
qtb.sh build toolchain
```


BUSYBOX
=======

This requires the presence of a cross-toolchain.

Build it with:

```bash
qtb.sh build busybox
```

Please note: this does build the busybox, it does not install it anywhere.



LINUX
=====

Currently there are two kernels supported to be built by the scripts:
- versatile
- qemu-mk

Build the desired kernel:

```bash
qtb.sh build kernel-versatile
```

or

```bash
qtb.sh build kernel-qemu-mk
```


LINKS
=====

ARM/PrimeCell documentation: http://infocenter.arm.com/help/index.jsp?topic=/com.arm.doc.ddi0194g/index.html

