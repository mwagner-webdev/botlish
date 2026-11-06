# Non-place parameter mutation correctness, milestone 1

A function parameter that is not declared `place` is a value: the
function's own logical copy of its argument. A mutation whose destination
is rooted in one is now the compile-time error
`NONPLACE-PARAMETER-MUTATION`
(`std::compiler::DiagnosticCode::NonplaceParameterMutation`), reported at
the mutation. A program says which
of the two meanings it wants: `place` for the caller's storage, or an
explicit local copy for a local working value. Both run unchanged on every
backend.

Throughout, *implementation fact* means something read from the code,
*observation* something a run showed, and *judgment* a design decision this
report argues for.

## 1. Result

* **The rule.** `hir::mutvec::verify` rejects every mutation whose place
  path is rooted in a value parameter: a collection operation's receiver
  (all eight public mutating operations of MutableVector and MutableArray)
  and the argument of another function's place parameter (which covers the
  standard library's MutableMap and MutableSet operations). Field paths,
  untyped, imprinted, affine and nested functions' parameters are covered;
  so are both call spellings. The diagnostic is the call's own problem
  (`hir::CheckingCall`), located at the receiver or argument, and relates
  the parameter's declaration.
* **The three SimCity shapes** (section 2) are rejected. Their `place`
  versions update the caller's storage on all four backends; their
  local-copy versions run with exactly the old programs' observable
  behaviour, which is now written down instead of silent.
* **Valid programs are unchanged.** The check adds diagnostics only: no
  HIR form, HIR text, interchange format, cache key, runtime
  representation or backend changed. The migrated programs make the same
  allocations, logical copies and detaches as before (section 15).
* **The repository's own code needed migration** (section 11). Nothing in
  `stdlib/`, `bench/` or `packages/` mutated a value parameter. Four
  example programs, one probe and the fuzzer preludes did, and so did a substantial
  share of the test programs: they tested value semantics by mutating a
  parameter and observing that the caller was unchanged. One golden test,
  `native-aggregates.bot`'s chunked builder, pinned a real dropped write
  (section 11.2); it now declares the intended `place`.
* **The frozen kickoff fixture was migrated too, at the user's direction**
  (section 11.4). Three of its programs mutated parameters; each now copies
  the parameter into a local before the first mutation. Every program's
  results and every warning's text are what the tree before the milestone
  printed for the unmigrated fixture, on all four backends; only positions
  moved. AGENTS.md now allows exactly this kind of edit.
