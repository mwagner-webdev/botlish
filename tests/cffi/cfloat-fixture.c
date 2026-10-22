/* cfloat-fixture.c -- the C side of tests/c-float-ffi.test
 * (C-FLOAT-FFI-MILESTONE-1.md): C float and C double in the platform C ABI,
 * as arguments, results, struct fields, pointees and array elements, and
 * through function pointers. The functions report exactly what C received
 * (its bit patterns) and return exactly what a test asks for (any bit
 * pattern, NaN and the infinities among them), so the tests can check every
 * conversion bit for bit against an oracle that is not Botlish. Compiled by
 * the test into a static archive in a private directory; test
 * infrastructure only. */

#include <math.h>
#include <stdarg.h>
#include <stddef.h>
#include <stdint.h>
#include <string.h>

/* The brief's names. */
float echo_float(float x) { return x; }
double echo_double(double x) { return x; }
float add_float(float a, float b) { return a + b; }
double add_double(double a, double b) { return a + b; }
/* C's own (float) conversion: what a C program narrowing a double gets. */
float float_from_double(double x) { return (float)x; }
double double_from_float(float x) { return (double)x; }

float return_float_nan(void) { return NAN; }
float return_float_pos_inf(void) { return INFINITY; }
float return_float_neg_inf(void) { return -INFINITY; }
double return_double_nan(void) { return NAN; }
double return_double_pos_inf(void) { return INFINITY; }
double return_double_neg_inf(void) { return -INFINITY; }

/* The exact bits C received. */
uint32_t cff_float_bits(float x) {
    uint32_t u;
    memcpy(&u, &x, sizeof u);
    return u;
}
uint64_t cff_double_bits(double x) {
    uint64_t u;
    memcpy(&u, &x, sizeof u);
    return u;
}

/* Any bit pattern, returned as the C type: NaN payloads, the infinities,
 * negative zero, subnormals. */
float cff_float_of_bits(uint32_t u) {
    float x;
    memcpy(&x, &u, sizeof x);
    return x;
}
double cff_double_of_bits(uint64_t u) {
    double x;
    memcpy(&x, &u, sizeof x);
    return x;
}

/* A side effect C performs when it is called: the count of calls of
 * cff_counted, so a test can tell that a call whose float argument could
 * not be narrowed never reached C. */
static int cff_calls;
int cff_counted(float x) { (void)x; return ++cff_calls; }
int cff_count(void) { return cff_calls; }

/* 1 when C received a negative zero. */
int cff_float_signbit(float x) { return signbit(x) != 0; }
int cff_double_signbit(double x) { return signbit(x) != 0; }

/* Register exhaustion. More floats than there are floating-point argument
 * registers on any supported target (8: xmm0-7 on SysV x86-64, v0-v7 on
 * AAPCS64; 4 positional ones on Win64), the rest on the stack: argument
 * WHICH, returned exactly (widened, which is exact). */
double cff_pick_float(int which, float a0, float a1, float a2, float a3,
                      float a4, float a5, float a6, float a7, float a8,
                      float a9, float a10, float a11) {
    float all[12] = {a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11};
    return (which >= 0 && which < 12) ? (double)all[which] : -1.0;
}

/* Floats, doubles and integers interleaved, twenty-one in all: each class
 * fills its own registers on SysV and AAPCS64 (and the positions on Win64),
 * then the stack, where Apple packs a float into 4 bytes and SysV and
 * Linux AAPCS64 give it an 8-byte slot. Argument WHICH (0 .. 20) as a
 * double. */
double cff_pick_mixed(int which,
                      float f0, double d0, int i0, float f1, double d1, long i1,
                      float f2, double d2, short i2, float f3, double d3, int i3,
                      float f4, double d4, long long i4, float f5, double d5,
                      unsigned char i5, float f6, double d6) {
    switch (which) {
    case 0: return f0;  case 1: return d0;  case 2: return i0;
    case 3: return f1;  case 4: return d1;  case 5: return (double)i1;
    case 6: return f2;  case 7: return d2;  case 8: return i2;
    case 9: return f3;  case 10: return d3; case 11: return i3;
    case 12: return f4; case 13: return d4; case 14: return (double)i4;
    case 15: return f5; case 16: return d5; case 17: return i5;
    case 18: return f6; case 19: return d6;
    }
    return -1.0;
}

/* Sixteen floats then a float result: every float register used, the
 * result in the first again. */
float cff_sum16f(float a, float b, float c, float d, float e, float f,
                 float g, float h, float i, float j, float k, float l,
                 float m, float n, float o, float p) {
    return a + 2 * b + 3 * c + 4 * d + 5 * e + 6 * f + 7 * g + 8 * h +
           9 * i + 10 * j + 11 * k + 12 * l + 13 * m + 14 * n + 15 * o + 16 * p;
}

/* The bits of float argument WHICH of nine floats (the ninth on the stack on
 * every target): what C read from the slot, exactly. */
