#!/usr/bin/env tclsh9.0
# fuzz.tcl -- generated MutableArray programs against an independent model
# (MUTABLE-ARRAY.md).
#
#   tclsh9.0 audit/mutable-array/tools/fuzz.tcl ?-n N? ?-seed S? ?-dump 1?
#                                               ?-backends LIST? ?-native 0|1?
#                                               ?-gc-stress 0|1?
#
# Each program is a driver function `drive(zero)` -- a straight line of 5..18
# operations -- whose result is a List of observations (each a List of
# Ints). Every index is written `I + zero` (drive is called with 0): an
# array's length is often known statically, and a statically known failure
# is a compile-time KNOWN-ERROR, so the index must not be. Programs alternate between two families:
#
#   UNRESTRICTED  arrays of Ints, held in bindings and in a struct field (Box
#                 {tag, values}), and arrays of MutableVector[Int] (a repeated
#                 create of a vector). The operations: create (a repeated
#                 Int, or a repeated vector), from_list, generate with a
#                 factory, a copy of an array by a binding and through every
#                 route MUTABLE-ARRAY.md names -- a typed identity, a function
#                 returning its unmutated parameter on some path, a generic
#                 identity and a generic wrapper ({data: x}, whose field
#                 becomes a place), a struct field, a List element and a
#                 MutableVector element -- where the source is, half the
#                 time, a fresh array no operation ever mutates (the route
#                 that let a skipped copy go unnoticed, MUTABLE-VECTOR.md),
#                 capacity, at, set, swap, mutable_array::copy (memmove
#                 semantics, every slice checked before anything moves), a
#                 function that mutates its parameter (the caller's array is
#                 unchanged) or returns it, iteration over a snapshot while
#                 the loop mutates the array, and early exits from a loop.
#   AFFINE        arrays of coroutine handles and of affine structs (Job
#                 {id, step}), held in bindings and in a struct field (Pool
#                 {tag, items}): generate with a factory (one coroutine per
#                 slot), a factory that fails at slot K (the K coroutines it
#                 made are released, in order; the error propagates), swap
#                 (also with its result discarded, and out of range: the
#                 failing swap releases the replacement), a whole move, a
#                 pass through a function that swaps a slot and returns the
#                 array, storing it in a struct and destructuring it back, a
#                 MutableVector of arrays (push moves the array in, pop moves
#                 it out), consuming loops -- with `continue` and `break`,
#                 and in a callee leaving by `return`, `fail` and a
#                 propagated declared error -- and arrays still owning
#                 coroutines when they die.
#
# The model shares no code with the compiler or a runtime:
#
#   * unrestricted: every place holds its own pure logical sequence (a Tcl
#     list). A copy is another equal sequence; a mutation changes only the
#     sequence of the place it names; a loop iterates the sequence as it was
#     when the loop began; a callee's mutations of its parameter change only
#     its copy. Physical sharing is not part of the model.
#   * affine: every coroutine is an IDENTITY (its creation rank) with an
#     accumulator (a resume with Msg {v: X} yields acc + X and keeps it) and
#     exactly one owner -- a handle binding, a slot of an array place, a
#     callee's parameter, a loop variable, or `dropped`. swap moves the
#     replacement into the slot and the slot's old identity to the result --
#     or, out of range, drops the replacement; a discarded result is
#     dropped; an array's death and a consuming loop drop its slots first to
#     last. Every identity is dropped exactly once by the time drive returns.
#
# Every accepted program's value is compared on every backend of BACKENDS
# against the model's. An affine program's releases are checked on the
# interpreter and the Tcl compiler against the model's obligations
# (core::coroutines::releaseCalls / releaseTrace): exactly the model's
# identities are released, each exactly once, and every group of slots the
# model drops together (an array's death, a failed generate, a consuming
# loop) consecutively, first slot first. Natively (-native 1), the runtime's
# counters: every identity released, none swept by a collection; with
# -gc-stress 1, the native run again with a collection at every allocation
# site.
#
# A third of the programs carry one fault, with the diagnostic the model
# predicts: a use of a handle after a swap or a factory-free move took it,
# or of an affine array after a whole move, a pass, a consuming loop or a
# store into a struct or a vector (USE-AFTER-MOVE); an affine `at`
# (AFFINE-ELEMENT-COPY-OUT); create repeating a handle
# (AFFINE-DUPLICATION-UNSUPPORTED); a mutation of a temporary, or of an
# enclosing function's array from a nested function
# (MUTABLE-PLACE-RECEIVER); a nested function reading an array its
# enclosing function mutates (MUTABLE-PLACE-CAPTURE); an affine array erased
# to `any` (AFFINE-ERASURE-UNSUPPORTED) or captured
# (AFFINE-CAPTURE-UNSUPPORTED); a projection of a Pool's array field
# (AFFINE-FIELD-MOVE-REQUIRES-DESTRUCTURE); an element of the wrong type
# stored (TYPE).

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
import list
import mutable_array
import mutable_vector

