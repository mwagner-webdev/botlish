#!/usr/bin/env tclsh9.0
# ir2.tcl -- SHORT-STRING.md deterministic dynamic-instruction measurement of
# the tiered regime: callgrind Ir per steady-state run of every canonical
# corpus program under five configurations.
#
#   base  the commit before the milestone (its own NIR and audit build)
#   m1    the first milestone as shipped (ShortString1 only, interned table):
#         its own NIR and audit build
#   off   this tree with -short-string-opt 0 (no short Strings; runtime without
#         the table)
#   b     this tree with -ascii-pack-opt 0 -short-demand-opt 0 (ShortString1
#         only, no table, categorical)
#   nd    this tree with -short-demand-opt 0 (packed ASCII + ShortString1, no
#         table, categorical: the regime before the demand rule)
#   new   this tree, defaults (the same with the demand rule)
#
# A configuration whose (binary, NIR) pair equals another's is profiled once.
#
#   tclsh9.0 audit/short-string/tools/ir2.tcl BIN BASE-BIN BASE-NIR-DIR M1-BIN M1-NIR-DIR OUTDIR ?-runs N? ?-heavy-runs M? ?PROGRAM.bot...?
source [file join [file dirname [file normalize [info script]]] lib.tcl]
lassign $argv bin baseBin baseNirDir m1Bin m1NirDir out
set args [lrange $argv 6 end]
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
proc pct {a b} { return [format %+.2f [expr {$b > 0 ? 100.0 * ($a - $b) / $b : 0.0}]] }
foreach path $paths {
    set name [programName $path]
    set hir [surface::readProgramFile $path]
    set n [expr {$name in $heavy ? $heavyRuns : $runs}]
    file mkdir [file join $out $name]
    set configs [list \
        base $baseBin [readFile [file join $baseNirDir $name.nir]] \
        m1 $m1Bin [readFile [file join $m1NirDir $name.nir]] \
        off $bin [native::nir $hir -short-string-opt 0] \
        b $bin [native::nir $hir -ascii-pack-opt 0 -short-demand-opt 0] \
        nd $bin [native::nir $hir -short-demand-opt 0] \
        new $bin [native::nir $hir]]
    set done [dict create]
    foreach {tag binary nir} $configs {
        set key [list $binary $nir]
        if {[dict exists $done $key]} {
            set ir($tag) [dict get $done $key]
            continue
        }
        set f [open [file join $out $name $tag.nir] w]
        fconfigure $f -encoding utf-8 -translation lf
        puts -nonewline $f $nir
        close $f
        exec bash $script $binary [file join $out $name $tag.nir] $n [file join $out $name profile-$tag] 2>@1
        set ir($tag) [totalsIr [file join $out $name profile-$tag profile.txt]]
        dict set done $key $ir($tag)
    }
    puts [format "%-15s base %10d | m1 %10d (%s%%) | off %10d (%s%%) | b %10d (%s%%) | nd %10d (%s%%) | new %10d (%s%%)  new-vs-nd %s%%  new-vs-m1 %s%%" $name \
        $ir(base) $ir(m1) [pct $ir(m1) $ir(base)] $ir(off) [pct $ir(off) $ir(base)] $ir(b) [pct $ir(b) $ir(base)] \
        $ir(nd) [pct $ir(nd) $ir(base)] $ir(new) [pct $ir(new) $ir(base)] [pct $ir(new) $ir(nd)] [pct $ir(new) $ir(m1)]]
    unset ir
    flush stdout
}
