# variadic.tcl -- variadic parameters of Botlish functions
# (VARIADICS-VERTICAL-SLICE-1.md).
#
# A function may end its parameter list with a variadic section
# (`fn sum(variadic xs: List[int])`, `fn log(level: int, variadic parts:
# List[str])`): one parameter bound, at each call, to the List of the call's
# trailing arguments. The parameter is an ordinary List parameter of the block
# -- its last ordinary one, before the flags -- and the body sees an ordinary
# immutable List of its declared type: there is no variadic value, type or
# runtime representation. What is variadic is the *call*: a call of the
# declared function (or of a name bound to it, `g = sum`; or method syntax,
# `x.log(a, b)`) passes the fixed arguments first and any number of trailing
# ones, and resolution collects the trailing ones into one ordinary list
# construction, exactly the call `list(...)` a list literal is, so
#
#     sum()          is   sum([])
#     sum(1, 2, 3)   is   sum([1, 2, 3])
#     log(1, a, b)   is   log(1, [a, b])
#
# Every argument is evaluated once, in written order (the list construction
# is the last argument and evaluates its elements in order), and each
# trailing one is held to the element type by its own admission proof
# (DiagnoseElements: element by element, which a List literal's static type
# cannot be), so `smalls(1, 9, 10)` is a List[Small] where the literal
# [1, 9, 10] is a List[int]; the List owns its elements like any other.
# Every analysis and backend downstream sees that ordinary call.
#
# What HIR keeps:
#
#   block expr   variadic   N: the function's first N parameters are its
#                           fixed ones, parameter N the variadic List (absent
#                           for a function without a variadic section)
#   binding      flagIface  ... variadic 1: the callee's interface
#                           (hir/flags.tcl), resolved statically at every
#                           call; `ordinary` counts the List parameter
#   call expr    variadic   {fixed N count K}: the call collected K trailing
#                           arguments after N fixed ones into its last
#                           argument, the list construction (absent on any
#                           other call)
#
# The declared type is List[T] (an imprint variable T is established by the
# collected List, hir/imprint.tcl) or a bare `List`, which in a variadic
# section only means List[T] for a fresh imprint variable no other name of
# the signature uses: the element type each call imprints, never List[any].
# A call with no trailing argument collects the empty list, List[never], the
# empty collection's own type (M7AA-EMPTY-COLLECTION-AND-APPLIED-TYPE-
# SEMANTICS.md); an explicit imprint (`inspect[int]()`) names it instead.
#
# A variadic function used as a value (passed, returned, stored) is the
# ordinary function of its List parameter: a call through a value has no
# statically known declaration whose trailing arguments it could collect, so
# it passes the List itself (`apply(sum, [1, 2])` with `fn apply(f, xs):
# f(xs)`). Function types carry no variadic marker; an imprinted one (List[T],
# bare List) is no value at all, as every imprinted callable.

namespace eval hir::variadic {}

# The fresh imprint variable a bare `List` variadic parameter's element is,
# for the block syntax node NODE of a function in namespace NS whose
# enclosing functions' imprint variables are ENCLOSING: the first of T, T1,
# T2, ... that is no name written in the signature, no enclosing variable and
# no type visible in NS (an imprint variable never names a visible type, so
# HIR text reads it back as the same variable).
proc hir::variadic::ElementVariable {node ns enclosing} {
    set words {}
    foreach t [concat [dict getdef $node paramTypes {}] [list [dict getdef $node declaredResult {}]]] {
        lappend words {*}[regexp -all -inline {[A-Za-z_][A-Za-z0-9_]*} $t]
    }
    for {set i 0} {1} {incr i} {
        set name [expr {$i == 0 ? "T" : "T$i"}]
        if {$name in $words || $name in $enclosing} {
            continue
        }
        if {![catch {hir::types::resolveNamed $name $ns}]} {
            continue
        }
        return $name
    }
}

