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
# a bound from an exact call until its successful-result summary is known,
# from an open call, a list/aggregate read, or from a branch condition (e.g. `i <
# length(xs)` proves nothing about i's range: that needs relational
# reasoning intervals cannot express, so it is not attempted; see #19 of the
# milestone this module was written for).
#
# Parameters: interprocedural seeding
# ------------------------------------
# ExternalSeeds supplies syntactically evident initial arguments: Int
# literals and context-free native result metadata. The instance fixpoint
# then joins ranges from every reached exact call site, including ranges
# derived from caller parameters and branch narrowing. Same-instance calls
# feed a local widening step; cross-instance calls feed the outer rounds.
# Open generic entries remain unknown when materialized Block values may
# reach them through dynamic dispatch.
# A parameter with no proven caller argument and no self-recursive
# feedback stays unknown (Option A of the milestone's #13: a parameter's
# incoming magnitude is never assumed small merely because it is a Botlish
# Int).
#
# Exact-call arguments and successful-result ranges now settle together in
# the instance rounds below. No value fact implies completion or an effect.


namespace eval hir::range {
    # The runtime's tagged small-Int range (see the file header).
    variable smallMin [expr {-(1 << 62)}]
    variable smallMax [expr {(1 << 62) - 1}]
    # Self-recursive parameter feedback passes before giving up (each pass
    # either converges or widens a bound to infinity, so few are needed).
    variable maxPasses 4
    # Exact-value-set cardinality budget (see "Exact value sets" below): the
    # largest sorted set of alternatives a Range may carry alongside its
    # interval. Must be at least 16 (HighNibble's own exact domain,
    # core/scalarbits.tcl); chosen at 32 to leave headroom for a small
    # branch join (spec #27's own "16 or 32 are reasonable" -- a named
    # compiler constant, not a magic number at each call site) without
    # inviting the combinatorial growth #28-30 warn against.
    variable maxExactValues 32
    # The largest shift_left amount BitOp will actually compute a bound
    # for (see BitOp's own shift_left case): shift_left's result grows the
    # shifted value's own bit-length by the shift amount itself, unlike
    # +/-/*, whose result bit-length is only roughly the sum of its
    # operands' -- so, unlike every other transfer in this file, a small,
    # easily-representable *fact* (an ordinary small Int shift amount) can
    # demand an astronomically large *bound* even though computing that
    # bound never itself needs an unbounded number of steps (Tcl's own
    # arbitrary-precision `<<` is linear in the result's bit-length, not
    # exponential). The actual, measured hazard is downstream: every other
    # producer in this file eventually compares a candidate bound against
    # the literal sentinels "-inf"/"+inf" (`ne`/`eq`, e.g. Normalize's own
    # dense-interval check) -- a *string* comparison that forces Tcl to
    # materialize the bound's full decimal text first, which for a
    # multi-hundred-thousand-bit integer is quadratic and, confirmed
    # directly, costs tens of seconds even before core/scalarbits.tcl's own
    # MAX_SHIFT (1<<20) is reached (a shift amount that large is not even
    # adversarial -- it is a value this milestone's own generic shift
    # contract accepts as valid). 4096 is comfortably above every realistic
    # bit-manipulation shift (nibble/byte/word positioning) while keeping
    # the worst case a few milliseconds; beyond it BitOp simply declines
    # (falls back to `unknown`) rather than trying to compute and propagate
    # a bound of a size nothing downstream can afford to look at.
    variable maxShiftLeftAmount 4096
}

# ---------------------------------------------------------------------------
# The Range lattice
#
# Exact value sets
# ----------------
# A Range may optionally carry a third fact alongside its interval: `exact`,
# a sorted, duplicate-free Tcl list of every value the expression could
# actually take -- strictly more precise than the interval alone whenever
# the set is sparse (HighNibble's {0,16,...,240} inside [0,240]) or a small
# join of otherwise-unrelated points ({0,255} inside [0,255]). Absent
# (ExactOf returns "") means "not tracked", never "no values" -- an empty
# set never appears on a live Range; a computation that would produce one
# (e.g. narrowing to an unsatisfiable equality) simply falls back to
# interval-only precision instead of trying to represent unreachability
# through this lattice (hir/range.tcl already has "never" as its bottom for
# expressions; reusing it for a *binding's* narrowed fact would need
# plumbing this milestone deliberately does not add -- see
# BYTE-NIBBLE-BIT-ARITHMETIC.md's own account of this scope decision).
#
# This is a strict *addition* to the interval Range that existed before this
# milestone (spec #26): every proc below that does not mention `exact`
# explicitly still computes min/max exactly as it always did, and simply
# carries no `exact` key -- ExactOf then reads that the same as "not
# tracked". Only join, add/sub/mul and the two Narrowed-family branch-
# narrowing, bounded constant-mask transfer, and semantic type seeding also
# populate or filter it. Bounded by
# maxExactValues throughout: crossing it always widens to interval-only,
# never grows past it (spec #27-30). Normalize (below) additionally drops a
# set that is exactly as precise as its own interval -- a dense run
# {0,1,...,15} says nothing an ordinary [0,15] Range doesn't already (spec
# #106-108) -- so a tracked `exact` key, when present, is always genuinely
# more informative than the interval alone.

# The exact value set of R, or "" if not tracked. A point range (min==max)
# always answers its own singleton, even with no explicit `exact` key
# (Normalize itself never sets one there -- a 1-element set spanning
# min==max is exactly the interval it already is, so storing it separately
# would violate Normalize's own "redundant with the interval" rule): this
# is spec #85's "singleton set reuses the existing exact-constant
# representation" -- point's own {min max} pair -- made concrete, and it is
# what lets a later join (e.g. `point(1)` then `point(4)`) recover a real
# two-element exact set instead of silently losing precision because each
# side's own single value had nothing stored under `exact`.
proc hir::range::ExactOf {r} {
    if {[dict exists $r exact]} {
        return [dict get $r exact]
    }
    variable maxExactValues
    set mn [dict get $r min]
    set mx [dict get $r max]
    if {$mn eq "-inf" || $mx eq "+inf" || $mx - $mn + 1 > $maxExactValues} {
        return ""
    }
    # A finite, in-budget interval's members are exactly {mn, mn+1, ...,
    # mx}, whether or not Normalize chose to store that list explicitly
    # (dense sets are deliberately not stored, per this file's own header
    # and spec #106-107 -- redundant with the interval for *display*, but
    # composition (CrossExact, join) still needs to reconstruct it on
    # demand: otherwise a cheap exact transfer like {1,2}+{10,20} -> four
    # values, spec #29, would wrongly degrade the moment either side's own
    # set was small enough to be dense).
    # Not `incr v`: Tcl 9.0.1's bytecode-compiled `incr` (i.e. `incr` as it
    # runs inside a *proc*, not typed interactively at the top level) wraps
    # via native 64-bit arithmetic instead of promoting to a bignum exactly
    # at the i64 boundary -- confirmed directly and minimally (a bare `incr`
    # on 9223372036854775807 -- i64::MAX -- inside a one-line proc returns
    # -9223372036854775808; the identical `incr` typed at tclsh's top level
    # correctly returns 9223372036854775808). Every proc in this file is
    # compiled, so this loop hit it, turning a single-iteration point
    # reconstruction into a multi-billion-iteration runaway (see
    # BYTE-NIBBLE-BIT-ARITHMETIC.md's own account). `expr {$v + 1}` uses
    # Tcl 9's ordinary arbitrary-precision addition, exactly like every
    # other bound computed in this file, and is not vulnerable to this.
    set values {}
    set v $mn
    while {$v <= $mx} {
        lappend values $v
        set v [expr {$v + 1}]
    }
    return $values
}

