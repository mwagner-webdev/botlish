# decimal.tcl -- DecimalRounded in the front end: which decimal literals
# are DecimalRounded constants, what the operators mean on DecimalRounded
# operands, the proofs that decide which guarantee a value has, and the
# precision every observation reads (DECIMAL-ROUNDED-MILESTONE-1.md).
#
# Semantics (core/decimal.tcl has the runtime half). A value of
# DecimalRounded{minDecimalsPreserved: N} stands for a true value t; the type
# guarantees that rounding the value to any P <= N places (half to even)
# gives round(t, P). An observation reads round(v, P) at a precision its
# operands' static types guarantee, so it never depends on digits no type
# guarantees and every correct implementation makes the same decision.
#
# Literal typing
# --------------
# A decimal literal is lowered as the Float64 nearest its decimal value
# (surface::lower::DecimalConstant) that still carries the exact decimal it
# spells (the const node's `decimal`). The choice between the two types is
# made here, inside type inference (resolve, called by hir::operators::
# resolve after every typing walk), and only here: a *decimal constant
# expression* -- a decimal literal, or unary minus or `+ - * /` of decimal
# constant expressions -- becomes a DecimalRounded expression when it stands
# where a DecimalRounded type is expected:
#
#   * a value of a function whose declared result is one (its final
#     expression, an `if` branch of it, a `return`);
#   * an argument of a parameter declared as one;
#   * a field of a struct construction whose field is declared as one;
#   * an element of a List literal where List[T] of one is expected;
#   * a handler's value, where the handled call's result type is one;
#   * an operand of an operator whose other operand is statically one (the
#     sibling's type is the expected type).
#
# Its literals then mean their exact decimals (never the Float64 they would
# otherwise round to), its operators the DecimalRounded operations, and its
# root carries the expected type (`decimalExpected`, with `decimalReason`
# saying why), which is its static type. Every other decimal literal stays
# the Float64 it was lowered to: there is no global literal inference.
#
# Proofs
# ------
# A decimal constant expression's every node has a known exact true value t
# (rational arithmetic on the literals' exact decimals) and a known
# implementation value: the representation of a literal is a function of its
# decimal alone (core::decimal::Represent), and each operation is the
# binary64 operation on its operands' representations, which IEEE 754
# defines as the correctly rounded exact result -- computed here with exact
# rationals (core::decimal::ExactOperation), never with host floating point.
# The root is accepted at its expected type DecimalRounded{minDecimalsPreserved:
# N, ...} only when the implementation value satisfies the nested guarantee
# for t at N (core::decimal::Satisfies); otherwise DECIMAL-PRECISION reports
# how many places it is proven to. A non-finite intermediate result is the
# completion analysis's KNOWN-ERROR NonFiniteFloat (the natives fold with the
# run's computation); a division by an exactly zero true value is no value
# (DECIMAL-PRECISION). A run computes exactly the proven operations: folding
# and running never differ, and no constant acquires a guarantee a run does
# not have.
#
# Arithmetic on any other DecimalRounded value -- a parameter, a call
# result, a field -- proves nothing (DECIMAL-GUARANTEE-LOST): only its
# guarantee is known, and correct rounding is discontinuous, so an operand
# anywhere in its rounding cell can carry the exact result across a
# rounding boundary of every precision; and absolute precision needs a
# magnitude the type does not state. Unary minus is the exception: exact,
# and rounding half to even is symmetric, so it keeps its operand's type.
#
# Observations
# ------------
# `< <= > >= ==` of two DecimalRounded operands compare round(a, P) with
# round(b, P), P the smaller of the two operands' guaranteed precisions (a
# decimal constant operand has its sibling's type, so P is always a declared
# precision); `!=` is the negation of `==`. `<` and `>` therefore hold only
# when the true values are provably ordered, and `==` means "the same
# decimal at P". std::float64::from_decimal_rounded(x) is the Float64 nearest
# round(x, N), N x's guaranteed precision. Elaborate writes each such P into
# the call (the run-time operation's last argument), after every check, so
# no backend chooses a precision. Equality of a List, struct or set holding
# DecimalRounded values does not know their precision: it is rejected where
# the program says so (verify) and raises EQUALITY where it does not
# (core::value::equal).

namespace eval hir::decimal {
    # The arithmetic operators of a decimal constant expression.
    variable treeOperators {+ - * / neg}
}

# 1 if TYPE is statically of the DecimalRounded kind (refined or not).
proc hir::decimal::IsDecimal {type} {
    return [expr {[hir::types::kindOf $type] eq $::core::decimal::kind}]
}

# 1 if TYPE is a refined DecimalRounded type (one with a guaranteed
# precision).
proc hir::decimal::IsRefined {type} {
    return [expr {[hir::refinements::IsRefined $type]
        && [hir::refinements::Family $type] eq $::core::decimal::kind}]
}

# The guaranteed precision (minDecimalsPreserved) of the refined
# DecimalRounded TYPE.
proc hir::decimal::Precision {type} {
    return [hir::refinements::fact $type minDecimalsPreserved]
}

