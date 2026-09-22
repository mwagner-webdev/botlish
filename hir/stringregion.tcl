# stringregion.tcl -- conservative recognition of String values whose
# physical extent (a base String object plus a character-index range) native/
# lower.tcl's lowering may keep as three scalar registers -- a "StringRegion"
# -- instead of ever calling `substr`, when a temporary substring's identity
# and byte layout are never observed:
#
#   set analysis [hir::stringregion::analyze $hir $spec]
#   hir::stringregion::wants $analysis $instanceId          -> 0 | 1
#   hir::stringregion::virtual $analysis $instanceId $b     -> 0 | 1
#   hir::stringregion::classify $hir $spec $analysis $id $e -> "" | {const T} |
#                                                               {remote target}
#
# This is a *representation* analysis, exactly in the sense hir/escape.tcl's
# header describes for fixed-shape List aggregates: nothing here changes what
# a Botlish String means, HIR types, or hir/specialize.tcl's instances. A
# StringRegion is never a source-visible type (not a slice, not a span, not a
# borrowed/reference String): it is purely an optimizer-internal
# representation of an ordinary, already-semantically-immutable String value,
# used only while native/lower.tcl can preserve the exact observable behavior
# of a materialized String (see native/lower.tcl's "String regions" section
# for the lowering this analysis drives).
#
# Scope (deliberately narrow, mirroring hir/escape.tcl's own discipline: if
# uncertain, this module simply does not recognize the binding or call, and
# ordinary lowering -- an actual `substr` allocation -- is exactly as sound
# and unchanged as it always was):
#
#   * a *region-producing* expression is a direct `substring(text, a, b)`
#     call (the region is (text, a, b): the same three operands the ordinary
#     call would validate and copy from), a String literal (trivially a
#     region over itself, (self, 0, its own character count)), or a direct
#     call to another block whose own instance's *every* reachable exit
#     (return, or trailing body value; never a self-tail loop backedge --
#     see hir/escape.tcl's identical Exits/SelfTailExit, reused here as-is)
#     is itself region-producing (by induction, exactly like hir::escape's
#     Arities). This is what lets `peek`-shaped helpers (a String-returning
#     function whose every exit is a substring call or a literal) recognize
#     across a function boundary: hir::stringregion::wants marks such an
#     instance for a *region companion* function (native/lower.tcl's
#     RegionCompanionFunction), alongside its ordinary, unconditionally
#     still-emitted String-returning function -- exactly the same
#     "canonical + companion" shape hir/escape.tcl established for Lists.
#   * a local binding, bound (once, non-duplicate, kind local, never captured
#     by a nested closure) to a region-producing expression, is "virtual"
#     only if *every* reference to it is an operand of a native `==` call
#     whose two operands are both statically str-typed (so it lowers to
#     `streq`, never a runtime-guarded `eq`/`==` -- see native/lower.tcl's
#     NativeCallOp), or the sole argument of a native `length` call. Any
#     other use at all (concat, storage, return, an argument to any other
#     call, a generic/indirect use) means the binding is not virtual:
#     ordinary lowering (materializing the substring exactly once, as
#     before) runs unchanged for it -- no partial optimization, so no risk
#     of double evaluation, a changed materialization point, or a changed
#     bounds-error moment (mirrors hir::escape.tcl's #11-13 rationale
#     exactly).
#   * a region-producing call embedded directly as an operand of such a `==`
#     or `length` call, with no binding at all (e.g. `peek(text, i) ==
#     "\""`), is recognized the same way: native/lower.tcl evaluates it in
#     region form right at that one use (see Call's `wantRegion`), so it
#     needs no "every reference" check at all (there is exactly one, by
#     construction) -- only, if it forwards to another block, the same
#     companion demand as the bound case.
#
# A region companion is demanded for instance J (hir::stringregion::wants)
# when some caller's binding is virtual and its construction forwards to J,
# or an inline region-consuming operand forwards to J, or an instance C that
# is itself demanded forwards (in the sense above) to J: this closure is
# exactly hir::escape::Propagate, reused as-is (it is generic over any
# InstanceId->InstanceId forwarding graph).
#
# Bounded, non-recursive-in-the-worrying-sense: the region-producing fixpoint
# (Regions) only ever adds facts, so it reaches a fixed point in at most one
# pass per candidate instance; a genuine cycle of mutual forwarding with no
# base case simply never gets recognized (sound: no companion is ever built
# for it). Linear scans over each used instance's own region, no
# whole-program points-to reasoning -- the same complexity shape as
# hir/escape.tcl.
#
# Consuming parameters (the "char/string-view allocations" milestone): a
# region-producing value passed as an *argument*, not just as a `==`/
# `length` operand -- e.g. Botlish source shaped like
# `is_local_char(char_at(i))`, where `char_at`'s one-character result is
# immediately classified rather than compared. `is_tcl_alpha`/`is_tcl_alnum`
# (core/tclcompat.tcl) join `==`/`length` directly as supported native
# consumers (ConsumingNative, below): a region-eligible sole argument of
# either lowers to a StringRegion classification (native/lower.tcl's "String
# regions" section), never a materialized one-character String.
#
# A *user-defined* one-parameter predicate wholly built from those same three
# native shapes -- `is_local_char`/`is_label_char` in lib/web.tcl's Emailish?
# native-body are exactly this: `fn is_local_char(c): is_tcl_alnum(c) or c ==
# "." or ...` -- is itself then just as safely region-consuming at that
# parameter: every one of its own reachable uses of the parameter is already
# one of the three supported shapes, so calling it with a region argument
# needs nothing but substituting the region for the parameter throughout its
# body, never a materialized String at the call boundary either.
# ConsumingParams (below) recognizes this by structural induction, generic
# over shape and never over any specific name (#29 of the milestone): a used,
# non-generic (mirrors hir/traversal.tcl's own restriction to non-generic
# instances, for exactly the same "always reached through a direct call,
# never the fixed generic-entry ABI" reason -- see that module's own
# rationale), non-self-tail-calling instance whose *entire* region consists
# only of `if`, a literal/root (`true`/`false`) reference, and a native call
# to `==` (one operand a String literal), `length`, `is_tcl_alpha`, or
# `is_tcl_alnum` -- exactly the node kinds native/lower.tcl's
# EmitRegionConsumerBody (native/lower.tcl's "String regions" section) knows
# how to re-lower directly against a caller's region, in place of an actual
# call to the instance's own compiled function (the same "lower directly in
# the caller, no interprocedural ABI, no companion call" choice hir/
# traversal.tcl's TraversalAccess already made for the analogous producer-
# side problem: see that module's own header, #17-18 option A) -- is
# region-consuming at parameter index K when every reference to parameter K
# is one of those three native-call operand positions. Any other shape at
# all (a second Block call, a `bind`, a `loop`, a captured/non-literal `==`
# operand) simply is not recognized: ordinary lowering, an actual call
# passing a materialized String, runs unchanged for it, exactly as narrow
# and conservative as every other analysis in this file.

