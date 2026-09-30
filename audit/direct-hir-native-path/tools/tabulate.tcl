#!/usr/bin/env tclsh9.0
# tabulate.tcl -- totals over the differential.tcl summaries of two runs.
#
#   tclsh9.0 tabulate.tcl LABEL-A DIR-A LABEL-B DIR-B [N-CANONICAL]
#
# Reads DIR/summary.txt of each run, sums the numeric columns over the first
# N-CANONICAL programs (default 17: bench/*.bot then examples/stdlib/*.bot),
# and prints the two totals side by side with the difference, then every
# program whose row differs between the runs.
lassign $argv la da lb db n
if {$n eq ""} { set n 17 }
proc load {dir} {
    set rows [dict create]
    set order {}
    set f [open [file join $dir summary.txt]]
    while {[gets $f line] >= 0} {
        if {$line eq ""} continue
        set name [lindex $line 0]
        lappend order $name
        dict set rows $name [lrange $line 1 end]
    }
    close $f
    return [list $order $rows]
}
lassign [load $da] orderA rowsA
lassign [load $db] orderB rowsB
set fields {requests trivial hits walks rounds instances used codegen functions lines guards calls callvalues bytes}
proc total {order rows n fields} {
    set t [dict create closed 0 guarded 0 open 0]
    foreach k $fields { dict set t $k 0 }
    foreach name [lrange $order 0 [expr {$n - 1}]] {
        set r [dict get $rows $name]
        if {[lindex $r 0] in {REJECTED UNSUPPORTED}} continue
        foreach k $fields { dict incr t $k [dict get $r $k] }
        lassign [split [dict get $r aot] /] c g o
        dict incr t closed $c; dict incr t guarded $g; dict incr t open $o
    }
    return $t
}
set ta [total $orderA $rowsA $n $fields]
set tb [total $orderB $rowsB $n $fields]
puts [format "%-14s %12s %12s %8s" "(first $n)" $la $lb diff]
foreach k [concat $fields {closed guarded open}] {
    puts [format "%-14s %12d %12d %+8d" $k [dict get $ta $k] [dict get $tb $k] [expr {[dict get $tb $k] - [dict get $ta $k]}]]
}
puts "\nprograms whose rows differ (digests excluded):"
foreach name $orderA {
    if {![dict exists $rowsB $name]} continue
    set a [dict get $rowsA $name]; set b [dict get $rowsB $name]
    set diff {}
    foreach k [concat $fields aot] {
        if {[dict exists $a $k] && [dict get $a $k] ne [dict get $b $k]} {
            lappend diff "$k [dict get $a $k]->[dict get $b $k]"
        }
    }
    if {$diff ne ""} { puts [format "  %-22s %s" $name [join $diff {, }]] }
}