# 1 if TYPE mentions a DecimalRounded type (itself, or in a List, set,
# vector, array or struct field).
proc hir::decimal::Mentions {type {seen {}}} {
    set type [hir::types::Unrefined $type]
    if {[IsDecimal $type]} {
        return 1
    }
    if {[hir::types::IsList $type] || [hir::types::IsSet $type]
            || [hir::types::IsMutVec $type] || [hir::types::IsMutArray $type]} {
        return [Mentions [lindex $type 1] $seen]
    }
    if {[hir::types::IsStruct $type]} {
        foreach {name t} [lindex $type 1] {
            if {[Mentions $t $seen]} {
                return 1
            }
        }
        return 0
    }
    if {[hir::types::IsNamedStruct $type]} {
        # (An application's fields, its slots replaced by the arguments:
        # TRAIT-CONSTRAINED-IMPRINTED-TYPES.md. SEEN guards a struct that
        # holds itself.)
        if {$type in $seen} {
            return 0
        }
        foreach {name t} [hir::structs::AppliedFieldTypes $type] {
            if {[Mentions $t [concat $seen [list $type]]]} {
                return 1
            }
        }
    }
    return 0
}

# ---------------------------------------------------------------------------
# Decimal constant expressions

# 1 if E is a decimal literal still of type Float64 (a const node carrying
# the exact decimal it spells).
proc hir::decimal::IsFloatLiteral {hir e} {
    set node [dict get $hir exprs $e]
    return [expr {[dict get $node kind] eq "const" && [dict exists $node decimal]
        && [lindex [dict get $node literal] 0] eq "Float64"}]
}

# The source operator of call E when it is an operator call of a decimal
# constant expression -- unresolved, or resolved to Float64's or
# DecimalRounded's operation -- else "".
proc hir::decimal::TreeOperator {hir e} {
    variable treeOperators
    set node [dict get $hir exprs $e]
    if {[dict get $node kind] ne "call"} {
        return ""
    }
    if {[dict exists $node operator]} {
        set op [dict get $node operator]
    } elseif {[dict exists $node resolvedOperator]
            && [lindex [dict get $node resolvedOperator] 1] in [list Float64 $::core::decimal::kind]} {
        set op [lindex [dict get $node resolvedOperator] 0]
    } else {
        return ""
    }
    if {$op ni $treeOperators} {
        return ""
    }
    return $op
}

# The operand expressions of operator call E (OP its operator): unary
# minus's operand without the synthetic 0 of an unresolved `0 - X`.
proc hir::decimal::Operands {hir e op} {
    set node [dict get $hir exprs $e]
    set args [dict get $node args]
    if {$op eq "neg" && [dict exists $node operator]} {
        return [lrange $args 1 end]
    }
    return $args
}

# 1 if E is a decimal constant expression not yet made a DecimalRounded one:
# a Float64 decimal literal, or a Float64 (or unresolved) operator call of
# decimal constant expressions.
proc hir::decimal::IsFloatTree {hir e} {
    if {[IsFloatLiteral $hir $e]} {
        return 1
    }
    set op [TreeOperator $hir $e]
    if {$op eq "" || [dict exists $hir exprs $e decimalTree]} {
        return 0
    }
    if {[dict exists $hir exprs $e resolvedOperator]
            && [lindex [dict get $hir exprs $e resolvedOperator] 1] ne "Float64"} {
        return 0
    }
    foreach a [Operands $hir $e $op] {
        if {![IsFloatTree $hir $a]} {
            return 0
        }
    }
    return 1
}

# Makes the decimal constant expression E (IsFloatTree, or a DecimalRounded
# one already) a DecimalRounded expression whose root E is expected to have
# the refined type EXPECTED (REASON says where the expectation comes from).
# Returns 1 if anything changed.
proc hir::decimal::Adopt {hirVar e expected reason} {
    upvar 1 $hirVar hir
    if {[dict exists $hir exprs $e decimalTree]} {
        # Already a DecimalRounded expression: a root keeps its expectation
        # current (a sibling's type may have changed), an inner node is its
        # tree's.
        if {[dict get $hir exprs $e decimalTree] ne $e
                || [dict get $hir exprs $e decimalExpected] eq $expected} {
            return 0
        }
        dict set hir exprs $e decimalExpected $expected
        dict set hir exprs $e decimalReason $reason
        return 1
    }
    if {![IsFloatTree $hir $e]} {
        return 0
    }
    Convert hir $e $e
    dict set hir exprs $e decimalExpected $expected
    dict set hir exprs $e decimalReason $reason
    return 1
}

# Converts node E of the decimal constant expression rooted at ROOT.
proc hir::decimal::Convert {hirVar e root} {
    upvar 1 $hirVar hir
    dict set hir exprs $e decimalTree $root
    if {[IsFloatLiteral $hir $e]} {
        # The literal's exact decimal, now a DecimalRounded constant: its
        # representation is chosen from that decimal alone
        # (core::decimal::constant), never from the Float64 it was.
        set text [dict get $hir exprs $e decimal]
        dict set hir exprs $e literal [list $::core::decimal::kind $text]
        dict set hir exprs $e value [core::decimal::constant $text]
        return
    }
    set op [TreeOperator $hir $e]
    set operands [Operands $hir $e $op]
    Retarget hir $e $op
    foreach a $operands {
        Convert hir $a $root
    }
}

