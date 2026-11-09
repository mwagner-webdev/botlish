# semantic.tcl -- opportunistic semantic function instances
# (OPPORTUNISTIC-SEMANTIC-INSTANCES.md).
#
# Botlish has no user-facing generic functions, and this file adds none: no
# type variable, no `fn f[T]`, no `where`. An ordinary function such as
#
#     fn identity(x):
#         x
#
# keeps its one source contract (x : any, result : any). What this file adds
# is a *compiler-internal* analysis layer: when a call's target block is
# statically known (hir::types::Call's exact `{block E ...}` callee) and the
# call's argument types say more than the block's own generic entry types, the
# block's ordinary body is analyzed once more under those concrete entry types
# -- the same hir::types walk, refinements, flow facts, reachability and
# nested-closure typing every function body gets -- and the call is typed with
# the result that analysis proves:
#
#     identity(m)        m : MutableArray[str]
#                        x : MutableArray[str], result : MutableArray[str]
#
# The relation "parameter type == result type" is never written down anywhere:
# it falls out because the body returns x and x had a concrete type.
#
# Vocabulary (kept apart on purpose)
# ----------------------------------
#   source function   the one function the programmer wrote: a block expression
#   semantic instance a compiler-internal analysis of that function under one
#                     concrete semantic entry environment (this file)
#   codegen instance  an emitted lowered/native function body
#                     (hir/specialize.tcl's instances, native/lower.tcl)
#   specialization key  hir::specialize::KeyType, the representation-oriented
#                     grouping codegen instances are shared by
#
# A semantic instance is NOT a codegen specialization. Nothing here emits
# code, clones HIR, changes a block's contract, or creates a specialize.tcl
# instance; several semantic instances routinely lower through one codegen
# instance (`identity<MutableArray[str]>` and `identity<MutableArray[int]>`
# run the same generic code: KeyType(MutableArray[T]) is still `mutarray`), and
# an inlined call has no codegen identity at all. Nothing in this file
# changes hir::specialize::KeyType. (EXACT-CALLABLE-CLOSED-CALLER.md later
# changed KeyType itself, deliberately and in one place: an exact callable
# argument keeps its identity in the codegen key because that identity
# decides direct versus indirect lowering. That is a statement about
# representation, not a relaxation of the separation above: every other
# exact semantic fact -- an exact scalar value, an exact List element, a
# contract -- still stays out of the key.)
#
# The key
# -------
# A semantic instance is {BLOCK ENTRY-TYPES}: the block's ExprId and one FULL
# semantic type per parameter -- MutableArray[str] is not MutableArray[int],
# List[str] is not List[int], Fn{args:[str],...} is not Fn{args:[int],...}, an
# exact callable stays `{block E ...}`; nothing is projected to a runtime kind.
# ENTRY-TYPES[i] is
#
#   * the argument's static type, for a parameter without a declared or
#     trusted-inferred contract (hir::signatures::entryTypes), and
#   * for a parameter WITH one, the argument type if it is a subtype of the
#     contract (a Dog for an Animal parameter), else the contract itself.
#     A declared parameter type stays the definition's contract: the body is
#     always valid for it (and was already analyzed for it), and the narrower
#     argument fact may only add precision -- it can never rescue a body that
#     is invalid for the declared type. A contract that holds a
#     MutableVector or a MutableArray is kept as it is: the parameter is a
#     place the body may store into at its declared element type
#     (MUTABLE-VECTOR.md, MUTABLE-ARRAY.md).
#
# Exact scalar values are not in the key (`0` and `1` are both `int`); only
# types are. A request whose entry types equal the block's own generic entry
# types would re-run the generic analysis, so it is not an instance ("trivial",
# counted separately).
#
# Captures
# --------
# A block's body also depends on the types of the bindings it captures, and an
# exact block type names a code target, not a closure environment: the same
# block expression is created once per activation of its enclosing function.
# The chosen model, and why it is sound: the entry environment of a block's
# instance is the environment its GENERIC analysis recorded where the block is
# created (RecordEnv: the type of each captured binding in the creating walk).
# The generic analysis of the enclosing function is valid for every activation
# of it, so every closure of that block ever created captures values whose
# types are subtypes of the recorded ones; an instance analyzed under the
# recorded types is therefore sound for every closure of the block, and the
# key needs no capture component (it is a function of the block). Module-static
# references are typed once for the whole program (hir::types::BindingType),
# never per activation. A block created inside an enclosing *instance's* walk
# is typed in place, with that instance's more precise environment, as part of
# the enclosing instance's region: its body is verified with the enclosing
# instance (Region, verify), so an invalid use of a captured typed value there
# is found. A call to such a block still requests an instance of it under the
# recorded (generic) environment -- sound, only less precise about captures --
# and the call keeps whichever result is more precise (Refines: the in-place
# result is the fallback). A block with captures whose creating walk has not
# run yet has no recorded environment in this pass: the request is declined
# ("no-env") and hir::types::infer re-runs the walk once the environments are
# known (every pass is sound, later ones are more precise). Definition order
# cannot cause this -- a call always follows the binding, and the binding's
# own walk, of the function it calls (hir/resolve.tcl) -- but a recursive
# function can: a call of itself, answerable at once because its result type
# is declared, requests an instance of the function whose body creates a
# nested closure that the enclosing generic walk has not reached yet.
#
# Demand, caching, recursion
# --------------------------
# Instances are demand-driven: only an exact, reachable call in the program (or
# in an already existing instance's body) whose entry types are non-trivial
# requests one; identical canonical keys are one instance (the cache); there is
# no enumeration of type combinations. An instance being analyzed that is
# requested again (self recursion, mutual recursion) answers with its current
# result, initially `never` -- the same optimistic assumption hir::types::Block
# already uses for recursive functions -- and instances that read an answer
# that later grows are analyzed again (a deterministic worklist: dependents in
# discovery order), the way hir/specialize.tcl's result fixpoint works. Results
# only grow (lub) in the finite lattice of hir::types (aggregate nesting is
# bounded), with a pass limit as a guard.
#
# Budgets (SEMANTIC-INSTANCE-SCALABILITY-MILESTONE-1.md)
# -------
# Whether a program is valid must not depend on how many unrelated types have
# instantiated a helper, so no request is ever declined for a budget: a call
# whose instance is not analyzed would keep its generic result, which a typed
# use rejects as a TYPE error the program did not commit (the per-function
# budget of 16 instances did exactly that, at the 17th distinct type). What
# bounds the analysis instead:
#
#   * the key space is finite: an entry type is a type of the finite lattice
#     of hir::types (aggregate nesting is bounded, appliedDepth for
#     applications; minted List lengths are forgotten, ForgetInferred), so a
#     function has finitely many instances, and type-changing recursion
#     (wrap([x], n - 1)) reaches `any` at the aggregate bound;
#   * an instance's result only grows (lub), with passLimit as a widening:
#     past it a still-growing result is `any` -- a function of the instance
#     alone, never of other requests;
#   * nesting: a request made with maxDepth analyses in progress (or Tcl's
#     stack near levelLimit) is deferred to the worklist (Defer), which
#     analyzes it once they return; it costs walks, never precision, and does
#     not depend on which request came first;
#   * the worklist's length (Drain) and the number of instances
#     (maxInstances) are the resource guards left: reaching either fails the
#     compilation with HIR SEMANTIC LIMIT, naming the function and the chain
#     of instances being analyzed (Exhausted). A compiler failure, never a
#     TYPE error of the program and never a fallback that could accept an
#     erasure.
#
# The one request still declined is a closure's whose creation environment
# no walk has recorded yet (no-env, "Captures"), which a later walk of the
# program serves. A declined call gives its parameters no instance context, so
# hir::callables still rejects a bearing argument (a MutableArray[T], a typed
# callable) that would cross an untyped parameter -- a decline never accepts
# an erasure. A real type error found in an instance is never turned into a
# fallback.
#
# Validity
# --------
# Analysis (Walk) and verification are separate. Walk types the body under the
# entry environment, in the program's HIR in place ("Region-local walks"),
# and yields the result; each instance's final walk is snapshotted (the
# volatile per-expression facts of its region, not a HIR clone). verify then
# runs, on the HIR carrying that snapshot (applied in place and taken back),
# the same checks every function body gets for its own definition: the typed-call
# admissibility proofs and MutableArray store/copy rules
# (hir::range::verifyBlocks) and the bearing/non-erasure audit
# (hir::callables::verifyBlocks). A diagnostic there means "this function is
# invalid for this call": it is reported at the CALL that needed the instance
# (status invalid); the source function is not rejected and other calls are
# unaffected. A diagnostic in code the instance proves unreachable (an arm its
# types decide against, the body of a loop over an empty domain) is not one:
# the call never runs that code, whose typing describes values that cannot
# exist (a loop element of type `never`); the definition's own verification
# still checks it as written. A call to an invalid instance from inside
# another instance makes that one invalid too. Explicit parameter declarations and intrinsic
# contracts (hir/signatures.tcl) are not changed by any of this: contracts are
# still derived from declaration + body alone, and hir::moduleSignatures never
# reports an instance.
#
# Status: (deferred ->) analyzing -> analyzed; then verify: valid | invalid. A
# request that is not instantiated is `declined` with its reason, no-env.

