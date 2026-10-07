# fuzz.tcl -- differential fuzzer for eager structural traits (TRAITS.md).
#
#   tclsh9.0 audit/traits/tools/fuzz.tcl ?-seed N? ?-count N? ?-backends LIST? ?-accept P? ?-v 1? ?-show 1?
#
# -accept P: the share of programs drawn (by retrying) until the oracle
# accepts them; the rest are taken as generated (a third of them with a
# deliberate defect: an operation the trait does not declare, a field of a
# view, a view passed to a concrete function or to another trait's consumer,
# a join of two parameters' witnesses, a witness that does not satisfy the
# trait, ...). -show 1 prints every program.
#
# Each program is a set of modules in a private temporary library plus an
# entry program:
#
#   * 2-4 traits (in the entry program, or in module `tr`, spelled through
#     `import type` or qualified), each with 1-3 unary receiver requirements
#     drawn from label (-> str), size (-> int), length (-> int) and lowercase
#     (-> the trait itself);
#   * 2-3 witness modules w1..w3, each owning one type (Box, Cell, Pos, Small): a struct, an opaque
#     struct, a refinement of int or an integer domain, with a `make`
#     constructor and, per requirement, a matching owner function or a
#     mismatching one (missing, wrong result, no declared result, an extra
#     parameter, or a receiver declared `int` -- which admits an int-carrier
#     witness and no struct); optionally the built-in str (length and
#     lowercase are str's intrinsics) and an entry-program struct Local;
#   * optionally a module `hp`, imported by the entry program, and functions
#     of the entry program itself, with correctly typed functions of a
#     requirement's name for a witness that lacks it: neither an import nor
#     the calling program ever implements a requirement;
#   * trait consumers: unary, two independent trait parameters, recursion
#     (also with the two parameters swapped: polymorphic recursion when their
#     witnesses differ), identity/requirement-result trait returns, same-
#     witness joins, joins of two parameters (always rejected), closures
#     capturing a view, local aliases, and calls of earlier consumers;
#   * a main list of calls with concrete witnesses, views returned by trait
#     returns, helper functions joining two views or two concrete values,
#     trait operations on a returned view, and aliases of consumers.
#
# An independent oracle (this file; it shares no code with the compiler)
# models what TRAITS.md says: structural satisfaction from the generated
# owner functions alone; the nominal one-way view (only the trait's
# requirements, no fields, no concrete parameter, no other trait); one
# witness per join; the set of specializations (consumer, witness tuple) the
# program's static calls need, and polymorphic recursion among them; and the
# program's value, evaluated concretely.
#
# A predicted rejection must be a compile-time error of one of the predicted
# kinds. A predicted acceptance must compile; the monomorphized HIR must hold
# no trait type and exactly the predicted specializations, by name
# (`c3<w1::Box,str>`); hir::traits::satisfies must agree with the oracle for
# every witness and trait; and every backend must run it to the oracle's
# value.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 200000

set options [dict create -seed 1 -count 100 -backends {interp compile cranelift-generic cranelift} -accept 0.6 -v 0 -show 0]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}
expr {srand([dict get $options -seed])}

proc pick {list} { lindex $list [expr {int(rand() * [llength $list])}] }
proc chance {p} { expr {rand() < $p} }
proc randInt {lo hi} { expr {$lo + int(rand() * ($hi - $lo + 1))} }
proc shuffle {list} {
    set out {}
    while {$list ne {}} {
        set i [expr {int(rand() * [llength $list])}]
        lappend out [lindex $list $i]
        set list [lreplace $list $i $i]
    }
    return $out
}

# The requirement pool: name -> result (str, int, or the trait itself).
set pool {label str size int length int lowercase self}

# ---------------------------------------------------------------------------
# Generation. The program is a dict in ::P:
#   traits     {T1 {OP ...} ...}            requirements, declaration order
#   traitHome  entry | module
#   spelling   short | qualified           (module home only)
#   witnesses  {W ...}  W: {id ID kind KIND canon CANON impls {OP STATUS ...}
#                            a A b B c C d D}
#   traps      {{OP WITNESS-ID} ...}       module hp's functions
#   consumers  {C ...}  C: {name N kind K params {{NAME TRAIT} ...}
#                            extras {{NAME int|bool} ...} result int|TRAIT
#                            stmts {...} body EXPR}
#   helpers    {H ...}  H: {name N consumer C a ARG b ARG}
#   aliases    {{NAME CONSUMER} ...}
#   main       {ELEMENT ...}

proc genStatus {kind op} {
    set r [expr {rand()}]
    if {$r < 0.72} { return ok }
    if {$r < 0.80} { return missing }
    if {$r < 0.85} { return wrongResult }
    if {$r < 0.89} { return noResult }
    if {$r < 0.93} { return arity }
    # A receiver declared int (an integer domain's lowercase would need a
    # range proof from an int: drawn ok instead).
    if {$kind eq "domain" && $op eq "lowercase"} { return ok }
    return intParam
}

proc genTraits {} {
    set traits {}
    set n [randInt 2 4]
    for {set i 1} {$i <= $n} {incr i} {
        set ops [list [pick {label size length}]]
        foreach extra {label size length lowercase} {
            if {$extra ni $ops && [llength $ops] < 3 && [chance 0.3]} {
                lappend ops $extra
            }
        }
        lappend traits T$i [shuffle $ops]
    }
    return $traits
}

proc genWitnesses {} {
    set ws {}
    set n [randInt 2 3]
    for {set i 1} {$i <= $n} {incr i} {
        set kind [pick {struct opaque refine domain}]
        set impls {}
        foreach op {label size length lowercase} {
            dict set impls $op [genStatus $kind $op]
        }
        set type [dict get {struct Box opaque Cell refine Pos domain Small} $kind]
        lappend ws [dict create id w$i kind $kind type $type canon "w${i}::$type" impls $impls \
            a [randInt 1 5] b [randInt 0 9] c [randInt 1 9] d [randInt 1 5]]
    }
    if {[chance 0.5]} {
        lappend ws [dict create id str kind str type str canon str \
            impls {label missing size missing length ok lowercase ok}]
    }
    if {[chance 0.4]} {
        set impls {}
        foreach op {label size length lowercase} {
            dict set impls $op [genStatus local $op]
        }
        lappend ws [dict create id local kind local type Local canon Local impls $impls \
            a [randInt 1 5] b [randInt 0 9] c [randInt 1 9] d [randInt 1 5]]
    }
    return $ws
}

