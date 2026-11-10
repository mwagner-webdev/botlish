# audit/managed-subprocess

The material of the census MANAGED-SUBPROCESS-AND-EVENT-LOOP-CENSUS-
MILESTONE-1.md (`../../docs/`): an experiment, not shipped functionality.
Nothing here is loaded by the compiler, the standard library, the tests or a
workflow.

* `helper/msp-child.c` -- the deterministic helper child: one operation per
  argument (write, flood, read stdin, close a stream, exit, raise, ignore or
  trap a signal, fork a descendant, setsid, report its ids, environment,
  working directory, arguments, signal mask, descriptors, terminal).
* `native/msp.c` -- the EXPERIMENTAL adapter: specs, posix_spawn plus the
  pidfd of the unreaped child, non-blocking pipe ends, exit peeked with
  WNOWAIT and reaped separately, signals through the pidfd (to the process
  group with PIDFD_SIGNAL_PROCESS_GROUP), generation-checked handles, a
  child per thread, detach and sweep, the subreaper probe. Scalars and
  borrowed bytes only; no thread, no signal handler, no callback.
  `native/msp-test.c` checks what the Botlish side cannot reach.
* `slice/` -- an application root: `msp.bot` (the EXPERIMENTAL module:
  contexts, an owner/identity pair per child, watches through
  event_loop_linux, interrupts, terminate, the reaper), `labkit.bot` and
  `report.bot` (scenario helpers), the scenario runners `lab-io.bot`,
  `lab-life.bot`, `lab-perf.bot`, the vertical slice `slice.bot` (with
  `board.bot`), `threads.bot` (with `procworker.bot`), `durable.bot` (the
  crash-recovery supervisor), `repro-send-child.bot` (with
  `sendchild.bot`). `build.sh` installs the driver package and builds the
  adapter and the helper (build products are ignored: `.gitignore`).
* `repro/` -- standalone reproducers: `pidfd-spawn-leak.c` (glibc),
  `group-after-reap.c` (a pidfd group signal after the leader's reap),
  `posix-spawn-ffi.bot`, `raw-fork.bot`, `cleanup-cannot-wait.bot` (with
  `cleanup_job.bot`).
* `tools/run.py` -- the harness: builds (`--build`), runs every scenario
  under a watchdog (a PTY where it needs a terminal), checks expectations
  and, from outside, the processes a run named; `tools/recovery.py` -- the
  crash-recovery experiment; `tools/mutate.py` with `tools/mutants.txt` --
  the mutation tests.
* `results/` -- the runs this census reports (`runs/`, `recovery-*.txt`,
  `mutants.txt`, `repro.txt`, `adapter-test.txt`).

Commands (Linux x86-64, Tcl 9.0.1, the native backend built):

    export LANG=C.utf8 LC_ALL=C.utf8
    python3 -I audit/managed-subprocess/tools/run.py --build
    python3 -I audit/managed-subprocess/tools/recovery.py
    python3 -I audit/managed-subprocess/tools/recovery.py --no-subreaper
    python3 -I audit/managed-subprocess/tools/mutate.py
    cc -O2 -pthread audit/managed-subprocess/native/msp-test.c \
       audit/managed-subprocess/native/msp.c -o /tmp/msp-test &&
       /tmp/msp-test audit/managed-subprocess/slice/bin/msp-child
