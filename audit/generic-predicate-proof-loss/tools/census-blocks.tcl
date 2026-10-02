#!/usr/bin/env tclsh9.0
# census-blocks.tcl -- function-level corpus census for a change that
# changes instance keys (GENERIC-PREDICATE-PROOF-LOSS.md, loss point 1:
# hir::specialize::closureIntKeyOpt), where census.tcl's instance-by-
# instance comparison does not apply: compares the dumps collect.tcl wrote
# at knob 0 (DUMP0) and 1 (DUMP1), program by program.
#
#   tclsh9.0 census-blocks.tcl DUMP0 DUMP1 OUT PROGRAM...
#
# Per function (HIR block), the facts the code that can run relies on: the
# join over its LIVE used instances (not in dormant.txt) of every entry
# Range, the result Range, and every expression Range. Classified like
# census.tcl (same / equal / narrower / wider / incomparable; wider and
# incomparable must not happen). A function live at one knob only is listed.
# The NIR is compared with instance labels (instance="...") and ExprId
# anchors removed: "same modulo labels" means the machine code is the same.
# Instance counts (used, dormant, emitted NIR functions) per program too.

lassign $argv dump0 dump1 outPath
set programs [lrange $argv 3 end]

proc Read {path} {
    set f [open $path r]
    fconfigure $f -encoding utf-8
    set s [read $f]
    close $f
    return $s
}

# Range sets (as census.tcl).
proc LowGe {a b} {
    if {$b eq "-inf"} { return 1 }
    if {$a eq "-inf"} { return 0 }
    return [expr {$a >= $b}]
}
proc HighLe {a b} {
    if {$b eq "+inf"} { return 1 }
    if {$a eq "+inf"} { return 0 }
    return [expr {$a <= $b}]
}
proc InRange {v r} {
    set mn [dict get $r min]
    set mx [dict get $r max]
    if {$mn ne "-inf" && $v < $mn} { return 0 }
    if {$mx ne "+inf" && $v > $mx} { return 0 }
    if {[dict exists $r exact]} {
        foreach x [dict get $r exact] {
            if {$x == $v} { return 1 }
        }
        return 0
    }
    return 1
}
proc Subset {a b} {
    if {$a eq "never"} { return 1 }
    if {$b eq "never"} { return 0 }
    set amn [dict get $a min]
    set amx [dict get $a max]
    if {[dict exists $a exact]} {
        foreach v [dict get $a exact] {
            if {($amn ne "-inf" && $v < $amn) || ($amx ne "+inf" && $v > $amx)} continue
            if {![InRange $v $b]} { return 0 }
        }
        return 1
    }
    if {![LowGe $amn [dict get $b min]] || ![HighLe $amx [dict get $b max]]} {
        return 0
    }
    if {[dict exists $b exact]} {
        if {$amn eq "-inf" || $amx eq "+inf"} { return 0 }
        set bex [dict get $b exact]
        if {$amx - $amn + 1 > [llength $bex]} { return 0 }
        for {set v $amn} {$v <= $amx} {set v [expr {$v + 1}]} {
            if {![InRange $v $b]} { return 0 }
        }
    }
    return 1
}
proc Classify {r0 r1} {
    if {$r0 eq $r1} { return same }
    set s10 [Subset $r1 $r0]
    set s01 [Subset $r0 $r1]
    if {$s10 && $s01} { return equal }
    if {$s10} { return narrower }
    if {$s01} { return wider }
    return incomparable
}
# The hull of two Ranges (exact sets kept only when both have one).
proc Join {a b} {
    if {$a eq "never"} { return $b }
    if {$b eq "never"} { return $a }
    set amn [dict get $a min]; set bmn [dict get $b min]
    set amx [dict get $a max]; set bmx [dict get $b max]
    set mn [expr {$amn eq "-inf" || $bmn eq "-inf" ? "-inf" : min($amn, $bmn)}]
    set mx [expr {$amx eq "+inf" || $bmx eq "+inf" ? "+inf" : max($amx, $bmx)}]
    set r [dict create min $mn max $mx]
    if {[dict exists $a exact] && [dict exists $b exact]} {
        dict set r exact [lsort -integer -unique [concat [dict get $a exact] [dict get $b exact]]]
    }
    return $r
}
proc Show {r} {
    if {$r eq "never"} { return never }
    set s "\[[string map {-inf -∞} [dict get $r min]], [string map {+inf +∞} [dict get $r max]]\]"
    if {[dict exists $r exact]} { append s " {[join [dict get $r exact] ,]}" }
    return $s
}

