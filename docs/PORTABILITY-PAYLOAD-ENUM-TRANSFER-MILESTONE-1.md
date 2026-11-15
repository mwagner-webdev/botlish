# PORTABILITY-PAYLOAD-ENUM-TRANSFER-MILESTONE-1.md

Sendable payload-bearing enums across independent Botlish VMs.

> An enum is sendable when every possible case carries only data that can
> be reconstructed independently in another compatible Botlish VM.
> Transfer preserves the value's meaning, not its representation, object
> identity, allocation history or runtime environment.

```botlish
import std::transfer
import std::abi::bytes

enum Request:
    Stop,
    Calculate {requestId: int, x: int, y: int},
    Store {key: str, value: List[int]},

data = std::transfer::encode([Request::Calculate {requestId: 1, x: 6, y: 7}, Request::Stop])
copy = std::transfer::decode[List[Request]](data):      # this VM's own values
    on TransferMalformed:
        ...
    # (and TransferVersion, TransferTypeMismatch, TransferInvalidValue,
    # TransferLimit)
```

This milestone extends the existing `Sendable` judgement and the existing
value-transfer codecs (SENDABILITY-AND-VALUE-COPY-MILESTONE-1.md) to
payload-bearing enums (PORTABILITY-PAYLOAD-ENUMS-MILESTONE-1.md), whose
values a receiver matches exhaustively
(PORTABILITY-EXHAUSTIVE-MATCH-MILESTONE-1.md). It adds no serializer, no
transport and no syntax: a new schema node, both codecs' handling of it,
the native plan's validation of it, and the structural rule.

Claims are labelled: **[inspection]** (implementation inspection),
**[observed]** (observed execution in this container), **[CI]** (CI
evidence), **[projection]**.

## Contents

1. Starting architecture and the prior restriction
2. The structural Sendable rule
3. Recursive types and declaration summaries
4. The schema extension
5. Version and fingerprint compatibility
6. The wire format, with annotated bytes
7. The Tcl codec
8. The native plan, encoder and decoder
9. GC rooting and independent values
10. Errors and refusals
11. Cross-program and cross-backend identity
12. Independent VMs and the remote-actor acceptance
13. Static trait and generic integration
14. The independent oracle and the fuzzer
15. Mutation testing
16. Fixed vectors and compatibility checks
17. Performance and allocations
18. Regression and CI
19. Unsupported transfers
20. Remaining limitations
21. Files, and what to run when changing this

---

## 1. Starting architecture and the prior restriction

**[inspection]** Before this milestone:

* `hir::types::SendClass` (hir/types.tcl) refused every enum with a
  payload-bearing case outright:

  ```
  if {[IsEnum $type] && [hir::enums::hasPayloads [lindex $type 1]]} {
      return [list none "[show $type] has payload-bearing cases, and a
          payload-bearing enum case has no transfer encoding yet (only an
          enum whose every case is payload-free is sendable)"]
  }
  ```

  so `std::transfer`, thread entries and `std::actor::remote` all refused
  such an enum (NOT-SENDABLE, THREAD-ENTRY-SIGNATURE, TRAIT-NOT-SATISFIED).
* `hir::transfer::Schema` (hir/transfer.tcl) gave an enum the node
  `enum ID CASES` -- its nominal identity and its case names, sorted -- and
  the two codecs (core/transfer.tcl, native/src/runtime/transfer.rs) wrote a
  value as one varuint: its case's index among those names. Nothing could
  carry a payload.
* Natively a payload-free case is an immediate word, a payload-bearing one
  an `EnumCaseObj` (KIND_ENUMCASE) holding the program's enum and case
  numbers and an anonymous struct payload; on the Tcl backends a value is
  `{enum ID CASE}` or `{enum ID CASE PAYLOAD}`.

## 2. The structural Sendable rule

**[inspection]** `SendClass` now judges a payload-bearing enum by the
payload fields of every declared case (hir/types.tcl):

```
if {[IsEnum $type] && [hir::enums::hasPayloads [lindex $type 1]]} {
    if {$type in $seen} {
        return {total ""}
    }
    return [SendComponents [hir::enums::payloadParts [lindex $type 1]] $assumed [concat $seen [list $type]]]
}
```

* `Sendable(E)` holds iff every field of every case is sendable. A
  payload-free case contributes nothing; the case one value holds decides
  nothing (`pet-class-any-case`: one non-sendable case first, last or in
  the middle refuses the enum).
* The three classes are kept: `total`, `none` (a component no value of
  which is sendable: a function, a coroutine handle, a C pointer, a context
  struct, an opaque struct without a statement), `unknown` (`any`).
