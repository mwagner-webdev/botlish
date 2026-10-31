# conformance.tcl -- the checker's recognizer semantics against the
# reference interpreter (MODULAR-EMISSION-PROOFS-MILESTONE-1.md, section 11).
#
#   tclsh9.0 audit/emission-proofs/tools/conformance.tcl ?-count N? ?-seed S?
#   conformance::run ENTRY KEYS ?COUNT? ?SEED?   => {CASES MISMATCHES}
#
# dfasem.tcl reads the lowering's own table (surface::dfa::Codes) and states
# once what each code means; tests/dfa-support.tcl's reference interpreter
# reads the declarations themselves (no effective table, nothing of
# surface/dfa.tcl), and tests/dfa.test holds the compiled recognizers to it.
# Here every case dfatest::cases makes for a recognizer (every interesting
# symbol, the breadth-first frontier of its configurations, random walks,
# each ended by the end of the input, a symbol, or nothing) is run through
# dfasem's composite step one symbol at a time and its outcome compared with
# the reference's: accepted with the same token length and unread count,
# rejected by the same recognizer in the same state at the same index, or
# still waiting.

set conformanceMain [expr {[info exists argv0] && [file normalize $argv0] eq [file normalize [info script]]}]
if {$conformanceMain} {
    set conformanceArgs $argv
    set argv {}
}
if {[info commands ::dfaref::run] eq ""} {
    source [file join [file dirname [file normalize [info script]]] concrete.tcl]
}
if {[info commands ::dfasem::Step] eq ""} {
    source [file join [file dirname [file normalize [info script]]] modcheck.tcl]
}

namespace eval conformance {}

# dfasem's outcome for INPUTS (symbols, -1 the end) from recognizer KEY, in
# dfaref::text's form.
proc conformance::Outcome {key inputs} {
    set c [dfasem::Initial $key]
    set i 0
    foreach x $inputs {
        set r [dfasem::Step $c [intset::point $x]]
        if {[llength $r] != 1} {
            return "nondeterministic at $i"
        }
        lassign [lindex $r 0] y result
        if {$result eq "done"} {
            # Completed with nothing unread: on its own last symbol, or at
            # the end.
            if {$x == -1} {
                return "accept $i 0"
            }
            return "accept [expr {$i + 1}] 0"
        }
        if {[lindex $result 0] eq "violation"} {
            lassign $result - kind rkey q n
            switch -- $kind {
                beyond {
                    if {$x == -1} {
                        return "accept [expr {$i - $n}] $n"
                    }
                    return "accept [expr {$i + 1 - $n}] $n"
                }
                reject {
                    set what [expr {$x == -1 ? "end" : "unrecognized"}]
                    return "$what [dfasem::Get $rkey qualified] $q $i"
                }
                default {
                    return "$kind $i"
                }
            }
        }
        set c $result
        incr i
    }
    return suspended
}

proc conformance::run {entry keys {count 40} {seed 1}} {
    set files [dfasem::ApplicationFiles $entry]
    set model [dfaref::load [concat {*}[lmap {ns p} $files {list $ns $p}]]]
    set cases 0
    set mismatches {}
    foreach key $keys {
        lassign $key ns name
        foreach input [dfatest::cases $model $ns $name $count $seed] {
            incr cases
            set ref [dfaref::text [dfaref::run $model $ns $name $input 0]]
            set got [Outcome $key $input]
            if {$ref ne $got} {
                lappend mismatches [list $key $input $ref $got]
            }
        }
    }
    return [list $cases $mismatches]
}

if {$conformanceMain} {
    set options [dict merge {-count 40 -seed 1 -out ""} $conformanceArgs]
    source [file join [file dirname [file normalize [info script]]] workspace.tcl]
    set dir [epws::scratch main.bot "import json_grammar\n\n0\n" la.bot \
        "import std::dfa\n\ndfa ab over ascii:\n    start:\n        'a' -> one\n    one:\n        'b' -> two\n    two:\n        'c' -> accept before 2\n        end -> accept\n\ndfa ab_more over ascii:\n    start:\n        'b' -> more\n    more:\n        'b' -> more\n        ')' 'c' -> accept before\n        end -> reject\n\ndfa wrap over ascii:\n    start:\n        '(' -> inner\n    inner:\n        'a' -> call ab then accept
        'b' -> call ab_more then close\n    close:\n        ')' -> accept\n        'c' -> accept\n" \
        main2.bot "import la\nimport json_grammar\n\n0\n"]
    set entry [file join $dir main2.bot]
    set keys [dfasem::load $entry]
    lassign [conformance::run $entry $keys [dict get $options -count] [dict get $options -seed]] cases mismatches
    set lines [list "## Recognizer semantics: dfasem against the reference interpreter" "" \
        "[llength $keys] recognizers ([join [lmap k $keys {dfasem::KeyText $k}] {, }]), $cases cases, seed [dict get $options -seed]: [llength $mismatches] mismatches"]
    foreach m [lrange $mismatches 0 20] {
        lassign $m key input ref got
        lappend lines "* [dfasem::KeyText $key] [list $input]: reference `$ref`, dfasem `$got`"
    }
    set text [join $lines \n]
    if {[dict get $options -out] ne ""} {
        set f [open [dict get $options -out] w]
        puts $f $text
        close $f
    }
    puts $text
    exit [expr {[llength $mismatches] > 0}]
}
