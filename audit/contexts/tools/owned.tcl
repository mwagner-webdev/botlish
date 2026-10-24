# owned.tcl -- the context fuzzer's context-owned affine state mode
# (CONTEXT-OWNED-AFFINE-STATE-MILESTONE-1.md), sourced by fuzz.tcl -owned 1.
#
# Each program installs one context, Owner, whose members are every kind of
# state a context may own:
#
#   root   std::ffi::c::Ptr[Int]               a direct affine member
#   pair   Pair {a: Ptr[Int], b: Ptr[Int]}     a nested affine aggregate
#   jobs   MutableVector[Job]                  affine elements: a coroutine
#                                              (w, an accumulator) and a tag
#   cells  MutableVector[Res]                  affine elements: a pointer
#   slots  MutableArray[Ptr[Int]]              an affine array (two slots)
#   log    MutableVector[int]                  an unrestricted member
#
# installed with a literal or through a binding, and then a top level of
# 4..14 calls of the prelude's operations, each a public wrapper that turns
# the declared errors into numbers: open a job (push a new coroutine),
# resume one where it is stored (the element place's coroutine resumed in
# place), read a tag, observe done?, take one out and resume it, pop one,
# swap one for a new job (a failed swap releases the replacement), take one
# and fail (the taken job released on the error exit) or observe and fail
# (nothing moves), push and pop pointer cells, read a cell's or a slot's
# address through its element place, swap a slot, read the root, clone it
# explicitly, sum the pair, push to the log, copy the log out and push to
# the copy (value semantics: the installed log does not change), and count
# through a context trait (Counter, which Owner implements) or through a
# private-style helper. Indexes are random, so some are out of range.
#
# The oracle shares no code with the compiler: it is the generator's own
# model of the installed state -- the jobs with their identities (creation
# order) and accumulators, the cells' and slots' addresses, the log -- moved
# by each operation's rule. From it come the program's value and the
# release obligations: every coroutine moved out of the context (taken,
# popped, swapped out, a failed swap's replacement) is released exactly
# once; every coroutine still in the context when the program ends is never
# released (the installation owns it for the program's lifetime: affinity is
# at most once). Checked on the interpreter by the release calls
# (core::coroutines::releaseCalls) and the Tcl coroutines left alive, and
# natively by the runtime's counters (released, sweptSuspended 0).
#
# A third of the programs carry one fault, a function (never called) that
# copies state out of the context, with the diagnostic the oracle predicts:
# a binding, an argument, a result, a destructuring or a copy of the whole
# context, a consuming loop, an element pushed into its own vector, an
# element place bound, an erasing native, a parameter declared `any`, an
# observation whose later
# argument runs code (AFFINE-CONTEXT-COPY-OUT); a closure capture
# (AFFINE-CAPTURE-UNSUPPORTED); an element copied out with at
# (AFFINE-ELEMENT-COPY-OUT); an element place of a collection no context
# owns (MUTABLE-PLACE-RECEIVER; spelled as a method, with both collections'
# element places visible, NO-APPLICABLE-METHOD: the receiver is a problem of
# each candidate's own call, METHOD-SUGAR.md); an equality
# (AFFINE-EQUALITY-UNSUPPORTED).

core::cabi::installTestFixture

