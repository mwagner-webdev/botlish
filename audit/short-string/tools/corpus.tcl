#!/usr/bin/env tclsh9.0
# corpus.tcl -- SHORT-STRING.md: for every canonical corpus program, the value
# with ShortString1 off and on (native), the static ShortString1 operation
# counts, and whether the emitted NIR is accepted by the validator and
# compiled to machine code. Observation only.
#
#   tclsh9.0 audit/short-string/tools/corpus.tcl
source [file join [file dirname [file normalize [info script]]] lib.tcl]
set bad 0
foreach path [corpusPaths] {
    set hir [surface::readProgramFile $path]
    set prepared [native::prepareHir $hir]
    set off [native::evalHir $prepared -short-string-opt 0]
    set on [native::evalHir $prepared -short-string-opt 1]
    set same [core::value::equal $off $on]
    if {!$same} { incr bad }
    set nir [native::nir $hir -short-string-opt 1]
    set c [shortCounts $nir]
    set size [lindex [native::codeSize $hir -short-string-opt 1] 0]
    puts [format "%-16s values %s  A: strtoascii %2d asciitostr %2d asciilit %3d len %2d eq %2d | S: strtoshort %2d shorttostr %2d shortlit %3d len %2d eq %2d slice %2d | widen %d mixedeq %d | ABI functions A %2d S %2d | %d bytes" \
        [programName $path] [expr {$same ? "agree   " : "DISAGREE"}] \
        [dict get $c strtoascii] [dict get $c asciitostr] [dict get $c asciilit] [dict get $c asciilen] [dict get $c asciieq] \
        [dict get $c strtoshort] [dict get $c shorttostr] [dict get $c shortlit] [dict get $c shortlen] [dict get $c shorteq] [dict get $c strsliceshort] \
        [dict get $c asciitoshort] [dict get $c asciishorteq] \
        [dict get $c asciiFunctions] [dict get $c shortFunctions] $size]
}
puts "disagreements: $bad"
