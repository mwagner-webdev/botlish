#!/usr/bin/env tclsh9.0
# equivalence.tcl -- refactor equivalence of the result-narrowing change
# (GENERIC-PREDICATE-PROOF-LOSS.md, fix 3): the pre-change tree (DUMPHEAD,
# collect.tcl run on a worktree of the pre-change commit with KNOB "-")
# against the changed tree with hir::range::resultNarrowOpt 0 (DUMP0),
# program by program. Also cross-checks the changed tree's own knob 1 dump
# (DUMP1) where knob 1 must agree with knob 0 (the ascending phase).
#
#   tclsh9.0 equivalence.tcl DUMPHEAD DUMP0 DUMP1 OUT PROGRAM.bot...
#
# Required byte-identical (the refactor-equivalence claim):
#   nir.txt        native::nir's text
#   instances.txt  hir::range::analyze's `instances` dict
# Also checked byte-identical (stronger evidence; reported separately):
#   analysis.txt (instances + induction + recursive), rawabi.txt,
#   labels.txt, variants.txt, hir.txt, the call counts in calls.txt, and
#   every Fixpoint call's state record with the two keys the change added
#   (ascendingResults, resultNarrow) removed from the knob-0 side.
# Knob-0 sanity: every Fixpoint call reports resultNarrow {attempted 0
# converged 0 rounds 0} and calleeResults equal to ascendingResults.
# Knob 1 vs knob 0: the first Fixpoint call's ascendingResults are
# byte-identical (the change runs strictly after the ascending phase).

lassign $argv dumpHead dump0 dump1 outPath
set programs [lrange $argv 4 end]

proc Read {path} {
    set f [open $path r]
    fconfigure $f -encoding utf-8
    set s [read $f]
    close $f
    return $s
}
proc Lines {path} {
    return [split [string trimright [Read $path] \n] \n]
}