namespace eval hir::semantic {
    # 0 disables the whole layer (measurement and tests only).
    variable enabled 1
    # The one budget (header, "Budgets"): reaching it fails the compilation
    # (HIR SEMANTIC LIMIT). There is no per-function budget.
    variable maxInstances 2000
    # Nested analyses: a request deeper is deferred to the worklist, never
    # declined (Defer).
    variable maxDepth 24
    variable passLimit 6
    # hir::types::infer re-runs the walk (once the creation environments of
    # blocks a first pass had to decline are known) at most this many times.
    variable maxRounds 3
    variable levelLimit 700
    # Run state (empty outside hir::types::infer).
    variable state {}
    # Per-expression facts a walk writes (hir/types.tcl); the ones that are
    # TypeIds are stored as type forms.
    variable fields {type reachable target known calleeErrors handlerTypes refinements resultType inferredResultType traitCall}
    variable typeFields {type resultType inferredResultType}
}

# ---------------------------------------------------------------------------
# Run lifecycle (hir::types::infer)

proc hir::semantic::Enabled {} {
    variable enabled
    return $enabled
}

proc hir::semantic::Begin {envs} {
    variable state
    set state [dict create envs $envs pendingEnv {} instances {} keys {} byBlock {} \
        calls {} declined {} stack {} queue {} deps {} txns {} next 0 regions {} \
        regionScopes {} scopeKids "" instsOf {} \
        requests 0 trivial 0 hits 0 walks 0 deferred 0 declinedCount {}]
}

# Ends the run: the state a HIR keeps as its `semantic` field (instances,
# keys, calls, census counters, the creation environments) plus `used` (the
# instances reachable from the program's own calls).
proc hir::semantic::End {} {
    variable state
    set s $state
    set state {}
    set used {}
    set work {}
    dict for {key id} [dict get $s calls] {
        if {[lindex $key 0] eq "generic" && $id ni $used} {
            lappend used $id
            lappend work $id
        }
    }
    while {$work ne {}} {
        set x [lindex $work 0]
        set work [lrange $work 1 end]
        dict for {key id} [dict get $s calls] {
            if {[lindex $key 0] eq $x && $id ni $used} {
                lappend used $id
                lappend work $id
            }
        }
    }
    dict set s used [lsort -dictionary $used]
    foreach id $used {
        if {[dict get $s instances $id status] ne "analyzed"} {
            # (Every request that defers an instance drains the worklist
            # before it returns: Call.)
            error "hir::semantic: instance $id was never analyzed"
        }
    }
    foreach key {stack queue txns regions regionScopes scopeKids} {
        dict unset s $key
    }
    return $s
}

# Ends the run in progress without a result (a walk that failed).
proc hir::semantic::Abandon {} {
    variable state
    set state {}
}

# The record {block B args ENTRY ...} of instance ID of the run in progress,
# or "" (no run, or no such instance): which function and entry types a walk
# with typing context `inst ID` is analyzing (hir::coroutines::
# SpecializedNode).
proc hir::semantic::Instance {id} {
    variable state
    if {$state eq "" || ![dict exists $state instances $id]} {
        return ""
    }
    return [dict get $state instances $id]
}

# 1 if a run is in progress.
proc hir::semantic::Active {} {
    variable state
    return [expr {$state ne ""}]
}

# 1 if the last run declined a request only for want of a creation
# environment that it has since learned (worth a second walk).
proc hir::semantic::WantsRerun {snapshot} {
    dict for {block _} [dict get $snapshot pendingEnv] {
        if {[dict exists $snapshot envs $block]} {
            return 1
        }
    }
    return 0
}

# Records, for the generic walk of block E (created in context OUTER of
# HIR), the type of each captured binding at creation: the entry
# environment every instance of E is analyzed under (header, "Captures").
proc hir::semantic::RecordEnv {hir outer e self selfType} {
    variable state
    if {$state eq "" || [dict exists $outer inst] || [dict exists $outer spec]} {
        return
    }
    set env [dict create]
    foreach b [dict get $hir exprs $e captures] {
        dict set env $b [if {$b eq $self} {set selfType} else {hir::types::BindingType $hir $outer $b}]
    }
    if {[dict exists $state envs $e] && [dict get $state envs $e] ne $env && [dict exists $state instsOf $e]} {
        # The creation environment changed (a later attempt of an enclosing
        # recursive function typed a captured binding differently: an earlier
        # attempt may have been optimistic): every instance analyzed under
        # the old one is re-analyzed, and so are their readers.
        foreach id [dict get $state instsOf $e] {
            dict set state instances $id env $env
            Requeue $id
        }
    }
    dict set state envs $e $env
}

# ---------------------------------------------------------------------------
# Requests

