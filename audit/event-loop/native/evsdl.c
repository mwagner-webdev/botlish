/* evsdl.c -- the SDL3 adapter of EVENT-LOOP-EXPLORATION.md (Experiments B
 * and C), over evn.c. SDL is initialized for events only (no window: the
 * sandbox is headless); its events come from other threads (a producer
 * pushing user events, SDL's own timer thread), which is exactly the case a
 * loop must not lose: a native callback on a thread that is not the loop's.
 *
 * Four ways of coordinating SDL with the loop's one wait (evsdl_start's
 * MODE), and a fifth where SDL does the waiting (evsdl_block):
 *
 *   1 wakeup  readiness/wakeup protocol: an event FILTER (SDL calls it
 *             synchronously, on the pushing thread, before queueing) copies
 *             the event into a record (evn_post: thread-safe, wakes the
 *             loop) and drops it from SDL's queue. No polling.
 *   2 pump    prepare/check protocol: each wake, the check hook pumps SDL
 *             and moves at most `room` queued events into records; SDL has
 *             no descriptor to wait on, so prepare caps every sleep at CAP
 *             us (polling: bounded latency, periodic wakeups).
 *   3 hybrid  both: an event WATCH only wakes the loop (eventfd); the check
 *             hook moves the events, on the loop's thread, from SDL's queue
 *             (SDL's own bounded queue is the buffer).
 *   4 naive   the check hook alone, no cap, no wakeup: the negative control
 *             -- an event pushed while the loop sleeps waits for something
 *             else to wake it.
 *   5 sdl     (evsdl_block) SDL_WaitEventTimeout with the loop's deadline
 *             is the loop's only wait; sockets and posts are noticed only
 *             when SDL wakes or the deadline passes.
 *
 * In every mode the callbacks only copy scalars and post: no Botlish code
 * runs in them, nothing of SDL's event survives the callback, and an event
 * a Botlish task causes (evsdl_push, a nested native dispatch) reaches
 * Botlish in a later turn, never inside the task's segment.
 *
 * C-side policy for callbacks that must answer at once: the filter's
 * return value (keep or drop the event) is decided from a policy table the
 * program set beforehand (evsdl_drop_codes_from), never by asking Botlish.
 */
#include <SDL3/SDL.h>
#include <pthread.h>
#include <stdatomic.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>

extern long long evn_now(void);
extern int evn_post(int slot, int gen, long long a, long long b);
extern int evn_push_local(int slot, int gen, long long a, long long b);
extern int evn_wake(void);
extern int evn_block(long long deadline);
extern int evn_add_pump(long long (*prepare)(long long), int (*check)(int));

enum { M_WAKEUP = 1, M_PUMP = 2, M_HYBRID = 3, M_NAIVE = 4, M_SDL = 5 };

static struct {
    int mode, slot, gen, started, cap_us;
    SDL_ThreadID loop_thread;
    atomic_int in_call;                  /* a Botlish task is inside evsdl_push */
    int drop_from;                       /* policy: user codes >= this are dropped */
    atomic_llong callbacks, foreign_thread, nested, copied, dropped_by_policy, pumped, peeped, timer_callbacks;
} S = { .drop_from = 0x7fffffff };

/* The lifecycle barrier (EVENT-LOOP-EXPLORATION.md, Experiment C). SDL
 * delivers WILL_ENTER_BACKGROUND through the filter on the thread that
 * reports it (Android: the Java UI thread; the app thread blocks right
 * after: "do any life cycle handling in an event filter while the event
 * was being queued", SDL_androidevents.c). Botlish code cannot run on that
 * thread, so the filter posts the event to the loop and HOLDS the reporting
 * thread until the loop acknowledges (evsdl_lifecycle_ack) or a deadline
 * passes: the program's handler runs on the loop's thread, in a turn,
 * before the reporting thread returns to the system. */
static pthread_mutex_t barrier_lock = PTHREAD_MUTEX_INITIALIZER;
static pthread_cond_t barrier_cond = PTHREAD_COND_INITIALIZER;
static long long barrier_posted, barrier_acked, barrier_timeouts, barrier_max_hold_us, barrier_us = 2000000;

