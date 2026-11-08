# claims.tcl -- every emission claim of a CSV program and its verdict
# (CSV-EMISSION-VALIDATION-MILESTONE-1.md).
#
#   tclsh9.0 audit/csv-emission/tools/claims.tcl PROGRAM.bot
#       one line per claim of every file the program loads: FILE FUNCTION
#       RECOGNIZER VERDICT KINDS
#
#   source audit/csv-emission/tools/claims.tcl
#   csvclaims::of PATH  => {FILE FUNCTION RECOGNIZER VERDICT KINDS}...

set csvclaimsArgv $argv
set argv {}
if {[info commands ::tcltest::test] eq ""} {
    source [file join [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]] tests helpers.tcl]
}
if {[info commands ::surface::readProgramFile] eq ""} {
    source [file join $::projectRoot surface surface.tcl]
}

namespace eval csvclaims {}

proc csvclaims::of {path} {
    set hir [surface::readProgramFile $path -warnings off -strict 0]
    set out {}
    foreach r [hir::emission::claims $hir] {
        set origin [dict get $r origin]
        set file ?
        if {[lindex $origin 0] eq "file"} {
            set file [file tail [dict get [hir::sourceFile $hir [lindex $origin 1]] path]]
        }
        set b [dict get $r block]
        set kinds [lsort -unique [lmap d [dict get $hir diagnostics] {
            if {[dict getdef $d expr ""] ne $b || ![string match EMIT-* [dict get $d kind]]} continue
            dict get $d kind
        }]]
        lappend out [list $file [namespace tail [dict get $r function]] [dict get $r recognizer] [dict get $r verdict] $kinds]
    }
    return [lsort -index 0 [lsort -index 1 $out]]
}

if {[info exists ::argv0] && [file normalize $::argv0] eq [file normalize [info script]]} {
    foreach c [csvclaims::of [file normalize [lindex $::csvclaimsArgv 0]]] {
        puts [join $c "  "]
    }
}
