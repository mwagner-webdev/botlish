#!/usr/bin/env tclsh9.0
# LEGACY / RELIFT COMPARISON (census whose "relifted" column is native::buildProgramHir of hir::lower): needs native::buildProgramHir, which
# DIRECT-HIR-NATIVE-PATH.md removed. Runs only against a tree from before that
# milestone; the production route is audit/direct-hir-native-path/tools/.
# typecensus.tcl -- STRUCTURAL-FUNCTION-TYPES.md's before/after callable
# type census for the three higher-order canonical benchmarks
# (HIGHER-ORDER-DOGFOODING.md). Observation only: reads HIR types,
# hir::specialize views and native::lower's NIR text, changes nothing.
#
#   (cd TREE && tclsh9.0 audit/structural-function-types/tools/typecensus.tcl OUTFILE)
#
# Runs against whatever tree it is started in, so the identical script
# measures the pre-milestone tree and this one. Every boundary item 74 of
# the milestone brief names is reported twice:
#
#   surface   the HIR surface::readProgramFile builds (every source
#             annotation kept) -- what `main.tcl -backend cranelift` and
#             `-backend compile` lower
#   relifted  native::buildProgramHir [hir::lower ...] -- the core-IR
#             round trip bench/bench.tcl uses (annotations erased by
#             hir::lower), and the pipeline HIGHER-ORDER-DOGFOODING.md's own
#             census measured
#
# with the semantic (whole-program) type and the type in every used
# specialization instance's own view, plus the NIR call form of the call
# sites involved. The last section is the static `callvalue` census over
# every canonical bench/*.bot (relifted pipeline, as bench/bench.tcl runs).
set root [pwd]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000
lassign $argv out

proc show {t} { return [hir::types::show $t] }

# The first binding named NAME (any kind but root), or "".
proc bindingNamed {hir name} {
    dict for {b binding} [dict get $hir bindings] {
        if {[dict get $binding name] eq $name && [dict get $binding kind] ne "root"} {
            return $b
        }
    }
    return ""
}

# The value expression bound to NAME's own declaring bind.
proc valueOf {hir name} {
    set b [bindingNamed $hir $name]
    return [dict get $hir exprs [dict get $hir bindings $b declaredBy] value]
}

# Every expression E of kind KIND within block BLOCK's own body (not
# descending into nested blocks), in pre-order.
proc exprsIn {hir block kind} {
    set out {}
    set work [lreverse [dict get $hir exprs $block body]]
    while {$work ne {}} {
        set e [lindex $work end]
        set work [lrange $work 0 end-1]
        if {[hir::kind $hir $e] eq $kind} { lappend out $e }
        if {[hir::kind $hir $e] eq "block"} continue
        foreach c [lreverse [hir::children $hir $e]] { lappend work $c }
    }
    return $out
}

# Every call expression anywhere whose callee is a ref to binding B.
proc callsOf {hir b} {
    set out {}
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "call"} continue
        set callee [dict get $node callee]
        if {[hir::kind $hir $callee] eq "ref" && [hir::get $hir $callee binding] eq $b} {
            lappend out $e
        }
    }
    return [lsort -dictionary $out]
}

# E's type in every used instance whose view contains it.
proc instanceTypes {hir spec e} {
    set out {}
    foreach id [dict get $spec used] {
        set inst [hir::specialize::instance $spec $id]
        if {$e ni [dict get $inst reachable]} continue
        set view [hir::specialize::view $hir $spec $id]
        lappend out "[hir::specialize::label $spec $id]: [show [hir::typeOf $view $e]]"
    }
    return $out
}

proc nirForm {nir e} {
    set forms {}
    foreach line [split $nir \n] {
        if {[regexp "= (call|callenv|callvalue|callmulti|callenvmulti) .*@$e\$" [string trim $line] -> form]} {
            lappend forms $form
        }
    }
    return [expr {$forms eq {} ? "(no call instruction: inlined/folded)" : [join $forms {, }]}]
}

proc report {LVar label hir spec nir e} {
    upvar 1 $LVar L
    lappend L "    $label ($e): [show [hir::typeOf $hir $e]]"
    foreach line [instanceTypes $hir $spec $e] { lappend L "        in $line" }
}

