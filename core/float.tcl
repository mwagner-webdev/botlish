# float.tcl -- the primitive floating-point types' runtime
# (FLOAT64-MILESTONE-1.md).
#
# The float family (core/type.tcl's `floats`: Float64 today) is one set of
# rules, written once here for every width:
#
#   * A value is a finite real number exactly representable in its type
#     ({TYPE X}, core/value.tcl), with one representation: never NaN, never
#     an infinity, never negative zero.
#   * Every arithmetic operation is the exact real-number operation on its
#     operands, rounded to the nearest number of the type (ties to even),
#     IEEE 754's round-to-nearest. A result whose magnitude rounds beyond the
#     type's largest finite number, and a division by zero (0.0 / 0.0
#     included), has no value: the operation completes with the declared
#     builtin error NonFiniteFloat, the same for every width -- the error
#     names the condition, not a type. Its payload says which non-finite
#     result the operation had, {result: NonFiniteResult}: the builtin enum's
#     PositiveInfinity, NegativeInfinity or NotANumber (0.0 / 0.0). It is a
#     fact about the failure, for the handler at the boundary where it
#     happened; no value ever is NaN or an infinity, and no operation tests a
#     value for being one. A result that rounds to zero is zero (the positive
#     one).
#   * Negation and the comparisons are exact and never fail. == is
#     core::value::equal: exact equality of the two numbers.
#
# The natives below are registered per float type, from the table:
#
#   TYPE#+ TYPE#- TYPE#* TYPE#/   (TYPE, TYPE) -> TYPE, errors NonFiniteFloat
#   TYPE#neg                      (TYPE) -> TYPE
#   TYPE#< TYPE#<= TYPE#> TYPE#>= (TYPE, TYPE) -> bool
#   NS::from_int                  (int) -> TYPE, errors NonFiniteFloat
#   NS::truncate                  (TYPE) -> int (toward zero; exact, total)
#   NS::round                     (TYPE) -> int (to the nearest Int, ties to
#                                 the even one; exact, total)
#
# (NS is the type's `namespace`: float64.) A `#` name is no source spelling:
# the operators reach them through operator resolution (hir/operators.tcl,
# which reads `operators` below), never by name. The root native `/` exists
# for the operator's spelling only: Botlish has no integer division, so a `/`
# no floating-point operand selects is a compile-time error
# (hir::operators::verify), and the root native itself raises TYPE.
#
# Every operation is computed by core::float::apply, which the natives call
# and which static analyses call to decide a call whose arguments are exactly
# known (-fold, core/native.tcl): a decided call and a run of it are the same
# computation, so no result depends on whether the compiler decided it.
#
# Tcl's doubles are IEEE 754 binary64 with round-to-nearest-even arithmetic
# on every host this runtime supports, so Float64 arithmetic is Tcl's own
# `expr` (Round is the identity for width 64). A narrower width would round
# each binary64 result to it (one rounding of an exact binary64 result of +,
# -, * or / is innocuous for binary32); a wider one needs an implementation
# of its own. Neither exists yet: Round refuses any other width.

namespace eval core::float {
    # The operator spellings the float family defines, OPERATOR -> {OP
    # ARITY}: the operation core::float::apply performs. The source
    # operators (hir/operators.tcl) resolve to the native TYPE#OPERATOR,
    # unary minus to TYPE#neg.
    variable operators [dict create \
        + {add 2} - {subtract 2} * {multiply 2} / {divide 2} \
        neg {negate 1} \
        < {less 2} <= {lessEqual 2} > {greater 2} >= {greaterEqual 2}]
    # The canonical decimal text (Text) is positional for decimal exponents
    # in minPositional..maxPositional-1 and scientific otherwise.
    variable minPositional -4
    variable maxPositional 16
}

# ---------------------------------------------------------------------------
# Values

# X (a Tcl double) rounded to the float type TYPE.
proc core::float::Round {type x} {
    set width [dict get [core::type::floatInfo $type] width]
    if {$width != 64} {
        error "core::float: no arithmetic for the $width-bit floating-point type $type"
    }
    return $x
}

# {ok VALUE}: the TYPE value of X, a Tcl double result already rounded to
# TYPE; or {error NonFiniteFloat RESULT} when X is not finite, RESULT the
# NonFiniteResult case naming it (Classify).
proc core::float::Make {type x} {
    if {![expr {isfinite($x)}]} {
        return [list error NonFiniteFloat [Classify $x]]
    }
    return [list ok [core::value::float $type $x]]
}

