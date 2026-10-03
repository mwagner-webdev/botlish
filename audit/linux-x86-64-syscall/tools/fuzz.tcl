#!/usr/bin/env tclsh9.0
# fuzz.tcl -- randomized check of the pure abi::x86_64 conversions
# (LINUX-X86-64-SYSCALL.md): Int -> Register64 -> Int.
#
#   tclsh9.0 audit/linux-x86-64-syscall/tools/fuzz.tcl ?-n N? ?-seed S?
#       ?-values V? ?-backends LIST? ?-gc-stress 0|1?
#
# No syscall is ever made: the kernel transition is not fuzzed (that would be
# unsafe and meaningless); only the conversions around it are.
#
# Each program (seeded individually: a failure replays with `-seed S -n 1`)
# draws V Ints clustered on the register bounds (+-2^63), the small-Int
# bounds (+-2^62), zero, arbitrary i64 bit patterns and values far beyond the
# register, and checks three things against an independent oracle (Tcl's own
# arbitrary-precision comparison with -2^63 and 2^63-1):
#
#   dynamic     every backend runs `register64(x)` on each value from a List
#               (so nothing is statically known): an in-range value
#               round-trips through to_int unchanged, an out-of-range one is
#               exactly the declared Register64BelowRange/AboveRange --
#               never a truncated or wrapped register
#   constant    each value written as a literal argument: in range needs no
#               handler at all (the call-specific completion proof), out of
#               range is the compile-time KNOWN-ERROR naming the violated
#               bound
#   round trip  in-range values through a typed Register64 parameter and
#               register64(to_int(r)) with no handler, on every backend
#
# The run ends with "register64-fuzz programs N values V out-of-range O
# constant-checks C failures F"; the exit status is 1 if F is not zero.
set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set args $argv
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
interp recursionlimit {} 100000

set n 20
set seed0 1
set valueCount 200
set backends {interp compile cranelift-generic cranelift}
set gcStress 0
while {[lindex $args 0] in {-n -seed -values -backends -gc-stress}} {
    switch -- [lindex $args 0] {
        -n { set n [lindex $args 1] }
        -seed { set seed0 [lindex $args 1] }
        -values { set valueCount [lindex $args 1] }
        -backends { set backends [lindex $args 1] }
        -gc-stress { set gcStress [lindex $args 1] }
    }
    set args [lrange $args 2 end]
}
if {$gcStress} {
    set ::env(BOTLISH_NATIVE_GC_STRESS) 1
}

# Program files live in a fresh system temporary directory, removed however
# the run ends (never inside the checkout).
set scratch [file tempdir register64-fuzz]
set counter 0

proc hirOfText {text {strict 1}} {
    set path [file join $::scratch p[incr ::counter].bot]
    set channel [open $path w]
    fconfigure $channel -encoding utf-8
    puts -nonewline $channel $text
    close $channel
    try {
        return [surface::readProgramFile $path -strict $strict]
    } finally {
        file delete $path
    }
}

proc oracle {v} {
    if {$v < -9223372036854775808} { return "\"below\"" }
    if {$v > 9223372036854775807} { return "\"above\"" }
    return $v
}

proc lit {v} {
    return [expr {$v < 0 ? "0 - [expr {-$v}]" : $v}]
}

proc draw {} {
    switch -- [expr {int(rand() * 6)}] {
        0 {
            set anchors {9223372036854775807 -9223372036854775808 9223372036854775808 -9223372036854775809}
            set a [lindex $anchors [expr {int(rand() * 4)}]]
            return [expr {$a + int(rand() * 9) - 4}]
        }
        1 {
            set anchors {4611686018427387903 4611686018427387904 -4611686018427387904 -4611686018427387905 0}
            set a [lindex $anchors [expr {int(rand() * 5)}]]
            return [expr {$a + int(rand() * 9) - 4}]
        }
        2 {
            # An arbitrary 64-bit pattern, read signed.
            set u [expr {int(rand() * 2**32) * 2**32 + int(rand() * 2**32)}]
            return [expr {$u >= 2**63 ? $u - 2**64 : $u}]
        }
        3 {
            set bits [expr {int(rand() * 64)}]
            set v [expr {(int(rand() * 2**32) * 2**32 + int(rand() * 2**32)) % (2**$bits + 1)}]
            return [expr {rand() < 0.5 ? -$v : $v}]
        }
        4 {
            set v [expr {2**63 + int(rand() * 2**50) * 2**50 + int(rand() * 2**50)}]
            return [expr {rand() < 0.5 ? -$v - 1 : $v}]
        }
        5 {
            return [expr {int(rand() * 200) - 100}]
        }
    }
}

