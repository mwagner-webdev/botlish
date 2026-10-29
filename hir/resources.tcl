# resources.tcl -- resources and their cleanup obligations
# (LEXICAL-RESOURCE-CLEANUP-EXPLORATION-MILESTONE-1.md).
#
# A resource is a value of an `opaque resource struct` (hir/structs.tcl's
# isResource): affine whatever its fields, and carrying a cleanup obligation
# that exactly one disposition discharges --
#
#   * its owner's lexical scope ends while it owns the value: the cleanup
#     runs there (hir/affine.tcl places it at the end of the owning
#     binding's sequence, and on every exit that leaves it, never at the
#     binding's last use);
#   * it is moved to another owner (a binding, a parameter, a result, a
#     field, an element, a coroutine's frame, an installed context's
#     collection): the obligation moves with it;
#   * its module takes it apart (a destructuring): discharged without the
#     cleanup -- the cleanup function itself does this, and so may any
#     function of the resource's module (the struct is opaque, so no other
#     code can).
#
# The cleanup is an ordinary function of the resource's module, declared
#
#     cleanup fn NAME(r: R, context ...):
#
# with exactly one ordinary parameter of the resource struct type R, no
# flags, no declared errors, a unit result, no yield, and context parameters
# of context structs only. Calling it is the explicit early release (it moves
# the value in); the compiler calls it where an owner dies. The restrictions
# are what make an inserted call harmless to every analysis that ran before
# the insertion: it can fail with nothing (no errors clause: completion and
# error sets unchanged), suspend nothing (no yield: coroutine effects
# unchanged), and its context requirement is a static fact of the resource's
# type, charged to every function that may release one (hir/contexts.tcl
# reads Cleanups) -- never a context trait, which only a call's
# monomorphization could select. A cleanup takes its parameter apart (a
# release of the parameter inside its own cleanup would run the cleanup
# again): verifyLate checks that the parameter has no release.
#
# What HIR keeps: `resources` {cleanups {STRUCTID {block E binding B index
# K}} unwind 0|1}. K is the cleanup's index in the program's cleanup table
# (in struct-identity order), which a drop descriptor's `rK` names
# (hir/affine.tcl's Descriptor). `unwind` (hir/affine.tcl's Unwinds) is 1
# when some function that may suspend owns a cleanup-bearing value: then a
# suspended coroutine's release unwinds its frames, running their releases.

namespace eval hir::resources {}

# The cleanup record {block E binding B index K} of resource struct ID in
# HIR, or "".
proc hir::resources::Cleanup {hir id} {
    return [dict getdef $hir resources cleanups $id ""]
}

# The cleanup table of HIR: struct ID -> {block E binding B index K}.
proc hir::resources::table {hir} {
    return [dict getdef $hir resources cleanups {}]
}

# 1 if HIR's suspended coroutines are released by unwinding their frames
# (hir/affine.tcl's Unwinds).
proc hir::resources::unwinds {hir} {
    return [dict getdef $hir resources unwind 0]
}

# 1 if some struct of HIR's registry is a resource: a program without one
# pays for nothing here.
proc hir::resources::Used {hir} {
    return [expr {[dict size [table $hir]] > 0 || [dict getdef $hir resources declared 0]}]
}

# The resource structs the drop of a value of TYPE runs the cleanup of: every
# resource struct the type owns by value -- itself, a field's, an element's
# (a List, MutableVector or MutableArray), recursively -- in no particular
# order. A coroutine handle owns nothing statically (its frames' resources
# are its function's own, released by unwinding: hir/affine.tcl).
proc hir::resources::ResourcesOf {type {visiting {}}} {
    set type [hir::types::Unrefined $type]
    if {[hir::types::IsNamedStruct $type]} {
        set id [lindex $type 1]
        if {$id in $visiting || ![hir::structs::declared $id]} {
            return {}
        }
        if {[hir::structs::isResource $id]} {
            return [list $id]
        }
        if {![hir::structs::IsAffine $id]} {
            return {}
        }
        set result {}
        foreach {name t} [hir::structs::fieldTypes $id] {
            lappend result {*}[ResourcesOf $t [concat $visiting [list $id]]]
        }
        return [lsort -unique $result]
    }
    if {[hir::types::IsStruct $type]} {
        set result {}
        foreach {name t} [lindex $type 1] {
            lappend result {*}[ResourcesOf $t $visiting]
        }
        return [lsort -unique $result]
    }
    if {[hir::types::IsList $type] || [hir::types::IsMutVec $type] || [hir::types::IsMutArray $type]} {
        return [ResourcesOf [lindex $type 1] $visiting]
    }
    return {}
}

