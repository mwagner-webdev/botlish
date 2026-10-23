#!/usr/bin/env tclsh9.0
# fuzz.tcl -- bounded randomized check of the method-call kind filter
# (METHOD-DECISION-FILTER.md, hir/methodfilter.tcl) against the exact
# decision (hir::DecideMethodCalls).
#
#   tclsh9.0 audit/method-filter/tools/fuzz.tcl ?SEEDS? ?FIRST-SEED? ?-dump 1?
#
# Each program is compiled twice, from the same text: with the filter off
# (hir::methodFilter 0: the exact decision alone), and with the filter on under
# its audit (hir::methodFilterAudit 1: whenever the filter certifies a
# decision the exact decision is made as well, and the compilation fails
# unless both decided the same calls the same way and gave the same HIR). The
# two compilations must then have the same outcome: the same error, or the
# same diagnostics, decided calls and HIR text. The programs are random in
#
#   receivers   parameters of kinds List, String, MutableArray, MutableVector
#               (typed), an untyped parameter narrowed by an explicit
#               qualified call before its method calls, one never narrowed
#               (ambiguous), an Int (no applicable method);
#   calls       length, at, get on those receivers, chained through lists of
#               lists and through the values they return, so that one call's
#               receiver is another call's result and, in the narrowing form,
#               the same binding is a receiver after an earlier call;
#   structs     receivers of named structs (typed parameters, locals bound to
#               constructions, constructions, fields), from three modules of a
#               private library: two Box declarations with the same fields,
#               applications of a Pair[A, B] (imprinted and concrete
#               parameters over it), a Cell[T]; and MutableMap and MutableSet
#               receivers; calls of size, weight, tag (untyped in one module:
#               an inferred contract) and peek, which the modules declare
#               over different structs, and length;
#   shape       one to three functions, two to five statements each, which
#               call one another.
#
# The summary line is
#
#   method-filter-fuzz seeds N programs P certified C fallbacks F (accepted
#       programs: A) rejected R evictions E builds exact X filter Y disagreements D
#
# (X and Y are the whole-program builds of the compilations with the filter
# off and on, without the audit.)
#
# and the exit status is 1 if D is not zero. Every program is seeded by its
# own number: `-seed-only S -dump 1` replays one.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set args $argv
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
interp recursionlimit {} 100000

set seeds 100
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

# The private library: a copy of the standard library beside three modules
# whose functions take named structs (removed at the end). None defines a
# function named like a method of the other receivers (length, at, get): a
# struct-parameter `length` beside std::list::length makes the exact
# decision reject `xs.at(0).length()`, whose outer call, standing at that
# candidate in a trial, rejects the inner call's result at the inner call's
# own node, which hir::MethodCallProblems counts as the inner call's problem
# (a defect of the exact decision, not of the filter, which decides the
# chain correctly: METHOD-DECISION-FILTER.md, "A defect of the exact
# decision").
set library [file tempdir botlish-method-filter-fuzz]
foreach entry [glob -nocomplain -directory $::core::libraryDir *] {
    file copy -force $entry $library
}
set ::core::libraryDir $library
foreach {name text} {
    fza "struct Box:\n    v: int\n\nstruct Pair\[A, B\]:\n    a: A\n    b: B\n\nfn size(b: Box) -> int:\n    b.v\n\nfn weight(p: Pair\[A, B\]) -> int:\n    1\n\nfn tag(x) -> int:\n    size(x)\n\nfn peek(b: Box, k: int) -> int:\n    b.v + k\n"
    fzb "import std::fza\n\nstruct Box:\n    v: int\n\nstruct Cell\[T\]:\n    t: T\n\nfn size(b: Box) -> int:\n    b.v + 1\n\nfn weight(p: std::fza::Pair\[int, int\]) -> int:\n    2\n\nfn tag(b: Box) -> int:\n    b.v\n\nfn peek(c: Cell\[T\], k: int) -> int:\n    k\n"
    fzc "import std::fzb\n\nfn size(c: std::fzb::Cell\[T\]) -> int:\n    3\n"
} {
    set f [open [file join $library $name.bot] w]
    fconfigure $f -encoding utf-8
    puts -nonewline $f [subst -nocommands -novariables $text]
    close $f
}

