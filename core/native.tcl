# native.tcl -- registry of native (Tcl-backed) callables.
#
# A native callable value is {native NAME}; everything else about it lives
# in the registry:
#
#   name            source-level name
#   impl            Tcl command prefix; called with the argument values,
#                   must return a runtime value
#   arity           exact argument count, or * for any
#   refinesTrue     facts proven when the callable returns true
#   refinesFalse    facts proven when the callable returns false
#   paramTypes      value kinds the implementation *requires* of each
#                   argument (any = no requirement); a call that returns
#                   proves its arguments had these kinds. "" = unknown.
#   resultType      value kind of every result, or any
#
# Refinement rules are flat lists of ARG-INDEX FACT pairs, e.g. {0 Int}
# ("argument 0 satisfies Int"). The evaluator never special-cases a native by
# name; it only consults this metadata (see refine.tcl).

namespace eval core::native {
    variable registry [dict create]
}

proc core::native::register {name args} {
    variable registry
    if {$name eq ""} {
        error "core::native::register: empty name"
    }
    if {[dict exists $registry $name]} {
        error "core::native::register: native \"$name\" is already registered"
    }
    if {[llength $args] % 2} {
        error "core::native::register: options must be -option value pairs"
    }
    set options [dict create -impl "" -arity "" -refines-true {} -refines-false {} \
        -param-types "" -result-type any]
    foreach {option value} $args {
        if {![dict exists $options $option]} {
            error "core::native::register: unknown option \"$option\""
        }
        dict set options $option $value
    }
    set impl [dict get $options -impl]
    if {$impl eq ""} {
        error "core::native::register: -impl is required for \"$name\""
    }
    set arity [dict get $options -arity]
    if {$arity ne "*" && !([string is digit -strict $arity])} {
        error "core::native::register: -arity must be a non-negative integer or *"
    }
    foreach option {-refines-true -refines-false} {
        set rules [dict get $options $option]
        if {[llength $rules] % 2} {
            error "core::native::register: $option must be ARG-INDEX FACT pairs"
        }
        foreach {index fact} $rules {
            if {![string is digit -strict $index] || $fact eq ""} {
                error "core::native::register: bad $option rule \"$index $fact\""
            }
        }
    }
    set kinds {int str bool unit list result block native any}
    foreach type [concat [dict get $options -param-types] [list [dict get $options -result-type]]] {
        if {$type ni $kinds} {
            error "core::native::register: unknown type \"$type\" (known: $kinds)"
        }
    }
    dict set registry $name [dict create \
        name $name \
        impl $impl \
        arity $arity \
        refinesTrue [dict get $options -refines-true] \
        refinesFalse [dict get $options -refines-false] \
        paramTypes [dict get $options -param-types] \
        resultType [dict get $options -result-type]]
    return [core::value::native $name]
}

proc core::native::names {} {
    variable registry
    return [dict keys $registry]
}

proc core::native::metadata {name} {
    variable registry
    if {![dict exists $registry $name]} {
        error "core::native: no native named \"$name\""
    }
    return [dict get $registry $name]
}

# OUTCOME is host 1 (predicate returned true) or 0 (returned false).
proc core::native::refinementRules {name outcome} {
    set meta [metadata $name]
    return [dict get $meta [expr {$outcome ? "refinesTrue" : "refinesFalse"}]]
}

proc core::native::invoke {nativeValue argValues} {
    set name [core::value::nativeName $nativeValue]
    set meta [metadata $name]
    set arity [dict get $meta arity]
    if {$arity ne "*" && [llength $argValues] != $arity} {
        core::semanticError ARITY \
            "$name expects $arity argument(s), got [llength $argValues]"
    }
    set result [{*}[dict get $meta impl] {*}$argValues]
    return [core::completion::normal $result]
}
