#!/usr/bin/env tclsh9.0
# fuzz.tcl -- parameterized structs and trait-constrained type slots against
# an independent model (TRAIT-CONSTRAINED-IMPRINTED-TYPES.md, "Fuzzing").
#
#   tclsh9.0 audit/trait-constrained-types/tools/fuzz.tcl ?-n N? ?-seed S?
#       ?-dump 1? ?-backends LIST? ?-gc-stress 0|1?
#
# Each program declares one to three parameterized structs of one to three
# slots, each slot unconstrained, `satisfies Hashable` or `satisfies
# Printable` (an ordinary trait of a module, implemented by two witness
# structs of two other modules; a third struct implements nothing). A field
# holds a slot bare, in a List, in a MutableArray, or an application of an
# earlier struct to the struct's own slots and concrete types. For every
# struct the program declares functions whose variables come from matching
# its application -- a projection of each bare field, the public hash of a
# Hashable slot's field, the trait operation of a Printable slot's field, a
# comparison of a field with a second parameter of the slot's variable, and
# a factory whose constraint comes from its result -- and observes them on
# values of concrete applications, constructed with the application written
# or inferred from the field values.
#
# The model shares no code with the compiler: a type is a term the
# generator builds (int, str, bool, fn, {list T}, {marr T}, {w W}, {app S
# ARGS}), its slot bindings are the generator's, and its predicates are its
# own -- Hashable when every component has total equality and a hash (no
# function, no MutableArray), Printable for the two witnesses only, a slot
# variable satisfying exactly its declared trait -- so it knows each
# observation's value (a projection compares equal to the value it built, a
# hash to the hash of the same literal, a trait operation returns the
# witness's text) and each probe's verdict:
#
#   * a declaration whose nested application's constrained slot is held by
#     a variable that does not declare the trait, or by a type that does not
#     satisfy it: TRAIT-NOT-SATISFIED;
#   * a function or construction applying a struct to a type that does not
#     satisfy a slot's trait (a function, a MutableArray, any, a struct that
#     holds one, a non-witness): TRAIT-NOT-SATISFIED; the same application
#     to a satisfying type: accepted, and runs;
#   * the wrong number of type arguments: TYPE;
#   * a second occurrence of an established variable given another type:
#     TYPE (rigid imprinting);
#   * a construction whose values establish no type for a slot: IMPRINT;
#   * a factory whose result application the binding makes invalid:
#     TRAIT-NOT-SATISFIED.
#
# Every backend of BACKENDS must give exactly the model's value for the main
# program, and every probe the model's verdict (its first diagnostic's
# kind). With -gc-stress 1 the main program runs again on cranelift with a
# collection at every allocation site.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set options [dict create -n 20 -seed 1 -dump 0 -backends {interp compile cranelift-generic cranelift} -gc-stress 0]
foreach {option value} $argv {
    if {![dict exists $options $option]} {
        error "fuzz.tcl: unknown option $option"
    }
    dict set options $option $value
}
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]

# A private library: the standard one plus the trait and its witnesses.
set ::fuzzLibrary [file tempdir botlish-tct-fuzz]
foreach entry [glob -nocomplain -directory $::core::libraryDir *] {
    file copy -force $entry $::fuzzLibrary
}
set ::core::libraryDir $::fuzzLibrary
foreach {path text} {
    printable.bot {trait Printable:
    fn describe(value: Printable) -> str
}
    wit1.bot {struct W1:
    name: str

fn describe(w: W1) -> str:
    w.name
}
    wit2.bot {struct W2:
    tag: str
    n: int

fn describe(w: W2) -> str:
    w.tag
}
    nowit.bot {struct N0:
    name: str
}
} {
    set channel [open [file join $::fuzzLibrary $path] w]
    fconfigure $channel -encoding utf-8 -translation lf
    puts -nonewline $channel $text
    close $channel
}

set ::header {import std::wit1
import std::wit2
import std::nowit
import std::mutable_array
import type std::printable::Printable
}

# ---------------------------------------------------------------------------
# Deterministic choices

proc Rand {n} {
    global seedState
    set seedState [expr {($seedState * 1103515245 + 12345) % 2147483648}]
    return [expr {($seedState / 65536) % $n}]
}

proc Pick {list} {
    return [lindex $list [Rand [llength $list]]]
}

