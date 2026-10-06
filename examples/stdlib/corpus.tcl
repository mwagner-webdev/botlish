# corpus.tcl -- running the Botlish algorithm corpus (examples/stdlib/*.bot).
#
#   source examples/stdlib/corpus.tcl       ;# also loads compiler, hir, core, surface
#
#   corpus::names                           the corpus programs (file root names)
#   corpus::text NAME                       a program's source text
#   corpus::program NAME DRIVER             HIR of the program followed by the
#                                           source statement(s) DRIVER, whose
#                                           value is the program's value
#   corpus::handled DRIVER ?ERRORS?         DRIVER with its builtin declared
#                                           errors handled (each the String
#                                           naming it)
#   corpus::driven NAME DRIVER              corpus::program, handling DRIVER's
#                                           builtin errors only if it needs it
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
    variable genericStandIns 0
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

# The HIR of the program TEXT (named FILENAME in every origin), with each
# module its imports (`import mutable_array`) name loaded and compiled
# alongside it: surface::modules::compileProgramFile's own steps over text
# instead of a file (a corpus program is a definitions-only prefix plus a
# driver). -strict and -warnings as surface::compile's.
proc corpus::compile {source filename args} {
    set strict 1
    set warnings ""
    foreach {option value} $args {
        switch -- $option {
            -strict   { set strict $value }
            -warnings { set warnings $value }
            default   { error "corpus::compile: unknown option \"$option\"" }
        }
    }
    # A corpus program is a program file plus a driver assembled here: the
    # driver's own dependencies (a `list::length(...)` in it) are declared
    # exactly, like the file's own header (IMPORTS.md).
    set source [surface::modules::ImportHeader $source]$source
    set ast [surface::parse $source $filename]
    set hir [surface::modules::BuildProgram $ast 0]
    return [surface::lower::Finish $hir $strict $warnings]
}

# DRIVER (top-level Botlish statements) as the body of a function whose
# builtin declared errors ERRORS -- list::at/mutable_array::at/set's
# IndexNotFound and the slices' LowerUnderrun/UpperOverrun, which the corpus
# functions declare where they index positional records or slice text they
# cannot prove in range (STDLIB-NAMESPACES.md) -- are handled at top level by
# becoming the String naming the error: the one place a test's driver
# states what a malformed input means, instead of every case repeating a
# handler. The function's declared `-> any` result is what makes that
# String admissible beside whatever the driver computes. Any other outcome
# is the driver's own.
proc corpus::handled {driver {errors IndexNotFound}} {
    set body [join [lmap line [split $driver \n] {string cat "    " $line}] \n]
    set handlers [join [lmap e $errors {string cat "    on $e:\n        \"$e\""}] \n]
    return "fn corpus_case() -> any errors [join $errors {, }]:\n$body\ncorpus_outcome = corpus_case():\n$handlers\ncorpus_outcome"
}

# corpus::program NAME DRIVER, or -- when DRIVER leaves builtin declared
# errors unhandled at top level (and only then) -- of corpus::handled DRIVER
# for exactly those errors (the compiler names one per rejection, so the
# set grows until the driver compiles).
proc corpus::driven {name driver args} {
    set errors {}
    while 1 {
        set text [expr {$errors eq {} ? $driver : [handled $driver $errors]}]
        if {![catch {program $name $text {*}$args} hir options]} {
            return $hir
        }
        if {[dict get $options -errorcode] ne {CORE SEMANTIC UNHANDLED-ERROR}
                || ![regexp {declared error "(IndexNotFound|LowerUnderrun|UpperOverrun)"} $hir -> error]
                || $error in $errors} {
            return -options $options $hir
        }
        lappend errors $error
    }
}

proc corpus::program {name driver args} {
    return [compile "[text $name]\n$driver\n" [path $name] {*}$args]
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
            # cranelift-generic has no slot for a struct projection that only
            # a semantic instance proves: the baseline is undefined for such
            # a program and cranelift stands in (tests/helpers.tcl, outcomeUnder).
            if {$backend eq "cranelift-generic" && [dict get $options -errorcode] eq "NATIVE UNSUPPORTED struct-shape"} {
                variable genericStandIns
                incr genericStandIns
                return [outcome cranelift $hir]
            }
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
