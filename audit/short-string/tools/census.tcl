#!/usr/bin/env tclsh9.0
# census.tcl -- SHORT-STRING.md virtualization and conversion censuses over
# the canonical corpus. Observation only.
#
# For each program (and a corpus total), with ShortString1 on:
#   * String positions/values examined and proven length <= 1 (native::shortstr
#     ::census: parameter positions of String-keyed instances, result positions,
#     live local String bindings);
#   * parameter / result positions that became ShortString1, instances with
#     any ShortString1 ABI position;
#   * what the virtualized values are: known Empty, known One (exact scalar),
#     known One (scalar only at run time), runtime Empty-or-One;
#   * local values virtualized and the lowering's own frontier counters
#     (tagged -> short extractions, short -> tagged materializations, scalar
#     length/equality, joins, slices);
#   * the static NIR conversion counts, off and on, the classification of
#     every materialization by what consumes the String, and the
#     zero/one/many materialization census of the virtual values.
#
#   tclsh9.0 audit/short-string/tools/census.tcl ?-detail? ?PROGRAM.bot...?
source [file join [file dirname [file normalize [info script]]] lib.tcl]
set detail 0
set paths {}
foreach a $argv {
    if {$a eq "-detail"} { set detail 1 } else { lappend paths $a }
}
if {$paths eq ""} { set paths [corpusPaths] }
set total [dict create]
proc add {d k v} { upvar 1 $d dd; if {![dict exists $dd $k]} { dict set dd $k 0 }; dict set dd $k [expr {[dict get $dd $k] + $v}] }
set classTotal [dict create]
set reasonsTotal [dict create]
set manyTotal [dict create zero 0 one 0 many 0]
foreach path $paths {
    set hir [surface::readProgramFile $path]
    set lowered [native::lowered $hir -short-string-opt 1]
    set c [native::shortstr::census]
    set nirOn [dict get $lowered text]
    set nirOff [native::nir $hir -short-string-opt 0]
    set counters [dict create shortLocals 0 shortLits 0 shortFromTagged 0 shortToTagged 0 shortConstMaterialized 0 shortLen 0 shortEq 0 shortJoins 0 shortSlices 0]
    foreach info [dict get $lowered functions] {
        if {![dict exists $info short]} continue
        dict for {k v} [dict get $info short] { add counters $k $v }
    }
    set on [shortCounts $nirOn]
    lassign [materializations $nirOn] classes perValue
    # zero/one/many over every short register of every function
    set many [dict create zero 0 one 0 many 0]
    foreach f [nirFunctions $nirOn] {
        lassign $f id name attrs body
        foreach r [dict get $attrs shortregs] {
            # only registers that are the source of conversions or genuine values
            set n [expr {[dict exists $perValue $id:$r] ? [dict get $perValue $id:$r] : 0}]
            dict incr many [expr {$n == 0 ? "zero" : $n == 1 ? "one" : "many"}]
        }
    }
    puts "== [programName $path]"
    puts "  planner fixpoint rounds: [dict get $c rounds]"
    add total rounds [dict get $c rounds]
    set maxRounds [expr {[info exists maxRounds] ? max($maxRounds, [dict get $c rounds]) : [dict get $c rounds]}]
    puts [format "  positions examined %d  proven <=1 %d | locals examined %d proven %d virtualized %d | params %d/%d result %d/%d | instances with any ShortString1 ABI %d" \
        [dict get $c positionsExamined] [dict get $c positionsProven] [dict get $c localsExamined] [dict get $c localsProven] \
        [dict get $counters shortLocals] [dict get $c paramSelected] [dict get $c paramPositions] [dict get $c resultSelected] [dict get $c resultPositions] [dict get $c anyAbi]]
    puts [format "  virtualized values: known Empty %d, known One (scalar known) %d, known One (scalar at run time) %d, runtime Empty-or-One %d" \
        [dict get $c exactEmpty] [dict get $c exactOne] [dict get $c exactOneUnknown] [dict get $c runtimeEmptyOrOne]]
    puts [format "  frontier counters (lowering): strtoshort %d  shorttostr %d  literal-materialized %d  shortlit %d  shortlen %d  shorteq %d  joins %d  slices %d" \
        [dict get $counters shortFromTagged] [dict get $counters shortToTagged] [dict get $counters shortConstMaterialized] \
        [dict get $counters shortLits] [dict get $counters shortLen] [dict get $counters shortEq] [dict get $counters shortJoins] [dict get $counters shortSlices]]
    puts [format "  static NIR: strtoshort %d  shorttostr %d  (off: %d/%d)" [dict get $on strtoshort] [dict get $on shorttostr] \
        [dict get [shortCounts $nirOff] strtoshort] [dict get [shortCounts $nirOff] shorttostr]]
    dict for {k v} $classes { puts "    materialization: $k = $v"; add classTotal $k $v }
    puts "  virtual registers by materialization count: [dict get $many zero] zero, [dict get $many one] one, [dict get $many many] multiple"
    dict for {k v} $many { add manyTotal $k $v }
    foreach k {positionsExamined positionsProven localsExamined localsProven paramPositions paramSelected resultPositions resultSelected anyAbi exactEmpty exactOne exactOneUnknown runtimeEmptyOrOne} {
        add total $k [dict get $c $k]
    }
    foreach k {shortLocals shortLits shortFromTagged shortToTagged shortConstMaterialized shortLen shortEq shortJoins shortSlices} {
        add total $k [dict get $counters $k]
    }
    add total offStrtoshort [dict get [shortCounts $nirOff] strtoshort]
    dict for {reason n} [dict get $c reasons] { add reasonsTotal $reason $n }
    if {$detail} { puts [native::shortstr::explainAll] }
}
puts "== TOTAL"
puts "  (max fixpoint rounds in one program: $maxRounds)"
dict for {k v} $total { puts "  $k = $v" }
puts "  materialization classes:"
dict for {k v} $classTotal { puts "    $k = $v" }
puts "  virtual registers by materialization count: $manyTotal"
puts "  rejection reasons of String positions kept tagged:"
dict for {k v} $reasonsTotal { puts "    $k = $v" }