* **Not migrated, by decision:** two research corpora (the hash-table
  experiment's implementations and the strict-reference-determinism
  experiment's variants). No test or workflow compiles them (section 11.4).

## 2. Starting semantics and reproduction

*Implementation fact.* Before this milestone, a parameter not declared
`place` was a place of its own function. `ReceiverProblem` and
`PlaceArgumentProblem` (hir/mutvec.tcl) admitted any binding whose kind is
`local` or `param`. Once a parameter was mutated it became a *place root*,
and the elaboration gave it a header of its own: `EntryRename` shared the
argument on entry, or the caller handed over a copy through the copy
convention's consumed parameters. MUTABLE-VECTOR.md stated it as a feature
(section 13, "A parameter is a place: the callee mutates its own copy").
The program compiled. The callee mutated its copy and returned normally.
The caller's collection stayed as it was.

The clean-room SimCity report survives only as the task's description
(the repository holds none of its sources). The three cases are therefore
reconstructed from that description and from the compiler's behaviour, as
the smallest programs with each failure's shape:

1. *A helper receives a struct's mutable array field as an ordinary
   parameter and sets into it*: `fn zone(tiles: MutableArray[int], i, kind)
   ... tiles.set(i, kind)`, called as `zone(m.tiles, 4, 2)`.
2. *`std::mutable_array::copy` with an incorrectly declared destination*:
   `fn blit(dst: MutableArray[int], src) ...
   std::mutable_array::copy(dst, 0, src, 0, 3)`, called as
   `blit(m.tiles, row)`.
3. *A module using `std::byte` calls `std::mutable_array::set` on its
   parameter*: an application module `pixels.bot` with
   `fn put_byte(buffer: MutableArray[std::byte::Byte], i, value) ...
   std::mutable_array::set(buffer, i, std::byte::from_int(value))`, called
   from the entry program.

*Observation* (the pre-change tree, `main.tcl -backend B`, each of
interp, compile, cranelift-generic and cranelift):

| case | value meant | old compiler, every backend | new compiler |
|---|---|---|---|
| 1 `zone` | 2 | `value: 0` (accepted) | NONPLACE-PARAMETER-MUTATION at 17:5 |
| 2 `blit` | `[5, 5, 0]` | `value: [0, 0, 0]` (accepted) | NONPLACE-PARAMETER-MUTATION at 17:30 |
| 3 `put_byte` | 200 | `value: 0` (accepted) | NONPLACE-PARAMETER-MUTATION at pixels.bot 5:29 |

The old compiler printed only an unrelated METHOD-ELIGIBLE warning. Each
write was lost, on every backend alike, which is why no differential test
noticed: the loss is the language's semantics, not a backend bug.

## 3. Architecture census

*Implementation facts*, read before any change:

* **Places** (hir/mutvec.tcl, MUTABLE-VECTOR.md, MUTABLE-ARRAY.md). A
  MutableVector or MutableArray is a value: a header over a copy-on-write
  backing. A mutation changes the header of the *place* it names. A place
  is a *place path*: a binding (local, parameter or context parameter of the
  same function) with zero or more field projections (`Path`). Collection
  elements are never places; element places (`-element-place`) exist only
  for an installed context's members.
* **Mutations** are exactly two kinds of call, both judged in
  `hir::mutvec::verify`:
  - a native whose receiver's ownership role is `place` (`OpKind` reads the
    registration, never a name). The public ones are std::mutable_vector's
    push, pop, take, swap and clear and std::mutable_array's set, swap and
    copy; the `#..._drop` forms are written later by the elaboration;
  - a call of a function with place parameters, for each place argument
    (`PlaceIndices`, `PlaceArgumentProblem`). std::mutable_map and
    std::mutable_set are ordinary Botlish over place parameters, so their
    operations are this kind.
* **Value parameters** are bindings of kind `param` in a function block's
  scope, listed in the block's `params` and absent from its `places`. Loop
  variables, a fold's intermediate and a handler's payload binding are
  also `param` bindings, but of a loop or branch scope. A context
  parameter is a `local` bound to `context#load` (`IsContextParam`).
* **Copies.** A binding's entry is a logical copy (`mutable_vector#share`)
  unless its value is fresh or `Moved`. `Moved` applies only to a binding
  the copy convention holds (a place root, a consumed parameter, a demanded
  local) at its path's last use. A parameter of a function also called
  through a function value is never consumed, so its local copy is always
  shared (section 8).
* **Lowering.** No backend knows places: every backend compiles the
  elaborated HIR, in which the copies are ordinary calls.
* **Existing diagnostics.** MUTABLE-PLACE-RECEIVER covers a temporary, a
  value of another kind, a module binding, a destructuring temporary and a
  binding of an enclosing function. MUTABLE-PLACE-CAPTURE covers a nested
  function referring to a place root. TYPE covers a place parameter's
  type.
* **Other writable storage, examined and out of scope.** MutableBytes is a
  value whose write returns new storage (MUTABLE-BYTES.md): no in-place
  mutation exists. NativeEdit stores to native memory behind a pointer,
  never to the parameter's own storage, under its own authority model
  (NATIVE-LAYOUT-WRITES.md). Consuming loops and moves are ownership
  transfers, not mutations.
* **Why mutations through ordinary parameters were accepted:** see
  section 2. It was a stated design decision, not an oversight in a check.

The production census (`audit/refactor/tools/gate.tcl`'s corpus and a scan
of every `.bot` file but the generated bindings) found mutations of value
parameters in examples, one probe and audit corpora, and none in
`stdlib/`, `bench/` or `packages/`. Every one was the value style: mutate
the parameter, then return it (section 11).

## 4. Precise language rule

> A mutation whose destination is a place path rooted in a **value
> parameter** -- a parameter of a function, not declared `place` -- is
> `NONPLACE-PARAMETER-MUTATION`. A *mutation* is a call of a native whose
> receiver role is `place` (its receiver is the destination), or a call
> giving an argument to another function's place parameter (that argument
> is the destination).

*Judgments* the rule encodes:

