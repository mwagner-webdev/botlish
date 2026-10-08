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
#     is invalid for the declared type.
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
# Budgets (never a false error): at most `maxPerBlock` instances of one block,
# `maxInstances` in all and `maxDepth` nested analyses; a request beyond is
# DECLINED and the call keeps its ordinary generic typing. That fallback is
# sound only because it is the pre-existing behavior: a declined call gives its
# parameters no instance context, so hir::callables still rejects a bearing
# argument (a MutableArray[T], a typed callable) that would cross an untyped
# parameter -- a budget never accepts an erasure. A real type error found in an
# instance is never turned into a fallback.
#
# Validity
# --------
# Analysis (Walk) and verification are separate. Walk types the body under the
# entry environment and yields the result; each instance's final walk is
# snapshotted (the volatile per-expression facts of its region, not a HIR
# clone). verify then runs, on a view of the HIR carrying that snapshot, the
# same checks every function body gets for its own definition: the typed-call
# admissibility proofs and MutableArray store/copy rules
# (hir::range::verifyBlocks) and the bearing/non-erasure audit
# (hir::callables::verifyBlocks). A diagnostic there means "this function is
# invalid for this call": it is reported at the CALL that needed the instance
# (status invalid); the source function is not rejected and other calls are
# unaffected. A call to an invalid instance from inside another instance makes
# that one invalid too. Explicit parameter declarations and intrinsic
# contracts (hir/signatures.tcl) are not changed by any of this: contracts are
# still derived from declaration + body alone, and hir::moduleSignatures never
# reports an instance.
#
# Status: analyzing -> analyzed; then verify: valid | invalid. A request that is
# not instantiated is `declined` with a reason (no-env, budget-block,
# budget-total, nesting).

namespace eval hir::semantic {
    # 0 disables the whole layer (measurement and tests only).
    variable enabled 1
    variable maxPerBlock 16
    variable maxInstances 2000
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
        calls {} declined {} stack {} queue {} deps {} base "" next 0 regions {} instsOf {} \
        requests 0 trivial 0 hits 0 walks 0 declinedCount {}]
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
    foreach key {base stack queue regions} {
        dict unset s $key
    }
    return $s
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
        dict set env $b [expr {$b eq $self ? $selfType : [hir::types::BindingType $hir $outer $b]}]
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
# context CTX of HIR (the generic walk, or a semantic instance's walk):
# BLOCKRESULT (the call's ordinary generic result) unless a semantic instance
# proves a more precise one. Records the call -> instance edge that
# hir::callables and hir::range::VerifyCall consult.
proc hir::semantic::Call {hir ctx e block argTypes blockResult} {
    variable state
    variable enabled
    variable maxPerBlock
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
    set generics {}
    set trivial 1
    set index 0
    foreach t $argTypes d $declared {
        if {$d ne {} && [hir::types::IsTraitConstraint $d]} {
            # A trait-typed parameter (TRAITS.md): the instance is entered
            # with the argument's view -- its hidden witness is the instance's
            # key component, so two witnesses are two instances.
            set x [hir::traits::EntryView $t $d]
            set generic [hir::traits::AbstractView $d $block $index]
        } elseif {$d ne {}} {
            set x [expr {[hir::types::subtype $t $d] ? $t : $d}]
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
            set x [expr {[hir::types::IsTrait $t] ? "any" : $t}]
            set generic any
        }
        incr index
        if {$x ne $generic} {
            set trivial 0
        }
        lappend entry $x
        lappend generics $generic
    }
    if {$trivial} {
        dict incr state trivial
        return $blockResult
    }
    set key [list $block $entry]
    set caller [expr {[dict exists $ctx inst] ? [dict get $ctx inst] : "generic"}]
    if {$caller eq "generic" && [dict get $state queue] ne {} && [dict get $state stack] eq {}} {
        # Instances whose environment changed since the last request are
        # settled before this walk reads any answer.
        dict set state base $hir
        try {
            Drain
        } finally {
            dict set state base ""
        }
    }
    set callKey [list $caller $e]
    if {[dict exists $state keys $key]} {
        dict incr state hits
        set id [dict get $state keys $key]
    } else {
        set reason [Declined $hir $block]
        if {$reason eq "" && [dict exists $state instances] } {
            if {[dict size [dict get $state instances]] >= $maxInstances} {
                set reason budget-total
            } elseif {[dict exists $state byBlock $block] && [dict get $state byBlock $block] >= $maxPerBlock} {
                set reason budget-block
            } elseif {[llength [dict get $state stack]] >= $maxDepth || [info level] > $levelLimit} {
                set reason nesting
            }
        }
        if {$reason in {budget-total budget-block}
                && ([hir::traits::IsPolymorphic $hir $block] || [hir::types::AnyAffine $entry])} {
            # A trait-polymorphic function's call has no generic fallback:
            # its witnesses decide which specialization it is (TRAITS.md).
            # Past the budget it gets the instance keyed by its trait
            # parameters' views alone, every other parameter at its generic
            # type -- at most one per witness combination. So does a call
            # that gives an affine argument (AFFINE-VALUES.md), keyed by its
            # affine entry types.
            set entry [lmap x $entry g $generics {
                expr {[hir::types::IsView $x] || [hir::types::IsAffine $x] ? $x : $g}
            }]
            set key [list $block $entry]
            set reason ""
        }
        if {$reason eq "" && [dict exists $state keys $key]} {
            dict incr state hits
            set id [dict get $state keys $key]
        } elseif {$reason ne ""} {
            dict set state declined $callKey $reason
            Bump declinedCount $reason
            if {$reason eq "no-env"} {
                dict set state pendingEnv $block 1
            }
            return $blockResult
        } else {
            set id [Create $block $entry $key]
            if {[dict get $state stack] eq {}} {
                dict set state base $hir
                try {
                    Analyze $id
                    Drain
                } finally {
                    dict set state base ""
                }
            } else {
                Analyze $id
            }
        }
    }
    dict set state calls $callKey $id
    if {$caller ne "generic"} {
        dict set state deps $id $caller 1
        if {[dict get $state instances $id status] eq "analyzing"} {
            # The caller read an answer that is still being computed (a
            # recursive request): its own result is an assumption until the
            # fixpoint settles.
            dict set state instances $caller assumes 1
        }
    }
    set result [dict get $state instances $id result]
    # The generic result is sound for every argument: an instance result that
    # is not at least as precise never replaces it.
    if {![Refines $result $blockResult]} {
        return $blockResult
    }
    return $result
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
        env $env status analyzing result never passes 0 dirty 0 assumes 0 snapshot {}]
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