# 1 if the drop of a value of TYPE runs a cleanup.
proc hir::resources::HasCleanup {type} {
    return [expr {[ResourcesOf $type] ne {}}]
}

# The cleanup blocks the drop of a value of TYPE calls in HIR (those that
# exist: a resource without a cleanup is diagnosed at its constructions).
proc hir::resources::CleanupBlocks {hir type} {
    set result {}
    foreach id [ResourcesOf $type] {
        set record [Cleanup $hir $id]
        if {$record ne ""} {
            lappend result [dict get $record block]
        }
    }
    return $result
}

# The namespace of binding B's declaring scope: a module's, "" for the entry
# program's top level, or -1 for a binding of no top-level scope.
proc hir::resources::NamespaceOf {hir b} {
    set scope [dict get $hir bindings $b scope]
    if {$scope eq [dict get $hir top]} {
        return ""
    }
    dict for {ns s} [dict getdef $hir modules {}] {
        if {$s eq $scope} {
            return $ns
        }
    }
    return -1
}

# The binding a block literal E is the value of (its `fn` declaration's
# binding), or "".
proc hir::resources::BindingOf {hir parent e} {
    if {![dict exists $parent $e]} {
        return ""
    }
    set p [lindex [dict get $parent $e] 0]
    if {$p eq "" || [dict get $hir exprs $p kind] ne "bind" || [dict get $hir exprs $p value] ne $e} {
        return ""
    }
    return [dict get $hir exprs $p binding]
}

