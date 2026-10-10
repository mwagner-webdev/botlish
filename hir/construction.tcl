# construction.tcl -- virtual immutable construction (M8.a,
# M8A-VIRTUAL-IMMUTABLE-CONSTRUCTION.md): which String/List values native/
# lower.tcl may keep as a *construction plan* -- "if this immutable value
# becomes observable as a flat value, here are the already-evaluated pieces
# it is made of" -- instead of materializing a flat String/List at every
# `str::concat`/`list::append`:
#
#   set analysis [hir::construction::analyze $hir $spec $escape $stringregion $blockescape]
#   hir::construction::paramFamily  $analysis $id $k   -> "" | str | list
#   hir::construction::localFamily  $analysis $id $b   -> "" | str | list
#   hir::construction::resultFamily $analysis $id      -> "" | str | list
#   hir::construction::explain / audit                 -> provenance, barriers
#
# Like hir/escape.tcl and hir/stringregion.tcl, this is a *representation*
# analysis: it never changes what a Botlish String/List means, any HIR type,
# any specialization key, or which instances exist. A plan is never a
# Botlish value or type: "virtual", "flat", "unique" and a plan's number of
# pieces are compiler/runtime construction facts that never enter type
# comparison, admissibility or hir::specialize's KeyType. Evaluation is
# unchanged too -- every piece is an ordinary, strictly evaluated value,
# evaluated exactly where and when it always was; only the *copying* into
# one flat object is postponed (see native/lower.tcl's "Virtual
# construction" section for the lowering and runtime/construct.rs for the
# runtime plan objects).
#
# There is no loop or accumulator recognizer here. The analysis only answers
# three general, per-binding/per-instance questions, and a runtime-variable
# recurrence (a self-tail call carrying `str::concat(acc, piece)`) benefits purely
# because its parameter happens to satisfy the same rule as any other
# binding:
#
#   * plan local   a local binding (never captured, never a cell/duplicate,
#                  not in a trailing position, not already claimed by the
#                  List-scalar/StringRegion/Block virtualizations) whose
#                  value is plan-producing (below) and which is *linear*:
#                  along every execution path of its scope it is referenced
#                  at most once (Linear). Its single use either extends the
#                  construction further or is its one materialization.
#   * plan param   parameter K of an instance, statically String/List-typed
#                  at every reference, never captured, linear in the body,
#                  and at least one direct call to the instance (a self-tail
#                  call, a sibling/outer call, or an internal-variant call)
#                  passes a plan-producing argument there. A plan parameter
#                  is "maybe-plan": it accepts a plan from such a caller and
#                  an ordinary flat value from anyone else (an open caller,
#                  the generic entry) -- so, unlike a plan result, it needs
#                  no closedness proof at all.
#   * plan result  a *closed* instance (hir::specialize::InstanceClosed, the
#                  M7.c proof that every runtime route into it is a direct
#                  call this compilation lowers) with a String/List result,
#                  some call of which is itself consumed in a plan position:
#                  its exits may then hand the caller a plan -- the
#                  construction summary "my result is a construction still
#                  in progress" crossing an exact call, without cloning or
#                  re-specializing the callee (its instance, key and single
#                  compiled body are unchanged; only its result's
#                  representation contract with its exact callers is).
#                  Instances with a scalar-replacement, region or `fields`
#                  companion are excluded (those variants have their own
#                  exit contracts).
#
# Plan-producing expressions (PlanSource): a native `str::concat` call (String) or
# `list::append` call (List), a `str::substring` call (a one-piece String
# construction: its StringRegion), a reference to a plan local/param, a direct call
# to a plan-result instance, or a value-producing `if` one of whose branch
# values is plan-producing. Plan positions (PlanContext) -- where such a
# value may stay virtual instead of being materialized: a `str::concat` operand, a
# `list::append` first operand, a plan local's value, the argument at a plan
# parameter, an exit of a plan-result instance, and a branch value of an
# `if` that is itself in a plan position. Every other consumer is a
# materialization barrier (Barrier names why: flat-only native, storage
# into an aggregate, open/dynamic call, fork, return to an unknown caller,
# final observable result, ...).
#
# All four sets grow monotonically (more plan bindings can only make more
# expressions plan-producing and more positions plan positions), so the
# fixpoint in `analyze` terminates.

namespace eval hir::construction {
}

