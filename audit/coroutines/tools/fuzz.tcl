#!/usr/bin/env tclsh9.0
# fuzz.tcl -- generated coroutine programs against an independent oracle
# (COROUTINES.md).
#
#   tclsh9.0 audit/coroutines/tools/fuzz.tcl ?-n N? ?-seed S? ?-dump 1?
#                                            ?-backends LIST?
#
# Each program has a root w0 and 0..3 helper levels w1..wL (wK calls wK+1),
# each a body of 1..5 statements over an accumulator chain a0 = n, a1, ...:
#
#   yield      `yield Ev {tag: T, v: aI}` -- its value discarded, or (a
#              struct-protocol program) bound and used: passed to
#              `take(m: Msg)` (use-site inference) or projected `m.v` (with a
#              declared `resume Msg`)
#   call       `aJ = aI + wK+1(aI)`, or the handled form `on Boom: 1000`
#   loop       a counted loop of 1..3 yields (a discarded collecting loop)
#   branch     `if aI > T:` yields, with or without an else yield
#   fail       `if aI > T: fail Boom`
#   return     `if aI > T: return ...`
#   nested     the function constructs and drives its own zero-message
#              generator coroutine (isolation: the function does not yield
#              by it)
#   held       the function constructs a generator coroutine that it
#              resumes only at its end: every later return, fail and failing
#              call leaves while it is still suspended
#   scan       a counted loop whose body constructs a generator coroutine,
#              `break`s or `continue`s on given iterations before its
#              resume, and notes the resumed value
#   effect     `note(log, T)`: an observable side effect, folding T into a
#              checksum in a MutableArray every function is passed
#
# In a quarter of the programs ("deep" ones) only the deepest level yields:
# every level above reaches the yields through calls alone.
#
# and a driver -- at the top level or inside a function -- that constructs
# `coroutine {step, first} = w0(ARG)` (field forms and renames vary), then
# resumes it 0..6 times (with Msg messages or none, as the oracle's protocol
# says), checks `coroutine::done?` in between and moves the handle to new
# names; every operation is handled when the root declares errors. After
# the construction and after every resume the driver reads the side-effect
# checksum: how far the body has run (eager construction, no re-run after
# termination).
#
# The oracle shares no code with the compiler. Statically it computes which
# functions may yield (the transitive effect) and the root's resume protocol
# (Msg or zero-message), compared with what the compiler records. Dynamically
# it runs the generated statements itself as one sequential computation fed
# the driver's messages in order -- the explicit machine not-created ->
# suspended(at the Nth yield) -> completed(value) | failed(error), the
# suspended frames being the oracle's own Tcl stack -- giving the coroutine's
# state after every driver operation, hence every observed value: the first
# result, each resume's result, the cached result or error after
# termination, each done? answer and the side-effect checksum after each
# segment. Ownership (live / moved per binding) is the driver's own record:
# an accepted program only ever uses the current owner. Every backend in
# BACKENDS must compute that value.
#
# About a third of the programs carry exactly one fault, each with the
# diagnostic the oracle predicts: a use after a move (USE-AFTER-MOVE), a move
# in a branch (AFFINE-NOT-DEFINITELY-LIVE), a resume of the wrong arity
# (COROUTINE-RESUME-ARITY), a message of the wrong type (TYPE), a handle
# compared for equality (AFFINE-EQUALITY-UNSUPPORTED; a List element became
# an ownership-moving position in AFFINE-VALUES.md), a direct call of the root
# (UNWRAPPED-YIELD), a top-level yield (YIELD-OUTSIDE-FUNCTION), a yield of an
# Int (COROUTINE-RESULT-MISMATCH) and a second protocol reaching the root
# (COROUTINE-RESUME-CONFLICT); a root that cannot yield at all is
# COROUTINE-RHS-NOT-YIELDING.
#
# For every accepted program the oracle also predicts where the final owner
# of the driver's coroutine is released (COROUTINES.md, "Release at the last
# use"): right after the statement of its last reference, and nowhere else
# -- no handle it was moved from is released. A release placed too early, of
# a moved-from handle, or of a handle still in use shows on every backend as
# a resume of a released coroutine. And it predicts what every early exit of
# a generated function releases ("... and on every early exit"): a return,
# fail or call failing with Boom releases the held coroutines constructed
# before it, a scan's break or continue only that iteration's coroutine --
# never the held ones its function still resumes after the loop -- and
# nothing else in the program releases on an exit.
#
# The last line is "programs N disagreements D"; exit status 1 if D > 0.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set args $argv
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
interp recursionlimit {} 100000

