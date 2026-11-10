/* msp.c -- the EXPERIMENTAL managed-subprocess adapter of the census
 * MANAGED-SUBPROCESS-AND-EVENT-LOOP-CENSUS-MILESTONE-1.md. Not shipped, not
 * a package: audit/managed-subprocess/slice/build.sh builds it into
 * slice/native/libmsp.a, which slice/msp.bot links.
 *
 * What it is for: to find out what a Linux process layer under
 * std::event_loop needs, with the least native code -- C functions of
 * scalars and borrowed bytes only (the C FFI's contract), no callback, no
 * thread, no signal handler, nothing that runs Botlish code. Readiness and
 * timers stay the event loop's: the module watches the descriptors this file
 * hands it (pipes, the pidfd) with event_loop_linux.
 *
 *   specs      a builder of what to start: the executable, the arguments
 *              (exact byte strings), the environment (inherited with
 *              overrides, or explicit), the working directory, each standard
 *              stream's policy (inherit, pipe, /dev/null, a file), the
 *              process-group policy                       msp_spec_*
 *   spawning   posix_spawn (glibc: clone with CLONE_VM|CLONE_VFORK, safe in a
 *              multithreaded process, exec's errno reported), then the
 *              pidfd of the still-unreaped child (pidfd_open: its PID cannot
 *              be reused before we reap it), so no later signal or wait can
 *              reach a reused PID. (glibc 2.39's pidfd_spawn would do both
 *              at once but leaks its pidfd when exec fails: repro/
 *              pidfd-spawn-leak.c; flag MSP_PIDFD_SPAWN.)
 *              Everything that can fail before exec is opened IN THE PARENT
 *              (the working directory as an O_PATH descriptor the child
 *              fchdirs to, redirection files, /dev/null, the pipes), so a
 *              failure says which stage failed; what is left for the child
 *              is exec itself, whose errno glibc reports (CLONE_VFORK).
 *              The child gets the default disposition of every signal and an
 *              empty signal mask (Botlish processes ignore SIGPIPE: the
 *              runtime's startup), and every descriptor above 2 closed
 *              (closefrom), so nothing of the supervisor leaks into it.
 *                                                          msp_spawn
 *   streams    the parent's pipe ends are O_NONBLOCK|O_CLOEXEC; the child's
 *              ends are blocking (a child's stdio expects that). read and
 *              write are one syscall each: -EAGAIN means "wait for
 *              readiness", 0 from read is end of file.   msp_read, _write
 *   exit       the pidfd is readable once the child has exited; msp_status
 *              PEEKS (waitid WNOWAIT) and caches the status, msp_reap reaps.
 *              Reaping is separate on purpose: until the leader is reaped
 *              its PID -- and so its process group's ID -- cannot be reused,
 *              so even kill(-pgid) before the reap cannot reach a stranger.
 *              (A pidfd group signal is safe after the reap too: it names
 *              the group by the leader's struct pid, repro/group-after-
 *              reap.c. This file refuses every signal after the reap
 *              anyway: conservative.)
 *   signals    pidfd_send_signal, to the process or (PIDFD_SIGNAL_PROCESS_
 *              GROUP, Linux 6.9) to its process group; refused after the
 *              reap (-ESRCH), never kill(pid).
 *   lifetime   a child is released only once reaped (-EBUSY otherwise) or
 *              detached; detaching closes the parent's stream ends and keeps
 *              the pidfd in a list msp_sweep reaps from, so a detached child
 *              never becomes a zombie of a supervisor that keeps running.
 *   threads    the table is shared and locked; a child belongs to the thread
 *              that spawned it (another thread's call is -EPERM): a VM's
 *              children are that VM's.
 *
 * Handles are GEN << 16 | INDEX: a stale handle (released, or its slot
 * reused) is -ESTALE, never another child.
 *
 * Negative controls (flags), for the census's reproducers only:
 * MSP_KEEP_SIGNALS spawns without resetting dispositions and the mask,
 * MSP_PIDFD_SPAWN with glibc's leaking pidfd_spawn,
 * MSP_KEEP_FDS without closefrom, MSP_EAGER_REAP makes msp_status reap at
 * once (so a later group signal has no reserved PGID behind it). */
#define _GNU_SOURCE
#include <dirent.h>
#include <errno.h>
#include <fcntl.h>
#include <pthread.h>
#include <signal.h>
#include <spawn.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/pidfd.h>
#include <sys/prctl.h>
#include <sys/resource.h>
#include <sys/stat.h>
#include <sys/syscall.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <time.h>
#include <unistd.h>

#ifndef PIDFD_SIGNAL_PROCESS_GROUP
#define PIDFD_SIGNAL_PROCESS_GROUP (1UL << 2)
#endif

extern char **environ;

#define MSP_ABI 1
#define MAX_SPECS 64
#define MAX_CHILDREN 1024

