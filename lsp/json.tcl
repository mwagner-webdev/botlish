# json.tcl -- JSON values for the language server (LSP-MILESTONE-1.md,
# "JSON and JSON-RPC").
#
#   lsp::json::decode BYTES        the value of UTF-8 JSON text (strict)
#   lsp::json::parse TEXT          the value of JSON text (a Tcl string)
#   lsp::json::encode VALUE        its UTF-8 JSON text
#   lsp::json::write VALUE         its JSON text (a Tcl string)
#
# A JSON value is a typed Tcl value, a two-element list {TYPE PAYLOAD}:
#
#   {null {}}          null
#   {bool 0|1}         false, true
#   {num TEXT}         a number, as its JSON text: never converted, so an
#                      integer of any size, a request id of 0, a fraction or
#                      an exponent round-trips exactly as the peer wrote it
#   {str TEXT}         a string, its Unicode text
#   {arr {V ...}}      an array of values
#   {obj {KEY V ...}}  an object: a dict from key strings to values, in the
#                      order the keys first appear (a repeated key keeps its
#                      last value)
#
# Nothing is ever guessed from a Tcl string's contents: "true", "1" and
# "null" are strings when the JSON text quotes them, and numbers and literals
# only when it does not. Constructors (str num int bool null arr arrayOf obj)
# build values; accessors (type, get, has, dig, text, integer, boolean,
# elements, members) read them and raise {LSP JSON TYPE} when a value is not
# of the type asked for.
#
# Errors: decode and parse raise {LSP JSON MALFORMED OFFSET} for text that is
# not one JSON value (OFFSET counts characters) and {LSP JSON ENCODING} for
# bytes that are not UTF-8. A string escape naming half of a surrogate pair
# without its other half is malformed: JSON text names Unicode scalar values
# here, never lone surrogates.
#
# This layer knows nothing of JSON-RPC or of the language server; the native
# Botlish implementation the census plans (an exported C function over UTF-8
# bytes) can replace it behind decode and encode.

