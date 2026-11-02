// sdltrace.c -- an LD_PRELOAD interposer for ICY-TOWER-CONTEXT-REFACTOR-CENSUS.md:
// logs every SDL call the Icy Tower executable makes that draws, polls, times
// or manages resources, with its arguments (a rectangle's contents and every
// float in C99 hex, a string's text, a color), one line per call, to the file
// named by SDLTRACE. Pointers are logged as "null" or "ptr" only, so two runs
// (two builds of the game) compare line by line: trace-compare.sh.
//
// Compiled with -DSDLTRACE_LINKED it is a link-time wrapper instead, for an
// SDL3 linked into the executable as a static archive, where nothing can be
// interposed at run time (macOS: ICY-TOWER-MACOS-MILESTONE-1.md, "SDL call
// trace"): each wrapper calls real_NAME, the archive's own NAME renamed
// (audit/icy-tower/tools/traced-archive.sh renames every function this file
// wraps -- the prototypes below are that list -- and adds this object to the
// archive). The lines it writes are the same.
//
// Fault injection, for the application bundle's failure alerts
// (ICY-TOWER-MACOS-APP-MILESTONE-1.md, "Terminal-free error reporting"):
// SDLTRACE_FAIL=SDL_CreateWindow makes the window's creation fail, and
// SDLTRACE_FAIL=SDL_RenderPresent@N the Nth present (a frame that cannot be
// drawn, after Cocoa and Metal started), each with SDL_SetError's text
// "SDLTRACE_FAIL: NAME injected", as SDL reports its own failures. Without
// the variable nothing changes.
#ifndef SDLTRACE_LINKED
#define _GNU_SOURCE
#include <dlfcn.h>
#endif
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <stdarg.h>
#include <stddef.h>
#include <string.h>

typedef struct { float x, y, w, h; } FRect;
bool SDL_SetError(const char *fmt, ...);
// Whether the CALLth call of NAME is the one SDLTRACE_FAIL names (NAME, the
// first call; NAME@N, the Nth); if so SDL's error is set.
static int injected(const char *name, long call) {
    const char *f = getenv("SDLTRACE_FAIL");
    size_t n = strlen(name);
    if (!f || strncmp(f, name, n) || (f[n] && f[n] != '@')) return 0;
    if (call != (f[n] == '@' ? atol(f + n + 1) : 1)) return 0;
    SDL_SetError("SDLTRACE_FAIL: %s injected", name);
    return 1;
}
static FILE *out;
static void open_out(void) {
    if (!out) { const char *p = getenv("SDLTRACE"); out = fopen(p ? p : "/dev/null", "w"); setvbuf(out, NULL, _IOFBF, 1 << 20); }
}
#ifdef SDLTRACE_LINKED
// The wrapped functions, as the archive defines them (SDL3's prototypes,
// with the argument types the wrappers below use).
bool real_SDL_SetRenderDrawColor(void *r, uint8_t a, uint8_t b, uint8_t c, uint8_t d);
bool real_SDL_RenderFillRect(void *r, const FRect *f);
bool real_SDL_RenderLine(void *r, float a, float b, float c, float d);
bool real_SDL_RenderDebugText(void *r, float x, float y, const char *s);
bool real_SDL_SetRenderScale(void *r, float x, float y);
bool real_SDL_RenderClear(void *r);
bool real_SDL_RenderPresent(void *r);
bool real_SDL_PollEvent(void *e);
const bool *real_SDL_GetKeyboardState(int *n);
uint64_t real_SDL_GetTicksNS(void);
void real_SDL_DelayNS(uint64_t ns);
uint64_t real_SDL_GetPerformanceCounter(void);
bool real_SDL_Init(uint32_t f);
void real_SDL_Quit(void);
void *real_SDL_CreateWindow(const char *t, int w, int h, uint64_t f);
void *real_SDL_CreateRenderer(void *w, const char *n);
bool real_SDL_SetRenderLogicalPresentation(void *r, int w, int h, int m);
bool real_SDL_SetRenderVSync(void *r, int v);
void real_SDL_DestroyRenderer(void *r);
void real_SDL_DestroyWindow(void *w);
void *real_SDL_malloc(size_t n);
void real_SDL_free(void *p);

