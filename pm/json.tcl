# json.tcl -- strict JSON for the package manager's metadata
# (PACKAGE-MANAGER-MILESTONE-1.md; BOTLISH-JSON.md, "Encoding").
#
#   pm::json::decode BYTES ?-limit N?   the value of UTF-8 JSON text
#   pm::json::encode VALUE              its canonical UTF-8 text (2-space
#                                       indentation, one trailing newline)
#
# A value is a typed Tcl value, {TYPE PAYLOAD}:
#
#   {null {}}  {bool 0|1}  {num TEXT}  {str TEXT}  {arr {V ...}}
#   {obj {KEY V ...}}     (keys in the order the text wrote them)
#
# The reader is deliberately stricter than JSON's grammar requires, because a
# package descriptor is security metadata: the same bytes must mean the same
# thing to every reader, now and to the registry later.
#
#   * the bytes must be UTF-8 (strict: no overlong forms, no surrogates), with
#     no byte order mark;
#   * an object may not repeat a key (anywhere): two readers that keep the
#     first or the last value would disagree about what the file says;
#   * a string escape may not name half of a surrogate pair alone, and a
#     string may hold no control character unescaped (JSON's own rule);
#   * nesting is limited (maxDepth), and so is the text's size (-limit).
#
# Errors are {PM JSON MALFORMED} with the byte-independent character offset
# and a message, {PM JSON ENCODING} for bytes that are not UTF-8, and
# {PM JSON LIMIT} for text over a limit. Nothing here knows what a package
# is; the descriptor's schema is pm/descriptor.tcl's.
#
# This is not lsp/json.tcl: that reader keeps a repeated key's last value, as
# the protocol allows. The package manager has no part in the language server
# and shares nothing with it.

