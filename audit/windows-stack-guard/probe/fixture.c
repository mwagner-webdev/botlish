/* The probe's C recursions (WINDOWS-X86-64-MILESTONE-4.md, "Experiments"):
 * each frame keeps a volatile buffer it reads after its recursive call, so
 * the call is no tail call and no compiler folds the recursion into a loop.
 * probe_c_deep's frames are under a page; probe_c_wide's are 64 KiB, which
 * MSVC probes page by page (__chkstk) before using them. */
#if defined(_MSC_VER)
#define NOINLINE __declspec(noinline)
#else
#define NOINLINE __attribute__((noinline))
#endif

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
