# Symbolic native result-type identity: hardening `{typed NAME}`

## Outcome

`encode_utf8`'s native result-shape metadata (`core/strings.tcl`,
`-result-shape {typed Byte}`, STATIC-COMPLETION-PROOFS.md's "UTF-8 result
type") resolved the symbolic name `Byte` lazily against whatever the
compiling program's own source-defined-type registry currently held, and
narrowed the result to `List[Byte]` the moment that name resolved to
*anything* -- with no check that the resolved type's own domain actually
admits the values the native guarantees. A same-spelled but narrower or
unrelated program-local `Byte` (e.g. `type Byte = Int in 0..15`) could
therefore have been falsely credited with UTF-8's real `0..255` guarantee,
purely because the two spellings matched.

This milestone closes that gap. `{typed NAME}` becomes `{typed NAME LO
HI}`: the native's own semantic fact (every result element is an Int in
`LO..HI`) is now carried in the metadata itself, and `hir/types.tcl`'s
`ShapeResult` narrows to `NAME` only after proving, with the same
admissibility check (`hir::range::ProvesType`) a declared function result
type is already held to, that `LO..HI` is a subset of whatever `NAME`
currently resolves to. Failing that proof -- an unknown name, an
incompatible kind, or a domain too narrow -- falls back to the native's own
plain declared `-result-type`, exactly as before whenever `NAME` was
unresolved. The canonical standard-library declaration (`type Byte = Int in
0..255`, `lib/byte.bot`) still proves membership trivially, so
`encode_utf8` is still typed `List[Byte]` and `lib/web.bot`'s clean,
conversion-free path is unaffected. No runtime representation, error
semantics, completion-proof semantics, or range-analysis precision changed;
`encode_utf8` is confirmed to be the only current use of this metadata kind.

**FINAL SEMANTIC SOURCE FENCE ESTABLISHED** -- see the end of this report.

## The symbolic-name soundness issue

