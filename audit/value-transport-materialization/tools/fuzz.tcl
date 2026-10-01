#!/usr/bin/env tclsh9.0
# fuzz.tcl DIR ?STRESS? -- the differential check for fuzz.py's programs: the
# reference interpreter and native code under every representation mode must
# agree on the value of every program:
#   default   the transport policy (distance, direction, cycles, nesting)
#   legacy    the previous milestone's width-only policy
#   nonest    transport without nested opening
#   virtual   every budget and ceiling raised: nothing is materialized for cost
#   frugal    budgets 0: every boundary materializes (frontier at construction)
#   off       -struct-opt 0: every struct physical
# With STRESS 1, the default lowering also runs under GC stress. Prints one line
# per disagreement and a summary. Observation only.
set root [pwd]
set args $argv
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
interp recursionlimit {} 100000
lassign $args dir stress
set modes {
    default {}
    legacy {-struct-policy legacy}
    nonest {-struct-nesting 0}
    virtual {-struct-local-width 64 -struct-return-width 64 -struct-arg-width 64 -struct-arg-budget 1e12 -struct-return-budget 1e12 -struct-cycle-budget 1e12}
    frugal {-struct-arg-budget 0 -struct-return-budget 0 -struct-cycle-budget 0}
    off {-struct-opt 0}
}
set n 0; set bad 0; set skipped 0; set virtualPrograms 0; set denied 0; set opened 0
foreach path [lsort [glob -directory $dir *.bot]] {
    incr n
    if {[catch {set hir [surface::readProgramFile $path]} msg]} {
        incr skipped
        continue
    }
    set interp [outcomeUnderHir interp $hir]
    set results [list [lindex $interp 1]]
    set names {interp}
    foreach {name opts} $modes {
        if {[catch {native::evalHir $hir {*}$opts} v]} {
            lappend results "error $v"
        } else {
            lappend results [core::value::show $v 1]
        }
        lappend names $name
    }
    if {$stress eq "1"} {
        set ::env(BOTLISH_NATIVE_GC_STRESS) 1
        lappend results [lindex [outcomeUnderHir cranelift $hir] 1]
        unset ::env(BOTLISH_NATIVE_GC_STRESS)
        lappend names stress
    }
    if {[lindex $interp 0] ne "value" || [llength [lsort -unique $results]] != 1} {
        incr bad
        puts "MISMATCH $path"
        foreach name $names r $results { puts "  [format %-8s $name] [string range $r 0 160]" }
    }
    set m [dict get [native::transportCensus $hir] metrics]
    if {[dict get $m virtual] > 0} { incr virtualPrograms }
    incr denied [dict get $m deniedParams]
    incr opened [dict get $m nestedOpened]
}
puts "programs $n, compile-skipped $skipped, mismatches $bad, programs with virtual structs $virtualPrograms, denied slots $denied, nested values opened $opened"
