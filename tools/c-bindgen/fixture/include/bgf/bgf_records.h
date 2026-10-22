/* bgf_records.h -- the fixture's C records (C-BINDGEN-LAYOUTS.md, "The
 * fixture"): every record shape the layout generator decides about, in one
 * header bgf.h includes after the types it uses (bgf_point, bgf_visit,
 * bgf_measure, ...). Freestanding like the rest of the fixture. Which of
 * them become layouts, and where every field lies, is the target C
 * compiler's answer: nothing below states an offset. */
#ifndef BGF_RECORDS_H
#define BGF_RECORDS_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#include "bgf/bgf_types.h"

/* Scalars and the padding the compiler puts between them. */
typedef struct bgf_scalars {
    char c;
    int i;
    unsigned short us;
    long long ll;
    signed char sc;
    unsigned char uc;
    short s;
    unsigned int ui;
    unsigned long long ull;
} bgf_scalars;

/* What LP64 and LLP64 place differently: long is 8 bytes on Linux and
 * macOS, 4 on Windows; a pointer is 8 on all of them. */
typedef struct bgf_longs {
    char c;
    long l;
    unsigned long ul;
    long long ll;
    void *p;
    int i;
    unsigned long long ull;
} bgf_longs;

typedef struct bgf_long_pair {
    long a;
    bgf_longs inner;
    unsigned long b;
} bgf_long_pair;

/* Typedef chains and enums: resolved to the scalars the compiler confirms. */
typedef enum bgf_mode { BGF_MODE_OFF, BGF_MODE_ON = 200 } bgf_mode;
typedef struct bgf_typed {
    bgf_u8 a;
    bgf_i16 b;
    bgf_u32 c;
    bgf_u64 d;
    bgf_size e;
    bgf_color color;
    bgf_mode mode;
    bgf_flags flags;
} bgf_typed;

/* Pointers keep their pointee identities: itself, an incomplete handle,
 * void, char, a pointer to a pointer, a callback typedef, an inline
 * function pointer, and a pointer to a record whose layout is blocked (a
 * pointer is no by-value dependency). */
struct bgf_chars;
typedef struct bgf_node {
    struct bgf_node *next;
    bgf_handle *handle;
    void *data;
    const char *name;
    struct bgf_node **slot;
    bgf_visit visit;
    int (*compare)(const struct bgf_node *a, const struct bgf_node *b);
    struct bgf_chars *label;
    uint32_t id;
} bgf_node;

/* Nested by value, twice, and beside a pointer. */
typedef struct bgf_rect {
    bgf_point origin;
    bgf_point extent;
} bgf_rect;

typedef struct bgf_frame {
    int id;
    bgf_rect bounds;
    bgf_rect clip;
    bgf_node *owner;
} bgf_frame;

/* Packing and alignment: whatever the compiler makes of them. */
#pragma pack(push, 1)
typedef struct bgf_packed1 {
    uint8_t kind;
    uint32_t length;
    uint16_t crc;
} bgf_packed1;
#pragma pack(pop)

#pragma pack(push, 2)
typedef struct bgf_packed2 {
    uint8_t kind;
    uint32_t length;
    uint64_t stamp;
} bgf_packed2;
#pragma pack(pop)

typedef struct __attribute__((packed)) bgf_packed_attr {
    char tag;
    long long value;
    short code;
} bgf_packed_attr;

typedef struct __attribute__((aligned(16))) bgf_aligned {
    int x;
} bgf_aligned;

typedef struct bgf_aligned_field {
    char c;
    int v __attribute__((aligned(8)));
    bgf_aligned over;
} bgf_aligned_field;

/* A packed record nested in an unpacked one, and an unpacked record nested
 * in a packed one. */
typedef struct bgf_nested_packed {
    char lead;
    bgf_packed1 inner;
    int tail;
} bgf_nested_packed;

#pragma pack(push, 1)
typedef struct bgf_packed_outer {
    char lead;
    bgf_point inner;
    short tail;
} bgf_packed_outer;
#pragma pack(pop)

/* A member whose name a later macro rewrites (glibc's st_atime pattern):
 * the record's member is late_value, which the probes must not read as
 * code. */
typedef struct bgf_late { int code; int late_value; } bgf_late;
#define late_value code

