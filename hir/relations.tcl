# relations.tcl -- relational facts: what the compiler knows of how two
# particular values are related, which neither value's type states
# (PROVEN-COLLECTION-REORDERING.md).
#
#   hir::relations::verify HIRVAR        diagnostics, part of hir::CheckOnce
#   hir::relations::Contracts HIR        the relational contracts of HIR's
#                                        functions: block -> row
#   hir::relations::proven HIR           the calls whose required relation
#                                        the last verify proved (tests)
#
# The one relation is SameMembers(A, B): the members of value A are exactly
# the members of value B -- a map's members are its keys, a set's its
# elements. It says nothing about order (two ordered sets with the same
# members may iterate differently) and nothing about identity (two
# independent copies have the same members). It is no scalar refinement:
# `MutableSet[K]` says which values may be members, never which collection's
# members they are, and the fact belongs to neither value's type. Equal
# lengths are not equal members; neither is one set's members all being
# another's.
#
# Contracts
# ---------
# Where the fact comes from, and who needs it, is part of an operation's
# contract, never read from its body (an implementation accident is no API).
# The table below states the contracts of the standard library's order
# operations, by the functions' declaration identities (the module's own
# binding of each, resolved to its block: Contracts); nothing else mints,
# needs or preserves the fact:
#
#   mints I        the call's result has the members of argument I, as the
#                  call read it
#   requires {I J} the call is admitted only where argument I is known to
#                  have the members argument J (a place) has when the call
#                  runs (REORDER-NOT-PROVEN otherwise)
#   preserves I    the call changes the place argument I in place without
#                  changing its members (an order-only mutation): every
#                  relation of the place survives it
#
# A row also names, for the diagnostic, what the members of argument J are
# called (keys, elements) and the operations that establish the fact.
#
# The analysis
# ------------
# Each function body (and the top-level code) holding a call that requires
# a relation is walked once, forward, in evaluation order, with a state that
# gives every place -- a binding and a field path from it
# (hir::mutvec::Path) holding a tracked collection -- a *members token*:
# two places or values with one token have the same members. A value's
# token is its place's when it is read (a copy has the members of what it
# copies), the minted argument's for a minting call, the fields' for a
# struct literal; any other value has an unknown token (a call's result,
# an element read out of a List, a parameter, a capture: no relation
# crosses a function boundary but by a contract). A place's token is an
# explicit one (the value it was bound to) or the implicit {v PATH STAMP}:
# "PATH's value since the last change of it (or of a place it overlaps)
# with STAMP, 0 for none".
#
# Invalidation: a call that may change a place in place -- the receiver of
# a mutating collection operation, a place argument (PLACE-PARAMETERS.md:
# a function may change anything under the place) -- gives the place and
# every place overlapping it a fresh stamp, unless its contract says it
# preserves that argument's members (reorder). A place rooted at a context
# parameter also changes at every call that may run code changing the
# installed context (hir::cardinality::ContextSite). A read-only operation
# (length, contains, at, a loop over the collection) changes nothing.
#
# Control flow: the two branches of an `if` (one, when its condition is
# decided: hir::types::KnownOutcome) and the handled call and its handlers
# are walked from the state before them, and joined: two places (or a
# place and an `if`'s or a handled call's value) share a token after the
# join exactly when they shared one on every completing path -- the token
# itself when it is the same on every path, else a fresh one (never one of
# the incoming ones) shared by exactly the places that agreed. A relation
# true on one path only is lost. A path that cannot complete (return, fail, break,
# continue, unreachable code) contributes nothing. A handler is entered
# with every place the handled call may change already changed. A loop's
# body is walked once, entered with every place changed anywhere in the
# loop given a fresh stamp (a value of one iteration never survives into
# the next but through a place), and the state after the loop gives them
# fresh stamps again. Nothing is optimistic: a relation is kept only where
# it holds on every path, and lost wherever it may not.
#
# The relation is compile-time knowledge only: it changes no code, and a
# proven call runs no check (the operation trusts the proof that admitted
# it).

