#!/usr/bin/env tclsh9.0
# workloads.tcl -- M8.a frozen-workload before/after table
# (M8A-VIRTUAL-IMMUTABLE-CONSTRUCTION.md, "Frozen workload timing
# before/after"). Observation only.
#
#   tclsh9.0 audit/m8a-virtual-construction/tools/workloads.tcl \
#       [-runs N] [-sessions N] [-markdown] [WORKLOAD ...]
#
# For every workload, with -virtual-construction-opt 0 and 1 (identical
# source, identical binary): the program value (must agree), the median over
# SESSIONS independent native::measure sessions of the best of RUNS runs
# (JIT compilation excluded -- the repository's established methodology,
# bench/uri-steady.tcl), native::allocationReport's totals (allocations,
# bytes, String/List/private-plan allocations, String bytes and List
# elements copied), machine-code bytes, NIR function count and guard count
# (cranelift, specialized).
#
# Workloads use the corpus's own benchmark drivers (bench/corpus.tcl's
# deterministic inputs, reproduced here), the two frozen URI benchmarks, and
# three concat-free controls.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
source [file join $root examples stdlib corpus.tcl]
interp recursionlimit {} 2000000

namespace eval wl {}

# bench/corpus.tcl's deterministic inputs.
proc wl::text {n} {
    set alphabet abcdefghijklmnopqrstuvwxyz0123456789
    return [string range [string repeat $alphabet [expr {$n / [string length $alphabet] + 1}]] 0 [expr {$n - 1}]]
}
proc wl::prose {n} {
    set sentence "the quick brown fox jumps over the lazy dog. "
    return [string range [string repeat $sentence [expr {$n / [string length $sentence] + 1}]] 0 [expr {$n - 1}]]
}
proc wl::csv {rows} {
    set lines [list {id,name,note,amount}]
    for {set i 1} {$i <= $rows} {incr i} {
        lappend lines [format {%d,user%d,"note %d, says ""hi""",%d} $i $i $i [expr {($i * 37) % 1000}]]
    }
    return "[join $lines \n]\n"
}
proc wl::matrix {n seed} {
    set rows {}
    for {set i 0} {$i < $n} {incr i} {
        set row {}
        for {set j 0} {$j < $n} {incr j} {
            lappend row [expr {(($i * 7 + $j * $seed + $seed) % 19) - 9}]
        }
        lappend rows "\[[join $row {, }]\]"
    }
    return "\[[join $rows {, }]\]"
}
# bench/ai_text_clean.tcl's fixture families, cycled to N characters.
proc wl::aiText {family n} {
    set sentence [dict get {
        ascii "The model generated this sentence. It contains ordinary ASCII text and no special punctuation or emoji at all. "
        emoji "\U0001F916 “Here’s the 東京 report—it’s ready…” \U0001F680 Grüße from München. "
    } $family]
    set text [string repeat $sentence [expr {$n / [string length $sentence] + 1}]]
    return [string range $text 0 [expr {$n - 1}]]
}

# WORKLOAD -> script returning its HIR.
set wl::workloads [dict create \
    uri-steady {surface::readProgramFile [file join $::root bench uri-steady.bot]} \
    refined-checks {core::loadLibrary web; native::prepareHir [hir::build [core::loadProgramFile [file join $::root bench refined-checks.ir]] -strict 0]} \
    ai_text_clean/ascii-100K {corpus::program ai_text_clean "clean_ai_text([corpus::literal [wl::aiText ascii 100000]])"} \
    ai_text_clean/emoji-100K {corpus::program ai_text_clean "clean_ai_text([corpus::literal [wl::aiText emoji 100000]])"} \
    ai_text_clean/ascii-10K {corpus::program ai_text_clean "clean_ai_text([corpus::literal [wl::aiText ascii 10000]])"} \
    string_reverse/10K {corpus::program string_reverse "reverse_chars([corpus::literal [wl::text 10000]])"} \
    string_replace/100KB {corpus::program string_replace "replace([corpus::literal [wl::prose 100000]], \"fox\", \"red panda\")"} \
    csv/10000 {corpus::program csv "csv_parse([corpus::literal [wl::csv 10000]])"} \
    csv_geometric/10000 {corpus::program csv_geometric "csv_parse([corpus::literal [wl::csv 10000]])"} \
    csv_chunked/10000 {corpus::program csv_chunked "csv_parse([corpus::literal [wl::csv 10000]])"} \
    matmul/32x32 {corpus::program matmul "matmul([wl::matrix 32 3], [wl::matrix 32 5])"} \
    fib {native::prepareHir [hir::build [core::loadProgramFile [file join $::root bench fib.ir]] -strict 0]} \
    loop-count {native::prepareHir [hir::build [core::loadProgramFile [file join $::root bench loop-count.ir]] -strict 0]} \
    sum-refined {native::prepareHir [hir::build [core::loadProgramFile [file join $::root bench sum-refined.ir]] -strict 0]}]

