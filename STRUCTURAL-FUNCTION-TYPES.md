# Structural function types

## Outcome

Botlish now has a real structural function type,

```
Fn{args: [T1, T2], return: R, errors: [E1, E2]}
```

usable wherever a type annotation is (parameters and declared results, and
nested inside `List[...]` or another `Fn`), resolved to one canonical
internal form, and participating in ordinary static checking: subtyping,
joins, argument admissibility, and declared-error analysis. Exact native and
Block references keep their exact types and are now *refinements* of their
own structural contract:

```
exact callable identity  ({native NAME}, {block E ...})
        |  subtype (hir::types::structuralOf)
structural Fn contract   ({fn {args ... return ... errors ...}})
        |
       any
```

A join of two different compatible callables forgets only *which code runs*
and keeps the call contract, instead of collapsing to `any` or a bare kind.
On the canonical corpus:

- `bench/lex-strategy.bot`: `choose_classifier`'s `if` was `any`; it is now
  `Fn{args: [any], return: bool, errors: []}`, and so are
  `choose_classifier`'s result, the `classifier` binding and the callee of
  `classifier(c)` (whose result is now `bool`, was `any`).
- `bench/source-checks.bot`: the `checks` List was `list` (element `any`);
  it is now `List[Fn{args: [any], return: bool, errors: []}]`, the loop
  element `check` has that `Fn` type, and `check(c)` is `bool`.
- `bench/test-selection.bot`: `changed_a?` stays exactly `block(e55)/1 ->
  bool` and its direct call stays `callenv` -- unchanged.
- Both dynamic sites stay `callvalue`: the static `callvalue` census is
  **9 before, 9 after, the identical sites**. No devirtualization, finite
  target set, union type, `context` field or runtime representation change
  was added. Specialization keys never gain identity (every used instance
  label of all 8 canonical programs is identical before/after), and the
  generated machine code of the whole scalar-asm audit corpus is
  byte-identical.

Along the way this closed one pre-existing soundness hole in the
typed-callable escape audit (a callable *returning* a typed callable could
be erased through an untyped parameter, letting `take_byte` receive `9999`
-- see "Error contracts"/"Diagnostics" below and `fn-escape-returned-typed-
callable`), and made the Tcl compile backend able to carry a declared error
out of a generic call (reachable for the first time now).

Full regression (native built): **2704/2704 on interp and 2704/2704 on
compile, 92 test files, 0 failures** (baseline 2619/2619, 91 files).
Canonical benchmark parity: `bench/bench.tcl -runs 1` exit 0, no
disagreement on any of the 8 programs.

## Motivation

The dogfooding census (`HIGHER-ORDER-DOGFOODING.md`) showed exact callables
losing *all* callable information at the first join: `{native
is_tcl_alnum} ⊔ {block lenient_ident_char?}` was `any`, and a List of two
natives and two Blocks was the plain `list`. The compiler could only say
"exactly this function" or "some arbitrary value". The middle ground --
"some callable with this statically checked contract" -- is what structural
`Fn` represents, and exact callables are its refinements.

## Prior callable type lattice

Before this milestone (`hir/types.tcl`):

| form | meaning |
|---|---|
| `{native NAME}` | exactly native `NAME` |
| `{block E ARITY RESULT}` | a Block of block expression `E`, arity, call result |
| `block`, `native` | the bare runtime kinds (core types) |
| `any` | nothing known |

`lub` kept an exact type only for the *same* target; two different Blocks
joined to the kind `block`, two different natives to `native`, a native
and a Block to `any`. There was no type for "a callable with this
signature", no way to annotate a parameter as one, and error-bearing or
typed-parameter callables could never cross an erasure point at all
(`hir/callables.tcl` rejected every one).

## Surface Fn syntax

```
Fn{
    args: [T1, T2],
    return: R,
    errors: [E1, E2]
}
```

`surface::parser::FnType` (grammar in its own header comment):

- Named fields `args`, `return`, `errors`; **any order**, each at most once,
  normalized to one canonical order. (The existing type grammar has no
  ordering precedent; accepting any order and normalizing gives the one
  printed form without needing "misplaced field" diagnostics.)
