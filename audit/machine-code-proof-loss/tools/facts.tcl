#!/usr/bin/env tclsh9.0
# facts.tcl -- per-function fact dump for MACHINE-CODE-PROOF-LOSS-
# INVESTIGATION.md: every layer between source and NIR that can hold a fact
# about a function's parameters/result, printed side by side so the first
# layer at which a fact disappears can be read off. Observation only: calls
# the same analyses, with the same default options, that native::lowered
# runs (native/lower.tcl's program: hir::specialize::analyze, then
# hir::range::analyze), on the HIR native::prepareHir returns.
#
#   (cd TREE && tclsh9.0 .../facts.tcl PROGRAM.bot ?NAME-REGEX?) > OUT.txt
#
# Sections:
#   semantic   hir::semantic::census: the front end's semantic instances
#              (entry types, result type, status) -- what hir::check knew.
#   codegen    hir::specialize: each used codegen instance's label, key
#              (args), result type, generic flag, CLOSED (InstanceClosed),
#              the closed-caller theorem, its parameters' entry Ranges and
#              result Range (hir::range), and each call site's target.
set root [pwd]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000
lassign $argv path pattern
if {$pattern eq ""} { set pattern . }
if {[file extension $path] eq ".bot"} {
    set hir [surface::readProgramFile $path]
} else {
    core::loadLibrary web
    set hir [hir::build [core::loadProgramFile $path] -strict 0]
}
fconfigure stdout -encoding utf-8 -translation lf

puts "== semantic instances (hir::semantic::census, front end)"
foreach r [hir::semantic::census $hir] {
    set name [dict get $r name]
    if {![regexp -- $pattern $name]} continue
    puts [format "  %-5s %-22s args=<%s> result=%s status=%s passes=%s calls=%d" \
        [dict get $r id] $name \
        [join [lmap a [dict get $r args] {hir::types::show $a}] {, }] \
        [hir::types::show [dict get $r result]] [dict get $r status] \
        [dict get $r passes] [llength [dict get $r calls]]]
}

set prepared [native::prepareHir $hir]
set spec [hir::specialize::analyze $prepared]
set ranges [hir::range::analyze $prepared $spec]
set blockescape [hir::blockescape::analyze $prepared $spec]
puts "\n== codegen instances (hir::specialize + hir::range, native lowering's inputs)"
foreach id [dict get $spec used] {
    set inst [hir::specialize::instance $spec $id]
    set label [hir::specialize::label $spec $id]
    if {![regexp -- $pattern $label]} continue
    set block [dict get $inst block]
    puts "  $id $label"
    puts "    key args:  <[join [lmap a [dict get $inst args] {hir::types::show $a}] {, }]>  result: [hir::types::show [dict get $inst result]]  generic: [dict get $inst generic]"
    if {$block ne "program"} {
        set closed [hir::specialize::closed $prepared $spec $id]
        puts "    closed (InstanceClosed): $closed"
        if {[catch {hir::specialize::closedCallerTheorem $prepared $spec $id} thm]} { set thm "(n/a: $thm)" }
        puts "    closed-caller theorem:   [expr {$thm eq "" ? "-" : [lmap t $thm {hir::types::show $t}]}]"
        set rinst [dict get $ranges instances $id]
        set i 0
        foreach p [hir::get $prepared $block params] r [dict get $rinst params] {
            set pname [dict get [hir::binding $prepared $p] name]
            puts "    param $i $pname: entry range [hir::range::show $r]"
            incr i
        }
        puts "    result range: [hir::range::show [dict get $rinst result]]"
    }
    dict for {e callee} [dict get $inst calls] {
        puts "    call @$e -> [hir::specialize::label $spec $callee]"
    }
}
