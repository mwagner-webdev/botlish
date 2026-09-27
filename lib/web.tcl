# web.tcl -- demonstration library of refined string types.
#
# Types are registered from Tcl, alongside the natives that use them; there
# is no type declaration IR. Two kinds of refined type are shown:
#
#   Emailish       structural: a regex validator decides membership, and the
#                  generated predicate emailish? refines its argument
#   UriQueryValue  opaque: no validator can manufacture it; only the trusted
#                  transform uriEscape produces values carrying its evidence
#
#   (if (call (ref emailish?) (ref x))
#       (block {} ... x is {refined str {Emailish}} here ...)
#       (block {} ...))
#
# emailish? is the canonical predicate (R2-ORDINARY-EMAILISH-PREDICATE.md):
# an ordinary Botlish function, web::is_emailish (lib/web.bot), reached
# through -module-fn exactly like uriEscape's own web::uri_escape_text
# (NATIVE-MODULES.md) -- never a -native-body literal pasted into every call
# site. Emailish? is a temporary compatibility alias (core::native::alias):
# the exact same registered predicate, same SymbolId/refinement theorem/HIR
# target/specialization instances as emailish?, not a second registration,
# a runtime callable value, or a wrapper function -- see the report for the
# full architecture and why (spec items 1-84 of the R2 milestone).

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
# emailish? is the canonical predicate: an ordinary Botlish function,
# web::is_emailish (lib/web.bot), reached on the native (Cranelift) backend
# through -module-fn -- exactly emailRegex's grammar (local: 1+ of
# [alnum . _ % + -]; "@"; domain: 1+ of (1+ of [alnum -] then "."); tld: 2+
# alpha; end), the same left-to-right scan over core/tclcompat.tcl's
# is_tcl_alpha/is_tcl_alnum this predicate always used (see
# NATIVE-TCL-UNICODE.md's §6-equivalence argument for why that scan is a
# faithful, not approximated, encoding of the regex), but now compiled once
# as a real, shared, top-level function instead of pasted into every call
# site (R2-ORDINARY-EMAILISH-PREDICATE.md, mirroring NATIVE-MODULES.md's
# uriEscape/web::uri_escape_text). No -native-body: this predicate no longer
# passes through native::ExpandNativeBodies's pre-HIR body substitution at
# all, on any backend.
core::type::definePredicate Emailish emailish? "" {web is_emailish}
# Emailish? is a temporary compatibility alias for emailish?, not a second
# registration: core::native::alias makes both spellings resolve (hir/
# resolve.tcl's RootBinding, core::rootEnv) to the exact same root Binding/
# Symbol/registry entry, so they share one SymbolId, one refinement theorem,
# one HIR call target, and one specialization instance family -- never a
# runtime Block value, a wrapper function, or a second predicate. The
# callable-type surface syntax (uppercase NAME? as a type's predicate) is
# unchanged and still spellable as Emailish? -- only its canonical
# implementation moved. Scheduled for removal, along with the callable-type
# surface form generally, in the source/refactor milestone that follows R2.
core::native::alias Emailish? emailish?

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
