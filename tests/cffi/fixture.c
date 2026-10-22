/* fixture.c -- the C side of the C FFI tests (C-FFI.md, "Testing").
 *
 * Test infrastructure only: tests/c-ffi.test, audit/c-ffi/tools/ and
 * bench/c-ffi.tcl compile it with the host C compiler (GCC or Clang on
 * Linux, Apple clang on macOS) into a static archive
 * (libbotlish_cffi_fixture.a) in a private directory and link Botlish
 * programs against it with `extern c library "botlish_cffi_fixture"` and
 * -L. Nothing in the compiler, the runtime or the libraries depends on it.
 * Every function is a plain C function of the ABI universe extern c fn
 * supports: integer scalars, C _Bool, data and function pointers, void.
 * The variadic ones (VARIADICS-VERTICAL-SLICE-1.md, at the end) are genuine
 * C variadic functions, reading their trailing arguments with <stdarg.h>.
 *
 * A few functions are assembly, where C cannot observe what the ABI
 * promises (a result register's bits beyond its width, the registers and
 * stack slots an argument arrives in): one text per instruction set, spelled
 * for the object format through BCF_FUNCTION (ELF's bare symbol and `.type`,
 * Mach-O's `_` user label prefix).
 */
#include <errno.h>
#include <stdarg.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <string.h>

/* An assembly function's header: the global symbol NAME, aligned, in the
 * object format's spelling. */
#if defined(__APPLE__)
#define BCF_FUNCTION(name) ".globl _" #name "\n.p2align 2\n_" #name ":\n"
#define BCF_CALL(name) "_" #name
#elif defined(__aarch64__)
#define BCF_FUNCTION(name) ".globl " #name "\n.type " #name ",%function\n.p2align 2\n" #name ":\n"
#define BCF_CALL(name) #name
#endif

/* Scalars: each returns its argument, so a round trip shows the transport
 * (sign or zero extension, width) of both directions. */
signed char bcf_echo_schar(signed char x) { return x; }
unsigned char bcf_echo_uchar(unsigned char x) { return x; }
char bcf_echo_char(char x) { return x; }
short bcf_echo_short(short x) { return x; }
unsigned short bcf_echo_ushort(unsigned short x) { return x; }
int bcf_echo_int(int x) { return x; }
unsigned int bcf_echo_uint(unsigned int x) { return x; }
long bcf_echo_long(long x) { return x; }
unsigned long bcf_echo_ulong(unsigned long x) { return x; }
long long bcf_echo_longlong(long long x) { return x; }
unsigned long long bcf_echo_ulonglong(unsigned long long x) { return x; }

/* Widening inside C: what C sees of a narrow argument. */
long bcf_widen_schar(signed char x) { return x; }
long bcf_widen_uchar(unsigned char x) { return x; }
long bcf_widen_short(short x) { return x; }
long bcf_widen_ushort(unsigned short x) { return x; }
long long bcf_widen_int(int x) { return x; }
long bcf_widen_char(char x) { return x; }
unsigned long long bcf_widen_uint(unsigned int x) { return x; }

int bcf_add(int a, int b) { return a + b; }
long bcf_sub_long(long a, long b) { return a - b; }

/* Ten arguments of mixed classes: past the six (x86-64 SysV) or eight
 * (AAPCS64) integer argument registers, so the last ones are on the stack.
 * Returns a checksum that sees every argument at its own weight. */
long long bcf_many(long a, int b, short c, signed char d, unsigned char e,
                   unsigned short f, unsigned int g, unsigned long h, long i, int j) {
    return (long long)a + 2LL * b + 3LL * c + 5LL * d + 7LL * e + 11LL * f
        + 13LL * (long long)g + 17LL * (long long)h + 19LL * i + 23LL * j;
}

/* The last argument alone, past the registers. */
int bcf_tenth(int a, int b, int c, int d, int e, int f, int g, int h, int i, int j) {
    (void)a; (void)b; (void)c; (void)d; (void)e; (void)f; (void)g; (void)h; (void)i;
    return j;
}

void bcf_nothing(void) {}

/* Pointers. */
static unsigned char bcf_cell[16];
void *bcf_address(void) { return bcf_cell; }
void *bcf_null(void) { return NULL; }
int bcf_is_null(void *p) { return p == NULL; }
void *bcf_echo_ptr(void *p) { return p; }
int bcf_same(void *a, void *b) { return a == b; }
/* A pointer one past P: a result that is *not* its argument, for the alias
 * contract's check. */
unsigned char *bcf_next(unsigned char *p) { return p + 1; }
/* An address no Botlish C pointer word holds (non-canonical on x86-64). */
void *bcf_wild(void) { return (void *)(uintptr_t)0xf000000000000010ull; }

/* Byte storage: read, write, both. */
unsigned long bcf_sum(const unsigned char *data, unsigned long count) {
    unsigned long sum = 0;
    for (unsigned long i = 0; i < count; i++) {
        sum += data[i];
    }
    return sum;
}

void bcf_fill(unsigned char *out, unsigned long count, unsigned char seed) {
    for (unsigned long i = 0; i < count; i++) {
        out[i] = (unsigned char)(seed + 37 * i);
    }
}

