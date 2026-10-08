#!/usr/bin/env tclsh9.0
# fuzz.tcl -- generated ownership programs against an independent oracle
# (AFFINE-VALUES.md).
#
#   tclsh9.0 audit/affine/tools/fuzz.tcl ?-n N? ?-seed S? ?-dump 1?
#                                         ?-backends LIST? ?-native 0|1?
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
#   Box {tag, step}, Two {a, b}   structs owning one or two handles
#
# The operations: construct a coroutine; resume one (the event folds into a
# checksum chain t0, t1, ...); move it to a new binding; pass it through
# `pass`; consume it (typed, or through the generic `invoke`); thread it
# through `keep`; box it; unbox (all fields, or only the tag: the handle is
# dropped); build a List of two (and move the List); build a Two and
# destructure one or both fields; consume it on one branch of an `if` only;
# discard `pass(c)`'s result; try_consume and guarded under a handler
# (failing or not, as K decides); resume it in a loop.
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
# construction released, none swept by a collection.
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
# coroutine where an explicit Fn is declared (COROUTINE-NOT-FUNCTION).

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set options [dict create -n 30 -seed 1 -dump 0 -backends {interp compile cranelift-generic cranelift} -native 1]
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

set prelude {import coroutine
import list

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

fn any_take(x: any) -> int:
    1

fn dup(f):
    [f, f]

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
        lappend ops resume resume move pass consume invoke keep box branch discard try guarded loop early pendingbox
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
    if {[Owners $state boxes] ne {}} { lappend kinds project }
    if {[Owners $state lists] ne {}} { lappend kinds listat iterate }
    if {[Owners $state handles] ne {}} { lappend kinds capture erase equality dup notfn }
    if {$kinds eq {}} {
        return ""
    }
    switch -- [Pick $kinds] {
        aftermove {
            Emit state "late = coroutine::done?([Pick $plain])"
            return USE-AFTER-MOVE
        }
        maybe {
            Emit state "late = coroutine::done?([Pick $branched])"
            return AFFINE-NOT-DEFINITELY-LIVE
        }
        project {
            Emit state "late = [Pick [Owners $state boxes]].step"
            return AFFINE-FIELD-MOVE-REQUIRES-DESTRUCTURE
        }
        listat {
            Emit state "late = list::at([Pick [Owners $state lists]], 0):"
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
            Emit state "    coroutine::done?($c)"
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
    }
}

# A generated program: {TEXT K EXPECT IDS}. EXPECT is {value V} or {error
# CODE}; IDS the oracle's identities.
proc Generate {} {
    set k [Rand 4]
    set state [dict create ids {} handles {} boxes {} lists {} twos {} lines {} t 0 total 0 n 0 tags {}]
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
                set counters [dict get [native::allocationReport $probeless summary] coroutines]
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
    puts "programs [dict get $options -n] disagreements $disagreements"
    return $disagreements
}

exit [expr {[Run] > 0 ? 1 : 0}]
