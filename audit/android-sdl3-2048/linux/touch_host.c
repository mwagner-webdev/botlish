/* touch_host.c -- a Linux host that starts a Botlish SDL3 application
 * library the way SDL3's Android bootstrap does, and feeds it touch and
 * lifecycle events the way Android does
 * (RN-BOTLISH-ANDROID-SDL3-2048-PACKAGE-MILESTONE-1.md, "Linux host
 * execution"; SDLActivity.java, SDL_android.c).
 *
 *   cc ... -DAPP_HEADER='"game.h"' -DAPP_PREFIX=game touch_host.c \
 *       -lgame -lSDL3 -pthread
 *   SCRIPT=events.txt ./host PROGRAM ARG...
 *
 * Threads, as on Android:
 *
 * * the process's main thread plays Android's UI thread: it starts a
 *   thread named "SDLThread" with a 1 MiB stack (ART's default for a Java
 *   thread), then reads the event script SCRIPT (when set) and pushes its
 *   events into SDL's queue with SDL_PushEvent -- from this thread, never
 *   the application's, exactly as SDLSurface.onTouch calls SDL_SendTouch
 *   on Android's UI thread -- and finally joins SDLThread;
 * * SDLThread calls SDL_RunApp(argc, argv, SDL_main, NULL); SDL_main calls
 *   the library's NAME_main(argc, argv, &error) and returns its status.
 *
 * The host knows nothing of the application: no game, no state, no
 * drawing. The script's lines (blank lines and # comments ignored):
 *
 *   ready              wait until SDL's video is initialized (at most 10 s)
 *   wait MS            sleep MS milliseconds
 *   down F X Y         SDL_EVENT_FINGER_DOWN of finger F at X, Y (0..1)
 *   motion F X Y       SDL_EVENT_FINGER_MOTION
 *   up F X Y           SDL_EVENT_FINGER_UP
 *   cancel F           SDL_EVENT_FINGER_CANCELED
 *   swipe F X1 Y1 X2 Y2   down at X1,Y1, four motions, up at X2,Y2
 *   tap F X Y          down and up at X, Y
 *   background         what Android's onPause makes SDL do: SDL's own
 *                      SDL_OnApplicationWillEnterBackground and
 *                      ..DidEnterBackground (SDL_androidevents.c's
 *                      Android_OnPause), so SDL decides what the queue gets
 *                      -- in SDL 3.4.18 the window's SDL_EVENT_WINDOW_MINIMIZED
 *                      (and a focus loss); its application events go to
 *                      watchers only
 *   foreground         onResume's: ..WillEnterForeground and
 *                      ..DidEnterForeground (SDL_EVENT_WINDOW_RESTORED)
 *   lowmemory          SDL_EVENT_LOW_MEMORY, pushed (SDL 3.4.18 never queues
 *                      it: this exercises the program's handler)
 *   resize             SDL_EVENT_WINDOW_PIXEL_SIZE_CHANGED
 *   reset              SDL_EVENT_RENDER_DEVICE_RESET
 *   back               SDL_EVENT_KEY_DOWN and _KEY_UP of SDL_SCANCODE_AC_BACK
 *                      (Android's back key, which SDL3 leaves to the program)
 *   quit               SDL_EVENT_QUIT
 *   terminate          SDL_EVENT_QUIT then SDL_EVENT_TERMINATING, pushed
 *                      (Android's Activity destruction queues the QUIT;
 *                      SDL 3.4.18 hands TERMINATING to watchers only, so the
 *                      push exercises the program's handler)
 *   mark               note SDLThread's CPU time and the time now
 *   cpu                report SDLThread's CPU time and the wall time since
 *                      the last mark ("host: SDLThread cpu C ms in W ms"):
 *                      an idle application's thread waits, it never spins
 *
 * It reports, on standard error, the thread SDL_main ran on, the
 * application's status and, for a failure, its error; with HOST_MARKS set,
 * also a line when a swipe's last event is pushed (measure.py times the
 * application's answer from it). */
#define _GNU_SOURCE
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include <SDL3/SDL.h>
#include <SDL3/SDL_main.h>
#include APP_HEADER

