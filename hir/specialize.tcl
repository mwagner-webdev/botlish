# specialize.tcl -- call-site specialization: function instances whose
# argument, result and aggregate kinds are statically known.
#
#   set spec [hir::specialize::analyze $hir]
#   puts [hir::specialize::explain $hir $spec]
#
# A function's semantic HIR type never changes because of what its callers
# happen to pass: `fn f(x)` stays f(any). An *instance* is an implementation
# artifact: the code of one region (a block's body, or the program) analyzed
# under argument facts its semantic inference could not assume. Instances of
# one function coexist, e.g.
#
#   f<generic>    x : any    (the semantic function; always correct)
#   f<int>        x : int    (valid only for calls passing an Int)
#   f<str>        x : str
#
# Nothing here changes the HIR, runs code, or is visible to programs: a
# Block value is always the generic function; instances are chosen only by
# calls whose target HIR already knows (a direct call). Backends use them as
# an optimization (native/lower.tcl); running generic code everywhere is
# always correct.
#
# Instances
# ---------
# A specialization key is {BLOCK ARG-TYPES}: the block ExprId and one key
# type per parameter. The program's key is "program". Key types are static
# types (hir/types.tcl) reduced to what an operation's choice depends on:
#
#   int str bool unit result any    kinds, evidence (named types) dropped
#   block native                    a callable of that kind; which one is
#                                   not part of the key
#   list, {list ELEM}, {list ELEM SHAPE}
#                                   aggregate facts with key-typed elements
#
# The generic instance of a block has key type any for every parameter. Equal
# keys are the same instance (the cache: keys -> InstanceId); instance ids
# are allocated in discovery order, which is deterministic.
#
# Region inference (hir::types::inferRegion) types an instance: the same
# inference as the semantic one, with parameters seeded by the key, captured
# bindings seeded by what the block's creations captured, aggregate facts,
# and calls of known blocks asking this analysis for the callee instance's
# result. The results are overlays: the type, known outcome and
# reachability of each expression of the region under the instance's facts.
# hir::aot then analyzes an instance on a *view*: the HIR with the overlay
# applied (view), so blockers, facts and guards come from the one AOT
# analysis, not from a second set of rules.
#
# Which instance a call uses
# --------------------------
# A call of a known block B with argument types T1..Tn (in instance I):
#
#   * Static blocks specialize normally. Exact calls of value-capturing
#     closures may specialize when every capture has a proven Int kind.
#     Captured types are joined across creations, so a shared instance is
#     valid for every creation. Other value-capturing closures stay generic
#     to bound code growth. A materialized Block retains a generic entry.
#   * a self tail call (hir::aot::selfTailCalls) whose key types are all
#     subtypes of I's own: I itself, so the call stays a loop. Otherwise
#     the key is the pointwise lub of I's key and the call's, which is
#     strictly more general: a chain of such calls climbs the finite key
#     lattice and ends in an instance that loops (at worst B<generic>).
#     f<int, str> tail-calling f(s, i) goes to f<any, any> = f<generic>.
#   * otherwise B<key(T1)..key(Tn)>, unless every key type is any (the
#     generic instance), or B already has `limit` specialized instances, or
#     the analysis has `instanceLimit` instances: then B<generic>.
#
# Explosion control, then: at most `limit` (default 8) specialized instances
# of a block in use plus its generic one, at most `instanceLimit` instances
# in all, key types bounded by the aggregate bounds of hir/types.tcl, and
# self tail calls only widen. Instances an earlier pass of the fixpoint used
# and no pass uses any more are released and do not count (see Fixpoint);
# which call meets the limit first depends on discovery order, which is
# deterministic.
#
# Result fixpoint
# ---------------
# Each instance has a result type, initially never ("no normal completion
# known yet"; an instance being analyzed that calls itself sees never). A
# worklist analyzes instances; a call records the caller as a dependent of
# its callee. After an analysis the instance's result becomes
# lub(old result, inferred result); if it changed, its dependents are
# analyzed again. New captured-binding facts for a block (a creation seen
# with new types) re-analyze its instances. Everything only grows in finite
# lattices, so the worklist empties; as a guard against non-monotone corner
# cases an instance analyzed more than passLimit times gets result any. At
# the fixpoint every instance's result is sound under the assumptions its
# callers used (induction over calls, as in the semantic block result
# inference), and an error path (type never) contributes nothing.
#
# Data model
# ----------
# analyze returns a dict:
#
#   specialize  1 | 0 (0: generic instances only, with semantic types)
#   instances   InstanceId -> instance
#   keys        key -> InstanceId
#   used        InstanceIds reachable from the program, ordered by the
#               block's position in the program, then by InstanceId
#   context     the hir::aot::context the analysis used
#
# An instance:
#
#   id        InstanceId (i0 is the program)
#   block     block ExprId, or program
#   name      the function name ("" for an anonymous block, <program>)
#   args      key types, one per parameter ("" for the program)
#   generic   1 if every key type is any (or the program)
#   result    result type
#   seeds     captured BindingId -> type the region was analyzed under
#   calls     call ExprId -> callee InstanceId, for direct calls of blocks
#   creates   block ExprIds the region creates
#   values    blocks whose Block value its reachable code materializes
#             (hir::aot::materializedBlocks): their generic instances run
#             those values
#   edges     InstanceIds its reachable code uses: callees and the generic
#             instances of values
#   overlay   ExprId -> {TYPE KNOWN REACHABLE} for the region's expressions
#             whose facts differ from the semantic HIR's ("" for semantic
#             types: specialize 0)
#   reachable the region's ExprIds reachable under the instance's facts
#   passes    how often it was analyzed

