/* xport.c -- Probe B of THREAD-ACTOR-ARCHITECTURE-CENSUS.md: a DISPOSABLE
 * cross-thread message transport over the Linux event loop's integration
 * ABI (botlish_event_loop.h, version 1).
 *
 * Producer threads never run Botlish code and never touch a Botlish heap.
 * A message is a record (four scalars, botlish_event_post) plus, optionally,
 * a byte payload the producer copies into this file's payload table. The
 * record's A names the table slot; the loop's thread later copies the
 * payload into a Botlish MutableBytes it allocated itself (xp_take, a
 * `write noescape` exposure: C-POINTER-BORROWING.md) and the slot is freed.
 * So the only thing that crosses threads is C memory owned by this file.
 *
 * Backpressure is visible twice: a full endpoint refuses a post (-EAGAIN;
 * the producer counts it and retries), and a full payload table makes the
 * producer wait on a condition variable (counted). A closed endpoint
 * (-EPIPE) stops its producer, which frees the payload it held.
 */
#define _GNU_SOURCE
#include <errno.h>
#include <pthread.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include "botlish_event_loop.h"

#define MAXP 16

typedef struct {
    int used;
    long long len;
    unsigned char *data;
} slot_t;

static pthread_mutex_t lock = PTHREAD_MUTEX_INITIALIZER;
static pthread_cond_t room = PTHREAD_COND_INITIALIZER;
static slot_t *table;
static int ntable;
static int *freelist;
static int nfree;
static long long inuse_max;
static volatile int stopping;

typedef struct {
    int endpoint, slot, gen, id, count, size, mode, delay_us;
    long long refusals, table_waits, posted, closed_at;
    pthread_t thread;
    int running;
} prod_t;

static prod_t P[MAXP];
static int np;

static long long now_us(void) {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (long long)ts.tv_sec * 1000000 + ts.tv_nsec / 1000;
}

int xp_init(int n) {
    pthread_mutex_lock(&lock);
    if (table == NULL) {
        table = calloc((size_t)n, sizeof(slot_t));
        freelist = malloc(sizeof(int) * (size_t)n);
        if (table == NULL || freelist == NULL) {
            pthread_mutex_unlock(&lock);
            return -ENOMEM;
        }
        ntable = n;
        for (int i = 0; i < n; i++) freelist[i] = n - 1 - i;
        nfree = n;
    }
    pthread_mutex_unlock(&lock);
    return 0;
}

/* A free slot (waits while the table is full); -1 when stopping. */
static int alloc_slot(prod_t *p) {
    pthread_mutex_lock(&lock);
    while (nfree == 0 && !stopping) {
        p->table_waits++;
        pthread_cond_wait(&room, &lock);
    }
    int i = -1;
    if (nfree > 0) {
        i = freelist[--nfree];
        table[i].used = 1;
        long long inuse = ntable - nfree;
        if (inuse > inuse_max) inuse_max = inuse;
    }
    pthread_mutex_unlock(&lock);
    return i;
}

static void free_slot(int i) {
    pthread_mutex_lock(&lock);
    if (i >= 0 && i < ntable && table[i].used) {
        free(table[i].data);
        table[i].data = NULL;
        table[i].len = 0;
        table[i].used = 0;
        freelist[nfree++] = i;
        pthread_cond_signal(&room);
    }
    pthread_mutex_unlock(&lock);
}

static void *producer(void *arg) {
    prod_t *p = arg;
    for (long long seq = 0; seq < p->count && !stopping; seq++) {
        int idx = 0;
        if (p->mode != 0) {
            idx = alloc_slot(p);
            if (idx < 0) break;
            unsigned char *buf = malloc((size_t)p->size + 1);
            if (p->mode == 1) {
                /* text: "p<ID> seq <SEQ>|" then 'x' up to SIZE bytes */
                int n = snprintf((char *)buf, (size_t)p->size + 1, "p%d seq %lld|", p->id, seq);
                for (int k = n; k < p->size; k++) buf[k] = 'x';
            } else {
                for (int k = 0; k < p->size; k++) buf[k] = (unsigned char)((seq + k) & 255);
            }
            pthread_mutex_lock(&lock);
            table[idx].data = buf;
            table[idx].len = p->size;
            pthread_mutex_unlock(&lock);
        }
        long long a = (long long)idx | ((long long)p->id << 20) | (seq << 28);
        for (;;) {
            int r = botlish_event_post(p->endpoint, p->slot, p->gen, a, now_us());
            if (r == 0) {
                p->posted++;
                break;
            }
            if (r == -EAGAIN && !stopping) {
                p->refusals++;
                usleep(20);
                continue;
            }
            /* -EPIPE (closed) or stopping: the message is not sent */
            if (p->mode != 0) free_slot(idx);
            p->closed_at = seq;
            return NULL;
        }
        if (p->delay_us > 0) usleep((useconds_t)p->delay_us);
    }
    return NULL;
}

int xp_start(int endpoint, int slot, int gen, int id, int count, int size, int mode, int delay_us) {
    if (np >= MAXP || id < 0 || id > 255) return -EINVAL;
    prod_t *p = &P[np];
    memset(p, 0, sizeof *p);
    p->endpoint = endpoint; p->slot = slot; p->gen = gen; p->id = id;
    p->count = count; p->size = size; p->mode = mode; p->delay_us = delay_us;
    p->closed_at = -1;
    if (pthread_create(&p->thread, NULL, producer, p) != 0) return -1;
    p->running = 1;
    np++;
    return np - 1;
}

long long xp_length(int idx) {
    pthread_mutex_lock(&lock);
    long long n = (idx >= 0 && idx < ntable && table[idx].used) ? table[idx].len : -1;
    pthread_mutex_unlock(&lock);
    return n;
}

/* Copy slot IDX's payload into BUF (CAP bytes: a Botlish MutableBytes
 * exposed for this call only) and free the slot. Returns the bytes copied,
 * -1 for a slot that holds nothing. */
long long xp_take(int idx, unsigned char *buf, long long cap) {
    pthread_mutex_lock(&lock);
    if (idx < 0 || idx >= ntable || !table[idx].used) {
        pthread_mutex_unlock(&lock);
        return -1;
    }
    long long n = table[idx].len < cap ? table[idx].len : cap;
    memcpy(buf, table[idx].data, (size_t)n);
    pthread_mutex_unlock(&lock);
    free_slot(idx);
    return n;
}

int xp_join(void) {
    int joined = 0;
    for (int i = 0; i < np; i++) {
        if (P[i].running) {
            pthread_join(P[i].thread, NULL);
            P[i].running = 0;
            joined++;
        }
    }
    return joined;
}

/* Ask every producer to stop (they finish the post in hand). */
int xp_stop(void) {
    pthread_mutex_lock(&lock);
    stopping = 1;
    pthread_cond_broadcast(&room);
    pthread_mutex_unlock(&lock);
    return 0;
}

/* Free every payload still in the table (messages posted but never taken,
 * e.g. discarded by close_endpoint): how many. */
int xp_discard(void) {
    int n = 0;
    for (int i = 0; i < ntable; i++) {
        if (table[i].used) {
            free_slot(i);
            n++;
        }
    }
    return n;
}

long long xp_stat(int producer_index, int what) {
    if (producer_index < 0 || producer_index >= np) {
        if (what == 9) return inuse_max;
        return -1;
    }
    prod_t *p = &P[producer_index];
    switch (what) {
    case 0: return p->posted;
    case 1: return p->refusals;
    case 2: return p->table_waits;
    case 3: return p->closed_at;
    default: return -1;
    }
}

long long xp_now(void) { return now_us(); }
