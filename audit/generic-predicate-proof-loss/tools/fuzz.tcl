#!/usr/bin/env tclsh9.0
# fuzz.tcl -- randomized soundness check of Fixpoint's result-narrowing pass
# (GENERIC-PREDICATE-PROOF-LOSS.md, fix 3: hir/range.tcl's NarrowRounds with
# narrowResults 1, which narrows the callee result summaries a call
# expression reads together with entry and capture facts).
#
#   tclsh9.0 audit/generic-predicate-proof-loss/tools/fuzz.tcl \
#       ?-n N? ?-seed "S ..."? ?-first K? ?-jobs J? ?-slice M? ?-dump 1?
#       ?-roundlimit L? ?-mutate 1? ?-timelimit SECONDS?
#
# Defaults: -n 150 -seed 1 -first 0 -jobs 2 -slice 10 -timelimit 600. The
# committed run and its verdict: ../out/fuzz.txt.
#
# Each seed S drives N programs; program K of seed S is generated from
# srand(S * 100000 + K) alone, so any failure replays exactly with
# `-seed S -first K -n 1 -dump 1`. A program is a chain of NON-recursive
# helper functions (depth up to ~4) over Int: one- and two-sided clamps
# against small or small-Int-boundary constants (+-2^62, +-2^62-1, ...),
# counted `loop i from/down from ... to/through ...` loops with early
# `return`, `continue`/`break` and natural-exhaustion values, `+ - *`,
# comparisons, Bool predicate helpers, helpers whose results are fed to other
# helpers and into branches; closures capturing an Int, and the emailish?
# shape (a String parameter and its length captured by nested scan/char_at
# functions, a predicate passed as a first-class value); and helpers stored
# in a module-level List and called through `list::at(...)(...)`, so open
# (generic) instances exist next to closed ones. Every parameter, local and
# nested function has a program-unique name, which is how the runtime trace
# below maps a Block invocation back to its HIR block. The top level is a
# List literal of direct helper calls.
#
# Oracles, per program:
#
#   DIFFERENTIAL  the reference interpreter, the Tcl compiler and native
#                 (Cranelift, specialized, the knob ON -- what native::lower
#                 consumes) must agree: same value, or same error code.
#
#   RANGE         hir::range::analyze of the program's prepared,
#                 specialized HIR with hir::range::resultNarrowOpt 1:
#                   top   each top-level List element that is a call to a
#                         helper: the interpreter's value must lie in the
#                         Range the program instance claims for that call
#                         ExprId (bounds and exact set). Every violation is
#                         re-checked against the resultNarrowOpt 0 analysis
#                         (pre-existing vs introduced by the pass).
#                   trace the interpreter's every Block invocation, traced
#                         (core::block::invoke): each Int argument must lie
#                         in the join of its block's instances' entry Ranges;
#                         each successful Int result in the join of their
#                         `result` Ranges AND of their call-site summaries
#                         (Fixpoint state calleeResults -- exactly what the
#                         pass narrows); each Int binding the block captures
#                         in Fixpoint's narrowedCaptures Range.
#
#   EXERCISE      the same analysis with resultNarrowOpt 0: does any entry
#                 Range or call-expression Range differ (so the generator
#                 really reaches the pass)? Also counted: programs whose
#                 checked top-level call Ranges differ, the pass's own
#                 converged / not-converged outcome, and any expression whose
#                 knob-on interval is NOT contained in its knob-off interval
#                 (the pass claims it only ever refines).
#
# Isolation: the driver runs programs in worker subprocesses (`-worker 1`),
# SLICE programs per worker, JOBS workers at a time, each under
# `ulimit -v` and `timeout` (as audit/collecting-loops/tools/fuzz.sh does);
# a worker that dies has its unfinished programs re-run one per process, and
# a program that still dies is reported as a LIMIT failure. Generated loops
# have bounded trip counts by construction (a counted loop's domain is at
# most 7 elements, or a String's length), so no program should ever need
# the limits.
#
# Output: FAILURE blocks (with the program text) as they are found -- a
# program whose only failure is a pre-existing disagreement already printed
# in full (same native outcome, ExprIds aside) is listed by reference -- and
# NOTE lines for knob-on intervals not contained in knob-off ones
# (informational: a precision non-monotonicity, not a soundness failure;
# the runtime oracles above are what judge soundness). Then one summary line
# per seed and a total; exit status 1 iff any failure.
#
# Extra options: -roundlimit L sets hir::range::resultNarrowRoundLimit (a
# small L makes the pass give up: its commit-nothing path); -mutate 1 is an
# ORACLE SELF-TEST that makes the pass deliberately unsound (every committed
# summary's finite lower bound raised by one), which must be reported.
#
# Loss point 2 (dormant instances): -knob VAR names the knob the "knob 0"
# side of every comparison above turns off (default
# hir::range::resultNarrowOpt; hir::specialize::dormantOpt for loss point 2:
# its knob-0 analysis re-runs the specialization with the knob off). The
# trace oracle always joins only NON-dormant instances of a block (a dormant
# instance is open and claims nothing, so including it would make the
# oracle vacuous for exactly the blocks loss point 2 is about), so an
# invocation of a block outside its live instances' facts -- including a
# dormant instance actually being entered -- is a violation. -mutate 2 is
# the matching ORACLE SELF-TEST: every used function instance that makes a
# call is declared dormant as well (its calls stop counting while it still
# runs), which must be reported. -nativeopts OPT=V,... passes native::evalHir
# options to the native run (e.g. -block-escape-opt=0, where lowering
# materializes every closure and emits dormant entries).
#
# Loss point 4 (raw counted loops): -knob native::lower::rawCountLoopOpt. A
# knob in native::lower is a LOWERING knob: the analysis does not depend on
# it (the Range comparison above finds nothing), so EXERCISE instead
# compares the program's NIR (native::nir with -nativeopts) knob 0 vs 1
# ("NIR changed by the knob"); the DIFFERENTIAL oracle (native with the
# knob on) is the soundness check, and a disagreement is attributed by
# re-running native with the knob off. -mutate 4 is the matching ORACLE
# SELF-TEST: native::lower::RawCountDomain stops looking at the bounds'
# Ranges (every counted loop is raw), which must be reported. The generator
# also builds numeric lockstep loops (`loop i from .. and j down from ..`,
# equal constant trip counts) for this point.
#
# Loss point 5 (raw internal-variant ABI): -knob
# native::lower::rawInternalAbiOpt, a lowering knob like point 4's.
# -mutate 5 is its ORACLE SELF-TEST: an internal variant (and every call of
# it) also takes raw the Int positions the plan rejected as
# unbounded-or-not-small (caller and callee still agree; the values do not
# fit), which must be reported. The generator also builds self-recursive
# de-closured closures (kind `recclosure`: a bounded non-tail or tail
# recursion over an Int with an Int capture), so internal variants call
# themselves through their raw signature.
set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set script [file normalize [info script]]
set args $argv
set argv {}
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 100000

