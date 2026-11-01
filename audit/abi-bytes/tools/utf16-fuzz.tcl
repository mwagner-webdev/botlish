#!/usr/bin/env tclsh9.0
# utf16-fuzz.tcl -- random Strings and random bytes through
# std::abi::bytes::encode_utf16le and decode_utf16le, against an independent
# oracle (UTF16-BYTE-STORAGE-MILESTONE-1.md, "Fuzzing").
#
#   tclsh9.0 audit/abi-bytes/tools/utf16-fuzz.tcl ?-n N? ?-seed S?
#       ?-backends LIST? ?-gc-stress 0|1? ?-parts LIST?
#
# Parts (-parts, default both):
#
#   strings  N random Strings of Unicode scalar values (a quarter all
#            ASCII) -- ASCII, BMP
#            characters (never a surrogate), supplementary-plane characters,
#            combining marks, U+0000, U+FFFD, U+FEFF, and some long Strings of
#            mixed widths -- each built in the program from its UTF-8 bytes
#            (std::abi::bytes::decode_utf8: no UTF-16 code involved), encoded
#            with encode_utf16le and decoded back. Each encoding must be the
#            oracle's bytes exactly, and every decoding the String itself.
#   bytes    N random byte buffers -- lengths 0 to 17 (odd ones among them),
#            many of their units surrogates (a high byte D8..DF), pairs in
#            both orders, lone ones, ordinary units; a third of them the
#            units of ASCII text, half of those with one fault (an odd byte,
#            a lone surrogate, a unit at U+0080) -- decoded with
#            decode_utf16le. Acceptance and every decoded scalar must be the
#            oracle's, and an accepted buffer must encode back to itself.
#
# The oracle (utf16-oracle.py beside this script, python3 -I) is plain
# integer arithmetic written from the milestone's rules, checked by its own
# selftest against Python's utf-16-le codec -- neither the Tcl backends'
# Tcl encoding nor the native runtime's Rust: the production encoder is
# never the decoder's oracle, nor the other way round. Every backend of
# -backends (default all four) runs the same program; each must agree with
# the oracle (and so with every other). -gc-stress 1 runs the native ones
# under BOTLISH_NATIVE_GC_STRESS=1.
#
# The last line is "cases N disagreements D"; the exit status is 1 when D > 0.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set options [dict create -n 200 -seed 1 -backends {interp compile cranelift-generic cranelift} \
    -gc-stress 0 -parts {strings bytes} -verbose 0]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}
source [file join $root compiler compiler.tcl]
source [file join $root native native.tcl]
source [file join $root surface surface.tcl]
expr {srand([dict get $options -seed])}
interp recursionlimit {} 100000

set n [dict get $options -n]
set scratch [file tempdir botlish-utf16-fuzz-]
set cases 0
set disagreements 0
set programs 0

proc rand {n} { expr {int(rand() * $n)} }
proc pick {list} { lindex $list [rand [llength $list]] }

proc build {text} {
    set dir [file join $::scratch p[incr ::programs]]
    file mkdir $dir
    set f [open [file join $dir main.bot] w]
    fconfigure $f -encoding utf-8 -translation lf
    puts -nonewline $f $text
    close $f
    return [surface::readProgramFile [file join $dir main.bot] -warnings off -cache "" -target [core::cabi::hostTarget]]
}

proc outcome {backend hir} {
    if {[catch {
        switch -- $backend {
            interp {
                core::useBackend interp
                core::evalProgram [hir::lower $hir]
            }
            compile { core::compiler::evalHir $hir }
            cranelift-generic { native::evalHir $hir -specialize 0 }
            cranelift { native::evalHir $hir }
        }
    } result opts]} {
        return [list error "[lindex [dict get $opts -errorcode] end]: [string range $result 0 300]"]
    }
    return [list value [core::value::show $result 1 1]]
}

proc report {part index expected got} {
    incr ::disagreements
    puts "$part case $index: expected [list $expected], got [list $got]"
}

