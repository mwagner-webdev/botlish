/* evsdlhost.c -- the host-driven experiment of EVENT-LOOP-EXPLORATION.md
 * (Experiment B, invariant 6; Experiment C): SDL3's own application model,
 * SDL_EnterAppMainCallbacks, owns the loop and calls SDL_AppIterate at ITS
 * pace (SDL_HINT_MAIN_CALLBACK_RATE: a rate, or "waitevent"), and
 * SDL_AppEvent synchronously for every event.
 *
 * Botlish cannot be called back from C, so control is inverted with a fiber
 * (a ucontext on a stack of its own): SDL's host loop runs on the fiber;
 * the Botlish loop's driver, evsdlhost_block, switches to it and returns
 * when SDL calls SDL_AppIterate -- one scheduling turn per host iteration.
 * The scheduler's deadline is a request the host does not honor: SDL
 * decides when the next iteration comes, and the experiment measures how
 * late that makes timers. SDL_AppEvent only copies the event into a record
 * (no Botlish code runs in it) and answers at once from a C policy: a quit
 * event ends the host when the program asked to quit on it, else the app
 * continues and the program sees the quit as a record.
 *
 * The same inversion is the proposed answer to Win32 modal loops
 * (native/win32/evwin32.c): the foreign loop on a fiber, Botlish's turn
 * between its callbacks, never inside them.
 */
#include <SDL3/SDL.h>
#define SDL_MAIN_NOIMPL 1   /* the executable's main is Botlish's: no SDL main() here */
#include <SDL3/SDL_main.h>
#include <stdatomic.h>
#include <stdint.h>
#include <stdlib.h>
#include <ucontext.h>

extern long long evn_now(void);
extern int evn_push_local(int slot, int gen, long long a, long long b);
extern int evn_block(long long deadline);
extern int evn_open(int capacity, int quota, int flags);

static struct {
    ucontext_t loop_ctx, host_ctx;
    void *stack;
    int slot, gen, started, finished, quit_requested, quit_on_quit_event, rc, kicked;
    long long iterations, events, foreign_events, last_iterate, max_gap;
    SDL_ThreadID loop_thread;
    char rate[32];
} H;

static SDL_AppResult SDLCALL app_init(void **appstate, int argc, char *argv[]) {
    (void)appstate;
    (void)argc;
    (void)argv;
    SDL_SetHint(SDL_HINT_MAIN_CALLBACK_RATE, H.rate);
    if (!SDL_Init(SDL_INIT_EVENTS)) return SDL_APP_FAILURE;
    /* "waitevent" waits for an event BEFORE the first iteration: a loop
     * whose sources start in its first turn would never get that turn.
     * One kick event (code 5999, not measured) starts it. */
    if (SDL_strcmp(H.rate, "waitevent") == 0) {
        SDL_Event kick = { 0 };
        kick.type = SDL_EVENT_USER;
        kick.user.code = 5999;
        kick.user.data1 = (void *)(intptr_t)evn_now();
        SDL_PushEvent(&kick);
        H.kicked = 1;
    }
    return SDL_APP_CONTINUE;
}

/* SDL_AppIterate: one host iteration hands the thread to the Botlish loop
 * for one turn. */
static SDL_AppResult SDLCALL app_iterate(void *appstate) {
    (void)appstate;
    H.iterations++;
    long long now = evn_now();
    if (H.last_iterate && now - H.last_iterate > H.max_gap) H.max_gap = now - H.last_iterate;
    H.last_iterate = now;
    swapcontext(&H.host_ctx, &H.loop_ctx);
    return H.quit_requested ? SDL_APP_SUCCESS : SDL_APP_CONTINUE;
}

/* SDL_AppEvent, synchronous: copy and answer at once (C policy, decided
 * beforehand). */
static SDL_AppResult SDLCALL app_event(void *appstate, SDL_Event *e) {
    (void)appstate;
    H.events++;
    if (SDL_GetCurrentThreadID() != H.loop_thread) H.foreign_events++;
    long long a = e->type == SDL_EVENT_USER ? (long long)e->user.code : -(long long)e->type;
    long long b = e->type == SDL_EVENT_USER ? (long long)(intptr_t)e->user.data1 : evn_now();
    evn_push_local(H.slot, H.gen, a, b);
    if (e->type == SDL_EVENT_QUIT && H.quit_on_quit_event) return SDL_APP_SUCCESS;
    return SDL_APP_CONTINUE;
}

static void SDLCALL app_quit(void *appstate, SDL_AppResult result) {
    (void)appstate;
    H.rc = (int)result;
}

static void host_main(void) {
    char *argv[] = { "evsdlhost", NULL };
    SDL_EnterAppMainCallbacks(1, argv, app_init, app_iterate, app_event, app_quit);
    H.finished = 1;
    /* uc_link returns to the loop. */
}

/* Prepare the host: SDL's events tagged (SLOT, GEN); RATE_HZ > 0 a fixed
 * iteration rate, 0 "waitevent" (SDL iterates only after an event). */
int evsdlhost_start(int slot, int gen, int rate_hz) {
    if (H.started) return 0;
    evn_open(4096, 16, 0);
    H.slot = slot;
    H.gen = gen;
    H.loop_thread = SDL_GetCurrentThreadID();
    if (rate_hz > 0) SDL_snprintf(H.rate, sizeof H.rate, "%d", rate_hz);
    else SDL_strlcpy(H.rate, "waitevent", sizeof H.rate);
    size_t size = 1 << 20;
    H.stack = malloc(size);
    getcontext(&H.host_ctx);
    H.host_ctx.uc_stack.ss_sp = H.stack;
    H.host_ctx.uc_stack.ss_size = size;
    H.host_ctx.uc_link = &H.loop_ctx;
    makecontext(&H.host_ctx, host_main, 0);
    H.started = 1;
    return 0;
}

/* The loop's wait: run the host until its next iteration (DEADLINE is
 * ignored -- the host decides), then poll everything else once. Returns
 * the records available; -1 once the host has ended. */
int evsdlhost_block(long long deadline) {
    (void)deadline;
    if (H.finished) return -1;
    swapcontext(&H.loop_ctx, &H.host_ctx);
    if (H.finished) return -1;
    return evn_block(0);
}

/* Ask the host to end after the next iteration. */
int evsdlhost_quit(int on_quit_event) {
    if (on_quit_event) {
        H.quit_on_quit_event = 1;
        return 0;
    }
    H.quit_requested = 1;
    if (!H.finished) swapcontext(&H.loop_ctx, &H.host_ctx);
    return H.rc;
}

long long evsdlhost_stat(int i) {
    switch (i) {
    case 0: return H.iterations;
    case 1: return H.events;
    case 2: return H.foreign_events;
    case 3: return H.max_gap;
    case 4: return H.finished;
    case 5: return H.kicked;
    }
    return -1;
}
