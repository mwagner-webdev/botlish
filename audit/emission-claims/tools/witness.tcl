# witness.tcl -- concrete counterexamples of emission claims
# (EMISSION-CLAIMS-MILESTONE-1.md, "Counterexamples"): running an emitter
# for real and judging its traces with the reference interpreter. A
# development and diagnostic tool, never part of compilation: the compiler
# reports what its analysis found ("may"); a claim is *disproven* only when a
# run shows it, and finding no witness proves nothing.
#
#   tclsh9.0 audit/emission-claims/tools/witness.tcl PROGRAM.bot
#       every claim of the program the compiler does not certify, with its
#       witness when the bounded search finds one
#
#   source audit/emission-claims/tools/witness.tcl   (sources tests/helpers.tcl)
#   emitw::traces DIR FN TYPES ERRORS TUPLES ?-backend B?
#       => {ARGS OUTCOME SYMBOLS}... : each argument tuple's run
#   emitw::witness DIR ENTRY HIR RECORD
#       => "" or {ARGS REASON}: the first candidate argument tuple whose run
#          of the claim's function completes with an invalid trace or yields
#          a non-viable prefix
#
# A run is a generated program in a copy of the program's directory with
# every emission claim removed (a claim is erased: the copy runs the same
# code, and a rejected claim no longer stops its compilation): the function
# called inside a coroutine root that catches every error it declares
# (completing with -3, `failed`) and completes with -1 (`complete`); the
# consumer collects the symbols. Argument values come from lists the
# compiler cannot see through (a list loop's elements), so a call that
# always fails for one constant is still compiled.

