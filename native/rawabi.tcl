# rawabi.tcl -- the raw Int ABI planner (RAW-INT-ABI.md).
#
# A *representation plan*, one per codegen instance (semantic instance of
# hir/specialize.tcl), choosing the physical calling currency of its Int
# positions:
#
#   value    the canonical tagged Botlish Value (every position's default)
#   rawint   a raw signed machine integer (two's complement i64 on the
#            current native target; no tag bit, no bias)
#
# This is NOT a new numeric type: the semantic type stays Int, arbitrary
# precision. RawInt is only a cheaper way to carry an Int whose small-Int
# membership an existing analysis already proved, across a boundary whose
# every caller the compiler knows. The planner invents no numeric fact. Its
# *eligibility* stage reads exactly these authoritative results, and nothing
# else (the demand stage below only reads facts lowering itself uses, to see
# which consumers want a raw Int):
#
#   hir::specialize   `closed` (InstanceClosed: every invocation of the
#                     instance is a direct, exact call the analysis saw) and
#                     the instance's key types and result type
#   hir::range        the instance's final entry Range per parameter and its
#                     successful-result Range (including bounded self-
#                     recursive result summaries: the ordinary result query,
#                     no special case), judged by hir::range::fitsSmall
#
# Eligibility theorem. A parameter position (resp. the successful result) of
# instance I may be rawint when
#
#   1. its semantic type is Int (the key type `int`; the result type's kind),
#   2. I is closed (InstanceClosed), and
#   3. its final entry (resp. successful-result) Range satisfies fitsSmall,
#      i.e. lies inside the *tagged small-Int domain* [-2^62, 2^62-1] -- not
#      merely finite and not merely inside a signed 64-bit register.
#
# (1) and (3) make the integer representable and its raw/tagged conversion
# non-allocating at every eligible boundary; (2) makes the Range a statement
# about every call, so no dynamic caller can hand the raw entry a Value it
# does not expect. Parameters and the result are planned independently; a
# function may be raw in any subset of its positions.
#
# Eligibility is a *safety* statement. Whether anything wants the raw form is
# a separate, *usefulness* question (RAW-INT-ABI.md, "Raw-demand
# suppression"): an eligible position is selected only if raw representation
# is demanded somewhere in its use / transport closure, i.e. only if the
# position can reach a genuine raw consumer (a raw arithmetic or comparison
# operand, a raw self-tail loop slot) through aliases, branches, returns and
# exact call edges. A position whose whole closure ends in tagged consumers
# stays tagged (reason `suppressed-no-raw-demand`). A position whose closure
# has a raw consumer *and* a tagged one (a mixed use) is boxed by default
# (reason `suppressed-mixed-tagged-use`): raw only when every consumer in its
# closure is raw. The pass is a boolean
# backward reachability over a small demand graph (see Demand below); it never
# adds an eligibility fact and never turns a tagged position raw.
#
# Layering. Semantic analysis proves Range/fitsSmall; this planner chooses a
# representation; native/lower.tcl emits the chosen physical convention and
# never re-decides it: the plan below is stored once (native::lower's
# `abiPlan`) and read by the callee's own lowering and by every caller, so
# caller/callee agreement holds by construction (and native/src/nir.rs
# validates it again on the NIR text). Raw selection removes boxing, never a
# check the proof relied on, so it cannot feed back into the Range proof.
#
# Only the canonical function of an instance has a physical raw signature.
# Companion, region, internal-capture and fields variants (see lower.tcl's
# modes) keep the tagged ABI; the generic Block-value entry always does.

namespace eval native::rawabi {
}

