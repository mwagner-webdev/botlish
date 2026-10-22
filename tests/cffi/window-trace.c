/* window-trace.c -- test infrastructure for tests/c-ffi-error-capture.test
 * (C-FFI-ERROR-CAPTURE-MILESTONE-1.md): the instructions a process actually
 * executes between two points, by ptrace single-stepping (Linux x86-64 and
 * AArch64).
 *
 *   window-trace EXE START STOP [ARG...]
 *
 * runs EXE (with ARGs, address space randomization off) up to the first time
 * it reaches START, then single-steps until it reaches STOP, printing one line
 * per instruction executed in between (START included, STOP not):
 *
 *   exe ADDRESS          an instruction of EXE (ADDRESS as `nm EXE` prints
 *                        its symbols: the link-time virtual address)
 *   lib PATH OFFSET      one of a shared library mapped from PATH, OFFSET
 *                        from the start of that file's first mapping
 *
 * preceded by one line `errno PATH OFFSET`: where __errno_location is in the
 * C library this tool itself runs with (the same file EXE maps, on the same
 * host), so a caller can recognize that function's instructions. START and
 * STOP are hexadecimal link-time addresses of EXE. Then it lets EXE run to
 * its end and exits with EXE's status (or 125 when tracing failed).
 *
 * With WINDOW_TRACE_UNTIL_LIBRARY set (non-empty) the window also ends after
 * the first instruction executed in a shared library: enough to show that a
 * window enters, say, the allocator, without single-stepping it. (On AArch64
 * a single-step between a load-exclusive and its store-exclusive clears the
 * exclusive monitor, so a lock's retry loop would never end.)
 *
 * Nothing in Botlish knows it exists: it watches an ordinary executable. */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <elf.h>
#include <errno.h>
#include <limits.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/personality.h>
#include <sys/ptrace.h>
#include <sys/uio.h>
#include <sys/user.h>
#include <signal.h>
#include <sys/wait.h>
#include <unistd.h>

#if defined(__x86_64__)
#define TRAP_BYTES 1 /* int3: the PC is past it when the trap is reported */
#elif defined(__aarch64__)
#define TRAP_BYTES 0 /* brk #0: the PC is at it */
#else
#error "window-trace: Linux x86-64 and AArch64 only"
#endif

static void fail(const char *what) {
    fprintf(stderr, "window-trace: %s: %s\n", what, strerror(errno));
    exit(125);
}

static uint64_t pc_of(pid_t pid) {
#if defined(__x86_64__)
    struct user_regs_struct regs;
    if (ptrace(PTRACE_GETREGS, pid, 0, &regs) != 0) fail("PTRACE_GETREGS");
    return regs.rip;
#else
    struct user_regs_struct regs; /* glibc's <sys/user.h>: x0-x30, sp, pc, pstate */
    struct iovec io = {&regs, sizeof regs};
    if (ptrace(PTRACE_GETREGSET, pid, (void *)NT_PRSTATUS, &io) != 0) fail("PTRACE_GETREGSET");
    return regs.pc;
#endif
}

static void set_pc(pid_t pid, uint64_t pc) {
#if defined(__x86_64__)
    struct user_regs_struct regs;
    if (ptrace(PTRACE_GETREGS, pid, 0, &regs) != 0) fail("PTRACE_GETREGS");
    regs.rip = pc;
    if (ptrace(PTRACE_SETREGS, pid, 0, &regs) != 0) fail("PTRACE_SETREGS");
#else
    struct user_regs_struct regs; /* glibc's <sys/user.h>: x0-x30, sp, pc, pstate */
    struct iovec io = {&regs, sizeof regs};
    if (ptrace(PTRACE_GETREGSET, pid, (void *)NT_PRSTATUS, &io) != 0) fail("PTRACE_GETREGSET");
    regs.pc = pc;
    if (ptrace(PTRACE_SETREGSET, pid, (void *)NT_PRSTATUS, &io) != 0) fail("PTRACE_SETREGSET");
#endif
}

