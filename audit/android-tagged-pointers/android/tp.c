/* tp.c -- the C side of the tagged-pointer probe
 * (RN-ANDROID-TAGGED-POINTER-CORRECTNESS-MILESTONE-1.md, "Android
 * execution"): heap blocks as Bionic's malloc gives them (Android 11 and
 * later tag every heap pointer's top byte), the addresses C receives for
 * Botlish byte exposures, a record and an out parameter holding a pointer,
 * a callback given a pointer as its user data, and the probe's output. C
 * compares the pointers Botlish hands back with the ones it gave out, bit
 * for bit, and reports what it sees: Botlish never converts a pointer to an
 * Int, so the tags printed here are C's own reading of the addresses.
 *
 *   NDK clang --target=aarch64-linux-android21 -O2 -fPIC -fvisibility=hidden
 *   -c tp.c (the library exports its public functions only), then
 *   llvm-ar rcs libtp.a tp.o (the probe's `extern c library "tp" static`). */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static void *tp_last;

/* A zeroed heap block of N bytes, recorded: tp_same compares a pointer
 * Botlish passes back with it. */
unsigned char *tp_alloc(unsigned long n) {
    tp_last = malloc(n);
    if (tp_last != NULL) memset(tp_last, 0, n);
    return tp_last;
}

/* 1 if P is exactly the last block tp_alloc gave out, every bit (its tag)
 * included. */
int tp_same(const void *p) { return p == tp_last; }

/* The top byte of P as C reads it: Bionic's heap tag, or 0. */
unsigned char tp_top_byte(const void *p) { return (unsigned char)((uintptr_t)p >> 56); }

void tp_free(void *p) {
    if (p == tp_last) tp_last = NULL;
    free(p);
}

void *tp_null(void) { return NULL; }
int tp_is_null(const void *p) { return p == NULL; }

void tp_poke(unsigned char *p, unsigned long i, unsigned char v) { p[i] = v; }

/* Byte exposures: the sum of COUNT bytes at DATA, the top byte of the
 * address C was given for them, and SEED, SEED+1, ... written at OUT. */
unsigned long tp_sum(const unsigned char *data, unsigned long count) {
    unsigned long sum = 0;
    for (unsigned long i = 0; i < count; i++) sum += data[i];
    return sum;
}

unsigned char tp_exposed_top_byte(const unsigned char *data) { return (unsigned char)((uintptr_t)data >> 56); }

void tp_fill(unsigned char *out, unsigned long count, unsigned char seed) {
    for (unsigned long i = 0; i < count; i++) out[i] = (unsigned char)(seed + i);
}

/* A record holding a pointer (a C struct field, read through a native
 * view): it holds the last block. tp_holder_matches says whether a store
 * through a native edit put exactly that block back. */
struct tp_holder {
    void *pointer;
    unsigned long size;
};
static struct tp_holder tp_record;

struct tp_holder *tp_holder(void) {
    tp_record.pointer = tp_last;
    tp_record.size = 64;
    return &tp_record;
}

void tp_holder_clear(void) { tp_record.pointer = NULL; }
int tp_holder_matches(void) { return tp_record.pointer == tp_last && tp_last != NULL; }

/* A callback given DATA as its user data, which it returns: 1 if it gave
 * back exactly DATA. */
typedef void *(*tp_echo)(void *);
int tp_call_back(tp_echo f, void *data) { return f(data) == data; }

/* The probe's output: the COUNT bytes at TEXT and a newline, on standard
 * output (a byte exposure too). */
void tp_say(const unsigned char *text, unsigned long count) {
    fwrite(text, 1, count, stdout);
    fputc('\n', stdout);
    fflush(stdout);
}
