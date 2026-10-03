# unicodechar.tcl -- the UnicodeChar scalar type's one native primitive.
#
# UnicodeChar is a builtin semantic scalar (core/value.tcl, core/type.tcl),
# distinct from Int and String; see UNICODE-CHAR-LITERALS.md. The only
# operation that observes a UnicodeChar's numeric scalar value is total,
# never fails, and returns a plain Int: char::scalar_value, a root native
# registered under its qualified `char` name (core::native::isQualifiedNative;
# STDLIB-NAMESPACES.md -- before that milestone the root name
# `char_codepoint`). lib/char.bot's char::codepoint is its typed wrapper:
# the same operation with a compile-time `c: UnicodeChar` contract, the
# way lib/byte.bot's functions wrap core/scalarbits.tcl's bit_and et al.
#
# This file, like scalarbits.tcl, is sourced unconditionally by core.tcl:
# the native is a core language primitive.

namespace eval core::unicodechar {}

proc core::unicodechar::codepoint {c} {
    set c [core::value::expect UnicodeChar $c char::scalar_value]
    return [core::value::int [core::value::charOf $c]]
}

core::native::register char::scalar_value -arity 1 -impl core::unicodechar::codepoint \
    -param-types {UnicodeChar} -result-type int -result-range nonneg -context-free 1
