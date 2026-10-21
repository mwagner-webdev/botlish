# listlength.tcl -- the explicit validator of the List length refinement
# (LIST-CARDINALITY-REFINEMENTS.md; core/listlength.tcl).
#
#   hir::listlength::verify HIRVAR     its imprints and arguments
#   hir::listlength::Elaborate HIRVAR  its length written into the call
#
# `list::with_length[T](xs)` is an intrinsic imprinted with the refined List
# type T it mints (hir/imprint.tcl): the call's static type is T, a
# List[E]{length: N}, and it completes only when xs has exactly N elements
# (else the declared LengthMismatch). Like decimal_rounded::round[T]
# (DECIMAL-ROUNDED-MILESTONE-1.md), the imprint's fact is elaborated into
# the call before any backend runs -- list#with_length(xs, N) -- so no
# backend reads a type, and the run-time operation returns xs itself: the
# check mints the refinement without a copy.
#
# What verify holds the call to:
#   * the imprint is a refinement of List (a List[E]{length: N}): the check
#     has a length to check (TYPE otherwise);
#   * the argument is admissible for the imprint's base (List[E]): the check
#     proves the length, never the elements, so a List of another element
#     type is rejected as it would be anywhere a List[E] is required (TYPE).

namespace eval hir::listlength {
    # The validator and its elaborated run-time operation.
    variable native list::with_length
    variable checked list#with_length
}

proc hir::listlength::verify {hirVar} {
    upvar 1 $hirVar hir
    variable native
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "call" || ![dict get $node reachable]
                || [hir::decimal::CalledNative $hir $e] ne $native || [hir::imprint::Unbound $hir $e]} {
            continue
        }
        set t [hir::typeOf $hir $e]
        if {$t in {never any}} {
            continue
        }
        if {[hir::types::LengthOf $t] eq "" || ![hir::types::IsRefinedApplied $t]} {
            hir::Diagnose hir TYPE [format \
                {%s checks a List against the exact length its imprint states, so it is imprinted with a List[T]{length: N} type (%s[List[int]{length: 4}](xs)), not %s} \
                $native $native [hir::types::show $t]] $e
            continue
        }
        set arg [lindex [dict get $node args] 0]
        if {$arg eq "" || [dict exists $hir poisoned $arg]} {
            continue
        }
        set argType [hir::typeOf $hir $arg]
        set base [hir::types::Unrefined $t]
        if {$argType ne "never" && ![hir::range::ProvesValueAcceptedBy $argType [hir::range::unknown] $base]} {
            hir::Diagnose hir TYPE [format \
                {the argument of %s cannot be proven to satisfy %s, the base of its imprint %s (argument type: %s): the check proves a List's length, never its elements} \
                $native [hir::types::show $base] [hir::types::show $t] \
                [hir::semantic::ShowType $hir [hir::range::ShownArgType $argType $base]]] $arg
        }
    }
}

# Writes the length every list::with_length[T] call checks into the call
# (the file header): it becomes list#with_length(xs, N), N the length T
# states. A call whose imprint states none (verify reported it) keeps its
# check form, which refuses to run.
proc hir::listlength::Elaborate {hirVar} {
    upvar 1 $hirVar hir
    variable native
    variable checked
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "call" || [hir::decimal::CalledNative $hir $e] ne $native} {
            continue
        }
        set n [hir::types::LengthOf [hir::typeOf $hir $e]]
        if {$n eq ""} {
            continue
        }
        set root [dict get $hir scopes [dict get $hir top] parent]
        hir::resolve::RootBinding hir $root $checked
        hir::mutvec::Retarget hir $e $checked
        if {[dict exists $hir exprs $e imprint]} {
            # (The run-time operation is not imprinted: the length is an
            # argument now.)
            dict unset hir exprs $e imprint
        }
        dict set hir exprs $e args [concat [dict get $node args] [list [hir::decimal::NewInt hir $n $e]]]
    }
}
