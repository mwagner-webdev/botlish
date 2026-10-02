# explain-native.tcl -- dumps HIR/NIR/Cranelift IR/range facts for any .ir
# program into a directory, for correlating source semantics with generated
# native code (the native-code-quality audit's temporary diagnostic
# tooling; see NATIVE-AUDIT.md). Works structurally on any program: no
# benchmark or function is known by name.
#
#   tclsh9.0 native/explain-native.tcl PROGRAM.{ir,bot} OUTDIR
#
# Writes, into OUTDIR:
#   hir.txt           hir::format: resolved HIR, one line per expression
#   aot.txt           hir::aot::explain: closed-AOT readiness per function
#   aot-spec.txt      hir::specialize::explain: instances, guards, runtime
#                     requirements per specialization
#   recursive-ranges.txt  bounded self-recursive result proofs and
#                     rejection reasons (hir/rangerec.tcl), with state trace
#   raw-int-abi.txt  native::rawabi: the raw Int ABI plan of every used
#                     instance (RAW-INT-ABI.md): closedness, each parameter's
#                     type, entry Range and ABI, the result's, and the
#                     rejection tag of every position that stays tagged
#   range-params.txt  hir::range::analyze's per-parameter/result Range of
#                     every used instance
#   range-exprs.txt   the same analysis's per-expression Range, keyed by
#                     ExprId (cross-reference against hir.txt's e<N> ids)
#   induction.txt     hir::induction::explain: per-parameter induction
#                     provenance -- guard condition, its nesting depth,
#                     recursive update, and the resulting Range, or why an
#                     attempted parameter was not proven
#   short-string.txt  native::shortstr: the ShortString1 plan (SHORT-STRING.md):
#                     per instance and per local String value, the proven
#                     character length, eligibility, physical representation,
#                     production, uses (scalar consumer or materialization
#                     frontier) and the rejection reason of every String
#                     position kept tagged
#   nir.txt           native::nir: the NIR every instance lowers to
#   clif.txt          native::clif: the Cranelift IR of every function
#   roots.txt         native::roots: codegen::roots's per-function GC-root
#                     report (register/safepoint/root-candidate counts and
#                     the resulting shadow-slot count)
#   transport.txt     native::transportCensusText: every fixed-shape struct
#                     construction with its transport distance, direction,
#                     score and budget, frontier and nested cut, the planning
#                     verdicts and the field-hop/histogram metrics
#                     (VALUE-TRANSPORT-MATERIALIZATION.md)
#   program.nir       nir.txt's text again, as a standalone file the Rust
#                     driver (native/target/release/botlish-native) can
#                     take directly: `botlish-native clif|size|object|bench
#                     ... OUTDIR/program.nir` for machine code and
#                     in-process timing.

set root [file dirname [file dirname [file normalize [info script]]]]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]

if {[llength $argv] != 2} {
    puts stderr "usage: tclsh9.0 native/explain-native.tcl PROGRAM.{ir,bot} OUTDIR"
    exit 2
}
lassign $argv path outdir
file mkdir $outdir

if {[file extension $path] eq ".bot"} {
    set hir [surface::readProgramFile $path]
} else {
    # core IR text is read into HIR like any other input notation; native
    # compilation starts from that HIR (DIRECT-HIR-NATIVE-PATH.md).
    set hir [hir::build [core::loadProgramFile $path] -strict 0]
}
# Everything below inspects the HIR native lowering actually compiles.
set hir [native::prepareHir $hir]

proc W {outdir name content} {
    set f [open [file join $outdir $name] w]
    fconfigure $f -encoding utf-8
    puts -nonewline $f $content
    close $f
}

set callFactsOpt [expr {[info exists ::env(BOTLISH_NATIVE_CALL_FACTS_OPT)]
    && $::env(BOTLISH_NATIVE_CALL_FACTS_OPT) eq "0" ? 0 : 1}]
set spec [hir::specialize::analyze $hir -call-facts-opt $callFactsOpt]
set recursiveOpt [expr {[info exists ::env(BOTLISH_NATIVE_RECURSIVE_RESULT_RANGE_OPT)]
    && $::env(BOTLISH_NATIVE_RECURSIVE_RESULT_RANGE_OPT) eq "0" ? 0 : 1}]
set recursiveLimit [expr {[info exists ::env(BOTLISH_NATIVE_RECURSIVE_RANGE_LIMIT)]
    ? $::env(BOTLISH_NATIVE_RECURSIVE_RANGE_LIMIT) : ""}]