set ownedPrelude {import std::coroutine
import std::ffi::c
import std::mutable_array
import std::mutable_vector
import ffi_fixture

error Late:
    at: int

struct Msg:
    v: int

struct Ev:
    v: int

fn w(acc: int, resume Msg) -> Ev:
    m = yield Ev {v: acc}
    w(acc + m.v)

struct Job:
    step: Coroutine{args: [Msg], return: Ev}
    tag: int

struct Res:
    p: std::ffi::c::Ptr[std::ffi::c::Int]
    tag: int

struct Pair:
    a: std::ffi::c::Ptr[std::ffi::c::Int]
    b: std::ffi::c::Ptr[std::ffi::c::Int]

opaque context struct Owner:
    root: std::ffi::c::Ptr[std::ffi::c::Int]
    pair: Pair
    jobs: MutableVector[Job]
    cells: MutableVector[Res]
    slots: MutableArray[std::ffi::c::Ptr[std::ffi::c::Int]]
    log: MutableVector[int]

context trait Counter:
    fn count() -> int

fn address(a: int) -> std::ffi::c::Ptr[std::ffi::c::Int]:
    ffi_fixture::address[std::ffi::c::Int](a)

fn slot_address(i: int) -> std::ffi::c::Ptr[std::ffi::c::Int]:
    address(4096 + 16 * i)

fn count(context c: Owner) -> int:
    c.jobs.length() + c.cells.length()

fn via_trait(context t: Counter) -> int:
    t.count()

fn open_job(seed: int, context c: Owner) -> int:
    coroutine {step} = w(seed)
    c.jobs.push(Job {step: step, tag: seed})
    c.jobs.length()

fn resume_at(i: int, x: int, context c: Owner) -> int errors IndexNotFound:
    e = c.jobs.element(i).step(Msg {v: x})
    e.v

fn resume_job(i: int, x: int) -> int:
    v = resume_at(i, x):
        on IndexNotFound:
            -1
    v

fn tag_at(i: int, context c: Owner) -> int errors IndexNotFound:
    c.jobs.element(i).tag

fn tag(i: int) -> int:
    v = tag_at(i):
        on IndexNotFound:
            -1
    v

fn done_at?(i: int, context c: Owner) -> bool errors IndexNotFound:
    std::coroutine::done?(c.jobs.element(i).step)

fn done(i: int) -> int:
    d = done_at?(i):
        on IndexNotFound:
            return -1
    if d:
        return 1
    0

fn take_at(i: int, x: int, context c: Owner) -> int errors IndexNotFound:
    job = c.jobs.take(i)
    {step, tag} = job
    e = step(Msg {v: x})
    e.v * 1000 + tag

fn take_job(i: int, x: int) -> int:
    v = take_at(i, x):
        on IndexNotFound:
            -1
    v

fn pop_at(context c: Owner) -> int errors IndexNotFound:
    job = c.jobs.pop()
    {step, tag} = job
    tag

fn pop_job() -> int:
    v = pop_at():
        on IndexNotFound:
            -1
    v

fn swap_at(i: int, seed: int, context c: Owner) -> int errors IndexNotFound:
    coroutine {step} = w(seed)
    old = c.jobs.swap(i, Job {step: step, tag: seed})
    {step: s, tag: t} = old
    e = s(Msg {v: 1})
    e.v * 1000 + t

fn swap_job(i: int, seed: int) -> int:
    v = swap_at(i, seed):
        on IndexNotFound:
            -1
    v

fn take_then_fail(i: int, k: int, context c: Owner) -> int errors IndexNotFound, Late:
    job = c.jobs.take(i)
    if k > 0:
        fail Late {at: k}
    {step, tag} = job
    tag

fn take_fail(i: int, k: int) -> int:
    v = take_then_fail(i, k):
        on IndexNotFound:
            -1
        on Late {at}:
            at * 100
    v

fn observe_then_fail(i: int, k: int, context c: Owner) -> int errors IndexNotFound, Late:
    t = c.jobs.element(i).tag
    if k > 0:
        fail Late {at: k}
    t

fn observe_fail(i: int, k: int) -> int:
    v = observe_then_fail(i, k):
        on IndexNotFound:
            -1
        on Late {at}:
            at * 100
    v

fn push_cell(a: int, context c: Owner) -> int:
    c.cells.push(Res {p: address(a), tag: a})
    c.cells.length()

fn cell_at(i: int, context c: Owner) -> int errors IndexNotFound:
    ffi_fixture::address_of(c.cells.element(i).p)

fn cell(i: int) -> int:
    v = cell_at(i):
        on IndexNotFound:
            -1
    v

fn pop_cell_at(context c: Owner) -> int errors IndexNotFound:
    r = c.cells.pop()
    {p, tag} = r
    ffi_fixture::address_of(p) + tag

fn pop_cell() -> int:
    v = pop_cell_at():
        on IndexNotFound:
            -1
    v

fn slot_at(i: int, context c: Owner) -> int errors IndexNotFound:
    ffi_fixture::address_of(c.slots.element(i))

fn slot(i: int) -> int:
    v = slot_at(i):
        on IndexNotFound:
            -1
    v

fn swap_slot_at(i: int, a: int, context c: Owner) -> int errors IndexNotFound:
    old = c.slots.swap(i, address(a))
    ffi_fixture::address_of(old)

fn swap_slot(i: int, a: int) -> int:
    v = swap_slot_at(i, a):
        on IndexNotFound:
            -1
    v

fn root(context c: Owner) -> int:
    ffi_fixture::address_of(c.root)

fn root_clone(context c: Owner) -> int:
    q = c.root.clone()
    ffi_fixture::address_of(q) + 1

fn pair_sum(context c: Owner) -> int:
    ffi_fixture::address_of(c.pair.a) + ffi_fixture::address_of(c.pair.b)

fn log_push(x: int, context c: Owner) -> int:
    c.log.push(x)
    c.log.length()

fn log_copy(context c: Owner) -> int:
    l = c.log
    l.push(0)
    l.length() * 10 + c.log.length()

fn counted() -> int:
    count()

}