namespace eval hir::relations {
    # The relational contracts of the standard library's order operations
    # (PROVEN-COLLECTION-REORDERING.md), by declaration identity.
    variable contracts {
        std::mutable_map::order {mints 0}
        std::mutable_map::validate_order {mints 0}
        std::mutable_map::reorder {requires {1 0} preserves 0 members keys
            snapshot order validator validate_order error std::mutable_map::OrderMismatch}
        std::mutable_set::order {mints 0}
        std::mutable_set::validate_order {mints 0}
        std::mutable_set::reorder {requires {1 0} preserves 0 members elements
            snapshot order validator validate_order error std::mutable_set::OrderMismatch}
    }
    # The collection structs whose members the relation tracks: a value of
    # one of them is a *leaf* (Leaves), by declaration identity.
    variable collections {std::mutable_map::MutableMap std::mutable_set::MutableSet}
    # Field depth to which a struct's tracked leaves are followed.
    variable maxDepth 4
    # The walk under way: the next fresh stamp, the break values of the
    # loops being walked, the context parameters of the invocation.
    variable next 0
    variable breaks [dict create]
    variable contextRoots {}
    # Leaves, memoized by type for one verify: a type's leaves are read
    # from the struct registry, which is the compilation's (COMPILATION-
    # ISOLATION.md: another program's struct of one name has other fields).
    variable leaves [dict create]
    # The calls whose required relation the last verify proved.
    variable provenCalls {}
}

# The contracts of HIR's functions: a dict, block ExprId -> row (the
# `contracts` table's), for each row whose function the program's modules
# declare.
proc hir::relations::Contracts {hir} {
    variable contracts
    set result [dict create]
    if {![dict exists $hir modules]} {
        return $result
    }
    dict for {name row} $contracts {
        set at [string last :: $name]
        set ns [string range $name 0 [expr {$at - 1}]]
        if {![dict exists $hir modules $ns]} continue
        set scope [dict get $hir modules $ns]
        set b [dict getdef $hir scopes $scope names $name ""]
        if {$b eq ""} continue
        set by [dict get $hir bindings $b declaredBy]
        if {$by eq "" || ![dict exists $hir exprs $by] || [dict get $hir exprs $by kind] ne "bind"} continue
        set block [dict get $hir exprs $by value]
        if {[dict get $hir exprs $block kind] ne "block"} continue
        dict set result $block [dict merge [dict create name $name] $row]
    }
    return $result
}

# The calls the last verify proved (their required relation held).
proc hir::relations::proven {} {
    variable provenCalls
    return $provenCalls
}

proc hir::relations::verify {hirVar} {
    upvar 1 $hirVar hir
    variable provenCalls
    variable leaves
    set provenCalls {}
    set leaves [dict create]
    set contracts [Contracts $hir]
    set requiring 0
    dict for {block row} $contracts {
        if {[dict exists $row requires]} {
            set requiring 1
        }
    }
    if {!$requiring} {
        return
    }
    # The invocations holding a reachable call that requires a relation.
    set units [dict create]
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "call" || ![dict get $node reachable]} continue
        lassign [dict get $node target] kind block
        if {$kind ne "block" || ![dict exists $contracts $block requires]} continue
        dict set units [dict get $hir scopes [dict get $node scope] invocation] 1
    }
    if {[dict size $units] == 0} {
        return
    }
    # (ContextSite's memo is keyed by the HIR's shape, which another build
    # of the same program can share.)
    hir::cardinality::resetCache
    foreach inv [dict keys $units] {
        Walk hir $inv $contracts
    }
}

# Walks invocation INV ("" the top-level code) once, diagnosing every call
# whose required relation is not proven.
proc hir::relations::Walk {hirVar inv contracts} {
    upvar 1 $hirVar hir
    variable next
    variable breaks
    variable contextRoots
    set next 0
    set breaks [dict create]
    if {$inv eq ""} {
        set body [dict get $hir roots]
    } else {
        set body [dict get $hir exprs $inv body]
    }
    set contextRoots [ContextRoots $hir $body]
    set state [dict create tokens [dict create] kills [dict create]]
    Seq hir $contracts state $body
}

# The context parameters (bindings bound to a context load) the code BODY
# reads, outside the functions defined in it.
proc hir::relations::ContextRoots {hir body} {
    set result [dict create]
    set work $body
    while {$work ne {}} {
        set work [lassign $work e]
        set node [dict get $hir exprs $e]
        if {[dict get $node kind] eq "block"} continue
        if {[dict get $node kind] eq "ref" && [dict get $node binding] ne ""
                && [hir::mutvec::IsContextParam $hir [dict get $node binding]]} {
            dict set result [dict get $node binding] 1
        }
        lappend work {*}[hir::children $hir $e]
    }
    return [dict keys $result]
}

