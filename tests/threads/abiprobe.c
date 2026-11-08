/* abiprobe.c -- tests/threads.test: the event-loop integration ABI
 * (botlish_event_loop.h, version 2) as a native library sees it while one
 * loop, then two loops of two VMs, are open (abi.bot).
 *
 * abi_probe(own, other) answers four digits: botlish_event_loop() is OWN
 * (1), -EPIPE (2) or something else (0); botlish_event_wake() succeeds
 * (1), is refused -EPIPE (2) or else (0); botlish_event_wake2(OWN) and
 * botlish_event_wake2(OTHER) succeed (1) or are refused -EPIPE (2). The
 * version 1 functions reach the one open loop while exactly one is, and
 * are refused while several are; a version 2 handle names its loop for as
 * long as it is open.
 */
#include <errno.h>
#include "botlish_event_loop.h"

static int digit(int r, int expected) {
    return r == expected ? 1 : r == -EPIPE ? 2 : 0;
}

int abi_probe(int own, int other) {
    int one = botlish_event_loop();
    int v1 = botlish_event_wake();
    int mine = botlish_event_wake2(own);
    int theirs = botlish_event_wake2(other);
    return digit(one, own) * 1000 + digit(v1, 0) * 100 + digit(mine, 0) * 10 + digit(theirs, 0);
}
