/* conformance.c -- a C caller of the native libraries alpha and beta
 * (tests/native-library.test, NATIVE-LIBRARY-MILESTONE-1.md). It includes
 * only their generated headers and links only their generated libraries.
 *
 *   conformance SECTION
 *
 * runs one section of checks and prints one line per check, "ok NAME" or
 * "not ok NAME: WHY", then "done SECTION N" (N checks). Sections: roots
 * types errors invalid instances two-libraries threads stack gc. */
#include <math.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "alpha.h"
#include "beta.h"

static int checks;
static int failures;
/* Allocation sizes: smaller under BOTLISH_NATIVE_GC_STRESS, where every
 * allocation collects. */
static int scale = 100;

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

/* A text view as a NUL-terminated copy (in a static buffer per slot). */
static const char *text(alpha_text t) {
    static char buffers[4][512];
    static int next;
    char *b = buffers[next++ % 4];
    size_t n = t.len < sizeof buffers[0] - 1 ? t.len : sizeof buffers[0] - 1;
    memcpy(b, t.data, n);
    b[n] = 0;
    return b;
}

static const char *alpha_identity(const alpha_error *e) {
    alpha_text t = {0, 0};
    if (alpha_error_identity(e, &t) != alpha_OK) return "(no identity)";
    return text(t);
}

static const char *beta_identity(const beta_error *e) {
    beta_text t = {0, 0};
    if (beta_error_identity(e, &t) != beta_OK) return "(no identity)";
    return text((alpha_text) {t.data, t.len});
}

static alpha_instance *new_alpha(void) {
    alpha_instance *a = NULL;
    alpha_error *e = NULL;
    int32_t s = alpha_create(&a, &e);
    if (s != alpha_OK) {
        printf("not ok alpha_create: status %d %s\n", s, e ? alpha_identity(e) : "");
        exit(1);
    }
    return a;
}

static beta_instance *new_beta(void) {
    beta_instance *b = NULL;
    beta_error *e = NULL;
    if (beta_create(&b, &e) != beta_OK) {
        printf("not ok beta_create\n");
        exit(1);
    }
    return b;
}

static int64_t alpha_int(int32_t (*f)(alpha_instance *, int64_t, int64_t *, alpha_error **),
                         alpha_instance *a, int64_t n, int32_t *status) {
    int64_t out = -123456789;
    alpha_error *e = NULL;
    *status = f(a, n, &out, &e);
    alpha_error_release(e);
    return out;
}

static int64_t alpha_text_int(int32_t (*f)(alpha_instance *, const uint8_t *, size_t, int64_t *, alpha_error **),
                              alpha_instance *a, const char *s, int32_t *status) {
    int64_t out = -123456789;
    alpha_error *e = NULL;
    *status = f(a, (const uint8_t *) s, strlen(s), &out, &e);
    alpha_error_release(e);
    return out;
}

/* --- export roots ------------------------------------------------------- */

