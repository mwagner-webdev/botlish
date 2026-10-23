# iteration.tcl -- loops over the standard library's collection structs
# (ORDERED-MUTABLE-MAP-SET.md, "Iteration"): `loop x in m:` where m is a
# std::mutable_map::MutableMap or a std::mutable_set::MutableSet.
#
#   hir::iteration::Protocol HIR TYPE      the loop protocol of TYPE, or ""
#   hir::iteration::ElementOf HIR TYPE     a loop variable's type over TYPE
#   hir::iteration::verify HIRVAR          diagnostics, part of hir::check
#   hir::iteration::Elaborate HIRVAR       the loops, written out (after
#                                          hir::check, before every backend)
#
# Intrinsic iteration. A loop iterates a List, a MutableVector or a
# MutableArray (the language's own sequences), and the struct types this
# file's table names, whose iteration the implementation supplies -- as an
# intrinsic trait's witnesses are (HASHABLE-AND-KEYED-HASH.md): no program
# declares an iterable type, and nothing is decided by a type's or a
# namespace's spelling but the table's rows. A row names a struct by its
# declaration identity; its owner module declares the three operations of
# the *loop protocol*, by fixed names, beside it:
#
#   iteration_end(c: S) -> int             one past the last position
#   iteration_live?(c: S, i: int) -> bool  whether position i holds an element
#   iteration_at(c: S, i: int) -> E        the element at a live position i
#
# each total (no declared error), over the struct's own application (S:
# `MutableMap[K, V]`), E the loop variable's type with the struct's
# arguments put in (ElementOf). Positions are the collection's
# representation, not its semantics: a loop visits the live positions in
# increasing order, and that order is the collection's (insertion order for
# MutableMap and MutableSet). The operations are internal: only the
# standard library may name them (surface/modules.tcl's CheckInternal), so
# no program can observe a position, a dead one or a representation change.
#
# The loop is written out after hir::check (Elaborate) as the numeric
# collecting loop every backend compiles, before the copies of
# hir/mutvec.tcl are:
#
#   loop x in DOMAIN:          x#domainE = DOMAIN
#       BODY             ==>  loop x#positionE from 0 to iteration_end(x#domainE):
#                                 if iteration_live?(x#domainE, x#positionE): (nothing)
#                                 else: continue
#                                 x = iteration_at(x#domainE, x#positionE)
#                                 BODY
#
# (E the loop's ExprId: the names are unique in their scope)
#
# so it iterates DOMAIN as it was when the loop began: `x#domainE` is a
# binding of its own, which hir/mutvec.tcl copies logically (an O(1) share
# of every header) exactly when the loop's place may change meanwhile -- the
# snapshot an unrestricted MutableVector's loop iterates, with no element
# materialized: a mutation of the collection inside the body detaches its
# own headers once and never changes what the loop sees. Every check ran on
# the loop as written (a listloop over DOMAIN, its variable typed by
# ElementOf); the protocol is total, so the operations add no error, and the
# collected List is the body's values at the live positions, as a listloop's
# is at every element.

namespace eval hir::iteration {
    # The iterable struct types the implementation supplies: their
    # declaration identities.
    variable iterables {std::mutable_map::MutableMap std::mutable_set::MutableSet}
    # The loop protocol's operations, by role: their names in the owner
    # namespace.
    variable operations {end iteration_end live iteration_live? at iteration_at}
}

# The owner namespace of iterable struct identity ID (its declaring
# module), or "" when ID is no table row.
proc hir::iteration::OwnerOf {id} {
    variable iterables
    if {$id ni $iterables} {
        return ""
    }
    set at [string last :: $id]
    return [string range $id 0 [expr {$at - 1}]]
}

# 1 if NAME (a qualified member name NS::MEMBER) is an operation of the loop
# protocol of a table row's owner: an internal member, which only the
# standard library may name.
proc hir::iteration::IsOperation {ns member} {
    variable iterables
    variable operations
    if {$member ni [dict values $operations]} {
        return 0
    }
    foreach id $iterables {
        if {[OwnerOf $id] eq $ns} {
            return 1
        }
    }
    return 0
}

