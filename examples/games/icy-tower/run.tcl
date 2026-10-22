# run.tcl -- runs the Icy Tower vertical slice's pure programs
# (ICY-TOWER-VERTICAL-SLICE-1.md) on the Tcl and native backends.
#
#   tclsh9.0 examples/games/icy-tower/run.tcl ?-backend B? ?-warnings W? FILE.bot ...
#   tclsh9.0 examples/games/icy-tower/run.tcl -suite ?-backends LIST?
#
# FILE.bot (headless.bot, or a program of your own beside the modules) is
# compiled once (warnings off unless -warnings says otherwise) and run on
# backend B (interp, compile, cranelift, cranelift-generic; default
# interp); its value is printed. -suite runs golden.bot on every backend of
# LIST (default all four) with tests/golden/run.tcl's runner and prints its
# report; the exit status is 1 if a test failed, the backends disagreed or
# a program did not compile or run.
#
# The modules are application modules, the files beside the programs
# (IMPORTS.md). main.bot, sdl.bot and render.bot import the generated SDL3
# binding, which is not beside them: build.sh stages them with it and
# builds the executable. Everything this script runs needs no SDL.
#
# Other scripts source this file for icytower::compile and icytower::run.

namespace eval icytower {
    variable here [file dirname [file normalize [info script]]]
    variable root [file dirname [file dirname [file dirname $here]]]
}
source [file join $::icytower::root tests golden run.tcl]

# Compiles FILE (its application modules beside it): the HIR, or an error.
proc icytower::compile {file {warnings off}} {
    return [surface::readProgramFile $file -warnings $warnings]
}

# Runs HIR on BACKEND and returns the program's value.
proc icytower::run {hir backend} {
    switch -- $backend {
        cranelift { return [native::evalHir $hir] }
        cranelift-generic { return [native::evalHir $hir -specialize 0] }
        compile { return [core::compiler::evalHir $hir] }
        interp {
            set saved [core::useBackend]
            core::useBackend interp
            try {
                core::useProgramRecursionLimit
                return [core::evalProgram [hir::lower $hir]]
            } finally {
                core::useBackend $saved
            }
        }
        default { error "unknown backend $backend" }
    }
}

proc icytower::main {argv} {
    variable here
    set backend interp
    set backends {interp compile cranelift-generic cranelift}
    set warnings off
    set suite 0
    set files {}
    for {set i 0} {$i < [llength $argv]} {incr i} {
        set arg [lindex $argv $i]
        switch -- $arg {
            -backend { set backend [lindex $argv [incr i]] }
            -backends { set backends [split [lindex $argv [incr i]] ,] }
            -warnings { set warnings [lindex $argv [incr i]] }
            -suite { set suite 1 }
            default { lappend files $arg }
        }
    }
    if {$suite} {
        return [golden::main [list -backends [join $backends ,] [file join $here golden.bot]]]
    }
    foreach file $files {
        if {[catch {compile $file $warnings} hir options]} {
            puts stderr "$file: $hir ([dict get $options -errorcode])"
            return 1
        }
        if {[catch {run $hir $backend} value options]} {
            puts stderr "$file: $value ([dict get $options -errorcode])"
            return 1
        }
        puts [core::value::show $value 1]
    }
    return 0
}

if {[info script] eq $::argv0} {
    exit [icytower::main $argv]
}