* **The destination's root binding decides, nothing else.** The rule never
  reads whether the parameter is later returned, read or passed on, its
  type, its callers, a name or a spelling. A mutation of a parameter the
  function returns is rejected too (task section 7): permission belongs to
  the function's contract, not to a later use an optimizer might see.
* **A local is a place of its own**, whatever it was bound from (section
  8). The rule does not taint values by origin.
* **Construct bindings are no parameters.** A loop variable, a fold's
  intermediate and a handler's payload belong to a loop or branch scope;
  a context parameter is a view of the installed context.
* **Existing receiver rules report first.** A temporary, an enclosing
  function's binding or a module binding stays MUTABLE-PLACE-RECEIVER: the
  check runs only on a destination those rules accepted.
* **It is an error, never a warning**, decided by the front end before any
  backend runs.

## 5. Direct mutation

`hir::mutvec::IsValueParam` answers the binding question (the parameter's
scope owner is a function block, the binding is one of its `params`, its
index is not in `places`). In `verify`, once `ReceiverProblem` accepts a
mutating native's receiver, the check reads the receiver's root binding
and reports `ValueParamMutation` inside `hir::CheckingCall`. Covered by
tests (`tests/nonplace-parameter-mutation.test`):

* `npm-direct`: the exact message, at 4:5;
* `npm-every-mutating-operation`: each of the eight operations, plus a
  registry census showing the tested list is exactly the public natives
  whose receiver role is `place`;
* `npm-call-spelling`: method spelling at 3:5, function spelling at 3:31;
* `npm-untyped-parameter`: the message suggests `place v: T`;
* `npm-returned-parameter`: mutating a parameter that is returned;
* `npm-every-site`: every site is reported, including a nested function's
  own parameter and a recursive function's;
* `npm-related-declaration`: located at the mutation, relating the
  parameter;
* `npm-numeric-looking-name`: parameters named `inf` and `nan` are named
  as written. The first version of the message chose its wording with
  `expr`'s `?:`, which reads such a name as a number;
  numeric-looking-names.test's source check caught it.

## 6. Nested and projected mutation

The destination is a place path, so a field path `city.grid.tiles` is
rooted in `city` (`npm-field-paths`: one level, two levels, several
collection fields of one struct). Reading immutable fields, a collection's
length and elements, or looping over one is no mutation
(`npm-field-reads`). A field path given to a place parameter is the same
mutation (`npm-place-argument`'s third site).

*Alias census (implementation fact).* Botlish has no reference, no
assignment and no element place outside contexts. Every way to name
writable storage is therefore a place path, whose root is a binding.
Binding a parameter to a local, destructuring it, or passing it to an
ordinary parameter makes an independent logical copy. Passing it to a
place parameter is a mutation and is checked. There is no second spelling
of a parameter-rooted destination for the rule to miss, and no construct
where the compiler cannot tell a parameter-rooted destination from an
independent local copy: the root binding is one or the other.

## 7. Calls and module boundaries

The place-argument check runs where `verify` checks a place parameter's
argument: after `PlaceArgumentProblem` and the overlap check accept it, a
root that is a value parameter is reported at that argument. So:

* `add(b, 1)` and `b.add(1)` inside `fn grown(b: Bag)` are rejected
  (`npm-place-argument`); a place parameter passed on is accepted;
* `fn both(place into: Bag, from: Bag)` mutates `into` and is rejected
  for `from` only (`npm-mixed-parameters`);
* std::mutable_map's `set` and std::mutable_set's `add` and `remove`, given
  a value parameter, are rejected; lookups only read and are accepted
  (`npm-stdlib-collections`);
* an imprinted function's value parameter is rejected, while its `place`
  version updates the caller's place in every specialization
  (`npm-imprinted`);
* across application modules, the module's own mutation is rejected in
  `lib.bot`, the entry program's argument in `main.bot`, and the accepted
  versions run on every backend (`npm-cross-module`,
  `npm-cross-module-accepted`, `npm-simcity-byte-module`);
* reading parameters and passing them to ordinary parameters is accepted,
  and so is mutating other storage, a local or a context member
  (`npm-reads-and-other-effects`).

*Method syntax.* The decision is the same for either spelling, because the
diagnostic is the call's own problem: a candidate it rejects is no
applicable candidate (METHOD-SUGAR.md). With one visible candidate the
method call reports NONPLACE-PARAMETER-MUTATION. With several (a file
importing both std::mutable_vector and std::mutable_array has two `swap`s)
it reports NO-APPLICABLE-METHOD, whose reason for the mutating candidate is
the full NONPLACE-PARAMETER-MUTATION text (`npm-method-several-candidates`).
MUTABLE-PLACE-RECEIVER has always behaved this way; the
`npm-not-the-calls-problem` mutant pins that the diagnostic is a candidate
problem.

## 8. Explicit local-copy semantics

*Implementation fact.* `w = v` binds a local. The local becomes a place
root when it is mutated, and its entry is a share of `v` unless `v` is
`Moved`. `Moved` holds only for a binding the copy convention holds, at its
path's last use, so the local is a header of its own either way:

* when the parameter is read after the copy, the entry is a real share,
  and the parameter still holds the argument (`npm-local-copy-read-after`:
  `[1, 3]`);
* when the copy is the parameter's last use and the function is only
  called directly, the convention consumes the parameter: the caller hands
  over its argument's last use, or a copy, and nothing is copied twice
  (`npm-local-copy-costs-nothing`: 1000 recursive pushes, 0 shares, 0
  detaches natively);
* when the function is also called through a function value, the caller
  hands its argument over uncopied, the parameter is not consumed, and the
  local's entry shares (`npm-local-copy-indirect`: both callers keep
  `[1, 2, 3]`).

