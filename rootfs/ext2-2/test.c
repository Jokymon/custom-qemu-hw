#include <stdio.h>
#include <unistd.h>

int main()
{
	int pid;

	pid = fork();
	if (pid == 0) {
		execl("/sbin/periodic", "periodic", NULL);
		printf("ERROR: fork failed\n");
	}

	while (1) {
		printf("Hello World!\n");
		getchar();
	}
	return 0;
}