# "str" | "list" | "": the construction family of static type TYPE.
proc hir::construction::Family {type} {
    switch -- [hir::types::kindOf $type] {
        str  { return str }
        list { return list }
    }
    return ""
}

# The native name a `call` E resolves to, or "" if it is not a native call.
proc hir::construction::NativeName {view e} {
    if {[hir::kind $view $e] ne "call"} {
        return ""
    }
    lassign [hir::get $view $e target] targetKind target
    if {$targetKind ne "native"} {
        return ""
    }
    return [dict get [hir::symbol $view $target] name]
}

# ---------------------------------------------------------------------------
# Per-instance facts

# A dict describing instance ID's region: view, block, top body, params,
# region exprs, captured bindings, references per binding, and the parent
# (consumer) of every region expression.
proc hir::construction::RegionInfo {hir spec id} {
    set context [dict get $spec context]
    set instance [dict get $spec instances $id]
    set block [dict get $instance block]
    set view [hir::specialize::view $hir $spec $id]
    set region [expr {$block eq "program" ? "program" : $block}]
    set exprs [dict get $context exprs $region]
    set topBody [expr {$block eq "program" ? [hir::roots $view] : [hir::get $view $block body]}]
    set params [expr {$block eq "program" ? {} : [hir::get $view $block params]}]
    set captured [dict create]
    set refs [dict create]
    set parent [dict create]
    foreach e $exprs {
        switch -- [hir::kind $view $e] {
            block {
                foreach b [hir::externalRefs $view $e] {
                    dict set captured $b 1
                }
                # A nested block's body is its own region.
                continue
            }
            ref {
                set b [hir::get $view $e binding]
                if {$b ne ""} {
                    dict lappend refs $b $e
                }
            }
        }
        foreach child [hir::children $view $e] {
            dict set parent $child $e
        }
    }
    return [dict create view $view block $block instance $instance exprs $exprs topBody $topBody \
        params $params captured $captured refs $refs parent $parent]
}

# ---------------------------------------------------------------------------
# Linear use
#
# Uses returns {N A}: the most references to binding B evaluated along any
# path through E that completes normally (N) or abruptly -- return, break,
# continue, fail, or an error caught by a `handle` (A); -1 means "no such
# path", 2 means "two or more". A binding is linear when max(N, A) <= 1 over
# its whole region: at most one reference executes per activation, so a
# plan it holds has exactly one continuation and may be extended in place.
# A loop body (or listloop body) that references B, when B is bound outside
# that loop, may run it any number of times: 2. A nested block capturing B
# aliases it: 2 (captured bindings are also excluded outright).

proc hir::construction::Add {x y} {
    if {$x < 0 || $y < 0} {
        return -1
    }
    return [expr {min(2, $x + $y)}]
}

proc hir::construction::Max {args} {
    return [tcl::mathfunc::max {*}$args]
}

proc hir::construction::SeqUses {view b loops exprs} {
    set n 0
    set a -1
    foreach e $exprs {
        lassign [Uses $view $b $loops $e] en ea
        if {$ea >= 0} {
            set a [Max $a [Add $n $ea]]
        }
        if {$en < 0} {
            return [list -1 $a]
        }
        set n [Add $n $en]
    }
    return [list $n $a]
}

