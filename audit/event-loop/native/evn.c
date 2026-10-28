/* evn.c -- the Linux native adapter of EVENT-LOOP-EXPLORATION.md
 * (Experiment B): what evloop's Driver needs from the operating system,
 * behind a C interface of scalars only.
 *
 *   clock      CLOCK_MONOTONIC, microseconds              evn_now
 *   waiting    one epoll instance; epoll_pwait2 (microsecond timeout)
 *              wakes for readiness, a wakeup or a deadline  evn_block
 *   wakeups    one eventfd, readable while a wakeup is owed: a post or
 *              wake from any thread before or during the sleep is never
 *              lost (the counter keeps it until the loop reads it)
 *                                                          evn_wake, evn_post
 *   records    (slot, gen, a, b): what the loop hands to evloop's
 *              registrations; the adapter copies everything it reads from
 *              the kernel into records and keeps no pointer to it
 *                                                          evn_take, evn_gen, evn_a, evn_b
 *   sockets    a listening TCP socket (accept -> a record per connection)
 *              and connections whose lines "CMD ARG\n" become records,
 *              read only while the connection has credit (demand-driven:
 *              backpressure reaches the peer through TCP's own window)
 *   threads    synthetic producers and test clients, on their own threads:
 *              the only cross-thread operation is evn_post (a mutex-guarded
 *              bounded queue); no Botlish code ever runs on them
 *
 * Fairness at this boundary: one evn_block reads at most `quota` records
 * per ready descriptor, so a flooding peer cannot fill the turn; the
 * cross-thread queue is bounded (a full queue refuses the post: the
 * producer sees it). evloop takes at most its budget of records per turn.
 *
 * EVN_BROKEN_WAKE (evn_open's flags & 1) is a deliberately wrong wakeup
 * protocol -- a post signals the eventfd only if the loop has announced it
 * is about to sleep -- with the classic race between the loop's emptiness
 * check and its announcement. It exists so the lost-wakeup test can show it
 * detects a lost wakeup (a positive control).
 */
#define _GNU_SOURCE
#include <arpa/inet.h>
#include <errno.h>
#include <fcntl.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <pthread.h>
#include <stdatomic.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/epoll.h>
#include <sys/eventfd.h>
#include <sys/resource.h>
#include <sys/socket.h>
#include <time.h>
#include <unistd.h>

typedef struct {
    int slot, gen;
    long long a, b;
} evn_record;

/* A bounded FIFO of records. */
typedef struct {
    evn_record *items;
    int cap, head, count, max;
} evn_ring;

static int ring_push(evn_ring *r, evn_record rec) {
    if (r->count == r->cap) return -1;
    r->items[(r->head + r->count) % r->cap] = rec;
    r->count++;
    if (r->count > r->max) r->max = r->count;
    return 0;
}

static int ring_pop(evn_ring *r, evn_record *out) {
    if (r->count == 0) return -1;
    *out = r->items[r->head];
    r->head = (r->head + 1) % r->cap;
    r->count--;
    return 0;
}

enum { TAG_WAKE = 0, TAG_LISTEN = 1, TAG_CONN = 2 };

#define MAX_CONNS 1024
#define LINE_MAX_BYTES 64

typedef struct {
    int fd, slot, gen, credit, attached, open, armed;
    char line[LINE_MAX_BYTES];
    int len;
} evn_conn;

/* Counters (evn_stat). */
enum {
    ST_BLOCKS, ST_WAKEUPS, ST_SPURIOUS, ST_TIMEOUTS, ST_RECORDS, ST_POSTS,
    ST_POSTS_REFUSED, ST_RING_MAX, ST_POST_MAX, ST_ACCEPTS, ST_LINES,
    ST_PAUSED, ST_EVENTFD_WRITES, ST_SENDS, ST_COUNT
};

static struct {
    int epfd, wakefd, listenfd, listen_slot, listen_gen, quota, flags, opened;
    evn_ring ring;                   /* the loop thread's records */
    evn_ring posted;                 /* records posted by other threads */
    pthread_mutex_t lock;            /* guards `posted` and `sleeping` */
    int sleeping;                    /* EVN_BROKEN_WAKE's announcement */
    evn_conn conns[MAX_CONNS];
    int nconns;
    evn_record cur;
    long long stats[ST_COUNT];
} E = { .epfd = -1, .wakefd = -1, .listenfd = -1, .lock = PTHREAD_MUTEX_INITIALIZER };

long long evn_now(void) {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (long long)ts.tv_sec * 1000000LL + ts.tv_nsec / 1000;
}

