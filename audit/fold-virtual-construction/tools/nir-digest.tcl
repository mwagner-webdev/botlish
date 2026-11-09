# nir-digest.tcl -- FOLD-VIRTUAL-LIST-CONSTRUCTION-MILESTONE-1.md's
# "nothing else moved" evidence: the SHA-256 of each program's NIR (the
# specialized native lowering's text, every option at its default) and its
# number of plan folds, so the digests of two checkouts can be compared
# (diff the two outputs): a program with no plan fold must lower to
# byte-identical NIR.
#
#   tclsh9.0 audit/fold-virtual-construction/tools/nir-digest.tcl ?-root DIR? FILE.bot ...

set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
set files {}
for {set i 0} {$i < [llength $argv]} {incr i} {
    set arg [lindex $argv $i]
    if {$arg eq "-root"} {
        set root [file normalize [lindex $argv [incr i]]]
    } else {
        lappend files [file normalize $arg]
    }
}
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
core::useProgramRecursionLimit

foreach path $files {
    set label [file join [file tail [file dirname $path]] [file tail $path]]
    if {[catch {
        set hir [surface::readProgramFile $path -warnings off]
        set lowered [native::lower::program $hir]
        set plans 0
        set analysis [dict get $lowered construction]
        if {[dict exists $analysis folds]} {
            dict for {id fs} [dict get $analysis folds] { incr plans [dict size $fs] }
        }
        set channel [open "|sha256sum" r+]
        fconfigure $channel -encoding utf-8 -translation lf
        puts -nonewline $channel [dict get $lowered text]
        chan close $channel write
        set digest [lindex [read $channel] 0]
        close $channel
        puts [format "%-56s %s plan-folds=%s" $label [string range $digest 0 15] $plans]
    } message]} {
        puts [format "%-56s ERROR %s" $label [lindex [split $message \n] 0]]
    }
}
