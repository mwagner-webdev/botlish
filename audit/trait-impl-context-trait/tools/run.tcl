# run.tcl -- the trait-implementation context-trait defect's reproducers
# (TRAIT-IMPLEMENTATION-CONTEXT-TRAIT-DEFECT.md): each variant in ../repro
# compiled and run through main.tcl on the backends it can run on, its
# outcome classified and compared with what the program should do.
#
#   tclsh9.0 audit/trait-impl-context-trait/tools/run.tcl ?-variants NAMES?
#
# Prints one line per variant and backend: `ok`, or `DEFECT` with the
# observed outcome. Exits 1 when any variant deviates from what it should
# do -- which, until the defect's milestone, the defect's variants do (the
# controls must always be `ok`). The program's own output (the variants
# that print) is not compared: the value is.
#
# The variants that print through std::linux::io run on the native backends
# only (the Tcl backends refuse a syscall's byte buffer at run time, as for
# every Linux I/O program); the others on all four. missing-context is a
# front-end judgment, checked on interp.

set here [file dirname [file normalize [info script]]]
set root [file normalize [file join $here .. .. ..]]
set repro [file normalize [file join $here .. repro]]

set native {cranelift-generic cranelift}
set all {interp compile cranelift-generic cranelift}

# variant backends should (value V | error CODE) kind (defect | control)
set variants [list \
    entry-io           $native {value 2}                defect \
    entry-user-trait   $all    {value 22}               defect \
    entry-indirect     $native {value 2}                defect \
    module-impl        $native {value 2}                defect \
    split-modules      $native {value 2}                defect \
    two-witnesses      $native {value 22}               defect \
    missing-context    interp  {error MISSING-CONTEXT}  defect \
    control-struct     $all    {value 22}               control \
    control-none       $all    {value 2}                control \
    control-direct     $native {value 2}                control \
    control-context-operation $all {value 111}          control]

set only {}
foreach {option value} $argv {
    switch -- $option {
        -variants { set only [split $value ", "] }
        default { error "run.tcl: unknown option $option" }
    }
}

# {value V} or {error CODE} of main.tcl's run of FILE on BACKEND: the first
# `value:` line; else the first error -- its lines up to the next `help:`,
# `error:` or `value:` line -- by the code its last line ends with in
# parentheses (the code's last word: MALFORMED, MISSING-CONTEXT), TCL-ERROR
# for a Tcl error with no code (the compiler itself failed), or its text.
proc outcome {backend file} {
    catch {exec [info nameofexecutable] [file join $::root main.tcl] -backend $backend $file 2>@1} output
    set lines [split $output \n]
    foreach line $lines {
        if {[regexp {^\s+value: (.*)$} $line -> v]} {
            return [list value $v]
        }
    }
    set block {}
    foreach line $lines {
        if {$block eq {}} {
            if {[regexp {error: (.*)$} $line -> text]} {
                lappend block $text
            }
        } elseif {[regexp {^\s+(help|error|value):} $line]} {
            break
        } else {
            lappend block $line
        }
    }
    if {$block eq {}} {
        return [list error "no outcome: [string range $output 0 120]"]
    }
    if {[regexp {\(([A-Z][A-Z0-9 -]*)\)\s*$} [lindex $block end] -> code]} {
        return [list error [lindex $code end]]
    }
    if {[regexp {^key "message" not known} [lindex $block 0]]} {
        return [list error TCL-ERROR]
    }
    return [list error [string range [lindex $block 0] 0 120]]
}

set deviations 0
foreach {name backends should kind} $variants {
    if {$only ne {} && $name ni $only} continue
    set file [file join $repro $name main.bot]
    foreach backend $backends {
        set got [outcome $backend $file]
        if {$got eq $should} {
            puts [format "%-26s %-18s ok" $name $backend]
        } else {
            incr deviations
            puts [format "%-26s %-18s DEFECT: should be %s, got %s%s" $name $backend \
                $should $got [expr {$kind eq "control" ? " (a CONTROL: a regression)" : ""}]]
        }
    }
}
puts "deviations $deviations"
exit [expr {$deviations > 0}]
