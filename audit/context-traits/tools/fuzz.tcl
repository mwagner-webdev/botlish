#!/usr/bin/env tclsh9.0
# fuzz.tcl -- generated context-trait programs against an independent oracle
# (CONTEXT-TRAITS.md).
#
#   tclsh9.0 audit/context-traits/tools/fuzz.tcl ?-n N? ?-seed S? ?-dump 1?
#                                                ?-backends LIST?
#
# Each program has, in a private library:
#
#   fz/tr.bot     1..3 context traits T0.. over a pool of operations (op0..op3,
#                 each `(n: int) -> int`, some declaring `errors Fail`); two
#                 traits may share an operation name
#   fz/cK.bot     1..3 concrete contexts CK, each the owner of its own
#                 candidate implementations: per operation name a correct one,
#                 a correct one declaring Fail (compatible only with a
#                 requirement that admits Fail), none, a wrong parameter type,
#                 a wrong result type, no context parameter, or another
#                 context's parameter
#
# and an entry program with consumers of six shapes -- direct (one or two
# context-trait parameters), transitive (calls earlier functions), nested (a
# nested function calling the operation), recursive, exact (an exact context
# parameter) and alias (`aN = f` in statement position) -- some never called,
# plus trap functions in the entry program named like operations over a
# concrete context (which must not implement anything: owner-only), and a top
# level of installations (a random subset, in random order) interleaved with
# calls. An independent oracle (no compiler code) computes:
#
#   * which concrete context satisfies which trait (compared with
#     hir::contexts::satisfiesTrait);
#   * every consumer's transitive requirement (traits and exact contexts),
#     compared with hir::contexts::required of the checked source program;
#   * at each top-level call, the installed providers of each required trait:
#     0 -> MISSING-CONTEXT, 1 -> selected, 2+ ->
#     AMBIGUOUS-CONTEXT-IMPLEMENTATION; a missing exact context ->
#     MISSING-CONTEXT; the first error in source order is the expected
#     rejection;
#   * for an accepted program: each call's selection (compared with the
#     recorded selections), the implementation every operation is bound to in
#     the compiled program (which must contain no context-trait operation or
#     binding), and the value, which every backend in BACKENDS must compute.
#
# The last line is "programs N disagreements D"; exit status 1 if D > 0.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set args $argv
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
interp recursionlimit {} 100000

set n 50
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

# A private library (a copy of lib/ plus the generated fz/ modules) and a
# private scratch directory, never under a fixed name (AGENTS.md).
set scratch [file tempdir context-traits-fuzz]
set library [file join $scratch lib]
file mkdir $library
foreach entry [glob -directory [file join $root lib] *] {
    file copy $entry $library
}
file mkdir [file join $library fz]
set ::core::libraryDir $library

proc rnd {n} {
    set ::rng [expr {($::rng * 1103515245 + 12345) % 2147483648}]
    return [expr {($::rng / 65536) % $n}]
}
proc pick {list} {
    return [lindex $list [rnd [llength $list]]]
}
proc chance {percent} {
    return [expr {[rnd 100] < $percent}]
}

proc writeModule {name text} {
    set f [open [file join $::library fz $name.bot] w]
    fconfigure $f -encoding utf-8
    puts -nonewline $f $text
    close $f
}

