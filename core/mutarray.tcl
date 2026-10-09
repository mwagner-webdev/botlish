# mutarray.tcl -- MutableArray[T]: a fixed-length mutable VALUE
# (MUTABLE-ARRAY.md; PARAMETERIZED-MUTABLEARRAY.md for its static contract).
#
# Mutable storage does not imply reference semantics. A MutableArray is a
# value -- MutableVector's fixed-length sibling (core/mutvec.tcl) -- realized
# in the same two layers on every backend:
#
#   header   {mutarray ID}: the identity of ONE logical array value. Every
#            mutation (set, swap, copy into it) changes the header it is
#            applied to, in place, so a mutation never has to store a new
#            value back into its receiver's binding, struct field or context
#            member: the receiver *place* keeps its header.
#   backing  the slots, here a Tcl list held in `store(ID)`. A logical copy
#            -- `mutable_vector#share` with an `h` descriptor, which the
#            compiler inserts wherever an array-bearing value is copied out
#            of or into a place (hir/mutvec.tcl) -- makes a new header whose
#            backing is the SAME Tcl list object: Tcl's own copy-on-write
#            duplicates it the first time either header is mutated, and
#            mutates it in place while it is unshared.
#
# The compiler guarantees a header is only ever mutated through the one place
# that owns it, so no alias of a header can observe a mutation. The array's
# length never changes after construction (there is no push, no growth and
# no hole); only a consuming loop drains an affine array it owns, which is
# dead to the program by then.
#
# An affine element type makes the array affine (hir::types::IsAffine): it is
# never shared (a copy is a move), its elements move in (set, swap) and out
# (swap, a consuming loop), and the elements it displaces or still owns are
# dropped by the static descriptor of their type, never by anything this
# runtime decides (`#swap_drop`, `#set_drop`, `#generate_drop`, the `a` form
# of affine#drop). There is no ownership state here: no moved flag, no owner,
# no count beyond Tcl's own.
#
#   mutable_array::allocate(n)         n slots of unit (the raw substrate)
#   mutable_array::create(n, x)        n slots, each a logical copy of x
#                                      (x unrestricted: the compiler rejects
#                                      an affine x, AFFINE-DUPLICATION-
#                                      UNSUPPORTED)
#   mutable_array::from_list(xs)       the List's elements, in order
#   mutable_array::generate(n, f)      slot i holds f(i), for i from 0 to
#                                      n - 1, in order; the first failing
#                                      call's error propagates
#   mutable_array::capacity(a)         the length
#   mutable_array::at(a, i)            the element at i (IndexNotFound)
#   mutable_array::set(a, i, x)        installs x at i; unit (IndexNotFound)
#   mutable_array::swap(a, i, x)       installs x at i, returns the old
#                                      element (IndexNotFound; no change)
#   mutable_array::copy(d, ds, s, ss, n)  memmove of s's slice into d's
#   mutable_array::freeze(a, n)        a List of the first n elements
#
# and the internal operations (no source can spell `#`):
#
#   mutable_array#to_list(a)           an immutable List snapshot (the
#                                      domain of a loop over an unrestricted
#                                      array)
#   mutable_array#consume(a)           a itself: Core IR's mark of a loop
#                                      that consumes a
#   mutable_array#take_front(a)        removes and returns the first element
#                                      of a consumed array (one step of a
#                                      consuming loop)
#   mutable_array#swap_drop(a, i, x, D)  swap of affine elements; when i is
#                                      no element, x (already owned by the
#                                      failed operation) is dropped by D
#                                      before IndexNotFound
#   mutable_array#set_drop(a, i, x, D) set of affine elements: the displaced
#                                      element is dropped by D; when i is no
#                                      element, x is dropped by D instead
#   mutable_array#generate_drop(n, f, D)  generate of affine elements: when
#                                      f fails, the elements already made
#                                      are dropped by D, first to last,
#                                      before the error propagates
#
# Test instrumentation (none by default): `counters` counts the arrays
# created and the logical copies (shares), for COW evidence on the Tcl
# backends (where Tcl decides the physical duplication itself).
#
# Equality is undefined for MutableArray, as for MutableVector
# (core::value::equal: EQUALITY).