# The faults: NAME -> {CODE TEXT}, TEXT a function never called.
set ownedFaults {
    bind {AFFINE-CONTEXT-COPY-OUT "fn bad(context c: Owner) -> int:\n    q = c.root\n    1\n"}
    argument {AFFINE-CONTEXT-COPY-OUT "fn keep(j: Job) -> int:\n    1\n\nfn bad(context c: Owner) -> int errors IndexNotFound:\n    keep(c.jobs.element(0))\n"}
    result {AFFINE-CONTEXT-COPY-OUT "fn bad(context c: Owner) -> std::ffi::c::Ptr\[std::ffi::c::Int\]:\n    c.pair.a\n"}
    destructure {AFFINE-CONTEXT-COPY-OUT "fn bad(context c: Owner) -> int:\n    {root} = c\n    1\n"}
    copy {AFFINE-CONTEXT-COPY-OUT "fn bad(context c: Owner) -> int:\n    o = c\n    1\n"}
    loop {AFFINE-CONTEXT-COPY-OUT "fn bad(context c: Owner) -> int:\n    loop j in c.jobs:\n        j.tag\n    1\n"}
    push-own {AFFINE-CONTEXT-COPY-OUT "fn bad(context c: Owner) -> int errors IndexNotFound:\n    c.cells.push(c.cells.element(0))\n    1\n"}
    element-bound {AFFINE-CONTEXT-COPY-OUT "fn bad(context c: Owner) -> int errors IndexNotFound:\n    r = c.cells.element(0)\n    1\n"}
    erase {AFFINE-CONTEXT-COPY-OUT "fn bad(context c: Owner) -> int:\n    v = std::ffi::c::erase(c.root)\n    1\n"}
    later-argument {AFFINE-CONTEXT-COPY-OUT "extern c fn probe(p: std::ffi::c::Ptr\[std::ffi::c::Int\], n: std::ffi::c::Int) -> std::ffi::c::Int\n\nfn shrink(context c: Owner) -> std::ffi::c::Int:\n    r = c.cells.pop():\n        on IndexNotFound:\n            return 0\n    1\n\nfn bad(context c: Owner) -> int errors IndexNotFound:\n    probe(c.cells.element(0).p, shrink())\n"}
    capture {AFFINE-CAPTURE-UNSUPPORTED "fn bad(context c: Owner) -> int:\n    fn inner() -> bool:\n        c.root.null?()\n    1\n"}
    at {AFFINE-ELEMENT-COPY-OUT "fn bad(context c: Owner) -> int errors IndexNotFound:\n    j = std::mutable_vector::at(c.jobs, 0)\n    1\n"}
    any-parameter {AFFINE-CONTEXT-COPY-OUT "fn hold(x: any) -> int:\n    1\n\nfn bad(context c: Owner) -> int:\n    hold(c.root)\n"}
    local-element {MUTABLE-PLACE-RECEIVER "fn bad() -> bool errors IndexNotFound:\n    v = std::mutable_vector::from_list(\[Res {p: address(1), tag: 1}\])\n    std::mutable_vector::element(v, 0).p.null?()\n"}
    local-element-method {NO-APPLICABLE-METHOD "fn bad() -> bool errors IndexNotFound:\n    v = std::mutable_vector::from_list(\[Res {p: address(1), tag: 1}\])\n    v.element(0).p.null?()\n"}
    equality {AFFINE-EQUALITY-UNSUPPORTED "fn bad(context c: Owner) -> bool:\n    c.root == c.pair.a\n"}
}

