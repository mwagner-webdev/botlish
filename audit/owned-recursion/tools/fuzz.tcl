# fuzz.tcl -- random declaration graphs against the recursive-ownership
# verdict (OWNED-RECURSION-DECLARATION-SUMMARY-MILESTONE-1.md).
#
#   tclsh9.0 audit/owned-recursion/tools/fuzz.tcl ?-programs N? ?-queries Q?
#       ?-seed S? ?-runtime N? ?-native N? ?-end-to-end 0|1? ?-verbose 0|1?
#
# Each program declares 1-5 structs D0..D4 with 0-3 type slots and 1-4
# fields, field types drawn from: a slot, int, a coroutine handle, a C
# pointer (to Void or to a slot: an identity, never owned), a function type
# over a slot, List / MutableVector / MutableArray of a smaller type, and
# applications of the program's declarations to smaller types (self,
# mutual and non-uniform recursion: `D0[List[T]]` in D0[T]). Then:
#
#   * the declarations alone: the compiler rejects them
#     (AFFINE-CONTAINER-UNSUPPORTED) exactly when the oracle finds a
#     declaration, at its own slots (unrestricted), recursive;
#   * Q queries, applications of the declarations to int, a coroutine, a
#     List of one, a pointer and applications of the declarations: the
#     compiler's verdict (hir::structs::OwnedRecursion, white-box) against
#     the independent oracle (oracle.py) -- any disagreement is a failure --
#     and classified against the walk the compiler had before
#     (reference.tcl): same, old-bound (it stopped at its depth or budget),
#     other-declaration (it looked for recursion of the root's own
#     declaration only, so it accepted a type holding another declaration's
#     recursive affine type: the hole Descriptor's assertion caught),
#     transient (it rejected an application that returns to its own
#     declaration through a container while the affinity dies out on the
#     way: no recursion of affine values), or DIFFERENT (unexplained: a
#     failure);
#   * with -end-to-end 1, the same queries written as parameter types of
#     one program: AFFINE-CONTAINER-UNSUPPORTED exactly at the recursive
#     ones;
#   * for -runtime N programs, every accepted affine query whose values can
#     be built from fields of int, coroutine handles and Lists: a value is
#     made, passed, returned, stored in a struct, moved and dropped, and
#     ignored as a result, on interp and compile (and natively for -native
#     N of them): every coroutine made is released exactly once, and every
#     drop descriptor the program needs is finite.
#
# The last line is "N programs, Q queries, ..., F failures".

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
# (helpers.tcl configures tcltest from argv: give it none.)
set arguments $argv
set argv {}
source [file join $root tests helpers.tcl]
set argv $arguments
source [file join $root audit owned-recursion tools reference.tcl]

set options [dict create -programs 40 -queries 12 -seed 1 -runtime 15 -native 3 -end-to-end 1 -verbose 0]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}
expr {srand([dict get $options -seed])}
set restricted 0

proc pick {list} {
    return [lindex $list [expr {int(rand() * [llength $list])}]]
}
proc chance {p} {
    return [expr {rand() < $p}]
}

# ---------------------------------------------------------------------------
# Generation: types as terms {int} {co} {ptr T} {fn T} {var NAME} {list T}
# {mutvec T} {mutarray T} {app NAME {T ...}}

proc genType {decls slots depth} {
    set kinds {}
    lappend kinds int
    if {$slots eq {} || [chance 0.4]} { lappend kinds co }
    if {$slots ne {}} { lappend kinds var var var var }
    if {$depth > 0} {
        lappend kinds list list app app app app
        if {!$::restricted} {
            # (Not built by the runtime check: its programs leave them out.)
            lappend kinds mutvec mutarray ptr fn
        }
    }
    switch -- [pick $kinds] {
        int { return {int} }
        co { return {co} }
        var { return [list var [pick $slots]] }
        list - mutvec - mutarray {
            return [list [pick {list list list mutvec mutarray}] [genType $decls $slots [expr {$depth - 1}]]]
        }
        ptr {
            if {$slots ne {} && [chance 0.5]} {
                return [list ptr [list var [pick $slots]]]
            }
            return {ptr void}
        }
        fn {
            if {$slots ne {}} {
                return [list fn [list var [pick $slots]]]
            }
            return {fn int}
        }
        app {
            set d [pick [dict keys $decls]]
            set args {}
            foreach - [dict get $decls $d slots] {
                lappend args [genArg $decls $slots [expr {$depth - 1}]]
            }
            return [list app $d $args]
        }
    }
}

