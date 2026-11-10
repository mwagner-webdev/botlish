/* process_linux.c -- the native adapter of the package process_linux
 * (PROCESS-LINUX-PACKAGE-MILESTONE-1.md; the census it grew from is
 * MANAGED-SUBPROCESS-AND-EVENT-LOOP-CENSUS-MILESTONE-1.md, whose
 * experimental adapter, audit/managed-subprocess/native/msp.c, is its
 * starting point). process_linux.bot links it as native/libprocess_linux.a,
 * built on the package author's side (tools/package-repository.tcl).
 *
 * C functions of scalars and borrowed bytes only (the C FFI's contract): no
 * callback, no thread, no signal handler, nothing that runs Botlish code.
 * Readiness and timers are the event loop's: the module watches the
 * descriptors this file hands it (pipes, the pidfd) with event_loop_linux.
 *
 *   specs      what to start, built one item at a time: the executable, the
 *              arguments (exact byte strings), the environment (inherited
 *              with settings and removals, or explicit), the working
 *              directory, each standard stream's policy (inherit, pipe,
 *              /dev/null, a file), the process-group policy. A spec belongs
 *              to the thread that made it.                   pl_spec_*
 *   spawning   posix_spawn (glibc: clone with CLONE_VM|CLONE_VFORK, safe in
 *              a multithreaded process, exec's errno reported), then the
 *              pidfd of the still-unreaped child (pidfd_open: its PID cannot
 *              be reused before we reap it). glibc 2.39's pidfd_spawn would
 *              do both at once but leaks its pidfd when exec fails
 *              (audit/managed-subprocess/repro/pidfd-spawn-leak.c): never
 *              used here (the testing build keeps it as a negative control).
 *              Everything that can fail before exec is opened IN THE PARENT
 *              (the working directory as an O_PATH descriptor the child
 *              fchdirs to, redirection files, /dev/null, the pipes), so a
 *              failure says which stage failed; what is left for the child
 *              is exec itself, whose errno glibc reports. The child gets the
 *              default disposition of every signal and an empty signal mask
 *              (a Botlish process ignores SIGPIPE: its runtime's startup;
 *              ignored dispositions survive exec), and every descriptor
 *              above 2 closed (closefrom).                     pl_spawn
 *   streams    the parent's pipe ends are O_NONBLOCK|O_CLOEXEC; the child's
 *              ends are blocking (a child's stdio expects that). read and
 *              write are one syscall each: -EAGAIN means "wait for
 *              readiness", 0 from read is end of file.  pl_read, pl_write
 *   exit       the pidfd is readable once the child has exited; pl_status
 *              PEEKS (waitid WNOWAIT) and caches the status, pl_reap reaps.
 *              Reaping is separate on purpose: until the leader is reaped
 *              its PID -- and so its process group's ID -- cannot be
 *              reused, so even the pre-6.9 fallback kill(-pgid) cannot
 *              reach a stranger.
 *   signals    pidfd_send_signal, to the process or (PIDFD_SIGNAL_PROCESS_
 *              GROUP, Linux 6.9) to its process group; refused after the
 *              reap (-ESRCH), never kill(pid) of a number that may be
 *              reused.
 *   lifetime   a child is released only once reaped (-EBUSY otherwise) or
 *              detached; a detached child's parent ends are closed and its
 *              pidfd kept until it is reaped (by the module's task, by
 *              pl_sweep, or by the next spawn once its thread has ended), so
 *              it never stays a zombie of a supervisor that keeps running.
 *   threads    the table is shared and locked; a child belongs to the
 *              thread that spawned it (another thread's call is -EPERM): a
 *              VM's children are that VM's. A thread is named by a token of
 *              its own (never its pthread_t, which a later thread may
 *              reuse). When a thread ends, a key's destructor kills
 *              (SIGKILL to the group) and reaps every child it still
 *              supervises: no child outlives its VM unless detached. At
 *              process exit every supervised child's group is sent SIGKILL
 *              (atexit), the same rule's backstop.
 *
 * Handles are GEN << 16 | INDEX: a stale handle (released, detached, or its
 * slot reused) is -ESTALE, never another child.
 *
 * Kernel and C library: pidfd_open and pidfd readiness (Linux 5.3),
 * waitid(P_PIDFD) (5.4), group signals through a pidfd (6.9; before it,
 * kill(-pgid) while the leader is unreaped); glibc 2.34
 * (posix_spawn_file_actions_addclosefrom_np). pl_probe says whether this
 * process can supervise children at all: a kernel without pidfds, or a
 * process whose SIGCHLD is ignored (its children reaped behind our back),
 * is refused rather than handled by PID numbers.
 *
 * PL_TESTING (the testing build only, tools/process-linux.tcl) adds the
 * pl_t_* functions: fault bits (negative controls) and probes. The released
 * archive has none of them, and reads no environment variable. */
#define _GNU_SOURCE
#include <dirent.h>
#include <errno.h>
#include <fcntl.h>
#include <pthread.h>
#include <signal.h>
#include <spawn.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/syscall.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <time.h>
#include <unistd.h>

#ifndef P_PIDFD
#define P_PIDFD 3
#endif
#ifndef PIDFD_SIGNAL_PROCESS_GROUP
#define PIDFD_SIGNAL_PROCESS_GROUP (1U << 2)
#endif
#ifndef SYS_pidfd_open
#define SYS_pidfd_open 434
#endif
#ifndef SYS_pidfd_send_signal
#define SYS_pidfd_send_signal 424
#endif

extern char **environ;

/* The ABI process_linux.bot calls this file through: an archive of another
 * is refused (the module's create()). */
#define PL_ABI 1
#define MAX_SPECS 64
#define MAX_CHILDREN 1024