- `args` and `return` are required.
- **Omitted `errors` means `errors: []`** (option A): exactly what an
  omitted `errors` clause means on a `fn` declaration today -- no declared
  error may escape. Omission never means "unchecked errors".
- Newlines inside the braces are free (the lexer already treats `{` like
  `(`/`[`); trailing commas allowed, as elsewhere.
- `Fn` is the one head name the type parser knows: `Fn[...]` (positional)
  and a bare `Fn` are syntax errors with their own messages.
- Surface representation: `{fn FIELDS}` -- `fn` is a keyword, so this pair
  can never be mistaken for an applied type `{NAME ARG}`.

Examples that now compile:

```
fn apply(predicate: Fn{args: [str], return: bool, errors: []}, value: str) -> bool:
    predicate(value)

fn pick(strict) -> Fn{args: [str], return: bool}:
    ...

fn count_where(xs: List[str], keep: Fn{args: [str], return: bool}) -> int:
    ...
```

## Canonical internal Fn representation

```
{fn {args {T1 ...} return R errors {E1 ...}}}
```

a two-element form whose second element is a dict with the fields always
in the order `args`, `return`, `errors` (`hir::types::MakeFn`, the only
constructor). Every field is always present after construction -- absence
is never significant past parsing. Types are compared as strings, so this
canonical order plus a canonical error set gives deterministic equality,
hashing (TypeId interning) and rendering.

### Arguments

An ordered list of canonical types, one per parameter; the list length is
the arity. Argument types are never cut by the aggregate depth bound:
widening a contravariant argument would make the contract *narrower*, not
over-approximate it. They are always declared types (or meets of declared
types), so the set is already finite.

### Return type

A canonical type, bounded like a Block result (`aggregateDepth`); past the
bound a whole `Fn` becomes `any` (a sound over-approximation).

### Error contracts

The declared, contractual error set: sorted, duplicate-free declared error
names (`lsort -unique`), so `[B, A, A]` and `[A, B]` are the same type.

### Future context extension point

Not implemented (no `context` field is accepted; the parser rejects it with
"the function type field "context" is not supported yet"). Adding it is
one more named entry in `MakeFn`'s dict (after `errors`), one more `switch`
arm in `FnType`, and one more clause in `FnMismatch`/`FnLub` -- never a new
positional form. Exact block contracts (below) are also a named dict, so an
inferred context would be recorded there the same way.

## Structural compatibility rules

`hir::types::subtype A B` for a structural `B` (`FnSubtype`, via
`structuralOf A`): equal arity, and

- **arguments contravariant**: each of `A`'s parameter types admits `B`'s
  argument type;
- **return covariant**: `A`'s return fits `B`'s;
- **errors**: `A`'s declared errors ⊆ `B`'s.

