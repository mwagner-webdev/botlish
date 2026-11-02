/* host.c -- Probe D of THREAD-ACTOR-ARCHITECTURE-CENSUS.md: a foreign host
 * (standing in for React Native's JS thread and its worker threads) that
 * talks to Botlish only through requests to a Botlish-OWNED thread.
 *
 *   botlish thread  pthread with a large stack (BOTLISH_THREAD_STACK, default
 *                   256 MiB). It alone creates the library instance, calls
 *                   it and destroys it: the instance's thread affinity
 *                   (WRONG-THREAD) is then a property the host cannot break.
 *   host threads    512 KiB stacks (a JS thread's). They never call the
 *                   instance: they queue a request and wait for its
 *                   completion (a promise's resolution, in a JS host).
 *
 * Nothing but C data crosses: the request's scalars and a copy of its
 * text; the reply's int, a copy of the str result (released with
 * actorlib_bytes_release on the Botlish thread), and a copy of the error's
 * identity and first int field.
 */
#define _GNU_SOURCE
#include <pthread.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include "actorlib.h"

enum { DEPTH = 1, GREET = 2, CHECKED = 3 };

typedef struct req {
    int kind;
    int64_t n;
    char text[64];
    int32_t status;
    int64_t result;
    char reply[128];
    char ident[64];
    int64_t field;
    int done;
    long long t_submit, t_done;
    pthread_mutex_t m;
    pthread_cond_t c;
    struct req *next;
} req;

static pthread_mutex_t qlock = PTHREAD_MUTEX_INITIALIZER;
static pthread_cond_t qcond = PTHREAD_COND_INITIALIZER;
static req *qhead, *qtail;
static int stopping;
static long long served, refused_after_stop;
static actorlib_instance *owned; /* only for the WRONG-THREAD negative */

static long long now_ns(void) {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (long long)ts.tv_sec * 1000000000LL + ts.tv_nsec;
}

static void complete(req *r) {
    pthread_mutex_lock(&r->m);
    r->t_done = now_ns();
    r->done = 1;
    pthread_cond_signal(&r->c);
    pthread_mutex_unlock(&r->m);
}

static void fill_error(req *r, actorlib_error **e) {
    const uint8_t *p; size_t l;
    if (*e == NULL) return;
    if (actorlib_error_identity(*e, &p, &l) == actorlib_STATUS_OK)
        snprintf(r->ident, sizeof r->ident, "%.*s", (int)l, (const char *)p);
    if (actorlib_error_field_count(*e) > 0) actorlib_error_field_int(*e, 0, &r->field);
    actorlib_error_release(e);
}

static void serve(actorlib_instance *in, req *r) {
    actorlib_error *e = NULL;
    switch (r->kind) {
    case DEPTH:
        r->status = actorlib_depth(in, r->n, &r->result, &e);
        break;
    case GREET: {
        actorlib_bytes b = {0};
        r->status = actorlib_greet(in, (const uint8_t *)r->text, strlen(r->text), &b, &e);
        if (r->status == actorlib_STATUS_OK) {
            snprintf(r->reply, sizeof r->reply, "%.*s", (int)b.len, (const char *)b.ptr);
            actorlib_bytes_release(&b);
        }
        break;
    }
    case CHECKED:
        r->status = actorlib_checked(in, r->n, &r->result, &e);
        break;
    }
    fill_error(r, &e);
    served++;
    complete(r);
}

static void *botlish_thread(void *arg) {
    (void)arg;
    actorlib_instance *in;
    actorlib_error *e = NULL;
    if (actorlib_create(&in, &e) != actorlib_STATUS_OK) {
        fprintf(stderr, "create failed\n");
        exit(1);
    }
    owned = in;
    for (;;) {
        pthread_mutex_lock(&qlock);
        while (qhead == NULL && !stopping) pthread_cond_wait(&qcond, &qlock);
        req *r = qhead;
        if (r != NULL) {
            qhead = r->next;
            if (qhead == NULL) qtail = NULL;
        }
        int stop = stopping && r == NULL;
        pthread_mutex_unlock(&qlock);
        if (stop) break;
        serve(in, r);
    }
    printf("botlish thread: destroy %d, served %lld\n", (int)actorlib_destroy(in), served);
    return NULL;
}

/* Queue R; 0 when queued, -1 when the Botlish thread is stopping (the
 * request completes at once as refused: a rejected promise). */
static int submit(req *r) {
    pthread_mutex_init(&r->m, NULL);
    pthread_cond_init(&r->c, NULL);
    r->done = 0;
    r->next = NULL;
    r->t_submit = now_ns();
    pthread_mutex_lock(&qlock);
    if (stopping) {
        refused_after_stop++;
        pthread_mutex_unlock(&qlock);
        r->status = -1;
        complete(r);
        return -1;
    }
    if (qtail) qtail->next = r; else qhead = r;
    qtail = r;
    pthread_cond_signal(&qcond);
    pthread_mutex_unlock(&qlock);
    return 0;
}

static void await(req *r) {
    pthread_mutex_lock(&r->m);
    while (!r->done) pthread_cond_wait(&r->c, &r->m);
    pthread_mutex_unlock(&r->m);
}

static req *call(int kind, int64_t n, const char *text) {
    req *r = calloc(1, sizeof *r);
    r->kind = kind;
    r->n = n;
    if (text) snprintf(r->text, sizeof r->text, "%s", text);
    submit(r);
    await(r);
    return r;
}

