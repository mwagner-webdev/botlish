# c-ffi-error-capture.tcl -- what a write-exposing C call's result costs
# natively, and what representing it as fields saves
# (C-FFI-ERROR-CAPTURE-MILESTONE-1.md, "Performance").
#
#   tclsh9.0 bench/c-ffi-error-capture.tcl ?-root DIR? ?-runs N? ?-n N?
#                                          ?-read-n N? ?-parts LIST?
#
# -root DIR measures another checkout's compiler and native backend (its own
# native/target build): the same programs, so two runs -- this tree and a
# checkout of the commit before the milestone -- compare the lowerings.
# Parts (-parts, default `shapes allocations read`):
#
#   shapes        in-process time per call (cranelift, specialized; best of
#                 RUNS runs of N calls, minus the same loop without the call)
#                 of the borrow test fixture's write exposure
#                 (core::cabi::installBorrowFixture) on a 64-byte buffer:
#                   discarded   fill(m, 0, 0) as a statement
#                   result      mixed(...)'s C result alone (a ULong)
#                   both        mixed's result and its written buffer
#                   returned    a function returning fill's write-back value,
#                               its buffer read by the caller
#                   detach 64K  fill on a 64 KiB buffer, discarded: the
#                               required private copy dominating
#   allocations   the heap objects of one call of each shape (Bytes,
#                 MutableBytes, Struct, List), beside the loop without it
#   read          per-iteration time of a standalone executable looping READ-N
#                 times over the C library's read(2) (glibc, libSystem)
#                 through a write exposure and an errno read on failure
#                 (darwin::read's shape): ok 64 (/dev/zero), EBADF 64, ok
#                 64 KiB; best of RUNS processes, minus the empty loop's
#                 executable. Hosts that link C calls only.
#
# The detach (the private copy of the caller's buffer) is Botlish's value
# semantics and stays: what the milestone removes is the write-back struct
# and its MutableBytes, built at every call before.

set args $argv
set argv {}
set options [dict create -root "" -runs 5 -n 20000 -read-n 100000 -parts {shapes allocations read}]
foreach {option value} $args {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}
set root [dict get $options -root]
if {$root eq ""} {
    set root [file dirname [file dirname [file normalize [info script]]]]
}
set root [file normalize $root]
set ::env(BOTLISH_NATIVE_BIN) [file join $root native target release botlish-native]
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
core::cabi::installBorrowFixture
set runs [dict get $options -runs]
set n [dict get $options -n]

set prelude "import abi\nimport abi::bytes\nimport ffi::c\nimport byte\nimport list\nimport ffi_fixture\n
fn pattern(n: int):
    loop i from 0 to n:
        byte::from_int(mod(i, 256))

fn raw(m: abi::bytes::MutableBytes):
    ffi_fixture::fill\[ffi::c::UChar\](m, 0, 0)

"

proc program {setup body n} {
    return "$::prelude\nfn f() -> int:\n    $setup\n    state = ffi::c::null\[ffi::c::Void\]()\n    xs = loop i from 0 to $n:\n        $body\n    list::length(xs)\n\nf()\n"
}

proc best {text} {
    lassign [native::measure [surface::compile $text -warnings off] $::runs] lower compile best
    return $best
}

proc allocations {text} {
    set report [native::allocationReport [surface::compile $text -warnings off] summary]
    lmap kind {Bytes MutableBytes Struct List} {
        expr {[dict exists $report byKind $kind] ? [dict get $report byKind $kind allocations] : 0}
    }
}

# NAME -> {SETUP BODY}: the loop body makes one call (and yields an Int).
set buffer {m = abi::bytes::from_bytes(abi::bytes::from_list(pattern(64)))
    data = abi::bytes::from_list(pattern(64))}
set shapes [dict create \
    discarded [list $buffer "ffi_fixture::fill\[ffi::c::UChar\](m, 0, 0)\n        0"] \
    result [list $buffer "ffi_fixture::mixed(data, state, m, 0).result"] \
    both [list $buffer "r = ffi_fixture::mixed(data, state, m, 0)\n        r.result + abi::bytes::mutable_length(r.output).value"] \
    returned [list $buffer "abi::bytes::mutable_length(raw(m).out).value"] \
    {detach 64K} [list {m = abi::bytes::from_bytes(abi::bytes::from_list(pattern(65536)))
    data = abi::bytes::from_list(pattern(64))} "ffi_fixture::fill\[ffi::c::UChar\](m, 0, 0)\n        0"]]

