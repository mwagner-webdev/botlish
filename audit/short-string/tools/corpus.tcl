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
    puts [format "%-16s values %s  strtoshort %3d shorttostr %3d shortlit %3d shortlen %2d shorteq %2d slice %2d | short ABI functions %2d (params %2d results %2d) | %d bytes" \
        [programName $path] [expr {$same ? "agree   " : "DISAGREE"}] \
        [dict get $c strtoshort] [dict get $c shorttostr] [dict get $c shortlit] [dict get $c shortlen] [dict get $c shorteq] [dict get $c strsliceshort] \
        [dict get $c shortFunctions] [dict get $c shortparams] [dict get $c shortresult] $size]
}
puts "disagreements: $bad"
