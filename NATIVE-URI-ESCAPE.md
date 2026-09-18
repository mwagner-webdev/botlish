# De-nativizing `refined-checks.ir`'s first blocker: `uriEscape`

Milestone 1 of the "push library semantics into ordinary Botlish" process.
`bench/refined-checks.ir` moves one native dependency (`uriEscape`) further;
its next blocker (`Emailish?`) is identified and deliberately left unfixed.

## 1. Files changed

- `core/strings.tcl` -- new general native `encode_utf8` (+ its Tcl impl).
- `native/src/nir.rs`, `native/src/runtime/ops.rs`, `native/src/codegen/clif.rs`
  -- `encode_utf8`'s native (Cranelift) support: a new NIR op (`strutf8bytes`)
  and its Rust runtime helper (`rt_str_utf8_bytes`).
- `native/lower.tcl` -- `encode_utf8` added to the native op whitelist.
- `core/native.tcl` -- new registry field `-native-body` / `nativeBody`.
- `lib/web.tcl` -- `uriEscape` gets a `-native-body`: the same algorithm as
  its Tcl `-impl`, written in ordinary Botlish over `encode_utf8`.
- `native/native.tcl` -- `ExpandNativeBodies`, the generic rewrite that lets
  the native backend use a native's `-native-body` instead of an op-whitelist
  entry; wired into `runProgram` (the native backend's own program entry
  point only).
- `tests/native-uri-escape.test` -- new differential/parity/GC-stress tests.
- `audit/native-scalar-asm/bench/refined-checks.status.txt`,
  `audit/native-scalar-asm/README.md` -- updated status line (targeted, not
  a full corpus regeneration -- see \167 11).

## 2. First blocker

```
$ tclsh9.0 main.tcl -backend cranelift bench/refined-checks.ir
   error: ir {1 2}: e39: native lowering does not support native uriEscape:
   the native "uriEscape" has no native implementation
   (NATIVE UNSUPPORTED {native uriEscape})
```

- **Registered:** `lib/web.tcl`, `core::native::register uriEscape -arity 1
  -impl core::web::uriEscape -param-types {str} -result-type {refined str
  {UriQueryValue}} -runtime {string-alloc evidence}`.
- **Implemented (before):** `core::web::uriEscape` (Tcl), `lib/web.tcl`.
- **Argument kind:** `str`. **Result kind:** `{refined str {UriQueryValue}}`
  (an opaque type -- see \167 5).
- **HIR-known?** No. `e39`'s `call native(uriEscape)` has no `known` field
  (confirmed in the HIR dump: `e39 call native(uriEscape) : str[UriQueryValue]`,
  no `= true`/`= false` annotation, unlike the neighboring folded
  `Emailish?(s) = true` at `e15`). `uriEscape` is a transform, not a
  `-tests-type` native, so nothing in `hir/refine.tcl`/`hir/types.tcl` ever
  decides its outcome statically -- it must genuinely execute.
- **Genuinely required, confirmed (spec \167 7):** `native/lower.tcl`'s
  `NativeCall` (`native/lower.tcl:3002`) checks `[dict get $node known]`
  *before* the whitelist-membership check at line 3011 -- exactly the fix
  the milestone's prior compiler cleanup made. `e39` reaches the whitelist
  check (and fails it) precisely because HIR genuinely has no known result
  for it, not because of a regression in that ordering. Not a bug to
  diagnose first.

## 3. Classification: **C, bootstrap convenience**

`uriEscape`'s Tcl implementation (`core::web::uriEscape`) is pure,
deterministic, allocating, byte-level string logic:

- **Unescaped:** `A-Za-z0-9._~-` (RFC 3986 unreserved).
- **Escaped:** everything else, as `%XX` (uppercase hex) of each UTF-8 byte.
- **Byte-based**, not scalar-based: `encoding convertto utf-8 $text`
  converts the whole string to UTF-8 first, then every byte is classified
  and (if needed) escaped independently.
- **UTF-8:** produced by Tcl's own `encoding convertto utf-8`, which (Tcl
  9, per `README.md` \167 0) is genuine UTF-8, scalar-value-based, no
  surrogate pairs.
- **Supplementary Unicode:** encoded as its real 4-byte UTF-8 sequence,
  each byte escaped independently -- verified directly (\167 6, "astral").
- **Total:** yes, no error path in the algorithm itself.
- **Can return `Error`?** No -- always a plain `str` (with evidence), never
  a `Result`.
