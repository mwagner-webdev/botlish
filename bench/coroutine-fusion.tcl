# coroutine-fusion.tcl -- the coroutine fusion performance report
# (COROUTINE-FUSION-MILESTONE-1.md, "Performance").
#
#   tclsh9.0 bench/coroutine-fusion.tcl ?-runs N? ?-rounds R?
#                                       ?-workloads LIST? ?-scale F?
#
# Every workload of audit/coroutine-fusion/programs/ three ways, natively:
#
#   general     its coroutines on the general runtime
#               (BOTLISH_NATIVE_COROUTINE_FUSION=0: a stack, a switch and a
#               runtime call per segment)
#   fused       the same program as the driver compiles it by default
#   procedural  its hand-written baseline without coroutines (NAME-
#               procedural.bot), doing the same work
#
# at three sizes each (-scale multiplies them). A time is the best of RUNS
# in-process runs (botlish-native bench: compilation excluded); each variant
# runs in ROUNDS driver processes, interleaved (general, fused, procedural,
# general, ...), and the report gives the minimum and the median over them,
# per item (a generated value, a grid cell, an input character or byte, a
# frame: utf8 validates N bytes its pattern function generates, so no
# input List is built). Then, per workload at its middle size: allocations (all objects,
# and coroutine objects and stacks), the driver's peak resident memory,
# machine code size (botlish-native size), and compile times (native
# lowering, then the driver: fusion and Cranelift).

set root [file dirname [file dirname [file normalize [info script]]]]
set args $argv
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
interp recursionlimit {} 200000

set runs 5
set rounds 5
set scale 1.0
set workloads {lcg lcg-struct grid tokens utf8 held}
foreach {option value} $args {
    switch -- $option {
        -runs { set runs $value }
        -rounds { set rounds $value }
        -workloads { set workloads $value }
        -scale { set scale $value }
        default { error "unknown option $option" }
    }
}

set programs [file join $root audit coroutine-fusion programs]

# The workload's sizes (items), and its program text at size N.
proc sizes {name} {
    set base [dict get {lcg {10000 100000 1000000} lcg-struct {10000 100000 1000000}
        grid {10000 100000 1000000} tokens {2000 20000 200000} utf8 {2000 20000 200000}
        held {1000 5000 20000}} $name]
    return [lmap n $base {expr {max(1, int($n * $::scale))}}]
}

proc source {name} {
    return [string trimright [core::ReadFile [file join $::programs $name.bot]] \n]
}

