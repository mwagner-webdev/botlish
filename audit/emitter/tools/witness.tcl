# witness.tcl -- grammar-directed generation from a declaration
# (EMITTER-COROUTINE-EXPLORATION.md, "Generation from the grammar"): for each
# declared recognizer of a workspace, a breadth-first walk of the emission
# automaton the checker uses (emitcheck::Step over the effective tables)
# gives the shortest token, and a coverage witness for every transition of
# every composite state: the shortest token that takes it. Each witness is
# then held to the reference interpreter of tests/dfa-support.tcl (which
# reads the declarations, not the effective table) and, for the JSON
# tokens, to the oracle.
#
#   tclsh9.0 audit/emitter/tools/witness.tcl ?-out FILE?
#
# A symbol stands for its segment of a state's row: the first of
# a-z, 0-9, A-Z, then the lowest symbol of the segment in the alphabet.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set options [dict create -out ""]
foreach {option value} $argv {
    dict set options $option $value
}
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root tests dfa-support.tcl]
source [file join $root audit emitter tools workspace.tcl]
source [file join $root audit emitter tools emitcheck.tcl]
source [file join $root audit emitter tools support.tcl]
interp recursionlimit {} 100000

namespace eval witness {}

# The representative of interval set SET in ALPHABET, or "" (none in it).
proc witness::Representative {set alphabet} {
    set inside [surface::dfa::Inter $set [list [surface::dfa::AlphabetHull $alphabet]]]
    if {$alphabet eq "unicode"} {
        set inside [surface::dfa::Inter $inside $::emitcheck::scalars]
    }
    foreach range {{97 122} {48 57} {65 90}} {
        set y [surface::dfa::Inter $inside [list $range]]
        if {$y ne {}} {
            return [lindex $y 0 0]
        }
    }
    if {$inside eq {}} {
        return ""
    }
    return [lindex $inside 0 0]
}

# The edges of composite C: {SYMBOL RESULT} per segment of its row that has
# a representative and does not violate (RESULT a composite or done).
proc witness::Edges {c alphabet} {
    set out {}
    foreach r [emitcheck::Step $c [surface::dfa::Minus [surface::dfa::Universe] {{-1 -1}}]] {
        lassign $r y result
        if {[lindex $result 0] eq "violation"} continue
        set s [Representative $y $alphabet]
        if {$s ne ""} {
            lappend out [list $s $result]
        }
    }
    return $out
}

# Whether composite C accepts the end.
proc witness::Ends {c} {
    if {$c eq "done"} {
        return 1
    }
    foreach r [emitcheck::Step $c {{-1 -1}}] {
        if {[lindex $r 1] ne "done"} {
            return 0
        }
    }
    return 1
}

# For recognizer KEY: {STATES SHORTEST WITNESSES}: the composite states
# reached, the shortest token, and per transition (composite, symbol) the
# shortest token taking it.
proc witness::Analyze {key} {
    set alphabet [dict get $::emitcheck::models $key alphabet]
    set start [emitcheck::Initial $key]
    # Shortest prefixes, breadth first.
    set prefix [dict create $start {}]
    set work [list $start]
    set edges [dict create]
    while {[llength $work]} {
        set work [lassign $work c]
        if {$c eq "done"} continue
        dict set edges $c [Edges $c $alphabet]
        foreach e [dict get $edges $c] {
            lassign $e s r
            if {![dict exists $prefix $r]} {
                dict set prefix $r [concat [dict get $prefix $c] $s]
                lappend work $r
            }
        }
    }
    # Shortest completions, by rounds (a state's completion: the end, or a
    # symbol then the next state's completion).
    set completion [dict create]
    dict for {c -} $prefix {
        if {[Ends $c]} {
            dict set completion $c {}
        }
    }
    set changed 1
    while {$changed} {
        set changed 0
        dict for {c es} $edges {
            foreach e $es {
                lassign $e s r
                if {![dict exists $completion $r]} continue
                set candidate [concat $s [dict get $completion $r]]
                if {![dict exists $completion $c] || [llength $candidate] < [llength [dict get $completion $c]]} {
                    dict set completion $c $candidate
                    set changed 1
                }
            }
        }
    }
    set witnesses [dict create]
    dict for {c es} $edges {
        foreach e $es {
            lassign $e s r
            if {![dict exists $completion $r]} continue
            dict set witnesses [list $c $s] [concat [dict get $prefix $c] $s [dict get $completion $r]]
        }
    }
    return [list [dict size $prefix] [dict get $completion $start] $witnesses]
}