proc pick {list} { lindex $list [expr {int(rand() * [llength $list])}] }
proc chance {p} { expr {rand() < $p} }

# ---------------------------------------------------------------------------
# Expressions by type. A type is int, str, ints (List[int]), strs (List[str]),
# nested (List[List[int]]), marr (MutableArray[int]) or mvec (MutableVector[int]).

set typeText {int int str str ints List[int] strs List[str] nested List[List[int]]
    marr MutableArray[int] mvec MutableVector[int]}
set ::needsHandler 0

proc literal {type} {
    switch -- $type {
        int { return [expr {int(rand() * 20)}] }
        str { return "\"[pick {a bb ccc dddd}]\"" }
        ints { return "\[[join [lmap i [lrepeat [expr {1 + int(rand() * 4)}] x] {expr {int(rand() * 9)}}] {, }]\]" }
        strs { return "\[\"x\", \"yy\", \"zzz\"\]" }
        nested { return "\[\[1, 2\], \[3\], \[4, 5, 6\]\]" }
        marr { return "std::mutable_array::create(3, [expr {int(rand() * 9)}])" }
        mvec { return "std::mutable_vector::from_list(\[1, 2, 3\])" }
    }
}

# An expression of TYPE over ENV (a list of {name type}), at most DEPTH deep.
proc gen {type env depth} {
    set vars [lmap v $env {if {[lindex $v 1] ne $type} continue; lindex $v 0}]
    if {$depth <= 0 || [chance 0.25]} {
        if {$vars ne "" && [chance 0.7]} { return [pick $vars] }
        return [literal $type]
    }
    switch -- $type {
        int {
            switch -- [expr {int(rand() * 6)}] {
                0 { return "[gen str $env [expr {$depth - 1}]].length()" }
                1 { return "[gen [pick {ints strs nested mvec}] $env [expr {$depth - 1}]].length()" }
                2 { set ::needsHandler 1; return "[gen [pick {ints marr mvec}] $env [expr {$depth - 1}]].at([expr {int(rand() * 3)}])" }
                3 { return "[gen [pick {ints marr}] $env [expr {$depth - 1}]].get([expr {int(rand() * 5)}], 0)" }
                4 { return "([gen int $env [expr {$depth - 1}]] + [gen int $env [expr {$depth - 1}]])" }
                5 { return [literal int] }
            }
        }
        str {
            switch -- [expr {int(rand() * 2)}] {
                0 { set ::needsHandler 1; return "[gen strs $env [expr {$depth - 1}]].at([expr {int(rand() * 3)}])" }
                1 { return "[gen strs $env [expr {$depth - 1}]].get([expr {int(rand() * 5)}], \"-\")" }
            }
        }
        ints {
            if {[chance 0.5]} {
                set ::needsHandler 1
                return "[gen nested $env [expr {$depth - 1}]].at([expr {int(rand() * 3)}])"
            }
            return "[gen nested $env [expr {$depth - 1}]].get([expr {int(rand() * 5)}], \[0\])"
        }
        default { return [literal $type] }
    }
}
# ---------------------------------------------------------------------------
# Programs

proc functionText {name paramTypes callable} {
    global typeText
    set env {}
    set params {}
    set i 0
    foreach t $paramTypes {
        lappend params "p$i: [dict get $typeText $t]"
        lappend env [list p$i $t]
        incr i
    }
    set ::needsHandler 0
    set lines {}
    set k 0
    foreach t [lrepeat [expr {2 + int(rand() * 4)}] x] {
        set type [pick {int int int str ints}]
        set expr [gen $type $env 3]
        lappend lines "    v$k = $expr"
        lappend env [list v$k $type]
        incr k
    }
    set ints [lmap v $env {if {[lindex $v 1] ne "int"} continue; lindex $v 0}]
    set sum [expr {$ints eq "" ? "0" : [join $ints { + }]}]
    set handled $::needsHandler
    set result $sum
    # Calls of the functions defined before this one: their results are ints.
    foreach c $callable {
        lassign $c cname ctypes chandled
        set args [lmap t $ctypes {gen $t $env 1}]
        set call "${cname}([join $args {, }])"
        if {$chandled} {
            set handled 1
        }
        set result "$result + $call"
    }
    set errors [expr {$handled ? " errors IndexNotFound" : ""}]
    return [list "fn ${name}([join $params {, }]) -> int$errors:\n[join $lines \n]\n    $result\n" $handled]
}