enum { POLICY_INHERIT = 0, POLICY_PIPE = 1, POLICY_NULL = 2, POLICY_FILE = 3 };
enum { MSP_KEEP_SIGNALS = 1, MSP_KEEP_FDS = 2, MSP_EAGER_REAP = 4, MSP_SETSID = 8, MSP_SEARCH_PATH = 16, MSP_PIDFD_SPAWN = 32 };
/* The stage a failed spawn stopped at (msp_last_stage). */
enum { STAGE_NONE = 0, STAGE_SPEC = 1, STAGE_CWD = 2, STAGE_FILE = 3, STAGE_PIPE = 4, STAGE_EXEC = 5, STAGE_TABLE = 6 };

typedef struct {
    int used;
    char *path;
    char **argv;
    int argc, argcap;
    char **env;            /* NAME=VALUE overrides, or NAME alone: unset */
    int envc, envcap;
    int env_explicit;      /* start from an empty environment */
    char *cwd;
    int policy[3];
    char *file[3];
    int append[3];
    int group;             /* 1: a process group of its own */
    int flags;
} msp_spec;

typedef struct {
    int used;
    unsigned gen;
    pthread_t owner;
    pid_t pid;
    int pidfd;
    int fd[3];             /* the parent's ends: 0 stdin (write), 1 stdout, 2 stderr (read) */
    int group;
    int flags;
    int exited;            /* status known (peeked) */
    int reaped;
    int detached;
    int kind;              /* 1 exited normally, 2 killed by a signal, 3 dumped core */
    int code;              /* exit status, or the signal */
    long long spawned_us, exited_us;
} msp_child;

static pthread_mutex_t LOCK = PTHREAD_MUTEX_INITIALIZER;
static msp_spec SPECS[MAX_SPECS];
static msp_child CHILDREN[MAX_CHILDREN];
static __thread int last_stage;

/* Counters (msp_stat). */
enum { ST_SPAWNED, ST_SPAWN_FAILED, ST_REAPED, ST_RELEASED, ST_DETACHED, ST_SWEPT, ST_SIGNALS, ST_READS, ST_READ_BYTES, ST_WRITES, ST_WRITE_BYTES, ST_EAGAIN, ST_LIVE, ST_FDS, ST_COUNT };
static long long STATS[ST_COUNT];

static long long now_us(void) {
    struct timespec t;
    clock_gettime(CLOCK_MONOTONIC, &t);
    return (long long)t.tv_sec * 1000000LL + t.tv_nsec / 1000;
}

long long msp_abi(void) { return MSP_ABI; }
long long msp_now(void) { return now_us(); }
long long msp_last_stage(void) { return last_stage; }

long long msp_stat(long long i) {
    if (i < 0 || i >= ST_COUNT) return -EINVAL;
    pthread_mutex_lock(&LOCK);
    long long v = STATS[i];
    pthread_mutex_unlock(&LOCK);
    return v;
}

/* ---------------------------------------------------------------------
 * Specs */

static msp_spec *spec_of(long long id) {
    if (id < 0 || id >= MAX_SPECS || !SPECS[id].used) return NULL;
    return &SPECS[id];
}

static char *copy_text(const void *p, unsigned long n) {
    if (memchr(p, 0, n)) return NULL; /* a C string cannot hold a NUL */
    char *s = malloc(n + 1);
    if (!s) return NULL;
    memcpy(s, p, n);
    s[n] = 0;
    return s;
}

long long msp_spec_new(void) {
    pthread_mutex_lock(&LOCK);
    for (int i = 0; i < MAX_SPECS; i++) {
        if (!SPECS[i].used) {
            memset(&SPECS[i], 0, sizeof SPECS[i]);
            SPECS[i].used = 1;
            SPECS[i].policy[0] = SPECS[i].policy[1] = SPECS[i].policy[2] = POLICY_PIPE;
            pthread_mutex_unlock(&LOCK);
            return i;
        }
    }
    pthread_mutex_unlock(&LOCK);
    return -ENOSPC;
}

long long msp_spec_free(long long id) {
    pthread_mutex_lock(&LOCK);
    msp_spec *s = spec_of(id);
    if (!s) {
        pthread_mutex_unlock(&LOCK);
        return -EINVAL;
    }
    free(s->path);
    for (int i = 0; i < s->argc; i++) free(s->argv[i]);
    free(s->argv);
    for (int i = 0; i < s->envc; i++) free(s->env[i]);
    free(s->env);
    free(s->cwd);
    for (int i = 0; i < 3; i++) free(s->file[i]);
    memset(s, 0, sizeof *s);
    pthread_mutex_unlock(&LOCK);
    return 0;
}

