# mutvec.tcl -- MutableVector[T]: a growable mutable VALUE (MUTABLE-VECTOR.md).
#
# Mutable storage does not imply reference semantics. A MutableVector is a
# value: two logical copies never influence each other. It is realized in
# two layers, the same on every backend:
#
#   header   {mutvec ID}: the identity of ONE logical vector value. Every
#            mutation (push, pop, take, swap, clear) changes the header it is
#            applied to, in place -- so a mutation never has to store a new
#            value back into its receiver's binding, struct field or context
#            member: the receiver *place* keeps its header.
#   backing  the elements, here a Tcl list held in `store(ID)`. Copying a
#            vector -- `mutable_vector#share`, which the compiler inserts
#            wherever a vector-bearing value is logically copied out of a
#            place that may later be mutated (hir/mutvec.tcl) -- makes a new
#            header whose backing is the SAME Tcl list object: Tcl's own
#            copy-on-write (Tcl_Obj reference counts) then duplicates the
#            list the first time either header is mutated, and mutates it in
#            place while it is unshared. That is the COW the native runtime
#            implements with an explicit shared count (MutVecObj).
#
# The compiler guarantees that a header is only ever mutated through the
# place that owns it: every value read out of a place is shared first, and a
# place's own initial value is shared unless it is fresh. So no alias of a
# header can observe a mutation, and the store's in-place update is never
# observable as aliasing -- exactly as for a coroutine handle.
#
# An affine element type makes the vector affine (hir::types::IsAffine): it
# is never shared (a copy is a move), its elements move in (push, swap) and
# out (pop, take, swap) and are dropped by the static descriptor of their
# type, never by anything this runtime decides: clear_drop/swap_drop and the
# `v` form of affine#drop (core/affine.tcl) take the descriptor the compiler
# computed. There is no ownership state here: no moved flag, no owner, no
# count beyond Tcl's own.
#
#   mutable_vector::from_list(xs)     a fresh vector of xs's elements
#   mutable_vector::length(v)         the number of elements
#   mutable_vector::empty?(v)         length == 0
#   mutable_vector::at(v, i)          the element at i (IndexNotFound)
#   mutable_vector::push(v, x)        appends x; unit
#   mutable_vector::pop(v)            removes and returns the last element
#                                     (IndexNotFound when empty)
#   mutable_vector::take(v, i)        removes and returns the element at i;
#                                     later elements keep their order
#                                     (IndexNotFound)
#   mutable_vector::swap(v, i, x)     installs x at i, returns the old
#                                     element (IndexNotFound; nothing changes)
#   mutable_vector::clear(v)          removes every element; unit
#
# and the internal operations (no source can spell `#`):
#
#   mutable_vector#share(v, D)        a logical copy of v (a vector-bearing
#                                     value) by share descriptor D: "h" a
#                                     vector (a new header on the same
#                                     backing), "s"N"."(SLOT"."D)*N a struct
#                                     whose listed slots are shared
#   mutable_vector#to_list(v)         an immutable List snapshot of v (the
#                                     domain of a loop over an unrestricted
#                                     vector)
#   mutable_vector#consume(v)         v itself: Core IR's mark of a loop that
#                                     consumes v (Core IR has no types)
#   mutable_vector#take_front(v)      removes and returns the first element
#                                     of a non-empty vector (consuming
#                                     iteration's one step)
#   mutable_vector#clear_drop(v, D)   clear, dropping every element by drop
#                                     descriptor D, first to last
#   mutable_vector#swap_drop(v, i, x, D)  swap; when i is no element, x
#                                     (already owned by the failed operation)
#                                     is dropped by D before IndexNotFound
#
# Test instrumentation (none by default): `counters` counts the logical
# copies (shares) and the vectors created, for COW evidence on the Tcl
# backends (where Tcl decides the physical duplication itself).

namespace eval core::mutvec {
    # Header ID -> the vector's elements (a Tcl list of values).
    variable store
    array set store {}
    variable nextId 0
    variable counters [dict create created 0 shares 0]
}

proc core::mutvec::New {items} {
    variable store
    variable nextId
    variable counters
    set id [incr nextId]
    set store($id) $items
    dict incr counters created
    return [list mutvec $id]
}

