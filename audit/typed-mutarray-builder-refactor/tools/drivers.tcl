set root [pwd]
source [file join $root examples stdlib corpus.tcl]
interp recursionlimit {} 100000
proc typeOfDriver {name driver} {
    if {[catch {corpus::driven $name $driver} hir]} { return "REJECT [string range $hir 0 400]" }
    hir::types::show [hir::typeOf $hir [lindex [hir::roots $hir] end]]
}
foreach {label d} {
  str   {geo_finish(geo_append(geo_new("a"), 1, "b"), 2)}
  list  {geo_finish(geo_append(geo_new(["x"]), 1, ["y"]), 2)}
  mut   {geo_finish(geo_append(geo_new(mutable_array::allocate(1)), 1, mutable_array::allocate(1)), 2)}
  wrong {geo_append(geo_new("a"), 1, 5)}
  storage {geo_append(geo_new("a"), 1, "b")}
  new-str {geo_new("a")}
} { puts "$label: [typeOfDriver csv_geometric $d]" }
