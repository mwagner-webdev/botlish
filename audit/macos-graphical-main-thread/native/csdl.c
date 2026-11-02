/* csdl.c -- the C controls of MACOS-GRAPHICAL-MAIN-THREAD-CENSUS.md: the
 * same SDL3 lifecycle the Botlish probe (programs/sdl.bot) runs, from C,
 * linked against the same static libSDL3.a and the same observation fixture
 * (mtprobe.c), on the threads each execution model would use. Whatever a
 * C program cannot do on a runner, a Botlish program is not blamed for.
 *
 *   csdl main            the lifecycle on the process's main thread: the
 *                        graphical positive control (section 8)
 *   csdl worker          the same on a 1 GiB pthread while the main thread
 *                        joins it: today's Botlish model, in C (section 6)
 *   csdl join-runonmain  main: SDL_Init(SDL_INIT_VIDEO), then join a worker
 *                        that calls SDL_RunOnMainThread(..., true): the
 *                        deadlock of section 17 (a watchdog ends it: 124)
 *   csdl pump-runonmain  main: SDL_Init(SDL_INIT_VIDEO), then process SDL's
 *                        events until the worker ends; the worker creates,
 *                        draws and destroys through SDL_RunOnMainThread:
 *                        candidate B with SDL's own queue (section 11)
 *   csdl nopump          the main lifecycle, but the quit event pushed is
 *                        never polled: a positive control -- the oracle must
 *                        not report it processed (section 25)
 *   csdl nodestroy       the main lifecycle without the window's, the
 *                        renderer's and SDL's shutdown: a positive control
 *                        of the cleanup check (section 25)
 *   csdl identity        only the identity report, on the main thread /
 *   csdl identity-worker on a 1 GiB worker the main thread joins
 *   csdl appkit-main     an NSWindow made directly through AppKit, no SDL,
 *   csdl appkit-worker   on the main thread / on a worker (macOS only)
 *
 * Reports are the fixture's "MTP" lines on standard error and one result
 * line, "MTP {"kind":"result",...}".
 */
#include <SDL3/SDL.h>
#include <pthread.h>
#include <stdatomic.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

extern int mtp_mark(int stage);
extern bool mtp_sdl(int stage, bool ok, bool sdl_is_main);
extern int mtp_window(SDL_Window *window);
extern int mtp_renderer(SDL_Renderer *renderer);
extern int mtp_capture(SDL_Window *window);
extern int mtp_is_process_main(void);
extern long long mtp_now_ns(void);
extern int mtp_threads(void);
#ifdef __APPLE__
extern int mtp_appkit_window(char *reason, size_t size);
#endif

enum { ENTRY, BEFORE_INIT, AFTER_INIT, AFTER_WINDOW, AFTER_RENDERER, AFTER_PRESENT, AFTER_EVENTS,
       AFTER_DESTROY, AFTER_QUIT, EXIT, COROUTINE_BODY, COROUTINE_RESUMED, DEEP, DISPATCH_CALL,
       AFTER_PUSH, CB_INIT, CB_ITERATE, CB_EVENT, CB_QUIT, WORKER };

static void result(const char *mode, bool init, bool window, bool renderer, int presented, bool pushed,
                   int events, bool quit_seen) {
    fprintf(stderr, "MTP {\"kind\":\"result\",\"mode\":\"%s\",\"init\":%s,\"window\":%s,\"renderer\":%s,"
            "\"presented\":%d,\"pushed\":%s,\"events\":%d,\"quit_seen\":%s,\"pthread_main\":%d}\n",
            mode, init ? "true" : "false", window ? "true" : "false", renderer ? "true" : "false", presented,
            pushed ? "true" : "false", events, quit_seen ? "true" : "false", mtp_is_process_main());
    fflush(stderr);
}

static int frame(SDL_Renderer *r) {
    bool ok = SDL_SetRenderDrawColor(r, 255, 128, 0, 255) && SDL_RenderClear(r) && SDL_RenderPresent(r);
    SDL_PumpEvents();
    SDL_Delay(16);
    return ok;
}