namespace eval lsp::json {
    # The deepest nesting parse accepts: a peer cannot exhaust the Tcl stack.
    variable maxDepth 256
    # String escapes for write: the two characters JSON requires escaped and
    # every control character.
    variable escapes [list \\ \\\\ \" \\\" \n \\n \r \\r \t \\t \b \\b \f \\f]
    for {set c 0} {$c < 32} {incr c} {
        if {[format %c $c] ni {\n \r \t \b \f}} {
            lappend escapes [format %c $c] [format \\u%04x $c]
        }
    }
    unset c
    # The two-character escapes and what they stand for (String).
    variable simple [list \\\" \" \\\\ \\ \\/ / \\b \b \\f \f \\n \n \\r \r \\t \t]
}

proc lsp::json::Fail {offset message} {
    return -code error -level 2 -errorcode [list LSP JSON MALFORMED $offset] \
        "malformed JSON at offset $offset: $message"
}

# ---------------------------------------------------------------------------
# Constructors

proc lsp::json::null {} { return {null {}} }
proc lsp::json::bool {value} { return [::list bool [expr {$value ? 1 : 0}]] }
proc lsp::json::str {text} { return [::list str $text] }

# A number from its JSON text (any JSON number).
proc lsp::json::num {text} {
    if {![regexp {^-?(?:0|[1-9][0-9]*)(?:\.[0-9]+)?(?:[eE][+-]?[0-9]+)?$} $text]} {
        error "lsp::json::num: not a JSON number: \"$text\""
    }
    return [::list num $text]
}

# A number from a Tcl integer.
proc lsp::json::int {value} {
    if {![::string is entier -strict $value]} {
        error "lsp::json::int: not an integer: \"$value\""
    }
    return [::list num [expr {$value + 0}]]
}

proc lsp::json::arr {args} { return [::list arr $args] }

# An array of the values of the Tcl list VALUES.
proc lsp::json::arrayOf {values} { return [::list arr $values] }

# An object of KEY VALUE ... (VALUE a JSON value).
proc lsp::json::obj {args} {
    if {[llength $args] % 2} {
        error "lsp::json::obj: keys and values come in pairs"
    }
    return [::list obj [dict create {*}$args]]
}

# ---------------------------------------------------------------------------
# Accessors

proc lsp::json::type {value} { return [lindex $value 0] }

proc lsp::json::TypeError {value wanted what} {
    return -code error -level 2 -errorcode [list LSP JSON TYPE $wanted] \
        "$what: expected a JSON $wanted, found [Describe $value]"
}

proc lsp::json::Describe {value} {
    switch -- [lindex $value 0] {
        null { return null }
        bool { return [expr {[lindex $value 1] ? "true" : "false"}] }
        num  { return "the number [lindex $value 1]" }
        str  { return "a string" }
        arr  { return "an array" }
        obj  { return "an object" }
    }
    return "no JSON value"
}

# 1 if OBJECT is an object with KEY.
proc lsp::json::has {object key} {
    return [expr {[lindex $object 0] eq "obj" && [dict exists [lindex $object 1] $key]}]
}

# The value of KEY in OBJECT; DEFAULT (when given) if OBJECT is not an object
# or lacks KEY, else {LSP JSON TYPE}.
proc lsp::json::get {object key args} {
    if {[lindex $object 0] eq "obj" && [dict exists [lindex $object 1] $key]} {
        return [dict get [lindex $object 1] $key]
    }
    if {[llength $args]} {
        return [lindex $args 0]
    }
    if {[lindex $object 0] ne "obj"} {
        TypeError $object object "member \"$key\""
    }
    return -code error -errorcode [list LSP JSON MISSING $key] "missing member \"$key\""
}

# The value at the path of keys KEYS in OBJECT, or DEFAULT where one is
# missing.
proc lsp::json::dig {object keys default} {
    foreach key $keys {
        if {![has $object $key]} {
            return $default
        }
        set object [dict get [lindex $object 1] $key]
    }
    return $object
}

proc lsp::json::text {value {what value}} {
    if {[lindex $value 0] ne "str"} {
        TypeError $value string $what
    }
    return [lindex $value 1]
}

proc lsp::json::boolean {value {what value}} {
    if {[lindex $value 0] ne "bool"} {
        TypeError $value boolean $what
    }
    return [lindex $value 1]
}

# The integer VALUE holds: a JSON number written as an integer (no fraction
# or exponent).
proc lsp::json::integer {value {what value}} {
    if {[lindex $value 0] ne "num" || ![regexp {^-?(?:0|[1-9][0-9]*)$} [lindex $value 1]]} {
        TypeError $value integer $what
    }
    return [lindex $value 1]
}

proc lsp::json::elements {value {what value}} {
    if {[lindex $value 0] ne "arr"} {
        TypeError $value array $what
    }
    return [lindex $value 1]
}

proc lsp::json::members {value {what value}} {
    if {[lindex $value 0] ne "obj"} {
        TypeError $value object $what
    }
    return [lindex $value 1]
}

# ---------------------------------------------------------------------------
# Reading

proc lsp::json::decode {bytes} {
    if {[catch {encoding convertfrom -profile strict utf-8 $bytes} text]} {
        return -code error -errorcode {LSP JSON ENCODING} "JSON text that is not UTF-8: $text"
    }
    return [parse $text]
}

proc lsp::json::parse {text} {
    set i 0
    set value [Value $text i 0]
    regexp -start $i -indices {\A[ \t\n\r]*} $text space
    set i [expr {[lindex $space 1] + 1}]
    if {$i < [::string length $text]} {
        Fail $i "unexpected text after the value"
    }
    return $value
}

# The value starting at (or after whitespace from) offset *I of TEXT; *I is
# left after it.
proc lsp::json::Value {text iVar depth} {
    upvar 1 $iVar i
    variable maxDepth
    regexp -start $i -indices {\A[ \t\n\r]*} $text space
    set i [expr {[lindex $space 1] + 1}]
    set c [::string index $text $i]
    switch -- $c {
        "\"" {
            return [::list str [String $text i]]
        }
        "\{" {
            if {$depth >= $maxDepth} {
                Fail $i "nested deeper than $maxDepth"
            }
            incr i
            set members [dict create]
            if {[regexp -start $i -indices {\A[ \t\n\r]*\}} $text close]} {
                set i [expr {[lindex $close 1] + 1}]
                return [::list obj $members]
            }
            while 1 {
                regexp -start $i -indices {\A[ \t\n\r]*} $text space
                set i [expr {[lindex $space 1] + 1}]
                if {[::string index $text $i] ne "\""} {
                    Fail $i "expected a member name (a string)"
                }
                set key [String $text i]
                if {![regexp -start $i -indices {\A[ \t\n\r]*:} $text colon]} {
                    Fail $i "expected \":\" after a member name"
                }
                set i [expr {[lindex $colon 1] + 1}]
                dict set members $key [Value $text i [expr {$depth + 1}]]
                if {[regexp -start $i -indices {\A[ \t\n\r]*([,\}])} $text - sep]} {
                    set i [expr {[lindex $sep 1] + 1}]
                    if {[::string index $text [lindex $sep 0]] eq "\}"} {
                        return [::list obj $members]
                    }
                    continue
                }
                Fail $i "expected \",\" or \"\}\" in an object"
            }
        }
        "\[" {
            if {$depth >= $maxDepth} {
                Fail $i "nested deeper than $maxDepth"
            }
            incr i
            set elements {}
            if {[regexp -start $i -indices {\A[ \t\n\r]*\]} $text close]} {
                set i [expr {[lindex $close 1] + 1}]
                return [::list arr $elements]
            }
            while 1 {
                lappend elements [Value $text i [expr {$depth + 1}]]
                if {[regexp -start $i -indices {\A[ \t\n\r]*([,\]])} $text - sep]} {
                    set i [expr {[lindex $sep 1] + 1}]
                    if {[::string index $text [lindex $sep 0]] eq "\]"} {
                        return [::list arr $elements]
                    }
                    continue
                }
                Fail $i "expected \",\" or \"\]\" in an array"
            }
        }
        t {
            if {[::string range $text $i [expr {$i + 3}]] eq "true"} {
                incr i 4
                return {bool 1}
            }
        }
        f {
            if {[::string range $text $i [expr {$i + 4}]] eq "false"} {
                incr i 5
                return {bool 0}
            }
        }
        n {
            if {[::string range $text $i [expr {$i + 3}]] eq "null"} {
                incr i 4
                return {null {}}
            }
        }
        "" {
            Fail $i "unexpected end of text"
        }
        default {
            if {[regexp -start $i -indices {\A-?(?:0|[1-9][0-9]*)(?:\.[0-9]+)?(?:[eE][+-]?[0-9]+)?} $text number]} {
                set i [expr {[lindex $number 1] + 1}]
                return [::list num [::string range $text {*}$number]]
            }
        }
    }
    Fail $i "expected a value"
}