/* The executable: a path (no search unless MSP_SEARCH_PATH); also argv[0]. */
long long msp_spec_executable(long long id, const void *p, unsigned long n) {
    msp_spec *s = spec_of(id);
    if (!s) return -EINVAL;
    char *t = copy_text(p, n);
    if (!t || n == 0) {
        free(t);
        return -EINVAL;
    }
    free(s->path);
    s->path = t;
    return 0;
}

static int push(char ***v, int *c, int *cap, char *t) {
    if (*c + 2 > *cap) {
        int ncap = *cap ? *cap * 2 : 8;
        char **nv = realloc(*v, (size_t)ncap * sizeof *nv);
        if (!nv) return -ENOMEM;
        *v = nv;
        *cap = ncap;
    }
    (*v)[(*c)++] = t;
    (*v)[*c] = NULL;
    return 0;
}

/* One argument after argv[0], exactly these bytes (no NUL). */
long long msp_spec_arg(long long id, const void *p, unsigned long n) {
    msp_spec *s = spec_of(id);
    if (!s) return -EINVAL;
    char *t = copy_text(p, n);
    if (!t) return -EINVAL;
    int r = push(&s->argv, &s->argc, &s->argcap, t);
    if (r) free(t);
    return r;
}

/* An environment entry: NAME=VALUE sets NAME, NAME alone unsets it. */
long long msp_spec_env(long long id, const void *p, unsigned long n) {
    msp_spec *s = spec_of(id);
    if (!s) return -EINVAL;
    char *t = copy_text(p, n);
    if (!t || n == 0 || t[0] == '=') {
        free(t);
        return -EINVAL;
    }
    int r = push(&s->env, &s->envc, &s->envcap, t);
    if (r) free(t);
    return r;
}

/* Start from an empty environment instead of the supervisor's. */
long long msp_spec_env_clear(long long id) {
    msp_spec *s = spec_of(id);
    if (!s) return -EINVAL;
    s->env_explicit = 1;
    return 0;
}

long long msp_spec_cwd(long long id, const void *p, unsigned long n) {
    msp_spec *s = spec_of(id);
    if (!s) return -EINVAL;
    char *t = copy_text(p, n);
    if (!t || n == 0) {
        free(t);
        return -EINVAL;
    }
    free(s->cwd);
    s->cwd = t;
    return 0;
}

long long msp_spec_stdio(long long id, long long which, long long policy) {
    msp_spec *s = spec_of(id);
    if (!s || which < 0 || which > 2 || policy < 0 || policy > 2) return -EINVAL;
    s->policy[which] = (int)policy;
    return 0;
}

/* Redirect stream WHICH to the file PATH (stdin: read it; stdout/stderr:
 * create or truncate it, or append to it). */
long long msp_spec_stdio_file(long long id, long long which, const void *p, unsigned long n, long long append) {
    msp_spec *s = spec_of(id);
    if (!s || which < 0 || which > 2) return -EINVAL;
    char *t = copy_text(p, n);
    if (!t || n == 0) {
        free(t);
        return -EINVAL;
    }
    free(s->file[which]);
    s->file[which] = t;
    s->append[which] = append != 0;
    s->policy[which] = POLICY_FILE;
    return 0;
}

long long msp_spec_group(long long id, long long group) {
    msp_spec *s = spec_of(id);
    if (!s) return -EINVAL;
    s->group = group != 0;
    return 0;
}

long long msp_spec_flags(long long id, long long flags) {
    msp_spec *s = spec_of(id);
    if (!s) return -EINVAL;
    s->flags = (int)flags;
    return 0;
}

/* The child's environment: the supervisor's (or none) with the overrides
 * applied in order. Freed by the caller (the strings are borrowed). */
static char **environment(msp_spec *s) {
    int n = 0;
    if (!s->env_explicit)
        for (char **e = environ; *e; e++) n++;
    char **out = calloc((size_t)(n + s->envc + 1), sizeof *out);
    if (!out) return NULL;
    int c = 0;
    if (!s->env_explicit)
        for (char **e = environ; *e; e++) out[c++] = *e;
    for (int i = 0; i < s->envc; i++) {
        char *eq = strchr(s->env[i], '=');
        size_t len = eq ? (size_t)(eq - s->env[i]) : strlen(s->env[i]);
        int k = 0;
        for (int j = 0; j < c; j++) {
            if (strncmp(out[j], s->env[i], len) == 0 && out[j][len] == '=') continue;
            out[k++] = out[j];
        }
        c = k;
        if (eq) out[c++] = s->env[i];
    }
    out[c] = NULL;
    return out;
}

/* ---------------------------------------------------------------------
 * Children */

static msp_child *child_of(long long h) {
    long long idx = h & 0xffff;
    unsigned gen = (unsigned)(h >> 16);
    if (h <= 0 || idx >= MAX_CHILDREN) return NULL;
    msp_child *c = &CHILDREN[idx];
    if (!c->used || c->gen != gen) return NULL;
    return c;
}

