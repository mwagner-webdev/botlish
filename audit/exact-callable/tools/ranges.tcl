#!/usr/bin/env tclsh9.0
# ranges.tcl -- EXACT-CALLABLE-CLOSED-CALLER.md: the Range hir::range proves
# for named bindings of named functions, per used instance: the entry Range
# if the binding is a parameter, and the join of the Range of every reference
# to it (the value the code actually reads). Runs unchanged on the frozen
# tree and this tree.
#
#   (cd TREE && tclsh9.0 .../ranges.tcl PROGRAM.bot fn:binding ...) > OUT.txt
set root [pwd]
set args $argv
set argv {}
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000
fconfigure stdout -encoding utf-8 -translation lf
set path [lindex $args 0]
set hir [native::prepareHir [surface::readProgramFile $path]]
set spec [hir::specialize::analyze $hir]
set ranges [hir::range::analyze $hir $spec]
set open [hir::range::OpenInstances $spec]
puts "program | function<key> | binding | entry Range | read Range | range-open"
foreach item [lrange $args 1 end] {
    lassign [split $item :] fn binding
    foreach id [dict get $spec used] {
        set inst [hir::specialize::instance $spec $id]
        if {[dict get $inst name] ne $fn} continue
        set block [dict get $inst block]
        set entry "-"
        set k 0
        foreach p [hir::get $hir $block params] r [dict get $ranges instances $id params] {
            if {[dict get [hir::binding $hir $p] name] eq $binding} { set entry [hir::range::show $r] }
        }
        set join never
        set view [hir::specialize::view $hir $spec $id]
        foreach e [dict get $spec context exprs $block] {
            if {[hir::kind $view $e] ne "ref"} continue
            set b [hir::get $view $e binding]
            if {$b eq "" || [dict get [hir::binding $hir $b] name] ne $binding} continue
            set r [hir::range::of $ranges $id $e]
            if {$r eq "never"} continue
            set join [expr {$join eq "never" ? $r : [hir::range::join $join $r]}]
        }
        puts "$path | [hir::specialize::label $spec $id] | $binding | $entry | [expr {$join eq "never" ? "-" : [hir::range::show $join]}] | [dict exists $open $id]"
    }
}
