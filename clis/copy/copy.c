#include <unistd.h>
#include <sys/wait.h>
#include <stdlib.h>
#include <stdio.h>
#include <errno.h>

#define BUF_SIZE 8192

int main(void) {
    int pipefd[2];
    if (pipe(pipefd) == -1) {
        perror("pipe");
        return 1;
    }

    pid_t pid = fork();
    if (pid == -1) {
        perror("fork");
        return 1;
    }

    if (pid == 0) {
        // Child: stdin <- pipe, exec xclip
        close(pipefd[1]);
        dup2(pipefd[0], STDIN_FILENO);
        close(pipefd[0]);

        execlp("xclip", "xclip", "-selection", "clipboard", NULL);
        perror("execlp");
        _exit(1);
    }

    // Parent: read stdin -> pipe
    close(pipefd[0]);

    char buf[BUF_SIZE];
    ssize_t n;

    while ((n = read(STDIN_FILENO, buf, sizeof(buf))) > 0) {
        if (write(pipefd[1], buf, n) != n) {
            perror("write");
            break;
        }
    }

    close(pipefd[1]);
    waitpid(pid, NULL, 0);

    return 0;
}
