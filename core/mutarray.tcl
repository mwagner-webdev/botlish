# mutarray.tcl -- MutableArray: the native mutable-storage substrate.
#
# {mutarray ID} (value.tcl) is a handle into `store`, a Tcl dict keyed by ID
# mapping to a fixed-length Tcl list of the array's current slot values. Every
# value carrying the same ID refers to the same storage: mutating it through
# one handle is observable through every other handle with that ID. This is
# the one runtime value kind value.tcl documents as *not* immutable.
#
# This is deliberately the whole substrate: allocate, capacity, indexed
# at/set (bounds checked), bulk copy and finalization to an ordinary
# immutable List -- the `mutable_array` namespace's intrinsics, each a root
# native registered under its qualified name (mutable_array::allocate,
# ::capacity, ::at, ::set, ::copy, ::freeze); lib/mutable_array.bot adds the
# ordinary Botlish members (from_list, create, get) and may never redefine
# these (surface/modules.tcl, DUPLICATE-NATIVE; STDLIB-NAMESPACES.md). There is no push/grow/reserve here (and no such native):
# growth policy, chunking policy and finalization strategy are ordinary
# Botlish, built on these primitives (see examples/stdlib's builders). A
# MutableArray's capacity never changes after allocate; "growing" means
# allocating a new, larger MutableArray and copying into it.
#
# A freshly allocated slot holds {unit}, never nothing: uninitialized memory
# is never exposed as a Botlish value (see allocate).
#
# Equality is undefined for MutableArray (like Block/Native: see
# core::value::equal) -- its identity/equality semantics are a separate
# design question, out of this milestone's scope.

namespace eval core::mutarray {
    variable store [dict create]
    variable nextId 0
    # The native runtime's small-Int ceiling (native/src/runtime/value.rs's
    # SMALL_MAX/MAX_COLLECTION_LENGTH): 2^62 - 1. The reference interpreter
    # has no representation reason to cap collection sizes here, but a
    # capacity this large cannot be honored by either backend regardless
    # (Tcl's own `lrepeat` cannot represent a list of that length), so both
    # reject it the same way: an ordinary RANGE error, never an uncontrolled
    # crash (req #35/#36).
    variable MaxCollectionLength 4611686018427387903
}

# A fresh MutableArray of CAPACITY slots, each initialized to {unit}.
proc core::mutarray::allocate {capacity} {
    variable store
    variable nextId
    variable MaxCollectionLength
    set n [core::value::intOf [core::value::expect int $capacity mutable_array::allocate]]
    if {$n < 0 || $n > $MaxCollectionLength} {
        core::semanticError RANGE \
            "mutable_array::allocate: capacity must be 0..$MaxCollectionLength, got $n"
    }
    set id [incr nextId]
    dict set store $id [lrepeat $n {unit}]
    return [list mutarray $id]
}

proc core::mutarray::Slots {v name} {
    variable store
    set id [core::value::mutarrayId [core::value::expect mutarray $v $name]]
    if {![dict exists $store $id]} {
        error "core::mutarray: unknown MutableArray handle $id"
    }
    return $id
}

proc core::mutarray::capacity {v} {
    variable store
    set id [Slots $v mutable_array::capacity]
    return [core::value::intFromNumber [llength [dict get $store $id]]]
}

# (mutable_array::at ARRAY INDEX): the element at INDEX, 0 <= INDEX <
# capacity; any other Int fails with the declared builtin error
# IndexNotFound (core/native.tcl), exactly like list::at (core/lists.tcl).
proc core::mutarray::at {v index} {
    variable store
    set id [Slots $v mutable_array::at]
    set slots [dict get $store $id]
    set i [core::value::intOf [core::value::expect int $index mutable_array::at]]
    if {$i < 0 || $i >= [llength $slots]} {
        core::native::failDeclared IndexNotFound \
            "mutable_array::at: index $i is outside 0..[expr {[llength $slots] - 1}]"
    }
    return [lindex $slots $i]
}

# (mutable_array::set ARRAY INDEX VALUE): mutates ARRAY in place; returns
# unit. An INDEX that does not designate a slot fails with IndexNotFound,
# exactly like mutable_array::at, and writes nothing.
proc core::mutarray::set_ {v index value} {
    variable store
    set id [Slots $v mutable_array::set]
    set slots [dict get $store $id]
    set i [core::value::intOf [core::value::expect int $index mutable_array::set]]
    if {$i < 0 || $i >= [llength $slots]} {
        core::native::failDeclared IndexNotFound \
            "mutable_array::set: index $i is outside 0..[expr {[llength $slots] - 1}]"
    }
    dict set store $id [lset slots $i [core::value::check $value]]
    return [core::value::unit]
}

