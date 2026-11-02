# probes.tcl -- the outcome of every program of audit/equality-semantics/probes
# (EQUALITY-SEMANTICS.md, "What == is today" and "Integer domains").
#
#   tclsh9.0 audit/equality-semantics/tools/probes.tcl ?-backends B,...? ?PROBE.bot ...?
#
# Runs each probe (default: all of them) through main.tcl with warnings off
# on each backend (default interp and cranelift), each run a child process
# with a 300 s limit, and prints its value or its first diagnostic per
# backend. The checkout is only read.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set backends {interp cranelift}
set probes {}
for {set i 0} {$i < [llength $argv]} {incr i} {
    set arg [lindex $argv $i]
    if {$arg eq "-backends"} {
        set backends [split [lindex $argv [incr i]] ,]
    } else {
        lappend probes [file normalize $arg]
    }
}
if {$probes eq {}} {
    set probes [lsort [glob -directory [file join $root audit equality-semantics probes] *.bot]]
}
set env(LANG) C.utf8
set env(LC_ALL) C.utf8
foreach probe $probes {
    puts "== [file tail $probe]"
    foreach backend $backends {
        catch {exec timeout 300 tclsh9.0 [file join $root main.tcl] -warnings off -backend $backend $probe 2>@1} output
        set shown ""
        foreach line [split $output \n] {
            set line [string trim $line]
            if {[regexp {^value: (.*)$} $line -> value]} {
                set shown "value $value"
                break
            }
            if {[regexp {^error: [^ ]+:\d+:\d+: (.*)$} $line -> message] || [regexp {^error: (.*)$} $line -> message]} {
                set shown "error $message"
                break
            }
        }
        if {$shown eq ""} {
            set shown "? [lindex [split [string trim $output] \n] end]"
        }
        puts "  [format %-10s $backend] $shown"
    }
}
