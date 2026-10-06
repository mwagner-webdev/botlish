# native::prepareHir -- the one place native compilation touches HIR before
# lowering.
#
# It makes a -strict 0 HIR safe to compile: a declared parameter type the
# program's own call cannot prove (`violatedDeclared`, recorded by
# hir::range::VerifyCall) must not be assumed by the callee's native code, so
# the declaration is dropped and the HIR re-checked -- the callee then guards
# what its own body needs and the call fails at run time as it does in the
# interpreter (this is hir::check's recovery for inferred contracts, applied
# to declared ones for native only; the relift used to hide the case because
# core IR has no declared types). A strict HIR never has such a violation.
#
# Input: program-mode HIR as a front end built it (analyzed). Output: the same
# HIR when nothing needs preparing (no work, no re-analysis); otherwise HIR
# with the contracts recovered, analyzed again. It is idempotent, keeps
# source locations, declared contracts, module identities and lexical
# shadowing, and is shared by every native entry point (native::lowered
# calls it).
#
# It used to also attach native implementations: a root native carrying a
# -module-fn (an ordinary Botlish module function as its native
# implementation) or a -native-body (a core-IR literal) had its calls
# redirected here. Both existed only for lib/web.tcl's Tcl-registered String
# refinements, which REFINEMENT-VALUES.md replaced with source declarations
# (`refined type`, `proves`) in lib/web.bot: no native needs either any more,
# and both mechanisms are gone.
proc native::prepareHir {hir} {
    return [RecoverDeclaredContracts $hir]
}

# native::prepareHir's second step: see its header.
proc native::RecoverDeclaredContracts {hir} {
    if {![dict exists $hir violatedDeclared]} {
        return $hir
    }
    set demote [dict keys [dict get $hir violatedDeclared]]
    set diagnostics [dict get $hir diagnostics]
    dict unset hir violatedDeclared
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "block" || ![dict exists $node declaredParamTypes]} continue
        set declared [dict get $node declaredParamTypes]
        set changed 0
        set index 0
        foreach b [dict get $node params] {
            if {$b in $demote && [lindex $declared $index] ne {}} {
                lset declared $index {}
                set changed 1
            }
            incr index
        }
        if {$changed} { dict set hir exprs $e declaredParamTypes $declared }
    }
    hir::check hir
    # The violations stay diagnosed (a -strict 0 HIR keeps them); the re-check
    # sees no declared type to break.
    dict set hir diagnostics $diagnostics
    dict unset hir violatedDeclared
    return $hir
}