# One program: {TEXT EXPECT MODEL}. EXPECT is {error CODE} or {value TEXT};
# MODEL {created N released IDS remaining IDS} (coroutine identities by
# creation order).
proc generateOwned {seed} {
    set ::rng [expr {$seed * 7919 + 17}]
    set rootA [expr {16 * (1 + [rnd 60])}]
    set pairA [expr {16 * (100 + [rnd 60])}]
    set pairB [expr {16 * (200 + [rnd 60])}]
    set log [lmap _ [lrepeat [rnd 3] x] {rnd 50}]
    # The model.
    set jobs {}
    set cells {}
    set slots [list [expr {4096 + 0}] [expr {4096 + 16}]]
    set created 0
    set released {}
    set lines {}
    set literal "Owner {root: address($rootA), pair: Pair {a: address($pairA), b: address($pairB)}, jobs: std::mutable_vector::from_list(\[\]), cells: std::mutable_vector::from_list(\[\]), slots: std::mutable_array::generate(2, slot_address), log: std::mutable_vector::from_list(\[[join $log {, }]\])}"
    if {[chance 50]} {
        lappend lines "with context $literal"
    } else {
        lappend lines "installed = $literal" "with context installed"
    }
    set results {}
    set steps [expr {4 + [rnd 11]}]
    for {set s 0} {$s < $steps} {incr s} {
        set op [pick {open open open resume resume tag done take pop swap take_fail observe_fail
            push_cell push_cell cell pop_cell slot swap_slot root root_clone pair_sum log_push log_copy
            via_trait counted}]
        set n [llength $jobs]
        set i [rnd [expr {$n + 2}]]
        switch -- $op {
            open {
                set seedv [rnd 90]
                lappend jobs [list $created $seedv $seedv]
                incr created
                set call "open_job($seedv)"
                set value [llength $jobs]
            }
            resume {
                set x [rnd 9]
                set call "resume_job($i, $x)"
                if {$i < $n} {
                    lassign [lindex $jobs $i] id acc tagv
                    set acc [expr {$acc + $x}]
                    lset jobs $i [list $id $acc $tagv]
                    set value $acc
                } else {
                    set value -1
                }
            }
            tag {
                set call "tag($i)"
                set value [expr {$i < $n ? [lindex $jobs $i 2] : -1}]
            }
            done {
                set call "done($i)"
                set value [expr {$i < $n ? 0 : -1}]
            }
            take {
                set x [rnd 9]
                set call "take_job($i, $x)"
                if {$i < $n} {
                    lassign [lindex $jobs $i] id acc tagv
                    set jobs [lreplace $jobs $i $i]
                    lappend released $id
                    set value [expr {($acc + $x) * 1000 + $tagv}]
                } else {
                    set value -1
                }
            }
            pop {
                set call "pop_job()"
                if {$n > 0} {
                    lassign [lindex $jobs end] id acc tagv
                    set jobs [lrange $jobs 0 end-1]
                    lappend released $id
                    set value $tagv
                } else {
                    set value -1
                }
            }
            swap {
                set seedv [rnd 90]
                set call "swap_job($i, $seedv)"
                set new $created
                incr created
                if {$i < $n} {
                    lassign [lindex $jobs $i] id acc tagv
                    lset jobs $i [list $new $seedv $seedv]
                    lappend released $id
                    set value [expr {($acc + 1) * 1000 + $tagv}]
                } else {
                    # The failed swap releases its replacement.
                    lappend released $new
                    set value -1
                }
            }
            take_fail {
                set k [rnd 3]
                set call "take_fail($i, $k)"
                if {$i < $n} {
                    lassign [lindex $jobs $i] id acc tagv
                    set jobs [lreplace $jobs $i $i]
                    lappend released $id
                    set value [expr {$k > 0 ? $k * 100 : $tagv}]
                } else {
                    set value -1
                }
            }
            observe_fail {
                set k [rnd 3]
                set call "observe_fail($i, $k)"
                if {$i < $n} {
                    set value [expr {$k > 0 ? $k * 100 : [lindex $jobs $i 2]}]
                } else {
                    set value -1
                }
            }
            push_cell {
                set a [expr {16 * (300 + [rnd 60])}]
                lappend cells $a
                set call "push_cell($a)"
                set value [llength $cells]
            }
            cell {
                set j [rnd [expr {[llength $cells] + 2}]]
                set call "cell($j)"
                set value [expr {$j < [llength $cells] ? [lindex $cells $j] : -1}]
            }
            pop_cell {
                set call "pop_cell()"
                if {[llength $cells] > 0} {
                    set a [lindex $cells end]
                    set cells [lrange $cells 0 end-1]
                    set value [expr {2 * $a}]
                } else {
                    set value -1
                }
            }
            slot {
                set j [rnd 3]
                set call "slot($j)"
                set value [expr {$j < 2 ? [lindex $slots $j] : -1}]
            }
            swap_slot {
                set j [rnd 3]
                set a [expr {16 * (400 + [rnd 60])}]
                set call "swap_slot($j, $a)"
                if {$j < 2} {
                    set value [lindex $slots $j]
                    lset slots $j $a
                } else {
                    set value -1
                }
            }
            root {
                set call "root()"
                set value $rootA
            }
            root_clone {
                set call "root_clone()"
                set value [expr {$rootA + 1}]
            }
            pair_sum {
                set call "pair_sum()"
                set value [expr {$pairA + $pairB}]
            }
            log_push {
                set x [rnd 50]
                lappend log $x
                set call "log_push($x)"
                set value [llength $log]
            }
            log_copy {
                set call "log_copy()"
                set value [expr {([llength $log] + 1) * 10 + [llength $log]}]
            }
            via_trait {
                set call "via_trait()"
                set value [expr {[llength $jobs] + [llength $cells]}]
            }
            counted {
                set call "counted()"
                set value [expr {[llength $jobs] + [llength $cells]}]
            }
        }
        lappend lines "r$s = $call"
        lappend results r$s $value
    }
    set names [lmap {r v} $results {set r}]
    set prelude $::ownedPrelude
    set expect [list value "\[[join [lmap {r v} $results {set v}] {, }], [llength $jobs]\]"]
    if {[chance 33]} {
        set fault [pick [dict keys $::ownedFaults]]
        lassign [dict get $::ownedFaults $fault] code text
        append prelude [subst -nocommands -novariables $text] "\n"
        set expect [list error $code]
    }
    lappend lines "\[[join $names {, }], test_owned_live()\]"
    set text "${prelude}[join $lines \n]\n"
    return [list $text $expect [dict create created $created released $released \
        remaining [lmap j $jobs {lindex $j 0}]]]
}