- **Allocates:** yes (`core::value::str`, `append`).
- **Depends on locale/global/process state?** No -- `utf-8` is a fixed
  named encoding, not affected by system locale.
- **Pure algorithmic Tcl?** Yes -- no syscalls, no FFI, no file I/O. This
  is category **C** (bootstrap convenience), not A (substrate) or B
  (platform/FFI): nothing here is below what ordinary Botlish *arithmetic
  and string operations* could express, given the right primitive.

The one real wrinkle, addressed in \167 5, is `-result-type {refined str
{UriQueryValue}}`: `UriQueryValue` is an **opaque** type (`core/type.tcl`,
`-opaque 1`, no validator) -- by this repository's own design, "a value
belongs to it only if it carries runtime evidence, which only trusted
natives attach" (`README.md` \167 14). That is a genuine, intentional trust
boundary, not a missing-capability gap -- see \167 5 for how this milestone
respects it without leaving `uriEscape` itself unfixed.

## 4. Attempted ordinary-Botlish implementation

The natural Botlish shape of the escaping algorithm, char by char, exactly
mirrors `examples/stdlib/string_reverse.bot`'s `reverse_from` /
`examples/stdlib/ai_text_clean.bot`'s `clean_from` accumulate-by-concat
recursion:

```
esc_from(text, i, acc):
    if i >= length(text): acc
    else: esc_from(text, i+1, concat(acc, esc_char(substring(text, i, i+1))))
```

Writing `esc_char` this way immediately hits the actual missing capability
(\167 5): Botlish's only String operations are `length`, `substring`,
`lowercase`, `concat` (`core/strings.tcl`) -- all **Unicode-scalar**-level.
There was no way, in ordinary Botlish, to ask "what are this character's
UTF-8 *bytes*" -- and percent-encoding is defined over bytes, not scalars
(a two-byte character like `é` must become two independent `%XX` groups).
This is not "inconvenient", it is a real gap: no expression in the
language could produce that byte sequence at all.

## 5. Missing-capability analysis and the primitive added

**Missing capability:** `String -> UTF-8 byte sequence` (a scalar-to-byte
view of a String). Nothing else was missing: hex formatting, the unreserved
membership test and the accumulate-by-concat traversal are all expressible
in ordinary Botlish once the bytes exist as ordinary `Int`s (\167 6).

**Added:** `encode_utf8 : str -> list<int>` (`core/strings.tcl` +
`native/src/runtime/ops.rs`'s `rt_str_utf8_bytes` + a new NIR op
`strutf8bytes`, `native/src/nir.rs`/`native/src/codegen/clif.rs`). Each
element is one UTF-8 byte, 0..255, in order.

**Why general, not operation-specific:** this is exactly
`README.md` \167 25's own suggested shape ("`String.encode_utf8()`"). It
returns an existing type (`List` of `Int`), not a new `Bytes` type (\167
14/24's deferred-topics list explicitly says not to drag `Bytes` in for one
blocker) -- any future byte-level String need (hashing, other encodings,
wire formats) can reuse it as-is, with zero URI-specific residue. Its Rust
implementation is a two-line byte-by-byte read of the already-UTF-8 Rust
`String` (`str_of(s).text.bytes()`) reusing `Vm::new_list`'s existing
`MAX_COLLECTION_LENGTH` check -- no new allocation policy, no new op class.

**Where implemented:** the lowest layer that can express it at all --
`native/src/runtime/ops.rs` (the Rust runtime helper) plus
`native/src/nir.rs`/`codegen/clif.rs` (its NIR op and Cranelift lowering),
mirrored by an ordinary Tcl `-impl` for interp/compile
(`core/strings.tcl`). This is architecturally identical to `length`,
`substring`, `concat` -- ordinary core string natives with Rust-backed
native execution, nothing new about the *shape* of the addition.

**Deferred:** a real `Bytes` value type, `TextBuilder`/incremental String
construction (\167 8), fixed-width integers, integer division. None of
these were needed: hex formatting uses a 16-element lookup list plus a
`mod 16`/ascending-threshold-ladder (no division primitive needed -- see
\167 6), and the accumulate-by-concat pattern (\167 8) is the same one
already used twice in `examples/stdlib/`, not new pressure this milestone
had to resolve.

## 6. Hex formatting and the unreserved test: ordinary Botlish, no new capability

