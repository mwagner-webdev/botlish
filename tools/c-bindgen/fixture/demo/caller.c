/* caller.c -- the C caller of the fixture's own API that demo.bot is
 * compared with (C-BINDGEN.md, "The synthetic fixture"): the same calls, in
 * C, printed as Botlish prints demo.bot's list. */
#include <stdio.h>
#include <string.h>
#include "bgf/bgf.h"

static const char *b(bool x) { return x ? "true" : "false"; }

int main(void) {
    bgf_handle *handle = bgf_open("alpha", 1);
    bgf_window *window = bgf_window_of(handle);
    bgf_handle *missing = bgf_open("beta", 1);
    unsigned char fill[3] = {0, 0, 0};
    int filled = bgf_fill(fill, 3, 7);
    unsigned char out[4] = {0, 0, 0, 0};
    bgf_digest((const unsigned char *)"abc", 3, out);
    int handle_id = bgf_handle_id(handle);
    int summed = bgf_printf("dldfp", 5, -7L, 30, 2.75, (void *)0);
    int printed = bgf_print("dd", 7, 8);
    bgf_close(handle);
    printf("[%d, %ld, %u, %d, %d, %d, %d, %d, %s, %s, %d, %d, %d, %d, %d, %d, %d, %d, %d, %u, %llu, %ld, %d, %d, %u, %u, %s, %s, %s, %s, %d, %d, %d, %d, %d]\n",
        bgf_add(2, 3), (long)bgf_length("hello"), bgf_mix(1, -2, 3, 4, -5, 6), bgf_count(),
        bgf_plain_char(65), bgf_keywords(1, 2, 3, 4, 5), bgf_unnamed(10, 0), filled,
        b(fill[0] == 7 && fill[1] == 44 && fill[2] == 81), b(out[0] == 128 && out[1] == 160 && out[2] == 192 && out[3] == 4), bgf_labeled(2), bgf_renamed(2), bgf_current(2),
        bgf_legacy(2), bgf_call_add(20, 22), bgf_square(7), BGF_TWICE(21), bgf_get(3), bgf_shadowed(1),
        BGF_FLAG_ALL, (unsigned long long)BGF_BIG, (long)BGF_SIZE_NONE, BGF_NEGATIVE, BGF_CHAR,
        (unsigned)BGF_BLUE, (unsigned)bgf_next_color(BGF_GREEN),
        b(window == 0), b(missing == 0), b(bgf_is_even(4)), b(bgf_flip(true)),
        handle_id, bgf_twins(0, 0), BGF_HIGH_CHAR, summed, printed);
    return 0;
}
