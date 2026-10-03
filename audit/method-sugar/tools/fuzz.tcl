#!/usr/bin/env tclsh9.0
# fuzz.tcl -- bounded randomized equivalence check of method-call sugar
# (METHOD-SUGAR.md).
#
#   tclsh9.0 audit/method-sugar/tools/fuzz.tcl ?-n N? ?-seed S? ?-dump 1? ?-backends LIST?
#
# Each program is generated once as a tree of ordinary calls over a prelude of
# visible functions and printed twice:
#
#   A   with every call spelled as a method call where the sugar allows it
#       (a random subset of the calls; the others stay free calls, so method
#       and free calls nest in both directions)
#   B   with every call spelled as an ordinary free call
#
# Ordinary call syntax is the oracle: on every backend the two spellings must
# produce the identical outcome -- value (with runtime evidence), error code
# (messages carry source locations, which are removed) and the log the
# program kept of its own evaluation order. Within one spelling every backend
# must also agree with the others.
#
# The trees are random in:
#
#   functions    arity 1..4 over Int; Int -> String, String -> Int,
#                String -> String, Int -> List, List -> Int, List -> List,
#                Int -> Struct, Struct -> Int; typed (declared parameter
#                types) and generic (untyped) parameters; a refinement type
#                (Small = Int in 0..10) both ways; an error-capable function
#                whose calls are handled; names bound to other names (aliases
#                of functions: `plus = add`)
#   receivers    parameters, literals, calls (method or free), parenthesized
#                arithmetic; chains of up to five method calls
#   effects      `tap(v, log, id)` records that it ran, so the evaluation
#                order of receivers and arguments is part of the outcome
#
# The run also generates NEGATIVE programs, each a valid program with exactly
# one defect in one method call:
#
#   hidden        the function exists but is not visible by that name (a
#                 module function reached only as list::any?, or a function
#                 defined after the call): must be rejected, and the
#                 diagnostic must say that no function by that name is
#                 visible
#   wrong-receiver / wrong-later / wrong-arity
#                 the receiver or a later argument has a type the function's
#                 declared parameter rejects, or the arity is wrong: must be
#                 rejected, and exactly as the free spelling is rejected
#   ambiguous     a struct with a callable field and a visible function of the
#                 same name: AMBIGUOUS-METHOD-CALL
#
# A negative program that is accepted where it must be rejected, or rejected
# differently from its free spelling, is a "negative escape".
#
# Every program is seeded individually, so any failure replays with
# `-seed S -n 1 -dump 1`. The run ends with a summary line
# "method-fuzz programs N values V errors E negatives M equivalence-
# disagreements D negative-escapes X backend-disagreements B"; the exit status
# is 1 if D, X or B is not zero.
set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set args $argv
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
interp recursionlimit {} 100000

set n 100
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

proc pick {list} { return [lindex $list [expr {int(rand() * [llength $list])}]] }
proc chance {p} { return [expr {rand() < $p}] }
proc rnd {lo hi} { return [expr {$lo + int(rand() * ($hi - $lo + 1))}] }

# ---------------------------------------------------------------------------
# The prelude: every function visible in generated programs. One entry per
# function: {NAME RESULT-TYPE PARAM-TYPES}. Types: int str list struct small.

set ::prelude {error TooSmall
error TooBig
type Small = Int in 0..10

fn probe(log, id, result):
    if mutable_array::capacity(log) == 1:
        mutable_array::set(log, 0, mutable_array::at(log, 0) * 10 + id)
    result
fn inc(a):
    a + 1
fn neg(a):
    0 - a
fn add(a, b):
    a + b
fn mul(a, b):
    a * b
fn mix3(a, b, c):
    a * b + c
fn mix4(a, b, c, d):
    a + b * c - d
fn tadd(a: int, b: int) -> int:
    a + b
fn label(n) -> str:
    str::substring("abcdefghijklmnop", 0, mod(n * n, 9) + 1)
fn shout(s):
    str::lowercase(s)
fn cat(s, t):
    str::concat(s, t)
fn size(s):
    str::length(s)
fn dup(a):
    [a, a]
fn trio(a, b, c):
    [a, b, c]
fn grow(xs, x):
    list::append(xs, x)
fn count(xs):
    list::length(xs)
fn second(xs):
    loop i from 1 to list::length(xs):
        return list::at(xs, i)
    0
fn rect(w, h):
    {w: w, h: h}
fn area(r, k):
    r.w * r.h * k
fn small(n) -> Small:
    bit_and(n, 7)
fn narrow(x: Small) -> int:
    x + 1
fn widen(x, y):
    x + y
fn tap(v, log, id):
    probe(log, id, v)
fn check(n, limit) -> int errors TooSmall, TooBig:
    if n < 0:
        fail TooSmall
    if n > limit:
        fail TooBig
    n
plus = add
bump = inc
}