A native like `encode_utf8` is registered once, at Tcl-process bootstrap
(`core.tcl` sources `core/strings.tcl` unconditionally), long before a
compiling program's own `type Byte = Int in 0..255` declaration
(`lib/byte.bot`, parsed per-compilation) exists in `core::type`'s registry.
`-result-shape {typed Byte}` therefore stored `Byte` as a bare symbolic
name, resolved only later, lazily, at ordinary whole-program type-inference
time (`hir/types.tcl`'s `ShapeResult`), against whatever the compiling
program's own source-defined-type registry held *at that point*. This
lazy-resolution design (SOURCE-DEFINED-INTEGER-DOMAINS.md's "compilation
isolation": the same spelling can validly denote a different domain in two
different programs the same long-lived Tcl process compiles) is correct and
is preserved unchanged by this milestone.

What was unsound is what happened *after* resolution: the pre-existing code
was

```tcl
lassign $shape _ name
if {![core::type::isNamed $name]} {
    return $result
}
return [MakeList $name]
```

-- narrowing to `List[NAME]` as soon as `core::type::isNamed $name` was
true, with no check on what `NAME`'s own domain actually was. A compiling
program that happened to declare a same-spelled but different type --
narrower (`type Byte = Int in 0..15`), or (hypothetically; see "Incompatible
same-name kind" below) an unrelated kind entirely -- would have been
credited with UTF-8's real `0..255` guarantee purely by name match. Nothing
in this codebase's standard library actually declares such a `Byte`
(`lib/byte.bot`'s is canonical), so this was latent, not yet triggered in
practice -- but the compiler's own soundness argument for `{typed NAME}`
depended on an assumption ("whatever the program calls Byte is close enough
to what encode_utf8 means") the metadata itself never stated or checked.

## Current `{typed NAME}` semantics

### Before this milestone

`{typed NAME}`: "the result is `List[NAME]` if a source-defined type
spelled `NAME` is currently registered" -- name resolution alone was taken
as proof of semantic membership.

### After this milestone

`{typed NAME LO HI}`: "every result element is, as a fact the native's own
implementation actually guarantees (never a guess from the native's name),
an `Int` in `LO..HI`. The result is additionally `List[NAME]` if a type
spelled `NAME` is currently registered *and* its own domain provably admits
every value in `LO..HI`." Name resolution is necessary but no longer
sufficient; domain admissibility is proven, not assumed.

## Chosen identity/admissibility model (spec item 13)

Audited alongside `core/type.tcl`'s existing source-defined-type machinery
(`isNamed`, `normalize`, `integerFacts`, `subtype`) and
`hir/sourcetypes.tcl`'s per-compilation registration:

- **Nominal identity** is already strict and pre-existing, unrelated to this
  milestone: two source-declared types with identical domains are distinct
  (`tests/source-types.test`'s `source-type-nominal-distinct` --
  `type A = Int in 0..15` and `type B = Int in 0..15` do not subtype each
  other). A type is identified by its own registration, not by its domain.
- **Domain admissibility** is a separate, pre-existing relation
  (`core::type::integerFacts` + `hir::range::ProvesType`,
  `core::type::integerDomainSubset`) already used to decide whether a
  *value* (or a proven value range) is a member of a *named* type.

`{typed NAME LO HI}`'s own question is neither of these directly: it is
"does the *currently-resolved* type spelled `NAME` admit the native's
guaranteed value domain?" -- i.e. **any currently-resolved type named NAME
whose domain the native's result provably satisfies**, not "one canonical
nominal declaration" (there is no canonical `Byte` at the compiler level;
`lib/byte.bot`'s is canonical only by *library convention*, not by anything
the compiler enforces or could enforce under the existing compilation-
isolation design). This is consistent with the pre-existing lazy-resolution
architecture (item 4/SOURCE-DEFINED-INTEGER-DOMAINS.md): the compiler
already accepts that "Byte" denotes whatever the compiling program most
recently declared under that spelling; this milestone's only change is
requiring that whatever it denotes actually admits the native's guaranteed
values, via the same domain-admissibility check already trusted for
function result-type verification, rather than trusting the spelling alone.

## How native semantic facts are represented

`-result-shape {typed NAME LO HI}` (`core/native.tcl::ValidShape`): `NAME`
is the symbolic type name (as before); `LO`/`HI` are the native's own fixed,
argument-independent guarantee that every result element is an Int in
`LO..HI` -- a fact belonging to the native's own contract, exactly the way
`-result-range nonneg`/`collection-length` already are (`core/native.tcl`'s
pre-existing "a guarantee the implementation actually upholds, never a
guess from the native's name" discipline, now extended to `List` element
facts as well as scalar-Int-result facts). `encode_utf8` declares `{typed
Byte 0 255}`: every UTF-8 byte is definitionally in `0..255`, independent of
whatever `Byte` happens to mean in the compiling program.

## How resolved source types are validated

`hir/types.tcl::ShapeResult`'s `typed` case:

```tcl
lassign $shape _ name lo hi
if {![core::type::isNamed $name]} {
    return $result
}
set resolved [core::type::normalize $name]
if {![hir::range::ProvesType [dict create min $lo max $hi] $resolved]} {
    return $result
}
return [MakeList $name]
```

`hir::range::ProvesType` is pre-existing, general machinery (added by the
static-completion-proofs milestone specifically to decide "is a value of
this proven Range accepted by this declared type", already used for
`verifyDeclaredParams`/`verifyDeclaredResults`): it reads `NAME`'s own
domain from `core::type::integerFacts` (which itself reads
`core::type::metadata`, i.e. the live registry `hir/sourcetypes.tcl`
populates per-compilation) and checks `LO..HI` is a subset. No second,
incompatible notion of "value range fits type" is introduced; no domain is
hardcoded for any name; `NAME`'s domain always comes from the registry.

## Canonical Byte case

`lib/byte.bot`'s `type Byte = Int in 0..255`: `core::type::integerFacts`
gives `{min 0 max 255}`; encode_utf8's own `{min 0 max 255}` is a subset ⟹
`ProvesType` succeeds ⟹ `encode_utf8(...) : List[Byte]`, unchanged from
before this milestone. No `lib/byte.bot`, `lib/ascii.bot`, or `lib/web.bot`
source changes were needed.

## Narrow incompatible Byte case

`type Byte = Int in 0..15`: `integerFacts` gives `{min 0 max 15}`;
encode_utf8's `0..255` is *not* a subset (255 > 15) ⟹ `ProvesType` fails ⟹
falls back to the native's own plain declared `-result-type`, `list`. UTF-8
may emit values above 15, so this is exactly the required conservative
result.

## Compatible superset case

`type Byte = Int in 0..1000`: `integerFacts` gives `{min 0 max 1000}`;
encode_utf8's `0..255` is a subset ⟹ `ProvesType` succeeds ⟹
`encode_utf8(...) : List[Byte]`. This is sound and intentional under the
chosen model (spec item 13): the mechanism checks semantic admissibility of
whatever is currently resolved under that spelling, not identity with a
specific canonical declaration -- Botlish's nominal-type semantics do not,
and structurally cannot (per "compilation isolation" above), single out one
declaration as *the* canonical `Byte` at the compiler level. This
demonstrates the fix is not a disguised `name == "Byte"` special case: a
same-spelled 0..1000 domain is accepted on its own semantic merits, a
same-spelled 0..15 domain is rejected on its own semantic merits, and
nothing here inspects the string "Byte" itself.

## Incompatible same-name kind case

Botlish's current type-declaration grammar (`surface/parser.tcl`'s
`TypeDecl`) only ever produces int-based types: `"type NAME = PARENT in
DOMAIN"` requires `PARENT` to be `Int` or another already-int-based type
(`hir/sourcetypes.tcl::RegisterOne` rejects any other parent with "is not an
integer-domain type"). There is therefore no legal Botlish *source*
construct that declares a non-int type spelled `Byte` -- this case cannot
arise from any program `hir::sourcetypes.tcl` accepts today.

The general mechanism is nonetheless sound against it, and this is tested
directly (not merely asserted): `hir::range::ProvesType`'s own "no domain
restriction" branch checks `[core::type::base $type] eq {int}`, so a
same-spelled type registered with a non-int base (the same
`core::type::register -base str ...` pre-existing machinery every
compiler-registered validator type -- `Emailish`, `UriQueryValue`,
`NonEmpty` -- already uses) makes `integerFacts` return `{}` and
`ProvesType` correctly return 0, falling back. `tests/symbolic-type-
identity.test`'s `symbolic-type-identity-incompatible-kind` exercises this
directly against `hir::types::ShapeResult`.

## Fallback behavior

Every failure mode -- unregistered name, narrower domain, incompatible
kind -- takes the identical fallback path: `return $result`, the native's
own plain declared `-result-type` (`list` for `encode_utf8`), unchanged
from what this codepath already did when `NAME` was simply unresolved. No
new fallback type was invented, no runtime check or conversion was
inserted, and no partial/best-effort narrowing is attempted.

## Audit of all symbolic typed-result metadata

Searched the whole tree for `-result-shape {typed`:

```
core/strings.tcl:73:    -result-shape {typed Byte 0 255}
```

`encode_utf8` is confirmed to be the only current use of `{typed NAME ...}`
result-shape metadata; `hir/specialize.tcl`'s own per-instance re-inference
has no independent handling of this shape kind -- it calls the same
`hir::types::ShapeResult` ordinary inference does (`hir/types.tcl`'s own
comment on `$spec`), so the fix covers both paths with one change.

## UTF-8 result typing

`encode_utf8(text) : List[Byte]` under the canonical standard-library
`Byte`, confirmed by direct HIR type inspection (`hir::typeOf` +
`hir::types::show`, not indirectly from backend output) for ASCII,
multi-byte, and astral inputs; `list_get(encode_utf8(text), 0) : Byte`
follows automatically from `list_get`'s own pre-existing, fully generic
`{element 0 1}` shape -- zero `list_get`- or `Byte`-specific code, as
before this milestone.

## Web regression

`lib/web.bot` is unchanged (confirmed: `git diff` shows no change to this
file across the whole milestone). Its clean path --

```botlish
fn esc_char(c):
    bytes = encode_utf8(c)
    if list_length(bytes) == 1:
        b = list_get(bytes, 0)
        if is_unreserved(b):
            c
        else:
            esc_bytes(bytes, 0, "")
    else:
        esc_bytes(bytes, 0, "")
```

-- still compiles with zero diagnostics: `list_get(bytes, 0)`'s inferred
`Byte` type still statically satisfies `is_unreserved(b: Byte)`'s declared
parameter with no conversion, handler, or fallback reintroduced. Verified
both by `tests/symbolic-type-identity.test`'s own direct compile-and-run of
`web::uri_escape_text` over ASCII/multi-byte/astral text (zero diagnostics,
correct percent-encoded output) and by `tests/native-uri-escape.test`'s
pre-existing, unmodified four-backend text-parity table (part of the full
suite below).

## URI punctuation regression

`lib/web.bot`'s module initializer remains exactly

```botlish
additional_unreserved_chars = byte::set(['-', '.', '_', '~'])
```

-- unchanged source, and (since the file is untouched) unchanged behavior;
confirmed by `tests/web-unreserved.test`'s pre-existing
`web-unreserved-set-built-once`/`web-unreserved-set-exact-members` tests
passing unmodified as part of the full suite.

## Error/completion regressions

`byte::from_int`, `byte::set`, ASCII predicates, and `hir/completions.tcl`
are all untouched source and untouched logic; `tests/byte-set.test`,
`tests/native-byte.test`, `tests/errors.test`, `tests/source-types.test`,
and every completion-proof test in the full suite (below) pass unmodified,
confirming `BelowRange`/`AboveRange`/known-error/effective-error behavior is
exactly as it was.

## Files changed

- `core/native.tcl` -- `ValidShape`'s `typed` case now requires and
  validates `{typed NAME LO HI}` (was `{typed NAME}`); doc comments updated.
- `core/strings.tcl` -- `encode_utf8`'s registration: `-result-shape {typed
  Byte 0 255}` (was `{typed Byte}`).
- `hir/types.tcl` -- `ShapeResult`'s `typed` case now validates `LO..HI`
  against the resolved type's own domain (`hir::range::ProvesType`) before
  narrowing, falling back otherwise; doc comment rewritten.
- `tests/symbolic-type-identity.test` -- new; the adversarial fixtures and
  acceptance-matrix tests below.
- `SYMBOLIC-TYPE-IDENTITY.md` -- this report.

No `native/`, `hir/completions.tcl`, `hir/range.tcl`, `lib/byte.bot`,
`lib/ascii.bot`, or `lib/web.bot` changes.

## Tests

`tests/symbolic-type-identity.test`, 9 tests, all passing:

- `symbolic-type-identity-canonical-byte` -- canonical `Byte = Int in
  0..255`: `encode_utf8(...) : List[Byte]` (shown as `List[int[Byte]]`).
- `symbolic-type-identity-narrow-byte-rejected` -- `Byte = Int in 0..15`:
  falls back to `list`.
- `symbolic-type-identity-wide-superset-byte` -- `Byte = Int in 0..1000`:
  still narrows to `List[Byte]`.
- `symbolic-type-identity-no-byte-declared` -- no `Byte` registered: falls
  back to `list`.
- `symbolic-type-identity-incompatible-kind` -- a non-int-based same-named
  `Byte`, registered directly (Botlish source syntax cannot express this;
  see above): falls back to `list`, exercising `hir::types::ShapeResult`
  directly.
- `symbolic-type-identity-list-get-{ascii,two-byte,astral}` --
  `list_get(encode_utf8(text), 0) : Byte` for `"A"`, `"é"`, `"😀"`.
- `symbolic-type-identity-web-regression-clean-compile` --
  `web::uri_escape_text` over mixed ASCII/multi-byte/astral text: zero
  diagnostics, correct output.

## Acceptance matrix

| Resolved target type | Native guarantee | Result |
| --- | --- | --- |
| `Byte = Int in 0..255` | `Int in 0..255` | `List[Byte]` |
| `Byte = Int in 0..15` | `Int in 0..255` | broader fallback (`list`) |
| `Byte` = incompatible kind (non-int) | `Int in 0..255` | broader fallback (`list`) |
| no `Byte` type loaded | `Int in 0..255` | broader fallback (`list`) |
| `Byte = Int in 0..1000` | `Int in 0..255` | `List[Byte]` (sound: a wider, currently-resolved, compatible domain) |

## Full regression / GC stress

Exact counts, all three required runs, no failures:

```
$ tclsh9.0 tests/all.tcl
######## backend: interp
######## backend: compile
all.tcl: Total 2102  Passed 2102  Skipped 0  Failed 0
Sourced 73 Test Files.

$ cargo test --release --manifest-path native/Cargo.toml
test result: ok. 60 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out

$ BOTLISH_NATIVE_GC_STRESS=1 tclsh9.0 tests/all.tcl
######## backend: interp
######## backend: compile
all.tcl: Total 2102  Passed 2102  Skipped 0  Failed 0
Sourced 73 Test Files.
```

(2102 is the combined interp+compile total across all 73 test files,
including the 9 new `tests/symbolic-type-identity.test` tests, unchanged in
count between the ordinary and GC-stress runs.)

## Required architecture questions

1. **What did `{typed Byte}` mean before this milestone?** "The result is
   `List[Byte]` if a source-defined type spelled `Byte` is currently
   registered" -- name resolution alone was treated as proof.
2. **Why could plain name resolution be unsound?** The same spelling can
   validly denote a different domain in a different compiling program
   (compilation isolation is intentional, pre-existing architecture); a
   narrower or unrelated same-spelled `Byte` would have been falsely
   credited with UTF-8's real `0..255` guarantee.
3. **What does it mean after this milestone?** "The result is `List[NAME]`
   if a type spelled `NAME` is currently registered *and* its own domain
   provably admits every value the native guarantees (`LO..HI`)."
4. **Does a native result metadata entry directly assign a nominal source
   type, or provide facts from which the compiler proves that type?** The
   latter: the native's own metadata now states its semantic facts
   (`LO..HI`), and the compiler proves those facts imply membership in
   whatever the resolved source type currently is, before ever asserting
   it.
5. **What semantic facts does `encode_utf8` guarantee?** Int elements, each
   in `0..255`.
6. **Where does the target source type's actual domain come from?** The
   currently loaded source-defined-type registry
   (`core::type::integerFacts`/`core::type::metadata`, populated per-
   compilation by `hir/sourcetypes.tcl`).
7. **Can a same-named type with domain `0..15` be assigned to UTF-8
   output?** No.
8. **What happens instead?** A truthful broader fallback: the native's own
   plain declared `-result-type` (`list`).
9. **Does the canonical standard-library Byte still produce `List[Byte]`?**
   Yes.
10. **Was any runtime check inserted?** No.

## Required scope questions

11. **Were error semantics changed?** No.
12. **Was completion analysis changed?** No (`hir/completions.tcl`
    untouched).
13. **Was branch/range analysis changed?** No; `hir::range::ProvesType` is
    reused exactly as it already existed, with no changes to its own logic.
14. **Was type-import syntax added?** No.
15. **Was any codegen/backend optimization performed?** No.
16. **Was UTF-8 runtime representation changed?** No.
17. **Was Byte representation changed?** No.
18. **Was web source changed?** No.
19. **Was `byte::set` source changed?** No.
20. **Was broad `.bot` modernization performed?** No.

## Final semantic source fence

After this fix, freezing exactly as instructed:

- `byte::from_int`
- `byte::set`
- ASCII predicates
- UTF-8 producer typing
- `web::is_unreserved`
- URI escaping
- `error`/`errors`/`fail`/`handle`
- completion proof semantics
- source-defined refinement semantics

No further semantic/source/optimization work is expected before the
comprehensive generated-code / representation audit, unless a genuine
correctness bug is discovered.

**FINAL SEMANTIC SOURCE FENCE ESTABLISHED**