# Plan every used instance of SPEC (hir::specialize::analyze result) given
# RANGES (hir::range::analyze result). ENABLED 0 plans everything `value`
# (reason `disabled`): the parent's tagged ABI.
#
# BLOCKESCAPE says whether lowering de-closure-converts (virtualizes) the
# closures hir::blockescape proves are only ever called directly. The
# closedness proof of a value-capturing closure's generic instance *is* that
# blockescape result (InstanceClosed's closure branch), so it only describes
# the lowered code when lowering acts on it: with block escape disabled
# every such closure is materialized as a Block value, whatever the proof
# says, and its generic instance keeps the tagged ABI (`open-instance`). Returns a dict
# InstanceId -> {params {KIND...} result KIND paramReasons {R...}
# resultReason R closed 0|1 paramEligible {0|1...} resultEligible 0|1
# paramTrace {T...} resultTrace T}, with KIND `value` | `rawint` and R "" for
# a raw position, else a concise tag: not-int, open-instance,
# unbounded-or-not-small, unknown-range, dynamic-entry, disabled,
# suppressed-no-raw-demand, suppressed-mixed-tagged-use. paramEligible/resultEligible record the *safety*
# eligibility (before the demand filter); T is the audit trace of an eligible
# position (see Demand).
#
# DEMAND 0 skips the usefulness filter (audit-only: `-raw-demand-opt 0`),
# leaving every eligible position raw -- the preliminary eligible => raw
# policy, kept for comparisons. MIXED says what a position with both a raw
# consumer and a tagged one becomes: `boxed` (the default, and the policy) keeps
# it tagged (reason suppressed-mixed-tagged-use); `raw` (audit-only,
# `-raw-mixed-policy raw`) keeps the earlier "any raw demand retains RawInt".
proc native::rawabi::plan {hir spec ranges enabled {blockEscape 1} {demand 1} {mixed boxed}} {
    set closed [dict get $spec closed]
    set statics [dict get [dict get $spec context] statics]
    set plan [dict create]
    foreach id [dict get $spec used] {
        set instance [dict get $spec instances $id]
        set isClosed [dict exists $closed $id]
        set block [dict get $instance block]
        if {$isClosed && !$blockEscape && [dict get $instance generic] && $block ne "program"
                && $block ni $statics} {
            set isClosed 0
        }
        set kinds {}
        set reasons {}
        if {$block eq "program"} {
            # The program is entered by the runtime, never by an exact call.
            dict set plan $id [dict create params {} result value paramReasons {} \
                resultReason dynamic-entry closed $isClosed paramEligible {} resultEligible 0 \
                paramTrace {} resultTrace {}]
            continue
        }
        set instRanges [dict get $ranges instances $id]
        foreach key [dict get $instance args] range [dict get $instRanges params] {
            lassign [Position $enabled $isClosed [expr {$key eq "int"}] $range] kind reason
            lappend kinds $kind
            lappend reasons $reason
        }
        set resultIsInt [expr {[hir::types::kindOf [dict get $instance result]] eq "int"}]
        lassign [Position $enabled $isClosed $resultIsInt [dict get $instRanges result]] resultKind resultReason
        dict set plan $id [dict create params $kinds result $resultKind paramReasons $reasons \
            resultReason $resultReason closed $isClosed \
            paramEligible [lmap k $kinds {expr {$k eq "rawint"}}] \
            resultEligible [expr {$resultKind eq "rawint"}] paramTrace {} resultTrace {}]
    }
    if {$enabled && $demand} {
        return [Demand $hir $spec $ranges $plan $mixed]
    }
    return $plan
}

# {KIND REASON} of one position. The three eligibility conditions, in the
# order a rejection is most informative.
proc native::rawabi::Position {enabled isClosed isInt range} {
    if {!$enabled} {
        return {value disabled}
    }
    if {!$isInt} {
        return {value not-int}
    }
    if {!$isClosed} {
        return {value open-instance}
    }
    if {$range eq "never"} {
        return {value unknown-range}
    }
    if {[hir::range::isUnknown $range]} {
        return {value unknown-range}
    }
    if {![hir::range::fitsSmall $range]} {
        return {value unbounded-or-not-small}
    }
    return {rawint {}}
}

# 1|0 per parameter position of the first N of instance ID: whether it is a
# raw Int position. Positions beyond the plan's list (a hidden trailing
# parameter) are tagged.
proc native::rawabi::params {plan id n} {
    set out {}
    set kinds [expr {[dict exists $plan $id] ? [dict get $plan $id params] : {}}]
    for {set i 0} {$i < $n} {incr i} {
        lappend out [expr {[lindex $kinds $i] eq "rawint"}]
    }
    return $out
}

# 1 if instance ID's successful result is a raw Int.
proc native::rawabi::result {plan id} {
    return [expr {[dict exists $plan $id] && [dict get $plan $id result] eq "rawint"}]
}

# 1 if instance ID's canonical function has any raw position.
proc native::rawabi::uses {plan id} {
    if {![dict exists $plan $id]} {
        return 0
    }
    return [expr {[dict get $plan $id result] eq "rawint" || "rawint" in [dict get $plan $id params]}]
}

