# escape.tcl -- conservative escape analysis and the facts native/lower.tcl's
# scalar replacement of fixed-shape immutable List aggregates needs.
#
#   set analysis [hir::escape::analyze $hir $spec]
#   hir::escape::wants $analysis $instanceId          -> 0 | 1
#   hir::escape::arity $analysis $instanceId          -> N | ""
#   hir::escape::virtualArity $analysis $instanceId $bindingId  -> N | ""
#   hir::escape::paramVirtualArity $analysis $instanceId $bindingId  -> N | ""
#   hir::escape::paramWants $analysis $instanceId     -> 0 | 1
#   hir::escape::classify $hir $spec $analysis $instanceId $e   -> "" | {local N} | {remote N target}
#
# Parameter virtualization (the closed-call-boundary extension this module
# was originally written up to, at #24 of its own header, as a "structural
# blocker"): a fixed-shape List value crossing an *exact closed call's
# parameter* need not materialize as a List either, when the value's actual
# shape is proven by its callers (never merely assumed from the callee's own
# access pattern) and every one of the parameter's own uses is itself
# structural (see "Parameter/result virtualization across closed calls"
# below for the two-pass analysis, and native/lower.tcl's "Parameter
# virtualization" section for how a `fields`/`fieldscompanion` internal
# variant is built from `paramVirtualArity`/`paramWants`, alongside the
# instance's unconditionally still-emitted canonical, List-taking function).
#
# This is a *representation* analysis, in the same sense as hir/range.tcl:
# nothing here changes what a Botlish List means, HIR types, or
# hir/specialize.tcl's instances. It only proves, per used specialization
# instance (hir/specialize.tcl), that certain `[e0, ..., en-1]` List values
# are semantically ordinary Lists whose object identity is never observed --
# so native/lower.tcl may keep them as a handful of scalar registers
# (n0..nn-1) instead of ever calling `listnew`, and every `list_get` reading
# one of them at a compile-time-constant position may read that register
# directly instead of calling `listget` -- and, separately, which used
# instances a caller's scalar use *demands* a scalar-replacement companion
# NIR function for (a second, additional lowering of the same instance,
# alongside its ordinary List-returning one: see native/lower.tcl's "Scalar
# replacement" section).
#
# Scope (the milestone's #3, #17, #21-22): only immutable List values of a
# statically fixed, positive arity, built directly by a call to the native
# `list` (a `[e0, ..., en-1]` literal) or forwarded unchanged from an exact,
# non-generic-required direct call to another block whose own instance is
# itself recognized this same way. MutableArray, HashTable, Cell, closures,
# Strings, foreign values, and arbitrary/unknown-length Lists are never
# touched: they simply never match the recognizers below, so they always
# fall back to ordinary lowering. Classify itself only ever recognizes a
# *construction* (a literal, or a forwarding call result); passing such an
# aggregate as a plain call *argument* is a separate, later concern this
# file also now covers -- see "Parameter/result virtualization across
# closed calls" below (this used to be a structural blocker for HashTable's
# rehash grouping; it no longer is, for the exact-closed-call shapes that
# section recognizes).
#
# What counts as "the aggregate's identity is never observed" (the
# milestone's #4-5, kept deliberately narrow and conservative -- if
# uncertain, this module simply does not recognize the binding, and
# ordinary lowering is exactly as sound and unchanged as it always was):
#
#   * a local binding, bound (once, non-duplicate, kind local, never
#     captured by a nested closure) to a recognized construction, is
#     "virtual" only if *every* reference to it in the same region is the
#     first argument of a `list_get` call whose second argument is a
#     compile-time Int constant within the construction's arity. Any other
#     use at all (a dynamic index, a store, an argument to any other call, a
#     return, anything this module does not specifically recognize) means
#     the binding is not virtual: ordinary lowering runs unchanged for it,
#     with no partial optimization and therefore no risk of double
#     evaluation or a changed materialization point (the milestone's #11-13
#     follow directly from doing nothing differently in that case).
#   * an instance's normal-completion result is "recognized" only if *every*
#     reachable exit (an explicit `return` targeting it, or its body's
#     trailing value), other than a self-tail-call exit (which is a loop
#     backedge, not a completion, and native/lower.tcl already compiles it
#     as such: see hir/aot.tcl's selfTailCalls), is itself either a direct
#     `[e0, ..., en-1]` construction of the same arity N, or a direct call
#     to another block whose own instance is itself recognized with the
#     same arity N (by induction: the fixpoint below only ever concludes N
#     for an instance once every instance it forwards to already has).
#
# A scalar-replacement companion function is *demanded* for instance J
# (hir::escape::wants) when some caller's binding is virtual and its
# construction forwards to J (direct demand), or when an instance C that is
# itself demanded forwards (in the sense above) to J (propagated demand):
# C's own companion, once built, must call J's companion at that exit rather
# than J's ordinary function, to keep the fields flowing without ever
# materializing a List in between. This is deliberately not "every recognized
# instance gets a companion": one is only ever built where some actual call
# site benefits, so an instance with no such caller is compiled exactly as
# it always was, and the canonical List-returning function of *every*
# instance is unconditionally still emitted (native/lower.tcl), so any
# caller that needs the real List -- a generic/open/indirect call, a test
# harness, a mismatched use elsewhere -- keeps working exactly as before
# (the milestone's #7, #28).
#
# Bounded, non-recursive-in-the-worrying-sense (#20-21): the arity fixpoint
# only ever adds facts (never retracts), so it reaches a fixed point in at
# most one pass per candidate instance; a genuine cycle of mutual forwarding
# with no base case simply never gets an arity, which is sound (no
# companion is ever built for it). The whole analysis is a handful of linear
# scans over each used instance's own region, no whole-program points-to
# reasoning.

