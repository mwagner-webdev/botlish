# Refinement values: `refined type` and `proves`

```
refined type Emailish = str

fn emailish?(value: str) -> bool proves value: Emailish:
    ...

fn consume(value: Emailish) -> int:
    str::length(value)

fn example(s: str) -> int:
    if emailish?(s):
        consume(s)          # accepted: the true edge proves s an Emailish
    else:
        0

fn bad(s: str) -> int:
    consume(s)              # TYPE: expected Emailish but found str:
                            # a refinement proof is required
```

> A refinement is a nominal fact attached to an existing value. Proof may
> strengthen the static view; forgetting may weaken it; neither operation
> changes the value itself.

A **refinement type** is a new nominal type over exactly one *carrier* type:
its values are exactly the carrier's values that a proof says satisfy its
proposition. A **proof-producing function** is an ordinary `-> bool` function
whose declaration says what its true result proves about one argument. The
compiler learns refinement facts from control flow over such calls, lets a
refined value flow wherever its carrier is expected (*forgetting*, ordinary
subtyping), refuses the reverse direction without a proof, and -- separately
-- decides a repeated identical call of a *repeatable* proof-producing
function from the result the first call already established on the path.

At run time nothing exists: a refined value is its carrier's value, with the
carrier's representation, equality, hashing, rendering, storage, GC behavior
and ABI. The feature is entirely static.

This milestone replaces the previous machinery, in which `Emailish` and
`UriQueryValue` were Tcl-registered named types (`lib/web.tcl`) with
compiler-registered type-test natives, runtime *evidence* attached to Strings
by a trusted native, and a native-to-module-function bridge that made the
Botlish `web::emailish?` stand in for the Tcl root native. All of that is
deleted (see "Source audit"). `lib/web.bot` now declares both refinements and
their predicates in ordinary Botlish, and no compiler or runtime file names
them.

## Syntax

```
typeDecl     = "type" IDENT "=" IDENT "in" domain NEWLINE
             | "refined" "type" IDENT "=" typeExpr NEWLINE
function     = { functionModifier } "fn" IDENT "(" [ paramList ] ")"
               [ "->" typeExpr ] [ proofClause ]
               [ "errors" IDENT { "," IDENT } ] ":" suite
proofClause  = "proves" IDENT ":" typeExpr
```

* `refined` is **contextual**: it is a declaration modifier only directly
  before `type` at the start of a top-level statement
  (`surface::parser::AtRefinedTypeDecl`); `refined = 1`, `refined(x)`, a
  parameter or field named `refined` keep their meaning. Anywhere else before
  a declaration it is a syntax error naming the one thing it modifies.
* `proves` is **contextual**: it is recognized only after the result type (or
  the parameter list) and before `errors`/`:` in a function header, a position
  where no other construct allows a name. Everywhere else it is an ordinary
  name (`proves = 1`, a parameter `proves`, `x.proves()`).
* A refinement declaration has exactly one carrier and nothing after it: no
  `in` domain (that is an integer domain, declared without `refined`), no
  `&`/`|`/second carrier. It is a top-level declaration only.
* A function has at most one proof clause, naming one parameter and one type.
  The clause is a list of clause dicts in the AST and HIR (outcome, parameter,
  type), so several parameters or other outcomes can extend the list without
  changing the node shape; this grammar admits exactly one, for the `true`
  outcome.

## Representation

**AST.** `refined type NAME = CARRIER` is a `typedecl` node with `form
refined`, `name`, `nameSpan`, `refinedSpan` (the modifier), `carrier` (a type
expression, the same form a parameter annotation parses to) and
`carrierSpan`; an integer domain is the same node kind with `form domain`. A
function node gains `proves`: `{outcome true param NAME paramSpan SPAN type
TYPEEXPR typeSpan SPAN span SPAN}` clauses (empty without a clause).
`surface::ast::format` prints both back (`refined type X = C`, ` proves p:
T`), and `hir::syntax::withProofs` carries the clauses onto the HIR syntax
`block` node.

**Type registry** (`core/type.tcl`). A refinement is a named type registered
with `-refinement {carrier TYPE owner NAMESPACE span SPAN}`: its canonical
identity (`web::Emailish`, the module's path-derived namespace plus the
declared name, as for every source-defined type), its carrier as a canonical
type, the exact declaring module (`""` for the entry program) and the
declaration span. Its base is the carrier's base and its parents are the
carrier's own named types, so the type `{refined str {web::Emailish}}` sits in
the existing named-type lattice: subtyping, `lub` and `narrow` need no new
rule. A refinement has no validator, no integer domain and no runtime
membership test; `core::type::validate` of a refinement checks only that the
value is a value of its carrier. `core::type::isRefinement`, `refinementOf`
and `refinementName` read it back. The declaration is registered by
`hir/sourcetypes.tcl` (`RegisterRefinement`) with the other source-defined
types, per compilation, and unregistered with them.

**HIR.** The program's HIR keeps its type declarations; HIR text prints a
refinement as

```
refined type web::Emailish carrier str owner web
```

(`owner -` for the entry program), and a block with a proof contract as
` proves BINDING NAME: TYPE` on its block line. `hir::read` reads both back,
re-registering the refinement with its original owner, so a program read back
from HIR text keeps its proofs and runs the same
(`refinement-hir-text`, `refinement-hir-round-trip-runs`).

## Namespaces, imports and the owner

A refinement is an ordinary namespace type member: `web::Emailish` is its
canonical identity, usable qualified anywhere and by its short name after
`import type web::Emailish`, exactly like `type Byte = Int in 0..255` in
`lib/byte.bot` (`refinement-module-identity`).

