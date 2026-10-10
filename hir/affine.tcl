# affine.tcl -- general affine ownership (AFFINE-VALUES.md).
#
# Affinity is a property of a value's type (hir::types::Affinity): an
# *unrestricted* value may be duplicated and aliased by ordinary operations;
# an *affine* value has at most one usable owner at a time, and ordinary
# operations *move* it instead of duplicating it. The one primitive affine
# root is the coroutine handle; a struct, an anonymous struct or a List that
# owns an affine value is itself affine. This file is the one ownership
# analysis: it never asks whether a value is a coroutine, only whether its
# type is affine, so a future affine root (a file, a socket, a stateful
# closure) needs no change here.
#
# Positions
# ---------
# Every reachable affine-typed expression E has exactly one *consumer*
# (Consumer), what its value flows into:
#
#   use       a non-consuming use: the handle of a resume (consume-and-
#             replace behind the same owner), of coroutine::done?, of a
#             coroutine's start; a read of an *unrestricted* field
#             (`test.name`); List length; a bare reference in statement
#             position. The owner keeps owning.
#   move      ownership transfers: the value of a binding statement (`b =
#             a`), a function argument (into the callee's parameter), a
#             resume's message, a struct field, a List literal's element, a
#             `return`, a function's result (its last statement), an `if`'s
#             or handler's value (the join owns it), a `break` value, a
#             coroutine construction's argument (captured by the thunk that
#             runs once), and -- the one partial move -- a struct
#             destructuring's read of an affine field out of the
#             destructured temporary.
#   discard   a statement whose value nobody receives: a reference is a
#             use; a fresh value (a call's result, a construction) is
#             released right after the statement.
#   rejected  everything that would duplicate, alias or hide ownership:
#             AFFINE-ERASURE-UNSUPPORTED (into `any`, an untyped native
#             argument, a field or element type that is not affine, the
#             program's result), AFFINE-EQUALITY-UNSUPPORTED (==, hash,
#             ImmutableSet), AFFINE-LIST-OPERATION-UNSUPPORTED (an element
#             copy -- list::at, list::append, iteration, collecting loops),
#             AFFINE-FIELD-MOVE-REQUIRES-DESTRUCTURE (a projection of an
#             affine field: no partial-move state exists), AFFINE-CAPTURE-
#             UNSUPPORTED (a closure capture), AFFINE-TEMPORARY-UNSUPPORTED
#             (a fresh value used without an owner), a module binding.
#
# Bindings
# --------
# An *affine binding* is a local or parameter whose type is affine. Its
# ownership state is static only: live, {moved MOVE...} or {maybe MOVE...}
# (moved on some path), computed by a forward analysis over each function
# body (and the top level) in evaluation order, joining at if/handle exits
# and iterating loops to a fixed point; a path that cannot complete normally
# does not reach a join. A parameter starts live: the callee owns its
# argument exactly as a local owns its value. A use or move of a binding
# that is moved is USE-AFTER-MOVE; of one that is maybe moved,
# AFFINE-NOT-DEFINITELY-LIVE. Nothing of this exists at run time: there is
# no moved sentinel and no ownership count; a move is an ordinary
# representation transfer (the same object, one new owner).
#
# A generic (untyped) parameter carries no affinity in its function's own
# analysis; a call that passes it an affine value gets a semantic instance
# (hir/semantic.tcl) analyzed with the value's type, and hir::semantic::
# verify runs this analysis on that instance (verifyInstance): an instance
# that would duplicate its argument is invalid for that call.
#
# Release (drop) elaboration
# --------------------------
# The analysis also decides where each owned value dies -- the type decides
# how it is released (Descriptor): a coroutine by coroutine#release, an
# aggregate by affine#drop with a static descriptor of where its affine
# components are. Releases are unobservable (no Botlish code runs, no value
# changes); they change resource retention only. Four tables:
#
#   releases    statement -> items released right after it completes
#               normally: an affine binding after the last statement of its
#               own sequence that refers to it, when it still owns its value
#               (live or maybe moved) there; a discarded fresh value (the
#               statement's own ExprId) right after its statement
#   exits       exit statement (return, fail, break, continue) -> items it
#               releases as it leaves: the bindings whose sequences it
#               leaves that still own their values, and the *pending
#               temporaries* it abandons (below)
#   errorExits  call (or a handled call's handle) -> NAME -> items released
#               when the call propagates declared error NAME
#   consumed    destructuring temporary -> the affine fields moved out of it:
#               its release drops only the others
#
# An item is a BindingId (release what the binding holds) or an ExprId (the
# value that expression produced: a discarded statement, or a pending
# temporary). A *pending temporary* is an affine argument (field, element)
# already evaluated and moved into a call (struct, List) that has not been
# entered yet, while a later argument is evaluated: if that later argument
# leaves abruptly (a declared error, return, break, continue, fail), the call
# never happens and the temporary is the owner -- it is released on that
# exit; the source binding stays moved (no ownership rollback).
#
# An exit releases a binding when it leaves the binding's sequence from a
# statement at or before its last use and the binding owns its value in the
# state where the exit leaves; a move target is declared where the move is,
# so every binding a value may have moved to is in a sequence the exit leaves
# too, or is a callee parameter (the callee releases it), a returned value
# (the caller owns it) or an aggregate (its owner releases it). A release is
# idempotent, so a maybe-moved binding and its new owner may both release.

namespace eval hir::affine {
    # Per-run state of the analysis.
    variable diagnostics {}
    variable parent {}
    variable loopExits {}
    variable afterStates {}
    variable exitStates {}
    # Affine-typed ExprId -> its consumer (Consumer), for the scanned region.
    variable consumers {}
    # Destructuring temporary -> the affine fields read out of it so far.
    variable consumed {}
    # Join ExprId -> the liveness state on each path into it (Flow): an if's
    # {THEN ELSE}, a handle's {CALL HANDLER...}, a loop's {NORMAL BREAK...}
    # (NORMAL "dead" for `loop`). Where a binding moved on some paths only
    # is released (PathReleases).
    variable joinStates {}
    # Loop ExprId -> its `break`s, in the order of joinStates' break paths.
    variable loopBreaks {}
    # Release points on infinite loops' breaks (PathReleases): break ->
    # bindings, merged into the exit table.
    variable pathExits {}
}

# ---------------------------------------------------------------------------
# Queries

# 1 if any type HIR interned is affine: a program without an affine value
# pays nothing for this file.
proc hir::affine::Used {hir} {
    dict for {t type} [dict get $hir types] {
        if {[hir::types::IsAffine $type]} {
            return 1
        }
    }
    return 0
}

# 1 if B is an affine binding: a local or parameter of affine type.
proc hir::affine::IsAffineBinding {hir b} {
    if {$b eq "" || ![dict exists $hir bindings $b]} {
        return 0
    }
    if {[dict get $hir bindings $b kind] ni {local param}} {
        return 0
    }
    return [hir::types::IsAffine [BindingType $hir $b]]
}

# The static type of binding B: its inferred type, or a parameter's entry
# type (declared, or trusted-inferred: hir::signatures::entryTypes) when
# inference recorded none for it.
proc hir::affine::BindingType {hir b} {
    if {[dict get $hir bindings $b type] ne ""} {
        return [hir::bindingType $hir $b]
    }
    if {[dict get $hir bindings $b kind] eq "param"} {
        set block [dict get $hir scopes [dict get $hir bindings $b scope] owner]
        if {$block ne "" && [dict exists $hir exprs $block] && [dict get $hir exprs $block kind] eq "listloop"
                && [dict get $hir exprs $block elementBinding] eq $b} {
            # A loop variable: its iterable's element type (a consuming
            # loop's over an affine MutableVector, MUTABLE-VECTOR.md).
            set t [hir::types::IterationElementOf [hir::typeOf $hir [dict get $hir exprs $block iterable]]]
            return [expr {$t eq "" ? "any" : $t}]
        }
        if {$block ne "" && [dict exists $hir exprs $block] && [dict get $hir exprs $block kind] eq "block"} {
            set index [lsearch -exact [dict get $hir exprs $block params] $b]
            if {[dict exists $hir semanticContext] && [dict get $hir semanticContext] ne "generic"} {
                # A view of a semantic instance (hir::semantic::View): its
                # own block's parameters have the instance's entry types.
                set inst [dict get $hir semantic instances [dict get $hir semanticContext]]
                if {[dict get $inst block] eq $block} {
                    return [lindex [dict get $inst args] $index]
                }
            }
            set t [lindex [hir::signatures::entryTypes $hir $block] $index]
            if {$t ne {}} {
                return $t
            }
        }
    }
    return any
}

