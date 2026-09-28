# cardinality.tcl -- returning-iterable-loop (listloop) output-length facts
# (RETURNING-ITERABLE-LOOPS.md items 15-19, 51-52).
#
#   hir::cardinality::analyze $hir     -> dict: listloop ExprId -> exact|max
#   hir::cardinality::of $hir $e       -> exact|max, for one listloop E
#
# The smallest representation compatible with the milestone's own explicit
# scoping ("if the current fact framework cannot yet express relational
# collection length without a disproportionate new system, STOP AND REPORT
# that limitation before inventing one... a narrowly scoped metadata
# representation is preferable to a general theorem engine"): this is not a
# relational fact system, and it is deliberately independent of hir/range.
# tcl's own per-specialization-instance argument-fact machinery (Range,
# narrowing rounds, call-site seeding) -- a listloop's cardinality needs
# none of that. It depends on exactly one already-resolved HIR fact:
# hir/resolve.tcl's own `target` field on every break/continue node (the
# ExprId of the loop it lexically targets, resolved once, purely
# syntactically, independent of reachability analysis or types).
#
#   exact   no break/continue anywhere in the loop's own body targets it:
#           every normal completion of the loop produces a List of exactly
#           the iterable's own length (item 15's ExactLengthOf(input)).
#   max     a break or continue targeting this loop is reachable in its own
#           body (a nested loop's own break/continue targets *that* inner
#           loop instead, via the same lexical resolution hir/resolve.tcl
#           already performs, and so does not count here): output length
#           <= input length on every normal completion (items 16/17/19's
#           MaxLengthOf(input)).
#
# return/Error are nonlocal completions (item 17): a listloop execution that
# ends in one of them does not "normally produce a List" at all, so neither
# ever weakens exact into max here -- only an actually reachable break/
# continue does, which is exactly what scanning for a matching `target`
# field (independent of return/error/reachability) already captures. This
# module does no path-sensitive counting (item 20 of the milestone this
# followed, "do not attempt path-sensitive counting in this milestone"): a
# break/continue on a provably-dead path still downgrades exact to max,
# exactly like hir/aot.tcl's own "discarded" fact is similarly a syntactic,
# not path-sensitive, approximation.
namespace eval hir::cardinality {}

proc hir::cardinality::analyze {hir} {
    set result [dict create]
    dict for {id node} [dict get $hir exprs] {
        if {[dict get $node kind] eq "listloop"} {
            dict set result $id exact
        }
    }
    dict for {id node} [dict get $hir exprs] {
        if {[dict get $node kind] in {break continue}} {
            set target [dict get $node target]
            if {$target ne "" && [dict exists $result $target]} {
                dict set result $target max
            }
        }
    }
    return $result
}

proc hir::cardinality::of {hir e} {
    if {[dict get $hir exprs $e kind] ne "listloop"} {
        error "hir::cardinality::of: $e is not a listloop"
    }
    return [dict get [analyze $hir] $e]
}
