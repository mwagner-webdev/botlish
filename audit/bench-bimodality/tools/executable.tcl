# executable.tcl -- the standalone (AOT) executable of a benchmark program,
# or, when the program is not AOT-ready, its NIR for the driver's `bench`.
#
#   tclsh9.0 audit/bench-bimodality/tools/executable.tcl FILE.bot OUT
#
# Prints "executable PATH" (OUT, as native::executable wrote it) or "nir
# OUT.nir" with the reason the executable was refused. Used by profile.sh.

namespace eval bimodality {}
source [file join [file dirname [file normalize [info script]]] stage.tcl]

lassign $argv path out
bimodality::withHir $path hir {
    if {[catch {native::executable $hir $out} written]} {
        set channel [open $out.nir w]
        fconfigure $channel -encoding utf-8 -translation lf
        puts -nonewline $channel [native::nir $hir]
        close $channel
        puts [list nir $out.nir [lindex [split $written \n] 0]]
    } else {
        puts [list executable $written]
    }
}
