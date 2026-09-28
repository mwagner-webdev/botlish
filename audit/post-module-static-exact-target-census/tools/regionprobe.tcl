#!/usr/bin/env tclsh9.0
# regionprobe.tcl -- POST-MODULE-STATIC-EXACT-TARGET-CENSUS.md's structural
# StringRegion check: which predicate instances StringRegion itself accepts
# as region consumers, and, for each it rejects, the exact node that
# disqualifies it. Observation only: calls hir::stringregion's own
# ConsumingShape / consumingParamsOf / explain, unmodified.
#
#   (cd TREE && tclsh9.0 .../regionprobe.tcl PROGRAM.ir OUTFILE)
#
# Runs from the CURRENT DIRECTORY's tree (production or a scratch
# counterfactual worktree).
set root [pwd]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000
lassign $argv path out

core::loadLibrary web
set hir [native::buildProgramHir [core::loadProgramFile $path]]
set spec [hir::specialize::analyze $hir]
set sr [hir::stringregion::analyze $hir $spec]
set context [dict get $spec context]

# The first node ConsumingShape would reject, with the reason, mirroring its
# own switch (hir/stringregion.tcl) -- used only to NAME the rejection; the
# verdict itself is ConsumingShape's own return value.
proc firstRejection {view instance exprs} {
    if {[dict get $instance calls] ne {}} {
        return "calls another Block: [dict get $instance calls]"
    }
    foreach e $exprs {
        switch -- [hir::kind $view $e] {
            if - const - ref {}
            call {
                set node [hir::node $view $e]
                lassign [dict get $node target] targetKind target
                if {$targetKind ne "native"} { return "$e: call to non-native target $targetKind" }
                set name [dict get [hir::symbol $view $target] name]
                if {$name ni {== length} && ![hir::stringregion::ConsumingNative $name]} {
                    return "$e: native `$name` is not a supported region consumer (supported: ==, length, is_tcl_alpha, is_tcl_alnum)"
                }
            }
            default { return "$e: node kind [hir::kind $view $e] not supported" }
        }
    }
    return "(shape accepted; a parameter reference is used outside a supported consumer position)"
}

set L {}
lappend L "tree: [exec git -C $root rev-parse HEAD] (lib/web.bot diff lines: [llength [split [exec git -C $root diff -- lib/web.bot] \n]])"
lappend L ""
lappend L "== predicate / scanner instances: StringRegion's own verdicts"
foreach id [dict get $spec used] {
    set label [hir::specialize::label $spec $id]
    if {![regexp {^(local_char\?|label_char\?|scan_\w+|char_at|tld\?|domain\?)<} $label]} continue
    set instance [dict get $spec instances $id]
    set block [dict get $instance block]
    set consuming [hir::stringregion::consumingParamsOf $sr $id]
    set wants [hir::stringregion::wants $sr $id]
    if {[dict get $instance generic]} {
        set verdict "generic instance: never a ConsumingParams candidate (ConsumingParams skips generic instances)"
    } else {
        set view [hir::specialize::view $hir $spec $id]
        set shape [hir::stringregion::ConsumingShape $view $instance [dict get $context exprs $block]]
        if {$shape eq ""} {
            set verdict "ConsumingShape rejects: [firstRejection $view $instance [dict get $context exprs $block]]"
        } else {
            set verdict "ConsumingShape accepts"
        }
    }
    lappend L "  $label: consumingParams=\{$consuming\} regionCompanionWanted=$wants"
    lappend L "      $verdict"
}
lappend L ""
lappend L "== hir::stringregion::explain"
foreach line [split [hir::stringregion::explain $hir $spec $sr] \n] { lappend L "  $line" }

set f [open $out w]
fconfigure $f -encoding utf-8
puts $f [join $L \n]
close $f
puts "wrote $out"
