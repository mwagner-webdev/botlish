#!/usr/bin/env tclsh9.0
# runtime.tcl OUTFILE ?RUNS? ?ROUNDS? -- the runtime comparison of the key
# probes of VALUE-TRANSPORT-MATERIALIZATION.md under the four representation
# modes (physical = -struct-opt 0, legacy, default, virtual = every budget and
# ceiling raised), with the methodology of the earlier milestones: ROUNDS
# rounds interleaved (every mode of a probe measured in turn, round after
# round, so slow drift hits all modes alike), best-of-RUNS per measurement, and
# the minimum and the median over the rounds reported (ns per iteration).
# Observation only.
set root [pwd]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
source [file join $root tests transport-shapes.tcl]
interp recursionlimit {} 2000000
lassign $argv outfile runs rounds
if {$runs eq ""} { set runs 15 }
if {$rounds eq ""} { set rounds 3 }
set ITERS 200000
set common {-tiny-leaf-inline-opt 0}
set raised {-struct-local-width 64 -struct-return-width 64 -struct-arg-width 64 \
    -struct-arg-budget 1e12 -struct-return-budget 1e12 -struct-cycle-budget 1e12}
set modes [list physical [concat $common {-struct-opt 0}] legacy [concat $common {-struct-policy legacy}] \
    default $common virtual [concat $common $raised]]
set probes [list \
    "narrow-arg W=2 E=9"   [chainArg 2 9 $ITERS] \
    "wide-return W=8 E=2"  [chainRet 8 2 $ITERS] \
    "wide-return W=8 E=8"  [chainRet 8 8 $ITERS] \
    "wide-arg W=8 E=4"     [chainArg 8 4 $ITERS] \
    "wide-arg W=8 E=8"     [chainArg 8 8 $ITERS] \
    "late-frontier W=6 E=5" [lateFrontier 6 5 $ITERS] \
    "direction-arg W=6 E=3" [chainArg 6 3 $ITERS] \
    "direction-ret W=6 E=3" [chainRet 6 3 $ITERS] \
    "branchy W=8 E=6"      [branchy 8 6 $ITERS 100] \
    "mixed W=4 R=3 A=6"    [mixed 4 3 6 $ITERS] \
    "nested-local"         "fn drive(i, n, acc):\n    if i >= n:\n        return acc\n    r = [nestedLiteral 2 i]\n    drive(i + 1, n, acc + [nestedUses 2 r])\ndrive(0, $ITERS, 0)\n" \
    "nested-return E=1"    [nestedChainRet 2 1 $ITERS] \
    "nested-return E=6"    [nestedChainRet 2 6 $ITERS] \
    "nested-arg inner4 E=3" [nestedChainArg 4 3 $ITERS]]
proc median {v} { lindex [lsort -real $v] [expr {[llength $v] / 2}] }
set out {}
foreach {label source} $probes {
    set hir [surface::compile $source probe.bot -strict 0]
    set samples [dict create]
    for {set r 0} {$r < $rounds} {incr r} {
        foreach {mode opts} $modes {
            lassign [native::measure $hir $runs {*}$opts] lower jit best collections value
            dict lappend samples $mode [expr {$best * 1000.0 / $ITERS}]
        }
    }
    set line [format "%-26s" $label]
    foreach {mode opts} $modes {
        set v [dict get $samples $mode]
        append line [format "  %-8s min %7.2f med %7.2f" $mode [lindex [lsort -real $v] 0] [median $v]]
    }
    lappend out $line
    puts $line
}
set f [open $outfile w]
puts $f [join $out \n]
close $f