# Makes operator call E (operator OP) a call of DecimalRounded's operation:
# its callee the root native, unary minus without its synthetic 0, and it is
# no longer an unresolved or a Float64 operator call.
proc hir::decimal::Retarget {hirVar e op} {
    upvar 1 $hirVar hir
    set native [core::decimal::operatorNative $op]
    set callee [dict get $hir exprs $e callee]
    set root [dict get $hir bindings [dict get $hir exprs $callee binding] scope]
    dict set hir exprs $callee binding [hir::resolve::RootBinding hir $root $native]
    dict set hir exprs $callee name $native
    if {$op eq "neg" && [dict exists $hir exprs $e operator]} {
        set args [dict get $hir exprs $e args]
        dict unset hir exprs [lindex $args 0]
        dict set hir exprs $e args [lrange $args 1 end]
    }
    if {[dict exists $hir exprs $e operator]} {
        dict unset hir exprs $e operator
        if {[dict exists $hir operatorCalls]} {
            dict set hir operatorCalls [lsearch -all -inline -not -exact [dict get $hir operatorCalls] $e]
        }
    }
    if {[dict exists $hir floatOperators]} {
        dict set hir floatOperators [lsearch -all -inline -not -exact [dict get $hir floatOperators] $e]
    }
    dict set hir exprs $e resolvedOperator [list $op $::core::decimal::kind]
    if {$e ni [dict getdef $hir decimalOperators {}]} {
        dict lappend hir decimalOperators $e
    }
}

# ---------------------------------------------------------------------------
# Resolution (inside hir::types::infer's fixpoint)

# Resolves, after a typing walk of HIR: every operator call with a
# DecimalRounded operand becomes a call of DecimalRounded's operation (its
# decimal constant sibling a DecimalRounded constant expression of the
# other operand's type), and every decimal constant expression where a
# refined DecimalRounded type is expected a DecimalRounded constant
# expression of that type. Returns 1 if anything changed (HIR is then typed
# again). Runs before Float64's resolution (hir::operators::resolve), so a
# DecimalRounded operand selects its operation even beside a Float64
# literal.
proc hir::decimal::resolve {hirVar} {
    upvar 1 $hirVar hir
    set changed 0
    # An unresolved operator call, or one an earlier walk resolved to
    # Float64's operation before an operand's type was known (a Float64
    # literal beside an operand still of type any selects Float64,
    # hir::operators::Selected): a DecimalRounded operand found since
    # selects DecimalRounded's operation instead.
    set calls [concat [dict getdef $hir operatorCalls {}] [dict getdef $hir floatOperators {}]]
    if {$calls ne {}} {
        foreach e $calls {
            if {[dict exists $hir exprs $e operator]} {
                set op [dict get $hir exprs $e operator]
            } elseif {[dict exists $hir exprs $e resolvedOperator]
                    && [lindex [dict get $hir exprs $e resolvedOperator] 1] eq "Float64"} {
                set op [lindex [dict get $hir exprs $e resolvedOperator] 0]
            } else {
                continue
            }
            set operands [Operands $hir $e $op]
            set types [lmap a $operands {hir::typeOf $hir $a}]
            set selected 0
            foreach t $types {
                if {[IsDecimal $t]} {
                    set selected 1
                }
            }
            if {!$selected} {
                continue
            }
            if {$op eq "==" || $op ni $::hir::decimal::treeOperators} {
                RetargetComparison hir $e $op
            } else {
                Retarget hir $e $op
            }
            set changed 1
        }
    }
    # Decimal constant expressions where a DecimalRounded type is expected.
    foreach {e expected reason} [Expectations $hir] {
        if {[Adopt hir $e $expected $reason]} {
            set changed 1
        }
    }
    return $changed
}

# Makes the comparison call E (operator OP: < <= > >= ==) a call of
# DecimalRounded's comparison check form (Elaborate writes its precision).
proc hir::decimal::RetargetComparison {hirVar e op} {
    upvar 1 $hirVar hir
    set native [core::decimal::operatorNative $op]
    set callee [dict get $hir exprs $e callee]
    set root [dict get $hir bindings [dict get $hir exprs $callee binding] scope]
    dict set hir exprs $callee binding [hir::resolve::RootBinding hir $root $native]
    dict set hir exprs $callee name $native
    if {[dict exists $hir exprs $e operator]} {
        dict unset hir exprs $e operator
        dict set hir operatorCalls [lsearch -all -inline -not -exact [dict get $hir operatorCalls] $e]
    }
    if {[dict exists $hir floatOperators]} {
        dict set hir floatOperators [lsearch -all -inline -not -exact [dict get $hir floatOperators] $e]
    }
    dict set hir exprs $e resolvedOperator [list $op $::core::decimal::kind]
    dict lappend hir decimalOperators $e
}

