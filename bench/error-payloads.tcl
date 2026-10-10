# error-payloads.tcl -- the performance report of payload-bearing errors
# (ERROR-PAYLOADS.md, "Performance").
#
#   tclsh9.0 bench/error-payloads.tcl ?-runs N? ?-n N? ?-native-n N?
#                                     ?-backends LIST? ?-payload-free-only 1?
#
# One table, on every backend (Tcl interp, Tcl compile, Cranelift): programs
# that each repeat one operation N times inside a collecting loop, reported
# as time per operation over the program's baseline, (program - baseline) /
# N, the whole program per operation in parentheses (bench/enums.tcl's
# method). The operations: a call of a function that declares an error and
# succeeds (payload-free, and payload-bearing: the success path must not
# care), a failure handled by its caller (payload-free, a one-Int payload, a
# small struct of scalars, a String, a nested struct, an ignored payload, a
# whole binding projected or used as a value, a partial destructuring) and a
# failure propagated across five declaring functions before its handler. A
# second table gives natively the heap allocations of each program
# (Cranelift's counters): a payload travels field-wise, so a failure
# allocates nothing a payload-free one does not, except what its fields are
# themselves (a String built for it, a nested struct) and a whole binding
# used as a value (one struct, built at the handler).
#
# -payload-free-only 1 measures the payload-free programs alone -- the ones
# that also run on the tree before this milestone, for the before/after
# comparison of code that does not use payloads.
#
# Every timed number is best of RUNS in-process executions, compilation
# excluded.

set root [file dirname [file dirname [file normalize [info script]]]]
set args $argv
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
source [file join $root bench backends.tcl]
interp recursionlimit {} 200000

set runs 5
set n 2000
set nativeN 200000
set backends {interp compile native}
set payloadFreeOnly 0
foreach {option value} $args {
    switch -- $option {
        -runs { set runs $value }
        -n { set n $value }
        -native-n { set nativeN $value }
        -backends { set backends $value }
        -payload-free-only { set payloadFreeOnly $value }
        default { error "unknown option $option" }
    }
}

set plainPrelude "import list
import str

error Lost

fn plain_ok(x: int) -> int:
    x

fn plain(x: int) -> int errors Lost:
    if x < 0:
        fail Lost
    x

fn p1(x: int) -> int errors Lost:
    plain(x) + 1

fn p2(x: int) -> int errors Lost:
    p1(x) + 1

fn p3(x: int) -> int errors Lost:
    p2(x) + 1

fn p4(x: int) -> int errors Lost:
    p3(x) + 1

fn p5(x: int) -> int errors Lost:
    p4(x) + 1

"

set payloadPrelude "${plainPrelude}struct Box:
    n: int

error Small:
    code: int

error Scalars:
    code: int
    at: int
    flag: bool

error Text:
    uri: str

error Nested:
    code: int
    box: Box

fn small(x: int) -> int errors Small:
    if x < 0:
        fail Small {code: x}
    x

fn scalars(x: int) -> int errors Scalars:
    if x < 0:
        fail Scalars {code: x, at: x + 1, flag: x < -5}
    x