# NAME RESULT PARAMS (a name may appear under several spellings: aliases).
set ::functions {
    {inc int {int}} {bump int {int}} {neg int {int}}
    {add int {int int}} {plus int {int int}} {mul int {int int}}
    {mix3 int {int int int}} {mix4 int {int int int int}} {tadd int {int int}}
    {label str {int}} {shout str {str}} {cat str {str str}} {size int {str}}
    {dup list {int}} {trio list {int int int}} {grow list {list int}}
    {count int {list}} {second int {list}}
    {rect struct {int int}} {area int {struct int}}
    {small small {int}} {narrow int {small}} {widen int {int int}}
}

# ---------------------------------------------------------------------------
# Generator. An expression is
#
#   {lit TEXT}  {var NAME}  {call NAME ARGS METHODABLE}  {paren EXPR}
#   {tap EXPR ID}           a probe call (always a call of `tap`)
#   {checked EXPR LIMIT H1 H2}  a handled call of `check` (handler values H1,
#                           H2), hoisted to a statement

set ::probeId 0
proc nextProbe {} {
    set ::probeId [expr {$::probeId % 9 + 1}]
    return $::probeId
}

proc functionsReturning {type} {
    return [lmap f $::functions {if {[lindex $f 1] eq $type} {set f} else continue}]
}

proc genExpr {type depth} {
    # Leaves, or a call.
    if {$depth <= 0 || [chance 0.2]} {
        return [genLeaf $type]
    }
    if {$type eq "int" && [chance 0.07]} {
        return [list checked [genExpr int [expr {$depth - 1}]] [rnd 5 40] [rnd 0 3] [rnd 4 9]]
    }
    if {$type eq "int" && [chance 0.12]} {
        return [list tap [genExpr int [expr {$depth - 1}]] [nextProbe]]
    }
    set candidates [functionsReturning $type]
    if {$candidates eq {}} {
        return [genLeaf $type]
    }
    lassign [pick $candidates] name result params
    set args [lmap p $params {genExpr $p [expr {$depth - 1}]}]
    return [list call $name $args [chance 0.75]]
}

proc genLeaf {type} {
    switch -- $type {
        int {
            return [pick [list {var a} {var b} [list lit [rnd 0 30]] [list lit [rnd 0 9]] \
                [list paren [list binary + {var a} [list lit [rnd 1 9]]]]]]
        }
        str {
            return [pick [list {var s} [list lit "\"[pick {x yz Hello abc}]\""]]]
        }
        list {
            return [pick [list [list call dup [list [genLeaf int]] 1] [list call trio [list [genLeaf int] {var a} {var b}] 0]]]
        }
        struct {
            return [list call rect [list [genLeaf int] [genLeaf int]] [chance 0.5]]
        }
        small {
            return [list call small [list [genLeaf int]] [chance 0.5]]
        }
    }
}

# The source text of EXPR; STYLE is method (the sugar where METHODABLE) or
# free. Hoisted handled-call statements are appended to ::hoisted.
proc emit {expr style} {
    switch -- [lindex $expr 0] {
        lit { return [lindex $expr 1] }
        var { return [lindex $expr 1] }
        paren { return "([emit [lindex $expr 1] $style])" }
        binary {
            lassign $expr _ op l r
            return "[emit $l $style] $op [emit $r $style]"
        }
        tap {
            lassign $expr _ inner id
            if {$style eq "method"} {
                return "[Receiver $inner $style].tap(log, $id)"
            }
            return "tap([emit $inner $style], log, $id)"
        }
        checked {
            lassign $expr _ inner limit h1 h2
            # The operand first (its own hoisted statements precede ours),
            # then this call's temporary.
            if {$style eq "method"} {
                set call "[Receiver $inner $style].check($limit)"
            } else {
                set call "check([emit $inner $style], $limit)"
            }
            set name t[incr ::tempId]
            lappend ::hoisted "    $name = $call:" "        on TooSmall:" "            $h1" "        on TooBig:" "            $h2"
            return $name
        }
        call {
            lassign $expr _ name args methodable
            if {$style eq "method" && $methodable} {
                set recv [Receiver [lindex $args 0] $style]
                set rest [lmap a [lrange $args 1 end] {emit $a $style}]
                return "${recv}.${name}([join $rest {, }])"
            }
            return "${name}([join [lmap a $args {emit $a $style}] {, }])"
        }
    }
}

