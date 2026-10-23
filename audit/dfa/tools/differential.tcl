# differential.tcl -- the JSON workload of the DFA prototype against an
# independent implementation (DFA-COROUTINE-EXPLORATION.md, "Correctness").
#
#   tclsh9.0 audit/dfa/tools/differential.tcl ?-suite DIR? ?-fuzz N?
#       ?-seed S | -seeds FIRST-LAST? ?-out FILE? ?-regressions FILE? ?-app DIR?
#
# Builds audit/dfa/json/conformance.bot as a standalone executable (a
# private copy of the application directory: nothing is written beside
# it), then runs it on
#
#   * every file of DIR (JSONTestSuite's test_parsing directory, cloned from
#     https://github.com/nst/JSONTestSuite: y_ files must be accepted, n_
#     files rejected, i_ files are implementation-defined), and
#   * N generated cases per seed (S, or each of FIRST..LAST): random JSON texts -- nested values, every
#     number form, strings with every escape, surrogate pairs and lone
#     surrogate escapes, raw characters of 1 to 4 UTF-8 bytes -- most of
#     them then mutated at the byte level (a byte replaced by an
#     interesting one, inserted, deleted, a span duplicated, a truncation),
#
# each validated whole and cut into random chunks, and compares every
# verdict with audit/dfa/tools/oracle.py (CPython's json, made strict). It
# writes a report (-out, default: standard output) and every case on which
# the two disagree, or the whole and the chunked runs do, to the
# regressions file (hex, one per line; default none). Exit status 1 on any
# disagreement other than the documented resource limits. -app DIR takes
# any of the application's modules found in DIR instead (a mutated
# json_lex.bot: audit/dfa/tools/mistakes.tcl).

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set options [dict create -suite "" -fuzz 0 -seed 1 -seeds "" -out "" -regressions "" -app ""]
foreach {option value} $argv {
    if {![dict exists $options $option]} {
        puts stderr "unknown option $option"
        exit 2
    }
    dict set options $option $value
}
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
source [file join $root audit dfa tests support.tcl]

# ---------------------------------------------------------------------------
# Generated cases.

proc pick {list} {
    return [lindex $list [expr {int(rand() * [llength $list])}]]
}

proc chance {p} {
    return [expr {rand() < $p}]
}

proc genNumber {} {
    set text [expr {[chance 0.3] ? "-" : ""}]
    if {[chance 0.2]} {
        append text 0
    } else {
        append text [expr {1 + int(rand() * 9)}]
        for {set k [expr {int(rand() * 4)}]} {$k > 0} {incr k -1} {
            append text [expr {int(rand() * 10)}]
        }
    }
    if {[chance 0.4]} {
        append text .
        for {set k [expr {1 + int(rand() * 3)}]} {$k > 0} {incr k -1} {
            append text [expr {int(rand() * 10)}]
        }
    }
    if {[chance 0.3]} {
        append text [pick {e E}] [pick {"" + -}] [expr {int(rand() * 40)}]
    }
    return $text
}

