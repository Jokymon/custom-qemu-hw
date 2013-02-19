#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/select.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <stdint.h>

static struct {
	uint8_t data;
} state;

typedef enum { CMD_INVALID = 0, CMD_WRITE = 1, CMD_READ = 2, CMD_RESULT = 3 } cmd_t;

typedef struct { /* keep data 8 bits to avoid byte order issue, and 8bits are suffient */
	uint8_t cmd;
	uint8_t data;
} msg_t;

static void data_send(int sock)
{
	msg_t msg;
	int rc;

	msg.cmd = CMD_RESULT;
	msg.data = state.data;

	rc = write(sock, &msg, sizeof(msg));
	if (rc < 0) {
		perror("write");
	}
}

static void print_bin8(uint8_t data)
{
	int i;

	for (i = 7; i >= 0; --i) {
		printf("%d", (data >> i) & 0x01);
	}
}

static void process_client(int sock)
{
	int rc;
	msg_t msg;
	fd_set rfds;

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
			case CMD_WRITE:
				printf("%s:%d: write: ", __FILE__, __LINE__);
				print_bin8(msg.data);
				printf("\n");
				state.data = msg.data;
				break;

			case CMD_READ:
				printf("%s:%d: read: ", __FILE__, __LINE__);
				print_bin8(state.data);
				printf("\n");
				data_send(sock);
				break;

			case CMD_RESULT:
				printf("%s:%d: invalid result received\n", __FILE__, __LINE__);
				break;
		}
	}
}

int main()
{
	int sock;
	struct sockaddr_in addr;
	int rc;
	struct sockaddr_in client_addr;
	socklen_t client_addr_len;
	int tmp;

	memset(&state, 0, sizeof(state));

	sock = socket(AF_INET, SOCK_STREAM , 0);
	if (sock < 0) {
		perror("socket");
		return EXIT_FAILURE;
	}

	tmp = 1;
	if (setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, &tmp, sizeof(tmp)) < 0) {
		perror("setsockopt");
		return EXIT_FAILURE;
	}

	addr.sin_family = AF_INET;
	addr.sin_port = htons(5678);
	addr.sin_addr.s_addr = INADDR_ANY;
	rc = bind(sock, (const struct sockaddr *)&addr, sizeof(addr));
	if (rc < 0) {
		perror("bind");
		return EXIT_FAILURE;
	}

	rc = listen(sock, 5);
	if (rc < 0) {
		perror("listen");
		return EXIT_FAILURE;
	}

	for (;;) {
		memset(&client_addr, 0, sizeof(client_addr));
		client_addr_len = sizeof(client_addr);
		rc = accept(sock, (struct sockaddr *)&client_addr, &client_addr_len);
		if (rc < 0) {
			perror("accept");
			return EXIT_FAILURE;
		}
		printf("%s:%d: connected\n", __FILE__, __LINE__);
		process_client(rc);
		printf("%s:%d: disconnected\n", __FILE__, __LINE__);
		close(rc);
	}

	return EXIT_SUCCESS;
}

