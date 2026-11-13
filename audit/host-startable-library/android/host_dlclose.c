/* host_dlclose.c -- the dynamic loader's side of an application library on
 * Android (RN-HOST-STARTABLE-APPLICATION-LIBRARY-MILESTONE-1.md, "Dynamic
 * loader and TLS lifetime"): what SDL's nativeRunMain does around SDL_main
 * -- dlopen the library, run the entry on a thread, dlclose it -- with the
 * one order that can go wrong: the library unloaded while the thread that
 * ran NAME_main lives on, the thread ending afterwards (its thread-local
 * destructors run then). Prints MAIN STATUS, UNLOADED (whether the
 * library's mapping is gone after dlclose) and SURVIVED once the thread has
 * ended: a destructor left in unmapped code would crash the process first.
 * MODE says how the library is held:
 *
 *   unload    one handle, closed while the thread lives: the order the
 *             report's lifetime rule forbids (on Android, where Rust's
 *             thread-locals are pthread keys with destructors, the thread's
 *             end then runs unmapped code)
 *   kept      a second handle opened first and never closed, as
 *             SDLActivity's System.loadLibrary of every library in
 *             getLibraries() holds the application library while
 *             nativeRunMain dlopens and dlcloses libmain.so
 *   nodelete  the one handle opened with RTLD_NODELETE: a shim's pin
 *
 *   host_dlclose LIBRARY SYMBOL MODE   (SYMBOL: the library's NAME_main) */
#include <dlfcn.h>
#include <pthread.h>
#include <semaphore.h>
#include <stdio.h>
#include <string.h>

typedef int (*main_fn)(int, char **, void **);
static main_fn app_main;
static sem_t ran, may_exit;

static int mapped(const char *path) {
    const char *name = strrchr(path, '/');
    name = name ? name + 1 : path;
    FILE *f = fopen("/proc/self/maps", "r");
    char line[4096];
    int n = 0;
    while (f && fgets(line, sizeof line, f)) if (strstr(line, name)) n++;
    if (f) fclose(f);
    return n;
}

static void *thread(void *unused) {
    (void)unused;
    char *argv[] = {"app", NULL};
    void *error = NULL;
    printf("MAIN\t%d\n", app_main(1, argv, &error));
    fflush(stdout);
    sem_post(&ran);
    sem_wait(&may_exit);
    return NULL;
}

int main(int argc, char **argv) {
    if (argc != 4) return 2;
    const char *mode = argv[3];
    if (strcmp(mode, "kept") == 0 && dlopen(argv[1], RTLD_NOW | RTLD_LOCAL) == NULL) {
        printf("DLOPEN\t%s\n", dlerror());
        return 1;
    }
    int flags = RTLD_NOW | RTLD_LOCAL | (strcmp(mode, "nodelete") == 0 ? RTLD_NODELETE : 0);
    void *handle = dlopen(argv[1], flags);
    if (handle == NULL) { printf("DLOPEN\t%s\n", dlerror()); return 1; }
    app_main = (main_fn)dlsym(handle, argv[2]);
    if (app_main == NULL) { printf("DLSYM\t%s\n", dlerror()); return 1; }
    sem_init(&ran, 0, 0);
    sem_init(&may_exit, 0, 0);
    pthread_t t;
    pthread_create(&t, NULL, thread, NULL);
    sem_wait(&ran);
    dlclose(handle);
    printf("UNLOADED\t%s\n", mapped(argv[1]) == 0 ? "yes" : "no");
    fflush(stdout);
    sem_post(&may_exit);
    pthread_join(t, NULL);
    printf("SURVIVED\n");
    return 0;
}