proc census {LVar path pipeline} {
    upvar 1 $LVar L
    set surface [surface::readProgramFile $path]
    set hir [expr {$pipeline eq "surface" ? $surface
        : [native::buildProgramHir [hir::lower $surface]]}]
    set spec [hir::specialize::analyze $hir]
    set nir [dict get [native::lower::program $hir] text]
    lappend L "  -- $pipeline HIR"
    switch -- [file tail $path] {
        source-checks.bot {
            set literal [valueOf $hir checks]
            report L {List literal [is_tcl_alpha, is_tcl_alnum, is_underscore?, is_hyphen?]} $hir $spec $nir $literal
            lappend L "    checks binding: [show [hir::bindingType $hir [bindingNamed $hir checks]]]"
            set classify [valueOf $hir classify_leading]
            set loop [lindex [exprsIn $hir $classify listloop] 0]
            set checkBinding [hir::get $hir $loop elementBinding]
            set call [lindex [callsOf $hir $checkBinding] 0]
            report L "check loop binding (as the callee ref of check(c))" $hir $spec $nir [hir::get $hir $call callee]
            report L "check(c) call result" $hir $spec $nir $call
            lappend L "    check(c) HIR target: \"[hir::get $hir $call target]\"   NIR form: [nirForm $nir $call]"
        }
        lex-strategy.bot {
            set choose [valueOf $hir choose_classifier]
            set if [lindex [exprsIn $hir $choose if] 0]
            report L "strict branch (is_tcl_alnum)" $hir $spec $nir [lindex [hir::get $hir $if thenBody] end]
            report L "relaxed branch (lenient_ident_char?)" $hir $spec $nir [lindex [hir::get $hir $if elseBody] end]
            report L "if expression" $hir $spec $nir $if
            lappend L "    choose_classifier result type: [show [hir::type $hir [hir::get $hir $choose resultType]]]"
            lappend L "    choose_classifier binding: [show [hir::bindingType $hir [bindingNamed $hir choose_classifier]]]"
            set classifier [bindingNamed $hir classifier]
            lappend L "    classifier binding: [show [hir::bindingType $hir $classifier]]"
            set call [lindex [callsOf $hir $classifier] 0]
            report L "classifier (callee ref of classifier(c))" $hir $spec $nir [hir::get $hir $call callee]
            report L "classifier(c) call result" $hir $spec $nir $call
            lappend L "    classifier(c) HIR target: \"[hir::get $hir $call target]\"   NIR form: [nirForm $nir $call]"
        }
        test-selection.bot {
            set factory [valueOf $hir make_changed?]
            lappend L "    make_changed? result type: [show [hir::type $hir [hir::get $hir $factory resultType]]]"
            lappend L "    make_changed? binding: [show [hir::bindingType $hir [bindingNamed $hir make_changed?]]]"
            set a [bindingNamed $hir changed_a?]
            lappend L "    changed_a? binding: [show [hir::bindingType $hir $a]]"
            lappend L "    changed_b? binding: [show [hir::bindingType $hir [bindingNamed $hir changed_b?]]]"
            foreach call [callsOf $hir $a] {
                report L "changed_a?(...) direct call result" $hir $spec $nir $call
                lappend L "    changed_a?(...) HIR target: \"[hir::get $hir $call target]\"   NIR form: [nirForm $nir $call]"
            }
        }
    }
    set counts [dict create call 0 callenv 0 callvalue 0]
    foreach line [split $nir \n] {
        if {[regexp {= (call|callenv|callvalue) } $line -> c]} { dict incr counts $c }
    }
    lappend L "    NIR totals: call [dict get $counts call], callenv [dict get $counts callenv], callvalue [dict get $counts callvalue]"
}

set L {}
lappend L "tree: [exec git -C $root rev-parse HEAD] (plus any uncommitted working-tree changes)"
lappend L ""
foreach name {source-checks lex-strategy test-selection} {
    set path [file join $root bench $name.bot]
    lappend L "== bench/$name.bot"
    foreach pipeline {surface relifted} {
        census L $path $pipeline
    }
    lappend L ""
}

lappend L "== static callvalue census (relifted pipeline, as bench/bench.tcl compiles)"
set total 0
foreach path [lsort [glob -directory [file join $root bench] *.bot]] {
    set hir [native::buildProgramHir [hir::lower [surface::readProgramFile $path]]]
    set nir [dict get [native::lower::program $hir] text]
    set sites {}
    set func ""
    foreach line [split $nir \n] {
        if {[regexp {^func (\d+) "([^"]*)"} $line -> fid fname]} { set func $fname }
        if {[regexp {= callvalue .*@(e\d+)} $line -> e]} { lappend sites "$func@$e" }
    }
    incr total [llength $sites]
    lappend L [format "  %-22s %d  %s" [file tail $path] [llength $sites] [join $sites {, }]]
}
lappend L "  total                  $total"

set f [open $out w]
fconfigure $f -encoding utf-8
puts $f [join $L \n]
close $f
puts "wrote $out"
