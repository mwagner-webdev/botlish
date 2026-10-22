# recovery.tcl -- which diagnostics a rejected compilation reports
# (DIAGNOSTIC-RECOVERY.md).
#
#   hir::recovery::reported HIR    the diagnostics to report, in order
#   hir::recovery::raise HIR LOCATE   raise them as one error
#   hir::recovery::entries HIR REPORTED LOCATE   what raise raises, as data
#   hir::recovery::runnable HIR    the HIR a backend compiles: without poison
#
# A compilation reports every diagnostic that is independently true of the
# source, and none that exists only because the compiler could not establish
# what an earlier failure meant. Two mechanisms keep the second kind out; both
# decide by semantic dependency, never by comparing message text:
#
#   * Within an analysis, a value the analysis proved invalid is *poison*
#     (hir/types.tcl, "Poison"): typed so that no later check restates it,
#     without hiding the code around it.
#
#   * Across the phases: resolution failures (an unbound name, an unknown
#     type, struct or error, a misplaced break, ...) are lexical facts, each
#     reported, and the source front end goes on to check the program
#     (surface/modules.tcl's BuildProgram no longer stops after them). What
#     the checks say about code whose meaning depends on a declaration the
#     compiler could not establish is dependent: a *unit* -- one top-level
#     expression of the program or of a module section (a function
#     declaration, a statement) -- is *tainted* when a resolution diagnostic
#     is located in it, or when it refers to a binding a tainted unit
#     declares (calls a function whose body or signature did not resolve,
#     reads a value computed by one); transitively. The check diagnostics of
#     tainted units are not reported; those of every other unit are, as are
#     all resolution diagnostics.
#
#   * Within the checks, the phase that rejects an expression owns it: the
#     ownership analysis's erasure of an argument (AFFINE-ERASURE-
#     UNSUPPORTED) is not reported when an earlier check rejected that
#     argument, or the call itself (anything but an obligation a valid call
#     may still carry: hir::MethodObligationKinds) -- `p + 1` with a pointer
#     `p`, a call of a value that cannot be called: no program has that
#     position to own a value in.
#
# The order is the build's (hir::diagnostics): resolution diagnostics first,
# in source order, then each check's, in the order the checks run, each in its
# own deterministic walk -- the first is the one a strict compilation always
# reported, and names the error code. No diagnostic is ever dropped for being
# like another: two at distinct sites are two -- two uses of one missing
# import too. (Merging them would make a static compile block's diagnostic
# depend on another block's: STATIC-DECISION-ECONOMICS.md.)
#
# A build that stopped after resolution (-halt-on-resolution-errors, a strict
# core IR text build) has resolution diagnostics only: it reports them all.
#
# Poison is the checks' recovery state, never a backend's: a lenient
# (-strict 0) HIR keeps its diagnostics and its poison, and runs anyway, each
# diagnostic a run-time error where it is reached -- so every backend entry
# point compiles hir::recovery::runnable of the HIR it is given.

namespace eval hir::recovery {}

# The diagnostics of HIR a compilation that rejects it reports (above), in
# HIR's order.
proc hir::recovery::reported {hir} {
    set diagnostics [OwnedPositions $hir [dict get $hir diagnostics]]
    if {![dict exists $hir resolutionDiagnostics]} {
        return $diagnostics
    }
    set resolution [dict get $hir resolutionDiagnostics]
    set tainted [Tainted $hir $resolution]
    if {[dict exists $tainted *]} {
        return [lmap d $diagnostics {if {$d in $resolution} {set d} else {continue}}]
    }
    set unitOf [dict get $tainted unitOf]
    set result {}
    foreach d $diagnostics {
        if {$d ni $resolution} {
            set e [dict getdef $d expr ""]
            if {![dict exists $unitOf $e] || [dict exists $tainted units [dict get $unitOf $e]]} {
                continue
            }
        }
        lappend result $d
    }
    return $result
}

# DIAGNOSTICS of HIR without the erasures of arguments an earlier check
# rejected, or whose call it rejected (above).
proc hir::recovery::OwnedPositions {hir diagnostics} {
    if {[lsearch -exact [lmap d $diagnostics {dict get $d kind}] AFFINE-ERASURE-UNSUPPORTED] < 0} {
        return $diagnostics
    }
    # Argument ExprId -> its call.
    set callOf [dict create]
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] eq "call"} {
            foreach a [dict get $node args] {
                dict set callOf $a $e
            }
        }
    }
    set rejected [dict create]
    set result {}
    foreach d $diagnostics {
        set e [dict getdef $d expr ""]
        if {[dict get $d kind] eq "AFFINE-ERASURE-UNSUPPORTED" && [dict exists $callOf $e]
                && ([dict exists $rejected $e] || [dict exists $rejected [dict get $callOf $e]])} {
            continue
        }
        if {[dict get $d kind] ni [hir::MethodObligationKinds]} {
            dict set rejected $e 1
        }
        lappend result $d
    }
    return $result
}

