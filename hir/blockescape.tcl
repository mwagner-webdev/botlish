# blockescape.tcl -- conservative escape analysis for locally-bound Block
# (closure) values that provably never escape, so native/lower.tcl may keep
# them as a code identity plus ordinary capture *values* instead of ever
# building a heap Block object.
#
#   set analysis [hir::blockescape::analyze $hir $spec]
#   hir::blockescape::virtual $analysis $instanceId $bindingId  -> "" | calleeInstanceId
#                       (non-empty: the binding is de-closure-converted; the
#                       instance named is one of its used instances -- a
#                       literal may have several, one per exact callable
#                       target, each call site names its own)
#   hir::blockescape::wants $analysis $calleeInstanceId          -> 0 | 1
#   hir::blockescape::captures $analysis $calleeInstanceId       -> BindingId list
#
# This is a *representation* analysis, in the same sense as hir/escape.tcl's
# List scalar replacement: nothing here changes what a Botlish Block means
# (still first-class: code plus captured lexical environment), HIR types, or
# hir/specialize.tcl's instances. It only proves, per used specialization
# instance, that a locally bound Block value is never observed except as the
# callee of a statically known direct call -- so native/lower.tcl may pass
# its captures as ordinary values to a capture-explicit internal variant of
# the callee, instead of ever calling `rt_closure_new` to build the
# canonical heap closure the generic Block ABI requires.
#
# de-closure conversion: transitive capture lifting
# ---------------------------------------------------
# The first implementation of this analysis (see git history) only ever
# recognized a binding B whose *every* reference lives in the very same
# region B itself is bound in, and declined outright the moment any
# reference could not be resolved that way -- in particular, both of the
# following, unconditionally:
#
#   * B is captured by another Block literal in the same region (i.e. some
#     sibling nested function C references B, and C is itself a value in
#     B's enclosing scope) -- even when every one of C's own references to
#     B, examined in C's own body, is itself nothing but an exact
#     matching-arity call.
#   * B is (directly or transitively) recursive: some reference to B's own
#     binding appears inside B's own body -- even when that reference,
#     too, is nothing but B's own exact self-tail or non-tail recursive
#     call.
#
# Both exclusions were sound but needlessly conservative: a Block whose
# *only* observers are exact, statically resolved calls -- whether those
# calls originate in the enclosing region, inside another sibling Block
# that is itself nonescaping, or inside the Block's own body (recursion) --
# never needs a real heap closure either. This is "de-closure conversion":
# capture lifting / closure scalar replacement, generalized to a bounded,
# single-region transitive fixpoint over a small graph of sibling
# candidates, rather than a purely local, single-binding proof.
#
# The algorithm, per used specialization instance I (I's own region R):
#
#   1. Candidates: every local, non-duplicate, non-trailing `bind` in R
#      whose value is a Block literal that itself needs an environment (an
#      envless/zero-capture literal is already free, via the pre-existing
#      fnvalue path -- see below). Exactly the original candidate set,
#      *minus* the automatic NeedsSelf exclusion.
#   2. For each candidate B (literal L, arity N), three kinds of reference
#      must each be proven to be nothing but an exact, N-argument call to
#      L's own single used specialize instance (RefsAsCalls below; no
#      reference at all is vacuously fine):
#        a. self references -- inside L's own body, a `ref` back to B
#           itself (recursion): must be exactly L's own recursive call.
#        b. external references -- inside R's own top-level exprs (the
#           same scope this original implementation always checked).
#        c. sibling references -- inside the body of any OTHER candidate C
#           in the same region R whose own Block literal captures B (i.e.
#           C calls B from within its own nested body): must be exactly a
#           call to B, AND C itself must be eligible (below) -- otherwise
#           C's own materialized closure would need a real B value to
#           capture, and B must materialize too.
#      Any other reference (return, store, comparison, argument to an
#      unrecognized call, a dynamic/generic call, capture by a Block this
#      analysis cannot itself vouch for) makes B ineligible, exactly as
#      before -- this module remains conservative and additive only.
#   3. Eligibility is a greatest fixpoint over the small candidate graph of
#      one region (2c's mutual dependency: B needs every sibling capturer
#      C to be eligible, and C's own eligibility can in turn depend on
#      further siblings) -- candidates are removed from the eligible set,
#      and the pass repeated, until no more can be removed.
#   4. Every eligible candidate's *flattened* capture list is computed
#      (FlattenBinding below): its own structurally captured bindings,
#      except that a captured binding which is itself an eligible
#      candidate is replaced, recursively, by *its own* flattened list
#      (in effect, capture lifting propagated through the closed call
#      chain: #7/#20 of this milestone), and a self-reference or a
#      reference to an envless (fnvalue) Block contributes nothing (no
#      value is ever needed for either). The result is deduplicated,
#      preserving first-occurrence order -- deterministic, since every
#      source list (hir::get's own `captures`) is itself deterministic.
#
# Consequences of the flattening (see native/lower.tcl's "Block
# virtualization" section for the lowering side): a candidate's own
# `virtualblock` local is no longer needed to *carry* captures forward
# (the original implementation's approach) -- since every reference to an
# eligible candidate is *already* known to be an exact call, and the
# candidate's own flattened captures are, by construction, always a subset
# of whatever bindings are already in scope wherever that call appears
# (the caller's own params, its own flattened captures, or plain
# already-bound region-local values), a call to a virtualized binding is
# lowered by resolving its flattened capture list fresh, in the calling
# function's own current scope, every time -- never by threading a stored
# value through an intervening `bind`. A `bind` of a virtualized candidate
# becomes, like an envless Block bound in statement position, a no-op: see
# the file header, and this makes recursion "free" too (2a above): a
# candidate's own recursive call, direct or self-tail, simply calls back
# into its own internal variant, passing its *own* current capture
# registers again -- no "self" (running-closure identity) value is ever
# asked for, since an eligible candidate's self reference is never used
# except as that one direct call target.
#
# What this module still declines outright, unchanged from the original
# implementation (the milestone's own scope limits, not omissions): a
# Block passed through another (possibly closed) function and proven not
# to escape there but not itself locally bound in the same region
# (interprocedural propagation beyond one region's own sibling graph);
# specializing an
# internal variant's own body differently per call site (one internal
# variant per callee instance, shared by every call site that demands it --
# a literal may have SEVERAL used instances, e.g. one per exact callable
# target it is called with (EXACT-CALLABLE-CLOSED-CALLER.md): every one of
# them gets its own internal variant, each call site naming its own
# instance, and every reference must resolve to one of them);
# mutual recursion between two DIFFERENT candidate bindings that are not
# simply "B calls A, A does not call B back" (the eligibility fixpoint
# only removes candidates, so a genuine A<->B value-capture cycle -- as
# opposed to a call cycle, which is fine -- can decline both, and does,
# conservatively). A Block literal with no captures at all is never a
# candidate here either: the existing envless/fnvalue path (native/
# lower.tcl's Closure) already calls it directly with zero allocation, so
# there is nothing for this analysis to add.