# Block -> {params {R...} result R exprs {e R ...} names {...}} over live
# instances; plus counts.
proc Load {dir} {
    if {[file exists [file join $dir skip.txt]]} {
        return [dict create skip [string trim [Read [file join $dir skip.txt]]]]
    }
    set instances [string trim [Read [file join $dir instances.txt]]]
    set labels [dict create]
    foreach line [split [string trimright [Read [file join $dir labels.txt]] \n] \n] {
        dict set labels [lindex $line 0] [lindex $line 1]
    }
    set dormant [string trim [Read [file join $dir dormant.txt]]]
    set blocks [dict create]
    dict for {id info} $labels {
        if {$id in $dormant} continue
        set block [dict get $info block]
        set inst [dict get $instances $id]
        if {![dict exists $blocks $block]} {
            dict set blocks $block [dict create params [dict get $inst params] result [dict get $inst result] \
                exprs [dict get $inst exprs] names [dict get $info pnames] labels [list [dict get $info label]]]
            continue
        }
        set b [dict get $blocks $block]
        dict set b params [lmap x [dict get $b params] y [dict get $inst params] {Join $x $y}]
        dict set b result [Join [dict get $b result] [dict get $inst result]]
        set ex [dict get $b exprs]
        dict for {e r} [dict get $inst exprs] {
            dict set ex $e [expr {[dict exists $ex $e] ? [Join [dict get $ex $e] $r] : $r}]
        }
        dict set b exprs $ex
        dict lappend b labels [dict get $info label]
        dict set blocks $block $b
    }
    set nir [Read [file join $dir nir.txt]]
    regsub -all {instance="[^"]*"} $nir {instance=X} plain
    regsub -all { @e\d+} $plain {} plain
    return [dict create blocks $blocks used [dict size $labels] dormant [llength $dormant] \
        funcs [regexp -all -line {^func } $nir] nir $nir plain $plain]
}

set out {}
set totals [dict create programs 0 facts 0 same 0 equal 0 narrower 0 wider 0 incomparable 0 \
    blocksOneSide 0 nirSame 0 nirSameModuloLabels 0 nirDifferent 0]
