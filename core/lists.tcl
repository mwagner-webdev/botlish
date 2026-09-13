# lists.tcl -- native list operations.
#
# The irreducible list primitives: counting, indexing and building. Lists
# are immutable values, so list_append returns a new list and leaves its
# argument unchanged. Indices are zero-based; an index outside the list is a
# RANGE error, never a default value.
#
# The names use `_` rather than `-` so that source can spell them (§17).
# Lists carry no element type, so list_get's result type is any: nothing in
# its signature says what kind of value comes out.

namespace eval core::lists {}

proc core::lists::Items {v name} {
    return [core::value::items [core::value::expect list $v $name]]
}

proc core::lists::length {l} {
    return [core::value::int [llength [Items $l list_length]]]
}

# (list_get LIST INDEX): the element at INDEX, 0 <= INDEX < length.
proc core::lists::get {l index} {
    set items [Items $l list_get]
    set i [core::value::intOf [core::value::expect int $index list_get]]
    if {$i < 0 || $i >= [llength $items]} {
        core::semanticError RANGE \
            "list_get: index $i is outside 0..[expr {[llength $items] - 1}]"
    }
    return [lindex $items $i]
}

# (list_append LIST VALUE): a new list of LIST's elements followed by VALUE.
proc core::lists::append {l v} {
    set items [Items $l list_append]
    lappend items [core::value::check $v]
    return [core::value::listOf $items]
}

core::native::register list_length -arity 1 -impl core::lists::length \
    -param-types {list} -result-type int
core::native::register list_get    -arity 2 -impl core::lists::get \
    -param-types {list int} -result-type any -runtime range-check
core::native::register list_append -arity 2 -impl core::lists::append \
    -param-types {list any} -result-type list -runtime list-alloc
