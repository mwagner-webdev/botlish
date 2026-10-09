#!/usr/bin/env tclsh9.0
# fuzz.tcl -- generated MutableVector programs against an independent model
# (MUTABLE-VECTOR.md).
#
#   tclsh9.0 audit/mutable-vector/tools/fuzz.tcl ?-n N? ?-seed S? ?-dump 1?
#                                                ?-backends LIST? ?-native 0|1?
#                                                ?-gc-stress 0|1?
#
# Each program is a driver function `drive()` -- a straight line of 5..18
# operations -- whose result is a List of observations (each a List of
# Ints). Programs alternate between two families: UNRESTRICTED (vectors of
# Ints, held in bindings and in a struct field, Bag {tag, items}) and AFFINE
# (vectors of coroutine handles and of affine structs, Job {id, step}, held
# in bindings and in a struct field, Queue {tag, items}). Every operation the
# milestone names is generated: from_list (and a typed empty constructor),
# a copy of an unrestricted vector (by a binding, and through functions that
# return their unmutated parameter, on some path or every path, typed or
# generic, bare or in an anonymous struct whose field becomes a place), a
# move of an affine one, length, empty?,
# unrestricted at, push, pop, take, swap (also with its affine result
# discarded), clear, a pass through a function that mutates its parameter
# and returns it, a function that mutates its parameter and returns only a
# count (the caller's vector is unchanged), growth across several capacities
# (a callee pushing 2..40 elements in a loop), storing a vector in a struct,
# mutating it through the field path, copying it out (unrestricted) or
# destructuring the struct (affine), iteration -- over an unrestricted
# vector's snapshot while the loop pushes onto it, and consuming an affine
# one with `continue`, `break` and moving the element into another vector --
# and `return`, `fail` and a propagated declared error out of a consuming
# loop, every failing operation (an empty pop, an out-of-range index) handled
# through IndexNotFound, and vectors still owning elements when they die.
#
# The model shares no code with the compiler or a runtime:
#
#   * unrestricted: every place (a vector binding, or a Bag's items field)
#     holds its own pure logical sequence (a Tcl list of Ints). A copy is
#     another equal sequence; a mutation changes only the sequence of the
#     place it names; a loop iterates the sequence as it was when the loop
#     began; a callee's mutations of its parameter change only its copy.
#     Physical sharing is not part of the model: copies are plain values.
#   * affine: every coroutine is an IDENTITY (its creation rank) with an
#     accumulator (a resume with Msg {v: X} yields acc + X and keeps it) and
#     exactly one owner -- a handle binding, a slot of a vector place, a
#     callee's parameter, a loop variable, or `dropped`. push moves the
#     element's owner into the vector's last slot; pop and take move a slot
#     out to the result binding (later slots shift down: the identity is the
#     same); swap moves the replacement into the slot and the slot's old
#     identity to the result -- or, out of range, drops the replacement; a
#     discarded result is dropped; clear and a vector's death drop its slots,
#     first to last; growth changes no identity. Every identity is dropped
#     exactly once by the time drive returns (it returns only Ints).
#
# Every accepted program's value is compared on every backend of BACKENDS
# against the model's. An affine program's releases are checked on the
# interpreter and the Tcl compiler against the model's obligations
# (core::coroutines::releaseCalls / releaseTrace): exactly the model's
# identities are released, each exactly once, and every group of slots the
# model drops together (a clear, a vector's death, a consuming loop) is
# released consecutively, first slot first. Natively (-native 1), the
# runtime's counters: every identity released, none swept by a collection;
# with -gc-stress 1, the native run again with a collection at every
# allocation site, its value compared too.
#
# A third of the programs carry one fault, with the diagnostic the model
# predicts: a use of a handle after push/from_list/swap moved it, or of an
# affine vector after a whole move, a pass, a consuming loop or a store into
# a struct (USE-AFTER-MOVE); an affine `at` (AFFINE-VECTOR-COPY-OUT); a
# mutation of a temporary, or of an enclosing function's vector from a nested
# function (MUTABLE-VECTOR-RECEIVER); a nested function reading a vector its
# enclosing function mutates (MUTABLE-VECTOR-CAPTURE); an affine vector
# erased to `any` (AFFINE-ERASURE-UNSUPPORTED) or captured
# (AFFINE-CAPTURE-UNSUPPORTED); a projection of a Queue's vector field
# (AFFINE-FIELD-MOVE-REQUIRES-DESTRUCTURE); an element of the wrong type
# pushed (TYPE).

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set options [dict create -n 40 -seed 1 -dump 0 -backends {interp compile cranelift-generic cranelift} -native 1 -gc-stress 0]
foreach {option value} $argv {
    if {![dict exists $options $option]} {
        error "fuzz.tcl: unknown option $option"
    }
    dict set options $option $value
}
set argv {}
source [file join $root tests helpers.tcl]