long long evn_cpu_us(void) {
    struct rusage u;
    getrusage(RUSAGE_SELF, &u);
    return (long long)(u.ru_utime.tv_sec + u.ru_stime.tv_sec) * 1000000LL + u.ru_utime.tv_usec + u.ru_stime.tv_usec;
}

long long evn_stat(int i) {
    if (i == ST_RING_MAX) return E.ring.max;
    if (i == ST_POST_MAX) return E.posted.max;
    return (i >= 0 && i < ST_COUNT) ? E.stats[i] : -1;
}

static int add_fd(int fd, int tag, int index, uint32_t events) {
    struct epoll_event ev = { .events = events, .data.u64 = ((uint64_t)tag << 32) | (uint32_t)index };
    return epoll_ctl(E.epfd, EPOLL_CTL_ADD, fd, &ev);
}

/* Open the adapter: a record ring of CAPACITY, at most QUOTA records per
 * ready descriptor per evn_block. 0, or -errno. */
int evn_open(int capacity, int quota, int flags) {
    if (E.opened) return 0;
    E.epfd = epoll_create1(EPOLL_CLOEXEC);
    if (E.epfd < 0) return -errno;
    E.wakefd = eventfd(0, EFD_NONBLOCK | EFD_CLOEXEC);
    if (E.wakefd < 0) return -errno;
    if (add_fd(E.wakefd, TAG_WAKE, 0, EPOLLIN) < 0) return -errno;
    E.ring.items = calloc((size_t)capacity, sizeof(evn_record));
    E.ring.cap = capacity;
    E.posted.items = calloc((size_t)capacity, sizeof(evn_record));
    E.posted.cap = capacity;
    E.quota = quota;
    E.flags = flags;
    E.opened = 1;
    return 0;
}

static void signal_wakefd(void) {
    uint64_t one = 1;
    if (write(E.wakefd, &one, sizeof one) == sizeof one) {
        __atomic_add_fetch(&E.stats[ST_EVENTFD_WRITES], 1, __ATOMIC_RELAXED);
    }
}

/* Wake the loop from any thread. */
int evn_wake(void) {
    signal_wakefd();
    return 0;
}

/* Post record (SLOT, GEN, A, B) from any thread. 0, or -1 when the
 * cross-thread queue is full (the post is refused, nothing is lost
 * silently). The eventfd is signalled only on the empty -> non-empty edge:
 * one wakeup per batch. */
int evn_post(int slot, int gen, long long a, long long b) {
    evn_record rec = { slot, gen, a, b };
    pthread_mutex_lock(&E.lock);
    int was_empty = E.posted.count == 0;
    int rc = ring_push(&E.posted, rec);
    int sleeping = E.sleeping;
    pthread_mutex_unlock(&E.lock);
    if (rc < 0) {
        __atomic_add_fetch(&E.stats[ST_POSTS_REFUSED], 1, __ATOMIC_RELAXED);
        return -1;
    }
    __atomic_add_fetch(&E.stats[ST_POSTS], 1, __ATOMIC_RELAXED);
    if (E.flags & 1) {
        if (sleeping) signal_wakefd();      /* BROKEN: misses the race window */
    } else if (was_empty) {
        signal_wakefd();
    }
    return 0;
}

static void drain_posted(void) {
    pthread_mutex_lock(&E.lock);
    evn_record rec;
    while (E.ring.count < E.ring.cap && ring_pop(&E.posted, &rec) == 0) {
        ring_push(&E.ring, rec);
    }
    pthread_mutex_unlock(&E.lock);
}

static void rearm(evn_conn *c) {
    int want = c->open && c->attached && c->credit > 0;
    if (want == c->armed) return;
    struct epoll_event ev = { .events = want ? EPOLLIN : 0, .data.u64 = ((uint64_t)TAG_CONN << 32) | (uint32_t)(c - E.conns) };
    epoll_ctl(E.epfd, EPOLL_CTL_MOD, c->fd, &ev);
    c->armed = want;
    if (!want) E.stats[ST_PAUSED]++;
}

static void conn_record(evn_conn *c, long long cmd, long long arg) {
    evn_record rec = { c->slot, c->gen, cmd, arg };
    if (ring_push(&E.ring, rec) == 0) {
        E.stats[ST_LINES]++;
        c->credit--;
    }
}