# One instance's audit paragraph (see RAW-INT-ABI.md): its closedness, each
# parameter's type, entry Range and ABI, and the result's.
proc native::rawabi::explain {hir spec ranges plan id} {
    set instance [dict get $spec instances $id]
    set block [dict get $instance block]
    set label [hir::specialize::label $spec $id]
    set p [dict get $plan $id]
    set out "instance $label\n  closed: [expr {[dict get $p closed] ? "yes" : "no"}]\n"
    if {$block eq "program"} {
        append out "  entry: runtime (tagged)\n"
        return $out
    }
    set names [lmap b [hir::get $hir $block params] {dict get [hir::binding $hir $b] name}]
    set instRanges [dict get $ranges instances $id]
    append out "  params:\n"
    set i 0
    foreach name $names key [dict get $instance args] range [dict get $instRanges params] \
            kind [dict get $p params] reason [dict get $p paramReasons] \
            eligible [dict get $p paramEligible] trace [dict get $p paramTrace] {
        append out "    $name:\n"
        append out "      type [expr {$key eq "int" ? "Int" : [hir::specialize::ShowKey $key]}]\n"
        append out "      entry [hir::range::show $range]\n"
        append out "      fitsSmall [Yes $range]\n"
        append out "      RawInt eligible [expr {$eligible ? "yes" : "no"}]\n"
        append out [ShowTrace $eligible $trace]
        append out "      ABI [Show $kind $reason]\n"
        incr i
    }
    set range [dict get $instRanges result]
    append out "  result:\n"
    set resultType [dict get $instance result]
    append out "    type [expr {[hir::types::kindOf $resultType] eq "int" ? "Int" : [hir::types::show $resultType]}]\n"
    append out "    range [hir::range::show $range]\n"
    append out "    fitsSmall [Yes $range]\n"
    append out "    RawInt eligible [expr {[dict get $p resultEligible] ? "yes" : "no"}]\n"
    append out [ShowTrace [dict get $p resultEligible] [dict get $p resultTrace] "    "]
    append out "    ABI [Show [dict get $p result] [dict get $p resultReason]]\n"
    return $out
}

# The demand-trace lines of one eligible position (nothing for an ineligible
# one, and nothing when the demand pass did not run).
proc native::rawabi::ShowTrace {eligible trace {indent "      "}} {
    if {!$eligible || $trace eq ""} {
        return ""
    }
    lassign $trace verdict items
    if {$verdict eq "raw"} {
        return "${indent}raw demand: [join $items { -> }]\n"
    }
    if {$verdict eq "mixed"} {
        lassign [lrange $trace 1 2] steps tagged
        return "${indent}raw demand: [join $steps { -> }]\n${indent}but tagged consumers too: [join $tagged {, }] (mixed use: boxed)\n"
    }
    set what [expr {$items eq "" ? "none" : [join $items {, }]}]
    return "${indent}raw demand: none (tagged consumers: $what)\n"
}

proc native::rawabi::Yes {range} {
    if {$range eq "never"} {
        return no
    }
    return [expr {[hir::range::fitsSmall $range] ? "yes" : "no"}]
}

proc native::rawabi::Show {kind reason} {
    if {$kind eq "rawint"} {
        return RawInt
    }
    return "tagged ($reason)"
}

# The whole program's audit text: every used instance's paragraph.
proc native::rawabi::explainAll {hir spec ranges plan} {
    set out ""
    foreach id [dict get $spec used] {
        append out [explain $hir $spec $ranges $plan $id] "\n"
    }
    return $out
}

