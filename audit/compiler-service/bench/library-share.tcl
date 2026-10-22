# library-share.tcl -- how much of an analysis is the standard library?
# (COMPILER-SERVICE-CENSUS.md, "Incrementality alternatives", strategy B's
# sound subset, and COMPILER-BOTTLENECKS.md item 10)
#
#   tclsh9.0 audit/compiler-service/bench/library-share.tcl ?-repeat N?
#
# For each workload: the share of the analyzed HIR's expressions whose origin
# is a standard-library file, the whole-program builds the analysis made,
# and the time of the analysis beside the time of its "library floor": a
# program that imports exactly the standard namespaces the application's own
# files import and does nothing else. The floor's time is what reusing the
# library's analysis could at most save per build (it is an upper bound:
# the floor program pays its own fixed costs too).

set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
source [file join $root audit compiler-service probes lib.tcl]
cs::load $root
interp recursionlimit {} 200000

set options [dict create -repeat 3]
foreach {k v} $argv { dict set options $k $v }
set N [dict get $options -repeat]

set workloads {
    csv examples/stdlib/csv.bot
    2048 examples/games/2048/demo.bot
    icy examples/games/icy-tower/headless.bot
    2048-golden examples/games/2048/golden.bot
}

proc median {xs} {
    set s [lsort -real $xs]
    return [lindex $s [expr {[llength $s] / 2}]]
}

set lib [file normalize $::core::libraryDir]
set dir [file normalize [file tempdir]]
puts "| workload | expressions | from stdlib/ | builds | analysis, ms | library floor, ms | floor builds | floor share |"
puts "|---|---:|---:|---:|---:|---:|---:|---:|"
foreach {name rel} $workloads {
    set entry [file join $root $rel]
    set b0 [dict get [hir::BuildStats] builds]
    set r [cs::analyze $entry -warnings off]
    set builds [expr {[dict get [hir::BuildStats] builds] - $b0}]
    set hir [dict get $r hir]
    set total 0
    set fromLib 0
    dict for {e node} [dict get $hir exprs] {
        set origin [dict get $node origin]
        if {[lindex $origin 0] ne "file"} continue
        incr total
        set path [file normalize [dict get [hir::sourceFile $hir [lindex $origin 1]] path]]
        if {[string first $lib/ $path] == 0} { incr fromLib }
    }
    # The standard namespaces the application's own files import: an
    # application file is the entry ("") or a module with a file beside it.
    set appRoot [file dirname $entry]
    proc appModule? {root ns} {
        return [file exists [file join $root {*}[split [string map {:: /} $ns] /]].bot]
    }
    set standard {}
    dict for {ns environment} [dict get $hir declarations imports] {
        if {$ns ne "" && ![appModule? $appRoot $ns]} continue
        foreach imported [dict get $environment namespaces] {
            if {![appModule? $appRoot $imported]} {
                lappend standard $imported
            }
        }
    }
    set standard [lsort -unique $standard]
    set floor [file join $dir floor-$name.bot]
    set ch [open $floor w]
    puts $ch "[join [lmap ns $standard {string cat "import " $ns}] \n]\n\n1"
    close $ch
    set t {}
    set f {}
    for {set i 0} {$i < $N} {incr i} {
        lappend t [lindex [time {cs::analyze $entry -warnings off}] 0]
        set fb0 [dict get [hir::BuildStats] builds]
        lappend f [lindex [time {set fr [cs::analyze $floor -warnings off]}] 0]
        set floorBuilds [expr {[dict get [hir::BuildStats] builds] - $fb0}]
    }
    set tm [expr {[median $t] / 1000.0}]
    set fm [expr {[median $f] / 1000.0}]
    puts [format "| %s | %d | %d (%.0f%%) | %d | %.0f | %.0f | %d | %.0f%% |" $name $total $fromLib \
        [expr {100.0 * $fromLib / $total}] $builds $tm $fm $floorBuilds [expr {100.0 * $fm / $floorBuilds * $builds / $tm}]]
    puts stderr "  $name floor imports: $standard (status [dict get $fr status])"
}
puts "\n\"floor share\" = the floor's time per build x the workload's builds / the workload's analysis time: the part of the analysis a per-build reuse of the library's analysis could at most remove."
file delete -force $dir