/* The lowest p_vaddr of EXE's PT_LOAD segments. */
static uint64_t first_load(const char *exe) {
    FILE *f = fopen(exe, "rb");
    if (f == NULL) fail("open EXE");
    Elf64_Ehdr eh;
    if (fread(&eh, sizeof eh, 1, f) != 1) fail("read ELF header");
    uint64_t lowest = UINT64_MAX;
    for (int i = 0; i < eh.e_phnum; i++) {
        Elf64_Phdr ph;
        if (fseek(f, (long)(eh.e_phoff + (uint64_t)i * eh.e_phentsize), SEEK_SET) != 0
            || fread(&ph, sizeof ph, 1, f) != 1) fail("read program header");
        if (ph.p_type == PT_LOAD && ph.p_vaddr < lowest) lowest = ph.p_vaddr;
    }
    fclose(f);
    return lowest & ~(uint64_t)0xfff;
}

/* The mapping of process PID that contains ADDRESS: its file's PATH and the
 * start of that file's first mapping. 0 when none does. */
static int mapping_of(pid_t pid, uint64_t address, char *path, uint64_t *base) {
    char name[64];
    snprintf(name, sizeof name, "/proc/%d/maps", (int)pid);
    FILE *f = fopen(name, "r");
    if (f == NULL) fail("open maps");
    char line[PATH_MAX + 128];
    char first_path[PATH_MAX] = "";
    uint64_t first_start = 0;
    int found = 0;
    while (fgets(line, sizeof line, f) != NULL) {
        unsigned long long start, end, offset;
        char perms[8], file[PATH_MAX] = "";
        if (sscanf(line, "%llx-%llx %7s %llx %*s %*s %4095s", &start, &end, perms, &offset, file) < 4) continue;
        if (file[0] == '/' && strcmp(file, first_path) != 0) {
            strcpy(first_path, file);
            first_start = start;
        }
        if (address >= start && address < end) {
            strcpy(path, file);
            *base = strcmp(file, first_path) == 0 ? first_start : start;
            found = 1;
            break;
        }
    }
    fclose(f);
    return found;
}

/* The start of the first mapping of EXE in process PID. */
static uint64_t exe_base(pid_t pid, const char *exe) {
    char resolved[PATH_MAX];
    if (realpath(exe, resolved) == NULL) fail("realpath EXE");
    char name[64];
    snprintf(name, sizeof name, "/proc/%d/maps", (int)pid);
    FILE *f = fopen(name, "r");
    if (f == NULL) fail("open maps");
    char line[PATH_MAX + 128];
    uint64_t base = 0;
    while (fgets(line, sizeof line, f) != NULL) {
        unsigned long long start, end, offset;
        char perms[8], file[PATH_MAX] = "";
        if (sscanf(line, "%llx-%llx %7s %llx %*s %*s %4095s", &start, &end, perms, &offset, file) < 5) continue;
        if (strcmp(file, resolved) == 0) {
            base = start;
            break;
        }
    }
    fclose(f);
    if (base == 0) {
        errno = ENOENT;
        fail("EXE is not mapped");
    }
    return base;
}

/* Waits for the next stop of any traced thread of the program (every thread
 * is traced: PTRACE_O_TRACECLONE), letting every one but the stop it reports
 * go on: a new thread's first stop and clone events are resumed here. Returns
 * the thread that stopped with SIGTRAP, or exits when the program ended. */
static pid_t next_trap(pid_t main_pid, int *status) {
    for (;;) {
        pid_t tid = waitpid(-1, status, __WALL);
        if (tid < 0) fail("waitpid");
        if (WIFEXITED(*status) || WIFSIGNALED(*status)) {
            if (tid == main_pid) {
                errno = ECHILD;
                fail("the program ended before the window");
            }
            continue;
        }
        if (!WIFSTOPPED(*status)) continue;
        int sig = WSTOPSIG(*status);
        if (sig == SIGTRAP && (*status >> 16) == 0) return tid;
        /* A clone event, a new thread's initial SIGSTOP, or another signal
         * (passed on). */
        int pass = (sig == SIGTRAP || sig == SIGSTOP) ? 0 : sig;
        if (ptrace(PTRACE_CONT, tid, 0, (void *)(long)pass) != 0) fail("PTRACE_CONT");
    }
}