# 1 if binding B is a struct destructuring's hygienic temporary
# (surface/lower.tcl's Destructure): the one owner fields may be moved out of.
proc hir::affine::IsDestructureTemp {hir b} {
    return [string match destructure#* [dict get $hir bindings $b name]]
}

# 1 if binding B is a coroutine construction's argument temporary
# (surface/lower.tcl's CoroutineBind), which the construction's thunk -- run
# exactly once, at once -- captures: a move into the coroutine.
proc hir::affine::IsThunkTemp {hir b} {
    return [string match coroutine#*#arg* [dict get $hir bindings $b name]]
}

# The root binding name call E calls (a native), or "".
proc hir::affine::NativeName {hir e} {
    if {![dict exists $hir exprs $e] || [dict get $hir exprs $e kind] ne "call"} {
        return ""
    }
    set callee [dict get $hir exprs [dict get $hir exprs $e callee]]
    if {[dict get $callee kind] ne "ref" || [dict get $callee binding] eq ""} {
        return ""
    }
    set binding [dict get $hir bindings [dict get $callee binding]]
    if {[dict get $binding kind] ne "root"} {
        return ""
    }
    return [dict get $binding name]
}

proc hir::affine::Where {hir e} {
    return [hir::originLocation $hir [dict get $hir exprs $e origin]]
}

# How expression E is named in a diagnostic.
proc hir::affine::Named {hir e} {
    if {[dict get $hir exprs $e kind] eq "ref"} {
        return "`[dict get $hir exprs $e name]`"
    }
    return "this value"
}

# The type text a diagnostic gives affine value E.
proc hir::affine::TypeText {hir e} {
    return [hir::types::show [hir::typeOf $hir $e]]
}

# ---------------------------------------------------------------------------
# Consumers

# The consumer of affine-typed expression E (see the header): {use WHAT},
# {move WHERE AT ?DETAIL?}, {discard} or {reject KIND MESSAGE}. WHERE is
# bind, arg, message, field, element, return, result, join, break, capture,
# out (a destructuring's field read) or value (a binding statement's value).
proc hir::affine::Consumer {hir parent e} {
    if {![dict exists $parent $e]} {
        return {discard}
    }
    lassign [dict get $parent $e] p role
    if {$p ne "" && $role eq "seq 1" && [dict get $hir exprs $p kind] eq "handle"} {
        # A handler's value is the handle's value, whatever happens to it.
        return [list move join $p]
    }
    if {[hir::coroutines::Discarded $hir $parent $e]} {
        return {discard}
    }
    set type [hir::typeOf $hir $e]
    if {$p eq ""} {
        return [list reject AFFINE-ERASURE-UNSUPPORTED \
            "[Named $hir $e] is an affine [TypeText $hir $e], which cannot be the program's result: a result is shown, never owned (end the program with something else; the value is released where its owner dies)"]
    }
    set node [dict get $hir exprs $p]
    switch -- [dict get $node kind] {
        bind {
            return [list move bind $p]
        }
        call {
            return [CallConsumer $hir $p $e $role $type]
        }
        struct {
            set index [lsearch -exact [dict get $node fields] $e]
            set name [lindex [dict get $node names] $index]
            set fieldType [hir::types::StructField [hir::typeOf $hir $p] $name]
            if {$fieldType ne "" && [hir::types::IsAffine $fieldType]} {
                return [list move field $p $name]
            }
            if {$fieldType ne "" && ![hir::types::subtype $type $fieldType]} {
                # A field type mismatch (TYPE, hir::range::VerifyStruct).
                return [list move field $p $name]
            }
            return [Erasure $hir $e "the value of field \"$name\" of type [hir::types::show [expr {$fieldType eq "" ? "any" : $fieldType}]]"]
        }
        project {
            if {[hir::mutvec::InReceiverPath $hir $parent $p]} {
                # A step of a MutableVector operation's receiver place
                # (`state.queue.push(x)`, MUTABLE-VECTOR.md): the operation
                # updates the field in place; nothing moves out of it.
                return {use place}
            }
            set name [dict get $node name]
            set fieldType [hir::types::StructField $type $name]
            set affineField [expr {$fieldType ne "" && [hir::types::IsAffine $fieldType]}]
            set kind [dict get $hir exprs $e kind]
            if {$kind eq "ref" && [IsDestructureTemp $hir [dict get $hir exprs $e binding]]} {
                if {$affineField} {
                    return [list move out $p $name]
                }
                return {use field}
            }
            if {$affineField} {
                set shown [expr {$kind eq "ref" ? [dict get $hir exprs $e name] : "value"}]
                return [list reject AFFINE-FIELD-MOVE-REQUIRES-DESTRUCTURE \
                    "field \"$name\" of [Named $hir $e] is affine ([hir::types::show $fieldType]): reading it would make a second owner of what [Named $hir $e] owns, and a field cannot be moved out of a struct that stays usable (consume the struct with a destructuring instead: \"{$name} = $shown\")"]
            }
            if {$kind ne "ref"} {
                return [Temporary $hir $e "read a field of"]
            }
            return {use field}
        }
        return {
            set block [dict get $node target]
            if {$block eq ""} {
                return [list reject AFFINE-ERASURE-UNSUPPORTED \
                    "[Named $hir $e] is an affine [TypeText $hir $e], which cannot be the program's result: a result is shown, never owned"]
            }
            return [Into $hir $e [list move return $p] [BlockResult $hir $block] "returned from a function whose result type is"]
        }
        block {
            # The last statement of a function body: its result.
            return [Into $hir $e [list move result $p] [BlockResult $hir $p] "the result of a function whose result type is"]
        }
        if {
            return [Into $hir $e [list move join $p] [hir::typeOf $hir $p] "the value of an if of type"]
        }
        handle {
            return [Into $hir $e [list move join $p] [hir::typeOf $hir $p] "the value of a handled call of type"]
        }
        break {
            set loop [dict get $node target]
            set dest [expr {$loop eq "" ? "any" : [hir::typeOf $hir $loop]}]
            return [Into $hir $e [list move break $p] $dest "the value of a loop of type"]
        }
        fail {
            # An error's payload (ERROR-PAYLOADS.md): the raised error owns it
            # -- its ownership moves along the error edge to the handler that
            # receives it, or on outward with the error.
            return [list move error $p]
        }
        loop - listloop - countloop - lockloop {
            if {$role eq "operand" && [dict get $node kind] eq "listloop" && [hir::mutvec::Kind $type] ne ""} {
                # A consuming loop over an affine MutableVector or MutableArray
                # (MUTABLE-VECTOR.md, MUTABLE-ARRAY.md): the collection moves
                # into the loop, which moves each element, in order, into the
                # loop variable, and releases what is left when it is left
                # early.
                return [list move loop $p]
            }
            if {$role eq "operand"} {
                return [list reject AFFINE-LIST-OPERATION-UNSUPPORTED \
                    "[Named $hir $e] is a [TypeText $hir $e]: iterating a List of affine values would copy each element into the loop variable while the List still owns it (whole-List moves are supported; element-wise access waits for ownership-moving operations)"]
            }
            return [list reject AFFINE-LIST-OPERATION-UNSUPPORTED \
                "this loop would collect affine values ([TypeText $hir $e]) into a List: a collecting loop's List would own them across iterations and abrupt exits it cannot release yet (build the List with a List literal, or discard the values)"]
        }
    }
    return [Erasure $hir $e "used as a value here"]
}

# The consumer of affine value E (of static TYPE) at position ROLE of call P.
proc hir::affine::CallConsumer {hir p e role type} {
    set node [dict get $hir exprs $p]
    if {$role eq "callee"} {
        # The callee: a resume of a coroutine handle (consume-and-replace
        # behind the same owner), never a move.
        return {use resume}
    }
    set index [lsearch -exact [dict get $node args] $e]
    set native [NativeName $hir $p]
    if {$native ne ""} {
        return [NativeConsumer $hir $p $e $index $native $type]
    }
    set calleeType [hir::typeOf $hir [dict get $node callee]]
    set target [hir::contexts::Callee $hir $p]
    if {$target eq "" && [lindex [dict get $node target] 0] eq "block"} {
        set target [lindex [dict get $node target] 1]
    }
    if {$target ne "" && [dict get $hir exprs $target kind] eq "block"} {
        set declared [lindex [dict get $hir exprs $target declaredParamTypes] $index]
        set entry [lindex [hir::signatures::entryTypes $hir $target] $index]
        if {$declared eq {}} {
            # An untyped parameter: a generic one. The call's semantic
            # instance owns the argument with its own type (verifyInstance).
            if {$entry eq {} || [hir::types::IsAffine $entry] || [hir::signatures::CallableAdmits $type $entry]
                    || ![hir::types::subtype $type $entry]} {
                if {[Unanalyzed $hir $p]} {
                    # No instance means no analysis of the body for this
                    # argument: whatever the body does with it -- duplicate
                    # it, erase it -- would go unseen (MUTABLE-ARRAY.md,
                    # "Library ownership").
                    set paramName [dict get $hir bindings [lindex [dict get $hir exprs $target params] $index] name]
                    return [list reject AFFINE-ERASURE-UNSUPPORTED \
                        "[Named $hir $e] is an affine [TypeText $hir $e], passed to the untyped parameter \"$paramName\" of a function whose body was not analyzed for it (its semantic instance was declined): the body could duplicate or lose it unseen (declare the parameter's type)"]
                }
                return [list move arg $p $index]
            }
            return [Erasure $hir $e "the argument of a parameter whose inferred contract is [hir::types::show $entry]"]
        }
        if {[hir::types::IsAffine $declared] || ![hir::types::subtype $type $declared]} {
            return [list move arg $p $index]
        }
        set paramName [dict get $hir bindings [lindex [dict get $hir exprs $target params] $index] name]
        return [Erasure $hir $e "the argument of parameter \"$paramName\", declared [hir::types::show $declared]"]
    }
    if {[hir::types::IsFn $calleeType] || [hir::types::IsCoroutine $calleeType]} {
        set declared [lindex [dict get [hir::types::Contract $calleeType] args] $index]
        if {$declared eq "" || [hir::types::IsAffine $declared] || ![hir::types::subtype $type $declared]} {
            return [list move [expr {[hir::types::IsCoroutine $calleeType] ? "message" : "arg"}] $p $index]
        }
        return [Erasure $hir $e "an argument of type [hir::types::show $declared] of a callable of type [hir::types::show $calleeType]"]
    }
    return [Erasure $hir $e "an argument of a function value whose parameters are not known"]
}

# The consumer of affine value E (of static TYPE), argument INDEX of call P of
# the root native NATIVE: what the native's ownership role for that argument
# (core/native.tcl's -ownership) says it does with the value -- never the
# native's name. A native without a role for it erases the value (`erase`).
proc hir::affine::NativeConsumer {hir p e index native type} {
    set role [core::native::ownershipRole $native $index]
    # The receiver of a collection operation may be a place path (a field
    # projection of a binding), which the operation reaches in place.
    set collection [expr {[hir::mutvec::OpKind $hir $p] ne "" && $index == 0}]
    set kind [dict get $hir exprs $e kind]
    switch -- $role {
        observe - release {
            # A non-consuming observation (a length, a coroutine's done?, a
            # start): the value needs an owner, which keeps owning it.
            if {$kind ne "ref" && !($collection && $kind eq "project")} {
                return [Temporary $hir $e "observe"]
            }
            return {use observe}
        }
        place {
            # The receiver place: updated in place, still the owner (a
            # temporary receiver is MUTABLE-PLACE-RECEIVER).
            return {use place}
        }
        resume {
            # A resume of a coroutine handle (consume-and-replace behind the
            # same owner), never a move.
            if {$kind ne "ref"} {
                return [Temporary $hir $e "resume"]
            }
            return {use resume}
        }
        message {
            return [list move message $p $index]
        }
        move {
            # Moved once into the operation: stored in its result or in its
            # receiver collection.
            return [list move [MoveInto $native] $p $index]
        }
        element {
            set dest [hir::typeOf $hir $p]
            if {[hir::types::IsAffine $dest]} {
                return [list move element $p $index]
            }
            return [Erasure $hir $e "an element of a List of type [hir::types::show $dest]"]
        }
        repeat {
            return [list reject AFFINE-DUPLICATION-UNSUPPORTED \
                "$native would place [Named $hir $e], an affine [TypeText $hir $e], in every slot it makes -- one value with several owners: an affine value has exactly one (make one value per slot with a factory instead -- mutable_array::generate(n, make) calls `make(i)` once for each slot -- or repeat an unrestricted value)"]
        }
        factory {
            return [list reject AFFINE-ERASURE-UNSUPPORTED \
                "[Named $hir $e] is an affine [TypeText $hir $e], which cannot be the factory of $native: a factory is called once per element, and an affine callable could be called once at most"]
        }
        copy-out {
            set what [hir::mutvec::Kind $type]
            if {$what ne ""} {
                return [list reject AFFINE-ELEMENT-COPY-OUT [CopyOutMessage $hir $e $native $what]]
            }
            if {[hir::types::IsList $type] || $native in {list::at list::append}} {
                return [list reject AFFINE-LIST-OPERATION-UNSUPPORTED \
                    "$native would copy affine elements out of [Named $hir $e] ([TypeText $hir $e]) while the List still owns them (whole-List moves are supported; element-wise access waits for ownership-moving operations)"]
            }
            return [Erasure $hir $e "an argument of the native $native, which copies elements out of it"]
        }
        equality {
            return [list reject AFFINE-EQUALITY-UNSUPPORTED \
                "[Named $hir $e] is an affine [TypeText $hir $e], which has no equality and no hash: comparing or hashing it would observe the identity of what it owns (compare unrestricted fields instead)"]
        }
    }
    if {[hir::types::IsList $type]} {
        return [list reject AFFINE-LIST-OPERATION-UNSUPPORTED \
            "$native is not an ownership-moving List operation: it cannot take [Named $hir $e], a List of affine values ([TypeText $hir $e])"]
    }
    return [Erasure $hir $e "an argument of the native $native, which takes any value"]
}

# The diagnostic of NATIVE copying an affine element out of collection E (of
# KIND vector or array) while the collection keeps owning it.
proc hir::affine::CopyOutMessage {hir e native kind} {
    if {$kind eq "array"} {
        set alternatives "`swap(i, replacement)` exchanges it for another, and a loop over the array consumes it, moving each element out in order"
        set what "the array"
    } else {
        set alternatives "`take(i)` removes it, `pop()` removes the last one, `swap(i, replacement)` exchanges it for another"
        set what "the vector"
    }
    return "$native would copy an affine element out of [Named $hir $e] ([TypeText $hir $e]) while $what still owns it, making a second owner: move it out instead -- $alternatives (there are no references to elements)"
}

# Where the `move` role of NATIVE moves a value: into a vector, an array, or
# (any other native) its argument position.
proc hir::affine::MoveInto {native} {
    if {[string match mutable_vector* $native]} {
        return vector
    }
    if {[string match mutable_array* $native]} {
        return array
    }
    return arg
}

# 1 if call P of a block had its semantic instance declined (hir/semantic.tcl:
# a budget, or no creation environment yet): the only way an affine argument
# of an untyped parameter would reach a body no analysis saw with it.
proc hir::affine::Unanalyzed {hir p} {
    if {![hir::semantic::Enabled] || ![dict exists $hir semantic declined]} {
        return 0
    }
    set ctx [expr {[dict exists $hir semanticContext] ? [dict get $hir semanticContext] : "generic"}]
    return [expr {[dict exists $hir semantic declined [list $ctx $p]] && [hir::semantic::InstanceOf $hir $p] eq ""}]
}

# MOVE if DEST (the type E's value flows into) is affine; else the erasure
# of E into a position described as "WHAT DEST".
proc hir::affine::Into {hir e move dest what} {
    if {[hir::types::IsAffine $dest] || $dest eq "never"} {
        return $move
    }
    return [Erasure $hir $e "$what [hir::types::show $dest]"]
}

proc hir::affine::Erasure {hir e what} {
    return [list reject AFFINE-ERASURE-UNSUPPORTED \
        "[Named $hir $e] is an affine [TypeText $hir $e], which cannot become $what: that position does not carry ownership, so the value would be duplicated or lost (keep it in a binding, a parameter, a result, a struct field or a List of an affine type)"]
}

proc hir::affine::Temporary {hir e what} {
    return [list reject AFFINE-TEMPORARY-UNSUPPORTED \
        "this affine [TypeText $hir $e] would have no owner: an operation that does not take ownership cannot $what a value that nothing else owns (bind it to a name first)"]
}

# The result type of block E (its declared result, else the inferred one).
proc hir::affine::BlockResult {hir e} {
    set declared [dict get $hir exprs $e declaredResult]
    if {$declared ne ""} {
        return $declared
    }
    set t [dict get $hir exprs $e resultType]
    return [expr {$t eq "" ? "any" : [hir::type $hir $t]}]
}

# ---------------------------------------------------------------------------
# The analysis (hir::check)

proc hir::affine::verify {hirVar} {
    upvar 1 $hirVar hir
    if {![Used $hir]} {
        dict set hir affine [dict create]
        return
    }
    lassign [hir::contexts::Walk $hir] owner parentMap rootOf calls blocks
    set regions [list [dict get $hir roots] {}]
    foreach b $blocks {
        lappend regions [dict get $hir exprs $b body] [AffineParams $hir $b]
    }
    set accepted [Analyze hir $parentMap $regions [dict keys [dict get $hir exprs]] 1]
    variable diagnostics
    foreach e [lsort -dictionary [dict keys $diagnostics]] {
        lassign [dict get $diagnostics $e] kind message at
        hir::Diagnose hir $kind $message $at
    }
    # Releases: only for a program the discipline accepts (a rejected one
    # that still runs, -strict 0, keeps every value until collected), and
    # never twice: HIR rebuilt from lowered Core IR (hir/lower.tcl) already
    # has every release written out.
    set scopes [expr {!$accepted || [WrittenReleases $hir $parentMap] ? {} : [Scopes $hir $parentMap]}]
    variable consumed
    dict set hir affine consumed $consumed
    dict set hir affine releases [Releases hir $parentMap $scopes $accepted]
    lassign [ExitReleases $hir $parentMap $scopes] exits errorExits
    variable pathExits
    dict for {x items} $pathExits {
        foreach item $items {
            if {![dict exists $exits $x] || $item ni [dict get $exits $x]} {
                dict lappend exits $x $item
            }
        }
    }
    dict set hir affine exits $exits
    dict set hir affine errorExits $errorExits
}

# The affine parameters of block E (they start live in its body).
proc hir::affine::AffineParams {hir e} {
    set result {}
    foreach b [dict get $hir exprs $e params] {
        if {[IsAffineBinding $hir $b]} {
            lappend result $b
        }
    }
    return $result
}

# Runs the position scan over EXPRS and the liveness analysis over REGIONS
# ({SEQUENCE PARAMS} pairs) of HIR with parent map PARENTMAP; records the
# per-run state; returns 1 if no diagnostic was found. With PROGRAM 1 the
# program-wide checks (module bindings) run too.
proc hir::affine::Analyze {hirVar parentMap regions exprs program} {
    upvar 1 $hirVar hir
    variable diagnostics
    variable parent
    variable loopExits
    variable afterStates
    variable exitStates
    variable consumers
    variable consumed
    set diagnostics [dict create]
    set parent $parentMap
    set loopExits [dict create]
    set afterStates [dict create]
    set exitStates [dict create]
    set consumers [dict create]
    set consumed [dict create]
    variable joinStates
    variable loopBreaks
    set joinStates [dict create]
    set loopBreaks [dict create]
    set moves [dict create]
    set moveRefs [dict create]
    foreach e $exprs {
        set node [dict get $hir exprs $e]
        if {![dict get $node reachable] || ![dict exists $parent $e]} continue
        set kind [dict get $node kind]
        if {$kind eq "block"} continue
        if {![hir::types::IsAffine [hir::typeOf $hir $e]]} continue
        set consumer [Consumer $hir $parent $e]
        dict set consumers $e $consumer
        if {[lindex $consumer 0] eq "reject" && !($kind eq "project" && [AffineProjection $hir $e])} {
            # (A projection of an affine field outside a destructuring is
            # diagnosed once, at its receiver.)
            dict set diagnostics $e [list [lindex $consumer 1] [lindex $consumer 2] $e]
        }
        if {$kind ne "ref"} continue
        set b [dict get $node binding]
        if {![IsAffineBinding $hir $b]} continue
        if {[lindex $consumer 0] eq "move"} {
            dict set moveRefs $e [lindex $consumer 1]
            if {[lindex $consumer 1] eq "bind"} {
                dict set moves [lindex $consumer 2] $b
            }
        }
        # A capture: a reference from another function than the binding's.
        set refScope [dict get $node scope]
        set bindingScope [dict get $hir bindings $b scope]
        if {[dict get $hir scopes $refScope invocation] ne [dict get $hir scopes $bindingScope invocation]} {
            if {[IsThunkTemp $hir $b] && [ThunkOf $hir $e] ne ""} {
                dict set consumers $e [list move capture [ThunkOf $hir $e]]
                dict set moveRefs $e capture
            } else {
                dict set diagnostics $e [list AFFINE-CAPTURE-UNSUPPORTED \
                    "`[dict get $node name]` is an affine [hir::types::show [BindingType $hir $b]], which cannot be captured by a closure (a nested function): a closure may be called any number of times and copied freely, so capturing would alias the one owner (pass it as an argument, or construct it inside the nested function)" $e]
            }
        }
    }
    if {$program} {
        # Module bindings cannot hold an affine value (module values are
        # immutable and shared by every user of the module).
        dict for {b binding} [dict get $hir bindings] {
            if {[dict get $binding kind] ne "local" || ![hir::isModuleBinding $hir $b]
                    || ![hir::types::IsAffine [BindingType $hir $b]]} continue
            set by [dict get $binding declaredBy]
            if {$by eq ""} continue
            dict set diagnostics $by [list AFFINE-ERASURE-UNSUPPORTED \
                "a module binding cannot hold an affine value ([hir::types::show [BindingType $hir $b]]): module values are immutable and shared by every user of the module (create it inside a function, or in the entry program)" $by]
        }
    }
    dict set hir affine moves $moves
    dict set hir affine moveRefs $moveRefs
    foreach {sequence params} $regions {
        set state [dict create]
        foreach b $params {
            dict set state $b live
        }
        Seq hir $sequence $state
    }
    return [expr {[dict size $diagnostics] == 0}]
}

# 1 if projection E reads an affine field out of anything but a
# destructuring temporary: AFFINE-FIELD-MOVE-REQUIRES-DESTRUCTURE, reported at
# its receiver. A step of a MutableVector operation's receiver place is not
# such a read (its receiver is a `use place`): whatever its own consumer
# rejects -- an affine `at` of `state.queue` -- is reported at it.
proc hir::affine::AffineProjection {hir e} {
    variable parent
    if {[hir::mutvec::InReceiverPath $hir $parent $e]} {
        return 0
    }
    set receiver [dict get $hir exprs $e receiver]
    if {[dict get $hir exprs $receiver kind] eq "ref" && [dict get $hir exprs $receiver binding] ne ""
            && [IsDestructureTemp $hir [dict get $hir exprs $receiver binding]]} {
        return 0
    }
    return [hir::types::IsAffine [hir::typeOf $hir $e]]
}

# The thunk block (a coroutine boundary, hir/coroutines.tcl) reference E is
# inside, or "".
proc hir::affine::ThunkOf {hir e} {
    variable parent
    set x $e
    for {set i 0} {$i < 4096 && [dict exists $parent $x]} {incr i} {
        set p [lindex [dict get $parent $x] 0]
        if {$p eq ""} {
            return ""
        }
        if {[dict get $hir exprs $p kind] eq "block"} {
            set q [lindex [dict get $parent $p] 0]
            if {$q ne "" && [hir::coroutines::NativeOf $hir $q] eq [core::coroutines::createNative]} {
                return $p
            }
            return ""
        }
        set x $p
    }
    return ""
}

# The diagnostics of the affine discipline in semantic instance view VIEW
# (hir::semantic::verify): the region of instance block BLOCK analyzed with
# the instance's types -- a generic function that would duplicate an affine
# argument is invalid for the call that passes it one. Appends to VIEW's
# diagnostics.
proc hir::affine::verifyInstance {viewVar block exprs} {
    upvar 1 $viewVar view
    if {![Used $view]} {
        return
    }
    lassign [hir::contexts::Walk $view] owner parentMap rootOf calls blocks
    set regions {}
    foreach b $blocks {
        if {$b in $exprs} {
            lappend regions [dict get $view exprs $b body] [AffineParams $view $b]
        }
    }
    Analyze view $parentMap $regions $exprs 0
    variable diagnostics
    foreach e [lsort -dictionary [dict keys $diagnostics]] {
        lassign [dict get $diagnostics $e] kind message at
        hir::Diagnose view $kind $message $at
    }
    # A resume of a coroutine the instance was given charges its declared
    # errors exactly as a direct resume does (AFFINE-VALUES.md, "Generic
    # callables"): the generic body called an untyped value, which no
    # error was charged to.
    foreach e $exprs {
        set node [dict get $view exprs $e]
        if {[dict get $node kind] ne "call" || [dict get $node target] ne "" || ![dict get $node reachable]} continue
        set calleeType [hir::typeOf $view [dict get $node callee]]
        if {![hir::types::IsCoroutine $calleeType]} continue
        set handled {}
        if {[dict exists $parentMap $e]} {
            set p [lindex [dict get $parentMap $e] 0]
            if {$p ne "" && [dict get $view exprs $p kind] eq "handle" && [dict get $view exprs $p call] eq $e} {
                set handled [dict get $view exprs $p handlerNames]
            }
        }
        set fn [dict get $view scopes [dict get $node scope] invocation]
        set enclosing [expr {$fn eq "" ? {} : [dict get $view exprs $fn declaredErrors]}]
        foreach name [hir::types::CoroutineErrors $calleeType] {
            if {$name ni $handled && $name ni $enclosing} {
                hir::Diagnose view UNHANDLED-ERROR [format \
                    {this coroutine resume may produce the declared error "%s", which is neither handled here nor admitted by the enclosing function's own "errors" declaration} \
                    $name] $e
            }
        }
    }
}

# ---------------------------------------------------------------------------
# Liveness

# State: BindingId -> live | {moved MOVE...} | {maybe MOVE...} (MOVE: the
# moving reference, or a binding statement whose value moves on); or the
# word `dead` for a path that cannot complete normally.
proc hir::affine::Join {a b} {
    if {$a eq "dead"} { return $b }
    if {$b eq "dead"} { return $a }
    set result [dict create]
    foreach key [lsort -unique [concat [dict keys $a] [dict keys $b]]] {
        if {![dict exists $a $key] || ![dict exists $b $key]} {
            # Bound on one path only: not visible after the join.
            continue
        }
        set x [dict get $a $key]
        set y [dict get $b $key]
        if {$x eq $y} {
            dict set result $key $x
        } elseif {$x eq "live" || $y eq "live" || [lindex $x 0] eq "maybe" || [lindex $y 0] eq "maybe"} {
            set moves [lsort -unique [concat [lrange $x 1 end] [lrange $y 1 end]]]
            dict set result $key [concat maybe $moves]
        } else {
            # Moved on both paths (at different places): definitely moved.
            dict set result $key [list moved {*}[lsort -unique [concat [lrange $x 1 end] [lrange $y 1 end]]]]
        }
    }
    return $result
}

proc hir::affine::Seq {hirVar exprs state} {
    upvar 1 $hirVar hir
    variable afterStates
    foreach e $exprs {
        if {$state eq "dead"} {
            return dead
        }
        set state [Flow hir $e $state]
        # The state after each statement (a loop body's, at the fixed
        # point): where a release may go (Releases).
        dict set afterStates $e $state
    }
    return $state
}

proc hir::affine::Flow {hirVar e state} {
    upvar 1 $hirVar hir
    variable loopExits
    variable joinStates
    variable loopBreaks
    variable exitStates
    variable consumers
    variable parent
    set node [dict get $hir exprs $e]
    if {![dict get $node reachable]} {
        return dead
    }
    switch -- [dict get $node kind] {
        ref {
            set b [dict get $node binding]
            if {[IsAffineBinding $hir $b]} {
                set state [Use hir $e $b $state]
            }
        }
        bind {
            set state [Flow hir [dict get $node value] $state]
            if {$state eq "dead"} {
                return dead
            }
            set b [dict get $node binding]
            if {[IsAffineBinding $hir $b] && ![dict get $node duplicate]} {
                dict set state $b live
                if {[dict exists $consumers $e] && [lindex [dict get $consumers $e] 0] eq "move"} {
                    # The binding statement's value is received by its parent
                    # (a function's result, a join): the new binding's value
                    # moves on at once.
                    dict set state $b [list moved $e]
                }
            }
            return $state
        }
        block {
            if {[dict exists $parent $e]} {
                set q [lindex [dict get $parent $e] 0]
                if {$q ne "" && [hir::coroutines::NativeOf $hir $q] eq [core::coroutines::createNative]} {
                    # A coroutine construction's thunk: its captured argument
                    # temporaries move into the coroutine it starts.
                    foreach b [dict get $node captures] {
                        if {[IsAffineBinding $hir $b] && [dict exists $state $b]} {
                            dict set state $b [list moved $e]
                        }
                    }
                }
            }
        }
        const {
        }
        fail {
            if {[dict exists $node value] && [dict get $node value] ne ""} {
                # The payload is evaluated (its affine values moved into it)
                # before the error leaves (ERROR-PAYLOADS.md).
                set state [Flow hir [dict get $node value] $state]
                if {$state eq "dead"} {
                    return dead
                }
            }
            dict set exitStates $e $state
            return dead
        }
        call - struct - project - ok - error {
            foreach child [hir::children $hir $e] {
                set state [Flow hir $child $state]
                if {$state eq "dead"} {
                    return dead
                }
            }
            if {[dict get $node kind] eq "call"} {
                # Where a declared error this call propagates leaves
                # (ExitReleases): the call itself runs after its operands.
                dict set exitStates $e $state
            }
        }
        if {
            set state [Flow hir [dict get $node condition] $state]
            if {$state eq "dead"} {
                return dead
            }
            set then [Seq hir [dict get $node thenBody] $state]
            set else [Seq hir [dict get $node elseBody] $state]
            dict set joinStates $e [list $then $else]
            return [Join $then $else]
        }
        loop - listloop - countloop - lockloop {
            foreach child [hir::children $hir $e] {
                if {$child in [dict get $node body]} break
                set state [Flow hir $child $state]
                if {$state eq "dead"} {
                    return dead
                }
            }
            set entry $state
            set head $state
            # A consuming loop's variable (MUTABLE-VECTOR.md) owns one
            # element per iteration, freshly.
            set element [expr {[dict get $node kind] eq "listloop" ? [dict get $node elementBinding] : ""}]
            if {$element ne "" && ![IsAffineBinding $hir $element]} {
                set element ""
            }
            for {set pass 0} {$pass < 64} {incr pass} {
                dict set loopExits $e [dict create breaks {} breakNodes {} continues {}]
                set start $head
                if {$element ne ""} {
                    dict set start $element live
                }
                set out [Seq hir [dict get $node body] $start]
                set exits [dict get $loopExits $e]
                set next [Join $entry $out]
                foreach c [dict get $exits continues] {
                    set next [Join $next $c]
                }
                set next [Restrict $next $entry]
                if {$next eq $head} break
                set head $next
            }
            set after [expr {[dict get $node kind] eq "loop" ? "dead" : $head}]
            set paths [list $after]
            foreach b [dict get $exits breaks] {
                set after [Join $after [Restrict $b $entry]]
                lappend paths [Restrict $b $entry]
            }
            dict set joinStates $e $paths
            dict set loopBreaks $e [dict get $exits breakNodes]
            dict unset loopExits $e
            return $after
        }
        return {
            set state [Flow hir [dict get $node value] $state]
            if {$state ne "dead"} {
                dict set exitStates $e $state
            }
            return dead
        }
        break {
            if {[dict get $node value] ne ""} {
                set state [Flow hir [dict get $node value] $state]
            }
            set loop [dict get $node target]
            if {$state ne "dead"} {
                dict set exitStates $e $state
                if {[dict exists $loopExits $loop]} {
                    dict set loopExits $loop breaks [concat [dict get $loopExits $loop breaks] [list $state]]
                    dict set loopExits $loop breakNodes [concat [dict get $loopExits $loop breakNodes] [list $e]]
                }
            }
            return dead
        }
        continue {
            set loop [dict get $node target]
            dict set exitStates $e $state
            if {[dict exists $loopExits $loop]} {
                dict set loopExits $loop continues [concat [dict get $loopExits $loop continues] [list $state]]
            }
            return dead
        }
        handle {
            set before $state
            set state [Flow hir [dict get $node call] $state]
            set entry [expr {$state eq "dead" ? $before : $state}]
            set result $state
            set paths [list $state]
            set payloads [expr {[dict exists $node handlerPayloads] ? [dict get $node handlerPayloads] : {}}]
            set index 0
            foreach body [dict get $node handlerBodies] {
                # A handler's payload binding (ERROR-PAYLOADS.md) owns the
                # payload the selected error carried: it starts live, like a
                # parameter.
                set start $entry
                set payload [lindex $payloads $index]
                incr index
                if {$payload ne "" && [IsAffineBinding $hir $payload]} {
                    dict set start $payload live
                }
                set out [Seq hir $body $start]
                set result [Join $result $out]
                lappend paths $out
            }
            dict set joinStates $e $paths
            return $result
        }
    }
    if {[hir::typeOf $hir $e] eq "never"} {
        return dead
    }
    return $state
}

# STATE without the bindings ENTRY does not know (a loop body's own bindings
# are per iteration).
proc hir::affine::Restrict {state entry} {
    if {$state eq "dead"} {
        return dead
    }
    set result [dict create]
    dict for {b status} $state {
        if {[dict exists $entry $b]} {
            dict set result $b $status
        }
    }
    return $result
}

# A use or move (reference E to affine binding B) in STATE: checked, then the
# state after it.
proc hir::affine::Use {hirVar e b state} {
    upvar 1 $hirVar hir
    variable diagnostics
    variable parent
    variable consumers
    variable consumed
    set name [dict get $hir exprs $e name]
    set p [lindex [dict get $parent $e] 0]
    if {[NativeName $hir $p] ne "" && [core::native::ownershipRole [NativeName $hir $p] \
            [lsearch -exact [dict get $hir exprs $p args] $e]] eq "release"} {
        # A release the compiler wrote out (HIR rebuilt from lowered Core IR):
        # placed where the value is dead, and of a binding possibly moved on
        # some path (Releases) -- never a use to check.
        return $state
    }
    set status [expr {[dict exists $state $b] ? [dict get $state $b] : "live"}]
    set what [expr {[hir::types::IsCoroutine [BindingType $hir $b]] ? "coroutine" : "affine"}]
    if {![dict exists $diagnostics $e] || [lindex [dict get $diagnostics $e] 0] in {USE-AFTER-MOVE AFFINE-NOT-DEFINITELY-LIVE}} {
        switch -- [lindex $status 0] {
            moved {
                set move [lindex $status 1]
                dict set diagnostics $e [list USE-AFTER-MOVE \
                    "`$name` was used after its $what value was moved\n\nmoved here:\n    [MoveText $hir $move]\n\nused here:\n    [Where $hir $e]" $e]
            }
            maybe {
                set moves [lrange $status 1 end]
                dict set diagnostics $e [list AFFINE-NOT-DEFINITELY-LIVE \
                    "`$name` is not definitely live here: its $what value was moved on some path reaching this use\n\nmoved here:\n    [join [lmap m $moves {MoveText $hir $m}] "\n    "]\n\nused here:\n    [Where $hir $e]" $e]
            }
            default {
                if {[dict exists $diagnostics $e]} {
                    dict unset diagnostics $e
                }
            }
        }
    }
    set consumer [expr {[dict exists $consumers $e] ? [dict get $consumers $e] : {use}}]
    if {[lindex $consumer 0] eq "move"} {
        if {[lindex $consumer 1] eq "out"} {
            # A destructuring reads an affine field out of its temporary:
            # the temporary keeps the rest (its release drops only those).
            dict set consumed $b [lindex $consumer 3] 1
        } else {
            dict set state $b [list moved $e]
        }
    }
    return $state
}

# Where move MOVE (a moving reference, or a binding statement whose value
# moves on, or a thunk) happened, for a diagnostic.
proc hir::affine::MoveText {hir move} {
    variable consumers
    set node [dict get $hir exprs $move]
    switch -- [dict get $node kind] {
        bind {
            return "the value of `[dict get $node name] = ...`, received by its context  ([Where $hir $move])"
        }
        block {
            return "captured by a coroutine construction  ([Where $hir $move])"
        }
    }
    set consumer [expr {[dict exists $consumers $move] ? [dict get $consumers $move] : {}}]
    lassign $consumer _ where at
    set source [dict get $node name]
    switch -- $where {
        bind {
            return "[dict get $hir exprs $at name] = $source  ([Where $hir $at])"
        }
        arg {
            set callee [dict get $hir exprs [dict get $hir exprs $at callee]]
            set fn [expr {[dict get $callee kind] eq "ref" ? [dict get $callee name] : "a function"}]
            return "$source passed to $fn  ([Where $hir $move])"
        }
        message {
            return "$source sent as a resume message  ([Where $hir $move])"
        }
        field {
            return "$source stored in field [lindex $consumer 3] of a struct  ([Where $hir $move])"
        }
        element {
            return "$source stored in a List  ([Where $hir $move])"
        }
        vector {
            return "$source moved into a MutableVector  ([Where $hir $move])"
        }
        array {
            return "$source moved into a MutableArray  ([Where $hir $move])"
        }
        loop {
            return "$source consumed by a loop  ([Where $hir $move])"
        }
        return - result {
            return "$source returned  ([Where $hir $move])"
        }
        join {
            return "$source moved into the value of an if or handler  ([Where $hir $move])"
        }
        break {
            return "$source moved into a loop's value  ([Where $hir $move])"
        }
        capture {
            return "$source captured by a coroutine construction  ([Where $hir $move])"
        }
        error {
            return "$source moved into the payload of a failure  ([Where $hir $move])"
        }
    }
    return "$source  ([Where $hir $move])"
}

# ---------------------------------------------------------------------------
# Release elaboration (the header's "Release (drop) elaboration")

# The internal native that drops an aggregate (core/affine.tcl).
proc hir::affine::DropNative {} {
    return affine#drop
}

# 1 if HIR already has releases written out: HIR rebuilt from Core IR that
# hir/lower.tcl lowered (source cannot spell `#`).
proc hir::affine::WrittenReleases {hir parent} {
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] eq "ref" && [dict exists $parent $e]
                && [NativeName $hir [lindex [dict get $parent $e] 0]] in [list [core::coroutines::releaseNative] [DropNative]]} {
            return 1
        }
    }
    return 0
}

# The affine bindings a release may apply to: B -> {sequence LIST key KEY
# last J}. LIST is the sequence its binding statement is in (a parameter's:
# its function's body), KEY its first statement, J the index of the last
# statement of LIST that refers to it (at least the binding statement's own;
# for a parameter at least the first statement). Only a binding every
# reference to which is inside its own sequence.
proc hir::affine::Scopes {hir parent} {
    set refs [dict create]
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] eq "ref" && [IsAffineBinding $hir [dict get $node binding]]} {
            dict lappend refs [dict get $node binding] $e
        }
    }
    set scopes [dict create]
    foreach b [lsort -dictionary [dict keys [dict get $hir bindings]]] {
        if {![IsAffineBinding $hir $b] || [hir::isModuleBinding $hir $b]} continue
        set binding [dict get $hir bindings $b]
        if {[dict get $binding kind] eq "param"} {
            set block [dict get $hir scopes [dict get $binding scope] owner]
            if {$block eq "" || ![dict exists $hir exprs $block] || [dict get $hir exprs $block kind] ni {block listloop handle}
                    || ![dict get $hir exprs $block reachable]} continue
            set p $block
            if {[dict get $hir exprs $block kind] eq "handle"} {
                # A handler's payload binding (ERROR-PAYLOADS.md): its
                # sequence is that handler's body.
                set at [lsearch -exact [dict get $hir exprs $block handlerScopes] [dict get $binding scope]]
                if {$at < 0} continue
                set sequence [lindex [dict get $hir exprs $block handlerBodies] $at]
            } else {
                set sequence [dict get $hir exprs $block body]
            }
            if {$sequence eq {}} continue
            set index 0
        } else {
            set by [dict get $binding declaredBy]
            if {$by eq "" || ![dict exists $hir exprs $by] || [dict get $hir exprs $by kind] ne "bind"
                    || ![dict get $hir exprs $by reachable] || ![dict exists $parent $by]} continue
            set p [lindex [dict get $parent $by] 0]
            set sequence [hir::coroutines::SequenceOf $hir $p $by]
            set index [lsearch -exact $sequence $by]
            if {$index < 0} continue
        }
        set last $index
        set found 1
        foreach r [expr {[dict exists $refs $b] ? [dict get $refs $b] : {}}] {
            # The statement of SEQUENCE the reference is in.
            set x $r
            set at -1
            for {set i 0} {$i < 4096 && [dict exists $parent $x]} {incr i} {
                set up [lindex [dict get $parent $x] 0]
                if {$up eq $p && [set at [lsearch -exact $sequence $x]] >= 0} {
                    break
                }
                if {$up eq ""} break
                set x $up
            }
            if {$at < 0} {
                set found 0
                break
            }
            set last [expr {max($last, $at)}]
        }
        if {!$found} continue
        dict set scopes $b [dict create sequence $sequence key [lindex $sequence 0] last $last]
    }
    return $scopes
}