The **owner** is the exact module whose source declares the refinement, as a
canonical namespace, recorded once in the registry entry. Only a function
declared in that exact module may carry `proves x: R`. `hir/resolve.tcl`
(`ResolveProofs`) compares the owner with the namespace of the module the
function is declared in; imports, parent namespaces and child namespaces
grant nothing (`REFINEMENT-MINT-AUTHORITY`), and the entry program owns its
own refinements. Because the owner is part of the registered declaration, not
derived from whoever imports it, a cached module's declaration keeps its owner
when two different modules import it (`refinement-import-grants-no-authority`,
`refinement-child-namespace-grants-no-authority`,
`refinement-two-importers-cannot-mint`, `refinement-owner-entry-program`).

As with opaque structs, the owner *defines* what its refinement means: the
compiler does not check that `emailish?`'s body matches any notion of an
e-mail address. The soundness theorem is that code outside the owner cannot
forge the fact: the only way to obtain a value statically typed `Emailish` is
a true result of one of the owner's proof-producing functions (or a value
already typed `Emailish`: a parameter, a field, a result).

## Carriers

`hir::sourcetypes::RefinementCarrierEligible(T)` decides, and its reason is
the diagnostic (`REFINEMENT-CARRIER`):

1. `T` is a concrete value type (not `any` or `never`);
2. `ValueStability(T)` is empty: every value of `T` is transitively
   immutable. A `MutableArray` (reference semantics), anything that can
   reach one (a List or set element, a struct field), a callable and `any`
   are not. This walks the type's structure, never a name: a struct named
   `MutableThing` with an `int` field is stable, `List[MutableArray[int]]`
   is not (`refinement-carrier-reaching-mutable`, `refinement-carrier-struct`);
3. this milestone's representation restriction: the carrier is a core
   scalar type -- `str`, `int`, `bool`, `UnicodeChar` (or `unit`) -- or an
   integer domain or a refinement over one. A stable aggregate (`List[str]`)
   is reported as stable but not supported yet; a struct carrier (including
   `abi::bytes::Bytes` and `abi::bytes::MutableBytes`) is rejected before
   struct types resolve, as "refinements of struct values are not supported
   yet".

`refinement-carrier-eligible` declares and uses refinements of `bool`,
`UnicodeChar`, `int`, the integer domain `byte::Byte`, `str` and of another
refinement. An unknown carrier is a `TYPE` error naming it.

