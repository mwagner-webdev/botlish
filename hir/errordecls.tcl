# errordecls.tcl -- source-defined named error declarations.
#
#   error BelowRange
#   error AboveRange
#
# (surface/parser.tcl's ErrorDecl grammar; surface/lower.tcl turns each into
# a plain DECL dict {name .. nameSpan ..}, never an hir/syntax.tcl node: an
# error declaration has no runtime meaning, exactly like a `type`
# declaration -- hir/sourcetypes.tcl.) EXPLICIT-ERROR-COMPLETIONS.md: two
# declared errors are different semantic identities even if their names
# happen to resemble each other (spec item 6). This file keeps that
# identity mechanism exactly as simple as source-defined *type* identity
# already is: NAME is the identity, valid and unique across one whole
# compiled program (every module section plus the top level), never
# compared by message text. Unlike a source type, no other part of the
# system (no runtime registry, no native registration) ever needs to look
# an error up outside of resolving *this* program's own HIR, so -- unlike
# hir::sourcetypes.tcl's `generation`/Reset machinery, which undoes a
# genuinely process-global core::type/core::native registration -- apply
# needs no "undo the previous batch" step: `current` is simply overwritten
# each time a program brings its own (non-empty) declarations, and a call
# with no declarations of its own (every internal re-hir::build of an
# already-resolved program: the Tcl compiler backend's own GenerateUnit,
# hir/specialize.tcl, ...) leaves the previous batch in place, exactly
# mirroring hir::sourcetypes::apply's own empty-DECLS rule and for the
# identical reason (that internal rebuild's own `fail`/`handle` nodes still
# need the original program's error names to resolve against).
#
# Same single-process, non-concurrent-compilation caveat as
# hir::sourcetypes.tcl's "Compilation isolation": `current` is one Tcl
# namespace variable, not scoped to a particular HIR object.

namespace eval hir::errordecls {
    # The ordered list of names the most recent non-empty `apply` call
    # registered (HIR's own `errorDecls` field mirrors this).
    variable current {}
}

proc hir::errordecls::Fail {span message} {
    if {$span eq ""} {
        core::semanticError UNDECLARED-ERROR $message
    }
    core::semanticError UNDECLARED-ERROR \
        "[dict get $span file]:[dict get $span line]:[dict get $span column]: $message"
}

# Validates DECLS (surface/lower.tcl's ErrorDeclOf dicts -- one per `error
# NAME` declaration found, across every module section a program loads plus
# its own top level, see surface/modules.tcl), returning the ordered list
# of declared names. Duplicate names, even across module sections, are
# rejected: exactly hir::sourcetypes.tcl's own single-flat-namespace rule
# for source-defined types.
proc hir::errordecls::apply {decls} {
    variable current
    if {$decls eq {}} {
        return $current
    }
    set seen [dict create]
    set order {}
    foreach decl $decls {
        set name [dict get $decl name]
        if {[dict exists $seen $name]} {
            Fail [dict get $decl nameSpan] "error \"$name\" is already declared"
        }
        dict set seen $name 1
        lappend order $name
    }
    set current $order
    return $order
}

# 1 if NAME is a declared error identity of the program currently being
# built (the most recent non-empty `apply` call).
proc hir::errordecls::isDeclared {name} {
    variable current
    return [expr {$name in $current}]
}
