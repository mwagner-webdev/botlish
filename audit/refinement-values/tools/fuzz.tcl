# fuzz.tcl -- differential fuzzer for refinement values (REFINEMENT-VALUES.md).
#
#   tclsh9.0 audit/refinement-values/tools/fuzz.tcl ?-seed N? ?-count N? ?-backends LIST? ?-accept P? ?-v 1? ?-show 1?
#
# -accept P: the share of programs drawn (by retrying) until the oracle
# accepts them; the rest are taken as generated, mostly rejections.
# -show 1 prints every accepted program with a decided call.
#
# Generates random programs over a fixed set of refinements and proof-
# producing predicates -- two sibling refinements of str (R1, R2), a
# refinement of a refinement (R3 = R1), two different predicates proving R1
# (p1?, q1?), one proving R2 (p2?), one proving R3 from an R1 (p3?), and a
# predicate proving R1 that is NOT repeatable (n1?: it hashes) -- and a
# random function body of: plain values and immutable aliases, Boolean
# bindings of conditions, guards with early returns, statement-level ifs
# whose branches only bind (so facts must survive the join), nested
# if-expressions, and leaves that need R1/R2/R3 or only str. Conditions are
# predicate calls, Boolean bindings, not, and, or.
#
# An independent oracle (this file; it shares no code with the compiler)
# models what the language says:
#
#   * carrier and nominal refinement facts per binding (a closure: R3
#     implies R1), established by a true proof and attached to the value --
#     the argument's binding and the binding it aliases, never a spelling;
#   * exact predicate-result facts, keyed by predicate and value identity
#     (the alias root), decided only for repeatable predicates;
#   * control flow: each outcome's facts of not/and/or (their lowering to
#     if-expressions), Boolean bindings carrying their implication, and the
#     join of a statement if: facts true at the end of every reachable
#     branch that completes;
#   * acceptance: every leaf's argument proven what its parameter requires
#     (reachable or not: the compiler type-checks dead code too);
#   * the value of the program, evaluated concretely.
#
# Each program is compiled once. A predicted rejection must be a compile-time
# TYPE error; a predicted acceptance must compile, run to the oracle's value
# on every backend, and decide exactly the predicate calls the oracle
# decides (the HIR `known` field of each predicate call, in order).

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 200000

set options [dict create -seed 1 -count 200 -backends {interp compile cranelift-generic cranelift} -accept 0.7 -v 0 -show 0]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}
expr {srand([dict get $options -seed])}

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
    100 * str::length(x)

fn plain(x: str) -> int:
    1000

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
    lappend stmts [list alias t[incr counter] [pick $strs]]
    return $stmts
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
    set n [expr {int(rand() * 4)}]
    set shadowed 0
    for {set i 0} {$i < $n} {incr i} {
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
        }
    }
    return $lines
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
    global prelude inputs
    set calls [lmap pair $inputs {format {f("%s", "%s")} {*}$pair}]
    return "${prelude}fn f(a: str, b: str) -> int:\n[join [blockLines $body 1] \n]\n\n\[[join $calls {, }]\]\n"
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
            lassign $e - fn v
            set need [dict get {need1 R1 need2 R2 need3 R3 plain {}} $fn]
            # Checked whether or not the leaf is reachable: dead code is
            # type-checked too.
            if {$need ne {} && $need ni [factsOf [dict get $st F] $v]} {
                dict lappend st rejects "$fn\($v) needs $need"
            }
        }
    }
}

# {REJECTS DECIDED} for program body BODY.
proc oracle {body} {
    set st [dict create F {} roots {} implies {} reach 1 rejects {} decided {}]
    block st $body
    return [list [dict get $st rejects] [dict get $st decided]]
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
        }
    }
    return "\[[join $values {, }]\]"
}

# ---------------------------------------------------------------------------
# The compiler side.

# The `known` of every predicate call in HIR, in pre-order (source order).
proc compilerDecided {hir} {
    global preds
    return [lmap e [hir::walk $hir] {
        if {[hir::kind $hir $e] ne "call"} continue
        set callee [hir::get $hir $e callee]
        if {[hir::kind $hir $callee] ne "ref" || ![dict exists $preds [hir::get $hir $callee name]]} continue
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

set stats [dict create programs 0 accepted 0 rejected 0 calls 0 decided 0 failures 0]
set failures {}
for {set i 0} {$i < [dict get $options -count]} {incr i} {
    # With probability -accept, draw until the oracle accepts (most random
    # bodies use a refinement nothing proved).
    set wantAccept [chance [dict get $options -accept]]
    for {set try 0} {$try < 500} {incr try} {
        set counter 0
        set body [genBlock {a b} {} 2 counter]
        lassign [oracle $body] rejects decided
        if {!$wantAccept || $rejects eq {}} break
    }
    set text [programText $body]
    dict incr stats programs
    if {[dict get $options -show] && [llength [lsearch -all -not -exact $decided ""]] > 0 && $rejects eq {}} {
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
        dict incr stats calls [llength $decided]
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
puts "seed [dict get $options -seed]: [dict get $stats programs] programs, [dict get $stats accepted] accepted, [dict get $stats rejected] rejected, [dict get $stats calls] predicate calls in accepted programs ([dict get $stats decided] decided), [dict get $stats failures] failures"
exit [expr {[dict get $stats failures] > 0}]