# R with its `exact` key set to VALUES (a list, possibly unsorted/with
# duplicates) if that is both nonempty and within budget and not merely the
# same information R's own interval already carries; otherwise R unchanged
# (no `exact` key). The single normalization point every producer below
# funnels through, so "exact is a subset of interval, and only ever present
# when it adds information" is one invariant enforced in one place (spec
# #82-83, #106).
proc hir::range::Normalize {r values} {
    variable maxExactValues
    if {[llength $values] == 0 || [llength $values] > $maxExactValues} {
        return $r
    }
    # Not `-integer`: Botlish Int is arbitrary-precision (spec #18) and can
    # exceed Tcl's native integer sort, which overflows past roughly 64
    # bits; `-command`/[expr] both accept Tcl 9's own bignums correctly.
    set sorted [lsort -unique -command {apply {{a b} {expr {$a < $b ? -1 : ($a > $b)}}}} $values]
    set mn [dict get $r min]
    set mx [dict get $r max]
    if {$mn ne "-inf" && $mx ne "+inf" && [llength $sorted] == $mx - $mn + 1} {
        # Dense: {mn, mn+1, ..., mx} is exactly the interval -- redundant.
        return $r
    }
    return [dict merge $r [dict create exact $sorted]]
}

# Intersects an existing flow fact with the bound supplied by a semantic
# integer type. Empty intersections remain conservative because this lattice
# deliberately has no binding-level bottom.
proc hir::range::intersect {a b} {
    if {$a eq {never}} { return never }
    set amn [dict get $a min]
    set bmn [dict get $b min]
    set amx [dict get $a max]
    set bmx [dict get $b max]
    if {$amn eq {-inf}} {
        set mn $bmn
    } elseif {$bmn eq {-inf}} {
        set mn $amn
    } else {
        set mn [Max $amn $bmn]
    }
    if {$amx eq {+inf}} {
        set mx $bmx
    } elseif {$bmx eq {+inf}} {
        set mx $amx
    } else {
        set mx [Min $amx $bmx]
    }
    if {$mn ne {-inf} && $mx ne {+inf} && $mn > $mx} { return $a }
    set r [dict create min $mn max $mx]
    set ea [ExactOf $a]
    set eb [ExactOf $b]
    if {$ea eq {} && $eb eq {}} { return $r }
    set source [expr {$ea eq {} ? $eb : $ea}]
    set values [lmap v $source {
        if {($mn ne {-inf} && $v < $mn) || ($mx ne {+inf} && $v > $mx) \
                || ($ea ne {} && $eb ne {} && $v ni $eb)} continue
        set v
    }]
    if {$values eq {}} { return $r }
    return [Normalize $r $values]
}

proc hir::range::TypeFact {type} {
    if {[catch {core::type::integerFacts $type} facts]} { return [unknown] }
    if {$facts eq {}} { return [unknown] }
    set r [dict create min [dict get $facts min] max [dict get $facts max]]
    return [expr {[dict exists $facts exact] ? [Normalize $r [dict get $facts exact]] : $r}]
}

proc hir::range::ConstrainType {hir e r} {
    if {$r eq {never}} { return never }
    return [intersect $r [TypeFact [hir::typeOf $hir $e]]]
}

proc hir::range::unknown {} {
    return {min -inf max +inf}
}

proc hir::range::point {n} {
    return [Normalize [dict create min $n max $n] [list $n]]
}

proc hir::range::nonneg {} {
    return [dict create min 0 max +inf]
}

# The range of a native result tagged -result-range collection-length
# (core/native.tcl): a String/List length. Unlike nonneg this bound is
# *finite* -- native/src/runtime/vm.rs's MAX_COLLECTION_LENGTH is an actual
# enforced construction-time limit, not an assumption (see its doc comment),
# so this alone makes a direct length(...)/list_length(...) call small
# (fitsSmall below) with no relational reasoning: it is the whole proof for
# every corpus loop whose bound is a length call appearing in the loop body
# itself (e.g. reverse's `index == length(text)`).
proc hir::range::collectionLength {} {
    variable smallMax
    return [dict create min 0 max $smallMax]
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
    set r [dict create min [Min [dict get $a min] [dict get $b min]] \
        max [Max [dict get $a max] [dict get $b max]]]
    set ea [ExactOf $a]
    set eb [ExactOf $b]
    if {$ea eq "" || $eb eq ""} {
        return $r
    }
    # Both sides tracked: the join's exact set is their union (spec #31 --
    # `if cond: x=0 else: x=255` is exactly this, each branch a `point`),
    # within budget or not tracked at all (spec #26-27: interval precision
    # above is unaffected either way).
    return [Normalize $r [concat $ea $eb]]
}

# NEW after a join of OLD with a freshly computed contribution: OLD with any
# bound that grew pushed to infinity, so repeated growth (an unbounded
# induction variable) reaches a fixed point in one step instead of counting
# up forever (see the milestone's #18). Deliberately never carries an
# `exact` key forward (NEW's own -- dict create below never sets one):
# widening is specifically for an induction variable's per-round growth,
# which this lattice already treats as unbounded once it triggers, so there
# is no finite set left to track through it (spec #26 still holds: OLD's
# interval survives exactly as before, only the exact-set *addition* this
# milestone made is what widen conservatively drops).
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

# X - Y (a bound of a subtraction result, or Narrowed's "predecessor of a
# finite bound" with y=1): every caller either passes (a.min, b.max) or
# (a.max, b.min) from `sub`, or has already checked x is finite (Narrowed),
# so x is never +inf and y is never -inf; every combination below is then
# well defined.
proc hir::range::SubBound {x y} {
    if {$x eq "-inf" || $y eq "+inf"} {
        return -inf
    }
    if {$x eq "+inf" || $y eq "-inf"} {
        return +inf
    }
    return [expr {$x - $y}]
}

# The exact set of OP applied pairwise to every value of A's exact set with
# every value of B's, within budget -- or R unchanged if either input is
# untracked or the cross product would exceed it (spec #28-30: bounded
# evaluation, never an unconditional Cartesian product). OPPROC is a
# 2-argument Tcl command computing OP itself (AddBound/SubBound/plain `*`,
# or a bitwise/shift operator -- BitOp below).
#
# When it succeeds, the returned Range's min/max are recomputed from the
# actual computed values, not merely R's own (possibly looser) interval:
# for `+`/`-`/`*` this changes nothing (interval arithmetic is already tight
# for two real intervals, and a tracked exact set's own min/max always equal
# its Range's min/max, so the corner values interval arithmetic used are
# always themselves members of the cross product -- recomputing from the
# full cross product can only ever reproduce the same bound). For
# bitwise/shift operations (BitOp's own callers), R's interval is often only
# a sound *superset* bound (e.g. AND's "0..the nonnegative operand's own
# max"), so recomputing from the actual pairwise results is what lets a
# genuinely sparse case (`{0,16,...,240} & {15}`) collapse all the way to a
# single point instead of merely decorating a loose interval with a
# same-shaped exact list (spec #7, #11-13).
proc hir::range::CrossExact {r a b opProc} {
    variable maxExactValues
    set ea [ExactOf $a]
    set eb [ExactOf $b]
    if {$ea eq "" || $eb eq "" || [llength $ea] * [llength $eb] > $maxExactValues} {
        return $r
    }
    set values {}
    foreach x $ea {
        foreach y $eb {
            lappend values [{*}$opProc $x $y]
        }
    }
    set mn ""
    set mx ""
    foreach v $values {
        if {$mn eq "" || $v < $mn} { set mn $v }
        if {$mx eq "" || $v > $mx} { set mx $v }
    }
    return [Normalize [dict create min $mn max $mx] $values]
}

proc hir::range::add {a b} {
    if {$a eq "never" || $b eq "never"} {
        return never
    }
    set r [dict create min [AddBound [dict get $a min] [dict get $b min]] \
        max [AddBound [dict get $a max] [dict get $b max]]]
    return [CrossExact $r $a $b {apply {{x y} {expr {$x + $y}}}}]
}

proc hir::range::sub {a b} {
    if {$a eq "never" || $b eq "never"} {
        return never
    }
    set r [dict create min [SubBound [dict get $a min] [dict get $b max]] \
        max [SubBound [dict get $a max] [dict get $b min]]]
    return [CrossExact $r $a $b {apply {{x y} {expr {$x - $y}}}}]
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
    set r [dict create min $lo max $hi]
    return [CrossExact $r $a $b {apply {{x y} {expr {$x * $y}}}}]
}

