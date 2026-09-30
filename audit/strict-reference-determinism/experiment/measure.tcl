#!/usr/bin/env tclsh9.0
# LEGACY / RELIFT COMPARISON (measurement in the relifted pipeline): needs native::buildProgramHir, which
# DIRECT-HIR-NATIVE-PATH.md removed. Runs only against a tree from before that
# milestone; the production route is audit/direct-hir-native-path/tools/.
# measure.tcl -- one program's semantic/specialization/NIR census, in the
# relifted pipeline bench/bench.tcl compiles. Runs against the tree named by
# -root (default: the tree this file lives in).
#
#   tclsh9.0 measure.tcl [-root TREE] FILE.bot
#
# Prints REJECTED plus the error when the program does not compile (nothing
# after resolution then runs), otherwise: semantic-instance counters,
# codegen/AOT/guard counts and a canonical NIR digest -- the function bodies
# sorted, with numeric ids (function ids, register numbers) replaced by
# order-of-appearance names -- so the same program written in two orders can
# be compared.
set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
while {[llength $argv] > 1} {
    switch -- [lindex $argv 0] {
        -root { set root [file normalize [lindex $argv 1]]; set argv [lrange $argv 2 end] }
        default { break }
    }
}
set path [lindex $argv 0]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000

if {[catch {surface::readProgramFile $path -strict 0} surfaceHir]} {
    puts "REJECTED: [lindex [split $surfaceHir \n] 0]"
    exit 0
}
if {[hir::diagnostics $surfaceHir] ne ""} {
    set first [lindex [hir::diagnostics $surfaceHir] 0]
    puts "REJECTED: [dict get $first kind]: [dict get $first message]"
    puts "(diagnostics: [llength [hir::diagnostics $surfaceHir]])"
    exit 0
}
set sem [dict get $surfaceHir semantic]
foreach key {requests trivial hits walks rounds} {
    puts [format {semantic.%-12s %s} $key [dict get $sem $key]]
}
puts [format {semantic.%-12s %s} instances [dict size [dict get $sem instances]]]
puts [format {semantic.%-12s %s} used [llength [dict get $sem used]]]
puts [format {semantic.%-12s %s} declinedNoEnv \
    [expr {[dict exists $sem declinedCount no-env] ? [dict get $sem declinedCount no-env] : 0}]]

set hir [native::buildProgramHir [hir::lower $surfaceHir]]
set spec [hir::specialize::analyze $hir]
set regions [hir::specialize::regions $hir $spec]
set counts [dict create closed 0 guarded 0 open 0]
foreach id [dict get $spec used] {
    dict incr counts [dict get [dict get $regions $id] status]
}
puts "codegen.used       [llength [dict get $spec used]]"
puts "aot.closed/guarded/open [dict get $counts closed]/[dict get $counts guarded]/[dict get $counts open]"

set nir [dict get [native::lower::program $hir] text]
set functions 0
set guards 0
set blocks {}
set current {}
foreach line [split $nir \n] {
    if {[regexp {^func } $line]} {
        incr functions
        if {$current ne ""} { lappend blocks [join $current \n] }
        set current {}
    }
    if {[regexp {^\s+guard} $line]} { incr guards }
    lappend current $line
}
if {$current ne ""} { lappend blocks [join $current \n] }
puts "nir.functions      $functions"
puts "nir.guards         $guards"
# Canonicalize: drop the @eN expression-id tags (they follow source order),
# and name every function reference (`call N`, `callmulti N`, `fnvalue N`,
# `closure N`) by the function's own name and instance instead of its id.
set fnName [dict create]
foreach line [split $nir \n] {
    if {[regexp {^func ([0-9]+) "([^"]*)".*instance="([^"]*)"} $line -> id name instance]} {
        dict set fnName $id "$name<$instance>"
    }
}
proc canon {text} {
    global fnName
    set text [regsub -all { @e[0-9]+} $text {}]
    set text [regsub -all {^func [0-9]+ } $text {func }]
    set out ""
    foreach line [split $text \n] {
        set line [regsub {^func [0-9]+ } $line {func }]
        if {[regexp {(call|callmulti|fnvalue|closure|tail) ([0-9]+)( |$)} $line -> op id]
                && [dict exists $fnName $id]} {
            regsub {(call|callmulti|fnvalue|closure|tail) [0-9]+( |$)} $line "\\1 <[dict get $fnName $id]>\\2" line
        }
        append out $line \n
    }
    return $out
}
# A stable digest without external packages: Tcl's own hash of the text.
proc Digest {text} {
    binary scan [encoding convertto utf-8 $text] c* bytes
    set h 1469598103934665603
    foreach b $bytes {
        set h [expr {(($h ^ ($b & 0xff)) * 1099511628211) & 0xFFFFFFFFFFFFFFFF}]
    }
    return [format %016x $h]
}
set canonical [lsort [lmap b $blocks {canon $b}]]
puts "nir.digest         [Digest [join $canonical 
]]"
