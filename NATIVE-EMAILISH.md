# De-nativizing `refined-checks.ir`'s second blocker: `Emailish?`

Milestone 2 of the "push library semantics into ordinary Botlish" process
(milestone 1: `NATIVE-URI-ESCAPE.md`, `uriEscape`). This milestone's
outcome is **B**, not A: `Emailish?` is *not* fully de-nativized.
`bench/refined-checks.ir` still stops at exactly the same call it stopped
at before this milestone -- but for a precisely understood reason, and the
architecture change that makes that reason precise (distinguishing
validator-backed from opaque named-type predicates, and letting the former
run natively through the same `-native-body` mechanism milestone 1 built)
is real, general, and independently proven by a second type.

## 1. Files changed

- `core/type.tcl` -- `core::type::definePredicate` gains one new, optional,
  trailing argument: `nativeBody`, forwarded verbatim to
  `core::native::register`'s existing `-native-body` field (\167 3 of
  `NATIVE-URI-ESCAPE.md`). No new registry field; the existing one is
  reused exactly as spec \167 23 asks.
- `tests/helpers.tcl` -- the synthetic `NonEmpty` validator type (already
  used by `refined.test` to test evidence combination) now also passes a
  `-native-body` (`length(v) > 0`, exactly its Tcl validator) to
  `definePredicate`: an independent, generic proof that a validator-backed
  predicate can run natively, unrelated to `Emailish` itself.
- `tests/native-validator-predicate.test` -- new: parity, known-result
  folding, the opaque/validator distinction, GC stress, and the `Emailish?`
  regression pin.
- `lib/web.tcl` -- **unchanged**. `Emailish`'s registration still passes no
  native body (\167 6).
- `native/lower.tcl` -- **unchanged**. No named-type logic added or
  touched (spec \167 9/17); see \167 2.

## 2. Reproducing the current failure

```
$ tclsh9.0 main.tcl -backend cranelift bench/refined-checks.ir
== refined-checks.ir (cranelift)
   error: ir {0 2 2 3 2 2 1}: e11: native lowering does not support native
   Emailish?: the native "Emailish?" has no native implementation
   (NATIVE UNSUPPORTED {native Emailish?})
```

`e11` is `check`'s outer `call native(Emailish?)` on its `s` parameter (the
HIR dump below). The rejecting code, confirmed by reading
`native/lower.tcl` directly (not inferred from the message text):

```tcl
proc native::lower::NativeCall {fnVar e node name argRegs rawEligible op want} {
    ...
    if {[dict get $node known] ne ""} {
        # already folds to a constant -- see \167 3
        return [list [Assign fn "bool ..." $e] tagged]
    }
    if {![dict exists $natives $name]} {
        Unsupported $e "native $name" "the native \"$name\" has no native implementation"
    }                                                    ; # <-- line 3012-3013, the actual hit
    ...
    set testsType [dict get $meta testsType]
    if {$testsType ne "" && [llength $testsType] > 1 && $name ni {ok? error?}} {
        Unsupported $e "native $name" "type tests of named types need evidence, ..."
    }                                                    ; # <-- line 3017-3019, NOT the hit
    ...
```

