#!/usr/bin/env tclsh9.0
# emit-supplemental-nir.tcl -- NIR of the SUPPLEMENTAL (non-canonical)
# workloads POST-M8A-COMMON-INEFFICIENCY-CENSUS.md uses only as supporting
# evidence, built exactly as audit/m8a-virtual-construction/tools/
# workloads.tcl builds them (corpus drivers, bench/corpus.tcl inputs).
# Observation only.
#
#   tclsh9.0 audit/post-m8a-common-inefficiency/tools/emit-supplemental-nir.tcl NAME OUT.nir
#
# NAME: uri-steady | ai_text_clean-ascii-10K | ai_text_clean-emoji-10K |
#       csv-1000 | string_reverse-10K
set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
source [file join $root examples stdlib corpus.tcl]
interp recursionlimit {} 2000000
lassign $argv name out
proc text {n} {
    set alphabet abcdefghijklmnopqrstuvwxyz0123456789
    return [string range [string repeat $alphabet [expr {$n / [string length $alphabet] + 1}]] 0 [expr {$n - 1}]]
}
proc csv {rows} {
    set lines [list {id,name,note,amount}]
    for {set i 1} {$i <= $rows} {incr i} {
        lappend lines [format {%d,user%d,"note %d, says ""hi""",%d} $i $i $i [expr {($i * 37) % 1000}]]
    }
    return "[join $lines \n]\n"
}
proc aiText {family n} {
    set sentence [dict get {
        ascii "The model generated this sentence. It contains ordinary ASCII text and no special punctuation or emoji at all. "
        emoji "\U0001F916 “Here’s the 東京 report—it’s ready…” \U0001F680 Grüße from München. "
    } $family]
    set t [string repeat $sentence [expr {$n / [string length $sentence] + 1}]]
    return [string range $t 0 [expr {$n - 1}]]
}
switch -- $name {
    uri-steady { set hir [surface::readProgramFile [file join $root bench uri-steady.bot]] }
    ai_text_clean-ascii-10K { set hir [corpus::program ai_text_clean "clean_ai_text([corpus::literal [aiText ascii 10000]])"] }
    ai_text_clean-emoji-10K { set hir [corpus::program ai_text_clean "clean_ai_text([corpus::literal [aiText emoji 10000]])"] }
    csv-1000 { set hir [corpus::program csv "csv_parse([corpus::literal [csv 1000]])"] }
    string_reverse-10K { set hir [corpus::program string_reverse "reverse_chars([corpus::literal [text 10000]])"] }
    default { error "unknown supplemental workload $name" }
}
set f [open $out w]
fconfigure $f -encoding utf-8 -translation lf
puts -nonewline $f [native::nir $hir]
close $f
