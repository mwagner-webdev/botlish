#!/usr/bin/env tclsh9.0
# emit-nir.tcl -- the NIR text native::nir lowers PROGRAM to with
# hir::range::resultNarrowOpt set to OPT (GENERIC-PREDICATE-PROOF-LOSS.md,
# fix 3): 0 skips Fixpoint's result-narrowing pass (the call-site callee
# summaries stay the ascending phase's widened ones), 1 is the default.
# Default native lowering options otherwise; observation only. The compiler
# tree is the one in the CURRENT DIRECTORY (run from the repository root).
#
#   tclsh9.0 audit/generic-predicate-proof-loss/tools/emit-nir.tcl OPT PROGRAM.{bot,ir} OUTFILE
#
# The written file is what audit/post-r2a-dynamic-census/tools/profile-nir.sh
# (and `botlish-native bench|clif|size ... FILE`) takes directly. A .ir
# program is read into HIR the way native/explain-native.tcl does.
if {[llength $argv] != 3 || [lindex $argv 0] ni {0 1}} {
    puts stderr "usage: tclsh9.0 emit-nir.tcl 0|1 PROGRAM.{bot,ir} OUTFILE"
    exit 2
}
lassign $argv opt path outfile
set root [pwd]
set argv {}
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000
set hir::range::resultNarrowOpt $opt
if {[file extension $path] eq ".bot"} {
    set hir [surface::readProgramFile $path]
} else {
    set hir [hir::build [core::loadProgramFile $path] -strict 0]
}
set text [native::nir $hir]
set f [open $outfile w]
fconfigure $f -encoding utf-8 -translation lf
puts -nonewline $f $text
close $f