# One program. Returns a dict: modules {NAME TEXT ...}, text (the entry
# program), satisfies {CK {Ti 0|1 ...} ...}, required {FN {IDS} ...},
# expect ({error KIND} | {value V}), selections (per accepted call, in order:
# {TRAIT CONTEXT ...}), bindings {CK {OP IMPL-NAME}} (what each operation
# binds to).
proc generate {seed} {
    set ::rng [expr {$seed * 104729 + 7}]
    set ops {op0 op1 op2 op3}
    # Requirement shapes: op -> fails (0|1) per trait.
    set nT [expr {1 + [rnd 3]}]
    set traits [dict create]
    set lines [list "error Fail" "error Other" ""]
    for {set t 0} {$t < $nT} {incr t} {
        set names [lsort -unique [lmap _ [lrepeat [expr {1 + [rnd 2]}] x] {pick $ops}]]
        set reqs [dict create]
        lappend lines "context trait T$t:"
        foreach op $names {
            set fails [chance 30]
            dict set reqs $op $fails
            lappend lines "    fn ${op}(n: int) -> int[expr {$fails ? " errors Fail" : ""}]"
        }
        lappend lines ""
        dict set traits T$t $reqs
    }
    set modules [dict create tr [join $lines \n]]
    # Concrete contexts and their implementations.
    set nC [expr {1 + [rnd 3]}]
    set contexts [dict create]
    set allOps [lsort -unique [concat {*}[lmap {t reqs} $traits {dict keys $reqs}]]]
    for {set c 0} {$c < $nC} {incr c} {
        set k [expr {1 + [rnd 50]}]
        set lines [list "import fz::tr" "type Small = Int in 0..1000" "" \
            "context struct C$c:" "    k: Small" "" "context struct D$c:" "    k: Small" "" \
            "fn create() -> C$c:" "    C$c {k: $k}" ""]
        set impls [dict create]
        foreach op $allOps {
            set kind [pick {ok ok ok ok ok ok ok okfail okfail missing badparam badresult nocontext othercontext}]
            set m [expr {2 + [rnd 5]}]
            switch -- $kind {
                ok { lappend lines "fn ${op}(n: int, context c: C$c) -> int:" "    n * $m + c.k" "" }
                okfail {
                    lappend lines "fn ${op}(n: int, context c: C$c) -> int errors Fail:" \
                        "    if n > 100000:" "        fail Fail" "    n * $m + c.k" ""
                }
                missing {}
                badparam { lappend lines "fn ${op}(n: str, context c: C$c) -> int:" "    c.k" "" }
                badresult { lappend lines "fn ${op}(n: int, context c: C$c) -> str:" "    \"x\"" "" }
                nocontext { lappend lines "fn ${op}(n: int) -> int:" "    n" "" }
                othercontext { lappend lines "fn ${op}(n: int, context d: D$c) -> int:" "    n + d.k" "" }
            }
            dict set impls $op [list $kind $m]
        }
        dict set modules c$c [join $lines \n]
        dict set contexts C$c [dict create k $k impls $impls]
    }
    # The oracle's satisfaction: CK satisfies Ti iff every requirement has an
    # `ok` implementation, or an `okfail` one where the requirement admits
    # Fail.
    set satisfies [dict create]
    dict for {c info} $contexts {
        dict for {t reqs} $traits {
            set ok 1
            dict for {op fails} $reqs {
                set kind [lindex [dict get $info impls $op] 0]
                if {!($kind eq "ok" || ($kind eq "okfail" && $fails))} {
                    set ok 0
                }
            }
            dict set satisfies $c $t $ok
        }
    }
    # The entry program.
    set lines {}
    lappend lines "import fz::tr"
    foreach t [dict keys $traits] {
        lappend lines "import type fz::tr::$t"
    }
    foreach c [dict keys $contexts] {
        lappend lines "import fz::[string tolower $c]"
    }
    lappend lines ""
    # Traps: entry-program functions named like operations, over a concrete
    # context (owner-only: they implement nothing).
    if {[chance 40]} {
        set c [pick [dict keys $contexts]]
        set op [pick $allOps]
        lappend lines "fn ${op}(n: int, context c: fz::[string tolower $c]::$c) -> int:" "    999" ""
    }
    # Functions: NAME -> {traits {Ti ...} exact {CK ...} calls {F ...} value
    # SCRIPT call SPELLING}. VALUE is a list of terms the oracle evaluates
    # under a selection: {op Ti OP ARG} | {const K} | {call F ARG} | {exactk
    # CK} | {rec Ti OP N}.
    set funcs [dict create]
    set order {}
    set nf [expr {2 + [rnd 6]}]
    # Consumers mostly use traits some context satisfies (the rest exercise
    # MISSING-CONTEXT).
    set usable [lmap t [dict keys $traits] {
        set any 0
        foreach c [dict keys $contexts] {
            if {[dict get $satisfies $c $t]} { set any 1 }
        }
        expr {$any ? $t : [continue]}
    }]
    set traitPool [expr {$usable ne {} && [chance 85] ? $usable : [dict keys $traits]}]
    for {set j 0} {$j < $nf} {incr j} {
        set kinds {direct direct nested rec exact}
        if {$order ne ""} {
            lappend kinds mid mid alias
        }
        set kind [pick $kinds]
        set constant [rnd 20]
        switch -- $kind {
            direct {
                set name u$j
                set chosen [lsort -unique [lmap _ [lrepeat [expr {1 + [rnd 2]}] x] {pick $traitPool}]]
                set params {}
                set terms {}
                set value {}
                set i 0
                foreach t $chosen {
                    set local [lindex {out env sink} $i]
                    incr i
                    lappend params "$local: $t"
                    set op [pick [dict keys [dict get $traits $t]]]
                    lappend terms "$local.${op}(n)"
                    lappend value [list op $t $op n]
                }
                lappend lines "fn ${name}(n: int, context [join $params {, }]) -> int errors Fail:" \
                    "    [join $terms { + }] + $constant" ""
                lappend value [list const $constant]
                dict set funcs $name [dict create traits $chosen exact {} calls {} value $value arity 1]
            }
            nested {
                set name w$j
                set t [pick $traitPool]
                set op [pick [dict keys [dict get $traits $t]]]
                lappend lines "fn ${name}(n: int, context io: $t) -> int errors Fail:" \
                    "    fn step(m: int) -> int errors Fail:" "        io.${op}(m)" \
                    "    step(n) + step(n + 1) + $constant" ""
                dict set funcs $name [dict create traits [list $t] exact {} calls {} arity 1 \
                    value [list [list op $t $op n] [list op $t $op n+1] [list const $constant]]]
            }
            rec {
                set name r$j
                set t [pick $traitPool]
                set op [pick [dict keys [dict get $traits $t]]]
                lappend lines "fn ${name}(n: int, context io: $t) -> int errors Fail:" \
                    "    if n <= 0:" "        return io.${op}(0) + $constant" "    ${name}(n - 1) + 1" ""
                dict set funcs $name [dict create traits [list $t] exact {} calls {} arity 1 \
                    value [list [list rec $t $op $constant]]]
            }
            exact {
                set name e$j
                set c [pick [dict keys $contexts]]
                lappend lines "fn ${name}(n: int, context c: fz::[string tolower $c]::$c) -> int errors Fail:" \
                    "    n + $constant" ""
                dict set funcs $name [dict create traits {} exact [list $c] calls {} arity 1 \
                    value [list [list arg] [list const $constant]]]
            }
            mid {
                set name m$j
                set callees [lsort -unique [lmap _ [lrepeat [expr {1 + [rnd 2]}] x] {pick $order}]]
                set terms [lmap f $callees {string cat [dict get $funcs $f callname] "(n + 1)"}]
                lappend lines "fn ${name}(n: int) -> int errors Fail:" "    [join $terms { + }] + $constant" ""
                dict set funcs $name [dict create traits {} exact {} calls $callees arity 1 \
                    value [concat [lmap f $callees {list call $f n+1}] [list [list const $constant]]]]
            }
            alias {
                set name a$j
                set target [pick $order]
                lappend lines "$name = [dict get $funcs $target callname]" ""
                dict set funcs $name [dict create traits {} exact {} calls [list $target] arity 1 \
                    value [list [list call $target n]] alias 1]
            }
        }
        dict set funcs $name callname $name
        lappend order $name
    }
    # The top level: installations of a random subset, in random order,
    # interleaved with calls.
    set ctxs [dict keys $contexts]
    set installs {}
    if {[chance 65]} {
        # Mostly: an installation set that gives each trait one provider
        # where the satisfaction table allows it, plus the contexts exact
        # consumers need when they add no second provider.
        set wanted [lsort -unique [concat {*}[lmap {f info} $funcs {dict get $info exact}]]]
        set traitOrder [dict keys $traits]
        foreach t $traitOrder {
            if {[chance 10]} continue
            set have [lmap c $installs {expr {[dict get $satisfies $c $t] ? $c : [continue]}}]
            if {$have ne {}} continue
            set candidates [lmap c $ctxs {
                expr {$c ni $installs && [dict get $satisfies $c $t] && ![Overlaps $satisfies $installs $c] ? $c : [continue]}
            }]
            if {$candidates ne {}} {
                lappend installs [pick $candidates]
            }
        }
        foreach c $wanted {
            if {$c ni $installs && ![Overlaps $satisfies $installs $c]} {
                lappend installs $c
            }
        }
        # A random order of them.
        set shuffled {}
        while {$installs ne {}} {
            set c [pick $installs]
            lappend shuffled $c
            set installs [lsearch -all -inline -not -exact $installs $c]
        }
        set installs $shuffled
    } else {
        set pool $ctxs
        while {$pool ne {} && [chance 75]} {
            set c [pick $pool]
            lappend installs $c
            set pool [lsearch -all -inline -not -exact $pool $c]
        }
    }
    set steps [expr {1 + [rnd 4]}]
    set events {}
    foreach c $installs {
        lappend events [list install $c]
    }
    for {set s 0} {$s < $steps} {incr s} {
        set position [rnd [expr {[llength $events] + 1}]]
        if {[chance 70]} {
            # Calls mostly after the installations.
            set position [llength $events]
        }
        set events [linsert $events $position [list call [pick $order] [rnd 4]]]
    }
    set installed {}
    set error ""
    set results {}
    set selections {}
    set r 0
    foreach event $events {
        if {[lindex $event 0] eq "install"} {
            set c [lindex $event 1]
            lappend lines "with context fz::[string tolower $c]::create()"
            lappend installed $c
            continue
        }
        lassign $event - f arg
        set res res[incr r]
        lappend lines "$res = [dict get $funcs $f callname]($arg):" "    on Fail:" "        -1"
        lappend results $res
        set selection [dict create]
        lassign [Requirement $funcs $f] traitsNeeded exactNeeded
        # A call's requirements are checked in the order of their canonical
        # identities (exact contexts fz::cK::CK sort before traits
        # fz::tr::Ti); the first unmet one is the call's error.
        set needs [lsort -index 0 [concat \
            [lmap c $exactNeeded {list fz::[string tolower $c]::$c exact $c}] \
            [lmap t $traitsNeeded {list fz::tr::$t trait $t}]]]
        foreach need $needs {
            if {$error ne ""} break
            lassign $need - kind x
            if {$kind eq "exact"} {
                if {$x ni $installed} {
                    set error MISSING-CONTEXT
                }
                continue
            }
            set providers [lmap c $installed {expr {[dict get $satisfies $c $x] ? $c : [continue]}}]
            if {[llength $providers] == 0} {
                set error MISSING-CONTEXT
            } elseif {[llength $providers] > 1} {
                set error AMBIGUOUS-CONTEXT-IMPLEMENTATION
            } else {
                dict set selection $x [lindex $providers 0]
            }
        }
        if {$error eq ""} {
            lappend selections $selection
            lappend expectedValues [Value $funcs $f $arg $selection $contexts]
        }
    }
    lappend lines [expr {$results eq {} ? "0" : "\[[join $results {, }]\]"}] ""
    if {$error ne ""} {
        set expect [list error $error]
    } elseif {$results eq {}} {
        set expect {value 0}
    } else {
        set expect [list value "\[[join $expectedValues {, }]\]"]
    }
    set required [dict create]
    foreach f $order {
        if {[dict exists $funcs $f alias]} continue
        lassign [Requirement $funcs $f] traitsNeeded exactNeeded
        dict set required $f [lsort [concat [lmap t $traitsNeeded {string cat fz::tr:: $t}] \
            [lmap c $exactNeeded {string cat fz:: [string tolower $c] :: $c}]]]
    }
    return [dict create modules $modules text [join $lines \n] satisfies $satisfies required $required \
        expect $expect selections $selections contexts $contexts traits $traits]
}