namespace eval hir::escape {
}

# ---------------------------------------------------------------------------
# Recognizing a construction

# "" | {local N ""} | {remote N target}: how expression E (a call, in
# INSTANCE's region) builds a recognized fixed-shape List, given ARITY
# (InstanceId -> N so far proven). INSTANCE is INSTANCE's hir::specialize
# instance dict (for its `calls` map). Never true of anything but a direct
# call: a ref, a parameter, a merged/if-typed value, or any other expression
# shape is conservatively unrecognized, however its static type reads.
proc hir::escape::Classify {hir instance arity e} {
    if {[hir::kind $hir $e] ne "call"} {
        return ""
    }
    set node [hir::node $hir $e]
    lassign [dict get $node target] targetKind target
    if {$targetKind eq "native"} {
        if {[dict get [hir::symbol $hir $target] name] ne "list"} {
            return ""
        }
        set n [llength [dict get $node args]]
        if {$n < 1} {
            return ""
        }
        return [list local $n ""]
    }
    if {$targetKind eq "block"} {
        set calls [dict get $instance calls]
        if {![dict exists $calls $e]} {
            return ""
        }
        set callee [dict get $calls $e]
        if {![dict exists $arity $callee]} {
            return ""
        }
        return [list remote [dict get $arity $callee] $callee]
    }
    return ""
}

# Public wrapper of Classify for native/lower.tcl: HIR is the *view* of
# instance ID (hir::specialize::view), matching how ANALYSIS itself examined
# it.
proc hir::escape::classify {hir spec analysis id e} {
    set instance [dict get $spec instances $id]
    return [Classify $hir $instance [dict get $analysis arity] $e]
}

# 1 if call expression E is, for INSTANCE ID specifically, a same-instance
# self-tail loop backedge (not a completion, so it contributes nothing to
# the instance's result shape): structurally a self-tail call
# (hir::aot::selfTailCalls) *and* resolved by hir::specialize back to this
# same instance -- exactly native/lower.tcl's own `self` test (Call), never
# just the structural fact alone. The two can disagree: a recursive call
# whose argument types have not yet converged to INSTANCE's own key
# (hir::specialize::Handle's `within` check) is structurally a self-tail
# call but is compiled as an ordinary forwarding call to a *different*
# (more general) instance, and must be treated as a forwarding exit here
# exactly as native/lower.tcl treats it as an ordinary call.
proc hir::escape::SelfTailExit {hir instance id selfTails e} {
    if {[hir::kind $hir $e] ne "call" || ![dict exists $selfTails $e]} {
        return 0
    }
    set calls [dict get $instance calls]
    return [expr {[dict exists $calls $e] && [dict get $calls $e] eq $id}]
}

# The candidate exit value expressions of instance ID's region (BLOCK, view
# HIR): every reachable `return` targeting it, and its body's trailing value
# if reachable -- excluding self-tail-call exits (see SelfTailExit).
proc hir::escape::Exits {hir context instance id block selfTails} {
    set exits {}
    foreach e [dict get $context exprs $block] {
        if {[hir::kind $hir $e] ne "return" || ![hir::get $hir $e reachable]
                || [hir::get $hir $e target] ne $block} {
            continue
        }
        set v [hir::get $hir $e value]
        if {$v ne "" && ![SelfTailExit $hir $instance $id $selfTails $v]} {
            lappend exits $v
        }
    }
    set body [hir::get $hir $block body]
    if {$body ne ""} {
        set last [lindex $body end]
        if {[hir::get $hir $last reachable] && ![SelfTailExit $hir $instance $id $selfTails $last]} {
            lappend exits $last
        }
    }
    return $exits
}

