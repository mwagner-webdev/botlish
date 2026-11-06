# ownership.tcl -- recursive affine ownership, decided on the finite
# declaration graph (OWNED-RECURSION-DECLARATION-SUMMARY-MILESTONE-1.md).
#
#   hir::ownership::Recursion TYPE   => "" or {recursive STEPS HEAD}
#   hir::ownership::FieldCycle ID    => 1 if every value of ID would hold
#                                       itself through fields alone
#
# The rule (AFFINE-VALUES.md): an affine value is released by a static drop
# descriptor (hir::affine::Descriptor), a finite walk of its type. A type
# whose values nest affine values to any depth through a container -- a
# List, MutableVector or MutableArray element, which may be empty, so finite
# values of every depth exist -- has no such walk: it is a *recursive affine
# type*, AFFINE-CONTAINER-UNSUPPORTED. Stated over the type's ownership
# unfolding (its applied fields, anonymous struct fields and container
# elements, affine components only):
#
#   TYPE is a recursive affine type  iff  its unfolding has an infinite path
#   that crosses a container element infinitely often.
#
# An infinite path that ends in fields alone (`struct S: c: C, s: S`, or
# `g: G[List[T]]` in G[T]) describes no finite value -- every field is
# mandatory -- so it is no recursion of values: such a type is accepted, and
# its descriptor cuts the path where it starts to repeat (FieldCycle).
#
# Why this is a finite question
# -----------------------------
# The unfolding of an application is infinite whenever its declaration is
# recursive, and its types are all distinct when the recursion is
# non-uniform (`next: List[W[List[T]]]` meets W[C], W[List[C]], ...). But
# every type it meets is a declaration's field type with the slots of an
# enclosing application substituted. A walk of the unfolding is a pushdown
# walk over the declarations' field types: entering an application S[e]
# *pushes* a frame (S, its arguments e); reaching, inside S's fields, one of
# S's own slot variables *pops* back to the argument expression in the frame
# below. Two finite facts per declaration describe it:
#
#   through(S)  for each slot j: whether S holds slot j's argument at an
#               owned position through fields alone (0) and/or through a
#               container element (1) -- a matched push and pop, summarized
#               (Through: a least fixpoint over the declarations, since S
#               may hold its slot through another application, or through
#               itself: Node[T]'s children hold T too);
#   edges(S)    the applications S's fields reach at owned positions in S's
#               own frame -- through anonymous structs, container elements
#               and the through facts of the applications they pass -- each
#               with the argument expressions over S's slots and whether the
#               way to it crossed an element (Edges).
#
# A frame is abstracted by its declaration and the set of its slots whose
# arguments are affine: (S, A). That is exact for everything the question
# reads: an application's affinity is its declaration's own or a relevant
# slot's argument's (hir::structs::IsAffine's summary), and an edge's
# arguments' affinity is computed from A by substituting an affine probe
# (`coroutine`) for the slots in A and `any` for the others -- IsAffine
# itself, as the affinity summary reads it. The states (S, A) and the edges
# between them form a finite graph: at most 2^n states per declaration of n
# slots (n <= 2 in every program of the repository), whatever applications
# substitution would make.
#
# An infinite path of the unfolding never stays at a bounded frame depth:
# within one frame, the position only moves deeper into a finite field type,
# and every pop returns to a deeper position of the frame below. So it pushes
# frames it never pops, infinitely often, and two of them have the same
# state, the later inside the earlier -- a cycle of the state graph. The
# path crosses elements infinitely often exactly when such a cycle does; and
# a cycle whose states are affine (on a cycle every state owns every other,
# so all or none are) is a recursion of affine values. Hence:
#
#   TYPE is a recursive affine type  iff  a cycle of the state graph that
#   crosses an element, through affine states, is reachable from TYPE.
#
# Recursion computes it by one root walk of TYPE itself (its applications,
# with the through facts into its arguments) and, for each state the root
# reaches, the strongly connected components of the states reachable from it
# (Explore: Tarjan's algorithm, every answer remembered per state). A
# component is *bad* when one of its internal edges crosses an element; its
# states are affine (an unrestricted state owns nothing affine, so the walk
# never enters one). No depth, budget or application count decides it: a
# chain of ninety-six declarations is ninety-six states; W[List^96[C]] is one
# state of W, unrestricted.
#
# The witness
# -----------
# A diagnostic names a path (RecursionSteps' "OWNER.FIELD: TYPE" steps): the
# way from TYPE to a state of a bad component, then once around a cycle of
# that component through an element, found by a search of the finite state
# graph after the verdict (Witness), the steps of each edge instantiated with
# the arguments the path has reached so far. The search never decides
# anything: it reads the components Explore classified, and it walks each
# state at most twice (with and without a crossed element).
#
# Every fact here is the registry's: computed lazily, forgotten with the
# affinity facts (hir::structs::ForgetAffinity calls Forget), keyed by
# declaration identity, never stored in HIR. Counters are
# hir::summaries::Count's (ownership.*), structural evidence only.

