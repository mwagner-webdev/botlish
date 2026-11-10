# Text and collection precision census

Unicode construction, collection refinements and type information across
iteration. A census, not an implementation milestone: no compiler, standard
library or language behavior changed. The material is
`../audit/text-collection-precision/` (probes, a probe runner, a type matrix
generator and a text-construction benchmark).

Measured on main at f2787af0 (2026-11-07), Linux x86-64, Tcl 9.0.1, the
native backend built in release mode. Re-checked on the merge with main at
2ca98b5c (the native backend rebuilt): the eighteen probes pass, the type
matrix is identical, and the source locations cited are that tree's.

**The motivating report.** The five observations come from the TUI
clean-room package experiment (TUI-CLEANROOM-PACKAGE-MILESTONE-1.md). That
report is not in this repository or on any branch of it, so every
observation was reproduced from scratch with independent probes on current
main; nothing below depends on the TUI package's code.

## A. Executive findings

| # | Observation | What is actually true on main | Classification | Disposition |
|---|---|---|---|---|
| 1 | `loop b in bs` gives `b` the type `any` while `bs.at(i)` keeps `Byte` | The **checker** types every loop variable with the element type, in every context tested (12 operations x 6 element types, section H). The `any` is the **binding table**: a loop clause binding (element, counter, lockstep clause) never has its type recorded, so `hir::bindingType` and the compiler service's hover (the language server's) report `any` at its declaration, and eleven analyses that read the binding table fall back to their conservative answer | **Compiler defect** (incomplete recording; presentation and conservative precision loss, no unsoundness) | M1 |
| 1b | (found while reproducing 1) | `s.encode_utf8()` is `List[Byte]` only when the compilation has loaded `std::byte`; otherwise plain `list`. An import nothing names changes whether a program is accepted (probes c4/c5) | **Incomplete contract** (documented fallback, non-local effect) | M3 |
| 2 | `List[int[Byte]]` is not accepted where `List[int]` is required | Intentional: MINIMAL-APPLIED-LIST-TYPES.md's "initial invariance rule", documented in Compilerpedia (`rule.type-argument`). Consistent across List, ImmutableSet, MutableVector, MutableArray, nested Lists and nonnumeric refinements. But the compiler's own `subtype` and `lub` are covariant (the join of `List[Byte]` and `List[int]` is `List[int]`), and widening costs an element-wise copy | **Intentional semantics**, conservative; covariance would be sound for List and ImmutableSet, not for place parameters | M7 (language-design decision) |
| 3 | A character from a scalar value needs UTF-8 decoding | No Int-to-UnicodeChar operation exists (stated in `-help std::char`; explicitly deferred by UNICODE-CHAR-LITERALS.md). The standard library has the same workaround itself (`stdlib/windows/fs.bot`'s `push_utf8` and `decoded`) | **Missing API** | M5 |
| 4 | Escape characters and arbitrary scalars are awkward to spell | The escape vocabulary is exactly `\\ \" \n \r \t` (Strings) and `\\ \' \n \r \t` (characters); every other escape is a syntax error. A raw control character typed into a literal is accepted and runs everywhere | **Language choice** (minimal, deliberate); the extension space is free (no valid program uses another escape) | M6 (language-design decision) |
| 5 | No convenient joining operation | No `join`, concatenation of a List of Strings or String from characters exists. Compilerpedia recommends `std::test::joined` (the test library's), which is quadratic; natively a fold carrying `concat` or `append_char` copies O(n²) bytes, while the same construction as self-tail recursion is linear | **Missing API** and a documentation problem; the fold copy is a known, deferred optimizer gap | M4, M2, M8 |
| 6 | (discoverability) | `encode_utf8`'s help says "There is no decoding operation back from bytes to a String" (one exists: `std::abi::bytes::decode_utf8`) and states its `List[Byte]` type unconditionally; README §19 says Lists carry no element type; `concept.strings` lists three of the five character escapes | **Documentation problems** | M2 |
| 7 | (diagnostics) | A declared-result TYPE error omits the inferred type that an argument TYPE error states; `.slice` on a List suggests importing `std::byte_store`, which then compiles and fails at run time | **Diagnostic shortcomings**; the second is out of this census's scope | M2 (first); separate task (second) |

## B. Current language contracts

The rules as implemented, with their sources. "Language" is semantics a
program can rely on; "inference" is what the checker derives; "library" is a
standard-library API; "backend" is representation.

**Strings and characters (language).** A `str` is an immutable sequence of
Unicode scalar values; `std::str::length` counts scalars (README "Strings";
`core/strings.tcl`). `UnicodeChar` is a builtin scalar type distinct from Int
and String, exactly one scalar value, never a surrogate
(`core/value.tcl:17`, `core::value::isValidScalar`; natively Rust's `char`).
Every String transformation discards refinements unless its contract states
otherwise (`core/strings.tcl:10`).

**Construction and observation of characters (library).** The whole
UnicodeChar surface is: character literals; `std::str::char_at(s, i) ->
UnicodeChar errors IndexNotFound`; `std::str::append_char(s, c) -> str`
(total); `std::char::scalar_value(c) -> int` (total, `-result-range
{intervals {0 0xD7FF} {0xE000 0x10FFFF}}`, `core/unicodechar.tcl:38`); the
classifiers `std::char::is_tcl_alpha`, `is_tcl_alnum`. There is no Int to
UnicodeChar conversion (`compilerpedia/notes/stdlib.notes:1281`: "There is
no conversion from an Int to a UnicodeChar"; UNICODE-CHAR-LITERALS.md,
"Deferred": "an `Int -> UnicodeChar` constructor ... [was] not added").

**UTF-8 (library).** `std::str::encode_utf8(s)` is a native registered with
result type `list` and `-result-shape {typed std::byte::Byte 0 255}`
(`core/strings.tcl:126`); the shape narrows the result to `List[Byte]` only
when `std::byte::Byte` is registered in the compilation and proves 0..255
(`hir/types.tcl:4175`, the `typed` case of `ShapeResult`), "never a false
claim". `std::abi::bytes::from_list(values: List[Byte]) -> Bytes`
(`stdlib/abi/bytes.bot:112`) and `std::abi::bytes::decode_utf8(data: Bytes)
-> str errors InvalidUtf8` (strict, `stdlib/abi/bytes.bot:138`) are the way
back; `std::abi::bytes::join(parts: List[Bytes]) -> Bytes` is linear.

**Byte and integer domains (language).** `std::byte::Byte` is a
source-declared integer domain, `type Byte = Int in 0..255`
(`stdlib/byte.bot`), printed `int[std::byte::Byte]`. A domain value is an
Int everywhere an Int is expected (subtyping). A typed scalar parameter
admits an argument by type or by range facts (STRICT-TYPED-PARAMETERS.md):
`need(27)` is accepted for `need(b: Byte)`. `std::byte::from_int(value:
int) -> Byte errors BelowRange, AboveRange` is the explicit conversion; a
call whose argument is proven in range has no error obligation.

**Literals (language, `surface/lexer.tcl:564` and `:628`).** String escapes
`\\ \" \n \r \t`; character escapes `\\ \' \n \r \t`; anything else is
`invalid escape "\X" in string` (or `in character literal`), a SURFACE
SYNTAX error. A character literal must decode to exactly one scalar, not a
surrogate. Other characters, control characters included, are taken from
the source text as they are. A one-character String literal draws the
ONE-CHAR-STRING-LITERAL warning.

**List typing (inference).** A List's type is `List[E]`, optionally with a
length refinement; a literal's element type is the `lub` of its elements,
with no expected type (MINIMAL-APPLIED-LIST-TYPES.md, "List construction
element inference"): `[27]` is `List[int]`. `std::list::at` has the element
type; `append` the lub; `flat` the inner element type
(docs/README.md, "list<ELEM>" rules).

**Admission of collections (inference).** `hir::range::ProvesValueAcceptedBy`
(`hir/range.tcl:1663`) sends every applied aggregate (List, ImmutableSet,
MutableVector, MutableArray, refined List) to `AggregateAdmits`
(`hir/range.tcl:1739`): "exact structural equality", except an element
proven empty (`never`). The same rule holds a parameter, a declared result
and every other declared boundary. By contrast `hir::types::subtype` and
`lub` are covariant for List and MutableVector (section D).

**Iteration (inference).** `hir::types::IterationElementOf`
(`hir/types.tcl:2032`): "The static type of the loop variable of a loop over
a value of static type TYPE: a List's element type, or a MutableVector's";
the loop protocol of a collection struct goes through
`hir::iteration::ElementOf`. RETURNING-ITERABLE-LOOPS.md fixes a collecting
loop's type as `List[body type]`; a fold's type is the join of the initial
value's and every completion's (FOLD-LOOPS-MILESTONE-1.md).

**Generics (inference).** Functions are imprinted, not generic over declared
type parameters: `fn first(xs: List[T]) -> T` binds T from the argument
(hir/imprint.tcl). There are no annotations on local bindings (only on
parameters, results and fields).

**Errors.** Invalid Unicode is a declared builtin error (`InvalidUtf8`,
`InvalidUtf16`), never a replacement character; range failures are declared
errors (`IndexNotFound`, `LowerUnderrun`, `UpperOverrun`, `BelowRange`,
`AboveRange`), discharged statically when a call's argument facts prove them
impossible (STATIC-COMPLETION-PROOFS.md).

## C. UTF-8 iteration inference

### C.1 The checker keeps the element type

Probe `c1-loop-element-checker.bot` (accepted, value `[[195, 169], 195,
[195, 169], 364, [195, 169]]` on interp, compile, cranelift and
cranelift-generic):

```
import std::str
import std::list
import std::byte

fn need(b: std::byte::Byte) -> int:
    b

fn via_loop(s: str) -> List[int]:
    bs = s.encode_utf8()
    loop b in bs:
        need(b)

fn via_at(s: str) -> int errors IndexNotFound:
    x = s.encode_utf8().at(0)
    need(x)

fn from_int_loop(s: str):
    loop b in s.encode_utf8():
        std::byte::from_int(b)
...
```

A `Byte` parameter demands a static proof (the negative control: an `any`
element is rejected with `argument type: any`, an `int` with `argument type:
int, facts: [-∞, +∞]`), so the acceptance of `need(b)` shows the checker
knows `b` is a Byte. `std::byte::from_int(b)` needs no handler, so error
inference sees the Byte too. Probe `c2` makes the checker print the type:

```
$ tclsh9.0 main.tcl -check audit/text-collection-precision/probes/c2-loop-element-diagnostic.bot
   error: ...c2-loop-element-diagnostic.bot:15:15: argument for parameter "t" cannot be proven to satisfy str (argument type: int[std::byte::Byte]) (CORE SEMANTIC TYPE)
   error: ...c2-loop-element-diagnostic.bot:18:11: argument for parameter "t" cannot be proven to satisfy str (argument type: int[std::byte::Byte]) (CORE SEMANTIC TYPE)
```

Line 15 is `probe(b)` inside `loop b in s.encode_utf8()`; line 18 is
`probe(s.encode_utf8().at(0))`. The same holds for every context the brief
asks about (each verified by a TYPE diagnostic naming the argument type):
iteration directly over `s.encode_utf8()`; over a local bound to it; over a
typed parameter `List[Byte]`; over an undeclared and a declared function
result; over `append` and `flat` results; over a collecting loop's result;
nested loops over `List[List[Byte]]`; a lockstep loop; a closure capturing
the element; a struct field; a module-level binding; a captured local; a
MutableVector; and a library module's function, typed and untyped.

Other consumers agree: a list-length refinement through a loop element
(`loop p in pairs(): p.at(1)` over `List[List[int]{length: 2}]`) needs no
IndexNotFound; calling loop elements that are exact functions charges
exactly their errors (no erased-callable contract); method-style calls on a
loop element decide as on an indexed one. Every accepted program printed
the same value on the four backends.

### C.2 Where `any` comes from: the binding table

The same program through the compiler service (what `main.tcl -lsp` shows on
hover; `audit/text-collection-precision/tools/probes.tcl`'s `binding:`
checks):

| position (probe c1 / hov3) | hover |
|---|---|
| `bs = s.encode_utf8()`, at `bs` | `bs: List[int[std::byte::Byte]]` |
| `x = bs.at(0)`, at `x` | `x: int[std::byte::Byte]` |
| `fold b in bs ...`, at the declaration `b` | `b: any` |
| `acc + b`, at the reference `b` | `b: int[std::byte::Byte]` |

This is the observed contrast exactly. The first point where the
information is missing is HIR's binding table:

* A `bind` records its value's type on its binding (`hir/types.tcl:5200`,
  `dict set hir bindings $b type ...`), and so does a fold's intermediate
  ("The intermediate's one type, for the analyses that read a binding's
  (hir::bindingType)", `hir/types.tcl:4738`).
* A `listloop` types its element binding only as a flow fact of the walk
  (`hir/types.tcl:4416`, `dict set ctx facts [dict get $node
  elementBinding] $elemType`), which every `ref` reads, and never records it
  on the binding. A `countloop`'s counter likewise (`:4480`, always `int`),
  and a `lockloop`'s clauses.
* `hir::bindingType` (`hir/hir.tcl:1185`) returns `any` for a binding with no
  recorded type. The service's `BindingType` (`service/service.tcl:1628`)
  takes its parameter branch only for a function's parameters (the loop
  binding's scope owner is the `listloop` node, not a block) and falls
  through to `hir::bindingType`.

Probe `c6-loop-clause-bindings.bot` pins the pattern: `i` (counter), `b`
(element) and `j` (lockstep counter) are recorded `any`; `bs`, `acc` (fold
intermediate), `first` and `rest` (destructured fields) are precise. Every
loop clause variable of the matrix programs reads `any` whatever its type
(Byte, UnicodeChar, a user domain, int, a struct, str).

**Who reads the binding table.** `hir::bindingType` has 24 call sites; for a
loop binding they get `any` and take their conservative answer:
`hir::methods::DefinedType` (the method decision's stand-in guesses, never
its certification), `hir::completions::BindingFact` and `CleanInput`
(callable facts: `any` is an unknown callable), `hir::staticdeps`'
`ScopedBy` and the mention edges (a type that "mentions any" may hold a
resource or an affine value: more dependency edges), `hir::emission::
CanonBinding` (the top fact), `hir::affine::BindingType` and
`hir::cardinality` (fold intermediates only). None of them can be wrong
because of it; each can be less precise than the checker. No probe found an
observable difference beyond the hover, so the cost of the defect today is
the misleading display plus conservative decisions.

### C.3 A second, real precision boundary: `std::byte` must be loaded

Removing `import std::byte` from the program (probe `c3`) makes both the
indexed element and the loop variable `any` in the checker itself:

```
   error: ...c3-encode-without-byte-import.bot:17:11: argument for parameter "t" cannot be proven to satisfy str (argument type: any)
   error: ...c3-encode-without-byte-import.bot:21:15: argument for parameter "t" cannot be proven to satisfy str (argument type: any)
```

and `bs: list` on hover. This is the documented fallback of the `typed`
result shape: "if the compiling program never declared NAME (e.g. it never
loaded the library module that does), this falls back to the native's own
plain declared -result-type, never a false claim" (`hir/types.tcl:4185`).
It is sound, but it is a non-local effect: probes `c4` and `c5` are one
program, a 256-entry table indexed by each byte of a String, that differ only
in an `import std::byte` nothing names. Without it the index is not proven
in range (`c4`: two UNHANDLED-ERROR diagnostics); with it the program is
accepted and runs (`c5`: `[105, 196, 170, 109, 109, 112]` on all four
backends). The native guarantees 0..255 whatever is imported.

### C.4 The intended contract and the classification

The intended rule exists and is implemented: a loop variable has the
collection's element type (`IterationElementOf`), on every path that reads
it. The `encode_utf8` reproducer violates no checker rule; it exposes (1) a
binding table that omits loop clause bindings, which every reader of
`hir::bindingType` and every hover inherits, and (2) an element type that
depends on whether `std::byte` is loaded. Runtime correctness was never at
stake (all four backends agree on every program).

* (1) is an **implementation defect**: the recording `bind` and fold
  intermediates already do is missing for loop clauses. Fix: M1.
* (2) is an **incomplete contract**: the native's contract is "every element
  is in 0..255", and the type system can state it only through a name the
  program may not have loaded. Fix: M3.

## D. Collection refinement compatibility

### D.1 What is rejected

Probe `d1-list-invariance.bot`:

```
   error: 27:11: function result does not prove declared type List[int]
   error: 36:9: argument for parameter "xs" cannot be proven to satisfy List[int] (argument type: List[int[std::byte::Byte]])
   error: 39:16: argument for parameter "xs" cannot be proven to satisfy List[int[std::byte::Byte]] (argument type: List[int])
   error: 40:9: argument for parameter "xs" cannot be proven to satisfy List[int] (argument type: List[int[std::byte::Byte]])
```

* `List[Byte]` as a `List[int]` parameter: rejected (36:9), also after
  `std::list::flat` (40:9).
* `List[Byte]` as a `List[int]` declared result: rejected (27:11).
* The converse, `[1, 2]` for `List[Byte]`: rejected (39:16): correct, since
  nothing proves the elements are Bytes, and also for `[27]` (probe `d5`),
  whose elements all are.
* An untyped parameter or a `list` parameter (`List[any]`) takes a
  `List[Byte]` (accepted lines of `d1`).
* `MutableVector[Byte]` for `MutableVector[int]`: rejected (the same rule).
* Probe `d4`: `List[str[std::web::Emailish]]` for `List[str]`,
  `List[List[Byte]]` for `List[List[int]]`, `ImmutableSet[Byte]` for
  `ImmutableSet[int]`: each rejected.

### D.2 The rule and its documented reason

`AggregateAdmits` (`hir/range.tcl:1739`) admits an applied aggregate only
when its element is the identical resolved type (or `never`), recursively.
MINIMAL-APPLIED-LIST-TYPES.md, "Initial invariance rule":

> Despite List being immutable (which *would* make covariance sound), this
> milestone deliberately keeps `List[T]` admissibility **invariant** ...
> especially before any variance/aliasing audit exists for a future mutable
> or reference-like container.

Compilerpedia states it to users (`rule.type-argument`, which every argument
TYPE diagnostic links): "List element types must match exactly (List[T] is
invariant today): a List[Digit] is not admissible for List[int], and a
literal `[1, 2]` is a List[int], not a List[Digit], whatever its elements'
values."

So the rejection is **intentional** and **consistent** across every
collection and every refinement kind tested.

### D.3 Where the compiler is not consistent with itself

`hir::types::subtype` and `hir::types::lub` are covariant (they serve the
specialization lattice and joins):

```
subtype List[Byte] List[int]                  -> 1
lub List[Byte] List[int]                      -> List[int]
AggregateAdmits List[Byte] List[int]          -> 0
subtype MutableVector[Byte] MutableVector[int] -> 1
```

The join is observable (probe `d4`, line 33): `xs = if c:
s.encode_utf8() else: [1000]` has type `List[int]`. The compiler's own lub
already treats a `List[Byte]` as a member of `List[int]`; only the
declared-boundary admission does not.

### D.4 Soundness, by mechanism

The five mechanisms the brief separates, with what Botlish has:

| mechanism | example | today |
|---|---|---|
| scalar refinement inclusion | `Byte <: int` | yes: a Byte is an Int everywhere |
| conversion of one scalar | `std::byte::from_int(n)` | explicit, checked, declared errors |
| conversion or view of a collection | `List[Byte]` viewed as `List[int]` | none (no view; no generic map function) |
| subtype relation between generic applications | `List[Byte] <: List[int]` | covariant in `subtype`/`lub`, invariant at every declared boundary |
| compiler-generated copy | element-wise widening | none: the program writes the copy |

Soundness of covariant admission, case by case:

* **Immutable List and ImmutableSet:** sound. A refinement is knowledge, not
  representation ("a refined value is exactly a value of its carrier"), so
  the `List[Byte]` value *is* a `List[int]` value; no one can write a
  non-Byte into it through the wider type, because nothing writes into a
  List.
* **MutableVector and MutableArray passed by value:** sound under Botlish's
  value semantics: a value parameter is its own logical copy
  (`hir::mutvec::Elaborate`'s entry copies; MUTABLE-VECTOR.md), so pushing
  300 into a callee's `MutableVector[int]` never reaches the caller's
  `MutableVector[Byte]`. It depends on that copy convention holding at every
  boundary, which is the audit MINIMAL-APPLIED-LIST-TYPES.md asks for.
* **Place parameters (`place v: MutableVector[int]`):** unsound. A place
  parameter is the caller's storage (PLACE-PARAMETERS.md); the callee could
  push 300 into the caller's Byte vector. Invariance is what protects it
  today.
* **Results:** sound for the same reasons as the values they return.

### D.5 What widening costs today

Probe `d2`: the identity loop `loop b in bs: b` keeps `Byte`
(`List[Byte]`) and is rejected as `-> List[int]`, as is a fold appending to
`[]`. An operation whose result type is `int` is needed: `b + 0`, or a call
of a function declared `(b: int) -> int` (probe `d3`, accepted on the four
backends). Each is an O(n) copy to change nothing but a static type. The
TUI library's explicit widening function is therefore the only user-facing
answer the language gives today; it is correct but costs an allocation and
a pass.

### D.6 The literal asymmetry

`need(27)` is accepted for `need(b: Byte)` (range facts), but
`from_list([27])` is rejected for `from_list(values: List[Byte])`: the
literal is typed bottom-up as `List[int]` and admitted by equality (probe
`d5`, 19:32). A program writes `[std::byte::from_int(27)]` instead (each
element proven statically: no handler). This is the documented consequence
of the same two rules, not a defect, but it is the first obstacle the TUI
route to an escape sequence meets.

### D.7 Assessment

Accepting `List[Byte]` where `List[int]` is declared is semantically
justified for immutable collections and results, and the compiler already
computes the covariant relation. Whether to adopt it is a language-design
decision (the invariance rule was a deliberate, recorded choice), and its
compatibility risks are concrete (M7: method decisions, imprinting,
specialization keys). The mutable collections' place parameters must stay
invariant under any change. Nothing in the evidence calls for implicit
conversions, a compiler-generated copy, or a generic map function.

## E. Unicode scalar construction

### E.1 Inventory

| from \ to | UnicodeChar | str | List[Byte] (UTF-8) |
|---|---|---|---|
| ASCII or Unicode character literal | `'a'`, `'é'`, `'😀'` | `"a"` (warns: one character) | `"a".encode_utf8()` |
| control character | raw character in `'...'`, or `'\n' '\r' '\t'` | raw in `"..."`, or `\n \r \t` | via a String |
| UnicodeChar | -- | `"".append_char(c)` | via a String |
| str | `s.char_at(i)` (IndexNotFound) | -- | `s.encode_utf8()` |
| Int known to be a scalar value | **none** | **none** | hand-written UTF-8 encoder |
| Byte | **none** | **none** | `[b]` |
| UTF-8 bytes | via `decode_utf8(...).char_at(0)` | `std::abi::bytes::decode_utf8(std::abi::bytes::from_list(bytes))` (InvalidUtf8) | -- |
| UnicodeChar to Int | `std::char::scalar_value(c)` (total, 0..0x10FFFF without surrogates) | | |

Invalid scalars: a surrogate or a value above U+10FFFF cannot be a
UnicodeChar (`isValidScalar`, Rust `char`), cannot be spelled in a literal
(`'...'` holds source text, which well-formed UTF-8 cannot make a
surrogate), and comes out of `decode_utf8` as `InvalidUtf8` (an encoded
surrogate is rejected). Nothing panics.

### E.2 What the TUI agent did, and what of it is necessary

Probe `e1-scalar-via-utf8.bot` (accepted, `[1, 27, 233]` on four backends):

```
fn char_of(bytes: List[std::byte::Byte]) -> UnicodeChar errors InvalidUtf8, IndexNotFound:
    std::abi::bytes::decode_utf8(std::abi::bytes::from_list(bytes)).char_at(0)

c1 = char_of([std::byte::from_int(27)]): ...
c2 = char_of([std::byte::from_int(195), std::byte::from_int(169)]): ...
```

Every step is a workaround for the missing conversion:

* the program writes the scalar's UTF-8 encoding itself (one byte for ESC,
  two for é, four for an astral scalar: a hand-written encoder);
* the bytes must be `List[Byte]`, so each is wrapped in `std::byte::from_int`
  (section D.6);
* `decode_utf8` declares `InvalidUtf8`, which the program must handle
  although its bytes are valid by construction;
* `char_at(0)` declares `IndexNotFound`, handled for the same reason.

No simpler existing operation was missed: `std::char`'s members are
`scalar_value`, `is_tcl_alpha` and `is_tcl_alnum` (probe `e2`; the
UNKNOWN-SYMBOL diagnostic lists them), and `-help std::char` says "There is
no conversion from an Int to a UnicodeChar". The standard library hits the
same gap: `stdlib/windows/fs.bot` turns UTF-16 scalars into text with its own
`push_utf8` (`:278`, a hand-written UTF-8 encoder) and `decoded` (`:334`,
`decode_utf8` with an `InvalidUtf8` handler commented "never: they are UTF-8
by construction").

### E.3 A safe option

A checked conversion is the missing piece; nothing calls for an unchecked
one. Its contract (section I) distinguishes exactly the five things the
brief lists: an Int that is a scalar value (success), an Int that is not
(the declared error, including the surrogate gap), a Byte (an Int; every
Byte is a scalar value, so the call needs no handler), a UnicodeChar (its
result), and UTF-8 bytes (untouched: decoding remains `decode_utf8`'s).

Three mechanisms were considered:

1. **An ordinary checked function** `std::char::from_scalar_value(n: int) ->
   UnicodeChar errors InvalidScalarValue` (M5). It mirrors
   `std::char::scalar_value` and `std::byte::from_int`, uses the existing
   call-specific completion proofs, and is a library addition only.
2. **A refinement conversion** (a `ScalarValue` integer domain admitted by
   comparisons). Not expressible: an integer domain is one interval, and
   the scalar values are two (UNICODE-CHAR-LITERALS.md deferred union and
   `except` domain syntax). Rejected for now.
3. **An existing generic mechanism.** None applies: imprinting chooses
   types, not values, and there is no conversion family to join.

Option 1 is recommended.

## F. Literal syntax

### F.1 The grammar today

Probe `f1-escapes.bot`:

```
   error: 11:6: invalid escape "\u" in string
   error: 12:6: invalid escape "\x" in string
   error: 13:6: invalid escape "\e" in string
   error: 14:6: invalid escape "\0" in string
   error: 15:6: invalid escape "\'" in string
   error: 16:6: invalid escape "\"" in character literal
```

* Strings take `\\ \" \n \r \t`; characters `\\ \' \n \r \t`
  (`surface/lexer.tcl:586`, `:652`). UNICODE-CHAR-LITERALS.md, "Escape
  behavior", records the choice: "No new escape syntax was invented".
* Every other escape is a syntax error, so **no valid program contains one**:
  extending the vocabulary cannot change the meaning of an existing program.
* A raw control character in a literal is accepted (probe `f2`: ESC and
  U+0001 in a String, ESC in a character literal; `[5, 27, 27]` on four
  backends). It is invisible in most editors, and a diagnostic quoting it
  writes it raw: `warning: the String literal `"^["` is one character long`.
* The compiler already has a numeric escape of its own: HIR text writes a
  control character in a String constant as `\u%04x` (`hir/format.tcl:435`;
  `-hir` of probe f2 prints `"\u001b[1m\u0001"`). It is HIR text's, read by
  Tcl, not source syntax.
* A one-character String literal warns (ONE-CHAR-STRING-LITERAL): `"\t"` and
  `"<ESC>"` both warn; the character literal plus `append_char` is the
  sanctioned spelling.

### F.2 Three approaches

| | 1. extend literal syntax | 2. explicit constructors only | 3. literal source text plus named control characters |
|---|---|---|---|
| spelling ESC | `'\u{1B}'`, `"\u{1B}[1m"` | `std::char::from_scalar_value(27)` (needs a handler unless the argument is proven, which a constant is) | raw ESC in source, or a named operation (`std::ascii::escape()`) |
| value type | unambiguous: a scalar in a String or a char literal | unambiguous (UnicodeChar) | unambiguous, but invisible (raw) or ad hoc (named) |
| readability | good, familiar shape, visible | verbose for text: each control character becomes an `append_char` | raw: poor; named: good for a few, no answer for arbitrary scalars |
| invalid input | lex-time diagnostics (no digits, too many, surrogate, > 10FFFF) | a declared error, or KNOWN-ERROR for a constant out of domain | n/a |
| scalar validity | checked by the lexer with `isValidScalar` | checked by the conversion | n/a |
| consistency | the escape grammar grows by one form in both literal kinds | no grammar change | a catalogue of names to curate |
| compatibility | additive (every `\u` is an error today) | additive | additive |
| one-char rule | `"\u{1B}"` warns like `"\t"`: write `'\u{1B}'` | -- | -- |
| raw bytes and FFI | none: a String holds scalars, never bytes | none | none |

**On `\xNN`.** A Botlish String is a sequence of scalar values; it cannot
hold a byte. `\xNN` would therefore have to mean either the scalar U+00NN
(so `"\xE9"` is é, whose UTF-8 is C3 A9, not the byte E9: the very confusion
C and Python 2 programmers bring), or a byte (not representable in a String;
admitting it would allow invalid UTF-8). Neither meaning is worth having
beside `\u{...}`, and bytes already have their own representation
(`List[Byte]`, `Bytes`). Not recommended. `\e` names one control character
`\u{1B}` already spells; `\0` likewise `\u{0}`. Not recommended.

**Recommendation.** Approach 2 first (M5), because it is the semantic
operation and every program can use it today; approach 1 restricted to
`\u{H...}` (one to six hex digits, a scalar value) as a separate,
language-design milestone (M6), defined as the same rule as the
conversion, so `'\u{1B}'` is exactly the value `from_scalar_value(27)`
returns. Approach 3's named characters are not justified by the evidence:
one TUI library needs ESC, and `\u{1B}` or the conversion covers it.

No lexer change was made during this census.

## G. String construction

### G.1 Inventory

| need | today | complexity |
|---|---|---|
| join a List of Strings with a separator | none in `std::str`; `std::test::joined(parts, sep)` in the **test** library (`stdlib/test.bot:173`), recommended by `task.string-concatenation` | O(n²) copies (rebuilds the prefix each time) |
| concatenate a List of Strings | `fold p in parts with intermediate acc "": acc.concat(p)` | O(n²) copies natively |
| | self-tail recursion carrying `concat(acc, piece)` | linear natively (M8A plans) |
| | encode each, `std::abi::bytes::join`, one `decode_utf8` | linear; handle a dead `InvalidUtf8` |
| String from UnicodeChars | fold `acc.append_char(c)` | O(n²) copies natively |
| | each `"".append_char(c)`, then join through bytes | linear, n small Strings |
| String from scalar values | hand-written UTF-8, `from_list`, `decode_utf8` (section E) | linear |
| decode UTF-8 bytes | `std::abi::bytes::decode_utf8(std::abi::bytes::from_list(bs))` | linear; `InvalidUtf8` |
| append text incrementally | `concat`, `append_char` | each one new String |
| repeated fixed fragment | none (no repeat) | a loop of the above |

`decode_utf8(from_list(...))` is the right operation when the input really
is UTF-8 bytes (a file, a socket, a C buffer): it is explicit encoding and
its `InvalidUtf8` is real. It is a workaround when the bytes were made by
the program from text or from scalars: there the encoding round trip exists
only because no direct construction does, and the error it declares cannot
happen.

### G.2 Measurements

`tclsh9.0 audit/text-collection-precision/tools/bench.tcl`. Each strategy
builds one String from N three-character pieces (`"ab;"`) or N characters
(`'é'`) and observes its length; all strategies and backends agree on the
value. Native times are the best of three runs with JIT compilation
excluded (`native::measure`); "copied" is `native::allocationReport`'s
String bytes copied, the complexity evidence. Interp and compile are one Tcl
`time` per run (compilation excluded), best of three.

Native, larger N (`-sizes "4000 16000 64000" -backends cranelift`):

| strategy | N | result bytes | us | String bytes copied |
|---|---:|---:|---:|---:|
| fold-concat | 4000 | 12,000 | 985 | 24,006,000 |
| fold-concat | 16000 | 48,000 | 13,995 | 384,024,000 |
| fold-concat | 64000 | 192,000 | 567,874 | 6,144,096,000 |
| tail-concat | 4000 | 12,000 | 157 | 39,276 |
| tail-concat | 16000 | 48,000 | 466 | 157,344 |
| tail-concat | 64000 | 192,000 | 2,517 | 629,652 |
| flat-bytes | 4000 | 12,000 | 602 | 0 |
| flat-bytes | 16000 | 48,000 | 1,991 | 0 |
| flat-bytes | 64000 | 192,000 | 10,691 | 0 |
| bytes-join | 4000 | 12,000 | 955 | 0 |
| bytes-join | 16000 | 48,000 | 6,722 | 0 |
| bytes-join | 64000 | 192,000 | 21,864 | 0 |
| fold-append-char | 4000 | 8,000 | 848 | 16,004,000 |
| fold-append-char | 16000 | 32,000 | 11,145 | 256,016,000 |
| fold-append-char | 64000 | 128,000 | 278,853 | 4,096,064,000 |
| test-joined | 4000 | 12,000 | 1,575 | 24,005,997 |
| test-joined | 16000 | 48,000 | 14,985 | 384,023,997 |
| test-joined | 64000 | 192,000 | 496,684 | 6,144,095,997 |

All backends, N = 250, 1000, 4000 (`-sizes "250 1000 4000"`; us):

| strategy | N | interp | compile | cranelift | copied (native) |
|---|---:|---:|---:|---:|---:|
| fold-concat | 250 | 16,265 | 1,496 | 30 | 94,125 |
| fold-concat | 1000 | 59,090 | 4,001 | 168 | 1,501,500 |
| fold-concat | 4000 | 236,658 | 13,987 | 1,035 | 24,006,000 |
| tail-concat | 4000 | 668,635 | 17,877 | 122 | 39,276 |
| halving-concat | 4000 | 2,069,730 | 78,513 | 372 | 121,200 |
| bytes-join | 4000 | 563,537 | 90,144 | 1,369 | 0 |
| flat-bytes | 4000 | 237,157 | 51,006 | 596 | 0 |
| fold-append-char | 4000 | 244,368 | 15,620 | 816 | 16,004,000 |
| chars-via-bytes | 4000 | 659,531 | 92,024 | 1,572 | 8,000 |

The compile backend at N = 16000 and 64000 (us, one run): fold-concat
67,481 and 358,395; tail-concat 78,620 and 455,308; flat-bytes 240,325 and
848,368; fold-append-char 66,699 and 345,714; test-joined 293,943 and
1,414,307.

A modest ANSI sequence (N = 20 pieces): every strategy costs 1-4 us
natively, 0.9-1.3 ms on compile and 6-10 ms on interp; the choice does not
matter at that size.

### G.3 Reading the numbers

* **Natively, the obvious idioms are quadratic.** A fold carrying `concat`
  or `append_char` copies the whole prefix on every step: 6.1 GB copied to
  build 192 KB, 568 ms. FOLD-LOOPS-MILESTONE-1.md records the same gap for
  Lists ("What remains inefficient", item 2: "Carrying a construction plan
  through a fold whose intermediate ... is only extended is the
  construction fusion of the planned progression") and defers it.
* **The linear native idiom is self-tail recursion**, through M8A's
  construction plans (the plan parameter is materialized once): 2.5 ms at
  64000. Nothing tells a programmer that recursion is linear and the fold
  quadratic.
* **The function Compilerpedia recommends for many parts,
  `std::test::joined`, is quadratic too** (497 ms at 64000), and it lives in
  the golden-test library.
* **The bytes routes are linear** but go through `List[Byte]` (one Int per
  byte) and a `decode_utf8` with a dead `InvalidUtf8`.
* **The Tcl backends** pay per-operation costs that hide the copy volume at
  these sizes (compile: 5.3x for 4x N on fold-concat); interp is
  interpretive overhead throughout. Their copies are the same O(n²) bytes
  (Tcl builds a new string for every `concat`).

A mutable string builder is not justified by this: the linear answers exist
for a program that knows them, and a `join` over a List (the shape
collecting loops already produce) gives predictable linear cost without one
(M4). Fold construction plans (M8) would make the existing idioms linear
without any API, but they are an optimization a program cannot rely on by
reading its source.

## H. Related type-precision asymmetries

`python3 -I audit/text-collection-precision/tools/matrix.py`. Each cell is
the type the checker states in a TYPE diagnostic for the operation's result
("argument type: T"); `List[...]` rows are the collection itself.

| operation | Byte | UnicodeChar | Small (`Int in 0..9`) | int | Holder (struct) | str |
|---|---|---|---|---|---|---|
| index | `int[std::byte::Byte]` | `UnicodeChar` | `int[Small]` | `int` | `Holder` | `str` |
| loop element | `int[std::byte::Byte]` | `UnicodeChar` | `int[Small]` | `int` | `Holder` | `str` |
| collecting loop, element | `int[std::byte::Byte]` | `UnicodeChar` | `int[Small]` | `int` | `Holder` | `str` |
| collecting loop, result | `List[int[std::byte::Byte]]` | `List[UnicodeChar]` | `List[int[Small]]` | `List[int]` | `List[Holder]` | `List[str]` |
| fold intermediate | `int[std::byte::Byte]` | `UnicodeChar` | `int[Small]` | `int` | `Holder` | `str` |
| std::list::flat, element | `int[std::byte::Byte]` | `UnicodeChar` | `int[Small]` | `int` | `Holder` | `str` |
| std::list::append, element | `int[std::byte::Byte]` | `UnicodeChar` | `int[Small]` | `int` | `Holder` | `str` |
| undeclared result | `List[int[std::byte::Byte]]` | `List[UnicodeChar]` | `List[int[Small]]` | `List[int]` | `List[Holder]` | `List[str]` |
| imprinted result (`List[T] -> T`) | `int[std::byte::Byte]` | `UnicodeChar` | `int[Small]` | `int` | `Holder` | `str` |
| struct field | `int[std::byte::Byte]` | `UnicodeChar` | `int[Small]` | `int` | `Holder` | `str` |
| destructured field | `int[std::byte::Byte]` | `UnicodeChar` | `int[Small]` | `int` | `Holder` | `str` |
| lockstep loop element | `int[std::byte::Byte]` | `UnicodeChar` | `int[Small]` | `int` | `Holder` | `str` |

No operation loses the element type in the checker. The systematic
asymmetries are elsewhere:

| asymmetry | first mechanism | precision loss or check? |
|---|---|---|
| loop clause binding recorded `any` (hover, `hir::bindingType`) | `hir/types.tcl:4416` records a flow fact, not a binding type | precision loss (presentation, conservative readers) |
| `encode_utf8` element `any` without `std::byte` loaded | `ShapeResult`'s `typed` case, `hir/types.tcl:4208` | precision loss (documented fallback) |
| `List[Byte]` refused for `List[int]`, though their lub is `List[int]` | `AggregateAdmits` (`hir/range.tcl:1739`) vs `hir::types::subtype` | intentional compatibility check |
| `27` admitted as a Byte, `[27]` not as a `List[Byte]` | bottom-up literal typing plus `AggregateAdmits` | intentional (documented) |
| a fold with a numeric literal initial value joins to `int` (`fold b in bs with intermediate acc 0: b` is `int`) | the literal `0` is an `int`; join | not a loss: `0`'s type is `int` |
| a handled call joins to its handlers' type (`via_at(..): on IndexNotFound: 0` is `int`) | `Handle`'s join | not a loss: as documented |

## I. Errors and effects

Contracts for the operations this census recommends (none is implemented).

| operation | input domain | output | success iff | error | statically decided | allocation | total? |
|---|---|---|---|---|---|---|---|
| `std::char::from_scalar_value(n: int) -> UnicodeChar` (M5) | any Int | one UnicodeChar | `0 <= n <= 0xD7FF` or `0xE000 <= n <= 0x10FFFF` | one declared builtin error, `InvalidScalarValue` (a surrogate is neither below nor above a range, so `BelowRange`/`AboveRange` would misdescribe it) | yes, by the call's argument facts: a constant in the domain has no obligation, a constant outside it is KNOWN-ERROR, a Byte argument (0..255) none; a value proven only in 0..0x10FFFF keeps the error unless interval facts (the surrogate gap) reach the completion analysis | none | no (Int input); yes on its domain |
| `std::str::join(parts: List[str], separator: str) -> str` (M4) | any List of Strings | one String | always | none (the collection-length ceiling stays the runtime's limit, as for `concat`) | always safe | exactly one String, total length known before copying; O(total) | yes |
| `std::str::from_chars(chars: List[UnicodeChar]) -> str` (M4, optional) | any List of UnicodeChars | one String | always | none | always safe | one String; O(n) | yes |
| `\u{H...}` in a String or character literal (M6) | 1-6 hex digits | the scalar, in the literal's value | the digits name a scalar value | SURFACE SYNTAX diagnostics at lex time: no digits, a non-hex digit, more than six, a missing brace, a surrogate, above 10FFFF | always (lexing) | none at run time | n/a |
| covariant admission of `List[S]`/`ImmutableSet[S]` for `List[T]`/`ImmutableSet[T]`, `S <: T` (M7) | -- | the same value | `subtype S T` | none | yes | none | n/a |
| `encode_utf8`'s element type independent of imports (M3) | -- | `List[Byte]` always | -- | none | yes | none | n/a |

Each keeps a failure that the current explicit route exposes explicit:
`from_scalar_value` declares the scalar-domain error that `decode_utf8`'s
`InvalidUtf8` stood in for, and drops only the `InvalidUtf8` and
`IndexNotFound` that could not happen. `join` and `from_chars` can fail in
no way the operations they replace could not. No proposed operation panics
on ordinary invalid input.

## J. Diagnostics and documentation

**What a developer can find** (`main.tcl -help QUERY`):

| need | found | note |
|---|---|---|
| String length, character count | `-help "string length"`: `concept.strings` first | good |
| List length, indexing | `-help "list length"`: `concept.list-length`; `std::list` | good |
| UTF-8 encoding | `-help "encode utf8"`: `stdlib.std::str::encode_utf8` | its note is wrong (below) |
| UTF-8 decoding | `-help decode_utf8` only; `encode_utf8`'s note denies it exists | hard to find |
| character construction | `-help "char from int"`: `std::char::scalar_value` | the absence is stated in `std::char`'s note, not under a construction topic |
| concatenation | `-help "join strings"`: `task.string-concatenation` | recommends `std::test::joined` (section G) |
| collection transformation | `std::list`'s description: the collecting loop is the map | good |
| numeric refinement widening | `-help widen`: no topic; the invariance is in `rule.type-argument`, reached from the diagnostic | no topic says how to widen |
| relevant errors | `InvalidUtf8`, `IndexNotFound`: topics exist | good |
| escapes and control characters | `-help "control character"`, `-help ansi`: nothing; `concept.strings` lists `'\n'`, `'\''`, `'\\'` | incomplete |

**Documentation problems** (each a correction for M2):

1. `compilerpedia/notes/stdlib.notes:1164` (`stdlib.std::str::encode_utf8`):
   "There is no decoding operation back from bytes to a String." False since
   `std::abi::bytes::decode_utf8` (WINDOWS-X86-64-MILESTONE-7.md). It also
   says "Its static type is List[std::byte::Byte]" without the condition
   (section C.3).
2. `compilerpedia/topics/tasks.topic:364` (`task.string-concatenation`):
   "For many parts, chain concat calls or use stdlib/test.bot's
   std::test::joined" sends production code to the test library, and both
   suggestions are quadratic natively.
3. `compilerpedia/topics/concepts.topic:768` (`concept.strings`): lists the
   escapes `'\n'`, `'\''`, `'\\'`; `\t` and `\r` exist too, and nothing says
   that no numeric escape exists or how a control character is written.
4. `docs/README.md:2551` (§19, closed-AOT readiness): "Lists carry no element
   type. `std::list::at` returns `any`." Historical; §16 and §21 describe the
   current List types. It should say it is a past state.

**Diagnostics:**

1. A declared result's TYPE error does not name the inferred type (probe
   `j3`): `function result does not prove declared type List[int]`, beside
   the argument form `... (argument type: List[int[std::byte::Byte]])`.
   `hir::range::verifyDeclaredResults` (`hir/range.tcl:1905`) has the
   inferred type in hand and prints it only through `MismatchClause`, which
   says nothing for Lists.
2. A method-style `.slice(0, 1)` on a List names `std::byte_store::slice`
   (probe `j1`): `namespace "std::byte_store" is not imported; add `import
   std::byte_store``. Following the advice compiles, because `std::byte_store`
   is an ordinary public namespace whose natives take `any`, and the call
   then fails when it runs on every backend (probe `j2`: `std::byte_store::
   slice: expected bytestore, got [97, 98]`). This belongs to method
   resolution and namespace visibility, outside this census; recorded only.
3. A diagnostic quoting a literal that holds a control character writes the
   character raw (section F.1).
4. The hover of a loop variable says `any` (section C.2): the most direct
   cause of the TUI observation.

## K. Regression probes and performance

**Probes.** `audit/text-collection-precision/probes/*.bot`, eighteen
programs, each stating its outcome in its leading comments (`# outcome:`,
`# value:`, `# diagnostic: L:C TEXT`, `# error:`, `# binding: L NAME
TYPE`). They pin today's behavior; a follow-up milestone that changes one
updates its expectation in the same change.

```
tclsh9.0 audit/text-collection-precision/tools/probes.tcl
```

runs `main.tcl -check` on each, every accepted or run-time-failing probe on
interp, compile, cranelift and cranelift-generic, and the binding-table
checks through the compiler service. Result on f2787af0: `18 probes, 0
failed`. A probe with a wrong expected value, and one with a wrong binding
type, both fail (checked).

| probe | pins |
|---|---|
| c1, c2 | the checker types a loop element over `encode_utf8()` as Byte, like `at`; four backends agree |
| c3 | without `std::byte` loaded, `encode_utf8()` is `list` in the checker |
| c4, c5 | an import nothing names decides acceptance |
| c6 | loop clause bindings are recorded `any`, other bindings precisely |
| d1, d4 | invariant admission for List, MutableVector, ImmutableSet, nested Lists, string refinements; covariant lub |
| d2, d3 | the widening idioms that are rejected and accepted |
| d5 | scalar literal admitted, List literal not |
| e1, e2 | the UTF-8 route to a character; no Int-to-UnicodeChar conversion |
| f1, f2 | the escape vocabulary; raw control characters |
| j1, j2, j3 | the diagnostics of section J |

**Type matrix.** `python3 -I audit/text-collection-precision/tools/matrix.py`
(section H; exit status 1 if an operation produced no diagnostic or an
unexpected one).

**Benchmark.**

```
tclsh9.0 audit/text-collection-precision/tools/bench.tcl -sizes "250 1000 4000" -markdown
tclsh9.0 audit/text-collection-precision/tools/bench.tcl -sizes "4000 16000 64000" -backends cranelift -markdown
```

Strategies: fold-concat, tail-concat, halving-concat, bytes-join,
flat-bytes, fold-append-char, chars-via-bytes, test-joined. Results in
section G. Machine: a 4-core Intel Xeon @ 2.30 GHz container, Tcl 9.0.1,
rustc 1.97.0, `botlish-native` in release mode.

## L. Architectural conclusions

* **Compiler defect:** loop clause bindings are missing from HIR's binding
  table (C.2). The checker is right; the record every other analysis and
  the language server read is not.
* **Incomplete contract:** `encode_utf8`'s element type depends on which
  modules the compilation loaded (C.3). The native's guarantee is
  unconditional; its static statement is not.
* **Language choice:** invariant admission of collections (D) and the
  minimal escape vocabulary (F). Both are recorded decisions; the first is
  stricter than soundness needs and inconsistent with the compiler's own
  lub, the second leaves arbitrary scalars without a visible spelling.
  Changing either needs a language-design decision, not a fix.
* **Library gaps:** an Int-to-UnicodeChar conversion (E), and a linear
  String construction from a List (G). The standard library carries
  workarounds for the first; Compilerpedia recommends a quadratic test-library
  function for the second.
* **Optimizer gap (known, deferred):** a fold intermediate is never a
  construction plan, so folds that build Strings or Lists copy O(n²) natively
  (G.3).
* **Documentation and diagnostics:** four stale or incomplete entries and a
  result diagnostic that omits the inferred type (J).

The distinctions the language draws held up under every probe: a value
never silently changed domain, no conversion was implicit, every invalid
Unicode input became a declared error, and the four backends agreed on
every accepted program. What made the TUI library verbose is a recording
defect, one non-local typing rule, a conservative variance rule and two
missing operations, each separable.

## M. Recommended implementation sequence

Each is an independent milestone; the order is by size and by how much later
work it unblocks. None combines a language change with another.

### M1. Record loop clause binding types

Done: LOOP-CLAUSE-BINDING-TYPE-CORRECTNESS-MILESTONE-1.md (probes `c1` and
`c6` record the precise types since).

* **Problem.** `hir::bindingType` and the hover report `any` for every loop
  element, counter and lockstep clause binding (probe c6).
* **Reproducer.** Probe c6; hover over `b` in `loop b in s.encode_utf8()`
  with `std::byte` imported.
* **Rule.** A loop clause binding's recorded type is the type the checker
  gives its references: the element type (`IterationElementOf` /
  `hir::iteration::ElementOf`), `int` for a counter, as the fold's
  intermediate records "what the body was last walked under".
* **Components.** `hir/types.tcl`'s `listloop`, `countloop`, `lockloop` cases
  (the main inference walk; a semantic instance's walk must not overwrite the
  generic record); the readers in C.2 then get precise types.
* **Compatibility.** The checker's own verdicts read the flow facts, not
  the record, so they do not change through it. The conservative readers
  become precise: the static-decision dependency edges (`hir::staticdeps`:
  fewer edges, so fewer or reordered builds, never another outcome by
  design), method-decision stand-ins (certification is unaffected) and
  callable facts (`hir::completions::BindingFact`), where a more precise
  fact can discharge an error obligation a program carries today. Those are
  the risk.
* **Tests.** Probe c6's expectations flip; `tests/compiler-service.test`,
  `tests/lsp.test`, `tests/static-economics.test`,
  `tests/structural-contract-completions.test`, `tests/hir-interchange.test`
  (binding types are in HIR text), the static-decision harnesses
  (`static-decisions.yml` in CI), the golden corpus on all four backends.
* **Benefit.** The hover tells the truth; analyses that read the binding
  table stop treating loop variables as unknown.
* **Risks, open choices.** Whether a binding whose walk differs per semantic
  instance records the generic walk's type (recommended) or a join.

### M2. Documentation and diagnostic corrections

Done: TEXT-AND-COLLECTION-DOCUMENTATION-AND-DIAGNOSTICS-MILESTONE-1.md (probe
`j3` pins the result type in the diagnostic since).

* **Problem.** Section J's four documentation problems and the result
  diagnostic.
* **Rule.** State what the compiler does: `decode_utf8` exists; the
  `List[Byte]` type's condition (until M3); `task.string-concatenation`
  names the linear idioms (self-tail recursion, the bytes route) and stops
  recommending `std::test::joined`; `concept.strings` lists the five
  escapes and says there is no numeric escape; README §19 marked historical;
  the result TYPE diagnostic names the inferred type
  (`(result type: List[int[std::byte::Byte]])`).
* **Components.** `compilerpedia/notes/stdlib.notes` (then
  `tools/compilerpedia.tcl generate`), `compilerpedia/topics/tasks.topic`,
  `concepts.topic`, `docs/README.md`, `hir/range.tcl:1905`.
* **Compatibility.** The message change moves golden suites' and tests'
  pinned texts (`rejects_at` pins position, not text; tests that match the
  message do).
* **Tests.** `tools/compilerpedia.tcl check`, `tests/compilerpedia.test`, the
  tests that pin "does not prove declared type", probe j3's expectation.
* **Benefit.** The next clean-room agent finds `decode_utf8` and the linear
  idioms.

### M3. `encode_utf8`'s element type independent of imports

* **Problem.** Probes c3, c4/c5.
* **Rule.** `std::str::encode_utf8(s)` is `List[std::byte::Byte]` in every
  compilation.
* **Components.** Either the loader declares the types a registered result
  shape names whenever the native's namespace is imported (as
  `hir::cabi::NamespaceTypeDecls` declares `std::ffi::c`'s scalars), or
  `std::byte::Byte` becomes a domain registered with the core. The
  `typed` shape's soundness check (`ProvesType`) stays.
* **Compatibility.** Programs that import `std::str` without `std::byte`
  get precise element types: some rejected programs become accepted (c4); a
  join that only `any` covered may now be a FOLD-INTERMEDIATE-TYPE or a
  TYPE error where `any` passed before, and a method decision may change.
  The golden corpus, the warning gate and the method-resolution oracle must
  show which.
* **Tests.** Probes c3-c5; `tests/application-modules.test`,
  `tests/std-namespace.test`, `tests/hir-cache.test` (a new front-end input
  must be in `surface::cache::Key`), the isolation and interchange audits
  (a newly declared registry entry), the golden corpus.
* **Risks, open choices.** Which mechanism; whether other `typed` shapes
  exist or are planned (today `encode_utf8` is the only one).

### M4. Linear text construction

* **Problem.** Section G: no linear String construction from a List; the
  documented answer is quadratic.
* **Rule.** `std::str::join(parts: List[str], separator: str) -> str`:
  total, one String of exactly the total length, each part copied once;
  `join(parts, "")` is concatenation. Optionally `std::str::from_chars(chars:
  List[UnicodeChar]) -> str`, measured against `join` of one-character
  Strings first.
* **Components.** `core/strings.tcl` (registration, Tcl implementation),
  `native/src/runtime/ops.rs` (one allocation, as `rt_list_flat` does for
  Lists), `native/lower.tcl`'s op table, Compilerpedia notes.
* **Compatibility.** Additive as a name (no module but the standard library
  can declare a `std::str` member), not as a method-call candidate: a
  program that imports `std::str`, defines its own `join` and calls
  `parts.join(sep)` becomes AMBIGUOUS-METHOD-CALL (checked with the existing
  `lowercase`: a program defining `fn lowercase(s: str)` and calling
  `"ABC".lowercase()` is ambiguous today). The corpus must be searched for
  such names before choosing one.
* **Tests.** Cross-backend unit tests (empty List, empty separator, astral
  scalars, a 64k-part List), the copy volume (`native::allocationReport`:
  bytes copied equal the result's size), GC stress, a golden suite.
* **Benefit.** Linear text construction on every backend, without relying
  on an optimization; `std::test::joined` can be written over it.
* **Risks, open choices.** Whether `from_chars` earns its place.

### M5. `std::char::from_scalar_value`

* **Problem.** Section E: no Int-to-UnicodeChar conversion; the standard
  library's own workaround.
* **Rule.** Section I's contract.
* **Components.** A native in `core/unicodechar.tcl` and `ops.rs`, with
  call-specific completion facts (a `-bounds`-style registration over the
  two intervals), or a Botlish function in a `std::char` module over an
  internal total intrinsic reached only through the check (as
  `std::actor::recover` is). A new builtin error `InvalidScalarValue` (the
  builtin error table, `std::compiler::DiagnosticCode` is unaffected).
* **Compatibility.** Additive.
* **Tests.** Every boundary (−1, 0, 0xD7FF, 0xD800, 0xDFFF, 0xE000,
  0x10FFFF, 0x110000, huge Ints), static decisions (constant in, constant
  out, a Byte argument, `scalar_value(c)` round trip), four backends. As for
  M4, a new member is a new method-call candidate (a program's own
  `from_scalar_value` called method-style would become ambiguous).
  Then `stdlib/windows/fs.bot`'s `push_utf8`/`decoded` can be replaced by it
  in a change of its own.
* **Risks, open choices.** Native versus Botlish-over-intrinsic; whether
  the completion analysis reads interval facts for the surrogate gap (so
  `from_scalar_value(scalar_value(c))` needs no handler).

### M6. A scalar escape in literals (language-design decision)

* **Problem.** Section F: arbitrary scalars have no visible spelling.
* **Rule.** `\u{H...}`, one to six hex digits naming a scalar value, in
  String and character literals, with M5's validity rule; no `\x`, `\e`,
  `\0`.
* **Components.** `surface/lexer.tcl`'s `String` and `Char`, the token IR
  (`surface/tokens.tcl`) and the generated editor grammars, whose escape
  pattern is `\\[\\"nrt]` (`tools/editor-grammars.tcl`, TextMate and Vim;
  regenerate them), ONE-CHAR-STRING-LITERAL's examples, Compilerpedia's
  `concept.strings`, UNICODE-CHAR-LITERALS.md's escape section.
* **Compatibility.** Additive: every `\u` is a syntax error today.
* **Tests.** Lexer tests for each diagnostic, the literal's value on four
  backends, HIR text and interchange round trips, the front-end cache,
  syntax recovery past a bad escape, the compiler service's text positions.
* **Risks, open choices.** Braced versus fixed-width digits; whether the
  decision waits for M5.

### M7. Covariant admission of immutable collections (language-design decision)

* **Problem.** Section D: an O(n) copy to widen a type the compiler's own lub
  already widens.
* **Rule.** `List[S]` (and `ImmutableSet[S]`) admissible where `List[T]`
  (`ImmutableSet[T]`) is declared when `S <: T`, at parameters and results;
  MutableVector and MutableArray stay invariant (at least for place
  parameters; value parameters only after the copy-convention audit).
* **Components.** `hir::range::AggregateAdmits`.
* **Compatibility.** More calls valid: a method-style call with several
  candidates could become AMBIGUOUS-METHOD-CALL where one candidate was valid
  before; imprinting (`List[T]` against `List[S]`), semantic instance entry
  facts and specialization keys see new argument types. The
  method-resolution oracle, the golden corpus and the static-decision
  comparison must show no change for existing programs.
* **Tests.** The invariance pins of MINIMAL-APPLIED-LIST-TYPES.md flip (they
  are tests of the old rule); probes d1-d4; place-parameter and mutable
  vector negatives.
* **Risks, open choices.** The decision itself; whether the literal case
  (`[27]` for `List[Byte]`) is addressed by contextual literal typing
  instead (a different rule, not covariance).

### M8. Construction plans through folds (optimizer, already planned)

Since the census was measured, FOLD-VIRTUAL-LIST-CONSTRUCTION-MILESTONE-1.md
reached main: a fold carrying `concat` is linear natively on current main,
while a fold or a recursion carrying `append_char` still copies O(n²)
(TEXT-AND-COLLECTION-DOCUMENTATION-AND-DIAGNOSTICS-MILESTONE-1.md, section D,
measured it; section G.2's fold rows are the tree of f2787af0).

* **Problem.** Section G.3: folds carrying `concat`/`append_char`/`append`
  copy O(n²) natively.
* **Rule.** FOLD-LOOPS-MILESTONE-1.md's deferred item 2: a fold whose
  intermediate is only extended carries a plan.
* **Components.** `hir/construction.tcl`, native lowering's `LoopResult*`.
* **Benefit.** Existing programs become linear without source changes.
  Independent of M4 (M4 gives a guarantee a reader can see; M8 an
  optimization).

Recorded outside these milestones: `std::byte_store`'s visibility and
`any`-typed natives (J, diagnostic 2), a method-resolution and namespace
question.

## N. Remaining uncertainties

* **The TUI report itself** was not available; the reproductions match its
  wording (hover of a loop variable, `List[int[Byte]]` spelling, the
  `decode_utf8(from_list(...))` route), but whether its agent saw `any` in
  a hover, in `hir::bindingType`'s output or in a program without
  `std::byte` loaded cannot be established. Both mechanisms are documented.
* **Platforms.** Every probe ran on Linux x86-64 only. The findings are
  front-end and standard-library behavior, identical by construction on
  Linux AArch64, macOS and Windows, but not run there.
* **Native measurements** are one container's; the copy volumes are exact,
  the times indicative.
* **Not investigated:** iteration over the loop protocol's collections
  (MutableMap, MutableSet, ImmutableMap) beyond the MutableVector case;
  `std::list::get`; DecimalRounded and refined List lengths as elements;
  the effect of M1 on static-decision economics (to be measured in M1).
* **Decisions requiring language-design input:** M6 (escape grammar), M7
  (variance), and for M3 which mechanism makes a library type available.