/* The child H names, for the calling thread; NULL with *ERR set. Called
 * with LOCK held. */
static msp_child *mine(long long h, long long *err) {
    msp_child *c = child_of(h);
    if (!c) {
        *err = -ESTALE;
        return NULL;
    }
    if (!pthread_equal(c->owner, pthread_self())) {
        *err = -EPERM;
        return NULL;
    }
    return c;
}

static void close_fd(int *fd) {
    if (*fd >= 0) {
        close(*fd);
        *fd = -1;
        STATS[ST_FDS]--;
    }
}

/* Start what spec ID describes. The child's handle (> 0), or -errno with
 * msp_last_stage() saying where it failed. The spec stays usable. */
long long msp_spawn(long long id) {
    last_stage = STAGE_SPEC;
    msp_spec *s = spec_of(id);
    if (!s || !s->path) return -EINVAL;
    int cwdfd = -1, src[3] = { -1, -1, -1 }, mine_end[3] = { -1, -1, -1 };
    long long result = 0;
    char **argv = NULL, **envp = NULL;
    posix_spawn_file_actions_t fa;
    posix_spawnattr_t attr;
    int have_fa = 0, have_attr = 0;

    if (s->cwd) {
        last_stage = STAGE_CWD;
        cwdfd = open(s->cwd, O_PATH | O_DIRECTORY | O_CLOEXEC);
        if (cwdfd < 0) {
            result = -errno;
            goto out;
        }
    }
    for (int i = 0; i < 3; i++) {
        switch (s->policy[i]) {
        case POLICY_INHERIT:
            break;
        case POLICY_NULL:
            last_stage = STAGE_FILE;
            src[i] = open("/dev/null", (i == 0 ? O_RDONLY : O_WRONLY) | O_CLOEXEC);
            if (src[i] < 0) {
                result = -errno;
                goto out;
            }
            break;
        case POLICY_FILE:
            last_stage = STAGE_FILE;
            src[i] = i == 0 ? open(s->file[i], O_RDONLY | O_CLOEXEC)
                            : open(s->file[i], O_WRONLY | O_CREAT | O_CLOEXEC | (s->append[i] ? O_APPEND : O_TRUNC), 0644);
            if (src[i] < 0) {
                result = -errno;
                goto out;
            }
            break;
        case POLICY_PIPE: {
            last_stage = STAGE_PIPE;
            int p[2];
            if (pipe2(p, O_CLOEXEC) < 0) {
                result = -errno;
                goto out;
            }
            /* stdin: the child reads p[0], we write p[1]; else the reverse */
            src[i] = i == 0 ? p[0] : p[1];
            mine_end[i] = i == 0 ? p[1] : p[0];
            if (fcntl(mine_end[i], F_SETFL, O_NONBLOCK) < 0) {
                result = -errno;
                goto out;
            }
            break;
        }
        }
    }
    last_stage = STAGE_SPEC;
    argv = calloc((size_t)s->argc + 2, sizeof *argv);
    envp = environment(s);
    if (!argv || !envp) {
        result = -ENOMEM;
        goto out;
    }
    argv[0] = s->path;
    for (int i = 0; i < s->argc; i++) argv[i + 1] = s->argv[i];
    if (posix_spawn_file_actions_init(&fa) != 0 || posix_spawnattr_init(&attr) != 0) {
        result = -ENOMEM;
        goto out;
    }
    have_fa = have_attr = 1;
    for (int i = 0; i < 3; i++)
        if (src[i] >= 0) posix_spawn_file_actions_adddup2(&fa, src[i], i);
    if (cwdfd >= 0) posix_spawn_file_actions_addfchdir_np(&fa, cwdfd);
    if (!(s->flags & MSP_KEEP_FDS)) posix_spawn_file_actions_addclosefrom_np(&fa, 3);
    short flags = 0;
    if (!(s->flags & MSP_KEEP_SIGNALS)) {
        sigset_t all, none;
        sigfillset(&all);
        sigemptyset(&none);
        posix_spawnattr_setsigdefault(&attr, &all);
        posix_spawnattr_setsigmask(&attr, &none);
        flags |= POSIX_SPAWN_SETSIGDEF | POSIX_SPAWN_SETSIGMASK;
    }
    if (s->flags & MSP_SETSID) {
        flags |= POSIX_SPAWN_SETSID;
    } else if (s->group) {
        flags |= POSIX_SPAWN_SETPGROUP;
        posix_spawnattr_setpgroup(&attr, 0);
    }
    posix_spawnattr_setflags(&attr, flags);

    pthread_mutex_lock(&LOCK);
    int idx = -1;
    for (int i = 0; i < MAX_CHILDREN; i++)
        if (!CHILDREN[i].used) {
            idx = i;
            break;
        }
    if (idx < 0) {
        pthread_mutex_unlock(&LOCK);
        last_stage = STAGE_TABLE;
        result = -ENOSPC;
        goto out;
    }
    msp_child *c = &CHILDREN[idx];
    unsigned gen = c->gen + 1;
    if (gen == 0 || gen > 0x7fffff) gen = 1;
    memset(c, 0, sizeof *c);
    c->gen = gen;
    c->used = 1; /* reserved while we spawn, unlocked */
    pthread_mutex_unlock(&LOCK);

    last_stage = STAGE_EXEC;
    int pidfd = -1;
    int r;
    if (s->flags & MSP_PIDFD_SPAWN) {
        /* glibc 2.39 leaks the pidfd it made when exec fails (repro/
         * pidfd-spawn-leak.c): the census's negative control only. */
        r = (s->flags & MSP_SEARCH_PATH) ? pidfd_spawnp(&pidfd, s->path, &fa, &attr, argv, envp)
                                         : pidfd_spawn(&pidfd, s->path, &fa, &attr, argv, envp);
    } else {
        pid_t pid = 0;
        r = (s->flags & MSP_SEARCH_PATH) ? posix_spawnp(&pid, s->path, &fa, &attr, argv, envp)
                                         : posix_spawn(&pid, s->path, &fa, &attr, argv, envp);
        if (r == 0) {
            /* The child is ours and unreaped: its PID cannot name another
             * process until we reap it, so this pidfd is the child's. */
            pidfd = (int)syscall(SYS_pidfd_open, pid, 0);
            if (pidfd < 0) {
                r = errno;
                kill(pid, SIGKILL);
                while (waitpid(pid, NULL, 0) < 0 && errno == EINTR) {}
            }
        }
    }
    pthread_mutex_lock(&LOCK);
    if (r != 0) {
        c->used = 0;
        STATS[ST_SPAWN_FAILED]++;
        pthread_mutex_unlock(&LOCK);
        result = -r;
        goto out;
    }
    c->owner = pthread_self();
    c->pidfd = pidfd;
    c->pid = pidfd_getpid(pidfd);
    c->group = s->group || (s->flags & MSP_SETSID);
    c->flags = s->flags;
    c->spawned_us = now_us();
    for (int i = 0; i < 3; i++) {
        c->fd[i] = mine_end[i];
        if (mine_end[i] >= 0) STATS[ST_FDS]++;
        mine_end[i] = -1;
    }
    STATS[ST_FDS]++; /* the pidfd */
    STATS[ST_SPAWNED]++;
    STATS[ST_LIVE]++;
    result = ((long long)gen << 16) | idx;
    pthread_mutex_unlock(&LOCK);
    last_stage = STAGE_NONE;
out:
    if (have_fa) posix_spawn_file_actions_destroy(&fa);
    if (have_attr) posix_spawnattr_destroy(&attr);
    free(argv);
    free(envp);
    if (cwdfd >= 0) close(cwdfd);
    for (int i = 0; i < 3; i++) {
        if (src[i] >= 0) close(src[i]);
        if (mine_end[i] >= 0) close(mine_end[i]);
    }
    return result;
}

