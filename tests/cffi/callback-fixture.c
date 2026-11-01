/* callback-fixture.c -- the C side of tests/c-callbacks.test and
 * bench/c-callbacks.tcl (C-CALLBACK-MILESTONE-1.md).
 *
 * Every function here takes C function pointers and calls them, as a C
 * library that calls back would: synchronously, during the call (the
 * bindings declare those parameters noescape), from the calling thread --
 * except the few that do what a callback contract forbids (call one on
 * another thread, keep one and call it later) to show the runtime refuses.
 * Where a callback's answer is checkable, C checks it itself, with its own
 * arithmetic and its own reading of the bits it passed, never trusting a
 * value the Botlish side computes: the functions return how many answers
 * were wrong (0 when every one was right), or the values C computed.
 *
 * Built by the tests into a private static library (botlish_callback_fixture)
 * with the host's C compiler; nothing else links it. */
#include <stdbool.h>
#include <stdint.h>
#include <string.h>
#include <pthread.h>

/* ------------------------------------------------------------------------
 * Integer callbacks */

typedef int (*cbx_unary)(int);
typedef void (*cbx_thunk)(void);

int cbx_apply(cbx_unary f, int x) { return f(x); }

/* A plain C function: no callback (the unrelated foreign call). */
int cbx_add(int a, int b) { return a + b; }

/* A synchronous decision C acts on at once: the callback says whether i is
 * even, and C counts the answers that are wrong by its own arithmetic. */
int cbx_check_parity(cbx_unary is_even, int n) {
    int wrong = 0;
    for (int i = -n; i < n; i++) {
        int answer = is_even(i);
        if ((answer != 0) != (i % 2 == 0)) {
            wrong++;
        }
    }
    return wrong;
}

/* C keeps only the elements the callback accepts (a filter whose result C
 * uses), then returns their sum: the callback is asked "keep x?" for
 * x = 0..n-1. */
long long cbx_filter_sum(cbx_unary keep, int n) {
    long long sum = 0;
    for (int i = 0; i < n; i++) {
        if (keep(i)) {
            sum += i;
        }
    }
    return sum;
}

/* A void(void) callback, N times; returns N. */
int cbx_tick(cbx_thunk f, int n) {
    for (int i = 0; i < n; i++) {
        f();
    }
    return n;
}

/* The tight loop of the benchmark and of the repeated-entry tests: the sum
 * of f(i) for i in 0..n-1. */
long long cbx_sum(cbx_unary f, int n) {
    long long sum = 0;
    for (int i = 0; i < n; i++) {
        sum += f(i);
    }
    return sum;
}

/* The benchmark's baseline: the same loop's work with no callback. */
volatile long long cbx_sink;
int cbx_plain(int x) { cbx_sink += x; return x; }

/* A call of f(x) with the frame-pointer register holding no frame: what a
 * C function compiled without frame pointers may leave there (it is an
 * ordinary callee-saved register to it), here made certain -- 16, an
 * address no stack has. A runtime that followed the frame-pointer chain
 * from a callback's frames into C's would stop or wander here; Botlish's
 * collector never reads a C frame (framewalk::walk_segmented). Elsewhere
 * (another architecture) a plain call. */
