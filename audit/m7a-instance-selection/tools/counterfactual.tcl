#!/usr/bin/env tclsh9.0
# counterfactual.tcl -- M7.a *what-if* measurements for candidate M7.b
# instance-selection/theorem changes (M7A-INSTANCE-SELECTION-THEOREM-
# AUDIT.md, "Code-explosion analysis" and the family 1b questions 33-34).
#
# THIS IS NOT A PRODUCTION CHANGE. It redefines one hir::specialize proc
# *inside this audit process only*, by a checked textual substitution of
# the production proc body (so the counterfactual stays exactly the
# production code except for the one line under test, and fails loudly if
# that line ever changes). Nothing under hir/, native/ or core/ is edited;
# a normal compiler process never sources this file.
#
#   tclsh9.0 audit/m7a-instance-selection/tools/counterfactual.tcl VARIANT PROGRAM OUTDIR
#
# VARIANT:
#   baseline               no substitution (control: must equal corpus.tcl)
#   closure-kind-identity  exact calls of value-capturing closures keep the
#                          ordinary argument-kind key (the rule static
#                          blocks and Int-capturing closures already get),
#                          instead of being forced to the generic key
#   declared-aggregate-seed a declared List[T]/ImmutableSet[T] parameter's
#                          declared type is also applied to an instance
#                          whose key is itself an aggregate of the same
#                          constructor (M1's rule, extended to aggregates)
#
# Writes the same OUTDIR files as tools/corpus.tcl (m7a::census), including
# the natively-run program value, so a variant's result can be compared
# with the baseline's for behavioral equality.

source [file join [file dirname [file normalize [info script]]] lib.tcl]

lassign $argv variant path outdir

proc Substitute {procName old new} {
    set body [info body $procName]
    if {[string first $old $body] < 0} {
        error "counterfactual: expected text not found in $procName (production changed?): $old"
    }
    set args {}
    foreach a [info args $procName] {
        if {[info default $procName $a d]} { lappend args [list $a $d] } else { lappend args $a }
    }
    proc $procName $args [string map [list $old $new] $body]
}

switch -- $variant {
    baseline {}
    closure-kind-identity {
        Substitute hir::specialize::Handle \
            {![dict get $state callFactsOpt] || !$scalarCaptures} \
            {![dict get $state callFactsOpt]}
    }
    declared-aggregate-seed {
        Substitute hir::specialize::Analyze \
            {$declaredType ne {} && ![hir::types::IsSpecific $type]} \
            {$declaredType ne {} && (![hir::types::IsSpecific $type] || [::CfAggregateSeed $type $declaredType])}
        # Only when the key is an aggregate of the declared constructor and
        # not the (admissibility-rejected) List[never]: then the declared
        # type replaces the key's own element evidence (the M1 branch's
        # "IsSpecific declared -> adopt declared" arm).
        proc ::CfAggregateSeed {key declared} {
            if {[hir::types::IsList $key] && [hir::types::IsList $declared]} {
                return [expr {[lindex $key 1] ne "never"}]
            }
            return [expr {([hir::types::IsSet $key] || $key eq "immutableSet") && [hir::types::IsSet $declared]}]
        }
    }
    default { error "unknown variant $variant" }
}

puts "variant: $variant"
puts [m7a::census $path $outdir]