enum { POLICY_INHERIT = 0, POLICY_PIPE = 1, POLICY_NULL = 2, POLICY_FILE = 3 };
/* The stage a failed spawn stopped at (pl_last_stage). */
enum { STAGE_NONE = 0, STAGE_SPEC = 1, STAGE_CWD = 2, STAGE_FILE = 3, STAGE_PIPE = 4, STAGE_EXEC = 5,
       STAGE_TABLE = 6, STAGE_PIDFD = 7, STAGE_KERNEL = 8 };
/* What is wrong with a spec item (pl_spec_*): the module names the item. */
enum { E_NUL = -1001, E_EMPTY = -1002, E_NAME = -1003, E_SPEC = -1004, E_VALUE_NUL = -1005 };

#ifdef PL_TESTING
/* The testing build's fault bits (pl_t_faults): negative controls. */
enum {
    F_KEEP_SIGNALS = 1,      /* spawn without resetting dispositions and the mask */
    F_KEEP_FDS = 2,          /* spawn without closefrom(3) */
    F_EAGER_REAP = 4,        /* pl_status reaps at once (no reserved PGID behind a later group signal) */
    F_PIDFD_SPAWN = 8,       /* glibc's pidfd_spawn (leaks its pidfd when exec fails) */
    F_NO_PIDFD = 16,         /* a kernel without pidfd_open (ENOSYS) */
    F_PIDFD_FAIL = 32,       /* pidfd_open fails after the spawn (EMFILE) */
    F_OLD_KERNEL = 64,       /* no PIDFD_SIGNAL_PROCESS_GROUP: the kill(-pgid) fallback */
};
static int FAULTS;
#define FAULT(b) (__atomic_load_n(&FAULTS, __ATOMIC_RELAXED) & (b))
#else
#define FAULT(b) 0
#endif

typedef struct {
    int used;
    unsigned long long owner;
    char *path;
    char **argv;
    int argc, argcap;
    char **env;            /* NAME=VALUE settings, or NAME alone: removal */
    int envc, envcap;
    int env_explicit;      /* start from an empty environment */
    char *cwd;
    int policy[3];
    char *file[3];
    int append[3];
    int group;             /* 1: a process group of its own */
} pl_spec;

typedef struct {
    int used;
    unsigned gen;
    unsigned long long owner;  /* the spawning thread's token; 0: no thread (detached, its thread ended) */
    pid_t pid;
    int pidfd;
    int fd[3];             /* the parent's ends: 0 stdin (write), 1 stdout, 2 stderr (read) */
    int group;
    int exited;            /* status known (peeked) */
    int reaped;
    int detached;
    int kind;              /* 1 exited normally, 2 killed by a signal, 3 dumped core */
    int code;              /* exit status, or the signal */
    long long spawned_us, exited_us;
} pl_child;

static pthread_mutex_t LOCK = PTHREAD_MUTEX_INITIALIZER;
static pl_spec SPECS[MAX_SPECS];
static pl_child CHILDREN[MAX_CHILDREN];
static __thread int last_stage;

/* Counters (pl_stat). */
enum { ST_SPAWNED, ST_SPAWN_FAILED, ST_REAPED, ST_RELEASED, ST_DETACHED, ST_SWEPT, ST_SIGNALS, ST_READS,
       ST_READ_BYTES, ST_WRITES, ST_WRITE_BYTES, ST_EAGAIN, ST_LIVE, ST_FDS, ST_TABLE, ST_THREAD_KILLED,
       ST_SPECS, ST_COUNT };
static long long STATS[ST_COUNT];

static long long now_us(void) {
    struct timespec t;
    clock_gettime(CLOCK_MONOTONIC, &t);
    return (long long)t.tv_sec * 1000000LL + t.tv_nsec / 1000;
}

long long pl_abi(void) { return PL_ABI; }
/* The clock the adapter and the Linux driver share (CLOCK_MONOTONIC, us). */
long long pl_now(void) { return now_us(); }
long long pl_last_stage(void) { return last_stage; }
/* The table index of handle H (its low 16 bits): the module's own tables
 * are indexed by it. */
long long pl_index(long long h) { return h & 0xffff; }

long long pl_stat(long long i) {
    if (i < 0 || i >= ST_COUNT) return -EINVAL;
    pthread_mutex_lock(&LOCK);
    long long v = STATS[i];
    pthread_mutex_unlock(&LOCK);
    return v;
}

static int pidfd_open_(pid_t pid) {
    if (FAULT(F_NO_PIDFD)) {
        errno = ENOSYS;
        return -1;
    }
    return (int)syscall(SYS_pidfd_open, pid, 0);
}

static int pidfd_send_signal_(int fd, int sig, unsigned flags) {
    return (int)syscall(SYS_pidfd_send_signal, fd, sig, NULL, flags);
}

/* Whether SIGCHLD is set up so that children reap themselves (SIG_IGN, or
 * SA_NOCLDWAIT): then a child can vanish before its pidfd is opened, and
 * this adapter cannot keep its identity. */
static int children_reap_themselves(void) {
    struct sigaction sa;
    if (sigaction(SIGCHLD, NULL, &sa) != 0) return 0;
    return sa.sa_handler == SIG_IGN || (sa.sa_flags & SA_NOCLDWAIT);
}

/* Whether this process can supervise children: 0, -ENOSYS (no pidfd_open:
 * Linux before 5.3), -EINVAL (no waitid(P_PIDFD): before 5.4), -ECHILD
 * (SIGCHLD ignored: children are reaped behind the supervisor's back). */
