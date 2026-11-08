# blockname-share.tcl -- the share of hir::aot::BlockName in lowering to NIR
# (audit/mid-end-port/README.md, "The scale experiment"):
#
#   tclsh9.0 audit/mid-end-port/tools/blockname-share.tcl ROOT SPECIALIZE FILE...
#
# Sources the compiler of the checkout ROOT (a worktree of another commit,
# to measure before or after a change), wraps only hir::aot::BlockName,
# hir::aot::analyzeRegion and hir::specialize::analyze (a few thousand calls:
# the wrappers cost nothing measurable), and for each program prints its
# front end's time, its lowering's (native::nir -specialize SPECIALIZE), and
# BlockName's inclusive time, share and calls. A ROOT whose lowering no
# longer calls BlockName reports 0 calls.

set here [file dirname [file normalize [info script]]]
set root [file normalize [lindex $argv 0]]
set spec [lindex $argv 1]
source [file join $root surface surface.tcl]
source [file join $root compiler compiler.tcl]
source [file join $root native native.tcl]
source [file join $here timing.tcl]
set wrapped {}
foreach p {::hir::aot::BlockName ::hir::aot::analyzeRegion ::hir::specialize::analyze} {
    if {[info procs $p] ne ""} { lappend wrapped $p }
}
timing::wrap $wrapped
foreach path [lrange $argv 2 end] {
    set t0 [clock microseconds]
    set hir [surface::readProgramFile $path -warnings off -cache ""]
    set front [expr {([clock microseconds] - $t0) / 1e6}]
    timing::reset
    set t0 [clock microseconds]
    native::nir $hir -specialize $spec
    set lower [expr {([clock microseconds] - $t0) / 1e6}]
    set b [timing::seconds ::hir::aot::BlockName]
    puts [format "%-24s -specialize %s  front end %6.1f s  lowering %6.1f s  BlockName %6.1f s (%5.1f%% of lowering, %5.1f%% of front end + lowering; %d calls)" \
        [file tail [file dirname $path]]/[file tail $path] $spec $front $lower $b [expr {100.0 * $b / $lower}] \
        [expr {100.0 * $b / ($front + $lower)}] [timing::calls ::hir::aot::BlockName]]
}