* The reason names the enum, the case and the field, in the format the
  existing component analyses use (Totality's), with the path through
  enclosing Lists, structs and enums -- observed **[observed]**:

  ```
  the argument of std::transfer::encode is not sendable: Request cannot be reconstructed in another VM
  field "work" of case Request::Execute (Fn{args: [], return: int, errors: []}): a function or closure is code of this program and the environment it captured: neither is a value another VM can rebuild
  ```

  and through a struct and a nested enum:

  ```
  field "e" of S (E): field "f" of case E::B (Fn{args: [], return: int, errors: []}): ...
  field "inner" of case Wrapper::Holds (Inner): field "f" of case Inner::Bad (Fn{...}): ...
  ```

* A payload-free enum stays `total` by its own branch, as before.
* Every existing non-sendable type stays non-sendable when an enum's
  payload holds it: `pet-class-function`, `-coroutine`, `-context`,
  `-pointer`, `-opaque`, `-nested-collection`, `-nested-enum`,
  `-recursive-leaf`, `-recursive-deep-leaf`, `-unknown` pin each class and
  reason **[observed]**. A payload is not made sendable by being an
  anonymous struct: `SendComponents` walks its fields.

The diagnostics are the existing ones: NOT-SENDABLE at a transfer,
TRAIT-NOT-SATISFIED at a Sendable view or a constrained slot,
THREAD-ENTRY-SIGNATURE at a thread entry. No enum-specific diagnostic was
added; the blanket message is gone (no test or document pinned it but
`pe-c-and-boundaries`, updated: a function-valued payload is still
NOT-SENDABLE, a sendable payload enum is accepted).

## 3. Recursive types and declaration summaries

**[inspection]** Enums are not parameterized, so their judgement needs no
declaration summary of its own: the walk follows Totality's enum case.
`SEEN` holds the enums being walked, and an enum met again inside itself
adds nothing, as a struct met again does. A finite recursive enum is
therefore sendable exactly when its other components are:

* `enum Tree: Leaf {value: int}, Branch {children: List[Tree]}` -- total;
* `enum Expr: Lit {value: int}, Neg {e: Expr}, Add {left: Expr, right: Expr}`
  (direct recursion, no List) -- total;
* `enum Node: Leaf {run: Fn{...}}, Branch {kids: List[Node]}` -- none, the
  reason the leaf's field.

A struct reached through an enum's payload is judged by its declaration
summary (`SendStructClass`, hir/summaries.tcl's fixpoint), whose node walks
the enum afresh with the struct in `SEEN`: mutual recursion terminates and
is order-independent. `pet-class-order` asks a mutually recursive struct
and enum in both orders, declared in both orders, with the summaries
forgotten before each question (`hir::structs::ForgetAffinity`), sendable
and not: the classes are equal in all eight runs **[observed]**. No depth
cutoff decides a class: the recursion stops at `SEEN`, never at a count.

Summaries are forgotten when an enum's payloads change (hir/enums.tcl
calls `ForgetAffinity` in `resolvePayloads` and `setPayload`), so a struct
summary that read an enum's payload is never stale **[inspection]**.

## 4. The schema extension

**[inspection]** hir/transfer.tcl gives a payload-bearing enum a node of
its own; a payload-free enum keeps its old node:

```
enum ID CASES          every case payload-free (unchanged)
penum ID PAYLOADS      some case payload-bearing: PAYLOADS {CASE NODE} per
                       declared case, sorted by name, NODE the node of the
                       case's payload -- an anonymous struct of its fields,
                       sorted -- or "" for a payload-free case
```

and its text line names every case with its payload's node, `-` for a
payload-free one. For

```botlish
enum Message:
    Ping,
    Text {body: str},
    Number {value: int},
    Batch {items: List[int]},
```

the text is (`pet-schema-Message`) **[observed]**:

```
botlish-transfer 1
0 penum Message {Batch 1 Number 4 Ping - Text 5}
1 struct {} {items 2}
2 list 3
3 int
4 struct {} {value 3}
5 struct {} {body 6}
6 str
```

* The schema is the whole declaration, never one value's case: every case
  is in it, payload-free ones too.
* Canonical: cases sorted, each payload's fields sorted
  (`hir::enums::payloadType`), nodes numbered in the order a walk in that
  order meets them; a payload type met twice (two cases with the same
  fields) is one node. Declaration order, field order, construction order,
  unrelated declarations and native numbers take no part.
* Nominal: the enum's module-qualified identity is in the line
  (`penum std::geom::Cmd {Move 1 Stop -}`).
* Finite for recursive types: a node is keyed by its type and indexed
  before its children are made, so an enum reached again through its own
  payload refers back to its node (`2 list 0` in Tree's schema;
  `1 struct {} {left 0 right 0}` in Expr's; `pet-schema-recursive-finite`
  from either root of a struct-and-enum cycle).

### A canonical fingerprint

Testing payload enums in natural use -- `encode([Tree::Leaf {...}, ...])`,
a List literal -- found a defect older than this milestone **[observed]**:
the schema's nodes were keyed by the static type, a List literal's static
type is length-refined (`List[Tree]{length: 2}`), and the text drops the
length but not its effect on the graph. The root `List[Tree]{length: 2}`
and the payload's `List[Tree]` became two nodes where the receiver's
`List[Tree]` is one, so the texts and fingerprints differed and the
receiver refused its own sender's bytes (TransferTypeMismatch). It hit
structs on main too: at origin/main (c5b22364), decoding
`std::transfer::encode([Node {name: "a", kids: []}])` of a `tree struct
Node` as `List[Node]` is TransferTypeMismatch, while the same value passed
through a `List[Node]` parameter first decodes **[observed]**.

The fix keeps the nodes the codecs read (every refinement the receiver
checks, kept) and computes the text and fingerprint from a second walk
over the type's *intent* (`hir::transfer::Intent`: List length
refinements and positional shapes erased in every part). A type with
neither has the same graph both ways, so its text is the one it always
had (section 5); integer domains are left alone, as they always were (a
declaration's, the same on both sides).

## 5. Version and fingerprint compatibility

Decisions **[inspection]**, each checked **[observed]**:

* **No version bump.** `BOTX` version 1 is kept. `penum` is a node of the
  schema, never of the bytes: the bytes hold a fingerprint and values.
  Only types that were refused before have a `penum` node, so no old
  sender produced such bytes, and an old receiver given them finds a
  fingerprint no type of its own has (TransferTypeMismatch) -- never a
  misreading.
* **Payload-free enums unchanged**: same node, same text, same
  fingerprint, same bytes. Pinned from the revision before the milestone
  (`pet-schema-payload-free-unchanged`: Color `81952409bbdce335`,
  `List[Color]` `ee91bd573f69614d`, a struct holding Color
  `e56e5cf49fe2da4a`), and every value-transfer fixed vector unchanged.
* **Every other existing type unchanged** unless it has a List length
  refinement or positional shape that the old graph kept apart. Of twenty
  representative types (scalars, structs, trees, applications, opaque
  statements, every collection, integer domains mixed with Ints) compared
  between origin/main and this branch, eighteen keep their fingerprints;
  the two that change are `List[Node]{length: 2}` -- now the fingerprint
  of `List[Node]`, the receiver's -- and a struct declaring
  `a: List[int]{length: 2}` beside `b: List[int]` -- now that of the same
  struct without the length, which the format always meant to check
  rather than compare. `pet-fingerprint-compatible` pins nine of the
  eighteen.
* **The transfer format remains a runtime interchange format**: no
  persistent storage promise and no schema evolution. A receiver whose
  declaration differs refuses the bytes.

The fingerprint distinguishes every incompatible change and nothing else
(`pet-fingerprint-changes-*`, `pet-fingerprint-stable`) **[observed]**:

| Change | Fingerprint |
|---|---|
| a payload field added, removed, renamed, its type changed | changes (and of an enum holding it) |
| a case added, removed, renamed; a payload added to a case or moved to another | changes |
| a List element type changed inside a payload | changes |
| the nominal identity (another module, another name with the same cases) | changes |
| a nested opaque representation, or its owner functions | changes |
| cases reordered, payload fields reordered, fields initialized in another order | same |
| unrelated declarations before it, module import order | same |
| an integer domain (`x: std::byte::Byte` for `x: int`) | same: checked by the receiver |
| a literal's List length | same: checked by the receiver |

## 6. The wire format, with annotated bytes

A payload-bearing enum's value **[inspection]** (core/transfer.tcl's
header):