# An argument: mostly a slot, a List of one (growth), or a small type.
proc genArg {decls slots depth} {
    if {$slots ne {} && [chance 0.55]} {
        set v [list var [pick $slots]]
        if {[chance 0.3]} {
            return [list list $v]
        }
        return $v
    }
    return [genType $decls $slots [expr {min($depth, 1)}]]
}

proc genProgram {} {
    set n [expr {1 + int(rand() * 5)}]
    set decls [dict create]
    set names {}
    for {set i 0} {$i < $n} {incr i} {
        set slots [lrange {T U V} 0 [expr {int(rand() * 4) - 1}]]
        dict set decls D$i [dict create slots $slots fields {}]
        lappend names D$i
    }
    foreach d $names {
        set slots [dict get $decls $d slots]
        set fields {}
        set count [expr {1 + int(rand() * 4)}]
        for {set k 0} {$k < $count} {incr k} {
            set t [genType $decls $slots 2]
            if {$::restricted && [lindex $t 0] eq "app" && [chance 0.7]} {
                # (A runtime program's declarations recurse through Lists
                # mostly: a field of a declaration's own application makes
                # its values impossible, and nothing to build.)
                set t [list list $t]
            }
            lappend fields f$k $t
        }
        dict set decls $d fields $fields
    }
    return $decls
}

# ---------------------------------------------------------------------------
# Spellings

proc botlish {t} {
    switch -- [lindex $t 0] {
        int { return int }
        co { return "Coroutine{args: \[\], return: int}" }
        ptr {
            if {[lindex $t 1] eq "void"} { return "std::ffi::c::Ptr\[std::ffi::c::Void\]" }
            return "std::ffi::c::Ptr\[[botlish [lindex $t 1]]\]"
        }
        fn { return "Fn{args: \[[botlish [lindex $t 1]]\], return: int}" }
        var { return [lindex $t 1] }
        list { return "List\[[botlish [lindex $t 1]]\]" }
        mutvec { return "MutableVector\[[botlish [lindex $t 1]]\]" }
        mutarray { return "MutableArray\[[botlish [lindex $t 1]]\]" }
        app {
            if {[lindex $t 2] eq {}} { return [lindex $t 1] }
            return "[lindex $t 1]\[[join [lmap a [lindex $t 2] {botlish $a}] {, }]\]"
        }
    }
    error "botlish: $t"
}

proc oracleType {t} {
    switch -- [lindex $t 0] {
        int - co { return [lindex $t 0] }
        ptr {
            if {[lindex $t 1] eq "void"} { return "ptr int" }
            return "ptr {[oracleType [lindex $t 1]]}"
        }
        fn { return "fn {[oracleType [lindex $t 1]]}" }
        var { return "var [lindex $t 1]" }
        list - mutvec - mutarray { return "[lindex $t 0] {[oracleType [lindex $t 1]]}" }
        app { return "app [lindex $t 1] {[join [lmap a [lindex $t 2] {string cat \{ [oracleType $a] \}}] { }]}" }
    }
    error "oracleType: $t"
}

# The compiler's type term (no slot variables: queries are concrete).
proc term {t} {
    switch -- [lindex $t 0] {
        int { return int }
        co { return [hir::types::MakeCoroutineType {} int {}] }
        ptr {
            if {[lindex $t 1] eq "void"} { return {cptr void} }
            return [list cptr [term [lindex $t 1]]]
        }
        fn { return [list fn [dict create args [list [term [lindex $t 1]]] return int errors {}]] }
        list { return [hir::types::MakeList [term [lindex $t 1]]] }
        mutvec { return [hir::types::MakeMutVec [term [lindex $t 1]] 0] }
        mutarray { return [hir::types::MakeMutArray [term [lindex $t 1]] 0] }
        app {
            if {[lindex $t 2] eq {}} { return [list nstruct [lindex $t 1]] }
            return [hir::types::MakeApplied [lindex $t 1] [lmap a [lindex $t 2] {term $a}]]
        }
    }
    error "term: $t"
}

