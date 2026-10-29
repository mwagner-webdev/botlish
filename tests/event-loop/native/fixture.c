/* fixture.c -- native test fixtures of tests/event-loop-linux.test: what an
 * independently developed native library looks like to the Linux driver of
 * std::event_loop. Producer threads post records through the integration
 * ABI (botlish_event_loop.h); a line protocol over TCP is parsed here, on
 * the loop's thread, from sockets the program watches; test clients run on
 * their own threads. No Botlish code runs in any of it.
 */
#define _GNU_SOURCE
#include "botlish_event_loop.h"

#include <arpa/inet.h>
#include <errno.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <time.h>
#include <unistd.h>

/* ---------------------------------------------------------------------
 * Producer threads */

typedef struct {
    int endpoint, slot, gen, count, interval_us, burst, jitter, gap_us;
    unsigned seed;
} synth_args;

static pthread_t synth_threads[16];
static int nsynth;
static long long synth_refusals;

static void pause_us(int us) {
    struct timespec ts = { us / 1000000, (us % 1000000) * 1000L };
    nanosleep(&ts, NULL);
}

static void *synth_main(void *p) {
    synth_args *s = p;
    unsigned seed = s->seed;
    for (int i = 0; i < s->count; i++) {
        if (s->interval_us > 0 && (s->burst <= 1 || i % s->burst == 0)) {
            int us = s->interval_us;
            if (s->jitter) us = (int)(rand_r(&seed) % (unsigned)(2 * s->interval_us + 1));
            pause_us(us);
        } else if (s->gap_us > 0) {
            pause_us(s->gap_us);
        }
        /* a: the sequence number; b: the post's time, so the receiver
         * measures post -> dispatch. A full endpoint refuses the post: the
         * producer waits and tries again (backpressure, never a drop). */
        for (;;) {
            int rc = botlish_event_post(s->endpoint, s->slot, s->gen, i, botlish_event_now());
            if (rc == 0) break;
            if (rc != -EAGAIN) goto done;
            __atomic_add_fetch(&synth_refusals, 1, __ATOMIC_RELAXED);
            pause_us(50);
        }
    }
done:
    free(s);
    return NULL;
}

/* A thread posting COUNT records to ENDPOINT tagged (SLOT, GEN): bursts of
 * BURST every INTERVAL_US (0: as fast as it can; JITTER 1: uniformly
 * 0..2*INTERVAL_US), GAP_US apart within a burst. */
int fx_synth(int endpoint, int slot, int gen, int count, int interval_us, int burst, int jitter, int gap_us) {
    if (nsynth == 16) return -1;
    synth_args *s = malloc(sizeof *s);
    *s = (synth_args){ endpoint, slot, gen, count, interval_us, burst, jitter, gap_us, (unsigned)(nsynth * 7919 + 17) };
    if (pthread_create(&synth_threads[nsynth], NULL, synth_main, s) != 0) return -1;
    nsynth++;
    return 0;
}

int fx_synth_join(void) {
    for (int i = 0; i < nsynth; i++) pthread_join(synth_threads[i], NULL);
    int n = nsynth;
    nsynth = 0;
    return n;
}

long long fx_synth_refusals(void) {
    return __atomic_load_n(&synth_refusals, __ATOMIC_RELAXED);
}

typedef struct { int endpoint, slot, gen, count; long long base; } burst_args;

static void *burst_main(void *p) {
    burst_args *s = p;
    for (int i = 0; i < s->count; i++) {
        for (;;) {
            int rc = botlish_event_post(s->endpoint, s->slot, s->gen, s->base + i, botlish_event_now());
            if (rc == 0) break;
            if (rc != -EAGAIN) goto done;
            __atomic_add_fetch(&synth_refusals, 1, __ATOMIC_RELAXED);
            pause_us(20);
        }
    }
done:
    free(s);
    return NULL;
}

/* A thread posting COUNT records (a: BASE + i) to ENDPOINT tagged (SLOT,
 * GEN) as fast as the endpoint takes them. */
int fx_burst(int endpoint, int slot, int gen, int count, long long base) {
    if (nsynth == 16) return -1;
    burst_args *s = malloc(sizeof *s);
    *s = (burst_args){ endpoint, slot, gen, count, base };
    if (pthread_create(&synth_threads[nsynth], NULL, burst_main, s) != 0) return -1;
    nsynth++;
    return 0;
}

