# lib.tcl -- the candidate equality relations of EQUALITY-SEMANTIC-CENSUS.md,
# over the checker's static types, shared by inspect.tcl and reclassify.tcl.
# Sourced after compiler/compiler.tcl and surface/surface.tcl: it reads the
# compiler's own type queries (hir::types::*) and defines nothing the
# compiler reads.
#
# Every relation answers a question about two static types A and B under
# today's `==` (core::value::equal). They are deliberately separate,
# because they are not equivalent (EQUALITY-SEMANTIC-CENSUS.md, section 3):
#
#   eqcensus::Head A B      the runtime kinds and, for enums and structs,
#                           the declarations or field sets: the part of a
#                           value `==` reads before it looks inside it.
#                           head-equal | head-disjoint | head-unknown
#   eqcensus::Overlap A B   whether some value of A and some value of B are
#                           equal under `==` (and the comparison of that
#                           pair does not raise): overlap | disjoint |
#                           unknown. The witness of an overlap is reported
#                           (`[]`, `ok(...)`, ...).
#   eqcensus::Kinded A B    EQUALITY-SEMANTICS.md's census relation (its
#                           census.tcl's Relation, reproduced here): a
#                           collection pair whose elements are disjoint is
#                           `empty-only`, which that report rejects.
#   eqcensus::Structural A B  componentwise comparability: equal heads at
#                           every component position (section 11 of the
#                           report): compatible | incompatible | refused |
#                           unknown.
#   eqcensus::Related A B   the static subtyping relation the checker uses
#                           everywhere else (hir::types::subtype, glb):
#                           sub (A <: B), super (B <: A), meet (a
#                           representable glb), unrelated, unknown.
#
# and the totality of the pair under `==`, eqcensus::Defined A B:
#
#   total      no pair of values of A and B raises EQUALITY
#   partial    some pair raises and some does not
#   undefined  every pair raises
#   unknown    an operand fixes no kind (any, an imprint variable, ...)
#
# computed from the value structure `==` walks: kinds are compared first, a
# List compares lengths before elements and stops at the first unequal
# pair, a Result compares tags before payloads, a struct compares shapes
# before fields, a set compares cardinalities before members
# (core::value::equal; native/src/runtime/ops.rs's `equal`).

namespace eval eqcensus {}

# 1 if TYPE fixes no runtime kind for this module's purposes.
proc eqcensus::Unknown {type} {
    set kind [hir::types::kindOf $type]
    return [expr {$type eq "any" || $kind eq "" || $kind eq "any"}]
}

# The element type of a List or ImmutableSet type ("" if it has none).
proc eqcensus::Element {type} {
    set type [hir::types::Unrefined $type]
    if {[hir::types::IsSet $type]} {
        return [lindex $type 1]
    }
    if {[hir::types::IsList $type]} {
        return [hir::types::elementOf $type]
    }
    return ""
}

# A Result type's {OK ERR} payload types, or "" for a bare result kind.
proc eqcensus::ResultParts {type} {
    if {[lindex $type 0] eq "result" && [llength $type] == 3} {
        return [lrange $type 1 2]
    }
    return ""
}

proc eqcensus::IsCallableType {type} {
    return [expr {[hir::types::IsFn $type] || [hir::types::IsExactBlock $type]
        || [hir::types::IsExactNative $type] || [lindex $type 0] in {block native}}]
}

# head-equal | head-disjoint | head-unknown, and why.
proc eqcensus::Head {a b} {
    if {[Unknown $a] || [Unknown $b]} {
        return {head-unknown ""}
    }
    set ka [hir::types::kindOf $a]
    set kb [hir::types::kindOf $b]
    if {$ka ne $kb} {
        return [list head-disjoint "kinds $ka and $kb"]
    }
    switch -- $ka {
        enum {
            if {[lindex $a 1] ne [lindex $b 1]} {
                return [list head-disjoint "enums [lindex $a 1] and [lindex $b 1]"]
            }
        }
        struct {
            if {![hir::types::IsStructLike $a] || ![hir::types::IsStructLike $b]} {
                return {head-unknown "a bare struct kind"}
            }
            set sa [hir::types::StructShape $a]
            set sb [hir::types::StructShape $b]
            if {$sa ne $sb} {
                return [list head-disjoint "struct shapes {$sa} and {$sb}"]
            }
        }
    }
    return {head-equal ""}
}