# The result type of the exact call E of BLOCK with ARGTYPES seen by
# context CTX of the HIR in variable HIRVAR (the generic walk's, which an
# instance's walk types in place: "Region-local walks"): BLOCKRESULT (the
# call's ordinary generic result) unless a semantic instance proves a more
# precise one. Records the call -> instance edge that hir::callables and
# hir::range::VerifyCall consult.
proc hir::semantic::Call {hirVar ctx e block argTypes blockResult} {
    upvar 1 $hirVar hir
    variable state
    variable enabled
    variable maxInstances
    variable maxDepth
    variable levelLimit
    if {!$enabled || $state eq "" || ($blockResult eq "never" && ![hir::traits::IsPolymorphic $hir $block]
            && ![hir::types::AnyAffine $argTypes])} {
        # (A call that gives an affine argument always gets its instance,
        # like a trait-polymorphic one: it decides the call's specialization,
        # AFFINE-VALUES.md.)
        return $blockResult
    }
    set node [dict get $hir exprs $block]
    set params [dict get $node params]
    if {[llength $params] != [llength $argTypes] || $block in {program}} {
        return $blockResult
    }
    dict incr state requests
    # Entry types (header, "The key").
    set declared [hir::signatures::entryTypes $hir $block]
    set entry {}
    set trivial 1
    set index 0
    foreach t $argTypes d $declared {
        # A List length a caller's argument happens to have selects no
        # instance: a fact inference minted crosses a function boundary
        # only as a declared contract (hir::types::ForgetInferred,
        # LIST-CARDINALITY-REFINEMENTS.md), so calls with Lists of three and
        # of four elements share one instance.
        set t [hir::types::ForgetInferred $t]
        if {$d ne {} && [hir::types::IsTraitConstraint $d]} {
            # A trait-typed parameter (TRAITS.md): the instance is entered
            # with the argument's view -- its hidden witness is the instance's
            # key component, so two witnesses are two instances.
            set x [hir::traits::EntryView $t $d]
            set generic [hir::traits::AbstractView $d $block $index]
        } elseif {$d ne {}} {
            if {[hir::types::subtype $t $d] && ![hir::types::MentionsMutable $d]} {
                set x $t
            } else {
                set x $d
            }
            if {[hir::signatures::inferredTrusted $hir $block $index]
                    && [hir::signatures::CallableAdmits $t $d]} {
                # A coroutine handle supplied for an untyped parameter the
                # body calls (AFFINE-VALUES.md): its inferred contract is a
                # callable contract, and the instance runs with the handle's
                # own type, of its own callable kind.
                set x $t
            }
            set generic $d
        } else {
            # A view passed where nothing is declared is only its concrete
            # value: no trait view crosses an untyped boundary (TRAITS.md,
            # "any").
            if {[hir::types::IsTrait $t]} {
                set x "any"
            } else {
                set x $t
            }
            set generic any
        }
        incr index
        if {$x ne $generic} {
            set trivial 0
        }
        lappend entry $x
    }
    if {$trivial} {
        dict incr state trivial
        return $blockResult
    }
    set key [list $block $entry]
    set caller [dict getdef $ctx inst "generic"]
    if {$caller eq "generic" && [dict get $state queue] ne {} && [dict get $state stack] eq {}} {
        # Instances whose environment changed since the last request are
        # settled before this walk reads any answer.
        Drain hir
    }
    set callKey [list $caller $e]
    if {[dict exists $state keys $key]} {
        dict incr state hits
        set id [dict get $state keys $key]
    } else {
        set reason [Declined $hir $block]
        if {$reason ne ""} {
            # (Only for want of a creation environment, which a later walk
            # of the program records: never a budget.)
            dict set state declined $callKey $reason
            Bump declinedCount $reason
            dict set state pendingEnv $block 1
            return $blockResult
        }
        if {[dict size [dict get $state instances]] >= $maxInstances} {
            # The one resource guard left: a compiler failure, never a
            # fallback a typed use could turn into a TYPE error (header,
            # "Budgets").
            Exhausted $hir $block $entry
        }
        set id [Create $block $entry $key]
        if {[dict get $state stack] eq {}} {
            Analyze hir $id
            Drain hir
        } elseif {[llength [dict get $state stack]] >= $maxDepth || [info level] > $levelLimit} {
            # Deep enough: analyzed by the worklist once the analyses in
            # progress return (Defer), never declined.
            Defer $id
        } else {
            Nested hir $id
        }
    }
    dict set state calls $callKey $id
    if {$caller ne "generic"} {
        dict set state deps $id $caller 1
        if {[dict get $state instances $id status] in {analyzing deferred}} {
            # The caller read an answer that is still being computed (a
            # recursive or deferred request): its own result is an
            # assumption until the fixpoint settles.
            dict set state instances $caller assumes 1
        }
    }
    set result [dict get $state instances $id result]
    if {[dict get $node declaredResult] eq {}} {
        # (An undeclared result forgets what inference minted, as the
        # generic one does: hir::types::Block.)
        set result [hir::types::ForgetInferred $result]
    }
    # The generic result is sound for every argument: an instance result that
    # is not at least as precise never replaces it.
    if {![Refines $result $blockResult]} {
        return $blockResult
    }
    return $result
}

# Fails the compilation: a new instance of BLOCK under ENTRY is needed, and
# maxInstances exist already. The resource guard's report names the
# function, its entry types and the chain of instances being analyzed when
# the request was made (header, "Budgets"): never a TYPE error at a later
# use of the generic result the call would otherwise have kept.
proc hir::semantic::Exhausted {hir block entry} {
    variable state
    variable maxInstances
    set chain [lmap id [lreverse [dict get $state stack]] {
        set inst [dict get $state instances $id]
        format {%s (%s)} [Named $hir [dict get $inst block]] [EntryText $hir [dict get $inst block] [dict get $inst args]]
    }]
    set text [format {%s (%s)} [Named $hir $block] [EntryText $hir $block $entry]]
    if {$chain ne {}} {
        append text ", requested while analyzing [join $chain {, called from }]"
    }
    throw {HIR SEMANTIC LIMIT} "hir::semantic: the semantic-instance limit was reached: $maxInstances instances were analyzed, and a call needs another one: $text; the compiler does not fall back to the untyped analysis, which could reject a valid program (declare the parameter types of a function called with very many argument types)"
}

# The source name of function BLOCK, or `function eN`.
proc hir::semantic::Named {hir block} {
    set name [CallableName $hir $block]
    if {$name eq ""} {
        return "function $block"
    }
    return $name
}

# "x : MutableArray[str], y : int": BLOCK's parameters at ENTRY.
proc hir::semantic::EntryText {hir block entry} {
    return [join [lmap b [dict get $hir exprs $block params] t $entry {
        format {%s : %s} [SourceName $hir $b] [ShowType $hir $t]
    }] {, }]
}

# 1 if call E, typed in CTX, is answered by an instance whose result is
# poison (Walk): never, because its every normal completion is a value the
# instance's analysis proved invalid -- reported at the call that made the
# instance (verify), never a divergence of the call.
proc hir::semantic::PoisonedCall {ctx e} {
    variable state
    if {$state eq ""} {
        return 0
    }
    set callKey [list [dict getdef $ctx inst "generic"] $e]
    if {![dict exists $state calls $callKey]} {
        return 0
    }
    set id [dict get $state calls $callKey]
    return [expr {[dict exists $state instances $id poisoned]
        && [dict get $state instances $id result] eq "never"}]
}

# 1 if instance result TYPE is at least as precise as the generic result
# GENERIC: a subtype of it; the same exact callable whose own result is (a
# closure created inside the instance carries the result its in-place typing
# proved); or one that differs only by carrying MutableArray element
# contracts GENERIC has erased (a MutableArray[T] is not a subtype of the raw
# kind -- that would be the erasure -- but it describes the same runtime
# values with strictly more contract).
proc hir::semantic::Refines {type generic} {
    if {[hir::types::subtype $type $generic]} {
        return 1
    }
    if {[hir::types::IsExactBlock $type] && [hir::types::IsExactBlock $generic]
            && [lrange $type 1 2] eq [lrange $generic 1 2]} {
        return [Refines [lindex $type 3] [lindex $generic 3]]
    }
    return [hir::types::subtype [EraseArrays $type] [EraseArrays $generic]]
}