#define JOIN(a, b) a##_##b
#define NAME(a, b) JOIN(a, b)
#define APP(suffix) NAME(APP_PREFIX, suffix)

static int app_argc;
static char **app_argv;
static volatile int app_status = -1;
static pthread_t sdl_tid;

static int SDLCALL app_sdl_main(int argc, char **argv) {
    char name[16] = "";
    pthread_getname_np(pthread_self(), name, sizeof name);
    fprintf(stderr, "host: SDL_main on thread %s, SDL_IsMainThread %d\n", name, (int)SDL_IsMainThread());
    APP(error) *error = NULL;
    int32_t status = APP(main)(argc, argv, &error);
    app_status = status;
    if (status != 0) {
        const uint8_t *p = NULL, *m = NULL;
        size_t n = 0, mn = 0;
        APP(error_identity)(error, &p, &n);
        APP(error_message)(error, &m, &mn);
        fprintf(stderr, "host: the application failed: status %d, %.*s: %.*s\n", (int)status, (int)n, (const char *)p,
                (int)mn, (const char *)m);
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

static void sleep_ms(long ms) {
    struct timespec t = {ms / 1000, (ms % 1000) * 1000000L};
    nanosleep(&t, NULL);
}

static Uint64 now_ns(void) {
    struct timespec t;
    clock_gettime(CLOCK_MONOTONIC, &t);
    return (Uint64)t.tv_sec * 1000000000ull + (Uint64)t.tv_nsec;
}

/* SDLThread's CPU time, in nanoseconds (0 when it cannot be read). */
static Uint64 sdl_cpu_ns(void) {
    clockid_t clock;
    struct timespec t;
    if (pthread_getcpuclockid(sdl_tid, &clock) != 0 || clock_gettime(clock, &t) != 0) return 0;
    return (Uint64)t.tv_sec * 1000000000ull + (Uint64)t.tv_nsec;
}

static void push_type(Uint32 type) {
    SDL_Event e;
    memset(&e, 0, sizeof e);
    e.type = type;
    e.common.timestamp = now_ns();
    if (!SDL_PushEvent(&e)) fprintf(stderr, "host: SDL_PushEvent failed: %s\n", SDL_GetError());
}

static void push_finger(Uint32 type, long finger, float x, float y) {
    SDL_Event e;
    memset(&e, 0, sizeof e);
    e.type = type;
    e.tfinger.timestamp = now_ns();
    e.tfinger.touchID = 1;
    e.tfinger.fingerID = (SDL_FingerID)finger;
    e.tfinger.x = x;
    e.tfinger.y = y;
    e.tfinger.pressure = 1.0f;
    if (!SDL_PushEvent(&e)) fprintf(stderr, "host: SDL_PushEvent failed: %s\n", SDL_GetError());
}

static void push_key(Uint32 type, SDL_Scancode code) {
    SDL_Event e;
    memset(&e, 0, sizeof e);
    e.type = type;
    e.key.timestamp = now_ns();
    e.key.scancode = code;
    e.key.down = type == SDL_EVENT_KEY_DOWN;
    if (!SDL_PushEvent(&e)) fprintf(stderr, "host: SDL_PushEvent failed: %s\n", SDL_GetError());
}

static void run_script(const char *path) {
    FILE *f = fopen(path, "r");
    if (!f) {
        perror(path);
        return;
    }
    char line[256];
    Uint64 mark_cpu = 0, mark_wall = now_ns();
    while (fgets(line, sizeof line, f)) {
        char word[32] = "";
        long a = 0;
        float x1 = 0, y1 = 0, x2 = 0, y2 = 0;
        if (sscanf(line, "%31s", word) != 1 || word[0] == '#') continue;
        if (!strcmp(word, "ready")) {
            for (int i = 0; i < 1000 && !(SDL_WasInit(SDL_INIT_VIDEO) & SDL_INIT_VIDEO); i++) sleep_ms(10);
            sleep_ms(100);
        } else if (!strcmp(word, "wait") && sscanf(line, "%*s %ld", &a) == 1) {
            sleep_ms(a);
        } else if (!strcmp(word, "down") && sscanf(line, "%*s %ld %f %f", &a, &x1, &y1) == 3) {
            push_finger(SDL_EVENT_FINGER_DOWN, a, x1, y1);
        } else if (!strcmp(word, "motion") && sscanf(line, "%*s %ld %f %f", &a, &x1, &y1) == 3) {
            push_finger(SDL_EVENT_FINGER_MOTION, a, x1, y1);
        } else if (!strcmp(word, "up") && sscanf(line, "%*s %ld %f %f", &a, &x1, &y1) == 3) {
            push_finger(SDL_EVENT_FINGER_UP, a, x1, y1);
        } else if (!strcmp(word, "cancel") && sscanf(line, "%*s %ld", &a) == 1) {
            push_finger(SDL_EVENT_FINGER_CANCELED, a, 0, 0);
        } else if (!strcmp(word, "swipe") && sscanf(line, "%*s %ld %f %f %f %f", &a, &x1, &y1, &x2, &y2) == 5) {
            push_finger(SDL_EVENT_FINGER_DOWN, a, x1, y1);
            for (int i = 1; i <= 4; i++) push_finger(SDL_EVENT_FINGER_MOTION, a, x1 + (x2 - x1) * i / 5, y1 + (y2 - y1) * i / 5);
            push_finger(SDL_EVENT_FINGER_UP, a, x2, y2);
            if (getenv("HOST_MARKS")) fprintf(stderr, "host: swipe pushed\n");
        } else if (!strcmp(word, "tap") && sscanf(line, "%*s %ld %f %f", &a, &x1, &y1) == 3) {
            push_finger(SDL_EVENT_FINGER_DOWN, a, x1, y1);
            push_finger(SDL_EVENT_FINGER_UP, a, x1, y1);
        } else if (!strcmp(word, "background")) {
            SDL_OnApplicationWillEnterBackground();
            SDL_OnApplicationDidEnterBackground();
        } else if (!strcmp(word, "foreground")) {
            SDL_OnApplicationWillEnterForeground();
            SDL_OnApplicationDidEnterForeground();
        } else if (!strcmp(word, "lowmemory")) {
            push_type(SDL_EVENT_LOW_MEMORY);
        } else if (!strcmp(word, "resize")) {
            push_type(SDL_EVENT_WINDOW_PIXEL_SIZE_CHANGED);
        } else if (!strcmp(word, "reset")) {
            push_type(SDL_EVENT_RENDER_DEVICE_RESET);
        } else if (!strcmp(word, "back")) {
            push_key(SDL_EVENT_KEY_DOWN, SDL_SCANCODE_AC_BACK);
            push_key(SDL_EVENT_KEY_UP, SDL_SCANCODE_AC_BACK);
        } else if (!strcmp(word, "quit")) {
            push_type(SDL_EVENT_QUIT);
        } else if (!strcmp(word, "terminate")) {
            push_type(SDL_EVENT_QUIT);
            push_type(SDL_EVENT_TERMINATING);
        } else if (!strcmp(word, "mark")) {
            mark_cpu = sdl_cpu_ns();
            mark_wall = now_ns();
        } else if (!strcmp(word, "cpu")) {
            fprintf(stderr, "host: SDLThread cpu %llu ms in %llu ms\n", (unsigned long long)((sdl_cpu_ns() - mark_cpu) / 1000000u),
                    (unsigned long long)((now_ns() - mark_wall) / 1000000u));
        } else {
            fprintf(stderr, "host: unknown script line: %s", line);
        }
    }
    fclose(f);
}

int main(int argc, char **argv) {
    if (argc < 2) {
        fprintf(stderr, "usage: [SCRIPT=FILE] %s PROGRAM ARG...\n", argv[0]);
        return 2;
    }
    app_argc = argc - 1;
    app_argv = argv + 1;
    pthread_attr_t attr;
    pthread_attr_init(&attr);
    pthread_attr_setstacksize(&attr, 1024 * 1024);
    if (pthread_create(&sdl_tid, &attr, sdl_thread, NULL) != 0) {
        perror("pthread_create");
        return 1;
    }
    const char *script = getenv("SCRIPT");
    if (script && *script) run_script(script);
    pthread_join(sdl_tid, NULL);
    return app_status == 0 ? 0 : 1;
}
