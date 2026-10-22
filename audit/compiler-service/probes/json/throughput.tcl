# throughput.tcl -- how fast is json_tokens.bot on each backend?
# (COMPILER-SERVICE-CENSUS.md, "FFI and JSON feasibility")
#
#   tclsh9.0 audit/compiler-service/probes/json/throughput.tcl
#
# Compiles json_probe.bot with its repeat count set to R0 and to R1 messages
# and runs each three times on a backend; the difference of the medians
# divided by R1 - R0 is the time to tokenize one message, compilation and
# start-up excluded.
set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname [file dirname $here]]]]
source [file join $root audit compiler-service probes lib.tcl]
cs::load $root
uplevel #0 [list source [file join $root native native.tcl]]
core::useProgramRecursionLimit
set text [core::ReadFile [file join $here json_probe.bot]]
set dir [file normalize [file tempdir]]
file copy [file join $here json_tokens.bot] $dir
proc median {xs} { lindex [lsort -real $xs] [expr {[llength $xs] / 2}] }
proc hirWith {repeat} {
    global text dir
    set path [file join $dir probe.bot]
    set ch [open $path w]
    puts -nonewline $ch [string map [list "repeat(message, 200, 0)" "repeat(message, $repeat, 0)"] $text]
    close $ch
    return [surface::readProgramFile $path -warnings off -warning-channel "" -cache ""]
}
foreach {backend r0 r1} {cranelift 0 5000 compile 0 40 interp 0 10} {
    set times {}
    foreach r [list $r0 $r1] {
        set hir [hirWith $r]
        set t {}
        for {set i 0} {$i < 3} {incr i} {
            hir::activate $hir
            set us [lindex [time {
                switch -- $backend {
                    cranelift { native::evalHir $hir }
                    compile { core::compiler::evalHir $hir }
                    interp { core::evalProgram [hir::lower $hir] }
                }
            }] 0]
            lappend t $us
        }
        lappend times [median $t]
    }
    lassign $times a b
    puts [format "%-10s %8.1f us per message (median run: %d messages %.0f ms, %d messages %.0f ms)" \
        $backend [expr {($b - $a) / double($r1 - $r0)}] $r0 [expr {$a / 1000.0}] $r1 [expr {$b / 1000.0}]]
}
file delete -force $dir