Local mutation stays available for a field's copy (`tiles = c.grid.tiles`,
`npm-local-copy-of-field`), a destructured field (`npm-destructured-local`),
fresh storage built in loops and recursion (`npm-fresh-locals`), and a
function threading a local copy through its own recursion. The idiom needs
a new name, because shadowing a parameter (`xs = xs`) is a DUPLICATE
binding. No new syntax was needed.

## 9. Affinity and contexts

* **Affine parameters.** A place parameter is never affine
  (`PlaceParamProblem`), so for an affine parameter's mutation the message
  says only: move it into a local (`working = q`, a move), mutate the
  local, return it. The moved local runs, every element released once
  (`npm-affine-parameter`, and the fuzzers' affine `pass_q`/`fill`).
* **Context parameters** are no value parameters: a member of the
  installed context is mutated as before and seen by every function that
  shares it (`npm-context-parameter`; the `npm-context-parameters-too`
  mutant shows the test depends on it).
* **Loop variables and handler payloads** are construct bindings and are
  unaffected (`npm-construct-bindings`; mutant
  `npm-construct-bindings-too`).
* **Native memory** is untouched: NativeEdit and the FFI's out-parameters
  have their own authority model, and no parameter's storage is involved.

## 10. Diagnostics and compilerpedia

The message names the destination, the parameter, its function and why,
then the fix that fits:

```
the receiver of std::mutable_array::set is `city.grid.tiles`, a path of
`city`, which is value parameter "city" of paint, not a place parameter: a
parameter not declared `place` is the function's own copy of its argument,
not its caller's storage, so this mutation would change only that copy, and
the caller would never see it (declare `place city: City` if the caller's
storage must change; if a local working value is intended, copy it into a
local first -- `working = city.grid.tiles` -- and mutate the copy)
```

It never recommends `place` unconditionally: both fixes are named, the
local copy is the one to prefer when the caller only needs the result, and
an affine parameter gets only the move. The diagnostic's `related` origin
is the parameter's declaration.

* **Registration:** `hir::static::codes` (NONPLACE-PARAMETER-MUTATION
  NonplaceParameterMutation), `std::compiler::DiagnosticCode`, and
  `std::test`'s two code lists. The static-compile census classifies it as
  recoverable: a block whose body mutates a value parameter is rejected
  with that code (`npm-static-compile`, the whole golden suite).
* **Compilerpedia:** `error.nonplace-parameter-mutation`
  (compilerpedia/topics/errors-ownership.topic) has MEANING, WHY, LIKELY
  CAUSES and WHAT TO DO, two rejected and two accepted examples. These
  topics were updated where they called an ordinary parameter a place:
  `error.mutable-place-receiver`, `error.mutable-place-capture`,
  `concept.mutable-vector` (whose accepted example mutated a parameter),
  `concept.place-parameters` and `concept.values`.

## 11. Existing-code migration

### 11.1 Production and examples

| site | shape | classification | change |
|---|---|---|---|
| examples/stdlib/csv_chunked.bot `chunked_append(builder)`, `chunked_copy_chunks(final)` | mutate the parameter, return it | local working value | `updated = builder`, `filling = final` |
| examples/stdlib/csv_records.bot `ht_rehash_insert(dest)`, `ht_place(table)`, `ht_set(table)` | same | local working value | `updated = PARAM` |
| examples/stdlib/hashtable.bot the same and `ht_delete(table)` | same | local working value | `updated = PARAM` |
| examples/dfa/json/conformance.bot `unhex(out)` | same | local working value | `filled = out` |
| audit/compiler-service/probes/json/json_tokens.bot `scan(out)` (read by tests/native-library.test) | same | local working value | `tokens = out` |

Each change binds the local as the function's first statement and spells
every later use with it, so the parameter's only use is the copy's entry.
*Observation:* the three examples/stdlib programs' native allocation reports (total
allocations, MutableArray reads, writes, shares and detaches) and their
values on the interpreter and natively are identical before and after.
The header comments that explained the old pattern now explain the local.

