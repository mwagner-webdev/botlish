/* mainstack.c -- the process main thread's stack (MACOS-GRAPHICAL-MAIN-
 * THREAD-CENSUS.md, sections 10-12): what the kernel gives it, read the way
 * the runtime reads a stack (runtime/platform/macos.rs: libpthread's
 * reported top and size, the first accessible address at or above the
 * reported bottom, the run of inaccessible mappings below that), and
 * whether all of it is usable. Linked once per size with Apple ld's
 * `-stack_size` (LC_MAIN's stacksize; tools/census.py), and once without.
 *
 *   mainstack report     one "MTP" line: rlimit, the reported stack, the
 *                        usable range and the confirmed guard
 *   mainstack touch      also recurse in 16 KiB frames down to 256 KiB above
 *                        the usable bottom: the whole stack is usable
 *   mainstack overflow   also recurse without end, with a SIGSEGV/SIGBUS
 *                        handler on an alternate stack that reports whether
 *                        the faulting address is in the confirmed guard
 */
#define _GNU_SOURCE
#include <pthread.h>
#include <signal.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/resource.h>
#include <unistd.h>
#ifdef __APPLE__
#include <mach/mach.h>
#include <mach/mach_vm.h>
#endif

static uintptr_t usable_low, guard_low, high;
static volatile uintptr_t deepest;

#ifdef __APPLE__
/* The mapping containing ADDRESS: start, end and protection; 0 if none. */
static int region(uintptr_t address, uintptr_t *start, uintptr_t *end, int *protection) {
    mach_vm_address_t a = address;
    mach_vm_size_t size = 0;
    vm_region_basic_info_data_64_t info;
    mach_msg_type_number_t count = VM_REGION_BASIC_INFO_COUNT_64;
    mach_port_t object = 0;
    if (mach_vm_region(mach_task_self(), &a, &size, VM_REGION_BASIC_INFO_64, (vm_region_info_t)&info, &count, &object) != KERN_SUCCESS)
        return 0;
    if (a > address) return 0;
    *start = a;
    *end = a + size;
    *protection = info.protection;
    return 1;
}
#endif

static void discover(void) {
    uintptr_t reported_low;
#ifdef __APPLE__
    pthread_t self = pthread_self();
    high = (uintptr_t)pthread_get_stackaddr_np(self);
    reported_low = high - pthread_get_stacksize_np(self);
    uintptr_t s, e;
    int p;
    usable_low = reported_low;
    for (int i = 0; i < 4 && region(usable_low, &s, &e, &p) && p == VM_PROT_NONE && e < high; i++) usable_low = e;
    guard_low = usable_low;
    for (int i = 0; i < 4 && region(guard_low - 1, &s, &e, &p) && p == VM_PROT_NONE && e == guard_low; i++) guard_low = s;
#else
    pthread_attr_t attr;
    void *addr;
    size_t size, guard = 0;
    pthread_getattr_np(pthread_self(), &attr);
    pthread_attr_getstack(&attr, &addr, &size);
    pthread_attr_getguardsize(&attr, &guard);
    pthread_attr_destroy(&attr);
    reported_low = usable_low = (uintptr_t)addr;
    high = usable_low + size;
    guard_low = usable_low - guard;
#endif
    struct rlimit rl;
    getrlimit(RLIMIT_STACK, &rl);
    fprintf(stderr, "MTP {\"kind\":\"mainstack\",\"pthread_main\":%d,\"rlimit_cur\":%lld,\"rlimit_max\":%lld,"
            "\"reported_bytes\":%lu,\"usable_bytes\":%lu,\"reported_bottom_skipped\":%lu,\"guard_bytes\":%lu,"
            "\"high\":\"0x%lx\",\"usable_low\":\"0x%lx\",\"guard_low\":\"0x%lx\"}\n",
#ifdef __APPLE__
            pthread_main_np(),
#else
            -1,
#endif
            (long long)rl.rlim_cur, (long long)rl.rlim_max, (unsigned long)(high - reported_low),
            (unsigned long)(high - usable_low), (unsigned long)(usable_low - reported_low),
            (unsigned long)(usable_low - guard_low), (unsigned long)high, (unsigned long)usable_low,
            (unsigned long)guard_low);
    fflush(stderr);
}

/* Recurse in 16 KiB frames until the stack pointer is within LIMIT of the
 * usable bottom (LIMIT 0: forever). */
__attribute__((noinline)) static int dive(uintptr_t limit, int n) {
    volatile char frame[16384];
    frame[0] = (char)n;
    frame[sizeof frame - 1] = (char)n;
    uintptr_t sp = (uintptr_t)&frame[0];
    deepest = sp;
    if (limit && sp < usable_low + limit) return n;
    return dive(limit, n + 1) + frame[0];
}

static void on_fault(int signal, siginfo_t *info, void *context) {
    (void)context;
    uintptr_t a = (uintptr_t)info->si_addr;
    char line[256];
    int n = snprintf(line, sizeof line, "MTP {\"kind\":\"mainstack-fault\",\"signal\":%d,\"in_guard\":%d,\"below_usable\":%lu,\"deepest_above_usable\":%ld}\n",
                     signal, a >= guard_low && a < usable_low, (unsigned long)(usable_low - a), (long)(deepest - usable_low));
    (void)!write(2, line, n);
    _exit(0);
}

int main(int argc, char **argv) {
    const char *mode = argc > 1 ? argv[1] : "report";
    discover();
    if (!strcmp(mode, "touch")) {
        int frames = dive(256 * 1024, 0);
        fprintf(stderr, "MTP {\"kind\":\"mainstack-touch\",\"frames\":%d,\"deepest_above_usable\":%ld}\n", frames, (long)(deepest - usable_low));
    } else if (!strcmp(mode, "overflow")) {
        static char alt[256 * 1024];
        stack_t ss = {.ss_sp = alt, .ss_size = sizeof alt, .ss_flags = 0};
        sigaltstack(&ss, NULL);
        struct sigaction sa;
        memset(&sa, 0, sizeof sa);
        sa.sa_sigaction = on_fault;
        sa.sa_flags = SA_SIGINFO | SA_ONSTACK;
        sigaction(SIGSEGV, &sa, NULL);
        sigaction(SIGBUS, &sa, NULL);
        dive(0, 0);
    }
    return 0;
}