/* H's PID (for reports; never for signalling), or -errno. */
long long msp_pid(long long h) {
    long long err = 0;
    pthread_mutex_lock(&LOCK);
    msp_child *c = mine(h, &err);
    long long v = c ? c->pid : err;
    pthread_mutex_unlock(&LOCK);
    return v;
}

/* The descriptor the module watches: WHICH 0..2 a stream (-1 when it has
 * none or it was closed), 3 the pidfd. */
long long msp_fd(long long h, long long which) {
    long long err = 0;
    pthread_mutex_lock(&LOCK);
    msp_child *c = mine(h, &err);
    long long v = !c ? err : which == 3 ? c->pidfd : (which >= 0 && which < 3) ? c->fd[which] : -EINVAL;
    pthread_mutex_unlock(&LOCK);
    return v;
}

/* One read(2) of stream WHICH (1 stdout, 2 stderr) into BUF: n > 0, 0 at
 * end of file, -EAGAIN when nothing is there yet, -EBADF when closed. */
long long msp_read(long long h, long long which, void *buf, unsigned long cap) {
    long long err = 0;
    pthread_mutex_lock(&LOCK);
    msp_child *c = mine(h, &err);
    int fd = c && which >= 1 && which <= 2 ? c->fd[which] : -1;
    pthread_mutex_unlock(&LOCK);
    if (!c) return err;
    if (fd < 0) return -EBADF;
    ssize_t n;
    do n = read(fd, buf, cap); while (n < 0 && errno == EINTR);
    pthread_mutex_lock(&LOCK);
    STATS[ST_READS]++;
    if (n > 0) STATS[ST_READ_BYTES] += n;
    if (n < 0 && errno == EAGAIN) STATS[ST_EAGAIN]++;
    pthread_mutex_unlock(&LOCK);
    return n < 0 ? -errno : n;
}

