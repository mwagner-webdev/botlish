/* msp-child.c -- the deterministic helper child of the managed-subprocess
 * census (MANAGED-SUBPROCESS-AND-EVENT-LOOP-CENSUS-MILESTONE-1.md). Not
 * shipped; built by audit/managed-subprocess/slice/build.sh.
 *
 *   msp-child OP OP ...
 *
 * Every argument is one operation, run in order. Text operands take the
 * escapes \n \t \\ \xHH. Operations:
 *
 *   out:TEXT        write TEXT to stdout (one write)
 *   err:TEXT        write TEXT to stderr (one write)
 *   outn:N:B        write N bytes of value B (decimal) to stdout, 64 KiB per
 *                   write; reports nothing (a blocked write blocks)
 *   errn:N:B        the same on stderr
 *   bin             write the binary probe to stdout: 0x00..0xff, then an
 *                   invalid UTF-8 pair (ff fe), then U+20AC's first byte,
 *                   a 300 ms pause, its other two bytes, then "\n"
 *   sleep:MS        sleep MS milliseconds (restarted after a handled signal)
 *   cat             copy stdin to stdout until EOF, then "cat-eof N\n" on
 *                   stderr (N: bytes copied)
 *   readn:N         read exactly N bytes of stdin (or to EOF), then
 *                   "readn GOT\n" on stdout
 *   lines:N         read N lines of stdin; echo each as "got: LINE\n"
 *   close:in|out|err close that descriptor
 *   exit:N          exit with status N
 *   raise:SIG       raise signal SIG (a number) on itself
 *   ignore:SIG      ignore SIG
 *   trap:SIG:MS     on SIG, write "trapped SIG\n" to stderr, sleep MS ms,
 *                   then exit 128+SIG (a graceful shutdown that takes time)
 *   child:OPS       fork and exec this program with OPS (comma-separated
 *                   operations) in the child; writes "desc PID\n" to stdout.
 *                   The descendant inherits every descriptor.
 *   setsid          setsid() (leave the process group and session)
 *   setpgid         setpgid(0, 0) (a process group of its own)
 *   ids             "ids PID PPID PGID SID\n" on stdout
 *   env:NAME        "env NAME=VALUE\n" (or "env NAME unset\n") on stdout
 *   cwd             "cwd PATH\n" on stdout
 *   args            "args N\n" then "arg I HEX\n" for every argument, then
 *                   exit 0: the arguments after it are data, not operations
 *   sig             "sigpipe ign|dfl mask HEX\n" on stdout: the inherited
 *                   SIGPIPE disposition and blocked-signal mask
 *   fds             "fds LIST\n": the open descriptors (from /proc/self/fd)
 *   tty             "tty 0|1 0|1 0|1\n": isatty of 0, 1, 2
 *   flood           write "flood\n" lines to stdout until a write fails
 *   chunks:N:MS     N stdout writes of "chunk I\n", MS ms apart
 *   pidfile:PATH    write the pid to PATH
 *   stamp           "stamp US\n" on stdout: CLOCK_MONOTONIC in microseconds
 *                   (the census's exit-latency measurement: stamp, exit)
 *   stty-raw        put the terminal on stdin into raw mode and leave it so
 *                   (a child that corrupts its supervisor's terminal)
 *
 * Exits 0 after the last operation unless an operation ends it. Every
 * failure of an operation is reported on stderr and exits 99. */
#define _GNU_SOURCE
#include <dirent.h>
#include <errno.h>
#include <stdarg.h>
#include <fcntl.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <termios.h>
#include <time.h>
#include <unistd.h>

static char *self_path;

static void die(const char *what) {
    char buf[256];
    int n = snprintf(buf, sizeof buf, "msp-child: %s: %s\n", what, strerror(errno));
    if (n > 0) (void)!write(2, buf, (size_t)n);
    _exit(99);
}

static void write_all(int fd, const char *p, size_t n) {
    while (n > 0) {
        ssize_t w = write(fd, p, n);
        if (w < 0) {
            if (errno == EINTR) continue;
            die("write");
        }
        p += w;
        n -= (size_t)w;
    }
}

static void say(int fd, const char *fmt, ...) __attribute__((format(printf, 2, 3)));
static void say(int fd, const char *fmt, ...) {
    char buf[4096];
    va_list ap;
    va_start(ap, fmt);
    int n = vsnprintf(buf, sizeof buf, fmt, ap);
    va_end(ap);
    if (n < 0) die("format");
    if ((size_t)n > sizeof buf - 1) n = sizeof buf - 1;
    write_all(fd, buf, (size_t)n);
}

static size_t unescape(const char *s, char *out) {
    size_t n = 0;
    while (*s) {
        if (s[0] == '\\' && s[1]) {
            switch (s[1]) {
            case 'n': out[n++] = '\n'; s += 2; continue;
            case 't': out[n++] = '\t'; s += 2; continue;
            case '\\': out[n++] = '\\'; s += 2; continue;
            case 'x':
                if (s[2] && s[3]) {
                    char hex[3] = { s[2], s[3], 0 };
                    out[n++] = (char)strtol(hex, NULL, 16);
                    s += 4;
                    continue;
                }
                break;
            default: break;
            }
        }
        out[n++] = *s++;
    }
    return n;
}

