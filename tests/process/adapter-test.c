/* adapter-test.c -- the process_linux adapter's own guarantees, which the
 * Botlish scenarios cannot reach (the module never hands a handle to another
 * thread, never releases an unreaped child, never ends a thread with a
 * child): tests/process-linux.test, PROCESS-LINUX-PACKAGE-MILESTONE-1.md.
 * Ported from the census's audit/managed-subprocess/native/msp-test.c.
 *
 *   cc -O2 -pthread -DPL_TESTING adapter-test.c process_linux.c -o adapter-test
 *   ./adapter-test HELPER
 *
 * Prints one line per check and "adapter-test: N failures". */
#define _GNU_SOURCE
#include <errno.h>
#include <pthread.h>
#include <signal.h>
#include <stdio.h>
#include <string.h>
#include <sys/wait.h>
#include <unistd.h>

long long pl_spec_new(void);
long long pl_spec_free(long long);
long long pl_spec_executable(long long, const void *, unsigned long);
long long pl_spec_arg(long long, const void *, unsigned long);
long long pl_spawn(long long);
long long pl_status(long long);
long long pl_signal(long long, long long, long long);
long long pl_reap(long long);
long long pl_release(long long);
long long pl_pid(long long);
long long pl_fd(long long, long long);
long long pl_kill_and_reap(long long);
long long pl_detach(long long);
long long pl_sweep(void);
long long pl_stat(long long);
long long pl_write(long long, const void *, unsigned long, long long);
long long pl_t_faults(long long);
long long pl_t_open_fds(void);
long long pl_t_proc_state(long long);

static int failures;
static void check(const char *what, long long got, long long want) {
    printf("%s %s: %lld (want %lld)\n", got == want ? "ok  " : "FAIL", what, got, want);
    if (got != want) failures++;
}

static long long spawn(const char *helper, const char **args) {
    long long s = pl_spec_new();
    pl_spec_executable(s, helper, strlen(helper));
    for (; *args; args++) pl_spec_arg(s, *args, strlen(*args));
    long long h = pl_spawn(s);
    pl_spec_free(s);
    return h;
}

static void wait_exit(long long h) {
    for (int i = 0; i < 2000 && pl_status(h) == 0; i++) usleep(1000);
}

static long long other_thread_result[4];
static void *other(void *arg) {
    long long h = *(long long *)arg;
    other_thread_result[0] = pl_signal(h, 0, 0);
    other_thread_result[1] = pl_status(h);
    other_thread_result[2] = pl_write(h, "x", 1, 0);
    other_thread_result[3] = pl_spec_free(0);
    return NULL;
}

/* A thread that spawns two children and ends: one supervised (killed and
 * reaped by the thread's end), one detached (left running). */
static const char *thread_helper;
static long long ended_pids[2];
static void *ending(void *arg) {
    (void)arg;
    const char *args[] = { "ignore:15", "sleep:30000", NULL };
    long long a = spawn(thread_helper, args);
    long long b = spawn(thread_helper, args);
    ended_pids[0] = pl_pid(a);
    ended_pids[1] = pl_pid(b);
    pl_detach(b);
    /* A spec the thread made and never freed: freed by its end. */
    pl_spec_new();
    return NULL;
}

