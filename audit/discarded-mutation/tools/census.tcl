# census.tcl -- every DISCARDED-MUTATION warning in the repository's Botlish
# programs (WARNINGS-DISCARDED-MUTATION-MILESTONE-1.md, sections 11 and 12).
#
#   tclsh9.0 audit/discarded-mutation/tools/census.tcl \
#       ?-out FILE.tsv? ?-shard I/N? ?-programs FILES? ?-root DIR?
#
# The programs are the construct-binding census's (CONSTRUCT-BINDING-
# MUTATION-CENSUS-1.md, section 11.1): every .bot file the repository
# tracks but the generated C bindings, plus a one-line loader
# `import std::NAME` per standard library module. Each is compiled by the
# ordinary front end with warnings on (the default policy, emitted
# nowhere); the warnings it carries are the census. A warning in a module
# several programs load is listed once (by its location), with the number
# of programs that observed it.
#
# Output: one TSV row per warning (location, reason, root binding, area,
# programs, first program, message), then a summary on stdout: the programs
# compiled and rejected, and the warnings per area.

set here [file dirname [file normalize [info script]]]
set checkout [file dirname [file dirname [file dirname $here]]]
set root $checkout
set out ""
set shard 1/1
set programs {}
foreach {option value} $argv {
    switch -- $option {
        -out { set out $value }
        -shard { set shard $value }
        -programs { set programs $value }
        -root { set root [file normalize $value] }
        default { error "unknown option $option" }
    }
}
set env(LANG) C.utf8
set env(LC_ALL) C.utf8
unset -nocomplain env(BOTLISH_HIR_CACHE)
unset -nocomplain env(BOTLISH_WARNINGS)
source [file join $checkout examples stdlib corpus.tcl]
interp recursionlimit {} 1000000

namespace eval dmc {
    variable rows [dict create]
}

proc dmc::Programs {root} {
    set files [split [string trim [exec git -C $root ls-files *.bot]] \n]
    set result {}
    foreach f $files {
        if {[string match generated/* $f] || [string match tools/c-bindgen/fixture/expected/* $f]} continue
        if {[string match stdlib/* $f]} continue
        lappend result $f
    }
    foreach f $files {
        if {![string match stdlib/* $f]} continue
        lappend result loader:$f
    }
    return $result
}

proc dmc::Relative {root path} {
    if {[string first $root/ $path] == 0} {
        return [string range $path [string length $root/] end]
    }
    if {[string first $::core::libraryDir/ $path] == 0} {
        return stdlib/[string range $path [string length $::core::libraryDir/] end]
    }
    return $path
}

proc dmc::Area {path} {
    foreach {pattern area} {
        stdlib/* stdlib examples/* examples packages/* packages bench/* bench
        tests/golden/* golden tests/* tests audit/construct-binding-mutation/corpus/* census-corpus
        audit/discarded-mutation/* own-corpus audit/* audit
    } {
        if {[string match $pattern $path]} {
            return $area
        }
    }
    return other
}

if {$programs eq {}} {
    set programs [dmc::Programs $root]
}
lassign [split $shard /] si sn
set compiled 0
set rejected {}
set n 0
foreach program $programs {
    incr n
    if {($n - 1) % $sn != $si - 1} continue
    if {[string match loader:* $program]} {
        set module [file rootname [string range $program [string length loader:stdlib/] end]]
        set ns std::[string map {/ ::} $module]
        regsub {\.(x86_64|aarch64)$} $ns {} ns
        set code [catch {surface::compile "import $ns\n0\n" loader.bot -warnings default -warning-channel ""} hir options]
    } else {
        set code [catch {surface::readProgramFile [file join $root $program] -warnings default -warning-channel ""} hir options]
    }
    if {$code} {
        lappend rejected $program [lrange [dict getdef $options -errorcode ?] 0 2]
        continue
    }
    incr compiled
    foreach w [hir::warnings::of $hir] {
        if {[dict get $w code] ne "DISCARDED-MUTATION"} continue
        set origin [dict get $w primary]
        set location [hir::originLocation $hir $origin]
        regexp {^(.*):(\d+):(\d+)$} $location -> path line column
        set path [dmc::Relative $root $path]
        set at $path:$line:$column
        if {[dict exists $::dmc::rows $at]} {
            dict lappend ::dmc::rows $at programs $program
            continue
        }
        set data [dict get $w data]
        dict set ::dmc::rows $at [dict create reason [dict get $data reason] name [dict get $data name] \
            area [dmc::Area $path] message [dict get $w message] programs [list $program]]
    }
}

set lines {}
set areas [dict create]
dict for {at row} $::dmc::rows {
    dict with row {
        lappend lines [join [list $at $reason $name $area [llength [lsort -unique $programs]] [lindex [lsort $programs] 0] $message] \t]
        dict incr areas "$area $reason"
    }
}
if {$out ne ""} {
    set f [open $out w]
    puts $f [join {site reason root area programs first message} \t]
    foreach line [lsort $lines] {
        puts $f $line
    }
    close $f
}
puts "programs: [expr {($n + $sn - 1) / $sn}] in shard, compiled $compiled, rejected [expr {[llength $rejected] / 2}]"
foreach {p c} $rejected {
    puts "  rejected $p ($c)"
}
puts "warnings: [llength $lines]"
dict for {k v} $areas {
    puts "  $k $v"
}