namespace eval hir::specialize {
    variable limit 8
    variable passLimit 16
    variable instanceLimit 1000
    # How deeply newly discovered callees are analyzed on demand.
    variable nestLimit 32
    # State of the running analysis (Handle needs it during inference).
    variable state {}
}

proc hir::specialize::analyze {hir args} {
    variable state
    set options [hir::Options hir::specialize::analyze {-specialize 1 -call-facts-opt 1} $args]
    set context [hir::aot::context $hir]
    set state [dict create hir $hir context $context \
        specialize [dict get $options -specialize] callFactsOpt [dict get $options -call-facts-opt] \
        instances [dict create] keys [dict create] byBlock [dict create] \
        seeds [dict create] deps [dict create] refs [dict create] \
        queue {} next 0 current "" building {} analyses 0 \
        refinementFacts [expr {[dict get $options -specialize] ? [RefinementFacts $hir] : {}}]]
    try {
        Instance program {}
        if {[dict get $state specialize]} {
            Fixpoint
        } else {
            SemanticInstances
        }
        return [dict create specialize [dict get $state specialize] \
            instances [dict get $state instances] keys [dict get $state keys] \
            used [Used] context $context]
    } finally {
        set state {}
    }
}

# ---------------------------------------------------------------------------
# The instance cache

# The InstanceId for block BLOCK (or program) with key types KEY-ARGS,
# creating and queueing it if new, after the explosion-control policy.
proc hir::specialize::Instance {block keyArgs} {
    variable state
    variable limit
    variable instanceLimit
    set generic [expr {$block eq "program" || [lsearch -exact -not $keyArgs any] < 0}]
    set key [expr {$block eq "program" ? "program" : [list $block $keyArgs]}]
    if {!$generic && ![dict exists $state keys $key]
            && ([dict size [dict get $state instances]] >= $instanceLimit
                || [LiveSpecializations $block] >= $limit)} {
        set keyArgs [lrepeat [llength $keyArgs] any]
        set key [list $block $keyArgs]
        set generic 1
    }
    if {[dict exists $state keys $key]} {
        return [dict get $state keys $key]
    }
    set id i[dict get $state next]
    dict incr state next
    set context [dict get $state context]
    set name [expr {$block eq "program" ? "<program>"
        : [dict exists $context names $block] ? [dict get $context names $block] : ""}]
    dict set state instances $id [dict create id $id block $block name $name args $keyArgs \
        generic $generic result never seeds {} calls {} creates {} values {} edges {} \
        overlay "" reachable {} passes 0]
    dict set state keys $key $id
    dict set state refs $id 0
    dict set state byBlock $block [concat         [expr {[dict exists $state byBlock $block] ? [dict get $state byBlock $block] : {}}] [list $id]]
    Requeue $id
    return $id
}