# {ARITY FORWARD}: ARITY is InstanceId -> N for every used instance whose
# result is fully recognized (see the file header); FORWARD is InstanceId ->
# list of distinct target InstanceIds among its own forwarding exits (used
# to propagate companion demand in Wants below).
proc hir::escape::Arities {hir spec} {
    set context [dict get $spec context]
    set selfTails [dict get $context selfTails]
    set candidates [dict create]
    foreach id [dict get $spec used] {
        set instance [dict get $spec instances $id]
        set block [dict get $instance block]
        if {$block eq "program"} {
            continue
        }
        set view [hir::specialize::view $hir $spec $id]
        set exits [Exits $view $context $instance $id $block $selfTails]
        if {$exits eq ""} {
            continue
        }
        dict set candidates $id [list $view $instance $exits]
    }
    set arity [dict create]
    set forward [dict create]
    set changed 1
    while {$changed} {
        set changed 0
        dict for {id info} $candidates {
            if {[dict exists $arity $id]} {
                continue
            }
            lassign $info view instance exits
            set n ""
            set ok 1
            set targets {}
            foreach e $exits {
                set c [Classify $view $instance $arity $e]
                if {$c eq ""} {
                    set ok 0
                    break
                }
                lassign $c kind cn target
                if {$n eq ""} {
                    set n $cn
                } elseif {$n ne $cn} {
                    set ok 0
                    break
                }
                if {$kind eq "remote"} {
                    lappend targets $target
                }
            }
            if {$ok && $n ne ""} {
                dict set arity $id $n
                dict set forward $id [lsort -unique $targets]
                set changed 1
            }
        }
    }
    return [list $arity $forward]
}

# ---------------------------------------------------------------------------
# Local bindings: which ones are fully scalarizable (see the file header),
# and the direct companion demand they create for a remote construction.

# The set (ExprId -> 1) of expressions at a "trailing position" of region
# HIR's own body TOPBODY, or of any if/loop body among EXPRS: whichever
# expression a body list ends with is that scope's implicit value, which
# flows out to whatever encloses it (ultimately the region's own result, if
# not consumed by a further join) with no separate `ref` node marking that
# flow -- see Bindings' use of this to keep a bind statement that is itself
# such a trailing value from being wrongly treated as unused.
proc hir::escape::TrailingPositions {hir topBody exprs} {
    set trailing [dict create]
    if {$topBody ne ""} {
        dict set trailing [lindex $topBody end] 1
    }
    foreach e $exprs {
        set bodies {}
        switch -- [hir::kind $hir $e] {
            if   { set bodies [list [hir::get $hir $e thenBody] [hir::get $hir $e elseBody]] }
            loop { set bodies [list [hir::get $hir $e body]] }
        }
        foreach body $bodies {
            if {$body ne ""} {
                dict set trailing [lindex $body end] 1
            }
        }
    }
    return $trailing
}

# 1 if reference R (to a virtual binding of arity N) is used only as the
# first argument of a `list_get` call whose second argument is a
# compile-time Int constant within 0..N-1 (LISTGETBYARG: first-arg ExprId ->
# the list_get call ExprId, from Bindings above).
proc hir::escape::ScalarUse {hir listGetByArg r n} {
    if {![dict exists $listGetByArg $r]} {
        return 0
    }
    set ce [dict get $listGetByArg $r]
    set idxExpr [lindex [dict get [hir::node $hir $ce] args] 1]
    if {[hir::kind $hir $idxExpr] ne "const"} {
        return 0
    }
    set v [hir::get $hir $idxExpr value]
    if {[core::value::kind $v] ne "int"} {
        return 0
    }
    set idx [core::value::intOf $v]
    return [expr {$idx >= 0 && $idx < $n}]
}

# ---------------------------------------------------------------------------
# Companion demand propagation

# WANTS (a set, InstanceId -> 1) closed over FORWARD (Arities's forwarding
# edges): if C is wanted and C forwards to J, J is wanted too (its
# companion must exist for C's own companion to call).
proc hir::escape::Propagate {wants forward} {
    set changed 1
    while {$changed} {
        set changed 0
        dict for {id targets} $forward {
            if {![dict exists $wants $id]} {
                continue
            }
            foreach target $targets {
                if {![dict exists $wants $target]} {
                    dict set wants $target 1
                    set changed 1
                }
            }
        }
    }
    return $wants
}

