#!/usr/bin/env tclsh9.0
# controls.tcl -- positive/negative controls for the strict-contract
# counterfactual (audit/intrinsic-function-contracts/out/variant-all-trusted.
# patch), rebuilt on MutableArray[T] (PARAMETERIZED-MUTABLEARRAY.md).
#
# Each control appends functions to a copy of examples/stdlib/csv_records.bot
# (minus its final sample() call) and reports the diagnostics they alone
# produce. They are SCRATCH rewrites of representative builder operations to
# use mutarray::create and MutableArray[T]; the canonical source is never
# edited and none of this is merged. Run it in a tree with
# variant-all-trusted.patch applied (that is the regime whose consumers demand
# a `mutarray`).
#
#   (cd TREE && tclsh9.0 audit/parameterized-mutablearray/tools/controls.tcl)
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

# A typed builder: the storage is a MutableArray[mutarray] threaded next to
# an explicit length (no [storage, length] pair), growth allocates the new
# storage with create (so every slot holds a valid element) and copies.
set typedBuilder {
fn tb_grow(storage: MutableArray[mutarray], length: int, filler: mutarray) -> MutableArray[mutarray]:
    capacity = mutable_array_capacity(storage)
    if length < capacity:
        return storage

    fresh = mutarray::create(geo_new_capacity(capacity, length), filler)
    mutable_array_copy(fresh, 0, storage, 0, length)
    fresh

fn tb_append(storage: MutableArray[mutarray], length: int, value: mutarray) -> MutableArray[mutarray]:
    grown = tb_grow(storage, length, value)
    mutable_array_set(grown, length, value)
    grown
}

set controls [list \
  typed-storage-rows "$typedBuilder\nfn control():\n    headers = \[\"name\", \"age\"\]\n    a = row_table(headers, 2, \[\"A\", \"1\"\], false)\n    b = row_table(headers, 2, \[\"B\", \"2\"\], false)\n    s0 = mutarray::create(0, mutable_array_allocate(0))\n    s1 = tb_append(s0, 0, a)\n    s2 = tb_append(s1, 1, b)\n    rows = mutable_array_freeze(s2, 2)\n    first = list_get(rows, 0)\n    \[ht_get(first, \"name\"), ht_size(first)\]\n" \
  typed-storage-freeze-type "$typedBuilder\nfn control_rows():\n    s0 = mutarray::create(0, mutable_array_allocate(0))\n    s1 = tb_append(s0, 0, mutable_array_allocate(3))\n    mutable_array_freeze(s1, 1)\nfn control(i):\n    ht_size(list_get(control_rows(), i))\n" \
  typed-storage-recursive-build "$typedBuilder\nfn tb_build(records: List\[List\[str\]\], i: int, headers: List\[str\], header_count: int, storage: MutableArray\[mutarray\], length: int, presize):\n    if i >= list_length(records):\n        return mutable_array_freeze(storage, length)\n\n    table = row_table(headers, header_count, list_get(records, i), presize)\n    tb_build(records, i + 1, headers, header_count, tb_append(storage, length, table), length + 1, presize)\nfn control():\n    records = \[\[\"name\", \"age\"\], \[\"A\", \"1\"\], \[\"B\", \"2\"\]\]\n    headers = list_get(records, 0)\n    rows = tb_build(records, 1, headers, list_length(headers), mutarray::create(0, mutable_array_allocate(0)), 0, false)\n    first = list_get(rows, 0)\n    \[ht_get(first, \"name\"), ht_size(first)\]\n" \
  raw-rows-still-valid "fn control():\n    rows = \[mutable_array_allocate(1), mutable_array_allocate(2)\]\n    first = list_get(rows, 0)\n    \[ht_size(first), mutable_array_capacity(first)\]\n" \
  from-list-rows-into-raw-table-consumer "fn control():\n    rows = \[mutarray::from_list(\[1\]), mutarray::from_list(\[2, 3\])\]\n    first = list_get(rows, 0)\n    \[ht_size(first), mutable_array_capacity(first)\]\n" \
  from-list-rows-typed-consumer "fn cap(m: MutableArray\[int\]) -> int:\n    mutable_array_capacity(m)\nfn control():\n    rows = \[mutarray::from_list(\[1\]), mutarray::from_list(\[2, 3\])\]\n    cap(list_get(rows, 0))\n" \
  pair-record-boundary "$typedBuilder\nfn control():\n    s0 = mutarray::create(0, mutable_array_allocate(0))\n    pair = \[tb_append(s0, 0, mutable_array_allocate(1)), 1\]\n    pair\n" \
  untyped-forwarder "$typedBuilder\nfn generic_append(storage, length, value):\n    tb_append(storage, length, value)\nfn control():\n    s0 = mutarray::create(0, mutable_array_allocate(0))\n    generic_append(s0, 0, mutable_array_allocate(1))\n" \
  untyped-raw-writer "fn raw_append(storage, value):\n    mutable_array_set(storage, 0, value)\nfn control():\n    s0 = mutarray::create(1, mutable_array_allocate(0))\n    raw_append(s0, mutable_array_allocate(1))\n" \
  raw-storage-of-typed-rows "fn control():\n    raw = mutable_array_allocate(1)\n    mutable_array_set(raw, 0, mutarray::from_list(\[1\]))\n    raw\n" \
]
foreach {name text} $controls {
    set path [file join [file tempdir] control-$name.bot]
    set out [open $path w]
    fconfigure $out -encoding utf-8
    puts -nonewline $out "$base\n$text"
    close $out
    if {[catch {surface::readProgramFile $path -strict 0} hir]} {
        puts "$name: NOT COMPILED ([string range $hir 0 90])"
        continue
    }
    set mine {}
    foreach d [hir::diagnostics $hir] {
        set loc [surface::originLocation $hir [hir::get $hir [dict get $d expr] origin]]
        set line [lindex [split $loc :] end-1]
        if {$line > $baseLines} { lappend mine "line [expr {$line - $baseLines}]: [string range [dict get $d message] 0 130]" }
    }
    puts "$name: [expr {[llength $mine] ? "REJECTED" : "accepted"}] ([llength $mine] diagnostic(s))"
    foreach m $mine { puts "    $m" }
}
