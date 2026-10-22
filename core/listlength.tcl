# listlength.tcl -- the explicit validator of the List length refinement
# (LIST-CARDINALITY-REFINEMENTS.md).
#
#   std::list::with_length[T](xs)  xs itself -- the same List value, never a
#                                  copy -- when it has exactly the length the
#                                  imprinted T (a List[E]{length: N}) states;
#                                  else the declared builtin error
#                                  LengthMismatch. Its static type is T.
#
# It is the run-time way to mint the refinement, beside the static ones (a
# literal, a declared contract, a guard `std::list::length(xs) == N`): never
# implicit, written where the program accepts the failure. The imprint is
# elaborated before any backend runs (hir/listlength.tcl's Elaborate) into
#
#   list#with_length(xs, N)    the check at the length N, an Int argument
#
# as std::decimal_rounded::round[T] is into decimal_rounded#round: no backend reads
# a type. The check form refuses to run unelaborated.
#
# LengthMismatch is declared here, after core/decimal.tcl's
# UnrepresentableDecimal (core/core.tcl's load order), so that it is builtin
# error 10 and every existing builtin error keeps its id (core/native.tcl's
# declaration-order comment; native/src/runtime/error.rs's ERR_* ids).

namespace eval core::listlength {}

core::native::declareError LengthMismatch

proc core::listlength::Unelaborated {name args} {
    core::semanticError TYPE "$name: a List length check reached run time without the length its imprint states (the compiler writes it into the call)"
}

# list#with_length(L, N): L when it has exactly N elements, else
# LengthMismatch.
proc core::listlength::withLength {l n} {
    set items [core::value::items [core::value::expect list $l std::list::with_length]]
    set want [core::value::intOf [core::value::expect int $n std::list::with_length]]
    if {[llength $items] != $want} {
        core::native::failDeclared LengthMismatch \
            "std::list::with_length: the List has [llength $items] element(s), not $want"
    }
    return $l
}

core::native::register std::list::with_length -arity 1 \
    -impl [list core::listlength::Unelaborated std::list::with_length] \
    -param-types {list} -result-type list -errors LengthMismatch -context-free 1 \
    -ownership {move} -imprint {vars {T} params {list} result {imprint T}}
core::native::register list#with_length -arity 2 -impl core::listlength::withLength \
    -param-types {list int} -result-type list -errors LengthMismatch -context-free 1 \
    -result-shape {same 0} -ownership {move observe}