# 1 if context C satisfies a trait some context of INSTALLS also satisfies.
proc Overlaps {satisfies installs c} {
    foreach other $installs {
        dict for {t ok} [dict get $satisfies $c] {
            if {$ok && [dict get $satisfies $other $t]} {
                return 1
            }
        }
    }
    return 0
}

# {TRAITS EXACT}: the oracle's transitive requirement of function F.
proc Requirement {funcs f {seen {}}} {
    if {$f in $seen} {
        return {{} {}}
    }
    set traits [dict get $funcs $f traits]
    set exact [dict get $funcs $f exact]
    foreach c [dict get $funcs $f calls] {
        lassign [Requirement $funcs $c [concat $seen [list $f]]] t e
        lappend traits {*}$t
        lappend exact {*}$e
    }
    return [list [lsort -unique $traits] [lsort -unique $exact]]
}

# The oracle's value of F(ARG) under SELECTION {Ti CK ...}.
proc Value {funcs f arg selection contexts} {
    set total 0
    foreach term [dict get $funcs $f value] {
        switch -- [lindex $term 0] {
            const { incr total [lindex $term 1] }
            arg { incr total $arg }
            op {
                lassign $term - t op x
                set v [expr {$x eq "n" ? $arg : $arg + 1}]
                incr total [OpValue $t $op $v $selection $contexts]
            }
            rec {
                lassign $term - t op constant
                # rN(n) = rN(n-1) + 1 down to rN(0) = op(0) + K.
                incr total [expr {[OpValue $t $op 0 $selection $contexts] + $constant + max($arg, 0)}]
            }
            call {
                lassign $term - g x
                set v [expr {$x eq "n" ? $arg : $arg + 1}]
                incr total [Value $funcs $g $v $selection $contexts]
            }
        }
    }
    return $total
}

