# escape.tcl -- conservative escape analysis and the facts native/lower.tcl's
# scalar replacement of fixed-shape immutable List aggregates needs.
#
#   set analysis [hir::escape::analyze $hir $spec]
#   hir::escape::wants $analysis $instanceId          -> 0 | 1
#   hir::escape::arity $analysis $instanceId          -> N | ""
#   hir::escape::virtualArity $analysis $instanceId $bindingId  -> N | ""
#   hir::escape::classify $hir $spec $analysis $instanceId $e   -> "" | {local N} | {remote N target}
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
# fall back to ordinary lowering. Passing such an aggregate as a plain call
# *argument* (rather than a call *result*) is also never recognized here --
# see the "structural blocker" this leaves for HashTable's rehash grouping,
# documented in native/lower.tcl.
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

# {VIRTUAL WANTS}: VIRTUAL is InstanceId -> BindingId -> N, for every local
# binding of every used instance that is bound (once, non-duplicate, kind
# local, never captured by a nested closure) to a recognized construction
# (Classify) all of whose references are `list_get(ref, constant)` at a
# position within its arity. WANTS is a set (InstanceId -> 1) of the
# instances directly demanded as a scalar-replacement-companion target by
# such a binding's remote construction.
proc hir::escape::Bindings {hir spec arity} {
    set context [dict get $spec context]
    set virtual [dict create]
    set wants [dict create]
    foreach id [dict get $spec used] {
        set instance [dict get $spec instances $id]
        set block [dict get $instance block]
        set region [expr {$block eq "program" ? "program" : $block}]
        set view [hir::specialize::view $hir $spec $id]
        set exprs [dict get $context exprs $region]
        set topBody [expr {$region eq "program" ? [hir::roots $view] : [hir::get $view $region body]}]
        # A bind expression at a trailing position (the region's own body,
        # or any nested if/loop body within it) is itself an implicit
        # "return" of its value out of that scope -- an escaping use no
        # `ref` node represents (see the file header's caution about not
        # confusing "no observed use" with "no use").
        set trailing [TrailingPositions $view $topBody $exprs]

        set captured [dict create]
        set refsByBinding [dict create]
        set listGetByArg [dict create]
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
                    if {$targetKind eq "native" && [dict get [hir::symbol $view $target] name] eq "list_get"
                            && [llength [dict get $node args]] == 2} {
                        dict set listGetByArg [lindex [dict get $node args] 0] $e
                    }
                }
            }
        }

        foreach e $exprs {
            if {[hir::kind $view $e] ne "bind"} {
                continue
            }
            set node [hir::node $view $e]
            if {[dict get $node duplicate]} {
                continue
            }
            if {[dict exists $trailing $e]} {
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
            set ok 1
            foreach r [expr {[dict exists $refsByBinding $b] ? [dict get $refsByBinding $b] : {}}] {
                if {![ScalarUse $view $listGetByArg $r $n]} {
                    set ok 0
                    break
                }
            }
            if {!$ok} {
                continue
            }
            dict set virtual $id $b $n
            if {$kind eq "remote"} {
                dict set wants $target 1
            }
        }
    }
    return [list $virtual $wants]
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
# Entry point

# The escape analysis of program HIR under specialization ANALYSIS
# (hir::specialize::analyze). Returns a dict:
#   arity     InstanceId -> N (see Arities)
#   wants     set (InstanceId -> 1) of instances to also emit a
#             scalar-replacement companion function for (see Propagate)
#   virtual   InstanceId -> BindingId -> N (see Bindings)
proc hir::escape::analyze {hir spec} {
    lassign [Arities $hir $spec] arity forward
    lassign [Bindings $hir $spec $arity] virtual wants
    set wants [Propagate $wants $forward]
    return [dict create arity $arity wants $wants virtual $virtual]
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
        if {$n eq "" && $bindings eq ""} {
            continue
        }
        lappend lines "[hir::specialize::label $spec $id] ($id):"
        if {$n ne ""} {
            lappend lines "  result shape: $n-element list[expr {[wants $analysis $id] ? \
                " (scalar-replacement companion built)" : " (recognized, but no caller demands a companion)"}]"
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
