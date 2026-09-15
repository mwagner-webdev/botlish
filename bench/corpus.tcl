# corpus.tcl -- baseline timings of the Botlish algorithm corpus
# (examples/stdlib/*.bot) on every backend.
#
#   tclsh bench/corpus.tcl [-runs N] [-markdown] [-all] [-backends {B ...}] [ALGORITHM ...]
#
# For each algorithm and input size, every backend runs the corpus program
# on the same deterministic input: once untimed (so the compiler's
# compilation is excluded), then N timed runs (default 3); the best run is
# reported, as wall time. Each measurement runs in a fresh tclsh process:
# the reference runtime never reclaims environments, so measurements in one
# process would disturb each other.
#
# The native backends compile once and run the program N times in their own
# process (native/src/main.rs, bench): the best run is the execution time.
# cranelift specializes functions (hir/specialize.tcl); cranelift-generic
# does not, and is the guarded baseline. Compilation is reported separately
# for each ("generic compile", "specialized compile"): native lowering in Tcl
# (HIR to NIR, including the specialization analysis) + Cranelift code
# generation and JIT linking. "code" is the machine code size and the
# number of NIR functions (generic -> specialized), "guards" the kind guards
# in the NIR. "alloc" is cranelift's allocation baseline (native/src/runtime/
# metrics.rs, summary mode, the last of the N timed runs): objects, bytes,
# peak live bytes, GC cycles -- a second compile+run per case, so it is
# measured for cranelift only, not cranelift-generic.
#
# Cases marked slow are skipped on the interpreter unless -all is given
# (shown as "skipped"). -markdown prints a Markdown table. Exits with
# status 1 if backends disagree on a value (compared by length and CRC-32 of
# its display form).
#
# A backend is a name corpus::run (examples/stdlib/corpus.tcl) understands.
#
# Internal: tclsh bench/corpus.tcl -measure ALGORITHM SIZE BACKEND RUNS
# prints "MICROSECONDS LENGTH CRC ?{LOWER-MICROSECONDS JIT-MICROSECONDS}
# {CODE-BYTES FUNCTIONS GUARDS} {ALLOCATIONS BYTES PEAK-BYTES GC-CYCLES
# STRING-BYTES-COPIED LIST-ELEMENTS-COPIED MUTABLE-ARRAY-ELEMENTS-COPIED
# MUTABLE-ARRAY-ALLOCATIONS}?" (the last two braced groups native backends
# only; the allocation group cranelift only, else {}).

set root [file dirname [file dirname [file normalize [info script]]]]
source [file join $root examples stdlib corpus.tcl]

namespace eval bench {}

# ---------------------------------------------------------------------------
# Deterministic inputs

# N characters cycling through a fixed alphabet.
proc bench::text {n} {
    set alphabet abcdefghijklmnopqrstuvwxyz0123456789
    set repeated [string repeat $alphabet [expr {$n / [string length $alphabet] + 1}]]
    return [string range $repeated 0 [expr {$n - 1}]]
}

# N characters of prose in which "fox" occurs every 45 characters.
proc bench::prose {n} {
    set sentence "the quick brown fox jumps over the lazy dog. "
    set repeated [string repeat $sentence [expr {$n / [string length $sentence] + 1}]]
    return [string range $repeated 0 [expr {$n - 1}]]
}

# A header and ROWS records mixing unquoted and quoted fields, commas and
# escaped quotes.
proc bench::csv {rows} {
    set lines [list {id,name,note,amount}]
    for {set i 1} {$i <= $rows} {incr i} {
        lappend lines [format {%d,user%d,"note %d, says ""hi""",%d} $i $i $i [expr {($i * 37) % 1000}]]
    }
    return "[join $lines \n]\n"
}

# An N x N matrix with small positive and negative entries.
proc bench::matrix {n seed} {
    set rows {}
    for {set i 0} {$i < $n} {incr i} {
        set row {}
        for {set j 0} {$j < $n} {incr j} {
            lappend row [expr {(($i * 7 + $j * $seed + $seed) % 19) - 9}]
        }
        lappend rows "\[[join $row {, }]\]"
    }
    return "\[[join $rows {, }]\]"
}

