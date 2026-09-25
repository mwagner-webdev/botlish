# errorsets.tcl -- error-set legality (EXPLICIT-ERROR-COMPLETIONS.md).
#
# The central rule (spec item 78):
#
#   calleeErrors(call) - handledErrors(call) subseteq enclosingDeclaredErrors
#
# Checked once per function (hir/callables.tcl's own "blocks" driver
# exactly: one independent top-level walk per block, plus one for the
# program root) walking every call/handle reachable from its own body
# without entering a nested block's own body (which gets its own top-level
# entry from this same "blocks" loop). The program root's own declared
# error set is always empty, which is exactly spec item 54's top-level
# closure rule: it falls straight out of this one shared rule, with no
# separate top-level-only check needed.
#
# A `handle` node's own handler values are also checked here, for
# admissibility as the handled call's own normal result type T (spec items
# 11/37: no implicit union widening of a handled-result binding -- a
# handler that completes normally must itself prove a value admissible as
# T, exactly the same subtype-or-proven-range-fact admissibility
# hir/range.tcl's own verifyDeclaredResults already uses for a function's
# declared result).

namespace eval hir::errorsets {}

# Diagnoses every name of CALLEEERRORS not in ADMITTED (a plain Tcl list),
# attributed to expression E.
proc hir::errorsets::CheckAdmitted {hirVar e calleeErrors admitted} {
    upvar 1 $hirVar hir
    foreach name $calleeErrors {
        if {$name ni $admitted} {
            hir::Diagnose hir UNHANDLED-ERROR [format \
                {this call may produce the declared error "%s", which is neither handled here nor admitted by the enclosing function's own "errors" declaration} \
                $name] $e
        }
    }
}

# Walks E (and its children, generically) checking every call reachable
# from it: mirrors hir::callables::WalkExpr and hir::range::
# VerifyCallArguments exactly (a nested block's own body is its own
# region -- it gets its own top-level entry from verify's own "blocks"
# loop below, so this never descends into a closure's body from here).
proc hir::errorsets::WalkExpr {hirVar e errors} {
    upvar 1 $hirVar hir
    set node [dict get $hir exprs $e]
    switch -- [dict get $node kind] {
        const - ref - continue - block - fail {
        }
        bind {
            WalkExpr hir [dict get $node value] $errors
        }
        call {
            CheckAdmitted hir $e [dict get $node calleeErrors] $errors
            WalkExpr hir [dict get $node callee] $errors
            foreach arg [dict get $node args] {
                WalkExpr hir $arg $errors
            }
        }
        if {
            WalkExpr hir [dict get $node condition] $errors
            foreach child [dict get $node thenBody] { WalkExpr hir $child $errors }
            foreach child [dict get $node elseBody] { WalkExpr hir $child $errors }
        }
        loop {
            foreach child [dict get $node body] { WalkExpr hir $child $errors }
        }
        listloop {
            WalkExpr hir [dict get $node iterable] $errors
            foreach child [dict get $node body] { WalkExpr hir $child $errors }
        }
        return - ok - error {
            WalkExpr hir [dict get $node value] $errors
        }
        break {
            set value [dict get $node value]
            if {$value ne ""} {
                WalkExpr hir $value $errors
            }
        }
        handle {
            CheckHandle hir $e $errors
        }
    }
}

# The handled call E: subtracts its own handled names from the callee's
# declared errors and admits what remains against ERRORS (spec items 7/14/
# 78); checks each live handler's own completion type is admissible as the
# call's own normal result type (spec items 11/37); recurses into the
# call's own callee/args and every handler body (each under the SAME
# ERRORS -- a handler body is lexically part of the enclosing function,
# not a new one, spec item 35).
proc hir::errorsets::CheckHandle {hirVar e errors} {
    upvar 1 $hirVar hir
    set node [dict get $hir exprs $e]
    set call [dict get $node call]
    set callNode [dict get $hir exprs $call]
    set handled [dict get $node handlerNames]
    set remaining {}
    foreach name [dict get $callNode calleeErrors] {
        if {$name ni $handled} {
            lappend remaining $name
        }
    }
    CheckAdmitted hir $e $remaining $errors

    set callType [hir::typeOf $hir $call]
    foreach name $handled body [dict get $node handlerBodies] type [dict get $node handlerTypes] {
        if {$type ne "never" && $callType ne "never"} {
            set range [hir::range::analyzeSequence $hir $body]
            if {![hir::range::ProvesValueAcceptedBy $type $range $callType]} {
                hir::Diagnose hir TYPE [format \
                    {handler "on %s" completes with type %s, not admissible as %s (the call's own normal result type)} \
                    $name [hir::types::show $type] [hir::types::show $callType]] $e
            }
        }
        foreach child $body {
            WalkExpr hir $child $errors
        }
    }
    WalkExpr hir [dict get $callNode callee] $errors
    foreach arg [dict get $callNode args] {
        WalkExpr hir $arg $errors
    }
}

proc hir::errorsets::verify {hirVar} {
    upvar 1 $hirVar hir
    set blocks [list program]
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] eq {block}} {
            lappend blocks $e
        }
    }
    foreach block $blocks {
        if {$block eq {program}} {
            set errors {}
            set body [hir::roots $hir]
        } else {
            set errors [dict get $hir exprs $block declaredErrors]
            set body [dict get $hir exprs $block body]
        }
        foreach child $body {
            WalkExpr hir $child $errors
        }
    }
}
