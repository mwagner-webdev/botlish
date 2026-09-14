# range.tcl -- conservative integer range analysis and the representation
# facts it proves, for native/lower.tcl's local unboxing.
#
#   set analysis [hir::range::analyze $hir $spec]
#   hir::range::of $analysis $instanceId $exprId     -> a Range
#
# This is a *representation* analysis, strictly below the semantic layer:
# nothing here changes what a Botlish `Int` means (still arbitrary
# precision), HIR types, or hir/specialize.tcl's instances. It only adds a
# second, independent fact per expression of a used specialization instance
# (hir/specialize.tcl): a conservative bound on the mathematical integer a
# reachable Int-typed expression evaluates to, given the argument facts that
# instance's calls establish. native/lower.tcl consults it to decide which
# Int-typed NIR registers may be lowered as raw (untagged) machine integers
# instead of tagged Values (see the "Representation" section of lower.tcl).
#
# Range
# -----
# A Range is {min MIN max MAX}: MIN is -inf or an arbitrary-precision
# integer, MAX is an integer or +inf, always MIN <= MAX. unknown is
# {min -inf max +inf}: no useful bound. Host arithmetic is Tcl's own
# (arbitrary precision), so range computations themselves never overflow.
#
# Small-int bound
# ----------------
# smallMin/smallMax are the *only* definition of the runtime's tagged
# small-Int range (native/src/runtime/value.rs: (n << 1) | 1 on a 64-bit
# word, n in [-2^62, 2^62)); native/lower.tcl and this module both read them
# from here, and tests/native.test checks they match the runtime's actual
# boundary.
#
# What is analyzed
# -----------------
# analyze walks the region (hir::specialize view) of every used instance,
# computing a Range for each reachable expression: constants, `+ - *` of two
# known ranges (interval arithmetic; unknown if either operand is unknown),
# natives whose -result-range metadata promises a fact (core/native.tcl),
# references to a local/param binding (the range last bound to it on this
# path), and `if` branches (joined; the known-branch shortcut reuses
# hir::types::KnownOutcome so a statically decided condition does not lose
# precision). Every other expression's range is unknown: nothing here infers
# a bound from a call whose target's own result this pass has not computed,
# from a list/aggregate read, or from a branch condition (e.g. `i <
# length(xs)` proves nothing about i's range: that needs relational
# reasoning intervals cannot express, so it is not attempted; see #19 of the
# milestone this module was written for).
#
# Parameters: interprocedural seeding
# ------------------------------------
# A parameter's range is seeded only from the *literal* Int arguments passed
# to it by other instances' direct calls (ExternalSeeds: a syntactic look at
# each call's argument expressions, not a fixpoint over the caller's own
# analysis, so instances need no dependency order). A call from an instance
# back to itself (hir::specialize's `calls`, self tail calls and ordinary
# same-instance recursion alike) instead feeds back through a small internal
# fixpoint: analyze the region under the current assumption, see what range
# the self calls' arguments would have, join it into the assumption, and
# repeat (widening a bound to infinity the first time it grows, so this
# always reaches a fixed point in a few passes: see #16-18 of the milestone).
# A parameter with no literal external argument and no self-recursive
# feedback stays unknown (Option A of the milestone's #13: a parameter's
# incoming magnitude is never assumed small merely because it is a Botlish
# Int).
#
# This is deliberately not a full interprocedural analysis: a non-recursive
# instance's parameters are seeded once from literal arguments and never
# revisited. That is sound (seeding never over-approximates: unknown is
# always a safe fallback) but not maximally precise; it is enough to prove
# what the corpus needs (loop counters seeded by a literal 0) without a
# cross-instance worklist.

namespace eval hir::range {
    # The runtime's tagged small-Int range (see the file header).
    variable smallMin [expr {-(1 << 62)}]
    variable smallMax [expr {(1 << 62) - 1}]
    # Self-recursive parameter feedback passes before giving up (each pass
    # either converges or widens a bound to infinity, so few are needed).
    variable maxPasses 4
}

# ---------------------------------------------------------------------------
# The Range lattice

proc hir::range::unknown {} {
    return {min -inf max +inf}
}

proc hir::range::point {n} {
    return [dict create min $n max $n]
}

proc hir::range::nonneg {} {
    return [dict create min 0 max +inf]
}

proc hir::range::isUnknown {r} {
    return [expr {[dict get $r min] eq "-inf" && [dict get $r max] eq "+inf"}]
}

