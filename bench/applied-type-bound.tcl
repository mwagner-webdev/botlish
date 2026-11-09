# applied-type-bound.tcl -- the performance report of the local exact check
# of applications past the applied-type bound
# (APPLIED-TYPE-BOUND-PRECISION-MILESTONE-1.md, "Performance").
#
#   tclsh9.0 bench/applied-type-bound.tcl ?-sizes {100 200 400 800 1000}?
#       ?-frontend 1? ?-baseline DIR? ?-runs 3?
#
# Deep specimens at every size N, each compiled in a fresh process (so its
# peak memory is its own: VmHWM):
#
#   inferred   Box {value: ... 1} N deep, read back through x.value^N
#   written    the same held to a parameter written Box[...int...] N deep
#   mismatch   a String at the leaf against that parameter (rejected at the
#              leaf: the exact path's whole work)
#
# For each: whether it compiled, the front end's wall time (milliseconds),
# peak memory (MB), the HIR's type-table size (types, characters) and the
# exact machinery's counters (evidence applications built, comparisons,
# admissions, projections). With -frontend 1, the front end's cost on real
# programs (golden suites of parameterized structs, Hashable, identity,
# maps, structs, enums, coroutines, affine values and the 2048 workload),
# median of -runs compilations in a fresh process each, here and in the
# checkout -baseline DIR (the revision before this milestone).

set root [file dirname [file dirname [file normalize [info script]]]]
array set opt {-sizes {100 200 400 800 1000} -frontend 1 -baseline "" -runs 3 -child ""}
array set opt $argv

proc specimen {kind n} {
    set s 1
    set t int
    for {set i 0} {$i < $n} {incr i} {
        set s "Box \{value: $s\}"
        set t "Box\[$t\]"
    }
    set decls "struct Box\[T\]:\n    value: T\n\n"
    switch -- $kind {
        inferred { return "${decls}x = $s\nx[string repeat .value $n]\n" }
        written { return "${decls}fn f(x: $t) -> int:\n    1\nf($s)\n" }
        mismatch {
            return "${decls}fn f(x: $t) -> int:\n    1\nf([string map {"value: 1" "value: \"s\""} $s])\n"
        }
    }
}

proc peakMB {} {
    set f [open /proc/self/status]
    set text [read $f]
    close $f
    regexp {VmHWM:\s+(\d+)} $text -> kb
    return [format %.0f [expr {$kb / 1024.0}]]
}

if {$opt(-child) ne ""} {
    # One measurement in this fresh process: KIND N ROOT, or a suite FILE ROOT.
    lassign $opt(-child) what arg tree
    set ::argv0 bench
    source [file join $tree compiler compiler.tcl]
    source [file join $tree surface surface.tcl]
    set exact [expr {[info commands hir::applied::ResetStats] ne ""}]
    if {$what eq "suite"} {
        set t [clock microseconds]
        catch {surface::readProgramFile $arg -warnings off}
        puts [expr {([clock microseconds] - $t) / 1000}]
        exit 0
    }
    if {$exact} {
        hir::applied::ResetStats
    }
    set t [clock microseconds]
    set ok [expr {![catch {surface::compile [specimen $what $arg] -warnings off} hir]}]
    set ms [expr {([clock microseconds] - $t) / 1000}]
    set types 0
    set chars 0
    if {$ok} {
        foreach type [dict get $hir types] {
            incr types
            incr chars [string length $type]
        }
    }
    set stats [expr {$exact ? [hir::applied::Stats] : {}}]
    puts [list $ok $ms [peakMB] $types $chars [dict getdef $stats apps 0] [dict getdef $stats compares 0] \
        [dict getdef $stats accepts 0] [dict getdef $stats projections 0]]
    exit 0
}

proc child {args} {
    return [exec [info nameofexecutable] [info script] -child $args 2>@1]
}

puts "## Deep specimens ([file tail $root])\n"
puts "| specimen | N | compiled | ms | peak MB | types | type chars | apps | compares | accepts | projections |"
puts "|---|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|"
foreach kind {inferred written mismatch} {
    foreach n $opt(-sizes) {
        lassign [child $kind $n $root] ok ms mb types chars apps compares accepts projections
        puts "| $kind | $n | [expr {$ok ? "yes" : "no"}] | $ms | $mb | $types | $chars | $apps | $compares | $accepts | $projections |"
        flush stdout
    }
}

if {$opt(-frontend)} {
    set suites {
        tests/golden/trait-constrained-types.bot tests/golden/hashable.bot tests/golden/value-identity.bot
        tests/golden/immutable-map.bot tests/golden/mutable-map.bot tests/golden/structs.bot
        tests/golden/enums.bot tests/golden/coroutines.bot tests/golden/affine.bot
        examples/games/2048/golden.bot
    }
    set trees [list $root]
    if {$opt(-baseline) ne ""} {
        lappend trees [file normalize $opt(-baseline)]
    }
    puts "\n## Front end on real programs (median of $opt(-runs) fresh processes, ms)\n"
    puts "| program | [join [lmap t $trees {file tail $t}] { | }] |"
    puts "|---|[join [lrepeat [llength $trees] ---:] |]|"
    foreach suite $suites {
        set row {}
        foreach tree $trees {
            set file [file join $tree $suite]
            if {![file exists $file]} {
                lappend row -
                continue
            }
            set times [lsort -integer [lmap _ [lrepeat $opt(-runs) x] {child suite $file $tree}]]
            lappend row [lindex $times [expr {[llength $times] / 2}]]
        }
        puts "| [file tail $suite] | [join $row { | }] |"
        flush stdout
    }
}
