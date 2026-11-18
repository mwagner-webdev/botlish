# audit/rn-offline-domain

Material of RN-OFFLINE-DOMAIN-ARCHITECTURE-CENSUS-MILESTONE-1.md (the
census of an offline-first Botlish domain service behind a React Native
Android application). Evidence, not product code: nothing here is loaded by
the compiler, the runtime, the standard library or a package, and no test or
workflow runs it. Section 20 of the report has every probe's commands and
results.

* `probes/reconcile.bot` -- probe B: the three-way reconciliation of one
  pet's editable fields as a pure executable model (ten scenarios: disjoint
  merge, same-field conflict, equal edits, a reverted edit, repeated edits,
  remote deletion with and without a local edit, double and mixed
  conflicts, the three resolutions). `probes/run.sh probes/reconcile.bot`
  runs it on interp, compile, cranelift and cranelift-generic under
  `-warnings error` and requires one value.
* `probes/outbox/` -- probe A: the durable mutation model on the external
  sqlite package (github.com/mwagner-webdev/sqlite-botpkg 0.1.0): an edit
  and its outbox intention in one IMMEDIATE transaction, a process aborted
  between the writes and the commit, compaction of repeated edits, an edit
  while a send is in flight, confirmation and cold-start recovery. One step
  per process; `inspect.py` reads the database with Python's own sqlite3
  after every step; `run.sh SQLITE.botpkg` compares the transcript with
  `expected.txt` (the package's `scripts/pack.sh` makes the .botpkg).
* `probes/service/` -- probe E: a persistent Botlish service on a host-owned
  thread, driven asynchronously by other host threads, with existing
  mechanisms only: an application library (`svc_main`, NAME_main of
  RN-HOST-STARTABLE-APPLICATION-LIBRARY-MILESTONE-1.md) running its own
  event loop over event_loop_linux, three exports run in instances on the
  host's other threads, and an in-library C port (`native/probe_bridge.c`)
  whose submissions post records into the service's loop
  (`botlish_event_post2`) and whose completions a host thread blocks for.
  `run.sh` builds everything in a temporary directory and runs `host.c`
  plainly and under `BOTLISH_NATIVE_GC_STRESS=1`.
