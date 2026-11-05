# summaries.tcl -- declaration summaries for the component analyses of
# parameterized nominal types (PARAMETERIZED-DECLARATION-SUMMARIES-
# MILESTONE-1.md).
#
# A parameterized struct declaration is a finite semantic object even when
# substituting its arguments again and again would make infinitely many
# distinct applications:
#
#   struct W[T]:
#       next: List[W[List[T]]]
#
# reaches W[C], W[List[C]], W[List[List[C]]], ... through its own field. A
# walk of a type's components that substitutes an application's arguments
# into its fields (hir::structs::AppliedFieldTypes) and recurses into what it
# finds follows that sequence: it ends only because the type bound cuts an
# unrestricted argument to `any` (hir::types::MakeApplied), which it never
# does to an affine one (cutting would erase the ownership it carries). So
# such walks are replaced here by a summary of each declaration, computed
# once, from which every application's answer is read with its own
# arguments' answers -- the architecture the affinity summary
# (hir::structs::AffinitySummary) and the slot positions
# (hir::structs::SlotPositions) already had:
#
#   P(S[A1, ..., An]) = own(S)  JOIN  contribution(S, i, P-class of Ai) ...
#
# Two algebras serve the analyses that have this shape:
#
#   classes  The property's answers are levels 0..L (join is max: a
#            disjunction, or the worst of three classes), and the answer a
#            slot gives depends on its argument only through a finite class
#            of the argument (Bearing's: `any`, not `any`, bearing). The
#            summary holds, for each slot and each class, the answer of S
#            applied to that class's probe at the slot and the neutral
#            argument at every other slot (each answer includes S's own).
#            An application's answer is the join of the summary's entries
#            at its arguments' classes.
#   union    The answers are sets (CarriedInto's error names), and a slot
#            contributes its argument's whole answer or nothing. The summary
#            holds S's own set (every slot neutral) and the slots whose
#            marker probe reaches the answer; an application's answer is the
#            own set and the answers of its relevant slots' arguments.
#
# The summary is computed from the property's own evaluator -- the walk of
# one declaration's applied fields the analysis always had (its `node`
# command), given the probes as arguments -- so there is no second statement
# of the property and no second substitution: a field type a slot sits deep
# in substitutes and bounds the probe exactly as it substitutes and bounds an
# argument. A nested application met while one declaration's node is
# evaluated is answered from its own summary (the evaluator's named-struct
# case is this framework), so every declaration is summarized by one least
# fixpoint over the declarations it reaches (Fixpoint): each starts at the
# property's bottom and is recomputed until none changes. The fixpoint
# terminates on the finite declaration graph whatever applications
# substitution would make, and an application's answer costs one summary
# read per nested application: no application is unfolded.
#
# Slot relevance is the property's own: Bearing reads an argument at a Fn
# argument position (is it `any`), Totality at a value position only,
# CarriedInto where an erased value's callables are. The framework shares the
# fixpoint, the tables, the invalidation and the counters, never one
# property's answers with another's.
#
# Summaries are facts of the struct registry they were computed for: kept
# per registration and forgotten with the affinity facts
# (hir::structs::ForgetAffinity calls Forget) whenever the declarations
# change -- the same lifetime and the same invalidation hook. They are never
# stored in HIR: a HIR read back (HIR text, interchange, the front-end cache)
# recomputes them from its declarations.
#
# The reason walk
# ---------------
# Totality and SendClass also explain a class that is not `total`: the path
# to the component that decides it, in field order (Components' format).
# That text is a walk of the applied fields, as it always was; the summary
# only decides the class and prunes the walk (a part whose class is `total`
# is never entered). A walk that would follow a non-uniform recursion forever
# (no reason in field order is ever reached) is stopped by Whistle: a
# declaration on an expansive cycle (Expansive) met a third time on the
# walk's path, each occurrence embedding the one before it (the arguments
# grew), is treated as met again. The class never depends on it.