set ranges [hir::range::analyze $hir $spec $callFactsOpt 1 1 $recursiveOpt $recursiveLimit]
set rawAbiOpt [expr {[info exists ::env(BOTLISH_NATIVE_RAW_INT_ABI_OPT)]
    && $::env(BOTLISH_NATIVE_RAW_INT_ABI_OPT) eq "0" ? 0 : 1}]
set rawDemandOpt [expr {[info exists ::env(BOTLISH_NATIVE_RAW_DEMAND_OPT)]
    && $::env(BOTLISH_NATIVE_RAW_DEMAND_OPT) eq "0" ? 0 : 1}]
set rawMixedPolicy [expr {[info exists ::env(BOTLISH_NATIVE_RAW_MIXED_POLICY)]
    && $::env(BOTLISH_NATIVE_RAW_MIXED_POLICY) eq "raw" ? "raw" : "boxed"}]
set abiPlan [native::rawabi::plan $hir $spec $ranges $rawAbiOpt 1 $rawDemandOpt $rawMixedPolicy]
W $outdir raw-int-abi.txt [native::rawabi::explainAll $hir $spec $ranges $abiPlan]
W $outdir hir.txt [hir::format $hir]
W $outdir aot.txt [hir::aot::explain $hir]
W $outdir aot-spec.txt [hir::specialize::explain $hir $spec]

set out {}
foreach id [dict get $spec used] {
    set instance [hir::specialize::instance $spec $id]
    set block [dict get $instance block]
    set label [hir::specialize::label $spec $id]
    append out "instance $id ($label): generic=[dict get $instance generic] block=$block\n"
    set pnames {}
    if {$block ne "program"} {
        set pnames [lmap b [hir::get $hir $block params] {dict get [hir::binding $hir $b] name}]
    }
    set pr [dict get [dict get $ranges instances $id] params]
    set i 0
    foreach r $pr {
        set nm [lindex $pnames $i]
        append out "  param $i ($nm) range: [hir::range::show $r]\n"
        incr i
    }
    append out "  result range: [hir::range::show [dict get [dict get $ranges instances $id] result]]\n"
}
W $outdir range-params.txt $out
W $outdir recursive-ranges.txt [hir::range::explainRecursive $spec $ranges 1]

# Per-expr range facts for every used instance, keyed by ExprId (for
# cross-referencing against hir.txt's e<N> ids).
set out2 {}
foreach id [dict get $spec used] {
    append out2 "instance $id:\n"
    set exprs [dict get [dict get $ranges instances $id] exprs]
    foreach e [lsort -dictionary [dict keys $exprs]] {
        append out2 "  $e: [hir::range::show [dict get $exprs $e]]\n"
    }
}
W $outdir range-exprs.txt $out2

# Exact call boundaries: target instance, argument type/range, and the
# successful-result range. This is analysis provenance, not an effect claim.
set callText {}
foreach id [dict get $spec used] {
    set instance [hir::specialize::instance $spec $id]
    set view [hir::specialize::view $hir $spec $id]
    foreach {e target} [dict get $instance calls] {
        if {![hir::get $view $e reachable]} {continue}
        append callText "[hir::specialize::label $spec $id] $e -> [hir::specialize::label $spec $target]\n"
        set i 0
        foreach a [hir::get $view $e args] {
            append callText "  arg$i: [hir::types::show [hir::typeOf $view $a]], range [hir::range::show [hir::range::of $ranges $id $a]]\n"
            incr i
        }
        append callText "  successful result: [hir::types::show [hir::typeOf $view $e]], range [hir::range::show [hir::range::of $ranges $id $e]]\n"
    }
}
W $outdir call-facts.txt $callText

W $outdir induction.txt [hir::induction::explain $hir $spec [dict get $ranges induction]]

set nirText [native::nir $hir]
W $outdir nir.txt $nirText
# The ShortString1 plan of that very lowering (native::lower::program left it
# in native::shortstr's state).
W $outdir short-string.txt [native::shortstr::explainAll]
W $outdir transport.txt [native::transportCensusText $hir]
W $outdir program.nir $nirText

if {[catch {native::clif $hir} clifText]} {
    W $outdir clif.txt "ERROR: $clifText"
} else {
    W $outdir clif.txt $clifText
}

if {[catch {native::roots $hir} rootsText]} {
    W $outdir roots.txt "ERROR: $rootsText"
} else {
    W $outdir roots.txt $rootsText
}

puts "wrote $outdir"
