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
#   {block E ARITY any ?CONTRACT?}  an EXACT Botlish callable: the code
#                                   target E (a block ExprId, i.e. binding/
#                                   declaration identity, never a printed
#                                   name) and its arity. Which closure
#                                   *values* (captured environments) reach
#                                   it is not part of the key: the value
#                                   itself is still an ordinary argument
#   {native NAME}                   an EXACT native: its registry name
#   block native                    a callable of that kind only: what an
#                                   exact callable degrades to when the
#                                   target budget is spent (exactLimit) or
#                                   -exact-callable-opt 0
#   (a structural function type)    any: a Fn value has no one runtime
#                                   kind, and its contract never selects
#                                   an instance (STRUCTURAL-FUNCTION-
#                                   TYPES.md, "KeyType / specialization
#                                   projection") -- a declared Fn
#                                   parameter's contract still reaches the
#                                   instance's own body through its
#                                   declared-type seed (Analyze), never
#                                   through the key
#   list, {list ELEM}, {list ELEM SHAPE}
#                                   aggregate facts with key-typed elements
#                                   (a callable *inside* an aggregate stays
#                                   the kind-only `block`/`native`: nothing
#                                   proves which element a read returns)
#
# Exact callable keys (EXACT-CALLABLE-CLOSED-CALLER.md): the identity of a
# callable argument IS representation-relevant, because it decides how a
# call through the parameter is lowered -- an indirect `callvalue` when the
# key only says `block`, a direct call (or direct native operation) when it
# names the target -- and every downstream analysis (StringRegion,
# blockescape, tiny-leaf inlining, error and range facts) then sees the
# ordinary exact call. The semantic type is unchanged; only the codegen
# projection stopped erasing what it already knew.
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
#     to bound code growth, except that an exact callable argument keeps its
#     identity in the key (bounded by exactLimit): which code a parameter
#     runs is representation-relevant, the captured values are not. A
#     materialized Block retains a generic entry.
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
#   closed      InstanceId -> 1 for every used instance InstanceClosed
#               proves closed (the one authoritative closedness result;
#               see "InstanceClosed" below)
#   dormant     InstanceId -> 1 for every used instance that is never
#               entered at run time (DormantInstances, below): kept in
#               `used`, but no evidence for anything else
#   exactCallable  1 if exact callable identity may enter keys
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
#   overlay   ExprId -> {TYPE KNOWN REACHABLE ?TARGET?} for the region's
#             expressions whose facts differ from the semantic HIR's (""
#             for semantic types: specialize 0). TARGET is "" or the call
#             target this instance resolves a call to that the semantic HIR
#             leaves open ({block E} or {native NAME}): a call through a
#             parameter whose key names an exact callable
#   reachable the region's ExprIds reachable under the instance's facts
#   passes    how often it was analyzed

namespace eval hir::specialize {
    variable limit 8
    # EXACT-CALLABLE-CLOSED-CALLER.md: at most this many live specialized
    # instances of one block may be keyed by an exact callable target; a
    # further distinct target degrades to the kind-only `block`/`native`
    # key (the pre-existing generic callable key). Deterministic: which
    # target meets the budget first depends on discovery order. Default 4,
    # measured (EXACT-CALLABLE-CLOSED-CALLER.md, "Specialization budget"):
    # each extra exact instance of a small higher-order function costs about
    # half a kilobyte of machine code and a few milliseconds of lowering,
    # the corpus's most-targeted function has 2 targets, and the per-block
    # `limit` above (8, shared with kind keys) is the hard ceiling anyway.
    # analyze's -exact-callable-limit overrides it per analysis.
    variable exactLimit 4
    variable passLimit 16
    variable instanceLimit 1000
    # How deeply newly discovered callees are analyzed on demand.
    variable nestLimit 32
    # State of the running analysis (Handle needs it during inference).
    variable state {}
    # M7.c.1 (M7C1-CLOSECALLERS-CONVERGENCE-FENCE.md): test-only override of
    # CloseCallers' own round budget, read only by CloseCallers -- "" means
    # "use the production passLimit (16)". Never read by the ordinary
    # Fixpoint above, so a test that sets this cannot perturb Fixpoint's own
    # unrelated non-convergence safety valve. Not a user-facing flag:
    # -closed-caller-facts-opt alone still controls whether the M7.c pass is
    # attempted at all.
    variable closeCallersRoundLimit ""
    # Whether the most recent CloseCallers pass committed its candidate (1)
    # or rolled back to the pre-pass snapshot because its round budget was
    # exhausted while state was still changing (0). A debug/audit signal for
    # tests and tooling, not a compiler diagnostic: non-convergence is never
    # a source-program error (see CloseCallers' own comment).
    variable closeCallersConverged 1
    # GENERIC-PREDICATE-PROOF-LOSS.md, loss point 2: test/audit knob, not a
    # user-facing flag. 0 makes DormantInstances find nothing, which
    # reproduces the compiler before the dormant set existed.
    variable dormantOpt 1
    # GENERIC-PREDICATE-PROOF-LOSS.md, loss point 1: test/audit knob, not a
    # user-facing flag. 0 restores the closure key rule before it (a
    # value-capturing closure with a non-Int capture keeps only exact
    # callable key positions, not Int ones).
    variable closureIntKeyOpt 1
}

