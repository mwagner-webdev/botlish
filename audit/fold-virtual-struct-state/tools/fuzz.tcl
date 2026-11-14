# fuzz.tcl -- the differential fuzzer of fold slots (FOLD-VIRTUAL-STRUCT-
# STATE-MILESTONE-1.md): random folds over a struct intermediate, every
# program run on every backend and against the lowering without fold slots.
#
#   tclsh9.0 audit/fold-virtual-struct-state/tools/fuzz.tcl ?-seed N?
#       ?-count N? ?-gc-stress 0|1? ?-keep DIR? ?-verbose 0|1?
#
# Each program is one of three templates:
#
#   scalar   a struct of 2-6 Int fields; the body's statements are drawn from
#            a pool -- a `continue` or a `break` under a condition, a
#            candidate successor bound to a local, an exact call of the
#            intermediate (a function taking it whole), an open call (a
#            function value chosen at run time), an equality, an early
#            `return` of the intermediate, a call whose declared error is
#            handled (to a value, or by a `continue`) or escapes the fold, an
#            inner fold seeded with the intermediate, a nested function that
#            captures it -- and the completion is a chain of `if`s whose
#            leaves are the intermediate itself, literals whose fields keep,
#            permute, repeat and combine the old fields, a candidate, an
#            exact helper's result or an inner fold's value;
#   history  an anonymous {p: S, seen: List[S]} intermediate that retains its
#            earlier versions' S in a List (observed after the fold);
#   vector   a struct of a count and a MutableVector pushed every iteration,
#            with or without a `continue` after the push (consumed, or
#            copied at every iteration's entry).
#
# For each program it checks:
#
#   * values -- the outcome on interp, compile, cranelift-generic,
#     cranelift, cranelift with fold slots off (BOTLISH_NATIVE_STRUCT_FOLD=0),
#     with reference joins off, with struct scalar replacement off and with
#     coroutine fusion off (and, with -gc-stress 1, cranelift and
#     cranelift-generic under BOTLISH_NATIVE_GC_STRESS=1) is one;
#   * decisions -- the fold slot of `run` is carried or declined as the
#     fuzzer's own model predicts from the statements it generated (a
#     capture declines it; a materializing use -- an open call, an equality
#     -- followed in the iteration by a path that keeps the intermediate --
#     a `continue`, an identity leaf -- declines it, no loss; anything else
#     is carried). The model knows nothing of hir/escape.tcl's predicates;
#   * no loss -- the native run's Struct allocations with fold slots are at
#     most those without (native::allocationReport, no GC stress).
#
# Exits 1 on any difference; -keep DIR keeps each failing program there.
# Its scratch files live in a `file tempdir` directory, removed at the end.

set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
set seed 1
set count 40
set gcStress 0
set keep ""
set verbose 0
foreach {option value} $argv {
    switch -- $option {
        -seed { set seed $value }
        -count { set count $value }
        -gc-stress { set gcStress $value }
        -keep { set keep [file normalize $value] }
        -verbose { set verbose $value }
        default { error "usage: fuzz.tcl ?-seed N? ?-count N? ?-gc-stress 0|1? ?-keep DIR? ?-verbose 0|1?" }
    }
}
set env(LANG) C.utf8
set env(LC_ALL) C.utf8
unset -nocomplain env(BOTLISH_NATIVE_GC_STRESS) env(BOTLISH_HIR_CACHE)
# (tests/helpers.tcl hands argv to tcltest.)
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root native native.tcl]
core::useProgramRecursionLimit
expr {srand($seed)}

proc pick {list} {
    return [lindex $list [expr {int(rand() * [llength $list])}]]
}
proc chance {p} {
    return [expr {rand() < $p}]
}
proc rnd {lo hi} {
    return [expr {$lo + int(rand() * ($hi - $lo + 1))}]
}

# ---------------------------------------------------------------------------
# Generation

# A random Int List literal of 0-5 elements, each 1-7.
proc listLiteral {} {
    set n [rnd 0 5]
    set xs {}
    for {set i 0} {$i < $n} {incr i} {
        lappend xs [rnd 1 7]
    }
    return "\[[join $xs {, }]\]"
}

