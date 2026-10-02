#!/usr/bin/env tclsh9.0
# codesize.tcl -- SHORT-STRING.md machine-code size: per program, whole-program
# bytes with ShortString1 off and on, and the bytes of exactly the functions
# whose NIR changed. Also determinism: the same program compiled twice gives
# byte-identical NIR and the same machine-code size. Observation only.
#
#   tclsh9.0 audit/short-string/tools/codesize.tcl ?PROGRAM.bot...?
source [file join [file dirname [file normalize [info script]]] lib.tcl]
set paths $argv
if {$paths eq ""} { set paths [corpusPaths] }
set g0 0; set g1 0; set functions0 0; set functions1 0
puts [format "%-16s %9s %9s %7s | functions %4s %4s" program off on delta off on]
foreach path $paths {
    set hir [surface::readProgramFile $path]
    set s0 [native::codeSize $hir -short-string-opt 0]
    set s1 [native::codeSize $hir -short-string-opt 1]
    set again [native::codeSize $hir -short-string-opt 1]
    if {[native::nir $hir -short-string-opt 1] ne [native::nir $hir -short-string-opt 1] || [lindex $s1 0] != [lindex $again 0]} {
        puts "NONDETERMINISTIC: $path"
    }
    puts [format "%-16s %9d %9d %+7d | functions %4d %4d" [programName $path] [lindex $s0 0] [lindex $s1 0] [expr {[lindex $s1 0] - [lindex $s0 0]}] [llength [lindex $s0 1]] [llength [lindex $s1 1]]]
    incr g0 [lindex $s0 0]; incr g1 [lindex $s1 0]
    incr functions0 [llength [lindex $s0 1]]; incr functions1 [llength [lindex $s1 1]]
}
puts [format "%-16s %9d %9d %+7d | functions %4d %4d" TOTAL $g0 $g1 [expr {$g1 - $g0}] $functions0 $functions1]