/* ---------------------------------------------------------------------
 * A pumped source: the hybrid protocol (SDL's, in tests/event-loop/native/
 * sdl.c) without SDL. A thread appends stamped items to this queue (a: the
 * sequence number, b: the time it was produced) and wakes the loop
 * (botlish_event_wake) -- it never posts. The pump's check, on the loop's
 * thread, posts what the queue holds to the endpoint, so an item is late
 * exactly when a wake was lost. */

#define PUMPED_CAP 4096

static struct {
    pthread_mutex_t lock;
    long long a[PUMPED_CAP], b[PUMPED_CAP];
    int head, count;
    int endpoint, slot, gen, total, interval_us, burst, gap_us, pump, running;
    pthread_t thread;
} P = { .lock = PTHREAD_MUTEX_INITIALIZER, .pump = -1 };

static void pumped_check(void *user) {
    (void)user;
    pthread_mutex_lock(&P.lock);
    while (P.count > 0) {
        if (botlish_event_post(P.endpoint, P.slot, P.gen, P.a[P.head], P.b[P.head]) != 0) break;
        P.head = (P.head + 1) % PUMPED_CAP;
        P.count--;
    }
    pthread_mutex_unlock(&P.lock);
}

static void *pumped_main(void *arg) {
    (void)arg;
    for (int i = 0; i < P.total; i++) {
        pause_us(P.burst <= 1 || i % P.burst == 0 ? P.interval_us : P.gap_us);
        pthread_mutex_lock(&P.lock);
        if (P.count < PUMPED_CAP) {
            int tail = (P.head + P.count) % PUMPED_CAP;
            P.a[tail] = i;
            P.b[tail] = botlish_event_now();
            P.count++;
        }
        pthread_mutex_unlock(&P.lock);
        botlish_event_wake();
    }
    return NULL;
}

/* Start the pumped source: COUNT items for ENDPOINT tagged (SLOT, GEN), in
 * bursts of BURST every INTERVAL_US, GAP_US apart within a burst. LOOP
 * THREAD (it adds the pump). 0, or -1. */
int fx_pumped(int endpoint, int slot, int gen, int count, int interval_us, int burst, int gap_us) {
    if (P.running) return -1;
    P.head = P.count = 0;
    P.endpoint = endpoint;
    P.slot = slot;
    P.gen = gen;
    P.total = count;
    P.interval_us = interval_us;
    P.burst = burst;
    P.gap_us = gap_us;
    P.pump = botlish_event_add_pump(NULL, pumped_check, NULL);
    if (P.pump < 0) return -1;
    if (pthread_create(&P.thread, NULL, pumped_main, NULL) != 0) {
        botlish_event_remove_pump(P.pump);
        return -1;
    }
    P.running = 1;
    return 0;
}

/* Wait for the pumped source's thread and remove its pump. LOOP THREAD. */
int fx_pumped_join(void) {
    if (!P.running) return 0;
    pthread_join(P.thread, NULL);
    botlish_event_remove_pump(P.pump);
    P.running = 0;
    return 0;
}

/* Post one record from the calling thread (a task: posting never runs
 * Botlish code, so the record reaches the program in a later turn). */
int fx_post(int endpoint, int slot, int gen, long long a, long long b) {
    return botlish_event_post(endpoint, slot, gen, a, b);
}

/* ---------------------------------------------------------------------
 * The line protocol: "CMD ARG\n" lines on nonblocking TCP sockets the
 * program watches; parsed here on the loop's thread. A connection's bytes
 * are buffered here, so readiness of its socket says nothing about lines
 * already in the buffer: fx_next_line returns a buffered line first and
 * reads the socket only when none is complete. */

#define MAX_CONNS 256
#define LINE_BYTES 64

typedef struct {
    int fd, open, eof;
    char buf[LINE_BYTES];
    int len;
} fx_conn;

static fx_conn conns[MAX_CONNS];
static int nconns;
static long long cur_cmd, cur_arg;

