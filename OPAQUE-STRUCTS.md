# `opaque struct`: module-owned representation and construction authority

```
opaque struct Token:
    value: int
```

`opaque struct` makes the declaring module the sole authority for constructing
and inspecting the struct's representation. That is the whole feature:

> An opaque struct is an ordinary Botlish value whose representation is
> accessible only to the module that declares it.

It is **representation ownership**, not object-oriented privacy. The fields are
not "private members" of a type with a public interface and friends: they are the
representation of a value that other code may hold, pass, store, return, compare
and hash as a whole, and may not manufacture or take apart. The owner writes the
abstraction as ordinary functions. The compiler, optimizer and runtime are not
subject to the boundary: `opaque` is source-level authority and never an
optimization barrier.

It is the prerequisite for `opaque struct Bytes` (ABI views), `opaque context
struct ...` and `opaque resource struct ...` (capability values, contexts,
managed foreign resources). This milestone implements only the first property.
Nothing here is a context, a resource, a borrow, a lifetime, RAII, `with:`, a
pointer, or an ownership transfer.

## Syntax

```
structDecl     = { structModifier } "struct" IDENT ":" NEWLINE INDENT structField { structField } DEDENT
structModifier = "opaque"
```

* `opaque` is a **contextual** word, not a keyword: it is a modifier only when
  every word before the `struct` keyword is a modifier word
  (`surface::parser::AtStructDecl`), which no other construct allows. `opaque =
  1`, `opaque(x)`, `x.opaque` and a field called `opaque` keep their meaning.