# ---------------------------------------------------------------------------
# Parameter/result virtualization across closed calls
#
# Everything above this section is unchanged from the original local/remote
# scalar replacement: a fixed-shape List that is *constructed* locally or
# *returned* by a direct call may stay scalar. This section extends the same
# discipline across an exact closed call's *parameter* boundary too: a
# fixed-shape List value that a proven exact caller hands to a callee whose
# own uses of that parameter are themselves all structural (Classify/
# ScalarUse's same "list_get at a constant position" rule, plus a new
# supported use -- forwarding the same value, unchanged, as an argument to
# another exact closed call) need not be materialized at that boundary
# either: its fields cross as ordinary internal-call arguments instead (see
# native/lower.tcl's "Parameter virtualization" section for the lowering
# side -- a `fields` internal variant, built the same way native/lower.tcl
# already builds a scalar-replacement companion or a Block-virtualization
# internal variant: additively, alongside the instance's unconditionally
# still-emitted canonical function).
#
# Two passes, deliberately kept separate because they answer different
# questions (the milestone's #41: shape is a caller-proven *value* fact,
# never inferred merely from which indices a callee happens to read):
#
#   RawLocalArities / RawParamArities
#       *Which* slots (a local binding, or a parameter) provably carry a
#       fixed-shape value at all, and of what arity -- from real
#       constructions only: a `[e0..en-1]` literal, a call to an
#       instance whose own result Arities already recognizes, or (new)
#       an exact caller's own already-fixed-shape slot forwarded
#       unchanged. This is a monotonic (least-fixpoint) *growth*: once
#       some slot's shape is provable, it can be cited as a source for
#       another slot's shape, and so on along a chain of exact calls
#       (the milestone's #23's `caller(state) -> helper1(state) ->
#       helper2(state)` chain: `state`'s shape is immediate from its own
#       literal construction; helper1's own `state` parameter's shape
#       then follows from *that*, in a later round; helper2's parameter
#       follows from helper1's in a further round). It says nothing yet
#       about whether it is *safe* to actually represent that slot as
#       scalar fields -- only that, semantically, it always would be an
#       N-element List if it does exist.
#
#   Eligible
#       Of the slots RawLocalArities/RawParamArities found a shape for,
#       *which* are safe to actually virtualize: every reference to the
#       slot, within its own instance's region, is either a `list_get`
#       at a compile-time-constant in-range index, or the unchanged
#       forwarding of the same value (same position, no re-wrapping) as
#       an argument to another exact call whose own corresponding
#       parameter is *also* kept eligible with the *same* arity. This is
#       a monotonic *shrink* (a greatest fixpoint over the candidate set
#       RawLocalArities/RawParamArities already fixed): start optimistic
#       (every shaped slot is a candidate), then repeatedly drop any
#       candidate with an unsupported use, including a forwarding use
#       whose target has itself already been dropped -- exactly the
#       "all relevant uses compatible, or preserve the canonical
#       aggregate entirely" discipline #22 requires (never partial, never
#       a late-materializing branch). An out-of-range constant index
#       (#10) simply fails this check like any other unsupported use,
#       which correctly declines virtualization and so preserves the
#       real `list_get`'s ordinary runtime INDEX error.
#
# Multiple callers of the same parameter position (#42) are handled by
# RawParamArities requiring *every* exact call site's argument to classify
# to the identical arity before the parameter is even a candidate: any
# caller with an unclassifiable or differently-shaped argument silently
# withholds the fact, so the parameter simply never becomes eligible --
# not a partial/unsound virtualization for the callers that *do* agree, and
# not a special case, just the ordinary "no proof, no optimization" rule
# every pass in this file already follows. An unknown/open/dynamic caller
# (#43) is exactly the same case: since it is never present in any used
# instance's `calls` map (hir::specialize only records *exact* resolved
# direct calls there), it never contributes a proposed shape, so it can
# never itself cause an unsound assumption -- it just means the parameter
# it calls into, if some *other* exact caller's shape also fails to appear
# unanimously, is not virtualized; the canonical function remains exactly
# as callable as ever for it, unconditionally, the same fallback guarantee
# every other case in this module already has.
#
# `hir::escape::wants` is not extended to track this new "companion needed
# because some argument's classification was itself `remote`" case
# precisely: native/lower.tcl's CompanionRef/CompanionFunction path already
# builds an instance's companion purely on demand (gated only on
# `hir::escape::arity`, not on `wants` -- `wants` is bookkeeping for
# `explain`/diagnostics, never a lowering precondition), so no extra
# propagation is needed for correctness here.

