# structure.tcl -- a structural audit of emission claims for
# EMISSION-IDENTITY-AND-FEASIBILITY-CORRECTNESS-MILESTONE-1.md: generated
# programs of the shapes the earlier fuzzers never made (their functions all
# took parameters and had names of their own,
# EMISSION-BINDING-AND-SIGNATURE-DEPENDENCY-CENSUS-MILESTONE-1.md, section
# 1), each claim checked by the compiler and every run of it judged.
#
#   tclsh9.0 audit/emission-identity/tools/structure.tcl ?-seeds 1-40?
#       ?-root DIR? ?-out FILE? ?-keep DIR?
#
# Each seed writes one program:
#
#   * functions at the top level and nested in two or three outer
#     functions, drawn from a small pool of names (helpers `h`, `g`; claimed
#     emitters `e`, `f`), so one name is often bound by several functions in
#     different lexical scopes, a nested one shadowing a top-level one, and
#     a helper of one scope calling a top-level helper of the same name as a
#     helper of another;
#   * claimed emitters with zero, one or two parameters (of `Bit`, Int in
#     0..1), helpers with zero or one; most bodies begin with an `if` before
#     any binding (an empty environment), conditions known (`true`,
#     `false`), unknown (`s1()`, `not s2()`: switches), nested, or on a
#     parameter, a binding before some of them;
#   * each emitter claims one of two recognizers (one digit; a digit then a
#     letter), its yields drawn from two digits and two letters, its calls
#     to helpers with and without claims of their own.
#
# Then, for every assignment of the switches (each `sN()`'s constant body),
# the program is compiled with a fresh memo (the verdicts), with the memo
# off, and -- the memo kept -- after the other assignments' programs and
# after an edited version of itself (one helper's first symbol changed):
# every verdict must be the same (history
# independence). The program with its claims erased runs every claimed
# emitter for every argument tuple, inside its own scope (a nested emitter
# is called where it is visible), on the Tcl compiler; the reference
# interpreter (tests/dfa-support.tcl) judges each trace.
#
#   false certificate   a certified claim with an invalid run (exit 1)
#   history differs     a verdict that depends on what the process compiled
#                       before, or on the memo being on (exit 1)
#   rejected, confirmed rejected and some run of some assignment is invalid
#   precision loss      not certified and every run valid
#
# -root DIR loads the compiler from another checkout (the tree before the
# milestone, to see what the audit finds there).

set here [file dirname [file normalize [info script]]]
set options [dict merge [list -seeds 1-40 -root [file dirname [file dirname [file dirname $here]]] -out "" -keep ""] $argv]
set argv {}
set root [dict get $options -root]
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
source [file join $root tests emission-support.tcl]
interp recursionlimit {} 100000
core::useProgramRecursionLimit

namespace eval gen {
    variable rng 1
    variable bound 0
    variable fault 0
    variable symbols {49 50 65 66}
    variable limit 10
}

proc gen::Rand {n} {
    variable rng
    set rng [expr {($rng * 1103515245 + 12345) % 2147483648}]
    return [expr {($rng >> 8) % $n}]
}

proc gen::Pick {list} {
    return [lindex $list [Rand [llength $list]]]
}

proc gen::Chance {percent} {
    return [expr {[Rand 100] < $percent}]
}

proc gen::Indent {lines {by "    "}} {
    return [lmap l $lines {string cat $by $l}]
}

# A condition: known, a switch, or on a parameter of PARAMS.
proc gen::Cond {params} {
    set choices {true false s1() s2() {not s1()} {not s2()}}
    foreach p $params {
        lappend choices "$p == 0" "$p > 0"
    }
    return [Pick $choices]
}

