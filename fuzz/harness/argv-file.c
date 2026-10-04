/* argv-file.c -- the campaign's argv harness.
 *
 * Botlish's one external input channel is the process argument vector
 * (ARGV.md): a standalone AOT executable captures the real Linux argv of
 * every run as raw bytes, before any Botlish code runs. AFL feeds a target
 * through a file (@@), so this harness turns a file's bytes into the
 * target's argv and execs it:
 *
 *   argv-file BINARY INPUT-FILE
 *
 * The file's content IS the argv vector: byte sequences separated by NUL
 * become argv[1], argv[2], ... (a NUL is the only lossless separator --
 * the kernel forbids NUL inside an argument). A trailing NUL terminates
 * the vector without adding a final empty argument; a non-empty segment
 * before it is a real argument, so "a\0\0b" is ["a", "", "b"] and "a\0"
 * is ["a"]. An empty file is an empty vector: just BINARY itself.
 *
 * argv[0] is the BINARY path as given (the invocation name; ARGV.md
 * documents that element zero is the launcher's string, not a real path).
 *
 * The harness itself never touches the target's stdin or stdout, passes no
 * environment changes, and exits only when exec fails: 126 if the kernel
 * rejects the vector (E2BIG for an oversized argument -- MAX_ARG_STRLEN
 * is 128 KiB per argument), 125 for harness misuse. Those exits are
 * harness behavior, not target crashes.
 *
 * Built by fuzz/scripts/setup-host.sh:
 *   cc -O2 -o fuzz/harness/argv-file fuzz/harness/argv-file.c
 */
#define _GNU_SOURCE
#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>

/* Reads all of FD into a malloc'd buffer. */
static char *slurp(int fd, size_t *size_out) {
    struct stat st;
    if (fstat(fd, &st) < 0) return NULL;
    size_t size = (size_t)st.st_size;
    char *buffer = malloc(size + 1);
    if (!buffer) return NULL;
    size_t done = 0;
    while (done < size) {
        ssize_t n = read(fd, buffer + done, size - done);
        if (n < 0) {
            if (errno == EINTR) continue;
            free(buffer);
            return NULL;
        }
        if (n == 0) break;
        done += (size_t)n;
    }
    buffer[done] = '\0';
    *size_out = done;
    return buffer;
}

int main(int argc, char **argv) {
    if (argc != 3) {
        fprintf(stderr, "usage: argv-file BINARY INPUT-FILE\n");
        return 125;
    }
    int fd = open(argv[2], O_RDONLY);
    if (fd < 0) { perror("argv-file: open"); return 125; }
    size_t size = 0;
    char *bytes = slurp(fd, &size);
    close(fd);
    if (!bytes) { fprintf(stderr, "argv-file: read failed\n"); return 125; }

    /* Count NUL-separated segments, then build the vector. An empty file
     * adds no argument at all; a file ending in NUL does not add a final
     * empty argument (the trailing separator is a terminator). */
    int drop_last = size > 0 && bytes[size - 1] == '\0';
    size_t segments = 1;
    for (size_t i = 0; i < size; i++) {
        if (bytes[i] == '\0') segments++;
    }
    if (drop_last) segments--;

    char **vector = calloc(segments + 1, sizeof(char *)); /* +1: argv[0] */
    if (!vector) { fprintf(stderr, "argv-file: out of memory\n"); return 125; }
    vector[0] = argv[1];
    size_t v = 1;
    char *start = bytes;
    for (size_t i = 0; i < size; i++) {
        if (bytes[i] != '\0') continue;
        size_t length = (size_t)(&bytes[i] - start);
        char *argument = malloc(length + 1);
        if (!argument) { fprintf(stderr, "argv-file: out of memory\n"); return 125; }
        memcpy(argument, start, length);
        argument[length] = '\0';
        vector[v++] = argument;
        start = &bytes[i + 1];
    }
    if (!drop_last && size > 0) {
        size_t length = (size_t)(&bytes[size] - start);
        char *argument = malloc(length + 1);
        if (!argument) { fprintf(stderr, "argv-file: out of memory\n"); return 125; }
        memcpy(argument, start, length);
        argument[length] = '\0';
        vector[v++] = argument;
    }
    vector[v] = NULL;

    execv(argv[1], vector);
    fprintf(stderr, "argv-file: exec %s failed: %s\n", argv[1], strerror(errno));
    return errno == E2BIG ? 126 : 125;
}