proc genString {} {
    set text \"
    for {set k [expr {int(rand() * 6)}]} {$k > 0} {incr k -1} {
        switch -- [expr {int(rand() * 10)}] {
            0 { append text [pick {\\\" \\\\ \\/ \\b \\f \\n \\r \\t}] }
            1 { append text [format \\u%04x [expr {int(rand() * 0xD800)}]] }
            2 { append text \\ud83d\\ude00 }
            3 { append text [pick {\\ud800 \\udfff \\uDBFF\\uDC00 \\ud800\\u0041}] }
            4 { append text [pick {é € 😀 ß 中 "߿" "￿"}] }
            default { append text [pick {a b z 0 9 " " - _ ~}] }
        }
    }
    return $text\"
}

proc genValue {depth} {
    set kind [expr {$depth > 3 ? int(rand() * 4) : int(rand() * 6)}]
    switch -- $kind {
        0 { return [genNumber] }
        1 { return [genString] }
        2 { return [pick {true false null}] }
        3 { return [genNumber] }
        4 {
            set items {}
            for {set k [expr {int(rand() * 4)}]} {$k > 0} {incr k -1} {
                lappend items [genValue [expr {$depth + 1}]]
            }
            return "\[[join $items [pick {, , " , "}]]\]"
        }
        5 {
            set items {}
            for {set k [expr {int(rand() * 4)}]} {$k > 0} {incr k -1} {
                lappend items "[genString][pick {: " : " ":"}][genValue [expr {$depth + 1}]]"
            }
            return "\{[join $items ,]\}"
        }
    }
}

set interesting {0 9 10 13 31 32 34 44 45 46 48 49 58 69 91 92 93 101 116 117 123 125 127 128 191 192 194 224 237 240 244 245 255}

proc mutate {bytes} {
    set n [llength $bytes]
    switch -- [expr {int(rand() * 5)}] {
        0 {
            if {$n} {
                lset bytes [expr {int(rand() * $n)}] [pick $::interesting]
            }
        }
        1 {
            set at [expr {int(rand() * ($n + 1))}]
            set bytes [linsert $bytes $at [pick $::interesting]]
        }
        2 {
            if {$n} {
                set at [expr {int(rand() * $n)}]
                set bytes [lreplace $bytes $at $at]
            }
        }
        3 {
            if {$n > 1} {
                set a [expr {int(rand() * $n)}]
                set b [expr {min($n - 1, $a + int(rand() * 4))}]
                set bytes [linsert $bytes $b {*}[lrange $bytes $a $b]]
            }
        }
        4 {
            set bytes [lrange $bytes 0 [expr {int(rand() * $n) - 1}]]
        }
    }
    return $bytes
}

# UTF-8 at the edges of RFC 3629's table, valid and not: injected into a
# string, where a JSON text may hold any character.
set utf8Edges {
    {194 128} {223 191} {224 160 128} {237 159 191} {238 128 128} {239 191 191}
    {240 144 128 128} {244 143 191 191}
    {192 128} {193 191} {224 128 128} {224 159 191} {237 160 128} {237 191 191}
    {240 128 128 128} {240 143 191 191} {244 144 128 128} {245 128 128 128}
    {128} {191} {194} {224 160} {240 144 128} {255}
}

proc injectUtf8 {bytes} {
    set quotes [lsearch -all $bytes 34]
    set at [expr {[llength $quotes] ? [lindex $quotes [expr {int(rand() * [llength $quotes])}]] + 1 : 0}]
    return [linsert $bytes $at {*}[pick $::utf8Edges]]
}

proc generated {count seed} {
    expr {srand($seed)}
    set out {}
    for {set i 0} {$i < $count} {incr i} {
        set text [genValue 0]
        if {[chance 0.2]} {
            set text "[pick {"" " " "\n"}]$text[pick {"" " " "\t\r\n"}]"
        }
        binary scan [encoding convertto utf-8 $text] cu* bytes
        if {[chance 0.25]} {
            set bytes [injectUtf8 $bytes]
        }
        if {[chance 0.6]} {
            for {set k [expr {1 + int(rand() * 3)}]} {$k > 0} {incr k -1} {
                set bytes [mutate $bytes]
            }
        }
        lappend out [list fuzz-$seed-$i $bytes]
    }
    return $out
}

# ---------------------------------------------------------------------------
# Running both sides.

proc hex {bytes} {
    return [join [lmap b $bytes {format %02x $b}] ""]
}

# The executable of conformance.bot, built in a private directory DIR (a
# copy of the application directory).
proc build {dir} {
    set app [dict get $::options -app]
    foreach name {dfa.bot json_lex.bot json.bot conformance.bot} {
        set from [file join $dfatest::json $name]
        if {$app ne "" && [file exists [file join $app $name]]} {
            set from [file join $app $name]
        }
        file copy $from [file join $dir $name]
    }
    set hir [surface::readProgramFile [file join $dir conformance.bot] -warnings off]
    return [native::executable $hir [file join $dir conformance]]
}

# The executable's lines for CASES ({NAME BYTES}), in batches whose
# arguments stay well inside the system's limits.
proc ours {exe cases} {
    set out {}
    set batch {}
    set size 0
    # The executable prints the program's value, unit, last.
    set flush {apply {{exe batch} {
        lrange [split [string trimright [exec $exe {*}$batch] \n] \n] 0 end-1
    }}}
    foreach c $cases {
        set h [hex [lindex $c 1]]
        set pieces {}
        if {$h eq ""} {
            set pieces [list ""]
        }
        for {set k 0} {$k < [string length $h]} {incr k 100000} {
            lappend pieces [expr {$k ? "+" : ""}][string range $h $k [expr {$k + 99999}]]
        }
        if {$size + [string length $h] > 600000 && [llength $batch]} {
            lappend out {*}[{*}$flush $exe $batch]
            set batch {}
            set size 0
        }
        lappend batch {*}$pieces
        incr size [string length $h]
    }
    if {[llength $batch]} {
        lappend out {*}[{*}$flush $exe $batch]
    }
    return $out
}

proc theirs {cases} {
    set input ""
    foreach c $cases {
        append input [hex [lindex $c 1]]\n
    }
    return [split [string trim [exec python3 -I [file join $::root audit dfa tools oracle.py] << $input]] \n]
}

# ---------------------------------------------------------------------------

set cases {}
if {[dict get $options -suite] ne ""} {
    foreach path [lsort [glob -directory [dict get $options -suite] *.json]] {
        set f [open $path rb]
        binary scan [read $f] cu* bytes
        close $f
        lappend cases [list [file tail $path] $bytes]
    }
}
if {[dict get $options -seeds] ne ""} {
    lassign [split [dict get $options -seeds] -] first last
    for {set seed $first} {$seed <= $last} {incr seed} {
        lappend cases {*}[generated [dict get $options -fuzz] $seed]
    }
} else {
    lappend cases {*}[generated [dict get $options -fuzz] [dict get $options -seed]]
}

set dir [file tempdir dfa-differential]
try {
    set t0 [clock milliseconds]
    set exe [build $dir]
    set buildMs [expr {[clock milliseconds] - $t0}]
    set t0 [clock milliseconds]
    set lines [ours $exe $cases]
    set runMs [expr {[clock milliseconds] - $t0}]
} finally {
    file delete -force $dir
}
set verdicts [theirs $cases]

# Tally.
set tally [dict create]
set disagreements {}
set limits {}
set splitDisagreements {}
set regressions {}
foreach c $cases line $lines oracle $verdicts {
    lassign $c name bytes
    lassign [split $line |] whole chunked text
    set whole [string trim $whole]
    set chunked [string trim $chunked]
    set text [string trim $text]
    # The unicode recognizers, over the scalar values of valid UTF-8.
    if {$text ne "n/a" && $oracle ne "deep" && $whole ne "too deep"} {
        dict incr tally "text [expr {[string match "ok *" $text] ? "accept" : "reject"}] $oracle"
        if {[string match "ok *" $text] != ($oracle eq "accept")} {
            lappend disagreements [list $name "text: $text" $oracle]
            lappend regressions [hex $bytes]
        }
    }
    set ourVerdict [expr {[string match "ok *" $whole] ? "accept" : "reject"}]
    set group [expr {[regexp {^([yni])_} $name -> g] ? $g : "fuzz"}]
    if {$whole ne $chunked} {
        lappend splitDisagreements [list $name $whole $chunked]
        lappend regressions [hex $bytes]
    }
    if {$oracle eq "deep" || $whole eq "too deep"} {
        lappend limits [list $name $whole $oracle]
        dict incr tally "$group limit"
        continue
    }
    dict incr tally "$group $ourVerdict $oracle"
    if {$ourVerdict ne $oracle} {
        lappend disagreements [list $name $whole $oracle]
        lappend regressions [hex $bytes]
    }
    if {$group eq "y" && $ourVerdict ne "accept" || $group eq "n" && $ourVerdict ne "reject"} {
        lappend disagreements [list $name $whole "suite: $group"]
    }
}

set report "# DFA JSON differential run\n\n"
append report "Generated by audit/dfa/tools/differential.tcl -suite [expr {[dict get $options -suite] eq "" ? "(none)" : "JSONTestSuite/test_parsing"}] -fuzz [dict get $options -fuzz] [expr {[dict get $options -seeds] ne "" ? "-seeds [dict get $options -seeds]" : "-seed [dict get $options -seed]"}].\n"
append report "[llength $cases] cases; executable built in $buildMs ms, run in $runMs ms.\n\n"
append report "| group | ours | oracle | cases |\n|---|---|---|---:|\n"
foreach key [lsort [dict keys $tally]] {
    lassign $key group a b
    append report "| $group | $a | $b | [dict get $tally $key] |\n"
}
append report "\nDisagreements with the oracle or the suite: [llength $disagreements]\n"
foreach d $disagreements {
    append report "  [join $d { -- }]\n"
}
append report "\nWhole and chunked runs that disagree: [llength $splitDisagreements]\n"
foreach d $splitDisagreements {
    append report "  [join $d { -- }]\n"
}
append report "\nResource limits (max_depth 1000; the oracle's recursion limit): [llength $limits]\n"
foreach d $limits {
    append report "  [join $d { -- }]\n"
}
if {[string match *i_* [join [lmap c $cases {lindex $c 0}]]]} {
    append report "\nImplementation-defined (i_) cases, our verdict:\n"
    foreach c $cases line $lines {
        if {[string match i_* [lindex $c 0]]} {
            append report "  [lindex $c 0]: [string trim [lindex [split $line |] 0]]\n"
        }
    }
}
if {[dict get $options -out] eq ""} {
    puts -nonewline $report
} else {
    dfa::WriteText [dict get $options -out] $report
    puts "wrote [dict get $options -out]: [llength $disagreements] disagreements, [llength $splitDisagreements] split disagreements"
}
if {[dict get $options -regressions] ne "" && [llength $regressions]} {
    set f [open [dict get $options -regressions] a]
    puts $f [join $regressions \n]
    close $f
}
exit [expr {[llength $disagreements] || [llength $splitDisagreements] ? 1 : 0}]