# The Tcl coroutines alive (a probe of the Tcl runtime).
proc OwnedLive {} {
    return [core::value::int [llength [info commands {::core::coroutines::co[0-9]*}]]]
}
if {"test_owned_live" ni [core::native::names]} {
    core::registerNative test_owned_live -arity 0 -impl OwnedLive
}

# The release check of accepted HIR against MODEL on the interpreter: every
# coroutine moved out of the context released exactly once, none of those
# still in it: "" or a disagreement.
proc CheckOwnedReleases {hir model} {
    set core::coroutines::releaseCalls {}
    try {
        outcomeUnderHir interp $hir
        set calls $core::coroutines::releaseCalls
    } finally {
        set core::coroutines::releaseCalls none
    }
    set created [dict get $model created]
    set expected [lsort -integer [dict get $model released]]
    # Runtime coroutine IDs grow in creation order: rank them. Only the
    # released ones are seen, so rank against every ID the run made: the
    # IDs a run makes are consecutive from its first.
    if {$calls eq ""} {
        if {$expected ne ""} {
            return "released nothing; oracle expects identities $expected"
        }
        return ""
    }
    set first [expr {[lindex [lsort -integer $calls] 0] - [lindex $expected 0]}]
    set got [lsort -integer [lmap c $calls {expr {$c - $first}}]]
    if {$got ne $expected} {
        return "released identities $got (calls $calls); oracle expects $expected"
    }
    return ""
}

