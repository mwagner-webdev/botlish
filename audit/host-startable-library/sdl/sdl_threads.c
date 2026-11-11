/* sdl_threads.c -- an LD_PRELOAD observer of the SDL functions an SDL
 * application calls (RN-HOST-STARTABLE-APPLICATION-LIBRARY-MILESTONE-1.md,
 * "SDL3/Icy Tower integration"): for each, how often and on which threads
 * (by name) it ran, printed to standard error at exit in a fixed order. Each
 * wrapper calls SDL's own function and changes nothing the application
 * sees. Built against SDL's pinned headers, so every wrapper has SDL's own
 * prototype. */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <pthread.h>
#include <stdatomic.h>
#include <stdio.h>
#include <string.h>
#include <SDL3/SDL.h>

enum { MAXF = 16 };
static struct { const char *name; char threads[96]; atomic_long calls; } seen[MAXF];
static pthread_mutex_t lock = PTHREAD_MUTEX_INITIALIZER;

static void note(int i, const char *fn) {
    char t[16] = "";
    pthread_getname_np(pthread_self(), t, sizeof t);
    pthread_mutex_lock(&lock);
    seen[i].name = fn;
    if (!strstr(seen[i].threads, t) && strlen(seen[i].threads) + strlen(t) + 2 < sizeof seen[i].threads) {
        if (seen[i].threads[0]) strcat(seen[i].threads, ",");
        strcat(seen[i].threads, t);
    }
    pthread_mutex_unlock(&lock);
    atomic_fetch_add(&seen[i].calls, 1);
}

#define WRAP(I, RET, NAME, PARAMS, ARGS)                           \
    RET NAME PARAMS {                                              \
        static RET (*real) PARAMS;                                 \
        if (!real) real = (RET (*) PARAMS)dlsym(RTLD_NEXT, #NAME); \
        note(I, #NAME);                                            \
        return real ARGS;                                          \
    }

WRAP(0, bool, SDL_Init, (SDL_InitFlags flags), (flags))
WRAP(1, SDL_Window *, SDL_CreateWindow, (const char *t, int w, int h, SDL_WindowFlags f), (t, w, h, f))
WRAP(2, SDL_Renderer *, SDL_CreateRenderer, (SDL_Window *w, const char *n), (w, n))
WRAP(3, bool, SDL_PollEvent, (SDL_Event *e), (e))
WRAP(4, bool, SDL_RenderClear, (SDL_Renderer *r), (r))
WRAP(5, bool, SDL_RenderFillRect, (SDL_Renderer *r, const SDL_FRect *rect), (r, rect))
WRAP(6, bool, SDL_RenderDebugText, (SDL_Renderer *r, float x, float y, const char *s), (r, x, y, s))
WRAP(7, bool, SDL_RenderPresent, (SDL_Renderer *r), (r))
WRAP(8, void, SDL_DestroyRenderer, (SDL_Renderer *r), (r))
WRAP(9, void, SDL_DestroyWindow, (SDL_Window *w), (w))
WRAP(10, void, SDL_Quit, (void), ())

__attribute__((destructor)) static void report(void) {
    for (int i = 0; i < MAXF; i++) {
        if (seen[i].name) fprintf(stderr, "observer: %s %ld calls on %s\n", seen[i].name, (long)seen[i].calls, seen[i].threads);
    }
}