namespace eval hir::stringregion {
}

# ---------------------------------------------------------------------------
# Recognizing a construction

# "" | {const TEXT} | {remote target}: how expression E (a `const` or `call`,
# in INSTANCE's region) produces a recognized String region, given REGIONOF
# (InstanceId -> 1, the instances so far proven region-producing). A direct
# `substring(text, a, b)` call is recognized structurally by native/lower.tcl
# itself (Call's `wantRegion` case): it needs no entry here, since its three
# operands -- not some derived fact -- *are* the region, and evaluating them
# is exactly evaluating an ordinary `substring` call's arguments. Classify
# only needs to name the *other* two shapes, since those are the ones a
# caller cannot tell apart from an ordinary String-typed expression by
# looking at E's kind alone.
proc hir::stringregion::Classify {hir instance regionOf e} {
    switch -- [hir::kind $hir $e] {
        const {
            set value [hir::get $hir $e value]
            if {[core::value::kind $value] ne "str"} {
                return ""
            }
            return [list const [core::value::strOf $value]]
        }
        call {
            set node [hir::node $hir $e]
            lassign [dict get $node target] targetKind target
            if {$targetKind eq "native"} {
                if {[dict get [hir::symbol $hir $target] name] eq "substring"
                        && [llength [dict get $node args]] == 3} {
                    return [list substr {*}[dict get $node args]]
                }
                return ""
            }
            if {$targetKind eq "block"} {
                set calls [dict get $instance calls]
                if {![dict exists $calls $e]} {
                    return ""
                }
                set callee [dict get $calls $e]
                if {![dict exists $regionOf $callee]} {
                    return ""
                }
                return [list remote $callee]
            }
            return ""
        }
    }
    return ""
}

