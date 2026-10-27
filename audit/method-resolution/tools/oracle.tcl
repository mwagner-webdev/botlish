#!/usr/bin/env tclsh9.0
# oracle.tcl -- an independent check of method-call decisions
# (METHOD-RESOLUTION-CORRECTNESS-MILESTONE-1.md, "Independent validation").
#
#   tclsh9.0 audit/method-resolution/tools/oracle.tcl ?SEEDS? ?FIRST-SEED? ?-dump 1? ?-seed-only S?
#       ?-contexts 1?
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
# call's result), some of them differing only in their result types (a
# call's use would tell those apart, and must not: it is no check of the
# call's). For each program the tool predicts every method call's outcome,
# compiles the program, and requires
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
# -contexts 1 adds the environment (SFIAE-MILESTONE-1.md): a module function
# may require a context -- the context trait env::Env, which two installable
# contexts implement (ca::CA, cb::CB), or the exact context cx::CX -- and
# about half of a program's statements are top-level code (no `at`, so no
# error to handle), where a call's context requirement is checked against the
# installations before it. Each check installs a random set of the three
# contexts. The rules gain one, stated here too:
#
#   * a context requirement is an obligation of the decided call, never a
#     condition of applicability: decisions are predicted exactly as without
#     contexts, whatever is installed, and a program whose calls are all
#     decided is rejected exactly when a decided callee's requirement (that of
#     a call in a function body is its top-level caller's) has no provider
#     (MISSING-CONTEXT) or Env has two (AMBIGUOUS-CONTEXT-IMPLEMENTATION) --
#     with exactly those diagnostic kinds.
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
set contexts 0
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
        -contexts { set contexts [lindex $args 1] }
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
        llist { return "\[\[1, 2\], \[3, 4\]\]" }
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
    {first {llist} ilist {[7, 8]}}
    {size {bag} str {"b"}}
    {first {llist} int {7}}
}

# The natives of std::list and std::str named like a method: name ->
# {receiver-kind result-rule}.
set natives {
    std::list::length {list int}
    std::list::at {list element}
    std::str::length {str int}
}

# -contexts 1: the context modules, the installations a check chooses from
# (ca, cb: the two contexts implementing env::Env; cx: the exact context) and
# the requirements a module function may have ("" none, env, cx).
set contextFiles {
    env.bot "context trait Env:\n    fn tick(n: int) -> int\n"
    ca.bot "context struct CA:\n    z: int\n\nfn tick(n: int, context c: CA) -> int:\n    n + c.z\n"
    cb.bot "context struct CB:\n    z: int\n\nfn tick(n: int, context c: CB) -> int:\n    n * (c.z + 1)\n"
    cx.bot "context struct CX:\n    z: int\n"
}
set environments {{} {ca} {cb} {ca cb} {cx} {ca cx} {ca cb cx}}
set requirementParam {env {context e: env::Env} cx {context c: cx::CX}}

# The obligation kind a requirement REQUIREMENT ("" none, env, cx) of a
# top-level call fails with under the installations ENVIRONMENT, "" when it
# is met.
proc obligation {requirement environment} {
    switch -- $requirement {
        env {
            set providers [llength [lmap c {ca cb} {expr {$c in $environment ? $c : [continue]}}]]
            if {$providers == 0} { return MISSING-CONTEXT }
            if {$providers > 1} { return AMBIGUOUS-CONTEXT-IMPLEMENTATION }
        }
        cx {
            if {"cx" ni $environment} { return MISSING-CONTEXT }
        }
    }
    return ""
}