# ---------------------------------------------------------------------------
# Raw-demand analysis (RAW-INT-ABI.md, "Raw-demand suppression")
#
# Eligibility (Position above) says a position *may* be raw. This pass says
# whether anything *wants* it raw, as one boolean per eligible position and
# nothing else: no scores, distances, counts or frequencies.
#
# The demand graph. Nodes are
#
#   P:ID:K   parameter K of instance ID          (only eligible ones matter)
#   R:ID     the successful result of instance ID (only eligible ones matter)
#   B:ID:B   a local binding / parameter binding of instance ID's region
#   RAW      the single seed: "some consumer genuinely wants a raw Int"
#
# and an edge `A -> B` means "if B is raw-demanded then so is A": A's value
# flows into B (through an alias, an if branch, a return, an exact call
# argument or an exact call's result). Absence of an edge is a *tagged
# consumer* (a Value operation, collection or struct storage, a generic call,
# a captured/static slot): it contributes no demand. An edge to RAW is a
# genuine raw consumer:
#
#   * an operand of a raw-representable native operation, with exactly the
#     range conditions lowering uses for it (RawOpEligible: `+ - * < <= > >=`,
#     `==` on two Ints, the proven-safe shifts);
#   * a slot of a self-tail loop whose raw representation lowering already
#     forces for the whole function (native::lower::RawParams: the instance
#     self-tail-calls and the position's final entry Range fitsSmall);
#   * a bound of a counted loop (or of a lockstep loop's numeric domain)
#     that lowering runs on a raw induction register
#     (native::lower::RawCountDomain: both bounds' Ranges fitsSmall; loss
#     point 4 of GENERIC-PREDICATE-PROOF-LOSS.md). A bound of any other
#     counted loop is a tagged consumer.
#
# A position is demanded iff it reaches RAW. That is plain graph reachability
# (reverse breadth-first search from RAW), monotone and deterministic, and it
# cannot bootstrap: a cycle of pure raw transport edges (f -> g -> f) with no
# edge into RAW is never reached, so it collapses to tagged. Transport
# (exact call edges) only *propagates* existing demand; it is never a seed.
#
# Conservative by construction: any construct this pass does not recognize
# contributes an edge to RAW (keeps the existing decision), only constructs it
# positively knows to be tagged are left edgeless, and every operand
# condition it evaluates is the guard-free (hence weaker or equal) form of
# lowering's, so it can only over-approximate raw demand, never under-estimate
# it. Unreachable code is skipped using the same facts lowering uses: the
# per-instance `reachable` bit of the view and hir::range::ConditionOutcome.
#
# Parameters and results are planned in their own direction. A parameter's
# demand is its uses in the callee body and onward exact transports; a
# closed instance's result demand is the demand of every direct call site's
# value (InstanceClosed makes that call set complete: every one is in some
# instance's `calls` map).

namespace eval native::rawabi {
    variable Hir ""
    variable Spec ""
    variable Ranges ""
    variable Plan ""
    # Forward edges: Fwd(FROM) -> list of {TO WHY}; Tagged(FROM) -> labels of
    # tagged consumers (audit only; they create no demand).
    variable Fwd
    variable Tagged
    # Unclean(FROM) = 1: FROM has a tagged consumer of its own *outside the
    # program function* (a mixed use if it is also raw-demanded). The
    # program function runs once, so a tagged value there is the single
    # frontier conversion every raw region has, not a competing use.
    variable Unclean
    # The walk in progress: h (the instance's view), id, loops (loop ExprId
    # -> sink of its break values), result (the sink of `return`).
    variable W
    variable Labels
    # The tagged native ops -> raw op, of the raw-representable family (the
    # same table native::lower::NativeCall's rawEligible branch uses).
    variable rawOps [dict create + riadd - risub * rimul < rilt <= rile > rigt >= rige \
        == rieq shift_left rishl shift_right rishr]
}

# The display label of instance ID, computed once per Demand pass.
proc native::rawabi::Label {id} {
    variable Spec
    variable Labels
    if {![info exists Labels($id)]} {
        set Labels($id) [hir::specialize::label $Spec $id]
    }
    return $Labels($id)
}

# 1 if range R is a proper range inside the small-Int domain.
proc native::rawabi::Fits {r} {
    return [expr {$r ne "never" && [hir::range::fitsSmall $r]}]
}

# Edge/tagged-use recording. SINK "" is a tagged consumer.
proc native::rawabi::Flow {from sink why} {
    variable Fwd
    variable Tagged
    variable Unclean
    variable W
    if {$sink eq ""} {
        if {$why eq "discarded"} {
            return
        }
        if {!$W(program)} {
            set Unclean($from) 1
        }
        if {[info exists Tagged($from)] && [llength $Tagged($from)] >= 6} {
            return
        }
        lappend Tagged($from) $why
        return
    }
    lappend Fwd($from) [list $sink $why]
}

