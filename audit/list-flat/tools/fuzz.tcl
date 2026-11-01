# fuzz.tcl -- differential fuzzing of std::list::flat (LIST-FLAT-MILESTONE-1.md)
# against an independent model (oracle.py beside this script).
#
#   tclsh9.0 audit/list-flat/tools/fuzz.tcl ?-n PROGRAMS? ?-seed N? ?-cases N?
#       ?-backends LIST? ?-gc-stress 0|1? ?-profile small|large? ?-keep DIR?
#
# Each program holds CASES cases (default 8). A case is a random List of
# Lists -- inner Lists of random length, many of them empty, of Ints (small
# and past 64 bits), Strings, Bools, Lists of Ints and FuzzP structs -- built
# in one of several ways and flattened:
#
#   literal    std::list::flat([[...], ...]) of a literal
#   method     the same written [[...], ...].flat()
#   function   flat of a function's result
#   loop       flat of a collecting loop whose body picks the i-th inner
#              List by branches (`if i == 0: [...] elif ...`)
#   fold       flat of a fold that appends the inner Lists one by one
#   twice      flat(flat(...)) of a List of Lists of Lists
#   computed   (profile large) inner Lists computed by counted loops, up to
#              hundreds of elements each, around many empty ones
#
# The program's value (the List of the cases' values) must be the oracle's on
# every backend; with -gc-stress 1 the native backends run under
# BOTLISH_NATIVE_GC_STRESS=1. The last line is "programs N disagreements D".
# Scratch files live in a `file tempdir` directory, removed at the end
# (-keep DIR copies the failing programs there).

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
# (tests/helpers.tcl loads tcltest, which reads argv: it sees none.)
set arguments $argv
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
set argv $arguments

set options [dict create -n 20 -seed 1 -cases 8 -backends {interp compile cranelift-generic cranelift} \
    -gc-stress 0 -profile small -keep ""]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}
if {[dict get $options -gc-stress]} {
    set ::env(BOTLISH_NATIVE_GC_STRESS) 1
}
set ::large [expr {[dict get $options -profile] eq "large"}]
expr {srand([dict get $options -seed])}

proc pick {n} {
    return [expr {int(rand() * $n)}]
}

# A random element: {JSON SOURCE}.
proc element {} {
    switch -- [pick 6] {
        0 - 1 {
            set n [expr {[pick 2000] - 1000}]
            return [list "{\"int\": $n}" $n]
        }
        2 {
            set n [expr {[pick 2] ? 18446744073709551616 + [pick 100] : -9223372036854775809 - [pick 100]}]
            return [list "{\"int\": $n}" $n]
        }
        3 {
            set s s[pick 100]
            return [list "{\"str\": \"$s\"}" "\"$s\""]
        }
        4 {
            if {[pick 2]} {
                set ints {}
                for {set i [pick 3]} {$i > 0} {incr i -1} { lappend ints [pick 9] }
                return [list "{\"ints\": \[[join $ints {, }]\]}" "\[[join $ints {, }]\]"]
            }
            set b [expr {[pick 2] ? "true" : "false"}]
            return [list "{\"bool\": $b}" $b]
        }
        5 {
            set n [pick 50]
            return [list "{\"p\": $n}" "FuzzP {x: $n}"]
        }
    }
}

# A random inner List: {JSON SOURCE}.
proc inner {} {
    set length [expr {[pick 3] == 0 ? 0 : [pick 7]}]
    set json {}
    set src {}
    for {set i 0} {$i < $length} {incr i} {
        lassign [element] j s
        lappend json $j
        lappend src $s
    }
    return [list "\[[join $json {, }]\]" "\[[join $src {, }]\]"]
}

# A random List of inner Lists: {JSONS SOURCES}, one per inner List.
proc outer {} {
    set m [pick 10]
    set jsons {}
    set sources {}
    for {set i 0} {$i < $m} {incr i} {
        lassign [inner] j s
        lappend jsons $j
        lappend sources $s
    }
    return [list $jsons $sources]
}