# ---------------------------------------------------------------------------
# Tokens and places
#
# A place is a flat list {BINDING FIELD...}; a value's members are an
# *abstract value*: a dict, leaf path ({FIELD...}, {} for the value itself)
# -> token, holding the tokens known (a missing leaf is unknown).

proc hir::relations::Fresh {} {
    variable next
    return [list n [incr next]]
}

# 1 if places P and Q may hold one collection: the same binding, one path a
# prefix of the other.
proc hir::relations::Overlap {p q} {
    set n [expr {min([llength $p], [llength $q])}]
    return [expr {[lrange $p 0 [expr {$n - 1}]] eq [lrange $q 0 [expr {$n - 1}]]}]
}

# The members token of place PATH in STATE.
proc hir::relations::Read {state path} {
    if {[dict exists $state tokens $path]} {
        return [dict get $state tokens $path]
    }
    set stamp 0
    dict for {k s} [dict get $state kills] {
        if {$s > $stamp && [Overlap $k $path]} {
            set stamp $s
        }
    }
    return [list v $path $stamp]
}

# STATE with place PATH (and every place overlapping it) changed.
proc hir::relations::Kill {stateVar path} {
    upvar 1 $stateVar state
    variable next
    dict for {k t} [dict get $state tokens] {
        if {[Overlap $k $path]} {
            dict unset state tokens $k
        }
    }
    dict set state kills $path [incr next]
}

# The place path of expression E as a flat list, or "".
proc hir::relations::PlaceOf {hir e} {
    set path [hir::mutvec::Path $hir $e]
    if {$path eq ""} {
        return ""
    }
    return [concat [list [lindex $path 0]] [lindex $path 1]]
}

# The leaf paths of a value of TYPE: {{}} for a tracked collection, the
# fields' leaves (prefixed with the field) for a struct, {} otherwise.
proc hir::relations::Leaves {type {depth 0}} {
    variable leaves
    variable collections
    variable maxDepth
    if {$depth == 0 && [dict exists $leaves $type]} {
        return [dict get $leaves $type]
    }
    set result {}
    if {[hir::types::IsNamedStruct $type] && [lindex $type 1] in $collections} {
        set result [list {}]
    } elseif {$depth < $maxDepth && [hir::types::IsStructLike $type]} {
        if {[hir::types::IsStruct $type]} {
            set fields [lindex $type 1]
        } elseif {[hir::types::IsAppliedStruct $type]} {
            set fields [hir::structs::AppliedFieldTypes $type]
        } elseif {[catch {hir::structs::fieldTypes [lindex $type 1]} fields]} {
            set fields {}
        }
        foreach {name t} $fields {
            foreach sub [Leaves $t [expr {$depth + 1}]] {
                lappend result [linsert $sub 0 $name]
            }
        }
    }
    if {$depth == 0} {
        dict set leaves $type $result
    }
    return $result
}

# The abstract value of a read of place PATH whose static type is TYPE.
proc hir::relations::ReadValue {state path type} {
    set value [dict create]
    foreach leaf [Leaves $type] {
        dict set value $leaf [Read $state [concat $path $leaf]]
    }
    return $value
}

# The token after a join of a place or value leaf whose tokens on the two
# incoming paths are X and Y (PAIRS: the join's tokens so far, by {X Y}):
# X when they are equal; otherwise the token the join already gave the pair
# -- what had one token on both paths has one after -- or a fresh one,
# which it then gives the pair.
proc hir::relations::JoinToken {pairsVar x y} {
    upvar 1 $pairsVar pairs
    if {$x eq $y} {
        return $x
    }
    set pair [list $x $y]
    if {![dict exists $pairs $pair]} {
        dict set pairs $pair [Fresh]
    }
    return [dict get $pairs $pair]
}

# The abstract value after a join of the abstract values A and B: a leaf
# both know, with JoinToken's token (PAIRS, the state join's).
proc hir::relations::JoinValue {a b {pairsVar ""}} {
    if {$pairsVar ne ""} {
        upvar 1 $pairsVar pairs
    } else {
        set pairs [dict create]
    }
    set result [dict create]
    dict for {leaf token} $a {
        if {[dict exists $b $leaf]} {
            dict set result $leaf [JoinToken pairs $token [dict get $b $leaf]]
        }
    }
    return $result
}

