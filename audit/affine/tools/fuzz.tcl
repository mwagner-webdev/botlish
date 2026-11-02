#!/usr/bin/env tclsh9.0
# fuzz.tcl -- generated ownership programs against an independent oracle
# (AFFINE-VALUES.md).
#
#   tclsh9.0 audit/affine/tools/fuzz.tcl ?-n N? ?-seed S? ?-dump 1?
#                                         ?-backends LIST? ?-native 0|1?
#                                         ?-applications N?
#
# Each program is a driver function `drive(k)` -- a straight line of 4..14
# operations over coroutine handles, structs and Lists that own them -- run
# with one argument K, over a fixed prelude:
#
#   w(acc, resume Msg)   a coroutine that yields Ev {v: acc}, and on every
#                        resume with Msg {v: X} yields acc + X (forever)
#   pass(s)              a typed parameter returned: a move in and out
#   consume(s, x)        a typed parameter resumed once, then dead
#   invoke(c, m)         an untyped HOF that resumes its argument
#                        (specialized for the coroutine)
#   keep(c, m)           an untyped HOF that resumes its argument and
#                        returns it with the event (in an anonymous struct)
#   try_consume(s, k)    consume(s, might_fail(k)): when k > 0 the second
#                        argument fails after s moved into the call's
#                        temporary
#   guarded(s, k)        resumes s, then fails when k > 0 (the callee's
#                        exit releases its parameter)
#   early(k, c)          boxes its parameter and returns early when k > 1,
#                        the box still owning it (the exit releases it)
#   pending_box(c, k)    builds Box {step: c, tag: might_fail(k)}: the field
#                        after the handle fails when k > 0
#   carry(s, k)          fails Carry {step: s, tag: k} when k > 0 (the
#                        handle moves into the error's payload,
#                        ERROR-PAYLOADS.md), else returns s
#   carry_value(s, k)    the same failure, else consume(s, 3)
#   Box {tag, step}, Two {a, b}   structs owning one or two handles
#   GBox[T] {tag, value}, GNest[T] {label, inner: GBox[T]}
#                        parameterized structs owning a handle through a
#                        slot (AFFINE-PARAMETERIZED-APPLICATIONS-CORRECTNESS-
#                        MILESTONE-1.md): GBox[Coroutine{...}] is affine by
#                        its applied field, GNest by the GBox it holds
#   gmake(c, tag)        a function building a GBox of its parameter: the
#                        application its undeclared result is
#
# The operations: construct a coroutine; resume one (the event folds into a
# checksum chain t0, t1, ...); move it to a new binding; pass it through
# `pass`; consume it (typed, or through the generic `invoke`); thread it
# through `keep`; box it; unbox (all fields, or only the tag: the handle is
# dropped); build a List of two (and move the List); build a Two and
# destructure one or both fields; consume it on one branch of an `if` only;
# discard `pass(c)`'s result; try_consume and guarded under a handler
# (failing or not, as K decides); resume it in a loop; and move it into an
# error payload (carry, carry_value) and receive it back from the handler by
# a destructuring or a whole binding, or have the handler ignore it or bind
# only the unrestricted field (the payload's handle is released); box it in
# a GBox (directly or through gmake), nest the GBox in a GNest, move either,
# and take them apart again (all fields, or only the tag or label: the
# handle is dropped).
#
# The oracle shares no code with the compiler. It is the generator's own
# record of every affine runtime identity: its accumulator, and the one owner
# location it has -- a binding, a struct field, a List element, a callee's
# parameter or call temporary, or `dropped` -- updated by the operations'
# transitions (a move: the old owner dead, the new one live; a drop: the
# identity released; a resume: owner unchanged, accumulator advanced). From
# it the oracle derives the driver's value (the checksum, which every resume
# contributes to) and the release obligations: every identity is released,
# exactly once (twice is allowed only for one consumed on one branch of an
# `if`, where a maybe-moved binding and its new owner both release -- a
# release is idempotent), and none is left alive when `drive` returns.
#
# Every accepted program is compared on every backend of BACKENDS (the
# values must equal the oracle's), and checked for its releases: on the
# interpreter, the IDs of every release call (core::coroutines::
# releaseCalls) against the oracle's obligations, and no Tcl coroutine alive
# after `drive`; natively (-native 1), the runtime's counters: every
# construction released, none swept by a collection. The counters are the
# general coroutine runtime's, read with coroutine fusion off (a fused
# coroutine has no runtime object to count: COROUTINE-FUSION-MILESTONE-1.md);
# cranelift-unfused among the backends compares that runtime's values too.
#
# A third of the programs carry one ownership fault, each with the diagnostic
# the oracle predicts: a use after a move into a binding, a call, a struct or
# a List (USE-AFTER-MOVE); a use after a move on one branch
# (AFFINE-NOT-DEFINITELY-LIVE); a projection of an affine field
# (AFFINE-FIELD-MOVE-REQUIRES-DESTRUCTURE); an element read or an iteration
# of a List of handles (AFFINE-LIST-OPERATION-UNSUPPORTED); a closure capture
# (AFFINE-CAPTURE-UNSUPPORTED); an erasure to `any` (AFFINE-ERASURE-
# UNSUPPORTED); an equality (AFFINE-EQUALITY-UNSUPPORTED); a generic function
# that duplicates its argument (USE-AFTER-MOVE, reported at the call); a
# coroutine where an explicit Fn is declared (COROUTINE-NOT-FUNCTION); and
# the same faults on a GBox or a GNest -- a use after a move, a projection of
# its affine field, an erasure, an equality, a generic duplication -- which
# the compiler accepted while an application's affinity ignored its
# arguments.
#
# With -applications N (default 30), N more programs test the
# classification itself (Applications, below): random parameterized struct
# declarations and applications, each judged by an independent oracle that
# substitutes the arguments into the fields and classifies the result, its
# verdict compared with the compiler's admission of a duplicated value, a
# recursive affine construction's rejection and, for an accepted value, its
# releases.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set options [dict create -n 30 -seed 1 -dump 0 -backends {interp compile cranelift-generic cranelift cranelift-unfused} -native 1 -applications 30]
foreach {option value} $argv {
    if {![dict exists $options $option]} {
        error "fuzz.tcl: unknown option $option"
    }
    dict set options $option $value
}
set argv {}
source [file join $root tests helpers.tcl]