set n 50
set seed0 1
set dump 0
set backends {interp compile cranelift-generic cranelift}
while {[lindex $args 0] in {-n -seed -dump -backends}} {
    switch -- [lindex $args 0] {
        -n { set n [lindex $args 1] }
        -seed { set seed0 [lindex $args 1] }
        -dump { set dump [lindex $args 1] }
        -backends { set backends [lindex $args 1] }
    }
    set args [lrange $args 2 end]
}

proc rnd {n} {
    set ::rng [expr {($::rng * 1103515245 + 12345) % 2147483648}]
    return [expr {($::rng / 65536) % $n}]
}
proc pick {list} {
    return [lindex $list [rnd [llength $list]]]
}
proc chance {percent} {
    return [expr {[rnd 100] < $percent}]
}

# ---------------------------------------------------------------------------
# Generation

# The statements of function K (K = 0 the root) of a program with L helper
# levels; CALLEE is the generated dict of wK+1 ("" for the deepest). In a
# DEEP program only the deepest level yields: every other one reaches the
# yields through calls alone.
proc Statements {k struct callee deep} {
    set kinds {yield yield yield loop branch fail fail return nested effect effect}
    if {$deep && $callee ne ""} {
        set kinds {fail fail return nested effect effect}
    }
    if {$callee ne ""} {
        lappend kinds call call call
    }
    set stmts {}
    set count [expr {1 + [rnd 5]}]
    for {set i 0} {$i < $count} {incr i} {
        set kind [pick $kinds]
        switch -- $kind {
            yield {
                set use [expr {$struct ? [pick {none take field}] : "none"}]
                lappend stmts [dict create kind yield tag [expr {10 * $k + [rnd 10]}] use $use]
            }
            call {
                set handled [expr {[dict get $callee errors] && [chance 50]}]
                lappend stmts [dict create kind call handled $handled]
            }
            loop {
                lappend stmts [dict create kind loop count [expr {1 + [rnd 3]}] tag [expr {10 * $k + [rnd 10]}]]
            }
            branch {
                lappend stmts [dict create kind branch limit [rnd 20] tag [expr {10 * $k + [rnd 10]}] \
                    else [chance 50] elseTag [expr {10 * $k + [rnd 10]}]]
            }
            fail {
                lappend stmts [dict create kind fail limit [expr {[rnd 18] - 3}]]
            }
            return {
                lappend stmts [dict create kind return limit [expr {5 + [rnd 40]}]]
            }
            nested {
                lappend stmts [dict create kind nested]
            }
            effect {
                lappend stmts [dict create kind effect tag [expr {1 + [rnd 9]}]]
            }
        }
    }
    # Most functions reach their callee, so that the deeper levels run.
    if {$callee ne "" && [chance 85]
            && ![llength [lmap s $stmts {expr {[dict get $s kind] eq "call" ? 1 : [continue]}}]]} {
        set handled [expr {[dict get $callee errors] && [chance 50]}]
        set stmts [linsert $stmts [rnd [expr {[llength $stmts] + 1}]] [dict create kind call handled $handled]]
    }
    # Coroutines the function's early exits leave suspended (in its first
    # half, so that exits follow), and a loop leaving its own.
    for {set i 0} {$i < 2} {incr i} {
        if {[chance 40]} {
            set stmts [linsert $stmts [rnd [expr {[llength $stmts] / 2 + 1}]] [dict create kind held]]
        }
    }
    if {[chance 30]} {
        set count [expr {1 + [rnd 4]}]
        set stmts [linsert $stmts [rnd [expr {[llength $stmts] + 1}]] [dict create kind scan count $count \
            break [expr {[chance 60] ? [rnd $count] : -1}] continue [expr {[chance 60] ? [rnd $count] : -1}]]]
    }
    return $stmts
}

# The oracle's static facts of function F (a dict with stmts): whether it
# may yield, its local protocol constraint, whether it declares errors.
proc Facts {f callee struct} {
    set yields 0
    set local none
    set errors 0
    foreach s [dict get $f stmts] {
        switch -- [dict get $s kind] {
            yield {
                set yields 1
                if {[dict get $s use] ne "none"} {
                    set local Msg
                }
            }
            loop - branch {
                set yields 1
            }
            call {
                if {[dict get $callee mayYield]} {
                    set yields 1
                }
                if {[dict get $callee errors] && ![dict get $s handled]} {
                    set errors 1
                }
            }
            fail {
                set errors 1
            }
        }
    }
    if {[dict get $f declaresResume]} {
        set local Msg
    }
    dict set f mayYield $yields
    dict set f local $local
    dict set f errors $errors
    return $f
}