# Every place of HIR where a refined DecimalRounded type is expected of an
# expression, as a flat list {E EXPECTED REASON ...} (see the file header).
proc hir::decimal::Expectations {hir} {
    set result {}
    if {[dict exists $hir decimalOperators]} {
        foreach e [dict get $hir decimalOperators] {
            # An operand beside a statically refined DecimalRounded operand.
            set node [dict get $hir exprs $e]
            if {[dict exists $node decimalTree]} {
                continue
            }
            set args [dict get $node args]
            if {[llength $args] != 2} {
                continue
            }
            lassign [dict get $node resolvedOperator] op
            foreach a $args other [lreverse $args] {
                set t [hir::typeOf $hir $other]
                if {[IsRefined $t] && ![dict exists $hir exprs $other decimalTree]} {
                    lappend result $a $t [format {the other operand of "%s"} [OperatorText $op]]
                }
            }
        }
    }
    dict for {e node} [dict get $hir exprs] {
        switch -- [dict get $node kind] {
            block {
                set declared [dict get $node declaredResult]
                if {$declared eq "" || ![MentionsRefined $declared]} {
                    continue
                }
                set what "the declared result of [hir::callables::Name $hir $e]"
                foreach leaf [ResultPositions $hir $e] {
                    lappend result {*}[Expected $hir $leaf $declared $what]
                }
            }
            call {
                lassign [dict get $node target] targetKind target
                if {$targetKind ne "block" || ![dict exists $hir exprs $target declaredParamTypes]} {
                    continue
                }
                set params [dict get $hir exprs $target params]
                foreach arg [dict get $node args] declared [dict get $hir exprs $target declaredParamTypes] \
                        param $params {
                    if {$arg eq "" || $declared eq "" || ![MentionsRefined $declared]} {
                        continue
                    }
                    lappend result {*}[Expected $hir $arg $declared \
                        [format {parameter "%s" of %s} [hir::semantic::SourceName $hir $param] \
                            [hir::callables::Name $hir $target]]]
                }
            }
            handle {
                # A handler's value is the handled call's: it is held to the
                # call's normal result type (hir/types.tcl's Handle).
                set declared [hir::typeOf $hir [dict get $node call]]
                if {$declared eq "" || ![MentionsRefined $declared]} {
                    continue
                }
                foreach body [dict get $node handlerBodies] {
                    if {$body eq ""} {
                        continue
                    }
                    foreach leaf [Tails $hir [lindex $body end]] {
                        lappend result {*}[Expected $hir $leaf $declared "the result of the handled call"]
                    }
                }
            }
            struct {
                if {![dict get $node named] || [dict get $node structId] eq ""} {
                    continue
                }
                set id [dict get $node structId]
                # (A parameterized struct's construction: its application's
                # field types, TRAIT-CONSTRAINED-IMPRINTED-TYPES.md.)
                set structType [list nstruct $id]
                if {[hir::structs::isParameterized $id]} {
                    set structType [hir::typeOf $hir $e]
                }
                foreach name [dict get $node names] field [dict get $node fields] {
                    set declared [hir::types::StructField $structType $name]
                    if {$declared ne "" && [MentionsRefined $declared]} {
                        lappend result {*}[Expected $hir $field $declared \
                            [format {field "%s" of %s} $name [hir::types::show $structType]]]
                    }
                }
            }
        }
    }
    return $result
}

# 1 if TYPE is or holds (in a List) a refined DecimalRounded type.
proc hir::decimal::MentionsRefined {type} {
    set type [hir::types::Unrefined $type]
    if {[IsRefined $type]} {
        return 1
    }
    return [expr {[hir::types::IsList $type] && [MentionsRefined [lindex $type 1]]}]
}

# {E EXPECTED REASON ...}: expression E where TYPE is expected (WHAT says
# where), and the elements of a List literal E where a List of it is.
proc hir::decimal::Expected {hir e type what} {
    set type [hir::types::Unrefined $type]
    if {[IsRefined $type]} {
        return [list $e $type $what]
    }
    if {[hir::types::IsList $type] && [IsListLiteral $hir $e]} {
        set result {}
        foreach item [dict get $hir exprs $e args] {
            lappend result {*}[Expected $hir $item [lindex $type 1] "an element of $what"]
        }
        return $result
    }
    return {}
}

# 1 if E is a List literal ([a, b]: a call of the root native `list` the
# frontend wrote as one).
proc hir::decimal::IsListLiteral {hir e} {
    set node [dict get $hir exprs $e]
    if {[dict get $node kind] ne "call" || ![dict exists $node written]
            || [dict get $node written form] ne "list"} {
        return 0
    }
    return 1
}

# The expressions whose value is a value of block E: its final expression
# (or each branch's of an `if`, each of a handled call: the call and its
# handlers' final expressions) and the values of its own `return`s.
proc hir::decimal::ResultPositions {hir e} {
    set result {}
    foreach x [hir::warnings::BodyExprs $hir $e] {
        set node [dict get $hir exprs $x]
        if {[dict get $node kind] eq "return" && [dict get $node target] eq $e && [dict get $node value] ne ""} {
            lappend result {*}[Tails $hir [dict get $node value]]
        }
    }
    set body [dict get $hir exprs $e body]
    if {$body ne ""} {
        lappend result {*}[Tails $hir [lindex $body end]]
    }
    return $result
}

