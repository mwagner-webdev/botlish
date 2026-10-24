#!/usr/bin/env tclsh9.0
# oracle.tcl -- an independent check of method-call decisions
# (METHOD-RESOLUTION-CORRECTNESS-MILESTONE-1.md, "Independent validation").
#
#   tclsh9.0 audit/method-resolution/tools/oracle.tcl ?SEEDS? ?FIRST-SEED? ?-dump 1? ?-seed-only S?
#
# Every program this tool generates lives in a small universe where the
# applicability of a candidate is decidable by a few declarative rules, which
# the tool states itself and the compiler's decision procedure does not take
# part in:
#
#   * values have one of the static types int, str, List[int], List[str],
#     List[List[int]], types::Bag, types::Box -- every one nominal, admitted
#     only by itself;
#   * the visible candidates of `r.m(args)` are std::list::length,
#     std::list::at and std::str::length (the file imports std::list and
#     std::str, which define no other function of these names) and the
#     functions named m of the application modules the file imports, each
#     declaring every parameter type;
#   * a module function applies when the call has its arity and each argument
#     (the receiver first) has the parameter's declared type; a native when
#     its receiver has the native's kind (a List for std::list::*, a String
#     for std::str::length) -- its later arguments are not checked
#     statically, and the generator gives them their kind;
#   * a call with exactly one applicable candidate has that candidate's
#     result type, else it is AMBIGUOUS-METHOD-CALL (several) or
#     NO-APPLICABLE-METHOD (none), and nothing is predicted of the calls that
#     depend on its value.
#
# The generator builds random typed expressions over method calls -- chains,
# calls in argument positions, receivers of every type -- in application
# modules whose names sort before and after `std` and that declare
# overlapping signatures (so a call may be ambiguous, have no applicable
# candidate, or have an outer candidate that sorts first and rejects an inner
# call's result). For each program the tool predicts every method call's
# outcome, compiles the program, and requires
#
#   * every call the compiler records with several candidates to be decided
#     to the predicted candidate, or rejected with the predicted kind (the
#     calls are matched by the position of their method name);
#   * the program to be rejected exactly when a call is predicted rejected
#     (or a single-candidate call inapplicable);
#   * an accepted program to run (interpreter) to the value of its qualified
#     spelling -- every call written `NS::m(r, args)` with the predicted
#     candidate -- which the compiler also compiles;
#   * the same program with its application modules renamed (so they sort the
#     other way) to be predicted and decided alike.
#
# The summary line is
#
#   method-resolution-oracle seeds N programs P calls C accepted A
#       rejected R disagreements D
#
# and the exit status is 1 if D is not zero.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set args $argv
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
interp recursionlimit {} 100000

set seeds 50
set first 1
set dump 0
set only ""
if {[llength $args] > 0 && [string is integer -strict [lindex $args 0]]} {
    set seeds [lindex $args 0]
    set args [lrange $args 1 end]
}
if {[llength $args] > 0 && [string is integer -strict [lindex $args 0]]} {
    set first [lindex $args 0]
    set args [lrange $args 1 end]
}
while {[llength $args] >= 2} {
    switch -- [lindex $args 0] {
        -dump { set dump [lindex $args 1] }
        -seed-only { set only [lindex $args 1] }
        default { puts stderr "unknown option [lindex $args 0]"; exit 2 }
    }
    set args [lrange $args 2 end]
}

proc pick {list} { lindex $list [expr {int(rand() * [llength $list])}] }
proc chance {p} { expr {rand() < $p} }

# ---------------------------------------------------------------------------
# The universe

# Static type -> its spelling, and a literal of it.
set typeText {
    int int str str ilist List[int] slist List[str] llist List[List[int]]
    bag types::Bag box types::Box
}
proc literal {type} {
    switch -- $type {
        int { return [expr {int(rand() * 9)}] }
        str { return "\"[pick {a bb ccc}]\"" }
        ilist { return "\[[expr {int(rand() * 9)}], [expr {int(rand() * 9)}]\]" }
        slist { return "\[\"x\", \"yy\"\]" }
        llist { return "\[\[1, 2\], \[3\]\]" }
        bag { return "types::Bag {n: [expr {int(rand() * 9)}]}" }
        box { return "types::Box {v: [expr {int(rand() * 9)}]}" }
    }
}