# Public wrapper of Classify for native/lower.tcl, in the same shape as
# hir::escape::classify.
proc hir::stringregion::classify {hir spec analysis id e} {
    set instance [dict get $spec instances $id]
    return [Classify $hir $instance [dict get $analysis regionOf] $e]
}

# {REGIONOF FORWARD}: REGIONOF is a set (InstanceId -> 1) of every used
# instance whose result is fully region-producing (see the file header);
# FORWARD is InstanceId -> list of distinct target InstanceIds among its own
# forwarding ("remote") exits (used to propagate companion demand).
proc hir::stringregion::Regions {hir spec} {
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
        # Exits/SelfTailExit are generic HIR shape-finders (no List concept
        # in them at all): reused directly from hir::escape.tcl rather than
        # duplicated (the milestone's own guidance: prefer shared general
        # principles over artificially shared code, but genuinely shared
        # code is still just shared).
        set exits [hir::escape::Exits $view $context $instance $id $block $selfTails]
        if {$exits eq ""} {
            continue
        }
        dict set candidates $id [list $view $instance $exits]
    }
    set regionOf [dict create]
    set forward [dict create]
    set changed 1
    while {$changed} {
        set changed 0
        dict for {id info} $candidates {
            if {[dict exists $regionOf $id]} {
                continue
            }
            lassign $info view instance exits
            set ok 1
            set targets {}
            foreach e $exits {
                set c [Classify $view $instance $regionOf $e]
                if {$c eq ""} {
                    set ok 0
                    break
                }
                if {[lindex $c 0] eq "remote"} {
                    lappend targets [lindex $c 1]
                }
            }
            if {$ok} {
                dict set regionOf $id 1
                dict set forward $id [lsort -unique $targets]
                set changed 1
            }
        }
    }
    return [list $regionOf $forward]
}

# ---------------------------------------------------------------------------
# Consuming parameters (see the file header): which used instances' own
# parameters are themselves safe to satisfy with a region instead of a
# materialized String.

# 1 if NAME (a native call's resolved symbol name) is a supported
# region-consuming classification native: `is_tcl_alpha`/`is_tcl_alnum`
# (core/tclcompat.tcl) join `==`/`length` (handled directly by Bindings/
# ConsumingParams themselves, not through this list, since they need their
# *other* operand inspected too) as natives whose sole region-eligible
# argument native/lower.tcl's "String regions" section can classify directly
# from the region, never materializing it first.
proc hir::stringregion::ConsumingNative {name} {
    return [expr {$name in {is_tcl_alpha is_tcl_alnum}}]
}

