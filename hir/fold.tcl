# fold.tcl -- the checks of folding loops (FOLD-LOOPS-MILESTONE-1.md)
#
#   hir::fold::verify HIRVAR
#
# A fold carries one value, its intermediate, from each iteration to the
# next. Its type is the join of its initial value's type and the type of
# every normal completion of its body (hir::types::FoldBody), and unlike an
# `if`'s join, which one consumer reads once, this one is read by the same
# body again on the next iteration. So a join that has no type but the
# dynamic `any` -- two different kinds (an Int and a String), two different
# named structs, anonymous structs of different fields, a value and the
# `unit` of an `if` without `else` -- is FOLD-INTERMEDIATE-TYPE, reported at
# the first completion (in source order) whose type makes the running join
# collapse, with the fold and its initial value as related locations. A
# value already of the dynamic type `any` (an untyped parameter's, say)
# collapses nothing: it is dynamic before the fold sees it. Poison and
# `never` (a completion that does not happen) are no completions.
#
# The type walk finds the conflict (hir::types::FoldBody, which records it
# in HIR's `foldConflicts` and makes the intermediate and the fold poison, so
# no later check restates it); this file decides what a conflict is
# (Conflict) and reports it. A program compiled despite its diagnostics
# (-strict 0) is typed again without poison (hir::recovery::runnable) and
# runs with a dynamic (`any`) intermediate.

namespace eval hir::fold {}

proc hir::fold::verify {hirVar} {
    upvar 1 $hirVar hir
    dict for {e conflict} [dict getdef $hir foldConflicts {}] {
        if {![dict exists $hir exprs $e] || ![dict get $hir exprs $e reachable]} {
            continue
        }
        Report hir $e [dict get $hir exprs $e] {*}$conflict
    }
}

# The conflict of a fold whose initial value is INITIAL and whose body ends
# with LAST, read from the types the body was just walked with
# (hir::types::FoldBody): {LEAF RUNNING TYPE HOW}, the first completion LEAF
# (of TYPE; HOW as Completions) at which the running join, of type RUNNING
# from the initial value's type through the earlier completions, collapses
# to `any`; or "" when no completion of a known type does.
proc hir::fold::Conflict {hir initial last} {
    set running [hir::typeOf $hir $initial]
    if {![Known $hir $initial $running]} {
        return ""
    }
    foreach {leaf type how} [Completions $hir $last] {
        if {![Known $hir $leaf $type]} {
            continue
        }
        set joined [hir::types::lub $running $type]
        if {$joined eq "any"} {
            return [list $leaf $running $type $how]
        }
        set running $joined
    }
    return ""
}

# Every expression of the sequence EXPRS and below it, nested functions'
# bodies included.
proc hir::fold::Subtree {hir exprs} {
    set result {}
    set work $exprs
    while {$work ne {}} {
        set work [lassign $work x]
        lappend result $x
        lappend work {*}[hir::children $hir $x]
    }
    return $result
}

# 1 if expression E, of type TYPE, is a value of a known type: neither the
# dynamic `any`, nor `never` (it does not complete), nor poison.
proc hir::fold::Known {hir e type} {
    return [expr {$type ni {any never} && ![hir::types::Poisoned $hir $e]}]
}

# The normal completions of the body value E, in source order, as triples
# {EXPR TYPE HOW}: HOW is `value` for an expression that completes with its
# value, `else` for an `if` without `else` whose missing branch completes
# with `unit`. An `if` or a handled call whose own join already is the
# dynamic type is looked into, to name the completion that made it so;
# anything else is one completion of its own type.
proc hir::fold::Completions {hir e} {
    set node [dict get $hir exprs $e]
    if {![dict get $node reachable]} {
        return {}
    }
    set type [hir::typeOf $hir $e]
    switch -- [dict get $node kind] {
        return - fail - break - continue {
            return {}
        }
        if {
            if {$type eq "any" && ![hir::warnings::SynthesizedBranch $hir $node]} {
                set result {}
                foreach role {thenBody elseBody} {
                    set branch [dict get $node $role]
                    if {$branch eq {}} {
                        lappend result $e unit else
                    } else {
                        lappend result {*}[Completions $hir [lindex $branch end]]
                    }
                }
                return $result
            }
        }
        handle {
            if {$type eq "any"} {
                set call [dict get $node call]
                set result [list $call [hir::typeOf $hir $call] value]
                foreach branch [dict get $node handlerBodies] {
                    if {$branch ne {}} {
                        lappend result {*}[Completions $hir [lindex $branch end]]
                    }
                }
                return $result
            }
        }
    }
    if {$type eq "never"} {
        return {}
    }
    return [list $e $type value]
}

# Reports the collapse of fold E's (node NODE) running join of type RUNNING
# at its completion LEAF of type TYPE (HOW: Completions).
proc hir::fold::Report {hirVar e node leaf running type how} {
    upvar 1 $hirVar hir
    set name [hir::semantic::SourceName $hir [dict get $node foldBinding]]
    set initial [dict get $node foldInitial]
    set from [hir::types::presented $running]
    set to [hir::types::presented $type]
    if {$how eq "else"} {
        set path "this `if` has no `else`: when its condition is false it completes the body with unit"
    } else {
        set path "this completion of the body is $to"
    }
    set source "its initial value"
    if {$running ne [hir::typeOf $hir $initial]} {
        set source "its initial value joined with the body's earlier completions"
    }
    hir::Diagnose hir FOLD-INTERMEDIATE-TYPE \
        "the intermediate \"$name\" of this fold is $from ($source), but $path: a fold carries one value from each iteration to the next, and $from and $to have no common type (give every normal completion of the body the intermediate's type)" \
        $leaf [list [dict get $hir exprs $e origin] [dict get $hir exprs $initial origin]]
}