1. a varuint: the case's index among the sorted case names;
2. if that case declares a payload, the payload: its fields in sorted
   order, each by its own node; a payload-free case writes nothing more.

Each fixed vector below is written out by hand from the format in
`tests/payload-enum-transfer.test` (`pet-vector-*`), derived again by the
independent oracle (`oracle.py selftest`), and checked on all four
backends **[observed]**; the header is `42 4f 54 58 01` and the type's
fingerprint, little-endian.

| Value | Bytes after the header | Reading |
|---|---|---|
| `Color::Green` (payload-free enum, fp `81952409bbdce335`) | `01` | index of Green in {Blue, Green, Red} |
| `Message::Ping` (fp `627b87415786bd05`) | `02` | index of Ping in {Batch, Number, Ping, Text}; no payload |
| `Message::Number {value: 300}` | `01 02 2c 01` | Number; value: 2 bytes, 300 = 0x012c |
| `Shape::Rect {w: 3, h: -1, label: "é", filled: true}` (fp `dc9e61e6ea435f1a`) | `01 01 01 ff 02 c3 a9 01 03` | Rect; filled 1; h: 1 byte, -1; label: 2 bytes of UTF-8; w: 1 byte, 3 |
| the same, fields written `label, filled, h, w` | `01 01 01 ff 02 c3 a9 01 03` | the same bytes |
| `Outer::Wrap {inner: Message::Text {body: "x"}}` (fp `ee4c21aa86f3ed94`) | `01 03 01 78` | Wrap; inner: Text; body: 1 byte "x" |
| `Message::Batch {items: [1, 300]}` | `00 02 01 01 02 2c 01` | Batch; items: count 2, 1, 300 |
| `Tree::Branch {children: [Leaf {value: 1}, Branch {children: []}]}` (fp `35f0957bd1ce64a5`) | `00 02 01 01 01 00 00` | Branch; 2 children: Leaf, value 1; Branch, 0 children |
| `Expr::Neg {e: Add {left: Lit {value: 2}, right: Lit {value: -2}}}` (fp `3ecf4892df3b00a2`) | `02 00 01 01 02 01 01 fe` | Neg; Add; Lit 2; Lit -2 |
| `std::geom::Cmd::Move {dx: 2}` (fp `14d2be2202c90e71`) | `00 01 02` | Move in {Move, Stop}; dx 2 |
| `Labeled::Named {name: name_of("hi")}` (fp `b541982001838983`) | `01 02 68 69` | Named; name: its owner's representation, the String "hi" |