# The interval of an integer type, {} if it has none.
proc eqcensus::IntFacts {type} {
    if {[catch {core::type::integerFacts $type} facts]} {
        return {}
    }
    return $facts
}

# overlap | disjoint | unknown, and a witness or a reason. Values of A and
# B can be equal under `==` without the comparison raising.
proc eqcensus::Overlap {a b {depth 0}} {
    if {$depth > 6} {
        return {unknown "too deep"}
    }
    if {$a eq "never" || $b eq "never"} {
        return {disjoint "no value"}
    }
    foreach t [list $a $b] {
        if {[IsCallableType $t]} {
            return {disjoint "a callable is equal to nothing (== raises EQUALITY)"}
        }
        set k [hir::types::kindOf $t]
        if {$k in $::core::value::incomparable} {
            return [list disjoint "a $k is equal to nothing (== raises EQUALITY)"]
        }
    }
    lassign [Head $a $b] head why
    if {$head eq "head-unknown"} {
        return [list unknown $why]
    }
    if {$head eq "head-disjoint"} {
        return [list disjoint $why]
    }
    set kind [hir::types::kindOf $a]
    switch -- $kind {
        list - immutableSet {
            set ea [Element $a]
            set eb [Element $b]
            set ua [hir::types::Unrefined $a]
            set ub [hir::types::Unrefined $b]
            # A List length refinement: two different exact lengths share no
            # value, and an empty value needs both to admit length 0.
            set la [ExactLength $a]
            set lb [ExactLength $b]
            if {$la ne "" && $lb ne "" && $la != $lb} {
                return [list disjoint "lengths $la and $lb"]
            }
            if {($la eq "" || $la == 0) && ($lb eq "" || $lb == 0)} {
                return [list overlap "the empty [expr {$kind eq "list" ? "List" : "set"}]"]
            }
            if {$ea eq "" || $eb eq ""} {
                return {unknown "a bare collection kind"}
            }
            lassign [Overlap $ea $eb [expr {$depth + 1}]] class why
            if {$class eq "overlap"} {
                return [list overlap "lists of $why"]
            }
            return [list $class "elements: $why"]
        }
        struct {
            set fields [lrange [hir::types::StructShape $a] 1 end]
            set witness {}
            foreach field $fields {
                set fa [hir::types::StructField $a $field]
                set fb [hir::types::StructField $b $field]
                if {$fa eq "" || $fb eq ""} {
                    return [list unknown "field $field has no type"]
                }
                lassign [Overlap $fa $fb [expr {$depth + 1}]] class why
                if {$class ne "overlap"} {
                    return [list $class "field $field: $why"]
                }
                lappend witness "$field: $why"
            }
            return [list overlap "{[join $witness {, }]}"]
        }
        result {
            set pa [ResultParts $a]
            set pb [ResultParts $b]
            if {$pa eq "" || $pb eq ""} {
                return {unknown "a bare Result kind"}
            }
            set worst disjoint
            foreach tag {ok error} i {0 1} {
                lassign [Overlap [lindex $pa $i] [lindex $pb $i] [expr {$depth + 1}]] class why
                if {$class eq "overlap"} {
                    return [list overlap "$tag($why)"]
                }
                if {$class eq "unknown"} {
                    set worst unknown
                }
            }
            return [list $worst "neither variant's payloads share a value"]
        }
        int {
            set fa [IntFacts $a]
            set fb [IntFacts $b]
            if {$fa ne {} && $fb ne {}
                    && ([dict get $fa max] < [dict get $fb min] || [dict get $fb max] < [dict get $fa min])} {
                return [list disjoint "domains [hir::types::show $a] and [hir::types::show $b] do not meet"]
            }
            return {overlap "an Int both admit"}
        }
    }
    return [list overlap "a $kind"]
}

# The exact length of a List length refinement, else "".
proc eqcensus::ExactLength {type} {
    if {[hir::refinements::IsRefined $type] && [hir::refinements::IsApplied [hir::refinements::Family $type]]} {
        set facts [lindex $type 2]
        if {[dict exists $facts length]} {
            return [dict get $facts length]
        }
    }
    return ""
}