# The string whose opening quote is at offset *I of TEXT, decoded; *I is
# left after its closing quote.
proc lsp::json::String {text iVar} {
    upvar 1 $iVar i
    variable simple
    # The common case in one regular expression match: a well-formed string
    # without \u escapes (a document's text is mostly this). Anything else,
    # including every malformed string, takes the loop below, which says
    # exactly what is wrong.
    if {[regexp -start $i -indices {\A"((?:[^"\\\u0000-\u001f]|\\["\\/bfnrt])*)"} $text all body]} {
        set i [expr {[lindex $all 1] + 1}]
        set body [::string range $text {*}$body]
        if {[::string first \\ $body] < 0} {
            return $body
        }
        return [::string map $simple $body]
    }
    set start $i
    incr i
    set out ""
    while 1 {
        if {![regexp -start $i -indices {["\\\u0000-\u001f]} $text stop]} {
            Fail $start "unterminated string"
        }
        set j [lindex $stop 0]
        append out [::string range $text $i [expr {$j - 1}]]
        set c [::string index $text $j]
        if {$c eq "\""} {
            set i [expr {$j + 1}]
            return $out
        }
        if {$c ne "\\"} {
            Fail $j "a control character (U+[format %04X [scan $c %c]]) in a string must be escaped"
        }
        set e [::string index $text [expr {$j + 1}]]
        switch -- $e {
            "\"" { append out "\"" }
            "\\" { append out "\\" }
            "/"  { append out "/" }
            b    { append out "\b" }
            f    { append out "\f" }
            n    { append out "\n" }
            r    { append out "\r" }
            t    { append out "\t" }
            u {
                set code [Hex4 $text [expr {$j + 2}]]
                if {$code >= 0xDC00 && $code <= 0xDFFF} {
                    Fail $j "a low surrogate escape without its high surrogate"
                }
                if {$code >= 0xD800 && $code <= 0xDBFF} {
                    if {[::string range $text [expr {$j + 6}] [expr {$j + 7}]] ne "\\u"} {
                        Fail $j "a high surrogate escape without its low surrogate"
                    }
                    set low [Hex4 $text [expr {$j + 8}]]
                    if {$low < 0xDC00 || $low > 0xDFFF} {
                        Fail $j "a high surrogate escape without its low surrogate"
                    }
                    set code [expr {0x10000 + (($code - 0xD800) << 10) + ($low - 0xDC00)}]
                    incr j 6
                }
                append out [format %c $code]
                set i [expr {$j + 6}]
                continue
            }
            default {
                Fail $j "an invalid escape \"\\$e\""
            }
        }
        set i [expr {$j + 2}]
    }
}

proc lsp::json::Hex4 {text at} {
    set digits [::string range $text $at [expr {$at + 3}]]
    if {![regexp {^[0-9A-Fa-f]{4}$} $digits]} {
        Fail $at "a \\u escape needs four hexadecimal digits"
    }
    return [expr {"0x$digits"}]
}

# ---------------------------------------------------------------------------
# Writing

proc lsp::json::encode {value} {
    return [encoding convertto utf-8 [write $value]]
}

proc lsp::json::write {value} {
    set payload [lindex $value 1]
    switch -- [lindex $value 0] {
        null { return null }
        bool { return [expr {$payload ? "true" : "false"}] }
        num  { return $payload }
        str  { return [Quote $payload] }
        arr {
            return "\[[join [lmap element $payload {write $element}] ,]\]"
        }
        obj {
            set members {}
            dict for {key member} $payload {
                lappend members "[Quote $key]:[write $member]"
            }
            return "\{[join $members ,]\}"
        }
    }
    error "lsp::json::write: not a JSON value: [::string range $value 0 80]"
}

# TEXT as a JSON string. A lone surrogate (a Tcl string can hold one) is
# written as its escape, so the text stays valid UTF-8.
proc lsp::json::Quote {text} {
    variable escapes
    set quoted [::string map $escapes $text]
    if {[regexp {[\uD800-\uDFFF]} $quoted]} {
        set out ""
        foreach c [split $quoted ""] {
            scan $c %c code
            if {$code >= 0xD800 && $code <= 0xDFFF} {
                append out [format \\u%04x $code]
            } else {
                append out $c
            }
        }
        set quoted $out
    }
    return "\"$quoted\""
}