// The probe build's account of the session, written to $SDLTRACE_INFO when
// that is set (never into the trace, whose lines stay the Linux
// interposer's): which video driver and renderer SDL chose, whether every
// SDL call ran on the process's main thread (pthread_main_np, never SDL's
// own answer), the window's and the drawable's sizes, and the session's
// times -- SDL_Init, the window, the renderer, the first frame presented,
// the frame intervals, the event pump, the shutdown.
#include <string.h>
#include <time.h>
#if defined(__APPLE__)
#include <pthread.h>
static int on_main(void) { return pthread_main_np(); }
#else
#include <unistd.h>
#include <sys/syscall.h>
static int on_main(void) { return getpid() == (pid_t)syscall(SYS_gettid); }
#endif
const char *SDL_GetCurrentVideoDriver(void);
const char *SDL_GetRendererName(void *r);
bool SDL_GetWindowSize(void *w, int *x, int *y);
bool SDL_GetWindowSizeInPixels(void *w, int *x, int *y);
bool SDL_GetRenderOutputSize(void *r, int *x, int *y);
static FILE *info;
static double t_start, t_shutdown, poll_seconds;
static long calls, off_main, polls, presents_n;
#define MAX_PRESENTS 200000
static double presents[MAX_PRESENTS];
static double now(void) { struct timespec ts; clock_gettime(CLOCK_MONOTONIC, &ts); return (double)ts.tv_sec + ts.tv_nsec / 1e9; }
static void note_call(void) {
    if (!calls++) {
        const char *p = getenv("SDLTRACE_INFO");
        info = p ? fopen(p, "w") : NULL;
        t_start = now();
        if (info) fprintf(info, "start main=%d\n", on_main());
    }
    if (!on_main()) off_main++;
}
static int by_value(const void *a, const void *b) { double x = *(const double *)a, y = *(const double *)b; return (x > y) - (x < y); }
static void info_summary(void) {
    if (!info) return;
    fprintf(info, "summary calls=%ld off_main=%ld presents=%ld polls=%ld poll_seconds=%.6f\n", calls, off_main, presents_n, polls, poll_seconds);
    long n = presents_n < MAX_PRESENTS ? presents_n : MAX_PRESENTS;
    if (n > 2) {
        static double gaps[MAX_PRESENTS];
        double sum = 0;
        for (long i = 1; i < n; i++) { gaps[i - 1] = (presents[i] - presents[i - 1]) * 1000.0; sum += gaps[i - 1]; }
        qsort(gaps, n - 1, sizeof gaps[0], by_value);
        fprintf(info, "frames intervals=%ld mean_ms=%.3f p50_ms=%.3f p90_ms=%.3f p99_ms=%.3f max_ms=%.3f\n", n - 1, sum / (n - 1),
                gaps[(n - 1) / 2], gaps[(n - 1) * 9 / 10], gaps[(n - 1) * 99 / 100], gaps[n - 2]);
    }
    fclose(info);
    info = NULL;
}
#define REAL(name) open_out(); note_call();
#else
#define REAL(name) static __typeof__(&name) real_##name; if (!real_##name) real_##name = (__typeof__(&name))dlsym(RTLD_NEXT, #name); open_out();
#endif
#define P(p) ((p) ? "ptr" : "null")

