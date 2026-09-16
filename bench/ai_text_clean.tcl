# ai_text_clean.tcl -- scaling benchmark for examples/stdlib/ai_text_clean.bot
# (see that file's own header): the permanent regression workload for
# sequential UTF-8 traversal, exercising exactly the character-indexed
# access idiom (csv.bot's peek()) that can become O(n^2) on non-ASCII text,
# since repeated character-indexed substring access decodes from byte 0 to
# reach each logical character position.
#
#   tclsh9.0 bench/ai_text_clean.tcl [-runs N] [-all] [-markdown]
#
# -runs N (default 5): timed runs per case, best of N (native::measure).
# -all: also measure the optional 1 MB size (slow; skipped by default, the
# repository's existing slow-benchmark convention -- see bench/corpus.tcl).
# -markdown: print a Markdown table instead of a fixed-width one.
#
# Backend: cranelift only (-specialize 1, the repository's own allocation-
# instrumentation convention -- README's "Allocation instrumentation"
# section measures the same way, since native::allocationReport is a native-
# backend-only facility; differential correctness across all four backends
# is tests/stdlib.test's job, not this benchmark's -- see its ai_text_clean
# cases, including a large-fixture parity check).
#
# Three deterministic fixture families (task's own shapes, cycled/truncated
# to an exact character count by aibench::fixture, never regenerated inside
# the timed region -- native::measure and native::allocationReport measure
# only the compiled clean_ai_text(FIXTURE) call; FIXTURE itself becomes a
# source-level String literal, interned once in the native backend's
# constant table (README's "Allocation instrumentation" section) before any
# timed run):
#
#   ascii        plain ASCII prose, no replacements needed: the traversal
#                baseline where character index and UTF-8 byte offset
#                coincide.
#   punctuation  generated-looking prose dense with curly quotes, en/em
#                dashes and ellipses, but no astral emoji: BMP non-ASCII
#                traversal, output construction on nearly every character.
#   emoji        emoji, curly punctuation, accented Latin and CJK together:
#                astral-heavy traversal, the shape closest to real
#                LLM-generated/user-facing text.
#
# For each family/size this reports input bytes/chars, output bytes/chars,
# wall time (best of -runs), and native::allocationReport's summary:
# total/String allocations, allocated bytes, String bytes copied, GC
# cycles -- then the same normalized per-input-character/per-input-byte,
# and scaling ratios between consecutive sizes (1K->10K, 10K->100K, and
# 100K->1M under -all). A representative subset (the 10K case of each
# family) is also measured under -string-region-opt 0, to separate
# temporary-String-allocation cost from character-position traversal cost
# per the milestone's own #13 (see the printed note: ai_text_clean's own
# peek()'d character always escapes into the output on the common,
# unchanged-character path -- see the file's own header -- so, unlike
# csv.bot's peek(), -string-region-opt already makes no difference to its
# allocation count; the two settings are expected to agree exactly here).
#
# This script never asserts a complexity class: it measures and prints
# ratios. Judging O(n) vs worse-than-O(n) from them is the final report's
# job (see the commit/PR description), not this script's.

set root [file dirname [file dirname [file normalize [info script]]]]
source [file join $root examples stdlib corpus.tcl]

namespace eval aibench {}

# ---------------------------------------------------------------------------
# Fixtures

proc aibench::asciiSentence {} {
    return "The model generated this sentence. It contains ordinary ASCII text and no special punctuation or emoji at all. "
}

proc aibench::punctuationSentence {} {
    return "“Here’s the result—it’s concise, readable…and ready to use.” "
}

proc aibench::emojiSentence {} {
    return "\U0001F916 “Here’s the 東京 report—it’s ready…” \U0001F680 Grüße from München. "
}

set aibench::families {
    ascii       aibench::asciiSentence
    punctuation aibench::punctuationSentence
    emoji       aibench::emojiSentence
}

# SENTENCE repeated and truncated to exactly N Unicode characters (Tcl 9's
# [string length] counts scalar values, matching Botlish's length() --
# README's introduction).
proc aibench::fixture {sentence n} {
    set repeated [string repeat $sentence [expr {$n / [string length $sentence] + 1}]]
    return [string range $repeated 0 [expr {$n - 1}]]
}

set aibench::sizes {
    1K   1000
    10K  10000
    100K 100000
}
set aibench::slowSize {1M 1000000}

# ---------------------------------------------------------------------------
# One measurement

# clean_ai_text(FIXTURE) on cranelift, RUNS timed runs (best of), under
# STRING-REGION-OPT (1 or 0). Returns a dict: inputChars inputBytes
# outputChars outputBytes microseconds allocations stringAllocations
# allocatedBytes stringBytesCopied gcCycles crc.
proc aibench::measure {text runs stringRegionOpt} {
    set hir [corpus::program ai_text_clean "clean_ai_text([corpus::literal $text])"]
    lassign [native::measure $hir $runs -string-region-opt $stringRegionOpt] lower compile best collections value
    set report [native::allocationReport $hir summary $runs -string-region-opt $stringRegionOpt]
    set outputText [core::value::strOf $value]
    set inputBytes [string length [encoding convertto utf-8 $text]]
    set outputBytes [string length [encoding convertto utf-8 $outputText]]
    set total [dict get $report total]
    set copies [dict get $report copies]
    return [dict create \
        inputChars [string length $text] inputBytes $inputBytes \
        outputChars [string length $outputText] outputBytes $outputBytes \
        microseconds $best \
        allocations [dict get $total allocations] \
        stringAllocations [dict get $report byKind String allocations] \
        allocatedBytes [dict get $total allocatedBytes] \
        stringBytesCopied [dict get $copies stringBytes] \
        gcCycles [dict get $report gc cycles] \
        crc [zlib crc32 [encoding convertto utf-8 $outputText]]]
}