proc witness {id} {
    foreach w [dict get $::P witnesses] {
        if {[dict get $w id] eq $id} { return $w }
    }
    error "no witness $id"
}

proc traitOps {t} { dict get $::P traits $t }

# Consumers of trait T of the given kinds defined so far (the generator only
# ever calls an earlier consumer: no forward reference).
proc consumersOf {t kinds} {
    set out {}
    foreach c [dict get $::P consumers] {
        if {[dict get $c kind] ni $kinds} continue
        set params [dict get $c params]
        if {$t ne "" && ([llength $params] != 1 || [lindex $params 0 1] ne $t)} continue
        lappend out $c
    }
    return $out
}

# A view expression of trait T over view variable VAR (in a consumer body).
proc genView {t var depth} {
    set r [expr {rand()}]
    if {$depth > 0 && "lowercase" in [traitOps $t] && $r < 0.25} {
        return [list low [genView $t $var [expr {$depth - 1}]]]
    }
    set keeps [consumersOf $t {keep}]
    if {$depth > 0 && $keeps ne {} && $r < 0.45} {
        return [list keep [dict get [pick $keeps] name] [genView $t $var [expr {$depth - 1}]]]
    }
    return [list p $var]
}

# An Int expression over the view variables VARS ({NAME TRAIT ...}); with
# DEFECT set, one deliberate defect is drawn into it instead.
proc genInt {vars depth {defect 0}} {
    set var [pick [dict keys $vars]]
    set t [dict get $vars $var]
    if {$defect} {
        return [genDefect $var $t]
    }
    set r [expr {rand()}]
    if {$depth > 0 && $r < 0.12} {
        return [list plus [genInt $vars [expr {$depth - 1}]] [genInt $vars [expr {$depth - 1}]]]
    }
    set calls [consumersOf $t {unary closure}]
    if {$calls ne {} && $r < 0.3} {
        return [list call [dict get [pick $calls] name] [list [genView $t $var 1]]]
    }
    set valueOps [lsearch -all -inline -not -exact [traitOps $t] lowercase]
    return [list op [pick $valueOps] [genView $t $var $depth]]
}

# One defect on view variable VAR of trait T, each a rule of TRAITS.md.
proc genDefect {var t} {
    set kinds {field unknown other concrete}
    while 1 {
        switch -- [pick $kinds] {
            field { return [list field [list p $var]] }
            unknown {
                set missing [lmap op {label size length lowercase} {
                    if {$op in [traitOps $t]} continue
                    set op
                }]
                if {$missing eq {}} continue
                set op [pick $missing]
                if {$op eq "lowercase"} {
                    return [list op [pick [lsearch -all -inline -not -exact [traitOps $t] lowercase]] [list low [list p $var]]]
                }
                return [list op $op [list p $var]]
            }
            other {
                set others [lmap c [consumersOf "" {unary closure}] {
                    if {[lindex [dict get $c params] 0 1] eq $t} continue
                    set c
                }]
                if {$others eq {}} continue
                return [list call [dict get [pick $others] name] [list [list p $var]]]
            }
            concrete {
                set candidates {}
                foreach w [dict get $::P witnesses] {
                    if {[dict get $w kind] in {str local}} continue
                    foreach op {size length label} {
                        if {[dict get $w impls $op] in {ok intParam}} {
                            lappend candidates [list [dict get $w id] $op]
                        }
                    }
                }
                if {$candidates eq {}} continue
                lassign [pick $candidates] id op
                return [list concrete $id $op [list p $var]]
            }
        }
    }
}

proc genConsumer {i defect} {
    set traits [dict keys [dict get $::P traits]]
    set t [pick $traits]
    set name c$i
    set stmts {}
    set kind [pick {unary unary pair rec keep keep join closure}]
    if {$defect && [chance 0.25]} {
        set kind joinParams
    }
    switch -- $kind {
        unary - closure {
            set vars [dict create x $t]
            if {[chance 0.35]} {
                lappend stmts [list let y$i [genView $t x 2]]
                dict set vars y$i $t
            }
            set body [genInt $vars 2 $defect]
            if {$kind eq "closure"} {
                lappend stmts [list closure f$i $body]
                set body [list ccall f$i]
            }
            set c [dict create params [list [list x $t]] extras {} result int]
        }
        pair {
            set t2 [pick $traits]
            set body [list plus [genInt [dict create a $t] 1 $defect] [genInt [dict create b $t2] 1]]
            set c [dict create params [list [list a $t] [list b $t2]] extras {} result int]
        }
        rec {
            if {[chance 0.4]} {
                # Two parameters of one trait, swapped by the recursive call.
                set base [list plus [genInt [dict create a $t] 1 $defect] [genInt [dict create b $t] 1]]
                set step [list plus [list call $name [list [list p b] [list p a] nminus]] {int 1}]
                set c [dict create params [list [list a $t] [list b $t]] extras {{n int}} result int]
                set kind recSwap
            } else {
                set base [genInt [dict create x $t] 1 $defect]
                set step [list plus [list call $name [list [genView $t x 1] nminus]] {int 1}]
                set c [dict create params [list [list x $t]] extras {{n int}} result int]
            }
            set body [list if n $base $step]
        }
        keep {
            set c [dict create params [list [list x $t]] extras {} result $t]
            set body [genView $t x 2]
            set name k$i
        }
        join {
            lappend stmts [list join y$i flag [genView $t x 1] [genView $t x 1]]
            set body [genInt [dict create y$i $t] 1 $defect]
            set c [dict create params [list [list x $t]] extras {{flag bool}} result int]
        }
        joinParams {
            lappend stmts [list join y$i flag [list p a] [list p b]]
            set body [genInt [dict create y$i $t] 1]
            set c [dict create params [list [list a $t] [list b $t]] extras {{flag bool}} result int]
        }
    }
    dict set c name $name
    dict set c kind $kind
    dict set c stmts $stmts
    dict set c body $body
    return $c
}

