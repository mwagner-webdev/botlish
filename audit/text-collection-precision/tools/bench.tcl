# bench.tcl -- how today's text-construction idioms scale
# (TEXT-AND-COLLECTION-PRECISION-CENSUS.md, section G). A census tool: it
# measures what exists and adds nothing to the language.
#
#   tclsh9.0 audit/text-collection-precision/tools/bench.tcl \
#       [-sizes {N ...}] [-runs N] [-backends {interp compile cranelift}] \
#       [-markdown] [STRATEGY ...]
#
# Every strategy builds one String from N pieces held in a List (or from N
# UnicodeChars) and observes it once (std::str::length), so the program
# value is an Int every strategy and backend must agree on. The pieces are
# made by a counted loop whose bound is the substituted N.
#
# Times: interp and compile are Tcl `time` around one run (the compile
# backend's compilation excluded: compileHir once, evalUnit timed); cranelift
# is native::measure's best-of-RUNS with JIT compilation excluded. Copy
# volume (String bytes copied, native::allocationReport) is the primary
# evidence of complexity, as bench/virtual-construction.tcl's.
set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 2000000
core::useProgramRecursionLimit

namespace eval tcbench {}
set tcbench::header {import std::str
import std::list
import std::abi::bytes
import std::byte
import std::test
import std::mutable_vector
}
# STRATEGY -> {description source}; %N% is replaced by N.
set tcbench::strategies [dict create \
    fold-concat [list "fold over the pieces, acc = std::str::concat(acc, p)" {
parts = loop i from 0 to %N%:
    "ab;"
s = fold p in parts with intermediate acc "":
    std::str::concat(acc, p)
std::str::length(s)
}] \
    tail-concat [list "self-tail recursion carrying std::str::concat(acc, piece)" {
fn build(i, n, acc):
    if i >= n:
        return acc
    build(i + 1, n, std::str::concat(acc, "ab;"))
std::str::length(build(0, %N%, ""))
}] \
    halving-concat [list "balanced divide and conquer over the pieces (O(n log n) copies)" {
parts = loop i from 0 to %N%:
    "ab;"
fn cat(xs, lo, hi) errors IndexNotFound:
    if hi - lo == 1:
        return xs.at(lo)
    if hi <= lo:
        return ""
    mid = lo + (hi - lo).shift_right(1)
    std::str::concat(cat(xs, lo, mid), cat(xs, mid, hi))
s = cat(parts, 0, std::list::length(parts)):
    on IndexNotFound:
        ""
std::str::length(s)
}] \
    bytes-join [list "encode each piece, std::abi::bytes::join, decode_utf8 once" {
parts = loop i from 0 to %N%:
    "ab;"
encoded = loop p in parts:
    std::abi::bytes::from_list(p.encode_utf8())
s = std::abi::bytes::decode_utf8(std::abi::bytes::join(encoded)):
    on InvalidUtf8:
        ""
std::str::length(s)
}] \
    flat-bytes [list "std::list::flat of each piece's encode_utf8, one from_list, decode_utf8" {
parts = loop i from 0 to %N%:
    "ab;"
chunks = loop p in parts:
    p.encode_utf8()
s = std::abi::bytes::decode_utf8(std::abi::bytes::from_list(std::list::flat(chunks))):
    on InvalidUtf8:
        ""
std::str::length(s)
}] \
    fold-append-char [list "fold over N characters, acc = std::str::append_char(acc, c)" {
chars = loop i from 0 to %N%:
    'é'
s = fold c in chars with intermediate acc "":
    std::str::append_char(acc, c)
std::str::length(s)
}] \
    chars-via-bytes [list "N characters, each a one-character String, joined through bytes" {
chars = loop i from 0 to %N%:
    'é'
encoded = loop c in chars:
    std::abi::bytes::from_list(std::str::append_char("", c).encode_utf8())
s = std::abi::bytes::decode_utf8(std::abi::bytes::join(encoded)):
    on InvalidUtf8:
        ""
std::str::length(s)
}] \
    test-joined [list "std::test::joined(parts, \"\") (what task.string-concatenation suggests)" {
parts = loop i from 0 to %N%:
    "ab;"
std::str::length(std::test::joined(parts, ""))
}]]

proc tcbench::source {strategy n} {
    variable header
    variable strategies
    return $header[string map [list %N% $n] [lindex [dict get $strategies $strategy] 1]]
}

proc tcbench::field {dict key} {
    return [dict getdef $dict $key 0]
}

# {VALUE MICROSECONDS STRING-BYTES-COPIED} of STRATEGY at N on BACKEND.
proc tcbench::measure {strategy n backend runs} {
    set hir [surface::compile [source $strategy $n] <$strategy> -warnings off]
    switch -- $backend {
        interp {
            set program [hir::lower $hir]
            set best ""
            for {set r 0} {$r < $runs} {incr r} {
                set us [lindex [time {set value [core::evalProgram $program]}] 0]
                if {$best eq "" || $us < $best} { set best $us }
            }
            return [list [core::value::show $value 1] $best -]
        }
        compile {
            set unit [core::compiler::compileHir $hir]
            set best ""
            for {set r 0} {$r < $runs} {incr r} {
                set us [lindex [time {set value [core::compiler::evalUnit $unit]}] 0]
                if {$best eq "" || $us < $best} { set best $us }
            }
            return [list [core::value::show $value 1] $best -]
        }
        cranelift {
            lassign [native::measure $hir $runs] lower compile best collections value
            set report [native::allocationReport $hir summary 1]
            return [list [core::value::show $value 1] $best [dict get $report copies stringBytes]]
        }
    }
    error "unknown backend $backend"
}

set sizes {250 1000 4000}
set runs 3
set backends {interp compile cranelift}
set markdown 0
set selected {}
for {set i 0} {$i < [llength $argv]} {incr i} {
    switch -- [lindex $argv $i] {
        -sizes    { set sizes [lindex $argv [incr i]] }
        -runs     { set runs [lindex $argv [incr i]] }
        -backends { set backends [lindex $argv [incr i]] }
        -markdown { set markdown 1 }
        default   { lappend selected [lindex $argv $i] }
    }
}
if {$selected eq ""} {
    set selected [dict keys $tcbench::strategies]
}
if {$markdown} {
    puts "| strategy | N | backend | value | us | String bytes copied |"
    puts "|---|---:|---|---:|---:|---:|"
}
foreach strategy $selected {
    foreach n $sizes {
        foreach backend $backends {
            lassign [tcbench::measure $strategy $n $backend $runs] value us copied
            if {$markdown} {
                puts [format "| %s | %d | %s | %s | %.0f | %s |" $strategy $n $backend $value $us $copied]
            } else {
                puts [format "%-17s %6d %-10s %8s %12.0f us  copied %s" $strategy $n $backend $value $us $copied]
            }
            flush stdout
        }
    }
}
