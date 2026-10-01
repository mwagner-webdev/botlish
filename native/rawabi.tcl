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
# every caller the compiler knows. The planner invents no numeric fact. It
# reads exactly three authoritative results, and nothing else:
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
# resultReason R closed 0|1}, with KIND `value` | `rawint` and R "" for a
# raw position, else a concise tag: not-int, open-instance,
# unbounded-or-not-small, unknown-range, dynamic-entry, disabled.
proc native::rawabi::plan {hir spec ranges enabled {blockEscape 1}} {
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
                resultReason dynamic-entry closed $isClosed]
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
            resultReason $resultReason closed $isClosed]
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
            kind [dict get $p params] reason [dict get $p paramReasons] {
        append out "    $name:\n"
        append out "      type [expr {$key eq "int" ? "Int" : [hir::specialize::ShowKey $key]}]\n"
        append out "      entry [hir::range::show $range]\n"
        append out "      fitsSmall [Yes $range]\n"
        append out "      ABI [Show $kind $reason]\n"
        incr i
    }
    set range [dict get $instRanges result]
    append out "  result:\n"
    set resultType [dict get $instance result]
    append out "    type [expr {[hir::types::kindOf $resultType] eq "int" ? "Int" : [hir::types::show $resultType]}]\n"
    append out "    range [hir::range::show $range]\n"
    append out "    fitsSmall [Yes $range]\n"
    append out "    ABI [Show [dict get $p result] [dict get $p resultReason]]\n"
    return $out
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