# A witness for a trait-T argument: one that satisfies T (the oracle's
# satisfaction) with probability GOOD.
proc pickWitness {t good} {
    set fits {}
    foreach w [dict get $::P witnesses] {
        if {[satisfiesOracle $w $t]} { lappend fits [dict get $w id] }
    }
    if {$fits ne {} && [chance $good]} {
        return [pick $fits]
    }
    return [dict get [pick [dict get $::P witnesses]] id]
}

proc genWitnessValue {id} {
    switch -- [dict get [witness $id] kind] {
        str {
            set s ""
            for {set k [randInt 1 6]} {$k > 0} {incr k -1} {
                append s [pick {a B c D e F x Y}]
            }
            return [list wit $id $s]
        }
        default { return [list wit $id [randInt 0 20]] }
    }
}

# An argument for a trait-T parameter in concrete code: a concrete witness
# value, or a view returned by a keep consumer of T.
proc genArg {t good} {
    set keeps [consumersOf $t {keep}]
    if {$keeps ne {} && [chance 0.3]} {
        return [list view [dict get [pick $keeps] name] [genWitnessValue [pickWitness $t $good]]]
    }
    return [genWitnessValue [pickWitness $t $good]]
}

proc genCallArgs {c good} {
    set args {}
    foreach p [dict get $c params] {
        lappend args [genArg [lindex $p 1] $good]
    }
    foreach x [dict get $c extras] {
        lappend args [expr {[lindex $x 1] eq "int" ? [list int [randInt 0 3]] : [list bool [pick {true false}]]}]
    }
    return $args
}

proc genMain {defect} {
    set callable [lmap c [dict get $::P consumers] {
        if {[dict get $c kind] eq "keep"} continue
        set c
    }]
    set good [expr {$defect ? 0.5 : 0.95}]
    set main {}
    set n [randInt 2 5]
    for {set k 0} {$k < $n} {incr k} {
        set r [expr {rand()}]
        set unary [lmap c $callable {
            if {[llength [dict get $c params]] != 1 || [dict get $c extras] ne {}} continue
            set c
        }]
        if {$r < 0.12 && $unary ne {}} {
            # A helper joining two arguments, then calling a consumer.
            set c [pick $unary]
            set t [lindex [dict get $c params] 0 1]
            set keeps [consumersOf $t {keep}]
            if {$keeps ne {} && [chance 0.5]} {
                set kname [dict get [pick $keeps] name]
                set id1 [pickWitness $t 0.95]
                set id2 [expr {[chance [expr {$defect ? 0.5 : 0.9}]] ? $id1 : [pickWitness $t 0.95]}]
                set a [list view $kname [genWitnessValue $id1]]
                set b [list view $kname [genWitnessValue $id2]]
            } else {
                set id1 [pickWitness $t 0.95]
                set id2 [expr {[chance [expr {$defect ? 0.5 : 0.9}]] ? $id1 : [pickWitness $t 0.95]}]
                set a [genWitnessValue $id1]
                set b [genWitnessValue $id2]
            }
            set h h[expr {[llength [dict get $::P helpers]] + 1}]
            dict lappend ::P helpers [dict create name $h consumer [dict get $c name] a $a b $b]
            lappend main [list helper $h [pick {true false}]]
        } elseif {$r < 0.22 && $callable ne {}} {
            set c [pick $callable]
            set a a[expr {[llength [dict get $::P aliases]] + 1}]
            dict lappend ::P aliases [list $a [dict get $c name]]
            lappend main [list alias $a [dict get $c name] [genCallArgs $c $good]]
        } elseif {$r < 0.32 && [consumersOf "" keep] ne {}} {
            # A trait operation on a returned view, in concrete code.
            set kc [pick [consumersOf "" keep]]
            set t [lindex [dict get $kc params] 0 1]
            set op [pick [lsearch -all -inline -not -exact [traitOps $t] lowercase]]
            lappend main [list viewop $op [list view [dict get $kc name] [genWitnessValue [pickWitness $t $good]]]]
        } elseif {$defect && $r < 0.40 && [consumersOf "" keep] ne {}} {
            # One-way: a view to a concrete function of its own witness.
            set kc [pick [consumersOf "" keep]]
            set t [lindex [dict get $kc params] 0 1]
            set targets {}
            foreach w [dict get $::P witnesses] {
                if {[dict get $w kind] in {str local} || ![satisfiesOracle $w $t]} continue
                foreach op {size length} {
                    if {[dict get $w impls $op] in {ok intParam}} {
                        lappend targets [list [dict get $w id] $op]
                    }
                }
            }
            if {$targets ne {}} {
                lassign [pick $targets] id op
                lappend main [list concrete $id $op [list view [dict get $kc name] [genWitnessValue $id]]]
            }
        } elseif {$callable ne {}} {
            set c [pick $callable]
            lappend main [list call [dict get $c name] [genCallArgs $c $good]]
        }
    }
    if {$main eq {}} {
        lappend main {int 0}
    }
    return $main
}

proc genProgram {} {
    set defect [chance 0.5]
    set ::P [dict create traits [genTraits] witnesses {} traps {} callerTraps {} consumers {} helpers {} aliases {} main {}]
    dict set ::P traitHome [expr {[chance 0.5] ? "entry" : "module"}]
    dict set ::P spelling [expr {[chance 0.5] ? "short" : "qualified"}]
    dict set ::P witnesses [genWitnesses]
    # Imports never implement a requirement: correctly typed functions of a
    # requirement's name for module witnesses that lack it.
    set used {}
    foreach w [dict get $::P witnesses] {
        if {[dict get $w kind] in {str local}} continue
        dict for {op status} [dict get $w impls] {
            if {$status ne "ok" && $op ni $used && [chance 0.4]} {
                dict lappend ::P traps [list $op [dict get $w id]]
                lappend used $op
            }
        }
    }
    # Nor does the calling program: correctly typed entry-program functions
    # of a requirement's name for module witnesses that lack it (a name the
    # entry program's own Local does not define).
    set used {}
    foreach w [dict get $::P witnesses] {
        if {[dict get $w kind] eq "local"} {
            dict for {op status} [dict get $w impls] {
                if {$status ne "missing"} { lappend used $op }
            }
        }
    }
    foreach w [dict get $::P witnesses] {
        if {[dict get $w kind] in {str local}} continue
        dict for {op status} [dict get $w impls] {
            if {$status ne "ok" && $op ni $used && [chance 0.4]} {
                dict lappend ::P callerTraps [list $op [dict get $w id]]
                lappend used $op
            }
        }
    }
    set n [randInt 2 6]
    # A defect goes into one consumer (or into main's arguments).
    set defectAt [expr {$defect && [chance 0.6] ? [randInt 1 $n] : 0}]
    for {set i 1} {$i <= $n} {incr i} {
        dict lappend ::P consumers [genConsumer $i [expr {$i == $defectAt}]]
    }
    dict set ::P main [genMain [expr {$defect && $defectAt == 0}]]
}

