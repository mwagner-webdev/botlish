# imports.tcl -- the import environments of a compilation (IMPORTS.md).
#
#   hir::imports::apply TABLE        install the table of the compilation
#   hir::imports::namespaces NS      the namespaces file NS directly imports
#   hir::imports::typeNamed NS SHORT canonical type SHORT denotes in NS, or ""
#   hir::imports::current            the installed table
#
# `import NAMESPACE` and `import type NAMESPACE::Type` are file-header
# declarations, settled before any body is resolved: surface/modules.tcl
# validates them (existence, duplicates, collisions, authorization of every
# qualified reference) and hands this compilation the *result* as one table,
# NAMESPACE -> {namespaces {NS ...} types {SHORT CANONICAL ...}}, keyed by the
# module namespace the importing file declares ("" for the entry program).
# An import never reaches HIR as a node, a binding or a call: it is a
# resolution-time fact, consulted by exactly two things --
#
#   * a method-style call `x.f(a)`: the directly imported namespaces' members
#     named `f` are, with the ordinary lexical candidates, the functions the
#     call may denote (hir/resolve.tcl; METHOD-SUGAR.md, IMPORTS.md);
#   * a bare type name in a type annotation: a type import binds SHORT to the
#     qualified source type CANONICAL (`abi::U8Value`) at once, so a type
#     annotation resolves to the one canonical identity and no alias survives
#     (hir/types.tcl's resolveNamed).
#
# Nothing else reads it: an unqualified value or function name is never
# resolved through an import, and the table is not transitive (a file's entry
# lists only what that file itself imports).
#
# Like hir/structs.tcl's registry and core::type's source types, the table is
# the current compilation's, one Tcl variable, replaced by the next
# compilation that brings its own (hir::buildSyntax's -imports); a build
# without the option (core IR, an internal rebuild of an already resolved
# program) leaves it as it is.

namespace eval hir::imports {
    variable table [dict create]
}

proc hir::imports::apply {newTable} {
    variable table
    set table $newTable
}

proc hir::imports::current {} {
    variable table
    return $table
}

# The namespaces file NS directly imports, in written order.
proc hir::imports::namespaces {ns} {
    variable table
    if {![dict exists $table $ns]} {
        return {}
    }
    return [dict get $table $ns namespaces]
}

# The canonical identity of the type SHORT names in file NS through a type
# import, or "".
proc hir::imports::typeNamed {ns short} {
    variable table
    if {![dict exists $table $ns]} {
        return ""
    }
    set types [dict get $table $ns types]
    return [expr {[dict exists $types $short] ? [dict get $types $short] : ""}]
}
