.PHONY: all clean

all :
	$(CC) -o test test.c -static
	$(STRIP) test
	$(CC) -o periodic periodic.c -static
	$(STRIP) periodic
	dd if=/dev/zero of=ramdisk bs=1024 count=1024
	sudo losetup /dev/loop0 ramdisk
	sudo mkfs.ext2 /dev/loop0
	sudo losetup -d /dev/loop0
	mkdir -p mnt
	sudo mount -o loop ramdisk mnt
	sudo mkdir mnt/sbin
	sudo cp test mnt/sbin/init
	sudo cp periodic mnt/sbin/periodic
	sudo sync
	sudo umount mnt
	rm -fr mnt

clean :
	rm -f test periodic ramdisk*
	rm -fr mnt