namespace eval hir::ownership {
    # ID -> {{CROSSED STEPS ...} ...}: through(ID), one dict per slot in slot
    # order (Through). STEPS, a witness in ID's own slot variables, is set
    # when an entry is first found and never changed: the fixpoint grows
    # sets only, so it ends.
    variable through [dict create]
    variable running 0
    variable met {}
    # ID -> {{TARGET ARGS CROSSED STEPS} ...}: edges(ID) (Edges).
    variable edges [dict create]
    # STATE -> {affine 0|1 succ {{STATE CROSSED EDGE} ...} scc N bad 0|1
    # reach 0|1}: the state graph, classified (Explore).
    variable states [dict create]
    variable components 0
    # TYPE -> Recursion's answer.
    variable verdicts [dict create]
    # ID -> FieldCycle's answer.
    variable cycles [dict create]
    # The size (characters of a type term) past which a witness's arguments
    # are no longer instantiated (Witness): presentation only.
    variable witnessSize 2000
}

proc hir::ownership::Forget {} {
    variable through
    variable edges
    variable states
    variable verdicts
    variable cycles
    set through [dict create]
    set edges [dict create]
    set states [dict create]
    set verdicts [dict create]
    set cycles [dict create]
}

proc hir::ownership::Count {counter {by 1}} {
    hir::summaries::Count ownership.$counter $by
}

# ---------------------------------------------------------------------------
# The walk of a type expression in a frame

# The events of TYPE, a type expression in the frame of a declaration whose
# slots are SLOTS ({} for the root: TYPE is concrete, or its variables are
# free and unrestricted), reached with CROSSED (1 once the way to it crossed
# a container element): {push ID ARGS CROSSED STEPS} for every application
# it holds at an owned position in this frame, {pop INDEX CROSSED STEPS} for
# every one of the frame's slots it holds at one. STEPS lead from TYPE to
# the event ({OWNER FIELD FIELDTYPE} each: OWNER "" for an anonymous
# struct). Each event once (the first found, in field order). MEMO (the
# caller's variable) keeps one session's answers per (TYPE, CROSSED): a
# deeply nested argument is walked once, not once per way to it.
proc hir::ownership::Walk {slots type crossed memoVar} {
    upvar 1 $memoVar memo
    set key [list $type $crossed]
    if {[dict exists $memo $key]} {
        return [dict get $memo $key]
    }
    Count walks
    set events [WalkUncached $slots $type $crossed memo]
    dict set memo $key $events
    return $events
}

proc hir::ownership::WalkUncached {slots type crossed memoVar} {
    upvar 1 $memoVar memo
    set type [hir::types::Unrefined $type]
    if {[hir::types::IsImprint $type]} {
        set index [lsearch -exact $slots [lindex $type 1]]
        if {$index < 0} {
            # A free variable of the root: unrestricted, holds nothing.
            return {}
        }
        return [list [list pop $index $crossed {}]]
    }
    if {[llength $type] < 2} {
        return {}
    }
    switch -- [lindex $type 0] {
        list - mutvec - mutarray {
            # A container: every element is owned, and there may be none.
            # (A positional List's element type covers every position, as
            # the drop descriptor reads it.)
            return [Walk $slots [lindex $type 1] 1 memo]
        }
        struct {
            if {![hir::types::IsStruct $type]} {
                return {}
            }
            set events {}
            foreach {name t} [lindex $type 1] {
                lappend events {*}[Prefixed [Walk $slots $t $crossed memo] [list "" $name $t]]
            }
            return [Unique $events]
        }
        nstruct {
            set id [lindex $type 1]
            if {![hir::structs::declared $id]} {
                return {}
            }
            set arguments [Arguments $type]
            set events [list [list push $id $arguments $crossed {}]]
            set binding [Binding $id $arguments]
            set j 0
            foreach entry [Through $id] {
                # A matched push and pop: the application holds its slot j,
                # so what its argument holds is held here, in this frame.
                dict for {c steps} $entry {
                    set inner [Walk $slots [lindex $arguments $j] [expr {$crossed || $c}] memo]
                    if {$inner eq {}} continue
                    lappend events {*}[Prefixed $inner {*}[Substituted $steps $binding]]
                }
                incr j
            }
            return [Unique $events]
        }
    }
    # A coroutine handle or a C address (an affine root, owning nothing), a
    # function or coroutine type (a callable owns no value of its signature),
    # an ImmutableSet (it holds no affine member), an enum, a trait view (no
    # field stores one), a scalar, any.
    return {}
}