set n 150
set seeds 1
set first 0
set dump 0
set worker 0
set jobs 2
set slice 10
set roundLimit ""
set mutate 0
set knob hir::range::resultNarrowOpt
set nativeOpts {}
set memLimitKb 4000000
set timeLimit 600
while {[llength $args] > 0} {
    set key [lindex $args 0]
    set value [lindex $args 1]
    switch -- $key {
        -n { set n $value }
        -seed { set seeds $value }
        -first { set first $value }
        -dump { set dump $value }
        -worker { set worker $value }
        -jobs { set jobs $value }
        -slice { set slice $value }
        -roundlimit { set roundLimit $value }
        -mutate { set mutate $value }
        -knob { set knob $value }
        -nativeopts { set nativeOpts $value }
        -timelimit { set timeLimit $value }
        default { puts stderr "unknown option $key"; exit 2 }
    }
    set args [lrange $args 2 end]
}

# -roundlimit L: hir::range::resultNarrowRoundLimit for every analysis and
# native lowering of the run (a small L makes the pass give up, exercising
# its commit-nothing path).
set hir::range::resultNarrowRoundLimit $roundLimit

# -mutate 1: ORACLE SELF-TEST ONLY. Deliberately unsound result narrowing:
# every summary the pass commits gets its finite lower bound raised by one.
# A run with it must report range violations; one without it must not.
if {$mutate == 5} {
    # ORACLE SELF-TEST for loss point 5: raw internal positions the plan
    # proved do not fit the small-Int domain.
    proc native::lower::MutatedRaw {id kind} {
        variable abiPlan
        if {![dict exists $abiPlan $id]} {
            return [expr {$kind eq "result" ? 0 : {}}]
        }
        set p [dict get $abiPlan $id]
        if {$kind eq "result"} {
            return [expr {[dict get $p result] eq "rawint" || [dict get $p resultReason] eq "unbounded-or-not-small"}]
        }
        return [lmap k [dict get $p params] r [dict get $p paramReasons] {
            expr {$k eq "rawint" || $r eq "unbounded-or-not-small"}
        }]
    }
    proc native::lower::InternalAbiParams {id n} {
        variable rawInternalAbiOpt
        set raw [MutatedRaw $id params]
        set out {}
        for {set i 0} {$i < $n} {incr i} {
            lappend out [expr {$rawInternalAbiOpt && [lindex $raw $i] eq "1"}]
        }
        return $out
    }
    proc native::lower::InternalAbiResult {id} {
        variable rawInternalAbiOpt
        return [expr {$rawInternalAbiOpt && [MutatedRaw $id result]}]
    }
} elseif {$mutate == 4} {
    # ORACLE SELF-TEST for loss point 4: a raw induction register whatever
    # the bounds' Ranges say (unsound for a bound outside the small-Int
    # domain).
    proc native::lower::RawCountDomain {ranges id startExpr endExpr} {
        variable reprOpt
        variable rawCountLoopOpt
        return [expr {$reprOpt && $rawCountLoopOpt}]
    }
} elseif {$mutate == 2} {
    rename hir::specialize::DormantInstances hir::specialize::DormantInstancesOriginal
    proc hir::specialize::DormantInstances {snapshot blockescape} {
        set dormant [DormantInstancesOriginal $snapshot $blockescape]
        if {!$::hir::specialize::dormantOpt} {
            return $dormant
        }
        foreach id [dict get $snapshot used] {
            set instance [dict get $snapshot instances $id]
            if {[dict get $instance block] ne "program" && [dict size [dict get $instance calls]]} {
                dict set dormant $id 1
            }
        }
        return $dormant
    }
} elseif {$mutate} {
    rename hir::range::NarrowRounds hir::range::NarrowRoundsOriginal
    proc hir::range::NarrowRounds {ctx narrowed captures results narrowResults roundBudget} {
        set out [NarrowRoundsOriginal $ctx $narrowed $captures $results $narrowResults $roundBudget]
        if {$narrowResults} {
            set rs [lindex $out 3]
            dict for {id r} $rs {
                if {$r ne "never" && [dict get $r min] ne "-inf" && [dict get $r max] ne "+inf"
                        && [dict get $r min] < [dict get $r max]} {
                    dict set rs $id [dict create min [expr {[dict get $r min] + 1}] max [dict get $r max]]
                }
            }
            lset out 3 $rs
            # no reusable last round: Fixpoint recomputes every instance
            # under the mutated summaries, so call expressions read them
            lset out 5 ""
        }
        return $out
    }
}

proc pick {list} { return [lindex $list [expr {int(rand() * [llength $list])}]] }
proc chance {p} { return [expr {rand() < $p}] }
proc rnd {lo hi} { return [expr {$lo + int(rand() * ($hi - $lo + 1))}] }
proc programSeed {seed k} { return [expr {$seed * 100000 + $k}] }

# ---------------------------------------------------------------------------
# Generator
#
# ::H is the list of helpers emitted so far, each a dict:
#   name    fN
#   kind    clamp loop arith branch closure scan bool apply
#   params  parameter names; ptypes: int | str per parameter
#   ret     int | bool
#   size    (apply only) the table length
# Expressions only ever call helpers emitted before them (no recursion).

proc lit {v} { return [expr {$v < 0 ? "($v)" : $v}] }
proc smallConst {} { return [rnd -8 20] }
proc edgeConst {} {
    return [pick {4611686018427387903 4611686018427387904 4611686018427387902
        -4611686018427387904 -4611686018427387905 -4611686018427387903
        9223372036854775807 -9223372036854775808 2305843009213693952 1000000}]
}
proc anyConst {{edge 0.25}} { return [expr {[chance $edge] ? [edgeConst] : [smallConst]}] }
proc strLit {} {
    return "\"[pick {{} a ab {ab cd} abc xxax {hello world} {a-b.c} {x} {aaa bbb} {zz9} {b a} {é x}}]\""
}

# Helpers by role.
proc intHelpers {} {
    return [lmap h $::H {expr {[dict get $h ret] eq "int" ? $h : [continue]}}]
}
proc boolHelpers {} {
    return [lmap h $::H {expr {[dict get $h ret] eq "bool" ? $h : [continue]}}]
}
# One-Int-parameter Int helpers: the ones a first-class table may hold.
proc singleHelpers {} {
    return [lmap h $::H {expr {[dict get $h ret] eq "int" && [dict get $h ptypes] eq "int"
        && [dict get $h kind] ne "apply" ? $h : [continue]}}]
}

# A call of helper H with arguments built from VARS at DEPTH.
proc callText {h vars depth} {
    set args {}
    switch [dict get $h kind] {
        apply {
            lappend args [rnd 0 [expr {[dict get $h size] - 1}]] [intExpr $vars $depth]
        }
        default {
            foreach t [dict get $h ptypes] {
                lappend args [expr {$t eq "str" ? [strLit] : [intExpr $vars $depth]}]
            }
        }
    }
    return "[dict get $h name]([join $args {, }])"
}

proc atom {vars} {
    if {[llength $vars] > 0 && [chance 0.75]} {
        return [pick $vars]
    }
    return [lit [anyConst 0.2]]
}

proc intExpr {vars depth} {
    set helpers [intHelpers]
    if {$depth <= 0 || [chance 0.3]} {
        return [atom $vars]
    }
    set r [rnd 0 9]
    if {$r <= 3 && [llength $helpers] > 0} {
        return [callText [pick $helpers] $vars [expr {$depth - 1}]]
    }
    switch [rnd 0 3] {
        0 { return "[atom $vars] + [lit [smallConst]]" }
        1 { return "[atom $vars] - [lit [smallConst]]" }
        2 { return "[atom $vars] * [lit [pick {2 3 -1 -2}]]" }
        3 { return "[intExpr $vars [expr {$depth - 1}]] [pick {+ - +}] [atom $vars]" }
    }
}