proc hir::range::show {r} {
    if {$r eq "never"} {
        return never
    }
    set mn [dict get $r min]
    set mx [dict get $r max]
    set base "\[[expr {$mn eq {-inf} ? "-∞" : $mn}], [expr {$mx eq {+inf} ? "+∞" : $mx}]\]"
    # Only ever displays an *explicitly* tracked exact set, or a bare
    # point's own trivial singleton -- never ExactOf's broader on-demand
    # reconstruction of an arbitrary small dense interval (ExactOf itself
    # needs that reconstruction for composition, spec #29, but showing it
    # for every small range no wider than the budget would defeat
    # Normalize's whole "a dense set is redundant with its interval" point,
    # spec #106-107, and make an ordinary bounded loop's range look like it
    # is carrying sparse information it is not).
    if {[dict exists $r exact]} {
        set exact [dict get $r exact]
    } elseif {$mn ne "-inf" && $mn eq $mx} {
        set exact [list $mn]
    } else {
        set exact ""
    }
    if {$exact eq ""} {
        return $base
    }
    return "$base {[::join $exact ,]}"
}

# A sound (not necessarily tightest) interval for bitwise/shift NAME
# (bit_and, bit_or, bit_xor, shift_left, shift_right -- core/scalarbits.tcl)
# applied to X, Y, proven purely from general nonnegative-integer reasoning
# about the operation itself, never from any named type (spec #17, #35: this
# stays a capability of the interval lattice, with no concept here named
# Byte or HighNibble). Every case additionally tries CrossExact first: when
# both operands carry a tracked (or reconstructible) exact set within
# budget, the true pairwise result is used directly, which is often
# strictly tighter than the sound interval bound below (spec #7-9, #11-13);
# CrossExact itself declines (returning its input unchanged) whenever that
# is not cheap, so every case still falls back to the interval-only
# reasoning that existed before this was added. AND with a nonnegative
# constant also gets bounded submask enumeration when the exact cross
# product itself was not available; general known-bits reasoning remains
# deliberately deferred.
#
#   bit_and: AND's result bits are a subset of whichever operand is
#     nonnegative (a set bit needs both operands set, and a nonnegative
#     literal/value has no bits set outside its own magnitude), so
#     0 <= x&y <= that operand's own max -- true for *any* integer on the
#     other side, positive or negative (spec #16's `Byte & LowNibble ->
#     LowNibble`-shaped facts fall out of exactly this, generically: no
#     dedicated per-type rule needed, per spec #17).
#   bit_or, bit_xor: for two nonnegative operands, the result is bounded by
#     their sum (a loose but sound bound -- neither operation can set a bit
#     beyond the highest either operand or their carry-free combination
#     could reach); bit_or's result is also never below either operand's own
#     minimum.
#   shift_right: an arithmetic right shift of a nonnegative value by a
#     nonnegative amount only ever shrinks it towards 0, so a known bound on
#     the shift amount (Y) tightens the result on both ends (ShiftRightBound
#     below); with no such bound, the result is still bounded by the
#     shifted value's own range (unaffected by an unknown/possibly-negative
#     shift amount, matching this proc's behavior before Y was consulted).
#   shift_left: for nonnegative X and Y, `x << y` is monotonically
#     increasing in both, so the sound bound is [xmn<<ymn, xmx<<ymx]
#     (arbitrary-precision, never truncated -- spec #18-19, #39).
proc hir::range::BitOp {name x y} {
    if {$x eq "never" || $y eq "never"} {
        return never
    }
    set xmn [dict get $x min]
    set xmx [dict get $x max]
    set ymn [dict get $y min]
    set ymx [dict get $y max]
    switch -- $name {
        bit_and {
            set r [unknown]
            if {$ymn ne "-inf" && $ymn >= 0} {
                set r [dict create min 0 max $ymx]
            } elseif {$xmn ne "-inf" && $xmn >= 0} {
                set r [dict create min 0 max $xmx]
            }
            set cross [CrossExact $r $x $y {apply {{a b} {expr {$a & $b}}}}]
            if {$cross ne $r} {
                return $cross
            }
            if {$ymn ne "-inf" && $ymn >= 0 && $ymn eq $ymx} {
                return [AndMaskExact $r $ymn]
            }
            if {$xmn ne "-inf" && $xmn >= 0 && $xmn eq $xmx} {
                return [AndMaskExact $r $xmn]
            }
            return $r
        }
        bit_or {
            set r [unknown]
            if {$xmn ne "-inf" && $xmn >= 0 && $ymn ne "-inf" && $ymn >= 0} {
                set r [dict create min [Max $xmn $ymn] max [AddBound $xmx $ymx]]
            }
            return [CrossExact $r $x $y {apply {{a b} {expr {$a | $b}}}}]
        }
        bit_xor {
            set r [unknown]
            if {$xmn ne "-inf" && $xmn >= 0 && $ymn ne "-inf" && $ymn >= 0} {
                set r [dict create min 0 max [AddBound $xmx $ymx]]
            }
            return [CrossExact $r $x $y {apply {{a b} {expr {$a ^ $b}}}}]
        }
        shift_right {
            if {$xmn eq "-inf" || $xmn < 0} {
                return [unknown]
            }
            set r [dict create min 0 max $xmx]
            if {$ymn eq "-inf" || $ymn < 0} {
                # An unproven/possibly-negative shift amount: keep the old,
                # shift-amount-independent bound (spec #21: a shift's
                # validity is a separate fact, consulted later by raw
                # eligibility -- not assumed here).
                return $r
            }
            set mx [ShiftRightBound $xmx $ymn]
            set mn [expr {$ymx eq "+inf" ? 0 : [ShiftRightBound $xmn $ymx]}]
            set r [dict create min $mn max $mx]
            return [CrossExact $r $x $y {apply {{a b} {expr {$a >> $b}}}}]
        }
        shift_left {
            if {$xmn eq "-inf" || $xmn < 0 || $ymn eq "-inf" || $ymn < 0} {
                return [unknown]
            }
            variable maxShiftLeftAmount
            if {$ymx eq "+inf" || $ymx > $maxShiftLeftAmount} {
                # See maxShiftLeftAmount's own comment: beyond this, even a
                # perfectly ordinary (MAX_SHIFT-valid) shift amount can
                # demand a bound too large for the rest of this file to
                # affordably compare against its "-inf"/"+inf" sentinels.
                return [unknown]
            }
            set mn [expr {$xmn << $ymn}]
            set mx [expr {$xmx eq "+inf" ? "+inf" : ($xmx << $ymx)}]
            set r [dict create min $mn max $mx]
            return [CrossExact $r $x $y {apply {{a b} {expr {$a << $b}}}}]
        }
    }
    return [unknown]
}

# A sound bound on X >> Y for nonnegative finite X and nonnegative Y (Y may
# be +inf, the limiting case: a nonnegative value shifted by an
# ever-growing amount approaches, and is bounded by, 0).
proc hir::range::ShiftRightBound {a b} {
    if {$a eq "+inf"} {
        return +inf
    }
    if {$b eq "+inf"} {
        return 0
    }
    return [expr {$a >> $b}]
}

proc hir::range::AndMaskExact {r mask} {
    variable maxExactValues
    set values {0}
    set sub $mask
    while {$sub != 0} {
        lappend values $sub
        if {[llength $values] > $maxExactValues} { return $r }
        set sub [expr {($sub - 1) & $mask}]
    }
    return [Normalize $r $values]
}

# ---------------------------------------------------------------------------
# Interprocedural seeding

