/* bgf.c -- the implementation of the binding generator's synthetic fixture
 * (include/bgf/bgf.h; C-BINDGEN.md, "The synthetic fixture"). Compiled
 * into libbgf.a by the generator's tests; the generator itself reads only
 * the header. Every function returns something its arguments determine, so
 * a Botlish caller of the generated binding and a C caller of the header
 * can be compared value for value. */
#include "bgf/bgf.h"

struct bgf_handle { int id; };
struct bgf_window_ { int id; };

static struct bgf_handle handles[2] = {{1}, {2}};
static struct bgf_window_ windows[2] = {{10}, {20}};
static bgf_handle *handle_list[3] = {&handles[0], &handles[1], 0};
static bgf_free_fn *saved_free;
static bgf_measure saved_measure;

int bgf_add(int a, int b) { return a + b; }

bgf_size bgf_length(const char *text) {
    bgf_size n = 0;
    while (text[n]) n++;
    return n;
}

bgf_u32 bgf_mix(bgf_u8 a, bgf_i16 b, bgf_u32 c, bgf_u64 d, long e, unsigned long long f) {
    return (bgf_u32)(a * 3u + (bgf_u32)b * 5u + c * 7u + (bgf_u32)d * 11u + (bgf_u32)e * 13u + (bgf_u32)f * 17u);
}

bgf_handle *bgf_open(const char *name, bgf_u32 flags) {
    return name[0] == 'a' ? &handles[flags & 1] : 0;
}

void bgf_close(bgf_handle *handle) { (void)handle; }

bgf_window *bgf_window_of(bgf_handle *handle) {
    return handle ? &windows[handle->id - 1] : 0;
}

int bgf_count(void) { return 2; }

char bgf_plain_char(char c) { return (char)(c + 1); }

bool bgf_is_even(int n) { return n % 2 == 0; }

bool bgf_flip(bool b) { return !b; }

bgf_color bgf_next_color(bgf_color c) {
    return c == BGF_RED ? BGF_GREEN : c == BGF_GREEN ? BGF_BLUE : BGF_RED;
}

int bgf_walk(bgf_handle *handle, bgf_visit visit, void *userdata) {
    return visit ? visit(userdata, handle, 1) : -1;
}

void bgf_set_free(bgf_free_fn *free_fn) { saved_free = free_fn; }

int bgf_point_sum(const bgf_point *point) { return point->x + point->y; }

int bgf_fill(unsigned char *out, size_t count, unsigned char seed) {
    for (size_t i = 0; i < count; i++) out[i] = (unsigned char)(seed + 37 * i);
    return (int)count;
}

int bgf_keywords(int fn, int type, int in, int loop, int str) {
    return fn * 10000 + type * 1000 + in * 100 + loop * 10 + str;
}

int bgf_unnamed(int n, const char *s) { return n + (s ? s[0] : 0); }

bgf_handle **bgf_handles(void) { return handle_list; }

unsigned char *bgf_digest(const unsigned char *data, size_t len, unsigned char out[4]) {
    unsigned char h[4] = {1, 2, 3, 4};
    for (size_t i = 0; i < len; i++) h[i % 4] = (unsigned char)(h[i % 4] * 31 + data[i]);
    for (int i = 0; i < 4; i++) out[i] = h[i];
    return out;
}

int bgf_twins(bgf_twin *a, struct bgf_twin *b) { return (a != 0) + 2 * (b != 0) + 40; }

int bgf_handle_id(bgf_handle *handle) { return handle->id; }

int bgf_labeled(int x) { return x * 3; }

int bgf_renamed(int x) { return x * 5; }

int bgf_current(int x) { return x * 7; }

double bgf_scale(double x, float y) { return x * y; }

bgf_pair bgf_swap(bgf_pair p) { bgf_pair q = {p.b, p.a}; return q; }

/* A variadic callee that reads its trailing arguments as FORMAT says: each
 * `d` an int, `l` a long, `f` a double (its whole part), `p` a pointer
 * (counted when non-null); the sum of what it read
 * (VARIADICS-VERTICAL-SLICE-1.md). */
int bgf_printf(const char *format, ...) {
    va_list ap;
    va_start(ap, format);
    long sum = 0;
    for (const char *c = format; *c; c++) {
        switch (*c) {
        case 'd': sum += va_arg(ap, int); break;
        case 'l': sum += va_arg(ap, long); break;
        case 'f': sum += (long)va_arg(ap, double); break;
        case 'p': sum += va_arg(ap, void *) != 0; break;
        default: break;
        }
    }
    va_end(ap);
    return (int)sum;
}

int bgf_vprintf(const char *format, va_list args) { (void)format; (void)args; return 0; }

int (bgf_vshadow)(int n, ...) { return n; }

int bgf_vother(int n, ...) { return n; }

void bgf_set_measure(bgf_measure measure) { saved_measure = measure; }

#if defined(__x86_64__)
int __attribute__((ms_abi)) bgf_ms(int x) { return x; }
#endif

void bgf_wide_set(bgf_wide w) { (void)w; }

int bgf_noproto() { return 0; }

void bgf_float_out(float *out) { *out = 1.5f; }

/* The table the bgf_get macro reads, and same-named functions that are not
 * the API: a binding that linked bgf_get or bgf_shadowed directly would
 * call these. */
static int table_get(int x) { return x * 10; }
static const bgf_table table = { table_get };
const bgf_table *bgf_table_ptr = &table;
#undef bgf_get
int bgf_get(int x) { return -x; }
#undef bgf_shadowed
int bgf_shadowed(int x) { return -x; }

#if defined(__linux__)
int bgf_linux_only(void) { return 1; }
#endif
#if defined(__APPLE__)
int bgf_apple_only(void) { return 1; }
#endif
#if defined(__aarch64__)
int bgf_arm_only(void) { return 1; }
#endif

/* bgf_records.h's functions. */
int bgf_rect_area(const bgf_rect *r) { return r->extent.x * r->extent.y; }
void bgf_node_link(bgf_node *a, bgf_node *b) { a->next = b; }
int bgf_frames(bgf_frame **out) { *out = 0; return 0; }
bgf_node *bgf_node_first(void) { return 0; }
int bgf_chars_length(const bgf_chars *c) { return c->len; }
bgf_secret *bgf_secret_open(void) { return 0; }
int __attribute__((stdcall)) bgf_stdcall(int x) { return x + 1; }
#if defined(__x86_64__)
int bgf_take_ms(bgf_ms_callback cb) { return cb == 0; }
#endif

/* C float and double (bgf.h's last section, C-FLOAT-FFI-MILESTONE-1.md). */
bgf_real32 bgf_scale32(bgf_scalar32 x, bgf_scalar64 k) { return (float)(x * k); }
double bgf_dot(const float *xs, const double *ys, size_t n) {
    double s = 0.0;
    for (size_t i = 0; i < n; i++) s += (double)xs[i] * ys[i];
    return s;
}
float bgf_apply_float(bgf_float_fn f, float x) { return f(x); }
static float halve(float x) { return x / 2.0f; }
bgf_float_fn bgf_halver(void) { return halve; }
double bgf_sum_mixed(const bgf_mixed_floats *m) { return m->tag + m->a + m->b + m->c; }
long double bgf_long_scale(long double x) { return x * 2; }
double bgf_long_ptr(long double *x) { return (double)*x; }
