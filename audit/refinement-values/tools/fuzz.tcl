# fuzz.tcl -- differential fuzzer for refinement values (REFINEMENT-VALUES.md).
#
#   tclsh9.0 audit/refinement-values/tools/fuzz.tcl ?-seed N? ?-count N? ?-backends LIST? ?-accept P? ?-validators 0|1? ?-v 1? ?-show 1?
#
# -accept P: the share of programs drawn (by retrying) until the oracle
# accepts them; the rest are taken as generated, mostly rejections (with
# validators, 70% of the rest are drawn until the oracle rejects exactly one
# use: the programs a compiler that proves too much would accept).
# -show 1 prints every accepted program with a decided call, -show 2 every
# accepted program with a validator call.
# -validators 0 generates exactly the programs of the predicate-only
# generator (the same random draws, prelude and printing), so its recorded
# runs stay reproducible; 1 (the default) adds validators (below).
#
# Generates random programs over a fixed set of refinements and proof-
# producing predicates -- two sibling refinements of str (R1, R2), a
# refinement of a refinement (R3 = R1), two different predicates proving R1
# (p1?, q1?), one proving R2 (p2?), one proving R3 from an R1 (p3?), and a
# predicate proving R1 that is NOT repeatable (n1?: it hashes) -- and a
# random body for f(a: str, b: str) of: immutable aliases, Boolean bindings
# of conditions, guards with early returns, statement-level ifs whose
# branches may hold a guard before binding (so a fact a branch did not
# start with can hold at its end, and the join matters), nested
# if-expressions whose branches may shadow a or b with another value (so a
# spelling is not a value), and leaves that need R1/R2/R3 or only str. need3
# forgets its R3 to R1 through a call, so the prelude itself depends on the
# chain. Conditions are predicate calls, Boolean bindings, not, and, or.
#
# Validators (`-> unit proves s: R`, REFINEMENT-VALUES.md "Validators"):
# validate_r1 and validate_q1 prove R1 with different failure thresholds,
# validate_r2 proves R2, validate_r3 proves R3 from an R1, and validate_lax
# proves R2 and never fails (no errors clause). f declares `errors Invalid`
# and the program calls it through g, whose handler turns an escaping
# Invalid into -1. Validator statements, in bodies and in statement-if
# branches: a plain call, a binding `uN = validate_x(v)`, method sugar
# `v.validate_x()`; a handled call (statement or bound) whose handler
# returns, fails, completes without a proof, completes after a guard, uses a
# value (so a handler that sees the failed call's proof is caught) or
# validates again; `pair(validate_x(v), need(v))`, the validator as an
# argument (its fact holds for the later argument; handled, the handler also
# runs when the argument fails, so it must not see that proof); a counted
# loop whose body validates and uses (its facts end with the body); and
# `use` statements, a leaf call whose value is discarded.
#
# An independent oracle (this file; it shares no code with the compiler)
# models what the language says:
#
#   * carrier and nominal refinement facts per binding (a closure: R3
#     implies R1), established by a true proof or a validator's normal
#     completion and attached to the value -- the argument's binding and the
#     binding it aliases, never a spelling;
#   * exact predicate-result facts, keyed by predicate and value identity
#     (the alias root), decided only for repeatable predicates; a validator
#     call is never decided;
#   * control flow: each outcome's facts of not/and/or (their lowering to
#     if-expressions), Boolean bindings carrying their implication, and the
#     join of a statement if: facts true at the end of every reachable
#     branch that completes; after a handled validator call, the facts true
#     on the call's normal completion and at the end of every handler that
#     completes (each handler starting from the facts before the call); a
#     loop body's facts end with it;
#   * acceptance: every leaf's argument proven what its parameter requires
#     (reachable or not: the compiler type-checks dead code too), and so is
#     every validate_r3/p3? argument;
#   * the value of the program, evaluated concretely.
#
# Each program is compiled once. A predicted rejection must be a compile-time
# TYPE error; a predicted acceptance must compile, run to the oracle's value
# on every backend, and decide exactly the predicate calls the oracle
# decides (the HIR `known` field of each predicate and validator call, in
# order).

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 200000

set options [dict create -seed 1 -count 200 -backends {interp compile cranelift-generic cranelift} -accept 0.7 -validators 1 -v 0 -show 0]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}
expr {srand([dict get $options -seed])}
set validating [dict get $options -validators]

proc pick {list} { lindex $list [expr {int(rand() * [llength $list])}] }
proc chance {p} { expr {rand() < $p} }

set prelude {import str

refined type R1 = str
refined type R2 = str
refined type R3 = R1

fn p1?(s: str) -> bool proves s: R1:
    str::length(s) > 2

fn q1?(s: str) -> bool proves s: R1:
    str::length(s) > 3

fn p2?(s: str) -> bool proves s: R2:
    str::length(s) < 5

fn p3?(s: R1) -> bool proves s: R3:
    str::length(s) > 4

fn n1?(s: str) -> bool proves s: R1:
    str::length(s) > 2 and hash(s) == hash(s)

fn need1(x: R1) -> int:
    str::length(x)

fn need2(x: R2) -> int:
    10 * str::length(x)

fn need3(x: R3) -> int:
    100 * need1(x)

fn plain(x: str) -> int:
    1000

}

