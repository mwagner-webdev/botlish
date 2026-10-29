/* mainthread-fixture.c -- the C side of tests/main-thread-startup.test
 * (MAIN-THREAD-STARTUP-MILESTONE-1.md): which thread, and which stack, a
 * standalone executable's Botlish code calls C from.
 *
 * Test infrastructure only: tests/main-thread-startup.test compiles it with
 * the host C compiler into a static archive
 * (libbotlish_mainthread_fixture.a) in a private directory and links Botlish
 * programs against it. Nothing in the compiler, the runtime or the libraries
 * depends on it.
 *
 * It is the independent witness of the startup policy: the runtime's own
 * report (BOTLISH_NATIVE_STARTUP_REPORT's `thread` line) says where the
 * runtime thinks it runs; these answers are the host's, asked from C.
 */
#if defined(__linux__)
#define _GNU_SOURCE
#include <sys/syscall.h>
#include <unistd.h>
#endif
#include <stdint.h>
#include <stddef.h>
#if defined(__APPLE__) || defined(__linux__)
#include <pthread.h>
#include <time.h>
#endif

/* 1 when the calling thread is the process's main thread, 0 when it is
 * another, -1 on a host this fixture cannot ask (Windows). macOS:
 * libpthread's own answer (pthread_main_np); Linux: the main thread's id is
 * the process's. */
int bmt_on_process_main(void) {
#if defined(__APPLE__)
    return pthread_main_np() == 1;
#elif defined(__linux__)
    return syscall(SYS_gettid) == getpid();
#else
    return -1;
#endif
}

/* 1 when the caller runs on a stack that is not its thread's own -- a
 * coroutine's, which the runtime switches to on the same thread -- 0 on the
 * thread's own stack, -1 when the host cannot say. The thread's stack is the
 * one libpthread describes (macOS: pthread_get_stackaddr_np and _stacksize_np;
 * Linux: pthread_getattr_np). */
int bmt_off_thread_stack(void) {
    volatile char probe = 0;
    uintptr_t sp = (uintptr_t)&probe;
#if defined(__APPLE__)
    pthread_t self = pthread_self();
    uintptr_t high = (uintptr_t)pthread_get_stackaddr_np(self);
    size_t size = pthread_get_stacksize_np(self);
    return !(sp < high && sp >= high - size);
#elif defined(__linux__)
    pthread_attr_t attr;
    void *base = NULL;
    size_t size = 0;
    if (pthread_getattr_np(pthread_self(), &attr) != 0) return -1;
    int rc = pthread_attr_getstack(&attr, &base, &size);
    pthread_attr_destroy(&attr);
    if (rc != 0) return -1;
    return !(sp >= (uintptr_t)base && sp < (uintptr_t)base + size);
#else
    (void)sp;
    return -1;
#endif
}

/* A fault that is no stack overflow: a store to address 16. The stack guard
 * must leave it to the signal's own disposition. */
int bmt_fault(void) {
    volatile uintptr_t where = 16;
    volatile int *p = (volatile int *)where;
    *p = 1;
    return *p;
}

/* Sleeps MS milliseconds in C: a program busy in a C call, for the signal
 * checks. */
int bmt_sleep_ms(int ms) {
#if defined(__APPLE__) || defined(__linux__)
    struct timespec t = {ms / 1000, (long)(ms % 1000) * 1000000L};
    while (nanosleep(&t, &t) != 0) {
    }
    return ms;
#else
    return -1;
#endif
}
