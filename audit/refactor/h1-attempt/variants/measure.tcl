# measure.tcl -- the placement and spelling measurements of the H1 attempt's
# translation table (../README.md, "Where the cost comes from"): for each
# program, clean_ai_text over bench/ai_text_clean.tcl's punctuation fixture
# at 2,000, 4,000 and 8,000 characters, on native
# (native::allocationReport): UTF-8 seek bytes, List element copies and
# String allocations. The counts are deterministic; no time is measured.
#
#   tclsh9.0 audit/refactor/h1-attempt/variants/measure.tcl ?FILE.bot ...?
#
# With no FILE, it measures the corpus program, the H1 attempt and the three
# variants in this directory.

set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname [file dirname $here]]]]
source [file join $root examples stdlib corpus.tcl]
interp recursionlimit {} 1000000

proc readText {path} {
    set channel [open $path]
    fconfigure $channel -encoding utf-8
    set text [read $channel]
    close $channel
    return $text
}

set files $argv
if {$files eq ""} {
    set files [list [file join $root examples stdlib ai_text_clean.bot] \
        [file join [file dirname $here] ai_text_clean.bot] \
        [file join $here list-program.bot] [file join $here string-local.bot] \
        [file join $here list-local.bot]]
}
# bench/ai_text_clean.tcl's punctuation sentence, repeated and cut to N
# characters (its aibench::fixture).
set sentence "“Here’s the result—it’s concise, readable…and ready to use.” "
foreach path $files {
    set label [string range [file normalize $path] [string length $root/] end]
    foreach n {2000 4000 8000} {
        set fixture [string range [string repeat $sentence [expr {$n / [string length $sentence] + 1}]] 0 [expr {$n - 1}]]
        set text "[readText $path]\nr = clean_ai_text([corpus::literal $fixture]):\n    on LowerUnderrun:\n        \"\"\nr\n"
        set report [native::allocationReport [corpus::compile $text $path -warnings off] summary]
        puts [format "%-52s %5d  seek %10d  list-copies %6d  strings %6d" $label $n \
            [dict get $report traversal utf8SeekBytes] [dict get $report copies listElements] \
            [dict get $report byKind String allocations]]
    }
}
