# enums.tcl -- payload-bearing enum cases (PORTABILITY-PAYLOAD-ENUMS-
# MILESTONE-1.md; ENUMS.md).
#
#   enum#case(PAYLOAD, "ID", "CASE")   the value of the payload-bearing case
#                                      CASE of the enum declared as ID,
#                                      carrying PAYLOAD
#
# The one runtime operation of a payload-bearing case: hir/resolve.tcl
# writes every construction `E::C {field: value, ...}` as a call of this
# internal root native (no source spells `enum#case`) whose first argument
# is the payload -- an ordinary anonymous struct construction, checked
# against the case's declared payload fields exactly as a named
# construction is (`casePayloadOf`) -- and whose two String constants name
# the enum's declaration identity and the case, both decided by resolution.
# Its static type is the enum's ({enum ID}: -result-shape {enum-case 1},
# hir::types::ShapeResult), never the payload's or a case's own: a case is a
# value of its enum, no subtype of it.
#
# The value is {enum ID CASE PAYLOAD} (core/value.tcl): the payload-free
# form {enum ID CASE} with the payload as a fourth component, so the
# identity (ID, CASE) stays the first two components of every case value
# and a payload-free case keeps the form it always had. Nothing here reads a
# case's position, and nothing is a discriminant.

namespace eval core::enums {}

proc core::enums::caseImpl {payload id case} {
    return [core::value::enumCaseValue [core::value::strOf $id] [core::value::strOf $case] $payload]
}

# The payload moves into the value (an affine payload's ownership with it:
# AFFINE-VALUES.md); the two names are constants.
core::native::register enum#case -arity 3 -impl core::enums::caseImpl \
    -param-types {struct str str} -result-type enum -result-shape {enum-case 1} \
    -context-free 1 -ownership {move erase erase}

# Case selection (PORTABILITY-EXHAUSTIVE-MATCH-MILESTONE-1.md)
# -------------------------------------------------------------
#   enum#is(VALUE, "ID", "CASE")       1 if VALUE is a value of case CASE of
#                                      the enum declared as ID
#   enum#payload(VALUE, "ID", "CASE")  the payload of VALUE, a value of that
#                                      case (unit for a payload-free case)
#   enum#unmatched()                   the end of a match no arm selected
#
# The three runtime operations of a match: hir/resolve.tcl writes every
# `match` (surface/lower.tcl's Match) as a chain of case tests -- an `if`
# per arm testing enum#is, whose then-branch takes the payload out with
# enum#payload first -- ending in enum#unmatched, which an exhaustive
# match never reaches (hir/match.tcl proves every case is named; it is the
# dead-code placeholder context#unreachable is for contexts). No source
# spells them. Selection reads the value's identity (ID, CASE) only: never
# its payload, never `==` -- a value whose payload is not comparable (a
# function, a mutable collection, an affine value) is selected the same
# way -- and never a position.
#
# enum#payload is called only where its own enum#is selected the case
# (hir::match::verify checks every call is): it still checks the identity
# itself, so a program run despite a rejected match (a lenient build) can
# never read another case's payload -- the selection's failure is an
# internal error, never another value.

proc core::enums::isImpl {value id case} {
    if {[core::value::kind $value] ne "enum"} {
        core::semanticError TYPE "a match selects a case of an enum value, got [core::value::kind $value]"
    }
    return [core::value::bool [expr {[core::value::enumId $value] eq [core::value::strOf $id]
        && [core::value::enumCaseName $value] eq [core::value::strOf $case]}]]
}

proc core::enums::payloadImpl {value id case} {
    set id [core::value::strOf $id]
    set case [core::value::strOf $case]
    if {[core::value::kind $value] ne "enum" || [core::value::enumId $value] ne $id
            || [core::value::enumCaseName $value] ne $case} {
        core::semanticError UNMATCHED \
            "enum#payload: the payload of ${id}::$case was taken from a value of another case (a compiler bug: a payload is taken only under its own case's selection)"
    }
    if {![core::value::enumHasPayload $value]} {
        return [core::value::unit]
    }
    return [core::value::enumPayload $value]
}

proc core::enums::unmatchedImpl {} {
    core::semanticError UNMATCHED \
        "enum#unmatched: no arm of a match selected the value's case (a compiler bug, or a program run despite its rejected match: a match is proven to name every case)"
}

# The scrutinee is observed (it stays its owner's: the next arm's selection
# reads it again); the payload moves out of it (an affine payload's
# ownership with it: AFFINE-VALUES.md), so every arm consumes the
# scrutinee exactly once. The names are constants.
core::native::register enum#is -arity 3 -impl core::enums::isImpl \
    -param-types {any str str} -result-type bool -result-shape {enum-test 0} \
    -context-free 1 -ownership {observe erase erase}
core::native::register enum#payload -arity 3 -impl core::enums::payloadImpl \
    -param-types {any str str} -result-type any -result-shape {enum-payload 1} \
    -context-free 1 -ownership {move erase erase}
core::native::register enum#unmatched -arity 0 -impl core::enums::unmatchedImpl \
    -result-shape {never}