# The NonFiniteResult case of the non-finite double X: NotANumber for NaN,
# else the infinity of X's sign.
proc core::float::Classify {x} {
    if {[expr {isnan($x)}]} {
        return NotANumber
    }
    if {$x > 0} {
        return PositiveInfinity
    }
    return NegativeInfinity
}

# The NonFiniteResult case of a division of the finite double X by zero:
# 0.0 / 0.0 is NotANumber, any other dividend the infinity of its sign (the
# divisor is the one zero, whose sign is positive).
proc core::float::DivisionByZero {x} {
    if {$x == 0} {
        return NotANumber
    }
    if {$x > 0} {
        return PositiveInfinity
    }
    return NegativeInfinity
}

# NonFiniteFloat's payload for the NonFiniteResult case RESULT: the value of
# its anonymous struct type {result: NonFiniteResult}.
proc core::float::Payload {result} {
    return [core::value::structOf [list {} result] [list [core::value::enumValue NonFiniteResult $result]]]
}

# The completion of the operation OP (`operators`) of the float type TYPE on
# the Botlish values ARGS, which have the operation's parameter types:
# {ok VALUE} (a TYPE value, or a Boolean of a comparison) or {error
# NonFiniteFloat RESULT} (Make). The one computation of every float operation: the
# natives' and a static analysis's (-fold).
proc core::float::apply {type op args} {
    set xs [lmap v $args {expr {double([core::value::floatOf $v])}}]
    lassign $xs x y
    switch -- $op {
        add      { set r [catch {expr {$x + $y}} z] }
        subtract { set r [catch {expr {$x - $y}} z] }
        multiply { set r [catch {expr {$x * $y}} z] }
        divide {
            if {$y == 0} {
                # Every quotient by zero is non-finite (an infinity, or NaN
                # for 0.0 / 0.0), whatever the dividend.
                return [list error NonFiniteFloat [DivisionByZero $x]]
            }
            set r [catch {expr {$x / $y}} z]
        }
        negate { return [Make $type [expr {-$x}]] }
        less         { return [list ok [core::value::bool [expr {$x < $y}]]] }
        lessEqual    { return [list ok [core::value::bool [expr {$x <= $y}]]] }
        greater      { return [list ok [core::value::bool [expr {$x > $y}]]] }
        greaterEqual { return [list ok [core::value::bool [expr {$x >= $y}]]] }
        default {
            error "core::float::apply: unknown operation \"$op\""
        }
    }
    if {$r} {
        # An arithmetic domain error of Tcl's (a NaN result): no value.
        return {error NonFiniteFloat NotANumber}
    }
    return [Make $type [Round $type $z]]
}

# The TYPE value nearest the Int value N (ties to even): {ok VALUE}, or
# {error NonFiniteFloat RESULT} when N's magnitude rounds beyond TYPE's range
# (the infinity of N's sign).
proc core::float::FromInt {type n} {
    set i [core::value::intOf $n]
    if {[catch {expr {double($i)}} x]} {
        return [list error NonFiniteFloat [expr {$i > 0 ? "PositiveInfinity" : "NegativeInfinity"}]]
    }
    return [Make $type [Round $type $x]]
}

# ---------------------------------------------------------------------------
# Decimal text
#
# The canonical text of a value (show, HIR and core IR literals) is the
# shortest decimal that reads back as exactly that number, written as a
# Botlish decimal literal: DIGITS "." DIGITS, with an exponent `eN` (no "+",
# no leading zeros) outside the positional range -- 1.5, -2.0, 0.0001,
# 1.0e16, 1.0e-5, 5.0e-324 -- with a "-" for a negative number. Tcl's own
# rendering of a double (tcl_precision 0) is the shortest round-trip digits;
# Text only lays those digits out (native/src/runtime/show.rs does the same
# from Rust's shortest digits).

# {SIGN DIGITS EXPONENT} of the finite nonzero double X: X = SIGN 0.DIGITS x
# 10^EXPONENT, DIGITS the shortest round-trip digits without leading or
# trailing zeros.
proc core::float::Decompose {x} {
    set sign [expr {$x < 0 ? "-" : ""}]
    set text [expr {abs($x)}]
    set e 0
    if {[regexp {^([^e]*)e([-+]?[0-9]+)$} $text -> text e]} {
        set e [scan $e %d]
    }
    set whole $text
    set fraction ""
    regexp {^([0-9]*)\.([0-9]*)$} $text -> whole fraction
    set digits $whole$fraction
    set point [expr {[string length $whole] + $e}]
    set stripped [string trimleft $digits 0]
    incr point [expr {[string length $stripped] - [string length $digits]}]
    return [list $sign [string trimright $stripped 0] $point]
}