/* The lifecycle sdl.bot runs. POLL: whether the pushed quit is polled back. */
static int lifecycle(const char *mode, bool poll, bool destroy) {
    mtp_mark(ENTRY);
    mtp_sdl(BEFORE_INIT, true, SDL_IsMainThread());
    bool init = mtp_sdl(AFTER_INIT, SDL_Init(SDL_INIT_VIDEO), SDL_IsMainThread());
    bool have_window = false, have_renderer = false, pushed = false, quit_seen = false;
    int presented = 0, events = 0;
    if (init) {
        SDL_Window *w = SDL_CreateWindow("C control", 320, 240, 0);
        have_window = mtp_window(w);
        mtp_sdl(AFTER_WINDOW, have_window, SDL_IsMainThread());
        if (w) {
            SDL_Renderer *r = SDL_CreateRenderer(w, NULL);
            have_renderer = mtp_renderer(r);
            mtp_sdl(AFTER_RENDERER, have_renderer, SDL_IsMainThread());
            for (int i = 0; r && i < 30; i++) presented += frame(r);
            mtp_mark(AFTER_PRESENT);
            mtp_capture(w);
            SDL_Event e;
            SDL_zero(e);
            e.type = SDL_EVENT_QUIT;
            pushed = SDL_PushEvent(&e);
            mtp_sdl(AFTER_PUSH, pushed, SDL_IsMainThread());
            for (int i = 0; poll && i < 400 && !quit_seen; i++) {
                if (SDL_PollEvent(&e)) {
                    events++;
                    quit_seen = e.type == SDL_EVENT_QUIT;
                } else {
                    SDL_Delay(5);
                }
            }
            mtp_mark(AFTER_EVENTS);
            if (destroy) {
                SDL_DestroyRenderer(r);
                SDL_DestroyWindow(w);
                mtp_mark(AFTER_DESTROY);
            }
        }
    }
    if (destroy) SDL_Quit();
    mtp_mark(AFTER_QUIT);
    result(mode, init, have_window, have_renderer, presented, pushed, events, quit_seen);
    return init && have_window && have_renderer && quit_seen ? 0 : 1;
}

static void *identity_worker(void *arg) {
    (void)arg;
    return (void *)(intptr_t)(mtp_mark(WORKER) == 0 ? 0 : 1);
}

static void *worker_lifecycle(void *arg) {
    (void)arg;
    return (void *)(intptr_t)lifecycle("worker", true, true);
}

/* A thread like Botlish's worker: 1 GiB of stack, the main thread joining. */
static int on_worker(void *(*body)(void *)) {
    pthread_attr_t attr;
    pthread_attr_init(&attr);
    pthread_attr_setstacksize(&attr, (size_t)1 << 30);
    pthread_t t;
    if (pthread_create(&t, &attr, body, NULL) != 0) { perror("pthread_create"); return 2; }
    void *status;
    pthread_join(t, &status);
    return (int)(intptr_t)status;
}

/* --- SDL_RunOnMainThread ----------------------------------------------------- */
static atomic_int worker_done;
static SDL_Window *rom_window;
static SDL_Renderer *rom_renderer;
static int rom_presented;
static int rom_on_main;  /* callbacks that ran on the process's main thread */
static int rom_calls;

static void count_thread(void) { rom_calls++; rom_on_main += mtp_is_process_main(); }
static void rom_create(void *u) { (void)u; count_thread(); rom_window = SDL_CreateWindow("C control (RunOnMainThread)", 320, 240, 0); mtp_window(rom_window); rom_renderer = rom_window ? SDL_CreateRenderer(rom_window, NULL) : NULL; mtp_renderer(rom_renderer); }
static void rom_frame(void *u) { (void)u; count_thread(); if (rom_renderer) rom_presented += frame(rom_renderer); }
static void rom_destroy(void *u) { (void)u; count_thread(); SDL_DestroyRenderer(rom_renderer); SDL_DestroyWindow(rom_window); }
static void rom_nothing(void *u) { (void)u; }