# Plan: the Demand pass. Returns PLAN with every eligible position that
# cannot reach a raw consumer set back to `value` (reason
# suppressed-no-raw-demand), plus the audit traces.
proc native::rawabi::Demand {hir spec ranges plan mixed} {
    variable Hir
    variable Spec
    variable Ranges
    variable Plan
    variable Fwd
    variable Tagged
    variable Unclean
    set any 0
    dict for {id p} $plan {
        if {1 in [dict get $p paramEligible] || [dict get $p resultEligible]} {
            set any 1
            break
        }
    }
    if {!$any} {
        return $plan
    }
    set Hir $hir
    set Spec $spec
    set Ranges $ranges
    set Plan $plan
    variable Labels
    array unset Fwd
    array unset Tagged
    array unset Unclean
    array unset Labels
    array set Fwd {}
    array set Unclean {}
    array set Tagged {}
    array set Labels {}
    foreach id [dict get $spec used] {
        if {[Relevant $id]} {
            WalkInstance $id
        }
    }
    # Reverse breadth-first search from the seed.
    set rev [dict create]
    foreach from [lsort [array names Fwd]] {
        foreach edge $Fwd($from) {
            dict lappend rev [lindex $edge 0] [list $from [lindex $edge 1]]
        }
    }
    set demanded [dict create RAW 1]
    set next [dict create]
    set queue [list RAW]
    for {set i 0} {$i < [llength $queue]} {incr i} {
        set node [lindex $queue $i]
        if {![dict exists $rev $node]} continue
        foreach pair [dict get $rev $node] {
            lassign $pair from why
            if {[dict exists $demanded $from]} continue
            dict set demanded $from 1
            dict set next $from [list $node $why]
            lappend queue $from
        }
    }
    # Mixed uses. A node is *unclean* when a tagged consumer sits in its
    # closure: it has a tagged use of its own (Unclean, recorded outside the
    # program function), or it flows into an unclean node, or into an eligible
    # position that ends up tagged (not demanded). Only demanded *and* clean
    # positions are selected under the boxed-mixed policy.
    set unclean [dict create]
    set queue {}
    foreach node [lsort [array names Unclean]] {
        dict set unclean $node 1
        lappend queue $node
    }
    foreach id [dict get $spec used] {
        set p [dict get $plan $id]
        set k 0
        foreach eligible [dict get $p paramEligible] {
            if {$eligible && ![dict exists $demanded P:$id:$k] && ![dict exists $unclean P:$id:$k]} {
                dict set unclean P:$id:$k 1
                lappend queue P:$id:$k
            }
            incr k
        }
        if {[dict get $p resultEligible] && ![dict exists $demanded R:$id] && ![dict exists $unclean R:$id]} {
            dict set unclean R:$id 1
            lappend queue R:$id
        }
    }
    for {set i 0} {$i < [llength $queue]} {incr i} {
        set node [lindex $queue $i]
        if {![dict exists $rev $node]} continue
        foreach pair [dict get $rev $node] {
            set from [lindex $pair 0]
            if {[dict exists $unclean $from]} continue
            dict set unclean $from 1
            lappend queue $from
        }
    }
    set boxedMixed [expr {$mixed eq "boxed"}]
    set out $plan
    foreach id [dict get $spec used] {
        set p [dict get $plan $id]
        set kinds [dict get $p params]
        set reasons [dict get $p paramReasons]
        set traces [lrepeat [llength $kinds] ""]
        set k 0
        foreach eligible [dict get $p paramEligible] {
            if {$eligible} {
                set node P:$id:$k
                lset traces $k [Trace $node $demanded $next $unclean]
                if {![dict exists $demanded $node]} {
                    lset kinds $k value
                    lset reasons $k suppressed-no-raw-demand
                } elseif {$boxedMixed && [dict exists $unclean $node]} {
                    lset kinds $k value
                    lset reasons $k suppressed-mixed-tagged-use
                }
            }
            incr k
        }
        set result [dict get $p result]
        set resultReason [dict get $p resultReason]
        set resultTrace ""
        if {[dict get $p resultEligible]} {
            set resultTrace [Trace R:$id $demanded $next $unclean]
            if {![dict exists $demanded R:$id]} {
                set result value
                set resultReason suppressed-no-raw-demand
            } elseif {$boxedMixed && [dict exists $unclean R:$id]} {
                set result value
                set resultReason suppressed-mixed-tagged-use
            }
        }
        dict set out $id params $kinds
        dict set out $id paramReasons $reasons
        dict set out $id result $result
        dict set out $id resultReason $resultReason
        dict set out $id paramTrace $traces
        dict set out $id resultTrace $resultTrace
    }
    return $out
}