long long pl_probe(void) {
    int fd = pidfd_open_(getpid());
    if (fd < 0) return -errno;
    siginfo_t si;
    memset(&si, 0, sizeof si);
    int r = waitid(P_PIDFD, (id_t)fd, &si, WEXITED | WNOHANG);
    int e = errno;
    close(fd);
    /* Our own process is no child of ours: ECHILD is the supported answer;
     * EINVAL says the kernel does not know P_PIDFD. */
    if (r == 0 || e != ECHILD) return -EINVAL;
    if (children_reap_themselves()) return -ECHILD;
    return 0;
}

/* ---------------------------------------------------------------------
 * The calling thread: a token of its own, and its end */

static unsigned long long NEXT_TOKEN = 1;
static __thread unsigned long long my_token;
static pthread_key_t END_KEY;
static pthread_once_t END_ONCE = PTHREAD_ONCE_INIT;
static int end_ready;

static void thread_ended(void *value);
static void process_ending(void);

static void end_key(void) {
    end_ready = pthread_key_create(&END_KEY, thread_ended) == 0;
    atexit(process_ending);
}

/* The calling thread's token; the first call registers its end. */
static unsigned long long token(void) {
    if (!my_token) {
        my_token = __atomic_fetch_add(&NEXT_TOKEN, 1, __ATOMIC_RELAXED);
        pthread_once(&END_ONCE, end_key);
        if (end_ready) pthread_setspecific(END_KEY, (void *)(uintptr_t)my_token);
    }
    return my_token;
}

/* ---------------------------------------------------------------------
 * Specs */

static pl_spec *spec_of(long long id) {
    if (id < 0 || id >= MAX_SPECS) return NULL;
    pl_spec *s = &SPECS[id];
    if (!__atomic_load_n(&s->used, __ATOMIC_ACQUIRE) || s->owner != token()) return NULL;
    return s;
}

/* A C string of N bytes at P: E_NUL when they hold a NUL (a C string
 * cannot), E_EMPTY when EMPTY_OK is 0 and N is 0, -ENOMEM. */
static int copy_text(const void *p, unsigned long n, int empty_ok, char **out) {
    *out = NULL;
    if (n == 0 && !empty_ok) return E_EMPTY;
    if (n > 0 && memchr(p, 0, n)) return E_NUL;
    char *s = malloc(n + 1);
    if (!s) return -ENOMEM;
    if (n > 0) memcpy(s, p, n);
    s[n] = 0;
    *out = s;
    return 0;
}

long long pl_spec_new(void) {
    unsigned long long me = token();
    pthread_mutex_lock(&LOCK);
    for (int i = 0; i < MAX_SPECS; i++) {
        if (!SPECS[i].used) {
            memset(&SPECS[i], 0, sizeof SPECS[i]);
            SPECS[i].owner = me;
            SPECS[i].policy[0] = SPECS[i].policy[1] = SPECS[i].policy[2] = POLICY_PIPE;
            SPECS[i].group = 1;
            __atomic_store_n(&SPECS[i].used, 1, __ATOMIC_RELEASE);
            STATS[ST_SPECS]++;
            pthread_mutex_unlock(&LOCK);
            return i;
        }
    }
    pthread_mutex_unlock(&LOCK);
    return -ENOSPC;
}

long long pl_spec_free(long long id) {
    pl_spec *s = spec_of(id);
    if (!s) return E_SPEC;
    free(s->path);
    for (int i = 0; i < s->argc; i++) free(s->argv[i]);
    free(s->argv);
    for (int i = 0; i < s->envc; i++) free(s->env[i]);
    free(s->env);
    free(s->cwd);
    for (int i = 0; i < 3; i++) free(s->file[i]);
    pthread_mutex_lock(&LOCK);
    memset(s, 0, sizeof *s);
    STATS[ST_SPECS]--;
    pthread_mutex_unlock(&LOCK);
    return 0;
}

/* The executable: a path, never searched for (a relative one is resolved in
 * the child's working directory, as execve does); also argv[0]. */