# The Range of expression E if it is a plain integer literal, or a direct
# call to a native whose -result-range metadata (core/native.tcl) is a
# context-free guarantee (nonneg, collection-length): unknown otherwise. Both
# cases are purely syntactic facts that need no analysis of any callee or
# binding, so external call sites can be seeded from them without an
# ordering dependency between instances. The native-call case is what lets a
# parameter seeded only by e.g. `list_length(row)`-shaped arguments (never a
# literal) still get a genuine finite range (matmul's `count`/`columns`):
# the same metadata Call (below) reads for an expression already inside the
# instance being analyzed, read here for an expression outside it.
proc hir::range::SeedRange {hir e} {
    switch -- [hir::kind $hir $e] {
        const {
            set v [hir::get $hir $e value]
            if {[core::value::kind $v] ne "int"} {
                return [unknown]
            }
            return [point [core::value::intOf $v]]
        }
        call {
            lassign [hir::get $hir $e target] targetKind target
            if {$targetKind ne "native"} {
                return [unknown]
            }
            set name [dict get [hir::symbol $hir $target] name]
            switch -- [dict get [core::native::metadata $name] resultRange] {
                nonneg            { return [nonneg] }
                collection-length { return [collectionLength] }
            }
            return [unknown]
        }
    }
    return [unknown]
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
                lappend next [join $c [SeedRange $hir $argExpr]]
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
            set r [ConstrainType $hir $e $r]
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
            dict set ctx breakRanges $e never
            foreach child [dict get $node body] {
                Expr hir ctx $child
            }
            set result [dict get $ctx breakRanges $e]
            dict unset ctx breakRanges $e
            dict set ctx bindings $saved
            return $result
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
            set value [dict get $node value]
            set r [expr {$value eq "" ? [unknown] : [Expr hir ctx $value]}]
            set target [dict get $node target]
            if {$r ne "never" && $target ne "" && [dict exists $ctx breakRanges $target]} {
                dict set ctx breakRanges $target [join [dict get $ctx breakRanges $target] $r]
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

# If a successful native addition computed a + K, then a later subtraction
# of the same immutable binding is K. This local algebraic identity is valid
# for arbitrary-precision Ints and says nothing about whether either call
# completes. It covers returning paths such as work's b - a.
proc hir::range::DifferenceOffset {hir left right} {
    set rightNode [hir::node $hir $right]
    if {[dict get $rightNode kind] ne "ref"} {
        return ""
    }
    set rightBinding [dict get $rightNode binding]
    set leftNode [hir::node $hir $left]
    if {[dict get $leftNode kind] ne "ref"} {
        return ""
    }
    set leftBinding [dict get $leftNode binding]
    set declaration [dict get [hir::binding $hir $leftBinding] declaredBy]
    if {$declaration eq ""} {
        return ""
    }
    set bound [hir::node $hir $declaration]
    if {[dict get $bound kind] ne "bind"} {
        return ""
    }
    set value [hir::node $hir [dict get $bound value]]
    if {[dict get $value kind] ne "call" || [lindex [dict get $value target] 0] ne "native"} {
        return ""
    }
    if {[llength [dict get $value args]] != 2} {return ""}
    set symbol [lindex [dict get $value target] 1]
    if {[dict get [hir::symbol $hir $symbol] name] ne "+"} {
        return ""
    }
    foreach {a b} [list [lindex [dict get $value args] 0] [lindex [dict get $value args] 1]] {
        # The two operands may appear in either order.
        foreach pair [list [list $a $b] [list $b $a]] {
            lassign $pair same constant
            set sameNode [hir::node $hir $same]
            set constantNode [hir::node $hir $constant]
            if {[dict get $sameNode kind] eq "ref"
                    && [dict get $sameNode binding] eq $rightBinding
                    && [dict get $constantNode kind] eq "const"
                    && [core::value::kind [dict get $constantNode value]] eq "int"} {
                return [core::value::intOf [dict get $constantNode value]]
            }
        }
    }
    return ""
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
        if {[hir::typeOf $hir $e] eq "never"} {
            # A proven error contributes no successful Int result.
            return never
        }
        set name [dict get [hir::symbol $hir $target] name]
        set result [unknown]
        if {$name in {+ - *} && [llength $argRanges] == 2} {
            lassign $argRanges x y
            switch -- $name {
                + { set result [add $x $y] }
                - {
                    set offset [DifferenceOffset $hir [lindex [dict get $node args] 0] [lindex [dict get $node args] 1]]
                    set result [expr {$offset eq "" ? [sub $x $y] : [point $offset]}]
                }
                * { set result [mul $x $y] }
            }
        } elseif {$name in {bit_and bit_or bit_xor shift_right shift_left} && [llength $argRanges] == 2} {
            lassign $argRanges x y
            set result [BitOp $name $x $y]
        } else {
            set meta [core::native::metadata $name]
            switch -- [dict get $meta resultRange] {
                nonneg            { set result [nonneg] }
                collection-length { set result [collectionLength] }
            }
        }
        set result [ConstrainType $hir $e $result]
        dict set ctx exprs $e $result
        return $result
    }
    if {$targetKind eq "block" && [dict exists [dict get $ctx instanceCalls] $e]} {
        # Every exact call this pass actually reaches (dead/unreachable
        # call expressions never get here: Expr's reachability check above
        # returns never before Call is even entered, so an argument from an
        # unreachable path never contributes -- spec #31). Self and
        # cross-instance targets are recorded uniformly; hir::range::analyze
        # separates them when folding (self feeds this same instance's own
        # fixpoint, cross feeds the callee's).
        set targetId [dict get [dict get $ctx instanceCalls] $e]
        dict lappend ctx calls [list $targetId $argRanges]
        set results [dict get $ctx calleeResults]
        set result [expr {[dict exists $results $targetId] ? [dict get $results $targetId] : [unknown]}]
        set result [ConstrainType $hir $e $result]
        if {$result eq "never"} {set result [unknown]}
        dict set ctx exprs $e $result
        return $result
    }
    if {$targetKind eq {block}} {
        set result [ConstrainType $hir $e [unknown]]
        dict set ctx exprs $e $result
        return $result
    }
    return [unknown]
}

proc hir::range::ProvesType {range type} {
    set facts [core::type::integerFacts $type]
    if {$facts eq {} || $range eq {never}} { return 0 }
    if {[dict exists $facts exact]} {
        set actual [ExactOf $range]
        if {$actual eq {}} { return 0 }
        foreach v $actual { if {$v ni [dict get $facts exact]} { return 0 } }
        return 1
    }
    set mn [dict get $range min]
    set mx [dict get $range max]
    return [expr {$mn ne {-inf} && $mx ne {+inf} && $mn >= [dict get $facts min] && $mx <= [dict get $facts max]}]
}

# 1 if a value of static type ARGTYPE (with flow-sensitive Range ARGRANGE,
# [unknown] if none) is provably accepted where DECLARED is required --
# the one admissibility operation verifyDeclaredResults/VerifyCall both
# use, for a parameter and for a declared result alike (spec item 41-42 of
# MINIMAL-APPLIED-LIST-TYPES.md).
#
# An ordinary (non-applied) DECLARED keeps exactly STRICT-TYPED-PARAMETERS.
# md's own two-part proof: nominal subtype, or the argument's own Range/
# exact-set fact is a subset of DECLARED's integer-domain facts.
#
# An applied List[T] DECLARED (hir::types::IsList) is deliberately *not*
# fed through either of those: hir::types::subtype's own list case is
# covariant (built for hir/specialize.tcl's positional-shape lattice, an
# unrelated internal use this proc must not disturb), and ProvesType only
# ever means integer-domain membership -- core::type::integerFacts would
# simply raise on a {list ...} type. List[T] admissibility is instead
# exact structural equality of the argument's own (already Unshaped,
# ordinary-inference-only) applied type against DECLARED: List[A] accepts
# only List[A], never List[B] merely because A<:B, and never a broad/
# unknown list or a non-list value -- the initial invariant rule (spec
# items 24-26, 70), chosen because List's own mutability/aliasing
# semantics have not been audited for anything more permissive, not
# because it was hard to make covariant.
#
# An applied ImmutableSet[T] DECLARED (hir::types::IsSet) takes the
# identical path, for the identical reason (MINIMAL-IMMUTABLE-SET.md):
# ImmutableSet[A] accepts only ImmutableSet[A], never ImmutableSet[B]
# merely because A<:B or because A and B are same-domain siblings, and
# never a broad/unknown set or a non-set value -- invariant from the
# start, even though the set itself is immutable, because immutability
# alone does not license covariance without a variance system this
# milestone deliberately does not build.
proc hir::range::ProvesValueAcceptedBy {argType argRange declared} {
    if {[hir::types::IsList $declared] || [hir::types::IsSet $declared]} {
        # ImmutableSet[T] (MINIMAL-IMMUTABLE-SET.md) is exactly as invariant
        # as List[T], for the identical reason: a set's own mutability/
        # aliasing semantics (here, immutable -- but no variance system
        # exists to make that fact usable) have not been audited for
        # anything more permissive than exact structural equality of the
        # already-Unshaped (a no-op for a set, which never has a shape)
        # applied type.
        return [expr {[hir::types::Unshaped $argType] eq $declared}]
    }
    return [expr {[hir::types::subtype $argType $declared] || [ProvesType $argRange $declared]}]
}

proc hir::range::verifyDeclaredResults {hirVar} {
    upvar 1 $hirVar hir
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne {block} || [dict get $node declaredResult] eq {}} { continue }
        set params [dict get $node params]
        set outcome [AnalyzeInstance $hir verify {} $e $params \
            [lrepeat [llength $params] [unknown]] {} {}]
        set result [dict get $outcome result]
        set declared [dict get $node declaredResult]
        set inferred [hir::type $hir [dict get $node inferredResultType]]
        if {![ProvesValueAcceptedBy $inferred $result $declared]} {
            hir::Diagnose hir TYPE [format {function result does not prove declared type %s (facts: %s)} \
                [hir::types::show $declared] [show $result]] $e
        }
    }
}

