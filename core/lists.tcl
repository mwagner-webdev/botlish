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
#   std::list::flat(lists)    a new list of the elements of every List in
#                             lists, in order: exactly one level of nesting
#                             removed (LIST-FLAT-MILESTONE-1.md)
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

# (std::list::flat LISTS): a new List of the elements of LISTS' first List,
# then of its second, and so on -- exactly one level of nesting removed,
# every element kept as it is (never compared, converted or flattened
# further), LISTS and its Lists unchanged. An element of LISTS that is not a
# List is the ordinary TYPE error, with its position; a checked program
# reaches it only through `any` (the static signature holds the argument to
# List[List[T]]). Linear: each inner List's items are appended once, and
# the result is built once (no prefix is ever copied again).
proc core::lists::flat {l} {
    set result {}
    set i 0
    foreach inner [Items $l std::list::flat] {
        lappend result {*}[core::value::items [core::value::expect list $inner "std::list::flat element $i"]]
        incr i
    }
    return [list list $result]
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
# std::list::flat[T](lists: List[List[T]]) -> List[T], stated the way the
# other List intrinsics state their element types: the -result-shape
# {flat 0} types the result from the argument's (hir/types.tcl's
# ShapeResult), -param-types and -element-kinds are the run-time kind
# contract -- a List whose every element is a List -- which the one
# native-kind rule holds statically where the argument's element type has a
# known other kind (flat([1, 2]) is a compile-time TYPE error) and leaves to
# the run-time check where it is `any`. The result's exact length is the
# outer length times the inner one when the argument's type states both
# (-result-length {flat 0}). Its elements are copied out of the argument's
# Lists (-ownership copy-out: an affine List is
# AFFINE-LIST-OPERATION-UNSUPPORTED, like every element-wise List operation).
core::native::register std::list::flat   -arity 1 -impl core::lists::flat \
    -param-types {list} -element-kinds {list} -result-type list -runtime list-alloc \
    -result-shape {flat 0} -context-free 1 -result-length {flat 0} -ownership {copy-out}