# ---------------------------------------------------------------------------
# Program text

proc traitRef {t} {
    if {[dict get $::P traitHome] eq "module" && [dict get $::P spelling] eq "qualified"} {
        return tr::$t
    }
    return $t
}

proc traitText {t} {
    set text "trait $t:\n"
    foreach op [traitOps $t] {
        set r [dict get $::pool $op]
        append text "    fn $op\(value: $t) -> [expr {$r eq "self" ? $t : $r}]\n"
    }
    return $text
}

# The owner function of requirement OP for witness W (kind struct, opaque,
# refine, domain or local), as STATUS says.
proc implText {w op status} {
    set type [dict get $w type]
    set kind [dict get $w kind]
    set v [expr {$kind in {struct opaque local} && $status ne "intParam" ? "value.v" : "value"}]
    set param [expr {$status eq "intParam" ? "value: int" : "value: $type"}]
    if {$status eq "arity"} {
        append param ", extra: int"
    }
    switch -- $op {
        label { set result str; set body "\"[string repeat l [dict get $w d]]\"" }
        size { set result int; set body "$v * [dict get $w a] + [dict get $w b]" }
        length { set result int; set body "$v * 2 + 1" }
        lowercase {
            set result $type
            switch -- $kind {
                struct - opaque - local { set body "$type {v: $v + [dict get $w c]}" }
                refine { set body "make($v + [dict get $w c])" }
                domain { set body "if value < 990:\n        value + [dict get $w c]\n    else:\n        value" }
            }
        }
    }
    if {$status eq "wrongResult"} {
        set result [dict get {label int size str length bool lowercase int} $op]
        set body [dict get {label 7 size {"s"} length true lowercase 1} $op]
    }
    set head "fn $op\($param)"
    if {$status ne "noResult"} {
        append head " -> $result"
    }
    return "$head:\n    $body\n"
}

proc witnessModule {w} {
    set T [dict get $w type]
    switch -- [dict get $w kind] {
        struct - opaque {
            set text "[expr {[dict get $w kind] eq "opaque" ? "opaque " : ""}]struct $T:\n    v: int\n\nfn make(n: int) -> $T:\n    $T {v: n}\n"
        }
        refine {
            set text "refined type $T = int\n\nfn ok_$T?(n: int) -> bool proves n: $T:\n    n >= 0\n\nfn make(n: int) -> $T:\n    if ok_$T?(n):\n        n\n    else:\n        make(0)\n"
        }
        domain {
            set text "type $T = Int in 0..1000\n\nfn make(n: $T) -> $T:\n    n\n"
        }
    }
    dict for {op status} [dict get $w impls] {
        if {$status eq "missing"} continue
        append text "\n[implText $w $op $status]"
    }
    return $text
}

proc viewText {v} {
    switch -- [lindex $v 0] {
        p { return [lindex $v 1] }
        low { return "[viewText [lindex $v 1]].lowercase()" }
        keep { return "[lindex $v 1]([viewText [lindex $v 2]])" }
    }
}

proc argText {a} {
    switch -- [lindex $a 0] {
        wit {
            lassign $a - id value
            switch -- [dict get [witness $id] kind] {
                str { return "\"$value\"" }
                local { return "Local {v: $value}" }
                default { return "$id\::make($value)" }
            }
        }
        view { return "[lindex $a 1]([argText [lindex $a 2]])" }
        int { return [lindex $a 1] }
        bool { return [lindex $a 1] }
        nminus { return "n - 1" }
        default { return [viewText $a] }
    }
}

proc intText {e} {
    switch -- [lindex $e 0] {
        op {
            lassign $e - op v
            if {$op eq "label"} {
                return "str::length([viewText $v].label())"
            }
            return "[viewText $v].$op\()"
        }
        call { return "[lindex $e 1]([join [lmap a [lindex $e 2] {argText $a}] {, }])" }
        plus { return "[intText [lindex $e 1]] + [intText [lindex $e 2]]" }
        int { return [lindex $e 1] }
        field { return "[viewText [lindex $e 1]].v" }
        concrete {
            lassign $e - id op v
            if {$op eq "label"} {
                return "str::length($id\::label([viewText $v]))"
            }
            return "$id\::$op\([viewText $v])"
        }
        ccall { return "[lindex $e 1]()" }
    }
}

proc consumerText {c} {
    set params [lmap p [dict get $c params] {list [lindex $p 0]: [traitRef [lindex $p 1]]}]
    foreach x [dict get $c extras] {
        lappend params "[lindex $x 0]: [lindex $x 1]"
    }
    set result [dict get $c result]
    set text "fn [dict get $c name]\([join [lmap p $params {join $p " "}] {, }]) -> [expr {$result eq "int" ? "int" : [traitRef $result]}]:\n"
    foreach s [dict get $c stmts] {
        switch -- [lindex $s 0] {
            let { append text "    [lindex $s 1] = [viewText [lindex $s 2]]\n" }
            closure { append text "    fn [lindex $s 1]() -> int:\n        [intText [lindex $s 2]]\n" }
            join {
                lassign $s - name cond v1 v2
                append text "    $name = if $cond:\n        [viewText $v1]\n    else:\n        [viewText $v2]\n"
            }
        }
    }
    set body [dict get $c body]
    if {[lindex $body 0] eq "if"} {
        lassign $body - - base step
        append text "    if n <= 0:\n        [intText $base]\n    else:\n        [intText $step]\n"
    } elseif {$result eq "int"} {
        append text "    [intText $body]\n"
    } else {
        append text "    [viewText $body]\n"
    }
    return $text
}

