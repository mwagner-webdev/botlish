# ERROR-PAYLOADS.md

Payload-bearing errors: a nominal error identity with a statically known
named-field payload, received by ordinary binding and irrefutable struct
destructuring.

> Botlish errors separate exceptional identity from structured information.
> A nominal error tells the consumer what happened; its optional named
> payload tells the consumer about what happened. `on` performs only nominal
> error discrimination, after which ordinary binding and irrefutable struct
> destructuring expose the payload. Payload transport participates in the
> same value, affinity, cleanup, and module rules as ordinary Botlish data,
> without introducing exception objects, structural matching, or a second
> ownership system.

```botlish
error PageNotFound:
    uri: str
    statusCode: int
    response: Response
```

is one error -- the same construct as the payload-free `error ConnectionLost`,
whose payload is the zero-field case -- and these are five ways of receiving
the same statically known payload:

```botlish
on PageNotFound:                                   # ignored
on PageNotFound details:                           # bound whole
on PageNotFound {uri, statusCode}:                 # destructured
on PageNotFound {uri: pageUri}:                    # destructured, renamed
on PageNotFound {response: {payloadStream, length}}:   # nested
```

`PageNotFound` selects the handler; nothing in `{...}` tests anything: the
payload's shape is known from the error's identity.

## Contents

