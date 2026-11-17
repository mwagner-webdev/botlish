# native-phases.tcl -- where lowering to NIR spends its time, analysis by
# analysis (PORTABILITY-MID-END-PORT-READINESS-CENSUS-1.md, section 12):
# measure.tcl's native phases name twelve analyses, and at 25,736 lines
# more than half of unspecialized lowering is outside them. This wraps
# every analysis entry point of ::hir and ::native (each procedure whose
# name is analyze, plan, summary, facts, verify or context, and native
# lowering's program) with timing.tcl and prints their exclusive seconds.
#
#   tclsh9.0 audit/mid-end-port/readiness/tools/native-phases.tcl FILE ?-specialize 0|1? ?-top 20?
#       ?-namespaces "::native::lower ..."?
#
# -namespaces wraps every procedure of the namespaces named instead (their
# exclusive times then locate the work inside one entry point; a wrapper
# costs about 2 us a call, so read a hot procedure's figure as a count).
set here [file dirname [file normalize [info script]]]
set checkout [file dirname [file dirname [file dirname [file dirname $here]]]]
set path [file normalize [lindex $argv 0]]
set options [dict create -specialize 0 -top 20 -namespaces ""]
foreach {option value} [lrange $argv 1 end] { dict set options $option $value }
source [file join $checkout surface surface.tcl]
source [file join $checkout compiler compiler.tcl]
source [file join $checkout native native.tcl]
source [file join $checkout audit mid-end-port tools timing.tcl]
set hir [surface::readProgramFile $path -warnings off -cache ""]
proc allNamespaces {ns} {
    set result [list $ns]
    foreach child [namespace children $ns] { lappend result {*}[allNamespaces $child] }
    return $result
}
set procs {}
foreach root {::hir ::native} {
    foreach ns [allNamespaces $root] {
        foreach p [info procs ${ns}::*] {
            if {[namespace tail $p] in {analyze plan summary facts context program lowered nir}} {
                lappend procs [namespace which -command $p]
            }
        }
    }
}
if {[dict get $options -namespaces] ne ""} {
    set procs {}
    foreach ns [dict get $options -namespaces] {
        foreach p [info procs ${ns}::*] { lappend procs [namespace which -command $p] }
    }
}
set procs [lsort -unique $procs]
timing::wrap $procs
timing::reset
set t0 [clock microseconds]
native::nir $hir -specialize [dict get $options -specialize]
set total [expr {([clock microseconds] - $t0) / 1e6}]
puts [format "%s: lowering to NIR (-specialize %s, %d entry points wrapped) %.1f s" $path [dict get $options -specialize] [llength $procs] $total]
set rows [lmap p $procs {list $p [timing::exclusiveSeconds $p] [timing::calls $p] [timing::seconds $p]}]
foreach row [lrange [lsort -real -decreasing -index 1 $rows] 0 [dict get $options -top]-1] {
    lassign $row p seconds calls inclusive
    puts [format "%8.2f s excl %8.2f s incl %7d  %s" $seconds $inclusive $calls [string trimleft $p :]]
}