`$natives` (`native/lower.tcl:99`) is a fixed dict of ~30 built-in
operator names (`+ - * ... integer? string? list? ok? error? ...`).
`Emailish?` (a *library* native, `lib/web.tcl`) was never in it, so the
first check (`![dict exists $natives $name]`) rejects it and raises before
the second, evidence-specific check at line 3017-3019 is ever reached.
Confirmed directly: a two-line program calling only `Emailish?` fails
identically (`native-validator-predicate-emailish-still-unsupported`,
this milestone's test file), with the *same* error text as before any
change here.

**This settles \167 5 of the milestone brief.** The "named type predicate ->
unsupported because it needs evidence" branch (line 3017-3019) is real
code, but it is not what rejects `Emailish?` today, and nothing currently
registered ever reaches it (only a native that is *both* in `$natives`
*and* a multi-name refined-type test would; none is). It is not a bug to
fix, and there is nothing to "un-conflate" in `native/lower.tcl` itself --
the actual gap is upstream of it entirely: no native/type registration
mechanism previously let a validator-backed predicate become *executable*
native code at all, of any kind. `native/lower.tcl` needed zero changes
this milestone (\167 9/17 of the brief) precisely because the fix belongs at
the registration layer, not the lowering layer.

## 3. HIR-known status of every `Emailish?`/`UriQueryValue?` call in the benchmark

```
e11  call native(Emailish?)         : bool            <- outer, on s: DYNAMIC
e15  call native(Emailish?) = true  : bool            <- inner, on s: KNOWN TRUE
                                                           (branch-narrowed by e11's then-branch)
e19  call native(UriQueryValue?)    : bool            <- on q (check's own *parameter*): DYNAMIC
```

(`tclsh9.0 main.tcl -backend interp -hir bench/refined-checks.ir`, the
`then s6 refines b5 s : str[Emailish]` / `then s7 refines b5 s :
str[Emailish]` lines confirm the refinement.)

- **`e11` (outer `Emailish?(s)`) is genuinely dynamic**, confirmed two
  ways: no `= true`/`= false` annotation in the HIR dump, and
  `hir::specialize`'s own chosen instance (`-aot-spec`:
  `check<int, int, str, str>`) types `s` as plain `str` -- specialization
  keys deliberately drop evidence (`hir/specialize.tcl:27-29`: "kinds,
  evidence (named types) dropped"), so nothing before native lowering
  could have decided it. It must genuinely execute. Confirmed independent
  of any change here (also true on the pre-milestone commit).
- **`e15` (inner, re-checked `Emailish?(s)`) is HIR-known true**, from
  `s6`'s branch refinement -- exactly the "statically redundant" case the
  benchmark's own header comment describes. `native/lower.tcl`'s `known`
  short-circuit (line 3003-3010, quoted above) folds this to a constant
  *before* the native-support check runs at all, so it needs **no** native
  implementation of `Emailish?` to exist, whether or not `e11` is ever
  fixed. This was already true before this milestone (`e11` alone was
  always the first, and only, failure) and remains true after it: `e11` is
  the only `Emailish?` blocker in this program, now and before.
- **`e19` (`UriQueryValue?(q)`) is also genuinely dynamic** -- a fact this
  milestone had to verify, not assume, because the benchmark's own header
  comment ("`UriQueryValue?` on a value whose type proves the answer")
  reads as if it should be known. It is not, *inside* `check`: `q` there
  is `check`'s own parameter (`b6 q : any` in the semantic HIR), and the
  evidence the top-level `bind q {call {ref uriEscape} ...}` attaches
  never crosses the call boundary into the callee's own body under this
  architecture (specialization keys drop evidence, same as `s` above; nor
  does any interprocedural evidence-propagation pass exist -- only
  `hir/range.tcl` propagates caller facts into callees, and only for
  numeric ranges). This is § 4's subject, not a bug: `UriQueryValue` is
  opaque, and `e19` is exactly the case spec \167 20 calls "opaque/evidence-
  only -> require evidence-capable runtime representation or remain
  unsupported" -- correctly unresolved today. (Separately, and worth
  recording precisely because it is easy to conflate with the point above:
  even where evidence *is* visible statically -- e.g. `{bind q {call {ref
  uriEscape} ...}} {call {ref UriQueryValue?} {ref q}}` at top level, no
  function boundary involved -- `UriQueryValue?(q)` still fails dynamically
  under `-backend cranelift`, *unlike* `interp`/`compile`, which fold it to
  `true`. This is milestone 1's own already-documented, unrelated
  limitation: `uriEscape`'s `-native-body` cannot attach opaque evidence
  -- see `NATIVE-URI-ESCAPE.md` \167 7/8 -- so under the native backend `q`
  never carries `UriQueryValue` evidence at all, by construction, on any
  backend that expands `uriEscape`'s body. Verified unchanged before and
  after this milestone's changes, with `git stash`.) Net effect: even a
  hypothetically-fully-fixed `Emailish?` would not let `refined-checks.ir`
  run to completion today -- `e19` would immediately become the next
  failure, for the *opaque* reason milestone 1 already knows about, not a
  new one.

## 4. `Emailish` vs. `UriQueryValue`: the type-registry facts

Read directly from `lib/web.tcl` and `core/type.tcl` (not inferred):

```tcl
core::type::register Emailish -base str \
    -validator [list core::regex::matches $core::web::emailRegex]
core::type::definePredicate Emailish

core::type::register UriQueryValue -base str -opaque 1
core::type::definePredicate UriQueryValue
```

`core/type.tcl`'s own header states the rule this registry enforces:
*"A validator type is structural: a command prefix, called with the value,
decides membership (1/0). An opaque type has no validator: a value belongs
to it only if it carries runtime evidence... Evidence on a value of a
validator type is an optimization; evidence of an opaque type is the only
proof there is."* `core::type::register` enforces this as a hard
precondition (`core/type.tcl:71-73`): `($validator ne "") == $opaque` is an
error -- a type is *exactly* one of the two, never both, never neither.
`core::type::validate` (`core/type.tcl:266-278`) is the operative rule:

```tcl
proc core::type::validate {name v} {
    ...
    if {[core::value::hasEvidence $v $name]} { return 1 }
    if {[dict get $meta opaque]} { return 0 }      ; # opaque, no evidence: false, period
    return [runValidator $name $v]                  ; # validator type: actually run it
}
```

| | `Emailish` | `UriQueryValue` |
|---|---|---|
| opaque? | no | yes |
| validator? | yes -- `core::regex::matches` against `core::web::emailRegex` | none (registration would error if one were given) |
| evidence required to decide membership? | no -- evidence is only an optimization; the validator can always be run instead | yes -- it is the *only* proof; a plain `str` with the right characters is never `UriQueryValue` |
| can an ordinary value be revalidated into the type? | **yes**, by construction -- that is what "validator-backed" means | **no**, by construction -- `core::type::register`'s own precondition above forbids giving it a validator at all |

Base type of both: `str`. `core::value::evidenceKinds` (`core/type.tcl:33`)
lists `str` as the only kind that can carry evidence at all -- both types
are on the one representation that supports either mechanism.

This table is not new in this milestone; it is exactly what
`lib/web.tcl`'s own header comment already documented (`Emailish
structural: a regex validator decides membership`; `UriQueryValue opaque:
no validator can manufacture it`) and what milestone 1 relied on when it
gave `uriEscape` (the only way to *mint* `UriQueryValue` evidence) a
`-native-body` while explicitly not doing the same for anything
`UriQueryValue`-shaped. This milestone's job was to give the *predicate*
side of that same distinction an equally general treatment.

## 5. The general mechanism: reusing `-native-body` for validator-backed predicates

`core::type::definePredicate` registers `NAME?` as an ordinary
`-tests-type` native (`core/type.tcl:99-114`) whose `-impl` is
`PredicateImpl`, which is exactly `core::type::validate` (\167 4) --
evidence-or-validator, uniformly, for *any* named type, opaque or not. The
Tcl side already treats both kinds uniformly through one code path; only
the *native-capable* side lacked any way to reproduce that for a
validator-backed type, because nothing ever gave its predicate a
`-native-body`.

The fix is exactly that, and nothing else:

```tcl
proc core::type::definePredicate {name {predicateName ""} {nativeBody ""}} {
    ...
    return [core::native::register $predicateName -arity 1 \
        -impl [list core::type::PredicateImpl $name] \
        -param-types [list $base] \
        -tests-type [list refined $base [list $name]] \
        -runtime evidence \
        -native-body $nativeBody]
}
```

`nativeBody`, when given, must compute the *same* 0/1 the validator does
(never evidence-checking logic -- `PredicateImpl`/`validate`'s contract is
already "evidence-or-validator"; a hand-written body only ever needs to
reproduce the validator half, since native code has no way to fabricate
runtime evidence anyway). Passing one for an **opaque** type would be
semantically wrong (there is no validator for it to reproduce; only
evidence proves membership) and no caller does this -- `UriQueryValue`'s
`definePredicate` call is untouched, still two arguments, `nativeBody ""`
by default (\167 4's precondition already makes "opaque with a validator"
impossible to register in the first place, so this can't even be gotten
wrong by construction).

Once a predicate carries a `-native-body`, milestone 1's existing,
completely generic `native::ExpandNativeBodies` (`native/native.tcl:472-
528`, unchanged) substitutes it at every call site, before `hir::build`
runs, for the native backend only. From there it is an ordinary block
call: **no entry in `native/lower.tcl`'s `natives` whitelist, and no
awareness in `native/lower.tcl` of type predicates, validators, or
evidence at all** -- exactly spec \167 17's "type semantics and executable
implementation connected through metadata, not hardcoded compiler logic."

**Independent proof this is general, not `Emailish`-specific** (spec
\167 38): `tests/helpers.tcl`'s synthetic `NonEmpty` type -- unrelated to
`Emailish`, already used elsewhere for independent-evidence tests -- now
gets `core::type::definePredicate NonEmpty "" {block {v} {call {ref >}
{call {ref length} {ref v}} {const 0}}}}`, reproducing its Tcl validator
(`string length > 0`) exactly. Before this milestone, `NonEmpty?` was
**unconditionally rejected** dynamically on `cranelift` (verified with
`git stash`: `native lowering does not support native NonEmpty?`, at the
*first* occurrence, before any folding could even be observed). After:

```
interp             -> value {[true, false]}
compile            -> value {[true, false]}
cranelift-generic  -> value {[true, false]}
cranelift          -> value {[true, false]}
```

for `[NonEmpty?("hi"), NonEmpty?("")]` -- byte-identical across all four
backends. `tests/native-validator-predicate.test` pins this, plus the
opaque/validator distinction (\167 7) and the `Emailish?` regression (\167 6),
as permanent regression coverage.

## 6. Why `Emailish` itself still gets no `-native-body`

`Emailish`'s validator is `core::regex::matches` against
`core::web::emailRegex` (`lib/web.tcl:18-24`):

```
seq
  repeat (class alnum | . | _ | % | + | -) 1 inf      ; # local part
  lit @
  repeat (seq (repeat (class alnum | -) 1 inf) (lit .)) 1 inf   ; # domain labels, each "label."
  repeat (class alpha) 2 inf                          ; # TLD