# 1 if every value in R is representable as a runtime small Int.
proc hir::range::fitsSmall {r} {
    variable smallMin
    variable smallMax
    set mn [dict get $r min]
    set mx [dict get $r max]
    return [expr {$mn ne "-inf" && $mx ne "+inf" && $mn >= $smallMin && $mx <= $smallMax}]
}

proc hir::range::Min {a b} {
    if {$a eq "-inf" || $b eq "-inf"} {
        return -inf
    }
    return [expr {$a < $b ? $a : $b}]
}

proc hir::range::Max {a b} {
    if {$a eq "+inf" || $b eq "+inf"} {
        return +inf
    }
    return [expr {$a > $b ? $a : $b}]
}

# The least upper bound of A and B: every value either could be. "never" (no
# value: dead code) is the bottom element.
proc hir::range::join {a b} {
    if {$a eq "never"} {
        return $b
    }
    if {$b eq "never"} {
        return $a
    }
    return [dict create min [Min [dict get $a min] [dict get $b min]] \
        max [Max [dict get $a max] [dict get $b max]]]
}

# NEW after a join of OLD with a freshly computed contribution: OLD with any
# bound that grew pushed to infinity, so repeated growth (an unbounded
# induction variable) reaches a fixed point in one step instead of counting
# up forever (see the milestone's #18).
proc hir::range::widen {old new} {
    set mn [dict get $new min]
    set mx [dict get $new max]
    if {$mn ne [dict get $old min]} {
        set mn -inf
    }
    if {$mx ne [dict get $old max]} {
        set mx +inf
    }
    return [dict create min $mn max $mx]
}

proc hir::range::AddBound {a b} {
    if {$a eq "-inf" || $b eq "-inf"} {
        return -inf
    }
    if {$a eq "+inf" || $b eq "+inf"} {
        return +inf
    }
    return [expr {$a + $b}]
}

# X - Y (a bound of a subtraction result): only ever called as (a.min,
# b.max) or (a.max, b.min), so a min operand is never +inf and a max operand
# is never -inf; every combination below is then well defined.
proc hir::range::SubBound {x y} {
    if {$x eq "-inf" || $y eq "+inf"} {
        return -inf
    }
    if {$x eq "+inf" || $y eq "-inf"} {
        return +inf
    }
    return [expr {$x - $y}]
}

proc hir::range::add {a b} {
    if {$a eq "never" || $b eq "never"} {
        return never
    }
    return [dict create min [AddBound [dict get $a min] [dict get $b min]] \
        max [AddBound [dict get $a max] [dict get $b max]]]
}

proc hir::range::sub {a b} {
    if {$a eq "never" || $b eq "never"} {
        return never
    }
    return [dict create min [SubBound [dict get $a min] [dict get $b max]] \
        max [SubBound [dict get $a max] [dict get $b min]]]
}

# The product's range from the four endpoint products, or unknown if any
# bound is infinite (a sound, simple fallback: see the milestone's #6).
proc hir::range::mul {a b} {
    if {$a eq "never" || $b eq "never"} {
        return never
    }
    set amin [dict get $a min]
    set amax [dict get $a max]
    set bmin [dict get $b min]
    set bmax [dict get $b max]
    if {$amin eq "-inf" || $amax eq "+inf" || $bmin eq "-inf" || $bmax eq "+inf"} {
        return [unknown]
    }
    set lo ""
    set hi ""
    foreach p [list [expr {$amin * $bmin}] [expr {$amin * $bmax}] [expr {$amax * $bmin}] [expr {$amax * $bmax}]] {
        if {$lo eq "" || $p < $lo} { set lo $p }
        if {$hi eq "" || $p > $hi} { set hi $p }
    }
    return [dict create min $lo max $hi]
}

proc hir::range::show {r} {
    if {$r eq "never"} {
        return never
    }
    set mn [dict get $r min]
    set mx [dict get $r max]
    return "\[[expr {$mn eq {-inf} ? "-∞" : $mn}], [expr {$mx eq {+inf} ? "+∞" : $mx}]\]"
}

# ---------------------------------------------------------------------------
# Interprocedural seeding

# The Int value of expression E if it is a plain integer literal, or
# unknown: a purely syntactic fact, so callers need not be analyzed first.
proc hir::range::LiteralRange {hir e} {
    if {[hir::kind $hir $e] ne "const"} {
        return [unknown]
    }
    set v [hir::get $hir $e value]
    if {[core::value::kind $v] ne "int"} {
        return [unknown]
    }
    return [point [core::value::intOf $v]]
}

