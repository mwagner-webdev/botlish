# declaration-summaries.tcl -- the scaling report of the declaration
# summaries (PARAMETERIZED-DECLARATION-SUMMARIES-MILESTONE-1.md,
# "Performance").
#
#   tclsh9.0 bench/declaration-summaries.tcl ?-depths {6 12 24 48 96}?
#       ?-reference 1? ?-budget N?
#
# Six specimen families, each at every depth N, answered by every migrated
# analysis (Totality equality and hash, Bearing, CarriedErrors, SendClass,
# MentionsMutable, MayHoldVector, CanCarry) from fresh summaries:
#
#   chain       N declarations L(i)[A, B] whose fields reach L(i-1) twice
#               (inner, rest) and themselves (same): a deep uniform recursion
#   nested      Box applied N deep around a coroutine handle (never cut)
#   nonuniform  W[List^N[C]] of `next: List[W[List[T]]]`
#   mutual      a ring of N declarations, each nesting its slot in a List
#               for the next (a non-uniform mutual recursion)
#   wide        one declaration of N slots, each held in a List
#   repeated    N applications of one declaration to N different arguments
#
# For each: wall time, summary node computations, summaries read from the
# table (memo hits), declarations summarized, application answers read,
# fixpoint rounds. With -reference 1, also the old recursive walks
# (audit/declaration-summaries/tools/reference.tcl) on the same queries,
# each stopped after -budget field reads: "budget" when it did not finish.

set root [file dirname [file dirname [file normalize [info script]]]]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root audit declaration-summaries tools reference.tcl]

array set opt {-depths {6 12 24 48 96} -reference 1 -budget 200000}
array set opt $argv

set C {Coroutine{args: [], return: int, errors: []}}
set cType [hir::types::MakeCoroutineType {} int {}]

# {SOURCE QUERY} of family FAMILY at depth N.
proc specimen {family n} {
    global C cType
    switch -- $family {
        chain {
            set decls "struct L0\[A, B\]:\n    x: A\n    y: B\n\n"
            for {set i 1} {$i <= $n} {incr i} {
                set p [expr {$i - 1}]
                append decls "struct L$i\[A, B\]:\n    inner: L$p\[B, A\]\n    tag: int\n    rest: List\[L$p\[int, A\]\]\n    same: List\[L$i\[int, int\]\]\n\n"
            }
            return [list $decls [list L$n [list $cType int]]]
        }
        nested {
            set t $cType
            for {set i 0} {$i < $n} {incr i} {
                set t [hir::types::MakeApplied Box [list $t]]
            }
            return [list "struct Box\[T\]:\n    value: T\n\n" $t]
        }
        nonuniform {
            set t $cType
            for {set i 0} {$i < $n} {incr i} {
                set t [hir::types::MakeList $t]
            }
            return [list "struct W\[T\]:\n    next: List\[W\[List\[T\]\]\]\n    f: Fn{args: \[int\], return: int}\n\n" [list W [list $t]]]
        }
        mutual {
            set decls ""
            for {set i 0} {$i < $n} {incr i} {
                set next [expr {($i + 1) % $n}]
                append decls "struct R$i\[T\]:\n    v: T\n    next: List\[R$next\[List\[T\]\]\]\n\n"
            }
            return [list $decls [list R0 [list $cType]]]
        }
        wide {
            set slots [lmap i [lrange [lsearch -all [lrepeat $n x] x] 0 end] {string cat T $i}]
            set decls "struct Wide\[[join $slots {, }]\]:\n"
            foreach s $slots {
                append decls "    f$s: List\[$s\]\n"
            }
            append decls "    self: List\[Wide\[[join $slots {, }]\]\]\n\n"
            return [list $decls [list Wide [lrepeat $n $cType]]]
        }
        repeated {
            return [list "struct Box\[T\]:\n    value: T\n\nstruct Pair\[A, B\]:\n    a: A\n    b: List\[Pair\[B, A\]\]\n\n" [list Pair [list $cType int]]]
        }
    }
}

proc applied {query} {
    if {[llength $query] == 2 && [lindex $query 0] ni {nstruct list}} {
        return [hir::types::MakeApplied [lindex $query 0] [lindex $query 1]]
    }
    return $query
}

# The queries a run answers: the specimen's type, and for `repeated` N
# applications to N different arguments.
proc queries {family n type} {
    global cType
    if {$family ne "repeated"} {
        return [list $type]
    }
    set result {}
    set arg int
    for {set i 0} {$i < $n} {incr i} {
        lappend result [hir::types::MakeApplied Pair [list $cType $arg]]
        set arg [hir::types::MakeList $arg]
    }
    return $result
}

proc answerAll {hir types} {
    foreach t $types {
        hir::types::Totality equality $t
        hir::types::Totality hash $t
        hir::callables::Bearing $hir $t
        hir::callables::CarriedErrors $hir $t
        hir::types::SendClass $t
        hir::types::MentionsMutable $t
        hir::mutvec::MayHoldVector $t
        hir::staticdeps::CanCarry $hir $t
    }
}

proc referenceAll {hir types} {
    foreach t $types {
        foreach script [list \
            [list ::reference::types::Totality equality $t] [list ::reference::types::Totality hash $t] \
            [list ::reference::callables::Bearing $hir $t] [list ::reference::callables::CarriedErrors $hir $t] \
            [list ::reference::types::SendClass $t] [list ::reference::types::MentionsMutable $t] \
            [list ::reference::mutvec::MayHoldVector $t] [list ::reference::staticdeps::CanCarry $hir $t]] {
            ::reference::Run $script
        }
    }
}

proc sumOf {counters prefix} {
    set total 0
    dict for {k v} $counters {
        if {[string match $prefix.* $k]} {
            incr total $v
        }
    }
    return $total
}

set ::reference::budget $opt(-budget)
puts "| family | N | wall (ms) | computations | memo hits | declarations | applications | rounds | old walks (ms) |"
puts "|---|---:|---:|---:|---:|---:|---:|---:|---:|"
foreach family {chain nested nonuniform mutual wide repeated} {
    foreach n $opt(-depths) {
        lassign [specimen $family $n] decls query
        set hir [surface::compile "$decls\n1\n" -warnings off]
        hir::activate $hir
        set type [applied $query]
        set types [queries $family $n $type]
        hir::structs::ForgetAffinity
        hir::summaries::ResetCounters
        set start [clock microseconds]
        answerAll $hir $types
        set wall [expr {([clock microseconds] - $start) / 1000.0}]
        set c [hir::summaries::counters]
        set declarations 0
        foreach name [dict keys $::hir::summaries::properties] {
            incr declarations [dict size [set ::hir::summaries::facts.$name]]
        }
        set old "-"
        if {$opt(-reference)} {
            set start [clock microseconds]
            if {[catch {referenceAll $hir $types} message]} {
                set old [expr {[string match REFERENCE-BUDGET* $message] ? "budget" : "error"}]
            } else {
                set old [format %.1f [expr {([clock microseconds] - $start) / 1000.0}]]
            }
        }
        puts [format {| %s | %d | %.1f | %d | %d | %d | %d | %d | %s |} $family $n $wall \
            [sumOf $c computations] [sumOf $c hits] $declarations [sumOf $c applications] \
            [dict getdef $c rounds 0] $old]
        flush stdout
    }
}