if {$validating} {
    append prelude {error Invalid

fn validate_r1(s: str) -> unit proves s: R1 errors Invalid:
    if str::length(s) <= 2:
        fail Invalid
    unit

fn validate_q1(s: str) -> unit proves s: R1 errors Invalid:
    if str::length(s) <= 3:
        fail Invalid
    unit

fn validate_r2(s: str) -> unit proves s: R2 errors Invalid:
    if str::length(s) >= 5:
        fail Invalid
    unit

fn validate_r3(s: R1) -> unit proves s: R3 errors Invalid:
    if str::length(s) <= 4:
        fail Invalid
    unit

fn validate_lax(s: str) -> unit proves s: R2:
    unit

fn pair(u: unit, n: int) -> int:
    n

}
}

# Predicate -> {refinement proven, refinement required of the argument,
# repeatable, concrete test}.
set preds {
    p1? {R1 {} 1 {expr {$n > 2}}}
    q1? {R1 {} 1 {expr {$n > 3}}}
    p2? {R2 {} 1 {expr {$n < 5}}}
    p3? {R3 R1 1 {expr {$n > 4}}}
    n1? {R1 {} 0 {expr {$n > 2}}}
}
# Validator -> {refinement proven, refinement required of the argument,
# concrete failure test}.
set validators {
    validate_r1 {R1 {} {expr {$n <= 2}}}
    validate_q1 {R1 {} {expr {$n <= 3}}}
    validate_r2 {R2 {} {expr {$n >= 5}}}
    validate_r3 {R3 R1 {expr {$n <= 4}}}
    validate_lax {R2 {} {expr {0}}}
}
set closure {R1 {R1} R2 {R2} R3 {R1 R3}}
set inputs {{ab abcdef} {abcd x} {abcdefg abc} {{} abcde} {abcde abcde}}

# ---------------------------------------------------------------------------
# Generation: an AST over string variables (params a, b; aliases tN) and
# Boolean variables (okN).