namespace eval pm::json {
    variable maxDepth 32
    variable defaultLimit [expr {1024 * 1024}]
    variable simple [list \\\" \" \\\\ \\ \\/ / \\b \b \\f \f \\n \n \\r \r \\t \t]
    variable escapes [list \\ \\\\ \" \\\" \n \\n \r \\r \t \\t \b \\b \f \\f]
    for {set c 0} {$c < 32} {incr c} {
        if {[format %c $c] ni {\n \r \t \b \f}} {
            lappend escapes [format %c $c] [format \\u%04x $c]
        }
    }
    lappend escapes \x7f \\u007f
    unset c
}

proc pm::json::Fail {offset message} {
    return -code error -errorcode [list PM JSON MALFORMED $offset] \
        "malformed JSON at character $offset: $message"
}

# The value of the UTF-8 JSON text BYTES.
proc pm::json::decode {bytes args} {
    variable defaultLimit
    set limit $defaultLimit
    foreach {option value} $args {
        switch -- $option {
            -limit { set limit $value }
            default { error "pm::json::decode: unknown option $option" }
        }
    }
    if {[string length $bytes] > $limit} {
        return -code error -errorcode {PM JSON LIMIT} \
            "JSON text of [string length $bytes] bytes is over the limit of $limit bytes"
    }
    if {[string range $bytes 0 2] eq "\xef\xbb\xbf"} {
        return -code error -errorcode {PM JSON ENCODING} \
            "JSON text starts with a UTF-8 byte order mark: write the file without one"
    }
    if {[catch {encoding convertfrom -profile strict utf-8 $bytes} text]} {
        return -code error -errorcode {PM JSON ENCODING} "JSON text is not valid UTF-8"
    }
    return [parse $text]
}

# The value of the JSON text TEXT (a Tcl string).
proc pm::json::parse {text} {
    set i [Space $text 0]
    set value [Value $text i 0]
    set i [Space $text $i]
    if {$i < [string length $text]} {
        Fail $i "unexpected text after the value"
    }
    return $value
}

proc pm::json::Space {text i} {
    if {[regexp -start $i {\A[ \t\r\n]*} $text match]} {
        incr i [string length $match]
    }
    return $i
}

proc pm::json::Value {text iVar depth} {
    upvar 1 $iVar i
    variable maxDepth
    if {$depth > $maxDepth} {
        Fail $i "nesting deeper than $maxDepth levels"
    }
    set c [string index $text $i]
    switch -- $c {
        "\{" { return [Object $text i $depth] }
        "\[" { return [Array $text i $depth] }
        "\"" { return [list str [String $text i]] }
        t {
            if {[string range $text $i [expr {$i + 3}]] eq "true"} {
                incr i 4
                return {bool 1}
            }
        }
        f {
            if {[string range $text $i [expr {$i + 4}]] eq "false"} {
                incr i 5
                return {bool 0}
            }
        }
        n {
            if {[string range $text $i [expr {$i + 3}]] eq "null"} {
                incr i 4
                return {null {}}
            }
        }
        default {
            if {[regexp -start $i {\A-?(?:0|[1-9][0-9]*)(?:\.[0-9]+)?(?:[eE][+-]?[0-9]+)?} $text number]} {
                incr i [string length $number]
                return [list num $number]
            }
        }
    }
    if {$c eq ""} {
        Fail $i "unexpected end of text, expecting a value"
    }
    Fail $i "unexpected character \"$c\", expecting a value"
}

proc pm::json::Object {text iVar depth} {
    upvar 1 $iVar i
    incr i
    set members {}
    set seen [dict create]
    set i [Space $text $i]
    if {[string index $text $i] eq "\}"} {
        incr i
        return [list obj $members]
    }
    while 1 {
        if {[string index $text $i] ne "\""} {
            Fail $i "expecting a string key"
        }
        set at $i
        set key [String $text i]
        if {[dict exists $seen $key]} {
            Fail $at "the object repeats the key \"$key\": a key may appear once"
        }
        dict set seen $key 1
        set i [Space $text $i]
        if {[string index $text $i] ne ":"} {
            Fail $i "expecting \":\" after an object key"
        }
        set i [Space $text [expr {$i + 1}]]
        lappend members $key [Value $text i [expr {$depth + 1}]]
        set i [Space $text $i]
        switch -- [string index $text $i] {
            , { set i [Space $text [expr {$i + 1}]] }
            "\}" {
                incr i
                return [list obj $members]
            }
            default { Fail $i "expecting \",\" or \"\}\" in an object" }
        }
    }
}

proc pm::json::Array {text iVar depth} {
    upvar 1 $iVar i
    incr i
    set items {}
    set i [Space $text $i]
    if {[string index $text $i] eq "\]"} {
        incr i
        return [list arr $items]
    }
    while 1 {
        lappend items [Value $text i [expr {$depth + 1}]]
        set i [Space $text $i]
        switch -- [string index $text $i] {
            , { set i [Space $text [expr {$i + 1}]] }
            "\]" {
                incr i
                return [list arr $items]
            }
            default { Fail $i "expecting \",\" or \"\]\" in an array" }
        }
    }
}

proc pm::json::String {text iVar} {
    upvar 1 $iVar i
    variable simple
    set start $i
    incr i
    set out ""
    while 1 {
        if {![regexp -start $i {\A[^"\\\x00-\x1f]*} $text run]} {
            set run ""
        }
        append out $run
        incr i [string length $run]
        set c [string index $text $i]
        if {$c eq "\""} {
            incr i
            return $out
        }
        if {$c eq ""} {
            Fail $start "unterminated string"
        }
        if {$c ne "\\"} {
            Fail $i "a control character must be escaped in a string"
        }
        set escape [string range $text $i [expr {$i + 1}]]
        if {[dict exists $simple $escape]} {
            append out [dict get $simple $escape]
            incr i 2
            continue
        }
        if {![regexp -start $i {\A\\u([0-9A-Fa-f]{4})} $text -> hex]} {
            Fail $i "invalid escape in a string"
        }
        set code [scan $hex %x]
        incr i 6
        if {$code >= 0xD800 && $code <= 0xDBFF} {
            if {![regexp -start $i {\A\\u([dD][c-fC-F][0-9A-Fa-f]{2})} $text -> low]} {
                Fail [expr {$i - 6}] "an escaped high surrogate without its low surrogate"
            }
            set code [expr {0x10000 + (($code - 0xD800) << 10) + ([scan $low %x] - 0xDC00)}]
            incr i 6
        } elseif {$code >= 0xDC00 && $code <= 0xDFFF} {
            Fail [expr {$i - 6}] "an escaped low surrogate without its high surrogate"
        }
        append out [format %c $code]
    }
}

# ---------------------------------------------------------------------------
# Accessors

proc pm::json::type {value} { return [lindex $value 0] }
proc pm::json::payload {value} { return [lindex $value 1] }

# ---------------------------------------------------------------------------
# Writing

# The canonical UTF-8 text of VALUE: two-space indentation, ": " after a key,
# an empty object or array as {} or [], one trailing newline. Keys are
# written in VALUE's order (callers that want a canonical order build it).
proc pm::json::encode {value} {
    return [encoding convertto utf-8 "[Write $value 0]\n"]
}

proc pm::json::Write {value level} {
    variable escapes
    lassign $value type payload
    switch -- $type {
        null { return null }
        bool { if {$payload} { return true } else { return false } }
        num { return $payload }
        str { return "\"[string map $escapes $payload]\"" }
        arr {
            if {$payload eq ""} { return {[]} }
            set inner [string repeat "  " [expr {$level + 1}]]
            set parts [lmap item $payload {string cat $inner [Write $item [expr {$level + 1}]]}]
            return "\[\n[join $parts ",\n"]\n[string repeat "  " $level]\]"
        }
        obj {
            if {$payload eq ""} { return "\{\}" }
            set inner [string repeat "  " [expr {$level + 1}]]
            set parts {}
            foreach {key item} $payload {
                lappend parts "$inner\"[string map $escapes $key]\": [Write $item [expr {$level + 1}]]"
            }
            return "\{\n[join $parts ",\n"]\n[string repeat "  " $level]\}"
        }
        default { error "pm::json::encode: not a JSON value: $value" }
    }
}