/* A listening socket on 127.0.0.1 (any free port), nonblocking: its fd. */
int fx_listen(void) {
    int fd = socket(AF_INET, SOCK_STREAM | SOCK_NONBLOCK | SOCK_CLOEXEC, 0);
    if (fd < 0) return -errno;
    int one = 1;
    setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &one, sizeof one);
    struct sockaddr_in a = { .sin_family = AF_INET, .sin_port = 0, .sin_addr.s_addr = htonl(INADDR_LOOPBACK) };
    if (bind(fd, (struct sockaddr *)&a, sizeof a) < 0 || listen(fd, 64) < 0) {
        int e = errno;
        close(fd);
        return -e;
    }
    return fd;
}

int fx_port(int fd) {
    struct sockaddr_in a;
    socklen_t len = sizeof a;
    if (getsockname(fd, (struct sockaddr *)&a, &len) < 0) return -errno;
    return ntohs(a.sin_port);
}

/* Accept one connection: its id (>= 0), -EAGAIN when none is waiting. */
int fx_accept(int lfd) {
    if (nconns == MAX_CONNS) return -ENOSPC;
    int fd = accept4(lfd, NULL, NULL, SOCK_NONBLOCK | SOCK_CLOEXEC);
    if (fd < 0) return -errno;
    int one = 1;
    setsockopt(fd, IPPROTO_TCP, TCP_NODELAY, &one, sizeof one);
    fx_conn *c = &conns[nconns];
    memset(c, 0, sizeof *c);
    c->fd = fd;
    c->open = 1;
    return nconns++;
}

int fx_conn_fd(int conn) {
    return conn >= 0 && conn < nconns ? conns[conn].fd : -1;
}

/* The next line of CONN: 1 (fx_cmd, fx_arg read it), 0 when no complete
 * line is buffered and the socket has nothing now (wait for readiness), -1
 * at end of input. NAIVE 1 reads the socket only (the bug class the
 * buffered-lines test pins: lines already buffered are never returned
 * until more bytes arrive). */
int fx_next_line(int conn, int naive) {
    if (conn < 0 || conn >= nconns) return -1;
    fx_conn *c = &conns[conn];
    for (;;) {
        char *nl = naive ? NULL : memchr(c->buf, '\n', (size_t)c->len);
        if (nl) {
            *nl = 0;
            cur_cmd = 0;
            cur_arg = 0;
            sscanf(c->buf, "%lld %lld", &cur_cmd, &cur_arg);
            int used = (int)(nl - c->buf) + 1;
            memmove(c->buf, c->buf + used, (size_t)(c->len - used));
            c->len -= used;
            return 1;
        }
        if (c->eof || !c->open) return -1;
        ssize_t n = read(c->fd, c->buf + c->len, (size_t)(LINE_BYTES - 1 - c->len));
        if (n > 0) {
            c->len += (int)n;
            if (c->len >= LINE_BYTES - 1 && !memchr(c->buf, '\n', (size_t)c->len)) c->len = 0;
            if (naive) {
                /* The naive reader takes the first line of what it read and
                 * forgets to look at the rest until the socket is readable
                 * again. */
                char *first = memchr(c->buf, '\n', (size_t)c->len);
                if (first) {
                    *first = 0;
                    cur_cmd = 0;
                    cur_arg = 0;
                    sscanf(c->buf, "%lld %lld", &cur_cmd, &cur_arg);
                    int used = (int)(first - c->buf) + 1;
                    memmove(c->buf, c->buf + used, (size_t)(c->len - used));
                    c->len -= used;
                    return 1;
                }
            }
            continue;
        }
        if (n == 0) {
            c->eof = 1;
            return -1;
        }
        if (errno == EINTR) continue;
        if (errno == EAGAIN || errno == EWOULDBLOCK) return 0;
        c->eof = 1;
        return -1;
    }
}

long long fx_cmd(void) { return cur_cmd; }
long long fx_arg(void) { return cur_arg; }

int fx_send(int conn, long long value) {
    if (conn < 0 || conn >= nconns || !conns[conn].open) return -1;
    char text[32];
    int n = snprintf(text, sizeof text, "%lld\n", value);
    return (int)send(conns[conn].fd, text, (size_t)n, MSG_NOSIGNAL);
}

