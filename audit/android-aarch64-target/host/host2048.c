/* host2048.c -- a minimal Android host of a Botlish native library
 * (ANDROID-AARCH64-TARGET-SUPPORT-MILESTONE-1.md, "Android execution").
 *
 * Test infrastructure, not an application: it loads the 2048 library the
 * distributed compiler built for android-aarch64 with dlopen, as an
 * application's System.loadLibrary would, resolves its exports with dlsym,
 * and drives them through the C ABI the library's header and manifest
 * state. Built by the NDK's clang for aarch64-linux-androidN and run by
 * Android's own dynamic linker (linker64) and Bionic.
 *
 *   host2048 LIB.so play          reads a script on standard input (one
 *                                 command per line, tab-separated words,
 *                                 "@" standing for the last state a command
 *                                 returned) and prints one line per command:
 *                                 STATE text | INT n | BOOL 0|1 |
 *                                 ERROR status identity
 *   host2048 LIB.so lifecycle N   N instances created, each playing a short
 *                                 game, destroyed; two instances interleaved;
 *                                 a destroyed instance refused
 *   host2048 LIB.so thread        an instance called from another thread
 *                                 than the one that created it is refused
 *                                 (WRONG-THREAD), and still works on its own
 *
 * Every str result is released with game_bytes_release and every error
 * with game_error_release, as the manifest's ownership says; a leak or a
 * double release would be the library's INVALID-RELEASE or a crash.
 */
#include <dlfcn.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "game.h"

#define FN(name) static __typeof__(&name) p_##name
FN(game_abi_version);
FN(game_create);
FN(game_destroy);
FN(game_error_release);
FN(game_error_status);
FN(game_error_identity);
FN(game_bytes_release);
FN(game_new_game);
FN(game_move);
FN(game_changes);
FN(game_spawn);
FN(game_first_empty);
FN(game_spawn_first);
FN(game_score);
FN(game_over);

static void *library;

static void *need(const char *name) {
    void *symbol = dlsym(library, name);
    if (!symbol) {
        fprintf(stderr, "host2048: %s: %s\n", name, dlerror());
        exit(3);
    }
    return symbol;
}

static void load(const char *path) {
    library = dlopen(path, RTLD_NOW | RTLD_LOCAL);
    if (!library) {
        fprintf(stderr, "host2048: dlopen %s: %s\n", path, dlerror());
        exit(3);
    }
#define RESOLVE(name) p_##name = (__typeof__(p_##name))need(#name)
    RESOLVE(game_abi_version);
    RESOLVE(game_create);
    RESOLVE(game_destroy);
    RESOLVE(game_error_release);
    RESOLVE(game_error_status);
    RESOLVE(game_error_identity);
    RESOLVE(game_bytes_release);
    RESOLVE(game_new_game);
    RESOLVE(game_move);
    RESOLVE(game_changes);
    RESOLVE(game_spawn);
    RESOLVE(game_first_empty);
    RESOLVE(game_spawn_first);
    RESOLVE(game_score);
    RESOLVE(game_over);
    if (p_game_abi_version() != game_ABI_VERSION) {
        fprintf(stderr, "host2048: C ABI version %u, header %d\n", p_game_abi_version(), game_ABI_VERSION);
        exit(3);
    }
}

/* Prints the error ERR ("ERROR status identity") and releases it. */
static void report_error(game_error *err) {
    const uint8_t *id = NULL;
    size_t len = 0;
    int status = p_game_error_status(err);
    p_game_error_identity(err, &id, &len);
    printf("ERROR\t%d\t%.*s\n", status, (int)len, (const char *)id);
    if (p_game_error_release(&err) != game_STATUS_OK || err != NULL) {
        fprintf(stderr, "host2048: game_error_release failed\n");
        exit(4);
    }
}

/* The last state a command returned (owned here, a copy). */
static char last[4096] = "";

static void report_state(int status, game_bytes *bytes, game_error *err) {
    if (status != game_STATUS_OK) {
        report_error(err);
        return;
    }
    if (bytes->len >= sizeof last || bytes->ptr[bytes->len] != 0) {
        fprintf(stderr, "host2048: a state result is not NUL-terminated after its length\n");
        exit(4);
    }
    memcpy(last, bytes->ptr, bytes->len + 1);
    printf("STATE\t%s\n", last);
    if (p_game_bytes_release(bytes) != game_STATUS_OK || bytes->ptr != NULL) {
        fprintf(stderr, "host2048: game_bytes_release failed\n");
        exit(4);
    }
}

static const char *arg(char *word) { return strcmp(word, "@") == 0 ? last : word; }