proc OpValue {t op v selection contexts} {
    set c [dict get $selection $t]
    lassign [dict get $contexts $c impls $op] kind m
    return [expr {$v * $m + [dict get $contexts $c k]}]
}

proc hirOf {text strict} {
    set path [file join $::scratch p[incr ::counter].bot]
    set channel [open $path w]
    fconfigure $channel -encoding utf-8
    puts -nonewline $channel $text
    close $channel
    return [surface::readProgramFile $path -strict $strict -warnings off]
}

proc blockOf {hir name} {
    dict for {b binding} [dict get $hir bindings] {
        if {[dict get $binding kind] ne "local"} continue
        set shown [expr {[dict exists $binding spelling] ? [dict get $binding spelling] : [dict get $binding name]}]
        if {$shown ne $name} continue
        set by [dict get $binding declaredBy]
        if {$by ne "" && [hir::kind $hir $by] eq "bind" && [hir::kind $hir [hir::get $hir $by value]] eq "block"} {
            return [hir::get $hir $by value]
        }
    }
    return ""
}

set disagreements 0
set accepted 0
set rejected 0
set kinds [dict create]
set selectionCount 0
for {set i 0} {$i < $n} {incr i} {
    set seed [expr {$seed0 + $i}]
    set p [generate $seed]
    dict for {name text} [dict get $p modules] {
        writeModule $name $text
    }
    set text [dict get $p text]
    set expect [dict get $p expect]
    if {$dump} {
        puts "### program $seed (expect $expect)"
        dict for {name module} [dict get $p modules] {
            puts "--- fz/$name.bot\n$module"
        }
        puts "--- entry\n$text"
    }
    set problems {}
    # The checked source program (-strict 0: also for a rejected program).
    if {[catch {hirOf $text 0} loose]} {
        lappend problems "-strict 0 build failed: $loose"
    } else {
        set source [expr {[dict exists $loose traitSource] ? [dict get $loose traitSource] : $loose}]
        dict for {f ids} [dict get $p required] {
            set b [blockOf $source $f]
            if {$b eq ""} {
                lappend problems "no function $f"
                continue
            }
            set got [hir::contexts::required $source $b]
            if {$got ne $ids} {
                lappend problems "requirement of $f: oracle {$ids}, compiler {$got}"
            }
        }
        dict for {c byTrait} [dict get $p satisfies] {
            dict for {t ok} $byTrait {
                set s [hir::contexts::satisfiesTrait fz::[string tolower $c]::$c fz::tr::$t]
                if {[dict get $s ok] != $ok} {
                    lappend problems "satisfaction of fz::tr::$t by $c: oracle $ok, compiler [dict get $s ok] ([dict get $s reason])"
                }
            }
        }
    }
    if {[lindex $expect 0] eq "error"} {
        incr rejected
        dict incr kinds [lindex $expect 1]
        if {![catch {hirOf $text 1} message options]} {
            lappend problems "accepted; oracle expects [lindex $expect 1]"
        } elseif {[lindex [dict get $options -errorcode] end] ne [lindex $expect 1]} {
            lappend problems "rejected with [dict get $options -errorcode] ($message); oracle expects [lindex $expect 1]"
        }
    } else {
        incr accepted
        if {[catch {hirOf $text 1} hir]} {
            lappend problems "rejected ($hir); oracle expects the value [lindex $expect 1]"
        } else {
            # Selections, in call order.
            set source [expr {[dict exists $hir traitSource] ? [dict get $hir traitSource] : $hir}]
            set got {}
            if {[dict exists $source contexts selections]} {
                dict for {c selection} [dict get $source contexts selections] {
                    lappend got [lmap {t w} $selection {list [namespace tail $t] [namespace tail $w]}]
                }
            }
            set want [lmap s [dict get $p selections] {
                expr {$s eq {} ? [continue] : [lmap {t w} $s {list $t $w}]}
            }]
            if {[lsort $got] ne [lsort $want]} {
                lappend problems "selections: oracle {$want}, compiler {$got}"
            }
            incr selectionCount [llength $want]
            # The compiled program: no context-trait operation or binding;
            # every operation bound to the selected context's implementation.
            dict for {e node} [dict get $hir exprs] {
                if {[dict exists $node traitCall]} {
                    lappend problems "the compiled program has a trait operation ($e)"
                }
                if {[hir::contexts::isLoad $hir $e] && [hir::contexts::isTrait [hir::contexts::loadId $hir $e]]} {
                    lappend problems "the compiled program loads a context trait ($e)"
                }
                if {[dict exists $node traitImpl context]} {
                    set impl [dict get $node traitImpl]
                    set w [lindex [dict get $impl witness] 1]
                    set expected "fz::[string tolower [namespace tail $w]]::[dict get $impl requirement]"
                    if {[dict get $impl implementation] ne $expected} {
                        lappend problems "operation [dict get $impl requirement] bound to [dict get $impl implementation], not $expected"
                    }
                }
            }
            foreach backend $backends {
                set outcome [outcomeUnderHir $backend $hir]
                if {[lindex $outcome 0] ne "value" || [lindex $outcome 1] ne [lindex $expect 1]} {
                    lappend problems "$backend: $outcome; oracle [lindex $expect 1]"
                }
            }
        }
    }
    if {$problems ne ""} {
        incr disagreements
        puts "DISAGREEMENT program $seed:\n[join $problems \n]"
        dict for {name module} [dict get $p modules] {
            puts "--- fz/$name.bot\n$module"
        }
        puts "--- entry\n$text"
    }
}
file delete -force $scratch
puts "accepted $accepted (selections $selectionCount) rejected $rejected ([join [lmap {k v} $kinds {string cat $k " " $v}] {, }])"
puts "programs $n disagreements $disagreements"
exit [expr {$disagreements > 0}]