proc core::mutvec::Id {v name} {
    variable store
    set id [core::value::mutvecId [core::value::expect mutvec $v $name]]
    if {![info exists store($id)]} {
        error "core::mutvec: unknown MutableVector header $id"
    }
    return $id
}

# The elements of vector V (a Tcl list of values).
proc core::mutvec::items {v} {
    variable store
    return $store([Id $v mutable_vector])
}

proc core::mutvec::fromList {xs} {
    return [New [core::value::items [core::value::expect list $xs mutable_vector::from_list]]]
}

proc core::mutvec::length {v} {
    variable store
    return [core::value::intFromNumber [llength $store([Id $v mutable_vector::length])]]
}

proc core::mutvec::empty {v} {
    variable store
    return [core::value::bool [expr {[llength $store([Id $v mutable_vector::empty?])] == 0}]]
}

# The index I (an Int value) of vector ID, checked: 0 <= I < length, else
# IndexNotFound (the list/array convention).
proc core::mutvec::Index {id index name} {
    variable store
    set i [core::value::intOf [core::value::expect int $index $name]]
    set n [llength $store($id)]
    if {$i < 0 || $i >= $n} {
        core::native::failDeclared IndexNotFound \
            "$name: index $i is outside 0..[expr {$n - 1}]"
    }
    return $i
}

proc core::mutvec::at {v index} {
    variable store
    set id [Id $v mutable_vector::at]
    set i [Index $id $index mutable_vector::at]
    return [lindex $store($id) $i]
}

proc core::mutvec::push {v x} {
    variable store
    set id [Id $v mutable_vector::push]
    lappend store($id) [core::value::check $x]
    return [core::value::unit]
}

proc core::mutvec::pop {v} {
    variable store
    set id [Id $v mutable_vector::pop]
    if {[llength $store($id)] == 0} {
        core::native::failDeclared IndexNotFound \
            "mutable_vector::pop: the vector is empty"
    }
    return [lpop store($id)]
}

proc core::mutvec::take {v index} {
    variable store
    set id [Id $v mutable_vector::take]
    set i [Index $id $index mutable_vector::take]
    return [lpop store($id) $i]
}

proc core::mutvec::swap {v index x} {
    variable store
    set id [Id $v mutable_vector::swap]
    set i [Index $id $index mutable_vector::swap]
    set old [lindex $store($id) $i]
    lset store($id) $i [core::value::check $x]
    return $old
}

proc core::mutvec::clear {v} {
    variable store
    set store([Id $v mutable_vector::clear]) {}
    return [core::value::unit]
}

# ---------------------------------------------------------------------------
# Internal operations