# The receiver text of EXPR: a binary expression or other low-precedence
# form is parenthesized; everything the generator makes is already a primary
# or postfix expression.
proc Receiver {expr style} {
    return [emit $expr $style]
}

proc program {expr style} {
    set ::hoisted {}
    set ::tempId 0
    set text [emit $expr $style]
    set lines [list $::prelude "fn run(a, b, s):" \
        "    log = mutable_array::allocate(1)" "    mutable_array::set(log, 0, 0)"]
    lappend lines {*}$::hoisted
    lappend lines "    r = $text" "    \[r, mutable_array::at(log, 0)\]"
    lappend lines {[run(3, 5, "xy"), run(0, 2, "abc"), run(7, 1, "q"), run(12, 4, "Hello")]}
    return [join [lflatten $lines] \n]
}

proc lflatten {lines} {
    set result {}
    foreach line $lines {
        foreach l [split $line \n] {
            lappend result $l
        }
    }
    return $result
}

# ---------------------------------------------------------------------------
# Running

# The outcome of SOURCE on BACKEND with error locations removed; a
# compile-time rejection is an outcome too ({error CODE MESSAGE}): both
# spellings must be rejected for the same reason.
proc stripLocations {message} {
    set message [regsub -all {[^ ]*\.bot:[0-9]+:[0-9]+} $message {t.bot:L:C}]
    return [regsub -all {\(at [0-9]+:[0-9]+\)} $message {(at L:C)}]
}

proc compileOrError {source} {
    if {[catch {surface::compile $source t.bot} hir options]} {
        return [list error [dict get $options -errorcode] [stripLocations $hir]]
    }
    return [list ok $hir]
}

proc outcomeOf {backend source} {
    set compiled [compileOrError $source]
    if {[lindex $compiled 0] eq "error"} {
        return $compiled
    }
    set outcome [outcomeUnderHir $backend [lindex $compiled 1]]
    if {[lindex $outcome 0] eq "error"} {
        lset outcome 2 [stripLocations [lindex $outcome 2]]
    }
    return $outcome
}

# The outcomes of SOURCE on every backend: one list.
proc outcomesOf {source} {
    set compiled [compileOrError $source]
    if {[lindex $compiled 0] eq "error"} {
        return [lmap b $::backends {set compiled}]
    }
    return [lmap b $::backends {outcomeOf $b $source}]
}

set programs 0
set methodCalls 0
set values 0
set errors 0
set negatives 0
set equivalenceDisagreements 0
set negativeEscapes 0
set backendDisagreements 0

# ---------------------------------------------------------------------------
# Negative programs: a valid base with one defective method call.

set ::negativeBase {fn run(a, b, s):
    log = mutable_array::allocate(1)
    mutable_array::set(log, 0, 0)
    r = %s
    [r, mutable_array::at(log, 0)]
[run(3, 5, "xy"), run(0, 2, "abc")]}

proc negative {kind} {
    set pred "fn is_big(x):\n    x > 1\n"
    switch -- $kind {
        hidden-module {
            # list::any? exists, takes a List first: not visible as `any?`.
            return [list "$::prelude$pred[format $::negativeBase {[a, b].any?(is_big)}]" \
                "$::prelude$pred[format $::negativeBase {list::any?([a, b], is_big)}]" "no function named \"any?\" is visible"]
        }
        hidden-later {
            return [list "$::prelude[format $::negativeBase {a.late(b)}]\nfn late(x, y):\n    x + y" \
                "" "no function named \"late\" is visible"]
        }
        hidden-aliased-original {
            # `plus` is visible, the function it names is also visible as
            # `add`; a function bound to a local name hides nothing, but a
            # name that exists only inside another function is not visible.
            return [list "$::prelude\nfn inner_only(x):\n    fn hidden(y):\n        y + 1\n    hidden(x)\n[format $::negativeBase {a.hidden()}]" \
                "" "no function named \"hidden\" is visible"]
        }
        wrong-receiver {
            return [list "$::prelude[format $::negativeBase {"x".tadd(b)}]" "$::prelude[format $::negativeBase {tadd("x", b)}]" ""]
        }
        wrong-receiver-refined {
            return [list "$::prelude[format $::negativeBase {(a + 20).narrow()}]" "$::prelude[format $::negativeBase {narrow(a + 20)}]" ""]
        }
        wrong-later {
            return [list "$::prelude[format $::negativeBase {a.tadd("x")}]" "$::prelude[format $::negativeBase {tadd(a, "x")}]" ""]
        }
        wrong-arity-few {
            return [list "$::prelude[format $::negativeBase {a.mix3(b)}]" "$::prelude[format $::negativeBase {mix3(a, b)}]" ""]
        }
        wrong-arity-many {
            return [list "$::prelude[format $::negativeBase {a.inc(b)}]" "$::prelude[format $::negativeBase {inc(a, b)}]" ""]
        }
        wrong-arity-zero {
            return [list "$::prelude\nfn zero():\n    1\n[format $::negativeBase {a.zero()}]" "$::prelude\nfn zero():\n    1\n[format $::negativeBase {zero(a)}]" ""]
        }
        ambiguous {
            set decl "fn cb(x):\n    x + 100\ns2 = {cb: inc, v: 3}\n"
            return [list "$::prelude$decl[format $::negativeBase {s2.cb(a)}]" "" "AMBIGUOUS-METHOD-CALL"]
        }
    }
}