/* C error state (C-FFI-ERROR-CAPTURE-MILESTONE-1.md): POSIX's convention, as
 * read(2) has it. Each writes its buffers first, then -- when ERR is not 0 --
 * fails: errno ERR (the standard errno, the calling thread's) and the result
 * -1, the bytes written before the failure left in place. ERR 0 succeeds with
 * the count, leaving errno at STALE when that is not 0 (a successful call may
 * change errno: its value means nothing then). Nothing in Botlish reads errno
 * for them: tests/c-ffi-error-capture.test's binding reads it through
 * __errno_location() (glibc) or __error() (Darwin) and a native view. */
long bcf_fill_errno(unsigned char *out, unsigned long count, unsigned char seed, int err, int stale) {
    bcf_fill(out, count, seed);
    if (err != 0) {
        errno = err;
        return -1;
    }
    if (stale != 0) {
        errno = stale;
    }
    return (long)count;
}

/* Two written buffers: A filled from seed 1, B from seed 2. */
long bcf_fill2_errno(unsigned char *a, unsigned long na, unsigned char *b, unsigned long nb, int err) {
    bcf_fill(a, na, 1);
    bcf_fill(b, nb, 2);
    if (err != 0) {
        errno = err;
        return -1;
    }
    return (long)(na + nb);
}

/* Reads SRC (COUNT bytes), writes them reversed into DST. */
long bcf_reverse_errno(const unsigned char *src, unsigned long count, unsigned char *dst, int err) {
    for (unsigned long i = 0; i < count; i++) {
        dst[i] = src[count - 1 - i];
    }
    if (err != 0) {
        errno = err;
        return -1;
    }
    return (long)count;
}

/* 64-bit results outside Botlish's small-Int range (|v| >= 2^62; C-FFI-
 * ERROR-CAPTURE-MILESTONE-2.md). bcf_large_error is iconv(3)'s convention:
 * failing (FAIL not 0), errno FAIL and (size_t)-1; succeeding, the count 42.
 * bcf_unsigned_errno and bcf_signed_errno return entry WHICH of a table of
 * the small-Int boundary, setting errno to ERR when ERR is not 0 (a failure
 * with that sentinel) and leaving it alone otherwise. */
size_t bcf_large_error(int fail) {
    if (fail != 0) {
        errno = fail;
        return (size_t)-1;
    }
    return 42;
}

/* bcf_fill_errno's shape with a size_t result: OUT filled from SEED, then,
 * when ERR is not 0, errno ERR and (size_t)-1 -- a write-back value whose
 * result is outside the small-Int range. */
size_t bcf_fill_size(unsigned char *out, unsigned long count, unsigned char seed, int err) {
    bcf_fill(out, count, seed);
    if (err != 0) {
        errno = err;
        return (size_t)-1;
    }
    return count;
}

static const uint64_t bcf_unsigned_words[] = {
    0, 5, 4611686018427387903u /* 2^62 - 1, the largest small Int */,
    4611686018427387904u /* 2^62 */, 9223372036854775808u /* 2^63 */,
    18446744073709551614u, 18446744073709551615u /* the largest 64-bit word */,
};

unsigned long bcf_unsigned_errno(int which, int err) {
    if (err != 0) {
        errno = err;
    }
    return (unsigned long)bcf_unsigned_words[which];
}

static const int64_t bcf_signed_words[] = {
    0, -1, 4611686018427387903 /* 2^62 - 1 */, 4611686018427387904 /* 2^62 */,
    INT64_MAX, -4611686018427387904 /* -2^62, the smallest small Int */,
    -4611686018427387904 - 1 /* -2^62 - 1 */, INT64_MIN,
};

long bcf_signed_errno(int which, int err) {
    if (err != 0) {
        errno = err;
    }
    return (long)bcf_signed_words[which];
}

/* A counter, 1, 2, 3, ... on successive calls: how often and in what order
 * a call's arguments are evaluated. */
static unsigned char bcf_ticks;
unsigned char bcf_tick(void) { return ++bcf_ticks; }

/* SHA256's shape: reads DATA, writes OUT, returns OUT. */
unsigned char *bcf_reverse(const unsigned char *data, unsigned long count, unsigned char *out) {
    for (unsigned long i = 0; i < count; i++) {
        out[i] = data[count - 1 - i];
    }
    return out;
}

/* The same, returning one byte past OUT (a false `alias out` contract). */
unsigned char *bcf_reverse_off(const unsigned char *data, unsigned long count, unsigned char *out) {
    bcf_reverse(data, count, out);
    return out + 1;
}

/* A pointer result inside its argument (memchr's shape). */
const unsigned char *bcf_find(const unsigned char *data, unsigned long count, unsigned char byte) {
    const void *found = memchr(data, byte, count);
    return found;
}

/* Retains its argument: a capturing contract (direct authority). */
static void *bcf_kept;
void bcf_keep(void *p) { bcf_kept = p; }
void *bcf_kept_pointer(void) { return bcf_kept; }

/* Function pointers: one is only passed and returned (Botlish never calls
 * one). */
typedef int (*bcf_callback)(int);
static int bcf_twice(int x) { return 2 * x; }
bcf_callback bcf_callback_twice(void) { return bcf_twice; }
int bcf_apply(bcf_callback f, int x) { return f(x); }

