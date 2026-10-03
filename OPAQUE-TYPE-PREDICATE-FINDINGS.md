# `UriQueryValue?` and opaque types: findings for a future milestone

Status: **findings only, no code changed.** This is planning input for a
separate milestone, the next step in the "push library semantics into
ordinary Botlish" series (`NATIVE-URI-ESCAPE.md`, `NATIVE-EMAILISH.md`,
`NATIVE-TCL-UNICODE.md`, `NATIVE-OPAQUE-REFINEMENT.md`,
`R2-ORDINARY-EMAILISH-PREDICATE.md`). Every behavior below was checked at
`85223b7` (reproduction in section 7).

## 1. Where this came from

`native::report` throws on `bench/refined-checks.bot` (and the frozen
`.ir`):

```
NATIVE UNSUPPORTED {native UriQueryValue?} ::
  bench/refined-checks.bot:32:16: e24: native lowering does not support native
  UriQueryValue?: the native "UriQueryValue?" has no native implementation
```

The throw comes from the report's generic lowering (`-specialize 0`): in
`check`, `q` is a parameter of unknown type, so `UriQueryValue?(q)` cannot be
decided statically. `native::report` tolerates only `NATIVE UNSUPPORTED
struct-shape` there. The specialized lowering proves `q : str[UriQueryValue]`
from `uriEscape`'s result type and folds the call (milestone 4,
`NATIVE-OPAQUE-REFINEMENT.md`), which is why the benchmark itself runs.
This turned up while fixing `native::report`'s inlined-leaf accounting
(`328efc6`).

The proposed fix was to do for `UriQueryValue?` what R2 did for `emailish?`:
reimplement it in ordinary Botlish, give it a lowercase name, and remove the
intrinsic. That does not transfer directly; this document records why, and
the options.

Requirement recorded for the eventual milestone: any Botlish written for it
should use the recently added language features where sensible: struct
destructuring (`STRUCT-DESTRUCTURING.md`), `elif` (`ELIF.md`), and the
counted, collecting and returning loop forms (`R2A3-COUNTED-LOOPS-FINAL-SOURCE.md`,
`COLLECTING-LOOPS.md`, `RETURNING-ITERABLE-LOOPS.md`).

## 2. Current behavior

| Program | interp | cranelift | cranelift-generic |
|---|---|---|---|
| `q = uriEscape("a b")`; `UriQueryValue?(q)` | `true` | `true` (folded statically) | `true` (folded statically) |
| `fn f(x): UriQueryValue?(x)`; `[f(uriEscape("a b")), f("abc")]` | `[true, false]` | NATIVE UNSUPPORTED | NATIVE UNSUPPORTED |
| `UriQueryValue?("a%26b")` | `false` | NATIVE UNSUPPORTED | NATIVE UNSUPPORTED |

