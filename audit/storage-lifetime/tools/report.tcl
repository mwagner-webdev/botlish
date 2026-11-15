# report.tcl -- the storage lifetime facts of programs, as text
# (STORAGE-LIFETIME-FACTS-MILESTONE-1.md, hir/lifetime.tcl).
#
#   tclsh9.0 audit/storage-lifetime/tools/report.tcl ?-all 0|1? ?-out DIR?
#       ?-specialize 0|1? FILE.bot...
#
# Prints, for each FILE, hir::lifetime::report over the units written in
# FILE (with -all 1, every unit: the standard library's too), and with -out
# writes it to DIR/NAME.txt instead. Deterministic: two runs on the same
# tree write the same bytes (no time, no host path: a unit is named by its
# function and its specialization key, a site by its operation and its
# FILE:LINE:COLUMN).
#
# With no FILE, the census corpus (audit/storage-static-reuse/cases/) and
# this audit's own cases (audit/storage-lifetime/cases/) are reported into
# audit/storage-lifetime/results/facts/.
set here [file dirname [file normalize [info script]]]
set audit [file dirname $here]
set root [file dirname [file dirname $audit]]
set options [dict create -all 0 -out "" -specialize 1]
set files {}
for {set i 0} {$i < [llength $argv]} {incr i} {
    set a [lindex $argv $i]
    if {[dict exists $options $a]} {
        dict set options $a [lindex $argv [incr i]]
    } else {
        lappend files $a
    }
}
set argv {}
source [file join $root surface surface.tcl]
set env(LANG) C.utf8
set env(LC_ALL) C.utf8
if {$files eq {}} {
    set files [concat [lsort [glob [file join $root audit storage-static-reuse cases *.bot]]] \
        [lsort [glob -nocomplain [file join $audit cases *.bot]]]]
    if {[dict get $options -out] eq ""} {
        dict set options -out [file join $audit results facts]
    }
}

proc writeFile {path text} {
    set f [open $path w]
    fconfigure $f -encoding utf-8 -translation lf
    puts -nonewline $f $text
    close $f
}

set out [dict get $options -out]
if {$out ne ""} {
    file mkdir $out
}
foreach file $files {
    set name [file rootname [file tail $file]]
    if {[catch {surface::readProgramFile $file -warnings off} hir]} {
        set text "$name: does not compile: [string map [list [file dirname [file normalize $file]]/ "" $root/ ""] [lindex [split $hir \n] 0]]\n"
    } else {
        set facts [hir::lifetime::analyze $hir -specialize [dict get $options -specialize]]
        set only [if {[dict get $options -all]} {list} else {hir::lifetime::unitsIn $hir $facts $file}]
        set text "[hir::lifetime::report $hir $facts $only]\n"
        # Library paths print as checkout-relative.
        set text [string map [list $root/ ""] $text]
    }
    if {$out eq ""} {
        puts "== $name"
        puts -nonewline $text
    } else {
        writeFile [file join $out $name.txt] $text
        puts "$name: [llength [split $text \n]] lines"
    }
}