# LOOPS: the set of loop/listloop ExprIds that contain B's own `bind` (a
# per-iteration binding): only their bodies are analyzed per iteration.
proc hir::construction::Uses {view b loops e} {
    switch -- [hir::kind $view $e] {
        const { return {0 -1} }
        ref {
            return [list [expr {[hir::get $view $e binding] eq $b ? 1 : 0}] -1]
        }
        continue { return {-1 0} }
        fail {
            set v [hir::get $view $e value]
            if {$v eq ""} {
                return {-1 0}
            }
            lassign [Uses $view $b $loops $v] n a
            return [list -1 [Max $n $a]]
        }
        bind - ok - error {
            return [Uses $view $b $loops [hir::get $view $e value]]
        }
        return - break {
            set v [hir::get $view $e value]
            if {$v eq ""} {
                return {-1 0}
            }
            lassign [Uses $view $b $loops $v] n a
            return [list -1 [Max $n $a]]
        }
        block {
            return [list [expr {$b in [hir::externalRefs $view $e] ? 2 : 0}] -1]
        }
        call {
            return [SeqUses $view $b $loops [hir::children $view $e]]
        }
        if {
            lassign [Uses $view $b $loops [hir::get $view $e condition]] cn ca
            lassign [SeqUses $view $b $loops [hir::get $view $e thenBody]] tn ta
            lassign [SeqUses $view $b $loops [hir::get $view $e elseBody]] en ea
            set branch [Max $tn $en]
            set n [expr {$cn < 0 || $branch < 0 ? -1 : [Add $cn $branch]}]
            set a $ca
            if {$cn >= 0} {
                if {$ta >= 0} { set a [Max $a [Add $cn $ta]] }
                if {$ea >= 0} { set a [Max $a [Add $cn $ea]] }
            }
            return [list $n $a]
        }
        loop - listloop {
            set prefix {0 -1}
            if {[hir::kind $view $e] eq "listloop"} {
                set prefix [Uses $view $b $loops [hir::get $view $e iterable]]
            }
            lassign [SeqUses $view $b $loops [hir::get $view $e body]] bn ba
            set per [Max $bn $ba]
            if {$per > 0 && ![dict exists $loops $e]} {
                set per 2
            }
            lassign $prefix pn pa
            if {$pn < 0} {
                return $prefix
            }
            set total [Add $pn [Max $per 0]]
            return [list $total [Max $pa $total]]
        }
        countloop - lockloop {
            # START/END (or every lockstep domain's operands) are a prefix,
            # evaluated once each, left to right, in the enclosing scope --
            # exactly like listloop's own single-expression iterable prefix
            # above, just over several expressions (SeqUses already
            # composes a sequence correctly).
            if {[hir::kind $view $e] eq "countloop"} {
                set operands [list [hir::get $view $e start] [hir::get $view $e end]]
            } else {
                set operands [hir::loopOperands [dict get $view exprs $e]]
            }
            set prefix [SeqUses $view $b $loops $operands]
            lassign [SeqUses $view $b $loops [hir::get $view $e body]] bn ba
            set per [Max $bn $ba]
            if {$per > 0 && ![dict exists $loops $e]} {
                set per 2
            }
            lassign $prefix pn pa
            if {$pn < 0} {
                return $prefix
            }
            set total [Add $pn [Max $per 0]]
            return [list $total [Max $pa $total]]
        }
        handle {
            lassign [Uses $view $b $loops [hir::get $view $e call]] cn ca
            set worst [Max $cn $ca 0]
            set hn -1
            set ha -1
            foreach body [hir::get $view $e handlerBodies] {
                lassign [SeqUses $view $b $loops $body] n a
                set hn [Max $hn $n]
                set ha [Max $ha $a]
            }
            set n [Max $cn [expr {$hn >= 0 ? [Add $worst $hn] : -1}]]
            set a [Max $ca [expr {$ha >= 0 ? [Add $worst $ha] : -1}]]
            return [list $n $a]
        }
    }
    # Any other kind: conservatively as its children, in order.
    return [SeqUses $view $b $loops [hir::children $view $e]]
}

# 1 if binding B is referenced at most once along every path through
# INFO's region (see Uses).
proc hir::construction::Linear {info b} {
    set view [dict get $info view]
    set parent [dict get $info parent]
    set loops [dict create]
    set declaredBy [dict get [hir::binding $view $b] declaredBy]
    for {set e $declaredBy} {$e ne "" && [dict exists $parent $e]} {set e [dict get $parent $e]} {
        set p [dict get $parent $e]
        switch -- [hir::kind $view $p] {
            loop {
                dict set loops $p 1
            }
            listloop {
                if {$e ne [hir::get $view $p iterable]} {
                    dict set loops $p 1
                }
            }
            countloop {
                if {$e ne [hir::get $view $p start] && $e ne [hir::get $view $p end]} {
                    dict set loops $p 1
                }
            }
            lockloop {
                if {$e ni [hir::loopOperands [dict get $view exprs $p]]} {
                    dict set loops $p 1
                }
            }
        }
    }
    lassign [SeqUses $view $b $loops [dict get $info topBody]] n a
    return [expr {[Max $n $a] <= 1}]
}

# The single construction family every reference to B in INFO's region has
# ("" if they disagree, are not String/List-typed, or there are none).
proc hir::construction::RefFamily {info b} {
    set view [dict get $info view]
    set refs [dict get $info refs]
    if {![dict exists $refs $b]} {
        return ""
    }
    set family ""
    foreach r [dict get $refs $b] {
        set f [Family [hir::typeOf $view $r]]
        if {$f eq "" || ($family ne "" && $f ne $family)} {
            return ""
        }
        set family $f
    }
    return $family
}

