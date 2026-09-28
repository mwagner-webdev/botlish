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