namespace eval hir::summaries {
    # NAME -> {algebra classes|union neutral TYPE probes {TYPE ...}
    # node CMD marker NAME}: the registered properties (define).
    variable properties [dict create]
    # The names of the per-property tables live in this namespace:
    # facts.NAME (ID -> SUMMARY), running.NAME (1 while its fixpoint runs),
    # met.NAME (the declarations it met, in order).
    # Counters (structural evidence, never semantics): computations.NAME
    # (node evaluations inside fixpoints), hits.NAME (summaries read from
    # the table), applications.NAME (answers read from a summary), rounds
    # (fixpoint rounds), fixpoints (fixpoints run).
    variable counters [dict create]
    # The expansive declarations of the registry (Expansive), "" until
    # computed.
    variable expansive ""
    # Embedding answers of the current registry ({A B} -> 0|1).
    variable embeds [dict create]
    # Answers for whole applications, for the properties whose answer reads
    # nothing but the registry ({NAME KEY} -> answer: Remember, Recall):
    # a walk over nested applications asks again about every inner one.
    variable answers [dict create]
}

# Registers property NAME. OPTIONS:
#   -algebra classes|union
#   -neutral TYPE          the argument every other slot is given: one at
#                          which the property reads nothing (level 0, the
#                          empty set)
#   -probes {TYPE ...}     (classes) one representative argument per class,
#                          class 0 first: the class of an argument is the
#                          index the property's own classifier gives it
#   -marker TYPE           (union) the argument whose answer is exactly
#                          {MARKERNAME} (-marker-name)
#   -marker-name NAME
#   -node CMD              CMD ID ARGS: the property's answer for the named
#                          struct type {nstruct ID ARGS} ({nstruct ID} when
#                          ARGS is empty), from its applied fields; a nested
#                          application it meets is answered through this
#                          framework
proc hir::summaries::define {name args} {
    variable properties
    set spec [dict create algebra classes neutral any probes {} marker "" marker-name "" node ""]
    foreach {option value} $args {
        dict set spec [string range $option 1 end] $value
    }
    dict set properties $name $spec
    namespace eval ::hir::summaries [list variable facts.$name [dict create]]
    namespace eval ::hir::summaries [list variable running.$name 0]
    namespace eval ::hir::summaries [list variable met.$name {}]
}

# Forgets every summary (and the expansive declarations), whenever the
# declarations change: hir::structs::ForgetAffinity's hook.
proc hir::summaries::Forget {} {
    variable properties
    variable expansive
    variable embeds
    foreach name [dict keys $properties] {
        set ::hir::summaries::facts.$name [dict create]
    }
    set expansive ""
    set embeds [dict create]
    variable answers
    set answers [dict create]
}

# The answer remembered for KEY of property NAME (Remember), or "".
proc hir::summaries::Recall {name key} {
    variable answers
    return [dict getdef $answers [list $name $key] ""]
}

# Remembers ANSWER for KEY of property NAME, unless a fixpoint of NAME runs
# (its answers then are provisional); returns ANSWER.
proc hir::summaries::Remember {name key answer} {
    variable answers
    if {![Running $name]} {
        dict set answers [list $name $key] $answer
    }
    return $answer
}

proc hir::summaries::Count {counter {by 1}} {
    variable counters
    dict incr counters $counter $by
}

# The counters since the last ResetCounters (a dict).
proc hir::summaries::counters {} {
    variable counters
    return $counters
}

proc hir::summaries::ResetCounters {} {
    variable counters
    set counters [dict create]
}

# The least fixpoint of a declaration fact for declared struct ID and every
# declaration it reaches -- shared by the affinity summary, the slot
# positions and every property defined here. TABLE (ID -> fact), RUNNING (1
# while a fixpoint runs) and MET (the declarations it met, in order) are the
# fully qualified names of the variables that hold them; OF is the command
# that computes a declaration's fact from its fields (reading every struct
# they name at its current fact through the same table), BOTTOM the command
# that gives a declaration's starting fact. Each fact starts at BOTTOM and
# is recomputed until none changes; a declaration met while the fixpoint
# runs joins it (its current fact is the answer meanwhile); only a finished
# fixpoint's facts are kept.
proc hir::summaries::Fixpoint {table running met of bottom id} {
    upvar #0 $table facts $running inside $met ids
    set start [{*}$bottom $id]
    dict set facts $id $start
    lappend ids $id
    if {$inside} {
        return $start
    }
    set inside 1
    Count fixpoints
    try {
        set changed 1
        set first 1
        while {$changed} {
            set changed 0
            Count rounds
            if {$first} {
                # The first round meets every declaration ID reaches, in the
                # order its fields name them (ids grows while it is walked: a
                # declaration met is summarized in the same round).
                for {set i 0} {$i < [llength $ids]} {incr i} {
                    set d [lindex $ids $i]
                    set fact [{*}$of $d]
                    if {$fact ne [dict get $facts $d]} {
                        dict set facts $d $fact
                        set changed 1
                    }
                }
                set first 0
                continue
            }
            # Later rounds recompute the last met first: a declaration is
            # met after the one whose fields name it, so a chain of N
            # declarations settles in one round, not N (the fixpoint is the
            # same in any order; a round that still changes a fact -- a
            # cycle, or one more met -- is followed by another).
            for {set i [expr {[llength $ids] - 1}]} {$i >= 0} {incr i -1} {
                set d [lindex $ids $i]
                set fact [{*}$of $d]
                if {$fact ne [dict get $facts $d]} {
                    dict set facts $d $fact
                    set changed 1
                }
            }
        }
    } on error {message options} {
        # An unfinished fixpoint's facts may be too small: keep none.
        foreach d $ids {
            dict unset facts $d
        }
        return -options $options $message
    } finally {
        set inside 0
        set ids {}
    }
    return [dict get $facts $id]
}

