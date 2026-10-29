/* event_loop_linux.c -- the native adapter of Botlish's Linux event-loop
 * driver (packages/event_loop_linux; EVENT-LOOP-MILESTONE-1.md, "Linux
 * driver"): what std::event_loop's Driver contract needs from Linux, behind
 * C functions of scalars only, and the integration ABI native libraries post
 * through (botlish_event_loop.h).
 *
 *   clock      CLOCK_MONOTONIC, microseconds                     evl_now
 *   waiting    one epoll instance; epoll_pwait2 (microsecond timeout,
 *              epoll_pwait's milliseconds rounded up where the kernel lacks
 *              it) for readiness, a wakeup or a deadline            evl_block
 *   wakeups    one eventfd, readable while a wakeup is owed: a post or a
 *              wake from any thread before or during the sleep is never lost
 *              (the counter keeps it until the loop reads it, and the loop
 *              checks the posted endpoints after resetting it, before it
 *              sleeps)                                botlish_event_post, _wake
 *   endpoints  per-source bounded record rings (a mutex-guarded FIFO each):
 *              a full endpoint refuses a post (-EAGAIN), so a flooding
 *              producer fills its own ring and never another's
 *   watches    descriptor readiness (EPOLLONESHOT): one coalesced readiness
 *              record per arming, re-armed when the program wants more --
 *              the program reads the descriptor itself, so a byte stream
 *              stays the kernel's and backpressure reaches the peer
 *   pumps      prepare/check hooks of libraries that can neither post from
 *              a thread nor be watched (botlish_event_loop.h)
 *   records    (slot, gen, a, b), handed to the scheduler round-robin over
 *              the sources that have one: one record per source in turn, a
 *              source's records in order; a held source (evl_hold) gives
 *              nothing until released (evl_release)
 *
 * Everything here runs on the loop's thread except botlish_event_post and
 * botlish_event_wake, which any thread may call; they touch only the
 * endpoint rings and the pending list, under one mutex, and the eventfd. No
 * Botlish code ever runs in this file, and nothing it hands Botlish refers
 * to memory of its own.
 *
 * One driver per process (Botlish's scheduler is thread-local and a program
 * has one main thread).
 *
 * Fault injection (tests only): BOTLISH_EVENT_LOOP_FAULT=lost-wakeup selects
 * a deliberately wrong wakeup protocol -- a post signals the eventfd only if
 * the loop has announced it is about to sleep, with the classic race
 * between the loop's emptiness check and its announcement -- so the
 * lost-wakeup tests can show they detect a lost wakeup (a positive
 * control).
 */
#define _GNU_SOURCE
#include "botlish_event_loop.h"

#include <errno.h>
#include <pthread.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <sys/epoll.h>
#include <sys/eventfd.h>
#include <sys/resource.h>
#include <time.h>
#include <unistd.h>

#define MAX_ENDPOINTS 256
#define MAX_WATCHES 4096
#define MAX_PUMPS 16
#define MAX_SOURCES (MAX_ENDPOINTS + MAX_WATCHES)
#define EPOLL_BATCH 64

typedef struct {
    int slot, gen;
    long long a, b;
} evl_rec;

typedef struct {
    /* guarded by E.lock */
    int open;
    evl_rec *items;
    int cap, head, count, max;
    int marked;            /* in the pending list or the rotation */
    long long posts, refused;
    /* the loop's thread */
    int rotating, paused, held;
    evl_rec held_rec;
} evl_endpoint;

typedef struct {
    int used, fd, slot, gen, interest, armed;
    int ready;
    long long ready_events;
    int rotating, paused, held;
    evl_rec held_rec;
} evl_watch_t;

typedef struct {
    botlish_event_prepare_fn prepare;
    botlish_event_check_fn check;
    void *user;
    int used;
} evl_pump;

/* Counters (evl_stat). */
enum {
    ST_BLOCKS, ST_SLEEPS, ST_POLL_SYSCALLS, ST_POLLS_SKIPPED, ST_WAKEUPS, ST_SPURIOUS,
    ST_TIMEOUTS, ST_POSTS, ST_REFUSED, ST_TAKEN, ST_HOLDS, ST_RELEASES, ST_WATCH_EVENTS,
    ST_EVENTFD_WRITES, ST_RING_MAX, ST_PUMP_CHECKS, ST_DISCARDED, ST_COUNT
};