namespace eval hir::blockescape {
}

# 1 if any of block literal L's own captures is a binding bound (via
# hir::aot::BoundBlock) to L itself: L structurally captures its own
# identity (recursion), somewhere in its own body -- possibly nested
# inside a further closure of L's own, which RefsAsCalls's single-level
# check over L's *direct* exprs would not see (see the file header).
proc hir::blockescape::HasSelfCapture {view l} {
    foreach cb [hir::get $view $l captures] {
        if {[hir::aot::BoundBlock $view $cb] eq $l} {
            return 1
        }
    }
    return 0
}

# Every `ref` expression in EXPRLIST (view HIR, one region's own exprs) that
# refers to binding B must be exactly the callee of a call with ARITY
# arguments, resolved (via INSTANCE's own `calls` map -- callExprId ->
# callee InstanceId) to a target instance. Returns {OK TARGETS}: OK 0 if
# some reference fails this proof; OK 1 and TARGETS {} if no reference to B
# exists in EXPRLIST at all (vacuously fine); OK 1 and the sorted list of
# distinct callee instances otherwise. (Which of them are acceptable is the
# caller's question: every one must be an instance of B's own literal.)
proc hir::blockescape::RefsAsCalls {view context instance exprlist b arity} {
    set callees [dict get $context callees]
    set calls [dict get $instance calls]
    set targets {}
    foreach e $exprlist {
        if {[hir::kind $view $e] ne "ref" || [hir::get $view $e binding] ne $b} {
            continue
        }
        if {![dict exists $callees $e]} {
            return {0 {}}
        }
        set callExpr [dict get $callees $e]
        if {[llength [dict get [hir::node $view $callExpr] args]] != $arity} {
            return {0 {}}
        }
        if {![dict exists $calls $callExpr]} {
            return {0 {}}
        }
        lappend targets [dict get $calls $callExpr]
    }
    return [list 1 [lsort -unique $targets]]
}

