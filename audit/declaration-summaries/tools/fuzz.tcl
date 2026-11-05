# fuzz.tcl -- random parameterized declaration graphs: the compiler's
# declaration summaries against an independent model (oracle.py) and
# against the recursive walks they replaced (reference.tcl)
# (PARAMETERIZED-DECLARATION-SUMMARIES-MILESTONE-1.md, "Oracle and fuzzing").
#
#   tclsh9.0 audit/declaration-summaries/tools/fuzz.tcl ?-seed N? ?-programs N?
#       ?-decls N? ?-queries N? ?-reference 0|1? ?-budget N? ?-keep DIR?
#
# Each program declares 1 to -decls parameterized structs of 0 to 3 slots
# (the oracle's type language: scalars, List, a Fn's argument and result,
# applications of any declaration -- itself, one declared later, a mutual
# cycle, an argument nested in a larger type: non-uniform recursion), is
# compiled, and is asked -queries random concrete types (atoms, a coroutine
# handle, Fn types, a MutableVector, Lists, applications with nested
# arguments). Every query's affinity, Bearing, Totality (both operations),
# carried errors and MentionsMutable must equal oracle.py's; with
# -reference 1 the old walks are run too and must agree (`same`), or differ
# only where the type bound cut an argument they read (`bound`), or not
# finish (`diverges`). Exit status 1 on any disagreement.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set ::argv0 fuzz
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root audit declaration-summaries tools parity.tcl]

array set opt {-seed 1 -programs 40 -decls 4 -queries 30 -reference 1 -budget 300 -keep ""}
array set opt $argv
expr {srand($opt(-seed))}
# (An old walk that has not finished after -budget field reads does not
# finish: a non-uniform recursion with an affine argument. The fuzzer's
# programs are small: a finite walk of them reads far fewer.)
set ::reference::budget $opt(-budget)

proc pick {list} {
    return [lindex $list [expr {int(rand() * [llength $list])}]]
}
proc chance {p} {
    return [expr {rand() < $p}]
}

# A random field type of a declaration with N slots among DECLS (name ->
# slots), at most DEPTH constructors deep around a slot.
proc fieldType {n decls depth} {
    set choices {atom atom}
    if {$n > 0} {
        lappend choices slot slot slot
    }
    if {$depth > 0} {
        lappend choices list arg ret app app app
    }
    switch -- [pick $choices] {
        atom { return [pick {int str F G E V}] }
        slot { return [list Slot [expr {int(rand() * $n)}]] }
        list { return [list List [fieldType $n $decls [expr {$depth - 1}]]] }
        arg { return [list Arg [fieldType $n $decls [expr {$depth - 1}]]] }
        ret { return [list Ret [fieldType $n $decls [expr {$depth - 1}]]] }
        app {
            set target [pick [dict keys $decls]]
            set args {}
            for {set i 0} {$i < [dict get $decls $target]} {incr i} {
                lappend args [fieldType $n $decls [expr {$depth - 1}]]
            }
            # (An application directly in a field, of a declaration that
            # needs no container to recur, is fine: the type is finite.)
            if {[chance 0.6]} {
                return [list List [list App $target $args]]
            }
            return [list App $target $args]
        }
    }
}

# A random query type, nesting at most DEPTH.
proc queryType {decls depth} {
    set choices {atom atom atom}
    if {$depth > 0} {
        lappend choices list app app app app
    }
    switch -- [pick $choices] {
        atom { return [pick {int str any C F G E V}] }
        list { return [list List [queryType $decls [expr {$depth - 1}]]] }
        app {
            set target [pick [dict keys $decls]]
            set args {}
            for {set i 0} {$i < [dict get $decls $target]} {incr i} {
                lappend args [queryType $decls [expr {$depth - 1}]]
            }
            return [list App $target $args]
        }
    }
}