# The expressions whose value is E's: E, or the final expressions of an
# `if`'s branches, or of a handled call's call and handlers.
proc hir::decimal::Tails {hir e} {
    set node [dict get $hir exprs $e]
    switch -- [dict get $node kind] {
        if {
            set result {}
            foreach body [list [dict get $node thenBody] [dict get $node elseBody]] {
                if {$body ne ""} {
                    lappend result {*}[Tails $hir [lindex $body end]]
                }
            }
            return $result
        }
        handle {
            set result [Tails $hir [dict get $node call]]
            foreach body [dict get $node handlerBodies] {
                if {$body ne ""} {
                    lappend result {*}[Tails $hir [lindex $body end]]
                }
            }
            return $result
        }
    }
    return [list $e]
}

# The text of operator OP in a message.
proc hir::decimal::OperatorText {op} {
    if {$op eq "neg"} {
        return -
    }
    return $op
}

# ---------------------------------------------------------------------------
# Typing (hir/types.tcl's hooks)

# The static type of a DecimalRounded constant expression's root E, or "":
# the type it is expected to have, which verify proves.
proc hir::decimal::ExpectedType {hir e} {
    return [dict getdef [dict get $hir exprs $e] decimalExpected ""]
}

# ---------------------------------------------------------------------------
# Proofs

# The exact facts of node E of a DecimalRounded constant expression: {ok T
# X}, T its exact true value (a rational, core::decimal) and X the binary64 a
# run computes; {nonfinite} when a run's result (here or below) is not
# finite; {undefined} for a division by an exactly zero true value.
proc hir::decimal::Facts {hir e} {
    set node [dict get $hir exprs $e]
    if {[dict get $node kind] eq "const"} {
        set text [lindex [dict get $node literal] 1]
        return [list ok [core::decimal::trueValue $text] [core::decimal::of [dict get $node value]]]
    }
    lassign [dict get $node resolvedOperator] op
    set spec [dict get $::core::decimal::operators $op]
    set ts {}
    set xs {}
    foreach a [dict get $node args] {
        set facts [Facts $hir $a]
        if {[lindex $facts 0] ne "ok"} {
            return $facts
        }
        lappend ts [lindex $facts 1]
        lappend xs [lindex $facts 2]
    }
    set computed [core::decimal::ExactOperation [lindex $spec 0] $xs]
    if {[lindex $computed 0] ne "ok"} {
        return nonfinite
    }
    set exact [core::decimal::TrueOperation [lindex $spec 0] $ts]
    if {[lindex $exact 0] ne "ok"} {
        return undefined
    }
    return [list ok [lindex $exact 1] [lindex $computed 1]]
}

# The precision the DecimalRounded constant expression rooted at E is proven
# to (core::decimal::Proven: a number, -1 or `exact`), or {nonfinite} /
# {undefined} (Facts).
proc hir::decimal::ProvenPrecision {hir e} {
    set facts [Facts $hir $e]
    if {[lindex $facts 0] ne "ok"} {
        return $facts
    }
    return [core::decimal::Proven [lindex $facts 2] [lindex $facts 1]]
}

# ---------------------------------------------------------------------------
# Verification (hir::CheckOnce)

# Diagnoses (header):
#
#   DECIMAL-PRECISION      a DecimalRounded constant expression whose run is
#                          not proven to the precision its position expects
#                          (or that divides by an exactly zero true value);
#   DECIMAL-GUARANTEE-LOST arithmetic on DecimalRounded values whose exact
#                          values are not known (no guarantee survives it);
#   TYPE                   an operand of another kind beside a DecimalRounded
#                          one (nothing converts implicitly), an operation
#                          that needs a precision of a value whose type
#                          states none, equality of a value holding
#                          DecimalRounded values, a misused conversion.
proc hir::decimal::verify {hirVar} {
    upvar 1 $hirVar hir
    foreach e [dict getdef $hir decimalOperators {}] {
        if {![dict exists $hir exprs $e] || ![dict get $hir exprs $e reachable]} {
            continue
        }
        VerifyOperation hir $e
    }
    dict for {e node} [dict get $hir exprs] {
        if {[dict exists $node decimalExpected] && [dict get $node reachable]
                && [dict get $node decimalTree] eq $e} {
            VerifyConstant hir $e
        }
    }
    # Equality of values that hold DecimalRounded values (an unresolved
    # `==`: neither operand is one itself).
    foreach e [dict getdef $hir operatorCalls {}] {
        if {![dict exists $hir exprs $e operator] || [dict get $hir exprs $e operator] ne "=="
                || ![dict get $hir exprs $e reachable]} {
            continue
        }
        set types [lmap a [dict get $hir exprs $e args] {hir::typeOf $hir $a}]
        foreach t $types {
            if {[Mentions $t]} {
                hir::Diagnose hir TYPE [format \
                    {== of %s: a DecimalRounded value is equal to another at the precision its type guarantees, which equality of a value holding one does not know (compare the DecimalRounded values themselves)} \
                    [join [lmap t $types {hir::types::show $t}] " and "]] $e
                break
            }
        }
    }
    # The named conversions, and every set made of DecimalRounded values (an
    # annotation spelling one is rejected where it is resolved,
    # hir::types::resolveApplication).
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "call" || ![dict get $node reachable]} {
            continue
        }
        set t [hir::typeOf $hir $e]
        if {[lindex $t 0] eq "immutableSet" && [llength $t] == 2 && [Mentions [lindex $t 1]]} {
            hir::Diagnose hir TYPE [format \
                {this call makes %s: a set compares and hashes its members by value, which knows no precision, so it cannot hold DecimalRounded values (a List can; decay the members with std::float64::from_decimal_rounded to build a set of Float64)} \
                [hir::types::show $t]] $e
            continue
        }
        set name [CalledNative $hir $e]
        switch -- $name {
            std::float64::from_decimal_rounded {
                set t [hir::typeOf $hir [lindex [dict get $node args] 0]]
                if {[IsDecimal $t] && ![IsRefined $t]} {
                    PrecisionUnknown hir $e $t "decayed to a Float64"
                }
            }
            std::decimal_rounded::round {
                set t [hir::typeOf $hir $e]
                if {![IsRefined $t] && ![hir::imprint::Unbound $hir $e] && $t ni {never any}} {
                    hir::Diagnose hir TYPE [format \
                        {std::decimal_rounded::round makes a DecimalRounded value of the precision its imprint states, so it is imprinted with a DecimalRounded{...} type (std::decimal_rounded::round[DecimalRounded{minDecimalsPreserved: 2}](x)), not %s} \
                        [hir::types::show $t]] $e
                }
            }
        }
    }
}

