#!/usr/bin/env tclsh9.0
# compiletime.tcl -- compile-time cost of Fixpoint's result-narrowing pass
# (GENERIC-PREDICATE-PROOF-LOSS.md, fix 3; modeled on
# audit/self-recursive-result-ranges/tools/compiletime.tcl). Per program,
# hir::range::resultNarrowOpt 0 (pass skipped) vs 1 (default), same tree,
# same prepared HIR and specialization, default lowering options:
#
#   range      hir::range::analyze (the whole analysis: Fixpoint, plus the
#              rangerec.tcl re-runs after pinning self-recursive summaries)
#   pass       wall time inside the result-narrowing pass itself (every
#              NarrowRounds call with NARROWRESULTS 1, summed over the
#              analyze's Fixpoint calls; knob 1 only). When the pass
#              converges its last round doubles as Fixpoint's final
#              recompute, so the pass's net cost is less than this
#   nir        native::nir (everything up to NIR text: prepareHir,
#              specialization, this analysis, the other analyses, lowering)
#
# each the median (and minimum) of N runs, milliseconds. The two knobs
# alternate inside every iteration (0 then 1 on even iterations, 1 then 0
# on odd ones) so a drifting machine load hits both alike.
#
# One extra, untimed analyze per knob counts the work directly: the
# resultNarrow {attempted converged rounds} of every Fixpoint call
# (Fixpoint's returned state), the number of used instances, and the total
# number of AnalyzeInstance calls the analyze made (a counting wrapper, never
# installed while timing). "extra AI" is the knob 1 count minus the knob 0
# count: the per-instance walks the pass adds, net of the final recompute
# it replaces.
#
# Run from the repository root (the compiler tree is the current directory):
#
#   tclsh9.0 audit/generic-predicate-proof-loss/tools/compiletime.tcl ?-n N? PROGRAM.{bot,ir} ...
set root [pwd]
set args $argv
set argv {}
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000
set n 5
while {[lindex $args 0] eq "-n"} {
    set n [lindex $args 1]
    set args [lrange $args 2 end]
}

proc median {xs} { set s [lsort -real $xs]; return [lindex $s [expr {[llength $s] / 2}]] }
proc minimum {xs} { return [lindex [lsort -real $xs] 0] }
proc ms {script} { return [expr {[lindex [uplevel 1 [list time $script]] 0] / 1000.0}] }

set ::passUs 0
# Timing the pass: a thin wrapper around NarrowRounds (one or two calls per
# Fixpoint call, so its own overhead is microseconds), installed throughout.
rename hir::range::NarrowRounds hir::range::NarrowRounds__timed
proc hir::range::NarrowRounds {ctx narrowed captures results narrowResults roundBudget} {
    set t0 [clock microseconds]
    set r [NarrowRounds__timed $ctx $narrowed $captures $results $narrowResults $roundBudget]
    if {$narrowResults} {
        set ::passUs [expr {$::passUs + [clock microseconds] - $t0}]
    }
    return $r
}

# Counting (untimed runs only): Fixpoint's resultNarrow states and the
# AnalyzeInstance calls.
proc countRun {prepared spec} {
    set ::fixStates {}
    set ::aiCalls 0
    rename hir::range::Fixpoint hir::range::Fixpoint__orig
    proc hir::range::Fixpoint {args} {
        set analysis [Fixpoint__orig {*}$args]
        set st [dict get $analysis state]
        lappend ::fixStates [list [llength [dict get $st ids]] \
            [expr {[dict exists $st resultNarrow] ? [dict get $st resultNarrow] : {}}]]
        return $analysis
    }
    rename hir::range::AnalyzeInstance hir::range::AnalyzeInstance__orig
    proc hir::range::AnalyzeInstance {args} {
        incr ::aiCalls
        return [AnalyzeInstance__orig {*}$args]
    }
    try {
        hir::range::analyze $prepared $spec
    } finally {
        rename hir::range::Fixpoint {}
        rename hir::range::Fixpoint__orig hir::range::Fixpoint
        rename hir::range::AnalyzeInstance {}
        rename hir::range::AnalyzeInstance__orig hir::range::AnalyzeInstance
    }
    return [list $::fixStates $::aiCalls]
}

