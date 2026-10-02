#!/usr/bin/env tclsh9.0
# collect.tcl -- dump everything the result-narrowing census compares
# (GENERIC-PREDICATE-PROOF-LOSS.md, fix 3) for a set of .bot programs, as
# produced by the compiler tree TREE (not necessarily this script's own
# tree, so the same script serves the pre-change worktree too).
#
#   tclsh9.0 collect.tcl TREE KNOB OUTDIR PROGRAM.{bot,ir}...
#
# KNOB is 0 or 1, or "-" (leave the tree's own defaults alone: the
# pre-change tree has no such variable). The variable it sets is
# hir::range::resultNarrowOpt (fix 3), or the one named by the environment
# variable AUDIT_KNOB (loss point 2: hir::specialize::dormantOpt). Per
# program, ONE native::nir run with default lowering options; the Range
# analysis, the Fixpoint states and the raw-int-ABI plan are the very ones
# that run computed (captured with execution traces, never recomputed), so
# every fact compared is the fact lowering consumed. Writes
# OUTDIR/<stem>/:
#   nir.txt        native::nir's text
#   instances.txt  hir::range::analyze's `instances` dict, verbatim
#   analysis.txt   instances, induction and recursive (one dict per line)
#   fixpoints.txt  one line per Fixpoint call: a dict of its state's ids,
#                  narrowed, narrowedCaptures, calleeResults, pinned,
#                  open (keys) and, when present, ascendingResults and
#                  resultNarrow
#   labels.txt     InstanceId -> {label LABEL block BLOCK pnames {...}}
#   rawabi.txt     native::rawabi::explainAll of the captured plan
#   hir.txt        hir::format of the HIR the analysis ran on (ExprId text)
#   variants.txt   every NIR function variant lowering emitted, as
#                  "InstanceId mode" (canonical, companion, region,
#                  internal, internalregion, fields, fieldscompanion) in
#                  the order lowering's worklist produced them
#   calls.txt      number of analyze / Fixpoint / rawabi::plan calls
#   dormant.txt    the specialization's dormant InstanceIds (loss point 2;
#                  empty on a tree without them)
# or OUTDIR/<stem>/skip.txt with the error, when lowering failed.
lassign $argv tree knob outdir
set programs [lrange $argv 3 end]
set tree [file normalize $tree]
source [file join $tree compiler compiler.tcl]
source [file join $tree surface surface.tcl]
source [file join $tree native native.tcl]
interp recursionlimit {} 20000
if {$knob ne "-"} {
    set ::[expr {[info exists ::env(AUDIT_KNOB)] ? $::env(AUDIT_KNOB) : "hir::range::resultNarrowOpt"}] $knob
}

proc W {path content} {
    set f [open $path w]
    fconfigure $f -encoding utf-8 -translation lf
    puts -nonewline $f $content
    close $f
}

namespace eval cap {
    variable analyzeArgs {}
    variable analyzeResults {}
    variable fixpoints {}
    variable planArgs {}
    variable plans {}
    variable variants {}
}
proc cap::AnalyzeEnter {cmd op} {
    variable analyzeArgs
    lappend analyzeArgs [lrange $cmd 1 2]
}
proc cap::AnalyzeLeave {cmd code result op} {
    variable analyzeResults
    if {$code == 0} {
        lappend analyzeResults $result
    }
}
proc cap::FixpointLeave {cmd code result op} {
    variable fixpoints
    if {$code != 0} return
    set st [dict get $result state]
    set rec [dict create]
    foreach key {ids narrowed narrowedCaptures calleeResults pinned} {
        dict set rec $key [dict get $st $key]
    }
    dict set rec open [lsort [dict keys [dict get $st open]]]
    foreach key {ascendingResults resultNarrow} {
        if {[dict exists $st $key]} {
            dict set rec $key [dict get $st $key]
        }
    }
    lappend fixpoints $rec
}
proc cap::PlanEnter {cmd op} {
    variable planArgs
    lappend planArgs [lrange $cmd 1 3]
}
proc cap::PlanLeave {cmd code result op} {
    variable plans
    if {$code == 0} {
        lappend plans $result
    }
}
proc cap::VariantEnter {mode cmd op} {
    variable variants
    lappend variants "[lindex $cmd 1] $mode"
}
foreach {procName mode} {Function canonical CompanionFunction companion
        RegionCompanionFunction region InternalFunction internal
        InternalRegionCompanionFunction internalregion FieldsFunction fields
        FieldsCompanionFunction fieldscompanion} {
    if {[info commands native::lower::$procName] ne ""} {
        trace add execution native::lower::$procName enter [list cap::VariantEnter $mode]
    }
}
trace add execution hir::range::analyze enter cap::AnalyzeEnter
trace add execution hir::range::analyze leave cap::AnalyzeLeave
trace add execution hir::range::Fixpoint leave cap::FixpointLeave
trace add execution native::rawabi::plan enter cap::PlanEnter
trace add execution native::rawabi::plan leave cap::PlanLeave

