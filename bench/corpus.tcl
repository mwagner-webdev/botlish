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
# Cases marked slow are skipped on the interpreter unless -all is given
# (shown as "skipped"). -markdown prints a Markdown table. Exits with
# status 1 if backends disagree on a value (compared by length and CRC-32 of
# its display form).
#
# A backend is a name corpus::run (examples/stdlib/corpus.tcl) understands;
# a future native backend is one more case there and one more column here.
#
# Internal: tclsh bench/corpus.tcl -measure ALGORITHM SIZE BACKEND RUNS
# prints "MICROSECONDS LENGTH CRC".

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
    return [format "%.1f ms" [expr {$micros / 1000.0}]]
}

if {$markdown} {
    puts "Tcl [info patchlevel], best of $runs runs, wall time, compilation excluded.\n"
    puts "| algorithm | input | [join $backends { | }] | speedup | values |"
    puts "|---|---|[string repeat ---:| [llength $backends]]---:|---|"
} else {
    puts [format "%-16s %-14s%s %9s" algorithm input \
        [join [lmap b $backends {format "%14s" $b}] ""] speedup]
}

set disagreements 0
foreach algorithm $algorithms {
    foreach entry [dict get $bench::cases $algorithm] {
        lassign $entry size slow
        set times {}
        set values {}
        foreach backend $backends {
            if {$slow && !$all && $backend eq "interp"} {
                lappend times ""
                continue
            }
            set result [exec [info nameofexecutable] [info script] -measure $algorithm $size $backend $runs]
            lappend times [lindex $result 0]
            lappend values [lrange $result 1 2]
        }
        set agree [expr {[llength [lsort -unique $values]] <= 1}]
        if {!$agree} {
            incr disagreements
        }
        set measured [lsearch -all -inline -not $times ""]
        set speedup ""
        if {[lindex $times 0] ne "" && [llength $measured] > 1} {
            set speedup [format "%.1fx" [expr {double([lindex $times 0]) / max(1, [lindex $times end])}]]
        }
        set cells [lmap micros $times {bench::cell $micros}]
        set check [expr {$agree ? "agree" : "DIFFER: $values"}]
        if {$markdown} {
            puts "| $algorithm | $size | [join $cells { | }] | $speedup | [expr {$agree ? "✅" : "❌ $check"}] |"
        } else {
            puts [format "%-16s %-14s%s %9s  %s" $algorithm $size \
                [join [lmap c $cells {format "%14s" $c}] ""] $speedup $check]
        }
        flush stdout
    }
}
exit [expr {$disagreements > 0}]
