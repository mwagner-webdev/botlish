# unicodechar.tcl -- the UnicodeChar scalar type's one native primitive.
#
# UnicodeChar is a builtin semantic scalar (core/value.tcl, core/type.tcl),
# distinct from Int and String; see UNICODE-CHAR-LITERALS.md. The only
# operation that observes a UnicodeChar's numeric scalar value is total,
# never fails, and returns a plain Int -- exactly char::codepoint's
# contract (lib/char.bot wraps this root native under the "char" namespace,
# the same way lib/byte.bot wraps core/scalarbits.tcl's bit_and et al.).
#
# This file, like scalarbits.tcl, is sourced unconditionally by core.tcl:
# the native is a core language primitive, even though its namespaced
# surface spelling char::codepoint is only reachable once a program's
# qualified reference pulls in lib/char.bot (surface/modules.tcl) -- the
# same split as byte::high_nibble/bit_and.

namespace eval core::unicodechar {}

proc core::unicodechar::codepoint {c} {
    set c [core::value::expect UnicodeChar $c char_codepoint]
    return [core::value::int [core::value::charOf $c]]
}

core::native::register char_codepoint -arity 1 -impl core::unicodechar::codepoint \
    -param-types {UnicodeChar} -result-type int -result-range nonneg -context-free 1
