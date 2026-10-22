# lists.tcl -- native list operations: the `list` namespace's intrinsics.
#
# The irreducible list primitives: counting, indexing and building. Lists
# are immutable values, so std::list::append returns a new list and leaves its
# argument unchanged. Indices are zero-based.
#
#   std::list::length(xs)     the number of elements
#   std::list::at(xs, i)      the element at i, 0 <= i < std::list::length(xs);
#                             any other Int index fails with the declared
#                             builtin error IndexNotFound (core/native.tcl) --
#                             an ordinary, handleable Botlish error completion,
#                             never a default value
#   std::list::append(xs, v)  a new list of xs's elements followed by v
#
# Each is a root native registered under its qualified name
# (core::native::isQualifiedNative): source spells it like a member of the
# `list` module (stdlib/list.bot), which may define other members (std::list::get,
# std::list::find, ...) but never one of these (surface/modules.tcl,
# DUPLICATE-NATIVE). STDLIB-NAMESPACES.md has the namespace model.
#
# Lists carry no element type, so std::list::at's result type is any: nothing in
# its signature says what kind of value comes out. Their -result-shape lets
# static analyses that track list contents (hir/types.tcl, aggregate facts)
# do better without knowing these natives by name.

namespace eval core::lists {}

proc core::lists::Items {v name} {
    return [core::value::items [core::value::expect list $v $name]]
}

proc core::lists::length {l} {
    return [core::value::intFromNumber [llength [Items $l std::list::length]]]
}

# (std::list::at LIST INDEX): the element at INDEX, 0 <= INDEX < length; any
# other Int fails with IndexNotFound. A non-List or non-Int argument is the
# ordinary TYPE error, not IndexNotFound: only an index that does not
# designate an element is "not found".
proc core::lists::at {l index} {
    set items [Items $l std::list::at]
    set i [core::value::intOf [core::value::expect int $index std::list::at]]
    if {$i < 0 || $i >= [llength $items]} {
        core::native::failDeclared IndexNotFound \
            "std::list::at: index $i is outside 0..[expr {[llength $items] - 1}]"
    }
    return [lindex $items $i]
}

# (std::list::append LIST VALUE): a new list of LIST's elements followed by VALUE.
proc core::lists::append {l v} {
    set items [Items $l std::list::append]
    lappend items [core::value::check $v]
    return [core::value::listOf $items]
}

core::native::register std::list::length -arity 1 -impl core::lists::length \
    -param-types {list} -result-type int -result-range collection-length -context-free 1 -ownership {observe} \
    -measures {List length 0}
core::native::register std::list::at     -arity 2 -impl core::lists::at \
    -param-types {list int} -result-type any -runtime range-check     -result-shape {element 0 1} \
    -context-free 1 -errors IndexNotFound -bounds {index list 0 1} -ownership {copy-out observe}
core::native::register std::list::append -arity 2 -impl core::lists::append \
    -param-types {list any} -result-type list -runtime list-alloc     -result-shape {append 0 1} -context-free 1 \
    -result-length {list 0 1} -ownership {copy-out copy-out}