proc condExpr {vars depth} {
    set bools [boolHelpers]
    set r [rnd 0 9]
    if {$r == 0 && [llength $bools] > 0} {
        set h [pick $bools]
        return [callText $h $vars [expr {$depth - 1}]]
    }
    set c "[intExpr $vars $depth] [pick {> >= < <= == !=}] [intExpr $vars [expr {$depth - 1}]]"
    if {$r == 1} {
        append c " [pick {and or}] [atom $vars] [pick {> < ==}] [lit [anyConst]]"
    } elseif {$r == 2} {
        set c "not ($c)"
    }
    return $c
}

proc indent {lines levels} {
    set pad [string repeat "    " $levels]
    return [lmap line $lines {string cat $pad $line}]
}

proc newHelper {kind params ptypes ret} {
    return [dict create name "f[expr {[llength $::H] + 1}]" kind $kind params $params ptypes $ptypes ret $ret]
}

proc intParams {f count} {
    return [lrange [list ${f}_a ${f}_b] 0 [expr {$count - 1}]]
}

# Each gen* returns {HELPER LINES} where LINES is the whole definition,
# preceded by any module-level bindings it needs.

proc genClamp {} {
    set h [newHelper clamp {} {} int]
    set f [dict get $h name]
    set ps [intParams $f [rnd 1 2]]
    dict set h params $ps
    dict set h ptypes [lrepeat [llength $ps] int]
    # mostly a function of the parameters (what the entries narrow)
    set helpers [intHelpers]
    set x [pick [list [pick $ps] "[pick $ps] [pick {+ - *}] [lit [smallConst]]" [intExpr $ps 2] \
        [expr {[llength $helpers] > 0 ? [callText [pick $helpers] $ps 1] : [pick $ps]}]]]
    set body [list "${f}_x = $x"]
    set vars [concat $ps ${f}_x]
    set c1 [anyConst 0.3]
    set cmp [pick {> >= < <=}]
    lappend body "if ${f}_x $cmp [lit $c1]:"
    lappend body "    [pick [list [lit $c1] "[lit $c1] + [lit [smallConst]]" [lit [anyConst]] "${f}_x - [lit [smallConst]]"]]"
    lappend body "else:"
    if {[chance 0.4]} {
        # two-sided: the other side bounded by a second constant
        set c0 [anyConst 0.3]
        set cmp2 [expr {$cmp in {> >=} ? [pick {< <=}] : [pick {> >=}]}]
        lappend body "    if ${f}_x $cmp2 [lit $c0]:" "        [lit $c0]" "    else:" \
            "        [pick [list ${f}_x "${f}_x + [lit [smallConst]]" "${f}_x * 2"]]"
    } else {
        lappend body "    [pick [list ${f}_x "${f}_x + [lit [smallConst]]" "[intExpr $vars 1]"]]"
    }
    return [list $h [concat [list "fn $f\([join $ps {, }]):"] [indent $body 1]]]
}

proc genLoop {} {
    set h [newHelper loop {} {} int]
    set f [dict get $h name]
    set ps [intParams $f [rnd 1 2]]
    dict set h params $ps
    dict set h ptypes [lrepeat [llength $ps] int]
    set s ${f}_s
    set i ${f}_i
    set k [rnd 0 6]
    set body [list "$s = [intExpr $ps 2]"]
    switch [rnd 0 5] {
        0 { set header "loop $i from $s to $s + $k:"; set natural "$s + $k" }
        1 { set header "loop $i from $s through $s + $k:"; set natural "$s + $k" }
        2 { set header "loop $i down from $s to $s - $k:"; set natural "$s - $k" }
        3 { set header "loop $i down from $s through $s - $k:"; set natural "$s - $k" }
        4 {
            set c0 [anyConst 0.2]
            set header "loop $i from [lit $c0] to [lit [expr {$c0 + $k}]]:"
            set natural [lit [expr {$c0 + $k}]]
        }
        5 {
            # a numeric lockstep loop (equal constant trip counts); the
            # second domain runs down from another expression
            set j ${f}_j
            set t ${f}_t
            lappend body "$t = [intExpr $ps 1]"
            if {[chance 0.5]} {
                set second "$j down from $t to $t - $k"
            } else {
                set second "$j down from $t through $t - [lit [expr {$k - 1}]]"
            }
            set header "loop $i from $s to $s + $k and $second:"
            set natural "$s + $k"
        }
    }
    lappend body $header
    set vars [concat $ps $s $i]
    if {[info exists j]} {
        lappend vars $j
    }
    if {[chance 0.3]} {
        lappend body "    if $i == $s + [rnd 0 3]:" "        continue"
    }
    set helpers [intHelpers]
    set conds [list "$i == $s + [rnd 0 $k]" "$i - $s == [rnd -3 $k]" "$i > [pick $ps]" \
        "$i * 2 >= [pick $ps]" "$i >= [lit [anyConst]]" "$i <= [lit [anyConst]]" \
        "[condExpr $vars 1]"]
    if {[llength $helpers] > 0} {
        lappend conds "[callText [pick $helpers] [list $i] 1] [pick {> >= == <}] [lit [anyConst]]"
    }
    lappend body "    if [pick $conds]:"
    set rets [list $i "$i + [lit [smallConst]]" "$i - $s" [lit [anyConst]] "$i * [pick {2 -1 3}]"]
    if {[info exists j]} {
        # a lockstep loop's second domain, observed (boxed) too
        lappend rets $j "$i - $j" "$j * 2"
    }
    if {[llength $helpers] > 0} {
        lappend rets [callText [pick $helpers] [list $i $s] 1]
    }
    lappend body "        return [pick $rets]"
    if {[chance 0.25]} {
        lappend body "    if $i == $s + [rnd 0 4]:" "        break"
    }
    set exits [list $natural $natural $s [lit [anyConst]] [pick $ps] "(-1)"]
    if {[llength $helpers] > 0} {
        lappend exits [callText [pick $helpers] [list $s] 1]
    }
    lappend body [pick $exits]
    return [list $h [concat [list "fn $f\([join $ps {, }]):"] [indent $body 1]]]
}

proc genArith {} {
    set h [newHelper arith {} {} int]
    set f [dict get $h name]
    set ps [intParams $f [rnd 1 2]]
    dict set h params $ps
    dict set h ptypes [lrepeat [llength $ps] int]
    set helpers [intHelpers]
    set x [expr {[llength $helpers] > 0 ? [callText [pick $helpers] $ps 2] : [intExpr $ps 2]}]
    set body [list "${f}_x = $x" "${f}_y = [intExpr [concat $ps ${f}_x] 2]"]
    lappend body [pick [list "${f}_x + ${f}_y" "${f}_x - ${f}_y" "${f}_x * [lit [pick {2 3 -1}]] + ${f}_y" \
        "${f}_x - [lit [anyConst]]" "${f}_y"]]
    return [list $h [concat [list "fn $f\([join $ps {, }]):"] [indent $body 1]]]
}

