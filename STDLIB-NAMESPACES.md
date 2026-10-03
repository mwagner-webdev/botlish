# Standard namespaces: `eq` removed, intrinsics namespaced, `at`/`get`

A language/library cleanup milestone with four parts:

1. the obsolete `eq` string-equality native is gone (String equality is `==`);
2. every standard intrinsic that belongs to one value family lives in that
   family's flat namespace (`list::at`, `str::concat`, `mutable_array::set`,
   ...); the root keeps only language primitives;
3. the indexed `*_get` reads are split into `at` (fails with the declared
   error `IndexNotFound`) and `get` (an ordinary Botlish library function:
   `at` with that one error handled by returning an explicit, eagerly
   evaluated default);
4. a namespaced intrinsic cannot be redefined or overloaded by a module (or
   an entry program) of the same namespace; the rest of that namespace stays
   open.

A follow-up (§11) gave the writes and slices declared errors too
(`mutable_array::set`: `IndexNotFound`; `str::substring`,
`mutable_array::freeze`, `mutable_array::copy`: `LowerUnderrun` /
`UpperOverrun`), made `char::scalar_value` the one name of the UnicodeChar
to Int operation (`lib/char.bot` and `char::codepoint` are gone), and
removed the test-only index-obligation waiver. Where the sections below
describe the state before that follow-up, they say so.

No compatibility aliases were added: every historical name is simply
unbound now (`core::native::aliasPairs` is empty; `tests/stdlib-namespaces.test`
`ns-historical-names-are-unknown` checks each one).

## 1. `eq` is gone

`eq` was never a surface operator: the parser had no `eq` token,
precedence level or AST node (checked against the pre-milestone
`surface/*.tcl`). It was a root native callable as `eq(a, b)` (and as
`{ref eq}` in core IR), registered in `core/primitives.tcl`, and mapped to
an intrinsic in each executor. Removed:

| Where | What |
|-------|------|
| `core/primitives.tcl` | `proc stringEqual` and `core::native::register eq` |
| `compiler/compiler.tcl` | the `eq IntrinsicStringEqual` intrinsics entry and `proc IntrinsicStringEqual` |
| `native/lower.tcl` | the `eq {op streq}` natives-table entry |
| `README.md` §1/§8 | the `eq` paragraph and table row (§8 now says `==` is the one equality operator, Strings included) |
| tests | `tests/calls.test`'s eq tests became `eq-removed-1/2` (`==` on Strings; `{ref eq}` is UNBOUND); `tests/argv.test`, `tests/native.test` no longer call or define `eq` |

After the change `eq(a, b)` is an ordinary unbound name (`UNBOUND`), `a eq b`
is a syntax error (`found name "eq"`), and `==` is String equality: exact
scalar-value comparison, no cross-kind coercion (`"10" == 10` is `false`)
-- `ns-eq-*` and `ns-string-equality-is-double-equals`.

Retained, deliberately: the internal NIR op `streq`, the Rust `Op::StrEq`
and runtime entry `rt_str_eq` (`native/src/nir.rs`, `codegen/clif.rs`,
`runtime/ops.rs`, `hir/stringregion.tcl`). They are how `==` itself is
lowered when both operands are proven Strings -- internal equality
machinery of `==`, never reachable by a name in source. No
`string_eq`/`StringEq`/`OP_EQ_STRING` identifiers existed.

## 2. The root namespace

### Inventory and classification

Every root native before the milestone, and where it is now
(`core::native::names`; `tests/stdlib-namespaces.test` `ns-root-inventory`
and `ns-qualified-inventory` pin the after-state in a fresh process):

