/*
 * linux_x86_64_start.c -- a freestanding startup harness for Linux x86-64
 * (C-COMPILE-FREESTANDING-MILESTONE-1.md, "Freestanding and toolchain
 * validation"). It replaces the C library's startup: the process begins at
 * _start, runs the generated program, writes "value: TEXT" or
 * "error: MESSAGE (CODE)" to standard output through the write system
 * call, and exits through the exit system call. It is the one
 * target-specific file of the demonstration (inline assembly for the two
 * system calls), and it supplies the four memory functions the C
 * toolchain itself requires of a freestanding environment; the generated
 * program contains neither.
 *
 *     cc -std=c11 -ffreestanding -nostdlib -static -fno-stack-protector \
 *        -DBOTLISH_PROGRAM=PREFIX -DBOTLISH_PROGRAM_HEADER='"PREFIX.h"' \
 *        -I OUT linux_x86_64_start.c OUT/PREFIX.c OUT/PREFIX_display.c
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

static long sys3(long number, long a, long b, long c)
{
    long result;
    __asm__ volatile ("syscall"
        : "=a"(result)
        : "a"(number), "D"(a), "S"(b), "d"(c)
        : "rcx", "r11", "memory");
    return result;
}

static void put(const char *s, size_t n)
{
    while (n > 0) {
        long written = sys3(1 /* write */, 1, (long)s, (long)n);
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
__attribute__((force_align_arg_pointer, noreturn)) void _start(void)
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
    sys3(60 /* exit */, code, 0, 0);
    for (;;) {
    }
}
