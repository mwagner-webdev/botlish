# economics.tcl -- FOLD-LOOPS-MILESTONE-1.md's compiler economics: for each
# program, the front end's time (best of RUNS, surface::readProgramFile with
# no front-end cache and warnings off), how many times the type walk entered
# a fold's body over the whole compilation (hir::types::FoldBody's walks of
# the body: every type walk, every attempt of an enclosing recursive block,
# every fixpoint attempt of the fold itself), the NIR size (instruction
# lines) and the machine code size of the native executable (bytes of its
# generated functions, nm -S of the botlish_fn_* symbols).
#
#   tclsh9.0 audit/fold-loops/tools/economics.tcl ?-runs N? FILE.bot ...
#
# Each program is compiled in this process, one after another; the native
# executable is written to a private directory, removed at the end.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]

set runs 5
set files {}
for {set i 0} {$i < [llength $argv]} {incr i} {
    set arg [lindex $argv $i]
    if {$arg eq "-runs"} {
        set runs [lindex $argv [incr i]]
    } else {
        lappend files $arg
    }
}

# Counts the body walks of every fold: FoldBody walks its body once per
# fixpoint attempt (Sequence), plus once more when it makes a conflicting
# intermediate poison.
rename ::hir::types::Sequence ::hir::types::SequenceCounted
proc ::hir::types::Sequence {hirVar ctxVar exprs} {
    upvar 1 $hirVar hir $ctxVar ctx
    if {[info level] > 1 && [lindex [info level -1] 0] in {FoldBody ::hir::types::FoldBody hir::types::FoldBody}} {
        incr ::foldWalks
    }
    return [::hir::types::SequenceCounted hir ctx $exprs]
}

set work [file tempdir]
puts [format "%-44s %12s %10s %8s %10s" program "front end" "fold walks" "NIR" "code bytes"]
foreach path $files {
    set best ""
    for {set run 0} {$run < $runs} {incr run} {
        set ::foldWalks 0
        set started [clock microseconds]
        set hir [surface::readProgramFile $path -warnings off]
        set elapsed [expr {[clock microseconds] - $started}]
        if {$best eq "" || $elapsed < $best} {
            set best $elapsed
        }
        set walks $::foldWalks
    }
    set nir [native::nir $hir]
    set instructions 0
    foreach line [split $nir \n] {
        if {[regexp {^\s+(%\d+ = |br |jump |ret |call |unreachable|raise )} $line]} {
            incr instructions
        }
    }
    set bytes n/a
    if {![catch {native::executable $hir [file join $work program]} exe]} {
        set bytes 0
        foreach line [split [exec nm -S --defined-only $exe] \n] {
            if {[regexp {^[0-9a-f]+ ([0-9a-f]+) [tT] botlish_fn_\d+$} $line -> size]} {
                incr bytes [expr {"0x$size"}]
            }
        }
    }
    set label [file join [file tail [file dirname $path]] [file tail $path]]
    puts [format "%-44s %9.1f ms %10d %8d %10s" $label [expr {$best / 1000.0}] $walks $instructions $bytes]
}
file delete -force $work