# ---------------------------------------------------------------------------
# The model
#
# A type is int | str | bool | fn | marrint | {list T} | {w W1|W2|N0} |
# {app S {ARG ...}} | {var X} (a slot inside a declaration). A struct is
# {slots {X ...} constraints {X C ...} fields {F FORM ...}}, a FORM one of
# {bare X}, {list X}, {marr X}, {nested S2 {ARGTERM ...}} (ARGTERM a type,
# {var X} or {list {var X}}).

# 1 if every value of TYPE has total equality and a hash (STRUCTS: SLOTS
# constraints of the declaration a {var X} belongs to).
proc Hashable {type {constraints {}}} {
    switch -- [lindex $type 0] {
        int - str - bool { return 1 }
        fn - marrint - marr - any { return 0 }
        list { return [Hashable [lindex $type 1] $constraints] }
        w { return 1 }
        var { return [expr {[dict getdef $constraints [lindex $type 1] ""] eq "Hashable"}] }
        app {
            lassign $type - s args
            foreach {f t} [FieldTypes $s $args] {
                if {![Hashable $t $constraints]} { return 0 }
            }
            return 1
        }
    }
    error "Hashable: $type"
}

proc Printable {type {constraints {}}} {
    switch -- [lindex $type 0] {
        w { return [expr {[lindex $type 1] in {W1 W2}}] }
        var { return [expr {[dict getdef $constraints [lindex $type 1] ""] eq "Printable"}] }
    }
    return 0
}

proc Satisfies {type trait {constraints {}}} {
    if {$trait eq ""} { return 1 }
    return [$trait $type $constraints]
}

# The field types of struct S applied to TARGS, slot variables replaced.
proc FieldTypes {s targs} {
    set st [dict get $::structs $s]
    set binding [dict create]
    foreach x [dict get $st slots] a $targs {
        dict set binding $x $a
    }
    set result {}
    foreach {f form} [dict get $st fields] {
        lappend result $f [FormType $form $binding]
    }
    return $result
}

proc Subst {term binding} {
    switch -- [lindex $term 0] {
        var { return [dict get $binding [lindex $term 1]] }
        list { return [list list [Subst [lindex $term 1] $binding]] }
        app { return [list app [lindex $term 1] [lmap a [lindex $term 2] {Subst $a $binding}]] }
    }
    return $term
}

proc FormType {form binding} {
    lassign $form kind x
    switch -- $kind {
        bare { return [dict get $binding $x] }
        list { return [list list [dict get $binding $x]] }
        marr {
            set t [dict get $binding $x]
            return [list marr $t]
        }
        nested { return [list app $x [lmap a [lindex $form 2] {Subst $a $binding}]] }
    }
}

# The source text of TYPE.
proc Text {type} {
    switch -- [lindex $type 0] {
        int - str - bool { return [lindex $type 0] }
        fn { return "Fn{args: \[int\], return: int, errors: \[\]}" }
        marrint { return "MutableArray\[int\]" }
        list { return "List\[[Text [lindex $type 1]]\]" }
        marr { return "MutableArray\[[Text [lindex $type 1]]\]" }
        w { return "std::[dict get {W1 wit1 W2 wit2 N0 nowit} [lindex $type 1]]::[lindex $type 1]" }
        var { return [lindex $type 1] }
        any { return any }
        app { return "[lindex $type 1]\[[join [lmap a [lindex $type 2] {Text $a}] {, }]\]" }
    }
    error "Text: $type"
}

# {EXPR DESC}: a value of the concrete TYPE (no function, no MutableArray at
# top level), DESC the model's description of it: what an equal value's
# expression is, and what describe() returns of a witness.
proc Value {type {depth 0}} {
    switch -- [lindex $type 0] {
        int { set v [expr {[Rand 2001] - 1000}]; return [list $v $v] }
        str { set v "s[Rand 1000]"; return [list "\"$v\"" "\"$v\""] }
        bool { set v [Pick {true false}]; return [list $v $v] }
        list {
            set items {}
            foreach i [lrange {1 2 3} 0 [Rand 3]] {
                lappend items [lindex [Value [lindex $type 1] [expr {$depth + 1}]] 0]
            }
            set e "\[[join $items {, }]\]"
            return [list $e $e]
        }
        w {
            set n "w[Rand 1000]"
            switch -- [lindex $type 1] {
                W1 { set e "std::wit1::W1 {name: \"$n\"}" }
                W2 { set e "std::wit2::W2 {tag: \"$n\", n: [Rand 9]}" }
                N0 { set e "std::nowit::N0 {name: \"$n\"}" }
            }
            return [list $e [list witness $n $e]]
        }
        app {
            lassign $type - s args
            set fields {}
            foreach {f t} [FieldTypes $s $args] {
                lappend fields "$f: [lindex [FieldValue $t $depth] 0]"
            }
            # (Written or inferred: every slot is held by a non-empty value
            # of its own type, so the field values establish it.)
            set head [expr {[Rand 2] ? [Text $type] : $s}]
            set e "$head {[join $fields {, }]}"
            return [list $e $e]
        }
    }
    error "Value: $type"
}