# The oracle's answers to LINES (utf16-oracle.py's input lines), in order.
proc oracle {lines} {
    set path [file join $::scratch cases.txt]
    set f [open $path w]
    fconfigure $f -encoding utf-8 -translation lf
    puts -nonewline $f [join $lines \n]\n
    close $f
    set answers [split [exec python3 -I [file join $::root audit abi-bytes tools utf16-oracle.py] < $path] \n]
    return [lrange $answers 0 [expr {[llength $lines] - 1}]]
}

# A random Unicode scalar value from the pools that matter.
proc randomScalar {} {
    switch [rand 9] {
        0 - 1 { return [expr {32 + [rand 95]}] }
        2 { return [pick {0 65533 65279 65534 65535}] }
        3 { return [expr {768 + [rand 112]}] }
        4 { return [expr {128 + [rand 1920]}] }
        5 { return [expr {[rand 2] ? 2048 + [rand 53248] : 57344 + [rand 8192]}] }
        6 { return [expr {0x10000 + [rand 0x100000]}] }
        7 { return [expr {[pick {0x10000 0x10FFFF 0x1F600 0x1D11E 0xFFFF 0xE000 0xD7FF}]}] }
        default { return [expr {0x1F300 + [rand 0x300]}] }
    }
}

# A random String's scalars: one in four all ASCII (the native runtime's
# ASCII paths), the rest from every pool; one in ten long.
proc randomScalars {} {
    set count [expr {[rand 10] == 0 ? 100 + [rand 500] : [rand 20]}]
    set ascii [expr {[rand 4] == 0}]
    set out {}
    for {set i 0} {$i < $count} {incr i} {
        lappend out [expr {$ascii ? [rand 128] : [randomScalar]}]
    }
    return $out
}

proc utf8Codes {scalars} {
    binary scan [encoding convertto utf-8 [join [lmap c $scalars {format %c $c}] ""]] cu* codes
    return $codes
}

# A random byte buffer whose units lean toward surrogates -- or, one in
# three, the units of ASCII text (the native decoder's ASCII path) with, half
# the time, one fault: a trailing odd byte, a lone surrogate or one unit at
# or just past U+0080.
proc randomBuffer {} {
    if {[rand 3] == 0} {
        set out {}
        set units [expr {[rand 2] ? [rand 9] : 60 + [rand 200]}]
        for {set i 0} {$i < $units} {incr i} {
            lappend out [rand 128] 0
        }
        if {[rand 2]} {
            set at [expr {2 * [rand [expr {$units + 1}]]}]
            switch [rand 4] {
                0 { lappend out [rand 256] }
                1 { set out [linsert $out $at 0 [expr {216 + [rand 8]}]] }
                2 { set out [linsert $out $at 0 [expr {220 + [rand 4]}]] }
                default { set out [linsert $out $at [expr {127 + [rand 2]}] 0] }
            }
        }
        return $out
    }
    set len [rand 18]
    set out {}
    for {set i 0} {$i < $len} {incr i} {
        if {$i % 2 == 1 && [rand 2]} {
            lappend out [expr {216 + [rand 8]}]
        } else {
            lappend out [rand 256]
        }
    }
    return $out
}

set prelude "import std::abi
import std::abi::bytes
import std::byte
import std::char
import std::int
import std::list
import std::str

fn raw(xs: List\[int\]) -> std::abi::bytes::Bytes:
    bs = loop x in xs:
        std::byte::from_int(x):
            on std::byte::BelowRange:
                0
            on std::byte::AboveRange:
                0
    std::abi::bytes::from_list(bs)

fn s(xs: List\[int\]) -> str:
    std::abi::bytes::decode_utf8(raw(xs)):
        on InvalidUtf8:
            \"<not UTF-8>\"

