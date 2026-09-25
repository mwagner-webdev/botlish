#!/usr/bin/env tclsh9.0
# census.tcl -- mechanical NIR/asm census over probe.tcl output directories
# (COMPREHENSIVE-GENERATED-CODE-AUDIT.md's box/unbox/guard, generic-call and
# code-size tables). Reads only files probe.tcl wrote; changes nothing.
#
#   tclsh9.0 audit/comprehensive-generated-code/tools/census.tcl OUTDIR...
#
# For every NIR function it classifies each guard by the instance it sits in
# (generic vs specialized) and whether the guarded register is a parameter
# (%0..%params-1: a fact the caller had to hand over) or a local; counts
# representation conversions (runbox/rbox), helper-backed ops, call kinds,
# and, from effects.txt, how many exact calls still carry a may_error check.

proc Read {path} {
    set f [open $path r]
    fconfigure $f -encoding utf-8
    set t [read $f]
    close $f
    return $t
}

set helperOps {listget listappend listnew listlen setcontains setfromlist charcodepoint
    strlen strcat substr regioneq regioncheck strregiontclalnum strregiontclalpha
    decodecharat strbytelen strutf8bytes veq streq hash imod}

foreach dir $argv {
    set name [file tail $dir]
    set nir [Read [file join $dir nir.txt]]
    set counts [dict create]
    set fn ""
    set generic 0
    set nparams 0
    foreach line [split $nir \n] {
        if {[regexp {^func \d+ "([^"]*)" params=(\d+) .*instance="([^"]*)"} $line -> fname np inst]} {
            set fn $fname
            set generic [expr {$inst eq "generic"}]
            set nparams $np
            dict incr counts functions
            if {$generic && $fname ne "<program>"} { dict incr counts genericFunctions }
            continue
        }
        set l [string trim $line]
        if {[regexp {^guard(bool)? (\w+)? ?%(\d+)} $l -> isBool kind reg]} {
            if {$isBool ne ""} {
                dict incr counts guardbool
            } else {
                set where [expr {$reg < $nparams ? "param" : "local"}]
                set inst [expr {$generic ? "generic" : "specialized"}]
                dict incr counts "guard $kind $inst-instance $where"
            }
            continue
        }
        if {[regexp {= op (runbox|rbox) } $l -> k]} { dict incr counts $k; continue }
        if {[regexp {= op (\w+)} $l -> op]} {
            if {$op in $helperOps} { dict incr counts "op $op" }
            if {[string match r* $op] && $op ni {regioneq regioncheck}} { dict incr counts rawop }
            if {$op in {ilt ile igt ige ieq iadd isub imul}} { dict incr counts "tagged-int $op" }
            continue
        }
        if {[regexp {= (call|callenv|callvalue|callmulti|callenvmulti) } $l -> c]} { dict incr counts $c; continue }
        if {[regexp {^(tail|tailenv) } $l -> c]} { dict incr counts $c; continue }
        if {[regexp {^(faildeclared|reraise|pusherrorexit|unreachable)} $l -> c]} { dict incr counts $c; continue }
        if {[regexp {= (closure|capture) } $l -> c]} { dict incr counts $c; continue }
    }
    set effects [Read [file join $dir effects.txt]]
    if {[regexp {exact_calls=(\d+) false_false=(\d+) false_true=(\d+) true_false=(\d+) true_true=(\d+)} $effects -> tot ff ft tf tt]} {
        dict set counts "exact calls" $tot
        dict set counts "exact calls with may_error check" [expr {$tf + $tt}]
    }
    set summary [Read [file join $dir summary.txt]]
    regexp {machine code bytes: (\S+)} $summary -> bytes
    regexp {allocations=(\d+)} $summary -> allocs
    puts "== $name  (bytes=$bytes allocations=$allocs)"
    foreach k [lsort [dict keys $counts]] {
        puts [format "    %-44s %s" $k [dict get $counts $k]]
    }
}