# The loop protocol of static TYPE: a dict ROLE -> {BINDING BLOCK} (the
# owner module's function binding of each operation and the block it binds)
# when TYPE is an application of a table row's struct whose owner module is
# in HIR and declares every operation as a function; "" otherwise.
proc hir::iteration::Protocol {hir type} {
    variable operations
    if {![hir::types::IsNamedStruct $type]} {
        return ""
    }
    set ns [OwnerOf [lindex $type 1]]
    if {$ns eq "" || ![dict exists $hir modules $ns]} {
        return ""
    }
    set scope [dict get $hir modules $ns]
    set result [dict create]
    dict for {role name} $operations {
        set b [dict getdef $hir scopes $scope names "${ns}::$name" ""]
        if {$b eq ""} {
            return ""
        }
        set by [dict get $hir bindings $b declaredBy]
        if {$by eq "" || ![dict exists $hir exprs $by] || [dict get $hir exprs $by kind] ne "bind"} {
            return ""
        }
        set block [dict get $hir exprs $by value]
        if {[dict get $hir exprs $block kind] ne "block"} {
            return ""
        }
        dict set result $role [list $b $block]
    }
    return $result
}

# The result type of loop protocol operation BLOCK (a block ExprId) called
# on a collection of static TYPE: its declared result with the variables
# its first parameter's declared type establishes from TYPE put in.
proc hir::iteration::ResultOn {hir block type} {
    set params [dict get $hir exprs $block declaredParamTypes]
    set result [dict get $hir exprs $block declaredResult]
    set binding [dict create]
    hir::imprint::Match [lindex $params 0] $type binding 0
    return [hir::imprint::Substitute $result $binding]
}

# The type of a loop variable over a value of static TYPE: the protocol's
# element (ResultOn of its `at`) for an iterable struct, else the
# language's own (hir::types::IterationElementOf; "" when unknown).
proc hir::iteration::ElementOf {hir type} {
    set protocol [Protocol $hir $type]
    if {$protocol eq ""} {
        return [hir::types::IterationElementOf $type]
    }
    return [ResultOn $hir [lindex [dict get $protocol at] 1] $type]
}

# 1 if lockstep loop NODE has a clause over an iterable struct (Protocol).
proc hir::iteration::IterableDomain {hir node} {
    foreach d [dict get $node domains] {
        if {[dict get $d kind] eq "list" && [Protocol $hir [hir::typeOf $hir [dict get $d iterable]]] ne ""} {
            return 1
        }
    }
    return 0
}

# ---------------------------------------------------------------------------
# Verification (hir::check)

# A lockstep loop advances its clauses together over a statically proven
# common count, which no iterable struct has: one of its domains is TYPE.
# And a table row's owner module that declares the protocol wrongly is a
# defect of the implementation, reported as one.
proc hir::iteration::verify {hirVar} {
    upvar 1 $hirVar hir
    variable iterables
    set checked [dict create]
    dict for {e node} [dict get $hir exprs] {
        switch -- [dict get $node kind] {
            listloop {
                set operands [list [dict get $node iterable]]
            }
            lockloop {
                set operands {}
                foreach d [dict get $node domains] {
                    if {[dict get $d kind] ne "list"} continue
                    set it [dict get $d iterable]
                    if {[Protocol $hir [hir::typeOf $hir $it]] ne ""} {
                        hir::Diagnose hir TYPE \
                            "a lockstep loop cannot iterate [hir::types::presented [hir::typeOf $hir $it]]: its clauses advance together over a count the compiler proves equal, and a collection's element count is not one (iterate it in a loop of its own)" $it
                    }
                }
                continue
            }
            default continue
        }
        foreach it $operands {
            set type [hir::typeOf $hir $it]
            set protocol [Protocol $hir $type]
            if {$protocol eq "" || [dict exists $checked [lindex $type 1]]} continue
            dict set checked [lindex $type 1] 1
            set problem [ProtocolProblem $hir $protocol]
            if {$problem ne ""} {
                error "hir::iteration: the loop protocol of [lindex $type 1] is malformed: $problem"
            }
        }
    }
}

# Why PROTOCOL (Protocol's dict) is no loop protocol, or "": each operation
# takes the collection first (its position second), declares its result
# and no error, and has no place parameter.
proc hir::iteration::ProtocolProblem {hir protocol} {
    dict for {role entry} $protocol {
        lassign $entry b block
        set node [dict get $hir exprs $block]
        set arity [expr {$role eq "end" ? 1 : 2}]
        if {[llength [dict get $node params]] != $arity} {
            return "$role takes $arity parameter(s)"
        }
        if {[dict get $node declaredErrors] ne {} || [dict get $node declaredResult] eq {}} {
            return "$role must declare its result and no error"
        }
        if {[dict getdef $node places {}] ne {} || [dict getdef $node directContexts {}] ne {}} {
            return "$role must take values only"
        }
    }
    return ""
}

# ---------------------------------------------------------------------------
# Elaboration (after hir::check; hir::BuildFull)

