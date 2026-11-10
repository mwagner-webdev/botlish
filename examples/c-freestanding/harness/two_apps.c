/*
 * two_apps.c -- two programs the Botlish C backend generated, run side by
 * side in one executable (C-CONTEXTS-FREESTANDING-MILESTONE-1.md,
 * "Context instance independence"). It is not part of either program.
 *
 * Programs A and B are two Botlish entry programs -- typically one
 * application installed with two different sets of contexts -- each
 * compiled with its own prefix. The harness runs them interleaved, A B B A
 * A B, prints one line per run,
 *
 *     PREFIX run N: value: TEXT
 *     PREFIX run N: error: MESSAGE (CODE)
 *
 * and then whether every run of a program gave the same text as its first:
 *
 *     repeated runs: identical          (exit status 0)
 *     repeated runs: DIFFERENT          (exit status 1)
 *
 * Hosted (a C library's stdout):
 *
 *     cc -std=c11 -DTWO_APPS_HOSTED \
 *        -DBOTLISH_PROGRAM_A=a -DBOTLISH_PROGRAM_A_HEADER='"a.h"' \
 *        -DBOTLISH_PROGRAM_B=b -DBOTLISH_PROGRAM_B_HEADER='"b.h"' \
 *        -I OUT two_apps.c OUT/a.c OUT/a_display.c OUT/b.c OUT/b_display.c
 *
 * With no C library at all (Linux; linux_start.c's _start calls
 * two_apps_main and its write system call prints):
 *
 *     cc -std=c11 -ffreestanding -nostdlib -static -fno-stack-protector \
 *        -DBOTLISH_START_ENTRY=two_apps_main [the four -D above] -I OUT \
 *        linux_start.c two_apps.c OUT/a.c OUT/a_display.c OUT/b.c OUT/b_display.c
 */
#include <stdbool.h>
#include <stddef.h>

#include BOTLISH_PROGRAM_A_HEADER
#include BOTLISH_PROGRAM_B_HEADER

#define BOTLISH_CAT2(a, b) a##b
#define BOTLISH_CAT(a, b) BOTLISH_CAT2(a, b)
#define BOTLISH_TEXT2(a) #a
#define BOTLISH_TEXT(a) BOTLISH_TEXT2(a)
#define A(name) BOTLISH_CAT(BOTLISH_PROGRAM_A, name)
#define B(name) BOTLISH_CAT(BOTLISH_PROGRAM_B, name)

#ifndef TWO_APPS_BUFFER
#define TWO_APPS_BUFFER 4096
#endif

#ifdef TWO_APPS_HOSTED
#include <stdio.h>

static void write_out(const char *s, size_t n)
{
    fwrite(s, 1, n, stdout);
}
#else
void botlish_start_write(const char *s, size_t n);

static void write_out(const char *s, size_t n)
{
    botlish_start_write(s, n);
}
#endif

int two_apps_main(void);

static size_t length_of(const char *s)
{
    size_t n = 0;
    while (s[n] != '\0') {
        n++;
    }
    return n;
}

static void put(const char *s)
{
    write_out(s, length_of(s));
}

/* One run's line, after "PREFIX run N: ", in TEXT (at most TWO_APPS_BUFFER
 * bytes; *length its length). */
typedef struct run_text {
    char text[TWO_APPS_BUFFER];
    size_t length;
} run_text;

static void append(run_text *out, const char *s, size_t n)
{
    size_t k;
    for (k = 0; k < n && out->length < sizeof out->text; k++) {
        out->text[out->length++] = s[k];
    }
}

static void append_text(run_text *out, const char *s)
{
    append(out, s, length_of(s));
}

static void run_a(run_text *out)
{
    A(_value) value;
    A(_status) status = A(_run)(&value);
    out->length = 0;
    if (status == A(_OK)) {
        append_text(out, "value: ");
        out->length += A(_show)(&value, out->text + out->length, sizeof out->text - out->length);
        if (out->length > sizeof out->text) {
            out->length = sizeof out->text;
        }
    } else {
        append_text(out, "error: ");
        append_text(out, A(_status_message)(status));
        append_text(out, " (");
        append_text(out, A(_status_code)(status));
        append_text(out, ")");
    }
}

static void run_b(run_text *out)
{
    B(_value) value;
    B(_status) status = B(_run)(&value);
    out->length = 0;
    if (status == B(_OK)) {
        append_text(out, "value: ");
        out->length += B(_show)(&value, out->text + out->length, sizeof out->text - out->length);
        if (out->length > sizeof out->text) {
            out->length = sizeof out->text;
        }
    } else {
        append_text(out, "error: ");
        append_text(out, B(_status_message)(status));
        append_text(out, " (");
        append_text(out, B(_status_code)(status));
        append_text(out, ")");
    }
}

static bool same(const run_text *x, const run_text *y)
{
    size_t k;
    if (x->length != y->length) {
        return false;
    }
    for (k = 0; k < x->length; k++) {
        if (x->text[k] != y->text[k]) {
            return false;
        }
    }
    return true;
}

static void report(const char *name, int n, const run_text *run)
{
    char digit[2];
    digit[0] = (char)('0' + n);
    digit[1] = '\0';
    put(name);
    put(" run ");
    put(digit);
    put(": ");
    write_out(run->text, run->length);
    put("\n");
}

/* The runs, interleaved: A B B A A B. */
static run_text first_a, first_b, again;

int two_apps_main(void)
{
    static const char order[] = "ABBAAB";
    const char *name_a = BOTLISH_TEXT(BOTLISH_PROGRAM_A);
    const char *name_b = BOTLISH_TEXT(BOTLISH_PROGRAM_B);
    int runs_a = 0, runs_b = 0;
    bool identical = true;
    size_t k;
    for (k = 0; order[k] != '\0'; k++) {
        if (order[k] == 'A') {
            run_text *out = runs_a == 0 ? &first_a : &again;
            run_a(out);
            report(name_a, ++runs_a, out);
            if (out != &first_a && !same(out, &first_a)) {
                identical = false;
            }
        } else {
            run_text *out = runs_b == 0 ? &first_b : &again;
            run_b(out);
            report(name_b, ++runs_b, out);
            if (out != &first_b && !same(out, &first_b)) {
                identical = false;
            }
        }
    }
    put(identical ? "repeated runs: identical\n" : "repeated runs: DIFFERENT\n");
    return identical ? 0 : 1;
}

#ifdef TWO_APPS_HOSTED
int main(void)
{
    return two_apps_main();
}
#endif