static int call_without_frame(cbx_unary f, int x) {
#if defined(__x86_64__) && !defined(_WIN32)
    long xv = x;
    long r;
    __asm__ volatile(
        "mov %%rsp, %%rbx\n\t"
        "sub $128, %%rsp\n\t" /* past the red zone */
        "and $-16, %%rsp\n\t"
        "push %%rbp\n\t"
        "push %%rbp\n\t"
        "mov $16, %%ebp\n\t"
        "call *%%rsi\n\t"
        "pop %%rbp\n\t"
        "mov %%rbx, %%rsp\n\t"
        : "=a"(r), "+S"(f), "+D"(xv)
        :
        : "rbx", "rcx", "rdx", "r8", "r9", "r10", "r11", "xmm0", "xmm1", "xmm2", "xmm3", "xmm4", "xmm5", "xmm6",
          "xmm7", "xmm8", "xmm9", "xmm10", "xmm11", "xmm12", "xmm13", "xmm14", "xmm15", "cc", "memory");
    return (int)r;
#elif defined(__aarch64__) && !defined(_WIN32)
    int r;
    /* Both inputs are read before x29 is overwritten (with frame pointers
     * omitted the compiler may have placed one there); x16 is a clobbered
     * scratch register. */
    __asm__ volatile(
        "mov x16, %[f]\n\t"
        "mov w0, %w[x]\n\t"
        "stp x29, x30, [sp, #-16]!\n\t"
        "mov x29, #16\n\t"
        "blr x16\n\t"
        "ldp x29, x30, [sp], #16\n\t"
        "mov %w[r], w0\n\t"
        : [r] "=r"(r)
        : [f] "r"(f), [x] "r"(x)
        : "x0", "x1", "x2", "x3", "x4", "x5", "x6", "x7", "x8", "x9", "x10", "x11", "x12", "x13", "x14", "x15",
          "x16", "x17",
#if !defined(__APPLE__)
          "x18",
#endif
          "x30", "v0", "v1", "v2", "v3", "v4", "v5", "v6", "v7", "v8", "v9", "v10", "v11", "v12", "v13", "v14",
          "v15", "v16", "v17", "v18", "v19", "v20", "v21", "v22", "v23", "v24", "v25", "v26", "v27", "v28", "v29",
          "v30", "v31", "cc", "memory");
    return r;
#else
    return f(x);
#endif
}

/* Nesting: OUTER calls f(x) and returns 2 * f(x) + 1; INNER returns
 * f(x) + 7. A Botlish callback of OUTER calls INNER, whose callback runs
 * nested in the same execution environment. Both call with no frame chain
 * (call_without_frame). */
int cbx_outer(cbx_unary f, int x) { return 2 * call_without_frame(f, x) + 1; }
int cbx_inner(cbx_unary f, int x) { return call_without_frame(f, x) + 7; }

/* Recursion through C: f(depth) is expected to call cbx_recurse again with
 * depth - 1 down to 0, each level adding 1; C checks each level's answer. */
static int recursion_errors;
int cbx_recurse(cbx_unary f, int depth) {
    int r = call_without_frame(f, depth);
    if (r != depth) {
        recursion_errors++;
    }
    return r;
}
int cbx_recursion_errors(void) { return recursion_errors; }

/* ------------------------------------------------------------------------
 * Every scalar class both ways: C calls the callback with each value and
 * counts the answers that are not the value itself (an identity callback). */

#define ECHO(NAME, T)                                                          \
    int cbx_echo_##NAME(T (*f)(T), int count, const T *values) {               \
        int wrong = 0;                                                         \
        for (int i = 0; i < count; i++) {                                      \
            if (f(values[i]) != values[i]) {                                   \
                wrong++;                                                       \
            }                                                                  \
        }                                                                      \
        return wrong;                                                          \
    }
#define ECHO_LIMITS(NAME, T, LO, HI)                                           \
    ECHO(NAME, T)                                                              \
    int cbx_echo_limits_##NAME(T (*f)(T)) {                                    \
        const T values[] = {(T)(LO), (T)(HI), (T)0, (T)1, (T)((HI) / 3)};      \
        return cbx_echo_##NAME(f, 5, values);                                  \
    }
ECHO_LIMITS(schar, signed char, -128, 127)
ECHO_LIMITS(uchar, unsigned char, 0, 255)
ECHO_LIMITS(short, short, -32768, 32767)
ECHO_LIMITS(ushort, unsigned short, 0, 65535)
ECHO_LIMITS(int, int, INT32_MIN, INT32_MAX)
ECHO_LIMITS(uint, unsigned int, 0, UINT32_MAX)
ECHO_LIMITS(longlong, long long, INT64_MIN, INT64_MAX)
ECHO_LIMITS(ulonglong, unsigned long long, 0, UINT64_MAX)

int cbx_echo_bool(bool (*f)(bool)) {
    return (f(true) != true) + (f(false) != false);
}

