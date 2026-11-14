/* fallback.c -- the weak definition of the optional provider's function
 * (RLF_NOTIFY_WEAKDEF, notify.c): a post with no provider linked is refused
 * with the target's -ENOSYS. A strong definition anywhere in the link (the
 * provider package's archive) replaces it. In a translation unit of its
 * own, so that no compiler sees the definition at the call. */
#include <errno.h>

__attribute__((weak)) int rlfp_post(int tag, long long value) {
    (void)tag;
    (void)value;
    return -ENOSYS;
}
