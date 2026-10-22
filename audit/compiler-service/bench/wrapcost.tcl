# wrapcost.tcl -- what renaming a compiled-inline command costs the next
# build (COMPILER-SERVICE-CENSUS.md, "Performance results": the measurement
# artifact the census found in its own first benchmark run).
#
#   tclsh9.0 audit/compiler-service/bench/wrapcost.tcl ?FILE ...?
#
# The first version of the probe library wrapped `file` and core::ReadFile
# by renaming them around every analysis. Renaming a command Tcl compiles
# inline (`file` is a compiled ensemble) invalidates every compiled
# procedure, so the next build recompiled the compiler's procedures it ran.
# This script times a strict front-end build of each FILE (default: the
# one-line arithmetic example and the 2048 demo) right after another build,
# and right after renaming `file` away and back.
set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
interp recursionlimit {} 200000
set files $argv
if {$files eq ""} {
    set files [list [file join $root examples surface 01-arithmetic.bot] [file join $root examples games 2048 demo.bot]]
}
proc build {f} { surface::modules::compileProgramFile $f -cache "" -warnings off -warning-channel "" }
foreach f $files {
    build $f
    set plain {}
    set renamed {}
    for {set i 0} {$i < 5} {incr i} {
        lappend plain [lindex [time {build $f}] 0]
        rename ::file ::fileSaved
        rename ::fileSaved ::file
        lappend renamed [lindex [time {build $f}] 0]
    }
    set plain [lsort -integer $plain]
    set renamed [lsort -integer $renamed]
    puts [format "%-20s build after a build: median %7.1f ms; after renaming `file`: median %7.1f ms" \
        [file tail $f] [expr {[lindex $plain 2] / 1000.0}] [expr {[lindex $renamed 2] / 1000.0}]]
}
