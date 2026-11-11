/* sdl_runapp_host.c -- a host that starts a Botlish application library the
 * way SDL3's Android bootstrap starts an application
 * (RN-HOST-STARTABLE-APPLICATION-LIBRARY-MILESTONE-1.md, "SDL3/Icy Tower
 * integration"; SDLActivity.java and SDL_android.c's nativeRunMain): the
 * process's main thread plays Android's UI thread and starts a thread named
 * "SDLThread" with a 1 MiB stack (ART's default for a Java thread); that
 * thread calls SDL_RunApp(argc, argv, SDL_main, NULL), and SDL_main calls
 * the library's NAME_main(argc, argv, &error) and returns its status. The
 * host knows nothing of the application: its arguments are this program's
 * own, passed on unchanged.
 *
 *   cc ... -DAPP_HEADER='"icy.h"' -DAPP_PREFIX=icy sdl_runapp_host.c \
 *       -licy -lSDL3 -pthread
 *   ./host PROGRAM ARG...     (argv[0] of the application is PROGRAM)
 */
#define _GNU_SOURCE
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/syscall.h>
#include <unistd.h>
#include <SDL3/SDL_main.h>
#include APP_HEADER

#define JOIN(a, b) a##_##b
#define NAME(a, b) JOIN(a, b)
#define APP(suffix) NAME(APP_PREFIX, suffix)

static int app_argc;
static char **app_argv;

static int SDLCALL app_sdl_main(int argc, char **argv) {
    char name[16] = "";
    pthread_getname_np(pthread_self(), name, sizeof name);
    fprintf(stderr, "host: SDL_main on thread %s, SDL_IsMainThread %d\n", name, (int)SDL_IsMainThread());
    APP(error) *error = NULL;
    int32_t status = APP(main)(argc, argv, &error);
    if (status != 0) {
        const uint8_t *p = NULL;
        size_t n = 0;
        APP(error_identity)(error, &p, &n);
        fprintf(stderr, "host: the application failed: status %d, %.*s\n", (int)status, (int)n, (const char *)p);
        APP(error_release)(&error);
        return 1;
    }
    fprintf(stderr, "host: the application returned 0\n");
    return 0;
}

static void *sdl_thread(void *unused) {
    (void)unused;
    pthread_setname_np(pthread_self(), "SDLThread");
    int status = SDL_RunApp(app_argc, app_argv, app_sdl_main, NULL);
    fprintf(stderr, "host: SDL_RunApp returned %d\n", status);
    return NULL;
}

int main(int argc, char **argv) {
    if (argc < 2) {
        fprintf(stderr, "usage: %s PROGRAM ARG...\n", argv[0]);
        return 2;
    }
    app_argc = argc - 1;
    app_argv = argv + 1;
    pthread_attr_t attr;
    pthread_attr_init(&attr);
    pthread_attr_setstacksize(&attr, 1024 * 1024);
    pthread_t t;
    if (pthread_create(&t, &attr, sdl_thread, NULL) != 0) {
        perror("pthread_create");
        return 1;
    }
    pthread_join(t, NULL);
    return 0;
}