# 1 while a fixpoint of property NAME runs: its answers are provisional.
proc hir::summaries::Running {name} {
    return [set ::hir::summaries::running.$name]
}

# The summary of declaration ID for property NAME: for the classes algebra
# {own LEVEL values {{LEVEL ...} ...}} (one row per slot, one entry per
# class), for the union algebra {own SET relevant {INDEX ...}}; "" for an
# identity no declaration has.
proc hir::summaries::Summary {name id} {
    upvar #0 ::hir::summaries::facts.$name facts
    if {[dict exists $facts $id]} {
        Count hits.$name
        return [dict get $facts $id]
    }
    if {![hir::structs::declared $id]} {
        return ""
    }
    return [Fixpoint ::hir::summaries::facts.$name ::hir::summaries::running.$name \
        ::hir::summaries::met.$name [list ::hir::summaries::Compute $name] \
        [list ::hir::summaries::Bottom $name] $id]
}

# The summary every declaration starts its fixpoint at: the property's
# bottom everywhere.
proc hir::summaries::Bottom {name id} {
    variable properties
    set spec [dict get $properties $name]
    set n [llength [hir::structs::slots $id]]
    if {[dict get $spec algebra] eq "union"} {
        return [dict create own {} relevant {}]
    }
    set row [lrepeat [llength [dict get $spec probes]] 0]
    return [dict create own 0 values [lrepeat $n $row]]
}

# The summary of declaration ID its fields give, every struct they name read
# at its current summary (Summary's fixpoint): the property's node command
# applied to the neutral argument at every slot, and to each probe at each
# slot.
proc hir::summaries::Compute {name id} {
    variable properties
    set spec [dict get $properties $name]
    set node [dict get $spec node]
    set n [llength [hir::structs::slots $id]]
    set neutral [lrepeat $n [dict get $spec neutral]]
    Count computations.$name
    set own [{*}$node $id $neutral]
    if {[dict get $spec algebra] eq "union"} {
        set marker [dict get $spec marker]
        set markerName [dict get $spec marker-name]
        set relevant {}
        for {set i 0} {$i < $n} {incr i} {
            Count computations.$name
            if {$markerName in [{*}$node $id [lreplace $neutral $i $i $marker]]} {
                lappend relevant $i
            }
        }
        return [dict create own [lsort -unique $own] relevant $relevant]
    }
    set values {}
    for {set i 0} {$i < $n} {incr i} {
        set row {}
        foreach probe [dict get $spec probes] {
            Count computations.$name
            lappend row [{*}$node $id [lreplace $neutral $i $i $probe]]
        }
        lappend values $row
    }
    return [dict create own $own values $values]
}

# The arguments of the named struct type TYPE in slot order: an
# application's own (canonical), a parameterized declaration named without
# arguments its slots' variables (the type its fields are written in), {}
# for a struct with no slots.
proc hir::summaries::Arguments {type} {
    set id [lindex $type 1]
    set slots [hir::structs::slots $id]
    if {$slots eq {}} {
        return {}
    }
    if {[llength $type] == 3} {
        # Each in the form a field holds it in once substituted
        # (hir::structs::AppliedFieldTypes canonicalizes: an application may
        # keep a refinement's declared name, `Small`, where a field holds its
        # normal form). A missing argument substitutes
        # nothing a value can be: `any`, as the affinity summary reads it.
        set arguments [lmap a [lindex $type 2] {
            # (A compound argument is canonical already: MakeApplied bounded
            # it, and substituting it re-bounds it at the same depth.)
            if {[hir::types::IsSpecific $a] || [catch {hir::types::canonical $a} c]} {
                string cat $a
            } else {
                set c
            }
        }]
        while {[llength $arguments] < [llength $slots]} {
            lappend arguments any
        }
        return $arguments
    }
    set constraints [hir::structs::slotConstraints $id]
    return [lmap slot $slots {hir::types::MakeImprint $slot [dict getdef $constraints $slot {}]}]
}