- **The gap is not limited to `native::report`.** Native supports
  `UriQueryValue?` only where HIR decides it statically, in either mode. A
  dynamic test is unsupported by design: milestone 4 kept it so ("absence of
  static proof is not treated as proof of absence"), and
  `native-validator-predicate-opaque-still-unsupported` pins it. In the
  native coverage run, refined-11 and refined-12 are `unsupported` with
  `{native UriQueryValue?}`.
- **Native values carry no evidence.** `fn g(s) -> UriQueryValue: uriEscape(s)`
  returns `"a%20b"#{UriQueryValue}` on interp but plain `"a%20b"` on
  cranelift. On native, the static type is the only proof that exists.

## 3. Why the `emailish?` recipe does not transfer

The type system has two kinds of named string type (`core/type.tcl`,
`core::type::validate`):

- **Validator types** (`Emailish`). Membership is a property of the text,
  decided by a Tcl validator. Evidence on a value is only a cached proof.
- **Opaque types** (`UriQueryValue`, registered `-opaque 1`). Membership
  *is* runtime evidence, and only trusted Tcl natives attach it
  (`core::value::withEvidence`; only `uriEscape` does).

An ordinary Botlish function can only inspect text, so it can implement a
validator type's predicate but not an opaque type's. A Botlish
`uri_query_value?` would answer a different question (is this well-formed
escaped text?) than `UriQueryValue?` does today (was this produced by
`uriEscape`?).

**What R2 actually moved for `emailish?`.** Only one of its three pieces is
Botlish:

1. The type is registered in Tcl as a validator type:
   `core::type::register Emailish -base str -validator <Tcl regex>`
   (`lib/web.tcl`).
2. The predicate is registered in Tcl: `core::type::definePredicate Emailish
   emailish? "" {web emailish?}`. That registration's `-tests-type
   str[Emailish]` is the source of "true means the argument is an
   `Emailish`"; the compiler reads it from the registry, not from Botlish.
3. The native implementation is ordinary Botlish, `web::emailish?(v)`
   (`lib/web.bot`), which just returns a Bool. The `-module-fn` bridge
   (`native/prepare.tcl`) points cranelift calls at it.

The Tcl regex stays the reference meaning on interp and compile, so the same
language is defined twice and held together by parity tests. The
"intrinsic" was only partly removed for `emailish?` too.

## 4. Proof syntax: what exists and what is missing

The question raised: *is the real problem that Botlish has no proof syntax
for opaque types yet?* Partly. Proof syntax covers producing and consuming
proofs; it does not by itself make a runtime test possible.

**Exists: consuming a proof.** A parameter annotation is a compile-time
proof obligation, never a runtime check (`STRICT-TYPED-PARAMETERS.md`), and
it already works with opaque types. Under strict compilation:

| Program | Result |
|---|---|
| `fn f(q: UriQueryValue): length(q)`; `f(uriEscape("a b"))` | compiles, `5` on interp and cranelift |
| the same `f`; `f("a%20b")` | rejected: argument cannot be proven to satisfy `str[UriQueryValue]` |
| the same `f`; `f(lowercase(uriEscape("a b")))` | rejected (string operations drop refinements) |
| `fn g(s) -> UriQueryValue: uriEscape(s)` | compiles |

**Missing: minting a proof.** `fn h(s) -> UriQueryValue: s` is rejected:
nothing in source can establish `UriQueryValue`. Only a Tcl native can
(`uriEscape`'s `-impl` attaches the evidence; on cranelift, its registered
result type is forced onto `web::uri_escape_text`'s result through
`nativeResultOverride`). Source code also cannot declare an opaque type at
all: the only source type declaration is an integer range (`type Byte = Int
in 0..255`, `hir/sourcetypes.tcl`).

**Not solved by proof syntax: a runtime test.** `UriQueryValue?` asks at run
time where a value came from. Static proof syntax cannot answer that, and
native has no runtime evidence to consult. The generic-mode failure in
section 1 is exactly this case.

**Also missing: predicate-refined source types.** Even a validator type
cannot be declared in source. Finishing the job R2 started for `emailish?`
(no Tcl registration, no Tcl regex) would need a declaration such as
`type UriQueryValue = Str where uri_query_value?`.

Related, for validator types: a literal is not accepted by a parameter
annotation either. `fn e(s: Emailish)` with `e("a@b.io")` is rejected,
because the compiler does not run validators on constants.

## 5. Options

### A. Make `UriQueryValue` structural (existing mechanism)

Move it from the opaque kind to the validator kind, exactly as `Emailish`
is set up. No type-system extension is needed.

- `lib/web.tcl`: `core::type::register UriQueryValue -base str -validator
  <regex>` (replacing `-opaque 1`), where the regex accepts a sequence of
  RFC 3986 unreserved characters (`A-Za-z0-9 - . _ ~`) and `%` followed by
  two hex digits. Then `definePredicate UriQueryValue uri_query_value? ""
  {web uri_query_value?}` and `core::native::alias UriQueryValue?
  uri_query_value?`.
- `lib/web.bot`: `web::uri_query_value?(s)`, a counted loop over the
  characters with `elif` arms for unreserved / `%XX` / anything else.
- `uriEscape` keeps its registration and its result type `str[UriQueryValue]`.
  Its output now satisfies the type by its text, so its Tcl `-impl` no
  longer has to attach evidence.

Effects:

- The section 1 failure and the section 2 gaps go away: a dynamic test
  becomes an ordinary call of `web::uri_query_value?`, and a test the type
  already proves still folds statically.
- The type's meaning changes from "produced by `uriEscape`" to "well-formed
  percent-encoded text". The safety property ("safe to embed as a query
  value") is a property of the text, so it is unchanged; the provenance
  guarantee is lost. Test changes:
  - refined-12: `UriQueryValue?("a%26b")` becomes `true`.
  - refined-11: `UriQueryValue?(lowercase(uriEscape("x y")))` becomes `true`
    at run time (its static type stays plain `str`).
  - refined-13 needs a malformed fake result (such as `"a b"`) to keep
    exercising the result-contract check: `test-fake-escape`
    (`tests/helpers.tcl`) returns its argument unchanged while claiming
    `UriQueryValue`, so `"abc"` would satisfy the type. Its other user,
    `tests/compiler-opt.test`, passes `"x"`, which would also be valid.
  - `native-validator-predicate-opaque-*` and
    `native-refinement-propagation-unknown-value-*` change meaning.
- Opaque types lose their only real user. The `-opaque` machinery would
  need a test-only opaque type to stay covered.
- Design point: accept uppercase hex only (matching `uriEscape`'s output),
  or both cases (RFC 3986 treats hex case-insensitively but tells producers
  to emit uppercase).
- The intrinsic is only partly removed, as for `emailish?` (section 3).

### B. Proof route (extends the language)

Keep provenance as the meaning, and make it provable in source instead of
testable at run time.

- **Declaration and minting:** source syntax to declare an opaque type in a
  module, plus a constructor only that module can call (for example,
  `opaque type UriQueryValue = Str` in `web`, minted inside
  `web::uri_escape`). `uriEscape` then becomes pure Botlish: lowercase name,
  no Tcl `-impl`, no `-module-fn` bridge.
- **No runtime test for opaque types:** a value is proven to be a
  `UriQueryValue`, never tested. `bench/refined-checks` would annotate
  `q: UriQueryValue` instead of testing `UriQueryValue?(q)`, and the
  section 1 failure disappears because nothing is left to test.
- refined-11, refined-12 and refined-13 turn from runtime results into
  compile-time rejections (the section 4 table already shows how those
  rejections read).
- Open questions:
  - The exact syntax, and whether privacy is per module or per file.
  - Whether interp keeps runtime evidence as a cross-check, or the
    machinery (`core::value::withEvidence`, the `"..."#{Name}` display used
    by the differential tests) is retired.
  - What happens to code that relies on `T?` for opaque types; the
    `UriQueryValue?` compatibility alias would have nothing to alias.