set imports "import std::coroutine\nimport std::mutable_vector\nimport std::mutable_array\nimport std::ffi::c\n"

proc declText {decls} {
    set text ""
    dict for {d entry} $decls {
        set slots [dict get $entry slots]
        append text "struct $d[expr {$slots eq {} ? "" : "\[[join $slots {, }]\]"}]:\n"
        foreach {f t} [dict get $entry fields] {
            append text "    $f: [botlish $t]\n"
        }
    }
    return $text
}

proc oracleText {decls queries} {
    set text ""
    dict for {d entry} $decls {
        set fields {}
        foreach {f t} [dict get $entry fields] {
            lappend fields "$f {[oracleType $t]}"
        }
        append text "decl $d {[dict get $entry slots]} {[join $fields { }]}\n"
    }
    foreach {id t} $queries {
        append text "query $id {[oracleType $t]}\n"
    }
    return $text
}

proc oracle {decls queries} {
    set file [file join $::scratch oracle.txt]
    set f [open $file w]
    puts -nonewline $f [oracleText $decls $queries]
    close $f
    set result [dict create]
    foreach line [split [exec python3 -I [file join $::root audit owned-recursion tools oracle.py] decide $file] \n] {
        if {$line eq ""} continue
        dict set result [lindex $line 0] [lindex $line 1]
    }
    return $result
}

proc compileCode {text} {
    if {[catch {surface::compile $text -warnings off} hir options]} {
        if {[dict exists $options -diagnostics]} {
            return [list error [dict get $options -diagnostics]]
        }
        return [list error [list [dict create errorcode [dict get $options -errorcode] message $hir]]]
    }
    return [list ok $hir]
}

proc kindOf {diagnostic} {
    return [lindex [dict get $diagnostic errorcode] end]
}

# ---------------------------------------------------------------------------
# Values for the runtime check: a Botlish expression of type T (concrete),
# or "" when none is built (a slot-free cycle of mandatory fields, a pointer,
# a function, a vector or array: not built here). COUNT counts coroutines.

proc valueOf {decls t depth countVar} {
    upvar 1 $countVar count
    switch -- [lindex $t 0] {
        int { return 0 }
        co {
            incr count
            return "make($count)"
        }
        list {
            if {$depth > 0 && [chance 0.85]} {
                set inner [valueOf $decls [lindex $t 1] [expr {$depth - 1}] count]
                if {$inner ne ""} {
                    return "\[$inner\]"
                }
            }
            return "\[\]"
        }
        app {
            if {$depth <= 0} { return "" }
            set d [lindex $t 1]
            set binding [dict create]
            foreach slot [dict get $decls $d slots] a [lindex $t 2] {
                dict set binding $slot $a
            }
            set parts {}
            foreach {f ft} [dict get $decls $d fields] {
                set v [valueOf $decls [substitute $ft $binding] [expr {$depth - 1}] count]
                if {$v eq ""} { return "" }
                lappend parts "$f: $v"
            }
            return "$d {[join $parts {, }]}"
        }
    }
    return ""
}

# The applications in the type term T below its top, at any depth.
proc subApplications {t} {
    set result {}
    switch -- [lindex $t 0] {
        list - mutvec - mutarray - ptr - fn {
            if {[lindex $t 1] ne "void"} {
                set inner [lindex $t 1]
                if {[lindex $inner 0] eq "app"} { lappend result $inner }
                lappend result {*}[subApplications $inner]
            }
        }
        app {
            foreach a [lindex $t 2] {
                if {[lindex $a 0] eq "app"} { lappend result $a }
                lappend result {*}[subApplications $a]
            }
        }
    }
    return $result
}

proc substitute {t binding} {
    switch -- [lindex $t 0] {
        var { return [dict get $binding [lindex $t 1]] }
        list - mutvec - mutarray - ptr - fn {
            if {[lindex $t 1] eq "void"} { return $t }
            return [list [lindex $t 0] [substitute [lindex $t 1] $binding]]
        }
        app { return [list app [lindex $t 1] [lmap a [lindex $t 2] {substitute $a $binding}]] }
    }
    return $t
}

