/* write-inject.c -- test infrastructure for tests/darwin-io.test on macOS: a
 * dyld interposer of libSystem's write(2) that makes chosen calls short,
 * stalled or failed, as `strace -e inject=write:...` does for
 * tests/portable-io.test on Linux (MACOS-AARCH64-MILESTONE-8.md).
 *
 * Built by the test as a dynamic library and loaded into one run of a
 * standalone executable with DYLD_INSERT_LIBRARIES; the `__DATA,__interpose`
 * section makes dyld bind every other image's references to write -- the
 * program's own C call of libSystem's write included -- to inject_write.
 * Nothing in Botlish knows it exists: the program calls the real libSystem
 * function, and this library stands where the kernel would have answered.
 *
 *   BCF_WRITE_FD    the descriptor whose writes the plan applies to
 *   BCF_WRITE_PLAN  the plan, one action per write(2) call on that
 *                   descriptor, separated by commas, the rest passed
 *                   through unchanged:
 *                     N    (N > 0) write at most N bytes (a short write when
 *                          the call asked for more), returning what the real
 *                          write returns
 *                     0    write nothing and return 0 (no progress)
 *                     -E   write nothing and fail: return -1 with errno E
 *   BCF_WRITE_LIMIT N (N > 0): every call on that descriptor after the
 *                   plan writes at most N bytes -- a short write whenever it
 *                   asks for more, for as long as the process runs
 *                   (bench/darwin-io.tcl's steady-state completion row)
 *   BCF_WRITE_LOG   a file every call on that descriptor is recorded in,
 *                   planned or passed through, one line "ASKED RESULT
 *                   ERRNO" each
 *
 * Calls on other descriptors, and every call after the plan (but for
 * BCF_WRITE_LIMIT's cap), are the real write's. The interposer's own calls of write reach the real one (dyld never
 * interposes an image's references to itself). */
#if defined(__APPLE__)
#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

static int bcf_initialized;
static int bcf_fd = -1;
static const char *bcf_plan;
static long bcf_limit;
static int bcf_log = -1;

static void bcf_init(void) {
    bcf_initialized = 1;
    const char *fd = getenv("BCF_WRITE_FD");
    if (fd != NULL) {
        bcf_fd = atoi(fd);
    }
    bcf_plan = getenv("BCF_WRITE_PLAN");
    const char *limit = getenv("BCF_WRITE_LIMIT");
    if (limit != NULL) {
        bcf_limit = atol(limit);
    }
    const char *log = getenv("BCF_WRITE_LOG");
    if (log != NULL) {
        bcf_log = open(log, O_WRONLY | O_CREAT | O_TRUNC | O_CLOEXEC, 0644);
    }
}

static ssize_t inject_write(int fd, const void *buf, size_t nbyte) {
    if (!bcf_initialized) {
        bcf_init();
    }
    if (fd != bcf_fd) {
        return write(fd, buf, nbyte);
    }
    long action = (long)nbyte;
    if (bcf_plan != NULL && *bcf_plan != '\0') {
        char *end;
        action = strtol(bcf_plan, &end, 10);
        bcf_plan = *end == ',' ? end + 1 : end;
    } else if (bcf_limit > 0 && (size_t)bcf_limit < nbyte) {
        action = bcf_limit;
    }
    ssize_t result;
    int error = 0;
    if (action < 0) {
        error = (int)-action;
        result = -1;
    } else if (action == 0) {
        result = 0;
    } else if ((size_t)action >= nbyte) {
        result = write(fd, buf, nbyte);
        if (result < 0) {
            error = errno;
        }
    } else {
        result = write(fd, buf, (size_t)action);
        if (result < 0) {
            error = errno;
        }
    }
    if (bcf_log >= 0) {
        char line[96];
        int n = snprintf(line, sizeof line, "%zu %zd %d\n", nbyte, result, error);
        write(bcf_log, line, (size_t)n);
    }
    if (result < 0) {
        errno = error;
    }
    return result;
}

__attribute__((used)) static const struct {
    const void *replacement;
    const void *replacee;
} bcf_interposers[] __attribute__((section("__DATA,__interpose"))) = {
    {(const void *)(unsigned long)&inject_write, (const void *)(unsigned long)&write},
};
#endif
