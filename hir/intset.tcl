# intset.tcl -- interval-set value facts: hir::range's interval lattice
# extended to finite unions of intervals (EMISSION-CLAIMS-MILESTONE-1.md,
# "Value facts"; MODULAR-EMISSION-PROOFS-MILESTONE-1.md, section 10).
#
#   hir::intset::universe | empty | point K | interval LO HI
#   hir::intset::union A B | inter A B | minus A B | subset A B | hull A
#   hir::intset::Arith NAME A B       a native operator's transfer
#   hir::intset::Narrow OP A B        A where `A OP B` holds
#   hir::intset::OfType TYPE          a declared integer type's facts
#   hir::intset::OfRegistered NAME    a native's registered result set
#   hir::intset::OfRange R | HullRange A
#
# An IntSet is a sorted list of disjoint, non-adjacent closed intervals
# {LO HI}, LO an Int or -inf, HI an Int or +inf: {} is no value (bottom),
# {{-inf +inf}} every Int. Bounds are true infinities and arbitrary-precision
# Ints, never sentinels: a value past every bound anything uses is still a
# value (an intersection with a sentinel range once dropped 10^23 from a
# yield and certified a false emission claim: EMISSION-CLAIMS-MILESTONE-1.md,
# section 4).
#
# This is the *disjunctive completion* of hir::range's lattice, not a second
# fact system. Every transfer is hir::range's own, applied to each component
# (or pair of components) and the results united (Lift1, Lift2): add, sub,
# mul, ModParts, BitOp, Narrowed, TypeFact, RegisteredSet,
# InductionBinding. The meaning of `+`, `mod`, `shift_right`, a comparison,
# a declared integer domain or a native's -result-range is stated once, in
# hir/range.tcl, and audited there. The one rule a Range cannot state is
# the reason this file exists: `x != K` (an `==` comparison false against a
# single point) removes K from the middle of a component (Narrow), where
# hir::range::PointEqualityNarrow can only filter an exact set. JSON's
# string escaping (`c == 34 or c == 92` false) and a Unicode scalar value's
# surrogate gap are such sets.
#
# The number of components is bounded (maxComponents); past it a result is
# its hull: fewer facts, always a superset.
#
# Who reads it: the emission checker (hir/emission.tcl). A more precise
# result must never exclude a value execution can produce: a false
# narrowing here is a false certificate there, so every rule is held to
# concrete evaluation by tests/interval-sets.test and mutated by
# audit/emission-claims/tools/mutate.tcl.

namespace eval hir::intset {
    variable maxComponents 48
}

# -- bounds ------------------------------------------------------------------

# -1, 0, 1 as bound A is below, equal to or above bound B.
proc hir::intset::Cmp {a b} {
    if {$a eq $b} { return 0 }
    if {$a eq "-inf" || $b eq "+inf"} { return -1 }
    if {$a eq "+inf" || $b eq "-inf"} { return 1 }
    if {$a < $b} { return -1 }
    if {$a > $b} { return 1 }
    return 0
}

proc hir::intset::Succ {a} {
    if {$a eq "-inf" || $a eq "+inf"} { return $a }
    return [expr {$a + 1}]
}

proc hir::intset::Pred {a} {
    if {$a eq "-inf" || $a eq "+inf"} { return $a }
    return [expr {$a - 1}]
}

# (Not `expr ?:`: a bound may be -inf or +inf, which expr reads as a
# number: AGENTS.md, "Tcl's expr reads a numeric-looking result".)
proc hir::intset::MinB {a b} {
    if {[Cmp $a $b] <= 0} { return $a }
    return $b
}

proc hir::intset::MaxB {a b} {
    if {[Cmp $a $b] >= 0} { return $a }
    return $b
}

# -- construction ------------------------------------------------------------

proc hir::intset::universe {} { return {{-inf +inf}} }
proc hir::intset::empty {} { return {} }
proc hir::intset::point {k} { return [list [list $k $k]] }
proc hir::intset::interval {lo hi} { return [norm [list [list $lo $hi]]] }

