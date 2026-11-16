# storageplan.tcl -- the storage-use plan: which allocation sites may place
# their objects in compiler-managed scratch storage, in which region, and
# why or why not (STORAGE-COMPILER-MANAGED-SCRATCH-MILESTONE-1.md).
#
#   set plan [hir::storageplan::plan $hir $facts $spec ?-natives NAMES?
#                 ?-excluded {UNIT REASON ...}?]
#   hir::storageplan::unit $plan $id        -> one unit's plan (below)
#   hir::storageplan::report $hir $plan ?UNITS? -> the plan, as text
#
# FACTS is hir::lifetime::analyze's result for HIR under SPEC (the
# specialization analysis the backend lowers from: the plan's unit and call
# identities are its instances).
#
# Three questions, kept apart (the report prints each):
#
#   * Is reuse semantically safe? hir::lifetime's verdicts: an object is
#     placed in a region only where it is `confined` to that region, in a
#     unit that never suspends (no region is ever live across a
#     suspension, so the segment verdict is the activation's). The region
#     is always the innermost one the site runs in -- its innermost loop's
#     iteration, else its activation -- so a region holds at most one
#     execution of each of its sites and every region's storage is reset
#     at its own boundary (no object of a loop is retained by an outer
#     region until that one ends).
#   * Can the backend place it there? Representability is the backend's: a
#     String producer of one of the natives NAMES (-natives), and a call
#     whose callee takes a destination (below). Every other producer kind
#     keeps its ordinary allocation.
#   * Does the policy choose it? The policy of this first plan: every safe,
#     representable site is selected; units the backend cannot frame
#     (-excluded, with its reason: a self tail call reuses its frame) and
#     units that may suspend get no region at all.
#
# Destinations (cross-function placement). A unit's producer that escapes
# its activation only through the unit's result (every reason `result`), at
# no loop of the unit, may go to its caller's region when the caller says
# so: the caller's call is itself a producer (the fresh part of the call's
# result, hir/lifetime.tcl's o:CALL), and where that is confined to the
# call's innermost region the caller passes the destination 1; where it
# escapes the caller only through the caller's own result, a unit that
# itself received a destination passes its own on (`dest`). A unit takes a
# destination (is `capable`) only when it never suspends, is not excluded,
# is not the program, is in no recursive component of the call graph (a
# recursion's leftovers would pile up in the outermost region) and some
# caller passes it one. Only a direct call can pass one (the backend checks
# that its callee takes it); a call through a value never does, so a unit
# entered any other way always allocates on the heap what it returns.
#
# Facts, not code: the plan is computed on demand and stored nowhere; the
# backend reads it while it lowers and records what it emitted (an
# instruction it matched, or why none). It never changes a verdict and adds
# no width, size or profitability cutoff to one: the size of an object is
# the storage provider's policy at run time (runtime/scratch.rs).

namespace eval hir::storageplan {
    # The natives whose String result the native backend can place in
    # scratch storage (each helper allocates at most one String, its result:
    # runtime/scratch.rs).
    variable defaultNatives {std::int::to_string std::str::concat std::str::substring std::str::append_char}
}

