# tclcompat.tcl -- native Tcl-compatibility character classification:
#   std::str::is_tcl_alpha(c), std::str::is_tcl_alnum(c) : one-scalar str -> bool
#   (root natives registered under their qualified `str` names, beside
#   core/strings.tcl's)
#   std::char::is_tcl_alpha(c), std::char::is_tcl_alnum(c) : UnicodeChar -> bool
#   (the same classes of a UnicodeChar, beside core/unicodechar.tcl's
#   std::char::scalar_value; UNICODECHAR-CLASSIFIERS.md)
#
# STATUS: temporary compatibility primitives -- NOT Botlish's eventual
# public Unicode character-classification API.
#
#   These exist only to let the Emailish validator (stdlib/web.tcl's
#   `Emailish?` when written, today stdlib/web.bot's `std::web::emailish?`; whose
#   grammar uses Tcl's `[:alpha:]`/`[:alnum:]` regexp bracket-expression
#   classes -- core/regex.tcl, core::web::emailRegex) be expressed as
#   ordinary compiled core IR instead of running through the Tcl-only regex
#   engine (core/regex.tcl) that has no native (Cranelift) implementation at
#   all. "tcl" is in the name on purpose: it means "reproduce what Tcl 9's
#   [:alpha:]/[:alnum:] currently accept, exactly", not "this is the
#   Unicode classification Botlish will eventually expose to source
#   programs". Do not let ordinary Botlish code start depending on these
#   names as if they were a stable, general-purpose API -- they are a
#   bootstrap substrate for one library validator, the same role
#   core/hashing.tcl's `hash` plays for hash tables (see that file's own
#   STATUS header for the same kind of caveat).
#
#   Replace these with an ordinary Botlish implementation once BOTH of these
#   are true:
#     1. Botlish has some way to classify a Unicode scalar by category (a
#        Unicode property table exposed to source programs -- generated
#        immutable data, module-level shared data, an efficient lookup
#        mechanism, possibly requiring fixed-width/Bytes support Botlish
#        does not have yet) that ordinary core IR can consult directly,
#        instead of this being a native primitive at all;
#     2. Botlish's own eventual public character-class semantics are
#        actually decided (matching Tcl's current classes exactly forever,
#        matching the Unicode Alphabetic/Numeric derived properties instead,
#        or something else) -- "whatever Tcl 9 happens to accept" is a
#        reasonable *bootstrap* target (it is what the existing reference
#        validator, core::regex::matches against emailRegex, already
#        decides today) but is not by itself a specification of Botlish's
#        language semantics.
#   Until then, this file and native/src/runtime/ops.rs's rt_is_tcl_alpha/
#   rt_is_tcl_alnum are the two implementations that must agree exactly (see
#   below); a Botlish replacement collapses that duplication to one, the
#   same way a future hash rewrite would for core/hashing.tcl.
#
# Semantics (empirically characterized against Tcl 9.0.1's `regexp
# {[:alpha:]}`/`{[:alnum:]}`, not assumed from documentation -- see
# NATIVE-TCL-UNICODE.md for the full edge-case corpus and Unicode-version
# notes):
#
#   std::str::is_tcl_alpha(c)  Unicode General_Category(c) in {Lu, Ll, Lt, Lm, Lo}
#                     ("Letter"), exactly Tcl 9's [:alpha:] bracket class.
#   std::str::is_tcl_alnum(c)  std::str::is_tcl_alpha(c) or General_Category(c) == Nd
#                     ("Letter or Decimal_Number"), exactly Tcl 9's
#                     [:alnum:] bracket class.
#
# Deliberately narrower than several plausible-looking alternatives, each
# checked directly against Tcl and rejected where it disagreed:
#   - Rust's std::char::is_alphabetic()/is_alphanumeric() use the Unicode
#     *Alphabetic*/derived-numeric properties, which also admit Nl
#     (letter-number) code points and other Other_Alphabetic marks Tcl's
#     classes do not (e.g. U+2160 ROMAN NUMERAL ONE: alpha=false in Tcl,
#     is_alphabetic()==true in Rust) -- not used directly; see
#     native/src/runtime/ops.rs's tcl_alpha_char/tcl_alnum_char, built from
#     General_Category instead.
#   - Python's str.isalnum() also admits No/Nl (e.g. circled digits, Roman
#     numerals, superscripts), not just Nd -- str.isalpha() plus
#     str.isdecimal() is the exact match instead (see
#     bench/equivalents/python/refined_checks.py's tcl_alpha/tcl_alnum).
#   - ASCII-only classification (is_ascii_alphabetic/is_ascii_alphanumeric,
#     the Rust benchmark's old shortcut) is a real semantic narrowing, not
#     an equivalent simplification: Tcl's [:alpha:]/[:alnum:] are
#     Unicode-aware (e.g. "café", "日本語" match [:alpha:]+ in Tcl 9).
#
# Contract: the argument of the `str` forms must be a str of exactly one
# Unicode scalar (core::strings::length == 1) -- the smallest representation
# that fit Botlish's architecture when they were written (no public
# UnicodeChar existed yet). An argument of any other length, including the
# empty string, is a RANGE error, following the same out-of-domain
# convention core::strings::substring uses for an out-of-range index, rather
# than silently classifying only the first scalar of a longer string.
#
# The `char` forms classify a UnicodeChar (UNICODE-CHAR-LITERALS.md) by the
# same rule and are total: every UnicodeChar is one Unicode scalar, so there
# is no RANGE case and no allocation -- a character read with
# std::str::char_at is classified without ever becoming a one-character
# String (UNICODECHAR-CLASSIFIERS.md, which measured what that costs). The
# two forms must agree on every scalar: each pair shares one classification
# here (Classify) and one in native/src/runtime/ops.rs (tcl_alpha_char,
# tcl_alnum_char), whose generated code also classifies an ASCII scalar
# inline (codegen::clif's CharIsTclAlpha/CharIsTclAlnum).
#
# native/src/runtime/ops.rs's rt_is_tcl_alpha/rt_is_tcl_alnum (and
# rt_char_is_tcl_alpha/rt_char_is_tcl_alnum, which stdlib/web.bot's emailish?
# reaches) are the Cranelift-native counterpart; this file (Tcl's
# own built-in `string is alpha -strict`/`string is alnum -strict`, verified
# identical to `regexp {^[:alpha:]$}`/`{^[:alnum:]}$}` on the same corpus)
# stays authoritative for interp/compile and for the reference contract
# check.