/* A pointer in and out: the callback returns the address it was given. */
int cbx_echo_pointer(void *(*f)(void *)) {
    static char object[4];
    void *values[] = {object, object + 3, (void *)0, (void *)0x7ffffffff000ull};
    int wrong = 0;
    for (int i = 0; i < 4; i++) {
        if (f(values[i]) != values[i]) {
            wrong++;
        }
    }
    return wrong;
}

/* ------------------------------------------------------------------------
 * Raw floating values: every bit pattern crosses unchanged. C builds each
 * pattern from its bits (never from arithmetic), passes it, and compares
 * the bits it gets back with the bits it built. */

static const uint64_t double_patterns[] = {
    0x0000000000000000ull, /* +0 */
    0x8000000000000000ull, /* -0 */
    0x3ff8000000000000ull, /* 1.5 */
    0x7ff0000000000000ull, /* +inf */
    0xfff0000000000000ull, /* -inf */
    0x7ff8000000000000ull, /* quiet NaN */
    0x7ff8000000000123ull, /* quiet NaN, payload */
    0xfff8000000000456ull, /* negative quiet NaN, payload */
    0x7ff0000000000001ull, /* signaling NaN, payload 1 */
    0x7ff4000000000abcull, /* signaling NaN, payload */
    0x0000000000000001ull, /* the least subnormal */
    0x800fffffffffffffull, /* the greatest negative subnormal */
    0x7fefffffffffffffull, /* DBL_MAX */
};
static const uint32_t float_patterns[] = {
    0x00000000u, 0x80000000u, 0x3fc00000u, 0x7f800000u, 0xff800000u, 0x7fc00000u,
    0x7fc00123u, 0xffc00456u, 0x7f800001u, 0x7fa00abcu, 0x00000001u, 0x807fffffu, 0x7f7fffffu,
};
#define PATTERNS(a) ((int)(sizeof(a) / sizeof((a)[0])))

static double double_of(uint64_t bits) { double d; memcpy(&d, &bits, 8); return d; }
static uint64_t bits_of_double(double d) { uint64_t b; memcpy(&b, &d, 8); return b; }
static float float_of(uint32_t bits) { float f; memcpy(&f, &bits, 4); return f; }
static uint32_t bits_of_float(float f) { uint32_t b; memcpy(&b, &f, 4); return b; }

int cbx_double_patterns(void) { return PATTERNS(double_patterns); }

/* The callback returns its argument: how many patterns come back changed. */
int cbx_roundtrip_doubles(double (*f)(double)) {
    int wrong = 0;
    for (int i = 0; i < PATTERNS(double_patterns); i++) {
        if (bits_of_double(f(double_of(double_patterns[i]))) != double_patterns[i]) {
            wrong++;
        }
    }
    return wrong;
}
int cbx_roundtrip_floats(float (*f)(float)) {
    int wrong = 0;
    for (int i = 0; i < PATTERNS(float_patterns); i++) {
        if (bits_of_float(f(float_of(float_patterns[i]))) != float_patterns[i]) {
            wrong++;
        }
    }
    return wrong;
}

/* The callback returns the bits it was given (an inspection of the raw
 * value in Botlish): how many differ from the bits C built. */
int cbx_bits_doubles(unsigned long long (*f)(double)) {
    int wrong = 0;
    for (int i = 0; i < PATTERNS(double_patterns); i++) {
        if (f(double_of(double_patterns[i])) != double_patterns[i]) {
            wrong++;
        }
    }
    return wrong;
}
int cbx_bits_floats(unsigned int (*f)(float)) {
    int wrong = 0;
    for (int i = 0; i < PATTERNS(float_patterns); i++) {
        if (f(float_of(float_patterns[i])) != float_patterns[i]) {
            wrong++;
        }
    }
    return wrong;
}

/* The callback classifies its argument: 0 finite, 1 NaN, 2 an infinity --
 * which C reads from the bits it built. */