| Before (root) | Classification | After |
|---------------|----------------|-------|
| `+ - * < <= > >= ==` | language primitive (operators) | root, unchanged |
| `mod bit_and bit_or bit_xor shift_left shift_right` | language primitive (the operators' named Int siblings) | root, unchanged |
| `list` | language primitive (what `[a, b]` calls) | root, unchanged |
| `integer? string? list? mutarray? ok? error?` | language primitive (kind/tag tests the type system refines on) | root, unchanged |
| `result-value result-error` | language primitive (core-IR-only Result accessors) | root, unchanged |
| `hash` | language primitive (the structural hash `==` agrees with; any value) | root, unchanged |
| `argv` | platform/process primitive (ARGV.md) | root, unchanged |
| `eq` | historical leftover | **removed** (§1) |
| `length substring lowercase concat encode_utf8 is_tcl_alpha is_tcl_alnum` | standard type op (String) | `str::*` |
| `list_length list_get list_append` | standard type op (List) | `list::length`, `list::at`, `list::append` |
| `mutable_array_allocate _capacity _get _set _copy _freeze` | standard type op (MutableArray) | `mutable_array::allocate/capacity/at/set/copy/freeze` |
| `immutable_set_from_list immutable_set_contains` | standard type op (ImmutableSet) | `immutable_set::from_list/contains` |
| `char_codepoint` | standard type op (UnicodeChar; the primitive behind `lib/char.bot`'s existing `char::codepoint`) | `char::scalar_value` (the follow-up removed the `char::codepoint` wrapper, §11) |
| `linux::abi::syscall` | platform-ABI, already qualified | unchanged |

Source-declared types still register their constructor/predicate natives at
the root for the duration of one compilation (`hir/sourcetypes.tcl`); those
are user names, not standard intrinsics. Internal-only natives (the test
harness's `test-log`/`test-tick`) are registered by `tests/helpers.tcl` only.

Why the primitives stay at the root: each is either an operator spelling,
the target of syntax (`list` for `[...]`), a kind test the type system
refines on (`integer?` narrows its argument), a Result accessor that only
core IR can spell, or a whole-language operation not owned by one family
(`hash` and `==` take any value). `argv` is the process boundary, not a
String or List operation. `mod`/`bit_*`/`shift_*` are the named Int
siblings of `+ - *`; Botlish has no `int::` family and the milestone does
not invent one.

### Namespaces

Flat and named after the value family, no `std::`/`stdlib::`/`core::`
hierarchy (`ns-no-nested-stdlib`):

| Namespace | Intrinsics (qualified root natives) | Library members (`lib/*.bot`) |
|-----------|-------------------------------------|-------------------------------|
| `str` | `length substring lowercase concat encode_utf8 is_tcl_alpha is_tcl_alnum` | none (no module file) |
| `list` | `length at append` | `get` (new), `find any? all? none?` ... (existing `lib/list.bot`) |
| `mutable_array` | `allocate capacity at set copy freeze` | `from_list create` (moved from the old `mutarray` module), `get` (new) |
| `immutable_set` | `from_list contains` | none |
| `char` | `scalar_value` | none (no module file since §11) |
| `linux::abi` | `syscall` | (unchanged) |

`lib/mutarray.bot` was renamed to `lib/mutable_array.bot` (`namespace
mutable_array`): one family, one namespace. `mutarray::create`/`from_list`
are now `mutable_array::create`/`from_list`; `mutarray::` names nothing
(`ns-historical-module-is-gone`).

### Old name to new name

```
eq                       (removed: use ==)
length                   str::length
substring                str::substring
lowercase                str::lowercase
concat                   str::concat
encode_utf8              str::encode_utf8
is_tcl_alpha             str::is_tcl_alpha
is_tcl_alnum             str::is_tcl_alnum
list_length              list::length
list_get                 list::at            (+ list::get with a default)
list_append              list::append
mutable_array_allocate   mutable_array::allocate
mutable_array_capacity   mutable_array::capacity
mutable_array_get        mutable_array::at   (+ mutable_array::get with a default)
mutable_array_set        mutable_array::set
mutable_array_copy       mutable_array::copy
mutable_array_freeze     mutable_array::freeze
mutarray::from_list      mutable_array::from_list
mutarray::create         mutable_array::create
immutable_set_from_list  immutable_set::from_list
immutable_set_contains   immutable_set::contains
char_codepoint           char::scalar_value
char::codepoint          char::scalar_value  (§11; the lib/char.bot wrapper is gone)
```

### How a qualified intrinsic resolves

The mechanism is the one `linux::abi::syscall` already used: a *qualified
root native*, registered under its qualified name
(`core::native::isQualifiedNative`). `surface/lower.tcl` lowers a reference
`str::concat` to a root reference to that native (`hir::syntax::rootRef`);
the module loader does not look for a module member of that name. From HIR
on, a call's target is `native str::concat` -- the same resolved identity
every analysis keys on (hir/containers.tcl rules, hir/cardinality.tcl,
hir/exactvalue.tcl, hir/stringregion.tcl, native/lower.tcl's natives
table, the Tcl compiler's intrinsics table). Every one of those keyed sites
was renamed; none was given a second key. No AST node changed; HIR and NIR
have no new node or op (the NIR ops `listget`, `listappend`, `strcat`,
`mutarrayset`, ... are what they were, only reached from the qualified
names).

A namespace with intrinsics but no module file (`str`, `immutable_set`) is
loadable for its intrinsics; an unknown member is reported against them:
`namespace "str" has no definition "reverse" (its members are the
intrinsics: concat, encode_utf8, ...)`, and for a namespace with both, the
list names module definitions and intrinsics together
(`ns-unknown-member-*`).

Canonical printing and diagnostics use the qualified names everywhere:
runtime messages (`str::substring: slice start 5 is above the length 2`,
`list::length: expected list, got "abc"`), contract inference (`argument 1
of native str::length requires str`), completion diagnostics (`this call
of "list::at" may produce the declared error "IndexNotFound"`), AOT
explanations (`natives: ==, *, list::at x3`), NIR comments
(`ns-diagnostics-name-the-qualified-callable` checks a run-time and a
static one).

## 3. `at` and `get`

### Found and converted

Indexed `*_get` reads before the milestone: `list_get` and
`mutable_array_get`. Both are converted:

```
list::at(xs: List[T], index: Int) -> T                errors IndexNotFound
list::get(xs: List[T], index: Int, default: T) -> T
mutable_array::at(a: MutableArray[T], index: Int) -> T errors IndexNotFound
mutable_array::get(a: MutableArray[T], index: Int, default: T) -> T
```

Botlish has no type variables to write those signatures down; they are what
the compiler infers. `at`'s result is the element type the container
carries (`ns-at-element-type`: `List[int]` gives `int`); `get`'s is the
element type joined with the default's (`ns-get-element-type`:
`list::get([1, 2], 5, 0)` is `int`, `list::get([[1], [2, 3]], 1, [])` is
`List[int]`). Neither is an optional or null type.

Not indexed `*_get`s, reported and left alone:

* `immutable_set::contains` -- membership, a total Boolean, not a read;
* `list::find` (`lib/list.bot`) -- a predicate search failing with
  `NotFound`, not an index;
* `result-value`/`result-error` -- Result accessors (core IR only);
* struct field projection `.f` -- static, checked at compile time;
* `str::substring` -- a range slice, not a lookup (its failures became
  `LowerUnderrun`/`UpperOverrun` in §11); there was never a `string_get`,
  and no `str::at` was added (non-goal: new collection semantics);
* the corpus program's `ht_get`/`ht_find_get` (`examples/stdlib/hashtable.bot`,
  `csv_records.bot`) -- a user program's key lookup returning `unit` for
  absence, not a standard API.

### `IndexNotFound`

One builtin declared error, `IndexNotFound`, declared once
(`core/native.tcl`, `core::native::declareError`, beside
`InvalidArgumentEncoding`), visible to every program without a
declaration, with the fixed native id `0x40000001`
(`native/src/runtime/error.rs` `ERR_INDEX_NOT_FOUND`). Both `at`s declare
exactly it (`-errors IndexNotFound`; `ns-at-signature`).

`at` fails with `IndexNotFound` for every Int that does not designate an
element: past the end, negative (no negative indexing: `-1` is not "the
last"), and any BigInt. A non-List/non-MutableArray or non-Int argument is
still the ordinary `TYPE` error, never `IndexNotFound`
(`ns-at-other-failures-are-not-index-not-found`). Unhandled at run time
(only reachable in a `-strict 0` build) it is the ordinary uncaught
declared error, `UNCAUGHT-ERROR: uncaught propagated error: <error
IndexNotFound>`, identical on every backend. (`mutable_array::set` now
fails with the same `IndexNotFound`, and the slices with `LowerUnderrun`/
`UpperOverrun`: §11.)

### `get` is ordinary Botlish

`lib/list.bot` and `lib/mutable_array.bot`:

```
fn get(xs, index, default):
    value = list::at(xs, index):
        on IndexNotFound:
            default
    value
```

(`mutable_array::get` is the same over `mutable_array::at`.) It is not a
native, not an intrinsic and has no op of its own: its HIR is a `handle`
node around the native `at` call, its NIR an ordinary call
(`ns-get-is-ordinary-botlish`, `ns-get-nir-is-an-ordinary-call`).

* **Only `IndexNotFound` is consumed.** The handler names that one error; a
  `TYPE` failure of `at` (a non-List argument) propagates out of `get`
  unchanged (`ns-get-handles-only-index-not-found`).
* **The default is eager.** It is an ordinary argument, evaluated once
  before the call whether or not the index is present -- no thunk, no lazy
  default (`ns-get-default-is-eager` counts the evaluations of a
  side-effecting default; the fuzzer checks the same per generated call).
* **`get` is `at` plus a handler, exactly.** `ns-get-differential` runs
  `list::get(xs, i, d)` and the explicit program `v = list::at(xs, i): on
  IndexNotFound: d` on the interpreter, the Tcl compiler and native
  (generic and specialized) for present, missing, negative and BigInt
  indices; the fuzzer repeats that on random inputs.
* **No obligation at the call.** `get` handles the error itself, so a `get`
  call never needs a handler (`ns-get-has-no-obligation`).

Bootstrap: `get` lives in the namespace whose intrinsic it calls. Inside
`lib/list.bot`, `list::at` is the qualified intrinsic -- the module cannot
define a member named `at` (§4), so nothing can shadow it, and `get` cannot
recurse into itself through it (`ns-list-module-beside-intrinsics`).

### Static obligations of `at`

`at` declares `IndexNotFound`, so the existing completion rules apply to it
like to any error-declaring function: a call must be handled, admitted by
the enclosing function's `errors` clause, or proven unable to fail;
otherwise `UNHANDLED-ERROR` at compile time. A call that can *never*
succeed under the facts proven for its arguments is `KNOWN-ERROR` ("this
call of "list::at" can never complete normally ... a handler does not make
a statically known failure legal"). Top level declares no errors.

The completion walk (`hir/completions.tcl`, `NativeEffectiveFacts` /
`IndexBounds`) proves an `at` call in range from facts the compiler already
has, nothing speculative:

* a container of statically known size (a literal, an exact value through
  immutable bindings, an exact List argument in a call-specific walk, a
  `MutableArray` from `mutable_array::allocate(n)`, `create(n, d)` or
  `from_list(xs)` -- `hir/cardinality.tcl`'s new `Capacity` and `cap`
  atom) and an index whose range lies in `0..N-1`;
* a counted loop `loop i from 0 to list::length(xs):` (or `to
  mutable_array::capacity(a)`, or a lockstep/inclusive form) reading
  `list::at(xs, i)` -- the loop variable is bounded by exactly the
  container's size form;
* an enclosing branch: `if i < 0 or i >= list::length(xs): ... else:
  list::at(xs, i)`, the `and` form's then branch, early returns, and
  `if list::length(b) == 2: list::at(b, 1)`. `and`/`or` conditions (lowered
  to nested `if`s) are decomposed into their conjuncts for both the range
  narrowing and the relational facts (`Conjuncts`). When the relational
  proof holds, a call-specific walk whose exact ranges would put the index
  out of range has found an unreachable path, and the read stays proven
  (`ns-proof-relations-before-call-ranges`);
* `mod(x, m)` with a divisor of bounded magnitude ranges over `0..m-1`.

Relational facts are scoped like the range facts they accompany: a guard
established inside a loop body or a handler (which may run zero times, or
only on the failing path) is dropped when that scope ends
(`ns-proof-relations-do-not-outlive-their-scope`); only an early exit at
the level of the read itself carries its condition forward.

`ns-proof-*` cover each rule and the unsound neighbours (an `or` in the
then branch, a missing `i >= 0`) that must stay rejected.

### Handled-call typing fix

Typing a handled call whose handler yields a different type than the call
(`v = list::at(xs, i): on IndexNotFound: "missing"` over a `List[int]`)
used the call's type for the whole expression inside semantic instances, so
native code could compare a String as an Int (a crash reproducible on the
pre-milestone tree with any user-declared error). `hir::types::Handle` now
takes the join of the call's type and every live handler's type unless the
handler's is a subtype (`ns-handle-type-in-an-instance`).

## 4. Protecting intrinsics

Representation: none new. A namespaced intrinsic is a registered qualified
root native; protection is the membership test
`core::native::isQualifiedNative NS::MEMBER`. `surface/modules.tcl`'s
`CheckNativeMembers` rejects a function or immutable binding named MEMBER in
any module file of namespace NS (`LoadNamespace`) and in an entry program
that itself declares `namespace NS` (`CheckEntryProgram`, called from
`compileProgramFile` and `surface::lowerToHir`). This generalizes the check
that already protected `linux::abi::syscall`. The diagnostic:

```
SURFACE MODULE DUPLICATE-NATIVE: module "list" (.../list.bot) cannot define
"at": list::at is a compiler-provided intrinsic (a root native registered
under that qualified name), which every reference of that spelling
denotes; it cannot be redefined or overloaded (other members of namespace
"list" are unaffected)
```

Protection is per member, not per namespace: `lib/list.bot` defines
`list::get` beside the intrinsic `list::at`; a user library directory's
`str.bot` may define `str::reverse` but not `str::length`
(`ns-protect-module-member`, `-binding`, `ns-unrelated-member-is-legal`,
`ns-protect-entry-program`). A local name `at`, `length` or `concat` in an
ordinary program is unrelated to the intrinsic (`ns-local-names-are-unrelated`):
local names cannot contain `::`. There is no overloading: a same-named
definition with a different arity is rejected the same way
(`ns-protect-is-not-overloading`).

## 5. Method spelling

Nothing method-specific was added. The existing rule (METHOD-SUGAR.md)
applies to intrinsics as to any namespaced function: `x.f(a)` is `f(x, a)`
when `f` is visible, and a namespaced function becomes visible by binding
it (`at = list::at`). `ns-method-*` check that `xs.at(i)`, `xs.get(i, d)`,
`xs.append(v)`, `xs.length()`, `s.concat(t)`, `s.length()`,
`s.substring(i, j)`, `set.contains(v)`, `c.scalar_value()` and their fully
qualified free spellings give the same value on every backend and resolve
to the same call target (`sameCallable`: the very native, or the very
library block); `ns-method-mutable-array` does the same reads and writes
through `a.set`/`a.at`/`a.get`; `ns-method-nir-identical` checks the method
and free spellings lower to identical NIR. Without a binding the method
spelling is the usual "no function named ... is visible"
(`ns-method-requires-a-binding`). No backend changes were made for methods.

## 6. Interpreter and native resolution

* Interpreter (`core/`): the natives are registered under their new names
  (`core/lists.tcl`, `strings.tcl`, `tclcompat.tcl`, `mutarray.tcl`,
  `immutableset.tcl`, `unicodechar.tcl`); `list::at`/`mutable_array::at`
  fail through `core::native::failDeclared IndexNotFound`.
* Tcl compiler (`compiler/compiler.tcl`): its intrinsics table is keyed by
  the qualified names; `eq` removed.
* Native (`native/lower.tcl`): the natives table and every name-keyed rule
  renamed; the `listget`/`mutarrayget` runtime entries
  (`native/src/runtime/ops.rs`) report out-of-range indices as the declared
  error `ERR_INDEX_NOT_FOUND` instead of `RANGE`. The inline list-read fast
  path is unchanged: its slow path is the same runtime call
  (`native-listget-fast-5/6`: identical outcomes with it on and off).
* `hir/*`: rename of keyed names; new proof rules (§3); `Handle` typing fix.

## 7. Migration

* `lib/`: `list.bot` (+`get`), `mutable_array.bot` (renamed module, +`get`),
  `char.bot` (removed in §11), `byte.bot`, `web.bot` (renamed calls; `esc_bytes` guards
  its index with `i < 0 or i >= list::length(bytes)`, which proves its
  read).
* Corpus (`examples/stdlib`): renamed throughout. Programs whose functions
  index records positionally without a proof declare `errors IndexNotFound`
  and handle it once at the sample: `matmul` (`dot`, `product_row`,
  `product_rows`, `matmul`), `hashtable` and `csv_records`
  (`sample_checks` + a handling `sample`), `csv_chunked`. Their expected
  values are unchanged. `examples/stdlib/corpus.tcl` gained
  `corpus::handled`/`corpus::driven` so a driver calling such a function at
  top level is wrapped in a handler only when it needs one.
* `bench/`, `examples/surface`, `audit/**/probes`: renamed; method
  spellings got bindings; incidental top-level reads use `get` or a
  handler. `bench/source-checks.bot`'s data strings that *mention* old
  names were deliberately left as data.
* Tests: renamed throughout; expectations naming old natives or `RANGE`
  for out-of-range reads updated. Programs that index incidentally were made
  legal the way real code would be (a proof-friendly guard, a handler, an
  `errors` clause, `get`); five test files whose subject is types/facts
  rather than error legality compiled through a test-only waiver
  (`compileWaivingIndexObligations`), which §11 removed.
* Fuzzers: `audit/{elif,flags,method-sugar,same-return-value,short-string,struct-destructuring}/tools/fuzz.tcl`
  generate the qualified names and no `eq`; historical audit instruments
  under `audit/*/tools` were renamed mechanically where they named a
  removed intrinsic (they are not part of the suite and were not re-run).
* Documentation: README §1, §8 (rewritten: primitives, intrinsics, library
  members, `at`/`get`, the protection rule) and the other sections' names;
  METHOD-SUGAR.md; the lib headers. Earlier milestone reports (`*.md` other
  than these) are historical records and keep the names they were written
  with.

Accounting changes caused by the migration (measured, documented at each
test): `csv_geometric`/`csv_records` gain two generic representation
blockers from the unused library function `mutable_array::get` in the
module they load; `csv_records`/`hashtable` gain one generic-only instance
(`sample_checks`); hir-aot's matmul driver runs inside `corpus::handled`
(one more region); matmul's blocker lines moved by three; every program
calling `uriEscape` gains one generic blocker and its kind guard
(`esc_bytes`'s new `i < 0` comparison on an untyped parameter).

## 8. Fuzzer

`audit/stdlib-namespaces/tools/fuzz.tcl` (`-n N -seed S`): random Lists
(Ints, Strings, nested, empty) with in-range, past-the-end, negative and
BigInt indices and random defaults, as programs whose expected values an
independent Tcl oracle computes, on every backend: `get` free and method
spelling; `get` versus the explicit handler program; `at` through handled
calls; the same for `mutable_array::from_list` with `at`/`get`/`set`;
eager-default counting; `str::`/`list::` operations free and by method.
Each program is followed by a rotating negative that must be rejected:
`a eq b` (syntax), `eq(a, b)` and a historical name (unbound), an entry
program of an intrinsic's namespace defining that member with arity 1
(`DUPLICATE-NATIVE`, whatever the intrinsic's own arity), a literal
out-of-range `list::at` (`KNOWN-ERROR`), an unprovable unhandled one
(`UNHANDLED-ERROR`), an unbound method spelling, and `list::get` on a
String (its `TYPE` error propagates through `get` at run time). `tests/stdlib-namespaces.test`
`ns-fuzz-smoke` runs a bounded instance in the suite.

## 9. Validation

* Full suite, `interp` and `compile` backends (each file run separately):
  10198 tests; the one failing file (`native-report-inlined-leaf.test`, the
  uriEscape accounting of §7) was updated and re-run with every test file
  changed after the run started: 310/310 (pre-milestone baseline: 10094
  tests, 0 failures). The new `tests/stdlib-namespaces.test` has 60 tests.
  The last analysis change (relational-fact scoping) postdates that run;
  the cranelift run below, which compiles every test program through the
  same analysis, covers it.
* Full suite on `cranelift` (`CORE_BACKEND=cranelift`, what
  `tests/native-coverage.tcl` classifies): 5100 tests, 60 failing -- the
  same 60 tests, by name, that fail on the pre-milestone tree (5047 tests;
  constructs the native backend reports unsupported, such as returning a
  Block to the host). No new failure.
* `BOTLISH_NATIVE_GC_STRESS=1` over `stdlib-namespaces`, `native-mutarray`,
  `lists` and `argv` (interp): 186 tests, 0 failures; the suite's own
  GC-stress tests (struct, syscall, raw-loop, argv, list fast path) pass in
  every run above. The full GC-stress job runs in CI on push.
* `cargo test --release` (native/): 180 passed, including the new
  `indexed_reads_fail_with_index_not_found`.
* CI's example steps: `main.tcl -backend interp`, `-backend compile`, and
  the cranelift corpus/surface/HIR set all succeed. Compiler warnings on
  every corpus, surface, bench and audit-probe program are identical to the
  pre-milestone tree (75 programs compared).
* Fuzzer: `fuzz.tcl -n 200 -seed 1`: 200 programs, 200 values, 200
  negatives, 0 oracle disagreements, 0 negative escapes, 0 backend
  disagreements. The fuzzer was checked to fail: with `list::get` broken to
  ignore index 0 it reports oracle disagreements; with the member
  protection disabled it reports a negative escape. (Its first 200-program
  run found a generator bug -- a stored value of another kind than the
  array's element type, which the compiler correctly rejects -- fixed in
  the generator.)
* The relational-proof scoping fix was checked the same way: with the
  scope restore stubbed out, `ns-proof-relations-do-not-outlive-their-scope`
  accepts the two unsound programs.

## 10. Remaining debt

* `mutable_array::allocate` keeps its `RANGE` for a negative or impossible
  capacity (it is neither a lookup, a write nor a slice), as do the other
  remaining `RANGE` sources: `str::is_tcl_alpha`/`is_tcl_alnum`'s
  one-scalar requirement, shift amounts, refined-type constructors and the
  native backend's collection-size ceiling (§11).
* `argv` and `hash` stay root primitives (process boundary; any-value
  hash). If a `process::`/`value::` family ever exists they could move.
* Positional-record and positional-slicing corpus programs (`csv_records`,
  `hashtable`, `csv_chunked`, `matmul`; since §11 also `csv`,
  `ai_text_clean`, `string_replace`, `string_reverse` and the CSV slicing
  of `csv_geometric`/`csv_records`) declare the errors through their call
  chains: their proofs need interprocedural facts (a record's fixed length
  across a call, a scan index below a length established by the caller),
  which the completion walk does not do.
* The Tcl compiler (`compile` backend) routes every native with declared
  errors through its generic call (`core::runtime::callValue`), so a slice
  or a write the completion proof has made obligation-free still pays the
  generic call there; the native backend is unaffected.
* Historical audit instruments were renamed but not re-run; earlier
  milestone reports keep the old names.

## 11. Follow-up: write and slice errors, `char::scalar_value`, no test waiver

### Writes: `IndexNotFound`

`mutable_array::set(a, i, v)` declares `IndexNotFound`, with exactly
`at`'s rule: it stores at `0 <= i < capacity` and fails for every other Int
(past the end, negative, BigInt). A write is not a lookup, but an index
that designates no slot is the same fact for both, so they share the error
and its proofs (`ns-mutable-array-set-is-index-not-found`, `mat-run-7`).

### Slices: `LowerUnderrun` and `UpperOverrun`

Two more builtin declared errors, after `IndexNotFound` in
`core::native::declareError` order: `LowerUnderrun` (native id
`0x40000002`) and `UpperOverrun` (`0x40000003`;
`native/src/runtime/error.rs` `ERR_LOWER_UNDERRUN`/`ERR_UPPER_OVERRUN`).
The slicing intrinsics declare exactly those two:

```
str::substring(s: Str, start: Int, end: Int) -> Str  errors LowerUnderrun, UpperOverrun
mutable_array::freeze(a, count: Int) -> List[T]       errors LowerUnderrun, UpperOverrun
mutable_array::copy(dst, ds: Int, src, ss: Int, count: Int) errors LowerUnderrun, UpperOverrun
```

The one slice rule (`core::native::checkSlice`; native `check_slice` in
`runtime/ops.rs`): a slice `START..END` of a sequence of `N` elements is
valid iff `0 <= START <= END <= N`. START is checked first, against
`0..N`, then END against `START..N`; a bound below its interval is
`LowerUnderrun`, above it `UpperOverrun`. Consequences, decided once for
all three natives:

* an inverted slice (`END < START`, START itself valid) is `LowerUnderrun`:
  END is below its interval;
* a START past the end is `UpperOverrun` whatever END is
  (`substring("abc", 4, 1)`);
* `freeze(a, n)` is the slice `0..n`; a negative count is `LowerUnderrun`;
* `copy` checks its destination slice `DS..DS+COUNT`, then its source slice
  `SS..SS+COUNT` (memmove semantics within one array are unchanged); a
  negative COUNT is `LowerUnderrun`;
* BigInt bounds follow the same comparisons (no truncation).

`ns-slice-rule-substring` and `ns-slice-rule-freeze-and-copy` pin every
case on every backend, BigInts included; `cargo test`'s
`slices_fail_with_lower_underrun_or_upper_overrun` pins the runtime's own.
The string-region fast path (`rt_str_region_check`) uses the same check, so
a slice consumed as a region fails exactly like a materialized one
(`region-bounds-*`, `blockescape-region-companion-bounds-error-*`).

### Proofs

The slices get the same three-way completion proof as `at`
(`hir/completions.tcl` `SliceFacts`): each of a slice's two checks is ruled
out on its own, so a call may need only one of its two errors handled; a
check that provably fails is `KNOWN-ERROR`. Sizes come from
`hir/cardinality.tcl`, which gained a String length atom (`slen`) and
`StrLength`: an exact String, `str::concat` (the sum of its operands'
lengths), `str::lowercase` (length-preserving) and a `substring` (`end -
start`). Branch facts gained minimum sizes (`if str::length(s) > 0:`, `==
0` false), which also apply to a plain Int binding (`if n > 0:` over an
array created with capacity `n`). `ns-slice-proofs` covers literals, an
index guard, a counted loop, a minimum length, lengths through `concat`,
capacities and the unsound neighbours.

The shape of each native's check is registered with the native, not keyed
by name in the pass: `core::native::register`'s new `-bounds` option
(`index FAMILY C I` for `list::at`, `mutable_array::at`,
`mutable_array::set`; `slices {FAMILY C START END}...` for the three
slicing natives, with `{const K}` and `{sum A B}` operands), validated
against the native's `-errors`. `hir/completions.tcl` reads it from the
registration, which keeps the PARAMETERIZED-MUTABLEARRAY.md fence
(`mat-id-4`: no name-keyed rules in `hir/`) intact.

### `char::scalar_value` is the one name

`char::codepoint` (`lib/char.bot`, a typed wrapper) is removed and
`lib/char.bot` with it; `char::scalar_value` is the operation's only name.
A "code point" also names surrogates and, colloquially, the numbers of
other encodings (Latin-1); a Unicode scalar value is exactly what a
UnicodeChar holds. `char::codepoint` is now an unknown member of `char`
(`ns-char-scalar-value-is-canonical`), `lib/byte.bot` calls
`char::scalar_value`, and the method spelling is `c.scalar_value()`.
Behavior change: the wrapper's parameter was statically typed, so
`char::codepoint(65)` was a compile-time contract error; like every
native's parameter types, `char::scalar_value`'s `UnicodeChar` is checked
when the call runs, so `char::scalar_value(65)` is the run-time `TYPE`
error (`str::length(5)` behaves the same way). An untyped Botlish
parameter forwarded to it is still inferred `UnicodeChar` and checked
statically at its own call sites.

### No test waiver

`tests/helpers.tcl`'s `compileWaivingIndexObligations` is gone. Every test
program that can fail with a declared error now handles it (by name, with
the handler's value asserted, which is what lets these tests become Botlish
tests later), declares it on its function, proves it impossible with a
guard real code would use, or -- where the test's subject is the failure
itself -- asserts the declared error by name (`uncaught propagated error:
<error UpperOverrun>`, identical on every backend). Tests that used a
statically certain failure to reach a run-time error now take the failing
input as data, because a certain failure is a compile-time `KNOWN-ERROR`
(`vc-str-error-*`, `mat-run-7`); `native-executable-runtime-error` uses an
impossible allocation, which is still a run-time `RANGE`.

### Where `RANGE` remains

`mutable_array::allocate` (negative or too large capacity),
`str::is_tcl_alpha`/`is_tcl_alnum` (an argument that is not one scalar),
`shift_left`/`shift_right` amounts, refined-type constructors
(`core/type.tcl`), and the native backend's collection-size ceiling. None is
a lookup, a write or a slice.

### Migration

* `lib/web.bot`: `char_at` guards its slice with `if i < 0 or i >= n:
  return ""` and `esc_from` with `if i < 0 or i >= str::length(text):` --
  the early-return form, which keeps the string-region companion (an
  if/else form lost it and materialized every character as a String,
  about 10K more String allocations in the allocation tests).
* Corpus: `csv`, `csv_geometric`, `csv_records`, `csv_chunked`,
  `ai_text_clean`, `string_replace`, `string_reverse` and `hashtable`
  declare the slice/write errors their unproven positions need and handle
  them once at the sample, like §7's `IndexNotFound` (expected values
  unchanged). `examples/05-refined-strings.ir` guards its prefix with a
  length test.
* `bench/lex-strategy.bot` and the audit probes (`adv1`, `adv2`,
  `emailish-local-copy`, `hof-capturing`, `hof-two-exact`) guard their
  slices; `mutarray-typed` freezes by `mutable_array::capacity(a)` (same
  value).
* Tests: as above; expectations that named `RANGE` for a slice or a write
  now name the declared error, and accounting tests record the measured
  effect of the new guards at each test (`native-report-inlined-leaf`:
  `esc_from` +1 blocker, each `char_at` instance -1; `hir-specialize`,
  `hir-aot`: one more generic `sample` instance per program that gained
  one).

### Validation

* Full suite, each test file run separately: `interp` 5110 tests, 0
  failures; `compile` 5110 tests, 0 failures (4 skipped); `cranelift`
  5110 tests, 60 failing -- the same 60 test names as on the pre-milestone
  tree (§9). New tests: `ns-bounds-are-registered`,
  `ns-proof-binding-minimum`, `opt-native-1b`,
  `blockescape-region-companion-bounds-error-2`, `region-bounds-handled-1`,
  besides the slice/write tests listed above.
* `cargo test --release` (native/): 181 passed, including
  `slices_fail_with_lower_underrun_or_upper_overrun`.
* `BOTLISH_NATIVE_GC_STRESS=1` over `stdlib-namespaces`, `native-mutarray`,
  `mutable-array-type`, `native-string-region`, `virtual-construction`,
  `lists` and `argv` (interp): 387 tests, 0 failures.
* Fuzzer `-n 200 -seed 1`: 200 programs, 200 values, 200 negatives, 0
  oracle disagreements, 0 negative escapes, 0 backend disagreements. With
  `checkSlice` broken to report an inverted slice as `UpperOverrun` it
  reports 12 oracle disagreements in 60 programs.
* CI's example steps (`main.tcl -backend interp`, `-backend compile`, the
  cranelift example set) succeed. Compiler warnings on the 75 corpus,
  surface, bench and audit-probe programs are identical to the
  pre-milestone tree, and so are their diagnostics.
