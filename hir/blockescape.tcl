# blockescape.tcl -- conservative escape analysis for locally-bound Block
# (closure) values that provably never escape, so native/lower.tcl may keep
# them as a code identity plus ordinary capture *values* instead of ever
# building a heap Block object.
#
#   set analysis [hir::blockescape::analyze $hir $spec]
#   hir::blockescape::virtual $analysis $instanceId $bindingId  -> "" | calleeInstanceId
#   hir::blockescape::wants $analysis $calleeInstanceId          -> 0 | 1
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
# Scope (deliberately narrow and conservative, mirroring hir/escape.tcl's
# own discipline: if uncertain, this module simply does not recognize the
# binding, and ordinary closure construction/calling runs exactly as it
# always did):
#
#   * a local binding, bound (once, non-duplicate, kind local, never
#     captured by a nested block, never an implicit return of its own
#     scope), directly to a `block` literal that itself needs no runtime
#     environment identity ("self": no reference inside its own body
#     resolves, through hir::aot::BoundBlock, back to itself -- i.e. no
#     direct recursion) and captures no binding hir::aot::context marks as
#     needing a forward-reference cell (native/lower.tcl's Closure captures
#     a cell's own reference for those, not an ordinary value: out of scope
#     for this first implementation).
#   * every reference to that binding, anywhere in the same region, is
#     exactly the callee of a `call` expression whose HIR-resolved target is
#     that same block literal, with matching arity, and whose specialize
#     instance (INSTANCE's own `calls` map, exactly as hir::escape.tcl's
#     Classify already consults for its "remote" case) is the same single
#     instance at every call site. Any other use at all (a dynamic call, an
#     argument, a return, a store, a comparison, anything this module does
#     not specifically recognize) means the binding is not virtual: ordinary
#     closure construction and calling run unchanged for it, with no partial
#     optimization (the milestone's #33-34: mixed direct-call-plus-escaping
#     use declines virtualization entirely, exactly like the first
#     StringRegion mixed-use policy).
#   * a Block literal with no captures at all is never a candidate here: the
#     existing envless/fnvalue path (native/lower.tcl's Closure) already
#     calls it directly with zero allocation, so there is nothing for this
#     analysis to add.
#
# What this module deliberately does not attempt (the milestone's own scope
# limits, not omissions): recursive Blocks (a self-referencing block simply
# never qualifies, above); a Block passed through another (possibly closed)
# function and proven not to escape there (interprocedural propagation);
# late materialization of a Block that has both direct-call and escaping
# uses (declined outright, above); specializing the internal variant's own
# body differently per call site (one internal variant per callee instance,
# shared by every direct-call site that demands it, exactly as
# hir::escape.tcl's scalar-replacement companion is shared).

namespace eval hir::blockescape {
}

# 1 if block literal L (view HIR) would need "self" (the currently running
# closure) anywhere in its own body: some binding it captures is itself
# bound, through hir::aot::BoundBlock, to L -- a direct reference to L's own
# binding from inside L's own body (recursion), or L capturing some
# enclosing invocation's identity that happens to be itself. Such a block
# has no internal-variant representation: an internal variant has no
# environment argument for "self" to mean anything once virtualized.
proc hir::blockescape::NeedsSelf {hir l} {
    foreach cb [hir::get $hir $l captures] {
        if {[hir::aot::BoundBlock $hir $cb] eq $l} {
            return 1
        }
    }
    return 0
}

# 1 if any of block literal L's own captures is a binding CONTEXT (hir::aot
# ::context) marks as needing a forward-reference cell. Such a capture is
# the cell's own reference, not an ordinary already-resolved value
# (native/lower.tcl's Closure captures the cell itself for these): out of
# scope for this first implementation (see the file header), so a candidate
# capturing one is conservatively declined, exactly like a NeedsSelf block.
proc hir::blockescape::NeedsCell {hir context l} {
    set cells [dict get $context cells]
    foreach cb [hir::get $hir $l captures] {
        if {[dict exists $cells $cb]} {
            return 1
        }
    }
    return 0
}

# The specialize instance INSTANCE's own `calls` map resolves call
# expression E (view HIR) to, if E is a direct call whose HIR-resolved
# target is exactly block literal L; "" otherwise. Structurally the same
# recognizer as hir::escape::Classify's "remote" case, specialized to a
# call's *callee* rather than its result.
proc hir::blockescape::CallTarget {hir instance l e} {
    set node [hir::node $hir $e]
    lassign [dict get $node target] targetKind target
    if {$targetKind ne "block" || $target ne $l} {
        return ""
    }
    set calls [dict get $instance calls]
    if {![dict exists $calls $e]} {
        return ""
    }
    return [dict get $calls $e]
}

