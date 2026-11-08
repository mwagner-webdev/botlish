# equivalence.tcl -- does a checkout's front end build the same HIR as
# another's? (SEMANTIC-INSTANCE-SCALABILITY-MILESTONE-1.md, "Equivalence")
#
#   tclsh9.0 audit/semantic-instance-scalability/tools/equivalence.tcl ROOT FILE...
#
# Sources the compiler of checkout ROOT, compiles each FILE (the front end,
# warnings off, no cache) and prints one line per file:
#
#   FILE OUTCOME HIR SEMANTIC SNAPSHOTS
#
# OUTCOME is `ok` or the error code and the first line of the message; HIR is
# the CRC-32 and length of the checked HIR's text without its `semantic`
# table (ROOT's path and the working directory's mapped out), SEMANTIC those of the semantic table without the run's census
# counters (`requests`, `hits`, `walks`, `deferred`, `deep`, `trivial`,
# `declinedCount`: how the analysis got there, not what it found), and
# SNAPSHOTS the number of instances. Two checkouts that build the same
# program the same way print the same line; run it with each and diff.

set root [file normalize [lindex $argv 0]]
source [file join $root surface surface.tcl]
# The CRC-32 and length of TEXT, the checkout's own path and the working
# directory's mapped out (the standard library's files are named by the one,
# an application's modules by the other).
proc digest {text} {
    set text [string map [list $::root/ ROOT/ [pwd]/ ROOT/] $text]
    return [format %08x/%d [zlib crc32 [encoding convertto utf-8 $text]] [string length $text]]
}
foreach path [lrange $argv 1 end] {
    set shown $path
    if {[catch {surface::readProgramFile $path -warnings off -cache ""} hir options]} {
        set first [lindex [split $hir \n] 0]
        set first [string map [list [file dirname [file normalize $path]]/ ""] $first]
        puts "$shown error [lrange [dict get $options -errorcode] 0 3] [digest $first]"
        continue
    }
    set semantic [dict getdef $hir semantic {}]
    foreach k {requests hits walks deferred deep trivial declinedCount} {
        dict unset semantic $k
    }
    set instances [expr {[dict exists $semantic instances] ? [dict size [dict get $semantic instances]] : 0}]
    puts "$shown ok [digest [dict remove $hir semantic]] [digest $semantic] $instances"
}