proc elementText {e} {
    switch -- [lindex $e 0] {
        call { return "[lindex $e 1]([join [lmap a [lindex $e 2] {argText $a}] {, }])" }
        alias { return "[lindex $e 1]([join [lmap a [lindex $e 3] {argText $a}] {, }])" }
        helper { return "[lindex $e 1]([lindex $e 2])" }
        viewop {
            lassign $e - op a
            if {$op eq "label"} {
                return "str::length([argText $a].label())"
            }
            return "[argText $a].$op\()"
        }
        concrete {
            lassign $e - id op a
            return "$id\::$op\([argText $a])"
        }
        int { return [lindex $e 1] }
    }
}

# {FILES ENTRY}: the module files ({PATH TEXT ...}) and the entry program.
proc programText {} {
    set files {}
    set entry "import str\n"
    if {[dict get $::P traitHome] eq "module"} {
        set text ""
        foreach t [dict keys [dict get $::P traits]] {
            append text "[traitText $t]\n"
        }
        lappend files tr.bot $text
        append entry "import tr\n"
        if {[dict get $::P spelling] eq "short"} {
            foreach t [dict keys [dict get $::P traits]] {
                append entry "import type tr::$t\n"
            }
        }
    }
    foreach w [dict get $::P witnesses] {
        if {[dict get $w kind] in {str local}} continue
        lappend files [dict get $w id].bot [witnessModule $w]
        append entry "import [dict get $w id]\n"
    }
    if {[dict get $::P traps] ne {}} {
        set text ""
        foreach id [lsort -unique [lmap tr [dict get $::P traps] {lindex $tr 1}]] {
            append text "import $id\n"
        }
        foreach tr [dict get $::P traps] {
            lassign $tr op id
            set canon [dict get [witness $id] canon]
            set result [dict get $::pool $op]
            set body [dict get {label {"t"} size 0 length 0 lowercase value} $op]
            append text "\nfn $op\(value: $canon) -> [expr {$result eq "self" ? $canon : $result}]:\n    $body\n"
        }
        lappend files hp.bot $text
        append entry "import hp\n"
    }
    append entry "\n"
    if {[dict get $::P traitHome] eq "entry"} {
        foreach t [dict keys [dict get $::P traits]] {
            append entry "[traitText $t]\n"
        }
    }
    foreach w [dict get $::P witnesses] {
        if {[dict get $w kind] ne "local"} continue
        append entry "struct Local:\n    v: int\n\n"
        dict for {op status} [dict get $w impls] {
            if {$status eq "missing"} continue
            append entry "[implText $w $op $status]\n"
        }
    }
    foreach tr [dict get $::P callerTraps] {
        lassign $tr op id
        set canon [dict get [witness $id] canon]
        set result [dict get $::pool $op]
        set body [dict get {label {"t"} size 0 length 0 lowercase value} $op]
        append entry "fn $op\(value: $canon) -> [expr {$result eq "self" ? $canon : $result}]:\n    $body\n\n"
    }
    foreach c [dict get $::P consumers] {
        append entry "[consumerText $c]\n"
    }
    foreach h [dict get $::P helpers] {
        set c [dict get $h consumer]
        append entry "fn [dict get $h name](flag: bool) -> int:\n    y = if flag:\n        [argText [dict get $h a]]\n    else:\n        [argText [dict get $h b]]\n    $c\(y)\n\n"
    }
    foreach a [dict get $::P aliases] {
        append entry "[lindex $a 0] = [lindex $a 1]\n"
    }
    append entry "\[[join [lmap e [dict get $::P main] {elementText $e}] {, }]\]\n"
    return [list $files $entry]
}

# ---------------------------------------------------------------------------
# The oracle

# A witness's owner function for OP admits it: declared exactly as required,
# or with a receiver declared int when the witness is an int carrier.
proc admits {w op} {
    set status [dict get $w impls $op]
    expr {$status eq "ok" || ($status eq "intParam" && [dict get $w kind] in {refine domain})}
}

proc satisfiesOracle {w t} {
    foreach op [traitOps $t] {
        if {![admits $w $op]} { return 0 }
    }
    return 1
}

proc consumer {name} {
    foreach c [dict get $::P consumers] {
        if {[dict get $c name] eq $name} { return $c }
    }
    error "no consumer $name"
}

proc reject {kinds why} {
    lappend ::rejects [list $kinds $why]
}

# Generic check of a consumer body: views are {TRAIT SOURCE}, SOURCE the
# parameter whose (abstract) witness the view has.
proc checkView {env v} {
    switch -- [lindex $v 0] {
        p { return [dict get $env [lindex $v 1]] }
        low {
            set view [checkView $env [lindex $v 1]]
            if {"lowercase" ni [traitOps [lindex $view 0]]} {
                reject TRAIT-UNKNOWN-OPERATION "lowercase on [lindex $view 0]"
            }
            return $view
        }
        keep {
            set view [checkView $env [lindex $v 2]]
            set t [lindex [dict get [consumer [lindex $v 1]] params] 0 1]
            if {[lindex $view 0] ne $t} {
                reject TRAIT-NOT-SATISFIED "[lindex $view 0] view to [lindex $v 1]"
            }
            return [list $t [lindex $view 1]]
        }
    }
}

proc checkInt {env e} {
    switch -- [lindex $e 0] {
        op {
            set view [checkView $env [lindex $e 2]]
            if {[lindex $e 1] ni [traitOps [lindex $view 0]]} {
                reject TRAIT-UNKNOWN-OPERATION "[lindex $e 1] on [lindex $view 0]"
            }
        }
        call {
            set c [consumer [lindex $e 1]]
            set params [dict get $c params]
            foreach a [lindex $e 2] p $params {
                if {$p eq "" || [lindex $a 0] eq "nminus"} continue
                set view [checkView $env $a]
                if {[lindex $view 0] ne [lindex $p 1]} {
                    reject TRAIT-NOT-SATISFIED "[lindex $view 0] view to [lindex $e 1]"
                }
            }
        }
        plus {
            checkInt $env [lindex $e 1]
            checkInt $env [lindex $e 2]
        }
        field {
            checkView $env [lindex $e 1]
            reject TRAIT-VIEW-MISUSE "field of a view"
        }
        concrete {
            checkView $env [lindex $e 3]
            reject TYPE "view to [lindex $e 1]::[lindex $e 2]"
        }
    }
}

