/* notify.c -- the fixture unit's one reference to an optional provider
 * (the http unit's notify.c, with the provider of the event loop's native
 * integration ABI replaced by the fixture's provider package): a
 * foreign-thread notification posts a record through rlfp_post,
 * which the provider package's archive defines.
 *
 * How the reference is made is the build's choice (build.rs's RLF_NOTIFY),
 * so that one fixture yields every variant the milestone measures:
 *
 *   RLF_NOTIFY_WEAKDEF  a plain reference here and a weak definition in
 *                       fallback.c (-ENOSYS): a provider's strong
 *                       definition replaces it at link time
 *   RLF_NOTIFY_WEAKREF  a weak reference, tested for null: the http unit's
 *                       notify.c exactly
 *   RLF_NOTIFY_STRONG   a plain reference: without a provider, no link
 *
 * ENOSYS is the target's own (errno.h): 38 on Linux, 78 on macOS. */
#include <errno.h>

#if defined(RLF_NOTIFY_WEAKREF)
__attribute__((weak)) int rlfp_post(int tag, long long value);
#else
int rlfp_post(int tag, long long value);
#endif

int rlfshim_post(int tag, long long value) {
#if defined(RLF_NOTIFY_WEAKREF)
    if (!rlfp_post) {
        return -ENOSYS;
    }
#endif
    return rlfp_post(tag, value);
}

/* The target's ENOSYS, for the Botlish module to name the refusal. */
int rlfshim_enosys(void) {
    return ENOSYS;
}
