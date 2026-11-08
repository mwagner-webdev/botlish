/* device.c -- the broker example's simulated exclusive device
 * (BOTLISH-OWNED-THREADS-AND-CROSS-THREAD-ACTORS-MILESTONE-1.md): a
 * resource of the process that admits one owner at a time, as a hardware
 * device or a native connection does. device_acquire refuses a second
 * owner (-EBUSY) whatever VM or thread asks; the operation counters record
 * every operation's entry and exit, so a test can see whether two ever
 * overlapped (they must not: the owner serializes them through one actor).
 */
#include <errno.h>
#include <stdatomic.h>

static atomic_int owner;           /* 0 free, 1 owned */
static atomic_int inside;          /* operations entered and not exited */
static atomic_long entered, overlaps, peak;

int device_acquire(void) {
    int free = 0;
    return atomic_compare_exchange_strong(&owner, &free, 1) ? 0 : -EBUSY;
}

int device_release(void) {
    atomic_store(&owner, 0);
    return 0;
}

/* An operation begins: the number of operations now inside (1 when none
 * overlaps). */
int device_enter(void) {
    int now = atomic_fetch_add(&inside, 1) + 1;
    atomic_fetch_add(&entered, 1);
    if (now > 1) atomic_fetch_add(&overlaps, 1);
    long p = atomic_load(&peak);
    while (now > p && !atomic_compare_exchange_weak(&peak, &p, now)) {
    }
    return now;
}

int device_exit(void) {
    return atomic_fetch_sub(&inside, 1) - 1;
}

/* 0 operations entered, 1 overlaps seen, 2 the most at once. */
long device_stat(int i) {
    return i == 0 ? atomic_load(&entered) : i == 1 ? atomic_load(&overlaps) : atomic_load(&peak);
}