# Cases: ALGORITHM -> list of {SIZE-LABEL SLOW DRIVER-SCRIPT}. A driver
# script returns the driver source appended to the corpus program.
set bench::cases [dict create \
    string_reverse {
        {"100 chars"     0 {string cat "reverse_chars(" [corpus::literal [bench::text 100]] ")"}}
        {"1,000 chars"   0 {string cat "reverse_chars(" [corpus::literal [bench::text 1000]] ")"}}
        {"10,000 chars"  0 {string cat "reverse_chars(" [corpus::literal [bench::text 10000]] ")"}}
    } \
    string_replace {
        {"1 KB"   0 {string cat "replace(" [corpus::literal [bench::prose 1000]] ", \"fox\", \"red panda\")"}}
        {"10 KB"  0 {string cat "replace(" [corpus::literal [bench::prose 10000]] ", \"fox\", \"red panda\")"}}
        {"100 KB" 1 {string cat "replace(" [corpus::literal [bench::prose 100000]] ", \"fox\", \"red panda\")"}}
    } \
    csv {
        {"100 rows"    0 {string cat "csv_parse(" [corpus::literal [bench::csv 100]] ")"}}
        {"1,000 rows"  0 {string cat "csv_parse(" [corpus::literal [bench::csv 1000]] ")"}}
        {"10,000 rows" 1 {string cat "csv_parse(" [corpus::literal [bench::csv 10000]] ")"}}
    } \
    csv_geometric {
        {"100 rows"    0 {string cat "csv_parse(" [corpus::literal [bench::csv 100]] ")"}}
        {"1,000 rows"  0 {string cat "csv_parse(" [corpus::literal [bench::csv 1000]] ")"}}
        {"10,000 rows" 1 {string cat "csv_parse(" [corpus::literal [bench::csv 10000]] ")"}}
    } \
    csv_chunked {
        {"100 rows"    0 {string cat "csv_parse(" [corpus::literal [bench::csv 100]] ")"}}
        {"1,000 rows"  0 {string cat "csv_parse(" [corpus::literal [bench::csv 1000]] ")"}}
        {"10,000 rows" 1 {string cat "csv_parse(" [corpus::literal [bench::csv 10000]] ")"}}
    } \
    matmul {
        {"2x3 * 3x2" 0 {return "matmul(\[\[1, 2, 3\], \[4, 5, 6\]\], \[\[7, 8\], \[9, 10\], \[11, 12\]\])"}}
        {"8x8"       0 {string cat "matmul(" [bench::matrix 8 3] ", " [bench::matrix 8 5] ")"}}
        {"16x16"     0 {string cat "matmul(" [bench::matrix 16 3] ", " [bench::matrix 16 5] ")"}}
        {"32x32"     1 {string cat "matmul(" [bench::matrix 32 3] ", " [bench::matrix 32 5] ")"}}
    }]

proc bench::case {algorithm size} {
    variable cases
    foreach entry [dict get $cases $algorithm] {
        if {[lindex $entry 0] eq $size} {
            return $entry
        }
    }
    error "bench: no case \"$size\" for $algorithm"
}

# ---------------------------------------------------------------------------
# One measurement (in its own process)

proc bench::measure {algorithm size backend runs} {
    lassign [case $algorithm $size] _ _ script
    set driver [apply [list {} $script]]
    if {$backend in {cranelift cranelift-generic}} {
        set specialize [expr {$backend eq "cranelift"}]
        set hir [corpus::program $algorithm $driver]
        lassign [native::measure $hir $runs -specialize $specialize] lower jit best - value
        set shown [core::value::show $value 1]
        set lowered [native::lower::program $hir -specialize $specialize]
        set guards [regexp -all -line {^\s+guard(bool)? } [dict get $lowered text]]
        set stats [dict get $lowered statistics]
        set code [list [lindex [native::codeSize $hir -specialize $specialize] 0] \
            [llength [dict get $lowered functions]] $guards \
            [dict get $stats rawUnboxes] [dict get $stats rawBoxes] \
            [expr {[dict get $stats rawArith] + [dict get $stats rawCompare]}]]
        # Allocation baseline (native/src/runtime/metrics.rs), cranelift
        # (specialized) only: a second measurement (its own compile+run),
        # so this is skipped for cranelift-generic to keep the corpus run to
        # one extra process per case rather than two.
        set alloc ""
        if {$specialize} {
            set report [native::allocationReport $hir summary $runs -specialize $specialize]
            set total [dict get $report total]
            set copies [dict get $report copies]
            set alloc [list [dict get $total allocations] [dict get $total allocatedBytes] \
                [dict get $total peakLiveBytes] [dict get $report gc cycles] \
                [dict get $copies stringBytes] [dict get $copies listElements] \
                [dict get $copies mutableArrayElements] [dict get $report byKind MutableArray allocations]]
        }
        return [list $best [string length $shown] [zlib crc32 [encoding convertto utf-8 $shown]] \
            [list $lower $jit] $code $alloc]
    }
    set program [hir::lower [corpus::program $algorithm $driver]]
    core::useBackend $backend
    # The program runs as its lowered IR, whose HIR is the corpus program's
    # HIR (tests/surface-samples.test checks this for source programs).
    # core::evalProgram caches the compiled unit, so the untimed run keeps
    # compilation out of the timings.
    core::evalProgram $program
    set best ""
    for {set i 0} {$i < $runs} {incr i} {
        set micros [lindex [time {set value [core::evalProgram $program]}] 0]
        if {$best eq "" || $micros < $best} {
            set best $micros
        }
    }
    set shown [core::value::show $value 1]
    return [list $best [string length $shown] [zlib crc32 [encoding convertto utf-8 $shown]]]
}