# EQUALITY-SEMANTICS.md's census relation (its census.tcl's Relation).
proc eqcensus::Kinded {a b} {
    foreach t [list $a $b] {
        if {[lindex [hir::types::Totality equality $t] 0] eq "none"} {
            return [list refused [lindex [hir::types::Totality equality $t] 1]]
        }
    }
    lassign [Head $a $b] head why
    if {$head eq "head-unknown"} {
        return [list unknown $why]
    }
    if {$head eq "head-disjoint"} {
        return [list disjoint $why]
    }
    switch -- [hir::types::kindOf $a] {
        struct {
            foreach field [lrange [hir::types::StructShape $a] 1 end] {
                set fa [hir::types::StructField $a $field]
                set fb [hir::types::StructField $b $field]
                if {$fa eq "" || $fb eq ""} continue
                lassign [Kinded $fa $fb] class why
                if {$class in {disjoint empty-only}} {
                    return [list disjoint "field $field: $why"]
                }
            }
            if {[hir::types::IsAppliedStruct $a] && [hir::types::IsAppliedStruct $b]} {
                foreach x [hir::types::StructArgs $a] y [hir::types::StructArgs $b] {
                    lassign [Kinded $x $y] class why
                    if {$class in {disjoint empty-only}} {
                        return [list disjoint "type arguments: $why"]
                    }
                }
            }
        }
        list - immutableSet {
            set ea [Element $a]
            set eb [Element $b]
            if {$ea eq "" || $eb eq "" || $ea eq "never" || $eb eq "never"} {
                return {compatible ""}
            }
            lassign [Kinded $ea $eb] class why
            if {$class in {disjoint empty-only}} {
                return [list empty-only "elements: $why"]
            }
            if {$class eq "unknown"} {
                return {unknown "an element type fixes no kind"}
            }
        }
        int {
            if {[lindex [Overlap $a $b] 0] eq "disjoint"} {
                return [list disjoint "integer domains do not meet"]
            }
        }
    }
    return {compatible ""}
}

# compatible | incompatible | refused | unknown: the componentwise relation
# EQUALITY-SEMANTIC-CENSUS.md recommends (section 11, "structural
# comparability"). Two types are compatible when their heads are equal
# (Head) and every pair of component positions -- List elements, set
# members, struct fields (an application's fields with its arguments
# substituted, so a slot no field names takes no part) -- is compatible.
# Integer domains and refinements are knowledge about a value of their
# carrier, never a different kind: Small and Big are compatible. A `never`
# component (the element of the empty List's type) is compatible with
# anything; an unknown component makes the pair unknown unless another one
# is incompatible. refused: an operand's top-level kind has no equality at
# all (a callable, a MutableArray, ...).
proc eqcensus::Structural {a b {depth 0}} {
    if {$depth > 6} {
        return {unknown "too deep"}
    }
    if {$a eq "never" || $b eq "never"} {
        return {compatible ""}
    }
    foreach t [list $a $b] {
        if {[IsCallableType $t] || [hir::types::kindOf $t] in $::core::value::incomparable} {
            return [list refused "a top-level [hir::types::show $t]"]
        }
    }
    lassign [Head $a $b] head why
    if {$head eq "head-unknown"} {
        return [list unknown $why]
    }
    if {$head eq "head-disjoint"} {
        return [list incompatible $why]
    }
    set worst compatible
    set reason ""
    switch -- [hir::types::kindOf $a] {
        list - immutableSet {
            set ea [Element $a]
            set eb [Element $b]
            if {$ea eq "" || $eb eq ""} {
                return {unknown "a bare collection kind"}
            }
            lassign [Structural $ea $eb [expr {$depth + 1}]] class why
            if {$class eq "refused"} {
                # A refused element kind: the collections still compare
                # when empty or of different sizes (partial, Defined).
                return {compatible ""}
            }
            return [list $class [expr {$why eq "" ? "" : "elements: $why"}]]
        }
        struct {
            foreach field [lrange [hir::types::StructShape $a] 1 end] {
                set fa [hir::types::StructField $a $field]
                set fb [hir::types::StructField $b $field]
                if {$fa eq "" || $fb eq ""} {
                    set worst unknown
                    continue
                }
                lassign [Structural $fa $fb [expr {$depth + 1}]] class why
                switch -- $class {
                    incompatible { return [list incompatible "field $field: $why"] }
                    unknown { set worst unknown; set reason "field $field: $why" }
                }
            }
        }
    }
    return [list $worst $reason]
}