# TYPE with every MutableArray[T] contract replaced by the raw kind.
proc hir::semantic::EraseArrays {type} {
    if {[hir::types::IsRefinedApplied $type]} {
        return [hir::types::Refine [EraseArrays [hir::refinements::Base $type]] \
            [hir::refinements::Family $type] [hir::refinements::Facts $type]]
    }
    if {[hir::types::IsMutArray $type]} {
        return mutarray
    }
    if {[hir::types::IsList $type] && [llength $type] == 2} {
        return [hir::types::MakeList [EraseArrays [lindex $type 1]]]
    }
    if {[hir::types::IsSet $type]} {
        return [hir::types::MakeSet [EraseArrays [lindex $type 1]] 0]
    }
    return $type
}

# Why block BLOCK cannot be instantiated now ("" if it can).
proc hir::semantic::Declined {hir block} {
    variable state
    set captures [dict get $hir exprs $block captures]
    if {$captures ne {} && ![dict exists $state envs $block]} {
        return no-env
    }
    return ""
}

proc hir::semantic::Create {block entry key} {
    variable state
    set id s[dict get $state next]
    dict incr state next
    set env {}
    if {[dict exists $state envs $block]} {
        set env [dict get $state envs $block]
    }
    dict set state instances $id [dict create id $id block $block args $entry key $key \
        env $env status analyzing result never outward never passes 0 dirty 0 assumes 0 snapshot {}]
    dict set state keys $key $id
    Bump byBlock $block
    dict lappend state instsOf $block $id
    return $id
}

# Increments counter FIELD (or its entry KEY) of the run state.
proc hir::semantic::Bump {field {key ""}} {
    variable state
    if {$key eq ""} {
        dict set state $field [expr {[dict get $state $field] + 1}]
    } elseif {[dict exists $state $field $key]} {
        dict set state $field $key [expr {[dict get $state $field $key] + 1}]
    } else {
        dict set state $field $key 1
    }
}

# Analyzes instance ID to its fixpoint, walking it on the HIR in variable
# HIRVAR (Walk). Self recursion re-walks until the result stops growing; a
# change that other analyzing instances already read marks them dirty, one
# that finished instances read queues them.
proc hir::semantic::Analyze {hirVar id} {
    upvar 1 $hirVar hir
    variable state
    variable passLimit
    dict lappend state stack $id
    if {[dict get $state instances $id status] eq "deferred"} {
        # (Its first analysis, as a fresh instance's: Create.)
        dict set state instances $id status analyzing
    }
    try {
        set passes 0
        while 1 {
            incr passes
            dict set state instances $id dirty 0
            dict set state instances $id assumes 0
            lassign [Walk hir $id] walked snapshot outward
            dict incr state walks
            dict set state instances $id outward \
                [hir::types::lub [dict get $state instances $id outward] $outward]
            set old [dict get $state instances $id result]
            set new [hir::types::lub $old $walked]
            if {$new ne $old && $passes >= $passLimit} {
                set new any
            }
            if {$new ne $old} {
                dict set state instances $id result $new
                if {[dict exists $state deps $id]} {
                    foreach reader [dict keys [dict get $state deps $id]] {
                        if {$reader eq $id} {
                            continue
                        }
                        if {$reader in [dict get $state stack]} {
                            dict set state instances $reader dirty 1
                        } else {
                            Requeue $reader
                        }
                    }
                }
            }
            if {![dict get $state instances $id assumes]
                    || ($new eq $old && ![dict get $state instances $id dirty])} {
                dict set state instances $id snapshot $snapshot
                break
            }
            if {$passes >= $passLimit + 3} {
                dict set state instances $id result any
                dict set state instances $id snapshot $snapshot
                break
            }
        }
        dict set state instances $id status analyzed
        dict set state instances $id passes [expr {[dict get $state instances $id passes] + $passes}]
    } finally {
        dict set state stack [lrange [dict get $state stack] 0 end-1]
    }
}

# Instance ID, requested deeper than the nesting limits (maxDepth analyses
# in progress, or Tcl's own stack near levelLimit): not analyzed now but
# queued, so that the worklist analyzes it once the analyses in progress
# return (Drain, at the request that started them). Until then it answers
# with its current result, never, as a recursive request does: whoever reads
# it assumes (Call) and is analyzed again when the answer grows. So depth
# costs walks, never precision, and never depends on which request came
# first.
proc hir::semantic::Defer {id} {
    variable state
    dict set state instances $id status deferred
    Bump deferred
    Requeue $id
}

# Instance ID, requested from inside another instance's walk: analyzed now,
# from the HIR as the request that started the walks in progress found it.
# Only the innermost walk's changes are in HIRVAR (every walk starts from
# that HIR: Walk), so it is put aside for the nested analysis and back after.
proc hir::semantic::Nested {hirVar id} {
    upvar 1 $hirVar hir
    variable state
    set txns [dict get $state txns]
    if {$txns eq {}} {
        Analyze hir $id
        return
    }
    set inner [lindex $txns end]
    set current [Capture $hir $inner]
    Rewind hir $inner
    try {
        Analyze hir $id
    } finally {
        Rewind hir $current
    }
}

proc hir::semantic::Requeue {id} {
    variable state
    if {$id ni [dict get $state queue]} {
        dict lappend state queue $id
    }
}

# Re-analyzes queued instances -- those whose inputs grew, and those
# deferred -- oldest first, until none is queued (a top-level request
# returns only settled answers). The guard is a compiler resource failure:
# each instance's result only grows in a finite lattice, so the worklist
# converges, and its length is bounded by the instances' count and the
# passes each may take.
proc hir::semantic::Drain {hirVar} {
    upvar 1 $hirVar hir
    variable state
    variable passLimit
    set guard 0
    while {[dict get $state queue] ne {}} {
        set id [lindex [dict get $state queue] 0]
        dict set state queue [lrange [dict get $state queue] 1 end]
        if {$id in [dict get $state stack]} {
            continue
        }
        set limit [expr {5000 + 4 * ($passLimit + 3) * [dict size [dict get $state instances]]}]
        if {[incr guard] > $limit} {
            throw {HIR SEMANTIC LIMIT} "hir::semantic: the semantic-instance worklist did not converge after $limit analyses"
        }
        Analyze hir $id
    }
}

