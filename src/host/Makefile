.PHONY: all
.PHONY: clean

all : gpio_listener

gpio_listener : gpio_listener.o
	$(CC) -o $@ $^

clean :
	rm -f *.o
	rm -f gpio_listener

%.o : %.c
	$(CC) -o $@ -c $< $(CFLAGS)

