/* mtprobe.c -- the observation fixture of MACOS-GRAPHICAL-MAIN-THREAD-CENSUS.md.
 *
 * A static library a probe program (Botlish or C) links to report, at named
 * stages, which thread it is on and what SDL says -- never to do the work
 * under study. Every SDL *operation* of a Botlish probe (SDL_Init,
 * SDL_CreateWindow, SDL_PollEvent, ...) is a call the Botlish program makes
 * itself; this file only reads state:
 *
 *   thread identity     pthread_threadid_np (macOS) / gettid (Linux) of the
 *                       calling thread, against the process's main thread's,
 *                       recorded by a constructor (constructors run on the
 *                       process's initial thread, before main);
 *                       pthread_main_np() (macOS: libpthread's own answer;
 *                       Linux: gettid() == getpid()); [NSThread isMainThread]
 *                       through the Objective-C runtime's C interface
 *                       (Foundation's answer; -1 where there is none)
 *   stack               the calling thread's stack as libpthread/glibc
 *                       reports it, and the current stack pointer
 *   time                CLOCK_MONOTONIC, and on macOS the time since exec
 *                       (sysctl KERN_PROC's p_starttime)
 *   threads             the process's thread count (task_threads, /proc)
 *   SDL                 mtprobe_sdl.c: SDL_GetError (thread-local),
 *                       SDL_GetCurrentVideoDriver, the renderer's name, the
 *                       window's ID, flags and Cocoa window -- and, on
 *                       request, a screen capture of that window
 *                       (screencapture -l, macOS). This file needs no SDL,
 *                       so a program without it (identity.rs) links it.
 *
 * Every report is one line on standard error: "MTP " and a JSON object,
 * which tools/census.py reads. Standard output stays the program's own.
 */
#define _GNU_SOURCE
#include <pthread.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>

#ifdef __APPLE__
#include <mach/mach.h>
#include <objc/message.h>
#include <objc/runtime.h>
#include <sys/sysctl.h>
#include <sys/time.h>
#else
#include <dirent.h>
#include <sys/syscall.h>
#endif

static uint64_t main_tid;
static long long loaded_ns;

static long long now_ns(void) {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (long long)ts.tv_sec * 1000000000LL + ts.tv_nsec;
}

static uint64_t current_tid(void) {
#ifdef __APPLE__
    uint64_t t = 0;
    pthread_threadid_np(NULL, &t);
    return t;
#else
    return (uint64_t)syscall(SYS_gettid);
#endif
}

/* The process's initial thread runs constructors before main(). */
__attribute__((constructor)) static void record_main_thread(void) {
    main_tid = current_tid();
    loaded_ns = now_ns();
}

int mtp_is_process_main(void) {
#ifdef __APPLE__
    return pthread_main_np();
#else
    return (pid_t)syscall(SYS_gettid) == getpid();
#endif
}

/* Foundation's answer, through the Objective-C runtime's C interface: -1
 * where there is no NSThread class (Linux; or Foundation not loaded). */
int mtp_ns_is_main(void) {
#ifdef __APPLE__
    Class thread = objc_getClass("NSThread");
    if (!thread) return -1;
    BOOL (*send)(id, SEL) = (BOOL (*)(id, SEL))objc_msgSend;
    return send((id)thread, sel_registerName("isMainThread")) ? 1 : 0;
#else
    return -1;
#endif
}

long long mtp_now_ns(void) { return now_ns(); }

/* Microseconds since the process was exec'd: KERN_PROC's start time (macOS,
 * the realtime clock), -1 elsewhere. */
static long long since_exec_us(void) {
#ifdef __APPLE__
    struct kinfo_proc info;
    size_t size = sizeof info;
    int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()};
    if (sysctl(mib, 4, &info, &size, NULL, 0) != 0 || size == 0) return -1;
    struct timeval start = info.kp_proc.p_starttime, now;
    gettimeofday(&now, NULL);
    return (long long)(now.tv_sec - start.tv_sec) * 1000000LL + (now.tv_usec - start.tv_usec);
#else
    return -1;
#endif
}

int mtp_threads(void) {
#ifdef __APPLE__
    thread_act_array_t list;
    mach_msg_type_number_t count = 0;
    if (task_threads(mach_task_self(), &list, &count) != KERN_SUCCESS) return -1;
    for (mach_msg_type_number_t i = 0; i < count; i++) mach_port_deallocate(mach_task_self(), list[i]);
    vm_deallocate(mach_task_self(), (vm_address_t)list, count * sizeof(thread_act_t));
    return (int)count;
#else
    DIR *d = opendir("/proc/self/task");
    if (!d) return -1;
    int n = 0;
    struct dirent *e;
    while ((e = readdir(d))) if (e->d_name[0] != '.') n++;
    closedir(d);
    return n;
#endif
}