* The modifier is a property of the one struct declaration, not another
  declaration kind: the `structdecl` AST node gains `opaque` (0 or 1) and
  `opaqueSpan` (the modifier word's span), and everything else about it is the
  ordinary node. A duplicate modifier, `opaque` before `fn`/`type`/`error`, and an
  `opaque struct` nested in a function or branch are located syntax errors.
  `opaque resource struct` is *not* accepted (`expected end of line, found name
  "resource"`): `resource` does not exist as a language feature. `context` does
  since CONTEXTS.md: `opaque context struct` is two independent modifiers of
  the one declaration (`context struct` alone is a context without opacity).
* The ordinary form is unchanged, and an ordinary struct is no more restrictive
  than before: everything below applies only to a struct written `opaque
  struct`. Protection is **per struct**, never per module: a module may declare
  `struct Public` and `opaque struct Secret`, and `Public` stays as open as ever.

## The owner

A struct's representation owner is the **source module that declares it**,
identified by the compiler's canonical, path-derived namespace:

```
lib/foo.bot         owns the opaque structs it declares: foo::Name
lib/abi/x86_64.bot  owns abi::x86_64::Name; it is a different module from abi
```

There is no `namespace` declaration, so there is nothing to spell differently.
Authority is **exact**: the declaring module only. No friend declaration,
package visibility, access list or namespace inheritance exists, and none was
invented. A parent module has none over its child's opaque structs, a child none
over its parent's, `import abi` grants nothing over `abi::bytes::Bytes`, a transitive
dependency grants nothing, and a struct that merely *holds* an opaque value (in a
field, a list) grants nothing over it. Imports authorize naming cross-module
symbols; they never grant representation authority.

An **entry program** may also declare an opaque struct; the entry program is its
owner (its namespace is `""`, which no module has). There is no cross-file entry
namespace to solve.

A module needs no import to use its own structs, and a self-import is already an
error: opacity uses the same module identity directly.

## What each side may do

| | the owning module | any other code |
|---|---|---|
| name the type: `token::Token`, in annotations, struct fields, lists | yes | yes |
| receive, pass, store, return, alias, put in aggregates | yes | yes |
| `==`, `!=`, `hash`, `ImmutableSet` membership (whole-value) | yes | yes |
| call ordinary functions that take or return it, and use their contract facts | yes | yes |
| `x.f()` where `f` is a visible function (method sugar) | yes | yes |
| construct: `token::Token {...}` | yes | **`OPAQUE-CONSTRUCTION`** |
| project: `x.f`, the callee of `(x.f)(a)` | yes | **`OPAQUE-REPRESENTATION`** |
| destructure: `{f} = x`, `{f: g} = x`, nested, partial | yes | **`OPAQUE-REPRESENTATION`** |
| field as a method candidate / source of ambiguity | ordinary rules | no: not a candidate |

Inside the owner an opaque struct is exactly an ordinary struct: no special
intrinsic constructor or accessor exists or is needed, the owner writes `Token
{value: v}`, `token.value` and `{value} = token` in ordinary Botlish, and
`create`/`value` are ordinary functions the author chose to write. There are no
implicit constructors, no generated getters, no automatic accessors.

Outside the owner the restriction is **authority, not proof**: `token::Token
{value: 42}` is rejected although `42` is perfectly valid for the field, and
although every field is a compile-time constant. The owner is the only code that
may build the representation, whatever the compiler can prove.

## Diagnostics

Both are compile-time errors with their own kinds, located where the written
construct is (the type name of the construction, the field name of the
projection), and raised before anything runs:

```
OPAQUE-CONSTRUCTION:
token::Token has an opaque representation owned by module "token"; construct it
through the public operations provided by that module

OPAQUE-REPRESENTATION:
field access on token::Token is not available outside module "token";
token::Token has an opaque representation, so its fields can be neither
projected nor destructured here (use the public operations provided by that module)
```

(For an entry-program owner the owner is "the entry program".) Neither message
depends on any field, and neither is a generic missing-field or type error: the
compiler knows the type and the field exists; the caller lacks authority.

**Nothing about the representation is observable from outside.**

* `x.real_hidden_field` and `x.guessed_field` give the same diagnostic, byte for
  byte, including the location and the optional method hint. A destructuring is
  rejected exactly as its explicit projections are (the lowering is the existing
  one: `tmp = x; v = tmp.value`).
* A construction that names fields wrongly, omits some, repeats one or gives the
  wrong type produces the one `OPAQUE-CONSTRUCTION` and nothing else: the
  field-level diagnostics (`MISSING-FIELD`, `UNKNOWN-FIELD`, `DUPLICATE-FIELD`,
  the declared-type proof) would enumerate the hidden schema, so none is given.
* A rejected access is typed as an unknown field is (`any`), never with the
  hidden field's declared type, so no later diagnostic can name it. The
  consequence of the rejection (an unproven nested projection, a call that cannot
  be proven) may still be reported after it; the opacity diagnostic always comes
  first in the HIR's diagnostic list, which is what a strict compile raises.
* Printing and diagnostics that mention an opaque value name its type (below).

A generic function of a consumer that projects its parameter is analysed under
the opaque argument type at the call that makes the instance
(OPAQUE-REPRESENTATION at that call, naming the instance and the body location):
`fn peek(x): x.value` followed by `peek(token::create(1))` is rejected, and so is
a *module's* generic function applied to an *entry program's* opaque struct. The
owner is exact, and the semantic-instance check does not know which module
"should" be allowed.

## Method syntax

`x.value()` is the method form of `token::value(x)` when that function is visible
(METHOD-SUGAR.md), while `x.value` as a field projection is forbidden. Method
resolution never inspects an opaque struct's fields outside its owner:

* a hidden function-valued field named `describe` is not a candidate, creates no
  field/function ambiguity, and does not change which function a call resolves to
  (the identical program on an ordinary struct is the documented
  `AMBIGUOUS-METHOD-CALL`; here the call is the function);
* inside the owner the ordinary field/function ambiguity rule applies unchanged;
* a method-style call with no visible function of that name is a call of the
  field's value, i.e. representation access: `OPAQUE-REPRESENTATION`, with the
  usual hint ("no function named ... is visible"), the same for a real field and
  a guessed name;
* `(x.callback)(arg)`, the explicit call of a field value, is a projection, and
  forbidden: a function-valued field is no way around opacity.

## Where authority is decided

Nothing runtime knows about opacity. Authority is decided statically, at the
source semantic boundary, from three facts: the declaration's owner, the namespace
of the code performing the operation, and, for a projection, the receiver's static
type.

```
declaration   hir::structs registry: opaque 0|1, namespace = the owner
construction  hir::resolve::ResolveStruct  (resolve time: the code's namespace is known)
              -> OPAQUE-CONSTRUCTION; the node is marked opaqueDenied so that
                 hir::range::VerifyStruct proves no field of it and the bearing
                 check (hir/callables.tcl) words no diagnostic about one
projection    hir::resolve stamps every `project` node (and the method-call record)
              with the namespace of the code it is written in (`ns`); after
              inference hir::structs::ProjectionProblem compares it with the
              receiver type's owner -> OPAQUE-REPRESENTATION; hir::types::Project
              types the denied access as unknown; hir::structs::AmbiguousMethodCall
              does not look at the fields of a receiver it has no authority over
destructuring lowers to projections (surface/lower.tcl, unchanged): the same check
```

Both checks go through one predicate, `hir::structs::representationDenied ID NS`
(the struct is opaque and NS is not its owner). The design is the general concept
the spec asks for: **any source operation that requires knowledge of a struct's
fields requires representation authority.** Today those operations are the
construction `Name {...}` and the projection `x.f` (with destructuring and the
field-value call being projections); a future `with`/`without`/update syntax
would call the same predicate. It is not "ban the `{...}` syntax".

After the check the HIR is ordinary. Inside the owner `x.value` lowers to the
very same `project` node as for a non-opaque struct; there is no `opaque_project`
or `opaque_construct` operation; core IR, the interpreter, the Tcl compiler and
native lowering see only construct/project. A node without an `ns` stamp (core IR
text, serialized HIR) is past the source boundary and trusted.
`tests/opaque-struct.test` checks that the checked HIR of an opaque program is the
ordinary struct program's, node for node, modulo one declaration marker.

### HIR representation

The struct entry of HIR's `sourceTypes` (and the registry behind it) gains
`opaque 0|1`; the owner is the entry's existing `namespace`. HIR text prints
`struct ID name NAME ns NS opaque fields ...` for an opaque struct only (an
ordinary struct's line is unchanged) and `hir::parse` reads it back. The loader
supplies the owner: `surface::lower::StructDeclOf` takes the canonical namespace
from module loading, so ownership never comes from the cached AST (below).

## Whole-value semantics: equality, hashing

Opacity changes neither. Two struct values are equal iff they are the same
declaration and every field is equal, slot by slot (STRUCTS.md "Equality"); an
opaque struct follows it exactly:

```
wrapped::create(1, "a") == wrapped::create(1, "a")    true
wrapped::create(1, "a") == wrapped::create(2, "a")    false
wrapped::create(1, "a") == wrapped::create(1, "b")    false
wrapped::create(1, "a") == lookalike::create(1, "a")  false   (a distinct declaration)
```

This does reveal that two opaque values are equal, as it would for any value; it
does not expose their fields, and no field becomes accessible. `hash(x)` is the
existing structural hash over the declaration identity and the fields: the same
declaration with and without the `opaque` modifier hashes alike
(`opaque-hash-equals-the-ordinary-struct-hash`). An `ImmutableSet` of opaque
values deduplicates by the same equality. Nothing was special-cased: changing
either is a separate language decision.

## Rendering

The one invariant: **normal user-facing rendering of an opaque value identifies
its nominal type and does not dump its private representation.**

```
core::value::show   <opaque token::Token>        alone, in a list, in another struct
runtime TYPE error  +: expected int, got <opaque token::Token>
printed program value, standalone executable: the same text
```

* `core::value::show` (the one Tcl printer: the program's printed value, the
  runtime error messages of the interpreter and compiler, evidence-bearing
  contract messages) prints `<opaque ID>`, in the style of `<block ...>` and
  `<native ...>`, for a struct whose identity the registry knows to be opaque. A
  third argument `reveal` (`core::value::show V 1 1`) asks for the full
  representation: this is for internal tooling, and the test harness's
  differential printer uses it so the backends are still compared on every field.
* The native runtime has its own printer (`show.rs`, used for its error messages
  and the standalone executable's result). A named NIR shape carries `opaque=1`
  when its declaration is opaque (`shape 1 named "token::Token" opaque=1
  fields="value"`; absent otherwise, so ordinary NIR is unchanged), the Rust
  `ShapeInfo` records it, and `show` prints `<opaque ID>`. It is a rendering fact
  only: no operation, layout, check or allocation reads it. The host value the
  native runtime hands back to Tcl (`tcl_value`) is the same complete
  representation for every struct, and Tcl's printer applies the rule.
* Static diagnostics already name types, not values (`expected int, got
  token::Token`), and a rejected access is typed as unknown (above).
* HIR text, `-hir`/NIR dumps and audit scripts are internal tooling and show the
  declaration. There is no security-redaction framework: this is abstraction
  integrity, not a cryptographic boundary.

## The compiler still sees the fields

`opaque` changes source authority, not compiler knowledge. Type inference, range
and exact-value analysis, completion analysis, struct scalar replacement, escape
analysis, specialization, NIR and native lowering read the declaration exactly as
for an ordinary struct: a field of type `ByteValue` is still `0..255` inside the
owner's code and in everything the compiler derives from it. What a consumer can
rely on is the owner's *function contracts* (a declared or inferred result type is
public API); the field's own domain is not exported through opacity.

### Optimizer transparency (measured)

`tests/opaque-struct.test` compiles one library module twice, `opaque struct
Small` and `struct Small` (the same text otherwise, one `SmallValue = Int in
0..255` field, `create`/`read`/`bump` functions), and the same consumers against
each:

| consumer | mode | `Struct` objects (opaque / plain) | allocations | NIR | CLIF |
|---|---|---|---|---|---|
| `x = create(7)`; `read(x) + bump(x)` | specialized | 0 / 0 | 0 / 0 | identical (no shape table at all) | identical |
| same | generic (`-specialize 0`) | 1 / 1 | 1 / 1 | identical but the shape line's `opaque=1` | identical |
| `[create(7), create(9)]`, `read(create(200))` | specialized | 2 / 2 | 2 / 2 | identical but `opaque=1` | identical |
| same | generic | 3 / 3 | 3 / 3 | identical but `opaque=1` | identical |
| `read(pass(create(3)))` | both | equal | equal | identical but `opaque=1` | identical |

On the specialized path a one-field opaque wrapper is scalar-replaced exactly as
an ordinary one: no struct object, no `structnew`, no shape, no boxing, no
reflection object, no runtime access check, no visibility test. The unspecialized
generic backend materializes the opaque struct exactly when it materializes the
ordinary struct (one object in the first row). The CLIF is byte-identical in every
case. A range-dependent branch (`bump(x) < 257` with the field in `0..255`) is
decided at compile time in both spellings.

## Module-cache safety

`surface::modules::ParseModule` caches parsed module ASTs by `{path, text}`. The
cached `structdecl` carries only what is intrinsic to the text (`opaque`); the
owner is the namespace the loader supplies when it lowers the declaration, from
the module's canonical path-derived identity, never from an importer. The tests
check that compiling consumers (accepted and rejected) leaves the cached AST
unchanged, that the verdicts are the same whichever program or module causes
`wrapped` to load and in either order, that an entry program's own `Wrapped` is a
different type owned by the entry program, and that editing the file (adding or
removing `opaque`) takes effect with no stale answer.

## Audit of structural operations

Every operation that can read or build fields by name:

| operation | status |
|---|---|
| `Name { f: v }` | construction: `OPAQUE-CONSTRUCTION` outside the owner |
| `x.f`, `(x.f)(a)`, `x.f(a)` with no visible function | projection: `OPAQUE-REPRESENTATION` |
| `{f} = x`, `{f: g} = x`, nested, partial | lowers to projections: the same check |
| anonymous `{ f: v }` | not the opaque struct's construction; an anonymous struct is never accepted for a named type, so it cannot manufacture an opaque value |
| `==`, `hash`, `ImmutableSet` | whole-value; no field is exposed |
| `list`, `list::*`, `str::*`, ... | do not look inside structs |
| reflection (`fields(x)`, `field(x, "f")`, representation serialization) | **does not exist**; none was added. The runtime's `project`, `structFields` and shape table are internal and reachable only from lowered code |
| update, `with`, `without`, spread | do not exist (STRUCTS.md); when they do, they require representation authority through the same predicate |

## Future modifiers

The parser and registry are shaped so that further modifiers compose with
`opaque` instead of replacing it:

```
opaque context struct FileSystem:        who may inspect / manufacture the representation
opaque resource struct Registration:        = opaque;   how the value participates in
opaque resource context struct Something:   contextual authority / lifetime = the others
```

* `structModifiers` is a table of contextual words; the grammar's shape is
  `{ modifier } "struct"`, and each modifier names one boolean property of the one
  `structdecl` node. Adding `context` or `resource` is an entry in the table, a
  property on the node and on the registry entry; `opaque struct` is not a separate
  declaration kind.
* `opaque` owns exactly *who may inspect or manufacture the representation*. A later
  `context` property is about how the value participates in contextual authority
  and propagation, `resource` about lifetime and cleanup responsibility; neither
  has to reimplement representation privacy, because the representation check is
  one predicate over (declaring owner, accessing namespace), independent of the
  other properties.
* Not implemented here, and not accepted by the parser: `resource`, cleanup
  functions, resource `with`, ownership anchoring, actor ownership, transfer
  restrictions. (`context` and `with context` came later, as the table entry
  and independent property this section planned: CONTEXTS.md.)

## Known limitations

* **Opacity is abstraction integrity, not a security boundary.** Whole-value
  equality and `hash` can still tell that two opaque values are alike, as for any
  value; HIR text, `-hir`/NIR dumps, the host value a native program hands back
  to Tcl and audit scripts show the declaration, on purpose (internal tooling);
  the native shape table carries the field names.
* **A contract-bearing opaque value is still contract-bearing.** A struct that
  holds a typed `MutableArray[T]` (or a typed callable) must not be erased
  through an untyped boundary (STRUCTS.md "Bearing"), and that soundness check
  applies to an opaque struct as to any: its diagnostic names the type and the
  call, never a field, but it does say that the value bears a contract.
* **A rejected access has consequences.** A denied projection is typed `any`
  (as an unknown field is), so a later unproven nested projection or an unprovable
  call argument may be reported *after* the opacity diagnostic. They are
  name-independent and reveal nothing; the opacity diagnostic always leads.
* **A generic function is only as general as its callers' opacity.** Library code
  that projects a field of an arbitrary struct (`fn first(x): x.value`) works on
  any struct whose representation its module may inspect and is rejected, at the
  call that makes the instance, on an opaque struct of another module. That is the
  theorem, not a limitation to engineer around: such an abstraction belongs behind
  an accessor the owner writes.
* No standard-library struct was migrated to `opaque` (see below).

## Not in this milestone

`context struct`, `resource struct`, `with`, RAII, destructors, drop semantics,
borrow checking, lifetime parameters, affine/linear types, move semantics,
actor/thread transfer restrictions, `abi::bytes::Bytes`, `MutableBytes`, `CString`, raw
pointers, FFI pointer retention, friend modules, per-field visibility, protected
fields, inheritance, visibility levels, reflection, generated getters/setters,
namespace aliases, new struct equality semantics, custom hash semantics. No
existing library struct was migrated to `opaque`: the harmless candidates
(`abi::U8` and its relatives) are consumed with `.value` throughout the corpus,
so migrating one would be an API redesign, which the milestone excludes.

## Tests and fuzzing

* `tests/opaque-struct.test` (142 tests): grammar, the contextual modifier, the
  AST and loader-supplied owner, the registry and HIR text round trip; the owner
  (module and entry program) on every backend; consumer values; every forbidden
  form with the exact messages (construction with valid, reordered, constant,
  missing, unknown, duplicate and wrongly typed fields; projection of real and
  guessed fields; every destructuring form; nested and partial; field-value calls;
  the method-spelling; generic-instance bypasses); methods and hidden fields;
  nesting, holders, per-struct scope; authority exactness (parent, child,
  imports, same short name); no operation below the source; printing on every
  backend including the standalone executable; equality, hashing, sets; the module
  cache; optimizer transparency (specialized and generic NIR, CLIF, allocations,
  range facts, GC stress); the root-cause ordering of diagnostics; a **leak
  sweep** (thirty-odd unauthorized programs against a struct with distinctive
  field names, types and a contract-bearing `any` slot: no diagnostic of any
  phase may contain a word of the representation the program did not itself
  write, with an ordinary-struct control showing the sweep would see a leak);
  every route around the boundary I could construct (higher-order calls,
  aliases, closures, nested functions: all rejected, while the owner's own
  functions passed as values work); a function's declared result domain as the
  public fact while the field's own domain is not exported; and a bounded run of
  the fuzzer below (`opaque-fuzz-smoke`).
* `native`: Rust unit tests for the shape attribute and the nominal rendering.
* `audit/opaque-struct/tools/fuzz.tcl`: per program a random module (ordinary and
  opaque structs, factories, accessors, a nested struct, hidden function-valued
  fields) and random consumers in two spellings, against a Tcl oracle on four
  backends, with the printed text checked; plus seventeen rotating negative
  shapes, each also compiled against the ordinary *twin* (the same program with
  `opaque` removed) as the control, the exact set of diagnostic kinds, the
  representation words diagnostics may not contain, and the identity of the real-field,
  guessed-field and destructuring diagnostics.
* `audit/opaque-struct/tools/mutate.tcl`: twenty mutants (each opacity check,
  both stamps, the owner predicate, the ordering, the flag at every stage, the
  printer, a message that names the field), each run against the fuzzer and the
  test file in a scratch copy of the tree; every mutant must be killed.

## Milestone report

1. **Grammar.** `structDecl = { structModifier } "struct" IDENT ":" ...`,
   `structModifier = "opaque"` (above).
2. **Contextual?** Yes: recognized only before `struct` by lookahead; never
   reserved.
3. **AST.** The one `structdecl` node with `opaque` (0/1) and `opaqueSpan`; the
   owner is not in the (cached) AST.
4. **HIR / registry.** `opaque 0|1` on the struct `sourceTypes` entry and registry
   entry; the owner is the entry's `namespace`. Checked HIR carries `ns` on
   `project` nodes and on the method-call record and `opaqueDenied` on a rejected
   construction, read only by the checks.
5. **Owner.** The canonical, path-derived namespace the loader passes to
   `StructDeclOf` (`"abi::x86_64"` for `lib/abi/x86_64.bot`), exact match only.
6. **Entry programs.** The entry program owns the opaque structs it declares
   (namespace `""`) and may construct, project and destructure them; no module can
   (not even through a generic function).
7. **Construction diagnostic.** `OPAQUE-CONSTRUCTION`, one diagnostic, no field
   mentioned (above), for every shape of field list.
8. **Projection diagnostic.** `OPAQUE-REPRESENTATION`, identical for a real and a
   guessed field.
9. **Destructuring diagnostic.** The same `OPAQUE-REPRESENTATION`, located at the
   field name in the pattern; nested and partial patterns included.
10. **Field-value calls.** `(x.f)(a)` is a projection and rejected; `x.f(a)` with
    no visible function is the same representation access with the method hint.
11. **Method calls.** `x.f()` resolves to the visible function exactly as for any
    struct and is unaffected by hidden fields.
12. **Hidden fields and candidates.** Candidates are found by name before types and
    never read fields; the only place fields matter, the field/function ambiguity
    check (`hir::structs::AmbiguousMethodCall`), skips a receiver the call's code has
    no authority over. A hidden field makes no ambiguity and no candidate; inside the
    owner the ordinary rules hold.
13. **Nested / public.** The boundary is at the opaque struct: `Outer.inner` and
    nested/partial patterns are rejected whatever `Inner` is; a public struct stays
    public; authority is not transitive through holders.
14. **Imports.** Grant nothing: not direct, transitive, parent, child, or via a
    holder; `import type` stays for source `type`s (`NOT-A-TYPE` for a struct).
15. **Type signatures.** Opaque structs appear freely in parameters, results,
    fields, lists, locals; the type is public as `ns::Name`.
16. **Equality.** Unchanged whole-value equality (above).
17. **Hash.** Unchanged structural hash (above).
18. **Rendering.** `<opaque ID>` in `core::value::show`, native runtime messages
    and the standalone executable; `reveal` for internal tooling.
19. **Optimizer transparency.** Identical HIR (modulo the marker), NIR (modulo the
    shape attribute), CLIF and allocations to the ordinary struct.
20. **Specialized evidence.** The one-field wrapper allocates 0 objects (above).
21. **Generic backend.** Materializes exactly when the ordinary struct does.
22. **Module cache.** Owner from the loader's canonical identity; AST untouched.
23. **Fuzz results.** See the regression section below.
24. **Full regression.** See below.
25. **Other structural operations needing enforcement.** None beyond construction and
    projection; destructuring and the field-value call are projections, method
    candidacy needed the ambiguity-check change, and the *semantic-instance* path
    (a generic body analysed under an opaque argument) needed the opacity kind to
    survive the instance report. No reflection or update operation exists.
26. **No borrow/resource/context semantics were added.** `context` and `resource`
    are not parsed; nothing about lifetime, cleanup, borrowing, transfer or pointers.
27. **Future composition.** Modifier table, per-modifier property on the one
    declaration node and registry entry, and one predicate for representation
    authority (above).

## Regression

All measured on the final tree (Tcl 9.0.1, rustc 1.97.0, 4 cores). The baseline
before the change was green: 5330 tests on the interpreter backend.

| run | result |
|---|---|
| `tclsh9.0 tests/all.tcl`, interp | **5468 tests, 5468 passed, 0 failed** (5330 before, plus the 138 tests `tests/opaque-struct.test` had then; its last four tests were added after these runs and pass with the file: 142 of 142) |
| the same, compile | 5468 tests, 5464 passed, 4 skipped (the same four `coreScoping` skips as before), **0 failed** |
| `tclsh9.0 tests/native-coverage.tcl` (the whole suite on cranelift) | 5502 tests, 2309 native, 3063 independent, 70 passed-partial, 60 unsupported (no opaque test among them), **0 failed** |
| `cargo test --release` | 157 + 28 passed (the two new Rust tests included), 0 failed |
| the whole suite under `BOTLISH_NATIVE_GC_STRESS=1` (a collection attempted at every allocation site; includes all 142 opaque tests) | interp: 5472 tests, 5472 passed, **0 failed**; compile: 5472 tests, 5468 passed, 4 skipped, **0 failed** |
| `main.tcl -backend interp` / `compile` / the cranelift example corpus (`stdlib`, `surface` 01-08 and 11-13, `hir` 01-03) | all exit 0 |
| `audit/opaque-struct/tools/fuzz.tcl -n 255 -seed 20000` (four backends) | programs 255, values 255, negatives 255, twins 240; differential, oracle, negative, twin, diagnostic-set, print, message-leak and backend disagreements all **0** |
| `audit/opaque-struct/tools/mutate.tcl -n 51` | 20 mutants, **20 killed**, 0 survivors (the unmutated tree is checked first) |

The files the milestone names, all inside the two full runs above: `imports.test`,
`method-sugar.test`, `structs.test`, `struct-destructuring.test`,
`structs-syntax.test`, `abi-numeric.test`, the proof/bounds tests (`hir-range*`,
`checked-domain-proof-provenance`, `conjunctive-entry-facts`, ...), the native
and struct-scalar-replacement tests. Opacity did not perturb ordinary structs or
imports: not one pre-existing test changed outcome. The only edits to existing
tests are in `tests/helpers.tcl`: the differential printer (`outcomeUnder`,
`outcomeUnderHir`) passes `reveal`, so the backends are still compared on every
field of an opaque value.

One process note for anyone repeating this: the suites write temporary files into
the working directory, so two backends' runs must not share one (run them in
separate checkouts, as CI's separate jobs do).