# The number of specialized instances of BLOCK in use: referenced by an
# instance, or by the calls of the instance being analyzed.
proc hir::specialize::LiveSpecializations {block} {
    variable state
    if {![dict exists $state byBlock $block]} {
        return 0
    }
    set current [dict get $state current]
    set pending [expr {$current eq "" ? {} : [dict values [dict get $state instances $current calls]]}]
    set count 0
    foreach id [dict get $state byBlock $block] {
        if {![dict get $state instances $id generic]
                && ([dict get $state refs $id] > 0 || $id in $pending)} {
            incr count
        }
    }
    return $count
}

proc hir::specialize::Requeue {id} {
    variable state
    if {$id ni [dict get $state queue]} {
        dict lappend state queue $id
    }
}

proc hir::specialize::AddRef {id} {
    variable state
    dict set state refs $id [expr {[dict get $state refs $id] + 1}]
    if {[dict get $state refs $id] == 1 && [dict get $state instances $id passes] > 0} {
        # Released before: analyze it again.
        Requeue $id
    }
}

proc hir::specialize::DropRef {id} {
    variable state
    dict set state refs $id [expr {[dict get $state refs $id] - 1}]
    if {[dict get $state refs $id] == 0} {
        # No longer used: release it (and what only it uses).
        Requeue $id
    }
}

# The key type of static type TYPE.
proc hir::specialize::KeyType {type} {
    if {[hir::types::IsList $type]} {
        set elem [KeyType [lindex $type 1]]
        if {[llength $type] == 3} {
            return [hir::types::MakeList $elem [lmap p [lindex $type 2] {KeyType $p}] 1]
        }
        return [hir::types::MakeList $elem]
    }
    set kind [hir::types::kindOf $type]
    return [expr {$type eq "never" ? "never" : $kind eq "" ? "any" : $kind}]
}

proc hir::specialize::GenericKey {block} {
    variable state
    return [lrepeat [llength [dict get $state hir exprs $block params]] any]
}

# ---------------------------------------------------------------------------
# Fixpoint
#
# Instances are reference counted by the instances whose reachable code
# uses them (edges: callees, and the generic instances of Block values the
# code materializes). The program is the root. An instance whose count drops
# to 0 is released when it comes up in the worklist: its edges are dropped
# and it is not analyzed (it keeps its result, so a later use still starts
# from a sound assumption). Released instances do not count towards the
# per-block limit, so instances an optimistic early pass needed do not crowd
# out the ones the fixpoint needs.
#
# Instances are unseen (never analyzed), building (being analyzed, possibly
# nested) or analyzed. A call that discovers an unseen callee analyzes it on
# the spot (up to nestLimit deep), so the caller usually sees the callee's
# result on its first pass; a callee that is building (recursion) answers
# with its current result, and the fixpoint corrects it. The worklist
# analyzes the most recently discovered instance first, so callees settle
# before their callers are analyzed again, and the program, often the
# largest region, comes last.

proc hir::specialize::Fixpoint {} {
    variable state
    while {[dict get $state queue] ne ""} {
        set queue [dict get $state queue]
        set newest 0
        for {set i 1} {$i < [llength $queue]} {incr i} {
            if {[string range [lindex $queue $i] 1 end] > [string range [lindex $queue $newest] 1 end]} {
                set newest $i
            }
        }
        set id [lindex $queue $newest]
        dict set state queue [lreplace $queue $newest $newest]
        set instance [dict get $state instances $id]
        set block [dict get $instance block]
        set oldEdges [dict get $instance edges]
        if {$block ne "program" && [dict get $state refs $id] == 0} {
            dict set state instances $id edges {}
            dict set state instances $id calls {}
            dict set state instances $id values {}
            foreach target $oldEdges {
                DropRef $target
            }
            continue
        }
        Analyze $id
    }
}

# ---------------------------------------------------------------------------
# Named-refinement propagation into parameter analysis
#
# A caller-proven named refinement (an opaque type like UriQueryValue, or a
# validator-backed one) reaching a callee's parameter *analysis* is a
# separate question from which specialized *instance* a call selects
# (hir/specialize.tcl's own KeyType already strips named types from
# instance identity, deliberately, to bound how many instances a program
# creates). RefinementFacts computes, once, from the semantic HIR, what
# every exact call of a block's parameter proves in common; RefineParams
# widens that parameter's *seed type* for the instance's own region
# re-inference (Analyze, below) accordingly -- never the instance's key.
# See the milestone doc (opaque-refinement-native-preservation) for the
# full argument; the short version is spec's own §17/18: sharing one
# instance across callers that do and do not prove a fact is sound only
# because a caller that does not prove it makes the intersection empty for
# that parameter, so no fact is attached at all -- nothing here ever lets
# one call site's proof leak into another's.

