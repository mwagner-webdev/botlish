/* host_main.c -- an Android process that starts an application library's
 * entry the way SDLActivity does, without ART (RN-HOST-STARTABLE-
 * APPLICATION-LIBRARY-MILESTONE-1.md, "Android execution"): a thread named
 * SDLThread with a 1 MiB stack calls NAME_main(argc, argv, &error), twice,
 * and prints the statuses. Run by Android's linker64 and Bionic (the
 * emulator images' userspace, audit/android-aarch64-target/tools/
 * android-run.sh) under qemu-user: Android's dynamic linker, C library and
 * pthreads, not an Activity. The application's own output goes to liblog,
 * which writes to standard error where no log daemon runs. Built with
 * -DNO_HEAP_POINTER_TAGGING it first turns Bionic's heap pointer tagging
 * off (Android 11+ tags every heap pointer's top byte, which no C address
 * word holds: the report's "Tagged heap pointers"). */
#include <dlfcn.h>
#include <malloc.h>
#include <pthread.h>
#include <stdio.h>
#include <stdint.h>
#include APP_HEADER

#define JOIN(a, b) a##_##b
#define NAME(a, b) JOIN(a, b)
#define APP(suffix) NAME(APP_PREFIX, suffix)

static int g_argc;
static char **g_argv;

static void *sdl_thread(void *unused) {
    (void)unused;
    pthread_setname_np(pthread_self(), "SDLThread");
    for (int round = 0; round < 2; round++) {
        APP(error) *error = NULL;
        int32_t status = APP(main)(g_argc, g_argv, &error);
        printf("MAIN\t%d\t%d", round, (int)status);
        if (error != NULL) {
            const uint8_t *p = NULL, *m = NULL;
            size_t n = 0, l = 0;
            APP(error_identity)(error, &p, &n);
            APP(error_message)(error, &m, &l);
            printf("\t%.*s\t%.*s", (int)n, (const char *)p, (int)l, (const char *)m);
        }
        printf("\n");
        fflush(stdout);
        APP(error_release)(&error);
    }
    return NULL;
}

int main(int argc, char **argv) {
#ifdef NO_HEAP_POINTER_TAGGING
    /* What an application's android:allowNativeHeapPointerTagging="false"
     * does: Bionic's heap allocations without the top-byte tag Android 11+
     * gives them (a C address word holds 60 bits). */
    /* mallopt is API 26's (this host is built for 21): looked up. */
    int (*set)(int, int) = (int (*)(int, int))dlsym(RTLD_DEFAULT, "mallopt");
    printf("TAGGING\t%s\n", set != NULL && set(M_BIONIC_SET_HEAP_TAGGING_LEVEL, M_HEAP_TAGGING_LEVEL_NONE) == 1 ? "off" : "unchanged");
#endif
    g_argc = argc;
    g_argv = argv;
    pthread_attr_t attr;
    pthread_attr_init(&attr);
    pthread_attr_setstacksize(&attr, 1024 * 1024);
    pthread_t t;
    if (pthread_create(&t, &attr, sdl_thread, NULL) != 0) return 1;
    pthread_join(t, NULL);
    printf("HOST\tdone\n");
    return 0;
}
