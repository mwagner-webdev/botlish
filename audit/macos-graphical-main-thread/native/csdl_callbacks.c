/* csdl_callbacks.c -- candidate C's lifecycle in C (MACOS-GRAPHICAL-MAIN-
 * THREAD-CENSUS.md, section 19): SDL3's main callbacks. SDL_main.h with
 * SDL_MAIN_USE_CALLBACKS defines the executable's main(), which on macOS is
 * SDL_RunApp -> SDL_EnterAppMainCallbacks: SDL's generic loop
 * (src/main/generic/SDL_sysmain_callbacks.c) on the process's initial
 * thread, calling SDL_AppInit once, SDL_AppIterate per iteration,
 * SDL_AppEvent per event and SDL_AppQuit at the end. Each callback reports
 * where it runs; SDL_AppIterate draws a frame and, at its 60th call, pushes
 * a quit, which SDL_AppEvent answers with SDL_APP_SUCCESS.
 *
 * With BOTLISH_LIBRARY set (Linux only: native libraries are Linux glibc's,
 * NATIVE-LIBRARY-MILESTONE-1.md) the callbacks also call an exported
 * Botlish function -- see tools/library-callbacks.sh.
 */
#define SDL_MAIN_USE_CALLBACKS 1
#include <SDL3/SDL.h>
#include <SDL3/SDL_main.h>
#include <stdbool.h>
#include <stdio.h>

extern int mtp_mark(int stage);
extern bool mtp_sdl(int stage, bool ok, bool sdl_is_main);
extern int mtp_window(SDL_Window *window);
extern int mtp_renderer(SDL_Renderer *renderer);
extern int mtp_is_process_main(void);
extern long long mtp_now_ns(void);

#ifdef MTP_BOTLISH_LIBRARY
/* The Botlish native library's C API (tools/library-callbacks.sh). */
#include "mtplib.h"
static mtplib_instance *instance;
static long long botlish_calls, botlish_failures, botlish_last;
static void botlish_step(long long n) {
    long long out = 0;
    int status = mtplib_step(instance, n, &out, NULL);
    botlish_calls++;
    if (status != mtplib_STATUS_OK) botlish_failures++;
    else botlish_last = out;
}
#endif

enum { CB_INIT = 15, CB_ITERATE = 16, CB_EVENT = 17, CB_QUIT = 18 };

typedef struct {
    SDL_Window *window;
    SDL_Renderer *renderer;
    int iterations, presented, events, on_main, calls;
    long long started_ns;
} App;

static App app;

static void count(void) { app.calls++; app.on_main += mtp_is_process_main(); }

SDL_AppResult SDL_AppInit(void **state, int argc, char *argv[]) {
    (void)argc; (void)argv;
    *state = &app;
    app.started_ns = mtp_now_ns();
    mtp_mark(CB_INIT);
    count();
    if (!mtp_sdl(2, SDL_Init(SDL_INIT_VIDEO), SDL_IsMainThread())) return SDL_APP_FAILURE;
    app.window = SDL_CreateWindow("C control (main callbacks)", 320, 240, 0);
    if (!mtp_window(app.window)) return SDL_APP_FAILURE;
    app.renderer = SDL_CreateRenderer(app.window, NULL);
    if (!mtp_renderer(app.renderer)) return SDL_APP_FAILURE;
#ifdef MTP_BOTLISH_LIBRARY
    if (mtplib_create(&instance, NULL) != mtplib_STATUS_OK) return SDL_APP_FAILURE;
    botlish_step(0);
#endif
    return SDL_APP_CONTINUE;
}

SDL_AppResult SDL_AppIterate(void *state) {
    App *a = state;
    if (a->iterations++ == 0) mtp_mark(CB_ITERATE);
    count();
    if (SDL_SetRenderDrawColor(a->renderer, 0, 160, 0, 255) && SDL_RenderClear(a->renderer) && SDL_RenderPresent(a->renderer))
        a->presented++;
#ifdef MTP_BOTLISH_LIBRARY
    botlish_step(a->iterations);
#endif
    if (a->iterations == 60) {
        SDL_Event e;
        SDL_zero(e);
        e.type = SDL_EVENT_QUIT;
        SDL_PushEvent(&e);
    }
    return SDL_APP_CONTINUE;
}

SDL_AppResult SDL_AppEvent(void *state, SDL_Event *event) {
    App *a = state;
    if (a->events++ == 0) mtp_mark(CB_EVENT);
    count();
    return event->type == SDL_EVENT_QUIT ? SDL_APP_SUCCESS : SDL_APP_CONTINUE;
}

void SDL_AppQuit(void *state, SDL_AppResult result) {
    App *a = state;
    mtp_mark(CB_QUIT);
    count();
    if (a) {
        SDL_DestroyRenderer(a->renderer);
        SDL_DestroyWindow(a->window);
    }
#ifdef MTP_BOTLISH_LIBRARY
    mtplib_destroy(instance);
    fprintf(stderr, "MTP {\"kind\":\"botlish-library\",\"calls\":%lld,\"failures\":%lld,\"last\":%lld}\n",
            botlish_calls, botlish_failures, botlish_last);
#endif
    fprintf(stderr, "MTP {\"kind\":\"callbacks\",\"result\":%d,\"iterations\":%d,\"presented\":%d,\"events\":%d,"
            "\"calls\":%d,\"on_main\":%d,\"ms\":%lld}\n", (int)result, a ? a->iterations : 0, a ? a->presented : 0,
            a ? a->events : 0, app.calls, app.on_main, (mtp_now_ns() - app.started_ns) / 1000000);
    fflush(stderr);
}