proc FieldValue {type depth} {
    if {[lindex $type 0] eq "marr"} {
        set inner [Value [lindex $type 1] [expr {$depth + 1}]]
        return [list "std::mutable_array::create(1, [lindex $inner 0])" [lindex $inner 1]]
    }
    return [Value $type [expr {$depth + 1}]]
}

# A concrete type for a slot constrained by TRAIT ("" for none), at most
# DEPTH applications deep, drawn from the program's earlier structs.
proc SlotArg {trait depth} {
    while 1 {
        set t [Pick {int str bool {list int} {list str} {w W1} {w W2} {w N0} app app}]
        if {$t eq "app"} {
            if {$depth <= 0 || [dict size $::structs] == 0} continue
            set s [Pick [dict keys $::structs]]
            set args [lmap x [dict get $::structs $s slots] {
                SlotArg [dict getdef [dict get $::structs $s constraints] $x ""] [expr {$depth - 1}]
            }]
            set t [list app $s $args]
        }
        if {[Satisfies $t $trait]} {
            return $t
        }
    }
}

# A type that does NOT satisfy TRAIT (for a probe).
proc BadArg {trait} {
    if {$trait eq "Hashable"} {
        return [Pick {fn marrint any {list fn}}]
    }
    return [Pick {int str {w N0} {list {w W1}}}]
}

# ---------------------------------------------------------------------------
# Programs

# Declares a random struct NAME over the structs declared so far (the
# global ::structs), returns its declaration text.
proc DeclareStruct {name} {
    set n [expr {1 + [Rand 3]}]
    set slots [lrange {A B C} 0 [expr {$n - 1}]]
    set constraints [dict create]
    foreach x $slots {
        dict set constraints $x [Pick {"" "" Hashable Printable}]
    }
    set fields {}
    set i 0
    foreach x $slots {
        lappend fields f$i [list [Pick {bare bare list marr}] $x]
        incr i
    }
    if {[dict size $::structs] > 0 && [Rand 2]} {
        set s2 [Pick [dict keys $::structs]]
        set args {}
        foreach y [dict get $::structs $s2 slots] {
            set need [dict getdef [dict get $::structs $s2 constraints] $y ""]
            # An argument the declaration can state the obligation for: one
            # of its own slots whose trait is what the nested slot needs (or
            # a List of one, for Hashable), or a satisfying concrete type.
            set mine [lmap x $slots {if {[dict get $constraints $x] eq $need || $need eq ""} {set x} else continue}]
            if {$mine ne {} && [Rand 2]} {
                set x [Pick $mine]
                if {$need eq "Hashable" && [Rand 2]} {
                    lappend args [list list [list var $x]]
                } else {
                    lappend args [list var $x]
                }
            } else {
                lappend args [SlotArg $need 0]
            }
        }
        lappend fields nest [list nested $s2 $args]
    }
    dict set ::structs $name [dict create slots $slots constraints $constraints fields $fields]
    return [DeclText $name]
}

proc DeclText {name} {
    set st [dict get $::structs $name]
    set slotTexts [lmap x [dict get $st slots] {
        set c [dict get $st constraints $x]
        if {$c eq ""} { set x } else { string cat $x " satisfies " $c }
    }]
    set lines [list "struct $name\[[join $slotTexts {, }]\]:"]
    foreach {f form} [dict get $st fields] {
        lassign $form kind x
        switch -- $kind {
            bare { set t $x }
            list { set t "List\[$x\]" }
            marr { set t "MutableArray\[$x\]" }
            nested { set t [Text [list app $x [lindex $form 2]]] }
        }
        lappend lines "    $f: $t"
    }
    return "[join $lines \n]\n"
}

