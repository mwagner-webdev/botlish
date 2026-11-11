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
 * with the host's C compiler; nothing else links it. On Windows x86-64 that
 * is MSVC's cl, with callback-fixture-win64.asm assembled by ml64 beside it
 * (WINDOWS-X86-64-MILESTONE-9.md): Windows threads and fibers stand for
 * pthreads and ucontext, and the assembly for what cl has no inline
 * assembly for -- a caller with no function table entry, and one that
 * checks every nonvolatile register across the callback. */
#include <stdbool.h>
#include <stdint.h>
#include <string.h>
#ifdef _WIN32
#include <windows.h>
#else
#include <pthread.h>
#endif

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
 * collector never reads a C frame (framewalk::walk_segmented). On Windows
 * x86-64 the call is made by callback-fixture-win64.asm's
 * cbx_win64_call_without_frame, whose frame has no function table entry
 * either: Windows' unwinder takes it for a leaf and finds the return
 * address 0 at its stack pointer, so a walk that unwound C's frames would
 * stop there, short of the waiting Botlish frames. Elsewhere (another
 * architecture) a plain call. */
#if defined(_WIN32) && defined(_M_X64)
extern int cbx_win64_call_without_frame(cbx_unary f, int x);
#endif
static int call_without_frame(cbx_unary f, int x) {
#if defined(_WIN32) && defined(_M_X64)
    return cbx_win64_call_without_frame(f, x);
#elif defined(__x86_64__) && !defined(_WIN32)
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

/* Called on another thread, while the calling thread waits in this call
 * (a pthread; on Windows a thread of CreateThread). */
struct thread_call { cbx_unary f; int x; int result; };
#ifdef _WIN32
static DWORD WINAPI thread_body(LPVOID arg) {
    struct thread_call *call = arg;
    call->result = call->f(call->x);
    return 0;
}
int cbx_call_on_thread(cbx_unary f, int x) {
    struct thread_call call = {f, x, -1};
    HANDLE thread = CreateThread(NULL, 0, thread_body, &call, 0, NULL);
    if (thread == NULL) {
        return -2;
    }
    WaitForSingleObject(thread, INFINITE);
    CloseHandle(thread);
    return call.result;
}
#else
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
#endif

/* Called on another stack: C switches to a stack of its own (ucontext, on
 * Linux; a fiber of its own, on Windows) and calls f there, while the
 * Botlish frames wait on theirs. */
#if defined(_WIN32)
static LPVOID waiting_fiber;
static cbx_unary other_f;
static int other_x, other_result;
static VOID CALLBACK other_body(LPVOID unused) {
    (void)unused;
    other_result = other_f(other_x);
    SwitchToFiber(waiting_fiber);
}
int cbx_call_on_other_stack(cbx_unary f, int x) {
    /* The thread may be a fiber already (the runtime makes it one for its
     * coroutines): switch from the running fiber then, and convert back
     * only a conversion of this function's own. */
    bool converted = false;
    if (IsThreadAFiber()) {
        waiting_fiber = GetCurrentFiber();
    } else {
        waiting_fiber = ConvertThreadToFiber(NULL);
        converted = true;
    }
    if (waiting_fiber == NULL) {
        return -2;
    }
    other_f = f;
    other_x = x;
    other_result = -1;
    LPVOID other = CreateFiber(1 << 20, other_body, NULL);
    if (other == NULL) {
        return -2;
    }
    SwitchToFiber(other);
    DeleteFiber(other);
    if (converted) {
        ConvertFiberToThread();
    }
    return other_result;
}
#elif defined(__linux__)
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

/* ------------------------------------------------------------------------
 * The Win64 ABI by hand (WINDOWS-X86-64-MILESTONE-9.md): a callback of mixed
 * classes -- an int, a double, a float third, an integer fourth (Win64
 * places by position: rcx, xmm1, xmm2, r9), then four on the stack -- that
 * hands its floating arguments back to C (cbx_record_bits, indices 1, 2, 4
 * and 7) and returns the sum of its integer ones. On Windows x86-64 the
 * call is callback-fixture-win64.asm's cbx_win64_abi_call, which places
 * every argument itself, each narrow one with dirty bits above its width,
 * and holds a sentinel in every nonvolatile register across the call;
 * elsewhere a plain C call (the compiler's own placement, no register
 * check). Returns how many answers were wrong: 1 per floating argument
 * that came back changed, 100 for a wrong sum, 1000 when a nonvolatile
 * register was not preserved (which ones: cbx_abi_last_changed). */
typedef long long (*cbx_abi_fn)(int a, double b, float c, long long d, double e, int g, signed char h, double i);
#if defined(_WIN32) && defined(_M_X64)
extern long long cbx_win64_abi_call(cbx_abi_fn f, unsigned long long *changed);
#endif
static unsigned long long abi_changed;
int cbx_abi_preserved(cbx_abi_fn f) {
    memset(recorded, 0, sizeof recorded);
    unsigned long long changed = 0;
#if defined(_WIN32) && defined(_M_X64)
    long long r = cbx_win64_abi_call(f, &changed);
#else
    long long r = f(-5, double_of(0x7ff4000000000abcull), float_of(0x7fa00abcu), 0x123456789ll,
        double_of(0x8000000000000000ull), 77, -3, double_of(0x0000000000000001ull));
#endif
    abi_changed = changed;
    const int indices[4] = {1, 2, 4, 7};
    const uint64_t expected[4] = {0x7ff4000000000abcull, 0x7fa00abcu, 0x8000000000000000ull, 0x0000000000000001ull};
    int wrong = 0;
    for (int k = 0; k < 4; k++) {
        if (!recorded[indices[k]] || records[indices[k]] != expected[k]) {
            wrong++;
        }
    }
    if (r != -5 + 0x123456789ll + 77 - 3) {
        wrong += 100;
    }
    if (changed != 0) {
        wrong += 1000;
    }
    return wrong;
}
unsigned long long cbx_abi_last_changed(void) { return abi_changed; }

/* ------------------------------------------------------------------------
 * Windows' unwinder through a callback (WINDOWS-X86-64-MILESTONE-9.md,
 * "Unwind information"): cbx_trace_outer calls f, a callback that calls
 * cbx_trace_inner with g, a callback that calls cbx_trace_check. From
 * there Windows' unwinder alone -- RtlLookupFunctionEntry, RtlVirtualUnwind,
 * a function without an entry taken for a leaf -- climbs at most 256
 * frames of the thread's stack, and the result says which of the two C
 * functions it crossed: 1 cbx_trace_inner (reached through the callback
 * g's entry point and the runtime's frames), 2 cbx_trace_outer (reached
 * also through the transition shim of cbx_trace_inner's call, f's Botlish
 * frames and its entry point). 3 when every function between has unwind
 * information that describes its frame. Not Windows: 3 (no such unwinder
 * to ask). The two are distinct functions (no identical-code folding). */
int cbx_trace_inner(cbx_unary g, int x) { return g(x) + 11; }
int cbx_trace_outer(cbx_unary f, int x) { return 3 * f(x) + 1; }
#ifdef _WIN32
static DWORD64 function_begin(DWORD64 pc) {
    DWORD64 base = 0;
    PRUNTIME_FUNCTION entry = RtlLookupFunctionEntry(pc, &base, NULL);
    return entry ? base + entry->BeginAddress : 0;
}
int cbx_trace_check(void) {
    CONTEXT context;
    RtlCaptureContext(&context);
    ULONG_PTR low = 0, high = 0;
    GetCurrentThreadStackLimits(&low, &high);
    DWORD64 inner = function_begin((DWORD64)(uintptr_t)&cbx_trace_inner);
    DWORD64 outer = function_begin((DWORD64)(uintptr_t)&cbx_trace_outer);
    int found = 0;
    for (int i = 0; i < 256; i++) {
        if (context.Rip == 0 || context.Rsp < low || context.Rsp + 8 > high) {
            break;
        }
        DWORD64 base = 0;
        PRUNTIME_FUNCTION entry = RtlLookupFunctionEntry(context.Rip, &base, NULL);
        DWORD64 begin = entry ? base + entry->BeginAddress : 0;
        if (begin != 0 && begin == inner) {
            found |= 1;
        }
        if (begin != 0 && begin == outer) {
            found |= 2;
            break;
        }
        if (entry == NULL) {
            context.Rip = *(DWORD64 *)(uintptr_t)context.Rsp;
            context.Rsp += 8;
        } else {
            PVOID handler_data = NULL;
            DWORD64 establisher = 0;
            RtlVirtualUnwind(UNW_FLAG_NHANDLER, base, context.Rip, entry, &context, &handler_data, &establisher, NULL);
        }
    }
    return found;
}
#else
int cbx_trace_check(void) { return 3; }
#endif

/* ------------------------------------------------------------------------
 * A real Windows API that calls back (WINDOWS-X86-64-MILESTONE-9.md):
 * kernel32's EnumSystemLocalesEx calls its LOCALE_ENUMPROCEX for each locale,
 * synchronously, on the calling thread. The Botlish callback has no state
 * of its own: it hands each call's arguments here, and the answer says
 * whether the enumeration goes on (1) or stops (0: after LIMIT calls, when
 * LIMIT is positive). C counts the calls, and the ones whose name was NULL
 * or whose lParam was not the 12345 the program passed. Portable (a name
 * is UTF-16 code units: Windows' wchar_t), so the binding links anywhere. */
static int locale_calls, locale_bad, locale_empty;
void cbx_locale_reset(void) { locale_calls = locale_bad = locale_empty = 0; }
int cbx_locale_note(const unsigned short *name, unsigned long flags, long long param, int limit) {
    (void)flags;
    locale_calls++;
    if (name == NULL || param != 12345) {
        locale_bad++;
    } else if (name[0] == 0) {
        locale_empty++;
    }
    return limit > 0 && locale_calls >= limit ? 0 : 1;
}
int cbx_locale_calls(void) { return locale_calls; }
int cbx_locale_bad(void) { return locale_bad; }