proc core::mutvec::shareImpl {v descriptor} {
    return [Share $v [core::affine::Tree [core::value::strOf $descriptor] mutable_vector#share]]
}

proc core::mutvec::Share {v tree} {
    variable store
    variable counters
    switch -- [lindex $tree 0] {
        h {
            set id [Id $v mutable_vector#share]
            dict incr counters shares
            # The same Tcl list object: Tcl duplicates it at the first
            # mutation of either header (copy-on-write).
            set copy [New $store($id)]
            dict incr counters created -1
            return $copy
        }
        s {
            set values [core::value::structValues $v]
            foreach part [lrange $tree 1 end] {
                lassign $part slot inner
                lset values $slot [Share [lindex $values $slot] $inner]
            }
            return [core::value::structOf [core::value::structShape $v] $values]
        }
    }
    error "mutable_vector#share: bad descriptor tree $tree"
}

# mutable_vector#consume(v): v itself -- the Core IR mark of a loop that
# consumes v (hir/lower.tcl), which the evaluator iterates by moving each
# element out (core/evaluator.tcl's op-listloop).
proc core::mutvec::consume {v} {
    Id $v mutable_vector#consume
    return $v
}

proc core::mutvec::toList {v} {
    variable store
    return [core::value::listOf $store([Id $v mutable_vector#to_list])]
}

proc core::mutvec::takeFront {v} {
    variable store
    set id [Id $v mutable_vector#take_front]
    if {[llength $store($id)] == 0} {
        error "mutable_vector#take_front: empty vector"
    }
    return [lpop store($id) 0]
}

# Drops every element of vector V by descriptor tree TREE (core/affine.tcl),
# first to last, leaving V empty. The elements leave the vector before any is
# dropped, so each is dropped exactly once.
proc core::mutvec::DropElements {v tree} {
    variable store
    set id [Id $v mutable_vector]
    set elements $store($id)
    set store($id) {}
    foreach element $elements {
        core::affine::Drop $element $tree
    }
}

proc core::mutvec::clearDrop {v descriptor} {
    DropElements $v [core::affine::Tree [core::value::strOf $descriptor] mutable_vector#clear_drop]
    return [core::value::unit]
}

proc core::mutvec::swapDrop {v index x descriptor} {
    variable store
    set id [Id $v mutable_vector#swap_drop]
    set i [core::value::intOf [core::value::expect int $index mutable_vector#swap_drop]]
    if {$i < 0 || $i >= [llength $store($id)]} {
        # The replacement moved into this operation: it is released here,
        # on the error path, and the vector is unchanged.
        core::affine::Drop $x [core::affine::Tree [core::value::strOf $descriptor] mutable_vector#swap_drop]
    }
    return [swap $v $index $x]
}

# Test instrumentation: the counters (created, shares), and a reset.
proc core::mutvec::counters {} {
    variable counters
    return $counters
}
proc core::mutvec::resetCounters {} {
    variable counters
    set counters [dict create created 0 shares 0]
}

core::native::register mutable_vector::from_list -arity 1 -impl core::mutvec::fromList \
    -param-types {list} -result-type mutvec -runtime mutvec-alloc -result-shape {mutvec-from-list 0}
core::native::register mutable_vector::length -arity 1 -impl core::mutvec::length \
    -param-types {mutvec} -result-type int -result-range collection-length
core::native::register mutable_vector::empty? -arity 1 -impl core::mutvec::empty \
    -param-types {mutvec} -result-type bool
core::native::register mutable_vector::at -arity 2 -impl core::mutvec::at \
    -param-types {mutvec int} -result-type any -runtime range-check \
    -result-shape {mutvec-element 0} -errors IndexNotFound
core::native::register mutable_vector::push -arity 2 -impl core::mutvec::push \
    -param-types {mutvec any} -result-type unit -runtime mutvec-mutate
core::native::register mutable_vector::pop -arity 1 -impl core::mutvec::pop \
    -param-types {mutvec} -result-type any -runtime {range-check mutvec-mutate} \
    -result-shape {mutvec-element 0} -errors IndexNotFound
core::native::register mutable_vector::take -arity 2 -impl core::mutvec::take \
    -param-types {mutvec int} -result-type any -runtime {range-check mutvec-mutate} \
    -result-shape {mutvec-element 0} -errors IndexNotFound
core::native::register mutable_vector::swap -arity 3 -impl core::mutvec::swap \
    -param-types {mutvec int any} -result-type any -runtime {range-check mutvec-mutate} \
    -result-shape {mutvec-element 0} -errors IndexNotFound
core::native::register mutable_vector::clear -arity 1 -impl core::mutvec::clear \
    -param-types {mutvec} -result-type unit -runtime mutvec-mutate

core::native::register mutable_vector#share -arity 2 -impl core::mutvec::shareImpl \
    -param-types {any str} -result-type any -runtime mutvec-alloc -result-shape {same 0}
core::native::register mutable_vector#consume -arity 1 -impl core::mutvec::consume \
    -param-types {mutvec} -result-type mutvec -result-shape {same 0}
core::native::register mutable_vector#to_list -arity 1 -impl core::mutvec::toList \
    -param-types {mutvec} -result-type list -runtime list-alloc -result-shape {mutvec-to-list 0}
core::native::register mutable_vector#take_front -arity 1 -impl core::mutvec::takeFront \
    -param-types {mutvec} -result-type any -runtime mutvec-mutate -result-shape {mutvec-element 0}
core::native::register mutable_vector#clear_drop -arity 2 -impl core::mutvec::clearDrop \
    -param-types {mutvec str} -result-type unit -runtime mutvec-mutate
core::native::register mutable_vector#swap_drop -arity 4 -impl core::mutvec::swapDrop \
    -param-types {mutvec int any str} -result-type any -runtime {range-check mutvec-mutate} \
    -result-shape {mutvec-element 0} -errors IndexNotFound