# The requirement of the candidate DISPLAY under MODULES ("" for a native).
proc requirementOf {display modules} {
    set module [namespace qualifiers $display]
    if {![dict exists $modules $module]} {
        return ""
    }
    foreach t [dict get $modules $module] {
        if {[lindex $t 0] eq [namespace tail $display]} {
            return [lindex $t 4]
        }
    }
    return ""
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
    if {$::noAt} {
        # (A top-level statement: no `at`, whose IndexNotFound the top level
        # could not handle.)
        set options [lmap o $options {expr {[lindex $o 0] eq "at" ? [continue] : [list {*}$o]}}]
    }
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
            # (An index is 0 or 1, within every List a program makes, all
            # of two elements: an index the completion analysis proves out
            # of range is a KNOWN-ERROR, which this universe does not
            # model.)
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

# A random program: {MODULES STATEMENTS PLACES}, STATEMENTS a list of trees
# of type int, PLACES each one's place: fn (a function's body) or top (with
# -contexts 1, top-level code).
set noAt 0
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
            if {$::contexts} {
                # Its context requirement, the template's fifth element.
                set r [expr {rand()}]
                lappend t [expr {$r < 0.5 ? "" : $r < 0.85 ? "env" : "cx"}]
            }
            lappend fns $t
            lappend taken [lindex $t 0]
        }
        dict set modules $m $fns
    }
    set statements {}
    set places {}
    foreach i [lrepeat [expr {1 + int(rand() * 3)}] x] {
        set place [expr {$::contexts && [chance 0.5] ? "top" : "fn"}]
        set ::noAt [expr {$place eq "top"}]
        lappend statements [gen int 4]
        set ::noAt 0
        lappend places $place
    }
    return [list $modules $statements $places]
}

proc moduleText {fns} {
    set text "import types\n\n"
    if {$::contexts} {
        set text "import types\nimport env\nimport cx\n\n"
    }
    foreach t $fns {
        lassign $t name params result body requirement
        set ps {}
        set i 0
        foreach p $params {
            lappend ps "p$i: [dict get $::typeText $p]"
            incr i
        }
        if {$requirement ne ""} {
            lappend ps [dict get $::requirementParam $requirement]
        }
        append text "fn ${name}([join $ps {, }]) -> [dict get $::typeText $result]:\n    $body\n\n"
    }
    return $text
}

set typesText "struct Bag:\n    n: int\n\nstruct Box:\n    v: int\n"