# Compile-time call admissibility (STRICT-TYPED-PARAMETERS.md): a call whose
# target is a directly-known block declaring one or more parameter types is
# legal only when the compiler can prove, for every typed parameter, that
# the argument's possible values are a subset of the parameter's accepted
# values -- exactly the same nominal-subtype-or-integer-domain-fact proof
# verifyDeclaredResults already uses for a declared result (subtype OR
# ProvesType, never a runtime guard). A merely-unproven argument is rejected
# exactly like a proven-incompatible one: there is no third, "insert a
# check" outcome.
#
# Runs once per block (and once for the program root), each with its own
# *local*, non-interprocedural AnalyzeInstance pass -- exactly
# verifyDeclaredResults's own "verify" call, never hir::range::analyze's
# interprocedural closed-call fixpoint. This is deliberate, not merely
# convenient: it is what makes spec #24 ("an invalid caller must not
# pollute the callee fixpoint") true by construction, since this pass never
# touches that fixpoint's `calls`/`contributions` machinery at all, and it
# is also what makes a recursive call's own argument checked soundly (a
# self-call inside a block's own body is just another expression this same
# local pass already walks, seeded by the same declared-parameter facts
# hir::types::Block already gave the body -- no separate recursion handling
# needed).
proc hir::range::verifyDeclaredParams {hirVar} {
    upvar 1 $hirVar hir
    set blocks [list program]
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] eq {block}} { lappend blocks $e }
    }
    foreach block $blocks {
        if {$block eq {program}} {
            set params {}
            set body [hir::roots $hir]
        } else {
            set node [dict get $hir exprs $block]
            set params [dict get $node params]
            set body [dict get $node body]
        }
        set outcome [AnalyzeInstance $hir verify {} $block $params \
            [lrepeat [llength $params] [unknown]] {} {}]
        set ranges [dict get $outcome exprs]
        foreach e $body {
            VerifyCallArguments hir $ranges $e
        }
    }
}

# Walks every call reachable from E within its own block/program (spec #58:
# a nested block's body is its own region, so this never descends into a
# closure's own body -- that gets its own top-level call from
# verifyDeclaredParams's own "blocks" loop above; hir::children's "block"
# case would otherwise recurse into it).
proc hir::range::VerifyCallArguments {hirVar ranges e} {
    upvar 1 $hirVar hir
    set node [dict get $hir exprs $e]
    set kind [dict get $node kind]
    if {$kind eq {call}} {
        VerifyCall hir $ranges $e $node
    }
    if {$kind eq {block}} {
        return
    }
    foreach child [hir::children $hir $e] {
        VerifyCallArguments hir $ranges $child
    }
}

# Checks one call E's arguments against its target's declared parameter
# types, if any (a call whose target is not a directly-known block -- an
# unresolved dynamic dispatch -- is outside this feature's scope; see
# STRICT-TYPED-PARAMETERS.md's "Dynamic/function-value call handling").
proc hir::range::VerifyCall {hirVar ranges e node} {
    upvar 1 $hirVar hir
    lassign [dict get $node target] targetKind targetBlock
    if {$targetKind ne {block}} { return }
    set targetNode [dict get $hir exprs $targetBlock]
    set declaredTypes [dict get $targetNode declaredParamTypes]
    set params [dict get $targetNode params]
    set args [dict get $node args]
    if {[llength $args] != [llength $params]} {
        # An arity mismatch is diagnosed elsewhere (or the call never
        # completes normally); nothing sound to check argument-by-argument.
        return
    }
    foreach arg $args paramBinding $params declaredType $declaredTypes {
        if {$declaredType eq {}} { continue }
        set argType [hir::typeOf $hir $arg]
        set argRange [expr {[dict exists $ranges $arg] ? [dict get $ranges $arg] : [unknown]}]
        if {[ProvesValueAcceptedBy $argType $argRange $declaredType]} {
            continue
        }
        hir::Diagnose hir TYPE [format \
            {argument for parameter "%s" cannot be proven to satisfy %s (argument type: %s, facts: %s)} \
            [dict get $hir bindings $paramBinding name] [hir::types::show $declaredType] \
            [hir::types::show $argType] [show $argRange]] $arg
    }
}

proc hir::range::If {hirVar ctxVar e node} {
    upvar 1 $hirVar hir $ctxVar ctx
    set condition [dict get $node condition]
    Expr hir ctx $condition
    set known [hir::types::KnownOutcome $hir $condition]
    set saved [dict get $ctx bindings]
    set branches [dict create]
    set after [dict create]
    foreach {outcome role} {1 then 0 else} {
        if {$known ne "" && $known != $outcome} {
            dict set branches $outcome never
            dict set after $outcome $saved
            continue
        }
        dict set ctx bindings $saved
        foreach {b r} [ComparisonNarrowing $hir $ctx $condition $outcome] {
            dict set ctx bindings $b $r
        }
        dict set branches $outcome [Sequence hir ctx [dict get $node ${role}Body]]
        dict set after $outcome [dict get $ctx bindings]
    }
    # What code textually after this "if" sees (spec #14's whole point: an
    # early-return/break guard -- the corpus's actual shape, e.g. reverse's
    # `if index == length(text): return ...` with no else, the recursive
    # call a later sibling statement, not nested in an else branch -- must
    # let a narrowed bound reach that sibling code, not just the branch body
    # itself). If one outcome never completes normally, only the other's
    # bindings (narrowed or not) are reachable afterward; if both are alive,
    # only the join of the two is safe. Every existing (pre-this-milestone)
    # binding is unchanged by either branch unless ComparisonNarrowing
    # touched it (an existing binding's range in ctx is otherwise never
    # rewritten -- only a fresh `bind` adds a new BindingId), so for any
    # program before this addition this reduces to plain restoration, same
    # as before.
    dict set ctx bindings [JoinBindings $saved [dict get $after 1] [dict get $after 0] $branches]
    if {$known ne ""} {
        return [dict get $branches $known]
    }
    return [join [dict get $branches 1] [dict get $branches 0]]
}

# The bindings dict code after an "if" sees, given SAVED (bindings entering
# it), AFTER1/AFTER0 (bindings leaving each branch, meaningful only when that
# branch is alive) and BRANCHES (each outcome's Range-or-never, to tell which
# branches are alive).
proc hir::range::JoinBindings {saved after1 after0 branches} {
    set dead1 [expr {[dict get $branches 1] eq "never"}]
    set dead0 [expr {[dict get $branches 0] eq "never"}]
    if {$dead1 && $dead0} {
        return $saved
    }
    if {$dead1} {
        return $after0
    }
    if {$dead0} {
        return $after1
    }
    set result [dict create]
    dict for {b r} $saved {
        set r1 [expr {[dict exists $after1 $b] ? [dict get $after1 $b] : $r}]
        set r0 [expr {[dict exists $after0 $b] ? [dict get $after0 $b] : $r}]
        dict set result $b [join $r1 $r0]
    }
    return $result
}

