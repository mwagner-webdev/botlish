# transport.tcl -- the value-transport cost model and graph arithmetic of
# hir/escape.tcl's representation analysis (VALUE-TRANSPORT-MATERIALIZATION.md).
#
# This file is not a second analysis. hir::escape::analyze is still the one
# authority on which fixed-shape values are carried as fields; this module is
# the *arithmetic* it consults to decide how far a value may be carried that
# way before it should become one physical aggregate:
#
#   * the policy options (legacy width caps vs the transport model) and the
#     tunable weights/budgets (Option, Default);
#   * the pressure score of carrying W independently transported values over
#     a number of exact argument edges, return edges and a cycle (Hop,
#     EdgeScore, PathScore), and the budgets that bound it (Budget);
#   * the distance summaries over the exact-forwarding graph of virtual
#     parameter slots: strongly connected components, longest argument and
#     return paths upstream and downstream of every slot, cyclic marking
#     (Plan). Linear in the size of the graph; no path is enumerated.
#
# Everything here is *heuristic and dimensionless*: scores are "transport
# pressure", never cycles. The only measured facts behind the defaults are
# the width/distance probes of STRUCT-SCALAR-REPLACEMENT.md and
# VALUE-TRANSPORT-MATERIALIZATION.md (stack operands, code bytes); the weights
# are calibrated to them, not derived from them.
#
# The model, in one line: carrying a value of width W across one exact
# boundary in direction D costs  factor[D] * W * (1 + spill[D](W)),  where
# spill is how far W exceeds the values a boundary of that direction carries
# in registers; a path costs the sum over its edges (width x distance, per
# direction); a cycle costs cycleFactor extra argument edges (a loop carries
# its value forever). A value stays virtual across a boundary only while its
# whole path -- upstream of the slot back to the nearest place that could
# have become the physical object, and downstream to the real consumption --
# stays within the direction's budget.

namespace eval hir::transport {
    # Option defaults. policy: "transport" (this model) or "legacy" (the
    # struct-scalar-replacement milestone's width-only caps, kept as the
    # comparison oracle: local 16, return 8, argument 4, no distance).
    variable defaults {
        policy transport
        localWidth 16
        returnWidth 16
        argWidth 8
        legacyLocalWidth 16
        legacyReturnWidth 8
        legacyArgWidth 4
        argFactor 1.0
        returnFactor 0.5
        cycleFactor 4.0
        argRegs 4
        returnRegs 8
        argBudget 24.0
        returnBudget 32.0
        cycleBudget 24.0
        densityWeight 0.5
        allocUnits 16.0
        nesting 1
    }
}

# The value of option NAME in STRUCTOPTS (a dict, any key optional), falling
# back to the default.
proc hir::transport::Option {structOpts name} {
    variable defaults
    if {[dict exists $structOpts $name]} {
        return [dict get $structOpts $name]
    }
    return [dict get $defaults $name]
}

proc hir::transport::Legacy {structOpts} {
    return [expr {[Option $structOpts policy] eq "legacy"}]
}

# The hard safety ceiling (fields) of BOUNDARY (local | return | arg): the
# widest struct that may ever stay virtual there, whatever its score. Under
# the legacy policy these are the old caps themselves.
proc hir::transport::Ceiling {structOpts boundary} {
    if {[Legacy $structOpts]} {
        if {[dict exists $structOpts ${boundary}Width]} {
            return [dict get $structOpts ${boundary}Width]
        }
        return [Option $structOpts legacy[string totitle $boundary]Width]
    }
    return [Option $structOpts ${boundary}Width]
}

# DIR is arg or return. The score of carrying WIDTH independent values across
# one such boundary: the values themselves plus, for every value beyond the
# register budget of that direction, one more transfer (a spill and reload).
proc hir::transport::Hop {structOpts dir width} {
    set regs [Option $structOpts ${dir}Regs]
    set spill [expr {max(0, $width - $regs)}]
    return [expr {double($width) * (1 + $spill)}]
}

# The weighted score of one edge in direction DIR (arg | return).
proc hir::transport::EdgeScore {structOpts dir width} {
    return [expr {[Option $structOpts ${dir}Factor] * [Hop $structOpts $dir $width]}]
}