int fx_hangup(int conn) {
    if (conn < 0 || conn >= nconns || !conns[conn].open) return -1;
    shutdown(conns[conn].fd, SHUT_RDWR);
    close(conns[conn].fd);
    conns[conn].open = 0;
    return 0;
}

/* ---------------------------------------------------------------------
 * Test clients (threads) */

typedef struct {
    int port, id, pattern, lines, interval_us;
} client_args;

static pthread_t client_threads[64];
static int nclients;
static long long client_replies[64];

static void client_text(int fd, const char *text, int n) {
    int off = 0;
    while (off < n) {
        ssize_t w = send(fd, text + off, (size_t)(n - off), MSG_NOSIGNAL);
        if (w <= 0) return;
        off += (int)w;
    }
}

static void client_line(int fd, long long cmd, long long arg) {
    char text[48];
    int n = snprintf(text, sizeof text, "%lld %lld\n", cmd, arg);
    client_text(fd, text, n);
}

static void *client_main(void *p) {
    client_args *c = p;
    int fd = socket(AF_INET, SOCK_STREAM, 0);
    struct sockaddr_in a = { .sin_family = AF_INET, .sin_port = htons((uint16_t)c->port), .sin_addr.s_addr = htonl(INADDR_LOOPBACK) };
    if (connect(fd, (struct sockaddr *)&a, sizeof a) < 0) {
        close(fd);
        free(c);
        return NULL;
    }
    int one = 1;
    setsockopt(fd, IPPROTO_TCP, TCP_NODELAY, &one, sizeof one);
    struct timeval rcv = { 10, 0 };
    setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &rcv, sizeof rcv);
    long long lines = 0;
    char buf[4096];
    if (c->pattern == 2) {
        /* A burst: every line in one write, then wait for the replies
         * WITHOUT closing (no BYE until they came back). */
        char text[4096];
        int n = 0;
        for (int i = 0; i < c->lines && n < (int)sizeof text - 48; i++) {
            n += snprintf(text + n, sizeof text - (size_t)n, "2 %d\n", i);
        }
        client_text(fd, text, n);
        while (lines < c->lines) {
            ssize_t r = recv(fd, buf, sizeof buf, 0);
            if (r <= 0) break;
            for (ssize_t i = 0; i < r; i++) if (buf[i] == '\n') lines++;
        }
        client_line(fd, 9, 0);
    } else {
        if (c->pattern == 1) client_line(fd, 1, 3000);
        for (int i = 0; i < c->lines; i++) {
            if (c->interval_us > 0) pause_us(c->interval_us);
            /* The argument is the send time: the server measures the
             * network-to-handler latency. */
            client_line(fd, 2, botlish_event_now());
        }
        client_line(fd, 9, 0);
    }
    for (;;) {
        ssize_t r = recv(fd, buf, sizeof buf, 0);
        if (r <= 0) break;
        for (ssize_t i = 0; i < r; i++) if (buf[i] == '\n') lines++;
    }
    client_replies[c->id % 64] = lines;
    close(fd);
    free(c);
    return NULL;
}

/* Test client ID on its own thread, connecting to PORT. PATTERN 0: LINES
 * TALK lines INTERVAL_US apart, then BYE; 1: a long MOVE first; 2: LINES
 * lines in one write, the replies awaited before BYE. */
int fx_client(int port, int id, int pattern, int lines, int interval_us) {
    if (nclients == 64) return -1;
    client_args *c = malloc(sizeof *c);
    *c = (client_args){ port, id, pattern, lines, interval_us };
    if (pthread_create(&client_threads[nclients], NULL, client_main, c) != 0) return -1;
    nclients++;
    return 0;
}

/* Hang up every connection, then wait for every client to finish. */
int fx_clients_join(void) {
    for (int i = 0; i < nconns; i++) {
        if (conns[i].open) fx_hangup(i);
    }
    for (int i = 0; i < nclients; i++) pthread_join(client_threads[i], NULL);
    int n = nclients;
    nclients = 0;
    return n;
}

long long fx_client_replies(int id) { return client_replies[id % 64]; }

/* Burn the calling thread's CPU for US microseconds (a slow handler). */
int fx_spin(int us) {
    long long end = botlish_event_now() + us;
    volatile long long x = 0;
    while (botlish_event_now() < end) x++;
    return 0;
}
