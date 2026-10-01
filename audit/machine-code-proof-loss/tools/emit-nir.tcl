#!/usr/bin/env tclsh9.0
# emit-nir.tcl -- the NIR text bench/bench.tcl's Cranelift column runs for a
# program, emitted by the tree in the CURRENT DIRECTORY (so one script serves
# the frozen tree and any historical worktree). Observation only.
#
#   (cd TREE && tclsh9.0 .../emit-nir.tcl PROGRAM.bot|PROGRAM.ir ?NIR-OPTIONS?) > OUT.nir
#
# .bot: surface::readProgramFile, exactly like bench.tcl and
# native/generate-scalar-audit.tcl. .ir: the post-R2.a census's own route
# (core::loadLibrary web; hir::build -strict 0), for comparability with the
# historical refined-checks.ir profiles. Both then call native::nir, the one
# HIR->NIR entry point the JIT, the object writer and native::measure share.
set root [pwd]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000
set path [lindex $argv 0]
if {[file extension $path] eq ".bot"} {
    set hir [surface::readProgramFile $path]
} else {
    core::loadLibrary web
    set hir [hir::build [core::loadProgramFile $path] -strict 0]
}
fconfigure stdout -encoding utf-8 -translation lf
puts -nonewline [native::nir $hir {*}[lrange $argv 1 end]]