# The module function templates: name, parameter types, result type, body.
set templates {
    {length {bag} int {p0.n}}
    {length {ilist} int {0}}
    {length {box} int {p0.v}}
    {at {box int} int {p0.v + p1}}
    {at {slist int} str {"s"}}
    {size {bag} int {p0.n + 1}}
    {size {str} int {2}}
    {size {ilist} int {3}}
    {pick {int int} int {p0 + p1}}
    {pick {str int} str {p0}}
    {pick {bag int} int {p0.n + p1}}
    {wrap {int} bag {types::Bag {n: p0}}}
    {wrap {str} box {types::Box {v: 1}}}
    {first {llist} ilist {[7]}}
}

# The natives of std::list and std::str named like a method: name ->
# {receiver-kind result-rule}.
set natives {
    std::list::length {list int}
    std::list::at {list element}
    std::str::length {str int}
}

proc kindOf {type} {
    expr {$type in {ilist slist llist} ? "list" : $type}
}
proc elementOf {type} {
    dict get {ilist int slist str llist ilist} $type
}

# The candidates of method NAME (the application modules MODULES, a dict
# module -> its templates): {display params result native} each.
proc candidates {name modules} {
    set out {}
    dict for {qualified spec} $::natives {
        if {[namespace tail $qualified] eq $name} {
            lappend out [list $qualified native $spec]
        }
    }
    dict for {module fns} $modules {
        foreach t $fns {
            lassign $t fname params result
            if {$fname eq $name} {
                lappend out [list ${module}::$name $params $result]
            }
        }
    }
    return $out
}

# The applicable candidates of the call NAME with argument types ARGTYPES
# (the receiver first) and the result type each gives: {display result}.
proc applicable {name argTypes modules} {
    set out {}
    foreach c [candidates $name $modules] {
        lassign $c display params result
        if {$params eq "native"} {
            lassign $result kind rule
            if {[kindOf [lindex $argTypes 0]] ne $kind} continue
            if {$display eq "std::list::at" && [llength $argTypes] != 2} continue
            if {$display ne "std::list::at" && [llength $argTypes] != 1} continue
            set type [expr {$rule eq "element" ? [elementOf [lindex $argTypes 0]] : $rule}]
            lappend out [list $display $type]
            continue
        }
        if {[llength $params] != [llength $argTypes]} continue
        set fits 1
        foreach p $params a $argTypes {
            if {$p ne $a} { set fits 0 }
        }
        if {$fits} {
            lappend out [list $display $result]
        }
    }
    return $out
}

# ---------------------------------------------------------------------------
# Expressions: a tree is {lit TEXT TYPE} or {call NAME RECEIVER ARGS}.

# The method templates that give a value of TYPE: {name receiverType
# argTypes}.
proc producers {type} {
    set out {}
    foreach t $::templates {
        lassign $t name params result
        if {$result eq $type} {
            lappend out [list $name [lindex $params 0] [lrange $params 1 end]]
        }
    }
    switch -- $type {
        int { lappend out {length ilist {}} {length slist {}} {length str {}} {at ilist int} }
        str { lappend out {at slist int} }
        ilist { lappend out {at llist int} }
    }
    return $out
}

proc gen {type depth} {
    if {$depth <= 0 || [chance 0.3]} {
        return [list lit [literal $type] $type]
    }
    set options [producers $type]
    if {$options eq "" } {
        return [list lit [literal $type] $type]
    }
    lassign [pick $options] name recvType argTypes
    if {[chance 0.08]} {
        # A receiver of another type: a call that may fit nothing.
        set recvType [pick {int str ilist slist llist bag box}]
    }
    set receiver [gen $recvType [expr {$depth - 1}]]
    set args [lmap a $argTypes {
        if {$a eq "int" && ($name eq "at" || [chance 0.7])} {
            # (An index is 0 or 1, within every List literal: an index the
            # completion analysis proves out of range is a KNOWN-ERROR,
            # which this universe does not model.)
            list lit [expr {int(rand() * 2)}] int
        } else {
            gen $a [expr {$depth - 2}]
        }
    }]
    return [list call $name $receiver $args]
}

