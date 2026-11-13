# alloc.tcl -- census measurement (HTTP-SSE-SERVER-CENSUS-MILESTONE-1.md):
# native heap allocations per operation of the probe server's hot paths,
# from native::allocationReport (the driver's --alloc summary). Each
# operation runs N times in a generated program beside a copy of
# probes/p2/http1.bot; the per-operation figure is the difference between
# N = 110 and N = 10, divided by 100, so start-up allocations cancel.
#
#   tclsh9.0 audit/http-sse-server-census/tools/alloc.tcl
set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]

set dir [file tempdir]
file copy [file join $here .. probes p2 http1.bot] $dir

set prelude {import http1
import std::abi
import std::abi::bytes
import std::linux
import std::mutable_array
import std::str

head = http1::utf8("GET /events HTTP/1.1\r\nHost: localhost:8080\r\nUser-Agent: curl/8.5.0\r\nAccept: text/event-stream\r\nLast-Event-ID: 41\r\n\r\n")
chunk = http1::utf8("0123456789abcdef0123456789abcdef")
acc = std::mutable_array::create(1, http1::empty())
frame = "id: 42\nevent: item\ndata: {\"name\": \"x\"}\n\n"
}

set ops {
    zeroed-4096+freeze_prefix   {r = std::abi::bytes::zeroed(std::abi::usize(4096))
    c = r.freeze_prefix(std::abi::usize(32)):
        on UpperOverrun:
            http1::empty()}
    linux-read-4096-fd0          {r = std::linux::read(std::abi::I32 {value: 0}, std::abi::bytes::zeroed(std::abi::usize(4096)))}
    join-32-onto-buffer          {acc.set(0, std::abi::bytes::join([acc.at(0), chunk])):
        on IndexNotFound:
            unit}
    scan-head-130-bytes          {s = http1::scan(head, 8192)}
    scan+parse-head              {s = http1::scan(head, 8192)
    p = http1::parse(s.text)}
    response-200-ok              {b = http1::response(200, "text/plain", "ok\n", false)}
    sse-frame-to-bytes           {b = http1::utf8(frame)}
    sse-data_lines-30-chars      {t = http1::data_lines("{\"name\": \"x\", \"n\": 12345678}")}
}

proc program {body n} {
    set lines {}
    foreach line [split $body \n] {
        # continuation lines are written indented by four already
        if {[llength $lines] > 0} {
            set line [string range $line 4 end]
        }
        lappend lines "    $line"
    }
    set marker [expr {[string match *std::linux::read* $body] ? "direct module\n\n" : ""}]
    return "$marker$::prelude\nloop i from 0 to $n:\n[join $lines \n]\n0\n"
}

proc measure {name body n} {
    set f [file join $::dir m.bot]
    set fh [open $f w]; puts -nonewline $fh [program $body $n]; close $fh
    set hir [surface::readProgramFile $f -warnings off]
    native::allocationReport $hir summary
}

puts [format "%-30s %10s %12s  %s" operation allocs/op bytes/op "by kind (allocations/op)"]
foreach {name body} $ops {
    if {[catch {
        set a [measure $name $body 10]
        set b [measure $name $body 110]
        set kinds {}
        dict for {kind row} [dict get $b byKind] {
            set d [expr {([dict get $row allocations] - [dict get $a byKind $kind allocations]) / 100.0}]
            if {$d != 0} {
                lappend kinds "$kind $d"
            }
        }
        puts [format "%-30s %10.2f %12.1f  %s" $name \
            [expr {([dict get $b total allocations] - [dict get $a total allocations]) / 100.0}] \
            [expr {([dict get $b total allocatedBytes] - [dict get $a total allocatedBytes]) / 100.0}] [join $kinds {, }]]
    } err]} {
        puts [format "%-30s ERROR %s" $name [string range $err 0 300]]
    }
}
file delete -force $dir
