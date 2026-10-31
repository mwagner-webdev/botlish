# intset.tcl -- the value domain of the modular emission checker
# (MODULAR-EMISSION-PROOFS-MILESTONE-1.md, "Value facts").
#
#   source audit/emission-proofs/tools/intset.tcl   (after hir/)
#
# An IntSet is a finite union of closed integer intervals: a sorted list of
# disjoint, non-adjacent {LO HI}, LO an Int or -inf, HI an Int or +inf; {} is
# no value (bottom), {{-inf +inf}} every Int. It is the *disjunctive
# completion* of hir::range's interval lattice, not a second fact system:
#
#   * every transfer function is hir::range's own, applied to each pair of
#     components and the results united (`Lift1`, `Lift2`): add, sub, mul,
#     Mod, BitOp, Narrowed, TypeFact, InductionBinding, RegisteredRange --
#     so the meaning of `+`, `mod`, `shift_right`, a comparison, a declared
#     integer domain or a native's -result-range is stated once, in
#     hir/range.tcl, and audited there;
#   * a component Range's exact value set (hir::range's `exact`, at most
#     maxExactValues points) becomes points (`OfRange`);
#   * the one rule hir::range does not have is the reason the domain
#     exists: `x != K` (an `==` comparison false against a single point)
#     removes K from the middle of a component (`Narrow`), where
#     hir::range::PointEqualityNarrow can only filter an exact set. JSON's
#     string escaping (`c == 34 or c == 92` false) and a scalar value's
#     surrogate gap need exactly that.
#
# Bounds are true infinities, never sentinels: a value past any bound the
# recognizers use is still a value (`ToDfa` maps a set into
# surface/dfa.tcl's interval space by clamping, never by intersecting --
# the exploratory checker's intersection with its sentinel range dropped
# 10^23 from a yield and certified the emitter: census case
# `sentinel-overflow`).
#
# The number of components is bounded (maxComponents); past it a result is
# its hull -- fewer facts, always sound.

namespace eval intset {
    variable maxComponents 48
}

# -- bounds ------------------------------------------------------------------

# -1, 0, 1 as bound A is below, equal to or above bound B.
proc intset::Cmp {a b} {
    if {$a eq $b} { return 0 }
    if {$a eq "-inf" || $b eq "+inf"} { return -1 }
    if {$a eq "+inf" || $b eq "-inf"} { return 1 }
    if {$a < $b} { return -1 }
    if {$a > $b} { return 1 }
    return 0
}

proc intset::Succ {a} {
    if {$a eq "-inf" || $a eq "+inf"} { return $a }
    return [expr {$a + 1}]
}

proc intset::Pred {a} {
    if {$a eq "-inf" || $a eq "+inf"} { return $a }
    return [expr {$a - 1}]
}

# (Not `expr ?:`: a bound may be -inf or +inf, which expr reads as a
# number: AGENTS.md, "Tcl's expr reads a numeric-looking result".)
proc intset::MinB {a b} {
    if {[Cmp $a $b] <= 0} { return $a }
    return $b
}

proc intset::MaxB {a b} {
    if {[Cmp $a $b] >= 0} { return $a }
    return $b
}

# -- construction ------------------------------------------------------------

proc intset::universe {} { return {{-inf +inf}} }
proc intset::empty {} { return {} }
proc intset::point {k} { return [list [list $k $k]] }
proc intset::interval {lo hi} { return [norm [list [list $lo $hi]]] }

# INTERVALS sorted, merged, the empty ones dropped.
proc intset::norm {intervals} {
    set kept {}
    foreach i $intervals {
        lassign $i lo hi
        if {[Cmp $lo $hi] <= 0} {
            lappend kept [list $lo $hi]
        }
    }
    set sorted [lsort -command {apply {{a b} {intset::Cmp [lindex $a 0] [lindex $b 0]}}} $kept]
    set out {}
    foreach i $sorted {
        lassign $i lo hi
        if {[llength $out] && [Cmp $lo [Succ [lindex $out end 1]]] <= 0} {
            if {[Cmp $hi [lindex $out end 1]] > 0} {
                lset out end 1 $hi
            }
        } else {
            lappend out [list $lo $hi]
        }
    }
    return $out
}

proc intset::union {a b} { return [norm [concat $a $b]] }

proc intset::inter {a b} {
    set out {}
    foreach x $a {
        lassign $x xl xh
        foreach y $b {
            lassign $y yl yh
            set lo [MaxB $xl $yl]
            set hi [MinB $xh $yh]
            if {[Cmp $lo $hi] <= 0} {
                lappend out [list $lo $hi]
            }
        }
    }
    return [norm $out]
}

proc intset::minus {a b} {
    set out $a
    foreach y $b {
        lassign $y yl yh
        set next {}
        foreach x $out {
            lassign $x xl xh
            if {[Cmp $yh $xl] < 0 || [Cmp $yl $xh] > 0} {
                lappend next $x
                continue
            }
            if {[Cmp $xl $yl] < 0} {
                lappend next [list $xl [Pred $yl]]
            }
            if {[Cmp $yh $xh] < 0} {
                lappend next [list [Succ $yh] $xh]
            }
        }
        set out $next
    }
    return [norm $out]
}

proc intset::subset {a b} { expr {[minus $a $b] eq {}} }
proc intset::isPoint {a} {
    expr {[llength $a] == 1 && [lindex $a 0 0] eq [lindex $a 0 1] && [lindex $a 0 0] ni {-inf +inf}}
}