# (mutable_array::copy DST DSTSTART SRC SRCSTART COUNT): copies COUNT elements
# of SRC starting at SRCSTART into DST starting at DSTSTART; returns unit.
# DST and SRC may be the same MutableArray, with overlapping ranges: the
# result is as if every source element were read before any destination
# write (memmove semantics), matching the native runtime's pointer copy.
# Both ranges are slices (core::native::checkSlice): the destination
# DSTSTART..DSTSTART+COUNT of DST, then the source SRCSTART..SRCSTART+COUNT
# of SRC; the first invalid one fails with LowerUnderrun or UpperOverrun
# (a negative COUNT is an end before its start: LowerUnderrun), and nothing
# is copied.
proc core::mutarray::copy {dst dstStart src srcStart count} {
    variable store
    set dstId [Slots $dst mutable_array::copy]
    set srcId [Slots $src mutable_array::copy]
    set dstSlots [dict get $store $dstId]
    set srcSlots [dict get $store $srcId]
    set ds [core::value::intOf [core::value::expect int $dstStart mutable_array::copy]]
    set ss [core::value::intOf [core::value::expect int $srcStart mutable_array::copy]]
    set n  [core::value::intOf [core::value::expect int $count mutable_array::copy]]
    core::native::checkSlice mutable_array::copy $ds [expr {$ds + $n}] [llength $dstSlots]
    core::native::checkSlice mutable_array::copy $ss [expr {$ss + $n}] [llength $srcSlots]
    if {$n > 0} {
        # Read the source range before writing (memmove semantics), so an
        # overlapping self-copy (dstId == srcId) is correct in either
        # direction.
        set moved [lrange $srcSlots $ss [expr {$ss + $n - 1}]]
        set i $ds
        foreach value $moved {
            lset dstSlots $i $value
            incr i
        }
        dict set store $dstId $dstSlots
    }
    return [core::value::unit]
}

# (mutable_array::freeze ARRAY COUNT): a new immutable List of ARRAY's first
# COUNT elements: the slice 0..COUNT (core::native::checkSlice: a negative
# COUNT is LowerUnderrun, one above the capacity UpperOverrun). Always
# copies: this is the runtime's "final immutable storage creation"
# primitive, not a growth policy, and a future zero-copy freeze is left
# open, not implemented here.
proc core::mutarray::freeze {v count} {
    variable store
    set id [Slots $v mutable_array::freeze]
    set slots [dict get $store $id]
    set n [core::value::intOf [core::value::expect int $count mutable_array::freeze]]
    core::native::checkSlice mutable_array::freeze 0 $n [llength $slots]
    return [core::value::listOf [lrange $slots 0 [expr {$n - 1}]]]
}

core::native::register mutable_array::allocate -arity 1 -impl core::mutarray::allocate \
    -param-types {int} -result-type mutarray -runtime mutarray-alloc -context-free 1
core::native::register mutable_array::capacity -arity 1 -impl core::mutarray::capacity \
    -param-types {mutarray} -result-type int -result-range collection-length
core::native::register mutable_array::at -arity 2 -impl core::mutarray::at \
    -param-types {mutarray int} -result-type any -runtime range-check \
    -result-shape {mutarray-element 0} -errors IndexNotFound -bounds {index mutarray 0 1}
core::native::register mutable_array::set -arity 3 -impl core::mutarray::set_ \
    -param-types {mutarray int any} -result-type unit -runtime {range-check mutarray-mutate} \
    -errors IndexNotFound -bounds {index mutarray 0 1}
core::native::register mutable_array::copy -arity 5 -impl core::mutarray::copy \
    -param-types {mutarray int mutarray int int} -result-type unit -runtime {range-check mutarray-mutate} \
    -errors {LowerUnderrun UpperOverrun} \
    -bounds {slices {mutarray 0 1 {sum 1 4}} {mutarray 2 3 {sum 3 4}}}
core::native::register mutable_array::freeze -arity 2 -impl core::mutarray::freeze \
    -param-types {mutarray int} -result-type list -runtime {range-check mutarray-alloc} \
    -result-shape {mutarray-freeze 0} -errors {LowerUnderrun UpperOverrun} \
    -bounds {slices {mutarray 0 {const 0} 1}}
