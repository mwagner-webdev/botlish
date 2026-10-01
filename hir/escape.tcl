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
# Value transport and materialization frontiers (VALUE-TRANSPORT-
# MATERIALIZATION.md): *how far* a virtual struct is carried as fields is a
# per-path decision, not a width cap. TransportPlan scores the exact-
# forwarding graph of virtual parameter slots by width x distance, argument and
# return edges weighted separately, a cycle with its own term (hir/transport.tcl),
# and denies a slot whose whole path exceeds its budget: the producer then
# materializes lazily, once, immediately before the first such edge (its
# earlier uses stay virtual) and passes one pointer. A result is recognized
# only while its return chain stays within the return budget (Arities). A
# nested struct literal is a value tree and the virtual form is a *cut*
# through it (NestingPlan): an inner value that is only ever projected is
# opened into the outer representation when its widened path still fits its
# budget, one that has an independent use stays one field. This file keeps
# its historical name; its responsibilities are now value representation and
# transport analysis rather than escape analysis proper (it also still answers
# the List and plan questions below).
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
# with any of: enabled (0|1); policy (transport | legacy); localWidth,
# returnWidth, argWidth (the *hard ceilings*: the widest struct, in fields,
# that may ever stay virtual as a local value, across an exact return and
# across an exact call); and the transport model's weights and budgets
# (hir/transport.tcl). Under policy legacy the three widths are the previous
# milestone's whole policy (16 / 8 / 4, STRUCT-SCALAR-REPLACEMENT.md, "Width
# policy"), kept as the comparison oracle; under transport they are safety
# ceilings and the decision is the score (VALUE-TRANSPORT-MATERIALIZATION.md).
proc hir::escape::StructOption {structOpts name} {
    if {[dict exists $structOpts $name]} {
        return [dict get $structOpts $name]
    }
    return [dict get {enabled 1} $name]
}

proc hir::escape::StructEnabled {structOpts} {
    return [StructOption $structOpts enabled]
}

# 1 under the legacy width-only policy.
proc hir::escape::LegacyPolicy {structOpts} {
    return [hir::transport::Legacy $structOpts]
}

# 1 if descriptor DESC fits the hard width ceiling of BOUNDARY (local |
# return | arg); a List is never capped here, and a boundary carries nothing
# of width 0. Under the transport policy this is only the safety ceiling: the
# per-path score (hir::transport) is the actual decision.
proc hir::escape::WidthOk {structOpts desc boundary} {
    if {[lindex $desc 1] eq ""} {
        return 1
    }
    set n [lindex $desc 0]
    if {$boundary ne "local" && $n < 1} {
        return 0
    }
    return [expr {$n <= [hir::transport::Ceiling $structOpts $boundary]}]
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

# {ARITY FORWARD WHY DEPTH}: ARITY is InstanceId -> DESC ({N SHAPE}, see
# Classify) for every used instance whose result is fully recognized (see the
# file header) and that the return policy accepts; FORWARD is InstanceId ->
# list of distinct target InstanceIds among its own forwarding exits (used to
# propagate companion demand in Wants below); WHY is InstanceId -> reason tag,
# for a used instance with struct exits whose result was *not* recognized
# ("width", "transport-budget", "mixed exits"): census bookkeeping only; DEPTH
# is InstanceId -> the number of exact return-forwarding edges below the
# instance's own boundary on its longest chain (0 when every exit builds its
# value itself), so a caller that consumes the result crosses DEPTH+1 return
# edges since the construction.
#
# The return policy is the legacy width cap (policy legacy) or the transport
# model's return verdict (width x return edges against the return budget,
# hir/transport.tcl) under a hard width ceiling. Results are acyclic by
# construction: an instance is recognized only through already-recognized
# targets, so the growth below is a well-founded order and DEPTH is final the
# moment an instance is recognized.
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
    set depth [dict create]
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
            set myDepth 0
            foreach t $targets {
                set myDepth [expr {max($myDepth, 1 + [dict get $depth $t])}]
            }
            if {$ok && $desc ne "" && ![WidthOk $structOpts $desc return]} {
                set ok 0
                set reason width
            }
            if {$ok && $desc ne "" && [lindex $desc 1] ne "" && ![LegacyPolicy $structOpts]} {
                if {![lindex [hir::transport::ReturnVerdict $structOpts [lindex $desc 0] $myDepth] 0]} {
                    set ok 0
                    set reason transport-budget
                }
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
                dict set depth $id $myDepth
                dict unset why $id
                set changed 1
            } elseif {$reason ne "" && [lsearch -exact [lmap x $exits {hir::kind $view $x}] struct] >= 0} {
                dict set why $id $reason
            }
        }
    }
    return [list $arity $forward $why $depth]
}