uint32_t cff_float_bits9(int which, float a0, float a1, float a2, float a3,
                         float a4, float a5, float a6, float a7, float a8) {
    float all[9] = {a0, a1, a2, a3, a4, a5, a6, a7, a8};
    return (which >= 0 && which < 9) ? cff_float_bits(all[which]) : 0;
}

/* A variadic function with fixed floats (SDL_RenderDebugTextFormat's
 * shape: floats among the fixed parameters, then `...`): the fixed floats
 * take floating-point registers as doubles do, so the trailing arguments
 * follow them (System V, Linux AAPCS64) or all go to the stack (Apple).
 * Argument WHICH as a double: 0 x, 1 y, then the trailing ones, COUNT
 * pairs of an int and a double. */
double cff_vpick(int which, float x, float y, int count, ...) {
    va_list ap;
    double r = -1.0;
    if (which == 0) r = x;
    if (which == 1) r = y;
    va_start(ap, count);
    for (int i = 0; i < count; i++) {
        int n = va_arg(ap, int);
        double d = va_arg(ap, double);
        if (which == 2 + 2 * i) r = n;
        if (which == 3 + 2 * i) r = d;
    }
    va_end(ap);
    return r;
}

/* The brief's struct: on every supported target sizeof 24, _Alignof 8, and
 * offsets 0, 4, 8, 16 (a float aligned to 4, a double to 8). */
struct MixedFloats {
    uint8_t tag;
    float a;
    double b;
    float c;
};

size_t cff_mixed_size(void) { return sizeof(struct MixedFloats); }
size_t cff_mixed_align(void) { return _Alignof(struct MixedFloats); }
size_t cff_mixed_offset(int which) {
    switch (which) {
    case 0: return offsetof(struct MixedFloats, tag);
    case 1: return offsetof(struct MixedFloats, a);
    case 2: return offsetof(struct MixedFloats, b);
    case 3: return offsetof(struct MixedFloats, c);
    }
    return (size_t)-1;
}
size_t cff_float_size(void) { return sizeof(float); }
size_t cff_float_align(void) { return _Alignof(float); }
size_t cff_double_size(void) { return sizeof(double); }
size_t cff_double_align(void) { return _Alignof(double); }

/* Native memory a test reads and writes through a view or an edit: one
 * MixedFloats, a float buffer and a double buffer (static storage, so the
 * pointers are independent of every argument). */
static struct MixedFloats cff_mixed;
static float cff_floats[16];
static double cff_doubles[16];

struct MixedFloats *cff_mixed_record(void) { return &cff_mixed; }
float *cff_float_buffer(void) { return cff_floats; }
double *cff_double_buffer(void) { return cff_doubles; }

void cff_fill_mixed(struct MixedFloats *m, uint8_t tag, float a, double b, float c) {
    m->tag = tag;
    m->a = a;
    m->b = b;
    m->c = c;
}
/* The bits of field WHICH (1 a, 2 b, 3 c) of *M, as C reads it. */
uint64_t cff_mixed_bits(const struct MixedFloats *m, int which) {
    switch (which) {
    case 1: return cff_float_bits(m->a);
    case 2: return cff_double_bits(m->b);
    case 3: return cff_float_bits(m->c);
    }
    return 0;
}
/* Writes the bit pattern U into float element I of P (a NaN, an infinity,
 * negative zero: what foreign memory may hold). */
void cff_poke_float_bits(float *p, int i, uint32_t u) { memcpy(&p[i], &u, sizeof u); }
void cff_poke_double_bits(double *p, int i, uint64_t u) { memcpy(&p[i], &u, sizeof u); }
uint32_t cff_peek_float_bits(const float *p, int i) { return cff_float_bits(p[i]); }
uint64_t cff_peek_double_bits(const double *p, int i) { return cff_double_bits(p[i]); }

/* The brief's pointer functions. */
void mutate_float(float *x) { *x = *x * 2.0f + 0.25f; }
void mutate_double(double *x) { *x = *x * 2.0 + 0.25; }
double dot(const float *xs, const double *ys, size_t n) {
    double s = 0.0;
    for (size_t i = 0; i < n; i++) {
        s += (double)xs[i] * ys[i];
    }
    return s;
}

/* Function pointers of float signatures: Botlish receives one, passes it
 * back, and C calls it. */
static float cff_halve(float x) { return x / 2.0f; }
static double cff_square(double x) { return x * x; }
static double cff_scale(float x, double k) { return (double)x * k; }
float (*cff_halver(void))(float) { return cff_halve; }
double (*cff_squarer(void))(double) { return cff_square; }
double (*cff_scaler(void))(float, double) { return cff_scale; }
float cff_apply_float(float (*f)(float), float x) { return f(x); }
double cff_apply_double(double (*f)(double), double x) { return f(x); }
double cff_apply_mixed(double (*f)(float, double), float x, double k) { return f(x, k); }
