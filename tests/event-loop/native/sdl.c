/* sdl.c -- an SDL3 event source for the Linux driver of std::event_loop
 * (tests/event-loop-linux.test; EVENT-LOOP-EXPLORATION.md's evsdl.c on the
 * production integration ABI, botlish_event_loop.h). SDL is initialized for
 * events only (headless); its events come from other threads (a producer
 * pushing user events, SDL's own timer thread) -- a native callback on a
 * thread that is not the loop's.
 *
 * Four ways of coordinating SDL with the loop's one wait (evsdl_start's
 * MODE):
 *
 *   1 wakeup  an event FILTER (SDL calls it synchronously, on the pushing
 *             thread) copies the event into a record, posts it to the
 *             endpoint and drops it from SDL's queue. No polling.
 *   2 pump    a check hook moves SDL's queued events into the endpoint after
 *             every wake; SDL has no descriptor to wait on, so the prepare
 *             hook caps every sleep at CAP us (polling).
 *   3 hybrid  an event WATCH only wakes the loop (botlish_event_wake); the
 *             check hook moves the events, on the loop's thread, from SDL's
 *             queue (SDL's own bounded queue is the buffer).
 *   4 naive   the check hook alone, no cap, no wakeup: the negative control
 *             -- an event pushed while the loop sleeps waits for something
 *             else to wake it.
 *
 * Callbacks copy scalars and post; none runs Botlish code, nothing of SDL's
 * event survives the callback, and an event a Botlish task causes
 * (evsdl_push: SDL runs the filter and watch inside that call) reaches the
 * program in a later turn, never inside the task's segment. The filter's
 * answer (keep or drop) comes from a policy the program set beforehand
 * (evsdl_drop_codes_from), never from Botlish.
 */
#include "botlish_event_loop.h"

#include <SDL3/SDL.h>
#include <errno.h>
#include <stdatomic.h>
#include <stdint.h>
#include <stdlib.h>

enum { M_WAKEUP = 1, M_PUMP = 2, M_HYBRID = 3, M_NAIVE = 4 };

static struct {
    int mode, endpoint, slot, gen, started, cap_us, pump;
    SDL_ThreadID loop_thread;
    atomic_int in_call;
    int drop_from;
    atomic_llong callbacks, foreign_thread, nested, copied, dropped_by_policy, checks, refused, timer_callbacks;
} S = { .drop_from = 0x7fffffff, .pump = -1 };

static long long record_a(const SDL_Event *e) {
    return e->type == SDL_EVENT_USER ? (long long)e->user.code : -(long long)e->type;
}

static long long record_b(const SDL_Event *e) {
    return e->type == SDL_EVENT_USER ? (long long)(intptr_t)e->user.data1 : botlish_event_now();
}

static void note_callback(void) {
    atomic_fetch_add(&S.callbacks, 1);
    if (SDL_GetCurrentThreadID() != S.loop_thread) atomic_fetch_add(&S.foreign_thread, 1);
    if (atomic_load(&S.in_call)) atomic_fetch_add(&S.nested, 1);
}

static bool policy_drops(const SDL_Event *e) {
    return e->type == SDL_EVENT_USER && e->user.code >= S.drop_from;
}

/* Post, waiting while the endpoint is full (the loop applies backpressure;
 * an SDL callback that may not wait would drop by its own policy). */
static void post(const SDL_Event *e) {
    while (botlish_event_post(S.endpoint, S.slot, S.gen, record_a(e), record_b(e)) == -EAGAIN) {
        atomic_fetch_add(&S.refused, 1);
        SDL_DelayNS(50000);
    }
}

/* Mode 1: copy, post, and drop from SDL's queue. Any thread. */
static bool SDLCALL filter_wakeup(void *userdata, SDL_Event *e) {
    (void)userdata;
    note_callback();
    if (policy_drops(e)) {
        atomic_fetch_add(&S.dropped_by_policy, 1);
        return false;
    }
    if (e->type == SDL_EVENT_USER || e->type == SDL_EVENT_QUIT) {
        post(e);
        atomic_fetch_add(&S.copied, 1);
        return false;
    }
    return true;
}

