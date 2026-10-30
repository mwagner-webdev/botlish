/* notify.c -- the bridge's one use of the event loop's native integration
 * ABI (packages/event_loop_linux/native/botlish_event_loop.h, version 1):
 * a wake from a foreign thread posts a record. The reference is weak, so
 * a program without the Linux driver links (its wakes are refused with
 * -ENOSYS: the deterministic driver has no foreign threads to wake it). A
 * weak reference pulls no archive member: it resolves only because the
 * driver's module calls the adapter, whose one object defines the symbol. */
__attribute__((weak)) int botlish_event_post(int endpoint, int slot, int gen, long long a, long long b);

int hs_notify_post(int endpoint, int slot, int gen, long long a, long long b) {
    if (!botlish_event_post) {
        return -38;
    }
    return botlish_event_post(endpoint, slot, gen, a, b);
}