# The lines of a part of kind KIND -- D one digit, L one letter, DL a digit
# then a letter, N no symbol -- on every path; CALLABLE the helpers visible
# here ({NAME ARITY KIND}...), PARAMS the parameters, DEPTH the nesting. A
# pending fault (gen::fault) makes one leaf of the part wrong: a symbol of
# the other class, a helper of another kind, an `if` without its `else`, a
# symbol too many.
proc gen::Part {kind callable params depth} {
    variable fault
    variable bound
    set lines {}
    if {$kind eq "DL"} {
        set roll [Rand 100]
        set fitting [lsearch -all -inline -index 2 $callable DL]
        if {$roll < 25 && $depth < 2} {
            lappend lines "if [Cond $params]:" {*}[Indent [Part DL $callable $params [expr {$depth + 1}]]] \
                "else:" {*}[Indent [Part DL $callable $params [expr {$depth + 1}]]]
        } elseif {$roll < 40 && $fitting ne {} && !$fault} {
            lappend lines [Call [Pick $fitting] $params]
        } else {
            lappend lines {*}[Part D $callable $params $depth] {*}[Part L $callable $params $depth]
        }
        return $lines
    }
    if {$kind eq "N"} {
        switch [Rand 3] {
            0 { lappend lines "v[incr bound] = [Pick {0 1}]" }
            1 { lappend lines "if [Cond $params]:" "    v[incr bound] = 1" }
            2 {
                set fitting [lsearch -all -inline -index 2 $callable N]
                if {$fitting ne {}} {
                    lappend lines [Call [Pick $fitting] $params]
                } else {
                    lappend lines "v[incr bound] = 0"
                }
            }
        }
        return $lines
    }
    # D or L.
    set other [dict get {D L L D} $kind]
    set roll [Rand 100]
    if {$roll < 15} {
        lappend lines {*}[Part N $callable $params $depth]
    }
    set roll [Rand 100]
    if {$roll < 35 && $depth < 2} {
        lappend lines "if [Cond $params]:" {*}[Indent [Part $kind $callable $params [expr {$depth + 1}]]]
        if {$fault && [Chance 30]} {
            set fault 0
        } else {
            lappend lines "else:" {*}[Indent [Part $kind $callable $params [expr {$depth + 1}]]]
        }
        return $lines
    }
    set want $kind
    if {$fault && [Chance 60]} {
        set fault 0
        if {[Chance 25]} {
            lappend lines [Yield $kind]
        }
        set want $other
    }
    set fitting [lsearch -all -inline -index 2 $callable $want]
    if {$roll < 65 && $fitting ne {}} {
        lappend lines [Call [Pick $fitting] $params]
    } else {
        lappend lines [Yield $want]
    }
    return $lines
}

proc gen::Yield {kind} {
    if {$kind eq "D"} {
        return "yield [Pick {49 50}]"
    }
    return "yield [Pick {65 66}]"
}

# A call of helper HELPER ({NAME ARITY KIND}), its argument a constant or a
# parameter of PARAMS.
proc gen::Call {helper params} {
    lassign $helper name arity
    set args {}
    for {set k 0} {$k < $arity} {incr k} {
        lappend args [Pick [concat 0 1 $params]]
    }
    return "$name\([join $args {, }])"
}

# A function declaration: {LINES CLAIM KIND}, CLAIM {NAME RECOGNIZER ARITY}
# for a claimed emitter (else ""), KIND what a helper emits.
proc gen::Function {name callable claimed} {
    variable fault
    # Inside its body a function's own name is the function itself.
    set callable [lsearch -all -inline -not -index 0 $callable $name]
    set arity [Rand [expr {$claimed ? 3 : 2}]]
    if {$claimed && [Chance 35]} {
        set arity 0
    }
    set params [lrange {b0 b1} 0 [expr {$arity - 1}]]
    # A claimed emitter's parameters are Bits (every tuple is run); a
    # helper's are Ints: a domain admission in code an `if false:` makes
    # unreachable is rejected (its argument's facts are unknown there, a
    # front-end imprecision outside this audit), and a helper may be called
    # in one.
    set type [expr {$claimed ? "Bit" : "int"}]
    set head "fn $name\([join [lmap p $params {string cat $p ": " $type}] {, }])"
    if {$claimed} {
        set r [Pick {digit_token digit_token pair_token}]
        set kind [dict get {digit_token D pair_token DL} $r]
        set fault [Chance 35]
        set body [Part $kind $callable $params 0]
        if {$fault} {
            # A symbol too many, after the token.
            lappend body [Yield [Pick {D L}]]
            set fault 0
        }
        return [list [list "$head -> int emits $r:" {*}[Indent $body] "    0"] [list $name $r $arity] $kind]
    }
    set kind [Pick {D D L N DL}]
    set fault 0
    set body [Part $kind $callable $params 0]
    set claim ""
    if {$kind in {D DL} && [Chance 50]} {
        # A helper with a claim of its own: callers compose with it.
        set claim " emits [dict get {D digit_token DL pair_token} $kind]"
    }
    return [list [list "$head -> unit$claim:" {*}[Indent $body] "    unit"] "" $kind]
}