# One walk of instance ID's block body under its entry environment: the
# ordinary semantic inference (hir::types::Sequence) of the HIR in variable
# HIRVAR -- the generic walk's own, typed in place: no copy of it is made --
# with the block's parameters seeded by the entry types and its captures by
# the recorded creation environment. Every change the walk makes is undone
# before it returns (Save, Restore: "Region-local walks"), after the
# region's facts are read into the instance's snapshot. Returns {RESULT
# SNAPSHOT OUTWARD}.
proc hir::semantic::Walk {hirVar id} {
    upvar 1 $hirVar hir
    variable state
    set inst [dict get $state instances $id]
    set block [dict get $inst block]
    set journal [Save hir $block]
    dict lappend state txns $journal
    set outermost [expr {[llength [dict get $state txns]] == 1}]
    try {
        set node [dict get $hir exprs $block]
        set ctx [hir::types::NewContext]
        dict set ctx inst $id
        set types [dict get $inst env]
        foreach b [dict get $node params] t [dict get $inst args] {
            dict set types $b $t
        }
        dict set ctx types $types
        set body [hir::types::Sequence hir ctx [dict get $node body]]
        set result [hir::types::lub $body [dict get $ctx returnType]]
        if {$result eq "never" && [dict get $ctx poisonResult]} {
            # Every normal completion of this walk is poison (hir/types.tcl,
            # "Poison"): so is the call of the instance (PoisonedCall).
            dict set state instances $id poisoned 1
        } elseif {[dict exists $state instances $id poisoned]} {
            dict unset state instances $id poisoned
        }
        dict set hir exprs $block inferredResultType [hir::types::intern hir $result]
        set declared [dict get $node declaredResult]
        if {$declared ne {}} {
            set result [hir::traits::ViewResult $declared $result]
        }
        dict set hir exprs $block resultType [hir::types::intern hir $result]
        set snapshot [Snapshot $hir $id]
        set outward [Outward $hir $block $result]
    } finally {
        dict set state txns [lrange [dict get $state txns] 0 end-1]
        Restore hir $journal $outermost
    }
    return [list $result $snapshot $outward]
}

# The outward type of a coroutine rooted at BLOCK, as this instance walk
# typed it (HIR, its result RESULT): the join of the result and of every
# value one of BLOCK's own yields sends (hir::coroutines::Outward's join,
# with the instance's types). A construction whose root call has an
# instance is typed with it (ConstructionOutward).
proc hir::semantic::Outward {hir block result} {
    if {![dict exists $hir coroutines direct $block]} {
        return $result
    }
    foreach y [dict get $hir coroutines direct $block] {
        set value [lindex [dict get $hir exprs $y args] 0]
        if {$value eq "" || [dict get $hir exprs $value type] eq ""} continue
        set result [hir::types::lub $result [hir::typeOf $hir $value]]
    }
    return $result
}

# The outward type the instance of the exact call E (typed in typing context
# CTX) gives a coroutine whose root that call is, or "" when the call has no
# instance (or no run is in progress): what its block's own yields send and
# it returns, under the call's argument types. A semantic instance types a
# construction the way it types an ordinary call's result
# (TREE-STRUCT-MILESTONE-1.md, "Typed traversal").
# Outside a run (a codegen instance's typing, hir/specialize.tcl), the
# program's own call E answers from the instance the run left in HIR, as
# GenericResult does for an ordinary call.
proc hir::semantic::ConstructionOutward {hir ctx e} {
    variable state
    if {$state eq ""} {
        if {![dict exists $hir semantic calls [list generic $e]]} {
            return ""
        }
        set id [dict get $hir semantic calls [list generic $e]]
        return [dict getdef [dict get $hir semantic instances $id] outward ""]
    }
    set callKey [list [dict getdef $ctx inst "generic"] $e]
    if {![dict exists $state calls $callKey]} {
        return ""
    }
    set id [dict get $state calls $callKey]
    return [dict get $state instances $id outward]
}

# ---------------------------------------------------------------------------
# Regions and snapshots

# The expressions of block E's region: E itself, its body and, transitively,
# the bodies of the closures it creates.
proc hir::semantic::Region {hir e} {
    variable state
    if {$state ne "" && [dict exists $state regions $e]} {
        return [dict get $state regions $e]
    }
    set result [list $e]
    foreach child [dict get $hir exprs $e body] {
        hir::WalkInto $hir $child result
    }
    if {$state ne ""} {
        dict set state regions $e $result
    }
    return $result
}

# The volatile facts instance ID's walk left in HIR over its region (a small
# per-instance side table; the HIR is never cloned).
proc hir::semantic::Snapshot {hir id} {
    variable state
    variable fields
    variable typeFields
    set block [dict get $state instances $id block]
    set exprs [dict create]
    set bindings [dict create]
    foreach e [Region $hir $block] {
        set node [dict get $hir exprs $e]
        set rec [dict create]
        foreach f $fields {
            if {![dict exists $node $f]} {
                continue
            }
            set v [dict get $node $f]
            if {$f in $typeFields} {
                if {$v eq ""} {
                    set v ""
                } else {
                    set v [dict get $hir types $v]
                }
            }
            dict set rec $f $v
        }
        dict set exprs $e $rec
        if {[dict get $node kind] eq "bind" && ![dict get $node duplicate]} {
            set b [dict get $node binding]
            if {$b ne "" && [dict exists $hir bindings $b type]
                    && [dict get $hir bindings $b type] ne ""} {
                dict set bindings $b [dict get $hir types [dict get $hir bindings $b type]]
            }
        }
        # A loop's clause bindings: their types as this instance's walk
        # recorded them (hir/types.tcl's RecordClause: its own table, never
        # the program's record, the generic walk's; Restore drops the table
        # with the walk's other changes).
        foreach b [hir::loopClauseBindings $node] {
            if {[dict exists $hir instanceClauses $b]} {
                dict set bindings $b [dict get $hir types [dict get $hir instanceClauses $b]]
            }
        }
    }
    return [dict create exprs $exprs bindings $bindings]
}

# HIR viewed as instance ID's final walk left it: the region's facts replaced
# by the snapshot, calls resolved in the instance's own context. A copy of
# the whole HIR: verify applies the snapshot in place instead (Apply).
proc hir::semantic::View {hir id} {
    Apply hir $id
    return $hir
}

# Makes the HIR in variable HIRVAR the view of instance ID (View), in place.
proc hir::semantic::Apply {hirVar id} {
    upvar 1 $hirVar hir
    variable typeFields
    set snapshot [dict get $hir semantic instances $id snapshot]
    dict for {e rec} [dict get $snapshot exprs] {
        dict for {f v} $rec {
            if {$f in $typeFields} {
                dict set hir exprs $e $f [if {$v eq ""} {string cat ""} else {hir::types::intern hir $v}]
            } else {
                dict set hir exprs $e $f $v
            }
        }
    }
    dict for {b type} [dict get $snapshot bindings] {
        dict set hir bindings $b type [hir::types::intern hir $type]
    }
    dict set hir semanticContext $id
    dict set hir diagnostics {}
    if {[dict exists $hir violatedContracts]} {
        dict unset hir violatedContracts
    }
}