static struct {
    int opened, epfd, wakefd, fault_lost_wakeup;
    pthread_mutex_t lock;
    evl_endpoint eps[MAX_ENDPOINTS];
    int pending[MAX_ENDPOINTS];  /* endpoints with new records (guarded) */
    int npending;
    int sleeping;                /* the lost-wakeup fault's announcement (guarded) */
    evl_watch_t watches[MAX_WATCHES];
    int nwatches, armed_watches;
    evl_pump pumps[MAX_PUMPS];
    int rot[MAX_SOURCES + 1];    /* the rotation: a ring of source ids */
    int rot_head, rot_count;
    int reset_owed;              /* the eventfd may be signalled from polls we skipped */
    evl_rec cur;
    int cur_source;
    long long stats[ST_COUNT];
} E = { .epfd = -1, .wakefd = -1, .lock = PTHREAD_MUTEX_INITIALIZER, .cur_source = -1 };

long long botlish_event_now(void) {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (long long)ts.tv_sec * 1000000LL + ts.tv_nsec / 1000;
}

long long evl_now(void) {
    return botlish_event_now();
}

long long evl_cpu_us(void) {
    struct rusage u;
    getrusage(RUSAGE_SELF, &u);
    return (long long)(u.ru_utime.tv_sec + u.ru_stime.tv_sec) * 1000000LL + u.ru_utime.tv_usec + u.ru_stime.tv_usec;
}

long long evl_stat(int i) {
    if (i < 0 || i >= ST_COUNT) return -1;
    return __atomic_load_n(&E.stats[i], __ATOMIC_RELAXED);
}

static void count(int i) {
    __atomic_add_fetch(&E.stats[i], 1, __ATOMIC_RELAXED);
}

/* ---------------------------------------------------------------------
 * The rotation (the loop's thread). */

static void rot_push(int source) {
    E.rot[(E.rot_head + E.rot_count) % (MAX_SOURCES + 1)] = source;
    E.rot_count++;
}

static int rot_pop(void) {
    if (E.rot_count == 0) return -1;
    int s = E.rot[E.rot_head];
    E.rot_head = (E.rot_head + 1) % (MAX_SOURCES + 1);
    E.rot_count--;
    return s;
}

/* Move the endpoints producers marked into the rotation. */
static void drain_pending(void) {
    pthread_mutex_lock(&E.lock);
    for (int i = 0; i < E.npending; i++) {
        evl_endpoint *ep = &E.eps[E.pending[i]];
        if (ep->open && !ep->paused && !ep->rotating) {
            ep->rotating = 1;
            rot_push(E.pending[i]);
        }
    }
    E.npending = 0;
    pthread_mutex_unlock(&E.lock);
}

static void signal_wakefd(void) {
    uint64_t one = 1;
    if (E.wakefd >= 0 && write(E.wakefd, &one, sizeof one) == sizeof one) count(ST_EVENTFD_WRITES);
}

static void reset_wakefd(void) {
    uint64_t n;
    if (read(E.wakefd, &n, sizeof n) == sizeof n) count(ST_WAKEUPS);
}

/* ---------------------------------------------------------------------
 * Opening and closing */

/* Open the driver. 0, or -errno (-EBUSY: already open). */
int evl_open(int flags) {
    (void)flags;
    if (E.opened) return -EBUSY;
    const char *fault = getenv("BOTLISH_EVENT_LOOP_FAULT");
    E.fault_lost_wakeup = fault && strcmp(fault, "lost-wakeup") == 0;
    E.epfd = epoll_create1(EPOLL_CLOEXEC);
    if (E.epfd < 0) return -errno;
    E.wakefd = eventfd(0, EFD_NONBLOCK | EFD_CLOEXEC);
    if (E.wakefd < 0) {
        int e = errno;
        close(E.epfd);
        E.epfd = -1;
        return -e;
    }
    struct epoll_event ev = { .events = EPOLLIN, .data.u64 = UINT64_MAX };
    if (epoll_ctl(E.epfd, EPOLL_CTL_ADD, E.wakefd, &ev) < 0) {
        int e = errno;
        close(E.wakefd);
        close(E.epfd);
        E.wakefd = E.epfd = -1;
        return -e;
    }
    E.opened = 1;
    return 0;
}

/* Close the driver: every endpoint refuses later posts (-EPIPE), every
 * watch is dropped (its descriptor stays the program's). 0. */