## 7. The Tcl codec

**[inspection]** core/transfer.tcl:

* **Encoding** (`penum`): the value must be `{enum ID CASE ...}` of the
  node's ID and a declared case; the case's schema decides whether a
  payload is written -- never the value's form, and a value that does not
  hold what its case declares is an internal error, never a silent drop.
  The payload is pushed onto the iterative walk's stack with its child
  node; the source value is read, never changed (logical value copies of a
  nested MutableVector are the existing `vector` node's).
* **Decoding**: the case index is read and checked; a payload-free case
  makes `core::value::enumValue`, a payload-bearing one schedules its
  payload's decode and a `wrap` instruction, which makes
  `core::value::enumCaseValue` around the decoded payload -- the existing
  constructors, so a decoded value is observationally a constructed one
  (`pet-match-decoded`, `pet-hash-equal`).
* **Minimum sizes** (`MinSizes`): now an upward fixpoint (section 10).

## 8. The native plan, encoder and decoder

**[inspection]** native/lower.tcl's `TransferPlan` resolves `penum` to

```
penum ENUM N {CASE CHILD}*N    ENUM this program's enum number, N the
                               declared case count, CASE the declaration
                               position of the I-th sorted name, CHILD the
                               payload's node or -1
```

after checking the schema against this program's declaration: the schema
names exactly the declared cases; each payload is present exactly when the
case declares one; each payload node is an anonymous struct of exactly the
case's declared fields. A schema that fails is NATIVE INVALID-HIR before
any plan exists (`pet-plan-validated` forges four: a payload omitted, a
payload of another case, a case renamed, a case missing). Program-local
enum and shape numbers appear in the plan only, never in the bytes or the
fingerprint.

native/src/runtime/transfer.rs:

* **Plan reading**: `Node::PEnum { number, cases, index_of, payloads }`; the
  case count must equal the program's, every case once, every payload node
  in range and -- checked once all nodes are read -- a `Struct` node
  (`transfer_payload_enum_plans_are_checked`).
* **Encoding**: accepts both representations, an immediate word or an
  `EnumCaseObj`, by `enum_case_parts` (identity only: no equality, no
  hash, no address); writes the sorted index; a payload-bearing case pushes
  its `EnumCaseObj`'s payload onto the iterative walk (`temp_roots`). An
  immediate word for a payload-bearing case, or the reverse, is a compiler
  bug (`Stop::Bug`), never a silent drop.
* **Decoding**: a payload-free case is its immediate word (`make_enum`), a
  payload-bearing one decodes its payload struct and then
  `Work::Wrap(number, case)` allocates the `EnumCaseObj` with this VM's
  `new_enum_case` (section 9). The walk stays iterative: a 100 000-deep
  recursive enum value decodes with no host recursion
  (`transfer_recursive_payload_enums`) **[observed]**.

## 9. GC rooting and independent values

**[inspection]** Encoding allocates nothing until its result; the payload
of every pending value sits on `temp_roots`. Decoding keeps every value it
made and has not yet put into its container on `temp_roots`; `Wrap` reads
the payload in place, allocates the case object (a collection may run:
the payload is still rooted), then writes the object into the payload's
place. The mutant that pops the payload first (`native-payload-unrooted`)
is killed by the stressed Rust tests (every allocation collects, freed
objects poisoned) and by `pet-gc-stress` (section 15).

A decoded value belongs to the receiving VM alone **[observed]**:

* Rust: values encoded by one `Vm`, the `Vm` dropped (every object freed
  and poisoned), decoded by a second `Vm` of another program numbering
  every shape and enum otherwise and declaring the cases in another order
  (`transfer_payload_enums_between_independent_vms`); two decodes are two
  objects; re-encoding in the receiver's numbering gives the sender's
  bytes.
* Separate processes: a sender process on each backend writes the bytes
  and exits, a receiver process on another backend decodes and matches
  them (`pet-process-*`, six pairs).
* Mutable payloads: a payload's MutableVector mutated by the sender after
  encoding is not in the bytes; a decoded copy mutated in place changes
  neither the source nor another decode of the same bytes; a later
  encoding of another value changes nothing of a decode
  (`pet-mutable-independent`); a received vector in a remote message is
  the receiving VM's own (`update 24 4` then `update 34 5` in
  `pet-remote-messages`: the first copy's push of 99 is not in the
  second).
