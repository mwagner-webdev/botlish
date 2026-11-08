/*
 * botlish_rt_v1_int_arena.c -- a provider of the Int services of the
 * Botlish C runtime-service interface, version 1 (botlish_rt_v1.h).
 *
 * C-COMPILE-FREESTANDING-MILESTONE-1.md, "Supplied-service integration":
 * an independent implementation of the int.* services, outside the
 * compiler, that a generated program links against. It is freestanding
 * C11 (no allocation, no library call): big numbers live in a fixed static
 * arena, so it suits a device with no heap. When the arena is full a
 * service reports BOTLISH_RT_V1_LIMIT -- it never returns a wrong value.
 *
 * Its numbers are sign and magnitude, the magnitude 32-bit limbs, least
 * significant first, with no leading zero limb. Every result that fits
 * int64_t is returned small (the interface's normalization rule). The
 * arena is never freed: a big number stays valid until the program ends
 * (an embedding that runs a program again may call
 * botlish_rt_v1_int_arena_reset between runs, when it holds no value of
 * the previous run).
 *
 * The algorithms are the schoolbook ones (addition, subtraction,
 * multiplication, bitwise long division): correct and short, not fast.
 * Its scratch numbers are static, so it serves one program thread.
 *
 * Capacity: BOTLISH_RT_INT_ARENA_LIMBS 32-bit limbs and
 * BOTLISH_RT_INT_ARENA_NUMBERS numbers, overridable with -D.
 */
#include "botlish_rt_v1.h"

#ifndef BOTLISH_RT_INT_ARENA_LIMBS
#define BOTLISH_RT_INT_ARENA_LIMBS 65536
#endif
#ifndef BOTLISH_RT_INT_ARENA_NUMBERS
#define BOTLISH_RT_INT_ARENA_NUMBERS 8192
#endif
/* The largest magnitude one operation handles, in limbs (a scratch bound). */
#define MAX_LIMBS 512

struct botlish_rt_v1_bignum {
    bool negative;
    size_t length;
    const uint32_t *limbs;
};

static uint32_t limb_arena[BOTLISH_RT_INT_ARENA_LIMBS];
static size_t limbs_used;
static struct botlish_rt_v1_bignum number_arena[BOTLISH_RT_INT_ARENA_NUMBERS];
static size_t numbers_used;

/* Forgets every big number made so far (none may still be in use). */
void botlish_rt_v1_int_arena_reset(void);
void botlish_rt_v1_int_arena_reset(void)
{
    limbs_used = 0;
    numbers_used = 0;
}

/* A magnitude being computed: limbs, least significant first. */
typedef struct {
    bool negative;
    size_t length;
    uint32_t limbs[MAX_LIMBS];
} work;

static void trim(work *w)
{
    while (w->length > 0 && w->limbs[w->length - 1] == 0) {
        w->length--;
    }
    if (w->length == 0) {
        w->negative = false;
    }
}

/* The value V as a work number. */
static void load(botlish_rt_v1_int v, work *w)
{
    size_t k;
    if (v.big == NULL) {
        uint64_t magnitude = v.small < 0 ? (uint64_t)0 - (uint64_t)v.small : (uint64_t)v.small;
        w->negative = v.small < 0;
        w->limbs[0] = (uint32_t)(magnitude & 0xFFFFFFFFu);
        w->limbs[1] = (uint32_t)(magnitude >> 32);
        w->length = 2;
        trim(w);
        return;
    }
    w->negative = v.big->negative;
    w->length = v.big->length;
    for (k = 0; k < w->length; k++) {
        w->limbs[k] = v.big->limbs[k];
    }
}

/* W as an Int: small when it fits int64_t, else a new arena number. */
static botlish_rt_v1_status store(work *w, botlish_rt_v1_int *result)
{
    struct botlish_rt_v1_bignum *n;
    uint32_t *limbs;
    size_t k;
    trim(w);
    if (w->length <= 2) {
        uint64_t magnitude = w->length == 0 ? 0 : w->limbs[0];
        if (w->length == 2) {
            magnitude |= (uint64_t)w->limbs[1] << 32;
        }
        if (!w->negative && magnitude <= (uint64_t)INT64_MAX) {
            result->small = (int64_t)magnitude;
            result->big = NULL;
            return BOTLISH_RT_V1_OK;
        }
        if (w->negative && magnitude <= (uint64_t)INT64_MAX + 1u) {
            result->small = magnitude == (uint64_t)INT64_MAX + 1u ? INT64_MIN : -(int64_t)magnitude;
            result->big = NULL;
            return BOTLISH_RT_V1_OK;
        }
    }
    if (numbers_used == BOTLISH_RT_INT_ARENA_NUMBERS
            || BOTLISH_RT_INT_ARENA_LIMBS - limbs_used < w->length) {
        return BOTLISH_RT_V1_LIMIT;
    }
    limbs = &limb_arena[limbs_used];
    limbs_used += w->length;
    for (k = 0; k < w->length; k++) {
        limbs[k] = w->limbs[k];
    }
    n = &number_arena[numbers_used++];
    n->negative = w->negative;
    n->length = w->length;
    n->limbs = limbs;
    result->small = 0;
    result->big = n;
    return BOTLISH_RT_V1_OK;
}