# A used, non-program, non-generic instance ID (view VIEW, own INSTANCE) is
# a candidate for ConsumingParams only if its *entire* region is built from
# nothing but `if`, a `ref` (to a parameter or to a root true/false/native
# value -- hir::binding's own `kind`), a `const`, and a native call to `==`,
# `length`, `is_tcl_alpha`, or `is_tcl_alnum` -- exactly the shapes
# native/lower.tcl's EmitRegionConsumerBody knows how to re-lower against a
# caller's region (see the file header) -- and it makes no call to another
# Block at all (so, in particular, it is never itself self-tail-recursive:
# the "create/consume/discard per iteration" restriction the milestone's
# #36 asks for, satisfied here simply by never recognizing a loop in the
# first place, exactly hir/traversal.tcl's own precedent of leaving
# loop-carried regions unattempted). Returns {EQOTHER LENARGS CLASSIFYARGS
# REFSBYBINDING} (EQOTHER/LENARGS/REFSBYBINDING in Bindings' own shape,
# CLASSIFYARGS the same shape as LENARGS) on success, "" if this instance's
# shape is not recognized at all.
proc hir::stringregion::ConsumingShape {view instance exprs} {
    if {[dict get $instance calls] ne {}} {
        return ""
    }
    set eqOther [dict create]
    set lenArgs [dict create]
    set classifyArgs [dict create]
    set refsByBinding [dict create]
    foreach e $exprs {
        switch -- [hir::kind $view $e] {
            if - const {}
            ref {
                set b [hir::get $view $e binding]
                if {$b eq ""} {
                    return ""
                }
                if {[dict get [hir::binding $view $b] kind] ne "root"} {
                    dict lappend refsByBinding $b $e
                }
            }
            call {
                set node [hir::node $view $e]
                lassign [dict get $node target] targetKind target
                if {$targetKind ne "native"} {
                    return ""
                }
                set name [dict get [hir::symbol $view $target] name]
                set args [dict get $node args]
                if {$name eq "==" && [llength $args] == 2} {
                    lassign $args a b
                    set ka [hir::types::kindOf [hir::typeOf $view $a]]
                    set kb [hir::types::kindOf [hir::typeOf $view $b]]
                    if {$ka ne "str" || $kb ne "str"} {
                        return ""
                    }
                    # EmitRegionConsumerBody only ever substitutes a
                    # region for one `==` operand and lowers the *other*
                    # as an ordinary String literal (`regioneq`'s own
                    # fourth operand): a `==` between two non-constant
                    # str-typed expressions is simply not recognized here
                    # (ordinary lowering handles it unchanged).
                    if {[hir::kind $view $a] eq "const" && [core::value::kind [hir::get $view $a value]] eq "str"} {
                        dict set eqOther $b $a
                    } elseif {[hir::kind $view $b] eq "const" && [core::value::kind [hir::get $view $b value]] eq "str"} {
                        dict set eqOther $a $b
                    } else {
                        return ""
                    }
                } elseif {$name eq "length" && [llength $args] == 1} {
                    dict set lenArgs [lindex $args 0] 1
                } elseif {[ConsumingNative $name] && [llength $args] == 1} {
                    dict set classifyArgs [lindex $args 0] 1
                } else {
                    return ""
                }
            }
            default {
                return ""
            }
        }
    }
    return [list $eqOther $lenArgs $classifyArgs $refsByBinding]
}

# InstanceId -> ParamIndex -> 1: every used instance's parameter safe to
# satisfy with a region argument instead of a materialized String (see the
# file header). CONTEXT is SPEC's own `context` (hir::specialize::analyze).
proc hir::stringregion::ConsumingParams {hir spec} {
    set context [dict get $spec context]
    set result [dict create]
    foreach id [dict get $spec used] {
        set instance [dict get $spec instances $id]
        set block [dict get $instance block]
        if {$block eq "program" || [dict get $instance generic]} {
            continue
        }
        set view [hir::specialize::view $hir $spec $id]
        set exprs [dict get $context exprs $block]
        set shape [ConsumingShape $view $instance $exprs]
        if {$shape eq ""} {
            continue
        }
        lassign $shape eqOther lenArgs classifyArgs refsByBinding
        set params [hir::get $view $block params]
        for {set k 0} {$k < [llength $params]} {incr k} {
            set p [lindex $params $k]
            if {![dict exists $refsByBinding $p]} {
                continue
            }
            set ok 1
            foreach r [dict get $refsByBinding $p] {
                if {![dict exists $eqOther $r] && ![dict exists $lenArgs $r] && ![dict exists $classifyArgs $r]} {
                    set ok 0
                    break
                }
            }
            if {$ok} {
                dict set result $id $k 1
            }
        }
    }
    return $result
}

# ---------------------------------------------------------------------------
# Local bindings and inline operands: which region-producing values are
# consumed only by a supported operation (`==` resolving to `streq`, or
# `length`), and the companion demand that creates.

