# probe.tcl -- drives the exported-function probe from Tcl (run.sh).
#
#   tclsh9.0 probe.tcl LIBRARY
load [lindex $argv 0] Bjprobe
proc rss {} {
    set ch [open /proc/self/status]; set t [read $ch]; close $ch
    regexp {VmRSS:\s+(\d+)} $t -> kb
    return [expr {$kb / 1024}]
}
set message [encoding convertto utf-8 {{"jsonrpc": "2.0", "id": 17, "method": "textDocument/hover", "params": {"textDocument": {"uri": "file:///a/café.bot"}, "position": {"line": 3, "character": 14}}, "numbers": [0, -1, 2.5, 1e10]}}]
puts "token_count(message): [bj::token_count $message]"
foreach s {{[1, 2]} {[1, 2, 3, 4, 5, 6]} {"abcdefghij"} {[true, false, null]}} {
    puts "token_count($s): [bj::token_count [encoding convertto utf-8 $s]]"
}
puts "token_count(malformed at 6): [bj::token_count [encoding convertto utf-8 {{"a": tru}}]]"
puts "token_count(invalid UTF-8): [catch {bj::token_count \xff\xfe} m] $m"
puts "shout(café): [encoding convertfrom utf-8 [bj::shout [encoding convertto utf-8 café]]]"
puts "checked(21): [bj::checked 21]"
set rc [catch {bj::checked -5} m opts]
puts "checked(-5): status $rc, errorcode [dict getdef $opts -errorcode {}]: $m"
puts "churn(100000): [bj::churn 100000]"
set before [rss]
set t [clock microseconds]
for {set i 0} {$i < 20000} {incr i} { bj::token_count $message }
set per [expr {([clock microseconds] - $t) / 20000.0}]
puts [format "20000 x token_count(%d bytes): %.1f us per call; rss %d -> %d MiB" [string length $message] $per $before [rss]]
set before [rss]
for {set i 0} {$i < 200} {incr i} { bj::churn 10000 }
puts "200 x churn(10000): rss $before -> [rss] MiB"
# A result retained across calls: copied by the shim, so still intact.
set kept [bj::shout [encoding convertto utf-8 kept]]
bj::churn 100000
puts "retained result after a collecting call: [encoding convertfrom utf-8 $kept]"
