# explain-native.tcl -- dumps HIR/NIR/Cranelift IR/range facts for any .ir
# program into a directory, for correlating source semantics with generated
# native code (the native-code-quality audit's temporary diagnostic
# tooling; see NATIVE-AUDIT.md). Works structurally on any program: no
# benchmark or function is known by name.
#
#   tclsh9.0 native/explain-native.tcl PROGRAM.ir OUTDIR
#
# Writes, into OUTDIR:
#   hir.txt           hir::format: resolved HIR, one line per expression
#   aot.txt           hir::aot::explain: closed-AOT readiness per function
#   aot-spec.txt      hir::specialize::explain: instances, guards, runtime
#                     requirements per specialization
#   range-params.txt  hir::range::analyze's per-parameter/result Range of
#                     every used instance
#   range-exprs.txt   the same analysis's per-expression Range, keyed by
#                     ExprId (cross-reference against hir.txt's e<N> ids)
#   induction.txt     hir::induction::explain: per-parameter induction
#                     provenance -- guard condition, its nesting depth,
#                     recursive update, and the resulting Range, or why an
#                     attempted parameter was not proven
#   nir.txt           native::nir: the NIR every instance lowers to
#   clif.txt          native::clif: the Cranelift IR of every function
#   roots.txt         native::roots: codegen::roots's per-function GC-root
#                     report (register/safepoint/root-candidate counts and
#                     the resulting shadow-slot count)
#   program.nir       nir.txt's text again, as a standalone file the Rust
#                     driver (native/target/release/botlish-native) can
#                     take directly: `botlish-native clif|size|object|bench
#                     ... OUTDIR/program.nir` for machine code and
#                     in-process timing.

set root [file dirname [file dirname [file normalize [info script]]]]
source [file join $root compiler compiler.tcl]
source [file join $root native native.tcl]

if {[llength $argv] != 2} {
    puts stderr "usage: tclsh9.0 native/explain-native.tcl PROGRAM.ir OUTDIR"
    exit 2
}
lassign $argv path outdir
file mkdir $outdir

set program [core::loadProgramFile $path]
set hir [hir::build $program -strict 0]

proc W {outdir name content} {
    set f [open [file join $outdir $name] w]
    fconfigure $f -encoding utf-8
    puts -nonewline $f $content
    close $f
}

W $outdir hir.txt [hir::format $hir]
W $outdir aot.txt [hir::aot::explain $hir]
W $outdir aot-spec.txt [hir::specialize::explain $hir]

set spec [hir::specialize::analyze $hir]
set ranges [hir::range::analyze $hir $spec]

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

W $outdir induction.txt [hir::induction::explain $hir $spec [dict get $ranges induction]]

set nirText [native::nir $hir]
W $outdir nir.txt $nirText
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