if {[lindex $argv 0] eq "-measure"} {
    lassign $argv _ algorithm size backend runs
    puts [bench::measure $algorithm $size $backend $runs]
    exit 0
}

# ---------------------------------------------------------------------------
# Driver

set runs 3
set markdown 0
set all 0
set backends $corpus::backends
set algorithms {}
for {set i 0} {$i < [llength $argv]} {incr i} {
    switch -- [lindex $argv $i] {
        -runs     { set runs [lindex $argv [incr i]] }
        -markdown { set markdown 1 }
        -all      { set all 1 }
        -backends { set backends [lindex $argv [incr i]] }
        default   { lappend algorithms [lindex $argv $i] }
    }
}
if {$algorithms eq ""} {
    set algorithms [dict keys $bench::cases]
}

proc bench::cell {micros} {
    if {$micros eq ""} {
        return skipped
    }
    if {$micros < 1000} {
        return [format "%.3f ms" [expr {$micros / 1000.0}]]
    }
    return [format "%.1f ms" [expr {$micros / 1000.0}]]
}

# Cranelift compile time: native lowering + Cranelift JIT.
proc bench::compileCell {times} {
    if {$times eq ""} {
        return skipped
    }
    lassign $times lower jit
    return [format "%.1f + %.1f ms" [expr {$lower / 1000.0}] [expr {$jit / 1000.0}]]
}

# Native code: bytes/functions/guards/unboxes/boxes/raw-ops of the generic
# and specialized code (unboxes, boxes, raw-ops: hir/range.tcl's local
# unboxing, native/lower.tcl's "Representation" section).
proc bench::codeCell {generic specialized} {
    set parts {}
    foreach {index unit} {0 "B" 1 "fn" 2 "guards" 3 "unbox" 4 "box" 5 "rawops"} {
        set g [expr {$generic eq "" ? "-" : [lindex $generic $index]}]
        set s [expr {$specialized eq "" ? "-" : [lindex $specialized $index]}]
        lappend parts "$g->$s $unit"
    }
    return [join $parts ", "]
}

# N as a human-scaled byte count, for the alloc column and the baseline doc.
proc bench::formatBytes {n} {
    if {$n eq ""} {
        return "-"
    }
    if {$n >= 1000000} {
        return [format "%.1f MB" [expr {$n / 1000000.0}]]
    }
    if {$n >= 1000} {
        return [format "%.1f KB" [expr {$n / 1000.0}]]
    }
    return "$n B"
}

# cranelift's allocation baseline (native::allocationReport summary mode):
# ALLOC is {allocations bytes peakBytes gcCycles stringBytesCopied
# listElementsCopied mutableArrayElementsCopied mutableArrayAllocations}, ""
# when not measured (bench::measure's -specialize 0).
proc bench::allocCell {alloc} {
    if {$alloc eq ""} {
        return skipped
    }
    lassign $alloc allocations bytes peakBytes gcCycles stringCopied listCopied mutarrayCopied mutarrayAllocs
    set copies {}
    if {$stringCopied > 0} {
        lappend copies "[bench::formatBytes $stringCopied] str copied"
    }
    if {$listCopied > 0} {
        lappend copies "$listCopied list elems copied"
    }
    if {$mutarrayAllocs > 0} {
        lappend copies "$mutarrayAllocs mutarrays, $mutarrayCopied mutarray elems copied"
    }
    set suffix [expr {$copies eq "" ? "" : ", [join $copies {, }]"}]
    return "$allocations objs, [bench::formatBytes $bytes], peak [bench::formatBytes $peakBytes], $gcCycles gc$suffix"
}