fn joined(parts: List\[str\], i: int) -> str:
    head = parts.at(i):
        on IndexNotFound:
            return \"\"
    if i + 1 == parts.length():
        return head
    std::str::concat(std::str::concat(head, \",\"), joined(parts, i + 1))

fn rendered(t: str) -> str:
    parts = loop i from 0 to t.length():
        t.char_at(i).scalar_value().to_string()
    joined(parts, 0)
"

proc stringsPart {} {
    global n
    set inputs {}
    for {set i 0} {$i < $n} {incr i} {
        lappend inputs [randomScalars]
    }
    set calls [join [lmap sc $inputs {string cat "e(\[[join [utf8Codes $sc] {, }]\])"}] ",\n    "]
    set text "${::prelude}
fn e(xs: List\[int\]) -> List\[any\]:
    t = s(xs)
    data = std::abi::bytes::encode_utf16le(t)
    back = std::abi::bytes::decode_utf16le(data):
        on InvalidUtf16:
            return \[data, false\]
    \[data, back == t\]

\[$calls\]
"
    set expected [oracle [lmap sc $inputs {string cat encode\t[join $sc ,]}]]
    if {[catch {build $text} hir]} {
        report strings program compiles $hir
        return
    }
    foreach backend [dict get $::options -backends] {
        lassign [outcome $backend $hir] kind value
        if {$kind ne "value"} {
            report strings $backend value $value
            continue
        }
        set hexes [lmap {- h} [regexp -all -inline {<bytes [0-9]+: ([0-9a-f]*)>} $value] {set h}]
        set trips [regexp -all -inline {\m(?:true|false)\M} $value]
        foreach sc $inputs want $expected got $hexes trip $trips {
            incr ::cases
            if {$got ne $want || $trip ne "true"} {
                report strings "[list [lrange $sc 0 7]] ($backend)" [list $want true] [list $got $trip]
            }
        }
        if {[llength $hexes] != [llength $inputs]} {
            report strings "count ($backend)" [llength $inputs] [llength $hexes]
        }
    }
}

proc bytesPart {} {
    global n
    set inputs {}
    for {set i 0} {$i < $n} {incr i} {
        lappend inputs [randomBuffer]
    }
    set calls [join [lmap b $inputs {string cat "d(\[[join $b {, }]\])"}] ",\n    "]
    set text "${::prelude}
fn d(xs: List\[int\]) -> List\[any\]:
    data = raw(xs)
    t = std::abi::bytes::decode_utf16le(data):
        on InvalidUtf16:
            return \[\"invalid\", data\]
    \[rendered(t), std::abi::bytes::encode_utf16le(t)\]

\[$calls\]
"
    set expected [oracle [lmap b $inputs {string cat decode\t[binary encode hex [binary format cu* $b]]}]]
    if {[catch {build $text} hir]} {
        report bytes program compiles $hir
        return
    }
    foreach backend [dict get $::options -backends] {
        lassign [outcome $backend $hir] kind value
        if {$kind ne "value"} {
            report bytes $backend value $value
            continue
        }
        set texts [lmap {- t} [regexp -all -inline {"([^"]*)"} $value] {set t}]
        set hexes [lmap {- h} [regexp -all -inline {<bytes [0-9]+: ([0-9a-f]*)>} $value] {set h}]
        foreach b $inputs want $expected got $texts back $hexes {
            incr ::cases
            set input [binary encode hex [binary format cu* $b]]
            # An accepted buffer encodes back to itself; a refused one is
            # returned as it was given.
            if {$got ne $want || $back ne $input} {
                report bytes "$input ($backend)" [list $want $input] [list $got $back]
            }
        }
        if {[llength $texts] != [llength $inputs]} {
            report bytes "count ($backend)" [llength $inputs] [llength $texts]
        }
    }
}

if {[dict get $options -gc-stress]} {
    set ::env(BOTLISH_NATIVE_GC_STRESS) 1
}
foreach part [dict get $options -parts] {
    switch -- $part {
        strings { stringsPart }
        bytes { bytesPart }
        default { error "unknown part $part" }
    }
}
unset -nocomplain ::env(BOTLISH_NATIVE_GC_STRESS)
if {$::tcl_platform(platform) eq "unix"} {
    exec rm -rf -- $scratch
} else {
    file delete -force $scratch
}
puts "cases $cases disagreements $disagreements"
exit [expr {$disagreements > 0}]