# Analyzes instance ID to its fixpoint. Self recursion re-walks until the
# result stops growing; a change that other analyzing instances already read
# marks them dirty, one that finished instances read queues them.
proc hir::semantic::Analyze {id} {
    variable state
    variable passLimit
    dict lappend state stack $id
    try {
        set passes 0
        while 1 {
            incr passes
            dict set state instances $id dirty 0
            dict set state instances $id assumes 0
            lassign [Walk $id] walked scratch
            dict incr state walks
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
                dict set state instances $id snapshot [Snapshot $scratch $id]
                break
            }
            if {$passes >= $passLimit + 3} {
                dict set state instances $id result any
                dict set state instances $id snapshot [Snapshot $scratch $id]
                break
            }
        }
        dict set state instances $id status analyzed
        dict set state instances $id passes [expr {[dict get $state instances $id passes] + $passes}]
    } finally {
        dict set state stack [lrange [dict get $state stack] 0 end-1]
    }
}

proc hir::semantic::Requeue {id} {
    variable state
    if {$id ni [dict get $state queue]} {
        dict lappend state queue $id
    }
}

# Re-analyzes instances whose inputs grew, oldest first, until none is
# queued (a top-level request returns only settled answers).
proc hir::semantic::Drain {} {
    variable state
    set guard 0
    while {[dict get $state queue] ne {}} {
        set id [lindex [dict get $state queue] 0]
        dict set state queue [lrange [dict get $state queue] 1 end]
        if {$id in [dict get $state stack]} {
            continue
        }
        if {[incr guard] > 5000} {
            error "hir::semantic: instance worklist did not converge"
        }
        Analyze $id
    }
}