# {VIRTUAL WANTS}: VIRTUAL is InstanceId -> BindingId -> calleeInstanceId,
# for every local binding of every used instance recognized as described in
# the file header. WANTS is a set (InstanceId -> 1) of the callee instances
# some such binding demands an internal (capture-explicit) variant for.
proc hir::blockescape::Bindings {hir spec} {
    set context [dict get $spec context]
    set callees [dict get $context callees]
    set envless [dict get $context envless]
    set virtual [dict create]
    set wants [dict create]
    foreach id [dict get $spec used] {
        set instance [dict get $spec instances $id]
        set block [dict get $instance block]
        set region [expr {$block eq "program" ? "program" : $block}]
        set view [hir::specialize::view $hir $spec $id]
        set exprs [dict get $context exprs $region]
        set topBody [expr {$region eq "program" ? [hir::roots $view] : [hir::get $view $region body]}]
        # A bind at a trailing position is itself an implicit "return" of
        # its value out of that scope: a Block escaping that way must
        # materialize (reused verbatim from hir::escape.tcl: the same
        # notion of "trailing position", independent of what kind of value
        # is bound there).
        set trailing [hir::escape::TrailingPositions $view $topBody $exprs]

        set captured [dict create]
        set refsByBinding [dict create]
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
            if {[dict get [hir::binding $view $b] kind] ne "local" || [dict exists $captured $b]
                    || [dict exists [dict get $context cells] $b]} {
                continue
            }
            set l [dict get $node value]
            if {[hir::kind $view $l] ne "block" || $l in $envless} {
                continue
            }
            if {[NeedsSelf $view $l] || [NeedsCell $view $context $l]} {
                continue
            }
            set refs [expr {[dict exists $refsByBinding $b] ? [dict get $refsByBinding $b] : {}}]
            if {$refs eq ""} {
                continue
            }
            set arity [llength [hir::get $view $l params]]
            set target ""
            set ok 1
            foreach r $refs {
                if {![dict exists $callees $r]} {
                    set ok 0
                    break
                }
                set callExpr [dict get $callees $r]
                if {[llength [dict get [hir::node $view $callExpr] args]] != $arity} {
                    set ok 0
                    break
                }
                set t [CallTarget $view $instance $l $callExpr]
                if {$t eq ""} {
                    set ok 0
                    break
                }
                if {$target eq ""} {
                    set target $t
                } elseif {$target ne $t} {
                    set ok 0
                    break
                }
            }
            if {!$ok || $target eq ""} {
                continue
            }
            dict set virtual $id $b $target
            dict set wants $target 1
        }
    }
    return [list $virtual $wants]
}

# ---------------------------------------------------------------------------
# Entry point

# The Block-escape analysis of program HIR under specialization ANALYSIS
# (hir::specialize::analyze). Returns a dict:
#   virtual   InstanceId -> BindingId -> calleeInstanceId (see Bindings)
#   wants     set (InstanceId -> 1) of callee instances to also emit a
#             capture-explicit internal variant for
proc hir::blockescape::analyze {hir spec} {
    lassign [Bindings $hir $spec] virtual wants
    return [dict create virtual $virtual wants $wants]
}

proc hir::blockescape::virtual {analysis id b} {
    set virtual [dict get $analysis virtual]
    if {[dict exists $virtual $id $b]} {
        return [dict get $virtual $id $b]
    }
    return ""
}

proc hir::blockescape::wants {analysis id} {
    return [dict exists $analysis wants $id]
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
# lowering, which asks `virtual`/`wants` directly)

proc hir::blockescape::explain {hir spec analysis} {
    set lines {}
    foreach id [dict get $spec used] {
        set virtual [dict get $analysis virtual]
        set bindings [expr {[dict exists $virtual $id] ? [dict get $virtual $id] : {}}]
        if {$bindings eq ""} {
            continue
        }
        lappend lines "[hir::specialize::label $spec $id] ($id):"
        foreach {b target} $bindings {
            lappend lines "  virtual local $b: calls [hir::specialize::label $spec $target]\
                directly, captures passed as ordinary values (no heap Block)"
        }
    }
    if {$lines eq ""} {
        return "no nonescaping Block binding was recognized"
    }
    return [join $lines \n]
}
