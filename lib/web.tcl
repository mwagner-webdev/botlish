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
# Emailish?'s native-body: emailRegex's exact grammar (local: 1+ of
# [alnum . _ % + -]; "@"; domain: 1+ of (1+ of [alnum -] then "."); tld: 2+
# alpha; end) as ordinary left-to-right scanning over core/tclcompat.tcl's
# is_tcl_alpha/is_tcl_alnum -- no regex engine, no DFA syntax, structurally
# the same two-pointer scan bench/equivalents/rust/refined_checks.rs's own
# `emailish` already uses (that scan's *shape* was always a faithful
# encoding of the regex; only its character classes were ASCII-only -- see
# NATIVE-TCL-UNICODE.md's §6-equivalence argument and this milestone's
# report). Three dedicated recursive scanners (scan_local/scan_label/
# scan_alpha), not one parameterized by a predicate value, so every
# is_tcl_alpha/is_tcl_alnum call site is a direct, syntactically literal
# native call -- never through a first-class function value -- exactly like
# uriEscape's own esc_bytes/esc_char/esc_from (NATIVE-URI-ESCAPE.md),
# deliberately not the more "reusable" higher-order alternative.
#
# scan_local/scan_label/scan_alpha(i) each return the index one past the
# longest run of their character class starting at i (i itself, if the
# class matches nothing there) -- an ordinary maximal-munch scan, since
# none of the three classes contains "." or "@" and the grammar has no
# ambiguity to backtrack over (NATIVE-TCL-UNICODE.md's §6 argument).
# domain_loop(i) consumes one "label ." group and then either recognizes
# the immediately following alpha run as the final TLD (returning n) or
# continues from just after the "." -- self-tail-recursive, matching
# refined-checks.ir's own `check` and uriEscape's esc_bytes/esc_from idiom.
core::type::definePredicate Emailish "" \
    {block {v}
        {bind n {call {ref length} {ref v}}}
        {bind char_at
            {block {i} {call {ref substring} {ref v} {ref i} {call {ref +} {ref i} {const 1}}}}}
        {bind is_local_char
            {block {c}
                {if {call {ref is_tcl_alnum} {ref c}}
                    {block {} {ref true}}
                    {block {}
                        {if {call {ref ==} {ref c} {const str .}}
                            {block {} {ref true}}
                            {block {}
                                {if {call {ref ==} {ref c} {const str _}}
                                    {block {} {ref true}}
                                    {block {}
                                        {if {call {ref ==} {ref c} {const str %}}
                                            {block {} {ref true}}
                                            {block {}
                                                {if {call {ref ==} {ref c} {const str +}}
                                                    {block {} {ref true}}
                                                    {block {} {call {ref ==} {ref c} {const str -}}}}}}}}}}}}}}
        {bind is_label_char
            {block {c}
                {if {call {ref is_tcl_alnum} {ref c}}
                    {block {} {ref true}}
                    {block {} {call {ref ==} {ref c} {const str -}}}}}}
        {bind scan_local
            {block {i}
                {if {call {ref >=} {ref i} {ref n}}
                    {block {} {ref i}}
                    {block {}
                        {if {call {ref is_local_char} {call {ref char_at} {ref i}}}
                            {block {} {call {ref scan_local} {call {ref +} {ref i} {const 1}}}}
                            {block {} {ref i}}}}}}}
        {bind scan_label
            {block {i}
                {if {call {ref >=} {ref i} {ref n}}
                    {block {} {ref i}}
                    {block {}
                        {if {call {ref is_label_char} {call {ref char_at} {ref i}}}
                            {block {} {call {ref scan_label} {call {ref +} {ref i} {const 1}}}}
                            {block {} {ref i}}}}}}}
        {bind scan_alpha
            {block {i}
                {if {call {ref >=} {ref i} {ref n}}
                    {block {} {ref i}}
                    {block {}
                        {if {call {ref is_tcl_alpha} {call {ref char_at} {ref i}}}
                            {block {} {call {ref scan_alpha} {call {ref +} {ref i} {const 1}}}}
                            {block {} {ref i}}}}}}}
        {bind tld_ok
            {block {i}
                {bind e {call {ref scan_alpha} {ref i}}}
                {if {call {ref ==} {ref e} {ref n}}
                    {block {} {call {ref >=} {call {ref -} {ref e} {ref i}} {const 2}}}
                    {block {} {ref false}}}}}
        {bind domain_loop
            {block {i}
                {bind labelEnd {call {ref scan_label} {ref i}}}
                {if {call {ref ==} {ref labelEnd} {ref i}}
                    {block {} {const -1}}
                    {block {}
                        {if {call {ref >=} {ref labelEnd} {ref n}}
                            {block {} {const -1}}
                            {block {}
                                {if {call {ref ==} {call {ref char_at} {ref labelEnd}} {const str .}}
                                    {block {}
                                        {bind i2 {call {ref +} {ref labelEnd} {const 1}}}
                                        {if {call {ref tld_ok} {ref i2}}
                                            {block {} {ref n}}
                                            {block {} {call {ref domain_loop} {ref i2}}}}}
                                    {block {} {const -1}}}}}}}}}
        {bind localEnd {call {ref scan_local} {const 0}}}
        {if {call {ref ==} {ref localEnd} {const 0}}
            {block {} {ref false}}
            {block {}
                {if {call {ref >=} {ref localEnd} {ref n}}
                    {block {} {ref false}}
                    {block {}
                        {if {call {ref ==} {call {ref char_at} {ref localEnd}} {const str @}}
                            {block {}
                                {bind afterAt {call {ref +} {ref localEnd} {const 1}}}
                                {call {ref ==} {call {ref domain_loop} {ref afterAt}} {ref n}}}
                            {block {} {ref false}}}}}}}}

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

# uriEscape's own escaping algorithm is now an ordinary cross-file Botlish
# definition, web::uri_escape_text (lib/web.bot) -- see NATIVE-MODULES.md.
# It is registered here as uriEscape's -module-fn (core/native.tcl), used
# only by the native (Cranelift) backend's own program entry point
# (native/native.tcl's module-native bridge) in place of a `natives` op
# whitelist entry: ordinary Botlish cannot itself attach the UriQueryValue
# evidence core::web::uriEscape's result carries (core/type.tcl: only a
# trusted native may mint evidence for an opaque type), so -impl above
# stays authoritative for interp and the Tcl compiler backend, and for the
# evidence itself on every backend -- web::uri_escape_text only has to
# reproduce the same *text*, which native code never inspects the evidence
# of. See NATIVE-URI-ESCAPE.md (the original -native-body migration) and
# NATIVE-MODULES.md (moving it into an ordinary module).
core::native::register uriEscape \
    -arity 1 \
    -impl core::web::uriEscape \
    -param-types {str} \
    -result-type {refined str {UriQueryValue}} \
    -runtime {string-alloc evidence} \
    -module-fn {web uri_escape_text}
