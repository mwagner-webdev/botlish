#!/usr/bin/env tclsh9.0
# fuzz.tcl -- randomized differential check of the ABI numeric domains
# (ABI-NUMERIC-DOMAINS.md): abi::i8 ... abi::usize, .value, and the
# abi::x86_64::from_* register encoders, for all ten domains.
#
#   tclsh9.0 audit/abi-numeric-domains/tools/fuzz.tcl ?-n N? ?-seed S?
#       ?-values V? ?-backends LIST? ?-gc-stress 0|1?
#
# No syscall is ever made: only the pure conversions are fuzzed.
#
# Each program (seeded individually: a failure replays with `-seed S -n 1`)
# draws, for every domain, V Ints strongly biased toward that domain's
# boundaries -- min-1, min, min+1, -1, 0, 1, max-1, max, max+1, and the
# 2^63 transition (2^63-1, 2^63, 2^63+1, 2^64-1, -2^63, -2^63-1) -- plus
# uniform values inside the domain, arbitrary 64-bit patterns read signed
# and unsigned, and arbitrary BigInts up to 2^100 either sign; and checks,
# against an independent oracle (Tcl's own arbitrary-precision comparisons
# with the domain's bounds):
#
#   dynamic     every backend runs the creator on each value from a List
#               (nothing statically known): an in-range value comes back
#               through .value unchanged and encodes as its register word
#               (sign extension for signed domains; zero extension for
#               unsigned ones -- the same 64 bits read signed); an
#               out-of-range value is exactly AbiIntegerBelowRange /
#               AbiIntegerAboveRange -- never truncated or wrapped
#   constant    one value per domain written as a literal argument: in range
#               needs no handler at all, out of range is the compile-time
#               KNOWN-ERROR naming the violated bound
#   round trip  in-range values through a typed parameter of the ABI type,
#               re-created from .value with no handler (the field's domain
#               proves it), twice, then encoded -- on every backend
#   narrowing   values of one random domain narrowed into another through
#               Int (`abi::t(s.value)`), against the target's oracle
#
# The run ends with "abi-numeric-fuzz programs N values V out-of-range O
# constant-checks C failures F"; the exit status is 1 if F is not zero.
set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set args $argv
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
interp recursionlimit {} 100000

set n 20
set seed0 1
set valueCount 24
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

# struct creator encoder min max signed
set family {
    I8    i8    from_i8    -128                  127                  1
    I16   i16   from_i16   -32768                32767                1
    I32   i32   from_i32   -2147483648           2147483647           1
    I64   i64   from_i64   -9223372036854775808  9223372036854775807  1
    U8    u8    from_u8    0                     255                  0
    U16   u16   from_u16   0                     65535                0
    U32   u32   from_u32   0                     4294967295           0
    U64   u64   from_u64   0                     18446744073709551615 0
    Isize isize from_isize -9223372036854775808  9223372036854775807  1
    Usize usize from_usize 0                     18446744073709551615 0
}

# Program files live in a fresh system temporary directory, removed however
# the run ends (never inside the checkout).
set scratch [file tempdir abi-numeric-fuzz]
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

# The oracle: "below"/"above", or [V, WORD] -- V, and the signed reading of
# the 64-bit pattern it travels as.
proc oracle {min max signed v} {
    if {$v < $min} { return "\"below\"" }
    if {$v > $max} { return "\"above\"" }
    set word [expr {!$signed && $v >= 2**63 ? $v - 2**64 : $v}]
    if {$word < -2**63 || $word >= 2**63} {
        error "oracle: $v has no 64-bit word"
    }
    return "\[$v, $word\]"
}

proc lit {v} {
    return [expr {$v < 0 ? "0 - [expr {-$v}]" : $v}]
}

proc random64 {} {
    return [expr {int(rand() * 2**32) * 2**32 + int(rand() * 2**32)}]
}

