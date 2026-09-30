# escape.tcl -- conservative escape analysis and the facts native/lower.tcl's
# scalar replacement of fixed-shape immutable aggregates needs: positional
# `[e0, ..., en-1]` Lists and structs (STRUCT-SCALAR-REPLACEMENT.md).
#
#   set analysis [hir::escape::analyze $hir $spec ?paramOpt? ?structOpts?]
#   hir::escape::wants $analysis $instanceId          -> 0 | 1
#   hir::escape::arity $analysis $instanceId          -> N | ""
#   hir::escape::resultShape $analysis $instanceId    -> {ID LAYOUT} | ""
#   hir::escape::virtualArity $analysis $instanceId $bindingId  -> N | ""
#   hir::escape::virtualShape $analysis $instanceId $bindingId  -> {ID LAYOUT} | ""
#   hir::escape::paramVirtualArity $analysis $instanceId $bindingId  -> N | ""
#   hir::escape::paramVirtualShape $analysis $instanceId $bindingId  -> {ID LAYOUT} | ""
#   hir::escape::paramWants $analysis $instanceId     -> 0 | 1
#   hir::escape::directProjection $analysis $instanceId $e  -> {N SHAPE} | ""
#   hir::escape::census $analysis                     -> one record per struct construction
#   hir::escape::classify $hir $spec $analysis $instanceId $e   -> "" | {local DESC {}} | {remote DESC TARGETS}
#
# Aggregate kinds. One analysis serves both: its facts are *descriptors*
# {N SHAPE}: the field count, and the shape -- "" for a List, {ID LAYOUT}
# (declaration identity or "" for an anonymous struct, field names in slot
# order) for a struct, exactly the key native/lower.tcl's ShapeIndex interns
# runtime shapes by. A struct is easier than a List: its arity, its field
# slots and its immutability are static, so a projection `x.f` is always a
# structural use (the slot is fixed by the shape; a List needs a constant
# in-range index), and a struct that is *also* needed as a physical object at
# some use need not be given up: it stays virtual until that first use and is
# materialized there, once (UseVerdict; native/lower.tcl's
# MaterializeVirtual). A List keeps the original all-or-nothing rule.
#
# Semantic struct identity is never lost: the shape travels in the descriptor
# (named identity and anonymous field set alike), so a virtual struct that
# materializes is built with exactly the shape it would have had. Width is a
# policy, not a proof: STRUCTOPTS caps how wide a struct may be as a local
# value (16), across one exact return (8) and across one exact call (4)
# (StructOption), and the unspecialized baseline (`-specialize 0`) never
# carries a struct across a boundary as fields.
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

# "" | {local DESC {}} | {remote DESC TARGETS}: how expression E (in
# INSTANCE's region) builds a recognized fixed-shape aggregate, given ARITY
# (InstanceId -> DESC so far proven). DESC is {N SHAPE}: the field count and
# the aggregate's *shape* -- "" for a List (a positional `[e0, ..., en-1]`
# literal), {ID LAYOUT} for a struct (STRUCT-SCALAR-REPLACEMENT.md: the named
# declaration identity, "" when anonymous, and the slot-order field names --
# exactly what native/lower.tcl's ShapeIndex keys a runtime shape by). INSTANCE
# is INSTANCE's hir::specialize instance dict (for its `calls` map). Never
# true of anything but a direct call or a struct literal: a ref, a parameter,
# a merged/if-typed value, or any other expression shape is conservatively
# unrecognized, however its static type reads.
#
# A struct literal is recognized whenever STRUCTOPTS enables struct scalar
# replacement and the node is well formed (every written field occupies
# exactly one slot of its layout). Width policy is *not* applied here: the
# caller that binds, returns or passes the value applies the cap of its own
# boundary (local / return / argument).
proc hir::escape::Classify {hir instance arity e {structOpts {}}} {
    set kind [hir::kind $hir $e]
    if {$kind eq "struct"} {
        if {![StructEnabled $structOpts]} {
            return ""
        }
        set node [hir::node $hir $e]
        set n [llength [dict get $node fields]]
        set layout [dict get $node layout]
        if {[llength $layout] != $n || [lsort -integer [dict get $node slots]] ne [Iota $n]} {
            return ""
        }
        set id [expr {[dict get $node named] ? [dict get $node structId] : ""}]
        return [list local [list $n [list $id $layout]] {}]
    }
    if {$kind eq "if"} {
        return [ClassifyIf $hir $instance $arity $e $structOpts]
    }
    if {$kind ne "call"} {
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
        return [list local [list $n {}] {}]
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
        return [list remote [dict get $arity $callee] [list $callee]]
    }
    return ""
}