int evl_close(void) {
    if (!E.opened) return 0;
    pthread_mutex_lock(&E.lock);
    for (int i = 0; i < MAX_ENDPOINTS; i++) {
        evl_endpoint *ep = &E.eps[i];
        if (ep->open) {
            E.stats[ST_DISCARDED] += ep->count;
            free(ep->items);
            memset(ep, 0, sizeof *ep);
        }
    }
    E.npending = 0;
    E.opened = 0;
    pthread_mutex_unlock(&E.lock);
    memset(E.watches, 0, sizeof E.watches);
    E.nwatches = E.armed_watches = 0;
    E.rot_head = E.rot_count = 0;
    close(E.wakefd);
    close(E.epfd);
    E.wakefd = E.epfd = -1;
    return 0;
}

/* ---------------------------------------------------------------------
 * Endpoints */

/* A new endpoint holding at most CAPACITY records. Its id (>= 0), or
 * -errno (-ENOSPC: every endpoint is in use). */
int evl_endpoint_open(int capacity) {
    if (!E.opened) return -EPIPE;
    if (capacity < 1) capacity = 1;
    evl_rec *items = calloc((size_t)capacity, sizeof(evl_rec));
    if (!items) return -ENOMEM;
    pthread_mutex_lock(&E.lock);
    for (int i = 0; i < MAX_ENDPOINTS; i++) {
        evl_endpoint *ep = &E.eps[i];
        if (!ep->open && !ep->rotating) {
            memset(ep, 0, sizeof *ep);
            ep->open = 1;
            ep->items = items;
            ep->cap = capacity;
            pthread_mutex_unlock(&E.lock);
            return i;
        }
    }
    pthread_mutex_unlock(&E.lock);
    free(items);
    return -ENOSPC;
}

/* Close endpoint ID: its undelivered records are discarded (the number is
 * returned), later posts fail with -EPIPE. */
int evl_endpoint_close(int id) {
    if (id < 0 || id >= MAX_ENDPOINTS) return -EINVAL;
    pthread_mutex_lock(&E.lock);
    evl_endpoint *ep = &E.eps[id];
    if (!ep->open) {
        pthread_mutex_unlock(&E.lock);
        return -EINVAL;
    }
    int discarded = ep->count + (ep->held ? 1 : 0);
    E.stats[ST_DISCARDED] += discarded;
    free(ep->items);
    ep->items = NULL;
    ep->open = 0;
    ep->count = 0;
    ep->held = 0;
    ep->paused = 0;
    ep->marked = 0;
    pthread_mutex_unlock(&E.lock);
    return discarded;
}

/* Records waiting in endpoint ID (held ones included), or -EINVAL. */
int evl_endpoint_count(int id) {
    if (id < 0 || id >= MAX_ENDPOINTS) return -EINVAL;
    pthread_mutex_lock(&E.lock);
    evl_endpoint *ep = &E.eps[id];
    int n = ep->open ? ep->count + (ep->held ? 1 : 0) : -EINVAL;
    pthread_mutex_unlock(&E.lock);
    return n;
}

int botlish_event_post(int endpoint, int slot, int gen, long long a, long long b) {
    if (endpoint < 0 || endpoint >= MAX_ENDPOINTS) return -EINVAL;
    pthread_mutex_lock(&E.lock);
    evl_endpoint *ep = &E.eps[endpoint];
    if (!ep->open) {
        pthread_mutex_unlock(&E.lock);
        return E.opened ? -EINVAL : -EPIPE;
    }
    if (ep->count == ep->cap) {
        ep->refused++;
        pthread_mutex_unlock(&E.lock);
        count(ST_REFUSED);
        return -EAGAIN;
    }
    ep->items[(ep->head + ep->count) % ep->cap] = (evl_rec){ slot, gen, a, b };
    ep->count++;
    ep->posts++;
    if (ep->count > ep->max) ep->max = ep->count;
    if (ep->count > E.stats[ST_RING_MAX]) E.stats[ST_RING_MAX] = ep->count;
    int signal = 0;
    if (!ep->marked) {
        ep->marked = 1;
        E.pending[E.npending++] = endpoint;
        /* One wakeup per batch: the empty -> non-empty edge of the list. */
        signal = E.npending == 1;
    }
    int sleeping = E.sleeping;
    pthread_mutex_unlock(&E.lock);
    count(ST_POSTS);
    if (E.fault_lost_wakeup) {
        if (sleeping) signal_wakefd();       /* WRONG: misses the race window */
    } else if (signal) {
        signal_wakefd();
    }
    return 0;
}