set out {}
set required 0
set requiredBad {}
set extra 0
set extraBad {}
set sanityBad {}
set compared 0
set skippedBoth {}
foreach path $programs {
    # One dump directory per program path (bench/fib.bot and bench/fib.ir
    # must not collide): the relative path with "/" spelled "__".
    set stem [string map {/ __} [string trimleft [file rootname $path] ./]]
    set h [file join $dumpHead $stem]
    set z [file join $dump0 $stem]
    set o [file join $dump1 $stem]
    set hs [file exists [file join $h skip.txt]]
    set zs [file exists [file join $z skip.txt]]
    if {$hs || $zs} {
        if {$hs && $zs && [Read [file join $h skip.txt]] eq [Read [file join $z skip.txt]]} {
            lappend skippedBoth "[file rootname $path] (identical error on both trees)"
        } else {
            lappend requiredBad "[file rootname $path]: skip status/error differs (head skip=$hs, knob0 skip=$zs)"
        }
        continue
    }
    incr compared
    foreach file {nir.txt instances.txt} {
        incr required
        if {[Read [file join $h $file]] ne [Read [file join $z $file]]} {
            set a [Lines [file join $h $file]]
            set b [Lines [file join $z $file]]
            set first ""
            for {set i 0} {$i < max([llength $a], [llength $b])} {incr i} {
                if {[lindex $a $i] ne [lindex $b $i]} {
                    set first "line [expr {$i + 1}]: head [string range [lindex $a $i] 0 200] | knob0 [string range [lindex $b $i] 0 200]"
                    break
                }
            }
            lappend requiredBad "$stem $file differs; first difference $first"
        }
    }
    foreach file {analysis.txt rawabi.txt labels.txt variants.txt hir.txt} {
        incr extra
        if {[Read [file join $h $file]] ne [Read [file join $z $file]]} {
            lappend extraBad "$stem $file differs"
        }
    }
    incr extra
    regsub { ms \d+} [Read [file join $h calls.txt]] {} ch
    regsub { ms \d+} [Read [file join $z calls.txt]] {} cz
    if {$ch ne $cz} {
        lappend extraBad "$stem call counts differ: head [string trim $ch] knob0 [string trim $cz]"
    }
    set fh [Lines [file join $h fixpoints.txt]]
    set fz [Lines [file join $z fixpoints.txt]]
    set fo [Lines [file join $o fixpoints.txt]]
    incr extra
    if {[llength $fh] != [llength $fz]} {
        lappend extraBad "$stem Fixpoint call counts differ: head [llength $fh] knob0 [llength $fz]"
    } else {
        set k 0
        foreach rh $fh rz $fz {
            incr k
            if {[dict exists $rh resultNarrow] || [dict exists $rh ascendingResults]} {
                lappend extraBad "$stem Fixpoint call $k: pre-change state unexpectedly has the new keys"
            }
            if {![dict exists $rz resultNarrow] || ![dict exists $rz ascendingResults]} {
                lappend sanityBad "$stem Fixpoint call $k: knob-0 state lacks resultNarrow/ascendingResults"
                continue
            }
            if {[dict get $rz resultNarrow] ne {attempted 0 converged 0 rounds 0}} {
                lappend sanityBad "$stem Fixpoint call $k: knob 0 resultNarrow [dict get $rz resultNarrow]"
            }
            if {[dict get $rz ascendingResults] ne [dict get $rz calleeResults]} {
                lappend sanityBad "$stem Fixpoint call $k: knob 0 calleeResults differ from ascendingResults"
            }
            set stripped [dict remove $rz resultNarrow ascendingResults]
            if {$stripped ne $rh} {
                set keys {}
                foreach key [dict keys $rh] {
                    if {![dict exists $stripped $key] || [dict get $stripped $key] ne [dict get $rh $key]} {
                        lappend keys $key
                    }
                }
                lappend extraBad "$stem Fixpoint call $k state differs in: $keys"
            }
        }
    }
    # knob 1's ascending phase (first Fixpoint call) == knob 0's
    set r1 [lindex $fo 0]
    set r0 [lindex $fz 0]
    if {[dict get $r1 ascendingResults] ne [dict get $r0 ascendingResults]} {
        lappend sanityBad "$stem: first Fixpoint call's ascendingResults differ between knob 0 and knob 1"
    }
}

lappend out "Refactor equivalence: pre-change tree (detached worktree of the base revision, its own defaults)"
lappend out "vs the changed tree with hir::range::resultNarrowOpt 0"
lappend out ""
lappend out "programs compared: $compared; skipped on both trees with identical errors: [llength $skippedBoth]"
foreach s $skippedBoth { lappend out "  $s" }
lappend out "required byte-identical comparisons (nir.txt, instances.txt): $required, mismatches: [llength $requiredBad]"
foreach b $requiredBad { lappend out "  MISMATCH $b" }
lappend out "additional byte-identical comparisons (analysis incl. induction/recursive, raw-int-ABI plan text,"
lappend out "  instance labels, emitted NIR function variants, HIR text, analyze/Fixpoint/plan call counts,"
lappend out "  every Fixpoint call's state minus the two new keys): $extra, mismatches: [llength $extraBad]"
foreach b $extraBad { lappend out "  MISMATCH $b" }
lappend out "knob-0 sanity (resultNarrow all-zero, calleeResults == ascendingResults) and knob-1 ascending"
lappend out "  phase == knob-0 ascending phase: violations: [llength $sanityBad]"
foreach b $sanityBad { lappend out "  VIOLATION $b" }

set text "[join $out \n]\n"
if {$outPath eq "-"} {
    fconfigure stdout -encoding utf-8 -translation lf
    puts -nonewline $text
} else {
    set f [open $outPath w]
    fconfigure $f -encoding utf-8 -translation lf
    puts -nonewline $f $text
    close $f
}
puts stderr "compared $compared required $required mismatches [llength $requiredBad] extra $extra mismatches [llength $extraBad] sanity [llength $sanityBad]"
