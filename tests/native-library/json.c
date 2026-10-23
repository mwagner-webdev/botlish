/* json.c -- a C caller of the JSON probe library bj (the compiler service
 * census's exports.bot over its unchanged json_tokens.bot,
 * audit/compiler-service/probes/; tests/native-library.test). It includes
 * only the generated bj.h and links only the generated library. Prints
 * "ok NAME" / "not ok NAME: WHY" per check, then "done json N". */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "bj.h"

static int checks;
static int failures;

static void check(int good, const char *name, const char *why) {
    checks++;
    if (good) {
        printf("ok %s\n", name);
    } else {
        failures++;
        printf("not ok %s: %s\n", name, why);
    }
    fflush(stdout);
}

#define CHECK(cond, name) check((cond), (name), #cond)

static int64_t count(bj_instance *in, const char *text, int32_t *status) {
    int64_t out = -999;
    *status = bj_token_count(in, (const uint8_t *) text, strlen(text), &out, NULL);
    return out;
}

int main(void) {
    const char *stress = getenv("BOTLISH_NATIVE_GC_STRESS");
    int quick = stress && *stress && strcmp(stress, "0") != 0;
    bj_instance *in = NULL;
    bj_error *e = NULL;
    int32_t s;
    CHECK(bj_create(&in, &e) == bj_OK && in != NULL, "create");

    /* The census's defect: the exported instance specialized for a short
     * constant input miscounted every longer one. */
    CHECK(count(in, "[1, 2]", &s) == 5, "[1, 2] is 5 tokens");
    CHECK(count(in, "[1, 2, 3]", &s) == 7, "[1, 2, 3] is 7 tokens");
    CHECK(count(in, "[1, 2, 3, 4, 5, 6]", &s) == 13, "[1, ..., 6] is 13 tokens");
    CHECK(count(in, "\"abcdefghij\"", &s) == 1, "a 10-character string is one token");
    CHECK(count(in, "{\"\xc3\xa9\": [true, false, null, -1.5e3]}", &s) == 13, "UTF-8 keys and every literal");
    char *big = malloc(200000);
    size_t at = 0;
    big[at++] = '[';
    for (int i = 0; i < 20000; i++) {
        at += (size_t) sprintf(big + at, i ? ", %d" : "%d", i);
    }
    big[at++] = ']';
    big[at] = 0;
    int64_t n = count(in, big, &s);
    CHECK(s == bj_OK && n == 2 + 20000 + 19999, "a 20000-element array");
    free(big);
    CHECK(count(in, "{\"a\": tru}", &s) == -7, "malformed at 6, folded into the count");

    /* The tokenizer's declared error, as data. */
    int64_t out = 0;
    s = bj_tokens(in, (const uint8_t *) "{\"a\": tru}", 10, &out, &e);
    bj_text t;
    int64_t at6 = 0;
    CHECK(s == bj_DECLARED_ERROR && bj_error_identity(e, &t) == bj_OK && t.len == 22 &&
          memcmp(t.data, "json_tokens::Malformed", 22) == 0 &&
          bj_error_field_int(e, 0, &at6) == bj_OK && at6 == 6,
          "tokens() fails with json_tokens::Malformed {at: 6}");
    bj_error_release(e);

    s = bj_token_count(in, (const uint8_t *) "\"\xff\"", 3, &out, &e);
    CHECK(s == bj_BOUNDARY_ERROR, "invalid UTF-8 is refused before the tokenizer runs");
    bj_error_release(e);

    /* Repeated calls and allocation. */
    int good = 1;
    int calls = quick ? 50 : 20000;
    for (int i = 0; i < calls; i++) {
        if (count(in, "{\"k\": [1, 2, {\"x\": null}]}", &s) != 15) good = 0;
    }
    CHECK(good, "repeated calls");
    bj_bytes kept;
    s = bj_shout(in, (const uint8_t *) "kept", 4, &kept, NULL);
    s = bj_churn(in, quick ? 300 : 100000, &out, NULL);
    CHECK(s == bj_OK && strcmp((const char *) kept.data, "kept!") == 0, "a result survives a collecting call");
    bj_bytes_release(&kept);

    /* Destruction and recreation. */
    CHECK(bj_destroy(in) == bj_OK, "destroy");
    CHECK(bj_token_count(in, (const uint8_t *) "[]", 2, &out, NULL) == bj_INVOCATION_ERROR, "a destroyed instance refuses calls");
    good = 1;
    for (int i = 0; i < (quick ? 20 : 500); i++) {
        bj_instance *again = NULL;
        if (bj_create(&again, NULL) != bj_OK) good = 0;
        if (count(again, "[1, 2, 3]", &s) != 7) good = 0;
        if (bj_destroy(again) != bj_OK) good = 0;
    }
    CHECK(good, "instances created and destroyed again and again");
    printf("done json %d\n", checks);
    return failures ? 1 : 0;
}