proc RunOwned {n seed0 backends dump native} {
    set accepted 0
    set rejected 0
    set codes [dict create]
    set disagreements 0
    set checked 0
    for {set p 0} {$p < $n} {incr p} {
        set number [expr {$seed0 + $p}]
        lassign [generateOwned $number] text expect model
        if {$dump} {
            puts "### program $number (expect $expect)\n$text"
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
            # With the live probe the Tcl backends report the coroutines
            # still alive -- the ones the context still owns.
            set tcl [lrange [outcomeUnderHir interp $hir] 0 1]
            if {$tcl ne $expect} {
                set problem "interp gives $tcl, oracle $expect"
            }
            set probeless [surface::compile [string map [list test_owned_live() [llength [dict get $model remaining]]] $text] -warnings off]
            foreach b $backends {
                if {$problem ne ""} break
                set o [lrange [outcomeUnderHir $b $probeless] 0 1]
                if {$o ne $expect} {
                    set problem "$b gives $o, oracle $expect"
                }
            }
            if {$problem eq ""} {
                set problem [CheckOwnedReleases $hir $model]
                incr checked [dict get $model created]
            }
            if {$problem eq "" && $native && $::tcl_platform(os) eq "Linux"} {
                # (No coroutine made, no counters reported.)
                set counters [dict getdef [withoutCoroutineFusion {native::allocationReport $probeless summary}] coroutines \
                    {stacksMapped 0 stacksReused 0 released 0 sweptSuspended 0}]
                # (A coroutine's stack is mapped, or reused from one
                # released before: one of the two per coroutine made.)
                if {[dict get $counters released] != [llength [dict get $model released]]
                        || [dict get $counters sweptSuspended] != 0
                        || [dict get $counters stacksMapped] + [dict get $counters stacksReused] != [dict get $model created]} {
                    set problem "native coroutine counters $counters; oracle created [dict get $model created] released [llength [dict get $model released]]"
                }
            }
            if {$problem eq ""} {
                incr accepted
            }
        }
        if {$problem ne ""} {
            incr disagreements
            puts "DISAGREEMENT program $number:\n$problem\n--- program ---\n$text"
        }
    }
    puts "accepted $accepted rejected $rejected ([join [lmap {c k} [lsort -stride 2 [dict get $codes]] {string cat "$c $k"}] {, }])"
    puts "coroutine identities whose releases were checked: $checked"
    puts "programs $n disagreements $disagreements"
    return $disagreements
}
