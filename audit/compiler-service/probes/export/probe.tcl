# probe.tcl -- drives the exported-function probe from Tcl (run.sh).
#
#   tclsh9.0 probe.tcl LIBRARY ?-quick?
#
# -quick (the GC-stress run) skips the throughput measurements and runs the
# loops shorter: a collection at every allocation makes them slow.
load [lindex $argv 0] Bjprobe
set quick [expr {[lindex $argv 1] eq "-quick"}]
proc rss {} {
    set ch [open /proc/self/status]; set t [read $ch]; close $ch
    regexp {VmRSS:\s+(\d+)} $t -> kb
    return [expr {$kb / 1024}]
}
proc failure {script} {
    if {[catch {uplevel 1 $script} message options]} {
        return [list [dict get $options -errorcode] $message]
    }
    return "no error"
}
set message [encoding convertto utf-8 {{"jsonrpc": "2.0", "id": 17, "method": "textDocument/hover", "params": {"textDocument": {"uri": "file:///a/café.bot"}, "position": {"line": 3, "character": 14}}, "numbers": [0, -1, 2.5, 1e10]}}]
puts "token_count(message): [bj::token_count $message]"
foreach s {{[1, 2]} {[1, 2, 3]} {[1, 2, 3, 4, 5, 6]} {"abcdefghij"} {[true, false, null]} {{"é": "ü", "😀": [1.5e3, -0, true]}}} {
    puts "token_count($s): [bj::token_count [encoding convertto utf-8 $s]]"
}
set long [encoding convertto utf-8 "\[[join [lmap i [lrepeat 500 x] {string cat 1}] {, }]\]"]
puts "token_count(a 500-element array, [string length $long] bytes): [bj::token_count $long]"
puts "token_count(malformed at 6): [bj::token_count [encoding convertto utf-8 {{"a": tru}}]]"
puts "tokens(malformed at 6): [failure {bj::tokens [encoding convertto utf-8 {{"a": tru}}]}]"
puts "tokens(unterminated string): [failure {bj::tokens [encoding convertto utf-8 {["abc}]}]"
puts "tokens(\[1, 2\]): [bj::tokens [encoding convertto utf-8 {[1, 2]}]]"
puts "token_count(invalid UTF-8): [failure {bj::token_count \xff\xfe}]"
puts "shout(café): [encoding convertfrom utf-8 [bj::shout [encoding convertto utf-8 café]]]"
puts "shout(a NUL inside): [string length [bj::shout a\x00b]] bytes"
puts "checked(21): [bj::checked 21]"
puts "checked(-5): [failure {bj::checked -5}]"
puts "churn(100000): [bj::churn [expr {$quick ? 300 : 100000}]]"
# A result retained across collecting calls: copied out of the owned buffer
# the library returned (released at once), so it never depended on the heap.
set kept [bj::shout [encoding convertto utf-8 kept]]
bj::churn [expr {$quick ? 300 : 100000}]
puts "retained result after a collecting call: [encoding convertfrom utf-8 $kept]"
# An error object is data: its identity and payload survive later calls.
catch {bj::checked -7} m o
bj::churn 100
puts "error after later calls: [dict get $o -errorcode]"
# Explicit lifecycle: destroy, a call on the destroyed instance, recreate.
bj::destroy
puts "after destroy: [failure {bj::checked 1}]"
bj::create
puts "after create: checked(2) = [bj::checked 2]"
if {!$quick} {
    set before [rss]
    set t [clock microseconds]
    for {set i 0} {$i < 20000} {incr i} { bj::token_count $message }
    set per [expr {([clock microseconds] - $t) / 20000.0}]
    puts [format "20000 x token_count(%d bytes): %.1f us per call; rss %d -> %d MiB" [string length $message] $per $before [rss]]
    set before [rss]
    for {set i 0} {$i < 200} {incr i} { bj::churn 10000 }
    puts "200 x churn(10000): rss $before -> [rss] MiB"
    set before [rss]
    for {set i 0} {$i < 2000} {incr i} { bj::destroy; bj::create; bj::checked $i }
    puts "2000 x destroy + create + call: rss $before -> [rss] MiB"
}