# The Botlish spelling of oracle type T.
proc spelled {t} {
    if {[llength $t] == 1} {
        switch -- $t {
            C { return "Coroutine{args: \[Message\], return: Event}" }
            F { return "Fn{args: \[int\], return: int}" }
            G { return "Fn{args: \[any\], return: int}" }
            E { return "Fn{args: \[\], return: int, errors: \[Oops\]}" }
            V { return "MutableVector\[int\]" }
        }
        return $t
    }
    switch -- [lindex $t 0] {
        Slot { return "T[lindex $t 1]" }
        List { return "List\[[spelled [lindex $t 1]]\]" }
        Arg { return "Fn{args: \[[spelled [lindex $t 1]]\], return: int}" }
        Ret { return "Fn{args: \[\], return: [spelled [lindex $t 1]]}" }
        App {
            set args [lindex $t 2]
            if {$args eq {}} {
                return [lindex $t 1]
            }
            return "[lindex $t 1]\[[join [lmap a $args {spelled $a}] {, }]\]"
        }
    }
}

# The compiler's canonical type of oracle type T.
proc compiled {t} {
    if {[llength $t] == 1} {
        switch -- $t {
            C { return [hir::types::MakeCoroutineType [list {nstruct Message}] {nstruct Event} {}] }
            F { return [hir::types::MakeFn {int} int {}] }
            G { return [hir::types::MakeFn {any} int {}] }
            E { return [hir::types::MakeFn {} int {Oops}] }
            V { return [hir::types::MakeMutVec int 0] }
        }
        return $t
    }
    switch -- [lindex $t 0] {
        List { return [hir::types::MakeList [compiled [lindex $t 1]]] }
        Arg { return [hir::types::MakeFn [list [compiled [lindex $t 1]]] int {}] }
        Ret { return [hir::types::MakeFn {} [compiled [lindex $t 1]] {}] }
        App {
            set args [lindex $t 2]
            if {$args eq {}} {
                return [list nstruct [lindex $t 1]]
            }
            return [hir::types::MakeApplied [lindex $t 1] [lmap a $args {compiled $a}]]
        }
    }
}

# JSON of oracle type T.
proc json {t} {
    if {[llength $t] == 1} {
        return "\"$t\""
    }
    switch -- [lindex $t 0] {
        Slot { return "\[\"Slot\", [lindex $t 1]\]" }
        List - Arg - Ret { return "\[\"[lindex $t 0]\", [json [lindex $t 1]]\]" }
        App { return "\[\"App\", \"[lindex $t 1]\", \[[join [lmap a [lindex $t 2] {json $a}] {, }]\]\]" }
    }
}

proc compilerAnswers {hir t} {
    set c [compiled $t]
    set equality [lindex [hir::types::Totality equality $c] 0]
    set hash [lindex [hir::types::Totality hash $c] 0]
    return [dict create affine [hir::types::IsAffine $c] bearing [hir::callables::Bearing $hir $c] \
        totality $equality hashTotality $hash carried [hir::callables::CarriedErrors $hir $c] \
        mutable [hir::types::MentionsMutable $c]]
}

