/* GPIO toggling - minimal implementation in C */

#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <stdint.h>

int main()
{
	int fd = -1;
	int rc = -1;
	int state = 0;

	fd = open("/sys/class/gpio/gpio0/value", O_RDWR);
	if (fd < 0) {
		perror("open");
		return EXIT_FAILURE;
	}

	for (;;) {
		switch (state) {
			case 0:
				rc = write(fd, "0", 1);
				state = 1;
				break;
			case 1:
				rc = write(fd, "1", 1);
				state = 0;
				break;
			default:
				break;
		}
		if (rc < 0) {
			perror("write");
			close(fd);
			return EXIT_FAILURE;
		}
		sleep(2);
	}

	close(fd);
	return EXIT_SUCCESS;
}