proc hir::storageplan::plan {hir facts spec args} {
    variable defaultNatives
    set options [hir::Options hir::storageplan::plan [list -natives $defaultNatives -excluded {}] $args]
    set natives [dict get $options -natives]
    set excluded [dict get $options -excluded]
    set units [hir::lifetime::units $facts]
    # Per unit: what keeps it from having regions at all.
    set blocked [dict create]
    foreach id $units {
        set u [hir::lifetime::unit $facts $id]
        if {[dict exists $excluded $id]} {
            dict set blocked $id [dict get $excluded $id]
        } elseif {[llength [dict get $u suspensions]]} {
            dict set blocked $id "it may suspend: a region is never live across a suspension"
        }
    }
    set recursive [Recursive $spec $units]
    # Per site: the semantic and representability facts.
    set sites [dict create]
    foreach id $units {
        set u [hir::lifetime::unit $facts $id]
        dict for {site p} [dict get $u producers] {
            dict set sites $id $site [Site $hir $spec $id $u $site $p $natives]
        }
    }
    # Candidates for a destination, callees first: a unit with a result-only
    # site it can place (a String producer, or a call of a candidate).
    set candidate [dict create]
    foreach id [CalleesFirst $spec $units] {
        if {[dict exists $blocked $id] || [dict get [hir::lifetime::unit $facts $id] block] eq "program"
                || [dict exists $recursive $id]} {
            continue
        }
        dict for {site s} [dict getdef $sites $id {}] {
            if {[dict get $s semantic] ne "result" || [dict get $s representable] ne ""} continue
            if {[dict get $s form] eq "native" || ([dict get $s form] eq "call" && [dict exists $candidate [dict get $s callee]])} {
                dict set candidate $id 1
                break
            }
        }
    }
    # Who receives one: least fixpoint over the calls that pass 1 (confined
    # in the caller's region) or pass on the caller's own.
    set receives [dict create]
    set changed 1
    while {$changed} {
        set changed 0
        foreach id $units {
            if {[dict exists $blocked $id]} continue
            dict for {site s} [dict getdef $sites $id {}] {
                if {[dict get $s form] ne "call"} continue
                set callee [dict get $s callee]
                if {![dict exists $candidate $callee] || [dict exists $receives $callee]} continue
                set passes [expr {[dict get $s semantic] eq "confined"
                    || ([dict get $s semantic] eq "result" && [dict exists $candidate $id] && [dict exists $receives $id])}]
                if {$passes} {
                    dict set receives $callee 1
                    set changed 1
                }
            }
        }
    }
    # The decisions.
    set plan [dict create units [dict create]]
    foreach id $units {
        set u [hir::lifetime::unit $facts $id]
        set capable [expr {[dict exists $candidate $id] && [dict exists $receives $id]}]
        set loops {}
        set activation 0
        set decided [dict create]
        dict for {site s} [dict getdef $sites $id {}] {
            set d [dict merge $s [dict create status rejected request "" placement "" policy ""]]
            if {[dict exists $blocked $id]} {
                dict set d policy [dict get $blocked $id]
            } elseif {[dict get $s representable] ne ""} {
                dict set d policy "not representable: [dict get $s representable]"
            } elseif {[dict get $s semantic] eq "confined"} {
                if {[dict get $s form] eq "call" && ![dict exists $candidate [dict get $s callee]]} {
                    dict set d policy "its callee takes no destination: [CalleeWhy $facts [dict get $s callee] $blocked $recursive $candidate]"
                } else {
                    dict set d status selected
                    dict set d request 1
                    set region [dict get $s region]
                    dict set d placement $region
                    if {$region eq "activation"} {
                        set activation 1
                    } elseif {[lindex $region 1] ni $loops} {
                        lappend loops [lindex $region 1]
                    }
                }
            } elseif {[dict get $s semantic] eq "result"} {
                if {!$capable} {
                    dict set d policy [if {[dict exists $candidate $id]} {string cat "it escapes through the result, and no caller gives this unit a destination"} else {string cat "it escapes through the result, and this unit takes no destination: [CalleeWhy $facts $id $blocked $recursive $candidate]"}]
                } elseif {[dict get $s form] eq "call" && ![dict exists $candidate [dict get $s callee]]} {
                    dict set d policy "its callee takes no destination: [CalleeWhy $facts [dict get $s callee] $blocked $recursive $candidate]"
                } else {
                    dict set d status selected
                    dict set d request dest
                    dict set d placement caller
                }
            } else {
                dict set d policy "not confined to its innermost region"
            }
            dict set decided $site $d
        }
        set frame [expr {![dict exists $blocked $id] && ($activation || [llength $loops] || $capable)}]
        dict set plan units $id [dict create id $id block [dict get $u block] label [dict get $u label] \
            blocked [dict getdef $blocked $id ""] capable $capable candidate [dict exists $candidate $id] \
            receives [dict exists $receives $id] recursive [dict exists $recursive $id] \
            frame $frame activation $activation loops [lsort -dictionary $loops] sites $decided]
    }
    return $plan
}

proc hir::storageplan::unit {plan id} {
    return [dict getdef $plan units $id [dict create id $id frame 0 capable 0 activation 0 loops {} sites {} blocked "not analyzed"]]
}