static void roots(void) {
    alpha_instance *a = new_alpha();
    int32_t s;
    alpha_error *e = NULL;
    int64_t out = 0;

    /* checked: every Botlish caller passes 1, which proves n < 0 dead. */
    s = alpha_checked(a, -5, &out, &e);
    CHECK(s == alpha_DECLARED_ERROR, "checked(-5) fails with its declared error");
    CHECK(e != NULL && strcmp(alpha_identity(e), "Rejected") == 0, "checked(-5)'s error is Rejected");
    int64_t code = 0;
    CHECK(alpha_error_field_count(e) == 1 && alpha_error_field_int(e, 0, &code) == alpha_OK && code == -5,
          "checked(-5)'s payload is {code: -5}");
    alpha_error_release(e);
    CHECK(alpha_int(alpha_checked, a, 21, &s) == 42 && s == alpha_OK, "checked(21) = 42");
    CHECK(alpha_int(alpha_checked, a, 1, &s) == 2 && s == alpha_OK, "checked(1) = 2");
    CHECK(alpha_int(alpha_checked, a, INT64_MAX / 2, &s) == INT64_MAX - 1, "checked(int64 max / 2)");

    /* commas: every Botlish caller passes the 6-character "[1, 2]". */
    CHECK(alpha_text_int(alpha_commas, a, "[1, 2]", &s) == 1, "commas(\"[1, 2]\") = 1");
    CHECK(alpha_text_int(alpha_commas, a, "[1, 2, 3]", &s) == 2, "commas of a longer input = 2");
    CHECK(alpha_text_int(alpha_commas, a, ",,,,,,,,,,,,,,,,,,,,", &s) == 20, "commas of 20 commas = 20");
    CHECK(alpha_text_int(alpha_commas, a, "", &s) == 0, "commas(\"\") = 0");

    /* The internal callers still get their own (specialized) instances. */
    s = alpha_internal(a, &out, &e);
    CHECK(s == alpha_OK && out == 201, "internal() = 201 through the specialized instances");

    /* No Botlish caller at all. */
    s = alpha_orphan(a, 7, 9, &out, &e);
    CHECK(s == alpha_OK && out == 7009, "orphan(7, 9) = 7009");

    /* A tiny leaf inlined into its Botlish callers keeps its entry point. */
    CHECK(alpha_int(alpha_inc, a, -1, &s) == 0, "inc(-1) = 0");
    s = alpha_inc_twice(a, &out, &e);
    CHECK(s == alpha_OK && out == 43, "inc_twice() = 43");

    /* A stated C symbol. */
    CHECK(alpha_int(alpha_stated_entry, a, 10, &s) == 9, "stated (alpha_stated_entry)(10) = 9");

    /* An export of an imported module, reading its module binding. */
    alpha_bytes b = {0, 0};
    s = alpha_util_greeting(a, &b, &e);
    CHECK(s == alpha_OK && b.len == 19 && strcmp((const char *) b.data, "hello from a module") == 0,
          "util_greeting() reads its module's binding");
    alpha_bytes_release(&b);
    alpha_destroy(a);
}

/* --- boundary types ----------------------------------------------------- */

