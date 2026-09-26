# virtual-construction.tcl -- M8.a scaling probes for virtual immutable
# construction (M8A-VIRTUAL-IMMUTABLE-CONSTRUCTION.md).
#
#   tclsh9.0 bench/virtual-construction.tcl [-opt 0|1|default] [-runs N]
#       [-sizes {N ...}] [-markdown] [PROBE ...]
#
# Every probe is ordinary Botlish source whose repeat count N is a runtime
# value: it is passed as an ordinary argument to a self-recursive function
# (the corpus's own "outer recursion drives N repeats" idiom), never unrolled
# or known to any recognizer. Each probe builds one String or List by
# ordinary immutable concatenation (concat / list_append) and observes it
# once at the end (length / list_length), so the program value is an Int
# that is identical for every setting.
#
# -opt selects native::lower::program's -virtual-construction-opt (0 = the
# pre-M8.a eager lowering, 1 = virtual construction); "default" passes no
# flag at all (the only meaningful setting before the flag existed, used to
# pin the pre-implementation baseline).
#
# For every probe and N this prints the program value, best-of-RUNS native
# (Cranelift, specialized) wall time with JIT compilation excluded
# (native::measure), and native::allocationReport's summary: total, String
# and List allocations, private construction-plan allocations (StringPlan/
# ListPlan, M8.a's runtime objects -- 0 when the optimization is off),
# String bytes and List elements copied, and M8.a's own construction
# counters (plan extensions, materializations, bytes/elements copied into
# plans; all 0 when off). Primary evidence is copy volume and allocation
# count, not wall time (spec item 39).

set root [file dirname [file dirname [file normalize [info script]]]]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]

interp recursionlimit {} 2000000

namespace eval vcbench {}

set vcbench::digits {digits = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]}

# PROBE -> {kind description source-template}; %N% is replaced by N.
set vcbench::probes [dict create \
    str_append [list String "acc = concat(acc, \"ab\"), N times" {
fn build(i, n, acc):
    if i >= n:
        return acc
    build(i + 1, n, concat(acc, "ab"))

length(build(0, %N%, ""))
}] \
    str_prepend [list String "acc = concat(\"ab\", acc), N times (reverse_from's shape)" {
fn build(i, n, acc):
    if i >= n:
        return acc
    build(i + 1, n, concat("ab", acc))

length(build(0, %N%, ""))
}] \
    str_helper [list String "acc = concat(acc, piece(i)); piece returns a 3-piece concat" "$vcbench::digits
fn piece(i):
    concat(\"<\", concat(list_get(digits, mod(i, 10)), \">\"))

fn build(i, n, acc):
    if i >= n:
        return acc
    build(i + 1, n, concat(acc, piece(i)))

length(build(0, %N%, \"\"))
"] \
    str_chain3 [list String "acc = concat(acc, c(i)); c/b/a is a 3-level helper chain" "$vcbench::digits
fn a(i):
    concat(\"a\", list_get(digits, mod(i, 10)))

fn b(i):
    concat(a(i), \"b\")

fn c(i):
    concat(b(i), \"c\")

fn build(i, n, acc):
    if i >= n:
        return acc
    build(i + 1, n, concat(acc, c(i)))

length(build(0, %N%, \"\"))
"] \
    str_bind [list String "x = concat(acc, \"a\"); y = concat(x, \"b\"); recurse with y" {
fn build(i, n, acc):
    if i >= n:
        return acc
    x = concat(acc, "a")
    y = concat(x, "b")
    build(i + 1, n, y)

length(build(0, %N%, ""))
}] \
    str_branch [list String "acc extended by one of two branch-local concats" {
fn build(i, n, acc):
    if i >= n:
        return acc
    next = if mod(i, 2) == 0:
        concat(acc, "ab")
    else:
        concat(concat(acc, "c"), "d")
    build(i + 1, n, next)

length(build(0, %N%, ""))
}] \
    list_append [list List "acc = list_append(acc, i), N times" {
fn build(i, n, acc):
    if i >= n:
        return acc
    build(i + 1, n, list_append(acc, i))

list_length(build(0, %N%, []))
}] \
    list_append2 [list List "acc = list_append(list_append(acc, i), i + 1), N/2 times" {
fn build(i, n, acc):
    if i >= n:
        return acc
    build(i + 2, n, list_append(list_append(acc, i), i + 1))

list_length(build(0, %N%, []))
}]]

proc vcbench::source {probe n} {
    variable probes
    return [string map [list %N% $n] [lindex [dict get $probes $probe] 2]]
}

proc vcbench::optArgs {opt} {
    if {$opt eq "default"} {
        return {}
    }
    return [list -virtual-construction-opt $opt]
}

proc vcbench::field {dict args} {
    if {[dict exists $dict {*}$args]} {
        return [dict get $dict {*}$args]
    }
    return 0
}

# {VALUE BEST-US REPORT}: one probe at size N.
proc vcbench::measure {probe n opt runs} {
    set hir [surface::compile [source $probe $n] <$probe>]
    set args [optArgs $opt]
    lassign [native::measure $hir $runs {*}$args] lower compile best collections value
    set report [native::allocationReport $hir summary 1 {*}$args]
    return [list [core::value::show $value 1] $best $report]
}

set opt default
set runs 3
set sizes {1000 2000 4000 8000 16000}
set markdown 0
set selected {}
for {set i 0} {$i < [llength $argv]} {incr i} {
    switch -- [lindex $argv $i] {
        -opt      { set opt [lindex $argv [incr i]] }
        -runs     { set runs [lindex $argv [incr i]] }
        -sizes    { set sizes [lindex $argv [incr i]] }
        -markdown { set markdown 1 }
        default   { lappend selected [lindex $argv $i] }
    }
}
if {$selected eq ""} {
    set selected [dict keys $vcbench::probes]
}

set columns {probe N value us allocs String List plans strBytes listElems planExt planMat}
if {$markdown} {
    puts "| [join $columns { | }] | copy ratio |"
    puts "|[string repeat ---|: [expr {[llength $columns] + 1}]]"
} else {
    puts "virtual-construction probes (-virtual-construction-opt $opt, best of $runs runs)"
    puts [format "%-13s %7s %9s %11s %8s %8s %6s %6s %13s %10s %7s %7s  %s" \
        {*}$columns "copy ratio"]
}
foreach probe $selected {
    set previous ""
    foreach n $sizes {
        lassign [vcbench::measure $probe $n $opt $runs] value best report
        set by [dict get $report byKind]
        set strBytes [dict get $report copies stringBytes]
        set listElems [dict get $report copies listElements]
        set copied [expr {$strBytes + $listElems}]
        set plans [expr {[vcbench::field $by StringPlan allocations] + [vcbench::field $by ListPlan allocations]}]
        set ratio [expr {$previous eq "" || $previous == 0 ? "" : [format %.2fx [expr {double($copied) / $previous}]]}]
        set previous $copied
        set row [list $probe $n $value [format %.1f $best] \
            [dict get $report total allocations] \
            [vcbench::field $by String allocations] [vcbench::field $by List allocations] $plans \
            $strBytes $listElems \
            [vcbench::field $report construction extensions] \
            [vcbench::field $report construction materializations] $ratio]
        if {$markdown} {
            puts "| [join $row { | }] |"
        } else {
            puts [format "%-13s %7s %9s %11s %8s %8s %6s %6s %13s %10s %7s %7s  %s" {*}$row]
        }
    }
}