# The transport score of a path of ARGEDGES argument edges and RETEDGES return
# edges at WIDTH, CYCLIC (0|1) adding the loop term, scaled by DENSITY
# (>= 1: the unused share of the transported fields). A pure function.
proc hir::transport::PathScore {structOpts width argEdges retEdges cyclic density} {
    set ca [EdgeScore $structOpts arg $width]
    set cr [EdgeScore $structOpts return $width]
    set s [expr {$argEdges * $ca + $retEdges * $cr}]
    if {$cyclic} {
        set s [expr {$s + [Option $structOpts cycleFactor] * $ca}]
    }
    return [expr {$s * $density}]
}

# The budget a path is held to: cyclic > arg > return by which edge kinds it
# contains (the strictest applicable, since the budgets are per direction).
proc hir::transport::Budget {structOpts argEdges retEdges cyclic} {
    if {$cyclic} {
        return [Option $structOpts cycleBudget]
    }
    if {$argEdges > 0} {
        return [Option $structOpts argBudget]
    }
    return [Option $structOpts returnBudget]
}

# The use-density multiplier of a slot that transports WIDTH values of which
# USED are ever read: 1 when every field is consumed, up to 1 + densityWeight
# when none is (a bundle that is forwarded but barely opened).
proc hir::transport::Density {structOpts width used} {
    if {$width <= 0} {
        return 1.0
    }
    set share [expr {double(min($used, $width)) / $width}]
    return [expr {1.0 + [Option $structOpts densityWeight] * (1.0 - $share)}]
}

# The verdict on a *result* of width WIDTH that crosses DEPTH+1 return edges
# (DEPTH exact forwarding exits below the consuming caller) before it is
# consumed: {OK SCORE BUDGET EDGES}. Returns are acyclic by construction (an
# instance's result is recognized only through already-recognized targets).
proc hir::transport::ReturnVerdict {structOpts width depth} {
    set edges [expr {$depth + 1}]
    set score [PathScore $structOpts $width 0 $edges 0 1.0]
    set budget [Option $structOpts returnBudget]
    return [list [expr {$score <= $budget}] $score $budget $edges]
}

