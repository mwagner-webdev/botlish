# tree.tcl -- the internal intrinsic of std::tree (TREE-STRUCT-MILESTONE-1.md).
#
# A tree struct's one recursive field, its child field, is the declaration's
# (hir/structs.tcl): `std::tree::children(t)` is that field of the tree value
# T, whatever the field is called, so std::tree::walk (stdlib/tree.bot) can
# traverse every tree struct without a children callback. It is internal to
# the standard library (core::native::declareInternalMember): to a program a
# tree's children are its field, read by its name. Statically, its argument
# is proven a tree struct's value where it runs (hir/structs.tcl's
# TreeChildrenProblem) and its result is that tree's child List type
# (hir/types.tcl's `tree-children` result shape); native code reads the
# slot the static type names (native/lower.tcl's NativeCall) or, where no
# static type names one, the slot the value's shape records (`treechildren`).

namespace eval core::tree {}

# The child List of T, a value of a tree struct: its child field's value. A
# checked program never gives it anything else (TYPE).
proc core::tree::children {t} {
    set child ""
    if {[core::value::kind $t] eq "struct"} {
        set child [core::value::treeChildOf [core::value::structId $t]]
    }
    if {$child eq ""} {
        core::semanticError TYPE "std::tree::children: [core::value::show $t] is not a tree struct value"
    }
    return [lindex [core::value::structValues $t] $child]
}

core::native::register std::tree::children -arity 1 -impl core::tree::children \
    -param-types {struct} -result-type list -result-shape {tree-children 0} \
    -context-free 1 -nomethod 1 -ownership {copy-out}
core::native::declareInternalMember std::tree::children