# The functions observing struct S: a projection per bare field, a hash per
# Hashable bare field, describe per Printable bare field, a comparison with
# a second occurrence of the slot's variable, a factory.
proc Functions {s} {
    set st [dict get $::structs $s]
    set app "$s\[[join [dict get $st slots] {, }]\]"
    set text ""
    foreach {f form} [dict get $st fields] {
        lassign $form kind x
        if {$kind eq "bare"} {
            append text "fn get_${s}_$f\(v: $app) -> $x:\n    v.$f\n\n"
            append text "fn same_${s}_$f\(v: $app, k: $x) -> bool:\n    v.$f == k\n\n"
            switch -- [dict get $st constraints $x] {
                Hashable { append text "fn hash_${s}_$f\(v: $app) -> int:\n    hash(v.$f)\n\n" }
                Printable { append text "fn desc_${s}_$f\(v: $app) -> str:\n    v.$f.describe()\n\n" }
            }
        }
        if {$kind eq "marr"} {
            append text "fn at_${s}_$f\(v: $app, k: $x) -> bool:\n    e = std::mutable_array::at(v.$f, 0):\n        on IndexNotFound:\n            return false\n    e == k\n\n"
        }
        if {$kind eq "list" && [dict get $st constraints $x] eq "Hashable"} {
            # (List[X] is Hashable exactly when X is.)
            append text "fn hashl_${s}_$f\(v: $app) -> int:\n    hash(v.$f)\n\n"
        }
    }
    return $text
}

# The observations of a value of S applied to TARGS: {EXPR EXPECTED} pairs.
proc Observations {s targs} {
    lassign [Value [list app $s $targs]] value
    set result {}
    set st [dict get $::structs $s]
    foreach {f t} [FieldTypes $s $targs] {f2 form} [dict get $st fields] {
        lassign $form kind x
        switch -- $kind {
            bare {
                set c [dict get $st constraints $x]
                set fieldValue [FieldOf $value $f]
                if {[Hashable $t]} {
                    # (== of values of a type with total equality.)
                    lappend result [list "get_${s}_$f\($value) == $fieldValue" true]
                    lappend result [list "same_${s}_$f\($value, $fieldValue)" true]
                }
                if {$c eq "Hashable"} {
                    lappend result [list "hash_${s}_$f\($value) == hash($fieldValue)" true]
                }
                if {$c eq "Printable"} {
                    lappend result [list "desc_${s}_$f\($value)" "\"[WitnessName $fieldValue]\""]
                }
            }
            list {
                if {[dict get $st constraints $x] eq "Hashable"} {
                    lappend result [list "hashl_${s}_$f\($value) == hash([FieldOf $value $f])" true]
                }
            }
            marr {
                set element [lindex $t 1]
                if {[Hashable $element]} {
                    regexp {^std::mutable_array::create\(1, (.*)\)$} [FieldOf $value $f] -> elementValue
                    lappend result [list "at_${s}_$f\($value, $elementValue)" true]
                }
            }
        }
    }
    return [list $value $result]
}

# The text of field F's value in the construction text VALUE (a top-level
# "F: EXPR" of the outermost braces).
proc FieldOf {value f} {
    set open [string first "\{" $value]
    set body [string range $value [expr {$open + 1}] end-1]
    set depth 0
    set start 0
    set parts {}
    for {set i 0} {$i < [string length $body]} {incr i} {
        set c [string index $body $i]
        if {$c in {( [ \{}} { incr depth } elseif {$c in {) ] \}}} { incr depth -1 } elseif {$c eq "," && $depth == 0} {
            lappend parts [string trim [string range $body $start [expr {$i - 1}]]]
            set start [expr {$i + 1}]
        }
    }
    lappend parts [string trim [string range $body $start end]]
    foreach part $parts {
        if {[string match "$f: *" $part]} {
            return [string range $part [expr {[string length $f] + 2}] end]
        }
    }
    error "FieldOf: $f not in $value"
}

# How many fields of struct ST hold slot X (its own form or a nested
# application's argument).
proc Uses {st x} {
    set n 0
    foreach {f form} [dict get $st fields] {
        if {[lindex $form 0] eq "nested"} {
            if {[string first "var $x" [lindex $form 2]] >= 0} { incr n }
        } elseif {[lindex $form 1] eq $x} {
            incr n
        }
    }
    return $n
}

