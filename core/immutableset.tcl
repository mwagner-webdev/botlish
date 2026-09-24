# immutableset.tcl -- native ImmutableSet operations.
#
# ImmutableSet (MINIMAL-IMMUTABLE-SET.md) is a distinct runtime value kind
# (core/value.tcl) whose membership is fixed at construction and never
# mutated afterward. This is deliberately the simplest sound representation
# (spec item 10): an ordinary internal Tcl list of already-deduplicated
# member values, kept in first-occurrence order as an implementation/display
# detail only -- a set has no semantic order (item 14) -- with construction
# (dedup) and membership both a linear/O(n^2) scan using Botlish's existing
# generic value equality (core::value::equal). No hashing, no bitmap, no
# perfect hash: those are deferred, later-representation concerns (see the
# report's "Future specialization notes").
#
# Two root primitives, mirroring core/lists.tcl's naming convention (`_`
# rather than `-`, so source can spell them):
#
#   immutable_set_from_list(List[T]) -> ImmutableSet[T]
#       Construction: deduplicates by core::value::equal. Total whenever
#       equality itself is total for the members involved -- see the
#       EQUALITY note on Dedup below, which is an existing restriction of
#       core::value::equal (block/native/mutarray have no structural
#       equality), not a new failure mode this milestone invents.
#   immutable_set_contains(ImmutableSet, any) -> Bool
#       Membership: total for a valid ImmutableSet argument. A queried value
#       of a different kind, or simply absent, returns false -- never an
#       Error completion (spec items 19-20).

namespace eval core::immutableset {}

# ITEMS (a Tcl list of runtime values) deduplicated by core::value::equal,
# O(n^2), keeping first-occurrence order. May raise {CORE SEMANTIC EQUALITY}
# -- the same, pre-existing restriction core::value::equal already has for
# Block/Native/MutableArray operands -- if two or more members of that kind
# would need to be compared (a single such member, or a list whose only
# duplicates are of comparable kinds, never triggers this: see MINIMAL-
# IMMUTABLE-SET.md's "Deduplication semantics").
proc core::immutableset::Dedup {items} {
    set result {}
    foreach item $items {
        set seen 0
        foreach existing $result {
            if {[core::value::equal $existing $item]} {
                set seen 1
                break
            }
        }
        if {!$seen} {
            lappend result $item
        }
    }
    return $result
}

proc core::immutableset::fromList {l} {
    set items [core::value::items [core::value::expect list $l immutable_set_from_list]]
    return [core::value::immutableSet [Dedup $items]]
}

proc core::immutableset::contains {s v} {
    set items [core::value::immutableSetItems [core::value::expect immutableSet $s immutable_set_contains]]
    core::value::check $v
    foreach item $items {
        if {[core::value::equal $item $v]} {
            return [core::value::bool 1]
        }
    }
    return [core::value::bool 0]
}

# List[T] -> ImmutableSet[T]: -result-shape {immutable-set 0} is the generic
# native-metadata relationship hir/types.tcl's ordinary (non-specialization)
# inference already consults for `list`/`list_get`/`list_append`
# (MINIMAL-APPLIED-LIST-TYPES.md) -- no ImmutableSet-specific inference code,
# no source-level generic function.
core::native::register immutable_set_from_list -arity 1 -impl core::immutableset::fromList \
    -param-types {list} -result-type immutableSet -runtime {set-alloc structural-equality} \
    -result-shape {immutable-set 0} -context-free 1
core::native::register immutable_set_contains -arity 2 -impl core::immutableset::contains \
    -param-types {immutableSet any} -result-type bool -runtime structural-equality -context-free 1
