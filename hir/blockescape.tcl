# blockescape.tcl -- conservative escape analysis for locally-bound Block
# (closure) values that provably never escape, so native/lower.tcl may keep
# them as a code identity plus ordinary capture *values* instead of ever
# building a heap Block object.
#
#   set analysis [hir::blockescape::analyze $hir $spec $stringregion]
#   hir::blockescape::virtual $analysis $instanceId $bindingId  -> "" | calleeInstanceId
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
#   1. Candidates: every local, non-duplicate, non-trailing, non-cell-
#      capturing `bind` in R whose value is a Block literal that itself
#      needs an environment (an envless/zero-capture literal is already
#      free, via the pre-existing fnvalue path -- see below) and does not
#      itself capture a forward-reference cell (NeedsCell, unchanged from
#      the original implementation: cells remain out of this analysis'
#      scope). Exactly the original candidate set, *minus* the automatic
#      NeedsSelf exclusion.
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
# (interprocedural propagation beyond one region's own sibling graph); a
# capture that needs a forward-reference cell (NeedsCell); specializing an
# internal variant's own body differently per call site (one internal
# variant per callee instance, shared by every call site that demands it);
# mutual recursion between two DIFFERENT candidate bindings that are not
# simply "B calls A, A does not call B back" (the eligibility fixpoint
# only removes candidates, so a genuine A<->B value-capture cycle -- as
# opposed to a call cycle, which is fine -- can decline both, and does,
# conservatively); a Block with more than one used specialize instance in
# a role this analysis needs a single instance for (declined outright,
# conservatively). A Block literal with no captures at all is never a
# candidate here either: the existing envless/fnvalue path (native/
# lower.tcl's Closure) already calls it directly with zero allocation, so
# there is nothing for this analysis to add.

namespace eval hir::blockescape {
}

