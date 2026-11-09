# WARNINGS-DISCARDED-MUTATION-MILESTONE-1

`DISCARDED-MUTATION`: one compiler warning for a mutation whose modified
state no later computation can see, and for a fold exit that deliberately
carries the iteration's starting intermediate after the iteration mutated it.
The recommendation of CONSTRUCT-BINDING-MUTATION-CENSUS-1.md (sections 16
and 17), implemented. No language rule, runtime behavior, HIR node, backend or
existing diagnostic changed.

Throughout, *implementation fact* means something read from the compiler's
code, *observation* something a run or an emitted diagnostic showed, and
*judgment* a design decision or tradeoff this report argues for.

The material: hir/discarded.tcl (the two facts), hir/warnings.tcl (the pass
and its messages), hir/hir.tcl (the checked source it reads),
tests/discarded-mutation.test, `../audit/discarded-mutation/` (the
repository census, the test-file census, the fuzzer, the mutation catalog),
bench/discarded-mutation.tcl, and Compilerpedia's
`warning.discarded-mutation` with the construct-binding documentation the
census asked for.

## 1. Result

* **`DISCARDED-MUTATION` is an ordinary built-in warning** (hir/warnings.tcl's
  registry, ninth entry), under the one global policy: printed under
  `-warnings default`, never computed under `off`, the first one raised as
  `{CORE SEMANTIC DISCARDED-MUTATION}` under `error`. No source suppression,
  no opt-out, no fixit.
* **Two reasons, one code** (sections 4 and 5):
  - *dead* (B1): a mutating call whose every mutated place dies with its
    scope -- a local, a loop or lockstep variable, a fold intermediate, a
    handler payload, a destructured field -- unread on every path after it,
    whose own value is discarded, whose callee has no other effect, and in
    which nothing affine moves;
  - *fold-exit* (B2): a `continue` or bare `break` of a fold that *every*
    path reaching it has mutated the fold's intermediate on, in the same
    iteration.
* **The census's reproducers** (*observation*, tests/discarded-mutation.test
  `dm-corpus-*`): the seven dead mutations (c01, c02, c05, c06, c07, c12,
  c14) and the two fold exits (c08, c09) each warn exactly once; the other
  32 reproducers -- the sixteen legitimate idioms a01-a16, every corrected
  program, c03, c04, c10, c11, c13 and the proof interactions -- are silent;
  the six rejected programs are rejected as before. Every reproducer runs to
  its recorded value on all four backends, with warnings on and off.
* **Production code is clean** (*observation*): the warning gate passes
  unchanged -- the standard library, its 43 loaders, the examples and the
  benchmarks carry no `DISCARDED-MUTATION` -- and so does
  `examples/dfa/csv/export.bot` (outside the gate's corpus), whose
  file-writing `flush` leaves its buffer dead (its callee requires a
  context, so it is no confined call). The
  repository census (section 11: 1,208 programs, 732 compiled) finds 42
  warnings: the nine reproducers, and 33 deliberate dead mutations in
  golden suites -- proofs, failures and copy-independence tests whose
  mutating call is the test's subject -- each classified and retained
  (section 12); none in the standard library, examples, packages,
  benchmarks, other test programs or audits.
* **No semantic change** (*observation*): the HIR every backend compiles,
  `hir::format`, NIR and every program's value are identical with warnings
  on and off (`dm-hir-unchanged-by-mode`, `dm-native-unchanged`,
  `dm-backends-agree`, the fuzzer's every program on interp and compile, and
  on all four backends for a seed).
* **Evidence of precision** (section 16): 1,100 generated programs
  against an independent model of both rules, 0 disagreements;
  34 mutants of the rules, each killed by the test that
  states the rule it breaks.
* **Cost** (section 17): 0.4-0.8% of the front end on the large golden suites, 2-4% on the 2048 engine, at most about 13% on generated programs that are nothing but mutations; linear in the program, the one quadratic being a report that is itself quadratic; keeping the checked source costs nothing measurable.
* **Documentation**: Compilerpedia's `warning.discarded-mutation` (five
  sections, six checked examples both ways), and the omissions the census
  found corrected: concept.values, concept.mutable-vector,
  concept.mutable-array, concept.loops and error.mutable-place-receiver now
  list a construct's bindings among the places a mutation may name, each
  holding its own copy, and concept.folds says what "immutable" means for an
  intermediate (its name cannot be bound again; a collection it holds is
  still a place).

## 2. Starting behavior

*Observations* (Tcl 9.0.1, the native backend built):

* main at `0a518ba4`, in a separate worktree: the eight registered warnings
  give the census's 41 reproducers 15 warnings, all unrelated to mutation
  (METHOD-ELIGIBLE 6, ONE-CHAR-STRING-LITERAL 9, on eight programs); the
  discarded writes c01, c05-c09, c12 and c14 compile with none at all, and
  c02's only warning is about a one-character string.
* `audit/construct-binding-mutation/tools/run.tcl` on this branch (the
  warning changes no value): 41 programs, 0 failures -- every
  reproducer's `# expect:` value on interp, compile, cranelift-generic and
  cranelift, every rejection, every `# alloc:` count. a02's and a05's counts
  (0 shares, 0 detaches, 0 elements copied) confirm that
  CONSUMED-FOLD-INTERMEDIATES-MILESTONE-1.md is on this branch: a fold that
  pushes onto its intermediate with no exit after the push no longer copies
  it.
* main's CI at `0a518ba4`: every test workflow's latest run queued (the
  earlier ones superseded and cancelled, CI-RUNS.md), c-bindgen green; no
  red run to compare against.

## 3. Architecture census

*Implementation facts*, read before writing the warning:

