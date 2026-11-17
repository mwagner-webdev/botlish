# probe.tcl -- the probe corpus of STORAGE-EXECUTION-OWNER-CENSUS-1.md
# (docs/): for each program, what the existing analyses and the native
# runtime say about storage that an execution owner would hold.
#
#   tclsh9.0 audit/storage-execution-owner/tools/probe.tcl ?-out DIR?
#       ?-native 0|1? ?-scope file|app? ?FILE.bot ...?
#
# With no FILE, the corpus is this audit's probes (probes/eNN*-*.bot; the
# probe directory's other .bot files are application modules the probes
# import). Writes DIR/NAME.txt per program and DIR/summary.md (default
# DIR: audit/storage-execution-owner/results/probes). Changes nothing: it
# reads the compiler's analyses and runs the programs. With -scope app, a
# program's units are those of every .bot file in its directory (an
# application and its own modules); with -native 0 nothing runs natively.
#
# Per program:
#
#   * whether it compiles (the first diagnostic if not) and its value on the
#     reference interpreter and natively (cranelift);
#   * per unit written in the program (hir::lifetime's units: one
#     specialization instance each): whether it may suspend, whether it is
#     recursive (the storage plan's rule), and per suspension point the
#     bindings, pending operands and objects kept across it;
#   * per producer (an expression that may make an object): its kind, its
#     innermost region, its verdicts and the *owner class* this census
#     derives from them (below), with the storage plan's decision today;
#   * per std::int::to_string site, the Range the range analysis proves for
#     its operand, and the decimal digits and native String block size that
#     Range would bound ([inference]: no analysis computes it today);
#   * the native allocation report (scratch storage on, and off): managed-
#     heap allocations and bytes, scratch placements, reservations and peak
#     occupancy, and the coroutine runtime's stacks.
#
# Owner classes (a census classification of hir::lifetime's verdicts; no
# compiler code computes it):
#
#   transient   confined to its innermost region and to its non-suspending
#               segment: storage a region on the Vm's stack of regions can
#               hold (today: only in units that never suspend);
#   segment     transient, in a unit that may suspend: a region would have
#               to be left before every suspension (none exists today);
#   persistent  confined to its innermost region but live across a
#               suspension (every segment reason is `suspension`): storage
#               that must survive while other executions run -- an
#               execution owner's (none exists today);
#   result      escapes its activation only through the unit's value: a
#               caller's region (a destination) could hold it;
#   escapes     reaches a sink that outlives every region of the unit (a
#               context, a yield, an error, a module binding, a caller-owned
#               value, ...); the reasons are listed;
#   unknown     reaches what the analysis does not follow.
#
# Deterministic (no time, no host path): sites are named by operation and
# FILE:LINE:COLUMN, units by function and specialization key.
set here [file dirname [file normalize [info script]]]
set audit [file dirname $here]
set root [file dirname [file dirname $audit]]
set options [dict create -out [file join $audit results probes] -native 1 -scope file]
set files {}
for {set i 0} {$i < [llength $argv]} {incr i} {
    set a [lindex $argv $i]
    if {[dict exists $options $a]} {
        dict set options $a [lindex $argv [incr i]]
    } else {
        lappend files [file normalize $a]
    }
}
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
set env(LANG) C.utf8
set env(LC_ALL) C.utf8
# Programs run on the Tcl backends under the program recursion limit, as
# main.tcl runs them (E14 recurses 200 deep).
core::useProgramRecursionLimit
if {$files eq {}} {
    set files [lsort [lmap f [glob [file join $audit probes *.bot]] {
        if {![regexp {^e[0-9]+[a-z]?-} [file tail $f]]} continue
        set f
    }]]
}
set out [file normalize [dict get $options -out]]
file mkdir $out

proc Relative {text} {
    return [string map [list $::root/ {}] $text]
}

proc writeFile {path text} {
    set f [open $path w]
    fconfigure $f -encoding utf-8 -translation lf
    puts -nonewline $f $text
    close $f
}

# The owner class of producer SITE of unit U (see the header), and the
# reason categories that decided it.
proc OwnerClass {u site suspends} {
    set p [dict get $u producers $site]
    set loops [dict get $p loops]
    set region [if {[llength $loops]} {list iteration [lindex $loops end]} else {string cat activation}]
    set verdicts [dict get $u verdicts $site]
    set v [dict get $verdicts $region]
    set seg [dict get $verdicts segment]
    set act [dict get $verdicts activation]
    set segCats [lsort -unique [lmap r [dict get $seg reasons] {dict get $r category}]]
    if {[dict get $v verdict] eq "confined"} {
        if {[dict get $seg verdict] eq "confined"} {
            return [list [expr {$suspends ? "segment" : "transient"}] {}]
        }
        if {[dict get $seg verdict] eq "escapes" && $segCats eq "suspension"} {
            return [list persistent suspension]
        }
        return [list escapes $segCats]
    }
    set cats [lsort -unique [lmap r [dict get $v reasons] {dict get $r category}]]
    if {[dict get $v verdict] eq "unknown"} {
        return [list unknown $cats]
    }
    if {$region eq "activation" && $cats eq "result"} {
        return [list result result]
    }
    return [list escapes $cats]
}

