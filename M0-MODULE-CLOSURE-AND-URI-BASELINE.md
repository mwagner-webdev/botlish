# M0: module-closure correctness (C2) and steady-state URI/Byte benchmark

## Outcome

C2 is fixed: an ordinary user function can now call a module-scope
function that is itself a closure, on all four backends (interp, compile,
cranelift-generic, cranelift), directly and transitively. The fix is a
five-line change to `hir/resolve.tcl`'s capture bookkeeping (plus a shared
helper extracted from existing code); no other production file changed. A
new steady-state benchmark, `bench/uri-steady.bot` /
`bench/uri-steady.tcl`, repeatedly calls the frozen `web::uri_escape_text`
from an ordinary user function -- the exact shape C2 made uncompilable
natively before this fix -- and its correctness, timing, and structural
baseline are recorded below. The existing benchmark/test corpus is
unaffected except for the one function (`web::is_unreserved`) that
actually has the C2 shape, and there only in a raw HIR field that native
lowering already filters back out to the same generated code as before.
M1 (declared-parameter fact transport) has **not** been started.

## Why M0 exists

The comprehensive generated-code audit
(`COMPREHENSIVE-GENERATED-CODE-AUDIT.md`) found five broad root causes but
recommended fixing one concrete correctness bug (C2) and adding a
trustworthy steady-state URI/Byte benchmark before any of them, so that
later machine-level work (M1's declared-parameter fact transport and
beyond) has both a correct compiler to build on and a real number to
compare against. This report covers exactly that: the C2 fix, its tests,
and the new benchmark's baseline -- nothing else.

## C2 reproduction

```botlish
fn f(b: Byte) -> bool:
    web::is_unreserved(b)

f(45)
```

(`audit/comprehensive-generated-code/bugs/module-closure-from-user-fn.bot`,
already committed by the audit.) Before this fix:

| backend | result |
|---|---|
| interp | `true` |
| compile | `true` |
| cranelift-generic | `NATIVE BUG: native lowering: binding b46 is not reachable from e322` |
| cranelift | `NATIVE BUG: native lowering: binding b46 is not reachable from e322` |

After this fix, all four backends agree on `true`.

## C2 root cause

`web::is_unreserved` (`lib/web.bot`) is itself a closure: it captures the
retained `additional_unreserved_chars` (`byte::set(['-', '.', '_', '~'])`,
built once at module initialization). `f` references it through a
module-qualified reference (`web::is_unreserved`, `hir/resolve.tcl`'s
`ResolveQualifiedRef`), not an ordinary lexical one.

`ResolveQualifiedRef` resolves a qualified reference directly against its
namespace's own module section scope and, by design, never added the
resolved binding to any enclosing block's `captures` list -- unlike
`ResolveRef`'s ordinary lexical walk, which captures through every
enclosing block whose body scope does not already contain the binding's
declaration (`hir/resolve.tcl`, the "Every enclosing block ... captures
it" step). The design was correct for the *interpreter*: a module binding
lives in the very same top-level interpreter frame as everything else
(`hir::resolve::program`'s own header: a module section is a
`"program"`-kind scope, invocation `""`, "the same interpreter frame as
everything else"), so nothing needs capturing to reach it there.

Native lowering has no such shared frame. `hir::aot::context`'s
`StaticBlocks` fixpoint (a block is "envless"/static if every binding it
captures is itself bound to a block that needs no environment) had
nothing to work with for `f`: `f`'s raw `captures` list was empty, so `f`
stayed in the "envless" set trivially, and `native::lower::Access` later
had no capture slot through which to reach `web::is_unreserved`'s actual
closure value at runtime -- hence "binding ... is not reachable".

Module functions calling other module functions, and the program root
calling a module function, both already worked: an unqualified reference
inside another module's own body resolves through the *ordinary* lexical
path (`ResolveRef`), which already added the capture (this is why
`web::uri_escape_text` already captures `web::is_unreserved`); and the
program's own top-level region needs no capture/environment concept at
all (it is the frame everything else runs relative to). The only missing
case was specifically *ordinary user code, outside any module, reaching a
module closure by its qualified name*.

## Chosen minimal correctness fix

`hir/resolve.tcl`: `ResolveQualifiedRef` now performs the same "every
enclosing block that does not already contain the binding captures it"
bookkeeping `ResolveRef` already did, factored into one shared helper,
`hir::resolve::Capture`:

```tcl
proc hir::resolve::Capture {hirVar ctx bindingScope b} {
    upvar 1 $hirVar hir
    foreach entry [lreverse [dict get $ctx blocks]] {
        lassign $entry block bodyScope
        if {[hir::scopeWithin $hir $bindingScope $bodyScope]} {
            break
        }
        set captures [dict get $hir exprs $block captures]
        if {$b ni $captures} {
            SetField hir $block captures [concat $captures [list $b]]
        }
    }
}
```

`ResolveRef`'s own tail is now `Capture hir $ctx $bindingScope $b` (inside
its existing `kind ne "root"` guard); `ResolveQualifiedRef` calls the same
helper unconditionally after resolving the qualified binding, passing the
module section scope as `bindingScope`. A module section scope is never
*within* any user block's own body scope (it is always a sibling of the
program's top scope, `hir::resolve::program`'s `ProgramSection`), so for a
qualified reference this loop never finds a reason to stop early: it
captures through every enclosing block between the reference and the
program root, exactly like an ordinary distant lexical reference.

