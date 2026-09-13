# corpus.tcl -- running the Botlish algorithm corpus (examples/stdlib/*.bot).
#
#   source examples/stdlib/corpus.tcl       ;# also loads compiler, hir, core, surface
#
#   corpus::names                           the corpus programs (file root names)
#   corpus::text NAME                       a program's source text
#   corpus::program NAME DRIVER             HIR of the program followed by the
#                                           source statement(s) DRIVER, whose
#                                           value is the program's value
#   corpus::run BACKEND HIR                 runs HIR; returns the runtime value
#   corpus::outcome BACKEND HIR             {value SHOWN} or {error ERRORCODE}
#   corpus::literal TEXT                    TEXT as a Botlish string literal
#
# The programs are ordinary source files: definitions followed by a sample
# expression. A driver is appended after the sample, so the functions are
# used exactly as written, without a module system.
#
# Backends run a program the way examples/surface programs run:
#
#   interp     HIR --hir::lower--> core IR --> core::evalProgram
#   compile    HIR --> core::compiler::evalHir
#   cranelift  HIR --> native::evalHir (native lowering with function
#              specialization, Cranelift JIT)
#   cranelift-generic
#              the same without specialization: generic, guarded functions
#
# Adding a backend means adding a case to run.

if {[info commands ::core::compiler::evalHir] eq ""} {
    source [file join [file dirname [file dirname [file dirname [file normalize [info script]]]]] compiler compiler.tcl]
}
if {[info commands ::surface::compile] eq ""} {
    source [file join [file dirname [file dirname [file dirname [file normalize [info script]]]]] surface surface.tcl]
}
if {[info commands ::native::evalHir] eq ""} {
    source [file join [file dirname [file dirname [file dirname [file normalize [info script]]]]] native native.tcl]
}

namespace eval corpus {
    variable home [file dirname [file normalize [info script]]]
    variable backends {interp compile cranelift-generic cranelift}
}

# The corpus programs recurse once per character, element or record: Botlish
# has no mutable loop state, and the interpreter does not eliminate tail
# calls.
interp recursionlimit {} 1000000

proc corpus::names {} {
    variable home
    return [lmap path [lsort [glob -directory $home *.bot]] {file rootname [file tail $path]}]
}

proc corpus::path {name} {
    variable home
    return [file join $home $name.bot]
}

proc corpus::text {name} {
    return [core::ReadFile [path $name]]
}

proc corpus::program {name driver args} {
    return [surface::compile "[text $name]\n$driver\n" [path $name] {*}$args]
}

proc corpus::run {backend hir} {
    switch -- $backend {
        interp  { return [core::evalProgram [hir::lower $hir]] }
        compile { return [core::compiler::evalHir $hir] }
        cranelift { return [native::evalHir $hir -specialize 1] }
        cranelift-generic { return [native::evalHir $hir -specialize 0] }
    }
    error "corpus::run: unknown backend \"$backend\""
}

proc corpus::outcome {backend hir} {
    set saved [core::useBackend]
    core::useBackend $backend
    try {
        if {[catch {run $backend $hir} value options]} {
            return [list error [dict get $options -errorcode]]
        }
        return [list value [core::value::show $value 1]]
    } finally {
        core::useBackend $saved
    }
}

proc corpus::literal {text} {
    return "\"[string map {\\ \\\\ \" \\\" \n \\n \r \\r \t \\t} $text]\""
}