```

**`core/regex.tcl` is entirely Tcl-only** (\167 12 of the brief): a regex
value is `{regex IR ARE NAMES}`, `create` lowers Botlish's regex IR to a
Tcl Advanced Regular Expression at *registration* time (so the pattern is
static, known at Tcl-load time, not user input), and `matches` calls
Tcl's `regexp` directly. None of this is a registered Botlish native, and
there is no core-IR operation, today, that runs a regex at all -- not
`Emailish`-specific, not general. Confirmed by reading the whole file
(262 lines): no `core::native::register` call anywhere in it.

**Attempted: express the same language without a regex engine (spec
\167 13/27).** The domain part is provably reducible to ordinary control
flow without backtracking: since `.` is never a member of the label
character class, splitting the domain on `.` deterministically recovers
the same segmentation the regex's greedy repeats would find (there is only
one way to place the dots), so "one-or-more `(label.)` groups then a TLD"
is exactly "every part but the last matches the label class, and the last
part matches the TLD class, after splitting on `.`, with >= 2 parts" --
formally equivalent, not approximated. The local part (a single character
class, one repeat, no nested alternation) is even simpler: an ordinary
left-to-right scan. Both are well within what `length`/`substring`/
`concat`/`==`/comparisons can already express (as `uriEscape`'s
`-native-body`, milestone 1, already demonstrates for a structurally
similar left-to-right scan).

**What blocks it: the character classes themselves.** `alnum` and `alpha`
in Tcl's bracket-class syntax are **Unicode-aware**, not ASCII-only --
verified directly, not assumed:

```
$ tclsh9.0
% regexp {^[[:alpha:]]+$} café     -> 1
% regexp {^[[:alpha:]]+$} 日本語    -> 1
% regexp {^[[:alpha:]]+$} MÜLLER   -> 1
```

So `core::regex::matches` -- the *current* validator, which spec \167 14
requires exact parity with -- accepts non-ASCII letters/digits in both the
local part and the TLD. Reproducing this exactly in ordinary Botlish would
require classifying an arbitrary Unicode scalar as "Letter" or
"Letter-or-Digit" per Unicode's category tables. No such primitive exists
in the native registry today (`core/strings.tcl` has `length`,
`substring`, `lowercase`, `concat`, `encode_utf8` -- no character-class
predicate of any kind), and none of the existing arithmetic/comparison
ops can derive it: `lowercase`-invariance, the only existing op that comes
close, is not a sound letter test (many caseless Unicode letters, e.g. CJK
ideographs, are invariant under it, same as digits and punctuation --
tested directly, not assumed). Building one from scratch means embedding
Unicode category data, which is exactly the kind of subsystem spec \167 15/
48-50 rule out for this milestone ("do not build a regex engine"; the
scope is the same order of magnitude whether the missing piece is called
"regex" or "Unicode classification" -- both are real capability gaps, not
one predicate's algorithm).

**An ASCII-only version was deliberately not written.** The project's own
`bench/equivalents/rust/refined_checks.rs` (used only for cross-language
benchmark comparison, not for semantics) already implements `emailish`
with `is_ascii_alphanumeric`/`is_ascii_alphabetic` -- i.e., it silently
narrows the language to ASCII. Writing the Botlish native-body to match
*that* instead of the actual Tcl validator would be exactly spec \167 14's
forbidden move ("do not approximate 'email-like' behavior... do not
silently change the type") -- a real, provable semantic narrowing (Tcl's
validator accepts strings an ASCII-only Botlish version would reject),
not a faithful port. Per spec \167 42, this is reported rather than shipped.

**Conclusion: Outcome B (spec \167 56).** The general mechanism (\167 5) is
built and independently proven (\167 5, `NonEmpty?`). `Emailish` itself is
validator-backed, not opaque, and is correctly *eligible* for the same
mechanism -- but its specific validator's exact semantics need Unicode-
aware character classification (equivalently, general regex matching)
that ordinary core IR cannot express yet, and this milestone does not
build that. `Emailish?`'s registration is therefore left exactly as it
was; `e11` fails with the identical error, for a now-precisely-diagnosed
reason instead of a generic one.

## 7. Regression coverage added

`tests/native-validator-predicate.test` (new, 12 tests):

- Four-way (`interp`/`compile`/`cranelift-generic`/`cranelift`) value
  parity for dynamic `NonEmpty?` on a non-empty and an empty string.
- A param-kind error (`NonEmpty?(5)`) still requires the runtime check --
  not silently folded -- and cranelift's own guard (inlined from
  `length`'s own contract, not `NonEmpty?`'s -- a natural, documented
  consequence of body substitution) reports it correctly.
- A `NonEmpty?` check redundant by an enclosing refinement still evaluates
  correctly (right *value*) on all four backends, and a NIR-shape test
  pins the *known, disclosed* optimization gap this reuse introduces
  (\167 8) rather than silently accepting or hiding it.
- `UriQueryValue?` (opaque) stays rejected dynamically on `cranelift`,
  with no `-native-body` in its registry metadata -- the opaque trust
  boundary, unmoved.
- `NonEmpty?` does carry a `-native-body`; `UriQueryValue?` and `Emailish?`
  do not -- asserted directly against `core::native::metadata`, not
  inferred from behavior.
- `Emailish?` is still rejected, byte-identically, both in isolation and
  via `bench/refined-checks.ir` itself (mirrors milestone 1's own
  `native-uri-escape-refined-checks-blocker` pin, which also still passes
  unchanged -- \167 9).
- A `BOTLISH_NATIVE_GC_STRESS=1` run of dynamic `NonEmpty?` on `cranelift`.

`tests/refined.test`'s 32 pre-existing tests (interp/compile-level
`Emailish?`/`UriQueryValue?`/`NonEmpty?` semantics, evidence combination,
contract checks) pass unchanged -- `definePredicate`'s new third argument
is optional and every existing call site (`UriQueryValue`, and `Emailish`
in `lib/web.tcl`) omits it, so their registered metadata is byte-identical
to before except for one new, empty `nativeBody` field.

## 8. A disclosed limitation this milestone's reuse introduces

Reusing `-native-body`/`ExpandNativeBodies` unmodified (spec \167 21-23) has
a real, minor cost specific to *predicates*, not general natives: the
substitution is purely syntactic, on raw core IR, **before** `hir::build`
runs (`native/native.tcl:450-471`, unchanged from milestone 1). A
provably-redundant ordinary native call folds via `native/lower.tcl`'s own
`known` check (\167 2, line 3003), because that check runs on the *native
call's own HIR node* -- but once a predicate has a `-native-body`, its
calls are no longer native calls by the time HIR exists; they are ordinary
block calls, so the refinement/`known` machinery that exists specifically
for `{native NAME}`-typed callees (`hir/refine.tcl`'s `decideTypeTest`,
gated on `[lindex $calleeType 0] eq "native"`) never sees them.

Concretely (`native-validator-predicate-known-result-nir-shape`): a
redundant `NonEmpty?(s)` check inside an already-`NonEmpty?`-refined
branch still executes for real on `cranelift` (`op strlen` appears twice
per call site, once per instance, so 4 times total for two call sites --
not folded to zero). This is **never a correctness bug** (both backends
that need to be right agree on the *value*, \167 5/7) and **does not affect
`Emailish?`**, whose calls carry no `-native-body` and therefore keep
exactly their pre-milestone `known`-folding behavior on `native/lower.tcl`
's own terms (\167 3: `e15` folds; only `e11` was ever a blocker, before and
after). It is listed here, per spec \167 34's "not hidden," as a genuine
consequence of the smallest-general fix, explicitly out of this
milestone's scope to close (no general inliner, spec \167 48; not a
`-native-body` module-system fix, spec \167 22) -- a real target for a later
milestone if predicate call sites with this shape become common.

## 9. Allocation, guards, GC

`NonEmpty?`'s native-body is `length` (runtime tag `char-index` only, no
allocation tag) then a raw-eligible `>` comparison on two provably-small
Ints -- `native::report` on a program using it shows `rawArith`/
`rawCompare` used and zero new allocation tags, consistent with `length`'s
own declared metadata; the Cranelift IR (`native::clif`) shows a direct
`call fnN` at every call site, no `call_indirect`/dynamic dispatch.
`native::report`'s own internal consistency assertion (blockers == guards,
`{NATIVE BUG}` otherwise) passes for a program exercising it, so guard
accounting (spec \167 35) is unaffected. `BOTLISH_NATIVE_GC_STRESS=1`
survives for a dynamic `NonEmpty?` call (\167 7). None of this applies to
`Emailish?` itself, which still does not compile (\167 6).

## 10. `refined-checks.ir` rerun and the next blocker

```
$ tclsh9.0 main.tcl -backend cranelift bench/refined-checks.ir
== refined-checks.ir (cranelift)
   error: ir {0 2 2 3 2 2 1}: e11: native lowering does not support native
   Emailish?: the native "Emailish?" has no native implementation
   (NATIVE UNSUPPORTED {native Emailish?})