/* Modes 2-4: the filter only applies the policy (an immediate answer). */
static bool SDLCALL filter_policy(void *userdata, SDL_Event *e) {
    (void)userdata;
    note_callback();
    if (policy_drops(e)) {
        atomic_fetch_add(&S.dropped_by_policy, 1);
        return false;
    }
    return true;
}

/* Mode 3: a watch (after queueing) that only wakes the loop. */
static bool SDLCALL watch_wake(void *userdata, SDL_Event *e) {
    (void)userdata;
    (void)e;
    botlish_event_wake();
    return true;
}

/* The check hook (modes 2-4): on the loop's thread, move SDL's queued
 * events into the endpoint while it has room. */
static void check_sdl(void *user) {
    (void)user;
    atomic_fetch_add(&S.checks, 1);
    SDL_PumpEvents();
    SDL_Event events[32];
    for (;;) {
        int n = SDL_PeepEvents(events, 32, SDL_PEEKEVENT, SDL_EVENT_FIRST, SDL_EVENT_LAST);
        if (n <= 0) break;
        int moved = 0;
        for (int i = 0; i < n; i++) {
            if (events[i].type == SDL_EVENT_USER || events[i].type == SDL_EVENT_QUIT) {
                if (botlish_event_post(S.endpoint, S.slot, S.gen, record_a(&events[i]), record_b(&events[i])) == -EAGAIN) {
                    atomic_fetch_add(&S.refused, 1);
                    break;
                }
                atomic_fetch_add(&S.copied, 1);
            }
            moved++;
        }
        /* Remove exactly what was posted (or skipped): the rest stays in
         * SDL's queue, its own bounded buffer, until the endpoint has room. */
        SDL_PeepEvents(events, moved, SDL_GETEVENT, SDL_EVENT_FIRST, SDL_EVENT_LAST);
        if (moved < n) break;
    }
}

static long long prepare_cap(void *user, long long deadline) {
    (void)user;
    long long cap = botlish_event_now() + S.cap_us;
    return (deadline < 0 || deadline > cap) ? cap : deadline;
}

/* Start SDL (events only) in MODE, its events posted to ENDPOINT tagged
 * (SLOT, GEN). CAP_US: mode 2's polling interval. 0, or -1 when SDL fails
 * to start, -2 when the driver has no room for the pump. */
int evsdl_start(int mode, int endpoint, int slot, int gen, int cap_us) {
    if (S.started) return 0;
    if (!SDL_Init(SDL_INIT_EVENTS)) return -1;
    S.mode = mode;
    S.endpoint = endpoint;
    S.slot = slot;
    S.gen = gen;
    S.cap_us = cap_us;
    S.loop_thread = SDL_GetCurrentThreadID();
    S.started = 1;
    switch (mode) {
    case M_WAKEUP:
        SDL_SetEventFilter(filter_wakeup, NULL);
        break;
    case M_PUMP:
        SDL_SetEventFilter(filter_policy, NULL);
        S.pump = botlish_event_add_pump(prepare_cap, check_sdl, NULL);
        break;
    case M_HYBRID:
        SDL_SetEventFilter(filter_policy, NULL);
        SDL_AddEventWatch(watch_wake, NULL);
        S.pump = botlish_event_add_pump(NULL, check_sdl, NULL);
        break;
    case M_NAIVE:
        SDL_SetEventFilter(filter_policy, NULL);
        S.pump = botlish_event_add_pump(NULL, check_sdl, NULL);
        break;
    }
    return mode != M_WAKEUP && S.pump < 0 ? -2 : 0;
}

int evsdl_drop_codes_from(int code) {
    S.drop_from = code;
    return 0;
}

/* Push a user event from the calling thread (a Botlish task: the filter and
 * the watch run synchronously inside this call -- a nested native
 * dispatch). */
