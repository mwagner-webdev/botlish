# decimal.tcl -- DecimalRounded's runtime and its exact decimal arithmetic
# (DECIMAL-ROUNDED-MILESTONE-1.md).
#
# A DecimalRounded{minDecimalsPreserved: N} value stands for a *true value*
# t, a real number: the exact result of the program's arithmetic on the exact
# decimal numbers its literals spell. The type does not say how t is
# represented. It guarantees that the value is accurate enough that rounding
# it to any P <= N decimal places gives round(t, P), where round(x, P) is x
# rounded to the nearest multiple of 10^-P, ties to the even multiple (round
# half to even). The guarantee is *nested*: it holds at every precision up to
# N, so a guarantee at N is one at every smaller precision too, and weakening
# a type never needs its value to change.
#
# Every observation of a DecimalRounded value (a comparison, an equality, a
# conversion out, its display) reads round(v, P) at a precision P its static
# type guarantees -- never anything finer -- so two implementations that
# satisfy the guarantee make the same decisions. Which P is the compiler's
# (hir/decimal.tcl: the precision both operands' types guarantee, written
# into the call as its last argument); the runtime only computes.
#
# Representation (an implementation choice, not the type's meaning): a value
# is {DecimalRounded X}, X a finite Tcl double (an IEEE 754 binary64), never
# negative zero, exactly like a Float64's number (core/value.tcl). The
# compiler proves, for every value it gives a DecimalRounded type, that X
# satisfies the guarantee (hir/decimal.tcl); the runtime never checks or
# records a precision. Nothing here makes X observable: comparisons and
# conversions round it first, and core::value::show and equality refuse it
# (they do not know the precision of the type it has).
#
# Everything a proof needs is computed exactly, with Tcl's arbitrary-
# precision integers, never with host floating-point arithmetic or
# formatting: exact rationals ({P Q}, Q > 0, reduced), the exact value of a
# binary64 (DoubleRat), the correctly rounded binary64 of a rational
# (RatDouble: round to nearest, ties to even, subnormals, overflow), and
# round-half-even decimal rounding (RoundAt). A binary64 is built from and
# read as its bit pattern (binary format/scan), never parsed from text.
#
# Natives (DECIMAL-ROUNDED-MILESTONE-1.md, "Operations"):
#
#   DecimalRounded#+ - * /   (DR, DR) -> DR, errors NonFiniteFloat: the
#                            binary64 operation on the representations
#                            (decimal constant expressions only: a guarantee
#                            survives inexact arithmetic only when the
#                            operands' true values are known, so the
#                            compiler admits no other use, hir/decimal.tcl)
#   DecimalRounded#neg       (DR) -> DR: exact, and rounding is symmetric,
#                            so it keeps every guarantee of its operand
#   DecimalRounded#< <= > >= ==
#                            (DR, DR) -> bool: the comparisons as the checks
#                            see them; elaborated (hir::decimal::Elaborate)
#                            into the forms below before anything runs
#   decimal_rounded#less less_equal greater greater_equal equal
#                            (DR, DR, int P) -> bool: compares round(a, P)
#                            with round(b, P)
#   std::float64::from_decimal_rounded  (DR) -> Float64, elaborated into
#   decimal_rounded#to_float64          (DR, int P) -> Float64: the Float64
#                            nearest round(v, P)
#   std::decimal_rounded::round[T]  (Float64) -> T, elaborated into
#   decimal_rounded#round           (Float64, int N) -> DR, errors
#                            UnrepresentableDecimal: the value whose true
#                            value is round(x, N), or the error when no
#                            binary64 holds that decimal to N places
#   std::decimal_rounded::to_string (DR) -> str, elaborated into
#   decimal_rounded#to_string       (DR, int P) -> str: the decimal text of
#                            round(v, P) (`text`), P the precision v's static
#                            type guarantees (NUMERIC-TEXT-BOUNDARY-
#                            MILESTONE-1.md): exactly P fraction digits, no
#                            point for P = 0, a "-" only before a nonzero
#                            result. Total.