# 1 if binding B owns its value (live, or maybe moved) in liveness STATE.
proc hir::affine::Owns {state b} {
    return [expr {$state ne "dead" && [dict exists $state $b]
        && [lindex [dict get $state $b] 0] in {live maybe}}]
}

# The release table: each binding of SCOPES that still owns its value after
# its last use's statement, and (ACCEPTED programs only) each discarded fresh
# affine value right after its statement.
proc hir::affine::Releases {hirVar parent scopes accepted} {
    upvar 1 $hirVar hir
    variable afterStates
    variable consumers
    variable pathExits
    set pathExits [dict create]
    set releases [dict create]
    dict for {b info} $scopes {
        set statement [lindex [dict get $info sequence] [dict get $info last]]
        if {![dict exists $afterStates $statement] || ![Owns [dict get $afterStates $statement] $b]} continue
        if {[Descriptor $hir [BindingType $hir $b] [ConsumedFields $hir $b]] eq ""} continue
        if {[lindex [dict get $afterStates $statement $b] 0] eq "maybe"} {
            # Moved on some paths only: released on each path that still
            # owns it, never after the join -- where a path that moved it
            # may have given it to an owner that lives on (a join's value,
            # a MutableVector place, ...).
            foreach point [PathReleases hir $parent $b $statement] {
                lassign $point kind at
                if {$kind eq "after"} {
                    dict lappend releases $at $b
                } else {
                    dict lappend pathExits $at $b
                }
            }
            continue
        }
        dict lappend releases $statement $b
    }
    if {$accepted && ![WrittenReleases $hir $parent]} {
        dict for {e consumer} $consumers {
            if {$consumer ne {discard}} continue
            if {[dict get $hir exprs $e kind] ni {call struct handle loop}} continue
            if {![dict exists $afterStates $e] || [dict get $afterStates $e] eq "dead"} continue
            dict lappend releases $e $e
        }
    }
    return $releases
}