# The audit trace of eligible position NODE: for a demanded one the shortest
# chain of transport steps down to the raw consumer ("raw: ..."), for a
# suppressed one the tagged consumers its whole closure ends in ("tagged:
# ...", "no raw consumer").
proc native::rawabi::Trace {node demanded next unclean} {
    variable Fwd
    variable Tagged
    if {[dict exists $demanded $node]} {
        set steps {}
        set cur $node
        while {$cur ne "RAW"} {
            lassign [dict get $next $cur] to why
            lappend steps $why
            set cur $to
        }
        if {![dict exists $unclean $node]} {
            return [list raw $steps]
        }
        return [list mixed $steps [TaggedClosure $node]]
    }
    return [list tagged [TaggedClosure $node]]
}

# The tagged consumers in the forward closure of NODE (at most 8 labels).
proc native::rawabi::TaggedClosure {node} {
    variable Fwd
    variable Tagged
    # Forward closure of the position: every tagged consumer reached.
    set seen [dict create $node 1]
    set queue [list $node]
    set labels {}
    for {set i 0} {$i < [llength $queue]} {incr i} {
        set cur [lindex $queue $i]
        if {[info exists Tagged($cur)]} {
            foreach l $Tagged($cur) {
                if {$l ni $labels && [llength $labels] < 8} {
                    lappend labels $l
                }
            }
        }
        if {![info exists Fwd($cur)]} continue
        foreach edge $Fwd($cur) {
            set to [lindex $edge 0]
            if {![dict exists $seen $to]} {
                dict set seen $to 1
                lappend queue $to
            }
        }
    }
    return $labels
}

# 1 if instance ID's walk can contribute an edge into an eligible position:
# it owns one, or calls an instance that does.
proc native::rawabi::Relevant {id} {
    variable Plan
    variable Spec
    set p [dict get $Plan $id]
    if {1 in [dict get $p paramEligible] || [dict get $p resultEligible]} {
        return 1
    }
    foreach {e target} [dict get $Spec instances $id calls] {
        if {![dict exists $Plan $target]} continue
        set q [dict get $Plan $target]
        if {1 in [dict get $q paramEligible] || [dict get $q resultEligible]} {
            return 1
        }
    }
    return 0
}

proc native::rawabi::WalkInstance {id} {
    variable Hir
    variable Spec
    variable Ranges
    variable Plan
    variable W
    set instance [dict get $Spec instances $id]
    set block [dict get $instance block]
    set h [hir::specialize::view $Hir $Spec $id]
    array unset W
    set W(h) $h
    set W(id) $id
    set W(loops) [dict create]
    set W(calls) [dict get $instance calls]
    set W(selfTail) [dict get $Spec context selfTails]
    set p [dict get $Plan $id]
    set W(program) [expr {$block eq "program"}]
    if {$block eq "program"} {
        set W(result) ""
        Seq [hir::roots $h] "" program
        return
    }
    set W(result) [expr {[dict get $p resultEligible] ? "R:$id" : ""}]
    set params [hir::get $h $block params]
    # A self-tail-recursive instance keeps a raw register for every
    # parameter whose entry Range fits (native::lower::RawParams), whatever
    # the ABI: those slots are genuine raw state.
    set selfTail 0
    foreach {e target} $W(calls) {
        if {$target eq $id && [dict exists $W(selfTail) $e]} {
            set selfTail 1
            break
        }
    }
    set paramRanges [dict get $Ranges instances $id params]
    set W(rawSlots) [lmap r $paramRanges {expr {$selfTail && [Fits $r]}}]
    set k 0
    foreach b $params eligible [dict get $p paramEligible] {
        if {$eligible} {
            Flow P:$id:$k B:$id:$b "parameter [dict get [hir::binding $h $b] name]"
            if {[lindex $W(rawSlots) $k]} {
                Flow P:$id:$k RAW "self-tail loop slot [dict get [hir::binding $h $b] name]"
            }
        }
        incr k
    }
    Seq [hir::get $h $block body] $W(result) return
}

