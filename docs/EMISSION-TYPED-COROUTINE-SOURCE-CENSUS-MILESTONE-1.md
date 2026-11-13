# EMISSION-TYPED-COROUTINE-SOURCE-CENSUS-MILESTONE-1.md

How Botlish types what a coroutine yields and what it returns: a census and
a design recommendation. No language, compiler, runtime, standard-library or
generated-code file is changed; the corpus and its tools are
[`../audit/typed-coroutine-sources/`](../audit/typed-coroutine-sources/).

> A coroutine has an execution protocol as well as a result. The compiler
> should be able to describe both without making consumers rediscover which
> values belong to which phase.

The motivating case is CSV-EMISSION-VALIDATION-MILESTONE-1.md's exporter: a
certified byte source returns the number of records it wrote, and its
consumer narrows every symbol to a `Byte` before buffering it.

Evidence is marked by kind: **(inspection)** for what reading the
implementation establishes, **(observed)** for what the compiler or a run in
this session showed (the census tool's records, never a run, for every
static type), **(projected)** for expectations not measured. Source
locations are `file:line` at commit ae2cb861.

## Contents

1. [Executive conclusion](#1-executive-conclusion)
2. [The original CSV symptom](#2-the-original-csv-symptom)
3. [Current source and consumer semantics](#3-current-source-and-consumer-semantics)
4. [Runtime yield, return and failure protocol](#4-runtime-yield-return-and-failure-protocol)
5. [Current type representation](#5-current-type-representation)
6. [HIR inference and propagation](#6-hir-inference-and-propagation)
7. [Yield/result type matrix](#7-yieldresult-type-matrix)
8. [First yield and resume behavior](#8-first-yield-and-resume-behavior)
9. [Deep yields](#9-deep-yields)
10. [Errors and noncompletion](#10-errors-and-noncompletion)
11. [Ownership and contexts](#11-ownership-and-contexts)
12. [Current use across the repository](#12-current-use-across-the-repository)
13. [Backend and native-fusion implications](#13-backend-and-native-fusion-implications)
14. [Alternative typing models](#14-alternative-typing-models)
15. [API ergonomics](#15-api-ergonomics)
16. [Compatibility and migration](#16-compatibility-and-migration)
17. [Differential observations](#17-differential-observations)
18. [Soundness and precision findings](#18-soundness-and-precision-findings)
19. [Recommended design](#19-recommended-design)
20. [Proposed minimum implementation milestone](#20-proposed-minimum-implementation-milestone)
21. [Deferred features and open questions](#21-deferred-features-and-open-questions)

[The final questions](#the-final-questions) · [Files](#files) ·
[How to rerun](#how-to-rerun) · [Main's CI](#mains-ci)

## 1. Executive conclusion

**What is conflated** is the *static type of the value a segment ends
with*. A coroutine has exactly one *outward type* O: its root's declared
result, else the one type among its returns and every yield it can reach
that all the others are subtypes of (COROUTINES.md, section 19;
`hir::coroutines::Outward`, `hir/coroutines.tcl:1569`). The handle is typed
`Coroutine{args: [M], return: O, errors: [E]}`, and `first` and every resume
are typed O. Yields and the root's return that have no such common type are
COROUTINE-RESULT-MISMATCH. The *phase* -- whether a value was yielded or
returned -- is not part of the value at all: it is the handle's state, read
by `std::coroutine::done?`. Not conflated: the errors (their own channel),
the resume message (its own protocol), and a helper's return (which goes to
its caller, COROUTINES.md 20).

**The runtime already has the distinction**, in all three implementations
(section 4): the Tcl runtime tags each segment's end `yielded` or `done`,
the native runtime records `CO_SUSPENDED` or `CO_COMPLETED`, fused code keeps
`st >= 0` or `st = -1`. Each passes the value on untagged and keeps the phase
in the handle. **The compiler already computes the separate types too**: the
yields' join (`hir::coroutines::YieldTypes`, printed in HIR text as the
source's `coroutine-effect (yields T, ...)`) and the root's result; `Outward`
joins them and the handle keeps only the join (section 6).

**What it costs** (observed, `../audit/typed-coroutine-sources/`, 67 cases on
five backends):

* The CSV symptom reproduces exactly: the byte source's yields are proven in
  [0, 244] by the range analysis, its consumer receives an `int` with no
  facts (section 2).
* Ten cases are rejected for precision alone: a source yielding Bytes with
  nothing to return, a parser yielding records and returning a summary, a
  processor yielding events and returning a status, a generic yielding
  helper under a declared root (sections 7, 9, 15).
* Library protocols are shaped around the rule: `std::actor::exit` builds the
  final value in the requests' type, `std::test::run` yields one-element Lists
  so that its end can be `[]`, `std::tree::walk` returns its last node, every
  event-loop task returns an `int`, and seven JSON and YAML sites read a `-1`
  end value as a value (section 12).
* Yields cannot be affine, by this rule and, independently, because
  `coroutine#yield`'s parameter carries no ownership (section 11).
* At run time the narrowing costs about 0.4 ns per symbol (9.5 against 9.9
  ns, fused), while a tagged outcome built as an ordinary payload-enum value
  per segment would cost two allocations and about 13 times the time
  (section 13).

**Recommendation** (section 19): infer the yield type Y and the terminal type
R separately and keep both in the handle type; require a common type of the
yields alone, not of the yields and the return; and connect the phase to the
value through the test consumers already write, `std::coroutine::done?`: a
value a resume produced, guarded by `not done?` on the same handle with no
resume in between, has type Y. No syntax, no runtime change, no change to
the coroutine operations' NIR, fusion untouched. A tagged resume outcome
waits for `match` and generic enums; a declared yield type and affine yields
are deferred.

**Worth doing now**, as one bounded milestone (section 20) -- for
expressiveness more than for CSV. The CSV narrowing disappears only where
the emitter's yields are statically `Byte`s, which today takes a declaration
(a Byte-typed helper around each yield, section 2): Botlish carries facts
across a function boundary only as declarations, and a literal's type is
`int`.

## 2. The original CSV symptom

**The source** (inspection): `examples/dfa/csv/sources.bot:51`

```
nomethod fn bytes_document_source(header: csv_common::Row, rows: List[csv_common::Row]) -> int errors csv_common::UnsupportedCSVCharacter emits csv_utf8::document3_bytes:
    utf8_emit::document_bytes(header, rows)
    rows.length() + 1
```

Its yields are all deep, in `utf8_emit.bot`'s encoder: `yield 34`,
`yield 44`, `yield 192 + v.shift_right(6)`, `yield 128 + v.mod(64)` -- int
literals and int arithmetic. Its normal terminal result is the number of
records written (the header included); its declared errors are
`UnsupportedCSVCharacter`.

**What the compiler recorded** (observed, `census.tcl` on
`examples/dfa/csv/export.bot`):

| fact | value |
|---|---|
| written result type | `int` |
| inferred result type (R) | `int` |
| the yields' join (Y) | `int` |
| the yields' range facts | [0, 244] |
| the handle's type | `Coroutine{args: [], return: int, errors: [csv_common::UnsupportedCSVCharacter]}` |
| `first` (the construction's first value) | `int`, facts [-∞, +∞] |
| every resume's value | `int` (the same rule as `first`) |
| the completed state | `std::coroutine::done?` true; resumes return the cached count |

**The consumer** (`examples/dfa/csv/export.bot:64-77`; the comparison at line 71) narrows:

```
        b = c.at(0)
        if b < 0 or b > 255:
            # Never: the source is certified to emit bytes. A consumer
            # still receives Ints (a resume's value has its type, not the
            # source's certificate), so it narrows them.
            fail std::io::fs::FileError {reason: std::io::fs::Reason::Other, code: 0}
        chunk.push(b)
```

**The reduction** (`cases/s2-csv-reduced.bot`): a quoted-field source over
int literals, guarding ASCII where the range analysis sees it (`if c < 32 or
c > 126: fail`), returning the field's length. The yields' facts are
[32, 126]; `first` is `int` with no facts; the consumer pushing into a
`MutableVector[Byte]` without the comparison (`s2-csv-reduced-direct.bot`) is
rejected:

```
value of type int is not admissible to element type int[std::byte::Byte] of
MutableVector[int[std::byte::Byte]] (facts: [-∞, +∞]) ... (CORE SEMANTIC TYPE)
```

**Where the distinction is lost.** Not in a union -- Botlish infers none --
but at two boundaries:

1. **The phase.** `Outward` makes one type of the yields and the return
   (`int`, here both), and `coroutine#start`/`#resume` are typed with it
   (`hir::coroutines::ShapeResult`'s `coroutine-outward`,
   `hir/coroutines.tcl:1513`). A source yielding statically `Byte`-typed
   values and returning a count (`s2-byte-typed-source.bot`, `m02`) gets
   Y = `Byte`, R = `int`, O = `int`: the consumer receives an `int` although
   every yield sends a `Byte` (`s2-byte-typed-source-direct.bot`: rejected).
2. **The facts.** A literal is an `int`; that `yield 44` sends a byte is a
   range fact. Range facts cross a coroutine boundary in no case
   (`t05-yields-int-literals.bot`: yields {34, 44}, `first` unbounded) -- and
   they do not cross an ordinary call either: `take(symbol(3))` with
   `fn symbol(i: int) -> int: 65 + i.mod(26)` is rejected exactly like the
   coroutine's value (`t06-call-result-facts.bot`), while the same function
   declared `-> std::byte::Byte` is admitted everywhere
   (`t07-declared-call-result.bot`). Facts cross a function boundary only as
   declarations (AGENTS.md's List-length rule states it for lengths). A
   function has a declaration slot for its result; a coroutine source has
   one slot for two channels.

So the CSV report's diagnosis ("a resume's value has its type, not the
source's certificate") is right, and incomplete: separating the phases would
give the CSV consumer `int`, not `Byte`. Giving it `Byte` also takes a
declaration of the yields. Today a source can make one without new syntax by
yielding through a Byte-typed helper (`s2-csv-typed-yields.bot`: `fn
byte(b: std::byte::Byte) -> std::byte::Byte: b`, `yield byte(c)` after the
guard), which turns Y into `Byte` while O stays `int`.

## 3. Current source and consumer semantics

(inspection: COROUTINES.md, `hir/coroutines.tcl`'s header; observed:
`cases/p*.bot`, `m08`, `m09`, `m10`)

1. **A coroutine source** is any function from which a reachable yield can
   be reached: its own yields, or an exact call of a function that may yield
   (the transitive effect, `verify`). Nothing is declared. A function that
   cannot yield is no source (`m08-no-yield-result.bot`:
   COROUTINE-RHS-NOT-YIELDING).
2. **Deep yields**: yes, through any number of ordinary calls (COROUTINES.md
   14; `d01`-`d08`). A function that may yield is never a value
   (UNWRAPPED-YIELD), so the call graph is exact.
3. **Construction** is the statement `coroutine {step, first} = root(args)`:
   the arguments are evaluated, then the handle is created.
4. **Construction runs the body at once to its first boundary** -- a yield,
   its normal return or an unhandled failure (`p01-protocol-trace.bot`: the
   body's first step has run when the statement completes).
5. **The consumer receives** `step` (the affine handle) and `first`: the first
   yield's value, or -- the body having completed or failed in its first
   segment -- the final result or a handler's value.
6. **A resume** `step()` / `step(Msg {...})` runs the next segment: the
   message becomes the suspended yield's value, the body runs to its next
   boundary, and the resume's value is that boundary's value.
7. **Normal completion** is the root's return: the segment's value is the
   final result, the coroutine is `completed` (`done?` true).
8. **A returned value** is cached and returned by every later resume, which
   runs no body code (`p01`: `[..., 400, 1, 400, 400, 4]`, the log counting
   body steps).
9. **A failure** is an unhandled declared error of a segment, raised at the
   construction or the resume that ran it, through the ordinary error channel
   (handlers, `errors` clauses); the coroutine is `failed`, and every later
   resume raises the same error again (`m09-always-fails.bot`, `e01`-`e03`).
10. **Yielded or terminal?** At run time, only by `std::coroutine::done?`
    (`p02-same-type-phases.bot`: `yield 2` then `return 2` produce the same
    value of the same type; `done?` alone tells them apart).
11. **A coroutine that never yields** at run time completes during
    construction: `first` is its result (`m08-unexecuted-yield.bot`). One
    that cannot yield at all is no coroutine (point 1).
12. **One that never completes** (an unbounded loop of yields) is fine:
    R is `never`, O the yields' type (`m09-never-completes.bot`).
13. **After completion**, a resume returns the cached result again; after a
    failure, it raises the cached error again. There is no exhaustion error.
14. **Abandonment**: the handle is released after its last use; a suspended
    coroutine's frames are unwound with no body code running
    (`p03-abandon.bot`: one body step, then nothing). In a program where a
    suspending function owns a resource, it is abandoned at its handle's
    scope end, its frames' releases running (`o04-resource-abandon.bot`).
15. **What a coroutine owns**: its frames' bindings across suspension
    (affine values included: `o02`), the values moved into it at
    construction (`o03`), and, terminal, its cached result or error.

## 4. Runtime yield, return and failure protocol

All three implementations distinguish a yield from a completion *in the
handle*, and none in the value (inspection):

**Tcl** (`core/coroutines.tcl`). A segment ends in the coroutine's Tcl
coroutine as `{yielded V}` (from `yieldImpl`, line 221) or `{done
COMPLETION}` (from `Body`); `Segment` (line 181) switches on the tag (lines
199, 204), records `suspended`, `completed` (with `value`) or `failed` (with
`failure`) in the store entry, and returns `core::completion::normal V` in
both normal cases. The tag never leaves the runtime; `doneImpl` (line 266)
reads the state.

**Native** (`native/src/runtime/coroutine.rs`). `CoroutineObj` has one
`value` slot, "the outward value of the last segment (a yield's, or the
final result), and the resume message on its way in" (line 166), and a
`state` byte: `CO_SUSPENDED` (2), `CO_COMPLETED` (3), `CO_FAILED` (4) (lines
127-132). `segment` (line 750) returns `(*co).value` for both suspended and
completed (lines 762-766) and re-raises for failed; `resume` (line 792)
returns the cached `value` of a completed coroutine without running
anything. `rt_co_done` reads `state`.

**Fused** (`native/src/codegen/fusion.rs`, header lines 40-80). The state is
a register `st` (0 fresh, k suspended at the k-th yield, `DONE` = -1,
`FAILED` = -2, lines 106-107), the value a register `out` ("a yield's, or
the final result: the cache"); every yield and every completion jumps to the
code after the operation that ran the segment, and `codone` is `st < 0`.

**Failure** is the ordinary error channel in all three: a start or resume
returns `NO_VALUE` (natively) or a propagate-error completion (Tcl) exactly
when the segment ended with an unhandled error, which then is the call's own
error. The failed state caches it.

So a typed interface that separates Y and R needs no new runtime state: the
state exists and is already observable. A *tagged value* would be new: today
nothing builds one (section 13).

## 5. Current type representation

(inspection)

* **The handle**: `{coroutine {args {M} return O errors {E...}}}`
  (`hir::types::MakeCoroutineType`, `hir/types.tcl:626`), "the callable
  contract ARGTYPES (the resume messages: {} or one named struct type),
  RESULT (what each resume returns) and ERRORS". Source spelling
  `Coroutine{args: [M], return: O, errors: [E]}` (AFFINE-VALUES.md 1), shared
  with `Fn`'s callable contract, compared by `FnMismatch`'s rules
  (`CoroutineMismatch`, `hir/types.tcl:1608`: contravariant arguments,
  covariant return, error subset). The parser accepts exactly `args`,
  `return` and `errors` (`surface/parser.tcl:3491`; `tests/affine.test`'s
  `af-contract-forms` pins the refusal of a `yield` field).
* **Separately recorded**: the resume protocol (`args`), the outward type
  (`return`), the error set (`errors`), affinity (the handle type is the
  primitive affine root, `hir::types::IsAffine`).
* **Inferred, not recorded in the handle**: the yields' join Y and the root's
  result R. Y is stored nowhere: `YieldTypes` recomputes it from the sent
  values' types when `Outward`, `ResultMismatch` or `EffectText` asks (the
  side table's per-function `yieldType` is the type a yield *evaluates to*,
  the resume message's, despite the name). R is the root block's
  `declaredResult` or `resultType`.
* **Not represented at all**: the completion state. It has no type; it is
  the value of `std::coroutine::done?`, a `bool`.
* **What the compiler service shows** (observed, `service::at` on `m02`):
  `step: Coroutine{args: [], return: int, errors: []}`, `first: int`.
* **HIR text** (observed, `main.tcl -hir` on `m02`):

```
e81 block s17 (b29 b:int[std::byte::Byte], b30 n:int) captures () declares int coroutine-effect (yields int[std::byte::Byte], resume none) : block(e81)/2 -> int
e90 bind b34 step : Coroutine{args: [], return: int, errors: []}
e98 bind b36 first : int
    e99 call native(coroutine#start) : int
```

The source's effect states Y = `Byte`; the handle and `first` state `int`.

## 6. HIR inference and propagation

The path from declaration to consumption (inspection; observed types from
the census):

```
source function declaration      declaredResult (or none)
  -> yields                       coroutine#yield(V) calls; the sent V typed
                                  as any expression; the yield call itself
                                  typed with the resume protocol
                                  (ShapeResult coroutine-yield)
  -> returns                      the block's resultType
  -> outward type                 Outward: declared result, else lub of
                                  resultType and YieldTypes (hir/coroutines
                                  .tcl:1569); InstanceOutward refines it by
                                  the root call's semantic instance (:1595)
  -> coroutine construction       coroutine#create typed MakeCoroutine
                                  (protocol, outward, root's declared
                                  errors) (ShapeResult coroutine-create)
  -> first yielded value          coroutine#start typed CoroutineOutward
                                  (ShapeResult coroutine-outward)
  -> resume                       coroutine#resume typed the same; its
                                  errors the handle's (hir::types::Call)
  -> terminal completion          no type; std::coroutine::done? is bool
  -> check                        ResultMismatch (:1911): with a declared
                                  result, every yield a subtype of it; else
                                  one component a supertype of all;
                                  AffineProtocol (:1857): the outward type,
                                  the protocol and the error payloads
                                  unrestricted
```

**Independent internal concepts** the compiler has today: the yield type (per
yield, `YieldTypes`; joined in `EffectText`), the function result type, the
error set, the resume input type (the protocol, a least fixed point over the
call graph, `Solve`), the resume output type (= outward), ownership (the
affine analysis of the handle). **Merged**: the yield type and the terminal
result, into the outward type. **Absent**: the completion state.

**Precision** (observed; section 7 has the matrix). For a source with no
declared result, O is the join, exactly what a function returning the same
values would get as its result type: yields of `str` give `str`
(`t01`), of a struct the struct (`t02`), of two cases of one payload enum the
enum (`t03`), of a refined domain the domain (`m07-nested-yield-types`:
Nibble and Byte give Byte). The root's own yields of an untyped parameter
take the construction's semantic instance (`t04`: `source(5)` gives `int`,
`source("a")` `str`), while a *helper's* yields keep their generic body's
type (`d05`, section 9). Range facts never cross: in every case whose yields
are bounded, `first` is unbounded (the `facts-widened` observation, 18 of
the 67 cases, and every construction of the three repository files).

### The emission checker

`hir/emission.tcl` walks the same yields with its own interval-set facts
(EMISSION-CLAIMS-MILESTONE-1.md): a certified `over bytes` claim proves every
symbol in 0..255, a stronger fact than any type the yields have. It is
deliberately no type: `x01-emits-certified.bot` is certified and its
consumer still receives an `int` with no facts (`x01b`: a Byte parameter
rejects it). A claim also says nothing about the result
(CSV-EMISSION-VALIDATION-MILESTONE-1.md, section 18). The yield types this
census discusses are the type checker's, for every source, claimed or not.

## 7. Yield/result type matrix

Each row a case of `../audit/typed-coroutine-sources/cases/`; Y the yields'
join, R the root's result, O the outward type (what `first` and every resume
are typed), all from the compiler's records (observed). Runs: every runnable
case produced the same value on the interpreter, the Tcl compiler, Cranelift
generic, Cranelift (fused) and Cranelift unfused.

| case | yields | terminal | outcome | Y | R | O | consumer |
|---|---|---|---|---|---|---|---|
| m01 | Byte | Byte | compiles | Byte | Byte | Byte | takes `first` as a Byte |
| m02 | Byte | int | compiles | Byte | int | int | narrows (`s2-byte-typed-source-direct`: rejected without) |
| m03 | Byte | unit (declared) | COROUTINE-RESULT-MISMATCH | Byte | unit | -- | -- |
| m03 | Byte | none written (a loop ends the body) | COROUTINE-RESULT-MISMATCH | Byte | `List[never]` | -- | -- |
| m04 | Byte | struct (declared) | COROUTINE-RESULT-MISMATCH | Byte | Summary | -- | -- |
| m04 | Byte | struct (inferred) | COROUTINE-RESULT-MISMATCH | Byte | Summary | -- | -- |
| m05 | int | str | COROUTINE-RESULT-MISMATCH | int | str | -- | -- |
| m06 | str | int | COROUTINE-RESULT-MISMATCH | str | int | -- | -- |
| m06 | str | int, declared `any` | compiles | str | any | any | receives `any` |
| m07 | int and str | int | COROUTINE-RESULT-MISMATCH (rightly) | -- | int | -- | -- |
| m07 | Nibble and Byte | Byte | compiles | Byte | Byte | Byte | precise |
| m08 | none | int | COROUTINE-RHS-NOT-YIELDING | -- | int | -- | call it directly |
| m08 | unreached at run time | int | compiles | int | int | int | `first` is the result, `done?` true |
| m09 | int | no normal completion (unbounded loop) | compiles | int | never | int | precise |
| m09 | int | always fails after yielding | compiles | int | int (declared) | int | failure at the last resume |
| m10 | none | always fails | COROUTINE-RHS-NOT-YIELDING (+ a dependent TYPE, section 18) | -- | int | any | -- |

Two observations the matrix forces:

* **A source with nothing to report has no valid shape.** Yields of any type
  and a unit result (`m03`, declared or not) are rejected: the source must
  manufacture a terminal value of a supertype of its yields. A body that
  simply ends in its loop ends with that loop's collected List (`List[never]`
  in `m03`): the CSV and JSON sources write a trailing value after their
  loops for this reason (`examples/dfa/json/json.bot:226`).
* **A source yielding Bytes and returning a count is accepted at `int`**
  (`m02`), not rejected; the cost moves to the consumer. Yielding records and
  returning a summary is rejected (`m04`, `w01`).

A source yielding a str and returning an int is not "conceptually
equivalent" to one that sometimes yields strs and sometimes ints: the first
has a protocol (yields, then one terminal), the second a union of yields.
The language can say neither today: the first is rejected (`m06`), and so is
the second (`m07`). Declaring `-> any` accepts the first (`m06-str-int-any`)
by giving up on both types.

## 8. First yield and resume behavior

(observed, `p01`, `p02`, `m08`, `e01`)

* **The first value is typed O whether it is a yield or the result.** In
  `m08-unexecuted-yield` the root completes during construction: `first` is
  the final result (7), `done?` is true, and a later resume returns 7 again.
  A consumer cannot know statically which `first` is; every consumer in the
  repository that uses both reads `first` into the same cell as later values
  and tests `done?` before using it (section 12).
* **A resume's value is a yield exactly when `done?` is false right after
  it.** True for every outcome a resume can have: a yield leaves the
  coroutine suspended; a return leaves it completed; a failure leaves it
  failed -- a handled resume's value is then the handler's, and `done?` is
  true (`m09-always-fails`, `e02`). A resume of a completed coroutine returns
  the cached result with `done?` still true. The converse direction is weaker:
  `done?` true means the value is the result *or a handler's value*.
* **Equal payload types do not make the phases equal** (`p02`): `yield 2`
  then `return 2` give two 2s; the consumer must not use a value to decide
  the phase. The `-1` convention does exactly that, and breaks on a stream
  in which -1 is an ordinary symbol (`c02-sentinel-collision.bot`: the
  sentinel consumer stops after `[3]`, the `done?` consumer takes
  `[3, -1, 4]`). CSV-EMISSION-VALIDATION-MILESTONE-1.md removed the -1 rule
  from the emission checker for this reason; no design below reintroduces a
  sentinel, an out-of-range value or an empty value as the phase.
* **A `done?` test does not narrow the value today**
  (`n01-done-guard-no-narrowing.bot`): `x = step()`, then
  `if std::coroutine::done?(step): return x`, then `take(x)` with a Byte
  parameter, is rejected (`argument type: int, facts: [-∞, +∞]`) although on
  that path `x` can only be a Byte yield. The type checker relates no value
  to a handle's state.

## 9. Deep yields

(observed, `d01`-`d08`; inspection, `hir/coroutines.tcl`)

* **A helper's yields are the coroutine's.** `YieldTypes` collects, over the
  call graph from the root (`Closure`), every yield of every node, and
  `Outward` joins them with the root's result: `d01` (a helper yields Bytes,
  the root returns a count) is `m02` again, one level down.
* **A helper's return never mixes** (`d03`: the helper yields ints and
  returns a str its caller uses; O is the root's int). COROUTINES.md 20.
* **Two helpers of different yield types** are rejected at the construction,
  rightly (`d02`).
* **Recursion** (`d04`), **yields on one branch and an early return on
  another** (`d06`), **a helper's failure handled by the root** (`d07`),
  **a nested coroutine** (`d08`: the inner yields strs to the outer root,
  which yields ints; the boundary isolates the two types) all type as
  expected.
* **A generic helper's yields keep their generic type** (`d05`): `fn
  emit(x): yield x` called by a root returning `int` and one returning
  `str` sends `any` in both (a helper has no outward type of its own:
  COROUTINES.md 9). With declared results both roots are rejected ("the
  yield at ... sends a any"); without, both are `any` (`d05b`).
  `InstanceOutward` refines only the root's *own* yields by the root call's
  semantic instance. This is a precision limit of today's rule; separating
  Y and R does not change it.
* **A helper that always fails after yielding** is KNOWN-ERROR at its call
  (`d07b`): its call never returns, whereas a *root* that always fails after
  yielding is accepted, its segments completing by yielding (COROUTINES.md
  22). Correct on both counts.

**Modularity.** Y is computed as O is: from the root's declaration, its own
body and the generic bodies of the helpers it reaches, refined for the
root's own yields by the construction's semantic instance. It reads no
consumer and no other construction: as caller-independent as the outward
type is today. It does need the call graph from the root (the helpers'
yields are part of a source's interface, as they are part of its outward
type now); a separate yield type adds no dependency that `Outward` and
`ResultMismatch` do not have. No ordinary function's result type includes its
deep yields, and none would.

## 10. Errors and noncompletion

(observed, `e01`-`e05b`, `m09`, `m10`)

| case | behavior |
|---|---|
| failure before the first yield (`e01`) | crosses the construction; its handler's value is `first` (-1); `done?` true; the next resume raises it again (its handler -2) |
| failure after several yields (`e02`) | crosses the resume that ran the failing segment; later resumes raise it again |
| a resume that may fail, unhandled (`e03`) | UNHANDLED-ERROR: "this coroutine resume may produce the declared error ..." |
| failure handled inside the source (`e04`) | never reaches a resume; the handle declares no error |
| a resume's handler value (`e05`, `e05b`) | joins the value: a Byte handler value keeps a Byte source's value a Byte; `-1` makes it an int (the handler is one more producer of the value, and the only way a consumer can put a sentinel into it) |
| never completes (`m09-never-completes`) | R `never`; O the yields' |
| always fails after yielding (`m09-always-fails`) | accepted; R its declared `int` |
| no yield and always fails (`m10`) | COROUTINE-RHS-NOT-YIELDING |

As conceptual outcomes, a segment ends in Yield(Y), Return(R) or Fail(E).
The compiler tracks Fail(E) separately already (the handle's `errors`, the
completion analysis's `NativeCallFacts`), and Yield and Return merged.
Nothing in this census merges Fail into either: a typed interface keeps
failures in the error channel, with their handlers and `errors` clauses as
they are.

## 11. Ownership and contexts

(observed, `o01`-`o06`)

* **Affine values in yields** (`o01`): yielding a struct that owns a
  coroutine handle is rejected twice, independently:
  * COROUTINE-CONTRACT, because the outward type is affine: "a completed
    coroutine returns its cached final result again on every later resume,
    which would give one affine value several owners" (`AffineProtocol`). The
    reason is the *result's*; it reaches the yields only because they share
    the outward type.
  * AFFINE-ERASURE-UNSUPPORTED at the yield: `coroutine#yield` "takes any
    value: that position does not carry ownership". The native's
    registration has no ownership role (`core/coroutines.tcl:397`).

  Separating Y and R would make only the first reason precise. An affine
  yield also needs `coroutine#yield` to take its argument by move, and the
  consumer to receive it once -- which the runtime already does (the value
  slot is overwritten by the message on resume, and only a terminal value is
  cached) (inspection).
* **Affine values held across suspension** (`o02`: a child coroutine) and
  **moved in at construction** (`o03`: a child handle as an argument) are
  accepted; a **resource** a suspended source owns is released at its end, or
  at its handle's scope end when abandoned (`o04`). None of this reads the
  outward type.
* **Contexts**: a source requiring an installed context (`o05`), one
  constructed and resumed inside `inject no context:` (`o06`) -- contexts
  are fixed at construction and add nothing to the yield or result types.

Separating Y and R changes no ownership obligation: an affine R stays
COROUTINE-CONTRACT (cached), a message stays unrestricted, error payloads
stay unrestricted. It would make the existing contract checkable per
channel. No lifetime, borrowing or context rule is involved.

## 12. Current use across the repository

`tools/inventory.tcl` (observed, `results/sites.tsv`): 448 construction
sites -- 7 in `stdlib/`, 6 in `packages/`, 83 in `examples/`, 48 in `bench/`,
304 in `tests/golden/`. At 166 sites the consuming function calls `done?`; 80
hand the handle to the event loop or an actor; 30 handle the construction's
errors; one narrows.

The protocol families, by how they live with one outward type:

| family | sites | yields | terminal | consumer uses | phase by | shaped by the rule |
|---|---|---|---|---|---|---|
| event-loop tasks (`std::event_loop`; `stdlib/thread.bot`, `stdlib/actor/remote.bot`, `packages/http`, `packages/process_linux`, `examples/event-loop`, `examples/threads`, `bench/`) | 80 handed to `adopt` | request codes: -1 ready, a slot to park on (`stdlib/event_loop.bot:1374`) | the task's value | both (the scheduler) | `done?` (`stdlib/event_loop.bot:1563`) | every task returns an `int`: the protocol is `Coroutine{args: [], return: int, ...}` (`stdlib/event_loop.bot:36`), so a task cannot return anything but a code-typed value |
| actors (`std::actor`) | 1 (`stdlib/actor.bot:861`) and every actor program | `Exit` requests | `Exit` built by `std::actor::exit(value)` (`stdlib/actor.bot:285`) | both (the host) | `done?` | the final value is an envelope of the requests' type, with an `op` field telling it apart |
| emitted symbol sources (CSV, JSON emitters) | 39 (`examples/dfa/csv/sinks.bot`, `export.bot`, `examples/dfa/json/sinks.bot`, `emit_*`) | symbols (int) | CSV: records written; JSON: -1 | yields; CSV also the result after `done?` | `done?` | the consumer narrows (one site: `export.bot`); results are int |
| input symbol sources (`examples/dfa/json/json.bot`, `composition.bot`, `yaml.bot`) | 7 | scalar values or bytes | -1 | yields, and the -1 *as a value* (`json.bot:278`: `if c == -1`) | the value | the end is a sentinel; resuming past it returns -1 again |
| declared recognizers (`std::dfa`, generated by `surface/dfa.tcl`) | the JSON/YAML/CSV validators | 0 ("taken") | symbols left unread | the result | `done?` | two different meanings in one `int` |
| `std::tree::walk` | library, `tests/tree-struct.test` | nodes | the last node (`stdlib/tree.bot:22`, `109-112`) | both, alike | `done?` | the last item is the result, so that the result is an item |
| `std::test::run` | 1 (`stdlib/test.bot:748`) | one-element Lists `[TestResult]` | `[]` (`stdlib/test.bot:737`) | yields | `done?` | an option encoded as a List so that the end fits the yields' type |
| example generators (`examples/event-loop/03-child.bot:18`) | 1 | squares | -1 | yields | the value read, then `done?` | documented "then -1" |

By the consumer categories this census set out to count:

* **Only yields used**: the emitted-symbol collectors, `std::test::results`,
  the generators.
* **Only the terminal result used**: the recognizer drivers (they ignore
  the 0 acknowledgements).
* **Both**: the event loop, actors, `std::tree::walk`, `sinks::written_bytes`,
  `export.bot`.
* **Completion result ignored**: the symbol collectors, `std::test::run`'s
  consumer.
* **Narrowing a merged type**: `examples/dfa/csv/export.bot`, the only one.
* **Depending on deep yields**: every emitter and event-loop task (yields
  inside `std::event_loop::wait`, `yield_now`, `sleep`), every actor
  (`std::actor::receive`, `send`, ...).
* **Handling coroutine failure**: 30 handled constructions; the event loop's
  `run_task` handles every resume's errors.
* **Affine resources across suspension**: tasks that own resources while
  they wait (`std::event_loop`'s `Owner` of an `owned_*` registration,
  `tests/event-loop.test`'s `el-owned-*`), in programs that unwind
  (LEXICAL-RESOURCE-CLEANUP-EXPLORATION-MILESTONE-1.md).

The typing of every one of these is O = Y = R at the type level, except
`export.bot`'s source (Y = R = `int`, the Byte-ness a range fact) and
`std::test::run` (Y = `List[TestResult]{length: 1}`, R = `List[TestResult]`).
What the rule costs the repository is mostly protocol design, not
narrowing.

## 13. Backend and native-fusion implications

(inspection unless marked)

* **Runtime state**: yields and terminal results already occupy separate
  states in every runtime (section 4); the value representation is not
  tagged. Separating the static types needs no runtime tag.
* **Allocation**: none of today's protocol allocates per segment for an
  immediate value (an int, a Byte): the value travels in one slot or one
  register. A tagged *value* -- `Yielded {value}` or `Completed {value}`
  built per segment -- would: a payload-bearing enum value is natively an
  `EnumCaseObj` holding a payload struct, and nothing scalar-replaces one
  today (PORTABILITY-PAYLOAD-ENUMS-MILESTONE-1.md, section 20).
* **Measured** (observed, `tools/bench.tcl`, `results/bench.md`; 200,000
  symbols, best of 7, compile time excluded, a 4-core container):

| program | backend | ns / symbol | allocations per run |
|---|---|---:|---:|
| plain consumer | cranelift (fused) | 9.5 | 1 |
| narrowing consumer (`if b < 0 or b > 255: fail`) | cranelift (fused) | 9.9 | 1 |
| plain consumer | cranelift-unfused | 77.6 | 3 |
| narrowing consumer | cranelift-unfused | 78.4 | 3 |
| a payload-enum value per segment | cranelift (fused) | 123.1 | 400,003 |
| a payload-enum value per segment | cranelift-unfused | 198.8 | 400,005 |

  The narrowing comparison costs about 0.4 ns per symbol (4%), fused or not:
  its cost is static (a check the program must write, which the certificate
  makes redundant), not dynamic. A per-segment payload-enum value costs two
  allocations per segment and about 13 times the fused time.
* **Affine payload movement**: the native value slot already moves the
  yielded value to the resumer and is then overwritten by the message; a
  moved affine yield needs no runtime change, only the static role.
* **Fusion** (`native/src/codegen/fusion.rs`) compiles each start and resume
  as its own copy of the template over shared registers; every yield and
  completion jumps back to the code after the operation, which reads `out`
  and tests `st` for `codone`. Fusion never reads a HIR type: a typing change
  that leaves the NIR alone leaves fusion, its conditions and its census
  identical. A `done?`-guarded segment fact (section 19) changes no
  coroutine operation; a narrowed type can sharpen the consumer's own code as
  any precision gain does (semantic instances, representations), which the
  milestone measures.
  A tagged outcome consumed by a match right after its resume could be
  lowered to the same `out`/`st` pair with no object; one that escapes would
  materialize.
* **Frame size**: unchanged by any typing proposal; a tagged outcome adds a
  register, or an object when materialized.
* **The C backend** compiles no coroutine: `main.tcl -emit-c` on `m02` is C
  UNSUPPORTED at `coroutine#create` and `coroutine#yield` (observed). A
  typing change gives the C target nothing until it compiles coroutines; the
  implementation milestone's report says so (AGENTS.md, "The C backend").

## 14. Alternative typing models

Four alternatives and a combination, against the requirements (soundness,
precision, compatibility, syntax, HIR, inference, deep yields, errors,
ownership, contexts, backends, fusion, diagnostics, cost, scope).

**A. Keep the merged outward type.** Sound, simple, already implemented and
consumed everywhere. Precision: loses Y whenever R is wider (`m02`), and
rejects every protocol whose Y and R have no common supertype (eight cases).
Consumer-side narrowing can be made shorter but not unnecessary: a narrowing
helper still checks every value, and the static information is already there
and thrown away. Keeps every protocol contortion of section 12.

**B. Infer Y and R separately, internally only.** `Coroutine{args, yield: Y,
return: R, errors}` in HIR, both inferred with the machinery `Outward` uses.
On its own it changes nothing a consumer sees: the start and resume values
are still one of Y or R, and nothing tells the type checker which. It makes
diagnostics and the affine contract precise per channel and is the
foundation of D and E.

**C. A typed handle `Coroutine<Yield, Result>`.** The handle type constructor
exists (`{coroutine {args return errors}}`); adding a yield component is a
field, not a new constructor. The question is what `first` and `step()`
return: the join (as in B), or Y with the completion delivered elsewhere --
which needs an exhaustion signal (no: COROUTINES.md and AGENTS.md exclude an
exhaustion error) or a typestate in which a completed handle cannot be
resumed (the program cannot know statically which resume completes). C is B
in the type; it needs D or E to be usable.

**D. A tagged resume outcome** `Yielded(Y) | Completed(R)`. The principled
value-level answer: the phase travels with the value, the consumer cannot
misuse it. Requirements: reading a payload (`match`: not in the language;
PORTABILITY-PAYLOAD-ENUMS-MILESTONE-1.md 19 defers it), an outcome generic in
Y and R (generic enums: not added; or a compiler-intrinsic outcome type like
`Coroutine{...}` itself), and an allocation-free lowering where the outcome
is matched at once (section 13: a materialized outcome costs two allocations
per segment). Compatibility: `first` and `step()` cannot change their types
without breaking every consumer, so D is a *new* resume form beside the
current ones. Deep yields, errors (failures stay errors), ownership (a moved
affine Y in the Yielded case) and fusion (lowered to `st`/`out`) all fit.

**E. B plus the phase through `done?`** -- segment facts. Infer Y and R
separately (B), and let the test every consumer already writes carry the
phase to the type checker: a resume's value, related to its handle until the
next resume or move of it, has type Y on the path where
`std::coroutine::done?(handle)` is false. Sound by section 8's argument (the
not-done path is exactly the yield path, handlers included). No syntax, no
runtime change, no allocation, the coroutine operations' NIR unchanged,
fusion untouched. It types the
consumer shapes that keep the value in a binding or a fold's intermediate
(`n02-fold-consumer`, the actor host's `fold with intermediate r first:`),
not values kept in a `MutableArray` cell (the CSV sinks' current shape): a
cell has no relation to a handle. Inside the type checker it is a branch
fact (`hir::refine::branchFacts`, applied by `hir::types::Narrow`) keyed by
a relation, as call keys already are; relational facts minted and killed by
operations' contracts have a precedent in `hir/relations.tcl`.

| | A | B | C | D | E |
|---|---|---|---|---|---|
| static soundness | yes | yes | yes | yes | yes (not-done path only) |
| yields typed Y at the consumer | no | no | no | yes | where the value is a binding or fold intermediate |
| unrelated Y and R accepted | no | with the rule relaxed | with the rule relaxed | yes | with the rule relaxed |
| source syntax | none | none | handle spelling `yield:` | a new resume form; `match` | none (handle spelling optional) |
| HIR | -- | handle field | handle field | outcome type, match | handle field, branch facts |
| inference | -- | existing | existing | existing + outcome | existing + a relation |
| deep yields | as today | as today | as today | as today | as today |
| errors | separate | separate | separate | separate | separate |
| affine | merged contract | per channel | per channel | per channel (+ move yield) | per channel |
| runtime / NIR | -- | none | none | allocation-free only if matched at once | none |
| fusion | -- | identical | identical | needs a lowering | identical |
| compatibility | -- | full | full (default `yield` = `return`) | additive form | full |
| depends on | -- | -- | -- | `match`, generic or intrinsic enums | -- |
| scope | none | small | small | large | medium |

**Rejected outright**: an iterator protocol over coroutines (`loop x in
step:`) -- COROUTINES.md and AGENTS.md exclude one ("no iterator protocol");
a sentinel or an out-of-range value as the end; an exhaustion error; making
`emits` define yield types (section 18).

**Recommendation: E**, with B as its first half, and D kept as a later,
explicit API once `match` exists (section 19).

## 15. API ergonomics

Three workloads, today and under E (compiling programs are the corpus's;
proposals are labelled pseudocode).

**CSV source** (yields bytes, returns a record count). Today
(`s2-csv-reduced.bot`; `export.bot`): a `MutableArray` cell, a `done?` test,
a narrowing comparison with an impossible failure branch, an error declared
for it. Under E, with the emitter's yields Byte-typed (a declaration: the
helper of `s2-csv-typed-yields.bot`), the consumer is a fold:

```
# pseudocode (E): b is a Byte inside the loop, the count after the break
coroutine {step, first} = sources::bytes_document_source(header, rows)
chunk = std::mutable_vector::from_list("".encode_utf8())
written = fold with intermediate b first:
    if std::coroutine::done?(step):
        break
    chunk.push(b)
    if chunk.length() >= 4096:
        path.flush(chunk)
    step()
path.flush(chunk)
written
```

Today this shape compiles only with a narrowing comparison before
`chunk.push(b)` (`n02-fold-consumer.bot` is the shape over a smaller
source, with the comparison). Under E the cell, the impossible failure and
its error disappear, and the program is shorter than today's.

**Streaming parser** (yields records, returns a summary). Today the natural
shape is rejected (`w01`: COROUTINE-RESULT-MISMATCH, and `first`, a Record at
run time, is typed `Summary`). The working shape is an envelope struct with
every field of both, a record carrying an empty summary and the result an
empty record (`w01b`). A payload enum (`Record {...} | Summary
{...}`) is a valid common type (`t03`) but no program can read its payload
(`w01c`: NOT-A-STRUCT). Under E with the shared-type rule relaxed:

```
# pseudocode (E)
fn parse(lines: List[str]) -> Summary:
    loop line in lines:
        yield Record {key: line, value: 1}
    Summary {records: lines.length(), skipped: 0}

coroutine {step, first} = parse(lines)
summary = fold with intermediate r first:
    if std::coroutine::done?(step):
        break
    consume(r)            # r: Record
    step()
summary.records           # after the break: Summary
```

(the true path's type is R joined with any handler values: here, R; the
fold's value after a bare break is the intermediate as typed on the break's
path, which E must state as part of the rule: section 20, item 4).

**Incremental processor** (yields events, returns a status). Today rejected
(`w02`); the working shape puts the status in an Event, as `std::actor::exit`
does (`w02b`), and the consumer reads `c.at(0).at` after `done?`. Under E the
source returns an `int` and the consumer reads it after the fold's break.

**What E does not remove**: the `done?` test (it is the phase), and the
fold-or-binding shape (a value stored in a cell is a value like any other).
D would remove the test in exchange for a match per resume; for these three
workloads the fold under E is no longer than the match would be.

## 16. Compatibility and migration

Under E (projected, from the rules in section 20; nothing implemented):

* **Every accepted program keeps its types outside narrowed paths.** Today
  an accepted program has Y <: O and R <: O with O one of them (a declared
  result, or the supertype among the components). E types a start or resume
  value as the join of Y and R, which is that same O. Inside a not-done
  branch a related binding becomes Y, a subtype of O: every check that
  admitted it admits it still. Narrowing can nevertheless, in principle,
  reject an accepted program -- a collection whose element type is inferred
  from the narrowed binding (`std::mutable_vector::from_list([x])`) becomes a
  collection of Y, which a later push of a wider value no longer fits -- and
  can change the consumer's code by sharper facts (a semantic instance keyed
  by Y, a representation chosen on Y's domain). This census found no
  consumer in the repository that binds a resume value and then uses it
  under a `not done?` test (section 12's consumers keep values in cells or
  use them before testing); the milestone's corpus, golden and test runs
  must confirm it. A narrowing comparison like `export.bot`'s stays valid
  (it becomes redundant; no warning is proposed).
* **Programs rejected today become valid**: unrelated yields and result
  (`m03`, `m04`, `m05`, `m06`, `w01`, `w02`), with the unnarrowed value typed
  as the join (possibly `any`). The yields among themselves still need a
  common type (`m07` and `d02` stay rejected).
* **A declared result types R only.** Today `-> int` also bounds the yields;
  under E it does not (the yields are inferred). A source author who relied
  on the declared result to check the yields loses that check -- the reason a
  `yields` declaration is an open question (section 21).
* **Handle spellings** (`Coroutine{args: [], return: int, errors: [...]}` in
  `stdlib/event_loop.bot`, `stdlib/actor.bot`, `examples/dfa/json`) keep
  their meaning if an omitted `yield` means "the same as `return`". A handle
  with a narrower Y is a subtype of the old spelling (covariance), so
  `std::event_loop::adopt` accepts every task it accepts today.
* **HIR text and interchange** gain the yield component: the front-end
  fingerprint changes (as with any front-end change), `hir/read.tcl` reads
  both spellings.
* **Library migration**, optional and separate: `std::test::run` could yield
  `TestResult` and return `unit`; `std::tree::walk` could keep its shape
  (handing over every node alike is its contract); `std::actor::exit` and
  the event loop's `int` results would need their handle storage widened
  (`return: any`, or per-task result types) -- an API decision, not a
  consequence of E.

Complete source compatibility is established for accepted programs' types
by the argument above; it is to be checked by the milestone's corpus run and
the golden suites, not assumed.

## 17. Differential observations

(observed)

* **67 cases**, every expectation met (`census.tcl`: 120 rows, 0
  mismatches). By class: 31 intended (13 precise, 15 with range facts
  stopping at the boundary, 1 with no coroutine -- `t07` -- and 2 rejected by
  an unrelated rule on purpose, `t06` and `e05b`); 19 showing that a
  consumer must narrow (7 widened, 5 precise envelopes or sentinels, 3 with
  facts stopping at the boundary, 4 direct uses rejected); 10 rejected for
  precision; 6 rejected rightly; 1 needing a missing feature (`w01c`).
* **Every runnable case (44) produced the same value** on the interpreter,
  the Tcl compiler, Cranelift generic, Cranelift fused and Cranelift
  unfused, and again with `BOTLISH_NATIVE_GC_STRESS=1` (0 disagreements both
  times). No backend disagreement and no soundness defect was found.
* **The repository's consumers** (`examples/dfa/csv/export.bot`,
  `examples/dfa/csv/sinks.bot`, `examples/dfa/json/sinks.bot`, analyzed):
  every byte source's yields bounded in [0, 244], every first value
  unbounded; the CSV validator's recognizer yields {0}.
* **One run side effect worth recording**: the census's first version ran
  `export.bot` natively and wrote `export.csv` into the working directory;
  the repository's consumers are now analyzed only.

## 18. Soundness and precision findings

**Soundness**: no false acceptance found. Every type the compiler gives a
start or resume value is a supertype of every value a run produced, on five
backends and under GC stress. The merged type is sound by construction: O is
a supertype of Y and of R.

**Precision limits** (each a case):

1. The yield type is dropped from the handle although computed (`m02`,
   `d01`, `s2-byte-typed-source`, `s2-csv-typed-yields`, `n02`).
2. Unrelated yield and result types are rejected (`m03` x2, `m04` x2, `m05`,
   `m06`, `w01`, `w02`).
3. A `done?` test narrows nothing (`n01`).
4. Range facts never cross a coroutine boundary -- as they never cross an
   undeclared call result (`t05`, `t06`): by the language's rule, not a
   coroutine defect.
5. A generic helper's yields are typed by its generic body (`d05`, `d05b`),
   not per construction.
6. A List-length fact of the yields is lost in the join (`w03`:
   `List[int]{length: 1}` yields, `List[int]` outward).
7. Affine yields are rejected by a reason that is the result's (`o01`).

**A diagnostic-recovery imprecision** (`m10-no-yield-never.bot`): a
construction rejected as COROUTINE-RHS-NOT-YIELDING is typed with an `any`
outward type (`MakeCoroutine unit any {}`, `ShapeResult`), not poison, so
`first` returned where an `int` is declared adds "function result does not
prove declared type int (result type: any ...)" (TYPE), which only restates
the construction's problem. DIAGNOSTIC-RECOVERY.md's rule is that a value an
analysis proved invalid is poison. Separate from this census's subject;
recorded for a diagnostic-recovery change.

**`emits`**: separate yield typing would not simplify the emission checker.
It walks yields with its own value facts, composes helpers through
certificates, and already ignores the result. What separate typing would add
is a type checker that, for a source whose yields are typed (a declaration),
tells the consumer what the certificate has always known about the range.
The two remain different guarantees: a yield type is a property of every
value; a claim is a property of the whole trace. A source without a claim
gets the same yield type; a claim never defines one.

## 19. Recommended design

**E: segment types.** Three parts, all in the front end:

1. **Two types in the handle.** `{coroutine {args {M} yield Y return R
   errors {E}}}`. Y is the join of the static types of every reachable yield
   the coroutine can reach (today's `YieldTypes`, with the root's own yields
   refined by the construction's semantic instance as `InstanceOutward`
   refines them now); R is the root's declared result, else its inferred
   result. The source spelling `Coroutine{args: [...], yield: ..., return:
   ..., errors: [...]}` accepts `yield`, and an omitted `yield` means
   `return`'s type. A handle is a subtype of another when its yield and its
   return are covariantly so (and the old spelling's single type bounds
   both).
2. **The shared-type rule applies to the yields alone.** The yields need one
   type among themselves (COROUTINE-RESULT-MISMATCH's yield half, `m07`,
   `d02`); the result is free. A start or resume value is typed with the join
   of Y and R -- for every program accepted today, today's outward type.
3. **The phase reaches the type checker through `done?`.** A binding bound
   to a start or resume value of handle H, or a fold intermediate whose
   initial value and every normal completion are such values, is related to
   H; any later resume of H, any move or release of H, ends the relation (H
   is affine: no alias can resume it behind the analysis). Where a condition
   `std::coroutine::done?(H)` is false, a related binding has type Y; where it
   is true, the join of R and the handlers' values of the resume that bound
   it. A bare `break` of a fold whose intermediate is related gives the fold
   the intermediate's type on the break's path (the parser workload's
   summary, section 15). Types only: no range facts cross the boundary.

**Why E and not D now.** D needs two features the language does not have
(`match`, generic or intrinsic enums), a new resume form beside the current
ones, and an allocation-free lowering of its outcome to be no slower than
today. E needs none of these, reuses the branch-fact machinery, changes no
NIR, and types the consumer code already written in fold or binding shape.
D remains the explicit API to add once `match` exists: it can be lowered to
E's facts (a match on `next(step)` is a resume and a `done?` branch).

**What E deliberately leaves out**: range facts across the boundary (the
language carries facts across a boundary only as declarations), a declared
yield type, affine yields, a tagged outcome, an iterator protocol, any
runtime or NIR change, and any interaction with `emits`.

## 20. Proposed minimum implementation milestone

**SEGMENT-TYPED-COROUTINES-MILESTONE-1** (a proposal):

1. **Handle type.** `hir::types::MakeCoroutineType` gains the yield
   component; `CoroutineOutward` becomes the join of yield and return;
   `CoroutineMismatch` compares both covariantly; HIR text prints `yield:`
   (omitted when equal to `return`), `hir/read.tcl` reads both spellings;
   the parser accepts the `yield` field (`af-contract-forms` updated).
2. **Inference.** `hir::coroutines::Outward` split into the yield join and
   the result; `ShapeResult`'s `coroutine-create` builds the two-type handle.
3. **Checks.** `ResultMismatch` checks the yields among themselves;
   `AffineProtocol` checks R (cached) and the message as today, and refuses an
   affine Y with its own reason (affine yields stay unsupported: section 21).
4. **Segment facts.** A relation in the type walk (ctx facts keyed by the
   handle binding, as call keys are), minted by `coroutine#start` and
   `coroutine#resume` values bound to a binding or carried by a fold's
   intermediate, killed by every other operation that may resume, move or
   release the handle; `hir::refine::branchFacts` narrows on
   `std::coroutine::done?`; a fold's value at a bare `break` takes its
   intermediate's type on that path (`hir::types::FoldBody`). Range analysis
   untouched.
5. **Nothing else**: no runtime, NIR, fusion, C backend, emission or library
   change. `examples/dfa/csv/export.bot` may be rewritten as a fold over a
   Byte-typed emitter as the milestone's demonstration, or left as it is.

**Evidence the milestone owes**:

* this census's corpus, every case's `# expect:` updated where its
  observation changes (the rejected-precision cases accepted, the narrowing
  cases' direct forms accepted where the yields are typed);
* a property check that start and resume values are typed exactly as today
  for every golden suite and test program (no accepted program changes
  type); NIR byte-identical for the golden corpus on both native backends
  (expected, since no program there narrows) and the coroutine fusion census
  unchanged, and, where a program does narrow, a record of what its NIR
  gained;
* tests of each kill rule (a resume, a move, a release, a call receiving the
  handle between the binding and the test), of handled resumes on the true
  path, of fold intermediates, of `first` from a construction that completes
  or fails in its first segment;
* a fuzzer comparing the narrowed types with a run's observed phases (the
  coroutine fuzzer's programs with `done?`-guarded uses);
* mutants of the relation's kills and of the narrowing's branch;
* the static-decision harnesses for the new branch facts (a fact a method
  decision may read), compilation isolation and interchange for the handle
  type, the C-target note (coroutines are C UNSUPPORTED: nothing changes for
  C).

**Cost estimate** (projected): the front end only -- `hir/types.tcl`,
`hir/coroutines.tcl`, `hir/refine.tcl`, `hir/format.tcl`, `hir/read.tcl`,
`surface/parser.tcl` -- about the size of a precision milestone of the
emission checker's, plus the evidence.

## 21. Deferred features and open questions

* **A declared yield type.** Without syntax, Y is what the yield
  expressions' static types say, and a literal-int emitter yields `int`. Its
  Byte-ness can be declared today only through a typed helper. A `yields T`
  clause beside `errors` and `emits` would be the direct form -- and would
  restore the check a declared result gave the yields before E. Open; not
  recommended until E's inferred Y has been used.
* **Range facts across the boundary.** A yield-range summary in hir::range
  (like a callee's result summary) would type CSV's yields without a
  declaration, but crossing a boundary as an implementation fact is what the
  language refuses for ordinary results. Not recommended.
* **A tagged outcome** (D): after `match` and generic or intrinsic enums,
  as an explicit API lowered to E's facts.
* **Affine yields**: `coroutine#yield` with a `move` ownership role, Y
  checked per channel; the runtime already delivers each yield once.
* **Generic helpers' yields per construction** (`d05`): an instance-aware
  YieldTypes over the root's call tree.
* **Library protocols** (`std::test::run`, `std::actor::exit`, event-loop
  task results): each its own API change after E.
* **The `MutableArray` cell idiom** (a consequence of no mutable bindings)
  keeps values out of E's reach; folds and bindings are the shapes E types.
* **COROUTINE-RHS-NOT-YIELDING's `any`** should be poison (section 18).
* **A resume message sentinel**: `std::dfa::Symbol {code: -1}` is the
  message-side counterpart of the -1 end (the end of input sent *to* a
  recognizer). Out of scope here; the same reasoning would apply to it.

## The final questions

**1. What exactly is conflated today?** The static type of the yield values
and of the terminal result: one outward type for both, which also types the
first value and every resume. The resume outcome (yield or completion) is
not conflated but absent from the value: it is the handle's state, read by
`done?`. Errors and resume messages are separate.

**2. Does the runtime already have the right distinction?** Yes: the Tcl
runtime's segment tags and store states, the native `CO_SUSPENDED` and
`CO_COMPLETED`, fused code's `st`. The type system can expose it without
changing execution, through `done?` (E).

**3. How much new type information is necessary?** One more type in the
handle, Y, which existing inference already computes (and HIR text already
prints on the source); no new syntax. For sources whose yields are int
literals (CSV), Y is `int`: making it `Byte` takes a declaration (a typed
helper today, perhaps a `yields` clause later), because facts cross a
boundary only as declarations.

**4. What would a CSV consumer look like afterward?** A fold whose
intermediate is the latest segment's value: `chunk.push(b)` with `b` a Byte
inside, the record count after the break -- no cell, no impossible failure,
no error declared for it (section 15). It eliminates the narrowing only
where the emitter's yields are Byte-typed.

**5. How does the design interact with deep yields?** Y is the join over
every yield the root can reach, as the outward type is today: computed from
the root's declaration, its body and its helpers' generic bodies, reading no
consumer. As modular and caller-independent as today's rule; generic
helpers keep their generic yield types.

**6. Does it preserve ownership and native fusion?** Yes. Ownership
obligations are unchanged (and become checkable per channel); fusion reads
no HIR type, and E changes no coroutine operation's NIR, so fusion's
conditions, census and code are identical. Affine yields additionally need an ownership role on
`coroutine#yield`, deferred.

**7. Is the change worth making now?** Yes, as the bounded front-end
milestone of section 20, mainly because the rule shapes library protocols
(actors, tests, task results, sentinel generators) and rejects ordinary
parser and processor shapes; the run-time cost of today's narrowing is
small (about 4% of a fused consumer's time per symbol), and the CSV case
alone would not justify it. The tagged outcome
should wait for `match`.

## Files

| path | what |
|---|---|
| `../audit/typed-coroutine-sources/README.md` | the corpus's guide: classes, observations, reproduction |
| `../audit/typed-coroutine-sources/cases/` | 67 programs (`s2-*` the CSV symptom, `m*` the matrix, `p*` the protocol, `t*` precision, `d*` deep yields, `e*` errors, `o*` ownership and contexts, `n*` the phase, `c*` sentinels, `w*` workloads, `x*` emits) and `support/handle.bot` |
| `../audit/typed-coroutine-sources/tools/census.tcl` | the census tool |
| `../audit/typed-coroutine-sources/tools/inventory.tcl` | the repository inventory |
| `../audit/typed-coroutine-sources/tools/bench.tcl` | the benchmark |
| `../audit/typed-coroutine-sources/results/` | `census.txt`, `matrix.tsv`, `sites.tsv`, `bench.md` |

## How to rerun

```sh
export LANG=C.utf8 LC_ALL=C.utf8
cargo build --release --manifest-path native/Cargo.toml
tclsh9.0 audit/typed-coroutine-sources/tools/census.tcl
BOTLISH_NATIVE_GC_STRESS=1 tclsh9.0 audit/typed-coroutine-sources/tools/census.tcl -external 0 -out /tmp/gc
tclsh9.0 audit/typed-coroutine-sources/tools/inventory.tcl
tclsh9.0 audit/typed-coroutine-sources/tools/bench.tcl
```

The census takes about 30 seconds; it exits 1 on a mismatch with a case's
expectation or a backend disagreement.

## Main's CI

Checked before this census branched (2026-11-13, main at ae2cb861): the
latest finished runs of tests, tests (linux arm64), tests (macos arm64) and
tests (windows x86-64) are red at ede621b1 on every host. By ce54fead's
commit message, the failures are `c-ffi.test`, `external-tools.test`,
`application-library.test` and `c-bindgen.test`, whose rustc-linked
executables could not find their crates under cargo 1.100's build-directory
layout, and ce54fead fixes it; ce54fead's runs were cancelled by ae2cb861's
push, whose runs were queued or in progress. Before that, tests' cranelift
coverage at 023dfaa3 failed `vt-large` (`tests/value-transfer.test`), recorded
as intermittent. This census adds `docs/` and `audit/` files only.