# The root native call E calls, or "".
proc hir::decimal::CalledNative {hir e} {
    lassign [dict get $hir exprs $e target] kind y
    if {$kind ne "native"} {
        return ""
    }
    return [dict get [hir::symbol $hir $y] name]
}

# Checks the DecimalRounded operation call E.
proc hir::decimal::VerifyOperation {hirVar e} {
    upvar 1 $hirVar hir
    set node [dict get $hir exprs $e]
    lassign [dict get $node resolvedOperator] op
    set args [dict get $node args]
    set types [lmap a $args {hir::typeOf $hir $a}]
    if {[hir::operators::Mismatched $types $::core::decimal::kind]} {
        # (Poison, hir/types.tcl's Call: this is why.)
        set conversions "std::float64::from_decimal_rounded decays a DecimalRounded value to a Float64, std::decimal_rounded::round\[DecimalRounded{...}\] rounds a Float64 to one"
        hir::Diagnose hir TYPE [format \
            {the operands of "%s" are %s: a DecimalRounded operation needs DecimalRounded operands, and nothing converts one implicitly (%s; a decimal literal is a DecimalRounded constant beside a DecimalRounded operand)} \
            [OperatorText $op] [join [lmap t $types {hir::types::show $t}] " and "] $conversions] $e
        return
    }
    if {[dict exists $node decimalTree]} {
        # A DecimalRounded constant expression: proven at its root.
        return
    }
    if {[hir::types::Poisoned $hir $e] && ![Unprovable $hir $e]} {
        # An operand an earlier diagnostic rejected: no value to check.
        return
    }
    switch -- $op {
        + - - - * - / {
            # (Each of the four arithmetic operators.)
            Diagnose hir DECIMAL-GUARANTEE-LOST [format \
                {no decimal place of this %s can be proved: its operands are %s, values known only to the precision their types guarantee, and rounding is discontinuous -- an operand anywhere in its rounding cell can carry the exact result across a rounding boundary of every precision, and the type states no magnitude (only arithmetic of decimal constants is proven: decay the operands with std::float64::from_decimal_rounded to compute with Float64, and round a Float64 result back with std::decimal_rounded::round[DecimalRounded{...}])} \
                [OperationNoun $op] [join [lmap t $types {hir::types::show $t}] " and "]] $e
        }
        neg {
            if {![IsRefined [lindex $types 0]] && [IsDecimal [lindex $types 0]]} {
                PrecisionUnknown hir $e [lindex $types 0] "negated"
            }
        }
        default {
            foreach t $types {
                if {[IsDecimal $t] && ![IsRefined $t]} {
                    PrecisionUnknown hir $e $t "compared"
                    break
                }
            }
        }
    }
}

# 1 if call E is DecimalRounded arithmetic no proof can give a guarantee:
# `+ - * /` outside a DecimalRounded constant expression (header). Its
# value is poison (hir/types.tcl's Call): DECIMAL-GUARANTEE-LOST says why,
# and nothing that only restates it is reported.
proc hir::decimal::Unprovable {hir e} {
    set node [dict get $hir exprs $e]
    if {![dict exists $node resolvedOperator] || [dict exists $node decimalTree]} {
        return 0
    }
    lassign [dict get $node resolvedOperator] op type
    return [expr {$type eq $::core::decimal::kind && $op in {+ - * /}}]
}