set oracle [file join $root audit declaration-summaries tools oracle.py]
set tmp [file tempdir declsummaries]
set failures 0
set stats [dict create programs 0 skipped 0 queries 0 same 0 bound 0 diverges 0 DIFFERENT 0 nonuniform 0]
hir::summaries::ResetCounters
try {
    for {set p 0} {$p < $opt(-programs)} {incr p} {
        set count [expr {1 + int(rand() * $opt(-decls))}]
        set decls [dict create]
        for {set d 0} {$d < $count} {incr d} {
            dict set decls D$d [expr {int(rand() * 4)}]
        }
        set fields [dict create]
        dict for {name n} $decls {
            set fs {}
            set k [expr {1 + int(rand() * 3)}]
            for {set i 0} {$i < $k} {incr i} {
                lappend fs [fieldType $n $decls 2]
            }
            if {$n > 0 && [chance 0.5]} {
                # A non-uniform recursion: an application of this or another
                # declaration whose arguments nest this one's slots (W's
                # `next: List[W[List[T]]]`), through a List.
                set target [if {[chance 0.6]} {set name} else {pick [dict keys $decls]}]
                set args {}
                for {set i 0} {$i < [dict get $decls $target]} {incr i} {
                    set slot [list Slot [expr {int(rand() * $n)}]]
                    lappend args [pick [list $slot [list List $slot] [list Ret $slot] [list Arg $slot] int]]
                }
                lappend fs [list List [list App $target $args]]
            }
            dict set fields $name $fs
        }
        set source "import std::list\nimport std::mutable_vector\n\nerror Oops\n\nstruct Message:\n    value: int\n\nstruct Event:\n    value: int\n\n"
        dict for {name n} $decls {
            set slots [lmap i [lrange {0 1 2 3} 0 [expr {$n - 1}]] {string cat T $i}]
            append source "struct $name[expr {$n ? "\[[join $slots {, }]\]" : ""}]:\n"
            set i 0
            foreach f [dict get $fields $name] {
                append source "    f$i: [spelled $f]\n"
                incr i
            }
            append source "\n"
        }
        append source "1\n"
        if {[catch {surface::compile $source -warnings off} hir]} {
            # (A generated declaration may be no valid one: a mutual cycle
            # through fields alone is fine, a duplicate never happens; keep
            # the count.)
            dict incr stats skipped
            if {$opt(-keep) ne ""} {
                set f [open [file join $opt(-keep) skipped-$opt(-seed)-$p.bot] w]; puts $f $source; puts $f "# $hir"; close $f
            }
            continue
        }
        dict incr stats programs
        hir::activate $hir
        if {[dict size [hir::summaries::ExpansiveDeclarations]] > 0} {
            dict incr stats nonuniform
        }
        set queries {}
        for {set q 0} {$q < $opt(-queries)} {incr q} {
            lappend queries [queryType $decls 2]
        }
        set spec "{\"decls\": {[join [lmap name [dict keys $decls] {
            string cat "\"$name\": {\"slots\": [dict get $decls $name], \"fields\": \[[join [lmap f [dict get $fields $name] {json $f}] {, }]\]}"
        }] {, }]}, \"queries\": \[[join [lmap q $queries {json $q}] {, }]\]}"
        set specFile [file join $tmp spec.json]
        set f [open $specFile w]; puts $f $spec; close $f
        set expected [split [string trim [exec python3 -I $oracle $specFile]] \n]
        foreach q $queries line $expected {
            dict incr stats queries
            if {[catch {compilerAnswers $hir $q} got]} {
                incr failures
                puts "COMPILER FAILS seed $opt(-seed) program $p: [spelled $q]: [string range $got 0 300]"
                puts $source
                continue
            }
            set want [dict create]
            foreach {k v} [string map {\{ "" \} "" \" "" : "" , ""} $line] {
                dict set want $k $v
            }
            # (The oracle's carried list printed as JSON: rebuild it.)
            regexp {"carried": \[([^\]]*)\]} $line -> carried
            dict set want carried [lsort [lmap e [split $carried ,] {string trim $e { "}}]]
            if {[dict get $want carried] eq {{}}} {
                dict set want carried {}
            }
            foreach k {affine bearing totality carried mutable} {
                if {[dict get $got $k] ne [dict get $want $k]} {
                    incr failures
                    puts "ORACLE DISAGREES seed $opt(-seed) program $p: $k of [spelled $q]: compiler [dict get $got $k], oracle [dict get $want $k]"
                    puts $source
                }
            }
            if {[dict get $got hashTotality] ne [dict get $got totality]} {
                incr failures
                puts "OPERATIONS DISAGREE seed $opt(-seed) program $p: [spelled $q]"
            }
            if {$opt(-reference)} {
                foreach row [parity::Compare $hir [compiled $q]] {
                    lassign $row analysis new old exact verdict
                    dict incr stats $verdict
                    if {$verdict eq "DIFFERENT"} {
                        incr failures
                        puts "REFERENCE DISAGREES seed $opt(-seed) program $p: $analysis of [spelled $q]: new $new, old $old, exact $exact"
                        puts $source
                    }
                }
            }
        }
    }
} finally {
    file delete -force $tmp
}
dict set stats whistles [dict getdef [hir::summaries::counters] whistles 0]
dict set stats fallbacks [dict getdef [hir::summaries::counters] fallbacks 0]
puts "declaration-summaries fuzz seed $opt(-seed): $stats, $failures failures"
exit [expr {$failures > 0}]
