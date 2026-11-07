# native-profile.tcl -- where lowering to NIR spends its time, procedure by
# procedure (audit/mid-end-port/README.md, "The scale experiment"):
#
#   tclsh9.0 audit/mid-end-port/tools/native-profile.tcl FILE ?-specialize 0|1? ?-top N?
#
# Compiles FILE (front end, warnings off), wraps every hir::aot procedure,
# the specializer's views and the HIR accessors with timing.tcl, lowers the
# program to NIR (native::nir) and prints the N (default 15) procedures with
# the most exclusive time, with their calls. The wrappers cost about 2 us a
# call, which the accessors' figures include (millions of calls): read them
# as counts, the others as times.

set here [file dirname [file normalize [info script]]]
set checkout [file dirname [file dirname [file dirname $here]]]
set path [file normalize [lindex $argv 0]]
set options [dict create -specialize 0 -top 15]
foreach {option value} [lrange $argv 1 end] {
    if {![dict exists $options $option]} { error "native-profile.tcl: unknown option $option" }
    dict set options $option $value
}
source [file join $checkout surface surface.tcl]
source [file join $checkout compiler compiler.tcl]
source [file join $checkout native native.tcl]
source [file join $here timing.tcl]
set hir [surface::readProgramFile $path -warnings off -cache ""]
set procs [concat [lsort [info procs ::hir::aot::*]] {::hir::specialize::view ::hir::get ::hir::kind
    ::hir::node ::hir::binding ::hir::typeOf ::hir::bindingType ::hir::type}]
timing::wrap $procs
timing::reset
set t0 [clock microseconds]
native::nir $hir -specialize [dict get $options -specialize]
puts [format "%s: lowering to NIR (-specialize %s, wrapped) %.1f s" [file tail [file dirname $path]]/[file tail $path] \
    [dict get $options -specialize] [expr {([clock microseconds] - $t0) / 1e6}]]
set rows [lmap p $procs {list $p [timing::exclusiveSeconds $p] [timing::calls $p]}]
foreach row [lrange [lsort -real -decreasing -index 1 $rows] 0 [dict get $options -top]-1] {
    lassign $row p seconds calls
    puts [format "%8.2f s %9d  %s" $seconds $calls [string trimleft $p :]]
}