# The used specialize instances of BLOCK a de-closure-converted binding of it
# may be called at: its non-generic used instances if it has any, otherwise
# its one generic instance if that is the only one, otherwise none (declined:
# a literal whose only instances are several generic ones does not exist,
# and a generic instance kept only so a canonical/materialized entry exists
# (hir/specialize.tcl's header: "a materialized Block retains a generic
# entry") is, whenever a specialized instance exists, never a call target of
# an eligible binding -- eligibility requires every reference to be an exact
# call, and exact calls select specialized instances). One literal commonly
# has several of them now: one per exact callable target it is called with,
# as before one per argument-kind key (hir/specialize.tcl).
proc hir::blockescape::RelevantInstances {spec block} {
    set found {}
    set nonGeneric {}
    foreach id [dict get $spec used] {
        set inst [dict get $spec instances $id]
        if {[dict get $inst block] eq $block} {
            lappend found $id
            if {![dict get $inst generic]} {
                lappend nonGeneric $id
            }
        }
    }
    if {[llength $nonGeneric]} {
        return $nonGeneric
    }
    return [expr {[llength $found] == 1 ? $found : {}}]
}

# The flattened, deduplicated capture list (BindingId list, first-occurrence
# order) of eligible candidate B (literal L, in region-view VIEW): every
# binding L structurally captures, except a self-reference (contributes
# nothing: an eligible candidate's own recursion needs no value) and a
# reference to an envless Block (fnvalue: already free, needs no capture --
# native/lower.tcl's BindingAccess draws the same distinction), and except
# that a captured binding which is itself an eligible candidate is replaced,
# recursively, by *its own* flattened list (capture lifting propagated
# through the closed call chain). MEMO (BindingId -> list) caches results
# within one region's pass; ELIGIBLE/CANDIDATES/LITTOBINDING describe that
# region's own candidate graph (see Bindings below).
proc hir::blockescape::FlattenBinding {view envless eligible candidates memoVar b} {
    upvar 1 $memoVar memo
    if {[dict exists $memo $b]} {
        return [dict get $memo $b]
    }
    # Cycle guard: a binding currently being flattened that recurs into
    # itself through some other candidate's captures (should not happen --
    # RefsAsCalls's sibling check requires a *call*, not a capture cycle --
    # but stay safe against any future relaxation).
    dict set memo $b {}
    set l [dict get $candidates $b]
    set result {}
    set seen [dict create]
    foreach cb [hir::get $view $l captures] {
        if {$cb eq $b} {
            continue
        }
        if {[dict exists $candidates $cb] && [dict exists $eligible $cb] && [dict get $eligible $cb]} {
            foreach x [FlattenBinding $view $envless $eligible $candidates memo $cb] {
                if {![dict exists $seen $x]} {
                    dict set seen $x 1
                    lappend result $x
                }
            }
            continue
        }
        set bound [hir::aot::BoundBlock $view $cb]
        if {$bound ne "" && $bound in $envless} {
            # fnvalue: an already environment-free callee, never a capture.
            continue
        }
        if {$bound ne "" && $bound eq $l} {
            # self, not yet caught by the $cb eq $b check above (a
            # forward-declared alias of the same binding): still nothing
            # to capture.
            continue
        }
        if {![dict exists $seen $cb]} {
            dict set seen $cb 1
            lappend result $cb
        }
    }
    dict set memo $b $result
    return $result
}

