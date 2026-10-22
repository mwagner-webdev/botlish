# longrun.tcl -- does a process that analyzes again and again stay bounded?
# (COMPILER-SERVICE-CENSUS.md, "State and lifetime model": resource
# ownership in a long-running process)
#
#   tclsh9.0 audit/compiler-service/probes/longrun.tcl ?-rounds N? ?-run 0|1?
#
# Analyzes examples/games/2048/demo.bot N times (default 40) in one process,
# each time with a different edit of game2048.bot in a buffer (as an editor
# session would), keeping only the latest analysis -- what a service holding
# one revision per document would do. Every 10 rounds it prints the
# resident set and the size of every process-wide namespace variable of the
# compiler that grew since the first round (dict or list length), so growth
# that is not released shows up by name. With -run 1 each round also runs
# the program on the compile backend (the Tcl compiler's code cache and unit
# procedures, which COMPILATION-ISOLATION.md records as never reclaimed).

set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
source [file join $here lib.tcl]
cs::load $root
interp recursionlimit {} 200000

set options [dict create -rounds 40 -run 0]
foreach {k v} $argv { dict set options $k $v }

proc rss {} {
    set ch [open /proc/self/status]
    set text [read $ch]
    close $ch
    regexp {VmRSS:\s+(\d+)} $text -> kb
    return [expr {$kb / 1024}]
}

# Every namespace variable under the compiler's namespaces, with a size.
proc Sizes {} {
    set sizes [dict create]
    foreach ns [concat [namespace children ::hir] [namespace children ::surface] \
            [namespace children ::core] ::hir ::surface ::core ::core::compiler] {
        foreach var [info vars ${ns}::*] {
            if {![info exists $var] || [array exists $var]} continue
            set value [set $var]
            if {[catch {dict size $value} n]} {
                if {[catch {llength $value} n]} { set n 0 }
            }
            dict set sizes $var $n
        }
    }
    dict set sizes procs [llength [info procs ::core::compiler::code::*]]
    return $sizes
}

set dir [file normalize [file tempdir]]
foreach f [glob -directory [file join $root examples games 2048] *.bot] {
    file copy $f $dir
}
set entry [file join $dir demo.bot]
set module [file join $dir game2048.bot]
set text [core::ReadFile $module]
set needle {scores.get(i, 0) + from(i + 1)}

set first ""
set latest ""
for {set i 1} {$i <= [dict get $options -rounds]} {incr i} {
    # A different edit each round: new text to every cache.
    set edited [string map [list $needle "$needle + [expr {$i % 7}] * 0 + $i - $i"] $text]
    set latest [cs::analyze $entry -overlay [list $module $edited] -warnings off]
    if {[dict get $options -run] && [dict get $latest status] eq "ok"} {
        hir::activate [dict get $latest hir]
        # The demo's I/O is native-only (NATIVE-ONLY at run time on the Tcl
        # backends); its compilation, which fills the code cache, runs first.
        catch {core::compiler::evalHir [dict get $latest hir]}
    }
    if {$i == 1} {
        set first [Sizes]
        puts "round 1: status [dict get $latest status], rss [rss] MiB"
    }
    if {$i % 10 == 0} {
        set now [Sizes]
        set grew {}
        dict for {var n} $now {
            set was [dict getdef $first $var 0]
            if {$n > $was + 2} {
                lappend grew "[string trimleft $var :] $was->$n"
            }
        }
        puts "round $i: rss [rss] MiB; grew since round 1: [expr {$grew eq "" ? "nothing" : [join $grew {, }]}]"
    }
}
file delete -force $dir
