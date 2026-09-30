# errors.tcl -- reporting of malformed IR and invalid programs.
#
# Two classes of failure are reported as Tcl errors, never as language values:
#
#   errorcode {CORE MALFORMED}         the IR is not well-formed
#   errorcode {CORE SEMANTIC <KIND>}   a well-formed but invalid program
#   errorcode {CORE CONTRACT TYPE}     trusted Tcl code (a native) broke its
#                                      declared type contract: an
#                                      implementation bug, not a program error
#
# Semantic kinds:
#   UNBOUND                  unresolved lexical name
#   DUPLICATE                name bound twice in one lexical scope
#   NOT-CALLABLE             call of a non-callable value
#   ARITY                    wrong number of arguments
#   NOT-BOOLEAN              non-Boolean if condition
#   TYPE                     primitive applied to a value of the wrong kind
#   EQUALITY                 == or hash applied to values without defined
#                            equality
#   RANGE                    an index outside the valid range
#   ARITHMETIC               an arithmetic operation with no defined result
#                            (mod by zero)
#   BREAK-OUTSIDE-LOOP       break not lexically inside a loop
#   CONTINUE-OUTSIDE-LOOP    continue not lexically inside a loop
#   RETURN-OUTSIDE-CALLABLE  return not inside a callable invocation
#   UNCAUGHT-ERROR           a propagate-error completion reached the program
#   STRUCT                   a struct value built with fields other than its
#                            declaration's (a named (struct ...) whose field
#                            names differ from the declared ones; HIR rules
#                            this out for a checked program)
#
# A checked program's struct diagnostics are HIR diagnostics (hir/structs.tcl,
# hir/resolve.tcl), reported with these kinds: UNKNOWN-STRUCT, DUPLICATE-FIELD,
# UNKNOWN-FIELD, MISSING-FIELD, NOT-A-STRUCT, UNPROVEN-FIELD (STRUCTS.md,
# "Diagnostics"); a wrongly typed field is a TYPE diagnostic.
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
