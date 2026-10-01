#!/usr/bin/env tclsh9.0
# fuzz.tcl -- randomized soundness check of the bounded self-recursive
# result summaries (SELF-RECURSIVE-RESULT-RANGES.md). For each random
# single-measure recursive function F and entry set E:
#
#   1. analyze `F(e) + ...` for e in E; if the instance is solved, take its
#      memoized state table S;
#   2. run, on the reference interpreter, a SEPARATE program returning
#      [F(k) | k in S] (so the analysis input is not perturbed) and check
#      every value lies in S(k) (an error/`never` state must also error or be
#      skipped: the generated functions cannot fail, so `never` is itself a
#      violation);
#   3. check the pinned instance result contains every value.
#
#   tclsh9.0 audit/self-recursive-result-ranges/tools/fuzz.tcl ?-n COUNT? ?-seed N?
set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 100000
set count 100
set seed 1
foreach {k v} $argv {
    switch -- $k { -n { set count $v } -seed { set seed $v } }
}
expr {srand($seed)}
proc pick {xs} { lindex $xs [expr {int(rand() * [llength $xs])}] }
proc rint {lo hi} { expr {$lo + int(rand() * ($hi - $lo + 1))} }

# A random function body over measure n.
proc genFunction {} {
    set base [rint -3 4]
    set s1 [rint 1 3]
    set s2 [rint 1 3]
    set c [rint -3 5]
    set baseExpr [pick [list "n" "$c" "n + $c" "n * 2" "0 - n"]]
    set two [expr {rand() < 0.5}]
    set a "f(n - $s1)"
    set b "f(n - $s2)"
    if {$two} {
        set rec [pick [list "$a + $b" "$a - $b" "$a + $b + $c" "$a * 2 - $b" "$a + n"]]
    } else {
        set rec [pick [list "$a + $c" "$a * 2" "$a + n" "$a * 2 + $c" "n - $a"]]
    }
    set base2 [rint -2 3]
    set extra [expr {rand() < 0.4}]
    set text "fn f(n):\n    if n <= $base:\n        $baseExpr\n    else:\n"
    if {$extra} {
        append text "        if n == [expr {$base + 1}]:\n            $base2\n        else:\n            $rec\n"
    } else {
        append text "        $rec\n"
    }
    return $text
}

set solved 0
set checked 0
set violations 0
for {set i 0} {$i < $count} {incr i} {
    set fn [genFunction]
    set entries {}
    for {set j 0} {$j < [rint 1 3]} {incr j} { lappend entries [rint -2 12] }
    set call [join [lmap e $entries {string cat "f($e)"}] " + "]
    set text "$fn\n$call\n"
    if {[catch {
        set hir [surface::compile $text t.bot -strict 0]
        set spec [hir::specialize::analyze $hir]
        set a [hir::range::analyze $hir $spec]
    } err]} {
        puts "SKIP $i: $err"
        continue
    }
    set rec [dict get $a recursive]
    if {[dict size $rec] != 1} continue
    set id [lindex [dict keys $rec] 0]
    set r [dict get $rec $id]
    if {[dict get $r status] ne "solved"} continue
    incr solved
    set states [dict get $r states]
    set ks [dict keys $states]
    set evalText "$fn\n\[[join [lmap k $ks {string cat "f($k)"}] {, }]\]\n"
    set hir2 [surface::compile $evalText t.bot -strict 0]
    set shown [core::value::show [core::evalProgram [hir::lower $hir2]]]
    set values [lmap v [split [string trim $shown {[]}] ,] {string trim $v}]
    foreach k $ks v $values {
        incr checked
        set S [dict get $states $k]
        if {$S eq "never" || $v < [dict get $S min] || $v > [dict get $S max]} {
            incr violations
            puts "VIOLATION: f($k) = $v not in [hir::range::show $S]\n$text"
        }
        set R [dict get $r result]
        if {$v < [dict get $R min] || $v > [dict get $R max]} {
            incr violations
            puts "VIOLATION: f($k) = $v not in result [hir::range::show $R]\n$text"
        }
    }
}
puts "functions $count, solved $solved, state values checked $checked, violations $violations"
exit [expr {$violations > 0}]
