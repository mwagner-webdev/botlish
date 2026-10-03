#!/usr/bin/env tclsh9.0
# workloads.tcl -- allocation, NIR-op, codegen and timing measurements of the
# geometric-builder workloads (csv_geometric, csv_records default/presized).
# Observation only: runs against whatever tree it is started in (pwd is the
# root), so the same script measures the fence commit and the refactored tree.
#
#   (cd TREE && tclsh9.0 audit/typed-mutarray-builder-refactor/tools/workloads.tcl OUTFILE ?RUNS?)
#
# Per workload: the allocation summary (native::allocationReport, the last
# of RUNS timed runs), the NIR statement census (mutarray*/list*/guard/call
# counts, function and parameter counts), machine-code bytes
# (native::codeSize) and best-of-RUNS native execution time
# (native::measure), all in the same process and build mode (specialized
# cranelift), same deterministic input.
set root [pwd]
source [file join $root examples stdlib corpus.tcl]
interp recursionlimit {} 4000000
lassign $argv outfile runs
if {$runs eq ""} { set runs 15 }

proc csvText {rows} {
    set lines [list {id,name,note,amount}]
    for {set i 1} {$i <= $rows} {incr i} {
        lappend lines [format {%d,user%d,"note %d, says ""hi""",%d} $i $i $i [expr {($i * 37) % 1000}]]
    }
    return "[join $lines \n]\n"
}
proc genCsv {rows cols} {
    set headers {}
    for {set j 0} {$j < $cols} {incr j} { lappend headers "column$j" }
    set lines [list [join $headers ,]]
    for {set i 0} {$i < $rows} {incr i} {
        set fields {}
        for {set j 0} {$j < $cols} {incr j} { lappend fields "r${i}c${j}" }
        lappend lines [join $fields ,]
    }
    return "[join $lines \n]\n"
}

set workloads [list \
    [list csv_geometric_100   csv_geometric "csv_parse([corpus::literal [csvText 100]])"] \
    [list csv_geometric_1000  csv_geometric "csv_parse([corpus::literal [csvText 1000]])"] \
    [list csv_geometric_10000 csv_geometric "csv_parse([corpus::literal [csvText 10000]])"] \
    [list csv_records_1000x5  csv_records "list::length(csv_records([corpus::literal [genCsv 1000 5]]))"] \
    [list csv_records_1000x20 csv_records "list::length(csv_records([corpus::literal [genCsv 1000 20]]))"] \
    [list csv_records_presized_1000x20 csv_records "list::length(csv_records_presized([corpus::literal [genCsv 1000 20]]))"] \
    [list csv_records_10000x5 csv_records "list::length(csv_records([corpus::literal [genCsv 10000 5]]))"] \
    [list csv_records_sample csv_records "sample()"]]

set out {}
foreach w $workloads {
    lassign $w label name driver
    lappend out "== $label"
    set hir [corpus::driven $name $driver]
    lassign [native::measure $hir $runs] lower jit best - value
    set shown [core::value::show $value 1]
    lappend out [format "value: length %d crc %d" [string length $shown] [zlib crc32 [encoding convertto utf-8 $shown]]]
    lappend out [format "native best-of-%d us: %.2f  (jit compile us: %s)" $runs $best $jit]
    set report [native::allocationReport $hir summary 1]
    set total [dict get $report total]
    lappend out "alloc total: [dict get $total allocations] allocations, [dict get $total allocatedBytes] bytes, peak [dict get $total peakLiveBytes]"
    lappend out "gc cycles: [dict get $report gc cycles]"
    lappend out "copies: [dict get $report copies]"
    foreach kind [lsort [dict keys [dict get $report byKind]]] {
        lappend out "byKind $kind: [dict get $report byKind $kind]"
    }
    set lowered [native::lower::program $hir]
    set text [dict get $lowered text]
    lappend out "emitted functions: [llength [dict get $lowered functions]]"
    lappend out "machine code bytes: [lindex [native::codeSize $hir] 0]"
    lappend out "nir lines: [llength [split $text \n]]"
    foreach op {mutarrayallocate mutarrayset mutarrayget mutarraycopy mutarrayfreeze mutarraycapacity listnew listget listlength listappend} {
        lappend out [format "nir op %-18s %d" $op [regexp -all "op $op " $text]]
    }
    lappend out "nir guard/guardbool: [regexp -all -line {^\s+guard(bool)? } $text]"
    lappend out "nir call: [regexp -all -line {^\s+%\d+ = call } $text]  callvalue: [regexp -all {callvalue} $text]"
    lappend out "nir retmulti: [regexp -all {retmulti} $text]"
    foreach fn {geo_new geo_grow geo_append geo_finish geo_new_capacity scan_record scan_records scan_record_tail csv_parse build_rows csv_records_generic} {
        foreach m [regexp -all -inline -line "^func \\d+ \"$fn\" .*\$" $text] {
            regexp {func (\d+) "([^"]+)" params=(\d+).*?instance="([^"]*)"} $m -> id fname params inst
            lappend out "  fn $fname/$id params=$params instance=<$inst>"
        }
    }
}
set f [open $outfile w]
puts $f [join $out \n]
close $f
puts "wrote $outfile"
