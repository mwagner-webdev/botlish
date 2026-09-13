# web.tcl -- demonstration library of refined string types.
#
# Types are registered from Tcl, alongside the natives that use them; there
# is no type declaration IR. Two kinds of refined type are shown:
#
#   Emailish       structural: a regex validator decides membership, and the
#                  generated predicate Emailish? refines its argument
#   UriQueryValue  opaque: no validator can manufacture it; only the trusted
#                  transform uriEscape produces values carrying its evidence
#
#   (if (call (ref Emailish?) (ref x))
#       (block {} ... x is {refined str {Emailish}} here ...)
#       (block {} ...))

namespace eval core::web {
    # Local part and domain labels of letters, digits and a few symbols,
    # then a dot and a top-level domain of at least two letters.
    variable emailRegex [core::regex::create {
        seq
        {repeat {set {class alnum} {char .} {char _} {char %} {char +} {char -}} 1 inf}
        {lit @}
        {repeat {seq {repeat {set {class alnum} {char -}} 1 inf} {lit .}} 1 inf}
        {repeat {class alpha} 2 inf}
    }]
}

core::type::register Emailish \
    -base str \
    -validator [list core::regex::matches $core::web::emailRegex]
core::type::definePredicate Emailish

core::type::register UriQueryValue \
    -base str \
    -opaque 1
core::type::definePredicate UriQueryValue

# Percent-encodes every byte of the UTF-8 form of S except the RFC 3986
# unreserved characters. The result is safe to embed as a URI query value,
# which the evidence records.
proc core::web::uriEscape {s} {
    set text [core::value::strOf [core::value::expect str $s uriEscape]]
    set escaped ""
    foreach byte [split [encoding convertto utf-8 $text] ""] {
        if {[regexp {^[A-Za-z0-9._~-]$} $byte]} {
            append escaped $byte
        } else {
            scan $byte %c code
            append escaped [format %%%02X $code]
        }
    }
    return [core::value::withEvidence [core::value::str $escaped] UriQueryValue]
}

core::native::register uriEscape \
    -arity 1 \
    -impl core::web::uriEscape \
    -param-types {str} \
    -result-type {refined str {UriQueryValue}}