error Boom

struct Msg:
    v: int

struct Ev:
    v: int

struct Box:
    tag: int
    values: MutableArray[int]

struct Job:
    id: int
    step: Coroutine{args: [Msg], return: Ev}

struct Pool:
    tag: int
    items: MutableArray[Coroutine{args: [Msg], return: Ev}]

fn w(acc: int, resume Msg) -> Ev:
    m = yield Ev {v: acc}
    w(acc + m.v)

fn make(acc: int) -> Coroutine{args: [Msg], return: Ev}:
    coroutine {step} = w(acc)
    step

fn mk0(i: int) -> Coroutine{args: [Msg], return: Ev}:
    make(i)

fn mk10(i: int) -> Coroutine{args: [Msg], return: Ev}:
    make(i + 10)

fn mk20(i: int) -> Coroutine{args: [Msg], return: Ev}:
    make(i + 20)

fn job0(i: int) -> Job:
    Job {id: i, step: make(i)}

fn job10(i: int) -> Job:
    Job {id: i, step: make(i + 10)}

fn fail1(i: int) -> Coroutine{args: [Msg], return: Ev} errors Boom:
    if i == 1:
        fail Boom
    make(i + 30)

fn fail2(i: int) -> Coroutine{args: [Msg], return: Ev} errors Boom:
    if i == 2:
        fail Boom
    make(i + 30)

fn fail3(i: int) -> Coroutine{args: [Msg], return: Ev} errors Boom:
    if i == 3:
        fail Boom
    make(i + 30)

fn spare() -> MutableArray[Coroutine{args: [Msg], return: Ev}]:
    mutable_array::generate(1, mk20)

fn spare_jobs() -> MutableArray[Job]:
    mutable_array::generate(1, job10)

fn arrays() -> MutableVector[MutableArray[Coroutine{args: [Msg], return: Ev}]]:
    mutable_vector::from_list([])

fn tens(i: int) -> int:
    i * 10

fn sq(i: int) -> int:
    i * i

fn b2i(b: bool) -> int:
    if b:
        return 1
    0

fn contents(a: MutableArray[int]) -> List[int]:
    loop x in a:
        x

fn vcontents(v: MutableVector[int]) -> List[int]:
    loop x in v:
        x

fn vslot(m: MutableArray[MutableVector[int]], i: int) -> List[int]:
    v = m.at(i):
        on IndexNotFound:
            mutable_vector::from_list([-1])
    vcontents(v)

fn vpush(m: MutableArray[MutableVector[int]], i: int, x: int) -> MutableArray[MutableVector[int]]:
    v = m.at(i):
        on IndexNotFound:
            return m
    v.push(x)
    m.set(i, v):
        on IndexNotFound:
            unit
    m

fn ident(a: MutableArray[int]) -> MutableArray[int]:
    a

fn either(c: int, a: MutableArray[int]) -> MutableArray[int]:
    w = mutable_array::create(2, 1)
    if c > 0:
        return w
    a

fn same(x):
    x

fn wrap(x):
    {data: x}

fn first_of(xs: List[MutableArray[int]]) -> MutableArray[int]:
    a = list::at(xs, 0):
        on IndexNotFound:
            mutable_array::create(0, 0)
    a

fn vfirst(v: MutableVector[MutableArray[int]]) -> MutableArray[int]:
    a = v.at(0):
        on IndexNotFound:
            mutable_array::create(0, 0)
    a

fn bump(a: MutableArray[int], i: int, x: int) -> MutableArray[int]:
    a.set(i, x):
        on IndexNotFound:
            unit
    a

fn set_count(a: MutableArray[int], x: int) -> int:
    a.set(0, x):
        on IndexNotFound:
            unit
    a.capacity()

fn find(a: MutableArray[int], t: int) -> int:
    loop x in a:
        if x == t:
            return x + 100
    0

fn find_fail(a: MutableArray[int], t: int) -> int errors Boom:
    loop x in a:
        if x == t:
            fail Boom
    0

fn boom_if(x: int) -> int errors Boom:
    if x > 0:
        fail Boom
    x

fn pass_q(q: MutableArray[Coroutine{args: [Msg], return: Ev}], i: int, acc: int) -> MutableArray[Coroutine{args: [Msg], return: Ev}]:
    old = q.swap(i, make(acc)):
        on IndexNotFound:
            make(77)
    q