/* One write(2) of DATA to the child's stdin: the bytes written (possibly
 * fewer), -EAGAIN when the pipe is full, -EPIPE once the child closed it. */
long long msp_write(long long h, const void *data, unsigned long n) {
    long long err = 0;
    pthread_mutex_lock(&LOCK);
    msp_child *c = mine(h, &err);
    int fd = c ? c->fd[0] : -1;
    pthread_mutex_unlock(&LOCK);
    if (!c) return err;
    if (fd < 0) return -EBADF;
    ssize_t w;
    do w = write(fd, data, n); while (w < 0 && errno == EINTR);
    pthread_mutex_lock(&LOCK);
    STATS[ST_WRITES]++;
    if (w > 0) STATS[ST_WRITE_BYTES] += w;
    if (w < 0 && errno == EAGAIN) STATS[ST_EAGAIN]++;
    pthread_mutex_unlock(&LOCK);
    return w < 0 ? -errno : w;
}

/* Close the parent's end of stream WHICH (0 closes stdin: the child reads
 * end of file). Unwatch it first: a closed number may name another file. */
long long msp_close_stream(long long h, long long which) {
    long long err = 0;
    pthread_mutex_lock(&LOCK);
    msp_child *c = mine(h, &err);
    if (c && which >= 0 && which <= 2) close_fd(&c->fd[which]);
    pthread_mutex_unlock(&LOCK);
    return c ? 0 : err;
}

static void record(msp_child *c, const siginfo_t *si) {
    c->exited = 1;
    c->exited_us = now_us();
    c->kind = si->si_code == CLD_EXITED ? 1 : si->si_code == CLD_DUMPED ? 3 : 2;
    c->code = si->si_status;
}

/* Whether H has exited: 0 running, 1 exited (msp_exit_kind/_code), -errno.
 * Peeks (WNOWAIT): the child stays unreaped until msp_reap. */
long long msp_status(long long h) {
    long long err = 0;
    pthread_mutex_lock(&LOCK);
    msp_child *c = mine(h, &err);
    if (!c) {
        pthread_mutex_unlock(&LOCK);
        return err;
    }
    if (!c->exited) {
        siginfo_t si;
        memset(&si, 0, sizeof si);
        int opts = WEXITED | WNOHANG | ((c->flags & MSP_EAGER_REAP) ? 0 : WNOWAIT);
        if (waitid(P_PIDFD, (id_t)c->pidfd, &si, opts) == 0 && si.si_pid != 0) {
            record(c, &si);
            if (c->flags & MSP_EAGER_REAP) {
                c->reaped = 1;
                STATS[ST_REAPED]++;
                STATS[ST_LIVE]--;
            }
        }
    }
    long long v = c->exited;
    pthread_mutex_unlock(&LOCK);
    return v;
}

long long msp_exit_kind(long long h) {
    long long err = 0;
    pthread_mutex_lock(&LOCK);
    msp_child *c = mine(h, &err);
    long long v = c ? (c->exited ? c->kind : 0) : err;
    pthread_mutex_unlock(&LOCK);
    return v;
}

long long msp_exit_code(long long h) {
    long long err = 0;
    pthread_mutex_lock(&LOCK);
    msp_child *c = mine(h, &err);
    long long v = c ? (c->exited ? c->code : 0) : err;
    pthread_mutex_unlock(&LOCK);
    return v;
}

/* Microseconds from spawn to the observed exit (or to now). */
long long msp_age(long long h) {
    long long err = 0;
    pthread_mutex_lock(&LOCK);
    msp_child *c = mine(h, &err);
    long long v = c ? (c->exited ? c->exited_us : now_us()) - c->spawned_us : err;
    pthread_mutex_unlock(&LOCK);
    return v;
}

/* Send SIG to H (GROUP: to its process group, when it has one of its own).
 * 0, or -errno: -ESRCH once reaped -- never a PID that may be reused. */
long long msp_signal(long long h, long long sig, long long group) {
    long long err = 0;
    pthread_mutex_lock(&LOCK);
    msp_child *c = mine(h, &err);
    if (!c) {
        pthread_mutex_unlock(&LOCK);
        return err;
    }
    if (c->reaped) {
        pthread_mutex_unlock(&LOCK);
        return -ESRCH;
    }
    unsigned flags = (group && c->group) ? PIDFD_SIGNAL_PROCESS_GROUP : 0;
    int r = pidfd_send_signal(c->pidfd, (int)sig, NULL, flags);
    if (r < 0 && errno == EINVAL && flags) {
        /* A kernel before 6.9: the leader is unreaped (checked above), so
         * its PID and the group's ID are still reserved. */
        r = kill(-c->pid, (int)sig);
    }
    long long v = r < 0 ? -errno : 0;
    if (r == 0) STATS[ST_SIGNALS]++;
    pthread_mutex_unlock(&LOCK);
    return v;
}