# Where binding B, moved on some paths through statement S only (its last
# use), is released: a list of {after STATEMENT} (after a statement completes
# normally) and {exit BREAK} (as an infinite loop's `break` leaves) points,
# one for every path into a join inside S on which B is still owned while
# another path moved it -- an `if` branch's end (an empty `else` is given a
# `unit` statement to hold it), a handler body's end, a `loop`'s break. A
# path no statement ends -- a handled call's normal completion, a counting
# or iterating loop's exhaustion -- cannot hold a release:
# AFFINE-PATH-RELEASE-UNSUPPORTED (move the value on every path, or on
# none).
proc hir::affine::PathReleases {hirVar parent b statement} {
    upvar 1 $hirVar hir
    variable joinStates
    set points {}
    set work [list $statement]
    while {$work ne {}} {
        set x [lindex $work end]
        set work [lrange $work 0 end-1]
        set node [dict get $hir exprs $x]
        if {[dict get $node kind] eq "block"} continue
        lappend work {*}[hir::children $hir $x]
        if {![dict exists $joinStates $x]} continue
        set paths [dict get $joinStates $x]
        set live {}
        set moved 0
        set i 0
        foreach path $paths {
            if {$path ne "dead" && [dict exists $path $b]} {
                switch -- [lindex [dict get $path $b] 0] {
                    live { lappend live $i }
                    default { set moved 1 }
                }
            }
            incr i
        }
        if {!$moved} continue
        foreach i $live {
            set point [PathPoint hir $x $i $b]
            if {$point ne ""} {
                lappend points $point
            }
        }
    }
    return $points
}