fn drain(q: MutableArray[Coroutine{args: [Msg], return: Ev}], x: int) -> List[int]:
    loop c in q:
        e = c(Msg {v: x})
        e.v

fn drain_jobs(q: MutableArray[Job], x: int) -> List[int]:
    loop j in q:
        {step} = j
        e = step(Msg {v: x})
        e.v

fn first_over(q: MutableArray[Coroutine{args: [Msg], return: Ev}], t: int) -> int:
    loop c in q:
        e = c(Msg {v: 1})
        if e.v > t:
            return e.v
    0

fn fail_over(q: MutableArray[Coroutine{args: [Msg], return: Ev}], t: int) -> int errors Boom:
    loop c in q:
        e = c(Msg {v: 1})
        if e.v > t:
            fail Boom
    0

fn boom_over(q: MutableArray[Coroutine{args: [Msg], return: Ev}], t: int) -> int errors Boom:
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

proc ObserveInt {stateVar expr value} {
    upvar 1 $stateVar state
    Observe state "\[$expr\]" [list $value]
}

# A handled call: NAME = CALL, IndexNotFound giving FALLBACK.
proc Handled {stateVar name call fallback} {
    upvar 1 $stateVar state
    Emit state "$name = $call:" "    on IndexNotFound:" "        $fallback"
}

proc Ints {count {limit 10}} {
    set values {}
    for {set i 0} {$i < $count} {incr i} { lappend values [Rand $limit] }
    return $values
}

# ---------------------------------------------------------------------------
# Unrestricted programs
#
# State: places (place -> its sequence: an array binding a*, or a Box's
# field b*.values), nests (array-of-vector bindings m* -> a list of
# sequences), frozen (copy sources no operation mutates -> their sequence),
# boxes (live Box bindings), mutated (array-owning bindings some operation
# mutates), lines, observed, expected, n.

proc UPlaces {state} {
    return [dict keys [dict get $state places]]
}

proc UNew {stateVar values} {
    upvar 1 $stateVar state
    set a [Fresh state a]
    dict set state places $a $values
    return $a
}

proc UMutated {stateVar place} {
    upvar 1 $stateVar state
    dict set state mutated [lindex [split $place .] 0] 1
}

# Half the time, a set of a slot of the copy PLACE just made (the final
# contents of every place then show whether the copy shares anything with its
# source).
proc UTouch {stateVar place} {
    upvar 1 $stateVar state
    set seq [dict get $state places $place]
    if {[Rand 2] && $seq ne {}} {
        set i [Rand [llength $seq]]
        set x [expr {50 + [Rand 10]}]
        Emit state "$place.set($i, $x):" "    on IndexNotFound:" "        unit"
        dict set state places $place [lreplace $seq $i $i $x]
        UMutated state $place
    }
}

# The source of a copy operation on place P (sequence SEQ): P itself, or,
# half the time, a fresh array no operation ever mutates (observed at the
# end). Only an unmutated source exposes a copy the compiler wrongly
# skipped. Returns {SOURCE SEQUENCE}.
proc USource {stateVar p seq} {
    upvar 1 $stateVar state
    if {[Rand 2]} {
        return [list $p $seq]
    }
    set values [Ints [expr {1 + [Rand 4]}]]
    set f [Fresh state f]
    Emit state "$f = mutable_array::from_list(\[[join $values {, }]\])"
    dict set state frozen $f $values
    return [list $f $values]
}

# mutable_array::copy(DST, DS, SRC, SS, N) on the model: every slice is
# checked before anything moves (destination first); an overlapping copy
# within one array reads the source as it was (memmove).
proc UCopyModel {dst ds src ss n} {
    if {$ds < 0 || $ds + $n > [llength $dst] || $ss < 0 || $ss + $n > [llength $src]} {
        return [list 0 $dst]
    }
    if {$n == 0} {
        return [list 1 $dst]
    }
    set slice [lrange $src $ss [expr {$ss + $n - 1}]]
    return [list 1 [lreplace $dst $ds [expr {$ds + $n - 1}] {*}$slice]]
}

