# conformance.tcl -- the checker's recognizer semantics against the
# reference interpreter (EMISSION-CLAIMS-MILESTONE-1.md, "One DFA outcome
# model"; the modular prototype's audit/emission-proofs/tools/
# conformance.tcl, its 7,201-case baseline).
#
#   tclsh9.0 audit/emission-claims/tools/conformance.tcl ?-count 40? ?-seed 1? ?-out FILE?
#
# Every case tests/dfa-support.tcl's dfatest::cases makes for every
# recognizer of the JSON workload (json_lex's eleven, json_grammar's four)
# and three written for what JSON lacks (`accept before 2`, a call `then
# accept` passing two unread symbols on, a call `then STATE` whose callee
# leaves its symbol for the caller to reconsider) is stepped by the checker
# one symbol at a time -- hir/emitdfa.tcl over core/dfa.tcl's outcome model,
# from the tables the HIR carries -- and its outcome compared with the
# reference interpreter's, which reads the declarations themselves.

set here [file dirname [file normalize [info script]]]
set options [dict merge {-count 40 -seed 1 -out ""} $argv]
set argv {}
source [file join $here witness.tcl]
interp recursionlimit {} 100000

set la "import std::dfa\n\ndfa ab over ascii:\n    start:\n        'a' -> one\n    one:\n        'b' -> two\n    two:\n        'c' -> accept before 2\n        end -> accept\n\ndfa ab_more over ascii:\n    start:\n        'b' -> more\n    more:\n        'b' -> more\n        ')' 'c' -> accept before\n        end -> reject\n\ndfa wrap over ascii:\n    start:\n        '(' -> inner\n    inner:\n        'a' -> call ab then accept\n        'b' -> call ab_more then close\n    close:\n        ')' -> accept\n        'c' -> accept\n"
set dir [emit::workspace main.bot "import json_grammar\nimport la\n\n0\n" la.bot $la]
lassign [emit::conformance $dir [dict get $options -count] [dict get $options -seed]] cases mismatches
set keys [lmap k [dict keys $::hir::emission::recognizers] {hir::emission::KeyText $k}]
set lines [list "## Recognizer semantics: the checker's step against the reference interpreter" "" \
    "[llength $keys] recognizers ([join $keys {, }]), $cases cases, [dict get $options -count] walks each, seed [dict get $options -seed]: [llength $mismatches] mismatches"]
foreach m [lrange $mismatches 0 20] {
    lassign $m key input ref got
    lappend lines "* [hir::emission::KeyText $key] [list $input]: reference `$ref`, checker `$got`"
}
set text [join $lines \n]
puts $text
if {[dict get $options -out] ne ""} {
    emit::writeText [dict get $options -out] "$text\n"
}
emit::cleanup
exit [expr {[llength $mismatches] > 0}]
