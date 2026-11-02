# stage.tcl -- shared by measure.tcl and executable.tcl: compiles a
# benchmark program the way bench/bench.tcl does.
#
# A program whose header names modules ("# bench-modules: PATH ...",
# repository-relative) is compiled from a private directory holding the
# program, those modules and then every other .bot file of the program's own
# directory, which replaces a listed module of the same name: a variant
# directory carries only the modules it changes (variants/game-server-
# continue/simdrv.bot).

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
core::useProgramRecursionLimit

proc bimodality::modules {path} {
    set modules {}
    foreach line [split [core::ReadFile $path] \n] {
        if {![string match "#*" $line]} {
            break
        }
        if {[regexp {^#\s*bench-modules:\s*(.*)$} $line -> paths]} {
            lappend modules {*}$paths
        }
    }
    return $modules
}

# Runs SCRIPT (in the caller's frame) with the variable named HIRVAR set to
# PATH's HIR, compiled from a private staging directory when PATH names
# modules; the directory is removed afterwards.
proc bimodality::withHir {path hirVar script} {
    global root
    upvar 1 $hirVar hir
    set modules [modules $path]
    if {![llength $modules]} {
        set hir [surface::readProgramFile $path -warnings off]
        return [uplevel 1 $script]
    }
    set dir [file tempdir bimodality]
    try {
        foreach module $modules {
            file copy [file join $root $module] [file join $dir [file tail $module]]
        }
        foreach sibling [glob -nocomplain -directory [file dirname $path] -types f *.bot] {
            file copy -force $sibling [file join $dir [file tail $sibling]]
        }
        set hir [surface::readProgramFile [file join $dir [file tail $path]] -warnings off]
        return [uplevel 1 $script]
    } finally {
        file delete -force $dir
    }
}
