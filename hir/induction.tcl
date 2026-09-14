# induction.tcl -- the equality-termination induction-variable proof.
#
#   set induction [hir::induction::analyze $hir $spec $seeds]
#   hir::induction::of $induction $instanceId $paramIndex   -> a Range or ""
#   hir::induction::reason $induction $instanceId $paramIndex -> "" or a string
#
# This is the one genuinely new relational fact this milestone adds, kept
# deliberately narrow (see the milestone's #10, #16-19): it recognizes only
#
#   fn f(..., i, ...):
#       if i == B:            ; # or B == i
#           <terminates: return/break/raise, no else>
#       ...                   ; # siblings of the if, in the same body list
#       f(..., i + 1, ...)    ; # or i - 1: a self tail call, step exactly +-1
#
# and, when every soundness condition below holds, concludes i's Range is
# [i0, B.max] (or, decreasing, [B.min, i0]) for hir/range.tcl's fixpoint to
# use as i's *fixed* starting assumption (see analyze's -- er, hir::range::
# analyze's -- integration, which never widens an index this module locked).
#
# hir/range.tcl's own branch-derived narrowing (ComparisonNarrowing) already
# handles every `< <= > >=` guard soundly and generally: `if i >= n: return`
# narrows the fallthrough's `i` to `i < n` directly, which the ordinary
# self-call interval fixpoint then converges on with no help from this
# module. Only `==` termination needs a *different* argument (equality alone
# proves nothing about magnitude: #15), which is exactly what this module
# supplies: given a constant step of exactly +-1, i cannot skip past B, so
# provided i starts on the correct side of B (checked explicitly below, not
# assumed) it is squeezed between its initial value and B for the life of
# the loop.
#
# What this module deliberately does NOT do (see the milestone's #10,
# #23-24): reorder/simplify expressions, look inside a callee, follow a step
# through anything but literal `i + c` / `i - c` / `i` unchanged, accept a
# step other than +-1, or search anywhere but the instance's own top-level
# body list for the guard and the self-tail calls it must dominate. Anything
# else safely produces no fact; hir/range.tcl's ordinary (and, since this
# milestone, narrowing-aware) analysis is always still exact for what it
# does prove, so a program this module cannot help with is not a regression.
#
# Termination and cost (#22, #53): one linear scan of each self-tail
# instance's top-level body and call sites, no fixpoint of its own.

namespace eval hir::induction {
}

# ---------------------------------------------------------------------------
# Per-argument classification: what a self-tail call's argument at a
# candidate parameter's position does to it.

# The Int value of expression E if it is a plain integer literal, else "".
proc hir::induction::ConstInt {hir e} {
    if {[hir::kind $hir $e] ne "const"} {
        return ""
    }
    set v [hir::get $hir $e value]
    if {[core::value::kind $v] ne "int"} {
        return ""
    }
    return [core::value::intOf $v]
}

# 1 if bound value A <= bound value B (each an arbitrary-precision integer,
# -inf, or +inf), never doing arithmetic on the -inf/+inf sentinels.
proc hir::induction::BoundLE {a b} {
    if {$a eq "-inf" || $b eq "+inf"} {
        return 1
    }
    if {$a eq "+inf" || $b eq "-inf"} {
        return 0
    }
    return [expr {$a <= $b}]
}

# 1 if REF is a `ref` to binding B.
proc hir::induction::IsRefTo {hir ref b} {
    return [expr {[hir::kind $hir $ref] eq "ref" && [hir::get $hir $ref binding] eq $b}]
}

# How self-tail call argument ARGEXPR treats candidate parameter binding P:
# "identity" (P unchanged), {step C} (P + C, C a literal, possibly
# negative), or "other" (anything else -- including a non-literal step, e.g.
# replace's `index + length(needle)`, or an opaque one, e.g. csv's
# `list_get(scanned, 1)`: both correctly fall back here).
proc hir::induction::ClassifyArg {hir argExpr p} {
    if {[IsRefTo $hir $argExpr $p]} {
        return identity
    }
    if {[hir::kind $hir $argExpr] ne "call"} {
        return other
    }
    lassign [hir::get $hir $argExpr target] targetKind target
    if {$targetKind ne "native"} {
        return other
    }
    set name [dict get [hir::symbol $hir $target] name]
    if {$name ni {+ -}} {
        return other
    }
    set args [hir::get $hir $argExpr args]
    if {[llength $args] != 2} {
        return other
    }
    lassign $args ea eb
    if {[IsRefTo $hir $ea $p]} {
        set c [ConstInt $hir $eb]
        if {$c eq ""} {
            return other
        }
        return [list step [expr {$name eq "+" ? $c : -$c}]]
    }
    if {$name eq "+" && [IsRefTo $hir $eb $p]} {
        set c [ConstInt $hir $ea]
        if {$c eq ""} {
            return other
        }
        return [list step $c]
    }
    return other
}

