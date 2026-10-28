/* evn_test.c -- adapter-level tests of evn.c (EVENT-LOOP-EXPLORATION.md,
 * "Testing"), built and run by tools/native.tcl:
 *
 *   buffered-lines   a peer sends 10 lines and stops; the program reads them
 *                    one credit at a time, restoring credit only after the
 *                    peer has stopped: every line (and the BYE) must arrive,
 *                    although epoll has nothing more to report once the
 *                    last bytes were read into the adapter's buffer;
 *   wake-race        2000 posts from another thread at random times against
 *                    a loop that blocks with no deadline between them: all
 *                    must arrive, none held to the 1 s deadline (a lost
 *                    wakeup would be: the threshold is 500 ms).
 *
 * Exit status 0 when both pass; one line per test on stdout. */
#include <stdio.h>
#include <time.h>
long long evn_now(void);
int evn_open(int, int, int);
int evn_listen(int, int, int);
int evn_block(long long);
int evn_take(void);
long long evn_a(void);
long long evn_b(void);
int evn_attach(int, int, int, int);
int evn_credit(int, int);
int evn_client(int, int, int, int, int);
int evn_hangup_all(void);
int evn_clients_join(void);
int evn_synth(int, int, int, int, int, int, int);
int evn_synth_join(void);

static int buffered_lines(void) {
    int port = evn_listen(0, 0, 1);
    evn_client(port, 7, 0, 10, 0);
    long long end = evn_now() + 5000000;
    int conn = -1, lines = 0, bye = 0, owed = 0;
    while (evn_now() < end && !bye) {
        evn_block(evn_now() + 20000);
        int slot = evn_take();
        if (slot == 0) { conn = (int)evn_a(); evn_attach(conn, 1, 1, 1); continue; }
        if (slot == 1) {
            lines++;
            if (evn_a() == 9) bye = 1;
            owed++;
        }
        /* Restore credit late: after the peer has sent everything. */
        if (owed && lines >= 1) {
            struct timespec ts = { 0, 30000000 };
            nanosleep(&ts, NULL);
            evn_credit(conn, owed);
            owed = 0;
        }
    }
    evn_hangup_all();
    evn_clients_join();
    printf("%s buffered-lines: %d lines, bye %d\n", (lines == 11 && bye) ? "ok  " : "FAIL", lines, bye);
    return lines == 11 && bye;
}

static int wake_race(void) {
    int n = 2000, got = 0;
    long long worst = 0;
    evn_synth(2, 1, n, 300, 1, 1, 0);
    long long end = evn_now() + 20000000;
    while (got < n && evn_now() < end) {
        evn_block(evn_now() + 1000000);
        while (evn_take() == 2) {
            long long lag = evn_now() - evn_b();
            if (lag > worst) worst = lag;
            got++;
        }
    }
    evn_synth_join();
    int ok = got == n && worst < 500000;
    printf("%s wake-race: %d/%d posts, worst latency %lld us\n", ok ? "ok  " : "FAIL", got, n, worst);
    return ok;
}

int main(void) {
    if (evn_open(512, 16, 0) != 0) { puts("FAIL open"); return 1; }
    int ok = buffered_lines();
    ok = wake_race() && ok;
    return ok ? 0 : 1;
}