# An `if` expression whose every value-producing branch ends in a recognized
# *struct* construction of one descriptor (STRUCT-SCALAR-REPLACEMENT.md,
# "Branch merging"): the two branches' fields join field-wise instead of
# allocating in each branch and merging pointers. A branch that cannot
# complete (HIR proved it unreachable, or its last expression never
# completes: a `return`, a `fail`, a `break`) contributes no value. Lists are
# never recognized through an `if` (that would change their existing
# behavior). TARGETS lists every instance a branch's forwarding call demands
# a companion of.
proc hir::escape::ClassifyIf {hir instance arity e structOpts} {
    if {![StructEnabled $structOpts]} {
        return ""
    }
    set node [hir::node $hir $e]
    set desc ""
    set targets {}
    foreach body [list [dict get $node thenBody] [dict get $node elseBody]] {
        if {$body eq ""} {
            return ""
        }
        if {![hir::get $hir [lindex $body 0] reachable]} {
            continue
        }
        set last [lindex $body end]
        if {[hir::typeOf $hir $last] eq "never"} {
            continue
        }
        set c [Classify $hir $instance $arity $last $structOpts]
        if {$c eq ""} {
            return ""
        }
        lassign $c kind d t
        if {[lindex $d 1] eq ""} {
            return ""
        }
        if {$desc eq ""} {
            set desc $d
        } elseif {$desc ne $d} {
            return ""
        }
        lappend targets {*}$t
    }
    if {$desc eq ""} {
        return ""
    }
    return [list [expr {$targets eq "" ? "local" : "remote"}] $desc [lsort -unique $targets]]
}

# 0 1 ... N-1, as a list (for checking a struct node's slot permutation).
proc hir::escape::Iota {n} {
    set r {}
    for {set i 0} {$i < $n} {incr i} {
        lappend r $i
    }
    return $r
}

# The struct scalar-replacement options, with defaults. STRUCTOPTS is a dict
# with any of: enabled (0|1), localWidth, returnWidth, argWidth (the widest
# struct, in fields, that may stay virtual as a local value, across one exact
# return boundary, and across one exact call boundary respectively).
# STRUCT-SCALAR-REPLACEMENT.md, "Width policy".
proc hir::escape::StructOption {structOpts name} {
    if {[dict exists $structOpts $name]} {
        return [dict get $structOpts $name]
    }
    return [dict get {enabled 1 localWidth 16 returnWidth 8 argWidth 4} $name]
}

proc hir::escape::StructEnabled {structOpts} {
    return [StructOption $structOpts enabled]
}

# The width cap (fields) struct descriptor DESC has at BOUNDARY (local |
# return | arg), or 0 when DESC is not a struct (Lists are never capped here).
proc hir::escape::WidthOk {structOpts desc boundary} {
    if {[lindex $desc 1] eq ""} {
        return 1
    }
    set n [lindex $desc 0]
    if {$boundary ne "local" && $n < 1} {
        return 0
    }
    return [expr {$n <= [StructOption $structOpts ${boundary}Width]}]
}