proc wl::row {hir opt runs sessions} {
    set args [list -virtual-construction-opt $opt]
    set bests {}
    set value ""
    for {set s 0} {$s < $sessions} {incr s} {
        lassign [native::measure $hir $runs {*}$args] lower compile best collections value
        lappend bests $best
    }
    set bests [lsort -real $bests]
    set median [lindex $bests [expr {[llength $bests] / 2}]]
    set report [native::allocationReport $hir summary 1 {*}$args]
    set by [dict get $report byKind]
    set lowered [native::lower::program $hir {*}$args]
    set text [dict get $lowered text]
    lassign [native::codeSize $hir {*}$args] bytes
    return [dict create value [core::value::show $value 1] median $median min [lindex $bests 0] max [lindex $bests end] \
        allocs [dict get $report total allocations] bytes [dict get $report total allocatedBytes] \
        String [dict get $by String allocations] List [dict get $by List allocations] \
        plans [expr {[dict get $by StringPlan allocations] + [dict get $by ListPlan allocations]}] \
        strCopied [dict get $report copies stringBytes] listCopied [dict get $report copies listElements] \
        code $bytes functions [llength [dict get $lowered functions]] \
        guards [regexp -all -line {^\s+guard(bool)? } $text] \
        materializations [dict get $report construction materializations]]
}

proc wl::us {x} {
    if {$x >= 1000} {
        return [format "%.2f ms" [expr {$x / 1000.0}]]
    }
    return [format "%.1f us" $x]
}

set runs 5
set sessions 5
set markdown 0
set selected {}
for {set i 0} {$i < [llength $argv]} {incr i} {
    switch -- [lindex $argv $i] {
        -runs     { set runs [lindex $argv [incr i]] }
        -sessions { set sessions [lindex $argv [incr i]] }
        -markdown { set markdown 1 }
        default   { lappend selected [lindex $argv $i] }
    }
}
if {$selected eq ""} {
    set selected [dict keys $wl::workloads]
}

puts "M8.a frozen workloads: median of $sessions sessions x best of $runs runs (JIT excluded), cranelift specialized"
if {$markdown} {
    puts "| workload | opt | value | median | speedup | allocs | bytes | String | List | plans | str bytes copied | list elems copied | code bytes | fns | guards |"
    puts "|---|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|"
}
foreach name $selected {
    set hir [eval [dict get $wl::workloads $name]]
    set off [wl::row $hir 0 $runs $sessions]
    set on [wl::row $hir 1 $runs $sessions]
    if {[dict get $off value] ne [dict get $on value]} {
        puts "VALUE MISMATCH $name: off [dict get $off value] on [dict get $on value]"
    }
    set value [dict get $on value]
    if {[string length $value] > 24} {
        set value "[string range $value 0 20]... ([string length $value] chars, equal)"
    }
    set speedup [format %.2fx [expr {[dict get $off median] / max(0.001, [dict get $on median])}]]
    foreach {opt r} [list 0 $off 1 $on] {
        set cells [list $name $opt $value [wl::us [dict get $r median]] [expr {$opt ? $speedup : ""}] \
            [dict get $r allocs] [dict get $r bytes] [dict get $r String] [dict get $r List] [dict get $r plans] \
            [dict get $r strCopied] [dict get $r listCopied] [dict get $r code] [dict get $r functions] [dict get $r guards]]
        if {$markdown} {
            puts "| [join $cells { | }] |"
        } else {
            puts [format "%-24s %s %-18s %11s %7s %9s %11s %8s %7s %6s %12s %10s %6s %4s %3s" {*}$cells]
        }
    }
    flush stdout
}
