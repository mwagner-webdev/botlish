/* stress.c -- runtime workloads of a Botlish native library in an Android
 * process (ANDROID-AARCH64-TARGET-SUPPORT-MILESTONE-1.md, "Native runtime
 * stress"): loads the stress library (stress/stress.bot) with dlopen and
 * calls its exports ROUNDS times on two instances in turn, checking that
 * every round of both gives the first round's results. Prints them once:
 *
 *   characters N        the length of repeated("aé😀", 2000) in characters
 *   reversed TEXT       reversed("aé😀bß")
 *   nested N            nested(500)
 *   vector N            vector(5000)
 *   boom STATUS ID COUNT TEXT   boom(300)'s error and its payload fields
 *
 *   stress LIB.so ROUNDS
 */
#include <dlfcn.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "stress.h"

#define FN(name) static __typeof__(&name) p_##name
FN(stress_create);
FN(stress_destroy);
FN(stress_bytes_release);
FN(stress_error_release);
FN(stress_error_status);
FN(stress_error_identity);
FN(stress_error_field_count);
FN(stress_error_field_name);
FN(stress_error_field_int);
FN(stress_error_field_str);
FN(stress_repeated);
FN(stress_reversed);
FN(stress_characters);
FN(stress_nested);
FN(stress_vector);
FN(stress_boom);

static void *library;

static void *need(const char *name) {
    void *symbol = dlsym(library, name);
    if (!symbol) {
        fprintf(stderr, "stress: %s: %s\n", name, dlerror());
        exit(3);
    }
    return symbol;
}

static void die(const char *what, stress_error *err) {
    const uint8_t *id = NULL;
    size_t len = 0;
    if (err) p_stress_error_identity(err, &id, &len);
    fprintf(stderr, "stress: %s failed: %.*s\n", what, (int)len, id ? (const char *)id : "");
    exit(4);
}

/* One round's results, as text. */
static void round_of(stress_instance *g, char *out, size_t size) {
    stress_bytes text = {0};
    stress_error *err = NULL;
    const char *seed = "a\xc3\xa9\xf0\x9f\x98\x80"; /* "aé😀" */
    if (p_stress_repeated(g, (const uint8_t *)seed, strlen(seed), 2000, &text, &err) != stress_STATUS_OK) die("repeated", err);
    int64_t chars = 0;
    if (p_stress_characters(g, text.ptr, text.len, &chars, &err) != stress_STATUS_OK) die("characters", err);
    size_t bytes = text.len;
    p_stress_bytes_release(&text);
    const char *word = "a\xc3\xa9\xf0\x9f\x98\x80" "b\xc3\x9f"; /* "aé😀bß" */
    stress_bytes back = {0};
    if (p_stress_reversed(g, (const uint8_t *)word, strlen(word), &back, &err) != stress_STATUS_OK) die("reversed", err);
    int64_t nested = 0, vector = 0, unused = 0;
    if (p_stress_nested(g, 500, &nested, &err) != stress_STATUS_OK) die("nested", err);
    if (p_stress_vector(g, 5000, &vector, &err) != stress_STATUS_OK) die("vector", err);
    int status = p_stress_boom(g, 300, &unused, &err);
    const uint8_t *id = NULL, *fstr = NULL;
    size_t idlen = 0, flen = 0;
    int64_t count = -1;
    if (status == stress_STATUS_OK) {
        fprintf(stderr, "stress: boom did not fail\n");
        exit(4);
    }
    p_stress_error_identity(err, &id, &idlen);
    for (size_t i = 0; i < p_stress_error_field_count(err); i++) {
        const uint8_t *name = NULL;
        size_t nlen = 0;
        p_stress_error_field_name(err, i, &name, &nlen);
        if (nlen == 5 && memcmp(name, "count", 5) == 0) p_stress_error_field_int(err, i, &count);
        if (nlen == 4 && memcmp(name, "text", 4) == 0) p_stress_error_field_str(err, i, &fstr, &flen);
    }
    snprintf(out, size, "characters\t%lld\t%zu\nreversed\t%.*s\nnested\t%lld\nvector\t%lld\nboom\t%d\t%.*s\t%lld\t%.*s\n",
             (long long)chars, bytes, (int)back.len, (const char *)back.ptr, (long long)nested, (long long)vector,
             p_stress_error_status(err), (int)idlen, (const char *)id, (long long)count, (int)flen, (const char *)fstr);
    p_stress_bytes_release(&back);
    if (p_stress_error_release(&err) != stress_STATUS_OK || err != NULL) die("error_release", NULL);
}

int main(int argc, char **argv) {
    if (argc < 3) {
        fprintf(stderr, "usage: stress LIB.so ROUNDS\n");
        return 2;
    }
    library = dlopen(argv[1], RTLD_NOW | RTLD_LOCAL);
    if (!library) {
        fprintf(stderr, "stress: dlopen %s: %s\n", argv[1], dlerror());
        return 3;
    }
#define RESOLVE(name) p_##name = (__typeof__(p_##name))need(#name)
    RESOLVE(stress_create);
    RESOLVE(stress_destroy);
    RESOLVE(stress_bytes_release);
    RESOLVE(stress_error_release);
    RESOLVE(stress_error_status);
    RESOLVE(stress_error_identity);
    RESOLVE(stress_error_field_count);
    RESOLVE(stress_error_field_name);
    RESOLVE(stress_error_field_int);
    RESOLVE(stress_error_field_str);
    RESOLVE(stress_repeated);
    RESOLVE(stress_reversed);
    RESOLVE(stress_characters);
    RESOLVE(stress_nested);
    RESOLVE(stress_vector);
    RESOLVE(stress_boom);
    int rounds = atoi(argv[2]);
    stress_instance *a = NULL, *b = NULL;
    stress_error *err = NULL;
    if (p_stress_create(&a, &err) != stress_STATUS_OK) die("create", err);
    if (p_stress_create(&b, &err) != stress_STATUS_OK) die("create", err);
    static char first[65536], again[65536];
    round_of(a, first, sizeof first);
    for (int r = 0; r < rounds; r++) {
        round_of(r % 2 ? a : b, again, sizeof again);
        if (strcmp(first, again) != 0) {
            fprintf(stderr, "stress: round %d differs:\n%s---\n%s", r, first, again);
            return 5;
        }
    }
    if (p_stress_destroy(a) != stress_STATUS_OK || p_stress_destroy(b) != stress_STATUS_OK) die("destroy", NULL);
    fputs(first, stdout);
    printf("rounds\t%d\n", rounds);
    return 0;
}
