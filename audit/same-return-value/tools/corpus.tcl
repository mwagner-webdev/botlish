# corpus.tcl -- observational audit of SAME-RETURN-VALUE over the frozen
# corpus (WARNINGS-SAME-RETURN.md, "Corpus findings"). Compiles every corpus
# program with warnings on (collected, not emitted), prints every distinct
# warning once with the source line of each exit, and a count. It edits
# nothing.
#
#   tclsh9.0 audit/same-return-value/tools/corpus.tcl

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
source [file join $root surface surface.tcl]

set programs [concat \
    [lsort [glob -directory [file join $root examples stdlib] *.bot]] \
    [lsort [glob -directory [file join $root examples surface] *.bot]] \
    [lsort [glob -directory [file join $root bench] *.bot]] \
    [lsort [glob -directory [file join $root lib] *.bot]]]

proc lineOf {hir origin} {
    set path [dict get [hir::sourceFile $hir [lindex $origin 1]] path]
    set line [dict get [lrange $origin 2 end] line]
    set channel [open $path]
    fconfigure $channel -encoding utf-8
    set lines [split [read $channel] \n]
    close $channel
    return [string trim [lindex $lines [expr {$line - 1}]]]
}

set seen [dict create]
set failed {}
foreach path $programs {
    if {[catch {surface::readProgramFile $path -warnings default -warning-channel ""} hir options]} {
        lappend failed [list [file tail $path] [dict get $options -errorcode] $hir]
        continue
    }
    foreach w [hir::warnings::of $hir] {
        set primary [dict get $w primary]
        set where [hir::originLocation $hir $primary]
        if {[dict exists $seen $where]} {
            continue
        }
        set rel [string map [list $root/ {}] $where]
        dict set seen $where [list $rel [dict get $w code] [dict get $w message] \
            [lmap o [list $primary {*}[dict get $w secondary]] {
                list [string map [list $root/ {}] [hir::originLocation $hir $o]] [lineOf $hir $o]
            }] [file tail $path]]
    }
}
set n 0
foreach where [lsort -dictionary [dict keys $seen]] {
    lassign [dict get $seen $where] rel code message exits entry
    incr n
    puts "$n. $rel: $code: $message   (first seen compiling $entry)"
    foreach exit $exits {
        puts "     [lindex $exit 0]: [lindex $exit 1]"
    }
}
puts "programs compiled: [expr {[llength $programs] - [llength $failed]}] of [llength $programs]"
foreach f $failed {
    puts "did not compile standalone: [lindex $f 0] ([lindex $f 1])"
}
puts "distinct SAME-RETURN-VALUE warnings: $n"