# {CALLEE -> {{CALLER ARGEXPRS} ...}}: for every used instance CALLER, every
# direct call recorded in its own `hir::specialize` instance.calls map
# (i.e. every call HIR statically resolved to one exact callee instance),
# grouped by callee -- the reverse of Arities'/Classify's own forward
# `instance.calls` lookup, built once and reused by RawParamArities and (via
# REGIONS' own argPos) Eligible.
proc hir::escape::CallSites {hir spec} {
    set sites [dict create]
    foreach id [dict get $spec used] {
        set instance [dict get $spec instances $id]
        set calls [dict get $instance calls]
        if {![dict size $calls]} {
            continue
        }
        set view [hir::specialize::view $hir $spec $id]
        dict for {ce callee} $calls {
            set node [hir::node $view $ce]
            if {[dict get $node kind] ne "call"} {
                continue
            }
            dict lappend sites $callee [list $id [dict get $node args]]
        }
    }
    return $sites
}

# Per used instance ID: the same region-scanning facts Bindings computes
# (view, instance, region, exprs, trailing, captured, refsByBinding,
# listGetByArg), plus ARGPOS (ref ExprId -> {calleeInstanceOrEmpty
# argIndex}, for every `ref` used as a plain call argument anywhere in the
# region -- calleeInstanceOrEmpty is "" unless the call is itself an exact
# closed call HIR/specialize resolved). Computed once per instance and
# shared by RawLocalArities, RawParamArities and Eligible, so none of them
# re-scans the same region repeatedly.
proc hir::escape::RegionInfo {hir spec id} {
    set instance [dict get $spec instances $id]
    set block [dict get $instance block]
    set region [expr {$block eq "program" ? "program" : $block}]
    set view [hir::specialize::view $hir $spec $id]
    set context [dict get $spec context]
    set exprs [dict get $context exprs $region]
    set topBody [expr {$region eq "program" ? [hir::roots $view] : [hir::get $view $region body]}]
    set trailing [TrailingPositions $view $topBody $exprs]
    set captured [dict create]
    set refsByBinding [dict create]
    set listGetByArg [dict create]
    set argPos [dict create]
    foreach e $exprs {
        switch -- [hir::kind $view $e] {
            block {
                foreach b [hir::get $view $e captures] {
                    dict set captured $b 1
                }
            }
            ref {
                set b [hir::get $view $e binding]
                if {$b ne ""} {
                    dict lappend refsByBinding $b $e
                }
            }
            call {
                set node [hir::node $view $e]
                lassign [dict get $node target] targetKind target
                set args [dict get $node args]
                if {$targetKind eq "native" && [dict get [hir::symbol $view $target] name] eq "list_get"
                        && [llength $args] == 2} {
                    dict set listGetByArg [lindex $args 0] $e
                }
                set callee ""
                if {$targetKind eq "block" && [dict exists [dict get $instance calls] $e]} {
                    set callee [dict get [dict get $instance calls] $e]
                }
                set i 0
                foreach a $args {
                    if {[hir::kind $view $a] eq "ref"} {
                        dict set argPos $a [list $callee $i]
                    }
                    incr i
                }
            }
        }
    }
    return [dict create view $view instance $instance region $region exprs $exprs \
        trailing $trailing captured $captured refsByBinding $refsByBinding \
        listGetByArg $listGetByArg argPos $argPos]
}

# The arity a caller's argument expression E (in VIEW/INSTANCE, CALLERID's
# own region) proves for whatever parameter it is passed to, or "" if not
# (yet -- this may be asked again in a later RawParamArities round)
# provable: either a direct recognized construction (Classify -- a literal
# or a call to an already-arity'd instance), or a `ref` to a binding this
# same caller's own region already knows (RAWLOCAL/RAWPARAM, "so far": a
# growing set, safe to consult mid-fixpoint since both are monotonic
# growth-only facts, never revised).
proc hir::escape::ArgShape {view instance arity rawLocal rawParam callerId e} {
    set c [Classify $view $instance $arity $e]
    if {$c ne ""} {
        return [lindex $c 1]
    }
    if {[hir::kind $view $e] ne "ref"} {
        return ""
    }
    set b [hir::get $view $e binding]
    if {$b eq ""} {
        return ""
    }
    if {[dict exists $rawLocal $callerId $b]} {
        return [dict get $rawLocal $callerId $b]
    }
    if {[dict exists $rawParam $callerId $b]} {
        return [dict get $rawParam $callerId $b]
    }
    return ""
}