set prelude {import coroutine
import mutable_vector

error Boom

struct Msg:
    v: int

struct Ev:
    v: int

struct Bag:
    tag: int
    items: MutableVector[int]

struct Job:
    id: int
    step: Coroutine{args: [Msg], return: Ev}

struct Queue:
    tag: int
    items: MutableVector[Coroutine{args: [Msg], return: Ev}]

fn w(acc: int, resume Msg) -> Ev:
    m = yield Ev {v: acc}
    w(acc + m.v)

fn make(acc: int) -> Coroutine{args: [Msg], return: Ev}:
    coroutine {step} = w(acc)
    step

fn ints() -> MutableVector[int]:
    mutable_vector::from_list([])

fn empty_queue() -> MutableVector[Coroutine{args: [Msg], return: Ev}]:
    mutable_vector::from_list([])

fn empty_jobs() -> MutableVector[Job]:
    mutable_vector::from_list([])

fn b2i(b: bool) -> int:
    if b:
        return 1
    0

fn contents(v: MutableVector[int]) -> List[int]:
    loop x in v:
        x

fn bump(v: MutableVector[int], x: int) -> MutableVector[int]:
    v.push(x)
    v

fn push_len(v: MutableVector[int], x: int) -> int:
    v.push(x)
    v.push(x)
    v.length()

fn grow(v: MutableVector[int], n: int) -> MutableVector[int]:
    loop i from 0 to n:
        v.push(i)
    v

fn ident(v: MutableVector[int]) -> MutableVector[int]:
    v

fn either(c: int, v: MutableVector[int]) -> MutableVector[int]:
    w = grow(ints(), 2)
    if c > 0:
        return w
    v

fn same(x):
    x

fn wrap(x):
    {data: x}

fn find(v: MutableVector[int], t: int) -> int:
    loop x in v:
        if x == t:
            return x + 100
    0

fn find_fail(v: MutableVector[int], t: int) -> int errors Boom:
    loop x in v:
        if x == t:
            fail Boom
    0

fn boom_if(x: int) -> int errors Boom:
    if x > 0:
        fail Boom
    x

fn pass_q(q: MutableVector[Coroutine{args: [Msg], return: Ev}], a: int) -> MutableVector[Coroutine{args: [Msg], return: Ev}]:
    q.push(make(a))
    q

fn fill(q: MutableVector[Coroutine{args: [Msg], return: Ev}], n: int, a: int) -> MutableVector[Coroutine{args: [Msg], return: Ev}]:
    loop i from 0 to n:
        q.push(make(a + i))
    q

fn fill_jobs(q: MutableVector[Job], n: int, a: int) -> MutableVector[Job]:
    loop i from 0 to n:
        q.push(Job {id: i, step: make(a + i)})
    q

fn drain(q: MutableVector[Coroutine{args: [Msg], return: Ev}], x: int) -> List[int]:
    loop c in q:
        e = c(Msg {v: x})
        e.v

fn drain_jobs(q: MutableVector[Job], x: int) -> List[int]:
    loop j in q:
        {step} = j
        e = step(Msg {v: x})
        e.v

fn first_over(q: MutableVector[Coroutine{args: [Msg], return: Ev}], t: int) -> int:
    loop c in q:
        e = c(Msg {v: 1})
        if e.v > t:
            return e.v
    0

fn fail_over(q: MutableVector[Coroutine{args: [Msg], return: Ev}], t: int) -> int errors Boom:
    loop c in q:
        e = c(Msg {v: 1})
        if e.v > t:
            fail Boom
    0

fn boom_over(q: MutableVector[Coroutine{args: [Msg], return: Ev}], t: int) -> int errors Boom:
    loop c in q:
        e = c(Msg {v: 1})
        n = boom_if(e.v - t)
        n
    0

fn any_take(x: any) -> int:
    1

}

# ---------------------------------------------------------------------------
# Random choice (a seeded linear congruential generator: reproducible)

proc Rand {n} {
    global seedState
    set seedState [expr {($seedState * 1103515245 + 12345) % 2147483648}]
    return [expr {($seedState / 65536) % $n}]
}

proc Pick {list} {
    return [lindex $list [Rand [llength $list]]]
}

proc Fresh {stateVar prefix} {
    upvar 1 $stateVar state
    dict incr state n
    return "$prefix[dict get $state n]"
}

proc Emit {stateVar args} {
    upvar 1 $stateVar state
    foreach line $args {
        dict lappend state lines $line
    }
}

# Records an observation: binding NAME (a List of Ints) with model value
# VALUES.
proc Observe {stateVar expr values} {
    upvar 1 $stateVar state
    set o [Fresh state o]
    Emit state "$o = $expr"
    dict lappend state observed $o
    dict lappend state expected $values
}

# An observation of one Int expression.
proc ObserveInt {stateVar expr value} {
    upvar 1 $stateVar state
    Observe state "\[$expr\]" [list $value]
}

# A handled element read: NAME = CALL, IndexNotFound giving FALLBACK.
proc Handled {stateVar name call fallback} {
    upvar 1 $stateVar state
    Emit state "$name = $call:" "    on IndexNotFound:" "        $fallback"
}

# ---------------------------------------------------------------------------
# Unrestricted programs
#
# State: places (place -> its sequence), frozen (copy sources no operation
# mutates -> their sequence: USource), bags (live Bag bindings), mutated
# (vector-owning bindings some operation mutates), lines, observed and
# expected (the observation bindings and their model values), n.

proc UPlaces {state} {
    return [dict keys [dict get $state places]]
}