set details {}
set rows {}
foreach path $programs {
    set stem [string map {/ __} [string trimleft [file rootname $path] ./]]
    set d0 [Load [file join $dump0 $stem]]
    set d1 [Load [file join $dump1 $stem]]
    if {[dict exists $d0 skip] || [dict exists $d1 skip]} {
        lappend details "$path: skipped ([expr {[dict exists $d0 skip] && [dict exists $d1 skip] ? "both" : "ONE SIDE ONLY"}])"
        continue
    }
    dict incr totals programs
    set cat [dict create same 0 equal 0 narrower 0 wider 0 incomparable 0]
    set pd {}
    set b0 [dict get $d0 blocks]
    set b1 [dict get $d1 blocks]
    foreach block [lsort -unique [concat [dict keys $b0] [dict keys $b1]]] {
        if {![dict exists $b0 $block] || ![dict exists $b1 $block]} {
            dict incr totals blocksOneSide
            set side [expr {[dict exists $b0 $block] ? 0 : 1}]
            set lab [dict get [expr {$side ? $b1 : $b0}] $block labels]
            lappend pd "    function $block live at knob $side only ([join $lab {, }])"
            continue
        }
        set x [dict get $b0 $block]
        set y [dict get $b1 $block]
        set name "[join [dict get $y labels] {, }]"
        set facts {}
        foreach r0 [dict get $x params] r1 [dict get $y params] p [dict get $y names] {
            lappend facts "entry $p" $r0 $r1
        }
        lappend facts result [dict get $x result] [dict get $y result]
        set ex0 [dict get $x exprs]
        set ex1 [dict get $y exprs]
        foreach e [lsort -dictionary -unique [concat [dict keys $ex0] [dict keys $ex1]]] {
            if {[dict exists $ex0 $e] && [dict exists $ex1 $e]} {
                lappend facts "expr $e" [dict get $ex0 $e] [dict get $ex1 $e]
            }
        }
        foreach {what r0 r1} $facts {
            dict incr totals facts
            set cls [Classify $r0 $r1]
            dict incr cat $cls
            dict incr totals $cls
            if {$cls ne "same"} {
                set mark [expr {$cls in {wider incomparable} ? "!!" : "  "}]
                lappend pd "  $mark$cls  $block ($name) $what: [Show $r0] -> [Show $r1]"
            }
        }
    }
    if {[dict get $d0 nir] eq [dict get $d1 nir]} {
        set nirClass same
        dict incr totals nirSame
    } elseif {[dict get $d0 plain] eq [dict get $d1 plain]} {
        set nirClass same-modulo-labels
        dict incr totals nirSameModuloLabels
    } else {
        set nirClass DIFFERENT
        dict incr totals nirDifferent
    }
    lappend rows [format "%-36s %5s %5s %5s %5s %5s %5s %-18s" $path \
        "[dict get $d0 used]>[dict get $d1 used]" "[dict get $d0 dormant]>[dict get $d1 dormant]" \
        "[dict get $d0 funcs]>[dict get $d1 funcs]" [dict get $cat narrower] \
        [expr {[dict get $cat wider] + [dict get $cat incomparable]}] [dict get $cat equal] $nirClass]
    if {$pd ne "" || $nirClass ne "same"} {
        lappend details "== $path (NIR: $nirClass)"
        lappend details {*}$pd
    }
}
lappend out "Function-level census (GENERIC-PREDICATE-PROOF-LOSS.md, loss point 1): knob 0 vs 1"
lappend out "Facts: per function, the join over its live (non-dormant) instances of entry, result and expression Ranges."
lappend out ""
lappend out [format "%-36s %5s %5s %5s %5s %5s %5s %-18s" program used dorm nirFn narrow WIDER equal NIR]
foreach r $rows { lappend out $r }
lappend out ""
lappend out "Columns: used / dorm / nirFn = used instances, dormant instances, emitted NIR functions (knob 0 > knob 1)."
lappend out ""
lappend out "Totals: programs [dict get $totals programs]; facts [dict get $totals facts]: same [dict get $totals same],\
    equal [dict get $totals equal], narrower [dict get $totals narrower], wider [dict get $totals wider],\
    incomparable [dict get $totals incomparable]; functions live at one knob only [dict get $totals blocksOneSide]"
lappend out "NIR: byte-identical [dict get $totals nirSame], identical modulo instance labels [dict get $totals nirSameModuloLabels],\
    different [dict get $totals nirDifferent]"
lappend out ""
lappend out "Details"
lappend out "======="
lappend out {*}$details
set text "[join $out \n]\n"
if {$outPath eq "-"} {
    puts -nonewline $text
} else {
    set f [open $outPath w]
    fconfigure $f -encoding utf-8 -translation lf
    puts -nonewline $f $text
    close $f
}
puts stderr "programs [dict get $totals programs] facts [dict get $totals facts] narrower [dict get $totals narrower] wider [dict get $totals wider] incomparable [dict get $totals incomparable] nir same [dict get $totals nirSame] modulo-labels [dict get $totals nirSameModuloLabels] different [dict get $totals nirDifferent]"
