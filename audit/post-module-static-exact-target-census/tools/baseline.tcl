#!/usr/bin/env tclsh9.0
# baseline.tcl -- POST-MODULE-STATIC-EXACT-TARGET-CENSUS.md's deterministic
# (static + allocation) baseline for one program. Observation only: calls
# existing hir::*/native::* entry points; changes no compiler or runtime
# behavior.
#
#   (cd TREE && tclsh9.0 .../baseline.tcl PROGRAM.ir OUTFILE)
#
# The successor of audit/post-r2a-dynamic-census/tools/baseline.tcl, which
# still runs on the module-static tree but predates module statics. Same
# sections and the same counting method, plus what the new representation
# needs:
#   * `guard` and `guardbool` counted separately (the earlier tool, and the
#     earlier reports, mixed them), and the module-static `staticget` /
#     `staticset` instructions and the NIR header's `statics=N`;
#   * a CLOSED flag per generic instance (hir::specialize::closed, M7.c's
#     InstanceClosed) next to hir::range's OPEN flag;
#   * per used instance: its block's lexical captures and module-static
#     references (hir::captures / hir::staticRefs) -- envless means no
#     captures;
#   * every `callvalue` site, by NIR function;
#   * blockescape's explanation one instance per line (the earlier tool
#     iterated the explanation string word by word).
# Runs from the CURRENT DIRECTORY's tree, so it serves the production tree
# and every scratch counterfactual worktree alike.
set root [pwd]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000
lassign $argv path out

core::loadLibrary web
set hir [native::prepareHir [hir::build [core::loadProgramFile $path] -strict 0]]
set spec [hir::specialize::analyze $hir]
set ranges [hir::range::analyze $hir $spec]
set open [hir::range::OpenInstances $spec]
set be [hir::blockescape::analyze $hir $spec]
set lowered [native::lower::program $hir]
set nir [dict get $lowered text]
lassign [native::codeSize $hir] bytes perFunction

proc names {hir bs} {
    return [join [lmap b $bs {dict get [hir::binding $hir $b] name}] {, }]
}

set L {}
lappend L "program: $path"
lappend L "tree: [exec git -C $root rev-parse HEAD] (worktree diff: [expr {[exec git -C $root diff --stat] eq "" ? "none" : [lindex [split [exec git -C $root diff --stat] \n] end]}])"
lappend L ""
lappend L "== used instances: [llength [dict get $spec used]]"
foreach id [dict get $spec used] {
    set inst [hir::specialize::instance $spec $id]
    set flags {}
    if {[dict get $inst generic]} {
        lappend flags generic
        if {[dict get $inst block] ne "program"} {
            lappend flags [expr {[hir::specialize::closed $hir $spec $id] ? "CLOSED" : "not-closed"}]
        }
    }
    if {[dict exists $open $id]} { lappend flags OPEN }
    if {[hir::blockescape::wants $be $id]} {
        lappend flags "blockescape-flattened captures=\[[names $hir [hir::blockescape::captures $be $id]]\]"
    }
    set vals [dict get $inst values]
    lappend L "  $id [hir::specialize::label $spec $id] [join $flags {; }][expr {$vals ne "" ? "; materializes $vals" : ""}]"
}
lappend L ""
lappend L "== block environments (used instances; envless = no lexical captures)"
foreach id [dict get $spec used] {
    set block [dict get [hir::specialize::instance $spec $id] block]
    if {$block eq "program"} continue
    set c [hir::captures $hir $block]
    set s [hir::staticRefs $hir $block]
    lappend L "  [hir::specialize::label $spec $id] ($block): [expr {$c eq "" ? "envless" : "captures"}] captures=\[[names $hir $c]\] staticRefs=\[[names $hir $s]\]"
}
lappend L ""
lappend L "== OpenInstances: [dict size $open] ([join [lmap id [dict keys $open] {hir::specialize::label $spec $id}] {, }])"
lappend L "== blockescape virtual bindings: [dict size [dict get $be virtual]]"
foreach line [split [hir::blockescape::explain $hir $spec $be] \n] { lappend L "  $line" }
lappend L ""

# NIR shape
set funcs 0
set counts [dict create]
set curName ""
set callvalueSites {}
foreach line [split $nir \n] {
    if {[regexp {^func (\d+) "([^"]*)"} $line -> fid fname]} {
        incr funcs
        set curName "$fid $fname"
        continue
    }
    set l [string trim $line]
    set key ""
    if {[regexp {^guard } $l]} { set key guard }
    if {[regexp {^guardbool } $l]} { set key guardbool }
    if {[regexp {^staticset } $l]} { set key staticset }
    if {[regexp {= (call|callenv|callvalue|callmulti|callenvmulti) } $l -> c]} { set key $c }
    if {[regexp {^(tail|tailenv) } $l -> k]} { set key $k }
    if {[regexp {= (closure|capture|fnvalue|staticget|native) ?} $l -> k]} { set key $k }
    if {[regexp {= op (\w+)} $l -> op]} { set key "op:$op" }
    if {$key eq "callvalue"} { lappend callvalueSites "$curName: $l" }
    if {$key ne ""} {
        dict incr counts $key
    }
}
regexp {^nir [^\n]*} $nir header
lappend L "== NIR: functions $funcs, lines [llength [split $nir \n]], machine bytes $bytes"
lappend L "  header: $header"
foreach k {call callenv callvalue callmulti callenvmulti tail tailenv guard guardbool closure fnvalue native capture staticget staticset} {
    lappend L [format "  %-14s %d" $k [expr {[dict exists $counts $k] ? [dict get $counts $k] : 0}]]
}
foreach k [lsort [dict keys $counts op:*]] {
    lappend L [format "  %-22s %d" $k [dict get $counts $k]]
}
lappend L "  callvalue sites: [expr {$callvalueSites eq "" ? "none" : ""}]"
foreach s $callvalueSites { lappend L "    $s" }
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