proc checkConsumer {c} {
    set env [dict create]
    set i 0
    foreach p [dict get $c params] {
        dict set env [lindex $p 0] [list [lindex $p 1] $i]
        incr i
    }
    foreach s [dict get $c stmts] {
        switch -- [lindex $s 0] {
            let { dict set env [lindex $s 1] [checkView $env [lindex $s 2]] }
            closure { checkInt $env [lindex $s 2] }
            join {
                lassign $s - name - v1 v2
                set a [checkView $env $v1]
                set b [checkView $env $v2]
                if {[lindex $a 1] ne [lindex $b 1]} {
                    # The join itself, and the joined view at its use.
                    reject {TRAIT-WITNESS-JOIN TRAIT-NOT-SATISFIED} "join of parameters"
                }
                dict set env $name $a
            }
        }
    }
    set body [dict get $c body]
    switch -- [lindex $body 0] {
        if {
            checkInt $env [lindex $body 2]
            checkInt $env [lindex $body 3]
        }
        ccall {}
        default {
            if {[dict get $c result] eq "int"} {
                checkInt $env $body
            } else {
                checkView $env $body
            }
        }
    }
}

# The static type of argument A in concrete code: {concrete WITNESS} or
# {view TRAIT WITNESS}; rejects an unsatisfied keep argument.
proc argType {a} {
    switch -- [lindex $a 0] {
        wit { return [list concrete [lindex $a 1]] }
        view {
            set t [lindex [dict get [consumer [lindex $a 1]] params] 0 1]
            set inner [argType [lindex $a 2]]
            acceptArg $inner $t [lindex $a 1]
            return [list view $t [lindex $inner end]]
        }
    }
}

# Checks argument type TYPE at a trait-T parameter of consumer C.
proc acceptArg {type t c} {
    if {[lindex $type 0] eq "concrete"} {
        if {![satisfiesOracle [witness [lindex $type 1]] $t]} {
            reject TRAIT-NOT-SATISFIED "[lindex $type 1] to $c ($t)"
        }
    } elseif {[lindex $type 1] ne $t} {
        reject TRAIT-NOT-SATISFIED "[lindex $type 1] view to $c ($t)"
    }
}

proc checkCall {cname argList} {
    set c [consumer $cname]
    foreach a $argList p [dict get $c params] {
        if {$p eq ""} continue
        acceptArg [argType $a] [lindex $p 1] $cname
    }
}

proc checkMain {} {
    foreach h [dict get $::P helpers] {
        set c [consumer [dict get $h consumer]]
        set t [lindex [dict get $c params] 0 1]
        set a [argType [dict get $h a]]
        set b [argType [dict get $h b]]
        if {[lindex $a end] ne [lindex $b end]} {
            if {[lindex $a 0] eq "view"} {
                reject {TRAIT-WITNESS-JOIN TRAIT-NOT-SATISFIED} "join of [lindex $a end] and [lindex $b end]"
            } else {
                # Two concrete types join to their lub: no trait (no implicit
                # trait join), so nothing that satisfies one.
                reject TRAIT-NOT-SATISFIED "lub of [lindex $a end] and [lindex $b end]"
            }
        } else {
            acceptArg $a $t [dict get $h consumer]
        }
    }
    foreach e [dict get $::P main] {
        switch -- [lindex $e 0] {
            call { checkCall [lindex $e 1] [lindex $e 2] }
            alias { checkCall [lindex $e 2] [lindex $e 3] }
            viewop { argType [lindex $e 2] }
            concrete {
                argType [lindex $e 3]
                reject TYPE "view to [lindex $e 1]::[lindex $e 2]"
            }
        }
    }
}

# --- Specializations: the static instance set ------------------------------

# The witness (canonical name) of argument A in concrete code.
proc argWitness {a} {
    switch -- [lindex $a 0] {
        wit { return [dict get [witness [lindex $a 1]] canon] }
        view { return [argWitness [lindex $a 2]] }
    }
}

proc viewSource {env v} {
    switch -- [lindex $v 0] {
        p { return [dict get $env [lindex $v 1]] }
        low { return [viewSource $env [lindex $v 1]] }
        keep {
            set w [viewSource $env [lindex $v 2]]
            noteInstance [lindex $v 1] [list $w]
            return $w
        }
    }
}

# Records instance NAME<WITNESSES>, and the edge to it from the instance
# being walked.
proc noteInstance {name witnesses} {
    set key "$name<[join $witnesses ,]>"
    if {$::from ne ""} {
        dict lappend ::edges $::from $key
    }
    if {![dict exists $::instances $key]} {
        dict set ::instances $key [list $name $witnesses]
        lappend ::work $key
    }
}

proc intInstances {env e} {
    switch -- [lindex $e 0] {
        op { viewSource $env [lindex $e 2] }
        call {
            set ws {}
            foreach a [lindex $e 2] {
                if {[lindex $a 0] eq "nminus"} continue
                lappend ws [viewSource $env $a]
            }
            noteInstance [lindex $e 1] $ws
        }
        plus {
            intInstances $env [lindex $e 1]
            intInstances $env [lindex $e 2]
        }
    }
}

proc instancesOf {c witnesses} {
    set env [dict create]
    foreach p [dict get $c params] w $witnesses {
        dict set env [lindex $p 0] $w
    }
    foreach s [dict get $c stmts] {
        switch -- [lindex $s 0] {
            let { dict set env [lindex $s 1] [viewSource $env [lindex $s 2]] }
            closure { intInstances $env [lindex $s 2] }
            join {
                set w [viewSource $env [lindex $s 3]]
                viewSource $env [lindex $s 4]
                dict set env [lindex $s 1] $w
            }
        }
    }
    set body [dict get $c body]
    switch -- [lindex $body 0] {
        if {
            intInstances $env [lindex $body 2]
            intInstances $env [lindex $body 3]
        }
        ccall {}
        default {
            if {[dict get $c result] eq "int"} {
                intInstances $env $body
            } else {
                viewSource $env $body
            }
        }
    }
}