set negativeKinds {hidden-module hidden-later hidden-aliased-original wrong-receiver wrong-receiver-refined
    wrong-later wrong-arity-few wrong-arity-many wrong-arity-zero ambiguous}

for {set k 0} {$k < $n} {incr k} {
    set seed [expr {$seed0 + $k}]
    expr {srand($seed)}
    set ::probeId 0
    set type [pick {int int int str list}]
    set tree [genExpr $type [rnd 2 5]]
    if {$type ne "int"} {
        # Keep the program's value an Int-or-printable: any type is fine for r.
    }
    set sourceA [program $tree method]
    set sourceB [program $tree free]
    if {$dump} {
        puts "---- seed $seed ($type)\n$sourceA\n-- free --\n$sourceB"
    }
    incr programs
    incr methodCalls [regexp -all {[A-Za-z0-9_)]\.[a-z_0-9]+\(} [string range $sourceA [string length $::prelude] end]]
    set outcomesA [outcomesOf $sourceA]
    set outcomesB [outcomesOf $sourceB]
    if {$outcomesA ne $outcomesB} {
        incr equivalenceDisagreements
        puts "EQUIVALENCE DISAGREEMENT seed $seed"
        foreach backend $backends a $outcomesA b $outcomesB {
            if {$a ne $b} {
                puts "  $backend: method [string range $a 0 300]\n  $backend: free   [string range $b 0 300]"
            }
        }
    }
    if {[llength [lsort -unique $outcomesA]] > 1} {
        incr backendDisagreements
        puts "BACKEND DISAGREEMENT seed $seed"
        foreach backend $backends a $outcomesA {
            puts "  $backend: [string range $a 0 300]"
        }
    }
    if {[lindex $outcomesA 0 0] eq "value"} {
        incr values
    } else {
        incr errors
        puts "note: seed $seed is an error outcome on both spellings: [string range [lrange [lindex $outcomesA 0] 0 1] 0 120]"
    }

    # One negative program per generated program.
    set kind [lindex $negativeKinds [expr {$k % [llength $negativeKinds]}]]
    lassign [negative $kind] methodSource freeSource expectation
    incr negatives
    set negA [outcomesOf $methodSource]
    set escape ""
    if {[lindex $negA 0 0] eq "error" && [lrange [lindex $negA 0 1] 0 1] eq "SURFACE SYNTAX"} {
        set escape "$kind: the defective program does not even parse (a generator bug): [string range [lindex $negA 0] 0 200]"
    } elseif {[lindex $negA 0 0] eq "value"} {
        set escape "accepted a $kind defect and produced a value"
    } elseif {$expectation ne ""} {
        if {[string first $expectation [lindex $negA 0 2]] < 0 && [string first $expectation [lindex $negA 0 1]] < 0} {
            set escape "rejected a $kind defect, but not with \"$expectation\": [string range [lindex $negA 0] 0 300]"
        }
    } elseif {$freeSource ne ""} {
        set negB [outcomesOf $freeSource]
        if {$negA ne $negB} {
            set escape "$kind: the method spelling is rejected differently from the free spelling: [string range [lindex $negA 0] 0 200] / [string range [lindex $negB 0] 0 200]"
        }
    }
    if {$escape ne ""} {
        incr negativeEscapes
        puts "NEGATIVE ESCAPE seed $seed ($kind): $escape"
    }
}
puts "method-fuzz-coverage method-calls $methodCalls"
puts "method-fuzz programs $programs values $values errors $errors negatives $negatives equivalence-disagreements $equivalenceDisagreements negative-escapes $negativeEscapes backend-disagreements $backendDisagreements"
exit [expr {$equivalenceDisagreements || $negativeEscapes || $backendDisagreements ? 1 : 0}]
