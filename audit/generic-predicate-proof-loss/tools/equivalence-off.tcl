#!/usr/bin/env tclsh9.0
# equivalence-off.tcl -- "knob off = the parent commit" for a change guarded
# by a test/audit knob (GENERIC-PREDICATE-PROOF-LOSS.md, loss point 2:
# hir::specialize::dormantOpt): every file collect.tcl dumped for the
# parent tree (DUMPBASE, KNOB "-") must be byte-identical to the changed
# tree's with the knob 0 (DUMP0), except the wall time in calls.txt.
#
#   tclsh9.0 equivalence-off.tcl DUMPBASE DUMP0 OUT PROGRAM...
#
# Compared per program: nir.txt, instances.txt, analysis.txt (instances,
# induction, recursive), fixpoints.txt (every Fixpoint call's state record),
# labels.txt, rawabi.txt, hir.txt, variants.txt, dormant.txt, calls.txt
# (analyze / Fixpoint / plan counts), or the skip.txt error.

lassign $argv dumpBase dump0 outPath
set programs [lrange $argv 3 end]

proc Read {path} {
    set f [open $path r]
    fconfigure $f -encoding utf-8
    set s [read $f]
    close $f
    return $s
}

set files {nir.txt instances.txt analysis.txt fixpoints.txt labels.txt rawabi.txt hir.txt variants.txt dormant.txt calls.txt}
set compared 0
set comparisons 0
set skipped {}
set bad {}
foreach path $programs {
    set stem [string map {/ __} [string trimleft [file rootname $path] ./]]
    set b [file join $dumpBase $stem]
    set z [file join $dump0 $stem]
    set bs [file exists [file join $b skip.txt]]
    set zs [file exists [file join $z skip.txt]]
    if {$bs || $zs} {
        if {$bs && $zs && [Read [file join $b skip.txt]] eq [Read [file join $z skip.txt]]} {
            lappend skipped "[file rootname $path] (identical error on both trees)"
        } else {
            lappend bad "[file rootname $path]: skip status/error differs (base skip=$bs, knob0 skip=$zs)"
        }
        continue
    }
    incr compared
    foreach file $files {
        incr comparisons
        set fb [file join $b $file]
        set fz [file join $z $file]
        set tb [expr {[file exists $fb] ? [Read $fb] : "\n"}]
        set tz [expr {[file exists $fz] ? [Read $fz] : "\n"}]
        if {$file eq "calls.txt"} {
            regsub { ms \d+} $tb {} tb
            regsub { ms \d+} $tz {} tz
        }
        if {$tb ne $tz} {
            lappend bad "$stem $file differs"
        }
    }
}
set out {}
lappend out "Knob-off equivalence: parent tree (its own defaults) vs the changed tree with the knob 0"
lappend out "programs compared: $compared; skipped on both trees with identical errors: [llength $skipped]"
foreach s $skipped { lappend out "  $s" }
lappend out "byte-identical comparisons ([join $files {, }]): $comparisons, mismatches: [llength $bad]"
foreach x $bad { lappend out "  MISMATCH $x" }
set text "[join $out \n]\n"
if {$outPath eq "-"} {
    puts -nonewline $text
} else {
    set f [open $outPath w]
    fconfigure $f -encoding utf-8 -translation lf
    puts -nonewline $f $text
    close $f
}
puts stderr "compared $compared comparisons $comparisons mismatches [llength $bad]"
