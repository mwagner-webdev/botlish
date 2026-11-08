# table.tcl -- the scale experiment's results as Markdown tables
# (audit/mid-end-port/README.md, "The scale experiment"):
#
#   tclsh9.0 audit/mid-end-port/tools/table.tcl FILE...
#
# Reads scale.tcl's result files (a dict per line) and prints one table of
# the front end and one of the native path, a row per size, in file order.

proc mb {kb} { expr {$kb eq "" ? "-" : [format %.2f [expr {$kb / 1048576.0}]]} }
proc get {record key {default -}} { dict getdef $record $key $default }
proc outcome {record} {
    set o [get $record outcome]
    switch -- [lindex $o 0] {
        ok { return ok }
        failed { return "rejected: [lindex [lindex $o 1] end]" }
        timeout { return "timeout after [lindex $o 3]" }
        crashed { return "died after [lindex $o 2] ([lindex $o 3])" }
    }
    return $o
}
set records {}
foreach file $argv {
    set channel [open $file]
    foreach line [split [read $channel] \n] {
        if {[string trim $line] ne ""} { lappend records $line }
    }
    close $channel
}
puts "| passes | generic helper | lines | functions | front end s | builds | peak GiB | semantic instances (most of one function) | outcome |"
puts "|---:|---|---:|---:|---:|---:|---:|---|---|"
foreach r $records {
    set sem [expr {[dict exists $r semanticInstances] ? "[get $r semanticInstances] ([get $r semanticMaxPerBlock])" : "-"}]
    puts "| [get $r passes] | [expr {[get $r generic] ? "yes" : "no"}] | [get $r lines] | [get $r functions] | [get $r frontend] | [get $r builds] | [mb [get $r frontendPeakKb {}]] | $sem | [outcome $r] |"
}
puts ""
puts "| passes | generic helper | specialize | lines | lower to NIR s | of which specializer's analysis s | views s (calls) | block escape s | range s | Cranelift and link s | specialized instances (most of one function) | peak GiB | native |"
puts "|---:|---|---|---:|---:|---:|---:|---:|---:|---:|---|---:|---|"
foreach r $records {
    set died [expr {[lindex [get $r outcome] 0] eq "crashed" && [lindex [get $r outcome] 2] eq "frontend"}]
    if {![dict exists $r native] && ![dict exists $r lower] && !$died} continue
    set phases [get $r nativePhases {}]
    proc phase {phases name} {
        if {![dict exists $phases $name]} { return - }
        lassign [dict get $phases $name] s n
        return $s
    }
    set views "-"
    if {[dict exists $phases specialize::view]} {
        lassign [dict get $phases specialize::view] s n
        set views "$s ($n)"
    }
    set native [get $r native]
    if {[lindex $native 0] eq "failed"} { set native "failed: [lindex $native 1]" }
    if {$died} { set native "died in the native path ([lindex [get $r outcome] 3])" }
    puts "| [get $r passes] | [expr {[get $r generic] ? "yes" : "no"}] | [expr {[get $r specializeOption 1] ? "yes" : "no"}] | [get $r lines] | [get $r lower] | [phase $phases specialize::analyze] | $views | [phase $phases blockescape::analyze] | [phase $phases range::analyze] | [get $r cranelift] | [get $r specSpecialized] ([get $r specMaxPerFunction]) | [mb [get $r peakKb {}]] | $native |"
}