**Chains.** A refinement may refine a refinement (`refined type Encoded =
Query`); its parents are the carrier's named types, so `Encoded ⊑ Query ⊑
str` and forgetting is transitive. Declarations resolve depth-first
(`hir/sourcetypes.tcl`'s `Resolve`), so a carrier may be declared later in
the same module. A chain that returns to itself -- `refined type A = A`,
`A = B` with `B = A` -- is `CYCLIC-REFINEMENT`, naming the chain (`"A" is its
own carrier through A -> B -> A`). There is exactly one carrier per
refinement, so no multiple inheritance.

## Forgetting, strengthening and joins

**Forgetting** is subtyping: `core::type::subtype` compares the named-type
*closures*, and a refinement's closure contains its carrier's. A refined
value is admissible wherever its carrier (or its carrier's carrier) is
expected -- parameters, results, struct fields, list elements, operators --
with no HIR operation, no NIR instruction and no runtime work. There is no
`forget`/`refineview` node to erase: the distinction exists only in static
types, which code generation reduces to the carrier's kind.

**No implicit strengthening.** A carrier value is never admissible where a
refinement is required. The admissibility diagnostic says why:

```
argument for parameter "a" cannot be proven to satisfy str[A] (argument type: str);
expected A but found str: a refinement proof is required (a str value becomes
A only where one of its owner's proof-producing functions has returned true for
it; there is no implicit conversion)
```

There is no cast, `as`, `assume` or unsafe refine.

**Joins** (`hir::types::lub`, unchanged machinery): the named types both
sides' closures share, minimized.

| join | result |
|---|---|
| `Emailish`, `Emailish` | `Emailish` |
| `Emailish`, `str` | `str` |
| `Mail`, `Query` (siblings over `str`) | `str` |
| `Encoded`, `Query` (`Encoded = Query`) | `Query` |
| `Encoded`, `Mail` | `str` |

A List literal or collecting loop mixing a refinement and its carrier is a
`List[str]` through the same lub (`refinement-list-elements`): nothing is
List-specific. `narrow` (proving a second refinement of the same value) is the
union, not minimized: a value proven `Mail`, `Query` and `Encoded` shows as
`str[Encoded,Mail,Query]`.

## Proof-producing functions

```
fn emailish?(value: str) -> bool proves value: Emailish:
```

means: whenever this invocation returns `true`, the argument passed for
`value` satisfies `Emailish`. The function is otherwise an ordinary
`bool` function: same arity, same call, same ABI, `x = emailish?(s)` is an
ordinary `bool` (`refinement-proof-arity-abi`).

**Validation** (`hir/resolve.tcl`, `ResolveProofs`; each a located
`PROOF-CLAUSE` diagnostic unless noted):

* the clause names one of the function's ordinary parameters ("the function
  has no parameter `t` (its parameters: s)");
* the proven type resolves (else `TYPE`, unknown type) and is a refinement
  ("the proven type ... is str, which is not a refinement type");
* the function's module is the refinement's owner (`REFINEMENT-MINT-AUTHORITY`);
* the parameter declares a type, and that type forgets to the refinement's
  carrier ("proof carrier mismatch: parameter "s" is declared int, but A
  refines str"); a proof can only strengthen what the parameter already is;
* the function declares `-> bool`.

**HIR proof metadata.** The resolved contract is the block's `proofs`: a list
of `{outcome 1 param INDEX binding PARAM-BINDING fact TYPE}` -- the outcome,
the parameter's position and BindingId, and the refinement type. Nothing in
it is a name. `hir::refine::ProofRules` turns it into the same `INDEX TYPE`
rule shape a native's `-refines-true` metadata has, so the consumers do not
care where a rule came from.

## Facts: what a call implies

`hir/refine.tcl`'s `Implication HIR CTX E` is what a typed Boolean
expression implies on each outcome: `{1 SET 0 SET}`, a SET being a fact set
or `never`. A fact set holds two kinds of keys:

* **refinement facts**: BindingId -> a type the binding's value is proven to
  have on this edge;
* **exact predicate-result facts**: `call BLOCK IDENTITY...` -> `1` or `0`,
  the result of that exact invocation: this proof-producing function on
  these argument values. `IDENTITY` is `hir::exact::Identity`: the immutable
  binding the argument denotes after following aliases, or an exactly known
  value.

A call of a function with a proof contract implies, on the true edge, the
contract's refinement for the argument (when the argument is a plain
reference: the binding and, for an immutable alias, the binding it aliases --
one value) and `key = 1`; on the false edge, only `key = 0` -- never a
negative refinement, because `proves` is a sufficient condition, not an
iff. A decided call (below) makes its other outcome `never`.

Implications compose:

* **Boolean bindings**: an immutable binding records the implication of the
  value it was bound to (the inference context's `implies`), and a reference
  to it implies the same thing: `ok = emailish?(s)` then `if ok:` proves what
  `if emailish?(s):` would; `ok2 = ok` copies it (`refinement-boolean-binding`).
  This belongs to the value and the binding, not to a syntactic pattern.
* **`not`, `and`, `or`** are lowered to Boolean `if` expressions, whose
  implication is, per outcome, the facts true on *every* path that produces
  that outcome (`refinement-not-and-or`; `p(s) or unrelated` proves nothing,
  `refinement-or-needs-both`).
* **handled calls** (`ok = p(s): on E: ...`) meet the call's implication with
  each handler's.

**True-edge propagation.** `hir/types.tcl`'s `If` applies the condition's
implication to each branch: refinement facts narrow the bindings inside the
branch (recorded on the `if` and its branch scope as `refines`, visible in HIR
text), exact facts enter the branch's fact set.

**Joins.** After an `if`, a fact survives exactly when it holds at the end of
every branch that completes normally (a branch that returns, fails or breaks
contributes nothing): refinement facts join by lub, exact results survive
when every such branch agrees (`refinement-join-all-paths`,
`refinement-join-one-path`, `refinement-repeat-join`). This is the existing
facts-scoping discipline of §13 extended to the join, not an optimistic
fallback.

**Value identity.** Facts are keyed by BindingId and value identity, never by
spelling. A later binding that shadows `s` is a different binding, so neither
the refinement nor the exact result applies to it (`refinement-rebinding`,
`refinement-repeat-rebound-value`); an immutable alias `x = s` *is* the same
value (`refinement-copy-of-proven-value`, `refinement-proof-through-alias`,
`refinement-repeat-alias-same-value`). Because carriers are stable values, a
fact about a value never needs invalidation.

**Refinement facts versus exact results.** A refinement fact says what type a
value has; it never decides a call. Two functions proving `Emailish` may
disagree, so `p1(s)` true makes `s` an `Emailish` but does not decide `p2(s)`
(`refinement-repeat-different-predicate`). Only the exact key -- same
function, same argument values -- can decide a later call, and only if the
function is repeatable.

## Repeated calls: repeatability

`hir/types.tcl`'s `Call` decides a call (`known` = the recorded result) when
all hold:

1. the callee is a known function with a proof contract;
2. the exact key of this call has a recorded result on every path reaching it;
3. `hir::repeatable::Block` proves the function repeatable.

Every backend already honors `known` (the Tcl compiler and native lowering
emit the constant and no call), so no backend changed for this.

**Repeatable** (`hir/repeatable.tcl`): a second call with the same argument
values is guaranteed to complete exactly as the first did, and neither call
has an effect anything else can observe. The rule is structural and
conservative; every operation the function can reach -- its body and,
transitively, every function it calls -- must be one of:

* a native call whose registration classifies it as a repeatable value
  operation: `-context-free 1` (it neither reads nor changes the execution
  environment: no I/O, process state or context) and no `mutarray-mutate`
  runtime tag, or a type test (`-tests-type`). Reading a `MutableArray`,
  hashing, syscalls, context operations and every unclassified native are
  not;
* a direct call of a known function, analyzed with what this call passes for
  that function's callable parameters (context-sensitively, memoized);
* a call through a parameter, only when every call that reaches it passed an
  exact callable (a known function or native) for that parameter, itself
  repeatable; a callable from a List, a struct field or an untyped value is
  not;
* everything else Botlish has: constants, references to immutable bindings
  (captures included), closure creation, control flow, struct construction
  and projection, declared errors.

Allocation is allowed (a fresh value is not observable through a Boolean).
Recursion is analyzed optimistically: repeatability is a safety property (no
reachable effectful operation), so the greatest fixpoint is the sound one.
`hir::repeatable::explain` gives the first reason a function is not
repeatable (`refinement-repeatable-explain`).

**What it reused, what is new.** It reuses existing native metadata
(`-context-free`, the runtime tags, `-tests-type`) and the existing exact
callable types; the walk itself (190 lines) is new, because no existing
analysis summarized the effects of a source function. Two natives the corpus
predicate needs were missing the classification they always deserved:
`str::is_tcl_alpha`/`str::is_tcl_alnum` (`core/tclcompat.tcl`) are now
`-context-free 1`. A proof contract never makes a call removable by itself
(`refinement-effectful-not-folded`, `refinement-mutant-unrepeatable-predicate`:
an `emailish?` that reads a `MutableArray` still proves, but a repeat is a
call), and a repeatable function without a proof contract is never decided
(`refinement-not-a-proof-not-folded`): this milestone records exact results
only for proof-producing calls; general CSE is a non-goal.

## The corpus

`lib/web.bot`:

```
refined type Emailish = str

