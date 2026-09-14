# strings.tcl -- native string operations.
#
# One conservative rule governs refined strings:
#
#   String transformations discard refinements unless their contract
#   explicitly establishes or preserves them.
#
# Every operation here builds a new plain string (no evidence), and its
# declared result type is plain str, so neither the runtime nor the compiler
# carries a refinement of an input over to the output. Indices count
# characters.

namespace eval core::strings {}

proc core::strings::Text {v name} {
    return [core::value::strOf [core::value::expect str $v $name]]
}

proc core::strings::length {s} {
    return [core::value::int [string length [Text $s length]]]
}

# (substring S START END): the characters at START <= i < END.
proc core::strings::substring {s start end} {
    set text [Text $s substring]
    set from [core::value::intOf [core::value::expect int $start substring]]
    set to [core::value::intOf [core::value::expect int $end substring]]
    if {$from < 0 || $from > $to || $to > [string length $text]} {
        core::semanticError RANGE \
            "substring: range $from..$to is outside 0..[string length $text]"
    }
    return [core::value::str [string range $text $from [expr {$to - 1}]]]
}

proc core::strings::lowercase {s} {
    return [core::value::str [string tolower [Text $s lowercase]]]
}

proc core::strings::concat {a b} {
    return [core::value::str "[Text $a concat][Text $b concat]"]
}

core::native::register length    -arity 1 -impl core::strings::length \
    -param-types {str} -result-type int -runtime char-index -result-range nonneg
core::native::register substring -arity 3 -impl core::strings::substring \
    -param-types {str int int} -result-type str \
    -runtime {string-alloc char-index range-check}
core::native::register lowercase -arity 1 -impl core::strings::lowercase \
    -param-types {str} -result-type str -runtime string-alloc
core::native::register concat    -arity 2 -impl core::strings::concat \
    -param-types {str str} -result-type str -runtime string-alloc
