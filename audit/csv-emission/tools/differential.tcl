# differential.tcl -- the CSV emitters against independent judges, on every
# backend (CSV-EMISSION-VALIDATION-MILESTONE-1.md, sections 9, 10, 13, 14
# and 17).
#
#   tclsh9.0 audit/csv-emission/tools/differential.tcl ?-part P? ?-seeds S?
#       ?-backends B? ?-length L? ?-cases N? ?-out FILE?
#
#   -part      corpus (the milestone's required input classes, named),
#              exhaustive (every string of length 0..L over the alphabet
#              {a , " CR LF}, as a field and inside a record), fuzz
#              (random documents, one batch per seed), or all (default)
#   -seeds     the fuzz seeds (default 1 2 3 4 5 6 7 8)
#   -backends  default interp compile cranelift-generic cranelift
#              cranelift-unfused (the native backend with coroutine fusion
#              off: every source on the general coroutine runtime)
#   -length    the exhaustive bound (default 5: 3,906 strings)
#   -cases     documents per fuzz seed (default 120)
#
# Every case runs on every backend (run.tcl), and:
#
#   1. every backend's outcome must be identical: status, failure position,
#      final value and every symbol;
#   2. the declared recognizer the source claims (the reference interpreter
#      over the declarations themselves) judges every trace: a completed
#      run is exactly one token, a failed one a viable prefix;
#   3. oracle.py, which reads no Botlish, judges each outcome: the expected
#      completion or failure, the reference serialization, its own strict
#      parser, CPython's csv reader and writer, strict UTF-8.
#
# Exits 1 on any disagreement or failed check.

set here [file dirname [file normalize [info script]]]
set options [dict merge {-part all -seeds {1 2 3 4 5 6 7 8} -backends {interp compile cranelift-generic cranelift cranelift-unfused}
    -length 5 -cases 120 -out ""} $argv]
set argv {}
source [file join [file dirname [file dirname [file dirname $here]]] tests helpers.tcl]
source [file join $::projectRoot surface surface.tcl]
source [file join $here run.tcl]
interp recursionlimit {} 100000
core::useProgramRecursionLimit

namespace eval diff {
    variable failures 0
    variable lines {}
    variable totals [dict create]
}

proc diff::out {line} {
    variable lines
    lappend lines $line
    puts $line
    flush stdout
}

proc diff::codes {s} {
    return [lmap ch [split $s ""] {scan $ch %c}]
}

# The corpus: each value as a field (every field kind), in each column of a
# record (every document kind), and all of them as one document's rows.
proc diff::Corpus {} {
    set values [csvrun::values]
    set cases {}
    set header [list [codes id] [codes value] [codes note]]
    dict for {name text} $values {
        set c [codes $text]
        foreach kind {strict_field utf8_field bytes_field selective_field} {
            lappend cases [list $kind $c]
        }
        lappend cases [list bytes_from_bytes [csvrun::Utf8 $c]]
        foreach col {0 1 2} {
            set row [list [codes $name] [codes x] [codes y]]
            lset row $col $c
            foreach kind {strict_document utf8_document bytes_document selective_document selective_strict_document} {
                lappend cases [list $kind [list $header $row]]
            }
            lappend cases [list bytes_unterminated [list $row $row]]
        }
    }
    # Zero, one and many records, and adjacent records with quotation marks
    # at their boundaries.
    foreach kind {bytes_stream bytes_unterminated} {
        lappend cases [list $kind {}]
        lappend cases [list $kind [list [list [codes a] [codes b] [codes c]]]]
        lappend cases [list $kind [list [list [codes "\""] {} [codes "x\""]] [list [codes "\"y"] [codes "\"\""] {}]]]
    }
    # Every value one profile represents, as the records of one document
    # (the others make a document fail at their first character, which the
    # cases above cover).
    set outsideB {nul control del nel}
    set outsideA [concat $outsideB {tab supplementary combining line-separators bom-inside latin1 cjk noncharacter}]
    foreach kind {strict_document utf8_document bytes_document selective_document selective_strict_document} {
        lappend cases [list $kind [list $header]]
        set outside [expr {[string match *strict* $kind] ? $outsideA : $outsideB}]
        set rows {}
        dict for {name text} $values {
            if {$name in $outside} continue
            lappend rows [list [codes $name] [codes $text] [codes "\"$name\""]]
        }
        lappend cases [list $kind [concat [list $header] $rows]]
    }
    # Invalid UTF-8 given as bytes: overlong, encoded surrogate, past
    # U+10FFFF, truncated, stray continuation.
    foreach bytes {{0xC0 0x80} {0xED 0xA0 0x80} {0xF4 0x90 0x80 0x80} {0x61 0xE2 0x82} {0x80 0x61} {0xFF}} {
        lappend cases [list bytes_from_bytes $bytes]
    }
    return $cases
}

# A random field of seed-driven length and character classes.
proc diff::Pools {} {
    return {
        ascii {97 98 120 32 48 57 65 90 126 33 35 43 45 61 64}
        separators {44 13 10}
        quotes {34}
        crlf {13 10}
        tab {9}
        latin {233 252 0xA0 0xFF 0x100}
        combining {0x301 0x303 0x94D}
        cjk {0x4E2D 0x6587 0xAC00}
        astral {0x1F600 0x10348 0x10FFFF 0x20000}
        lineseps {0x2028 0x2029}
        bom {0xFEFF}
        nonchar {0xFFFE 0xFFFF}
        unsupported {0 1 7 11 12 27 31 127 0x80 0x85 0x9F}
    }
}

