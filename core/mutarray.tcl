# mutarray.tcl -- MutableArray: the native mutable-storage substrate.
#
# {mutarray ID} (value.tcl) is a handle into `store`, a Tcl dict keyed by ID
# mapping to a fixed-length Tcl list of the array's current slot values. Every
# value carrying the same ID refers to the same storage: mutating it through
# one handle is observable through every other handle with that ID. This is
# the one runtime value kind value.tcl documents as *not* immutable.
#
# This is deliberately the whole substrate: allocate, capacity, indexed
# get/set (bounds checked), bulk copy and finalization to an ordinary
# immutable List. There is no push/grow/reserve here (and no such native):
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
    set n [core::value::intOf [core::value::expect int $capacity mutable_array_allocate]]
    if {$n < 0 || $n > $MaxCollectionLength} {
        core::semanticError RANGE \
            "mutable_array_allocate: capacity must be 0..$MaxCollectionLength, got $n"
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
    set id [Slots $v mutable_array_capacity]
    return [core::value::int [llength [dict get $store $id]]]
}

# (mutable_array_get ARRAY INDEX): the element at INDEX, 0 <= INDEX < capacity.
proc core::mutarray::get {v index} {
    variable store
    set id [Slots $v mutable_array_get]
    set slots [dict get $store $id]
    set i [core::value::intOf [core::value::expect int $index mutable_array_get]]
    if {$i < 0 || $i >= [llength $slots]} {
        core::semanticError RANGE \
            "mutable_array_get: index $i is outside 0..[expr {[llength $slots] - 1}]"
    }
    return [lindex $slots $i]
}

# (mutable_array_set ARRAY INDEX VALUE): mutates ARRAY in place; returns unit.
proc core::mutarray::set_ {v index value} {
    variable store
    set id [Slots $v mutable_array_set]
    set slots [dict get $store $id]
    set i [core::value::intOf [core::value::expect int $index mutable_array_set]]
    if {$i < 0 || $i >= [llength $slots]} {
        core::semanticError RANGE \
            "mutable_array_set: index $i is outside 0..[expr {[llength $slots] - 1}]"
    }
    dict set store $id [lset slots $i [core::value::check $value]]
    return [core::value::unit]
}

# (mutable_array_copy DST DSTSTART SRC SRCSTART COUNT): copies COUNT elements
# of SRC starting at SRCSTART into DST starting at DSTSTART; returns unit.
# DST and SRC may be the same MutableArray, with overlapping ranges: the
# result is as if every source element were read before any destination
# write (memmove semantics), matching the native runtime's pointer copy.
proc core::mutarray::copy {dst dstStart src srcStart count} {
    variable store
    set dstId [Slots $dst mutable_array_copy]
    set srcId [Slots $src mutable_array_copy]
    set dstSlots [dict get $store $dstId]
    set srcSlots [dict get $store $srcId]
    set ds [core::value::intOf [core::value::expect int $dstStart mutable_array_copy]]
    set ss [core::value::intOf [core::value::expect int $srcStart mutable_array_copy]]
    set n  [core::value::intOf [core::value::expect int $count mutable_array_copy]]
    set invalid [expr {
        $ds < 0 || $ss < 0 || $n < 0
        || $ds + $n > [llength $dstSlots] || $ss + $n > [llength $srcSlots]
    }]
    if {$invalid} {
        core::semanticError RANGE \
            "mutable_array_copy: range dstStart=$ds, srcStart=$ss, count=$n is invalid for dst capacity [llength $dstSlots], src capacity [llength $srcSlots]"
    }
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

# (mutable_array_freeze ARRAY COUNT): a new immutable List of ARRAY's first
# COUNT elements (0 <= COUNT <= capacity). Always copies: this is the
# runtime's "final immutable storage creation" primitive, not a growth
# policy, and a future zero-copy freeze is left open, not implemented here.
proc core::mutarray::freeze {v count} {
    variable store
    set id [Slots $v mutable_array_freeze]
    set slots [dict get $store $id]
    set n [core::value::intOf [core::value::expect int $count mutable_array_freeze]]
    if {$n < 0 || $n > [llength $slots]} {
        core::semanticError RANGE \
            "mutable_array_freeze: count $n is outside 0..[llength $slots]"
    }
    return [core::value::listOf [lrange $slots 0 [expr {$n - 1}]]]
}

core::native::register mutable_array_allocate -arity 1 -impl core::mutarray::allocate \
    -param-types {int} -result-type mutarray -runtime mutarray-alloc
core::native::register mutable_array_capacity -arity 1 -impl core::mutarray::capacity \
    -param-types {mutarray} -result-type int -result-range collection-length
core::native::register mutable_array_get -arity 2 -impl core::mutarray::get \
    -param-types {mutarray int} -result-type any -runtime range-check
core::native::register mutable_array_set -arity 3 -impl core::mutarray::set_ \
    -param-types {mutarray int any} -result-type unit -runtime {range-check mutarray-mutate}
core::native::register mutable_array_copy -arity 5 -impl core::mutarray::copy \
    -param-types {mutarray int mutarray int int} -result-type unit -runtime {range-check mutarray-mutate}
core::native::register mutable_array_freeze -arity 2 -impl core::mutarray::freeze \
    -param-types {mutarray int} -result-type list -runtime {range-check mutarray-alloc}