# How EVERY self-tail call (CALLS, a list of their argument-expression
# lists, one per call site, positionally aligned with PARAMS) treats
# candidate parameter binding P: the single classification every call site
# agrees on, or "other" if any disagree or any site classifies it "other".
proc hir::induction::ClassifyParam {hir calls index p} {
    set result ""
    foreach args $calls {
        set c [ClassifyArg $hir [lindex $args $index] $p]
        if {$c eq "other"} {
            return other
        }
        if {$result eq ""} {
            set result $c
        } elseif {$result ne $c} {
            return other
        }
    }
    return $result
}

# ---------------------------------------------------------------------------
# The bound term

# The Range of expression E when used as a stable upper/lower bound: a
# context-free native-metadata fact (hir::range::SeedRange: a literal, or a
# direct length(...)/list_length(...)-shaped call) or, if E refers to one of
# this instance's own parameters, that parameter's *external* seed (spec
# #20-21's stability requirement: PARAMS/CLASSIFICATIONS must show it is
# passed unchanged -- "identity" -- on every self-tail call, so its value
# during the loop is always its external seed). Anything else: unknown.
proc hir::induction::BoundRange {hir e params classifications seeds} {
    set r [hir::range::SeedRange $hir $e]
    if {![hir::range::isUnknown $r]} {
        return $r
    }
    if {[hir::kind $hir $e] ne "ref"} {
        return [hir::range::unknown]
    }
    set b [hir::get $hir $e binding]
    set index [lsearch -exact $params $b]
    if {$index < 0 || [lindex $classifications $index] ne "identity"} {
        return [hir::range::unknown]
    }
    return [lindex $seeds $index]
}

# ---------------------------------------------------------------------------
# The guard: an `if i == B` / `if B == i` (or, for a decreasing candidate,
# any of `==`) at the top level of BODY, whose true branch terminates
# normally (return/break/raise -- never falls through) with no else, and
# whose false-branch continuation (BODY's members after it) contains every
# one of P's self-tail calls. Returns the bound expression B, or "".

proc hir::induction::TerminatingBranch {hir exprs} {
    if {$exprs eq ""} {
        return 0
    }
    # return: never completes normally. break/continue: HIR kinds that would
    # only appear inside an enclosing `loop`, included for completeness --
    # the corpus's self-tail-recursive functions have no `loop` node, so
    # these never actually match, but a `return`-guarded fn is proven safe
    # exactly the same way regardless.
    return [expr {[hir::kind $hir [lindex $exprs end]] in {return break continue}}]
}

proc hir::induction::Guard {hir body p selfCallExprs} {
    for {set i 0} {$i < [llength $body]} {incr i} {
        set stmt [lindex $body $i]
        if {[hir::kind $hir $stmt] ne "if"} {
            continue
        }
        set node [hir::node $hir $stmt]
        if {[dict get $node elseBody] ne "" || ![TerminatingBranch $hir [dict get $node thenBody]]} {
            continue
        }
        set condition [dict get $node condition]
        if {[hir::kind $hir $condition] ne "call"} {
            continue
        }
        lassign [hir::get $hir $condition target] targetKind target
        if {$targetKind ne "native" || [dict get [hir::symbol $hir $target] name] ne "=="} {
            continue
        }
        set args [hir::get $hir $condition args]
        if {[llength $args] != 2} {
            continue
        }
        lassign $args ea eb
        if {[IsRefTo $hir $ea $p]} {
            set bound $eb
        } elseif {[IsRefTo $hir $eb $p]} {
            set bound $ea
        } else {
            continue
        }
        # Every self-tail call of P must be a sibling after this guard (not
        # nested inside some other, unproven, control-flow shape: #10, #24).
        set after [lrange $body [expr {$i + 1}] end]
        set ok 1
        foreach c $selfCallExprs {
            if {$c ni $after} {
                set ok 0
                break
            }
        }
        if {$ok} {
            # Both the bound and the condition's own expression id: the
            # latter lets hir::range::analyze recognize, during its own walk
            # of this *same* "if" (same HIR, same expression ids), that its
            # false branch is exactly the P != B this proof already
            # soundly turned into "P < B" (increasing) / "P > B"
            # (decreasing) -- see hir::range::ComparisonNarrowing's `monotone`
            # handling. Without that, P's ref expression inside the
            # continuing branch keeps the *unnarrowed* [initial, B.max]
            # range, and P + step's computed range overshoots fitsSmall by
            # exactly one step at the boundary.
            return [list $condition $bound]
        }
    }
    return ""
}

# ---------------------------------------------------------------------------
# Entry point