# Public wrapper of Classify for native/lower.tcl: HIR is the *view* of
# instance ID (hir::specialize::view), matching how ANALYSIS itself examined
# it.
proc hir::escape::classify {hir spec analysis id e} {
    set instance [dict get $spec instances $id]
    return [Classify $hir $instance [dict get $analysis arity] $e [structOptsOf $analysis]]
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

# {ARITY FORWARD WHY}: ARITY is InstanceId -> DESC ({N SHAPE}, see Classify)
# for every used instance whose result is fully recognized (see the file
# header) and within the return width cap; FORWARD is InstanceId -> list of
# distinct target InstanceIds among its own forwarding exits (used to
# propagate companion demand in Wants below); WHY is InstanceId -> reason
# tag, for a used instance with struct exits whose result was *not*
# recognized ("width", "mixed exits"): census bookkeeping only.
proc hir::escape::Arities {hir spec {structOpts {}}} {
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
    set why [dict create]
    set changed 1
    while {$changed} {
        set changed 0
        dict for {id info} $candidates {
            if {[dict exists $arity $id]} {
                continue
            }
            lassign $info view instance exits
            set desc ""
            set ok 1
            set targets {}
            set reason ""
            foreach e $exits {
                set c [Classify $view $instance $arity $e $structOpts]
                if {$c eq ""} {
                    set ok 0
                    set reason "mixed exits"
                    break
                }
                lassign $c kind cd target
                if {$desc eq ""} {
                    set desc $cd
                } elseif {$desc ne $cd} {
                    set ok 0
                    set reason "mixed exits"
                    break
                }
                if {$kind eq "remote"} {
                    lappend targets {*}$target
                }
            }
            if {$ok && $desc ne "" && ![WidthOk $structOpts $desc return]} {
                set ok 0
                set reason width
            }
            if {$ok && $desc ne "" && [lindex $desc 1] ne "" && [dict get $instance generic]} {
                # The unspecialized baseline (`-specialize 0`) keeps its
                # known limitation for structs (STRUCTS.md, "Known
                # limitations"): a function whose struct operands are proven
                # only by semantic instances is not compiled generically, so
                # nothing crosses one of its boundaries as fields either.
                set ok 0
                set reason generic
            }
            if {$ok && $desc ne ""} {
                dict set arity $id $desc
                dict set forward $id [lsort -unique $targets]
                dict unset why $id
                set changed 1
            } elseif {$reason ne "" && [lsearch -exact [lmap x $exits {hir::kind $view $x}] struct] >= 0} {
                dict set why $id $reason
            }
        }
    }
    return [list $arity $forward $why]
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
    set projByRecv [dict create]
    set bindValue [dict create]
    foreach e $exprs {
        switch -- [hir::kind $view $e] {
            block {
                foreach b [hir::externalRefs $view $e] {
                    dict set captured $b 1
                }
            }
            project {
                dict set projByRecv [hir::get $view $e receiver] $e
            }
            bind {
                set v [hir::get $view $e value]
                if {[hir::kind $view $v] eq "ref"} {
                    dict set bindValue $v $e
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
    lassign [ParentsAndLoops $view $topBody] parent loopOf
    return [dict create view $view instance $instance region $region exprs $exprs \
        trailing $trailing captured $captured refsByBinding $refsByBinding \
        listGetByArg $listGetByArg argPos $argPos projByRecv $projByRecv \
        bindValue $bindValue parent $parent loopOf $loopOf]
}

# {PARENT LOOPOF} of the region whose top-level body is TOPBODY (VIEW): PARENT
# maps every sub-expression to the expression directly containing it, LOOPOF
# to the innermost loop / listloop / countloop expression it executes inside
# ("" outside every loop). A countloop's bounds and a listloop's iterable run
# once, outside the loop; nested blocks are other regions and are not entered.
# Iterative (an explicit stack): a region can be large.
proc hir::escape::ParentsAndLoops {view topBody} {
    set parent [dict create]
    set loopOf [dict create]
    set stack {}
    foreach e $topBody {
        lappend stack [list $e "" ""]
    }
    while {$stack ne ""} {
        lassign [lindex $stack end] e p loop
        set stack [lrange $stack 0 end-1]
        dict set parent $e $p
        dict set loopOf $e $loop
        set node [hir::node $view $e]
        switch -- [dict get $node kind] {
            block {
            }
            loop {
                foreach c [dict get $node body] {
                    lappend stack [list $c $e $e]
                }
            }
            listloop {
                lappend stack [list [dict get $node iterable] $e $loop]
                foreach c [dict get $node body] {
                    lappend stack [list $c $e $e]
                }
            }
            countloop {
                lappend stack [list [dict get $node start] $e $loop]
                lappend stack [list [dict get $node end] $e $loop]
                foreach c [dict get $node body] {
                    lappend stack [list $c $e $e]
                }
            }
            default {
                foreach c [hir::children $view $e] {
                    lappend stack [list $c $e $loop]
                }
            }
        }
    }
    return [list $parent $loopOf]
}

# The descriptor a caller's argument expression E (in VIEW/INSTANCE, CALLERID's
# own region) proves for whatever parameter it is passed to, or "" if not
# (yet -- this may be asked again in a later RawParamArities round)
# provable: either a direct recognized construction (Classify -- a literal
# or a call to an already-arity'd instance), or a `ref` to a binding this
# same caller's own region already knows (RAWLOCAL/RAWPARAM, "so far": a
# growing set, safe to consult mid-fixpoint since both are monotonic
# growth-only facts, never revised).
proc hir::escape::ArgShape {view instance arity rawLocal rawParam callerId e {structOpts {}}} {
    set c [Classify $view $instance $arity $e $structOpts]
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

# {RESULT TARGETS ALIASOF WHY}: RESULT is InstanceId -> BindingId -> DESC, for
# every local binding (kind local, non-duplicate, never captured by a nested
# block, not itself an implicit trailing return of its own scope -- the same
# structural preconditions the original local-only pass already required)
# whose bound value Classify recognizes, *regardless* of how its references
# go on to be used (a pure value-shape fact: see the file header above).
# TARGETS is InstanceId -> BindingId -> target InstanceId, for exactly the
# entries whose Classify was `remote` (their construction is itself a call
# to a companion-eligible instance) -- consulted only for `wants`
# bookkeeping (analyze, below); native/lower.tcl's own CompanionRef/
# CompanionFunction path never needs it (it builds a companion purely on
# demand from `arity`, not from `wants`).
#
# A *struct* binding may also be an alias of another shaped struct local
# (`b = a`, STRUCT-SCALAR-REPLACEMENT.md): it then carries A's descriptor;
# ALIASOF is InstanceId -> BindingId -> A. WHY is InstanceId -> BindingId ->
# reason tag for a struct value bound to a binding this pass could not shape
# (census bookkeeping only).
proc hir::escape::RawLocalArities {hir spec arity regions {structOpts {}}} {
    set result [dict create]
    set targets [dict create]
    set aliasOf [dict create]
    set why [dict create]
    foreach id [dict get $spec used] {
        set info [dict get $regions $id]
        set view [dict get $info view]
        set instance [dict get $info instance]
        set trailing [dict get $info trailing]
        set captured [dict get $info captured]
        set aliases {}
        foreach e [dict get $info exprs] {
            if {[hir::kind $view $e] ne "bind"} {
                continue
            }
            set node [hir::node $view $e]
            set valueExpr [dict get $node value]
            set c [Classify $view $instance $arity $valueExpr $structOpts]
            set isAlias [expr {$c eq "" && [StructEnabled $structOpts] && [hir::kind $view $valueExpr] eq "ref"}]
            if {$c eq "" && !$isAlias} {
                continue
            }
            set b [dict get $node binding]
            set structValue [expr {$c ne "" && [lindex $c 1 1] ne ""}]
            if {[dict get $node duplicate] || [dict exists $trailing $e]} {
                if {$structValue} {
                    dict set why $id $b control
                }
                continue
            }
            if {[dict get [hir::binding $view $b] kind] ne "local" || [dict exists $captured $b]} {
                if {$structValue} {
                    dict set why $id $b capture
                }
                continue
            }
            if {$isAlias} {
                lappend aliases [list $b [hir::get $view $valueExpr binding]]
                continue
            }
            lassign $c kind desc target
            if {![WidthOk $structOpts $desc local]} {
                dict set why $id $b width
                continue
            }
            dict set result $id $b $desc
            if {$kind eq "remote"} {
                dict set targets $id $b $target
            }
        }
        # Aliases of shaped struct locals, to a fixed point (chains).
        set changed 1
        while {$changed} {
            set changed 0
            foreach pair $aliases {
                lassign $pair b src
                if {$src eq "" || [dict exists $result $id $b] || ![dict exists $result $id $src]} {
                    continue
                }
                set desc [dict get $result $id $src]
                if {[lindex $desc 1] eq ""} {
                    continue
                }
                dict set result $id $b $desc
                dict set aliasOf $id $b $src
                set changed 1
            }
        }
    }
    return [list $result $targets $aliasOf $why]
}

# RAWPARAM: InstanceId -> BindingId -> DESC, for every parameter binding of a
# used, non-program instance every one of whose *exact* call sites
# (CALLSITES) proves, via ArgShape, the identical descriptor at that position
# and (for a struct) fits the argument width cap -- a pure value-shape fact
# (see the file header), independent of whether B's
# own uses, or any forwarding caller's own uses, are themselves structurally
# safe (Eligible decides that separately). An instance with no exact call
# sites at all (CALLSITES has no entry for it: every actual call reaching it
# is dynamic/indirect) never gets a parameter descriptor here, soundly (#43):
# no caller ever proved a shape for it.
proc hir::escape::RawParamArities {spec arity rawLocal callSites regions {structOpts {}}} {
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
                    # no new shape information (whatever descriptor this
                    # parameter ends up with, forwarding its own already-
                    # shaped value back to itself is trivially still that)
                    # and, more importantly, can never be *the* proof this
                    # parameter needs -- requiring it to independently
                    # classify would make a self-threaded builder/state
                    # loop (the milestone's #25/#55) permanently unable to
                    # bootstrap its own parameter's shape, since RESULT
                    # (this same dict, still being computed) is exactly
                    # what its ref-case would need to already know.
                    # Skipped, not required to classify; some other, non-
                    # self-referential call site still must (a parameter
                    # with *only* self-referential call sites -- no real
                    # caller at all -- never gets a descriptor, soundly).
                    continue
                }
                set callerInfo [dict get $regions $callerId]
                set cn [ArgShape [dict get $callerInfo view] [dict get $callerInfo instance] $arity \
                    $rawLocal $result $callerId $argExpr $structOpts]
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
            if {$ok && $n ne "" && [WidthOk $structOpts $n arg]
                    && !([lindex $n 1] ne "" && [dict get $spec instances $id generic])} {
                dict set result $id $p $n
                set changed 1
            }
        }
    }
    return $result
}

# The census tag of a struct value passed to the native named NAME, from the
# native's own registered runtime effects (never from its name): storage into
# a List, Set or MutableArray, equality, hashing, or any other native call.
proc hir::escape::NativeUseTag {name} {
    set runtime [dict get [core::native::metadata $name] runtime]
    foreach flag {list-alloc set-alloc mutarray-mutate} {
        if {$flag in $runtime} {
            return storage
        }
    }
    if {"structural-equality" in $runtime} {
        return equality
    }
    if {"hash" in $runtime} {
        return hash
    }
    return "native call"
}

# A short tag naming why reference R (a use of a struct value) needs the
# physical object: the kind of its parent expression. Census bookkeeping
# only -- never consulted by an eligibility decision.
proc hir::escape::UseTag {info r} {
    set view [dict get $info view]
    set parent [dict get $info parent]
    set pe [expr {[dict exists $parent $r] ? [dict get $parent $r] : ""}]
    if {$pe eq ""} {
        return [expr {[dict exists [dict get $info trailing] $r] ? "result" : "other"}]
    }
    switch -- [hir::kind $view $pe] {
        call {
            set node [hir::node $view $pe]
            lassign [dict get $node target] targetKind target
            if {[dict get $node callee] eq $r} {
                return "call target"
            }
            switch -- $targetKind {
                native { return [NativeUseTag [dict get [hir::symbol $view $target] name]] }
                block  { return [expr {[dict exists [dict get [dict get $info instance] calls] $pe] ? "call param" : "open call"}] }
            }
            return "open call"
        }
        return { return return }
        ok - error { return storage }
        struct { return "nested field" }
        bind   { return alias }
        if - loop - listloop - countloop - handle { return control }
    }
    return other
}

# {REASON STRUCTURAL FORWARDS MATS} for binding B (descriptor DESC) of
# instance ID against the *current* CANDIDATES set: REASON is "" when every
# reference is acceptable, otherwise a short tag naming the first one that is
# not. STRUCTURAL counts the references that cost nothing (a projection, an
# alias or an argument forwarded into another candidate), FORWARDS the
# argument forwards among them, MATS the tags of the references that need
# the physical object (struct locals only).
#
# A *List* candidate keeps the original rule exactly: every reference must
# be a `list_get` at a constant in-range index, or an unchanged forwarding
# into another candidate of the same descriptor.
#
# A *struct* local may also be materialized, lazily, at any reference that
# needs the object (STRUCT-SCALAR-REPLACEMENT.md, "Materialization model"),
# provided that reference runs as often as the binding itself (same
# innermost loop: never a per-iteration allocation of a value built once),
# and the binding has at least one free use (a value whose every use
# materializes it would only move the allocation, never remove it). A struct
# *parameter* never materializes: its callers hand it over as fields, so a
# use inside the callee that needs the object would re-allocate it once per
# call.
proc hir::escape::UseVerdict {candidates regions aliasOf id b desc isParam bindExpr} {
    set info [dict get $regions $id]
    set view [dict get $info view]
    set refsByBinding [dict get $info refsByBinding]
    set argPos [dict get $info argPos]
    set refs [expr {[dict exists $refsByBinding $b] ? [dict get $refsByBinding $b] : {}}]
    lassign $desc n shape
    set structural 0
    set forwards 0
    set mats {}
    if {$shape eq ""} {
        set listGetByArg [dict get $info listGetByArg]
        foreach r $refs {
            if {[dict exists $listGetByArg $r]} {
                if {![ScalarUse $view $listGetByArg $r $n]} {
                    return [list list-use 0 0 {}]
                }
                continue
            }
            if {[dict exists $argPos $r] && [ForwardTarget $candidates $regions $argPos $r $desc]} {
                continue
            }
            return [list list-use 0 0 {}]
        }
        return [list "" 0 0 {}]
    }
    set layout [lindex $shape 1]
    set projByRecv [dict get $info projByRecv]
    set bindValue [dict get $info bindValue]
    set loopOf [dict get $info loopOf]
    set bindLoop [expr {$bindExpr eq "" || ![dict exists $loopOf $bindExpr] ? "?" : [dict get $loopOf $bindExpr]}]
    foreach r $refs {
        if {[dict exists $projByRecv $r]} {
            set slot [lsearch -exact $layout [hir::get $view [dict get $projByRecv $r] name]]
            if {$slot < 0} {
                return [list projection 0 0 {}]
            }
            incr structural
            continue
        }
        if {[dict exists $argPos $r] && [ForwardTarget $candidates $regions $argPos $r $desc]} {
            incr structural
            incr forwards
            continue
        }
        if {[dict exists $bindValue $r]} {
            set b2 [hir::get $view [dict get $bindValue $r] binding]
            if {[dict exists $candidates [list $id $b2]] && [dict get $candidates [list $id $b2]] eq $desc
                    && [dict exists $aliasOf $id $b2] && [dict get $aliasOf $id $b2] eq $b} {
                incr structural
                continue
            }
        }
        set tag [UseTag $info $r]
        if {$isParam} {
            return [list $tag 0 0 {}]
        }
        if {![dict exists $loopOf $r] || [dict get $loopOf $r] ne $bindLoop} {
            return [list loop 0 0 {}]
        }
        lappend mats $tag
    }
    if {$mats ne "" && $structural == 0} {
        return [list [lindex $mats 0] 0 0 {}]
    }
    return [list "" $structural $forwards $mats]
}

# 1 if the reference R (a call argument, ARGPOS) is passed, unchanged, to an
# exact closed callee whose own corresponding parameter is a current
# candidate of the same descriptor DESC.
proc hir::escape::ForwardTarget {candidates regions argPos r desc} {
    lassign [dict get $argPos $r] callee argIndex
    if {$callee eq "" || ![dict exists $regions $callee]} {
        return 0
    }
    set calleeInfo [dict get $regions $callee]
    set calleeBlock [dict get [dict get $calleeInfo instance] block]
    if {$calleeBlock eq "program"} {
        return 0
    }
    set calleeParams [hir::get [dict get $calleeInfo view] $calleeBlock params]
    if {$argIndex < 0 || $argIndex >= [llength $calleeParams]} {
        return 0
    }
    set targetKey [list $callee [lindex $calleeParams $argIndex]]
    return [expr {[dict exists $candidates $targetKey] && [dict get $candidates $targetKey] eq $desc}]
}

# {CANDIDATES WHY USEINFO} -- the {InstanceId BindingId} -> DESC slots this
# milestone actually virtualizes: RAWLOCAL union RAWPARAM's shaped
# candidates, pruned to those whose every reference is acceptable
# (UseVerdict). Never partial: a slot with a use it cannot take is dropped
# entirely, and every other slot whose only unsafe use was forwarding into a
# since-dropped slot is dropped too, by iterating to a fixed point. A struct
# alias is dropped along with its source and vice versa (each is accepted
# only while the other stands). WHY maps a dropped slot to its reason tag,
# USEINFO a kept one to {STRUCTURAL FORWARDS MATS}.
proc hir::escape::Eligible {rawLocal rawParam regions aliasOf} {
    set candidates [dict create]
    set isParam [dict create]
    set bindExprs [dict create]
    dict for {id bindings} $rawLocal {
        dict for {b n} $bindings {
            dict set candidates [list $id $b] $n
        }
        set info [dict get $regions $id]
        set view [dict get $info view]
        foreach e [dict get $info exprs] {
            if {[hir::kind $view $e] eq "bind"} {
                dict set bindExprs [list $id [hir::get $view $e binding]] $e
            }
        }
    }
    dict for {id bindings} $rawParam {
        dict for {b n} $bindings {
            dict set candidates [list $id $b] $n
            dict set isParam [list $id $b] 1
        }
    }
    set why [dict create]
    set useInfo [dict create]
    set changed 1
    while {$changed} {
        set changed 0
        dict for {key desc} $candidates {
            lassign $key id b
            set verdict [UseVerdict $candidates $regions $aliasOf $id $b $desc [dict exists $isParam $key] \
                [expr {[dict exists $bindExprs $key] ? [dict get $bindExprs $key] : ""}]]
            lassign $verdict reason structural forwards mats
            if {$reason eq "" && [dict exists $aliasOf $id $b]
                    && ![dict exists $candidates [list $id [dict get $aliasOf $id $b]]]} {
                set reason alias
            }
            if {$reason ne ""} {
                dict unset candidates $key
                dict set why $key $reason
                set changed 1
            } else {
                dict set useInfo $key [list $structural $forwards $mats]
            }
        }
    }
    return [list $candidates $why $useInfo]
}

# ---------------------------------------------------------------------------
# Entry point

# The escape analysis of program HIR under specialization ANALYSIS
# (hir::specialize::analyze). STRUCTOPTS (see StructOption) configures struct
# scalar replacement. Returns a dict:
#   arity         InstanceId -> DESC ({N SHAPE}, see Classify; the public
#                 `arity`/`resultShape` accessors split it)
#   wants         set (InstanceId -> 1) of instances to also emit a
#                 scalar-replacement companion function for (see Propagate)
#   virtual       InstanceId -> BindingId -> DESC, for a virtualized *local*
#                 binding (see Eligible)
#   paramVirtual  InstanceId -> BindingId -> DESC, for a virtualized
#                 *parameter* binding (see Eligible; native/lower.tcl's
#                 "Parameter virtualization" section builds an instance's
#                 `fields`/`fieldscompanion` internal variant from this)
#   structOpts    the options the analysis ran under
#   direct        InstanceId -> ExprId -> DESC, for a field projection whose
#                 receiver is itself a recognized struct construction (a
#                 literal or an exact call): read straight from its fields
#   census        one record per struct construction (see Census)
proc hir::escape::analyze {hir spec {paramOpt 1} {structOpts {}}} {
    lassign [Arities $hir $spec $structOpts] arity forward resultWhy
    set regions [dict create]
    foreach id [dict get $spec used] {
        dict set regions $id [RegionInfo $hir $spec $id]
    }
    lassign [RawLocalArities $hir $spec $arity $regions $structOpts] rawLocal localTargets aliasOf localWhy
    set rawParam [dict create]
    set callSites {}
    if {$paramOpt} {
        set callSites [CallSites $hir $spec]
        set rawParam [RawParamArities $spec $arity $rawLocal $callSites $regions $structOpts]
    }
    lassign [Eligible $rawLocal $rawParam $regions $aliasOf] eligible dropWhy useInfo
    set virtual [dict create]
    set paramVirtual [dict create]
    set wants [dict create]
    dict for {key desc} $eligible {
        lassign $key id b
        if {[dict exists $rawParam $id $b]} {
            dict set paramVirtual $id $b $desc
        } else {
            dict set virtual $id $b $desc
            if {[dict exists $localTargets $id $b]} {
                foreach t [dict get $localTargets $id $b] {
                    dict set wants $t 1
                }
            }
        }
    }
    # A closed call's argument that is itself a recognized remote struct
    # result demands that callee's companion too.
    if {[StructEnabled $structOpts]} {
        dict for {callee sites} $callSites {
            foreach site $sites {
                lassign $site callerId callerArgs
                set callerInfo [dict get $regions $callerId]
                set calleeBlock [dict get $spec instances $callee block]
                if {$calleeBlock eq "program" || ![dict exists $paramVirtual $callee]} {
                    continue
                }
                set params [hir::get [dict get $regions $callee view] $calleeBlock params]
                set i 0
                foreach a $callerArgs {
                    if {$i < [llength $params] && [dict exists $paramVirtual $callee [lindex $params $i]]} {
                        set c [Classify [dict get $callerInfo view] [dict get $callerInfo instance] $arity $a $structOpts]
                        if {[lindex $c 0] eq "remote"} {
                            foreach t [lindex $c 2] {
                                dict set wants $t 1
                            }
                        }
                    }
                    incr i
                }
            }
        }
    }
    set direct [DirectProjections $regions $arity $structOpts]
    dict for {id byExpr} $direct {
        dict for {e desc} $byExpr {
            set view [dict get $regions $id view]
            set c [Classify $view [dict get $regions $id instance] $arity [hir::get $view $e receiver] $structOpts]
            if {[lindex $c 0] eq "remote"} {
                foreach t [lindex $c 2] {
                    dict set wants $t 1
                }
            }
        }
    }
    set wants [Propagate $wants $forward]
    set analysis [dict create arity $arity wants $wants virtual $virtual paramVirtual $paramVirtual \
        structOpts $structOpts direct $direct]
    if {[StructEnabled $structOpts]} {
        dict set analysis census [Census $spec $regions $arity $resultWhy $wants $virtual $paramVirtual \
            $localWhy $dropWhy $useInfo $structOpts]
    } else {
        dict set analysis census {}
    }
    return $analysis
}

# InstanceId -> ExprId -> DESC: every field projection `r.name` (r a struct
# literal or an exact call classified as a recognized struct result) whose
# receiver is a recognized construction and whose name is in its layout, at a
# width the local (literal) or return (call) cap accepts.
proc hir::escape::DirectProjections {regions arity structOpts} {
    set direct [dict create]
    if {![StructEnabled $structOpts]} {
        return $direct
    }
    dict for {id info} $regions {
        set view [dict get $info view]
        dict for {recv pe} [dict get $info projByRecv] {
            set c [Classify $view [dict get $info instance] $arity $recv $structOpts]
            if {$c eq ""} {
                continue
            }
            lassign $c kind desc target
            lassign $desc n shape
            if {$shape eq "" || [lsearch -exact [lindex $shape 1] [hir::get $view $pe name]] < 0} {
                continue
            }
            if {$kind eq "local" && ![WidthOk $structOpts $desc local]} {
                continue
            }
            dict set direct $id $pe $desc
        }
    }
    return $direct
}

# ---------------------------------------------------------------------------
# Census (audit only): one record per struct construction (a `struct` node of
# a used instance), saying what became of it.
#
#   class       local     virtual, never leaves its function, never built
#               call      virtual, handed across one exact call as fields
#               return    a virtual exit of an instance whose result a caller
#                         consumes as fields (multi-value return)
#               materialized   built as a physical StructObj
#   mats        for a virtual construction, the tags of the uses that
#               materialize it later ("storage", "equality", ...)
#   reason      for a materialized one, the tag naming why
#
# The record is a dict: instance, label, expr, named (0|1), width N, class,
# reason, mats. Reason tags: storage (List/MutableArray/Set element),
# equality, hash, native call, open call (callvalue or unresolved target),
# call param (exact call, parameter not virtualizable), capture, width,
# loop (a physical use that would run per iteration), return (returned, no
# virtual consumer), mixed exits, nested field, control, other.
proc hir::escape::Census {spec regions arity resultWhy wants virtual paramVirtual localWhy dropWhy useInfo structOpts} {
    set records {}
    set context [dict get $spec context]
    set selfTails [dict get $context selfTails]
    foreach id [dict get $spec used] {
        set info [dict get $regions $id]
        set view [dict get $info view]
        set instance [dict get $info instance]
        set exits {}
        set block [dict get $instance block]
        if {$block ne "program"} {
            set exits [Exits $view $context $instance $id $block $selfTails]
        }
        foreach e [dict get $info exprs] {
            if {[hir::kind $view $e] ne "struct"} {
                continue
            }
            set node [hir::node $view $e]
            set n [llength [dict get $node fields]]
            set class materialized
            set reason other
            set mats {}
            # The value root: a literal that ends a branch of an `if` that is
            # itself a value (a bound value, an exit, an argument) shares the
            # fate of that `if` (branch merging).
            set v $e
            set parent [dict get $info parent]
            while {[dict exists $parent $v] && [dict get $parent $v] ne ""
                    && [hir::kind $view [dict get $parent $v]] eq "if"} {
                set up [dict get $parent $v]
                set upNode [hir::node $view $up]
                set thenBody [dict get $upNode thenBody]
                set elseBody [dict get $upNode elseBody]
                if {$v ne [lindex $thenBody end] && $v ne [lindex $elseBody end]} {
                    break
                }
                set v $up
            }
            set pe [expr {[dict exists $parent $v] ? [dict get $parent $v] : ""}]
            set pkind [expr {$pe eq "" ? "" : [hir::kind $view $pe]}]
            if {[dict exists $context discarded $e]} {
                # Statement position, value unused: its fields are evaluated
                # for their effects and no object is built.
                set class local
            } elseif {$v in $exits || ($pkind eq "return")} {
                if {[dict exists $arity $id]} {
                    if {[dict exists $wants $id]} {
                        set class return
                    } else {
                        set reason "return"
                    }
                } elseif {[dict exists $resultWhy $id]} {
                    set reason [dict get $resultWhy $id]
                } else {
                    set reason "mixed exits"
                }
            } elseif {$pkind eq "project"} {
                set class local
            } elseif {$pkind eq "bind" && [hir::get $view $pe value] eq $v} {
                set b [hir::get $view $pe binding]
                if {[dict exists $virtual $id $b]} {
                    lassign [dict get $useInfo [list $id $b]] structural forwards mats
                    set class [expr {$forwards > 0 ? "call" : "local"}]
                } elseif {[dict exists $dropWhy [list $id $b]]} {
                    set reason [dict get $dropWhy [list $id $b]]
                } elseif {[dict exists $localWhy $id $b]} {
                    set reason [dict get $localWhy $id $b]
                } else {
                    set reason [expr {$v eq $e ? "other" : "control"}]
                }
            } elseif {$pkind eq "call"} {
                set argIndex [lsearch -exact [hir::get $view $pe args] $v]
                set callee [expr {[dict exists [dict get $instance calls] $pe] ? [dict get [dict get $instance calls] $pe] : ""}]
                set virtualParam 0
                if {$callee ne "" && $argIndex >= 0 && [dict exists $regions $callee]
                        && [dict exists $paramVirtual $callee]} {
                    set cblock [dict get [dict get $regions $callee instance] block]
                    set params [hir::get [dict get $regions $callee view] $cblock params]
                    set virtualParam [expr {$argIndex < [llength $params]
                        && [dict exists $paramVirtual $callee [lindex $params $argIndex]]}]
                }
                if {$virtualParam} {
                    set class call
                } else {
                    set reason [UseTag $info $v]
                }
            } elseif {$pkind eq "struct"} {
                set reason "nested field"
            } else {
                set reason [expr {$pe eq "" ? "other" : [UseTag $info $v]}]
            }
            set desc [list $n [list [expr {[dict get $node named] ? [dict get $node structId] : ""}] [dict get $node layout]]]
            lappend records [dict create instance $id label [hir::specialize::label $spec $id] expr $e \
                named [dict get $node named] width $n class $class \
                reason [expr {$class eq "materialized" ? $reason : ""}] mats $mats]
        }
    }
    return $records
}

proc hir::escape::structOptsOf {analysis} {
    return [expr {[dict exists $analysis structOpts] ? [dict get $analysis structOpts] : {}}]
}

# The census of ANALYSIS: one record per struct construction, see Census.
proc hir::escape::census {analysis} {
    return [expr {[dict exists $analysis census] ? [dict get $analysis census] : {}}]
}

proc hir::escape::wants {analysis id} {
    return [dict exists $analysis wants $id]
}

# The field count of instance ID's recognized result, or "".
proc hir::escape::arity {analysis id} {
    set arity [dict get $analysis arity]
    return [expr {[dict exists $arity $id] ? [lindex [dict get $arity $id] 0] : ""}]
}

# The shape ({ID LAYOUT}) of instance ID's recognized *struct* result, "" for
# a List result or no recognized result.
proc hir::escape::resultShape {analysis id} {
    set arity [dict get $analysis arity]
    return [expr {[dict exists $arity $id] ? [lindex [dict get $arity $id] 1] : ""}]
}

proc hir::escape::virtualArity {analysis id b} {
    set virtual [dict get $analysis virtual]
    if {[dict exists $virtual $id $b]} {
        return [lindex [dict get $virtual $id $b] 0]
    }
    return ""
}

# The struct shape ({ID LAYOUT}) of virtual local B of instance ID, "" for a
# List (or not virtual).
proc hir::escape::virtualShape {analysis id b} {
    set virtual [dict get $analysis virtual]
    if {[dict exists $virtual $id $b]} {
        return [lindex [dict get $virtual $id $b] 1]
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
        return [lindex [dict get $paramVirtual $id $b] 0]
    }
    return ""
}

proc hir::escape::paramVirtualShape {analysis id b} {
    set paramVirtual [dict get $analysis paramVirtual]
    if {[dict exists $paramVirtual $id $b]} {
        return [lindex [dict get $paramVirtual $id $b] 1]
    }
    return ""
}

# The descriptor ({N SHAPE}) of field projection E of instance ID when its
# receiver is a recognized struct construction read straight from its
# fields, "" otherwise.
proc hir::escape::directProjection {analysis id e} {
    if {[dict exists $analysis direct $id $e]} {
        return [dict get $analysis direct $id $e]
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
            lappend lines "  result shape: [DescName [dict get $analysis arity $id]][expr {[wants $analysis $id] ? \
                " (scalar-replacement companion built)" : " (recognized, but no caller demands a companion)"}]"
        }
        foreach {b desc} $params {
            lappend lines "  virtual parameter $b: [DescName $desc], closed callers only (fields internal variant)"
        }
        foreach {b desc} $bindings {
            lappend lines "  virtual local $b: [DescName $desc], never materialized eagerly"
        }
    }
    if {$lines eq ""} {
        return "no fixed-shape List or struct aggregate was recognized"
    }
    return [join $lines \n]
}

# "N-element list" or "struct NAME{f, g} (N fields)" for descriptor DESC.
proc hir::escape::DescName {desc} {
    lassign $desc n shape
    if {$shape eq ""} {
        return "$n-element list"
    }
    lassign $shape id layout
    return "[expr {$id eq "" ? "anonymous struct" : "struct $id"}]{[join $layout {, }]} ($n fields)"
}