long long pl_spec_executable(long long id, const void *p, unsigned long n) {
    pl_spec *s = spec_of(id);
    if (!s) return E_SPEC;
    char *t;
    int r = copy_text(p, n, 0, &t);
    if (r) return r;
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

/* One argument after argv[0], exactly these bytes (empty is an argument). */
long long pl_spec_arg(long long id, const void *p, unsigned long n) {
    pl_spec *s = spec_of(id);
    if (!s) return E_SPEC;
    char *t;
    int r = copy_text(p, n, 1, &t);
    if (r) return r;
    r = push(&s->argv, &s->argc, &s->argcap, t);
    if (r) free(t);
    return r;
}

/* An environment variable's name: not empty, no '=', no NUL. */
static int env_name(const void *p, unsigned long n) {
    if (n == 0) return E_EMPTY;
    if (memchr(p, 0, n)) return E_NUL;
    if (memchr(p, '=', n)) return E_NAME;
    return 0;
}

/* Set NAME to VALUE in the child's environment (later settings win). */
long long pl_spec_env_set(long long id, const void *name, unsigned long nn, const void *value, unsigned long vn) {
    pl_spec *s = spec_of(id);
    if (!s) return E_SPEC;
    int r = env_name(name, nn);
    if (r) return r;
    if (vn > 0 && memchr(value, 0, vn)) return E_VALUE_NUL;
    char *t = malloc(nn + 1 + vn + 1);
    if (!t) return -ENOMEM;
    memcpy(t, name, nn);
    t[nn] = '=';
    if (vn > 0) memcpy(t + nn + 1, value, vn);
    t[nn + 1 + vn] = 0;
    r = push(&s->env, &s->envc, &s->envcap, t);
    if (r) free(t);
    return r;
}

/* Remove NAME from the child's environment. */
long long pl_spec_env_unset(long long id, const void *name, unsigned long nn) {
    pl_spec *s = spec_of(id);
    if (!s) return E_SPEC;
    int r = env_name(name, nn);
    if (r) return r;
    char *t;
    r = copy_text(name, nn, 0, &t);
    if (r) return r;
    r = push(&s->env, &s->envc, &s->envcap, t);
    if (r) free(t);
    return r;
}

/* Start from an empty environment instead of the supervisor's. */
long long pl_spec_env_clear(long long id) {
    pl_spec *s = spec_of(id);
    if (!s) return E_SPEC;
    s->env_explicit = 1;
    return 0;
}

long long pl_spec_cwd(long long id, const void *p, unsigned long n) {
    pl_spec *s = spec_of(id);
    if (!s) return E_SPEC;
    char *t;
    int r = copy_text(p, n, 0, &t);
    if (r) return r;
    free(s->cwd);
    s->cwd = t;
    return 0;
}

/* Stream WHICH (0 stdin, 1 stdout, 2 stderr): POLICY 0 inherit, 1 pipe,
 * 2 /dev/null. */
long long pl_spec_stdio(long long id, long long which, long long policy) {
    pl_spec *s = spec_of(id);
    if (!s) return E_SPEC;
    if (which < 0 || which > 2 || policy < 0 || policy > 2) return -EINVAL;
    s->policy[which] = (int)policy;
    return 0;
}

/* Redirect stream WHICH to the file PATH (stdin: read it; stdout/stderr:
 * create it (mode 0666, less the umask) and truncate it, or append to it). */
long long pl_spec_stdio_file(long long id, long long which, const void *p, unsigned long n, long long append) {
    pl_spec *s = spec_of(id);
    if (!s) return E_SPEC;
    if (which < 0 || which > 2) return -EINVAL;
    char *t;
    int r = copy_text(p, n, 0, &t);
    if (r) return r;
    free(s->file[which]);
    s->file[which] = t;
    s->append[which] = append != 0;
    s->policy[which] = POLICY_FILE;
    return 0;
}

/* GROUP 1: the child leads a process group of its own (the default); 0: it
 * stays in the supervisor's (and signals reach the child alone). */
long long pl_spec_group(long long id, long long group) {
    pl_spec *s = spec_of(id);
    if (!s) return E_SPEC;
    s->group = group != 0;
    return 0;
}

/* The child's environment: the supervisor's (or none) with the settings
 * and removals applied in order. Freed by the caller (the strings are
 * borrowed). */
static char **environment(pl_spec *s) {
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

static pl_child *child_of(long long h) {
    long long idx = h & 0xffff;
    unsigned gen = (unsigned)(h >> 16);
    if (h <= 0 || idx >= MAX_CHILDREN) return NULL;
    pl_child *c = &CHILDREN[idx];
    if (!c->used || c->gen != gen) return NULL;
    return c;
}

/* The child H names, for the calling thread; NULL with *ERR set. Called
 * with LOCK held. */
static pl_child *mine(long long h, unsigned long long me, long long *err) {
    pl_child *c = child_of(h);
    if (!c) {
        *err = -ESTALE;
        return NULL;
    }
    if (c->owner != me) {
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

static void next_gen(pl_child *c) {
    c->gen++;
    if (c->gen == 0 || c->gen > 0x7fffff) c->gen = 1;
}

/* Free slot C (its descriptors closed): the next child of the slot gets
 * another generation, so every handle of this one is stale. LOCK held. */
static void free_slot(pl_child *c) {
    for (int i = 0; i < 3; i++) close_fd(&c->fd[i]);
    close_fd(&c->pidfd);
    unsigned gen = c->gen;
    memset(c, 0, sizeof *c);
    c->gen = gen;
    c->pidfd = c->fd[0] = c->fd[1] = c->fd[2] = -1;
    STATS[ST_TABLE]--;
}

static void record(pl_child *c, const siginfo_t *si) {
    c->exited = 1;
    c->exited_us = now_us();
    c->kind = si->si_code == CLD_EXITED ? 1 : si->si_code == CLD_DUMPED ? 3 : 2;
    c->code = si->si_status;
}

/* Reap C if it has exited (WNOHANG): 1 when reaped. LOCK held. */
static int reap_now(pl_child *c) {
    if (c->reaped) return 1;
    siginfo_t si;
    memset(&si, 0, sizeof si);
    if (waitid(P_PIDFD, (id_t)c->pidfd, &si, WEXITED | WNOHANG) == 0 && si.si_pid != 0) {
        if (!c->exited) record(c, &si);
        c->reaped = 1;
        STATS[ST_REAPED]++;
        STATS[ST_LIVE]--;
        return 1;
    }
    return 0;
}

/* Detached children whose thread ended (owner 0): reaped and freed once
 * they have exited; how many still run. LOCK held. */
static long long sweep_orphaned(void) {
    long long running = 0;
    for (int i = 0; i < MAX_CHILDREN; i++) {
        pl_child *c = &CHILDREN[i];
        if (!c->used || !c->detached || c->owner != 0) continue;
        if (reap_now(c)) {
            free_slot(c);
            STATS[ST_SWEPT]++;
        } else {
            running++;
        }
    }
    return running;
}

/* An fd of at least 3 for FD (close-on-exec), so that the child's dup2s onto
 * 0, 1 and 2 never overwrite one another (a supervisor whose own standard
 * descriptors are closed gets pipe ends numbered 0..2). */
static int lift(int fd) {
    if (fd < 0 || fd > 2) return fd;
    int n = fcntl(fd, F_DUPFD_CLOEXEC, 3);
    int e = errno;
    close(fd);
    errno = e;
    return n;
}

/* Start what spec ID describes. The child's handle (> 0), or -errno with
 * pl_last_stage() saying where it failed. The spec stays usable. */
long long pl_spawn(long long id) {
    last_stage = STAGE_SPEC;
    pl_spec *s = spec_of(id);
    if (!s) return E_SPEC;
    if (!s->path) return E_EMPTY;
    unsigned long long me = token();
    if (FAULT(F_NO_PIDFD)) {
        last_stage = STAGE_KERNEL;
        return -ENOSYS;
    }
    if (children_reap_themselves()) {
        last_stage = STAGE_KERNEL;
        return -ECHILD;
    }
    int cwdfd = -1, src[3] = { -1, -1, -1 }, mine_end[3] = { -1, -1, -1 };
    long long result = 0;
    char **argv = NULL, **envp = NULL;
    posix_spawn_file_actions_t fa;
    posix_spawnattr_t attr;
    int have_fa = 0, have_attr = 0;

    pthread_mutex_lock(&LOCK);
    sweep_orphaned();
    pthread_mutex_unlock(&LOCK);

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
            src[i] = lift(open("/dev/null", (i == 0 ? O_RDONLY : O_WRONLY) | O_CLOEXEC));
            if (src[i] < 0) {
                result = -errno;
                goto out;
            }
            break;
        case POLICY_FILE:
            last_stage = STAGE_FILE;
            src[i] = lift(i == 0 ? open(s->file[i], O_RDONLY | O_CLOEXEC)
                                 : open(s->file[i], O_WRONLY | O_CREAT | O_CLOEXEC | (s->append[i] ? O_APPEND : O_TRUNC), 0666));
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
            src[i] = lift(src[i]);
            if (src[i] < 0) {
                result = -errno;
                goto out;
            }
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
    if (posix_spawn_file_actions_init(&fa) != 0) {
        result = -ENOMEM;
        goto out;
    }
    have_fa = 1;
    if (posix_spawnattr_init(&attr) != 0) {
        result = -ENOMEM;
        goto out;
    }
    have_attr = 1;
    for (int i = 0; i < 3; i++)
        if (src[i] >= 0 && posix_spawn_file_actions_adddup2(&fa, src[i], i) != 0) {
            result = -ENOMEM;
            goto out;
        }
    if (cwdfd >= 0 && posix_spawn_file_actions_addfchdir_np(&fa, cwdfd) != 0) {
        result = -ENOMEM;
        goto out;
    }
    if (!FAULT(F_KEEP_FDS) && posix_spawn_file_actions_addclosefrom_np(&fa, 3) != 0) {
        result = -ENOMEM;
        goto out;
    }
    short flags = 0;
    if (!FAULT(F_KEEP_SIGNALS)) {
        sigset_t all, none;
        sigfillset(&all);
        sigemptyset(&none);
        posix_spawnattr_setsigdefault(&attr, &all);
        posix_spawnattr_setsigmask(&attr, &none);
        flags |= POSIX_SPAWN_SETSIGDEF | POSIX_SPAWN_SETSIGMASK;
    }
    if (s->group) {
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
    pl_child *c = &CHILDREN[idx];
    unsigned gen = c->gen + 1;
    if (gen == 0 || gen > 0x7fffff) gen = 1;
    memset(c, 0, sizeof *c);
    c->gen = gen;
    c->pidfd = c->fd[0] = c->fd[1] = c->fd[2] = -1;
    c->used = 1; /* reserved while we spawn, unlocked; owner 0 until it is ours */
    STATS[ST_TABLE]++;
    pthread_mutex_unlock(&LOCK);

    last_stage = STAGE_EXEC;
    int pidfd = -1;
    pid_t pid = 0;
    int r;
    int stage = STAGE_EXEC;
#ifdef PL_TESTING
    if (FAULT(F_PIDFD_SPAWN)) {
        /* glibc 2.39 leaks the pidfd it made when exec fails
         * (audit/managed-subprocess/repro/pidfd-spawn-leak.c): a negative
         * control of the testing build only. */
        extern int pidfd_spawn(int *, const char *, const posix_spawn_file_actions_t *, const posix_spawnattr_t *,
                               char *const[], char *const[]);
        extern pid_t pidfd_getpid(int);
        r = pidfd_spawn(&pidfd, s->path, &fa, &attr, argv, envp);
        if (r == 0) pid = pidfd_getpid(pidfd);
    } else
#endif
    {
        r = posix_spawn(&pid, s->path, &fa, &attr, argv, envp);
        if (r == 0) {
            /* The child is ours and unreaped: its PID cannot name another
             * process until we reap it, so this pidfd is the child's. */
            pidfd = FAULT(F_PIDFD_FAIL) ? (errno = EMFILE, -1) : pidfd_open_(pid);
            if (pidfd < 0) {
                r = errno;
                stage = STAGE_PIDFD;
                /* No identity to supervise it by: it never runs unowned.
                 * Unreaped, its PID and its group's ID are still ours. */
                if (s->group) kill(-pid, SIGKILL);
                kill(pid, SIGKILL);
                while (waitpid(pid, NULL, 0) < 0 && errno == EINTR) {}
            }
        }
    }
    pthread_mutex_lock(&LOCK);
    if (r != 0) {
        free_slot(c);
        pthread_mutex_unlock(&LOCK);
        last_stage = stage;
        result = -r;
        goto out;
    }
    c->owner = me;
    c->pidfd = pidfd;
    c->pid = pid;
    c->group = s->group;
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
    if (result < 0) {
        pthread_mutex_lock(&LOCK);
        STATS[ST_SPAWN_FAILED]++;
        pthread_mutex_unlock(&LOCK);
    }
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

/* H's PID (for reports and records; never for signalling), or -errno. */
long long pl_pid(long long h) {
    long long err = 0;
    unsigned long long me = token();
    pthread_mutex_lock(&LOCK);
    pl_child *c = mine(h, me, &err);
    long long v = c ? c->pid : err;
    pthread_mutex_unlock(&LOCK);
    return v;
}

/* The descriptor the module watches: WHICH 0..2 a stream (-1 when it has
 * none or it was closed), 3 the pidfd. */
long long pl_fd(long long h, long long which) {
    long long err = 0;
    unsigned long long me = token();
    pthread_mutex_lock(&LOCK);
    pl_child *c = mine(h, me, &err);
    long long v = !c ? err : which == 3 ? c->pidfd : (which >= 0 && which < 3) ? c->fd[which] : -EINVAL;
    pthread_mutex_unlock(&LOCK);
    return v;
}

/* One read(2) of stream WHICH (1 stdout, 2 stderr) into BUF: n > 0, 0 at
 * end of file, -EAGAIN when nothing is there yet, -EBADF when it is no pipe
 * or was closed. */
long long pl_read(long long h, long long which, void *buf, unsigned long cap) {
    long long err = 0;
    unsigned long long me = token();
    pthread_mutex_lock(&LOCK);
    pl_child *c = mine(h, me, &err);
    int fd = c && which >= 1 && which <= 2 ? c->fd[which] : -1;
    pthread_mutex_unlock(&LOCK);
    if (!c) return err;
    if (fd < 0) return -EBADF;
    ssize_t n;
    do n = read(fd, buf, cap); while (n < 0 && errno == EINTR);
    int e = errno;
    pthread_mutex_lock(&LOCK);
    STATS[ST_READS]++;
    if (n > 0) STATS[ST_READ_BYTES] += n;
    if (n < 0 && e == EAGAIN) STATS[ST_EAGAIN]++;
    pthread_mutex_unlock(&LOCK);
    return n < 0 ? -e : n;
}

/* One write(2) to the child's stdin of DATA's bytes from OFFSET to N: the
 * bytes written (possibly fewer), -EAGAIN when the pipe is full, -EPIPE once
 * the child closed it, -EBADF when it is no pipe or was closed. (The module
 * lends the whole buffer and an offset, so a write the pipe takes in many
 * parts copies nothing.) */
long long pl_write(long long h, const void *data, unsigned long n, long long offset) {
    if (offset < 0 || (unsigned long)offset > n) return -EINVAL;
    long long err = 0;
    unsigned long long me = token();
    pthread_mutex_lock(&LOCK);
    pl_child *c = mine(h, me, &err);
    int fd = c ? c->fd[0] : -1;
    pthread_mutex_unlock(&LOCK);
    if (!c) return err;
    if (fd < 0) return -EBADF;
    if ((unsigned long)offset == n) return 0;
    ssize_t w;
    do w = write(fd, (const char *)data + offset, n - (unsigned long)offset); while (w < 0 && errno == EINTR);
    int e = errno;
    pthread_mutex_lock(&LOCK);
    STATS[ST_WRITES]++;
    if (w > 0) STATS[ST_WRITE_BYTES] += w;
    if (w < 0 && e == EAGAIN) STATS[ST_EAGAIN]++;
    pthread_mutex_unlock(&LOCK);
    return w < 0 ? -e : w;
}

/* Close the parent's end of stream WHICH (0 closes stdin: the child reads
 * end of file). Unwatch it first: a closed number may name another file. */
long long pl_close_stream(long long h, long long which) {
    long long err = 0;
    unsigned long long me = token();
    pthread_mutex_lock(&LOCK);
    pl_child *c = mine(h, me, &err);
    if (c && which >= 0 && which <= 2) close_fd(&c->fd[which]);
    pthread_mutex_unlock(&LOCK);
    return c ? 0 : err;
}

/* Whether H has exited: 0 running, 1 exited (pl_exit_kind/_code), -errno.
 * Peeks (WNOWAIT): the child stays unreaped until pl_reap. */
long long pl_status(long long h) {
    long long err = 0;
    unsigned long long me = token();
    pthread_mutex_lock(&LOCK);
    pl_child *c = mine(h, me, &err);
    if (!c) {
        pthread_mutex_unlock(&LOCK);
        return err;
    }
    if (!c->exited) {
        siginfo_t si;
        memset(&si, 0, sizeof si);
        int opts = WEXITED | WNOHANG | (FAULT(F_EAGER_REAP) ? 0 : WNOWAIT);
        if (waitid(P_PIDFD, (id_t)c->pidfd, &si, opts) == 0 && si.si_pid != 0) {
            record(c, &si);
            if (FAULT(F_EAGER_REAP)) {
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

/* Wait (blocking the calling thread) until H has exited, peeking (the child
 * stays unreaped): for the end of a loop that can no longer deliver its
 * exit (revoked), after SIGKILL. 1, or -errno. */
long long pl_await_exit(long long h) {
    long long err = 0;
    unsigned long long me = token();
    pthread_mutex_lock(&LOCK);
    pl_child *c = mine(h, me, &err);
    if (!c) {
        pthread_mutex_unlock(&LOCK);
        return err;
    }
    int fd = c->pidfd, known = c->exited || c->reaped;
    pthread_mutex_unlock(&LOCK);
    if (known) return 1;
    siginfo_t si;
    memset(&si, 0, sizeof si);
    int w;
    do w = waitid(P_PIDFD, (id_t)fd, &si, WEXITED | WNOWAIT); while (w < 0 && errno == EINTR);
    int e = errno;
    pthread_mutex_lock(&LOCK);
    if (w == 0 && !c->exited) record(c, &si);
    pthread_mutex_unlock(&LOCK);
    return w < 0 ? -e : 1;
}

long long pl_exit_kind(long long h) {
    long long err = 0;
    unsigned long long me = token();
    pthread_mutex_lock(&LOCK);
    pl_child *c = mine(h, me, &err);
    long long v = c ? (c->exited ? c->kind : 0) : err;
    pthread_mutex_unlock(&LOCK);
    return v;
}

long long pl_exit_code(long long h) {
    long long err = 0;
    unsigned long long me = token();
    pthread_mutex_lock(&LOCK);
    pl_child *c = mine(h, me, &err);
    long long v = c ? (c->exited ? c->code : 0) : err;
    pthread_mutex_unlock(&LOCK);
    return v;
}

/* Signal C (LOCK held): to its process group when GROUP and it has one of
 * its own, else to C. Never after the reap. 0, or -errno. */
static long long signal_child(pl_child *c, int sig, int group) {
    if (c->reaped) return -ESRCH;
    unsigned flags = (group && c->group) ? PIDFD_SIGNAL_PROCESS_GROUP : 0;
    int r = (flags && FAULT(F_OLD_KERNEL)) ? (errno = EINVAL, -1) : pidfd_send_signal_(c->pidfd, sig, flags);
    if (r < 0 && errno == EINVAL && flags) {
        /* A kernel before 6.9: the leader is unreaped (checked above), so
         * its PID -- the group's ID -- is still reserved. */
        r = kill(-c->pid, sig);
    }
    if (r == 0) STATS[ST_SIGNALS]++;
    return r < 0 ? -errno : 0;
}

/* Send SIG (0..64) to H (GROUP: to its process group, when it has one of
 * its own). 0, or -errno: -ESRCH once reaped -- never a PID that may be
 * reused. */
long long pl_signal(long long h, long long sig, long long group) {
    if (sig < 0 || sig > 64) return -EINVAL;
    long long err = 0;
    unsigned long long me = token();
    pthread_mutex_lock(&LOCK);
    pl_child *c = mine(h, me, &err);
    long long v = c ? signal_child(c, (int)sig, group != 0) : err;
    pthread_mutex_unlock(&LOCK);
    return v;
}

/* Reap H once it has exited: 0, -EAGAIN while it runs. */
long long pl_reap(long long h) {
    long long err = 0;
    unsigned long long me = token();
    pthread_mutex_lock(&LOCK);
    pl_child *c = mine(h, me, &err);
    if (!c) {
        pthread_mutex_unlock(&LOCK);
        return err;
    }
    long long v = reap_now(c) ? 0 : -EAGAIN;
    pthread_mutex_unlock(&LOCK);
    return v;
}

/* Kill C's group (or C) and reap it, blocking the calling thread until it
 * has exited (SIGKILL: bounded): what a loop that can no longer wait does.
 * LOCK not held; 0, or -errno. */
static long long kill_and_reap(pl_child *c) {
    pthread_mutex_lock(&LOCK);
    if (c->reaped) {
        pthread_mutex_unlock(&LOCK);
        return 0;
    }
    signal_child(c, SIGKILL, 1);
    int fd = c->pidfd;
    pthread_mutex_unlock(&LOCK);
    siginfo_t si;
    memset(&si, 0, sizeof si);
    int w;
    do w = waitid(P_PIDFD, (id_t)fd, &si, WEXITED); while (w < 0 && errno == EINTR);
    int e = errno;
    pthread_mutex_lock(&LOCK);
    if (w == 0) {
        if (!c->exited) record(c, &si);
        c->reaped = 1;
        STATS[ST_REAPED]++;
        STATS[ST_LIVE]--;
    }
    pthread_mutex_unlock(&LOCK);
    return w < 0 ? -e : 0;
}

long long pl_kill_and_reap(long long h) {
    long long err = 0;
    unsigned long long me = token();
    pthread_mutex_lock(&LOCK);
    pl_child *c = mine(h, me, &err);
    pthread_mutex_unlock(&LOCK);
    if (!c) return err;
    return kill_and_reap(c);
}

/* Release H: its descriptors are closed and its handle stale. Only once
 * reaped (-EBUSY otherwise: reap it, kill and reap it, or detach it). */
long long pl_release(long long h) {
    long long err = 0;
    unsigned long long me = token();
    pthread_mutex_lock(&LOCK);
    pl_child *c = mine(h, me, &err);
    if (!c) {
        pthread_mutex_unlock(&LOCK);
        return err;
    }
    if (!c->reaped) {
        pthread_mutex_unlock(&LOCK);
        return -EBUSY;
    }
    free_slot(c);
    STATS[ST_RELEASED]++;
    pthread_mutex_unlock(&LOCK);
    return 0;
}

/* Detach H: the parent's stream ends close (the child reads end of file on
 * a piped stdin; its writes to a piped stdout or stderr fail with EPIPE, or
 * SIGPIPE kill it), H goes stale, and the process keeps running. The new
 * handle names the detached child for reaping only (pl_status, pl_reap,
 * pl_release, pl_fd 3): the module's task reaps it if it exits while the
 * loop runs. -errno. */
long long pl_detach(long long h) {
    long long err = 0;
    unsigned long long me = token();
    pthread_mutex_lock(&LOCK);
    pl_child *c = mine(h, me, &err);
    if (!c) {
        pthread_mutex_unlock(&LOCK);
        return err;
    }
    for (int i = 0; i < 3; i++) close_fd(&c->fd[i]);
    c->detached = 1;
    next_gen(c); /* the owner's handle is stale now; the slot stays used */
    STATS[ST_DETACHED]++;
    long long v = ((long long)c->gen << 16) | (c - CHILDREN);
    pthread_mutex_unlock(&LOCK);
    return v;
}

/* Reap every detached child of the calling thread (and of ended threads)
 * that has exited and free its slot; the number of detached children still
 * running. */
long long pl_sweep(void) {
    unsigned long long me = token();
    long long running = 0;
    pthread_mutex_lock(&LOCK);
    for (int i = 0; i < MAX_CHILDREN; i++) {
        pl_child *c = &CHILDREN[i];
        if (!c->used || !c->detached || (c->owner != me && c->owner != 0)) continue;
        if (reap_now(c)) {
            free_slot(c);
            STATS[ST_SWEPT]++;
        } else {
            running++;
        }
    }
    pthread_mutex_unlock(&LOCK);
    return running;
}

/* The end of a thread that spawned children: every child it still
 * supervises is killed (SIGKILL to its group) and reaped, and its slot freed;
 * a detached one passes to no thread (owner 0) and is reaped by a later
 * sweep or spawn. */
static void thread_ended(void *value) {
    unsigned long long tok = (unsigned long long)(uintptr_t)value;
    if (!tok) return;
    for (int i = 0; i < MAX_CHILDREN; i++) {
        pthread_mutex_lock(&LOCK);
        pl_child *c = &CHILDREN[i];
        if (!c->used || c->owner != tok) {
            pthread_mutex_unlock(&LOCK);
            continue;
        }
        if (c->detached) {
            c->owner = 0;
            pthread_mutex_unlock(&LOCK);
            continue;
        }
        pthread_mutex_unlock(&LOCK);
        kill_and_reap(c);
        pthread_mutex_lock(&LOCK);
        if (c->reaped) {
            free_slot(c);
            STATS[ST_THREAD_KILLED]++;
        }
        pthread_mutex_unlock(&LOCK);
    }
    pthread_mutex_lock(&LOCK);
    for (int i = 0; i < MAX_SPECS; i++)
        if (SPECS[i].used && SPECS[i].owner == tok) {
            pl_spec *s = &SPECS[i];
            free(s->path);
            for (int k = 0; k < s->argc; k++) free(s->argv[k]);
            free(s->argv);
            for (int k = 0; k < s->envc; k++) free(s->env[k]);
            free(s->env);
            free(s->cwd);
            for (int k = 0; k < 3; k++) free(s->file[k]);
            memset(s, 0, sizeof *s);
            STATS[ST_SPECS]--;
        }
    pthread_mutex_unlock(&LOCK);
}

/* Process exit (atexit): every supervised child's group is sent SIGKILL, so
 * none outlives the process it was supervised by unless detached. (A
 * thread's end reaps its own; this is for whatever an exit() cut short.) */
static void process_ending(void) {
    if (pthread_mutex_trylock(&LOCK) != 0) return;
    for (int i = 0; i < MAX_CHILDREN; i++) {
        pl_child *c = &CHILDREN[i];
        if (c->used && !c->detached && c->owner != 0 && !c->reaped) signal_child(c, SIGKILL, 1);
    }
    pthread_mutex_unlock(&LOCK);
}

#ifdef PL_TESTING
/* ---------------------------------------------------------------------
 * The testing build's probes (tools/process-linux.tcl archive -testing 1;
 * tests/process/probe.bot). Never in the released archive. */

/* Set the fault bits; the previous ones. */
long long pl_t_faults(long long bits) {
    return __atomic_exchange_n(&FAULTS, (int)bits, __ATOMIC_RELAXED);
}

/* Descriptors open in this process (/proc/self/fd), for leak checks. */
long long pl_t_open_fds(void) {
    DIR *d = opendir("/proc/self/fd");
    if (!d) return -errno;
    long long n = 0;
    struct dirent *e;
    while ((e = readdir(d)))
        if (e->d_name[0] != '.') n++;
    closedir(d);
    return n - 1; /* the directory's own descriptor */
}

/* The calling thread's token (a thread's identity in the table). */
long long pl_t_token(void) {
    return (long long)token();
}

/* PID's scheduling state letter from /proc (82 'R', 83 'S', 84 'T' stopped,
 * 90 'Z' zombie, ...), or -errno (-ENOENT: no such process). */
long long pl_t_proc_state(long long pid) {
    char path[64], buf[512];
    snprintf(path, sizeof path, "/proc/%lld/stat", pid);
    int fd = open(path, O_RDONLY | O_CLOEXEC);
    if (fd < 0) return -errno;
    ssize_t n = read(fd, buf, sizeof buf - 1);
    close(fd);
    if (n <= 0) return -EIO;
    buf[n] = 0;
    char *close_paren = strrchr(buf, ')');
    return close_paren && close_paren[1] == ' ' ? (unsigned char)close_paren[2] : -EINVAL;
}

/* A descriptor of /dev/null opened WITHOUT close-on-exec, as a careless
 * library might: what closefrom(3) keeps out of every child. */
long long pl_t_plain_fd(void) {
    int fd = open("/dev/null", O_RDONLY);
    return fd < 0 ? -errno : fd;
}

long long pl_t_close(long long fd) {
    return close((int)fd) < 0 ? -errno : 0;
}

/* Set SIGCHLD's disposition: 1 ignored (children reap themselves), 0 the
 * default. The previous one: 1 when it was ignored. */
long long pl_t_ignore_sigchld(long long on) {
    struct sigaction sa, old;
    memset(&sa, 0, sizeof sa);
    sa.sa_handler = on ? SIG_IGN : SIG_DFL;
    sigemptyset(&sa.sa_mask);
    if (sigaction(SIGCHLD, &sa, &old) != 0) return -errno;
    return old.sa_handler == SIG_IGN;
}
#endif