static void *rom_worker(void *arg) {
    (void)arg;
    mtp_mark(WORKER);
    bool ok = SDL_RunOnMainThread(rom_create, NULL, true);
    for (int i = 0; ok && i < 30; i++) ok = SDL_RunOnMainThread(rom_frame, NULL, true);
    long long t = mtp_now_ns();
    for (int i = 0; ok && i < 200; i++) ok = SDL_RunOnMainThread(rom_nothing, NULL, true);
    long long ns = mtp_now_ns() - t;
    ok = ok && SDL_RunOnMainThread(rom_destroy, NULL, true);
    fprintf(stderr, "MTP {\"kind\":\"runonmain\",\"ok\":%s,\"calls\":%d,\"on_main\":%d,\"presented\":%d,\"empty_roundtrip_ns\":%lld}\n",
            ok ? "true" : "false", rom_calls, rom_on_main, rom_presented, ns / 200);
    fflush(stderr);
    atomic_store(&worker_done, 1);
    return (void *)(intptr_t)(ok ? 0 : 1);
}

static void *watchdog(void *arg) {
    sleep((unsigned)(uintptr_t)arg);
    fprintf(stderr, "MTP {\"kind\":\"deadlock\",\"after_s\":%u,\"threads\":%d}\n", (unsigned)(uintptr_t)arg, mtp_threads());
    fflush(stderr);
    _exit(124);
}

static int runonmain(bool pump) {
    mtp_mark(ENTRY);
    bool init = mtp_sdl(AFTER_INIT, SDL_Init(SDL_INIT_VIDEO), SDL_IsMainThread());
    if (!init) { result(pump ? "pump-runonmain" : "join-runonmain", false, false, false, 0, false, 0, false); return 1; }
    pthread_t dog, t;
    if (!pump) {
        pthread_create(&dog, NULL, watchdog, (void *)(uintptr_t)5);
        pthread_detach(dog);
    }
    pthread_create(&t, NULL, rom_worker, NULL);
    if (pump) {
        /* The main thread processes SDL's events -- and with them SDL's
         * main-thread callbacks -- until the worker is done. */
        while (!atomic_load(&worker_done)) SDL_WaitEventTimeout(NULL, 10);
    }
    void *status;
    pthread_join(t, &status);  /* join-runonmain: never returns */
    SDL_Quit();
    mtp_mark(AFTER_QUIT);
    return (int)(intptr_t)status;
}

#ifdef __APPLE__
static void *appkit_worker(void *arg) {
    (void)arg;
    char reason[512];
    int made = mtp_appkit_window(reason, sizeof reason);
    for (char *p = reason; *p; p++) if (*p == '"' || *p == '\\' || (unsigned char)*p < 0x20) *p = '\'';
    fprintf(stderr, "MTP {\"kind\":\"appkit\",\"made\":%d,\"pthread_main\":%d,\"reason\":\"%s\"}\n", made, mtp_is_process_main(), reason);
    fflush(stderr);
    return (void *)(intptr_t)(made ? 0 : 1);
}
#endif

int main(int argc, char **argv) {
    const char *mode = argc > 1 ? argv[1] : "main";
    if (!strcmp(mode, "main")) return lifecycle("main", true, true);
    if (!strcmp(mode, "nopump")) return lifecycle("nopump", false, true);
    if (!strcmp(mode, "nodestroy")) return lifecycle("nodestroy", true, false);
    if (!strcmp(mode, "identity")) return mtp_mark(ENTRY) == 1 ? 0 : 1;
    if (!strcmp(mode, "identity-worker")) return on_worker(identity_worker);
    if (!strcmp(mode, "worker")) return on_worker(worker_lifecycle);
    if (!strcmp(mode, "join-runonmain")) return runonmain(false);
    if (!strcmp(mode, "pump-runonmain")) return runonmain(true);
#ifdef __APPLE__
    if (!strcmp(mode, "appkit-main")) return (int)(intptr_t)appkit_worker(NULL);
    if (!strcmp(mode, "appkit-worker")) return on_worker(appkit_worker);
#endif
    fprintf(stderr, "csdl: unknown mode %s\n", mode);
    return 2;
}