proc genBranch {} {
    set h [newHelper branch {} {} int]
    set f [dict get $h name]
    set ps [intParams $f [rnd 1 2]]
    dict set h params $ps
    dict set h ptypes [lrepeat [llength $ps] int]
    set helpers [intHelpers]
    set r [expr {[llength $helpers] > 0 ? [callText [pick $helpers] $ps 2] : [intExpr $ps 2]}]
    set body [list "${f}_r = $r"]
    set vars [concat $ps ${f}_r]
    if {[chance 0.5]} {
        lappend body "${f}_q = if [condExpr $vars 2]:" "    [intExpr $vars 2]" "else:" "    [intExpr $vars 2]"
        lappend body [pick [list "${f}_q + [lit [smallConst]]" "${f}_q - ${f}_r" "${f}_q"]]
    } else {
        lappend body "if [condExpr $vars 2]:" "    [intExpr $vars 2]" "else:" "    [intExpr $vars 2]"
    }
    return [list $h [concat [list "fn $f\([join $ps {, }]):"] [indent $body 1]]]
}

proc genClosure {} {
    set h [newHelper closure {} {} int]
    set f [dict get $h name]
    set ps [intParams $f [rnd 1 2]]
    dict set h params $ps
    dict set h ptypes [lrepeat [llength $ps] int]
    set g ${f}_g
    set x ${g}_x
    set kk ${f}_k
    set body [list "$kk = [intExpr $ps 2]" "fn $g\($x):"]
    if {[chance 0.5]} {
        lappend body "    if $x [pick {> >= <}] $kk:" "        $kk" "    else:" \
            "        [pick [list "$x + [lit [smallConst]]" $x "$x - $kk" "[pick $ps] + $x"]]"
    } else {
        set i ${g}_i
        set k [rnd 0 5]
        lappend body "    loop $i from $x to $x + $k:" "        if $i >= $kk:" \
            "            return [pick [list "$i - $x" $i "$kk"]]" \
            "    [pick [list $kk "$x + $k" [pick $ps]]]"
    }
    set helpers [intHelpers]
    set calls [list "$g\([lit [smallConst]]) + $g\([pick $ps])" "$g\($g\([pick $ps]))" \
        "$g\([pick $ps]) - $kk"]
    if {[llength $helpers] > 0} {
        lappend calls "$g\([callText [pick $helpers] $ps 1])"
    }
    lappend body [pick $calls]
    return [list $h [concat [list "fn $f\([join $ps {, }]):"] [indent $body 1]]]
}

# A self-recursive de-closured closure: a bounded recursion over an Int
# (clamped to [0, 6]) with an Int capture, non-tail (the result feeds an
# addition) or tail (an accumulator).
proc genRecclosure {} {
    set h [newHelper recclosure {} {} int]
    set f [dict get $h name]
    set ps [intParams $f [rnd 1 2]]
    dict set h params $ps
    dict set h ptypes [lrepeat [llength $ps] int]
    set r ${f}_r
    set x ${r}_x
    set kk ${f}_k
    set c ${f}_c
    set a [pick $ps]
    set body [list "$kk = [intExpr $ps 2]" "$c = if $a < 0:" "    0" "else:" "    if $a > 6:" "        6"         "    else:" "        $a"]
    if {[chance 0.5]} {
        lappend body "fn $r\($x):" "    if $x <= 0:" "        [pick [list $kk "$kk + 1" "$kk - [lit [anyConst]]"]]"             "    else:" "        $r\($x - 1) [pick {+ -}] [pick [list $kk $x "$x * 2" [lit [smallConst]]]]"
        set call "$r\($c)"
    } else {
        set acc ${r}_acc
        lappend body "fn $r\($x, $acc):" "    if $x <= 0:" "        $acc + $kk" "    else:"             "        $r\($x - 1, $acc [pick {+ -}] [pick [list $kk $x [lit [anyConst]]]])"
        set call "$r\($c, [pick [list 0 $kk [lit [anyConst]]]])"
    }
    lappend body [pick [list $call "$call + $c" "$call - [pick $ps]"]]
    return [list $h [concat [list "fn $f\([join $ps {, }]):"] [indent $body 1]]]
}

# The emailish? shape: a String and its length captured by nested functions,
# a counted scan with an early return and the length as exhaustion value.
proc genScan {} {
    set h [newHelper scan {} {} int]
    set f [dict get $h name]
    set v ${f}_v
    set a ${f}_a
    dict set h params [list $v $a]
    dict set h ptypes {str int}
    set n ${f}_n
    set at ${f}_at
    set scan ${f}_scan
    set si ${scan}_i
    set ss ${scan}_start
    set body [list "$n = str::length($v)" "fn $at\(${at}_i):" "    str::substring($v, ${at}_i, ${at}_i + 1)"]
    set predArg ""
    if {[chance 0.6]} {
        # predicate passed as a first-class value
        set sp ${scan}_pred
        if {[chance 0.5]} {
            set pc ${f}_p_c
            lappend body "fn ${f}_p($pc):" \
                "    [pick [list "$pc == \"a\" or $pc == \"b\"" "str::is_tcl_alnum($pc) or $pc == \"-\"" "$pc != \" \""]]"
            set predArg ${f}_p
        } else {
            set predArg [pick {str::is_tcl_alpha str::is_tcl_alnum}]
        }
        lappend body "fn $scan\($ss, $sp):" "    loop $si from $ss to $n:" \
            "        if $sp\($at\($si)):" "            continue" "        return $si" "    $n"
        set call [list $scan $predArg]
    } else {
        lappend body "fn $scan\($ss):" "    loop $si from $ss to $n:" \
            "        if $at\($si) == \"[pick {a x { } b}]\":" "            return $si" "    $n"
        set call [list $scan]
    }
    set st ${f}_st
    switch [rnd 0 3] {
        0 { lappend body "$st = if $a < 0:" "    0" "else:" "    $a" }
        1 { lappend body "$st = [rnd 0 1]" }
        2 {
            set helpers [intHelpers]
            if {[llength $helpers] > 0} {
                lappend body "${f}_t = [callText [pick $helpers] [list $a] 1]" \
                    "$st = if ${f}_t < 0:" "    0" "else:" "    ${f}_t"
            } else {
                lappend body "$st = if $a > $n:" "    $n" "else:" "    $a"
            }
        }
        3 { lappend body "$st = if $a < 0:" "    0" "else:" "    if $a > $n:" "        $n" "    else:" "        $a" }
    }
    set e ${f}_e
    lappend body "$e = [lindex $call 0]\([join [concat $st [lrange $call 1 end]] {, }])"
    switch [rnd 0 3] {
        0 { lappend body "if $e == $n:" "    $e - $st" "else:" "    $e - $st + [lit [anyConst]]" }
        1 { lappend body $e }
        2 { lappend body "$e - $st" }
        3 {
            lappend body "${f}_e2 = [lindex $call 0]\([join [list "$e + 1" {*}[lrange $call 1 end]] {, }])" \
                "${f}_e2 - $e"
        }
    }
    return [list $h [concat [list "fn $f\($v, $a):"] [indent $body 1]]]
}

proc genBool {} {
    set h [newHelper bool {} {} bool]
    set f [dict get $h name]
    set a ${f}_a
    dict set h params [list $a]
    dict set h ptypes int
    set helpers [intHelpers]
    set forms [list "$a > [lit [anyConst]] and $a < [lit [anyConst]]" "not ($a == [lit [smallConst]])" \
        "$a * 2 >= [lit [anyConst]]"]
    if {[llength $helpers] > 0} {
        lappend forms "[callText [pick $helpers] [list $a] 1] [pick {== > <=}] [lit [anyConst]]"
    }
    return [list $h [list "fn $f\($a):" "    [pick $forms]"]]
}

