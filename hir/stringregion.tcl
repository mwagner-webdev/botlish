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
# Local bindings and inline operands: which region-producing values are
# consumed only by a supported operation (`==` resolving to `streq`, or
# `length`), and the companion demand that creates.

# {VIRTUAL WANTS}: VIRTUAL is InstanceId -> BindingId -> 1, for every local
# binding of every used instance recognized virtual (see the file header).
# WANTS is a set (InstanceId -> 1) of instances directly demanded as a region
# companion target, from a virtual binding's own construction or from an
# inline (unbound) region-consuming operand.
proc hir::stringregion::Bindings {hir spec regionOf} {
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

        set captured [dict create]
        set refsByBinding [dict create]
        # eqOther: an ExprId that is one operand of a native `==` call whose
        # two operands are both statically str-typed (so NativeCallOp would
        # lower it to `streq`) -> the call's *other* operand ExprId.
        # lenArgs: the set of ExprIds that are the sole argument of a native
        # `length` call. Built once per region, like hir::escape::Bindings's
        # own listGetByArg.
        set eqOther [dict create]
        set lenArgs [dict create]
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
                if {![dict exists $eqOther $r] && ![dict exists $lenArgs $r]} {
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
proc hir::stringregion::analyze {hir spec} {
    lassign [Regions $hir $spec] regionOf forward
    lassign [Bindings $hir $spec $regionOf] virtual wants
    set wants [hir::escape::Propagate $wants $forward]
    return [dict create regionOf $regionOf wants $wants virtual $virtual]
}

proc hir::stringregion::wants {analysis id} {
    return [dict exists $analysis wants $id]
}

proc hir::stringregion::virtual {analysis id b} {
    return [dict exists $analysis virtual $id $b]
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
        if {!$recognized && $bindings eq ""} {
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
    }
    if {$lines eq ""} {
        return "no String region was recognized"
    }
    return [join $lines \n]
}