foreach path $programs {
    # One dump directory per program path (bench/fib.bot and bench/fib.ir
    # must not collide): the relative path with "/" spelled "__".
    set stem [string map {/ __} [string trimleft [file rootname $path] ./]]
    set dir [file join $outdir $stem]
    file delete -force $dir
    file mkdir $dir
    set cap::analyzeArgs {}
    set cap::analyzeResults {}
    set cap::fixpoints {}
    set cap::planArgs {}
    set cap::plans {}
    set cap::variants {}
    set t0 [clock milliseconds]
    if {[catch {
        if {[file extension $path] eq ".ir"} {
            # Core IR text is read into HIR like any other input notation
            # (native/explain-native.tcl, audit/post-r2a-dynamic-census's
            # emit-nir.tcl); the web library its natives may name is loaded
            # first, as emit-nir.tcl does.
            core::loadLibrary web
            set hir [hir::build [core::loadProgramFile $path] -strict 0]
        } else {
            set hir [surface::readProgramFile $path]
        }
        set nir [native::nir $hir]
    } err opts]} {
        W [file join $dir skip.txt] "[dict get $opts -errorcode]\n$err\n"
        puts "$stem: SKIP [dict get $opts -errorcode]"
        continue
    }
    set ms [expr {[clock milliseconds] - $t0}]
    W [file join $dir nir.txt] $nir
    W [file join $dir calls.txt] "analyze [llength $cap::analyzeResults] fixpoint [llength $cap::fixpoints] plan [llength $cap::plans] ms $ms\n"
    # The (single, checked by census.tcl) analysis lowering consumed.
    set analysis [lindex $cap::analyzeResults end]
    lassign [lindex $cap::analyzeArgs end] ahir spec
    W [file join $dir instances.txt] "[dict get $analysis instances]\n"
    W [file join $dir analysis.txt] "[list instances [dict get $analysis instances]]\n[list induction [dict get $analysis induction]]\n[list recursive [dict get $analysis recursive]]\n"
    W [file join $dir fixpoints.txt] "[join $cap::fixpoints \n]\n"
    set labels {}
    foreach id [dict get $spec used] {
        set block [dict get [hir::specialize::instance $spec $id] block]
        set pnames {}
        if {$block ne "program"} {
            set pnames [lmap b [hir::get $ahir $block params] {dict get [hir::binding $ahir $b] name}]
        }
        append labels [list $id [dict create label [hir::specialize::label $spec $id] block $block pnames $pnames]] \n
    }
    W [file join $dir labels.txt] $labels
    W [file join $dir dormant.txt] "[expr {[dict exists $spec dormant] ? [lsort [dict keys [dict get $spec dormant]]] : ""}]\n"
    W [file join $dir hir.txt] [hir::format $ahir]
    W [file join $dir variants.txt] "[join $cap::variants \n]\n"
    lassign [lindex $cap::planArgs end] phir pspec pranges
    W [file join $dir rawabi.txt] [native::rawabi::explainAll $phir $pspec $pranges [lindex $cap::plans end]]
    puts "$stem: ok ${ms}ms analyze=[llength $cap::analyzeResults] fixpoint=[llength $cap::fixpoints]"
}