# The answer (a level) of property NAME (classes algebra) for the named
# struct type TYPE whose arguments have the classes CLASSES (in slot order,
# Arguments'): the join of the summary's entries at those classes ("" when
# no declaration has TYPE's identity).
proc hir::summaries::Level {name type classes} {
    set summary [Summary $name [lindex $type 1]]
    if {$summary eq ""} {
        return ""
    }
    Count applications.$name
    set level [dict get $summary own]
    foreach row [dict get $summary values] class $classes {
        set l [lindex $row $class]
        if {$l > $level} {
            set level $l
        }
    }
    return $level
}

# {OWN RELEVANT} of property NAME (union algebra) for the named struct type
# TYPE: its declaration's own set and the indices of the slots whose
# argument's whole answer joins it ("" when no declaration has TYPE's
# identity).
proc hir::summaries::Union {name type} {
    set summary [Summary $name [lindex $type 1]]
    if {$summary eq ""} {
        return ""
    }
    Count applications.$name
    return [list [dict get $summary own] [dict get $summary relevant]]
}

# ---------------------------------------------------------------------------
# Expansive declarations: the reason walk's termination (header)

# 1 if declaration ID lies on an expansive cycle of the slot graph: the
# graph whose nodes are the slots of the registry's declarations, with an
# edge from slot i of S to slot j of S' wherever a field type of S holds an
# application S'[..., A, ...] whose j-th argument A mentions S's i-th slot
# variable -- expansive when A is not that variable itself (the variable is
# nested in a larger type). An application of a declaration that is on no
# expansive cycle reaches finitely many applications through its fields,
# however deep its arguments (Kennedy and Pierce's finitary types); one on an
# expansive cycle may reach ever larger ones (`next: List[W[List[T]]]`).
proc hir::summaries::Expansive {id} {
    variable expansive
    if {$expansive eq ""} {
        set expansive [ExpansiveDeclarations]
    }
    return [dict exists $expansive $id]
}

# {ID 1 ...}: every declaration on an expansive cycle of the slot graph
# (Expansive), by Tarjan's strongly connected components.
proc hir::summaries::ExpansiveDeclarations {} {
    set edges [dict create]
    set expansiveEdges [dict create]
    dict for {id entry} $::hir::structs::registry {
        set slots [dict getdef $entry slots {}]
        if {$slots eq {}} continue
        foreach {field t} [dict get $entry types] {
            foreach application [Applications $t] {
                lassign $application target arguments
                for {set j 0} {$j < [llength $arguments]} {incr j} {
                    set a [lindex $arguments $j]
                    foreach variable [Variables $a] {
                        set i [lsearch -exact $slots $variable]
                        if {$i < 0} continue
                        set from [list $id $i]
                        set to [list $target $j]
                        dict lappend edges $from $to
                        if {!([hir::types::IsImprint $a] && [lindex $a 1] eq $variable)} {
                            dict set expansiveEdges [list $from $to] 1
                        }
                    }
                }
            }
        }
    }
    set result [dict create]
    if {[dict size $expansiveEdges] == 0} {
        return $result
    }
    set component [Components $edges]
    dict for {pair _} $expansiveEdges {
        lassign $pair from to
        if {[dict get $component $from] eq [dict get $component $to]} {
            set c [dict get $component $from]
            dict for {node k} $component {
                if {$k eq $c} {
                    dict set result [lindex $node 0] 1
                }
            }
        }
    }
    return $result
}

# The applications {ID ARGUMENTS} type T holds at any depth (its own
# included).
proc hir::summaries::Applications {t} {
    set result {}
    if {[hir::types::IsAppliedStruct $t]} {
        lappend result [list [lindex $t 1] [lindex $t 2]]
    }
    foreach part [Parts $t] {
        lappend result {*}[Applications $part]
    }
    return $result
}

# The imprint variables type T mentions, at any depth.
proc hir::summaries::Variables {t} {
    if {[hir::types::IsImprint $t]} {
        return [list [lindex $t 1]]
    }
    set result {}
    foreach part [Parts $t] {
        lappend result {*}[Variables $part]
    }
    return [lsort -unique $result]
}

