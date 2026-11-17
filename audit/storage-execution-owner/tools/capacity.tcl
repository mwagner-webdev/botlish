# capacity.tcl -- a model of compiler-derived String capacity
# (STORAGE-EXECUTION-OWNER-CENSUS-1.md, sections 10, 11 and 20): from the
# facts the compiler already computes -- hir::range's Ranges, hir::lifetime's
# regions, verdicts and coexistence -- a conservative byte bound for each
# String a region would hold, and two capacities per region: the bump
# capacity (every site's block side by side, as the native scratch provider
# lays them out today) and the overlay capacity (the largest set of blocks
# that coexist, as a layout reusing a dead object's bytes inside one region
# could). No compiler code computes any of this: it is this census's model,
# labeled [inference] in the report, and its bounds are checked against the
# native provider's measured peak where a program has one region.
#
#   tclsh9.0 audit/storage-execution-owner/tools/capacity.tcl ?-out FILE?
#       ?FILE.bot ...?
#
# A String expression's byte bound (UTF-8 bytes; "" when none):
#   a constant                    its bytes
#   std::int::to_string(x)        the decimal digits of x's widest value
#                                 (a sign counted), when x's Range is finite
#   std::str::concat(a, b)        bound(a) + bound(b)
#   std::str::append_char(s, c)   bound(s) + 4
#   std::str::substring(s, ...)   bound(s)
#   a reference                   the bound of the value it is bound to
# A site's block is the native String block of its bound (runtime/
# strobj.rs: 25 + bytes, rounded to 8). Only producers of the owner classes
# a region could hold are counted (probe.tcl's transient, segment and
# persistent: confined to their innermost region), grouped by that region.
set here [file dirname [file normalize [info script]]]
set audit [file dirname $here]
set root [file dirname [file dirname $audit]]
set options [dict create -out [file join $audit results capacity.md]]
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
set cases [file join $root audit storage-static-reuse cases]
set probes [file join $audit probes]
if {$files eq {}} {
    set files [list $cases/p01-sequential-temps.bot $cases/p02-simultaneous-temps.bot \
        $cases/p03-exclusive-branches.bot $cases/p04-loop-reuse.bot $cases/p05-escape-result.bot \
        $cases/p07b-string-across-suspension.bot $cases/p13-request-handler.bot $cases/p14-errors-early-exit.bot \
        $probes/e01-sequential-owner.bot $probes/e02-nested-calls.bot $probes/e03-independent-coroutines.bot \
        $probes/e04-resumption.bot $probes/e09-abandonment.bot $probes/e11-bounded-string.bot \
        $probes/e12-unbounded-string.bot $probes/e13-nested-owners.bot]
}

proc Block {b} {
    return [expr {((25 + $b + 7) / 8) * 8}]
}

# The byte bound of String expression E in instance ID, or {"" WHY}.
proc Bound {hir spec ranges id e {depth 0}} {
    if {$depth > 40} {
        return [list "" "too deep"]
    }
    set n [dict get $hir exprs $e]
    switch -- [dict get $n kind] {
        const {
            set v [dict get $n value]
            if {[lindex $v 0] eq "str"} {
                return [list [string length [encoding convertto utf-8 [lindex $v 1]]] ""]
            }
            return [list "" "a constant that is not a String"]
        }
        ref {
            set b [dict getdef $n binding ""]
            if {$b ne "" && [dict exists $hir bindings $b]} {
                set decl [dict get $hir bindings $b declaredBy]
                if {$decl ne "" && [dict exists $hir exprs $decl] && [dict get $hir exprs $decl kind] eq "bind"} {
                    return [Bound $hir $spec $ranges $id [dict get $hir exprs $decl value] [expr {$depth + 1}]]
                }
            }
            return [list "" "a binding whose value is not a local expression (a parameter, a capture, a resume message)"]
        }
        call {
            lassign [hir::storageplan::Target $hir $spec $id $e] tkind tid
            set args [dict get $n args]
            if {$tkind ne "native"} {
                return [list "" "the result of a call of a function (no summary of its result's size)"]
            }
            switch -- $tid {
                std::int::to_string {
                    set r [hir::range::of $ranges $id [lindex $args 0]]
                    set lo [dict get $r min]
                    set hi [dict get $r max]
                    if {[string match *inf $lo] || [string match *inf $hi]} {
                        return [list "" "to_string of an Int with no finite Range ([hir::range::show $r])"]
                    }
                    return [list [expr {max([string length $lo], [string length $hi])}] ""]
                }
                std::str::concat {
                    lassign [Bound $hir $spec $ranges $id [lindex $args 0] [expr {$depth + 1}]] a wa
                    lassign [Bound $hir $spec $ranges $id [lindex $args 1] [expr {$depth + 1}]] b wb
                    if {$a eq ""} { return [list "" $wa] }
                    if {$b eq ""} { return [list "" $wb] }
                    return [list [expr {$a + $b}] ""]
                }
                std::str::append_char {
                    lassign [Bound $hir $spec $ranges $id [lindex $args 0] [expr {$depth + 1}]] a wa
                    if {$a eq ""} { return [list "" $wa] }
                    return [list [expr {$a + 4}] ""]
                }
                std::str::substring {
                    return [Bound $hir $spec $ranges $id [lindex $args 0] [expr {$depth + 1}]]
                }
                default {
                    return [list "" "the native $tid (no size rule)"]
                }
            }
        }
        default {
            return [list "" "a [dict get $n kind] expression"]
        }
    }
}

