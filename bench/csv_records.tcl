# csv_records.tcl -- benchmarks and metrics for the composed CSV-header-to
# -row-HashTable workload (examples/stdlib/csv_records.bot): the milestone
# that built it asks "what happens when CSV parsing and a mutable HashTable,
# each already benchmarked on its own (bench/corpus.tcl's csv/csv_geometric
# cases, bench/hashtable.tcl), are used together in ordinary application
# code?" -- so this script isolates row-table construction from parsing
# (req #43), compares default- and presized-capacity row tables (req #24),
# and counts repeated header hashing across rows (req #23), the same way
# bench/hashtable.tcl counts probes with a Tcl-side model of the identical
# algorithm rather than instrumenting hashtable.bot itself (req #50).
#
#   tclsh bench/csv_records.tcl [-rows N N N] [-cols N N N] [-runs N] [-all]
#
# Reports, per (rows, cols) size:
#
#   construction: wall time and allocation/GC metrics for csv-only,
#                 default-capacity row tables, and presized row tables
#                 (req #14, #21, #43, #56, #57)
#   presizing:    resizes/entries-rehashed/MutableArray-allocation delta
#                 between default and presized (req #24)
#   hashing:      hash calls, probe steps, comparisons -- from a Tcl-side
#                 model of the identical algorithm (req #22, #23, #29, #50),
#                 not from hashtable.bot itself
#   lookup:       optional post-construction read phase (req #40)
#
# and, once, a representative allocation-site (Sites mode) breakdown (req
# #42) and a fixed realistic schema case (req #27). -all also runs the
# largest (10,000 rows x 100 columns) corner, which is slow to compile from
# a single giant CSV string literal (like bench/corpus.tcl's own "10,000
# rows" CSV case) and skipped by default.

set root [file dirname [file dirname [file normalize [info script]]]]
source [file join $root core core.tcl]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]

interp recursionlimit {} 4000000

# ---------------------------------------------------------------------------
# The implementation under test, as a source prefix (definitions only, no
# trailing sample() call -- see bench/hashtable.tcl's identical header note).

set csvRecordsSource [regsub {\nsample\(\)\n$} \
    [core::ReadFile [file join $root examples stdlib csv_records.bot]] "\n"]

proc hirOf {text} {
    global csvRecordsSource
    return [surface::compile "$csvRecordsSource\n$text\n" bench.bot -strict 0]
}

# TEXT as a Botlish string literal (examples/stdlib/corpus.tcl's own
# corpus::literal, duplicated here so this script does not need to source
# the whole corpus module just for this one helper).
proc literal {text} {
    return "\"[string map {\\ \\\\ \" \\\" \n \\n \r \\r \t \\t} $text]\""
}

proc measureBest {text runs} {
    lassign [native::measure [hirOf $text] $runs] lower compile best collections value
    return [list $best $value]
}

proc allocationsOf {text} {
    return [native::allocationReport [hirOf $text] summary]
}

# ---------------------------------------------------------------------------
# Deterministic CSV generation (Tcl-side: Botlish has no Int -> String
# conversion -- see bench/hashtable.tcl's identical note -- so datasets are
# built here, not by a Botlish loop).

# COLS header names: column0, column1, ...
proc genHeaders {cols} {
    set headers {}
    for {set j 0} {$j < $cols} {incr j} {
        lappend headers "column$j"
    }
    return $headers
}

# A header row of COLS columns and ROWS data rows, each cell "rIcJ" (row I,
# column J) -- distinct per cell, ASCII-only (quoting is covered separately
# in tests/stdlib.test and tests/native-csv-records.test, not benchmarked
# here: quoting cost belongs to the CSV scanner, already isolated by req
# #43's csv-only column).
proc genCsv {rows cols} {
    set headers [genHeaders $cols]
    set lines [list [join $headers ,]]
    for {set i 0} {$i < $rows} {incr i} {
        set fields {}
        for {set j 0} {$j < $cols} {incr j} {
            lappend fields "r${i}c${j}"
        }
        lappend lines [join $fields ,]
    }
    return "[join $lines \n]\n"
}