int botlish_event_wake(void) {
    if (!E.opened) return -EPIPE;
    signal_wakefd();
    return 0;
}

/* ---------------------------------------------------------------------
 * Watches */

static uint32_t interest_bits(int interest) {
    uint32_t bits = EPOLLONESHOT | EPOLLRDHUP;
    if (interest & 1) bits |= EPOLLIN;
    if (interest & 2) bits |= EPOLLOUT;
    return bits;
}

/* Watch descriptor FD for INTEREST (1 readable, 2 writable, 3 both): one
 * readiness record (SLOT, GEN, events, fd) per arming; armed now. Its id,
 * or -errno. The descriptor stays the caller's: never closed here. */
int evl_watch(int fd, int interest, int slot, int gen) {
    if (!E.opened) return -EPIPE;
    for (int i = 0; i < MAX_WATCHES; i++) {
        evl_watch_t *w = &E.watches[i];
        if (!w->used && !w->rotating) {
            memset(w, 0, sizeof *w);
            struct epoll_event ev = { .events = interest_bits(interest), .data.u64 = (uint64_t)i };
            if (epoll_ctl(E.epfd, EPOLL_CTL_ADD, fd, &ev) < 0) return -errno;
            w->used = 1;
            w->fd = fd;
            w->slot = slot;
            w->gen = gen;
            w->interest = interest;
            w->armed = 1;
            E.nwatches++;
            E.armed_watches++;
            return i;
        }
    }
    return -ENOSPC;
}

/* Whether watch ID is the one tagged (SLOT, GEN): a stale Watch value never
 * reaches a watch that reused its id. */
static evl_watch_t *watch_of(int id, int slot, int gen) {
    if (id < 0 || id >= MAX_WATCHES) return NULL;
    evl_watch_t *w = &E.watches[id];
    if (!w->used || w->slot != slot || w->gen != gen) return NULL;
    return w;
}

/* Arm watch ID (tagged SLOT, GEN) again, after its readiness record was
 * taken. 0, or -errno (-EINVAL: no such watch). */
int evl_watch_rearm(int id, int slot, int gen) {
    evl_watch_t *w = watch_of(id, slot, gen);
    if (!w) return -EINVAL;
    if (w->armed || w->ready) return 0;
    struct epoll_event ev = { .events = interest_bits(w->interest), .data.u64 = (uint64_t)id };
    if (epoll_ctl(E.epfd, EPOLL_CTL_MOD, w->fd, &ev) < 0) return -errno;
    w->armed = 1;
    E.armed_watches++;
    return 0;
}

/* Stop watching (watch ID, tagged SLOT, GEN): the descriptor leaves the
 * epoll set (it stays open: close it after this, never before -- a closed
 * descriptor's number may already name another file) and a readiness record
 * not yet taken is dropped. 0, or -EINVAL. */
int evl_watch_close(int id, int slot, int gen) {
    evl_watch_t *w = watch_of(id, slot, gen);
    if (!w) return -EINVAL;
    epoll_ctl(E.epfd, EPOLL_CTL_DEL, w->fd, NULL);
    if (w->armed) E.armed_watches--;
    E.nwatches--;
    w->used = 0;
    w->ready = 0;
    w->held = 0;
    w->paused = 0;
    return 0;
}

/* ---------------------------------------------------------------------
 * Pumps */

int botlish_event_add_pump(botlish_event_prepare_fn prepare, botlish_event_check_fn check, void *user) {
    for (int i = 0; i < MAX_PUMPS; i++) {
        if (!E.pumps[i].used) {
            E.pumps[i] = (evl_pump){ prepare, check, user, 1 };
            return i;
        }
    }
    return -ENOSPC;
}

int botlish_event_remove_pump(int pump) {
    if (pump < 0 || pump >= MAX_PUMPS || !E.pumps[pump].used) return -EINVAL;
    E.pumps[pump].used = 0;
    return 0;
}

static void run_checks(void) {
    for (int i = 0; i < MAX_PUMPS; i++) {
        if (E.pumps[i].used && E.pumps[i].check) {
            count(ST_PUMP_CHECKS);
            E.pumps[i].check(E.pumps[i].user);
        }
    }
}