Per `README.md` \167 26, hex formatting is ordinary Botlish, not a new
primitive:

- `hex_digits`: a 16-element `list` literal, `"0".."9","A".."F"`.
- `high_nibble(b)`: `floor(b/16)` for `b` in `0..255`, via a single
  **ascending threshold ladder** (`if b<=15: 0 elif b<=31: 1 ...`) --
  Botlish has no integer-division primitive, and this milestone
  deliberately did not add one (out of scope, \167 5's "deferred" list);
  the ladder needs none.
- low nibble: `mod(b, 16)` (already a native, Euclidean, `core/primitives.tcl`).
- `is_unreserved(b)`: the same ascending-threshold-ladder shape, exploiting
  that the unreserved byte ranges, once sorted, partition `0..255` into
  disjoint ordered intervals -- so it needs no `and`/`or` (which Botlish
  also lacks as primitives; `if` alone suffices for a boundary walk).

## 7. `-native-body`: the smallest coherent transition for the trust boundary

`uriEscape`'s result type is `{refined str {UriQueryValue}}`, an **opaque**
type. By this repository's own design (`README.md` \167 14, `core/type.tcl`),
only a trusted native `-impl` may attach the evidence that makes a value
*be* a `UriQueryValue` -- ordinary Botlish structurally cannot, and should
not be able to (that is the entire point of an opaque type: unforgeable
membership). A first attempt at this milestone shadowed the root
`uriEscape` binding with a plain Botlish block in `bench/refined-checks.ir`
itself; this was **rejected** because it is a real, measured regression:
the resulting `q` no longer carries evidence, so
`UriQueryValue?(q)` inside `check` stops being (correctly) true, and the
benchmark's own answer changes from `[400, 0]` to `[0, 0]` on **every**
backend, including `interp` -- not merely a Cranelift lowering detail, but
a changed program result. (This was caught by directly comparing
`tclsh9.0 main.tcl bench/refined-checks.ir` before and after, at a smaller
`n`, per spec \167 10's "write the intended code and identify the exact
thing that prevents it from working" -- the "thing" here was evidence, not
UTF-8 bytes.)

Given that, `README.md` \167 17's explicit alternative applies: *"semantic
registration remains for bootstrap/interpreter reasons, but native-capable
Botlish implementation becomes authoritative."* Concretely:

- `core::native::register` gains one new, generic, optional field:
  `-native-body {block PARAMS BODY...}` (`core/native.tcl`). It is
  metadata, exactly like `-result-shape`/`-runtime`; it changes no
  semantics for any native that doesn't set it (every native but
  `uriEscape`, today).
- `native/native.tcl`'s `ExpandNativeBodies` rewrites a program's raw core
  IR, **before** `hir::build`, substituting any `(call (ref NAME) ARG...)`
  whose native carries a body for `(call (block PARAMS BODY...) ARG...)`.
  After the rewrite the call is *ordinary program logic* -- ordinary HIR,
  ordinary specialization/escape/range analysis, ordinary block-to-NIR
  lowering, the same pipeline `check` itself already goes through. No new
  compiler node, no `if name == "uriEscape"` anywhere (`README.md`
  \167 16): the check is generic (`nativeBody ne ""`), driven by registry
  metadata, not by name.
- This rewrite runs **only** inside `native::runProgram` -- the native
  (Cranelift) backend's own `core::registerBackend` entry point. `interp`
  and `compile` never see it; they keep calling `-impl`
  (`core::web::uriEscape`) exactly as before, evidence and all. Backend
  parity for *evidence* is therefore deliberately **not** claimed across
  backends (\167 8 below) -- only for the escaped *text*, which is all the
  native backend can or needs to represent (\167 8).
- `-impl` (Tcl, evidence-attaching) stays the single source of truth for
  every backend except native execution; `-native-body` is authoritative
  *only* for what the native backend executes. No duplicate semantic
  algorithm exists by accident: the `-native-body` IS the algorithm,
  written once, in Botlish; `-impl`'s Tcl loop is the same algorithm
  written once more, in Tcl, because Tcl is what interp/compile run. Both
  were checked byte-for-byte against each other (\167 8) rather than assumed
  consistent.
