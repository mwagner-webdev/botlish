#!/usr/bin/env tclsh9.0
# targetgraph.tcl -- POST-MODULE-STATIC-EXACT-TARGET-CENSUS.md's structural
# proof of scan_while's post-module-static target graph. Observation only:
# reads hir::specialize / hir::blockescape / hir::range / native::lower
# results, never changes them.
#
#   (cd TREE && tclsh9.0 .../targetgraph.tcl PROGRAM.ir OUTFILE)
#
# Reports, for every used instance whose label starts with SCANNER (default
# scan_while):
#   * how many semantic instances exist and which are generic;
#   * hir::specialize::closed (M7.c's InstanceClosed) and
#     hir::specialize::closedCallerTheorem (the closed-caller KeyType join);
#   * every reachable call site that targets it (caller instance, call
#     ExprId) and, per argument, the HIR form and exact type that reaches
#     the parameter -- for a Block, the block's lexical captures and its
#     module-static references (envless = no captures);
#   * the `callvalue` instructions inside its NIR function(s) and the NIR
#     form each caller uses to pass the callable (fnvalue / native /
#     closure / capture).
set root [pwd]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000
lassign $argv path out scanner
if {$scanner eq ""} { set scanner scan_while }

core::loadLibrary web
set hir [native::buildProgramHir [core::loadProgramFile $path]]
set spec [hir::specialize::analyze $hir]
set open [hir::range::OpenInstances $spec]
set nir [dict get [native::lower::program $hir] text]

proc names {hir bs} { join [lmap b $bs {dict get [hir::binding $hir $b] name}] {, } }

set L {}
lappend L "tree: [exec git -C $root rev-parse HEAD] (lib/web.bot diff lines: [llength [split [exec git -C $root diff -- lib/web.bot] \n]])"
set targets [lmap id [dict get $spec used] {
    expr {[string match "$scanner<*" [hir::specialize::label $spec $id]] ? $id : [continue]}
}]
set blocks [lsort -unique [lmap id $targets {dict get [hir::specialize::instance $spec $id] block}]]
lappend L "$scanner: [llength $blocks] semantic block(s), [llength $targets] used instance(s): [join [lmap id $targets {hir::specialize::label $spec $id}] {, }]"
foreach id $targets {
    set inst [hir::specialize::instance $spec $id]
    lappend L ""
    lappend L "== $id [hir::specialize::label $spec $id] (block [dict get $inst block])"
    lappend L "  generic: [dict get $inst generic]   InstanceClosed: [hir::specialize::closed $hir $spec $id]   range OPEN: [dict exists $open $id]"
    lappend L "  closedCallerTheorem (KeyType join per parameter): [hir::specialize::closedCallerTheorem $hir $spec $id]"
    set params [hir::get $hir [dict get $inst block] params]
    lappend L "  parameters: [names $hir $params]"
    foreach callerId [dict get $spec used] {
        set callerInst [hir::specialize::instance $spec $callerId]
        dict for {e target} [dict get $callerInst calls] {
            if {$target ne $id} continue
            set reachable [expr {$e in [dict get $callerInst reachable]}]
            set view [hir::specialize::view $hir $spec $callerId]
            lappend L "  call site $e in [hir::specialize::label $spec $callerId] (reachable: $reachable)"
            foreach a [dict get $view exprs $e args] p $params {
                set node [dict get $view exprs $a]
                set form [dict get $node kind]
                set extra ""
                if {$form eq "ref"} {
                    set b [dict get $node binding]
                    set bind [hir::binding $hir $b]
                    set form "ref [dict get $bind name] (binding kind [dict get $bind kind])"
                }
                set type [hir::typeOf $view $a]
                if {[lindex $type 0] eq "block"} {
                    set blk [lindex $type 1]
                    set c [hir::captures $hir $blk]
                    set extra "  -> Block $blk: [expr {$c eq "" ? "ENVLESS" : "captures"}] captures=\[[names $hir $c]\] staticRefs=\[[names $hir [hir::staticRefs $hir $blk]]\]"
                } elseif {[lindex $type 0] eq "native"} {
                    set extra "  -> Native [lindex $type 1]"
                }
                lappend L "      [dict get [hir::binding $hir $p] name] <- $form : $type$extra"
            }
        }
    }
}

lappend L ""
lappend L "== NIR"
set cur ""
foreach line [split $nir \n] {
    if {[regexp {^func (\d+) "([^"]*)"} $line -> fid fname]} {
        set cur $fname
        if {$fname eq $scanner} { lappend L "  $line" }
        continue
    }
    set l [string trim $line]
    if {$cur eq $scanner && [regexp {callvalue} $l]} { lappend L "    $l" }
    if {[regexp {= (fnvalue|native|closure|capture) } $l] && $cur ni {<program>}} {
        lappend L "  in $cur: $l"
    }
}
lappend L "  callvalue instructions in the whole program: [regexp -all {= callvalue } $nir]"

set f [open $out w]
fconfigure $f -encoding utf-8
puts $f [join $L \n]
close $f
puts "wrote $out"