proc Indent {lines prefix} {
    return [lmap line $lines {string cat $prefix $line}]
}

# The source lines of function K.
proc FunctionText {k f levels} {
    set root [expr {$k == 0}]
    set result [expr {$root ? "Ev" : "int"}]
    set params "n: int, log: MutableArray\[int\]"
    if {[dict get $f declaresResume]} {
        append params ", resume Msg"
    }
    set lines [list "fn w${k}($params) -> $result[expr {[dict get $f errors] ? " errors Boom" : ""}]:"]
    lappend lines "    a0 = n"
    set a 0
    set m 0
    set held {}
    foreach s [dict get $f stmts] {
        set acc a$a
        switch -- [dict get $s kind] {
            yield {
                set value [expr {[dict exists $s int] ? $acc : "Ev {tag: [dict get $s tag], v: $acc}"}]
                switch -- [dict get $s use] {
                    none { lappend lines "    yield $value" }
                    take {
                        incr m
                        lappend lines "    m$m = yield $value" "    a[incr a] = $acc + take(m$m)"
                    }
                    field {
                        incr m
                        lappend lines "    m$m = yield $value" "    a[incr a] = $acc + m$m.v"
                    }
                }
            }
            call {
                set callee w[expr {$k + 1}]
                if {[dict get $s handled]} {
                    lappend lines "    a[incr a] = ${callee}($acc, log):" "        on Boom:" "            1000"
                } else {
                    lappend lines "    a[incr a] = $acc + ${callee}($acc, log)"
                }
            }
            loop {
                lappend lines "    loop i from 0 to [dict get $s count]:" \
                    "        yield Ev {tag: [dict get $s tag], v: i}"
            }
            branch {
                lappend lines "    if $acc > [dict get $s limit]:" \
                    "        yield Ev {tag: [dict get $s tag], v: $acc}"
                if {[dict get $s else]} {
                    lappend lines "    else:" "        yield Ev {tag: [dict get $s elseTag], v: 0 - $acc}"
                }
            }
            fail {
                lappend lines "    if $acc > [dict get $s limit]:" "        fail Boom"
            }
            return {
                lappend lines "    if $acc > [dict get $s limit]:" \
                    "        return [expr {$root ? "Ev {tag: 900, v: $acc}" : $acc}]"
            }
            nested {
                incr m
                lappend lines "    coroutine {step: g$m, first: f$m} = gen($acc)" \
                    "    h$m = g${m}()" \
                    "    a[incr a] = $acc + f$m.v + h$m.v"
            }
            held {
                incr m
                lappend lines "    coroutine {step: g$m, first: f$m} = gen($acc)"
                lappend held $m
            }
            scan {
                incr m
                lappend lines "    loop i from 0 to [dict get $s count]:" \
                    "        coroutine {step: s$m, first: t$m} = gen(i)"
                if {[dict get $s break] >= 0} {
                    lappend lines "        if i == [dict get $s break]:" "            break"
                }
                if {[dict get $s continue] >= 0} {
                    lappend lines "        if i == [dict get $s continue]:" "            continue"
                }
                lappend lines "        note(log, s${m}().v + t$m.v)"
            }
            other {
                lappend lines "    a[incr a] = $acc + other()"
            }
            effect {
                lappend lines "    note(log, [dict get $s tag])"
            }
        }
    }
    # The held coroutines, resumed at last.
    foreach h $held {
        set acc a$a
        lappend lines "    r$h = g${h}()" "    a[incr a] = $acc + f$h.v + r$h.v"
    }
    lappend lines "    [expr {$root ? "return Ev {tag: 999, v: a$a}" : "a$a"}]"
    return $lines
}

