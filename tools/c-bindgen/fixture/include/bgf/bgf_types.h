/* bgf_types.h -- the fixture's scalar typedefs and opaque handles, in a
 * header of their own, included by bgf.h (C-BINDGEN.md, "The synthetic
 * fixture"). */
#ifndef BGF_TYPES_H
#define BGF_TYPES_H

#include <stddef.h>
#include <stdint.h>

#ifdef __APPLE__
#define BGF_LABEL_PREFIX "_"
#else
#define BGF_LABEL_PREFIX ""
#endif
#define BGF_UINT64_C(c) UINT64_C(c)

typedef uint8_t bgf_u8;
typedef int16_t bgf_i16;
typedef uint32_t bgf_u32;
typedef uint64_t bgf_u64;
typedef ptrdiff_t bgf_size;
typedef bgf_u32 bgf_flags;

/* Opaque handles: a struct tag never completed, named by a typedef of the
 * same name, and one whose typedef hides the pointer. */
typedef struct bgf_handle bgf_handle;
typedef struct bgf_window_ *bgf_window_ref;
typedef struct bgf_window_ bgf_window;

/* A function of this header: its module uses bgf_handle too, which has one
 * identity however many modules point to it. */
extern int bgf_handle_id(bgf_handle *handle);

/* C floating typedef chains (C-FLOAT-FFI-MILESTONE-1.md): bgf_real32 is a
 * typedef of a typedef of float; the compiler confirms what each names. */
typedef float bgf_scalar32;
typedef bgf_scalar32 bgf_real32;
typedef double bgf_scalar64;

#endif
