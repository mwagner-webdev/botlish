# inproc.tcl -- can Tcl call a Botlish function in its own process today,
# without a C ABI? (COMPILER-SERVICE-CENSUS.md, "FFI and JSON feasibility")
#
#   tclsh9.0 audit/compiler-service/probes/json/inproc.tcl ?-calls N?
#
# The Tcl backends run in the compiler's own process. A program whose value
# is a function hands Tcl a block value, which core::callable::invoke (the
# reference evaluator's one call operation) can call again with any
# arguments. This probe compiles json_tokens.bot's tokenize that way, on the
# interp and on the compile backend, calls it N times (default 50) on a
# 1 KiB LSP-like message and on malformed input, and reports the time per
# call and what a failure looks like on the Tcl side.

set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname [file dirname $here]]]]
source [file join $root audit compiler-service probes lib.tcl]
cs::load $root
core::useProgramRecursionLimit

set options [dict create -calls 50]
foreach {k v} $argv { dict set options $k $v }

# The message of json_probe.bot, as Tcl text.
set message {{"jsonrpc": "2.0", "id": 17, "method": "textDocument/didChange", "params": {"textDocument": {"uri": "file:///home/user/app/main.bot", "version": 42}, "contentChanges": [{"text": "import util\nimport std::list\n\nfn total(x: int, y: int) -> int:\n    x + y\n\nx = util::f(2)\n[x + 1, std::list::get([1, 2], 5, 0)]\n# café \"quoted\" \t tab\n"}], "range": {"start": {"line": 3, "character": 14}, "end": {"line": 3, "character": 15}}, "numbers": [0, -1, 2.5, 1e10, -0.25E-3, 123456789012345678901234567890], "flags": [true, false, null]}}}

set dir [file normalize [file tempdir]]
file copy [file join $here json_tokens.bot] $dir
set ch [open [file join $dir entry.bot] w]
puts $ch "import json_tokens\n\njson_tokens::tokenize"
close $ch

set hir [surface::readProgramFile [file join $dir entry.bot] -warnings off -warning-channel "" -cache ""]
puts "message: [string length $message] characters"
foreach backend {interp compile} {
    hir::activate $hir
    set t [clock microseconds]
    if {$backend eq "interp"} {
        set fn [core::evalProgram [hir::lower $hir]]
    } else {
        set fn [core::compiler::evalHir $hir]
    }
    set setup [expr {([clock microseconds] - $t) / 1000.0}]
    set calls [dict get $options -calls]
    set t [clock microseconds]
    for {set i 0} {$i < $calls} {incr i} {
        set c [core::callable::invoke $fn [list [core::value::str $message] [core::value::int 100000]]]
    }
    set per [expr {([clock microseconds] - $t) / 1000.0 / $calls}]
    set tokens [expr {[core::completion::isNormal $c] ? [llength [core::value::items [lindex $c 1]]] : "failed: $c"}]
    puts [format "%-8s setup (lower/compile + run to the function value) %8.1f ms; per call %7.2f ms; %s tokens" $backend $setup $per $tokens]
    set bad [core::callable::invoke $fn [list [core::value::str {{"a": tru}}] [core::value::int 100]]]
    puts "         malformed input: completion kind [core::completion::kind $bad]: [string range [core::value::show [lindex $bad 1] 1] 0 120]"
}
file delete -force $dir