proc draw {min max} {
    switch -- [expr {int(rand() * 7)}] {
        0 - 1 - 2 {
            # Boundary clusters: the domain's own, and the universal ones.
            set anchors [list [expr {$min - 1}] $min [expr {$min + 1}] -1 0 1 \
                [expr {$max - 1}] $max [expr {$max + 1}]]
            if {rand() < 0.3} {
                set anchors [list [expr {2**63 - 1}] [expr {2**63}] [expr {2**63 + 1}] \
                    [expr {2**64 - 1}] [expr {2**64}] [expr {-2**63}] [expr {-2**63 - 1}]]
            }
            return [lindex $anchors [expr {int(rand() * [llength $anchors])}]]
        }
        3 {
            # Uniform inside the domain.
            set r [expr {[random64] * 2**32 + int(rand() * 2**32)}]
            return [expr {$min + $r % ($max - $min + 1)}]
        }
        4 {
            # An arbitrary 64-bit pattern, read unsigned or signed.
            set u [random64]
            return [expr {rand() < 0.5 ? $u : ($u >= 2**63 ? $u - 2**64 : $u)}]
        }
        5 {
            # An arbitrary BigInt up to 2^100, either sign.
            set bits [expr {int(rand() * 101)}]
            set v [expr {([random64] * 2**64 + [random64]) % (2**$bits + 1)}]
            return [expr {rand() < 0.5 ? -$v : $v}]
        }
        6 {
            return [expr {int(rand() * 600) - 300}]
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
    set functions ""
    set bindings ""
    set results {}
    set expected {}
    set roundTripExpected {}
    set roundTripBindings ""
    set constants {}
    set index 0
    foreach {s ctor enc min max signed} $family {
        set xs {}
        for {set i 0} {$i < $valueCount} {incr i} {
            lappend xs [draw $min $max]
        }
        incr values [llength $xs]
        set want [lmap v $xs {oracle $min $max $signed $v}]
        incr outOfRange [llength [lsearch -all -glob $want {"*}]]
        lappend expected "\[[join $want {, }]\]"
        append functions "fn c$index\(n: int):
    x = abi::${ctor}(n):
        on AbiIntegerBelowRange:
            return \"below\"
        on AbiIntegerAboveRange:
            return \"above\"
    \[x.value, abi::x86_64::${enc}(x).word\]

fn again$index\(x: abi::$s) -> abi::$s:
    abi::${ctor}(x.value)

fn rt$index\(n: int):
    x = abi::${ctor}(n):
        on AbiIntegerBelowRange:
            return \"below\"
        on AbiIntegerAboveRange:
            return \"above\"
    y = again$index\(again$index\(x))
    \[y.value, abi::x86_64::${enc}(y).word\]

"
        append bindings "r$index = loop v in \[[join [lmap v $xs {lit $v}] {, }]\]:\n    c$index\(v)\n"
        set inRange [lmap v $xs {expr {$v >= $min && $v <= $max ? $v : [continue]}}]
        append roundTripBindings "t$index = loop v in \[[join [lmap v $inRange {lit $v}] {, }]\]:\n    rt$index\(v)\n"
        lappend roundTripExpected "\[[join [lmap v $inRange {oracle $min $max $signed $v}] {, }]\]"
        lappend results r$index
        lappend constants [list $ctor $min $max [lindex $xs [expr {int(rand() * [llength $xs])}]]]
        incr index
    }

    # dynamic + round trip: one program for all ten domains
    set text "$functions$bindings$roundTripBindings\[\[[join $results {, }]\], \[[join [lmap r $results {string map {r t} $r}] {, }]\]\]\n"
    set want [list value "\[\[[join $expected {, }]\], \[[join $roundTripExpected {, }]\]\]" {}]
    if {[catch {outcomes [hirOfText $text]} got]} {
        incr failures
        puts "FAIL seed $seed dynamic/round-trip: compile: $got"
    } else {
        foreach backend $::backends outcome $got {
            if {$outcome ne $want} {
                incr failures
                puts "FAIL seed $seed dynamic/round-trip $backend: [string range $outcome 0 400]"
            }
        }
    }

    # narrowing: values of a random source domain into a random target
    # domain, through Int
    set from [expr {int(rand() * 10)}]
    set to [expr {int(rand() * 10)}]
    lassign [lrange $family [expr {$from * 6}] [expr {$from * 6 + 5}]] fs fctor fenc fmin fmax fsigned
    lassign [lrange $family [expr {$to * 6}] [expr {$to * 6 + 5}]] ts tctor tenc tmin tmax tsigned
    set xs [lmap i [lrange {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15} 0 [expr {$valueCount / 2}]] {
        set v [draw $fmin $fmax]
        expr {$v >= $fmin && $v <= $fmax ? $v : $fmin}
    }]
    incr values [llength $xs]
    set text "fn narrow(x: abi::$fs):\n    y = abi::${tctor}(x.value):\n        on AbiIntegerBelowRange:\n            return \"below\"\n        on AbiIntegerAboveRange:\n            return \"above\"\n    \[y.value, abi::x86_64::${tenc}(y).word\]\nfn entry(n: int):\n    x = abi::${fctor}(n):\n        on AbiIntegerBelowRange:\n            return \"unreachable\"\n        on AbiIntegerAboveRange:\n            return \"unreachable\"\n    narrow(x)\nloop v in \[[join [lmap v $xs {lit $v}] {, }]\]:\n    entry(v)\n"
    set narrowed [lmap v $xs {oracle $tmin $tmax $tsigned $v}]
    set want [list value "\[[join $narrowed {, }]\]" {}]
    if {[catch {outcomes [hirOfText $text]} got]} {
        incr failures
        puts "FAIL seed $seed narrowing $fs->$ts: compile: $got"
    } else {
        foreach backend $::backends outcome $got {
            if {$outcome ne $want} {
                incr failures
                puts "FAIL seed $seed narrowing $fs->$ts $backend: [string range $outcome 0 300]"
            }
        }
    }

    # constant: one literal per domain
    foreach c $constants {
        lassign $c ctor min max v
        incr constantChecks
        if {[catch {hirOfText "abi::${ctor}([lit $v]).value\n" 0} hir]} {
            incr failures
            puts "FAIL seed $seed constant abi::${ctor}($v): compile: $hir"
            continue
        }
        set kinds [lsort -unique [lmap d [hir::diagnostics $hir] {dict get $d kind}]]
        set want [expr {$v < $min || $v > $max ? "KNOWN-ERROR" : ""}]
        if {$kinds ne $want} {
            incr failures
            puts "FAIL seed $seed constant abi::${ctor}($v): diagnostics {$kinds}, expected {$want}"
        } elseif {$want eq "KNOWN-ERROR"} {
            set message [dict get [lindex [hir::diagnostics $hir] 0] message]
            set error [expr {$v < $min ? "AbiIntegerBelowRange" : "AbiIntegerAboveRange"}]
            # The complete list of errors named, up to its ";".
            if {![string match "*declared error(s) $error;*" $message]} {
                incr failures
                puts "FAIL seed $seed constant abi::${ctor}($v): $message"
            }
        } else {
            set outcome [outcomeUnderHir interp $hir]
            if {$outcome ne [list value $v {}]} {
                incr failures
                puts "FAIL seed $seed constant abi::${ctor}($v): $outcome"
            }
        }
    }
}
} finally {
    file delete -force $scratch
}
puts "abi-numeric-fuzz programs $n values $values out-of-range $outOfRange constant-checks $constantChecks failures $failures"
exit [expr {$failures ? 1 : 0}]
