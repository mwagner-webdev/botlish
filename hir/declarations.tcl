# declarations.tcl -- the declaration state a HIR's build left behind, and
# its activation (COMPILATION-ISOLATION.md).
#
#   hir::declarations::capture        the registries' current state, a value
#   hir::declarations::stamp HIRVAR   records it as HIR's `declarations`
#   hir::declarations::invalidate     before a build or a read writes them
#   hir::activate HIR                 makes HIR's state the registries' state
#
# A compilation registers its declarations in process-wide registries
# (hir/sourcetypes.tcl, "Compilation isolation"): the source-defined entries
# of core::type (a domain or a refinement), hir::structs, hir::enums,
# hir::layouts, hir::errordecls, hir::traits, hir::imports and the extern c
# fn natives of core::native with their link plan (hir/foreign.tcl).
# The analyses and the backends read them by bare name, so a HIR is not
# self-contained: compiling another program used to change what an earlier
# HIR's lowering or run saw (a silently wrong value, native code that traps,
# a coroutine never released).
#
# Every HIR therefore records the state its build left behind (`declarations`,
# a HIR side table of plain values: the registry entries themselves, which
# name only fixed procedures -- a domain's validator is
# core::type::IntegerDomainValidator with its domain -- so the state also
# survives serialization), and every
# entry point that reads the registries for an existing HIR activates it
# first: hir::lower, hir::format, hir::specialize::analyze, hir::aot::analyze
# (and so native::executable and native::report, which start with them),
# core::compiler::compileHir and native::prepareHir (every native lowering). The Tcl
# compiler's code cache, keyed
# by core IR text, drops a unit compiled under another state. A new registry
# belongs in capture and Install; a new entry point reading the registries
# for a HIR it is given calls hir::activate.
#
# The state is its own identity: two HIRs of equal declarations need no switch
# between them, and comparing a HIR's state with the active one is O(1) for
# the very object installed (Tcl's `eq` on one object), so activating the HIR
# already active costs one comparison. A build or a read invalidates the
# active state before it writes the registries and stamps its HIR when done:
# a compilation that fails half way leaves the next activation to install.

namespace eval hir::declarations {
    # The declaration state the registries hold now ("" when unknown: before
    # any stamp or activation, and while a build or a read rewrites them).
    variable active ""
    # Switches made (activations that changed the registries), for audits.
    variable switches 0
}

# The current declaration state, as one dict of the registries' values.
proc hir::declarations::capture {} {
    set types {}
    foreach entry $::hir::sourcetypes::generation {
        lassign $entry kind name
        if {[dict exists $::core::type::registry $name]} {
            lappend types $name [dict get $::core::type::registry $name]
        }
    }
    return [dict create \
        generation $::hir::sourcetypes::generation types $types \
        structs $::hir::structs::registry enums $::hir::enums::registry \
        layouts $::hir::layouts::registry \
        errors $::hir::errordecls::current payloads $::hir::errordecls::payloads \
        traits $::hir::traits::registry impls $::hir::traits::impls \
        unitNames $::hir::traits::unitNames imports $::hir::imports::table \
        foreign [hir::foreign::capture]]
}

# Forgets which state the registries hold: called before a build or a read
# writes them. Until the next stamp, every activation installs its HIR's
# state, so a compilation that fails half way through registering its
# declarations cannot leave an earlier HIR's activation a no-op over
# registries it has already rewritten.
proc hir::declarations::invalidate {} {
    variable active
    set active ""
}

# Makes the current declaration state the active one, and returns it. Equal
# content keeps the installed object, so that the next activation compares
# one object with itself.
proc hir::declarations::current {} {
    variable active
    set state [capture]
    if {$state ne $active} {
        set active $state
    }
    return $active
}

# Records the current declaration state as HIR's own, and as the active one.
proc hir::declarations::stamp {hirVar} {
    upvar 1 $hirVar hir
    dict set hir declarations [current]
}

# Makes HIR's declaration state the registries' state. A HIR without one
# (built by code that predates it) leaves the registries as they are.
proc hir::activate {hir} {
    if {![dict exists $hir declarations]} {
        return
    }
    set state [dict get $hir declarations]
    if {$state eq $::hir::declarations::active} {
        set ::hir::declarations::active $state
        return
    }
    hir::declarations::Install $state
}

proc hir::declarations::Install {state} {
    variable active
    variable switches
    incr switches
    # Unregisters the source-defined types of the state in force (and its
    # structs) ...
    hir::sourcetypes::Reset
    # ... and installs STATE's, as they were registered (already validated:
    # no declaration is resolved again).
    dict for {name meta} [dict get $state types] {
        dict set ::core::type::registry $name $meta
    }
    set ::hir::sourcetypes::generation [dict get $state generation]
    set ::hir::structs::registry [dict get $state structs]
    hir::structs::ForgetAffinity
    set ::hir::enums::registry [dict get $state enums]
    set ::hir::layouts::registry [dict get $state layouts]
    set ::hir::errordecls::current [dict get $state errors]
    set ::hir::errordecls::payloads [dict get $state payloads]
    set ::hir::traits::registry [dict get $state traits]
    set ::hir::traits::impls [dict get $state impls]
    set ::hir::traits::unitNames [dict get $state unitNames]
    set ::hir::traits::cache [dict create]
    hir::contexts::ResetTraitCache
    set ::hir::imports::table [dict get $state imports]
    hir::foreign::Install [dict get $state foreign]
    set active $state
}