# ---------------------------------------------------------------------------
# Region-local walks (SEMANTIC-INSTANCE-SCALABILITY-MILESTONE-1.md)
#
# An instance's walk types its block's region in the HIR the generic walk is
# typing -- that variable itself (Call, Analyze and Walk take its name) -- and
# verification applies an instance's snapshot to the checked HIR the same way
# (verify). Neither copies the program: Tcl copies a table on its first
# write only when another value shares it, and a scratch copy of the HIR
# shared every table with the program, so its first type write copied the
# whole expression table -- O(program) per instance walk, quadratic in all.
# A walk in place writes only what it types, O(its region).
#
# The HIR is authoritative, and an instance's walk must leave it exactly as
# it found it. Save records, before the walk, everything the walk may
# change:
#
#   * every top-level entry but the tables below, as it is (one reference
#     each: a table a walk writes -- `poisoned`, `foldConflicts` -- is copied
#     at its first write, which costs that table's size, small and non-empty
#     only where it is about a diagnostic);
#   * of `exprs`, every expression of the block's region (Region: the block,
#     its body, the closures it creates);
#   * of `scopes` and `bindings`, every scope nested in the block's body
#     scope (RegionScopes) and every binding declared in one: a walk types
#     the bindings it binds and refines the scopes it branches into;
#   * of `types` and `typeIds`, the interning counter: interning only adds.
#
# Restore puts every recorded value back and drops what was added (a
# top-level entry, the types interned since the mark). What a walk computes
# survives only in the instance's snapshot, read before Restore (Snapshot,
# Outward), exactly as when it was typed in a copy.
#
# Every walk starts from the HIR as the request that started the analyses in
# progress found it: a walk requested from inside another (Nested) puts the
# changes of the one in progress aside first (Capture, Rewind) and puts them
# back after. Interning, the id counters and `symbols` only grow, so they are
# never put aside: the ids an enclosing walk holds stay valid, and the one
# outermost walk drops them at its end.
#
# auditRollback 1 (BOTLISH_SEMANTIC_ROLLBACK_AUDIT=1; tests) compares the
# whole HIR after every Restore with the HIR before the walk, and fails the
# compilation on any difference: a walk that writes outside what Save
# records. It costs a copy of the program per walk (the reference shares its
# tables): a check, not a mode to run.

namespace eval hir::semantic {
    # Tables restored entry by entry (the rest as a whole).
    variable sparse {exprs bindings scopes types typeIds}
    # Tables that only grow during a run: never put aside.
    variable appendOnly {counters symbols}
    variable auditRollback [expr {[info exists ::env(BOTLISH_SEMANTIC_ROLLBACK_AUDIT)]
        && $::env(BOTLISH_SEMANTIC_ROLLBACK_AUDIT) eq "1"}]
}

# Scope -> the scopes whose parent it is, of HIR.
proc hir::semantic::ScopeKids {hir} {
    set kids [dict create]
    dict for {s rec} [dict get $hir scopes] {
        set parent [dict get $rec parent]
        if {$parent ne ""} {
            dict lappend kids $parent $s
        }
    }
    return $kids
}

# The scopes of block E's region: its body scope and every scope nested in
# it. KIDS is ScopeKids of HIR; during a run it is the run's own (scopes are
# made by resolution, never by a walk) and so are the answers.
proc hir::semantic::RegionScopes {hir e {kids ""}} {
    variable state
    if {$state ne "" && [dict exists $state regionScopes $e]} {
        return [dict get $state regionScopes $e]
    }
    if {$kids eq "" && $state ne ""} {
        if {[dict get $state scopeKids] eq ""} {
            dict set state scopeKids [list [ScopeKids $hir]]
        }
        set kids [lindex [dict get $state scopeKids] 0]
    } elseif {$kids eq ""} {
        set kids [ScopeKids $hir]
    }
    set result {}
    set work [list [dict get $hir exprs $e bodyScope]]
    while {$work ne {}} {
        set s [lindex $work end]
        set work [lrange $work 0 end-1]
        lappend result $s
        lappend work {*}[dict getdef $kids $s {}]
    }
    if {$state ne ""} {
        dict set state regionScopes $e $result
    }
    return $result
}

# The journal of a walk of block E's region in the HIR in variable HIRVAR
# (header, above): what Restore puts back.
proc hir::semantic::Save {hirVar e {kids ""}} {
    upvar 1 $hirVar hir
    variable sparse
    variable auditRollback
    set tops [dict create]
    dict for {k v} $hir {
        if {$k ni $sparse} {
            dict set tops $k $v
        }
    }
    # (Each table's entries as a list of ID VALUE pairs: what Rewind puts
    # back in order, without hashing them twice.)
    set table [dict get $hir exprs]
    set exprs {}
    foreach x [Region $hir $e] {
        lappend exprs $x [dict get $table $x]
    }
    set scopeTable [dict get $hir scopes]
    set bindingTable [dict get $hir bindings]
    set scopes {}
    set bindings {}
    foreach s [RegionScopes $hir $e $kids] {
        set rec [dict get $scopeTable $s]
        lappend scopes $s $rec
        foreach b [dict get $rec bindings] {
            lappend bindings $b [dict get $bindingTable $b]
        }
    }
    unset table scopeTable bindingTable
    set journal [dict create tops $tops exprs $exprs scopes $scopes bindings $bindings \
        mark [dict getdef $hir counters type 0] order [dict keys $hir]]
    if {$auditRollback} {
        dict set journal reference $hir
    }
    return $journal
}

# JOURNAL's entries as HIR holds them now (Nested: the changes of the walk in
# progress, put aside and back).
proc hir::semantic::Capture {hir journal} {
    variable sparse
    variable appendOnly
    set tops [dict create]
    dict for {k v} $hir {
        if {$k ni $sparse && $k ni $appendOnly} {
            dict set tops $k $v
        }
    }
    set captured [dict create tops $tops]
    foreach table {exprs scopes bindings} {
        set entries [dict get $hir $table]
        set now {}
        foreach {id -} [dict get $journal $table] {
            lappend now $id [dict get $entries $id]
        }
        dict set captured $table $now
    }
    return $captured
}

# Puts JOURNAL's entries (Save's, or Capture's) back into the HIR in variable
# HIRVAR, the growing tables aside: a top-level entry it does not hold is
# removed.
proc hir::semantic::Rewind {hirVar journal} {
    upvar 1 $hirVar hir
    variable sparse
    variable appendOnly
    set tops [dict get $journal tops]
    foreach k [dict keys $hir] {
        if {$k in $sparse || $k in $appendOnly || [dict exists $tops $k]} continue
        dict unset hir $k
    }
    dict for {k v} $tops {
        if {$k in $appendOnly} continue
        dict set hir $k $v
    }
    foreach table {exprs scopes bindings} {
        set pairs [dict get $journal $table]
        if {$pairs eq {}} continue
        # The table taken out while its entries are put back, so that each
        # write is one lookup in a table nothing else holds.
        set entries [dict get $hir $table]
        dict set hir $table {}
        foreach {id value} $pairs {
            dict set entries $id $value
        }
        dict set hir $table $entries
        unset entries
    }
}

# Ends the walk JOURNAL is Save's of: the HIR in variable HIRVAR as it was
# before it. The OUTERMOST walk (no other in progress) also drops what the
# growing tables gained: the types interned since its mark, the id counters
# and symbols made.
proc hir::semantic::Restore {hirVar journal outermost} {
    upvar 1 $hirVar hir
    variable appendOnly
    set now [dict getdef $hir counters type 0]
    Rewind hir $journal
    if {$outermost} {
        set tops [dict get $journal tops]
        foreach k $appendOnly {
            if {[dict exists $tops $k]} {
                dict set hir $k [dict get $tops $k]
            } elseif {[dict exists $hir $k]} {
                dict unset hir $k
            }
        }
        set prefix [dict get $::hir::prefixes type]
        for {set n [expr {[dict get $journal mark] + 1}]} {$n <= $now} {incr n} {
            if {[dict exists $hir types $prefix$n]} {
                dict unset hir typeIds [dict get $hir types $prefix$n]
                dict unset hir types $prefix$n
            }
        }
    }
    if {[dict keys $hir] ne [dict get $journal order]} {
        # A top-level entry the walk removed and Rewind put back went last:
        # the entries in their order again (what the HIR holds is unchanged).
        set ordered [dict create]
        foreach k [dict get $journal order] {
            if {[dict exists $hir $k]} {
                dict set ordered $k [dict get $hir $k]
            }
        }
        dict for {k v} $hir {
            if {![dict exists $ordered $k]} {
                dict set ordered $k $v
            }
        }
        set hir $ordered
        unset ordered
    }
    if {[dict exists $journal reference]} {
        AuditRestore [dict get $journal reference] $hir $outermost
    }
}