`any`, the bare kinds `block`/`native` and non-callables are never subtypes
of an `Fn` (a value of type `any` is "unknown", not "known callable, unknown
target").

### Argument contravariance

"Admits" is the repository's own declared-parameter admissibility,
`hir::range::ProvesValueAcceptedBy T (TypeFact T) PARAM` (`hir::types::
Admits`), not bare `subtype` -- because a structural argument type *is* a
declared parameter obligation: `List[T]`/`ImmutableSet[T]` stay invariant
exactly as for a declared parameter, and an integer domain contained in
another is admissible without a nominal parent. So `Fn{args: [int]} <:
Fn{args: [Byte]} <: Fn{args: [Nibble]}`, never the reverse.

### Return covariance

`ReturnFits`: `subtype` (covariant, consistent with how `lub` already joins
values -- `List[Byte] ⊔ List[int]` is `List[int]`) or admissibility (a
contained integer domain). `Fn{return: Byte} <: Fn{return: int}`.

### Error-set narrowing

`actual ⊆ expected`. `Fn{errors: [NotFound]} <: Fn{errors: [NotFound,
PermissionDenied]}`; the reverse is not.

## Type meet / GLB strategy

There was no meet operation; `hir::types::glb` is the smallest sound one
needed for argument joins:

1. equal types: that type;
2. one side admissible for the other: the narrower side (e.g. `glb(any,
   str) = str`, `glb(int, Byte) = Byte`);
3. both admissible for each other (equivalent domains): the same-base
   evidence union for core types, else the lexicographically smaller
   string -- deterministic and operand-order independent;
4. two core types of one base: their evidence union (`core::type::narrow`,
   the repository's existing "a value of both" operation);
5. anything else (different kinds such as `str` vs `int`, two unequal
   `List`/`ImmutableSet`/`Fn` types): **no representable meet** -- the join
   falls back.

`never` would be the sound meet of unrelated kinds, but it is deliberately
not produced (a contract no caller can ever satisfy is useless, and item 28
prefers the conservative fallback); no intersection-type system was added.

## Function LUB rules

`hir::types::lub`, for two callable types (exact or structural):

| case | result |
|---|---|
| same exact target (`{native A}` twice, block `E` twice) | that exact type (block results joined) |
| different exact targets / structural, representable | `FnLub(structuralOf A, structuralOf B)` |
| different arity, or an argument pair with no meet | previous fallback: the shared kind (`block`/`native`) or `any` |

`FnLub`: arguments `glb` pointwise, return `lub`, errors union (sorted).
It is an upper bound of both operands (`fn-law-lub-is-upper-bound`), so
`lub(ExactA, FnSuper) == FnSuper` when `ExactA <: FnSuper`. No finite set
of targets is kept: `Exact A ⊔ Exact B` is structural `Fn`.

**Symmetry** holds in every case (tested, including error sets written in
different orders). **Associativity** holds within the representable fragment
(tested on representative triples); in the *fallback* region the lattice is
deliberately approximate: with `A = block e1/1`, `B = block e2/2`, `C =
block e3/1`, `(A ⊔ C) ⊔ B = any` (the `Fn` of `A`,`C` has no single kind to
share with `B`) while `A ⊔ (C ⊔ B) = block`. Both are sound upper bounds;
making them agree would need `Fn` to also remember a runtime kind (an
intersection), which is out of scope.

## Exact Native refinement

`{native NAME}` is unchanged. Its structural supertype comes from the
native registry (`core::native::metadata`): its fixed arity, its
`-result-type`, no errors, and **every argument `any`**. This is a
deliberate reading of the registry, not a hand-coded signature: a native's
`-param-types` are *run-time-checked requirements* (the native validates its
own arguments on every call, raising `TYPE`, which is why a direct call of
a native with an `any`-typed argument has always been accepted), not static
proof obligations. Structural argument types are exactly static obligations,
and keeping that true is what lets the typed-callable escape audit decide
from a type alone whether a structural value still carries an obligation
worth protecting (see "Diagnostics" and `hir/callables.tcl`'s header):
mapping `-param-types` into `args` would make a native-derived
`Fn{args: [str]}` indistinguishable from a typed-Block-derived one, forcing
the audit either to reject erasure of harmless native joins (a regression
for ordinary programs, e.g. passing a native/Block join to `list::all?`) or
to accept erasure of typed-Block contracts (unsound).

Classification (51 natives with the test libraries loaded): 50 fixed-arity
natives all have a structural signature; `list` (arity `*`) has none -- no
variadic function typing was invented, so it keeps the old fallback
behavior.

## Exact Block refinement

`{block E ARITY RESULT}` is unchanged for a block that declares no parameter
type and no error. A block that does now carries its contract as a fifth
element:

```
{block E ARITY RESULT {args {T1 ...} errors {E1 ...}}}
```

built only by `hir::types::blockType` from the block node's own resolved
`declaredParamTypes` (untyped: `any`) and `declaredErrors` -- the one
authoritative declaration source; nothing is re-derived elsewhere. This
keeps `structuralOf`, `subtype` and `lub` pure functions of their type
arguments (they are called in many places with no HIR in reach), keeps
every exact type of one block one canonical string, and leaves every
existing untyped exact type (and every test pinning one) byte-identical.
`hir::types::show` does not print the contract (it is recovered from the
node: `hir::read::CanonicalBlockTypes` re-canonicalizes after parsing HIR
text). Exact types are not surface-spellable.

## Capturing Block semantics

An exact Block type names a **code target, not a closure object**:
"calling this value executes Block `E`, with whatever valid environment
this value carries". `test-selection.bot`'s `changed_a?`/`changed_b?` are
two closures of one `make_changed?` activation site and both are exactly
`block(e55)/1 -> bool`. Capture/environment is representation, not part of
the call contract, so a capturing Block's structural supertype is the same
kind of `Fn` as any other (`fn-accept-exact-capturing-block` passes two
different closures of one factory to one `Fn` parameter). Surface `Fn` has
no environment, capture list or identity field.

## Native signature derivation

`hir::types::structuralOf {native NAME}`: `MakeFn [lrepeat ARITY any]
RESULT-TYPE {}` from the registry; `""` for arity `*`. See "Exact Native
refinement" for why the arguments are `any`.

## Block signature derivation

`structuralOf {block E ARITY RESULT ?CONTRACT?}`: arguments and errors from
the contract (trivial contract: `any` × arity, no errors), return `RESULT`
-- the block's declared result type if it has one, else its inferred one
(`hir::types::Block`), never weakened for the structural view. Signatures
are never inferred from callers. A recursive function's signature names its
parameter/return/error types, never its own exact type
(`fn-accept-recursive`); a closure factory's contract is `Fn{..., return:
Fn{...}}` (`fn-accept-closure-factory`), rendering and equality bounded by
the aggregate depth (`fn-law-nested-return-bounded`).

## KeyType / specialization projection

Decision: **B, coarse projection** (the smallest behavior required).
`hir::specialize::KeyType` still erases an exact callable to its kind
(`block`/`native`), and projects a structural `Fn` to `any` (it has no one
runtime kind; `kindOf` is `""`). Specializing on a contract would multiply
instances without changing any operation's lowering (a call through either
is the same `callvalue`). A declared `Fn` parameter's contract still reaches
the instance's own body through its *declared-type seed* (`Analyze`'s M1
path adopts the declared type), never through the key. The full HIR type
keeps both identity and contract; the key is deliberately coarser.

Measured: every used instance label of all 8 canonical `bench/*.bot`
programs is identical before and after; two different Blocks passed to one
`Fn` parameter share `apply<block, str>` (`fn-specialization-shared-
instance`).

## Calling structural Fn values

`hir::types::Call`: a callee of structural type has no `target` (lowering
stays the indirect `callvalue` path; no instance is chosen, no target set
inferred), but the call is typed from the contract (its result is the
`return` type) and charged its declared errors (`calleeErrors`). Its
arguments are held to the contract's argument types by
`hir::range::VerifyStructuralCall` -- the identical admissibility proof a
direct call's arguments get, never a runtime check -- and a call with the
wrong number of arguments is a static `TYPE` error (a direct call of an
exact target with the wrong arity stays the run-time `ARITY` error it always
was). Exact callables still lower directly: native call, `call` for an
envless Block, `callenv` for a capturing one (`test-selection.bot` direct
call still `callenv`).

The AOT readiness report (`hir/aot.tcl`) classifies a structural callee as
an `indirect-call` of a `callable` (target unknown), not a `DynamicCall`
blocker ("native, block or not callable is decided at run time" is no longer
true of it). `lex-strategy.bot`'s `classify` goes from `open` to `guarded`
(its only blocker was that call), `valid_chars`/`total_valid` stop being
"transitively open".

## List[Fn] inference

`[a, b, ...]` is typed `List[lub(elements)]`, so a List of compatible
callables is `List[Fn{...}]`, and a `loop x in xs:` element has that `Fn`
type; `x(v)` type-checks from it and stays `callvalue`
(`fn-accept-list-inference`). A List of typed callables is
`List[Fn{args: [Byte], ...}]`, callable through its elements with checked
arguments (`fn-escape-typed-list`).

## Control-flow Fn joins

`if`/`else`, `return` joins, a function's implicit trailing value and loop
`break` joins all go through `lub`, so compatible callables join to their
`Fn` (`fn-accept-if-join`, `fn-accept-returned-fn`). Incompatible ones
(different arity, no argument meet) fall back exactly as before -- never to
an unsound `Fn` (`fn-reject-incompatible-join-falls-back`).

## source-checks before/after

Raw census: `audit/structural-function-types/out/{before,after}.txt`
(`audit/structural-function-types/tools/typecensus.tcl`, run in the
pre-milestone tree and this one; surface HIR and the bench pipeline's
re-lifted HIR give the same answers).

| boundary | before | after |
|---|---|---|
| List literal `[is_tcl_alpha, is_tcl_alnum, is_underscore?, is_hyphen?]` | `list` | `List[Fn{args: [any], return: bool, errors: []}]` |
| `checks` binding | `list` | `List[Fn{args: [any], return: bool, errors: []}]` |
| `check` loop binding | `any` | `Fn{args: [any], return: bool, errors: []}` |
| `check(c)` result | `any` | `bool` |
| `check(c)` call form | `callvalue` | `callvalue` |

(Inside the specialized instance `classify_leading<generic>` the element is
`Fn{args: [any], return: any, errors: []}`: region inference has always
typed a created Block's result `any` -- see "Known limitations".)

## lex-strategy before/after

| boundary | before | after |
|---|---|---|
| strict branch (`is_tcl_alnum`) | `native is_tcl_alnum` | `native is_tcl_alnum` |
| relaxed branch (`lenient_ident_char?`) | `block(e49)/1 -> bool` | `block(e49)/1 -> bool` |
| `if` expression | `any` | `Fn{args: [any], return: bool, errors: []}` |
| `choose_classifier` result | `any` | `Fn{args: [any], return: bool, errors: []}` |
| `classifier` binding | `any` | `Fn{args: [any], return: bool, errors: []}` |
| `classifier(c)` result | `any` | `bool` |
| `classifier(c)` call form | `callvalue` | `callvalue` |

Inferred contract: `Fn{args: [any], return: bool, errors: []}` -- `glb(any
(native), any (untyped c)) = any`, `lub(bool, bool) = bool`, no errors.

## test-selection before/after

| boundary | before | after |
|---|---|---|
| `make_changed?` returned type | `block(e55)/1 -> bool` | `block(e55)/1 -> bool` |
| `changed_a?` binding | `block(e55)/1 -> bool` | `block(e55)/1 -> bool` |
| direct `changed_a?("lib/web.bot")` | target `block e55`, `callenv` | target `block e55`, `callenv` |

Exact identity is preserved; nothing is eagerly widened to `Fn`.

## Error-contract tests

`tests/structural-fn-types.test`:

- `fn-errors-impl-none-declared-a`: emits nothing, declares `[A]` -> valid.
- `fn-errors-impl-a-declared-ab`: emits `[A]`, declares `[A, B]` -> valid.
- `fn-errors-impl-ab-declared-a`: may emit `[A, B]`, declares `[A]` ->
  compile-time error (the pre-existing `fail` admission rule, pinned).
- `fn-errors-narrower-satisfies-wider`: a callable declaring `[NotFound]`
  passes a parameter typed `errors: [NotFound, PermissionDenied]`; the
  error propagates through the structural call to the handler on every
  backend.
- `fn-errors-wider-rejected`: `errors [NotFound]` into `errors: []` is
  rejected, naming `NotFound`.
- `fn-errors-structural-call-propagates` / `-declared`: a call through an
  `Fn` with `errors: [NotFound]` is `UNHANDLED-ERROR` unless handled or
  admitted by the enclosing `errors` clause; when admitted it propagates at
  run time to an outer handler (interp, compile, cranelift, cranelift-
  generic, and both backends from the surface HIR).
- `fn-errors-join-union`: joining `[NotFound]` and `[PermissionDenied]`
  callables gives `errors: [NotFound, PermissionDenied]`; the joined call
  must handle both.
- `fn-errors-exact-call-keeps-narrower-set`: a callable that crosses a
  wider-contract boundary keeps its own narrower exact set wherever it is
  still exact (its direct call handles only `NotFound`).
- `fn-reject-extra-error`: an extra `PermissionDenied` is rejected.

Native error contracts: no registered native declares an error set (natives
never do), so native error-set coverage uses empty-error natives only (item
80); none was invented.

## Diagnostics

Mismatches name the incompatible part of the contract
(`hir::types::explainMismatch`, appended to the existing admissibility
diagnostic):

```
argument for parameter "f" cannot be proven to satisfy Fn{args: [str], return: bool, errors: []} (argument type: block(e7)/2 -> bool, facts: ...); arity mismatch: the callable takes 2 argument(s), the function type 1
...; argument 1 is incompatible: the callable's parameter requires int[Byte], but callers of the function type may pass any int
...; return incompatible: the callable returns any, not usable as bool
...; error set incompatible: the callable may raise PermissionDenied, but the function type allows only [NotFound]
...; a value of type int is not known to be callable
...; a value of type any is not known to be callable
argument 1 cannot be proven to satisfy int[Byte], the parameter type the callee's function type Fn{args: [int[Byte]], return: int, errors: []} requires (argument type: int, facts: [9999, 9999] {9999})
this call passes 2 argument(s) to a callable of function type Fn{args: [str], return: bool, errors: []}, whose contract takes 1
this call through a callable of function type Fn{args: [str], return: int, errors: [NotFound]} may produce the declared error "NotFound", which is neither handled here nor admitted by the enclosing function's own "errors" declaration
```

Syntax diagnostics (each pinned): missing `args`, missing `return`,
duplicate field, unknown field, `context` not supported yet, `target`/
`targets` not a field, `args` not a type list, `errors` not a name list,
a type in the `errors` list, a non-name error, a duplicate error name,
missing `:`, missing `,` between fields or list items, positional `Fn[...]`,
bare `Fn`. Unknown error names and unknown argument types are the ordinary
resolution diagnostics (now with the underlying reason appended).

The typed-callable escape audit (`hir/callables.tcl`) is structural-aware:

- a typed callable flowing into a position whose type is a structural
  supertype of it (a join, a declared `Fn` parameter/result, a `List[Fn]`
  element through `list`/`list_append`/`list_get`/`immutable_set_from_list`)
  is *not* an erasure: its obligations stay checkable (`Preserves`);
- a structural type that still carries an obligation (a non-`any` argument
  type or a declared error), a callable whose *result* carries one, and a
  List/ImmutableSet of them are themselves precondition-bearing (`Bearing`,
  now recursive): erasing one to `any`/an untyped parameter is rejected as
  before. The recursion is what closes the pre-existing hole
  (`fn chooser(): take_byte` passed to an untyped `apply` ran
  `take_byte(9999)`; now rejected);
- a declared `Fn` result type must preserve the returned callable's
  obligations;
- a returning loop's collected element (`loop x in xs: v`) is audited as a
  join into its List's element type -- new because Lists can now hold typed
  callables, whose element type the aggregate depth bound could otherwise
  cut silently (`fn-escape-returning-loop-element`).

Three `typed-callable-escape.test` cases that pinned "a join of two
different typed callables is rejected" now pin the structural behavior (the
join is accepted, and a call violating the typed side's contract is still
rejected -- at the call); a new case pins that an *incompatible* typed join
is still rejected.

## Static callvalue census

Relifted pipeline (as `bench/bench.tcl` compiles), every canonical
`bench/*.bot`:

| program | before | after |
|---|---:|---:|
| `lex-strategy.bot` | 2 (`list::all?@e18`, `classify@e119`) | 2 (same) |
| `refined-checks.bot` | 1 (`scan_while@e216`) | 1 (same) |
| `source-checks.bot` | 2 (`list::find@e42`, `classify_leading@e91`) | 2 (same) |
| `test-selection.bot` | 3 (`list::any?@e6`, `list::none?@e31`, `list::find@e42`) | 3 (same) |
| `uri-steady.bot` | 1 (`scan_while@e216`) | 1 (same) |
| others | 0 | 0 |
| **total** | **9** | **9** |

No change: this milestone improves type precision, not dispatch.

## Backend parity

- `tclsh9.0 bench/bench.tcl -runs 1` (native built): exit 0, no `VALUES
  DIFFER` on any of the 8 canonical programs.
- Every positive surface test in `tests/structural-fn-types.test` runs on
  interp, compile, cranelift-generic and cranelift through lowered core IR,
  plus compile and cranelift straight from the surface HIR (where declared
  `Fn` annotations are kept), and requires all six to agree.
- `native/generate-scalar-audit.tcl` into a scratch directory: every `.asm`
  and summary of the audit corpus is byte-identical to the committed one
  (only the README's recorded commit differs).
- Runtime: the native ABI (`fnvalue`, closures, native values, `callvalue`,
  `callenv`) is unchanged -- native `callvalue` already checks every result
  for a pending error. The one runtime edit is in the Tcl compile backend's
  generic call helper, `core::runtime::callValue`, which now re-signals a
  `propagate-error` completion as compiled code's own Tcl code 5 (what a
  direct call of a compiled block that `fail`s already returns) instead of
  raising "compiled code cannot yet propagate": an error-bearing callable
  can now legitimately reach a generic call. No object layout, stack root
  or allocation path changed, so GC-stress was not run (item 94).

## Full regression

```
LANG=C.utf8 LC_ALL=C.utf8 tclsh9.0 tests/all.tcl
```

with the native backend built (rustc 1.98.1, `cargo build --release
--manifest-path native/Cargo.toml`):

- before (this milestone's parent commit): interp **2619/2619**, compile
  **2619/2619**, 91 test files;
- after: interp **Total 2704, Passed 2704, Skipped 0, Failed 0**, compile
  **Total 2704, Passed 2704, Skipped 0, Failed 0**, **92** test files (the
  new `tests/structural-fn-types.test`, 84 cases, plus one new
  `typed-callable-escape.test` case).

Focused files while developing (interp and compile): `structural-fn-
types.test` 84/84, `typed-callable-escape.test` 36/36, `hir-aot.test`
32/32, `types.test` 16/16, `hir-types`, `hir-specialize`, `typed-
parameters`, `inference`, `errors`, `applied-types`, `hir-callable-
target`, `hir-samples`, `hir-resolution`, `list-stdlib` all passing.

Pinned expectations changed on purpose: `types.test` `type-7` (`{native +}
⊔ {native -}` is now `Fn{args: [any, any], return: int, errors: []}`, was
`native`), `hir-aot.test` `hir-aot-4`/`-5` (the joined callee's
`calleeKind` is `callable`, was `block`/`native`), and the three
`typed-callable-escape.test` join cases above.

## Known limitations

- **Native arguments are `any` in structural contracts** (see "Exact
  Native refinement"): a call through a native-derived `Fn` with an argument
  of the wrong kind is the same run-time `TYPE` error a direct native call
  with an `any` argument always was.
- **Instance-level precision**: specialization region inference types a
  created Block's result `any` (pre-existing), so inside a specialized
  instance a joined `Fn`'s return can be `any` where the semantic type says
  `bool` (e.g. `classify<str, bool>`).
- **List invariance** is unchanged: a declared `List[Fn{...}]` parameter
  accepts a `List[Fn{...}]` of the identical contract (or the empty List),
  not `List[native X]` merely because `native X <: Fn{...}`.
- **Bearing Lists and other natives**: a List of *typed* callables passed to
  a native other than `list`/`list_append`/`list_get`/
  `immutable_set_from_list` (e.g. `list_length`) is conservatively rejected
  as an erasure.
- **HOF helpers stay untyped**: `list::any?/all?/none?/find` and
  `web::scan_while` keep untyped predicate parameters. Typing them accurately
  needs "the predicate accepts the element type", i.e. type variables, which
  do not exist; `Fn{args: [any], return: bool}` would newly reject valid
  uses whose predicate result is not statically `bool`. Their internal
  predicate calls stay `callvalue` and keep their `DynamicCall` AOT blockers.
- **Meet** is only the admissibility order plus same-base evidence union;
  unrelated kinds have no representable meet (conservative fallback), and
  the fallback region is not associative (see "Function LUB rules").
- **Arity through `Fn` is static, direct arity is dynamic**: a wrong-arity
  call through an `Fn` is a compile error; a wrong-arity direct call of an
  exact target is still the run-time `ARITY` error it always was.

## Readiness for finite callable-target refinement

The pieces the next step needs are now in place and separated:

- exact identity is still carried wherever it is known (and still decides
  lowering through `target`);
- the one place identity is forgotten is `hir::types::lub`'s callable case
  (`FnLub`), which is exactly where a bounded target set could be kept as a
  refinement *of* the structural type it already computes;
- the structural contract a target set would refine is canonical, compared
  as a string, and extensible by named field;
- `KeyType` already erases both identity and contract, so a target-set
  refinement need not touch specialization keys;
- calls through a structural type are already typed, argument-checked and
  error-checked from the contract, so devirtualizing one to a finite set of
  exact targets changes lowering only, not static checking.

## Required architecture questions

1. **Before**: `{native NAME}`, `{block E ARITY RESULT}`, the bare kinds
   `native`/`block`, and `any`.
2. **Now**: `{fn {args {T...} return R errors {E...}}}` (`MakeFn`), fields
   named and in canonical order.
3. **Native signatures**: the native registry (`core::native::metadata`):
   arity and `-result-type`; errors empty; arguments `any` because
   `-param-types` are run-time-checked requirements.
4. **Block signatures**: the block node's resolved `declaredParamTypes`,
   `declaredErrors`, and its declared-or-inferred result type
   (`blockType`/`BlockContract`).
5. **Exact Native → structural**: `hir::types::structuralOf {native NAME}`.
6. **Exact Block → structural**: `hir::types::structuralOf {block E A R
   ?CONTRACT?}` (the contract is carried in the exact type when non-trivial).
7. **Capturing Block "exact"**: code target, not closure environment
   identity.
8. **Runtime callable representation changed?** No. (One Tcl-backend
   helper now forwards a declared-error completion from a generic call.)

## Required surface questions

9. `Fn{args: [T...], return: R, errors: [E...]}`, fields in any order,
   newlines allowed, trailing commas allowed.
10. Yes: `args`, `return` and `errors` are all represented.
11. Omitted `errors` means `errors: []` (no declared error may escape),
    matching `fn` declarations.
12. Yes (parameter annotation).
13. Yes (declared result annotation), and nested in `List[...]`/`Fn`.
14. See "Diagnostics": missing args/return, duplicate/unknown field,
    `context`, `target(s)`, non-list `args`/`errors`, types or non-names in
    `errors`, duplicate error, missing `:`/`,`, positional `Fn[...]`, bare
    `Fn`, unknown error/type names.
15. `context` was not implemented.

## Required compatibility questions

16. Arguments contravariant under declared-parameter admissibility.
17. Return covariant.
18. `actual errors ⊆ expected errors`.
19. Yes: fewer declared errors satisfies a contract allowing more.
20. No: an undeclared escaping error is rejected (`fail` admission, and
    `errors` subset for subtyping).
21. Yes, a native satisfies a compatible `Fn`.
22. Yes, an envless Block.
23. Yes, a capturing Block.

## Required LUB questions

24. `ExactNative[A] ⊔ ExactNative[B]` = structural `Fn` (e.g.
    `Fn{args: [any], return: bool, errors: []}`).
25. `ExactBlock[A] ⊔ ExactBlock[B]` = structural `Fn`.
26. `ExactNative[A] ⊔ ExactBlock[B]` = structural `Fn`.
27. Incompatible arity: no `Fn`; the previous fallback (shared kind or
    `any`).
28. Arguments: `glb` (meet), never a covariant lub.
29. Return types: `lub`.
30. Error sets: union, canonically sorted.

## Required dogfooding questions

31. `source-checks.bot` callable List: `List[Fn{args: [any], return: bool,
    errors: []}]`.
32. `check`: `Fn{args: [any], return: bool, errors: []}`.
33. `check(c)` still `callvalue`: yes.
34. `lex-strategy.bot` `if`: `Fn{args: [any], return: bool, errors: []}`.
35. Still widens to `any`? No.
36. `classifier`: `Fn{args: [any], return: bool, errors: []}`.
37. `classifier(c)` still `callvalue`: yes.
38. `test-selection.bot`'s returned closure stays exact: yes
    (`block(e55)/1 -> bool`).
39. Its direct invocation stays `callenv`: yes.

## Required specialization questions

40. Exact target identity entered specialization keys? No.
41. `KeyType` of an exact native/Block: its kind (`native`/`block`), as
    before.
42. `KeyType` of a structural `Fn`: `any`.
43. Two different code targets with the same signature share one
    specialization? Yes (`apply<block, str>` for two Blocks).

## Required error questions

44. A structural `Fn` call propagates its declared error set statically:
    yes.
45. An implementation may produce fewer errors than declared: yes.
46. An undeclared escaping error is rejected: yes.
47. Joining compatible function types unions their errors: yes.
48. Error-set renderings are canonical/deterministic: yes (sorted, unique).