proc WitnessName {text} {
    regexp {(?:name|tag): "([^"]*)"} $text -> n
    return $n
}

proc Program {number} {
    set ::structs [dict create]
    set decls ""
    set count [expr {1 + [Rand 3]}]
    for {set i 1} {$i <= $count} {incr i} {
        append decls [DeclareStruct S$i]\n
    }
    set fns ""
    dict for {s st} $::structs {
        append fns [Functions $s]
    }
    set observations {}
    set expected {}
    foreach s [dict keys $::structs] {
        foreach k {1 2} {
            set args [lmap x [dict get $::structs $s slots] {SlotArg [dict get $::structs $s constraints $x] 1}]
            lassign [Observations $s $args] value obs
            foreach o $obs {
                lappend observations [lindex $o 0]
                lappend expected [lindex $o 1]
            }
        }
    }
    set text "$::header\n$decls$fns\[\n    [join $observations ",\n    "]\n\]\n"
    return [list $text "\[[join $expected {, }]\]" $decls]
}

# ---------------------------------------------------------------------------
# Probes: {TEXT EXPECTED} with EXPECTED accepted or a diagnostic kind

proc Probes {decls} {
    set probes {}
    foreach s [dict keys $::structs] {
        set st [dict get $::structs $s]
        set slots [dict get $st slots]
        set constraints [dict get $st constraints]
        # A concrete application in a signature: a satisfying or a violating
        # argument for one slot.
        set x [Pick $slots]
        set c [dict get $constraints $x]
        set good [lmap y $slots {SlotArg [dict get $constraints $y] 0}]
        if {$c ne ""} {
            set bad $good
            lset bad [lsearch -exact $slots $x] [BadArg $c]
            lappend probes [list "fn p(v: [Text [list app $s $bad]]) -> int:\n    1\np\n" TRAIT-NOT-SATISFIED]
        }
        lappend probes [list "fn p(v: [Text [list app $s $good]]) -> int:\n    1\n1\n" accepted]
        # Arity.
        if {[llength $slots] > 1} {
            lappend probes [list "fn p(v: [Text [list app $s [lrange $good 1 end]]]) -> int:\n    1\np\n" TYPE]
        } else {
            lappend probes [list "fn p(v: [Text [list app $s [concat $good {int}]]]) -> int:\n    1\np\n" TYPE]
        }
        # A construction of a violating argument (a slot only its bare field
        # holds).
        foreach {f form} [dict get $st fields] {
            lassign $form kind y
            if {$kind eq "bare" && [dict get $constraints $y] eq "Hashable" && [Uses $st $y] == 1} {
                set args $good
                lset args [lsearch -exact $slots $y] fn
                set fields [lmap {ff tt} [FieldTypes $s $args] {
                    if {$tt eq "fn"} { string cat "$ff: twice" } else { string cat "$ff: [lindex [FieldValue $tt 1] 0]" }
                }]
                lappend probes [list "fn twice(n):\n    n\nx = $s {[join $fields {, }]}\n1\n" TRAIT-NOT-SATISFIED]
                break
            }
        }
        # Rigid imprinting: an established variable's second occurrence of
        # another type.
        foreach {f form} [dict get $st fields] {
            lassign $form kind y
            if {$kind eq "bare" && [Hashable [lindex $good [lsearch -exact $slots $y]]]} {
                set i [lsearch -exact $slots $y]
                set t [lindex $good $i]
                set other [expr {$t eq "int" ? "\"other\"" : 12345}]
                lassign [Value [list app $s $good]] value
                lappend probes [list "same_${s}_$f\($value, $other)\n" TYPE]
                break
            }
        }
        # An unestablished slot: the one value that would establish it an
        # empty List.
        if {[llength $slots] == 1 && [llength [dict get $st fields]] == 2 && [lindex [dict get $st fields] 1 0] eq "list"} {
            lappend probes [list "x = $s {f0: \[\]}\n1\n" IMPRINT]
        }
        # A factory whose result application the binding makes invalid.
        if {$c eq "Hashable"} {
            set i [lsearch -exact $slots $x]
            set params [lmap y $slots {string cat "l$y: List\[$y\]"}]
            set fields [lmap {f form} [dict get $st fields] {
                lassign $form kind y
                switch -- $kind {
                    bare { string cat "$f: std::list::at(l$y, 0)" }
                    default { continue }
                }
            }]
            if {[llength $fields] == [llength [dict get $st fields]]} {
                set argsText [lmap y $slots {
                    if {$y eq $x} { string cat "\[Box {f: plain}\]" } else { string cat "\[[lindex [Value [lindex $good [lsearch -exact $slots $y]]] 0]\]" }
                }]
                lappend probes [list "import std::list\nstruct Box\[T\]:\n    f: T\nfn plain(n):\n    n\nfn mk([join $params {, }]) -> $s\[[join $slots {, }]\] errors IndexNotFound:\n    $s\[[join $slots {, }]\] {[join $fields {, }]}\nfn tryit() -> int:\n    x = mk([join $argsText {, }]):\n        on IndexNotFound:\n            return 0\n    1\ntryit()\n" TRAIT-NOT-SATISFIED]
            }
        }
    }
    # A nested obligation a declaration does not state.
    lappend probes [list "struct Need\[K satisfies Hashable\]:\n    k: K\nstruct Holder\[T\]:\n    inner: Need\[T\]\n1\n" TRAIT-NOT-SATISFIED]
    lappend probes [list "struct Need\[K satisfies Printable\]:\n    k: K\nstruct Holder\[T satisfies Hashable\]:\n    inner: Need\[T\]\n1\n" TRAIT-NOT-SATISFIED]
    lappend probes [list "struct Need\[K satisfies Printable\]:\n    k: K\nstruct Holder\[T satisfies Printable\]:\n    inner: Need\[T\]\n1\n" accepted]
    return $probes
}