# The state after paths ending in states A and B join (Control flow,
# header): two places, or a place and a value, have one token after it
# exactly when they had one token on each path -- the relations true on
# every completing path, and no other. A place whose last change differs
# gets a fresh stamp; its implicit token after the join stands for the
# pair of its tokens on the two paths. PAIRS receives the pairs' tokens,
# for the value join.
proc hir::relations::JoinState {a b pairsVar} {
    upvar 1 $pairsVar pairs
    variable next
    set result [dict create tokens [dict create] kills [dict create]]
    set ka [dict get $a kills]
    set kb [dict get $b kills]
    set changed {}
    foreach k [lsort -unique [concat [dict keys $ka] [dict keys $kb]]] {
        set sa [dict getdef $ka $k ""]
        set sb [dict getdef $kb $k ""]
        if {$sa eq $sb} {
            dict set result kills $k $sa
        } else {
            dict set result kills $k [incr next]
            lappend changed $k
        }
    }
    foreach k $changed {
        set pair [list [Read $a $k] [Read $b $k]]
        if {![dict exists $pairs $pair]} {
            dict set pairs $pair [Read $result $k]
        }
    }
    set ta [dict get $a tokens]
    set tb [dict get $b tokens]
    foreach path [lsort -unique [concat [dict keys $ta] [dict keys $tb]]] {
        dict set result tokens $path [JoinToken pairs [Read $a $path] [Read $b $path]]
    }
    return $result
}

# Joins the completing outcomes OUTCOMES ({VALUE STATE} each; "never" for
# a path that does not complete): {VALUE STATE}, or never.
proc hir::relations::Join {outcomes} {
    set result never
    foreach outcome $outcomes {
        if {$outcome eq "never"} continue
        if {$result eq "never"} {
            set result $outcome
            continue
        }
        lassign $result value state
        lassign $outcome v s
        set pairs [dict create]
        set state [JoinState $state $s pairs]
        set result [list [JoinValue $value $v pairs] $state]
    }
    return $result
}

# Every place a call anywhere in the code EXPRS (outside the functions
# defined in it) may change in place, given a fresh stamp in STATE, and
# every context parameter's place when one of those calls may change the
# installed context.
proc hir::relations::KillWritten {hirVar contracts stateVar exprs} {
    upvar 1 $hirVar hir $stateVar state
    set work $exprs
    while {$work ne {}} {
        set work [lassign $work e]
        set node [dict get $hir exprs $e]
        if {[dict get $node kind] eq "block"} continue
        if {[dict get $node kind] eq "call"} {
            Effects hir $contracts state $e
        }
        lappend work {*}[hir::children $hir $e]
    }
}

# The changes call E makes when it runs (Invalidation, header): its place
# arguments, but an argument its contract preserves, and the context
# parameters' places when it may change the installed context.
proc hir::relations::Effects {hirVar contracts stateVar e} {
    upvar 1 $hirVar hir $stateVar state
    variable contextRoots
    set node [dict get $hir exprs $e]
    set preserved {}
    lassign [dict get $node target] kind block
    if {$kind eq "block" && [dict exists $contracts $block preserves]} {
        set preserved [dict get $contracts $block preserves]
    }
    set index 0
    foreach arg [dict get $node args] {
        if {$arg ne "" && $index ni $preserved && [hir::mutvec::PlaceArgument $hir $e $arg]} {
            set path [PlaceOf $hir $arg]
            if {$path ne ""} {
                Kill state $path
            }
        }
        incr index
    }
    foreach root $contextRoots {
        if {[hir::cardinality::ContextSite $hir $e [hir::cardinality::ContextIdOf $hir $root]]} {
            Kill state [list $root]
        }
    }
}

# ---------------------------------------------------------------------------
# The walk: Eval returns the abstract value of a completing expression, or
# never; STATE is the state where it completes.

proc hir::relations::Seq {hirVar contracts stateVar body} {
    upvar 1 $hirVar hir $stateVar state
    set value [dict create]
    foreach e $body {
        if {![dict get $hir exprs $e reachable]} {
            return never
        }
        set value [Eval hir $contracts state $e]
        if {$value eq "never"} {
            return never
        }
    }
    return $value
}

# Walks BODY from STATE: {VALUE STATE'} or never.
proc hir::relations::Outcome {hirVar contracts state body} {
    upvar 1 $hirVar hir
    set value [Seq hir $contracts state $body]
    if {$value eq "never"} {
        return never
    }
    return [list $value $state]
}