# ---------------------------------------------------------------------------
# Branch-derived narrowing (spec #14): what a `< <= > >=` condition directly
# says about a ref'd local/param binding's range on the branch its outcome
# (1 true, 0 false) selects. Sound and general -- no step/monotonicity
# reasoning, unlike hir/induction.tcl's equality-termination proof. `==`
# establishes nothing here (spec #15: equality alone never bounds a
# magnitude without an independent monotonicity fact).

# The binding a `ref` expression E names, if it is a proven-initialized local
# or parameter (the only bindings ctx bindings tracks a range for), else "".
#
# Soundness: `local` and `param` are hir/hir.tcl's two immutable-lexical-
# binding kinds (binding kind enum: root | ambient | param | local) -- both
# are bound exactly once, to a value that never changes for the life of the
# binding (spec #2, #25: a raw representation is a downstream consequence,
# never a source-semantics change, and Botlish has no parameter mutation to
# begin with). `root` (builtins/constants) and `ambient` (an open host
# environment's names in -mode sequence: not a checked program, no static
# facts to narrow) are excluded, unchanged from before this milestone.
proc hir::range::RefBinding {hir e} {
    if {[hir::kind $hir $e] ne "ref"} {
        return ""
    }
    set b [hir::get $hir $e binding]
    if {$b eq "" || [hir::get $hir $e init] eq "no"} {
        return ""
    }
    if {[dict get [hir::binding $hir $b] kind] ni {local param}} {
        return ""
    }
    return $b
}

# {binding Range ...}: what CONDITION (a call already evaluated into CTX's
# exprs, so its argument ranges are available) establishes when it evaluates
# to OUTCOME, for each side that is a ref'd local/param binding.
proc hir::range::ComparisonNarrowing {hir ctx condition outcome} {
    set node [hir::node $hir $condition]
    if {[dict get $node kind] ne "call"} {
        return {}
    }
    lassign [dict get $node target] targetKind target
    if {$targetKind ne "native"} {
        return {}
    }
    set name [dict get [hir::symbol $hir $target] name]
    set args [dict get $node args]
    if {[llength $args] != 2} {
        return {}
    }
    if {$name eq "=="} {
        set facts [EqualityNarrowing $hir $ctx $condition $args $outcome]
        if {$facts eq {}} {
            # No induction-proved termination guard for this condition:
            # fall back to the general exact-value-set rule (spec #33),
            # independent of any monotonicity proof.
            set facts [ExactEqualityNarrowing $hir $ctx $args $outcome]
        }
        return $facts
    }
    if {$name ni {< <= > >=}} {
        return {}
    }
    set op $name
    if {!$outcome} {
        # The false branch's fact is the comparison's negation.
        set op [dict get {< >= <= > > <= >= <} $op]
    }
    lassign $args ea eb
    set exprs [dict get $ctx exprs]
    set ra [expr {[dict exists $exprs $ea] ? [dict get $exprs $ea] : [unknown]}]
    set rb [expr {[dict exists $exprs $eb] ? [dict get $exprs $eb] : [unknown]}]
    set facts [dict create]
    set ba [RefBinding $hir $ea]
    if {$ba ne ""} {
        set n [Narrowed $op $ra $rb]
        if {$n ne ""} {
            dict set facts $ba $n
        }
    }
    set bb [RefBinding $hir $eb]
    if {$bb ne ""} {
        # "B [mirror of OP] A" is the same fact, stated about B.
        set mirror [dict get {< > <= >= > < >= <=} $op]
        set n [Narrowed $mirror $rb $ra]
        if {$n ne ""} {
            dict set facts $bb $n
        }
    }
    return $facts
}

# ComparisonNarrowing's `==` case. Equality alone proves nothing (spec #15):
# unless hir/induction.tcl already proved this exact "if P == B" sound as an
# equality-termination guard (ctx monotone, keyed by this same condition's
# expression id -- hir/induction.tcl's Guard found the identical HIR node,
# so it is the same P and the same B), in which case its false ("P != B")
# branch is exactly "P < B" / "P > B" per that proof, the same fact a
# `<`/`>` guard would give. Unlike the generic comparison case above, OP here
# is derived from the proof's step direction, not from the source order of
# CONDITION's two operands, so this resolves P and B itself (whichever side
# each is) rather than trying both sides symmetrically.
proc hir::range::EqualityNarrowing {hir ctx condition args outcome} {
    if {$outcome || ![dict exists [dict get $ctx monotone] $condition]} {
        return {}
    }
    lassign [dict get [dict get $ctx monotone] $condition] p step
    lassign $args ea eb
    set boundExpr [expr {[RefBinding $hir $ea] eq $p ? $eb : $ea}]
    set exprs [dict get $ctx exprs]
    set boundRange [expr {[dict exists $exprs $boundExpr] ? [dict get $exprs $boundExpr] : [unknown]}]
    set current [dict get [dict get $ctx bindings] $p]
    set n [Narrowed [expr {$step > 0 ? "<" : ">"}] $current $boundRange]
    return [expr {$n eq "" ? {} : [dict create $p $n]}]
}

# The Range of X narrowed by "X OP Y", given X's own range RX and Y's range
# RY, or "" if OP gives no new information (Y unbounded on the relevant
# side). If RX already tracks an exact set, it is filtered to the elements
# still within the narrowed interval too (spec #32: `x = {1,4,7,10}; x < 7`
# narrows the true branch to {1,4}, the false branch to {7,10}) -- reusing
# this same interval narrowing to select the filter, rather than a separate
# "exact-set branch engine" (spec #32's own instruction).
proc hir::range::Narrowed {op rx ry} {
    set mn [dict get $rx min]
    set mx [dict get $rx max]
    switch -- $op {
        < {
            if {[dict get $ry max] eq "+inf"} { return "" }
            set mx [Min $mx [SubBound [dict get $ry max] 1]]
        }
        <= {
            if {[dict get $ry max] eq "+inf"} { return "" }
            set mx [Min $mx [dict get $ry max]]
        }
        > {
            if {[dict get $ry min] eq "-inf"} { return "" }
            set mn [Max $mn [AddBound [dict get $ry min] 1]]
        }
        >= {
            if {[dict get $ry min] eq "-inf"} { return "" }
            set mn [Max $mn [dict get $ry min]]
        }
        default { return "" }
    }
    set r [dict create min $mn max $mx]
    set exact [ExactOf $rx]
    if {$exact eq ""} {
        return $r
    }
    set filtered {}
    foreach v $exact {
        if {($mn eq "-inf" || $v >= $mn) && ($mx eq "+inf" || $v <= $mx)} {
            lappend filtered $v
        }
    }
    if {$filtered eq ""} {
        # Would-be-empty: fall back to interval-only rather than
        # representing unreachability through this lattice (see this
        # file's "Exact value sets" header).
        return $r
    }
    return [Normalize $r $filtered]
}

# General exact-set equality narrowing (spec #33), independent of
# hir/induction.tcl's own monotone-termination proof (EqualityNarrowing,
# above): "x == K" (K a proven single point) narrows x's range to exactly
# {K} in the true branch; the false branch removes K from x's own tracked
# exact set, if it had one (spec #33's own `{0,16,32}` minus 16 example).
# Symmetric in EA/EB (unlike EqualityNarrowing, which resolves a specific
# proof's own P/B roles): each ref'd side is narrowed independently from the
# other side's already-computed Range.
proc hir::range::ExactEqualityNarrowing {hir ctx args outcome} {
    lassign $args ea eb
    set exprs [dict get $ctx exprs]
    set ra [expr {[dict exists $exprs $ea] ? [dict get $exprs $ea] : [unknown]}]
    set rb [expr {[dict exists $exprs $eb] ? [dict get $exprs $eb] : [unknown]}]
    set facts [dict create]
    foreach pair [list [list $ea $ra $rb] [list $eb $rb $ra]] {
        lassign $pair selfExpr selfRange otherRange
        set b [RefBinding $hir $selfExpr]
        if {$b eq ""} {
            continue
        }
        set n [PointEqualityNarrow $selfRange $otherRange $outcome]
        if {$n ne ""} {
            dict set facts $b $n
        }
    }
    return $facts
}

