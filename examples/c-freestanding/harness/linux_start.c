/*
 * linux_start.c -- a freestanding startup harness for Linux
 * (C-COMPILE-FREESTANDING-MILESTONE-1.md, "Freestanding and toolchain
 * validation"). It replaces the C library's startup: the process begins at
 * _start, runs the generated program, writes "value: TEXT" or
 * "error: MESSAGE (CODE)" to standard output through the write system
 * call, and exits through the exit system call. Its one target-specific
 * part is the system call (inline assembly per architecture: x86-64,
 * AArch64, RISC-V 64, s390x, 32-bit ARM, i386); it also supplies the four
 * memory functions
 * the C toolchain itself requires of a freestanding environment. The
 * generated program contains neither.
 *
 *     cc -std=c11 -ffreestanding -nostdlib -static -fno-stack-protector \
 *        -DBOTLISH_PROGRAM=PREFIX -DBOTLISH_PROGRAM_HEADER='"PREFIX.h"' \
 *        -I OUT linux_start.c OUT/PREFIX.c OUT/PREFIX_display.c
 *
 * (a cross build: clang --target=aarch64-linux-gnu -fuse-ld=lld ...)
 */
#include BOTLISH_PROGRAM_HEADER

#define BOTLISH_CAT2(a, b) a##b
#define BOTLISH_CAT(a, b) BOTLISH_CAT2(a, b)
#define P(name) BOTLISH_CAT(BOTLISH_PROGRAM, name)

#ifndef START_BUFFER
#define START_BUFFER 65536
#endif

static char text[START_BUFFER];

/*
 * memcpy, memmove, memset and memcmp: GCC and Clang document that a
 * freestanding environment must provide these four, because they may emit
 * calls of them for any code (a struct copy, a zero-initialized object),
 * whatever the source calls. They are the toolchain's obligation, not
 * Botlish's: the generated program never calls them itself. The volatile
 * accesses keep a compiler from recognizing the loops as calls of the very
 * functions they define.
 */
void *memcpy(void *restrict to, const void *restrict from, size_t n);
void *memmove(void *to, const void *from, size_t n);
void *memset(void *to, int value, size_t n);
int memcmp(const void *a, const void *b, size_t n);

void *memcpy(void *restrict to, const void *restrict from, size_t n)
{
    volatile unsigned char *d = to;
    const unsigned char *s = from;
    while (n-- > 0) {
        *d++ = *s++;
    }
    return to;
}

void *memmove(void *to, const void *from, size_t n)
{
    volatile unsigned char *d = to;
    const unsigned char *s = from;
    if (d < s) {
        while (n-- > 0) {
            *d++ = *s++;
        }
    } else {
        while (n > 0) {
            n--;
            d[n] = s[n];
        }
    }
    return to;
}

void *memset(void *to, int value, size_t n)
{
    volatile unsigned char *d = to;
    while (n-- > 0) {
        *d++ = (unsigned char)value;
    }
    return to;
}

int memcmp(const void *a, const void *b, size_t n)
{
    const volatile unsigned char *x = a;
    const unsigned char *y = b;
    for (; n > 0; n--, x++, y++) {
        if (*x != *y) {
            return *x < *y ? -1 : 1;
        }
    }
    return 0;
}

#if defined(__x86_64__)
#define SYS_WRITE 1
#define SYS_EXIT 60
static long sys3(long number, long a, long b, long c)
{
    long result;
    __asm__ volatile ("syscall"
        : "=a"(result)
        : "a"(number), "D"(a), "S"(b), "d"(c)
        : "rcx", "r11", "memory");
    return result;
}
#elif defined(__aarch64__)
#define SYS_WRITE 64
#define SYS_EXIT 93
static long sys3(long number, long a, long b, long c)
{
    register long x8 __asm__("x8") = number;
    register long x0 __asm__("x0") = a;
    register long x1 __asm__("x1") = b;
    register long x2 __asm__("x2") = c;
    __asm__ volatile ("svc #0" : "+r"(x0) : "r"(x8), "r"(x1), "r"(x2) : "memory");
    return x0;
}
#elif defined(__riscv) && __riscv_xlen == 64
#define SYS_WRITE 64
#define SYS_EXIT 93
static long sys3(long number, long a, long b, long c)
{
    register long a7 __asm__("a7") = number;
    register long a0 __asm__("a0") = a;
    register long a1 __asm__("a1") = b;
    register long a2 __asm__("a2") = c;
    __asm__ volatile ("ecall" : "+r"(a0) : "r"(a7), "r"(a1), "r"(a2) : "memory");
    return a0;
}
#elif defined(__s390x__)
#define SYS_WRITE 4
#define SYS_EXIT 1
static long sys3(long number, long a, long b, long c)
{
    register long r1 __asm__("r1") = number;
    register long r2 __asm__("r2") = a;
    register long r3 __asm__("r3") = b;
    register long r4 __asm__("r4") = c;
    __asm__ volatile ("svc 0" : "+r"(r2) : "r"(r1), "r"(r3), "r"(r4) : "memory");
    return r2;
}
#elif defined(__arm__)
#define SYS_WRITE 4
#define SYS_EXIT 1
static long sys3(long number, long a, long b, long c)
{
    register long r7 __asm__("r7") = number;
    register long r0 __asm__("r0") = a;
    register long r1 __asm__("r1") = b;
    register long r2 __asm__("r2") = c;
    __asm__ volatile ("svc #0" : "+r"(r0) : "r"(r7), "r"(r1), "r"(r2) : "memory");
    return r0;
}
#elif defined(__i386__)
#define SYS_WRITE 4
#define SYS_EXIT 1
static long sys3(long number, long a, long b, long c)
{
    long result;
    __asm__ volatile ("int $0x80"
        : "=a"(result)
        : "a"(number), "b"(a), "c"(b), "d"(c)
        : "memory");
    return result;
}
#else
#error "linux_start.c: no system call stub for this architecture"
#endif

#if defined(__arm__)
/*
 * Linux ARM's libgcc (whose __aeabi_uldivmod a 64-bit % calls) reports a
 * division by zero through the C library's raise: another obligation of
 * the toolchain's, which a C library would meet. The generated program
 * never divides by zero (it checks the divisor first), so this only ends the
 * process should a toolchain routine ever call it.
 */
int raise(int signal);
int raise(int signal)
{
    sys3(SYS_EXIT, 128 + signal, 0, 0);
    return 0;
}

#endif
static void put(const char *s, size_t n)
{
    while (n > 0) {
        long written = sys3(SYS_WRITE, 1, (long)s, (long)n);
        if (written <= 0) {
            return;
        }
        s += written;
        n -= (size_t)written;
    }
}

static size_t length_of(const char *s)
{
    size_t n = 0;
    while (s[n] != '\0') {
        n++;
    }
    return n;
}

static void put_text(const char *s)
{
    put(s, length_of(s));
}

void _start(void);
#if defined(__x86_64__) || defined(__i386__)
__attribute__((force_align_arg_pointer))
#endif
__attribute__((noreturn)) void _start(void)
{
    P(_value) value;
    P(_status) status = P(_run)(&value);
    int code = 0;
    if (status == P(_OK)) {
        size_t n = P(_show)(&value, text, sizeof text);
        put_text("value: ");
        put(text, n < sizeof text ? n : sizeof text);
        put_text("\n");
    } else {
        put_text("error: ");
        put_text(P(_status_message)(status));
        put_text(" (");
        put_text(P(_status_code)(status));
        put_text(")\n");
        code = 1;
    }
    sys3(SYS_EXIT, code, 0, 0);
    for (;;) {
    }
}