static int play(game_instance *g, FILE *in) {
    char line[8192];
    while (fgets(line, sizeof line, in)) {
        line[strcspn(line, "\n")] = 0;
        char *words[8] = {0};
        int n = 0;
        for (char *w = strtok(line, "\t"); w && n < 8; w = strtok(NULL, "\t")) {
            words[n++] = w;
        }
        if (n == 0) continue;
        game_bytes bytes = {0};
        game_error *err = NULL;
        const char *s = n > 1 ? arg(words[1]) : "";
        char state[4096];
        snprintf(state, sizeof state, "%s", s);
        size_t len = strlen(state);
        const uint8_t *p = (const uint8_t *)state;
        if (strcmp(words[0], "new_game") == 0) {
            report_state(p_game_new_game(g, &bytes, &err), &bytes, err);
        } else if (strcmp(words[0], "move") == 0) {
            report_state(p_game_move(g, p, len, atoll(words[2]), &bytes, &err), &bytes, err);
        } else if (strcmp(words[0], "spawn_first") == 0) {
            report_state(p_game_spawn_first(g, p, len, atoll(words[2]), &bytes, &err), &bytes, err);
        } else if (strcmp(words[0], "spawn") == 0) {
            report_state(p_game_spawn(g, p, len, atoll(words[2]), atoll(words[3]), atoll(words[4]), &bytes, &err), &bytes, err);
        } else if (strcmp(words[0], "score") == 0 || strcmp(words[0], "first_empty") == 0) {
            int64_t value = 0;
            int status = strcmp(words[0], "score") == 0 ? p_game_score(g, p, len, &value, &err)
                                                        : p_game_first_empty(g, p, len, &value, &err);
            if (status == game_STATUS_OK) printf("INT\t%lld\n", (long long)value); else report_error(err);
        } else if (strcmp(words[0], "over") == 0 || strcmp(words[0], "changes") == 0) {
            bool value = false;
            int status = strcmp(words[0], "over") == 0 ? p_game_over(g, p, len, &value, &err)
                                                       : p_game_changes(g, p, len, atoll(words[2]), &value, &err);
            if (status == game_STATUS_OK) printf("BOOL\t%d\n", value ? 1 : 0); else report_error(err);
        } else {
            fprintf(stderr, "host2048: unknown command %s\n", words[0]);
            return 2;
        }
    }
    return 0;
}

static game_instance *create(void) {
    game_instance *g = NULL;
    game_error *err = NULL;
    if (p_game_create(&g, &err) != game_STATUS_OK) {
        report_error(err);
        exit(5);
    }
    return g;
}

/* A short game on instance G: a new game, two spawns, moves; returns the score. */
static long long short_game(game_instance *g) {
    game_bytes bytes = {0};
    game_error *err = NULL;
    char state[4096];
    if (p_game_new_game(g, &bytes, &err) != game_STATUS_OK) { report_error(err); exit(6); }
    snprintf(state, sizeof state, "%s", (char *)bytes.ptr);
    p_game_bytes_release(&bytes);
    for (int i = 0; i < 24; i++) {
        int status = (i % 2 == 0)
            ? p_game_spawn_first(g, (const uint8_t *)state, strlen(state), i % 3 == 0 ? 4 : 2, &bytes, &err)
            : p_game_move(g, (const uint8_t *)state, strlen(state), i % 4, &bytes, &err);
        if (status != game_STATUS_OK) { report_error(err); exit(6); }
        snprintf(state, sizeof state, "%s", (char *)bytes.ptr);
        p_game_bytes_release(&bytes);
    }
    int64_t score = 0;
    if (p_game_score(g, (const uint8_t *)state, strlen(state), &score, &err) != game_STATUS_OK) { report_error(err); exit(6); }
    return (long long)score;
}

static int lifecycle(int count) {
    long long first = -1;
    for (int i = 0; i < count; i++) {
        game_instance *g = create();
        long long score = short_game(g);
        if (first < 0) first = score;
        if (score != first) { printf("FAIL\tinstance %d scored %lld, not %lld\n", i, score, first); return 1; }
        if (p_game_destroy(g) != game_STATUS_OK) { printf("FAIL\tdestroy %d\n", i); return 1; }
    }
    printf("LIFECYCLE\t%d instances, each scored %lld\n", count, first);
    /* Two instances interleaved; destroying one leaves the other working. */
    game_instance *a = create(), *b = create();
    long long sa = short_game(a), sb = short_game(b);
    if (p_game_destroy(a) != game_STATUS_OK) return 1;
    long long sb2 = short_game(b);
    printf("INTERLEAVED\t%lld %lld %lld\n", sa, sb, sb2);
    /* The destroyed instance is refused, never touched. */
    game_bytes bytes = {0};
    game_error *err = NULL;
    int status = p_game_new_game(a, &bytes, &err);
    if (status == game_STATUS_OK) { printf("FAIL\ta destroyed instance answered\n"); return 1; }
    report_error(err);
    p_game_destroy(b);
    return 0;
}

static game_instance *shared;
static int other_status;
static char other_identity[64];

static void *other_thread(void *unused) {
    (void)unused;
    game_bytes bytes = {0};
    game_error *err = NULL;
    other_status = p_game_new_game(shared, &bytes, &err);
    if (other_status != game_STATUS_OK) {
        const uint8_t *id = NULL;
        size_t len = 0;
        p_game_error_identity(err, &id, &len);
        snprintf(other_identity, sizeof other_identity, "%.*s", (int)len, (const char *)id);
        p_game_error_release(&err);
    }
    return NULL;
}

static int thread(void) {
    shared = create();
    pthread_t t;
    pthread_create(&t, NULL, other_thread, NULL);
    pthread_join(t, NULL);
    printf("OTHER-THREAD\t%d\t%s\n", other_status, other_identity);
    printf("OWN-THREAD\t%lld\n", short_game(shared));
    return p_game_destroy(shared) == game_STATUS_OK ? 0 : 1;
}

int main(int argc, char **argv) {
    if (argc < 3) {
        fprintf(stderr, "usage: host2048 LIB.so play|lifecycle N|thread\n");
        return 2;
    }
    load(argv[1]);
    if (strcmp(argv[2], "play") == 0) {
        game_instance *g = create();
        int status = play(g, stdin);
        if (p_game_destroy(g) != game_STATUS_OK) return 7;
        return status;
    }
    if (strcmp(argv[2], "lifecycle") == 0 && argc > 3) return lifecycle(atoi(argv[3]));
    if (strcmp(argv[2], "thread") == 0) return thread();
    fprintf(stderr, "host2048: unknown mode %s\n", argv[2]);
    return 2;
}