| piece | where | what the warning takes from it |
|---|---|---|
| the warning framework | hir/warnings.tcl (`passes`, `run`, `collect`, `Rejection`, `render`) | a static registry of passes; `run` applies the mode, skips programs with diagnostics, and gives each pass a trait program's `traitSource` -- its checked build before monomorphization -- or the HIR itself |
| when warnings run | surface/lower.tcl's `Finish`, after `hir::buildSyntax` returns | after every analysis *and every elaboration*: for a program that is no trait program, the HIR a pass sees is the elaborated one |
| the elaborations | hir/hir.tcl's `BuildFull` (`ElaborateResumes`, `hir::iteration::Elaborate`, `hir::mutvec::Elaborate`, layouts, decimal, transfer, list lengths) | they rename a fold's intermediate (`acc#entry` becomes the fold binding, `acc` a local bound to `share(acc#entry)`), give loop elements, payloads and parameters entry copies, and rewrite MutableMap and MutableSet loops into counted loops with `continue`s of their own: B2 cannot be read off that HIR, and B1's categories change |
| mutations | hir/mutvec.tcl (`OpKind`, `PlaceIndices`, `verify`) | a mutation is a native whose receiver role is `place` (registry metadata, never a name) or a call giving an argument to a function's `place` parameter; `verify` already rejects receivers that are no place and value parameters (NONPLACE-PARAMETER-MUTATION) |
| last use | hir/mutvec.tcl (`NoLaterUse`, `UseMap`, `ReadsPath`, `LaterIn`, `Leaves`, `BoundInside`) | the proof the copy convention's moves rely on: no use of the path, a prefix of it or a header-holding extension of it can run after the expression, on any path -- later statements, later operands, an earlier by-reference argument, branches after a condition, handlers after a handled call, later iterations of a loop the binding outlives, a `break`'s continuation after its loop. It reads `uses` from the convention variable the elaboration otherwise holds |
| fold exits | hir/mutvec.tcl (`FoldExitsClean`, `FoldWalk`, `GivesHeader`) | a may-analysis of whether a `continue`/`break` can run after the iteration *gave the header away* (a mutation, a place argument, a move): the consumed-fold optimization's question, conservative in the other direction from a warning's (section 8) |
| bindings | hir/resolve.tcl, hir/mutvec.tcl (`IsContextParam`, `IsPlaceParam`, `IsValueParam`) | a loop element, lockstep element, fold intermediate and handler payload are `param`s of their construct's scope; a context parameter is a `local` bound to `context#load` |
| call provenance | the `written` marker of a call the source frontend built | which calls the program wrote, in either spelling; synthesized calls (operators, list literals) and core IR carry another form or none |
| effects | hir/contexts.tcl (`required`), hir/direct.tcl, hir/coroutines.tcl, core/native.tcl (`contextFree`, runtime tags, ownership roles) | a function's transitive context requirement; directness (an ordinary module's raw call needs a context, a `direct module`'s does not); natives' own registration. There is no effect system, and no single existing fact says "this function changes nothing but its places" (section 6) |
| reachability | `reachable` flags; hir/completions.tcl's `reachedExprs` | structural reachability, and the completion proof's walk, which prunes branches its range facts prove infeasible. *Observation*: the walk records a handled call's `handle`, not the call it evaluates in place |
| affinity | hir/types.tcl's `IsAffine`, hir/resources.tcl | an affine value's release runs a resource's cleanup, which can run code |

