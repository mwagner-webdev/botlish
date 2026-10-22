# hashable.tcl -- the performance report of the public and the private
# keyed hash (HASHABLE-AND-KEYED-HASH.md, "Performance").
#
#   tclsh9.0 bench/hashable.tcl ?-runs N? ?-n N? ?-native-n N? ?-backends LIST?
#                               ?-keyed 0|1?
#
# Programs that each hash one kind of value N times inside a collecting loop,
# reported as time per hash over the program that builds the same value
# without hashing it, (program - baseline) / N, the whole program per
# iteration in parentheses (bench/enums.tcl's method): an Int, a String, a
# two-field struct and a nested struct, through the public `hash` and
# through the private keyed table hash. The keyed hash is reached the only
# way it can be, from a standard library module: a private copy of lib/ gets
# a module `hashbench` that calls it (tests/helpers.tcl's withPrivateLibrary
# does the same). A second table gives natively each program's heap
# allocations (Cranelift's allocation counters): hashing allocates nothing.
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
set keyed 1
foreach {option value} $args {
    switch -- $option {
        -runs { set runs $value }
        -n { set n $value }
        -native-n { set nativeN $value }
        -backends { set backends $value }
        -keyed { set keyed $value }
        default { error "unknown option $option" }
    }
}

# The private library: lib/ plus the module hashbench, which reaches the
# keyed hash.
set library [file join [file tempdir] lib]
file copy [file join $root lib] $library
set f [open [file join $library hashbench.bot] w]
puts $f {import table_hash

fn keyed(x: Hashable) -> int:
    table_hash::of(x)}
close $f
set ::core::libraryDir $library

set prelude "import list
[if {$keyed} {string cat "import hashbench"}]

struct P:
    x: int
    y: int

struct Q:
    p: P
    name: str
    tag: int

"

# A program that builds N values with the expression VALUE (of `i` and the
# String parameter `s`) into a List, then maps OP over them -- `v` itself for
# a baseline, `hash(v)` or the table hash for a measurement -- so the values
# exist (are materialized) before anything hashes them, and an operation's
# time and allocations over its baseline are the hash's alone.
proc Program {n value op} {
    return [string cat $::prelude "fn f(n: int, s: str) -> int:
    vals = loop i from 0 to n:
        $value
    xs = loop v in vals:
        $op
    list::length(xs)

f($n, \"session-key-0042\")
"]
}

proc programText {kind n} {
    set values {int i str "s" struct "P {x: i, y: 7}" nested "Q {p: P {x: i, y: 7}, name: s, tag: 3}"}
    lassign [split $kind -] what value
    set op [dict get {base v hash hash(v) keyed hashbench::keyed(v)} $what]
    return [Program $n [dict get $values $value] $op]
}

proc program {kind n} {
    return [surface::compile [programText $kind $n] -warnings off]
}

proc timeOn {backend hir} {
    if {$backend eq "native"} {
        lassign [native::measure $hir $::runs] lower compile best collections value
        return $best
    }
    if {$backend eq "compile"} {
        set unit [core::compiler::compileHir $hir]
        set run {core::compiler::evalUnit $unit}
    } else {
        set program [hir::lower $hir]
        core::useBackend $backend
        set run {core::evalProgram $program}
    }
    eval $run
    set best ""
    for {set i 0} {$i < $::runs} {incr i} {
        set micros [lindex [time $run] 0]
        if {$best eq "" || $micros < $best} {
            set best $micros
        }
    }
    return $best
}

proc nOf {backend} {
    return [expr {$backend eq "native" ? $::nativeN : $::n}]
}

proc perOp {kind base backend} {
    set n [nOf $backend]
    set t [timeOn $backend [program $kind $n]]
    set b [timeOn $backend [program $base $n]]
    return [list [expr {($t - $b) * 1000.0 / $n}] [expr {$t * 1000.0 / $n}]]
}

set operations {
    "hash(Int)" hash-int base-int
    "hash(String), 16 bytes" hash-str base-str
    "hash(simple struct)" hash-struct base-struct
    "hash(nested struct)" hash-nested base-nested
}
if {$keyed} {
    lappend operations \
        "table hash(Int)" keyed-int base-int \
        "table hash(String), 16 bytes" keyed-str base-str \
        "table hash(simple struct)" keyed-struct base-struct \
        "table hash(nested struct)" keyed-nested base-nested
}

try {
    puts [bench::backends::manifest $backends]
    puts ""
    puts "Time per operation, ns, over its baseline (whole program per iteration in parentheses); N = $n on the Tcl backends, $nativeN natively, best of $runs"
    puts ""
    set header "| operation |"
    set rule "|---|"
    foreach backend $backends {
        append header " [bench::backends::displayName $backend] |"
        append rule "---:|"
    }
    puts $header
    puts $rule
    foreach {label kind base} $operations {
        set row "| $label |"
        foreach backend $backends {
            lassign [perOp $kind $base $backend] delta whole
            append row [format " %.1f (%.1f) |" $delta $whole]
        }
        puts $row
    }
    if {"native" in $backends} {
        puts ""
        puts "Heap allocations natively (Cranelift's counters), N = 1000"
        puts ""
        puts "| program | allocations | over baseline |"
        puts "|---|---:|---:|"
        foreach {label kind base} $operations {
            set a [dict get [native::allocationReport [program $kind 1000] summary] total allocations]
            set b [dict get [native::allocationReport [program $base 1000] summary] total allocations]
            puts "| $label | $a | [expr {$a - $b}] |"
        }
    }
} finally {
    file delete -force [file dirname $library]
}
