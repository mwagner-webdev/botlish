set root [pwd]
source [file join $root examples stdlib corpus.tcl]
interp recursionlimit {} 100000
set hir [corpus::program [lindex $argv 0] "list_length(sample())"]
set text [dict get [native::lower::program $hir] text]
set fn ""
foreach line [split $text \n] {
    if {[regexp {^func \d+ "([^"]+)" params=(\d+).*instance="([^"]*)"} $line -> name p inst]} { set fn "$name<$inst>/p$p" }
    if {[regexp {^\s+guard(bool)? (.*)$} $line -> b rest]} { puts "$fn: guard$b $rest" }
}