fconfigure stdout -buffering line
puts "result-narrowing compile time, knob 0 vs 1 (milliseconds; median of $n, min in parentheses)"
puts "fixpoints: per Fixpoint call at knob 1, instances:attempted/converged/rounds"
puts ""
puts [format "%-30s | %-17s | %-17s | %-7s | %-17s | %-17s | %-8s | %-24s | %s" \
    program "range 0" "range 1" "pass" "nir 0" "nir 1" "dRange" fixpoints "AI 0 -> 1 (extra AI)"]
set totals [dict create r0 0.0 r1 0.0 p 0.0 n0 0.0 n1 0.0]
foreach path $args {
    if {[file extension $path] eq ".bot"} {
        set hir [surface::readProgramFile $path]
    } else {
        set hir [hir::build [core::loadProgramFile $path] -strict 0]
    }
    set prepared [native::prepareHir $hir]
    set spec [hir::specialize::analyze $prepared]
    # Warm-up (byte-compilation, caches), both knobs, untimed.
    foreach k {0 1} {
        set hir::range::resultNarrowOpt $k
        hir::range::analyze $prepared $spec
        native::nir $hir
    }
    set R0 {}; set R1 {}; set N0 {}; set N1 {}; set PASS {}
    for {set i 0} {$i < $n} {incr i} {
        foreach k [expr {$i % 2 ? {1 0} : {0 1}}] {
            set hir::range::resultNarrowOpt $k
            set ::passUs 0
            set r [ms {hir::range::analyze $prepared $spec}]
            if {$k} { lappend PASS [expr {$::passUs / 1000.0}] }
            set nirMs [ms {native::nir $hir}]
            lappend R$k $r
            lappend N$k $nirMs
        }
    }
    set counts [dict create]
    foreach k {0 1} {
        set hir::range::resultNarrowOpt $k
        dict set counts $k [countRun $prepared $spec]
    }
    set hir::range::resultNarrowOpt 1
    set fix {}
    foreach f [lindex [dict get $counts 1] 0] {
        lassign $f nIds rn
        if {$rn eq ""} {
            lappend fix "$nIds:-"
        } else {
            lappend fix "$nIds:[dict get $rn attempted]/[dict get $rn converged]/[dict get $rn rounds]"
        }
    }
    set ai0 [lindex [dict get $counts 0] 1]
    set ai1 [lindex [dict get $counts 1] 1]
    set mr0 [median $R0]; set mr1 [median $R1]; set mp [median $PASS]
    set mn0 [median $N0]; set mn1 [median $N1]
    dict set totals r0 [expr {[dict get $totals r0] + $mr0}]
    dict set totals r1 [expr {[dict get $totals r1] + $mr1}]
    dict set totals p [expr {[dict get $totals p] + $mp}]
    dict set totals n0 [expr {[dict get $totals n0] + $mn0}]
    dict set totals n1 [expr {[dict get $totals n1] + $mn1}]
    puts [format "%-30s | %7.1f (%7.1f) | %7.1f (%7.1f) | %7.1f | %7.1f (%7.1f) | %7.1f (%7.1f) | %+7.1f%% | %-24s | %d -> %d (%+d)" \
        [file rootname $path] $mr0 [minimum $R0] $mr1 [minimum $R1] $mp $mn0 [minimum $N0] $mn1 [minimum $N1] \
        [expr {100.0 * ($mr1 - $mr0) / $mr0}] [join $fix ,] $ai0 $ai1 [expr {$ai1 - $ai0}]]
}
dict with totals {
    puts [format "%-30s | %7.1f           | %7.1f           | %7.1f | %7.1f           | %7.1f           | %+7.1f%% |" \
        "SUM of medians" $r0 $r1 $p $n0 $n1 [expr {100.0 * ($r1 - $r0) / $r0}]]
}