static long long run_prepares(long long deadline) {
    for (int i = 0; i < MAX_PUMPS; i++) {
        if (E.pumps[i].used && E.pumps[i].prepare) {
            long long d = E.pumps[i].prepare(E.pumps[i].user, deadline);
            if (d >= 0 && (deadline < 0 || d < deadline)) deadline = d;
        }
    }
    return deadline;
}

/* ---------------------------------------------------------------------
 * Waiting */

static int any_pumps(void) {
    for (int i = 0; i < MAX_PUMPS; i++) if (E.pumps[i].used) return 1;
    return 0;
}

static void ready_watch(int id, uint32_t events) {
    evl_watch_t *w = &E.watches[id];
    if (!w->used) return;
    if (w->armed) {
        w->armed = 0;
        E.armed_watches--;
    }
    long long bits = 0;
    if (events & EPOLLIN) bits |= 1;
    if (events & EPOLLOUT) bits |= 2;
    if (events & (EPOLLHUP | EPOLLRDHUP)) bits |= 4;
    if (events & EPOLLERR) bits |= 8;
    w->ready = 1;
    w->ready_events |= bits;
    count(ST_WATCH_EVENTS);
    if (!w->paused && !w->rotating) {
        w->rotating = 1;
        rot_push(MAX_ENDPOINTS + id);
    }
}

static int epoll_wait_us(struct epoll_event *events, long long timeout_us) {
    struct timespec ts, *tp = NULL;
    if (timeout_us >= 0) {
        ts.tv_sec = timeout_us / 1000000;
        ts.tv_nsec = (timeout_us % 1000000) * 1000;
        tp = &ts;
    }
    int n = epoll_pwait2(E.epfd, events, EPOLL_BATCH, tp, NULL);
    if (n < 0 && errno == ENOSYS) {
        /* Before Linux 5.11: milliseconds, rounded up (never early). */
        int ms = timeout_us < 0 ? -1 : (int)((timeout_us + 999) / 1000);
        n = epoll_wait(E.epfd, events, EPOLL_BATCH, ms);
    }
    return n;
}

/* Block until a record is available, a wakeup arrives or DEADLINE
 * (microseconds of evl_now's clock) passes; -1: no deadline; a deadline
 * not in the future, or records already available: do not sleep. Returns
 * the number of sources with a record, or -errno. */
int evl_block(long long deadline) {
    if (!E.opened) return -EPIPE;
    count(ST_BLOCKS);
    run_checks();
    deadline = run_prepares(deadline);
    long long timeout = -1;
    if (E.rot_count > 0) {
        timeout = 0;
    } else if (deadline >= 0) {
        timeout = deadline - botlish_event_now();
        if (timeout < 0) timeout = 0;
    }
    drain_pending();
    if (E.rot_count > 0) timeout = 0;
    if (timeout != 0) {
        if (E.fault_lost_wakeup) {
            /* WRONG: the endpoints were checked above; announce the sleep
             * only now, so a post in between signals nobody. */
            struct timespec gap = { 0, 200000 };   /* the race window, widened */
            nanosleep(&gap, NULL);
            pthread_mutex_lock(&E.lock);
            E.sleeping = 1;
            pthread_mutex_unlock(&E.lock);
        } else if (E.reset_owed) {
            /* The eventfd may hold signals from polls that skipped the
             * kernel: reset it, THEN look at the posted endpoints again, so
             * a post after the reset wakes the sleep below. */
            reset_wakefd();
            E.reset_owed = 0;
            drain_pending();
            if (E.rot_count > 0) timeout = 0;
        }
    }
    int n = 0;
    struct epoll_event events[EPOLL_BATCH];
    if (timeout == 0 && E.armed_watches == 0 && !E.fault_lost_wakeup) {
        /* A poll with nothing the kernel could report but the eventfd: the
         * posted endpoints were just looked at in memory. */
        count(ST_POLLS_SKIPPED);
        E.reset_owed = 1;
    } else {
        if (timeout == 0) count(ST_POLL_SYSCALLS); else count(ST_SLEEPS);
        n = epoll_wait_us(events, timeout);
        if (E.fault_lost_wakeup) {
            pthread_mutex_lock(&E.lock);
            E.sleeping = 0;
            pthread_mutex_unlock(&E.lock);
        }
        if (n < 0) {
            if (errno != EINTR) return -errno;
            n = 0;
        }
        if (n == 0 && timeout > 0) count(ST_TIMEOUTS);
    }
    int before = E.rot_count;
    for (int i = 0; i < n; i++) {
        if (events[i].data.u64 == UINT64_MAX) {
            reset_wakefd();
        } else {
            ready_watch((int)events[i].data.u64, events[i].events);
        }
    }
    drain_pending();
    if (any_pumps()) {
        run_checks();
        drain_pending();
    }
    if (n > 0 && E.rot_count == before) count(ST_SPURIOUS);
    return E.rot_count;
}

