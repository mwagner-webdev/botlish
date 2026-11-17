/* probe_bridge.c -- probe E of RN-OFFLINE-DOMAIN-ARCHITECTURE-CENSUS-
 * MILESTONE-1.md: the smallest host port a persistent Botlish service can be
 * driven through with nothing but existing mechanisms. Evidence, not a
 * product: the census's RN-ASYNC-BOTLISH-SERVICE-BRIDGE milestone designs
 * the real one.
 *
 * A port is a pair of bounded queues of byte messages, guarded by one mutex:
 *
 *   requests     host -> service. A host thread submits through a Botlish
 *                export (an instance on that thread calls pb_submit); each
 *                submission posts one record into the service VM's event
 *                loop (botlish_event_post2, ABI 2) once the service has
 *                attached its endpoint. The record only wakes the service:
 *                it takes every queued request (FIFO) by itself.
 *   completions  service -> host. The service completes a request with
 *                pb_complete; a host thread blocks in pb_wait (a condition
 *                variable, never a poll) through another export.
 *
 * No Botlish code ever runs on a thread that is not its VM's own: the host's
 * threads enter only their own instances, and the service's loop thread
 * takes and completes. Every function is called from Botlish (extern c fn);
 * the host never calls this file directly (its symbols are local to the
 * library). */
#include <errno.h>
#include <pthread.h>
#include <string.h>
#include <time.h>
#include "botlish_event_loop.h"

#define PORTS 4
#define REQUESTS 64
#define COMPLETIONS 1024
#define MESSAGE 4096

typedef struct {
    long long id;
    unsigned long length;
    char data[MESSAGE];
} message;

typedef struct {
    int used;
    int attached, loop, endpoint, slot, gen;
    long long next_id;
    message requests[REQUESTS];
    int rhead, rcount;
    message completions[COMPLETIONS];
    int chead, ccount;
    long long posts, refused;
    pthread_cond_t ready;
} port;

static pthread_mutex_t lock = PTHREAD_MUTEX_INITIALIZER;
static port ports[PORTS];

static port *find(int p) {
    if (p < 1 || p > PORTS || !ports[p - 1].used) return NULL;
    return &ports[p - 1];
}

/* A new port (1..PORTS), or -ENOSPC. */
int pb_open(void) {
    pthread_mutex_lock(&lock);
    for (int i = 0; i < PORTS; i++) {
        if (!ports[i].used) {
            memset(&ports[i], 0, sizeof ports[i]);
            ports[i].used = 1;
            ports[i].next_id = 1;
            pthread_cond_init(&ports[i].ready, NULL);
            pthread_mutex_unlock(&lock);
            return i + 1;
        }
    }
    pthread_mutex_unlock(&lock);
    return -ENOSPC;
}

static void wake_service(port *q) {
    if (!q->attached) return;
    int rc = botlish_event_post2(q->loop, q->endpoint, q->slot, q->gen, q->next_id, 0);
    if (rc == 0) q->posts++; else q->refused++;
    /* -EAGAIN: records are already waiting, and the service drains every
     * queued request per wake; -EPIPE: the service has gone. */
}

/* Queue BUF[0..N) as a request; its id (> 0), or -EAGAIN (full), -EINVAL. */
long long pb_submit(int p, const void *buf, unsigned long n) {
    pthread_mutex_lock(&lock);
    port *q = find(p);
    if (!q || n > MESSAGE) { pthread_mutex_unlock(&lock); return -EINVAL; }
    if (q->rcount == REQUESTS) { pthread_mutex_unlock(&lock); return -EAGAIN; }
    message *m = &q->requests[(q->rhead + q->rcount) % REQUESTS];
    m->id = q->next_id++;
    m->length = n;
    memcpy(m->data, buf, n);
    q->rcount++;
    long long id = m->id;
    wake_service(q);
    pthread_mutex_unlock(&lock);
    return id;
}

/* The service's endpoint: records go to LOOP's ENDPOINT for registration
 * (SLOT, GEN). Requests queued before it attached are announced now. */
int pb_attach(int p, int loop, int endpoint, int slot, int gen) {
    pthread_mutex_lock(&lock);
    port *q = find(p);
    if (!q) { pthread_mutex_unlock(&lock); return -EINVAL; }
    q->attached = 1; q->loop = loop; q->endpoint = endpoint; q->slot = slot; q->gen = gen;
    if (q->rcount > 0) wake_service(q);
    pthread_mutex_unlock(&lock);
    return 0;
}