static int classify_bits(uint64_t bits) {
    uint64_t exponent = (bits >> 52) & 0x7ff, mantissa = bits & 0xfffffffffffffull;
    return exponent != 0x7ff ? 0 : mantissa ? 1 : 2;
}
int cbx_classify_doubles(int (*f)(double)) {
    int wrong = 0;
    for (int i = 0; i < PATTERNS(double_patterns); i++) {
        if (f(double_of(double_patterns[i])) != classify_bits(double_patterns[i])) {
            wrong++;
        }
    }
    return wrong;
}

/* The callback admits its argument to a Float64 and returns it as a C
 * double (finite values only: a Botlish NaN would be an error): C passes
 * the finite patterns, and the results must be them (negative zero
 * admitted as zero). */
int cbx_admit_doubles(double (*f)(double)) {
    int wrong = 0;
    for (int i = 0; i < PATTERNS(double_patterns); i++) {
        uint64_t bits = double_patterns[i];
        if (classify_bits(bits) != 0) {
            continue;
        }
        uint64_t expected = bits == 0x8000000000000000ull ? 0 : bits;
        if (bits_of_double(f(double_of(bits))) != expected) {
            wrong++;
        }
    }
    return wrong;
}

/* The benchmark's raw loops: N calls of an identity callback. */
volatile uint64_t cbx_bits_sink;
long long cbx_bench_doubles(double (*f)(double), int n) {
    for (int i = 0; i < n; i++) {
        cbx_bits_sink ^= bits_of_double(f(double_of(double_patterns[i % PATTERNS(double_patterns)])));
    }
    return n;
}
long long cbx_bench_floats(float (*f)(float), int n) {
    for (int i = 0; i < n; i++) {
        cbx_bits_sink ^= bits_of_float(f(float_of(float_patterns[i % PATTERNS(float_patterns)])));
    }
    return n;
}
long long cbx_bench_double_in(int (*f)(double), int n) {
    long long sum = 0;
    for (int i = 0; i < n; i++) {
        sum += f(double_of(double_patterns[i % 3]));
    }
    return sum;
}
long long cbx_bench_float_in(int (*f)(float), int n) {
    long long sum = 0;
    for (int i = 0; i < n; i++) {
        sum += f(float_of(float_patterns[i % 3]));
    }
    return sum;
}

/* ------------------------------------------------------------------------
 * The ABI: a callback of many mixed parameters, past the argument registers
 * of every convention (x86-64 System V: 6 integer, 8 vector; AAPCS64: 8 and
 * 8), so some arrive on the stack. The callback hands each argument back
 * to C (cbx_record_*), which compares it with what it passed; it returns
 * the sum of its int arguments, which C checks too. */

typedef long long (*cbx_mixed_fn)(signed char a0, double d0, unsigned short a1, float f0, int a2, double d1,
    long long a3, float f1, unsigned char a4, double d2, short a5, double d3, unsigned int a6, double d4,
    unsigned long long a7, double d5, int a8, double d6, double d7, double d8, int a9, bool b0, void *p0);

static uint64_t records[64];
static bool recorded[64];
void cbx_record_int(int index, long long value) {
    if (index >= 0 && index < 64) { records[index] = (uint64_t)value; recorded[index] = true; }
}
void cbx_record_bits(int index, unsigned long long bits) {
    if (index >= 0 && index < 64) { records[index] = bits; recorded[index] = true; }
}
void cbx_record_pointer(int index, void *p) {
    if (index >= 0 && index < 64) { records[index] = (uint64_t)(uintptr_t)p; recorded[index] = true; }
}