# {VIRTUAL WANTS}: VIRTUAL is InstanceId -> BindingId -> 1, for every local
# binding of every used instance recognized virtual (see the file header).
# WANTS is a set (InstanceId -> 1) of instances directly demanded as a region
# companion target, from a virtual binding's own construction or from an
# inline (unbound) region-consuming operand.
proc hir::stringregion::Bindings {hir spec regionOf consumingParams} {
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
        set trailing [hir::escape::TrailingPositions $view $topBody $exprs]
        set calls [dict get $instance calls]

        set captured [dict create]
        set refsByBinding [dict create]
        # eqOther: an ExprId that is one operand of a native `==` call whose
        # two operands are both statically str-typed (so NativeCallOp would
        # lower it to `streq`) -> the call's *other* operand ExprId.
        # lenArgs: the set of ExprIds that are the sole argument of a native
        # `length` call. classifyArgs: the set of ExprIds that are the sole
        # argument of a supported native classification call (ConsumingNative
        # -- is_tcl_alpha/is_tcl_alnum). consumingCallArgs: the set of
        # ExprIds that are the argument, at a consuming parameter position
        # (hir::stringregion::ConsumingParams), of a direct call to another
        # used instance. Built once per region, like hir::escape::
        # RegionInfo's own listGetByArg.
        set eqOther [dict create]
        set lenArgs [dict create]
        set classifyArgs [dict create]
        set consumingCallArgs [dict create]
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
                    if {$targetKind eq "block"} {
                        if {![dict exists $calls $e] || ![dict exists $consumingParams [dict get $calls $e]]} {
                            continue
                        }
                        set callee [dict get $calls $e]
                        set args [dict get $node args]
                        dict for {k _} [dict get $consumingParams $callee] {
                            if {$k < [llength $args]} {
                                dict set consumingCallArgs [lindex $args $k] 1
                            }
                        }
                        continue
                    }
                    if {$targetKind ne "native"} {
                        continue
                    }
                    set name [dict get [hir::symbol $view $target] name]
                    set args [dict get $node args]
                    if {$name eq "==" && [llength $args] == 2} {
                        lassign $args a b
                        set ka [hir::types::kindOf [hir::typeOf $view $a]]
                        set kb [hir::types::kindOf [hir::typeOf $view $b]]
                        if {$ka eq "str" && $kb eq "str"} {
                            dict set eqOther $a $b
                            dict set eqOther $b $a
                        }
                    } elseif {$name eq "length" && [llength $args] == 1} {
                        dict set lenArgs [lindex $args 0] 1
                    } elseif {[ConsumingNative $name] && [llength $args] == 1} {
                        dict set classifyArgs [lindex $args 0] 1
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
            set c [Classify $view $instance $regionOf [dict get $node value]]
            if {$c eq ""} {
                continue
            }
            set ok 1
            foreach r [expr {[dict exists $refsByBinding $b] ? [dict get $refsByBinding $b] : {}}] {
                if {![dict exists $eqOther $r] && ![dict exists $lenArgs $r]
                        && ![dict exists $classifyArgs $r] && ![dict exists $consumingCallArgs $r]} {
                    set ok 0
                    break
                }
            }
            if {!$ok} {
                continue
            }
            dict set virtual $id $b 1
            if {[lindex $c 0] eq "remote"} {
                dict set wants [lindex $c 1] 1
            }
        }

        # Inline region-consuming operands with no binding at all (e.g.
        # `peek(text, i) == "\""`, `length(peek(text, i))`): native/lower.tcl
        # evaluates each in region form right at its one use, so the only
        # fact this analysis still owes it is companion demand for a
        # forwarding ("remote") shape. A `ref` operand is already covered by
        # the virtual-binding scan above.
        foreach {e other} $eqOther {
            if {[hir::kind $view $e] eq "ref"} {
                continue
            }
            set c [Classify $view $instance $regionOf $e]
            if {$c ne "" && [lindex $c 0] eq "remote"} {
                dict set wants [lindex $c 1] 1
            }
        }
        foreach e [dict keys $lenArgs] {
            if {[hir::kind $view $e] eq "ref"} {
                continue
            }
            set c [Classify $view $instance $regionOf $e]
            if {$c ne "" && [lindex $c 0] eq "remote"} {
                dict set wants [lindex $c 1] 1
            }
        }
        foreach e [dict keys $classifyArgs] {
            if {[hir::kind $view $e] eq "ref"} {
                continue
            }
            set c [Classify $view $instance $regionOf $e]
            if {$c ne "" && [lindex $c 0] eq "remote"} {
                dict set wants [lindex $c 1] 1
            }
        }
        foreach e [dict keys $consumingCallArgs] {
            if {[hir::kind $view $e] eq "ref"} {
                continue
            }
            set c [Classify $view $instance $regionOf $e]
            if {$c ne "" && [lindex $c 0] eq "remote"} {
                dict set wants [lindex $c 1] 1
            }
        }
    }
    return [list $virtual $wants]
}