# INTERVALS sorted, merged, the empty ones dropped.
proc hir::intset::norm {intervals} {
    set kept {}
    foreach i $intervals {
        lassign $i lo hi
        if {[Cmp $lo $hi] <= 0} {
            lappend kept [list $lo $hi]
        }
    }
    set sorted [lsort -command {apply {{a b} {hir::intset::Cmp [lindex $a 0] [lindex $b 0]}}} $kept]
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

proc hir::intset::union {a b} { return [norm [concat $a $b]] }

proc hir::intset::inter {a b} {
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

proc hir::intset::minus {a b} {
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

proc hir::intset::subset {a b} { expr {[minus $a $b] eq {}} }

proc hir::intset::contains {a k} {
    foreach x $a {
        lassign $x lo hi
        if {[Cmp $lo $k] <= 0 && [Cmp $k $hi] <= 0} { return 1 }
    }
    return 0
}

proc hir::intset::isPoint {a} {
    expr {[llength $a] == 1 && [lindex $a 0 0] eq [lindex $a 0 1] && [lindex $a 0 0] ni {-inf +inf}}
}

proc hir::intset::hull {a} {
    if {$a eq {}} { return {} }
    return [list [list [lindex $a 0 0] [lindex $a end 1]]]
}

# A past maxComponents components: its hull (a superset).
proc hir::intset::Bound {a} {
    variable maxComponents
    if {[llength $a] > $maxComponents} {
        return [hull $a]
    }
    return $a
}

# -- hir::range Ranges -------------------------------------------------------

# The IntSet of hir::range Range R (`never` and an empty Range: no value; a
# Range's exact value set, when it tracks one, its points).
proc hir::intset::OfRange {r} {
    if {$r eq "never"} { return {} }
    set mn [dict get $r min]
    set mx [dict get $r max]
    if {$mn ne "-inf" && $mx ne "+inf" && $mn > $mx} { return {} }
    if {[dict exists $r exact] && [dict get $r exact] ne ""} {
        return [norm [lmap v [dict get $r exact] {list $v $v}]]
    }
    return [list [list $mn $mx]]
}

proc hir::intset::ToRange {i} {
    return [dict create min [lindex $i 0] max [lindex $i 1]]
}

# The hull of A as a Range (`never` for no value).
proc hir::intset::HullRange {a} {
    if {$a eq {}} { return never }
    return [ToRange [lindex [hull $a] 0]]
}

# OP (a hir::range transfer of one Range) over every component of A.
proc hir::intset::Lift1 {op a} {
    set out {}
    foreach x $a {
        set out [concat $out [OfRange [{*}$op [ToRange $x]]]]
    }
    return [Bound [norm $out]]
}

# OP (a hir::range transfer of two Ranges) over every pair of components.
proc hir::intset::Lift2 {op a b} {
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

# hir::range::ModParts over every pair of components: a component pair may
# give two parts (a range of operands wrapping past a multiple of the
# divisor).
proc hir::intset::LiftMod {a b} {
    variable maxComponents
    if {[llength $a] * [llength $b] > 4 * $maxComponents} {
        set a [hull $a]
        set b [hull $b]
    }
    set out {}
    foreach x $a {
        foreach y $b {
            foreach part [hir::range::ModParts [ToRange $x] [ToRange $y]] {
                set out [concat $out [OfRange $part]]
            }
        }
    }
    return [Bound [norm $out]]
}

# The IntSet of native operator NAME of A and B: hir::range's own transfer,
# or "" when it has none.
proc hir::intset::Arith {name a b} {
    switch -- $name {
        + { return [Lift2 hir::range::add $a $b] }
        - { return [Lift2 hir::range::sub $a $b] }
        * { return [Lift2 hir::range::mul $a $b] }
        mod { return [LiftMod $a $b] }
        bit_and - bit_or - bit_xor - shift_right - shift_left {
            return [Lift2 [list hir::range::BitOp $name] $a $b]
        }
    }
    return ""
}

# What the static type TYPE says of an Int (hir::range::TypeFact: a
# declared integer domain's interval or exact values; any other, every Int).
proc hir::intset::OfType {type} {
    return [OfRange [hir::range::TypeFact $type]]
}

# The set native NAME's -result-range metadata promises for every Int it
# returns (hir::range::RegisteredSet: an `intervals` registration's
# components, any other registration its one Range).
proc hir::intset::OfRegistered {name} {
    return [norm [lmap r [hir::range::RegisteredSet $name] {
        if {$r eq "never"} continue
        list [dict get $r min] [dict get $r max]
    }]]
}

# A's values on the paths where `A OP B` holds (OP < <= > >= == !=), B the
# other operand's values: hir::range::Narrowed per component for the order
# comparisons, hir::range's point-equality rule for `==`, and -- the one
# rule a Range cannot state -- removal of a single point for `!=`.
proc hir::intset::Narrow {op a b} {
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

proc hir::intset::text {a} {
    if {$a eq {}} { return "nothing" }
    return [join [lmap x $a {
        lassign $x lo hi
        if {$lo eq $hi} { set lo } else { string cat $lo..$hi }
    }] " "]
}