proc hir::specialize::analyze {hir args} {
    variable state
    set options [hir::Options hir::specialize::analyze \
        {-specialize 1 -call-facts-opt 1 -closed-caller-facts-opt 1 -exact-callable-opt 1
         -exact-callable-limit {}} $args]
    variable exactLimit
    set context [hir::aot::context $hir]
    set state [dict create hir $hir context $context \
        specialize [dict get $options -specialize] callFactsOpt [dict get $options -call-facts-opt] \
        exactCallableOpt [dict get $options -exact-callable-opt] \
        exactLimit [expr {[dict get $options -exact-callable-limit] ne ""
            ? [dict get $options -exact-callable-limit] : $exactLimit}] \
        instances [dict create] keys [dict create] byBlock [dict create] \
        seeds [dict create] deps [dict create] refs [dict create] \
        queue {} next 0 current "" building {} analyses 0 \
        refinementFacts [expr {[dict get $options -specialize] ? [RefinementFacts $hir] : {}}]]
    try {
        Instance program {}
        if {[dict get $state specialize]} {
            Fixpoint
            if {[dict get $options -closed-caller-facts-opt]} {
                # M7.c (M7C-CLOSED-CLOSURE-ENTRY-FACTS.md): once the ordinary
                # fixpoint above has converged, the complete call graph for
                # every used instance is known. Only then can closedness (an
                # instance's complete runtime ingress) and a closed-caller
                # entry-kind theorem be soundly derived -- see CloseCallers'
                # own header for why this cannot run any earlier.
                CloseCallers
            }
        } else {
            SemanticInstances
        }
        set analysis [dict create specialize [dict get $state specialize] \
            instances [dict get $state instances] keys [dict get $state keys] \
            used [Used] context $context \
            exactCallable [expr {[dict get $state specialize] && [dict get $state exactCallableOpt]}]]
        # The one authoritative closedness result (see InstanceClosed): every
        # later consumer reads it from here rather than re-deriving it.
        # CloseCallers already ran blockescape over the identical frozen graph
        # (it reads only structure and calls/edges/values/used, which that
        # pass never writes), so its result is reused rather than recomputed.
        set be [expr {[dict exists $state blockescape] ? [dict get $state blockescape]
            : [hir::blockescape::analyze $hir $analysis]}]
        dict set analysis closed [ClosedInstances $hir $analysis $be]
        dict set analysis dormant [DormantInstances $analysis $be]
        return $analysis
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
    if {$block ne "program" && [HasExactCallable $keyArgs]
            && ![dict exists $state keys [list $block $keyArgs]]
            && [LiveExactSpecializations $block] >= [dict get $state exactLimit]} {
        # The exact-target budget is spent: this target shares the existing
        # kind-only callable key (callers of it use the ordinary
        # callable-value ABI), exactly the pre-exact behavior.
        set keyArgs [lmap k $keyArgs {CoarseCallable $k}]
    }
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

# The number of specialized instances of BLOCK in use (as LiveSpecializations
# counts them) whose key names an exact callable target.
proc hir::specialize::LiveExactSpecializations {block} {
    variable state
    if {![dict exists $state byBlock $block]} {
        return 0
    }
    set current [dict get $state current]
    set pending [expr {$current eq "" ? {} : [dict values [dict get $state instances $current calls]]}]
    set count 0
    foreach id [dict get $state byBlock $block] {
        if {[dict get $state instances $id generic] || ![HasExactCallable [dict get $state instances $id args]]} {
            continue
        }
        if {[dict get $state refs $id] > 0 || $id in $pending} {
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

# The key type of static type TYPE (an argument of an instance's call).
# Deliberately coarser than TYPE itself (evidence, applied types, a
# structural function type's contract never select an instance), with one
# deliberate exception: an EXACT callable keeps its identity.
#
#   {block E ARITY any ?CONTRACT?}   exact Botlish callable E
#   {native NAME}                    exact native
#
# Before EXACT-CALLABLE-CLOSED-CALLER.md both were reduced to the kinds
# `block`/`native` on the stated premise that "a call through either is the
# same indirect callvalue". That premise held only because the key erased
# the identity: with it kept, the call through the parameter is a direct call
# of a known target, and every downstream analysis sees it. The block's
# result slot is normalized to any (it is a property of the creating walk,
# which grows during the fixpoint; the target's own instance carries the
# result) and its contract, a function of E alone (hir::types::blockType),
# is kept. Natives are identified by registry name, never by signature.
#
# A callable *inside* an aggregate (a List element, a struct field) is not
# exact here (ElementKeyType): nothing proves which element a read returns,
# and aggregate exact-value propagation is out of scope.
proc hir::specialize::KeyType {type} {
    if {[hir::types::IsExactBlock $type]} {
        return [lreplace $type 3 3 any]
    }
    if {[hir::types::IsExactNative $type]} {
        return $type
    }
    return [ElementKeyType $type]
}

# The kind-only projection KeyType applied to every type before exact
# callable keys: an exact callable's identity is erased to its kind, a
# structural function type to any.
proc hir::specialize::ElementKeyType {type} {
    if {[hir::types::IsList $type]} {
        set elem [ElementKeyType [lindex $type 1]]
        if {[llength $type] == 3} {
            return [hir::types::MakeList $elem [lmap p [lindex $type 2] {ElementKeyType $p}] 1]
        }
        return [hir::types::MakeList $elem]
    }
    if {[hir::types::IsStruct $type]} {
        # A struct (STRUCTS.md) keeps what its code generation depends on: the
        # field names -- the layout, which every field projection's slot
        # index comes from -- with each field type reduced to its key type
        # exactly like a List's element: `{x: MutableArray[int]}` and
        # `{x: MutableArray[str]}` share a key (both mutarray), `{x: int}` and
        # `{x: str}` do not (typed field operations differ). The semantic
        # field types (evidence, applied types) never enter the key.
        set fields [dict create]
        dict for {name t} [lindex $type 1] {
            dict set fields $name [ElementKeyType $t]
        }
        return [hir::types::MakeStruct $fields 0]
    }
    if {[hir::types::IsNamedStruct $type]} {
        # A named struct's layout and field types are its declaration's.
        return $type
    }
    set kind [hir::types::kindOf $type]
    return [expr {$type eq "never" ? "never" : $kind eq "" ? "any" : $kind}]
}

# 1 if KEY (a key type) names an exact callable.
proc hir::specialize::IsExactCallableKey {key} {
    return [expr {[hir::types::IsExactBlock $key] || [hir::types::IsExactNative $key]}]
}

# 1 if some key type of KEYARGS names an exact callable.
proc hir::specialize::HasExactCallable {keyArgs} {
    foreach k $keyArgs {
        if {[IsExactCallableKey $k]} {
            return 1
        }
    }
    return 0
}

# KEY with an exact callable reduced to its kind (`block`/`native`), any
# other key unchanged: the generic callable key.
proc hir::specialize::CoarseCallable {key} {
    if {[hir::types::IsExactBlock $key]} {
        return block
    }
    if {[hir::types::IsExactNative $key]} {
        return native
    }
    return $key
}

# The join of two key types. Two different callables (exact or kind-only)
# join to their common kind (`block`/`native`) or any, exactly as the kind
# keys joined before exact keys: never to a structural function contract,
# which would add a fact the pre-exact keys never carried. Equal keys (the
# same exact target on both sides) keep the exact identity.
proc hir::specialize::JoinKey {a b} {
    if {$a eq $b} {
        return $a
    }
    if {[IsCallableKey $a] && [IsCallableKey $b]} {
        set ca [CoarseCallable $a]
        set cb [CoarseCallable $b]
        return [expr {$ca eq $cb ? $ca : "any"}]
    }
    return [hir::types::lub $a $b]
}

proc hir::specialize::IsCallableKey {key} {
    return [expr {[IsExactCallableKey $key] || $key in {block native}}]
}

# The label text of key type KEY: an exact callable as block(e239) /
# native(str::is_tcl_alpha), everything else as hir::types::show. (The block's
# ExprId is a diagnostic handle for audits, never a language feature.)
proc hir::specialize::ShowKey {key} {
    if {[hir::types::IsExactBlock $key]} {
        return "block([lindex $key 1])"
    }
    if {[hir::types::IsExactNative $key]} {
        return "native([lindex $key 1])"
    }
    return [hir::types::show $key]
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
        # Union, never replace (M1 spec #25-26): KEYTYPE may already carry
        # the function's own declared-parameter evidence (the caller of
        # this proc seeds that first); widening by named-refinement
        # evidence proven at every exact call must only add to that, never
        # drop it merely because this particular evidence set does not
        # happen to repeat it.
        dict set types $b [hir::types::narrow $keyType [core::type::Make $base [dict get $blockFacts $b]]]
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
# including, through a call's nativeResultOverride, a trusted native's
# declared result). A transformed value (e.g. str::concat(q, "")) has no
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
            foreach b [dict get $state hir exprs $block params] type [dict get $instance args] \
                    declaredType [hir::signatures::entryTypes [dict get $state hir] $block] {
                if {$declaredType eq {}} {
                    dict set types $b $type
                    continue
                }
                if {![hir::types::IsSpecific $type]} {
                    # M1: the function's own declared parameter contract is
                    # valid for every instance, generic included -- every
                    # legal call already proved it (hir::range::
                    # verifyDeclaredParams for a direct call; hir/callables.
                    # tcl rejects every escape path that would let a typed
                    # callable, and so this contract, reach a call erased
                    # of its exact identity -- see M1-DECLARED-PARAMETER-
                    # FACT-TRANSPORT.md). Adding it can only add a
                    # fact, never lose one: TYPE is not itself specific
                    # (never a shaped/callable key already carrying its own
                    # structural facts, which this leaves untouched -- item
                    # 32's container/callable case), so it is either any
                    # (a generic instance, adopting the declared type
                    # outright -- hir::types::narrow's own "a core type"
                    # contract does not cover an aggregate/callable FACT,
                    # so a declared List[T]/ImmutableSet[T] etc. is adopted
                    # directly rather than routed through narrow) or an
                    # already-specialized scalar key sharing the declared
                    # type's base, unioned with its evidence via narrow.
                    set type [expr {[hir::types::IsSpecific $declaredType]
                        ? $declaredType : [hir::types::narrow $type $declaredType]}]
                } elseif {([hir::types::IsList $type] && [hir::types::IsList $declaredType])
                        || ([hir::types::IsSet $type] && [hir::types::IsSet $declaredType])} {
                    # M7.b (M7B-CONJUNCTIVE-ENTRY-FACTS.md): TYPE is already
                    # "specific" here -- an aggregate KEY, the *observed*
                    # instance fact (a caller's shape, or M7.a.a's provably
                    # empty `never` element) -- which is exactly the case M1
                    # above declined to touch, because a bare hir::types::
                    # narrow cannot combine two aggregate forms. It can now
                    # (hir/types.tcl's own narrow was extended to recurse
                    # into a matching List/ImmutableSet's element position),
                    # so combine conjunctively instead of either keeping TYPE
                    # alone (M7.a's own "S05d": the declared element theorem
                    # stays lost) or replacing it with DECLAREDTYPE outright
                    # (would silently erase a proven-empty `never` element,
                    # the M7.a.a regression this milestone must not cause).
                    # The instance's own KEY (this proc's caller, `args`)
                    # and therefore its identity are untouched: only this
                    # local per-instance region re-inference seed changes.
                    #
                    # The declared parameter theorem and the instance
                    # observation are already known compatible because
                    # declared-parameter verification precedes
                    # specialization (hir::range::verifyDeclaredParams runs,
                    # and hir::callables::verify closes every escape path
                    # that could reach a call erased of this guarantee,
                    # before hir::specialize ever runs). narrow combines
                    # already-compatible facts here; it is not itself an
                    # admissibility check.
                    set type [hir::types::narrow $type $declaredType]
                }
                dict set types $b $type
            }
            RefineParams $block types
        }
        set scratch [dict get $state hir]
        set inferred [hir::types::inferRegion scratch $block $types hir::specialize::Handle]
        if {$block ne {program} && [dict get $semantic exprs $block declaredResult] ne {}} {
            set inferred [dict get $semantic exprs $block declaredResult]
        }

        set overlay [dict create]
        set reachable [dict create]
        foreach e [dict get $state context exprs $block] {
            set node [dict get $scratch exprs $e]
            set base [dict get $semantic exprs $e]
            set known [expr {[dict exists $node known] ? [dict get $node known] : ""}]
            # Equal type forms have equal TypeIds: scratch interns into a copy
            # of the semantic type table.
            set target [InstanceTarget $scratch $node $base]
            if {[dict get $node type] ne [dict get $base type]
                    || [dict get $node reachable] != [dict get $base reachable]
                    || $known ne [expr {[dict exists $base known] ? [dict get $base known] : ""}]
                    || $target ne ""} {
                dict set overlay $e [OverlayEntry [hir::typeOf $scratch $e] $known [dict get $node reachable] $target]
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

# One overlay entry: {TYPE KNOWN REACHABLE} plus, only when the instance
# resolves a call the semantic HIR leaves open, its TARGET.
proc hir::specialize::OverlayEntry {type known reachable target} {
    if {$target eq ""} {
        return [list $type $known $reachable]
    }
    return [list $type $known $reachable $target]
}

# The target instance region inference resolved for call node NODE (of the
# SCRATCH HIR) when the semantic HIR BASE node left it open: a call through a
# parameter whose key names an exact callable. {block E}, {native NAME}
# (natives by registry name: a symbol id belongs to one HIR copy), or ""
# for every other expression and every call the semantic HIR already
# resolved (a call's semantic target is never changed, only added).
proc hir::specialize::InstanceTarget {scratch node base} {
    if {[dict get $node kind] ne "call" || ![dict exists $node target]} {
        return ""
    }
    set target [dict get $node target]
    if {$target eq "" || ([dict exists $base target] && [dict get $base target] ne "")} {
        return ""
    }
    lassign $target kind value
    if {$kind eq "native"} {
        return [list native [dict get [hir::symbol $scratch $value] name]]
    }
    return $target
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
            if {![dict get $state exactCallableOpt]} {
                set keyArgs [lmap k $keyArgs {CoarseCallable $k}]
            }
            # Exact closure calls can specialize: captured types are joined
            # across creations, and a growing join requeues instances.
            if {$block ni [dict get $state context statics]} {
                # Bound code growth for value-capturing closures. Scalar Int
                # captures can feed the existing raw representation path;
                # aggregate and managed captures retain the generic entry for
                # every parameter except an exact callable or an Int (below).
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
                if {![dict get $state callFactsOpt]} {
                    set keyArgs [GenericKey $block]
                } elseif {!$scalarCaptures} {
                    # What the generic-key rule protects is code growth and
                    # blockescape's single-instance de-closure proof, not
                    # correctness: the captured values reach the instance
                    # through the closure value and the capture seeds, never
                    # through the key, and a specialized instance is only
                    # ever entered by the exact calls that selected it (a
                    # materialized Block keeps its own generic entry). A
                    # callable argument's identity is different in kind: it
                    # selects direct versus indirect lowering of the call
                    # through the parameter. So the exact callable positions
                    # keep their identity (bounded by exactLimit).
                    #
                    # An Int position keeps its kind too (GENERIC-PREDICATE-
                    # PROOF-LOSS.md, loss point 1): Int is the one kind with a
                    # representation consequence (Range facts, raw Int
                    # operations and the RawInt ABI all read an Int key), and
                    # the cost is bounded like any other key (`limit`
                    # instances per block). The literal's generic instance
                    # then stays used only as the Block-value entry; when
                    # blockescape de-closures the binding that entry is
                    # dormant (DormantInstances), so its unknown-kind calls
                    # are no evidence for the keyed instances' facts, and an
                    # exact call that still selects it (an argument of
                    # another kind) makes it a de-closure target of its own
                    # (hir::blockescape::RelevantInstances). Every other
                    # position stays generic, to be refined by the
                    # closed-caller theorem (ClosedSet) exactly as before.
                    variable closureIntKeyOpt
                    set keyArgs [lmap k $keyArgs {
                        expr {[IsExactCallableKey $k] || ($closureIntKeyOpt && $k eq "int") ? $k : "any"}
                    }]
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
                    set keyArgs [lmap k $keyArgs o $own {KeyType [JoinKey $k $o]}]
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
            set result [dict get $state instances $target result]
            # Never less precise than the semantic HIR: a semantic instance
            # (hir/semantic.tcl) may already prove a more precise result for
            # this call than a key-type instance can (KeyType(MutableArray[T])
            # is the raw kind). Both are sound, so the more precise wins.
            set semantic [hir::semantic::GenericResult [dict get $state hir] $e]
            if {$semantic ne "" && [hir::types::subtype $semantic $result]} {
                set result $semantic
            }
            return $result
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

# ---------------------------------------------------------------------------
# M7.c: closed-closure caller-derived entry-kind theorems
# (M7C-CLOSED-CLOSURE-ENTRY-FACTS.md)
#
# Family 1b (M7A-INSTANCE-SELECTION-THEOREM-AUDIT.md): a value-capturing
# closure's KeyType is always forced generic (Handle's own GenericKey
# collapse above, "Bound code growth for value-capturing closures"), so its
# instance's parameters seed "any" even where every actual runtime caller
# passes one consistent kind. M1/M7.b already transport a *declared*
# parameter theorem into a generic instance's own seed; this milestone adds
# a second, independently sound theorem -- derived from the instance's own
# *closed* set of callers -- through the exact same seeding mechanism
# (Analyze's own parameter loop, mirrored below by Reanalyze), so existing
# downstream guard/type machinery removes the resulting guards with no
# change of its own (spec item 49).
#
# Closedness: see "InstanceClosed" below -- since EXACT-CALLABLE-CLOSED-
# CALLER.md the one authoritative proof, shared with hir::range (whose own
# coarser "some Block value of it is materialized" test is gone). It was
# the right, audited answer for an ordinary (static/envless) block -- and is
# InstanceClosed's static branch unchanged -- but NOT for a family-1b
# *closure*: hir::aot::materializedBlocks' own "bind" case counts *every*
# bind of a non-envless (capturing) closure as materializing, unconditionally
# (`$value ni $envless` alone, no reference-level check) -- correct for its
# own conservative purpose, but it makes that test say "open" for
# essentially every value-capturing closure regardless of how it is actually
# referenced (confirmed empirically against both frozen benchmarks: every
# family-1b guard site except plain-static cascades reads open=1 there).
# The finer, already-existing proof that most of these closures' *every*
# reference actually is an exact, statically resolved call is
# hir::blockescape's own eligibility fixpoint (RefsAsCalls): reused directly
# below (InstanceClosed's "closure" branch) rather than building a second
# escape analysis, per spec item 10's own explicit preference. hir::blockescape
# already needs this exact proof for a stronger consequence (skipping heap
# allocation entirely), so this milestone's own closedness proof is no less
# audited than that existing, shipped guarantee.
#
# Why this cannot run any earlier than a whole extra pass, after Fixpoint
# has converged: blockescape's own analysis (like hir::range::analyze's)
# takes the *finished* `used`/`calls` graph as input -- a closure's
# reference set is only completely known once specialization itself is
# done discovering instances and edges. Analyze's own M1/M7.b seeding, by
# contrast, needs no such wait, because a function's declared-parameter
# theorem is available before any instance exists at all.
#
# Never creating a new instance or edge (spec items 22, 41, 43, 50, 54, 89):
# Reanalyze below re-runs hir::types::inferRegion for exactly one already-
# used instance, with FrozenHandle in place of the ordinary Handle -- it
# never calls Instance, so it can only ever resolve a "call" op to the
# *same* target hir::specialize's own ordinary Fixpoint already recorded in
# that instance's own `calls` map. A narrower seed can only prune
# reachability (decide more branches, never fewer -- soundness of the
# existing type-inference lattice), so every call FrozenHandle is ever asked
# about is guaranteed to already have an entry there; if that invariant is
# ever wrong, FrozenHandle degrades safely (returns "any"/no target) rather
# than fail loudly, since this whole pass is optimization-only (spec #85).
#
# Cascades and fixpoint (spec items 17-20, 27, 30-32, 43-44): one closed
# instance's own theorem can depend on *another* closed instance's theorem
# (a caller passes a value whose own precision only improves once *its*
# entry theorem is applied -- M7.a's own "cascade" mechanism, reproduced
# directly in the frozen corpus: hex_pair depends on esc_bytes.bytes,
# scan_label/scan_alpha depend on domain_loop/tld_ok). CloseCallers below
# runs a small, bounded, monotone round loop over exactly the closed subset
# -- the same shape as hir::range::analyze's own already-existing
# caller-propagation fixpoint, applied to Kind facts instead of Range facts
# -- rather than reusing hir::specialize's own live Instance/Requeue
# machinery (which would risk exactly the new-instance/new-edge outcome the
# invariants above forbid). A zero-caller closed instance is simply never
# reanalyzed (Reanalyze is only ever called for instances ClosedCallerFacts
# found a fact for), so it never receives an arbitrary theorem (spec #32).

# ---------------------------------------------------------------------------
# InstanceClosed: the one authoritative closedness proof
# (EXACT-CALLABLE-CLOSED-CALLER.md)
#
# InstanceClosed(I) means: every invocation of codegen instance I that can
# happen at run time is accounted for in the analysis's own call graph, so
# facts derived from the callers the compiler knows (an entry-kind theorem,
# an entry Range, an exact-callable key) hold for every call that can occur.
#
# What it relies on, per kind of instance:
#
#   * the program      -- no callers at all.
#   * a SPECIALIZED instance (some key position is not `any`: a kind, an
#     exact callable, an aggregate shape) -- it is only ever *selected* by a
#     direct call (Handle -> Instance); nothing else can name a specific key.
#     A Block value's dynamic dispatch always enters the block's GENERIC
#     instance (a materialized Block "retains a generic entry").
#   * a GENERIC instance of a static (environment-free) block -- closed iff
#     the block's Block value is never materialized (hir::aot::
#     materializedBlocks over every used instance): the value is the only
#     route to an unknown caller.
#   * a GENERIC instance of a value-capturing closure -- closed iff
#     hir::blockescape proves every reference to the binding is an exact,
#     arity-matching call (its eligibility fixpoint, RefsAsCalls): the
#     closure is never a first-class value, so there is no unknown caller.
#     (aot's materializedBlocks counts *every* bind of a capturing closure as
#     materializing, which is why it cannot decide this branch.)
#
# Which analysis computes it: InstanceClosed itself, over the finished
# analysis. When it is stable: after the ordinary Fixpoint has converged --
# `calls`, `edges`, `values` and the used set are frozen from then on
# (CloseCallers writes only overlays and results), and blockescape reads
# only structure and those frozen maps. analyze therefore computes it once
# (ClosedInstances) and stores it under `closed` in its result; CloseCallers
# derives its own working copy from the identical call, at the identical
# frozen graph. Every consumer reads that one result: hir::range
# (OpenInstances), hir::construction, the audit output (closedAudit), and
# the public closed query.
#
# Instances it cannot prove closed: a generic instance whose Block value is
# materialized (a callable that escapes: stored, returned, put in a List,
# passed to code that is not an exact call); a closure blockescape declines
# (a reference that is not a call; a candidate it finds no call to at all);
# an instance whose callers the analysis never saw.
#
# Soundness of *exact callable identity* is a different question from
# closedness: an exact callable argument says which code a parameter holds
# at one call. That is a fact about the argument expression's type, and it
# keys a SPECIALIZED instance that is closed by construction. An exact
# callable that also escapes elsewhere does not make anything else closed.

# 1 if every runtime route by which instance ID could be invoked is
# accounted for in SNAPSHOT's own call graph (a `hir::specialize::analyze`
# return value) and BLOCKESCAPE's own eligibility analysis
# (`hir::blockescape::analyze $hir SNAPSHOT`) -- see the section header above
# for what makes each branch below sound. Only ever *needed* for a generic
# instance of a real block (the program is never open; a specialized
# instance's only possible callers are exactly the direct calls that
# selected it).
proc hir::specialize::InstanceClosed {snapshot blockescape id} {
    set instance [dict get $snapshot instances $id]
    if {[dict get $instance block] eq "program" || ![dict get $instance generic]} {
        return 1
    }
    set block [dict get $instance block]
    if {$block in [dict get [dict get $snapshot context] statics]} {
        return [expr {![dict exists [MaterializedBlocks $snapshot] $block]}]
    }
    return [hir::blockescape::wants $blockescape $id]
}

# InstanceId -> 1 for every used instance InstanceClosed proves closed
# (specialized instances and the program included): the authoritative
# result analyze stores under `closed`.
proc hir::specialize::ClosedInstances {hir analysis {blockescape ""}} {
    if {$blockescape eq ""} {
        set blockescape [hir::blockescape::analyze $hir $analysis]
    }
    set closed [dict create]
    foreach id [dict get $analysis used] {
        if {[InstanceClosed $analysis $blockescape $id]} {
            dict set closed $id 1
        }
    }
    return $closed
}

# BlockExprId -> 1, for every block whose Block value some used instance's
# reachable code materializes (hir::aot::materializedBlocks): the identical
# computation hir::range::OpenInstances used to make, kept here as the
# static-block branch of InstanceClosed.
proc hir::specialize::MaterializedBlocks {snapshot} {
    set materialized [dict create]
    foreach id [dict get $snapshot used] {
        foreach block [dict get [dict get $snapshot instances $id] values] {
            dict set materialized $block 1
        }
    }
    return $materialized
}

# ---------------------------------------------------------------------------
# Dormant instances (GENERIC-PREDICATE-PROOF-LOSS.md, loss point 2)
#
# A value-capturing closure's bind always materializes its Block value as far
# as hir::aot::materializedBlocks is concerned, so Analyze keeps an edge to
# the literal's generic instance from every instance that binds it, even when
# hir::blockescape de-closures the binding (`wants` some instance of the
# literal). That generic instance is then the entry of a Block value nobody
# ever calls dynamically: blockescape's proof (the one InstanceClosed's
# closure branch rests on) is that every reference to the binding is the
# callee of an exact call, so the value never reaches a dynamic call site.
# A Block value's only route into code is a call, so such an ENTRY runs only
# when an exact call selects it -- on any backend, whether or not native
# lowering builds the value (with -block-escape-opt 0 it does, and an exact
# call of the materialized closure still goes to the instance
# hir::specialize chose for that call site).
#
# DORMANT is the set of used instances not reachable from the program once
# an edge into an entry is followed only when it is a call of the source
# (a `calls` target of it): the entries no live code calls, and everything
# only they reach. Code that never runs makes no calls and creates no
# closures, so nothing a dormant instance does is evidence about anything
# else: hir::range, the closed-caller theorem and AOT readiness ignore them
# as sources. Following every call edge means the set never relies on
# blockescape's proof that the calls reach only specialized instances
# (where it does not hold -- a call that selected the generic instance --
# the instance is simply live); it relies only on the value never being
# called dynamically. Dormant instances stay in `used` (with their keys and
# edges): the used graph is what blockescape itself is computed from, and
# lowering still emits an entry's code when -block-escape-opt 0
# materializes the closure. Their own facts must hold whatever calls them:
# hir::range treats every dormant instance as open (no caller facts).
#
# Only computed after the ordinary Fixpoint, from the frozen graph and the
# blockescape result over it (see InstanceClosed's section).
proc hir::specialize::DormantInstances {snapshot blockescape} {
    variable dormantOpt
    if {!$dormantOpt} {
        return {}
    }
    set statics [dict get [dict get $snapshot context] statics]
    set used [dict get $snapshot used]
    set wantedBlocks [dict create]
    foreach id $used {
        if {[hir::blockescape::wants $blockescape $id]} {
            dict set wantedBlocks [dict get $snapshot instances $id block] 1
        }
    }
    set entries [dict create]
    foreach id $used {
        set instance [dict get $snapshot instances $id]
        set block [dict get $instance block]
        if {$block ne "program" && [dict get $instance generic] && $block ni $statics
                && [dict exists $wantedBlocks $block]} {
            dict set entries $id 1
        }
    }
    if {![dict size $entries]} {
        return {}
    }
    set live [dict create]
    set work [list [dict get $snapshot keys program]]
    while {$work ne ""} {
        set work [lassign $work id]
        if {[dict exists $live $id]} {
            continue
        }
        dict set live $id 1
        set instance [dict get $snapshot instances $id]
        set callees [dict values [dict get $instance calls]]
        foreach target [dict get $instance edges] {
            if {[dict exists $entries $target] && $target ni $callees} {
                continue
            }
            lappend work $target
        }
    }
    set dormant [dict create]
    foreach id $used {
        if {![dict exists $live $id]} {
            dict set dormant $id 1
        }
    }
    return $dormant
}

# InstanceId -> 1, for every used closed instance the closed-caller entry-kind
# theorem applies to: a generic instance, and a SPECIALIZED instance of a
# value-capturing closure whose key still has an `any` position (Handle's
# closure rule leaves every position of such a closure generic except an
# exact callable or an Int, so the theorem refines them exactly as it
# refines the generic instance's -- e.g. a String parameter next to an exact
# predicate in the key). An
# ordinary (static) block's specialized instance with an `any` position
# keeps it: there the callers genuinely pass nothing more precise, and the
# theorem would only re-run the inference with a less precise call-result
# handler (FrozenHandle) for no gain.
proc hir::specialize::ClosedSet {snapshot blockescape} {
    set closed [dict create]
    set statics [dict get [dict get $snapshot context] statics]
    foreach id [dict get $snapshot used] {
        set instance [dict get $snapshot instances $id]
        set block [dict get $instance block]
        if {$block eq "program"} {
            continue
        }
        set applies [dict get $instance generic]
        if {!$applies && $block ni $statics && [lsearch -exact [dict get $instance args] any] >= 0} {
            set applies 1
        }
        if {$applies && [InstanceClosed $snapshot $blockescape $id]} {
            dict set closed $id 1
        }
    }
    return $closed
}

# InstanceId -> one KeyType per parameter (the join of every exact caller's
# own argument kind, "any" where no closed instance in CLOSED is a call
# target, or where the callers themselves disagree): the closed-caller
# entry-kind theorem, collected fresh from SNAPSHOT's *current* overlays --
# so a caller that is itself a reanalyzed closed instance (a cascade)
# contributes its own, already-improved argument facts once CloseCallers'
# own round loop reaches it again. Only reachable calls count (spec #16/32:
# dead code proves nothing); only calls targeting a CLOSED instance are
# examined at all, so nothing here ever reads or joins a fact from an open/
# dynamic edge, because an open/dynamic edge is never routed through
# hir::specialize's own Handle in the first place (hir::types::Call only
# invokes the spec handler for an exact `{block B arity result}` callee --
# see hir/types.tcl's own Call).
#
# An argument that is nothing but an unchanged forward of the callee's own
# parameter to itself (a self or otherwise recursive call passing a
# parameter straight through, e.g. esc_bytes's own `esc_bytes(bytes, i + 1,
# ...)`) contributes no fact for that position -- exactly RefinementFacts'
# own exclusion (see its comment), and for the identical reason: such a
# reference's own type is circularly the very theorem this proc is
# computing, so joining its *current*, not-yet-improved type in would only
# ever poison the join down to "any" and never converge (confirmed directly
# against the frozen corpus: `bytes` never left "any" across every round
# without this exclusion, while `i`/`acc`, forwarded only via a native op
# with its own fixed result kind, were unaffected either way). Such a
# position is marked with the empty string, a "no contribution from this
# call" placeholder distinct from the real type atom "any" (a genuinely
# unknown-typed argument, e.g. a cascade still waiting on its own caller's
# theorem, which must still join as "any" -- CombineCallerTheorem treats
# both alike as "nothing to narrow with" only once every contributing call
# has been folded in).
#
# A DORMANT caller (DormantInstances) contributes nothing: it never runs.
proc hir::specialize::ClosedCallerFacts {hir snapshot closed {dormant {}}} {
    set facts [dict create]
    set exactCallable [expr {[dict exists $snapshot exactCallable] && [dict get $snapshot exactCallable]}]
    foreach callerId [dict get $snapshot used] {
        if {[dict exists $dormant $callerId]} {
            continue
        }
        set callerInstance [dict get $snapshot instances $callerId]
        set calls [dict get $callerInstance calls]
        if {![dict size $calls]} {
            continue
        }
        set reachable [dict get $callerInstance reachable]
        set view ""
        dict for {e target} $calls {
            if {![dict exists $closed $target] || $e ni $reachable} {
                continue
            }
            if {$view eq ""} {
                set view [view $hir $snapshot $callerId]
            }
            set params [dict get $view exprs [dict get $snapshot instances $target block] params]
            set contribution {}
            foreach a [dict get $view exprs $e args] p $params {
                set argNode [dict get $view exprs $a]
                if {[dict get $argNode kind] eq "ref" && [dict get $argNode binding] eq $p} {
                    lappend contribution ""
                } else {
                    set key [KeyType [hir::typeOf $view $a]]
                    if {!$exactCallable} {
                        set key [CoarseCallable $key]
                    }
                    lappend contribution $key
                }
            }
            if {![dict exists $facts $target]} {
                dict set facts $target $contribution
            } else {
                set merged {}
                foreach prev [dict get $facts $target] cur $contribution {
                    if {$prev eq ""} {
                        lappend merged $cur
                    } elseif {$cur eq ""} {
                        lappend merged $prev
                    } else {
                        lappend merged [JoinKey $prev $cur]
                    }
                }
                dict set facts $target $merged
            }
        }
    }
    return $facts
}

# Combines TYPE (the observed key, already possibly narrowed by the
# declared-parameter theorem -- see Reanalyze's own seeding order, which
# mirrors Analyze's) with FACT, one parameter's closed-caller join ("any" if
# no useful fact applies): conjunctively, exactly mirroring the M1/M7.b
# declared-theorem combination (M7B-CONJUNCTIVE-ENTRY-FACTS.md) a second
# time for a second, independently proven channel (M7C's own generalization
# of that milestone's specific-key invariant). Never erases TYPE; only ever
# narrows it further.
proc hir::specialize::CombineCallerTheorem {type fact} {
    if {$fact eq "any" || $fact eq ""} {
        return $type
    }
    if {![hir::types::IsSpecific $type]} {
        return [expr {[hir::types::IsSpecific $fact] ? $fact : [hir::types::narrow $type $fact]}]
    }
    if {([hir::types::IsList $type] && [hir::types::IsList $fact])
            || ([hir::types::IsSet $type] && [hir::types::IsSet $fact])} {
        return [hir::types::narrow $type $fact]
    }
    # TYPE is already a specific (aggregate/callable) fact whose constructor
    # does not match FACT's. Every legal caller of a sound program already
    # agrees on a parameter's own static kind (hir::range::
    # verifyDeclaredParams's admissibility proof, upstream of specialization
    # -- see this section's own header), so this is not expected to happen;
    # if it ever does, keep TYPE rather than risk combining incompatible
    # facts.
    return $type
}

# The handler Reanalyze's own hir::types::inferRegion pass uses in place of
# the ordinary Handle: identical for "create" (nothing here needs a fresh
# captured-binding seed -- Reanalyze never changes what a nested closure
# captures), but a call always resolves to CALLS' own pre-recorded target
# instead of calling Instance -- so this pass can only ever narrow facts
# inside instance ID's own region, never create a new instance or select a
# different one for a call it already made (see this section's own header,
# "Never creating a new instance or edge").
proc hir::specialize::FrozenHandle {calls op args} {
    variable state
    switch -- $op {
        call {
            lassign $args e block argTypes
            if {![dict exists $calls $e]} {
                return any
            }
            return [dict get $state instances [dict get $calls $e] result]
        }
        create {
            return
        }
    }
    error "hir::specialize: unknown handler operation \"$op\""
}

# Re-infers instance ID's region with its parameters additionally narrowed
# by the closed-caller entry-kind theorem ARGTYPES (one KeyType per
# parameter, positionally, "any" where no fact applies): a fresh overlay and
# result, with `calls`/`edges`/`values`/`creates` left exactly as the
# ordinary fixpoint already computed them. Mirrors Analyze's own seeding
# loop (M1/M7.b's declared-theorem combination, then CombineCallerTheorem,
# then RefineParams) so every existing downstream consumer of the overlay
# needs no change of its own. Returns 1 if the overlay or result actually
# changed.
proc hir::specialize::Reanalyze {id argTypes} {
    variable state
    set hir [dict get $state hir]
    set instance [dict get $state instances $id]
    set block [dict get $instance block]
    if {$block eq "program"} {
        return 0
    }

    set types [dict create]
    dict for {b type} [dict get $instance seeds] {
        dict set types $b $type
    }
    foreach b [dict get $hir exprs $block params] keyType [dict get $instance args] \
            declaredType [hir::signatures::entryTypes $hir $block] \
            callerFact $argTypes {
        set type $keyType
        if {$declaredType ne {}} {
            if {![hir::types::IsSpecific $type]} {
                set type [expr {[hir::types::IsSpecific $declaredType]
                    ? $declaredType : [hir::types::narrow $type $declaredType]}]
            } elseif {([hir::types::IsList $type] && [hir::types::IsList $declaredType])
                    || ([hir::types::IsSet $type] && [hir::types::IsSet $declaredType])} {
                set type [hir::types::narrow $type $declaredType]
            }
        }
        set type [CombineCallerTheorem $type $callerFact]
        dict set types $b $type
    }
    RefineParams $block types

    set scratch $hir
    set inferred [hir::types::inferRegion scratch $block $types \
        [list hir::specialize::FrozenHandle [dict get $instance calls]]]
    if {[dict get $hir exprs $block declaredResult] ne {}} {
        set inferred [dict get $hir exprs $block declaredResult]
    }
    # Widen, never overwrite (mirrors Analyze's own "result = lub(old,
    # inferred)"): a self-referential result (esc_from's own recursive
    # call) can only be as precise as the *previous* round's already-
    # published result, read back through FrozenHandle -- exactly the same
    # round-over-round settling the ordinary Fixpoint does for any self-
    # recursive instance. Overwriting instead of widening would let one
    # round's still-imprecise self-read regress a later round's already-
    # better result, and could defeat this proc's own "changed" check by
    # oscillating instead of converging.
    set oldResult [dict get $instance result]
    set inferred [hir::types::lub $oldResult $inferred]

    set overlay [dict create]
    set reachable {}
    foreach e [dict get $state context exprs $block] {
        set node [dict get $scratch exprs $e]
        set base [dict get $hir exprs $e]
        set known [expr {[dict exists $node known] ? [dict get $node known] : ""}]
        set target [InstanceTarget $scratch $node $base]
        if {[dict get $node type] ne [dict get $base type]
                || [dict get $node reachable] != [dict get $base reachable]
                || $known ne [expr {[dict exists $base known] ? [dict get $base known] : ""}]
                || $target ne ""} {
            dict set overlay $e [OverlayEntry [hir::typeOf $scratch $e] $known [dict get $node reachable] $target]
        }
        if {[dict get $node reachable]} {
            lappend reachable $e
        }
    }

    set changed [expr {$overlay ne [dict get $instance overlay] || $inferred ne $oldResult}]
    if {$changed} {
        dict set instance overlay $overlay
        dict set instance reachable $reachable
        dict set instance result $inferred
        dict set state instances $id $instance
    }
    return $changed
}

# Computes closedness and closed-caller entry-kind theorems for the current
# `state instances`/`used` set (post-Fixpoint: see this section's own header
# for why not earlier), and applies them via Reanalyze -- a small, bounded,
# monotone round loop exactly like hir::range::analyze's own caller-
# propagation fixpoint, needed because one closed instance's own theorem can
# depend on another's (cascades; see the header). Never touches `calls`,
# `edges`, `values`, `creates`, instance identity, or the `used` set itself.
#
# M7.c.1 (M7C1-CLOSECALLERS-CONVERGENCE-FENCE.md): this whole pass is
# transactional. A caller-derived fact one round settles can feed a *later*
# round's own facts (a cascade reads a still-earlier round's overlay), so a
# round loop stopped by exhausting its budget rather than by a complete
# stable round has no sound way to know which, if any, of its already-
# applied per-instance changes are individually safe to keep -- some may
# depend on a sibling's change the budget never let settle. The only
# obviously safe rule is to commit nothing at all in that case: BASELINE
# below is `state instances` exactly as the already-sound ordinary Fixpoint
# left it (this pass's every mutation -- confirmed by inspection, see the
# section header's own audit -- lands only in that one field, never in
# `queue`/`deps`/`refs`/`byBlock`/`seeds`/`current`/`building`/`analyses`,
# so restoring it alone is a complete rollback of the whole pass); Tcl's
# ordinary dict/value semantics mean capturing it with a plain assignment is
# already enough isolation -- later `dict set state instances ...` calls
# rebind `state`, they never mutate the value BASELINE still holds. On
# non-convergence CloseCallers restores exactly that value, discarding every
# overlay/result change this pass made, rather than keeping the current
# (possibly partially-ascended) state, poisoning only `result`, or trying to
# salvage whichever instances "look" converged: a partial round's cross-
# instance dependencies make any of those unsound in general (see the
# report's own "Why result = any alone is insufficient").
proc hir::specialize::CloseCallers {} {
    variable state
    variable passLimit
    variable closeCallersRoundLimit
    variable closeCallersConverged
    set roundLimit [expr {$closeCallersRoundLimit ne "" ? $closeCallersRoundLimit : $passLimit}]
    set hir [dict get $state hir]
    set baseline [dict get $state instances]
    set snapshot [dict create specialize 1 instances $baseline \
        keys [dict get $state keys] used [Used] context [dict get $state context] \
        exactCallable [dict get $state exactCallableOpt]]
    set be [hir::blockescape::analyze $hir $snapshot]
    dict set state blockescape $be
    set closed [ClosedSet $snapshot $be]
    set dormant [DormantInstances $snapshot $be]
    if {![dict size $closed]} {
        set closeCallersConverged 1
        return
    }
    # Only an instance ClosedCallerFacts will actually reanalyze at all
    # (i.e. some used instance's `calls` targets it) is safe to reset below:
    # `calls`/edges are frozen by this whole pass (see the file header), so
    # this set of targets is identical in every round -- computing it once,
    # ahead of the round loop, is exactly the round-1 computation, not a
    # separate query.
    set facts [ClosedCallerFacts $hir $snapshot $closed $dormant]
    # A closed instance may already carry a `result` the ordinary Fixpoint
    # pinned to "any" only because it exhausted its own passLimit while
    # every entry fact was still "any" (Analyze's own non-convergence
    # safety valve, hir/specialize.tcl's own Fixpoint header) -- e.g.
    # esc_from's self-recursive result, unrecoverable there because lub's
    # own top absorbs ("any" joined with anything stays "any" forever), but
    # perfectly recoverable here now that entry facts are far better.
    # Resetting to `never` (the same bottom Instance itself starts every
    # instance at) and re-settling through this proc's own bounded,
    # monotone round loop reaches the identical least fixpoint a correctly-
    # converged Fixpoint would have, never a smaller (unsound) one, by the
    # same monotone-lattice argument the ordinary Fixpoint itself relies on.
    # An instance with no entry here (no exact caller at all, e.g. the dead-
    # `fnvalue` residuals -- spec item 106's own "other" category) is never
    # reanalyzed by this pass at all, so its `result` must not be reset:
    # doing so would leave it wrongly pinned at `never` forever. This reset
    # is itself part of the transaction (a mutation of `state`, made after
    # BASELINE was already captured above), so a rollback below undoes it
    # exactly as it undoes every later round's own change.
    dict for {id argTypes} $facts {
        dict set state instances $id result never
    }
    dict set snapshot instances [dict get $state instances]
    set converged 0
    for {set round 1} {$round <= $roundLimit} {incr round} {
        if {$round > 1} {
            set facts [ClosedCallerFacts $hir $snapshot $closed $dormant]
        }
        set changed 0
        dict for {id argTypes} $facts {
            if {[Reanalyze $id $argTypes]} {
                set changed 1
                dict set snapshot instances $id [dict get $state instances $id]
            }
        }
        if {!$changed} {
            # A complete round changed nothing: every relevant piece of
            # state (Reanalyze's own "changed" test already covers overlay
            # and result -- the only two fields this pass ever writes, see
            # the section header) is stable, so the candidate is a genuine
            # fixpoint under the current entry facts, not merely a pass
            # that ran out of rounds. Convergence, per this milestone's own
            # off-by-one rule, does not require using every permitted round.
            set converged 1
            break
        }
    }
    set closeCallersConverged $converged
    if {!$converged} {
        # The round budget was exhausted while a complete round still
        # changed state: no fixpoint was proven, so the whole candidate --
        # not just `result`, not just the instances that individually
        # stopped changing -- is discarded. Restoring BASELINE returns
        # exactly the already-sound pre-CloseCallers snapshot: legal
        # programs still compile and run correctly under it, identically to
        # -closed-caller-facts-opt 0, because that snapshot is exactly what
        # this optimization is optional on top of.
        dict set state instances $baseline
    }
}

# ---------------------------------------------------------------------------
# M7.c: public closedness/theorem queries (spec items 60-62), for tests and
# audit tooling that need to assert `closed`/the theorem directly rather
# than only infer success from a disappeared guard. Both recompute
# hir::blockescape::analyze (cheap, deterministic, a pure function of HIR
# and ANALYSIS) rather than requiring every caller of hir::specialize::
# analyze to also thread a blockescape analysis through -- the same
# analysis CloseCallers already ran internally, exposed here for inspection
# rather than cached, so a caller can ask about ANALYSIS's own instances
# (specialize 1) at any time after analyze returns, not only during
# CloseCallers' own internal pass.

# 1 if ANALYSIS (a hir::specialize::analyze return value) proves instance ID
# closed -- see InstanceClosed's own header for the exact proof per branch.
proc hir::specialize::closed {hir analysis id} {
    if {[dict exists $analysis closed]} {
        return [dict exists $analysis closed $id]
    }
    return [InstanceClosed $analysis [hir::blockescape::analyze $hir $analysis] $id]
}

# The dormant set of ANALYSIS (see DormantInstances): the one analyze
# stored, or derived from BLOCKESCAPE for a hand-built analysis without it.
proc hir::specialize::DormantOf {analysis blockescape} {
    if {[dict exists $analysis dormant]} {
        return [dict get $analysis dormant]
    }
    return [DormantInstances $analysis $blockescape]
}

# 1 if instance ID of ANALYSIS is dormant: never entered at run time, kept
# in `used` but no evidence for anything else (DormantInstances).
proc hir::specialize::dormant {hir analysis id} {
    if {[dict exists $analysis dormant]} {
        return [dict exists $analysis dormant $id]
    }
    return [dict exists [DormantInstances $analysis [hir::blockescape::analyze $hir $analysis]] $id]
}

# Audit-only: one line per used instance (never user-facing) stating the
# authoritative closedness answer and what it rests on: instance, closed
# yes/no with the proof branch, how many exact call sites target it, and the
# exact callable target(s) in its key, and whether it is dormant. hir::range
# treats an instance as open exactly when it is not closed or is dormant: the
# `range-open` column is that consumer's own answer.
proc hir::specialize::closedAudit {hir analysis} {
    set be [hir::blockescape::analyze $hir $analysis]
    set callers [dict create]
    foreach id [dict get $analysis used] {
        foreach target [lsort -unique [dict values [dict get $analysis instances $id calls]]] {
            dict incr callers $target
        }
    }
    set open [hir::range::OpenInstances $analysis $hir]
    set dormant [DormantOf $analysis $be]
    set lines {}
    foreach id [dict get $analysis used] {
        set instance [dict get $analysis instances $id]
        set block [dict get $instance block]
        if {$block eq "program"} {
            continue
        }
        set closed [InstanceClosed $analysis $be $id]
        if {![dict get $instance generic]} {
            set why "specialized: selected only by exact calls"
        } elseif {$block in [dict get $analysis context statics]} {
            set why [expr {$closed ? "static block, never materialized" : "static block, Block value materialized"}]
        } elseif {$closed} {
            set why "closure, blockescape: every reference is an exact call"
        } else {
            # A generic instance of a closure blockescape does de-closure-
            # convert (through its other, specialized instances) is the Block
            # value's entry: never entered at run time, and not itself part
            # of the proof, so it stays open; it is dormant (DormantInstances),
            # so its own calls are no evidence for anything else.
            set sibling 0
            foreach other [dict get $analysis used] {
                if {$other ne $id && [dict get $analysis instances $other block] eq $block
                        && [hir::blockescape::wants $be $other]} {
                    set sibling 1
                }
            }
            set why [expr {$sibling
                ? "closure de-closure-converted via its specialized instances; this generic Block-value entry is never entered"
                : "closure, blockescape declined (its Block value may exist: stored, returned or passed)"}]
        }
        set exact [lmap k [dict get $instance args] {
            if {![IsExactCallableKey $k]} continue
            ShowKey $k
        }]
        lappend lines [format "%-8s %-40s closed=%d range-open=%d callers=%d exact=\[%s\] dormant=%d  (%s)" \
            $id [label $analysis $id] $closed [dict exists $open $id] \
            [expr {[dict exists $callers $id] ? [dict get $callers $id] : 0}] [join $exact {, }] \
            [dict exists $dormant $id] $why]
    }
    return [join $lines \n]
}

# The closed-caller entry-kind theorem (one KeyType per parameter, "any"
# where no useful fact applies) ANALYSIS's own closed-caller pass would
# derive for instance ID -- "" (not a list) if ID is not closed at all, so a
# test can distinguish "closed but every caller position was any/absent"
# from "not closed, no theorem is even attempted".
proc hir::specialize::closedCallerTheorem {hir analysis id} {
    set be [hir::blockescape::analyze $hir $analysis]
    set closed [ClosedSet $analysis $be]
    if {![dict exists $closed $id]} {
        return ""
    }
    set facts [ClosedCallerFacts $hir $analysis $closed [DormantOf $analysis $be]]
    if {![dict exists $facts $id]} {
        return [lrepeat [llength [dict get $analysis instances $id args]] any]
    }
    return [lmap t [dict get $facts $id] {expr {$t eq "" ? "any" : $t}}]
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
        lassign $entry type known reachable target
        dict set hir exprs $e type [hir::types::intern hir $type]
        dict set hir exprs $e reachable $reachable
        if {$known ne "" || [dict exists $hir exprs $e known]} {
            dict set hir exprs $e known $known
        }
        if {$target ne ""} {
            # A call through a parameter this instance's key names an exact
            # callable for: the view says what the semantic HIR cannot, that
            # the call has a known target.
            lassign $target targetKind targetValue
            if {$targetKind eq "native"} {
                set targetValue [hir::resolve::nativeSymbol hir $targetValue]
            }
            dict set hir exprs $e target [list $targetKind $targetValue]
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
    return "$name<[join [lmap t [dict get $instance args] {ShowKey $t}] {, }]>"
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