proc mainArgInstances {a} {
    if {[lindex $a 0] eq "view"} {
        mainArgInstances [lindex $a 2]
        noteInstance [lindex $a 1] [list [argWitness [lindex $a 2]]]
    }
}

proc mainCallInstances {cname argList} {
    set c [consumer $cname]
    set ws {}
    foreach a $argList p [dict get $c params] {
        mainArgInstances $a
        if {$p ne ""} {
            lappend ws [argWitness $a]
        }
    }
    noteInstance $cname $ws
}

# The instance set and whether two distinct instances call each other in a
# cycle (polymorphic recursion).
proc instances {} {
    set ::instances [dict create]
    set ::edges [dict create]
    set ::work {}
    set ::from ""
    foreach h [dict get $::P helpers] {
        mainArgInstances [dict get $h a]
        mainArgInstances [dict get $h b]
        noteInstance [dict get $h consumer] [list [argWitness [dict get $h a]]]
    }
    foreach e [dict get $::P main] {
        switch -- [lindex $e 0] {
            call { mainCallInstances [lindex $e 1] [lindex $e 2] }
            alias { mainCallInstances [lindex $e 2] [lindex $e 3] }
            viewop - concrete { mainArgInstances [lindex $e end] }
        }
    }
    while {$::work ne {}} {
        set key [lindex $::work 0]
        set ::work [lrange $::work 1 end]
        set ::from $key
        lassign [dict get $::instances $key] name ws
        instancesOf [consumer $name] $ws
    }
    set ::from ""
    # A cycle through two distinct instances.
    set cyclic 0
    dict for {key -} $::instances {
        set seen [dict create]
        set stack [lmap k [expr {[dict exists $::edges $key] ? [dict get $::edges $key] : {}}] {
            if {$k eq $key} continue
            set k
        }]
        while {$stack ne {}} {
            set k [lindex $stack end]
            set stack [lrange $stack 0 end-1]
            if {$k eq $key} { set cyclic 1; break }
            if {[dict exists $seen $k]} continue
            dict set seen $k 1
            if {[dict exists $::edges $k]} {
                lappend stack {*}[dict get $::edges $k]
            }
        }
    }
    return [list [lsort [dict keys $::instances]] $cyclic]
}

# {REJECTS INSTANCES}: the predicted rejections ({KINDS WHY} ...) and, for an
# accepted program, its specializations.
proc oracle {} {
    set ::rejects {}
    foreach c [dict get $::P consumers] {
        checkConsumer $c
    }
    checkMain
    if {$::rejects ne {}} {
        return [list $::rejects {}]
    }
    lassign [instances] names cyclic
    if {$cyclic} {
        reject TRAIT-POLYMORPHIC-RECURSION "swapped witnesses"
    }
    return [list $::rejects $names]
}

# --- The concrete evaluator ----------------------------------------------------

# A witness value is {WITNESS-ID RAW}: RAW an Int (the struct field, the
# refined or domain Int itself) or the str.
proc opValue {value op} {
    lassign $value id raw
    set w [witness $id]
    switch -- $op {
        label { return [dict get $w d] }
        size { return [expr {$raw * [dict get $w a] + [dict get $w b]}] }
        length {
            if {[dict get $w kind] eq "str"} {
                return [string length $raw]
            }
            return [expr {2 * $raw + 1}]
        }
        lowercase {
            switch -- [dict get $w kind] {
                str { return [list $id [string tolower $raw]] }
                domain { return [list $id [expr {$raw < 990 ? $raw + [dict get $w c] : $raw}]] }
                default { return [list $id [expr {$raw + [dict get $w c]}]] }
            }
        }
    }
}

proc evalView {env v} {
    switch -- [lindex $v 0] {
        p { return [dict get $env [lindex $v 1]] }
        low { return [opValue [evalView $env [lindex $v 1]] lowercase] }
        keep { return [callValue [lindex $v 1] [list [evalView $env [lindex $v 2]]]] }
    }
}

proc evalInt {env e} {
    switch -- [lindex $e 0] {
        op { return [opValue [evalView $env [lindex $e 2]] [lindex $e 1]] }
        call {
            set values [lmap a [lindex $e 2] {
                if {[lindex $a 0] eq "nminus"} {
                    expr {[dict get $env n] - 1}
                } else {
                    evalView $env $a
                }
            }]
            return [callValue [lindex $e 1] $values]
        }
        plus { return [expr {[evalInt $env [lindex $e 1]] + [evalInt $env [lindex $e 2]]}] }
        int { return [lindex $e 1] }
        ccall { return [evalInt $env [dict get $env [lindex $e 1]]] }
    }
}

proc callValue {name argList} {
    set c [consumer $name]
    set env [dict create]
    set params [concat [lmap p [dict get $c params] {lindex $p 0}] [lmap x [dict get $c extras] {lindex $x 0}]]
    foreach p $params a $argList {
        dict set env $p $a
    }
    foreach s [dict get $c stmts] {
        switch -- [lindex $s 0] {
            let { dict set env [lindex $s 1] [evalView $env [lindex $s 2]] }
            closure { dict set env [lindex $s 1] [lindex $s 2] }
            join {
                lassign $s - name cond v1 v2
                dict set env $name [evalView $env [expr {[dict get $env $cond] ? $v1 : $v2}]]
            }
        }
    }
    set body [dict get $c body]
    switch -- [lindex $body 0] {
        if {
            return [evalInt $env [lindex $body [expr {[dict get $env n] <= 0 ? 2 : 3}]]]
        }
        ccall { return [evalInt $env $body] }
        default {
            if {[dict get $c result] eq "int"} {
                return [evalInt $env $body]
            }
            return [evalView $env $body]
        }
    }
}