static void show(const char *what, req *r) {
    printf("%s: status %d", what, (int)r->status);
    if (r->status == actorlib_STATUS_OK) {
        if (r->kind == GREET) printf(" \"%s\"", r->reply); else printf(" %lld", (long long)r->result);
    } else if (r->ident[0]) {
        printf(" %s field %lld", r->ident, (long long)r->field);
    }
    printf("\n");
}

/* ---- the host's threads: 512 KiB stacks */

static void *host_main(void *arg) {
    (void)arg;
    req *r;
    show("depth 1000", r = call(DEPTH, 1000, NULL)); free(r);
    show("depth 1000000 (on the Botlish thread)", r = call(DEPTH, 1000000, NULL)); free(r);
    show("greet", r = call(GREET, 0, "host")); free(r);
    show("checked 21", r = call(CHECKED, 21, NULL)); free(r);
    show("checked -5", r = call(CHECKED, -5, NULL)); free(r);
    /* the instance belongs to the Botlish thread: a direct call is refused */
    int64_t out; actorlib_error *e = NULL;
    int32_t s = actorlib_depth(owned, 3, &out, &e);
    printf("direct call from a host thread: status %d", (int)s);
    if (e) { const uint8_t *p; size_t l; actorlib_error_identity(e, &p, &l); printf(" %.*s", (int)l, (const char *)p); actorlib_error_release(&e); }
    printf("\n");
    /* the host's own instance on its own 512 KiB stack: the library's
     * stack check refuses deep recursion, the instance goes on */
    actorlib_instance *mine;
    if (actorlib_create(&mine, &e) == actorlib_STATUS_OK) {
        s = actorlib_depth(mine, 1000000, &out, &e);
        printf("depth 1000000 on the host's 512 KiB thread: status %d", (int)s);
        if (e) { const uint8_t *p; size_t l; actorlib_error_identity(e, &p, &l); printf(" %.*s", (int)l, (const char *)p); actorlib_error_release(&e); }
        printf("\n");
        s = actorlib_depth(mine, 100, &out, &e);
        printf("then depth 100 on the same instance: status %d result %lld\n", (int)s, (long long)out);
        actorlib_destroy(mine);
    }
    return NULL;
}

typedef struct { int id; int count; long long total_ns, max_ns; long long sum; } load_t;

static void *host_load(void *arg) {
    load_t *l = arg;
    req r;
    for (int i = 0; i < l->count; i++) {
        memset(&r, 0, sizeof r);
        r.kind = CHECKED;
        r.n = i;
        submit(&r);
        await(&r);
        long long d = r.t_done - r.t_submit;
        l->total_ns += d;
        if (d > l->max_ns) l->max_ns = d;
        l->sum += r.result;
        pthread_mutex_destroy(&r.m);
        pthread_cond_destroy(&r.c);
    }
    return NULL;
}

static pthread_t start(void *(*f)(void *), void *arg, size_t stack) {
    pthread_attr_t a;
    pthread_t t;
    pthread_attr_init(&a);
    pthread_attr_setstacksize(&a, stack);
    if (pthread_create(&t, &a, f, arg) != 0) { perror("pthread_create"); exit(1); }
    pthread_attr_destroy(&a);
    return t;
}

int main(void) {
    size_t stack = 256u << 20;
    const char *env = getenv("BOTLISH_THREAD_STACK");
    if (env) stack = (size_t)strtoull(env, NULL, 10);
    pthread_t bt = start(botlish_thread, NULL, stack);
    while (__atomic_load_n(&owned, __ATOMIC_ACQUIRE) == NULL) sched_yield();

    pthread_t h = start(host_main, NULL, 512u << 10);
    pthread_join(h, NULL);

    for (int nthreads = 1; nthreads <= 4; nthreads *= 4) {
        load_t loads[4];
        pthread_t ts[4];
        int per = 20000 / nthreads;
        long long t0 = now_ns();
        for (int i = 0; i < nthreads; i++) {
            loads[i] = (load_t){.id = i, .count = per};
            ts[i] = start(host_load, &loads[i], 512u << 10);
        }
        long long total = 0, max = 0, sum = 0;
        for (int i = 0; i < nthreads; i++) {
            pthread_join(ts[i], NULL);
            total += loads[i].total_ns;
            if (loads[i].max_ns > max) max = loads[i].max_ns;
            sum += loads[i].sum;
        }
        long long wall = now_ns() - t0;
        printf("load: %d host threads x %d requests: sum %s, mean round trip %lld ns, max %lld ns, %lld requests/s\n",
               nthreads, per, sum == (long long)nthreads * per * (per - 1) ? "ok" : "WRONG",
               total / (nthreads * per), max, (long long)nthreads * per * 1000000000LL / wall);
    }

    /* shutdown: requests queued before the stop are served, later ones are
     * refused without touching the instance, and the instance is destroyed
     * on its own thread */
    req pending[3];
    for (int i = 0; i < 3; i++) { memset(&pending[i], 0, sizeof pending[i]); pending[i].kind = DEPTH; pending[i].n = 10; submit(&pending[i]); }
    pthread_mutex_lock(&qlock);
    stopping = 1;
    pthread_cond_signal(&qcond);
    pthread_mutex_unlock(&qlock);
    req late = {0};
    late.kind = DEPTH;
    late.n = 10;
    submit(&late);
    for (int i = 0; i < 3; i++) await(&pending[i]);
    await(&late);
    pthread_join(bt, NULL);
    printf("shutdown: pending served %d %d %d, late request status %d, refused after stop %lld\n",
           pending[0].status, pending[1].status, pending[2].status, (int)late.status, refused_after_stop);
    return 0;
}