# The statements of a body: every value but the last is discarded.
proc native::rawabi::Seq {exprs sink why} {
    set n [llength $exprs]
    set i 0
    foreach e $exprs {
        incr i
        if {$i < $n} {
            Walk $e "" discarded
        } else {
            Walk $e $sink $why
        }
    }
}

# Walk expression E, whose value flows to SINK ("" tagged, RAW, or a node),
# WHY labelling that edge. Records the edges of everything beneath it.
proc native::rawabi::Walk {e sink why} {
    variable W
    set h $W(h)
    if {![hir::get $h $e reachable]} {
        return
    }
    set node [hir::node $h $e]
    switch -- [dict get $node kind] {
        const - continue - fail { }
        ref {
            set b [dict get $node binding]
            if {$b ne "" && [dict get [hir::binding $h $b] kind] in {local param}} {
                Flow B:$W(id):$b $sink $why
            }
        }
        bind {
            set b [dict get $node binding]
            set value [dict get $node value]
            if {[hir::kind $h $value] eq "block"} {
                return
            }
            if {$b eq "" || [hir::isModuleBinding $h $b]} {
                # Written once to a tagged static slot.
                Walk $value "" "module static [dict get $node name]"
            } else {
                Flow B:$W(id):$b $sink $why
                Walk $value B:$W(id):$b "bind [dict get $node name]"
            }
        }
        block { }
        call { Call $e $node $sink $why }
        if { If $e $node $sink $why }
        loop {
            dict set W(loops) $e $sink
            Seq [dict get $node body] "" discarded
            # A loop body's value is discarded (every iteration).
        }
        listloop {
            Walk [dict get $node iterable] "" "list loop source"
            dict set W(loops) $e ""
            Seq [dict get $node body] "" "list loop result element"
        }
        countloop {
            CountBounds $e [dict get $node start] [dict get $node end]
            dict set W(loops) $e ""
            # A collecting loop (COLLECTING-LOOPS.md): the body's value is a
            # result-List element, exactly like listloop's.
            Seq [dict get $node body] "" "list loop result element"
        }
        lockloop {
            foreach domain [dict get $node domains] {
                if {[dict get $domain kind] eq "list"} {
                    Walk [dict get $domain iterable] "" "list loop source"
                } else {
                    CountBounds $e [dict get $domain start] [dict get $domain end]
                }
            }
            dict set W(loops) $e ""
            Seq [dict get $node body] "" "list loop result element"
        }
        struct {
            foreach f [dict get $node fields] {
                Walk $f "" "struct field"
            }
        }
        project { Walk [dict get $node receiver] "" "field projection" }
        ok - error { Walk [dict get $node value] "" "result payload" }
        return { Walk [dict get $node value] $W(result) "return" }
        break {
            set value [dict get $node value]
            if {$value ne ""} {
                set loop [dict get $node target]
                set target [expr {[dict exists $W(loops) $loop] ? [dict get $W(loops) $loop] : ""}]
                Walk $value $target "break value"
            }
        }
        handle {
            Walk [dict get $node call] $sink $why
            foreach body [dict get $node handlerBodies] {
                Seq $body $sink $why
            }
        }
        default {
            # Unknown construct: stay conservative (keep the existing choice).
            foreach c [hir::children $h $e] {
                Walk $c RAW "unrecognized [dict get $node kind]"
            }
        }
    }
}

# The two bounds of a numeric loop domain of loop E (a countloop, or one
# domain of a lockloop). Lowering runs the domain on a raw induction
# register exactly when native::lower::RawCountDomain holds (loss point 4 of
# GENERIC-PREDICATE-PROOF-LOSS.md): both bounds are then unboxed once and
# compared raw, so each is a raw consumer. Otherwise the loop compares and
# advances tagged, and a bound is a tagged consumer.
proc native::rawabi::CountBounds {e startExpr endExpr} {
    variable W
    variable Ranges
    if {[native::lower::RawCountDomain $Ranges $W(id) $startExpr $endExpr]} {
        Walk $startExpr RAW "raw count loop bound @$e"
        Walk $endExpr RAW "raw count loop bound @$e"
        return
    }
    Walk $startExpr "" "count loop bound"
    Walk $endExpr "" "count loop bound"
}

