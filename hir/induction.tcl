# induction.tcl -- the equality-termination induction-variable proof.
#
#   set induction [hir::induction::analyze $hir $spec $seeds]
#   hir::induction::of $induction $instanceId $paramIndex   -> a Range or ""
#   hir::induction::reason $induction $instanceId $paramIndex -> "" or a string
#
# This is the one genuinely new relational fact this milestone adds, kept
# deliberately narrow (see the milestone's #10, #16-19): it recognizes
#
#   fn f(..., i, ...):
#       if i == B:            ; # or B == i
#           <terminates: return/break/raise/error, or, with no sibling
#            code after it in the same body, any normal value>
#       ...                   ; # siblings of the if, in the same body list
#       f(..., i + 1, ...)    ; # or i - 1: a self tail call, step exactly +-1
#
# (the top-level shape this module has always recognized) *or the same
# pattern with an explicit `else` in place of the guard's siblings* --
#
#   fn f(..., i, ...):
#       if i == B:
#           <terminates: any value, return, break, raise, error -- there is
#            no fallthrough into `else` to guard against, so any completion
#            mode is safe here, unlike the sibling-code case above>
#       else:
#           f(..., i + 1, ...)
#
# -- appearing either at an instance's own top level or nested beneath one
# or more *harmless wrapper* `if`s: an outer condition on a par with
# `integer? acc` (sum-refined.ir's own motivating shape -- see the milestone
# this module's header was written for) that constrains something other
# than i, where exactly one branch is where every one of i's self-tail
# calls actually is. Guard (below) is the recursive traversal that finds
# this, walking down through such wrappers instead of only scanning one
# fixed body list; TerminatingBranch and CoversAll are exactly as narrow as
# they always were, just callable at any depth reached this way.
#
# When every soundness condition below holds, i's Range is concluded to be
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
# Dominance (the milestone's #8-#9): a nested guard mints i's induction fact
# only when every one of i's self-tail calls is unconditionally reached
# through the guard's own continuing side (its `else`, or the sibling code
# after an elseless guard) -- never merely *somewhere* in the instance. Guard
# establishes this the same way at every nesting level: at each body it
# looks at, either the classic top-level shape matches directly (checked
# first, unchanged), or exactly one statement of that body can reach any of
# the self-tail calls at all (Reaches/AnyReaches, a plain "does this
# subtree mention one of these expression ids" search -- deliberately not
# itself a soundness argument) and that one statement is an `if` whose
# branches split the same way (exactly one live). A wrapper's *dead* branch
# -- proven, by the same search, to reach none of the calls -- needs no
# further look, whatever it computes or however it completes (#14: an
# `error` branch, an unrelated side path, anything): it is simply never on
# a path this proof is making a claim about. Two live branches, or none
# where the search expected exactly one, and Guard returns "" rather than
# guess (#28/#30/#31's non-dominating and ambiguous shapes: rejected this
# way, not by any special case).
#
# Binding identity (#11-#12): every comparison Guard/ClassifyArg/IsRefTo
# make is against P's own resolved BindingId, never a name, at every
# depth -- so a nested `bind` that happens to reuse i's name creates a
# distinct BindingId that simply never matches P, with no separate shadow
# check needed. Immutable parameters only (BoundRange/RefBinding's existing
# `param`-kind restriction, untouched): this module still never reasons
# about a mutable cell.
#
# What this module deliberately does NOT do (see the milestone's #10,
# #23-24): reorder/simplify expressions, look inside a callee, follow a step
# through anything but literal `i + c` / `i - c` / `i` unchanged, accept a
# step other than +-1, descend into a `loop` or a nested `block` (a
# different invocation) while looking for a wrapper's live branch, or
# recognize two self-tail calls whose updates disagree (ClassifyParam,
# unchanged, already forces "other" the moment call sites disagree, well
# before Guard ever runs). Anything else safely produces no fact;
# hir/range.tcl's ordinary (and, since an earlier milestone, narrowing-
# aware) analysis is always still exact for what it does prove, so a
# program this module cannot help with is not a regression.
#
# Termination and cost (#22, #53, #16's "avoid unbounded pathological
# recursion"): one bounded-depth traversal (maxNestingDepth) of each
# self-tail instance's body and call sites, no fixpoint of its own.

