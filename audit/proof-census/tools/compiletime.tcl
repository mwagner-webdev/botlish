# compiletime.tcl -- what the census's proof passes cost at compile time.
#
#   tclsh9.0 audit/proof-census/tools/compiletime.tcl PROGRAM.bot...
#
# Observation only. For each program: the whole front end
# (surface::readProgramFile, which runs hir::check -- types, declared
# contracts, the completion proof), then, on the resulting HIR, a second
# run of each proof pass alone: hir::errorsets::verify (the completion
# proof over every function body), hir::specialize::analyze and
# hir::range::analyze (the codegen-facing fixpoint, induction and
# recursive-result solver included). Median of 3, milliseconds.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]

proc Median {script} {
    set times {}
    for {set i 0} {$i < 3} {incr i} {
        lappend times [lindex [time {uplevel 1 $script}] 0]
    }
    return [format %.1f [expr {[lindex [lsort -integer $times] 1] / 1000.0}]]
}

puts [format "%-28s %10s %10s %10s %10s" program frontend errorsets specialize range]
foreach path $argv {
    set front [Median {set hir [surface::readProgramFile $path -warnings off]}]
    set es [Median {set h $hir; hir::errorsets::verify h}]
    set prepared [native::prepareHir $hir]
    set sp [Median {set spec [hir::specialize::analyze $prepared]}]
    set rg [Median {set ranges [hir::range::analyze $prepared $spec]}]
    puts [format "%-28s %10s %10s %10s %10s" [file tail $path] $front $es $sp $rg]
}