# EVENTS with the steps STEP... put before each event's own.
proc hir::ownership::Prefixed {events args} {
    if {$args eq {}} {
        return $events
    }
    return [lmap event $events {
        lset event end [concat $args [lindex $event end]]
        set event
    }]
}

# EVENTS without the later of two that differ by their steps only.
proc hir::ownership::Unique {events} {
    set seen [dict create]
    set result {}
    foreach event $events {
        set key [lrange $event 0 end-1]
        if {[dict exists $seen $key]} continue
        dict set seen $key 1
        lappend result $event
    }
    return $result
}

# The arguments of the application TYPE in slot order (a missing one is
# `any`, which holds no value), {} for a struct with no slots.
proc hir::ownership::Arguments {type} {
    set slots [hir::structs::slots [lindex $type 1]]
    if {$slots eq {}} {
        return {}
    }
    set arguments [lindex $type 2]
    while {[llength $arguments] < [llength $slots]} {
        lappend arguments any
    }
    return [lrange $arguments 0 [llength $slots]-1]
}

# {SLOT ARGUMENT ...} of declaration ID.
proc hir::ownership::Binding {id arguments} {
    set binding [dict create]
    foreach slot [hir::structs::slots $id] a $arguments {
        dict set binding $slot $a
    }
    return $binding
}

# STEPS with BINDING's arguments substituted for the slot variables they
# name (a witness of one frame read in another).
proc hir::ownership::Substituted {steps binding} {
    if {[dict size $binding] == 0} {
        return $steps
    }
    return [lmap step $steps {
        lassign $step owner name t
        if {$owner ne ""} {
            set owner [Apply $owner $binding]
        }
        list $owner $name [Apply $t $binding]
    }]
}

proc hir::ownership::Apply {type binding} {
    return [hir::types::canonical [hir::imprint::Substitute $type $binding]]
}

# ---------------------------------------------------------------------------
# through(ID): the matched pushes and pops (a least fixpoint)

# {{CROSSED STEPS ...} ...}: for each slot of struct ID, the ways ID holds
# its argument at an owned position -- CROSSED 0 through fields alone, 1
# through a container element -- each with a witness (steps in ID's slot
# variables); {} for an identity no declaration has.
proc hir::ownership::Through {id} {
    variable through
    if {[dict exists $through $id]} {
        return [dict get $through $id]
    }
    if {![hir::structs::declared $id]} {
        return {}
    }
    return [hir::summaries::Fixpoint ::hir::ownership::through ::hir::ownership::running \
        ::hir::ownership::met ::hir::ownership::ThroughOf ::hir::ownership::ThroughBottom $id]
}

proc hir::ownership::ThroughBottom {id} {
    return [lrepeat [llength [hir::structs::slots $id]] [dict create]]
}

# through(ID) its fields give, every application they hold read at its
# current through facts; an entry already found keeps its witness.
proc hir::ownership::ThroughOf {id} {
    variable through
    Count throughComputations
    set slots [hir::structs::slots $id]
    set result [dict getdef $through $id [ThroughBottom $id]]
    if {$slots eq {}} {
        return $result
    }
    set self [hir::structs::SelfType $id]
    set memo [dict create]
    foreach {name t} [hir::structs::fieldTypes $id] {
        foreach event [Prefixed [Walk $slots $t 0 memo] [list $self $name $t]] {
            if {[lindex $event 0] ne "pop"} continue
            lassign $event - index c steps
            if {![dict exists [lindex $result $index] $c]} {
                lset result $index [dict replace [lindex $result $index] $c $steps]
            }
        }
    }
    return $result
}