/* The order of the magnitudes of A and B. */
static int compare_magnitude(const work *a, const work *b)
{
    size_t k;
    if (a->length != b->length) {
        return a->length < b->length ? -1 : 1;
    }
    for (k = a->length; k > 0; k--) {
        if (a->limbs[k - 1] != b->limbs[k - 1]) {
            return a->limbs[k - 1] < b->limbs[k - 1] ? -1 : 1;
        }
    }
    return 0;
}

/* r = |a| + |b| (sign left to the caller); 0 on success. */
static bool add_magnitude(const work *a, const work *b, work *r)
{
    size_t n = a->length > b->length ? a->length : b->length;
    uint64_t carry = 0;
    size_t k;
    if (n + 1 > MAX_LIMBS) {
        return false;
    }
    for (k = 0; k < n; k++) {
        uint64_t sum = carry;
        if (k < a->length) sum += a->limbs[k];
        if (k < b->length) sum += b->limbs[k];
        r->limbs[k] = (uint32_t)(sum & 0xFFFFFFFFu);
        carry = sum >> 32;
    }
    r->limbs[n] = (uint32_t)carry;
    r->length = n + 1;
    return true;
}

/* r = |a| - |b|, given |a| >= |b|. */
static void sub_magnitude(const work *a, const work *b, work *r)
{
    uint32_t borrow = 0;
    size_t k;
    for (k = 0; k < a->length; k++) {
        uint64_t subtrahend = (uint64_t)borrow + (k < b->length ? b->limbs[k] : 0u);
        uint64_t minuend = a->limbs[k];
        if (minuend >= subtrahend) {
            r->limbs[k] = (uint32_t)(minuend - subtrahend);
            borrow = 0;
        } else {
            r->limbs[k] = (uint32_t)(minuend + ((uint64_t)1 << 32) - subtrahend);
            borrow = 1;
        }
    }
    r->length = a->length;
}

/* r = a + b with signs; false when the scratch bound is exceeded. */
static bool signed_add(const work *a, const work *b, work *r)
{
    if (a->negative == b->negative) {
        if (!add_magnitude(a, b, r)) {
            return false;
        }
        r->negative = a->negative;
    } else if (compare_magnitude(a, b) >= 0) {
        sub_magnitude(a, b, r);
        r->negative = a->negative;
    } else {
        sub_magnitude(b, a, r);
        r->negative = b->negative;
    }
    trim(r);
    return true;
}

botlish_rt_v1_status botlish_rt_v1_int_add(botlish_rt_v1_int a, botlish_rt_v1_int b,
    botlish_rt_v1_int *result)
{
    static work x, y, r;
    load(a, &x);
    load(b, &y);
    if (!signed_add(&x, &y, &r)) {
        return BOTLISH_RT_V1_LIMIT;
    }
    return store(&r, result);
}

botlish_rt_v1_status botlish_rt_v1_int_sub(botlish_rt_v1_int a, botlish_rt_v1_int b,
    botlish_rt_v1_int *result)
{
    static work x, y, r;
    load(a, &x);
    load(b, &y);
    if (y.length > 0) {
        y.negative = !y.negative;
    }
    if (!signed_add(&x, &y, &r)) {
        return BOTLISH_RT_V1_LIMIT;
    }
    return store(&r, result);
}

botlish_rt_v1_status botlish_rt_v1_int_mul(botlish_rt_v1_int a, botlish_rt_v1_int b,
    botlish_rt_v1_int *result)
{
    static work x, y, r;
    size_t i, j;
    load(a, &x);
    load(b, &y);
    if (x.length + y.length > MAX_LIMBS) {
        return BOTLISH_RT_V1_LIMIT;
    }
    r.length = x.length + y.length;
    for (i = 0; i < r.length; i++) {
        r.limbs[i] = 0;
    }
    for (i = 0; i < x.length; i++) {
        uint64_t carry = 0;
        for (j = 0; j < y.length; j++) {
            uint64_t t = (uint64_t)x.limbs[i] * y.limbs[j] + r.limbs[i + j] + carry;
            r.limbs[i + j] = (uint32_t)(t & 0xFFFFFFFFu);
            carry = t >> 32;
        }
        r.limbs[i + y.length] = (uint32_t)carry;
    }
    r.negative = x.negative != y.negative;
    return store(&r, result);
}