# The prediction for TREE under MODULES: {type T calls C} where T is the
# static type ("" when unknown: a rejected call is below) and C a list of
# {id outcome} per call node, ID its preorder number (the caller's counter
# variable), OUTCOME {decided DISPLAY} | {rejected KIND} | {single ok} |
# {single bad} | {unknown}.
proc predict {tree modules counterVar} {
    upvar 1 $counterVar counter
    if {[lindex $tree 0] eq "lit"} {
        return [list type [lindex $tree 2] calls {}]
    }
    lassign $tree - name receiver args
    set id [incr counter]
    set calls {}
    set types {}
    set r [predict $receiver $modules counter]
    lappend types [dict get $r type]
    lappend calls {*}[dict get $r calls]
    foreach a $args {
        set p [predict $a $modules counter]
        lappend types [dict get $p type]
        lappend calls {*}[dict get $p calls]
    }
    if {"" in $types} {
        return [list type "" calls [linsert $calls 0 [list $id unknown]]]
    }
    set fit [applicable $name $types $modules]
    set count [llength [candidates $name $modules]]
    if {[llength $fit] == 1} {
        lassign [lindex $fit 0] display type
        set outcome [expr {$count > 1 ? [list decided $display] : {single ok}}]
        return [list type $type calls [linsert $calls 0 [list $id $outcome]]]
    }
    if {$count <= 1} {
        # (No candidate of that name at all: the call of a field value, whose
        # projection is the ordinary diagnostic. One: the free call's.)
        return [list type "" calls [linsert $calls 0 [list $id {single bad}]]]
    }
    set kind [expr {[llength $fit] > 1 ? "AMBIGUOUS-METHOD-CALL" : "NO-APPLICABLE-METHOD"}]
    return [list type "" calls [linsert $calls 0 [list $id [list rejected $kind]]]]
}

# The text of TREE in method spelling: {TEXT NAMES}, NAMES a list of {id
# offset} (the offset of each call's method name in TEXT), ids in preorder.
proc render {tree counterVar} {
    upvar 1 $counterVar counter
    if {[lindex $tree 0] eq "lit"} {
        return [list [lindex $tree 1] {}]
    }
    lassign $tree - name receiver args
    set id [incr counter]
    lassign [render $receiver counter] rtext rnames
    set text "($rtext)"
    set names [lmap n $rnames {list [lindex $n 0] [expr {[lindex $n 1] + 1}]}]
    append text .
    lappend names [list $id [string length $text]]
    append text "$name\("
    set parts {}
    foreach a $args {
        lassign [render $a counter] atext anames
        set at [string length $text]
        if {$parts ne ""} {
            incr at [expr {2 * [llength $parts]}]
            foreach p $parts { incr at [string length $p] }
        }
        lappend parts $atext
        foreach n $anames { lappend names [list [lindex $n 0] [expr {$at + [lindex $n 1]}]] }
    }
    append text [join $parts {, }] ")"
    return [list $text [lsort -index 0 -integer $names]]
}

# The qualified spelling of TREE, each call written with the candidate
# PREDICTION (id -> outcome) decided it to.
proc qualified {tree outcomes counterVar} {
    upvar 1 $counterVar counter
    if {[lindex $tree 0] eq "lit"} {
        return [lindex $tree 1]
    }
    lassign $tree - name receiver args
    set id [incr counter]
    set callee [lindex [dict get $outcomes $id] 1]
    set parts [list [qualified $receiver $outcomes counter]]
    foreach a $args {
        lappend parts [qualified $a $outcomes counter]
    }
    return "$callee\([join $parts {, }])"
}

# ---------------------------------------------------------------------------
# Programs

# A random program: {files MODULES STATEMENTS}, STATEMENTS a list of trees of
# type int.
proc program {} {
    set names [pick {{aa zz} {zz aa} {aa mm} {bb zz} {app zzz}}]
    set modules [dict create]
    foreach m $names {
        # (At most one function of a name per module: Botlish has no
        # overloading.)
        set fns {}
        set taken {}
        foreach t $::templates {
            if {[lindex $t 0] in $taken || ![chance 0.45]} continue
            lappend fns $t
            lappend taken [lindex $t 0]
        }
        dict set modules $m $fns
    }
    set statements {}
    foreach i [lrepeat [expr {1 + int(rand() * 3)}] x] {
        lappend statements [gen int 4]
    }
    return [list $modules $statements]
}

proc moduleText {fns} {
    set text "import types\n\n"
    foreach t $fns {
        lassign $t name params result body
        set ps {}
        set i 0
        foreach p $params {
            lappend ps "p$i: [dict get $::typeText $p]"
            incr i
        }
        append text "fn ${name}([join $ps {, }]) -> [dict get $::typeText $result]:\n    $body\n\n"
    }
    return $text
}

