# CONTEXT-OWNED-AFFINE-STATE-MILESTONE-1.md -- a context owns the resources it protects

> A context is an architectural airlock for authority. It must be able to
> own the resources it protects, without forcing those resources through
> untracked native memory or exposing them to callers.

ICY-TOWER-CONTEXT-REFACTOR-CENSUS.md found the intended architecture
working -- no raw SDL pointer above `sdl.bot`, 0 cross-module
pointer-bearing calls -- with one deficiency inside the airlock: a context
could not hold an affine value. Installing a context struct with a C
pointer in it was `AFFINE-ERASURE-UNSUPPORTED` (the installation passed the
value through an ownership-erasing position), and reading one through a
context parameter `AFFINE-FIELD-MOVE-REQUIRES-DESTRUCTURE` (a context
parameter was an ordinary immutable local, so every load would have been
another owner). Icy Tower therefore kept its SDL pointers in a 56-byte
native-memory record, held an unrestricted `NativeView` of it in the
context, and read the pointers back for every SDL call -- correct, but
outside affine tracking, inside the very abstraction meant to preserve the
authority boundary.

This milestone makes contexts own affine state. The installation moves its
value into the installed context; a context parameter names that installed
storage instead of copying it; a contextual function reaches the members as
places, observing them where they are stored; state acquired and released
after installation lives in a collection member and moves in and out by
that collection's explicit operations. Icy Tower's airlock keeps its
pointers in the context itself: the native handle record is gone.

## Contents

1. Result
2. Semantic result
3. Compiler and runtime
4. The SDL airlock
5. Evidence
6. Architectural conclusion
7. Remaining limitations
8. Files, and what to run when changing this

## 1. Result

**Can a Botlish context now own the affine foreign resources it protects,
including resources acquired after installation, without exposing them to
callers or stepping outside affine tracking? Yes.**

* **Ownership belongs to the installation.** `with context EXPR` moves the
  value into the installed context (the install native's ownership role is
  `move`): an affine value installed from a binding leaves the binding
  moved, and the context owns its members -- a pointer, a struct of
  pointers, a MutableVector or MutableArray of affine values, coroutines --
  for the rest of the run.
* **A context parameter is no second owner.** `context sdl: Sdl` names the
  installed storage. `sdl.renderer`, `sdl.sessions` and
  `sdl.sessions.element(0).renderer` are *context places*: an affine value
  there is observed where it is stored (a C call, `null?`, `clone`'s
  receiver, a field read), and any position that would copy it out -- a
  binding, an argument a parameter owns, a result, a field, a List element,
  a join, a loop, a destructuring or copy of the whole context, an erasing
  native -- is the new `AFFINE-CONTEXT-COPY-OUT`.
* **Late acquisition and explicit release.** A context installed closed (an
  empty vector) acquires a resource by `push`, observes it through the
  element place `std::mutable_vector::element(v, i)` (new, with its array
  sibling) and releases it by `pop`, `take` or `swap`, which clear the place
  they leave: no stale pointer remains reachable through the context.
* **Nothing implicit.** No reference type, no borrowed parameter, no
  lifetime, no implicit clone, no destructor: an explicit `clone` is a new
  affine value as before, and nothing releases what a context owns when the
  program ends (affinity is at most once, unchanged: reproducer c3).
* **Natively** a C address word -- a pointer, a native view or edit -- is an
  immediate leaf of the fixed context slot (`contextstore`/`contextload`),
  a vector header is rooted by `ctxroot` as before, and an observation is a
  `contextload` with no allocation.
* **Icy Tower.** `sdl.bot`'s Session holds the six SDL pointers themselves,
  inside the installed `Sdl`'s vector. The 56-byte record, its self-address,
  its view, its edit and the `remember` helper are gone; the public API is
  unchanged (render.bot and main.bot are untouched); the SDL call trace of a
  2400-frame run is identical but for the record's `SDL_malloc(56)` and
  `SDL_free`; `CONTEXT-RESOURCE-ESCAPE` stays clean.
* **A bug found and fixed on the way:** an affine struct holding an
  unrestricted MutableVector aliased the vector it was built from (its share
  descriptor was empty, since affine values are never copied); an
  unrestricted vector member beside an affine one is now a value again
  (section 3.6).

## 2. Semantic result

### 2.1 Three things, kept distinct

| | what it is | written |
|---|---|---|
| context requirement | what environment a function needs; a compile-time dependency, unchanged | `fn draw(context sdl: Sdl)` |
| context installation | the entry program moves a value into the installed context, which owns it -- once per type, at the top level, for the program's lifetime, unchanged in where and when | `with context sdl::create()` |
| context-member place access | a function requiring the context reaches the installed state where it is, without becoming an owner of any affine member | `sdl.open.element(0).renderer` |

The installed context stays the one value of its type; a function requiring
it reaches that value, never a fresh owner of it. Requirements, satisfaction,
context traits, installation order and every context diagnostic are
unchanged.

### 2.2 Context parameters when the installed value holds affine members

For an unrestricted context nothing changes: the parameter is a value that
can be copied, passed, compared and destructured (`cao-unrestricted-
context-unchanged`). For a context whose type is affine (it holds an affine
member somewhere), the binding `sdl` is a place:

* it is never an owner: the ownership analysis gives it no liveness state
  and no release (`hir::affine::IsAffineBinding` is 0 for a context
  binding, `IsContextBinding`), so no function's end drops the installed
  state;
* every expression reaching into it is a context place
  (`hir::affine::ContextPlace`): the binding, a field projection of a
  context place, an element place of a collection at one;
* the whole context is never copied while it holds affine state: binding
  it (`copy = sdl`), passing it to a parameter, returning it, destructuring
  it (`{root} = sdl`), comparing it, capturing it in a closure.

### 2.3 Direct-member observation

```
opaque context struct Holder:
    p: std::ffi::c::Ptr[std::ffi::c::Void]

fn empty?(context h: Holder) -> bool:
    h.p.null?()                          # observes the stored pointer

with context make()
empty?()                                 # true, on all four backends (a1)
```

A projection of a context place is a place step (`Consumer`'s project case:
`use place`), and its own consumer decides: an `observe` ownership role (a C
call's pointer arguments, `null?`, `clone`, `std::coroutine::done?`, a native
view's or edit's pointer) observes it in place; a collection operation's
receiver mutates the member in place; a field read of an unrestricted member
copies that value out (`h.count`); a statement that discards it is a use.
Before the milestone the same observation was `AFFINE-FIELD-MOVE-REQUIRES-
DESTRUCTURE` -- and still is for an owned local's affine field (2.12).

### 2.4 Element places: nested-element observation

The census's central requirement: a context member `MutableVector[Session]`
of affine sessions, a drawing operation observing the stored session's
renderer without popping and re-pushing it.
`std::mutable_vector::at` cannot: it returns an element by value, and an
affine one is `AFFINE-ELEMENT-COPY-OUT`. Reinterpreting `at` as a place
where its consumer happens to observe would give one call two meanings, so
the milestone adds the narrowest explicit operation instead:

```
std::mutable_vector::element(v, i)      the place of element i of v
std::mutable_array::element(a, i)       the place of slot i of a
```