# ---------------------------------------------------------------------------
# edges(ID): the applications ID's frame pushes

# {{TARGET ARGS CROSSED STEPS} ...}: the applications struct ID's fields hold
# at owned positions in ID's own frame (Walk), ARGS over ID's slot
# variables, STEPS from ID's own type (its declaration at its slots).
proc hir::ownership::Edges {id} {
    variable edges
    if {[dict exists $edges $id]} {
        return [dict get $edges $id]
    }
    Count edgeComputations
    set slots [hir::structs::slots $id]
    set self [hir::structs::SelfType $id]
    set memo [dict create]
    set events {}
    foreach {name t} [hir::structs::fieldTypes $id] {
        lappend events {*}[Prefixed [Walk $slots $t 0 memo] [list $self $name $t]]
    }
    set result {}
    foreach event [Unique $events] {
        if {[lindex $event 0] ne "push"} continue
        lappend result [lrange $event 1 end]
    }
    dict set edges $id $result
    return $result
}

# ---------------------------------------------------------------------------
# The state graph

# The state of a frame of declaration ID whose arguments ARGUMENTS are
# concrete (or free variables).
proc hir::ownership::StateOf {id arguments} {
    set affine {}
    set i 0
    foreach a $arguments {
        if {[hir::types::IsAffine $a]} {
            lappend affine $i
        }
        incr i
    }
    return [list $id $affine]
}

# The probe binding of state STATE: an affine root for each slot whose
# argument is affine, `any` (which holds nothing) for the others.
proc hir::ownership::Probes {state} {
    lassign $state id affine
    set binding [dict create]
    set i 0
    foreach slot [hir::structs::slots $id] {
        dict set binding $slot [expr {$i in $affine ? "coroutine" : "any"}]
        incr i
    }
    return $binding
}

# The record of STATE, its successors computed (not yet classified).
proc hir::ownership::Node {state} {
    lassign $state id affine
    Count states
    set binding [Probes $state]
    set probe [lmap slot [hir::structs::slots $id] {dict get $binding $slot}]
    if {![hir::structs::IsAffine $id $probe]} {
        # Owns nothing affine: neither does anything it holds.
        return [dict create affine 0 succ {}]
    }
    set succ {}
    set k 0
    foreach edge [Edges $id] {
        lassign $edge target arguments c
        Count edges
        set next {}
        set i 0
        foreach a $arguments {
            if {[hir::types::IsAffine [Apply $a $binding]]} {
                lappend next $i
            }
            incr i
        }
        lappend succ [list [list $target $next] $c $k]
        incr k
    }
    return [dict create affine 1 succ $succ]
}

# Classifies every state reachable from ROOT (Tarjan's algorithm, iterative):
# its component, whether the component is bad (an internal edge crosses an
# element) and whether a bad component is reachable from it (reach). A state
# classified by an earlier call is complete: nothing new reaches back into
# its component.
proc hir::ownership::Explore {root} {
    variable states
    variable components
    if {[dict exists $states $root]} {
        return
    }
    set index 0
    set indices [dict create]
    set low [dict create]
    set onStack [dict create]
    set stack {}
    set nodes [dict create]
    set frames {}
    set Visit {
        set n [Node $v]
        dict set nodes $v $n
        dict set indices $v $index
        dict set low $v $index
        incr index
        lappend stack $v
        dict set onStack $v 1
        lappend frames [list $v 0]
    }
    set v $root
    eval $Visit
    while {[llength $frames] > 0} {
        lassign [lindex $frames end] v k
        set succ [dict get $nodes $v succ]
        if {$k < [llength $succ]} {
            lset frames end 1 [expr {$k + 1}]
            set w [lindex $succ $k 0]
            if {[dict exists $states $w]} {
                continue
            }
            if {![dict exists $indices $w]} {
                set parent $v
                set v $w
                eval $Visit
            } elseif {[dict exists $onStack $w]} {
                if {[dict get $indices $w] < [dict get $low $v]} {
                    dict set low $v [dict get $indices $w]
                }
            }
            continue
        }
        set frames [lrange $frames 0 end-1]
        if {[llength $frames] > 0} {
            set parent [lindex $frames end 0]
            if {[dict get $low $v] < [dict get $low $parent]} {
                dict set low $parent [dict get $low $v]
            }
        }
        if {[dict get $low $v] != [dict get $indices $v]} continue
        # A component, complete: its successors outside are classified.
        set members {}
        while 1 {
            set w [lindex $stack end]
            set stack [lrange $stack 0 end-1]
            dict unset onStack $w
            lappend members $w
            if {$w eq $v} break
        }
        incr components
        set inside [dict create]
        foreach m $members {
            dict set inside $m 1
        }
        set bad 0
        set reach 0
        foreach m $members {
            foreach s [dict get $nodes $m succ] {
                lassign $s w c
                if {[dict exists $inside $w]} {
                    if {$c} {
                        set bad 1
                    }
                } elseif {[dict get $states $w reach]} {
                    set reach 1
                }
            }
        }
        set reach [expr {$reach || $bad}]
        foreach m $members {
            dict set states $m [dict merge [dict get $nodes $m] \
                [dict create scc $components bad $bad reach $reach]]
        }
        Count components
    }
}