proc intset::hull {a} {
    if {$a eq {}} { return {} }
    return [list [list [lindex $a 0 0] [lindex $a end 1]]]
}

# A past maxComponents components: its hull (sound: a superset).
proc intset::Bound {a} {
    variable maxComponents
    if {[llength $a] > $maxComponents} {
        return [hull $a]
    }
    return $a
}

# -- hir::range Ranges -------------------------------------------------------

# The IntSet of hir::range Range R (`never` and an empty Range: no value).
proc intset::OfRange {r} {
    if {$r eq "never"} { return {} }
    set mn [dict get $r min]
    set mx [dict get $r max]
    if {$mn ne "-inf" && $mx ne "+inf" && $mn > $mx} { return {} }
    if {[dict exists $r exact] && [dict get $r exact] ne ""} {
        return [norm [lmap v [dict get $r exact] {list $v $v}]]
    }
    return [list [list $mn $mx]]
}

proc intset::ToRange {i} {
    return [dict create min [lindex $i 0] max [lindex $i 1]]
}

proc intset::HullRange {a} {
    if {$a eq {}} { return never }
    return [ToRange [lindex [hull $a] 0]]
}

# OP (a hir::range transfer of one Range) over every component of A.
proc intset::Lift1 {op a} {
    set out {}
    foreach x $a {
        set out [concat $out [OfRange [{*}$op [ToRange $x]]]]
    }
    return [Bound [norm $out]]
}

# OP (a hir::range transfer of two Ranges) over every pair of components.
proc intset::Lift2 {op a b} {
    variable maxComponents
    if {[llength $a] * [llength $b] > 4 * $maxComponents} {
        set a [hull $a]
        set b [hull $b]
    }
    set out {}
    foreach x $a {
        foreach y $b {
            set out [concat $out [OfRange [{*}$op [ToRange $x] [ToRange $y]]]]
        }
    }
    return [Bound [norm $out]]
}

# The IntSet of native operator NAME of A and B: hir::range's own transfer
# (hir::range::Call's), or "" when it has none.
proc intset::Arith {name a b} {
    switch -- $name {
        + { return [Lift2 hir::range::add $a $b] }
        - { return [Lift2 hir::range::sub $a $b] }
        * { return [Lift2 hir::range::mul $a $b] }
        mod { return [Lift2 hir::range::Mod $a $b] }
        bit_and - bit_or - bit_xor - shift_right - shift_left {
            return [Lift2 [list hir::range::BitOp $name] $a $b]
        }
    }
    return ""
}

# What the static type TYPE says of an Int (hir::range::TypeFact: a
# declared integer domain's interval or exact values; any other, every Int).
proc intset::OfType {type} {
    return [OfRange [hir::range::TypeFact $type]]
}

# A's values on the path where `A OP B` holds (OP < <= > >= == !=), B the
# other operand's values: hir::range::Narrowed per component for the order
# comparisons, hir::range's point-equality rule for `==`, and -- the
# domain's own rule -- removal of a single point for `!=`.
proc intset::Narrow {op a b} {
    switch -- $op {
        < - <= - > - >= {
            if {$b eq {}} { return {} }
            set rb [HullRange $b]
            set out {}
            foreach x $a {
                set n [hir::range::Narrowed $op [ToRange $x] $rb]
                if {$n eq ""} {
                    lappend out $x
                } else {
                    set out [concat $out [OfRange $n]]
                }
            }
            return [norm $out]
        }
        == {
            if {[isPoint $b]} {
                return [inter $a $b]
            }
            return $a
        }
        != {
            if {[isPoint $b]} {
                return [minus $a $b]
            }
            return $a
        }
    }
    return $a
}

# -- surface/dfa.tcl's interval space ------------------------------------------

# A as a set of surface/dfa.tcl's bounded interval space (its MIN and MAX
# stand for the Int line beyond every symbol): bounds clamped, never
# dropped, so every value of A still meets the partition row it belongs to.
proc intset::ToDfa {a} {
    set min $::surface::dfa::MIN
    set max $::surface::dfa::MAX
    set out {}
    foreach x $a {
        lassign $x lo hi
        if {$lo eq "-inf" || [Cmp $lo $min] < 0} { set lo $min }
        if {$lo ne "+inf" && [Cmp $lo $max] > 0} { set lo $max }
        if {$hi eq "+inf" || [Cmp $hi $max] > 0} { set hi $max }
        if {$hi ne "-inf" && [Cmp $hi $min] < 0} { set hi $min }
        if {$lo eq "+inf"} { set lo $max }
        if {$hi eq "-inf"} { set hi $min }
        lappend out [list $lo $hi]
    }
    return [surface::dfa::Norm $out]
}

# The IntSet of a set S of surface/dfa.tcl's space (MIN and MAX unbounded).
proc intset::OfDfa {s} {
    set min $::surface::dfa::MIN
    set max $::surface::dfa::MAX
    return [norm [lmap x $s {
        lassign $x lo hi
        if {$lo == $min} { set lo -inf }
        if {$hi == $max} { set hi +inf }
        list $lo $hi
    }]]
}

proc intset::text {a} {
    if {$a eq {}} { return "nothing" }
    return [join [lmap x $a {
        lassign $x lo hi
        if {$lo eq $hi} { set lo } else { string cat $lo..$hi }
    }] " "]
}
