#!/usr/bin/env tclsh9.0
# ir.tcl -- SHORT-STRING.md deterministic dynamic-instruction measurement:
# callgrind Ir per steady-state run of every canonical corpus program, three
# ways:
#
#   base  the parent commit (before the milestone): its own NIR (BASE-NIR-DIR,
#         from emit-base-nir.tcl run in a checkout of the parent) running on
#         the parent's own audit build (BASE-BIN)
#   off   this tree with -short-string-opt 0
#   on    this tree with -short-string-opt 1 (the default)
#
# (audit/post-r2a-dynamic-census/tools/profile-nir.sh on an audit-only build
# of each tree's botlish-native; the patch adds no code to generated
# functions.) `off` differs from `base` only by the runtime's per-String
# first-scalar field. A program whose NIR is byte-identical across all three
# is not profiled again for `on`.
#
#   tclsh9.0 audit/short-string/tools/ir.tcl BIN BASE-BIN BASE-NIR-DIR OUTDIR ?-runs N? ?-heavy-runs M? ?PROGRAM.bot...?
source [file join [file dirname [file normalize [info script]]] lib.tcl]
lassign $argv bin baseBin baseNirDir out
set args [lrange $argv 4 end]
set runs 11
set heavyRuns 4
set paths {}
while {$args ne ""} {
    set a [lindex $args 0]
    if {$a eq "-runs"} { set runs [lindex $args 1]; set args [lrange $args 2 end]
    } elseif {$a eq "-heavy-runs"} { set heavyRuns [lindex $args 1]; set args [lrange $args 2 end]
    } else { lappend paths $a; set args [lrange $args 1 end] }
}
if {$paths eq ""} { set paths [corpusPaths] }
file mkdir $out
set script [file join $root audit post-r2a-dynamic-census tools profile-nir.sh]
set heavy {uri-steady refined-checks csv_records csv_chunked csv_geometric}
proc totalsIr {file} {
    set f [open $file]
    set text [read $f]
    close $f
    if {[regexp {totals per run: Ir=([0-9,]+)} $text -> ir]} { return [string map {, {}} $ir] }
    return ""
}
proc readFile {path} {
    set f [open $path]
    fconfigure $f -encoding utf-8
    set t [read $f]
    close $f
    return $t
}
foreach path $paths {
    set name [programName $path]
    set hir [surface::readProgramFile $path]
    set nirBase [readFile [file join $baseNirDir $name.nir]]
    set nirOff [native::nir $hir -short-string-opt 0]
    set nirOn [native::nir $hir -short-string-opt 1]
    set n [expr {$name in $heavy ? $heavyRuns : $runs}]
    file mkdir [file join $out $name]
    set configs [list base $baseBin $nirBase off $bin $nirOff]
    if {$nirOn ne $nirOff} { lappend configs on $bin $nirOn }
    foreach {tag binary nir} $configs {
        set f [open [file join $out $name $tag.nir] w]
        fconfigure $f -encoding utf-8 -translation lf
        puts -nonewline $f $nir
        close $f
        exec bash $script $binary [file join $out $name $tag.nir] $n [file join $out $name profile-$tag] 2>@1
        set ir($tag) [totalsIr [file join $out $name profile-$tag profile.txt]]
    }
    if {![info exists ir(on)] || $nirOn eq $nirOff} { set ir(on) $ir(off) }
    puts [format "%-15s base %12s  off %12s (%+.2f%%)  on %12s  on-vs-base %+d (%+.2f%%)  on-vs-off %+d (%+.2f%%)  %s" $name $ir(base) $ir(off) \
        [expr {100.0 * ($ir(off) - $ir(base)) / $ir(base)}] $ir(on) \
        [expr {$ir(on) - $ir(base)}] [expr {100.0 * ($ir(on) - $ir(base)) / $ir(base)}] \
        [expr {$ir(on) - $ir(off)}] [expr {$ir(off) > 0 ? 100.0 * ($ir(on) - $ir(off)) / $ir(off) : 0}] \
        [expr {$nirOn eq $nirOff ? "(NIR unchanged)" : ""}]]
    unset ir
    flush stdout
}