# The release point of path I into join X for binding B (PathReleases), or
# "" (diagnosed, or a shadowed name left to the collector).
proc hir::affine::PathPoint {hirVar x i b} {
    upvar 1 $hirVar hir
    variable loopBreaks
    set node [dict get $hir exprs $x]
    set name [dict get $hir bindings $b name]
    switch -- [dict get $node kind] {
        if {
            set field [expr {$i == 0 ? "thenBody" : "elseBody"}]
            set body [dict get $node $field]
            if {$body eq {}} {
                set body [list [UnitStatement hir $x [dict get $node [expr {$i == 0 ? "thenScope" : "elseScope"}]]]]
                dict set hir exprs $x $field $body
            }
            set at [lindex $body end]
            return [expr {[Shadowed $hir $at $b] ? "" : [list after $at]}]
        }
        handle {
            if {$i > 0} {
                set at [lindex [lindex [dict get $node handlerBodies] [expr {$i - 1}]] end]
                return [expr {[Shadowed $hir $at $b] ? "" : [list after $at]}]
            }
            hir::Diagnose hir AFFINE-PATH-RELEASE-UNSUPPORTED \
                "`$name` is moved by a handler of this call but still owned when the call completes normally: no statement ends that path to release it there (move it on every path, or on none -- e.g. bind the call's result first and move `$name` in an if)" $x
            return ""
        }
        default {
            if {$i > 0 && [dict exists $loopBreaks $x]} {
                set at [lindex [dict get $loopBreaks $x] [expr {$i - 1}]]
                return [expr {[Shadowed $hir $at $b] ? "" : [list exit $at]}]
            }
            hir::Diagnose hir AFFINE-PATH-RELEASE-UNSUPPORTED \
                "`$name` is moved on a path that breaks out of this loop but still owned when the loop runs to its end: no statement ends that path to release it there (move it on every path, or on none -- e.g. use an infinite `loop:` whose every exit is a `break`)" $x
            return ""
        }
    }
}