static void read_conn(evn_conn *c) {
    int produced = 0;
    while (produced < E.quota && c->credit > 0 && E.ring.count < E.ring.cap) {
        /* Complete lines already buffered first. */
        char *nl = memchr(c->line, '\n', (size_t)c->len);
        if (nl) {
            *nl = 0;
            long long cmd = 0, arg = 0;
            sscanf(c->line, "%lld %lld", &cmd, &arg);
            int used = (int)(nl - c->line) + 1;
            memmove(c->line, c->line + used, (size_t)(c->len - used));
            c->len -= used;
            conn_record(c, cmd, arg);
            produced++;
            continue;
        }
        ssize_t n = read(c->fd, c->line + c->len, (size_t)(LINE_MAX_BYTES - 1 - c->len));
        if (n > 0) {
            c->len += (int)n;
            if (c->len >= LINE_MAX_BYTES - 1 && !memchr(c->line, '\n', (size_t)c->len)) c->len = 0; /* overlong: dropped */
            continue;
        }
        if (n == 0) {
            /* The peer closed: one BYE record, then nothing more. */
            conn_record(c, 9, 0);
            c->open = 0;
            epoll_ctl(E.epfd, EPOLL_CTL_DEL, c->fd, NULL);
            c->armed = 0;
            return;
        }
        if (errno == EAGAIN || errno == EWOULDBLOCK) break;
        if (errno == EINTR) continue;
        conn_record(c, 9, -errno);
        c->open = 0;
        epoll_ctl(E.epfd, EPOLL_CTL_DEL, c->fd, NULL);
        c->armed = 0;
        return;
    }
    rearm(c);
}

static void accept_some(void) {
    int produced = 0;
    while (produced < E.quota && E.ring.count < E.ring.cap && E.nconns < MAX_CONNS) {
        int fd = accept4(E.listenfd, NULL, NULL, SOCK_NONBLOCK | SOCK_CLOEXEC);
        if (fd < 0) break;
        int one = 1;
        setsockopt(fd, IPPROTO_TCP, TCP_NODELAY, &one, sizeof one);
        int id = E.nconns++;
        evn_conn *c = &E.conns[id];
        memset(c, 0, sizeof *c);
        c->fd = fd;
        c->open = 1;
        /* Registered with no interest until the program attaches it. */
        add_fd(fd, TAG_CONN, id, 0);
        E.stats[ST_ACCEPTS]++;
        evn_record rec = { E.listen_slot, E.listen_gen, id, 0 };
        ring_push(&E.ring, rec);
        produced++;
    }
}

/* Block until a record is available, a wakeup arrives or DEADLINE (us,
 * evn_now's clock) passes; -1: no deadline; a deadline not in the future,
 * or records already waiting: do not block. Returns the records available. */
int evn_block(long long deadline) {
    E.stats[ST_BLOCKS]++;
    if (E.flags & 1) {
        /* BROKEN_WAKE: check emptiness, then (later) announce the sleep. */
        pthread_mutex_lock(&E.lock);
        int empty = E.posted.count == 0;
        pthread_mutex_unlock(&E.lock);
        if (empty) {
            struct timespec gap = { 0, 200000 };   /* the race window, widened */
            nanosleep(&gap, NULL);
            pthread_mutex_lock(&E.lock);
            E.sleeping = 1;
            pthread_mutex_unlock(&E.lock);
        }
    } else {
        drain_posted();
    }
    struct timespec timeout, *tp = NULL;
    if (E.ring.count > 0) {
        timeout.tv_sec = 0;
        timeout.tv_nsec = 0;
        tp = &timeout;
    } else if (deadline >= 0) {
        long long left = deadline - evn_now();
        if (left < 0) left = 0;
        timeout.tv_sec = left / 1000000;
        timeout.tv_nsec = (left % 1000000) * 1000;
        tp = &timeout;
    }
    struct epoll_event events[64];
    int n = epoll_pwait2(E.epfd, events, 64, tp, NULL);
    if (E.flags & 1) {
        pthread_mutex_lock(&E.lock);
        E.sleeping = 0;
        pthread_mutex_unlock(&E.lock);
    }
    int before = E.ring.count;
    if (n == 0 && tp && (tp->tv_sec || tp->tv_nsec)) E.stats[ST_TIMEOUTS]++;
    for (int i = 0; i < n; i++) {
        int tag = (int)(events[i].data.u64 >> 32);
        int index = (int)(uint32_t)events[i].data.u64;
        if (tag == TAG_WAKE) {
            uint64_t count;
            if (read(E.wakefd, &count, sizeof count) == sizeof count) E.stats[ST_WAKEUPS]++;
        } else if (tag == TAG_LISTEN) {
            accept_some();
        } else if (tag == TAG_CONN) {
            read_conn(&E.conns[index]);
        }
    }
    drain_posted();
    if (n > 0 && E.ring.count == before) E.stats[ST_SPURIOUS]++;
    E.stats[ST_RECORDS] += E.ring.count - before;
    return E.ring.count;
}

