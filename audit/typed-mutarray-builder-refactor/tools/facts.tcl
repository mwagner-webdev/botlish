set root [pwd]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000
foreach name {csv_geometric csv_records} {
    puts "=== $name"
    set hir [surface::readProgramFile [file join $root examples stdlib $name.bot] -strict 0]
    foreach row [lsort [lmap row [hir::semantic::census $hir] {
        format {%s<%s> -> %s [%s]} [dict get $row name] [join [lmap t [dict get $row args] {hir::semantic::ShowType $hir $t}] {, }] [hir::semantic::ShowType $hir [dict get $row result]] [dict get $row status]
    }]] { if {[regexp {^(geo_|mutarray|scan_record|scan_records|csv_parse|build_rows|csv_records_generic|row_table|row_fill)} $row]} {puts "  $row"} }
    foreach nm {rows presized_rows first second presized_first records headers table first storage grown fresh} {
        dict for {b binding} [dict get $hir bindings] {
            if {[dict get $binding name] ne $nm || [dict get $binding declaredBy] eq ""} continue
            set value [hir::get $hir [dict get $binding declaredBy] value]
            if {[hir::kind $hir $value] eq "block"} continue
            puts "  binding $nm : [hir::types::show [hir::typeOf $hir $value]]"
        }
    }
    puts "  diagnostics: [llength [hir::diagnostics $hir]]"
}
