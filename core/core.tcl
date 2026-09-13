# core.tcl -- loads the reference evaluator.
#
#   source core/core.tcl
#   core::formatValue [core::eval {call {ref +} {const 1} {const 2}}]   ;# => 3
#
# Optional libraries in lib/ (e.g. lib/web.tcl) are not loaded by default:
#
#   core::loadLibrary web

package require Tcl 8.6

namespace eval core {
    variable home [file dirname [file normalize [info script]]]
    variable libraryDir [file join [file dirname $home] lib]
    variable loadedLibraries {}
}

apply {{dir} {
    foreach file {
        errors value completion env ir type regex
        block native callable refine runtime evaluator
        primitives predicates strings lists programfile
    } {
        uplevel #0 [list source [file join $dir $file.tcl]]
    }
}} $core::home

# Loads the optional library lib/NAME.tcl once. Libraries register types and
# natives globally; root environments created afterwards include them.
proc core::loadLibrary {name} {
    variable libraryDir
    variable loadedLibraries
    if {![regexp {^[A-Za-z0-9_-]+$} $name]} {
        error "core::loadLibrary: invalid library name \"$name\""
    }
    if {$name in $loadedLibraries} {
        return
    }
    set path [file join $libraryDir $name.tcl]
    if {![file exists $path]} {
        error "core::loadLibrary: no library \"$name\" in $libraryDir"
    }
    uplevel #0 [list source $path]
    lappend loadedLibraries $name
    return
}

package provide core 0.1