static void lifecycle_barrier(const SDL_Event *e) {
    long long start = evn_now();
    pthread_mutex_lock(&barrier_lock);
    long long seq = ++barrier_posted;
    pthread_mutex_unlock(&barrier_lock);
    while (evn_post(S.slot, S.gen, -(long long)e->type, start) < 0) SDL_DelayNS(50000);
    struct timespec until;
    clock_gettime(CLOCK_REALTIME, &until);
    until.tv_sec += (time_t)(barrier_us / 1000000);
    until.tv_nsec += (long)(barrier_us % 1000000) * 1000;
    if (until.tv_nsec >= 1000000000L) { until.tv_sec++; until.tv_nsec -= 1000000000L; }
    pthread_mutex_lock(&barrier_lock);
    while (barrier_acked < seq) {
        if (pthread_cond_timedwait(&barrier_cond, &barrier_lock, &until) != 0) {
            barrier_timeouts++;
            break;
        }
    }
    long long held = evn_now() - start;
    if (held > barrier_max_hold_us) barrier_max_hold_us = held;
    pthread_mutex_unlock(&barrier_lock);
}

/* The loop's handler is done with the lifecycle event(s) posted so far. */
int evsdl_lifecycle_ack(void) {
    pthread_mutex_lock(&barrier_lock);
    barrier_acked = barrier_posted;
    pthread_cond_broadcast(&barrier_cond);
    pthread_mutex_unlock(&barrier_lock);
    return 0;
}

static long long lifecycle_returned_at;
static SDL_Thread *lifecycle_threads[4];
static int nlifecycle;

static int SDLCALL lifecycle_main(void *p) {
    SDL_DelayNS((Uint64)(intptr_t)p * 1000000);
    SDL_Event e = { 0 };
    e.type = SDL_EVENT_WILL_ENTER_BACKGROUND;
    SDL_PushEvent(&e);                   /* the filter holds this thread */
    long long now = evn_now();
    if (now > lifecycle_returned_at) lifecycle_returned_at = now;
    return 0;
}

/* A thread reporting WILL_ENTER_BACKGROUND after MS (the system's
 * lifecycle thread in this probe). */
int evsdl_lifecycle_after(int ms) {
    if (nlifecycle == 4) return -1;
    lifecycle_threads[nlifecycle] = SDL_CreateThread(lifecycle_main, "evsdl-lifecycle", (void *)(intptr_t)ms);
    return lifecycle_threads[nlifecycle] ? nlifecycle++ : -1;
}

int evsdl_lifecycle_join(void) {
    for (int i = 0; i < nlifecycle; i++) SDL_WaitThread(lifecycle_threads[i], NULL);
    int n = nlifecycle;
    nlifecycle = 0;
    return n;
}

int evsdl_background_code(void) {
    return -(int)SDL_EVENT_WILL_ENTER_BACKGROUND;
}

static long long record_a(const SDL_Event *e) {
    return e->type == SDL_EVENT_USER ? (long long)e->user.code : -(long long)e->type;
}

static long long record_b(const SDL_Event *e) {
    return e->type == SDL_EVENT_USER ? (long long)(intptr_t)e->user.data1 : evn_now();
}

static void note_callback(void) {
    atomic_fetch_add(&S.callbacks, 1);
    if (SDL_GetCurrentThreadID() != S.loop_thread) atomic_fetch_add(&S.foreign_thread, 1);
    if (atomic_load(&S.in_call)) atomic_fetch_add(&S.nested, 1);
}

static bool policy_drops(const SDL_Event *e) {
    return e->type == SDL_EVENT_USER && e->user.code >= S.drop_from;
}

/* Mode 1: copy, post, and drop from SDL's queue. Any thread. */
static bool SDLCALL filter_wakeup(void *userdata, SDL_Event *e) {
    (void)userdata;
    note_callback();
    if (e->type == SDL_EVENT_WILL_ENTER_BACKGROUND) {
        lifecycle_barrier(e);
        return false;
    }
    if (policy_drops(e)) {
        atomic_fetch_add(&S.dropped_by_policy, 1);
        return false;
    }
    if (e->type == SDL_EVENT_USER || e->type == SDL_EVENT_QUIT) {
        while (evn_post(S.slot, S.gen, record_a(e), record_b(e)) < 0) SDL_DelayNS(50000);
        atomic_fetch_add(&S.copied, 1);
        return false;
    }
    return true;
}

/* Modes 2-4: the filter only applies the policy (an immediate answer). */
static bool SDLCALL filter_policy(void *userdata, SDL_Event *e) {
    (void)userdata;
    note_callback();
    if (e->type == SDL_EVENT_WILL_ENTER_BACKGROUND) {
        lifecycle_barrier(e);
        return false;
    }
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
    evn_wake();
    return true;
}