# ---------------------------------------------------------------------------
# The question

# "" when TYPE is no recursive affine type, else {recursive STEPS HEAD}:
# STEPS the witness path in TYPE's terms ({OWNER FIELD FIELDTYPE} each, the
# arguments substituted), HEAD the declaration of the state the path's cycle
# returns to -- the declaration of TYPE itself whenever a bad component
# holding a state of it is reachable (the type holds affine values of its own
# declaration in a container), else the first bad component's (TYPE holds a
# recursive affine type of another declaration).
proc hir::ownership::Recursion {type} {
    variable verdicts
    set type [hir::types::Unrefined $type]
    if {[dict exists $verdicts $type]} {
        Count verdictHits
        return [dict get $verdicts $type]
    }
    Count queries
    set result ""
    if {[hir::types::IsAffine $type]} {
        set roots [RootEdges $type]
        set bad 0
        foreach edge $roots {
            set state [lindex $edge 0]
            Explore $state
            if {[Reach $state]} {
                set bad 1
                break
            }
        }
        if {$bad} {
            set result [Witness $type $roots]
        }
    }
    if {![set ::hir::structs::summarizing]} {
        dict set verdicts $type $result
    }
    return $result
}

proc hir::ownership::Reach {state} {
    variable states
    return [dict get $states $state reach]
}

# The pushes of the root walk of TYPE: {STATE ARGS STEPS} each, ARGS the
# application's concrete arguments, STEPS from TYPE.
proc hir::ownership::RootEdges {type} {
    set memo [dict create]
    set result {}
    foreach event [Walk {} $type 0 memo] {
        if {[lindex $event 0] ne "push"} continue
        lassign $event - id arguments c steps
        lappend result [list [StateOf $id $arguments] $arguments $steps]
    }
    return $result
}

# The witness of the recursive affine type TYPE whose root pushes are ROOTS
# (Recursion's result).
proc hir::ownership::Witness {type roots} {
    variable states
    Count witnesses
    set prefers [list ""]
    if {[hir::types::IsNamedStruct $type]} {
        set prefers [list [lindex $type 1] ""]
    }
    # A path to a state of a bad component: one of TYPE's own declaration
    # when there is one, else any.
    foreach prefer $prefers {
        foreach edge $roots {
            Explore [lindex $edge 0]
            if {![Reach [lindex $edge 0]]} continue
            lassign [PathToHead [lindex $edge 0] $prefer] reached path
            if {$reached} {
                set found [list $edge $path]
                break
            }
        }
        if {[info exists found]} break
    }
    lassign $found root path
    lassign $root state arguments steps
    set headState $state
    if {$path ne {}} {
        set headState [lindex $path end 0]
    }
    set head [lindex $headState 0]
    set cycle [Cycle $headState]
    # Instantiate: each edge's steps in the frame's arguments, the frame's
    # arguments the edge's substituted. (Presentation only: arguments that
    # grow at every step -- `f0: D0[D0[U, T], List[T]]` doubles them -- are
    # shown, past a size, in each declaration's own terms instead.)
    variable witnessSize
    set id [lindex $state 0]
    set symbolic 0
    foreach move [concat $path $cycle] {
        lassign $move next c k
        if {!$symbolic && [string length $arguments] > $witnessSize} {
            set symbolic 1
        }
        if {$symbolic} {
            set binding [dict create]
        } else {
            set binding [Binding $id $arguments]
        }
        lassign [lindex [Edges $id] $k] target edgeArguments - edgeSteps
        lappend steps {*}[Substituted $edgeSteps $binding]
        if {!$symbolic} {
            set arguments [lmap a $edgeArguments {Apply $a $binding}]
        }
        set id $target
    }
    return [list recursive $steps $head]
}

