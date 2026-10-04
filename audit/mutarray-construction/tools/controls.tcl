#!/usr/bin/env tclsh9.0
# controls.tcl -- positive/negative controls for the strict-contract
# counterfactual (audit/intrinsic-function-contracts/out/variant-all-trusted.
# patch). Each control appends one function to a copy of examples/stdlib/
# csv_records.bot (minus its final sample() call) and reports the
# diagnostics that function alone produces. They isolate where the
# constructor -> container -> projection -> consumer chain breaks; the
# canonical source is never edited. Runs against whatever tree it is
# started in (pwd is the root).
#
#   (cd TREE && tclsh9.0 audit/mutarray-construction/tools/controls.tcl)
set root [pwd]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000

set c [open [file join $root examples stdlib csv_records.bot]]
fconfigure $c -encoding utf-8
set base [read $c]
close $c
set base [string map [list "\nsample()\n" "\n"] $base]
set baseLines [llength [split $base \n]]

set controls [list \
  literal-rows "fn control():\n    headers = \[\"name\", \"age\"\]\n    rows = \[row_table(headers, 2, \[\"A\", \"1\"\], false), row_table(headers, 2, \[\"B\", \"2\"\], false)\]\n    first = list::at(rows, 0)\n    \[ht_get(first, \"name\"), ht_size(first)\]\n" \
  appended-rows "fn control():\n    headers = \[\"name\", \"age\"\]\n    rows = list::append(\[row_table(headers, 2, \[\"A\", \"1\"\], false)\], row_table(headers, 2, \[\"B\", \"2\"\], false))\n    first = list::at(rows, 0)\n    \[ht_get(first, \"name\"), ht_size(first)\]\n" \
  builder-rows "fn control():\n    headers = \[\"name\", \"age\"\]\n    outer = geo_append(geo_new(), row_table(headers, 2, \[\"A\", \"1\"\], false))\n    rows = geo_finish(outer)\n    first = list::at(rows, 0)\n    \[ht_get(first, \"name\"), ht_size(first)\]\n" \
  from-list-rows "fn control():\n    rows = \[mutable_array::from_list(\[1\]), mutable_array::from_list(\[2, 3\])\]\n    first = list::at(rows, 0)\n    \[ht_size(first), mutable_array::capacity(first)\]\n" \
  from-list-fn-rows "fn table(n):\n    mutable_array::from_list(\[n, n\])\nfn control_rows():\n    \[table(1), table(2), table(3)\]\nfn control(i):\n    ht_size(list::at(control_rows(), i))\n" \
  record-pair-boundary "fn cap(m):\n    mutable_array::capacity(m)\nfn mk():\n    \[mutable_array::from_list(\[1\]), 0\]\nfn control():\n    cap(list::at(mk(), 0))\n" \
  record-pair-local "fn cap(m):\n    mutable_array::capacity(m)\nfn control():\n    pair = \[mutable_array::from_list(\[1\]), 0\]\n    cap(list::at(pair, 0))\n" \
]
foreach {name text} $controls {
    set path [file join [file tempdir] control-$name.bot]
    set out [open $path w]
    fconfigure $out -encoding utf-8
    puts -nonewline $out "[surface::modules::ImportHeader "$base\n$text"]$base\n$text"
    close $out
    if {[catch {surface::readProgramFile $path -strict 0} hir]} {
        puts "$name: NOT COMPILED ([string range $hir 0 90])"
        continue
    }
    set mine {}
    foreach d [hir::diagnostics $hir] {
        set loc [surface::originLocation $hir [hir::get $hir [dict get $d expr] origin]]
        set line [lindex [split $loc :] end-1]
        if {$line > $baseLines} { lappend mine "line [expr {$line - $baseLines}]: [string range [dict get $d message] 0 100]" }
    }
    puts "$name: [expr {[llength $mine] ? "REJECTED" : "accepted"}] ([llength $mine] diagnostic(s))"
    foreach m $mine { puts "    $m" }
}