namespace eval hir::induction {
    # Guard's own recursion depth cap (spec #16's "avoid unbounded
    # pathological recursion in the analysis itself"): generous enough for
    # several harmless wrappers, never unbounded.
    variable maxNestingDepth 16
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
# any of `==`), whose true branch terminates -- return/break/raise/error,
# or (only when nothing after it needs protecting from a fallthrough: see
# below) any normal value -- and whose continuing side (an explicit `else`,
# or, when there is none, BODY's own siblings after the guard) contains
# every one of P's self-tail calls. Returns {conditionExpr boundExpr}, or
# "".

# EXPRS (a thenBody/elseBody) "terminates": it never falls through into
# AFTER (the guard's own continuing side). return/break/continue/error are
# non-local exits, safe regardless of AFTER (#15: Botlish's own semantic
# completions -- Value, Return, Error, Break, Continue -- and only the
# first of those can fall through at all). A bare, normally-completing
# value is *also* safe, but only when AFTER is empty: with nothing to
# protect, what the branch's own value is does not matter (this is exactly
# sum-refined's own guard -- `if n == 0: acc` with an explicit `else`, so
# AFTER, the sibling-code case's own notion of "what follows", is simply
# never consulted for it; see Guard's `elseBody ne ""` case below, which
# never calls this proc at all for that reason -- this proc only ever runs
# for the *elseless*, sibling-code shape, where AFTER can be non-empty).
proc hir::induction::TerminatingBranch {hir exprs after} {
    if {$exprs eq ""} {
        return 0
    }
    if {[hir::kind $hir [lindex $exprs end]] in {return break continue error}} {
        return 1
    }
    return [expr {$after eq ""}]
}

# 1 if the subtree rooted at expression E includes, anywhere reachable
# without crossing into a nested `block` (a different invocation this
# proof has no business following), any expression id in SELFCALLS. This
# is a plain "does it mention one" search, not itself a dominance argument
# (#8-#9's actual coverage proof is CoversAll, below, always literal and
# always at the specific body a guard's continuing side names) -- Guard
# only ever uses it to decide which single branch of a candidate wrapper
# to keep looking inside, never to conclude coverage by itself.
proc hir::induction::Reaches {hir e selfCallExprs} {
    if {$e in $selfCallExprs} {
        return 1
    }
    if {[hir::kind $hir $e] eq "block"} {
        return 0
    }
    foreach c [hir::children $hir $e] {
        if {[Reaches $hir $c $selfCallExprs]} {
            return 1
        }
    }
    return 0
}

proc hir::induction::AnyReaches {hir stmts selfCallExprs} {
    foreach s $stmts {
        if {[Reaches $hir $s $selfCallExprs]} {
            return 1
        }
    }
    return 0
}

# 1 if every one of SELFCALLEXPRS is a literal member of STMTS: the actual
# (always sound, never approximated) coverage proof, unchanged from what
# this module always required of the classic top-level shape's own
# siblings-after-the-guard, now also asked of an explicit guard's own
# `else` body.
proc hir::induction::CoversAll {stmts selfCallExprs} {
    foreach c $selfCallExprs {
        if {$c ni $stmts} {
            return 0
        }
    }
    return 1
}

# The equality bound B of condition COND against candidate parameter P
# (`P == B` or `B == P`), or "" if COND is not an `==` call naming P at
# all.
proc hir::induction::EqualityBound {hir cond p} {
    if {[hir::kind $hir $cond] ne "call"} {
        return ""
    }
    lassign [hir::get $hir $cond target] targetKind target
    if {$targetKind ne "native" || [dict get [hir::symbol $hir $target] name] ne "=="} {
        return ""
    }
    set args [hir::get $hir $cond args]
    if {[llength $args] != 2} {
        return ""
    }
    lassign $args ea eb
    if {[IsRefTo $hir $ea $p]} {
        return $eb
    }
    if {[IsRefTo $hir $eb $p]} {
        return $ea
    }
    return ""
}

proc hir::induction::Guard {hir body p selfCallExprs {depth 0}} {
    variable maxNestingDepth
    if {$depth > $maxNestingDepth} {
        return ""
    }

    # The classic top-level shape, unchanged: an elseless `if p == B` whose
    # true branch terminates, followed by every one of P's self-tail calls
    # as literal siblings in this same BODY.
    for {set i 0} {$i < [llength $body]} {incr i} {
        set stmt [lindex $body $i]
        if {[hir::kind $hir $stmt] ne "if"} {
            continue
        }
        set node [hir::node $hir $stmt]
        if {[dict get $node elseBody] ne ""} {
            continue
        }
        set after [lrange $body [expr {$i + 1}] end]
        if {![TerminatingBranch $hir [dict get $node thenBody] $after]} {
            continue
        }
        set bound [EqualityBound $hir [dict get $node condition] $p]
        if {$bound eq ""} {
            continue
        }
        if {[CoversAll $after $selfCallExprs]} {
            # Both the bound and the condition's own expression id: the
            # latter lets hir::range::analyze recognize, during its own walk
            # of this *same* "if" (same HIR, same expression ids), that its
            # false branch is exactly the P != B this proof already
            # soundly turned into "P < B" (increasing) / "P > B"
            # (decreasing) -- see hir::range::ComparisonNarrowing's `monotone`
            # handling. Without that, P's ref expression inside the
            # continuing branch keeps the *unnarrowed* [initial, B.max]
            # range, and P + step's computed range overshoots fitsSmall by
            # exactly one step at the boundary. The third element (DEPTH)
            # is diagnostic only (explain, below): how many harmless
            # wrappers this call peeled through to reach this guard.
            return [list [dict get $node condition] $bound $depth]
        }
    }

    # Nested shapes (#3, #10, #16): an `if`/`else` guard whose `else` is the
    # continuation (sum-refined's own shape), or a harmless wrapper around
    # either of these two forms. Exactly one statement of BODY may reach
    # any of P's self-tail calls at all -- every other statement (a sibling
    # before or after it, or its own sibling branch, once it is found) is
    # then provably off every relevant recursive path, so it is safe to
    # ignore without asking what it computes (#14, #17).
    set candidates {}
    foreach stmt $body {
        if {[Reaches $hir $stmt $selfCallExprs]} {
            lappend candidates $stmt
        }
    }
    if {[llength $candidates] != 1} {
        # None: no self-tail call is even reachable from BODY (a plain,
        # unrelated body -- not this proc's problem, and not necessarily a
        # failure: the caller tries this at every body it descends into).
        # More than one: two statements each reach a self-tail call with
        # nothing in this BODY relating them, so no single guard governs
        # every path this proof would need to (#28's non-dominating shape,
        # once its own outer wrapper has been peeled away).
        return ""
    }
    set stmt [lindex $candidates 0]
    if {[hir::kind $hir $stmt] ne "if"} {
        # A bare, unguarded self-tail call (or an expression otherwise
        # reaching one) at this level: #28's shape, and #38's own rule
        # against inventing a look-through for anything but an `if`.
        return ""
    }
    set node [hir::node $hir $stmt]
    set thenBody [dict get $node thenBody]
    set elseBody [dict get $node elseBody]
    set thenHas [AnyReaches $hir $thenBody $selfCallExprs]
    set elseHas [expr {$elseBody ne "" && [AnyReaches $hir $elseBody $selfCallExprs]}]
    if {$thenHas == $elseHas} {
        # Both branches (#30-#31's ambiguous/non-decreasing-on-one-path
        # shapes) reach a self-tail call: no single branch this guard could
        # be said to govern (#9). Neither reaching one is impossible given
        # CANDIDATES above (STMT itself would not have been a candidate),
        # kept only as a safe fallback rather than assumed.
        return ""
    }
    if {$elseHas} {
        # sum-refined's own shape (#1, #19): STMT's `else`, not sibling
        # code after an elseless `if`, is the recursive continuation.
        # thenBody -- proven above to reach no self-tail call -- can never
        # fall through into elseBody (they are alternatives of the same
        # `if`, not sequential), so no TerminatingBranch call applies here
        # at all: whatever thenBody computes and however it completes is
        # simply not on any path this proof is making a claim about (#15).
        set bound [EqualityBound $hir [dict get $node condition] $p]
        if {$bound ne "" && [CoversAll $elseBody $selfCallExprs]} {
            return [list [dict get $node condition] $bound $depth]
        }
        # STMT's own condition is not (or its `else` does not literally
        # hold every self-tail call, and this module never approximates
        # that) the guard itself: keep looking inside its `else` (#3's
        # "if guard_a: ... else: if n == 0: ..." shape).
        return [Guard $hir $elseBody $p $selfCallExprs [expr {$depth + 1}]]
    }
    # thenBody is live: by this pattern's own direction (`p == B`
    # terminates on *true*), STMT's condition can never itself soundly be
    # the guard here, so this is purely #10/#14's "harmless wrapper" case
    # (sum-refined's own outer `integer? acc`, or #16's further nesting).
    # elseBody, if any -- proven above to reach no self-tail call -- needs
    # no further look, whatever it computes (#14's error-branch shape).
    return [Guard $hir $thenBody $p $selfCallExprs [expr {$depth + 1}]]
}

# ---------------------------------------------------------------------------
# Entry point

# Induction facts for every used instance of specialization SPEC over
# program HIR, given SEEDS (hir::range::ExternalSeeds's result -- computed
# once, reused rather than recomputed). Returns a dict:
#   instances  InstanceId -> {ParamIndex Range ...}   proven overrides
#   reasons    InstanceId -> {ParamIndex Reason ...}  why an attempted
#              (step-classified) parameter was not proven
#   guards     InstanceId -> {ParamIndex {ConditionExprId BoundExprId
#              NestingDepth Step UpdateExprId} ...}  provenance for every
#              proven parameter (spec #40-#41): guard/explain, below, read
#              this purely for diagnostics -- nothing else in this module
#              consults it (the actual proof is `instances`/`monotone`)
proc hir::induction::analyze {hir spec seeds} {
    set context [dict get $spec context]
    set selfTails [dict get $context selfTails]
    set instances [dict create]
    set reasons [dict create]
    set allMonotone [dict create]
    set allGuards [dict create]
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
        set guards [dict create]
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
            lassign $guard conditionExpr boundExpr guardDepth
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
                dict set guards $index [list $conditionExpr $boundExpr $guardDepth $step [lindex $calls 0 $index]]
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
                dict set guards $index [list $conditionExpr $boundExpr $guardDepth $step [lindex $calls 0 $index]]
            }
        }
        if {[dict size $overrides]} {
            dict set instances $id $overrides
        }
        if {[dict size $monotone]} {
            dict set allMonotone $id $monotone
        }
        if {[dict size $guards]} {
            dict set allGuards $id $guards
        }
    }
    return [dict create instances $instances reasons $reasons monotone $allMonotone guards $allGuards]
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

