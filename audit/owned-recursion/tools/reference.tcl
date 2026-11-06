# reference.tcl -- the walk hir::structs::OwnedRecursion was before
# OWNED-RECURSION-DECLARATION-SUMMARY-MILESTONE-1 (revision 09b1ea9),
# verbatim but for its namespace (::reference::owned) and its two bounds,
# which are variables here (recursionDepth 64, recursionBudget 4096, as
# they were). Audit-only: audit/owned-recursion/tools/parity.tcl compares
# the compiler's verdict with it; no production code loads it. It reads the
# compiler's own registry and type functions (AppliedFieldTypes, IsAffine,
# ...), which this milestone does not change.

namespace eval ::reference::owned {
    variable recursionDepth 64
    variable recursionBudget 4096
}

proc ::reference::owned::OwnedRecursion {type} {
    set type [hir::types::Unrefined $type]
    if {![hir::types::IsNamedStruct $type] || ![hir::types::IsAffine $type]} {
        return ""
    }
    set visited [dict create]
    return [OwnedRecursionFrom [lindex $type 1] $type $type 0 {} visited]
}

proc ::reference::owned::OwnedRecursionFrom {target start type crossed path visitedVar} {
    upvar 1 $visitedVar visited
    variable recursionDepth
    variable recursionBudget
    set type [hir::types::Unrefined $type]
    if {![hir::types::IsAffine $type]} {
        return ""
    }
    if {[hir::types::IsNamedStruct $type]} {
        set id [lindex $type 1]
        if {$path ne {} && $id eq $target} {
            if {$crossed} {
                return [list recursive $path]
            }
            if {$type eq $start} {
                return ""
            }
        }
        if {[dict exists $visited $type,$crossed] || ![hir::structs::declared $id]} {
            return ""
        }
        if {[llength $path] >= $recursionDepth || [dict size $visited] >= $recursionBudget} {
            return [list unbounded $path]
        }
        dict set visited $type,$crossed 1
        set owner $type
        set fields [hir::structs::AppliedFieldTypes $type]
    } elseif {[hir::types::IsStruct $type]} {
        set owner ""
        set fields [lindex $type 1]
    } elseif {[hir::types::IsList $type] || [hir::types::IsMutVec $type] || [hir::types::IsMutArray $type]} {
        return [OwnedRecursionFrom $target $start [lindex $type 1] 1 $path visited]
    } else {
        return ""
    }
    foreach {name t} $fields {
        set found [OwnedRecursionFrom $target $start $t $crossed [linsert $path end [list $owner $name $t]] visited]
        if {$found ne ""} {
            return $found
        }
    }
    return ""
}

proc ::reference::owned::RecursionSteps {path} {
    return [join [lmap step $path {
        lassign $step owner name t
        if {$owner eq ""} {
            set shown "{...}"
        } elseif {![hir::types::IsAppliedStruct $owner] || $owner eq [hir::structs::SelfType [lindex $owner 1]]} {
            set shown [hir::structs::display [lindex $owner 1]]
        } else {
            set shown [hir::types::presented $owner]
        }
        format {%s.%s: %s} $shown $name [hir::types::show $t]
    }] ", "]
}

