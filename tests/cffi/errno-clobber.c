/* errno-clobber.c -- test infrastructure for tests/c-ffi-error-capture.test
 * (C-FFI-ERROR-CAPTURE-MILESTONE-1.md): an allocator that changes errno.
 *
 * POSIX leaves errno unspecified after a successful call, so an allocator
 * may change it on success; glibc's and Apple's do not in practice. This
 * library makes the worst case real: loaded into one run of a standalone
 * executable (LD_PRELOAD on Linux, DYLD_INSERT_LIBRARIES on macOS), every
 * successful malloc, calloc, realloc, posix_memalign or aligned_alloc -- the
 * Botlish runtime's heap objects come from the system allocator -- sets errno
 * to BCF_ERRNO_CLOBBER (default 77) before it returns. A program that reads a
 * C call's errno after an allocation sees that marker instead of the call's
 * own errno; one with nothing allocated in between sees the call's.
 *
 * free is left alone (POSIX 2024 requires it to keep errno). Nothing in
 * Botlish knows the library exists: it stands where the system allocator
 * would have answered.
 *
 * On Linux the wrappers are the definitions themselves, over glibc's
 * __libc_* entry points (no dlsym, which may itself allocate); on macOS the
 * `__DATA,__interpose` section makes dyld bind every other image's
 * references to the libSystem functions to them (dyld never interposes an
 * image's references to itself, so their own calls reach libSystem). */
#include <errno.h>
#include <stdlib.h>

static int bcf_marker;

static int bcf_clobber(void) {
    if (bcf_marker == 0) {
        const char *text = getenv("BCF_ERRNO_CLOBBER");
        bcf_marker = text != NULL && atoi(text) != 0 ? atoi(text) : 77;
    }
    return bcf_marker;
}

#if defined(__linux__)
extern void *__libc_malloc(size_t);
extern void *__libc_calloc(size_t, size_t);
extern void *__libc_realloc(void *, size_t);
extern void *__libc_memalign(size_t, size_t);

void *malloc(size_t n) {
    void *p = __libc_malloc(n);
    if (p != NULL) {
        errno = bcf_clobber();
    }
    return p;
}

void *calloc(size_t count, size_t n) {
    void *p = __libc_calloc(count, n);
    if (p != NULL) {
        errno = bcf_clobber();
    }
    return p;
}

void *realloc(void *old, size_t n) {
    void *p = __libc_realloc(old, n);
    if (p != NULL) {
        errno = bcf_clobber();
    }
    return p;
}

int posix_memalign(void **out, size_t alignment, size_t n) {
    void *p = __libc_memalign(alignment, n);
    if (p == NULL) {
        return ENOMEM;
    }
    *out = p;
    errno = bcf_clobber();
    return 0;
}

void *aligned_alloc(size_t alignment, size_t n) {
    void *p = __libc_memalign(alignment, n);
    if (p != NULL) {
        errno = bcf_clobber();
    }
    return p;
}

void *memalign(size_t alignment, size_t n) {
    return aligned_alloc(alignment, n);
}
#elif defined(__APPLE__)
static void *bcf_malloc(size_t n) {
    void *p = malloc(n);
    if (p != NULL) {
        errno = bcf_clobber();
    }
    return p;
}

static void *bcf_calloc(size_t count, size_t n) {
    void *p = calloc(count, n);
    if (p != NULL) {
        errno = bcf_clobber();
    }
    return p;
}

static void *bcf_realloc(void *old, size_t n) {
    void *p = realloc(old, n);
    if (p != NULL) {
        errno = bcf_clobber();
    }
    return p;
}

static int bcf_posix_memalign(void **out, size_t alignment, size_t n) {
    int status = posix_memalign(out, alignment, n);
    if (status == 0) {
        errno = bcf_clobber();
    }
    return status;
}

static void *bcf_aligned_alloc(size_t alignment, size_t n) {
    void *p = aligned_alloc(alignment, n);
    if (p != NULL) {
        errno = bcf_clobber();
    }
    return p;
}

__attribute__((used)) static const struct {
    const void *replacement;
    const void *replacee;
} bcf_interposers[] __attribute__((section("__DATA,__interpose"))) = {
    {(const void *)(unsigned long)&bcf_malloc, (const void *)(unsigned long)&malloc},
    {(const void *)(unsigned long)&bcf_calloc, (const void *)(unsigned long)&calloc},
    {(const void *)(unsigned long)&bcf_realloc, (const void *)(unsigned long)&realloc},
    {(const void *)(unsigned long)&bcf_posix_memalign, (const void *)(unsigned long)&posix_memalign},
    {(const void *)(unsigned long)&bcf_aligned_alloc, (const void *)(unsigned long)&aligned_alloc},
};
#endif
