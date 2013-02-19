.PHONY: all
.PHONY: clean

all : gpio_listener gpio_comm

gpio_listener : gpio_listener.o
	$(CC) -o $@ $^

gpio_comm : gpio_comm.o
	$(CC) -o $@ $^

clean :
	rm -f *.o
	rm -f gpio_listener
	rm -f gpio_comm

%.o : %.c
	$(CC) -o $@ -c $< $(CFLAGS)

