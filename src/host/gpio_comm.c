#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/select.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <stdint.h>

typedef enum { CMD_INVALID = 0, CMD_WRITE = 1, CMD_READ = 2, CMD_RESULT = 3 } cmd_t;

typedef struct { /* keep data 8 bits to avoid byte order issue, and 8bits are suffient */
	uint8_t cmd;
	uint8_t data;
} msg_t;

static void print_bin8(uint8_t data)
{
	int i;

	for (i = 7; i >= 0; --i) {
		printf("%d", (data >> i) & 0x01);
	}
}

static void exec_listener(int sock)
{
	msg_t msg;
	fd_set rfds;
	int rc;

	for (;;) {
		FD_ZERO(&rfds);
		FD_SET(sock, &rfds);
		rc = select(sock + 1, &rfds, NULL, NULL, NULL);
		if (rc <= 0) return;
		rc = read(sock, &msg, sizeof(msg));
		if (rc < 0) {
			perror("read");
			return;
		}
		if (rc == 0) return;
		if (!FD_ISSET(sock, &rfds)) return;

		switch ((cmd_t)msg.cmd) {
			case CMD_INVALID:
				printf("%s:%d: invalid: ignored", __FILE__, __LINE__);
				break;

			case CMD_WRITE:
				printf("%s:%d: write: ", __FILE__, __LINE__);
				print_bin8(msg.data);
				printf("\n");
				break;

			case CMD_READ:
				printf("%s:%d: read: ignored", __FILE__, __LINE__);
				break;

			case CMD_RESULT:
				printf("%s:%d: result: ignored", __FILE__, __LINE__);
				break;
		}
	}
}

static exec_write(int sock, int val)
{
	msg_t msg;

	msg.cmd = CMD_WRITE;
	msg.data = (uint8_t)val;

	if (write(sock, &msg, sizeof(msg)) < 0) {
		perror("write");
	}
}

int main(int argc, char ** argv)
{
	int sock;
	struct sockaddr_in addr;
	int rc;

	sock = socket(AF_INET, SOCK_STREAM , 0);
	if (sock < 0) {
		perror("socket");
		return EXIT_FAILURE;
	}

	addr.sin_family = AF_INET;
	addr.sin_port = htons(5679);
	addr.sin_addr.s_addr = inet_addr("127.0.0.1");
	rc = connect(sock, (const struct sockaddr *)&addr, sizeof(addr));
	if (rc < 0) {
		perror("connect");
		return EXIT_FAILURE;
	}

	if (argc == 1) {
		exec_listener(sock);
	} else {
		exec_write(sock, atoi(argv[1]));
	}

	close(sock);
	return EXIT_SUCCESS;
}

