/* Probe D's host (ANDROID-SDL3-NATIVE-APPLICATION-ENTRY-CENSUS-MILESTONE-1.md):
 * the shape of SDL3's Android bootstrap (SDLActivity.java, SDL_android.c's
 * nativeRunMain), on Linux. The process's main thread plays Android's UI
 * thread: it starts a thread named "SDLThread" with a 1 MiB stack (ART's
 * default for a Java thread, which SDLActivity's `new Thread(new
 * SDLMain(), "SDLThread")` gets), and that thread calls
 * SDL_RunApp(argc, argv, SDL_main, NULL) -- what nativeRunMain does after
 * dlsym(library, "SDL_main"). SDL_main is the application's entry: here it
 * starts the Botlish entry computation (probe D1) through the library's
 * create function and returns its status. Nothing here knows the game.
 *
 * SDL_RunApp's generic implementation (src/main/SDL_runapp.c) calls
 * SDL_SetMainReady on this thread, which makes it SDL's main thread until
 * the video subsystem is initialized (src/SDL.c: SDL_IsMainThread). */
#define _GNU_SOURCE
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/syscall.h>
#include <unistd.h>
#include <SDL3/SDL_main.h>
#include "icy.h"

static int SDLCALL app_main(int argc, char **argv) {
    (void)argc; (void)argv;
    char name[16] = "";
    pthread_getname_np(pthread_self(), name, sizeof name);
    printf("bootstrap: SDL_main on thread %s (tid %ld), SDL_IsMainThread %d\n",
           name, (long)syscall(SYS_gettid), (int)SDL_IsMainThread());
    icy_instance *instance = NULL;
    icy_error *error = NULL;
    int32_t status = icy_create(&instance, &error);
    if (status != 0) {
        const uint8_t *p = NULL;
        size_t n = 0;
        icy_error_identity(error, &p, &n);
        printf("bootstrap: the application failed: status %d, %.*s\n", status, (int)n, (const char *)p);
        icy_error_release(&error);
        return 1;
    }
    printf("bootstrap: the application returned; destroy status %d\n", icy_destroy(instance));
    return 0;
}

static void *sdl_thread(void *unused) {
    (void)unused;
    pthread_setname_np(pthread_self(), "SDLThread");
    char *argv[] = {"app_process", NULL};
    int status = SDL_RunApp(1, argv, app_main, NULL);
    printf("bootstrap: SDL_RunApp returned %d\n", status);
    return NULL;
}

int main(void) {
    printf("bootstrap: UI thread tid %ld\n", (long)syscall(SYS_gettid));
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
