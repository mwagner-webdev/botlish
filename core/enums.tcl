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