# ---------------------------------------------------------------------------
# Entry point

# The string-region analysis of program HIR under specialization SPEC
# (hir::specialize::analyze). Returns a dict:
#   regionOf  set (InstanceId -> 1): every instance whose result is fully
#             region-producing (see Regions)
#   wants     set (InstanceId -> 1) of instances to also emit a region
#             companion function for (see Bindings/hir::escape::Propagate)
#   virtual   InstanceId -> BindingId -> 1 (see Bindings)
#   consumingParams  InstanceId -> ParamIndex -> 1 (see ConsumingParams)
proc hir::stringregion::analyze {hir spec} {
    lassign [Regions $hir $spec] regionOf forward
    set consumingParams [ConsumingParams $hir $spec]
    lassign [Bindings $hir $spec $regionOf $consumingParams] virtual wants
    set wants [hir::escape::Propagate $wants $forward]
    return [dict create regionOf $regionOf wants $wants virtual $virtual consumingParams $consumingParams]
}

proc hir::stringregion::wants {analysis id} {
    return [dict exists $analysis wants $id]
}

proc hir::stringregion::virtual {analysis id b} {
    return [dict exists $analysis virtual $id $b]
}

# Every parameter index of instance ID a region argument may satisfy
# directly, instead of a materialized String (see ConsumingParams and the
# file header) -- consulted by native/lower.tcl's Call to decide whether a
# direct call to ID, given a region-eligible argument at that position,
# should inline ID's own body against the region (EmitRegionConsumerBody)
# rather than materializing and calling it. "" if none.
proc hir::stringregion::consumingParamsOf {analysis id} {
    if {![dict exists $analysis consumingParams $id]} {
        return ""
    }
    return [lsort -integer [dict keys [dict get $analysis consumingParams $id]]]
}

# {InstanceId Label} pairs (hir::specialize::label) of every instance a
# region companion function is built for: for explainability/reporting only,
# never consulted by lowering itself (mirrors hir::escape::wantedInstances).
proc hir::stringregion::wantedInstances {hir spec analysis} {
    set result {}
    foreach id [dict get $spec used] {
        if {[wants $analysis $id]} {
            lappend result [list $id [hir::specialize::label $spec $id]]
        }
    }
    return $result
}

# Human-readable explanation (derived from the analysis; never consulted by
# lowering, which asks `wants`/`virtual`/`classify` directly), in the same
# spirit as hir::escape::explain.
proc hir::stringregion::explain {hir spec analysis} {
    set lines {}
    foreach id [dict get $spec used] {
        set recognized [dict exists [dict get $analysis regionOf] $id]
        set bindings [expr {[dict exists [dict get $analysis virtual] $id]
            ? [dict keys [dict get [dict get $analysis virtual] $id]] : {}}]
        set consuming [consumingParamsOf $analysis $id]
        if {!$recognized && $bindings eq "" && $consuming eq ""} {
            continue
        }
        lappend lines "[hir::specialize::label $spec $id] ($id):"
        if {$recognized} {
            lappend lines "  result: a String region[expr {[wants $analysis $id] \
                ? " (region companion built)" : " (recognized, but no caller demands a companion)"}]"
        }
        foreach b $bindings {
            lappend lines "  virtual local $b: consumed as a region (==/length), never materialized"
        }
        foreach k $consuming {
            lappend lines "  parameter $k: region-consuming, inlined at a region-eligible call argument"
        }
    }
    if {$lines eq ""} {
        return "no String region was recognized"
    }
    return [join $lines \n]
}