* Maps, sets and an ImmutableSet of Hashable payload enums are rebuilt
  with the receiver's own hashes (`pet-collections`).

## 10. Errors and refusals

Bytes stay untrusted; the existing declared refusals apply **[observed]**
(`pet-refuse-*`, on every backend; Rust `transfer_payload_enums_refuse_malformed_bytes`):

| Condition | Refusal |
|---|---|
| a case index the enum does not declare (`04`, or `80 01`) | TransferInvalidValue |
| a case index that is no minimal varuint (`82 00`) | TransferMalformed |
| a payload-bearing case with its payload missing | TransferMalformed |
| a payload-free case followed by bytes; a payload followed by bytes | TransferMalformed |
| a truncated payload List, struct, nested enum, recursive value | TransferMalformed |
| invalid UTF-8 in a String field | TransferInvalidValue |
| an Int field not minimal; a Bool byte 2 | TransferInvalidValue |
| a `std::byte::Byte` field holding 300 | TransferInvalidValue |
| a forged List count (outer or in a payload) the bytes cannot hold | TransferMalformed |
| a valid outer case around an invalid inner enum index | TransferInvalidValue |
| bytes of another type, another enum, a payload-free enum of the same cases | TransferTypeMismatch |
| a fingerprint forged to the receiver's | the receiver's own checks: TransferMalformed, TransferInvalidValue, or a valid value of the receiver's type |

A thousand mutations of a rich encoding decode into the same outcome on
every backend, none taken for another version or type, never a crash
(`pet-refuse-mutations`); the fuzzer compares 38 400 mutated decodes over
60 seeds, on four backends, with the oracle's prediction (section 14).

**Minimum sizes.** A count is admitted against its element's minimum
size before any element is read, so the minimum must hold whatever case
the bytes hold. A `penum`'s is 1 (the case index) plus the least payload
minimum over every declared case (0 for a payload-free case): never the
largest case's (the mutant `min-size-largest-case` refuses a List of
payload-free cases whose every byte is there) and never one selected case.
Recursion through a payload (`Neg {e: Expr}`) needs no List to recur, so
`MinSizes` became an upward fixpoint in node order -- iterated until no
size changes or one round more than there are nodes, each size capped at
2^40 -- whose every round is a lower bound: sound wherever it stops, and
for every graph without payload recursion exactly the sizes the old
recursion computed. The zero-size budget is untouched: every enum value
takes at least one byte. No new limit: a 20 000-deep value round-trips on
every backend and a forged count of 2^28 - 1 is refused against two bytes
left (`pet-limits`) **[observed]**.

## 11. Cross-program and cross-backend identity

**[observed]**

* `pet-cross-backend`: the four backends write identical bytes for a
  bundle of payload enums (nested, recursive, a MutableVector, a struct of
  several fields), and each backend decodes each backend's bytes: sixteen
  pairs, one result.
* `pet-program-compatible`: a sender program's bytes decode in a receiver
  that declares the enum's cases and fields in another order behind other
  enums and structs (other native enum numbers and shape indexes), and the
  receiver matches every value.
* `pet-program-incompatible`: a field's type changed, a field added, a
  case added, the same cases in an enum of another name, the same short
  name in another module -- each refused (TransferTypeMismatch); the same
  declaration decodes.
* Rust: the same in two `Vm`s of different numbering.
* The fuzzer: every seed's receiver is compiled with every enum's cases,
  every payload's and struct's fields shuffled and two unrelated
  declarations first (section 14).

## 12. Independent VMs and the remote-actor acceptance