proc native::rawabi::If {e node sink why} {
    variable W
    variable Ranges
    set h $W(h)
    set condition [dict get $node condition]
    Walk $condition "" condition
    set outcome [hir::range::ConditionOutcome $h $Ranges $W(id) $condition]
    if {$outcome ne ""} {
        # Range-decided: lowering emits only the chosen branch.
        Seq [dict get $node [expr {$outcome ? "thenBody" : "elseBody"}]] $sink $why
        return
    }
    foreach role {thenBody elseBody} {
        set body [dict get $node $role]
        if {$body ne "" && ![hir::get $h [lindex $body 0] reachable]} continue
        Seq $body $sink $why
    }
}

proc native::rawabi::Call {e node sink why} {
    variable W
    variable Plan
    variable rawOps
    set h $W(h)
    set args [dict get $node args]
    set callee [dict get $node callee]
    if {[hir::kind $h $callee] ne "ref"} {
        Walk $callee "" callee
    }
    lassign [dict get $node target] kind target
    if {$kind eq "native"} {
        set name [dict get [hir::symbol $h $target] name]
        set rawOp ""
        if {[dict exists $rawOps $name] && [llength $args] == 2 && [RawOpEligible $e $name $args]} {
            set rawOp [dict get $rawOps $name]
        }
        foreach a $args {
            if {$rawOp ne ""} {
                Walk $a RAW "raw $rawOp @$e"
            } else {
                Walk $a "" "tagged native $name"
            }
        }
        return
    }
    set instance ""
    if {$kind eq "block" && [dict exists $W(calls) $e]} {
        set instance [dict get $W(calls) $e]
    }
    if {$instance eq "" || ![dict exists $Plan $instance]} {
        foreach a $args {
            Walk $a "" "dynamic call argument"
        }
        return
    }
    set q [dict get $Plan $instance]
    set label [Label $instance]
    set exact [expr {[llength $args] == [llength [dict get $q paramEligible]]}]
    set self [expr {$instance eq $W(id) && [dict exists $W(selfTail) $e]}]
    set i 0
    foreach a $args {
        if {$self} {
            # A self tail call: the loop slots raw by RawParams.
            if {[lindex $W(rawSlots) $i]} {
                Walk $a RAW "self-tail loop argument $i"
            } elseif {$exact && [lindex [dict get $q paramEligible] $i]} {
                Walk $a P:$instance:$i "self-tail argument $i"
            } else {
                Walk $a "" "self-tail argument $i"
            }
        } elseif {$exact && [lindex [dict get $q paramEligible] $i]} {
            Walk $a P:$instance:$i "argument $i of $label"
        } else {
            Walk $a "" "tagged argument $i of $label"
        }
        incr i
    }
    if {!$self && [dict get $q resultEligible]} {
        Flow R:$instance $sink "result of $label ($why)"
        if {$sink eq "" && $why eq "discarded" && !$W(program)} {
            # A discarded raw result is still boxed at the call.
            variable Unclean
            set Unclean(R:$instance) 1
        }
    }
}

# 1 if native NAME (a raw-representable operation) applied to ARGEXPRS at call E
# can take both operands raw: lowering's RawEligibleCall / RawEligibleShift
# without the guard facts (which only ever reject), so this is never
# stricter than lowering.
proc native::rawabi::RawOpEligible {e name argExprs} {
    variable W
    variable Ranges
    set h $W(h)
    lassign $argExprs ea eb
    if {$name eq "=="} {
        if {[hir::types::kindOf [hir::typeOf $h $ea]] ne "int"
                || [hir::types::kindOf [hir::typeOf $h $eb]] ne "int"} {
            return 0
        }
    }
    set ra [hir::range::of $Ranges $W(id) $ea]
    set rb [hir::range::of $Ranges $W(id) $eb]
    if {![Fits $ra] || ![Fits $rb]} {
        return 0
    }
    switch -- $name {
        + { return [Fits [hir::range::add $ra $rb]] }
        - { return [Fits [hir::range::sub $ra $rb]] }
        * { return [Fits [hir::range::mul $ra $rb]] }
        shift_left - shift_right {
            if {[dict get $ra min] < 0} {
                return 0
            }
            set kmn [dict get $rb min]
            if {$kmn ne [dict get $rb max] || $kmn < 0 || $kmn >= $::native::lower::rawShiftMax} {
                return 0
            }
            return [Fits [hir::range::of $Ranges $W(id) $e]]
        }
    }
    return 1
}