# {1 PATH}: the edges {STATE CROSSED EDGE} of the first path (depth first,
# in edge order) from STATE through states that reach a bad component to a
# state of a bad component -- of declaration PREFER, unless PREFER is "" --
# PATH {} when STATE itself is one; {0 {}} when there is none.
proc hir::ownership::PathToHead {state prefer} {
    variable states
    set Head {
        expr {[dict get $states $s bad] && ($prefer eq "" || [lindex $s 0] eq $prefer)}
    }
    set s $state
    if {[eval $Head]} {
        return {1 {}}
    }
    set seen [dict create $state 1]
    set frames [list [list $state 0 {}]]
    while {[llength $frames] > 0} {
        lassign [lindex $frames end] v k path
        set succ [dict get $states $v succ]
        if {$k >= [llength $succ]} {
            set frames [lrange $frames 0 end-1]
            continue
        }
        lset frames end 1 [expr {$k + 1}]
        set move [lindex $succ $k]
        set s [lindex $move 0]
        if {[dict exists $seen $s] || ![dict get $states $s reach]} continue
        dict set seen $s 1
        set path [linsert $path end $move]
        if {[eval $Head]} {
            return [list 1 $path]
        }
        lappend frames [list $s 0 $path]
    }
    return {0 {}}
}

# The edges of the first cycle (depth first, in edge order) from STATE, in a
# bad component, back to it within its component, crossing an element.
proc hir::ownership::Cycle {state} {
    variable states
    set scc [dict get $states $state scc]
    set seen [dict create [list $state 0] 1]
    set frames [list [list $state 0 0 {}]]
    while {[llength $frames] > 0} {
        lassign [lindex $frames end] v crossed k path
        set succ [dict get $states $v succ]
        if {$k >= [llength $succ]} {
            set frames [lrange $frames 0 end-1]
            continue
        }
        lset frames end 2 [expr {$k + 1}]
        set move [lindex $succ $k]
        lassign $move w c
        if {![dict exists $states $w] || [dict get $states $w scc] != $scc} continue
        set x [expr {$crossed || $c}]
        set path [linsert $path end $move]
        if {$w eq $state && $x} {
            return $path
        }
        if {[dict exists $seen [list $w $x]]} continue
        dict set seen [list $w $x] 1
        lappend frames [list $w $x 0 $path]
    }
    error "internal compiler error: a bad component of the ownership graph without a crossing cycle through [lindex $state 0]"
}

# ---------------------------------------------------------------------------
# Field-only cycles: declarations with no finite value

# 1 if declaration ID reaches an application of itself through fields alone
# in its own frame -- an edge of crossed 0, possibly through other
# declarations' edges of crossed 0. Then every value of every application
# of ID would hold another such value through mandatory fields, without end:
# no finite value has the type, whatever its arguments (edges are the
# declaration's, not an application's). The drop descriptor walk cuts such
# a type where it meets its declaration again (hir::affine::Descriptor).
proc hir::ownership::FieldCycle {id} {
    variable cycles
    if {[dict exists $cycles $id]} {
        return [dict get $cycles $id]
    }
    if {![hir::structs::declared $id]} {
        return 0
    }
    set result 0
    set seen [dict create]
    set work [list $id]
    while {[llength $work] > 0 && !$result} {
        set d [lindex $work end]
        set work [lrange $work 0 end-1]
        foreach edge [Edges $d] {
            lassign $edge target - c
            if {$c} continue
            if {$target eq $id} {
                set result 1
                break
            }
            if {[dict exists $seen $target]} continue
            dict set seen $target 1
            lappend work $target
        }
    }
    dict set cycles $id $result
    return $result
}
