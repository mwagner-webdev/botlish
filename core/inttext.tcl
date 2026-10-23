# inttext.tcl -- an Int's decimal text, both ways
# (NUMERIC-TEXT-BOUNDARY-MILESTONE-1.md).
#
#   std::int::to_string(n)    (int) -> str: N's canonical decimal text --
#                             the decimal digits, no leading zero (but the
#                             one digit of 0), a "-" before a negative
#                             number and nothing before any other; exact for
#                             every Int, of every size. Total.
#   std::int::from_string(s)  (str) -> int, errors InvalidIntegerText: the
#                             Int whose canonical decimal text is S; the
#                             declared builtin error InvalidIntegerText for
#                             any other text.
#
# The text is the one canonical decimal text of an Int this implementation
# already has: an Int's runtime payload (core/value.tcl's `int`), its core
# IR and HIR constants, and its display (core::value::show) are all
# 0 | -?[1-9][0-9]* (core::value::isCanonicalInt), which is the source
# integer literal's rule (decimal digits, no leading zeros: surface/
# lexer.tcl) with a minus sign for a negative number. to_string is that
# display; from_string accepts exactly the texts to_string produces, so the
# two are inverse bijections between the Ints and their texts:
# from_string(to_string(x)) == x for every Int x, and to_string(from_string(s))
# == s for every text s from_string accepts. Nothing else is accepted: no
# "+", no leading zero ("01", "-01"), no "-0" (zero has one text), no
# space anywhere, no fraction or exponent, no digit other than ASCII 0-9,
# and not the empty text. No locale, no base but ten, no digit grouping.
# native/src/runtime/inttext.rs computes the same, from the same rule.

namespace eval core::inttext {}

# InvalidIntegerText: a text that is not the canonical decimal text of an
# Int (std::int::from_string). Declared here, after core/listlength.tcl's
# LengthMismatch (core/core.tcl's load order), so that it is builtin error
# 11 and every existing builtin error keeps its id (core/native.tcl's
# declaration-order comment; native/src/runtime/error.rs's ERR_* ids).
core::native::declareError InvalidIntegerText

# std::int::to_string(N): the canonical decimal text of the Int N, the
# display core::value::show gives it (one rendering of an Int: a program's
# result, a message, and this).
proc core::inttext::toString {n} {
    core::value::expect int $n std::int::to_string
    return [core::value::str [core::value::show $n]]
}

# std::int::from_string(S): the Int whose canonical decimal text is S, else
# InvalidIntegerText.
proc core::inttext::fromString {s} {
    set text [core::value::strOf [core::value::expect str $s std::int::from_string]]
    if {![core::value::isCanonicalInt $text]} {
        core::native::failDeclared InvalidIntegerText \
            "std::int::from_string: [core::value::show [core::value::str [Excerpt $text]]] is not the decimal text of an Int (an optional \"-\" and decimal digits, no leading zero)"
    }
    return [core::value::int $text]
}

# TEXT, or its first 40 characters and "..." when it is longer: what a
# message quotes of a rejected text.
proc core::inttext::Excerpt {text} {
    if {[string length $text] <= 40} {
        return $text
    }
    return "[string range $text 0 39]..."
}

# to_string folds (core/native.tcl's -fold): a call of an exactly known Int
# is the text it makes. from_string does not: its failure is a fact about
# the text a run is given, which a program handles, never a compile-time
# error of a constant (a fold that fails is KNOWN-ERROR whatever handles it).
proc core::inttext::Fold {n} {
    if {[core::value::kind $n] ne "int"} {
        return ""
    }
    return [list value [toString $n]]
}

core::native::register std::int::to_string -arity 1 -impl core::inttext::toString \
    -param-types {int} -result-type str -runtime {bigint string-alloc} -context-free 1 \
    -fold core::inttext::Fold
core::native::register std::int::from_string -arity 1 -impl core::inttext::fromString \
    -param-types {str} -result-type int -runtime bigint -errors InvalidIntegerText \
    -context-free 1 -nomethod 1