# Widens TYPES (BindingId -> key type, upvar), for BLOCK's own parameters
# only, with whatever named refinement RefinementFacts proved for them.
proc hir::specialize::RefineParams {block typesVar} {
    variable state
    upvar 1 $typesVar types
    set facts [dict get $state refinementFacts]
    if {![dict exists $facts $block]} {
        return
    }
    set blockFacts [dict get $facts $block]
    foreach b [dict get $state hir exprs $block params] {
        if {![dict exists $blockFacts $b]} {
            continue
        }
        set keyType [dict get $types $b]
        if {$keyType eq "never" || [hir::types::IsSpecific $keyType]} {
            # Not a core (primitive/refined) type -- a callable or
            # aggregate parameter (block, native, list): named refinement
            # evidence is only ever defined for a primitive base, so there
            # is nothing sound to widen here.
            continue
        }
        set base [core::type::base $keyType]
        if {$base eq ""} {
            # Key type any (this instance was never called with a concrete
            # argument its own key would reflect): nothing sound to widen.
            continue
        }
        dict set types $b [core::type::Make $base [dict get $blockFacts $b]]
    }
}

# The elements common to both lists A and B (a plain set intersection; named
# refinement sets here are always short and unsorted).
proc hir::specialize::Intersect {a b} {
    set result {}
    foreach x $a {
        if {$x in $b} {
            lappend result $x
        }
    }
    return $result
}

# BlockExprId -> ParamBindingId -> {NAME...}: the named refinements every
# *exact*, statically resolved call of that block's parameter proves,
# intersected across every such call -- so a fact this returns holds
# regardless of which call reached the parameter.
#
# Purely syntactic, over the semantic (unspecialized) HIR, computed once
# before the fixpoint runs: not a fixpoint itself, and independent of which
# instances specialization goes on to create -- exactly hir/range.tcl's own
# "ExternalSeeds" precedent for numeric ranges (a syntactic look at each
# call's argument expressions, no cross-instance dependency order), adapted
# to a set-valued, intersection lattice instead of an interval one. The two
# lattices differ for a reason: a numeric range genuinely widens across
# recursive calls, so range.tcl needs a small internal fixpoint; a named
# refinement is a property of an *immutable* binding's already-established
# value, so a self/recursive call that forwards a parameter *unchanged*
# trivially preserves whatever is eventually proved for it -- a structural
# induction whose base case is exactly what the non-forwarding callers
# prove -- and is simply skipped below, with no iteration needed.
#
# A call's argument that is anything other than an unchanged forward of the
# very parameter it feeds contributes its own semantic type's evidence
# (hir/types.tcl's Call already computed this on the first, generic pass --
# including, after hir::ApplyNativeResultOverrides, a trusted native's
# declared result). A transformed value (e.g. concat(q, "")) has no
# evidence in its own semantic type unless the operation is itself known to
# preserve it, so it correctly contributes {} -- dropping the fact for that
# parameter unless some other call proves it independently.
proc hir::specialize::RefinementFacts {hir} {
    set callsByBlock [dict create]
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "call"} {
            continue
        }
        set target [dict get $node target]
        if {[lindex $target 0] ne "block"} {
            continue
        }
        set block [lindex $target 1]
        set params [dict get $hir exprs $block params]
        set args [dict get $node args]
        if {[llength $params] != [llength $args]} {
            continue
        }
        dict lappend callsByBlock $block $args
    }
    set facts [dict create]
    dict for {block callArgsList} $callsByBlock {
        set params [dict get $hir exprs $block params]
        set proven [dict create]
        set has [dict create]
        foreach args $callArgsList {
            foreach p $params a $args {
                set argNode [dict get $hir exprs $a]
                if {[dict get $argNode kind] eq "ref" && [dict get $argNode binding] eq $p} {
                    # Unchanged forward of the parameter to itself (a self
                    # or otherwise recursive call): no constraint.
                    continue
                }
                set argType [hir::typeOf $hir $a]
                set evidence [expr {$argType eq "never" || [hir::types::IsSpecific $argType]
                    ? {} : [core::type::evidenceOf $argType]}]
                if {![dict exists $has $p]} {
                    dict set proven $p $evidence
                    dict set has $p 1
                } else {
                    dict set proven $p [Intersect [dict get $proven $p] $evidence]
                }
            }
        }
        set blockFacts [dict create]
        dict for {p evidence} $proven {
            if {$evidence ne ""} {
                dict set blockFacts $p $evidence
            }
        }
        if {[dict size $blockFacts]} {
            dict set facts $block $blockFacts
        }
    }
    return $facts
}