# The canonical decimal text of the double X (finite).
proc core::float::Text {x} {
    variable minPositional
    variable maxPositional
    if {$x == 0} {
        return 0.0
    }
    lassign [Decompose $x] sign digits point
    # The decimal exponent of the leading digit.
    set exponent [expr {$point - 1}]
    set n [string length $digits]
    if {$exponent >= $minPositional && $exponent < $maxPositional} {
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

# The canonical decimal text of the float value V.
proc core::float::text {v} {
    return [Text [core::value::floatOf $v]]
}

# 1 if TEXT is decimal number syntax: an optional "-", DIGITS "." DIGITS and
# an optional exponent (core IR and HIR literals; the source lexer has its
# own, signless, rule).
proc core::float::IsDecimal {text} {
    return [regexp {^-?[0-9]+\.[0-9]+(?:[eE][-+]?[0-9]+)?$} $text]
}

# {ok VALUE} for the TYPE value nearest the decimal number TEXT (IsDecimal),
# or {error NonFiniteFloat} when it rounds beyond TYPE's range.
proc core::float::Parse {type text} {
    if {![IsDecimal $text]} {
        error "core::float::Parse: not a decimal number: \"$text\""
    }
    return [Make $type [Round $type [expr {double($text)}]]]
}

# 1 if TEXT is the canonical text of a TYPE value (a core IR or HIR literal).
proc core::float::isCanonical {type text} {
    if {![IsDecimal $text]} {
        return 0
    }
    set made [Parse $type $text]
    return [expr {[lindex $made 0] eq "ok" && [text [lindex $made 1]] eq $text}]
}

# The TYPE value whose canonical text is TEXT (isCanonical).
proc core::float::fromText {type text} {
    if {![isCanonical $type $text]} {
        error "core::float::fromText: not a canonical $type literal: \"$text\""
    }
    return [lindex [Parse $type $text] 1]
}

# The largest finite value of the float type TYPE: (2 - 2^(1-P)) x 2^EMAX.
proc core::float::largest {type} {
    set info [core::type::floatInfo $type]
    set p [dict get $info precision]
    set e [dict get $info maxExponent]
    return [core::value::float $type [Round $type [expr {(2.0 - 2.0 ** (1 - $p)) * 2.0 ** $e}]]]
}

# The 64-bit IEEE 754 binary64 bit pattern of the Float64 value V, as an
# unsigned integer (native constants and hashing; width 64 only).
proc core::float::bits64 {v} {
    binary scan [binary format q [core::value::floatOf $v]] wu bits
    return $bits
}

# ---------------------------------------------------------------------------
# Natives

# The root native of the float type TYPE's operation for the source operator
# OPERATOR (`operators`: + - * / < <= > >= neg), which hir/operators.tcl
# resolves an operator call to.
proc core::float::operatorNative {type operator} {
    variable operators
    if {![dict exists $operators $operator]} {
        error "core::float::operatorNative: no floating-point operator \"$operator\""
    }
    return $type#$operator
}

# The value of a completion COMPLETION of apply/FromInt for the native NAME,
# or its declared error.
proc core::float::Complete {name completion} {
    if {[lindex $completion 0] eq "ok"} {
        return [lindex $completion 1]
    }
    set result [lindex $completion 2]
    core::native::failDeclared NonFiniteFloat "$name: the result is not a finite number ($result)" [Payload $result]
}

proc core::float::Operation {type operator op args} {
    set name $type#$operator
    foreach v $args {
        core::value::expect $type $v $name
    }
    return [Complete $name [apply $type $op {*}$args]]
}

proc core::float::FromIntNative {type name n} {
    core::value::expect int $n $name
    return [Complete $name [FromInt $type $n]]
}

# {ok INT}: the Int value of the float value V with its fraction dropped
# (toward zero). Exact and total: every finite float is an Int and a fraction.
proc core::float::Truncate {type v} {
    return [list ok [core::value::intFromNumber [expr {entier([core::value::floatOf $v])}]]]
}

proc core::float::TruncateNative {type name v} {
    core::value::expect $type $v $name
    return [lindex [Truncate $type $v] 1]
}

# {ok INT}: the Int nearest the float value V, ties to the even Int
# (NUMERIC-TEXT-BOUNDARY-MILESTONE-1.md) -- the rule every rounding of the
# numeric model uses: IEEE 754's round-to-nearest of the arithmetic, and
# DecimalRounded's round(x, P), of which this is round(x, 0)
# (core::decimal::RoundAt, the same procedure). Computed exactly from V's
# binary value (core::decimal::DoubleRat), never from its decimal text, so a
# value just below or above a half rounds by where it really is. Exact and
# total: every finite float is within half of some Int, of any size.
proc core::float::Nearest {type v} {
    set r [core::decimal::DoubleRat [core::value::floatOf $v]]
    return [list ok [core::value::intFromNumber [core::decimal::RoundAt $r 0]]]
}

proc core::float::NearestNative {type name v} {
    core::value::expect $type $v $name
    return [lindex [Nearest $type $v] 1]
}

# The fold of a float native (-fold, core/native.tcl): the call of the
# operation on the exactly known ARGS, decided -- {value V} or {error
# NonFiniteFloat} -- or "" when an argument is not of the operation's kind
# (the call then raises TYPE when it runs; nothing is decided).
proc core::float::Fold {type kinds command args} {
    foreach v $args kind $kinds {
        if {[core::value::kind $v] ne $kind} {
            return ""
        }
    }
    set completion [{*}$command {*}$args]
    if {[lindex $completion 0] eq "ok"} {
        return [list value [lindex $completion 1]]
    }
    return [lrange $completion 0 1]
}

# The root native `/`: reached only by a `/` no floating-point operand
# selected (hir/operators.tcl), which the front end rejects; a program run
# despite its diagnostics fails here.
proc core::float::NoDivision {a b} {
    core::semanticError TYPE "/: Botlish has no integer division; / divides floating-point values (got [core::value::show $a] / [core::value::show $b])"
}

# The payload of NonFiniteFloat (core/native.tcl declares the error itself):
# which non-finite result the failed operation had -- every width's, so the
# enum names results, never a type. Visible in every program, like the error.
core::native::declareEnum NonFiniteResult {PositiveInfinity NegativeInfinity NotANumber}
core::native::declareErrorPayload NonFiniteFloat {result {enum NonFiniteResult}}

core::native::register / -arity 2 -impl core::float::NoDivision -context-free 1

apply {{} {
    variable operators
    foreach type [core::type::floatTypes] {
        dict for {operator spec} $operators {
            lassign $spec op arity
            set name [operatorNative $type $operator]
            set params [lrepeat $arity $type]
            set fold [list core::float::Fold $type $params [list core::float::apply $type $op]]
            if {$op in {less lessEqual greater greaterEqual}} {
                core::native::register $name -arity $arity -impl [list core::float::Operation $type $operator $op] \
                    -param-types $params -result-type bool -context-free 1 -fold $fold
            } elseif {$op eq "negate"} {
                core::native::register $name -arity $arity -impl [list core::float::Operation $type $operator $op] \
                    -param-types $params -result-type $type -runtime float-alloc -context-free 1 -fold $fold
            } else {
                core::native::register $name -arity $arity -impl [list core::float::Operation $type $operator $op] \
                    -param-types $params -result-type $type -runtime float-alloc -errors NonFiniteFloat \
                    -context-free 1 -fold $fold
            }
        }
        set ns [dict get [core::type::floatInfo $type] namespace]
        core::native::register ${ns}::from_int -arity 1 -impl [list core::float::FromIntNative $type ${ns}::from_int] \
            -param-types {int} -result-type $type -runtime {bigint float-alloc} -errors NonFiniteFloat \
            -context-free 1 -fold [list core::float::Fold $type int [list core::float::FromInt $type]]
        core::native::register ${ns}::truncate -arity 1 -impl [list core::float::TruncateNative $type ${ns}::truncate] \
            -param-types [list $type] -result-type int -runtime bigint -context-free 1 \
            -fold [list core::float::Fold $type [list $type] [list core::float::Truncate $type]]
        core::native::register ${ns}::round -arity 1 -impl [list core::float::NearestNative $type ${ns}::round] \
            -param-types [list $type] -result-type int -runtime bigint -context-free 1 \
            -fold [list core::float::Fold $type [list $type] [list core::float::Nearest $type]]
    }
} core::float}