int evsdl_push(int code) {
    SDL_Event e = { 0 };
    e.type = SDL_EVENT_USER;
    e.user.code = code;
    e.user.data1 = (void *)(intptr_t)botlish_event_now();
    atomic_store(&S.in_call, 1);
    bool ok = SDL_PushEvent(&e);
    atomic_store(&S.in_call, 0);
    return ok ? 0 : -1;
}

typedef struct { int count, interval_us, base; } producer_args;
static SDL_Thread *producers[8];
static int nproducers;

static int SDLCALL producer_main(void *p) {
    producer_args *a = p;
    unsigned seed = (unsigned)a->base * 2654435761u + 1;
    for (int i = 0; i < a->count; i++) {
        int us = a->interval_us ? (int)((unsigned)rand_r(&seed) % (unsigned)(2 * a->interval_us + 1)) : 0;
        if (us) SDL_DelayNS((Uint64)us * 1000);
        SDL_Event e = { 0 };
        e.type = SDL_EVENT_USER;
        e.user.code = a->base + i;
        e.user.data1 = (void *)(intptr_t)botlish_event_now();
        /* Pushed once: SDL_PushEvent returns false also when a filter
         * dropped the event (the policy, or mode 1's filter, which
         * consumes every event after copying it). */
        SDL_PushEvent(&e);
    }
    free(a);
    return 0;
}

/* A thread pushing COUNT user events (codes BASE..), jittered around
 * INTERVAL_US apart. */
int evsdl_producer(int count, int interval_us, int base) {
    if (nproducers == 8) return -1;
    producer_args *a = malloc(sizeof *a);
    *a = (producer_args){ count, interval_us, base };
    producers[nproducers] = SDL_CreateThread(producer_main, "evsdl-producer", a);
    return producers[nproducers] ? nproducers++ : -1;
}

int evsdl_producers_join(void) {
    for (int i = 0; i < nproducers; i++) SDL_WaitThread(producers[i], NULL);
    int n = nproducers;
    nproducers = 0;
    return n;
}

typedef struct { atomic_int left; int code; } timer_args;

static Uint32 SDLCALL timer_cb(void *userdata, SDL_TimerID id, Uint32 interval) {
    (void)id;
    timer_args *t = userdata;
    atomic_fetch_add(&S.timer_callbacks, 1);
    SDL_Event e = { 0 };
    e.type = SDL_EVENT_USER;
    e.user.code = t->code++;
    e.user.data1 = (void *)(intptr_t)botlish_event_now();
    SDL_PushEvent(&e);
    return atomic_fetch_sub(&t->left, 1) > 1 ? interval : 0;
}

/* SDL's own timer: COUNT callbacks on SDL's timer thread, MS apart, each
 * pushing a user event (codes BASE..). */
int evsdl_sdl_timer(int ms, int count, int base) {
    timer_args *t = malloc(sizeof *t);   /* lives as long as the process */
    atomic_init(&t->left, count);
    t->code = base;
    return SDL_AddTimer((Uint32)ms, timer_cb, t) ? 0 : -1;
}

long long evsdl_stat(int i) {
    switch (i) {
    case 0: return atomic_load(&S.callbacks);
    case 1: return atomic_load(&S.foreign_thread);
    case 2: return atomic_load(&S.nested);
    case 3: return atomic_load(&S.copied);
    case 4: return atomic_load(&S.dropped_by_policy);
    case 5: return atomic_load(&S.checks);
    case 6: return atomic_load(&S.refused);
    case 7: return atomic_load(&S.timer_callbacks);
    }
    return -1;
}

int evsdl_quit(void) {
    if (S.pump >= 0) botlish_event_remove_pump(S.pump);
    S.pump = -1;
    if (S.started) {
        SDL_SetEventFilter(NULL, NULL);
        SDL_RemoveEventWatch(watch_wake, NULL);
        SDL_Quit();
    }
    S.started = 0;
    return 0;
}