# A new `unit` statement (a reference to the root binding unit) in scope S,
# placed like X: what an empty `else` holds when a release must end it.
proc hir::affine::UnitStatement {hirVar x s} {
    upvar 1 $hirVar hir
    set root [dict get $hir scopes [dict get $hir top] parent]
    set b [dict get $hir scopes $root names unit]
    set r [hir::NewId hir expr]
    dict set hir exprs $r [dict create id $r kind ref origin [dict get $hir exprs $x origin] scope $s \
        type [hir::types::intern hir unit] reachable [dict get $hir exprs $x reachable] \
        name unit binding $b init yes]
    return $r
}

# The fields moved out of destructuring temporary B (none for any other
# binding).
proc hir::affine::ConsumedFields {hir b} {
    if {$b eq ""} {
        return {}
    }
    if {[dict exists $hir affine consumed]} {
        if {[dict exists $hir affine consumed $b]} {
            return [dict keys [dict get $hir affine consumed $b]]
        }
        return {}
    }
    if {![dict exists $hir bindings $b]} {
        return {}
    }
    set by [dict get $hir bindings $b declaredBy]
    if {$by ne "" && [dict exists $hir exprs $by affineConsumed]} {
        # HIR read back from text (hir/read.tcl): as printed.
        return [dict get $hir exprs $by affineConsumed]
    }
    if {[dict exists $hir bindings $b affineConsumed]} {
        # A handler's payload binding read back from text (ERROR-PAYLOADS.md).
        return [dict get $hir bindings $b affineConsumed]
    }
    return {}
}