proc outcomes {hir} {
    return [lmap backend $::backends {outcomeUnderHir $backend $hir}]
}

set failures 0
set values 0
set outOfRange 0
set constantChecks 0
try {
for {set p 0} {$p < $n} {incr p} {
    set seed [expr {$seed0 + $p}]
    expr {srand($seed)}
    set xs {}
    for {set i 0} {$i < $valueCount} {incr i} {
        lappend xs [draw]
    }
    incr values [llength $xs]
    set expected "\[[join [lmap v $xs {oracle $v}] {, }]\]"
    incr outOfRange [llength [lsearch -all -glob [lmap v $xs {oracle $v}] {"*}]]

    # dynamic
    set text "fn classify(n: int):\n    r = abi::x86_64::register64(n):\n        on Register64BelowRange:\n            return \"below\"\n        on Register64AboveRange:\n            return \"above\"\n    abi::x86_64::to_int(r)\n\nxs = \[[join [lmap v $xs {lit $v}] {, }]\]\nloop x in xs:\n    classify(x)\n"
    foreach backend $::backends outcome [outcomes [hirOfText $text]] {
        if {$outcome ne [list value $expected {}]} {
            incr failures
            puts "FAIL seed $seed dynamic $backend: [string range $outcome 0 300]"
        }
    }

    # constant: 10 values per program, each its own literal call
    foreach v [lrange $xs 0 9] {
        incr constantChecks
        set hir [hirOfText "abi::x86_64::to_int(abi::x86_64::register64([lit $v]))\n" 0]
        set kinds [lsort -unique [lmap d [hir::diagnostics $hir] {dict get $d kind}]]
        set o [oracle $v]
        set want [expr {[string match {"*} $o] ? "KNOWN-ERROR" : ""}]
        if {$kinds ne $want} {
            incr failures
            puts "FAIL seed $seed constant $v: diagnostics {$kinds}, expected {$want}"
        } elseif {$want eq "KNOWN-ERROR"} {
            set message [dict get [lindex [hir::diagnostics $hir] 0] message]
            set error [expr {$o eq "\"below\"" ? "Register64BelowRange" : "Register64AboveRange"}]
            if {![string match "*$error*" $message]} {
                incr failures
                puts "FAIL seed $seed constant $v: $message"
            }
        }
    }

    # round trip, in-range values only, no handler anywhere but the dynamic
    # entry
    set inRange [lsearch -all -inline -not -glob [lmap v $xs {oracle $v}] {"*}]
    set text "fn again(r: abi::x86_64::Register64) -> abi::x86_64::Register64:\n    abi::x86_64::register64(abi::x86_64::to_int(r))\nfn entry(n: int):\n    r = abi::x86_64::register64(n):\n        on Register64BelowRange:\n            return 0\n        on Register64AboveRange:\n            return 0\n    abi::x86_64::to_int(again(again(r)))\n\nloop x in \[[join [lmap v $inRange {lit $v}] {, }]\]:\n    entry(x)\n"
    set want [list value "\[[join $inRange {, }]\]" {}]
    foreach backend $::backends outcome [outcomes [hirOfText $text]] {
        if {$outcome ne $want} {
            incr failures
            puts "FAIL seed $seed round-trip $backend: [string range $outcome 0 300]"
        }
    }
}
} finally {
    file delete -force $scratch
}
puts "register64-fuzz programs $n values $values out-of-range $outOfRange constant-checks $constantChecks failures $failures"
exit [expr {$failures ? 1 : 0}]