/* r = |a| mod |b| (|b| > 0), by bitwise long division. */
static void mod_magnitude(const work *a, const work *b, work *r)
{
    size_t k;
    int bit;
    r->negative = false;
    r->length = 0;
    for (k = a->length; k > 0; k--) {
        for (bit = 31; bit >= 0; bit--) {
            /* r = 2r + bit */
            uint32_t carry = (a->limbs[k - 1] >> bit) & 1u;
            size_t m;
            for (m = 0; m < r->length; m++) {
                uint32_t out = r->limbs[m] >> 31;
                r->limbs[m] = (r->limbs[m] << 1) | carry;
                carry = out;
            }
            if (carry != 0) {
                r->limbs[r->length++] = carry;
            }
            if (compare_magnitude(r, b) >= 0) {
                sub_magnitude(r, b, r);
                trim(r);
            }
        }
    }
}

botlish_rt_v1_status botlish_rt_v1_int_mod(botlish_rt_v1_int a, botlish_rt_v1_int b,
    botlish_rt_v1_int *result)
{
    static work x, y, r, e;
    load(a, &x);
    load(b, &y);
    if (y.length == 0) {
        /* The interface's caller guarantees b != 0. */
        return BOTLISH_RT_V1_LIMIT + 1;
    }
    mod_magnitude(&x, &y, &r);
    if (x.negative && r.length > 0) {
        /* Euclidean: |b| - r. */
        y.negative = false;
        sub_magnitude(&y, &r, &e);
        e.negative = false;
        return store(&e, result);
    }
    return store(&r, result);
}

int botlish_rt_v1_int_compare(botlish_rt_v1_int a, botlish_rt_v1_int b)
{
    static work x, y;
    int order;
    load(a, &x);
    load(b, &y);
    if (x.negative != y.negative) {
        return x.negative ? -1 : 1;
    }
    order = compare_magnitude(&x, &y);
    return x.negative ? -order : order;
}

botlish_rt_v1_status botlish_rt_v1_int_from_decimal(const char *digits, size_t length,
    botlish_rt_v1_int *result)
{
    static work r;
    size_t k = 0;
    bool negative = false;
    if (length > 0 && digits[0] == '-') {
        negative = true;
        k = 1;
    }
    r.length = 0;
    for (; k < length; k++) {
        uint64_t carry = (uint64_t)(digits[k] - '0');
        size_t m;
        for (m = 0; m < r.length; m++) {
            uint64_t t = (uint64_t)r.limbs[m] * 10u + carry;
            r.limbs[m] = (uint32_t)(t & 0xFFFFFFFFu);
            carry = t >> 32;
        }
        if (carry != 0) {
            if (r.length == MAX_LIMBS) {
                return BOTLISH_RT_V1_LIMIT;
            }
            r.limbs[r.length++] = (uint32_t)carry;
        }
    }
    r.negative = negative;
    return store(&r, result);
}

size_t botlish_rt_v1_int_to_decimal(botlish_rt_v1_int value, char *buffer, size_t capacity)
{
    static work x;
    /* Base-10^9 digits, least significant first: MAX_LIMBS limbs need at
     * most MAX_LIMBS * 32 / 29.9 + 1 of them. */
    static uint32_t chunks[MAX_LIMBS * 32 / 29 + 2];
    size_t count = 0, length = 0, k;
    load(value, &x);
    if (x.negative) {
        if (length < capacity) buffer[length] = '-';
        length++;
    }
    do {
        uint64_t remainder = 0;
        for (k = x.length; k > 0; k--) {
            uint64_t current = (remainder << 32) | x.limbs[k - 1];
            x.limbs[k - 1] = (uint32_t)(current / 1000000000u);
            remainder = current % 1000000000u;
        }
        trim(&x);
        chunks[count++] = (uint32_t)remainder;
    } while (x.length > 0);
    for (k = count; k > 0; k--) {
        char digits[9];
        uint32_t chunk = chunks[k - 1];
        int d, first = 0;
        for (d = 8; d >= 0; d--) {
            digits[d] = (char)('0' + chunk % 10u);
            chunk /= 10u;
        }
        if (k == count) {
            while (first < 8 && digits[first] == '0') first++;
        }
        for (d = first; d < 9; d++) {
            if (length < capacity) buffer[length] = digits[d];
            length++;
        }
    }
    return length;
}
