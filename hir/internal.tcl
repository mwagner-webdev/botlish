# internal.tcl -- the intrinsics internal to the language implementation
# (HASHABLE-AND-KEYED-HASH.md, "Visibility boundary").
#
#   hir::internal::verify HIRVAR     diagnostics, part of hir::CheckOnce
#
# A member of an internal namespace (core::native::declareInternalNamespace:
# table_hash, the private table hash) is reached by the standard library's
# modules only: the loader refuses an import of its namespace, or a qualified
# reference into it, from any other code (surface/modules.tcl's CheckInternal,
# INTERNAL-NAMESPACE). Here, for every program alike, it is only ever called:
# a reference that is not the callee of a call -- an alias, an argument, a
# result, a stored or captured value -- is INTERNAL-INTRINSIC-VALUE, so no
# function value can carry it out of the module that may use it, and a call
# through a value never reaches it. HIR from core IR text or HIR interchange
# is past the source boundary and trusted, as for every other check.

namespace eval hir::internal {}

proc hir::internal::verify {hirVar} {
    upvar 1 $hirVar hir
    if {[core::native::internalNamespaces] eq {}} {
        return
    }
    set callees [dict create]
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] eq "call"} {
            dict set callees [dict get $node callee] 1
        }
    }
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "ref" || [dict exists $callees $e]} continue
        set b [dict get $node binding]
        if {$b eq "" || ![dict exists $hir bindings $b]} continue
        set binding [hir::binding $hir $b]
        if {[dict get $binding kind] ne "root" || ![core::native::isInternal [dict get $binding name]]} continue
        set native [dict get $binding name]
        hir::Diagnose hir INTERNAL-INTRINSIC-VALUE \
            "$native can only be called, never used as a value: it is internal to the standard library (namespace \"[core::native::namespaceOf $native]\"), and a function value of it could be passed, stored or returned out of the code allowed to use it" $e
    }
}