Static checks see the program as written; the copy elaboration writes what
backends compile. The warning is about the former, so it needs the checked
build before the elaborations -- which existed for trait programs only
(`traitSource`). *Judgment*: `hir::BuildFull` now keeps that build as
`checkedSource` for a source program that uses a mutable collection and is
no trait program (one `dict set` of a reference before the first
elaboration); `hir::warnings::run`, its one reader, drops it from the HIR the
compilation returns, under every mode, so no compiled HIR -- a cache entry, a
service revision, interchange text, any comparison of HIRs -- carries it, and
its memory is released with the warning run (section 17 measures what the
reference costs the elaborations' copy-on-write). The pass refuses an
elaborated HIR that comes without one rather than misread it
(`hir::discarded::Source`: a reference to a native only the elaborations
write).

## 4. Final B1 rule (dead mutation)

A reachable call the program wrote (`written` form `function` or `method`)
that mutates -- a native whose receiver role is `place` (its receiver path
the destination), or a call of a function with place parameters (each place
argument's path a destination) -- is reported when all of these hold:

1. **Every destination dies with its scope** (`Dying`): its root binding is
   a `local` that is no context parameter (a function's, a construct
   body's, the entry program's top level), or the `param` of a `listloop`
   or `lockloop` (a loop or lockstep element), of a fold (its
   intermediate) or of a `handle` (a payload). Never a function's
   parameter: a place parameter is the caller's place, and a value
   parameter is never mutated (NONPLACE-PARAMETER-MUTATION). A module's
   top level holds no mutation (INVALID-TOPLEVEL) and no function may
   mutate a module binding (MUTABLE-PLACE-RECEIVER).
2. **Every destination is its path's last use**
   (`hir::mutvec::NoLaterUse`, unchanged, section 7).
3. **The call's value is discarded** (`ValueDiscarded`): it is unit, or the
   call is a discarded statement, or its value is the value of a construct
   that is itself discarded -- a branch of an `if`, a handled call or a
   handler's last statement (the `handle`'s value), a collecting loop's
   iteration (the loop's List). Never a function's result, the program's
   value, a fold's next intermediate, a binding's value or an operand: a
   destructive read whose element is used is a read (c13).
4. **The operation has no other effect**: a collection operation (its only
   effect is its receiver's), or a call of a *confined* function (section 6).
5. **Nothing affine is involved** (`InvolvesAffine`): no destination, argument
   or result has an affine type. Releasing or moving an affine value can run
   a resource's cleanup (`tests/resources/fds.bot`'s `v.clear()` closes
   descriptors), whose timing is the program's.
6. **It can run**: the completion analysis's walk of its function reaches it
   (top-level code: structural reachability).
7. **No fold-exit fact reports it** (one problem, one warning: the exit says
   why).

The warning is anchored at the call, with the root binding's declaration as
its related location. The fact is about the state, never the call: the
message says, when the completion analysis finds the call may fail, that "the
call itself can still fail (ERRORS)".

## 5. Final B2 rule (fold exit)

For every reachable fold whose intermediate some mutation's destination is
rooted in, one walk of one iteration (`ExitSequence`, `ExitWalk`) carries
two facts, or "top" where no path arrives:

* *must*: every path to the current point has mutated the intermediate in
  this iteration (a flag);
* *may*: the mutations of the intermediate some path to the current point
  ran in this iteration (a set; it only names the related locations).

The walk:

* a call is counted once it completes (its operands first): must becomes
  true, and the call joins may;
* an `if` meets its branches: must when both branches' are, may the union
  ("top" is the identity);
* a handler starts from the state before its handled call: the failed call
  made no mutation of its own, the handler ran instead;
* a loop inside the body may run its body no times, so it adds nothing; a
  nested function's body runs elsewhere;
* a `return`, a `fail`, an exit and any statement that never completes end
  the path ("top"): nothing after them runs.

A `continue` or `break` targeting the fold, reached with must true, is
reported, anchored at the exit, with the may set as its related locations.
Exits and mutations the completion analysis proves unreachable are dropped.

*Judgment*, revised while validating: the first version's state was the set
of mutations *every* path ran (an intersection), which missed the plainest
case of two branches that mutate differently and exit after both
(`if c: acc.push(x) else: acc.push(0)`, then `continue`): no one mutation
is on every path, yet every execution of the exit discards one. The fact
the warning states is "every path to this exit mutated the intermediate",
so that is the must-fact; which mutation a given run discarded is path
data, so the related locations are a may set
(`dm-fold-both-branches-mutate`; the mutant that keeps one specific
mutation per path, `dm-one-mutation-on-every-path`, is killed by it).

*Implementation fact*: `break` never takes a value in Botlish (a parse
error), and `break` and `continue` always target the nearest loop of the
same function (FOLD-LOOPS-MILESTONE-1.md, rules 10 and 11). So every exit of
a fold is in its own body outside any nested loop; "named" and value-bearing
exits do not exist to analyze. A `return` or `fail` inside a fold leaves it
with no value: it is never a fold-exit fact (rule 8), though a mutation of the
intermediate followed only by one is dead (B1).

## 6. Mutation classification and effect boundaries

*Implementation fact*: a mutation is identified exactly as
`hir::mutvec::verify` identifies one -- by the registry's receiver roles
(`OpKind`) and the callee's `places` -- never by an operation's spelling. The
public collection operations so identified are std::mutable_vector's push,
pop, take, swap, clear and std::mutable_array's set, swap, copy; every other
mutation is a place call (std::mutable_map's set, remove, clear, reorder,
std::mutable_set's add, remove, clear, reorder, any user function with a
`place` parameter). Element places (`-element-place`) are an installed
context's and never a dying place.

**A collection operation** has no effect but its receiver's: the registry
says so (its receiver role is `place`; no other role of its arguments calls
code).

**A place call** is the hard case: the census's
`examples/dfa/csv/export.bot:80` leaves its `chunk` dead and writes a file.
*Judgment*: no existing analysis states "has no effect but on its places",
and a context requirement is not enough (a `direct module`'s function makes
raw syscalls with none). The rule is a transitive walk, `ConfinedBlocks`: a
function is *confined* when it requires no context and every reachable
operation of its body and, transitively, of every function it calls by a
known target is

* a value computation (anything but a call), closure creation included;
* a call of a confined function;
* a call of a native whose registration says it touches nothing outside its
  arguments (`NativeConfined`): it calls no argument (no `factory` or
  `resume` role), and it is context-free (core/native.tcl: it neither reads
  nor changes the execution environment), a collection operation or
  constructor (`hir::mutvec::NativeOpKind`, `Constructor`), or a native
  whose every runtime requirement tag is a value computation's: allocation,
  big integers, characters, range checks, structural equality, hashing, and
  `table-hash` (the private keyed hash: it reads the process's hidden key
  and changes nothing).

Not confined: a call through a function value; a native that calls an
argument; a yield, a context load, a syscall (`raw-syscall`: "effects
unknown"), a C call, the process's argv; any native with no classification;
any function holding a value of an affine type (its release may run a
resource's cleanup, which the walk does not see as a call). Recursion is
analyzed optimistically: confinement is a safety property, so the greatest
fixed point is the sound one. The runtime tags are registration metadata
(core/native.tcl's `runtimeTags`, each documented); the walk names no native
and no operation.

What a confined call can still do is fail (with its declared errors) or not
terminate: the warning hides neither, and says the former.

*Observation* (tests): std::mutable_set::add, and std::mutable_map's set and
std::mutable_set's clear, are confined (c12, `dm-mutable-map-and-set`); a
helper that also pushes to a context (`dm-place-helper-context`), calls a
function value directly or one call down (`dm-place-helper-calls-a-function-value`,
`dm-place-helper-transitive`), hands one to `generate`
(`dm-place-helper-runs-a-callable-through-a-native`), closes a descriptor
with a raw syscall in a `direct module` and no context
(`dm-place-helper-io-without-context`), or drops a resource whose cleanup
makes a syscall and requires nothing (`dm-place-helper-holds-a-resource`) is
not. A call that gives two places is dead only when both die unread
(`dm-place-helper-two-places`: a transfer from one to another is
productive).

## 7. Destination liveness

`hir::mutvec::NoLaterUse`, unchanged, decides condition 2 for each
destination, with a use map built for the program as written (and the
convention variable it reads kept and restored). It is path-based:
reading `s.count` (an Int field) after `s.items.push(1)` leaves the push
dead, reading `s` or `s.items` does not (`dm-nested-field-path`); an earlier
mutation is read by a later one, so only the last of a run of pushes is dead
(`dm-earlier-mutations-live`).

What it does and does not prove (*implementation facts*, each pinned by a
test):

* A later reference on *any* path keeps a mutation live: a return on some
  paths is no trigger (`dm-conditional-return-is-no-trigger`), and a `fail`
  after a mutation makes it dead only when nothing reads it on any path
  (`dm-mutation-then-fail`). The warning never fires "merely because" an
  exit follows: it fires because nothing reads the state.
* *Known false negative*: a binding mutated in a loop it outlives is live at
  the end of every iteration (the next one may read it), so
  `acc.push(i)` in every iteration of a counted loop, never read after it,
  is silent (`dm-loop-liveness-false-negative`). The census recorded this;
  extending `NoLaterUse` to loop-carried liveness was out of scope.
* *Known false negative*: a read is a read even when its own value is
  discarded -- `loop row in rows: row.push(42); row` as a statement collects
  the pushed rows into a List nobody reads, and is silent
  (`dm-read-whose-value-is-discarded`).
* The walks bound themselves at 4096 enclosing expressions: past that,
  "not dead" -- conservative.

## 8. Fold exit analysis

*Judgment*: the warning does not reuse `FoldExitsClean`'s answer. That
analysis asks whether an exit *may* run after the iteration *may* have given
the intermediate's header away -- to decide whether the entry copy can be
skipped -- and answers "not clean" for reasons that discard nothing (a move
of the header to another value, a path that is infeasible, a mutation in one
branch and an exit in another). The warning asks whether an exit discards a
mutation, and must not report a path it cannot show exists. Its walk shares
the traversal's shape (sequences, branches, handlers, inner loops, nested
functions) but answers "every path" instead of "some path".

That choice makes path feasibility irrelevant: if every path to the exit in
the iteration's control flow -- feasible or not -- ran the mutation, then
every execution of the exit discards it. The price is a false negative
(*Judgment*, recorded in section 18): `if a: acc.push(x)` followed by
`if b: continue` is silent, although `a and b` may well hold together. A
may-analysis would report it, and would also report
`if x > 0: acc.push(x)` followed by `if x <= 0: continue`, where the path is
impossible; no available analysis relates the two conditions, so the
narrower rule is the one that is always right (`dm-fold-branch-paths`). The
mutant that makes the branches' must a disjunction, and the one that
reports wherever `FoldExitsClean` fails, are both killed by that test. Two
branches that each mutate, followed by an exit, are every path, and warn
(`dm-fold-both-branches-mutate`).

The other distinctions, each a test: an exit before the mutation discards
nothing (`dm-fold-continue-before-and-after`, `-break-before-and-after`); an
inner loop's exits are the inner loop's (`dm-fold-inner-loop-exit`); an
inner fold's exits never discard the outer intermediate's mutations
(`dm-fold-nested-folds`); a mutation through a place helper counts
(`dm-fold-place-helper`); a read of the intermediate does not, nor does a
mutation of a copy of it (`dm-fold-read-only-and-moved`); a struct
intermediate's field counts (`dm-fold-struct-intermediate`); a handler of
the mutating call itself discards only what ran before that call
(`dm-fold-handler`); every loop kind is covered (`dm-fold-every-loop-kind`);
an exit the completion analysis proves unreachable warns nothing
(`dm-fold-unreachable-exit`); 400 conditions deep at Tcl's default recursion
limit the walk runs in depth-safe segments (`dm-fold-exit-deep`; it is in
audit/depth-safe-nesting/census.tsv).

## 9. Diagnostic messages and locations

B1, anchored at the call, the related location the root binding's
declaration:

```
c01.bot:12:5: warning: this mutation of `row` is never observed: nothing reads `row` again before it goes out of scope (`row` is this iteration's own copy of an element, not the element of the iterated collection) (DISCARDED-MUTATION)
c01.bot:11:6: note: `row` is bound here
```

The clause after the scope says what the place is when it is a construct's
binding: a loop or lockstep element ("this iteration's own copy of an
element"), a handler payload ("the handler's own copy of the error's
payload"), a fold intermediate ("a fold carries its intermediate's changes
only to the iteration after one that completes with it"); a local gets none.
A field path is named as written (`s.points`, "before `s` goes out of
scope"); a call that can fail says so:

```
t.bot:4:5: warning: this mutation of `a` is never observed: nothing reads `a` again before it goes out of scope; the call itself can still fail (IndexNotFound) (DISCARDED-MUTATION)
```

B2, anchored at the exit, each mutation some path to it ran a related
location (one warning per exit, however many mutations):

```
c08.bot:19:13: warning: this `continue` discards this iteration's mutation of the fold's intermediate `acc` (every path to it mutates `acc`): the fold carries the intermediate this iteration started with to the next iteration, not its modified value (DISCARDED-MUTATION)
c08.bot:17:9: note: a mutation of `acc` before this `continue`, in the same iteration
```

and for `break`, "the fold yields the intermediate this iteration started
with, not its modified value". The messages state what happens to the state
and nothing about intent; the remedies are Compilerpedia's (main.tcl prints
`help: tclsh9.0 main.tcl -help warning.discarded-mutation` under them).
Names are source names (`hir::semantic::SourceName`), never hygiene's.

## 10. Warning-policy integration

Nothing new: the pass is one registry line, and the framework applies the
policy (`dm-mode-off`: the pass never runs; `dm-mode-error`: the warning's
code and message, its related location appended; `dm-mode-default-runs`;
`dm-rejected-program-not-warned`; `dm-cli`: stderr, the help line, the
program still runs; `-warnings error` rejects). Ordering is the framework's
(source order, then code, then message). A call exists once in the program
as written, whatever its spelling (`dm-spellings-agree`), its semantic
instances (`dm-generic-function-once`) or a trait program's clones
(`dm-trait-program`), so no warning is duplicated. The tests that pin the
registry (warnings.test, many-boolean-arguments.test, method-eligible.test,
one-char-string-literal.test, fixed-arity-list-return.test, proves-naming.test,
same-failure.test, compilerpedia.test, static-compile.test's census of
diagnostic kinds) list the ninth code.

## 11. Existing warning-baseline impact

**The warning gate** (audit/refactor/tools/gate.tcl: the shipped standard
library, its 43 loaders, the 89 example and benchmark programs, each
compared with audit/refactor/manifest.txt): passes unchanged, run twice --
during development and with the final code (*observation*). The manifest
needs no entry: production code holds no dead mutation in the warning's
sense, and no unit lost its `-warnings error` cleanliness.

**The repository census** (`audit/discarded-mutation/tools/census.tcl`, 3
shards; its result is `audit/discarded-mutation/census.tsv`). The programs
are the construct-binding census's: every tracked `.bot` file but the
generated C bindings, plus a one-line loader per standard-library module
(a Windows or macOS module compiled for its platform's target), each
compiled by the ordinary front end with warnings on. *Observation*: 1,208
programs, 732 compiled (the 8 Windows and macOS loaders compiled for their
targets). The 476 rejected are, by first diagnostic, the by-design
categories the construct-binding census recorded: modules compiled outside
the entry that loads them (UNKNOWN-NAMESPACE 178, MISSING-IMPORT 25), the
event-loop prototype and its copies (CONTEXT-FUNCTION-VALUE 55), the
rejected corpora of the diagnostic-recovery, equality, proof,
syntax-recovery and NONPLACE-PARAMETER-MUTATION audits, programs needing a
package staged at test time, the two internal standard-library modules
(`std::ordered_table`, `std::io::bytepath`: INTERNAL-NAMESPACE as programs,
analyzed through the modules that import them), and one probe requiring a
library that no longer exists. The warnings, counted once per location:

| area | programs | compiled | dead (B1) | fold-exit (B2) |
|---|---:|---:|---:|---:|
| `stdlib/` (one loader per module) | 46 | 44 | 0 | 0 |
| `examples/` | 113 | 67 | 0 | 0 |
| `bench/` | 18 | 12 | 0 | 0 |
| `packages/` | 8 | 1 | 0 | 0 |
| `tests/golden/` | 119 | 119 | 33 | 0 |
| other test programs (`tests/*/`) | 156 | 55 | 0 | 0 |
| `audit/` but the construct-binding corpus | 700 | 395 | 0 | 0 |
| the construct-binding corpus | 41 | 35 | 7 | 2 |
| elsewhere (compilerpedia, editors, single, tools) | 7 | 4 | 0 | 0 |
| **total** | **1,208** | **732** | **40** | **2** |

The 9 corpus warnings are exactly the designed reproducers (section 1).
Production code -- `stdlib/`, `examples/`, `packages/`, `bench/` -- holds
none; `packages/` and parts of `examples/` (Icy Tower, the event-loop and
Raven consumers) need staged packages and are covered by the gate's and the
construct-binding census's own staging. Compared with the census
(CONSTRUCT-BINDING-MUTATION-CENSUS-1.md, section 16): it predicted "0 /
33" -- no production site, 33 deliberate golden sites, 20 operations and 13
place calls -- and the implemented rule finds exactly that split.

**The Tcl test files' programs** (`tools/test-census.sh`: every test file run
under a hook that analyzes each program it compiles, on interp, the golden
duplicates skipped): 284 test files, 12,063 tests (9,304
passed, 2,757 skipped -- golden duplicates and host constraints -- and 2
failed, both understood: `main-cli.test`'s `cli-help-index` counts the
warnings index's topics, eight before this milestone and nine now, and is
updated; `static-economics.test`'s `se-property-plan-gate` reads
`hir::BuildFull`'s body with a regular expression and saw the census
hook's wrapper -- run directly it passes). Findings, counted once per
program location (`audit/discarded-mutation/test-census.tsv`): 79, of which
41 are this milestone's own test programs; the other 38 -- 33 dead, 5 fold
exits -- are all in tests that exist to pin the behavior the warning
describes: proven-bounds.test 19 (programs whose only point is to prove a
`set` or `copy` in bounds), consumed-fold-intermediates.test 5 (its exits
after a push, which pin the rollback: all five fold exits), mutable-vector.test
4 and mutable-array-type.test 2 (copy independence, the payload entry copy),
and one each in mutable-array, native-mutarray, nonplace-parameter-mutation
(the working-copy variant), place-parameters, refinement-values (a
predicate that writes its own copy, to pin that it is not repeatable),
static-compile-expected-diagnostics (a template whose map only one snippet
reads), stdlib-namespaces and golden.test (errors.bot, the golden site
above). The construct-binding census counted the same class in the same
files ("35 native operations in 8 files ... and 4 place calls", none of the
B2 shape, which the consumed-fold tests added since). No test compiles one
of these programs under `-warnings error` or asserts a complete warning
set, which is why none failed.

## 12. Golden-suite migration and retained intentional warnings

`audit/discarded-mutation/golden-sites.tsv` lists the 33 golden sites, each
with its test and class. *Judgment*: every one is retained, unrewritten.

| class | sites | what the mutation is for |
|---|---:|---|
| proof | 17 | a `static compile:` block or a proof test whose mutating call exists to be proven: collection-reorder's ten reorders (REORDER-NOT-PROVEN is the alternative), stdlib-namespaces' `copy-within-capacities` (the census's own example), place-parameters' length proof across a place call (the cleared field is never read, the disjoint one is), compiled-values' three per-instance writers, mutable-array's admitted writes (`mat-bd-5/write-valid`, `mat-ref-3`) |
| independence | 9 | a write to one copy the test does not read, because it reads the *other* copy: collection-reorder's order snapshot, mutable-array's surviving result, parameter store, `mutarray-sem-4` and `-7`, native-aggregates' `mutarray-5`, and nonplace-parameter-mutation's two SimCity "local copy" variants, which pin the very program behavior c14 reproduces |
| failure | 5 | the operation's IndexNotFound, LowerUnderrun or UpperOverrun (or its success) is the observed outcome: errors.bot's `mat-run-7`, native-aggregates' set and copy bounds tests, validators-and-proofs' agreement of bounds values |
| result | 2 | set's own result, unit (`mutarray-4`), and a GC workload whose final write exercises the array (`paramagg-gc-stress-1`) |

Why no rewrite: the dead write is each test's subject. A read added after
it would change no test's meaning but would add a line to suites that pin
locations (`rejects_at`) and to static-compile blocks whose decisions the
static-decisions workflow compares, for no benefit -- the golden runner
compiles every suite with warnings off (tests/golden/run.tcl), so none of
these warnings is ever emitted by a test, and none changes a test's
outcome. The baseline is a committed, classified file rather than a
mechanism: no per-warning suppression, no file exemption, no special
treatment of `tests/`. `tools/census.tcl` re-takes it; a new site in a
golden suite is classified the same way or rewritten. Frozen fixtures
(audit/refactor/kickoff-corpus) hold none.

## 13. Compilerpedia

* `warning.discarded-mutation` (compilerpedia/topics/warnings.topic): what it
  detects (both reasons, with the rendered warnings), why it matters (a
  construct binding is a place holding its own copy; a fold exit's rollback),
  recommended practice (collect the changed copies, a `place` parameter,
  return the working copy, complete the iteration with the intermediate,
  remove a genuinely unnecessary mutation -- with its failure), the
  evidence, and the legitimate exceptions and known false negatives. Six
  examples, each run on the backends by `tools/compilerpedia.tcl check`:
  the loop-variable push (warns) and its collecting fix (silent); the fold
  continue (warns) and test-first (silent); a returned working copy and a
  used destructive read (silent).
* The census's documentation gap: concept.values, concept.mutable-vector,
  concept.mutable-array and error.mutable-place-receiver now list loop
  variables, fold intermediates and handler payloads among the places a
  mutation may name, each a place of its construct holding its own copy;
  concept.loops says what mutating a loop variable changes; concept.folds
  says the intermediate's *name* is immutable while a collection it holds is
  a place, and points at the warning.
* Two existing examples now warn. concept.folds's "a continue after the
  push drops that iteration's push" exists to show exactly B2: it states
  `@warn DISCARDED-MUTATION` and says so. proof.list-bounds's tenth example
  pushed onto a vector and returned without reading it (the push mattered
  only as a resize): it now returns `r + v.length()` (24), the proof it shows
  unchanged.
* `tools/compilerpedia.tcl check`: 1,295 topics, 769 examples, 0 problems.

## 14. Backend consistency

The warning is decided once, by the front end, on the program as written:
no backend computes or reads it (`hir/discarded.tcl` reads no NIR, core IR or
backend state). *Observations*: the HIR minus the side table, `hir::format`,
NIR (specialized and generic) are identical under `off` and `default`; every
warned reproducer and every fuzzer program runs to the same value on
interp and compile (all four backends for the reproducers and one fuzzer
seed) with warnings on and off; a decoded interchange HIR carries the
warnings and no checked source.

## 15. Regression corpus

tests/discarded-mutation.test, 70 tests, each listed in the golden-migration
census (`audit/golden/migration/census/discarded-mutation.tsv`; warnings are
not observable from a golden suite, which compiles with warnings off:
`KEEP-WARNING`, and `KEEP-INTERNAL` for the side table, the registry, the
depth guard and the process boundary). By section of the file:

* the census's reproducers: the nine warned, the rest silent, two rendered,
  every warned one's behavior on four backends with warnings on and off;
* B1 places: a local (and read on one path, on some path, returned), a
  MutableArray set that can fail and one proven in range, the explicit copy
  of a value parameter (c14) and its returned variant, a struct field's
  path, the top level, a loop element in a function and its collecting
  variant, an inner loop's element, a handler payload, a destructured local,
  a dead mutation before a `fail`, a conditional return;
* B1 values: a destructive read used and dropped, a handled pop, a collected
  value discarded and used;
* B1 effects: a place parameter, a confined helper in both spellings, helpers
  with a context, a function value, a transitive callee, a raw syscall, a
  callable handed to a native, a resource of their own, two places; a context
  member; MutableMap and MutableSet operations; collections of resources and
  of coroutine handles;
* the known false negatives, pinned as such; unreachable code;
* spellings, generic instances, trait programs, one warning per call, a run
  of pushes;
* B2: before and after for `continue` and `break`, several mutations, branch
  paths, both branches, inner loops, nested folds, place helpers, reads and
  copies, struct intermediates, handlers, `return`, dead-and-exit
  deduplication, conditional mutations, normal completion, unreachable exits,
  every loop kind, depth;
* the policy, the checked source's lifetime, the refusal of an elaborated
  HIR, backends, NIR.

## 16. Fuzzing and mutation testing

**The fuzzer** (`audit/discarded-mutation/tools/fuzz.tcl`) generates
functions over three MutableVector locals from a grammar whose statements
state their relations: pushes in both spellings, handled pops dropped or
bound, calls of a confined place helper and of one that also changes an
installed context, reads, `if`s on a parameter of their own (no two
conditions share one, so every path is feasible), early returns, and folds
whose bodies mutate the intermediate or the locals, exit under conditions,
and complete with the intermediate or a fresh vector. Its model is its own:
a backward liveness over the statement tree it generated (a local is live
at a fold body's end and after a `continue`, live after a `break` as after
the fold, live before a fold when the fold refers to it; an intermediate
dies at every exit and at a body's end that does not complete with it), and
a forward must-analysis of each fold body. It never calls the compiler's
analyses. Per program it checks the warnings (reason, line, column) against
the model, that `off` attaches none and builds the same HIR, that `error`
rejects exactly the warned programs with the first warning's code, and that
the backends run the program to the same value with warnings on and off.

*Observations*, with the final model and generator:

| seed | programs | backends | with warnings | dead | fold-exit | disagreements |
|---|---:|---|---:|---:|---:|---:|
| 1 | 150 | interp, compile | 62 | 77 | 7 | 0 |
| 2 | 60 | interp, compile | 27 | 35 | 3 | 0 |
| 3 | 150 | interp, compile | 66 | 75 | 11 | 0 |
| 5 | 150 | interp, compile | 82 | 89 | 12 | 0 |
| 7 | 150 | interp | 63 | 75 | 2 | 0 |
| 13 | 100 | interp | 43 | 53 | 7 | 0 |
| 17 | 150 | interp, compile | 57 | 69 | 5 | 0 |
| 21 | 40 | interp, compile, cranelift-generic, cranelift | 22 | 28 | 1 | 0 |
| 41 | 150 | interp, compile | 71 | 86 | 5 | 0 |
| **total** | **1,100** | | **493** | **587** | **53** | **0** |

Every disagreement found while building the fuzzer was the model's, and each
taught it something true about the rule rather than the reverse: (1) a fold
counts as a use of a local only when its body refers to it -- the model had
first treated "the next iteration may read any local" as reaching outside
the fold (seed 2, six programs); (2) a `break` makes the locals live as
they are after the fold, not every local; (3) a fold over `[1, 2, 3]` whose
body starts with an unconditional `return` never completes, and the
compiler knows it (the List's length), so a mutation after it is
unreachable and correctly silent (seed 7): the generator no longer writes
such a fold. No disagreement was a compiler error, and none changed the
rule. The fold-exit share was raised by biasing the generator towards folds
(seed 13 on) after the first seeds produced 1-4 per 150 programs.

**The mutation catalog** (`audit/discarded-mutation/tools/mutants.txt`,
`mutate.tcl`): each mutant must apply exactly once and be killed by a test
its `!!` line names (a failure of any other test is reported as "not for its
reason", a failure).

*Observation*: 34 mutants -- the two facts disabled, each condition of B1
(later reads, the call's value, collected results, field paths, the dying
categories, a call's second place, affine values, reachability), each part
of the effect boundary (place calls ignored, every function confined,
unknown callees, transitivity, runtime tags, callable natives, affine
locals), the B2 walk ("some path" for the must-fact, one specific
mutation for it, `FoldExitsClean` as the condition, inner-loop exits, observations as mutations, a handler's entry
state, duplicate reports), the program as written (no checked source, an
elaborated HIR analyzed, the checked source outliving the run), the report
(related locations, the failure clause) and the policy (`off` and `error`)
-- every one applies exactly once and is killed by a test its `!!` line
names:

| mutant | what it breaks | killed by |
|---|---|---|
| `dm-no-dead` | the dead-mutation fact is never reported: every B1 reproducer compiles silently again | `dm-corpus-discarded-writes`, `dm-explicit-copy-of-value-parameter`, `dm-local-push` |
| `dm-no-fold-exit` | the fold-exit fact is never reported: a continue or break after a mutation of the intermediate is silent again | `dm-corpus-discarded-writes`, `dm-fold-break-before-and-after`, `dm-fold-continue-before-and-after` |
| `dm-ignore-later-read` | a later read is ignored: every mutation of a dying place is dead, read afterwards or not | `dm-corpus-silent`, `dm-earlier-mutations-live`, `dm-local-read-after` |
| `dm-used-destructive-read` | every call's value counts as discarded: a pop whose element is used is a dead mutation | `dm-corpus-silent`, `dm-destructive-read-used`, `dm-handled-destructive-read` |
| `dm-collected-result-used` | a value a collecting loop collects counts as used, whatever becomes of the loop's List: the census's c12 is silent again | `dm-collected-result`, `dm-corpus-discarded-writes` |
| `dm-ignore-field-paths` | a destination that is a field path is never analyzed: a struct field's dead push is silent again | `dm-corpus-discarded-writes`, `dm-nested-field-path` |
| `dm-context-dies` | a context parameter counts as a place that dies with its function: a context member's push is reported | `dm-context-member` |
| `dm-place-parameter-dies` | a function's parameter counts as a dying place: a place parameter's mutation inside its function is reported, although the caller owns it | `dm-fold-place-helper`, `dm-place-helper-confined`, `dm-place-parameter` |
| `dm-loop-element-lives` | a loop element counts as a place that outlives the call: the canonical loop-variable push is silent again | `dm-collecting-loop-element`, `dm-corpus-discarded-writes`, `dm-nested-loop-inner-element` |
| `dm-payload-lives` | a handler's payload counts as a place that outlives the handler: its dead mutation is silent again | `dm-handler-payload` |
| `dm-first-place-only` | a call giving two places is judged by its first: a transfer whose second place is read is reported | `dm-place-helper-two-places` |
| `dm-affine-ignored` | an affine destination or argument is ignored: clearing a collection of resources -- whose cleanups run code -- is reported | `dm-affine-collection` |
| `dm-unreachable-kept` | the completion analysis's reachability is ignored: a mutation or an exit under a branch it proves infeasible is reported | `dm-fold-unreachable-exit`, `dm-unreachable` |
| `dm-place-calls-ignored` | a call giving a place to a function is no mutation: std::mutable_set::add on a dying set (c12) and a place helper on the intermediate are silent again | `dm-collected-result`, `dm-corpus-discarded-writes`, `dm-fold-place-helper`, `dm-mutable-map-and-set`, `dm-place-helper-confined` |
| `dm-any-place-call-confined` | every function is confined: a place helper with another effect -- a context, a function value -- is reported | `dm-place-helper-calls-a-function-value`, `dm-place-helper-context`, `dm-place-helper-transitive` |
| `dm-unknown-callee-confined` | a call through a function value is taken for a confined one: a place helper calling one is reported | `dm-place-helper-calls-a-function-value` |
| `dm-not-transitive` | confinement reads a function's own body only: a helper whose callee calls a function value, or makes a raw syscall, is reported | `dm-place-helper-io-without-context`, `dm-place-helper-transitive` |
| `dm-every-tag-a-value` | an unknown-effect runtime tag counts as a value computation: a place helper whose callee makes a raw syscall is reported | `dm-place-helper-io-without-context` |
| `dm-callable-natives-confined` | a native that calls an argument (a factory) counts as confined: a place helper handing a function value to generate is reported | `dm-place-helper-runs-a-callable-through-a-native` |
| `dm-affine-local-confined` | a function holding an affine value counts as confined: a place helper that drops a resource of its own (its cleanup runs) is reported | `dm-place-helper-holds-a-resource` |
| `dm-may-not-must` | the walk's must-fact joins as "some path" instead of "every path": a mutation in one branch and an exit under another, which may never run together, is reported | `dm-fold-branch-paths`, `dm-fold-conditional-mutation-then-exit` |
| `dm-one-mutation-on-every-path` | the must-fact asks for one mutation on every path instead of a mutation on every path: an exit after a different push on each branch is silent again | `dm-fold-both-branches-mutate` |
| `dm-exit-whenever-not-clean` | a fold-exit fact wherever the consumed-fold optimization keeps the entry copy (FoldExitsClean): a mutation that only may precede an exit is reported | `dm-fold-branch-paths` |
| `dm-inner-loop-exits` | a loop in the fold's body is walked as if its exits were the fold's: an inner loop's continue after a mutation of the intermediate is reported | `dm-fold-inner-loop-exit`, `dm-fold-nested-folds` |
| `dm-read-only-as-mutation` | an observing collection operation counts as a mutation: reading the intermediate's length before an exit is reported | `dm-fold-read-only-and-moved` |
| `dm-handler-after-call` | a handler starts from the state after its handled call: the failed pop's own mutation counts as one the handler's continue discards | `dm-fold-handler` |
| `dm-duplicate-reports` | a mutation a fold exit discards is reported again as dead: one problem, two warnings | `dm-fold-dead-and-exit-once` |
| `dm-no-checked-source` | the checked program before the elaborations is not kept for the warning run: an ordinary program is analyzed only when its elaboration happened to write no copy, and a fold with an exit (copied) never | `dm-checked-source`, `dm-corpus-discarded-writes`, `dm-fold-continue-before-and-after` |
| `dm-elaborated-analyzed` | an elaborated HIR is analyzed as if it were written so (its fold's intermediate renamed, its copies written out) | `dm-elaborated-hir-not-analyzed` |
| `dm-no-related-locations` | the warnings carry no related location: the dead mutation's binding and the exit's mutations are not named | `dm-corpus-discarded-writes`, `dm-fold-several-mutations-one-exit` |
| `dm-failure-unmentioned` | the dead-mutation message no longer says that the call can still fail | `dm-array-set-can-fail` |
| `dm-off-runs-passes` | warnings off runs the passes anyway | `dm-mode-off` |
| `dm-error-not-raised` | warnings error rejects nothing | `dm-mode-error` |
| `dm-checked-source-leaks` | the checked source outlives the warning run: every compiled HIR of a program with a mutable collection carries a second copy of its program into the cache, the compiler service and every comparison of HIRs | `dm-checked-source` |

Two results of the first run changed the tests, not the rule: the mutant
that stops confinement from propagating was killed only by the raw-syscall
test (the transitivity test's helper also required a context, which the
requirement check catches without propagation), so the transitivity test
now puts a call through a function value one call down, with no context
anywhere; and the mutant that analyzes an elaborated HIR survived (the
test's program happened to give no finding either way), so the test now
also uses a loop-variable program whose elaborated HIR *would* give one.
The table is the last run, the whole catalog against the final code
(`mutate.tcl`, exit status 0): 33 of 33 killed for their reason. (The first
run, before the two test changes above, had killed 30 of 32.)
`tools/mutant-catalogs.tcl`: 101 catalogs, 3,434 mutants, all apply (the
existing catalogs unaffected by this change).

## 17. Compile-time performance

*Implementation facts* -- what the pass does, for a program that uses a
mutable collection (any other returns at once, after a scan of the interned
types: `hir::mutvec::Used`):

* one walk of the expressions to find the mutation sites (calls the program
  wrote whose registry role or callee's `places` mutate);
* one parent map (`hir::contexts::Walk`) and one use map
  (`hir::mutvec::UseMap`: per reference, its enclosing expressions), both
  linear in the program (the use map in its references times their depth);
* per site, the cheap conditions first (the destination's binding, its
  value's position, affinity) and `NoLaterUse` per destination, which walks
  up the parent chain and scans the later siblings of each enclosing
  sequence until a reader -- the same proof the copy elaboration already
  runs per read-out;
* per distinct place-taking callee, one confinement walk over the functions
  it reaches, memoized for the run (the standard library's map and set
  operations are walked once per program);
* per fold whose intermediate some site mutates, one walk of its body,
  updating one set in place (a branch copies it once for its other side);
* per function holding a finding, the completion analysis's walk
  (`reachedExprs`, as SAME-RETURN-VALUE already does) -- computed only for
  candidates, cached per function.

Nothing is repeated per semantic instance or per trait clone: the program
as written has each expression once.

*Observations* (`bench/discarded-mutation.tcl -runs 3`, best of three; a
4-core container, other processes running beside it, so the ratios are the
meaningful figures): the pass's own time against the front end's (warnings
off), for real programs and for generated shapes made mutation-dense on
purpose, at three scales.

| program | expressions | sites | folds | findings | front end (ms) | pass (ms) | pass / front end |
|---|---:|---:|---:|---:|---:|---:|---:|
| tests/golden/mutable-vector.bot | 4,569 | 91 | 0 | 0 | 17,689 | 74 | 0.4% |
| tests/golden/fold-loops.bot | 6,963 | 115 | 67 | 0 | 17,797 | 129 | 0.7% |
| tests/golden/mutable-map.bot | 7,043 | 161 | 0 | 0 | 21,596 | 111 | 0.5% |
| examples/games/2048/game2048.bot | 663 | 1 | 0 | 0 | 219 | 8 | 3.6% |
| examples/games/2048/demo.bot | 2,038 | 1 | 0 | 0 | 1,339 | 32 | 2.4% |
| locals: 400 / 800 / 1,600 statements over 20 vectors | 1,680 / 3,280 / 6,480 | 343 / 686 / 1,371 | 0 | 16 / 16 / 15 | 733 / 1,219 / 2,257 | 70 / 109 / 279 | 9.5 / 9.0 / 12.4% |
| nested loops 6 / 12 / 24 deep | 240 / 456 / 888 | 48 / 96 / 192 | 0 | 6 / 12 / 24 | 95 / 170 / 379 | 6 / 13 / 25 | 6.7 / 7.6 / 6.7% |
| one fold, 200 / 400 / 800 pushes, an exit every 5 | 1,666 / 3,306 / 6,586 | 200 / 400 / 800 | 1 | 40 / 80 / 160 | 568 / 1,005 / 2,789 | 65 / 128 / 307 | 11.4 / 12.7 / 11.0% |
| an untyped function, 200 / 400 / 800 pushes, 6 instances | 832 / 1,632 / 3,232 | 200 / 400 / 800 | 0 | 1 / 1 / 1 | 672 / 1,128 / 2,600 | 27 / 50 / 129 | 4.0 / 4.4 / 5.0% |
| 20 / 40 / 80 application modules, 30 pushes each | 4,482 / 8,962 / 17,922 | 600 / 1,200 / 2,400 | 0 | 0 | 1,553 / 2,608 / 6,999 | 98 / 166 / 340 | 6.3 / 6.4 / 4.9% |

* On real programs the pass costs 0.4-0.8% of the front end for the large
  golden suites and 2-4% for the 2048 engine; the generated shapes, which
  are almost nothing but mutations, stay within 5-13%.
* It grows linearly with the program: doubling a shape doubles its time,
  within the machine's noise. A profile of the flat shape at 800, 1,600 and
  3,200 statements (the walk, the use map, `NoLaterUse` over every site and
  the completion walk, each measured alone) gives 97, 291 and 504 ms in all,
  each part roughly doubling.
* The one quadratic is the report itself: a fold whose exits each discard
  every earlier push reports, at each exit, every mutation it discards (an
  exit every 5 pushes over 3,200 pushes is 640 warnings with 1,025,600
  related locations, 3.3 s). The work is proportional to that output.
* *Judgment*, from this measurement: the first version of the fold-exit walk
  copied its state set at every mutation (a value shared between the
  caller's frame and the callee's), and compared it with a string at every
  statement -- quadratic even with a single exit (859 ms for 3,200 pushes).
  The walk now updates the set where it is held and marks "no path" with a
  key (80 ms); the fuzzer's seeds 3 and 5 give the same results before and
  after.
* Keeping the checked source (the last column of the benchmark's own
  output) costs nothing measurable: the front end with and without it
  differ by noise, in both directions; its memory is released when the
  warning run drops it.

## 18. Known false negatives and precision limitations

* **Loop-carried liveness** (section 7): a binding mutated in every
  iteration of a loop it outlives and never read after the loop is silent.
* **A read whose value is unused** keeps a mutation live: a loop collecting
  the mutated element as a discarded statement, a binding of a read nobody
  uses.
* **Fold exits only some paths reach** after the mutation are silent (the
  must-analysis; section 8). A mutation in one branch followed, on every
  path, by an exit is still reported -- as dead (B1), since nothing reads it.
* **Place calls**: a callee that calls a function value, takes a callable
  into a native, holds an affine value, requires a context, or reaches any
  native without a classification is never confined, whatever it does.
  Divergence of a confined callee is not modeled as an effect.
* **Affine values**: no warning involves one, even where its release would
  be unobservable (a coroutine handle's).
* **Intent**: c03, c04, c10 and c11 read the mutated copy; nothing here can
  tell them from legitimate scratch use, and the warning says nothing about
  them (the census, section 19).
* **Elaborated HIR**: a HIR read from interchange text carries its warnings
  and is never analyzed again; the pass declines an elaborated HIR rather
  than misread it.

## 19. Files changed

| file | change |
|---|---|
| hir/discarded.tcl (new) | the two facts: sites, `Dying`, `ValueDiscarded`, `InvolvesAffine`, confinement, the fold-exit must-walk, the program as written |
| hir/warnings.tcl | the registry entry, the pass and its messages; `run` drops `checkedSource` from the HIR it returns |
| hir/hir.tcl | `BuildFull` keeps `checkedSource`; the file list sources hir/discarded.tcl; the HIR documentation |
| hir/interchange.tcl | encode leaves `checkedSource` out |
| tests/discarded-mutation.test (new) | the regression corpus |
| tests/{warnings,many-boolean-arguments,method-eligible,one-char-string-literal,fixed-arity-list-return,proves-naming,same-failure,compilerpedia,static-compile,main-cli}.test | the ninth registered code (main-cli: the warnings index lists nine topics) |
| compilerpedia/topics/{warnings,concepts,folds,errors-ownership,proofs}.topic | the warning's topic, the construct-binding documentation, two examples |
| audit/discarded-mutation/ (new) | census, test census, fuzzer, mutation catalog, their results |
| audit/depth-safe-nesting/census.tsv | the two guarded walks |
| audit/golden/migration/census/discarded-mutation.tsv, tcl-names.txt, tests/golden/manifest.tsv | the new test file's rows |
| bench/discarded-mutation.tcl (new) | the cost measurement |
| AGENTS.md, docs/INDEX.md | the rule and what to run; this report |

## 20. Reproduction commands

Tcl 9.0.1, `LANG=C.utf8 LC_ALL=C.utf8`, the native backend built
(`cargo build --release --manifest-path native/Cargo.toml`):

```
tclsh9.0 tests/discarded-mutation.test
tclsh9.0 audit/construct-binding-mutation/tools/run.tcl
tclsh9.0 audit/discarded-mutation/tools/fuzz.tcl -seed N -count 150
tclsh9.0 audit/discarded-mutation/tools/fuzz.tcl -seed N -count 40 -backends "interp compile cranelift-generic cranelift"
tclsh9.0 audit/discarded-mutation/tools/mutate.tcl
tclsh9.0 audit/discarded-mutation/tools/census.tcl -shard I/3 -out census-I.tsv
sh audit/discarded-mutation/tools/test-census.sh OUTDIR 4
tclsh9.0 audit/refactor/tools/gate.tcl
tclsh9.0 tools/compilerpedia.tcl check
tclsh9.0 tools/mutant-catalogs.tcl
tclsh9.0 bench/discarded-mutation.tcl -runs 3
```