/* Narrow results with dirty upper register bits: the ABI leaves the bits of
 * a char or short result beyond its width unspecified, and GCC leaves them,
 * so a caller must extend the result itself. These return 0x80 (as unsigned
 * char), -128 (as signed char), 0x8000 and -32768 with every higher bit of
 * the result register set the other way. */
#if defined(__x86_64__) && !defined(__APPLE__)
__asm__(
    ".text\n"
    ".globl bcf_dirty_uchar\n.type bcf_dirty_uchar,@function\nbcf_dirty_uchar:\n"
    "    movabsq $0x5555555555555580, %rax\n    ret\n"
    ".globl bcf_dirty_schar\n.type bcf_dirty_schar,@function\nbcf_dirty_schar:\n"
    "    movabsq $0x5555555555555580, %rax\n    ret\n"
    ".globl bcf_dirty_ushort\n.type bcf_dirty_ushort,@function\nbcf_dirty_ushort:\n"
    "    movabsq $0x5555555555558000, %rax\n    ret\n"
    ".globl bcf_dirty_short\n.type bcf_dirty_short,@function\nbcf_dirty_short:\n"
    "    movabsq $0x5555555555558000, %rax\n    ret\n"
    ".globl bcf_dirty_uint\n.type bcf_dirty_uint,@function\nbcf_dirty_uint:\n"
    "    movabsq $0x55555555fffffff0, %rax\n    ret\n"
    ".globl bcf_dirty_int\n.type bcf_dirty_int,@function\nbcf_dirty_int:\n"
    "    movabsq $0x55555555fffffff0, %rax\n    ret\n");
#elif defined(__aarch64__)
__asm__(
    ".text\n"
    BCF_FUNCTION(bcf_dirty_uchar)
    "    movz x0, #0x5580\n    movk x0, #0x5555, lsl #16\n    movk x0, #0x5555, lsl #32\n    movk x0, #0x5555, lsl #48\n    ret\n"
    BCF_FUNCTION(bcf_dirty_schar)
    "    movz x0, #0x5580\n    movk x0, #0x5555, lsl #16\n    movk x0, #0x5555, lsl #32\n    movk x0, #0x5555, lsl #48\n    ret\n"
    BCF_FUNCTION(bcf_dirty_ushort)
    "    movz x0, #0x8000\n    movk x0, #0x5555, lsl #16\n    movk x0, #0x5555, lsl #32\n    movk x0, #0x5555, lsl #48\n    ret\n"
    BCF_FUNCTION(bcf_dirty_short)
    "    movz x0, #0x8000\n    movk x0, #0x5555, lsl #16\n    movk x0, #0x5555, lsl #32\n    movk x0, #0x5555, lsl #48\n    ret\n"
    BCF_FUNCTION(bcf_dirty_uint)
    "    movz x0, #0xfff0\n    movk x0, #0xffff, lsl #16\n    movk x0, #0x5555, lsl #32\n    movk x0, #0x5555, lsl #48\n    ret\n"
    BCF_FUNCTION(bcf_dirty_int)
    "    movz x0, #0xfff0\n    movk x0, #0xffff, lsl #16\n    movk x0, #0x5555, lsl #32\n    movk x0, #0x5555, lsl #48\n    ret\n");
#endif

/* C _Bool (ffi::c::Bool, C-BINDGEN.md "C bool"): round trips, what C
 * sees, and the transport's corners. */
bool bcf_echo_bool(bool x) { return x; }
bool bcf_bool_false(void) { return false; }
bool bcf_bool_true(void) { return true; }
int bcf_observe_bool(bool x) { return x ? 1 : 0; }
bool bcf_not(bool x) { return !x; }
bool bcf_is_positive(int x) { return x > 0; }
int bcf_bool_args(bool a, int b, bool c) { return (a ? 100 : 0) + b + (c ? 1 : 0); }
/* Ten arguments, the bools last: on the stack on both targets. */
int bcf_bool_stack(long a, long b, long c, long d, long e, long f, long g, long h, bool i, bool j) {
    (void)a; (void)b; (void)c; (void)d; (void)e; (void)f; (void)g; (void)h;
    return (i ? 2 : 0) + (j ? 1 : 0);
}
/* A pointer to _Bool is only passed through. */
bool *bcf_echo_bool_ptr(bool *p) { return p; }
typedef bool (*bcf_predicate)(int);
static bool bcf_odd(int x) { return x % 2 != 0; }
bcf_predicate bcf_predicate_odd(void) { return bcf_odd; }

/* The register a _Bool argument arrives in, all 32 low bits of it (the
 * platform ABIs have the caller zero-extend it as an unsigned char), and
 * _Bool results with dirty bits above the byte (valid: the bits are
 * unspecified) or a byte that is no _Bool (2: the call must fail). */
#if defined(__x86_64__) && !defined(__APPLE__)
__asm__(
    ".text\n"
    ".globl bcf_bool_register\n.type bcf_bool_register,@function\nbcf_bool_register:\n"
    "    movl %edi, %eax\n    ret\n"
    ".globl bcf_dirty_bool_true\n.type bcf_dirty_bool_true,@function\nbcf_dirty_bool_true:\n"
    "    movabsq $0x5555555555555501, %rax\n    ret\n"
    ".globl bcf_dirty_bool_false\n.type bcf_dirty_bool_false,@function\nbcf_dirty_bool_false:\n"
    "    movabsq $0x5555555555555500, %rax\n    ret\n"
    ".globl bcf_invalid_bool\n.type bcf_invalid_bool,@function\nbcf_invalid_bool:\n"
    "    movl $2, %eax\n    ret\n");