static void sleep_ms(long ms) {
    struct timespec t = { ms / 1000, (ms % 1000) * 1000000L };
    while (nanosleep(&t, &t) < 0 && errno == EINTR) {}
}

static long trap_ms;
static void on_trap(int sig) {
    char buf[32];
    int n = snprintf(buf, sizeof buf, "trapped %d\n", sig);
    (void)!write(2, buf, (size_t)n);
    struct timespec t = { trap_ms / 1000, (trap_ms % 1000) * 1000000L };
    while (nanosleep(&t, &t) < 0 && errno == EINTR) {}
    _exit(128 + sig);
}

static void flood(char byte, long count, int fd) {
    static char block[65536];
    memset(block, byte, sizeof block);
    while (count > 0) {
        size_t n = count > (long)sizeof block ? sizeof block : (size_t)count;
        write_all(fd, block, n);
        count -= (long)n;
    }
}

static void op(char *arg);

/* child:OPS -- fork, exec this program with OPS split at commas. */
static void descendant(const char *ops) {
    char *copy = strdup(ops);
    if (!copy) die("strdup");
    char *argv[64];
    int argc = 0;
    argv[argc++] = self_path;
    for (char *tok = strtok(copy, ","); tok && argc < 63; tok = strtok(NULL, ",")) argv[argc++] = tok;
    argv[argc] = NULL;
    pid_t pid = fork();
    if (pid < 0) die("fork");
    if (pid == 0) {
        execv(self_path, argv);
        _exit(127);
    }
    say(1, "desc %d\n", (int)pid);
    free(copy);
}