# X's Range narrowed by "X == Y" (OUTCOME 1) or "X != Y" (OUTCOME 0), given
# Y's own Range OTHER: when OTHER is a proven single point K, X narrows to
# exactly {K} if true, or has K removed from its own tracked exact set if
# false (no new fact if X has no exact set to filter, or OTHER is not a
# single known point -- this is deliberately scoped to spec #33's own case,
# not a general disequality solver).
proc hir::range::PointEqualityNarrow {self other outcome} {
    if {[dict get $other min] ne [dict get $other max] || [dict get $other min] eq "-inf"} {
        return ""
    }
    set k [dict get $other min]
    if {$outcome} {
        return [point $k]
    }
    set exact [ExactOf $self]
    if {$exact eq "" || $k ni $exact} {
        return ""
    }
    set remaining [lsearch -all -inline -not -exact $exact $k]
    if {$remaining eq ""} {
        return ""
    }
    return [Normalize $self $remaining]
}

# The region of instance ID's view HIR (already specialize::view'd): a dict
#   exprs   ExprId -> Range, for every reachable expression this pass could
#           say something about
#   result  the range of the region's normal completion (never if none)
#   calls   list of {TargetInstanceId ArgumentRangeList}, one per exact
#           block call this pass reached (hir::specialize's own "calls" --
#           self tail calls, ordinary same-instance recursion, and calls of
#           other instances alike); hir::range::analyze separates self from
#           cross-instance when it folds these into entry facts
proc hir::range::AnalyzeInstance {hir id instanceCalls block params assumed monotone calleeResults} {
    set ctx [dict create bindings [dict create] returnRange never breakRanges {} exprs [dict create] \
        calls {} id $id instanceCalls $instanceCalls monotone $monotone calleeResults $calleeResults]
    foreach b $params r $assumed {
        dict set ctx bindings $b $r
    }
    set body [expr {$block eq "program" ? [hir::roots $hir] : [hir::get $hir $block body]}]
    set final [Sequence hir ctx $body]
    set result [join $final [dict get $ctx returnRange]]
    return [dict create exprs [dict get $ctx exprs] result $result calls [dict get $ctx calls]]
}

# The block ExprIds that materialize (hir/aot.tcl::materializedBlocks) as an
# escaping Block value somewhere in the used instances' reachable code: a
# value that can be called through unknown dynamic dispatch this analysis
# has no edges for (spec #9, #28-29). Only a block's *generic* instance can
# ever run such a call (hir::specialize's own materialization rule always
# resolves a materialized value to the block's generic instance --
# specialize.tcl's own header, "Closures over values stay generic" and "not
# a static block"): a *specialized* instance's only possible callers are
# exactly the direct calls hir::specialize resolved to it, so it is never
# open regardless of this set.
proc hir::range::OpenInstances {spec} {
    set materialized [dict create]
    foreach id [dict get $spec used] {
        foreach block [dict get [dict get $spec instances $id] values] {
            dict set materialized $block 1
        }
    }
    set open [dict create]
    foreach id [dict get $spec used] {
        set instance [dict get $spec instances $id]
        if {[dict get $instance generic] && [dict get $instance block] ne "program"
                && [dict exists $materialized [dict get $instance block]]} {
            dict set open $id 1
        }
    }
    return $open
}

