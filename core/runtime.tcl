# runtime.tcl -- semantic operations shared by every backend.
#
# The interpreter (evaluator.tcl) and the compiler (compiler/) must agree on
# these rules; keeping them in one place makes that agreement structural.

namespace eval core::runtime {}

# The outcome (host 1/0) of an if condition value. Only Booleans qualify.
proc core::runtime::conditionOutcome {test} {
    if {[core::value::kind $test] ne "bool"} {
        core::semanticError NOT-BOOLEAN \
            "if condition must be a Boolean, got [core::value::show $test]"
    }
    return [core::value::isTrue $test]
}

# Calls CALLEE with ARG-VALUES from compiled code. Returns the value; the
# call boundary has already consumed or rejected every abrupt completion
# except propagate-error, which is re-signalled as compiled code's own Tcl
# completion code 5 (core::completion::fromTclCode) -- exactly what a
# direct call of a compiled block that `fail`s already returns, so an
# enclosing compiled `handle` (or the caller's own caller) sees it the same
# way. Reachable since STRUCTURAL-FUNCTION-TYPES.md: a callable with a
# declared error set may now be called through a structural function type,
# whose calls have no exact target and so are compiled as this generic
# call.
proc core::runtime::callValue {callee argValues} {
    set completion [core::callable::invoke $callee $argValues]
    if {[core::completion::isNormal $completion]} {
        return [core::completion::payload $completion]
    }
    if {[core::completion::kind $completion] eq "propagate-error"} {
        return -code 5 [core::completion::payload $completion]
    }
    error "core::runtime: compiled code cannot yet propagate [core::completion::show $completion]"
}

# The struct value with declaration head HEAD ({} anonymous, {ID FIELD...}
# named) whose fields are the written NAMES with the VALUES (same order):
# the one place both backends agree on a struct's runtime shape (STRUCTS.md).
# An anonymous struct's shape is its field set in canonical (sorted) order,
# so two literals of one field set written in different orders have one
# shape; a named struct's is its declaration's identity and slot order, and
# the written names must be exactly that field set (static in HIR; a semantic
# error here). Values were all evaluated already: nothing partially built is
# ever visible.
proc core::runtime::structNew {head names values} {
    set byName [dict create]
    foreach name $names value $values {
        dict set byName $name $value
    }
    if {$head eq ""} {
        set fields [lsort $names]
        set shape [linsert $fields 0 ""]
    } else {
        set fields [lrange $head 1 end]
        if {[lsort $fields] ne [lsort $names]} {
            core::semanticError STRUCT \
                "struct [lindex $head 0] initializer has fields {$names}, but its declaration has {$fields}"
        }
        set shape $head
    }
    return [core::value::structOf $shape [lmap field $fields {dict get $byName $field}]]
}

# Field NAME of the struct value RECEIVER. A field projection is resolved
# statically (HIR proves the receiver is a struct with that field), so the
# two failures below are an invalid program's, never an event a correct
# program can reach; the name is found in the value's own shape only because
# a reference backend keeps the shape with the value.
proc core::runtime::project {receiver name} {
    if {[core::value::kind $receiver] ne "struct"} {
        core::semanticError TYPE \
            "field projection \".$name\": expected a struct, got [core::value::show $receiver]"
    }
    set slot [lsearch -exact [core::value::structFields $receiver] $name]
    if {$slot < 0} {
        core::semanticError TYPE \
            "field projection \".$name\": [core::value::show $receiver] has no field \"$name\""
    }
    return [lindex [core::value::structValues $receiver] $slot]
}