# The decimal digits of the widest value of range R, or "" when R is not
# finite.
proc Digits {r} {
    set lo [dict get $r min]
    set hi [dict get $r max]
    if {$lo eq "-inf" || $hi eq "+inf" || $lo eq "+inf" || $hi eq "-inf"} {
        return ""
    }
    return [expr {max([string length $lo], [string length $hi])}]
}

# The native String block of a String of B bytes (runtime/strobj.rs:
# STR_TEXT_OFFSET 25 + B, rounded to STR_ALIGN 8).
proc Block {b} {
    return [expr {((25 + $b + 7) / 8) * 8}]
}

proc Report {hir on} {
    return [native::allocationReport $hir summary 1 -scratch-opt [expr {$on ? 1 : 0}]]
}

set summary [list "# Execution-owner probes" "" \
    "Generated by \`tclsh9.0 audit/storage-execution-owner/tools/probe.tcl\` (STORAGE-EXECUTION-OWNER-CENSUS-1.md). One file per program. Owner classes are this census's reading of hir::lifetime's verdicts (the tool's header); \"placed today\" is what STORAGE-COMPILER-MANAGED-SCRATCH-MILESTONE-1's lowering emitted; heap counts are the native managed heap's with scratch storage on (off in parentheses)." "" \
    "| probe | units (suspending) | suspension points | producers | transient | segment | persistent | result | escapes | unknown | String sites placed today | heap allocations on (off) | scratch peak in use | coroutine stacks mapped / reused | value interp = native |" \
    "|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|"]
set classTotals [dict create]