namespace eval core::mutarray {
    # Header ID -> the array's elements (a Tcl list of values).
    variable store
    array set store {}
    variable nextId 0
    variable counters [dict create created 0 shares 0]
    # The native runtime's small-Int ceiling (native/src/runtime/value.rs's
    # SMALL_MAX/MAX_COLLECTION_LENGTH): 2^62 - 1. The reference interpreter
    # has no representation reason to cap collection sizes here, but a
    # capacity this large cannot be honored by either backend regardless
    # (Tcl's own `lrepeat` cannot represent a list of that length), so both
    # reject it the same way: an ordinary RANGE error, never an uncontrolled
    # crash.
    variable MaxCollectionLength 4611686018427387903
}

proc core::mutarray::New {items} {
    variable store
    variable nextId
    variable counters
    set id [incr nextId]
    set store($id) $items
    dict incr counters created
    return [list mutarray $id]
}

proc core::mutarray::Id {v name} {
    variable store
    set id [core::value::mutarrayId [core::value::expect mutarray $v $name]]
    if {![info exists store($id)]} {
        error "core::mutarray: unknown MutableArray header $id"
    }
    return $id
}

# The elements of array V (a Tcl list of values).
proc core::mutarray::items {v} {
    variable store
    return $store([Id $v mutable_array])
}

# The checked capacity N (an Int value) of a new array, for operation NAME.
proc core::mutarray::Capacity {n name} {
    variable MaxCollectionLength
    set n [core::value::intOf [core::value::expect int $n $name]]
    if {$n < 0 || $n > $MaxCollectionLength} {
        core::semanticError RANGE "$name: capacity must be 0..$MaxCollectionLength, got $n"
    }
    return $n
}

# A fresh MutableArray of CAPACITY slots, each initialized to {unit}.
proc core::mutarray::allocate {capacity} {
    return [New [lrepeat [Capacity $capacity mutable_array::allocate] [core::value::unit]]]
}

# A fresh MutableArray of CAPACITY slots, each holding VALUE: one value placed
# CAPACITY times (an unrestricted value: a logical copy per slot, the same
# immutable value or COW header in each).
proc core::mutarray::create {capacity value} {
    return [New [lrepeat [Capacity $capacity mutable_array::create] [core::value::check $value]]]
}

proc core::mutarray::fromList {xs} {
    return [New [core::value::items [core::value::expect list $xs mutable_array::from_list]]]
}

# The elements FACTORY makes for slots 0..COUNT-1, in order, as a completion:
# {normal ARRAY}, or the first failing call's propagate-error, after DROP (a
# descriptor tree, or "" for unrestricted elements) released the elements
# already made, first to last.
proc core::mutarray::Generate {count factory tree name} {
    set n [Capacity $count $name]
    set items {}
    for {set i 0} {$i < $n} {incr i} {
        set completion [core::callable::invoke $factory [list [core::value::intFromNumber $i]]]
        if {[core::completion::kind $completion] ne "value"} {
            if {$tree ne ""} {
                foreach item $items {
                    core::affine::Drop $item $tree
                }
            }
            return $completion
        }
        lappend items [core::completion::payload $completion]
    }
    return [core::completion::normal [New $items]]
}

proc core::mutarray::generate {count factory} {
    return [Generate $count $factory "" mutable_array::generate]
}