# InstanceId -> the number of return edges a value built by that instance's
# own exits crosses on its *longest* way up to a consumer: 1 for an instance
# nothing forwards through, 1 + that of the worst instance forwarding its
# result otherwise. ARITY's insertion order is the growth order (an instance
# is recognized after its forwarding targets), so one reverse pass is the
# whole computation. Audit/census: the recognition decision itself uses each
# instance's own depth (Arities).
proc hir::escape::RetTop {arity forward} {
    set top [dict create]
    foreach id [dict keys $arity] {
        dict set top $id 1
    }
    foreach id [lreverse [dict keys $arity]] {
        if {![dict exists $forward $id]} {
            continue
        }
        foreach t [dict get $forward $id] {
            set cand [expr {[dict get $top $id] + 1}]
            if {$cand > [dict get $top $t]} {
                dict set top $t $cand
            }
        }
    }
    return $top
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
# only -- never consulted by an eligibility decision except to distinguish a
# parameter the transport policy gave up on ("transport-budget": the exact
# callee exists and could receive fields, but carrying them that far costs
# more than the budget, so the value becomes one physical aggregate here --
# the materialization frontier) from one that simply cannot receive them
# ("call param"). DENY is the set of {InstanceId BindingId} parameter slots
# the transport plan denied (empty during the first Eligible pass).
proc hir::escape::UseTag {info r {regions {}} {deny {}}} {
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
                block  {
                    set calls [dict get [dict get $info instance] calls]
                    if {![dict exists $calls $pe]} {
                        return "open call"
                    }
                    set callee [dict get $calls $pe]
                    if {[dict size $deny] && [dict exists $regions $callee]} {
                        set i [lsearch -exact [dict get $node args] $r]
                        set cinfo [dict get $regions $callee]
                        set cblock [dict get [dict get $cinfo instance] block]
                        if {$cblock ne "program" && $i >= 0} {
                            set params [hir::get [dict get $cinfo view] $cblock params]
                            if {$i < [llength $params] && [dict exists $deny [list $callee [lindex $params $i]]]} {
                                return "transport-budget"
                            }
                        }
                    }
                    return "call param"
                }
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
proc hir::escape::UseVerdict {candidates regions aliasOf id b desc isParam bindExpr {deny {}}} {
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
        set tag [UseTag $info $r $regions $deny]
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
proc hir::escape::Eligible {rawLocal rawParam regions aliasOf {deny {}}} {
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
    # Slots the transport plan denied start out dropped (a monotone shrink:
    # nothing is ever re-admitted, so planning cannot oscillate).
    dict for {key reason} $deny {
        if {[dict exists $candidates $key]} {
            dict unset candidates $key
            dict set why $key $reason
        }
    }
    set changed 1
    while {$changed} {
        set changed 0
        dict for {key desc} $candidates {
            lassign $key id b
            set verdict [UseVerdict $candidates $regions $aliasOf $id $b $desc [dict exists $isParam $key] \
                [expr {[dict exists $bindExprs $key] ? [dict get $bindExprs $key] : ""}] $deny]
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
# Transport planning (VALUE-TRANSPORT-MATERIALIZATION.md)
#
# Eligible says which struct slots *may* stay virtual (every use is free or,
# for a local, lazily materializable). This pass asks the other question: how
# far may a value be carried as independent fields before one physical
# aggregate is cheaper to carry? It sees the exact-forwarding graph of the
# virtual *parameter* slots (a slot forwards its value unchanged to a callee
# slot = one argument edge; a call whose result feeds an argument crosses
# return edges first), summarizes it by strongly connected components
# (hir::transport::Plan: linear, no path enumerated) and gives every slot the
# score of the whole path through it: argument edges and return edges
# weighted separately, a cycle given its own term (a loop carries its value
# forever), scaled by use density. A slot whose path exceeds its budget is
# *denied*: its callers materialize the value before the first such edge --
# the frontier -- and pass one pointer, while the locals upstream keep every
# earlier use virtual (lazy single materialization) and a local's own
# projections never move. Only parameter slots are planned: a parameter never
# materializes inside its callee (a per-call allocation), so the frontier of
# a chain can only be at the producer's side of an edge, and a denied slot
# denies everything that forwards into it (Eligible's own shrink).
#
# Planning is two monotone phases, so it cannot oscillate: (1) structural
# eligibility, (2) a single budget pass over the eligible graph whose
# verdicts are final, followed by one more structural shrink. Nothing is ever
# re-admitted; a slot that falls only has fewer callers' fields to carry.
#
# Returns {DENY INFO}: DENY is {InstanceId BindingId} -> "transport-budget"
# for every denied slot, INFO the verdict dict of every planned slot
# (hir::transport::Plan's records).
proc hir::escape::TransportPlan {spec regions callSites arity retDepth eligible rawParam structOpts} {
    set nodes {}
    set width [dict create]
    dict for {key desc} $eligible {
        lassign $key id b
        if {[dict exists $rawParam $id $b] && [lindex $desc 1] ne ""} {
            lappend nodes $key
            dict set width $key [lindex $desc 0]
        }
    }
    if {$nodes eq ""} {
        return [list [dict create] [dict create]]
    }
    set fwd [dict create]
    set used [dict create]
    set supply [dict create]
    # The call graph of the used instances: a site inside a recursive cycle
    # carries its value around that cycle.
    set callSucc [dict create]
    dict for {callee sites} $callSites {
        foreach site $sites {
            dict lappend callSucc [lindex $site 0] $callee
        }
    }
    lassign [hir::transport::Scc [dict get $spec used] $callSucc] instComp - -
    foreach key $nodes {
        lassign $key id b
        set desc [dict get $eligible $key]
        set info [dict get $regions $id]
        set view [dict get $info view]
        set refs [expr {[dict exists [dict get $info refsByBinding] $b] ? [dict get [dict get $info refsByBinding] $b] : {}}]
        set layout [lindex $desc 1 1]
        set argPos [dict get $info argPos]
        set projByRecv [dict get $info projByRecv]
        set targets {}
        set slots {}
        foreach r $refs {
            if {[dict exists $projByRecv $r]} {
                set slot [lsearch -exact $layout [hir::get $view [dict get $projByRecv $r] name]]
                if {$slot >= 0} {
                    lappend slots $slot
                }
                continue
            }
            if {![dict exists $argPos $r]} {
                continue
            }
            lassign [dict get $argPos $r] callee argIndex
            if {$callee eq "" || ![dict exists $regions $callee]} {
                continue
            }
            set cblock [dict get [dict get $regions $callee instance] block]
            if {$cblock eq "program"} {
                continue
            }
            set cparams [hir::get [dict get $regions $callee view] $cblock params]
            if {$argIndex < 0 || $argIndex >= [llength $cparams]} {
                continue
            }
            set target [list $callee [lindex $cparams $argIndex]]
            if {[dict exists $eligible $target] && [dict get $eligible $target] eq $desc} {
                lappend targets $target
            }
        }
        dict set fwd $key [lsort -unique $targets]
        dict set used $key [lsort -unique -integer $slots]
        # Where the slot's value can come from.
        set index [lsearch -exact [hir::get $view [dict get [dict get $regions $id instance] block] params] $b]
        set entries {}
        if {[dict exists $callSites $id]} {
            foreach site [dict get $callSites $id] {
                lassign $site callerId callerArgs
                if {$index < 0 || $index >= [llength $callerArgs]} {
                    continue
                }
                set argExpr [lindex $callerArgs $index]
                set cinfo [dict get $regions $callerId]
                set cview [dict get $cinfo view]
                set recursive [expr {[dict get $instComp $callerId] == [dict get $instComp $id]}]
                if {[hir::kind $cview $argExpr] eq "ref"} {
                    set b2 [hir::get $cview $argExpr binding]
                    if {$callerId eq $id && $b2 eq $b} {
                        continue
                    }
                    set src [list $callerId $b2]
                    if {[dict exists $width $src] && [dict get $eligible $src] eq $desc} {
                        lappend entries [list $src 0 $recursive]
                    } elseif {[dict exists $eligible $src] && [dict get $eligible $src] eq $desc} {
                        lappend entries [list "" 0 $recursive]
                    }
                    continue
                }
                set c [Classify $cview [dict get $cinfo instance] $arity $argExpr $structOpts]
                if {$c eq ""} {
                    continue
                }
                lassign $c kind cd targetIds
                set ret 0
                foreach t $targetIds {
                    set ret [expr {max($ret, 1 + [dict get $retDepth $t])}]
                }
                lappend entries [list "" $ret $recursive]
            }
        }
        dict set supply $key $entries
    }
    set info [hir::transport::Plan $structOpts $nodes $fwd $supply $width $used]
    set deny [dict create]
    dict for {key v} $info {
        if {![dict get $v ok]} {
            dict set deny $key transport-budget
        }
    }
    return [list $deny $info]
}

# ---------------------------------------------------------------------------
# Nested values: the cut through the value tree (VALUE-TRANSPORT-
# MATERIALIZATION.md, "Nested value-tree model")
#
# A struct whose field is itself an inline struct literal is a tree. The
# virtual representation is a *cut* through it: every field below the cut is
# one transported value (the inner aggregate, still a physical object), every
# field above is opened (its own fields join the outer representation, so the
# outer width grows by the inner width less one). Nothing here recurses
# blindly: an inner value is a candidate for opening only if
#
#   * every construction that can flow into the slot builds it as an inline
#     literal of one shape (a shared or computed inner value is one opaque
#     field: no DAG scalarization), and
#   * it has no independent lifetime: every use of it, in every slot the value
#     travels through, is a further projection (`outer.inner.c`) -- an inner
#     value that is itself forwarded, stored, compared or returned stays a
#     bundle, however much some other use only projects it.
#
# The decision is one greedy pass per *representation class*: the slots
# (locals, parameters, results) a value moves between without being
# rebuilt -- bind, alias, exact argument forwarding, exact return -- are
# unioned, so the whole class shares one transported layout (a callee has
# one `fields` form, never a family). The pass walks the candidate inner
# values once, outermost first, and opens one only if the widened path still
# fits its budget (and the ceiling of every boundary the class touches) and
# opening costs less transport than the allocation it saves: at distance 0
# (a local) that is always, across a long argument chain it is not. No subset
# of cuts is ever enumerated.
#
# A cut is the flat list {NAME SUBSHAPE SUBCUT ...} over the opened fields in
# layout order; a descriptor with a cut is {N SHAPE CUT}, N the *physical*
# width (opened fields count as their own fields).

# The number of physical fields of struct SHAPE opened as CUT.
proc hir::escape::CutFields {shape cut} {
    set n [llength [lindex $shape 1]]
    foreach {name sub subcut} $cut {
        incr n [expr {[CutFields $sub $subcut] - 1}]
    }
    return $n
}

# 1 if struct node E of VIEW is a well-formed literal (every written field
# occupies exactly one slot of its layout; Classify's own condition).
proc hir::escape::WellFormedStruct {view e} {
    set node [hir::node $view $e]
    set n [llength [dict get $node fields]]
    return [expr {[llength [dict get $node layout]] == $n && [lsort -integer [dict get $node slots]] eq [Iota $n]}]
}

# {SHAPE CHILDREN}: struct literal E as a tree; CHILDREN maps a field name to
# the tree of that field's value when it is itself an inline well-formed
# literal.
proc hir::escape::LiteralTree {view e} {
    set node [hir::node $view $e]
    set shape [list [expr {[dict get $node named] ? [dict get $node structId] : ""}] [dict get $node layout]]
    set children [dict create]
    foreach name [dict get $node names] f [dict get $node fields] {
        if {[hir::kind $view $f] eq "struct" && [WellFormedStruct $view $f]} {
            dict set children $name [LiteralTree $view $f]
        }
    }
    return [list $shape $children]
}

# The intersection of two LiteralTrees of one root shape: a child survives
# only if both have it with the same shape.
proc hir::escape::IntersectTrees {a b} {
    lassign $a shape ca
    lassign $b shape2 cb
    set children [dict create]
    dict for {name t} $ca {
        if {[dict exists $cb $name] && [lindex $t 0] eq [lindex [dict get $cb $name] 0]} {
            dict set children $name [IntersectTrees $t [dict get $cb $name]]
        }
    }
    return [list $shape $children]
}

# The constructions expression E (of instance ID, VIEW) is made of when it is
# a recognized aggregate value: {lit ID E} for a struct literal, {res CALLEE}
# for an exact call to an instance with a recognized result, through `if`
# branches. "" if E is anything else.
proc hir::escape::Origins {view instance arity id e structOpts} {
    switch -- [hir::kind $view $e] {
        struct {
            if {[Classify $view $instance $arity $e $structOpts] eq ""} {
                return ""
            }
            return [list [list lit $id $e]]
        }
        call {
            set c [Classify $view $instance $arity $e $structOpts]
            if {[lindex $c 0] ne "remote"} {
                return ""
            }
            return [lmap t [lindex $c 2] {list res $t}]
        }
        if {
            set node [hir::node $view $e]
            set result {}
            foreach body [list [dict get $node thenBody] [dict get $node elseBody]] {
                if {$body eq ""} {
                    return ""
                }
                if {![hir::get $view [lindex $body 0] reachable]} {
                    continue
                }
                set last [lindex $body end]
                if {[hir::typeOf $view $last] eq "never"} {
                    continue
                }
                set o [Origins $view $instance $arity $id $last $structOpts]
                if {$o eq ""} {
                    return ""
                }
                lappend result {*}$o
            }
            return $result
        }
    }
    return ""
}

# Unions MEMBER with every construction in ORIGINS ({lit ID E} always; {res
# ID} only if that result is itself a member).
proc hir::escape::UnionOrigins {ufVar member origins} {
    upvar 1 $ufVar uf
    foreach o $origins {
        if {[lindex $o 0] eq "res" && ![dict exists $uf $o]} {
            continue
        }
        UfUnion uf $member $o
    }
}

proc hir::escape::UfFind {ufVar x} {
    upvar 1 $ufVar uf
    if {![dict exists $uf $x]} {
        dict set uf $x $x
        return $x
    }
    set root $x
    while {[dict get $uf $root] ne $root} {
        set root [dict get $uf $root]
    }
    while {[dict get $uf $x] ne $root} {
        set next [dict get $uf $x]
        dict set uf $x $root
        set x $next
    }
    return $root
}

proc hir::escape::UfUnion {ufVar a b} {
    upvar 1 $ufVar uf
    set ra [UfFind uf $a]
    set rb [UfFind uf $b]
    if {$ra ne $rb} {
        if {[string compare $ra $rb] < 0} {
            dict set uf $rb $ra
        } else {
            dict set uf $ra $rb
        }
    }
}

# Plans the cut of every representation class. ELIGIBLE: {InstanceId
# BindingId} -> natural DESC of every virtual slot (RAWPARAM says which are
# parameters); ARITY the recognized results; TRANSPORT the parameter slots'
# path statistics (hir::transport::Plan); RETDEPTH each result's return
# depth. Returns {CUTS CLASSES}: CUTS maps a member key ({loc ID B}, {par ID
# B} or {res ID}) to its non-empty cut; CLASSES is one record per class that
# has an inline nested literal: {members shape width0 width cut opened closed
# argEdges retEdges cyclic budget score}, closed being {PATH REASON} pairs.
proc hir::escape::NestingPlan {hir spec regions callSites arity retDepth eligible rawParam transport structOpts} {
    set uf [dict create]
    set context [dict get $spec context]
    set selfTails [dict get $context selfTails]
    # --- members and their unions
    dict for {key desc} $eligible {
        lassign $key id b
        if {[lindex $desc 1] eq ""} {
            continue
        }
        set k [list [expr {[dict exists $rawParam $id $b] ? "par" : "loc"}] $id $b]
        UfFind uf $k
    }
    dict for {id desc} $arity {
        if {[lindex $desc 1] ne ""} {
            UfFind uf [list res $id]
        }
    }
    set bindValues [dict create]
    foreach id [dict get $spec used] {
        set info [dict get $regions $id]
        set view [dict get $info view]
        foreach e [dict get $info exprs] {
            if {[hir::kind $view $e] eq "bind"} {
                set node [hir::node $view $e]
                if {![dict get $node duplicate]} {
                    dict set bindValues [list $id [dict get $node binding]] [dict get $node value]
                }
            }
        }
    }
    dict for {key desc} $eligible {
        lassign $key id b
        if {[lindex $desc 1] eq "" || [dict exists $rawParam $id $b]} {
            continue
        }
        set member [list loc $id $b]
        if {![dict exists $bindValues $key]} {
            continue
        }
        set v [dict get $bindValues $key]
        set info [dict get $regions $id]
        set view [dict get $info view]
        if {[hir::kind $view $v] eq "ref"} {
            set src [list $id [hir::get $view $v binding]]
            if {[dict exists $eligible $src] && ![dict exists $rawParam {*}$src]} {
                UfUnion uf $member [list loc {*}$src]
            }
            continue
        }
        UnionOrigins uf $member [Origins $view [dict get $info instance] $arity $id $v $structOpts]
    }
    dict for {key desc} $eligible {
        lassign $key id b
        if {[lindex $desc 1] eq "" || ![dict exists $rawParam $id $b] || ![dict exists $callSites $id]} {
            continue
        }
        set member [list par $id $b]
        set block [dict get $regions $id instance block]
        set index [lsearch -exact [hir::get [dict get $regions $id view] $block params] $b]
        foreach site [dict get $callSites $id] {
            lassign $site callerId callerArgs
            if {$index < 0 || $index >= [llength $callerArgs]} {
                continue
            }
            set argExpr [lindex $callerArgs $index]
            set cinfo [dict get $regions $callerId]
            set cview [dict get $cinfo view]
            if {[hir::kind $cview $argExpr] eq "ref"} {
                set src [list $callerId [hir::get $cview $argExpr binding]]
                if {[dict exists $eligible $src] && [dict get $eligible $src] eq $desc} {
                    UfUnion uf $member [list [expr {[dict exists $rawParam {*}$src] ? "par" : "loc"}] {*}$src]
                }
                continue
            }
            UnionOrigins uf $member [Origins $cview [dict get $cinfo instance] $arity $callerId $argExpr $structOpts]
        }
    }
    dict for {id desc} $arity {
        if {[lindex $desc 1] eq ""} {
            continue
        }
        set member [list res $id]
        set info [dict get $regions $id]
        set instance [dict get $info instance]
        set exits [Exits [dict get $info view] $context $instance $id [dict get $instance block] $selfTails]
        foreach e $exits {
            UnionOrigins uf $member [Origins [dict get $info view] $instance $arity $id $e $structOpts]
        }
    }
    # --- independent-use constraints: the outermost projection chains
    set blocked [dict create]
    foreach id [dict get $spec used] {
        set info [dict get $regions $id]
        set view [dict get $info view]
        set parent [dict get $info parent]
        foreach pe [dict values [dict get $info projByRecv]] {
            set up [expr {[dict exists $parent $pe] ? [dict get $parent $pe] : ""}]
            if {$up ne "" && [hir::kind $view $up] eq "project" && [hir::get $view $up receiver] eq $pe} {
                continue
            }
            # PE is the outermost projection of a chain: walk down to its root.
            set names {}
            set node $pe
            while {[hir::kind $view $node] eq "project"} {
                set names [linsert $names 0 [hir::get $view $node name]]
                set node [hir::get $view $node receiver]
            }
            set member ""
            if {[hir::kind $view $node] eq "ref"} {
                set b [hir::get $view $node binding]
                foreach kind {loc par} {
                    if {[dict exists $uf [list $kind $id $b]]} {
                        set member [list $kind $id $b]
                    }
                }
            } elseif {[hir::kind $view $node] eq "call"} {
                set c [Classify $view [dict get $info instance] $arity $node $structOpts]
                if {[lindex $c 0] eq "remote"} {
                    foreach t [lindex $c 2] {
                        dict lappend blocked [UfFind uf [list res $t]] $names
                    }
                }
            }
            if {$member ne ""} {
                dict lappend blocked [UfFind uf $member] $names
            }
        }
    }
    # --- classes
    set classes [dict create]
    foreach k [dict keys $uf] {
        dict lappend classes [UfFind uf $k] $k
    }
    set cuts [dict create]
    set records {}
    foreach root [lsort [dict keys $classes]] {
        set members [lsort [dict get $classes $root]]
        set tree ""
        set shape ""
        foreach k $members {
            if {[lindex $k 0] eq "lit"} {
                lassign $k - id e
                set t [LiteralTree [dict get $regions $id view] $e]
                set tree [expr {$tree eq "" ? $t : [IntersectTrees $tree $t]}]
            } else {
                set d [expr {[lindex $k 0] eq "res" ? [dict get $arity [lindex $k 1]] : [dict get $eligible [lrange $k 1 2]]}]
                if {$shape eq ""} {
                    set shape [lindex $d 1]
                }
            }
        }
        if {$tree eq "" || [dict size [lindex $tree 1]] == 0} {
            continue
        }
        # path statistics of the class
        set ea 0
        set er 0
        set cyc 0
        set ceiling [hir::transport::Ceiling $structOpts local]
        foreach k $members {
            switch -- [lindex $k 0] {
                par {
                    set tinfo [expr {[dict exists $transport [lrange $k 1 2]] ? [dict get $transport [lrange $k 1 2]] : {}}]
                    if {$tinfo ne ""} {
                        set ea [expr {max($ea, [dict get $tinfo up] + [dict get $tinfo down])}]
                        set er [expr {max($er, [dict get $tinfo ret])}]
                        set cyc [expr {$cyc || [dict get $tinfo cyclic]}]
                    }
                    set ceiling [expr {min($ceiling, [hir::transport::Ceiling $structOpts arg])}]
                }
                res {
                    set er [expr {max($er, [dict get $retDepth [lindex $k 1]] + 1)}]
                    set ceiling [expr {min($ceiling, [hir::transport::Ceiling $structOpts return])}]
                }
            }
        }
        set blockedPaths [expr {[dict exists $blocked $root] ? [dict get $blocked $root] : {}}]
        lassign [ChooseCut $structOpts $tree $blockedPaths $ceiling $ea $er $cyc] cut width0 width opened closed score budget
        if {$opened eq "" && $closed eq ""} {
            continue
        }
        foreach k $members {
            if {[lindex $k 0] ne "lit" && $cut ne ""} {
                dict set cuts $k $cut
            }
        }
        lappend records [dict create members [lmap k $members {if {[lindex $k 0] eq "lit"} continue; set k}] \
            literals [lmap k $members {if {[lindex $k 0] ne "lit"} continue; set k}] \
            shape [lindex $tree 0] width0 $width0 width $width cut $cut opened $opened closed $closed \
            argEdges $ea retEdges $er cyclic $cyc score $score budget $budget]
    }
    return [list $cuts $records]
}

# The greedy cut of TREE ({SHAPE CHILDREN}) for a class whose worst path has
# EA argument edges, ER return edges and CYC (0|1), under the hard width
# CEILING and the BLOCKED paths (lists of field names that have an
# independent use). Returns {CUT WIDTH0 WIDTH OPENED CLOSED SCORE BUDGET}:
# OPENED the opened paths, CLOSED {PATH REASON} for each candidate kept
# bundled (reasons: independent-use, ceiling, transport-budget,
# allocation-cheaper).
proc hir::escape::ChooseCut {structOpts tree blocked ceiling ea er cyc} {
    set width0 [llength [lindex $tree 0 1]]
    set budget [hir::transport::Budget $structOpts $ea $er $cyc]
    set state [dict create width $width0 opened {} closed {}]
    set cut [ChooseLevel $structOpts $tree {} $blocked $ceiling $ea $er $cyc $budget state]
    set width [dict get $state width]
    set score [hir::transport::PathScore $structOpts $width $ea $er $cyc 1.0]
    return [list $cut $width0 $width [dict get $state opened] [dict get $state closed] $score $budget]
}

proc hir::escape::ChooseLevel {structOpts tree prefix blocked ceiling ea er cyc budget stateVar} {
    upvar 1 $stateVar state
    set cut {}
    lassign $tree shape children
    foreach name [lindex $shape 1] {
        if {![dict exists $children $name]} {
            continue
        }
        set path [concat $prefix [list $name]]
        set sub [dict get $children $name]
        if {[lsearch -exact $blocked $path] >= 0} {
            dict lappend state closed [list $path independent-use]
            continue
        }
        set width [dict get $state width]
        set delta [expr {[llength [lindex $sub 0 1]] - 1}]
        set newWidth [expr {$width + $delta}]
        set cost [hir::transport::PathScore $structOpts $newWidth $ea $er $cyc 1.0]
        set base [hir::transport::PathScore $structOpts $width $ea $er $cyc 1.0]
        if {$newWidth > $ceiling} {
            dict lappend state closed [list $path ceiling]
            continue
        }
        if {$cost > $budget} {
            dict lappend state closed [list $path transport-budget]
            continue
        }
        if {$cost - $base >= [hir::transport::Option $structOpts allocUnits]} {
            dict lappend state closed [list $path allocation-cheaper]
            continue
        }
        dict set state width $newWidth
        dict lappend state opened $path
        set subcut [ChooseLevel $structOpts $sub $path $blocked $ceiling $ea $er $cyc $budget state]
        lappend cut $name [lindex $sub 0] $subcut
    }
    return $cut
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
    lassign [Arities $hir $spec $structOpts] arity forward resultWhy retDepth
    set retTop [RetTop $arity $forward]
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
    set transport [dict create]
    set deny [dict create]
    if {[StructEnabled $structOpts] && ![LegacyPolicy $structOpts]} {
        lassign [TransportPlan $spec $regions $callSites $arity $retDepth $eligible $rawParam $structOpts] deny transport
        if {[dict size $deny]} {
            lassign [Eligible $rawLocal $rawParam $regions $aliasOf $deny] eligible dropWhy useInfo
        }
    }
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
    # Nested values: the cut through each representation class's value tree
    # (NestingPlan), applied to the descriptors the lowering reads. Only under
    # the transport policy; the legacy policy keeps every nested struct one
    # field value.
    set nested {}
    if {[StructEnabled $structOpts] && ![LegacyPolicy $structOpts] && [hir::transport::Option $structOpts nesting]} {
        lassign [NestingPlan $hir $spec $regions $callSites $arity $retDepth $eligible $rawParam $transport $structOpts] cuts nested
        dict for {k cut} $cuts {
            switch -- [lindex $k 0] {
                loc {
                    set desc [dict get $virtual [lindex $k 1] [lindex $k 2]]
                    dict set virtual [lindex $k 1] [lindex $k 2] [list [CutFields [lindex $desc 1] $cut] [lindex $desc 1] $cut]
                }
                par {
                    set desc [dict get $paramVirtual [lindex $k 1] [lindex $k 2]]
                    dict set paramVirtual [lindex $k 1] [lindex $k 2] [list [CutFields [lindex $desc 1] $cut] [lindex $desc 1] $cut]
                }
                res {
                    set desc [dict get $arity [lindex $k 1]]
                    dict set arity [lindex $k 1] [list [CutFields [lindex $desc 1] $cut] [lindex $desc 1] $cut]
                }
            }
        }
    }
    set direct [DirectProjections $regions $arity $structOpts]
    set directRoot [DirectRoots $regions $arity $structOpts]
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
    dict for {id byExpr} $directRoot {
        dict for {e info} $byExpr {
            lassign $info root desc
            set view [dict get $regions $id view]
            set c [Classify $view [dict get $regions $id instance] $arity $root $structOpts]
            if {[lindex $c 0] eq "remote"} {
                foreach t [lindex $c 2] {
                    dict set wants $t 1
                }
            }
        }
    }
    set wants [Propagate $wants $forward]
    set analysis [dict create arity $arity wants $wants virtual $virtual paramVirtual $paramVirtual \
        structOpts $structOpts direct $direct directRoot $directRoot transport $transport deny $deny \
        retDepth $retDepth retTop $retTop nested $nested]
    if {[StructEnabled $structOpts]} {
        dict set analysis census [Census $spec $regions $arity $resultWhy $wants $virtual $paramVirtual \
            $localWhy $dropWhy $useInfo $structOpts [dict create deny $deny transport $transport \
            retDepth $retDepth retTop $retTop nested $nested]]
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

# InstanceId -> ExprId -> {ROOT DESC}: every field projection PE that is the
# outermost of a chain `root.f.g...` of two or more projections whose root is a
# recognized *call* result (a recognized construction read straight from its
# fields, with the descriptor -- cut included -- its slot carries). The
# chain is resolved to one field register in lowering (a field the cut
# opened is read from the sub-fields; a closed one by an ordinary structget).
proc hir::escape::DirectRoots {regions arity structOpts} {
    set direct [dict create]
    if {![StructEnabled $structOpts]} {
        return $direct
    }
    dict for {id info} $regions {
        set view [dict get $info view]
        set parent [dict get $info parent]
        foreach pe [dict values [dict get $info projByRecv]] {
            set up [expr {[dict exists $parent $pe] ? [dict get $parent $pe] : ""}]
            if {$up ne "" && [hir::kind $view $up] eq "project" && [hir::get $view $up receiver] eq $pe} {
                continue
            }
            set depth 0
            set node $pe
            while {[hir::kind $view $node] eq "project"} {
                set node [hir::get $view $node receiver]
                incr depth
            }
            if {$depth < 2 || [hir::kind $view $node] ne "call"} {
                continue
            }
            set c [Classify $view [dict get $info instance] $arity $node $structOpts]
            if {[lindex $c 0] ne "remote" || [lindex $c 1 1] eq ""} {
                continue
            }
            dict set direct $id $pe [list $node [lindex $c 1]]
        }
    }
    return $direct
}

# ---------------------------------------------------------------------------
# Census (audit only): one record per struct construction (a `struct` node of
# a used instance), saying what became of it, and why.
#
#   class       local     virtual, never leaves its function, never built
#               call      virtual, handed across exact calls as fields
#               return    a virtual exit of an instance whose result a caller
#                         consumes as fields (multi-value return)
#               materialized   built as a physical StructObj
#   mats        for a virtual construction, the tags of the uses that
#               materialize it later ("storage", "equality", ...)
#   reason      for a materialized one, the tag naming why
#
# The record is a dict: instance, label, expr, named (0|1), width N, class,
# reason, mats -- and, for the transport model (VALUE-TRANSPORT-
# MATERIALIZATION.md): where (the slot kind that carries it: local, param,
# result, direct, none), argEdges / retEdges / cyclic (the worst exact path
# its slot lies on: transport distance), score and budget (the pressure score
# of that path and the budget it was held to), live (fields ever read
# downstream), frontier (where it becomes physical: construction,
# before-first-call, before-long-forwarding-region, storage-boundary,
# open-call, control-merge, never), afterLocalUse (0|1: free local uses
# preceded the materialization), nested ("" | opened | closed:REASON, for a
# literal inside another literal), physical (physical structnew sites this
# construction accounts for), transportedWidth (physical width of the
# virtual form). Reason tags: storage (List/MutableArray/Set element),
# equality, hash, native call, open call (callvalue or unresolved target),
# call param (exact call, parameter not virtualizable), transport-budget
# (exact callee could take fields but the path is too costly), capture,
# width, loop (a physical use that would run per iteration), return
# (returned, no virtual consumer), mixed exits, nested field, control, other.
proc hir::escape::Census {spec regions arity resultWhy wants virtual paramVirtual localWhy dropWhy useInfo structOpts {ctx {}}} {
    set records {}
    set context [dict get $spec context]
    set selfTails [dict get $context selfTails]
    set deny [expr {[dict exists $ctx deny] ? [dict get $ctx deny] : {}}]
    set transport [expr {[dict exists $ctx transport] ? [dict get $ctx transport] : {}}]
    set retDepth [expr {[dict exists $ctx retDepth] ? [dict get $ctx retDepth] : {}}]
    set retTop [expr {[dict exists $ctx retTop] ? [dict get $ctx retTop] : {}}]
    set nested [expr {[dict exists $ctx nested] ? [dict get $ctx nested] : {}}]
    # literal origin -> its class record
    set literalClass [dict create]
    foreach rec $nested {
        foreach lit [dict get $rec literals] {
            dict set literalClass $lit $rec
        }
    }
    set byExpr [dict create]
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
            set structural 0
            set dest ""
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
                set dest [list res $id]
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
                set dest [list loc $id $b]
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
                if {$callee ne "" && $argIndex >= 0 && [dict exists $regions $callee]} {
                    set cblock [dict get [dict get $regions $callee instance] block]
                    set params [hir::get [dict get $regions $callee view] $cblock params]
                    if {$argIndex < [llength $params]} {
                        set dest [list par $callee [lindex $params $argIndex]]
                        set virtualParam [dict exists $paramVirtual $callee [lindex $params $argIndex]]
                    }
                }
                if {$virtualParam} {
                    set class call
                } else {
                    set reason [UseTag $info $v $regions $deny]
                }
            } elseif {$pkind eq "struct"} {
                set reason "nested field"
            } else {
                set reason [expr {$pe eq "" ? "other" : [UseTag $info $v $regions $deny]}]
            }
            set desc [list $n [list [expr {[dict get $node named] ? [dict get $node structId] : ""}] [dict get $node layout]]]
            set rec [dict create instance $id label [hir::specialize::label $spec $id] expr $e \
                named [dict get $node named] width $n class $class \
                reason [expr {$class eq "materialized" ? $reason : ""}] mats $mats \
                structural $structural dest $dest parentKind $pkind nested "" physical 0 transportedWidth $n \
                argEdges 0 retEdges 0 cyclic 0 score 0.0 budget 0.0 live $n where none]
            dict set byExpr [list $id $e] $rec
        }
    }
    # Transport facts of every record, then nested literals (a literal inside
    # another literal shares its outer's fate: opened into it, or a bundle).
    foreach key [lsort -dictionary [dict keys $byExpr]] {
        lassign $key id e
        set rec [dict get $byExpr $key]
        if {[dict get $rec parentKind] eq "struct"} {
            continue
        }
        set rec [CensusTransport $rec $id $regions $transport $retTop $structOpts $paramVirtual]
        set rec [CensusFrontier $rec]
        if {[dict exists $literalClass [list lit $id $e]]} {
            set cr [dict get $literalClass [list lit $id $e]]
            dict set rec transportedWidth [dict get $cr width]
        }
        dict set byExpr $key $rec
    }
    foreach key [lsort -dictionary [dict keys $byExpr]] {
        lassign $key id e
        set rec [dict get $byExpr $key]
        if {[dict get $rec parentKind] ne "struct"} {
            continue
        }
        set info [dict get $regions $id]
        set view [dict get $info view]
        set parent [dict get $info parent]
        # walk to the root literal, collecting the field path
        set path {}
        set node $e
        while {[dict exists $parent $node] && [dict get $parent $node] ne "" && [hir::kind $view [dict get $parent $node]] eq "struct"} {
            set up [dict get $parent $node]
            set names [hir::get $view $up names]
            set fields [hir::get $view $up fields]
            set path [linsert $path 0 [lindex $names [lsearch -exact $fields $node]]]
            set node $up
        }
        set outerKey [list $id $node]
        set outer [expr {[dict exists $byExpr $outerKey] ? [dict get $byExpr $outerKey] : {}}]
        set nestedTag "closed:independent-use"
        if {[dict exists $literalClass [list lit $id $node]]} {
            set cr [dict get $literalClass [list lit $id $node]]
            if {[lsearch -exact [dict get $cr opened] $path] >= 0} {
                set nestedTag opened
            } else {
                foreach pair [dict get $cr closed] {
                    if {[lindex $pair 0] eq $path} {
                        set nestedTag "closed:[lindex $pair 1]"
                    }
                }
            }
        } else {
            set nestedTag "closed:not-candidate"
        }
        dict set rec nested $nestedTag
        if {$nestedTag eq "opened" && $outer ne ""} {
            foreach k {class reason mats argEdges retEdges cyclic score budget where frontier afterLocalUse} {
                dict set rec $k [dict get $outer $k]
            }
        } else {
            dict set rec class materialized
            dict set rec reason "nested field"
            dict set rec frontier construction
            dict set rec afterLocalUse 0
        }
        dict set byExpr $key $rec
    }
    foreach key [lsort -dictionary [dict keys $byExpr]] {
        lappend records [Physical [dict get $byExpr $key]]
    }
    return $records
}

# The number of physical `structnew` sites a census record accounts for: a
# materialized construction builds one object at its frontier; a virtual one
# builds one only where a materializing use needs it (and then also one per
# inner value it opened, rebuilt there); a virtual one with no such use never
# builds any.
proc hir::escape::Physical {rec} {
    set n 0
    if {[dict get $rec class] eq "materialized"} {
        set n 1
    } elseif {[dict get $rec mats] ne ""} {
        set n 1
    }
    if {[dict get $rec nested] eq "opened"} {
        set n [expr {[dict get $rec mats] ne "" ? 1 : 0}]
    }
    dict set rec physical $n
    return $rec
}

# The forwarding parameter slots a local binding feeds (exact calls whose
# parameter receives it unchanged).
proc hir::escape::ForwardKeys {regions id b} {
    set info [dict get $regions $id]
    set refs [expr {[dict exists [dict get $info refsByBinding] $b] ? [dict get [dict get $info refsByBinding] $b] : {}}]
    set keys {}
    foreach r $refs {
        if {![dict exists [dict get $info argPos] $r]} {
            continue
        }
        lassign [dict get [dict get $info argPos] $r] callee argIndex
        if {$callee eq "" || ![dict exists $regions $callee]} {
            continue
        }
        set cblock [dict get [dict get $regions $callee instance] block]
        if {$cblock eq "program"} {
            continue
        }
        set params [hir::get [dict get $regions $callee view] $cblock params]
        if {$argIndex >= 0 && $argIndex < [llength $params]} {
            lappend keys [list $callee [lindex $params $argIndex]]
        }
    }
    return [lsort -unique $keys]
}

# Adds the path statistics (distance, direction, cycle, score, budget, live
# width) of the slot REC's construction is carried by.
proc hir::escape::CensusTransport {rec id regions transport retTop structOpts paramVirtual} {
    set dest [dict get $rec dest]
    if {$dest eq ""} {
        return $rec
    }
    set width [dict get $rec width]
    switch -- [lindex $dest 0] {
        res {
            dict set rec where result
            if {[dict exists $retTop $id]} {
                set edges [dict get $retTop $id]
                lassign [hir::transport::ReturnVerdict $structOpts $width [expr {$edges - 1}]] ok score budget edges
                dict set rec retEdges $edges
                dict set rec score $score
                dict set rec budget $budget
            }
        }
        par {
            dict set rec where param
            set key [lrange $dest 1 2]
            if {[dict exists $transport $key]} {
                set v [dict get $transport $key]
                dict set rec argEdges [expr {[dict get $v up] + [dict get $v down]}]
                dict set rec retEdges [dict get $v ret]
                dict set rec cyclic [dict get $v cyclic]
                dict set rec score [dict get $v score]
                dict set rec budget [dict get $v budget]
                dict set rec live [dict get $v used]
            }
        }
        loc {
            dict set rec where local
            set worst ""
            foreach key [ForwardKeys $regions $id [lindex $dest 2]] {
                if {![dict exists $transport $key]} {
                    continue
                }
                set v [dict get $transport $key]
                if {$worst eq "" || [dict get $v score] > [dict get $worst score]} {
                    set worst $v
                }
            }
            if {$worst ne ""} {
                dict set rec argEdges [expr {[dict get $worst up] + [dict get $worst down]}]
                dict set rec retEdges [dict get $worst ret]
                dict set rec cyclic [dict get $worst cyclic]
                dict set rec score [dict get $worst score]
                dict set rec budget [dict get $worst budget]
                dict set rec live [dict get $worst used]
            }
        }
    }
    return $rec
}

# The frontier (where the value becomes physical) of a census record.
proc hir::escape::CensusFrontier {rec} {
    set class [dict get $rec class]
    set mats [dict get $rec mats]
    set tag ""
    if {$class eq "materialized"} {
        set tag [dict get $rec reason]
    } elseif {$mats ne ""} {
        set tag [lindex $mats 0]
    }
    set after [expr {$class ne "materialized" && $mats ne "" && [dict get $rec structural] > 0}]
    if {$tag eq ""} {
        set frontier never
    } else {
        switch -- $tag {
            transport-budget { set frontier before-long-forwarding-region }
            "call param" - "call target" { set frontier before-first-call }
            storage { set frontier storage-boundary }
            "open call" - "native call" - equality - hash - capture - result - return { set frontier open-call }
            control - loop { set frontier control-merge }
            default { set frontier construction }
        }
        if {$class eq "materialized" && $frontier eq "before-first-call"} {
            set frontier construction
        }
    }
    dict set rec frontier $frontier
    dict set rec afterLocalUse $after
    return $rec
}

proc hir::escape::structOptsOf {analysis} {
    return [expr {[dict exists $analysis structOpts] ? [dict get $analysis structOpts] : {}}]
}

# The planning facts of ANALYSIS (audit only): {params RESULTS NESTED DENY}
# -- the path verdict of every planned parameter slot (hir::transport::Plan),
# the return verdict of every recognized struct result ({InstanceId -> dict
# of width depth edges score budget ok}), the nested value-tree classes
# (NestingPlan) and the denied parameter slots.
proc hir::escape::transportFacts {analysis} {
    set results [dict create]
    if {[dict exists $analysis retDepth]} {
        dict for {id depth} [dict get $analysis retDepth] {
            set desc [dict get $analysis arity $id]
            if {[lindex $desc 1] eq ""} {
                continue
            }
            set structOpts [structOptsOf $analysis]
            lassign [hir::transport::ReturnVerdict $structOpts [lindex $desc 0] $depth] ok score budget edges
            dict set results $id [dict create width [lindex $desc 0] depth $depth edges $edges score $score budget $budget ok $ok]
        }
    }
    return [dict create params [expr {[dict exists $analysis transport] ? [dict get $analysis transport] : {}}] \
        results $results nested [expr {[dict exists $analysis nested] ? [dict get $analysis nested] : {}}] \
        deny [expr {[dict exists $analysis deny] ? [dict get $analysis deny] : {}}]]
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

# The cut ({NAME SUBSHAPE SUBCUT ...}, "" when nothing is opened) of instance
# ID's recognized result, of virtual local B, of virtual parameter B.
proc hir::escape::resultCut {analysis id} {
    set arity [dict get $analysis arity]
    return [expr {[dict exists $arity $id] ? [lindex [dict get $arity $id] 2] : ""}]
}

proc hir::escape::virtualCut {analysis id b} {
    set virtual [dict get $analysis virtual]
    return [expr {[dict exists $virtual $id $b] ? [lindex [dict get $virtual $id $b] 2] : ""}]
}

proc hir::escape::paramVirtualCut {analysis id b} {
    set paramVirtual [dict get $analysis paramVirtual]
    return [expr {[dict exists $paramVirtual $id $b] ? [lindex [dict get $paramVirtual $id $b] 2] : ""}]
}

# {ROOT DESC} of field projection chain E of instance ID when its root is a
# recognized call result read straight from its fields (DirectRoots), "".
proc hir::escape::directRoot {analysis id e} {
    if {[dict exists $analysis directRoot $id $e]} {
        return [dict get $analysis directRoot $id $e]
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
