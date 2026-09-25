# errorsets.tcl -- error-set legality (EXPLICIT-ERROR-COMPLETIONS.md,
# STATIC-COMPLETION-PROOFS.md).
#
# The central rule, call-specific (STATIC-COMPLETION-PROOFS.md item 45):
#
#   effectiveErrors(call) - handledErrors(call) subseteq enclosingDeclaredErrors
#
# where effectiveErrors(call) is never larger than the callee's own declared
# signature (item 46: proof only ever removes errors a call site's own
# argument/branch facts prove impossible, it never adds one -- a reachable
# undeclared `fail` inside a function's own body remains a separate,
# unconditional rejection, checked by hir/resolve.tcl at `fail` resolution
# time, unchanged by this file).
#
# The actual walk -- Range-fact tracking, branch feasibility, per-call
# effective-error-set computation, and the KNOWN-ERROR/UNHANDLED-ERROR/TYPE
# diagnostics themselves -- lives in hir/completions.tcl
# (hir::completions::checkBlock), which this file's own "blocks" driver
# calls once per function body (plus once for the program root, whose own
# declared error set is always empty -- spec item 54's top-level closure
# rule, falling straight out of this one shared rule with no separate
# top-level-only check needed, unchanged from before this milestone).

namespace eval hir::errorsets {}

proc hir::errorsets::verify {hirVar} {
    upvar 1 $hirVar hir
    hir::completions::resetCache
    set blocks [list program]
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] eq {block}} {
            lappend blocks $e
        }
    }
    foreach block $blocks {
        set errors [expr {$block eq {program} ? {} : [dict get $hir exprs $block declaredErrors]}]
        hir::completions::checkBlock hir $block $errors
    }
}