namespace eval core::tclcompat {}

proc core::tclcompat::CheckOneScalar {v native} {
    set text [core::value::strOf [core::value::expect str $v $native]]
    set n [string length $text]
    if {$n != 1} {
        core::semanticError RANGE \
            "$native: expects a single Unicode scalar, got a string of length $n"
    }
    return $text
}

# Whether TEXT, exactly one scalar, is in Tcl 9's class CLASS (alpha or
# alnum): the one classification both forms use.
proc core::tclcompat::Classify {class text} {
    return [core::value::bool [string is $class -strict $text]]
}

proc core::tclcompat::isTclAlpha {c} {
    return [Classify alpha [CheckOneScalar $c std::str::is_tcl_alpha]]
}

proc core::tclcompat::isTclAlnum {c} {
    return [Classify alnum [CheckOneScalar $c std::str::is_tcl_alnum]]
}

proc core::tclcompat::charIsTclAlpha {c} {
    set c [core::value::expect UnicodeChar $c std::char::is_tcl_alpha]
    return [Classify alpha [format %c [core::value::charOf $c]]]
}

proc core::tclcompat::charIsTclAlnum {c} {
    set c [core::value::expect UnicodeChar $c std::char::is_tcl_alnum]
    return [Classify alnum [format %c [core::value::charOf $c]]]
}

# All four are context-free value operations (a pure function of the
# argument, no I/O or process state): a module initializer may call them, and
# a function calling them can be repeatable (hir/repeatable.tcl,
# REFINEMENT-VALUES.md). The `char` forms need no -runtime tag: they index
# nothing, cannot fail and allocate nothing.
core::native::register std::str::is_tcl_alpha -arity 1 -impl core::tclcompat::isTclAlpha \
    -param-types {str} -result-type bool -runtime {char-index range-check} -context-free 1
core::native::register std::str::is_tcl_alnum -arity 1 -impl core::tclcompat::isTclAlnum \
    -param-types {str} -result-type bool -runtime {char-index range-check} -context-free 1
core::native::register std::char::is_tcl_alpha -arity 1 -impl core::tclcompat::charIsTclAlpha \
    -param-types {UnicodeChar} -result-type bool -context-free 1
core::native::register std::char::is_tcl_alnum -arity 1 -impl core::tclcompat::charIsTclAlnum \
    -param-types {UnicodeChar} -result-type bool -context-free 1