set typesText "struct Bag:\n    n: int\n\nstruct Box:\n    v: int\n"

# The files of a program whose statements are TEXTS (int expressions), each
# its own function's body.
proc programFiles {modules texts} {
    set files [dict create types.bot $::typesText]
    set head "import std::list\nimport std::str\nimport types\n"
    dict for {m fns} $modules {
        dict set files $m.bot [moduleText $fns]
        append head "import $m\n"
    }
    set body ""
    set tail {}
    set sum {}
    set i 0
    foreach text $texts {
        append body "fn t${i}() -> int errors IndexNotFound:\n    $text\n\n"
        lappend tail "r$i = t${i}():\n    on IndexNotFound:\n        -1"
        lappend sum r$i
        incr i
    }
    dict set files main.bot "$head\n$body[join $tail \n]\n[join $sum { + }]\n"
    return $files
}

# The 1-based line of the first statement's text in main.bot (header lines
# and blank line before the first function, then the `fn` line).
proc firstLine {modules} {
    expr {3 + [dict size $modules] + 1 + 2}
}

proc compileFiles {files} {
    set dir [file tempdir botlish-method-oracle]
    try {
        dict for {name text} $files {
            set f [open [file join $dir $name] w]
            fconfigure $f -encoding utf-8
            puts -nonewline $f $text
            close $f
        }
        if {[catch {surface::readProgramFile [file join $dir main.bot] -strict 0 -warnings off -cache ""} hir]} {
            return [list error $hir]
        }
        return [list ok $hir]
    } finally {
        file delete -force $dir
    }
}

# What the compiler did with each multi-candidate method call of HIR: a dict
# {line column} -> {decided DISPLAY} | {rejected KIND} | {stand-in DISPLAY}.
proc compiled {hir} {
    set out [dict create]
    set decided [if {[dict exists $hir methodDecided]} {dict get $hir methodDecided} else {dict get $hir methodChoices}]
    set rejections [dict create]
    foreach d [dict get $hir diagnostics] {
        if {[dict get $d kind] ni {AMBIGUOUS-METHOD-CALL NO-APPLICABLE-METHOD}} continue
        dict set rejections [dict get $d expr] [dict get $d kind]
    }
    dict for {key info} [dict get $hir methodCalls] {
        set e [dict get $info expr]
        set origin [dict get $hir exprs $e method nameOrigin]
        set where [list [dict get $origin line] [dict get $origin column]]
        if {[dict exists $rejections $e]} {
            dict set out $where [list rejected [dict get $rejections $e]]
        } elseif {[dict exists $decided $key]} {
            dict set out $where [list decided [dict get $decided $key]]
        } else {
            dict set out $where [list stand-in [dict get $info chosen]]
        }
    }
    return $out
}

