/* GPIO listen - continuously reads (blocking) on a GPIO */

#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <stdint.h>
#include <string.h>
#include <sys/poll.h>

static void hex_dump(const char * s, unsigned int len)
{
	for (; len > 0; --len, ++s) {
		printf(" %02x", *s);
	}
}

int main(int argc, char ** argv)
{
	int fd = -1;
	int rc = -1;
	char state[32];
	char device[128];
	struct pollfd fdset[1];

	static const char * DEVICE_FMT = "/sys/class/gpio/gpio%s/value";

	if (argc == 2) {
		snprintf(device, sizeof(device), DEVICE_FMT, argv[1]);
	} else {
		snprintf(device, sizeof(device), DEVICE_FMT, "0");
	}

	fd = open(device, O_RDONLY | O_NONBLOCK);
	if (fd < 0) {
		perror("open");
		return EXIT_FAILURE;
	}

	for (;;) {
		memset(fdset, 0, sizeof(fdset));
		memset(&state, 0, sizeof(state));

		fdset[0].fd = fd;
		fdset[0].events = POLLPRI;

		rc = poll(fdset, 1, 2 * 1000);
		if (rc < 0) {
			perror("poll");
			close(fd);
			return EXIT_FAILURE;
		}

		if (fdset[0].revents & POLLPRI) {
			rc = read(fdset[0].fd, state, sizeof(state));
			if (rc < 0) {
				perror("read");
				close(fd);
				return EXIT_FAILURE;
			}
			lseek(fdset[0].fd, 0, SEEK_SET);
			printf("PRI: rc=%3d  state:", rc);
			hex_dump(state, rc);
			printf("\n");
			continue;
		}

		if (fdset[0].revents & POLLIN) {
			rc = read(fdset[0].fd, state, sizeof(state));
			if (rc < 0) {
				perror("read");
				close(fd);
				return EXIT_FAILURE;
			}
			lseek(fdset[0].fd, 0, SEEK_SET);
			printf("IN : rc=%3d  state:", rc);
			hex_dump(state, rc);
			printf("\n");
			continue;
		}
	}

	close(fd);
	return EXIT_SUCCESS;
}