### 11.2 A dropped write the census found in the tests

`tests/golden/native-aggregates.bot`'s chunked builder (from
tests/native-mutarray.test) had a `chunked_copy_chunks(chunks, index,
final, offset)` that copied every completed chunk into `final`, an ordinary
parameter. Its comment said: *"Writes into its parameter `final`: the
caller's array never sees it."* The suite pinned the consequence:
`mutarray-builder-5`, `-8` and `-100` expected the chunked builder's List
to differ from the persistent one (`[true, false, N]`). This is the SimCity
defect inside the repository. The function exists to fill its caller's
array, so it is classified *mutate caller storage*: it now declares
`place final: mutarray`, and the three tests expect `[true, true, N]` (the
builder now produces the right List at every size).

### 11.3 Tests, fuzzers, Compilerpedia

Test programs written to observe value semantics through a mutated
parameter were migrated to the same observation through an explicit local
copy, so every test keeps its name, its outcome and what it states:

* **Golden suites:** mutable-array, mutable-vector, compiled-values,
  validators-and-proofs, stdlib-namespaces, place-parameters and
  recursive-types (local copies; pinned `rejects_at` lines and one message
  line moved with the inserted statements), and native-aggregates
  (section 11.2).
* **Tcl tests** (found by a census run of every Tcl test file, duplicates
  included, with every NONPLACE-PARAMETER-MUTATION site logged, also in
  tests that compile leniently and still passed): mutable-vector,
  mutable-array, mutable-array-type, place-parameters, semantic-instances,
  stdlib-namespaces, refinement-values, diagnostic-recovery and
  native-mutarray (local copies); proven-bounds and vector-bounds (their
  program templates take `b0`/`w0`/`a0`/`t0`/`v0` and bind the old names
  as their first statement, so each body stays as written and each pinned
  line moves by one); hir-range, native-mod-lowering, mutable-map and
  native-tiny-leaf-inline (`place`). The last four are about one
  collection mutated in place across a recursion or a leaf and passed on
  unchanged. Their subject needs the parameter itself, and only `place`
  keeps it: a local copy would change what an induction proves (section
  16), whether a leaf is one statement, or what an allocation count
  measures. native-mutarray's chunked builder declares `place final`, as
  its golden port does (section 11.2). Two counts of DiagnosticCode cases
  moved from 139 to 140 (static-compile.test, golden-framework.test).
  The test descriptions that said "an ordinary parameter is a place of
  its own" now say that its local copy is.
* **Fuzzer preludes** (audit/mutable-vector, audit/mutable-array): every
  helper that mutated its parameter mutates a local copy (`w = v`). Their
  models already said "a callee's mutations change only its copy", so no
  expectation changed.
* **Compilerpedia:** `concept.mutable-vector`'s accepted example, a
  proof example (`proof.list-bounds`), `std::mutable_vector::pop`'s note,
  and the TYPE topic's rejected example (it showed a second diagnostic,
  NONPLACE-PARAMETER-MUTATION, beside the TYPE it is about).