proc hir::storageplan::units {plan} {
    return [dict keys [dict get $plan units]]
}

# The facts of producer SITE (P its lifetime record) of unit ID: its form
# (native NAME, call of a block instance, other), innermost region, the
# semantic answer (confined to the innermost region | result only | no)
# with the verdict it read, and why it is not representable ("" if it is).
proc hir::storageplan::Site {hir spec id u site p natives} {
    set e [dict get $p expr]
    set loops [dict get $p loops]
    set region [if {[llength $loops]} {list iteration [lindex $loops end]} else {string cat activation}]
    set verdicts [dict get $u verdicts $site]
    set v [dict get $verdicts $region]
    set act [dict get $verdicts activation]
    set semantic no
    if {[dict get $v verdict] eq "confined" && [dict get [dict get $verdicts segment] verdict] eq "confined"} {
        set semantic confined
    } elseif {$region eq "activation" && [dict get $act verdict] eq "escapes" && [llength [dict get $act reasons]]
            && [lsearch -not -exact [lmap r [dict get $act reasons] {dict get $r category}] result] < 0} {
        set semantic result
    }
    set node [dict get $hir exprs $e]
    set form other
    set callee ""
    set native ""
    set representable ""
    if {[dict get $node kind] eq "call"} {
        lassign [Target $hir $spec $id $e] tkind tid
        if {$tkind eq "native"} {
            set form native
            set native $tid
            if {$tid ni $natives} {
                set representable "the native $tid"
            } elseif {[dict get $p kind] ne "str"} {
                set representable "a [dict get $p kind] result (only Strings are placed)"
            }
        } elseif {$tkind eq "block"} {
            set callee [dict getdef [dict get $spec instances $id] calls $e ""]
            if {$callee eq ""} {
                set callee [hir::specialize::genericInstance $hir $spec $tid]
            }
            if {$callee eq ""} {
                set form other
                set representable "a call the analysis does not resolve"
            } else {
                set form call
            }
        } else {
            set representable "a call through a function value"
        }
    } else {
        set representable "a [dict get $p kind] (only Strings are placed)"
    }
    return [dict create expr $e kind [dict get $p kind] what [dict get $p what] origin [dict get $p origin] \
        region $region verdict [dict get $v verdict] reasons [dict get $v reasons] \
        activation [dict get $act verdict] activationReasons [dict get $act reasons] \
        semantic $semantic form $form native $native callee $callee representable $representable]
}

# The call target of call E in instance ID: {native NAME}, {block E} or "".
proc hir::storageplan::Target {hir spec id e} {
    set node [dict get $hir exprs $e]
    set overlay [dict getdef [dict get $spec instances $id] overlay {}]
    if {[dict exists $overlay $e]} {
        set over [lindex [dict get $overlay $e] 3]
        if {$over ne ""} {
            return $over
        }
    }
    lassign [dict get $node target] kind tid
    if {$kind eq "native"} {
        return [list native [dict get $hir symbols $tid name]]
    }
    if {$kind eq "block"} {
        return [list block $tid]
    }
    return ""
}

# The instance ids of UNITS whose instances' calls form a cycle (a self
# call included).
proc hir::storageplan::Recursive {spec units} {
    set graph [CallGraph $spec $units]
    set result [dict create]
    foreach scc [Components $graph $units] {
        if {[llength $scc] > 1} {
            foreach id $scc {
                dict set result $id 1
            }
        } elseif {[lindex $scc 0] in [dict getdef $graph [lindex $scc 0] {}]} {
            dict set result [lindex $scc 0] 1
        }
    }
    return $result
}

proc hir::storageplan::CallGraph {spec units} {
    set graph [dict create]
    foreach id $units {
        set out {}
        if {[dict exists $spec instances $id]} {
            dict for {e callee} [dict getdef [dict get $spec instances $id] calls {}] {
                if {$callee ne "" && $callee in $units && $callee ni $out} {
                    lappend out $callee
                }
            }
        }
        dict set graph $id $out
    }
    return $graph
}