bool SDL_SetRenderDrawColor(void *r, uint8_t a, uint8_t b, uint8_t c, uint8_t d) {
    REAL(SDL_SetRenderDrawColor);
    bool ok = real_SDL_SetRenderDrawColor(r, a, b, c, d);
    fprintf(out, "color %s %u %u %u %u -> %d\n", P(r), a, b, c, d, ok); return ok;
}
bool SDL_RenderFillRect(void *r, const FRect *f) {
    REAL(SDL_RenderFillRect);
    bool ok = real_SDL_RenderFillRect(r, f);
    if (f) fprintf(out, "fill %s %a %a %a %a -> %d\n", P(r), f->x, f->y, f->w, f->h, ok); else fprintf(out, "fill %s null -> %d\n", P(r), ok);
    return ok;
}
bool SDL_RenderLine(void *r, float a, float b, float c, float d) {
    REAL(SDL_RenderLine);
    bool ok = real_SDL_RenderLine(r, a, b, c, d);
    fprintf(out, "line %s %a %a %a %a -> %d\n", P(r), a, b, c, d, ok); return ok;
}
bool SDL_RenderDebugText(void *r, float x, float y, const char *s) {
    REAL(SDL_RenderDebugText);
    bool ok = real_SDL_RenderDebugText(r, x, y, s);
    fprintf(out, "text %s %a %a \"%s\" -> %d\n", P(r), x, y, s ? s : "(null)", ok); return ok;
}
bool SDL_SetRenderScale(void *r, float x, float y) {
    REAL(SDL_SetRenderScale);
    bool ok = real_SDL_SetRenderScale(r, x, y);
    fprintf(out, "scale %s %a %a -> %d\n", P(r), x, y, ok); return ok;
}
bool SDL_RenderClear(void *r) { REAL(SDL_RenderClear); bool ok = real_SDL_RenderClear(r); fprintf(out, "clear %s -> %d\n", P(r), ok); return ok; }
bool SDL_RenderPresent(void *r) {
    REAL(SDL_RenderPresent);
    static long presents_made;
    bool ok = injected("SDL_RenderPresent", ++presents_made) ? false : real_SDL_RenderPresent(r);
    fprintf(out, "present %s -> %d\n", P(r), ok);
#ifdef SDLTRACE_LINKED
    double t = now();
    if (presents_n < MAX_PRESENTS) presents[presents_n] = t;
    if (!presents_n++ && info) {
        int w = 0, h = 0;
        SDL_GetRenderOutputSize(r, &w, &h);
        fprintf(info, "first-present since_start=%.6f output=%dx%d main=%d\n", t - t_start, w, h, on_main());
    }
#endif
    return ok;
}
bool SDL_PollEvent(void *e) {
    REAL(SDL_PollEvent);
#ifdef SDLTRACE_LINKED
    double t = now();
    bool ok = real_SDL_PollEvent(e);
    poll_seconds += now() - t;
    polls++;
#else
    bool ok = real_SDL_PollEvent(e);
#endif
    fprintf(out, "poll %s -> %d\n", P(e), ok); return ok;
}
const bool *SDL_GetKeyboardState(int *n) { REAL(SDL_GetKeyboardState); const bool *k = real_SDL_GetKeyboardState(n); fprintf(out, "keyboardstate %s -> %s\n", P(n), P(k)); return k; }
uint64_t SDL_GetTicksNS(void) { REAL(SDL_GetTicksNS); uint64_t t = real_SDL_GetTicksNS(); fprintf(out, "ticks\n"); return t; }
void SDL_DelayNS(uint64_t ns) { REAL(SDL_DelayNS); fprintf(out, "delay\n"); real_SDL_DelayNS(ns); }
uint64_t SDL_GetPerformanceCounter(void) { REAL(SDL_GetPerformanceCounter); fprintf(out, "counter\n"); return real_SDL_GetPerformanceCounter(); }
bool SDL_Init(uint32_t f) {
    REAL(SDL_Init);
#ifdef SDLTRACE_LINKED
    double t = now();
    bool ok = real_SDL_Init(f);
    if (info) {
        const char *driver = ok ? SDL_GetCurrentVideoDriver() : NULL;
        fprintf(info, "init ok=%d seconds=%.6f driver=%s main=%d\n", ok, now() - t, driver ? driver : "none", on_main());
    }
#else
    bool ok = real_SDL_Init(f);
#endif
    fprintf(out, "init %u -> %d\n", f, ok); return ok;
}
void SDL_Quit(void) {
    REAL(SDL_Quit);
    fprintf(out, "quit\n"); fflush(out);
    real_SDL_Quit();
#ifdef SDLTRACE_LINKED
    if (info) fprintf(info, "shutdown seconds=%.6f main=%d\n", t_shutdown ? now() - t_shutdown : 0.0, on_main());
    info_summary();
#endif
}
void *SDL_CreateWindow(const char *t, int w, int h, uint64_t f) {
    REAL(SDL_CreateWindow);
    static long windows_made;
    if (injected("SDL_CreateWindow", ++windows_made)) {
        fprintf(out, "createwindow \"%s\" %d %d %llu -> null (injected)\n", t, w, h, (unsigned long long)f);
        return NULL;
    }
#ifdef SDLTRACE_LINKED
    double t0 = now();
    void *p = real_SDL_CreateWindow(t, w, h, f);
    if (info) {
        int ww = 0, wh = 0, pw = 0, ph = 0;
        if (p) { SDL_GetWindowSize(p, &ww, &wh); SDL_GetWindowSizeInPixels(p, &pw, &ph); }
        fprintf(info, "window ok=%d seconds=%.6f size=%dx%d pixels=%dx%d main=%d\n", p != NULL, now() - t0, ww, wh, pw, ph, on_main());
    }
#else
    void *p = real_SDL_CreateWindow(t, w, h, f);
#endif
    fprintf(out, "createwindow \"%s\" %d %d %llu -> %s\n", t, w, h, (unsigned long long)f, P(p)); return p;
}
void *SDL_CreateRenderer(void *w, const char *n) {
    REAL(SDL_CreateRenderer);
#ifdef SDLTRACE_LINKED
    double t0 = now();
    void *p = real_SDL_CreateRenderer(w, n);
    if (info) {
        const char *name = p ? SDL_GetRendererName(p) : NULL;
        fprintf(info, "renderer ok=%d seconds=%.6f name=%s main=%d\n", p != NULL, now() - t0, name ? name : "none", on_main());
    }
#else
    void *p = real_SDL_CreateRenderer(w, n);
#endif
    fprintf(out, "createrenderer %s %s -> %s\n", P(w), P(n), P(p)); return p;
}
bool SDL_SetRenderLogicalPresentation(void *r, int w, int h, int m) { REAL(SDL_SetRenderLogicalPresentation); bool ok = real_SDL_SetRenderLogicalPresentation(r, w, h, m); fprintf(out, "logical %s %d %d %d -> %d\n", P(r), w, h, m, ok); return ok; }
bool SDL_SetRenderVSync(void *r, int v) { REAL(SDL_SetRenderVSync); bool ok = real_SDL_SetRenderVSync(r, v); fprintf(out, "vsync %s %d -> %d\n", P(r), v, ok); return ok; }
void SDL_DestroyRenderer(void *r) {
    REAL(SDL_DestroyRenderer);
#ifdef SDLTRACE_LINKED
    t_shutdown = now();
#endif
    fprintf(out, "destroyrenderer %s\n", P(r)); real_SDL_DestroyRenderer(r);
}
void SDL_DestroyWindow(void *w) { REAL(SDL_DestroyWindow); fprintf(out, "destroywindow %s\n", P(w)); real_SDL_DestroyWindow(w); }
void *SDL_malloc(size_t n) { REAL(SDL_malloc); void *p = real_SDL_malloc(n); fprintf(out, "malloc %zu -> %s\n", n, P(p)); return p; }
void SDL_free(void *p) { REAL(SDL_free); fprintf(out, "free %s\n", P(p)); real_SDL_free(p); }