# A function whose statements are a run of method calls on the same binding (a
# parameter of a kind, or a value it was bound to): each call's default
# candidate narrows the binding for the calls after it.
proc chainText {name} {
    set kind [pick {marr mvec ints}]
    set typeName [dict get {marr MutableArray[int] mvec MutableVector[int] ints List[int]} $kind]
    set lines {}
    set names {}
    set n [expr {2 + int(rand() * 9)}]
    set source [pick {param param local}]
    set body {}
    if {$source eq "local"} {
        set params ""
        set recv a
        switch -- $kind {
            marr { lappend body "    a = std::mutable_array::create(4, 1)" }
            mvec { lappend body "    a = std::mutable_vector::from_list(\[1, 2, 3, 4\])" }
            ints { lappend body "    a = \[1, 2, 3, 4\]" }
        }
        set callArgs ""
    } else {
        set params "a: $typeName"
        set recv a
        set callArgs [literal $kind]
    }
    set handled 0
    for {set i 0} {$i < $n} {incr i} {
        set m [pick {at get length}]
        if {$m eq "get" && $kind eq "mvec"} { set m at }
        switch -- $m {
            at { set handled 1; set call "$recv.at([expr {int(rand() * 3)}])" }
            get { set call "$recv.get([expr {int(rand() * 3)}], 0)" }
            length {
                if {$kind eq "marr"} { set call "$recv.at(0)"; set handled 1 } else { set call "$recv.length()" }
            }
        }
        lappend body "    c$i = $call"
        lappend names c$i
    }
    lappend body "    [join $names { + }]"
    set errors [expr {$handled ? " errors IndexNotFound" : ""}]
    return [list "fn ${name}($params) -> int$errors:\n[join $body \n]\n" $callArgs $handled]
}

# A function with an untyped parameter. FORM: narrowed (a qualified call
# narrows it before its method calls), ambiguous (never narrowed), wrong (a
# typed Int receiver of a method no Int has).
proc untypedText {form} {
    switch -- $form {
        narrowed {
            set k [pick {list str}]
            if {$k eq "list"} {
                return [list "fn u(x) -> int errors IndexNotFound:\n    n = std::list::length(x)\n    a = x.at(0)\n    b = x.length()\n    n + b + a\n" "\[5, 6, 7\]" 1]
            }
            return [list "fn u(x) -> int:\n    n = std::str::length(x)\n    b = x.length()\n    n + b\n" "\"abc\"" 0]
        }
        ambiguous {
            return [list "fn u(x) -> int:\n    x.length()\n" "\[1, 2\]" 0]
        }
        wrong {
            set m [pick {length at}]
            if {$m eq "length"} {
                return [list "fn u(k: int) -> int:\n    k.length()\n" 3 0]
            }
            return [list "fn u(k: int) -> int errors IndexNotFound:\n    k.at(0)\n" 3 1]
        }
    }
}

# Named-struct receivers: tag -> {type text, a construction}. COLLECTIONS adds
# MutableMap and MutableSet ones.
set nominalReceivers {
    abox {{std::fza::Box} {std::fza::Box {v: 2}}}
    bbox {{std::fzb::Box} {std::fzb::Box {v: 3}}}
    pairis {{std::fza::Pair[int, str]} {std::fza::Pair[int, str] {a: 1, b: "x"}}}
    pairii {{std::fza::Pair[int, int]} {std::fza::Pair[int, int] {a: 1, b: 2}}}
    pairbox {{std::fza::Pair[std::fzb::Box, int]} {std::fza::Pair[std::fzb::Box, int] {a: std::fzb::Box {v: 4}, b: 5}}}
    cell {{std::fzb::Cell[int]} {std::fzb::Cell[int] {t: 6}}}
}
set collectionReceivers {
    map {{std::mutable_map::MutableMap[int, int]} {std::mutable_map::create[int, int]()}}
    set {{std::mutable_set::MutableSet[int]} {std::mutable_set::create[int]()}}
}

