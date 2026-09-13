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

# Kind and tag predicates are type tests (-tests-type): each returns exactly
# whether its argument is a value of the type, and refines it accordingly.
foreach {name kind} {integer? int string? str list? list} {
    core::native::register $name -arity 1  -impl [list core::predicates::KindIs $kind] -tests-type $kind
}
unset name kind

# The tag of a Result is a structural property: validator types.
core::type::register Result.ok    -base result -validator {core::predicates::HasTag ok}
core::type::register Result.error -base result -validator {core::predicates::HasTag error}

proc core::predicates::HasTag {tag v} {
    return [expr {[core::value::resultTag $v] eq $tag}]
}

core::native::register ok? -arity 1  -impl {core::predicates::ResultIs ok} -tests-type Result.ok
core::native::register error? -arity 1  -impl {core::predicates::ResultIs error} -tests-type Result.error

core::native::register result-value -arity 1 -impl core::predicates::resultValue \
    -param-types result
core::native::register result-error -arity 1 -impl core::predicates::resultError \
    -param-types result