/* The service has stopped taking requests: later submissions only queue. */
int pb_detach(int p) {
    pthread_mutex_lock(&lock);
    port *q = find(p);
    if (q) q->attached = 0;
    pthread_mutex_unlock(&lock);
    return q ? 0 : -EINVAL;
}

/* The id of the oldest queued request, or 0 when none is. */
long long pb_take_id(int p) {
    pthread_mutex_lock(&lock);
    port *q = find(p);
    long long id = (q && q->rcount > 0) ? q->requests[q->rhead].id : 0;
    pthread_mutex_unlock(&lock);
    return id;
}

/* Copy the oldest queued request into BUF (CAP bytes) and remove it: its
 * length, or -1 when none is queued, -EMSGSIZE when it does not fit. */
int pb_take(int p, void *buf, unsigned long cap) {
    pthread_mutex_lock(&lock);
    port *q = find(p);
    if (!q || q->rcount == 0) { pthread_mutex_unlock(&lock); return -1; }
    message *m = &q->requests[q->rhead];
    if (m->length > cap) { pthread_mutex_unlock(&lock); return -EMSGSIZE; }
    memcpy(buf, m->data, m->length);
    int n = (int) m->length;
    q->rhead = (q->rhead + 1) % REQUESTS;
    q->rcount--;
    pthread_mutex_unlock(&lock);
    return n;
}

/* Complete request ID with BUF[0..N): 0, or -EAGAIN (the host has not
 * taken COMPLETIONS completions yet: the probe sizes the queue so that it
 * never happens; a product needs flow control here), -EINVAL. */
int pb_complete(int p, long long id, const void *buf, unsigned long n) {
    pthread_mutex_lock(&lock);
    port *q = find(p);
    if (!q || n > MESSAGE) { pthread_mutex_unlock(&lock); return -EINVAL; }
    if (q->ccount == COMPLETIONS) { pthread_mutex_unlock(&lock); return -EAGAIN; }
    message *m = &q->completions[(q->chead + q->ccount) % COMPLETIONS];
    m->id = id;
    m->length = n;
    memcpy(m->data, buf, n);
    q->ccount++;
    pthread_cond_signal(&q->ready);
    pthread_mutex_unlock(&lock);
    return 0;
}

/* Block until a completion is waiting (its length) or TIMEOUT_MS pass
 * (-ETIMEDOUT). */
int pb_wait(int p, int timeout_ms) {
    struct timespec until;
    clock_gettime(CLOCK_REALTIME, &until);
    until.tv_sec += timeout_ms / 1000;
    until.tv_nsec += (long) (timeout_ms % 1000) * 1000000L;
    if (until.tv_nsec >= 1000000000L) { until.tv_sec++; until.tv_nsec -= 1000000000L; }
    pthread_mutex_lock(&lock);
    port *q = find(p);
    if (!q) { pthread_mutex_unlock(&lock); return -EINVAL; }
    while (q->ccount == 0) {
        if (pthread_cond_timedwait(&q->ready, &lock, &until) == ETIMEDOUT) {
            pthread_mutex_unlock(&lock);
            return -ETIMEDOUT;
        }
    }
    int n = (int) q->completions[q->chead].length;
    pthread_mutex_unlock(&lock);
    return n;
}

/* The id of the oldest waiting completion, or 0. */
long long pb_done_id(int p) {
    pthread_mutex_lock(&lock);
    port *q = find(p);
    long long id = (q && q->ccount > 0) ? q->completions[q->chead].id : 0;
    pthread_mutex_unlock(&lock);
    return id;
}

/* Copy the oldest waiting completion into BUF and remove it: its length,
 * or -1 when none waits, -EMSGSIZE when it does not fit. */
int pb_fetch(int p, void *buf, unsigned long cap) {
    pthread_mutex_lock(&lock);
    port *q = find(p);
    if (!q || q->ccount == 0) { pthread_mutex_unlock(&lock); return -1; }
    message *m = &q->completions[q->chead];
    if (m->length > cap) { pthread_mutex_unlock(&lock); return -EMSGSIZE; }
    memcpy(buf, m->data, m->length);
    int n = (int) m->length;
    q->chead = (q->chead + 1) % COMPLETIONS;
    q->ccount--;
    pthread_mutex_unlock(&lock);
    return n;
}

/* Records posted and refused (endpoint full or closed) so far. */
long long pb_posts(int p) {
    pthread_mutex_lock(&lock);
    port *q = find(p);
    long long n = q ? q->posts : -1;
    pthread_mutex_unlock(&lock);
    return n;
}
