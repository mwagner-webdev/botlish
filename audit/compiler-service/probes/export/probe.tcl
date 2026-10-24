# probe.tcl -- drives the exported-function probe from Tcl (run.sh), through
# the Botlish native library bj (NATIVE-LIBRARY-MILESTONE-1.md).
#
#   tclsh9.0 probe.tcl LIBRARY ?CALLS?
#
# CALLS (default 20000) is the number of timed token_count calls.
load [lindex $argv 0] Bjprobe
set calls [expr {[llength $argv] > 1 ? [lindex $argv 1] : 20000}]
proc rss {} {
    set ch [open /proc/self/status]; set t [read $ch]; close $ch
    regexp {VmRSS:\s+(\d+)} $t -> kb
    return [expr {$kb / 1024}]
}
proc utf8 {text} { encoding convertto utf-8 $text }
proc failure {script} {
    set rc [catch {uplevel 1 $script} message options]
    if {!$rc} { return "no error: $message" }
    return "[dict get $options -errorcode] -- $message"
}
set message [utf8 {{"jsonrpc": "2.0", "id": 17, "method": "textDocument/hover", "params": {"textDocument": {"uri": "file:///a/café.bot"}, "position": {"line": 3, "character": 14}}, "numbers": [0, -1, 2.5, 1e10]}}]
puts "token_count(message): [bj::token_count $message]"
foreach s {{[1, 2]} {[1, 2, 3]} {[1, 2, 3, 4, 5, 6]} {"abcdefghij"} {[true, false, null]} {"ä😀"}} {
    puts "token_count($s): [bj::token_count [utf8 $s]]"
}
set long "\[[join [lrepeat 500 {"x", 12.5e-3, true}] {, }]\]"
puts "token_count(long, [string length $long] characters): [bj::token_count [utf8 $long]]"
puts "token_count(malformed at 6): [failure {bj::token_count [utf8 {{"a": tru}}]}]"
puts "token_count(raw newline in a string): [failure {bj::token_count [utf8 "\[\"a\nb\"\]"]}]"
puts "token_count(invalid UTF-8): [failure {bj::token_count \xff\xfe}]"
puts "token_table(\[true, \"é\"\]): [string map {\n |} [encoding convertfrom utf-8 [bj::token_table [utf8 {[true, "é"]}]]]]"
puts "shout(café): [encoding convertfrom utf-8 [bj::shout [utf8 café]]]"
puts "shout(empty): \"[bj::shout {}]\""
puts "shout(a NUL inside): [string length [bj::shout "a\x00b"]] bytes"
puts "checked(21): [bj::checked 21]"
puts "checked(-5): [failure {bj::checked -5}]"
puts "checked(2**62): [failure {bj::checked [expr {2**62}]}]"
puts "sample(): [bj::sample]"
puts "churn(100000): [bj::churn 100000]"
set before [rss]
set t [clock microseconds]
for {set i 0} {$i < $calls} {incr i} { bj::token_count $message }
set per [expr {([clock microseconds] - $t) / double($calls)}]
puts [format "%d x token_count(%d bytes): %.1f us per call; rss %d -> %d MiB" $calls [string length $message] $per $before [rss]]
set before [rss]
for {set i 0} {$i < 200} {incr i} { bj::churn 10000 }
puts "200 x churn(10000): rss $before -> [rss] MiB"
set kept [bj::shout [utf8 kept]]
set error [failure {bj::checked -7}]
bj::churn 100000
puts "a result kept across a collecting call: [encoding convertfrom utf-8 $kept]"
puts "an error kept across a collecting call: $error"
bj::reset
puts "after destroy and create: token_count(\[1, 2\]) = [bj::token_count [utf8 {[1, 2]}]], checked(3) = [bj::checked 3]"