# Why the old walk's "recursive" verdict OLD for TYPE, which the compiler
# accepts, was no recursion of affine values: "uninhabited" when an
# application its path passes has a declaration whose every value would hold
# itself through fields alone (hir::ownership::FieldCycle: no finite value
# has the type, so nothing nests), "transient" when the application of the
# root's declaration it returned to has another affine-slot state than the
# root's and is itself accepted (its affinity dies out before it recurs);
# "" when neither explains it (a DIFFERENT, a failure).
proc Explained {type old} {
    set target [lindex $old 1 end 2]
    while {![hir::types::IsNamedStruct $target] || [lindex $target 1] ne [lindex $type 1]} {
        if {[llength $target] < 2} { return "" }
        set target [lindex $target 1]
    }
    if {[hir::structs::OwnedRecursion $target] ne ""} {
        return ""
    }
    if {[hir::ownership::StateOf [lindex $target 1] [hir::ownership::Arguments $target]]
            ne [hir::ownership::StateOf [lindex $type 1] [hir::ownership::Arguments $type]]} {
        return transient
    }
    # "nested": the application it met again is one the type's own
    # arguments, or a declaration's field types, spell -- Box[List[Box[C]]]
    # holds a List of Box[C] because its argument says so -- or the root's
    # declaration has no recursion of its own at all (no cycle of the
    # declarations' edges through it): not one its declaration's recursion
    # reaches, a finite nesting.
    set key [list [lindex $target 1] [lindex $target 2]]
    set spelled [hir::summaries::Applications [lindex $type 2]]
    dict for {d entry} $::hir::structs::registry {
        foreach {f ft} [dict get $entry types] {
            lappend spelled {*}[hir::summaries::Applications $ft]
        }
    }
    if {$key in $spelled || ![DeclarationCycle [lindex $type 1]]} {
        return nested
    }
    # "uninhabited": the path passes an application of a declaration whose
    # every value would hold itself through fields alone (FieldCycle): no
    # value of what it found exists.
    foreach step [lindex $old 1] {
        lassign $step owner name t
        foreach x [list $owner $t] {
            foreach application [hir::summaries::Applications $x] {
                if {[hir::ownership::FieldCycle [lindex $application 0]]} {
                    return uninhabited
                }
            }
        }
    }
    return ""
}

# 1 if declaration ID reaches itself by the declarations' edges
# (hir::ownership::Edges, whatever they cross and whatever the affinity).
proc DeclarationCycle {id} {
    set seen [dict create]
    set work [list $id]
    while {$work ne {}} {
        set d [lindex $work end]
        set work [lrange $work 0 end-1]
        foreach edge [hir::ownership::Edges $d] {
            set target [lindex $edge 0]
            if {$target eq $id} { return 1 }
            if {[dict exists $seen $target]} continue
            dict set seen $target 1
            lappend work $target
        }
    }
    return 0
}

# ---------------------------------------------------------------------------
# The run

set scratch [file tempdir botlish-owned-recursion-fuzz]
set counts [dict create programs 0 rejected 0 queries 0 bad 0 same 0 old-bound 0 old-diverges 0 other-declaration 0 transient 0 uninhabited 0 nested 0 runtime 0 runtimeSkipped 0 native 0 endToEnd 0]
set failures 0
proc fail {message} {
    global failures
    incr failures
    puts "FAIL $message"
}

proc queryPool {decls} {
    set pool [list {int} {co} {list co}]
    if {!$::restricted} { lappend pool {ptr void} }
    dict for {d entry} $decls {
        set n [llength [dict get $entry slots]]
        set args {}
        for {set i 0} {$i < $n} {incr i} { lappend args [pick {int co {list co}}] }
        lappend pool [list app $d $args]
    }
    return $pool
}