- **Known, disclosed limitation** (not hidden, per spec \167 34): the
  rewrite is purely syntactic on raw core IR, run *before* lexical
  resolution, so it substitutes a native's body even where a program-local
  `bind` of the same name would shadow it. No program in this repository
  does that for `uriEscape` (or any other native with a body) today. A
  future iteration that needs correctness there should run the same
  rewrite after `hir::build`'s own resolution, keyed on a call's resolved
  `target` field (`{native SymbolId}`) instead of the raw `ref` text --
  deliberately not built now (a second, larger integration with HIR's
  binding tables, not "the smallest genuinely general" capability this
  blocker needed).
- **Also known:** each direct call site gets its own literal body inlined
  (no sharing across call sites) -- correct, but would duplicate compiled
  code for a native called from many sites. `refined-checks.ir` calls
  `uriEscape` once, so this is a non-issue here; a program calling it
  hundreds of times would show it in code size, not correctness.

No part of `uriEscape`'s own escaping algorithm was implemented in Rust
(spec \167 3/4): the only Rust addition is `encode_utf8`, a primitive with
no URI-specific residue, exercised by ordinary Botlish source
(`lib/web.tcl`'s `-native-body`) that a human could have written the same
way by hand.

## 8. Parity, correctness, allocation, GC

All four backends produce the identical escaped **text** for every case
tested (empty, plain ASCII, space, `@`, two-byte, four-byte/astral,
percent-like `50%`, the full unreserved set) -- `tests/native-uri-escape.test`,
18/18 passing. `encode_utf8` itself is checked four-way with no exception
(no evidence involved at all).

Evidence, as designed (\167 7), is where the backends *intentionally*
differ: `interp`/`compile` show `"a%20b"#{UriQueryValue}`;
`cranelift`/`cranelift-generic` show plain `"a%20b"`. This is checked
explicitly (`native-uri-escape-evidence-*` tests) so the difference stays a
documented, tested fact instead of an unstated gap. It cannot regress
`refined-checks.ir` itself: that benchmark's own `UriQueryValue?(q)` checks
are only ever HIR-known (folded, never executed dynamically) on *every*
backend, native included -- confirmed by the disassembly-free but
symbolically-checked HIR (`Emailish?(s) = true`/etc. `known` folding, \167
13 of `README.md`) and by the fact the benchmark still fails on `Emailish?`
(a genuinely dynamic call), never on a dynamically-executed
`UriQueryValue?`.

`GC stress` (`BOTLISH_NATIVE_GC_STRESS=1`) passes for `uriEscape` on
Cranelift (forces a collection before every allocation across the whole
call chain -- `hex_digits`'s list, every recursive `concat`, `encode_utf8`'s
per-character list).

**Allocation shape** (native/Cranelift, from the NIR text,
\167 9): per top-level call, one `listnew` (the 16-entry `hex_digits`
table) plus, per input character, one `encode_utf8` call (allocates one
small List) and, for any escaped character, one `concat`-built `%XX`
fragment and one `concat` onto the accumulator. This is real, visible,
*not hidden* repeated-concatenation cost (\167 23): a `String` of `n`
escaped characters allocates on the order of `O(n)` intermediate Strings of
growing length -- catastrophically more than the single-pass byte buffer
`core::web::uriEscape`'s Tcl `append` effectively gets from Tcl's own
string representation. This is exactly the kind of pressure the milestone
predicted (\167 23/34): **not hidden, not fixed here.** A `TextBuilder`-
shaped capability (\167 24 of the milestone spec) is the natural answer,
but is a separate, larger, deliberately deferred milestone -- this one did
not need it to make `uriEscape` *correct* and *native-capable*, only to
make it fast, which was explicitly out of scope (\167 28).

## 9. Representative NIR (native backend)

```
func 1 "" params=1 env=0 regs=26 pnames="s" ... instance="str"
    %1 = str "0" ...  %16 = str "F" ...
    %17 = op listnew %1 ... %16          ; hex_digits
    %18 = closure 5 %17                  ; high_nibble, captures hex_digits... (nested)
    %19 = closure 6 %18                  ; is_unreserved
    %20 = closure 7 %19                  ; hex_pair
    %21 = closure 8 %20                  ; esc_bytes/esc_char/esc_from chain
    %22 = int 0
    %24 = str ""
    %25 = callenv 8 %21 %0 %22 %24       ; esc_from(s, 0, "")
    ret %25

func 3 "high_nibble" params=1 regs=93 rawregs="2 6 8 12 ..." ...
    guard int %0 "<=" @e25
    %3 = op ile %0 %1                    ; b <= 15 (raw, range-narrowed)
    br %3 L0 L1
    ...
```

Direct calls: `closure`/`callenv` per helper (ordinary Block invocation, no
new call form). Runtime helper calls: `op listnew` (the hex table) and,
inside `esc_char`, `op strutf8bytes` (`rt_str_utf8_bytes`) once per
character. Allocations: the hex table (once), one small List per character
(`encode_utf8`), and the `concat` chain (\167 8). Loop structure: none --
every scan is ordinary self-tail recursion (`esc_from`/`esc_bytes`), which
the existing self-tail-call compilation already turns into a real machine
loop, same as `check`'s own recursion. String operations: `concat`,
`substring`, `list_get`, all pre-existing ops. Guards: kind guards on `b`'s
comparisons already fold away once the caller's range is proven small
(`high_nibble`'s `rawregs` shows this already happening, unprompted, via
the existing range/representation machinery -- F2/F7 from
`NATIVE-AUDIT.md` \167 9, not touched by this milestone). Root
slots/safepoints: unremarkable, same shadow-stack policy as every other
compiled function (`NATIVE-AUDIT.md` \167 10, also untouched).

No new optimization, inliner, or compiler pass was added or needed to reach
this (spec \167 27); everything above is the *existing* pipeline reused.

## 10. `refined-checks` rerun

```
$ tclsh9.0 main.tcl -backend cranelift bench/refined-checks.ir
   error: ir {0 2 2 3 2 2 1}: e11: native lowering does not support native Emailish?:
   the native "Emailish?" has no native implementation
   (NATIVE UNSUPPORTED {native Emailish?})
```

- **Passed the old blocker:** yes -- `uriEscape`'s call (`e39` in the
  original numbering) no longer raises `NATIVE UNSUPPORTED`.