puts "root: $root ([string trim [exec git -C $root log -1 --format=%h]])"
if {"shapes" in [dict get $options -parts]} {
    puts "\nper call, ns (best of $runs runs of $n calls, minus the empty loop):"
    foreach {name shape} $shapes {
        lassign $shape setup body
        set baseline [best [program $setup 0 $n]]
        set t [best [program $setup $body $n]]
        puts [format "  %-11s %10.1f" $name [expr {1000.0 * ($t - $baseline) / $n}]]
    }
}
if {"allocations" in [dict get $options -parts]} {
    puts "\nallocations of one call {Bytes MutableBytes Struct List}, beside the loop without it:"
    foreach {name shape} $shapes {
        lassign $shape setup body
        set without [allocations [program $setup 0 1]]
        set with [allocations [program $setup $body 1]]
        puts [format "  %-11s %s" $name [lmap a $without b $with {expr {$b - $a}}]]
    }
}

# --- real read(2) in a standalone executable
if {"read" in [dict get $options -parts] && [native::hostSupports cCalls]} {
    set readN [dict get $options -read-n]
    set darwin [string match macos-* [core::cabi::hostTarget]]
    set errno [expr {$darwin ? "__error" : "__errno_location"}]
    set binding "direct module
import abi
import abi::bytes
import binary
import binary::native
import byte
import ffi::c
import list
import str

extern c fn c_errno_location named \"$errno\"() -> ffi::c::Ptr\[ffi::c::Int\] independent
extern c fn c_read named \"read\"(fd: ffi::c::Int, buf: ffi::c::Ptr\[ffi::c::Void\] write noescape, nbyte: ffi::c::ULong) -> ffi::c::Long
extern c fn c_open named \"open\"(path: ffi::c::Ptr\[ffi::c::Char\] read noescape, oflag: ffi::c::Int, variadic) -> ffi::c::Int

layout ErrnoCell:
    size 4
    align 4
    field value: ffi::c::Int at 0

struct Outcome:
    count: int
    errno: int
    data: abi::bytes::MutableBytes

fn errno() -> int:
    location = c_errno_location()
    cell = binary::native::view(ErrnoCell, location):
        on NativeViewNull:
            return 0
    cell.value

fn read(fd: ffi::c::Int, data: abi::bytes::MutableBytes) -> Outcome:
    r = c_read(fd, data, abi::bytes::mutable_length(data).value)
    if r.result < 0:
        failure = errno()
        return Outcome {count: r.result, errno: failure, data: r.buf}
    Outcome {count: r.result, errno: 0, data: r.buf}

fn nul() -> byte::Byte:
    0

fn zero() -> ffi::c::Int:
    c_open(abi::bytes::from_list(str::encode_utf8(\"/dev/zero\").append(nul())), 0)

# A descriptor no file has: read fails with EBADF.
fn closed() -> ffi::c::Int:
    99
"
    set dir [file join [file normalize [pwd]] ec-bench-[pid]]
    file mkdir $dir
    proc write {path text} {
        set f [open $path w]
        fconfigure $f -encoding utf-8 -translation lf
        puts -nonewline $f $text
        close $f
    }
    write [file join $dir rb.bot] $binding
    # NAME -> {FD SIZE}
    set rows [dict create {ok 64} {rb::zero() 64} {EBADF 64} {rb::closed() 64} {ok 64K} {rb::zero() 65536}]
    puts "\nread(2) per iteration, ns (an executable looping $readN times; best of $runs processes, minus the empty loop):"
    set counter 0
    proc exeOf {dir body iterations} {
        set main "direct module\nimport abi\nimport abi::bytes\nimport ffi::c\nimport list\nimport rb\n\nfn f(fd: ffi::c::Int, size: int) -> int:\n    n = abi::usize(size):\n        on abi::AbiIntegerAboveRange:\n            return 0\n        on abi::AbiIntegerBelowRange:\n            return 0\n    m = abi::bytes::zeroed(n)\n    xs = loop i from 0 to $iterations:\n        $body\n    list::length(xs)\n\n"
        return $main
    }
    foreach {name spec} $rows {
        lassign $spec fd size
        set times {}
        foreach {kind body} [list empty 0 call "o = rb::read(fd, m)\n        o.count + o.errno"] {
            set text [exeOf $dir $body $readN]
            append text "f($fd, $size)\n"
            write [file join $dir main.bot] $text
            set exe [native::executable [surface::readProgramFile [file join $dir main.bot] -warnings off -cache ""] [file join $dir prog[incr counter]]]
            set fastest ""
            for {set r 0} {$r < $runs} {incr r} {
                set t [lindex [time {exec $exe}] 0]
                if {$fastest eq "" || $t < $fastest} { set fastest $t }
            }
            dict set times $kind $fastest
        }
        puts [format "  %-11s %10.1f" $name [expr {1000.0 * ([dict get $times call] - [dict get $times empty]) / $readN}]]
    }
    file delete -force $dir
}
