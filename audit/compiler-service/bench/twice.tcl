# twice.tcl -- one fresh process: load the compiler, analyze FILE three times
# (service-bench.tcl, "What a persistent process would save").
#
#   tclsh9.0 audit/compiler-service/bench/twice.tcl FILE
#
# Prints four times in ms: loading the compiler (and the probe library),
# the first analysis, the second (bytecode and parse cache warm) and a third
# with the loader's parse cache emptied (bytecode warm).
set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
interp recursionlimit {} 200000
set t0 [clock microseconds]
source [file join $root audit compiler-service probes lib.tcl]
cs::load $root
set t1 [clock microseconds]
set file [lindex $argv 0]
cs::analyze $file -warnings default
set t2 [clock microseconds]
cs::analyze $file -warnings default
set t3 [clock microseconds]
set ::surface::modules::parsed [dict create]
cs::analyze $file -warnings default
set t4 [clock microseconds]
puts [lmap {a b} [list $t0 $t1 $t1 $t2 $t2 $t3 $t3 $t4] {expr {($b - $a) / 1000.0}}]