# {RESULT TARGETS}: RESULT is InstanceId -> BindingId -> N, for every local
# binding (kind local, non-duplicate, never captured by a nested block, not
# itself an implicit trailing return of its own scope -- the same
# structural preconditions the original local-only pass already required)
# whose bound value Classify recognizes, *regardless* of how its references
# go on to be used (a pure value-shape fact: see the file header above).
# TARGETS is InstanceId -> BindingId -> target InstanceId, for exactly the
# entries whose Classify was `remote` (their construction is itself a call
# to a companion-eligible instance) -- consulted only for `wants`
# bookkeeping (analyze, below); native/lower.tcl's own CompanionRef/
# CompanionFunction path never needs it (it builds a companion purely on
# demand from `arity`, not from `wants`).
proc hir::escape::RawLocalArities {hir spec arity regions} {
    set result [dict create]
    set targets [dict create]
    foreach id [dict get $spec used] {
        set info [dict get $regions $id]
        set view [dict get $info view]
        set instance [dict get $info instance]
        set trailing [dict get $info trailing]
        set captured [dict get $info captured]
        foreach e [dict get $info exprs] {
            if {[hir::kind $view $e] ne "bind"} {
                continue
            }
            set node [hir::node $view $e]
            if {[dict get $node duplicate] || [dict exists $trailing $e]} {
                continue
            }
            set b [dict get $node binding]
            if {[dict get [hir::binding $view $b] kind] ne "local" || [dict exists $captured $b]} {
                continue
            }
            set c [Classify $view $instance $arity [dict get $node value]]
            if {$c eq ""} {
                continue
            }
            lassign $c kind n target
            dict set result $id $b $n
            if {$kind eq "remote"} {
                dict set targets $id $b $target
            }
        }
    }
    return [list $result $targets]
}

# RAWPARAM: InstanceId -> BindingId -> N, for every parameter binding of a
# used, non-program instance every one of whose *exact* call sites
# (CALLSITES) proves, via ArgShape, the identical arity at that position --
# a pure value-shape fact (see the file header), independent of whether B's
# own uses, or any forwarding caller's own uses, are themselves structurally
# safe (Eligible decides that separately). An instance with no exact call
# sites at all (CALLSITES has no entry for it: every actual call reaching it
# is dynamic/indirect) never gets a parameter arity here, soundly (#43): no
# caller ever proved a shape for it.
proc hir::escape::RawParamArities {spec arity rawLocal callSites regions} {
    set result [dict create]
    set candidates [dict create]
    foreach id [dict get $spec used] {
        set instance [dict get $spec instances $id]
        set block [dict get $instance block]
        if {$block eq "program" || ![dict exists $callSites $id]} {
            continue
        }
        set info [dict get $regions $id]
        set params [hir::get [dict get $info view] $block params]
        set captured [dict get $info captured]
        set i 0
        foreach p $params {
            if {![dict exists $captured $p]} {
                dict set candidates [list $id $i] $p
            }
            incr i
        }
    }
    set changed 1
    while {$changed} {
        set changed 0
        dict for {key p} $candidates {
            lassign $key id i
            if {[dict exists $result $id $p]} {
                continue
            }
            set n ""
            set ok 1
            foreach site [dict get $callSites $id] {
                lassign $site callerId callerArgs
                if {$i >= [llength $callerArgs]} {
                    set ok 0
                    break
                }
                set argExpr [lindex $callerArgs $i]
                if {$callerId eq $id && [hir::kind [dict get $regions $id view] $argExpr] eq "ref"
                        && [hir::get [dict get $regions $id view] $argExpr binding] eq $p} {
                    # A same-instance (self-tail or otherwise recursive)
                    # call forwarding parameter P back to *itself*, at the
                    # *same* position, completely unchanged: this carries
                    # no new shape information (whatever N this parameter
                    # ends up with, forwarding its own already-N-shaped
                    # value back to itself is trivially still N) and, more
                    # importantly, can never be *the* proof this parameter
                    # needs -- requiring it to independently classify would
                    # make a self-threaded builder/state loop (the
                    # milestone's #25/#55) permanently unable to bootstrap
                    # its own parameter's arity, since RESULT (this same
                    # dict, still being computed) is exactly what its
                    # ref-case would need to already know. Skipped, not
                    # required to classify; some other, non-self-
                    # referential call site still must (a parameter with
                    # *only* self-referential call sites -- no real caller
                    # at all -- never gets an arity, soundly).
                    continue
                }
                set callerInfo [dict get $regions $callerId]
                set cn [ArgShape [dict get $callerInfo view] [dict get $callerInfo instance] $arity \
                    $rawLocal $result $callerId $argExpr]
                if {$cn eq ""} {
                    set ok 0
                    break
                }
                if {$n eq ""} {
                    set n $cn
                } elseif {$n ne $cn} {
                    set ok 0
                    break
                }
            }
            if {$ok && $n ne ""} {
                dict set result $id $p $n
                set changed 1
            }
        }
    }
    return $result
}