/* ---------------------------------------------------------------------
 * Records */

/* Make the next record current, round-robin over the sources that have
 * one; its slot, or -1 when none is available. */
int evl_take(void) {
    for (;;) {
        int s = rot_pop();
        if (s < 0) return -1;
        if (s < MAX_ENDPOINTS) {
            evl_endpoint *ep = &E.eps[s];
            ep->rotating = 0;
            if (ep->paused) continue;
            evl_rec rec;
            int more;
            pthread_mutex_lock(&E.lock);
            if (!ep->open) {
                pthread_mutex_unlock(&E.lock);
                continue;
            }
            if (ep->held) {
                rec = ep->held_rec;
                ep->held = 0;
            } else if (ep->count > 0) {
                rec = ep->items[ep->head];
                ep->head = (ep->head + 1) % ep->cap;
                ep->count--;
            } else {
                ep->marked = 0;
                pthread_mutex_unlock(&E.lock);
                continue;
            }
            more = ep->count > 0;
            if (!more) ep->marked = 0;
            pthread_mutex_unlock(&E.lock);
            if (more) {
                ep->rotating = 1;
                rot_push(s);
            }
            E.cur = rec;
            E.cur_source = s;
            count(ST_TAKEN);
            return rec.slot;
        }
        evl_watch_t *w = &E.watches[s - MAX_ENDPOINTS];
        w->rotating = 0;
        if (!w->used || w->paused) continue;
        if (w->held) {
            E.cur = w->held_rec;
            w->held = 0;
        } else if (w->ready) {
            E.cur = (evl_rec){ w->slot, w->gen, w->ready_events, w->fd };
            w->ready = 0;
            w->ready_events = 0;
        } else {
            continue;
        }
        E.cur_source = s;
        count(ST_TAKEN);
        return E.cur.slot;
    }
}

int evl_gen(void) { return E.cur.gen; }
long long evl_a(void) { return E.cur.a; }
long long evl_b(void) { return E.cur.b; }

/* The current record could not be accepted (a Reliable registration has
 * no room): keep it first in its source and take nothing more from that
 * source until evl_release(its slot). 0, or -EINVAL. */
int evl_hold(void) {
    int s = E.cur_source;
    if (s < 0) return -EINVAL;
    count(ST_HOLDS);
    if (s < MAX_ENDPOINTS) {
        evl_endpoint *ep = &E.eps[s];
        pthread_mutex_lock(&E.lock);
        if (ep->open) {
            ep->held = 1;
            ep->held_rec = E.cur;
            ep->paused = 1;
            ep->marked = 1;     /* producers leave it alone until released */
        }
        pthread_mutex_unlock(&E.lock);
    } else {
        evl_watch_t *w = &E.watches[s - MAX_ENDPOINTS];
        if (w->used) {
            w->held = 1;
            w->held_rec = E.cur;
            w->paused = 1;
        }
    }
    E.cur_source = -1;
    return 0;
}

/* Sources holding a record for SLOT may deliver again. The number of
 * sources released. */
int evl_release(int slot) {
    int released = 0;
    pthread_mutex_lock(&E.lock);
    for (int i = 0; i < MAX_ENDPOINTS; i++) {
        evl_endpoint *ep = &E.eps[i];
        if (ep->open && ep->paused && ep->held && ep->held_rec.slot == slot) {
            ep->paused = 0;
            ep->marked = 1;
            if (!ep->rotating) {
                ep->rotating = 1;
                rot_push(i);
            }
            released++;
        }
    }
    pthread_mutex_unlock(&E.lock);
    for (int i = 0; i < MAX_WATCHES; i++) {
        evl_watch_t *w = &E.watches[i];
        if (w->used && w->paused && w->held && w->held_rec.slot == slot) {
            w->paused = 0;
            if (!w->rotating) {
                w->rotating = 1;
                rot_push(MAX_ENDPOINTS + i);
            }
            released++;
        }
    }
    if (released) __atomic_add_fetch(&E.stats[ST_RELEASES], released, __ATOMIC_RELAXED);
    return released;
}