proc genApply {} {
    set singles [singleHelpers]
    set h [newHelper apply {} {} int]
    set f [dict get $h name]
    set members {}
    foreach unused [lrepeat [rnd 1 3] x] {
        lappend members [dict get [pick $singles] name]
    }
    dict set h size [llength $members]
    dict set h params [list ${f}_i ${f}_v]
    dict set h ptypes {int int}
    set lines [list "${f}_tbl = \[[join $members {, }]\]" "fn $f\(${f}_i, ${f}_v):"]
    if {[chance 0.5]} {
        lappend lines "    list::at(${f}_tbl, ${f}_i)(${f}_v)"
    } else {
        lappend lines "    ${f}_h = list::at(${f}_tbl, ${f}_i)" \
            "    ${f}_h(${f}_v) [pick {+ -}] ${f}_h(${f}_v + [lit [smallConst]])"
    }
    return [list $h $lines]
}

# The top-level argument text for a parameter of type T.
proc topArg {t locals} {
    if {$t eq "str"} {
        return [strLit]
    }
    if {[llength $locals] > 0 && [chance 0.2]} {
        return [pick $locals]
    }
    return [lit [anyConst 0.3]]
}

proc topCall {h locals} {
    set f [dict get $h name]
    switch [dict get $h kind] {
        apply {
            set idx [expr {[chance 0.03] ? [dict get $h size] : [rnd 0 [expr {[dict get $h size] - 1}]]}]
            return "$f\($idx, [topArg int $locals])"
        }
        scan {
            # mostly a valid start; occasionally a negative one (an error
            # path every backend must agree on, unless the helper clamps it)
            set a [expr {[chance 0.85] ? [rnd 0 6] : [anyConst 0.4]}]
            return "$f\([strLit], [lit $a])"
        }
        default {
            return "$f\([join [lmap t [dict get $h ptypes] {topArg $t $locals}] {, }])"
        }
    }
}

proc genProgram {} {
    set ::H {}
    set lines {}
    set count [rnd 2 6]
    for {set j 0} {$j < $count} {incr j} {
        set kinds {clamp clamp clamp loop loop loop arith arith branch branch closure closure recclosure scan bool}
        if {[llength [singleHelpers]] > 0} {
            lappend kinds apply apply
        }
        set kind [pick $kinds]
        if {$kind eq "bool" && $j == $count - 1 && [llength [intHelpers]] == 0} {
            # the top level calls Int helpers: there must be one
            set kind clamp
        }
        lassign [gen[string totitle $kind]] h hlines
        lappend ::H $h
        lappend lines {*}$hlines ""
    }
    set ints [intHelpers]
    set locals {}
    foreach unused [lrepeat [rnd 0 2] x] {
        set t "t[expr {[llength $locals] + 1}]"
        lappend lines "$t = [topCall [pick $ints] $locals]"
        lappend locals $t
    }
    # Bias toward the later helpers: they call the earlier ones.
    set calls {}
    set late [lrange $ints [expr {[llength $ints] / 2}] end]
    foreach unused [lrepeat [rnd 3 8] x] {
        lappend calls [topCall [pick [expr {[chance 0.6] ? $late : $ints}]] $locals]
    }
    lappend lines "\[[join $calls {, }]\]"
    return [join $lines \n]\n
}

# ---------------------------------------------------------------------------
# Running

# The -nativeopts options as a native::evalHir / native::nir option list.
proc nativeOptions {} {
    set opts {}
    foreach pair [split $::nativeOpts ,] {
        if {$pair ne ""} { lappend opts {*}[split $pair =] }
    }
    return $opts
}

proc outcome {kind hir} {
    if {[catch {
        switch $kind {
            interp  { core::useBackend interp;  set r [core::evalProgram [hir::lower $hir]] }
            compile { core::useBackend compile; set r [core::evalProgram [hir::lower $hir]] }
            native  { set r [native::evalHir $hir {*}[nativeOptions]] }
        }
    } msg opts]} {
        return [list error [dict get $opts -errorcode] $msg]
    }
    return [list value [core::value::show $r 1] $r]
}

# The interpreter's Block invocations: {PARAMS ARGS COMPLETION ENV}.
set ::observed {}
proc ::Probe {command code result op} {
    if {$code != 0} {
        return
    }
    set block [lindex $command 1]
    lappend ::observed [list [core::value::blockParams $block] [lindex $command 2] $result \
        [core::value::blockEnv $block]]
}

proc inRange {v r} {
    if {$r eq "never"} {
        return 0
    }
    set mn [dict get $r min]
    set mx [dict get $r max]
    if {$mn ne "-inf" && $v < $mn} { return 0 }
    if {$mx ne "+inf" && $v > $mx} { return 0 }
    if {[dict exists $r exact]} {
        foreach x [dict get $r exact] {
            if {$x == $v} { return 1 }
        }
        return 0
    }
    return 1
}

# 1 iff R1's interval lies within R0's.
proc within {r1 r0} {
    if {$r1 eq "never" || $r0 eq "never"} {
        return [expr {$r1 eq "never" || $r0 ne "never"}]
    }
    set mn0 [dict get $r0 min]; set mx0 [dict get $r0 max]
    set mn1 [dict get $r1 min]; set mx1 [dict get $r1 max]
    if {$mn0 ne "-inf" && ($mn1 eq "-inf" || $mn1 < $mn0)} { return 0 }
    if {$mx0 ne "+inf" && ($mx1 eq "+inf" || $mx1 > $mx0)} { return 0 }
    return 1
}

proc showRange {r} { return [hir::range::show $r] }

# Block -> {params {R...} exprs {e R ...}}: the join over the block's used,
# non-dormant instances of SPEC (program included) in ANALYSIS.
proc blockJoins {spec analysis} {
    set dormant [expr {[dict exists $spec dormant] ? [dict get $spec dormant] : {}}]
    set joins [dict create]
    foreach id [dict get $spec used] {
        if {[dict exists $dormant $id]} continue
        set block [dict get $spec instances $id block]
        set inst [dict get $analysis instances $id]
        if {![dict exists $joins $block]} {
            dict set joins $block [dict create params [dict get $inst params] exprs [dict get $inst exprs]]
            continue
        }
        set b [dict get $joins $block]
        dict set b params [lmap x [dict get $b params] y [dict get $inst params] {hir::range::join $x $y}]
        set ex [dict get $b exprs]
        dict for {e r} [dict get $inst exprs] {
            dict set ex $e [expr {[dict exists $ex $e] ? [hir::range::join [dict get $ex $e] $r] : $r}]
        }
        dict set b exprs $ex
        dict set joins $block $b
    }
    return $joins
}

proc analyzeWith {opt hir spec} {
    set ::$::knob $opt
    try {
        if {$::knob ne "hir::range::resultNarrowOpt"} {
            # A specialization knob (hir::specialize::dormantOpt,
            # closureIntKeyOpt): the specialization itself is computed with
            # it.
            set spec [hir::specialize::analyze $hir]
        }
        set ::knobSpec($opt) $spec
        return [hir::range::analyze $hir $spec]
    } finally {
        set ::$::knob 1
    }
}