# The oracle's prediction of what each early exit of function F (with
# callee facts CALLEE, "" for the deepest) releases, in source order: {KIND
# HANDLES} for each exit that releases any -- a return or fail statement or
# a call failing with Boom (KIND call) the held coroutines constructed
# before it, a scan's break or continue that scan's own coroutine.
proc Exits {f callee} {
    set exits {}
    set held {}
    set m 0
    foreach s [dict get $f stmts] {
        switch -- [dict get $s kind] {
            yield {
                if {[dict get $s use] ne "none"} {
                    incr m
                }
            }
            nested {
                incr m
            }
            held {
                lappend held g[incr m]
            }
            scan {
                incr m
                foreach kind {break continue} {
                    if {[dict get $s $kind] >= 0} {
                        lappend exits [list $kind s$m]
                    }
                }
            }
            fail - return {
                if {$held ne {}} {
                    lappend exits [list [dict get $s kind] [lsort $held]]
                }
            }
            call {
                if {$held ne {} && [dict get $callee errors] && ![dict get $s handled]} {
                    lappend exits [list call [lsort $held]]
                }
            }
        }
    }
    return $exits
}

# One program: a dict text, expect ({error KIND} | {value V}), mayYield (the
# names of the functions that may yield), protocol (Msg | unit) and the
# number of levels.
proc generate {seed} {
    set ::rng [expr {$seed * 7919 + 13}]
    set struct [chance 60]
    set deep [chance 25]
    set levels [rnd 4]
    # Deepest first: each function's facts need its callee's.
    set funcs [dict create]
    set callee ""
    for {set k $levels} {$k >= 0} {incr k -1} {
        set f [dict create stmts [Statements $k $struct $callee $deep] declaresResume 0]
        if {$struct} {
            set fields [lmap s [dict get $f stmts] {
                expr {[dict get $s kind] eq "yield" && [dict get $s use] eq "field" ? 1 : [continue]}
            }]
            set hasYield [llength [lmap s [dict get $f stmts] {
                expr {[dict get $s kind] eq "yield" ? 1 : [continue]}
            }]]
            if {[llength $fields] || ($hasYield && [chance 15])} {
                dict set f declaresResume 1
            }
        }
        set f [Facts $f $callee $struct]
        dict set funcs $k $f
        set callee $f
    }
    # The protocol of each function: its local constraint joined with its
    # yielding callee's (a call statement makes the edge).
    set protocol none
    for {set k $levels} {$k >= 0} {incr k -1} {
        set f [dict get $funcs $k]
        set p [dict get $f local]
        if {$k < $levels && [dict get [dict get $funcs [expr {$k + 1}]] mayYield]
                && [llength [lmap s [dict get $f stmts] {expr {[dict get $s kind] eq "call" ? 1 : [continue]}}]]} {
            if {$protocol eq "Msg"} {
                set p Msg
            }
        }
        if {![dict get $f mayYield]} {
            set p none
        }
        dict set funcs $k protocol $p
        set protocol $p
    }
    set rootFacts [dict get $funcs 0]
    set resolved [expr {[dict get $rootFacts protocol] eq "Msg" ? "Msg" : "unit"}]
    set rootErrors [dict get $rootFacts errors]
    set mayYield [lmap k [lsort -integer [dict keys $funcs]] {
        expr {[dict get $funcs $k mayYield] ? "w$k" : [continue]}
    }]

    # The driver: construction, then resumes, done? checks and moves.
    set arg [rnd 10]
    set stepName [pick {step step step h0}]
    set firstName [pick {first first f0 ""}]
    set ops [list [list start]]
    set resumes [rnd 7]
    set names [list $stepName]
    for {set r 1} {$r <= $resumes} {incr r} {
        if {[chance 25]} {
            lappend names m$r
            lappend ops [list move m$r]
        }
        lappend ops [list resume [rnd 10]]
        if {[chance 30]} {
            lappend ops [list done]
        }
    }
    if {[chance 20]} {
        lappend ops [list done]
    }
    set inFunction [chance 30]

    # One fault, when the root may yield.
    set fault ""
    if {[dict get $rootFacts mayYield] && [chance 35]} {
        set candidates {storage unwrapped outside mismatch branchmove arity}
        if {[llength $names] > 1} {
            lappend candidates aftermove
        }
        if {$resolved eq "Msg"} {
            lappend candidates type conflict
        }
        set fault [pick $candidates]
    }
    switch -- $fault {
        mismatch {
            # One yield (of any function the root reaches) sends an Int.
            set sites {}
            dict for {k f} $funcs {
                set i 0
                foreach s [dict get $f stmts] {
                    if {[dict get $s kind] eq "yield"} {
                        lappend sites [list $k $i]
                    }
                    incr i
                }
            }
            # Only a function the root reaches through calls.
            set reach 0
            set reachable {}
            for {set k 0} {$k <= $levels} {incr k} {
                lappend reachable $k
                if {![llength [lmap s [dict get $funcs $k stmts] {expr {[dict get $s kind] eq "call" ? 1 : [continue]}}]]} {
                    break
                }
            }
            set sites [lmap site $sites {expr {[lindex $site 0] in $reachable ? $site : [continue]}}]
            if {$sites eq ""} {
                set fault ""
            } else {
                lassign [pick $sites] k i
                set stmts [dict get $funcs $k stmts]
                lset stmts $i [dict merge [lindex $stmts $i] {int 1}]
                dict set funcs $k stmts $stmts
            }
        }
        conflict {
            set stmts [dict get $funcs 0 stmts]
            lappend stmts [dict create kind other]
            dict set funcs 0 stmts $stmts
        }
    }

    # Text.
    set lines [list "import coroutine" "import mutable_array" "" "error Boom" "" \
        "struct Msg:" "    v: int" "" "struct Other:" "    w: int" "" \
        "struct Ev:" "    tag: int" "    v: int" "" \
        "fn take(m: Msg) -> int:" "    m.v" "" \
        "fn seen(log: MutableArray\[int\]) -> int:" \
        "    mutable_array::at(log, 0):" "        on IndexNotFound:" "            -1" "" \
        "fn note(log: MutableArray\[int\], v: int) -> int:" \
        "    old = seen(log)" \
        "    mutable_array::set(log, 0, old * 3 + v):" "        on IndexNotFound:" "            unit" "    v" "" \
        "fn gen(n: int) -> Ev:" "    yield Ev {tag: 50, v: n}" "    return Ev {tag: 51, v: n + 1}" ""]
    if {$fault eq "conflict"} {
        lappend lines "fn other(resume Other) -> int:" "    m = yield Ev {tag: 77, v: 0}" "    m.w" ""
    }
    for {set k $levels} {$k >= 0} {incr k -1} {
        lappend lines {*}[FunctionText $k [dict get $funcs $k] $levels] ""
    }
    set handler [list "    on Boom:" "        Ev {tag: -1, v: -1}"]
    set driver {}
    set observed {}
    set fields [expr {$stepName eq "step" ? "step" : "step: $stepName"}]
    if {$firstName ne ""} {
        append fields [expr {$firstName eq "first" ? ", first" : ", first: $firstName"}]
        lappend observed $firstName
    }
    lappend driver "log = mutable_array::create(1, 0)"
    lappend driver "coroutine {$fields} = w0($arg, log)[expr {$rootErrors ? ":" : ""}]"
    if {$rootErrors} {
        lappend driver {*}$handler
    }
    lappend driver "e0 = seen(log)"
    lappend observed e0
    if {$fault eq "branchmove"} {
        # Moved on one path only: the next use of the handle is not
        # definitely live.
        lappend driver "if coroutine::done?($stepName):" "    gone = $stepName"
        if {[llength $ops] == 1} {
            lappend ops [list done]
        }
    }
    set current $stepName
    # The statement after which the final owner's coroutine is released
    # (COROUTINES.md, "Release at the last use"): the statement of its last
    # reference -- the start, a resume, a done? check, or the move that made
    # it the owner.
    set releaseAfter [expr {$firstName ne "" ? "bind $firstName" : ($rootErrors ? "handle" : "call")}]
    set r 0
    set d 0
    set badArity [expr {$fault eq "arity" ? [rnd [expr {max($resumes, 1)}]] + 1 : -1}]
    if {$fault eq "arity" && $resumes == 0} {
        lappend ops [list resume 1]
    }
    set badType [expr {$fault eq "type" ? [rnd [expr {max($resumes, 1)}]] + 1 : -1}]
    if {$fault eq "type" && $resumes == 0} {
        lappend ops [list resume 1]
    }
    set moved ""
    foreach op [lrange $ops 1 end] {
        switch -- [lindex $op 0] {
            move {
                lappend driver "[lindex $op 1] = $current"
                set moved $current
                set current [lindex $op 1]
                set releaseAfter "bind $current"
            }
            resume {
                incr r
                set message [expr {$resolved eq "Msg" ? "Msg {v: [lindex $op 1]}" : ""}]
                if {$r == $badArity} {
                    set message [expr {$resolved eq "Msg" ? "" : "Msg {v: 1}"}]
                }
                if {$r == $badType} {
                    set message "Other {w: 1}"
                }
                lappend driver "r$r = ${current}($message)[expr {$rootErrors ? ":" : ""}]"
                if {$rootErrors} {
                    lappend driver {*}$handler
                }
                lappend driver "e$r = seen(log)"
                lappend observed r$r e$r
                set releaseAfter "bind r$r"
            }
            done {
                incr d
                lappend driver "d$d = coroutine::done?($current)"
                lappend observed d$d
                set releaseAfter "bind d$d"
            }
        }
    }
    switch -- $fault {
        aftermove {
            lappend driver "late = coroutine::done?($moved)"
        }
        storage {
            # (A List element is an ownership-moving position since
            # AFFINE-VALUES.md; equality stays rejected.)
            lappend driver "kept = $current == $current"
        }
        unwrapped {
            lappend driver "direct = w0(1, log)[expr {$rootErrors ? ":" : ""}]"
            if {$rootErrors} {
                lappend driver {*}$handler
            }
        }
    }
    set final "\[[join $observed {, }]\]"
    if {$inFunction} {
        lappend lines "fn drive() -> list:" {*}[Indent $driver "    "] "    $final" ""
        if {$fault eq "outside"} {
            lappend lines "yield Ev {tag: 0, v: 0}"
        }
        lappend lines "drive()"
    } else {
        lappend lines {*}$driver
        if {$fault eq "outside"} {
            lappend lines "yield Ev {tag: 0, v: 0}"
        }
        lappend lines $final
    }

    # Expectation.
    if {![dict get $rootFacts mayYield]} {
        set expect {error COROUTINE-RHS-NOT-YIELDING}
    } elseif {$fault ne ""} {
        set expect [list error [dict get {
            aftermove USE-AFTER-MOVE branchmove AFFINE-NOT-DEFINITELY-LIVE
            arity COROUTINE-RESUME-ARITY type TYPE storage AFFINE-EQUALITY-UNSUPPORTED
            unwrapped UNWRAPPED-YIELD outside YIELD-OUTSIDE-FUNCTION
            mismatch COROUTINE-RESULT-MISMATCH conflict COROUTINE-RESUME-CONFLICT
        } $fault]]
    } else {
        set expect [list value [Observe $funcs $levels $arg $ops $resolved $firstName]]
    }
    set exits [dict create]
    for {set k 0} {$k <= $levels} {incr k} {
        dict set exits $k [Exits [dict get $funcs $k] \
            [expr {$k < $levels ? [dict get $funcs [expr {$k + 1}]] : ""}]]
    }
    return [dict create text [join $lines \n] expect $expect mayYield $mayYield \
        protocol $resolved levels $levels fault $fault owner $current release $releaseAfter \
        exits $exits]
}

