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

# S's UTF-8 encoding as a List of Ints, one per byte (each 0..255), in
# order: the general byte-level access String otherwise never exposes
# (String counts and indexes only by Unicode scalar -- length, substring).
# Library string transforms that need to inspect or classify individual
# bytes (percent-encoding, other byte-oriented text formats) build on this
# plus ordinary List/Int operations, instead of each needing its own
# native. Mirrors native/src/runtime/ops.rs's rt_str_utf8_bytes exactly
# (Tcl's `encoding convertto utf-8` here, Rust's already-UTF-8 `String`
# there): both walk the same byte sequence in the same order.
proc core::strings::encodeUtf8 {s} {
    set text [Text $s encode_utf8]
    set bytes {}
    foreach byte [split [encoding convertto utf-8 $text] ""] {
        scan $byte %c code
        lappend bytes [core::value::int $code]
    }
    return [core::value::listOf $bytes]
}

core::native::register length    -arity 1 -impl core::strings::length \
    -param-types {str} -result-type int -runtime char-index -result-range collection-length -context-free 1
core::native::register substring -arity 3 -impl core::strings::substring \
    -param-types {str int int} -result-type str \
    -runtime {string-alloc char-index range-check} -context-free 1
core::native::register lowercase -arity 1 -impl core::strings::lowercase \
    -param-types {str} -result-type str -runtime string-alloc -context-free 1
core::native::register concat    -arity 2 -impl core::strings::concat \
    -param-types {str str} -result-type str -runtime string-alloc -context-free 1
core::native::register encode_utf8 -arity 1 -impl core::strings::encodeUtf8 \
    -param-types {str} -result-type list -runtime list-alloc -context-free 1