# The sequences an abrupt completion at X leaves, innermost first, as {KEY
# INDEX} pairs (the sequence's key and the index of the statement it leaves
# from), up to and including the body of LOOP (break, continue) or of the
# enclosing function (LOOP "": the top level's roots at the outermost), and
# the pending temporaries it abandons on the way (the header's "Release
# (drop) elaboration"): {PAIRS PENDING}. With NAMES (the declared errors a
# call propagates): NAME -> {PAIRS PENDING}, each name's walk ending at a
# `handle` whose call contains X and which handles it.
proc hir::affine::Crossed {hir parent x loop names {keep ""}} {
    set pairs {}
    set pending {}
    set result [dict create]
    for {set i 0} {$i < 4096 && [dict exists $parent $x]} {incr i} {
        lassign [dict get $parent $x] p role
        if {$p eq ""} {
            set roots [dict get $hir roots]
            lappend pairs [list [lindex $roots 0] [lsearch -exact $roots $x]]
            break
        }
        set node [dict get $hir exprs $p]
        if {$names ne {} && [dict get $node kind] eq "handle" && $x eq [dict get $node call]} {
            set remaining {}
            foreach name $names {
                if {$name in [dict get $node handlerNames]} {
                    dict set result $name [list $pairs $pending]
                } else {
                    lappend remaining $name
                }
            }
            set names $remaining
            if {$names eq {}} {
                return $result
            }
        }
        if {[dict get $node kind] in {call struct} && $role eq "operand"} {
            lappend pending {*}[PendingBefore $hir $p $x]
        }
        if {$role ne "operand" && $p ne $keep && [hir::mutvec::IsConsumingLoop $hir $p]} {
            # Leaving a consuming loop over an affine MutableVector: what is
            # left of the vector (the elements not taken yet) is released
            # (MUTABLE-VECTOR.md). A `continue` of this loop keeps it (KEEP).
            lappend pending [LoopDomain $hir $p]
        }
        set sequence [hir::coroutines::SequenceOf $hir $p $x]
        if {$sequence ne ""} {
            lappend pairs [list [lindex $sequence 0] [lsearch -exact $sequence $x]]
        }
        if {[dict get $node kind] eq "block" || ($loop ne "" && $p eq $loop)} break
        set x $p
    }
    if {$names eq {}} {
        return [list $pairs $pending]
    }
    foreach name $names {
        dict set result $name [list $pairs $pending]
    }
    return $result
}

# The pending item of consuming loop P's domain (its iterable's value): a
# reference's binding (which still holds the vector being drained at run
# time), any other operand's ExprId.
proc hir::affine::LoopDomain {hir p} {
    set it [dict get $hir exprs $p iterable]
    if {[dict get $hir exprs $it kind] eq "ref" && [IsAffineBinding $hir [dict get $hir exprs $it binding]]} {
        return [list ref $it [dict get $hir exprs $it binding]]
    }
    return [list value $it]
}

# The pending temporaries of construction P (a call or a struct) while its
# operand X is evaluated: the affine operands evaluated before X that moved
# into P. A reference's is its binding (still holding the value at run time),
# any other operand's the ExprId of the value.
proc hir::affine::PendingBefore {hir p x} {
    variable consumers
    set node [dict get $hir exprs $p]
    set operands [expr {[dict get $node kind] eq "struct" ? [dict get $node fields] : [dict get $node args]}]
    set result {}
    foreach a $operands {
        if {$a eq $x} break
        if {![dict exists $consumers $a] || [lindex [dict get $consumers $a] 0] ne "move"} continue
        if {[dict get $hir exprs $a kind] eq "ref" && [IsAffineBinding $hir [dict get $hir exprs $a binding]]} {
            lappend result [list ref $a [dict get $hir exprs $a binding]]
        } else {
            lappend result [list value $a]
        }
    }
    return $result
}

# The items of PENDING (PendingBefore's) an exit at X releases: a reference's
# binding unless its name is shadowed at X (then the value's ExprId), any
# other value's ExprId.
proc hir::affine::PendingItems {hir pending x} {
    set result {}
    foreach item $pending {
        if {[lindex $item 0] eq "ref"} {
            lassign $item _ a b
            lappend result [expr {[Shadowed $hir $x $b] ? $a : $b}]
        } else {
            lappend result [lindex $item 1]
        }
    }
    return $result
}

# The bindings of SCOPES (in the sequences of PAIRS, BYKEY: sequence key ->
# its bindings) exit X from PAIRS releases in liveness STATE. A binding whose
# binding statement has not run where X leaves is not in STATE (a loop
# body's bindings are not in its head's state either), so it owns nothing.
proc hir::affine::Leaving {hir scopes byKey pairs state x} {
    set result {}
    foreach pair $pairs {
        lassign $pair key at
        if {![dict exists $byKey $key]} continue
        foreach b [dict get $byKey $key] {
            if {$at <= [dict get $scopes $b last] && [Owns $state $b] && ![Shadowed $hir $x $b]
                    && [Descriptor $hir [BindingType $hir $b] [ConsumedFields $hir $b]] ne ""} {
                lappend result $b
            }
        }
    }
    return [lsort -dictionary $result]
}

# 1 if the name of binding B may denote another binding at expression X: a
# binding of that name in a scope between X's and B's own. A release names
# its binding (Core IR resolves names, hir/lower.tcl), so a shadowed binding
# is left to the collector there.
proc hir::affine::Shadowed {hir x b} {
    set name [dict get $hir bindings $b name]
    set home [dict get $hir bindings $b scope]
    set s [dict get $hir exprs $x scope]
    for {set i 0} {$i < 4096 && $s ne ""} {incr i} {
        if {$s eq $home} {
            return 0
        }
        foreach other [dict get $hir scopes $s bindings] {
            if {$other ne $b && [dict get $hir bindings $other name] eq $name} {
                return 1
            }
        }
        set s [dict get $hir scopes $s parent]
    }
    return 1
}

# The exit and error-exit tables of the bindings of SCOPES and of the pending
# temporaries: {EXITS ERROREXITS}.
proc hir::affine::ExitReleases {hir parent scopes} {
    variable exitStates
    set exits [dict create]
    set errorExits [dict create]
    if {[dict size $scopes] == 0 && ![WrittenNone $hir $parent]} {
        return [list $exits $errorExits]
    }
    set byKey [dict create]
    dict for {b info} $scopes {
        dict lappend byKey [dict get $info key] $b
    }
    # Explicit exits first: a call in an exit's value runs after the exit
    # released what the value does not refer to.
    set kinds [dict create return 0 fail 0 break 0 continue 0 call 1]
    set order [lsort -command [list apply {{kinds a b} {
        expr {[dict get $kinds [lindex $a 1]] - [dict get $kinds [lindex $b 1]]}
    }} $kinds] [lmap x [dict keys $exitStates] {list $x [dict get $hir exprs $x kind]}]]
    set already [dict create]
    set tails [hir::aot::selfTailCalls $hir]
    # What a call may let through from a callable the program erases into
    # an untyped parameter (hir/completions.tcl, "Precision and the
    # erased-callable contract"): its type-level errors do not name it, yet
    # it leaves through the call's error edge like any other.
    set erased [hir::completions::erasedErrorsOf $hir]
    set transparent [expr {$erased eq {} ? {} : [hir::completions::transparentBlocks $hir]}]
    foreach entry $order {
        set x [lindex $entry 0]
        set state [dict get $exitStates $x]
        set node [dict get $hir exprs $x]
        switch -- [dict get $node kind] {
            return - fail - break - continue {
                if {![dict exists $parent $x]} continue
                set loop [expr {[dict get $node kind] in {break continue} ? [dict get $node target] : ""}]
                set names {}
                if {[dict get $node kind] eq "fail"} {
                    set names [list [dict get $node name]]
                }
                set keep [expr {[dict get $node kind] eq "continue" ? $loop : ""}]
                set crossed [Crossed $hir $parent $x $loop $names $keep]
                lassign [expr {$names eq {} ? $crossed : [dict get $crossed [lindex $names 0]]}] pairs pending
                set released [concat [Leaving $hir $scopes $byKey $pairs $state $x] [PendingItems $hir $pending $x]]
                if {$released eq {}} continue
                dict set exits $x $released
                if {[dict exists $node value] && [dict get $node value] ne ""} {
                    set used [RefsIn $hir [dict get $node value]]
                    set before [lmap b $released {expr {$b in $used ? [continue] : $b}}]
                    foreach c [CallsIn $hir [dict get $node value]] {
                        dict lappend already $c {*}$before
                    }
                }
            }
            call {
                if {[dict exists $tails $x]} {
                    # A self tail call: the backends that restart the
                    # function for it cannot catch around it (its exit
                    # released the bindings its arguments do not use).
                    continue
                }
                set at $x
                set names [expr {[dict exists $node calleeErrors] ? [dict get $node calleeErrors] : {}}]
                if {$erased ne {} && [hir::completions::mayLetErasedThrough $hir $x $transparent]} {
                    set names [lsort -unique [concat $names $erased]]
                }
                lassign [dict get $parent $x] p
                if {$p ne "" && [dict get $hir exprs $p kind] eq "handle" && [dict get $hir exprs $p call] eq $x} {
                    # A handled call: what its handlers do not handle leaves
                    # from the handle.
                    set at $p
                    set names [lmap name $names {
                        if {$name in [dict get $hir exprs $p handlerNames]} continue
                        set name
                    }]
                }
                if {$names eq {}} continue
                set byName [dict create]
                set done [expr {[dict exists $already $x] ? [dict get $already $x] : {}}]
                dict for {name crossed} [Crossed $hir $parent $at "" [lsort -unique $names]] {
                    lassign $crossed pairs pending
                    set released [lmap b [concat [Leaving $hir $scopes $byKey $pairs $state $x] [PendingItems $hir $pending $x]] {
                        expr {$b in $done ? [continue] : $b}
                    }]
                    if {$released ne {}} {
                        dict set byName $name $released
                    }
                }
                if {[dict size $byName]} {
                    dict set errorExits $at $byName
                }
            }
        }
    }
    return [list $exits $errorExits]
}