proc UNewVector {stateVar values} {
    upvar 1 $stateVar state
    set v [Fresh state v]
    dict set state places $v $values
    return $v
}

proc UMutated {stateVar place} {
    upvar 1 $stateVar state
    dict set state mutated [lindex [split $place .] 0] 1
}

# Half the time, a push onto the copy PLACE just made (the final contents of
# every place then show whether the copy shares anything with its source).
proc UTouch {stateVar place} {
    upvar 1 $stateVar state
    if {[Rand 2]} {
        set x [Rand 10]
        Emit state "$place.push($x)"
        dict set state places $place [concat [dict get $state places $place] [list $x]]
        UMutated state $place
    }
}

# The source of a copy operation on place P (sequence SEQ): P itself, or,
# half the time, a new vector no operation ever mutates (a "frozen" binding,
# observed at the end). Only an unmutated source can expose a copy the
# compiler wrongly skipped: a mutated one is a place root, whose every value
# use is already a copy. Returns {SOURCE SEQUENCE}.
proc USource {stateVar p seq} {
    upvar 1 $stateVar state
    if {[Rand 2]} {
        return [list $p $seq]
    }
    set values {}
    set count [expr {1 + [Rand 4]}]
    for {set i 0} {$i < $count} {incr i} { lappend values [Rand 10] }
    set f [Fresh state f]
    Emit state "$f = mutable_vector::from_list(\[[join $values {, }]\])"
    dict set state frozen $f $values
    return [list $f $values]
}

proc UOperation {stateVar} {
    upvar 1 $stateVar state
    set places [UPlaces $state]
    set kinds {}
    if {[llength $places] < 5} { lappend kinds new new }
    if {$places ne {}} {
        lappend kinds copy length empty at at push push push pop pop take take swap swap clear \
            bump pushlen grow ident either same wrap bag loop loop find findfail contents
    }
    if {[dict get $state bags] ne {}} { lappend kinds bagcopy }
    set kind [Pick $kinds]
    set p [expr {$places eq {} ? "" : [Pick $places]}]
    set seq [expr {$p eq "" ? {} : [dict get $state places $p]}]
    set len [llength $seq]
    switch -- $kind {
        new {
            set values {}
            set count [Rand 5]
            for {set i 0} {$i < $count} {incr i} { lappend values [Rand 10] }
            set v [UNewVector state $values]
            if {$values eq {}} {
                # (an untyped `from_list([])` local is MutableVector[never])
                Emit state "$v = ints()"
            } else {
                Emit state "$v = mutable_vector::from_list(\[[join $values {, }]\])"
            }
        }
        copy {
            lassign [USource state $p $seq] p seq
            set v [UNewVector state $seq]
            Emit state "$v = $p"
            UTouch state $v
        }
        length { ObserveInt state "$p.length()" $len }
        empty { ObserveInt state "b2i($p.empty?())" [expr {$len == 0}] }
        at {
            set i [expr {[Rand [expr {$len + 2}]] - 1}]
            set x [Fresh state x]
            Handled state $x "mutable_vector::at($p, $i)" -1
            ObserveInt state $x [expr {$i >= 0 && $i < $len ? [lindex $seq $i] : -1}]
        }
        push {
            set x [Rand 10]
            Emit state "$p.push($x)"
            dict set state places $p [concat $seq [list $x]]
            UMutated state $p
        }
        pop {
            set x [Fresh state x]
            Handled state $x "$p.pop()" -1
            if {$len > 0} {
                ObserveInt state $x [lindex $seq end]
                dict set state places $p [lrange $seq 0 end-1]
            } else {
                ObserveInt state $x -1
            }
            UMutated state $p
        }
        take {
            set i [Rand [expr {$len + 1}]]
            set x [Fresh state x]
            Handled state $x "$p.take($i)" -1
            if {$i < $len} {
                ObserveInt state $x [lindex $seq $i]
                dict set state places $p [lreplace $seq $i $i]
            } else {
                ObserveInt state $x -1
            }
            UMutated state $p
        }
        swap {
            set i [Rand [expr {$len + 1}]]
            set y [Rand 10]
            set x [Fresh state x]
            Handled state $x "$p.swap($i, $y)" -1
            if {$i < $len} {
                ObserveInt state $x [lindex $seq $i]
                dict set state places $p [lreplace $seq $i $i $y]
            } else {
                ObserveInt state $x -1
            }
            UMutated state $p
        }
        clear {
            Emit state "$p.clear()"
            dict set state places $p {}
            UMutated state $p
        }
        bump {
            set x [Rand 10]
            set v [UNewVector state [concat $seq [list $x]]]
            Emit state "$v = bump($p, $x)"
        }
        ident {
            lassign [USource state $p $seq] p seq
            set v [UNewVector state $seq]
            Emit state "$v = ident($p)"
            UTouch state $v
        }
        either {
            lassign [USource state $p $seq] p seq
            set c [expr {[Rand 3] - 1}]
            set v [UNewVector state [expr {$c > 0 ? {0 1} : $seq}]]
            Emit state "$v = either($c, $p)"
            UTouch state $v
        }
        same {
            lassign [USource state $p $seq] p seq
            set v [UNewVector state $seq]
            Emit state "$v = same($p)"
            UTouch state $v
        }
        wrap {
            # A generic function's anonymous struct around the vector: a new
            # place (the struct's field), a copy of P.
            lassign [USource state $p $seq] p seq
            set w [Fresh state w]
            Emit state "$w = wrap($p)"
            dict set state places $w.data $seq
            UTouch state $w.data
        }
        pushlen {
            set x [Rand 10]
            ObserveInt state "push_len($p, $x)" [expr {$len + 2}]
        }
        grow {
            set count [Pick {2 3 5 8 9 17 33 40}]
            set values $seq
            for {set i 0} {$i < $count} {incr i} { lappend values $i }
            set v [UNewVector state $values]
            Emit state "$v = grow($p, $count)"
        }
        bag {
            set b [Fresh state b]
            Emit state "$b = Bag {tag: [Rand 10], items: $p}"
            dict lappend state bags $b
            dict set state places $b.items $seq
        }
        bagcopy {
            set from [Pick [dict get $state bags]]
            set b [Fresh state b]
            Emit state "$b = $from"
            dict lappend state bags $b
            dict set state places $b.items [dict get $state places $from.items]
        }
        loop {
            # Iterates P's sequence as it was; the body pushes onto R (P
            # itself, or another place).
            set r [Pick $places]
            set a [Rand 10]
            set b [Rand 10]
            set o [Fresh state o]
            set x [Fresh state x]
            Emit state "$o = loop $x in $p:" \
                "    if $x == $a:" "        continue" \
                "    if $x == $b:" "        break" \
                "    $r.push($x + 10)" \
                "    $x * 2"
            set collected {}
            foreach item $seq {
                if {$item == $a} continue
                if {$item == $b} break
                dict set state places $r [concat [dict get $state places $r] [list [expr {$item + 10}]]]
                lappend collected [expr {$item * 2}]
            }
            UMutated state $r
            dict lappend state observed $o
            dict lappend state expected $collected
        }
        find {
            set t [Rand 10]
            ObserveInt state "find($p, $t)" [expr {$t in $seq ? $t + 100 : 0}]
        }
        findfail {
            set t [Rand 10]
            set x [Fresh state x]
            Emit state "$x = find_fail($p, $t):" "    on Boom:" "        -1"
            ObserveInt state $x [expr {$t in $seq ? -1 : 0}]
        }
        contents {
            Observe state "contents($p)" $seq
        }
    }
}