# The checker's subtyping relation between A and B.
proc eqcensus::Related {a b} {
    if {[Unknown $a] || [Unknown $b]} {
        return unknown
    }
    if {[hir::types::subtype $a $b]} {
        return [expr {[hir::types::subtype $b $a] ? "same" : "sub"}]
    }
    if {[hir::types::subtype $b $a]} {
        return super
    }
    if {[hir::types::glb $a $b] ne "" || [hir::types::lub $a $b] ni {any "" struct list immutableSet result}} {
        return meet
    }
    return unrelated
}

# total | partial | undefined | unknown for `==` of a value of A with a
# value of B, and why: the value structure core::value::equal walks.
proc eqcensus::Defined {a b {depth 0}} {
    if {$depth > 6} {
        return {unknown "too deep"}
    }
    if {$a eq "never" || $b eq "never"} {
        return {total "no value"}
    }
    foreach t [list $a $b] {
        if {[IsCallableType $t] || [hir::types::kindOf $t] in $::core::value::incomparable} {
            return [list undefined "a top-level [hir::types::show $t] is refused before anything is compared"]
        }
    }
    set ta [lindex [hir::types::Totality equality $a] 0]
    set tb [lindex [hir::types::Totality equality $b] 0]
    if {$ta eq "total" && $tb eq "total"} {
        return {total ""}
    }
    if {[Unknown $a] || [Unknown $b]} {
        return {unknown "an operand fixes no kind"}
    }
    lassign [Head $a $b] head why
    if {$head eq "head-disjoint"} {
        # Different kinds or shapes: `==` answers false before it looks
        # inside either value.
        return [list total "heads differ ($why): false before any component is compared"]
    }
    if {$head eq "head-unknown"} {
        return [list unknown $why]
    }
    switch -- [hir::types::kindOf $a] {
        list - immutableSet {
            set ea [Element $a]
            set eb [Element $b]
            if {$ea eq "" || $eb eq ""} {
                return {unknown "a bare collection kind"}
            }
            lassign [Defined $ea $eb [expr {$depth + 1}]] class why
            if {$class in {total unknown}} {
                return [list $class $why]
            }
            # The empty collections compare (true), different lengths compare
            # (false): never undefined for every pair.
            return [list partial "empty or differently sized values compare; elements: $class ($why)"]
        }
        struct {
            set fields [lrange [hir::types::StructShape $a] 1 end]
            set worst total
            set reasons {}
            foreach field $fields {
                set fa [hir::types::StructField $a $field]
                set fb [hir::types::StructField $b $field]
                lassign [Defined $fa $fb [expr {$depth + 1}]] class why
                if {$class eq "undefined"} {
                    # An undefined field is still reached only if every
                    # field before it is equal (slot order).
                    set class [expr {[llength $reasons] == 0 ? "undefined" : "partial"}]
                }
                lappend reasons "$field: $class"
                switch -- $class {
                    undefined { return [list undefined "field $field: $why"] }
                    partial { set worst partial }
                    unknown { if {$worst eq "total"} { set worst unknown } }
                }
            }
            return [list $worst [join $reasons {, }]]
        }
        result {
            set pa [ResultParts $a]
            set pb [ResultParts $b]
            if {$pa eq "" || $pb eq ""} {
                return {unknown "a bare Result kind"}
            }
            # Different tags compare false without looking at the payload.
            set classes {}
            foreach i {0 1} {
                lappend classes [lindex [Defined [lindex $pa $i] [lindex $pb $i] [expr {$depth + 1}]] 0]
            }
            if {$classes eq {total total}} {
                return {total ""}
            }
            if {"unknown" in $classes} {
                return {unknown "a payload of no fixed kind"}
            }
            return [list partial "payloads: ok $classes; a tag mismatch is false without comparing payloads"]
        }
    }
    return [list unknown "Totality says [lindex [hir::types::Totality equality $a] 0]/[lindex [hir::types::Totality equality $b] 0]"]
}