set lines [list "# String capacity derivable from existing facts (a model)" "" \
    "Generated by \`tclsh9.0 audit/storage-execution-owner/tools/capacity.tcl\` (STORAGE-EXECUTION-OWNER-CENSUS-1.md). For each unit, each region a confined String producer would be placed in (its innermost region: the activation, or an iteration of a loop), the byte bound this tool derives for each such String from the range analysis and constant text (its header), its native block, and the region's **bump** capacity (blocks side by side, today's provider) and **overlay** capacity (the heaviest set of blocks the lifetime facts say coexist). These are a census model's numbers \[inference\], not a compiler fact; \"measured peak\" is the native provider's peak occupancy for the whole run (scratch storage on), comparable where the program places Strings in one region at a time." ""]
foreach file $files {
    set name [file rootname [file tail $file]]
    puts stderr "capacity: $name"
    set hir [surface::readProgramFile $file -warnings off]
    set spec [hir::specialize::analyze $hir -specialize 1]
    set facts [hir::lifetime::analyze $hir -spec $spec]
    set ranges [hir::range::analyze $hir $spec]
    set r [native::allocationReport $hir summary 1]
    set peak [dict getdef [dict getdef $r scratch {}] peakOccupancy 0]
    lappend lines "## $name" "" "Measured peak in use (whole run, scratch storage on): $peak B." ""
    foreach id [hir::lifetime::unitsIn $hir $facts $file] {
        set u [hir::lifetime::unit $facts $id]
        set suspends [expr {[llength [dict get $u suspensions]] > 0}]
        # Region -> sites (confined String producers).
        set regions [dict create]
        dict for {site p} [dict get $u producers] {
            if {[dict get $p kind] ne "str"} continue
            set loops [dict get $p loops]
            set region [if {[llength $loops]} {list iteration [lindex $loops end]} else {string cat activation}]
            if {[dict get $u verdicts $site $region verdict] ne "confined"} continue
            dict lappend regions $region $site
        }
        if {![dict size $regions]} continue
        lappend lines "unit [dict get $u label][expr {$suspends ? " (may suspend: its regions would be an owner's)" : ""}]"
        dict for {region sites} $regions {
            set blocks [dict create]
            set unbounded {}
            foreach site $sites {
                set p [dict get $u producers $site]
                lassign [Bound $hir $spec $ranges $id [dict get $p expr]] b why
                set seg [dict get $u verdicts $site segment verdict]
                set kind [expr {$seg eq "confined" ? ($suspends ? "segment" : "transient") : "persistent"}]
                if {$b eq ""} {
                    lappend unbounded $site
                    lappend lines "  [lindex $region 0] region: [dict get $p what] at [dict get $p origin] ($kind): no bound -- $why"
                } else {
                    dict set blocks $site [Block $b]
                    lappend lines "  [lindex $region 0] region: [dict get $p what] at [dict get $p origin] ($kind): at most $b bytes, a [Block $b]-byte block"
                }
            }
            if {[llength $unbounded]} {
                lappend lines "  => [lindex $region 0] region: no finite capacity ([llength $unbounded] of [llength $sites] Strings unbounded)"
                continue
            }
            set bump 0
            dict for {s b} $blocks { incr bump $b }
            set overlay 0
            dict for {s b} $blocks {
                set w $b
                foreach t [dict getdef [dict get $u coexist] $s {}] {
                    if {$t ne $s && [dict exists $blocks $t]} {
                        incr w [dict get $blocks $t]
                    }
                }
                set overlay [expr {max($overlay, $w)}]
            }
            lappend lines "  => [lindex $region 0] region: bump capacity $bump B, overlay capacity $overlay B"
        }
    }
    lappend lines ""
}
set f [open [dict get $options -out] w]
fconfigure $f -encoding utf-8 -translation lf
puts -nonewline $f [join $lines \n]
close $f
puts stderr "capacity: wrote [string map [list $root/ {}] [dict get $options -out]]"
