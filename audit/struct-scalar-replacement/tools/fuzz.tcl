#!/usr/bin/env tclsh9.0
# fuzz.tcl DIR ?STRESS? -- the differential check for fuzz.py's programs: the
# interpreter, native with struct scalar replacement and native with
# -struct-opt 0 must agree on the value of every program (and, with STRESS
# 1, native under GC stress too). Prints one line per disagreement and a
# summary. Observation only.
set root [pwd]
set args $argv
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
interp recursionlimit {} 100000
lassign $args dir stress
set n 0; set bad 0; set skipped 0; set virtual 0
foreach path [lsort [glob -directory $dir *.bot]] {
    incr n
    if {[catch {set hir [surface::readProgramFile $path]} msg]} {
        incr skipped
        continue
    }
    set interp [outcomeUnderHir interp $hir]
    set on [outcomeUnderHir cranelift $hir]
    if {[catch {native::evalHir $hir -struct-opt 0} off]} {
        set offShown "error $off"
    } else {
        set offShown [core::value::show $off 1]
    }
    set results [list [lindex $interp 1] [lindex $on 1] $offShown]
    if {$stress eq "1"} {
        set ::env(BOTLISH_NATIVE_GC_STRESS) 1
        set stressed [outcomeUnderHir cranelift $hir]
        unset ::env(BOTLISH_NATIVE_GC_STRESS)
        lappend results [lindex $stressed 1]
    }
    if {[llength [lsort -unique [concat [lindex $interp 0] $results]]] > 2 || [llength [lsort -unique $results]] != 1 || [lindex $interp 0] ne "value"} {
        incr bad
        puts "MISMATCH $path\n  interp: $interp\n  opt:    $on\n  off:    $offShown"
    }
    set text [dict get [native::lowered $hir] text]
    set off [dict get [native::lowered $hir -struct-opt 0] text]
    if {[regexp -all {= structnew } $text] < [regexp -all {= structnew } $off]} { incr virtual }
}
puts "programs $n, compile-skipped $skipped, mismatches $bad, programs with fewer structnew $virtual"