if {[info exists ::env(EMISSION_CLAIMS_ROOT)]} {
    set ::emitwRoot $::env(EMISSION_CLAIMS_ROOT)
} else {
    set ::emitwRoot [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
}
if {[info commands ::tcltest::test] eq ""} {
    source [file join $::emitwRoot tests helpers.tcl]
}
if {[info commands ::emit::judge] eq ""} {
    source [file join $::projectRoot tests emission-support.tcl]
}

namespace eval emitw {
    variable limit 400
    variable maxTuples 120
    variable counter 0
}

# The source spelling of HIR type TYPE for a driver, or "" when the driver
# cannot write its values.
proc emitw::Spelling {type} {
    if {$type in {int str bool}} { return $type }
    if {[lindex $type 0] eq "refined" && [lindex $type 1] eq "int"} {
        return [lindex $type 2]
    }
    if {$type eq {list int}} { return "List\[int\]" }
    return ""
}

proc emitw::Literal {type v} {
    switch -- $type {
        str {
            set out "\""
            foreach ch [split $v ""] {
                switch -- $ch {
                    "\"" - "\\" { append out \\$ch }
                    "\n" { append out "\\n" }
                    "\r" { append out "\\r" }
                    "\t" { append out "\\t" }
                    default { append out $ch }
                }
            }
            return "$out\""
        }
        bool { if {$v} { return true } else { return false } }
    }
    if {$type eq {list int}} {
        return "\[[join $v {, }]\]"
    }
    return $v
}

# A copy of DIR (its .bot files) with every emission claim removed: a new
# directory.
proc emitw::Stripped {dir} {
    set copy [emit::workspace]
    foreach path [glob -nocomplain -directory $copy *.bot] {
        file delete $path
    }
    foreach path [glob -directory $dir *.bot] {
        emit::writeText [file join $copy [file tail $path]] [emit::strip [emit::readText $path]]
    }
    return $copy
}

# The traces of FN (its name as an entry program sees it: NS::NAME) for each
# argument tuple of TUPLES, its parameters of HIR types TYPES and its
# declared errors ERRORS, run in a program in DIR (a stripped copy).
proc emitw::traces {dir fn types errors tuples args} {
    variable limit
    variable counter
    set options [dict merge {-backend compile} $args]
    set ns [namespace qualifiers $fn]
    set spellings [lmap t $types {Spelling $t}]
    if {"" in $spellings} {
        return ""
    }
    set params [lmap t $spellings i [lsearch -all $types *] {string cat a$i ": " $t}]
    set names [lmap i [lsearch -all $types *] {string cat a$i}]
    set text ""
    if {$ns ne ""} { append text "import $ns\n" }
    append text "import std::coroutine\n\n"
    set call "${fn}([join $names {, }])"
    append text "fn src([join $params {, }]) -> int:\n"
    if {$errors eq {}} {
        append text "    $call\n"
    } else {
        append text "    $call:\n"
        foreach e $errors {
            append text "        on $e:\n            return -3\n"
        }
    }
    append text "    -1\n\n"
    append text "fn trace([join $params {, }]) -> List\[int\]:\n"
    append text "    coroutine {step, first} = src([join $names {, }])\n"
    append text "    loop k from 0 to $limit:\n"
    append text "        if k == 0:\n            first\n"
    append text "        elif std::coroutine::done?(step):\n            -9\n"
    append text "        else:\n            step()\n\n"
    foreach t $spellings type $types i [lsearch -all $types *] {
        append text "fn cases${i}() -> List\[$t\]{length: [llength $tuples]}:\n    \[[join [lmap tuple $tuples {Literal $type [lindex $tuple $i]}] {, }]\]\n\n"
    }
    if {$names eq {}} {
        append text "loop k from 0 to [llength $tuples]:\n    trace()\n"
    } else {
        set domains [join [lmap n $names i [lsearch -all $names *] {string cat "$n in cases${i}()"}] " and "]
        append text "loop $domains:\n    trace([join $names {, }])\n"
    }
    set file [file join $dir "witness_[pid]_[incr counter].bot"]
    emit::writeText $file $text
    set code [catch {
        set hir [surface::readProgramFile $file -warnings off]
        set outcome [outcomeUnderHir [dict get $options -backend] $hir]
    } msg]
    file delete $file
    if {$code} {
        return -code error "witness: $fn: $msg"
    }
    if {[lindex $outcome 0] ne "value"} {
        return -code error "witness: $fn: [lindex $outcome 2]"
    }
    set value [lindex [string map {\[ \{ \] \} , ""} [lindex $outcome 1]] 0]
    set out {}
    foreach tuple $tuples run $value {
        set end [lsearch -exact $run -9]
        if {$end < 0} {
            lappend out [list $tuple truncated $run]
            continue
        }
        set terminal [lindex $run [expr {$end - 1}]]
        set symbols [lrange $run 0 [expr {$end - 2}]]
        if {$terminal == -1} {
            lappend out [list $tuple complete $symbols]
        } else {
            lappend out [list $tuple failed $symbols]
        }
    }
    return $out
}

# Candidate values of HIR type TYPE (with the Int CONSTANTS of the code and
# their neighbors).
proc emitw::Candidates {type constants} {
    set ints {0 1 -1 2 7 8 9 10 15 16 31 32 33 34 47 48 49 57 58 92 127 128 255 256 999 -999
        65535 65536 1114111 1114112 2147483648 9223372036854775808 -9223372036854775809
        1000000000000000000000000}
    foreach k $constants {
        lappend ints $k [expr {$k - 1}] [expr {$k + 1}]
    }
    set ints [lsort -unique -command {apply {{a b} {
        set x [expr {abs($a)}]
        set y [expr {abs($b)}]
        if {$x < $y} { return -1 }
        if {$x > $y} { return 1 }
        if {$a < $b} { return -1 }
        if {$a > $b} { return 1 }
        return 0
    }}} $ints]
    switch -- $type {
        int { return $ints }
        str {
            return [list "" a "\"" "\\" "\n" "\x01" "\x1f" / "\x7f" "é" "😀" "\ud7ff" "\uffff" "a\"b\\c\td" \
                [string repeat "xé😀\"" 50]]
        }
        bool { return {1 0} }
    }
    if {$type eq {list int}} {
        return [list {} {0} {97} {34} {-1} {55296} {1114112} {97 0 128512} {92 10 1}]
    }
    if {[lindex $type 0] eq "refined"} {
        set facts [hir::intset::OfType $type]
        return [lmap k $ints {if {![hir::intset::contains $facts $k]} continue; set k}]
    }
    return {}
}

# Every Int constant in block B and the blocks it calls.
proc emitw::Constants {hir b} {
    set out {}
    set seen [dict create]
    set work [list $b]
    while {[llength $work]} {
        set work [lassign $work x]
        if {[dict exists $seen $x]} continue
        dict set seen $x 1
        set stack [dict get $hir exprs $x body]
        while {[llength $stack]} {
            set stack [lassign $stack e]
            set node [dict get $hir exprs $e]
            switch -- [dict get $node kind] {
                const {
                    set v [dict get $node value]
                    if {[core::value::kind $v] eq "int"} {
                        lappend out [core::value::intOf $v]
                    }
                }
                call {
                    lassign [dict get $node target] tk t
                    if {$tk eq "block" && [dict exists $hir exprs $t]} { lappend work $t }
                }
            }
            if {[dict get $node kind] ne "block"} {
                lappend stack {*}[hir::children $hir $e]
            }
        }
    }
    return [lsort -unique $out]
}

# The first argument tuple (of a bounded set of candidates) whose run of the
# function of claim RECORD (hir::emission::claims of HIR, the program at
# ENTRY in DIR) completes with an invalid trace or yields a non-viable
# prefix: {ARGS REASON}, or "".
proc emitw::witness {dir entry hir record} {
    variable maxTuples
    set b [dict get $record block]
    set node [dict get $hir exprs $b]
    set types [dict get $node declaredParamTypes]
    if {"" in $types} { return "" }
    set constants [Constants $hir $b]
    set lists [lmap t $types {Candidates $t $constants}]
    foreach l $lists {
        if {$l eq {}} { return "" }
    }
    set tuples {{}}
    foreach l $lists {
        set next {}
        foreach t $tuples {
            foreach v $l {
                lappend next [concat $t [list $v]]
            }
        }
        set tuples $next
    }
    if {[llength $tuples] > $maxTuples} {
        set step [expr {double([llength $tuples]) / $maxTuples}]
        set sample {}
        for {set i 0} {$i < $maxTuples} {incr i} {
            lappend sample [lindex $tuples [expr {int($i * $step)}]]
        }
        set tuples $sample
    }
    set copy [Stripped $dir]
    set errors [dict get $node declaredErrors]
    set fn [dict get $record function]
    if {[string first :: $fn] < 0} {
        # A function of the entry program: run from a module copy of its
        # declarations (the entry's own errors qualified by that module).
        lassign [EntryModule $copy [file tail $entry]] mod declared
        set fn ${mod}::$fn
        set errors [lmap e $errors {if {$e in $declared} {string cat ${mod}::$e} else {set e}}]
    }
    if {[catch {traces $copy $fn $types $errors $tuples} runs] || $runs eq ""} {
        return ""
    }
    set model [emit::reference $copy [file tail $entry]]
    set r [dict get $record recognizer]
    set key [list [namespace qualifiers $r] [namespace tail $r]]
    foreach run $runs {
        lassign $run tuple outcome symbols
        set verdict [emit::judge $model $key $outcome $symbols]
        if {$verdict ne "ok"} {
            return [list [join [lmap t $types v $tuple {Literal $t $v}] {, }] [lindex $verdict 1]]
        }
    }
    return ""
}

# A module copy (in DIR) of the entry program ENTRY's declarations (its
# leading imports and declarations, up to its first top-level expression):
# {MODULE ERRORS}, ERRORS the errors it declares.
proc emitw::EntryModule {dir entry} {
    variable counter
    set mod "witness_entry_[pid]_[incr counter]"
    set lines {}
    set declared {}
    set decl {^(import|fn|private|nomethod|error|struct|enum|type|refined|class|dfa|context|layout|union|extern|exported|trait|#|direct|$)}
    foreach line [split [emit::readText [file join $dir $entry]] \n] {
        if {[regexp {^\S} $line] && ![regexp $decl $line]} break
        if {[regexp {^error\s+([A-Za-z_][A-Za-z0-9_]*)} $line -> name]} {
            lappend declared $name
        }
        lappend lines $line
    }
    emit::writeText [file join $dir $mod.bot] [join $lines \n]
    return [list $mod $declared]
}

if {[info exists argv0] && [file normalize $argv0] eq [file normalize [info script]]} {
    if {[llength $argv] != 1} {
        puts stderr "usage: tclsh9.0 audit/emission-claims/tools/witness.tcl PROGRAM.bot"
        exit 2
    }
    interp recursionlimit {} 100000
    core::useProgramRecursionLimit
    set entry [file normalize [lindex $argv 0]]
    set hir [emit::compile $entry]
    set bad 0
    foreach r [hir::emission::claims $hir] {
        if {[dict get $r verdict] eq "proven"} continue
        set bad 1
        set w [emitw::witness [file dirname $entry] $entry $hir $r]
        set line "[dict get $r function] emits [dict get $r recognizer]: [dict get $r verdict]"
        if {$w ne ""} {
            append line "; disproven by ([lindex $w 0]): [lindex $w 1]"
        } else {
            append line "; no counterexample found (that proves nothing)"
        }
        puts $line
    }
    emit::cleanup
    exit $bad
}