The tests that state the replaced behaviour (`pp-parameter-as-place`,
`pp-diag-untyped-argument`, `mv-receiver-places`, ...) keep their
observable result. The original programs are this milestone's rejection
tests (`npm-place-argument`, `npm-untyped-parameter`, ...).

### 11.4 The frozen fixture, and what was not migrated

* **`audit/refactor/kickoff-corpus/`** (csv_chunked, csv_records and
  hashtable) is migrated. AGENTS.md used to forbid any edit of this frozen
  fixture, so the first commit left it as written.
  - The cost of not editing it: its three programs stopped at
    NONPLACE-PARAMETER-MUTATION. The CLI tests that read the fixture
    (`me-`, `fa-`, `oc-`, `mb-`, `pn-` and
    `sf-cli-backend-independent-*`) still passed, since the other programs
    still carry warnings. But they compared three fewer programs, and the
    fixture no longer held any SAME-RETURN-VALUE line (only csv_records and
    hashtable had them).
  - The user then directed the migration, and changed the rule: the fixture
    is edited when a language change makes one of its programs stop
    compiling, only as far as compiling again takes, keeping every warning
    and every result.
  - The edit: each of the nine functions copies its parameter into a local
    (`updated = table`, `filling = final`) right before its first mutation,
    and the code after the copy uses the local. Each parameter keeps its
    name, because SAME-RETURN-VALUE names a returned value by its alias
    root. A first attempt that renamed the parameter (`table =
    given_table`) changed `ht_delete`'s line to "the value of
    `given_table`".
  - The check: each of the eleven programs ran on all four backends with
    `-warnings default`, in the tree before the milestone (13dd290, the
    fixture unmigrated) and in this one. All 88 standard outputs and
    standard errors are identical, once the base tree's paths, the internal
    HIR ids in the compile backend's `type:` lines and the nine inserted
    lines' shifts are mapped. The 357 warnings located in the fixture (285
    METHOD-ELIGIBLE, 64 ONE-CHAR-STRING-LITERAL, 5 FIXED-ARITY-LIST-RETURN,
    3 SAME-RETURN-VALUE) keep their code and text. `hashtable.bot` is
    refused by cranelift-generic (NATIVE UNSUPPORTED struct-shape) in both
    trees alike.
  - The fixture's README.md records the edit under "Migrations".
* **`audit/hash-table/impl/*.bot`** (15 implementations) and
  **`audit/strict-reference-determinism/experiment/csv_records-*.bot`**.
  These are records of finished experiments, measured and reported as
  written. No test or workflow compiles them; `tools/mutant-catalogs.tcl`
  only applies their mutants' text, which still applies. Their tools would
  now report the rejection. The fix for each is the local copy of section
  11.1.

## 12. Backend consistency

The rule is a front-end check in `hir::check`, before any elaboration or
lowering, so every backend sees the same rejection: there is no backend
code for it. `npm-command-line` runs main.tcl with each of the four
backends and gets the same diagnostic line and exit status. `npm-executable`
shows `-emit-native-executable` refusing the program before anything is
emitted, and the `place` version's standalone executable printing the
updated length. Every accepted program in the test file and the golden
suite runs on interp, compile, cranelift-generic and cranelift, which must
agree.

## 13. Regression tests

* `tests/nonplace-parameter-mutation.test` (36 tests): sections 5 to 12,
  the three SimCity cases (original rejected, `place` updates the caller,
  local copy leaves it unchanged), and `npm-check-load-bearing`. That last
  test replaces `IsValueParam` by `return 0` and shows the rejected
  programs compiling and silently dropping their writes. Removing the
  check makes the key negative cases accepted again, with the defect's
  exact values.
* `tests/golden/nonplace-parameter-mutation.bot` (48 golden tests, all four
  backends; `audit/golden/tools/perturb.tcl`: every test fails with its
  verdict inverted and with its expectation altered): the source-observable half of the file, ported (fragment
  `audit/golden/migration/fragments/nonplace-parameter-mutation.tsv`,
  census `audit/golden/migration/census/nonplace-parameter-mutation.tsv`,
  manifest regenerated with `merge.tcl`, `-check` clean). Multi-module
  programs, main.tcl, executables, the native allocation report and the
  patched compiler stay Tcl-only, each with its census reason.

## 14. Fuzzing and mutation testing

