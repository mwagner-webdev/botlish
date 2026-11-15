/* notify-weakdef.c -- a variant of packages/http/native/src/notify.c for
 * HTTP-MACOS-RUST-ARCHIVE-LINK-FEASIBILITY-MILESTONE-1.md, section 4: the
 * same C function and the same integration ABI (botlish_event_post2,
 * packages/event_loop_linux/native/botlish_event_loop.h, version 2), with a
 * weak *definition* of botlish_event_post2 in place of http's weak
 * *reference*. A program that links no provider calls this fallback, which
 * answers -38 as http's null check does; one that links a provider's
 * strong definition calls the provider's. The fallback must stay a global
 * (weak) symbol of the localized unit: localized away, every program would
 * call it, provider or not (tools/rust-unit.tcl's -keep). Built in place of
 * http's file with RUSTLINK_NOTIFY (audit/rust-archive-link/unit/build.rs). */
__attribute__((weak)) int botlish_event_post2(int loop, int endpoint, int slot, int gen, long long a, long long b) {
    (void)loop;
    (void)endpoint;
    (void)slot;
    (void)gen;
    (void)a;
    (void)b;
    return -38;
}

int botlish_http_notify_post(int loop, int endpoint, int slot, int gen, long long a, long long b) {
    return botlish_event_post2(loop, endpoint, slot, gen, a, b);
}