# The {InstanceId BindingId} -> N slots this milestone actually virtualizes:
# RAWLOCAL union RAWPARAM's shaped candidates, pruned to those whose every
# reference is a supported structural use (see the file header's
# description of this pass). Never partial: a slot with any unsupported use
# at all is dropped entirely, and every other slot whose only unsafe use was
# forwarding into a since-dropped slot is dropped too, by iterating to a
# fixed point.
proc hir::escape::Eligible {rawLocal rawParam regions} {
    set candidates [dict create]
    dict for {id bindings} $rawLocal {
        dict for {b n} $bindings {
            dict set candidates [list $id $b] $n
        }
    }
    dict for {id bindings} $rawParam {
        dict for {b n} $bindings {
            dict set candidates [list $id $b] $n
        }
    }
    set changed 1
    while {$changed} {
        set changed 0
        dict for {key n} $candidates {
            lassign $key id b
            if {![EligibleUse $candidates $regions $id $b $n]} {
                dict unset candidates $key
                set changed 1
            }
        }
    }
    return $candidates
}

# 1 if every reference to binding B (arity N) in instance ID's own region is
# a supported structural use, checked against the *current* CANDIDATES set
# (Eligible's caller re-runs this to a fixed point as CANDIDATES shrinks).
proc hir::escape::EligibleUse {candidates regions id b n} {
    set info [dict get $regions $id]
    set view [dict get $info view]
    set refsByBinding [dict get $info refsByBinding]
    set listGetByArg [dict get $info listGetByArg]
    set argPos [dict get $info argPos]
    set refs [expr {[dict exists $refsByBinding $b] ? [dict get $refsByBinding $b] : {}}]
    foreach r $refs {
        if {[dict exists $listGetByArg $r]} {
            if {![ScalarUse $view $listGetByArg $r $n]} {
                return 0
            }
            continue
        }
        if {[dict exists $argPos $r]} {
            lassign [dict get $argPos $r] callee argIndex
            if {$callee eq "" || ![dict exists $regions $callee]} {
                return 0
            }
            set calleeInfo [dict get $regions $callee]
            set calleeInstance [dict get $calleeInfo instance]
            set calleeBlock [dict get $calleeInstance block]
            if {$calleeBlock eq "program"} {
                return 0
            }
            set calleeParams [hir::get [dict get $calleeInfo view] $calleeBlock params]
            if {$argIndex < 0 || $argIndex >= [llength $calleeParams]} {
                return 0
            }
            set targetKey [list $callee [lindex $calleeParams $argIndex]]
            if {![dict exists $candidates $targetKey] || [dict get $candidates $targetKey] != $n} {
                return 0
            }
            continue
        }
        return 0
    }
    return 1
}

# ---------------------------------------------------------------------------
# Entry point

# The escape analysis of program HIR under specialization ANALYSIS
# (hir::specialize::analyze). Returns a dict:
#   arity         InstanceId -> N (see Arities)
#   wants         set (InstanceId -> 1) of instances to also emit a
#                 scalar-replacement companion function for (see Propagate)
#   virtual       InstanceId -> BindingId -> N, for a virtualized *local*
#                 binding (see Eligible)
#   paramVirtual  InstanceId -> BindingId -> N, for a virtualized
#                 *parameter* binding (see Eligible; native/lower.tcl's
#                 "Parameter virtualization" section builds an instance's
#                 `fields`/`fieldscompanion` internal variant from this)
proc hir::escape::analyze {hir spec {paramOpt 1}} {
    lassign [Arities $hir $spec] arity forward
    set regions [dict create]
    foreach id [dict get $spec used] {
        dict set regions $id [RegionInfo $hir $spec $id]
    }
    lassign [RawLocalArities $hir $spec $arity $regions] rawLocal localTargets
    set rawParam [dict create]
    if {$paramOpt} {
        set callSites [CallSites $hir $spec]
        set rawParam [RawParamArities $spec $arity $rawLocal $callSites $regions]
    }
    set eligible [Eligible $rawLocal $rawParam $regions]
    set virtual [dict create]
    set paramVirtual [dict create]
    set wants [dict create]
    dict for {key n} $eligible {
        lassign $key id b
        if {[dict exists $rawParam $id $b]} {
            dict set paramVirtual $id $b $n
        } else {
            dict set virtual $id $b $n
            if {[dict exists $localTargets $id $b]} {
                dict set wants [dict get $localTargets $id $b] 1
            }
        }
    }
    set wants [Propagate $wants $forward]
    return [dict create arity $arity wants $wants virtual $virtual paramVirtual $paramVirtual]
}