static void types(void) {
    alpha_instance *a = new_alpha();
    alpha_error *e = NULL;
    int32_t s;
    int64_t out = 0;
    alpha_bytes b = {0, 0};

    CHECK(alpha_abi_version() == ALPHA_ABI_VERSION, "abi_version() is the header's");

    s = alpha_shout(a, (const uint8_t *) "caf\xc3\xa9", 5, &b, &e);
    CHECK(s == alpha_OK && b.len == 6 && memcmp(b.data, "caf\xc3\xa9!", 6) == 0 && b.data[6] == 0,
          "shout(UTF-8) returns owned NUL-terminated bytes");
    alpha_bytes kept = b;
    s = alpha_churn(a, 20 * scale, &out, &e);
    CHECK(s == alpha_OK && out == 20 * scale && memcmp(kept.data, "caf\xc3\xa9!", 6) == 0,
          "a returned str survives a collecting call");
    CHECK(alpha_bytes_release(&b) == alpha_OK && b.data == NULL && b.len == 0, "bytes_release empties the bytes");
    CHECK(alpha_bytes_release(&b) == alpha_OK, "releasing an empty bytes does nothing");
    CHECK(alpha_bytes_release(&kept) == alpha_INVOCATION_ERROR, "releasing a copy already released is an invocation error");

    s = alpha_shout(a, NULL, 0, &b, &e);
    CHECK(s == alpha_OK && b.len == 1 && b.data[0] == '!', "NULL with length 0 is the empty string");
    alpha_bytes_release(&b);
    s = alpha_shout(a, (const uint8_t *) "a\0b", 3, &b, &e);
    CHECK(s == alpha_OK && b.len == 4 && memcmp(b.data, "a\0b!", 4) == 0, "embedded NUL bytes are characters");
    alpha_bytes_release(&b);
    CHECK(alpha_text_int(alpha_length, a, "a\xf0\x9f\x98\x80" "b", &s) == 3, "length counts scalar values");

    s = alpha_shout(a, (const uint8_t *) "\xff\xfe", 2, &b, &e);
    CHECK(s == alpha_BOUNDARY_ERROR && strcmp(alpha_identity(e), "BOUNDARY UTF-8") == 0, "invalid UTF-8 is a boundary error");
    alpha_error_release(e);
    s = alpha_shout(a, (const uint8_t *) "\xed\xa0\x80", 3, &b, &e);
    CHECK(s == alpha_BOUNDARY_ERROR, "a UTF-8 surrogate is a boundary error");
    alpha_error_release(e);
    s = alpha_shout(a, NULL, 3, &b, &e);
    CHECK(s == alpha_INVOCATION_ERROR && strcmp(alpha_identity(e), "INVOCATION NULL-POINTER") == 0,
          "NULL with a length is an invocation error");
    alpha_error_release(e);
    s = alpha_shout(a, (const uint8_t *) "ok", 2, &b, &e);
    CHECK(s == alpha_OK && strcmp((const char *) b.data, "ok!") == 0, "the instance works after boundary errors");
    alpha_bytes_release(&b);

    bool flag = true;
    s = alpha_negate(a, true, &flag, &e);
    CHECK(s == alpha_OK && flag == false, "negate(true) = false");
    s = alpha_negate(a, false, &flag, &e);
    CHECK(s == alpha_OK && flag == true, "negate(false) = true");

    double x = 0;
    s = alpha_half(a, 5.0, &x, &e);
    CHECK(s == alpha_OK && x == 2.5, "half(5.0) = 2.5");
    s = alpha_half(a, -0.0, &x, &e);
    CHECK(s == alpha_OK && x == 0.0 && !signbit(x), "half(-0.0) = 0.0");
    s = alpha_half(a, NAN, &x, &e);
    CHECK(s == alpha_BOUNDARY_ERROR && strcmp(alpha_identity(e), "BOUNDARY NON-FINITE") == 0, "half(NaN) is a boundary error");
    alpha_error_release(e);
    s = alpha_half(a, INFINITY, &x, &e);
    CHECK(s == alpha_BOUNDARY_ERROR, "half(inf) is a boundary error");
    alpha_error_release(e);

    s = alpha_nothing(a, 3, &e);
    CHECK(s == alpha_OK && e == NULL, "a unit result has no result parameter");

    CHECK(alpha_int(alpha_square, a, 3037000499LL, &s) == 9223372030926249001LL && s == alpha_OK, "square(3037000499) fits int64_t");
    out = 77;
    s = alpha_square(a, 3037000500LL, &out, &e);
    CHECK(s == alpha_BOUNDARY_ERROR && strcmp(alpha_identity(e), "BOUNDARY INT-RANGE") == 0 && out == 77,
          "an Int result beyond int64_t is a boundary error, never truncated");
    alpha_error_release(e);
    CHECK(alpha_int(alpha_square, a, INT64_MIN, &s) == -123456789 && s == alpha_BOUNDARY_ERROR, "square(int64 min) is out of range");
    s = alpha_orphan(a, INT64_MAX / 1000, 807, &out, &e);
    CHECK(s == alpha_OK && out == INT64_MAX, "int64_t arguments and results are exact to the limit");
    s = alpha_orphan(a, INT64_MIN / 1000, -808, &out, &e);
    CHECK(s == alpha_OK && out == INT64_MIN, "int64 min is exact");
    alpha_destroy(a);
}

/* --- errors as data ----------------------------------------------------- */