# Runs instance ID to its own local self-call fixpoint (self tail calls and
# ordinary same-instance recursion, exactly the mechanism this module had
# before interprocedural caller-propagation existed): ASSUMED is the entry
# Range per parameter to start from; LOCKED marks indices hir/induction.tcl
# already proved (never touched -- see analyze's own comment on this).
# Returns {outcome ASSUMED'}: the last pass's AnalyzeInstance result and the
# (possibly narrower-information, widened) settled entry Ranges.
proc hir::range::SettleInstance {hir id instanceCalls block params assumed locked monotone calleeResults} {
    variable maxPasses
    set n [llength $params]
    set outcome {}
    for {set pass 1} {$pass <= $maxPasses} {incr pass} {
        set outcome [AnalyzeInstance $hir $id $instanceCalls $block $params $assumed $monotone $calleeResults]
        set selfArgs {}
        foreach pair [dict get $outcome calls] {
            lassign $pair target argRanges
            if {$target eq $id} {
                lappend selfArgs $argRanges
            }
        }
        if {$selfArgs eq ""} {
            break
        }
        set next {}
        for {set i 0} {$i < $n} {incr i} {
            if {[dict exists $locked $i]} {
                lappend next [lindex $assumed $i]
                continue
            }
            set r never
            foreach call $selfArgs {
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
    return [list $outcome $assumed]
}

# ---------------------------------------------------------------------------
# Entry point

# Range facts for every used instance of specialization ANALYSIS (the return
# of hir::specialize::analyze) over program HIR. Returns a dict:
#   instances  InstanceId -> {params {Range ...} exprs {ExprId Range ...} result Range}
#
# Two cooperating mechanisms feed a used instance's parameter entry facts:
#
#   * SettleInstance's own self-call fixpoint (unchanged from before this
#     milestone): a self-recursive/self-tail call's argument ranges, fed
#     back into the same instance's own assumption.
#   * caller propagation (new): an *exact* call from another used instance
#     (hir::specialize's own call resolution -- never an open/dynamic
#     dispatch, which never appears in an instance's "calls" at all) seeds
#     the callee with the caller's own already-proven Range for the
#     argument expression, not just a syntactically literal one.
#
# Both read the caller/callee's Range the *same* way this module always
# has (AnalyzeInstance's ctx exprs), so an argument may be a Ref, an
# arithmetic expression, a branch-narrowed parameter reference, a known
# native result, or anything else this analysis already prices in -- never
# only a literal (spec #8).
#
# This is an ordinary monotone dataflow fixpoint over the "used" instance
# graph (self-recursion and, rarely, mutual recursion between distinct
# instances are its only cycles): each round re-settles every instance from
# its current entry facts, then folds every exact call's argument ranges
# into its callee's facts (join across every caller -- a safe hull, never
# an intersection or "whichever call site ran first": spec #11) and widens
# any bound that grew (same widen() as the self-call case) so growth jumps
# straight to infinity in one step instead of climbing forever. A bound can
# then change at most twice (unseen -> a first concrete value -> widened to
# infinity), so convergence needs only as many rounds as the longest
# caller-to-callee chain among the used instances, comfortably inside the
# round budget below; stopping once nothing changed in a full round is
# still sound if the budget is ever exhausted first, since every entry fact
# an unfinished fixpoint leaves behind is still real, if not maximally
# precise, evidence (never a guess).
#
# An instance flagged open (OpenInstances) never receives caller-propagated
# facts for any parameter: its set of known callers is not the full set of
# actual callers (spec #28-29), so joining only the known ones would be
# unsound over-narrowing; it keeps whatever hir/induction.tcl proved and is
# otherwise unknown, exactly as an instance with no known callers at all
# already was before this milestone.
proc hir::range::analyze {hir spec {callFactsOpt 1}} {
    # hir/induction.tcl is fed only the old, purely syntactic external seeds
    # (a literal argument, or a direct call to a native with context-free
    # -result-range metadata) -- unchanged by, and entirely independent of,
    # this proc's own caller-propagated seeding below, so its proof is
    # exactly as sound and exactly as narrow as it was before this
    # milestone (spec #17, #44: no induction capability change here).
    set literalSeeds [ExternalSeeds $hir $spec]
    # hir/induction.tcl's proof, when it fires, replaces a parameter's own
    # self-call feedback with a fixed answer (see below): unlike an ordinary
    # seed it is a *conclusion*, not just a starting guess, so widen must
    # never touch it, or the very growth its equality-termination argument
    # already accounts for would immediately widen it back to infinity (see
    # hir/induction.tcl's header).
    set induction [hir::induction::analyze $hir $spec $literalSeeds]
    set open [OpenInstances $spec]

    set ids [dict get $spec used]
    set blockOf [dict create]
    set paramsOf [dict create]
    set viewOf [dict create]
    set instanceCallsOf [dict create]
    set monotoneOf [dict create]
    set lockedOf [dict create]
    set assumed [dict create]
    set outcomes [dict create]
    set calleeResults [dict create]
    set resultPoisoned [dict create]
    # Indices this instance's own self-call feedback has, at some round,
    # actually *destroyed*: widened a concrete entry fact all the way to
    # unknown (never just started unknown with nothing yet to say -- see
    # the caller-propagation fold below, which must tell the two apart).
    set poisonedOf [dict create]

    foreach id $ids {
        set instance [dict get $spec instances $id]
        set block [dict get $instance block]
        dict set blockOf $id $block
        set params [expr {$block eq "program" ? {} : [hir::get $hir $block params]}]
        dict set paramsOf $id $params
        dict set viewOf $id [hir::specialize::view $hir $spec $id]
        dict set instanceCallsOf $id [dict get $instance calls]
        dict set monotoneOf $id [hir::induction::monotone $induction $id]

        set locked [dict create]
        set init {}
        set i 0
        foreach p $params {
            set override [hir::induction::of $induction $id $i]
            if {$override ne ""} {
                dict set locked $i 1
                lappend init $override
            } else {
                lappend init [unknown]
            }
            incr i
        }
        dict set lockedOf $id $locked
        dict set assumed $id $init
        dict set poisonedOf $id [dict create]
    }

    # Whether ID calls itself at all (self tail calls and ordinary
    # same-instance recursion alike -- hir::specialize's own "calls", not a
    # separate notion): the fold below must tell a *genuinely* self-derived
    # "unknown" (SettleInstance ran, found real self-call evidence, and it
    # proved the entry unbounded -- see POISONEDOF) apart from an
    # instance with no self-calls at all, whose entry fact is unknown only
    # because nothing has said otherwise yet, never a conclusion. Only the
    # first kind is safe to fold caller evidence into by *union* (it must
    # never lose ground); the second is free to be replaced outright by a
    # fresher, more precise caller computation as upstream callers
    # themselves finish converging (spec #12-13, #15: this is exactly why
    # work's parameter, having no self-calls, can still tighten from
    # drive's own still-converging else-branch fact once drive settles,
    # instead of being stuck at whatever drive's first, roughest pass gave
    # it).
    set selfRecursiveOf [dict create]
    foreach id $ids {
        dict set selfRecursiveOf $id [expr {$id in [dict values [dict get $instanceCallsOf $id]]}]
    }

    # A bound on rounds that scales with the instance count (a chain of N
    # instances can need up to N rounds for its first real value to
    # propagate end to end) plus a fixed cushion for the self-call/widen
    # settling every instance also does each round -- finite, deterministic,
    # never a per-interval or per-benchmark constant (spec #12, #24, #37).
    set roundBudget [expr {4 * [llength $ids] + 16}]
    for {set round 1} {$round <= $roundBudget} {incr round} {
        set changed 0
        set contributions [dict create]
        foreach id $ids {
            set before [dict get $assumed $id]
            lassign [SettleInstance [dict get $viewOf $id] $id [dict get $instanceCallsOf $id] \
                [dict get $blockOf $id] [dict get $paramsOf $id] $before \
                [dict get $lockedOf $id] [dict get $monotoneOf $id] $calleeResults] outcome settled
            dict set outcomes $id $outcome
            if {$settled ne $before} {
                set locked [dict get $lockedOf $id]
                set poisoned [dict get $poisonedOf $id]
                set i 0
                foreach b $before s $settled {
                    if {![dict exists $locked $i] && $b ne [unknown] && $s eq [unknown]} {
                        # Self-call feedback just destroyed a real entry
                        # fact (a genuine widen, not "nothing proven yet"):
                        # permanent, since a wider starting fact could only
                        # make the same self-recursion at least as
                        # unbounded, never less (the caller-propagation
                        # fold below must never treat this "unknown" as an
                        # empty slate safe to adopt a caller's Range into).
                        dict set poisoned $i 1
                    }
                    incr i
                }
                dict set poisonedOf $id $poisoned
                dict set assumed $id $settled
                set changed 1
            }
            foreach pair [dict get $outcome calls] {
                lassign $pair target argRanges
                if {$target eq $id || [dict exists $open $target]} {
                    continue
                }
                set current [expr {[dict exists $contributions $target]
                    ? [dict get $contributions $target] : [lrepeat [llength $argRanges] never]}]
                set next {}
                foreach c $current r $argRanges {
                    lappend next [join $c $r]
                }
                dict set contributions $target $next
            }
        }
        dict for {target contribution} $contributions {
            set locked [dict get $lockedOf $target]
            set poisoned [dict get $poisonedOf $target]
            set selfRecursive [dict get $selfRecursiveOf $target]
            set current [dict get $assumed $target]
            set next {}
            set i 0
            foreach o $current c $contribution {
                if {[dict exists $locked $i]} {
                    # Never touched: induction's own conclusion (see the
                    # header on this proc), not an ordinary seed to widen.
                    lappend next $o
                } elseif {!$selfRecursive} {
                    # No self-calls at all (SELFRECURSIVEOF, above): this
                    # parameter's entry fact is *entirely* a function of its
                    # exact callers, nothing here to preserve against, so
                    # each round recomputes it fresh from this round's
                    # calls instead of folding onto -- and thereby never
                    # improving past -- a rougher fact an earlier round
                    # (necessarily computed from a caller that had not yet
                    # settled itself: work's caller drive is a self-tail
                    # loop that only reaches its own [-∞,500] over several
                    # rounds) happened to produce first.
                    lappend next [expr {$c eq "never" ? [unknown] : $c}]
                } elseif {[dict exists $poisoned $i]} {
                    # This instance's own self-recursion already proved the
                    # entry unbounded (id-processing loop, above): permanent,
                    # and a caller's Range -- real or not yet -- cannot
                    # un-prove it.
                    lappend next [unknown]
                } elseif {$o eq [unknown]} {
                    # Self-recursive, but its own feedback has not (yet, or
                    # ever, if it never needs to move past its seed) said
                    # anything: the first real caller evidence is this
                    # parameter's first fact, adopted exactly, for the same
                    # reason as the non-self-recursive case above.
                    lappend next [expr {$c eq "never" ? [unknown] : $c}]
                } else {
                    # A genuine, already-established self-derived fact
                    # (drive's own [-∞,500], reached through its own
                    # self-tail widening): callers can only ever add to it,
                    # never replace it outright, and widen keeps that
                    # addition from taking many rounds to reach its own
                    # fixed point.
                    lappend next [widen $o [join $o $c]]
                }
                incr i
            }
            if {$next ne $current} {
                set changed 1
            }
            dict set assumed $target $next
        }
        # Successful value ranges are per instance; no effect fact follows.
        # An initial unknown is provisional while caller entry ranges settle.
        # Once a concrete summary appears it can only widen. If later caller
        # evidence destroys it, unknown is permanent for this analysis.
        if {$callFactsOpt} {
            foreach id $ids {
                set inferred [dict get $outcomes $id result]
                if {![dict exists $calleeResults $id]} {
                    set next $inferred
                } else {
                    set old [dict get $calleeResults $id]
                    if {[dict exists $resultPoisoned $id]} {
                        set next [unknown]
                    } elseif {$old eq [unknown]} {
                        set next $inferred
                    } else {
                        set next [join $old $inferred]
                        if {$next eq [unknown] && $old ne [unknown]} {
                            dict set resultPoisoned $id 1
                        }
                    }
                }
                if {![dict exists $calleeResults $id] || [dict get $calleeResults $id] ne $next} {
                    dict set calleeResults $id $next
                    set changed 1
                }
            }
        }
        if {!$changed} {
            break
        }
        if {$round == $roundBudget} {
            throw {HIR RANGE LIMIT} "hir::range: closed-call facts did not converge"
        }
    }

    set instances [dict create]
    foreach id $ids {
        set outcome [dict get $outcomes $id]
        dict set instances $id [dict create params [dict get $assumed $id] \
            exprs [dict get $outcome exprs] result [dict get $outcome result]]
    }
    return [dict create instances $instances induction $induction]
}

# The Range of expression E as instance ID's analysis proved it, or unknown.
proc hir::range::of {analysis id e} {
    set exprs [dict get [dict get $analysis instances $id] exprs]
    if {[dict exists $exprs $e]} {
        return [dict get $exprs $e]
    }
    return [unknown]
}
