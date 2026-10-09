# lists.tcl -- native list operations: the `list` namespace's intrinsics.
#
# The irreducible list primitives: counting, indexing and building. Lists
# are immutable values, so list::append returns a new list and leaves its
# argument unchanged. Indices are zero-based.
#
#   list::length(xs)      the number of elements
#   list::at(xs, i)       the element at i, 0 <= i < list::length(xs); any
#                         other Int index fails with the declared builtin
#                         error IndexNotFound (core/native.tcl) -- an
#                         ordinary, handleable Botlish error completion,
#                         never a default value
#   list::append(xs, v)   a new list of xs's elements followed by v
#
# Each is a root native registered under its qualified name
# (core::native::isQualifiedNative): source spells it like a member of the
# `list` module (lib/list.bot), which may define other members (list::get,
# list::find, ...) but never one of these (surface/modules.tcl,
# DUPLICATE-NATIVE). STDLIB-NAMESPACES.md has the namespace model.
#
# Lists carry no element type, so list::at's result type is any: nothing in
# its signature says what kind of value comes out. Their -result-shape lets
# static analyses that track list contents (hir/types.tcl, aggregate facts)
# do better without knowing these natives by name.

namespace eval core::lists {}

proc core::lists::Items {v name} {
    return [core::value::items [core::value::expect list $v $name]]
}

proc core::lists::length {l} {
    return [core::value::intFromNumber [llength [Items $l list::length]]]
}

# (list::at LIST INDEX): the element at INDEX, 0 <= INDEX < length; any
# other Int fails with IndexNotFound. A non-List or non-Int argument is the
# ordinary TYPE error, not IndexNotFound: only an index that does not
# designate an element is "not found".
proc core::lists::at {l index} {
    set items [Items $l list::at]
    set i [core::value::intOf [core::value::expect int $index list::at]]
    if {$i < 0 || $i >= [llength $items]} {
        core::native::failDeclared IndexNotFound \
            "list::at: index $i is outside 0..[expr {[llength $items] - 1}]"
    }
    return [lindex $items $i]
}

# (list::append LIST VALUE): a new list of LIST's elements followed by VALUE.
proc core::lists::append {l v} {
    set items [Items $l list::append]
    lappend items [core::value::check $v]
    return [core::value::listOf $items]
}

core::native::register list::length -arity 1 -impl core::lists::length \
    -param-types {list} -result-type int -result-range collection-length -context-free 1 -ownership {observe}
core::native::register list::at     -arity 2 -impl core::lists::at \
    -param-types {list int} -result-type any -runtime range-check     -result-shape {element 0 1} \
    -context-free 1 -errors IndexNotFound -bounds {index list 0 1} -ownership {copy-out observe}
core::native::register list::append -arity 2 -impl core::lists::append \
    -param-types {list any} -result-type list -runtime list-alloc     -result-shape {append 0 1} -context-free 1 \
    -ownership {copy-out copy-out}