# Fails unless AFTER (a HIR Restore put back) is BEFORE (the HIR Save saw):
# auditRollback's check (header, above). Below the OUTERMOST walk, the growing
# tables may have grown.
proc hir::semantic::AuditRestore {before after outermost} {
    variable sparse
    variable appendOnly
    set growing [if {$outermost} {list} else {list {*}$appendOnly types typeIds}]
    set problems {}
    foreach k [lsort -unique [concat [dict keys $before] [dict keys $after]]] {
        if {![dict exists $before $k] || ![dict exists $after $k]} {
            if {$k in $growing && [dict exists $after $k]} continue
            lappend problems "the top-level entry `$k` was [if {[dict exists $before $k]} {string cat removed} else {string cat added}]"
            continue
        }
        if {$k eq "counters" && !$outermost} continue
        set b [dict get $before $k]
        set a [dict get $after $k]
        if {$k in $sparse || $k in $growing} {
            if {$k ni $growing && [dict size $a] != [dict size $b]} {
                lappend problems "`$k` had [dict size $b] entries and has [dict size $a]"
            }
            dict for {id v} $b {
                if {![dict exists $a $id]} {
                    lappend problems "`$k` lost $id"
                } elseif {[dict get $a $id] ne $v} {
                    lappend problems "`$k` $id changed"
                }
            }
        } elseif {$a ne $b} {
            lappend problems "the top-level entry `$k` changed"
        }
    }
    if {$problems ne {}} {
        error "hir::semantic: a region-local walk did not restore the HIR: [join [lrange $problems 0 9] {; }]"
    }
}

# ---------------------------------------------------------------------------
# Queries (hir::callables, hir::range, hir::specialize, tooling)

# The InstanceId the exact call E uses in the context HIR is being looked at
# in (the generic program, or a view of an instance), or "".
proc hir::semantic::InstanceOf {hir e} {
    if {![dict exists $hir semantic]} {
        return ""
    }
    set ctx [dict getdef $hir semanticContext "generic"]
    set key [list $ctx $e]
    if {[dict exists $hir semantic calls $key]} {
        return [dict get $hir semantic calls $key]
    }
    return ""
}

# The entry types of instance ID (one per parameter).
proc hir::semantic::EntryTypes {hir id} {
    return [dict get $hir semantic instances $id args]
}

# The result type semantic instance analysis gave the program's own call E
# ("" if none): used by hir/specialize.tcl to never be less precise than the
# semantic HIR.
proc hir::semantic::GenericResult {hir e} {
    if {![dict exists $hir semantic calls [list generic $e]]} {
        return ""
    }
    set id [dict get $hir semantic calls [list generic $e]]
    return [dict get $hir semantic instances $id result]
}

# ---------------------------------------------------------------------------
# Verification (hir::check)

# Diagnoses every call of the program that needs an instance the body of which
# is invalid under that call's concrete types (header, "Validity").
proc hir::semantic::verify {hirVar} {
    upvar 1 $hirVar hir
    if {![dict exists $hir semantic]} {
        return
    }
    set semantic [dict get $hir semantic]
    set used [dict get $semantic used]
    # 1. Each instance's own diagnostics. A problem the definition already has
    # for every call (the generic verification reported the same diagnostic
    # at the same expression) is that definition's, not this call's.
    set definitional [dict create]
    foreach d [dict get $hir diagnostics] {
        dict set definitional [list [dict get $d expr] [dict get $d message]] 1
    }
    set own [dict create]
    # Each instance is verified in the checked HIR itself, its snapshot
    # applied in place and taken back (Save, Apply, Restore: "Region-local
    # walks"), never in a copy of the program.
    set kids [ScopeKids $hir]
    foreach id $used {
        set block [dict get $semantic instances $id block]
        set region [Region $hir $block]
        set journal [Save hir $block $kids]
        # The generic program as hir::layouts::verifyInstance reads it: the
        # region's own expressions, with their generic types.
        set generic [dict create exprs [dict create {*}[dict get $journal exprs]] types [dict create]]
        foreach {e node} [dict get $journal exprs] {
            set t [dict get $node type]
            if {$t ne ""} {
                dict set generic types $t [dict get $hir types $t]
            }
        }
        try {
            Apply hir $id
            set blocks [lmap e $region {
                if {[dict get $hir exprs $e kind] ne "block"} continue
                set e
            }]
            hir::range::verifyBlocks hir $blocks
            hir::callables::verifyBlocks hir $blocks
            hir::structs::verifyExprs hir $region
            hir::layouts::verifyInstance hir $generic $region
            if {[hir::types::AnyAffine [dict get $semantic instances $id args]]} {
                # An instance that owns an affine argument (AFFINE-VALUES.md):
                # the ownership discipline, with the instance's own types -- a
                # generic function that would duplicate or erase the value it
                # was given is invalid for the call that gives it one.
                hir::affine::verifyInstance hir $block $region
            }
            dict set own $id [lmap d [dict get $hir diagnostics] {
                if {[dict exists $definitional [list [dict get $d expr] [dict get $d message]]]} continue
                # Nor is a problem in code this instance proves unreachable (an
                # empty domain's loop body, an arm its types decide against):
                # the call never runs it. Its typing there describes values that
                # cannot exist (a loop element of type `never`). The definition's
                # own verification still checks that code as written.
                if {[dict exists $hir exprs [dict get $d expr]]
                        && ![dict get $hir exprs [dict get $d expr] reachable]} continue
                dict set d curable [expr {[dict get $d kind] eq "UNPROVEN-FIELD"}]
                set d
            }]
            set violated [dict getdef $hir violatedContracts {}]
        } finally {
            Restore hir $journal 1
        }
        dict for {p arg} $violated {
            dict set hir violatedContracts $p $arg
        }
    }
    # 2. A call to an invalid instance makes the calling instance invalid.
    set calls [dict get $semantic calls]
    set changed 1
    while {$changed} {
        set changed 0
        dict for {key callee} $calls {
            lassign $key caller e
            if {$caller eq "generic" || $caller ni $used || [dict get $own $callee] eq {}} {
                continue
            }
            set derived [Derived $hir $callee $e $own]
            if {$derived ni [lmap d [dict get $own $caller] {dict get $d message}]} {
                dict lappend own $caller [dict create kind [DerivedKind $own $callee] message $derived expr $e \
                    curable [Curable $own $callee]]
                set changed 1
            }
        }
    }
    dict set hir semantic status [lmap id $used {
        list $id [expr {[dict get $own $id] eq {} ? "valid" : "invalid"}]
    }]
    dict set hir semantic diagnostics $own
    # 3. Report at the program's own calls, in a stable order.
    set generic {}
    dict for {key callee} $calls {
        if {[lindex $key 0] eq "generic"} {
            lappend generic [lindex $key 1]
        }
    }
    set live ""
    foreach e [lsort -dictionary $generic] {
        set callee [dict get $calls [list generic $e]]
        if {[dict get $own $callee] eq {}} {
            continue
        }
        # An unproven struct projection is the one problem an instance can
        # cure (hir/structs.tcl): the instance a call of a generic body that
        # never runs generically asks for (a recursive function's own call,
        # made with its unrefined parameters) is not reachable, so it reports
        # nothing. Every other problem is the call's, live or not.
        if {[Curable $own $callee]} {
            if {$live eq ""} {
                set live [hir::structs::GenericLive $hir]
            }
            if {[hir::structs::OwnerBlock $hir $e] ni $live} {
                continue
            }
        }
        # The call's own problem with its callee: no instance of the callee
        # is valid for these arguments (hir::CheckingCall).
        hir::CheckingCall $e {
            hir::Diagnose hir [DerivedKind $own $callee] [Derived $hir $callee $e $own] $e
        }
    }
}

