/* raw_oracle.c -- tests/raven.test's C oracle for raven-raw
 * (RAW-C-FLOAT-FFI-MILESTONE-1.md): the steps tests/raven/raw.bot takes,
 * made by a C program against the same libraven.so -- a slider's and a spin
 * box's value set and read back -- printing the bits C reads after each
 * step, so the test compares Botlish's raw values with C's own. The step a
 * Botlish slider refuses (a NaN, before Raven runs) is no call here either.
 * Test infrastructure only: built and run by raven-raw. */

#include <Raven.h>
#include <inttypes.h>
#include <stdio.h>
#include <string.h>

static uint32_t float_bits(float x) {
    uint32_t u;
    memcpy(&u, &x, sizeof u);
    return u;
}

static uint64_t double_bits(double x) {
    uint64_t u;
    memcpy(&u, &x, sizeof u);
    return u;
}

static float float_of(uint32_t u) {
    float x;
    memcpy(&x, &u, sizeof x);
    return x;
}

static double double_of(uint64_t u) {
    double x;
    memcpy(&x, &u, sizeof x);
    return x;
}

int main(void) {
    RInitDesc desc;
    memset(&desc, 0, sizeof desc);
    desc.backend = R_BACKEND_NULL;
    desc.headless = 1;
    if (!Rinit_ex(&desc)) return 1;
    Rid w = Rwindow_create("Raw", 320, 200, 0);
    Rid box = Rwidget_create(R_WIDGET_VBOX);
    Rid s = Rwidget_create(R_WIDGET_SLIDER);
    Rid b = Rwidget_create(R_WIDGET_SPIN_BOX);
    Rslider_set_range(s, -1.0f, 1.0f);
    Rspin_box_set_range(b, -10.0, 10.0);
    Rwidget_add_child(box, s);
    Rwidget_add_child(box, b);
    Rwindow_set_content(w, box);
    Rslider_set_value(s, 0.5f);
    printf("%" PRIu32, float_bits(Rslider_get_value(s)));
    Rslider_set_value(s, float_of(0x80000000u));
    printf(" %" PRIu32, float_bits(Rslider_get_value(s)));
    Rslider_set_value(s, float_of(1u));
    printf(" %" PRIu32, float_bits(Rslider_get_value(s)));
    printf(" %" PRIu32, float_bits(Rslider_get_value(s)));
    Rslider_set_value(s, (float)0.1);
    printf(" %" PRIu32, float_bits(Rslider_get_value(s)));
    Rspin_box_set_value(b, 2.5);
    printf(" %" PRIu64, double_bits(Rspin_box_get_value(b)));
    Rspin_box_set_value(b, double_of(0x7ff8000000000001ull));
    printf(" %" PRIu64, double_bits(Rspin_box_get_value(b)));
    Rspin_box_set_value(b, double_of(0x8000000000000000ull));
    printf(" %" PRIu64, double_bits(Rspin_box_get_value(b)));
    Rspin_box_set_value(b, double_of(0x7ff0000000000000ull));
    printf(" %" PRIu64, double_bits(Rspin_box_get_value(b)));
    Rspin_box_set_range(b, double_of(0xfff0000000000000ull), double_of(0x7ff0000000000000ull));
    Rspin_box_set_value(b, double_of(0x7ff0000000000000ull));
    printf(" %" PRIu64, double_bits(Rspin_box_get_value(b)));
    int drawn = Rdraw_frame();
    printf(" %d", drawn);
    printf(" %" PRIu64, double_bits(Rspin_box_get_value(b)));
    Rspin_box_set_value(b, double_of(0xfff0000000000000ull));
    printf(" %" PRIu64, double_bits(Rspin_box_get_value(b)));
    Rspin_box_set_range(b, 0.0, 1.0);
    printf(" %" PRIu64 "\n", double_bits(Rspin_box_get_value(b)));
    Rshutdown();
    return 0;
}
