#!/usr/bin/env tclsh9.0
# ir.tcl -- SHORT-STRING.md deterministic dynamic-instruction measurement:
# callgrind Ir per steady-state run of every canonical corpus program with
# ShortString1 off and on (audit/post-r2a-dynamic-census/tools/profile-nir.sh
# on an audit-only build of this tree's botlish-native; the patch adds no code
# to generated functions). A program whose NIR is byte-identical with the
# optimization off and on is not profiled twice: its machine code, and so its
# Ir, is the same.
#
#   tclsh9.0 audit/short-string/tools/ir.tcl AUDIT-BIN OUTDIR ?-runs N? ?-heavy-runs M? ?PROGRAM.bot...?
source [file join [file dirname [file normalize [info script]]] lib.tcl]
set bin [lindex $argv 0]
set out [lindex $argv 1]
set args [lrange $argv 2 end]
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
foreach path $paths {
    set name [programName $path]
    set hir [surface::readProgramFile $path]
    set nir0 [native::nir $hir -short-string-opt 0]
    set nir1 [native::nir $hir -short-string-opt 1]
    if {$nir0 eq $nir1} {
        puts "$name identical-nir"
        continue
    }
    set n [expr {$name in $heavy ? $heavyRuns : $runs}]
    foreach {tag nir} [list off $nir0 on $nir1] {
        file mkdir [file join $out $name]
        set f [open [file join $out $name $tag.nir] w]
        fconfigure $f -encoding utf-8 -translation lf
        puts -nonewline $f $nir
        close $f
        exec bash $script $bin [file join $out $name $tag.nir] $n [file join $out $name profile-$tag] 2>@1
        set ir($tag) [totalsIr [file join $out $name profile-$tag profile.txt]]
    }
    set delta [expr {$ir(on) - $ir(off)}]
    puts [format "%s off %s on %s delta %+d (%+.2f%%) runs %d" $name $ir(off) $ir(on) $delta [expr {100.0 * $delta / $ir(off)}] $n]
    flush stdout
}