# The JSON-like text tokens.bot reads, about N characters long.
proc jsonText {n} {
    set piece {{"a": [1, -2.5, 30], "b\"c": {"d": 400}, "e": [6.0, 7]}, }
    set text [string repeat $piece [expr {max(1, $n / [string length $piece])}]]
    return [string map {\\ \\\\ \" \\\"} $text]
}

# Program FILE (a workload or its baseline) at size N: its last call's
# argument replaced, or its input made N long.
proc programAt {file n} {
    set text [source $file]
    set lines [split $text \n]
    switch -glob -- $file {
        grid* {
            set last "total(100, [expr {max(1, $n / 100)}])"
            return [join [lreplace $lines end end $last] \n]\n
        }
        tokens* {
            set at [lsearch -glob $lines {lex(*}]
            return [join [lreplace $lines $at $at "lex(\"[jsonText $n]\"):"] \n]\n
        }
        utf8* {
            set at [lsearch -glob $lines {\[validate(*}]
            set head [lrange $lines 0 [expr {$at - 1}]]
            return "[join $head \n]\nvalidate_pattern($n)\n"
        }
        default {
            set last [lindex $lines end]
            regsub {\(\d+\)$} $last "($n)" last
            return [join [lreplace $lines end end $last] \n]\n
        }
    }
}

proc compileText {text} {
    return [surface::compile $text -warnings off]
}

# {LOWER-US COMPILE-US BEST-US VALUE} of HIR natively, fusion on or off.
proc measure {hir fused} {
    if {$fused} {
        return [native::measure $hir $::runs]
    }
    return [withoutCoroutineFusion {native::measure $hir $::runs}]
}

proc median {values} {
    set sorted [lsort -real $values]
    return [lindex $sorted [expr {[llength $sorted] / 2}]]
}

# The driver's peak resident memory (KiB) running HIR.
proc peakKiB {hir fused} {
    set text [native::nir $hir]
    lassign [file tempfile path botlish-bench.nir] channel
    puts -nonewline $channel $text
    close $channel
    set script {
import resource, subprocess, sys
subprocess.run(sys.argv[1:], stdout=subprocess.DEVNULL, check=True)
print(resource.getrusage(resource.RUSAGE_CHILDREN).ru_maxrss)
}
    try {
        if {$fused} {
            set out [exec python3 -c $script [native::binary] run $path]
        } else {
            set out [withoutCoroutineFusion {exec python3 -c $script [native::binary] run $path}]
        }
    } finally {
        file delete $path
    }
    return [string trim $out]
}

proc codeSize {hir fused} {
    set line [lindex [if {$fused} {native::Driver size [native::nir $hir]} else {
        withoutCoroutineFusion {native::Driver size [native::nir $hir]}
    }] 0]
    return [lindex $line 1]
}

proc allocations {hir fused} {
    if {$fused} {
        set report [native::allocationReport $hir summary]
    } else {
        set report [withoutCoroutineFusion {native::allocationReport $hir summary}]
    }
    set all 0
    dict for {kind info} [dict get $report byKind] {
        incr all [dict get $info allocations]
    }
    set coroutines [expr {[dict exists $report byKind Coroutine] ? [dict get $report byKind Coroutine allocations] : 0}]
    set stacks [expr {[dict exists $report coroutines] ? [dict get $report coroutines stacksMapped] + [dict get $report coroutines stacksReused] : 0}]
    return [list $all $coroutines $stacks]
}

puts "# Coroutine fusion: general runtime, fused, procedural"
puts ""
puts "best of $runs in-process runs; minimum and median over $rounds interleaved driver processes; ns per item"
puts ""
puts "| workload | items | general min | general med | fused min | fused med | procedural min | procedural med | fused / procedural | general / fused |"
puts "|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|"
set middle [dict create]
foreach name $workloads {
    foreach n [sizes $name] {
        set coroutine [compileText [programAt $name $n]]
        set baseline [compileText [programAt $name-procedural $n]]
        set times [dict create general {} fused {} procedural {}]
        set values {}
        for {set r 0} {$r < $rounds} {incr r} {
            foreach {variant hir fused} [list general $coroutine 0 fused $coroutine 1 procedural $baseline 1] {
                lassign [measure $hir $fused] lower compile best collections value
                dict lappend times $variant [expr {$best * 1000.0 / $n}]
                lappend values $value
            }
        }
        if {[llength [lsort -unique $values]] != 1} {
            error "$name at $n: the variants disagree: [lsort -unique $values]"
        }
        set row [list $name $n]
        foreach variant {general fused procedural} {
            set ts [dict get $times $variant]
            lappend row [format %.2f [tcl::mathfunc::min {*}$ts]] [format %.2f [median $ts]]
        }
        set ratio [format %.2f [expr {[median [dict get $times fused]] / [median [dict get $times procedural]]}]]
        set speedup [format %.1f [expr {[median [dict get $times general]] / [median [dict get $times fused]]}]]
        puts "| [join $row { | }] | $ratio | $speedup |"
    }
}

puts ""
puts "## Resources (middle size)"
puts ""
puts "| workload | variant | allocations | coroutine objects | stacks | peak RSS KiB | code bytes | lower ms | driver compile ms |"
puts "|---|---|---:|---:|---:|---:|---:|---:|---:|"
foreach name $workloads {
    set n [lindex [sizes $name] 1]
    set coroutine [compileText [programAt $name $n]]
    set baseline [compileText [programAt $name-procedural $n]]
    foreach {variant hir fused} [list general $coroutine 0 fused $coroutine 1 procedural $baseline 1] {
        lassign [allocations $hir $fused] all coroutines stacks
        set compiles {}
        set lowers {}
        for {set r 0} {$r < 3} {incr r} {
            lassign [measure $hir $fused] lower compile
            lappend lowers [expr {$lower / 1000.0}]
            lappend compiles [expr {$compile / 1000.0}]
        }
        puts "| $name | $variant | $all | $coroutines | $stacks | [peakKiB $hir $fused] | [codeSize $hir $fused] | [format %.1f [median $lowers]] | [format %.1f [median $compiles]] |"
    }
}