static int check_sdl(int room) {
    atomic_fetch_add(&S.pumped, 1);
    if (S.mode != M_WAKEUP) SDL_PumpEvents();
    SDL_Event events[32];
    int moved = 0;
    while (moved < room) {
        int want = room - moved < 32 ? room - moved : 32;
        int n = SDL_PeepEvents(events, want, SDL_GETEVENT, SDL_EVENT_FIRST, SDL_EVENT_LAST);
        if (n <= 0) break;
        for (int i = 0; i < n; i++) {
            if (events[i].type == SDL_EVENT_USER || events[i].type == SDL_EVENT_QUIT) {
                evn_push_local(S.slot, S.gen, record_a(&events[i]), record_b(&events[i]));
                atomic_fetch_add(&S.copied, 1);
            }
        }
        atomic_fetch_add(&S.peeped, n);
        moved += n;
    }
    return moved;
}

static long long prepare_cap(long long deadline) {
    long long cap = evn_now() + S.cap_us;
    return (deadline < 0 || deadline > cap) ? cap : deadline;
}

/* Start SDL (events only) in MODE, its events tagged (SLOT, GEN). CAP_US:
 * mode 2's polling interval. 0, or -1 when SDL fails to start. */
int evsdl_start(int mode, int slot, int gen, int cap_us) {
    if (S.started) return 0;
    if (!SDL_Init(SDL_INIT_EVENTS)) return -1;
    S.mode = mode;
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
        evn_add_pump(prepare_cap, check_sdl);
        break;
    case M_HYBRID:
        SDL_SetEventFilter(filter_policy, NULL);
        SDL_AddEventWatch(watch_wake, NULL);
        evn_add_pump(NULL, check_sdl);
        break;
    case M_NAIVE:
        SDL_SetEventFilter(filter_policy, NULL);
        evn_add_pump(NULL, check_sdl);
        break;
    case M_SDL:
        SDL_SetEventFilter(filter_policy, NULL);
        break;
    }
    return 0;
}

/* Mode 5's wait: SDL blocks, with the loop's deadline; then everything else
 * is polled once (sockets, posts) and SDL's events are moved. */
int evsdl_block(long long deadline) {
    long long left = deadline < 0 ? -1 : deadline - evn_now();
    if (left < 0 && deadline >= 0) left = 0;
    /* SDL's wait has millisecond resolution: round up, never early. */
    SDL_WaitEventTimeout(NULL, left < 0 ? -1 : (Sint32)((left + 999) / 1000));
    int n = evn_block(0);
    return n + check_sdl(512);
}

int evsdl_drop_codes_from(int code) {
    S.drop_from = code;
    return 0;
}

/* Push a user event from the calling thread (a Botlish task: the filter
 * and watch run synchronously inside this call -- a nested native
 * dispatch). */
int evsdl_push(int code) {
    SDL_Event e = { 0 };
    e.type = SDL_EVENT_USER;
    e.user.code = code;
    e.user.data1 = (void *)(intptr_t)evn_now();
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
        int us = a->interval_us ? (int)(rand_r(&seed) % (unsigned)(2 * a->interval_us + 1)) : 0;
        if (us) SDL_DelayNS((Uint64)us * 1000);
        SDL_Event e = { 0 };
        e.type = SDL_EVENT_USER;
        e.user.code = a->base + i;
        e.user.data1 = (void *)(intptr_t)evn_now();
        /* Pushed once: SDL_PushEvent also returns false when a filter
         * dropped the event (the policy, or mode 1, whose filter consumes
         * every event after copying it): retrying would duplicate it. */
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
    e.user.data1 = (void *)(intptr_t)evn_now();
    SDL_PushEvent(&e);
    return atomic_fetch_sub(&t->left, 1) > 1 ? interval : 0;
}

/* SDL's own timer: COUNT callbacks on SDL's timer thread, MS apart, each
 * pushing a user event (codes BASE..). Several may run at once. */
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
    case 5: return atomic_load(&S.pumped);
    case 6: return atomic_load(&S.peeped);
    case 7: return atomic_load(&S.timer_callbacks);
    case 8: return barrier_posted;
    case 9: return barrier_acked;
    case 10: return barrier_timeouts;
    case 11: return barrier_max_hold_us;
    case 12: return lifecycle_returned_at;
    }
    return -1;
}

int evsdl_quit(void) {
    if (S.started) SDL_Quit();
    S.started = 0;
    return 0;
}