# A condition on the element x or a field of VAR.
proc condition {var fields} {
    switch -- [rnd 0 2] {
        0 { return "x.mod([rnd 2 4]) == [rnd 0 1]" }
        1 { return "x > [rnd 2 5]" }
        2 { return "$var.[pick $fields] > [rnd 3 20]" }
    }
}

# A field expression of field I for a literal built from VAR (fields
# FIELDS), using any of the Int locals INTS.
proc fieldExpr {var fields i ints} {
    set fi [lindex $fields $i]
    set choices [list "$var.$fi" "$var.[pick $fields]" "$var.$fi + x" \
        "$var.[pick $fields] + $var.[pick $fields]" "x * 2" [rnd 0 3]]
    if {$ints ne ""} {
        lappend choices "$var.$fi + [pick $ints]"
    }
    return [pick $choices]
}

proc literal {name var fields ints} {
    set parts {}
    set i 0
    foreach f $fields {
        lappend parts "$f: [fieldExpr $var $fields $i $ints]"
        incr i
    }
    return "$name {[join $parts {, }]}"
}

proc indent {text n} {
    set pad [string repeat " " $n]
    return [join [lmap line [split $text \n] {if {$line eq ""} {set line} else {string cat $pad $line}}] \n]
}

# {TEXT MODEL NAME LABEL} of a `scalar` program: MODEL is {virtual} or
# {dropped WHY}, for fold intermediate NAME of the instance LABEL of `run`.
proc scalarProgram {} {
    set w [rnd 2 6]
    set fields [lmap i [lrange {0 1 2 3 4 5} 0 [expr {$w - 1}]] {string cat f $i}]
    set ints {}
    set candidates {}
    set inners {}
    set stmts {}
    set usesOpen 0
    set usesExact 0
    set usesCheck 0
    set escapes 0
    set captured 0
    set matSeen 0
    set keepAfterMat 0
    set nStmts [rnd 0 4]
    for {set k 0} {$k < $nStmts} {incr k} {
        switch -- [pick {continue break candidate exact open equal return handled handledcontinue escape inner capture}] {
            continue {
                lappend stmts "if [condition s $fields]:\n    continue"
                if {$matSeen} { set keepAfterMat 1 }
            }
            break {
                lappend stmts "if [condition s $fields]:\n    break"
            }
            candidate {
                lappend stmts "n$k = [literal S s $fields $ints]"
                lappend candidates n$k
            }
            exact {
                lappend stmts "w$k = weigh(s)"
                lappend ints w$k
                set usesExact 1
            }
            open {
                lappend stmts "w$k = f(s)"
                lappend ints w$k
                set usesOpen 1
                set matSeen 1
            }
            equal {
                lappend stmts "e$k = s == [literal S s $fields {}]\nq$k = if e$k:\n    1\nelse:\n    0"
                lappend ints q$k
                set matSeen 1
            }
            return {
                lappend stmts "if x == [rnd 3 6]:\n    return s"
            }
            handled {
                lappend stmts "c$k = check(x):\n    on Bad:\n        0"
                lappend ints c$k
                set usesCheck 1
            }
            handledcontinue {
                lappend stmts "c$k = check(x):\n    on Bad:\n        continue"
                lappend ints c$k
                set usesCheck 1
                if {$matSeen} { set keepAfterMat 1 }
            }
            escape {
                lappend stmts "c$k = check(x)"
                lappend ints c$k
                set usesCheck 1
                set escapes 1
            }
            inner {
                lappend stmts "t$k = fold y in \[x, 1\] with intermediate u s:\n    [literal S u $fields {}]"
                lappend inners t$k
            }
            capture {
                lappend stmts "fn g${k}() -> int:\n    s.[lindex $fields 0] + x"
                lappend ints g${k}()
                set captured 1
            }
        }
    }
    # The completion: an `if` chain of 1-3 leaves.
    set nLeaves [rnd 1 3]
    set leaves {}
    set identity 0
    for {set i 0} {$i < $nLeaves} {incr i} {
        set kinds {literal literal identity helper}
        if {$candidates ne ""} { lappend kinds candidate }
        if {$inners ne ""} { lappend kinds inner }
        switch -- [pick $kinds] {
            literal { lappend leaves [literal S s $fields $ints] }
            identity { lappend leaves s; set identity 1 }
            helper { lappend leaves "adv(s, x)" }
            candidate { lappend leaves [pick $candidates] }
            inner { lappend leaves [pick $inners] }
        }
    }
    if {[llength $leaves] == 1} {
        set completion [lindex $leaves 0]
    } else {
        set completion "if [condition s $fields]:\n    [lindex $leaves 0]"
        foreach leaf [lrange $leaves 1 end-1] {
            append completion "\nelif [condition s $fields]:\n    $leaf"
        }
        append completion "\nelse:\n    [lindex $leaves end]"
    }
    if {$identity && $matSeen} {
        set keepAfterMat 1
    }
    set decl "struct S:\n[join [lmap f $fields {string cat "    $f: int"}] \n]\n"
    set initial "S {[join [lmap f $fields {string cat "$f: [rnd 0 3]"}] {, }]}"
    set errors [expr {$escapes ? " errors Bad" : ""}]
    set text "import std::list\n\nerror Bad\n\n$decl
fn check(x: int) -> int errors Bad:
    if x == 5:
        fail Bad
    x

fn weigh(p: S) -> int:
    p.[lindex $fields 0] + p.[lindex $fields end]

fn weigh2(p: S) -> int:
    p.[lindex $fields 0] * 2

fn adv(p: S, x: int) -> S:
    [literal S p $fields {}]

fn run(xs: List\[int\], k: int) -> S$errors:
"
    if {$usesOpen} {
        append text "    f = if k > 0:\n        weigh\n    else:\n        weigh2\n"
    }
    append text "    fold x in xs with intermediate s $initial:\n"
    foreach st $stmts {
        append text [indent $st 8] \n
    }
    append text [indent $completion 8] \n
    set out "\[[join [lmap f $fields {string cat r. $f}] {, }]\]"
    append text "
fn safe(xs: List\[int\], k: int) -> List\[int\]:
    r = run(xs, k):
        on Bad:
            return \[-1\]
    $out

\[safe([listLiteral], 1), safe([listLiteral], 0), safe([listLiteral], 1), safe(\[1, 2, 3, 4, 5, 6, 7\], 1)\]
"
    if {!$escapes} {
        # run declares no error: safe's handler would be a static error.
        set text [string map [list "    r = run(xs, k):\n        on Bad:\n            return \[-1\]\n" "    r = run(xs, k)\n"] $text]
    }
    if {$captured} {
        set model {dropped capture}
    } elseif {$keepAfterMat} {
        set model {dropped no-loss}
    } else {
        set model virtual
    }
    return [list $text $model s {run<List[int], int>}]
}