proc hir::escape::wants {analysis id} {
    return [dict exists $analysis wants $id]
}

proc hir::escape::arity {analysis id} {
    set arity [dict get $analysis arity]
    return [expr {[dict exists $arity $id] ? [dict get $arity $id] : ""}]
}

proc hir::escape::virtualArity {analysis id b} {
    set virtual [dict get $analysis virtual]
    if {[dict exists $virtual $id $b]} {
        return [dict get $virtual $id $b]
    }
    return ""
}

# Like virtualArity, for a *parameter* binding B of instance ID (Eligible's
# paramVirtual): N if B should be received as N ordinary field
# registers by ID's `fields`/`fieldscompanion` internal variant, "" if B
# stays an ordinary single-register (List) parameter.
proc hir::escape::paramVirtualArity {analysis id b} {
    set paramVirtual [dict get $analysis paramVirtual]
    if {[dict exists $paramVirtual $id $b]} {
        return [dict get $paramVirtual $id $b]
    }
    return ""
}

# 1 if instance ID has any virtualized parameter at all (native/lower.tcl
# consults this to decide whether to build ID's `fields`/`fieldscompanion`
# internal variant in the first place).
proc hir::escape::paramWants {analysis id} {
    return [dict exists $analysis paramVirtual $id]
}

# {InstanceId Label} pairs (hir::specialize::label) of every instance a
# companion function is built for, in a deterministic order: for
# explainability/reporting only (native.tcl, tests), never consulted by
# lowering itself.
proc hir::escape::wantedInstances {hir spec analysis} {
    set result {}
    foreach id [dict get $spec used] {
        if {[wants $analysis $id]} {
            lappend result [list $id [hir::specialize::label $spec $id] [arity $analysis $id]]
        }
    }
    return $result
}

# ---------------------------------------------------------------------------
# Human-readable explanation (derived from the analysis; never consulted by
# lowering, which asks `wants`/`arity`/`virtualArity`/`classify` directly)

# For each used instance, in program order: its recognized result shape (if
# any) and whether a scalar-replacement companion was built for it, then
# every local binding of its own region this analysis virtualized. This is
# a summary, not a per-blocker trace (the milestone's #40 explicitly allows
# skipping that level of detail): a binding or instance not listed here
# simply lowers exactly as it always did, for one of the reasons the file
# header enumerates (an escaping use, a dynamic index, an argument crossing
# a call boundary, a generic/indirect call, recursion with no base case, or
# any other shape this module does not specifically recognize).
proc hir::escape::explain {hir spec analysis} {
    set lines {}
    foreach id [dict get $spec used] {
        set n [arity $analysis $id]
        set bindings [expr {[dict exists [dict get $analysis virtual] $id]
            ? [dict get [dict get $analysis virtual] $id] : {}}]
        set params [expr {[dict exists [dict get $analysis paramVirtual] $id]
            ? [dict get [dict get $analysis paramVirtual] $id] : {}}]
        if {$n eq "" && $bindings eq "" && $params eq ""} {
            continue
        }
        lappend lines "[hir::specialize::label $spec $id] ($id):"
        if {$n ne ""} {
            lappend lines "  result shape: $n-element list[expr {[wants $analysis $id] ? \
                " (scalar-replacement companion built)" : " (recognized, but no caller demands a companion)"}]"
        }
        foreach {b bn} $params {
            lappend lines "  virtual parameter $b: $bn-element list, closed callers only (fields internal variant)"
        }
        foreach {b bn} $bindings {
            lappend lines "  virtual local $b: $bn-element list, never materialized"
        }
    }
    if {$lines eq ""} {
        return "no fixed-shape List aggregate was recognized"
    }
    return [join $lines \n]
}
