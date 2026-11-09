/* msp-test.c -- the experimental adapter's own guarantees, which the
 * Botlish scenarios cannot reach (the module never hands a handle to another
 * thread, never releases an unreaped child): MANAGED-SUBPROCESS-AND-EVENT-
 * LOOP-CENSUS-MILESTONE-1.md, section 16.
 *
 *   cc -O2 -pthread msp-test.c msp.c -o msp-test && ./msp-test HELPER
 *
 * Prints one line per check and "msp-test: N failures". */
#define _GNU_SOURCE
#include <errno.h>
#include <pthread.h>
#include <signal.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

long long msp_spec_new(void);
long long msp_spec_free(long long);
long long msp_spec_executable(long long, const void *, unsigned long);
long long msp_spec_arg(long long, const void *, unsigned long);
long long msp_spec_flags(long long, long long);
long long msp_spawn(long long);
long long msp_status(long long);
long long msp_signal(long long, long long, long long);
long long msp_reap(long long);
long long msp_release(long long);
long long msp_pid(long long);
long long msp_kill_and_reap(long long);
long long msp_open_fds(void);
long long msp_detach(long long);
long long msp_sweep(void);

static int failures;
static void check(const char *what, long long got, long long want) {
    printf("%s %s: %lld (want %lld)\n", got == want ? "ok  " : "FAIL", what, got, want);
    if (got != want) failures++;
}

static long long spawn(const char *helper, const char **args, long long flags) {
    long long s = msp_spec_new();
    msp_spec_executable(s, helper, strlen(helper));
    for (; *args; args++) msp_spec_arg(s, *args, strlen(*args));
    msp_spec_flags(s, flags);
    long long h = msp_spawn(s);
    msp_spec_free(s);
    return h;
}

static long long other_thread_result;
static void *other(void *arg) {
    other_thread_result = msp_signal(*(long long *)arg, 0, 0);
    return NULL;
}

static void wait_exit(long long h) {
    for (int i = 0; i < 2000 && msp_status(h) == 0; i++) usleep(1000);
}

int main(int argc, char **argv) {
    if (argc < 2) return 2;
    const char *helper = argv[1];
    long long fds = msp_open_fds();
    const char *sleep_args[] = { "sleep:5000", NULL };
    long long h = spawn(helper, sleep_args, 0);
    check("spawn", h > 0, 1);
    pthread_t t;
    pthread_create(&t, NULL, other, &h);
    pthread_join(t, NULL);
    check("another thread's signal is refused", other_thread_result, -EPERM);
    check("release before reap is refused", msp_release(h), -EBUSY);
    check("kill and reap", msp_kill_and_reap(h), 0);
    check("signal after reap", msp_signal(h, SIGTERM, 1), -ESRCH);
    check("release after reap", msp_release(h), 0);
    check("a released handle is stale", msp_status(h), -ESTALE);
    long long h2 = spawn(helper, sleep_args, 0);
    check("slot reuse keeps the index", (h2 & 0xffff) == (h & 0xffff), 1);
    check("... with another generation", h2 != h, 1);
    check("the old handle does not reach the new child", msp_signal(h, SIGKILL, 0), -ESTALE);
    check("the new child runs", msp_status(h2), 0);
    msp_kill_and_reap(h2);
    msp_release(h2);
    const char *exit_args[] = { "exit:0", NULL };
    long long h3 = spawn(helper, exit_args, 0);
    wait_exit(h3);
    check("exit observed by peeking", msp_status(h3), 1);
    check("a zombie (unreaped) takes a signal", msp_signal(h3, 0, 1), 0);
    check("reap", msp_reap(h3), 0);
    msp_release(h3);
    const char *short_args[] = { "sleep:100", NULL };
    long long h4 = spawn(helper, short_args, 0);
    check("detach", msp_detach(h4), 0);
    check("a detached handle is stale", msp_status(h4), -ESTALE);
    check("sweep while it runs", msp_sweep(), 1);
    usleep(300000);
    check("sweep after it ended", msp_sweep(), 0);
    const char *missing_args[] = { NULL };
    long long fds2 = msp_open_fds();
    for (int i = 0; i < 3; i++) spawn("/nonexistent", missing_args, 0);
    check("posix_spawn+pidfd_open: no descriptor leaked by exec failures", msp_open_fds() - fds2, 0);
    for (int i = 0; i < 3; i++) spawn("/nonexistent", missing_args, 32);
    check("pidfd_spawn (negative control): descriptors leaked by exec failures", msp_open_fds() - fds2, 3);
    check("descriptors (without the control's leaks)", msp_open_fds() - fds - 3, 0);
    printf("msp-test: %d failures\n", failures);
    return failures != 0;
}