proc UFault {stateVar} {
    upvar 1 $stateVar state
    set places [UPlaces $state]
    set kinds {temporary wrongtype}
    set bindings [lsearch -all -inline -glob $places v*]
    if {$places ne {}} { lappend kinds nestedmutation }
    set mutatedBindings [lmap v $bindings {expr {[dict exists $state mutated $v] ? $v : [continue]}}]
    if {$mutatedBindings ne {}} { lappend kinds capture }
    switch -- [Pick $kinds] {
        temporary {
            Emit state "ints().push(1)"
            return MUTABLE-VECTOR-RECEIVER
        }
        wrongtype {
            if {$places eq {}} {
                Emit state "late = mutable_vector::from_list(\[1\])" "late.push(\"s\")"
            } else {
                Emit state "[Pick $places].push(\"s\")"
            }
            return TYPE
        }
        nestedmutation {
            Emit state "fn nested() -> int:" "    [Pick $places].push(1)" "    1"
            return MUTABLE-VECTOR-RECEIVER
        }
        capture {
            Emit state "fn nested() -> int:" "    [Pick $mutatedBindings].length()"
            return MUTABLE-VECTOR-CAPTURE
        }
    }
}

proc UGenerate {} {
    set state [dict create places {} frozen {} bags {} mutated {} lines {} observed {} expected {} n 0]
    set count [expr {5 + [Rand 14]}]
    for {set i 0} {$i < $count} {incr i} {
        UOperation state
    }
    set code ""
    if {[Rand 3] == 0} {
        set code [UFault state]
    } else {
        # The final contents of every place, and of every frozen source.
        foreach p [UPlaces $state] {
            Observe state "contents($p)" [dict get $state places $p]
        }
        dict for {f values} [dict get $state frozen] {
            Observe state "contents($f)" $values
        }
    }
    return [list $state $code]
}

# ---------------------------------------------------------------------------
# Affine programs
#
# State:
#   accs       rank -> accumulator (one entry per identity ever created)
#   handles    live handle bindings -> rank
#   vecs       live vector places -> {KIND RANKS}: KIND co (coroutine
#              elements) or job (Job elements), RANKS the slots in order
#   queues     live Queue bindings (each NAME has the place NAME.items)
#   moved      moved binding names -> what moved them (faults use them)
#   groups     the rank lists dropped together, each in slot order
#   lines, observed, expected, n

proc ANew {stateVar acc} {
    upvar 1 $stateVar state
    set rank [dict size [dict get $state accs]]
    dict set state accs $rank $acc
    return $rank
}

proc ADrop {stateVar ranks} {
    upvar 1 $stateVar state
    if {$ranks ne {}} {
        dict lappend state groups $ranks
    }
}

proc AMoved {stateVar name how} {
    upvar 1 $stateVar state
    dict set state moved $name $how
}

