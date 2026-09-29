#!/usr/bin/env tclsh9.0
# trace.tcl -- provenance chain of the MutableArray-typed values in
# examples/stdlib/csv_records.bot and examples/stdlib/hashtable.bot:
# the semantic type of every function result on the constructor ->
# container -> projection -> consumer chain, and of the local bindings
# (rows, first, ...) the strict-contract counterfactual fails on. Runs
# against whatever tree it is started in (pwd is the root), so it measures
# the parent commit, this tree, and either with variant-all-trusted.patch
# applied.
#
#   (cd TREE && tclsh9.0 audit/mutarray-construction/tools/trace.tcl)
set root [pwd]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000

proc result {hir e} { string trim [lindex [split [hir::types::show [hir::typeOf $hir $e]] >] end] }

proc fnResults {hir names} {
    foreach name $names {
        dict for {b binding} [dict get $hir bindings] {
            if {[dict get $binding name] ne $name || [dict get $binding declaredBy] eq ""} continue
            set value [hir::get $hir [dict get $binding declaredBy] value]
            if {[hir::kind $hir $value] ne "block"} continue
            set sig [hir::signatures::of $hir $value]
            set ps [lmap p [dict get $sig params] {format {%s:%s} [dict get $p name] [hir::types::show [hir::signatures::paramType $p]]}]
            puts [format "  %-22s (%s) -> %s" $name [join $ps ", "] [result $hir $value]]
        }
    }
}
proc bindings {hir names} {
    foreach name $names {
        dict for {b binding} [dict get $hir bindings] {
            if {[dict get $binding name] ne $name || [dict get $binding declaredBy] eq ""} continue
            set value [hir::get $hir [dict get $binding declaredBy] value]
            if {[hir::kind $hir $value] eq "block"} continue
            puts [format "  %-22s : %s" $name [hir::types::show [hir::typeOf $hir $value]]]
        }
    }
}

puts "== examples/stdlib/csv_records.bot"
set hir [surface::readProgramFile [file join $root examples stdlib csv_records.bot] -strict 0]
puts "-- function results and parameter contracts (constructor -> container -> projection)"
fnResults $hir {ht_alloc ht_new ht_new_sized row_new row_fill row_table geo_new geo_grow geo_append geo_finish build_rows csv_records_generic csv_records csv_records_presized ht_get ht_size}
puts "-- sample() bindings (projection -> consumer)"
bindings $hir {rows presized_rows first second presized_first}
puts "-- record-contained: builder pair and rehash destination"
bindings $hir {dest newControls fresh grown storage}
puts "-- diagnostics (a non-empty list only under variant-all-trusted.patch)"
foreach d [hir::diagnostics $hir] {
    puts "  [surface::originLocation $hir [hir::get $hir [dict get $d expr] origin]]: [string range [dict get $d message] 0 110]"
}
puts "== examples/stdlib/hashtable.bot"
set hir [surface::readProgramFile [file join $root examples stdlib hashtable.bot] -strict 0]
fnResults $hir {ht_alloc ht_new ht_new_sized ht_rehash_insert ht_rehash_probe ht_get}
bindings $hir {dest newControls}
foreach d [hir::diagnostics $hir] {
    puts "  [surface::originLocation $hir [hir::get $hir [dict get $d expr] origin]]: [string range [dict get $d message] 0 110]"
}