proc diff::Field {strict} {
    set pools [Pools]
    if {$strict} {
        # Profile A's alphabet: ASCII only (an outsider is injected below).
        set weights {ascii 30 separators 6 quotes 8 crlf 4}
    } else {
        set weights {ascii 30 separators 6 quotes 8 crlf 4 tab 2 latin 4 combining 2 cjk 3 astral 3 lineseps 2 bom 1 nonchar 1}
    }
    set n [expr {int(rand() * rand() * 24)}]
    set out {}
    set total 0
    dict for {k w} $weights { incr total $w }
    for {set i 0} {$i < $n} {incr i} {
        set r [expr {int(rand() * $total)}]
        dict for {k w} $weights {
            if {$r < $w} break
            incr r -$w
        }
        set pool [dict get $pools $k]
        lappend out [expr {[lindex $pool [expr {int(rand() * [llength $pool])}]] + 0}]
        if {$k eq "crlf" && rand() < 0.5} {
            lappend out 13 10
        }
    }
    # One field in fifty holds a character its profile does not: an
    # unsupported one, or for Profile A any non-ASCII character.
    if {rand() < 0.02} {
        set pool [dict get $pools unsupported]
        if {$strict} {
            lappend pool 9 233 0x2028 0x1F600
        }
        set at [expr {int(rand() * ([llength $out] + 1))}]
        set out [linsert $out $at [expr {[lindex $pool [expr {int(rand() * [llength $pool])}]] + 0}]]
    }
    return $out
}

proc diff::Fuzz {seed count} {
    expr {srand($seed)}
    set cases {}
    set kinds {strict_document utf8_document bytes_document selective_document selective_strict_document bytes_stream bytes_unterminated}
    for {set i 0} {$i < $count} {incr i} {
        set kind [lindex $kinds [expr {$i % [llength $kinds]}]]
        set nrows [expr {int(rand() * 5)}]
        if {$kind ni {bytes_stream bytes_unterminated}} { incr nrows }
        set strict [string match *strict* $kind]
        set rows {}
        for {set r 0} {$r < $nrows} {incr r} {
            lappend rows [list [Field $strict] [Field $strict] [Field $strict]]
        }
        lappend cases [list $kind $rows]
    }
    return $cases
}

# Runs CASES (named TITLE) on every backend and every judge; RESULTS, when
# given, are their outcomes already (csvrun::exhaustive's).
proc diff::Check {title cases backends {results ""}} {
    variable failures
    variable totals
    set t0 [clock milliseconds]
    if {$results eq ""} {
        set results [csvrun::run $cases $backends]
    }
    set first [lindex $results 1]
    set disagree 0
    foreach {backend outcomes} $results {
        foreach c $cases a $first b $outcomes {
            if {$a ne $b} {
                incr disagree
                if {$disagree <= 5} {
                    out "  DISAGREE [lindex $c 0] [lindex $results 0] vs $backend: [lrange $a 0 3] / [lrange $b 0 3]"
                }
            }
        }
    }
    set invalid 0
    set statuses [dict create]
    foreach c $cases o $first {
        dict incr statuses [lindex $o 0]
        set v [csvrun::judge $c $o]
        if {$v ne "ok"} {
            incr invalid
            if {$invalid <= 5} {
                out "  RECOGNIZER [lindex $c 0]: [lindex $v 1]"
            }
        }
    }
    set path [file join [file tempdir] lines.txt]
    csvrun::write $path $cases $first
    set code [catch {exec python3 -I [file join $::here oracle.py] check $path} report]
    file delete -force [file dirname $path]
    set ms [expr {[clock milliseconds] - $t0}]
    out "  milliseconds: $::csvrun::timing"
    out "$title: [llength $cases] cases x [llength $backends] backends ([join [lmap {k v} $statuses {format "%s %d" $k $v}] {, }]); \
backends disagree $disagree; recognizer rejects $invalid; [expr {$ms / 1000.0}] s"
    foreach line [split $report \n] {
        out "    $line"
    }
    if {$code || $disagree || $invalid} {
        incr failures
    }
    dict incr totals cases [llength $cases]
    dict incr totals runs [expr {[llength $cases] * [llength $backends]}]
}

set part [dict get $options -part]
set backends [dict get $options -backends]
if {$part in {corpus all}} {
    diff::Check "corpus" [diff::Corpus] $backends
}
if {$part in {exhaustive all}} {
    set length [dict get $options -length]
    set t0 [clock milliseconds]
    lassign [csvrun::exhaustive $length $backends] cases results
    diff::Check "exhaustive (every string of length 0..$length over {a , \" CR LF}, in [expr {[llength $csvrun::exhaustive] / 2}] contexts)" \
        $cases $backends $results
}
if {$part in {fuzz all}} {
    foreach seed [dict get $options -seeds] {
        diff::Check "fuzz seed $seed" [diff::Fuzz $seed [dict get $options -cases]] $backends
    }
}
diff::out "total: [dict getdef $diff::totals cases 0] cases, [dict getdef $diff::totals runs 0] runs; [expr {$diff::failures ? "$diff::failures batches FAILED" : "every check passed"}]"
if {[dict get $options -out] ne ""} {
    set f [open [dict get $options -out] w]
    puts $f "# CSV emission: differential results\n\n```\n[join $diff::lines \n]\n```"
    close $f
}
exit [expr {$diff::failures ? 1 : 0}]