#elif defined(__aarch64__)
__asm__(
    ".text\n"
    BCF_FUNCTION(bcf_bool_register)
    "    mov w0, w0\n    ret\n"
    BCF_FUNCTION(bcf_dirty_bool_true)
    "    movz x0, #0x5501\n    movk x0, #0x5555, lsl #16\n    movk x0, #0x5555, lsl #32\n    movk x0, #0x5555, lsl #48\n    ret\n"
    BCF_FUNCTION(bcf_dirty_bool_false)
    "    movz x0, #0x5500\n    movk x0, #0x5555, lsl #16\n    movk x0, #0x5555, lsl #32\n    movk x0, #0x5555, lsl #48\n    ret\n"
    BCF_FUNCTION(bcf_invalid_bool)
    "    mov w0, #2\n    ret\n");
#endif

/* Counts its own calls: the performance benchmark's per-call work. */
static unsigned long bcf_calls;
unsigned long bcf_count(void) { return ++bcf_calls; }

/* ---------------------------------------------------------------------------
 * The Apple AArch64 milestone's ABI evidence (MACOS-AARCH64-MILESTONE-6.md):
 * every C scalar in registers and on the stack, read back by C compiled by
 * the platform's own compiler, and the raw machine state a call arrives
 * in. */

/* What a call of bcf_capture arrived in: the integer argument registers
 * (x0-x7 on AArch64; rdi, rsi, rdx, rcx, r8, r9 on x86-64), all 64 bits of
 * each, and the first 128 bytes at the stack pointer the caller left, where
 * its stack-passed arguments start. bcf_capture is assembly (below): it
 * saves the registers before any compiled code can touch them and hands
 * them to bcf_capture_record, which keeps them here. Declared with any
 * signature (each Botlish binding gives it one), it reads the arguments of
 * that signature without interpreting them, and returns 0. */
static unsigned long long bcf_regs[8];
static unsigned char bcf_stack[128];
static unsigned long long bcf_ref_regs[8];
static unsigned char bcf_ref_stack[128];

int bcf_capture_record(const unsigned long long *regs, const unsigned char *stack, int count) {
    for (int i = 0; i < 8; i++) {
        bcf_regs[i] = i < count ? regs[i] : 0;
    }
    memcpy(bcf_stack, stack, sizeof bcf_stack);
    return 0;
}

int bcf_capture(void);

#if defined(__x86_64__) && !defined(__APPLE__)
__asm__(
    ".text\n"
    ".globl bcf_capture\n.type bcf_capture,@function\nbcf_capture:\n"
    "    pushq %rbp\n    movq %rsp, %rbp\n    subq $48, %rsp\n"
    "    movq %rdi, 0(%rsp)\n    movq %rsi, 8(%rsp)\n    movq %rdx, 16(%rsp)\n"
    "    movq %rcx, 24(%rsp)\n    movq %r8, 32(%rsp)\n    movq %r9, 40(%rsp)\n"
    "    movq %rsp, %rdi\n    leaq 16(%rbp), %rsi\n    movl $6, %edx\n"
    "    call bcf_capture_record@PLT\n"
    "    leave\n    ret\n");
#elif defined(__aarch64__)
__asm__(
    ".text\n"
    BCF_FUNCTION(bcf_capture)
    "    stp x29, x30, [sp, #-80]!\n    mov x29, sp\n"
    "    stp x0, x1, [sp, #16]\n    stp x2, x3, [sp, #32]\n"
    "    stp x4, x5, [sp, #48]\n    stp x6, x7, [sp, #64]\n"
    "    add x0, sp, #16\n    add x1, sp, #80\n    mov w2, #8\n"
    "    bl " BCF_CALL(bcf_capture_record) "\n"
    "    ldp x29, x30, [sp], #80\n    ret\n");
#endif

/* The last capture: register I's 64 bits and its low 32, stack byte I. */
unsigned long long bcf_captured_register(int i) { return bcf_regs[i & 7]; }
unsigned int bcf_captured_register32(int i) { return (unsigned int)bcf_regs[i & 7]; }
unsigned char bcf_captured_stack_byte(int i) { return bcf_stack[i & 127]; }

/* The same, of the reference call bcf_reference_* made: the call this C
 * compiler makes of bcf_capture with the same prototype and values as a
 * Botlish binding's, its own answer to where each argument goes. */
unsigned int bcf_reference_register32(int i) { return (unsigned int)bcf_ref_regs[i & 7]; }
unsigned long long bcf_reference_register(int i) { return bcf_ref_regs[i & 7]; }
unsigned char bcf_reference_stack_byte(int i) { return bcf_ref_stack[i & 127]; }

static void bcf_keep_reference(void) {
    memcpy(bcf_ref_regs, bcf_regs, sizeof bcf_regs);
    memcpy(bcf_ref_stack, bcf_stack, sizeof bcf_stack);
}

