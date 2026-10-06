#!/usr/bin/env tclsh9.0
# measure.tcl -- the numbers ENCODE-UTF8-ALLOCATION-RESEARCH.md reports for
# one Botlish program, on one source tree.
#
#   tclsh9.0 measure.tcl ?-root TREE? ?-runs N? ?-repeat K? ?-fn NAME ...? PROGRAM.bot
#
# TREE (default: this checkout) supplies compiler/, surface/, native/ and
# lib/, so a prototype in a scratch copy of the tree is measured by pointing
# -root at it. PROGRAM is read relative to the current directory. Prints:
#   value BACKEND OUTCOME            on interp, compile, cranelift-generic, cranelift
#   alloc OBJECTS BYTES KIND N/BYTES ...   native::allocationReport summary (1 run),
#                                     every kind with a nonzero count
#   size TOTAL                        native::codeSize, all functions
#   fnsize NAME BYTES                 machine code of every function whose
#                                     NIR name matches a -fn NAME (all instances)
#   best US                           min over K repetitions of native::measure HIR N
#   repeatable NAME WHY               hir::repeatable::explain of module function NAME
#                                     ("" = proven repeatable)
set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
set runs 20
set repeat 5
set fns {}
set program ""
for {set i 0} {$i < [llength $argv]} {incr i} {
    switch -- [lindex $argv $i] {
        -root { set root [file normalize [lindex $argv [incr i]]] }
        -runs { set runs [lindex $argv [incr i]] }
        -repeat { set repeat [lindex $argv [incr i]] }
        -fn { lappend fns [lindex $argv [incr i]] }
        default { set program [file normalize [lindex $argv $i]] }
    }
}
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000

set hir [surface::readProgramFile $program -warnings off]

foreach backend {interp compile cranelift-generic cranelift} {
    if {$backend in {interp compile}} {
        core::useBackend $backend
        set status [catch {core::evalProgram [hir::lower $hir]} r opts]
    } else {
        set options [expr {$backend eq "cranelift-generic" ? {-specialize 0} : {}}]
        set status [catch {native::evalHir $hir {*}$options} r opts]
    }
    if {$status} {
        puts "value $backend error [dict get $opts -errorcode] [lindex [split $r \n] 0]"
    } else {
        puts "value $backend [core::value::show $r 1 1]"
    }
}

set report [native::allocationReport $hir summary]
set total [dict get $report total]
set kinds {}
dict for {k info} [dict get $report byKind] {
    if {[dict get $info allocations]} {
        lappend kinds $k [dict get $info allocations]/[dict get $info allocatedBytes]B
    }
}
puts "alloc [dict get $total allocations] [dict get $total allocatedBytes] $kinds"

lassign [native::codeSize $hir] sizeTotal sizes
puts "size $sizeTotal"
if {[llength $fns]} {
    set names [lmap l [lsearch -all -inline -regexp [split [native::nir $hir] \n] {^func }] {
        regexp {^func \d+ "([^"]*)"} $l -> n; set n
    }]
    foreach fn $fns {
        set bytes 0
        foreach n $names s $sizes {
            if {$n eq $fn} { incr bytes $s }
        }
        puts "fnsize $fn $bytes"
    }
}

set best ""
for {set k 0} {$k < $repeat} {incr k} {
    set b [lindex [native::measure $hir $runs] 2]
    if {$best eq "" || $b < $best} { set best $b }
}
puts [format "best %.1f" $best]

foreach fn $fns {
    if {![string match *::* $fn]} { continue }
    foreach e [hir::walk $hir] {
        if {[hir::kind $hir $e] eq "ref" && [dict exists [hir::node $hir $e] name]
                && [hir::get $hir $e name] eq $fn} {
            set b [hir::get $hir $e binding]
            set why [hir::repeatable::explain $hir [hir::get $hir [dict get [hir::binding $hir $b] declaredBy] value]]
            puts "repeatable $fn [list $why]"
            break
        }
    }
}