* **Fuzzers.** The mutable-vector and mutable-array fuzzers gained a fault
  kind, `valueparam`: a nested function that mutates its own value
  parameter (push, set, or std::mutable_array::copy into it), returning the
  parameter or not, predicted NONPLACE-PARAMETER-MUTATION. Their preludes
  mutate local copies (section 11.3). *Observation:* mutable-vector seeds
  1, 2, 3 and 4 (the last under GC stress), 60 programs each, and
  mutable-array seeds 1 to 4 (4 under GC stress), 40 programs each: 0
  disagreements, every generated NONPLACE-PARAMETER-MUTATION fault
  predicted. (A run's program *i* is seeded with seed + *i*, so seeds 1 to
  4 overlap heavily; distant seeds are reported in section 17.) The
  mutable-map fuzzer, whose collections mutate through place parameters,
  seeds 1 and 2: 20 programs each, 0 failing.
* **Mutants.** `audit/nonplace-parameter-mutation/tools/mutants.txt` (12
  mutants, harness `mutate.tcl`). It covers: the rule removed; receivers
  only; place arguments only; whole bindings only; typed parameters only;
  place parameters, construct bindings or context parameters counted as
  value parameters; the diagnosis taken out of the call's own problems;
  the affine advice dropped; the related location dropped; the function's
  name dropped from the message. *Observation:* 12 mutants, 12 killed,
  each by a test its `!!` line names.
* **Existing catalogs.** `tools/mutant-catalogs.tcl`: every mutant of
  every catalog still applies (86 catalogs, 3001 mutants, 0 problems).
  The mutable-vector, mutable-array and mutable-map harnesses were run on
  every mutant that edits hir/mutvec.tcl: 38 of 38, 9 of 9 and 5 of 5
  killed. That includes the mutable-array mutant that removes parameter
  copies (`param-mutation-leaks`), now killed through the tests' local
  copies.

## 15. Performance

* **Compile time.** The check is a constant number of dictionary lookups
  and one `lsearch` over the enclosing block's parameters, made only at a
  mutating call. *Observation* (front end of four programs the change did
  not touch, best of three, ms, two rounds alternating the trees):

  | program | before | after | before | after |
  |---|---:|---:|---:|---:|
  | golden collection-iteration.bot | 9417 | 8948 | 8879 | 9682 |
  | golden value-identity.bot | 16569 | 15368 | 15176 | 16920 |
  | examples/games/2048/golden.bot | 6347 | 6169 | 6678 | 6919 |
  | golden mutable-map.bot | 20844 | 19979 | 22411 | 20995 |

  The differences are this machine's run-to-run noise (under 8% either
  way, with no direction): the check costs nothing measurable.
* **Run time.** Valid programs compile to the same HIR as before (the
  check adds nothing to it). The migrated examples' native allocation
  reports are identical before and after (section 11.1).
  `npm-local-copy-costs-nothing` pins that the idiom copies nothing at a
  parameter's last use.

## 16. Remaining limitations

* **Loop variables and handler payloads** are places of their own
  construct. `loop r in rows: r.push(x)` changes the loop variable's copy
  and never the iterated List's element, the same silent-loss shape. No
  parameter is involved and the task scopes the rule to parameters, so it
  is unchanged and documented (`npm-construct-bindings`). Extending the
  rule to them would be a separate decision.
* **Induction precision.** The induction analysis (hir/induction.tcl,
  hir-range.test) treats a bound read from a parameter as stable when the
  self call passes the parameter itself. A recursion that set into its
  parameter (length-preserving) and passed it on had a stable capacity
  bound. Written with a local copy (`w = a`, pass `w`), it loses the bound,
  because the analysis does not see `w` as the parameter's copy. Written
  with `place a` it keeps the bound. This is a loss of precision, not of
  soundness. The programs that had the shape (tests in hir-range.test and
  native-mod-lowering.test) now use `place`.
* **Method decisions with several candidates** report NO-APPLICABLE-METHOD,
  with the NONPLACE-PARAMETER-MUTATION text as the mutating candidate's
  reason (section 7), as MUTABLE-PLACE-RECEIVER always has.
* **The two unmigrated research corpora** of section 11.4 no longer compile.
* **No bypass is known.** Section 6's alias census found no second
  spelling of a parameter-rooted destination. If a later feature adds one
  (a reference, an element place outside contexts, a capture that may
  mutate), it has to state its own place rule. AGENTS.md's new section
  says so.