static void errors(void) {
    alpha_instance *a = new_alpha();
    alpha_error *e = NULL;
    int32_t s;
    int64_t out = 0;
    alpha_text t;

    s = alpha_detail(a, 3000000, &out, &e);
    CHECK(s == alpha_DECLARED_ERROR && alpha_error_status(e) == alpha_DECLARED_ERROR, "detail() fails with a declared error");
    CHECK(strcmp(alpha_identity(e), "Detail") == 0, "its identity is Detail");
    CHECK(alpha_error_field_count(e) == 5, "it has five payload fields");
    /* Fields in the payload's slot order: sorted by name. */
    const char *names[] = {"count", "flag", "huge", "label", "ratio"};
    int kinds[] = {alpha_FIELD_INT, alpha_FIELD_BOOL, alpha_FIELD_INT, alpha_FIELD_STR, alpha_FIELD_FLOAT64};
    int named = 1;
    for (size_t i = 0; i < 5; i++) {
        if (alpha_error_field_name(e, i, &t) != alpha_OK || strcmp(text(t), names[i]) != 0) named = 0;
        if (alpha_error_field_kind(e, i) != kinds[i]) named = 0;
    }
    CHECK(named, "the fields' names and kinds");
    int64_t count = 0;
    CHECK(alpha_error_field_int(e, 0, &count) == alpha_OK && count == 3000000, "count = 3000000");
    bool flag = false;
    CHECK(alpha_error_field_bool(e, 1, &flag) == alpha_OK && flag, "flag = true");
    int64_t huge = 0;
    CHECK(alpha_error_field_int(e, 2, &huge) == alpha_BOUNDARY_ERROR, "huge does not fit int64_t");
    CHECK(alpha_error_field_text(e, 2, &t) == alpha_OK && strcmp(text(t), "27000000000000000000") == 0, "huge's text is exact");
    CHECK(alpha_error_field_str(e, 3, &t) == alpha_OK && strcmp(text(t), "lab\xc3\xa9l") == 0, "label = \"labél\"");
    double ratio = 0;
    CHECK(alpha_error_field_float64(e, 4, &ratio) == alpha_OK && ratio == 0.5, "ratio = 0.5");
    CHECK(alpha_error_field_int(e, 3, &count) == alpha_INVOCATION_ERROR, "a field of another kind is an invocation error");
    CHECK(alpha_error_field_kind(e, 5) == -1 && alpha_error_field_name(e, 5, &t) == alpha_INVOCATION_ERROR, "there is no sixth field");
    CHECK(alpha_error_message(e, &t) == alpha_OK && strstr(text(t), "Detail") != NULL, "a human-readable message");

    /* The error survives later calls, other errors and the instance. */
    alpha_error *other = NULL;
    s = alpha_checked(a, -1, &out, &other);
    CHECK(s == alpha_DECLARED_ERROR && strcmp(alpha_identity(other), "Rejected") == 0, "a later call fails on its own");
    alpha_churn(a, 10 * scale, &out, NULL);
    alpha_destroy(a);
    CHECK(strcmp(alpha_identity(e), "Detail") == 0 && alpha_error_field_int(e, 0, &count) == alpha_OK && count == 3000000,
          "an error survives later calls and the instance's destruction");
    CHECK(alpha_error_release(e) == alpha_OK, "error_release");
    CHECK(alpha_error_release(e) == alpha_INVOCATION_ERROR, "releasing an error twice is an invocation error");
    CHECK(alpha_error_status(e) == -1 && alpha_error_identity(e, &t) == alpha_INVOCATION_ERROR, "a released error is no live error");
    CHECK(alpha_error_release(NULL) == alpha_OK, "releasing NULL does nothing");
    alpha_error_release(other);

    a = new_alpha();
    s = alpha_element(a, 1, &out, &e);
    CHECK(s == alpha_OK && out == 20, "element(1) = 20");
    s = alpha_element(a, 7, &out, &e);
    CHECK(s == alpha_DECLARED_ERROR && strcmp(alpha_identity(e), "IndexNotFound") == 0, "a builtin declared error by name");
    alpha_error_release(e);
    s = alpha_checked(a, -2, &out, NULL);
    CHECK(s == alpha_DECLARED_ERROR, "a call needs no error out-parameter");
    CHECK(alpha_int(alpha_checked, a, 4, &s) == 8, "the instance works after errors");
    alpha_destroy(a);
}

/* --- invalid invocations ------------------------------------------------ */