# Checks program K of SEED. Returns its record (a dict): status ok |
# rejected | harness-error; failures {{KIND DETAIL} ...}; and counters.
# Program K of SEED's text (the generator is a pure function of the seed).
proc programText {seed k} {
    expr {srand([programSeed $seed $k])}
    return [genProgram]
}

proc checkProgram {seed k} {
    expr {srand([programSeed $seed $k])}
    set ::lastText ""
    set text [genProgram]
    set ::lastText $text
    set rec [dict create k $k status ok failures {} text $text]
    if {$::dump} {
        puts "--- seed $seed program $k\n$text"
    }
    if {[catch {surface::compile $text fuzz.bot -strict 0} hir]} {
        return [dict merge $rec [dict create status rejected detail $hir]]
    }
    if {[hir::diagnostics $hir] ne ""} {
        return [dict merge $rec [dict create status rejected detail [hir::diagnostics $hir]]]
    }
    if {[catch {
        set prepared [native::prepareHir $hir]
        set spec [hir::specialize::analyze $prepared]
        set a1 [analyzeWith 1 $prepared $spec]
        set a0 [analyzeWith 0 $prepared $spec]
        set state [dict get [hir::range::Fixpoint $prepared $spec 1 1 1 [dict create]] state]
    } message options]} {
        dict lappend rec failures [list analysis-error "[dict get $options -errorcode]: $message"]
        return $rec
    }
    dict set rec resultNarrow [dict get $state resultNarrow]
    # an open (unknown-ingress) instance of a program function
    set openHelper 0
    foreach id [dict keys [dict get $state open]] {
        if {[dict get [hir::specialize::instance $spec $id] block] ne "program"} { set openHelper 1 }
    }
    dict set rec openInstance $openHelper
    set dormant [expr {[dict exists $spec dormant] ? [dict get $spec dormant] : {}}]
    dict set rec dormant [expr {[dict size $dormant] > 0}]

    # -- runs
    set ::observed {}
    trace add execution core::block::invoke leave ::Probe
    try {
        set oi [outcome interp $hir]
    } finally {
        trace remove execution core::block::invoke leave ::Probe
    }
    set observed $::observed
    set ::observed {}
    set oc [outcome compile $hir]
    set on [outcome native $prepared]
    dict set rec interpError [expr {[lindex $oi 0] eq "error"}]
    set norm [lmap o [list $oi $oc $on] {lrange $o 0 1}]
    if {[llength [lsort -unique $norm]] != 1} {
        set kind [expr {[string match "NATIVE UNSUPPORTED*" [lindex $on 1]] ? "native-unsupported" : "disagreement"}]
        # Attribution: native again with the pass off. The same native
        # outcome there means the disagreement predates the pass.
        set ::$::knob 0
        try {
            set on0 [outcome native $prepared]
        } finally {
            set ::$::knob 1
        }
        set origin [expr {[lrange $on0 0 2] eq [lrange $on 0 2]
            ? "pre-existing: identical with $::knob 0"
            : "INTRODUCED by the pass: $::knob 0 native gives [lrange $on0 0 2]"}]
        dict lappend rec failures [list $kind \
            "interp:  [lrange $oi 0 2]\ncompile: [lrange $oc 0 2]\nnative:  [lrange $on 0 2]\n($origin)"]
    } elseif {[lindex $oi 0] eq "error" && [llength [lsort -unique [lmap o [list $oi $oc $on] {lindex $o 2}]]] != 1} {
        dict set rec messageMismatch 1
    }

    # -- instance tables
    set progId ""
    set blocksOf [dict create]   ;# block ExprId -> instance ids
    set blockOfKey [dict create] ;# "param names" -> block ExprId
    foreach id [dict get $spec used] {
        set block [dict get [hir::specialize::instance $spec $id] block]
        if {$block eq "program"} {
            set progId $id
            continue
        }
        dict lappend blocksOf $block $id
        set names [lmap b [hir::get $prepared $block params] {dict get [hir::binding $prepared $b] name}]
        dict set blockOfKey $names $block
    }

    # -- EXERCISE: knob 0 vs 1
    set changed 0
    set exprChanged 0
    set notRefinement {}
    set narrower 0
    if {$::knob ne "hir::range::resultNarrowOpt"} {
        # A specialization knob may change the instances (closureIntKeyOpt
        # changes keys): compare per function, the join over its live
        # (non-dormant) instances, as census-blocks.tcl does.
        set j1 [blockJoins $::knobSpec(1) $a1]
        set j0 [blockJoins $::knobSpec(0) $a0]
        dict for {block b1} $j1 {
            if {![dict exists $j0 $block]} continue
            set b0 [dict get $j0 $block]
            foreach r1 [dict get $b1 params] r0 [dict get $b0 params] {
                if {$r1 ne $r0} { set changed 1 }
                if {![within $r1 $r0]} { lappend notRefinement "$block param [showRange $r0] -> [showRange $r1]" }
                if {$r1 ne $r0 && [within $r1 $r0] && ![within $r0 $r1]} { set narrower 1 }
            }
            dict for {e r1} [dict get $b1 exprs] {
                set r0 [expr {[dict exists $b0 exprs $e] ? [dict get $b0 exprs $e] : [hir::range::unknown]}]
                if {$r1 eq $r0} continue
                set exprChanged 1
                if {![catch {hir::kind $prepared $e} kind] && $kind eq "call"} { set changed 1 }
                if {![within $r1 $r0]} { lappend notRefinement "$block $e [showRange $r0] -> [showRange $r1]" }
                if {[within $r1 $r0] && ![within $r0 $r1]} { set narrower 1 }
            }
        }
    }
    foreach id [expr {$::knob eq "hir::range::resultNarrowOpt" ? [dict get $spec used] : {}}] {
        set i1 [dict get $a1 instances $id]
        set i0 [dict get $a0 instances $id]
        foreach r1 [dict get $i1 params] r0 [dict get $i0 params] {
            if {$r1 ne $r0} { set changed 1 }
            if {![within $r1 $r0]} { lappend notRefinement "$id param [showRange $r0] -> [showRange $r1]" }
        }
        set view [hir::specialize::view $prepared $spec $id]
        dict for {e r1} [dict get $i1 exprs] {
            set r0 [expr {[dict exists $i0 exprs $e] ? [dict get $i0 exprs $e] : [hir::range::unknown]}]
            if {$r1 eq $r0} continue
            set exprChanged 1
            if {![catch {hir::kind $view $e} kind] && $kind eq "call"} { set changed 1 }
            if {![within $r1 $r0]} { lappend notRefinement "$id $e [showRange $r0] -> [showRange $r1]" }
        }
    }
    if {[string match "native::lower::*" $::knob]} {
        # A lowering knob: the analysis is the same either way; what it
        # changes is the NIR.
        set nirs {}
        foreach opt {0 1} {
            set ::$::knob $opt
            try {
                lappend nirs [native::nir $prepared {*}[nativeOptions]]
            } finally {
                set ::$::knob 1
            }
        }
        dict set rec nirChanged [expr {[lindex $nirs 0] ne [lindex $nirs 1]}]
    }
    dict set rec changed $changed
    dict set rec exprChanged $exprChanged
    dict set rec narrower $narrower
    if {$notRefinement ne ""} {
        dict set rec notRefinement [lrange $notRefinement 0 4]
    }

    # -- RANGE (top): the top-level List's helper-call elements
    set helperNames [lmap h $::H {dict get $h name}]
    set topChecks 0
    set topChanged 0
    set last [lindex [dict get $prepared roots] end]
    set items [expr {[lindex $oi 0] eq "value" ? [core::value::items [lindex $oi 2]] : {}}]
    set index 0
    foreach e [hir::get $prepared $last args] {
        set item [lindex $items $index]
        incr index
        if {[hir::kind $prepared $e] ne "call"} continue
        set callee [hir::get $prepared $e callee]
        if {[hir::kind $prepared $callee] ne "ref"} continue
        set b [hir::get $prepared $callee binding]
        if {$b eq "" || [dict get [hir::binding $prepared $b] name] ni $helperNames} continue
        set r1 [hir::range::of $a1 $progId $e]
        set r0 [hir::range::of $a0 $progId $e]
        if {$r1 ne $r0} { set topChanged 1 }
        if {$item eq "" || [core::value::kind $item] ne "int"} continue
        incr topChecks
        set v [core::value::intOf $item]
        if {![inRange $v $r1]} {
            dict lappend rec failures [list range-top \
                "element $index ($e, [dict get [hir::binding $prepared $b] name]) = $v not in [showRange $r1]\
                 ($::knob 0: [showRange $r0], [expr {[inRange $v $r0] ? "contains it: INTRODUCED by the pass" : "violated too: pre-existing"}])"]
        }
    }
    dict set rec topChecks $topChecks
    dict set rec topChanged $topChanged

    # -- RANGE (trace): every Block invocation the interpreter made
    set entryJoin [dict create]
    set resultJoin [dict create]
    set summaryJoin [dict create]
    dict for {block ids} $blocksOf {
        set ej {}
        set rj never
        set sj never
        set ids [lmap id $ids {expr {[dict exists $dormant $id] ? [continue] : $id}}]
        if {$ids eq ""} {
            # Every instance is dormant: the block must never run.
            dict set entryJoin $block dormant
            continue
        }
        foreach id $ids {
            set inst [dict get $a1 instances $id]
            if {$ej eq ""} {
                set ej [dict get $inst params]
            } else {
                set ej [lmap x $ej y [dict get $inst params] {hir::range::join $x $y}]
            }
            set rj [hir::range::join $rj [dict get $inst result]]
            if {[dict exists $state calleeResults $id]} {
                set sj [hir::range::join $sj [dict get $state calleeResults $id]]
            } else {
                # an instance with no summary: no call site reads one
                set sj [hir::range::join $sj [hir::range::unknown]]
            }
        }
        dict set entryJoin $block $ej
        dict set resultJoin $block $rj
        dict set summaryJoin $block $sj
    }
    set captures [dict get $state narrowedCaptures]
    set traceChecks 0
    set traceFail {}
    foreach o $observed {
        lassign $o params argValues completion env
        if {![dict exists $blockOfKey $params]} {
            # A program function (every one has a parameter named fN_...)
            # the interpreter ran but no used instance covers: the
            # analysis treated a reached function as dead.
            if {[regexp {^f\d+_} [lindex $params 0]]} {
                lappend traceFail "invoked ([join $params ,]) has no used instance"
            }
            continue
        }
        set block [dict get $blockOfKey $params]
        set label "[join $params ,]"
        if {[dict get $entryJoin $block] eq "dormant"} {
            lappend traceFail "invoked ($label), whose every used instance is dormant"
            continue
        }
        foreach v $argValues r [dict get $entryJoin $block] p $params {
            if {$v eq "" || [core::value::kind $v] ne "int"} continue
            incr traceChecks
            if {![inRange [core::value::intOf $v] $r]} {
                lappend traceFail "entry $p = [core::value::intOf $v] not in [showRange $r]"
            }
        }
        if {[lindex $completion 0] eq "value" && [core::value::kind [lindex $completion 1]] eq "int"} {
            set v [core::value::intOf [lindex $completion 1]]
            incr traceChecks 2
            if {![inRange $v [dict get $resultJoin $block]]} {
                lappend traceFail "result of ($label) = $v not in instance result [showRange [dict get $resultJoin $block]]"
            }
            if {![inRange $v [dict get $summaryJoin $block]]} {
                lappend traceFail "result of ($label) = $v not in call-site summary [showRange [dict get $summaryJoin $block]]"
            }
        }
        if {[dict exists $captures $block]} {
            dict for {b r} [dict get $captures $block] {
                set name [dict get [hir::binding $prepared $b] name]
                if {[catch {core::env::lookup $env $name} v]} continue
                if {[catch {core::value::kind $v} kind] || $kind ne "int"} continue
                incr traceChecks
                if {![inRange [core::value::intOf $v] $r]} {
                    lappend traceFail "capture $name in ($label) = [core::value::intOf $v] not in [showRange $r]"
                }
            }
        }
    }
    dict set rec traceChecks $traceChecks
    foreach f [lsort -unique $traceFail] {
        dict lappend rec failures [list range-trace $f]
    }
    return $rec
}