int evn_take(void) {
    if (ring_pop(&E.ring, &E.cur) < 0) return -1;
    return E.cur.slot;
}
int evn_gen(void) { return E.cur.gen; }
long long evn_a(void) { return E.cur.a; }
long long evn_b(void) { return E.cur.b; }

/* ---------------------------------------------------------------------
 * Sockets */

/* Listen on 127.0.0.1:PORT (0: any free port); accepted connections are
 * records (SLOT, GEN, conn, 0). Returns the port, or -errno. */
int evn_listen(int port, int slot, int gen) {
    int fd = socket(AF_INET, SOCK_STREAM | SOCK_NONBLOCK | SOCK_CLOEXEC, 0);
    if (fd < 0) return -errno;
    int one = 1;
    setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &one, sizeof one);
    struct sockaddr_in a = { .sin_family = AF_INET, .sin_port = htons((uint16_t)port), .sin_addr.s_addr = htonl(INADDR_LOOPBACK) };
    if (bind(fd, (struct sockaddr *)&a, sizeof a) < 0 || listen(fd, 64) < 0) {
        int e = errno;
        close(fd);
        return -e;
    }
    socklen_t len = sizeof a;
    getsockname(fd, (struct sockaddr *)&a, &len);
    E.listenfd = fd;
    E.listen_slot = slot;
    E.listen_gen = gen;
    add_fd(fd, TAG_LISTEN, 0, EPOLLIN);
    return ntohs(a.sin_port);
}

/* Stop listening (the registration was revoked). */
int evn_unlisten(void) {
    if (E.listenfd < 0) return 0;
    epoll_ctl(E.epfd, EPOLL_CTL_DEL, E.listenfd, NULL);
    close(E.listenfd);
    E.listenfd = -1;
    return 1;
}

/* Tag connection CONN's lines with registration (SLOT, GEN) and start
 * reading them, CREDIT lines ahead. */
int evn_attach(int conn, int slot, int gen, int credit) {
    if (conn < 0 || conn >= E.nconns) return -1;
    evn_conn *c = &E.conns[conn];
    c->slot = slot;
    c->gen = gen;
    c->credit = credit;
    c->attached = 1;
    rearm(c);
    /* Lines may already be buffered: read them in the next evn_block. */
    if (c->armed) evn_wake();
    return 0;
}

/* The program consumed N lines of CONN: read N more. */
int evn_credit(int conn, int n) {
    if (conn < 0 || conn >= E.nconns) return -1;
    evn_conn *c = &E.conns[conn];
    c->credit += n;
    int was = c->armed;
    rearm(c);
    if (!was && c->armed) evn_wake();
    return c->credit;
}

int evn_send(int conn, long long value) {
    if (conn < 0 || conn >= E.nconns || !E.conns[conn].open) return -1;
    char text[32];
    int n = snprintf(text, sizeof text, "%lld\n", value);
    E.stats[ST_SENDS]++;
    return (int)send(E.conns[conn].fd, text, (size_t)n, MSG_NOSIGNAL);
}

int evn_hangup(int conn) {
    if (conn < 0 || conn >= E.nconns) return -1;
    evn_conn *c = &E.conns[conn];
    if (c->fd >= 0) {
        epoll_ctl(E.epfd, EPOLL_CTL_DEL, c->fd, NULL);
        close(c->fd);
        c->fd = -1;
    }
    c->open = 0;
    c->armed = 0;
    return 0;
}

/* ---------------------------------------------------------------------
 * Threads: synthetic sources and test clients. None of them runs Botlish
 * code; each talks to the loop through evn_post or a socket. */

typedef struct {
    int slot, gen, count, interval_us, burst, jitter, gap_us;
    unsigned seed;
} synth_args;

static pthread_t synth_threads[16];
static int nsynth;

