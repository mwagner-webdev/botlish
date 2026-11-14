/* rlf_provider.c -- the fixture's optional provider (the package
 * `rlf_provider`; HTTP-MACOS-RUST-ARCHIVE-LINK-FEASIBILITY-MILESTONE-1.md):
 * the strong definition of rlfp_post, which the Rust unit's notify.c
 * reaches -- the event loop driver's botlish_event_post2, for the http
 * unit -- and what it recorded, for the Botlish program to read. A post
 * comes from the unit's own thread, so the record is behind a mutex. */
#include <pthread.h>

static pthread_mutex_t lock = PTHREAD_MUTEX_INITIALIZER;
static long long posts;
static long long total;
static long long tag_sum;

int rlfp_post(int tag, long long value) {
    pthread_mutex_lock(&lock);
    posts += 1;
    total += value;
    tag_sum += tag;
    pthread_mutex_unlock(&lock);
    return 0;
}

/* WHAT: 0 the posts, 1 the sum of their values, 2 the sum of their tags. */
long long rlfp_read(long long what) {
    long long v;
    pthread_mutex_lock(&lock);
    v = what == 0 ? posts : what == 1 ? total : what == 2 ? tag_sum : -1;
    pthread_mutex_unlock(&lock);
    return v;
}