# ---------------------------------------------------------------------------
# Worker: checks programs FIRST .. FIRST+N-1 of one seed, one RECORD each.

if {$worker} {
    set seed [lindex $seeds 0]
    for {set k $first} {$k < $first + $n} {incr k} {
        if {[catch {checkProgram $seed $k} rec options]} {
            if {$::dump} { puts [dict get $options -errorinfo] }
            set rec [dict create k $k status harness-error failures [list [list harness-error \
                "[dict get $options -errorcode]: $rec"]] text $::lastText]
        }
        if {[dict get $rec failures] eq "" && [dict get $rec status] eq "ok"} {
            dict unset rec text
        }
        puts [list RECORD $k $rec]
        flush stdout
    }
    exit 0
}

# ---------------------------------------------------------------------------
# Driver

proc launch {seed first count} {
    set cmd "ulimit -v $::memLimitKb 2>/dev/null; exec timeout $::timeLimit tclsh9.0\
        [list $::script] -worker 1 -seed $seed -first $first -n $count\
        -roundlimit [list $::roundLimit] -mutate $::mutate -knob [list $::knob] -nativeopts $::nativeOpts"
    return [open |[list sh -c $cmd 2>@1] r]
}

# {RECORDS STATUS OUTPUT}: the records a finished worker printed.
proc collect {pipe} {
    set output [read $pipe]
    set status 0
    if {[catch {close $pipe} message options]} {
        set status [lindex [dict get $options -errorcode] end]
    }
    set records [dict create]
    set pending ""
    foreach line [split $output \n] {
        append pending $line \n
        if {![info complete $pending]} continue
        if {[lindex $pending 0] eq "RECORD"} {
            dict set records [lindex $pending 1] [lindex $pending 2]
        }
        set pending ""
    }
    return [list $records $status $output]
}

proc runSeed {seed} {
    set slices {}
    for {set k $::first} {$k < $::first + $::n} {incr k $::slice} {
        lappend slices [list $k [expr {min($::slice, $::first + $::n - $k)}]]
    }
    set records [dict create]
    set running {}
    set retry {}
    while {[llength $slices] > 0 || [llength $running] > 0} {
        while {[llength $running] < $::jobs && [llength $slices] > 0} {
            lassign [lindex $slices 0] k count
            set slices [lrange $slices 1 end]
            lappend running [list [launch $seed $k $count] $k $count]
        }
        lassign [lindex $running 0] pipe k count
        set running [lrange $running 1 end]
        lassign [collect $pipe] got status output
        set records [dict merge $records $got]
        for {set j $k} {$j < $k + $count} {incr j} {
            if {![dict exists $got $j]} {
                if {$count == 1} {
                    dict set records $j [dict create k $j status limit failures [list [list limit \
                        "worker exit status $status; output tail:\n[string range $output end-2000 end]"]] \
                        text [programText $seed $j]]
                } else {
                    lappend slices [list $j 1]
                }
            }
        }
    }
    return $records
}

