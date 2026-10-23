// sdltrace.c -- an LD_PRELOAD interposer for ICY-TOWER-CONTEXT-REFACTOR-CENSUS.md:
// logs every SDL call the Icy Tower executable makes that draws, polls, times
// or manages resources, with its arguments (a rectangle's contents and every
// float in C99 hex, a string's text, a color), one line per call, to the file
// named by SDLTRACE. Pointers are logged as "null" or "ptr" only, so two runs
// (two builds of the game) compare line by line: trace-compare.sh.
#define _GNU_SOURCE
#include <dlfcn.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <stdarg.h>

typedef struct { float x, y, w, h; } FRect;
static FILE *out;
static void open_out(void) {
    if (!out) { const char *p = getenv("SDLTRACE"); out = fopen(p ? p : "/dev/null", "w"); setvbuf(out, NULL, _IOFBF, 1 << 20); }
}
#define REAL(name) static __typeof__(&name) real_##name; if (!real_##name) real_##name = (__typeof__(&name))dlsym(RTLD_NEXT, #name); open_out();
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
bool SDL_RenderPresent(void *r) { REAL(SDL_RenderPresent); bool ok = real_SDL_RenderPresent(r); fprintf(out, "present %s -> %d\n", P(r), ok); return ok; }
bool SDL_PollEvent(void *e) { REAL(SDL_PollEvent); bool ok = real_SDL_PollEvent(e); fprintf(out, "poll %s -> %d\n", P(e), ok); return ok; }
const bool *SDL_GetKeyboardState(int *n) { REAL(SDL_GetKeyboardState); const bool *k = real_SDL_GetKeyboardState(n); fprintf(out, "keyboardstate %s -> %s\n", P(n), P(k)); return k; }
uint64_t SDL_GetTicksNS(void) { REAL(SDL_GetTicksNS); uint64_t t = real_SDL_GetTicksNS(); fprintf(out, "ticks\n"); return t; }
void SDL_DelayNS(uint64_t ns) { REAL(SDL_DelayNS); fprintf(out, "delay\n"); real_SDL_DelayNS(ns); }
uint64_t SDL_GetPerformanceCounter(void) { REAL(SDL_GetPerformanceCounter); fprintf(out, "counter\n"); return real_SDL_GetPerformanceCounter(); }
bool SDL_Init(uint32_t f) { REAL(SDL_Init); bool ok = real_SDL_Init(f); fprintf(out, "init %u -> %d\n", f, ok); return ok; }
void SDL_Quit(void) { REAL(SDL_Quit); fprintf(out, "quit\n"); fflush(out); real_SDL_Quit(); }
void *SDL_CreateWindow(const char *t, int w, int h, uint64_t f) { REAL(SDL_CreateWindow); void *p = real_SDL_CreateWindow(t, w, h, f); fprintf(out, "createwindow \"%s\" %d %d %llu -> %s\n", t, w, h, (unsigned long long)f, P(p)); return p; }
void *SDL_CreateRenderer(void *w, const char *n) { REAL(SDL_CreateRenderer); void *p = real_SDL_CreateRenderer(w, n); fprintf(out, "createrenderer %s %s -> %s\n", P(w), P(n), P(p)); return p; }
bool SDL_SetRenderLogicalPresentation(void *r, int w, int h, int m) { REAL(SDL_SetRenderLogicalPresentation); bool ok = real_SDL_SetRenderLogicalPresentation(r, w, h, m); fprintf(out, "logical %s %d %d %d -> %d\n", P(r), w, h, m, ok); return ok; }
bool SDL_SetRenderVSync(void *r, int v) { REAL(SDL_SetRenderVSync); bool ok = real_SDL_SetRenderVSync(r, v); fprintf(out, "vsync %s %d -> %d\n", P(r), v, ok); return ok; }
void SDL_DestroyRenderer(void *r) { REAL(SDL_DestroyRenderer); fprintf(out, "destroyrenderer %s\n", P(r)); real_SDL_DestroyRenderer(r); }
void SDL_DestroyWindow(void *w) { REAL(SDL_DestroyWindow); fprintf(out, "destroywindow %s\n", P(w)); real_SDL_DestroyWindow(w); }
void *SDL_malloc(size_t n) { REAL(SDL_malloc); void *p = real_SDL_malloc(n); fprintf(out, "malloc %zu -> %s\n", n, P(p)); return p; }
void SDL_free(void *p) { REAL(SDL_free); fprintf(out, "free %s\n", P(p)); real_SDL_free(p); }