# ---------------------------------------------------------------------------
# The oracle's run time

# Runs function K on N as part of the one coroutine; returns {ok V} or
# {fail}. A yield appends its value to ::outs and takes the next message
# from ::messages; when there is none, the coroutine stays suspended forever:
# the run stops (error SUSPENDED).
proc Exec {funcs k n} {
    set acc $n
    set root [expr {$k == 0}]
    set held {}
    foreach s [dict get $funcs $k stmts] {
        switch -- [dict get $s kind] {
            yield {
                set m [Yield [Ev [dict get $s tag] $acc]]
                if {[dict get $s use] ne "none"} {
                    set acc [expr {$acc + $m}]
                }
            }
            call {
                set result [Exec $funcs [expr {$k + 1}] $acc]
                if {[lindex $result 0] eq "fail"} {
                    if {![dict get $s handled]} {
                        return {fail}
                    }
                    set acc 1000
                } elseif {[dict get $s handled]} {
                    set acc [lindex $result 1]
                } else {
                    set acc [expr {$acc + [lindex $result 1]}]
                }
            }
            loop {
                for {set i 0} {$i < [dict get $s count]} {incr i} {
                    Yield [Ev [dict get $s tag] $i]
                }
            }
            branch {
                if {$acc > [dict get $s limit]} {
                    Yield [Ev [dict get $s tag] $acc]
                } elseif {[dict get $s else]} {
                    Yield [Ev [dict get $s elseTag] [expr {0 - $acc}]]
                }
            }
            fail {
                if {$acc > [dict get $s limit]} {
                    return {fail}
                }
            }
            return {
                if {$acc > [dict get $s limit]} {
                    return [list ok [expr {$root ? [Ev 900 $acc] : $acc}]]
                }
            }
            nested {
                # gen(acc) yields Ev(50, acc), then returns Ev(51, acc + 1).
                set acc [expr {$acc + $acc + $acc + 1}]
            }
            held {
                # Resumed at the end, with the accumulator of its start.
                lappend held $acc
            }
            scan {
                for {set i 0} {$i < [dict get $s count]} {incr i} {
                    if {$i == [dict get $s break]} break
                    if {$i == [dict get $s continue]} continue
                    # gen(i) yields Ev(50, i), then returns Ev(51, i + 1).
                    set ::log [expr {$::log * 3 + $i + 1 + $i}]
                }
            }
            effect {
                set ::log [expr {$::log * 3 + [dict get $s tag]}]
            }
        }
    }
    foreach c $held {
        set acc [expr {$acc + $c + $c + 1}]
    }
    return [list ok [expr {$root ? [Ev 999 $acc] : $acc}]]
}