# Case K: {JSON DECLARATIONS EXPRESSION}.
proc makeCase {k} {
    set modes {literal method function loop fold twice}
    if {$::large} {
        lappend modes computed computed computed
    }
    set mode [lindex $modes [pick [llength $modes]]]
    if {$mode eq "twice"} {
        set groups {}
        set jsons {}
        for {set g [pick 4]} {$g > 0} {incr g -1} {
            lassign [outer] js ss
            lappend jsons "\[[join $js {, }]\]"
            lappend groups "\[[join $ss {, }]\]"
        }
        return [list "{\"depth\": 2, \"lists\": \[[join $jsons {, }]\]}" "" \
            "std::list::flat(std::list::flat(\[[join $groups {, }]\]))"]
    }
    if {$mode eq "computed"} {
        set ks {}
        set jsons {}
        set m [expr {1 + [pick 60]}]
        for {set i 0} {$i < $m} {incr i} {
            set len [expr {[pick 4] == 0 ? [pick 300] : 0}]
            lappend ks $len
            set items {}
            for {set j 0} {$j < $len} {incr j} { lappend items "{\"int\": [expr {$i * 1000 + $j}]}" }
            lappend jsons "\[[join $items {, }]\]"
        }
        set decl "fn computed_$k\(i, k):\n    loop j from 0 to k:\n        i * 1000 + j\n\nfn outer_$k\():\n    ks = \[[join $ks {, }]\]\n    loop k in ks and i from 0 to std::list::length(ks):\n        computed_$k\(i, k)\n"
        return [list "{\"depth\": 1, \"lists\": \[[join $jsons {, }]\]}" $decl "std::list::flat(outer_$k\())"]
    }
    lassign [outer] jsons sources
    set json "{\"depth\": 1, \"lists\": \[[join $jsons {, }]\]}"
    set literal "\[[join $sources {, }]\]"
    switch -- $mode {
        literal { return [list $json "" "std::list::flat($literal)"] }
        method { return [list $json "" "$literal.flat()"] }
        function {
            return [list $json "fn make_$k\():\n    $literal\n" "std::list::flat(make_$k\())"]
        }
        loop - fold {
            set m [llength $sources]
            if {$m == 0} {
                return [list $json "" "std::list::flat($literal)"]
            }
            set decl "fn part_$k\(i):\n"
            set i 0
            foreach source $sources {
                if {$i == 0} {
                    append decl "    if i == 0:\n        $source\n"
                } elseif {$i < $m - 1} {
                    append decl "    elif i == $i:\n        $source\n"
                } else {
                    append decl "    else:\n        $source\n"
                }
                incr i
            }
            if {$m == 1} {
                set decl "fn part_$k\(i):\n    [lindex $sources 0]\n"
            }
            if {$mode eq "loop"} {
                append decl "\nfn outer_$k\():\n    loop i from 0 to $m:\n        part_$k\(i)\n"
            } else {
                append decl "\nfn outer_$k\():\n    fold i from 0 to $m with intermediate acc \[\]:\n        acc.append(part_$k\(i))\n"
            }
            return [list $json $decl "std::list::flat(outer_$k\())"]
        }
    }
}

proc oracle {jsons} {
    set f [file join $::scratch cases.json]
    set channel [open $f w]
    fconfigure $channel -encoding utf-8 -translation lf
    puts $channel "\[[join $jsons ",\n"]\]"
    close $channel
    return [split [string trim [exec python3 -I [file join [file dirname [file normalize [info script]]] oracle.py] < $f]] \n]
}

set ::scratch [file tempdir botlish-list-flat-fuzz]
set disagreements 0
set ::runs 0
set backends [dict get $options -backends]
try {
    for {set p 0} {$p < [dict get $options -n]} {incr p} {
        set jsons {}
        set decls {}
        set exprs {}
        for {set k 0} {$k < [dict get $options -cases]} {incr k} {
            lassign [makeCase $k] json decl expr
            lappend jsons $json
            if {$decl ne ""} { lappend decls $decl }
            lappend exprs $expr
        }
        set program "import std::list\n\nstruct FuzzP:\n    x: int\n\n[join $decls \n]\n\[[join $exprs ",\n "]\]\n"
        set want "\[[join [oracle $jsons] {, }]\]"
        if {[catch {surface::compile $program fuzz.bot -warnings off} hir]} {
            set outcomes [list "compile: $hir"]
        } else {
            set outcomes {}
            foreach backend $backends {
                set outcome [outcomeUnderHir $backend $hir]
                if {[lindex $outcome 0] eq "value"} {
                    lappend outcomes [lindex $outcome 1]
                } else {
                    lappend outcomes "$backend: [lrange $outcome 0 2]"
                }
            }
        }
        incr ::runs [llength $outcomes]
        set bad [lmap o $outcomes {if {$o eq $want} continue; set o}]
        if {$bad ne {}} {
            incr disagreements
            puts "DISAGREE program $p (seed [dict get $options -seed]):\n  expected $want\n  got [lindex $bad 0]"
            if {[dict get $options -keep] ne ""} {
                file mkdir [dict get $options -keep]
                set f [open [file join [dict get $options -keep] program-$p.bot] w]
                puts -nonewline $f $program
                close $f
            }
        }
    }
} finally {
    file delete -force $::scratch
}
puts "runs $::runs (each program on [llength $backends] backends, [dict get $options -cases] cases)"
puts "programs [dict get $options -n] disagreements $disagreements"
exit [expr {$disagreements > 0}]
