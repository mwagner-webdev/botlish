# Mutants of compiler-managed scratch storage

The record run of `tools/mutate.tcl` (STORAGE-COMPILER-MANAGED-SCRATCH-MILESTONE-1.md, section 19), then the reruns of the frame-cost fix (section 24): `plan-recursive-destination` became `plan-recursive-region` (a recursive unit gets no region, so the old mutant changed nothing), and `lower-request-constant-at-entry` and `roots-mark-rooted` are new. The mutants whose code or detectors the fix touched ran again.

```
# tclsh9.0 audit/storage-scratch/tools/mutate.tcl
BASELINE: every detector passes on the unmutated copy
KILLED plan-any-verdict -- by ss-plan-escapes, ss-run-dest-stale, fuzz (child process exited abnormally)
KILLED plan-result-any-reason -- by ss-run-context-escape
KILLED plan-outermost-region -- by ss-run-nested-loops-steady
KILLED plan-suspending-unit -- by ss-plan-p07b-suspension
KILLED plan-recursive-destination -- by ss-plan-recursive
KILLED lower-no-exit-reset -- by ss-nir-frame, ss-run-steady-state
KILLED lower-no-error-exit-reset -- by ss-run-error-steady
KILLED lower-no-head-reset -- by ss-nir-loop, ss-run-steady-state, ss-run-nested-loops-steady
KILLED lower-inner-reset-outer-mark -- by ss-run-inner-region
KILLED lower-dest-as-one -- by ss-run-dest-stale
KILLED rt-reset-ignored -- by ss-run-steady-state, rust (runtime::scratch::tests::a_too_small_chunk_above_the_position_is_replaced, runtime::scratch::tests::a_mark_above_the_position_is_a_protocol_error, runtime::scratch::tests::nested_regions_release_only_their_own, runtime::scratch::tests::bump_mark_reset_reuses_the_same_bytes, runtime::scratch::tests::growth_never_moves_a_live_object, runtime::scratch::vm_tests::a_root_into_released_storage_is_counted_and_never_read)
KILLED rt-bump-no-advance -- by ss-run-census, ss-run-heap-reduction, rust (runtime::scratch::tests::a_mark_above_the_position_is_a_protocol_error, runtime::scratch::tests::a_too_small_chunk_above_the_position_is_replaced, runtime::scratch::tests::bump_mark_reset_reuses_the_same_bytes, runtime::scratch::tests::growth_never_moves_a_live_object, runtime::scratch::tests::poison_overwrites_released_bytes, runtime::scratch::tests::nested_regions_release_only_their_own)
KILLED rt-exit-ignores-dest -- by ss-run-census, ss-run-nested, fuzz (child process exited abnormally)
KILLED rt-grow-replaces-live -- by rust (runtime::scratch::tests::a_too_small_chunk_above_the_position_is_replaced, runtime::scratch::tests::growth_never_moves_a_live_object)
KILLED rt-stress-no-collect -- by ss-run-stress-collects
KILLED rt-collector-reads-scratch -- by rust (runtime::scratch::vm_tests::a_root_into_released_storage_is_counted_and_never_read, runtime::scratch::vm_tests::a_request_places_exactly_the_next_string_and_the_collector_never_touches_it)
KILLED clif-request-not-cleared -- by ss-run-request-cleared
KILLED clif-dest-not-cleared -- by ss-run-dest-stale
KILLED nir-protocol-unchecked -- by ss-nir-validator, rust (nir::scratch_tests::the_protocol_is_checked_structurally)
KILLED lifetime-error-let-through -- by sl-error-let-through, fuzz (child process exited abnormally)
KILLED lifetime-fresh-holds-nothing -- by sl-fresh-holds-parameter, fuzz (child process exited abnormally)
KILLED lifetime-reasons-grow -- by sl-recursive-reasons-converge
22 mutants, 0 not killed
exit 0
```

```
# tclsh9.0 audit/storage-scratch/tools/mutate.tcl -only plan-recursive-region,plan-suspending-unit,rt-exit-ignores-dest
BASELINE: every detector passes on the unmutated copy
KILLED plan-suspending-unit -- by ss-plan-p07b-suspension
KILLED plan-recursive-region -- by ss-plan-recursive
KILLED rt-exit-ignores-dest -- by ss-run-census, ss-run-nested, fuzz (child process exited abnormally)
3 mutants, 0 not killed
exit 0
# tclsh9.0 audit/storage-scratch/tools/mutate.tcl -only lower-request-constant-at-entry,roots-mark-rooted
BASELINE: every detector passes on the unmutated copy
KILLED lower-request-constant-at-entry -- by ss-nir-frame-roots
KILLED roots-mark-rooted -- by ss-nir-frame-roots
2 mutants, 0 not killed
exit 0
```

24 mutants in the catalog, each killed by its last run.
