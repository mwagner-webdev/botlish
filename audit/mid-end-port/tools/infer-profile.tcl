# infer-profile.tcl -- exclusive time of the front end's type-inference
# procedures, for one program (audit/mid-end-port/README.md, "The scale
# experiment"):
#
#   tclsh9.0 audit/mid-end-port/tools/infer-profile.tcl ROOT FILE PROCS-FILE
#
# Sources the compiler of checkout ROOT and wraps (timing.tcl) every
# procedure PROCS-FILE lists -- or, with PROCS-FILE "", every procedure of the
# namespaces below, whose wrappers then cost more than the procedures (use it
# for the call counts, on a small program, to choose PROCS-FILE: the
# procedures called at most a few ten thousand times) -- plus
# hir::signatures::infer. Prints the front end's time (wrapped) and each
# procedure's exclusive seconds and calls, largest first.
lassign $argv root path procsFile
source [file join $root surface surface.tcl]
source [file join [file dirname [file normalize [info script]]] timing.tcl]
set namespaces {::hir::types ::hir::semantic ::hir::signatures ::hir::imprint ::hir::callables ::hir::range ::hir::cardinality ::hir::specialize ::hir::traits}
if {$procsFile eq ""} {
    set procs {}
    foreach ns $namespaces { lappend procs {*}[info procs ${ns}::*] }
} else {
    set channel [open $procsFile]; set procs [read $channel]; close $channel
}
set procs [lsort -unique [lmap p $procs {expr {[string match ::* $p] ? $p : "::$p"}}]]
lappend procs ::hir::signatures::infer
set procs [lsort -unique $procs]
timing::wrap $procs
set scratch [file tempdir infer-profile]
set warm [file join $scratch warm.bot]
set channel [open $warm w]; puts $channel 1; close $channel
surface::readProgramFile $warm -warnings off -cache ""
file delete -force $scratch
timing::reset
set t0 [clock microseconds]
surface::readProgramFile $path -warnings off -cache ""
set all [expr {([clock microseconds] - $t0) / 1e6}]
puts [format "%s: front end %.1f s (wrapped), hir::signatures::infer inclusive %.1f s" $path $all [timing::seconds ::hir::signatures::infer]]
set rows [lmap p $procs {list $p [timing::exclusiveSeconds $p] [timing::calls $p]}]
foreach row [lsort -real -decreasing -index 1 $rows] {
    lassign $row p seconds calls
    if {$calls == 0} continue
    puts [format "%8.2f s %10d  %s" $seconds $calls [string trimleft $p :]]
}
