/* notify-stub.c -- a stand-in for the event loop driver's adapter in the
 * http link probe on macOS (HTTP-MACOS-RUST-ARCHIVE-LINK-FEASIBILITY-
 * MILESTONE-1.md, "The http unit"): the one symbol the unit's notify.c
 * references, botlish_event_post2 (botlish_event_loop.h, version 2), and a
 * count of the posts it received. No macOS driver exists yet; the probe
 * links the unit with and without this stand-in. */
static long long posts;

int botlish_event_post2(int loop, int endpoint, int slot, int gen, long long a, long long b) {
    (void)loop; (void)endpoint; (void)slot; (void)gen; (void)a; (void)b;
    posts += 1;
    return 0;
}

long long notify_stub_posts(void) {
    return posts;
}