# ---------------------------------------------------------------------------
# Plan sources and plan positions (given the current fixpoint state S)

# "" | str | list: whether E (in instance ID) produces a construction.
proc hir::construction::Source {s id e} {
    set info [dict get $s regions $id]
    set view [dict get $info view]
    switch -- [hir::kind $view $e] {
        call {
            set name [NativeName $view $e]
            set args [hir::get $view $e args]
            if {$name eq "str::concat" && [llength $args] == 2} {
                return str
            }
            # A substring is a one-piece construction: its StringRegion
            # (native/lower.tcl's region piece), never copied into a String
            # of its own while it only flows on into a construction.
            if {$name eq "str::substring" && [llength $args] == 3} {
                return str
            }
            if {$name eq "list::append" && [llength $args] == 2
                    && [Family [hir::typeOf $view [lindex $args 0]]] eq "list"} {
                return list
            }
            set calls [dict get $info instance calls]
            if {$name eq "" && [dict exists $calls $e]} {
                set callee [dict get $calls $e]
                if {[dict exists $s results $callee]} {
                    return [dict get $s results $callee]
                }
            }
            return ""
        }
        ref {
            set b [hir::get $view $e binding]
            if {$b ne "" && [dict exists $s bindings $id $b]} {
                return [dict get $s bindings $id $b]
            }
            return ""
        }
        if {
            set family [Family [hir::typeOf $view $e]]
            if {$family eq ""} {
                return ""
            }
            foreach role {thenBody elseBody} {
                set body [hir::get $view $e $role]
                if {$body ne "" && [Source $s $id [lindex $body end]] eq $family} {
                    return $family
                }
            }
            return ""
        }
    }
    return ""
}

# 1 if E is the trailing value of instance ID's region (one of its exits).
proc hir::construction::TrailingExit {info e} {
    set top [dict get $info topBody]
    return [expr {$top ne "" && [lindex $top end] eq $e}]
}

# {1 ""} if E (a plan-producing expression of instance ID) is consumed in a
# plan position, else {0 REASON}: why its consumer needs a flat value.
proc hir::construction::Context {s id e} {
    set info [dict get $s regions $id]
    set view [dict get $info view]
    set parent [dict get $info parent]
    set block [dict get $info block]
    if {![dict exists $parent $e]} {
        if {[TrailingExit $info $e]} {
            if {$block eq "program"} {
                return {0 "final observable result"}
            }
            if {[dict exists $s results $id]} {
                return {1 ""}
            }
            return [list 0 [ReturnReason $s $id]]
        }
        return {0 "discarded statement value"}
    }
    set p [dict get $parent $e]
    switch -- [hir::kind $view $p] {
        call {
            set args [hir::get $view $p args]
            set k [lsearch -exact $args $e]
            if {$k < 0} {
                return {0 "called as a callee"}
            }
            set name [NativeName $view $p]
            if {$name eq "str::concat"} {
                return {1 ""}
            }
            if {$name eq "list::append"} {
                if {$k == 0} {
                    return {1 ""}
                }
                return {0 "storage into an aggregate (List element)"}
            }
            if {$name eq "list"} {
                return {0 "storage into an aggregate (List element)"}
            }
            if {$name ne ""} {
                return [list 0 "flat-only native operation ($name)"]
            }
            set calls [dict get $info instance calls]
            if {![dict exists $calls $p]} {
                return {0 "dynamic/open call"}
            }
            set callee [dict get $calls $p]
            if {[dict exists $s params $callee $k]} {
                return {1 ""}
            }
            return [list 0 "exact call to a parameter that is not a plan parameter ([ParamReason $s $callee $k])"]
        }
        bind {
            set b [hir::get $view $p binding]
            if {[dict exists $s bindings $id $b]} {
                return {1 ""}
            }
            return [list 0 [LocalReason $s $id $b]]
        }
        return {
            if {[hir::get $view $p target] ne $block} {
                return {0 "return from a nested block"}
            }
            if {$block eq "program"} {
                return {0 "final observable result"}
            }
            if {[dict exists $s results $id]} {
                return {1 ""}
            }
            return [list 0 [ReturnReason $s $id]]
        }
        if {
            if {$e eq [hir::get $view $p condition]} {
                return {0 "if condition"}
            }
            foreach role {thenBody elseBody} {
                set body [hir::get $view $p $role]
                if {$body ne "" && [lindex $body end] eq $e} {
                    if {[Source $s $id $p] eq ""} {
                        return {0 "unsupported branch join"}
                    }
                    if {![dict exists $parent $p] && ![TrailingExit $info $p]} {
                        return {0 "discarded statement value"}
                    }
                    return [Context $s $id $p]
                }
            }
            return {0 "discarded statement value"}
        }
        ok - error {
            return {0 "storage into an aggregate (Result payload)"}
        }
        break {
            return {0 "loop break value"}
        }
        listloop - loop {
            if {[hir::kind $view $p] eq "listloop" && $e eq [hir::get $view $p iterable]} {
                return {0 "flat-only operation (listloop iterable)"}
            }
            return {0 "loop body value (collected or discarded)"}
        }
        countloop {
            if {$e eq [hir::get $view $p start] || $e eq [hir::get $view $p end]} {
                return {0 "flat-only operation (countloop bound)"}
            }
            return {0 "loop body value (collected or discarded)"}
        }
        lockloop {
            if {$e in [hir::loopOperands [dict get $view exprs $p]]} {
                return {0 "flat-only operation (lockloop domain operand)"}
            }
            return {0 "loop body value (collected or discarded)"}
        }
        handle {
            return {0 "handled call result"}
        }
    }
    return [list 0 "other ([hir::kind $view $p])"]
}