# The parts of a type as a Tcl list: its elements, the one element of a
# list that holds one (an application's single argument, `{X}`), none for a
# word.
proc hir::summaries::Parts {t} {
    set n [llength $t]
    if {$n > 1} {
        return $t
    }
    if {$n == 1 && [lindex $t 0] ne $t} {
        return [list [lindex $t 0]]
    }
    return {}
}

# NODE -> component number of the directed graph EDGES (NODE -> {NODE ...}),
# Tarjan's algorithm (iterative: a graph's size is the registry's).
proc hir::summaries::Components {edges} {
    set nodes [dict create]
    dict for {from tos} $edges {
        dict set nodes $from 1
        foreach to $tos {
            dict set nodes $to 1
        }
    }
    set index 0
    set indices [dict create]
    set low [dict create]
    set onStack [dict create]
    set stack {}
    set component [dict create]
    set count 0
    foreach root [dict keys $nodes] {
        if {[dict exists $indices $root]} continue
        # Each frame: {NODE NEXT-SUCCESSOR-INDEX}.
        set frames [list [list $root 0]]
        dict set indices $root $index
        dict set low $root $index
        incr index
        lappend stack $root
        dict set onStack $root 1
        while {[llength $frames] > 0} {
            lassign [lindex $frames end] v k
            set successors [dict getdef $edges $v {}]
            if {$k < [llength $successors]} {
                lset frames end 1 [expr {$k + 1}]
                set w [lindex $successors $k]
                if {![dict exists $indices $w]} {
                    dict set indices $w $index
                    dict set low $w $index
                    incr index
                    lappend stack $w
                    dict set onStack $w 1
                    lappend frames [list $w 0]
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
            if {[dict get $low $v] == [dict get $indices $v]} {
                while 1 {
                    set w [lindex $stack end]
                    set stack [lrange $stack 0 end-1]
                    dict unset onStack $w
                    dict set component $w $count
                    if {$w eq $v} break
                }
                incr count
            }
        }
    }
    return $component
}

# 1 if the reason walk must not enter the named struct type TYPE from the
# path SEEN (the named struct types it is walking, outermost first): TYPE's
# declaration is expansive and the path already holds two earlier
# applications of it, each embedding the one before it and TYPE embedding the
# last (the arguments grew along an expansive cycle twice). A walk that goes
# on would meet ever larger applications; one that stops has already shown
# the cycle once more than a reason in field order needs (header).
proc hir::summaries::Whistle {type seen} {
    set id [lindex $type 1]
    if {![hir::types::IsAppliedStruct $type] || ![Expansive $id]} {
        return 0
    }
    set chain {}
    foreach s $seen {
        if {[hir::types::IsAppliedStruct $s] && [lindex $s 1] eq $id} {
            lappend chain $s
        }
    }
    # The longest chain ending in TYPE, each element embedding into the next.
    set next [list $type]
    set length 1
    for {set k [expr {[llength $chain] - 1}]} {$k >= 0} {incr k -1} {
        set s [lindex $chain $k]
        if {$s ne [lindex $next end] && [Embeds $s [lindex $next end]]} {
            lappend next $s
            incr length
            if {$length >= 3} {
                Count whistles
                return 1
            }
        }
    }
    return 0
}

# 1 if type A is homeomorphically embedded in type B: A is B, or A is
# embedded in a part of B, or A and B have the same constructor and arity
# and each part of A is embedded in the corresponding part of B (a type is a
# Tcl list: its first element names its constructor, a one-element word is a
# leaf).
proc hir::summaries::Embeds {a b} {
    variable embeds
    set key [list $a $b]
    if {[dict exists $embeds $key]} {
        return [dict get $embeds $key]
    }
    set result [EmbedsUncached $a $b]
    dict set embeds $key $result
    return $result
}

proc hir::summaries::EmbedsUncached {a b} {
    if {$a eq $b} {
        return 1
    }
    set pa [Parts $a]
    set pb [Parts $b]
    if {$pa ne {} && $pb ne {} && [llength $pa] == [llength $pb]
            && [llength $a] == [llength $b]} {
        set coupled 1
        foreach x $pa y $pb {
            if {![Embeds $x $y]} {
                set coupled 0
                break
            }
        }
        if {$coupled} {
            return 1
        }
    }
    foreach part $pb {
        if {[Embeds $a $part]} {
            return 1
        }
    }
    return 0
}
