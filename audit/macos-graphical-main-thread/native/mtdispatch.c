/* mtdispatch.c -- candidate B of MACOS-GRAPHICAL-MAIN-THREAD-CENSUS.md
 * (section 11): Botlish stays on its worker, and every SDL operation is
 * dispatched to the process's main thread. Linked only against the
 * EXPERIMENTAL runtime (patches/main-thread-experiment.patch), whose
 * `botlish_experiment_main_call(f, data)` runs f(data) on the main thread
 * and waits for it -- when the executable runs with
 * BOTLISH_EXPERIMENT_THREAD=dispatch; otherwise it returns -1 at once (no
 * main thread serves requests: the production model, where the main thread
 * is blocked in join()).
 *
 * Each mtd_* function below is one synchronous request: the SDL calls in it
 * run on the main thread, never on the worker that asked. This file moves
 * them there on purpose -- it IS the dispatcher's client -- and reports
 * where they ran ("dispatch" lines). It also offers the two hazards the
 * census demonstrates: SDL_RunOnMainThread's own queue, which only SDL's
 * event processing on the main thread drains (mtd_callback_ptr), and a
 * watchdog that ends a deadlocked probe (mtd_watchdog).
 */
#include <SDL3/SDL.h>
#include <pthread.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

extern int botlish_experiment_main_call(void (*f)(void *), void *data);
extern int mtp_is_process_main(void);
extern long long mtp_now_ns(void);
extern int mtp_threads(void);

struct call {
    int pthread_main;
    bool sdl_main;
    char error[256];
    char driver[32];
};

static void note(struct call *c) {
    c->pthread_main = mtp_is_process_main();
    c->sdl_main = SDL_IsMainThread();
    snprintf(c->error, sizeof c->error, "%s", SDL_GetError());
    const char *driver = SDL_WasInit(SDL_INIT_VIDEO) ? SDL_GetCurrentVideoDriver() : NULL;
    snprintf(c->driver, sizeof c->driver, "%s", driver ? driver : "");
}

static void report(const char *what, int rc, bool ok, const struct call *c, long long ns) {
    fprintf(stderr, "MTP {\"kind\":\"dispatch\",\"what\":\"%s\",\"rc\":%d,\"ok\":%s,\"caller_pthread_main\":%d,"
            "\"pthread_main\":%d,\"sdl_main\":%s,\"error\":\"", what, rc, ok ? "true" : "false",
            mtp_is_process_main(), c->pthread_main, c->sdl_main ? "true" : "false");
    for (const char *p = c->error; *p; p++) {
        if (*p == '"' || *p == '\\') fputc('\\', stderr);
        if ((unsigned char)*p >= 0x20) fputc(*p, stderr);
    }
    fprintf(stderr, "\",\"driver\":\"%s\",\"ns\":%lld,\"threads\":%d}\n", c->driver, ns, mtp_threads());
    fflush(stderr);
}

/* --- availability --------------------------------------------------------- */
static void do_nothing(void *data) { note(data); }

/* 1 when a main thread serves requests, else 0 (the call returned -1). */
int mtd_available(void) {
    struct call c = {0};
    long long t = mtp_now_ns();
    int rc = botlish_experiment_main_call(do_nothing, &c);
    report("available", rc, rc == 0, &c, mtp_now_ns() - t);
    return rc == 0;
}

/* N empty requests: the total nanoseconds of the round trips. */
long long mtd_roundtrips(int n) {
    struct call c = {0};
    int failed = 0;
    long long t = mtp_now_ns();
    for (int i = 0; i < n; i++) failed += botlish_experiment_main_call(do_nothing, &c) != 0;
    long long ns = mtp_now_ns() - t;
    report("roundtrips", failed ? -1 : 0, failed == 0, &c, ns);
    return failed ? -1 : ns;
}

/* --- SDL's lifecycle, each a request ------------------------------------- */
struct init { struct call c; unsigned flags; bool ok; };
static void do_init(void *p) { struct init *a = p; a->ok = SDL_Init(a->flags); note(&a->c); }
bool mtd_init(unsigned flags) {
    struct init a = {.flags = flags};
    long long t = mtp_now_ns();
    int rc = botlish_experiment_main_call(do_init, &a);
    report("SDL_Init", rc, a.ok, &a.c, mtp_now_ns() - t);
    return rc == 0 && a.ok;
}

struct window { struct call c; SDL_Window *w; };
static void do_window(void *p) { struct window *a = p; a->w = SDL_CreateWindow("Botlish main-thread census (dispatched)", 320, 240, 0); note(&a->c); }
SDL_Window *mtd_create_window(void) {
    struct window a = {0};
    long long t = mtp_now_ns();
    int rc = botlish_experiment_main_call(do_window, &a);
    report("SDL_CreateWindow", rc, a.w != NULL, &a.c, mtp_now_ns() - t);
    return a.w;
}