namespace eval core::decimal {
    # The runtime kind (core/value.tcl) and the scalar-refinement family
    # (hir/refinements.tcl) of the decimal-rounded numbers.
    variable kind DecimalRounded
    # The source operators a DecimalRounded operand selects, OPERATOR ->
    # {OP ARITY}, as core::float::operators does for a float type; `==` is
    # one too (a DecimalRounded value has no type-blind equality).
    variable operators [dict create \
        + {add 2} - {subtract 2} * {multiply 2} / {divide 2} \
        neg {negate 1} \
        < {less 2} <= {lessEqual 2} > {greater 2} >= {greaterEqual 2} == {equal 2}]
    # The elaborated comparison of each comparison operator (Elaborate's
    # target, with the observation precision as its last argument).
    variable comparisons [dict create \
        < decimal_rounded#less <= decimal_rounded#less_equal \
        > decimal_rounded#greater >= decimal_rounded#greater_equal \
        == decimal_rounded#equal]
    # The finite range of binary64: the smallest subnormal exponent and the
    # bound beyond which a rounded magnitude overflows.
    variable minExponent -1074
    variable precision 53
    variable maxExponent 1023
}

# ---------------------------------------------------------------------------
# Exact rationals: {P Q}, Q > 0, gcd(P, Q) = 1.

proc core::decimal::Gcd {a b} {
    set a [expr {abs($a)}]
    set b [expr {abs($b)}]
    while {$b != 0} {
        lassign [list $b [expr {$a % $b}]] a b
    }
    return $a
}

proc core::decimal::Rat {p q} {
    if {$q == 0} {
        error "core::decimal::Rat: zero denominator"
    }
    if {$q < 0} {
        set p [expr {-$p}]
        set q [expr {-$q}]
    }
    set g [Gcd $p $q]
    if {$g > 1} {
        set p [expr {$p / $g}]
        set q [expr {$q / $g}]
    }
    return [list $p $q]
}

proc core::decimal::RatAdd {a b} {
    lassign $a p1 q1
    lassign $b p2 q2
    return [Rat [expr {$p1 * $q2 + $p2 * $q1}] [expr {$q1 * $q2}]]
}

proc core::decimal::RatSub {a b} {
    lassign $b p2 q2
    return [RatAdd $a [list [expr {-$p2}] $q2]]
}

proc core::decimal::RatMul {a b} {
    lassign $a p1 q1
    lassign $b p2 q2
    return [Rat [expr {$p1 * $p2}] [expr {$q1 * $q2}]]
}

# A / B; B must not be zero.
proc core::decimal::RatDiv {a b} {
    lassign $a p1 q1
    lassign $b p2 q2
    return [Rat [expr {$p1 * $q2}] [expr {$q1 * $p2}]]
}

proc core::decimal::RatNeg {a} {
    return [list [expr {-[lindex $a 0]}] [lindex $a 1]]
}

proc core::decimal::RatSign {a} {
    set p [lindex $a 0]
    return [expr {$p > 0 ? 1 : ($p < 0 ? -1 : 0)}]
}

# -1, 0 or 1 as A is below, equal to or above B.
proc core::decimal::RatCmp {a b} {
    return [RatSign [RatSub $a $b]]
}

proc core::decimal::RatIsZero {a} {
    return [expr {[lindex $a 0] == 0}]
}

proc core::decimal::RatAbs {a} {
    return [list [expr {abs([lindex $a 0])}] [lindex $a 1]]
}

# The number of bits of the positive integer N.
proc core::decimal::BitLength {n} {
    return [string length [format %llb $n]]
}

# ---------------------------------------------------------------------------
# Decimal text

# The rational a decimal number TEXT spells exactly: an optional "-", DIGITS
# "." DIGITS and an optional exponent ([eE][+-]DIGITS) -- a source literal's
# exact text (the lexer's DECIMAL token value) or a canonical one (Text).
proc core::decimal::ParseDecimal {text} {
    if {![regexp {^(-?)([0-9]+)\.([0-9]+)(?:[eE]([-+]?[0-9]+))?$} $text -> sign whole fraction exponent]} {
        error "core::decimal::ParseDecimal: not a decimal number: \"$text\""
    }
    set digits [string trimleft $whole$fraction 0]
    if {$digits eq ""} {
        set digits 0
    }
    set scale [string length $fraction]
    if {$exponent ne ""} {
        set scale [expr {$scale - [scan $exponent %d]}]
    }
    set p $digits
    if {$sign eq "-"} {
        set p [expr {-$digits}]
    }
    if {$scale <= 0} {
        return [Rat [expr {$p * 10 ** (-$scale)}] 1]
    }
    return [Rat $p [expr {10 ** $scale}]]
}

# 1 if TEXT is decimal number syntax (ParseDecimal's).
proc core::decimal::IsDecimal {text} {
    return [regexp {^-?[0-9]+\.[0-9]+(?:[eE][-+]?[0-9]+)?$} $text]
}

# {SIGN DIGITS POINT} of the nonzero rational R if it is a finite decimal
# (its denominator divides a power of ten): R = SIGN 0.DIGITS x 10^POINT,
# DIGITS without leading or trailing zeros; "" otherwise.
proc core::decimal::DecimalDigits {r} {
    lassign $r p q
    set twos 0
    set fives 0
    set m $q
    while {$m % 2 == 0} { set m [expr {$m / 2}]; incr twos }
    while {$m % 5 == 0} { set m [expr {$m / 5}]; incr fives }
    if {$m != 1} {
        return ""
    }
    set scale [expr {max($twos, $fives)}]
    set n [expr {abs($p) * (10 ** $scale / $q)}]
    set text [string trimright $n 0]
    set stripped [expr {[string length $n] - [string length $text]}]
    set sign [expr {$p < 0 ? "-" : ""}]
    # n x 10^-scale = 0.TEXT x 10^(len(n) - scale), with the zeros stripped
    # from TEXT's end changing nothing.
    return [list $sign $text [expr {[string length $n] - $scale}]]
}

# The canonical text of the finite-decimal rational R: the layout of a
# Float64's canonical text (core::float::Text) -- positional for decimal
# exponents -4..15, else D.DDDeN -- of R's exact digits. A DecimalRounded
# constant of HIR and core IR is spelled so (one text per number).
proc core::decimal::Text {r} {
    if {[RatIsZero $r]} {
        return 0.0
    }
    set decomposed [DecimalDigits $r]
    if {$decomposed eq ""} {
        error "core::decimal::Text: [lindex $r 0]/[lindex $r 1] is not a finite decimal"
    }
    lassign $decomposed sign digits point
    set exponent [expr {$point - 1}]
    set n [string length $digits]
    if {$exponent >= $::core::float::minPositional && $exponent < $::core::float::maxPositional} {
        if {$point <= 0} {
            return "${sign}0.[string repeat 0 [expr {-$point}]]$digits"
        }
        if {$point >= $n} {
            return "$sign$digits[string repeat 0 [expr {$point - $n}]].0"
        }
        return "$sign[string range $digits 0 $point-1].[string range $digits $point end]"
    }
    set rest [string range $digits 1 end]
    if {$rest eq ""} {
        set rest 0
    }
    return "$sign[string index $digits 0].${rest}e$exponent"
}

# The canonical text (Text) of the decimal number TEXT.
proc core::decimal::canonical {text} {
    return [Text [ParseDecimal $text]]
}

# 1 if TEXT is the canonical text of a decimal number.
proc core::decimal::isCanonical {text} {
    return [expr {[IsDecimal $text] && [canonical $text] eq $text}]
}

# ---------------------------------------------------------------------------
# Binary64, exactly

# The bit pattern (an unsigned 64-bit integer) of the Tcl double X.
proc core::decimal::Bits {x} {
    binary scan [binary format q $x] wu bits
    return $bits
}

# The Tcl double whose bit pattern is BITS.
proc core::decimal::FromBits {bits} {
    binary scan [binary format wu $bits] q x
    return $x
}

# The exact rational value of the finite Tcl double X.
proc core::decimal::DoubleRat {x} {
    set bits [Bits $x]
    set negative [expr {$bits >> 63}]
    set biased [expr {($bits >> 52) & 0x7FF}]
    set fraction [expr {$bits & 0xFFFFFFFFFFFFF}]
    if {$biased == 0x7FF} {
        error "core::decimal::DoubleRat: $x is not finite"
    }
    if {$biased == 0} {
        set m $fraction
        set e -1074
    } else {
        set m [expr {$fraction | (1 << 52)}]
        set e [expr {$biased - 1075}]
    }
    if {$negative} {
        set m [expr {-$m}]
    }
    if {$e >= 0} {
        return [Rat [expr {$m << $e}] 1]
    }
    return [Rat $m [expr {1 << (-$e)}]]
}

# The integer nearest the rational R, ties to the even integer.
proc core::decimal::RoundHalfEven {r} {
    lassign $r p q
    # Tcl's integer division floors (toward minus infinity).
    set n [expr {$p / $q}]
    set rem [expr {$p - $n * $q}]
    set twice [expr {2 * $rem}]
    if {$twice > $q || ($twice == $q && $n % 2 != 0)} {
        incr n
    }
    return $n
}

# The binary64 nearest the rational R (ties to even), the definition of
# IEEE 754's round-to-nearest: {ok X}, X a Tcl double (zero is the positive
# zero), or {overflow SIGN} when the rounded magnitude is beyond the largest
# finite binary64 (SIGN 1 or -1).
proc core::decimal::RatDouble {r} {
    variable minExponent
    variable precision
    variable maxExponent
    lassign $r p q
    if {$p == 0} {
        return {ok 0.0}
    }
    set sign [expr {$p < 0 ? -1 : 1}]
    set p [expr {abs($p)}]
    # The exponent E of the last significand bit: floor(|R| / 2^E) has
    # exactly PRECISION bits (2^52 <= it < 2^53), unless E is the subnormal
    # floor.
    set e [expr {[BitLength $p] - [BitLength $q] - $precision + 1}]
    if {[Scaled $p $q $e floor] < (1 << ($precision - 1))} {
        incr e -1
    }
    if {$e < $minExponent} {
        set e $minExponent
    }
    set m [Scaled $p $q $e nearest]
    if {$m == (1 << $precision)} {
        # Rounded up into the next binade.
        set m [expr {1 << ($precision - 1)}]
        incr e
    }
    if {$m == 0} {
        return {ok 0.0}
    }
    # M x 2^E with M < 2^53: an overflow once it reaches 2^(EMAX + 1).
    if {$e + $precision > $maxExponent + 1} {
        return [list overflow $sign]
    }
    if {$m < (1 << ($precision - 1))} {
        # A subnormal (E is the floor).
        set bits $m
    } else {
        set biased [expr {$e + 1075}]
        set bits [expr {($biased << 52) | ($m & 0xFFFFFFFFFFFFF)}]
    }
    if {$sign < 0} {
        set bits [expr {$bits | (1 << 63)}]
    }
    return [list ok [FromBits $bits]]
}

# P/Q divided by 2^E, as an integer: rounded down (MODE floor) or to the
# nearest integer, ties to even (nearest). P and Q are positive.
proc core::decimal::Scaled {p q e mode} {
    if {$e >= 0} {
        set r [list $p [expr {$q << $e}]]
    } else {
        set r [list [expr {$p << (-$e)}] $q]
    }
    if {$mode eq "floor"} {
        return [expr {[lindex $r 0] / [lindex $r 1]}]
    }
    return [RoundHalfEven $r]
}

# The finite double adjacent to X toward plus (DIRECTION 1) or minus (-1)
# infinity, or "" when there is none (X is the largest finite magnitude in
# that direction). Zero has one representation: its neighbors are the
# smallest subnormals.
proc core::decimal::NextDouble {x direction} {
    set bits [Bits $x]
    if {$x == 0} {
        set next [expr {$direction > 0 ? 1 : (1 << 63) | 1}]
    } elseif {($x > 0) == ($direction > 0)} {
        set next [expr {$bits + 1}]
    } else {
        set next [expr {$bits - 1}]
        if {($next & ~(1 << 63)) == 0} {
            return 0.0
        }
    }
    if {(($next >> 52) & 0x7FF) == 0x7FF} {
        return ""
    }
    return [FromBits $next]
}

# ---------------------------------------------------------------------------
# Decimal rounding and the guarantee

# The integer K with round(R, P) = K x 10^-P (round half to even), P >= 0.
proc core::decimal::RoundAt {r p} {
    lassign $r num den
    return [RoundHalfEven [Rat [expr {$num * 10 ** $p}] $den]]
}

# 1 if the double X satisfies the guarantee of a value whose true value is
# the rational T at precision N: for every P from 0 to N, round(X, P) equals
# round(T, P). (The nested guarantee; N < 0 asks for nothing.)
proc core::decimal::Satisfies {x t n} {
    set xr [DoubleRat $x]
    for {set p 0} {$p <= $n} {incr p} {
        if {[RoundAt $xr $p] != [RoundAt $t $p]} {
            return 0
        }
    }
    return 1
}

# The largest N for which the double X satisfies the guarantee of true
# value T (Satisfies): -1 when even P = 0 fails, `exact` when X is T itself
# (every precision holds).
proc core::decimal::Proven {x t} {
    set xr [DoubleRat $x]
    if {[RatCmp $xr $t] == 0} {
        return exact
    }
    # A cell of precision P is 10^-P wide, so once 10^-P is below |X - T| the
    # two are in different cells: the loop ends there at the latest.
    set p 0
    while 1 {
        if {[RoundAt $xr $p] != [RoundAt $t $p]} {
            return [expr {$p - 1}]
        }
        incr p
    }
}

# 1 if the proven precision PROVEN (Proven) reaches N.
proc core::decimal::Reaches {proven n} {
    return [expr {$proven eq "exact" || $proven >= $n}]
}

# The representation of a value whose true value is the rational T (a
# DecimalRounded constant, or the decimal a quantization establishes),
# chosen from T alone: among the binary64 nearest T and its two neighbors,
# the one satisfying the guarantee at the highest precision (Proven), then
# the nearest to T. Usually the nearest binary64 itself; its neighbor when T
# is a decimal tie the nearest binary64 lands on the wrong side of
# (1.245, whose nearest binary64 is above it, rounds to 1.24 at two places).
# "" when T has no finite binary64 (overflow).
proc core::decimal::Represent {t} {
    set nearest [RatDouble $t]
    if {[lindex $nearest 0] ne "ok"} {
        return ""
    }
    set x [lindex $nearest 1]
    set candidates [list $x]
    foreach direction {-1 1} {
        set y [NextDouble $x $direction]
        if {$y ne ""} {
            lappend candidates $y
        }
    }
    set best ""
    foreach y $candidates {
        set proven [Proven $y $t]
        set rank $proven
        if {$proven eq "exact"} {
            set rank 1000000
        }
        set distance [RatAbs [RatSub [DoubleRat $y] $t]]
        if {$best eq "" || $rank > [lindex $best 1]
                || ($rank == [lindex $best 1] && [RatCmp $distance [lindex $best 2]] < 0)} {
            set best [list $y $rank $distance]
        }
    }
    return [lindex $best 0]
}

# The decimal text of round(R, P), R a rational: P fraction digits (none
# for P = 0), for messages.
proc core::decimal::RoundedText {r p} {
    set k [RoundAt $r $p]
    set sign [expr {$k < 0 ? "-" : ""}]
    set digits [expr {abs($k)}]
    if {$p == 0} {
        return $sign$digits
    }
    if {[string length $digits] <= $p} {
        set digits [string repeat 0 [expr {$p + 1 - [string length $digits]}]]$digits
    }
    return "$sign[string range $digits 0 end-$p].[string range $digits end-[expr {$p - 1}] end]"
}

# The exact decimal value of the double X, for messages: every digit of its
# expansion (a binary64 is a finite decimal) up to 40 significant ones, then
# "...".
proc core::decimal::BinaryText {x} {
    set r [DoubleRat $x]
    if {[RatIsZero $r]} {
        return 0.0
    }
    lassign [DecimalDigits $r] sign digits point
    set shown [string range $digits 0 39]
    set more [expr {[string length $digits] > 40 ? "..." : ""}]
    set text [Text [ParseDecimal "${sign}0.${shown}e$point"]]
    return $text$more
}

# ---------------------------------------------------------------------------
# Values

# The DecimalRounded value represented by the finite Tcl double X (the one
# zero is positive, as for a float: core::value::float).
proc core::decimal::value {x} {
    variable kind
    if {$x == 0} {
        set x 0.0
    }
    return [list $kind $x]
}

# The representation (a Tcl double) of the DecimalRounded value V.
proc core::decimal::of {v} {
    variable kind
    if {[core::value::kind $v] ne $kind} {
        error "core::decimal: expected a DecimalRounded value, got \"$v\""
    }
    return [lindex $v 1]
}

# The value of the DecimalRounded constant TEXT (a canonical decimal, as HIR
# and core IR spell one): its representation is Represent's, a function of
# the number alone.
proc core::decimal::constant {text} {
    set x [Represent [ParseDecimal $text]]
    if {$x eq ""} {
        error "core::decimal::constant: $text has no binary64 representation"
    }
    return [value $x]
}

# The exact rational a constant's text TEXT spells (its true value).
proc core::decimal::trueValue {text} {
    return [ParseDecimal $text]
}

# The decimal text of round(V, P): its digits with exactly P fraction digits
# (none, and no point, for P = 0), and a "-" only for a nonzero result. The
# display of a value whose static type guarantees P places: a program
# result's (hir::decimal::Display) and std::decimal_rounded::to_string's,
# one rounding at P (RoundAt), never a search over precisions.
proc core::decimal::text {v p} {
    return [RoundedText [DoubleRat [of $v]] $p]
}

# ---------------------------------------------------------------------------
# Operations

# The completion of the arithmetic operation OP (`operators`) on the
# DecimalRounded values ARGS: the binary64 operation on their
# representations, as core::float::apply computes it -- {ok VALUE} or {error
# NonFiniteFloat RESULT}. The one computation of a decimal constant
# expression: the natives' and a static analysis's (-fold).
proc core::decimal::apply {op args} {
    set floats [lmap v $args {core::value::float Float64 [of $v]}]
    set completion [core::float::apply Float64 $op {*}$floats]
    if {[lindex $completion 0] ne "ok"} {
        return $completion
    }
    return [list ok [value [core::value::floatOf [lindex $completion 1]]]]
}

# The binary64 result of the operation OP on the doubles XS, computed
# exactly (the correctly rounded exact result: IEEE 754's definition of the
# basic operations), never with host arithmetic: {ok X} or {nonfinite}.
# What a proof assumes a run computes (hir/decimal.tcl); tests compare it
# with apply's.
proc core::decimal::ExactOperation {op xs} {
    set rs [lmap x $xs {DoubleRat $x}]
    lassign $rs a b
    switch -- $op {
        add      { set r [RatAdd $a $b] }
        subtract { set r [RatSub $a $b] }
        multiply { set r [RatMul $a $b] }
        divide {
            if {[RatIsZero $b]} {
                return nonfinite
            }
            set r [RatDiv $a $b]
        }
        negate { set r [RatNeg $a] }
        default { error "core::decimal::ExactOperation: unknown operation \"$op\"" }
    }
    set rounded [RatDouble $r]
    if {[lindex $rounded 0] ne "ok"} {
        return nonfinite
    }
    return $rounded
}

# The exact true value of the operation OP on the true values TS (rationals):
# {ok T}, or {undefined} for a division by an exact zero.
proc core::decimal::TrueOperation {op ts} {
    lassign $ts a b
    switch -- $op {
        add      { return [list ok [RatAdd $a $b]] }
        subtract { return [list ok [RatSub $a $b]] }
        multiply { return [list ok [RatMul $a $b]] }
        divide {
            if {[RatIsZero $b]} {
                return undefined
            }
            return [list ok [RatDiv $a $b]]
        }
        negate { return [list ok [RatNeg $a]] }
    }
    error "core::decimal::TrueOperation: unknown operation \"$op\""
}

# -1, 0 or 1 as round(A, P) is below, equal to or above round(B, P), A and B
# DecimalRounded values.
proc core::decimal::CompareAt {a b p} {
    set ka [RoundAt [DoubleRat [of $a]] $p]
    set kb [RoundAt [DoubleRat [of $b]] $p]
    return [expr {$ka < $kb ? -1 : ($ka > $kb ? 1 : 0)}]
}

# The Float64 nearest round(V, P): a DecimalRounded value decayed to a
# Float64 at the precision its type guarantees (never its representation,
# which may carry digits no type guarantees).
proc core::decimal::ToFloat64 {v p} {
    set rounded [RatDouble [Rat [RoundAt [DoubleRat [of $v]] $p] [expr {10 ** $p}]]]
    # round(V, P) is within half a unit of V's own finite magnitude, so it
    # rounds to a finite binary64 (the largest finite magnitude is an integer).
    return [core::value::float Float64 [lindex $rounded 1]]
}

# The quantization of the Float64 value X at N places: {ok VALUE}, the
# DecimalRounded value whose true value is the decimal round(X, N), or
# {error UnrepresentableDecimal} when no binary64 satisfies that true value's
# guarantee at N places (Represent's choice does not: a decimal finer than
# binary64 resolves at that magnitude).
proc core::decimal::Quantize {x n} {
    set t [Rat [RoundAt [DoubleRat [core::value::floatOf $x]] $n] [expr {10 ** $n}]]
    set y [Represent $t]
    if {$y eq "" || ![Satisfies $y $t $n]} {
        return {error UnrepresentableDecimal}
    }
    return [list ok [value $y]]
}

# ---------------------------------------------------------------------------
# Natives

# The value of a completion COMPLETION for the native NAME, or its declared
# error.
proc core::decimal::Complete {name completion} {
    if {[lindex $completion 0] eq "ok"} {
        return [lindex $completion 1]
    }
    switch -- [lindex $completion 1] {
        NonFiniteFloat {
            set result [lindex $completion 2]
            core::native::failDeclared NonFiniteFloat "$name: the result is not a finite number ($result)" \
                [core::float::Payload $result]
        }
        UnrepresentableDecimal {
            core::native::failDeclared UnrepresentableDecimal \
                "$name: no available representation holds this decimal to the requested number of places"
        }
    }
    error "core::decimal::Complete: unexpected completion \"$completion\""
}

proc core::decimal::Operation {operator op args} {
    variable kind
    set name $kind#$operator
    foreach v $args {
        core::value::expect $kind $v $name
    }
    return [Complete $name [apply $op {*}$args]]
}

# A comparison's check form (DecimalRounded#<, ...): the operator as the
# static checks see it. hir::decimal::Elaborate makes every such call the
# elaborated comparison, which carries its precision, before anything runs.
proc core::decimal::Unelaborated {name args} {
    core::semanticError TYPE "$name: a DecimalRounded operation reached run time without the precision its operands' types guarantee (the compiler writes it into the call)"
}

# decimal_rounded#less ... (A, B, P): the comparison CMP of round(A, P)
# with round(B, P).
proc core::decimal::CompareNative {name cmp a b p} {
    variable kind
    core::value::expect $kind $a $name
    core::value::expect $kind $b $name
    set order [CompareAt $a $b [core::value::intOf $p]]
    return [core::value::bool [switch -- $cmp {
        less         { expr {$order < 0} }
        lessEqual    { expr {$order <= 0} }
        greater      { expr {$order > 0} }
        greaterEqual { expr {$order >= 0} }
        equal        { expr {$order == 0} }
    }]]
}

proc core::decimal::ToFloat64Native {v p} {
    variable kind
    core::value::expect $kind $v decimal_rounded#to_float64
    return [ToFloat64 $v [core::value::intOf $p]]
}

proc core::decimal::ToStringNative {v p} {
    variable kind
    core::value::expect $kind $v decimal_rounded#to_string
    return [core::value::str [text $v [core::value::intOf $p]]]
}

proc core::decimal::RoundNative {x n} {
    core::value::expect Float64 $x decimal_rounded#round
    return [Complete decimal_rounded#round [Quantize $x [core::value::intOf $n]]]
}

# The fold of a DecimalRounded arithmetic native (-fold, core/native.tcl):
# the call of the operation on the exactly known ARGS, decided like a float
# operation's (core::float::Fold).
proc core::decimal::Fold {op args} {
    variable kind
    foreach v $args {
        if {[core::value::kind $v] ne $kind} {
            return ""
        }
    }
    set completion [apply $op {*}$args]
    if {[lindex $completion 0] eq "ok"} {
        return [list value [lindex $completion 1]]
    }
    return [lrange $completion 0 1]
}

# The root native of the operation of the source operator OPERATOR
# (`operators`) on DecimalRounded operands, which hir/decimal.tcl resolves an
# operator call to.
proc core::decimal::operatorNative {operator} {
    variable kind
    variable operators
    if {![dict exists $operators $operator]} {
        error "core::decimal::operatorNative: no DecimalRounded operator \"$operator\""
    }
    return $kind#$operator
}

# The elaborated comparison of the comparison operator OPERATOR, or "".
proc core::decimal::comparisonNative {operator} {
    variable comparisons
    return [dict getdef $comparisons $operator ""]
}

# UnrepresentableDecimal: a quantization (std::decimal_rounded::round) whose
# decimal no available representation holds to the requested number of
# places. A builtin error after the binary ones (core/native.tcl's list of
# builtin errors), so it is declared here, where this file loads.
core::native::declareError UnrepresentableDecimal

apply {{} {
    variable kind
    variable operators
    dict for {operator spec} $operators {
        lassign $spec op arity
        set name [operatorNative $operator]
        set params [lrepeat $arity $kind]
        if {$op in {less lessEqual greater greaterEqual equal}} {
            core::native::register $name -arity $arity -impl [list core::decimal::Unelaborated $name] \
                -param-types $params -result-type bool -context-free 1
        } elseif {$op eq "negate"} {
            # (Negation keeps its operand's every guarantee: its result has
            # the operand's static type.)
            core::native::register $name -arity 1 -impl [list core::decimal::Operation $operator $op] \
                -param-types $params -result-type $kind -runtime float-alloc -context-free 1 \
                -result-shape {same 0} -fold [list core::decimal::Fold $op]
        } else {
            core::native::register $name -arity $arity -impl [list core::decimal::Operation $operator $op] \
                -param-types $params -result-type $kind -runtime float-alloc -errors NonFiniteFloat \
                -context-free 1 -fold [list core::decimal::Fold $op]
        }
    }
    foreach {name cmp} {
        decimal_rounded#less less decimal_rounded#less_equal lessEqual
        decimal_rounded#greater greater decimal_rounded#greater_equal greaterEqual
        decimal_rounded#equal equal
    } {
        core::native::register $name -arity 3 -impl [list core::decimal::CompareNative $name $cmp] \
            -param-types [list $kind $kind int] -result-type bool -runtime bigint -context-free 1
    }
    core::native::register std::float64::from_decimal_rounded -arity 1 \
        -impl [list core::decimal::Unelaborated std::float64::from_decimal_rounded] \
        -param-types [list $kind] -result-type Float64 -context-free 1
    core::native::register decimal_rounded#to_float64 -arity 2 -impl core::decimal::ToFloat64Native \
        -param-types [list $kind int] -result-type Float64 -runtime {bigint float-alloc} -context-free 1
    core::native::register std::decimal_rounded::round -arity 1 \
        -impl [list core::decimal::Unelaborated std::decimal_rounded::round] \
        -param-types {Float64} -result-type $kind -errors UnrepresentableDecimal -context-free 1 \
        -imprint {vars {T} params {Float64} result {imprint T}}
    core::native::register decimal_rounded#round -arity 2 -impl core::decimal::RoundNative \
        -param-types {Float64 int} -result-type $kind -runtime {bigint float-alloc} \
        -errors UnrepresentableDecimal -context-free 1
    core::native::register std::decimal_rounded::to_string -arity 1 \
        -impl [list core::decimal::Unelaborated std::decimal_rounded::to_string] \
        -param-types [list $kind] -result-type str -context-free 1
    core::native::register decimal_rounded#to_string -arity 2 -impl core::decimal::ToStringNative \
        -param-types [list $kind int] -result-type str -runtime {bigint string-alloc} -context-free 1
} core::decimal}
