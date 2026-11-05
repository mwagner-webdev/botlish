# corpus.tcl -- the full parity corpus: every migrated analysis's answer
# against the old recursive walk it replaced, on corpus.bot's declarations
# applied to the full argument pool (PARAMETERIZED-DECLARATION-SUMMARIES-
# MILESTONE-1.md, "Parity").
#
#   tclsh9.0 audit/declaration-summaries/tools/corpus.tcl ?-budget N? ?-size full|small?
#
# Prints every verdict other than `same` (tools/parity.tcl's) and the
# counts; exit status 1 on a DIFFERENT verdict. The old walks are stopped
# after -budget field reads (default 5000): `diverges`.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set ::argv0 corpus
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root audit declaration-summaries tools parity.tcl]

array set opt {-budget 5000 -size full}
array set opt $argv
set ::reference::budget $opt(-budget)

set hir [parity::CorpusHir]
set types [parity::Corpus $opt(-size)]
puts "[llength $types] types, [llength $parity::analyses] analyses"
set counts [dict create]
set start [clock milliseconds]
foreach t $types {
    foreach row [parity::Compare $hir $t] {
        lassign $row analysis new old exact verdict
        dict incr counts $verdict
        if {$verdict ne "same"} {
            puts "$verdict $analysis [hir::types::show $t]"
            if {$verdict ne "diverges"} {
                puts "   new=[string range $new 0 300]\n   old=[string range $old 0 300]\n   exact=[string range $exact 0 300]"
            }
        }
    }
}
puts "verdicts: $counts"
puts "[expr {[clock milliseconds] - $start}] ms"
exit [expr {[dict exists $counts DIFFERENT]}]
