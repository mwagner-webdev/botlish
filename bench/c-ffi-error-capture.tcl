# c-ffi-error-capture.tcl -- what a write-exposing C call's result costs
# natively, and what representing it as fields saves
# (C-FFI-ERROR-CAPTURE-MILESTONE-1.md, "Performance").
#
#   tclsh9.0 bench/c-ffi-error-capture.tcl ?-root DIR? ?-baseline-rev REV?
#                                          ?-runs N? ?-n N? ?-read-n N?
#                                          ?-parts LIST? ?-instructions 0|1?
#
# -root DIR measures another checkout's compiler and native backend (its own
# native/target build): the same programs, so two runs -- this tree and a
# checkout of the commit before the milestone -- compare the lowerings.
# -baseline-rev REV makes both runs on one host: revision REV's compiler and
# native backend first (a commit or a branch of origin, fetched if this
# clone lacks it, built in a temporary worktree removed afterwards: how CI
# compares on a macOS runner, tests/platform/tier.tcl's c-capture-bench),
# then ROOT's.
# Parts (-parts, default `shapes allocations read errno`):
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
#                 MutableBytes, Struct, List), beside the loop without it,
#                 in each lowering (default, -struct-opt 0, -specialize 0,
#                 both)
#   read          per-iteration time of a standalone executable looping READ-N
#                 times over the C library's read(2) (glibc, libSystem)
#                 through a write exposure and an errno read on failure
#                 (darwin::read's shape): ok 64 (/dev/zero), EBADF 64, ok
#                 64 KiB; best of RUNS processes, minus the empty loop's
#                 executable. Hosts that link C calls only.
#
#   errno         C-FFI-ERROR-CAPTURE-MILESTONE-2.md: real C (tests/cffi/
#                 fixture.c, built with the host's cc) in a standalone
#                 executable looping READ-N times over a function that calls
#                 C and reads errno on failure, for each shape -- a small
#                 signed sentinel (-1), (size_t)-1, a large successful
#                 unsigned result, a write-back value's status alone, its
#                 status and buffer, a closure capturing the value after the
#                 read, the value stored in a List after it -- and each
#                 lowering (default, -struct-opt 0, -specialize 0, both, and
#                 the eager-foreign-result fault: Milestone 1's
#                 representation): time per call (best of RUNS processes,
#                 minus the empty loop), instructions per call
#                 (-instructions 1), the allocation sites of the
#                 wrapper (static: the driver reports no allocations of a
#                 program that calls C), the hazards of the protected window
#                 (C call to errno(): `before`) and the runtime helper calls on
#                 any path through it in the object file, and whether the
#                 executable prints the same under GC stress. Hosts that
#                 link C calls only.
#
# -instructions 1 (where valgrind is installed) also counts the instructions
# a call executes, with callgrind: 2000 calls minus the empty loop, the
# shapes' in-process run per lowering and the `errno` part's executables.
# Unlike the times, which a shared machine scatters, the counts repeat
# within about 1%: what a regression check compares.
#
# The detach (the private copy of the caller's buffer) is Botlish's value
# semantics and stays: what the milestone removes is the write-back struct
# and its MutableBytes, built at every call before.

set args $argv
set argv {}
set options [dict create -root "" -baseline-rev "" -runs 5 -n 20000 -read-n 100000 -parts {shapes allocations read errno} -instructions 0]
foreach {option value} $args {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}
set root [dict get $options -root]
if {$root eq ""} {
    set root [file dirname [file dirname [file normalize [info script]]]]
}
set root [file normalize $root]
set baselineRev [dict get $options -baseline-rev]
if {$baselineRev ne ""} {
    # REV's tree, its driver built in it (cargo finds the worktree's
    # .cargo/config.toml from its working directory), measured by this
    # script with -root.
    if {[catch {exec git -C $root rev-parse --verify --quiet "$baselineRev^{commit}"} commit]} {
        exec git -C $root fetch --quiet --depth 1 origin $baselineRev
        set commit [exec git -C $root rev-parse FETCH_HEAD]
    }
    set worktree [file join [file tempdir botlish-capture-bench] tree]
    exec git -C $root worktree add --quiet --detach $worktree $commit
    set here [pwd]
    cd $worktree
    exec cargo build --release --quiet --manifest-path [file join $worktree native Cargo.toml] 2>@stderr
    cd $here
    puts "baseline: revision $baselineRev"
    exec [info nameofexecutable] [info script] {*}[dict replace $options -root $worktree -baseline-rev ""] >@stdout 2>@stderr
    exec git -C $root worktree remove --force $worktree
    file delete -force [file dirname $worktree]
    puts ""
}
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