foreach file $files {
    set name [file rootname [file tail $file]]
    puts stderr "probe: $name"
    set lines [list "# $name ([Relative $file])" ""]
    if {[catch {surface::readProgramFile $file -warnings off} hir ropts]} {
        set code [lindex [dict get $ropts -errorcode] end]
        lappend lines "rejected by the compiler ($code): [Relative [lindex [split $hir \n] 0]]"
        writeFile [file join $out $name.txt] "[join $lines \n]\n"
        lappend summary "| $name | rejected: $code | | | | | | | | | | | | | |"
        continue
    }
    # The values.
    if {[dict get $options -native]} {
        set interp [lrange [outcomeUnderHir interp $hir] 0 1]
        set native [lrange [outcomeUnderHir cranelift $hir] 0 1]
        lappend lines "value: interp [Relative $interp]; native [Relative $native]" ""
    } else {
        set interp [set native "not run"]
    }
    # The facts, the plan and the ranges, under one specialization analysis.
    set spec [hir::specialize::analyze $hir -specialize 1]
    set facts [hir::lifetime::analyze $hir -spec $spec]
    set allUnits [hir::lifetime::units $facts]
    if {[dict get $options -scope] eq "app"} {
        set units {}
        foreach f [lsort [glob [file join [file dirname $file] *.bot]]] {
            foreach id [hir::lifetime::unitsIn $hir $facts $f] {
                if {$id ni $units} { lappend units $id }
            }
        }
    } else {
        set units [hir::lifetime::unitsIn $hir $facts $file]
    }
    set recursive [hir::storageplan::Recursive $spec $allUnits]
    set plan [hir::storageplan::plan $hir $facts $spec]
    set ranges [hir::range::analyze $hir $spec]
    set counts [dict create units 0 suspending 0 points 0 producers 0 transient 0 segment 0 persistent 0 result 0 escapes 0 unknown 0]
    foreach id $units {
        set u [hir::lifetime::unit $facts $id]
        set suspends [expr {[llength [dict get $u suspensions]] > 0}]
        dict incr counts units
        if {$suspends} {
            dict incr counts suspending
        }
        set flags {}
        if {$suspends} { lappend flags "may suspend" }
        if {[dict exists $recursive $id]} { lappend flags "recursive" }
        set pu [hir::storageplan::unit $plan $id]
        lappend lines "unit [dict get $u label][expr {[llength $flags] ? " -- [join $flags {, }]" : ""}]"
        foreach s [dict get $u suspensions] {
            dict incr counts points
            set kept [llength [dict get $s objects]]
            lappend lines "  suspension [dict get $s what] at [dict get $s origin]: live bindings [llength [dict get $s bindings]], pending operands [llength [dict get $s pending]], objects kept $kept"
        }
        dict for {site p} [dict get $u producers] {
            dict incr counts producers
            lassign [OwnerClass $u $site $suspends] class cats
            dict incr counts $class
            dict incr classTotals "$class [dict get $p kind]"
            set decision ""
            if {[dict exists $pu sites $site]} {
                set ps [dict get $pu sites $site]
                set decision "; plan: [dict get $ps status][expr {[dict get $ps status] eq "rejected" ? " ([dict get $ps policy])" : ""}]"
            }
            lappend lines "  [dict get $p what] ([dict get $p kind]) at [dict get $p origin]: $class[expr {[llength $cats] && $class ni {persistent result} ? " ($cats)" : ""}]$decision"
            # A to_string site: its operand's proven Range.
            if {[dict get $p what] eq "call of std::int::to_string"} {
                set node [dict get $hir exprs [dict get $p expr]]
                set arg [lindex [dict get $node args] 0]
                set r [hir::range::of $ranges $id $arg]
                set d [Digits $r]
                if {$d eq ""} {
                    lappend lines "    operand range [hir::range::show $r]: no finite bound on the text"
                } else {
                    set signed [expr {[dict get $r min] < 0}]
                    lappend lines "    operand range [hir::range::show $r]: at most $d characters (ASCII) -- a native String block of at most [Block $d] bytes ([if {$signed} {string cat "a sign counted"} else {string cat "no sign"}]) \[inference\]"
                }
            }
        }
    }
    lappend lines "" "owner classes: [join [lmap k {transient segment persistent result escapes unknown} {string cat "$k [dict get $counts $k]"}] {, }]"
    # The native runs.
    set placed "-"
    set heap "-"
    set peak "-"
    set stacks "-"
    if {[dict get $options -native]} {
        if {[catch {
            set lowered [native::lowered $hir]
            set emitted [dict get $lowered storagePlan emitted]
            set n 0
            dict for {uid sites} $emitted {
                dict for {site st} $sites {
                    if {[dict get $st status] eq "emitted"} { incr n }
                }
            }
            set placed $n
            set on [Report $hir 1]
            set off [Report $hir 0]
            set heap "[dict get $on total allocations] ([dict get $off total allocations])"
            set sc [dict getdef $on scratch {}]
            set peak [dict getdef $sc peakOccupancy 0]
            set co [dict getdef $on coroutines {}]
            if {[dict size $co]} {
                set stacks "[dict get $co stacksMapped] / [dict get $co stacksReused]"
            } else {
                set stacks "0 / 0"
            }
            lappend lines "native, scratch storage on: heap allocations [dict get $on total allocations], heap bytes [dict get $on total allocatedBytes], collections [dict get $on gc cycles];\
                scratch placements [dict getdef $sc allocations 0], regions [dict getdef $sc regions 0], reservations [dict getdef $sc reservations 0], peak in use [dict getdef $sc peakOccupancy 0] B, stale roots [dict getdef $sc staleRoots 0], protocol errors [dict getdef $sc protocolErrors 0]"
            lappend lines "native, scratch storage off: heap allocations [dict get $off total allocations], heap bytes [dict get $off total allocatedBytes], collections [dict get $off gc cycles]"
            if {[dict size $co]} {
                lappend lines "coroutines: [join [lmap {k v} $co {string cat "$k $v"}] {, }]"
            }
            set rs [dict getdef $on resources {}]
            if {[dict size $rs]} {
                lappend lines "resources: [join [lmap {k v} $rs {string cat "$k $v"}] {, }]"
            }
            lappend lines "String sites lowering emitted a placement for: $placed"
        } message]} {
            lappend lines "native: [Relative [lindex [split $message \n] 0]]"
        }
    }
    writeFile [file join $out $name.txt] "[join $lines \n]\n"
    if {![dict get $options -native]} {
        set agree "not run"
    } elseif {$interp eq $native} {
        set agree yes
    } elseif {[lindex $interp 0] eq "value" && [lindex $native 0] eq "error"} {
        set agree "native refuses"
    } else {
        set agree NO
    }
    lappend summary "| $name | [dict get $counts units] ([dict get $counts suspending]) | [dict get $counts points] | [dict get $counts producers] |\
        [dict get $counts transient] | [dict get $counts segment] | [dict get $counts persistent] | [dict get $counts result] |\
        [dict get $counts escapes] | [dict get $counts unknown] | $placed | $heap | $peak | $stacks | $agree |"
}

lappend summary "" "## Producers by owner class and kind, over the corpus" "" "| class | kind | producers |" "|---|---|---:|"
foreach key [lsort [dict keys $classTotals]] {
    lappend summary "| [lindex $key 0] | [lindex $key 1] | [dict get $classTotals $key] |"
}
writeFile [file join $out summary.md] "[join $summary \n]\n"
puts stderr "probe: wrote [Relative $out]"