int cbx_mixed(cbx_mixed_fn f) {
    memset(recorded, 0, sizeof recorded);
    static char object[8];
    uint64_t expected[23] = {
        (uint64_t)(int64_t)-100, 0x7ff4000000000abcull, 65000, 0x7fc00123u, (uint64_t)(int64_t)-2000000000,
        0x8000000000000000ull, (uint64_t)INT64_MIN, 0x00000001u, 200, 0x3ff8000000000000ull, (uint64_t)(int64_t)-30000,
        0xfff0000000000000ull, 4000000000u, 0x0000000000000001ull, UINT64_MAX, 0xfff8000000000456ull, 77,
        0x7fefffffffffffffull, 0x7ff0000000000001ull, 0x4000000000000000ull, 9, 1, (uint64_t)(uintptr_t)(object + 5),
    };
    long long sum = f(-100, double_of(expected[1]), 65000, float_of(0x7fc00123u), -2000000000, double_of(expected[5]),
        INT64_MIN, float_of(0x00000001u), 200, double_of(expected[9]), -30000, double_of(expected[11]), 4000000000u,
        double_of(expected[13]), UINT64_MAX, double_of(expected[15]), 77, double_of(expected[17]), double_of(expected[18]),
        double_of(expected[19]), 9, true, object + 5);
    int wrong = 0;
    for (int i = 0; i < 23; i++) {
        if (!recorded[i] || records[i] != expected[i]) {
            wrong++;
        }
    }
    long long expected_sum = -100 + 65000 + (-2000000000) + 200 + (-30000) + 77 + 9;
    return wrong + (sum != expected_sum ? 100 : 0);
}

/* ------------------------------------------------------------------------
 * Allocation and the collector: byte storage C reads before and after a
 * callback that allocates (and, under GC stress, collects at every
 * allocation); C reports whether the bytes changed. */

typedef long long (*cbx_long_unary)(long long);
int cbx_bytes_around(const unsigned char *data, unsigned long len, cbx_long_unary f, long long x) {
    unsigned long before = 0, after = 0;
    for (unsigned long i = 0; i < len; i++) before = before * 31 + data[i];
    long long r = f(x);
    for (unsigned long i = 0; i < len; i++) after = after * 31 + data[i];
    return (before != after ? 1 : 0) + (r != x * 3 ? 10 : 0);
}

/* ------------------------------------------------------------------------
 * What a callback contract forbids: each ends the process, refused by the
 * runtime before any Botlish code runs. */

/* Called on another thread, while the calling thread waits in this call. */
struct thread_call { cbx_unary f; int x; int result; };
static void *thread_body(void *arg) {
    struct thread_call *call = arg;
    call->result = call->f(call->x);
    return 0;
}
int cbx_call_on_thread(cbx_unary f, int x) {
    struct thread_call call = {f, x, -1};
    pthread_t thread;
    if (pthread_create(&thread, 0, thread_body, &call) != 0) {
        return -2;
    }
    pthread_join(thread, 0);
    return call.result;
}

/* Called on another stack: C switches to a stack of its own (ucontext, on
 * Linux) and calls f there, while the Botlish frames wait on theirs. */
#if defined(__linux__)
#include <ucontext.h>
#include <stdlib.h>
static ucontext_t waiting_context, other_context;
static cbx_unary other_f;
static int other_x, other_result;
static void other_body(void) { other_result = other_f(other_x); }
int cbx_call_on_other_stack(cbx_unary f, int x) {
    size_t size = 1 << 20;
    void *stack = malloc(size);
    if (!stack || getcontext(&other_context) != 0) {
        return -2;
    }
    other_f = f;
    other_x = x;
    other_result = -1;
    other_context.uc_stack.ss_sp = stack;
    other_context.uc_stack.ss_size = size;
    other_context.uc_link = &waiting_context;
    makecontext(&other_context, other_body, 0);
    swapcontext(&waiting_context, &other_context);
    free(stack);
    return other_result;
}
#else
int cbx_call_on_other_stack(cbx_unary f, int x) { (void)f; (void)x; return -3; }
#endif

/* Kept past the call (a `captures` parameter), and called by a later call
 * that has no callback parameter. */
static cbx_unary stored;
void cbx_store(cbx_unary f) { stored = f; }
int cbx_call_stored(int x) { return stored ? stored(x) : -1; }

/* A `_Bool` argument that is no `_Bool` (the C side's own pointer type is
 * unsigned char's), and an address no C address word holds. */
int cbx_bad_bool(int (*f)(unsigned char)) { return f(2); }
int cbx_bad_pointer(int (*f)(void *)) { return f((void *)0x0800000000001000ull); }

/* An address no C address word holds, as a result: a NATIVE ADDRESS
 * failure of the Botlish code that calls this. */
void *cbx_unholdable_address(void) { return (void *)0x0800000000001000ull; }