/* The registers, all narrow: one of every narrow class, C _Bool and plain
 * char, the values those of c-ffi.test's cf-abi-register-extension.
 * Exactly the eight argument registers of AArch64, the last (x7) a char
 * (x86-64 passes the last two on the stack). */
typedef int (*bcf_narrow8_fn)(signed char, unsigned char, short, unsigned short, int, unsigned int, bool, char);

int bcf_reference_narrow8(void) {
    volatile bcf_narrow8_fn f = (bcf_narrow8_fn)bcf_capture;
    int r = f(-2, 253, -1234, 65244, -123456789, 4275878552u, true, (char)-3);
    bcf_keep_reference();
    return r;
}

/* Eight doubles, then the eight narrow integers of bcf_reference_narrow8:
 * the doubles take the floating-point registers (v0-v7, xmm0-xmm7), so
 * the integers arrive exactly where they do without them -- the integer
 * registers are counted apart from the doubles. */
typedef int (*bcf_d8n8_fn)(double, double, double, double, double, double, double, double,
                           signed char, unsigned char, short, unsigned short, int, unsigned int, bool, char);

int bcf_reference_d8n8(void) {
    volatile bcf_d8n8_fn f = (bcf_d8n8_fn)bcf_capture;
    int r = f(0.5, 1.5, 2.5, 3.5, 4.5, 5.5, 6.5, 7.5,
              -2, 253, -1234, 65244, -123456789, 4275878552u, true, (char)-3);
    bcf_keep_reference();
    return r;
}

/* Twenty parameters: a selector, seven narrow register arguments and
 * twelve stack arguments of mixed width and signedness -- adjacent narrow
 * ones, a 64-bit one after narrow ones, narrow ones after it. Apple packs
 * them at their natural size and alignment (bytes 0, 1, 2, 4, 6, 8, 12,
 * 16, 24, 26, 28, 32); AAPCS64 and SysV give each its own 8-byte slot. */
#define BCF_PICK_PARAMS int which, signed char a1, unsigned char a2, short a3, \
    unsigned short a4, int a5, unsigned int a6, char a7, signed char s8, \
    unsigned char s9, short s10, signed char s11, unsigned short s12, int s13, \
    signed char s14, long s15, unsigned char s16, short s17, unsigned int s18, \
    signed char s19

/* Argument WHICH (1-19) as C received it, read by this compiler's code for
 * this prototype: what a callee makes of each argument's location and
 * extension. */
long long bcf_pick(BCF_PICK_PARAMS) {
    switch (which) {
    case 1: return a1;
    case 2: return a2;
    case 3: return a3;
    case 4: return a4;
    case 5: return a5;
    case 6: return a6;
    case 7: return a7;
    case 8: return s8;
    case 9: return s9;
    case 10: return s10;
    case 11: return s11;
    case 12: return s12;
    case 13: return s13;
    case 14: return s14;
    case 15: return s15;
    case 16: return s16;
    case 17: return s17;
    case 18: return s18;
    case 19: return s19;
    default: return -999;
    }
}

typedef int (*bcf_pick_fn)(BCF_PICK_PARAMS);

int bcf_reference_pick(void) {
    volatile bcf_pick_fn f = (bcf_pick_fn)bcf_capture;
    int r = f(0, -2, 253, -1234, 65244, -123456789, 4275878552u, (char)-3,
              -4, 247, -30000, -128, 48879, -2000000000, 127, -81985529216486895L,
              128, -2, 2147483649u, -1);
    bcf_keep_reference();
    return r;
}

/* One stack argument past eight register ones: a signed char at the start
 * of the stack area. */
int bcf_ninth(long a, long b, long c, long d, long e, long f, long g, long h, signed char i) {
    (void)a; (void)b; (void)c; (void)d; (void)e; (void)f; (void)g; (void)h;
    return i;
}

/* Stack arguments ending two bytes short of a 16-byte boundary: a long at
 * 0, an int at 8, a short at 12 and a signed char at 14 under Apple's
 * packing. The arguments are checked here; what matters as much is that
 * the caller wrote nothing past them (cf-abi-stack-tail-frame). */
long long bcf_stack_tail(long a, long b, long c, long d, long e, long f, long g, long h,
                         long i, int j, short k, signed char l) {
    return a + 2 * b + 3 * c + 4 * d + 5 * e + 6 * f + 7 * g + 8 * h
        + 9 * i + 10LL * j + 11LL * k + 12LL * l;
}

/* Pointers among integers, in registers and on the stack: a bit per
 * argument that is exactly what cf-abi-pointer-mix passes, 0xfff for all. */
static unsigned char bcf_cell2[16];
void *bcf_address2(void) { return bcf_cell2; }
/* Addresses never dereferenced: the top of the 47-bit user space and an
 * address with every high bit set, which a C pointer word holds as its
 * sign-extended 60 bits. */
void *bcf_user_top(void) { return (void *)(uintptr_t)0x00007ffffffffff0ull; }
void *bcf_high_address(void) { return (void *)(uintptr_t)0xfffffffffffffff0ull; }
int bcf_needs_64_bits(void *p) { return ((uintptr_t)p >> 32) != 0; }