proc witness::Shown {symbols alphabet} {
    return [join [lmap s $symbols {
        if {$alphabet eq "bytes" && $s > 127} {
            format {\x%02X} $s
        } elseif {$s < 32 || $s == 127} {
            format {\u%04X} $s
        } else {
            format %c $s
        }
    }] ""]
}

set dir [emitws::scratch]
set emitcheck::models [emitcheck::Models [file join $dir check_all.bot]]
set reference [dfaref::load [list json_lex [file join $dir json_lex.bot] json_grammar [file join $dir json_grammar.bot]]]
set report "# Grammar-directed generation: witnesses\n\n"
append report "Generated by audit/emitter/tools/witness.tcl: per declared recognizer, the composite states the emission automaton reaches, its shortest token, and one shortest token per transition of every composite state (a coverage witness), each held to the reference interpreter (tests/dfa-support.tcl) and, for JSON tokens over Unicode, to the oracle.\n\n"
append report "| recognizer | alphabet | composite states | transitions | shortest token | witnesses the reference accepts | oracle (valid JSON) |\n|---|---|---:|---:|---|---:|---:|\n"
set details ""
set failures 0
foreach key [lsort [dict keys $emitcheck::models]] {
    lassign $key ns name
    set alphabet [dict get $emitcheck::models $key alphabet]
    lassign [witness::Analyze $key] states shortest witnesses
    set tokens [lsort -unique [dict values $witnesses]]
    set accepted 0
    foreach t $tokens {
        set ref [dfaref::text [dfaref::run $reference $ns $name [concat $t -1] 0]]
        if {$ref eq "accept [llength $t] 0"} {
            incr accepted
        } else {
            incr failures
            puts "[emitcheck::KeyText $key]: witness [witness::Shown $t $alphabet] is not accepted by the reference: $ref"
        }
    }
    set oracle --
    if {$ns eq "json_lex" && $name in {json_number json_literal json_string json_string_strict json_token} || $name eq "json_text"} {
        set verdicts [emitsup::oracle [lmap t $tokens {emitsup::case unicode $t}]]
        set oracle [llength [lsearch -all -glob $verdicts valid*]]/[llength $tokens]
    } elseif {$name in {json_string_bytes json_token_bytes json_text_bytes}} {
        set verdicts [emitsup::oracle [lmap t $tokens {emitsup::case bytes $t}]]
        set oracle [llength [lsearch -all -glob $verdicts valid*]]/[llength $tokens]
    }
    append report "| [emitcheck::KeyText $key] | $alphabet | $states | [dict size $witnesses] | `[witness::Shown $shortest $alphabet]` | $accepted/[llength $tokens] | $oracle |\n"
    if {$name in {json_number json_string_strict utf8_char}} {
        append details "\n### [emitcheck::KeyText $key]: its coverage witnesses\n\n"
        append details [join [lmap t $tokens {string cat "`" [string map {` \\`} [witness::Shown $t $alphabet]] "`"}] ", "]\n
    }
}
file delete -force $dir
append report $details
puts $report
if {[dict get $options -out] ne ""} {
    set f [open [dict get $options -out] w]
    fconfigure $f -encoding utf-8 -translation lf
    puts -nonewline $f $report
    close $f
}
exit [expr {$failures > 0}]
