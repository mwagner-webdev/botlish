/* provider.c -- a minimal provider of the event loop's native integration
 * point, botlish_event_post2 (packages/event_loop_linux/native/
 * botlish_event_loop.h, version 2: int botlish_event_post2(int loop, int
 * endpoint, int slot, int gen, long long a, long long b)), for
 * HTTP-MACOS-RUST-ARCHIVE-LINK-FEASIBILITY-MILESTONE-1.md: it records each
 * post instead of waking a loop, on every host (the Linux driver is
 * Linux's), so a program can tell whether the Rust unit's notification
 * object reached this definition or its own fallback.
 *
 * Its other functions are what a Botlish module calls (rustlink::provider):
 * a call of one pulls this object out of its archive, and with it the
 * definition -- a weak reference pulls no archive member, as the real
 * driver's module pulls its adapter. A post may come from any thread. */
#include <pthread.h>

static pthread_mutex_t lock = PTHREAD_MUTEX_INITIALIZER;
static long long posts;
static long long last[6];

int botlish_event_post2(int loop, int endpoint, int slot, int gen, long long a, long long b) {
    if (loop <= 0) {
        return -9; /* no such loop (the driver's -EBADF) */
    }
    pthread_mutex_lock(&lock);
    posts += 1;
    last[0] = loop;
    last[1] = endpoint;
    last[2] = slot;
    last[3] = gen;
    last[4] = a;
    last[5] = b;
    pthread_mutex_unlock(&lock);
    return 0;
}

long long rlp_posts(void) {
    pthread_mutex_lock(&lock);
    long long n = posts;
    pthread_mutex_unlock(&lock);
    return n;
}

long long rlp_last(long long field) {
    if (field < 0 || field > 5) {
        return -1;
    }
    pthread_mutex_lock(&lock);
    long long v = last[field];
    pthread_mutex_unlock(&lock);
    return v;
}