proc evalArg {a} {
    switch -- [lindex $a 0] {
        wit { return [lrange $a 1 2] }
        view { return [callValue [lindex $a 1] [list [evalArg [lindex $a 2]]]] }
        int { return [lindex $a 1] }
        bool { return [expr {[lindex $a 1] eq "true"}] }
    }
}

proc concrete {} {
    set values {}
    foreach e [dict get $::P main] {
        switch -- [lindex $e 0] {
            call { lappend values [callValue [lindex $e 1] [lmap a [lindex $e 2] {evalArg $a}]] }
            alias { lappend values [callValue [lindex $e 2] [lmap a [lindex $e 3] {evalArg $a}]] }
            helper {
                foreach h [dict get $::P helpers] {
                    if {[dict get $h name] eq [lindex $e 1]} break
                }
                set a [evalArg [dict get $h [expr {[lindex $e 2] eq "true" ? "a" : "b"}]]]
                lappend values [callValue [dict get $h consumer] [list $a]]
            }
            viewop { lappend values [opValue [evalArg [lindex $e 2]] [lindex $e 1]] }
            int { lappend values [lindex $e 1] }
        }
    }
    return "\[[join $values {, }]\]"
}

# ---------------------------------------------------------------------------
# The compiler side

# The specializations in monomorphized HIR: the names of function bindings
# that are clones of a consumer.
proc compilerInstances {hir} {
    set names {}
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "bind"} continue
        if {[dict get $hir exprs [dict get $node value] kind] ne "block"} continue
        set name [dict get $hir bindings [dict get $node binding] name]
        if {[regexp {^[ck][0-9]+(<|$)} $name]} {
            lappend names $name
        }
    }
    return [lsort $names]
}

# "" if no static type or expression of HIR is a trait's, else the first.
proc traitLeft {hir} {
    dict for {t type} [dict get $hir types] {
        if {[hir::types::MentionsTrait $type]} {
            return "type $type"
        }
    }
    dict for {e node} [dict get $hir exprs] {
        if {[dict exists $node traitCall]} {
            return "trait call $e"
        }
    }
    return ""
}

proc witnessType {w} {
    switch -- [dict get $w kind] {
        str { return str }
        struct - opaque { return [list nstruct [dict get $w canon]] }
        local { return {nstruct Local} }
        default { return [core::type::normalize [dict get $w canon]] }
    }
}

# Mismatches between hir::traits::satisfies and the oracle, for every
# witness and trait of the program just compiled.
proc satisfactionMismatches {} {
    set out {}
    foreach w [dict get $::P witnesses] {
        foreach t [dict keys [dict get $::P traits]] {
            set id [expr {[dict get $::P traitHome] eq "module" ? "tr::$t" : $t}]
            set got [dict get [hir::traits::satisfies [witnessType $w] $id] ok]
            if {$got != [satisfiesOracle $w $t]} {
                lappend out "[dict get $w canon] $t: compiler $got"
            }
        }
    }
    return $out
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

# A private library: a copy of lib/ in a temporary directory, the generated
# modules written into it per program.
set library [file tempdir botlish-trait-fuzz]
foreach entry [glob -nocomplain -directory $::core::libraryDir *] {
    file copy -force $entry $library
}
set ::core::libraryDir $library
set generated {}

set stats [dict create programs 0 accepted 0 rejected 0 instances 0 failures 0]
set kinds [dict create]
set failures {}
try {
    for {set i 0} {$i < [dict get $options -count]} {incr i} {
        set wantAccept [chance [dict get $options -accept]]
        for {set try 0} {$try < 500} {incr try} {
            genProgram
            lassign [oracle] rejects predicted
            if {!$wantAccept || $rejects eq {}} break
        }
        lassign [programText] files text
        foreach path $generated {
            file delete [file join $library $path]
        }
        set generated {}
        foreach {path content} $files {
            set f [open [file join $library $path] w]
            fconfigure $f -encoding utf-8
            puts -nonewline $f $content
            close $f
            lappend generated $path
        }
        set listing ""
        foreach {path content} $files {
            append listing "---- $path\n$content"
        }
        append listing "---- fuzz.bot\n$text"
        dict incr stats programs
        if {[dict get $options -show]} {
            puts "==== program $i (oracle: [expr {$rejects eq {} ? "accept $predicted" : $rejects}])\n$listing"
        }
        set expectedKinds [lsort -unique [concat {*}[lmap r $rejects {lindex $r 0}]]]
        set problem ""
        if {[catch {surface::compile $text fuzz.bot -warnings off} hir compileOptions]} {
            set kind [lindex [dict get $compileOptions -errorcode] end]
            if {[lindex [dict get $compileOptions -errorcode] 1] eq "SYNTAX"} {
                set kind SYNTAX
            }
            if {$rejects eq {}} {
                set problem "rejected ($kind): $hir"
            } elseif {$kind ni $expectedKinds} {
                set problem "rejected with $kind (expected one of $expectedKinds: $rejects): $hir"
            } else {
                dict incr stats rejected
                dict incr kinds $kind
            }
        } elseif {$rejects ne {}} {
            set problem "accepted, but the oracle rejects: $rejects"
        } else {
            dict incr stats accepted
            dict incr stats instances [llength $predicted]
            set got [compilerInstances $hir]
            set left [traitLeft $hir]
            set mismatches [satisfactionMismatches]
            if {$got ne $predicted} {
                set problem "specializations: compiler {$got}, oracle {$predicted}"
            } elseif {$left ne ""} {
                set problem "monomorphized HIR keeps a $left"
            } elseif {$mismatches ne {}} {
                set problem "satisfaction: [join $mismatches {; }]"
            } else {
                set expected [list value [concrete]]
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
            lappend failures [list $i $problem $listing]
        }
    }
} finally {
    file delete -force $library
}

foreach failure $failures {
    lassign $failure i problem listing
    puts "FAIL program $i: $problem"
    if {[dict get $options -v]} {
        puts $listing
    }
}
puts "rejection kinds: [lsort -stride 2 $kinds]"
puts "seed [dict get $options -seed]: [dict get $stats programs] programs, [dict get $stats accepted] accepted ([dict get $stats instances] specializations), [dict get $stats rejected] rejected, [dict get $stats failures] failures"
exit [expr {[dict get $stats failures] > 0}]
