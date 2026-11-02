/* host.c -- Probe E of THREAD-ACTOR-ARCHITECTURE-CENSUS.md: two Botlish VMs
 * on two OS threads exchanging copied messages.
 *
 * producer thread  its own instance of twovm; produce(seed) builds and
 *                  renders a value in ITS heap; the str result is copied
 *                  into a malloc'ed queue entry (C memory) and the
 *                  library's buffer released on the producer thread; it
 *                  also digests its own text, the checksum to compare.
 * consumer thread  its own instance; digest(text) of each entry: the
 *                  bytes are converted into a str of ITS heap at the call.
 * Nothing the collectors trace is shared: the queue holds C bytes.
 * Teardown: the consumer stops early; entries still queued are freed
 * after both instances are destroyed (no VM is alive to own them).
 */
#define _GNU_SOURCE
#include <pthread.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "twovm.h"

typedef struct entry { char *text; size_t len; int64_t expect; struct entry *next; } entry;
static pthread_mutex_t lock = PTHREAD_MUTEX_INITIALIZER;
static pthread_cond_t cv = PTHREAD_COND_INITIALIZER, room = PTHREAD_COND_INITIALIZER;
static entry *head, *tail;
static int queued, done_producing, consumer_stop;
static int MESSAGES = 400, ITEMS = 40, CONSUME = 300, CAP = 16;
static long long produced, consumed, mismatches, failures, full_waits;

static void *producer(void *arg) {
    (void)arg;
    twovm_instance *in; twovm_error *e = NULL;
    if (twovm_create(&in, &e) != twovm_STATUS_OK) { failures++; return NULL; }
    for (int i = 0; i < MESSAGES; i++) {
        twovm_bytes b = {0};
        if (twovm_produce(in, i, ITEMS, &b, &e) != twovm_STATUS_OK) { failures++; twovm_error_release(&e); continue; }
        int64_t h;
        if (twovm_digest(in, b.ptr, b.len, &h, &e) != twovm_STATUS_OK) { failures++; twovm_error_release(&e); }
        entry *x = malloc(sizeof *x);
        x->text = malloc(b.len);
        memcpy(x->text, b.ptr, b.len);
        x->len = b.len;
        x->expect = h;
        x->next = NULL;
        twovm_bytes_release(&b); /* the library's buffer, on its own thread */
        pthread_mutex_lock(&lock);
        while (queued >= CAP && !consumer_stop) { full_waits++; pthread_cond_wait(&room, &lock); }
        if (consumer_stop && queued >= CAP) {
            pthread_mutex_unlock(&lock);
            free(x->text); free(x);
            break;
        }
        if (tail) tail->next = x; else head = x;
        tail = x;
        queued++;
        produced++;
        pthread_cond_signal(&cv);
        pthread_mutex_unlock(&lock);
    }
    pthread_mutex_lock(&lock);
    done_producing = 1;
    pthread_cond_broadcast(&cv);
    pthread_mutex_unlock(&lock);
    printf("producer: destroy %d\n", (int)twovm_destroy(in));
    return NULL;
}

static void *consumer(void *arg) {
    (void)arg;
    twovm_instance *in; twovm_error *e = NULL;
    if (twovm_create(&in, &e) != twovm_STATUS_OK) { failures++; return NULL; }
    for (;;) {
        pthread_mutex_lock(&lock);
        while (head == NULL && !done_producing) pthread_cond_wait(&cv, &lock);
        if (head == NULL || consumed >= CONSUME) {
            consumer_stop = 1;
            pthread_cond_broadcast(&room);
            pthread_mutex_unlock(&lock);
            break;
        }
        entry *x = head;
        head = x->next;
        if (head == NULL) tail = NULL;
        queued--;
        pthread_cond_signal(&room);
        pthread_mutex_unlock(&lock);
        int64_t h;
        if (twovm_digest(in, (const uint8_t *)x->text, x->len, &h, &e) != twovm_STATUS_OK) { failures++; twovm_error_release(&e); }
        else if (h != x->expect) mismatches++;
        consumed++;
        free(x->text); free(x);
    }
    printf("consumer: destroy %d\n", (int)twovm_destroy(in));
    return NULL;
}

int main(int argc, char **argv) {
    if (argc > 1) MESSAGES = atoi(argv[1]);
    if (argc > 2) CONSUME = atoi(argv[2]);
    pthread_attr_t a;
    pthread_attr_init(&a);
    pthread_attr_setstacksize(&a, 64u << 20);
    pthread_t p, c;
    pthread_create(&p, &a, producer, NULL);
    pthread_create(&c, &a, consumer, NULL);
    pthread_join(c, NULL);
    pthread_join(p, NULL);
    int left = 0;
    while (head) { entry *x = head; head = x->next; free(x->text); free(x); left++; }
    printf("produced %lld, consumed %lld, checksum mismatches %lld, failed calls %lld, producer waits for room %lld, left in queue at teardown %d (freed as C memory)\n",
           produced, consumed, mismatches, failures, full_waits, left);
    return mismatches || failures ? 1 : 0;
}