proc hir::construction::ReturnReason {s id} {
    if {![dict exists $s closed $id]} {
        return "return to an unknown/open caller"
    }
    if {[dict exists $s companioned $id]} {
        return "return from an instance with a companion variant"
    }
    return "return to exact callers that never extend the result"
}

proc hir::construction::ParamReason {s id k} {
    if {![dict exists $s regions $id]} {
        return "callee not analyzed"
    }
    if {[dict exists $s paramWhy $id $k]} {
        return [dict get $s paramWhy $id $k]
    }
    return "no caller passes a construction there"
}

proc hir::construction::LocalReason {s id b} {
    if {[dict exists $s localWhy $id $b]} {
        return [dict get $s localWhy $id $b]
    }
    return "not a plan local"
}

# ---------------------------------------------------------------------------
# Entry point

# The virtual-construction analysis of program HIR under specialization SPEC,
# given the other representation analyses native/lower.tcl already ran
# (their own variants/bindings are left to them: see the file header).
# Returns a dict:
#   params    InstanceId -> ParamIndex -> family (plan parameters)
#   bindings  InstanceId -> BindingId -> family (plan params and plan locals)
#   locals    InstanceId -> BindingId -> family (plan locals only)
#   results   InstanceId -> family (plan-result instances)
#   closed    set of closed instances (InstanceClosed)
#   regions   InstanceId -> RegionInfo (for audit/explain)
#   paramWhy/localWhy  why a String/List-typed candidate was declined
proc hir::construction::analyze {hir spec escape stringregion blockescape} {
    set s [dict create params {} bindings {} locals {} results {} closed {} companioned {} \
        regions {} paramWhy {} localWhy {}]
    set used [dict get $spec used]
    foreach id $used {
        dict set s regions $id [RegionInfo $hir $spec $id]
        # The authoritative closedness proof (hir::specialize's `closed`,
        # computed once at the stable point); a hand-built SPEC without it
        # falls back to the identical InstanceClosed over BLOCKESCAPE.
        if {[dict exists $spec closed] ? [dict exists $spec closed $id]
                : [hir::specialize::InstanceClosed $spec $blockescape $id]} {
            dict set s closed $id 1
        }
        if {[hir::escape::wants $escape $id] || [hir::escape::paramWants $escape $id]
                || [hir::stringregion::wants $stringregion $id]} {
            dict set s companioned $id 1
        }
    }

    # Candidates that do not depend on the fixpoint: statically-typed,
    # uncaptured, linear bindings.
    set paramCandidates [dict create]
    set localCandidates [dict create]
    foreach id $used {
        set info [dict get $s regions $id]
        set view [dict get $info view]
        set captured [dict get $info captured]
        if {[dict get $info block] ne "program" && ![hir::escape::paramWants $escape $id]} {
            set k 0
            foreach p [dict get $info params] {
                set family [RefFamily $info $p]
                if {$family eq ""} {
                    # Not a String/List construction candidate at all.
                } elseif {[dict exists $captured $p]} {
                    dict set s paramWhy $id $k "captured by a nested block (fork/alias)"
                } elseif {![Linear $info $p]} {
                    dict set s paramWhy $id $k "fork: referenced more than once on some path"
                } else {
                    dict set paramCandidates $id $k [list $p $family]
                }
                incr k
            }
        }
        set parent [dict get $info parent]
        # A bind whose own value is a sequence's value (a body's or branch's
        # trailing position) must still produce that value as one register:
        # left to ordinary lowering, like hir/escape.tcl's own exclusion.
        set trailing [hir::escape::TrailingPositions $view [dict get $info topBody] [dict get $info exprs]]
        foreach e [dict get $info exprs] {
            if {[hir::kind $view $e] ne "bind"} {
                continue
            }
            set b [hir::get $view $e binding]
            set family [Family [hir::typeOf $view [hir::get $view $e value]]]
            if {$family eq ""} {
                continue
            }
            set why ""
            if {[hir::get $view $e duplicate]} {
                set why "duplicate binding"
            } elseif {[dict get [hir::binding $view $b] kind] ne "local"} {
                set why "not a local binding"
            } elseif {[dict exists $captured $b]} {
                set why "captured by a nested block (fork/alias)"
            } elseif {[dict exists $trailing $e]} {
                set why "trailing-position binding"
            } elseif {[hir::escape::virtualArity $escape $id $b] ne ""
                    || [hir::stringregion::virtual $stringregion $id $b]
                    || [hir::blockescape::virtual $blockescape $id $b] ne ""} {
                set why "claimed by another representation analysis"
            } elseif {![Linear $info $b]} {
                set why "fork: referenced more than once on some path"
            }
            if {$why ne ""} {
                dict set s localWhy $id $b $why
                continue
            }
            dict set localCandidates $id $b [list $e $family]
        }
    }

    # Call sites: callee InstanceId -> list of {caller-id call-expr}.
    set callers [dict create]
    foreach id $used {
        dict for {e callee} [dict get $s regions $id instance calls] {
            dict lappend callers $callee [list $id $e]
        }
    }

    set changed 1
    while {$changed} {
        set changed 0
        # Plan locals: a candidate whose value is plan-producing.
        dict for {id candidates} $localCandidates {
            dict for {b entry} $candidates {
                lassign $entry bindExpr family
                if {[dict exists $s locals $id $b]} {
                    continue
                }
                set value [hir::get [dict get $s regions $id view] $bindExpr value]
                if {[Source $s $id $value] eq $family} {
                    dict set s locals $id $b $family
                    dict set s bindings $id $b $family
                    set changed 1
                }
            }
        }
        # Plan params: some direct call passes a plan-producing argument.
        dict for {id candidates} $paramCandidates {
            dict for {k entry} $candidates {
                lassign $entry p family
                if {[dict exists $s params $id $k]} {
                    continue
                }
                if {![dict exists $callers $id]} {
                    continue
                }
                set supplied 0
                foreach site [dict get $callers $id] {
                    lassign $site caller callExpr
                    set callerView [dict get $s regions $caller view]
                    set args [hir::get $callerView $callExpr args]
                    if {$k < [llength $args] && [Source $s $caller [lindex $args $k]] eq $family} {
                        set supplied 1
                        break
                    }
                }
                if {!$supplied} {
                    continue
                }
                # ... and the parameter itself continues the construction
                # somewhere (a concat operand, a plan argument, a plan-result
                # exit): a parameter whose every use needs a flat value would
                # only make its callers build a plan object for the callee to
                # materialize at once -- one allocation more than eager.
                set trial $s
                dict set trial params $id $k $family
                dict set trial bindings $id $p $family
                set continues 0
                foreach r [dict get $s regions $id refs $p] {
                    if {[lindex [Context $trial $id $r] 0]} {
                        set continues 1
                        break
                    }
                }
                if {$continues} {
                    dict set s params $id $k $family
                    dict set s bindings $id $p $family
                    set changed 1
                } else {
                    dict set s paramWhy $id $k "every use needs a flat value"
                }
            }
        }
        # Plan results: closed, String/List-typed, some call consumed in a
        # plan position.
        foreach id $used {
            if {[dict exists $s results $id] || ![dict exists $s closed $id]
                    || [dict exists $s companioned $id] || ![dict exists $callers $id]} {
                continue
            }
            set info [dict get $s regions $id]
            if {[dict get $info block] eq "program"} {
                continue
            }
            set family [Family [dict get $info instance result]]
            if {$family eq ""} {
                continue
            }
            foreach site [dict get $callers $id] {
                lassign $site caller callExpr
                if {$caller eq $id && [dict exists [dict get $spec context selfTails] $callExpr]} {
                    continue
                }
                # As if ID were already a plan result: is this call's own
                # consumer a plan position?
                set trial $s
                dict set trial results $id $family
                if {[lindex [Context $trial $caller $callExpr] 0]} {
                    dict set s results $id $family
                    set changed 1
                    break
                }
            }
        }
    }
    foreach id [dict keys [dict get $s params]] {
        dict for {k family} [dict get $s params $id] {
            if {[dict exists $s paramWhy $id $k]} {
                dict unset s paramWhy $id $k
            }
        }
    }
    return $s
}

