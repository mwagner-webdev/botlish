# support.tcl -- what the emitter experiment's tools and tests share
# (EMITTER-COROUTINE-EXPLORATION.md): Botlish literals of generated cases,
# their canonical JSON text (written here, independently of every Botlish
# emitter: every non-ASCII character escaped), random cases, and reading a
# program's List-of-Lists-of-Int value.
#
#   source audit/emitter/tools/support.tcl   (after tests/helpers.tcl)

namespace eval emitsup {}

# A Botlish string literal of TEXT: the five escapes the lexer has, every
# other character raw (a raw control character included).
proc emitsup::literal {text} {
    return "\"[string map {\\ \\\\ \" \\\" \n \\n \r \\r \t \\t} $text]\""
}

# The scalar values of TEXT.
proc emitsup::scalars {text} {
    return [lmap c [split $text ""] {scan $c %c}]
}

# The UTF-8 bytes of TEXT.
proc emitsup::utf8 {text} {
    binary scan [encoding convertto utf-8 $text] cu* bytes
    return $bytes
}

# TEXT as a JSON string, ASCII only: a policy no Botlish emitter has (every
# character past U+007E escaped, the controls as \u00XX).
proc emitsup::jsonString {text} {
    set out \"
    foreach c [split $text ""] {
        scan $c %c v
        if {$v == 34} {
            append out {\"}
        } elseif {$v == 92} {
            append out {\\}
        } elseif {$v >= 32 && $v < 127} {
            append out $c
        } elseif {$v < 0x10000} {
            append out [format {\u%04x} $v]
        } else {
            set u [expr {$v - 0x10000}]
            append out [format {\u%04x\u%04x} [expr {0xD800 + ($u >> 10)}] [expr {0xDC00 + ($u & 0x3FF)}]]
        }
    }
    return $out\"
}

# A JSON value V ({null} {true} {false} {number N} {string TEXT} {array
# {V...}} {object {{KEY V}...}}) as JSON text, and as a Botlish expression
# of value_emit's constructors.
proc emitsup::json {v} {
    lassign $v kind x
    switch -- $kind {
        null - true - false { return $kind }
        number { return $x }
        string { return [jsonString $x] }
        array { return "\[[join [lmap e $x {json $e}] ,]\]" }
        object { return "\{[join [lmap m $x {string cat [jsonString [lindex $m 0]] : [json [lindex $m 1]]}] ,]\}" }
    }
}

proc emitsup::botlish {v} {
    lassign $v kind x
    switch -- $kind {
        null { return "value_emit::null_value()" }
        true { return "value_emit::boolean(true)" }
        false { return "value_emit::boolean(false)" }
        number { return "value_emit::number($x)" }
        string { return "value_emit::string([literal $x])" }
        array { return "value_emit::array(\[[join [lmap e $x {botlish $e}] {, }]\])" }
        object {
            set keys [lmap m $x {literal [lindex $m 0]}]
            set values [lmap m $x {botlish [lindex $m 1]}]
            if {$keys eq {}} {
                return "value_emit::object(no_keys(), \[\])"
            }
            return "value_emit::object(\[[join $keys {, }]\], \[[join $values {, }]\])"
        }
    }
}

# ---------------------------------------------------------------------------
# Random cases (a seeded generator of Tcl's own: expr srand/rand)

proc emitsup::seed {n} {
    expr {srand($n)}
}

proc emitsup::below {n} {
    return [expr {int(rand() * $n)}]
}

proc emitsup::pick {list} {
    return [lindex $list [below [llength $list]]]
}

# An Int of a random magnitude: zero, small, near a power of two or ten,
# or a long run of random digits; either sign.
proc emitsup::integer {} {
    set n [switch -- [below 6] {
        0 { expr {[below 10]} }
        1 { expr {[below 100000]} }
        2 { expr {2 ** [below 200] + [below 3] - 1} }
        3 { expr {10 ** [below 60] + [below 3] - 1} }
        4 {
            set d [expr {1 + [below 9]}]
            for {set i [below 300]} {$i > 0} {incr i -1} {
                append d [below 10]
            }
            set d
        }
        5 { expr {9223372036854775807 + [below 5] - 2} }
    }]
    if {[below 2]} {
        set n [expr {-$n}]
    }
    return $n
}

# A Unicode scalar value from one of the classes a string emitter
# distinguishes.
proc emitsup::scalar {} {
    switch -- [below 11] {
        0 - 1 - 2 { return [expr {32 + [below 95]}] }
        3 { return [pick {34 92 47}] }
        4 { return [below 32] }
        5 { return 127 }
        6 { return [expr {128 + [below 1920]}] }
        7 { return [expr {0x800 + [below [expr {0xD800 - 0x800}]]}] }
        8 { return [expr {0xD000 + [below 0x800]}] }
        9 { return [expr {0xE000 + [below 0x2000]}] }
        10 { return [expr {0x10000 + [below 0x100000]}] }
    }
}

proc emitsup::text {{max 24}} {
    set out ""
    for {set i [below $max]} {$i > 0} {incr i -1} {
        append out [format %c [scalar]]
    }
    return $out
}

# A random JSON value of nesting at most DEPTH.
proc emitsup::value {depth} {
    set k [below [expr {$depth > 0 ? 9 : 5}]]
    switch -- $k {
        0 { return {null} }
        1 { return [pick {{true} {false}}] }
        2 { return [list number [integer]] }
        3 - 4 { return [list string [text 12]] }
        5 - 6 {
            set items {}
            for {set i [below 5]} {$i > 0} {incr i -1} {
                lappend items [value [expr {$depth - 1}]]
            }
            return [list array $items]
        }
        default {
            set members {}
            for {set i [below 5]} {$i > 0} {incr i -1} {
                set key [if {[below 4] == 0 && $members ne {}} {lindex $members 0 0} else {text 6}]
                lappend members [list $key [value [expr {$depth - 1}]]]
            }
            return [list object $members]
        }
    }
}

# ---------------------------------------------------------------------------
# Programs

# The Lists of a Botlish value List[List[int]] as shown (core::value::show).
proc emitsup::lists {shown} {
    return [lmap l [regexp -all -inline {\[[-0-9, ]*\]} [string range $shown 1 end-1]] {
        string map {, ""} [string range $l 1 end-1]
    }]
}

# The oracle's verdict on each of LINES (tools/oracle.py's input lines).
proc emitsup::oracle {lines} {
    set f [open "|python3 -I [list [file join $::emitws::root audit emitter tools oracle.py]]" r+]
    fconfigure $f -encoding utf-8
    puts -nonewline $f [join $lines \n]\n
    close $f write
    set out [split [string trim [read $f]] \n]
    close $f
    return $out
}

# An oracle line: KIND, SYMBOLS (a Tcl list of Ints), the expected JSON
# text EXPECTED ("" for none).
proc emitsup::case {kind symbols {expected ""}} {
    set line "$kind [expr {$symbols eq {} ? "-" : [join $symbols ,]}]"
    if {$expected ne ""} {
        binary scan [encoding convertto utf-8 $expected] H* hex
        append line " $hex"
    }
    return $line
}

# Applies case NAME of the census (audit/emitter/census/cases.txt) to the
# workspace DIR: its text replaced in its file (exactly one occurrence, or
# an error).
proc emitsup::mutate {dir name} {
    set path [file join $::emitws::root audit emitter census cases.txt]
    set f [open $path]
    fconfigure $f -encoding utf-8
    set lines [split [read $f] \n]
    close $f
    set i [lsearch -glob $lines "@@ $name *"]
    if {$i < 0} {
        error "no census case $name"
    }
    set file [lindex [lindex $lines $i] 2]
    set old {}
    set new {}
    set mode ""
    foreach l [lrange $lines [expr {$i + 1}] end] {
        switch -- $l {
            <<<< { set mode old; continue }
            ==== { set mode new; continue }
            >>>> { break }
        }
        lappend $mode $l
    }
    set target [file join $dir $file]
    set f [open $target]
    fconfigure $f -encoding utf-8
    set text [read $f]
    close $f
    set old [join $old \n]
    set at [string first $old $text]
    if {$at < 0 || [string first $old $text [expr {$at + 1}]] >= 0} {
        error "census case $name does not apply to $file"
    }
    set f [open $target w]
    fconfigure $f -encoding utf-8 -translation lf
    puts -nonewline $f [string replace $text $at [expr {$at + [string length $old] - 1}] [join $new \n]]
    close $f
}
