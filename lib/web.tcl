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

# uriEscape's own algorithm, in ordinary Botlish, over the general
# core/strings.tcl native encode_utf8 (str -> list of Int, one per UTF-8
# byte) plus mod/comparisons/concat/list_get: the same byte-based
# percent-encoding as core::web::uriEscape above, character by character
# (encode_utf8 of a one-character substring gives exactly that scalar's own
# UTF-8 bytes, so scanning the source by Unicode scalar rather than by raw
# byte is equivalent -- UTF-8 is a per-scalar, concatenation-preserving
# encoding). high_nibble/is_unreserved are single ascending threshold
# ladders (Botlish has no integer division and no and/or primitive; a
# boundary walk over disjoint, already-ordered ranges needs neither).
# esc_bytes/esc_char/esc_from accumulate their result by repeated concat,
# the same recursive idiom examples/stdlib/string_reverse.bot's
# reverse_from and examples/stdlib/ai_text_clean.bot's clean_from already
# use for this codebase's only other "no mutable String" left-to-right scan.
#
# This is registered as uriEscape's -native-body (core/native.tcl), used
# only by the native (Cranelift) backend's own program entry point
# (native/native.tcl's ExpandNativeBodies) in place of a `natives` op
# whitelist entry: ordinary Botlish cannot itself attach the UriQueryValue
# evidence core::web::uriEscape's result carries (core/type.tcl: only a
# trusted native may mint evidence for an opaque type), so -impl above
# stays authoritative for interp and the Tcl compiler backend, and for the
# evidence itself on every backend -- this body only has to reproduce the
# same *text*, which native code never inspects the evidence of. See
# NATIVE-URI-ESCAPE.md.
core::native::register uriEscape \
    -arity 1 \
    -impl core::web::uriEscape \
    -param-types {str} \
    -result-type {refined str {UriQueryValue}} \
    -runtime {string-alloc evidence} \
    -native-body         {block {s}
            {bind hex_digits
                {call {ref list}
                    {const str 0} {const str 1} {const str 2} {const str 3}
                    {const str 4} {const str 5} {const str 6} {const str 7}
                    {const str 8} {const str 9} {const str A} {const str B}
                    {const str C} {const str D} {const str E} {const str F}}}
            {bind high_nibble
                {block {b}
                    {if {call {ref <=} {ref b} {const 15}} {block {} {const 0}} {block {} {if {call {ref <=} {ref b} {const 31}} {block {} {const 1}} {block {} {if {call {ref <=} {ref b} {const 47}} {block {} {const 2}} {block {} {if {call {ref <=} {ref b} {const 63}} {block {} {const 3}} {block {} {if {call {ref <=} {ref b} {const 79}} {block {} {const 4}} {block {} {if {call {ref <=} {ref b} {const 95}} {block {} {const 5}} {block {} {if {call {ref <=} {ref b} {const 111}} {block {} {const 6}} {block {} {if {call {ref <=} {ref b} {const 127}} {block {} {const 7}} {block {} {if {call {ref <=} {ref b} {const 143}} {block {} {const 8}} {block {} {if {call {ref <=} {ref b} {const 159}} {block {} {const 9}} {block {} {if {call {ref <=} {ref b} {const 175}} {block {} {const 10}} {block {} {if {call {ref <=} {ref b} {const 191}} {block {} {const 11}} {block {} {if {call {ref <=} {ref b} {const 207}} {block {} {const 12}} {block {} {if {call {ref <=} {ref b} {const 223}} {block {} {const 13}} {block {} {if {call {ref <=} {ref b} {const 239}} {block {} {const 14}} {block {} {const 15}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}
            {bind is_unreserved
                {block {b}
                    {if {call {ref <=} {ref b} {const 44}} {block {} {ref false}} {block {} {if {call {ref <=} {ref b} {const 46}} {block {} {ref true}} {block {} {if {call {ref <=} {ref b} {const 47}} {block {} {ref false}} {block {} {if {call {ref <=} {ref b} {const 57}} {block {} {ref true}} {block {} {if {call {ref <=} {ref b} {const 64}} {block {} {ref false}} {block {} {if {call {ref <=} {ref b} {const 90}} {block {} {ref true}} {block {} {if {call {ref <=} {ref b} {const 94}} {block {} {ref false}} {block {} {if {call {ref <=} {ref b} {const 95}} {block {} {ref true}} {block {} {if {call {ref <=} {ref b} {const 96}} {block {} {ref false}} {block {} {if {call {ref <=} {ref b} {const 122}} {block {} {ref true}} {block {} {if {call {ref <=} {ref b} {const 125}} {block {} {ref false}} {block {} {if {call {ref <=} {ref b} {const 126}} {block {} {ref true}} {block {} {ref false}}}}}}}}}}}}}}}}}}}}}}}}}}}
            {bind hex_pair
                {block {b}
                    {call {ref concat}
                        {call {ref list_get} {ref hex_digits} {call {ref high_nibble} {ref b}}}
                        {call {ref list_get} {ref hex_digits} {call {ref mod} {ref b} {const 16}}}}}}
            {bind esc_bytes
                {block {bytes i acc}
                    {if {call {ref >=} {ref i} {call {ref list_length} {ref bytes}}}
                        {block {} {ref acc}}
                        {block {}
                            {call {ref esc_bytes}
                                {ref bytes}
                                {call {ref +} {ref i} {const 1}}
                                {call {ref concat}
                                    {ref acc}
                                    {call {ref concat} {const str %}
                                        {call {ref hex_pair} {call {ref list_get} {ref bytes} {ref i}}}}}}}}}}
            {bind esc_char
                {block {c}
                    {bind bytes {call {ref encode_utf8} {ref c}}}
                    {if {call {ref ==} {call {ref list_length} {ref bytes}} {const 1}}
                        {block {}
                            {if {call {ref is_unreserved} {call {ref list_get} {ref bytes} {const 0}}}
                                {block {} {ref c}}
                                {block {} {call {ref esc_bytes} {ref bytes} {const 0} {const str {}}}}}}
                        {block {} {call {ref esc_bytes} {ref bytes} {const 0} {const str {}}}}}}}
            {bind esc_from
                {block {text i acc}
                    {if {call {ref >=} {ref i} {call {ref length} {ref text}}}
                        {block {} {ref acc}}
                        {block {}
                            {call {ref esc_from}
                                {ref text}
                                {call {ref +} {ref i} {const 1}}
                                {call {ref concat}
                                    {ref acc}
                                    {call {ref esc_char}
                                        {call {ref substring} {ref text} {ref i} {call {ref +} {ref i} {const 1}}}}}}}}}}
            {call {ref esc_from} {ref s} {const 0} {const str {}}}}