# The files of a program whose statements are TEXTS (int expressions), each
# its own function's body or, at PLACES' top (-contexts 1), top-level code
# after the installations ENVIRONMENT: {FILES ANCHORS}, ANCHORS each text's
# {LINE COLUMN} in main.bot (1-based, the column of its first character).
proc programFiles {modules texts {places {}} {environment {}}} {
    set files [dict create types.bot $::typesText]
    set head "import std::list\nimport std::str\nimport types\n"
    if {$::contexts} {
        set files [dict merge $files $::contextFiles]
        append head "import ca\nimport cb\nimport cx\n"
    }
    dict for {m fns} $modules {
        dict set files $m.bot [moduleText $fns]
        append head "import $m\n"
    }
    set lines [split "$head" \n]
    if {$::contexts} {
        lappend lines "fn as_int(n: int) -> int:" "    n" ""
    }
    set anchors {}
    set tail {}
    set sum {}
    set i 0
    foreach text $texts {
        set place [expr {$places eq {} ? "fn" : [lindex $places $i]}]
        if {$place eq "fn"} {
            lappend lines "fn t${i}() -> int errors IndexNotFound:"
            lappend anchors [list [expr {[llength $lines] + 1}] 5]
            lappend lines "    $text" ""
            lappend tail [list "r$i = t${i}():" "    on IndexNotFound:" "        -1"]
        } else {
            lappend tail [list "r$i = as_int($text)"]
            lappend anchors [list top [string length "r$i = as_int("]]
        }
        lappend sum r$i
        incr i
    }
    foreach c $environment {
        lappend lines "with context ${c}::[string toupper $c] {z: 0}"
    }
    set i 0
    foreach t $tail {
        if {[lindex $anchors $i 0] eq "top"} {
            lset anchors $i [list [expr {[llength $lines] + 1}] [expr {[lindex $anchors $i 1] + 1}]]
        }
        lappend lines {*}$t
        incr i
    }
    lappend lines [join $sum { + }] ""
    dict set files main.bot [join $lines \n]
    return [list $files $anchors]
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
    if {[dict exists $hir traitSource]} {
        # (A trait program -- with -contexts 1, one requiring env::Env -- is
        # the monomorphized build; its method calls and decisions are those
        # of the checked source.)
        set hir [dict get $hir traitSource]
    }
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

# Checks one program, its statements at PLACES, under the installations
# ENVIRONMENT: {ok "" FILES} or {bad REASON FILES} (FILES the program's, which
# -dump prints); updates the counters.
proc check {modules statements places environment tag} {
    set predictions {}
    set texts {}
    set namesOf {}
    set accepted 1
    foreach tree $statements {
        set counter 0
        set p [predict $tree $modules counter]
        set counter 0
        lassign [render $tree counter] text names
        lappend texts $text
        lappend namesOf $names
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
    }
    lassign [programFiles $modules $texts $places $environment] files anchors
    set positions {}
    set s 0
    foreach names $namesOf anchor $anchors {
        lassign $anchor line column
        foreach n $names {
            lassign $n id offset
            dict set positions [list $line [expr {$column + $offset}]] [list $s $id]
        }
        incr s
    }
    # The obligations (-contexts 1): when every call is decided, each decided
    # callee's context requirement is checked at its top-level call against
    # the installations; the program is rejected exactly when one fails, with
    # exactly the failed obligations' kinds. The decisions above do not read
    # them.
    set obligations {}
    if {$::contexts && $accepted} {
        foreach tree $statements outcomes $predictions {
            dict for {id outcome} [SingleDisplays $tree $modules [FullOutcomes $outcomes]] {
                set kind [obligation [requirementOf [lindex $outcome 1] $modules] $environment]
                if {$kind ne ""} {
                    lappend obligations $kind
                }
            }
        }
        set obligations [lsort -unique $obligations]
        if {$obligations ne {}} {
            set accepted 0
            incr ::obligationPrograms
        }
    }
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
    if {$obligations ne {}} {
        set kinds [lsort -unique [lmap d $diagnostics {dict get $d kind}]]
        if {$kinds ne $obligations} {
            return [list bad "$tag: predicted the obligations $obligations under {$environment}, compiler: $kinds" $files]
        }
    }
    if {$accepted} {
        incr ::acceptedPrograms
        set qtexts {}
        foreach tree $statements outcomes $predictions {
            set counter 0
            lappend qtexts [qualified $tree [SingleDisplays $tree $modules [FullOutcomes $outcomes]] counter]
        }
        lassign [compileFiles [lindex [programFiles $modules $qtexts $places $environment] 0]] qstatus qhir
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
    return [list ok "" $files]
}

# OUTCOMES (a statement's predictions, every call decided or single ok) with
# each single-candidate call's display left to fill in (SingleDisplays).
proc FullOutcomes {outcomes} {
    set full [dict create]
    dict for {id outcome} $outcomes {
        if {$outcome eq {single ok}} {
            # The one candidate: recompute its display.
            dict set full $id [list decided ""]
        } else {
            dict set full $id $outcome
        }
    }
    return $full
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
set ::obligationPrograms 0
set disagreements 0
if {$only ne ""} {
    set first $only
    set seeds 1
}
for {set seed $first} {$seed < $first + $seeds} {incr seed} {
    expr {srand($seed)}
    lassign [program] modules statements places
    incr programs
    foreach {tag mods} [list as-written $modules renamed [renamed $modules]] {
        # (-contexts 1: each check under installations of its own, which
        # change no decision.)
        set environment [expr {$contexts ? [pick $::environments] : {}}]
        set result [check $mods $statements $places $environment "seed $seed ($tag[expr {$contexts ? ", installed {$environment}" : ""}])"]
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
puts "method-resolution-oracle seeds $seeds programs $programs calls $::calls accepted $::acceptedPrograms rejected $::rejectedPrograms[expr {$contexts ? " (by an obligation $::obligationPrograms)" : ""}] disagreements $disagreements"
exit [expr {$disagreements > 0}]
