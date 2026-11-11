/* Probe C (ANDROID-SDL3-NATIVE-APPLICATION-ENTRY-CENSUS-MILESTONE-1.md):
 * a host-owned, persistent native-library instance driven by repeated calls,
 * as an SDL3 callback host would drive one. Uses the React Native 2048
 * facade (examples/react-native/2048/game.bot) built for the host.
 *
 * It measures what option C costs and what it cannot keep:
 *   - creating one instance (one VM), and the memory it adds;
 *   - one `move` call: the whole game state crosses the C ABI twice as a
 *     string, because an instance keeps no mutable state between calls;
 *   - a call from another thread (WRONG-THREAD, nothing runs).
 */
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include "game.h"

static long rss_kib(void) {
    FILE *f = fopen("/proc/self/status", "r");
    char line[256];
    long v = -1;
    while (f && fgets(line, sizeof line, f)) {
        if (strncmp(line, "VmRSS:", 6) == 0) { v = atol(line + 6); break; }
    }
    if (f) fclose(f);
    return v;
}

static double now_ns(void) {
    struct timespec t;
    clock_gettime(CLOCK_MONOTONIC, &t);
    return t.tv_sec * 1e9 + t.tv_nsec;
}

static game_instance *instance;
static game_bytes state;

static void *foreign(void *unused) {
    (void)unused;
    game_bytes out = {0};
    game_error *err = NULL;
    int32_t s = game_move(instance, state.ptr, state.len, 0, &out, &err);
    const uint8_t *p; size_t n;
    if (err && game_error_identity(err, &p, &n) == 0) {
        printf("foreign-thread call: status %d identity %.*s\n", s, (int)n, (const char *)p);
    } else {
        printf("foreign-thread call: status %d\n", s);
    }
    game_error_release(&err);
    return NULL;
}

int main(int argc, char **argv) {
    int moves = argc > 1 ? atoi(argv[1]) : 20000;
    game_error *err = NULL;
    long before = rss_kib();
    double t0 = now_ns();
    if (game_create(&instance, &err) != 0) { puts("create failed"); return 1; }
    double t1 = now_ns();
    long after = rss_kib();
    printf("create: %.1f us, RSS %ld -> %ld KiB (+%ld)\n", (t1 - t0) / 1e3, before, after, after - before);

    if (game_new_game(instance, 7, &state, &err) != 0) { puts("new_game failed"); return 1; }
    printf("state: %zu bytes\n", state.len);

    int declared = 0;
    double t2 = now_ns();
    for (int i = 0; i < moves; i++) {
        game_bytes next = {0};
        int32_t s = game_move(instance, state.ptr, state.len, i % 4, &next, &err);
        if (s == 0) {
            game_bytes_release(&state);
            state = next;
        } else {
            declared++;
            game_error_release(&err);
        }
    }
    double t3 = now_ns();
    printf("move: %d calls, %.2f us per call (state crossing twice), %d refused\n", moves, (t3 - t2) / 1e3 / moves, declared);

    pthread_t t;
    pthread_create(&t, NULL, foreign, NULL);
    pthread_join(t, NULL);

    game_bytes_release(&state);
    printf("destroy: status %d, RSS %ld KiB\n", game_destroy(instance), rss_kib());
    return 0;
}