proc AResume {stateVar rank x} {
    upvar 1 $stateVar state
    set acc [expr {[dict get $state accs $rank] + $x}]
    dict set state accs $rank $acc
    return $acc
}

proc AVectors {state {kind ""} {bindingsOnly 0}} {
    set out {}
    dict for {p info} [dict get $state vecs] {
        if {$kind ne "" && [lindex $info 0] ne $kind} continue
        if {$bindingsOnly && [string first . $p] >= 0} continue
        lappend out $p
    }
    return $out
}

# Takes a live handle binding out of the state (it moves): {NAME RANK}.
proc ATakeHandle {stateVar how} {
    upvar 1 $stateVar state
    set c [Pick [dict keys [dict get $state handles]]]
    set rank [dict get $state handles $c]
    dict unset state handles $c
    AMoved state $c $how
    return [list $c $rank]
}

# The element expression for handle C in a vector of KIND.
proc AElement {stateVar kind c} {
    upvar 1 $stateVar state
    return [expr {$kind eq "co" ? $c : "Job {id: [Rand 10], step: $c}"}]
}

# Reads an element out: NAME (a handle binding) = CALL, IndexNotFound
# giving a fresh coroutine (accumulator 77). RANK is the identity CALL
# gives, or "" when it fails (the fallback is a new identity then).
proc AElementOut {stateVar kind call rank} {
    upvar 1 $stateVar state
    set c [Fresh state c]
    if {$kind eq "co"} {
        Handled state $c $call "make(77)"
    } else {
        set j [Fresh state j]
        Handled state $j $call "Job {id: 0, step: make(77)}"
        Emit state "{step: $c} = $j"
    }
    if {$rank eq ""} {
        set rank [ANew state 77]
    }
    dict set state handles $c $rank
}