# The declared type of the variadic parameter NAME of block E, resolved as
# DECLARED from the type expression TYPEEXPR: DECLARED when it is a List
# type, else "" after a TYPE diagnostic (the parameter is then untyped, as
# any parameter whose annotation is invalid).
proc hir::variadic::CheckDeclared {hirVar e name typeExpr declared} {
    upvar 1 $hirVar hir
    if {$declared eq "" || ([lindex $declared 0] eq "list" && [llength $declared] == 2)} {
        return $declared
    }
    hir::Diagnose hir TYPE [format \
        {the variadic parameter "%s" is declared %s, but a variadic parameter is bound to the List of the call's trailing arguments: declare it List[ELEMENT] (or a bare List, whose element type each call imprints)} \
        $name [hir::resolve::ShowTypeExpr $typeExpr]] $e
    return ""
}

# The argument syntax nodes of call E (its callee already resolved) with the
# trailing ones collected, when the callee is a variadic function: ARGNODES
# (the receiver first for method syntax) with every argument after the
# callee's fixed ones replaced by one list construction of them, at the
# call's origin (node ID/variadic). ARGNODES unchanged for any other callee, and for a call
# passing fewer than the fixed arguments: an ARITY diagnostic, and the call
# keeps the arguments it has (a -strict 0 program fails at run time as any
# call of the wrong arity does).
proc hir::variadic::Arguments {hirVar e argNodes} {
    upvar 1 $hirVar hir
    set callee [dict get $hir exprs $e callee]
    set iface [hir::flags::InterfaceOf $hir $callee]
    if {$iface eq "" || ![dict getdef $iface variadic 0]} {
        return $argNodes
    }
    set fixed [expr {[dict get $iface ordinary] - 1}]
    if {[llength $argNodes] < $fixed} {
        set flags [dict get $iface flags]
        hir::Diagnose hir ARITY [format \
            {function %s takes %d fixed argument(s) before its variadic parameter%s, got %d argument(s)} \
            [dict get $hir exprs $callee name] $fixed \
            [expr {$flags eq {} ? "" : " and the flags [join [lmap n $flags {string cat : $n}] {, }]"}] \
            [llength $argNodes]] $e
        return $argNodes
    }
    set origin [dict get $hir exprs $e origin]
    if {[dict exists $origin node]} {
        dict set origin node "[dict get $origin node]/variadic"
    }
    set tail [lrange $argNodes $fixed end]
    set collected [hir::syntax::callNode $origin [hir::syntax::rootRef $origin list] {*}$tail]
    dict set hir exprs $e variadic [dict create fixed $fixed count [llength $tail]]
    return [concat [lrange $argNodes 0 [expr {$fixed - 1}]] [list $collected]]
}

# 1 if call E's arity was diagnosed by Arguments (a variadic callee given
# fewer than its fixed arguments): hir::flags::ResolveCall then reports no
# second ARITY.
proc hir::variadic::ArityReported {hir e} {
    set iface [hir::flags::InterfaceOf $hir [dict get $hir exprs $e callee]]
    return [expr {$iface ne "" && [dict getdef $iface variadic 0] && ![dict exists $hir exprs $e variadic]}]
}

# Diagnoses the trailing arguments of variadic call E (node NODE) that do not
# satisfy ELEMENT, the element type of its variadic parameter PARAM, given
# the call's argument RANGES: each one at its own spelling, as the argument
# it was written as (hir::range::VerifyCall asks when the collected List
# ARG is not admissible as a whole: a List literal's static type keeps no
# element's range, so a List[Small] is proven element by element). Returns
# 1 if it reported any, 0 when every trailing argument is proven.
proc hir::variadic::DiagnoseElements {hirVar e node arg element param ranges} {
    upvar 1 $hirVar hir
    set fixed [dict get $node variadic fixed]
    set callee [dict get $hir exprs [dict get $node callee] name]
    set reported 0
    set position $fixed
    foreach item [dict get $hir exprs $arg args] {
        incr position
        if {[dict exists $hir poisoned $item]} {
            continue
        }
        set type [hir::typeOf $hir $item]
        set range [dict getdef $ranges $item [hir::range::unknown]]
        if {[hir::range::ProvesValueAcceptedBy $type $range $element]} {
            continue
        }
        hir::Diagnose hir TYPE [format \
            {argument %d of %s cannot be proven to satisfy %s, the element type of its variadic parameter "%s" (argument type: %s%s)%s} \
            $position $callee [hir::types::show $element] $param [hir::semantic::ShowType $hir [hir::range::ShownArgType $type $element]] \
            [hir::range::FactsClause $type $element $range] [hir::range::MismatchClause $type $element]] $item
        set reported 1
    }
    return $reported
}
