/* bgf.h -- the binding generator's synthetic fixture (C-BINDGEN.md,
 * "The synthetic fixture"): one small public header with every shape the
 * generator decides about. Freestanding (stddef, stdint, stdbool, stdarg
 * only), so it preprocesses for every target without a target sysroot.
 * tools/c-bindgen/fixture/bgf.c implements it; the generator never reads
 * that file. */
#ifndef BGF_H
#define BGF_H

#include <stdarg.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#include "bgf/bgf_types.h"

#define BGF_EXPORT
#define BGF_VERSION_MAJOR 3
#define BGF_FLAG_A 0x00000001u
#define BGF_FLAG_B 0x00000002u
#define BGF_FLAG_ALL (BGF_FLAG_A | BGF_FLAG_B)
#define BGF_BIG BGF_UINT64_C(0xFFFFFFFFFFFFFFFF)
#define BGF_NEGATIVE (-42)
#define BGF_SIZE_NONE ((bgf_size)-1)
#define BGF_HALF 0.5
#define BGF_NAME "bgf"
#define BGF_NULL_HANDLE ((bgf_handle *) 0)
#define BGF_CHAR 'x'
#define BGF_HIGH_CHAR ((char)200)
#define BGF_TWICE(x) ((x) * 2)

/* Enums: a named one, used in signatures, and an anonymous one. */
typedef enum bgf_color {
    BGF_RED,
    BGF_GREEN = 5,
    BGF_BLUE
} bgf_color;

enum {
    BGF_ANON_ONE = 1,
    BGF_ANON_MINUS = -1
};

/* Callbacks: a function-pointer typedef, a function-type typedef, and one
 * outside the C ABI universe. */
typedef int (*bgf_visit)(void *userdata, bgf_handle *handle, int depth);
typedef void (bgf_free_fn)(void *pointer);
typedef long double (*bgf_measure)(long double x);

/* A complete struct, only ever behind a pointer, and one passed by value. */
typedef struct bgf_point {
    int x;
    int y;
} bgf_point;

typedef struct bgf_pair { int a; int b; } bgf_pair;

/* Two tags, one spelling: struct bgf_other is named bgf_twin by its
 * typedef, and struct bgf_twin is a tag of its own -- two C types. */
typedef struct bgf_other bgf_twin;
struct bgf_twin;

/* Ordinary functions. */
extern BGF_EXPORT int bgf_add(int a, int b);
extern BGF_EXPORT bgf_size bgf_length(const char *text);
extern BGF_EXPORT bgf_u32 bgf_mix(bgf_u8 a, bgf_i16 b, bgf_u32 c, bgf_u64 d, long e, unsigned long long f);
extern BGF_EXPORT bgf_handle *bgf_open(const char *name, bgf_u32 flags);
extern BGF_EXPORT void bgf_close(bgf_handle *handle);
extern BGF_EXPORT bgf_window *bgf_window_of(bgf_handle *handle);
extern BGF_EXPORT int bgf_count(void);
extern BGF_EXPORT char bgf_plain_char(char c);
extern BGF_EXPORT bool bgf_is_even(int n);
extern BGF_EXPORT bool bgf_flip(bool b);
extern BGF_EXPORT bgf_color bgf_next_color(bgf_color c);
extern BGF_EXPORT int bgf_walk(bgf_handle *handle, bgf_visit visit, void *userdata);
extern BGF_EXPORT void bgf_set_free(bgf_free_fn *free_fn);
extern BGF_EXPORT int bgf_point_sum(const bgf_point *point);
extern BGF_EXPORT int bgf_fill(unsigned char *out, size_t count, unsigned char seed);
extern BGF_EXPORT int bgf_keywords(int fn, int type, int in, int loop, int str);
extern BGF_EXPORT int bgf_unnamed(int, const char *);
extern BGF_EXPORT bgf_handle **bgf_handles(void);
extern BGF_EXPORT unsigned char *bgf_digest(const unsigned char *data, size_t len, unsigned char out[4]);
extern BGF_EXPORT int bgf_twins(bgf_twin *a, struct bgf_twin *b);

/* Link names: an asm label, a renamed symbol, and an API name that is a
 * macro alias of another exported function. */