# Analyzes instance ID once: infers its region, records its overlay, calls
# and edges, and updates its result.
proc hir::specialize::Analyze {id} {
    variable state
    variable passLimit
    variable instanceLimit
    set semantic [dict get $state hir]
    set instance [dict get $state instances $id]
    set block [dict get $instance block]
    set oldEdges [dict get $instance edges]
    set outer [dict get $state current]
    dict lappend state building $id
    try {
        dict incr state analyses
        if {[dict get $state analyses] > 64 * $instanceLimit} {
            throw {HIR SPECIALIZE LIMIT} "hir::specialize: the fixpoint did not converge"
        }
        dict set state current $id
        dict set state instances $id passes [expr {[dict get $instance passes] + 1}]
        dict set state instances $id calls {}
        dict set state instances $id creates {}

        set types [dict create]
        set seeds [expr {[dict exists $state seeds $block] ? [dict get $state seeds $block] : {}}]
        if {$block ne "program"} {
            dict for {b type} $seeds {
                dict set types $b $type
            }
            foreach b [dict get $state hir exprs $block params] type [dict get $instance args] {
                dict set types $b $type
            }
            RefineParams $block types
        }
        set scratch [dict get $state hir]
        set inferred [hir::types::inferRegion scratch $block $types hir::specialize::Handle]

        set overlay [dict create]
        set reachable [dict create]
        foreach e [dict get $state context exprs $block] {
            set node [dict get $scratch exprs $e]
            set base [dict get $semantic exprs $e]
            set known [expr {[dict exists $node known] ? [dict get $node known] : ""}]
            # Equal type forms have equal TypeIds: scratch interns into a copy
            # of the semantic type table.
            if {[dict get $node type] ne [dict get $base type]
                    || [dict get $node reachable] != [dict get $base reachable]
                    || $known ne [expr {[dict exists $base known] ? [dict get $base known] : ""}]} {
                dict set overlay $e [list [hir::typeOf $scratch $e] $known [dict get $node reachable]]
            }
            if {[dict get $node reachable]} {
                dict set reachable $e 1
            }
        }
        set instance [dict get $state instances $id]
        dict set instance overlay $overlay
        dict set instance reachable [dict keys $reachable]
        dict set instance seeds $seeds
        dict set instance values [hir::aot::materializedBlocks $semantic [dict get $state context] \
            $block [dict keys $reachable]]
        dict set state instances $id $instance

        # Edges from reachable code only.
        set edges {}
        foreach {e target} [dict get $instance calls] {
            if {[dict exists $reachable $e]} {
                lappend edges $target
            }
        }
        foreach e [dict get $instance values] {
            lappend edges [Instance $e [GenericKey $e]]
        }
        set edges [lsort -unique $edges]
        dict set state instances $id edges $edges
        foreach target $edges {
            AddRef $target
        }
        foreach target $oldEdges {
            DropRef $target
        }
        dict set state current ""

        set old [dict get $state instances $id result]
        set result [hir::types::lub $old $inferred]
        if {[dict get $state instances $id passes] > $passLimit} {
            set result any
        }
        if {$result ne $old} {
            dict set state instances $id result $result
            if {[dict exists $state deps $id]} {
                foreach caller [dict keys [dict get $state deps $id]] {
                    Requeue $caller
                }
            }
        }
    } finally {
        dict set state building [lrange [dict get $state building] 0 end-1]
        dict set state current $outer
    }
}

