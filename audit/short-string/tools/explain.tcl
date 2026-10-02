#!/usr/bin/env tclsh9.0
# explain.tcl -- SHORT-STRING.md audit text (native::shortstr::explainAll) for
# every canonical corpus program: per instance and per local String value the
# proven character length, ShortString1 eligibility, physical representation,
# production, uses (scalar consumer or materialization frontier) and the
# reason a String position stayed tagged. Writes OUTDIR/NAME.txt.
#
#   tclsh9.0 audit/short-string/tools/explain.tcl OUTDIR ?PROGRAM.bot...?
source [file join [file dirname [file normalize [info script]]] lib.tcl]
set out [lindex $argv 0]
set paths [lrange $argv 1 end]
if {$paths eq ""} { set paths [corpusPaths] }
file mkdir $out
foreach path $paths {
    set hir [surface::readProgramFile $path]
    native::lowered $hir
    set f [open [file join $out [programName $path].txt] w]
    fconfigure $f -encoding utf-8
    puts -nonewline $f [native::shortstr::explainAll]
    close $f
}
