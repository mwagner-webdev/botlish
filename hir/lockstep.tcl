# lockstep.tcl -- the equal-cardinality obligation of lockstep loops
# (COLLECTING-LOOPS.md).
#
#   hir::lockstep::verify HIRVAR
#
# `loop x in xs and i from 0 to n:` advances every iteration clause once per
# body execution, so it is only meaningful when all clauses have the same
# number of elements. Botlish deliberately has no shortest-wins `zip`, no
# padding and no runtime length check: the loop is legal exactly when the
# compiler can PROVE the clauses' cardinalities equal, and is otherwise a
# compile-time error. This module is that proof's only consumer; the proof
# itself -- iteration domains, exact cardinality of each, and the symbolic
# comparison -- is hir/cardinality.tcl.
#
# Three outcomes per lockstep loop, comparing every clause against the first:
#
#   equal     the normalized cardinalities are identical (or both constant
#             and equal): accepted, nothing recorded.
#   unequal   the cardinalities differ by a nonzero constant (or are
#             different constants): LOCKSTEP-UNEQUAL, "the compiler can prove
#             they differ".
#   unknown   anything else: LOCKSTEP-UNPROVEN, "could not prove A == B".
#
# A rejected loop is also marked (`unproven` MESSAGE on its HIR node) so that
# hir::lower of a -strict 0 program, whose diagnostics stay in the HIR,
# replays the diagnostic as an unconditional run-time error instead of ever
# running an unproven lockstep loop. That is the diagnostic replayed, not a
# length check: it fires regardless of what the lengths are.

namespace eval hir::lockstep {}

proc hir::lockstep::verify {hirVar} {
    upvar 1 $hirVar hir
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "lockloop"} {
            continue
        }
        set domains [hir::cardinality::domains $hir $e]
        set steps 0
        set first [hir::cardinality::of_domain $hir [lindex $domains 0] steps]
        set index 0
        foreach domain [lrange $domains 1 end] {
            incr index
            set steps 0
            set other [hir::cardinality::of_domain $hir $domain steps]
            set verdict [hir::cardinality::compare $first $other]
            if {$verdict eq "equal"} {
                continue
            }
            set a [hir::cardinality::show $hir $first]
            set b [hir::cardinality::show $hir $other]
            if {$verdict eq "unequal"} {
                set kind LOCKSTEP-UNEQUAL
                set message "lockstep loop requires equal iteration counts; clause 1 iterates $a times but\
                    clause [expr {$index + 1}] iterates $b times"
            } else {
                set kind LOCKSTEP-UNPROVEN
                set message "lockstep loop requires equal iteration counts; could not prove $a == $b\
                    (clause 1 vs clause [expr {$index + 1}])"
            }
            hir::Diagnose hir $kind $message $e
            dict set hir exprs $e unproven "$kind: $message"
            break
        }
    }
}