```

Unchanged, as \167 6 concludes. Per spec \167 51's "one dependency per
iteration," the next blocker is **not** fixed here. Recorded for iteration
3 to pick up (per \167 3, it would be reached immediately if `Emailish?`
were ever fixed some other way): `e19`, `UriQueryValue?(q)` inside
`check`, genuinely dynamic (\167 3) and correctly unsupported because
`UriQueryValue` is opaque (\167 4) -- the true architectural target of a
future "opaque evidence, natively" milestone (spec \167 20's other branch:
"require evidence-capable runtime representation"), not a regex/Unicode
milestone. `Emailish?` itself remains the more immediate blocker as long
as it is unfixed.

## 11. Native-surface inventory (extends milestone 1's, spec \167 52)

| native | layer | classification | validator/evidence | de-native status | remaining dependency |
|---|---|---|---|---|---|
| `Emailish?` | library (`lib/web.tcl`) | type predicate, `-tests-type` | validator-backed (`core::regex::matches`) | **not fixed** (Outcome B) | Unicode-aware character classification / general regex matching (no ordinary-Botlish primitive exists) |
| `UriQueryValue?` | library (`lib/web.tcl`) | type predicate, `-tests-type` | **opaque**, evidence-only | unchanged, correctly unsupported dynamically | evidence-capable native runtime representation (separate architecture direction, not regex) |
| `NonEmpty?` (synthetic) | test-only (`tests/helpers.tcl`) | type predicate, `-tests-type` | validator-backed (`length(v) > 0`) | **fully de-nativized**, this milestone | none -- proves the general mechanism |
| `core::type::definePredicate` | registration (`core/type.tcl`) | generic capability, not a native itself | n/a | generalized: optional `-native-body`, forwarded to the existing field | none |
| `core/regex.tcl` (`core::regex::matches` etc.) | library-internal (Tcl only) | not a registered native at all | n/a | unchanged; identified, not touched | general regex matching / Unicode character classification (\167 6) |

## 12. Final answers

1. **Was `Emailish?` genuinely dynamic at the failing call?** Yes (\167 3):
   no `known` annotation, and specialization deliberately drops evidence
   from its parameter's key type, so nothing upstream of native lowering
   ever decides it statically.
2. **Is `Emailish` opaque or validator-backed?** Validator-backed:
   `-validator [list core::regex::matches ...]`, no `-opaque` (\167 4);
   `UriQueryValue` is the opaque one, by direct contrast.
3. **Did native lowering conflate validator-backed with opaque?** No --
   verified by reading the exact rejecting branch (\167 2): the generic
   "no native implementation" check (line 3012-3013) rejects `Emailish?`
   *before* the evidence-specific branch (line 3017-3019) is ever reached;
   that branch is presently unreachable dead code for every currently-
   registered native. The real gap was one layer up: no registration path
   ever gave a validator-backed predicate an executable native form at
   all, opaque or not.
4. **What is the correct general semantic distinction?** Opaque named-type
   predicate -> requires evidence, cannot be replaced by revalidation, and
   nothing here makes it executable natively; validator-backed named-type
   predicate -> may execute its validator through ordinary compiled code,
   with no evidence required, via `-native-body` (existing metadata,
   reused, not extended) and `ExpandNativeBodies` (existing mechanism,
   unmodified). `native/lower.tcl` implements neither branch explicitly;
   it just runs whatever ordinary code (if any) `ExpandNativeBodies` gave
   it, or rejects the call as before.
5. **Can validator-backed predicates now execute natively in general?**
   Yes, proven independently of `Emailish` by `NonEmpty?` (\167 5, \167 7):
   four-way backend parity, correct results including the param-kind-
   error and redundant-check cases, GC-stress survival.
6. **Does the fix preserve opaque-type evidence semantics?** Yes:
   `UriQueryValue?` is untouched, still carries no `-native-body`
   (asserted directly against its registry metadata, not just by
   behavior), and still fails the same way dynamically on `cranelift`
   (\167 7); `core::type::register`'s own precondition makes "opaque with a
   validator" impossible to construct in the first place (\167 4).
7. **Where does `Emailish`'s actual validator logic execute now?**
   Unchanged from before this milestone: `core::regex::matches` (Tcl),
   used by `interp`/`compile`/the reference contract check; never
   natively, on any backend, before or after this milestone.
8. **Was any `Emailish`-specific algorithm implemented in Rust?** No.
   Nothing in `native/src` changed at all this milestone.
9. **If regex remains involved, is it now the precise blocker?** Yes, and
   more precisely than "regex": it is specifically Unicode-aware character
   classification (`alpha`/`alnum` per Unicode categories) that has no
   ordinary-Botlish or native-primitive expression today -- the domain/
   local-part *structure* itself (splitting, sequencing, concatenation)
   was shown constructible without any regex engine at all (\167 6).
10. **Does the first dynamic `Emailish?` execute exactly where required?**
    Not applicable this milestone -- `Emailish?` still does not compile
    natively at all (Outcome B); `e11` still fails before any code for it
    exists. This criterion is satisfied for `NonEmpty?` instead (\167 5),
    the type this milestone's mechanism actually made runnable.
11. **Is the later redundant `Emailish?` check still eliminated by HIR?**
    Yes, unaffected: `e15` still folds via `native/lower.tcl`'s `known`
    check (\167 3), exactly as before this milestone, since `Emailish?`
    carries no `-native-body` and its calls are therefore still ordinary
    native calls, not block calls, all the way through.
12. **What did this iteration reveal about the architecture?** That the
    opaque/validator distinction was already fully and correctly encoded
    at the type-registry layer (`core/type.tcl`, unchanged, pre-existing)
    and needed no new logic there either -- only a *connection* from that
    existing metadata to the existing `-native-body` executable-code
    mechanism was missing, at the one place (`definePredicate`) that
    creates a validator-backed type's predicate. It also revealed a real,
    minor, disclosed tension between `-native-body`'s syntactic, pre-HIR
    substitution and the refinement-based known-result folding that type
    predicates specifically depend on (\167 8) -- invisible to milestone 1
    because `uriEscape` is not a predicate and has no such folding to lose.
13. **What is the next blocker after `Emailish?`?** `Emailish?` itself,
    unchanged (\167 10) -- Outcome B does not move the benchmark's failure
    point. The next blocker *behind* it, would `Emailish?` ever be fixed,
    is `UriQueryValue?(q)` inside `check` (\167 3, \167 10): genuinely
    dynamic, correctly unsupported because opaque.
14. **Why was that blocker deliberately left untouched?** Spec \167 51's
    "one dependency per iteration," and because it is architecturally a
    *different* kind of gap (evidence-capable native runtime
    representation for opaque types) than this milestone's subject
    (validator execution) -- conflating the two into one milestone would
    repeat exactly the mistake \167 5 confirmed native lowering does *not*
    currently make.
15. **What should iteration 3 investigate?** Two independent, smaller-
    grained candidates, either of which is a legitimate next step (not
    both in one milestone, per \167 51): (a) whether `UriQueryValue?`/
    opaque-evidence types can gain *any* native-executable representation
    -- e.g. a runtime evidence tag Cranelift code can check without
    reproducing `uriEscape`'s trust logic -- which is what actually
    unblocks `refined-checks.ir` past `Emailish?`, should it ever be
    fixed; or (b) the precise, narrow capability this milestone found
    missing for `Emailish?` itself: a general-purpose way to classify a
    Unicode scalar's category (starting with just Letter/Digit, the two
    `core::regex.tcl` classes actually used here), which is a much smaller
    scope than a full regex engine and might independently unblock more
    than just `Emailish?`.
