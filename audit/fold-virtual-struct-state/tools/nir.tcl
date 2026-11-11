# nir.tcl -- writes the NIR text of a program (native::nir, nothing else)
# to a file, the input of tools/nir-sra.tcl and of `botlish-native run`
# (FOLD-VIRTUAL-STRUCT-STATE-CENSUS-1.md, section 16).
#
#   tclsh9.0 audit/fold-virtual-struct-state/tools/nir.tcl FILE.bot OUT.nir

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set env(LANG) C.utf8
set env(LC_ALL) C.utf8
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
core::useProgramRecursionLimit
lassign $argv path out
set hir [surface::readProgramFile $path -warnings off]
set ch [open $out w]
fconfigure $ch -encoding utf-8 -translation lf
puts -nonewline $ch [native::nir $hir]
close $ch
