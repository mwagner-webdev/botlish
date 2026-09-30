# keyvariant.tcl -- codegen-instance counts of the canonical corpus under two KeyType choices for
# anonymous structs: "kinds" (the implementation: layout plus each field's key type) and
# "layout" (field names only). Observation only; run from the tree root:
#   tclsh9.0 audit/structs/tools/keyvariant.tcl kinds|layout
set root [pwd]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000
set variant [lindex $argv 0]
if {$variant eq "layout"} {
    # Variant: a struct's key is its layout only (field names), every field
    # type erased to any.
    rename hir::specialize::KeyType hir::specialize::KeyTypeKinds
    proc hir::specialize::KeyType {type} {
        if {[hir::types::IsStruct $type]} {
            set fields [dict create]
            dict for {name t} [lindex $type 1] { dict set fields $name any }
            return [hir::types::MakeStruct $fields 0]
        }
        return [hir::specialize::KeyTypeKinds $type]
    }
}
set used 0; set emitted 0; set structInst 0
foreach path [concat [lsort [glob -directory [file join $root bench] *.bot]] [lsort [glob -directory [file join $root examples stdlib] *.bot]]] {
    set hir [native::prepareHir [surface::readProgramFile $path]]
    set spec [hir::specialize::analyze $hir]
    incr used [llength [dict get $spec used]]
    incr emitted [llength [dict get [native::lower::program $hir] functions]]
}
puts "KeyType variant $variant: codegen used $used emitted $emitted"