# ---------------------------------------------------------------------------
# Report

proc aibench::formatBytes {n} {
    if {$n >= 1000000} { return [format "%.2f MB" [expr {$n / 1000000.0}]] }
    if {$n >= 1000}    { return [format "%.1f KB" [expr {$n / 1000.0}]] }
    return "$n B"
}

proc aibench::formatMicros {us} {
    if {$us >= 1000} { return [format "%.2f ms" [expr {$us / 1000.0}]] }
    return "$us us"
}

set runs 5
set all 0
set markdown 0
for {set i 0} {$i < [llength $argv]} {incr i} {
    switch -- [lindex $argv $i] {
        -runs     { set runs [lindex $argv [incr i]] }
        -all      { set all 1 }
        -markdown { set markdown 1 }
        default   { puts stderr "unknown option: [lindex $argv $i]"; exit 2 }
    }
}

set sizeList $aibench::sizes
if {$all} {
    lappend sizeList {*}$aibench::slowSize
}

# family -> size -> result dict (string-region-opt 1), in size order, for
# the ratio table below.
array set aibench::onResults {}

puts "Tcl [info patchlevel], cranelift, best of $runs runs, wall time; allocation counts from a separate run (native::allocationReport summary mode, same settings)."
puts ""
if {$markdown} {
    puts "| family | size | input bytes | input chars | output bytes | output chars | time | allocations | String allocs | allocated | String bytes copied | GC cycles |"
    puts "|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|"
} else {
    puts [format "%-12s %-6s %10s %10s %10s %10s %10s %10s %10s %10s %14s %6s" \
        family size in-bytes in-chars out-bytes out-chars time allocs str-allocs allocated str-bytes-copied gc]
}

foreach {family sentenceProc} $aibench::families {
    foreach {label size} $sizeList {
        set text [aibench::fixture [$sentenceProc] $size]
        set r [aibench::measure $text $runs 1]
        set aibench::onResults($family,$label) $r
        set row [list $family $label [dict get $r inputBytes] [dict get $r inputChars] \
            [dict get $r outputBytes] [dict get $r outputChars] [aibench::formatMicros [dict get $r microseconds]] \
            [dict get $r allocations] [dict get $r stringAllocations] [aibench::formatBytes [dict get $r allocatedBytes]] \
            [aibench::formatBytes [dict get $r stringBytesCopied]] [dict get $r gcCycles]]
        if {$markdown} {
            puts "| [join $row { | }] |"
        } else {
            puts [format "%-12s %-6s %10s %10s %10s %10s %10s %10s %10s %10s %14s %6s" {*}$row]
        }
        flush stdout
    }
}

# ---------------------------------------------------------------------------
# Scaling ratios (string-region-opt 1): consecutive sizes' time and
# allocated-bytes ratios, per family -- the milestone's core question (#12):
# is non-ASCII traversal scaling worse than ASCII?

puts ""
puts "Scaling ratios (string-region-opt 1), consecutive sizes, string-region-opt 1:"
puts [format "%-12s %-14s %10s %10s" family sizes time-x bytes-x]
set labels [lmap {label size} $sizeList {set label}]
foreach {family sentenceProc} $aibench::families {
    for {set i 1} {$i < [llength $labels]} {incr i} {
        set prevLabel [lindex $labels [expr {$i - 1}]]
        set label [lindex $labels $i]
        set prev $aibench::onResults($family,$prevLabel)
        set cur $aibench::onResults($family,$label)
        set timeRatio [expr {double([dict get $cur microseconds]) / max(1, [dict get $prev microseconds])}]
        set bytesRatio [expr {double([dict get $cur allocatedBytes]) / max(1, [dict get $prev allocatedBytes])}]
        puts [format "%-12s %-14s %10s %10s" $family "$prevLabel->$label" [format %.1fx $timeRatio] [format %.1fx $bytesRatio]]
    }
}

# ---------------------------------------------------------------------------
# -string-region-opt 0 subset: the 10K case of each family (task's #13 --
# not a full matrix), to separate temporary-String-allocation cost from
# character-position traversal cost. See the file header: ai_text_clean's
# own peek()'d character always escapes into the output on the common,
# unchanged-character path (clean_char's fallback returns the character
# itself), so, unlike csv.bot's peek(), -string-region-opt is expected to
# make *no* difference to its allocation count here -- this prints the
# actual numbers rather than assuming that.

puts ""
puts "String-region-opt 1 vs 0, 10K case (allocations; identical numbers here are expected -- see the file header):"
puts [format "%-12s %10s %10s %10s %10s" family allocs-on allocs-off bytes-on bytes-off]
foreach {family sentenceProc} $aibench::families {
    set text [aibench::fixture [$sentenceProc] 10000]
    set on $aibench::onResults($family,10K)
    set off [aibench::measure $text $runs 0]
    if {[dict get $on outputChars] != [dict get $off outputChars] || [dict get $on crc] != [dict get $off crc]} {
        puts stderr "aibench: $family 10K: string-region-opt 1 and 0 disagree on the cleaned result"
        exit 1
    }
    puts [format "%-12s %10s %10s %10s %10s" $family [dict get $on allocations] [dict get $off allocations] \
        [aibench::formatBytes [dict get $on allocatedBytes]] [aibench::formatBytes [dict get $off allocatedBytes]]]
}
