#include <stdio.h>

int main(int argc, char ** argv)
{
	(void)argc;

	while (1) {
		printf("Hello from '%s'\n", argv[0]);
		sleep(1);
	}
	return 0;
}