proc genCond {strs bools depth} {
    global preds
    set r [expr {rand()}]
    if {$depth > 0 && $r < 0.15} {
        return [list not [genCond $strs $bools [expr {$depth - 1}]]]
    }
    if {$depth > 0 && $r < 0.30} {
        return [list [pick {and or}] [genCond $strs $bools [expr {$depth - 1}]] [genCond $strs $bools [expr {$depth - 1}]]]
    }
    if {$bools ne {} && $r < 0.45} {
        return [list ref [pick $bools]]
    }
    # Few predicates over few values, so that the same call recurs: the
    # current bindings of a and b are drawn twice as often.
    return [list call [pick {p1? p1? q1? p2? p3? n1?}] [pick [concat $strs [lsearch -all -inline -regexp $strs {^[ab](#|$)}]]]]
}


# A statement: {alias T V} | {bool OK COND} | {guard COND K} (`if COND:
# return K`) | {sif COND THEN ELSE}, THEN and ELSE statement lists of an
# optional guard then one alias (branch-scoped names): a guard in a branch is
# what makes a fact the branch did not start with true at its end.
proc genBranch {strs bools counterVar} {
    upvar 1 $counterVar counter
    set stmts {}
    if {[chance 0.5]} {
        lappend stmts [list guard [genCond $strs $bools 1] [expr {int(rand() * 9)}]]
    }
    if {$::validating} {
        # A validator in a branch: its fact holds in the branch, and after
        # the if only when every completing branch proves it.
        if {[chance 0.5]} {
            lappend stmts {*}[genValidation $strs $bools counter 0]
        }
        if {[chance 0.4]} {
            lappend stmts [list use [genUseLeaf $strs]]
        }
    }
    lappend stmts [list alias t[incr counter] [pick $strs]]
    return $stmts
}

# A string binding to pass, the current a and b drawn twice as often.
proc pickStr {strs} {
    return [pick [concat $strs [lsearch -all -inline -regexp $strs {^[ab](#|$)}]]]
}

# A leaf for a `use` statement (its value is discarded).
proc genUseLeaf {strs} {
    return [list leaf [pick {need1 need2 need3 plain}] [pickStr $strs]]
}

# A leaf that needs what validator X proves of V (or, half the time, any
# leaf; sometimes what X proves, of another value -- an alias root, a
# shadowed or unrelated one): what a fact that is (or is not) there is caught
# by.
proc genTargetLeaf {strs x v} {
    if {[chance 0.5]} {
        return [genUseLeaf $strs]
    }
    set need [dict get {validate_r1 need1 validate_q1 need1 validate_r2 need2 validate_r3 need3 validate_lax need2} $x]
    return [list leaf $need [expr {[chance 0.7] ? $v : [pickStr $strs]}]]
}

# Validator statements (-validators 1), a list of:
#
#   {validate X V FORM NAME}     X(V), NAME = X(V) or V.X() (FORM stmt, bind,
#                                method)
#   {vhandle X V HANDLER NAME}   X(V) handled by HANDLER, bound to NAME
#                                unless NAME is ""
#   {varg X V LEAF HANDLER NAME} pair(X(V), LEAF): the validator as an
#                                argument, handled unless HANDLER is "",
#                                bound unless NAME is ""
#   {use LEAF}                   LEAF as a statement
#   {vloop K STMTS}              loop i from 0 to K: STMTS (LOOPS 1 only)
#
# A validator call is often followed by a use that needs what it proves.
proc genValidation {strs bools counterVar {loops 1}} {
    upvar 1 $counterVar counter
    set r [expr {rand()}]
    set v [pickStr $strs]
    set x [pick {validate_r1 validate_r1 validate_q1 validate_r2 validate_r3 validate_lax}]
    if {$r < 0.30} {
        set stmt [list validate $x $v [pick {stmt stmt bind method}] u[incr counter]]
    } elseif {$r < 0.60} {
        set stmt [list vhandle $x $v [genHandler $strs $bools $x $v] [expr {[chance 0.4] ? "u[incr counter]" : ""}]]
    } elseif {$r < 0.75} {
        set handler [expr {[chance 0.5] ? [genHandler $strs $bools $x $v] : ""}]
        set stmt [list varg $x $v [genTargetLeaf $strs $x $v] $handler [expr {[chance 0.4] ? "w[incr counter]" : ""}]]
    } elseif {$r < 0.85 || !$loops} {
        return [list [list use [genUseLeaf $strs]]]
    } else {
        set body [genValidation $strs $bools counter 0]
        if {[chance 0.5]} {
            lappend body [list use [genUseLeaf $strs]]
        }
        set result [list [list vloop [expr {int(rand() * 3)}] $body]]
        # After the loop: a use of what the body proved (it must not hold).
        set first [lindex $body 0]
        if {[lindex $first 0] in {validate vhandle varg} && [chance 0.6]} {
            lappend result [list use [genTargetLeaf $strs [lindex $first 1] [lindex $first 2]]]
        }
        return $result
    }
    set result [list $stmt]
    if {[chance 0.6]} {
        lappend result [list use [genTargetLeaf $strs $x $v]]
    }
    return $result
}

# The `on Invalid` handler of a handled call of validator X on V: {return
# K}, {fail}, {complete} (the handled call's value: completes with no
# proof), {guard C K} (`if C: return K`, then completes), {use LEAF} (then
# completes; often a leaf needing what the failed call would have proven)
# or {revalidate X V} (another validator call, then completes).
proc genHandler {strs bools x v} {
    set r [expr {rand()}]
    if {$r < 0.2} {
        return [list return [expr {int(rand() * 9)}]]
    }
    if {$r < 0.35} {
        return [list fail]
    }
    if {$r < 0.5} {
        return [list complete]
    }
    if {$r < 0.7} {
        return [list guard [genCond $strs $bools 1] [expr {int(rand() * 9)}]]
    }
    if {$r < 0.85} {
        return [list use [genTargetLeaf $strs $x $v]]
    }
    return [list revalidate [pick {validate_r1 validate_q1 validate_r2 validate_r3 validate_lax}] \
        [expr {[chance 0.5] ? $v : [pickStr $strs]}]]
}

# A block's statements and final expression. NESTED: the block is an if
# branch, a scope of its own, where `a = V` or `b = V` may shadow the
# parameter (once per block: a second would be DUPLICATE). A binding's
# internal id is its spelling, or SPELLING#N for a shadowing one -- the
# oracle and the evaluator work on ids (value identity), the printer
# prints spellings, so a fact keyed by spelling is caught.
proc genBlock {strs bools depth counterVar {nested 0}} {
    upvar 1 $counterVar counter
    set stmts {}
    set n [expr {int(rand() * ($::validating ? 5 : 4))}]
    set shadowed 0
    for {set i 0} {$i < $n} {incr i} {
        if {$::validating && [chance 0.35]} {
            lappend stmts {*}[genValidation $strs $bools counter]
            continue
        }
        set r [expr {rand()}]
        if {$nested && !$shadowed && $r < 0.2} {
            set shadowed 1
            set name [pick {a b}]
            set old [lsearch -all -inline -regexp $strs "^$name\(#|\$\)"]
            set id $name#[incr counter]
            lappend stmts [list alias $id [pick $strs]]
            set strs [concat [lmap x $strs {if {$x in $old} continue; set x}] [list $id]]
        } elseif {$r < 0.2} {
            set t t[incr counter]
            lappend stmts [list alias $t [pick $strs]]
            lappend strs $t
        } elseif {$r < 0.45} {
            set ok ok[incr counter]
            lappend stmts [list bool $ok [genCond $strs $bools 2]]
            lappend bools $ok
        } elseif {$r < 0.75} {
            lappend stmts [list guard [genCond $strs $bools 2] [expr {int(rand() * 9)}]]
        } else {
            lappend stmts [list sif [genCond $strs $bools 2] \
                [genBranch $strs $bools counter] [genBranch $strs $bools counter]]
        }
    }
    return [list $stmts [genExpr $strs $bools $depth counter]]
}

proc genExpr {strs bools depth counterVar} {
    upvar 1 $counterVar counter
    set r [expr {rand()}]
    if {$depth > 0 && $r < 0.45} {
        return [list if [genCond $strs $bools 2] \
            [genBlock $strs $bools [expr {$depth - 1}] counter 1] \
            [genBlock $strs $bools [expr {$depth - 1}] counter 1]]
    }
    if {$r < 0.6} {
        return [list plus [genLeaf $strs] [genLeaf $strs]]
    }
    return [genLeaf $strs]
}

proc genLeaf {strs} {
    if {[chance 0.1]} {
        return [list int [expr {int(rand() * 7)}]]
    }
    return [list leaf [pick {need1 need2 need3 plain}] [pick $strs]]
}

# ---------------------------------------------------------------------------
# Printing

# The spelling of binding id ID.
proc spell {id} { return [regsub {#[0-9]+$} $id ""] }

proc condText {c} {
    switch -- [lindex $c 0] {
        call { return "[lindex $c 1]([spell [lindex $c 2]])" }
        ref  { return [lindex $c 1] }
        not  { return "not ([condText [lindex $c 1]])" }
        and - or { return "([condText [lindex $c 1]]) [lindex $c 0] ([condText [lindex $c 2]])" }
    }
}

proc stmtLines {stmts indent} {
    set pad [string repeat "    " $indent]
    set lines {}
    foreach s $stmts {
        switch -- [lindex $s 0] {
            alias { lappend lines "$pad[spell [lindex $s 1]] = [spell [lindex $s 2]]" }
            bool  { lappend lines "$pad[lindex $s 1] = [condText [lindex $s 2]]" }
            guard {
                lappend lines "${pad}if [condText [lindex $s 1]]:" "$pad    return [lindex $s 2]"
            }
            sif {
                lappend lines "${pad}if [condText [lindex $s 1]]:" \
                    {*}[stmtLines [lindex $s 2] [expr {$indent + 1}]] "${pad}else:" \
                    {*}[stmtLines [lindex $s 3] [expr {$indent + 1}]]
            }
            validate {
                lassign $s - x v form name
                switch -- $form {
                    stmt   { lappend lines "$pad$x\([spell $v])" }
                    bind   { lappend lines "$pad$name = $x\([spell $v])" }
                    method { lappend lines "$pad[spell $v].$x\()" }
                }
            }
            vhandle {
                lassign $s - x v handler name
                set head [expr {$name eq "" ? "" : "$name = "}]
                lappend lines "$pad$head$x\([spell $v]):" "$pad    on Invalid:" \
                    {*}[handlerLines $handler unit [expr {$indent + 2}]]
            }
            varg {
                lassign $s - x v leaf handler name
                set head [expr {$name eq "" ? "" : "$name = "}]
                set call "pair($x\([spell $v]), [leafText $leaf])"
                if {$handler eq ""} {
                    lappend lines "$pad$head$call"
                } else {
                    lappend lines "$pad$head$call:" "$pad    on Invalid:" \
                        {*}[handlerLines $handler 0 [expr {$indent + 2}]]
                }
            }
            use {
                lappend lines "$pad[leafText [lindex $s 1]]"
            }
            vloop {
                lappend lines "${pad}loop i from 0 to [lindex $s 1]:" {*}[stmtLines [lindex $s 2] [expr {$indent + 1}]]
            }
        }
    }
    return $lines
}

# The lines of handler H, completing (where it does) with VALUE.
proc handlerLines {h value indent} {
    set pad [string repeat "    " $indent]
    switch -- [lindex $h 0] {
        return     { return [list "${pad}return [lindex $h 1]"] }
        fail       { return [list "${pad}fail Invalid"] }
        complete   { return [list "$pad$value"] }
        guard      { return [list "${pad}if [condText [lindex $h 1]]:" "$pad    return [lindex $h 2]" "$pad$value"] }
        use        { return [list "$pad[leafText [lindex $h 1]]" "$pad$value"] }
        revalidate { return [list "$pad[lindex $h 1]([spell [lindex $h 2]])" "$pad$value"] }
    }
}

proc blockLines {block indent} {
    lassign $block stmts e
    return [concat [stmtLines $stmts $indent] [exprLines $e $indent]]
}

proc exprLines {e indent} {
    set pad [string repeat "    " $indent]
    if {[lindex $e 0] eq "if"} {
        return [concat [list "${pad}if [condText [lindex $e 1]]:"] [blockLines [lindex $e 2] [expr {$indent + 1}]] \
            [list "${pad}else:"] [blockLines [lindex $e 3] [expr {$indent + 1}]]]
    }
    return [list "$pad[leafText $e]"]
}

proc leafText {e} {
    switch -- [lindex $e 0] {
        int  { return [lindex $e 1] }
        leaf { return "[lindex $e 1]([spell [lindex $e 2]])" }
        plus { return "[leafText [lindex $e 1]] + [leafText [lindex $e 2]]" }
    }
}

proc programText {body} {
    global prelude inputs validating
    if {!$validating} {
        set calls [lmap pair $inputs {format {f("%s", "%s")} {*}$pair}]
        return "${prelude}fn f(a: str, b: str) -> int:\n[join [blockLines $body 1] \n]\n\n\[[join $calls {, }]\]\n"
    }
    # A validator's Invalid may escape f; g turns it into -1.
    set calls [lmap pair $inputs {format {g("%s", "%s")} {*}$pair}]
    return "${prelude}fn f(a: str, b: str) -> int errors Invalid:\n[join [blockLines $body 1] \n]\n\nfn g(a: str, b: str) -> int:\n    r = f(a, b):\n        on Invalid:\n            -1\n    r\n\n\[[join $calls {, }]\]\n"
}

# ---------------------------------------------------------------------------
# The oracle: static facts. State ST: F (facts: {b NAME} -> sorted list of
# the refinements proven of NAME's value, {c PRED ROOT} -> 0|1: the result of
# PRED on the value ROOT names), roots (NAME -> the parameter or alias root
# whose value it holds), implies (okN -> its implication), reach (the
# current point is reachable), rejects, decided (the `known` of each
# predicate call, in source order).
#
# An implication is {1 SET 0 SET}: a SET is a fact dict like F, or `never`.

proc rootOf {stVar v} {
    upvar 1 $stVar st
    return [expr {[dict exists $st roots $v] ? [dict get $st roots $v] : $v}]
}

proc factsOf {F v} {
    return [expr {[dict exists $F [list b $v]] ? [dict get $F [list b $v]] : {}}]
}

# Every fact of A and of B (neither never).
proc union {a b} {
    set r $a
    dict for {k v} $b {
        if {[lindex $k 0] eq "b" && [dict exists $r $k]} {
            dict set r $k [lsort -unique [concat [dict get $r $k] $v]]
        } else {
            dict set r $k $v
        }
    }
    return $r
}

# The facts true in both A and B (neither never): the refinements both prove
# of a value, a predicate result both agree on.
proc meet {a b} {
    set r [dict create]
    dict for {k v} $a {
        if {![dict exists $b $k]} continue
        set w [dict get $b $k]
        if {[lindex $k 0] eq "c"} {
            if {$v eq $w} { dict set r $k $v }
        } else {
            set i [lmap x $v {if {$x in $w} {set x} else continue}]
            if {$i ne {}} { dict set r $k $i }
        }
    }
    return $r
}

proc meetAll {list} {
    if {$list eq {}} { return never }
    set r [lindex $list 0]
    foreach x [lrange $list 1 end] { set r [meet $r $x] }
    return $r
}

proc applyFacts {stVar I} {
    upvar 1 $stVar st
    dict set st F [union [dict get $st F] $I]
}

# A constant Boolean's implication: the other outcome cannot happen.
proc constImp {b} { return [expr {$b ? {1 {} 0 never} : {1 never 0 {}}}] }

# Types condition C in ST (not/and/or are their if-expression lowerings,
# whose join changes ST's facts like any if); returns {IMPLICATION KNOWN},
# KNOWN the decided outcome of C itself ("" unless C is a decided call).
proc cond {stVar c} {
    upvar 1 $stVar st
    global preds closure
    switch -- [lindex $c 0] {
        call {
            lassign $c - p v
            lassign [dict get $preds $p] proven required repeatable
            if {$required ne {} && $required ni [factsOf [dict get $st F] $v]} {
                dict lappend st rejects "$p\($v) needs $required"
            }
            set root [rootOf st $v]
            set key [list c $p $root]
            set known ""
            if {$repeatable && [dict exists $st F $key]} {
                set known [dict get $st F $key]
            }
            dict lappend st decided $known
            set proof [dict get $closure $proven]
            set imp [dict create \
                1 [dict create [list b $v] $proof [list b $root] $proof $key 1] \
                0 [dict create $key 0]]
            # The result fact is recorded for every predicate (a later call
            # of a non-repeatable one is still made: the decision, above, is
            # what asks).
            if {$known eq "1"} { dict set imp 0 never }
            if {$known eq "0"} { dict set imp 1 never }
            return [list $imp $known]
        }
        ref {
            set ok [lindex $c 1]
            return [list [dict get $st implies $ok] ""]
        }
        not { return [list [lowerIf st [lindex $c 1] {const 0} {const 1}] ""] }
        and { return [list [lowerIf st [lindex $c 1] [list cond [lindex $c 2]] {const 0}] ""] }
        or  { return [list [lowerIf st [lindex $c 1] {const 1} [list cond [lindex $c 2]]] ""] }
    }
}

# The Boolean if-expression `if C: THEN else: ELSE`, each branch {const B}
# or {cond C2}; returns its implication: for each outcome, the facts true on
# every path producing it (the branch's entry facts with its value's).
# Leaves ST's facts at the if's join.
proc lowerIf {stVar c then else} {
    upvar 1 $stVar st
    lassign [cond st $c] I known
    set entryF [dict get $st F]
    set entryReach [dict get $st reach]
    set ends {}
    set values [dict create]
    foreach {b branch} [list 1 $then 0 $else] {
        dict set st F $entryF
        set reach [expr {$entryReach && ($known eq "" || $known == $b)}]
        dict set st reach $reach
        if {[dict get $I $b] ne "never"} {
            applyFacts st [dict get $I $b]
        }
        if {[lindex $branch 0] eq "const"} {
            set v [constImp [lindex $branch 1]]
        } else {
            lassign [cond st [lindex $branch 1]] v
        }
        if {$reach} {
            lappend ends [dict get $st F]
        }
        dict set values $b $v
    }
    dict set st reach $entryReach
    dict set st F [expr {$ends eq {} ? $entryF : [meetAll $ends]}]
    set result [dict create]
    foreach o {1 0} {
        set paths {}
        foreach b {1 0} {
            set entry [dict get $I $b]
            set v [dict get $values $b $o]
            if {$entry eq "never" || $v eq "never"} continue
            lappend paths [union $entry $v]
        }
        dict set result $o [meetAll $paths]
    }
    return $result
}

proc stmts {stVar list} {
    upvar 1 $stVar st
    foreach s $list {
        switch -- [lindex $s 0] {
            alias {
                lassign $s - t v
                dict set st F [list b $t] [factsOf [dict get $st F] $v]
                dict set st roots $t [rootOf st $v]
            }
            bool {
                lassign $s - ok c
                lassign [cond st $c] imp
                dict set st implies $ok $imp
            }
            guard {
                # `if C: return K`: only the false outcome continues.
                lassign $s - c
                lassign [cond st $c] I known
                if {[dict get $st reach] && ($known eq "" || $known == 0)} {
                    if {[dict get $I 0] ne "never"} { applyFacts st [dict get $I 0] }
                } else {
                    dict set st reach 0
                }
            }
            sif {
                lassign $s - c thenStmts elseStmts
                lassign [cond st $c] I known
                set entryF [dict get $st F]
                set entryReach [dict get $st reach]
                set ends {}
                foreach {b branch} [list 1 $thenStmts 0 $elseStmts] {
                    dict set st F $entryF
                    dict set st reach [expr {$entryReach && ($known eq "" || $known == $b)}]
                    if {[dict get $I $b] ne "never"} { applyFacts st [dict get $I $b] }
                    stmts st $branch
                    if {[dict get $st reach]} {
                        lappend ends [dict get $st F]
                    }
                }
                dict set st F [expr {$ends eq {} ? $entryF : [meetAll $ends]}]
                dict set st reach $entryReach
                if {$ends eq {}} {
                    dict set st reach 0
                }
            }
            validate {
                # A normal completion proves: the rest of the path has it.
                lassign $s - x v
                applyFacts st [vcall st $x $v]
            }
            vhandle {
                lassign $s - x v h
                set entryF [dict get $st F]
                set proof [vcall st $x $v]
                handled st $entryF [union $entryF $proof] $h
            }
            varg {
                # The validator argument completes before the leaf
                # argument is evaluated; a handler runs instead of the
                # whole call, so it starts from the facts before it.
                lassign $s - x v leaf h
                set entryF [dict get $st F]
                applyFacts st [vcall st $x $v]
                useLeaf st $leaf
                if {$h ne ""} {
                    handled st $entryF [dict get $st F] $h
                }
            }
            use {
                useLeaf st [lindex $s 1]
            }
            vloop {
                # The body's facts are the body's: none survive the loop.
                set entryF [dict get $st F]
                set entryReach [dict get $st reach]
                stmts st [lindex $s 2]
                dict set st F $entryF
                dict set st reach $entryReach
            }
        }
    }
}

# A call of validator X on V: checks what X requires of V, records the call
# (never decided) and returns the facts its normal completion proves.
proc vcall {stVar x v} {
    upvar 1 $stVar st
    global validators closure
    lassign [dict get $validators $x] proven required
    if {$required ne {} && $required ni [factsOf [dict get $st F] $v]} {
        dict lappend st rejects "$x\($v) needs $required"
    }
    dict lappend st decided ""
    dict incr st vcalls
    set proof [dict get $closure $proven]
    return [dict create [list b $v] $proof [list b [rootOf st $v]] $proof]
}

# Checks leaf E's argument.
proc useLeaf {stVar e} {
    upvar 1 $stVar st
    lassign $e - fn v
    set need [dict get {need1 R1 need2 R2 need3 R3 plain {}} $fn]
    # Checked whether or not the leaf is reachable: dead code is type-checked
    # too.
    if {$need ne {} && $need ni [factsOf [dict get $st F] $v]} {
        dict lappend st rejects "$fn\($v) needs $need"
    }
}

# The facts after a handled call: those on its normal completion (NORMAL)
# met with those at the end of handler H when H completes, H starting from
# ENTRY, the facts before the handled call.
proc handled {stVar entry normal h} {
    upvar 1 $stVar st
    set entryReach [dict get $st reach]
    set ends [list $normal]
    dict set st F $entry
    if {[handlerRun st $h]} {
        lappend ends [dict get $st F]
    }
    dict set st F [meetAll $ends]
    dict set st reach $entryReach
}

# Runs handler H in ST; returns whether it can complete normally (a guard
# decided true always returns).
proc handlerRun {stVar h} {
    upvar 1 $stVar st
    switch -- [lindex $h 0] {
        return - fail { return 0 }
        complete { return 1 }
        guard {
            lassign [cond st [lindex $h 1]] I known
            if {[dict get $st reach] && ($known eq "" || $known == 0) && [dict get $I 0] ne "never"} {
                applyFacts st [dict get $I 0]
            }
            return [expr {$known ne "1"}]
        }
        use {
            useLeaf st [lindex $h 1]
            return 1
        }
        revalidate {
            applyFacts st [vcall st [lindex $h 1] [lindex $h 2]]
            return 1
        }
    }
}

proc block {stVar blk} {
    upvar 1 $stVar st
    lassign $blk list e
    stmts st $list
    oracleExpr st $e
}

proc oracleExpr {stVar e} {
    upvar 1 $stVar st
    switch -- [lindex $e 0] {
        if {
            lassign $e - c thenBlk elseBlk
            lassign [cond st $c] I known
            set entryF [dict get $st F]
            set entryReach [dict get $st reach]
            foreach {b blk} [list 1 $thenBlk 0 $elseBlk] {
                dict set st F $entryF
                dict set st reach [expr {$entryReach && ($known eq "" || $known == $b)}]
                if {[dict get $I $b] ne "never"} { applyFacts st [dict get $I $b] }
                block st $blk
            }
            dict set st F $entryF
            dict set st reach $entryReach
        }
        plus {
            oracleExpr st [lindex $e 1]
            oracleExpr st [lindex $e 2]
        }
        int {}
        leaf {
            useLeaf st $e
        }
    }
}

# {REJECTS DECIDED VCALLS} for program body BODY: VCALLS validator calls.
proc oracle {body} {
    set st [dict create F {} roots {} implies {} reach 1 rejects {} decided {} vcalls 0]
    block st $body
    return [list [dict get $st rejects] [dict get $st decided] [dict get $st vcalls]]
}

# ---------------------------------------------------------------------------
# The concrete evaluator: the value of f(A, B).

proc truth {env c} {
    global preds
    switch -- [lindex $c 0] {
        call {
            set n [string length [dict get $env [lindex $c 2]]]
            return [eval [lindex [dict get $preds [lindex $c 1]] 3]]
        }
        ref { return [dict get $env [lindex $c 1]] }
        not { return [expr {![truth $env [lindex $c 1]]}] }
        and { return [expr {[truth $env [lindex $c 1]] && [truth $env [lindex $c 2]]}] }
        or  { return [expr {[truth $env [lindex $c 1]] || [truth $env [lindex $c 2]]}] }
    }
}

# Runs statements LIST in ENV (upvar); a guard that fires throws {FUZZ
# RETURN K}.
proc runStmts {envVar list} {
    upvar 1 $envVar env
    foreach s $list {
        switch -- [lindex $s 0] {
            alias { dict set env [lindex $s 1] [dict get $env [lindex $s 2]] }
            bool  { dict set env [lindex $s 1] [truth $env [lindex $s 2]] }
            guard {
                if {[truth $env [lindex $s 1]]} {
                    throw [list FUZZ RETURN [lindex $s 2]] return
                }
            }
            sif {
                set inner $env
                runStmts inner [lindex $s [expr {[truth $env [lindex $s 1]] ? 2 : 3}]]
            }
            validate {
                if {[fails $env [lindex $s 1] [lindex $s 2]]} {
                    throw {FUZZ FAIL} fail
                }
            }
            vhandle {
                if {[fails $env [lindex $s 1] [lindex $s 2]]} {
                    runHandler $env [lindex $s 3]
                }
            }
            varg {
                if {[fails $env [lindex $s 1] [lindex $s 2]]} {
                    if {[lindex $s 4] eq ""} {
                        throw {FUZZ FAIL} fail
                    }
                    runHandler $env [lindex $s 4]
                }
            }
            use {}
            vloop {
                for {set k 0} {$k < [lindex $s 1]} {incr k} {
                    set inner $env
                    runStmts inner [lindex $s 2]
                }
            }
        }
    }
}

# 1 if validator X fails on the value of V in ENV.
proc fails {env x v} {
    global validators
    set n [string length [dict get $env $v]]
    return [eval [lindex [dict get $validators $x] 2]]
}

# Runs handler H in ENV: a return throws {FUZZ RETURN K}, an escaping
# Invalid {FUZZ FAIL}.
proc runHandler {env h} {
    switch -- [lindex $h 0] {
        return { throw [list FUZZ RETURN [lindex $h 1]] return }
        fail { throw {FUZZ FAIL} fail }
        guard {
            if {[truth $env [lindex $h 1]]} {
                throw [list FUZZ RETURN [lindex $h 2]] return
            }
        }
        revalidate {
            if {[fails $env [lindex $h 1] [lindex $h 2]]} {
                throw {FUZZ FAIL} fail
            }
        }
    }
}

proc runBlock {env blk} {
    runStmts env [lindex $blk 0]
    return [runExpr $env [lindex $blk 1]]
}

proc runExpr {env e} {
    switch -- [lindex $e 0] {
        if   { return [runBlock $env [lindex $e [expr {[truth $env [lindex $e 1]] ? 2 : 3}]]] }
        plus { return [expr {[runExpr $env [lindex $e 1]] + [runExpr $env [lindex $e 2]]}] }
        int  { return [lindex $e 1] }
        leaf {
            set n [string length [dict get $env [lindex $e 2]]]
            return [dict get [dict create need1 $n need2 [expr {10 * $n}] need3 [expr {100 * $n}] plain 1000] [lindex $e 1]]
        }
    }
}

proc concrete {body} {
    global inputs
    set values {}
    foreach pair $inputs {
        try {
            lappend values [runBlock [dict create a [lindex $pair 0] b [lindex $pair 1]] $body]
        } trap {FUZZ RETURN} {- options} {
            lappend values [lindex [dict get $options -errorcode] 2]
        } trap {FUZZ FAIL} {} {
            # Invalid escaped f: g's handler.
            lappend values -1
        }
    }
    return "\[[join $values {, }]\]"
}

# ---------------------------------------------------------------------------
# The compiler side.

# The `known` of every predicate and validator call in HIR, in pre-order
# (source order).
proc compilerDecided {hir} {
    global preds validators
    return [lmap e [hir::walk $hir] {
        if {[hir::kind $hir $e] ne "call"} continue
        set callee [hir::get $hir $e callee]
        if {[hir::kind $hir $callee] ne "ref"} continue
        set name [hir::get $hir $callee name]
        if {![dict exists $preds $name] && ![dict exists $validators $name]} continue
        hir::get $hir $e known
    }]
}

proc outcome {backend hir} {
    if {[catch {
        switch -- $backend {
            interp - compile {
                core::useBackend $backend
                set r [core::evalProgram [hir::lower $hir]]
            }
            cranelift { set r [native::evalHir $hir] }
            cranelift-generic { set r [native::evalHir $hir -specialize 0] }
        }
    } message options]} {
        return [list error [dict get $options -errorcode] $message]
    }
    return [list value [core::value::show $r 1]]
}

# ---------------------------------------------------------------------------
# Driver

set stats [dict create programs 0 accepted 0 rejected 0 calls 0 decided 0 vcalls 0 failures 0]
set failures {}
for {set i 0} {$i < [dict get $options -count]} {incr i} {
    # With probability -accept, draw until the oracle accepts (most random
    # bodies use a refinement nothing proved). With validators, most of the
    # other programs are drawn until the oracle rejects exactly one use: a
    # compiler that proves too much (a handler seeing the failed call's
    # proof, a join keeping a fact one path lacks) accepts exactly those.
    set wantAccept [chance [dict get $options -accept]]
    set wantSingle [expr {!$wantAccept && $validating && [chance 0.7]}]
    for {set try 0} {$try < 500} {incr try} {
        set counter 0
        set body [genBlock {a b} {} 2 counter]
        lassign [oracle $body] rejects decided vcalls
        if {$wantSingle ? [llength $rejects] == 1 : (!$wantAccept || $rejects eq {})} break
    }
    set text [programText $body]
    dict incr stats programs
    if {$rejects eq {} && (([dict get $options -show] == 1 && [llength [lsearch -all -not -exact $decided ""]] > 0)
            || ([dict get $options -show] == 2 && $vcalls > 0))} {
        puts "---- program $i (decided: $decided)\n$text"
    }
    set problem ""
    if {[catch {surface::compile $text fuzz.bot -warnings off} hir compileOptions]} {
        set code [dict get $compileOptions -errorcode]
        if {$rejects eq {}} {
            set problem "rejected ($code): $hir"
        } elseif {[lindex $code end] ne "TYPE"} {
            set problem "rejected with $code (expected TYPE: $rejects): $hir"
        } else {
            dict incr stats rejected
        }
    } elseif {$rejects ne {}} {
        set problem "accepted, but the oracle rejects: $rejects"
    } else {
        dict incr stats accepted
        set got [compilerDecided $hir]
        dict incr stats calls [expr {[llength $decided] - $vcalls}]
        dict incr stats vcalls $vcalls
        dict incr stats decided [llength [lsearch -all -not -exact $decided ""]]
        if {$got ne $decided} {
            set problem "decided calls: compiler {$got}, oracle {$decided}"
        } else {
            set expected [list value [concrete $body]]
            foreach backend [dict get $options -backends] {
                set result [outcome $backend $hir]
                if {$result ne $expected} {
                    set problem "$backend: $result, expected $expected"
                    break
                }
            }
        }
    }
    if {$problem ne ""} {
        dict incr stats failures
        lappend failures [list $i $problem $text]
    }
}

foreach failure $failures {
    lassign $failure i problem text
    puts "FAIL program $i: $problem"
    if {[dict get $options -v]} {
        puts $text
    }
}
set validatorCalls [expr {$validating ? ", [dict get $stats vcalls] validator calls (never decided)" : ""}]
puts "seed [dict get $options -seed]: [dict get $stats programs] programs, [dict get $stats accepted] accepted, [dict get $stats rejected] rejected, [dict get $stats calls] predicate calls in accepted programs ([dict get $stats decided] decided)$validatorCalls, [dict get $stats failures] failures"
exit [expr {[dict get $stats failures] > 0}]