proc Ev {tag v} {
    return "Ev {tag: $tag, v: $v}"
}

proc Yield {value} {
    lappend ::outs $value
    lappend ::logs $::log
    if {[llength $::outs] > [llength $::messages]} {
        return -code error -errorcode SUSPENDED suspended
    }
    return [lindex $::messages [expr {[llength $::outs] - 1}]]
}

# The value the driver OPS observes: the list of first (if bound) and each
# resume's result, each followed by the side-effect checksum, and each done?
# answer, in order.
proc Observe {funcs levels arg ops protocol firstName} {
    set ::outs {}
    set ::logs {}
    set ::log 0
    set ::messages [lmap op $ops {
        expr {[lindex $op 0] eq "resume" ? ($protocol eq "Msg" ? [lindex $op 1] : 0) : [continue]}
    }]
    if {[catch {Exec $funcs 0 $arg} final options]} {
        if {[dict get $options -errorcode] ne "SUSPENDED"} {
            return -options $options $final
        }
        set final suspended
    }
    # The log when the body stopped for good (it never runs again).
    set finalLog $::log
    # Segment I's result: the I-th yield, else the terminal completion.
    set failed [list [Ev -1 -1]]
    set values {}
    set segment 0
    foreach op $ops {
        switch -- [lindex $op 0] {
            start - resume {
                if {$segment < [llength $::outs]} {
                    set value [lindex $::outs $segment]
                } elseif {[lindex $final 0] eq "ok"} {
                    set value [lindex $final 1]
                } else {
                    set value [Ev -1 -1]
                }
                if {[lindex $op 0] eq "resume" || $firstName ne ""} {
                    lappend values $value
                }
                # The log after the segment: as the body left it at that
                # yield, or at its end.
                lappend values [expr {$segment < [llength $::logs] ? [lindex $::logs $segment] : $finalLog}]
                incr segment
            }
            done {
                lappend values [expr {$segment > [llength $::outs] ? "true" : "false"}]
            }
        }
    }
    return "\[[join $values {, }]\]"
}