# The kind of the first diagnostic of compiling TEXT, or "accepted".
proc Verdict {text} {
    if {[catch {surface::compile $text t.bot -warnings off} message options]} {
        if {[dict exists $options -diagnostics]} {
            return [lindex [dict get [lindex [dict get $options -diagnostics] 0] errorcode] end]
        }
        return [lindex [dict get $options -errorcode] end]
    }
    return accepted
}

proc Run {} {
    global options seedState
    set seedState [dict get $options -seed]
    set backends [dict get $options -backends]
    set failures 0
    set observed 0
    set probed 0
    set verdicts [dict create]
    for {set number 1} {$number <= [dict get $options -n]} {incr number} {
        lassign [Program $number] text expected decls
        if {[dict get $options -dump]} {
            puts "--- program $number\n$text"
        }
        set problems {}
        if {[catch {surface::compile $text t.bot -warnings off} hir options2]} {
            lappend problems "the program does not compile: $hir"
        } else {
            foreach b $backends {
                set o [lrange [outcomeUnderHir $b $hir] 0 1]
                if {$o ne [list value $expected]} {
                    lappend problems "$b gives $o, the model $expected"
                }
            }
            if {[dict get $options -gc-stress]} {
                set ::env(BOTLISH_NATIVE_GC_STRESS) 1
                try {
                    set o [lrange [outcomeUnderHir cranelift $hir] 0 1]
                } finally {
                    unset ::env(BOTLISH_NATIVE_GC_STRESS)
                }
                if {$o ne [list value $expected]} {
                    lappend problems "cranelift under GC stress gives $o, the model $expected"
                }
            }
            incr observed [llength [split $expected ,]]
        }
        foreach probe [Probes $decls] {
            lassign $probe body want
            set probeText "$::header\n$decls[Functions_All]$body"
            incr probed
            dict incr verdicts $want
            set got [Verdict $probeText]
            if {$got ne $want} {
                lappend problems "probe: the model says $want, the compiler $got\n$probeText"
            }
        }
        if {$problems ne {}} {
            incr failures
            puts "FAIL program $number (seed [dict get $options -seed]):"
            foreach p $problems {
                puts "  $p"
            }
            puts "--- source\n$text"
        }
    }
    puts "fuzz: [dict get $options -n] programs, $observed observations, $probed probes ([join [lmap {k v} [lsort -stride 2 $verdicts] {string cat "$v $k"}] {, }]), $failures failing (seed [dict get $options -seed])"
    return $failures
}

proc Functions_All {} {
    set text ""
    dict for {s st} $::structs {
        append text [Functions $s]
    }
    return $text
}

try {
    set failures [Run]
} finally {
    file delete -force $::fuzzLibrary
}
exit [expr {$failures > 0}]
