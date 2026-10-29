/* mtprobe_sdl.c -- the SDL half of the observation fixture (mtprobe.c):
 * what SDL says, read, never an operation of the program's. */
#include <SDL3/SDL.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#ifdef __APPLE__
#include <objc/message.h>
#include <objc/runtime.h>
#include <spawn.h>
#include <sys/wait.h>
extern char **environ;
#endif

extern int mtp_is_process_main(void);
extern int mtp_threads(void);
extern long long mtp_now_ns(void);
extern const char *mtp_stage_name(int stage);
extern void mtp_json_text(FILE *f, const char *text);
#define now_ns mtp_now_ns

/* What SDL says at STAGE about the operation the program just made: OK and
 * SDL_IS_MAIN are the program's own call results (Botlish's), the error and
 * driver this file reads. Returns OK. */
bool mtp_sdl(int stage, bool ok, bool sdl_is_main) {
    fprintf(stderr, "MTP {\"kind\":\"sdl\",\"stage\":\"%s\",\"ok\":%s,\"sdl_is_main\":%s,\"pthread_main\":%d,\"error\":",
            mtp_stage_name(stage), ok ? "true" : "false", sdl_is_main ? "true" : "false", mtp_is_process_main());
    mtp_json_text(stderr, SDL_GetError());
    fputs(",\"driver\":", stderr);
    mtp_json_text(stderr, SDL_WasInit(SDL_INIT_VIDEO) ? SDL_GetCurrentVideoDriver() : NULL);
    fprintf(stderr, ",\"t_ns\":%lld,\"threads\":%d}\n", now_ns(), mtp_threads());
    fflush(stderr);
    return ok;
}

/* The renderer the program made: its name (metal, opengl, software ...). */
int mtp_renderer(SDL_Renderer *renderer) {
    fputs("MTP {\"kind\":\"renderer\",\"name\":", stderr);
    mtp_json_text(stderr, renderer ? SDL_GetRendererName(renderer) : NULL);
    fprintf(stderr, ",\"pthread_main\":%d}\n", mtp_is_process_main());
    fflush(stderr);
    return renderer != NULL;
}

#ifdef __APPLE__
/* The NSWindow's windowNumber: what screencapture -l and CGWindowList take. */
static long window_number(void *nswindow) {
    if (!nswindow) return -1;
    long (*send)(id, SEL) = (long (*)(id, SEL))objc_msgSend;
    return send((id)nswindow, sel_registerName("windowNumber"));
}
#endif

/* The window the program made: SDL's ID and flags, and its Cocoa window. */
int mtp_window(SDL_Window *window) {
    void *native = NULL;
    long number = -1;
    unsigned long long flags = 0;
    if (window) {
        flags = (unsigned long long)SDL_GetWindowFlags(window);
#ifdef __APPLE__
        native = SDL_GetPointerProperty(SDL_GetWindowProperties(window), SDL_PROP_WINDOW_COCOA_WINDOW_POINTER, NULL);
        number = window_number(native);
#endif
    }
    fprintf(stderr, "MTP {\"kind\":\"window\",\"id\":%u,\"flags\":%llu,\"cocoa_window\":%s,\"window_number\":%ld,\"pthread_main\":%d}\n",
            window ? (unsigned)SDL_GetWindowID(window) : 0u, flags, native ? "true" : "false", number, mtp_is_process_main());
    fflush(stderr);
    return window != NULL;
}

/* A capture of WINDOW's pixels into $MTP_CAPTURE (macOS: screencapture -x
 * -o -l NUMBER), when that variable names a file. Prints its outcome;
 * returns screencapture's exit status, or -1 when nothing was attempted. */
int mtp_capture(SDL_Window *window) {
#ifdef __APPLE__
    const char *path = getenv("MTP_CAPTURE");
    if (!path || !*path || !window) return -1;
    void *native = SDL_GetPointerProperty(SDL_GetWindowProperties(window), SDL_PROP_WINDOW_COCOA_WINDOW_POINTER, NULL);
    char number[32];
    snprintf(number, sizeof number, "%ld", window_number(native));
    char *argv[] = {"/usr/sbin/screencapture", "-x", "-o", "-l", number, (char *)path, NULL};
    pid_t pid;
    int status = -1;
    if (posix_spawn(&pid, argv[0], NULL, NULL, argv, environ) == 0) waitpid(pid, &status, 0);
    FILE *f = fopen(path, "rb");
    long size = -1;
    if (f) { fseek(f, 0, SEEK_END); size = ftell(f); fclose(f); }
    fprintf(stderr, "MTP {\"kind\":\"capture\",\"window_number\":%s,\"status\":%d,\"bytes\":%ld}\n", number, status, size);
    fflush(stderr);
    return status;
#else
    (void)window;
    return -1;
#endif
}