static void invalid(void) {
    alpha_error *e = NULL;
    int32_t s;
    int64_t out = 0;
    CHECK(alpha_create(NULL, &e) == alpha_INVOCATION_ERROR && e != NULL, "create(NULL) is an invocation error");
    alpha_error_release(e);

    alpha_instance *a = new_alpha();
    s = alpha_checked(a, 1, NULL, &e);
    CHECK(s == alpha_INVOCATION_ERROR && strcmp(alpha_identity(e), "INVOCATION NULL-POINTER") == 0, "a NULL result is an invocation error");
    alpha_error_release(e);
    s = alpha_checked(NULL, 1, &out, &e);
    CHECK(s == alpha_INVOCATION_ERROR && strcmp(alpha_identity(e), "INVOCATION NULL-INSTANCE") == 0, "a NULL instance");
    alpha_error_release(e);
    int not_an_instance = 0;
    s = alpha_checked((alpha_instance *) &not_an_instance, 1, &out, &e);
    CHECK(s == alpha_INVOCATION_ERROR && strcmp(alpha_identity(e), "INVOCATION UNKNOWN-INSTANCE") == 0, "a pointer that is no instance");
    alpha_error_release(e);
    s = beta_checked((beta_instance *) a, 1, &out, NULL);
    CHECK(s == beta_INVOCATION_ERROR, "another library's instance is an invocation error");
    CHECK(alpha_destroy(a) == alpha_OK, "destroy");
    CHECK(alpha_destroy(a) == alpha_INVOCATION_ERROR, "destroying twice is an invocation error");
    s = alpha_checked(a, 1, &out, &e);
    CHECK(s == alpha_INVOCATION_ERROR && strcmp(alpha_identity(e), "INVOCATION DESTROYED") == 0, "a destroyed instance");
    alpha_error_release(e);
    CHECK(alpha_destroy(NULL) == alpha_INVOCATION_ERROR, "destroy(NULL)");
    alpha_bytes bogus = {(uint8_t *) &not_an_instance, 4};
    CHECK(alpha_bytes_release(&bogus) == alpha_INVOCATION_ERROR, "releasing bytes the library did not return");
    CHECK(alpha_error_release((alpha_error *) &not_an_instance) == alpha_INVOCATION_ERROR, "releasing an error the library did not return");
}

/* --- instances ---------------------------------------------------------- */

static void instances(void) {
    alpha_instance *x = new_alpha();
    alpha_instance *y = new_alpha();
    alpha_error *e = NULL;
    int64_t out = 0;
    int32_t s;
    CHECK(x != y, "two instances are distinct");
    /* An error pending in one is no state of the other. */
    s = alpha_checked(x, -9, &out, &e);
    int64_t in_y = alpha_int(alpha_checked, y, 9, &s);
    CHECK(in_y == 18 && s == alpha_OK, "an error in one instance is not the other's");
    alpha_error_release(e);
    /* Interleaved allocation. */
    int good = 1;
    for (int i = 0; i < 50; i++) {
        if (alpha_int(alpha_churn, x, scale + i, &s) != scale + i) good = 0;
        if (alpha_int(alpha_churn, y, 2 * scale + i, &s) != 2 * scale + i) good = 0;
    }
    CHECK(good, "interleaved allocating calls");
    alpha_bytes bx, by;
    alpha_shout(x, (const uint8_t *) "x", 1, &bx, NULL);
    alpha_shout(y, (const uint8_t *) "y", 1, &by, NULL);
    CHECK(alpha_destroy(x) == alpha_OK, "destroy one");
    CHECK(alpha_int(alpha_churn, y, 3 * scale, &s) == 3 * scale && s == alpha_OK, "the other still works");
    CHECK(strcmp((const char *) bx.data, "x!") == 0 && strcmp((const char *) by.data, "y!") == 0,
          "results outlive their instance");
    alpha_bytes_release(&bx);
    alpha_bytes_release(&by);
    alpha_destroy(y);
    /* Destruction and recreation. */
    good = 1;
    for (int i = 0; i < 300; i++) {
        alpha_instance *z = new_alpha();
        if (alpha_int(alpha_churn, z, 100, &s) != 100) good = 0;
        if (alpha_destroy(z) != alpha_OK) good = 0;
    }
    CHECK(good, "300 instances created, used and destroyed");
}

/* --- two libraries ------------------------------------------------------ */