# {TEXT MODEL NAME LABEL} of a `history` program.
proc historyProgram {} {
    set fields {a b}
    set text "import std::list

struct S:
    a: int
    b: int

fn run(xs: List\[int\]) -> List\[int\]:
    t = fold x in xs with intermediate s {p: S {a: 0, b: 1}, seen: \[\]}:
"
    if {[chance 0.5]} {
        append text "        if [condition s.p $fields]:\n            continue\n"
    }
    set store "{p: [literal S s.p $fields {}], seen: s.seen.append(s.p)}"
    if {[chance 0.5]} {
        append text "        if [condition s.p $fields]:\n            s\n        else:\n            $store\n"
    } else {
        append text "        $store\n"
    }
    append text "    fold q in t.seen with intermediate z \[t.p.a, t.p.b, t.seen.length()\]:
        z.append(q.a * 10 + q.b)

\[run([listLiteral]), run([listLiteral]), run(\[1, 2, 3, 4, 5\])\]
"
    return [list $text virtual s {run<List[int]>}]
}

# {TEXT MODEL NAME LABEL} of a `vector` program.
proc vectorProgram {} {
    set copying [chance 0.5]
    set text "import std::list
import std::mutable_vector

struct Acc:
    count: int
    items: MutableVector\[int\]

fn ints() -> MutableVector\[int\]:
    std::mutable_vector::from_list(\[\])

fn total(v: MutableVector\[int\]) -> int:
    fold i from 0 to v.length() with intermediate t 0:
        t + v.at(i)

fn run(n: int) -> List\[int\]:
    r = fold i from 0 to n with intermediate a Acc {count: 0, items: ints()}:
        a.items.push(i * [rnd 1 3])
"
    if {$copying} {
        append text "        if i.mod([rnd 2 4]) != 0:\n            continue\n"
    }
    if {[chance 0.3]} {
        append text "        if i == [rnd 1 5]:\n            a\n        else:\n            Acc {count: a.count + 1, items: a.items}\n"
    } else {
        append text "        Acc {count: a.count + [rnd 1 2], items: a.items}\n"
    }
    append text "    \[r.count, r.items.length(), total(r.items)\]

\[run([rnd 0 3]), run([rnd 4 12])\]
"
    return [list $text virtual [expr {$copying ? "a#entry" : "a"}] run<int>]
}