proc hir::construction::paramFamily {analysis id k} {
    if {[dict exists $analysis params $id $k]} {
        return [dict get $analysis params $id $k]
    }
    return ""
}

proc hir::construction::localFamily {analysis id b} {
    if {[dict exists $analysis locals $id $b]} {
        return [dict get $analysis locals $id $b]
    }
    return ""
}

proc hir::construction::resultFamily {analysis id} {
    if {[dict exists $analysis results $id]} {
        return [dict get $analysis results $id]
    }
    return ""
}

# The plan-parameter indices of instance ID, ascending.
proc hir::construction::planParams {analysis id} {
    if {![dict exists $analysis params $id]} {
        return {}
    }
    return [lsort -integer [dict keys [dict get $analysis params $id]]]
}

# ---------------------------------------------------------------------------
# Provenance (spec items 37, 73-74): never consulted by lowering.

# One record per construction site (a native concat/list::append call) and
# per plan-producing reference/call, in every used instance of SPEC: a dict
# with instance (label), expr, location, family, operation, disposition
# ("virtual" when consumed in a plan position, else "materialized") and
# reason (the barrier category, "" when virtual).
proc hir::construction::audit {hir spec analysis} {
    set records {}
    foreach id [dict get $spec used] {
        set info [dict get $analysis regions $id]
        set view [dict get $info view]
        foreach e [dict get $info exprs] {
            if {![hir::get $view $e reachable]} {
                continue
            }
            set family [Source $analysis $id $e]
            if {$family eq ""} {
                continue
            }
            set kind [hir::kind $view $e]
            set name [NativeName $view $e]
            set operation [expr {$name ne "" ? $name : ($kind eq "call" ? "call (plan result)" : $kind)}]
            lassign [Context $analysis $id $e] virtual reason
            set origin [hir::get $view $e origin]
            lappend records [dict create instance [hir::specialize::label $spec $id] expr $e \
                location [hir::aot::Location $view $origin] family $family operation $operation \
                disposition [expr {$virtual ? "virtual" : "materialized"}] reason $reason]
        }
    }
    return $records
}

# Human-readable summary of ANALYSIS (never consulted by lowering), in the
# spirit of hir::stringregion::explain.
proc hir::construction::explain {hir spec analysis} {
    set lines {}
    foreach id [dict get $spec used] {
        set info [dict get $analysis regions $id]
        set view [dict get $info view]
        set entries {}
        if {[dict exists $analysis results $id]} {
            lappend entries "  result: may be a [dict get $analysis results $id] plan (closed; exact callers extend it)"
        }
        foreach k [planParams $analysis $id] {
            set p [lindex [dict get $info params] $k]
            lappend entries "  parameter $k ([dict get [hir::binding $view $p] name]): accepts a [dict get $analysis params $id $k] plan"
        }
        if {[dict exists $analysis locals $id]} {
            dict for {b family} [dict get $analysis locals $id] {
                lappend entries "  local [dict get [hir::binding $view $b] name] ($b): a $family plan, one continuation"
            }
        }
        if {$entries ne ""} {
            lappend lines "[hir::specialize::label $spec $id] ($id):" {*}$entries
        }
    }
    if {$lines eq ""} {
        return "no virtual construction was recognized"
    }
    return [join $lines \n]
}