/* Anonymous records: a typedef of an anonymous struct, a named member of an
 * anonymous struct type, and an anonymous struct member (its members are
 * the record's own, C11). */
typedef struct {
    int x;
    int y;
} bgf_anon_point;

typedef struct bgf_member_anon {
    int n;
    struct {
        short lo;
        short hi;
    } range;
} bgf_member_anon;

typedef struct bgf_promoted {
    int kind;
    struct {
        int left;
        int right;
    };
    int tail;
} bgf_promoted;

/* Names: a typedef naming one tag and a tag of the same name (two records,
 * two layouts), C names that are Botlish keywords or reserved type names,
 * several typedefs of one record (one layout). */
typedef struct bgf_coll_a { int a; } bgf_coll;
struct bgf_coll { int b; };
typedef struct bgf_kw { int fn; int type; int loop; } loop;
struct List { int size; int align; };
typedef struct bgf_multi { int v; } bgf_multi, bgf_multi_alias, *bgf_multi_ptr;
typedef bgf_multi bgf_multi2;

/* Blocked records: every representation the layout language lacks. */
typedef struct bgf_chars { int len; char name[16]; } bgf_chars;
typedef struct bgf_wide_text { int len; wchar_t text[8]; } bgf_wide_text;
typedef struct bgf_points4 { bgf_point pts[4]; } bgf_points4;
typedef struct bgf_ptrs3 { void *slots[3]; } bgf_ptrs3;
typedef struct bgf_matrix { int m[2][3]; } bgf_matrix;
typedef struct bgf_flex { size_t count; int items[]; } bgf_flex;
typedef union bgf_value { int i; unsigned int u; void *p; } bgf_value;
typedef struct bgf_tagged { int kind; bgf_value value; } bgf_tagged;
typedef struct bgf_overlay { int kind; union { int i; void *p; }; } bgf_overlay;
typedef struct bgf_bits { unsigned int a : 3; unsigned int b : 5; int rest; } bgf_bits;
typedef struct bgf_real { float f; double d; } bgf_real;
typedef struct bgf_ld { long double x; int n; } bgf_ld;
typedef struct bgf_flag { bool ok; int code; } bgf_flag;
typedef struct bgf_vol { volatile int counter; int n; } bgf_vol;
typedef struct bgf_wide_field { bgf_wide w; } bgf_wide_field;
typedef struct bgf_float_ptr { float *values; int n; } bgf_float_ptr;
typedef struct bgf_bad_callback { bgf_measure measure; int n; } bgf_bad_callback;
typedef struct bgf_ms_field { int (__attribute__((ms_abi)) *cb)(int); int n; } bgf_ms_field;

/* Blocked through what they hold by value; a pointer to a blocked record
 * blocks nothing. */
typedef struct bgf_outer_blocked { int n; bgf_chars chars; } bgf_outer_blocked;
typedef struct bgf_chain2 { bgf_outer_blocked inner; long tail; } bgf_chain2;
typedef struct bgf_points_ref { bgf_points4 *points; int n; } bgf_points_ref;
typedef struct bgf_mixed { bgf_value u; char name[4]; } bgf_mixed;
typedef struct bgf_flagged_rect { bgf_flag flag; bgf_rect rect; } bgf_flagged_rect;

/* An incomplete record: a pointee identity, never a layout. */
typedef struct bgf_secret bgf_secret;

/* Explicit calling conventions are the compiler's to judge
 * (__builtin_types_compatible_p): __stdcall is ignored on every 64-bit
 * target (MinGW's WINAPI); ms_abi is Windows x86-64's own convention and
 * another one on Linux x86-64, also through a typedef. */
extern int __attribute__((stdcall)) bgf_stdcall(int x);
#if defined(__x86_64__)
typedef int (__attribute__((ms_abi)) *bgf_ms_callback)(int);
extern int bgf_take_ms(bgf_ms_callback cb);
#endif

/* Unions (LAYOUT-UNIONS.md): a union is a union layout whose alternatives
 * are its members, each where the compiler places it; an anonymous member
 * -- a union, or a struct inside a union -- is a synthetic layout of its
 * own, held by a generated field, never flattened. Unions of scalars and
 * arrays, of a record and a scalar, of a packed record; arrays of unions,
 * one- and two-dimensional; the OVERLAPPED and LARGE_INTEGER shapes; deeper
 * anonymous nesting; a keyword alternative; a tag the synthetic name of
 * bgf_overlapped's anonymous union would take; unions wider than every
 * alternative (tail padding, an aligned union), named and anonymous; two
 * anonymous unions on one line. */