static void *synth_main(void *p) {
    synth_args *s = p;
    unsigned seed = s->seed;
    for (int i = 0; i < s->count; i++) {
        if (s->interval_us > 0 && (s->burst <= 1 || i % s->burst == 0)) {
            int us = s->interval_us;
            if (s->jitter) us = (int)(rand_r(&seed) % (unsigned)(2 * s->interval_us + 1));
            struct timespec ts = { us / 1000000, (us % 1000000) * 1000L };
            nanosleep(&ts, NULL);
        } else if (s->gap_us > 0) {
            struct timespec ts = { 0, s->gap_us * 1000L };
            nanosleep(&ts, NULL);
        }
        /* b: the time of the post, so the receiver measures post -> dispatch. */
        while (evn_post(s->slot, s->gen, i, evn_now()) < 0) {
            struct timespec ts = { 0, 50000 };
            nanosleep(&ts, NULL);
        }
    }
    free(s);
    return NULL;
}

/* Start a thread posting COUNT records to (SLOT, GEN): bursts of BURST
 * records every INTERVAL_US (0: as fast as it can; JITTER 1: uniformly
 * 0..2*INTERVAL_US), GAP_US apart within a burst. A full queue makes the
 * producer wait (backpressure). */
int evn_synth(int slot, int gen, int count, int interval_us, int burst, int jitter, int gap_us) {
    if (nsynth == 16) return -1;
    synth_args *s = malloc(sizeof *s);
    *s = (synth_args){ slot, gen, count, interval_us, burst, jitter, gap_us, (unsigned)(nsynth * 7919 + 17) };
    if (pthread_create(&synth_threads[nsynth], NULL, synth_main, s) != 0) return -1;
    nsynth++;
    return 0;
}

int evn_synth_join(void) {
    for (int i = 0; i < nsynth; i++) pthread_join(synth_threads[i], NULL);
    int n = nsynth;
    nsynth = 0;
    return n;
}

typedef struct {
    int port, id, pattern, lines, interval_us;
} client_args;

static pthread_t client_threads[64];
static int nclients;
static long long client_replies[64];

static void client_line(int fd, long long cmd, long long arg) {
    char text[48];
    int n = snprintf(text, sizeof text, "%lld %lld\n", cmd, arg);
    ssize_t off = 0;
    while (off < n) {
        ssize_t w = send(fd, text + off, (size_t)(n - off), MSG_NOSIGNAL);
        if (w <= 0) return;
        off += w;
    }
}

static void *client_main(void *p) {
    client_args *c = p;
    int fd = socket(AF_INET, SOCK_STREAM, 0);
    struct sockaddr_in a = { .sin_family = AF_INET, .sin_port = htons((uint16_t)c->port), .sin_addr.s_addr = htonl(INADDR_LOOPBACK) };
    if (connect(fd, (struct sockaddr *)&a, sizeof a) < 0) { free(c); return NULL; }
    int one = 1;
    setsockopt(fd, IPPROTO_TCP, TCP_NODELAY, &one, sizeof one);
    /* pattern 0: talk; 1: a long path, then talk; 2: flood. */
    if (c->pattern == 1) client_line(fd, 1, 3000);
    for (int i = 0; i < c->lines; i++) {
        if (c->interval_us > 0) {
            struct timespec ts = { c->interval_us / 1000000, (c->interval_us % 1000000) * 1000L };
            nanosleep(&ts, NULL);
        }
        client_line(fd, 2, c->id * 1000 + i);
    }
    client_line(fd, 9, 0);
    /* Read the replies until the server hangs up. */
    char buf[4096];
    long long lines = 0;
    for (;;) {
        ssize_t n = recv(fd, buf, sizeof buf, 0);
        if (n <= 0) break;
        for (ssize_t i = 0; i < n; i++) if (buf[i] == '\n') lines++;
    }
    client_replies[c->id % 64] = lines;
    close(fd);
    free(c);
    return NULL;
}

/* Start test client ID on its own thread (connects to PORT). */
int evn_client(int port, int id, int pattern, int lines, int interval_us) {
    if (nclients == 64) return -1;
    client_args *c = malloc(sizeof *c);
    *c = (client_args){ port, id, pattern, lines, interval_us };
    if (pthread_create(&client_threads[nclients], NULL, client_main, c) != 0) return -1;
    nclients++;
    return 0;
}

int evn_clients_join(void) {
    for (int i = 0; i < nclients; i++) pthread_join(client_threads[i], NULL);
    int n = nclients;
    nclients = 0;
    return n;
}

long long evn_client_replies(int id) { return client_replies[id % 64]; }

/* Burn the calling thread's CPU for US microseconds (a slow handler). */
int evn_spin(int us) {
    long long end = evn_now() + us;
    volatile long long x = 0;
    while (evn_now() < end) x++;
    return 0;
}
