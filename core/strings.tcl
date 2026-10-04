# strings.tcl -- native string operations: the `str` namespace's
# intrinsics (str::length, str::substring, str::lowercase, str::concat,
# str::encode_utf8; core/tclcompat.tcl adds str::is_tcl_alpha/alnum).
# Each is a root native registered under its qualified name
# (core::native::isQualifiedNative): there is no lib/str.bot module, and a
# future one could add other members but never redefine these
# (surface/modules.tcl, DUPLICATE-NATIVE; STDLIB-NAMESPACES.md).
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
    return [core::value::int [string length [Text $s str::length]]]
}

# (str::substring S START END): the characters at START <= i < END, a slice
# of S's characters: an invalid one fails with LowerUnderrun or UpperOverrun
# (core::native::checkSlice).
proc core::strings::substring {s start end} {
    set text [Text $s str::substring]
    set from [core::value::intOf [core::value::expect int $start str::substring]]
    set to [core::value::intOf [core::value::expect int $end str::substring]]
    core::native::checkSlice str::substring $from $to [string length $text]
    return [core::value::str [string range $text $from [expr {$to - 1}]]]
}

# lowercase: the Unicode 16 *simple* (one-to-one, UnicodeData.txt) lowercase
# mapping, which is what Tcl 9.0.x's `string tolower` implements except for two
# scalars it leaves unchanged although UnicodeData.txt maps them (U+023A and
# U+023E; verified against all scalars on Tcl 9.0.1, whose tables are Unicode
# 16). They are patched here so the reference matches the standard, and
# native/src/runtime/ops.rs's rt_str_lower matches this. The full mapping
# (SpecialCasing.txt: U+0130 -> "i" + U+0307, context/language rules) and
# Unicode 17 additions are deliberately not implemented; see README.md
# ("Strings") and tests/native-tcl-unicode.test, which compares every scalar.
# Not performance-critical: this is the reference implementation.
proc core::strings::lowercase {s} {
    set text [string tolower [Text $s str::lowercase]]
    return [core::value::str [string map "Ⱥ ⱥ Ⱦ ⱦ" $text]]
}

proc core::strings::concat {a b} {
    return [core::value::str "[Text $a str::concat][Text $b str::concat]"]
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
    set text [Text $s str::encode_utf8]
    set bytes {}
    foreach byte [split [encoding convertto utf-8 $text] ""] {
        scan $byte %c code
        lappend bytes [core::value::int $code]
    }
    return [core::value::listOf $bytes]
}

core::native::register str::length    -arity 1 -impl core::strings::length \
    -param-types {str} -result-type int -runtime char-index -result-range collection-length -context-free 1
core::native::register str::substring -arity 3 -impl core::strings::substring \
    -param-types {str int int} -result-type str \
    -runtime {string-alloc char-index range-check} -context-free 1 \
    -errors {LowerUnderrun UpperOverrun} -bounds {slices {str 0 1 2}}
core::native::register str::lowercase -arity 1 -impl core::strings::lowercase \
    -param-types {str} -result-type str -runtime string-alloc -context-free 1
core::native::register str::concat    -arity 2 -impl core::strings::concat \
    -param-types {str str} -result-type str -runtime string-alloc -context-free 1
core::native::register str::encode_utf8 -arity 1 -impl core::strings::encodeUtf8 \
    -param-types {str} -result-type list -runtime list-alloc -context-free 1 \
    -result-shape {typed byte::Byte 0 255}
