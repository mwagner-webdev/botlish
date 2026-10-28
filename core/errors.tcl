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
#   NATIVE-ONLY              an operation only the native backend performs
#                            (std::linux::abi::x86_64::syscall's raw kernel transition,
#                            core/linuxabi.tcl) was called on a Tcl backend,
#                            which deliberately does not imitate it
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

# Raises the compiler diagnostics DIAGNOSTICS -- a non-empty list of
# {errorcode CODE message TEXT ?shown SHOWN?} dicts, in the order they are
# reported -- as one error (DIAGNOSTIC-RECOVERY.md): the first one's error
# code and text, then a line "TEXT (SHOWN)" for each further one (SHOWN: how
# its code is shown, CODE itself by default), and the list itself as the
# return option -diagnostics, for a caller that presents them one by one
# (main.tcl). A single diagnostic raises exactly what core::semanticError (or
# the parser's or the loader's own error) would.
#
# The front end's producers also give each entry its location as data
# (COMPILER-SERVICE-MILESTONE-1.md, "Structured diagnostics"), beside the
# text, so a consumer never parses it out of TEXT:
#
#   summary   the message without its "FILE:LINE:COLUMN: " prefix
#   location  the source span TEXT names, {file PATH start S end E line L
#             column C endLine L2 endColumn C2} (offsets and columns count
#             Unicode scalar values of the normalized text, lines and columns
#             1-based, END exclusive), or "" when the diagnostic has none
#   related   the further spans it names, in order (a list of such spans)
#   notes     optional: further locations with a text of their own, for a
#             reader (where a method-style call's candidates are declared):
#             {message TEXT summary SUMMARY location SPAN} each, TEXT
#             located as the entry's own message is; never part of the
#             entry's message, and no part of its identity
#   record    the producer's own richer record, when it has one (a HIR
#             diagnostic, a warning, a syntax diagnostic)
proc core::raiseDiagnostics {diagnostics} {
    set first [lindex $diagnostics 0]
    set message [dict get $first message]
    foreach diagnostic [lrange $diagnostics 1 end] {
        append message "\n[dict get $diagnostic message] ([core::ShownCode $diagnostic])"
    }
    return -code error -errorcode [dict get $first errorcode] -diagnostics $diagnostics $message
}

# How the code of one entry of core::raiseDiagnostics is shown.
proc core::ShownCode {diagnostic} {
    return [dict getdef $diagnostic shown [dict get $diagnostic errorcode]]
}