# ---------------------------------------------------------------------------
# Checking

set configs {
    interp {}
    compile {}
    cranelift-generic {}
    cranelift {}
    cranelift {BOTLISH_NATIVE_STRUCT_FOLD 0}
    cranelift {BOTLISH_NATIVE_STRUCT_REF_JOINS 0}
    cranelift {BOTLISH_NATIVE_STRUCT_OPT 0}
    cranelift-unfused {}
}
if {$gcStress} {
    lappend configs cranelift {BOTLISH_NATIVE_GC_STRESS 1} cranelift-generic {BOTLISH_NATIVE_GC_STRESS 1}
}

proc withEnv {pairs script} {
    set saved {}
    foreach {name value} $pairs {
        lappend saved $name [expr {[info exists ::env($name)] ? [list 1 $::env($name)] : [list 0 ""]}]
        set ::env($name) $value
    }
    try {
        return [uplevel 1 $script]
    } finally {
        foreach {name old} $saved {
            if {[lindex $old 0]} {
                set ::env($name) [lindex $old 1]
            } else {
                unset ::env($name)
            }
        }
    }
}

proc structs {hir args} {
    return [dict get [native::allocationReport $hir summary 1 {*}$args] byKind Struct allocations]
}

set work [file tempdir fvss-fuzz]
set failures 0
set tally [dict create]
try {
    for {set i 0} {$i < $count} {incr i} {
        set template [pick {scalar scalar scalar history vector}]
        lassign [${template}Program] text model name label
        set problems {}
        if {[catch {surface::compile $text fuzz.bot -warnings off} hir]} {
            lappend problems "does not compile: [lindex [split $hir \n] 0]"
        } else {
            set outcomes {}
            foreach {backend envPairs} $configs {
                set outcome [withEnv $envPairs {
                    if {[catch {lrange [outcomeUnderHir $backend $hir] 0 1} o]} {
                        set o [list crash $o]
                    }
                    set o
                }]
                lappend outcomes "$backend $envPairs" $outcome
            }
            set distinct [lsort -unique [dict values $outcomes]]
            if {[llength $distinct] != 1} {
                lappend problems "outcomes differ: $outcomes"
            } elseif {[lindex $distinct 0 0] ne "value"} {
                lappend problems "not a value: [lindex $distinct 0]"
            }
            set slot {}
            foreach rec [native::foldSlots $hir] {
                # (The instance whose body runs: an empty List literal's
                # List[never] instance never runs its fold's body.)
                if {[dict get $rec label] eq $label && [dict get $rec name] eq $name} {
                    set slot [expr {[dict get $rec status] eq "virtual" ? "virtual" : [list dropped [dict get $rec reason]]}]
                }
            }
            if {$slot ne $model} {
                lappend problems "decision: the model predicts {$model}, the compiler {$slot}"
            }
            set with [structs $hir]
            set without [structs $hir -struct-fold 0]
            if {$with > $without} {
                lappend problems "loss: $with structs with fold slots, $without without"
            }
            dict incr tally "$template [lindex $model 0]"
        }
        if {$problems ne ""} {
            incr failures
            puts "== program $i ($template, seed $seed)"
            foreach p $problems { puts "   $p" }
            if {$verbose} { puts $text }
            if {$keep ne ""} {
                file mkdir $keep
                set f [open [file join $keep "seed$seed-$i.bot"] w]
                puts -nonewline $f $text
                close $f
            }
        } elseif {$verbose} {
            puts "ok $i $template $model"
        }
    }
} finally {
    file delete -force $work
}
puts "seed $seed: $count programs ([lsort -stride 2 $tally]), $failures failing"
exit [expr {$failures > 0}]