# The clause of a type-mismatch message (hir::range::MismatchClause) when a
# value of ARGTYPE does not satisfy DECLARED and one of them is a
# DecimalRounded type, else "".
proc hir::decimal::MismatchClause {argType declared} {
    if {[IsRefined $argType] && [IsRefined $declared]} {
        set have [Precision $argType]
        set need [Precision $declared]
        if {$have < $need} {
            return [format {; a value of %s is known only to %d decimal place%s, and a guarantee is never strengthened without a proof (only a decimal constant's precision is proven)} \
                [hir::types::show $argType] $have [if {$have == 1} {string cat ""} else {string cat s}]]
        }
        set ceiling [hir::refinements::fact $argType maxDecimalsPreserved]
        set allowed [hir::refinements::fact $declared maxDecimalsPreserved]
        if {![hir::refinements::AtLeast $ceiling $allowed]} {
            set allows [if {$allowed eq "inf"} {string cat "states no upper bound"} else {format "allows observations to %s places" $allowed}]
            return [format {; observations of a value of %s are limited to %s decimal places (its maxDecimalsPreserved), and %s %s: an upper precision bound is never dropped or raised} \
                [hir::types::show $argType] $ceiling [hir::types::show $declared] $allows]
        }
        return ""
    }
    if {[IsDecimal $declared] && [hir::types::kindOf $argType] eq "Float64"} {
        return "; a Float64 is no DecimalRounded value, and nothing converts one implicitly (std::decimal_rounded::round\[DecimalRounded{...}\] rounds a Float64 to one; a decimal literal where a DecimalRounded type is expected is one)"
    }
    if {[IsDecimal $argType] && $declared eq "Float64"} {
        return "; a DecimalRounded value is no Float64, and nothing converts one implicitly (std::float64::from_decimal_rounded decays one to the Float64 nearest its guaranteed decimal)"
    }
    if {[IsRefined $declared] && [IsDecimal $argType]} {
        return "; the precision of this DecimalRounded value is not known statically"
    }
    return ""
}

# Reports a diagnostic of KIND at E (hir::Diagnose's).
proc hir::decimal::Diagnose {hirVar kind message e} {
    upvar 1 $hirVar hir
    hir::Diagnose hir $kind $message $e
}

# The noun of arithmetic operator OP's result.
proc hir::decimal::OperationNoun {op} {
    return [dict get {+ sum - difference * product / quotient} $op]
}

# Reports that the DecimalRounded value of static TYPE at E, which E's
# operation reads at a precision (WHAT: how it is used), has a type that
# states none.
proc hir::decimal::PrecisionUnknown {hirVar e type what} {
    upvar 1 $hirVar hir
    hir::Diagnose hir TYPE [format \
        {a DecimalRounded value of type %s is %s here, which reads it at a precision its type guarantees, but its type states none (declare the value's type DecimalRounded{minDecimalsPreserved: N})} \
        [hir::types::show $type] $what] $e
}

# Proves the DecimalRounded constant expression rooted at E against the type
# it is expected to have (header).
proc hir::decimal::VerifyConstant {hirVar e} {
    upvar 1 $hirVar hir
    set expected [dict get $hir exprs $e decimalExpected]
    set reason [dict get $hir exprs $e decimalReason]
    set n [Precision $expected]
    set proven [ProvenPrecision $hir $e]
    switch -- [lindex $proven 0] {
        nonfinite {
            # The completion analysis reports the operation that always
            # fails with NonFiniteFloat (KNOWN-ERROR).
            return
        }
        undefined {
            hir::Diagnose hir DECIMAL-PRECISION [format \
                {this decimal constant divides by a value whose exact decimal value is zero, so it has no value to round (%s expects %s), even though its binary64 computation divides by a nonzero approximation} \
                $reason [hir::types::show $expected]] $e
            return
        }
    }
    if {[core::decimal::Reaches $proven $n]} {
        return
    }
    set facts [Facts $hir $e]
    set t [lindex $facts 1]
    set x [lindex $facts 2]
    if {$proven < 0} {
        set claim "no decimal place of [Subject $hir $e] is proven correct (not even its rounding to an integer)"
    } else {
        set claim [format {%s is only proven correct to %d decimal place%s} [Subject $hir $e] $proven \
            [if {$proven == 1} {string cat ""} else {string cat s}]]
    }
    set first [expr {$proven + 1}]
    hir::Diagnose hir DECIMAL-PRECISION [format \
        {%s, but %s requires %s (its exact value is %s; its binary64 computation gives %s, which rounds to %s at %d place%s where the exact value rounds to %s)} \
        $claim $reason [hir::types::show $expected] [ExactText $t] [core::decimal::BinaryText $x] \
        [Abbreviated [core::decimal::RoundedText [core::decimal::DoubleRat $x] $first]] $first \
        [if {$first == 1} {string cat ""} else {string cat s}] \
        [Abbreviated [core::decimal::RoundedText $t $first]]] $e
}

# A rounded decimal TEXT as a message shows it: whole when short, else its
# first digits and the last 32, where two roundings differ.
proc hir::decimal::Abbreviated {text} {
    if {[string length $text] <= 48} {
        return $text
    }
    return "[string range $text 0 7]...[string range $text end-31 end]"
}

# What the DecimalRounded constant expression rooted at E is called in a
# message: the literal itself, or "this result".
proc hir::decimal::Subject {hir e} {
    set node [dict get $hir exprs $e]
    if {[dict get $node kind] eq "const"} {
        return "the literal [lindex [dict get $node literal] 1]"
    }
    return "this result"
}

# The exact rational T as a message shows it: its decimal when it has one,
# else a fraction with its leading digits.
proc hir::decimal::ExactText {t} {
    if {[core::decimal::DecimalDigits $t] ne "" || [core::decimal::RatIsZero $t]} {
        return [core::decimal::Text $t]
    }
    return "[lindex $t 0]/[lindex $t 1] = [core::decimal::RoundedText $t 20]..."
}

# ---------------------------------------------------------------------------
# Elaboration (hir::BuildFull, after the checks)

# Writes the precision every observation of a DecimalRounded value reads
# into its call (header): a comparison's check form becomes its run-time
# comparison with P, the smaller guaranteed precision of its operands; a
# decay std::float64::from_decimal_rounded(x) becomes decimal_rounded#to_float64
# with x's guaranteed precision; a quantization std::decimal_rounded::round[T](x)
# becomes decimal_rounded#round with T's. A call whose precision is not
# known (verify reported it) keeps its check form, which refuses to run.
proc hir::decimal::Elaborate {hirVar} {
    upvar 1 $hirVar hir
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "call"} {
            continue
        }
        set name [CalledNative $hir $e]
        if {$name eq ""} {
            continue
        }
        set args [dict get $node args]
        set precision ""
        set target ""
        if {[string match "$::core::decimal::kind#*" $name]} {
            set op [string range $name [string length "$::core::decimal::kind#"] end]
            set target [core::decimal::comparisonNative $op]
            if {$target eq ""} {
                continue
            }
            set types [lmap a $args {hir::typeOf $hir $a}]
            if {[IsRefined [lindex $types 0]] && [IsRefined [lindex $types 1]]} {
                set precision [expr {min([Precision [lindex $types 0]], [Precision [lindex $types 1]])}]
            }
        } elseif {$name eq "std::float64::from_decimal_rounded"} {
            set target decimal_rounded#to_float64
            set t [hir::typeOf $hir [lindex $args 0]]
            if {[IsRefined $t]} {
                set precision [Precision $t]
            }
        } elseif {$name eq "std::decimal_rounded::round"} {
            set target decimal_rounded#round
            set t [hir::typeOf $hir $e]
            if {[IsRefined $t]} {
                set precision [Precision $t]
            }
        } else {
            continue
        }
        if {$precision eq ""} {
            continue
        }
        set root [dict get $hir scopes [dict get $hir top] parent]
        hir::resolve::RootBinding hir $root $target
        hir::mutvec::Retarget hir $e $target
        if {[dict exists $hir exprs $e imprint]} {
            # (The run-time operation is not imprinted: its precision is an
            # argument now.)
            dict unset hir exprs $e imprint
        }
        dict set hir exprs $e args [concat $args [list [NewInt hir $precision $e]]]
    }
}

# A new const Int node N, placed like expression AT.
proc hir::decimal::NewInt {hirVar n at} {
    upvar 1 $hirVar hir
    set node [dict get $hir exprs $at]
    set c [hir::NewId hir expr]
    set literal [hir::syntax::constNode [dict get $node origin] $n]
    dict set hir exprs $c [dict merge $literal [dict create id $c \
        scope [dict get $node scope] type [hir::types::intern hir int] reachable [dict get $node reachable] \
        value [core::value::int $n]]]
    return $c
}

# ---------------------------------------------------------------------------
# Display

# The display of the program result VALUE, whose static type is TYPE:
# core::value::show's, except that a DecimalRounded value shows its
# rounding to the precision its static type guarantees
# (core::decimal::text) wherever TYPE says one -- in a List, a struct field
# -- and <DecimalRounded> where it does not (its representation is never
# shown: it may hold digits no type guarantees).
proc hir::decimal::Display {value type} {
    if {![ContainsDecimal $value]} {
        return [core::value::show $value 1]
    }
    return [Show $value $type]
}

proc hir::decimal::ContainsDecimal {value} {
    return [expr {[string first $::core::decimal::kind $value] >= 0}]
}

proc hir::decimal::Show {value type} {
    set type [hir::types::Unrefined $type]
    set kind [core::value::kind $value]
    if {$kind eq $::core::decimal::kind} {
        if {[IsRefined $type]} {
            return [core::decimal::text $value [Precision $type]]
        }
        return [core::value::show $value 1]
    }
    if {$kind eq "list"} {
        set elem any
        if {[hir::types::IsList $type]} {
            set elem [lindex $type 1]
        }
        return "\[[join [lmap item [core::value::items $value] {Show $item $elem}] {, }]\]"
    }
    if {$kind eq "struct" && ![core::value::isOpaqueStruct [lindex $value 1 0]]} {
        set id [lindex $value 1 0]
        set parts {}
        foreach field [lrange [lindex $value 1] 1 end] item [lindex $value 2] {
            set fieldType any
            if {[hir::types::IsStruct $type] && [dict exists [lindex $type 1] $field]} {
                set fieldType [dict get [lindex $type 1] $field]
            } elseif {[hir::types::IsNamedStruct $type] && [hir::types::StructField $type $field] ne ""} {
                # (The static type's own field: an application's, its slots
                # replaced, TRAIT-CONSTRAINED-IMPRINTED-TYPES.md.)
                set fieldType [hir::types::StructField $type $field]
            } elseif {$id ne "" && [hir::structs::fieldType $id $field] ne ""} {
                set fieldType [hir::structs::fieldType $id $field]
            }
            lappend parts "$field: [Show $item $fieldType]"
        }
        set text "{[join $parts {, }]}"
        if {$id ne ""} {
            return "$id $text"
        }
        return $text
    }
    return [core::value::show $value 1]
}