# Builds HIR's cleanup table from its `cleanup fn` declarations and checks
# them (RESOURCE-DECLARATION), and every construction of a resource struct
# that has no cleanup. After type inference (a declared parameter type is
# resolved), before the context analysis, which reads the table
# (hir/contexts.tcl), and the ownership analysis, which places the cleanups
# (hir/affine.tcl).
proc hir::resources::verify {hirVar} {
    upvar 1 $hirVar hir
    dict unset hir resources
    set declared 0
    dict for {id entry} $::hir::structs::registry {
        if {[dict getdef $entry resource 0]} {
            set declared 1
            break
        }
    }
    set candidates {}
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] eq "block" && [dict exists $node cleanup]} {
            lappend candidates $e
        }
    }
    if {!$declared && $candidates eq {}} {
        return
    }
    dict set hir resources declared $declared
    set parent [lindex [hir::contexts::Walk $hir] 1]
    set found [dict create]
    foreach e [lsort -dictionary $candidates] {
        set node [dict get $hir exprs $e]
        set b [BindingOf $hir $parent $e]
        set what "a cleanup function"
        if {$b eq "" || [NamespaceOf $hir $b] eq "-1"} {
            hir::Diagnose hir RESOURCE-DECLARATION \
                "a cleanup function is a top-level function of its resource's module: \"cleanup fn\" cannot declare a nested function or a function value" $e
            continue
        }
        set name [hir::semantic::SourceName $hir $b]
        set params [dict get $node params]
        set types [dict get $node declaredParamTypes]
        set flags [dict getdef $node flags {}]
        set ordinary [expr {[llength $params] - [llength $flags]}]
        # The resource this cleanup is for: its first parameter's declared
        # type. Once that is a resource of this module, the cleanup is the
        # resource's from here on, whatever else is wrong with it (its
        # constructions are then not "without a cleanup").
        set type [hir::types::Unrefined [lindex $types 0]]
        set id ""
        if {[lindex $types 0] ne {} && [hir::types::IsNamedStruct $type] && [hir::structs::isResource [lindex $type 1]]
                && [hir::structs::owner [lindex $type 1]] eq [NamespaceOf $hir $b]} {
            set id [lindex $type 1]
            if {[dict exists $found $id]} {
                set other [dict get $found $id binding]
                hir::Diagnose hir RESOURCE-DECLARATION \
                    "resource [hir::types::show $type] has two cleanup functions, [hir::semantic::SourceName $hir $other] and $name: a resource's obligation is discharged by exactly one" $e
                continue
            }
            dict set found $id [dict create block $e binding $b]
        }
        if {$ordinary != 1 || [lindex $types 0] eq {}} {
            hir::Diagnose hir RESOURCE-DECLARATION \
                "cleanup function $name must have exactly one ordinary parameter, declared with its resource struct type (\"cleanup fn ${name}(r: R, context ...):\"): the cleanup receives the one value whose obligation it discharges" $e
            continue
        }
        if {![hir::types::IsNamedStruct $type] || ![hir::structs::isResource [lindex $type 1]]} {
            hir::Diagnose hir RESOURCE-DECLARATION \
                "cleanup function $name's parameter must have a resource struct type (an \"opaque resource struct\"), not [hir::types::show $type]" $e
            continue
        }
        if {$id eq ""} {
            hir::Diagnose hir RESOURCE-DECLARATION \
                "cleanup function $name is not declared in the module of its resource [hir::types::show $type]: only the module that owns a resource's representation may discharge its obligation" $e
            continue
        }
        if {$flags ne {} || [dict exists $node variadic] || [dict getdef $node places {}] ne {}} {
            hir::Diagnose hir RESOURCE-DECLARATION \
                "cleanup function $name takes no flags, variadic or place parameter: the compiler calls it with the one value it releases" $e
            continue
        }
        if {[dict get $node declaredErrors] ne {}} {
            hir::Diagnose hir RESOURCE-DECLARATION \
                "cleanup function $name cannot declare errors: a cleanup runs where an owner's scope ends -- on every exit, the error edges included -- and nothing there could handle its failure (handle every error inside it, and record what must be reported where the program will read it)" $e
            continue
        }
        set result [dict get $node declaredResult]
        if {$result ne {} && $result ne "unit"} {
            hir::Diagnose hir RESOURCE-DECLARATION \
                "cleanup function $name must return unit (or declare no result): nothing receives a cleanup's value" $e
            continue
        }
        # Where it is declared in its module does not matter: no resource
        # exists before every module's declarations are bound. A module's
        # initializers are context-free, which no struct construction is
        # (hir/modulebinding.tcl: MODULE-CONTEXT), so no initializer makes
        # one, and the entry program, whose statements run after every
        # module's, declares no resource (RESOURCE-DECLARATION).
    }
    set index 0
    foreach id [lsort [dict keys $found]] {
        dict set found $id index $index
        incr index
    }
    dict set hir resources cleanups $found
    # A construction of a resource without a cleanup: its obligation could
    # never be discharged by a scope's end.
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "struct" || ![dict get $node reachable]} continue
        set type [hir::typeOf $hir $e]
        if {![hir::types::IsNamedStruct $type]} continue
        set id [lindex $type 1]
        if {![hir::structs::isResource $id] || [dict exists $found $id]} continue
        hir::Diagnose hir RESOURCE-DECLARATION \
            "resource [hir::types::show $type] has no cleanup function: declare \"cleanup fn NAME(r: [hir::structs::display $id]):\" in its module, the one function that discharges a value's obligation when its owner's scope ends" $e
    }
}

# The checks of a cleanup function that need the yield and context analyses
# (after hir::coroutines::verify and hir::contexts::verify): it never
# suspends, and it requires no context trait.
proc hir::resources::verifyLate {hirVar} {
    upvar 1 $hirVar hir
    dict for {id record} [table $hir] {
        set e [dict get $record block]
        set name [hir::semantic::SourceName $hir [dict get $record binding]]
        if {[dict exists $hir coroutines blocks $e]} {
            hir::Diagnose hir RESOURCE-DECLARATION \
                "cleanup function $name may yield: a cleanup runs where an owner's scope ends, inside whatever code is running there, and can suspend nothing (it would suspend the code that released the resource)" $e
        }
        foreach c [dict getdef $hir exprs $e requiredContexts {}] {
            if {[hir::contexts::isTrait $c]} {
                hir::Diagnose hir RESOURCE-DECLARATION \
                    "cleanup function $name requires the context trait $c: a cleanup's context requirement is a fact of its resource type, charged to every function that may release one, so it names context structs only (an installed implementation is selected per call, and the compiler's release is no call of yours)" $e
                break
            }
        }
    }
}