# Receiver tag -> the calls some candidate fits (the others fit none: a
# function made only of those is rejected, so they are drawn less often).
set nominalCalls {
    abox {size() tag() peek(1)} bbox {size() tag()} pairis weight() pairii weight()
    pairbox weight() cell {peek(1) size()} map length() set length()
}

# A function of method calls on named-struct receivers: {TEXT ARGS}, ARGS
# the constructions its parameters are called with.
proc nominalText {name collections} {
    set receivers $::nominalReceivers
    if {$collections} {
        set receivers [dict merge $receivers $::collectionReceivers]
    }
    set params {}
    set args {}
    set body {}
    set terms {}
    set n [expr {2 + int(rand() * 4)}]
    for {set i 0} {$i < $n} {incr i} {
        set tag [pick [dict keys $receivers]]
        lassign [dict get $receivers $tag] type construction
        switch -- [pick {param param local inline field}] {
            param {
                lappend params "r$i: $type"
                lappend args $construction
                set recv r$i
            }
            local {
                lappend body "    r$i = $construction"
                set recv r$i
            }
            inline {
                set recv $construction
            }
            field {
                lassign [dict get $receivers pairbox] - pairbox
                set recv "${pairbox}.a"
                set tag bbox
            }
        }
        if {[chance 0.85]} {
            set call [pick [dict get $::nominalCalls $tag]]
        } else {
            set call [pick {size() weight() tag() peek(1) length()}]
        }
        lappend body "    c$i = ${recv}.$call"
        lappend terms c$i
    }
    lappend body "    [join $terms { + }]"
    return [list "fn ${name}([join $params {, }]) -> int:\n[join $body \n]\n" $args]
}

proc program {} {
    set fns {}
    set callable {}
    set n [expr {1 + int(rand() * 3)}]
    for {set i 0} {$i < $n} {incr i} {
        set types [lmap j [lrepeat [expr {1 + int(rand() * 4)}] x] {pick {int str ints strs nested marr mvec}}]
        lassign [functionText f$i $types $callable] text handled
        lappend fns $text
        lappend callable [list f$i $types $handled]
    }
    set untyped ""
    set uform ""
    if {[chance 0.35]} {
        set uform [pick {narrowed narrowed ambiguous wrong}]
        lassign [untypedText $uform] utext uarg uhandled
        lappend fns $utext
    }
    set chain ""
    if {[chance 0.6]} {
        lassign [chainText ch] ctext cargs chandled
        lappend fns $ctext
        set chain [list $cargs $chandled]
    }
    set nominal ""
    set collections 0
    if {[chance 0.5]} {
        set collections [chance 0.3]
        lassign [nominalText nm $collections] ntext nargs
        lappend fns $ntext
        set nominal [list $nargs]
    }
    # The entry: call the last typed function (with its arguments), the
    # untyped one, the chain and the named-struct one; a function that can
    # fail IndexNotFound is called under a handler.
    lassign [lindex $callable end] name types handled
    set args [lmap t $types {gen $t {} 1}]
    set lines {}
    set sum {}
    foreach {var call can} [list r "${name}([join $args {, }])" $handled] {
        lappend lines [entryLine $var $call $can]
        lappend sum $var
    }
    if {$uform ne ""} {
        lappend lines [entryLine u1 "u($uarg)" $uhandled]
        lappend sum u1
    }
    if {$chain ne ""} {
        lassign $chain cargs chandled
        lappend lines [entryLine c1 "ch($cargs)" $chandled]
        lappend sum c1
    }
    set head "import std::list\nimport std::str\nimport std::mutable_array\nimport std::mutable_vector\n"
    if {$nominal ne ""} {
        lappend lines [entryLine n1 "nm([join [lindex $nominal 0] {, }])" 0]
        lappend sum n1
        append head "import std::fza\nimport std::fzb\nimport std::fzc\n"
        if {$collections} {
            append head "import std::mutable_map\nimport std::mutable_set\n"
        }
    }
    append head "\n"
    return "$head[join $fns \n]\n[join $lines \n]\n[join $sum { + }]\n"
}