# The kind a call's diagnostic carries when instance ID (in OWN) is invalid:
# TYPE, except that a first problem of representation authority over an
# opaque struct (OPAQUE-STRUCTS.md) keeps its own kind, so the call that made
# the instance is reported as the opacity violation it is.
proc hir::semantic::DerivedKind {own id} {
    set first [lindex [dict get $own $id] 0]
    set kind [dict get $first kind]
    if {$kind in {OPAQUE-REPRESENTATION USE-AFTER-MOVE UNHANDLED-ERROR MISSING-IMPORT PRIVATE-ACCESS} || [string match AFFINE-* $kind]} {
        # (An ownership violation keeps its own kind: AFFINE-VALUES.md. So
        # does a method-style call whose function's namespace is not
        # imported: the explicit spelling's diagnostic, DIAGNOSTIC-RECOVERY.md
        # -- and a private access: MODULE-PRIVACY-AND-CONTEXT-ESCAPE-
        # MILESTONE-1.md.)
        return $kind
    }
    return TYPE
}

# 1 if every problem instance ID has (in OWN) is an unproven struct field
# projection, directly or through the instances it calls.
proc hir::semantic::Curable {own id} {
    foreach d [dict get $own $id] {
        if {![dict exists $d curable] || ![dict get $d curable]} {
            return 0
        }
    }
    return 1
}

# "call to F with x : T, ... is invalid: WHY": the message for call E of
# instance ID, WHY being the first problem its body has (with where).
proc hir::semantic::Derived {hir id e own} {
    set first [lindex [dict get $own $id] 0]
    set where [hir::signatures::Where $hir [dict get $first expr]]
    return [format {call to %s with %s is invalid: %s%s} \
        [Label $hir $id] [Environment $hir $id] [dict get $first message] \
        [expr {$where eq "" ? "" : " (in the body of [Label $hir $id], at $where)"}]]
}

# The source name of the function of instance ID.
proc hir::semantic::Label {hir id} {
    set name [CallableName $hir [dict get $hir semantic instances $id block]]
    if {$name eq ""} {
        return "this function"
    }
    return $name
}

# "x : MutableArray[str], y : int": the concrete environment of instance ID.
proc hir::semantic::Environment {hir id} {
    set inst [dict get $hir semantic instances $id]
    set block [dict get $inst block]
    return [join [lmap b [dict get $hir exprs $block params] t [dict get $inst args] {
        format {%s : %s} [SourceName $hir $b] [ShowType $hir $t]
    }] {, }]
}

# The name binding B is written with, for a diagnostic: its source spelling
# when hygiene renamed it (hir/hygiene.tcl's NAME#N, whose number counts the
# renames of that name across the whole program -- the bindings of every
# static site's body among them, so it is not the same in every build:
# STATIC-COMPILE.md, "Internal ids"), else its name (a module's own
# definition: the qualified name, which hir/hygiene.tcl's qualifyModules
# made of a hygiene rename too -- NS::NAME#N is written NS::NAME).
proc hir::semantic::SourceName {hir b} {
    if {[dict exists $hir bindings $b extern]} {
        # An extern c fn (hir/foreign.tcl): its Botlish qualified name.
        return [dict get $hir bindings $b extern]
    }
    if {[dict exists $hir bindings $b spelling] && ![hir::isModuleBinding $hir $b]} {
        return [dict get $hir bindings $b spelling]
    }
    set name [dict get $hir bindings $b name]
    set i [string last :: $name]
    if {[dict exists $hir bindings $b spelling] && $i >= 0} {
        set name [string range $name 0 [expr {$i + 1}]][namespace tail [dict get $hir bindings $b spelling]]
    }
    return $name
}

# The name reference or binding statement E (a `ref` or `bind` node) is
# written with, for a diagnostic: hygiene renames a binding's references and
# binding statements with it (hir/hygiene.tcl's RenameTo), so a node that
# carries its binding's name is named by SourceName; any other (an unresolved
# reference) keeps its own.
proc hir::semantic::RefName {hir e} {
    set node [dict get $hir exprs $e]
    set b [dict get $node binding]
    if {$b ne "" && [dict get $hir bindings $b name] eq [dict get $node name]} {
        return [SourceName $hir $b]
    }
    return [dict get $node name]
}

# The source name of the function block E is bound to (SourceName), or ""
# for a function without one.
proc hir::semantic::CallableName {hir e} {
    foreach b [dict get $hir scopes [dict get $hir exprs $e scope] bindings] {
        set declaredBy [dict get $hir bindings $b declaredBy]
        if {$declaredBy ne "" && [dict exists $hir exprs $declaredBy]
                && [dict get $hir exprs $declaredBy value] eq $e} {
            return [SourceName $hir $b]
        }
    }
    return ""
}

# hir::types::show with an exact callable named by its source function
# (`block(e49)/1 -> bool` reads `is_b/1 -> bool`).
proc hir::semantic::ShowType {hir type} {
    return [NameCallables $hir [hir::types::show $type]]
}

# TEXT (a type's text, hir::types::show or showContract) with every exact
# callable `block(e49)` named by its source function (CallableName) --
# `function e49` for one without a name.
proc hir::semantic::NameCallables {hir text} {
    while {[regexp {block\((e[0-9]+)\)} $text -> block]} {
        set name [CallableName $hir $block]
        if {$name eq ""} {
            set name "function $block"
        }
        regsub {block\(e[0-9]+\)} $text $name text
    }
    return $text
}

# ---------------------------------------------------------------------------
# Tooling

# The instance table of HIR as a list of dicts, in id order, each with
# id, name, args (types), result, status (valid | invalid | analyzed), used
# and calls (the program's own calls that use it).
proc hir::semantic::census {hir} {
    if {![dict exists $hir semantic]} {
        return {}
    }
    set s [dict get $hir semantic]
    set status [dict getdef $s status {}]
    set rows {}
    foreach id [dict get $s used] {
        set inst [dict get $s instances $id]
        set st analyzed
        foreach pair $status {
            if {[lindex $pair 0] eq $id} {
                set st [lindex $pair 1]
            }
        }
        set calls {}
        dict for {key i} [dict get $s calls] {
            if {$i eq $id} {
                lappend calls $key
            }
        }
        lappend rows [dict create id $id block [dict get $inst block] \
            name [hir::signatures::Name $hir [dict get $inst block]] \
            args [dict get $inst args] result [dict get $inst result] status $st \
            passes [dict get $inst passes] calls $calls]
    }
    return $rows
}
