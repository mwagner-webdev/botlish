# bench.tcl -- what EMISSION-IDENTITY-AND-FEASIBILITY-CORRECTNESS-
# MILESTONE-1.md's corrections cost the emission checker:
#
#   * the JSON and CSV probe programs (examples/dfa/json/emit_probes.bot's
#     22 claims, examples/dfa/csv/probes.bot's 52), each compiled by
#     -runs fresh processes: the checker's own time (median and range), its
#     summaries computed and reused, its rounds, the claims certified;
#   * the same, compiled a second time in one process: the claims reused
#     from the memo and the checker's time;
#   * the ambiguous-name fallback: a generated program of -scopes outer
#     functions, each holding a nested claimed `emitter` and its `helper`
#     (every name shared), against the same program with names of their
#     own, compiled twice in one process: what the second compilation
#     reuses and costs.
#
#   tclsh9.0 audit/emission-identity/tools/bench.tcl ?-root DIR? ?-runs 5?
#       ?-scopes 12? ?-out FILE?
#
# -root DIR measures the compiler of another checkout (the tree before the
# milestone). Timings are of a shared machine: compare medians, not runs.

set here [file dirname [file normalize [info script]]]
set options [dict merge [list -root [file dirname [file dirname [file dirname $here]]] -runs 5 -scopes 12 \
    -out "" -child ""] $argv]
set argv {}
set root [dict get $options -root]

# The generated fallback program: SCOPES outer functions, names shared or
# not.
proc Scoped {scopes shared} {
    set text "import std::dfa\n\nclass digit = '0'..'9'\n\ntype Digit = Int in 0..9\n\ndfa digit_token over ascii:\n    start:\n        digit -> accept\n\n"
    for {set i 1} {$i <= $scopes} {incr i} {
        set suffix [expr {$shared ? "" : $i}]
        append text "fn outer$i\(d: Digit) -> int:\n" \
            "    fn helper$suffix\(n: Digit) -> unit:\n        if n > 4:\n            yield 48 + n\n        else:\n            yield 48 + 9 - n\n        unit\n" \
            "    fn emitter$suffix\() -> unit emits digit_token:\n        if true:\n            helper$suffix\(d)\n        else:\n            yield 65\n        unit\n" \
            "    $i\n\n"
    }
    return "${text}0\n"
}

if {[dict get $options -child] ne ""} {
    source [file join $root tests helpers.tcl]
    source [file join $root surface surface.tcl]
    lassign [dict get $options -child] mode path
    set times {}
    foreach pass [expr {$mode eq "twice" ? {1 2} : {1}}] {
        set hir [surface::readProgramFile $path -warnings off -strict 0]
        set s $::hir::emission::stats
        lappend times [list [dict get $s checkMicroseconds] [dict get $s summariesComputed] \
            [dict get $s summariesReused] [dict get $s rounds] \
            [llength [lmap r [hir::emission::claims $hir] {if {[dict get $r verdict] ne "proven"} continue; set r}]] \
            [llength [dict getdef $s reusedClaims {}]] [llength [hir::emission::claims $hir]]]
    }
    puts $times
    exit 0
}

proc Child {mode path} {
    return [exec [info nameofexecutable] [info script] -root $::root -child [list $mode $path]]
}

proc Median {values} {
    set sorted [lsort -real $values]
    return [lindex $sorted [expr {[llength $sorted] / 2}]]
}

if {[catch {exec git -C $root rev-parse --short HEAD} rev] || [catch {exec git -C $root status --porcelain -- hir} dirty]} {
    set tree "a copy of a tree that is no checkout"
} else {
    set tree "$rev[expr {$dirty eq "" ? "" : ", hir/ modified"}]"
}
set lines [list "## Emission checker costs" "" "Compiler: [expr {[file normalize $root] eq [file normalize [file dirname [file dirname [file dirname $here]]]] ? "this checkout" : $root}] ($tree); [dict get $options -runs] fresh processes per program." ""]
lappend lines "| program | claims | certified | checker ms (median, range) | summaries computed / reused | rounds |" "|---|---:|---:|---|---|---:|"
set work [file tempdir]
foreach {name path} [list JSON [file join $root examples dfa json emit_probes.bot] CSV [file join $root examples dfa csv probes.bot]] {
    set ms {}
    foreach run [lrange {1 2 3 4 5 6 7 8 9 10} 0 [dict get $options -runs]-1] {
        set r [lindex [Child once $path] 0]
        lappend ms [expr {[lindex $r 0] / 1000.0}]
    }
    lassign $r - computed reused rounds proven - claims
    lappend lines "| $name | $claims | $proven | [format %.0f [Median $ms]] ([format %.0f [lindex [lsort -real $ms] 0]]-[format %.0f [lindex [lsort -real $ms] end]]) | $computed / $reused | $rounds |"
}
lappend lines "" "Compiled twice in one process (the memo kept):" "" \
    "| program | claims reused by the second compilation | checker ms, first / second |" "|---|---:|---|"
set scopes [dict get $options -scopes]
foreach shared {1 0} {
    set f [file join $work scoped$shared.bot]
    set out [open $f w]
    fconfigure $out -encoding utf-8 -translation lf
    puts -nonewline $out [Scoped $scopes $shared]
    close $out
}
foreach {name path} [list JSON [file join $root examples dfa json emit_probes.bot] CSV [file join $root examples dfa csv probes.bot] \
        "$scopes scopes, every name shared" [file join $work scoped1.bot] "$scopes scopes, names of their own" [file join $work scoped0.bot]] {
    set firsts {}
    set seconds {}
    foreach run [lrange {1 2 3 4 5 6 7 8 9 10} 0 [dict get $options -runs]-1] {
        lassign [Child twice $path] a b
        lappend firsts [expr {[lindex $a 0] / 1000.0}]
        lappend seconds [expr {[lindex $b 0] / 1000.0}]
    }
    lappend lines "| $name | [lindex $b 5] of [lindex $b 6] (certified: [lindex $b 4]) | [format %.0f [Median $firsts]] / [format %.0f [Median $seconds]] |"
}
file delete -force $work
set text [join $lines \n]
puts $text
if {[dict get $options -out] ne ""} {
    set f [open [dict get $options -out] w]
    fconfigure $f -encoding utf-8 -translation lf
    puts $f $text
    close $f
}
