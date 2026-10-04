# probe.tcl -- print, for a Botlish program text (argv), each expression's
# semantic type and exact fact, and for every used specialization instance
# the type and Range of every analyzed expression.
#   tclsh9.0 probe.tcl [-strict 0|1] 'source text'
set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
set strict 1
set args $argv
if {[lindex $args 0] eq "-strict"} { set strict [lindex $args 1]; set args [lrange $args 2 end] }
set hir [surface::compile [surface::modules::ImportHeader [lindex $args 0]][lindex $args 0] t.bot -strict $strict]
set havExact [expr {[info commands hir::exact::Of] ne ""}]
puts "--- semantic"
puts [hir::format $hir]
if {$havExact} {
    puts "--- exact facts (semantic)"
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] in {ref block}} continue
        set f [hir::exact::Of $hir $e]
        if {$f ne ""} { puts "$e [dict get $node kind]: [hir::exact::describe $hir $f]" }
    }
}
set spec [hir::specialize::analyze $hir]
set an [hir::range::analyze $hir $spec]
foreach id [dict get $spec used] {
    puts "--- instance [hir::specialize::label $spec $id]"
    set view [hir::specialize::view $hir $spec $id]
    dict for {e r} [dict get $an instances $id exprs] {
        if {[hir::kind $view $e] eq "ref"} continue
        puts "$e [hir::kind $view $e] : [hir::types::show [hir::typeOf $view $e]]   \[[hir::range::show $r]\]"
    }
}