# 1 if the analysis may still owe releases with no binding scope: pending
# temporaries exist only in an accepted program whose releases are not
# written out already.
proc hir::affine::WrittenNone {hir parent} {
    variable diagnostics
    return [expr {[dict size $diagnostics] == 0 && ![WrittenReleases $hir $parent]}]
}

# The bindings referred to in the subtree of expression E.
proc hir::affine::RefsIn {hir e} {
    set result {}
    set work [list $e]
    while {$work ne {}} {
        set x [lindex $work end]
        set work [lrange $work 0 end-1]
        if {[dict get $hir exprs $x kind] eq "ref"} {
            lappend result [dict get $hir exprs $x binding]
        }
        lappend work {*}[hir::children $hir $x]
    }
    return $result
}

# The call ExprIds in the subtree of expression E.
proc hir::affine::CallsIn {hir e} {
    set result {}
    set work [list $e]
    while {$work ne {}} {
        set x [lindex $work end]
        set work [lrange $work 0 end-1]
        if {[dict get $hir exprs $x kind] eq "call"} {
            lappend result $x
        }
        lappend work {*}[hir::children $hir $x]
    }
    return $result
}

# ---------------------------------------------------------------------------
# Tables, as the backends read them (from the analysis, or from HIR text read
# back: hir/read.tcl)

# The items to release after statement E.
proc hir::affine::releasesAfter {hir e} {
    if {[dict exists $hir affine releases $e]} {
        return [dict get $hir affine releases $e]
    }
    if {[dict exists $hir exprs $e affineRelease]} {
        return [dict get $hir exprs $e affineRelease]
    }
    return {}
}

# The items to release when exit statement E (return, break, continue, fail)
# leaves, as {BEFORE AFTER}: released before evaluating its value (items the
# value does not refer to), and after it.
proc hir::affine::releasesOnExit {hir e} {
    if {[dict exists $hir affine exits $e]} {
        set items [dict get $hir affine exits $e]
    } elseif {[dict exists $hir exprs $e affineExitRelease]} {
        set items [dict get $hir exprs $e affineExitRelease]
    } else {
        return {{} {}}
    }
    set value [expr {[dict exists $hir exprs $e value] ? [dict get $hir exprs $e value] : ""}]
    set used [expr {$value eq "" ? {} : [RefsIn $hir $value]}]
    set before {}
    set after {}
    foreach item $items {
        if {$item in $used} {
            lappend after $item
        } else {
            # (A pending temporary is never the exit's own value.)
            lappend before $item
        }
    }
    return [list $before $after]
}

# The items to release when call (or handled call's `handle`) E propagates a
# declared error, as NAME -> items (only the names that release any).
proc hir::affine::releasesOnError {hir e} {
    if {[dict exists $hir affine errorExits $e]} {
        return [dict get $hir affine errorExits $e]
    }
    if {[dict exists $hir exprs $e affineErrorRelease]} {
        return [dict get $hir exprs $e affineErrorRelease]
    }
    return {}
}

# 1 if reference E moves its binding's value (HIR text's `move` flag).
proc hir::affine::isMove {hir e} {
    return [expr {[dict exists $hir affine moveRefs $e] || [dict exists $hir exprs $e affineMove]}]
}

# 1 if binding statement E moves a binding's value to its new binding.
proc hir::affine::isMoveBind {hir e} {
    return [expr {[dict exists $hir affine moves $e] || [dict exists $hir exprs $e affineMove]}]
}

# The temporaries (ExprIds) any release item of HIR names: the values a
# backend must keep reachable by name until they may be released
# (hir/lower.tcl gives each one a Core IR name).
proc hir::affine::temporaries {hir} {
    set result [dict create]
    foreach table {releases exits} {
        if {![dict exists $hir affine $table]} continue
        dict for {e items} [dict get $hir affine $table] {
            foreach item $items {
                if {[string match e* $item]} {
                    dict set result $item 1
                }
            }
        }
    }
    if {[dict exists $hir affine errorExits]} {
        dict for {e byName} [dict get $hir affine errorExits] {
            dict for {name items} $byName {
                foreach item $items {
                    if {[string match e* $item]} {
                        dict set result $item 1
                    }
                }
            }
        }
    }
    dict for {e node} [dict get $hir exprs] {
        foreach field {affineRelease affineExitRelease} {
            if {[dict exists $node $field]} {
                foreach item [dict get $node $field] {
                    if {[string match e* $item]} {
                        dict set result $item 1
                    }
                }
            }
        }
        if {[dict exists $node affineErrorRelease]} {
            dict for {name items} [dict get $node affineErrorRelease] {
                foreach item $items {
                    if {[string match e* $item]} {
                        dict set result $item 1
                    }
                }
            }
        }
    }
    return $result
}

# ---------------------------------------------------------------------------
# Drop glue: how a value of a type is released

# The static drop descriptor of a value of TYPE (minus the fields EXCLUDE of
# a struct), or "" when it owns nothing affine. A string, the same for every
# runtime (core/affine.tcl, native/src/runtime/affine.rs):
#
#   c                      a coroutine handle: release it (coroutine#release)
#   l D                    a List: drop every element by D, in index order
#   v D                    a MutableVector: drop every live element by D,
#                          lowest index first, leaving it empty
#   a D                    a MutableArray: drop every element by D, lowest
#                          index first
#   s N . (SLOT . D)*N     a struct: drop field SLOT (its index in the
#                          struct's layout) by D, for each of its N affine
#                          fields, in reverse layout (declaration) order
#
# (numbers in decimal, each followed by "."): a struct whose field 1 is a
# coroutine is "s1.1.c", a List of them "ls1.1.c". One deterministic order: a
# struct's fields last-declared first (the reverse of construction order for
# a struct written in declaration order), a List's elements first to last.
# Releases are unobservable, so the order changes no value; it is fixed so
# runtime behavior is reproducible (AFFINE-VALUES.md, "Drop glue").
proc hir::affine::Descriptor {hir type {exclude {}}} {
    if {[hir::types::AffineRoot $type]} {
        return c
    }
    if {[hir::types::IsList $type]} {
        set inner [Descriptor $hir [lindex $type 1]]
        if {$inner eq ""} {
            return ""
        }
        return "l$inner"
    }
    if {[hir::types::IsMutVec $type]} {
        # A MutableVector drops its live elements, first to last
        # (MUTABLE-VECTOR.md), and is left empty.
        set inner [Descriptor $hir [lindex $type 1]]
        if {$inner eq ""} {
            return ""
        }
        return "v$inner"
    }
    if {[hir::types::IsMutArray $type]} {
        # A MutableArray drops every element, first to last (MUTABLE-
        # ARRAY.md).
        set inner [Descriptor $hir [lindex $type 1]]
        if {$inner eq ""} {
            return ""
        }
        return "a$inner"
    }
    if {[hir::types::IsStructLike $type]} {
        set layout [hir::types::StructLayout $type]
        set parts {}
        set n 0
        set slot [llength $layout]
        foreach name [lreverse $layout] {
            incr slot -1
            if {$name in $exclude} continue
            set d [Descriptor $hir [hir::types::StructField $type $name]]
            if {$d ne ""} {
                append parts "$slot.$d"
                incr n
            }
        }
        if {$n == 0} {
            return ""
        }
        return "s$n.$parts"
    }
    return ""
}

# The affine components of construction E -- a struct, or a List literal
# (the `list` native) -- whose value is released as a whole: {EXPR TYPE ...}
# for every operand that owns something affine, a nested construction by its
# own components. A backend that does not build a discarded construction
# (native lowering skips it) releases these instead: the same values, owned
# by nothing else.
proc hir::affine::Components {hir e} {
    set node [dict get $hir exprs $e]
    if {[dict get $node kind] eq "struct"} {
        set operands [dict get $node fields]
    } elseif {[dict get $node kind] eq "call" && [NativeName $hir $e] eq "list"} {
        set operands [dict get $node args]
    } else {
        return [list $e [hir::typeOf $hir $e]]
    }
    set result {}
    foreach o $operands {
        if {[hir::types::IsAffine [hir::typeOf $hir $o]]} {
            lappend result {*}[Components $hir $o]
        }
    }
    return $result
}

# The type of release item ITEM (a BindingId or an ExprId) and its excluded
# fields: {TYPE EXCLUDE}.
proc hir::affine::ItemType {hir item} {
    if {[string match b* $item]} {
        return [list [BindingType $hir $item] [ConsumedFields $hir $item]]
    }
    return [list [hir::typeOf $hir $item] {}]
}

# How release item ITEM is released: {coroutine} (coroutine#release), {drop
# DESCRIPTOR} (affine#drop), or "" (it owns nothing affine any more).
proc hir::affine::DropPlan {hir item} {
    lassign [ItemType $hir $item] type exclude
    set d [Descriptor $hir $type $exclude]
    if {$d eq ""} {
        return ""
    }
    if {$d eq "c"} {
        return {coroutine}
    }
    return [list drop $d]
}
