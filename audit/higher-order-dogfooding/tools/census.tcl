#!/usr/bin/env tclsh9.0
# census.tcl -- HIGHER-ORDER-DOGFOODING.md's structural callable census for
# one canonical surface-Botlish .bot program. Observation only: reads
# hir::specialize/hir::blockescape/native::lower results, changes nothing.
#
#   (cd TREE && tclsh9.0 audit/higher-order-dogfooding/tools/census.tcl PROGRAM.bot OUTFILE)
#
# Reports, for every used specialization instance:
#   * generic/InstanceClosed/OpenInstances flags;
#   * its Block's lexical captures and module-static references (envless =
#     no captures);
#   * every call expression it contains: the HIR "target" field (unset =
#     callvalue at native lowering), and for each argument, the HIR form
#     and exact type reaching the callee/each parameter -- for a Block, its
#     own captures/staticRefs; for a native, its name.
# Then the generated NIR's own call/callenv/callvalue/closure/fnvalue/
# native/capture instruction counts, exactly like
# audit/post-module-static-exact-target-census/tools/baseline.tcl's own NIR
# section, plus every callvalue instruction's containing function.
set root [pwd]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000
lassign $argv path out

set hir [native::prepareHir [surface::readProgramFile $path]]
set spec [hir::specialize::analyze $hir]
set open [hir::range::OpenInstances $spec]
set be [hir::blockescape::analyze $hir $spec]
set lowered [native::lower::program $hir]
set nir [dict get $lowered text]

proc names {hir bs} { return [join [lmap b $bs {dict get [hir::binding $hir $b] name}] {, }] }

set L {}
lappend L "program: $path"
lappend L "tree: [exec git -C $root rev-parse HEAD]"
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
    lappend L "  $id [hir::specialize::label $spec $id] [join $flags {; }]"
}
lappend L ""
lappend L "== block environments (used instances; envless = no lexical captures)"
foreach id [dict get $spec used] {
    set block [dict get [hir::specialize::instance $spec $id] block]
    if {$block eq "program"} continue
    set c [hir::captures $hir $block]
    set s [hir::staticRefs $hir $block]
    lappend L "  [hir::specialize::label $spec $id] (block $block): [expr {$c eq "" ? "envless" : "captures"}] captures=\[[names $hir $c]\] staticRefs=\[[names $hir $s]\]"
}
lappend L ""
lappend L "== blockescape virtual bindings: [dict size [dict get $be virtual]]"
foreach line [split [hir::blockescape::explain $hir $spec $be] \n] { lappend L "  $line" }
lappend L ""
lappend L "== call sites (every used instance's own call expressions)"
foreach id [dict get $spec used] {
    set inst [hir::specialize::instance $spec $id]
    set view [hir::specialize::view $hir $spec $id]
    dict for {e target} [dict get $inst calls] {
        set reachable [expr {$e in [dict get $inst reachable]}]
        if {!$reachable} continue
        set node [dict get $view exprs $e]
        set calleeDesc "target=[expr {$target eq "" ? "UNSET(callvalue)" : $target}]"
        if {$target ne ""} {
            set calleeDesc "-> [hir::specialize::label $spec $target]"
        }
        # Describe the callee expression itself (the thing being called).
        set calleeExpr [dict get $node callee]
        set cnode [dict get $view exprs $calleeExpr]
        set cform [dict get $cnode kind]
        set cextra ""
        if {$cform eq "ref"} {
            set b [dict get $cnode binding]
            set bind [hir::binding $hir $b]
            set cform "ref [dict get $bind name] (binding kind [dict get $bind kind])"
        }
        set ctype [hir::typeOf $view $calleeExpr]
        if {[llength $ctype] >= 2 && [lindex $ctype 0] eq "block"} {
            set blk [lindex $ctype 1]
            set c [hir::captures $hir $blk]
            set cextra "  -> Block $blk: [expr {$c eq "" ? "ENVLESS" : "captures"}] captures=\[[names $hir $c]\] staticRefs=\[[names $hir [hir::staticRefs $hir $blk]]\]"
        } elseif {[llength $ctype] >= 2 && [lindex $ctype 0] eq "native"} {
            set cextra "  -> Native [lindex $ctype 1]"
        }
        lappend L "  call $e in [hir::specialize::label $spec $id]: callee $cform : $ctype $cextra ($calleeDesc)"
        foreach a [dict get $node args] {
            set anode [dict get $view exprs $a]
            set aform [dict get $anode kind]
            set aextra ""
            if {$aform eq "ref"} {
                set b [dict get $anode binding]
                set bind [hir::binding $hir $b]
                set aform "ref [dict get $bind name] (binding kind [dict get $bind kind])"
            }
            set atype [hir::typeOf $view $a]
            if {[llength $atype] >= 2 && [lindex $atype 0] eq "block"} {
                set blk [lindex $atype 1]
                set c [hir::captures $hir $blk]
                set aextra "  -> Block $blk: [expr {$c eq "" ? "ENVLESS" : "captures"}] captures=\[[names $hir $c]\] staticRefs=\[[names $hir [hir::staticRefs $hir $blk]]\]"
            } elseif {[llength $atype] >= 2 && [lindex $atype 0] eq "native"} {
                set aextra "  -> Native [lindex $atype 1]"
            }
            lappend L "      arg: $aform : $atype$aextra"
        }
    }
}
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
    if {[regexp {= (call|callenv|callvalue|callmulti|callenvmulti) } $l -> c]} { set key $c }
    if {[regexp {= (closure|capture|fnvalue|staticget|native) ?} $l -> k]} { set key $k }
    if {$key eq "callvalue"} { lappend callvalueSites "$curName: $l" }
    if {$key ne ""} { dict incr counts $key }
}
lappend L "== NIR: functions $funcs, lines [llength [split $nir \n]]"
foreach k {call callenv callvalue callmulti callenvmulti closure fnvalue native capture staticget} {
    lappend L [format "  %-14s %d" $k [expr {[dict exists $counts $k] ? [dict get $counts $k] : 0}]]
}
lappend L "  callvalue sites:"
foreach s $callvalueSites { lappend L "    $s" }
lappend L ""

set f [open $out w]
fconfigure $f -encoding utf-8
puts $f [join $L \n]
close $f
puts "wrote $out"