# 1 if some element of TARGETS is not in ALLOWED.
proc hir::blockescape::NotAllIn {targets allowed} {
    foreach t $targets {
        if {$t ni $allowed} {
            return 1
        }
    }
    return 0
}

# {VIRTUAL WANTS CAPTURES}: VIRTUAL is BindingId -> calleeInstanceId, for
# every local binding recognized as eligible per the file header. WANTS is a
# set (InstanceId -> 1) of the callee instances some such binding demands an
# internal (capture-explicit) variant for. CAPTURES is InstanceId ->
# flattened BindingId list (FlattenBinding), for every instance in WANTS.
proc hir::blockescape::Bindings {hir spec} {
    set context [dict get $spec context]
    set envless [dict get $context envless]
    set virtual [dict create]
    set wants [dict create]
    set flatCaptures [dict create]
    foreach id [dict get $spec used] {
        set instance [dict get $spec instances $id]
        set block [dict get $instance block]
        set region [expr {$block eq "program" ? "program" : $block}]
        set view [hir::specialize::view $hir $spec $id]
        set exprs [dict get $context exprs $region]
        set topBody [expr {$region eq "program" ? [hir::roots $view] : [hir::get $view $region body]}]
        # A bind at a trailing position is itself an implicit "return" of
        # its value out of that scope: a Block escaping that way must
        # materialize (reused verbatim from hir::escape.tcl).
        set trailing [hir::escape::TrailingPositions $view $topBody $exprs]

        # Candidates: BindingId -> Block literal ExprId.
        set candidates [dict create]
        set litToBinding [dict create]
        foreach e $exprs {
            if {[hir::kind $view $e] ne "bind"} {
                continue
            }
            set node [hir::node $view $e]
            if {[dict get $node duplicate] || [dict exists $trailing $e]} {
                continue
            }
            set b [dict get $node binding]
            if {[dict get [hir::binding $view $b] kind] ne "local"} {
                continue
            }
            set l [dict get $node value]
            if {[hir::kind $view $l] ne "block" || $l in $envless} {
                continue
            }
            dict set candidates $b $l
            dict set litToBinding $l $b
        }
        if {[dict size $candidates] == 0} {
            continue
        }

        # capturedBy: candidate BindingId -> list of capturing Block exprs
        # (any Block literal in this region whose own `captures` names it),
        # excluding the candidate's own literal (self, checked separately).
        set capturedBy [dict create]
        foreach e $exprs {
            if {[hir::kind $view $e] ne "block"} {
                continue
            }
            foreach cb [hir::get $view $e captures] {
                if {[dict exists $candidates $cb] && [dict get $candidates $cb] ne $e} {
                    dict lappend capturedBy $cb $e
                }
            }
        }

        # Eligibility: a greatest fixpoint over the candidate graph (see
        # the file header's #3).
        set eligible [dict create]
        set instancesOf [dict create]
        set arityOf [dict create]
        foreach {b l} $candidates {
            dict set eligible $b 1
            dict set instancesOf $b [RelevantInstances $spec $l]
            dict set arityOf $b [llength [hir::get $view $l params]]
        }
        set changed 1
        while {$changed} {
            set changed 0
            foreach {b l} $candidates {
                if {![dict get $eligible $b]} {
                    continue
                }
                set linsts [dict get $instancesOf $b]
                if {$linsts eq ""} {
                    dict set eligible $b 0
                    set changed 1
                    continue
                }
                set arity [dict get $arityOf $b]
                set ok 1
                # self references, inside L's own body, examined in every
                # used instance of L (each instance has its own `calls`).
                # Each must be a call to an instance of L. A self-reference
                # nested inside some further closure of L's own (rather
                # than directly in L's own body) is not examined by this
                # analysis (see the file header's scope limits): if L
                # structurally captures itself but no *direct* self-
                # reference-as-call was found, decline conservatively
                # rather than risk missing a genuine escaping use.
                set selfFound 0
                foreach linst $linsts {
                    lassign [RefsAsCalls $view $context [dict get $spec instances $linst] [dict get $context exprs $l] $b $arity] selfOk selfTargets
                    if {!$selfOk || [NotAllIn $selfTargets $linsts]} {
                        set ok 0
                        break
                    }
                    if {$selfTargets ne ""} {
                        set selfFound 1
                    }
                }
                if {$ok && !$selfFound && [HasSelfCapture $view $l]} {
                    set ok 0
                }
                # external references, in this region's own top exprs.
                set found 0
                if {$ok} {
                    lassign [RefsAsCalls $view $context $instance $exprs $b $arity] extOk extTargets
                    if {!$extOk || [NotAllIn $extTargets $linsts]} {
                        set ok 0
                    } elseif {$extTargets ne ""} {
                        set found 1
                    }
                }
                # sibling references, inside every candidate that captures B.
                if {$ok && [dict exists $capturedBy $b]} {
                    foreach ce [dict get $capturedBy $b] {
                        if {![dict exists $litToBinding $ce]} {
                            # An opaque capturer: some Block literal in
                            # this region captures B but is not itself a
                            # recognized local-bind candidate (e.g. an
                            # anonymous Block passed on as an argument, or
                            # one this analysis declined for its own
                            # reasons -- a returned/stored/duplicate bind).
                            # Its own use of B cannot be vouched for.
                            set ok 0
                            break
                        }
                        set cb [dict get $litToBinding $ce]
                        if {![dict get $eligible $cb]} {
                            set ok 0
                            break
                        }
                        set cinsts [dict get $instancesOf $cb]
                        if {$cinsts eq ""} {
                            set ok 0
                            break
                        }
                        # capturedBy already proves C's own literal
                        # structurally captures B; a *direct* reference
                        # inside C's own body (context.exprs[ce]) must
                        # therefore exist, in every used instance of C. If
                        # none is found there, the actual use is nested
                        # inside some further closure of C's own -- not
                        # examined by this analysis (the file header's scope
                        # limits) -- so decline conservatively.
                        foreach cinst $cinsts {
                            lassign [RefsAsCalls $view $context [dict get $spec instances $cinst] [dict get $context exprs $ce] $b $arity] cOk cTargets
                            if {!$cOk || $cTargets eq "" || [NotAllIn $cTargets $linsts]} {
                                set ok 0
                                break
                            }
                        }
                        if {!$ok} {
                            break
                        }
                        set found 1
                    }
                }
                # A candidate this analysis never observes any genuine
                # (external or sibling) call reference to at all -- e.g. a
                # binding reachable only through some other, out-of-band
                # mechanism this analysis does not model, such as the
                # native-to-module bridge (native/lower.tcl's
                # ModuleBridgeBinding) -- must not be virtualized: there is
                # nothing here proving every use is an exact call, only
                # that this analysis found none to check. A self-only
                # reference (checked above) does not by itself satisfy
                # this: a candidate with no external or sibling caller at
                # all is unreachable code, or reachable some other way this
                # analysis cannot vouch for -- either way, decline.
                if {$ok && !$found} {
                    set ok 0
                }
                if {!$ok} {
                    dict set eligible $b 0
                    set changed 1
                }
            }
        }

        set memo [dict create]
        foreach {b l} $candidates {
            if {![dict get $eligible $b]} {
                continue
            }
            set linsts [dict get $instancesOf $b]
            # VIRTUAL answers only "is this binding de-closure-converted"
            # (its first instance stands for it); each call site names its
            # own callee instance, and every used instance of the literal is
            # wanted, with the one flattened capture list a literal has.
            dict set virtual $b [lindex $linsts 0]
            set flat [FlattenBinding $view $envless $eligible $candidates memo $b]
            foreach linst $linsts {
                dict set wants $linst 1
                if {![dict exists $flatCaptures $linst]} {
                    dict set flatCaptures $linst $flat
                }
            }
        }
    }
    return [list $virtual $wants $flatCaptures]
}