set totalFailures 0
set seenSignatures [dict create]
set totals [dict create]
set started [clock seconds]
foreach seed $seeds {
    set t0 [clock seconds]
    set records [runSeed $seed]
    set s [dict create programs 0 ok 0 rejected 0 interpError 0 disagreements 0 unsupported 0 \
        analysisErrors 0 limits 0 harness 0 disagreementsIntroduced 0 topChecks 0 topViolations 0 topIntroduced 0 \
        traceChecks 0 traceViolations 0 changed 0 topChanged 0 exprChanged 0 notRefinement 0 \
        attempted 0 converged 0 unconverged 0 messageMismatch 0 openInstance 0 dormant 0 narrower 0 nirChanged 0]
    set rounds {}
    set rejectSamples {}
    foreach k [lsort -integer [dict keys $records]] {
        set rec [dict get $records $k]
        dict incr s programs
        switch [dict get $rec status] {
            ok { dict incr s ok }
            rejected {
                dict incr s rejected
                if {[llength $rejectSamples] < 3} {
                    lappend rejectSamples "program $k: [dict get $rec detail]\n[dict get $rec text]"
                }
                continue
            }
            limit { dict incr s limits }
            harness-error { dict incr s harness }
        }
        foreach key {interpError changed topChanged exprChanged messageMismatch openInstance dormant narrower nirChanged} {
            if {[dict exists $rec $key] && [dict get $rec $key]} { dict incr s $key }
        }
        foreach key {topChecks traceChecks} {
            if {[dict exists $rec $key]} { dict incr s $key [dict get $rec $key] }
        }
        if {[dict exists $rec resultNarrow]} {
            set rn [dict get $rec resultNarrow]
            if {[dict get $rn attempted]} {
                dict incr s attempted
                if {[dict get $rn converged]} {
                    dict incr s converged
                    lappend rounds [dict get $rn rounds]
                } else {
                    dict incr s unconverged
                }
            }
        }
        if {[dict exists $rec notRefinement]} {
            dict incr s notRefinement
            puts "NOTE seed $seed program $k: knob-on interval not within knob-off interval:\n  [join [dict get $rec notRefinement] "\n  "]"
        }
        set failures [dict get $rec failures]
        foreach f $failures {
            switch [lindex $f 0] {
                disagreement {
                    dict incr s disagreements
                    if {[string match "*INTRODUCED*" [lindex $f 1]]} { dict incr s disagreementsIntroduced }
                }
                native-unsupported { dict incr s unsupported }
                analysis-error { dict incr s analysisErrors }
                range-top {
                    dict incr s topViolations
                    if {[string match "*INTRODUCED*" [lindex $f 1]]} { dict incr s topIntroduced }
                }
                range-trace { dict incr s traceViolations }
            }
        }
        if {$failures ne ""} {
            incr totalFailures
            # A program whose only failure is a PRE-EXISTING disagreement
            # (identical with the pass off) already printed in full for an
            # earlier program -- same native outcome, ExprIds aside -- is
            # listed by reference only.
            set signature ""
            if {[llength $failures] == 1 && [lindex $failures 0 0] eq "disagreement"
                    && [string match "*(pre-existing:*" [lindex $failures 0 1]]
                    && [regexp -line {^native:  (.*)$} [lindex $failures 0 1] -> nativeLine]} {
                set signature [regsub -all {\me\d+\M} $nativeLine eN]
            }
            if {$signature ne "" && [dict exists $::seenSignatures $signature]} {
                puts "FAILURE seed $seed program $k: pre-existing disagreement, same native outcome as\
                    [dict get $::seenSignatures $signature]"
                continue
            }
            if {$signature ne ""} {
                dict set ::seenSignatures $signature "seed $seed program $k ($signature)"
            }
            puts "FAILURE seed $seed program $k (replay: -seed $seed -first $k -n 1 -dump 1)"
            foreach f $failures {
                puts "  [lindex $f 0]: [string map [list \n "\n    "] [lindex $f 1]]"
            }
            puts "  program:\n[join [lmap line [split [string trimright [dict get $rec text] \n] \n] {string cat "    " $line}] \n]"
        }
    }
    foreach sample $rejectSamples {
        puts "GENERATOR-REJECT seed $seed $sample"
    }
    set roundText [expr {$rounds eq "" ? "-" : "[tcl::mathfunc::min {*}$rounds]..[tcl::mathfunc::max {*}$rounds]"}]
    puts [format "seed %s: programs %d (compiled %d, rejected %d, interp-error outcome %d); disagreements %d (introduced by\
        the pass %d), native-unsupported %d, analysis errors %d, limits %d, harness errors %d; range violations: top-level %d\
        of %d checks (introduced by the pass %d), trace %d of %d checks; narrowing changed an entry/call Range in\
        %d programs (a checked top-level call Range in %d, any expression Range in %d); programs with an open\
        instance %d, with a dormant instance %d; result narrowing\
        attempted %d, converged %d (rounds %s), not converged %d; knob-on not within knob-off %d\
        (strictly narrower somewhere: %d, specialization knobs only); NIR changed by the knob %d (lowering knobs\
        only); error-message mismatches %d; %ds" \
        $seed [dict get $s programs] [dict get $s ok] [dict get $s rejected] [dict get $s interpError] \
        [dict get $s disagreements] [dict get $s disagreementsIntroduced] [dict get $s unsupported] [dict get $s analysisErrors] [dict get $s limits] \
        [dict get $s harness] [dict get $s topViolations] [dict get $s topChecks] [dict get $s topIntroduced] \
        [dict get $s traceViolations] [dict get $s traceChecks] [dict get $s changed] [dict get $s topChanged] \
        [dict get $s exprChanged] [dict get $s openInstance] [dict get $s dormant] [dict get $s attempted] [dict get $s converged] $roundText \
        [dict get $s unconverged] [dict get $s notRefinement] [dict get $s narrower] [dict get $s nirChanged] [dict get $s messageMismatch] \
        [expr {[clock seconds] - $t0}]]
    flush stdout
    dict for {key value} $s {
        dict incr totals $key $value
    }
}
if {[llength $seeds] > 1} {
    puts [format "total (seeds %s): programs %d, compiled %d, disagreements %d, range violations top %d / trace %d,\
        changed-by-the-knob %d (top-level %d), NIR changed by the knob %d, with a dormant instance %d, not-converged %d,\
        failures %d programs; %ds" \
        [join $seeds ,] [dict get $totals programs] [dict get $totals ok] [dict get $totals disagreements] \
        [dict get $totals topViolations] [dict get $totals traceViolations] [dict get $totals changed] \
        [dict get $totals topChanged] [dict get $totals nirChanged] [dict get $totals dormant] [dict get $totals unconverged] \
        $totalFailures [expr {[clock seconds] - $started}]]
}
exit [expr {$totalFailures ? 1 : 0}]