# One walk of instance ID's block body under its entry environment: the
# ordinary semantic inference (hir::types::Sequence) over a scratch copy of
# the request-time HIR, with the block's parameters seeded by the entry types
# and its captures by the recorded creation environment. Returns {RESULT
# SCRATCH}.
proc hir::semantic::Walk {id} {
    variable state
    set scratch [dict get $state base]
    set inst [dict get $state instances $id]
    set block [dict get $inst block]
    set node [dict get $scratch exprs $block]
    set ctx [hir::types::NewContext]
    dict set ctx inst $id
    set types [dict get $inst env]
    foreach b [dict get $node params] t [dict get $inst args] {
        dict set types $b $t
    }
    dict set ctx types $types
    set body [hir::types::Sequence scratch ctx [dict get $node body]]
    set result [hir::types::lub $body [dict get $ctx returnType]]
    dict set scratch exprs $block inferredResultType [hir::types::intern scratch $result]
    set declared [dict get $node declaredResult]
    if {$declared ne {}} {
        set result [hir::traits::ViewResult $declared $result]
    }
    dict set scratch exprs $block resultType [hir::types::intern scratch $result]
    return [list $result $scratch]
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

# The volatile facts of instance ID's final walk over its region (a small
# per-instance side table; the HIR is never cloned).
proc hir::semantic::Snapshot {scratch id} {
    variable state
    variable fields
    variable typeFields
    set block [dict get $state instances $id block]
    set exprs [dict create]
    set bindings [dict create]
    foreach e [Region $scratch $block] {
        set node [dict get $scratch exprs $e]
        set rec [dict create]
        foreach f $fields {
            if {![dict exists $node $f]} {
                continue
            }
            set v [dict get $node $f]
            if {$f in $typeFields} {
                set v [expr {$v eq "" ? "" : [dict get $scratch types $v]}]
            }
            dict set rec $f $v
        }
        dict set exprs $e $rec
        if {[dict get $node kind] eq "bind" && ![dict get $node duplicate]} {
            set b [dict get $node binding]
            if {$b ne "" && [dict exists $scratch bindings $b type]
                    && [dict get $scratch bindings $b type] ne ""} {
                dict set bindings $b [dict get $scratch types [dict get $scratch bindings $b type]]
            }
        }
    }
    return [dict create exprs $exprs bindings $bindings]
}

# HIR viewed as instance ID's final walk left it: the region's facts replaced
# by the snapshot, calls resolved in the instance's own context.
proc hir::semantic::View {hir id} {
    variable typeFields
    set snapshot [dict get $hir semantic instances $id snapshot]
    dict for {e rec} [dict get $snapshot exprs] {
        dict for {f v} $rec {
            if {$f in $typeFields} {
                dict set hir exprs $e $f [expr {$v eq "" ? "" : [hir::types::intern hir $v]}]
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
    return $hir
}

# ---------------------------------------------------------------------------
# Queries (hir::callables, hir::range, hir::specialize, tooling)

# The InstanceId the exact call E uses in the context HIR is being looked at
# in (the generic program, or a view of an instance), or "".
proc hir::semantic::InstanceOf {hir e} {
    if {![dict exists $hir semantic]} {
        return ""
    }
    set ctx [expr {[dict exists $hir semanticContext] ? [dict get $hir semanticContext] : "generic"}]
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
    foreach id $used {
        set view [View $hir $id]
        set block [dict get $semantic instances $id block]
        set blocks [lmap e [Region $view $block] {
            if {[dict get $view exprs $e kind] ne "block"} continue
            set e
        }]
        hir::range::verifyBlocks view $blocks
        hir::callables::verifyBlocks view $blocks
        hir::structs::verifyExprs view [Region $view $block]
        if {[hir::types::AnyAffine [dict get $semantic instances $id args]]} {
            # An instance that owns an affine argument (AFFINE-VALUES.md):
            # the ownership discipline, with the instance's own types -- a
            # generic function that would duplicate or erase the value it
            # was given is invalid for the call that gives it one.
            hir::affine::verifyInstance view $block [Region $view $block]
        }
        dict set own $id [lmap d [dict get $view diagnostics] {
            if {[dict exists $definitional [list [dict get $d expr] [dict get $d message]]]} continue
            dict set d curable [expr {[dict get $d kind] eq "UNPROVEN-FIELD"}]
            set d
        }]
        if {[dict exists $view violatedContracts]} {
            dict for {p arg} [dict get $view violatedContracts] {
                dict set hir violatedContracts $p $arg
            }
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
        hir::Diagnose hir [DerivedKind $own $callee] [Derived $hir $callee $e $own] $e
    }
}

# The kind a call's diagnostic carries when instance ID (in OWN) is invalid:
# TYPE, except that a first problem of representation authority over an
# opaque struct (OPAQUE-STRUCTS.md) keeps its own kind, so the call that made
# the instance is reported as the opacity violation it is.
proc hir::semantic::DerivedKind {own id} {
    set first [lindex [dict get $own $id] 0]
    set kind [dict get $first kind]
    if {$kind eq "OPAQUE-REPRESENTATION" || [string match AFFINE-* $kind] || $kind eq "USE-AFTER-MOVE"} {
        # (An ownership violation keeps its own kind: AFFINE-VALUES.md.)
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
    set block [dict get $hir semantic instances $id block]
    set name [hir::signatures::Name $hir $block]
    return [expr {$name eq "a function" ? "this function" : $name}]
}

# "x : MutableArray[str], y : int": the concrete environment of instance ID.
proc hir::semantic::Environment {hir id} {
    set inst [dict get $hir semantic instances $id]
    set block [dict get $inst block]
    return [join [lmap b [dict get $hir exprs $block params] t [dict get $inst args] {
        format {%s : %s} [dict get $hir bindings $b name] [ShowType $hir $t]
    }] {, }]
}

# hir::types::show with an exact callable named by its source function
# (`block(e49)/1 -> bool` reads `is_b/1 -> bool`).
proc hir::semantic::ShowType {hir type} {
    set text [hir::types::show $type]
    while {[regexp {block\((e[0-9]+)\)} $text -> block]} {
        set name [hir::signatures::Name $hir $block]
        if {$name eq "a function"} {
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
    set status [expr {[dict exists $s status] ? [dict get $s status] : {}}]
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