int main(int argc, char **argv) {
    if (argc < 4) {
        fprintf(stderr, "usage: window-trace EXE START STOP [ARG...]\n");
        return 125;
    }
    const char *exe = argv[1];
    uint64_t start = strtoull(argv[2], NULL, 16);
    uint64_t stop = strtoull(argv[3], NULL, 16);
    const char *until = getenv("WINDOW_TRACE_UNTIL_LIBRARY");
    int until_library = until != NULL && until[0] != '\0';
    Dl_info info;
    if (dladdr((void *)&__errno_location, &info) == 0) fail("dladdr __errno_location");
    char libc[PATH_MAX];
    if (realpath(info.dli_fname, libc) == NULL) strcpy(libc, info.dli_fname);
    printf("errno %s %llx\n", libc, (unsigned long long)((uintptr_t)&__errno_location - (uintptr_t)info.dli_fbase));
    fflush(stdout);

    pid_t pid = fork();
    if (pid < 0) fail("fork");
    if (pid == 0) {
        personality(ADDR_NO_RANDOMIZE);
        if (ptrace(PTRACE_TRACEME, 0, 0, 0) != 0) fail("PTRACE_TRACEME");
        execv(exe, argv + 3);
        fail("execv");
    }
    int status;
    if (waitpid(pid, &status, 0) != pid || !WIFSTOPPED(status)) fail("the exec stop");
    if (ptrace(PTRACE_SETOPTIONS, pid, 0, (void *)(long)(PTRACE_O_TRACECLONE | PTRACE_O_EXITKILL)) != 0) fail("PTRACE_SETOPTIONS");
    char resolved[PATH_MAX];
    if (realpath(exe, resolved) == NULL) fail("realpath EXE");
    uint64_t delta = exe_base(pid, exe) - first_load(exe);
    uint64_t at = start + delta;
    uint64_t end = stop + delta;
    errno = 0;
    long original = ptrace(PTRACE_PEEKTEXT, pid, (void *)at, 0);
    if (errno != 0) fail("PTRACE_PEEKTEXT");
#if defined(__x86_64__)
    long trapped = (original & ~0xffL) | 0xcc;
#else
    long trapped = (original & ~0xffffffffL) | 0xd4200000L;
#endif
    if (ptrace(PTRACE_POKETEXT, pid, (void *)at, (void *)trapped) != 0) fail("PTRACE_POKETEXT");
    if (ptrace(PTRACE_CONT, pid, 0, 0) != 0) fail("PTRACE_CONT");
    /* The program runs on a worker thread (the native runtime's): the trap
     * is that thread's. */
    pid_t tid = next_trap(pid, &status);
    if (pc_of(tid) != at + TRAP_BYTES) {
        errno = EFAULT;
        fail("stopped elsewhere than START");
    }
    if (ptrace(PTRACE_POKETEXT, tid, (void *)at, (void *)original) != 0) fail("PTRACE_POKETEXT");
    set_pc(tid, at);
    for (long steps = 0;; steps++) {
        uint64_t pc = pc_of(tid);
        if (pc == end) break;
        if (steps > 1000000) {
            errno = ELOOP;
            fail("STOP not reached in a million instructions");
        }
        char path[PATH_MAX] = "";
        uint64_t base = 0;
        if (!mapping_of(pid, pc, path, &base) || strcmp(path, resolved) == 0) {
            printf("exe %llx\n", (unsigned long long)(pc - delta));
        } else {
            printf("lib %s %llx\n", path, (unsigned long long)(pc - base));
            if (until_library) break;
        }
        if (ptrace(PTRACE_SINGLESTEP, tid, 0, 0) != 0) fail("PTRACE_SINGLESTEP");
        for (;;) {
            if (waitpid(tid, &status, __WALL) != tid) fail("waitpid");
            if (!WIFSTOPPED(status)) {
                errno = ECHILD;
                fail("the thread ended inside the window");
            }
            if (WSTOPSIG(status) == SIGTRAP && (status >> 16) == 0) break;
            /* A clone event of the stepped thread: step on. */
            if (ptrace(PTRACE_SINGLESTEP, tid, 0, 0) != 0) fail("PTRACE_SINGLESTEP");
        }
    }
    fflush(stdout);
    /* The window is over: let every thread run to the program's end. */
    if (ptrace(PTRACE_CONT, tid, 0, 0) != 0) fail("PTRACE_CONT");
    for (;;) {
        pid_t t = waitpid(-1, &status, __WALL);
        if (t < 0) fail("waitpid");
        if (t == pid && (WIFEXITED(status) || WIFSIGNALED(status))) {
            return WIFEXITED(status) ? WEXITSTATUS(status) : 125;
        }
        if (WIFSTOPPED(status)) {
            int sig = WSTOPSIG(status);
            int pass = (sig == SIGTRAP || sig == SIGSTOP) ? 0 : sig;
            if (ptrace(PTRACE_CONT, t, 0, (void *)(long)pass) != 0) fail("PTRACE_CONT");
        }
    }
}