# The handler region inference calls (hir::types::inferRegion).
proc hir::specialize::Handle {op args} {
    variable state
    set current [dict get $state current]
    switch -- $op {
        call {
            lassign $args e block argTypes
            set region [dict get $state instances $current block]
            set keyArgs [lmap type $argTypes {KeyType $type}]
            # Exact closure calls can specialize: captured types are joined
            # across creations, and a growing join requeues instances.
            if {$block ni [dict get $state context statics]} {
                # Bound code growth for value-capturing closures. Scalar Int
                # captures can feed the existing raw representation path;
                # aggregate and managed captures retain the generic entry.
                set scalarCaptures [dict exists $state seeds $block]
                if {$scalarCaptures} {
                    foreach b [dict get $state hir exprs $block captures] {
                        if {![dict exists $state seeds $block $b]
                                || [hir::types::kindOf [dict get $state seeds $block $b]] ne "int"} {
                            set scalarCaptures 0
                            break
                        }
                    }
                }
                if {![dict get $state callFactsOpt] || !$scalarCaptures} {
                    set keyArgs [GenericKey $block]
                }
            }
            set target ""
            if {$block eq $region && [dict exists $state context selfTails $e]} {
                set own [dict get $state instances $current args]
                set within 1
                foreach k $keyArgs o $own {
                    if {![hir::types::subtype $k $o]} {
                        set within 0
                    }
                }
                if {$within} {
                    set target $current
                } else {
                    set keyArgs [lmap k $keyArgs o $own {KeyType [hir::types::lub $k $o]}]
                }
            }
            if {$target eq ""} {
                set target [Instance $block $keyArgs]
                variable nestLimit
                if {[dict get $state instances $target passes] == 0
                        && [llength [dict get $state building]] < $nestLimit} {
                    # Unseen: analyze it now.
                    set queue [dict get $state queue]
                    set index [lsearch -exact $queue $target]
                    dict set state queue [lreplace $queue $index $index]
                    Analyze $target
                }
            }
            dict set state instances $current calls $e $target
            dict set state deps $target $current 1
            return [dict get $state instances $target result]
        }
        create {
            lassign $args e seeds
            set old [expr {[dict exists $state seeds $e] ? [dict get $state seeds $e] : {}}]
            set merged $old
            dict for {b type} $seeds {
                set before [expr {[dict exists $old $b] ? [dict get $old $b] : "never"}]
                dict set merged $b [hir::types::lub $before $type]
            }
            if {$merged ne $old} {
                dict set state seeds $e $merged
                if {[dict exists $state byBlock $e]} {
                    foreach id [dict get $state byBlock $e] {
                        Requeue $id
                    }
                }
            }
            dict set state instances $current creates \
                [concat [dict get $state instances $current creates] [list $e]]
            return
        }
    }
    error "hir::specialize: unknown handler operation \"$op\""
}

# specialize 0: one generic instance per block, with the semantic types and
# the calls HIR resolved.
proc hir::specialize::SemanticInstances {} {
    variable state
    set hir [dict get $state hir]
    set context [dict get $state context]
    dict for {region exprs} [dict get $context exprs] {
        if {$region eq "program"} {
            set id [dict get $state keys program]
        } else {
            set id [Instance $region [GenericKey $region]]
            dict set state instances $id result [hir::type $hir [hir::get $hir $region resultType]]
        }
        set edges {}
        set reachable {}
        foreach e $exprs {
            if {![hir::get $hir $e reachable]} {
                continue
            }
            lappend reachable $e
            switch -- [hir::kind $hir $e] {
                block {
                    dict set state instances $id creates \
                        [concat [dict get $state instances $id creates] [list $e]]
                }
                call {
                    lassign [hir::get $hir $e target] kind target
                    if {$kind eq "block" && [llength [hir::get $hir $target params]] == [llength [hir::get $hir $e args]]} {
                        set callee [Instance $target [GenericKey $target]]
                        dict set state instances $id calls $e $callee
                        lappend edges $callee
                    }
                }
            }
        }
        set values [hir::aot::materializedBlocks $hir $context $region $reachable]
        dict set state instances $id values $values
        dict set state instances $id reachable $reachable
        foreach block $values {
            lappend edges [Instance $block [GenericKey $block]]
        }
        dict set state instances $id edges [lsort -unique $edges]
    }
    dict set state queue {}
}

