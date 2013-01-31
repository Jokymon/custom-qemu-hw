.PHONY: all clean

all :
	$(CC) -o test test.c -static
	$(STRIP) test
	echo test | cpio --create --format=newc > rootfs

clean :
	rm -f test rootfs

