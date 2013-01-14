obj-m += simple_km.o

KERNEL=${BUILD}/linux-2.6.38

all:
	make -C $(KERNEL) M=$(CURDIR) modules

clean:
	make -C $(KERNEL) M=$(CURDIR) clean