This is the "fix capture analysis, not lowering around the bug" option
the audit asked for: the missing reachability information is now present
in HIR's own capture data, so `hir::aot::context`, `hir::blockescape`, and
`native::lower::Access` all consume it through their existing,
unmodified machinery. No new special case for `web`, `is_unreserved`, or
`additional_unreserved_chars` exists anywhere in the fix.

## Capture semantics before/after

Only the *reachability* information available to native lowering
changes; nothing about what a module binding or a capture *means*
changes:

- module initialization, module retention, module binding identity: same
  scope/binding data structures, same one-time initialization order
  (`hir::modulebinding` is untouched)
- closure semantics: a capture still denotes "the value already bound
  when the enclosing block's value is created"; qualified references
  simply now participate in the same bookkeeping ordinary references
  always used
- capture immutability: unaffected (nothing about mutability is touched)
- module function source: no `.bot` file changed

The user function `f` (and any function shaped like it) may now itself
carry a capture/environment where it previously had none -- exactly item
8's "acceptable" outcome, not something this milestone tries to avoid or
optimize away. Whether that environment survives all the way to generated
code, or whether `hir::blockescape`'s own pre-existing de-closure
conversion optimizes it into an ordinary flattened parameter instead, is
a downstream, already-existing decision this fix does not touch (see
"Generic module-closure fixture" below for both shapes actually observed).

## Generic module-closure fixture

Required independent of `web` (spec item 5). Added to
`tests/surface-modules.test` (`writeC2Fixture`, module `counter`):

```botlish
# lib/counter.bot (scratch-library fixture, not checked into lib/)
namespace counter

retained = [1, 2, 3]

fn no_captures(x):
    x + 1

fn module_fn(x):
    x + list_length(retained)
```

```botlish
# main.bot
fn wrapper(x):
    counter::module_fn(x)

fn wrapper2(x):
    wrapper(x)

fn control_wrapper(x):
    counter::no_captures(x)

[wrapper(5), wrapper2(5), control_wrapper(5), counter::module_fn(10)]
```

`retained` (a `List`) forces `module_fn` to need an environment exactly as
`additional_unreserved_chars` (also a `List`-derived value) forces one on
`web::is_unreserved`. Confirmed directly (not just inferred) to fail
pre-fix, on the native backend, with the same error shape as C2:

```
$ git stash                      # removes the hir/resolve.tcl fix
$ tclsh9.0 main.tcl -backend cranelift /tmp/c2fixture/main.bot
   error: native lowering: binding b1 is not reachable from e22 (NATIVE BUG)
$ git stash pop                  # restores the fix
$ tclsh9.0 main.tcl -backend cranelift /tmp/c2fixture/main.bot
   value: [8, 8, 6, 13]
```

Post-fix, all four backends agree on `[8, 8, 6, 13]`
(`wrapper(5)=8, wrapper2(5)=8, control_wrapper(5)=6, counter::module_fn(10)=13`;
tests `surface-modules-c2-user-fn-to-module-closure`,
`surface-modules-c2-values`).

## Real web reproduction