# {unitOf EXPR->UNIT units UNIT->1}: the unit (a root ExprId) of every
# expression of HIR, and the tainted ones given the resolution diagnostics
# RESOLUTION (above); {* 1} when a resolution diagnostic belongs to no unit
# (then every unit depends on it).
proc hir::recovery::Tainted {hir resolution} {
    set unitOf [dict create]
    # BindingId -> the unit that declares it, for the bindings units share.
    set declaredIn [dict create]
    # Unit -> the bindings its expressions refer to.
    set refers [dict create]
    foreach root [dict get $hir roots] {
        set exprs {}
        hir::WalkInto $hir $root exprs
        set bindings [dict create]
        foreach e $exprs {
            dict set unitOf $e $root
            set node [dict get $hir exprs $e]
            switch -- [dict get $node kind] {
                bind {
                    dict set declaredIn [dict get $node binding] $root
                }
                ref {
                    if {[dict get $node binding] ne ""} {
                        dict set bindings [dict get $node binding] 1
                    }
                }
            }
        }
        dict set refers $root [dict keys $bindings]
    }
    set units [dict create]
    foreach d $resolution {
        set e [dict getdef $d expr ""]
        if {![dict exists $unitOf $e]} {
            return [dict create * 1]
        }
        dict set units [dict get $unitOf $e] 1
    }
    # A unit depends on the units declaring what it refers to: until no
    # tainted unit taints another (`mutual:` groups refer forward).
    set changed 1
    while {$changed} {
        set changed 0
        dict for {root bindings} $refers {
            if {[dict exists $units $root]} continue
            foreach b $bindings {
                if {[dict exists $declaredIn $b] && [dict exists $units [dict get $declaredIn $b]]} {
                    dict set units $root 1
                    set changed 1
                    break
                }
            }
        }
    }
    return [dict create unitOf $unitOf units $units]
}

# The HIR a backend compiles for HIR (hir::lower, core::compiler::compileHir,
# native::prepareHir): HIR itself, unless it has poison (hir/types.tcl). A
# poisoned expression is typed `never` for the checks, which is not a
# divergence at run time: the failed projection still runs -- and raises, or,
# an opaque field's or a handler's value, completes. So a poisoned HIR is
# checked again without poison (`unpoisoned`: typed exactly as before poison
# existed, a failed projection `any`), keeping its diagnostics -- as hir::check
# keeps them when it demotes a violated contract, and native::prepareHir when
# it drops a violated declared type. Only a lenient HIR can have poison: a
# strict compilation raises it, and a static decision never runs its builds.
proc hir::recovery::runnable {hir} {
    if {![dict exists $hir poisoned]} {
        return $hir
    }
    set diagnostics [dict get $hir diagnostics]
    dict set hir unpoisoned 1
    hir::check hir
    dict set hir diagnostics $diagnostics
    return $hir
}

# Raises the diagnostics REPORTED of HIR (reported) as one {CORE SEMANTIC KIND}
# error (core::raiseDiagnostics): KIND the first's. With LOCATE 1 each message
# starts with its "FILE:LINE:COLUMN: " (a source program's), else it is the
# message alone (core IR text, whose origins name no file).
proc hir::recovery::raise {hir reported locate} {
    core::raiseDiagnostics [entries $hir $reported $locate]
}

# The core::raiseDiagnostics entries of the diagnostics REPORTED of HIR, as
# raise raises them (LOCATE as raise's): each with its location and its
# related locations as data, beside the located text, and the HIR diagnostic
# itself as its `record`. The one statement of what a semantic diagnostic is
# outside HIR: a strict compilation raises these, and the compiler service
# reports exactly these for a lenient one (COMPILER-SERVICE-MILESTONE-1.md).
proc hir::recovery::entries {hir reported locate} {
    set entries {}
    foreach diagnostic $reported {
        set message [dict get $diagnostic message]
        set location ""
        set related {}
        if {$locate} {
            set origin [if {[dict exists $diagnostic origin]} {dict get $diagnostic origin} else {hir::get $hir [dict get $diagnostic expr] origin}]
            set message "[hir::originLocation $hir $origin]: $message"
            set location [hir::originSpan $hir $origin]
            foreach o [dict getdef $diagnostic related {}] {
                lappend related [hir::originSpan $hir $o]
            }
        }
        lappend entries [dict create errorcode [list CORE SEMANTIC [dict get $diagnostic kind]] message $message \
            summary [dict get $diagnostic message] location $location related $related record $diagnostic]
    }
    return $entries
}