# Instance ID's parameter INDEX's proven-guard provenance --
# {ConditionExprId BoundExprId NestingDepth Step UpdateExprId} -- or "" if
# nothing was proven there (see `reason`). Diagnostic-only (spec #40-#41):
# `of`/`monotone` above are the facts hir/range.tcl actually consumes.
proc hir::induction::guard {induction id index} {
    if {[dict exists [dict get $induction guards] $id $index]} {
        return [dict get [dict get $induction guards] $id $index]
    }
    return ""
}

# ---------------------------------------------------------------------------
# Diagnostics (spec #41-#42)

# A short, single-line rendering of expression E: just enough structure
# (a literal, a name, or a two-operand native call written infix) for a
# provenance report to name a guard/update by more than its bare ExprId.
# Not a general HIR printer (hir::format already is one) -- anything this
# module's own proof does not itself interpret renders as "<e...>".
proc hir::induction::ShortExpr {hir e} {
    switch -- [hir::kind $hir $e] {
        const {
            set v [hir::get $hir $e value]
            if {[core::value::kind $v] eq "int"} {
                return [core::value::intOf $v]
            }
            return "<$e>"
        }
        ref {
            return [dict get [hir::binding $hir [hir::get $hir $e binding]] name]
        }
        call {
            lassign [hir::get $hir $e target] targetKind target
            set args [hir::get $hir $e args]
            if {$targetKind eq "native" && [llength $args] == 2} {
                set name [dict get [hir::symbol $hir $target] name]
                return "[ShortExpr $hir [lindex $args 0]] $name [ShortExpr $hir [lindex $args 1]]"
            }
            return "<$e>"
        }
        default {
            return "<$e>"
        }
    }
}