int bcf_pointer_mix(void *a, signed char b, void *c, unsigned short d, long e, void *f, int g,
                    void *h, void *s0, signed char s1, void *s2, short s3) {
    int mask = 0;
    mask |= (a == (void *)bcf_cell) << 0;
    mask |= (b == -5) << 1;
    mask |= (c == NULL) << 2;
    mask |= (d == 65000) << 3;
    mask |= (e == -1234567890123L) << 4;
    mask |= (f == (void *)bcf_cell2) << 5;
    mask |= (g == -7) << 6;
    mask |= (h == bcf_high_address()) << 7;
    mask |= (s0 == (void *)bcf_cell) << 8;
    mask |= (s1 == -128) << 9;
    mask |= (s2 == bcf_user_top()) << 10;
    mask |= (s3 == -32768) << 11;
    return mask;
}

/* A C function's own sentinel: -1 for a zero divisor, the quotient
 * otherwise. Botlish interprets it; nothing translates it. */
int bcf_checked_div(int a, int b) { return b == 0 ? -1 : a / b; }

/* C recursion as deep as N, returning N: each frame keeps a volatile
 * buffer it reads after the recursive call (so the call is no tail call),
 * and a large N exhausts the stack it runs on (the native worker thread's
 * or a coroutine's) inside C. */
__attribute__((noinline)) long bcf_deep(long n) {
    volatile unsigned char pad[256];
    pad[0] = (unsigned char)n;
    if (n <= 0) {
        return 0;
    }
    return bcf_deep(n - 1) + (pad[0] == (unsigned char)n);
}

#if defined(__APPLE__)
/* A run-time OS version check, which clang compiles to a call of
 * `__isPlatformVersionAtLeast`: defined by clang's compiler runtime
 * (libclang_rt.osx.a, not libSystem) and by Rust's standard library, which
 * the link reaches first. macOS 99 is no version a runner has: 0. */
int bcf_available(void) {
    if (__builtin_available(macOS 99, *)) {
        return 1;
    }
    return 0;
}
#endif

/* ---------------------------------------------------------------------------
 * Byte borrowing through real C (tests/c-byte-borrowing.test,
 * MACOS-AARCH64-MILESTONE-7.md): what C reads and writes through a
 * temporary exposure of Botlish byte storage, and the address it is given. */

/* Two sums of DATA's COUNT bytes in one word: the plain sum (low 32 bits)
 * and the position-weighted sum of (i + 1) * byte i (high 32 bits), each
 * mod 2^32 -- a byte read wrong, skipped, read twice or out of order
 * changes it. */
unsigned long long bcf_checksum(const unsigned char *data, unsigned long count) {
    uint32_t plain = 0, weighted = 0;
    for (unsigned long i = 0; i < count; i++) {
        plain += data[i];
        weighted += (uint32_t)(i + 1) * data[i];
    }
    return ((unsigned long long)weighted << 32) | plain;
}

/* The address C was given, as an integer: never dereferenced. */
unsigned long long bcf_address_of(const void *p) { return (unsigned long long)(uintptr_t)p; }

/* BYTE at offsets [FROM, TO) of OUT; every other byte as it was. */
void bcf_fill_range(unsigned char *out, unsigned long from, unsigned long to, unsigned char byte) {
    for (unsigned long i = from; i < to; i++) {
        out[i] = byte;
    }
}

/* Two outputs of one call: A gets DATA's COUNT bytes, B their complements. */
void bcf_split(const unsigned char *data, unsigned long count, unsigned char *a, unsigned char *b) {
    for (unsigned long i = 0; i < count; i++) {
        a[i] = data[i];
        b[i] = (unsigned char)~data[i];
    }
}

/* A C failure sentinel after a partial write: bcf_fill's pattern into the
 * first min(COUNT, LIMIT) bytes of OUT, then -1 when COUNT exceeds LIMIT
 * (some bytes written, the request refused), else COUNT. */
long bcf_fill_upto(unsigned char *out, unsigned long count, unsigned long limit, unsigned char seed) {
    unsigned long n = count < limit ? count : limit;
    bcf_fill(out, n, seed);
    return count > limit ? -1 : (long)count;
}

/* ---------------------------------------------------------------------------
 * Variadic C functions (VARIADICS-VERTICAL-SLICE-1.md): genuine variadic
 * callees, compiled by the host's own C compiler, reading every trailing
 * argument with va_arg as the type their fixed arguments say -- the
 * semantic oracle of a variadic call -- and the machine state a variadic
 * call arrives in, beside this compiler's own variadic calls of the same
 * prototype with the same values. */

/* What bcf_vrecord last read: each trailing argument's bits (an integer
 * sign- or zero-extended to 64 bits by its type, a double's IEEE bits, a
 * pointer's address). */
#define BCF_VMAX 32
static unsigned long long bcf_vseen[BCF_VMAX];

/* Reads COUNT (at most 32) trailing arguments, argument I of the type whose
 * 4-bit code is nibble I of KINDS (I < 16) or of KINDS2 (I >= 16), low
 * nibble first: 1 int, 2 unsigned int, 3 long, 4 unsigned long, 5 long
 * long, 6 unsigned long long, 7 double, 8 void *. Every type is one a
 * default argument promotion makes: a char, short or _Bool argument is read
 * as the int it was promoted to. Returns COUNT, or -1 for a code it does not
 * know (it stops reading there). */