local_extra_chars = immutable_set::from_list([".", "_", "%", "+", "-"])

fn emailish?(v: str) -> bool proves v: Emailish:

    n = str::length(v)

    fn char_at(i):
        if i < 0 or i >= n:
            return ""
        str::substring(v, i, i + 1)

    fn local_char?(c: str) -> bool:
        str::is_tcl_alnum(c) or immutable_set::contains(local_extra_chars, c)

    fn label_char?(c):
        str::is_tcl_alnum(c) or c == "-"

    fn scan_while(start, predicate: Fn{args: [str], return: bool}):
        loop i from start to n:
            if predicate(char_at(i)):
                continue
            return i
        n

    fn tld?(i):
        e = scan_while(i, str::is_tcl_alpha)
        if e == n:
            e - i >= 2
        else:
            false

    fn domain?(start):
        loop j from start to n:
            if char_at(j) == ".":
                if j == start:
                    return false
                if char_at(j - 1) == ".":
                    return false
                if tld?(j + 1):
                    return true
            else:
                if not label_char?(char_at(j)):
                    return false
        false

    local_end = scan_while(0, local_char?)
    if local_end == 0:
        false
    else:
        if local_end >= n:
            false
        else:
            if char_at(local_end) == "@":
                domain?(local_end + 1)
            else:
                false

refined type UriQueryValue = str

fn uri_query_value?(value: str) -> bool proves value: UriQueryValue:
    bytes = str::encode_utf8(value)

    fn upper_hex?(i):
        if i < 0 or i >= list::length(bytes):
            false
        else:
            b = list::at(bytes, i)
            ascii::is_digit(b) or (b >= 65 and b <= 70)

    fn valid_from?(i):
        if i < 0 or i >= list::length(bytes):
            true
        else:
            b = list::at(bytes, i)
            if b == 37:
                if upper_hex?(i + 1) and upper_hex?(i + 2):
                    valid_from?(i + 3)
                else:
                    false
            else:
                if is_unreserved(b):
                    valid_from?(i + 1)
                else:
                    false

    valid_from?(0)
```

(comments omitted). Names follow the corpus convention: the module's
predicates are snake_case with a trailing `?`, so `UriQueryValue?` is
`web::uri_query_value?`.

* `emailish?` is the module's existing ordinary implementation of the e-mail
  grammar (R2-ORDINARY-EMAILISH-PREDICATE.md), unchanged in behavior; its
  signature gained `v: str`, `-> bool` and the proof clause. It was
  previously reached from programs through the root native `emailish?` of
  `lib/web.tcl`, bridged to this function; it is now called directly as
  `web::emailish?`. Two helpers gained types: `local_char?(c: str) -> bool`
  and `scan_while`'s `predicate: Fn{args: [str], return: bool}`. Now that the
  module function is part of every program that checks e-mails (no root
  native in front of it), a standalone executable needs `local_char?`'s
  parameter kind statically; the structural type also states the contract
  both passed predicates (`local_char?`, `str::is_tcl_alpha`) satisfy.
  Repeatability follows the exact callables passed for `predicate` into
  `scan_while`.
* `UriQueryValue` used to be *opaque*: a String was one only when the trusted
  native `uriEscape` had attached runtime evidence to it. Runtime evidence is
  exactly what the representation theorem forbids, so its proposition is now
  the structural one the evidence stood for: every UTF-8 byte is an RFC 3986
  unreserved character or starts an uppercase `%XX` triplet -- exactly the
  alphabet `web::uri_escape_text` writes, so every string it produces passes.
  `uri_escape_text` returns a plain `str`; a caller that needs a
  `UriQueryValue` proves it with `uri_query_value?`.

`bench/refined-checks.bot` (the principal vertical test, `expect: [400, 0]`):

```
import web

q = web::uri_escape_text("a b")

fn check(n, acc, s, q):
    if n <= 0:
        return acc
    hit = if web::emailish?(s):
        if web::emailish?(s):
            if web::uri_query_value?(q):
                1
            else:
                0
        else:
            0
    else:
        0
    check(n - 1, acc + hit, s, q)

