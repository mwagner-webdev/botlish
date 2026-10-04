# values.tcl -- each program's outcome on every backend, for
# PROOF-FACT-CENSUS.md.
#
#   tclsh9.0 audit/proof-census/tools/values.tcl ?-root DIR? PROGRAM.bot...
#
# Observation only. Compiles each program twice: as main.tcl does (strict,
# the default: a static rejection is the outcome), and with -strict 0 (the
# program runs even when the completion proof rejects it, so a rejected
# program's run-time behavior is visible). Each compilation runs on interp,
# compile, cranelift (specialized) and cranelift-generic (-specialize 0).
# -root DIR loads the compiler from another checkout (the same tool against
# the parent commit's compiler gives the "before" column).

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
if {[lindex $argv 0] eq "-root"} {
    set root [file normalize [lindex $argv 1]]
    set argv [lrange $argv 2 end]
}
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]

proc Outcome {backend hir} {
    if {[catch {
        switch -- $backend {
            interp { set v [core::evalProgram [hir::lower $hir]] }
            compile { set v [core::compiler::evalHir $hir] }
            cranelift { set v [native::evalHir $hir] }
            cranelift-generic { set v [native::evalHir $hir -specialize 0] }
        }
    } message options]} {
        return "error [lindex [dict get $options -errorcode] end]: [string range $message 0 80]"
    }
    set shown [core::value::show $v 1]
    if {[string length $shown] > 160} {
        set shown "[string range $shown 0 159]... ([string length $shown] chars)"
    }
    return $shown
}

foreach path $argv {
    puts "=== [file tail $path]"
    foreach strict {1 0} {
        if {[catch {surface::readProgramFile $path -strict $strict -warnings off} hir options]} {
            puts "  strict $strict: rejected [lindex [dict get $options -errorcode] end]"
            continue
        }
        set outcomes [lmap b {interp compile cranelift cranelift-generic} {Outcome $b $hir}]
        if {[llength [lsort -unique $outcomes]] == 1} {
            puts "  strict $strict: all backends: [lindex $outcomes 0]"
        } else {
            foreach b {interp compile cranelift cranelift-generic} o $outcomes {
                puts "  strict $strict: $b: $o"
            }
        }
    }
}