proc core::mutarray::generateDrop {count factory descriptor} {
    return [Generate $count $factory \
        [core::affine::Tree [core::value::strOf $descriptor] mutable_array#generate_drop] mutable_array#generate_drop]
}

proc core::mutarray::capacity {v} {
    variable store
    return [core::value::intFromNumber [llength $store([Id $v mutable_array::capacity])]]
}

# The index I (an Int value) of array ID, checked: 0 <= I < capacity, else
# IndexNotFound (the list/vector convention).
proc core::mutarray::Index {id index name} {
    variable store
    set i [core::value::intOf [core::value::expect int $index $name]]
    set n [llength $store($id)]
    if {$i < 0 || $i >= $n} {
        core::native::failDeclared IndexNotFound \
            "$name: index $i is outside 0..[expr {$n - 1}]"
    }
    return $i
}

# (mutable_array::at ARRAY INDEX): the element at INDEX, 0 <= INDEX <
# capacity; any other Int fails with the declared builtin error
# IndexNotFound (core/native.tcl), exactly like list::at (core/lists.tcl).
proc core::mutarray::at {v index} {
    variable store
    set id [Id $v mutable_array::at]
    set i [Index $id $index mutable_array::at]
    return [lindex $store($id) $i]
}

# (mutable_array::set ARRAY INDEX VALUE): mutates ARRAY's header in place;
# returns unit. An INDEX that does not designate a slot fails with
# IndexNotFound, exactly like mutable_array::at, and writes nothing.
proc core::mutarray::set_ {v index value} {
    variable store
    set id [Id $v mutable_array::set]
    set i [Index $id $index mutable_array::set]
    lset store($id) $i [core::value::check $value]
    return [core::value::unit]
}

# (mutable_array::swap ARRAY INDEX VALUE): VALUE installed at INDEX, the old
# element returned; IndexNotFound (and no change) when INDEX is no slot.
proc core::mutarray::swap {v index value} {
    variable store
    set id [Id $v mutable_array::swap]
    set i [Index $id $index mutable_array::swap]
    set old [lindex $store($id) $i]
    lset store($id) $i [core::value::check $value]
    return $old
}

# (mutable_array::copy DST DSTSTART SRC SRCSTART COUNT): copies COUNT elements
# of SRC starting at SRCSTART into DST starting at DSTSTART; returns unit.
# DST and SRC may be the same array, with overlapping ranges: the result is
# as if every source element were read before any destination write (memmove
# semantics), matching the native runtime. Both ranges are slices
# (core::native::checkSlice): the destination DSTSTART..DSTSTART+COUNT of
# DST, then the source SRCSTART..SRCSTART+COUNT of SRC; the first invalid one
# fails with LowerUnderrun or UpperOverrun (a negative COUNT is an end before
# its start: LowerUnderrun), and nothing is copied.
proc core::mutarray::copy {dst dstStart src srcStart count} {
    variable store
    set dstId [Id $dst mutable_array::copy]
    set srcId [Id $src mutable_array::copy]
    set ds [core::value::intOf [core::value::expect int $dstStart mutable_array::copy]]
    set ss [core::value::intOf [core::value::expect int $srcStart mutable_array::copy]]
    set n  [core::value::intOf [core::value::expect int $count mutable_array::copy]]
    core::native::checkSlice mutable_array::copy $ds [expr {$ds + $n}] [llength $store($dstId)]
    core::native::checkSlice mutable_array::copy $ss [expr {$ss + $n}] [llength $store($srcId)]
    if {$n > 0} {
        # Read the source range before writing (memmove semantics), so an
        # overlapping self-copy is correct in either direction.
        set moved [lrange $store($srcId) $ss [expr {$ss + $n - 1}]]
        set i $ds
        foreach value $moved {
            lset store($dstId) $i $value
            incr i
        }
    }
    return [core::value::unit]
}

# (mutable_array::freeze ARRAY COUNT): a new immutable List of ARRAY's first
# COUNT elements: the slice 0..COUNT (core::native::checkSlice: a negative
# COUNT is LowerUnderrun, one above the capacity UpperOverrun).
proc core::mutarray::freeze {v count} {
    variable store
    set id [Id $v mutable_array::freeze]
    set n [core::value::intOf [core::value::expect int $count mutable_array::freeze]]
    core::native::checkSlice mutable_array::freeze 0 $n [llength $store($id)]
    return [core::value::listOf [lrange $store($id) 0 [expr {$n - 1}]]]
}

# ---------------------------------------------------------------------------
# Internal operations

proc core::mutarray::toList {v} {
    variable store
    return [core::value::listOf $store([Id $v mutable_array#to_list])]
}

# mutable_array#consume(a): a itself -- the Core IR mark of a loop that
# consumes a (hir/lower.tcl), which the evaluator iterates by moving each
# element out (core/evaluator.tcl's op-listloop).
proc core::mutarray::consume {v} {
    Id $v mutable_array#consume
    return $v
}

proc core::mutarray::takeFront {v} {
    variable store
    set id [Id $v mutable_array#take_front]
    if {[llength $store($id)] == 0} {
        error "mutable_array#take_front: no element left"
    }
    return [lpop store($id) 0]
}

proc core::mutarray::swapDrop {v index x descriptor} {
    variable store
    set id [Id $v mutable_array#swap_drop]
    set i [core::value::intOf [core::value::expect int $index mutable_array#swap_drop]]
    if {$i < 0 || $i >= [llength $store($id)]} {
        # The replacement moved into this operation: it is released here,
        # on the error path, and the array is unchanged.
        core::affine::Drop $x [core::affine::Tree [core::value::strOf $descriptor] mutable_array#swap_drop]
    }
    return [swap $v $index $x]
}

proc core::mutarray::setDrop {v index x descriptor} {
    variable store
    set tree [core::affine::Tree [core::value::strOf $descriptor] mutable_array#set_drop]
    set id [Id $v mutable_array#set_drop]
    set i [core::value::intOf [core::value::expect int $index mutable_array#set_drop]]
    if {$i < 0 || $i >= [llength $store($id)]} {
        core::affine::Drop $x $tree
        return [set_ $v $index $x]
    }
    # The displaced element leaves the array before it is released.
    core::affine::Drop [swap $v $index $x] $tree
    return [core::value::unit]
}

# A new header on the same backing as array V (mutable_vector#share's `h`).
proc core::mutarray::Share {v} {
    variable store
    variable counters
    set id [Id $v mutable_vector#share]
    dict incr counters shares
    # The same Tcl list object: Tcl duplicates it at the first mutation of
    # either header (copy-on-write).
    set copy [New $store($id)]
    dict incr counters created -1
    return $copy
}

# Drops every element of array V by descriptor tree TREE (core/affine.tcl),
# first to last. The elements leave the (dying) array before any is dropped,
# so each is dropped exactly once.
proc core::mutarray::DropElements {v tree} {
    variable store
    set id [Id $v mutable_array]
    set elements $store($id)
    set store($id) {}
    foreach element $elements {
        core::affine::Drop $element $tree
    }
}

# Test instrumentation: the counters (created, shares), and a reset.
proc core::mutarray::counters {} {
    variable counters
    return $counters
}
proc core::mutarray::resetCounters {} {
    variable counters
    set counters [dict create created 0 shares 0]
}

# Ownership roles (-ownership, core/native.tcl): what each operation does with
# each argument, which the ownership discipline (hir/affine.tcl) reads instead
# of any operation's name.
core::native::register mutable_array::allocate -arity 1 -impl core::mutarray::allocate \
    -param-types {int} -result-type mutarray -runtime mutarray-alloc -context-free 1 \
    -result-length {int 0} -ownership {observe}
core::native::register mutable_array::create -arity 2 -impl core::mutarray::create \
    -param-types {int any} -result-type mutarray -runtime mutarray-alloc \
    -result-shape {mutarray-create 1} -result-length {int 0} -ownership {observe repeat}
core::native::register mutable_array::from_list -arity 1 -impl core::mutarray::fromList \
    -param-types {list} -result-type mutarray -runtime mutarray-alloc \
    -result-shape {mutarray-from-list 0} -result-length {list 0} -ownership {move}
core::native::register mutable_array::generate -arity 2 -impl core::mutarray::generate \
    -param-types {int any} -result-type mutarray -runtime mutarray-alloc -completion 1 \
    -result-shape {mutarray-generate 1} -errors-from 1 -result-length {int 0} \
    -drop-form {mutable_array#generate_drop result} -ownership {observe factory}
core::native::register mutable_array::capacity -arity 1 -impl core::mutarray::capacity \
    -param-types {mutarray} -result-type int -result-range collection-length -ownership {observe}
core::native::register mutable_array::at -arity 2 -impl core::mutarray::at \
    -param-types {mutarray int} -result-type any -runtime range-check \
    -result-shape {mutarray-element 0} -errors IndexNotFound -bounds {index mutarray 0 1} \
    -ownership {copy-out observe}
core::native::register mutable_array::set -arity 3 -impl core::mutarray::set_ \
    -param-types {mutarray int any} -result-type unit -runtime {range-check mutarray-mutate} \
    -errors IndexNotFound -bounds {index mutarray 0 1} -drop-form {mutable_array#set_drop 0} \
    -ownership {place observe move}
core::native::register mutable_array::swap -arity 3 -impl core::mutarray::swap \
    -param-types {mutarray int any} -result-type any -runtime {range-check mutarray-mutate} \
    -result-shape {mutarray-element 0} -errors IndexNotFound -bounds {index mutarray 0 1} \
    -drop-form {mutable_array#swap_drop 0} -ownership {place observe move}
core::native::register mutable_array::copy -arity 5 -impl core::mutarray::copy \
    -param-types {mutarray int mutarray int int} -result-type unit -runtime {range-check mutarray-mutate} \
    -errors {LowerUnderrun UpperOverrun} \
    -bounds {slices {mutarray 0 1 {sum 1 4}} {mutarray 2 3 {sum 3 4}}} \
    -ownership {place observe copy-out observe observe}
core::native::register mutable_array::freeze -arity 2 -impl core::mutarray::freeze \
    -param-types {mutarray int} -result-type list -runtime {range-check mutarray-alloc} \
    -result-shape {mutarray-freeze 0} -errors {LowerUnderrun UpperOverrun} \
    -bounds {slices {mutarray 0 {const 0} 1}} -ownership {copy-out observe}

core::native::register mutable_array#to_list -arity 1 -impl core::mutarray::toList \
    -param-types {mutarray} -result-type list -runtime list-alloc -result-shape {mutarray-freeze 0} \
    -ownership {copy-out}
core::native::register mutable_array#consume -arity 1 -impl core::mutarray::consume \
    -param-types {mutarray} -result-type mutarray -result-shape {same 0} -ownership {move}
core::native::register mutable_array#take_front -arity 1 -impl core::mutarray::takeFront \
    -param-types {mutarray} -result-type any -runtime mutarray-mutate -result-shape {mutarray-element 0} \
    -ownership {place}
core::native::register mutable_array#swap_drop -arity 4 -impl core::mutarray::swapDrop \
    -param-types {mutarray int any str} -result-type any -runtime {range-check mutarray-mutate} \
    -result-shape {mutarray-element 0} -errors IndexNotFound -ownership {place observe move observe}
core::native::register mutable_array#set_drop -arity 4 -impl core::mutarray::setDrop \
    -param-types {mutarray int any str} -result-type unit -runtime {range-check mutarray-mutate} \
    -errors IndexNotFound -ownership {place observe move observe}
core::native::register mutable_array#generate_drop -arity 3 -impl core::mutarray::generateDrop \
    -param-types {int any str} -result-type mutarray -runtime mutarray-alloc -completion 1 \
    -result-shape {mutarray-generate 1} -errors-from 1 -result-length {int 0} \
    -ownership {observe factory observe}