# Plans the virtual *parameter* slots NODES (a list of slot keys) over the
# exact-forwarding graph. FWD: key -> list of keys it forwards its value to
# unchanged (each such forward is one argument edge). SUPPLY: key -> list of
# {SOURCE RETEDGES}: one entry per exact call site that can hand the slot its
# value; SOURCE is the key of a caller slot that forwards its own parameter
# ("" when the argument is a construction or a local, which can itself become
# the physical object lazily, so the path starts there), RETEDGES the number
# of return edges the construction already crossed (an argument that is
# itself the result of an exact call). WIDTH/USED: key -> transported width /
# number of distinct fields ever read downstream.
#
# Returns key -> dict {width used up down ret cyclic score budget ok}: UP is
# the longest argument path into the slot (>= 1: the edge that delivers it),
# DOWN the longest argument path out of it to a consumption, RET the return
# edges at the head of the worst path, CYCLIC whether the slot lies on a
# forwarding cycle (a self-tail loop or mutual recursion, whose distance is
# unbounded: it gets the cycle term instead of a fabricated finite distance),
# SCORE/BUDGET/OK the verdict. SCCs by Tarjan (iterative), then one pass in
# topological order for each of the two longest-path summaries: linear.
proc hir::transport::Plan {structOpts nodes fwd supply width used} {
    set index [dict create]
    set i 0
    foreach n $nodes {
        dict set index $n $i
        incr i
    }
    # Tarjan, iterative. comp: key -> component number, components are
    # numbered in completion order (sinks first = reverse topological).
    set low [dict create]
    set num [dict create]
    set onStack [dict create]
    set comp [dict create]
    set members [dict create]
    set stack {}
    set counter 0
    set ncomp 0
    foreach root $nodes {
        if {[dict exists $num $root]} {
            continue
        }
        set work [list [list $root 0]]
        while {$work ne ""} {
            lassign [lindex $work end] v pos
            if {$pos == 0} {
                dict set num $v $counter
                dict set low $v $counter
                incr counter
                lappend stack $v
                dict set onStack $v 1
            }
            set succ [expr {[dict exists $fwd $v] ? [dict get $fwd $v] : {}}]
            set descended 0
            while {$pos < [llength $succ]} {
                set w [lindex $succ $pos]
                incr pos
                if {![dict exists $index $w]} {
                    continue
                }
                if {![dict exists $num $w]} {
                    set work [lreplace $work end end [list $v $pos]]
                    lappend work [list $w 0]
                    set descended 1
                    break
                } elseif {[dict exists $onStack $w]} {
                    dict set low $v [expr {min([dict get $low $v], [dict get $num $w])}]
                }
            }
            if {$descended} {
                continue
            }
            set work [lrange $work 0 end-1]
            if {$work ne ""} {
                set parent [lindex $work end 0]
                dict set low $parent [expr {min([dict get $low $parent], [dict get $low $v])}]
            }
            if {[dict get $low $v] == [dict get $num $v]} {
                while 1 {
                    set w [lindex $stack end]
                    set stack [lrange $stack 0 end-1]
                    dict unset onStack $w
                    dict set comp $w $ncomp
                    dict lappend members $ncomp $w
                    if {$w eq $v} {
                        break
                    }
                }
                incr ncomp
            }
        }
    }
    # A component is cyclic when it has several members or one that forwards
    # to itself.
    set cyclic [dict create]
    for {set c 0} {$c < $ncomp} {incr c} {
        set m [dict get $members $c]
        set cyc [expr {[llength $m] > 1}]
        if {!$cyc} {
            set v [lindex $m 0]
            if {[dict exists $fwd $v] && [lsearch -exact [dict get $fwd $v] $v] >= 0} {
                set cyc 1
            }
        }
        dict set cyclic $c $cyc
    }
    # down: longest argument path out of a component (component numbers
    # ascend from sinks, so every successor is already done).
    set downA [dict create]
    set usedSet [dict create]
    for {set c 0} {$c < $ncomp} {incr c} {
        set best 0
        set u {}
        foreach v [dict get $members $c] {
            if {[dict exists $used $v]} {
                lappend u {*}[dict get $used $v]
            }
            if {![dict exists $fwd $v]} {
                continue
            }
            foreach w [dict get $fwd $v] {
                if {![dict exists $comp $w]} {
                    continue
                }
                set wc [dict get $comp $w]
                if {$wc == $c} {
                    continue
                }
                set best [expr {max($best, 1 + [dict get $downA $wc])}]
                lappend u {*}[dict get $usedSet $wc]
            }
        }
        dict set downA $c $best
        dict set usedSet $c [lsort -unique $u]
    }
    # up: longest argument path into a component, with the return edges at the
    # head of that path; sources come later in the numbering (their component
    # number is higher), so walk from the highest down. The path maximized is
    # the weighted one (argument edge weight vs return edge weight at the
    # component's width).
    set upA [dict create]
    set upR [dict create]
    for {set c [expr {$ncomp - 1}]} {$c >= 0} {incr c -1} {
        set bestA 0
        set bestR 0
        set bestW -1.0
        set w0 [lindex [dict get $members $c] 0]
        set wd [dict get $width $w0]
        set ca [EdgeScore $structOpts arg $wd]
        set cr [EdgeScore $structOpts return $wd]
        foreach v [dict get $members $c] {
            if {![dict exists $supply $v]} {
                continue
            }
            foreach entry [dict get $supply $v] {
                lassign $entry src ret
                set a 1
                set r $ret
                if {$src ne "" && [dict exists $comp $src]} {
                    set sc [dict get $comp $src]
                    if {$sc == $c} {
                        continue
                    }
                    set a [expr {1 + [dict get $upA $sc]}]
                    set r [expr {$ret + [dict get $upR $sc]}]
                }
                set wt [expr {$a * $ca + $r * $cr}]
                if {$wt > $bestW} {
                    set bestW $wt
                    set bestA $a
                    set bestR $r
                }
            }
        }
        if {$bestW < 0} {
            # No site can hand this slot its value as fields: nothing to
            # transport (the verdict is moot; callers use the canonical form).
            set bestA 1
        }
        dict set upA $c $bestA
        dict set upR $c $bestR
    }
    set result [dict create]
    foreach v $nodes {
        set c [dict get $comp $v]
        set wd [dict get $width $v]
        set cyc [dict get $cyclic $c]
        set up [dict get $upA $c]
        set down [dict get $downA $c]
        set ret [dict get $upR $c]
        set usedN [llength [dict get $usedSet $c]]
        set density [Density $structOpts $wd $usedN]
        set score [PathScore $structOpts $wd [expr {$up + $down}] $ret $cyc $density]
        set budget [Budget $structOpts [expr {$up + $down}] $ret $cyc]
        dict set result $v [dict create width $wd used $usedN up $up down $down ret $ret \
            cyclic $cyc score $score budget $budget ok [expr {$score <= $budget}]]
    }
    return $result
}