proc UOperation {stateVar} {
    upvar 1 $stateVar state
    set places [UPlaces $state]
    set kinds {}
    if {[llength $places] < 5} { lappend kinds create fromlist generate }
    if {$places ne {}} {
        lappend kinds copy capacity at at set set swap swap copyop copyop \
            ident either same wrap box listget vecget bump setcount loop loop find findfail contents
    }
    if {[dict get $state boxes] ne {}} { lappend kinds boxcopy }
    if {[dict size [dict get $state nests]] < 2} { lappend kinds nest }
    if {[dict get $state nests] ne {}} { lappend kinds nestpush nestcopy }
    set kind [Pick $kinds]
    set p [expr {$places eq {} ? "" : [Pick $places]}]
    set seq [expr {$p eq "" ? {} : [dict get $state places $p]}]
    set len [llength $seq]
    switch -- $kind {
        create {
            set count [Rand 5]
            set x [Rand 10]
            set a [UNew state [lrepeat $count $x]]
            Emit state "$a = mutable_array::create($count, $x)"
        }
        fromlist {
            set values [Ints [expr {1 + [Rand 4]}]]
            set a [UNew state $values]
            Emit state "$a = mutable_array::from_list(\[[join $values {, }]\])"
        }
        generate {
            set count [Rand 5]
            set f [Pick {tens sq}]
            set values {}
            for {set i 0} {$i < $count} {incr i} {
                lappend values [expr {$f eq "tens" ? $i * 10 : $i * $i}]
            }
            set a [UNew state $values]
            Emit state "$a = mutable_array::generate($count, $f)"
        }
        copy {
            lassign [USource state $p $seq] p seq
            set a [UNew state $seq]
            Emit state "$a = $p"
            UTouch state $a
        }
        capacity { ObserveInt state "$p.capacity()" $len }
        at {
            set i [expr {[Rand [expr {$len + 2}]] - 1}]
            set x [Fresh state x]
            Handled state $x "mutable_array::at($p, $i + zero)" -1
            ObserveInt state $x [expr {$i >= 0 && $i < $len ? [lindex $seq $i] : -1}]
        }
        set {
            set i [expr {[Rand [expr {$len + 2}]] - 1}]
            set x [Rand 10]
            Emit state "$p.set($i + zero, $x):" "    on IndexNotFound:" "        unit"
            if {$i >= 0 && $i < $len} {
                dict set state places $p [lreplace $seq $i $i $x]
            }
            UMutated state $p
        }
        swap {
            set i [Rand [expr {$len + 1}]]
            set y [Rand 10]
            set x [Fresh state x]
            Handled state $x "$p.swap($i + zero, $y)" -1
            if {$i < $len} {
                ObserveInt state $x [lindex $seq $i]
                dict set state places $p [lreplace $seq $i $i $y]
            } else {
                ObserveInt state $x -1
            }
            UMutated state $p
        }
        copyop {
            set src [Pick [concat $places [dict keys [dict get $state frozen]]]]
            set srcSeq [expr {[dict exists $state places $src] ? [dict get $state places $src] : [dict get $state frozen $src]}]
            set ds [Rand [expr {$len + 2}]]
            set ss [Rand [expr {[llength $srcSeq] + 2}]]
            set n [Rand 4]
            Emit state "mutable_array::copy($p, $ds + zero, $src, $ss + zero, $n + zero):" \
                "    on LowerUnderrun:" "        unit" "    on UpperOverrun:" "        unit"
            lassign [UCopyModel $seq $ds $srcSeq $ss $n] ok after
            dict set state places $p $after
            UMutated state $p
        }
        ident {
            lassign [USource state $p $seq] p seq
            set a [UNew state $seq]
            Emit state "$a = ident($p)"
            UTouch state $a
        }
        either {
            lassign [USource state $p $seq] p seq
            set c [expr {[Rand 3] - 1}]
            set a [UNew state [expr {$c > 0 ? {1 1} : $seq}]]
            Emit state "$a = either($c, $p)"
            UTouch state $a
        }
        same {
            lassign [USource state $p $seq] p seq
            set a [UNew state $seq]
            Emit state "$a = same($p)"
            UTouch state $a
        }
        wrap {
            # A generic function's anonymous struct around the array: a new
            # place (the struct's field), a copy of P.
            lassign [USource state $p $seq] p seq
            set w [Fresh state w]
            Emit state "$w = wrap($p)"
            dict set state places $w.data $seq
            UTouch state $w.data
        }
        box {
            lassign [USource state $p $seq] p seq
            set b [Fresh state b]
            Emit state "$b = Box {tag: [Rand 10], values: $p}"
            dict lappend state boxes $b
            dict set state places $b.values $seq
            UTouch state $b.values
        }
        boxcopy {
            set from [Pick [dict get $state boxes]]
            set b [Fresh state b]
            Emit state "$b = $from"
            dict lappend state boxes $b
            dict set state places $b.values [dict get $state places $from.values]
            UTouch state $b.values
        }
        listget {
            # A List element read out: a copy of the array the List holds.
            lassign [USource state $p $seq] p seq
            set xs [Fresh state xs]
            set a [UNew state $seq]
            Emit state "$xs = \[$p\]" "$a = first_of($xs)"
            UTouch state $a
            Observe state "contents(first_of($xs))" $seq
        }
        vecget {
            # A MutableVector element read out: a copy of the array the
            # vector holds.
            lassign [USource state $p $seq] p seq
            set v [Fresh state vv]
            set a [UNew state $seq]
            Emit state "$v = mutable_vector::from_list(\[$p\])" "$a = vfirst($v)"
            UTouch state $a
            Observe state "contents(vfirst($v))" $seq
        }
        bump {
            set i [Rand [expr {$len + 1}]]
            set x [Rand 10]
            set a [UNew state [expr {$i < $len ? [lreplace $seq $i $i $x] : $seq}]]
            Emit state "$a = bump($p, $i, $x)"
        }
        setcount {
            ObserveInt state "set_count($p, [Rand 10])" $len
        }
        loop {
            # Iterates P's sequence as it was; the body sets slot 0 of R (P
            # itself, or another place).
            set r [Pick $places]
            set a [Rand 10]
            set b [Rand 10]
            set o [Fresh state o]
            set x [Fresh state x]
            Emit state "$o = loop $x in $p:" \
                "    if $x == $a:" "        continue" \
                "    if $x == $b:" "        break" \
                "    $r.set(0 + zero, $x + 10):" "        on IndexNotFound:" "            unit" \
                "    $x * 2"
            set collected {}
            foreach item $seq {
                if {$item == $a} continue
                if {$item == $b} break
                set rseq [dict get $state places $r]
                if {$rseq ne {}} {
                    dict set state places $r [lreplace $rseq 0 0 [expr {$item + 10}]]
                }
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
        nest {
            # A repeated vector: COUNT logical copies of one vector.
            set values [Ints [Rand 3]]
            set count [expr {1 + [Rand 3]}]
            set v [Fresh state v]
            set m [Fresh state m]
            if {$values eq {}} {
                Emit state "$v = mutable_vector::from_list(\[0\])"
                set values 0
            } else {
                Emit state "$v = mutable_vector::from_list(\[[join $values {, }]\])"
            }
            Emit state "$m = mutable_array::create($count, $v)"
            dict set state nests $m [lrepeat $count $values]
            dict set state frozenVectors $v $values
        }
        nestpush {
            set m [Pick [dict keys [dict get $state nests]]]
            set slots [dict get $state nests $m]
            set i [Rand [expr {[llength $slots] + 1}]]
            set x [Rand 10]
            set m2 [Fresh state m]
            Emit state "$m2 = vpush($m, $i, $x)"
            if {$i < [llength $slots]} {
                lset slots $i [concat [lindex $slots $i] [list $x]]
            }
            dict set state nests $m2 $slots
        }
        nestcopy {
            set m [Pick [dict keys [dict get $state nests]]]
            set m2 [Fresh state m]
            Emit state "$m2 = $m"
            dict set state nests $m2 [dict get $state nests $m]
        }
    }
}

proc UFault {stateVar} {
    upvar 1 $stateVar state
    set places [UPlaces $state]
    set kinds {temporary wrongtype}
    set bindings [lsearch -all -inline -glob $places a*]
    if {$places ne {}} { lappend kinds nestedmutation }
    set mutatedBindings [lmap a $bindings {expr {[dict exists $state mutated $a] ? $a : [continue]}}]
    if {$mutatedBindings ne {}} { lappend kinds capture }
    switch -- [Pick $kinds] {
        temporary {
            Emit state "mutable_array::create(1, 0).set(0, 1):" "    on IndexNotFound:" "        unit"
            return MUTABLE-PLACE-RECEIVER
        }
        wrongtype {
            set p [expr {$places eq {} ? "late" : [Pick $places]}]
            if {$places eq {}} {
                Emit state "late = mutable_array::from_list(\[1\])"
            }
            Emit state "$p.set(0, \"s\"):" "    on IndexNotFound:" "        unit"
            return TYPE
        }
        nestedmutation {
            Emit state "fn nested() -> int:" "    [Pick $places].set(0, 1):" "        on IndexNotFound:" "            unit" "    1"
            return MUTABLE-PLACE-RECEIVER
        }
        capture {
            Emit state "fn nested() -> int:" "    [Pick $mutatedBindings].capacity()"
            return MUTABLE-PLACE-CAPTURE
        }
    }
}

proc UGenerate {} {
    set state [dict create places {} frozen {} frozenVectors {} nests {} boxes {} mutated {} \
        lines {} observed {} expected {} n 0]
    set count [expr {5 + [Rand 14]}]
    for {set i 0} {$i < $count} {incr i} {
        UOperation state
    }
    set code ""
    if {[Rand 3] == 0} {
        set code [UFault state]
    } else {
        # The final contents of every place, every frozen source, every
        # repeated vector and every slot of every array of vectors.
        foreach p [UPlaces $state] {
            Observe state "contents($p)" [dict get $state places $p]
        }
        dict for {f values} [dict get $state frozen] {
            Observe state "contents($f)" $values
        }
        dict for {v values} [dict get $state frozenVectors] {
            Observe state "vcontents($v)" $values
        }
        dict for {m slots} [dict get $state nests] {
            set i 0
            foreach slot $slots {
                Observe state "vslot($m, $i)" $slot
                incr i
            }
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
#   arrs       live array places -> {KIND RANKS}: KIND co (coroutine
#              elements) or job (Job elements), RANKS the slots in order
#   pools      live Pool bindings (each NAME has the place NAME.items)
#   vecs       live MutableVector-of-arrays bindings -> a list of RANKS
#              lists (each a coroutine array it owns, in push order)
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

proc AArrays {state {kind ""} {bindingsOnly 0}} {
    set out {}
    dict for {p info} [dict get $state arrs] {
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

proc AElement {kind c} {
    return [expr {$kind eq "co" ? $c : "Job {id: [Rand 10], step: $c}"}]
}

# A generated array of KIND: COUNT slots from FACTORY (base accumulator
# BASE: slot i's identity starts at BASE + i).
proc AGenerated {stateVar kind count factory base} {
    upvar 1 $stateVar state
    set q [Fresh state [expr {$kind eq "co" ? "q" : "jq"}]]
    Emit state "$q = mutable_array::generate($count, $factory)"
    set ranks {}
    for {set i 0} {$i < $count} {incr i} { lappend ranks [ANew state [expr {$base + $i}]] }
    dict set state arrs $q [list $kind $ranks]
    return $q
}

# Reads an element out of a swap: NAME = CALL, IndexNotFound giving a fresh
# coroutine (accumulator 77). RANK is the identity CALL gives, or "" when it
# fails (the fallback is a new identity then).
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
    set arrays [AArrays $state]
    set bindingArrays [AArrays $state "" 1]
    set coBindings [AArrays $state co 1]
    set kinds {make generate generate}
    if {$handles ne {}} { lappend kinds resume }
    if {[llength $arrays] < 4} { lappend kinds generate genjobs genfail }
    if {$arrays ne {}} { lappend kinds capacity }
    if {$arrays ne {} && $handles ne {}} { lappend kinds swap swap discardswap }
    if {$bindingArrays ne {}} { lappend kinds move drain }
    if {$coBindings ne {}} { lappend kinds pass loop loop over pool vecpush }
    if {[dict get $state pools] ne {}} { lappend kinds unpool }
    if {[dict get $state vecs] ne {}} { lappend kinds vecpop }
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
        generate {
            set f [Pick {mk0 mk10 mk20}]
            AGenerated state co [Rand 5] $f [dict get {mk0 0 mk10 10 mk20 20} $f]
        }
        genjobs {
            set f [Pick {job0 job10}]
            AGenerated state job [Rand 4] $f [dict get {job0 0 job10 10} $f]
        }
        genfail {
            # A factory failing at slot K (fail1/2/3) when the array has more
            # than K slots: the K coroutines it made are released, first to
            # last, and Boom propagates to the handler, whose array is new.
            set k [expr {1 + [Rand 3]}]
            set count [Rand 5]
            set q [Fresh state q]
            Emit state "$q = mutable_array::generate($count, fail$k):" "    on Boom:" "        spare()"
            if {$count > $k} {
                set made {}
                for {set i 0} {$i < $k} {incr i} { lappend made [ANew state [expr {30 + $i}]] }
                ADrop state $made
                dict set state arrs $q [list co [list [ANew state 20]]]
            } else {
                set ranks {}
                for {set i 0} {$i < $count} {incr i} { lappend ranks [ANew state [expr {30 + $i}]] }
                dict set state arrs $q [list co $ranks]
            }
        }
        capacity {
            set p [Pick $arrays]
            ObserveInt state "$p.capacity()" [llength [lindex [dict get $state arrs $p] 1]]
        }
        swap {
            set p [Pick $arrays]
            lassign [dict get $state arrs $p] akind ranks
            set len [llength $ranks]
            set i [Rand [expr {$len + 1}]]
            lassign [ATakeHandle state swap] c rank
            set call "$p.swap($i + zero, [AElement $akind $c])"
            if {$i < $len} {
                set old [lindex $ranks $i]
                dict set state arrs $p [list $akind [lreplace $ranks $i $i $rank]]
            } else {
                # The replacement is dropped by the failing swap.
                ADrop state [list $rank]
                set old ""
            }
            AElementOut state $akind $call $old
        }
        discardswap {
            set p [Pick $arrays]
            lassign [dict get $state arrs $p] akind ranks
            set len [llength $ranks]
            set i [Rand [expr {$len + 1}]]
            lassign [ATakeHandle state swap] c rank
            set fallback [expr {$akind eq "co" ? "make(77)" : "Job {id: 0, step: make(77)}"}]
            Emit state "$p.swap($i + zero, [AElement $akind $c]):" "    on IndexNotFound:" "        $fallback"
            if {$i < $len} {
                set old [lindex $ranks $i]
                dict set state arrs $p [list $akind [lreplace $ranks $i $i $rank]]
                ADrop state [list $old]
            } else {
                ADrop state [list $rank]
                ADrop state [list [ANew state 77]]
            }
        }
        move {
            set p [Pick $bindingArrays]
            set info [dict get $state arrs $p]
            set q [Fresh state [expr {[lindex $info 0] eq "co" ? "q" : "jq"}]]
            Emit state "$q = $p"
            dict unset state arrs $p
            dict set state arrs $q $info
            AMoved state $p move
        }
        pass {
            # pass_q swaps a new coroutine (ACC) into slot I and returns the
            # array; the displaced one (or, out of range, the replacement
            # and the handler's make(77)) is released inside.
            set p [Pick $coBindings]
            set ranks [lindex [dict get $state arrs $p] 1]
            set len [llength $ranks]
            set i [Rand [expr {$len + 1}]]
            set acc [Rand 10]
            set q [Fresh state q]
            Emit state "$q = pass_q($p, $i + zero, $acc)"
            set new [ANew state $acc]
            if {$i < $len} {
                ADrop state [list [lindex $ranks $i]]
                set ranks [lreplace $ranks $i $i $new]
            } else {
                ADrop state [list $new]
                ADrop state [list [ANew state 77]]
            }
            dict unset state arrs $p
            dict set state arrs $q [list co $ranks]
            AMoved state $p pass
        }
        drain {
            set p [Pick $bindingArrays]
            lassign [dict get $state arrs $p] akind ranks
            set x [Rand 5]
            Observe state "[expr {$akind eq "co" ? "drain" : "drain_jobs"}]($p, $x)" \
                [lmap rank $ranks {AResume state $rank $x}]
            ADrop state $ranks
            dict unset state arrs $p
            AMoved state $p loop
        }
        loop {
            # Consumes P: continue, break.
            set p [Pick $coBindings]
            set ranks [lindex [dict get $state arrs $p] 1]
            set x [Rand 4]
            set a [Rand 30]
            set b [Rand 30]
            set c [Fresh state cl]
            set e [Fresh state el]
            set o [Fresh state o]
            Emit state "$o = loop $c in $p:" "    $e = ${c}(Msg {v: $x})" \
                "    if $e.v == $a:" "        continue" \
                "    if $e.v == $b:" "        break" "    $e.v"
            set collected {}
            set index 0
            foreach rank $ranks {
                incr index
                set v [AResume state $rank $x]
                if {$v == $a} continue
                if {$v == $b} break
                lappend collected $v
            }
            ADrop state $ranks
            dict unset state arrs $p
            AMoved state $p loop
            dict lappend state observed $o
            dict lappend state expected $collected
        }
        over {
            # Leaves a consuming loop in a callee: return, fail, or a
            # propagated error (boom_if fails once an event exceeds T).
            set p [Pick $coBindings]
            set ranks [lindex [dict get $state arrs $p] 1]
            set t [Rand 30]
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
            dict unset state arrs $p
            AMoved state $p loop
        }
        pool {
            set p [Pick $coBindings]
            set h [Fresh state h]
            Emit state "$h = Pool {tag: [Rand 10], items: $p}"
            dict set state arrs $h.items [dict get $state arrs $p]
            dict unset state arrs $p
            dict lappend state pools $h
            AMoved state $p pool
        }
        unpool {
            set h [Pick [dict get $state pools]]
            set q [Fresh state q]
            Emit state "{items: $q} = $h"
            dict set state arrs $q [dict get $state arrs $h.items]
            dict unset state arrs $h.items
            dict set state pools [lsearch -all -inline -exact -not [dict get $state pools] $h]
        }
        vecpush {
            # A MutableVector of affine arrays: push moves the array in.
            set p [Pick $coBindings]
            set vs [dict keys [dict get $state vecs]]
            if {$vs eq {} || [Rand 3] == 0} {
                set v [Fresh state vq]
                Emit state "$v = arrays()"
                dict set state vecs $v {}
            } else {
                set v [Pick $vs]
            }
            Emit state "$v.push($p)"
            dict set state vecs $v [concat [dict get $state vecs $v] [list [lindex [dict get $state arrs $p] 1]]]
            dict unset state arrs $p
            AMoved state $p vector
        }
        vecpop {
            # pop moves the last array out (an empty vector: the handler's
            # spare(), a new identity).
            set v [Pick [dict keys [dict get $state vecs]]]
            set held [dict get $state vecs $v]
            set q [Fresh state q]
            Handled state $q "$v.pop()" "spare()"
            if {$held eq {}} {
                set ranks [list [ANew state 20]]
            } else {
                set ranks [lindex $held end]
                dict set state vecs $v [lrange $held 0 end-1]
            }
            dict set state arrs $q [list co $ranks]
        }
    }
}

proc AFault {stateVar} {
    upvar 1 $stateVar state
    set kinds {temporary}
    set movedHandles {}
    set movedArrays {}
    dict for {name how} [dict get $state moved] {
        if {[string match c* $name]} {
            lappend movedHandles $name
        } elseif {[string match q* $name] || [string match jq* $name]} {
            lappend movedArrays $name
        }
    }
    if {$movedHandles ne {}} { lappend kinds handleaftermove }
    if {$movedArrays ne {}} { lappend kinds arrayaftermove }
    set arrays [AArrays $state]
    set bindings [AArrays $state "" 1]
    if {$arrays ne {}} { lappend kinds at wrongtype }
    if {$bindings ne {}} { lappend kinds erase capture }
    if {[dict get $state handles] ne {}} { lappend kinds duplicate }
    if {[dict get $state pools] ne {}} { lappend kinds project }
    switch -- [Pick $kinds] {
        temporary {
            Handled state late "mutable_array::swap(spare(), 0, make(1))" "make(2)"
            return MUTABLE-PLACE-RECEIVER
        }
        handleaftermove {
            Emit state "late = coroutine::done?([Pick $movedHandles])"
            return USE-AFTER-MOVE
        }
        arrayaftermove {
            Emit state "late = [Pick $movedArrays].capacity()"
            return USE-AFTER-MOVE
        }
        at {
            set p [Pick $arrays]
            set fallback [expr {[lindex [dict get $state arrs $p] 0] eq "co" ? "make(1)" : "Job {id: 0, step: make(1)}"}]
            Handled state late "mutable_array::at($p, 0)" $fallback
            return AFFINE-ELEMENT-COPY-OUT
        }
        duplicate {
            Emit state "late = mutable_array::create(2, [Pick [dict keys [dict get $state handles]]])"
            return AFFINE-DUPLICATION-UNSUPPORTED
        }
        wrongtype {
            set p [Pick $arrays]
            set fallback [expr {[lindex [dict get $state arrs $p] 0] eq "co" ? "make(1)" : "Job {id: 0, step: make(1)}"}]
            Handled state late "mutable_array::swap($p, 0, 5)" $fallback
            return TYPE
        }
        erase {
            Emit state "late = any_take([Pick $bindings])"
            return AFFINE-ERASURE-UNSUPPORTED
        }
        capture {
            Emit state "fn peek() -> int:" "    [Pick $bindings].capacity()"
            return AFFINE-CAPTURE-UNSUPPORTED
        }
        project {
            Emit state "late = [Pick [dict get $state pools]].items"
            return AFFINE-FIELD-MOVE-REQUIRES-DESTRUCTURE
        }
    }
}

proc AGenerate {} {
    set state [dict create accs {} handles {} arrs {} pools {} vecs {} moved {} groups {} \
        lines {} observed {} expected {} n 0]
    set count [expr {5 + [Rand 14]}]
    for {set i 0} {$i < $count} {incr i} {
        AOperation state
    }
    set code ""
    if {[Rand 3] == 0} {
        set code [AFault state]
    } else {
        # What is still owned dies with drive: a handle alone, an array's (or
        # a Pool's) slots together, first to last; a vector's arrays one
        # after another, each first to last.
        dict for {c rank} [dict get $state handles] {
            ADrop state [list $rank]
        }
        dict for {p info} [dict get $state arrs] {
            ADrop state [lindex $info 1]
        }
        dict for {v held} [dict get $state vecs] {
            foreach ranks $held {
                ADrop state $ranks
            }
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
    set text "${::prelude}fn drive(zero: int) -> List\[List\[int\]\]:\n$body\n    $result\n\ndrive(0)\n"
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
