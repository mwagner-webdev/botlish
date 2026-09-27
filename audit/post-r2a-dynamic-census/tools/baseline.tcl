#!/usr/bin/env tclsh9.0
# baseline.tcl -- POST-R2A-DYNAMIC-CENSUS.md's deterministic (static +
# allocation) baseline for one program. Observation only: calls existing
# hir::*/native::* entry points; changes no compiler or runtime behavior.
#
#   tclsh9.0 audit/post-r2a-dynamic-census/tools/baseline.tcl PROGRAM.ir OUTFILE
#
# Records, for the tree it is run from: used instances (hir::specialize),
# NIR function/line/op counts (native::nir), machine-code bytes total and
# per function (native::codeSize), OpenInstances (hir::range), blockescape
# virtual/flattened instances, every instance's parameter entry Ranges and
# each countloop induction binding's Range, and an allocation summary
# (native::allocationReport, summary mode, one run). It is written to run
# unchanged on historical trees (R2, R2.a.2) too: anything a tree does not
# have (countloop) is simply absent from its output.
set root [pwd]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000
lassign $argv path out

core::loadLibrary web
set hir [native::buildProgramHir [core::loadProgramFile $path]]
set spec [hir::specialize::analyze $hir]
set ranges [hir::range::analyze $hir $spec]
set open [hir::range::OpenInstances $spec]
set be [hir::blockescape::analyze $hir $spec]
set lowered [native::lower::program $hir]
set nir [dict get $lowered text]
lassign [native::codeSize $hir] bytes perFunction

set L {}
lappend L "program: $path"
lappend L "tree: [exec git -C $root rev-parse HEAD]"
lappend L ""
lappend L "== used instances: [llength [dict get $spec used]]"
foreach id [dict get $spec used] {
    set inst [hir::specialize::instance $spec $id]
    set flags {}
    if {[dict get $inst generic]} { lappend flags generic }
    if {[dict exists $open $id]} { lappend flags OPEN }
    if {[hir::blockescape::wants $be $id]} {
        lappend flags "blockescape-flattened captures=\[[join [lmap b [hir::blockescape::captures $be $id] {dict get [hir::binding $hir $b] name}] {, }]\]"
    }
    set vals [dict get $inst values]
    lappend L "  $id [hir::specialize::label $spec $id] [join $flags {; }][expr {$vals ne "" ? "; materializes $vals" : ""}]"
}
lappend L ""
lappend L "== OpenInstances: [dict size $open] ([join [lmap id [dict keys $open] {hir::specialize::label $spec $id}] {, }])"
lappend L "== blockescape virtual bindings: [dict size [dict get $be virtual]]"
foreach line [hir::blockescape::explain $hir $spec $be] { lappend L "  $line" }
lappend L ""

# NIR shape
set funcs 0
set counts [dict create]
set curName ""
set perFn [dict create]
foreach line [split $nir \n] {
    if {[regexp {^func (\d+) "([^"]*)"} $line -> fid fname]} {
        incr funcs
        set curName "$fid $fname"
        continue
    }
    set l [string trim $line]
    set key ""
    if {[regexp {^guard(bool)? } $l]} { set key guard }
    if {[regexp {= (call|callenv|callvalue|callmulti|callenvmulti) } $l -> c]} { set key $c }
    if {[regexp {^(tail|tailenv) } $l -> k]} { set key $k }
    if {[regexp {= (closure|capture|fnvalue) ?} $l -> k]} { set key $k }
    if {[regexp {= op (\w+)} $l -> op]} { set key "op:$op" }
    if {$key ne ""} {
        dict incr counts $key
        dict incr perFn "$curName|$key"
    }
}
lappend L "== NIR: functions $funcs, lines [llength [split $nir \n]], machine bytes $bytes"
foreach k {call callenv callvalue callmulti callenvmulti tail tailenv guard closure fnvalue capture} {
    lappend L [format "  %-14s %d" $k [expr {[dict exists $counts $k] ? [dict get $counts $k] : 0}]]
}
foreach k [lsort [dict keys $counts op:*]] {
    lappend L [format "  %-22s %d" $k [dict get $counts $k]]
}
lappend L "  per-function machine bytes: $perFunction"
lappend L ""

# Range facts
lappend L "== parameter entry Ranges (hir::range::analyze)"
foreach id [dict get $spec used] {
    set inst [hir::specialize::instance $spec $id]
    set block [dict get $inst block]
    if {$block eq "program"} continue
    set pr [dict get [dict get $ranges instances $id] params]
    set parts {}
    foreach b [hir::get $hir $block params] r $pr {
        lappend parts "[dict get [hir::binding $hir $b] name]=[hir::range::show $r]"
    }
    lappend L "  [hir::specialize::label $spec $id]: [join $parts {  }]"
}
lappend L ""
lappend L "== countloop induction bindings (Range of the first in-body ref)"
foreach id [dict get $spec used] {
    set inst [hir::specialize::instance $spec $id]
    set block [dict get $inst block]
    if {$block eq "program"} continue
    set view [hir::specialize::view $hir $spec $id]
    foreach e [dict get [dict get $spec context] exprs $block] {
        if {[hir::kind $view $e] ne "countloop"} continue
        set cb [hir::get $view $e countBinding]
        set seen "-"
        foreach r [dict get [dict get $spec context] exprs $block] {
            if {[hir::kind $view $r] eq "ref" && [hir::get $view $r binding] eq $cb} {
                set seen [hir::range::show [hir::range::of $ranges $id $r]]
                break
            }
        }
        lappend L "  [hir::specialize::label $spec $id]: [dict get [hir::binding $hir $cb] name] = $seen"
    }
}
lappend L ""

set r [native::allocationReport $hir summary 1]
set t [dict get $r total]
lappend L "== allocationReport (summary, one run)"
lappend L "  total allocations [dict get $t allocations], allocatedBytes [dict get $t allocatedBytes]"
dict for {kind k} [dict get $r byKind] {
    if {[dict get $k allocations]} {
        lappend L [format "  %-13s %6d objects %8d bytes" $kind [dict get $k allocations] [dict get $k allocatedBytes]]
    }
}
lappend L "  gc: [dict get $r gc]"
lappend L "  traversal: [dict get $r traversal]"
lappend L "  static: [dict get $r static]"

set f [open $out w]
fconfigure $f -encoding utf-8
puts $f [join $L \n]
close $f
puts "wrote $out"