# ---------------------------------------------------------------------------
# Driver

proc blockOf {hir name} {
    dict for {b binding} [dict get $hir bindings] {
        if {[dict get $binding kind] ne "local"} continue
        set shown [expr {[dict exists $binding spelling] ? [dict get $binding spelling] : [dict get $binding name]}]
        if {$shown ne $name} continue
        set by [dict get $binding declaredBy]
        if {$by ne "" && [hir::kind $hir $by] eq "bind" && [hir::kind $hir [hir::get $hir $by value]] eq "block"} {
            return [hir::get $hir $by value]
        }
    }
    return ""
}

# The compiler's exit releases in function block B, in source order: {KIND
# HANDLES} for each exit of the exit table (return, fail, break, continue)
# and each call of the error-exit table (KIND call; the handles a Boom
# releases).
proc ExitsOf {hir b} {
    set result {}
    set nodes {}
    set work [list $b]
    while {$work ne {}} {
        set e [lindex $work end]
        set work [lrange $work 0 end-1]
        lappend nodes $e
        lappend work {*}[hir::children $hir $e]
    }
    set name {{hir b} {regsub {#[0-9]+$} [dict get $hir bindings $b name] ""}}
    foreach e [lsort -dictionary $nodes] {
        if {[dict exists $hir affine exits $e]} {
            lappend result [list [hir::kind $hir $e] [lsort [lmap h [dict get $hir affine exits $e] {apply $name $hir $h}]]]
        }
        if {[dict exists $hir affine errorExits $e]} {
            set byName [dict get $hir affine errorExits $e]
            lappend result [list call [lsort [lmap h [expr {[dict exists $byName Boom] ? [dict get $byName Boom] : {}}] {apply $name $hir $h}]]]
        }
    }
    return $result
}

set disagreements 0
set accepted 0
set kinds [dict create]
set exitKinds [dict create]
set faults [dict create]
for {set i 0} {$i < $n} {incr i} {
    set seed [expr {$seed0 + $i}]
    set p [generate $seed]
    set text [dict get $p text]
    set expect [dict get $p expect]
    if {$dump} {
        puts "### program $seed (expect $expect)\n$text"
    }
    set problems {}
    if {[lindex $expect 0] eq "error"} {
        dict incr kinds [lindex $expect 1]
        if {![catch {surface::compile $text -warnings off} message options]} {
            lappend problems "accepted; oracle expects [lindex $expect 1]"
        } elseif {[lindex [dict get $options -errorcode] end] ne [lindex $expect 1]} {
            lappend problems "rejected with [dict get $options -errorcode] ($message); oracle expects [lindex $expect 1]"
        }
    } elseif {[catch {surface::compile $text -warnings off} hir]} {
        lappend problems "rejected ($hir); oracle expects the value [lindex $expect 1]"
    } else {
        incr accepted
        # The transitive yield effect and the root's protocol.
        set got {}
        for {set k 0} {$k <= [dict get $p levels]} {incr k} {
            set b [blockOf $hir w$k]
            if {$b ne "" && [dict exists $hir coroutines mayYield $b]} {
                lappend got w$k
            }
        }
        if {$got ne [dict get $p mayYield]} {
            lappend problems "may yield: oracle {[dict get $p mayYield]}, compiler {$got}"
        }
        set b [blockOf $hir w0]
        set protocol [hir::coroutines::Resolved [dict get $hir coroutines blocks $b protocol]]
        set protocol [expr {$protocol eq "unit" ? "unit" : [hir::types::show $protocol]}]
        if {$protocol ne [dict get $p protocol]} {
            lappend problems "protocol: oracle [dict get $p protocol], compiler $protocol"
        }
        # The final owner is released once, right after its last reference;
        # every earlier owner was moved, so is not released at all.
        set released {}
        dict for {e bs} [dict get $hir affine releases] {
            foreach b $bs {
                if {[regsub {#[0-9]+$} [dict get $hir bindings $b name] ""] ne [dict get $p owner]} continue
                set node [dict get $hir exprs $e]
                set label [dict get $node kind]
                if {$label eq "bind"} {
                    append label " [regsub {#[0-9]+$} [dict get $hir bindings [dict get $node binding] name] {}]"
                }
                lappend released $label
            }
        }
        if {$released ne [list [dict get $p release]]} {
            lappend problems "release of [dict get $p owner]: oracle after {[dict get $p release]}, compiler after {[join $released {, }]}"
        }
        # What every early exit releases, function by function in source
        # order; no other exit releases anything.
        set counted 0
        for {set k 0} {$k <= [dict get $p levels]} {incr k} {
            set got [ExitsOf $hir [blockOf $hir w$k]]
            incr counted [llength $got]
            foreach exit [dict get $p exits $k] {
                dict incr exitKinds [lindex $exit 0]
            }
            if {$got ne [dict get $p exits $k]} {
                lappend problems "exits of w$k: oracle {[dict get $p exits $k]}, compiler {$got}"
            }
        }
        set all [expr {[dict size [dict get $hir affine exits]] + [dict size [dict get $hir affine errorExits]]}]
        if {$all != $counted} {
            lappend problems "exits: [expr {$all - $counted}] outside the generated functions release"
        }
        foreach backend $backends {
            set outcome [outcomeUnderHir $backend $hir]
            if {[lindex $outcome 0] ne "value" || [lindex $outcome 1] ne [lindex $expect 1]} {
                lappend problems "$backend: [lrange $outcome 0 1]; oracle [lindex $expect 1]"
            }
        }
    }
    if {$problems ne ""} {
        incr disagreements
        puts "DISAGREEMENT program $seed:\n[join $problems \n]\n--- program\n$text"
    }
}
puts "accepted $accepted rejected [expr {$n - $accepted}] ([join [lmap {k v} $kinds {string cat $k " " $v}] {, }])"
puts "early exits releasing coroutines: [join [lmap k {return fail call break continue} {string cat $k " " [expr {[dict exists $exitKinds $k] ? [dict get $exitKinds $k] : 0}]}] {, }]"
puts "programs $n disagreements $disagreements"
exit [expr {$disagreements > 0}]
