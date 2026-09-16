# substr_classify.tcl -- baseline classification of `substring` call sites
# (the milestone "Optimize String access and temporary substrings"), driven
# by the existing allocation-site instrumentation (native/src/runtime/
# metrics.rs, native::allocationReport's sites mode) and the same
# hir::stringregion analysis that drives the optimization itself -- not
# assumed patterns.
#
#   tclsh bench/substr_classify.tcl [PROGRAM ...]
#
# With no arguments, classifies every algorithm in the corpus
# (examples/stdlib/corpus.tcl) that calls `substring` at all (csv,
# csv_chunked, csv_geometric, string_replace) plus the composed csv_records
# workload (examples/stdlib/csv_records.bot). PROGRAM names either a corpus
# algorithm (corpus::names) or a .bot file under examples/stdlib.
#
# For each `substring` call site (grouped by source location -- one line can
# be reached from several specialized instances, counted once), reports:
#
#   shape     one-char   the end operand is syntactically "start + 1" (or
#                        "1 + start"): the CSV-scanner idiom this milestone's
#                        #6 targets (examples/stdlib/csv.bot's `peek`)
#             multi-char anything else
#   category  A  one-character access, recognized as a StringRegion by
#                hir::stringregion.tcl (native/lower.tcl's "String regions"
#                section): every reference is a supported consumer
#                (`==`/`length`), so no temporary String is ever allocated
#             B  a longer (non-one-character) temporary region, also fully
#                recognized: same zero-allocation treatment
#             C  escapes as a real, independent output String (stored,
#                returned, or otherwise not recognized as consumed only by
#                `==`/`length`): allocates exactly as before -- this
#                milestone does not and should not change that
#             D  ambiguous/unsupported: neither clearly a discardable
#                temporary nor clearly an escaping result (a mixed-use
#                binding compared *and* concatenated, or a use this
#                conservative analysis simply does not recognize)
#   allocations at this site, -string-region-opt 1 vs 0 (the empirical
#   confirmation of the classification: A/B sites should read 0/N>0, C
#   sites should read N/N, D sites vary)
#
# This is deliberately a source-classification tool (which *sites* exist and
# what they mean), not a re-implementation of hir::stringregion.tcl's own
# recognition: category A/B both mean "hir::stringregion.tcl already
# eliminates this site's temporary", which the allocation columns confirm
# empirically rather than by re-deriving the analysis's own logic twice.

set root [file dirname [file dirname [file normalize [info script]]]]
source [file join $root core core.tcl]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
source [file join $root examples stdlib corpus.tcl]

# ---------------------------------------------------------------------------
# Finding `substring` call sites in a program's generic (unspecialized)
# lowering: one pass over every used instance's own region is enough to see
# every *source* call site once (specialization changes typing, not shape).

# 1 if E and OTHER (view HIR) are both `ref` expressions naming the same
# binding: expression-id equality is never right here, since the source
# idiom `substring(text, index, index + 1)` mentions `index` twice, as two
# distinct `ref` expressions of the one binding.
proc sameBinding {hir e other} {
    return [expr {[hir::kind $hir $e] eq "ref" && [hir::kind $hir $other] eq "ref"
        && [hir::get $hir $e binding] ne "" && [hir::get $hir $e binding] eq [hir::get $hir $other binding]}]
}

# 1 if expression E (view HIR) is a native `+` call adding a constant 1 to
# expression OTHER (either operand order) -- the "start + 1"/"1 + start"
# shape of a one-character substring's end operand.
proc oneMore {hir e other} {
    if {[hir::kind $hir $e] ne "call"} {
        return 0
    }
    set node [hir::node $hir $e]
    lassign [dict get $node target] targetKind target
    if {$targetKind ne "native" || [dict get [hir::symbol $hir $target] name] ne "+"
            || [llength [dict get $node args]] != 2} {
        return 0
    }
    lassign [dict get $node args] a b
    foreach {x y} [list $a $b $b $a] {
        if {[sameBinding $hir $x $other] && [hir::kind $hir $y] eq "const"
                && [core::value::kind [hir::get $hir $y value]] eq "int"
                && [core::value::intOf [hir::get $hir $y value]] == 1} {
            return 1
        }
    }
    return 0
}

