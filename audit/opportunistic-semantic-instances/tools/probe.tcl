#!/usr/bin/env tclsh9.0
# probe.tcl -- compiles each snippet of a probe file (snippets separated by
# lines "### name") as a program under the strict checker and prints its last
# expression's semantic type, or the compile-time diagnostic. Runs against the
# tree it is started in (pwd is the root).
#
#   tclsh9.0 audit/opportunistic-semantic-instances/tools/probe.tcl SNIPPETS.txt [-off]
set root [pwd]
source [file join $root surface surface.tcl]
interp recursionlimit {} 100000
if {[lindex $argv 1] eq "-off"} { set hir::semantic::enabled 0 }
set f [open [lindex $argv 0]]
fconfigure $f -encoding utf-8
set text [read $f]
close $f
set parts [regexp -all -inline -indices {(?n)^### (.*)$} $text]
set headers {}
foreach {whole nm} $parts { lappend headers [list [string range $text {*}$nm] [lindex $whole 0] [lindex $whole 1]] }
set path [file join [file tempdir] probe-program.bot]
set i 0
foreach header $headers {
    lassign $header name hstart hend
    set bodyEnd [expr {$i + 1 < [llength $headers] ? [lindex $headers [expr {$i + 1}] 1] - 1 : [string length $text]}]
    incr i
    set src [string range $text [expr {$hend + 2}] $bodyEnd]
    set c [open $path w]
    fconfigure $c -encoding utf-8
    puts $c $src
    close $c
    if {[catch {surface::readProgramFile $path -strict 1} hir]} {
        regsub {^[^ ]*probe-program.bot:} $hir {} msg
        puts "$name: REJECT $msg"
    } else {
        puts "$name: OK [hir::types::show [hir::typeOf $hir [lindex [hir::roots $hir] end]]]"
    }
}