# Checks one program: {ok} or {bad REASON}; updates the counters.
proc check {modules statements tag} {
    set predictions {}
    set texts {}
    set positions {}
    set line [firstLine $modules]
    set rejectedProgram 0
    set accepted 1
    foreach tree $statements {
        set counter 0
        set p [predict $tree $modules counter]
        set counter 0
        lassign [render $tree counter] text names
        lappend texts $text
        foreach n $names {
            lassign $n id offset
            dict set positions [list $line [expr {4 + $offset + 1}]] [list [llength $predictions] $id]
        }
        set outcomes [dict create]
        if {[dict get $p type] ne "int"} {
            # (A statement whose calls give it another type than its
            # function's declared int is a TYPE error of the function.)
            set accepted 0
        }
        foreach c [dict get $p calls] {
            lassign $c id outcome
            dict set outcomes $id $outcome
            if {[lindex $outcome 0] eq "rejected" || $outcome eq {single bad}} {
                set accepted 0
            }
        }
        lappend predictions $outcomes
        incr line 3
    }
    set files [programFiles $modules $texts]
    lassign [compileFiles $files] status hir
    if {$status eq "error"} {
        return [list bad "$tag: the compilation raised: [string range $hir 0 200]" $files]
    }
    set found [compiled $hir]
    incr ::calls [dict size $positions]
    dict for {where info} $positions {
        lassign $info s id
        set predicted [dict get [lindex $predictions $s] $id]
        if {![dict exists $found $where]} {
            # A call with one candidate (or none of these names): no record.
            if {[lindex $predicted 0] in {decided rejected}} {
                return [list bad "$tag: call at $where predicted $predicted is not a multi-candidate call" $files]
            }
            continue
        }
        set actual [dict get $found $where]
        switch -- [lindex $predicted 0] {
            decided - rejected {
                if {$actual ne $predicted} {
                    return [list bad "$tag: call at $where: predicted $predicted, compiler $actual" $files]
                }
            }
        }
    }
    set diagnostics [dict get $hir diagnostics]
    if {$accepted && $diagnostics ne ""} {
        return [list bad "$tag: predicted accepted, compiler: [lmap d $diagnostics {dict get $d kind}]" $files]
    }
    if {!$accepted && $diagnostics eq ""} {
        return [list bad "$tag: predicted rejected, compiler accepted" $files]
    }
    if {$accepted} {
        incr ::acceptedPrograms
        set qtexts {}
        foreach tree $statements outcomes $predictions {
            set counter 0
            set full [dict create]
            dict for {id outcome} $outcomes {
                if {$outcome eq {single ok}} {
                    # The one candidate: recompute its display.
                    dict set full $id [list decided ""]
                } else {
                    dict set full $id $outcome
                }
            }
            lappend qtexts [qualified $tree [SingleDisplays $tree $modules $full] counter]
        }
        lassign [compileFiles [programFiles $modules $qtexts]] qstatus qhir
        if {$qstatus eq "error" || [dict get $qhir diagnostics] ne ""} {
            return [list bad "$tag: the qualified spelling does not compile" $files]
        }
        set a [outcomeUnderHir interp $hir]
        set b [outcomeUnderHir interp $qhir]
        if {[lrange $a 0 1] ne [lrange $b 0 1]} {
            return [list bad "$tag: method spelling runs to $a, qualified to $b" $files]
        }
    } else {
        incr ::rejectedPrograms
    }
    return [list ok]
}

# OUTCOMES with every single-candidate call's display filled in (the one
# applicable candidate of TREE's call).
proc SingleDisplays {tree modules outcomes} {
    set counter 0
    FillSingles $tree $modules outcomes counter
    return $outcomes
}
proc FillSingles {tree modules outcomesVar counterVar} {
    upvar 1 $outcomesVar outcomes $counterVar counter
    if {[lindex $tree 0] eq "lit"} {
        return [lindex $tree 2]
    }
    lassign $tree - name receiver args
    set id [incr counter]
    set types [list [FillSingles $receiver $modules outcomes counter]]
    foreach a $args {
        lappend types [FillSingles $a $modules outcomes counter]
    }
    set fit [applicable $name $types $modules]
    lassign [lindex $fit 0] display type
    if {[lindex [dict get $outcomes $id] 1] eq ""} {
        dict set outcomes $id [list decided $display]
    }
    return $type
}

# MODULES renamed: each application module's name replaced so that the
# names sort the other way (and every display the prediction names).
proc renamed {modules} {
    set out [dict create]
    set names [dict keys $modules]
    set fresh [dict create]
    foreach m $names {
        dict set fresh $m [string map {a z z a b y m n p q} $m]
    }
    dict for {m fns} $modules {
        dict set out [dict get $fresh $m] $fns
    }
    return $out
}

set programs 0
set ::calls 0
set ::acceptedPrograms 0
set ::rejectedPrograms 0
set disagreements 0
if {$only ne ""} {
    set first $only
    set seeds 1
}
for {set seed $first} {$seed < $first + $seeds} {incr seed} {
    expr {srand($seed)}
    lassign [program] modules statements
    incr programs
    foreach {tag mods} [list as-written $modules renamed [renamed $modules]] {
        set result [check $mods $statements "seed $seed ($tag)"]
        if {$dump} {
            puts "---- seed $seed $tag: [lindex $result 0]"
            if {[llength $result] > 2} {
                dict for {name text} [lindex $result 2] { puts "== $name\n$text" }
            }
        }
        if {[lindex $result 0] ne "ok"} {
            incr disagreements
            puts "DISAGREE [lindex $result 1]"
            if {!$dump} {
                dict for {name text} [lindex $result 2] { puts "== $name\n$text" }
            }
            break
        }
    }
}
puts "method-resolution-oracle seeds $seeds programs $programs calls $::calls accepted $::acceptedPrograms rejected $::rejectedPrograms disagreements $disagreements"
exit [expr {$disagreements > 0}]