static void stack_of_thread(uintptr_t *low, uintptr_t *high) {
#ifdef __APPLE__
    pthread_t self = pthread_self();
    *high = (uintptr_t)pthread_get_stackaddr_np(self);
    *low = *high - pthread_get_stacksize_np(self);
#else
    pthread_attr_t attr;
    void *addr = NULL;
    size_t size = 0;
    *low = *high = 0;
    if (pthread_getattr_np(pthread_self(), &attr) == 0) {
        pthread_attr_getstack(&attr, &addr, &size);
        pthread_attr_destroy(&attr);
        *low = (uintptr_t)addr;
        *high = *low + size;
    }
#endif
}

static const char *const stage_names[] = {
    "entry", "before-init", "after-init", "after-window", "after-renderer",
    "after-present", "after-events", "after-destroy", "after-quit", "exit",
    "coroutine-body", "coroutine-resumed", "deep", "dispatch-call", "after-push",
    "callback-init", "callback-iterate", "callback-event", "callback-quit", "worker",
    "pump-100",
};

const char *mtp_stage_name(int stage) {
    if (stage >= 0 && stage < (int)(sizeof stage_names / sizeof *stage_names)) return stage_names[stage];
    return "unknown";
}

/* TEXT as a JSON string's contents on F (quotes, backslashes, controls). */
void mtp_json_text(FILE *f, const char *text) {
    if (!text) { fputs("null", f); return; }
    fputc('"', f);
    for (const unsigned char *p = (const unsigned char *)text; *p; p++) {
        if (*p == '"' || *p == '\\') fprintf(f, "\\%c", *p);
        else if (*p < 0x20) fprintf(f, "\\u%04x", *p);
        else fputc(*p, f);
    }
    fputc('"', f);
}

/* One line: where STAGE runs. Returns pthread_main_np()'s answer. */
int mtp_mark(int stage) {
    uintptr_t low, high;
    stack_of_thread(&low, &high);
    int process_main = mtp_is_process_main();
    fprintf(stderr,
            "MTP {\"kind\":\"mark\",\"stage\":\"%s\",\"tid\":%llu,\"main_tid\":%llu,\"same_tid\":%d,"
            "\"pthread_main\":%d,\"ns_main\":%d,\"sp\":\"%p\",\"stack_low\":\"0x%lx\",\"stack_high\":\"0x%lx\","
            "\"stack_bytes\":%lu,\"t_ns\":%lld,\"since_load_ns\":%lld,\"since_exec_us\":%lld,\"threads\":%d}\n",
            mtp_stage_name(stage), (unsigned long long)current_tid(), (unsigned long long)main_tid,
            current_tid() == main_tid, process_main, mtp_ns_is_main(), __builtin_frame_address(0),
            (unsigned long)low, (unsigned long)high, (unsigned long)(high - low), now_ns(),
            now_ns() - loaded_ns, since_exec_us(), mtp_threads());
    fflush(stderr);
    return process_main;
}

/* Nanoseconds since START_NS (an earlier mtp_now_ns()). */
long long mtp_elapsed_since(long long start_ns) { return now_ns() - start_ns; }

/* A labelled number the program computed (a count, a duration). */
long long mtp_value(int stage, long long value) {
    fprintf(stderr, "MTP {\"kind\":\"value\",\"stage\":\"%s\",\"value\":%lld,\"pthread_main\":%d}\n",
            mtp_stage_name(stage), value, mtp_is_process_main());
    fflush(stderr);
    return value;
}

/* A fault that is no stack's exhaustion: a store to address 16. The stack
 * guard must leave it to the process's own disposition (death by the
 * signal), never report it as NATIVE LIMIT STACK. */
int mtp_fault(void) {
    mtp_mark(0);
    volatile uintptr_t where = 16;
    *(volatile int *)where = 1;
    return 0;
}

/* Sleeps MS milliseconds in a C call (nanosleep, restarted after a handled
 * signal): a program that is busy in C, for the termination probes. */
int mtp_sleep_ms(int ms) {
    struct timespec left = {ms / 1000, (long)(ms % 1000) * 1000000L};
    while (nanosleep(&left, &left) != 0) {}
    return ms;
}