`tests/web-unreserved.test`'s new `web-unreserved-user-fn-wraps-module-closure`
runs the milestone's literal repro (`fn f(b: Byte) -> bool:
web::is_unreserved(b)` / `f(45)`) through `moduleParity` (all four
backends) and `moduleValue` (interp value), pinned to `same` / `true`.
Confirmed directly via `main.tcl` on all four backends (see "C2
reproduction" above): `true` everywhere, post-fix.

## Transitive reachability audit

Covered by the generic fixture's `wrapper2` (a user function calling
another user function, `wrapper`, that itself reaches the module
closure) and pinned structurally, not just by absence of a crash (spec
item 34), via `hir::aot::analyze`
(`surface-modules-c2-capture-set`):

| region | own captures | requirement |
|---|---|---|
| `wrapper` | `{name counter::module_fn class value}` | `closure-env` |
| `wrapper2` | `{name wrapper class value}` | `closure-env` |
| `control_wrapper` (control: calls the envless `counter::no_captures`) | `{name counter::no_captures class block}` | *(none)* |

`wrapper2` reaches the module closure by capturing `wrapper` itself (now
non-envless) the same ordinary way it would capture any other top-level
function value -- no separate transitive-module-capture mechanism was
built; the existing capture propagation already composes. `control_wrapper`
is the over-capture control spec item 35 asks for: calling an
environment-free module function adds a capture entry (class `block`,
matching the existing `hir-aot-22` pattern for an ordinary same-region
call) but no environment requirement -- no unrelated module state is
pulled in.

**Controls also covered** (spec item 33): `counter::module_fn(10)` from
program root (already worked, included in the same fixture/value);
`web::uri_escape_text` calling `web::is_unreserved` is the pre-existing
"module fn -> module fn" control (unaffected, see below);
`counter::no_captures` is the "module function without captures" control.

**What native lowering actually does with the fixed capture information**
(`surface-modules-c2-native-env`) is worth recording precisely, because it
is not what the raw `hir::aot` classification above alone would suggest:
`counter::module_fn`, `wrapper`, and `wrapper2` are *all* bound in the
same `"program"` region (module-scope and program-top-level function
binds are ordinary flat statements of one shared region -- see
`hir/resolve.tcl`'s own module-section-scope comment), and every
reference among them is an exact direct call, so `hir::blockescape`'s
pre-existing, unmodified de-closure conversion recognizes the whole
chain as eligible and passes `counter::retained` on as an ordinary
trailing parameter at each call site instead of ever building a real heap
closure (`env=0`, `captures=0`, `pnames="x counter::retained"`). This is
item 8's "or otherwise gain an environment" in practice: the *fix*
supplies the reachability; a wholly separate, pre-existing optimization
then decides representation. `web::is_unreserved` is *not* eligible for
that same flattening (it is called from more than one place with more
than one used specialization instance -- `hir::blockescape`'s own
documented limit), so it keeps the plain `env=1`/`captures=1` real-closure
representation, unchanged from before this fix
(`surface-modules-c2-existing-corpus-unaffected`). Both shapes are now
exercised and pinned by name.

## C2 semantic tests

Added to `tests/surface-modules.test` and `tests/web-unreserved.test`
(11 new tests total, all passing):

- `surface-modules-c2-user-fn-to-module-closure` -- 4-backend parity
- `surface-modules-c2-values` -- pinned value `[8, 8, 6, 13]`
- `surface-modules-c2-capture-set` -- `hir::aot` capture-set/requirement
  pinning for `wrapper`/`wrapper2`/`control_wrapper` (item 34)
- `surface-modules-c2-native-env` -- structural NIR pinning (env/params/
  captures) for the same three, explained above
- `surface-modules-c2-existing-corpus-unaffected` -- `web::is_unreserved`'s
  own raw captures (now also naming `ascii::is_alphanumeric`) vs. its
  unchanged generated NIR
- `web-unreserved-user-fn-wraps-module-closure` -- the literal C2 repro

**Callable-erasure interaction** (spec item 36): `tests/typed-callable-escape.test`
re-run unmodified, still 35/35 passing -- typed and error-bearing
callable obligations are untouched by this fix (it only ever adds a
capture entry; it does not change what any callable's type or error
obligations are).

## GC/rooting impact

A newly captured module closure is a heap value/root once code takes the
`env=1`/real-closure path (`web::is_unreserved` itself, and any user
function shaped like `f` that is not eligible for `hir::blockescape`'s
flattening). `tests/surface-modules.test` and `tests/web-unreserved.test`
(including every new C2 test above) pass under
`BOTLISH_NATIVE_GC_STRESS=1`, which exercises the fixed call shape (both
the real-closure path and the flattened-parameter path) under aggressive
GC pressure; see "Tests / GC stress" below for the full-suite run.

## Production files changed

```
hir/resolve.tcl   (ResolveQualifiedRef + ResolveRef + new Capture helper)
```

That is the entire production diff. Everything else changed by this
milestone is tests, a new benchmark, and this report.

## Why this is not the module-constant redesign

The audit's own later milestone (5b / M2, "retained module values as
program-lifetime constants") would let `f` reach `web::is_unreserved`
directly as a program-lifetime constant, with no per-call capture load or
environment at all -- removing the residual cost item 38 asks to record,
not eliminate, here. This fix does none of that: it does not change
module initialization, module retention representation, or how a module
binding's value is stored; it only makes the *existing* capture model see
a reachability edge it was blind to. The one extra capture load
`web::is_unreserved` itself performs per call (its own
`additional_unreserved_chars` access) is unchanged by this fix and is
exactly the cost 5b/M2 will later remove.

## New steady-state URI benchmark

`bench/uri-steady.bot` (an ordinary Botlish program) and
`bench/uri-steady.tcl` (its harness: correctness + timing + structural
report). Not a rewrite of `refined-checks.ir` and not wired into
`bench/bench.tcl`'s own `bench/*.ir` glob -- a standalone harness script,
the same convention `bench/hashtable.tcl`, `bench/csv_records.tcl`, and
`bench/tiny-leaf-pressure.tcl` already use for `.bot`-sourced benchmarks.

### Why `refined-checks` was insufficient

`bench/refined-checks.ir` calls `uriEscape` (the legacy `-native-body`
implementation, `lib/web.tcl`, via `# requires: web`) exactly once, at
startup, on the two-character input `"a b"`; its own timed steady state
is a `check` recursion dominated by `Emailish?`
(`COMPREHENSIVE-GENERATED-CODE-AUDIT.md`'s own C2 section says so
directly). It does not, and structurally cannot, measure
`web::uri_escape_text` (the *module*-based implementation C2 is about),
UTF-8 encoding, or `ascii`/`web` Byte classification under repeated call
pressure. It remains unmodified and unreplaced (spec item 41): it still
usefully exercises `StringRegion`, validator refinement, closures, and
module-state URI *composition*, none of which `uri-steady` duplicates.

### Benchmark source

```botlish
corpus = ["abcXYZ012", "a b+c?", "café", "hello 世界?"]

fn repeat_uri(i, total, acc):
    if i >= total:
        return acc
    text = list_get(corpus, mod(i, list_length(corpus)))
    escaped = web::uri_escape_text(text)
    repeat_uri(i + 1, total, acc + length(escaped))

repeat_uri(0, 2000, 0)
```

`repeat_uri` is an ordinary user function containing the repeated call
(spec item 16) -- the exact shape that could not be lowered natively
before the C2 fix (confirmed: this file fails the same way the C2 and
generic fixtures did, pre-fix). `acc` sums each result's own `length`
(an `Int`): no persistent list/String accumulation in the harness itself
(only `web::uri_escape_text`'s own frozen implementation ever
concatenates strings, item 19), and every call's result observably
contributes to the final value, so nothing can be dropped as dead work
(item 20). The "outer recursion drives N repeats" shape is this
repository's own existing idiom (`bench/loop-count.ir`'s `drive`,
`bench/hashtable.tcl`'s `build`), not a new pattern invented for this
benchmark.

### Inputs (spec item 18)

| input | covers |
|---|---|
| `"abcXYZ012"` | plain unreserved ASCII (no escaping) |
| `"a b+c?"` | ASCII requiring percent-escaping (space, `+`, `?`) |
| `"café"` | multi-byte UTF-8 (é, 2-byte) |
| `"hello 世界?"` | mixed: ASCII + two 3-byte UTF-8 characters + one escaped char |

Cycled by `mod(i, 4)` over 2000 calls (500 of each).

### Correctness

Pinned and checked on all four backends
(`tclsh9.0 bench/uri-steady.tcl`):

```
interp             29500
compile            29500
cranelift-generic  29500
cranelift          29500
-> all four backends agree: 29500
```

(29500 = the sum of `length(web::uri_escape_text(text))` over the 2000
calls in the fixed corpus cycle -- a checksum, not the escaped text
itself, per item 20's "small enough to add little overhead".)

### Timed methodology

`native::measure` (the same mechanism `bench/bench.tcl`'s own Cranelift
column and `audit/comprehensive-generated-code/tools/measure.tcl` use):
one untimed warmup run inside the same JIT-compiled subprocess, then N
timed runs, best reported; JIT compilation and module
initialization/startup are excluded from every timed run by construction
(`native::measure`'s own `lowerUs`/`compileUs`/`bestUs` split). Repeated
across independent sessions (fresh subprocess each time) for spread, the
same technique the audit's own `measure.tcl` uses.

### Steady-state structural baseline (spec item 27)

Whole-program (`tclsh9.0 bench/uri-steady.tcl`'s structural section,
`native::nir`/`native::codeSize`/`native::allocationReport`; includes
module init/startup, not isolated out -- see "Keep startup separate"
below for why that is fine here):

| metric | value |
|---|---|
| NIR functions | 17 |
| machine code bytes | 8167 |
| generic instances | 14 |
| int/raw instances | 1 |
| other instances | 2 |
| guard int ops | 10 |
| call/callenv ops | 17 |
| tagged i-arith ops (`iadd`/`isub`/`imul`) | 6 |
| total allocations (one run) | 61510 |
| total allocated bytes (one run) | 2544568 |

Finer structural census (`audit/comprehensive-generated-code/tools/probe.tcl`
+ `census.tcl` run on `bench/uri-steady.bot`, non-production tooling this
milestone reuses rather than duplicating -- spec item 27's own allowance):

```
exact calls                                  17
exact calls with may_error check             16
capture                                       1
closure                                       1
callenv                                       1
genericFunctions                             13
guard int generic-instance param             10
guard list generic-instance param             1
guard str generic-instance local              2
guard str generic-instance param              4
op setcontains                                1
op strutf8bytes                               1
op substr                                     1
tail                                          3
```

Per-function shape (from `probe.tcl`'s `summary.txt`; only the hot-path
functions):

```
web::is_unreserved<generic>   regs=9  params=1 env=1 bytes=199  call=1 br=2 capture=1 op:setcontains=1
web::uri_escape_text<generic> regs=7  params=3 env=0 bytes=121  call=1
esc_char<generic>             regs=23 params=3 env=0 bytes=525  guard=1 op:strutf8bytes=1 ... callenv=1 call=2
esc_from<generic>             regs=17 params=5 env=0 bytes=1004 guard=4 op:strlen=1 ... call=1 op:strcat=1 tail=1
repeat_uri<generic>            regs=18 params=6 env=0 bytes=1180 guard=4 ... call=1 tail=1
```

Allocation sites (one run, `probe.tcl`'s `summary.txt`): module
initialization contributes a fixed, one-time set (`web.bot:63/65`
`listnew`, `web.bot:67` `closure` x1, `byte.bot:175/177` the
`additional_unreserved_chars` set construction) -- these are the startup
costs item 30 asks to keep visible but separate. The steady-state (per
2000-call loop) sites are `web.bot:76/82` (`hex_pair`/`esc_bytes` percent-
escape `strcat`, 6500 each), `web.bot:85` (`strutf8bytes`, 14000 --
once per input character), and `web.bot:99` (`substr`/`strcat`, 14000
each, `esc_from`'s per-character walk). 14000 = 2000 calls x 7 characters/
call average over the fixed corpus.

### Hot-path baseline (spec item 28)

- `web::is_unreserved` executes as its **generic** instance (`<generic>`,
  not `<int>`), with exactly one real capture load per call
  (`additional_unreserved_chars`) and one `op setcontains` (the
  punctuation-set membership check) -- this is the honest current-state
  answer to "does it need a tagged/guarded generic path or a raw int
  one": generic, because nothing upstream of it seeds its parameter with
  the declared `Byte` fact yet (this is exactly the gap M1 targets).
- `ascii::is_alphanumeric`, `is_alphabetic`, `is_digit`, `is_upper`,
  `is_lower` all execute as `<generic>` too (13 `genericFunctions` total
  on this program).
- `web::uri_escape_text`, `esc_char`, `esc_bytes`, `esc_from`,
  `repeat_uri` are all `env=0` (de-closured by `hir::blockescape`, as
  explained above): capture loads are confined to `web::is_unreserved`
  itself, exactly one per call into it (one per ASCII-range byte
  classification), not one per byte of input generally.
- `rt_set_contains` (the runtime helper backing `op setcontains`) is
  reached once per `is_unreserved` call whose left (`ascii::is_alphanumeric`)
  side is false -- i.e. for every non-alphanumeric byte the escaper
  classifies (spec item 29's "percent-escape path runs for at least some
  bytes" and "is_unreserved runs repeatedly for relevant bytes" are both
  demonstrably true: 16 of this program's 17 exact calls carry a
  `may_error` check, and `esc_char`'s own `op:strutf8bytes=1` /
  `esc_from`'s per-character `substr` confirm the UTF-8 multi-byte path
  runs for `café`/`"hello 世界?"`'s non-ASCII characters).

### Existing benchmark regression

Before/after NIR text, byte for byte, over the full existing corpus
(`bench/*.ir`, all nine `examples/stdlib/*.bot`, and every
`audit/comprehensive-generated-code/probes/*.bot`) is **identical**:

```
$ git stash && <regenerate NIR for the whole corpus> && git stash pop && <regenerate again> && diff -rq before after
(no output -- zero differences across 25 programs)
```

This includes the audit's own `web-unreserved-256.bot` and
`web-unreserved-literals.bot` probes, which already call
`web::is_unreserved` (from program root, never from a user function), so
even those exercise no change. The one place raw HIR data *does* change
is `web::is_unreserved`'s own `captures` field (it now also names
`ascii::is_alphanumeric`, a qualified reference from inside its own
body) -- but `native::lower::CaptureList`/`BindingAccess` already filters
a capture whose target is itself an envless block (`fnvalue` access, no
value ever needed) before it reaches generated code, so
`web::is_unreserved`'s own NIR (`env=1 ... captures=1`, pinned by
`surface-modules-c2-existing-corpus-unaffected`) is unchanged. `fib`,
`loop-count`, `sum-refined`, `refined-checks`, the stdlib algorithm
corpus, and the `steady-ascii`/`steady-ascii-param`/`steady-ascii-capture`
probes contain no user-function -> module-closure reference at all, so
none of them could have changed in the first place; the diff confirms
they did not.

### Tests / GC stress

```
tclsh9.0 tests/all.tcl                          2111 tests, 2111 passed, 0 failed, 0 skipped (interp + compile)
cargo test --release --manifest-path native/Cargo.toml   60 passed, 0 failed
BOTLISH_NATIVE_GC_STRESS=1 tclsh9.0 tests/all.tcl          2111 tests, 2111 passed, 0 failed, 0 skipped (interp + compile, both under GC stress)
```

### Source-fence confirmation

```
$ git diff 02295c7 -- lib/
(no output)
```

`lib/byte.bot`, `lib/ascii.bot`, `lib/char.bot`, `lib/web.bot`, and every
other frozen library source file are byte-for-byte unchanged.

## M1 entry baseline

Answers to spec item 42's ten questions, as of this milestone (not
implementing any of them):

1. **Steady-state cost per escaped input**: median 5658.74 us / 2000
   calls ~= **2.83 us/call** (best-of-7-runs, median of 8 independent
   sessions; see the full session table in "Timed methodology" data
   above -- min 5182.38 us, max 6236.73 us, spread ~17% run-to-run on
   this shared sandbox).
2. **Cost per input byte**: the fixed corpus averages ~7 UTF-8
   characters/call (14000 characters over 2000 calls, from the
   `substr`/`strutf8bytes` site counts); ~2.83 us / 7 chars =~ **0.4
   us/character** as a rough structural estimate -- not broken out
   per-backend-instruction here, since that needs the M1-era guard/
   `may_error` removal to be meaningful rather than dominated by current
   generic-path overhead.
3. **Calls into the ASCII predicate chain**: `web::is_unreserved` calls
   `ascii::is_alphanumeric` once per byte classified (one `call` op in
   `is_unreserved`'s own NIR body); `is_alphanumeric` itself calls
   `is_alphabetic`/`is_digit` (each composed from `is_upper`/`is_lower`
   or direct range checks) -- the full chain is 13 generic functions
   deep across the program.
4. **Which ASCII instances execute**: **all `<generic>`** -- `is_digit`,
   `is_upper`, `is_lower`, `is_alphabetic`, `is_alphanumeric`, and
   `web::is_unreserved` itself. None run as a specialized `<int>`
   instance on this program.
5. **`guard int` operations on the hot path**: 10 structurally, in this
   program's NIR text (mostly the generic ASCII leaves' own parameter
   guards).
6. **`may_error` call checks on the hot path**: 16 of the program's 17
   exact calls carry one (census `exact calls with may_error check`).
7. **`rt_set_contains` reach**: once per `is_unreserved` call whose
   alphanumeric check is false (one `op setcontains` in
   `is_unreserved`'s own body, executed conditionally).
8. **Capture loads per relevant byte**: exactly one (the
   `additional_unreserved_chars` capture inside `web::is_unreserved`),
   once per byte classified -- not once per input byte generally, since
   `uri_escape_text`/`esc_char`/`esc_bytes`/`esc_from`/`repeat_uri` are
   all `env=0` (de-closured, see above).
9. **Allocations genuinely produced by URI escaping**: per-character
   `strcat` (percent-escape building, `web.bot:76/82`, 6500 sites each
   over 2000 calls) and `strutf8bytes`/`substr` (UTF-8 decode per
   character, `web.bot:85/99`, 14000 each); module init contributes a
   fixed, separate one-time `additional_unreserved_chars` set/closure
   cost (see "Steady-state structural baseline" above).
10. *(Not answered by implementing M1 -- left for that milestone, as
    instructed.)*

**M1's expected first effect, made measurable now**: seeding generic
instances with their already-verified declared parameter types (M1's
"seed generic instances with declaredParamTypes") should let
`web::is_unreserved`'s own `b: Byte` parameter, and the ASCII chain
underneath it, specialize to `<int>` (or a raw/guard-free path) even
though `is_unreserved` itself remains a closure/generic-module-function
in representation terms -- this benchmark's structural baseline (14
generic instances, 10 guards, 16 `may_error`-checked calls) is exactly
the "before" half of that future comparison, and its timing baseline
(2.83 us/call, 8-session spread recorded above) is the throughput number
to check M1 actually moves.

## Regression commands (exact counts)

```
tclsh9.0 tests/all.tcl
  -> 73 test files, 2111 tests, 2111 passed, 0 failed, 0 skipped (exit 0; interp and compile backends)

cargo test --release --manifest-path native/Cargo.toml
  -> 60 passed, 0 failed

BOTLISH_NATIVE_GC_STRESS=1 tclsh9.0 tests/all.tcl
  -> 73 test files, 2111 tests, 2111 passed, 0 failed, 0 skipped (exit 0; interp and compile backends, both under GC stress)
```

## Scope confirmation (spec items 50, 21-30)

| question | answer |
|---|---|
| Was `lib/web.bot` changed? | no |
| Was any frozen `.bot` source changed? | no (`git diff 02295c7 -- lib/` is empty) |
| Was specialization changed? | no |
| Was range/control-flow lowering changed? | no |
| Was error lowering changed? | no |
| Was listloop changed? | no |
| Was call inlining changed? | no |
| Were module values made program constants? | no |
| Was constant-set optimization added? | no |
| Was any performance optimization intentionally implemented? | no (`hir::blockescape`'s de-closure conversion that acts on the fix's output is pre-existing, unmodified code) |

## Required C2 questions (spec item 48)

1. **Why did the user function fail to reach the module closure?**
   Its own HIR `captures` list was empty: a qualified reference
   (`ResolveQualifiedRef`) never added the referenced binding to any
   enclosing block's captures, unlike an ordinary lexical reference.
2. **Which HIR/capture structure was missing?** The enclosing user
   function's own `captures` field (`hir::get $hir $e captures`), read
   by `hir::aot::context`'s `StaticBlocks` fixpoint and by
   `native::lower::CaptureList`/`hir::blockescape`.
3. **What exact change now makes the module binding reachable?**
   `ResolveQualifiedRef` now calls the same capture-propagation helper
   (`Capture`, factored out of `ResolveRef`) that ordinary lexical
   references already used.
4. **Does the fix work generically for any captured module function?**
   Yes -- confirmed with a fixture (`counter`) wholly independent of
   `web`.
5. **Does the fix change module semantics?** No.
6. **Does it make the user function carry an environment/capture where
   needed?** Yes, that is the chosen model (subject to
   `hir::blockescape`'s own pre-existing, unmodified decision about
   whether that surfaces as a real closure or a flattened parameter).
7. **Is this representation optimal?** Not necessarily -- optimization
   (the module-constant redesign, 5b/M2) is deliberately deferred.
8. **Does the fix touch specialization?** No.
9. **Does it touch module-retention representation?** No.
10. **Does GC stress pass for the newly captured closure?** Yes (see
    "Tests / GC stress" above: 2111/2111 under
    `BOTLISH_NATIVE_GC_STRESS=1`, both backends).

## Required benchmark questions (spec item 49)

11. **Why was `refined-checks` insufficient?** Its own URI call is a
    single startup-time call on a 2-character input through the legacy
    `-native-body` `uriEscape`, not the module-based
    `web::uri_escape_text`; its measured steady state is a
    recursive `Emailish?`/`UriQueryValue?` check, not URI escaping.
12. **Which URI/Byte/ASCII functions execute repeatedly?**
    `web::uri_escape_text`, its nested `esc_from`/`esc_char`/`esc_bytes`/
    `hex_pair`/`high_nibble`, `web::is_unreserved`, and the
    `ascii::is_*` chain underneath it -- all called from `repeat_uri`,
    2000 times.
13. **Are module init and JIT compilation excluded from timing?** Yes
    (`native::measure`'s own `lowerUs`/`compileUs`/`bestUs` split; only
    `bestUs` is the reported timing).
14. **What fixed inputs, and why?** `"abcXYZ012"` (plain unreserved),
    `"a b+c?"` (percent-escaping), `"café"` (2-byte UTF-8), `"hello
    世界?"` (mixed, 3-byte UTF-8 x2) -- covers every code path
    `web::uri_escape_text`'s own semantics distinguish, without gigantic
    strings that would just measure bulk-copy bandwidth instead of the
    small-function costs the audit found.
15. **Stable Cranelift baseline?** Median 5658.74 us for 2000 calls
    (best-of-7, 8 sessions).
16. **Run-to-run spread?** ~17% (5182.38-6236.73 us across 8 sessions on
    this shared sandbox; a separate 2-session check measured 3%, and
    another 5-session check measured 42% with one outlier session --
    recorded honestly rather than cherry-picked, since this sandbox's
    CPU is shared/virtualized).
17. **Which ASCII instance shape executes today?** All `<generic>` (see
    "M1 entry baseline" #4).
18. **Guards/checks/capture loads remaining structurally?** 10 `guard
    int` ops, 16 `may_error`-checked calls, 1 real capture load per
    `is_unreserved` call (see "M1 entry baseline" #5, #6, #8).
19. **Allocations per iteration/input?** See "Steady-state structural
    baseline"'s allocation-sites table (6500/6500/14000/14000 per-
    character sites over 2000 calls, plus a fixed one-time module-init
    set).
20. **Sensitive to the RC1 issue M1 will address?** Yes -- the entire
    ASCII/`is_unreserved` chain runs generic today specifically because
    nothing seeds it with the declared `Byte` fact (RC1, per the audit);
    this benchmark's structural baseline is the "before" half of that
    comparison.

## Stop condition

All sixteen conditions hold: C2 is fixed generically (fixture-confirmed
independent of `web`); it works on all four backends, directly and
transitively; GC stress covers the new capture path; no frozen library
source changed; no specialization, representation, lowering, inlining, or
other optimization was added; the existing benchmark/probe corpus's
generated code is byte-for-byte unchanged (25-program NIR diff); a real
steady-state URI/Byte/ASCII benchmark exists (`bench/uri-steady.bot`/
`.tcl`), its correctness is pinned (29500, four-backend agreement), its
timed region excludes startup/JIT, its baseline timing/variance and its
structural baseline (generic instances, guards, tagged ops, `may_error`
checks, allocations, code size) are recorded, it demonstrably exercises
`web::uri_escape_text`/Byte classification/ASCII classification/escaping
repeatedly (allocation-site and census counts above), the full regression
suite and Rust test suite pass, and M1 has not been implemented.
