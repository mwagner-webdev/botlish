#!/usr/bin/env tclsh9.0
# corpus.tcl -- POST-R2A-DYNAMIC-CENSUS.md's cheap corpus generality check:
# for every program in the repository's own compiled corpus (bench/*.ir,
# bench/*.bot, examples/stdlib/*.bot, examples/surface/*.bot), the static
# population of each candidate mechanism's pattern. Observation only.
#
#   tclsh9.0 audit/post-r2a-dynamic-census/tools/corpus.tcl OUTFILE
#
# Columns (static site/instance counts in the default lowering, never
# dynamic): callvalue sites; per-call closure allocations (`closure` ops
# outside <program>); closure-valued functions (env=1); module-retained
# values reaching a function as a flattened capture parameter (a pname
# containing "::"); generic used instances; OpenInstances; OpenInstances
# that blockescape nevertheless flattens (the range<->blockescape
# mismatch population); `substr` (materializing) sites; region ops
# (regioncheck/regioneq/strregion*); setcontainstotal sites.
set root [pwd]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000
set out [lindex $argv 0]
core::loadLibrary web

set files [concat [lsort [glob bench/*.ir]] [lsort [glob -nocomplain bench/*.bot]] \
    [lsort [glob examples/stdlib/*.bot]] [lsort [glob examples/surface/*.bot]]]
set L {}
lappend L "| program | callvalue | per-call closure allocs (closure ops outside <program>) | closure-valued fns (env=1) | flattened module-value params | generic instances | OpenInstances | open but blockescape-flattened | substr | region ops | setcontainstotal |"
lappend L "|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|"
foreach path $files {
    if {[catch {
        if {[file extension $path] eq ".bot"} {
            set hir [surface::readProgramFile $path]
        } else {
            set hir [native::buildProgramHir [core::loadProgramFile $path]]
        }
        set spec [hir::specialize::analyze $hir]
        set open [hir::range::OpenInstances $spec]
        set be [hir::blockescape::analyze $hir $spec]
        set nir [native::nir $hir]
    } err]} {
        lappend L "| $path | (not lowerable: [string range $err 0 60]) |||||||||"
        continue
    }
    set generic 0
    set openFlat 0
    foreach id [dict get $spec used] {
        set inst [hir::specialize::instance $spec $id]
        if {[dict get $inst generic] && [dict get $inst block] ne "program"} { incr generic }
        if {[dict exists $open $id] && [hir::blockescape::wants $be $id]} { incr openFlat }
    }
    set cv 0; set clo 0; set envfns 0; set modparams 0; set substr 0; set region 0; set setc 0
    set cur ""
    foreach line [split $nir \n] {
        if {[regexp {^func \d+ "([^"]*)" params=\d+ env=(\d) [^\n]*pnames="([^"]*)"} $line -> name envFlag pnames]} {
            set cur $name
            if {$envFlag} { incr envfns }
            foreach p $pnames { if {[string match *::* $p]} { incr modparams } }
            continue
        }
        if {[regexp {= callvalue } $line]} { incr cv }
        if {[regexp {= closure } $line] && $cur ne "<program>"} { incr clo }
        if {[regexp {= op substr } $line]} { incr substr }
        if {[regexp {= op (regioncheck|regioneq|strregion\w*) } $line]} { incr region }
        if {[regexp {= op setcontainstotal } $line]} { incr setc }
    }
    lappend L "| $path | $cv | $clo | $envfns | $modparams | $generic | [dict size $open] | $openFlat | $substr | $region | $setc |"
}
set f [open $out w]
fconfigure $f -encoding utf-8
puts $f [join $L \n]
close $f
puts [join $L \n]