typedef union bgf_word { uint32_t whole; uint16_t halves[2]; uint8_t bytes[4]; } bgf_word;
typedef union bgf_shape { bgf_point pt; long long bits; unsigned char raw[3]; } bgf_shape;
typedef struct bgf_words3 { int n; bgf_word words[3]; } bgf_words3;
typedef struct bgf_word_grid { bgf_word grid[2][2]; short tail; } bgf_word_grid;
typedef union bgf_packed_u { bgf_packed1 p; uint8_t raw[7]; } bgf_packed_u;
typedef struct bgf_overlapped {
    uintptr_t internal;
    uintptr_t internal_high;
    union {
        struct {
            uint32_t offset;
            uint32_t offset_high;
        };
        void *pointer;
    };
    void *event;
} bgf_overlapped;
struct bgf_overlapped_member3 { int z; };
typedef union bgf_large {
    struct { uint32_t low; int32_t high; };
    struct { uint32_t low; int32_t high; } u;
    long long quad;
} bgf_large;
typedef struct bgf_deep {
    char tag;
    struct {
        short a;
        union { int b; char c[3]; };
    };
    union
    {
        struct { uint16_t x; uint16_t y; union { uint8_t z; uint16_t zz; }; };
        bgf_word w;
    };
} bgf_deep;
typedef union bgf_kwu { int fn; unsigned int type; } bgf_kwu;
typedef union bgf_tail_u { char c[5]; int i; } bgf_tail_u;
typedef union __attribute__((aligned(16))) bgf_aligned_u { int i; char c; } bgf_aligned_u;
typedef struct bgf_anon_tail { char k; union { char c[5]; int i; }; char after; } bgf_anon_tail;
typedef struct bgf_two_anon { union { char a; int b; }; union { short c; long long d; }; } bgf_two_anon;

/* Unions an alternative blocks: the alternative's own reason is the root,
 * directly, through a record, an array or an anonymous member; and a
 * representable anonymous union its record's bitfield blocks (not emitted:
 * nothing reaches it). */
typedef union bgf_num { int i; long double f; } bgf_num;
typedef union bgf_flagu { int i; bool b; } bgf_flagu;
typedef union bgf_bitsu { bgf_bits bits; int i; } bgf_bitsu;
typedef struct bgf_holds_bitsu { int n; bgf_bitsu u; } bgf_holds_bitsu;
typedef struct bgf_nums2 { bgf_num nums[2]; } bgf_nums2;
typedef struct bgf_anon_float { int k; union { int i; long double f; }; } bgf_anon_float;
typedef struct bgf_bits_overlay { unsigned int flag : 1; union { int i; char c; }; } bgf_bits_overlay;

/* Functions pointing to records (the API pressure the report counts). */
extern int bgf_rect_area(const bgf_rect *r);
extern void bgf_node_link(bgf_node *a, bgf_node *b);
extern int bgf_frames(bgf_frame **out);
extern bgf_node *bgf_node_first(void);
extern int bgf_chars_length(const bgf_chars *c);
extern bgf_secret *bgf_secret_open(void);

/* C float and double fields (C-FLOAT-FFI-MILESTONE-1.md): the brief's mixed
 * record (sizeof 24, a float aligned to 4, a double to 8), one with float
 * typedef fields, fixed arrays of each (a float's stride is 4), a union of
 * both with an int, an anonymous union of a float; the compiler gives every
 * size, alignment and offset. */
typedef struct bgf_mixed_floats { uint8_t tag; float a; double b; float c; } bgf_mixed_floats;
typedef struct bgf_mixed_real { float x; double y; bgf_scalar32 z; bgf_real32 w; bgf_scalar64 v; } bgf_mixed_real;
typedef struct bgf_samples { float xs[4]; double ys[2][2]; int n; } bgf_samples;
typedef union bgf_fnum { int i; float f; double d; } bgf_fnum;
typedef struct bgf_anon_fnum { int k; union { unsigned int u; float f; }; } bgf_anon_fnum;

#endif
