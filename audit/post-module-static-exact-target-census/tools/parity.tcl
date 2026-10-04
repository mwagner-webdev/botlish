#!/usr/bin/env tclsh9.0
# parity.tcl -- POST-MODULE-STATIC-EXACT-TARGET-CENSUS.md's semantic-parity
# check for the exact-target counterfactual. Observation only.
#
#   (cd TREE && tclsh9.0 .../parity.tcl CORPUS.txt OUTFILE)
#
# Runs from the CURRENT DIRECTORY's tree (production, or a scratch
# counterfactual worktree whose own lib/web.bot was rewritten), so the SAME
# script's output can be diffed across trees: identical files mean
# identical observable behavior on every address and every backend.
#
# CORPUS.txt: one address per line, UTF-8, taken verbatim (leading/trailing
# blanks and tabs included); the line "<empty>" stands for "".
#
# Every address reaches the predicate as a runtime value (a data List
# walked by an ordinary recursive function), never as a folded constant.
# Two programs, because a module-qualified name resolves only through the
# surface path and the root predicate's native -module-fn bridge only
# through the IR path:
#   module  a .bot program calling web::emailish?(s) directly -- the
#           module's own Botlish source, the code the counterfactual
#           rewrites -- run exactly the way main.tcl runs a .bot file on each
#           backend (interp and compile evaluate lib/web.bot's own source;
#           cranelift-generic / cranelift compile it);
#   root    a .ir program calling emailish?(s) -- the path
#           bench/refined-checks.ir itself takes: the -module-fn bridge to
#           web::emailish? on the native backends, and the independent Tcl
#           validator (emailRegex) on interp/compile, which serves as the
#           oracle for the Botlish source.
set root [pwd]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000
lassign $argv corpusPath out
set backends {interp compile cranelift-generic cranelift}

set f [open $corpusPath]
fconfigure $f -encoding utf-8
set corpus {}
foreach line [split [string trimright [read $f] \n] \n] {
    lappend corpus [expr {$line eq "<empty>" ? "" : $line}]
}
close $f

proc botString {s} {
    return "\"[string map [list \\ \\\\ \" \\\" \t \\t] $s]\""
}
proc writeFile {path text} {
    set f [open $path w]
    fconfigure $f -encoding utf-8
    puts -nonewline $f $text
    close $f
}
# "[true, false, ...]" (core::value::show's surface form) -> {true false ...}
proc parseBools {shown} {
    return [split [string map {"\[" "" "\]" "" " " ""} $shown] ,]
}

set dir [file dirname [file normalize $out]]
set bot [file join $dir parity-module.bot]
writeFile $bot "# requires: web
import list
import web

corpus = \[[join [lmap s $corpus {botString $s}] {, }]\]

fn go(i, acc):
    if i >= list::length(corpus):
        return acc
    go(i + 1, list::append(acc, web::emailish?(list::at(corpus, i))))

go(0, \[\])
"
set ir [file join $dir parity-root.ir]
writeFile $ir "# requires: web
[list [list bind corpus [list call {ref list} {*}[lmap s $corpus {list const str $s}]]]]
{bind go {block {i acc}
  {if {call {ref >=} {ref i} {call {ref list::length} {ref corpus}}}
    {block {} {ref acc}}
    {block {} {call {ref go} {call {ref +} {ref i} {const 1}}
                 {call {ref list::append} {ref acc} {call {ref emailish?} {call {ref list::at} {ref corpus} {ref i}}}}}}}}}
{call {ref go} {const 0} {call {ref list}}}
"

set hir [surface::readProgramFile $bot]
set lowered [hir::lower $hir]
set irProgram [core::loadProgramFile $ir]
set results [dict create]
foreach {backend run} {
    interp            {core::evalProgram $lowered}
    compile           {core::compiler::evalHir $hir}
    cranelift-generic {native::evalHir $hir -specialize 0}
    cranelift         {native::evalHir $hir}
} {
    if {[catch $run r opts]} {
        dict set results module $backend [lrepeat [llength $corpus] "ERROR([dict get $opts -errorcode])"]
    } else {
        dict set results module $backend [parseBools [core::value::show $r 1]]
    }
}
foreach backend $backends {
    core::useBackend $backend
    if {[catch {core::evalProgram $irProgram} r opts]} {
        dict set results root $backend [lrepeat [llength $corpus] "ERROR([dict get $opts -errorcode])"]
    } else {
        dict set results root $backend [parseBools [core::value::show $r 1]]
    }
}
core::useBackend interp

set L {}
lappend L "tree: [exec git -C $root rev-parse HEAD] (lib/web.bot diff lines: [llength [split [exec git -C $root diff -- lib/web.bot] \n]])"
lappend L "columns: module = web::emailish?(s) via .bot, root = emailish?(s) via .ir; each on $backends"
set crossBackend 0
set oracle 0
set trueCount 0
set i 0
foreach s $corpus {
    set mods [lmap b $backends {lindex [dict get $results module $b] $i}]
    set roots [lmap b $backends {lindex [dict get $results root $b] $i}]
    set all [lsort -unique [concat $mods $roots]]
    if {[llength $all] != 1} { incr crossBackend }
    # Oracle: the Tcl validator (root predicate on interp) vs every
    # evaluation of the Botlish source.
    if {[lsort -unique [concat [lindex $roots 0] $mods [lrange $roots 2 end]]] ne [lindex $roots 0]} { incr oracle }
    if {[lindex $mods 0] eq "true"} { incr trueCount }
    lappend L [format "%-3d %-58s module=%s root=%s" $i [list $s] [join $mods /] [join $roots /]]
    incr i
}
lappend L "addresses: [llength $corpus] (accepted: $trueCount, rejected: [expr {[llength $corpus] - $trueCount}])"
lappend L "addresses where any backend/path disagrees: $crossBackend"
lappend L "addresses where the Botlish source disagrees with the Tcl-validator oracle: $oracle"
writeFile $out "[join $L \n]\n"
file delete $bot $ir
puts "wrote $out ($crossBackend disagreements, $oracle oracle disagreements, $trueCount accepted)"
