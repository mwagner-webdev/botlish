# hygiene.tcl -- keeping root and module references faithful through
# lowering.
#
# A root reference (hir::syntax::rootRef) denotes a root binding (a native,
# true, false or unit) no matter which local bindings share its name: a
# frontend uses it for names it introduces itself, such as the `list` a list
# literal calls. Core IR has only lexical `ref`, so if the reference's name
# is shadowed where it occurs, lowering it to (ref NAME) would find the local
# binding instead.
#
# Nothing in core IR is needed to express this: spelling is not identity, so
# the shadowing binding is renamed. Every such binding gets a fresh name
# NAME#N that no binding or reference in the program uses (source can never
# spell #), in the binding, its scope's names and every bind and ref of it.
# The binding keeps its original spelling in `spelling`. Afterwards a lexical
# lookup of every root reference's name finds its root binding, so lowered
# core IR, the compiler's frames and HIR text all agree with the HIR.
#
# Diagnostics are computed before renaming and keep the source spelling.
#
# The same problem, in reverse, applies to a module's own definitions
# (surface/modules.tcl): hir::resolve resolves them in a private scope, so
# a reference from another file (already spelled "mod::name") and a bare,
# same-module reference to a sibling definition (spelled just "name", as
# ordinary same-file code always is) can resolve to the very same binding
# under two different spellings. qualifyModules (below) renames every such
# binding to its one qualified spelling, "mod::name", everywhere -- the
# same fresh-name machinery Rename uses, minus the #N search (a qualified
# spelling can never collide: no ordinary identifier can spell "::").

namespace eval hir::hygiene {}

# Renames bindings that shadow root references (recorded by resolution in
# HIR's rootRefs); removes rootRefs. Then (qualifyModules) renames every
# module's own top-level definitions to their qualified spelling.
proc hir::hygiene::apply {hirVar} {
    upvar 1 $hirVar hir
    if {[dict exists $hir rootRefs]} {
        foreach e [dict get $hir rootRefs] {
            set name [dict get $hir exprs $e name]
            set root [dict get $hir exprs $e binding]
            while 1 {
                set found [hir::lookup $hir [dict get $hir exprs $e scope] $name]
                if {$found eq $root || $found eq ""} {
                    break
                }
                Rename hir $found
            }
        }
        dict unset hir rootRefs
    }
    qualifyModules hir
}

proc hir::hygiene::Rename {hirVar b} {
    upvar 1 $hirVar hir
    set old [dict get $hir bindings $b name]
    set used [dict create]
    dict for {id binding} [dict get $hir bindings] {
        dict set used [dict get $binding name] 1
    }
    dict for {id node} [dict get $hir exprs] {
        if {[dict exists $node name]} {
            dict set used [dict get $node name] 1
        }
    }
    set n 1
    while {[dict exists $used $old#$n]} {
        incr n
    }
    RenameTo hir $b $old#$n 1
}

# Renames every binding declared directly in a module's own section scope
# (hir::resolve's `modules` table, populated by hir::resolve::program's
# ProgramSection as each namespace's own section -- surface/modules.tcl --
# is resolved) to its qualified spelling, "NAMESPACE::NAME", and every ref/
# bind of it: both the qualified references other files already spell
# that way (hir::resolve::ResolveQualifiedRef) and the module's own
# internal, as-written *bare* references to its own sibling definitions
# (ordinary same-module recursion, including mutual recursion -- entirely
# unaffected by being loaded as a module: hir::resolve resolved it in the
# module's own private scope exactly as it would in a single ordinary
# file, before this pass ever renames anything).
#
# This exists for the same reason Rename (above) does: hir::lower's core
# IR is purely name/lexical-scope based, like the rest of this engine (the
# interpreter, the Tcl compiler), with no notion of HIR's own BindingId
# identity -- so two different spellings of what HIR resolved to be the
# very same binding (an internal bare "odd" and an external qualified
# "parity::odd") must become the very same name before lowering, or
# lowered core IR would silently stop meaning what HIR resolved. Unlike
# Rename, no #N collision search is needed: the qualified spelling can
# never collide with anything (no ordinary identifier can spell "::").
proc hir::hygiene::qualifyModules {hirVar} {
    upvar 1 $hirVar hir
    if {![dict exists $hir modules]} {
        return
    }
    dict for {ns bodyScope} [dict get $hir modules] {
        foreach b [dict get $hir scopes $bodyScope bindings] {
            RenameTo hir $b "${ns}::[dict get $hir bindings $b name]"
        }
    }
}

# Renames binding B to NEW everywhere: its own record, its declaring
# scope's `names` entry, and every ref/bind expression of it. With
# RECORDSPELLING 1 (Rename's own hygiene-#N renames: a pure lowering-
# collision workaround with no meaning of its own), the binding's original
# name is kept in `spelling`, which diagnostics and native symbol names
# (hir::aot::BindingName) prefer over `name` -- so a hygiene-renamed local
# still reads as the name the programmer wrote. Without it (the default;
# qualifyModules's renames), `name` -- the qualified spelling -- is itself
# the meaningful, canonical, provenance-carrying identity, so it is what
# diagnostics and native symbol names should show (spec: "an agent seeing
# web::uri_escape should be able to answer mechanically which file defines
# this").
proc hir::hygiene::RenameTo {hirVar b new {recordSpelling 0}} {
    upvar 1 $hirVar hir
    set old [dict get $hir bindings $b name]
    set s [dict get $hir bindings $b scope]
    dict set hir bindings $b name $new
    if {$recordSpelling && ![dict exists $hir bindings $b spelling]} {
        dict set hir bindings $b spelling $old
    }
    dict unset hir scopes $s names $old
    dict set hir scopes $s names $new $b
    dict for {id node} [dict get $hir exprs] {
        if {[dict get $node kind] in {ref bind} && [dict get $node binding] eq $b} {
            dict set hir exprs $id name $new
        }
    }
}