proc AOperation {stateVar} {
    upvar 1 $stateVar state
    set handles [dict keys [dict get $state handles]]
    set vectors [AVectors $state]
    set bindingVectors [AVectors $state "" 1]
    set coVectors [AVectors $state co]
    set coBindings [AVectors $state co 1]
    set kinds {make make}
    if {$handles ne {}} { lappend kinds resume newvec }
    if {[llength $vectors] < 4} { lappend kinds newvec newvec fillnew }
    if {$vectors ne {}} { lappend kinds length empty pop pop take take clear }
    if {$vectors ne {} && $handles ne {}} { lappend kinds push push push swap swap discardswap }
    if {$bindingVectors ne {}} { lappend kinds move drain fill }
    if {$coBindings ne {}} { lappend kinds pass loop loop over queue }
    if {[dict get $state queues] ne {}} { lappend kinds unqueue }
    set kind [Pick $kinds]
    switch -- $kind {
        make {
            set c [Fresh state c]
            set acc [Rand 10]
            Emit state "$c = make($acc)"
            dict set state handles $c [ANew state $acc]
        }
        resume {
            set c [Pick $handles]
            set x [Rand 5]
            set e [Fresh state e]
            Emit state "$e = ${c}(Msg {v: $x})"
            ObserveInt state "$e.v" [AResume state [dict get $state handles $c] $x]
        }
        newvec {
            set kind [Pick {co co job}]
            set q [Fresh state [expr {$kind eq "co" ? "q" : "jq"}]]
            set count [expr {$handles eq {} ? 0 : [Rand 4]}]
            set ranks {}
            set elements {}
            for {set i 0} {$i < $count && [dict size [dict get $state handles]] > 0} {incr i} {
                lassign [ATakeHandle state from_list] c rank
                lappend ranks $rank
                lappend elements [AElement state $kind $c]
            }
            if {$elements eq {}} {
                Emit state "$q = [expr {$kind eq "co" ? "empty_queue()" : "empty_jobs()"}]"
            } else {
                Emit state "$q = mutable_vector::from_list(\[[join $elements {, }]\])"
            }
            dict set state vecs $q [list $kind $ranks]
        }
        fillnew {
            set kind [Pick {co job}]
            set q [Fresh state [expr {$kind eq "co" ? "q" : "jq"}]]
            set count [Pick {2 3 5 9 17}]
            set acc [Rand 10]
            set ranks {}
            for {set i 0} {$i < $count} {incr i} { lappend ranks [ANew state [expr {$acc + $i}]] }
            if {$kind eq "co"} {
                Emit state "$q = fill(empty_queue(), $count, $acc)"
            } else {
                Emit state "$q = fill_jobs(empty_jobs(), $count, $acc)"
            }
            dict set state vecs $q [list $kind $ranks]
        }
        length {
            set p [Pick $vectors]
            ObserveInt state "$p.length()" [llength [lindex [dict get $state vecs $p] 1]]
        }
        empty {
            set p [Pick $vectors]
            ObserveInt state "b2i($p.empty?())" [expr {[llength [lindex [dict get $state vecs $p] 1]] == 0}]
        }
        push {
            set p [Pick $vectors]
            lassign [dict get $state vecs $p] vkind ranks
            lassign [ATakeHandle state push] c rank
            Emit state "$p.push([AElement state $vkind $c])"
            dict set state vecs $p [list $vkind [concat $ranks [list $rank]]]
        }
        pop - take {
            set p [Pick $vectors]
            lassign [dict get $state vecs $p] vkind ranks
            set len [llength $ranks]
            if {$kind eq "pop"} {
                set i [expr {$len - 1}]
                set call "$p.pop()"
            } else {
                set i [Rand [expr {$len + 1}]]
                set call "$p.take($i)"
            }
            if {$i >= 0 && $i < $len} {
                set rank [lindex $ranks $i]
                dict set state vecs $p [list $vkind [lreplace $ranks $i $i]]
            } else {
                set rank ""
            }
            AElementOut state $vkind $call $rank
        }
        swap {
            set p [Pick $vectors]
            lassign [dict get $state vecs $p] vkind ranks
            set len [llength $ranks]
            set i [Rand [expr {$len + 1}]]
            lassign [ATakeHandle state swap] c rank
            set call "$p.swap($i, [AElement state $vkind $c])"
            if {$i < $len} {
                set old [lindex $ranks $i]
                dict set state vecs $p [list $vkind [lreplace $ranks $i $i $rank]]
            } else {
                # The replacement is dropped by the failing swap.
                ADrop state [list $rank]
                set old ""
            }
            AElementOut state $vkind $call $old
        }
        discardswap {
            set p [Pick $vectors]
            lassign [dict get $state vecs $p] vkind ranks
            set len [llength $ranks]
            set i [Rand [expr {$len + 1}]]
            lassign [ATakeHandle state swap] c rank
            set fallback [expr {$vkind eq "co" ? "make(77)" : "Job {id: 0, step: make(77)}"}]
            Emit state "$p.swap($i, [AElement state $vkind $c]):" "    on IndexNotFound:" "        $fallback"
            if {$i < $len} {
                set old [lindex $ranks $i]
                dict set state vecs $p [list $vkind [lreplace $ranks $i $i $rank]]
                ADrop state [list $old]
            } else {
                ADrop state [list $rank]
                ADrop state [list [ANew state 77]]
            }
        }
        clear {
            set p [Pick $vectors]
            lassign [dict get $state vecs $p] vkind ranks
            Emit state "$p.clear()"
            ADrop state $ranks
            dict set state vecs $p [list $vkind {}]
        }
        move {
            set p [Pick $bindingVectors]
            set info [dict get $state vecs $p]
            set q [Fresh state [expr {[lindex $info 0] eq "co" ? "q" : "jq"}]]
            Emit state "$q = $p"
            dict unset state vecs $p
            dict set state vecs $q $info
            AMoved state $p move
        }
        pass {
            set p [Pick $coBindings]
            set ranks [lindex [dict get $state vecs $p] 1]
            set q [Fresh state q]
            set acc [Rand 10]
            Emit state "$q = pass_q($p, $acc)"
            dict unset state vecs $p
            dict set state vecs $q [list co [concat $ranks [list [ANew state $acc]]]]
            AMoved state $p pass
        }
        fill {
            set p [Pick $bindingVectors]
            lassign [dict get $state vecs $p] vkind ranks
            set count [Pick {2 3 5 9 17 30}]
            set acc [Rand 10]
            for {set i 0} {$i < $count} {incr i} { lappend ranks [ANew state [expr {$acc + $i}]] }
            set q [Fresh state [expr {$vkind eq "co" ? "q" : "jq"}]]
            Emit state "$q = [expr {$vkind eq "co" ? "fill" : "fill_jobs"}]($p, $count, $acc)"
            dict unset state vecs $p
            dict set state vecs $q [list $vkind $ranks]
            AMoved state $p pass
        }
        drain {
            set p [Pick $bindingVectors]
            lassign [dict get $state vecs $p] vkind ranks
            set x [Rand 5]
            Observe state "[expr {$vkind eq "co" ? "drain" : "drain_jobs"}]($p, $x)" \
                [lmap rank $ranks {AResume state $rank $x}]
            ADrop state $ranks
            dict unset state vecs $p
            AMoved state $p loop
        }
        loop {
            # Consumes P: continue, keeping an element in another vector,
            # break.
            set p [Pick $coBindings]
            set ranks [lindex [dict get $state vecs $p] 1]
            set others [lsearch -all -inline -exact -not $coVectors $p]
            set keep [expr {$others eq {} ? "" : [Pick $others]}]
            set x [Rand 4]
            set a [Rand 12]
            set k [Rand 12]
            set b [Rand 12]
            set c [Fresh state cl]
            set e [Fresh state el]
            set o [Fresh state o]
            Emit state "$o = loop $c in $p:" "    $e = ${c}(Msg {v: $x})" \
                "    if $e.v == $a:" "        continue"
            if {$keep ne ""} {
                Emit state "    if $e.v == $k:" "        $keep.push($c)" "        continue"
            }
            Emit state "    if $e.v == $b:" "        break" "    $e.v"
            set dropped {}
            set collected {}
            set index 0
            foreach rank $ranks {
                incr index
                set v [AResume state $rank $x]
                if {$v == $a} {
                    lappend dropped $rank
                    continue
                }
                if {$keep ne "" && $v == $k} {
                    lassign [dict get $state vecs $keep] vkind kept
                    dict set state vecs $keep [list $vkind [concat $kept [list $rank]]]
                    continue
                }
                lappend dropped $rank
                if {$v == $b} {
                    lappend dropped {*}[lrange $ranks $index end]
                    break
                }
                lappend collected $v
            }
            ADrop state $dropped
            dict unset state vecs $p
            AMoved state $p loop
            dict lappend state observed $o
            dict lappend state expected $collected
        }
        over {
            # Leaves a consuming loop in a callee: return, fail, or a
            # propagated error (boom_if fails once an event exceeds T).
            set p [Pick $coBindings]
            set ranks [lindex [dict get $state vecs $p] 1]
            set t [Rand 12]
            set how [Pick {first_over fail_over boom_over}]
            set hit ""
            foreach rank $ranks {
                set v [AResume state $rank 1]
                if {$v > $t} {
                    set hit $v
                    break
                }
            }
            if {$how eq "first_over"} {
                ObserveInt state "first_over($p, $t)" [expr {$hit eq "" ? 0 : $hit}]
            } else {
                set r [Fresh state x]
                Emit state "$r = ${how}($p, $t):" "    on Boom:" "        -1"
                ObserveInt state $r [expr {$hit eq "" ? 0 : -1}]
            }
            ADrop state $ranks
            dict unset state vecs $p
            AMoved state $p loop
        }
        queue {
            set p [Pick $coBindings]
            set h [Fresh state h]
            Emit state "$h = Queue {tag: [Rand 10], items: $p}"
            dict set state vecs $h.items [dict get $state vecs $p]
            dict unset state vecs $p
            dict lappend state queues $h
            AMoved state $p queue
        }
        unqueue {
            set h [Pick [dict get $state queues]]
            set q [Fresh state q]
            Emit state "{items: $q} = $h"
            dict set state vecs $q [dict get $state vecs $h.items]
            dict unset state vecs $h.items
            dict set state queues [lsearch -all -inline -exact -not [dict get $state queues] $h]
        }
    }
}

