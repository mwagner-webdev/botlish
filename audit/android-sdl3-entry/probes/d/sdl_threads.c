/* Probe D's observer (ANDROID-SDL3-NATIVE-APPLICATION-ENTRY-CENSUS-MILESTONE-1.md):
 * an LD_PRELOAD interposer of the SDL functions the game calls, recording
 * for each the threads it ran on (by name) and how often, printed at exit.
 * It changes nothing the game sees: each wrapper calls SDL's own function. */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <pthread.h>
#include <stdatomic.h>
#include <stdbool.h>
#include <stdio.h>
#include <string.h>

#define MAXF 16
static struct { const char *name; char threads[64]; atomic_long calls; } seen[MAXF];
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

#define WRAP(I, RET, NAME, PARAMS, ARGS)                         \
    RET NAME PARAMS {                                            \
        static RET (*real) PARAMS;                               \
        if (!real) real = (RET (*) PARAMS)dlsym(RTLD_NEXT, #NAME); \
        note(I, #NAME);                                          \
        return real ARGS;                                        \
    }

typedef struct SDL_Window SDL_Window;
typedef struct SDL_Renderer SDL_Renderer;
typedef union SDL_Event SDL_Event;
WRAP(0, bool, SDL_Init, (unsigned flags), (flags))
WRAP(1, SDL_Window *, SDL_CreateWindow, (const char *t, int w, int h, unsigned long long f), (t, w, h, f))
WRAP(2, SDL_Renderer *, SDL_CreateRenderer, (SDL_Window *w, const char *n), (w, n))
WRAP(3, bool, SDL_PollEvent, (SDL_Event *e), (e))
WRAP(4, bool, SDL_RenderPresent, (SDL_Renderer *r), (r))
WRAP(5, bool, SDL_RenderDebugText, (SDL_Renderer *r, float x, float y, const char *s), (r, x, y, s))
WRAP(6, void, SDL_DestroyRenderer, (SDL_Renderer *r), (r))
WRAP(7, void, SDL_Quit, (void), ())

__attribute__((destructor)) static void report(void) {
    for (int i = 0; i < MAXF; i++) {
        if (seen[i].name) fprintf(stderr, "observer: %-20s %6ld calls, on %s\n", seen[i].name, (long)seen[i].calls, seen[i].threads);
    }
}