# The fixed realistic schema (req #27): a small, human-shaped header instead
# of mechanically similar column names.
proc genRealisticCsv {rows} {
    set headers {id name email city country status created_at}
    set statuses {active pending suspended closed}
    set cities {Berlin Hamburg Munich Cologne Leipzig}
    set lines [list [join $headers ,]]
    for {set i 0} {$i < $rows} {incr i} {
        set status [lindex $statuses [expr {$i % [llength $statuses]}]]
        set city [lindex $cities [expr {$i % [llength $cities]}]]
        lappend lines [format {%d,user%d,user%d@example.com,%s,Germany,%s,2024-01-%02d} \
            $i $i $i $city $status [expr {($i % 28) + 1}]]
    }
    return "[join $lines \n]\n"
}

# ---------------------------------------------------------------------------
# Program text generators. Every program ends in a scalar (list_length, or a
# small list of Ints/Strings) -- the native backend cannot return a
# MutableArray-backed value straight to the host (see csv_records.bot's own
# tables), so a bare csv_records(...) is never the program's final value.

proc csvOnlyProgram {text} {
    return "list_length(csv_parse([literal $text]))"
}

proc recordsProgram {text presized} {
    set ctor [expr {$presized ? "csv_records_presized" : "csv_records"}]
    return "list_length(${ctor}([literal $text]))"
}

