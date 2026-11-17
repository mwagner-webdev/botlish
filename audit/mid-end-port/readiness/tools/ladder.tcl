# ladder.tcl -- prints scale.tcl result files (audit/mid-end-port/tools/
# scale.tcl's records, one dict per line) as the readiness census's front-end
# table, beside the per-line cost and the growth from the previous size
# (PORTABILITY-MID-END-PORT-READINESS-CENSUS-1.md, section 9).
#
#   tclsh9.0 audit/mid-end-port/readiness/tools/ladder.tcl FILE...
foreach file $argv {
    puts "== [file tail $file]"
    puts [format "%6s %6s %8s %8s %8s %8s %8s %8s %8s %7s %7s %s" passes lines exprs front load check decide mono ms/line growth GiB outcome]
    set channel [open $file]; set lines [split [string trim [read $channel]] \n]; close $channel
    set prev ""
    foreach line $lines {
        set r $line
        set front [dict getdef $r frontend -]
        set growth ""
        if {$prev ne "" && $front ne "-"} {
            set growth [format "%.2fx/%.2fx" [expr {$front / [lindex $prev 0]}] [expr {double([dict get $r lines]) / [lindex $prev 1]}]]
        }
        puts [format "%6s %6s %8s %8s %8s %8s %8s %8s %8s %7s %7s %s" [dict get $r passes] [dict get $r lines] \
            [dict getdef $r exprs -] $front [dict getdef $r CollectAndLoad -] [dict getdef $r check -] \
            [dict getdef $r DecideMethodCalls -] [dict getdef $r monomorphize -] \
            [expr {$front eq "-" ? "-" : [format %.2f [expr {1000.0 * $front / [dict get $r lines]}]]}] $growth \
            [format %.2f [expr {[dict getdef $r frontendPeakKb 0] / 1048576.0}]] [lindex [dict get $r outcome] 0]]
        if {$front ne "-"} { set prev [list $front [dict get $r lines]] }
    }
}