static void two_libraries(void) {
    alpha_instance *a = new_alpha();
    beta_instance *b = new_beta();
    int64_t out = 0;
    int32_t s;
    beta_error *be = NULL;
    alpha_error *ae = NULL;
    int good = 1;
    for (int i = 0; i < 100; i++) {
        if (alpha_int(alpha_checked, a, i, &s) != 2 * i) good = 0;
        s = beta_checked(b, i, &out, &be);
        if (s != beta_OK || out != i + 1000) good = 0;
    }
    CHECK(good, "alternating calls reach each library's own code");
    alpha_bytes ab;
    beta_bytes bb;
    alpha_shout(a, (const uint8_t *) "a", 1, &ab, &ae);
    beta_shout(b, (const uint8_t *) "b", 1, &bb, &be);
    CHECK(strcmp((const char *) ab.data, "a!") == 0 && strcmp((const char *) bb.data, "b?") == 0, "each library's strings");
    CHECK(beta_bytes_release((beta_bytes *) &ab) == beta_INVOCATION_ERROR, "beta does not release alpha's bytes");
    alpha_bytes_release(&ab);
    beta_bytes_release(&bb);
    good = 1;
    for (int i = 0; i < 40; i++) {
        if (alpha_int(alpha_churn, a, 5 * scale + i, &s) != 5 * scale + i) good = 0;
        s = beta_churn(b, 5 * scale + i, &out, &be);
        if (s != beta_OK || out != 2 * (5 * scale + i)) good = 0;
    }
    CHECK(good, "alternating allocating calls");
    s = beta_fails(b, 12, &out, &be);
    s = alpha_checked(a, -12, &out, &ae);
    int64_t n = 0, code = 0;
    CHECK(strcmp(beta_identity(be), "Oops") == 0 && beta_error_field_int(be, 0, &n) == beta_OK && n == 12 &&
          strcmp(alpha_identity(ae), "Rejected") == 0 && alpha_error_field_int(ae, 0, &code) == alpha_OK && code == -12,
          "each library's declared errors");
    beta_error_release(be);
    alpha_error_release(ae);
    alpha_destroy(a);
    beta_destroy(b);
}

/* --- threads ------------------------------------------------------------ */

struct work {
    int library; /* 0 alpha, 1 beta */
    int good;
    alpha_instance *foreign;
};

static void *worker(void *arg) {
    struct work *w = arg;
    int64_t out = 0;
    int32_t s;
    w->good = 1;
    if (w->foreign) {
        alpha_error *e = NULL;
        s = alpha_checked(w->foreign, 1, &out, &e);
        w->good = s == alpha_INVOCATION_ERROR && strcmp(alpha_identity(e), "INVOCATION WRONG-THREAD") == 0;
        alpha_error_release(e);
        w->good = w->good && alpha_destroy(w->foreign) == alpha_INVOCATION_ERROR;
        return NULL;
    }
    if (w->library == 0) {
        alpha_instance *a = new_alpha();
        for (int i = 0; i < 200; i++) {
            if (alpha_int(alpha_churn, a, scale + i, &s) != scale + i) w->good = 0;
            if (alpha_int(alpha_checked, a, i, &s) != 2 * i) w->good = 0;
        }
        alpha_destroy(a);
    } else {
        beta_instance *b = new_beta();
        for (int i = 0; i < 200; i++) {
            if (beta_churn(b, scale + i, &out, NULL) != beta_OK || out != 2 * (scale + i)) w->good = 0;
            if (beta_checked(b, i, &out, NULL) != beta_OK || out != i + 1000) w->good = 0;
        }
        beta_destroy(b);
    }
    return NULL;
}

static void threads(void) {
    alpha_instance *a = new_alpha();
    pthread_t t;
    struct work w = {0, 0, a};
    pthread_create(&t, NULL, worker, &w);
    pthread_join(t, NULL);
    CHECK(w.good, "another thread's call and destruction are invocation errors");
    int32_t s;
    CHECK(alpha_int(alpha_checked, a, 3, &s) == 6, "the owner thread still calls it");
    alpha_destroy(a);

    pthread_t ts[4];
    struct work ws[4];
    for (int i = 0; i < 4; i++) {
        ws[i] = (struct work) {i % 2, 0, NULL};
        pthread_create(&ts[i], NULL, worker, &ws[i]);
    }
    int good = 1;
    for (int i = 0; i < 4; i++) {
        pthread_join(ts[i], NULL);
        good = good && ws[i].good;
    }
    CHECK(good, "four threads, each with its own instance of alpha or beta, at once");
}

/* --- stack -------------------------------------------------------------- */

