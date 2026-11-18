/* host.c -- probe E's host (RN-OFFLINE-DOMAIN-ARCHITECTURE-CENSUS-
 * MILESTONE-1.md): stands in for React Native. Three host threads, none of
 * which is a Botlish thread:
 *
 *   service  calls svc_main(2, {"svc", PORT}): the persistent service's VM
 *            is made, runs its loop and is dropped on this thread;
 *   client   its own instance; PINGS sequential round trips (submit, then
 *            block for the completion), timing each; then collects the
 *            main thread's burst and checks it arrived whole and in order;
 *   main     the "JavaScript thread": its own instance; opens the port,
 *            starts the others, submits BURST requests without waiting for
 *            any (retrying, with a short sleep, only when the port's request
 *            queue is full), then "stop"; checks thread affinity by having
 *            a fourth thread call through main's instance.
 *
 * Exit status 0 when every check holds. */
#include <errno.h>
#include <inttypes.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include "svc.h"

#define PINGS 200
#define BURST 500

static int64_t port;
static svc_instance *js;
static char port_text[32];
static int32_t service_status = -1;
static pthread_mutex_t m = PTHREAD_MUTEX_INITIALIZER;
static pthread_cond_t c = PTHREAD_COND_INITIALIZER;
static int pinged;
static int failures;

static double now_us(void) {
    struct timespec t;
    clock_gettime(CLOCK_MONOTONIC, &t);
    return t.tv_sec * 1e6 + t.tv_nsec / 1e3;
}

static void fail(const char *what) {
    fprintf(stderr, "FAIL %s\n", what);
    failures++;
}

static void identity(svc_error *e, char *out, size_t cap) {
    const uint8_t *p; size_t n;
    out[0] = 0;
    if (e && svc_error_identity(e, &p, &n) == 0) snprintf(out, cap, "%.*s", (int) n, (const char *) p);
}

static void *service(void *unused) {
    (void) unused;
    char *argv[] = {"svc", port_text, NULL};
    svc_error *e = NULL;
    service_status = svc_main(2, argv, &e);
    if (e) { char id[128]; identity(e, id, sizeof id); fprintf(stderr, "service error %s\n", id); svc_error_release(&e); }
    return NULL;
}

static int cmp(const void *a, const void *b) {
    double x = *(const double *) a, y = *(const double *) b;
    return x < y ? -1 : x > y;
}

/* The next completion's text into OUT; 0 on a timeout. */
static int next(svc_instance *in, char *out, size_t cap) {
    svc_bytes b = {0}; svc_error *e = NULL;
    if (svc_next_completion(in, port, 5000, &b, &e) != 0) { svc_error_release(&e); return 0; }
    snprintf(out, cap, "%.*s", (int) b.len, (const char *) b.ptr);
    svc_bytes_release(&b);
    return out[0] != 0;
}

static void *client(void *unused) {
    (void) unused;
    svc_instance *in = NULL; svc_error *e = NULL;
    if (svc_create(&in, &e) != 0) { fail("client create"); return NULL; }
    static double rtt[PINGS];
    char text[256], want[256];
    for (int i = 0; i < PINGS; i++) {
        char req[64]; int64_t id = 0;
        snprintf(req, sizeof req, "ping-%d", i);
        double t0 = now_us();
        if (svc_submit(in, port, (const uint8_t *) req, strlen(req), &id, &e) != 0 || id <= 0) { fail("ping submit"); break; }
        if (!next(in, text, sizeof text)) { fail("ping completion"); break; }
        rtt[i] = now_us() - t0;
        snprintf(want, sizeof want, "%" PRId64 " ok %d ping-%d", id, i + 1, i);
        if (strcmp(text, want) != 0) { fprintf(stderr, "got [%s] want [%s]\n", text, want); fail("ping text"); }
    }
    qsort(rtt, PINGS, sizeof rtt[0], cmp);
    printf("ping round trips: %d, median %.1f us, p99 %.1f us, max %.1f us\n",
           PINGS, rtt[PINGS / 2], rtt[PINGS * 99 / 100], rtt[PINGS - 1]);
    pthread_mutex_lock(&m); pinged = 1; pthread_cond_signal(&c); pthread_mutex_unlock(&m);
    int got = 0, in_order = 1, stopped = 0;
    double first = 0, last = 0;
    while (next(in, text, sizeof text)) {
        if (got == 0) first = now_us();
        last = now_us();
        if (strstr(text, " stopped")) { stopped = 1; break; }
        int64_t id; int rev, n;
        if (sscanf(text, "%" SCNd64 " ok %d pet-%d", &id, &rev, &n) != 3 || n != got || rev != PINGS + 1 + got) in_order = 0;
        got++;
    }
    printf("burst completions: %d of %d, in order: %s, stop acknowledged: %s, collected over %.1f ms\n",
           got, BURST, in_order ? "yes" : "no", stopped ? "yes" : "no", (last - first) / 1e3);
    if (got != BURST || !in_order || !stopped) fail("burst");
    if (svc_destroy(in) != 0) fail("client destroy");
    return NULL;
}

static void *intruder(void *unused) {
    (void) unused;
    int64_t id = 0; svc_error *e = NULL; char who[128];
    int32_t s = svc_submit(js, port, (const uint8_t *) "x", 1, &id, &e);
    identity(e, who, sizeof who);
    printf("submit through another thread's instance: status %d %s\n", s, who);
    if (s != svc_STATUS_INVOCATION || strcmp(who, "WRONG-THREAD") != 0) fail("affinity");
    svc_error_release(&e);
    return NULL;
}

int main(void) {
    svc_error *e = NULL;
    if (svc_create(&js, &e) != 0 || svc_open_port(js, &port, &e) != 0 || port <= 0) { fprintf(stderr, "no port\n"); return 1; }
    snprintf(port_text, sizeof port_text, "%" PRId64, port);
    pthread_t s, cl, x;
    pthread_create(&s, NULL, service, NULL);
    pthread_create(&cl, NULL, client, NULL);
    pthread_mutex_lock(&m); while (!pinged) pthread_cond_wait(&c, &m); pthread_mutex_unlock(&m);
    double worst = 0, t_all = now_us();
    int full = 0;
    for (int i = 0; i < BURST; i++) {
        char req[64]; int64_t id = 0;
        snprintf(req, sizeof req, "pet-%d", i);
        for (;;) {
            double t0 = now_us();
            if (svc_submit(js, port, (const uint8_t *) req, strlen(req), &id, &e) != 0) { fail("burst submit"); break; }
            double dt = now_us() - t0;
            if (dt > worst) worst = dt;
            if (id != -EAGAIN) break;
            full++;
            struct timespec pause = {0, 100000};
            nanosleep(&pause, NULL);
        }
    }
    printf("burst submitted: %d in %.1f ms, slowest submit %.1f us, refused while the queue was full: %d\n",
           BURST, (now_us() - t_all) / 1e3, worst, full);
    pthread_create(&x, NULL, intruder, NULL);
    pthread_join(x, NULL);
    int64_t id;
    if (svc_submit(js, port, (const uint8_t *) "stop", 4, &id, &e) != 0) fail("stop submit");
    pthread_join(cl, NULL);
    pthread_join(s, NULL);
    printf("service returned: %d\n", service_status);
    if (service_status != 0) fail("service status");
    if (svc_destroy(js) != 0) fail("main destroy");
    printf("%s\n", failures ? "FAILED" : "all checks hold");
    return failures != 0;
}