struct renderer { struct call c; SDL_Window *w; SDL_Renderer *r; };
static void do_renderer(void *p) { struct renderer *a = p; a->r = SDL_CreateRenderer(a->w, NULL); note(&a->c); }
SDL_Renderer *mtd_create_renderer(SDL_Window *w) {
    struct renderer a = {.w = w};
    long long t = mtp_now_ns();
    int rc = botlish_experiment_main_call(do_renderer, &a);
    report("SDL_CreateRenderer", rc, a.r != NULL, &a.c, mtp_now_ns() - t);
    return a.r;
}

/* One frame: color, clear, present and the events pumped, in one request. */
struct frame { struct call c; SDL_Renderer *r; bool ok; };
static void do_frame(void *p) {
    struct frame *a = p;
    a->ok = SDL_SetRenderDrawColor(a->r, 0, 255, 255, 255) && SDL_RenderClear(a->r) && SDL_RenderPresent(a->r);
    SDL_PumpEvents();
    note(&a->c);
}
bool mtd_frame(SDL_Renderer *r) {
    struct frame a = {.r = r};
    long long t = mtp_now_ns();
    int rc = botlish_experiment_main_call(do_frame, &a);
    long long ns = mtp_now_ns() - t;
    static int reported;
    if (!reported++ || !a.ok) report("frame", rc, a.ok, &a.c, ns);
    return rc == 0 && a.ok;
}

struct push { struct call c; bool ok; };
static void do_push_quit(void *p) {
    struct push *a = p;
    SDL_Event e;
    SDL_zero(e);
    e.type = SDL_EVENT_QUIT;
    a->ok = SDL_PushEvent(&e);
    note(&a->c);
}
bool mtd_push_quit(void) {
    struct push a = {0};
    long long t = mtp_now_ns();
    int rc = botlish_experiment_main_call(do_push_quit, &a);
    report("SDL_PushEvent", rc, a.ok, &a.c, mtp_now_ns() - t);
    return rc == 0 && a.ok;
}

/* One SDL_PollEvent on the main thread: the event's type, or 0. */
struct poll { struct call c; unsigned type; };
static void do_poll(void *p) {
    struct poll *a = p;
    SDL_Event e;
    a->type = SDL_PollEvent(&e) ? e.type : 0;
    note(&a->c);
}
unsigned mtd_poll(void) {
    struct poll a = {0};
    int rc = botlish_experiment_main_call(do_poll, &a);
    if (a.type == SDL_EVENT_QUIT) report("SDL_PollEvent(quit)", rc, true, &a.c, 0);
    return rc == 0 ? a.type : 0;
}

struct destroy { struct call c; SDL_Window *w; SDL_Renderer *r; };
static void do_destroy(void *p) {
    struct destroy *a = p;
    SDL_DestroyRenderer(a->r);
    SDL_DestroyWindow(a->w);
    SDL_Quit();
    note(&a->c);
}
bool mtd_destroy_and_quit(SDL_Renderer *r, SDL_Window *w) {
    struct destroy a = {.w = w, .r = r};
    long long t = mtp_now_ns();
    int rc = botlish_experiment_main_call(do_destroy, &a);
    report("SDL_Destroy*+SDL_Quit", rc, rc == 0, &a.c, mtp_now_ns() - t);
    return rc == 0;
}

/* --- SDL's own main-thread queue ------------------------------------------ */
static void on_main(void *userdata) {
    (void)userdata;
    fprintf(stderr, "MTP {\"kind\":\"runonmain-callback\",\"pthread_main\":%d,\"sdl_main\":%s}\n",
            mtp_is_process_main(), SDL_IsMainThread() ? "true" : "false");
    fflush(stderr);
}

/* The C function SDL_RunOnMainThread is given (Botlish passes a C function
 * pointer it cannot make itself). */
SDL_MainThreadCallback mtd_callback_ptr(void) { return on_main; }

/* --- the watchdog ----------------------------------------------------------- */
static void *watch(void *arg) {
    unsigned seconds = (unsigned)(uintptr_t)arg;
    sleep(seconds);
    fprintf(stderr, "MTP {\"kind\":\"deadlock\",\"after_s\":%u,\"threads\":%d}\n", seconds, mtp_threads());
    fflush(stderr);
    _exit(124);
}

/* After SECONDS, report a deadlock and end the process with status 124:
 * how a probe that waits forever ends, measured, instead of by the
 * harness's timeout. */
int mtd_watchdog(unsigned seconds) {
    pthread_t t;
    if (pthread_create(&t, NULL, watch, (void *)(uintptr_t)seconds) != 0) return 0;
    pthread_detach(t);
    return 1;
}
