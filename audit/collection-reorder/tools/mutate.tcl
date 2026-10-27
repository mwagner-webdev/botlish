# mutate.tcl -- mutation testing of proven collection reordering
# (PROVEN-COLLECTION-REORDERING.md, "Mutation testing").
#
#   tclsh9.0 audit/collection-reorder/tools/mutate.tcl ?OPTION VALUE ...?
#
# The collections' harness (audit/mutable-map/tools/mutate.tcl: a private
# copy of the tree per mutant, the native backend rebuilt for a native
# mutant) with this directory's mutants.txt and these detectors, in order,
# until one kills the mutant:
#
#   * the mutant's own test files, then tests/collection-reorder.test,
#     tests/ordered-table.test, tests/mutable-map.test and
#     tests/mutable-set.test;
#   * the collection fuzzer (audit/mutable-map/tools/fuzz.tcl, reorders
#     included) against its model;
#   * the proof fuzzer (proofs.tcl, beside this script) against its model
#     and against the programs' runs.
#
# Every option is the harness's (-only, -jobs, -all-detectors, -timeout,
# -fuzz-count, -proof-fuzz-count, ...) and overrides the defaults below.

set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname $here]]
set root [file dirname $root]
set defaults [list -mutants [file join $here mutants.txt] \
    -tests {tests/collection-reorder.test tests/ordered-table.test tests/mutable-map.test tests/mutable-set.test} \
    -proof-fuzz-count 12]
set status [catch {exec tclsh9.0 [file join $root audit mutable-map tools mutate.tcl] {*}$defaults {*}$argv >@stdout 2>@stderr}]
exit $status