# InstanceIds reachable from the program through edges, in program order.
proc hir::specialize::Used {} {
    variable state
    set seen [dict create]
    set work [list [dict get $state keys program]]
    while {$work ne ""} {
        set work [lassign $work id]
        if {[dict exists $seen $id]} {
            continue
        }
        dict set seen $id 1
        lappend work {*}[dict get $state instances $id edges]
    }
    return [Order [dict keys $seen]]
}

# IDS sorted by their block's position in the program, then by InstanceId.
proc hir::specialize::Order {ids} {
    variable state
    set keyed [lmap id $ids {
        set block [dict get $state instances $id block]
        list [expr {$block eq "program" ? 0 : [dict get $state context positions $block]}] \
            [string range $id 1 end] $id
    }]
    return [lmap entry [lsort -integer -index 0 [lsort -integer -index 1 $keyed]] {
        lindex $entry 2
    }]
}

# ---------------------------------------------------------------------------
# Queries

proc hir::specialize::instance {analysis id} {
    return [dict get $analysis instances $id]
}

# The generic InstanceId of block BLOCK, or "" if the analysis has none (the
# block is never created by analyzed code).
proc hir::specialize::genericInstance {hir analysis block} {
    set key [list $block [lrepeat [llength [hir::get $hir $block params]] any]]
    if {[dict exists $analysis keys $key]} {
        return [dict get $analysis keys $key]
    }
    return ""
}

# The HIR as instance ID sees it: the semantic HIR with the instance's
# overlay applied to its region, its parameters' binding types set to its
# key types and its block's result type to the instance's result.
proc hir::specialize::view {hir analysis id} {
    set instance [dict get $analysis instances $id]
    set overlay [dict get $instance overlay]
    if {![dict get $analysis specialize]} {
        return $hir
    }
    dict for {e entry} $overlay {
        lassign $entry type known reachable
        dict set hir exprs $e type [hir::types::intern hir $type]
        dict set hir exprs $e reachable $reachable
        if {$known ne "" || [dict exists $hir exprs $e known]} {
            dict set hir exprs $e known $known
        }
    }
    set block [dict get $instance block]
    if {$block ne "program"} {
        foreach b [hir::get $hir $block params] type [dict get $instance args] {
            dict set hir bindings $b type [hir::types::intern hir $type]
        }
        dict set hir exprs $block resultType [hir::types::intern hir [dict get $instance result]]
    }
    return $hir
}

# The display name of instance ID: NAME<generic> or NAME<T1, T2>.
proc hir::specialize::label {analysis id} {
    set instance [dict get $analysis instances $id]
    set name [dict get $instance name]
    set block [dict get $instance block]
    if {$block eq "program"} {
        return $name
    }
    if {$name eq ""} {
        set name "block $block"
    }
    if {[dict get $instance generic]} {
        return "$name<generic>"
    }
    return "$name<[join [lmap t [dict get $instance args] {hir::types::show $t}] {, }]>"
}

# The hir::aot region analysis of instance ID (on its view), with
#   instance  ID       label  its label
#   callees   the InstanceIds it calls directly
proc hir::specialize::region {hir analysis id} {
    set instance [dict get $analysis instances $id]
    set region [hir::aot::analyzeRegion [view $hir $analysis $id] [dict get $instance block] \
        [dict get $analysis context]]
    dict set region instance $id
    dict set region label [label $analysis $id]
    dict set region callees [lsort -unique [dict values [dict get $instance calls]]]
    return $region
}

# InstanceId -> region (see region) for every used instance, with transitive
# status over instance calls.
proc hir::specialize::regions {hir analysis} {
    set regions [dict create]
    foreach id [dict get $analysis used] {
        dict set regions $id [region $hir $analysis $id]
    }
    return [hir::aot::Transitive $regions]
}