# "one-char" or "multi-char": the shape of substring call E (view HIR,
# NODE its call node) -- purely syntactic, independent of how the result is
# used (the milestone's #6: recognize the *shape* CSV scanning uses).
proc substrShape {hir node} {
    lassign [dict get $node args] textExpr startExpr endExpr
    return [expr {[oneMore $hir $endExpr $startExpr] ? "one-char" : "multi-char"}]
}

# A (locationText -> {shape count exprIds}) dict of every `substring` call
# site reachable from any used instance of HIR/SPEC.
proc findSubstrSites {hir spec} {
    set context [dict get $spec context]
    set sites [dict create]
    foreach id [dict get $spec used] {
        set instance [dict get $spec instances $id]
        set block [dict get $instance block]
        set region [expr {$block eq "program" ? "program" : $block}]
        set view [hir::specialize::view $hir $spec $id]
        foreach e [dict get $context exprs $region] {
            if {[hir::kind $view $e] ne "call"} {
                continue
            }
            set node [hir::node $view $e]
            lassign [dict get $node target] targetKind target
            if {$targetKind ne "native" || [dict get [hir::symbol $view $target] name] ne "substring"
                    || [llength [dict get $node args]] != 3} {
                continue
            }
            set location [hir::aot::Location $view [hir::get $view $e origin]]
            set text [expr {[dict exists $location line]
                ? "[dict get $location file]:[dict get $location line]" : "ir"}]
            set shape [substrShape $view $node]
            if {![dict exists $sites $text]} {
                dict set sites $text [dict create shape $shape count 0]
            }
            dict set sites $text count [expr {[dict get $sites $text count] + 1}]
        }
    }
    return $sites
}

# ---------------------------------------------------------------------------
# Report

proc classify {shape before after} {
    if {$before == 0} {
        # Nothing to eliminate either way (e.g. never actually reached).
        return D
    }
    if {$after == 0} {
        return [expr {$shape eq "one-char" ? "A" : "B"}]
    }
    if {$after == $before} {
        return C
    }
    return D
}

proc reportProgram {label hir} {
    puts "=== $label ==="
    set spec [hir::specialize::analyze $hir -specialize 0]
    set sites [findSubstrSites $hir $spec]
    if {[dict size $sites] == 0} {
        puts "  (no substring call sites)"
        puts ""
        return
    }
    set siteReportOn [native::allocationReport $hir sites 1 -string-region-opt 1]
    set siteReportOff [native::allocationReport $hir sites 1 -string-region-opt 0]
    # hirExpr -> allocation count, resolved back to the same "file:line" key
    # findSubstrSites uses, per mode.
    proc byLocation {report} {
        set byLoc [dict create]
        foreach site [dict get $report sites] {
            if {[dict get $site operation] ne "substr"} {
                continue
            }
            set location [dict get $site location]
            if {![dict exists $location line]} {
                continue
            }
            set text "[dict get $location file]:[dict get $location line]"
            dict incr byLoc $text [dict get $site allocations]
        }
        return $byLoc
    }
    set onCounts [byLocation $siteReportOn]
    set offCounts [byLocation $siteReportOff]
    set totalA 0
    set totalB 0
    set totalC 0
    set totalD 0
    puts [format "  %-55s %-10s %8s %8s %8s" location shape before after category]
    dict for {loc info} $sites {
        set shape [dict get $info shape]
        set before [expr {[dict exists $offCounts $loc] ? [dict get $offCounts $loc] : 0}]
        set after [expr {[dict exists $onCounts $loc] ? [dict get $onCounts $loc] : 0}]
        set cat [classify $shape $before $after]
        incr total[set cat]
        puts [format "  %-55s %-10s %8d %8d %8s" $loc $shape $before $after $cat]
    }
    puts "  totals: A(one-char, eliminated)=$totalA B(temporary, eliminated)=$totalB C(escaping)=$totalC D(ambiguous)=$totalD"
    puts ""
}

# ---------------------------------------------------------------------------
# Driver

set programs $argv
if {$programs eq ""} {
    set programs {csv csv_chunked csv_geometric string_replace csv_records}
}

foreach name $programs {
    if {$name in [corpus::names]} {
        reportProgram $name [surface::readProgramFile [corpus::path $name]]
    } elseif {[file exists [file join $root examples stdlib $name.bot]]} {
        reportProgram $name [surface::readProgramFile [file join $root examples stdlib $name.bot]]
    } else {
        puts "unknown program: $name"
    }
}