/* Reap H once it has exited: 0, -EAGAIN while it runs. */
long long msp_reap(long long h) {
    long long err = 0;
    pthread_mutex_lock(&LOCK);
    msp_child *c = mine(h, &err);
    if (!c) {
        pthread_mutex_unlock(&LOCK);
        return err;
    }
    if (c->reaped) {
        pthread_mutex_unlock(&LOCK);
        return 0;
    }
    siginfo_t si;
    memset(&si, 0, sizeof si);
    long long v = -EAGAIN;
    if (waitid(P_PIDFD, (id_t)c->pidfd, &si, WEXITED | WNOHANG) == 0 && si.si_pid != 0) {
        if (!c->exited) record(c, &si);
        c->reaped = 1;
        STATS[ST_REAPED]++;
        STATS[ST_LIVE]--;
        v = 0;
    }
    pthread_mutex_unlock(&LOCK);
    return v;
}

/* Kill H's group (or H) and reap it, blocking until it has exited: what a
 * scope's cleanup can do when it cannot wait on the loop. 0, or -errno. */
long long msp_kill_and_reap(long long h) {
    long long r = msp_signal(h, SIGKILL, 1);
    if (r < 0 && r != -ESRCH) return r;
    long long err = 0;
    pthread_mutex_lock(&LOCK);
    msp_child *c = mine(h, &err);
    if (!c) {
        pthread_mutex_unlock(&LOCK);
        return err;
    }
    int fd = c->pidfd;
    int reaped = c->reaped;
    pthread_mutex_unlock(&LOCK);
    if (reaped) return 0;
    siginfo_t si;
    memset(&si, 0, sizeof si);
    int w;
    do w = waitid(P_PIDFD, (id_t)fd, &si, WEXITED); while (w < 0 && errno == EINTR);
    pthread_mutex_lock(&LOCK);
    if (w == 0) {
        if (!c->exited) record(c, &si);
        c->reaped = 1;
        STATS[ST_REAPED]++;
        STATS[ST_LIVE]--;
    }
    pthread_mutex_unlock(&LOCK);
    return w < 0 ? -errno : 0;
}

/* Release H: its descriptors are closed and its handle stale. Only once
 * reaped (-EBUSY otherwise: kill and reap it, or detach it). */
long long msp_release(long long h) {
    long long err = 0;
    pthread_mutex_lock(&LOCK);
    msp_child *c = mine(h, &err);
    if (!c) {
        pthread_mutex_unlock(&LOCK);
        return err;
    }
    if (!c->reaped) {
        pthread_mutex_unlock(&LOCK);
        return -EBUSY;
    }
    for (int i = 0; i < 3; i++) close_fd(&c->fd[i]);
    close_fd(&c->pidfd);
    unsigned gen = c->gen;
    memset(c, 0, sizeof *c);
    c->gen = gen;
    STATS[ST_RELEASED]++;
    pthread_mutex_unlock(&LOCK);
    return 0;
}

/* Detach H: the parent's stream ends close (the child sees end of file on
 * stdin and EPIPE on its pipes), the handle goes stale, and the process
 * keeps running; msp_sweep reaps it once it exits, so it never stays a
 * zombie of this supervisor. 0, or -errno. */
long long msp_detach(long long h) {
    long long err = 0;
    pthread_mutex_lock(&LOCK);
    msp_child *c = mine(h, &err);
    if (!c) {
        pthread_mutex_unlock(&LOCK);
        return err;
    }
    for (int i = 0; i < 3; i++) close_fd(&c->fd[i]);
    c->detached = 1;
    c->gen++; /* the owner's handle is stale now; the slot stays used */
    if (c->gen == 0 || c->gen > 0x7fffff) c->gen = 1;
    STATS[ST_DETACHED]++;
    pthread_mutex_unlock(&LOCK);
    return 0;
}

/* Reap every detached child that has exited and free its slot; the number
 * of detached children still running. */
long long msp_sweep(void) {
    long long running = 0;
    pthread_mutex_lock(&LOCK);
    for (int i = 0; i < MAX_CHILDREN; i++) {
        msp_child *c = &CHILDREN[i];
        if (!c->used || !c->detached) continue;
        siginfo_t si;
        memset(&si, 0, sizeof si);
        if (!c->reaped && waitid(P_PIDFD, (id_t)c->pidfd, &si, WEXITED | WNOHANG) == 0 && si.si_pid != 0) {
            c->reaped = 1;
            STATS[ST_REAPED]++;
            STATS[ST_LIVE]--;
        }
        if (c->reaped) {
            close_fd(&c->pidfd);
            unsigned gen = c->gen;
            memset(c, 0, sizeof *c);
            c->gen = gen;
            STATS[ST_SWEPT]++;
        } else {
            running++;
        }
    }
    pthread_mutex_unlock(&LOCK);
    return running;
}

