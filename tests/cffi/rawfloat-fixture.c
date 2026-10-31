/* rawfloat-fixture.c -- the C side of tests/raw-c-float-ffi.test
 * (RAW-C-FLOAT-FFI-MILESTONE-1.md): C float and C double carried raw --
 * every IEEE 754 bit pattern, NaN payloads, signaling NaNs, the infinities,
 * negative zero and subnormals -- as arguments and results (in registers
 * and on the stack), struct fields, array elements, union alternatives,
 * pointees and through function pointers. Every function either reports the
 * exact bits C received or returns a value assembled from exact bits, and
 * none computes on a floating value (a conversion or an arithmetic
 * operation may quiet a signaling NaN; a move never does), so a test can
 * require bit-exact agreement. Compiled by the test into a static archive in
 * a private directory; test infrastructure only. */

#include <stddef.h>
#include <stdint.h>
#include <string.h>

uint32_t rfx_float_bits(float x) {
    uint32_t u;
    memcpy(&u, &x, sizeof u);
    return u;
}

uint64_t rfx_double_bits(double x) {
    uint64_t u;
    memcpy(&u, &x, sizeof u);
    return u;
}

float rfx_float_of_bits(uint32_t u) {
    float x;
    memcpy(&x, &u, sizeof x);
    return x;
}

double rfx_double_of_bits(uint64_t u) {
    double x;
    memcpy(&x, &u, sizeof x);
    return x;
}

/* Values passed straight back: the argument register is the result
 * register's class, and nothing converts it. */
float rfx_echo_float(float x) { return x; }
double rfx_echo_double(double x) { return x; }

/* The bits of argument W of twelve floats or doubles: past every target's
 * eight floating-point argument registers, the last ones are on the stack. */
uint32_t rfx_pick_float_bits(int w, float a0, float a1, float a2, float a3, float a4, float a5,
                             float a6, float a7, float a8, float a9, float a10, float a11) {
    float all[12] = {a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11};
    return rfx_float_bits(all[w]);
}

uint64_t rfx_pick_double_bits(int w, double a0, double a1, double a2, double a3, double a4, double a5,
                              double a6, double a7, double a8, double a9, double a10, double a11) {
    double all[12] = {a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11};
    return rfx_double_bits(all[w]);
}

/* Argument W of an interleaving of floats, doubles and integers, returned
 * as a double (W even: the double after it; W odd: the float, as the bits of
 * a double whose low half they are) -- each class in its own registers,
 * then the stack. */
uint64_t rfx_pick_mixed_bits(int w, float f0, double d0, int32_t i0, float f1, double d1, int64_t i1,
                             float f2, double d2, float f3, double d3, float f4, double d4, float f5,
                             double d5, float f6, double d6, float f7, double d7, float f8, double d8) {
    float fs[9] = {f0, f1, f2, f3, f4, f5, f6, f7, f8};
    double ds[9] = {d0, d1, d2, d3, d4, d5, d6, d7, d8};
    if (w == 100) return (uint64_t)(uint32_t)i0;
    if (w == 101) return (uint64_t)i1;
    if (w % 2 == 0) return rfx_double_bits(ds[w / 2]);
    return rfx_float_bits(fs[w / 2]);
}

/* A float result that is argument W of nine floats (the ninth on the stack
 * of a SysV or AAPCS64 call), returned in the float result register. */
float rfx_select_float(int w, float a0, float a1, float a2, float a3, float a4, float a5, float a6,
                       float a7, float a8) {
    float all[9] = {a0, a1, a2, a3, a4, a5, a6, a7, a8};
    return all[w];
}

double rfx_select_double(int w, double a0, double a1, double a2, double a3, double a4, double a5,
                         double a6, double a7, double a8) {
    double all[9] = {a0, a1, a2, a3, a4, a5, a6, a7, a8};
    return all[w];
}

/* struct RawRec as a Botlish layout declares it: a float and a double
 * field, a float array, after a tag byte. */
struct RawRec {
    uint8_t tag;
    float f;
    double d;
    float xs[3];
    uint32_t pad;
};

union RawUnion {
    float f;
    double d;
    uint64_t u;
};

size_t rfx_rec_size(void) { return sizeof(struct RawRec); }
size_t rfx_rec_offset_f(void) { return offsetof(struct RawRec, f); }
size_t rfx_rec_offset_d(void) { return offsetof(struct RawRec, d); }
size_t rfx_rec_offset_xs(void) { return offsetof(struct RawRec, xs); }

/* Fills R's fields from bit patterns, with C's own stores of floats. */
void rfx_rec_fill(struct RawRec *r, uint32_t f, uint64_t d, uint32_t x0, uint32_t x1, uint32_t x2) {
    r->tag = 7;
    r->f = rfx_float_of_bits(f);
    r->d = rfx_double_of_bits(d);
    r->xs[0] = rfx_float_of_bits(x0);
    r->xs[1] = rfx_float_of_bits(x1);
    r->xs[2] = rfx_float_of_bits(x2);
    r->pad = 0;
}

/* The bits C reads from R's field K (0 f, 1 d, 2.. xs[K - 2]). */
uint64_t rfx_rec_bits(const struct RawRec *r, int k) {
    if (k == 0) return rfx_float_bits(r->f);
    if (k == 1) return rfx_double_bits(r->d);
    return rfx_float_bits(r->xs[k - 2]);
}

/* A union's float alternative stored by C: only its low 4 bytes. */
void rfx_union_store_float(union RawUnion *u, uint32_t bits) { u->f = rfx_float_of_bits(bits); }
uint64_t rfx_union_bits(const union RawUnion *u) { return u->u; }

/* Floats through a float *: written from bits, read back as bits. */
void rfx_store_floats(float *p, size_t n, uint32_t first) {
    for (size_t i = 0; i < n; i++) p[i] = rfx_float_of_bits(first + (uint32_t)i);
}
uint32_t rfx_load_float(const float *p, size_t i) { return rfx_float_bits(p[i]); }

/* A function pointer of a raw signature: C hands one out and calls it. */
typedef double (*rfx_double_fn)(double);
typedef float (*rfx_float_fn)(float, double);
static double rfx_negate_bits(double x) {
    uint64_t u = rfx_double_bits(x) ^ 0x8000000000000000ull;
    return rfx_double_of_bits(u);
}
static float rfx_take_float(float x, double unused) {
    (void)unused;
    return x;
}
rfx_double_fn rfx_negator(void) { return rfx_negate_bits; }
rfx_float_fn rfx_taker(void) { return rfx_take_float; }
double rfx_apply_double(rfx_double_fn f, double x) { return f(x); }
float rfx_apply_float(rfx_float_fn f, float x, double y) { return f(x, y); }

/* Native memory C owns, for views and edits: one RawRec, one union and a
 * buffer of sixteen floats (static: never freed, 16-byte aligned). */
static _Alignas(16) struct RawRec rfx_rec_storage;
static _Alignas(16) union RawUnion rfx_union_storage;
static _Alignas(16) float rfx_float_storage[16];
void *rfx_record(void) { return &rfx_rec_storage; }
void *rfx_union(void) { return &rfx_union_storage; }
float *rfx_float_buffer(void) { return rfx_float_storage; }