# Induction facts for every used instance of specialization SPEC over
# program HIR, given SEEDS (hir::range::ExternalSeeds's result -- computed
# once, reused rather than recomputed). Returns a dict:
#   instances  InstanceId -> {ParamIndex Range ...}   proven overrides
#   reasons    InstanceId -> {ParamIndex Reason ...}  why an attempted
#              (step-classified) parameter was not proven
proc hir::induction::analyze {hir spec seeds} {
    set context [dict get $spec context]
    set selfTails [dict get $context selfTails]
    set instances [dict create]
    set reasons [dict create]
    set allMonotone [dict create]
    foreach id [dict get $spec used] {
        set instance [dict get $spec instances $id]
        set block [dict get $instance block]
        if {$block eq "program"} {
            continue
        }
        set selfCallExprs {}
        foreach {callExpr target} [dict get $instance calls] {
            if {$target eq $id && [dict exists $selfTails $callExpr]} {
                lappend selfCallExprs $callExpr
            }
        }
        if {$selfCallExprs eq ""} {
            continue
        }
        set params [hir::get $hir $block params]
        set n [llength $params]
        set calls [lmap c $selfCallExprs {hir::get $hir $c args}]
        set classifications [lmap p $params {ClassifyParam $hir $calls [lsearch -exact $params $p] $p}]
        set paramSeeds [expr {[dict exists $seeds $id] ? [dict get $seeds $id] : [lrepeat $n [hir::range::unknown]]}]
        set body [hir::get $hir $block body]
        set overrides [dict create]
        set monotone [dict create]
        for {set index 0} {$index < $n} {incr index} {
            set class [lindex $classifications $index]
            if {$class eq "" || [lindex $class 0] ne "step"} {
                continue
            }
            set step [lindex $class 1]
            set p [lindex $params $index]
            set guard [Guard $hir $body $p $selfCallExprs]
            if {$guard eq ""} {
                dict set reasons $id $index "unsupported relational form"
                continue
            }
            lassign $guard conditionExpr boundExpr
            if {abs($step) != 1} {
                dict set reasons $id $index "step may skip equality terminator"
                continue
            }
            set boundRange [BoundRange $hir $boundExpr $params $classifications $paramSeeds]
            set initial [lindex $paramSeeds $index]
            if {[hir::range::isUnknown $boundRange]} {
                dict set reasons $id $index "bound not stable"
                continue
            }
            if {$step > 0} {
                # #18's "i starts <= n": i's worst-case initial value must
                # not already be past B's best (smallest) case, or
                # incrementing by exactly 1 could overshoot B without ever
                # equalling it.
                if {![BoundLE [dict get $initial max] [dict get $boundRange min]]} {
                    dict set reasons $id $index "unsupported relational form"
                    continue
                }
                set bmax [dict get $boundRange max]
                if {$bmax eq "+inf"} {
                    dict set reasons $id $index "upper bound not machine-representable"
                    continue
                }
                dict set overrides $index [dict create min [dict get $initial min] max $bmax]
                dict set monotone $conditionExpr [list $p $step]
            } else {
                # The decreasing mirror (#19): i's best-case (smallest)
                # initial value must not already be below B's worst-case
                # (largest), or decrementing by exactly 1 could undershoot.
                if {![BoundLE [dict get $boundRange max] [dict get $initial min]]} {
                    dict set reasons $id $index "unsupported relational form"
                    continue
                }
                set bmin [dict get $boundRange min]
                if {$bmin eq "-inf"} {
                    dict set reasons $id $index "upper bound not machine-representable"
                    continue
                }
                dict set overrides $index [dict create min $bmin max [dict get $initial max]]
                dict set monotone $conditionExpr [list $p $step]
            }
        }
        if {[dict size $overrides]} {
            dict set instances $id $overrides
        }
        if {[dict size $monotone]} {
            dict set allMonotone $id $monotone
        }
    }
    return [dict create instances $instances reasons $reasons monotone $allMonotone]
}

# The {ConditionExprId {ParamBinding Step} ...} dict of instance ID's
# "if P == B" guards this module proved sound (P moves toward B by exactly
# Step per self-tail call, never skipping it): hir::range::ComparisonNarrowing
# consults this, keyed by the guard's own condition expression id, so P's ref
# expression inside that guard's continuing branch is narrowed exactly like a
# `<`/`>` guard would be (P != B plus this proof is exactly P < B / P > B),
# not left at its unnarrowed [initial, B] range.
proc hir::induction::monotone {induction id} {
    if {[dict exists [dict get $induction monotone] $id]} {
        return [dict get [dict get $induction monotone] $id]
    }
    return [dict create]
}

# The proven override Range of instance ID's parameter INDEX, or "".
proc hir::induction::of {induction id index} {
    if {[dict exists [dict get $induction instances] $id $index]} {
        return [dict get [dict get $induction instances] $id $index]
    }
    return ""
}

# Why instance ID's parameter INDEX was not proven, or "" (not attempted, or
# proven).
proc hir::induction::reason {induction id index} {
    if {[dict exists [dict get $induction reasons] $id $index]} {
        return [dict get [dict get $induction reasons] $id $index]
    }
    return ""
}