# ---------------------------------------------------------------------------
# Entry point

# The Block-escape analysis of program HIR under specialization SPEC
# (hir::specialize::analyze). This module is independent of
# hir::stringregion.tcl: a candidate whose result some caller wants in
# StringRegion "region" form is no longer excluded here (see
# native/lower.tcl's "Block virtualization" section, "Composing with
# String regions") -- native/lower.tcl's Call
# resolves, per call site, whether an ordinary or region-result internal
# variant is what that particular use needs, using this analysis' `virtual`
# /`wants`/`captures` together with hir::stringregion::wants, never by this
# module declining a candidate on stringregion's behalf. Returns a dict:
#   virtual       BindingId -> calleeInstanceId (see Bindings)
#   wants         set (InstanceId -> 1) of callee instances to also emit a
#                 capture-explicit internal variant for
#   flatCaptures  InstanceId -> flattened BindingId list (see Bindings)
proc hir::blockescape::analyze {hir spec} {
    lassign [Bindings $hir $spec] virtual wants flatCaptures
    return [dict create virtual $virtual wants $wants flatCaptures $flatCaptures]
}

# Query is by BindingId alone: a local binding's identity is a structural
# HIR property, the same regardless of which specialize instance is
# currently being lowered (the enclosing region's own instance, or -- for a
# sibling/self reference resolved from *inside* another eligible
# candidate's own internal variant -- some other instance entirely). ID is
# accepted for call-site compatibility but not otherwise consulted.
proc hir::blockescape::virtual {analysis id b} {
    set virtual [dict get $analysis virtual]
    if {[dict exists $virtual $b]} {
        return [dict get $virtual $b]
    }
    return ""
}