# Guard accounting: dict of
#   generic       representation blockers of the semantic analysis
#                 (hir::aot::analyze), over all regions
#   specialized   representation blockers over the used instances
#   instances     number of used instances; genericInstances, specializedInstances
#   perFunction   function name -> {generic 0|1 specializations N}, in
#                 program order (blocks with a used instance)
proc hir::specialize::summary {hir analysis {regions ""}} {
    if {$regions eq ""} {
        set regions [regions $hir $analysis]
    }
    set generic 0
    dict for {id region} [dict get [hir::aot::analyze $hir] regions] {
        incr generic [RepresentationBlockers $region]
    }
    set specialized 0
    set counts [dict create]
    set perFunction [dict create]
    set genericCount 0
    set specializedCount 0
    foreach id [dict get $analysis used] {
        incr specialized [RepresentationBlockers [dict get $regions $id]]
        set instance [dict get $analysis instances $id]
        if {[dict get $instance block] eq "program"} {
            continue
        }
        set name [dict get $instance name]
        if {$name eq ""} {
            set name "block [dict get $instance block]"
        }
        if {![dict exists $perFunction $name]} {
            dict set perFunction $name [dict create generic 0 specializations 0]
        }
        if {[dict get $instance generic]} {
            dict set perFunction $name generic 1
            incr genericCount
        } else {
            dict set perFunction $name specializations \
                [expr {[dict get $perFunction $name specializations] + 1}]
            incr specializedCount
        }
    }
    return [dict create generic $generic specialized $specialized \
        instances [llength [dict get $analysis used]] \
        genericInstances $genericCount specializedInstances $specializedCount \
        perFunction $perFunction]
}

proc hir::specialize::RepresentationBlockers {region} {
    return [llength [lmap b [dict get $region blockers] {
        if {[dict get $b class] ne "representation"} continue
        set b
    }]]
}

# ---------------------------------------------------------------------------
# Human-readable explanation

# For each function in program order: its semantic (generic) AOT report,
# then every used instance's, with parameters, result, status, blockers and
# the instances it calls.
proc hir::specialize::explain {hir {analysis ""}} {
    if {$analysis eq ""} {
        set analysis [analyze $hir]
    }
    set regions [regions $hir $analysis]
    set semantic [dict get [hir::aot::analyze $hir] regions]
    set lines {}
    set shown {}
    foreach id [dict get $analysis used] {
        set instance [dict get $analysis instances $id]
        set block [dict get $instance block]
        set region [dict get $regions $id]
        if {$block ni $shown && $block ne "program"} {
            lappend shown $block
            set generic [dict get $semantic $block]
            lappend lines "[dict get $instance name] (semantic): [dict get $generic status]   \[[join [BlockerCounts $generic] {, }]\]"
        }
        set status [dict get $region status]
        set header "[dict get $region label]: $status"
        if {[dict get $region transitive] ne $status} {
            append header " (transitively [dict get $region transitive])"
        }
        append header "   \[$id, [hir::aot::LocationText [dict get $region location]]\]"
        lappend lines $header
        if {$block ne "program"} {
            lappend lines "  params:   [expr {[dict get $region params] eq "" ? "(none)" : [join [lmap p [dict get $region params] {
                string cat [dict get $p name] " : " [hir::types::show [dict get $p type]]
            }] {, }]}]"
            lappend lines "  result:   [hir::types::show [dict get $instance result]]"
        }
        set calls [lsort -unique [lmap {e target} [dict get $instance calls] {label $analysis $target}]]
        if {$calls ne ""} {
            lappend lines "  calls:    [join $calls {, }]"
        }
        set guards [RepresentationBlockers $region]
        lappend lines "  guards:   $guards"
        foreach blocker [dict get $region blockers] {
            lappend lines "    [hir::aot::LocationText [dict get $blocker location]]  [dict get $blocker expr]  [dict get $blocker kind]: [dict get $blocker message]"
        }
        set requirements [dict get $region requirements]
        lappend lines "  runtime:  [expr {$requirements eq "" ? "none" : [join $requirements {, }]}]"
        lappend lines ""
    }
    set summary [summary $hir $analysis $regions]
    lappend lines "guards: generic [dict get $summary generic], specialized [dict get $summary specialized]; instances: [dict get $summary genericInstances] generic, [dict get $summary specializedInstances] specialized"
    return [join $lines \n]
}

proc hir::specialize::BlockerCounts {region} {
    set counts [dict create]
    foreach b [dict get $region blockers] {
        dict incr counts [dict get $b kind]
    }
    if {![dict size $counts]} {
        return [list "no blockers"]
    }
    return [lmap {kind n} $counts {string cat $kind " " $n}]
}