### C. Predicate-refined source types (extends the language)

`type NAME = Str where predicate?`: a validator type whose predicate is an
ordinary Botlish function, with no Tcl registration and no Tcl validator.
This is what would finish removing the intrinsic for `emailish?`, and it
would turn option A into a pure-Botlish change. It complements B rather than
replacing it.

### D. Native evidence representation (rejected direction)

Give native strings runtime evidence so dynamic opaque tests can run. This
costs String layout, GC and every String operation (each must drop or
propagate evidence), and it reverses milestone 4's deliberate choice. Listed
only for completeness.

## 6. Questions to settle when planning

1. Keep opaque (provenance) types at all, or make them structural (A)?
2. If opaque types stay: should `T?` exist for them, or only static proof (B)?
3. Where should a predicate's single meaning live: the Tcl validator (today),
   or Botlish source (C)?
4. Order: B and C share declaration syntax (`type ... = Str ...`), so they
   are probably best designed together, even if built in separate steps.

## 7. Reproduction

Run from the repository root with `LANG=C.utf8 LC_ALL=C.utf8 tclsh9.0` and
the native backend built:

```tcl
set ::argv {}
source tests/helpers.tcl
source surface/surface.tcl
# Section 1.
catch {native::report [surface::readProgramFile [file join [pwd] bench refined-checks.bot]]} r o
puts "[dict get $o -errorcode] $r"
# Section 2.
proc sourceIR {text} { hir::lower [surface::compile $text t.bot -strict 0] }
set ir [sourceIR "fn f(x):\n    UriQueryValue?(x)\n\n\[f(uriEscape(\"a b\")), f(\"abc\")\]\n"]
foreach b {interp cranelift cranelift-generic} { puts "$b [lrange [outcomeUnder $b $ir] 0 2]" }
# Section 4: strict compilation, rejected with CORE SEMANTIC TYPE.
catch {surface::compile "fn f(q: UriQueryValue):\n    length(q)\n\nf(\"a%20b\")\n" t.bot} r o
puts "[dict get $o -errorcode] $r"
```