# InstanceId -> list of Range, one per parameter: the join of the literal
# argument ranges every *other* used instance's direct calls pass it.
# Self-recursive calls are excluded (Analyze below feeds those back).
proc hir::range::ExternalSeeds {hir spec} {
    set seeds [dict create]
    foreach id [dict get $spec used] {
        set instance [dict get $spec instances $id]
        foreach {callExpr target} [dict get $instance calls] {
            if {$target eq $id} {
                continue
            }
            set targetBlock [dict get [dict get $spec instances $target] block]
            if {$targetBlock eq "program"} {
                continue
            }
            set nparams [llength [hir::get $hir $targetBlock params]]
            set current [expr {[dict exists $seeds $target] ? [dict get $seeds $target] : [lrepeat $nparams never]}]
            set next {}
            foreach argExpr [hir::get $hir $callExpr args] c $current {
                lappend next [join $c [LiteralRange $hir $argExpr]]
            }
            dict set seeds $target $next
        }
    }
    return $seeds
}

# ---------------------------------------------------------------------------
# One region, under one assumption of its parameters' ranges

# Types EXPRS in order (a block body, an if branch): the last one's range,
# or never if some expression never completes normally.
proc hir::range::Sequence {hirVar ctxVar exprs} {
    upvar 1 $hirVar hir $ctxVar ctx
    set result [unknown]
    foreach e $exprs {
        set result [Expr hir ctx $e]
        if {$result eq "never"} {
            break
        }
    }
    return $result
}

proc hir::range::Expr {hirVar ctxVar e} {
    upvar 1 $hirVar hir $ctxVar ctx
    if {![hir::get $hir $e reachable]} {
        return never
    }
    set node [hir::node $hir $e]
    switch -- [dict get $node kind] {
        const {
            set v [dict get $node value]
            set r [expr {[core::value::kind $v] eq "int" ? [point [core::value::intOf $v]] : [unknown]}]
            dict set ctx exprs $e $r
            return $r
        }
        ref {
            if {[dict get $node binding] eq "" || [dict get $node init] eq "no"} {
                return never
            }
            set b [dict get $node binding]
            set bindings [dict get $ctx bindings]
            set r [expr {[dict exists $bindings $b] ? [dict get $bindings $b] : [unknown]}]
            dict set ctx exprs $e $r
            return $r
        }
        bind {
            set r [Expr hir ctx [dict get $node value]]
            set b [dict get $node binding]
            if {$r ne "never" && ![dict get $node duplicate]
                    && [dict get [hir::binding $hir $b] kind] eq "local"} {
                dict set ctx bindings $b $r
            }
            return $r
        }
        block {
            # A nested block's body is its own region; nothing to compute here.
            return [unknown]
        }
        call {
            return [Call hir ctx $e $node]
        }
        if {
            return [If hir ctx $e $node]
        }
        loop {
            set saved [dict get $ctx bindings]
            foreach child [dict get $node body] {
                Expr hir ctx $child
            }
            dict set ctx bindings $saved
            return [unknown]
        }
        return {
            set value [dict get $node value]
            set r [expr {$value eq "" ? [unknown] : [Expr hir ctx $value]}]
            if {$r ne "never" && [dict get $node target] ne ""} {
                dict set ctx returnRange [join [dict get $ctx returnRange] $r]
            }
            return never
        }
        break {
            if {[dict get $node value] ne ""} {
                Expr hir ctx [dict get $node value]
            }
            return never
        }
        continue {
            return never
        }
        ok - error {
            set value [Expr hir ctx [dict get $node value]]
            return [expr {$value eq "never" ? "never" : [unknown]}]
        }
        default {
            return [unknown]
        }
    }
}