registered `-element-place 1` (core/native.tcl's `elementPlace`: the
analyses read it by registration, never by name), with one static meaning:
*the place of the element at i of a collection the installed context owns*.

* Its receiver is a context place (`hir::mutvec::verify`;
  MUTABLE-PLACE-RECEIVER otherwise, naming at, take, pop and swap for a
  collection of the function's own). Element places nest through fields:
  `c.jobs.element(i).inner.element(j)`.
* It is never a value: it is projected (`.renderer`, `.synced`), observed
  (`std::coroutine::done?(c.jobs.element(0).step)`, a C call), or -- an
  unrestricted element or field -- read out. Binding, passing or returning
  an affine element place is `AFFINE-CONTEXT-COPY-OUT` (with a hint: an
  element place is used where it is written).
* A missing element fails with the declared IndexNotFound when the place is
  evaluated, exactly like `at`. A handler covers one call and not its
  arguments, and the place is an argument of the call that uses it, so a
  function using an element place declares IndexNotFound and its caller
  handles it (Icy Tower's public wrapper / private `session_*` pairs).
* At run time it is the element read (`op mvat`, `op mutarrayget`; the Tcl
  backends' `core::mutvec::element`): no reference, no new object.

One more hazard is specific to element places: the place is evaluated
where it is written, the call that observes it uses the word once its later
arguments have run, and code in a later argument could take the element out
of its collection (and release it) first. An observation through an element
place whose call has a later argument that may run Botlish code
(`hir::mutvec::MayRunCode`: a function, a callable, a resume, a yield) is
`AFFINE-CONTEXT-COPY-OUT` ("the observation would hold a copy across that
code"; `LaterArgumentRunsCode`). A direct member and a collection member's
header never leave the context, so their observations need no such check;
later arguments that are values (a reference, a constant, another element
place) are fine.

### 2.5 Explicit movement

Moving out of a context goes through a collection member's explicit moves,
each of which leaves its source place without the value:

| operation | moves | leaves |
|---|---|---|
| `c.v.push(x)` | x into the context | -- |
| `c.v.pop()`, `c.v.take(i)` | the element out (IndexNotFound, nothing changes, when absent) | the vector without it |
| `c.v.swap(i, x)` | x in, the old element out; a failed swap releases x | the slot holding x |
| `c.a.swap(i, x)` (MutableArray) | the same, for a fixed slot | the slot holding x |

A *direct* member (`c.root`) is owned for the program's lifetime: it can be
observed and explicitly cloned, never moved out, because nothing could
leave its place empty. State that is acquired and released after
installation therefore lives in a collection member -- Icy Tower's
`open: MutableVector[Session]`, empty when closed. No new movement
operation was needed: the collections already had exactly the moves that
clear their source (MUTABLE-VECTOR.md, MUTABLE-ARRAY.md). An ordinary field
projection never moves.

### 2.6 Container operations on context-owned collections

| operation on a context member of affine elements | result |
|---|---|
| `length`, `empty?` | observe the collection in place |
| `element(i)` | the element's place (2.4) |
| `at(i)` | `AFFINE-ELEMENT-COPY-OUT`, whose message now names `c.v.element(i)` for a context-owned collection |
| `push`, `pop`, `take`, `swap`, `clear` | mutate the member in place; elements move in and out as in any vector |
| `loop x in c.v` | `AFFINE-CONTEXT-COPY-OUT`: a consuming loop would move the whole vector out of the context |
| `c.v` as a value (`v = c.v`, an argument) | `AFFINE-CONTEXT-COPY-OUT`: the vector stays affine through the context (`MutableVector[Session]` never becomes copyable by being reachable through a context) |

### 2.7 No implicit duplication

Every way to copy affine state out is rejected, each at its place, with one
diagnostic (`cao-copy-out-rejected`, sixteen programs):

```
`d.root` is an affine std::ffi::c::Ptr[std::ffi::c::Int] that the installed
context Device owns: passing it to a parameter (which owns its argument)
would copy it out while the context keeps owning it, making a second owner.
Reach it where it is stored -- observe it (a C call, null?, clone), or keep
it in a collection member and move it out with take, pop or swap
(CORE SEMANTIC AFFINE-CONTEXT-COPY-OUT)
```

| attempt | diagnostic |
|---|---|
| `q = c.root`; `keep(c.root)`; `-> Ptr: c.root`; `return c.root`; `Box {p: c.root}`; `[c.root]`; `p = if b: c.root else: ...` | AFFINE-CONTEXT-COPY-OUT |
| `copy = c`; `{root} = c`; `g(c)` | AFFINE-CONTEXT-COPY-OUT ("the installed context ..., which owns affine state: destructuring it ...") |
| `v = c.sessions`; `loop s in c.sessions:` | AFFINE-CONTEXT-COPY-OUT |
| `s = c.sessions.element(0)`; `c.sessions.push(c.sessions.element(0))` (storing the same value twice) | AFFINE-CONTEXT-COPY-OUT |
| `std::ffi::c::erase(c.root)` (an ownership-erasing native) | AFFINE-CONTEXT-COPY-OUT (an erasure of a context place is a copy out of it) |
| `two(c.sessions.element(0).renderer, closing())` (a later argument runs code) | AFFINE-CONTEXT-COPY-OUT |
| `fn g() -> bool: c.root.null?()` nested in a function requiring `c` | AFFINE-CAPTURE-UNSUPPORTED, naming the remedy: the nested function declares `context c: Device` itself |
| `c.root == c.root` | AFFINE-EQUALITY-UNSUPPORTED, the ordinary rule |
| `c.sessions.at(0)` | AFFINE-ELEMENT-COPY-OUT, naming the element place |
| `std::mutable_vector::element(local, 0)` | MUTABLE-PLACE-RECEIVER (spelled as a method with both collections' element places visible, NO-APPLICABLE-METHOD: the receiver is each candidate's own problem, METHOD-SUGAR.md) |

A dedicated kind was added because the distinction needs its own
explanation: moving out of an owned binding is legal (the binding becomes
moved), moving out of a context place is not (the installed slot cannot
become moved), and the old remedies -- "destructure the struct", "keep it in
a binding" -- are wrong for a context. A forbidden copy never becomes an
implicit clone. An illegal access is one diagnostic and the rest of the
program is still checked (`cao-recovery`).

### 2.8 Legitimate explicit sharing

`c.root.clone()` is a new affine value under C-ABI-TYPES.md's rule (clone's
receiver is observed), which may be moved anywhere -- an explicit, visible
duplication of the address, never confused with an implicit copy
(`cao-direct-member-explicit-clone`). Affinity is not exclusive control of
a foreign allocation: a clone, native-memory authority (a view or edit of
the same memory) or a C library that retains a pointer keep their meanings.
What the milestone guarantees is narrower and exact: context storage never
implicitly duplicates or erases affine ownership.

### 2.9 Error paths

* An observation that fails leaves the state owned: a function that
  observes a stored job and then fails with a declared error leaves the job
  in the context (`cao-error-paths`; the fuzzer's `observe_fail`).
* An explicit move stays a move: a job taken out and then abandoned by a
  declared error is released on that error path, once, by the ordinary exit
  releases (AFFINE-VALUES.md); the job left in the context is never
  released (`cao-error-paths`: one release, the Tcl runtime's one live
  coroutine left, natively `released 1 sweptSuspended 0`).
* A failed `swap` releases the replacement it was given (MUTABLE-VECTOR.md's
  `swap_drop`), so a session moved into a failing swap is not lost silently
  (the fuzzer's `swap_job` out of range).
* Partial acquisition is the program's explicit code, as before: Icy
  Tower's `open` releases what it made, in reverse, on each failure, and
  publishes the session only after the last failure point -- nothing
  incomplete is ever pushed into the context.
* No transactional rollback: what moved out stays moved.

### 2.10 Compatibility

Contexts whose members are all unrestricted behave exactly as before:
`tests/contexts.test` (74 tests) and `tests/context-traits.test` (39) pass
unchanged, `cao-unrestricted-context-unchanged` copies, passes, destructures
and compares one, and an unrestricted vector member beside an affine one
keeps value semantics (`cao-mixed-members-value-semantics`: a read-out is a
copy; installing does not alias the vector the context was built from).

### 2.11 Context traits

The trait plan clones a function requiring a context trait for the selected
installed context and turns each operation into a direct call of the
implementation; the monomorphized program binds no value for the trait at
all -- only each implementation's own context parameter, which owns nothing
(`cao-trait-plan-no-state-copy` reads the monomorphized HIR). A private
helper, a public wrapper and a context-trait implementation all reach the
same installed state (`cao-helpers-wrappers-traits`, four backends; the
fuzzer's `via_trait`). Resolution, structural satisfaction, selection and
ambiguity are unchanged; context installation does not bypass `private`,
`opaque`, the direct-module analysis or CONTEXT-RESOURCE-ESCAPE.

### 2.12 What this is not

No `&T`, no borrowed or observing parameter, no mutable reference, no
lifetime, no reference-returning function, no place binding, no RAII, no
scoped installation, no exactly-once resources. Place observation applies
to places rooted at a context parameter: an owned local's affine field is
still `AFFINE-FIELD-MOVE-REQUIRES-DESTRUCTURE` (the owner can destructure or
move it, and general observing affine access is a separate design; 7). The
element place is a context-place operation for the same reason.

## 3. Compiler and runtime

### 3.1 HIR

Nothing new in HIR: no expression kind, no field, no side table. A context
binding is recognized from what HIR already holds (a local bound to the
installed context's load, `hir::mutvec::IsContextParam`), a context place
from its shape (a reference, projections, element-place calls), and an
element place is an ordinary call of a native. HIR text, interchange
(`cao-interchange`: a HIR with context-owned state through
`hir::interchange::encode`/`decode`, run on two backends) and compilation
isolation are unaffected; the two natives are core registrations, not a
registry a build fills.

### 3.2 The ownership analysis (hir/affine.tcl)

* `IsContextBinding` and `IsAffineBinding`: a context binding owns
  nothing, so it has no liveness, no USE-AFTER-MOVE and no release scope.
* `ContextPlace`, `ContextRoot`, `ContextPlaceText`, `ElementPlace`,
  `ThroughElement`: what a context place is, where it is rooted, how it is
  written in a diagnostic, and whether it reaches through an element.
* `Consumer`'s project case: a projection of a context place is `use
  place`; `NativeConsumer`'s observe case accepts a context place (not only
  a binding) as an observed argument's owner; `AffineProjection` lets a
  context projection be judged at itself.
* `ContextConsumer` (applied in `Analyze` to every affine context place):
  a move becomes AFFINE-CONTEXT-COPY-OUT, an erasure too, a discard a use.
  `LaterArgumentRunsCode` adds the later-argument rule of 2.4.
* A capture of a context binding by a nested function is
  AFFINE-CAPTURE-UNSUPPORTED with the context remedy.
* `Named` never prints the `with context` temporary (`context#1643`, the
  census's diagnostic-quality bug): it is "the value `with context`
  installs".
* `CopyOutMessage` names the element place for a context-owned collection.

The ownership kinds that withhold release scopes (hir/staticdeps.tcl's
`C:verdict`) include the new kind, and it has its DiagnosticCode case
(`AffineContextCopyOut`, hir/static.tcl and stdlib/compiler.bot), its census
classification (recoverable) and its Compilerpedia topic
(`error.affine-context-copy-out`, with a rejected and an accepted example).

### 3.3 Installation

`context#install` is registered `-ownership {move}` (core/contexts.tcl): the
hygienic temporary of `with context EXPR` moves into the installed context,
so it is never released after the installation (the mutant
`install-does-not-consume` releases the installed coroutines, and dies).
An unrestricted installed value is unaffected (ownership roles apply to
affine values only).

### 3.4 Places and collections (hir/mutvec.tcl, core/)

* `hir::mutvec::verify` checks an element place's receiver is a context
  place (MUTABLE-PLACE-RECEIVER, inside `hir::CheckingCall`: the call's own
  problem with its callee, so method-call decisions see it).
* core/native.tcl's `-element-place` option and `elementPlace` metadata,
  validated (an observed MutableVector or MutableArray receiver and an
  index); core/mutvec.tcl's and core/mutarray.tcl's `element`; native
  lowering maps the two natives to `mvat` and `mutarrayget`.
* The share descriptors: 3.6.

### 3.5 Native representation and GC roots

The context area and its slots are CONTEXTS.md's; what changed is the
eligibility enumeration (`native::lower::ContextLeaves`): a leaf of kind
`cptr` -- a C data or function pointer, a native view, a native edit, all
the C address word `(address << 4) | 0b1110` -- is an immediate, never a
heap pointer, so it is a slot word like a Bool. A String (or anything that
may be a heap object) is still CONTEXT-NATIVE-LOWERING-UNSUPPORTED
(`cao-native-slot-eligibility`; the mutant `view-eligibility-
overgeneralized`). The census's b2b -- a bare `NativeView` member -- now runs.

```
nir 1 call-effects=1 statics=0 contexts=16
context 0 "Sdl" offset=0 words=2 fields="root open"

func 0 "<program>"                       with context Sdl {root: null(), open: from_list([])}
    %0 = op cptrnull
    %1 = op listnew
    %2 = op mvfromlist %1
    contextstore 0 %0                     the pointer word, owned by the slot
    contextstore 8 %2                     the vector header
    %3 = op ctxroot %2                    rooted for the run
func 2 "root_null?"                      sdl.root.null?()
    %0 = contextload 0
    %1 = op cptrisnull %0
func 1 "session_clear"                   sdl.open.element(0).renderer.SDL_RenderClear()
    %0 = contextload 8                    the header
    %1 = int 0
    %3 = op mvat %0 %1                    the element place (IndexNotFound)
    %4 = structget 1 %3                   its renderer
    %5 = foreigncall 0 %4
    ret %5
```

1. *The installed slot owns the value*: the installation stores the leaves;
   nothing else holds the pointer words.
2. *Observing allocates nothing and copies no owning aggregate*: a member is
   one `contextload`, an element place one `mvat` and a field read
   (`cao-native-observation-no-allocation`: the allocation count of 100
   observations equals one's; no `structnew` in the observing function).
3. *Moving out updates the source place*: `pop`, `take` and `swap` are the
   vector's own operations on the installed header (its unique backing:
   an affine vector is never shared, MUTABLE-VECTOR.md).
4. *Replacing a stored value preserves GC correctness*: a stored element is
   reachable from the header, which `ctxroot` roots for the run
   (`vm.context_roots`); a replaced element moves out to its new owner's
   register or is released.
5. *Live managed objects stay roots*: the header (and through it every
   Session, coroutine or stored struct) is a permanent root; a coroutine's
   suspended stack is traced through its object as before.
6. *Pointer words are not heap pointers*: a register defined by a
   `contextload` of a `cptr` leaf is an immediate (`codegen/roots.rs`:
   never a root), exactly as for any C address word.
7. *GC movement does not invalidate context references*: the collector is
   a non-moving mark-and-sweep (native/src/runtime/heap.rs), and a context
   member is reloaded at every use; no reference to a member outlives the
   expression that reaches it.
8. *NIR keeps observation and transfer apart*: an observation is
   `contextload` (+ `mvat`, `structget`), a transfer one of the
   collection's mutating ops (`mvpush`, `mvpop`, `mvtake`, `mvswap`).

No Rust changed: no runtime resource table, no new NIR instruction, no
codegen change. GC stress: `cao-gc-stress` (the lifecycle and a coroutine
scheduler under `BOTLISH_NATIVE_GC_STRESS=1`), the Icy Tower executable
under GC stress (section 5), and the mutant `context-roots-lost` (no
`ctxroot`), which GC stress kills.

### 3.6 A bug found and fixed: affine structs' share descriptors

`hir::mutvec::ShareDescriptor` returned "" for every affine type: an affine
value is moved, never copied. But an affine *struct* may hold an
unrestricted collection beside its affine fields, and that collection is
still a value. Before the fix

```
v = std::mutable_vector::from_list([1])
s = State {log: v, p: std::ffi::c::null[std::ffi::c::Void]()}    # State is affine (p)
s.log.push(2)
[v.length(), s.log.length()]                                   # [2, 2] -- v aliased
```

on every backend; for a context this meant an installed affine context's
unrestricted vector aliased the vector it was built from, and its read-outs
were not copies. The descriptor of an affine struct now lists its
unrestricted collection slots (the affine ones move with the struct): `[1,
2]`, and the context's member is its own (`cao-affine-struct-vector-value`,
`cao-mixed-members-value-semantics`; the mutant `share-affine-struct-off`).
An affine *collection* is still never copied.

### 3.7 Backend parity

The rules are the shared front end's; the four backends run what it
accepts and agree on every program of tests/context-affine.test, the
reproducers and the fuzzer (interp, compile, cranelift-generic,
cranelift). The Tcl backends store the installed value in
`core::contexts::installed` and a vector header there is the same
`{mutvec ID}` every load returns, so in-place mutation and element reads
work unchanged; natively, 3.5. C calls run natively only, so a test that
needs a non-null pointer on every backend uses the test process's own
`ffi_fixture::address` (no foreign allocation), and coroutines are the
affine root with a real release on every backend.

## 4. The SDL airlock

`examples/games/icy-tower/sdl.bot`, before (this milestone's base) and
after:

```
before                                         after
Sdl                                            Sdl
  open: MutableVector[Session]                   open: MutableVector[Session]
    Session                                        Session (private, opaque)
      handles: NativeView[Handles]                   window, renderer, keys, rect,
        56-byte native record (SDL_malloc)           text, event: the affine pointers
          record (its own address), window,          synced: bool
          renderer, keys, rect, text, event
      synced: bool
```

| measure | before | after |
|---|---:|---:|
| native bytes retained solely for the handle record | 56 | 0 |
| unrestricted views retained solely to hold pointers | 1 (`Session.handles`) | 0 |
| context-owned affine resources | 0 | 6 pointers a session (window, renderer, keyboard state, rect, text and event buffers) |
| public pointer-bearing operations | 0 | 0 |
| private pointer helpers (parameters or results holding a pointer) | 8 (`write_text`, `log_failure`, `free_text`, `release`, `remember`, `renderer`, `quit_requested?`, `down?`) | 4 (`write_text`, `log_failure`, `free_text`, `release`) |
| pointer clones (`.clone()`) | 6 | 5 |
| native record lookups (pointer reads through the Handles view) | 13 (+2 reads of the view itself) | 0 |
| element-place accesses (`sdl.open.element(0)`) | 0 | 16 |
| native views and edits made | 6 | 5 |
| `sdl.bot` code lines (non-blank, non-comment) | 262 | 239 |
| functions in sdl.bot | 28 | 33 |
| frame instructions (callgrind, dummy driver) | 2,141,868 | 2,130,973 (-0.51 %) |
| program mallocs a frame (the managed heap's objects) | 511.9 | 511.9 |
| native allocations (SDL_malloc) | 4 (128 text, 16 rect, 128 event, 56 record) | 3 |
| `CONTEXT-RESOURCE-ESCAPE` warnings | 0 | 0 |

(The census's own counting tool, audit/icy-tower/context-refactor/tools/
census.tcl, counts "pointer-carrying" as affine: after the milestone it
also counts `sdl::Sdl` and `sdl::Session` as pointer-holding struct types
and `main -> sdl::create` as one pointer-crossing call -- the opaque Sdl
the entry program installs. That is the point of the milestone: the
pointers are tracked where they live, and the opaque Sdl that holds them
crosses exactly once, into the installed context.
`workload-icy-tower-sdl-airlock` accepts exactly that crossing and
nothing else.)

**What changed in sdl.bot.**

* `open` builds the session from the pointers it made and moves it in:
  `sdl.open.push(Session {window: window, renderer: renderer, keys: keys,
  rect: rect, text: text, event: event, synced: synced})`. The record's
  malloc, its edit and view, the two impossible-failure handlers and
  `remember` are gone.
* `close` moves it out and takes it apart: `session = sdl.open.pop()`,
  `{window, renderer, rect, text, event} = session`, `release(...)` -- the
  record's free and its self-address are gone (`keys` is SDL's, dropped
  without a call, as before).
* Every operation is a public wrapper and a private `session_*` function
  (`session_color`, `session_clear`, `session_present`, `session_fill`,
  `session_line`, `session_text`, `session_scale`, `session_synced?`):
  the private one makes the SDL call with the pointers where the context
  stores them (`sdl.open.element(0).renderer.SDL_RenderClear()`), the public
  one turns a closed SDL (IndexNotFound) into its failure. `poll`'s readers
  (`quit_requested?`, `down?`) observe the event and keyboard pointers the
  same way, so they no longer take a pointer.
* The text buffer is written through an edit made from the stored pointer
  (`write_chars`), so drawing text needs no clone.

**The remaining clones (5) and native memory.** All five are in the open
and release paths, where the pointer is a local of `open` or `release`, not
the context's: `text.clone().log_failure(...)` four times (log the failure,
then free the buffer) and once in `release` (after the merge below, the same
five clones read SDL's error: four in `open`, one in `close`). The native memory left is the
memory SDL's C ABI needs -- the `SDL_FRect` that `SDL_RenderFillRect` reads,
the 128-byte text buffer `SDL_RenderDebugText` reads, the 128-byte event
buffer `SDL_PollEvent` writes, all `SDL_malloc`'d by `open` and freed by
`close` -- and the views and edits that read and write them
(`EventType`, `KeyState`, `TextBuffer`, `SDL_FRect`). Nothing native
remains that exists only to retain a pointer.

**The airlock is intact.** This milestone changed neither the public API
nor render.bot and main.bot (the Windows port's changes to the API and
to main.bot, described below, are main's). `workload-icy-tower-sdl-airlock` (no pointer, view,
edit or SDL call outside sdl.bot, its only exception now the installation
of the opaque Sdl), `-sdl-records-opaque` (Session is opaque),
`-sdl-helpers-private` (every pointer helper, the session and every layout
private: its pinned list updated to the new names), `-no-resource-escape`
and `-baseline-warnings` pass; sdl.bot stays `contextualized` and every
other module ordinary.

**Merged with main's Windows port.** While this milestone was in progress,
main ported Icy Tower to Windows (ICY-TOWER-WINDOWS.md) on the record
design: the game moved into game.bot beside two entries (main.bot,
main-windows.bot), and sdl.bot stopped making the variadic `SDL_Log` call,
which Windows' native backend does not lower. SDL's error is now copied out
of SDL (`SDL_strlcpy` into the text buffer) and read through its layout
(`error_text`, `text_of`, `read_text`, `printable`), SdlFailed carries it
as `reason`, `close` returns it, and `poll` takes the scancodes as ints.
The merge carries all of it onto the Session design unchanged in behavior:
the error is read with `text.clone().error_text()` where `log_failure` was
(four times in `open`, once in `close`, from the popped session's buffer,
before anything is released), so the clone count stays five and the
private pointer helpers are `write_text`, `error_text`, `text_of`,
`free_text` and `release`. The table above measures the milestone before
the merge. Against main's committed executable, the merged one's SDL trace
of the same 2400-frame run is again identical but for the record's
`SDL_malloc(56)` and its `SDL_free`, and both failure traces
(`SDL_VIDEO_DRIVER=nosuch`, `SDL_RENDER_DRIVER=nosuch`, which read SDL's
error) are identical.

## 5. Evidence

### 5.1 Reproducers

`tclsh9.0 audit/icy-tower/context-refactor/tools/repro.tcl`: 63 runs, all as
expected. The census's programs are unchanged; their headers
record the new outcomes beside the old account
(ICY-TOWER-CONTEXT-REFACTOR-CENSUS.md, 4.1, has both):

| reproducer | previous result | result now |
|---|---|---|
| a1 | AFFINE-FIELD-MOVE-REQUIRES-DESTRUCTURE, AFFINE-ERASURE-UNSUPPORTED | `value: true` on all four backends: valid installation, observing place access |
| a1b | AFFINE-ERASURE-UNSUPPORTED at the installation | AFFINE-CONTEXT-COPY-OUT at the destructuring: installation valid, whole-context movement still rejected |
| a2 | AFFINE-ERASURE-UNSUPPORTED twice | `value: 1` on all four backends: the slot owns the aggregate and the vector of pointers |
| b1 | `[-1, 42, -1, -1]` | unchanged |
| b2 | `[-1, 5, -1, -1]` natively | unchanged; no longer necessary (a3) |
| b2b | CONTEXT-NATIVE-LOWERING-UNSUPPORTED natively | runs natively (its value is uninitialized memory: `value: *`) |
| c3 | `[1, 0]`: a dropped handle is not released | unchanged: affinity is at most once |
| a3 (new) | -- | `[-1, 5, -1, -1, 5]` natively: pointers acquired into the context after installation, observed by strlen through the element place, released by pop, reopened |
| b2c (new) | -- | `42` natively: a bare view member, its cell written before it is read |

### 5.2 Tests

`tests/context-affine.test` (28 tests, every program on interp, compile,
cranelift-generic and cranelift): installation consumes; direct members
observed and explicitly cloned; a nested aggregate; the unrestricted
contrast; the late-acquisition lifecycle (open, observe, close, close
twice, reopen); the element-place registrations; unrestricted element
fields; take and swap; a MutableArray of pointers; coroutines owned by a
context vector; error paths with release accounting (Tcl probe and native
counters); a counted loop and a recursive contextual function observing
every stored job, and a failed construction whose coroutine is released
before it reaches the context; sixteen copy-out programs; the message; the ordinary
diagnostics where they apply; recovery; plain later arguments; helpers,
wrappers and a context trait; the trait plan's monomorphized HIR; mixed
members; the affine-struct share fix; native slot leaves, eligibility, a
no-allocation observation; GC stress; an edited HIR text making a second
owner (`hir::parse` checks form, not analysis -- HIR text is trusted like
compiled code -- and `hir::check` of the edited HIR reports
AFFINE-CONTEXT-COPY-OUT); HIR interchange.

Updated, because the semantics changed on purpose: `tests/c-abi-types.test`'s
`ca-affine-containers-contexts` (a context struct may hold a pointer now;
the test adds the observation and the copy-out), `tests/mutable-array.
test`'s `ma-roles-audit` (the two element places' roles),
`tests/static-compile.test`'s `sc-codes-one-to-one` and
`tests/golden-framework.test`'s `gf-code-name-complete` (113 codes:
`std::test::code_name` spells the new case, stdlib/test.bot),
`tests/stdlib-namespaces.test`'s `ns-qualified-inventory` (the two element
places; audit/stdlib-census/after.tsv regenerated), `tests/windows-io.test`'s
`wi-context-holds-devices` (it pinned "a C pointer cannot live in a context";
WindowsIO still holds devices, for its other reason -- a cached standard
handle would outlive the process replacing it -- and the test now checks
WindowsIO's fields hold no C address), and `tests/workload-icy-tower.test`'s
airlock (the installation of the opaque Sdl) and helpers-private (the new
private names) tests.

### 5.3 Fuzzing

The context fuzzer has an owned-state mode, `audit/contexts/tools/fuzz.tcl
-owned 1` (audit/contexts/tools/owned.tcl): one context owning a direct
pointer, a nested pair, a vector of coroutine jobs, a vector of pointer
cells, an array of pointer slots and an unrestricted log, installed by a
literal or a binding, then 4..14 random operations -- open, resume in place,
tag, done?, take, pop, swap (also out of range), take-and-fail,
observe-and-fail, cell and slot push/pop/swap/read, root, an explicit clone,
the pair, the log and a copy of it, a context-trait count and a helper
count. Its oracle is an independent model of the installed state (jobs with
identities and accumulators, addresses, the log), from which it derives the
value and the release obligations: every coroutine moved out of the
context is released exactly once, none still in it ever is (checked by the
interpreter's release calls, the live Tcl coroutines and the native
counters). A third of the programs carry one fault from 16 (2.7's), each
with the predicted diagnostic.

Four seeds of 40 programs each (`-seed 1`, `101`, `201`, `301`; every
program on all four backends, the native coroutine counters read with
coroutine fusion off):

| seed | accepted | rejected (by the predicted diagnostic) | coroutine identities whose releases were checked | disagreements |
|---|---:|---|---:|---:|
| 1 | 27 | 13 (AFFINE-CONTEXT-COPY-OUT 10, MUTABLE-PLACE-RECEIVER 2, AFFINE-EQUALITY-UNSUPPORTED 1) | 55 | 0 |
| 101 | 28 | 12 (AFFINE-CONTEXT-COPY-OUT 9, AFFINE-CAPTURE-UNSUPPORTED 1, AFFINE-ELEMENT-COPY-OUT 1, NO-APPLICABLE-METHOD 1) | 52 | 0 |
| 201 | 19 | 21 (AFFINE-CONTEXT-COPY-OUT 13, NO-APPLICABLE-METHOD 4, AFFINE-EQUALITY-UNSUPPORTED 2, AFFINE-ELEMENT-COPY-OUT 1, MUTABLE-PLACE-RECEIVER 1) | 32 | 0 |
| 301 | 32 | 8 (AFFINE-CONTEXT-COPY-OUT 5, AFFINE-CAPTURE-UNSUPPORTED 1, AFFINE-EQUALITY-UNSUPPORTED 2) | 58 | 0 |

160 programs, 0 disagreements (the final generator: an installation's
context also holds a job made before it and the top level keeps a log it
reads at the end; each seed ran in 66 to 94 seconds). The fuzzer's first runs found two faults
of its own, both a method-call rule rather than a context one: with both
`std::mutable_vector` and `std::mutable_array` imported, `v.element(0)` on a
collection no context owns and `c.jobs.at(0)` have two candidates, each of
whose own call is invalid, so method sugar reports NO-APPLICABLE-METHOD,
not the receiver's diagnostic (METHOD-SUGAR.md; the same holds for `swap`
on a temporary). The faults now spell the qualified call, and a
`local-element-method` fault expects NO-APPLICABLE-METHOD. The default
(unowned) mode of the fuzzer is unchanged.

### 5.4 Mutation testing

`audit/context-affine/tools/mutate.tcl` (mutants.txt, 18 mutants; the
detectors tests/context-affine.test and the owned-state fuzzer):
18 mutants, 18 killed, 0 survived. Each is a deliberate bug of one rule,
and every one is caught by a test of behavior, most also by the fuzzer:

| mutant | the bug | tests that fail | fuzzer programs that disagree (30) |
|---|---|---:|---:|
| `install-does-not-consume` | installation observes its value instead of moving it: the temporary stays its owner and is released after the installation | 1 | 10 |
| `install-erases` | the pre-milestone rule: installation erases its value | 23 | 22 |
| `context-binding-owns` | a context parameter's binding is an owner (runtime loads mint owners), released at its last use | 5 | 20 |
| `context-copy-accepted` | a move of a context place stays a move: context access copies an affine member | 4 | 4 |
| `context-erasure-accepted` | an erasure of a context place stays the old AFFINE-ERASURE-UNSUPPORTED | 1 | 3 |
| `element-copy-accepted` | affine vector elements are treated as unrestricted: an element place may be bound or pushed | 2 | 2 |
| `observation-consumes` | an observed context place is a temporary nothing owns | 18 | 30 |
| `projection-not-place` | a projection of a context place is no place step | 20 | 30 |
| `capture-accepted` | a closure may capture the installed context's affine state | 1 | 0 |
| `later-argument-unchecked` | an element place observed across a later argument that runs code | 1 | 0 |
| `element-receiver-unchecked` | an element place of a collection no context owns is accepted | 1 | 2 |
| `element-place-unregistered` | the vector's element is registered as no element place | 14 | 30 |
| `non-affine-context-rejected` | a non-affine context is judged by the context rule too | 8 | 23 |
| `share-affine-struct-off` | the pre-milestone ShareDescriptor: an unrestricted vector member of an affine context aliases its source | 2 | 2 |
| `take-leaves-slot-populated` | take returns the element and keeps it in the vector (two owners) | 3 | 2 |
| `context-roots-lost` | an installed vector header is never registered as a GC root (killed by GC stress) | 2 | 0 |
| `view-eligibility-overgeneralized` | a String member is an "immediate" context-slot leaf | 1 | 0 |
| `pointer-not-eligible` | the pre-milestone eligibility: no pointer or view leaf | 15 | 20 |

Two mutation targets the brief names have no mutant, for a reason
mutants.txt records: *the context-trait plan copies installed state* --
the plan binds no context value at all, so there is no copy to make, and
`cao-trait-plan-no-state-copy` checks the monomorphized HIR has none; and
*a private helper bypasses affinity* -- privacy has no ownership code path,
so every mutant above applies to private helpers alike (the helpers of
`cao-helpers-wrappers-traits` and of Icy Tower are private). The first
complete run counted two mutants killed by the fuzzer alone through a
fault of the fuzzer's own (2.7's method-call note), and showed that
`context-erasure-accepted` was caught by nothing else: the test now covers
an erasure through a parameter declared `any` (its own row), the fuzzer has
an `any-parameter` fault, and its installations hold a job made before the
installation and a log the top level keeps (`install-does-not-consume`,
`context-erasure-accepted` and `share-affine-struct-off` are now killed by
the fuzzer too). The table is the run on the final tree (16 minutes). No
program of its 30 catches four mutants: a closure capturing context state
and a later argument that runs code are single faults (a third of the
programs carry one of sixteen, so 30 programs hold a given fault about
every other run; this run's 30, seed 7, rejected 7 programs by
AFFINE-CONTEXT-COPY-OUT, 2 by MUTABLE-PLACE-RECEIVER and 1 by
AFFINE-EQUALITY-UNSUPPORTED, none by a capture), and the fuzzer runs no GC
stress and builds no String member, which the GC-roots and slot-kind
mutants need. Each of the four has its test.

### 5.5 Regression

`tclsh9.0 tests/local.tcl` (every Tcl test file on interp and compile, every
golden suite on all four backends; 64 minutes with 4 jobs):

| layer | result |
|---|---|
| Tcl tests on interp | 7,362 passed, 2 failed, 74 skipped (2,250 golden duplicates skipped) |
| Tcl tests on compile | 7,357 passed, 2 failed, 79 skipped |
| golden suites (108) | 0 failed: interp 5,180/5,180, compile 5,180/5,180, cranelift-generic 5,088/5,088, cranelift 5,190/5,190 |

The two failures were tests pinning the old rules, found by this run and
updated with it (5.2): `gf-code-name-complete` (stdlib/test.bot's
`std::test::code_name` did not spell the new DiagnosticCode case) and
`wi-context-holds-devices` (it pinned AFFINE-ERASURE-UNSUPPORTED for a
context holding a pointer). With them updated, both files pass
(golden-framework.test 42 of 42; windows-io.test 12 passed, its 15
Windows-only tests skipped), with context-affine, golden, compilerpedia and
stdlib-namespaces rerun beside them; and the golden layer, run again on the
final tree (`tests/local.tcl -parts golden`: stdlib/test.bot changed, so
every suite's front end ran anew, 23 minutes), is again 108 suites, 0
failed, with the same counts on every backend.

The harnesses AGENTS.md names for the files this milestone changed:

| harness | result |
|---|---|
| `audit/affine/tools/fuzz.tcl -n 40`, seeds 3, 17, 41 | 120 programs, 0 disagreements (307 identities' releases checked) |
| `audit/contexts/tools/fuzz.tcl -owned 1 -n 40`, seeds 1, 101, 201, 301 | 160 programs, 0 disagreements (5.3) |
| `audit/context-affine/tools/mutate.tcl` | 18 of 18 killed (5.4) |
| `audit/affine/tools/mutate.tcl`, the 14 mutants that edit hir/affine.tcl | 14 of 14 killed |
| `audit/coroutines/tools/mutate.tcl`, the 17 mutants that edit hir/affine.tcl or native/lower.tcl | 17 of 17 killed |
| `audit/mutable-vector/tools/mutate.tcl`, the 46 mutants that edit hir/affine.tcl or hir/mutvec.tcl (`affine-move-cow-fork`'s text updated to the new ShareDescriptor) | 46 of 46 killed |
| `audit/mutable-array/tools/mutate.tcl`, the 12 mutants that edit hir/affine.tcl, hir/mutvec.tcl or native/lower.tcl | 12 of 12 killed |
| `audit/mutable-map/tools/mutate.tcl`, the 6 mutants that edit hir/mutvec.tcl or native/lower.tcl | 6 of 6 killed |
| `audit/contexts/tools/mutate.tcl` (26 mutants; core/contexts.tcl changed; its fuzzer in the default, unowned mode) | 26 of 26 killed |
| every mutant of every `audit/*/tools/mutants.txt` that edits a file this milestone changed (346 edits) | each still applies to its text exactly once |
| `tclsh9.0 audit/refactor/tools/gate.tcl` (the warning gate) | passed: the observed warnings are exactly the manifest (75 corpus programs, 30 library loaders) |
| `tclsh9.0 tools/compilerpedia.tcl check` | 848 topics (2 new, 2 generated notes), 633 examples run, 0 problems |
| `tclsh9.0 audit/icy-tower/context-refactor/tools/repro.tcl` | all as expected (5.1) |

The affine, coroutine, vector, array and map harnesses ran their mutants of
the files this milestone changed, not their whole lists: the rest mutate
code this change does not touch (their texts were checked to apply), and
the five lists run in full take most of a day in this container. CI runs
none of these five.

### 5.6 Targets

Beside this container's runs, the branch ran in CI on every host the
native backend supports: the macOS and Windows workflows on the commit
that holds the whole change (7bc86bb7), and tests, tests-arm64,
static-decisions and icy-tower dispatched on 3b770910 (every commit after
7bc86bb7 changes only this report). Every job passed.

| target | shared semantics | native context slots, element places |
|---|---|---|
| Linux x86-64 | executed: every test above in this container; in CI (`tests`) the whole Tcl suite on interp and compile, its cranelift and cranelift-generic coverage, the golden suites in four shards, the stub- and system-linked executables (the system-linked also under GC stress), the warning gate and the method-call oracle | executed (both native backends; `cao-native-*` and `cao-gc-stress` here and in CI) |
| Linux AArch64 | executed in CI (`tests-arm64`, ubuntu-24.04-arm): the Tcl suite on interp and compile, its cranelift and cranelift-generic coverage, the golden suites, the Rust unit tests (also under GC stress), the system-linked executables (also under GC stress) and the whole suite under GC stress | executed in CI (the same jobs; tests/context-affine.test's `nativeLinux` and `nativeCoroutines` tests run there) |
| macOS AArch64 | executed in CI (`tests (macos arm64)`): smoke, the acceptance tier in two shards (tests/context-affine.test among its 117 files) and the system linker's tests, also under GC stress | executed in CI except the three `nativeLinux` tests (slot leaves, eligibility, the no-allocation observation), which skip off Linux; the four `nativeCoroutines` tests run |
| Windows x86-64 | executed in CI (`tests (windows x86-64)`): smoke, the root plans, the system linker and the acceptance tier in four shards (Windows excludes no test file) | executed in CI except the three `nativeLinux` tests and the four `nativeCoroutines` tests (Windows has no native coroutines) |

`static-decisions` compared the batched and the sequential scheduler on
every golden suite (mutable-array.bot's job and four shards): no
disagreement. `icy-tower` built SDL3, ran the workload's tests with none
skipped, compared the executable with the independent oracle, killed the
mutants and played the game under Xvfb. The `tests` workflow's GC-stress
job runs on pushes to main only and so did not run on the branch; the
arm64 workflow's GC-stress run of the whole suite did.

No claim of target execution rests on cross-target compilation. The SDL
acceptance workload is Linux x86-64 only, as before.

### 5.7 Icy Tower

| check | result |
|---|---|
| SDL call trace, 2400 dummy-driver frames, seed 7 (trace-compare.sh, the previously committed executable against the one this milestone commits, `audit/icy-tower/artifacts/icy-tower`, rebuilt by build.sh) | 204,299 calls before, 204,297 after: identical except the record's `malloc 56` and its `free` |
| failure traces (`SDL_VIDEO_DRIVER=nosuch`, `SDL_RENDER_DRIVER=nosuch`) | identical (3 and 7 calls) |
| `--headless` 600 frames; dummy driver 600 frames | identical summaries before and after |
| `tests/workload-icy-tower.test` (20 tests, executables with the package-owned libSDL3) | 20 passed, 0 skipped (5 min 51 s) |
| `golden.bot` on four backends | 67 of 67 on interp, compile, cranelift-generic and cranelift, the same report on each (`workload-icy-tower-golden-suite`) |
| `audit/icy-tower/mutate.tcl` (26 gameplay mutants) | 26 of 26 killed, every one by failing golden tests (23 minutes) |
| `python3 audit/icy-tower/oracle.py compare` (8 seeds; 1, 60, 600, 3600 frames) | 0 differences |
| valgrind memcheck, 30 frames (the test) and 600 frames | 0 errors; 0 bytes definitely, indirectly or possibly lost (600 frames: 544 bytes still reachable, SDL's own, as in the census) |
| GC stress (`BOTLISH_NATIVE_GC_STRESS=1`), 120 frames (the test) and 600 dummy-driver frames | the same summary as without, before and after |
| `audit/icy-tower/tools/xvfb-session.py` (SDL3 with its x11 driver, Xvfb, XTest; the rebuilt committed executable) | every check passes: Right then Left moved the player from x = 319.5 to 481.5 and back to 175.5, Escape exits 0; the autopilot ran 1518 frames in 25 s (vertical sync, 60 Hz) and exits 0; WM_DELETE_WINDOW ends the run cleanly |

### 5.8 Performance

`audit/icy-tower/tools/perf.tcl` on both trees (the before tree is this
milestone's base commit, compiled by its own compiler; callgrind's
instruction counts, unstripped builds, 240 minus 60 frames, seed 7):

| per frame | before | after | change |
|---|---:|---:|---:|
| instructions, dummy driver | 2,141,868 | 2,130,973 | -10,895 (-0.51 %) |
| -- in the program | 489,367 | 480,033 | -9,334 (-1.9 %) |
| -- of them runtime helpers | 185,919 | 177,819 | -8,100 |
| -- of them generated code | 26,993 | 25,759 | -1,234 |
| -- libc | 161,310 | 159,748 | -1,562 |
| program mallocs (managed objects) | 511.9 | 511.9 | 0 |
| C calls into SDL | 89 | 89 | 0 |
| instructions, headless (no SDL) | 220,586 | 220,588 | +2 |
| native allocations a run (SDL_malloc) | 4 | 3 | -1 (the record) |
| pointer clones a frame | 0 | 0 | 0 |

About 105 program instructions fewer per SDL operation (9,334 over 89 calls): an element place is the
vector's bounds-checked read and a field load of the stored Session, where
the record design read the session out of the vector and then each pointer
through a native view (a runtime helper per field). The census measured the
record design at +0.7 % against the vertical slice; the context-owned design
gives back most of it. The headless run, which opens no SDL, is unchanged.
Wall-clock time (best of 3, on a container running the test suite
concurrently, so only indicative): headless 27.5 us a frame before, 24.2
after; dummy driver 477.8 us before, 444.6 after -- within the noise of a
loaded machine, and SDL's software renderer dominates it. No specialized
native instruction was added for any of it; AOT builds and runs as before
(build.sh: about a minute).

## 6. Architectural conclusion

**Can a Botlish context now own the affine foreign resources it protects,
including resources acquired after installation, without exposing them to
callers or stepping outside affine tracking? Yes.**

The installed context owns its members -- pointers, aggregates of them,
vectors and arrays of them, coroutines -- because installation moves them
in. Functions that require it reach those members where they are stored,
as places, and nothing copies one out: every position that would make a
second owner is a compile-time error, and every move out of the context is
one of a collection's explicit operations, which leave no stale value
behind. Resources acquired after installation go in by push and come out
by pop, take or swap. All of it is affine tracking -- the same analysis,
the same releases, the same diagnostics' discipline -- with no reference
type, no borrow, no lifetime and nothing at run time but the loads and the
collection operations that were already there. Icy Tower's airlock keeps
its SDL window, renderer and buffers in the context, as affine pointers,
with no native memory that exists only to hold them, and its callers see
exactly the operations they saw before. The authority boundary and the
ownership boundary coincide.

## 7. Remaining limitations

* **Context lifetime and destructors.** Unchanged: a context lives as long
  as the program, nothing releases what it owns when the program ends, and
  close is the program's explicit operation. A forgotten close is not
  diagnosed (affinity is at most once; c3).
* **Program-wide installation.** Unchanged: once per type, at the entry
  program's top level, unconditionally, with no handler (c1, c1b, c2); an
  airlock installs closed and opens by an operation.
* **Context composition.** Unchanged: a context cannot hold (and so
  install) another context; every layer is installed by the entry program
  (e1).
* **General observing affine access.** Place observation is for places
  rooted at a context parameter. An owned local's or parameter's affine
  field is still read by destructuring (AFFINE-FIELD-MOVE-REQUIRES-
  DESTRUCTURE), and a helper that needs a context-owned pointer either
  declares the context itself or receives an explicit clone; there is no
  observing parameter. An element place is not bindable, so an operation
  that uses one is a function declaring IndexNotFound (Icy Tower's
  `session_*` functions): the ergonomic cost of having no place bindings.
* **Element places and later arguments.** Conservative: any later argument
  that may run Botlish code rejects the observation, even code that cannot
  reach the context; bind the later arguments first.
* **Native slots.** A context member that may be a heap object other than a
  collection header (a String, a List, a struct held outside a collection,
  a coroutine handle as a *direct* member) is still
  CONTEXT-NATIVE-LOWERING-UNSUPPORTED natively; a coroutine or a struct of
  pointers inside a vector or array member is supported (the header is the
  root).
* **Module and package visibility.** Unchanged (`private` is module-level;
  no package `internal`).
* **FFI borrowing and non-byte storage.** Unchanged: the SDL scratch
  memory is native because Botlish storage can be lent only to byte-sized
  pointees (C-POINTER-BORROWING.md).
* **Implementation-specific.** The native check of the area's words is the
  eligibility enumeration (`ContextLeaves`); a new immediate kind must be
  added there explicitly.

## 8. Files, and what to run when changing this

| file | what |
|---|---|
| `core/contexts.tcl` | `context#install` moves its value (`-ownership {move}`) |
| `core/native.tcl` | the `-element-place` registration option and `elementPlace` metadata |
| `core/mutvec.tcl`, `core/mutarray.tcl` | `std::mutable_vector::element`, `std::mutable_array::element` |
| `hir/affine.tcl` | context bindings own nothing; context places; `ContextConsumer`, AFFINE-CONTEXT-COPY-OUT, `LaterArgumentRunsCode`; the capture and naming fixes |
| `hir/mutvec.tcl` | the element place's receiver check; affine structs' share descriptors |
| `hir/static.tcl`, `stdlib/compiler.bot`, `hir/staticdeps.tcl`, `stdlib/test.bot` | the new kind's DiagnosticCode case, its ownership-verdict channel and `std::test::code_name`'s spelling of it |
| `native/lower.tcl` | C address words as context-slot leaves; the element places' ops |
| `examples/games/icy-tower/sdl.bot` | the refactored airlock |
| `audit/icy-tower/artifacts/icy-tower` | the committed executable, rebuilt from it |
| `tests/c-abi-types.test`, `tests/mutable-array.test`, `tests/static-compile.test`, `tests/stdlib-namespaces.test`, `tests/workload-icy-tower.test`, `tests/windows-io.test`, `tests/golden-framework.test` | tests that pinned the old rule (a pointer in a context rejected), the roles and namespace inventories, the census and the airlock's private names |
| `tests/context-affine.test` | the milestone's tests |
| `audit/contexts/tools/fuzz.tcl`, `owned.tcl` | the context fuzzer's owned-state mode |
| `audit/context-affine/tools/mutate.tcl`, `mutants.txt` | the mutation harness and its mutants |
| `audit/icy-tower/context-refactor/repro/` | the reproducers' new outcomes, a3 and b2c |
| `compilerpedia/topics/`, `compilerpedia/notes/stdlib.notes` | `concept.context-owned-state`, `error.affine-context-copy-out`, the element places |

When changing any of it, run what AGENTS.md's "Context-owned affine state"
lists: `tests/context-affine.test`, `tests/contexts.test`,
`tests/context-traits.test`, `tests/affine.test`, `tests/coroutines.test`,
`tests/mutable-vector.test`, `tests/mutable-array.test`,
`tests/c-abi-types.test`, `tests/workload-icy-tower.test`,
`audit/contexts/tools/fuzz.tcl -owned 1` (several seeds),
`audit/context-affine/tools/mutate.tcl`, the affine, coroutine,
mutable-vector and mutable-array harnesses for a change to hir/affine.tcl
or hir/mutvec.tcl, a GC-stress run for the native slots, and the
reproducers.