proc fuzzLive {} {
    return [core::value::int [llength [info commands {::core::coroutines::co[0-9]*}]]]
}
if {"test_aff_live" ni [core::native::names]} {
    core::registerNative test_aff_live -arity 0 -impl fuzzLive
}

set prelude {import std::coroutine
import std::list

error Boom

struct Msg:
    v: int

struct Ev:
    v: int

struct Box:
    tag: int
    step: Coroutine{args: [Msg], return: Ev}

struct Two:
    a: Coroutine{args: [Msg], return: Ev}
    b: Coroutine{args: [Msg], return: Ev}

fn w(acc: int, resume Msg) -> Ev:
    m = yield Ev {v: acc}
    w(acc + m.v)

fn pass(s: Coroutine{args: [Msg], return: Ev}) -> Coroutine{args: [Msg], return: Ev}:
    s

fn consume(s: Coroutine{args: [Msg], return: Ev}, x: int) -> int:
    e = s(Msg {v: x})
    e.v

fn invoke(c, m):
    c(m)

fn keep(c, m):
    e = c(m)
    {callable: c, event: e}

fn might_fail(k: int) -> int errors Boom:
    if k > 0:
        fail Boom
    k

fn try_consume(s: Coroutine{args: [Msg], return: Ev}, k: int) -> int errors Boom:
    consume(s, might_fail(k))

fn guarded(s: Coroutine{args: [Msg], return: Ev}, k: int) -> int errors Boom:
    e = s(Msg {v: 1})
    if k > 0:
        fail Boom
    e.v

fn early(k: int, c: Coroutine{args: [Msg], return: Ev}) -> int:
    b = Box {tag: 1, step: c}
    if k > 1:
        return 0
    {step} = b
    consume(step, 1)

fn pending_box(c: Coroutine{args: [Msg], return: Ev}, k: int) -> int errors Boom:
    b = Box {step: c, tag: might_fail(k)}
    {step} = b
    consume(step, 2)

error Carry:
    step: Coroutine{args: [Msg], return: Ev}
    tag: int

fn carry(s: Coroutine{args: [Msg], return: Ev}, k: int) -> Coroutine{args: [Msg], return: Ev} errors Carry:
    if k > 0:
        fail Carry {step: s, tag: k}
    s

fn carry_value(s: Coroutine{args: [Msg], return: Ev}, k: int) -> int errors Carry:
    if k > 0:
        fail Carry {tag: k, step: s}
    consume(s, 3)

fn any_take(x: any) -> int:
    1

fn dup(f):
    [f, f]

struct GBox[T]:
    tag: int
    value: T

struct GNest[T]:
    label: int
    inner: GBox[T]

fn gmake(c: Coroutine{args: [Msg], return: Ev}, tag: int):
    GBox {tag: tag, value: c}

fn apply_fn(f: Fn{args: [Msg], return: Ev, errors: []}) -> int:
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

# ---------------------------------------------------------------------------
# The generator and its oracle
#
# State (a dict in the caller):
#   ids        ID -> {acc A owner O releases R}: O is a binding name, a
#              struct or List binding name (the identity is inside it), or
#              "dropped"; R the release calls allowed: {1} or {1 2}
#   handles    live coroutine binding names, boxes, lists, twos: the live
#              owners of each kind (name -> the identities it owns)
#   lines      the driver's statements
#   t          the current checksum binding index; total its oracle value
#   n          a counter for fresh names

proc Fresh {stateVar prefix} {
    upvar 1 $stateVar state
    dict incr state n
    return "$prefix[dict get $state n]"
}

proc Emit {stateVar line} {
    upvar 1 $stateVar state
    dict lappend state lines $line
}

# Folds VALUEEXPR (an Int expression, oracle value VALUE) into the checksum.
proc Fold {stateVar valueExpr value} {
    upvar 1 $stateVar state
    set prev "t[dict get $state t]"
    dict incr state t
    Emit state "t[dict get $state t] = $prev + $valueExpr"
    dict set state total [expr {[dict get $state total] + $value}]
}

proc Owners {state kind} {
    return [dict keys [dict get $state $kind]]
}

proc Take {stateVar kind name} {
    upvar 1 $stateVar state
    set ids [dict get $state $kind $name]
    dict unset state $kind $name
    return $ids
}

proc Own {stateVar kind name ids} {
    upvar 1 $stateVar state
    dict set state $kind $name $ids
    foreach id $ids {
        dict set state ids $id owner $name
    }
}

proc Drop {stateVar ids {twice 0}} {
    upvar 1 $stateVar state
    foreach id $ids {
        dict set state ids $id owner dropped
        if {$twice} {
            dict set state ids $id releases {1 2}
        }
    }
}

proc Advance {stateVar id x} {
    upvar 1 $stateVar state
    set acc [expr {[dict get $state ids $id acc] + $x}]
    dict set state ids $id acc $acc
    return $acc
}

# One random operation on STATE (driver argument K): the statements it
# emits and the oracle's transitions.
proc Operation {stateVar k} {
    upvar 1 $stateVar state
    set cs [Owners $state handles]
    set ops {new}
    if {[llength $cs] >= 1} {
        lappend ops resume resume move pass consume invoke keep box branch discard try guarded loop early pendingbox \
            carry carrywhole carryignore carrytag
    }
    if {[llength $cs] >= 2} {
        lappend ops list two
    }
    if {[Owners $state boxes] ne {}} {
        lappend ops unbox unbox partial
    }
    if {[Owners $state lists] ne {}} {
        lappend ops listmove
    }
    if {[Owners $state twos] ne {}} {
        lappend ops untwo
    }
    if {[llength $cs] >= 1} {
        lappend ops gbox gmake
    }
    if {[Owners $state gboxes] ne {}} {
        lappend ops ungbox gpartial gmove gnest
    }
    if {[Owners $state gnests] ne {}} {
        lappend ops ungnest glabel
    }
    set op [Pick $ops]
    switch -- $op {
        new {
            set base [expr {1 + [Rand 9]}]
            set c [Fresh state c]
            set id [dict size [dict get $state ids]]
            dict set state ids $id [dict create acc $base owner $c releases {1}]
            Emit state "coroutine {step: $c} = w($base)"
            dict set state handles $c [list $id]
        }
        resume {
            set c [Pick $cs]
            set id [lindex [dict get $state handles $c] 0]
            set x [Rand 10]
            set e [Fresh state e]
            Emit state "$e = ${c}(Msg {v: $x})"
            Fold state "$e.v" [Advance state $id $x]
        }
        move {
            set c [Pick $cs]
            set ids [Take state handles $c]
            set d [Fresh state c]
            Emit state "$d = $c"
            Own state handles $d $ids
            dict lappend state moved $c [list bind $d]
        }
        pass {
            set c [Pick $cs]
            set ids [Take state handles $c]
            set d [Fresh state c]
            Emit state "$d = pass($c)"
            Own state handles $d $ids
            dict lappend state moved $c [list call pass]
        }
        consume {
            set c [Pick $cs]
            set ids [Take state handles $c]
            set x [Rand 10]
            Fold state "consume($c, $x)" [Advance state [lindex $ids 0] $x]
            Drop state $ids
            dict lappend state moved $c [list call consume]
        }
        invoke {
            set c [Pick $cs]
            set ids [Take state handles $c]
            set x [Rand 10]
            set e [Fresh state e]
            Emit state "$e = invoke($c, Msg {v: $x})"
            Fold state "$e.v" [Advance state [lindex $ids 0] $x]
            Drop state $ids
            dict lappend state moved $c [list call invoke]
        }
        keep {
            set c [Pick $cs]
            set ids [Take state handles $c]
            set x [Rand 10]
            set d [Fresh state c]
            set e [Fresh state e]
            Emit state "{callable: $d, event: $e} = keep($c, Msg {v: $x})"
            Fold state "$e.v" [Advance state [lindex $ids 0] $x]
            Own state handles $d $ids
            dict lappend state moved $c [list call keep]
        }
        box {
            set c [Pick $cs]
            set ids [Take state handles $c]
            set b [Fresh state b]
            set tag [Rand 100]
            Emit state "$b = Box {tag: $tag, step: $c}"
            Own state boxes $b $ids
            dict set state tags $b $tag
            dict lappend state moved $c [list field $b]
        }
        unbox {
            set b [Pick [Owners $state boxes]]
            set ids [Take state boxes $b]
            set d [Fresh state c]
            if {[Rand 2]} {
                set g [Fresh state g]
                Emit state "{tag: $g, step: $d} = $b"
                Fold state $g [dict get $state tags $b]
            } else {
                Emit state "{step: $d} = $b"
            }
            Own state handles $d $ids
            dict lappend state moved $b [list destructure]
        }
        partial {
            set b [Pick [Owners $state boxes]]
            set ids [Take state boxes $b]
            set g [Fresh state g]
            Emit state "{tag: $g} = $b"
            Fold state $g [dict get $state tags $b]
            Drop state $ids
            dict lappend state moved $b [list destructure]
        }
        list {
            set c1 [Pick $cs]
            set rest [lsearch -all -inline -not -exact $cs $c1]
            set c2 [Pick $rest]
            set ids [concat [Take state handles $c1] [Take state handles $c2]]
            set l [Fresh state l]
            Emit state "$l = \[$c1, $c2\]"
            Own state lists $l $ids
            dict lappend state moved $c1 [list element $l]
            dict lappend state moved $c2 [list element $l]
        }
        listmove {
            set l [Pick [Owners $state lists]]
            set ids [Take state lists $l]
            set m [Fresh state l]
            Emit state "$m = $l"
            Own state lists $m $ids
            dict lappend state moved $l [list bind $m]
        }
        two {
            set c1 [Pick $cs]
            set rest [lsearch -all -inline -not -exact $cs $c1]
            set c2 [Pick $rest]
            set ids [concat [Take state handles $c1] [Take state handles $c2]]
            set p [Fresh state p]
            Emit state "$p = Two {a: $c1, b: $c2}"
            Own state twos $p $ids
            dict lappend state moved $c1 [list field $p]
            dict lappend state moved $c2 [list field $p]
        }
        untwo {
            set p [Pick [Owners $state twos]]
            lassign [Take state twos $p] ida idb
            switch -- [Rand 3] {
                0 {
                    set d [Fresh state c]
                    Emit state "{a: $d} = $p"
                    Own state handles $d [list $ida]
                    Drop state [list $idb]
                }
                1 {
                    set d [Fresh state c]
                    Emit state "{b: $d} = $p"
                    Own state handles $d [list $idb]
                    Drop state [list $ida]
                }
                2 {
                    set d1 [Fresh state c]
                    set d2 [Fresh state c]
                    Emit state "{a: $d1, b: $d2} = $p"
                    Own state handles $d1 [list $ida]
                    Own state handles $d2 [list $idb]
                }
            }
            dict lappend state moved $p [list destructure]
        }
        branch {
            # Consumed on one path only: the binding is maybe-moved after the
            # if (never used again), released there on the other path.
            set c [Pick $cs]
            set ids [Take state handles $c]
            set limit [Rand 6]
            set x [Rand 10]
            set prev "t[dict get $state t]"
            dict incr state t
            Emit state "t[dict get $state t] = if k > $limit:"
            Emit state "    $prev + consume($c, $x)"
            Emit state "else:"
            Emit state "    $prev"
            if {$k > $limit} {
                dict set state total [expr {[dict get $state total] + [Advance state [lindex $ids 0] $x]}]
            }
            Drop state $ids 1
            dict lappend state moved $c [list branch]
        }
        discard {
            set c [Pick $cs]
            set ids [Take state handles $c]
            Emit state "pass($c)"
            Drop state $ids
            dict lappend state moved $c [list call pass]
        }
        try {
            set c [Pick $cs]
            set ids [Take state handles $c]
            # (The driver's argument, not a literal: a literal failing
            # argument would be a statically known failure, KNOWN-ERROR.)
            set useK [Rand 2]
            set f [expr {$useK ? $k : 0}]
            set r [Fresh state r]
            Emit state "$r = try_consume($c, [expr {$useK ? "k" : "0"}]):"
            Emit state "    on Boom:"
            Emit state "        -1"
            set value [expr {$f > 0 ? -1 : [Advance state [lindex $ids 0] 0]}]
            Fold state $r $value
            Drop state $ids
            dict lappend state moved $c [list call try_consume]
        }
        guarded {
            set c [Pick $cs]
            set ids [Take state handles $c]
            # (The driver's argument, not a literal: a literal failing
            # argument would be a statically known failure, KNOWN-ERROR.)
            set useK [Rand 2]
            set f [expr {$useK ? $k : 0}]
            set r [Fresh state r]
            Emit state "$r = guarded($c, [expr {$useK ? "k" : "0"}]):"
            Emit state "    on Boom:"
            Emit state "        -1"
            set acc [Advance state [lindex $ids 0] 1]
            Fold state $r [expr {$f > 0 ? -1 : $acc}]
            Drop state $ids
            dict lappend state moved $c [list call guarded]
        }
        early {
            # A helper that boxes its parameter and returns early (when
            # k > 1) with the box still owning it: the exit releases it.
            set c [Pick $cs]
            set ids [Take state handles $c]
            set value [expr {$k > 1 ? 0 : [Advance state [lindex $ids 0] 1]}]
            Fold state "early(k, $c)" $value
            Drop state $ids
            dict lappend state moved $c [list call early]
        }
        pendingbox {
            # A struct field that fails (when k > 0) after the handle moved
            # into the construction's temporary: the temporary releases it.
            set c [Pick $cs]
            set ids [Take state handles $c]
            set r [Fresh state r]
            Emit state "$r = pending_box($c, k):"
            Emit state "    on Boom:"
            Emit state "        -1"
            Fold state $r [expr {$k > 0 ? -1 : [Advance state [lindex $ids 0] 2]}]
            Drop state $ids
            dict lappend state moved $c [list call pending_box]
        }
        carry - carrywhole {
            # The handle moves into an error payload (when the call fails)
            # and comes back out of the handler: a destructuring of the
            # payload, or of its whole binding.
            set c [Pick $cs]
            set ids [Take state handles $c]
            set useK [Rand 2]
            set d [Fresh state c]
            Emit state "$d = carry($c, [expr {$useK ? "k" : "0"}]):"
            if {$op eq "carry"} {
                Emit state "    on Carry {step}:"
                Emit state "        step"
            } else {
                Emit state "    on Carry details:"
                Emit state "        {step: back} = details"
                Emit state "        back"
            }
            Own state handles $d $ids
            dict lappend state moved $c [list call carry]
        }
        carryignore - carrytag {
            # The handler ignores the payload, or binds only its tag: the
            # handle the payload owns is released.
            set c [Pick $cs]
            set ids [Take state handles $c]
            set useK [Rand 2]
            set f [expr {$useK ? $k : 0}]
            set r [Fresh state r]
            Emit state "$r = carry_value($c, [expr {$useK ? "k" : "0"}]):"
            if {$op eq "carryignore"} {
                Emit state "    on Carry:"
                Emit state "        -1"
                set failed -1
            } else {
                Emit state "    on Carry {tag}:"
                Emit state "        tag * 10"
                set failed [expr {$f * 10}]
            }
            Fold state $r [expr {$f > 0 ? $failed : [Advance state [lindex $ids 0] 3]}]
            Drop state $ids
            dict lappend state moved $c [list call carry_value]
        }
        gbox - gmake {
            # A handle held through GBox's slot: GBox[Coroutine{...}].
            set c [Pick $cs]
            set ids [Take state handles $c]
            set q [Fresh state q]
            set tag [Rand 100]
            if {$op eq "gbox"} {
                Emit state "$q = GBox {tag: $tag, value: $c}"
                dict lappend state moved $c [list field $q]
            } else {
                Emit state "$q = gmake($c, $tag)"
                dict lappend state moved $c [list call gmake]
            }
            Own state gboxes $q $ids
            dict set state tags $q $tag
        }
        ungbox {
            set q [Pick [Owners $state gboxes]]
            set ids [Take state gboxes $q]
            set d [Fresh state c]
            if {[Rand 2]} {
                set g [Fresh state g]
                Emit state "{tag: $g, value: $d} = $q"
                Fold state $g [dict get $state tags $q]
            } else {
                Emit state "{value: $d} = $q"
            }
            Own state handles $d $ids
            dict lappend state moved $q [list destructure]
        }
        gpartial {
            set q [Pick [Owners $state gboxes]]
            set ids [Take state gboxes $q]
            set g [Fresh state g]
            Emit state "{tag: $g} = $q"
            Fold state $g [dict get $state tags $q]
            Drop state $ids
            dict lappend state moved $q [list destructure]
        }
        gmove {
            set q [Pick [Owners $state gboxes]]
            set ids [Take state gboxes $q]
            set r [Fresh state q]
            Emit state "$r = $q"
            Own state gboxes $r $ids
            dict set state tags $r [dict get $state tags $q]
            dict lappend state moved $q [list bind $r]
        }
        gnest {
            # GNest[Coroutine{...}]: affine through the GBox its slot makes.
            set q [Pick [Owners $state gboxes]]
            set ids [Take state gboxes $q]
            set n [Fresh state n]
            set label [Rand 100]
            Emit state "$n = GNest {label: $label, inner: $q}"
            Own state gnests $n $ids
            dict set state tags $n [list $label [dict get $state tags $q]]
            dict lappend state moved $q [list field $n]
        }
        ungnest {
            set n [Pick [Owners $state gnests]]
            set ids [Take state gnests $n]
            set q [Fresh state q]
            lassign [dict get $state tags $n] label tag
            if {[Rand 2]} {
                set g [Fresh state g]
                Emit state "{label: $g, inner: $q} = $n"
                Fold state $g $label
            } else {
                Emit state "{inner: $q} = $n"
            }
            Own state gboxes $q $ids
            dict set state tags $q $tag
            dict lappend state moved $n [list destructure]
        }
        glabel {
            set n [Pick [Owners $state gnests]]
            set ids [Take state gnests $n]
            set g [Fresh state g]
            Emit state "{label: $g} = $n"
            Fold state $g [lindex [dict get $state tags $n] 0]
            Drop state $ids
            dict lappend state moved $n [list destructure]
        }
        loop {
            set c [Pick $cs]
            set id [lindex [dict get $state handles $c] 0]
            set count [expr {1 + [Rand 3]}]
            Emit state "loop i from 0 to $count:"
            Emit state "    ${c}(Msg {v: 1})"
            Advance state $id $count
        }
    }
    return $op
}

# The fault statement (and its predicted diagnostic code) on STATE, or "".
proc Fault {stateVar} {
    upvar 1 $stateVar state
    set kinds {}
    set moved [expr {[dict exists $state moved] ? [dict keys [dict get $state moved]] : {}}]
    set plain {}
    set branched {}
    foreach name $moved {
        if {![string match c* $name]} continue
        if {[lindex [dict get $state moved $name] 0 0] eq "branch"} {
            lappend branched $name
        } else {
            lappend plain $name
        }
    }
    if {$plain ne {}} { lappend kinds aftermove }
    if {$branched ne {}} { lappend kinds maybe }
    set gmoved {}
    foreach name $moved {
        if {[string match {[qn]*} $name]} {
            lappend gmoved $name
        }
    }
    if {$gmoved ne {}} { lappend kinds gaftermove }
    set gowners [concat [Owners $state gboxes] [Owners $state gnests]]
    if {$gowners ne {}} { lappend kinds gproject gerase gequality gdup }
    if {[Owners $state boxes] ne {}} { lappend kinds project }
    if {[Owners $state lists] ne {}} { lappend kinds listat iterate }
    if {[Owners $state handles] ne {}} { lappend kinds capture erase equality dup notfn }
    if {$kinds eq {}} {
        return ""
    }
    switch -- [Pick $kinds] {
        aftermove {
            Emit state "late = std::coroutine::done?([Pick $plain])"
            return USE-AFTER-MOVE
        }
        maybe {
            Emit state "late = std::coroutine::done?([Pick $branched])"
            return AFFINE-NOT-DEFINITELY-LIVE
        }
        project {
            Emit state "late = [Pick [Owners $state boxes]].step"
            return AFFINE-FIELD-MOVE-REQUIRES-DESTRUCTURE
        }
        listat {
            Emit state "late = std::list::at([Pick [Owners $state lists]], 0):"
            Emit state "    on IndexNotFound:"
            Emit state "        0"
            return AFFINE-LIST-OPERATION-UNSUPPORTED
        }
        iterate {
            Emit state "late = loop x in [Pick [Owners $state lists]]:"
            Emit state "    1"
            return AFFINE-LIST-OPERATION-UNSUPPORTED
        }
        capture {
            set c [Pick [Owners $state handles]]
            Emit state "fn peek() -> bool:"
            Emit state "    std::coroutine::done?($c)"
            return AFFINE-CAPTURE-UNSUPPORTED
        }
        erase {
            Emit state "late = any_take([Pick [Owners $state handles]])"
            return AFFINE-ERASURE-UNSUPPORTED
        }
        equality {
            set c [Pick [Owners $state handles]]
            Emit state "late = $c == $c"
            return AFFINE-EQUALITY-UNSUPPORTED
        }
        dup {
            Emit state "late = dup([Pick [Owners $state handles]])"
            return USE-AFTER-MOVE
        }
        notfn {
            Emit state "late = apply_fn([Pick [Owners $state handles]])"
            return COROUTINE-NOT-FUNCTION
        }
        gaftermove {
            set g [Pick $gmoved]
            set field [expr {[string match q* $g] ? "tag" : "label"}]
            Emit state "late = $g.$field"
            return USE-AFTER-MOVE
        }
        gproject {
            set g [Pick $gowners]
            set field [expr {[string match q* $g] ? "value" : "inner"}]
            Emit state "late = $g.$field"
            return AFFINE-FIELD-MOVE-REQUIRES-DESTRUCTURE
        }
        gerase {
            Emit state "late = any_take([Pick $gowners])"
            return AFFINE-ERASURE-UNSUPPORTED
        }
        gequality {
            set g [Pick $gowners]
            Emit state "late = $g == $g"
            return AFFINE-EQUALITY-UNSUPPORTED
        }
        gdup {
            Emit state "late = dup([Pick $gowners])"
            return USE-AFTER-MOVE
        }
    }
}

# A generated program: {TEXT K EXPECT IDS}. EXPECT is {value V} or {error
# CODE}; IDS the oracle's identities.
proc Generate {} {
    set k [Rand 4]
    set state [dict create ids {} handles {} boxes {} lists {} twos {} gboxes {} gnests {} lines {} t 0 total 0 n 0 tags {}]
    dict set state lines [list "t0 = 0"]
    set count [expr {4 + [Rand 11]}]
    for {set i 0} {$i < $count} {incr i} {
        Operation state $k
    }
    set code ""
    if {[Rand 3] == 0} {
        set code [Fault state]
    }
    set body [join [lmap line [dict get $state lines] {string cat "    " $line}] \n]
    set text "${::prelude}fn drive(k: int):\n$body\n    t[dict get $state t]\n\nr = drive($k)\n\[r, test_aff_live()\]\n"
    set expect [expr {$code ne "" ? [list error $code] : [list value "\[[dict get $state total], 0\]"]}]
    return [list $text $k $expect [dict get $state ids]]
}

# ---------------------------------------------------------------------------
# Checking

# The release obligation check of program TEXT (accepted) against the
# oracle's identities IDS on the interpreter: "" or a disagreement.
proc CheckReleases {hir ids} {
    set core::coroutines::releaseCalls {}
    try {
        outcomeUnderHir interp $hir
        set calls $core::coroutines::releaseCalls
    } finally {
        set core::coroutines::releaseCalls none
    }
    # Runtime IDs in construction order are the oracle's identities.
    set runtime [lsort -integer -unique $calls]
    if {[llength $runtime] != [dict size $ids]} {
        return "released [llength $runtime] of [dict size $ids] identities ($calls)"
    }
    set rank 0
    foreach rid $runtime {
        set n [llength [lsearch -all -exact $calls $rid]]
        if {$n ni [dict get $ids $rank releases]} {
            return "identity $rank released $n times, allowed [dict get $ids $rank releases]"
        }
        incr rank
    }
    return ""
}

proc Run {} {
    global options
    set backends [dict get $options -backends]
    set accepted 0
    set rejected 0
    set codes [dict create]
    set disagreements 0
    set releasesChecked 0
    for {set p 0} {$p < [dict get $options -n]} {incr p} {
        set number [expr {[dict get $options -seed] + $p}]
        set ::seedState [expr {$number * 7919 + 17}]
        lassign [Generate] text k expect ids
        if {[dict get $options -dump]} {
            puts "--- program $number\n$text--- expect $expect"
        }
        set problem ""
        if {[catch {surface::compile $text -warnings off} hir errOptions]} {
            set got [list error [lindex [dict get $errOptions -errorcode] end]]
            if {$got ne $expect} {
                set problem "rejected [lindex $got 1]: $hir; oracle expects $expect"
            } else {
                incr rejected
                dict incr codes [lindex $got 1]
            }
        } elseif {[lindex $expect 0] eq "error"} {
            set problem "accepted; oracle expects [lindex $expect 1]"
        } else {
            set tclValue [lrange [outcomeUnderHir interp $hir] 0 1]
            set probeless [surface::compile [string map {test_aff_live() 0} $text] -warnings off]
            set outcomes [lmap b $backends {lrange [outcomeUnderHir $b $probeless] 0 1}]
            if {$tclValue ne $expect} {
                set problem "interp (with the live probe) gives $tclValue, oracle $expect"
            } else {
                foreach b $backends o $outcomes {
                    if {$o ne $expect} {
                        set problem "$b gives $o, oracle $expect"
                        break
                    }
                }
            }
            if {$problem eq ""} {
                set problem [CheckReleases $hir $ids]
                incr releasesChecked [dict size $ids]
            }
            if {$problem eq "" && [dict get $options -native] && $::tcl_platform(os) eq "Linux"} {
                set counters [dict get [withoutCoroutineFusion {native::allocationReport $probeless summary}] coroutines]
                if {[dict get $counters released] != [dict size $ids] || [dict get $counters sweptSuspended] != 0} {
                    set problem "native release counters $counters for [dict size $ids] identities"
                }
            }
            if {$problem eq ""} {
                incr accepted
            }
        }
        if {$problem ne ""} {
            incr disagreements
            puts "DISAGREEMENT program $number:\n$problem\n--- program\n$text"
        }
    }
    puts "accepted $accepted rejected $rejected ([join [lmap {c n} [lsort -stride 2 [dict get $codes]] {string cat "$c $n"}] {, }])"
    puts "identities whose releases were checked: $releasesChecked"
    puts "ownership programs [dict get $options -n] disagreements $disagreements"
    return $disagreements
}

# ---------------------------------------------------------------------------
# Applications: the classification of parameterized struct applications
# (AFFINE-PARAMETERIZED-APPLICATIONS-CORRECTNESS-MILESTONE-1.md)
#
# A program declares 2..4 structs S0, S1, ... (each with one or two slots,
# A and B) whose fields are drawn from
#
#   a slot                       A
#   int
#   a List of a slot             List[A]
#   an earlier declaration       Sj[X, ...], each X a slot or int
#   an ordinary struct           Holder (a coroutine handle: affine), Plain
#   a function type over a slot  Fn{args: [A], return: int} (no value of A)
#   itself, in a List            List[Si[A, ...]] or List[Si[int, ...]]
#
# (a slot no field establishes gets a field of its own), then constructs one
# of them in `main`, every slot's argument drawn from int, str, List[int], a
# coroutine handle, Plain, Holder and -- where no function type takes it --
# a construction of an earlier declaration, every value built by its own
# construction expression; and uses it in one of two ways:
#
#   dup    a = VALUE; b = a; c = a      USE-AFTER-MOVE exactly when affine
#   drop   a = VALUE                    runs; every handle released
#
# The oracle shares nothing with the compiler. Its types are {int} {str}
# {listint} {co} {holder} {plain} {list T} {fn T} {app J ARGS} and, in a
# declaration, {slot K}. An application's affinity is its fields', the
# arguments substituted: co and holder are affine, a list is its element's,
# int, str, a function type and Plain are not, an application met again
# inside itself adds nothing (the least fixpoint); a slot of a declaration
# seen generically is unrestricted. An affine application that holds an
# affine application of its own declaration in a List is a recursive affine
# type: AFFINE-CONTAINER-UNSUPPORTED for the program when a declaration is
# one with its slots unrestricted, else when a constructed application is
# one. Every other program compiles exactly when the oracle says the value
# may be duplicated, and an accepted one gives [1, 0] on every backend
# (main's 1 and no Tcl coroutine alive after it) and, natively, releases
# every handle it constructed, the collector sweeping none.

set appPrelude {import std::list

struct Holder:
    c: Coroutine{args: [], return: int, errors: []}

struct Plain:
    n: int

fn gen() -> int:
    yield 1
    2

fn mk() -> Coroutine{args: [], return: int, errors: []}:
    coroutine {step} = gen()
    step

fn f_int(x: int) -> int:
    1

fn f_str(x: str) -> int:
    1

fn f_listint(x: List[int]) -> int:
    1

fn f_co(x: Coroutine{args: [], return: int, errors: []}) -> int:
    1

fn f_holder(x: Holder) -> int:
    1

fn f_plain(x: Plain) -> int:
    1

}

set appBase {{int} {str} {listint} {co} {holder} {plain}}

# The source text of oracle type T (SLOTS the slot names of the declaration
# it is written in).
proc AppText {t {slots {A B}}} {
    switch -- [lindex $t 0] {
        int { return int }
        str { return str }
        listint { return {List[int]} }
        co { return {Coroutine{args: [], return: int, errors: []}} }
        holder { return Holder }
        plain { return Plain }
        slot { return [lindex $slots [lindex $t 1]] }
        list { return "List\[[AppText [lindex $t 1] $slots]\]" }
        fn { return "Fn{args: \[[AppText [lindex $t 1] $slots]\], return: int}" }
        app {
            return "S[lindex $t 1]\[[join [lmap a [lindex $t 2] {AppText $a $slots}] {, }]\]"
        }
    }
    error "AppText: $t"
}

# T with every {slot K} replaced by the K-th of ARGS.
proc AppSubst {t args} {
    switch -- [lindex $t 0] {
        slot { return [lindex $args [lindex $t 1]] }
        list - fn { return [list [lindex $t 0] [AppSubst [lindex $t 1] {*}$args]] }
        app { return [list app [lindex $t 1] [lmap a [lindex $t 2] {AppSubst $a {*}$args}]] }
    }
    return $t
}

# The oracle's affinity of T (DECLS: J -> {slots N fields {{NAME TYPE} ...}}).
proc AppAffine {decls t {seen {}}} {
    switch -- [lindex $t 0] {
        co - holder { return 1 }
        list { return [AppAffine $decls [lindex $t 1] $seen] }
        app {
            if {$t in $seen} {
                return 0
            }
            foreach field [dict get $decls [lindex $t 1] fields] {
                if {[AppAffine $decls [AppSubst [lindex $field 1] {*}[lindex $t 2]] [concat $seen [list $t]]]} {
                    return 1
                }
            }
            return 0
        }
    }
    return 0
}

# 1 if the affine application T of declaration TARGET holds, inside a List,
# an affine application of TARGET (the oracle's recursive affine type).
proc AppRecursive {decls t} {
    set target [lindex $t 1]
    set work [list [list $t 0 0]]
    set visited {}
    while {$work ne {}} {
        set work [lassign $work item]
        lassign $item type crossed depth
        if {![AppAffine $decls $type]} continue
        if {[lindex $type 0] eq "list"} {
            lappend work [list [lindex $type 1] 1 [expr {$depth + 1}]]
            continue
        }
        if {[lindex $type 0] ne "app"} continue
        if {$depth > 0 && [lindex $type 1] eq $target && $crossed} {
            return 1
        }
        if {[list $type $crossed] in $visited} continue
        lappend visited [list $type $crossed]
        foreach field [dict get $decls [lindex $type 1] fields] {
            lappend work [list [AppSubst [lindex $field 1] {*}[lindex $type 2]] $crossed [expr {$depth + 1}]]
        }
    }
    return 0
}

# 1 if slot K of declaration J flows into a function type (directly, or
# through an earlier declaration's tainted slot): its argument must have a
# test function f_KIND.
proc AppTainted {decls j k} {
    foreach field [dict get $decls $j fields] {
        if {[AppTaints $decls $j [lindex $field 1] $k]} {
            return 1
        }
    }
    return 0
}
# (A field of declaration J; its own declaration again, in a List, adds
# nothing: the same slots.)
proc AppTaints {decls j t k} {
    switch -- [lindex $t 0] {
        fn { return [expr {[lindex $t 1] eq [list slot $k]}] }
        list { return [AppTaints $decls $j [lindex $t 1] $k] }
        app {
            if {[lindex $t 1] eq $j} {
                return 0
            }
            set p 0
            foreach a [lindex $t 2] {
                if {$a eq [list slot $k] && [AppTainted $decls [lindex $t 1] $p]} {
                    return 1
                }
                incr p
            }
        }
    }
    return 0
}

# Random declarations: J -> {slots N fields {{NAME TYPE} ...} self 0|1}.
proc AppDeclarations {} {
    set decls [dict create]
    set count [expr {2 + [Rand 3]}]
    for {set j 0} {$j < $count} {incr j} {
        set n [expr {1 + [Rand 2]}]
        dict set decls $j [dict create slots $n fields {}]
        set fields {}
        set established {}
        set forms {slot int listslot holder plain fn self}
        if {$j > 0} {
            lappend forms app app appint
        }
        set nfields [expr {1 + [Rand 3]}]
        for {set f 0} {$f < $nfields} {incr f} {
            set k [Rand $n]
            switch -- [Pick $forms] {
                slot { set t [list slot $k]; lappend established $k }
                int { set t {int} }
                listslot { set t [list list [list slot $k]]; lappend established $k }
                holder { set t {holder} }
                plain { set t {plain} }
                fn { set t [list fn [list slot $k]] }
                self {
                    # (Applied to its own slots; a later pass applies one in
                    # three to int instead.)
                    set t [list list [list app $j [lmap s [Iota $n] {list slot $s}]]]
                }
                app - appint {
                    set i [Rand $j]
                    set args {}
                    for {set s 0} {$s < [dict get $decls $i slots]} {incr s} {
                        if {[Rand 3] == 0} {
                            lappend args {int}
                        } else {
                            set kk [Rand $n]
                            lappend args [list slot $kk]
                            lappend established $kk
                        }
                    }
                    set t [list app $i $args]
                    if {[Rand 3] == 0} {
                        set t [list list $t]
                    }
                }
            }
            lappend fields [list f$f $t]
        }
        for {set s 0} {$s < $n} {incr s} {
            if {$s ni $established} {
                lappend fields [list v$s [list slot $s]]
            }
        }
        dict set decls $j fields $fields
    }
    # (A self field applied to int, one in three.)
    dict for {j d} $decls {
        set fields {}
        foreach field [dict get $d fields] {
            lassign $field name t
            if {[lindex $t 0] eq "list" && [lindex $t 1 0] eq "app" && [lindex $t 1 1] eq $j && [Rand 3] == 0} {
                set t [list list [list app $j [lrepeat [dict get $d slots] {int}]]]
            }
            lappend fields [list $name $t]
        }
        dict set decls $j fields $fields
    }
    return $decls
}

# The construction expression of a value of concrete oracle type T, every
# application it constructs appended to APPSVAR, every handle counted in
# COUNTVAR.
proc AppValue {decls t appsVar countVar} {
    upvar 1 $appsVar apps $countVar count
    switch -- [lindex $t 0] {
        int { return 7 }
        str { return {"ab"} }
        listint { return {[7]} }
        co { incr count; return "mk()" }
        holder { incr count; return "Holder {c: mk()}" }
        plain { return "Plain {n: 7}" }
        list { return "\[[AppValue $decls [lindex $t 1] apps count]\]" }
        fn { return "f_[lindex $t 1 0]" }
        app {
            lappend apps $t
            set j [lindex $t 1]
            set parts {}
            foreach field [dict get $decls $j fields] {
                lassign $field name declared
                if {[lindex $declared 0] eq "list" && [lindex $declared 1 0] eq "app" && [lindex $declared 1 1] eq $j} {
                    # (Its own declaration in a List, as declared -- never
                    # a slot's argument that happens to be one: empty.)
                    lappend parts "$name: \[\]"
                } else {
                    lappend parts "$name: [AppValue $decls [AppSubst $declared {*}[lindex $t 2]] apps count]"
                }
            }
            return "S$j {[join $parts {, }]}"
        }
    }
    error "AppValue: $t"
}

# An argument for slot K of declaration J: a base type, or (when no function
# type takes it, DEPTH allowing) an application of an earlier declaration.
proc AppArgument {decls j k depth} {
    if {![AppTainted $decls $j $k] && $depth < 2 && $j > 0 && [Rand 3] == 0} {
        set i [Rand $j]
        return [list app $i [lmap s [lrepeat [dict get $decls $i slots] x] {AppArgument $decls $i 0 [expr {$depth + 1}]}]]
    }
    return [Pick $::appBase]
}

# One classification program: {TEXT EXPECT COUNT} (EXPECT {value V} or
# {error CODE}).
proc AppGenerate {} {
    set decls [AppDeclarations]
    set text $::appPrelude
    dict for {j d} $decls {
        set slots [lrange {A B} 0 [expr {[dict get $d slots] - 1}]]
        append text "struct S$j\[[join $slots {, }]\]:\n"
        foreach field [dict get $d fields] {
            append text "    [lindex $field 0]: [AppText [lindex $field 1] $slots]\n"
        }
        append text "\n"
    }
    set j [Rand [dict size $decls]]
    set args {}
    for {set k 0} {$k < [dict get $decls $j slots]} {incr k} {
        # (A tainted slot takes a base argument, AppArgument's rule for
        # this declaration's own slots too.)
        lappend args [AppArgument $decls $j $k 0]
    }
    set t [list app $j $args]
    set apps {}
    set count 0
    set value [AppValue $decls $t apps count]
    set use [Pick {dup drop}]
    append text "fn main() -> int:\n    a = $value\n"
    if {$use eq "dup"} {
        append text "    b = a\n    c = a\n"
    }
    append text "    1\n\n\[main(), test_aff_live()\]\n"
    # The oracle.
    set expect [list value {[1, 0]}]
    set declarationRecursive 0
    dict for {i d} $decls {
        set generic [list app $i [lmap k [Iota [dict get $d slots]] {list slot $k}]]
        if {[AppAffine $decls $generic] && [AppRecursive $decls $generic]} {
            set declarationRecursive 1
        }
    }
    if {$declarationRecursive} {
        set expect [list error AFFINE-CONTAINER-UNSUPPORTED]
    } elseif {[lsearch -exact [lmap a $apps {expr {[AppAffine $decls $a] && [AppRecursive $decls $a]}}] 1] >= 0} {
        set expect [list error AFFINE-CONTAINER-UNSUPPORTED]
    } elseif {$use eq "dup" && [AppAffine $decls $t]} {
        set expect [list error USE-AFTER-MOVE]
    }
    return [list $text $expect $count [AppAffine $decls $t]]
}

proc Iota {n} {
    set r {}
    for {set i 0} {$i < $n} {incr i} {
        lappend r $i
    }
    return $r
}

# Runs -applications classification programs: the number of disagreements.
proc RunApplications {} {
    global options
    set backends [dict get $options -backends]
    set disagreements 0
    set tally [dict create]
    for {set p 0} {$p < [dict get $options -applications]} {incr p} {
        set number [expr {[dict get $options -seed] + $p}]
        set ::seedState [expr {$number * 6007 + 29}]
        lassign [AppGenerate] text expect count affine
        if {[dict get $options -dump]} {
            puts "--- application program $number\n$text--- expect $expect"
        }
        set problem ""
        if {[catch {surface::compile $text -warnings off} hir errOptions]} {
            if {[dict exists $errOptions -diagnostics]} {
                set codes [lmap d [dict get $errOptions -diagnostics] {lindex [dict get $d errorcode] end}]
            } else {
                set codes [list [lindex [dict get $errOptions -errorcode] end]]
            }
            if {[lindex $expect 0] ne "error" || [lindex $expect 1] ni $codes
                    || ([lindex $expect 1] eq "USE-AFTER-MOVE" && [lindex $codes 0] ne "USE-AFTER-MOVE")} {
                set problem "rejected ($codes): $hir; oracle expects $expect"
            } else {
                dict incr tally "rejected [lindex $expect 1]"
            }
        } elseif {[lindex $expect 0] eq "error"} {
            set problem "accepted; oracle expects [lindex $expect 1]"
        } else {
            set tclValue [lrange [outcomeUnderHir interp $hir] 0 1]
            set probeless [surface::compile [string map {test_aff_live() 0} $text] -warnings off]
            if {$tclValue ne $expect} {
                set problem "interp (with the live probe) gives $tclValue, oracle $expect"
            } else {
                foreach b $backends {
                    set o [lrange [outcomeUnderHir $b $probeless] 0 1]
                    if {$o ne $expect} {
                        set problem "$b gives $o, oracle $expect"
                        break
                    }
                }
            }
            if {$problem eq "" && $count > 0 && [dict get $options -native] && $::tcl_platform(os) eq "Linux"} {
                set counters [dict get [withoutCoroutineFusion {native::allocationReport $probeless summary}] coroutines]
                if {[dict get $counters released] != $count || [dict get $counters sweptSuspended] != 0} {
                    set problem "native release counters $counters for $count handles"
                }
            }
            if {$problem eq ""} {
                dict incr tally "accepted [expr {$affine ? "affine" : "unrestricted"}]"
            }
        }
        if {$problem ne ""} {
            incr disagreements
            puts "DISAGREEMENT application program $number:\n$problem\n--- program\n$text"
        }
    }
    puts "application programs [dict get $options -applications]: [join [lmap {k n} [lsort -stride 2 $tally] {string cat "$k $n"}] {, }]; disagreements $disagreements"
    return $disagreements
}

set failures [Run]
incr failures [RunApplications]
# (The last line is the total, as audit/affine/tools/mutate.tcl reads it.)
puts "programs [expr {[dict get $options -n] + [dict get $options -applications]}] disagreements $failures"
exit [expr {$failures > 0 ? 1 : 0}]