int main(int argc, char **argv) {
    if (argc < 2) return 2;
    const char *helper = argv[1];
    thread_helper = helper;
    long long fds = pl_t_open_fds();
    const char *sleep_args[] = { "sleep:5000", NULL };
    long long h = spawn(helper, sleep_args);
    check("spawn", h > 0, 1);
    long long spec = pl_spec_new();
    pthread_t t;
    pthread_create(&t, NULL, other, &h);
    pthread_join(t, NULL);
    check("another thread's signal is refused", other_thread_result[0], -EPERM);
    check("another thread's status is refused", other_thread_result[1], -EPERM);
    check("another thread's write is refused", other_thread_result[2], -EPERM);
    check("another thread's spec is refused", other_thread_result[3], -1004);
    pl_spec_free(spec);
    check("release before reap is refused", pl_release(h), -EBUSY);
    check("kill and reap", pl_kill_and_reap(h), 0);
    check("signal after reap", pl_signal(h, SIGTERM, 1), -ESRCH);
    check("release after reap", pl_release(h), 0);
    check("a released handle is stale", pl_status(h), -ESTALE);
    long long h2 = spawn(helper, sleep_args);
    check("slot reuse keeps the index", (h2 & 0xffff) == (h & 0xffff), 1);
    check("... with another generation", h2 != h, 1);
    check("the old handle does not reach the new child", pl_signal(h, SIGKILL, 0), -ESTALE);
    check("the new child runs", pl_status(h2), 0);
    check("a signal number out of range is refused", pl_signal(h2, 65, 0), -EINVAL);
    pl_kill_and_reap(h2);
    pl_release(h2);
    const char *exit_args[] = { "exit:0", NULL };
    long long h3 = spawn(helper, exit_args);
    wait_exit(h3);
    check("exit observed by peeking", pl_status(h3), 1);
    check("a zombie (unreaped) takes a signal", pl_signal(h3, 0, 1), 0);
    check("reap", pl_reap(h3), 0);
    pl_release(h3);
    /* After the reap only the refusal guards a group signal: the pidfd
     * answers ESRCH for the process itself, but the group's ID outlives its
     * leader while a member runs -- the kernel's group flag still reaches
     * it, and the fallback's kill(-pgid) names whatever group holds that
     * number once it is free. */
    const char *group_args[] = { "child:sleep:30000", "exit:0", NULL };
    long long hg = spawn(helper, group_args);
    long long gpid = pl_pid(hg);
    wait_exit(hg);
    pl_reap(hg);
    check("a group signal after the reap is refused while a member runs", pl_signal(hg, 0, 1), -ESRCH);
    pl_t_faults(64);
    check("... also without the kernel's group flag (the kill(-pgid) fallback)", pl_signal(hg, 0, 1), -ESRCH);
    pl_t_faults(0);
    kill(-(pid_t)gpid, SIGKILL);
    pl_release(hg);
    const char *short_args[] = { "sleep:100", NULL };
    long long h4 = spawn(helper, short_args);
    long long h4d = pl_detach(h4);
    check("detach gives the reaping handle", h4d > 0 && h4d != h4, 1);
    check("a detached handle is stale", pl_status(h4), -ESTALE);
    check("sweep while it runs", pl_sweep(), 1);
    usleep(300000);
    check("sweep after it ended", pl_sweep(), 0);
    check("the swept handle is stale", pl_status(h4d), -ESTALE);
    const char *missing_args[] = { NULL };
    long long fds2 = pl_t_open_fds();
    for (int i = 0; i < 3; i++) spawn("/nonexistent", missing_args);
    check("posix_spawn+pidfd_open: no descriptor leaked by exec failures", pl_t_open_fds() - fds2, 0);
    /* The negative control: glibc's pidfd_spawn leaked its pidfd when exec
     * failed (glibc bug 31695) until its fix (2.40, and later 2.39
     * builds): reported, not required -- this host's glibc decides. */
    pl_t_faults(8);
    for (int i = 0; i < 3; i++) spawn("/nonexistent", missing_args);
    pl_t_faults(0);
    long long leaked = pl_t_open_fds() - fds2;
    printf("info pidfd_spawn (negative control): %lld descriptors leaked by 3 exec failures (%s)\n",
           leaked, leaked == 3 ? "this glibc leaks" : leaked == 0 ? "this glibc has the fix" : "unexpected");
    check("pidfd_spawn (negative control) leaks one descriptor per failure or none", leaked == 0 || leaked == 3, 1);
    /* A thread's end: its supervised child killed and reaped, its detached
     * one left running and swept later. */
    long long live = pl_stat(12), killed = pl_stat(15), specs = pl_stat(16);
    pthread_create(&t, NULL, ending, NULL);
    pthread_join(t, NULL);
    check("the ended thread's supervised child is gone", pl_t_proc_state(ended_pids[0]), -ENOENT);
    check("its detached child still runs", pl_t_proc_state(ended_pids[1]) > 0 && pl_t_proc_state(ended_pids[1]) != 'Z', 1);
    check("children killed at a thread's end", pl_stat(15) - killed, 1);
    check("the thread's spec was freed", pl_stat(16) - specs, 0);
    kill((pid_t)ended_pids[1], SIGKILL);
    usleep(100000);
    check("a later sweep reaps the orphaned detached child", pl_sweep(), 0);
    check("the orphaned detached child is reaped", pl_t_proc_state(ended_pids[1]), -ENOENT);
    check("unreaped children", pl_stat(12) - live, 0);
    check("descriptors (without the control's leaks)", pl_t_open_fds() - fds - leaked, 0);
    check("descriptors the adapter holds", pl_stat(13), 0);
    printf("adapter-test: %d failures\n", failures);
    return failures != 0;
}
