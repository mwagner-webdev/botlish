# measure.tcl -- clean_ai_text over bench/ai_text_clean.tcl's punctuation and
# emoji fixtures (100,000 characters each) on native, for each variant in
# this directory (README.md): the value (checked equal across variants),
# UTF-8 bytes re-decoded (native::allocationReport's traversal counter),
# Strings and all objects allocated, and the best of 5 timed runs
# (native::measure).
#
#   tclsh9.0 audit/refactor/ripple/measure.tcl ?VARIANT ...?
#
# With no VARIANT, every variant: as-merged list-loop set-per-call
# set-program ripple. The slow variants take several seconds a run.

set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
source [file join $root examples stdlib corpus.tcl]
interp recursionlimit {} 2000000
set corpus::home $here

set variants $argv
if {$variants eq ""} {
    set variants {as-merged list-loop set-per-call set-program ripple}
}
# bench/ai_text_clean.tcl's sentences and its fixture rule (repeated, cut to
# N characters).
proc fixture {sentence n} {
    set repeated [string repeat $sentence [expr {$n / [string length $sentence] + 1}]]
    return [string range $repeated 0 [expr {$n - 1}]]
}
set families [list \
    punctuation "“Here’s the result—it’s concise, readable…and ready to use.” " \
    emoji "\U0001F916 “Here’s the 東京 report—it’s ready…” \U0001F680 Grüße from München. "]
set reference {}
foreach {family sentence} $families {
    set text [fixture $sentence 100000]
    foreach variant $variants {
        set hir [corpus::driven $variant "clean_ai_text([corpus::literal $text])" -warnings off]
        set report [native::allocationReport $hir summary]
        lassign [native::measure $hir 5] lower compile best collections value
        if {![dict exists $reference $family]} {
            dict set reference $family $value
        }
        set same [expr {$value eq [dict get $reference $family] ? "same value" : "VALUE DIFFERS"}]
        puts [format "%-12s %-13s re-decoded %14lld B  Strings %7d  objects %7d  best %9.2f ms  %s" \
            $family $variant [dict get $report traversal utf8SeekBytes] \
            [dict get $report byKind String allocations] [dict get $report total allocations] \
            [expr {$best / 1000.0}] $same]
    }
}