* [The principal program](#the-principal-program)
* [What changed, in one page](#what-changed-in-one-page)
* [Report](#report) -- the 65 points of the milestone report, in order
* [Native evidence](#native-evidence) -- the NIR of a failure and of each handler form
* [Payload-bearing enums are not this](#payload-bearing-enums-are-not-this)
* [Files](#files)
* [What to run when changing this](#what-to-run-when-changing-this)

## The principal program

The brief's item 78 as Botlish accepts it (`tests/error-payloads.test`'s
`ep-principal`, `ep-principal-ints`, and `ep-principal-bytes` with the
stdlib's `abi::bytes::Bytes` as the stream), on the Tcl interpreter, the Tcl
compiler and Cranelift without and with specialization:

```botlish
struct Response:
    payloadStream: str          # abi::bytes::Bytes in ep-principal-bytes
    length: int

error PageNotFound:
    uri: str
    statusCode: int
    response: Response

fn fetch(uri: str) -> str errors PageNotFound:
    if uri == "":
        return "home"
    fail PageNotFound {
        uri: uri,
        statusCode: 404,
        response: Response {
            payloadStream: "",
            length: 0,
        },
    }

fn whole(uri: str) -> str:
    fetch(uri):
        on PageNotFound details:
            details.uri

fn fields(uri: str) -> int:
    page = fetch(uri):
        on PageNotFound {statusCode}:
            return statusCode
    str::length(page)

fn rename(uri: str) -> str:
    fetch(uri):
        on PageNotFound {uri: pageUri}:
            pageUri

fn nested(uri: str) -> int:
    page = fetch(uri):
        on PageNotFound {
            response: {
                payloadStream,
                length,
            }
        }:
            return length + str::length(payloadStream)
    -1
```

Two adjustments to the brief's text, both existing rules of the language,
neither touched here:

* the brief's `fetch` fails unconditionally. Botlish rejects a call that can
  never complete normally (`KNOWN-ERROR`, STATIC-COMPLETION-PROOFS.md:
  "known failure -> compile-time rejection"), so `fetch` succeeds for `""`;
* the brief's `fields` and `nested` declare `-> int` while their handled call
  `fetch(uri)` is a `str`: a handler's value must be admissible as the call's
  own result (EXPLICIT-ERROR-COMPLETIONS.md, "Handler typing"), so those
  handlers `return` their Int and the success path computes one.

`[whole("/x"), rename("/z"), ignored("/v"), whole("")]` is `["/x", "/z",
"fallback", "home"]` and `[fields("/y"), nested("/w"), fields(""),
nested("")]` is `[404, 0, 4, -1]` on every backend.

## What changed, in one page

* **Grammar** (`surface/parser.tcl`): `error NAME:` followed by indented
  `field: Type` lines (the struct field grammar); `fail NAME {field: value,
  ...}` (the struct field-initializer payload); `on NAME`, `on NAME IDENT`
  or `on NAME PATTERN` (the destructuring pattern grammar). Guards, value
  patterns, positional payloads and several errors per handler are syntax
  errors with their own messages.
* **Lowering** (`surface/lower.tcl`): a payload is a `struct` syntax node
  marked `payloadOf NAME`; a handler's payload is a binding of the handler's
  own scope -- the written name, or, for a pattern, the pattern's hygienic
  temporary `destructure#N`, whose ordinary projection binds (the very
  `Projections` a destructuring statement uses) open the handler body.
* **Error descriptors** (`hir/errordecls.tcl`): identity plus payload fields
  (declaration order, resolved types, spans, declaring namespace);
  `payloadType NAME` is the anonymous struct type of the fields.
* **HIR** (`hir/resolve.tcl`, `hir/types.tcl`, `hir/range.tcl`): `fail` has a
  `value`; the payload construction is checked like a named construction
  (`MISSING-FIELD`, `UNKNOWN-FIELD`, `DUPLICATE-FIELD`, `TYPE`); `fail` of a
  payload-bearing error without one is `MISSING-ERROR-PAYLOAD`, a payload on
  a payload-free error `UNEXPECTED-ERROR-PAYLOAD`; a handle has
  `handlerPayloads`, one binding (or "") per handler, typed with the error's
  payload type.
* **Ownership** (`hir/affine.tcl`): a payload is a move target (`move error`);
  a handler's payload binding starts live like a parameter and is released by
  the ordinary rules; an ignored affine payload gets a hidden binding
  (`payload#E#K`) released after the handler's first statement; a coroutine
  may not fail with an affine payload (`COROUTINE-CONTRACT`).
* **Core IR / Tcl backends**: `(fail NAME PAYLOAD)`, handler blocks with one
  parameter; the error identity `{errorId NAME PAYLOAD}` (`{errorId NAME}`
  unchanged for a payload-free error).
* **Native**: `faildeclared ID NAME SHAPE FIELDS...` copies the payload's
  field values into the Vm's payload slots; `declaredpayload K` reads field K
  in the handler, which holds the payload binding as a virtual struct; no
  struct object is built to transport a payload.
* **Warnings**: `SAME-FAILURE` groups a payload-bearing failure only with one
  whose payload is proven identical (the rule WARNINGS-SAME-FAILURE.md
  reserved).

## Report

### 1. Declaration grammar

```
errorDecl = "error" IDENT NEWLINE
          | "error" IDENT ":" NEWLINE INDENT { IDENT ":" typeExpr NEWLINE } DEDENT
```

The payload-free spelling is unchanged. `error NAME:` with no field line is
a syntax error that names the payload-free spelling ("a payload-free error is
declared `error E`, without the colon"): an empty payload has exactly one
spelling. A declaration is top-level only, as before (`ep-declaration-grammar`).

### 2. Payload field grammar

Exactly a struct declaration's field line: `name: Type`, an explicit type
from the whole type grammar (structs declared before or after, enums,
`List[T]`, `ImmutableSet[T]`, `Fn{...}`, `Coroutine{...}`, refined and domain
types), one per line, no default. Rejected at the declaration
(`ep-declaration-rejections`): a duplicate field (`DUPLICATE-FIELD`), a
default value, a positional payload `error E(str, int)`, an anonymous payload
type `error E: {a: int}`, a rest field `...rest` (syntax errors with their own
messages), an unknown or trait type (`TYPE`, `TRAIT-STORAGE-UNSUPPORTED`,
`CONTEXT-TRAIT-POSITION`, as for a struct field). Field types resolve in the
declaring module's namespace (`ep-cross-module`: `meta: Meta` in module
`eppage` is `eppage::Meta`).

### 3. Payload-free compatibility

Unchanged in grammar, HIR (`fail NAME` with an empty `value`, no child;
handlers with no payload binding), Core IR (`(fail NAME)`, `(block {} ...)`
handlers), the Tcl runtime (`{errorId NAME}`) and native code: a payload-free
program's NIR is byte-identical to the tree before this milestone
(`ep-native-payload-free-unchanged`; the scalar audit, point 61). The whole
existing suite passes unchanged (point 53); the one test edited is
`sf-fail-carries-no-payload`, whose own text said it pins the absence of
payloads.

### 4. Nominal error identity

The name is the identity, as before: program-global, declared once
(`hir/errordecls.tcl`). Two errors with identical fields are two descriptors
(`ep-declaration-nominal`), handled by their own handlers only
(`ep-same-shape-distinct`), never interchangeably (`ep-same-shape-not-
interchangeable`: handling the twin leaves the raised error unhandled,
`UNHANDLED-ERROR`). The payload never contains the identity: there is no
`kind`/`name` field (`details.kind` is `UNKNOWN-FIELD`).

### 5. Payload metadata

The error descriptor (`hir::errordecls::payloads`, HIR's `errorPayloads`)
holds, per payload-bearing error, the field names in declaration order, each
field's resolved type, the field and type spans, the declaration span and
the declaring namespace. `fields NAME` gives `{FIELD TYPE ...}` in
declaration order; `payloadType NAME` the anonymous struct type
`{struct {FIELD TYPE ...}}` (fields sorted -- the canonical anonymous form). A
payload-free error has no entry: its descriptor is the identity with zero
fields. Field identity is the name, never the position (the payload struct's
slot order is the sorted names, the declaration order is kept for
diagnostics and HIR text).

### 6. Failure construction

`fail NAME {field: value, ...}` lowers to a `fail` node whose `value` is a
`struct` node marked `payloadOf NAME`: an anonymous struct construction
resolved and checked as a named construction is (`hir::resolve::
ResolveStruct`): every declared field exactly once (`MISSING-FIELD`), none
undeclared (`UNKNOWN-FIELD`), none twice (`DUPLICATE-FIELD`), and each value
*proven* admissible for its declared type by the same proof a declared
parameter's argument gets (`hir::range::VerifyPayload`, `TYPE`; an untyped
value is rejected, never guarded: `ep-fail-fields-like-a-struct-literal`).
Fields are evaluated in written order, then the error is raised; a field
that fails or returns raises that instead (`ep-fail-written-order`). The
construction is typed with the declared payload type, whatever its values
are, as a named construction is. No positional form (`ep-fail-positional-
rejected`).

### 7. Missing/extra payload diagnostics

`fail NAME` of a payload-bearing error is `MISSING-ERROR-PAYLOAD` ("error
"ObjectNotFound" carries a payload, which "fail ObjectNotFound" must
construct: write "fail ObjectNotFound {uri: ...}" ..."). A payload on a
payload-free error, `{}` included, is `UNEXPECTED-ERROR-PAYLOAD`, and so is
binding or destructuring a payload-free error's payload in a handler (there
is nothing to bind): no anonymous payload is ever created (`ep-fail-
missing-payload`, `ep-fail-unexpected-payload`, `ep-bind-payload-free`).

### 8. Field type checking

The proof of point 6 (`ProvesValueAcceptedBy`), so a refined or domain field
type takes exactly the values proven in its domain, a struct field its
declared struct, an enum field its enum's cases, `Fn{...}` a callable whose
contract admits it. The diagnostic names the payload: `payload field "uri"
of error ObjectNotFound cannot be proven to satisfy its declared type str
(value type: int)`.

### 9. Error contracts

`errors E1, E2` and `Fn{... errors: [...]}` name identities only; a payload
field list there is a syntax error (`ep-contracts-name-identities`). The
payload belongs to the declaration, so two contracts naming one identity
agree on its payload by construction.

### 10. Propagation

An error a call raises and its caller does not handle leaves the caller with
its identity and its payload unchanged: no reconstruction, no field lost
(`ep-propagation`, two declaring functions deep). In the Tcl backends the
completion carries the `errorId` value itself; natively the payload slots
are untouched by every frame the error leaves (point 26).

### 11. Handler without binding

`on NAME:` handles the error and ignores its payload; for an unrestricted
payload nothing at all happens to it (natively nothing is read). For an
affine one, see point 38.

### 12. Whole-payload binding

`on NAME details:` binds the payload to an ordinary binding of the handler's
own scope (a parameter of the handler, like a loop's element binding):
projections (`details.uri`), passing it, storing it, comparing it -- an
ordinary value (`ep-whole-binding-is-the-payload`, `ep-captured-payload-
binding`: a nested function may capture it).

### 13. Payload whole-value representation

The anonymous struct of the declared fields, `struct{response: Response,
statusCode: int, uri: str}`: no source-nameable type, no hidden nominal type
and no identity field. Equality is the anonymous struct's (structural:
`details == {uri: "o"}` is `true` for `ObjectNotFound`'s payload); it renders
as one (`{response: Response {payloadStream: "", length: 0}, statusCode:
404, uri: "/p"}`). A helper may take either of two same-shaped errors'
payloads when its own parameter admits the structure; the handlers stay
nominal.

### 14. Partial destructuring

`on NAME {uri}:` is exactly `{uri} = details` over the payload binding:
requested fields must exist, the others are not bound. Adding a field to the
declaration does not affect it (`ep-partial-destructuring`, the brief's item
64). Unbound affine fields are released (point 41).

### 15. Renaming

`{uri: pageUri}`: the field on the left, the binding on the right -- the
destructuring rule, no handler alias (`ep-principal`'s `rename`).

### 16. Nested destructuring

`{response: {payloadStream, length}}` is the destructuring statement's
recursive expansion (a nested hygienic temporary bound to `tmp.response`,
then its projections): the same `Projections` procedure
(`surface/lower.tcl`), no handler-specific nesting (`ep-principal`'s
`nested`; diagnostics in point 18).

### 17. Handler scoping

The payload binding and every binding a pattern makes belong to the
handler's branch scope: never visible after the handled call rejoins
(`UNBOUND`), and, like any nested scope, they may shadow an outer name; a
name bound twice in one handler is `DUPLICATE`, whether by the pattern or by
the body (`ep-handler-scope`, `ep-destructuring-diagnostics`).

### 18. Rejection of matching/guards

* Value or range in a pattern position (`{statusCode: 404}`, `{statusCode:
  400..499}`, `{uri: "/x"}`): the destructuring grammar's own syntax error
  ("expected a binding name or a nested "{...}" pattern"): a position binds,
  it never compares (`ep-no-value-patterns`).
* `on E if ...`, `on E where ...`, `on E details if ...`: "a handler selects
  only by the error's identity ("on E:"): there are no handler guards; test
  the payload with an ordinary "if" inside the handler". `on E, F:` and `on E
  | F` (one error per handler), `on E(a, b):` (received by name): syntax
  errors. A second handler for the same error stays `DUPLICATE`: there is no
  payload-driven selection (`ep-no-guards`).
* Destructuring diagnostics are the ordinary ones: `UNKNOWN-FIELD`,
  `NOT-A-STRUCT`, `DUPLICATE`, `LIST-DESTRUCTURING`, the rest-binding error
  (`ep-destructuring-diagnostics`).

### 19. HIR error descriptor

HIR's `errorDecls` (the names, as before) and, for payload-bearing errors,
`errorPayloads`: NAME -> `{fields {FIELD TYPE ...} namespace NS}`. HIR text
prints `error NAME` or `error NAME ns NS payload F1: T1, F2: T2`, and reads
it back (`ep-principal-hir-text-round-trip`):

```
error PageNotFound ns - payload uri: str, statusCode: int, response: Response
```

### 20. HIR fail representation

```
e10 fail PageNotFound : never
    e11 struct payload(PageNotFound) (uri, statusCode, response) : struct{response: Response, statusCode: int, uri: str}
        e12 ref b2 uri : str
        e13 const 404 : int
        e14 struct Response (payloadStream, length) : Response
```

The payload construction is a typed struct node (written order, slots,
declared payload type) until lowering: field admission (point 8), moves
(`ref ... move` on an affine field), drop descriptors and the native field
transport all read it.

### 21. HIR handler representation

Selection, the payload binding and the body are three visible parts:

```
e28 handle : str
    e29 call block(e2) : str
    on PageNotFound s9 payload (b9 destructure#578) binds b10 statusCode
        e32 bind b10 statusCode : int
            e33 project statusCode : int
                e34 ref b9 destructure#578 : struct{response: Response, statusCode: int, uri: str}
```

`on NAME SCOPE` is the nominal selection; `payload (B NAME)` the binding the
payload is bound to (a parameter of the handler's scope); the destructuring
is ordinary `bind`/`project` HIR. An affine destructuring temporary prints
what moved out of it (`consumed=stream`), an ignored affine payload its
hidden binding (`payload (b18 payload#e46#1)`) and the statement after which
it is released (`release=b18`) (`ep-principal-hir`, `ep-affine-hir-
evidence`).

### 22. Core IR transport

`(fail NAME PAYLOAD-EXPR)` beside `(fail NAME)`; a handler block may have one
parameter, `(block {P} ...)`, bound to the payload. A releasing re-raise on
an error edge (`hir::lower::ReleasingOnError`) binds the payload and raises
it again: `(block {affine#raised#E} RELEASES... (fail NAME (ref
affine#raised#E)))`. Payload-free errors keep `(fail NAME)` and parameterless
blocks. Lowered Core IR rebuilds into HIR that lowers back to the same Core
IR (`ep-principal-core-ir`).

### 23. Tcl interpreter representation

The completion `propagate-error` carries the error identity value
`{errorId NAME PAYLOAD}` -- two components, the name and the payload value
(an anonymous struct value) -- or `{errorId NAME}` as before. `op-handle`
compares names only and defines the handler's parameter from
`core::value::errorIdPayload`: no debug string is ever parsed.

### 24. Tcl compiler lowering

`return -code 5 [core::value::errorId NAME $payload]`; a matching handler
sets its payload variable from `core::value::errorIdPayload` (a frame
definition when the scope is materialized, a local otherwise, as a loop's
element binding); everything else re-raises with `return -options`, which
keeps the payload. The compiler agrees with the interpreter on every test
and fuzz program.

### 25. Native representation

Field-wise, never boxed for transport: `Vm::declared_payload` (a
`Vec<Value>`, its capacity reused; a GC root) holds the payload's field values
in the anonymous payload struct's slot order, beside the existing
`declared_error` id; `declared_payload_shape` names the shape for rendering an
uncaught one. A payload-free error leaves the slots empty. A failed
coroutine caches `(RtError, id, payload, shape)` and restores the slots on
every re-raise.

### 26. Native lowering

```
faildeclared 1 "PageNotFound" 1 %12 %7 %6     # fail: SHAPE, then the fields in slot order
...
%4 = declaredpayload 1                         # handler: the fields it reads
cleardeclarederror
```

`fail` evaluates the payload construction's fields in written order
(`StructFields`, the struct literal's own procedure) and hands them to
`rt_fail_declared_payload` from a stack array. A matching handler reads the
fields its payload binding is projected through (`PayloadNeeded`: the
projected names plus every affine field, or all of them when the binding is
used whole) before clearing the error, and holds the binding as a virtual
struct (`{virtual FIELDS SHAPE ...}`, the scalar-replacement entry): a
projection is the field register, a whole use materializes it once
(`structnew`), a capture by a nested function builds it at the handler.
Propagation needs nothing: `reraise` and every `may_error` exit leave the
slots alone.

### 27. Payload-free native path

Unchanged instruction for instruction: `faildeclared ID "NAME"` (no shape,
no fields), `rt_fail_declared` now also empties the payload slots (a length
store), handlers read nothing. A payload-free failure allocates nothing
(`ep-native-no-payload-allocation`).

### 28. Small-payload native path

A one-Int payload fails and is handled with zero heap allocations; three
scalar fields likewise; only what a field is itself allocates (a String built
for it, a nested struct), and a whole binding used as a value builds one
struct at the handler (point 62's allocation table).

### 29. Success-path overhead

None: declaring a payload-bearing error in `errors` constructs nothing and
reads nothing on a successful call (`ep-native-no-payload-allocation`'s
success rows; point 62).

### 30. Nominal handler dispatch

`if raised identity == handler identity`, on every backend (`op-handle`'s
name comparison, the compiler's `switch` on the name, native
`declarederroreq ID`). The payload's shape or value never participates
(the `dispatch-by-shape-*` and `same-shape-interchangeable-native` mutants,
point 52).

### 31. Same-shaped distinct errors

`error A: uri: str` and `error ObjectNotFound: uri: str` are unrelated
(`ep-same-shape-distinct`, `ep-same-shape-not-interchangeable`); the fuzzer
gives every program such a twin (point 51). Same field names across errors
are ordinary (`ep-multiple-payload-errors`).

### 32. Generic propagation

`fn call(f, x): f(x)` with a payload-raising callee is specialized for it
(monomorphization / semantic instances, no runtime dispatch); the payload
reaches the handler unchanged (`ep-generic-propagation`; the fuzzer's
`generic` path).

### 33. Function-value error contracts

`Fn{args: [int], return: int, errors: [ObjectNotFound]}` names the identity;
a call through it carries the payload; the subset rule is unchanged (a
callee raising more than the contract admits is `TYPE`)
(`ep-function-values`).

### 34. Handler rejoin

Unchanged: the handle's type is the call's; each handler's value must be
admissible as it (`ep-rejoin-unchanged`: a handler answering a String from
`{uri}` rejoins a String call, one answering an Int is `TYPE`); facts and
reachability join as before. The only addition is the payload binding's
type, an ordinary local of the handler.

### 35. Validator/refinement interaction

`fn validate_short(value: str) -> unit proves value: Short errors Invalid`
with `error Invalid: reason: str, at: int`: a successful call proves `Short`
for the rest of the path; the error edge does not (a handler that falls
through without proving it makes the later `use(text)` a `TYPE` error), and
a handler that returns keeps the proof on the success path (`ep-validator`).
`tests/refinement-validators.test` and `tests/refinement-values.test` pass
unchanged (point 56).

### 36. Payload affinity

`hir::types::IsAffine` of the payload type: the anonymous struct rule --
affine exactly when a field is (`ep-affine-payload-type`). The identity is
not a value and has no affinity.

### 37. Affine fail construction

A field value moves into the payload as into any struct field (`move field`);
the payload construction moves into the error (`move error`). A later use of
the moved binding, including inside the same payload, is `USE-AFTER-MOVE`
("s stored in field stream of a struct") (`ep-affine-fail-moves`).

### 38. Ignored affine payload

A handler that ignores an affine payload gets a hidden payload binding
(`payload#E#K`, unspellable), which the ordinary rule releases after the
handler's first statement (or on an exit before it): deterministic, exactly
once, never left to a collector (`ep-affine-handlers` on the Tcl backends'
live-coroutine count, `ep-affine-native-releases` on the native counters:
every coroutine released, none swept).

### 39. Whole affine binding

`on ReadFailed details:` makes `details` the owner (a live parameter of the
handler): projections of unrestricted fields read it, a destructuring moves
out of it, and it is released at its last use or on any exit.

### 40. Affine destructuring

`on ReadFailed {stream, bytesRead}:` -- the payload binding is a
destructuring temporary: `stream` moves out of it (`consumed=stream`),
`stream` owns the coroutine, the temporary drops only what was not moved out
(the descriptor excludes consumed fields).

### 41. Partial affine destructuring

`on ReadFailed {bytesRead}:` releases the unbound `stream` with the
temporary (`ep-affine-handlers`).

### 42. Propagation of affine payload

The same ownership tree moves outward: no copy, no drop-and-recreate; a
releasing re-raise on an error edge re-raises the payload it received
(`ep-affine-propagation`; the `propagation-copies-affine-payload` mutant
releases it on the way and is killed).

### 43. Early-exit cleanup

A handler's payload bindings are released by the exits that leave them --
`return`, `fail` (including through a failing call in the handler),
`break`, `continue` -- by the ordinary exit and error-exit releases
(`ep-affine-handler-exits`, `ep-affine-refail`).

### 44. Pending-argument interaction

A payload error raised while an earlier argument is pending abandons that
argument, which is released; the payload is a separate ownership tree that
propagates (`ep-affine-pending-arguments`). A payload field that fails after
an earlier affine field moved into the payload abandons the payload under
construction: the earlier field is a pending temporary and is released
(`ep-affine-partial-construction`).

### 45. Outermost unhandled cleanup

Under `-strict 1` no declared error reaches the program boundary: a
top-level call that may raise one is `UNHANDLED-ERROR` at compile time
(`ep-uncaught-strict`), and a coroutine's escaping error is raised at its
resume, where it is checked. A program run with `-strict 0` despite
diagnostics gets no release elaboration at all (the affine milestone's rule
for rejected programs), so its uncaught payload is reported and left to the
collector.

### 46. Coroutine error interaction

A coroutine may fail with a payload-bearing error: its handler at the
resume receives the payload (`ep-coroutine-cached-payload`).

### 47. Cached coroutine failure rule

Option 1 of the brief: **a coroutine may not fail with an error whose
payload is affine.** A failed coroutine raises its cached error again on
every later resume, for the same reason its cached final result must be
unrestricted; `hir::coroutines::AffineProtocol` rejects a construction whose
coroutine's error contract names such an error (`COROUTINE-CONTRACT`: "gen's
coroutine may fail with ReadFailed, whose payload struct{...} is affine: a
failed coroutine raises its cached error again on every later resume, which
would give the one affine payload several owners ..."). An unrestricted
payload is cached and raised again unchanged, on every backend (Tcl: the
cached completion; native: the cached field values, GC roots of the
coroutine object) -- `ep-coroutine-cached-payload` raises it twice. Error
payloads outside coroutines may be affine.

### 48. Enum payload fields

Ordinary values: `kind: ParseErrorKind` is selected nothing by; a handler
branches on it with `if` after `on ParseFailed` (`ep-enum-and-list-fields`,
`ep-compile-error-shape`).

### 49. Collection payload fields

`List[...]`, `MutableVector[...]`, `MutableArray[...]` fields are ordinary
values: a MutableVector moved into a payload is the logical copy
`hir::mutvec::Elaborate` writes for any struct field, and a handler's
payload binding is a place like a parameter (`details.items.push(7)`)
(`ep-mutable-collection-fields`).

### 50. Debug rendering

An uncaught payload error (reachable only with `-strict 0`) renders
identically on every backend:

```
uncaught propagated error: <error PageNotFound {response: Response {payloadStream: "", length: 0}, statusCode: 404, uri: "/q"}>
```

the identity, then the payload's ordinary struct rendering (opaque fields
render as `<opaque T>`): a diagnostic, not a serialization or a parser
contract (`ep-uncaught-rendering`). Natively the payload is rendered lazily,
at the program boundary (`Vm::describe_error`), never on a failure a
handler catches.

### 51. Fuzzer design/results

`audit/error-payloads/tools/fuzz.tcl` (its header has the whole design)
generates programs with three to five errors -- payload-free ones,
payloads of one to three fields from a typed pool (Int, String, Bool, an
enum, a struct, a nested struct, a List), always one *twin* with exactly
another error's fields, and in every other program an affine error whose
payload owns a coroutine -- and drives four to ten operations, each a
handled call reached directly, through one or two declaring functions,
through a generic `call(f, k, v)`, through a handled call that handles one
other error itself, or translated into another payload error by a handler.
Handlers ignore, bind whole (and project), destructure partially, rename
and destructure nested fields, in random order; each answers its error's
tag, so a handler run for the wrong identity shows. The independent model
(no code shared with the compiler or a runtime) is the pair (identity,
payload value) with selection by identity and destructuring by name. A
third of the programs carry one fault (missing payload, payload on a
payload-free error, missing/unknown/duplicate/ill-typed field, unknown or
non-struct destructured field, a stream used after it moved into a payload,
an unhandled error, the twin's handler instead of the raised error's) and
must report exactly the predicted diagnostic kind; the others must compile
clean and agree with the model on every backend, with every coroutine
released (Tcl: none alive; native: all released, none swept).

| campaign | programs | accepted | rejected as predicted | disagreements |
|---|---:|---:|---:|---:|
| `-n 200 -seed 1` (4 backends) | 200 | 148 | 52 | 0 |
| `-n 100 -seed 1001 -gc-stress 1` | 100 | 79 | 21 | 0 |

The rejections cover every predicted kind (DUPLICATE-FIELD 16,
UNHANDLED-ERROR 19, TYPE 13, UNKNOWN-FIELD 11, MISSING-FIELD 5,
MISSING-ERROR-PAYLOAD 4, UNEXPECTED-ERROR-PAYLOAD 3, NOT-A-STRUCT 2).

The first campaign run found one disagreement, a program the model rejects
(UNHANDLED-ERROR) and the compiler accepts: the pre-existing
completion-analysis hole of point 63 (an untyped callable parameter), which
the tree before the milestone shows with payload-free errors too. The
fuzzer's `unhandled` fault now avoids that path; nothing else disagreed.
The mutation run (point 52) also showed the fuzzer had no path through a
handled call that handles a different error; it has one now (`partial`).

The affine fuzzer (`audit/affine/tools/fuzz.tcl`) also exercises payloads
now: an affine value moved into a payload and handled ignored, whole,
destructured, or passed through a declaring function (point 54).

### 52. Mutation results

`audit/error-payloads/tools/mutate.tcl` applies each of the 24 mutants of
`audit/error-payloads/tools/mutants.txt` -- the brief's item-87 list, each
a deliberate bug -- to a private copy of the tree and runs the detectors:
`tests/error-payloads.test`, 25 fuzz programs (all backends), and for the
native-runtime mutant a rebuild plus the Rust payload-slot tests.

**24 mutants, 24 killed, 0 survived.**

| mutant | tests failed | fuzz programs disagreeing | Rust |
|---|---:|---:|---|
| `fail-ignores-payload-tcl` | 35 | 19/25 | |
| `fail-ignores-payload-native` | 37 | 19/25 | |
| `missing-payload-accepted` | 1 | 0/25 | |
| `payload-on-payload-free-accepted` | 1 | 1/25 | |
| `dispatch-by-shape-tcl` | 3 | 17/25 | |
| `same-shape-interchangeable-native` | 2 | 13/25 | |
| `whole-binding-loses-field-tcl` | 28 | 19/25 | |
| `whole-binding-loses-field-native` | 21 | 17/25 | |
| `partial-destructuring-drops-bound-affine-field` | 5 | 3/25 | |
| `partial-destructuring-leaks-unbound-affine-field` | 8 | 5/25 | |
| `nested-destructuring-handler-specific` | 7 | 12/25 | |
| `renaming-binds-original` | 9 | 19/25 | |
| `ignored-affine-payload-leaks` | 3 | 3/25 | |
| `handler-payload-not-owned` | 8 | 5/25 | |
| `propagation-drops-payload-tcl` | 1 | 0/25 | |
| `propagation-copies-affine-payload` | 1 | 0/25 | |
| `payload-construction-failure-leaks` | 1 | 0/25 | |
| `contract-loses-payload-metadata` | 2 | 0/25 | |
| `generic-propagation-loses-identity` | 1 | 7/25 | |
| `tcl-serializes-payload-through-string` | 36 | 19/25 | |
| `native-payload-free-allocates` | 1 | 0/25 | |
| `native-small-payload-boxes` | 2 | 0/25 | |
| `coroutine-cached-failure-duplicates-affine-payload` | 1 | 0/25 | |
| `propagation-drops-payload-native` | 2 | 0/25 | killed |

The brief's names map onto them: payload fields ignored during fail
construction (`fail-ignores-payload-*`), missing payload accepted, payload
on a payload-free error accepted, dispatch by shape instead of identity
(`dispatch-by-shape-tcl`, `same-shape-interchangeable-native`), whole
binding loses a field, partial destructuring drops a bound affine field or
leaks an unbound one, nested destructuring through handler-specific rules,
renaming binds the original, an ignored affine payload leaks, propagation
drops the payload (Tcl, and natively through a coroutine's cached failure)
or copies an affine payload, a construction failure leaks the earlier
affine field, a contract loses payload metadata, generic propagation loses
identity, the Tcl runtime serializes through a String, native payload-free
failure allocates, a native small payload is boxed, and a coroutine's cached
failure duplicates an affine payload.

The first full run left `generic-propagation-loses-identity` alive: no
test and no fuzz program sent an error *through* a handled call whose
handlers name a different error (the Tcl compiler's `return -options`
re-raise). `ep-propagation-through-handled-call` and the fuzzer's `partial`
path were added for it; the final run above is after them. The mutants
only the tests kill are a diagnostic whose fault the 25 programs did not
draw (`missing-payload-accepted`; the first run's fuzz, on other programs,
killed it) and properties the fuzzer does not observe by design: a
releasing re-raise past a pending affine argument, a failing payload field
after an affine one, a module boundary, the native allocation counters and
the coroutine contract.

### 53. Full regression

`tests/all.tcl` on both Tcl backends, against the commit before the
milestone (7332d5a, run the same way in its own tree):

| backend | before (7332d5a) | after |
|---|---|---|
| `CORE_BACKEND=interp` | 6882 passed, 0 failed | 6941 passed, 0 failed |
| `CORE_BACKEND=compile` | 6878 passed, 4 skipped, 0 failed | 6937 passed, 4 skipped, 0 failed |

The 59 new tests are `tests/error-payloads.test` as of that run (58) and
`sf-payload-rule`; the suite includes the warning gate
(`tests/warning-gate.test`, the corpus unchanged and warning-clean as
before) and `tests/direct-hir-native-path.test`. The three tests added
after that run (`ep-principal-bytes`, `ep-affine-exit-after-payload`,
`ep-propagation-through-handled-call`) pass on both backends with the rest
of `tests/error-payloads.test` (61) and `tests/same-failure.test` (100) on
the final tree. One existing test changed its expectation:
`sf-fail-carries-no-payload` pinned that a `fail` node has no value, which
is exactly what this milestone changes (a payload-free `fail` still has
none).

### 54. Affine regression

`tests/affine.test` passes (45, also under GC stress, point 60).
`audit/affine/tools/fuzz.tcl`, now with payload operations (an affine
value moved into an error payload, then the payload ignored, bound whole,
destructured or propagated): seeds 1-4 and 1001, 30 programs each, 0
disagreements (79-84 identities' releases checked per run).
`audit/affine/tools/mutate.tcl`: 29 mutants, 29 killed, every mutant still
applying (the milestone edits `hir/affine.tcl`'s consumers, flow and
scopes; no mutant text needed a change).

### 55. Coroutine regression

`tests/coroutines.test` passes (79, also under GC stress, point 60).
`audit/coroutines/tools/fuzz.tcl` seeds 1-3 and 1001, 50 programs each: 0
disagreements (13-14 returns, 21-24 fails, 5 calls, 15-18 breaks and 12-16
continues releasing coroutines on early exits per run).
`audit/coroutines/tools/mutate.tcl`: 52 mutants (11 native, each rebuilt),
52 killed, every mutant still applying. The coroutine-specific payload
behavior -- an affine payload in a coroutine's contract rejected
(COROUTINE-CONTRACT), a scalar payload cached with the failure and raised
again on every resume, its slots a GC root while cached -- is pinned by
`ep-coroutine-affine-payload-rejected`, `ep-coroutine-cached-payload`,
`ep-gc-stress-coroutine` and the Rust test
`error_payload_of_a_failed_coroutine_is_cached_and_raised_again`.

`audit/same-failure/tools/mutate.tcl` (SAME-FAILURE reads `fail` sites,
whose payload this milestone adds to the warning's identity rule): 14
mutants, 14 killed; `audit/same-failure/tools/fuzz.tcl 300 1`: 300 seeds,
0 failures, 0 extra warnings.

### 56. Refinement regression

`tests/refinement-values.test`, `tests/refinement-validators.test` and
`tests/emailish-predicate.test` pass in the full regression;
`audit/refinement-values/tools/fuzz.tcl -seed 1 -count 200` (validators on,
every backend): 200 programs, 133 accepted, 67 rejected, 0 failures.
`ep-validator` covers a validator whose error carries a payload: its
refinement proven on success, none on the error edge.

### 57. Struct-destructuring regression

Handler destructuring *is* struct destructuring (the same parser
`Pattern`, the same `Projections` lowering through a hygienic temporary,
the same diagnostics), so this regression is the milestone's main
compatibility check: `tests/struct-destructuring.test` passes (263, also
under GC stress); `audit/struct-destructuring/tools/fuzz.tcl` seeds 1, 2
and 1001: 100 programs each, 0 equivalence, negative-escape or backend
disagreements.

### 58. Enum regression

`tests/enums.test` passes (66, also under GC stress);
`audit/enums/tools/fuzz.tcl` seed 1 (40 programs) and seed 1001 with
`-gc-stress 1` (40 programs): 0 disagreements. Enum-typed payload fields
are covered by `ep-enum-and-list-fields` and the error-payload fuzzer's
`kind` field; `tests/mutable-vector.test` (53) and
`tests/mutable-array.test` (32) pass, also under GC stress, with
`ep-mutable-collection-fields` for mutable collections in a payload.

### 59. Native coverage

`tests/native-coverage.tcl -verbose` (the whole suite on Cranelift, every
test classified), on the commit before the milestone (7332d5a, with its own
native build) and on the final tree:

| class | before (7332d5a) | after |
|---|---:|---:|
| tests | 6882 | 6944 |
| native | 2754 | 2791 |
| independent | 3999 | 4024 |
| passed-partial | 69 | 69 |
| unsupported | 60 | 60 |
| failed | 0 | 0 |

The 62 new tests are 37 native and 25 independent (the frontend and HIR
diagnostics); every test both trees have keeps its class, and no construct
became unsupported. (The baseline's whole-suite run, made concurrently
with the final tree's, recorded no classification for the 41 executable
(AOT) tests of `argv.test`, `direct-hir-native.test`,
`native-executable.test`, `short-string.test` and
`string-allocation.test`; those files rerun alone in the baseline tree
under the same coverage log pass completely, and their 41 classes -- 29
native, 12 independent -- are the final tree's. The table counts them.)

`cargo test --release --manifest-path native/Cargo.toml`: 219 + 31 passed,
0 failed (before: 217 + 31); the two new ones are the payload-slot tests
(`error_payload_travels_in_the_payload_slots_and_is_cleared_by_the_handler`,
`error_payload_of_a_failed_coroutine_is_cached_and_raised_again`).

### 60. GC stress

`BOTLISH_NATIVE_GC_STRESS=1` (a collection attempt at every allocation
site) over the test files whose native code this milestone touches or
neighbors:

| test file | tests | failed |
|---|---:|---:|
| `error-payloads.test` | 61 | 0 |
| `errors.test` | 40 | 0 |
| `affine.test` | 45 | 0 |
| `coroutines.test` | 79 | 0 |
| `struct-destructuring.test` | 263 | 0 |
| `enums.test` | 66 | 0 |
| `mutable-vector.test` | 53 | 0 |
| `mutable-array.test` | 32 | 0 |

The error-payload fuzzer's second campaign runs every accepted program
natively again under GC stress (100 programs, 0 disagreements), and
`ep-gc-stress`/`ep-gc-stress-coroutine` force collections while payload
fields (Strings, nested structs, a cached coroutine failure) sit only in the
Vm's payload slots. The whole suite under GC stress is the `gc-stress` CI
job on `main`.

### 61. Scalar audit

`native/generate-scalar-audit.tcl -outdir DIR` regenerated the committed
corpus (13 programs: the canonical benchmarks and `examples/stdlib`) on the
final tree: every `.asm` and summary file is byte-identical to
`audit/native-scalar-asm/` (only the README's commit id and the sandbox's
rustc version line differ). No corpus program uses a payload, and the
payload-free path emits the same code (point 27).

### 62. Performance

`bench/error-payloads.tcl -runs 15` on the final tree (best of 15
in-process runs, compilation excluded; N = 2000 operations per program on
the Tcl backends, 200000 natively). Each cell is the time per operation
over its baseline program, the whole program per operation in parentheses.
The deltas of the Tcl backends are noisy -- a few hundred ns between runs,
the interpreter's tens of microseconds -- so read the whole-program numbers
and the native column.

| operation | baseline | Tcl interp | Tcl compile | Cranelift |
|---|---|---:|---:|---:|
| payload-free: declaring call, success | ok-plain-base | 64606.0 ns (177460.5 ns) | 887.5 ns (2478.5 ns) | -7.4 ns (30.7 ns) |
| payload-free: failure, handled by the caller | base | 135318.5 ns (218156.0 ns) | 1468.0 ns (2909.0 ns) | 52.2 ns (82.4 ns) |
| payload-free: failure propagated across 5 calls | base | 282313.5 ns (363635.5 ns) | 3773.0 ns (5204.5 ns) | 55.2 ns (85.4 ns) |
| payload-bearing: declaring call, success | ok-plain-base | 55638.5 ns (169684.5 ns) | 578.5 ns (2811.0 ns) | 0.2 ns (38.6 ns) |
| one-Int payload: failure, destructured | rich-base | 132767.0 ns (216575.5 ns) | 5487.0 ns (7610.5 ns) | 57.1 ns (87.3 ns) |
| one-Int payload: failure, payload ignored | rich-base | 140624.0 ns (224715.0 ns) | 2959.5 ns (4666.5 ns) | 29.8 ns (68.4 ns) |
| 3 scalar fields: failure, 2 destructured | rich-base | 316916.0 ns (401299.0 ns) | 8980.0 ns (11109.5 ns) | 32.0 ns (70.8 ns) |
| 3 scalar fields: whole binding, projected | rich-base | 212088.5 ns (300886.0 ns) | 7344.0 ns (9528.5 ns) | 49.8 ns (88.1 ns) |
| 3 scalar fields: whole binding used as a value | rich-base | 280059.5 ns (377414.0 ns) | 9866.5 ns (11599.5 ns) | 156.8 ns (189.1 ns) |
| 3 scalar fields: partial destructuring (1 field) | rich-base | 221730.5 ns (328611.0 ns) | 9599.0 ns (11769.5 ns) | 33.5 ns (72.2 ns) |
| String field (a constant) | rich-base | 157223.0 ns (240955.5 ns) | 7649.5 ns (9827.0 ns) | 58.5 ns (88.6 ns) |
| String field (built per failure) | rich-base | 178537.0 ns (266567.5 ns) | 13923.0 ns (16082.5 ns) | 85.0 ns (123.1 ns) |
| nested struct field, nested destructuring | rich-base | 215227.0 ns (323061.5 ns) | 11226.5 ns (12977.5 ns) | 107.9 ns (146.2 ns) |
| one-Int payload: failure propagated across 5 calls | rich-base | 347672.0 ns (430242.0 ns) | 6419.0 ns (8959.0 ns) | 54.0 ns (93.0 ns) |

Native heap allocations of each whole program (N = 200000; the 3 of every
program are the collecting loop's List):

| program | allocations | Structs | Strings | bytes |
|---|---:|---:|---:|---:|
| every payload-free program, and `ok-small`, `fail-small`, `fail-small-ignored`, `fail-scalars`, `fail-whole-projected`, `fail-partial`, `fail-text`, `fail-small-5` | 3 | 0 | 0 | 1600120 |
| `fail-whole-value` (`d = [details]`) | 400003 | 200000 | 0 | 19200120 |
| `fail-built` (`str::concat` per failure) | 200003 | 0 | 200000 | 7400120 |
| `fail-nested` (`box: Box {n: x}` per failure) | 200003 | 200000 | 0 | 9600120 |

Natively a scalar payload fails, travels and is destructured, ignored,
projected through a whole binding or partially destructured with **zero
allocations**, at the cost of a payload-free failure within the noise
(about 70-90 ns per handled failure in this loop either way; propagating
across five declaring functions adds nothing measurable). Only what a
field is allocates (a String built per failure, a nested struct), and a
whole binding used as a value builds its one struct at the handler
(`fail-whole-value`'s other 200000 are the program's own one-element
Lists). The success path of a payload-bearing declaring call is the
payload-free one (38.6 ns vs 30.7-39.8 ns per whole operation across
runs). On the Tcl backends -- the reference implementations -- a payload
costs its struct construction (`core::runtime::structNew`), the `errorId`
call and the handler's projection: a one-Int failure handled by the
Tcl compiler is about 7.6 us per operation against 2.9 us payload-free.

**Payload-free code before and after.** The generated code is identical
(the Tcl compiler's output for a payload-free failure is byte-identical to
the tree before the milestone, the native code is point 27's, and the
scalar audit's machine code is byte-identical, point 61). Timed in
alternation, each tree three times (`bench/error-payloads.tcl`'s programs,
best of 15, whole program per operation):

| program | backend | before (7332d5a) | after |
|---|---|---|---|
| failure handled by the caller | Tcl compile | 2874.5, 2894.0, 2846.5 ns | 3316.5, 2907.0, 2822.5 ns |
| failure handled by the caller | Cranelift | 69.6, 66.6, 88.0 ns | 71.4, 83.4, 78.6 ns |
| declaring call, success | Tcl compile | 3048.0, 3023.5, 2307.0 ns | 3028.5, 3031.0, 2352.5 ns |
| declaring call, success | Cranelift | 39.8, 38.9, 38.5 ns | 38.7, 38.6, 38.5 ns |
| failure propagated across 5 calls | Tcl compile | 4120.5, 3190.5, 3901.0 ns | 4074.0, 4003.5, 4080.0 ns |
| failure propagated across 5 calls | Cranelift | 75.5, 89.9, 87.7 ns | 70.0, 72.7, 75.1 ns |

No difference beyond the run-to-run spread. (A first, noisier single run
of the whole report showed the payload-bearing success path 1 us slower on
the Tcl compiler; its generated code is the payload-free one's, and timed
directly the two differ by 100-160 ns, inside the spread.)

### 63. Compatibility findings

Every error declaration of the shipped corpus stays payload-free and
unchanged: `lib/io.bot` `WriteFailed`; `lib/byte.bot` `BelowRange`,
`AboveRange`; `lib/list.bot` `NotFound`; `lib/abi.bot`
`AbiIntegerBelowRange`, `AbiIntegerAboveRange`; `lib/abi/x86_64.bot`
`Register64BelowRange`, `Register64AboveRange`; `lib/io/path.bot`
`NotAPath`; and the runtime's builtin `InvalidArgumentEncoding`,
`IndexNotFound`, `LowerUnderrun`, `UpperOverrun`. None was converted (the
acceptance cases are the tests' own declarations); no API behavior and no
existing diagnostic changed. Findings:

* **Cross-module identity (item 59).** Error names are program-global
  (EXPLICIT-ERROR-COMPLETIONS.md, "Flat, program-global error namespace"):
  `http::PageNotFound` and `cache::PageNotFound` cannot both be declared; the
  second declaration is rejected ("error "PageNotFound" is already declared
  ..."). Nominal distinctness therefore holds by rejection, never by merging:
  no two declarations ever share an identity, with or without payloads
  (`ep-cross-module`). Module-qualified error names are a separate change of
  the error namespace, not made here. A module's payload field types are
  qualified like its struct fields (`eppage::Meta`).
* **Module initializers.** A module binding whose initializer reaches a
  payload-bearing `fail` stays retainable and context-free (the payload's
  fields are checked like any evaluated expression); reading payload fields
  in a module initializer is a projection, which module initializers do not
  support for any struct value yet (`MODULE-CONTEXT`, `ep-module-
  initializer`).
* **The brief's principal program** needed the two existing-rule adjustments
  of "The principal program" above.
* **A pre-existing hole the fuzzer found: errors through an untyped callable
  parameter.** A call through a parameter with no function type (`fn
  call(f, k, v): f(k, v)`) contributes no errors to the completion
  analysis's effective set (`hir/completions.tcl`'s `EvalCall` returns an
  unknown range and merges nothing when the callee type is neither `Fn` nor
  `Coroutine`). An exact callee analyzed under its arguments' facts
  (`generic(k, v) -> int errors E1, E2: call(raise, k, v)`) therefore
  reports no effective error, and a handled call of it that omits a handler
  for `E1` is accepted instead of diagnosed UNHANDLED-ERROR; at run time the
  error escapes as `uncaught propagated error: <error E1>`. The tree before
  this milestone behaves identically with payload-free errors (the same
  program, checked on both trees), so it is not a payload property and is
  not changed here: identity dispatch still holds (no handler ever runs for
  an error it does not name), only the static coverage check is incomplete.
  The fix belongs to the completion analysis (fall back to the declared
  contract once a body calls an untyped callable, as `EffectiveFacts` does
  when its precision runs out). The fuzzer's `unhandled` fault avoids the
  `generic` path until then.

### 64. Future "CompileError" audit

```botlish
enum DiagnosticCode:
    Type,
    Unbound,
    UseAfterMove,

struct SourceLocation:
    line: int
    column: int

error CompileError:
    code: DiagnosticCode
    primary: SourceLocation
    related: List[SourceLocation]
    message: str
```

is an ordinary payload error today, and `assert_compiles(n)` handling it with
`on CompileError {code, primary}:` and an `if code == DiagnosticCode::Unbound`
runs on every backend (`ep-compile-error-shape`). No new error mechanism is
needed; `compiler::assert_compiles` itself is not implemented.

### 65. Limitations before `compiler::assert_compiles`

* Error names stay program-global (point 63): a `compiler` module declaring
  `CompileError` reserves the name for every program that loads it.
* A payload type cannot be spelled in a source annotation (the anonymous
  struct rule): a helper that takes a whole payload is untyped (specialized)
  or takes the fields it needs.
* Module initializers cannot read payload fields (no struct values in module
  initializers yet).
* A coroutine cannot fail with an affine payload (point 47).
* There is no automatic cause chain and no `with`/`without` struct update:
  translating an error means constructing the new payload from the fields
  received (`ep-translate`).
* Diagnostics as data: `assert_compiles` would need the compiler's
  diagnostics as Botlish values (`DiagnosticCode`, `SourceLocation` values)
  -- a host-to-Botlish bridge this milestone does not add.

## Native evidence

The NIR (`native::lowered`) of each form, the body of the named function
only, source positions dropped. The program declares `error Lost`,
`error Small: code: int`, `error Nested: code: int, box: Box` and
`error ReadFailed: stream: Coroutine{args: [Message], return: Event},
bytesRead: int`, and each function fails when its argument is negative.

A failure: the payload's fields in slot order after the shape index, no
object built for transport. A field that is itself a struct (`box`) is that
struct, built as any struct literal is.

```
plain:   faildeclared 1 "Lost"
small:   faildeclared 2 "Small" 1 %0
nested:  %1 = structnew 2 %0
         faildeclared 3 "Nested" 0 %1 %0
read:    %1 = call 2 %0                      # s = make(n)
         faildeclared 4 "ReadFailed" 3 %0 %1
```

Propagation (`mid(x) -> int errors Small: small(x) + 1`) is the
payload-free code: a call, an add, a return. Nothing reads or copies the
slots on the way out.

Handlers: the payload-free one (`on Lost: -1`) and one ignoring a scalar
payload (`on Small: -1`) are the same code, identity test and clear, with
nothing read from the slots. A handler
reads exactly the fields its binding needs, before the clear:

```
on Nested details: return [details]      on Nested {box: {n}}: n
  %3 = declarederroreq 3                   %3 = declarederroreq 3
  br %3 L2 L3                              br %3 L2 L3
label L2                                 label L2
  %4 = declaredpayload 0                   %4 = declaredpayload 0     # box
  %5 = declaredpayload 1                   cleardeclarederror
  cleardeclarederror                       %5 = structget 0 %4        # box.n
  %6 = structnew 0 %4 %5   # used whole    %1 = move %5
  %7 = op listnew %6
```

An affine payload: the ignored handler reads only the affine field and
releases it; the partial one reads the field it binds and releases the
field it leaves unbound:

```
on ReadFailed: -1                        on ReadFailed {bytesRead}: bytesRead
  %4 = declaredpayload 1   # stream        %4 = declaredpayload 0     # bytesRead
  cleardeclarederror                       %5 = declaredpayload 1     # stream
  ...                                      cleardeclarederror
  %11 = op corelease %4                    %6 = op corelease %5
  %1 = move %10                            %1 = move %4
```

Running the program's seven handlers on a failing argument natively:
11 allocations, 5 of them structs (the two failures' nested `Box`es, the
whole binding's one materialization and the two coroutines' first yielded
`Event`s); 2 coroutines created, both released while suspended (one by the
ignoring handler, one by the partial one), none swept. The native NIR is
generated with `-specialize 0` so each function appears once.

## Payload-bearing enums are not this

Error payloads did not become a second tagged-union implementation. An
error is a control-flow identity: it is never a value, it cannot be stored,
passed, compared or returned, and only `on` selects on it; its payload is
an ordinary anonymous struct value after selection. A future
payload-bearing enum case is an ordinary value of a sum type. They may
share the product and destructuring machinery (the payload is a struct and
is destructured by the struct rules), not the control-flow semantics: no
error identity is an enum case, no enum case is raised, and `on` will never
select an enum case.

## Files

| file | what |
|---|---|
| `surface/parser.tcl`, `surface/ast.tcl` | the declaration, `fail` payload and handler receive grammar; guards/patterns rejected |
| `surface/lower.tcl` | `ErrorDeclOf` (fields, namespace), the payload construction, `Handlers` (payload binding, destructuring expansion) |
| `hir/errordecls.tcl` | error descriptors, `payloadType`, `resolvePayloads`, HIR entries |
| `hir/syntax.tcl`, `hir/hir.tcl` | `fail` value, handler payloads, `fromIR`, `hir::children` |
| `hir/resolve.tcl` | payload checks (`MISSING-/UNEXPECTED-ERROR-PAYLOAD`, `payloadOf` construction), handler payload bindings |
| `hir/types.tcl`, `hir/range.tcl` | payload typing, `VerifyPayload` |
| `hir/affine.tcl`, `hir/coroutines.tcl` | payload moves, handler ownership, the coroutine rule |
| `hir/format.tcl`, `hir/read.tcl` | HIR text |
| `hir/lower.tcl`, `core/ir.tcl`, `core/value.tcl`, `core/evaluator.tcl`, `compiler/compiler.tcl` | Core IR and the Tcl backends |
| `hir/warnings.tcl` | `SAME-FAILURE`'s payload rule |
| `hir/{completions,callables,signatures,construction,modulebinding,traits}.tcl`, `native/{rawabi,shortstring}.tcl` | walkers that now visit a payload |
| `native/lower.tcl` | `PayloadFields`, `PayloadNeeded`, the handler's virtual payload |
| `native/src/{nir.rs,codegen/clif.rs,codegen/roots.rs}`, `native/src/runtime/{vm,ops,coroutine,show,aot}.rs`, `native/src/main.rs` | NIR, code generation, payload slots, rendering |
| `tests/error-payloads.test` | the milestone's tests |
| `audit/error-payloads/tools/fuzz.tcl` | the fuzzer and its independent model |
| `audit/error-payloads/tools/mutate.tcl`, `mutants.txt` | mutation testing |
| `bench/error-payloads.tcl` | the performance report |

## What to run when changing this

If you change the error declaration or payload grammar, `hir/errordecls.tcl`,
the `fail`/`handle` resolution, typing, affine flow or lowering in any
backend, `errorId`, the native payload slots or `hir::warnings::FailSites`:
`tests/error-payloads.test`, `tests/errors.test`, `tests/same-failure.test`,
`tests/affine.test`, `tests/coroutines.test`,
`audit/error-payloads/tools/fuzz.tcl` (several seeds, once with `-gc-stress
1`), `audit/error-payloads/tools/mutate.tcl` (every mutant must still apply
and be killed; update a mutant's text when you change the code it mutates,
keeping it a mutant of the same rule), `audit/same-failure/tools/mutate.tcl`
and `cargo test --release --manifest-path native/Cargo.toml --lib
error_payload`. `bench/error-payloads.tcl` regenerates point 62.