proc hir::range::Call {hirVar ctxVar e node} {
    upvar 1 $hirVar hir $ctxVar ctx
    set argRanges {}
    set dead 0
    foreach a [dict get $node args] {
        set r [Expr hir ctx $a]
        lappend argRanges $r
        if {$r eq "never"} {
            set dead 1
        }
    }
    if {$dead} {
        return never
    }
    lassign [dict get $node target] targetKind target
    if {$targetKind eq "native"} {
        set name [dict get [hir::symbol $hir $target] name]
        set result [unknown]
        if {$name in {+ - *} && [llength $argRanges] == 2} {
            lassign $argRanges x y
            switch -- $name {
                + { set result [add $x $y] }
                - { set result [sub $x $y] }
                * { set result [mul $x $y] }
            }
        } else {
            set meta [core::native::metadata $name]
            if {[dict get $meta resultRange] eq "nonneg"} {
                set result [nonneg]
            }
        }
        dict set ctx exprs $e $result
        return $result
    }
    if {$targetKind eq "block" && [dict exists [dict get $ctx instanceCalls] $e]
            && [dict get [dict get $ctx instanceCalls] $e] eq [dict get $ctx id]} {
        dict lappend ctx selfCalls $argRanges
    }
    return [unknown]
}

proc hir::range::If {hirVar ctxVar e node} {
    upvar 1 $hirVar hir $ctxVar ctx
    set condition [dict get $node condition]
    Expr hir ctx $condition
    set known [hir::types::KnownOutcome $hir $condition]
    set branches [dict create]
    foreach {outcome role} {1 then 0 else} {
        if {$known ne "" && $known != $outcome} {
            dict set branches $outcome never
            continue
        }
        set saved [dict get $ctx bindings]
        dict set branches $outcome [Sequence hir ctx [dict get $node ${role}Body]]
        dict set ctx bindings $saved
    }
    if {$known ne ""} {
        return [dict get $branches $known]
    }
    return [join [dict get $branches 1] [dict get $branches 0]]
}

# The region of instance ID's view HIR (already specialize::view'd): a dict
#   exprs      ExprId -> Range, for every reachable expression this pass
#              could say something about
#   result     the range of the region's normal completion (never if none)
#   selfCalls  list of argument-Range-lists, one per call this pass found
#              targeting this same instance (self tail calls and ordinary
#              same-instance recursion alike)
proc hir::range::AnalyzeInstance {hir id instanceCalls block params assumed} {
    set ctx [dict create bindings [dict create] returnRange never exprs [dict create] \
        selfCalls {} id $id instanceCalls $instanceCalls]
    foreach b $params r $assumed {
        dict set ctx bindings $b $r
    }
    set body [expr {$block eq "program" ? [hir::roots $hir] : [hir::get $hir $block body]}]
    set final [Sequence hir ctx $body]
    set result [join $final [dict get $ctx returnRange]]
    return [dict create exprs [dict get $ctx exprs] result $result selfCalls [dict get $ctx selfCalls]]
}

# ---------------------------------------------------------------------------
# Entry point

# Range facts for every used instance of specialization ANALYSIS (the return
# of hir::specialize::analyze) over program HIR. Returns a dict:
#   instances  InstanceId -> {params {Range ...} exprs {ExprId Range ...} result Range}
proc hir::range::analyze {hir spec} {
    variable maxPasses
    set seeds [ExternalSeeds $hir $spec]
    set instances [dict create]
    foreach id [dict get $spec used] {
        set instance [dict get $spec instances $id]
        set block [dict get $instance block]
        set params [expr {$block eq "program" ? {} : [hir::get $hir $block params]}]
        set n [llength $params]
        set assumed [expr {[dict exists $seeds $id] ? [dict get $seeds $id] : [lrepeat $n [unknown]]}]
        set view [hir::specialize::view $hir $spec $id]
        set instanceCalls [dict get $instance calls]
        set outcome {}
        for {set pass 1} {$pass <= $maxPasses} {incr pass} {
            set outcome [AnalyzeInstance $view $id $instanceCalls $block $params $assumed]
            set selfCalls [dict get $outcome selfCalls]
            if {$selfCalls eq ""} {
                break
            }
            set next {}
            for {set i 0} {$i < $n} {incr i} {
                set r never
                foreach call $selfCalls {
                    set r [join $r [lindex $call $i]]
                }
                lappend next [join [lindex $assumed $i] $r]
            }
            if {$next eq $assumed} {
                break
            }
            set widened {}
            foreach a $assumed w $next {
                lappend widened [widen $a $w]
            }
            set assumed $widened
        }
        dict set instances $id [dict create params $assumed exprs [dict get $outcome exprs] result [dict get $outcome result]]
    }
    return [dict create instances $instances]
}

# The Range of expression E as instance ID's analysis proved it, or unknown.
proc hir::range::of {analysis id e} {
    set exprs [dict get [dict get $analysis instances $id] exprs]
    if {[dict exists $exprs $e]} {
        return [dict get $exprs $e]
    }
    return [unknown]
}
