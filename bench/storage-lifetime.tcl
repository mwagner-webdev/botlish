# storage-lifetime.tcl -- what the storage lifetime facts cost
# (STORAGE-LIFETIME-FACTS-MILESTONE-1.md, "Analysis scalability and compiler
# overhead"; hir/lifetime.tcl).
#
#   tclsh9.0 bench/storage-lifetime.tcl ?-runs 3? ?-only GLOB?
#
# For each workload: the front end's compilation time (surface), the
# specialization analysis the facts are computed over, and the analysis
# itself (best of RUNS), with what it covered -- units, CFG nodes,
# containment constraints, producers by activation verdict, suspension
# points -- and the process's peak resident set (VmHWM, Linux) after it.
# Workloads: the census corpus, real programs (the 2048 engine's golden
# suite and demo, the actor probe), and generated stress cases -- a long
# straight-line function, many functions and instances, a coroutine with
# many suspension points, and the depth-safe specimens nested 100 to 400
# deep (loops, conditions, structs).
set root [file dirname [file dirname [file normalize [info script]]]]
set options [dict create -runs 3 -only *]
foreach {k v} $argv {
    if {![dict exists $options $k]} { error "unknown option $k" }
    dict set options $k $v
}
set argv {}
source [file join $root surface surface.tcl]
source [file join $root audit depth-safe-nesting tools specimens.tcl]
set env(LANG) C.utf8
set env(LC_ALL) C.utf8

proc Hwm {} {
    if {[catch {open /proc/self/status r} f]} { return "" }
    set text [read $f]
    close $f
    if {[regexp {VmHWM:\s+(\d+) kB} $text -> kb]} { return "[expr {$kb / 1024}] MB" }
    return ""
}

proc Straight {n} {
    set lines {"import std::int" "import std::str" "" "fn f(seed: int) -> int:"}
    for {set i 0} {$i < $n} {incr i} {
        lappend lines "    s$i = std::int::to_string(seed + $i)"
        lappend lines "    n$i = std::str::length(s$i)"
    }
    lappend lines "    n0 + n[expr {$n - 1}]" "" "f(3)"
    return [join $lines \n]\n
}

proc ManyFunctions {n} {
    set lines {"import std::int" "import std::str" ""}
    for {set i 0} {$i < $n} {incr i} {
        lappend lines "fn g$i\(x) -> str:" "    std::int::to_string(std::str::length(x) + $i)" ""
    }
    lappend lines "fn run(seed: int) -> int:" "    t = std::int::to_string(seed)"
    for {set i 0} {$i < $n} {incr i} {
        lappend lines "    u$i = g$i\(t)"
    }
    lappend lines "    std::str::length(u0)" "" "run(3)"
    return [join $lines \n]\n
}

proc ManyYields {n} {
    set lines {"import std::coroutine" "import std::int" "import std::str" "" "fn w(seed: int) -> int:"}
    for {set i 0} {$i < $n} {incr i} {
        lappend lines "    s$i = std::int::to_string(seed + $i)"
        lappend lines "    yield std::str::length(s$i)"
    }
    lappend lines "    std::str::length(s0)" "" "coroutine {step, first} = w(3)" "\[first, step()\]"
    return [join $lines \n]\n
}

set workloads {}
foreach f [lsort [glob [file join $root audit storage-static-reuse cases *.bot]]] {
    if {[string match *p16b* $f]} continue
    lappend workloads [file rootname [file tail $f]] [list file $f]
}
lappend workloads 2048-demo [list file [file join $root examples games 2048 demo.bot]]
lappend workloads 2048-golden [list file [file join $root examples games 2048 golden.bot]]
lappend workloads icy-tower-golden [list file [file join $root examples games icy-tower golden.bot]]
foreach n {250 1000 4000} {
    lappend workloads straight-$n [list text [Straight $n]]
}
foreach n {50 200} {
    lappend workloads functions-$n [list text [ManyFunctions $n]]
}
foreach n {50 200 800} {
    lappend workloads yields-$n [list text [ManyYields $n]]
}
foreach kind {loops cond struct} {
    foreach n {100 200 400} {
        lappend workloads $kind-$n [list text [dict get [dsn::specimen $kind $n] source]]
    }
}

puts "| workload | compile ms | specialize ms | lifetime ms (best of [dict get $options -runs]) | units | nodes | constraints | producers confined/escapes/unknown | suspensions | VmHWM |"
puts "|---|---:|---:|---:|---:|---:|---:|---|---:|---:|"
foreach {name spec} $workloads {
    if {![string match [dict get $options -only] $name]} continue
    lassign $spec how what
    set t0 [clock milliseconds]
    if {$how eq "file"} {
        if {[catch {surface::readProgramFile $what -warnings off} hir]} {
            puts "| $name | does not compile | | | | | | | | |"
            continue
        }
    } else {
        set hir [surface::compile $what -warnings off]
    }
    set compile [expr {[clock milliseconds] - $t0}]
    set t0 [clock milliseconds]
    set spec [hir::specialize::analyze $hir]
    set specialize [expr {[clock milliseconds] - $t0}]
    set best ""
    for {set r 0} {$r < [dict get $options -runs]} {incr r} {
        set t0 [clock microseconds]
        set facts [hir::lifetime::analyze $hir -spec $spec]
        set t [expr {([clock microseconds] - $t0) / 1000.0}]
        if {$best eq "" || $t < $best} { set best $t }
    }
    set nodes 0
    set cons 0
    set susp 0
    set counts [dict create confined 0 escapes 0 unknown 0]
    foreach id [hir::lifetime::units $facts] {
        set u [hir::lifetime::unit $facts $id]
        incr nodes [dict get $u nodeCount]
        incr cons [dict get $u consCount]
        incr susp [llength [dict get $u suspensions]]
        dict for {site v} [dict get $u verdicts] {
            dict incr counts [dict get $v activation verdict]
        }
    }
    puts "| $name | $compile | $specialize | [format %.1f $best] | [llength [hir::lifetime::units $facts]] | $nodes | $cons |\
        [dict get $counts confined]/[dict get $counts escapes]/[dict get $counts unknown] | $susp | [Hwm] |"
    flush stdout
}