proc hir::blockescape::wants {analysis id} {
    return [dict exists $analysis wants $id]
}

# The flattened capture BindingId list (Bindings/FlattenBinding) for callee
# instance ID -- only ever called for an ID hir::blockescape::wants is true
# for.
proc hir::blockescape::captures {analysis id} {
    set flatCaptures [dict get $analysis flatCaptures]
    if {[dict exists $flatCaptures $id]} {
        return [dict get $flatCaptures $id]
    }
    return {}
}

# {InstanceId Label} pairs (hir::specialize::label) of every instance an
# internal variant is built for, in a deterministic order: for
# explainability/reporting only, never consulted by lowering itself.
proc hir::blockescape::wantedInstances {hir spec analysis} {
    set result {}
    foreach id [dict get $spec used] {
        if {[wants $analysis $id]} {
            lappend result [list $id [hir::specialize::label $spec $id]]
        }
    }
    return $result
}

# ---------------------------------------------------------------------------
# Human-readable explanation (derived from the analysis; never consulted by
# lowering, which asks `virtual`/`wants`/`captures` directly)

proc hir::blockescape::explain {hir spec analysis} {
    set lines {}
    foreach pair [wantedInstances $hir $spec $analysis] {
        lassign $pair id label
        set captures [captures $analysis $id]
        set names [lmap b $captures {dict get [hir::binding $hir $b] name}]
        lappend lines "$label ($id): internal variant, captures \[[join $names {, }]\]"
    }
    if {$lines eq ""} {
        return "no nonescaping Block binding was recognized"
    }
    return [join $lines \n]
}