proc hir::iteration::Elaborate {hirVar} {
    upvar 1 $hirVar hir
    if {[hir::mode $hir] ne "program"} {
        return
    }
    set loops {}
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "listloop"} continue
        set type [hir::typeOf $hir [dict get $node iterable]]
        set protocol [Protocol $hir $type]
        if {$protocol ne ""} {
            lappend loops $e $protocol $type
        }
    }
    if {$loops eq {}} {
        return
    }
    lassign [hir::contexts::Walk $hir] owner parent rootOf calls blocks
    foreach {e protocol type} $loops {
        Rewrite hir $parent $e $protocol $type
    }
}

# Writes listloop E (its iterable of static TYPE, PROTOCOL its loop
# protocol; PARENT the parent map) out as the counted loop the file's header
# shows, in place: E becomes the countloop.
proc hir::iteration::Rewrite {hirVar parent e protocol type} {
    upvar 1 $hirVar hir
    set node [dict get $hir exprs $e]
    set origin [dict get $node origin]
    set scope [dict get $node scope]
    set reachable [dict get $node reachable]
    set iterable [dict get $node iterable]
    set bodyScope [dict get $node bodyScope]
    set element [dict get $node elementBinding]
    set body [dict get $node body]
    set name [dict get $hir bindings $element name]
    set elemType [hir::affine::BindingType $hir $element]
    # The statement E is (or is the value of), in the sequence it is in.
    lassign [Statement $hir $parent $e] holder statement
    # x#domain = DOMAIN, before that statement.
    set d [NewLocal hir "$name#domain$e" $scope $origin $type]
    set bindDomain [NewNode hir bind $origin $scope $type $reachable \
        name "$name#domain$e" binding $d value $iterable duplicate 0]
    dict set hir bindings $d declaredBy $bindDomain
    InsertBefore hir $holder $statement $bindDomain
    # The position: the countloop's induction binding, a parameter of the
    # loop's body scope.
    set position [hir::NewId hir binding]
    dict set hir bindings $position [dict create id $position name "$name#position$e" kind param \
        scope $bodyScope declaredBy "" origin $origin type [hir::types::intern hir int] symbol "" value ""]
    dict set hir scopes $bodyScope names "$name#position$e" $position
    dict set hir scopes $bodyScope bindings [linsert [dict get $hir scopes $bodyScope bindings] 0 $position]
    # The body's reachability (its first statement's, or the loop's).
    set inner $reachable
    if {$body ne {}} {
        set inner [dict get $hir exprs [lindex $body 0] reachable]
    }
    # if iteration_live?(x#domain, x#position): (nothing) else: continue
    set live [OperationCall hir $protocol live [list [Ref hir $d $origin $scope $inner] \
        [Ref hir $position $origin $bodyScope $inner]] bool $origin $bodyScope $inner]
    set thenScope [NewScope hir branch $bodyScope $origin]
    set elseScope [NewScope hir branch $bodyScope $origin]
    set skip [NewNode hir continue $origin $elseScope never $inner target $e]
    set test [NewNode hir if $origin $bodyScope unit $inner condition $live \
        thenScope $thenScope thenBody {} elseScope $elseScope elseBody [list $skip] \
        refinements {1 {} 0 {}}]
    dict set hir scopes $thenScope owner $test
    dict set hir scopes $elseScope owner $test
    # x = iteration_at(x#domain, x#position): the element binding becomes a
    # local of the body scope.
    set at [OperationCall hir $protocol at [list [Ref hir $d $origin $bodyScope $inner] \
        [Ref hir $position $origin $bodyScope $inner]] $elemType $origin $bodyScope $inner]
    set bindElement [NewNode hir bind $origin $bodyScope $elemType $inner \
        name $name binding $element value $at duplicate 0]
    dict set hir bindings $element kind local
    dict set hir bindings $element declaredBy $bindElement
    dict set hir bindings $element type [hir::types::intern hir $elemType]
    # The loop itself: 0 to iteration_end(x#domain), exclusive, upward.
    set start [NewNode hir const $origin $scope int $reachable literal 0 value {int 0}]
    set end [OperationCall hir $protocol end [list [Ref hir $d $origin $scope $reachable]] int \
        $origin $scope $reachable]
    set loop [dict create id $e kind countloop origin $origin scope $scope type [dict get $node type] \
        reachable $reachable start $start end $end bodyScope $bodyScope countBinding $position \
        direction up endKind exclusive body [concat [list $test $bindElement] $body]]
    dict set hir exprs $e $loop
    # The enclosing functions reach the operations as module-static
    # references (hir::resolve::Capture's rule for a module binding).
    set x $e
    for {set i 0} {$i < 4096 && [dict exists $parent $x]} {incr i} {
        set x [lindex [dict get $parent $x] 0]
        if {$x eq ""} break
        if {[dict get $hir exprs $x kind] ne "block"} continue
        set refs [dict get $hir exprs $x staticRefs]
        dict for {role entry} $protocol {
            set b [lindex $entry 0]
            if {$b ni $refs && [dict get $hir scopes [dict get $hir bindings $b scope] invocation]
                    ne [dict get $hir scopes [dict get $hir exprs $x bodyScope] invocation]} {
                lappend refs $b
            }
        }
        dict set hir exprs $x staticRefs $refs
    }
}

