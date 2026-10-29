/* ticker.c -- a native event source for examples/event-loop/native: a
 * thread that posts COUNT records, one every INTERVAL microseconds, to an
 * endpoint of Botlish's Linux event-loop driver through its integration ABI
 * (botlish_event_loop.h). Record i carries a = i and b = the driver's
 * clock when it was posted. A full endpoint is backpressure: the thread
 * waits and posts again; a closed one ends it. The thread never runs
 * Botlish code -- posting only queues a record and wakes the loop. */
#include <errno.h>
#include <pthread.h>
#include <time.h>

#include "botlish_event_loop.h"

static struct {
    int endpoint, slot, gen, count, interval;
} job;
static pthread_t thread;
static int running;

static void pause_us(long us) {
    struct timespec t = { us / 1000000, (us % 1000000) * 1000 };
    nanosleep(&t, NULL);
}

static void *run(void *arg) {
    (void)arg;
    for (int i = 1; i <= job.count; i++) {
        pause_us(job.interval);
        int r;
        while ((r = botlish_event_post(job.endpoint, job.slot, job.gen, i, botlish_event_now())) == -EAGAIN) {
            pause_us(100);
        }
        if (r < 0) break;
    }
    return NULL;
}

/* Start posting to ENDPOINT, tagged (SLOT, GEN). 0, or -errno. */
int ticker_start(int endpoint, int slot, int gen, int count, int interval) {
    if (running) return -EBUSY;
    job.endpoint = endpoint;
    job.slot = slot;
    job.gen = gen;
    job.count = count;
    job.interval = interval;
    if (pthread_create(&thread, NULL, run, NULL) != 0) return -EAGAIN;
    running = 1;
    return 0;
}

/* Wait for the thread to finish. 0. */
int ticker_join(void) {
    if (running) {
        pthread_join(thread, NULL);
        running = 0;
    }
    return 0;
}