proc hir::relations::Eval {hirVar contracts stateVar e} {
    upvar 1 $hirVar hir $stateVar state
    variable breaks
    set node [dict get $hir exprs $e]
    switch -- [dict get $node kind] {
        const - block {
            return [dict create]
        }
        ref - project {
            set path [PlaceOf $hir $e]
            if {$path ne ""} {
                return [ReadValue $state $path [hir::typeOf $hir $e]]
            }
            if {[dict get $node kind] eq "ref"} {
                return [dict create]
            }
            set receiver [Eval hir $contracts state [dict get $node receiver]]
            if {$receiver eq "never"} {
                return never
            }
            set field [dict get $node name]
            set value [dict create]
            dict for {leaf token} $receiver {
                if {[lindex $leaf 0] eq $field} {
                    dict set value [lrange $leaf 1 end] $token
                }
            }
            return $value
        }
        bind {
            set value [Eval hir $contracts state [dict get $node value]]
            if {$value eq "never"} {
                return never
            }
            set b [dict get $node binding]
            if {![dict get $node duplicate] && $b ne ""} {
                # A new binding: what its places held before (an earlier
                # iteration's) is gone; each leaf is its value's.
                foreach k [dict keys [dict get $state kills]] {
                    if {[lindex $k 0] eq $b} {
                        dict unset state kills $k
                    }
                }
                foreach k [dict keys [dict get $state tokens]] {
                    if {[lindex $k 0] eq $b} {
                        dict unset state tokens $k
                    }
                }
                foreach leaf [Leaves [hir::typeOf $hir [dict get $node value]]] {
                    if {[dict exists $value $leaf]} {
                        set token [dict get $value $leaf]
                    } else {
                        set token [Fresh]
                    }
                    dict set state tokens [concat [list $b] $leaf] $token
                }
            }
            return [dict create]
        }
        struct {
            set value [dict create]
            foreach name [dict get $node names] field [dict get $node fields] {
                set v [Eval hir $contracts state $field]
                if {$v eq "never"} {
                    return never
                }
                dict for {leaf token} $v {
                    dict set value [linsert $leaf 0 $name] $token
                }
            }
            return $value
        }
        call {
            return [Call hir $contracts state $e $node]
        }
        if {
            if {[Eval hir $contracts state [dict get $node condition]] eq "never"} {
                return never
            }
            set known [hir::types::KnownOutcome $hir [dict get $node condition]]
            set outcomes {}
            if {$known ne "0"} {
                lappend outcomes [Outcome hir $contracts $state [dict get $node thenBody]]
            }
            if {$known ne "1"} {
                lappend outcomes [Outcome hir $contracts $state [dict get $node elseBody]]
            }
            return [Complete state [Join $outcomes]]
        }
        handle {
            set before $state
            set handled [Outcome hir $contracts $state [list [dict get $node call]]]
            set entry $before
            KillWritten hir $contracts entry [list [dict get $node call]]
            set outcomes [list $handled]
            foreach body [dict get $node handlerBodies] {
                lappend outcomes [Outcome hir $contracts $entry $body]
            }
            return [Complete state [Join $outcomes]]
        }
        loop - listloop - countloop - lockloop {
            return [Loop hir $contracts state $e $node]
        }
        break {
            set value [dict create]
            if {[dict get $node value] ne ""} {
                set value [Eval hir $contracts state [dict get $node value]]
                if {$value eq "never"} {
                    return never
                }
            }
            dict lappend breaks [dict get $node target] $value
            return never
        }
        return - fail {
            if {[dict exists $node value] && [dict get $node value] ne ""} {
                Eval hir $contracts state [dict get $node value]
            }
            return never
        }
        continue {
            return never
        }
        default {
            foreach child [hir::children $hir $e] {
                if {[Eval hir $contracts state $child] eq "never"} {
                    return never
                }
            }
            return [dict create]
        }
    }
}

# Sets STATE from the joined OUTCOME ({VALUE STATE} or never) and returns
# its value.
proc hir::relations::Complete {stateVar outcome} {
    upvar 1 $stateVar state
    if {$outcome eq "never"} {
        return never
    }
    lassign $outcome value state
    return $value
}