int bcf_vrecord(int count, unsigned long long kinds, unsigned long long kinds2, ...) {
    va_list ap;
    va_start(ap, kinds2);
    for (int i = 0; i < count && i < BCF_VMAX; i++) {
        unsigned code = (unsigned)((i < 16 ? kinds >> (4 * i) : kinds2 >> (4 * (i - 16))) & 15);
        unsigned long long bits;
        switch (code) {
        case 1: bits = (unsigned long long)(long long)va_arg(ap, int); break;
        case 2: bits = va_arg(ap, unsigned int); break;
        case 3: bits = (unsigned long long)(long long)va_arg(ap, long); break;
        case 4: bits = va_arg(ap, unsigned long); break;
        case 5: bits = (unsigned long long)va_arg(ap, long long); break;
        case 6: bits = va_arg(ap, unsigned long long); break;
        case 7: {
            double d = va_arg(ap, double);
            memcpy(&bits, &d, sizeof bits);
            break;
        }
        case 8: bits = (unsigned long long)(uintptr_t)va_arg(ap, void *); break;
        default:
            va_end(ap);
            return -1;
        }
        bcf_vseen[i] = bits;
    }
    va_end(ap);
    return count;
}

/* Trailing argument I of the last bcf_vrecord call, as its 64 bits. */
unsigned long long bcf_vseen_bits(int i) { return bcf_vseen[i & (BCF_VMAX - 1)]; }

/* The sum of COUNT trailing ints: none, one, more than the argument
 * registers hold. */
long long bcf_vsum(int count, ...) {
    va_list ap;
    va_start(ap, count);
    long long sum = 0;
    for (int i = 0; i < count; i++) {
        sum += va_arg(ap, int);
    }
    va_end(ap);
    return sum;
}

/* FACTOR times the sum of COUNT trailing doubles: a fixed double before the
 * variadic boundary, then doubles past the floating-point registers. */
double bcf_vscale(double factor, int count, ...) {
    va_list ap;
    va_start(ap, count);
    double sum = 0.0;
    for (int i = 0; i < count; i++) {
        sum += va_arg(ap, double);
    }
    va_end(ap);
    return factor * sum;
}

/* The trailing pointers up to the first null one, a sentinel-terminated
 * list as real C APIs take (Tcl_AppendResult's interp, ..., NULL): how many
 * there are before it; each is kept for bcf_vseen_bits (at most 32). */
int bcf_vsentinel(int tag, ...) {
    va_list ap;
    va_start(ap, tag);
    int n = 0;
    for (;;) {
        void *p = va_arg(ap, void *);
        if (p == NULL) {
            break;
        }
        if (n < BCF_VMAX) {
            bcf_vseen[n] = (unsigned long long)(uintptr_t)p;
        }
        n++;
    }
    va_end(ap);
    return n;
}

/* A second static cell, whose address a sentinel list can pass, and its
 * address as a number (what a capture of it shows). */
static unsigned char bcf_vcell[8];
void *bcf_vaddress(void) { return bcf_vcell; }
unsigned long long bcf_vaddress_bits(void) { return (unsigned long long)(uintptr_t)bcf_vcell; }

/* What a call of bcf_vcapture (or its alias bcf_vcapture_d) arrived in: the
 * eight integer argument registers (x0-x7; on x86-64 rdi, rsi, rdx, rcx, r8,
 * r9, then two zeros), %rax (x86-64, where a variadic call's %al states how
 * many vector registers it uses; 0 on AArch64), the low 64 bits of the
 * eight floating-point argument registers (v0-v7, xmm0-xmm7) and the first
 * 256 bytes of the caller's stack arguments (Apple's convention puts every
 * trailing argument there: the mixed scenario's eighteen take 144). Assembly
 * saves them before any compiled code can touch them; declared with any
 * prototype, it returns 0. */
static unsigned long long bcf_vregs[8], bcf_vfregs[8], bcf_vrax;
static unsigned char bcf_vstack[256];
static unsigned long long bcf_vref_regs[8], bcf_vref_fregs[8], bcf_vref_rax;
static unsigned char bcf_vref_stack[256];

/* REGS: eight integer registers, %rax, eight floating-point registers. */
int bcf_vcapture_record(const unsigned long long *regs, const unsigned char *stack) {
    memcpy(bcf_vregs, regs, sizeof bcf_vregs);
    bcf_vrax = regs[8];
    memcpy(bcf_vfregs, regs + 9, sizeof bcf_vfregs);
    memcpy(bcf_vstack, stack, sizeof bcf_vstack);
    return 0;
}

int bcf_vcapture(int n, ...);
int bcf_vcapture_d(double x, int n, ...);