- **Next blocker:** `Emailish?`, at `check`'s own `if (call (ref
  Emailish?) (ref s)) ...` (`e11` in the HIR dump, \167 2) -- the *first*
  call in `check`'s body, genuinely dynamic (no incoming refinement on
  `s`), exactly as `NATIVE-AUDIT.md` \167 5 (F7) already predicted for this
  file.
- **Currently implemented:** `lib/web.tcl`, `core::type::register Emailish
  -base str -validator ...` / `core::type::definePredicate Emailish`; a
  *structural* (validator-based) type test, unlike `UriQueryValue`'s opaque
  evidence-only design.
- **Likely classification (not investigated further, per the hard scope
  rule):** looks like **bootstrap convenience** (C) on the surface --
  `Emailish?`'s validator is an ordinary regex match
  (`core::regex::matches`), which is itself Tcl-backed structural logic,
  not substrate/FFI -- but `native/lower.tcl`'s own comment
  (`NativeCall`, \167 3015-3018) says type tests of *named* (non-primitive)
  types are unconditionally unsupported natively because they "need
  evidence" -- worth checking in iteration 2 whether that's actually true
  for a *validator* type (which needs no evidence at all, only a regex
  match `core::type::acceptsValue` could run inline) or whether the
  current code overly conflates opaque and validator named types in that
  one unconditional check.
- **What iteration 2 should investigate:** (1) confirm whether
  `Emailish?`'s block is genuinely required to execute dynamically here
  (same `known`-before-whitelist check as \167 2, expected yes, given `s`
  has no incoming refinement); (2) re-derive `Emailish?`'s classification
  from the actual `native/lower.tcl` code path it hits (`testsType`
  unconditional-Unsupported check vs. plain whitelist-miss -- these are
  different code paths with different possible fixes); (3) whether a
  validator-type test can be compiled generically (regex match, or a
  compiled DFA -- explicitly **not** yet, per this milestone's own
  constraints on DFA work) without needing any evidence machinery at all,
  which would make it a much shallower fix than `UriQueryValue?`'s.

## 11. Native-surface inventory (lightweight, per spec \167 38)

| native | layer | classification | de-native status |
|---|---|---|---|
| `+ - * mod < <= > >= == eq list` | `core/primitives.tcl` | bootstrap convenience (arithmetic identity to machine ops) | native (op-mapped; not in scope) |
| `length substring lowercase concat` | `core/strings.tcl` | bootstrap convenience | native (op-mapped; not in scope) |
| `encode_utf8` (**new**) | `core/strings.tcl` | bootstrap convenience -- byte view onto an already-UTF-8 representation | native (op-mapped; independently general, added this milestone) |
| `list_length list_get list_append` | `core/lists.tcl` | bootstrap convenience | native (op-mapped; not in scope) |
| `mutable_array_*` | `core/mutarray.tcl` | bootstrap convenience | native (op-mapped; not in scope) |
| `hash` | `core/hashing.tcl` | **performance workaround** (own header: blocked on wrapping/fixed-width Int, which Botlish lacks) | native; explicitly documented as temporary |
| `Emailish?` | `lib/web.tcl` | bootstrap convenience (validator regex) -- **tentative**, see \167 10 | native; **next milestone's target** |
| `UriQueryValue?` | `lib/web.tcl` | **platform-adjacent trust boundary** (opaque-type evidence check; needs a runtime evidence representation the native backend doesn't have) | native; likely legitimate, not yet fully investigated |
| `uriEscape` | `lib/web.tcl` | bootstrap convenience (text transform) + trust boundary (evidence attachment) | **de-natived this milestone**: `-native-body` runs the transform on Cranelift; `-impl` (Tcl) keeps attaching evidence for interp/compile |

This inventory is evidence, not policy (spec \167 39): no rule against
registering natives was added.

## 12. Final answers

1. **First genuinely required unsupported native:** `uriEscape`
   (`bench/refined-checks.ir`'s `{bind q {call {ref uriEscape} ...}}`).
2. **Why native before:** bootstrap convenience (Category C) -- ordinary
   byte-level text-transform logic, registered as a Tcl-backed native
   purely because `native/lower.tcl`'s op whitelist never learned about
   library-registered natives, plus a genuine language gap (no UTF-8 byte
   access) that made the algorithm itself unwritable in Botlish until now.
3. **Semantic implementation now in ordinary Botlish?** Yes, for the
   escaping *transform* -- a `-native-body` in `lib/web.tcl`, compiled and
   run through the ordinary block/HIR/NIR pipeline. The opaque-type
   *evidence* attachment remains Tcl (deliberately -- \167 3/7).
4. **New lower-level capability required?** Yes: `encode_utf8` (`str ->
   list<int>`, UTF-8 byte access).
5. **Why general:** it is `README.md` \167 25's own suggested primitive
   shape, returns Botlish's existing `List`/`Int` types (no new value
   kind), and has zero URI-specific content -- any future byte-level
   String need can reuse it unmodified.
6. **Any part of the original operation implemented in Rust?** No. Only
   `encode_utf8` (a primitive, independently useful, not the escaping
   algorithm) touches Rust.
7. **Native execution independent of Tcl?** Yes -- `-native-body`'s
   compiled code never calls back into the Tcl interpreter; it is ordinary
   compiled Botlish, same as any user function.
8. **What did this reveal about String/Unicode/construction/compiler
   capabilities?** Confirmed real: no UTF-8 byte access (fixed this
   milestone), no integer division (worked around with a threshold ladder,
   not fixed), no `and`/`or` (same), and, most importantly, **no efficient
   String construction** -- the `concat`-accumulation pattern this
   codebase already leans on twice (`string_reverse.bot`, `ai_text_clean.bot`)
   is visibly `O(n)`-allocating here too, confirmed but not hidden or fixed.
9. **Did performance become pathological?** Not pathological for this
   benchmark's one seven-character call, but the *shape* of the cost
   (repeated String reallocation, one fresh small List per character via
   `encode_utf8`) would scale badly on longer input -- reported per \167 8,
   not fixed, exactly per spec \167 23/28/34.
10. **Next native dependency `refined-checks` hits:** `Emailish?`.
11. **Why left untouched:** the milestone's hard scope rule (one native per
    iteration) -- report and stop, not fix, even though a preliminary look
    (\167 10) suggests it may be shallower than `UriQueryValue?`'s evidence-
    bound case.
12. **What iteration 2 should examine:** whether `Emailish?`'s
    `NATIVE UNSUPPORTED` comes from the plain whitelist-miss path or from
    `NativeCall`'s separate, unconditional "type tests of named types need
    evidence" check (\167 10) -- these imply different, and differently
    sized, fixes -- and, if evidence-free, whether a validator-type test
    can be lowered generically (regex-as-native-code, itself possibly a
    prerequisite of its own) without violating this milestone's "no DFA
    work yet" constraint.