proc allocations {text {lowering {}}} {
    set report [native::allocationReport [surface::compile $text -warnings off] summary 1 {*}$lowering]
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

# The instructions COMMAND executes (callgrind's Ir), "" without valgrind
# or -instructions 1.
set countInstructions [dict get $options -instructions]
proc instructions {args} {
    if {!$::countInstructions || [auto_execok valgrind] eq ""} {
        return ""
    }
    catch {exec valgrind --tool=callgrind --callgrind-out-file=/dev/null {*}$args 2>@1} output
    if {![regexp {Collected : ([0-9]+)} $output -> count]} {
        error "callgrind counted nothing: $output"
    }
    return $count
}
set lowerings [dict create default {} {-struct-opt 0} {-struct-opt 0} {-specialize 0} {-specialize 0} both {-struct-opt 0 -specialize 0}]

puts "root: $root ([string trim [exec git -C $root log -1 --format=%h]])"
if {"shapes" in [dict get $options -parts]} {
    puts "\nper call, ns (best of $runs runs of $n calls, minus the empty loop):"
    foreach {name shape} $shapes {
        lassign $shape setup body
        set baseline [best [program $setup 0 $n]]
        set t [best [program $setup $body $n]]
        puts [format "  %-11s %10.1f" $name [expr {1000.0 * ($t - $baseline) / $n}]]
    }
    if {[instructions true] ne ""} {
        puts "\nper call, instructions (callgrind: the driver's run of 2000 calls, minus the empty loop), by lowering:"
        set nirFile [file join [file normalize [pwd]] ec-bench-[pid].nir]
        foreach {mode lowering} $lowerings {
            foreach {name shape} $shapes {
                lassign $shape setup body
                set counts {}
                foreach calls [list 0 2000] {
                    set f [open $nirFile w]
                    puts -nonewline $f [native::nir [surface::compile [program $setup [expr {$calls ? $body : 0}] 2000] -warnings off] {*}$lowering]
                    close $f
                    lappend counts [instructions $::env(BOTLISH_NATIVE_BIN) run $nirFile]
                }
                puts [format "  %-11s %-14s %8.1f" $name $mode [expr {([lindex $counts 1] - [lindex $counts 0]) / 2000.0}]]
            }
        }
        file delete $nirFile
    }
}
if {"allocations" in [dict get $options -parts]} {
    puts "\nallocations of one call {Bytes MutableBytes Struct List}, beside the loop without it, by lowering:"
    foreach {mode lowering} {default {} {-struct-opt 0} {-struct-opt 0} {-specialize 0} {-specialize 0} both {-struct-opt 0 -specialize 0}} {
        foreach {name shape} $shapes {
            lassign $shape setup body
            set without [allocations [program $setup 0 1] $lowering]
            set with [allocations [program $setup $body 1] $lowering]
            puts [format "  %-11s %-14s %s" $name $mode [lmap a $without b $with {expr {$b - $a}}]]
        }
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

# --- representation invariance (C-FFI-ERROR-CAPTURE-MILESTONE-2.md)
if {"errno" in [dict get $options -parts] && [native::hostSupports cCalls] && [auto_execok cc] ne ""} {
    # The fixture and the detectors are this script's own (a baseline tree
    # predates the milestone's fixture functions); the compiler and the
    # native backend are ROOT's.
    set own [file dirname [file dirname [file normalize [info script]]]]
    source [file join $own tests cffi window.tcl]
    set readN [dict get $options -read-n]
    set darwin [string match macos-* [core::cabi::hostTarget]]
    set dir [file join [file normalize [pwd]] ec2-bench-[pid]]
    file mkdir $dir
    exec cc -c -O2 -fPIC [file join $own tests cffi fixture.c] -o [file join $dir fixture.o]
    exec ar rcs [file join $dir libbotlish_cffi_fixture.a] [file join $dir fixture.o]
    proc put {path text} {
        set f [open $path w]
        fconfigure $f -encoding utf-8 -translation lf
        puts -nonewline $f $text
        close $f
    }
    put [file join $dir eb.bot] "direct module
import abi
import abi::bytes
import binary
import binary::native
import ffi::c

extern c library \"botlish_cffi_fixture\"

extern c fn c_errno_location named \"[expr {$darwin ? "__error" : "__errno_location"}]\"() -> ffi::c::Ptr\[ffi::c::Int\] independent
extern c fn fill_errno named \"bcf_fill_errno\"(out: ffi::c::Ptr\[ffi::c::UChar\] write noescape, count: ffi::c::ULong, seed: ffi::c::UChar, err: ffi::c::Int, stale: ffi::c::Int) -> ffi::c::Long
extern c fn large_error named \"bcf_large_error\"(failing: ffi::c::Int) -> ffi::c::ULong
extern c fn unsigned_errno named \"bcf_unsigned_errno\"(which: ffi::c::Int, err: ffi::c::Int) -> ffi::c::ULong
extern c fn signed_errno named \"bcf_signed_errno\"(which: ffi::c::Int, err: ffi::c::Int) -> ffi::c::Long

layout ErrnoCell:
    size 4
    align 4
    field value: ffi::c::Int at 0

fn errno() -> int:
    location = c_errno_location()
    cell = binary::native::view(ErrnoCell, location):
        on NativeViewNull:
            return 0
    cell.value

fn mlen(d: abi::bytes::MutableBytes) -> ffi::c::ULong:
    abi::bytes::mutable_length(d).value
"
    # NAME -> {WRAPPER BODY}: WRAPPER the function making the call (`w`),
    # BODY one iteration's use of it (an Int).
    set wrappers [dict create \
        {small -1} [list "fn w(m: abi::bytes::MutableBytes) -> int:\n    r = eb::signed_errno(1, 9)\n    if r < 0:\n        return eb::errno()\n    0\n" "w(m)"] \
        {(size_t)-1} [list "fn w(m: abi::bytes::MutableBytes) -> int:\n    r = eb::large_error(9)\n    if r == 18446744073709551615:\n        return eb::errno()\n    0\n" "w(m)"] \
        {large ok} [list "fn w(m: abi::bytes::MutableBytes):\n    r = eb::unsigned_errno(6, 0)\n    if r == 18446744073709551615:\n        return \[r, eb::errno()\]\n    \[r, 0\]\n" "list::length(w(m))"] \
        {wb status} [list "fn w(m: abi::bytes::MutableBytes) -> int:\n    r = eb::fill_errno(m, eb::mlen(m), 1, 9, 0)\n    if r.result < 0:\n        return eb::errno()\n    0\n" "w(m)"] \
        {wb +buffer} [list "fn w(m: abi::bytes::MutableBytes) -> int:\n    r = eb::fill_errno(m, eb::mlen(m), 1, 9, 0)\n    failure = if r.result < 0:\n        eb::errno()\n    else:\n        0\n    failure + abi::bytes::mutable_length(r.out).value\n" "w(m)"] \
        {wb captured} [list "fn w(m: abi::bytes::MutableBytes) -> list:\n    r = eb::fill_errno(m, eb::mlen(m), 1, 9, 0)\n    failure = if r.result < 0:\n        eb::errno()\n    else:\n        0\n    fn get() -> abi::bytes::MutableBytes:\n        r.out\n    \[failure, get\]\n" "list::length(w(m))"] \
        {wb in List} [list "fn w(m: abi::bytes::MutableBytes) -> list:\n    r = eb::fill_errno(m, eb::mlen(m), 1, 9, 0)\n    failure = if r.result < 0:\n        eb::errno()\n    else:\n        0\n    \[failure, r\]\n" "list::length(w(m))"]]
    set modes $lowerings
    put [file join $dir probe.bot] "1\n"
    if {![catch {native::nir [surface::readProgramFile [file join $dir probe.bot] -warnings off -cache ""] -fault eager-foreign-result}]} {
        # (A tree before the milestone has no fault: its default lowering is
        # Milestone 1's representation.)
        dict set modes {eager (fault)} {-fault eager-foreign-result}
    }
    proc mainOf {wrapper body iterations} {
        # (The empty loop calls nothing direct: it may not say it is.)
        set marker [if {$wrapper eq ""} {string cat ""} else {string cat "direct module\n"}]
        return "${marker}import abi\nimport abi::bytes\nimport ffi::c\nimport list\nimport eb\n\n$wrapper\nfn f() -> int:\n    m = abi::bytes::zeroed(abi::usize(64))\n    xs = loop i from 0 to $iterations:\n        $body\n    list::length(xs)\n\nf()\n"
    }
    set counter 0
    proc build {dir text options} {
        put [file join $dir main.bot] $text
        set hir [surface::readProgramFile [file join $dir main.bot] -warnings off -cache ""]
        set exe [native::withLinkDirs [list $dir] {native::executable $hir [file join $dir prog[incr ::counter]] {*}$options}]
        return [list $hir $exe]
    }
    proc fastest {exe} {
        set best ""
        for {set r 0} {$r < $::runs} {incr r} {
            set t [lindex [time {exec $exe}] 0]
            if {$best eq "" || $t < $best} { set best $t }
        }
        return $best
    }
    puts "\nC error capture by shape and lowering (C-FFI-ERROR-CAPTURE-MILESTONE-2.md; $readN calls per executable, best of $runs processes):"
    set counting [expr {[instructions true] ne ""}]
    puts [format "  %-12s %-20s %9s %9s %6s %7s %-28s %s" shape lowering ns/call instr sites before helpers {GC stress}]
    foreach {mode options} $modes {
        lassign [build $dir [mainOf {} 0 $readN] $options] - empty
        set emptyTime [fastest $empty]
        if {$counting} {
            set emptyCount [instructions [lindex [build $dir [mainOf {} 0 2000] $options] 1]]
        }
        foreach {name spec} $wrappers {
            lassign $spec wrapper body
            lassign [build $dir [mainOf $wrapper $body $readN] $options] hir exe
            set t [fastest $exe]
            set count -
            if {$counting} {
                set count [format %.1f [expr {([instructions [lindex [build $dir [mainOf $wrapper $body 2000] $options] 1]] - $emptyCount) / 2000.0}]]
            }
            set plain [exec $exe]
            set stress [expr {[exec env BOTLISH_NATIVE_GC_STRESS=1 $exe] eq $plain ? "same" : "DIFFERS"}]
            # The allocation sites of the wrapper (a static count: the driver
            # makes no allocation report of a program that calls C, which
            # runs as an executable; the in-process `allocations` part above
            # counts the objects): the allocating instructions of `w`
            # (sites), and every instruction of the protected window (C call
            # to errno()) that may allocate or call (`before`, the NIR
            # detector's hazards).
            set nir [native::nir $hir {*}$options]
            set sites 0
            foreach body [window::nirBodies $nir w] {
                foreach line $body {
                    if {[regexp {= (structnew|closure|op (cwbox|listnew|listappend|mbytes(new|from|set|clone|freeze|freezeprefix)))\M} $line]} {
                        incr sites
                    }
                }
            }
            set before 0
            foreach window [window::nirWindows $nir w eb::errno] {
                incr before [llength [window::nirHazards $window]]
            }
            set object [file join $dir obj[incr ::counter].o]
            native::object $hir $object {*}$options
            set functions [window::machine $object]
            set foreign [dict getdef {{small -1} bcf_signed_errno {(size_t)-1} bcf_large_error {large ok} bcf_unsigned_errno} $name bcf_fill_errno]
            set helpers {}
            set errnoFn botlish_fn_[window::nirId $nir eb::errno]
            foreach id [regexp -all -inline -line {^func ([0-9]+) "w" } $nir] {
                if {[string is integer -strict $id]} {
                    lappend helpers {*}[window::machineWindow $functions botlish_fn_$id $foreign $errnoFn]
                }
            }
            puts [format "  %-12s %-20s %9.1f %9s %6s %7s %-28s %s" $name $mode [expr {1000.0 * ($t - $emptyTime) / $readN}] $count $sites $before [lsort -unique $helpers] $stress]
        }
    }
    file delete -force $dir
}