# A short, human-readable report of every induction attempt (proven or
# not) on every used, non-generic instance of SPEC (hir::specialize::
# analyze -- read here only for instance labels and the used-instance
# list, never re-analyzed). One paragraph per instance that attempted at
# least one parameter; an instance with nothing attempted is omitted.
# Exact format is not contractual (spec #41 says as much); this exists so
# native/explain-native.tcl can show, per parameter: the guard's own
# condition expression and its nesting depth (how many harmless wrappers
# it was found beneath), the recursive update, and the resulting Range --
# or, when nothing was proven, `reason`'s own explanation.
proc hir::induction::explain {hir spec induction} {
    set paragraphs {}
    foreach id [dict get $spec used] {
        set instance [dict get $spec instances $id]
        set block [dict get $instance block]
        if {$block eq "program"} {
            continue
        }
        set params [hir::get $hir $block params]
        set lines {}
        for {set index 0} {$index < [llength $params]} {incr index} {
            set g [guard $induction $id $index]
            set r [reason $induction $id $index]
            if {$g eq "" && $r eq ""} {
                continue
            }
            set name [dict get [hir::binding $hir [lindex $params $index]] name]
            lappend lines "  induction parameter: $name (param $index)"
            if {$g eq ""} {
                lappend lines "    result: not proven ($r)"
                continue
            }
            lassign $g conditionExpr boundExpr depth step updateExpr
            lappend lines "    termination guard: $conditionExpr ([ShortExpr $hir $conditionExpr])"
            lappend lines "    guard nesting depth: $depth"
            lappend lines "    recursive update: $updateExpr ([ShortExpr $hir $updateExpr])"
            lappend lines "    result: bounded [expr {$step > 0 ? {increasing} : {decreasing}}]\
                induction [hir::range::show [of $induction $id $index]]"
        }
        if {$lines eq ""} {
            continue
        }
        lappend paragraphs "[hir::specialize::label $spec $id]\n[join $lines \n]"
    }
    return [join $paragraphs \n\n]
}
