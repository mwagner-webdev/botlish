# types.tcl -- the static type language of the compiler.
#
# A static type describes every value an expression can produce:
#
#   int str bool unit list result   values of that kind
#   native block                    some callable of that kind
#   {native NAME}                   exactly the native callable NAME
#   {block PROC ARITY RESULT}       a Block whose body is compiled proc PROC,
#                                   taking ARITY arguments; RESULT types what
#                                   a call returns
#   any                             no static knowledge
#   never                           no value: evaluation never completes
#                                   normally (return, break, error, ...)
#
# Types only ever *describe* runtime values; they never change what a program
# means. The compiler uses them to choose faster code whose behavior is
# identical, and falls back to the generic code whenever a type is unknown.
#
# Where types come from:
#   * literals and constructors (const, ok, error-value, list)
#   * the root environment's constants, when the program is compiled against it
#   * native signatures in the registry (-param-types / -result-type)
#   * immutability: a binding has the type of the expression it was bound to
#   * refinement facts of predicates, inside the branch they hold in
#   * flow facts: once a native requiring int returned, its argument was an
#     int, and since bindings are immutable it stays one

namespace eval core::types {
    variable factTypes [dict create \
        Int int Str str List list Result.ok result Result.error result]
}

# Least upper bound: the most precise type describing values of A or B.
proc core::types::lub {a b} {
    if {$a eq "never"} { return $b }
    if {$b eq "never"} { return $a }
    if {$a eq $b} { return $a }
    if {[lindex $a 0] eq "block" && [lindex $b 0] eq "block"
            && [lrange $a 1 2] eq [lrange $b 1 2]} {
        return [list block [lindex $a 1] [lindex $a 2] [lub [lindex $a 3] [lindex $b 3]]]
    }
    return any
}

# Narrows CURRENT by a proven FACT type.
proc core::types::narrow {current fact} {
    if {$fact eq "any"} {
        return $current
    }
    if {$current in {any never} || [kindOf $current] ne $fact} {
        # A contradicting fact can only hold on unreachable paths.
        return [expr {$current eq "never" ? "never" : $fact}]
    }
    return $current
}

# The runtime value kind every value of TYPE has, or "" if not fixed.
proc core::types::kindOf {type} {
    switch -- [lindex $type 0] {
        native - block { return [lindex $type 0] }
        any - never    { return "" }
        default        { return $type }
    }
}

# The static type of the runtime value V.
proc core::types::ofValue {v} {
    switch -- [core::value::kind $v] {
        native  { return [list native [core::value::nativeName $v]] }
        default { return [core::value::kind $v] }
    }
}

# The type proven by refinement fact FACT (see core/predicates.tcl), or any.
proc core::types::ofFact {fact} {
    variable factTypes
    if {[dict exists $factTypes $fact]} {
        return [dict get $factTypes $fact]
    }
    return any
}

# Signature of native NAME: {PARAM-TYPES RESULT-TYPE}; PARAM-TYPES may be "".
proc core::types::nativeSignature {name} {
    set meta [core::native::metadata $name]
    return [list [dict get $meta paramTypes] [dict get $meta resultType]]
}

proc core::types::show {type} {
    if {[llength $type] == 1} {
        return $type
    }
    switch -- [lindex $type 0] {
        native  { return "native [lindex $type 1]" }
        block   { return "block/[lindex $type 2] -> [show [lindex $type 3]]" }
        default { return $type }
    }
}