proc AFault {stateVar} {
    upvar 1 $stateVar state
    set kinds {temporary}
    set movedHandles {}
    set movedVectors {}
    dict for {name how} [dict get $state moved] {
        if {[string match c* $name]} {
            lappend movedHandles $name
        } elseif {[string match q* $name] || [string match jq* $name]} {
            lappend movedVectors $name
        }
    }
    if {$movedHandles ne {}} { lappend kinds handleaftermove }
    if {$movedVectors ne {}} { lappend kinds vectoraftermove }
    set vectors [AVectors $state]
    set bindings [AVectors $state "" 1]
    if {$vectors ne {}} { lappend kinds at wrongtype }
    if {$bindings ne {}} { lappend kinds erase capture }
    if {[dict get $state queues] ne {}} { lappend kinds project }
    switch -- [Pick $kinds] {
        temporary {
            Emit state "empty_queue().push(make(1))"
            return MUTABLE-VECTOR-RECEIVER
        }
        handleaftermove {
            Emit state "late = coroutine::done?([Pick $movedHandles])"
            return USE-AFTER-MOVE
        }
        vectoraftermove {
            Emit state "late = [Pick $movedVectors].length()"
            return USE-AFTER-MOVE
        }
        at {
            set p [Pick $vectors]
            set fallback [expr {[lindex [dict get $state vecs $p] 0] eq "co" ? "make(1)" : "Job {id: 0, step: make(1)}"}]
            Handled state late "mutable_vector::at($p, 0)" $fallback
            return AFFINE-VECTOR-COPY-OUT
        }
        wrongtype {
            Emit state "[Pick $vectors].push(5)"
            return TYPE
        }
        erase {
            Emit state "late = any_take([Pick $bindings])"
            return AFFINE-ERASURE-UNSUPPORTED
        }
        capture {
            Emit state "fn peek() -> int:" "    [Pick $bindings].length()"
            return AFFINE-CAPTURE-UNSUPPORTED
        }
        project {
            Emit state "late = [Pick [dict get $state queues]].items"
            return AFFINE-FIELD-MOVE-REQUIRES-DESTRUCTURE
        }
    }
}

proc AGenerate {} {
    set state [dict create accs {} handles {} vecs {} queues {} moved {} groups {} \
        lines {} observed {} expected {} n 0]
    set count [expr {5 + [Rand 14]}]
    for {set i 0} {$i < $count} {incr i} {
        AOperation state
    }
    set code ""
    if {[Rand 3] == 0} {
        set code [AFault state]
    } else {
        # What is still owned dies with drive: a handle alone, a vector (or
        # a Queue's) slots together, first to last.
        dict for {c rank} [dict get $state handles] {
            ADrop state [list $rank]
        }
        dict for {p info} [dict get $state vecs] {
            ADrop state [lindex $info 1]
        }
    }
    return [list $state $code]
}

# ---------------------------------------------------------------------------
# Programs, checks and the run

proc Show {observations} {
    return "\[[join [lmap o $observations {string cat "\[" [join $o {, }] "\]"}] {, }]\]"
}

