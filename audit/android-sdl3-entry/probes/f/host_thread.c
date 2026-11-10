/* Probe F's host (ANDROID-SDL3-NATIVE-APPLICATION-ENTRY-CENSUS-MILESTONE-1.md):
 * starts a Botlish entry computation on a thread the host made (as
 * SDLActivity makes "SDLThread"), with the stack size given on the command
 * line, through the library's create function -- which runs the program
 * function, the entry program's top level included, once LIBRARY-TOP-LEVEL
 * no longer refuses it. Prints the status and the error's identity. */
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include ENTRY_HEADER

static void *app(void *unused) {
    (void)unused;
    ENTRY_PREFIX(instance) *instance = NULL;
    ENTRY_PREFIX(error) *error = NULL;
    int32_t status = ENTRY_PREFIX(create)(&instance, &error);
    if (status != 0) {
        const uint8_t *p = NULL;
        size_t n = 0;
        ENTRY_PREFIX(error_identity)(error, &p, &n);
        printf("host: create status %d, identity %.*s\n", status, (int)n, (const char *)p);
        ENTRY_PREFIX(error_release)(&error);
        return NULL;
    }
    printf("host: create status 0 (the entry ran to its end)\n");
    printf("host: destroy status %d\n", ENTRY_PREFIX(destroy)(instance));
    return NULL;
}

int main(int argc, char **argv) {
    size_t stack = (argc > 1 ? (size_t)atol(argv[1]) : 1024) * 1024;
    pthread_attr_t attr;
    pthread_attr_init(&attr);
    pthread_attr_setstacksize(&attr, stack);
    pthread_t t;
    if (pthread_create(&t, &attr, app, NULL) != 0) {
        perror("pthread_create");
        return 1;
    }
    pthread_join(t, NULL);
    return 0;
}