proc entryLine {var call handled} {
    if {$handled} {
        return "$var = $call:\n    on IndexNotFound:\n        -1"
    }
    return "$var = $call"
}

# ---------------------------------------------------------------------------
# Running

proc compileUnder {filter audit text} {
    set saved [list $hir::methodFilter $hir::methodFilterAudit]
    set hir::methodFilter $filter
    set hir::methodFilterAudit $audit
    set before [hir::BuildStats]
    try {
        if {[catch {surface::compile $text -strict 0 -warnings off} hir options]} {
            set result [dict create error [string range $hir 0 300] hir ""]
        } else {
            set diags [lmap d [dict get $hir diagnostics] {list [dict get $d kind] [dict get $d message]}]
            set decided [expr {[dict exists $hir methodDecided] ? [lsort -stride 2 [dict get $hir methodDecided]] : {}}]
            set result [dict create error "" diagnostics $diags decided $decided text [hir::format $hir] hir $hir]
        }
    } finally {
        lassign $saved hir::methodFilter hir::methodFilterAudit
    }
    set after [hir::BuildStats]
    dict set result builds [expr {[dict get $after builds] - [dict get $before builds]}]
    foreach c {methodFiltered methodFilterAbandoned methodFilterEvicted} {
        dict set result $c [expr {[dict get $after $c] - [dict get $before $c]}]
    }
    return $result
}

set programs 0
set certified 0
set fallbacks 0
set rejected 0
set exactBuilds 0
set filterBuilds 0
set disagreements 0
set wasted 0
set evictions 0
set kinds [dict create]
if {$only ne ""} {
    set first $only
    set seeds 1
}
for {set seed $first} {$seed < $first + $seeds} {incr seed} {
    expr {srand($seed)}
    set text [program]
    incr programs
    if {$dump} {
        puts "---- seed $seed\n$text"
    }
    set exact [compileUnder 0 0 $text]
    set filtered [compileUnder 1 1 $text]
    # (The builds the filter takes, without the audit's second decision.)
    set cheap [compileUnder 1 0 $text]
    incr exactBuilds [dict get $exact builds]
    incr filterBuilds [dict get $cheap builds]
    if {[dict get $cheap methodFiltered] > 0} { incr certified }
    if {[dict get $cheap methodFilterEvicted] > 0} {
        incr evictions [dict get $cheap methodFilterEvicted]
        if {$dump} { puts "  (the filter took back [dict get $cheap methodFilterEvicted] decision(s))" } else { puts "seed $seed: evictions [dict get $cheap methodFilterEvicted]" }
    }
    if {[dict get $cheap methodFilterAbandoned] > 0} {
        incr fallbacks
        if {[dict get $exact error] eq "" && [dict get $exact diagnostics] eq ""} {
            incr wasted
            if {$dump} { puts "  (abandoned on a program the exact decision accepts)" }
        }
    }
    if {[dict get $exact error] ne "" || [dict get $exact diagnostics] ne ""} {
        incr rejected
        if {[dict get $exact error] ne ""} {
            dict incr kinds ERROR
        } else {
            foreach d [lsort -unique [lmap d [dict get $exact diagnostics] {lindex $d 0}]] { dict incr kinds $d }
        }
    }
    set bad ""
    if {[dict get $filtered error] ne [dict get $exact error]} {
        set bad "error differs:\n  filter: [dict get $filtered error]\n  exact:  [dict get $exact error]"
    } elseif {[dict get $exact error] eq ""} {
        foreach field {diagnostics decided text} {
            if {[dict get $filtered $field] ne [dict get $exact $field]} {
                set bad "$field differs"
                break
            }
        }
    }
    if {$bad ne ""} {
        incr disagreements
        puts "DISAGREE seed $seed: $bad"
        if {!$dump} { puts "$text" }
    }
}
file delete -force $library
puts "method-filter-fuzz seeds $seeds programs $programs certified $certified fallbacks $fallbacks (accepted programs: $wasted) rejected $rejected evictions $evictions builds exact $exactBuilds filter $filterBuilds disagreements $disagreements"
puts "rejections by kind: $kinds"
exit [expr {$disagreements > 0}]
