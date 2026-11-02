# unicodechar.tcl -- the UnicodeChar scalar type's one native primitive.
#
# UnicodeChar is a builtin semantic scalar (core/value.tcl, core/type.tcl),
# distinct from Int and String; see UNICODE-CHAR-LITERALS.md. The only
# operation that observes a UnicodeChar's numeric scalar value is total,
# never fails, and returns a plain Int, a Unicode scalar value
# (0..0x10FFFF without the surrogates: its -result-range, which the range,
# completion and emission analyses read): std::char::scalar_value, a root native
# registered under its qualified `char` name (core::native::isQualifiedNative;
# STDLIB-NAMESPACES.md -- before that milestone the root name
# `char_codepoint`, wrapped by a stdlib/char.bot `std::char::codepoint`; the one
# canonical name is now std::char::scalar_value, which says exactly what it
# returns -- a Unicode scalar value, never a byte or a Latin-1 code). Like
# every native's, its UnicodeChar parameter is checked when the call runs;
# an untyped Botlish parameter forwarded to it is inferred UnicodeChar and
# checked statically at its own call sites
# (INTRINSIC-FUNCTION-CONTRACT-INFERENCE.md).
#
# This file, like scalarbits.tcl, is sourced unconditionally by core.tcl:
# the native is a core language primitive.

namespace eval core::unicodechar {}

proc core::unicodechar::scalar_value {c} {
    set c [core::value::expect UnicodeChar $c std::char::scalar_value]
    return [core::value::int [core::value::charOf $c]]
}

# Its -result-range is the set of Unicode scalar values, 0..0x10FFFF without
# the surrogates 0xD800..0xDFFF: the implementation's contract, which both
# runtimes uphold by construction -- a UnicodeChar is made only through
# core::value's isValidScalar (core/value.tcl) and, natively, Rust's `char`
# (native/src/runtime/value.rs), neither of which admits a surrogate
# (tests/interval-sets.test's is-scalar-value checks hold both to it). The
# range analysis reads the hull 0..0x10FFFF; the interval-set facts the
# emission checker reads see the gap (EMISSION-CLAIMS-MILESTONE-1.md,
# "Native result sets").
core::native::register std::char::scalar_value -arity 1 -impl core::unicodechar::scalar_value \
    -param-types {UnicodeChar} -result-type int -result-range {intervals {0 0xD7FF} {0xE000 0x10FFFF}} -context-free 1