static void op(char *arg) {
    static char text[65536];
    char *colon = strchr(arg, ':');
    char *rest = colon ? colon + 1 : "";
    size_t name_len = colon ? (size_t)(colon - arg) : strlen(arg);
#define IS(s) (name_len == strlen(s) && strncmp(arg, s, name_len) == 0)
    if (IS("out") || IS("err")) {
        size_t n = unescape(rest, text);
        write_all(IS("out") ? 1 : 2, text, n);
    } else if (IS("outn") || IS("errn")) {
        long count = strtol(rest, &rest, 10);
        long byte = *rest == ':' ? strtol(rest + 1, NULL, 10) : 'x';
        flood((char)byte, count, IS("outn") ? 1 : 2);
    } else if (IS("bin")) {
        unsigned char all[256];
        for (int i = 0; i < 256; i++) all[i] = (unsigned char)i;
        write_all(1, (char *)all, sizeof all);
        write_all(1, "\xff\xfe", 2);
        write_all(1, "\xe2", 1);
        sleep_ms(300);
        write_all(1, "\x82\xac\n", 3);
    } else if (IS("sleep")) {
        long ms = strtol(rest, NULL, 10);
        struct timespec t = { ms / 1000, (ms % 1000) * 1000000L };
        while (nanosleep(&t, &t) < 0 && errno == EINTR) {}
    } else if (IS("cat")) {
        char buf[65536];
        long total = 0;
        for (;;) {
            ssize_t r = read(0, buf, sizeof buf);
            if (r < 0) {
                if (errno == EINTR) continue;
                die("read");
            }
            if (r == 0) break;
            write_all(1, buf, (size_t)r);
            total += r;
        }
        say(2, "cat-eof %ld\n", total);
    } else if (IS("readn")) {
        long want = strtol(rest, NULL, 10), got = 0;
        char buf[65536];
        while (got < want) {
            size_t ask = (size_t)(want - got) > sizeof buf ? sizeof buf : (size_t)(want - got);
            ssize_t r = read(0, buf, ask);
            if (r < 0) {
                if (errno == EINTR) continue;
                die("read");
            }
            if (r == 0) break;
            got += r;
        }
        say(1, "readn %ld\n", got);
    } else if (IS("lines")) {
        long want = strtol(rest, NULL, 10);
        FILE *in = fdopen(dup(0), "r");
        if (!in) die("fdopen");
        char line[4096];
        for (long i = 0; i < want && fgets(line, sizeof line, in); i++) say(1, "got: %s", line);
        fclose(in);
    } else if (IS("close")) {
        int fd = strcmp(rest, "in") == 0 ? 0 : strcmp(rest, "out") == 0 ? 1 : 2;
        if (close(fd) < 0) die("close");
    } else if (IS("exit")) {
        _exit((int)strtol(rest, NULL, 10));
    } else if (IS("raise")) {
        int sig = (int)strtol(rest, NULL, 10);
        signal(sig, SIG_DFL);
        raise(sig);
    } else if (IS("ignore")) {
        signal((int)strtol(rest, NULL, 10), SIG_IGN);
    } else if (IS("trap")) {
        int sig = (int)strtol(rest, &rest, 10);
        trap_ms = *rest == ':' ? strtol(rest + 1, NULL, 10) : 0;
        struct sigaction sa;
        memset(&sa, 0, sizeof sa);
        sa.sa_handler = on_trap;
        sigaction(sig, &sa, NULL);
    } else if (IS("child")) {
        descendant(rest);
    } else if (IS("setsid")) {
        if (setsid() < 0) die("setsid");
    } else if (IS("setpgid")) {
        if (setpgid(0, 0) < 0) die("setpgid");
    } else if (IS("ids")) {
        say(1, "ids %d %d %d %d\n", (int)getpid(), (int)getppid(), (int)getpgid(0), (int)getsid(0));
    } else if (IS("env")) {
        const char *v = getenv(rest);
        if (v) say(1, "env %s=%s\n", rest, v);
        else say(1, "env %s unset\n", rest);
    } else if (IS("cwd")) {
        char buf[4096];
        if (!getcwd(buf, sizeof buf)) die("getcwd");
        say(1, "cwd %s\n", buf);
    } else if (IS("args")) {
        /* handled in main: needs argv */
    } else if (IS("sig")) {
        struct sigaction sa;
        sigaction(SIGPIPE, NULL, &sa);
        sigset_t mask;
        sigprocmask(SIG_BLOCK, NULL, &mask);
        unsigned long bits = 0;
        for (int s = 1; s < 64; s++) if (sigismember(&mask, s) == 1) bits |= 1UL << (s - 1);
        say(1, "sigpipe %s mask %lx\n", sa.sa_handler == SIG_IGN ? "ign" : "dfl", bits);
    } else if (IS("fds")) {
        DIR *d = opendir("/proc/self/fd");
        if (!d) die("opendir");
        int fds[1024], n = 0, dfd = dirfd(d);
        struct dirent *e;
        while ((e = readdir(d)) && n < 1024) {
            if (e->d_name[0] == '.') continue;
            int fd = atoi(e->d_name);
            if (fd != dfd) fds[n++] = fd;
        }
        closedir(d);
        for (int i = 1; i < n; i++)
            for (int j = i; j > 0 && fds[j - 1] > fds[j]; j--) {
                int t = fds[j]; fds[j] = fds[j - 1]; fds[j - 1] = t;
            }
        char buf[4096];
        size_t len = 0;
        len += (size_t)snprintf(buf + len, sizeof buf - len, "fds");
        for (int i = 0; i < n && len < sizeof buf - 16; i++) len += (size_t)snprintf(buf + len, sizeof buf - len, " %d", fds[i]);
        len += (size_t)snprintf(buf + len, sizeof buf - len, "\n");
        write_all(1, buf, len);
    } else if (IS("tty")) {
        say(1, "tty %d %d %d\n", isatty(0), isatty(1), isatty(2));
    } else if (IS("flood")) {
        static const char line[] = "flood\n";
        for (;;) {
            ssize_t w = write(1, line, sizeof line - 1);
            if (w < 0 && errno != EINTR) {
                say(2, "flood stopped: %s\n", strerror(errno));
                _exit(3);
            }
        }
    } else if (IS("chunks")) {
        long n = strtol(rest, &rest, 10);
        long ms = *rest == ':' ? strtol(rest + 1, NULL, 10) : 0;
        for (long i = 0; i < n; i++) {
            say(1, "chunk %ld\n", i);
            if (ms) sleep_ms(ms);
        }
    } else if (IS("stamp")) {
        struct timespec t;
        clock_gettime(CLOCK_MONOTONIC, &t);
        say(1, "stamp %lld\n", (long long)t.tv_sec * 1000000LL + t.tv_nsec / 1000);
    } else if (IS("stty-raw")) {
        struct termios tio;
        if (tcgetattr(0, &tio) < 0) die("tcgetattr");
        cfmakeraw(&tio);
        if (tcsetattr(0, TCSANOW, &tio) < 0) die("tcsetattr");
    } else if (IS("pidfile")) {
        FILE *f = fopen(rest, "w");
        if (!f) die("pidfile");
        fprintf(f, "%d\n", (int)getpid());
        fclose(f);
    } else {
        errno = EINVAL;
        die(arg);
    }
#undef IS
}

int main(int argc, char **argv) {
    self_path = realpath("/proc/self/exe", NULL);
    if (!self_path) die("realpath");
    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "args") == 0) {
            say(1, "args %d\n", argc);
            for (int a = 0; a < argc; a++) {
                char hex[8192];
                size_t len = 0, n = strlen(argv[a]);
                for (size_t k = 0; k < n && len < sizeof hex - 3; k++) len += (size_t)snprintf(hex + len, sizeof hex - len, "%02x", (unsigned char)argv[a][k]);
                hex[len] = 0;
                say(1, "arg %d %s\n", a, len ? hex : "-");
            }
            return 0;
        }
        op(argv[i]);
    }
    return 0;
}