/* ---------------------------------------------------------------------
 * Descendants (the census's subreaper experiment). */

long long msp_subreaper(long long on) {
    return prctl(PR_SET_CHILD_SUBREAPER, on ? 1 : 0, 0, 0, 0) < 0 ? -errno : 0;
}

static int known_pid(pid_t pid) {
    for (int i = 0; i < MAX_CHILDREN; i++)
        if (CHILDREN[i].used && CHILDREN[i].pid == pid) return 1;
    return 0;
}

/* The process's children that are none of the table's (orphaned
 * descendants reparented to a subreaper): each that already exited is
 * reaped; SIG is sent (0: none) to each that runs, through a pidfd opened
 * while it is our unreaped child. How many were running, or -errno. */
long long msp_orphans(long long sig) {
    char path[64];
    snprintf(path, sizeof path, "/proc/%d/task", (int)getpid());
    DIR *d = opendir(path);
    if (!d) return -errno;
    long long found = 0;
    struct dirent *e;
    pthread_mutex_lock(&LOCK);
    while ((e = readdir(d))) {
        if (e->d_name[0] == '.') continue;
        char cpath[320];
        snprintf(cpath, sizeof cpath, "/proc/%d/task/%s/children", (int)getpid(), e->d_name);
        FILE *f = fopen(cpath, "r");
        if (!f) continue;
        int pid;
        while (fscanf(f, "%d", &pid) == 1) {
            if (known_pid(pid)) continue;
            int fd = (int)syscall(SYS_pidfd_open, pid, 0);
            if (fd < 0) continue;
            siginfo_t si;
            memset(&si, 0, sizeof si);
            /* An orphan that already exited is reaped, not counted. */
            if (waitid(P_PIDFD, (id_t)fd, &si, WEXITED | WNOHANG) == 0 && si.si_pid != 0) {
                close(fd);
                continue;
            }
            found++;
            if (sig) pidfd_send_signal(fd, (int)sig, NULL, 0);
            close(fd);
        }
        fclose(f);
    }
    pthread_mutex_unlock(&LOCK);
    closedir(d);
    return found;
}

/* H's scheduling state from /proc (its letter: 'R', 'S', 'T' stopped, 'Z'
 * zombie ...), for the census's terminal experiments; -errno. */
long long msp_proc_state(long long h) {
    long long pid = msp_pid(h);
    if (pid < 0) return pid;
    char path[64], buf[512];
    snprintf(path, sizeof path, "/proc/%lld/stat", pid);
    FILE *f = fopen(path, "r");
    if (!f) return -errno;
    size_t n = fread(buf, 1, sizeof buf - 1, f);
    fclose(f);
    buf[n] = 0;
    char *close_paren = strrchr(buf, ')');
    return close_paren && close_paren[1] == ' ' ? (unsigned char)close_paren[2] : -EINVAL;
}

/* H's start time (/proc/PID/stat field 22: clock ticks after boot), the
 * identity a durable job record keeps beside the PID; -errno. */
long long msp_start_time(long long h) {
    long long pid = msp_pid(h);
    if (pid < 0) return pid;
    char path[64], buf[1024];
    snprintf(path, sizeof path, "/proc/%lld/stat", pid);
    FILE *f = fopen(path, "r");
    if (!f) return -errno;
    size_t n = fread(buf, 1, sizeof buf - 1, f);
    fclose(f);
    buf[n] = 0;
    char *p = strrchr(buf, ')');
    if (!p) return -EINVAL;
    p += 2; /* the state letter: field 3 */
    for (int field = 3; field < 22 && p; field++) {
        p = strchr(p, ' ');
        if (p) p++;
    }
    return p ? strtoll(p, NULL, 10) : -EINVAL;
}

/* Descriptors open in this process (/proc/self/fd), for leak checks. */
long long msp_open_fds(void) {
    DIR *d = opendir("/proc/self/fd");
    if (!d) return -errno;
    long long n = 0;
    struct dirent *e;
    while ((e = readdir(d)))
        if (e->d_name[0] != '.') n++;
    closedir(d);
    return n - 1; /* the directory's own descriptor */
}

/* Bytes and lines: Botlish cannot index a Bytes (by design, ABI-BYTES.md),
 * so splitting a child's output into lines needs the position of a byte.
 * The offset of the first BYTE in DATA at or after FROM, or -1. */
long long msp_find_byte(const void *data, unsigned long n, long long from, long long byte) {
    if (from < 0 || (unsigned long)from >= n) return -1;
    const unsigned char *p = memchr((const unsigned char *)data + from, (int)byte, n - (unsigned long)from);
    return p ? (long long)(p - (const unsigned char *)data) : -1;
}