extern BGF_EXPORT int bgf_labeled(int x) __asm__(BGF_LABEL_PREFIX "bgf_labeled_v2");
#ifdef __APPLE__
#pragma redefine_extname bgf_renamed _bgf_renamed_impl
#else
#pragma redefine_extname bgf_renamed bgf_renamed_impl
#endif
extern BGF_EXPORT int bgf_renamed(int x);
extern BGF_EXPORT int bgf_current(int x);
#define bgf_legacy bgf_current
#define bgf_call_add(a, b) bgf_add(a, b)

/* A variadic function, bound with its fixed parameter and `variadic`, and
 * an object-like macro naming it (an alias: `named "bgf_printf"`, as Win32's
 * wsprintf names wsprintfW); its va_list sibling, which is no variadic
 * function (a va_list parameter is a fixed one, and unsupported); a variadic
 * function a function-like macro of its name shadows, which only a C thunk
 * could call -- and C cannot forward the trailing arguments a thunk is given
 * (unsupported). */
extern BGF_EXPORT int bgf_printf(const char *format, ...);
#define bgf_print bgf_printf
extern BGF_EXPORT int bgf_vprintf(const char *format, va_list args);
extern BGF_EXPORT int bgf_vshadow(int n, ...);
extern BGF_EXPORT int bgf_vother(int n, ...);
#define bgf_vshadow(n, ...) bgf_vother((n) + 1, __VA_ARGS__)

/* Shapes: C float and double (bound: C-FLOAT-FFI-MILESTONE-1.md); then
 * unsupported: an aggregate by value, a callback outside the ABI universe,
 * an explicit calling convention, a 128-bit typedef. */
extern BGF_EXPORT double bgf_scale(double x, float y);
extern BGF_EXPORT bgf_pair bgf_swap(bgf_pair p);
extern BGF_EXPORT void bgf_set_measure(bgf_measure measure);
#if defined(__x86_64__)
extern BGF_EXPORT int __attribute__((ms_abi)) bgf_ms(int x);
#endif
typedef unsigned long bgf_wide __attribute__((mode(TI)));
extern BGF_EXPORT void bgf_wide_set(bgf_wide w);
extern BGF_EXPORT int bgf_noproto();
extern BGF_EXPORT void bgf_float_out(float *out);

/* Static inline API: one representable, one not. */
static inline int bgf_square(int x) { return x * x; }
static inline int bgf_point_x(const bgf_point *p) { return p->x; }
static inline double bgf_half(double x) { return x / 2; }

/* A table-redirected API (the stubs pattern): the declared function's name
 * is a macro that calls through a global table. */
typedef struct bgf_table { int (*get)(int); } bgf_table;
extern const bgf_table *bgf_table_ptr;
extern BGF_EXPORT int bgf_get(int x);
#define bgf_get (bgf_table_ptr->get)

/* A declared function its own function-like macro shadows: a C caller of
 * bgf_shadowed(x) gets the macro, bgf_add(x, 100), never the symbol. */
extern BGF_EXPORT int bgf_shadowed(int x);
#define bgf_shadowed(x) bgf_add((x), 100)

/* Platform-only API. */
#if defined(__linux__)
extern BGF_EXPORT int bgf_linux_only(void);
#endif
#if defined(__APPLE__)
extern BGF_EXPORT int bgf_apple_only(void);
#endif
#if defined(__aarch64__)
extern BGF_EXPORT int bgf_arm_only(void);
#endif

/* The records (C-BINDGEN-LAYOUTS.md), in a header of their own: they use
 * the types above. */
#include "bgf/bgf_records.h"

/* C float and double (C-FLOAT-FFI-MILESTONE-1.md): their typedef chains
 * (bgf_types.h), pointers, a callback of float signature and functions
 * taking and returning one, the brief's dot product over two arrays; and C
 * long double, which no FFI type represents (unsupported, its own
 * blocker). */
typedef float (*bgf_float_fn)(float x);
extern BGF_EXPORT bgf_real32 bgf_scale32(bgf_scalar32 x, bgf_scalar64 k);
extern BGF_EXPORT double bgf_dot(const float *xs, const double *ys, size_t n);
extern BGF_EXPORT float bgf_apply_float(bgf_float_fn f, float x);
extern BGF_EXPORT bgf_float_fn bgf_halver(void);
extern BGF_EXPORT double bgf_sum_mixed(const bgf_mixed_floats *m);
extern BGF_EXPORT long double bgf_long_scale(long double x);
extern BGF_EXPORT double bgf_long_ptr(long double *x);

#endif