# Columns: every backend, then the native compile times and code.
set columns $backends
set natives [lmap b {cranelift-generic cranelift} {if {$b ni $backends} continue; set b}]
foreach b $natives {
    lappend columns [dict get {cranelift-generic "generic compile" cranelift "specialized compile"} $b]
}
if {$natives ne ""} {
    lappend columns code
}
if {"cranelift" in $backends} {
    lappend columns alloc
}
# speedups: the Tcl compiler's time over cranelift's and cranelift-generic's
# over cranelift's when they run, else the interpreter's over the last
# backend's.
set speedups {}
foreach pair {{compile cranelift} {cranelift-generic cranelift}} {
    if {[lindex $pair 0] in $backends && [lindex $pair 1] in $backends} {
        lappend speedups $pair
    }
}
if {$speedups eq ""} {
    set speedups [list [list [lindex $backends 0] [lindex $backends end]]]
}
set speedupNames [lmap pair $speedups {join $pair /}]
if {$markdown} {
    puts "Tcl [info patchlevel], best of $runs runs, wall time, compilation excluded (compile columns: native lowering in Tcl + Cranelift JIT; code: generic -> specialized machine code bytes, NIR functions, kind guards).\n"
    puts "| algorithm | input | [join $columns { | }] | [join [lmap n $speedupNames {string cat "speedup ($n)"}] { | }] | values |"
    puts "|---|---|[string repeat ---:| [expr {[llength $columns] + [llength $speedups]}]]---|"
} else {
    puts [format "%-16s %-14s%s%s" algorithm input \
        [join [lmap b $columns {format " %21s" $b}] ""] [join [lmap n $speedupNames {format " %24s" $n}] ""]]
}

set disagreements 0
foreach algorithm $algorithms {
    foreach entry [dict get $bench::cases $algorithm] {
        lassign $entry size slow
        set times [dict create]
        set values {}
        set compileTimes [dict create cranelift "" cranelift-generic ""]
        set codes [dict create cranelift "" cranelift-generic ""]
        set allocs [dict create cranelift ""]
        foreach backend $backends {
            if {$slow && !$all && $backend eq "interp"} {
                dict set times $backend ""
                continue
            }
            set result [exec [info nameofexecutable] [info script] -measure $algorithm $size $backend $runs]
            dict set times $backend [lindex $result 0]
            lappend values [lrange $result 1 2]
            if {$backend in $natives} {
                dict set compileTimes $backend [lindex $result 3]
                dict set codes $backend [lindex $result 4]
            }
            if {$backend eq "cranelift"} {
                dict set allocs cranelift [lindex $result 5]
            }
        }
        set agree [expr {[llength [lsort -unique $values]] <= 1}]
        if {!$agree} {
            incr disagreements
        }
        set speedupCells [lmap pair $speedups {
            lassign $pair slower faster
            if {[dict get $times $slower] eq "" || [dict get $times $faster] eq ""} {
                string cat ""
            } else {
                format "%.1fx" [expr {double([dict get $times $slower]) / max(1, [dict get $times $faster])}]
            }
        }]
        set cells [lmap backend $backends {bench::cell [dict get $times $backend]}]
        foreach b $natives {
            lappend cells [bench::compileCell [dict get $compileTimes $b]]
        }
        if {$natives ne ""} {
            lappend cells [bench::codeCell [dict get $codes cranelift-generic] [dict get $codes cranelift]]
        }
        if {"cranelift" in $backends} {
            lappend cells [bench::allocCell [dict get $allocs cranelift]]
        }
        set check [expr {$agree ? "agree" : "DIFFER: $values"}]
        if {$markdown} {
            puts "| $algorithm | $size | [join $cells { | }] | [join $speedupCells { | }] | [expr {$agree ? "✅" : "❌ $check"}] |"
        } else {
            puts [format "%-16s %-14s%s%s  %s" $algorithm $size \
                [join [lmap c $cells {format " %21s" $c}] ""] [join [lmap c $speedupCells {format " %24s" $c}] ""] $check]
        }
        flush stdout
    }
}
exit [expr {$disagreements > 0}]