[check(400, 0, "café@例え.テスト", q), check(400, 0, "not-an-email", q)]
```

Its Core-IR predecessor `bench/refined-checks.ir` (which required
`lib/web.tcl`) is deleted, as are `examples/05-refined-strings.ir` and
`examples/hir/06-refined-strings.*`; `examples/refinement/refined-strings.bot`
is the source example. The cross-language equivalents
(`bench/equivalents/{python,rust,go}/refined_checks.*`) now perform the same
structural query-value check, and `bench/check-unicode-parity.tcl` agrees on
all 19 cases.

## Interactions

* **Method sugar.** A refined value is a method receiver for functions over
  its carrier through ordinary admissibility (`s.length()` style calls of
  `str` functions on an `Emailish`), with no forwarding functions
  (`refinement-method-sugar-forgets`). A function requiring `Emailish` is
  not a method of a plain `str` (`refinement-method-sugar-one-way`). No
  ranking was added: a function over `Emailish` and a different one over
  `str`, both applicable, stay ambiguous, and qualified calls disambiguate
  (`refinement-method-sugar-ambiguity`).
* **Operators** take the carrier: `str::concat` of an `Emailish` and a `str`
  is a `str`, `==`, `<` and friends compare as the carrier does; no operation
  preserves a refinement unless its declared result says so
  (`refinement-operators`).
* **Equality and hashing** are the carrier's: a refined value equals and
  hashes exactly like the same carrier value, with nothing salted by the
  type (`refinement-equality-and-hash`, every backend).
* **Rendering** is the carrier's at top level and inside containers, on every
  backend including the native runtime (`refinement-rendering-value`,
  `refinement-rendering-native-runtime`). HIR text and diagnostics show the
  static type (`str[web::Emailish]`).
* **`any` / erasure.** A refinement is a static fact with no runtime trace, so
  a value that passes through a type the compiler no longer tracks precisely
  loses it: `loop x in [s, 1]` binds `x: any` (the List's element type is
  `any`) and `send(x)` is a `TYPE` error; where the compiler still knows the
  exact value (`xs = [s, 1]` then `send(list::at(xs, 0))`, by exact value
  facts) it is kept (`refinement-any-erasure`). No tag is added to recover it.
* **Generics and imprinting.** Semantic instances (OPPORTUNISTIC-SEMANTIC-
  INSTANCES.md) key on the full static type, so `identity(m)` with `m:
  Emailish` is a separate semantic instance from `identity("plain")` and
  returns an `Emailish` (`refinement-generic-imprint`,
  `refinement-semantic-keys-keep-identity`). Specialization keys for code
  generation reduce named types to the kind (§21), so one codegen instance
  serves both: representation equivalence shares code, never semantic types.
  Intrinsic contract inference propagates a refinement requirement to an
  untyped parameter, so `relay(x): send(x)` requires its callers to prove
  (`refinement-contract-inference`).
* **Returns and fields.** A function may return a refinement it has proven,
  with no constructor; returning an unproven carrier is rejected
  (`refinement-return`, `refinement-return-unproven`). A struct field of
  refinement type accepts only a proven value, and reading it gives a
  refined value (`refinement-field`).
* **Integer domains** (`type Byte = Int in 0..255`) are unchanged and coexist.
  They share the registry entry kind, the `{refined BASE {NAMES}}` lattice
  and therefore subtyping, lub and narrow, and `hir/sourcetypes.tcl`'s
  declaration resolution. They stay separate in everything that makes a
  domain a domain: a domain is a *validator* type with an integer interval,
  read by range analysis (§21, `hir/range.tcl`) and ABI lowering, and a
  value can enter it by a checked conversion; a refinement has no validator,
  no interval, and only its owner's proofs mint it. A refinement may refine
  a domain (`refined type EvenByte = Byte`). Range diagnostics
  (`hir/range.tcl`'s mismatch clause) gained the refinement explanation.
* **Opaque structs** are unchanged: forgetting is defined only for
  refinement declarations, so an opaque struct gains no access to its fields'
  types and no conversion to them. The complete opaque-struct suite passes
  (Regression).

## Representation: the theorem

A refined value has exactly its carrier's representation in every backend:

* **interp**: a Tcl `{str TEXT}` value, as before the milestone minus the
  former evidence list: `core::value` has no evidence procs any more;
* **compile**: the same values; static types only choose code;
* **native**: the carrier's kind and register class. Code-generation keys
  reduce named types to their kind, so a function over `Emailish` and the
  same function over `str` are the same code.

Evidence from `tests/refinement-values.test`:

* **HIR**: the true branch carries `refines BINDING s : str[web::Emailish]`
  on its scope and the reference inside is typed `str[web::Emailish]`; no
  node constructs anything.
* **NIR** (`refinement-nir-proof-passes-register`): after `if mail?(s):`, the
  call `consume(s)` passes the parameter's own register; there is no
  allocation, guard, helper call or move into a new register.
  `refinement-nir-forgetting-is-free`: `consume_email(x)` calling
  `consume_string(x)` passes `x` on unchanged.
* **NIR/machine code** (`refinement-abi-identical`): a function over the
  refinement and the same function over its carrier compile to identical NIR
  text and the same machine-code size, parameter and result.
* **Layout** (`refinement-struct-layout-identical`): a struct with a
  refinement field lowers exactly as the same struct with the carrier field.
* **Allocation** (`refinement-allocation-free`): proving, passing to a
  refined function, passing to a carrier function, returning and storing in
  a struct: the refined program's allocation report is identical to the
  carrier program's.

## Corpus evidence: before and after

`bench/refined-checks.bot`, measured on the tree before this milestone
(`HEAD`, where it imported `web` and called the root natives `emailish?` and
`UriQueryValue?` with `q = uriEscape("a b")`) and after.

| | before | after |
|---|---|---|
| value, interp / compile / cranelift | `[400, 0]` | `[400, 0]` |
| value, cranelift-generic | fails: `UriQueryValue?` has no native implementation | `[400, 0]` |
| HIR, inner `emailish?(s)` | `call native(emailish?) = true` (a type test of the Tcl-registered `Emailish`, decided by the bridged native's metadata) | `call block(web::emailish?) = true` (exact result + repeatability) |
| HIR, `q`'s type | `str[UriQueryValue]` (the native's declared result) | `str` |
| NIR of `check`: calls of the e-mail predicate | 1 | 1 |
| NIR of `check`: query-value check | none (decided true from `q`'s static type) | 1 call of `web::uri_query_value?` |
| allocations (native) | 6823 objects, 178.3 KB: 6807 Strings, 12 Lists | 7223 objects, 203.9 KB: 6807 Strings, 412 Lists |
| machine code, all functions | 8187 bytes | 9371 bytes |
| best run (native, 20 runs) | 359.5 µs | 411.4 µs |

The e-mail side is the point: the second check disappears in both, but before
it disappeared because the compiler had a Tcl-registered type test for a
Tcl-registered type, and now it disappears because of the proof contract and
the exact-result fact the first call established, with the function proven
repeatable. `refinement-corpus-refined-checks-nir` and
`refinement-corpus-refined-checks-machine-code` pin it at the NIR and at the
Cranelift IR: `check` makes one call of `web::emailish?` and one of
`web::uri_query_value?`.

The query side changed meaning, as the spec asks: the old program never ran
a query-value check, because `uriEscape`'s declared result type *was* the
proof. Now `q` is a plain String and the check is a different predicate on a
different value, so it runs (400 times for the matching input; its
`str::encode_utf8` is the 400 extra Lists and most of the extra time and
code). Strings are unchanged.

## Diagnostics

| situation | code | message (abridged) |
|---|---|---|
| invalid carrier | `REFINEMENT-CARRIER` | invalid refinement carrier MutableArray[int] for "B": MutableArray[int] has reference semantics (...), so a proof about one value would not stay true |
| cyclic refinement | `CYCLIC-REFINEMENT` | cyclic refinement: "A" is its own carrier through A -> B -> A |
| unknown carrier | `TYPE` | unknown carrier type Nope for refinement "A" |
| proof target not a refinement | `PROOF-CLAUSE` | the proven type of "proves s: str" is str, which is not a refinement type |
| proof parameter missing | `PROOF-CLAUSE` | proof clause "proves t: A" must name one of the function's ordinary parameters: the function has no parameter "t" |
| carrier mismatch | `PROOF-CLAUSE` | proof carrier mismatch: parameter "s" is declared int, but A refines str |
| non-bool proof function | `PROOF-CLAUSE` | a proof-producing function must declare "-> bool" (its true result is the proof) |
| mint outside the owner | `REFINEMENT-MINT-AUTHORITY` | the entry program cannot declare a proof of refinement web::Emailish: only its owning module "web" may mint it |
| carrier where a refinement is required | `TYPE` | expected A but found str: a refinement proof is required |
| name collides with a built-in or another declaration | `TYPE` | type "str" cannot be declared: the name is already a built-in type |
| nested declaration, two proof clauses, `refined` before anything but `type` | `SYNTAX` | "refined" only modifies a type declaration ... |

## Source audit

Removed, with what replaced it:

| removed | replaced by |
|---|---|
| `lib/web.tcl`: `Emailish` (validator type over a regex), `UriQueryValue` (opaque type), the type-test natives `Emailish?`/`UriQueryValue?`, the compatibility alias `emailish?`, the evidence-attaching native `uriEscape` | `lib/web.bot`'s `refined type` declarations, `emailish?`/`uri_query_value?` with proof clauses, `uri_escape_text` |
| opaque named types (`core::type::register -opaque`), runtime evidence on Strings (`core::value::evidence`/`withEvidence`/`hasEvidence`, the `evidence` runtime tag, evidence in `show`/`==`) | refinement types: static facts only |
| `core::native::alias` and its resolution in `hir/resolve.tcl` | ordinary module functions |
| the `-module-fn`/`-native-body` native-implementation bridge (`core/native.tcl`, `core/evaluator.tcl`), `AttachNatives`, the bridged-native lowering, `nativeResultOverride` and `moduleNativeTargets` (`native/`, `hir/aot.tcl`, `hir/contexts.tcl`) | none needed: a module function is called as itself |
| `bench/refined-checks.ir`, `examples/05-refined-strings.ir`, `examples/hir/06-refined-strings.*`, the tests of the bridge (`module-fn-bridge-*.test`, `native-validator-predicate.test`) | `bench/refined-checks.bot`, `examples/refinement/refined-strings.bot`, `tests/refinement-values.test` |

No compatibility fallback remains. `refinement-no-compiler-domain-knowledge`
searches every compiler and runtime source (`core/`, `hir/`, `surface/`,
`native/` including its Rust sources, `compiler/`; `main.tcl` has none either)
for `Emailish`, `UriQueryValue`, `emailish?` and `uri_query_value?` outside
comments and finds none, and checks that `lib/` holds no Tcl library;
`refinement-old-mechanism-gone` checks that runtime evidence, opaque named
types, native aliases and the bridge are gone. The corpus fails as it should
without its declarations: without the proof clause nothing proves `Emailish`
and nothing decides the repeat (`refinement-mutant-no-proof-clause`); without
the refinement declaration the proof clause names no type
(`refinement-mutant-no-declaration`).

## Tests, fuzzing and mutation testing

`tests/refinement-values.test` (88 tests) pins every item above, each
behavioral case on interp, compile, cranelift-generic and cranelift through
one HIR (`sourceAgree`). `tests/emailish-predicate.test` and the other test
files that used the old machinery were migrated (`hir-refinement`,
`native-refinement-propagation`, `refined`, `types`, `native-uri-escape`,
...).

**Fuzzer** (`audit/refinement-values/tools/fuzz.tcl`): random function bodies
over two sibling refinements of `str`, a refinement of a refinement, two
predicates proving the same refinement, one proving the chain's refinement
from its carrier refinement, and one non-repeatable predicate; with plain and
aliased values, Boolean bindings of conditions, `not`/`and`/`or`, guards with
early returns, statement `if`s whose branches contain guards (so joins
matter), nested `if` expressions and leaves requiring each refinement or only
the carrier. An independent oracle (it shares no code with the compiler)
tracks carrier and nominal facts per value identity, exact predicate-result
facts keyed by predicate and alias root, implications through Boolean
bindings and the `not`/`and`/`or` lowering, and the intersection at joins.
For each program it predicts acceptance (a rejection must be a compile-time
`TYPE` error), the `known` of every predicate call in order, and the value,
which every backend must compute. Nested branches may also shadow `a` or
`b` with another value, so a fact keyed by spelling is caught, and the
prelude's `need3` forgets its `R3` to `R1` through a call, so the chain is
exercised. Four seeds × 600 programs: 1,794 accepted, 606 rejected, 3,093
predicate calls in accepted programs of which 264 decided (true and false),
**0 failures**.

**Mutation testing.** 31 mutants of the compiler, each run against
`tests/refinement-values.test` + `tests/emailish-predicate.test` (both
backends) and the fuzzer (seed 1, 300 programs, all four backends). A mutant
is killed when a test fails, a test file fails to load, or the fuzzer reports
a failure.

| # | mutant (the spec's item-87 list, where it maps) | tests failing | fuzzer failures | result |
|---|---|---:|---:|---|
| m01 | carrier -> refinement admitted without a proof | 13 | 71 | killed |
| m02 | owner check on proof minting disabled | 3 | 0 | killed |
| m03 | true edge drops the proof's facts | 34 | 17 | killed |
| m04 | proof facts flow to the false edge too | 3 | 10 | killed |
| m05 | exact results keyed by spelling, not value identity | 2 | 5 | killed |
| m06 | different predicates on one value treated as one | 2 | 51 | killed |
| m07 | one predicate on different values treated as one | 3 | 30 | killed |
| m08 | join keeps the first completing branch's facts (one path proves it) | 2 | 22 | killed |
| m09 | join takes the union of branch facts (one path proves it) | 2 | 23 | killed |
| m10 | join counts branches that return/fail | 3 | 20 | killed |
| m11 | redundant predicate elimination disabled | 10 | 22 | killed |
| m12 | every proof function treated as repeatable (effectful folded) | 2 | 5 | killed |
| m13 | every native treated as a repeatable value operation | 3 | 5 | killed |
| m14 | a call through an unknown callable treated as repeatable | 1 | 0 | killed |
| m15 | Boolean bindings forget their implication | 3 | 3 | killed |
| m16 | `not`/`and`/`or` implication swaps the condition's edges | 3 | 19 | killed |
| m17 | a join keeps an exact result the paths disagree on | 0 | 7 | killed |
| m18 | forgetting disabled (a refined str is not a str) | load error | 47 | killed |
| m19 | refinement chains not transitive | 1 | 235 | killed |
| m20 | carrier eligibility not checked | 3 | 0 | killed |
| m21 | cycles not diagnosed as `CYCLIC-REFINEMENT` | 1 | 0 | killed |
| m22 | proof carrier mismatch not checked | 1 | 0 | killed |
| m23 | semantic instance keys collapse a refinement to its carrier | 29 | 0 | killed |
| m24 | the runtime demands a refinement tag values do not carry | 0 | 0 | **survived** (equivalent) |
| m25 | a decided call keeps both outcomes possible | 0 | 1 | killed |
| m26 | a proof not attached to the alias root | 1 | 1 | killed |
| m27 | proof functions need not return `bool` | 1 | 0 | killed |
| m28 | exact results recorded on the true edge only | 1 | 14 | killed |
| m29 | a proof carried over to a later binding of the same spelling (fact retained after rebinding) | 0 → 1 | 0 | survived, then killed by a new test |
| m31 | join drops facts every completing branch proves (all paths prove it) | 1 | 6 | killed |
| m32 | refined values lose their carrier kind at the representation boundary (view not erased) | 5 | 0 | killed |

Notes, honestly:

* **m24 survives, and is equivalent.** `core::type::validate` of a
  refinement is reached only from native contracts and type-test natives,
  and neither can name a source-defined refinement (`definePredicate`
  rejects refinements; natives are registered before any source type). So no
  runtime path of any backend ever asks whether a value is a refinement
  member: making that question fail changes nothing. Its survival is the
  representation theorem observed from the other side.
* **m29 survived the first run.** Both existing rebinding tests shadowed the
  proven name with an inner function's *parameter*; a later *local*
  `s = "x"` in the proven branch was unpinned.
  `refinement-rebinding-local` now pins both the refinement and the exact
  result for a local shadow and kills m29 (and m05). The fuzzer does not
  kill m29: it needs a program whose only error is a refinement use of a
  shadowed name, which random generation rarely produces (also unbiased,
  `-accept 0`: 0 of 300).
* m05 and m19 were first killed only by tests; after the fuzzer gained
  shadowing in nested branches and a prelude that forgets R3 to R1 through a
  call, the fuzzer kills them too (the table shows the second run). m17 and
  m25 are killed by the fuzzer alone.
* Not constructible as written: "make refinement hashing include the nominal
  type", "allocate a wrapper for a refinement" and "fail to erase
  forget/refine view in NIR" need a runtime object or a HIR operation that
  does not exist -- hashing, allocation and NIR never see a refinement.
  m24 (Tcl runtime) and m32 (native representation) are the closest real
  mutants, and `refinement-equality-and-hash`, `refinement-allocation-free`
  and `refinement-abi-identical` would fail on any such addition.
  "Leave the old Emailish hardcoding active" is pinned statically:
  `refinement-no-compiler-domain-knowledge` and
  `refinement-old-mechanism-gone` fail if any of it comes back, and
  `refinement-mutant-no-proof-clause`/`-no-declaration` show the corpus
  behavior disappears without its source declarations.

## Regression

The whole suite (`tests/all.tcl`, 144 files: types, source-defined types and
`import type`, opaque structs, method sugar and METHOD-ELIGIBLE, callable
values and structural function types, range and completion proofs, ABI
numerics, Bytes, MutableBytes, contexts, Linux I/O, semantic instances and
imprinting, HIR samples and round trips, the native backend's own files), each
run on its own copy of the tree:

| run | tests | failed | baseline (the tree before this milestone) |
|---|---:|---:|---|
| `CORE_BACKEND=interp` | 5,990 | 10 = 8 + 2 since fixed | 6,030 tests, the same 8 failures |
| `CORE_BACKEND=compile` | 5,990 | 10 = 8 + 2 since fixed | 6,030 tests, the same 8 failures |
| `BOTLISH_NATIVE_GC_STRESS=1` (interp) | 5,990 | 8 | the same 8 failures |
| `tests/native-coverage.tcl` (cranelift) | 5,991 | 8 (the same 8) | 2,424 native, 3,432 independent, 67 passed-partial, 60 unsupported (test-only Tcl natives, Blocks returned to the host, sequence mode) |
| `cargo test --release` (native/) | 183 + 31 | 0 | |

(The coverage run includes `refinement-rebinding-local`, added after the
other runs.) The 8 failures are pre-existing and unrelated: `me-list-literal-never-eligible`
and `me-off-runs-no-warning-pass` (`method-eligible.test`) and six `warn-*`
tests (`warnings.test`), failing identically on the untouched baseline tree.
The interp and compile runs first also failed `ic-scan-while` and
`ic-local-char` (`intrinsic-contracts.test`): they pinned what intrinsic
contracts infer from `lib/web.bot`'s untyped `scan_while` and `local_char?`,
which this milestone typed. They now compile the original untyped helpers
inline, so the inference is still pinned, and pass on both backends (the GC
stress run already includes the fix). The net drop of 40 tests is the removed
mechanism's tests -- three deleted files with 35 tests
(`module-fn-bridge-param-check`, `module-fn-bridge-reachability`,
`native-validator-predicate`), 26 fewer in the migrated
`emailish-predicate`, `refined`, `native-refinement-propagation`,
`native-uri-escape` and `native-executable` files, and the per-file corpus
tests generated for the deleted `refined-checks.ir`, `05-refined-strings.ir`
and `06-refined-strings` sample -- against `refinement-values.test`'s 87 at
the time of the runs (88 now).

**Scalar machine code.** `native/generate-scalar-audit.tcl` regenerated the
committed audit corpus (`audit/native-scalar-asm/`, every `bench/*.bot` and
`examples/stdlib/*.bot`): only `bench/refined-checks` changed (the
`web::uri_query_value?` call and its two helpers; `local_char?`'s generic
instance is 62 bytes smaller now that it declares `c: str`). Every other
program's disassembly is byte-identical: refinements perturb nothing where
none occur.

**Cross-language parity.** `bench/check-unicode-parity.tcl`: all 19 cases
agree across Botlish and the Python, Rust and Go equivalents.

The AFL campaign plumbing (`fuzz/`) drops the deleted
`examples/hir/06-refined-strings` target (its seeds, baseline and inventory
rows); the historical campaign records are kept.

## Limitations

* Carriers are scalar value types (and domains and refinements over them).
  Struct, List and Bytes carriers are rejected as unsupported; the stability
  rule already classifies them (a `MutableArray` anywhere inside is never
  stable), but this milestone's types live on the core type lattice, which
  has no applied or struct forms. `Bytes`/`MutableBytes` would additionally
  need `ValueStability` to see through their `any`-typed `storage` field.
* Facts attach to plain references (and their alias roots). A proof about an
  argument that is not a reference (`p(f(x))`) proves nothing; a proof made
  by calling through a `Fn`-typed value proves nothing (no static contract is
  known for the callee).
* Exact results decide only the same function on the same values; a
  different predicate that would necessarily return true is never decided
  (by design: owner-defined predicates need not be canonical).
* Repeatability is all-or-nothing per function and conservative: any
  unclassified native, any call through an unknown callable makes the whole
  function unrepeatable.
* Facts do not survive erasure through `any` (no runtime trace by design).
* `main.tcl -backend interp` on `bench/refined-checks.bot` hits Tcl's
  recursion limit (the reference interpreter's depth for the 400-deep
  self-call, as before the milestone); the corpus test runs it on compile
  and both native backends, and the fuzzer and the other refinement tests
  run interp on smaller programs.

## Future work

* **Linux paths** (`refined type LinuxPath = ...`): the mechanism is not
  tied to `str`; what remains is choosing the carrier (likely a byte
  string, which needs struct/aggregate carriers or a scalar byte-string
  kind), the owning module and its parser predicate, and deciding which
  operations may forget a path to its carrier.
* **Generalized proof minting** (a `socket()` result, resource ownership,
  relational facts): the proof contract is a list of clause dicts with an
  outcome, so a "result satisfies R" clause or a non-Boolean outcome extends
  it; the consumers already take rules in a uniform shape. What is missing is
  the grammar, validation for those forms and a story for minting without a
  Boolean edge.
* **Traits**: refinement identity is a nominal registry entry that survives
  in semantic types and semantic instance keys, so a future trait can accept
  `LinuxPath` and `WindowsPath` as distinct types; nothing at run time needs
  to change.
