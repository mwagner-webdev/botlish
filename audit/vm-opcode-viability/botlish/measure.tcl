# measure.tcl -- native (Cranelift) best-of-5 run time of the Botlish
# versions of the two micro-benchmarks, through native::measure (one
# subprocess, compiled once, timed in-process; compilation excluded).
#
#   tclsh9.0 audit/vm-opcode-viability/botlish/measure.tcl \
#       audit/vm-opcode-viability/botlish/fib30.bot audit/vm-opcode-viability/botlish/loop.bot
set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
foreach f $argv {
    set hir [surface::readProgramFile $f -warnings off]
    lassign [native::measure $hir 5] lower compile best collections value
    puts "[file tail $f] value=$value best=[format %.1f [expr {$best / 1000.0}]] ms"
}
