# counts.tcl -- what the emission checker reads, how often
# (EMISSION-BINDING-AND-SIGNATURE-DEPENDENCY-CENSUS-MILESTONE-1.md, section
# 23): each program compiled leniently, its walk counted -- references by
# where their facts come from, calls by what the walk does with them, the
# branch decisions made with an empty environment, duplicate function names
# -- with the summaries computed, reused and their edges.
#
#   tclsh9.0 audit/emission-dependencies/tools/counts.tcl PROGRAM.bot ...
#
# Instruments hir::emission's procedures in this process only (a wrapper
# around RefValue, EvalCall and Facts); it changes no verdict.

set programs $argv
set argv {}
set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
interp recursionlimit {} 100000
core::useProgramRecursionLimit

set ::count [dict create]
proc bump {k} { dict incr ::count $k }

rename hir::emission::RefValue hir::emission::RefValue_counted
proc hir::emission::RefValue {e node} {
    set b [dict get $node binding]
    set hir $::hir::emission::hir
    if {$b eq ""} {
        bump "reference, unresolved"
    } elseif {[dict exists $::hir::emission::env $b]} {
        bump "reference, from the walk's environment"
    } else {
        set kind [dict get $hir bindings $b kind]
        if {$kind eq "local"} {
            bump "reference, to a module binding or a captured local"
        } elseif {$kind eq "param"} {
            bump "reference, to a parameter outside the environment (a list loop's element)"
        } else {
            bump "reference, to a $kind binding"
        }
    }
    return [hir::emission::RefValue_counted $e $node]
}

rename hir::emission::EvalCall hir::emission::EvalCall_counted
proc hir::emission::EvalCall {e node s} {
    set hir $::hir::emission::hir
    if {[dict get $hir exprs [dict get $node callee] kind] eq "ref"} {
        bump "call, a named callee (Taint)"
    }
    lassign [dict get $node target] tk t
    set never [expr {[hir::typeOf $hir $e] eq "never"}]
    if {[dict exists $node traitCall]} {
        bump "call, a trait operation"
    } elseif {$tk eq "native"} {
        bump "call, a native"
    } elseif {$tk eq "block" && [dict exists $hir exprs $t]} {
        if {$never && [hir::coroutines::MayYield $hir $t]} {
            bump "call, a yielding function that never returns"
        } elseif {$never} {
            bump "call, a function whose never is relied on (Read)"
        } elseif {[dict exists $::hir::emission::guards $t]} {
            bump "call, a guard"
        } elseif {[hir::coroutines::MayYield $hir $t]} {
            bump "call, a yielding function (Apply)"
        } else {
            bump "call, a non-yielding function (Child)"
        }
    } elseif {$never} {
        bump "call, through a value, typed never"
    } else {
        bump "call, through a value"
    }
    return [hir::emission::EvalCall_counted $e $node $s]
}

rename hir::emission::Facts hir::emission::Facts_counted
proc hir::emission::Facts {condition outcome} {
    bump "branch decisions (Facts)"
    if {[dict size $::hir::emission::env] == 0} {
        bump "branch decisions with an empty environment"
    }
    return [hir::emission::Facts_counted $condition $outcome]
}

foreach path $programs {
    set ::count [dict create]
    set ::hir::emission::memo [dict create]
    set hir [surface::readProgramFile $path -warnings off -strict 0]
    set byName [dict create]
    dict for {v n} $::hir::emission::names {
        dict lappend byName $n $v
    }
    set duplicates [lmap n [dict keys $byName] {
        if {[llength [dict get $byName $n]] < 2} continue
        set n
    }]
    set children 0
    set reads 0
    dict for {k rec} $::hir::emission::cache {
        incr children [llength [dict get $rec children]]
        incr reads [llength [dict get $rec reads]]
    }
    set verdicts [dict create]
    foreach r [hir::emission::claims $hir] {
        dict incr verdicts [dict get $r verdict]
    }
    set stats $::hir::emission::stats
    puts "$path: claims $verdicts; summaries [dict get $stats summariesComputed] computed, [dict get $stats summariesReused] reused, [dict get $stats rounds] rounds; edges: children $children, reads $reads; duplicate function names: [llength $duplicates] $duplicates"
    foreach k [lsort [dict keys $::count]] {
        puts "    $k: [dict get $::count $k]"
    }
}
