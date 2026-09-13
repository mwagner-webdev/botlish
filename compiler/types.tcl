# types.tcl -- the compiler's static types.
#
# Static types are the semantic types of core/type.tcl, which define what it
# means for a value to have a type, extended with forms that only the
# compiler needs:
#
#   (any semantic type)             int, str, {refined str {Emailish}}, any, ...
#   {native NAME}                   exactly the native callable NAME
#   {block PROC ARITY RESULT}       a Block whose body is compiled proc PROC,
#                                   taking ARITY arguments; RESULT types what
#                                   a call returns
#   never                           no value: evaluation never completes
#                                   normally (return, break, error, ...)
#
# The procedures here handle the compiler-only forms and delegate everything
# else to core::type, so a refinement or named type means the same thing to
# the compiler as to the interpreter.
#
# Types only ever *describe* runtime values; they never change what a program
# means. Invariant: if an operand has static type T (a semantic type), its
# runtime value v satisfies core::type::acceptsValue T v.
#
# Where types come from:
#   * literals and constructors (const, ok, error-value, list)
#   * the root environment's constants, when the program is compiled against it
#   * native signatures in the registry (-param-types / -result-type)
#   * immutability: a binding has the type of the expression it was bound to
#   * refinement metadata of predicates (types), inside the branch they hold in
#   * flow facts: once a native requiring a type returned, its argument had
#     that type, and since bindings are immutable it keeps it

namespace eval core::types {}

proc core::types::IsCompilerOnly {type} {
    return [expr {$type eq "never"
                  || ([llength $type] > 1 && [lindex $type 0] in {native block})}]
}

# TYPE in canonical form (semantic types are normalized by core::type).
proc core::types::Canonical {type} {
    if {[IsCompilerOnly $type]} {
        return $type
    }
    return [core::type::normalize $type]
}

# Least upper bound: the most precise type describing values of A or B.
proc core::types::lub {a b} {
    if {$a eq "never"} { return [Canonical $b] }
    if {$b eq "never"} { return [Canonical $a] }
    if {$a eq $b} { return [Canonical $a] }
    if {[lindex $a 0] eq "block" && [lindex $b 0] eq "block"
            && [llength $a] == 4 && [llength $b] == 4
            && [lrange $a 1 2] eq [lrange $b 1 2]} {
        return [list block [lindex $a 1] [lindex $a 2] [lub [lindex $a 3] [lindex $b 3]]]
    }
    if {[IsCompilerOnly $a] || [IsCompilerOnly $b]} {
        set kind [kindOf $a]
        return [expr {$kind ne "" && $kind eq [kindOf $b] ? $kind : "any"}]
    }
    return [core::type::lub $a $b]
}

# Narrows CURRENT by a proven FACT (a semantic type).
proc core::types::narrow {current fact} {
    if {$fact eq "any" || $current eq "never"} {
        return $current
    }
    if {[IsCompilerOnly $current]} {
        # A precise callable type already implies a bare kind fact.
        if {$fact eq [kindOf $current]} {
            return $current
        }
        return $fact
    }
    return [core::type::narrow $current $fact]
}

# The runtime value kind every value of TYPE has, or "" if not fixed.
proc core::types::kindOf {type} {
    if {$type eq "never"} {
        return ""
    }
    if {[IsCompilerOnly $type]} {
        return [lindex $type 0]
    }
    return [core::type::base $type]
}

# The static type of the runtime value V.
proc core::types::ofValue {v} {
    if {[core::value::kind $v] eq "native"} {
        return [list native [core::value::nativeName $v]]
    }
    return [core::type::ofValue $v]
}

# Signature of native NAME: {PARAM-TYPES RESULT-TYPE}; PARAM-TYPES may be "".
proc core::types::nativeSignature {name} {
    set meta [core::native::metadata $name]
    return [list [dict get $meta paramTypes] [dict get $meta resultType]]
}

proc core::types::show {type} {
    if {$type eq "never"} {
        return never
    }
    if {[IsCompilerOnly $type]} {
        switch -- [lindex $type 0] {
            native { return "native [lindex $type 1]" }
            block  { return "block/[lindex $type 2] -> [show [lindex $type 3]]" }
        }
    }
    return [core::type::show $type]
}