The principal application (tests/payload-enum-transfer/*.bot, run on
cranelift by `pet-remote-*`) **[observed]**, through the existing
`std::thread` and `std::actor::remote` APIs, unchanged:

* **messages.bot**: a worker thread sends `protocol::Request` values --
  `Calculate {requestId, x, y}`, `Store {key, value: List[int]}`,
  `Update {numbers: MutableVector[int]}` (sent, changed by its sender,
  sent again), `Nested {inner: List[Request]}`, two hundred numbered
  `Calculate`s, `Stop` -- through a `Remote[Request]` endpoint of capacity
  4 into a mailbox of 4 of the main VM. Each is encoded in the sending VM,
  carried as bytes, decoded in the receiving VM, and matched exhaustively
  by the receiving actor:

  ```
  ["calc 1 42", "store kéy 6", "update 24 4", "update 34 5",
   "nested 2 calc 2 2 stop", "ordered 200 received 200"]
  ```

  every case and payload as sent, in order, under backpressure (FIFO kept
  by the transport). Then a thread entry whose initialization value and
  result are payload enums (`compute(q: Query) -> Outcome`) returns
  `Outcome::Count {n: 3, longest: "three"}` to the main VM.
* **calls.bot**: a worker VM serves `Service[Query, Outcome]`; the main
  VM's caller actor calls it once per Query case and matches each
  reconstructed `Outcome`: `["pong", "sum 42", "text héllo!", "count 3
  bbbb"]`, four answers.
* Both again under `BOTLISH_NATIVE_GC_STRESS=1` (every VM's collector at
  every allocation site): the same results.
* `pet-actor-same-thread`: a payload enum posted to a same-thread actor is
  an ordinary value of its VM -- no transfer -- on every backend.
* The transport's own tests (FIFO, full queues and backpressure, closed and
  stale endpoints, type mismatches, undelivered messages, service
  termination, calls): tests/threads.test passes unchanged, 21 of 21.

## 13. Static trait and generic integration

**[observed]** A payload enum whose payloads are sendable satisfies the
intrinsic trait `Sendable` at every boundary that asks
(`pet-admit-*`): `std::transfer::encode` and `decode[T]`, a `Sendable`
trait view parameter (its function cloned per witness), a struct slot
`[T satisfies Sendable]`, a thread entry's parameter and result,
`std::actor::remote::Remote[M]` and `Service[Q, R]`. One with a
non-sendable case is refused at each, with the existing codes.
`any` and an unconstrained imprint variable stay `unknown`.

A generic helper constrained by Sendable, specialized for two payload
enums and a struct holding one, compiles under the semantic rollback audit
(`BOTLISH_SEMANTIC_ROLLBACK_AUDIT`'s check, `pet-semantic-rollback`) and
each specialization encodes its own schema **[observed]**. This milestone
writes no new HIR fact during analysis: `SendClass` is a query, and the
schema is computed by `hir::transfer::Elaborate` after the checks
**[inspection]**.

HIR text and interchange carry the schema as the transfer call's String
constant, as before; a reader that did not build it is checked where it
matters: native lowering validates a `penum` against the declaration
(section 8). The static decisions read no schema: `hir/staticdeps.tcl` is
unchanged, and the batched and sequential schedulers' comparison runs in
CI (section 18) **[inspection]**.

## 14. The independent oracle and the fuzzer

`audit/payload-enum-transfer/tools/oracle.py` is a model written from the
milestone's rules, sharing no code with the compiler: for int, str, bool,
List, named structs and enums (and Fn and any for the judgement) it
predicts Sendable, the canonical schema text and fingerprint, a value's
bytes, and the outcome of decoding *any* byte string -- the refusal, in
the order the format checks, with counts admitted against the fixpoint
minimum sizes. Its selftest derives the fixed vectors and fingerprints of
section 6 again **[observed]**.

`audit/payload-enum-transfer/tools/fuzz.tcl` generates, per seed,
declarations (two to four enums sharing case names, cases payload-free and
payload-bearing, payload fields of scalars, Lists, earlier enums and the
enum itself, a struct holding enums, sometimes a function or `any` field),
typed values, and mutations of their encodings, and checks on every
backend: SendClass against the oracle; each backend's bytes against the
oracle's; the oracle's bytes decoded by a receiver compiled from shuffled
declarations (equal to the receiver's own construction, re-encoding to the
same bytes); each mutation's outcome against the oracle's.

**[observed]**

| Run | Seeds | Backends | Judgements | Encodings | Decodes | Mutated decodes | Disagreements |
|---|---|---|---:|---:|---:|---:|---:|
| `-cases 10 -mutations 16` | 1-60 | four | 541 | 2 400 | 2 400 | 38 400 | 0 |
| `-gc-stress 1` | 100-109 | cranelift-generic, cranelift | 99 | 160 | 160 | 1 920 | 0 |

Its first runs failed on two defects of the fuzzer itself (it took a
standard-library function for one of the functions whose parameter type it
judges, and wrote a typed binding Botlish has no syntax for); neither was a
compiler disagreement. The oracle's prediction of every mutated decode -- value or
refusal, which refusal -- matched every backend's in every seed, so the
order of the format's checks is the same in the model, the Tcl codec and
the native codec. Counterexamples are kept per seed (`-keep`); none was
needed.

## 15. Mutation testing

`audit/payload-enum-transfer/tools/mutate.tcl` with `mutants.txt`
(26 mutants). A mutant names its detectors: tests, `rust:FILTER`, or
`fuzz:SEEDS` (the fuzzer against the oracle). A mutant is KILLED only by a
named detector reporting a failure; a test file that does not complete is
INCOMPLETE, never a kill.

**[observed]** All 26 are killed by a named detector. The first run of
the whole catalog killed 24; the two survivors were detector gaps, fixed
in the tests (not the mutants) and re-run (`-only`), both then killed:

* `decoded-payload-shared` (the decoder hands out the payload of the
  value last encoded in the process): sharing a payload's MutableVector
  between a source and its decoded copies is unobservable under Botlish's
  value semantics -- every read of a payload, a match's binding included,
  is a logical copy -- so `pet-mutable-independent` passed. The mutant's
  observable harm is a stale value: bytes decoded after another value was
  encoded take that value's payload. The test now encodes a second value
  between encoding and decoding the first, and kills it.
* `native-plan-payload-unchecked` (the Rust plan reader accepts a payload
  node that is no struct): the Rust test's bad plan was exercised by an
  encode whose value check failed first. It now decodes bytes the bad plan
  would turn into an `EnumCaseObj` with a non-struct payload, and kills it.

| Mutant | The bug it plants | Killed by |
|---|---|---|
| **The judgement** | | |
| `any-payload-sendable` | any payload-bearing enum is Sendable | `pet-class-function`, `pet-class-coroutine`, `pet-admit-encode`, `pet-admit-view`, fuzz |
| `first-field-only` | an enum judged by its first payload field alone | `pet-class-any-case` |
| `none-case-ignored` | a case with a non-sendable field ignored | `pet-class-function`, `pet-class-nested-enum`, `pet-class-opaque`, fuzz |
| `recursion-total` | a self-recursive enum taken as sendable outright | `pet-class-recursive-leaf`, `pet-class-recursive-deep-leaf`, `pet-class-order` |
| **The schema** | | |
| `payload-field-dropped` | a payload's last field missing from the schema | `pet-schema-Shape`, `pet-vector-several-fields`, `pet-roundtrip-several`, fuzz |
| `payload-declared-order` | payload fields in declared order: spelling becomes identity | `pet-vector-several-fields`, fuzz |
| `cases-declared-order` | cases in declaration order: fingerprint and indices depend on spelling | `pet-schema-Message`, `pet-fingerprint-stable`, `pet-program-compatible`, fuzz |
| `payload-free-cases-dropped` | only payload-bearing cases in the schema, as if one value's case decided it | `pet-schema-Message`, `pet-vector-payload-free-case`, `pet-vector-one-int`, `pet-fingerprint-changes-case-added`, fuzz |
| `payload-free-penum` | a payload-free enum moves to the new form: its old encoding changes | `pet-schema-Color`, `pet-schema-payload-free-unchanged`, `pet-vector-fingerprints` |
| `fingerprint-keeps-length` | the fingerprint keyed by the refined static type | `pet-fingerprint-literal`, `pet-gc-stress` |
| **The Tcl codec** | | |
| `payload-not-written` | the case written, its payload omitted | `pet-vector-one-int`, `pet-vector-list-payload`, `pet-roundtrip-text`, fuzz |
| `other-case-payload-schema` | every payload written by another case's schema | `pet-vector-one-int`, `pet-roundtrip-list`, fuzz |
| `payload-not-read` | every case decoded payload-free | `pet-roundtrip-text`, `pet-match-decoded`, `pet-vector-one-int`, fuzz |
| `wrong-case-built` | the next case built around the payload read | `pet-roundtrip-text`, `pet-match-decoded`, `pet-vector-one-int`, fuzz |
| `forged-index-accepted` | a case index not checked | `pet-refuse-case-index`, `-case-index-large`, `-recursive-index`, fuzz |
| `trailing-accepted` | bytes after the value ignored | `pet-refuse-payload-free-extra`, `pet-refuse-payload-extra`, fuzz |
| `min-size-largest-case` | a penum's minimum size its largest case's | `pet-roundtrip-payload-free-list`, fuzz |
| `zero-budget-bypassed` | zero-size elements draw on no budget | `vt-refuse-zero-budget` |
| `decoded-payload-shared` | the last encoded payload handed out by the decoder | `pet-mutable-independent` (after the fix above) |
| **The native plan** | | |
| `plan-unchecked` | a penum schema resolved without checking it against the declaration | `pet-plan-validated` |
| **The native codec** | | |
| `native-declaration-number` | the declaration's case number written for the sorted index | `pet-cross-backend`, `pet-vector-one-int`, `rust:transfer_payload` |
| `native-payload-not-written` | the case written, its payload omitted | `pet-cross-backend`, `pet-vector-one-int`, `rust:transfer_payload` |
| `native-payload-unrooted` | the payload popped off the roots before its object is allocated | `pet-gc-stress`, `rust:transfer_recursive_payload_enums`, `rust:transfer_payload_enums_between_independent_vms` |
| `native-payload-free-default` | a payload-bearing case decoded as the first payload-free case | `pet-remote-messages`, `pet-cross-backend`, `rust:transfer_payload` |
| `native-index-unchecked` | a forged case index clamped instead of refused | `pet-refuse-case-index`, `pet-refuse-recursive-index`, `rust:transfer_payload_enums_refuse_malformed_bytes` |
| `native-plan-payload-unchecked` | a payload node that is no struct accepted | `rust:transfer_payload_enum_plans_are_checked` (after the fix above) |

"fuzz" is `fuzz:1-4` (four seeds against the oracle). The existing
catalogs: `tools/mutant-catalogs.tcl` applies every mutant of every
catalog (114 catalogs, 3 866 mutants, 0 problems) **[observed]**;
`audit/payload-enums/tools/mutants.txt`'s `payload-enums-sendable` --
which planted "a payload enum is Sendable" against the old blanket
refusal -- now plants "a payload enum is Sendable whatever its payloads
hold" against the structural rule. VT-MUTANTS

## 16. Fixed vectors and compatibility checks

**[observed]**

* tests/value-transfer.test, unchanged: 76 of 76 -- its fixed vectors
  (`vt-bytes-*`) and every refusal.
* tests/sendability.test, unchanged: 82 of 82.
* Payload-free fingerprints pinned from origin/main
  (`pet-schema-payload-free-unchanged`), and nine other types'
  (`pet-fingerprint-compatible`).
* The new fixed vectors (section 6), pinned with their fingerprints
  (`pet-vector-fingerprints`, each the FNV-1a of the pinned text, which an
  independent FNV in the test recomputes).
* The plan form is pinned separately from the bytes: the Rust tests feed
  hand-written plans (`message_plan`, `tree_plan`).

## 17. Performance and allocations

PERF-RESULTS

## 18. Regression and CI

REGRESSION-RESULTS

## 19. Unsupported transfers

Refused, as before or by the rule:

* An enum any of whose cases holds a function, a closure, a coroutine
  handle, a C pointer or native view, a context struct, an opaque struct
  without a `sendable` statement, a refinement, or `any` -- also through a
  List, a struct or another enum.
* Moving affine runtime resources between VMs: an enum whose payload may
  own one is not sendable (affinity is not sendability).
* Transfer of `any` as an untyped dynamic value, of installed contexts or
  authority, of executable code.
* Persistent storage or schema evolution: a receiver with another
  declaration refuses (TransferTypeMismatch); nothing migrates.
* C ABI representations, a public discriminant or case number: none.

## 20. Remaining limitations

* **[inspection]** The fingerprint is a check of intent, not of
  authenticity; a forged one decodes only into values the receiver's
  schema admits.
* **[inspection]** A recursive enum's minimum size may stop below its
  exact minimum after the capped rounds (a recursive case's partial values
  are cheaper than its base case for a few rounds): sound, only weaker
  early refusal of a forged count.
* **[inspection]** Integer domains still keep their own nodes: two fields
  of different domains (or a domain and a plain Int) in one graph give a
  text another declaration of plain Ints does not share. This milestone
  leaves domains as they were (section 5); erasing them too would change
  existing types' fingerprints.
* **[projection]** Thread transport of payload enums is as available as
  the transport itself: Linux x86-64 and AArch64 with the driver package;
  other targets keep their explicit refusals (no platform workaround was
  added).

## 21. Files, and what to run when changing this

* hir/types.tcl (`SendClass`'s payload enum branch), hir/transfer.tcl
  (`penum`, `Intent`, `Schema`), core/transfer.tcl (`penum` in both
  directions, `wrap`, `MinSizes`), native/lower.tcl (`TransferPlan`'s
  `penum`), native/src/runtime/transfer.rs (`Node::PEnum`, `Work::Wrap`,
  the tests).
* tests/payload-enum-transfer.test and tests/payload-enum-transfer/*.bot;
  tests/payload-enums.test (`pe-c-and-boundaries`).
* audit/payload-enum-transfer/tools/{oracle.py, fuzz.tcl, mutate.tcl,
  mutants.txt}; audit/payload-enums/tools/mutants.txt
  (`payload-enums-sendable`, rewritten for the new rule);
  audit/golden/migration/census/payload-enum-transfer.tsv.
* bench/payload-enum-transfer.tcl.
* compilerpedia/topics/transfer.topic, concepts.topic; AGENTS.md
  ("Sendable payload-bearing enums").

What to run: `tests/payload-enum-transfer.test` (also under
`BOTLISH_NATIVE_GC_STRESS=1`), `tests/sendability.test`,
`tests/value-transfer.test`, `tests/payload-enums.test`,
`tests/exhaustive-match.test`, `tests/threads.test`, `cargo test --release
--manifest-path native/Cargo.toml --lib transfer`, `python3 -I
audit/payload-enum-transfer/tools/oracle.py selftest`,
`audit/payload-enum-transfer/tools/fuzz.tcl` (several seeds, once with
`-gc-stress 1`), `audit/payload-enum-transfer/tools/mutate.tcl`,
`audit/value-transfer/tools/mutate.tcl` and `audit/payload-enums/tools/
mutate.tcl` for code they share, `tools/mutant-catalogs.tcl` and
`tools/compilerpedia.tcl check`.