# Builds ROWS row tables (presized or not), then performs one lookup per row
# of a first, a middle-ish and a last header, plus one guaranteed-missing
# key -- a small, realistic post-construction read phase (req #40).
proc lookupProgram {text cols presized} {
    set ctor [expr {$presized ? "csv_records_presized" : "csv_records"}]
    set last [expr {$cols - 1}]
    set mid [expr {$cols / 2}]
    return "
fn lookupRow(rows, i, n):
    if i >= n:
        return unit
    r = list_get(rows, i)
    ht_get(r, \"column0\")
    ht_get(r, \"column$mid\")
    ht_get(r, \"column$last\")
    ht_get(r, \"missing_column\")
    lookupRow(rows, i + 1, n)

fn f():
    rows = ${ctor}([literal $text])
    lookupRow(rows, 0, list_length(rows))
    list_length(rows)
f()
"
}

# ---------------------------------------------------------------------------
# Tcl-side model of the identical algorithm (bench/hashtable.tcl's own
# convention: see this file's header and req #29, #50): R rows, each
# inserting the SAME C header keys (in header order) into a fresh table.
# Counts hash calls, probe steps (control-slot visits), comparisons (key ==
# comparisons at OCCUPIED slots), resizes and entries rehashed, accumulated
# across every row -- req #23's "hash calls per inserted field" falls out of
# hashCalls / (rows * cols).

proc modelHash {v} {
    return [core::value::intOf [lindex [core::native::invoke [core::value::native hash] [list $v]] 1]]
}

# ht_capacity_for's identical doubling rule (hashtable.bot), in Tcl.
proc modelCapacityFor {expected capacity} {
    while {$expected * 3 > $capacity * 2} {
        set capacity [expr {$capacity * 2}]
    }
    return $capacity
}

# One row's worth of inserts (the COLS header keys, in order) into a fresh
# table starting at STARTCAPACITY, folding hashCalls/probeSteps/comparisons/
# resizes/entriesRehashed into COUNTERS (a Tcl dict, updated in place via
# upvar). Mirrors hashtable.bot's ht_set/ht_should_grow/ht_grow_or_clean
# exactly (only inserts occur here: a fresh row table never deletes, so
# tombstones never enter into it). Keeps an explicit slot -> header-index
# array alongside controls, so a resize's rehash step knows exactly which
# header (and therefore which hash) occupied each slot.
proc modelBuildRow {headerHashes startCapacity countersVar} {
    upvar 1 $countersVar counters
    set capacity $startCapacity
    set controls [lrepeat $capacity 0]
    set slotHeader [lrepeat $capacity -1]
    set size 0
    set headerIndex 0
    foreach h $headerHashes {
        dict incr counters hashCalls
        set index [expr {$h % $capacity}]
        while 1 {
            dict incr counters probeSteps
            set state [lindex $controls $index]
            if {$state == 0} {
                break
            }
            dict incr counters comparisons
            set index [expr {($index + 1) % $capacity}]
        }
        set occupied $size
        if {($occupied + 1) * 3 > $capacity * 2} {
            set newCapacity [expr {$capacity * 2}]
            set newControls [lrepeat $newCapacity 0]
            set newSlotHeader [lrepeat $newCapacity -1]
            for {set j 0} {$j < $capacity} {incr j} {
                if {[lindex $controls $j] != 1} {
                    continue
                }
                set hi [lindex $slotHeader $j]
                set oldHash [lindex $headerHashes $hi]
                dict incr counters hashCalls
                dict incr counters entriesRehashed
                set idx [expr {$oldHash % $newCapacity}]
                while {[lindex $newControls $idx] != 0} {
                    set idx [expr {($idx + 1) % $newCapacity}]
                }
                lset newControls $idx 1
                lset newSlotHeader $idx $hi
            }
            dict incr counters resizes
            set capacity $newCapacity
            set controls $newControls
            set slotHeader $newSlotHeader
            set index [expr {$h % $capacity}]
            while {[lindex $controls $index] != 0} {
                set index [expr {($index + 1) % $capacity}]
            }
        }
        lset controls $index 1
        lset slotHeader $index $headerIndex
        incr size
        incr headerIndex
    }
}

# ROWS rows of COLS header keys ("column0".."column{COLS-1}"), each row a
# fresh table starting at STARTCAPACITY (ht_min_capacity()'s 8 for the
# default variant, modelCapacityFor(cols, 8) for the presized variant):
# total hashCalls/probeSteps/comparisons/resizes/entriesRehashed.
proc modelBuild {rows cols presized} {
    set headers [genHeaders $cols]
    set headerHashes [lmap h $headers {modelHash [core::value::str $h]}]
    set startCapacity [expr {$presized ? [modelCapacityFor $cols 8] : 8}]
    set counters [dict create hashCalls 0 probeSteps 0 comparisons 0 resizes 0 entriesRehashed 0]
    for {set i 0} {$i < $rows} {incr i} {
        modelBuildRow $headerHashes $startCapacity counters
    }
    dict set counters startCapacity $startCapacity
    return $counters
}

# ---------------------------------------------------------------------------
# Report

proc mutarrayAllocations {report} {
    return [dict get $report byKind MutableArray allocations]
}

proc row {args} {
    puts [format "  %-14s %-10s %14s %12s %12s %10s %10s" {*}$args]
}

proc rowf {fmt args} {
    puts [format $fmt {*}$args]
}

# One (rows, cols) size: csv-only / default / presized construction, then
# the presizing and hashing breakdowns, then the optional lookup phase.
proc reportSize {rows cols runs} {
    puts "--- $rows rows x $cols columns ---"
    set text [genCsv $rows $cols]

    row variant allocs allocatedBytes {peak live} {GC cycles} mutarrays time-us
    foreach {label program} [list \
        csv-only   [csvOnlyProgram $text] \
        default    [recordsProgram $text 0] \
        presized   [recordsProgram $text 1]] {
        set report [allocationsOf $program]
        lassign [measureBest $program $runs] best value
        set total [dict get $report total]
        row $label [dict get $total allocations] [dict get $total allocatedBytes] \
            [dict get $total peakLiveBytes] [dict get $report gc cycles] \
            [mutarrayAllocations $report] $best
    }
    puts ""

    set defaultReport [allocationsOf [recordsProgram $text 0]]
    set presizedReport [allocationsOf [recordsProgram $text 1]]
    set defaultMutarrays [mutarrayAllocations $defaultReport]
    set presizedMutarrays [mutarrayAllocations $presizedReport]
    # Each resize allocates exactly 3 replacement MutableArrays
    # (hashtable.bot's ht_rehash); every table (default or presized) starts
    # with 4 (ht_alloc) and the outer GeometricBuilder adds a few more of
    # its own, identical between the two variants -- so the raw allocation
    # *delta* between them is exactly 3 * (resizes saved by presizing).
    rowf "  presizing: %d fewer MutableArray allocations (%d default -> %d presized), i.e. %d fewer resizes across %d rows" \
        [expr {$defaultMutarrays - $presizedMutarrays}] $defaultMutarrays $presizedMutarrays \
        [expr {($defaultMutarrays - $presizedMutarrays) / 3}] $rows
    puts ""

    puts "  hashing/probing (Tcl-side model of the identical algorithm; see file header)"
    row {} startCap hashCalls probeSteps comparisons resizes entriesRehashed
    foreach presized {0 1} {
        set counters [modelBuild $rows $cols $presized]
        set label [expr {$presized ? "presized" : "default"}]
        row $label [dict get $counters startCapacity] [dict get $counters hashCalls] \
            [dict get $counters probeSteps] [dict get $counters comparisons] \
            [dict get $counters resizes] [dict get $counters entriesRehashed]
    }
    set naive [expr {$rows * $cols}]
    set defaultCounters [modelBuild $rows $cols 0]
    rowf "  hash calls per inserted field: %.3f (R*C = %d; default variant's own hashCalls = %d)" \
        [expr {double([dict get $defaultCounters hashCalls]) / $naive}] $naive [dict get $defaultCounters hashCalls]
    puts ""

    puts "  lookup phase (4 reads/row: first, middle, last header, one guaranteed miss)"
    row {} {} {} {} {} {} time-us
    foreach presized {0 1} {
        set label [expr {$presized ? "presized" : "default"}]
        lassign [measureBest [lookupProgram $text $cols $presized] $runs] best value
        row $label {} {} {} {} {} $best
    }
    puts ""
}

# ---------------------------------------------------------------------------
# Allocation-site profiling (req #42): one representative, moderate-size
# dataset, Sites mode.

proc reportSites {rows cols} {
    puts "--- allocation sites: $rows rows x $cols columns, default-capacity row tables ---"
    set report [native::allocationReport [hirOf [recordsProgram [genCsv $rows $cols] 0]] sites]
    puts [native::allocationText $report 12]
    puts ""
}

# ---------------------------------------------------------------------------
# The fixed realistic schema (req #27).

proc reportRealistic {rows runs} {
    puts "--- realistic schema (id,name,email,city,country,status,created_at): $rows rows ---"
    set text [genRealisticCsv $rows]
    row variant allocs allocatedBytes {peak live} {GC cycles} mutarrays time-us
    foreach {label program} [list \
        csv-only [csvOnlyProgram $text] \
        default  [recordsProgram $text 0] \
        presized [recordsProgram $text 1]] {
        set report [allocationsOf $program]
        lassign [measureBest $program $runs] best value
        set total [dict get $report total]
        row $label [dict get $total allocations] [dict get $total allocatedBytes] \
            [dict get $total peakLiveBytes] [dict get $report gc cycles] \
            [mutarrayAllocations $report] $best
    }
    puts ""
}

# ---------------------------------------------------------------------------
# Driver

set rowSizes {100 1000}
set colSizes {5 20}
set runs 3
set all 0
for {set i 0} {$i < [llength $argv]} {incr i} {
    switch -- [lindex $argv $i] {
        -rows { set rowSizes {} ; incr i ; while {$i < [llength $argv] && [string is integer [lindex $argv $i]]} { lappend rowSizes [lindex $argv $i] ; incr i } ; incr i -1 }
        -cols { set colSizes {} ; incr i ; while {$i < [llength $argv] && [string is integer [lindex $argv $i]]} { lappend colSizes [lindex $argv $i] ; incr i } ; incr i -1 }
        -runs { set runs [lindex $argv [incr i]] }
        -all  { set all 1 }
    }
}
if {$all} {
    if {10000 ni $rowSizes} { lappend rowSizes 10000 }
    if {100 ni $colSizes} { lappend colSizes 100 }
}

foreach rows $rowSizes {
    foreach cols $colSizes {
        # The largest corner (many rows, wide rows) is slow to compile from
        # one giant CSV string literal -- skip it unless -all asked for it
        # explicitly (matching bench/corpus.tcl's own "slow" convention).
        if {$rows >= 10000 && $cols >= 100 && !$all} {
            puts "--- $rows rows x $cols columns: skipped (pass -all to run) ---"
            continue
        }
        reportSize $rows $cols $runs
    }
}

# The smallest configured size, not the largest: sites mode is for a
# representative sample (req #42), and req #55 asks not to run every large
# matrix point in sites mode -- the scaling numbers above already cover the
# large corners in summary mode.
reportSites [lindex [lsort -integer $rowSizes] 0] [lindex [lsort -integer $colSizes] 0]
reportRealistic 1000 $runs