# The strongly connected components of GRAPH over NODES, callees first
# (Tarjan's algorithm, iterative).
proc hir::storageplan::Components {graph nodes} {
    set index [dict create]
    set low [dict create]
    set onStack [dict create]
    set stack {}
    set result {}
    set next 0
    foreach root $nodes {
        if {[dict exists $index $root]} continue
        set work [list [list $root 0]]
        while {[llength $work]} {
            lassign [lindex $work end] v i
            if {$i == 0} {
                dict set index $v $next
                dict set low $v $next
                incr next
                lappend stack $v
                dict set onStack $v 1
            }
            set succ [dict getdef $graph $v {}]
            if {$i < [llength $succ]} {
                lset work end 1 [expr {$i + 1}]
                set w [lindex $succ $i]
                if {![dict exists $index $w]} {
                    lappend work [list $w 0]
                } elseif {[dict exists $onStack $w]} {
                    dict set low $v [expr {min([dict get $low $v], [dict get $index $w])}]
                }
                continue
            }
            set work [lrange $work 0 end-1]
            if {[llength $work]} {
                set parent [lindex $work end 0]
                dict set low $parent [expr {min([dict get $low $parent], [dict get $low $v])}]
            }
            if {[dict get $low $v] == [dict get $index $v]} {
                set scc {}
                while 1 {
                    set w [lindex $stack end]
                    set stack [lrange $stack 0 end-1]
                    dict unset onStack $w
                    lappend scc $w
                    if {$w eq $v} break
                }
                lappend result $scc
            }
        }
    }
    return $result
}

# UNITS ordered callees first (a callee before every caller outside its
# component).
proc hir::storageplan::CalleesFirst {spec units} {
    set order {}
    foreach scc [Components [CallGraph $spec $units] $units] {
        lappend order {*}$scc
    }
    return $order
}

# Why unit ID takes no destination.
proc hir::storageplan::CalleeWhy {facts id blocked recursive candidate} {
    if {[dict exists $blocked $id]} {
        return [dict get $blocked $id]
    }
    if {[dict exists $recursive $id]} {
        return "it is recursive"
    }
    if {![dict exists $candidate $id]} {
        return "nothing it returns can be placed in its caller's region"
    }
    return "no caller gives it a destination"
}

# ---------------------------------------------------------------------------
# The report

proc hir::storageplan::report {hir plan {only ""}} {
    set lines {}
    foreach id [units $plan] {
        if {$only ne "" && $id ni $only} continue
        set u [unit $plan $id]
        set head "unit [dict get $u label]"
        if {[dict get $u blocked] ne ""} {
            append head " -- no region: [dict get $u blocked]"
        } elseif {[dict get $u frame]} {
            set parts {}
            if {[dict get $u activation]} {
                lappend parts "an activation region"
            }
            foreach loop [dict get $u loops] {
                lappend parts "a region per iteration of the [hir::lifetime::What $hir $loop] at [hir::lifetime::Origin $hir $loop]"
            }
            if {[dict get $u capable]} {
                lappend parts "takes a destination from its callers"
            }
            append head " -- [join $parts {; }]"
        }
        lappend lines $head
        dict for {site s} [dict get $u sites] {
            set text "  [dict get $s what] ([dict get $s kind]) at [dict get $s origin]: [dict get $s status]"
            if {[dict get $s status] eq "selected"} {
                if {[dict get $s request] eq "dest"} {
                    append text " -- in the caller's region when the caller gives a destination"
                } elseif {[dict get $s form] eq "call"} {
                    append text " -- its callee's result in [RegionText $hir [dict get $s placement]]"
                } else {
                    append text " -- [RegionText $hir [dict get $s placement]]"
                }
            } else {
                append text " -- [dict get $s policy]"
            }
            lappend lines $text
            set why [lmap r [dict get $s reasons] {hir::lifetime::ReasonText $hir $r}]
            lappend lines "    semantic: [dict get $s verdict] to [RegionText $hir [dict get $s region]][if {$why ne {}} {string cat " ([join $why {; }])"} else {string cat ""}]"
            if {[dict get $s representable] ne ""} {
                lappend lines "    representable: no ([dict get $s representable])"
            }
        }
    }
    return [join $lines \n]
}

proc hir::storageplan::RegionText {hir region} {
    if {$region eq "caller"} {
        return "the caller's region"
    }
    return [hir::lifetime::RegionText $hir $region]
}