proc Generate {number} {
    set family [expr {$number % 2 ? "affine" : "unrestricted"}]
    if {$family eq "unrestricted"} {
        lassign [UGenerate] state code
    } else {
        lassign [AGenerate] state code
    }
    set body [join [lmap line [dict get $state lines] {string cat "    " $line}] \n]
    set result "\[[join [dict get $state observed] {, }]\]"
    set text "${::prelude}fn drive() -> List\[List\[int\]\]:\n$body\n    $result\n\ndrive()\n"
    set expect [expr {$code ne "" ? [list error $code] : [list value [Show [dict get $state expected]]]}]
    set identities [expr {$family eq "affine" ? [dict size [dict get $state accs]] : 0}]
    set groups [expr {$family eq "affine" ? [dict get $state groups] : {}}]
    return [list $family $text $expect $identities $groups]
}

# The release obligations on BACKEND (interp or compile): "" or a problem.
proc CheckReleases {backend hir identities groups} {
    set before $core::coroutines::nextId
    set core::coroutines::releaseCalls {}
    set core::coroutines::releaseTrace {}
    try {
        outcomeUnderHir $backend $hir
        set calls $core::coroutines::releaseCalls
        set trace $core::coroutines::releaseTrace
    } finally {
        set core::coroutines::releaseCalls none
        set core::coroutines::releaseTrace none
    }
    set created [expr {$core::coroutines::nextId - $before}]
    if {$created != $identities} {
        return "$backend: created $created coroutines, the model $identities"
    }
    for {set rank 0} {$rank < $identities} {incr rank} {
        set n [llength [lsearch -all -exact $calls [expr {$before + 1 + $rank}]]]
        if {$n != 1} {
            return "$backend: identity $rank released $n times ($calls)"
        }
    }
    set order [lmap id $trace {expr {$id - $before - 1}}]
    foreach group $groups {
        set first [lsearch -exact $order [lindex $group 0]]
        if {$first < 0 || [lrange $order $first [expr {$first + [llength $group] - 1}]] ne $group} {
            return "$backend: slots $group were not released together in order (release order $order)"
        }
    }
    return ""
}

proc Run {} {
    global options
    set backends [dict get $options -backends]
    set accepted 0
    set rejected 0
    set codes [dict create]
    set families [dict create]
    set disagreements 0
    set identitiesChecked 0
    for {set p 0} {$p < [dict get $options -n]} {incr p} {
        set number [expr {[dict get $options -seed] + $p}]
        set ::seedState [expr {$number * 7919 + 17}]
        lassign [Generate $number] family text expect identities groups
        dict incr families $family
        if {[dict get $options -dump]} {
            puts "--- program $number ($family)\n$text--- expect $expect"
        }
        set problem ""
        if {[catch {surface::compile $text -warnings off} hir errOptions]} {
            set got [list error [lindex [dict get $errOptions -errorcode] end]]
            if {$got ne $expect} {
                set problem "rejected [lindex $got 1]: $hir\noracle expects $expect"
            } else {
                incr rejected
                dict incr codes [lindex $got 1]
            }
        } elseif {[lindex $expect 0] eq "error"} {
            set problem "accepted; oracle expects [lindex $expect 1]"
        } else {
            foreach b $backends {
                set o [lrange [outcomeUnderHir $b $hir] 0 1]
                if {$o ne $expect} {
                    set problem "$b gives $o, oracle $expect"
                    break
                }
            }
            if {$problem eq "" && $family eq "affine"} {
                foreach b {interp compile} {
                    if {$b ni $backends} continue
                    set problem [CheckReleases $b $hir $identities $groups]
                    if {$problem ne ""} break
                }
                incr identitiesChecked $identities
            }
            set nativeOk [expr {$::tcl_platform(os) eq "Linux" && $::tcl_platform(machine) in {x86_64 amd64}}]
            if {$problem eq "" && $family eq "affine" && $identities > 0 && [dict get $options -native] && $nativeOk} {
                set report [native::allocationReport $hir summary]
                set counters [expr {[dict exists $report coroutines] ? [dict get $report coroutines] : {}}]
                if {$counters eq {} || [dict get $counters released] != $identities || [dict get $counters sweptSuspended] != 0} {
                    set problem "native release counters $counters for $identities identities"
                }
            }
            if {$problem eq "" && [dict get $options -gc-stress] && $nativeOk} {
                set ::env(BOTLISH_NATIVE_GC_STRESS) 1
                try {
                    set o [lrange [outcomeUnderHir cranelift $hir] 0 1]
                } finally {
                    unset ::env(BOTLISH_NATIVE_GC_STRESS)
                }
                if {$o ne $expect} {
                    set problem "cranelift under GC stress gives $o, oracle $expect"
                }
            }
            if {$problem eq ""} {
                incr accepted
            }
        }
        if {$problem ne ""} {
            incr disagreements
            puts "DISAGREEMENT program $number ($family):\n$problem\n--- program\n$text"
        }
    }
    puts "families: [join [lmap {f n} [lsort -stride 2 [dict get $families]] {string cat "$f $n"}] {, }]"
    puts "accepted $accepted rejected $rejected ([join [lmap {c n} [lsort -stride 2 [dict get $codes]] {string cat "$c $n"}] {, }])"
    puts "identities whose releases were checked: $identitiesChecked"
    puts "programs [dict get $options -n] disagreements $disagreements"
    return $disagreements
}

exit [expr {[Run] > 0 ? 1 : 0}]