# {HOLDER STATEMENT}: the expression (a block, a branch's or a handler's
# owner, a loop) whose sequence holds STATEMENT, the statement that E is or
# is the value of (a bind's, a return's) -- or {"" STATEMENT} for a
# top-level statement (HIR's roots).
proc hir::iteration::Statement {hir parent e} {
    set x $e
    for {set i 0} {$i < 8} {incr i} {
        set p [lindex [dict getdef $parent $x {""}] 0]
        if {$p eq ""} {
            return [list "" $x]
        }
        if {[hir::coroutines::SequenceOf $hir $p $x] ne ""} {
            return [list $p $x]
        }
        if {[dict get $hir exprs $p kind] ni {bind return}} {
            error "hir::iteration: a collecting loop over a collection in an unexpected position ($e in $p)"
        }
        set x $p
    }
    error "hir::iteration: no statement holds $e"
}

# Inserts expression NEW into the sequence of HOLDER ("" for the roots)
# right before STATEMENT.
proc hir::iteration::InsertBefore {hirVar holder statement new} {
    upvar 1 $hirVar hir
    if {$holder eq ""} {
        set roots [dict get $hir roots]
        dict set hir roots [linsert $roots [lsearch -exact $roots $statement] $new]
        return
    }
    set node [dict get $hir exprs $holder]
    foreach field {body thenBody elseBody} {
        if {[dict exists $node $field]} {
            set list [dict get $node $field]
            set i [lsearch -exact $list $statement]
            if {$i >= 0} {
                dict set hir exprs $holder $field [linsert $list $i $new]
                return
            }
        }
    }
    if {[dict exists $node handlerBodies]} {
        set bodies [dict get $node handlerBodies]
        set k 0
        foreach list $bodies {
            set i [lsearch -exact $list $statement]
            if {$i >= 0} {
                lset bodies $k [linsert $list $i $new]
                dict set hir exprs $holder handlerBodies $bodies
                return
            }
            incr k
        }
    }
    error "hir::iteration: $statement is in no sequence of $holder"
}

# A new expression node of KIND with the common fields and FIELDS; its id.
proc hir::iteration::NewNode {hirVar kind origin scope type reachable args} {
    upvar 1 $hirVar hir
    set x [hir::NewId hir expr]
    dict set hir exprs $x [dict merge [dict create id $x kind $kind origin $origin scope $scope \
        type [hir::types::intern hir $type] reachable $reachable] [dict create {*}$args]]
    return $x
}

# A new local binding NAME of SCOPE, of static TYPE.
proc hir::iteration::NewLocal {hirVar name scope origin type} {
    upvar 1 $hirVar hir
    set b [hir::NewId hir binding]
    dict set hir bindings $b [dict create id $b name $name kind local scope $scope declaredBy "" \
        origin $origin type [hir::types::intern hir $type] symbol "" value ""]
    dict set hir scopes $scope names $name $b
    dict set hir scopes $scope bindings [concat [dict get $hir scopes $scope bindings] [list $b]]
    return $b
}

# A new scope of KIND inside PARENT (its invocation's), owner set later.
proc hir::iteration::NewScope {hirVar kind parentScope origin} {
    upvar 1 $hirVar hir
    set s [hir::NewId hir scope]
    dict set hir scopes $s [dict create id $s kind $kind parent $parentScope \
        invocation [dict get $hir scopes $parentScope invocation] owner "" origin $origin \
        names [dict create] bindings {} closures {} refinements {}]
    return $s
}

# A reference to binding B.
proc hir::iteration::Ref {hirVar b origin scope reachable} {
    upvar 1 $hirVar hir
    set type [hir::affine::BindingType $hir $b]
    return [NewNode hir ref $origin $scope $type $reachable \
        name [dict get $hir bindings $b name] binding $b init yes]
}

# A direct call of PROTOCOL's operation ROLE with ARGS, of static TYPE.
proc hir::iteration::OperationCall {hirVar protocol role args type origin scope reachable} {
    upvar 1 $hirVar hir
    lassign [dict get $protocol $role] b block
    set callee [NewNode hir ref $origin $scope [hir::affine::BindingType $hir $b] $reachable \
        name [dict get $hir bindings $b name] binding $b init yes]
    return [NewNode hir call $origin $scope $type $reachable callee $callee args $args \
        target [list block $block] known ""]
}