## 17. Files changed and verification commands

The rule: `hir/mutvec.tcl` (`IsValueParam`, `ValueParamMutation`, the two
checks in `verify`, the header). The code: `hir/static.tcl`,
`stdlib/compiler.bot`, `stdlib/test.bot`. Topics:
`compilerpedia/topics/errors-ownership.topic` and `concepts.topic`.
Documents: this report, `docs/INDEX.md`, `docs/PLACE-PARAMETERS.md`,
`docs/MUTABLE-VECTOR.md`, `docs/MUTABLE-ARRAY.md`, `AGENTS.md` (the "Value
parameters are never mutated" section, and the warning gate's rule for the
kickoff fixture), `audit/refactor/kickoff-corpus/README.md` and the
fixture's three migrated programs. Tests and tools: the new test
file, golden suite, fragment, census rows, names and manifest rows, the
mutation catalog and harness, and the migrations of section 11.

Verification (Tcl 9.0.1, `LANG=C.utf8 LC_ALL=C.utf8`):

```
tclsh9.0 tests/nonplace-parameter-mutation.test
tclsh9.0 tests/local.tcl tests/golden/nonplace-parameter-mutation.bot
tclsh9.0 audit/nonplace-parameter-mutation/tools/mutate.tcl
tclsh9.0 audit/mutable-vector/tools/fuzz.tcl -seed S
tclsh9.0 audit/mutable-array/tools/fuzz.tcl -seed S
tclsh9.0 tools/mutant-catalogs.tcl
tclsh9.0 tools/compilerpedia.tcl check
tclsh9.0 audit/refactor/tools/gate.tcl
tclsh9.0 audit/golden/migration/merge.tcl -names audit/golden/migration/tcl-names.txt -check 1
tclsh9.0 tests/local.tcl
```

*Observations* on this branch (a 4-core container; the first line is the
pre-change tree, `main` at 13dd290):

* `tests/nonplace-parameter-mutation.test`: 36 of 36; its golden suite: 48
  of 48 on all four backends, and `audit/golden/tools/perturb.tcl` makes
  every one of them fail, with its verdict inverted and with its
  expectation altered.
* The census run: `tests/local.tcl -all 1 -parts tcl -backends interp` (all
  268 Tcl test files, golden duplicates included), with every
  NONPLACE-PARAMETER-MUTATION site logged by a temporary hook (removed
  before committing). Each file it showed failing or carrying a site was
  migrated and run again (section 11.3), until the only sites left were
  the new test file's own rejections and main.tcl's reads of the frozen
  fixture, since migrated (section 11.4). A front-end pass over every golden suite under
  the same hook found the one site in mutable-vector.bot that its first
  rejection had hidden.
* `audit/nonplace-parameter-mutation/tools/mutate.tcl`: 12 of 12 mutants
  killed. The mutable-vector, mutable-array and mutable-map harnesses, run
  on their hir/mutvec.tcl mutants: 38, 9 and 5 killed.
  `tools/mutant-catalogs.tcl`: 86 catalogs, 3001 mutants, 0 problems.
* Fuzzers (section 14): 0 disagreements and 0 failing runs.
* `tools/compilerpedia.tcl check`: 1219 topics, 746 examples, 0 problems.
  `audit/refactor/tools/gate.tcl`: passed (the observed warnings are
  exactly the manifest), and `audit/refactor/tools/expect.tcl`: 32
  programs, 0 mismatches. `merge.tcl -check 1`: clean (13139 rows).
* `tests/local.tcl` (every golden suite on four backends through the
  front-end cache, every Tcl test on interp and compile, golden duplicates
  skipped): Tcl tests 8725 passed and 0 failed on interp, 8720 passed and
  0 failed on compile (2493 golden duplicates skipped each); 118 golden
  suites, 0 failed (interp 5637/5637, compile 5637/5637, cranelift-generic
  5545/5545, cranelift 5647/5647); 97 minutes with 4 jobs.
* CI on the branch (macos-arm64.yml and windows-x86_64.yml on the push;
  tests.yml, tests-arm64.yml and static-decisions.yml dispatched): see the
  branch's runs. Their verdict is reported where this report is handed
  over, not here.