static void *deep(void *arg) {
    int *good = arg;
    alpha_instance *a = new_alpha();
    alpha_error *e = NULL;
    int64_t out = 0;
    int32_t s = alpha_depth(a, 10000000, &out, &e);
    *good = s == alpha_RUNTIME_ERROR && strcmp(alpha_identity(e), "NATIVE LIMIT STACK") == 0;
    alpha_error_release(e);
    s = alpha_depth(a, 1000, &out, &e);
    *good = *good && s == alpha_OK && out == 1000;
    alpha_destroy(a);
    return NULL;
}

static void stack(void) {
    alpha_instance *a = new_alpha();
    alpha_error *e = NULL;
    int64_t out = 0;
    int32_t s = alpha_depth(a, 10000, &out, &e);
    CHECK(s == alpha_OK && out == 10000, "depth(10000) on the main thread");
    s = alpha_depth(a, 100000000, &out, &e);
    CHECK(s == alpha_RUNTIME_ERROR && strcmp(alpha_identity(e), "NATIVE LIMIT STACK") == 0,
          "exhausting the main thread's stack is NATIVE LIMIT STACK");
    alpha_error_release(e);
    s = alpha_depth(a, 5000, &out, &e);
    CHECK(s == alpha_OK && out == 5000, "the instance works afterwards");
    alpha_destroy(a);

    size_t sizes[] = {512 * 1024, 1024 * 1024};
    for (int i = 0; i < 2; i++) {
        pthread_attr_t attr;
        pthread_attr_init(&attr);
        pthread_attr_setstacksize(&attr, sizes[i]);
        pthread_t t;
        int good = 0;
        pthread_create(&t, &attr, deep, &good);
        pthread_join(t, NULL);
        char name[100];
        snprintf(name, sizeof name, "NATIVE LIMIT STACK on a %zu KiB thread, and recovery", sizes[i] / 1024);
        CHECK(good, name);
    }
}

/* --- GC: many collections across instances and libraries ------------------ */

static void gc(void) {
    alpha_instance *a = new_alpha();
    beta_instance *b = new_beta();
    int32_t s;
    int64_t out = 0;
    int good = 1;
    alpha_bytes kept[20];
    for (int i = 0; i < 20; i++) {
        char word[16];
        snprintf(word, sizeof word, "w%d", i);
        if (alpha_shout(a, (const uint8_t *) word, strlen(word), &kept[i], NULL) != alpha_OK) good = 0;
        if (alpha_int(alpha_churn, a, 2 * scale, &s) != 2 * scale) good = 0;
        if (beta_churn(b, 2 * scale, &out, NULL) != beta_OK || out != 4 * scale) good = 0;
        if (alpha_text_int(alpha_commas, a, "[1, 2, 3, 4]", &s) != 3) good = 0;
    }
    for (int i = 0; i < 20; i++) {
        char word[16];
        snprintf(word, sizeof word, "w%d!", i);
        if (strcmp((const char *) kept[i].data, word) != 0) good = 0;
        alpha_bytes_release(&kept[i]);
    }
    CHECK(good, "results and calls across many collections");
    alpha_destroy(a);
    beta_destroy(b);
}

int main(int argc, char **argv) {
    const char *section = argc > 1 ? argv[1] : "";
    const char *stress = getenv("BOTLISH_NATIVE_GC_STRESS");
    if (stress && *stress && strcmp(stress, "0") != 0) {
        scale = 2;
    }
    if (!strcmp(section, "roots")) roots();
    else if (!strcmp(section, "types")) types();
    else if (!strcmp(section, "errors")) errors();
    else if (!strcmp(section, "invalid")) invalid();
    else if (!strcmp(section, "instances")) instances();
    else if (!strcmp(section, "two-libraries")) two_libraries();
    else if (!strcmp(section, "threads")) threads();
    else if (!strcmp(section, "stack")) stack();
    else if (!strcmp(section, "gc")) gc();
    else {
        fprintf(stderr, "usage: conformance roots|types|errors|invalid|instances|two-libraries|threads|stack|gc\n");
        return 2;
    }
    printf("done %s %d\n", section, checks);
    return failures ? 1 : 0;
}