#if defined(__x86_64__) && !defined(__APPLE__)
__asm__(
    ".text\n"
    ".globl bcf_vcapture\n.type bcf_vcapture,@function\n"
    ".globl bcf_vcapture_d\n.type bcf_vcapture_d,@function\n"
    "bcf_vcapture:\nbcf_vcapture_d:\n"
    "    pushq %rbp\n    movq %rsp, %rbp\n    subq $144, %rsp\n"
    "    movq %rdi, 0(%rsp)\n    movq %rsi, 8(%rsp)\n    movq %rdx, 16(%rsp)\n"
    "    movq %rcx, 24(%rsp)\n    movq %r8, 32(%rsp)\n    movq %r9, 40(%rsp)\n"
    "    movq $0, 48(%rsp)\n    movq $0, 56(%rsp)\n    movq %rax, 64(%rsp)\n"
    "    movsd %xmm0, 72(%rsp)\n    movsd %xmm1, 80(%rsp)\n    movsd %xmm2, 88(%rsp)\n"
    "    movsd %xmm3, 96(%rsp)\n    movsd %xmm4, 104(%rsp)\n    movsd %xmm5, 112(%rsp)\n"
    "    movsd %xmm6, 120(%rsp)\n    movsd %xmm7, 128(%rsp)\n"
    "    movq %rsp, %rdi\n    leaq 16(%rbp), %rsi\n"
    "    call bcf_vcapture_record@PLT\n"
    "    leave\n    ret\n");
#elif defined(__aarch64__)
__asm__(
    ".text\n"
    BCF_FUNCTION(bcf_vcapture)
    BCF_FUNCTION(bcf_vcapture_d)
    "    stp x29, x30, [sp, #-160]!\n    mov x29, sp\n"
    "    stp x0, x1, [sp, #16]\n    stp x2, x3, [sp, #32]\n"
    "    stp x4, x5, [sp, #48]\n    stp x6, x7, [sp, #64]\n"
    "    str xzr, [sp, #80]\n"
    "    stp d0, d1, [sp, #88]\n    stp d2, d3, [sp, #104]\n"
    "    stp d4, d5, [sp, #120]\n    stp d6, d7, [sp, #136]\n"
    "    add x0, sp, #16\n    add x1, sp, #160\n"
    "    bl " BCF_CALL(bcf_vcapture_record) "\n"
    "    ldp x29, x30, [sp], #160\n    ret\n");
#endif

/* The last capture, and the reference call's: integer register I, the low
 * 8 bits of %rax (%al), floating-point register I's 64 bits, stack byte I. */
unsigned long long bcf_vcaptured_register(int i) { return bcf_vregs[i & 7]; }
unsigned int bcf_vcaptured_al(void) { return (unsigned int)(bcf_vrax & 0xff); }
unsigned long long bcf_vcaptured_float(int i) { return bcf_vfregs[i & 7]; }
unsigned char bcf_vcaptured_stack_byte(int i) { return bcf_vstack[i & 255]; }
unsigned long long bcf_vreference_register(int i) { return bcf_vref_regs[i & 7]; }
unsigned int bcf_vreference_al(void) { return (unsigned int)(bcf_vref_rax & 0xff); }
unsigned long long bcf_vreference_float(int i) { return bcf_vref_fregs[i & 7]; }
unsigned char bcf_vreference_stack_byte(int i) { return bcf_vref_stack[i & 255]; }

static void bcf_vkeep_reference(void) {
    memcpy(bcf_vref_regs, bcf_vregs, sizeof bcf_vregs);
    memcpy(bcf_vref_fregs, bcf_vfregs, sizeof bcf_vfregs);
    bcf_vref_rax = bcf_vrax;
    memcpy(bcf_vref_stack, bcf_vstack, sizeof bcf_vstack);
}

/* This compiler's own variadic calls of the capture, through a volatile
 * pointer of the variadic prototype (so the call is a variadic call the
 * compiler lowers itself), with c-ffi.test's cf-va-abi-* values:
 *
 *   none     n = 0 and no trailing argument
 *   small    two trailing arguments, an int and a double: every register
 *            free (Apple: still on the stack)
 *   ints     twelve ints: past the integer registers everywhere
 *   mixed    ints, longs, pointers and doubles interleaved, ten doubles
 *            (past the floating-point registers) and eight integers
 *   fixedd   bcf_vcapture_d: a fixed double and a fixed int, then doubles
 *            and ints */
typedef int (*bcf_vcapture_fn)(int, ...);
typedef int (*bcf_vcapture_d_fn)(double, int, ...);

int bcf_vreference_none(void) {
    volatile bcf_vcapture_fn f = bcf_vcapture;
    int r = f(0);
    bcf_vkeep_reference();
    return r;
}

int bcf_vreference_small(void) {
    volatile bcf_vcapture_fn f = bcf_vcapture;
    int r = f(2, -5, 2.5);
    bcf_vkeep_reference();
    return r;
}

int bcf_vreference_ints(void) {
    volatile bcf_vcapture_fn f = bcf_vcapture;
    int r = f(12, -1, 2, -3, 4, -5, 6, -7, 8, -9, 10, -11, 2147483647);
    bcf_vkeep_reference();
    return r;
}

int bcf_vreference_mixed(void) {
    volatile bcf_vcapture_fn f = bcf_vcapture;
    int r = f(18, 7, 0.5, -9000000000L, 1.25, (void *)bcf_vcell, -2.0, 4000000000u, 3.5,
              -1, 4.75, 18446744073709551615ULL, 5.0, (void *)0, 6.125, 42, 7.5, 8.25, 9.0);
    bcf_vkeep_reference();
    return r;
}

int bcf_vreference_fixedd(void) {
    volatile bcf_vcapture_d_fn f = bcf_vcapture_d;
    int r = f(0.75, 3, 1.5, -6, 2.5);
    bcf_vkeep_reference();
    return r;
}