try {
    for {set p 0} {$p < [dict get $options -programs]} {incr p} {
        set restricted [expr {$p < [dict get $options -runtime]}]
        set decls [genProgram]
        if {[dict get $options -verbose]} {
            puts stderr "program $p\n[declText $decls]"
        }
        dict incr counts programs
        set text "$imports[declText $decls]"
        # The declarations alone.
        set selfQueries {}
        dict for {d entry} $decls {
            lappend selfQueries self-$d [list app $d [lrepeat [llength [dict get $entry slots]] int]]
        }
        set verdicts [oracle $decls $selfQueries]
        set expectRejected [expr {"bad" in [dict values $verdicts]}]
        lassign [compileCode "${text}1\n"] status result
        set rejected 0
        if {$status eq "error"} {
            set kinds [lmap d $result {kindOf $d}]
            if {[lindex $kinds 0] ne "AFFINE-CONTAINER-UNSUPPORTED"} {
                fail "program $p: the declarations are rejected for another reason: [lindex $kinds 0] [dict get [lindex $result 0] message]\n[declText $decls]"
                continue
            }
            set rejected 1
        }
        if {$rejected != $expectRejected} {
            fail "program $p: declarations [expr {$rejected ? "rejected" : "accepted"}], the oracle [expr {$expectRejected ? "finds a recursive one" : "finds none"}] ($verdicts)\n[declText $decls]"
            continue
        }
        if {$rejected} {
            dict incr counts rejected
            continue
        }
        set hir $result
        # Queries.
        set queries {}
        set pool [queryPool $decls]
        for {set q 0} {$q < [dict get $options -queries]} {incr q} {
            set d [pick [dict keys $decls]]
            set args {}
            foreach - [dict get $decls $d slots] {
                set a [pick $pool]
                if {[chance 0.25]} { set a [list list $a] }
                lappend args $a
            }
            set t [list app $d $args]
            if {[chance 0.15]} { set t [list list $t] }
            lappend queries q$q $t
        }
        # (A written type is no type when any application in it is
        # recursive, a phantom slot's argument included: the end-to-end
        # expectation asks the oracle about each.)
        set asked $queries
        foreach {id t} $queries {
            set k 0
            foreach sub [subApplications $t] {
                lappend asked $id.[incr k] $sub
            }
        }
        set verdicts [oracle $decls $asked]
        hir::activate $hir
        foreach {id t} $queries {
            dict incr counts queries
            set type [term $t]
            set new [hir::structs::OwnedRecursion $type]
            set expected [dict get $verdicts $id]
            set got [expr {$new eq "" ? "ok" : "bad"}]
            if {$got eq "bad"} { dict incr counts bad }
            if {$got ne $expected} {
                fail "program $p query $id [botlish $t]: compiler $got, oracle $expected\n[declText $decls]"
                continue
            }
            # Against the old walk (only an affine named struct was asked).
            if {![hir::types::IsNamedStruct $type]} {
                dict incr counts same
                continue
            }
            set old [::reference::owned::OwnedRecursion $type]
            set oldVerdict [expr {$old eq "" ? "ok" : [lindex $old 0]}]
            if {($oldVerdict eq "ok") == ($got eq "ok")} {
                dict incr counts same
            } elseif {$oldVerdict eq "unbounded"} {
                dict incr counts old-bound
            } elseif {$oldVerdict eq "diverges"} {
                dict incr counts old-diverges
            } elseif {$oldVerdict eq "ok" && [lindex $new 2] ne [lindex $type 1]} {
                dict incr counts other-declaration
                if {[dict get $options -verbose]} { puts "other-declaration: [botlish $t]\n[declText $decls]" }
            } elseif {$oldVerdict eq "recursive" && $got eq "ok" && [set why [Explained $type $old]] ne ""} {
                dict incr counts $why
                if {[dict get $options -verbose]} { puts "$why: [botlish $t]\n[declText $decls]" }
            } else {
                fail "program $p query $id [botlish $t]: DIFFERENT from the old walk: old $old, new $new\n[declText $decls]"
            }
        }
        # End to end: the queries as parameter types.
        if {[dict get $options -end-to-end]} {
            set program "${text}"
            set lines [dict create]
            set line [llength [split $program \n]]
            foreach {id t} $queries {
                dict set lines $line $id
                append program "fn $id\(x: [botlish $t]) -> int:\n    1\n"
                incr line 2
            }
            append program "1\n"
            lassign [compileCode $program] status result
            set badLines [dict create]
            if {$status eq "error"} {
                foreach d $result {
                    if {[kindOf $d] ne "AFFINE-CONTAINER-UNSUPPORTED"} {
                        fail "program $p end to end: [kindOf $d] [dict get $d message]"
                        continue
                    }
                    regexp {^[^:]*:(\d+):} [dict get $d message] -> l
                    dict set badLines $l 1
                }
            }
            dict for {l id} $lines {
                dict incr counts endToEnd
                set written [expr {[dict exists $badLines $l] ? "bad" : "ok"}]
                set expected [dict get $verdicts $id]
                dict for {sub verdict} $verdicts {
                    if {[string match $id.* $sub] && $verdict eq "bad"} {
                        set expected bad
                    }
                }
                if {$written ne $expected} {
                    fail "program $p end to end $id ([botlish [dict get $queries $id]]): written $written, oracle $expected"
                }
            }
        }
        # Runtime: accepted affine queries that can be built.
        if {$p < [dict get $options -runtime]} {
            foreach {id t} $queries {
                if {[dict get $verdicts $id] ne "ok"} continue
                if {[lindex $t 0] ne "app"} continue
                # (Written, a type with a recursive application anywhere in
                # it is no type, a phantom slot's argument included.)
                set subBad 0
                dict for {sub verdict} $verdicts {
                    if {[string match $id.* $sub] && $verdict eq "bad"} { set subBad 1 }
                }
                if {$subBad} continue
                hir::activate $hir
                set type [term $t]
                if {![hir::types::IsAffine $type]} continue
                set count 0
                set value [valueOf $decls $t 6 count]
                if {$value eq "" || $count == 0} {
                    dict incr counts runtimeSkipped
                    continue
                }
                set spelled [botlish $t]
                set program "${text}fn worker(seed: int) -> int:\n    yield seed\n    seed\nfn make(seed: int) -> Coroutine{args: \[\], return: int}:\n    coroutine {step} = worker(seed)\n    step\nfn mk() -> $spelled:\n    $value\nfn pass(x: $spelled) -> $spelled:\n    x\nstruct Hold:\n    h: $spelled\nfn main() -> int:\n    a = mk()\n    b = pass(a)\n    h = Hold {h: b}\n    pass(mk())\n    1\nmain()\n"
                lassign [compileCode $program] status result
                if {$status eq "error"} {
                    # A construction the inference does not type as written
                    # (a phantom slot's argument, say): not this check's.
                    dict incr counts runtimeSkipped
                    if {[dict get $options -verbose]} { puts "runtime skipped ([kindOf [lindex $result 0]]): $spelled: [dict get [lindex $result 0] message]\n$program" }
                    continue
                }
                dict incr counts runtime
                set made [expr {2 * $count}]
                foreach backend {interp compile} {
                    set core::coroutines::releaseCalls {}
                    try {
                        set outcome [lrange [outcomeUnderHir $backend $result] 0 1]
                        set calls $core::coroutines::releaseCalls
                    } finally {
                        set core::coroutines::releaseCalls none
                    }
                    if {$outcome ne {value 1} || [llength $calls] != $made || [llength [lsort -unique $calls]] != $made} {
                        fail "program $p runtime $spelled on $backend: $outcome, [llength $calls] releases of $made coroutines ([llength [lsort -unique $calls]] distinct)\n$program"
                    }
                }
                if {[dict get $counts native] < [dict get $options -native] && [testConstraint nativeCoroutines]} {
                    dict incr counts native
                    set report [withoutCoroutineFusion {dict get [native::allocationReport $result summary] coroutines}]
                    set outcome [lrange [outcomeUnderHir cranelift $result] 0 1]
                    if {$outcome ne {value 1} || [dict get $report released] != $made || [dict get $report sweptSuspended] != 0} {
                        fail "program $p runtime $spelled natively: $outcome, $report (made $made)\n$program"
                    }
                }
            }
        }
    }
} finally {
    file delete -force $scratch
}

puts "[dict get $counts programs] programs ([dict get $counts rejected] rejected at their declarations), [dict get $counts queries] queries ([dict get $counts bad] recursive), old walk: [dict get $counts same] same, [dict get $counts old-bound] old-bound, [dict get $counts old-diverges] old-diverges, [dict get $counts other-declaration] other-declaration, [dict get $counts transient] transient, [dict get $counts uninhabited] uninhabited, [dict get $counts nested] nested; [dict get $counts endToEnd] written, [dict get $counts runtime] runtime ([dict get $counts runtimeSkipped] not built, [dict get $counts native] native), $failures failures"
exit [expr {$failures > 0}]