fn text(x: int) -> int errors Text:
    if x < 0:
        fail Text {uri: \"/missing\"}
    x

fn built(x: int) -> int errors Text:
    if x < 0:
        fail Text {uri: str::concat(\"/a\", \"/b\")}
    x

fn nested(x: int) -> int errors Nested:
    if x < 0:
        fail Nested {code: x, box: Box {n: x}}
    x

fn s1(x: int) -> int errors Small:
    small(x) + 1

fn s2(x: int) -> int errors Small:
    s1(x) + 1

fn s3(x: int) -> int errors Small:
    s2(x) + 1

fn s4(x: int) -> int errors Small:
    s3(x) + 1

fn s5(x: int) -> int errors Small:
    s4(x) + 1

"

# `f(n: int, sign: int) -> int`: a collecting loop of N iterations whose
# body is BODY (lines, the iteration's value last), the List's length; run
# as f(N, SIGN). SIGN -1 makes every call of a fallible function fail (its
# argument `sign * (i + 1)` is negative), 1 makes it succeed: a run-time
# value, so no call is statically known to fail.
proc Loop {prelude n sign body} {
    set text "${prelude}fn f(n: int, sign: int) -> int:\n    xs = loop i from 0 to n:\n        x = sign * (i + 1)\n"
    foreach line $body {
        append text "        $line\n"
    }
    append text "    list::length(xs)\n\nf($n, $sign)\n"
    return $text
}

proc programText {kind n} {
    set plain $::plainPrelude
    set rich $::payloadPrelude
    switch -- $kind {
        base          { return [Loop $plain $n -1 {x}] }
        ok-plain-base { return [Loop $plain $n 1 {"plain_ok(x)"}] }
        ok-plain      { return [Loop $plain $n 1 {"plain(x):" "    on Lost:" "        0"}] }
        fail-plain    { return [Loop $plain $n -1 {"plain(x):" "    on Lost:" "        0"}] }
        fail-plain-5  { return [Loop $plain $n -1 {"p5(x):" "    on Lost:" "        0"}] }
        rich-base     { return [Loop $rich $n -1 {x}] }
        ok-small      { return [Loop $rich $n 1 {"small(x):" "    on Small {code}:" "        code"}] }
        fail-small    { return [Loop $rich $n -1 {"small(x):" "    on Small {code}:" "        code"}] }
        fail-small-ignored { return [Loop $rich $n -1 {"small(x):" "    on Small:" "        0"}] }
        fail-scalars  { return [Loop $rich $n -1 {"scalars(x):" "    on Scalars {code, at}:" "        code + at"}] }
        fail-text     { return [Loop $rich $n -1 {"text(x):" "    on Text {uri}:" "        str::length(uri)"}] }
        fail-built    { return [Loop $rich $n -1 {"built(x):" "    on Text {uri}:" "        str::length(uri)"}] }
        fail-nested   { return [Loop $rich $n -1 {"nested(x):" "    on Nested {box: {n}}:" "        n"}] }
        fail-whole-projected { return [Loop $rich $n -1 {"scalars(x):" "    on Scalars details:" "        details.code"}] }
        fail-whole-value { return [Loop $rich $n -1 {"v = scalars(x):" "    on Scalars details:" "        d = \[details\]" "        list::length(d)" "v"}] }
        fail-partial  { return [Loop $rich $n -1 {"scalars(x):" "    on Scalars {at}:" "        at"}] }
        fail-small-5  { return [Loop $rich $n -1 {"s5(x):" "    on Small {code}:" "        code"}] }
        default { error "unknown program $kind" }
    }
}

proc program {kind n} {
    return [surface::compile [programText $kind $n] -warnings off]
}

# Best-of-RUNS microseconds of HIR on BACKEND (interp, compile, native).
proc timeOn {backend hir} {
    if {$backend eq "native"} {
        lassign [native::measure $hir $::runs] lower compile best collections value
        return $best
    }
    set program [hir::lower $hir]
    core::useBackend $backend
    core::evalProgram $program
    set best ""
    for {set i 0} {$i < $::runs} {incr i} {
        set micros [lindex [time {core::evalProgram $program}] 0]
        if {$best eq "" || $micros < $best} {
            set best $micros
        }
    }
    return $best
}

proc nOf {backend} {
    return [expr {$backend eq "native" ? $::nativeN : $::n}]
}

# {DELTA WHOLE} nanoseconds per operation of KIND over BASE.
proc perOp {kind base backend} {
    set n [nOf $backend]
    set t [timeOn $backend [program $kind $n]]
    set b [timeOn $backend [program $base $n]]
    return [list [expr {($t - $b) * 1000.0 / $n}] [expr {$t * 1000.0 / $n}]]
}

proc ns {x} {
    return [format "%.1f ns" $x]
}

set plainOperations {
    "payload-free: declaring call, success" ok-plain ok-plain-base
    "payload-free: failure, handled by the caller" fail-plain base
    "payload-free: failure propagated across 5 calls" fail-plain-5 base
}
set payloadOperations {
    "payload-bearing: declaring call, success" ok-small ok-plain-base
    "one-Int payload: failure, destructured" fail-small rich-base
    "one-Int payload: failure, payload ignored" fail-small-ignored rich-base
    "3 scalar fields: failure, 2 destructured" fail-scalars rich-base
    "3 scalar fields: whole binding, projected" fail-whole-projected rich-base
    "3 scalar fields: whole binding used as a value" fail-whole-value rich-base
    "3 scalar fields: partial destructuring (1 field)" fail-partial rich-base
    "String field (a constant)" fail-text rich-base
    "String field (built per failure)" fail-built rich-base
    "nested struct field, nested destructuring" fail-nested rich-base
    "one-Int payload: failure propagated across 5 calls" fail-small-5 rich-base
}
set operations [expr {$payloadFreeOnly ? $plainOperations : [concat $plainOperations $payloadOperations]}]

puts "Error payloads: performance (n = $n operations per program on the Tcl backends, $nativeN natively; best of $runs runs)\n"
puts [bench::backends::manifest $backends]
puts ""
puts "## Operations\n"
puts "| operation | baseline | [join [lmap b $backends {bench::backends::displayName $b}] { | }] |"
puts "|---|---|[string repeat ---:| [llength $backends]]"
foreach {label kind base} $operations {
    set cells {}
    foreach backend $backends {
        lassign [perOp $kind $base $backend] delta whole
        lappend cells "[ns $delta] ([ns $whole])"
    }
    puts "| $label | $base | [join $cells { | }] |"
}

if {"native" in $backends} {
    puts "\n## Native allocations\n"
    puts "Heap allocations of each whole program (Cranelift's counters), N = $nativeN.\n"
    puts "| program | allocations | Structs | Strings | bytes |"
    puts "|---|---:|---:|---:|---:|"
    set seen {}
    foreach {label kind base} $operations {
        foreach k [list $base $kind] {
            if {$k in $seen} continue
            lappend seen $k
            set report [native::allocationReport [program $k $nativeN] summary]
            puts "| $k | [dict get $report total allocations] | [dict get $report byKind Struct allocations] | [dict get $report byKind String allocations] | [dict get $report total allocatedBytes] |"
        }
    }
}