# 1 if any of block literal L's own captures is a binding CONTEXT (hir::aot
# ::context) marks as needing a forward-reference cell. Such a capture is
# the cell's own reference, not an ordinary already-resolved value
# (native/lower.tcl's Closure captures the cell itself for these): out of
# scope for this implementation (see the file header), so a candidate
# capturing one is conservatively declined.
proc hir::blockescape::NeedsCell {hir context l} {
    set cells [dict get $context cells]
    foreach cb [hir::get $hir $l captures] {
        if {[dict exists $cells $cb]} {
            return 1
        }
    }
    return 0
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
# callee InstanceId) to one consistent target instance. Returns {OK TARGET}:
# OK 0 if some reference fails this proof; OK 1 and TARGET "" if no
# reference to B exists in EXPRLIST at all (vacuously fine); OK 1 and TARGET
# set to the single consistent callee instance otherwise.
proc hir::blockescape::RefsAsCalls {view context instance exprlist b arity} {
    set callees [dict get $context callees]
    set calls [dict get $instance calls]
    set target ""
    foreach e $exprlist {
        if {[hir::kind $view $e] ne "ref" || [hir::get $view $e binding] ne $b} {
            continue
        }
        if {![dict exists $callees $e]} {
            return {0 ""}
        }
        set callExpr [dict get $callees $e]
        if {[llength [dict get [hir::node $view $callExpr] args]] != $arity} {
            return {0 ""}
        }
        if {![dict exists $calls $callExpr]} {
            return {0 ""}
        }
        set t [dict get $calls $callExpr]
        if {$target eq ""} {
            set target $t
        } elseif {$target ne $t} {
            return {0 ""}
        }
    }
    return [list 1 $target]
}

# The BLOCK's own single used specialize instance id, or "" if this
# analysis cannot settle on one. hir/specialize.tcl's own header notes "a
# materialized Block retains a generic entry": a Block literal that is ever
# a candidate here routinely has *two* used instances even when only one is
# ever actually a call target -- a specialized (non-generic) instance real
# calls resolve to, plus an always-present generic one kept only so a
# canonical/materialized entry exists (hir::aot::materializedBlocks),
# typically with an empty `calls` map of its own (nothing was ever
# analyzed calling out of it). So: if there is exactly one *non-generic*
# used instance, that is L's target, regardless of how many generic
# siblings coexist; otherwise, if there is exactly one used instance in
# all (no specialization occurred), use that; otherwise decline (a
# candidate whose literal is polymorphic across several genuinely distinct
# used instances needs one canonical target/capture shape this analysis
# does not attempt to choose between).
proc hir::blockescape::SingleInstance {spec block} {
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
    if {[llength $nonGeneric] == 1} {
        return [lindex $nonGeneric 0]
    }
    return [expr {[llength $found] == 1 ? [lindex $found 0] : ""}]
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

# {VIRTUAL WANTS CAPTURES}: VIRTUAL is BindingId -> calleeInstanceId, for
# every local binding recognized as eligible per the file header. WANTS is a
# set (InstanceId -> 1) of the callee instances some such binding demands an
# internal (capture-explicit) variant for. CAPTURES is InstanceId ->
# flattened BindingId list (FlattenBinding), for every instance in WANTS.
proc hir::blockescape::Bindings {hir spec stringregion} {
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
            if {[dict get [hir::binding $view $b] kind] ne "local"
                    || [dict exists [dict get $context cells] $b]} {
                continue
            }
            set l [dict get $node value]
            if {[hir::kind $view $l] ne "block" || $l in $envless} {
                continue
            }
            if {[NeedsCell $view $context $l]} {
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
        set singleInstance [dict create]
        set arityOf [dict create]
        foreach {b l} $candidates {
            dict set eligible $b 1
            dict set singleInstance $b [SingleInstance $spec $l]
            dict set arityOf $b [llength [hir::get $view $l params]]
        }
        set changed 1
        while {$changed} {
            set changed 0
            foreach {b l} $candidates {
                if {![dict get $eligible $b]} {
                    continue
                }
                set linst [dict get $singleInstance $b]
                if {$linst eq "" || [hir::stringregion::wants $stringregion $linst]} {
                    # hir::stringregion.tcl already proved some caller
                    # asks for THIS instance's result in region form (a
                    # base/start/end triple: e.g. an immediate `==`/
                    # `length`/classification consumer, hir/stringregion
                    # .tcl's own Class A/B/C) -- native/lower.tcl's Call
                    # always reaches such a use through the instance's
                    # *canonical*, closure-taking region companion
                    # (`callenvmulti`, a real captured environment
                    # register), never a capture-explicit internal
                    # variant, so this candidate must stay materialized
                    # for that companion to have a real closure to call
                    # through (see native/lower.tcl's "String regions"
                    # section; composing the two optimizations further is
                    # out of this milestone's scope).
                    dict set eligible $b 0
                    set changed 1
                    continue
                }
                set linstance [dict get $spec instances $linst]
                set arity [dict get $arityOf $b]
                set ok 1
                # self references, inside L's own body. A self-reference
                # nested inside some further closure of L's own (rather
                # than directly in L's own body) is not examined by this
                # analysis (see the file header's scope limits): if L
                # structurally captures itself but no *direct* self-
                # reference-as-call was found, decline conservatively
                # rather than risk missing a genuine escaping use.
                lassign [RefsAsCalls $view $context $linstance [dict get $context exprs $l] $b $arity] selfOk selfTarget
                if {!$selfOk || ($selfTarget ne "" && $selfTarget ne $linst)} {
                    set ok 0
                } elseif {$selfTarget eq "" && [HasSelfCapture $view $l]} {
                    set ok 0
                }
                # external references, in this region's own top exprs.
                set found 0
                if {$ok} {
                    lassign [RefsAsCalls $view $context $instance $exprs $b $arity] extOk extTarget
                    if {!$extOk || ($extTarget ne "" && $extTarget ne $linst)} {
                        set ok 0
                    } elseif {$extTarget ne ""} {
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
                        set cinst [dict get $singleInstance $cb]
                        if {$cinst eq ""} {
                            set ok 0
                            break
                        }
                        set cinstance [dict get $spec instances $cinst]
                        # capturedBy already proves C's own literal
                        # structurally captures B; a *direct* reference
                        # inside C's own body (context.exprs[ce]) must
                        # therefore exist. If none is found there, the
                        # actual use is nested inside some further closure
                        # of C's own -- not examined by this analysis (the
                        # file header's scope limits) -- so decline
                        # conservatively.
                        lassign [RefsAsCalls $view $context $cinstance [dict get $context exprs $ce] $b $arity] cOk cTarget
                        if {!$cOk || $cTarget eq "" || $cTarget ne $linst} {
                            set ok 0
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
            set linst [dict get $singleInstance $b]
            dict set virtual $b $linst
            dict set wants $linst 1
            if {![dict exists $flatCaptures $linst]} {
                dict set flatCaptures $linst \
                    [FlattenBinding $view $envless $eligible $candidates memo $b]
            }
        }
    }
    return [list $virtual $wants $flatCaptures]
}

# ---------------------------------------------------------------------------
# Entry point

# The Block-escape analysis of program HIR under specialization SPEC
# (hir::specialize::analyze) and the already-computed hir::stringregion
# analysis STRINGREGION (see Bindings's own use of its `wants` query).
# Returns a dict:
#   virtual       BindingId -> calleeInstanceId (see Bindings)
#   wants         set (InstanceId -> 1) of callee instances to also emit a
#                 capture-explicit internal variant for
#   flatCaptures  InstanceId -> flattened BindingId list (see Bindings)
proc hir::blockescape::analyze {hir spec stringregion} {
    lassign [Bindings $hir $spec $stringregion] virtual wants flatCaptures
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
