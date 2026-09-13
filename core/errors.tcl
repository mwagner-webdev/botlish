# errors.tcl -- reporting of malformed IR and invalid programs.
#
# Two classes of failure are reported as Tcl errors, never as language values:
#
#   errorcode {CORE MALFORMED}         the IR is not well-formed
#   errorcode {CORE SEMANTIC <KIND>}   a well-formed but invalid program
#
# Semantic kinds:
#   UNBOUND                  unresolved lexical name
#   DUPLICATE                name bound twice in one lexical scope
#   NOT-CALLABLE             call of a non-callable value
#   ARITY                    wrong number of arguments
#   NOT-BOOLEAN              non-Boolean if condition
#   TYPE                     primitive applied to a value of the wrong kind
#   EQUALITY                 == applied to values without defined equality
#   BREAK-OUTSIDE-LOOP       break not lexically inside a loop
#   CONTINUE-OUTSIDE-LOOP    continue not lexically inside a loop
#   RETURN-OUTSIDE-CALLABLE  return not inside a callable invocation
#   UNCAUGHT-ERROR           a propagate-error completion reached the program
#
# Application/domain failures are *not* errors in this sense: they are
# ordinary Result values (see value.tcl).

namespace eval core {}

proc core::malformed {message node} {
    throw [list CORE MALFORMED] "malformed IR: $message: $node"
}

proc core::semanticError {kind message} {
    throw [list CORE SEMANTIC $kind] $message
}