# A loop (Control flow, header): its operands evaluated once, its body
# walked once from the state with every place the loop may change given a
# fresh stamp, the state after it likewise.
proc hir::relations::Loop {hirVar contracts stateVar e node} {
    upvar 1 $hirVar hir $stateVar state
    variable breaks
    switch -- [dict get $node kind] {
        listloop { set operands [list [dict get $node iterable]] }
        countloop { set operands [list [dict get $node start] [dict get $node end]] }
        lockloop { set operands [hir::loopOperands $node] }
        default { set operands {} }
    }
    foreach operand $operands {
        if {[Eval hir $contracts state $operand] eq "never"} {
            return never
        }
    }
    set body [dict get $node body]
    set entry $state
    KillWritten hir $contracts entry $body
    dict unset breaks $e
    Seq hir $contracts entry $body
    KillWritten hir $contracts state $body
    set values [dict getdef $breaks $e {}]
    dict unset breaks $e
    if {[dict get $node kind] ne "loop"} {
        # (A collecting loop's value is a List.)
        return [dict create]
    }
    if {$values eq {}} {
        # Nothing breaks out of it: it never completes.
        return never
    }
    set value [lindex $values 0]
    foreach v [lrange $values 1 end] {
        set value [JoinValue $value $v]
    }
    return $value
}

# A call: its callee and arguments in order, then its own effect -- the
# check of a required relation, the changes it makes, the members of its
# result.
proc hir::relations::Call {hirVar contracts stateVar e node} {
    upvar 1 $hirVar hir $stateVar state
    variable provenCalls
    if {[Eval hir $contracts state [dict get $node callee]] eq "never"} {
        return never
    }
    set values {}
    foreach arg [dict get $node args] {
        if {$arg eq ""} {
            lappend values [dict create]
            continue
        }
        set v [Eval hir $contracts state $arg]
        if {$v eq "never"} {
            return never
        }
        lappend values $v
    }
    set row ""
    lassign [dict get $node target] kind block
    if {$kind eq "block" && [dict exists $contracts $block]} {
        set row [dict get $contracts $block]
    }
    if {$row ne "" && [dict exists $row requires] && [dict get $node reachable]} {
        lassign [dict get $row requires] i j
        set order [lindex [dict get $node args] $i]
        set place [lindex [dict get $node args] $j]
        set path [PlaceOf $hir $place]
        if {$order ne "" && $path ne "" && ![Poisoned $hir [list $e $order $place]]} {
            # The place's members when the call runs (after every argument),
            # the order's as it was read.
            set have [Read $state $path]
            set given [dict getdef [lindex $values $i] {} ""]
            if {$given ne "" && $given eq $have} {
                lappend provenCalls $e
            } else {
                Unproven hir $e $row $order $path
            }
        }
    }
    Effects hir $contracts state $e
    if {$row ne "" && [dict exists $row mints]} {
        set token [dict getdef [lindex $values [dict get $row mints]] {} ""]
        if {$token ne ""} {
            return [dict create {} $token]
        }
    }
    return [dict create]
}

# 1 if any expression of EXPRS is poison (hir/types.tcl, "Poison"): its
# diagnostic is reported, and this one would only restate it.
proc hir::relations::Poisoned {hir exprs} {
    foreach x $exprs {
        if {[hir::types::Poisoned $hir $x]} {
            return 1
        }
    }
    return 0
}

proc hir::relations::Unproven {hirVar e row order path} {
    upvar 1 $hirVar hir
    set fn [dict get $row name]
    set ns [string range $fn 0 [expr {[string last :: $fn] - 1}]]
    set members [dict get $row members]
    set receiver [join [concat [list [hir::semantic::SourceName $hir [lindex $path 0]]] [lrange $path 1 end]] .]
    set orderPath [PlaceOf $hir $order]
    if {$orderPath ne ""} {
        set what "`[join [concat [list [hir::semantic::SourceName $hir [lindex $orderPath 0]]] [lrange $orderPath 1 end]] .]`"
    } else {
        set what "the order"
    }
    hir::Diagnose hir REORDER-NOT-PROVEN \
        "$what is not known to hold exactly the current $members of `$receiver`, which $fn requires of its order (an order of the right type may hold other $members, and equal lengths are not equal $members): take the order from `$receiver.[dict get $row snapshot]()`, or check a candidate once with `$receiver.[dict get $row validator](candidate)` ([dict get $row error] when it does not hold them), and change neither `$receiver`'s $members nor the order's elements before the call" \
        $e
}