# The driver of claimed emitter CLAIM in its scope (indented by INDENT): a
# source and a collector, unique names; the expression of its traces.
proc gen::Driver {claim tag} {
    variable limit
    lassign $claim name r arity
    set params [lrange {a0 a1} 0 [expr {$arity - 1}]]
    set typed [join [lmap p $params {string cat $p ": Bit"}] {, }]
    set lines [list "fn src_$tag\($typed) -> int:" "    $name\([join $params {, }])" "    -1" \
        "fn trace_$tag\($typed) -> List\[int\]:" "    coroutine {step, first} = src_$tag\([join $params {, }])" \
        "    loop k from 0 to $limit:" "        if k == 0:" "            first" \
        "        elif std::coroutine::done?(step):" "            -9" "        else:" "            step()"]
    set calls {}
    foreach tuple [Tuples $arity] {
        lappend calls "trace_$tag\([join $tuple {, }])"
    }
    return [list $lines $calls]
}

proc gen::Tuples {arity} {
    set out {{}}
    for {set i 0} {$i < $arity} {incr i} {
        set next {}
        foreach t $out {
            lappend next [concat $t 0] [concat $t 1]
        }
        set out $next
    }
    return $out
}

# One program: {TEXT CLAIMS EDIT} -- TEXT with %S1% and %S2% for the
# switches' bodies, CLAIMS {LINE NAME RECOGNIZER ARITY TUPLES}... in source
# order with their traces' positions in the value, EDIT an edited text.
proc gen::Program {seed} {
    variable rng
    set rng [expr {$seed * 7919 + 101}]
    set head [list "import std::coroutine" "import std::dfa" "" "class digit = '0'..'9'" "class letter = 'A'..'Z'" "" \
        "type Bit = Int in 0..1" "" "dfa digit_token over ascii:" "    start:" "        digit -> accept" "" \
        "dfa pair_token over ascii:" "    start:" "        digit -> second" "    second:" "        letter -> accept" "" \
        "fn s1() -> bool:" "    %S1%" "" "fn s2() -> bool:" "    %S2%" ""]
    set lines $head
    set claims {}
    set helpers {}
    # Top level: helpers, then emitters.
    set callable {}
    foreach name [lrange {h g} 0 [Rand 2]] {
        lassign [Function $name $callable 0] fl - kind
        set arity [regexp {\(b0} [lindex $fl 0]]
        lappend helpers [dict create lines $fl nested 0 name $name arity $arity at [expr {[llength $lines] + 1}]]
        lappend lines {*}$fl ""
        lappend callable [list $name $arity $kind]
    }
    set topCalls {}
    set topDrivers {}
    foreach name [lrange {e f} 0 [Rand 2]] {
        if {[Chance 50]} continue
        lassign [Function $name $callable 1] fl claim
        lappend claims [list [expr {[llength $lines] + 1}] {*}$claim]
        lappend lines {*}$fl ""
        lassign [Driver $claim top$name] dl calls
        lappend topDrivers {*}$dl ""
        lappend topCalls {*}$calls
    }
    # Outer functions.
    set outers {}
    for {set i 1} {$i <= 2 + [Rand 2]} {incr i} {
        set scope $callable
        set body {}
        foreach name [lrange {h g} 0 [Rand 2]] {
            if {[Chance 40]} continue
            lassign [Function $name $scope 0] fl - kind
            set arity [regexp {\(b0} [lindex $fl 0]]
            lappend helpers [dict create lines [Indent $fl] nested 1 name $name arity $arity \
                at [expr {[llength $lines] + 2 + [llength $body]}]]
            lappend body {*}[Indent $fl]
            set scope [lsearch -all -inline -not -index 0 $scope $name]
            lappend scope [list $name $arity $kind]
        }
        set calls {}
        foreach name [lrange {e f} 0 [Rand 2]] {
            lassign [Function $name $scope 1] fl claim
            lappend claims [list [expr {[llength $lines] + 2 + [llength $body]}] {*}$claim]
            lappend body {*}[Indent $fl]
            lassign [Driver $claim o${i}$name] dl dc
            lappend body {*}[Indent $dl]
            lappend calls {*}$dc
        }
        if {$calls eq {}} {
            lappend body "    \[\]"
        } else {
            lappend body "    \[[join $calls {, }]\]"
        }
        lappend lines "fn outer$i\() -> List\[List\[int\]\]:" {*}$body ""
        lappend outers "outer$i\()"
    }
    lappend lines {*}$topDrivers
    lappend lines "\[[join [concat $outers [list "\[[join $topCalls {, }]\]"]] {, }]\]"
    set text "[join $lines \n]\n"
    # The edit: a nested helper removed where a top-level helper of its
    # name and arity is what its scope's calls then mean (the census's N6:
    # a name that stops being shared), else a helper's first symbol changed.
    set edit $text
    set editClaims $claims
    set removable {}
    foreach h $helpers {
        if {![dict get $h nested]} continue
        foreach t $helpers {
            if {![dict get $t nested] && [dict get $t name] eq [dict get $h name] && [dict get $t arity] == [dict get $h arity]} {
                lappend removable $h
            }
        }
    }
    if {$removable ne {} && [Chance 60]} {
        set h [Pick $removable]
        set at [dict get $h at]
        set n [llength [dict get $h lines]]
        set all [split [string trimright $text \n] \n]
        set edit "[join [lreplace $all [expr {$at - 1}] [expr {$at + $n - 2}]] \n]\n"
        set editClaims [lmap c $claims {
            if {[lindex $c 0] > $at} {
                lset c 0 [expr {[lindex $c 0] - $n}]
            }
            set c
        }]
        set how "nested [dict get $h name] (line $at) removed"
    } elseif {$helpers ne {}} {
        set h [Pick $helpers]
        set old [join [dict get $h lines] \n]
        set new [regsub {yield (49|50|65|66)} $old {yield 66}]
        if {$new eq $old} {
            set new [regsub {yield (49|50|65|66)} $old {yield 49}]
        }
        set edit [string map [list $old $new] $text]
        set how "[dict get $h name] (line [dict get $h at]): a symbol changed"
    } else {
        set how "none"
    }
    return [list $text $claims $edit $editClaims $how]
}

# The text of PROGRAM for switch assignment ASSIGNMENT ({S1 S2}).
proc gen::Assign {program assignment} {
    lassign $assignment a b
    return [string map [list %S1% $a %S2% $b] $program]
}

# {LINE VERDICT}... of the claims of the program at PATH (lenient).
proc Verdicts {path} {
    set hir [emit::compile $path]
    set out {}
    foreach r [hir::emission::claims $hir] {
        set origin [dict get $r origin]
        set line [dict getdef [lrange $origin 2 end] line 0]
        lappend out [list $line [dict get $r verdict]]
    }
    return [lsort -integer -index 0 $out]
}

proc Range {spec} {
    set out {}
    foreach part [split $spec ,] {
        if {[regexp {^(\d+)-(\d+)$} $part -> a b]} {
            for {set i $a} {$i <= $b} {incr i} { lappend out $i }
        } else {
            lappend out $part
        }
    }
    return $out
}

set totals [dict create programs 0 claims 0 proven 0 rejected 0 not-proved 0 dependent 0 \
    "false certificate" 0 "history differs" 0 "rejected, confirmed" 0 "precision loss" 0 discarded 0 runs 0 \
    "parameterless claims" 0 "names of several functions" 0 "claims whose name is shared" 0 \
    "edits removing a shadowing helper" 0]
set rows {}
set failures 0
set base [file tempdir]
set assignments {{true true} {true false} {false true} {false false}}

# The fresh verdicts of PROGRAM for every assignment: {ASSIGNMENT {{LINE
# VERDICT}...}...}, the program written at PATH; checked against the memo
# off (DIFFERSVAR).
proc Fresh {program path differsVar label} {
    upvar 1 $differsVar differs
    set out [dict create]
    foreach a $::assignments {
        emit::writeText $path [gen::Assign $program $a]
        set ::hir::emission::memo [dict create]
        set ::hir::emission::useMemo 1
        dict set out $a [Verdicts $path]
        set ::hir::emission::useMemo 0
        if {[Verdicts $path] ne [dict get $out $a]} {
            lappend differs "$label, memo off, $a"
        }
        set ::hir::emission::useMemo 1
    }
    return $out
}

# Every claimed emitter of PROGRAM (CLAIMS) run for every argument tuple of
# every assignment, its claims erased: {INVALID FALSE} -- INVALID {LINE
# WHY}... of the claims some run of which is invalid, FALSE the certified
# ones among them ({LINE WHY} of the first run that shows it).
proc Runs {program claims verdicts dir label} {
    set path [file join $dir main.bot]
    set invalid [dict create]
    set false [dict create]
    foreach a $::assignments {
        set text [gen::Assign $program $a]
        set stripped [emit::strip $text]
        if {[catch {surface::compile $stripped -warnings off} hir]} {
            error "$label: the erased program does not compile: [lindex [split $hir \n] 0]"
        }
        set outcome [outcomeUnderHir interp $hir]
        if {[lindex $outcome 0] ne "value"} {
            error "$label: the erased program fails: [lindex $outcome 2]"
        }
        set value [lindex [string map {\[ \{ \] \} , ""} [lindex $outcome 1]] 0]
        emit::writeText $path $stripped
        set model [emit::reference $dir]
        set runs {}
        foreach group $value { lappend runs {*}$group }
        # The drivers' order: the outer functions' emitters, then the top
        # level's; each emitter's tuples consecutively.
        set order [lsort -integer -index 0 $claims]
        set lines [split $text \n]
        set outerClaims {}
        set topClaims {}
        foreach c $order {
            if {[regexp {^    fn } [lindex $lines [expr {[lindex $c 0] - 1}]]]} {
                lappend outerClaims $c
            } else {
                lappend topClaims $c
            }
        }
        set i 0
        foreach c [concat $outerClaims $topClaims] {
            lassign $c line name r arity
            foreach tuple [gen::Tuples $arity] {
                set run [lindex $runs $i]
                incr i
                dict incr ::totals runs
                set end [lsearch -exact $run -9]
                if {$end < 0} {
                    set outcome truncated
                    set symbols $run
                } else {
                    set symbols [lrange $run 0 [expr {$end - 2}]]
                    set outcome complete
                }
                set j [emit::judge $model [list "" $r] $outcome $symbols]
                if {$j eq "ok"} continue
                set why "$name ($r), s = $a, args = ($tuple): [lindex $j 1]"
                if {![dict exists $invalid $line]} {
                    dict set invalid $line $why
                }
                set verdict [lindex [lsearch -inline -index 0 [dict get $verdicts $a] $line] 1]
                if {$verdict eq "proven" && ![dict exists $false $line]} {
                    dict set false $line $why
                }
            }
        }
        if {$i != [llength $runs]} {
            error "$label: driver mismatch: $i runs expected, [llength $runs] made"
        }
    }
    return [list $invalid $false]
}

foreach seed [Range [dict get $options -seeds]] {
    lassign [gen::Program $seed] program claims edited editedClaims how
    set dir [file join $base s$seed]
    file mkdir $dir
    set path [file join $dir main.bot]
    if {[dict get $options -keep] ne ""} {
        file mkdir [dict get $options -keep]
        emit::writeText [file join [dict get $options -keep] s$seed.bot] $program
        emit::writeText [file join [dict get $options -keep] s$seed-edited.bot] $edited
    }
    if {[string match "nested *" $how]} {
        dict incr totals "edits removing a shadowing helper"
    }
    # Names bound by several functions (helpers and emitters).
    set count [dict create]
    foreach {- n} [regexp -all -inline -line {^\s*fn ([a-z][a-z0-9_]*)\(} $program] { dict incr count $n }
    set shared [dict keys [dict filter $count script {k v} {expr {$v > 1}}]]
    dict incr totals "names of several functions" [llength $shared]
    set differs {}
    if {[catch {
        set verdicts [Fresh $program $path differs program]
        set editedVerdicts [Fresh $edited $path differs edited]
        # History, the memo kept: each version after the other, two rounds.
        set ::hir::emission::memo [dict create]
        foreach round {1 2} {
            foreach a $assignments {
                foreach {first second expected label} [list $edited $program $verdicts program $program $edited $editedVerdicts edited] {
                    emit::writeText $path [gen::Assign $first $a]
                    Verdicts $path
                    emit::writeText $path [gen::Assign $second $a]
                    if {[Verdicts $path] ne [dict get $expected $a]} {
                        lappend differs "$label after the other (round $round), $a"
                    }
                }
            }
        }
        lassign [Runs $program $claims $verdicts $dir program] invalid false
        lassign [Runs $edited $editedClaims $editedVerdicts $dir edited] editedInvalid editedFalse
    } message]} {
        dict incr totals discarded
        lappend rows "| $seed | (discarded: [string map {| /} $message]) |"
        continue
    }
    dict incr totals programs
    if {$differs ne {}} {
        dict incr totals "history differs"
        incr failures
        lappend rows "| $seed | HISTORY DIFFERS: [join [lsort -unique $differs] {; }] |"
    }
    set counts [dict create]
    foreach {cs vs inv fs label} [list $claims $verdicts $invalid $false program $editedClaims $editedVerdicts $editedInvalid $editedFalse edited] {
        foreach c $cs {
            lassign $c line name r arity
            dict incr totals claims
            if {$arity == 0} { dict incr totals "parameterless claims" }
            if {$name in $shared} { dict incr totals "claims whose name is shared" }
            set seen [lsort -unique [lmap a $assignments {lindex [lsearch -inline -index 0 [dict get $vs $a] $line] 1}]]
            foreach v $seen {
                dict incr totals $v
                dict incr counts $v
            }
            if {"proven" ni $seen && ![dict exists $inv $line]} {
                dict incr totals "precision loss"
                lappend rows "| $seed | precision loss ($label, line $line): $name ($r), [join $seen /], every run valid |"
            } elseif {"proven" ni $seen} {
                dict incr totals "rejected, confirmed"
            }
        }
        dict for {line why} $fs {
            incr failures
            dict incr totals "false certificate"
            lappend rows "| $seed | FALSE CERTIFICATE ($label, line $line): $why |"
        }
    }
    lappend rows "| $seed | [join [lmap {k v} $counts {string cat $k " " $v}] {, }]; shared names: [expr {$shared eq {} ? "none" : [join $shared {, }]}]; edit: $how |"
}
file delete -force $base

set report [list "## Structural audit: identity and feasibility" "" \
    "seeds [dict get $options -seeds]; compiler: [expr {[file normalize $root] eq [file normalize [file dirname [file dirname [file dirname $here]]]] ? "this checkout" : $root}]; the program and an edited version of it, every claim decided for 4 switch assignments with a fresh memo, with it off, and after the other version (the memo kept, two rounds); every emitter of both run for every argument tuple of every assignment (interp)" "" \
    "| seed | result |" "|---|---|" {*}$rows "" "| total | |" "|---|---:|"]
dict for {k v} $totals {
    lappend report "| $k | $v |"
}
set text [join $report \n]
if {[dict get $options -out] ne ""} {
    emit::writeText [dict get $options -out] "$text\n"
}
puts $text
emit::cleanup
exit [expr {$failures > 0}]
