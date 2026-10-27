/* The probe's C functions (WINDOWS-X86-64-MILESTONE-5.md, "Architecture
 * comparison"), called from a fiber's and a custom stack's code:
 * scalar, double and pointer arguments, the C runtime's errno, and
 * recursions that grow (and exhaust) the stack they run on -- each frame
 * keeps a volatile buffer it reads after its recursive call, so the call is
 * no tail call and no compiler folds the recursion into a loop.
 * probe_c_wide's frames are 64 KiB, which MSVC probes page by page
 * (__chkstk) before using them. */
#include <errno.h>
#include <string.h>

#if defined(_MSC_VER)
#define NOINLINE __declspec(noinline)
#else
#define NOINLINE __attribute__((noinline))
#endif

NOINLINE long long probe_c_add(long long a, int b, short c) {
    return a + b + c;
}

NOINLINE double probe_c_mix(double a, long long b, double c) {
    return a * (double)b + c;
}

NOINLINE long long probe_c_fill(unsigned char *buffer, long long n, int value) {
    long long sum = 0;
    memset(buffer, value, (size_t)n);
    for (long long i = 0; i < n; i++) {
        sum += buffer[i];
    }
    return sum;
}

NOINLINE void probe_set_errno(int value) {
    errno = value;
}

NOINLINE int probe_get_errno(void) {
    return errno;
}

NOINLINE long probe_c_deep(long n) {
    volatile unsigned char pad[256];
    pad[0] = (unsigned char)n;
    if (n <= 0) {
        return 0;
    }
    return probe_c_deep(n - 1) + (pad[0] == (unsigned char)n);
}

NOINLINE long probe_c_wide(long n) {
    volatile unsigned char pad[65536];
    pad[0] = (unsigned char)n;
    pad[65535] = (unsigned char)n;
    if (n <= 0) {
        return 0;
    }
    return probe_c_wide(n - 1) + (pad[0] == pad[65535]);
}
