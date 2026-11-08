# economics.tcl -- FOLD-VIRTUAL-LIST-CONSTRUCTION-MILESTONE-1.md's compile
# cost: per program, the time hir::construction::analyze takes (best of
# RUNS lowerings), how many times its linearity walk enters an expression
# (hir::construction::Uses, counted in one further lowering), the whole
# native lowering's time (best of RUNS), the program's folds and plan folds,
# its NIR size and its machine code size.
#
#   tclsh9.0 audit/fold-virtual-construction/tools/economics.tcl ?-root DIR? ?-runs N? FILE.bot ...
#
# -root names the checkout whose compiler is measured (default: this one),
# so the tree before the milestone measures the same files. The two
# procedures are measured through wrappers defined in this process (around
# the renamed originals), never through execution traces: a trace hands its
# callback the command's arguments and result as strings, and stringifying
# an analysis or a HIR view would be the measurement (and, for a large
# golden suite, gigabytes). A rename makes the lowering compile its callers
# again once: an untimed warm-up lowering per program absorbs that.

set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
set runs 5
set files {}
for {set i 0} {$i < [llength $argv]} {incr i} {
    set arg [lindex $argv $i]
    switch -- $arg {
        -root { set root [file normalize [lindex $argv [incr i]]] }
        -runs { set runs [lindex $argv [incr i]] }
        default { lappend files [file normalize $arg] }
    }
}
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
core::useProgramRecursionLimit

set ::analyzeUs 0
set ::usesCalls 0
set ::countUses 0
rename hir::construction::analyze hir::construction::AnalyzeMeasured
proc hir::construction::analyze {args} {
    set started [clock microseconds]
    set result [AnalyzeMeasured {*}$args]
    set ::analyzeUs [expr {[clock microseconds] - $started}]
    return $result
}
rename hir::construction::Uses hir::construction::UsesMeasured
proc hir::construction::Uses {view b loops e} {
    if {$::countUses} {
        incr ::usesCalls
    }
    return [UsesMeasured $view $b $loops $e]
}

puts [format "%-44s %10s %10s %10s %6s %6s %7s %8s" program analyze-us uses-walks lower-us folds plan nir code-B]
foreach path $files {
    set hir [surface::readProgramFile $path -warnings off]
    set bestAnalyze ""
    set bestLower ""
    # (The first lowering is a warm-up: it compiles the procedures.)
    native::lower::program $hir
    for {set r 0} {$r < $runs} {incr r} {
        set started [clock microseconds]
        set lowered [native::lower::program $hir]
        set lower [expr {[clock microseconds] - $started}]
        if {$bestLower eq "" || $lower < $bestLower} { set bestLower $lower }
        if {$bestAnalyze eq "" || $::analyzeUs < $bestAnalyze} { set bestAnalyze $::analyzeUs }
    }
    set ::usesCalls 0
    set ::countUses 1
    native::lower::program $hir
    set ::countUses 0
    set analysis [dict get $lowered construction]
    set spec [dict get $lowered specialization]
    set folds 0
    foreach id [dict get $spec used] {
        set view [dict get $analysis regions $id view]
        foreach e [dict get $analysis regions $id exprs] {
            if {[hir::kind $view $e] in {loop listloop countloop lockloop} && [hir::isFold $view $e]} {
                incr folds
            }
        }
    }
    set plans 0
    if {[dict exists $analysis folds]} {
        dict for {id fs} [dict get $analysis folds] { incr plans [dict size $fs] }
    }
    set nir [llength [split [dict get $lowered text] \n]]
    set code [lindex [native::codeSize $hir] 0]
    puts [format "%-44s %10s %10s %10s %6s %6s %7s %8s" \
        [file join [file tail [file dirname $path]] [file tail $path]] $bestAnalyze $::usesCalls $bestLower $folds $plans $nir $code]
    flush stdout
}
