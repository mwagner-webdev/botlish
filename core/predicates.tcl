# predicates.tcl -- native predicates and Result helpers.
#
# Predicates are ordinary callables (Any -> Bool). Their refinement metadata
# is registered alongside them and is the only thing that makes `if` branches
# learn facts; nothing in the evaluator refers to these names.

namespace eval core::predicates {}

proc core::predicates::KindIs {kind v} {
    return [core::value::bool [expr {[core::value::kind $v] eq $kind}]]
}

proc core::predicates::ResultIs {tag v} {
    return [core::value::bool [expr {[core::value::kind $v] eq "result"
                                     && [core::value::resultTag $v] eq $tag}]]
}

proc core::predicates::resultValue {v} {
    core::value::expect result $v result-value
    if {[core::value::resultTag $v] ne "ok"} {
        core::semanticError TYPE \
            "result-value: expected an ok Result, got [core::value::show $v]"
    }
    return [core::value::resultPayload $v]
}

proc core::predicates::resultError {v} {
    core::value::expect result $v result-error
    if {[core::value::resultTag $v] ne "error"} {
        core::semanticError TYPE \
            "result-error: expected an error Result, got [core::value::show $v]"
    }
    return [core::value::resultPayload $v]
}

core::native::register integer? -arity 1 \
    -impl {core::predicates::KindIs int} -refines-true {0 Int}
core::native::register string? -arity 1 \
    -impl {core::predicates::KindIs str} -refines-true {0 Str}
core::native::register list? -arity 1 \
    -impl {core::predicates::KindIs list} -refines-true {0 List}

core::native::register ok? -arity 1 \
    -impl {core::predicates::ResultIs ok} -refines-true {0 Result.ok}
core::native::register error? -arity 1 \
    -impl {core::predicates::ResultIs error} -refines-true {0 Result.error}

core::native::register result-value -arity 1 -impl core::predicates::resultValue
core::native::register result-error -arity 1 -impl core::predicates::resultError
