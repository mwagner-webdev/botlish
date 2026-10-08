# M8.a: virtual immutable construction plans

## Outcome

**Kept, default on.** The stronger hypothesis M8.a set out to test --
"intermediate immutable sequence values are being materialized much earlier
than their semantics require" -- is confirmed, and the general value model
built to test it clears the milestone's own high bar on the workloads that
actually exercise repeated construction:

* **Copy volume goes from quadratic to linear.** Every runtime-variable
  concat/list_append probe copied exactly 4.00x more payload per doubling of
  N before M8.a, and copies exactly 2.00x more after it (tables below). At
  N = 16000, String bytes copied fall from 256,016,000 to 121,272 (2111x
  less) and List elements copied from 127,992,000 to 32,380 (3953x less).
* **Intermediate allocation collapses.** The same probes go from N
  intermediate flat Strings/Lists to exactly one final flat object plus one
  private plan object, whatever N is.
* **Frozen concat-heavy workloads improve far beyond noise**:
  `string_replace` 100 KB 12.1x, `string_reverse` 10K characters 11.3x,
  `ai_text_clean` 100K characters 6.3-7.2x, `csv` 10,000 rows 2.5x, the two
  builder-based csv variants 1.4-1.6x (their quoted-field accumulator);
  concat-free controls stay at 0.96-1.00x (noise).
* **The URI chain collapses structurally and, for the first time in the
  M-series, moves in time.** Its 33,500 intermediate String
  materializations per 2000 calls go to 0 (plus 8,500 private plan
  objects), with `hex_pair`/`esc_bytes`/`esc_char`/`esc_from` all still
  `<generic>`, and `uri-steady` runs 17-22% faster (medians 5,055-5,290 us
  off, 3,978-4,105 us on, across independent runs) -- even though its
  strings are 1-12 characters long and copy volume was never its main
  cost.

Nothing about what a String or List *is* changed: no source change, no
type/theorem change (`hir::types::show`, instance keys, instance and
function counts identical with the optimization on and off), no
specialization key encodes plan state, no fixed-arity type exists, and every
program's value is identical on interp, compile, cranelift-generic and
cranelift with `-virtual-construction-opt 0` and `1`.

```
git diff --stat (production code):
 hir/construction.tcl            | new, 794 lines  (the analysis)
 hir/hir.tcl                     |   2 +-          (loads it)
 native/lower.tcl                | +550            (lowering + flag + docs)
 native/src/runtime/construct.rs | new, 650 lines  (plan objects, rt_construct, unit tests)
 native/src/nir.rs               | +485            (Construct inst, planregs/planresult, validate_plans, tests)
 native/src/codegen/clif.rs      |  +55            (construct codegen, generic-entry materialize)
 native/src/codegen/roots.rs     |   +3            (def/use, safepoint)
 native/src/runtime/{heap,metrics,value,ops,mod}.rs | +99 (GC mark/size/free, counters, kinds, helpers)
```

The eager concat implementation (`rt_str_cat`, `rt_list_append`, `op
strcat`/`op listappend`) is **byte-for-byte untouched**; where nothing is
virtual the lowering still emits exactly those ops, and
`-virtual-construction-opt 0` (or `BOTLISH_NATIVE_VIRTUAL_CONSTRUCTION_OPT=0`)
emits no `construct` instruction at all.

## Baseline concat complexity audit

Pinned before any change (`audit/m8a-virtual-construction/probes-baseline-pre.txt`,
`bench/virtual-construction.tcl` with no flag): every probe's copied payload
grows **exactly 4.00x per doubling of N** at every size (1000 -> 16000): the
O(N^2) prefix copying of an immutable accumulator. Result size grows 2x,
allocations 2x (one flat object per step). H1 is true as stated for every
recurrence shape measured: append, prepend, helper result appended, a
3-level helper chain appended, binding-carried, branch-carried, List append.

Mechanism, confirmed from the NIR and runtime: `rt_str_cat`/`rt_list_append`
are already optimal *per call* (one exact-size allocation, no rescan), but a
recurrence `f(i + 1, n, concat(acc, piece))` calls one per step, each
copying the whole growing prefix. `STRING-BYTES-CONSTRUCTION-AUDIT.md` had
already measured the same shape on `ai_text_clean` (5,000 MB copied for a
100K-character input); nothing in M1-M7 touched it, because none of them
changed how many times, or over what prefix, the eager op runs.

## Chosen construction-plan representation

Two levels, each used only where the other cannot work:

* **Compile-time pieces** (native/lower.tcl): while a construction stays
  inside one function's straight-line structure -- a nested concat tree, a
  binding, a branch value -- it is just an ordered list of already-evaluated
  registers: `{span REG}` (a flat String/List, or a plan register),
  `{region BASE START END}` (a validated StringRegion) and `{elem REG}` (one
  List element). No runtime object at all; its materialization is one n-ary
  `construct ... flat`.
* **Runtime plan objects** (runtime/construct.rs), needed only where a
  construction must cross a point a register list cannot: a self-tail back
  edge or direct call carrying it into a *plan parameter*, a *plan result*
  returned to an exact caller, an `if` join. Two new private heap kinds:
  * `StrPlanObj` -- a UTF-8 gap buffer: data in `buf[start..end]`,
    geometric growth toward whichever end is extended (appends leave no
    front slack, prepends no back slack; a fresh plan gets 8 bytes of front
    slack), incrementally maintained character count and ASCII flag. It
    holds **no Value**: a piece's bytes are copied in when it joins, so the
    piece object may die at once and the collector has nothing to trace.
  * `ListPlanObj` -- a growable `Vec<Value>` (append-only: `list_append` is
    the only List construction API), traced by the collector.

One NIR instruction does all construction, whatever its piece count:
`%d = construct str|list plan|flat PIECE...` (no `strcat2/3/4` zoo; arity is
never operation identity). `plan` builds a plan, or extends the first plan
piece *in place* (its "anchor": front pieces go into its front slack, later
ones onto its back); `flat` is the one materialization -- one allocation,
each piece copied once, byte-for-byte the object eager concat/list_append
would build (or, for a single flat piece, that piece itself).

Why this and not a segment list of references: the measured workloads'
pieces are overwhelmingly 1-3 bytes (`ai_text_clean`'s decoded characters,
the URI chain's `%`/hex digits). A reference-per-piece plan would keep every
one-character String alive until materialization (~48 bytes of header per
byte of payload) and give the collector one edge per piece; copying the
bytes in costs one small memcpy and frees the piece immediately. Total
payload copying stays O(N) either way (each byte is written into the plan
once, moved O(1) times amortized by geometric growth, and copied once more
by the final materialization) -- see the probes' copy columns. A naive
linked plan (one object per concat, spec item 42) was never built: the gap
buffer is the smallest append-efficient shape and the data show plan
management is not dominant (below).

## Why this is not laziness

Nothing is deferred except copying. Every piece is an ordinary value,
evaluated exactly where, and in exactly the order, the eager lowering
evaluates it: `ConstructPieces` lowers operand 1, then operand 2, then emits
the eager call's own argument kind guards on the same flat registers (only
a piece that stayed virtual skips a guard, and those are statically
String/List-typed by construction, so they never had one), and only then
continues. A plan local's pieces are all evaluated at its `bind`. A region
piece's bounds check (`regioncheck`) runs where the eager `substr` would.
Tests pin it (`vc-str-error-order-1/2`, `vc-str-error-midway-1`,
`vc-str-region-2`, `vc-str-error-handled-1`): piece 1 succeeds, piece 2's
error is the one reported everywhere, piece 3 never runs; a recurrence
failing at step 5 exposes no partial plan; a handled failure after a plan
argument was consumed recovers with the handler's own value.

The single failure eager concat/list_append can raise -- the
collection-length ceiling, `MAX_COLLECTION_LENGTH` = 2^62-1 characters/
elements -- is enforced by `construct` itself. In principle a multi-piece
flat construct reports it at the combined step rather than at the first
concat that crossed it; no allocatable String/List can reach 2^62 elements,
so this is unobservable, and it is the only place M8.a's evaluation
schedule differs even in principle.

## Why this is not loop recognition

There is no accumulator/loop pattern anywhere in `hir/construction.tcl` or
the lowering: the analysis only asks per-binding and per-instance questions
("is this binding referenced at most once along every path?", "does some
direct call pass a construction at this parameter?", "is this instance
closed, and is some call of it consumed in a plan position?"). A self-tail
recurrence `build(i + 1, n, concat(acc, x))` benefits only because `acc`
satisfies the same plan-parameter rule a non-recursive parameter does; the
same rule makes a non-tail recursion (`list_append(build(n - 1), n)`: a
plan *result* the caller extends), a helper chain, a branch join, and a
binding sequence virtual. The loop improved because its recurrence carried a
virtual construction, not because the compiler recognized an accumulator
idiom. No StringBuilder/ListBuilder surface or privileged lowering exists;
the collecting `listloop`'s own internal accumulator (a compiler-generated
`listappend` per iteration, e.g. in `byte::set`) is deliberately left eager
(M8.b scope). (Since then the collecting-loop lowering keeps that
accumulator in a List plan itself -- COLLECTING-LOOPS.md, "Native result
List" -- still with no recognizer here: the accumulator is not a binding.)

## Why this is not a source type

Plan state lives only in the lowering (`fn locals` tags `pieces`/`plan`, NIR
`planregs=`/`planresult=1`) and the runtime (two private heap kinds `kind_of`
refuses to classify). It never enters `hir::types`, `hir::specialize`'s
`KeyType`, admissibility or theorem comparison; "virtual", "flat", "unique"
and a plan's piece count are construction facts, not type facts. Tests pin
it: `vc-types-1`/`vc-types-2` compare the HIR type of every expression of
every used instance, every instance key and the function count with the
optimization on and off (identical); `[Int, Int]` keeps its ordinary
`List[int]` theorem, `[Int, "foo"]` stays the broad `list`, and no
`List[T, N]`-shaped type appears.

## String plan model

* **Pieces**: a flat String, an existing plan (consumed), or a StringRegion
  `(base, start, end)` -- a `substring` operand of a concat is never
  allocated as its own String (`vc-str-region-1`: 1 String instead of 2).
* **Concat semantics** (spec section 10): `concat(flat, flat)` -> pieces
  `[A, B]`; `concat(plan, x)` -> the plan extended at its back;
  `concat(x, plan)` -> the plan extended at its front (the gap buffer's
  front slack makes `reverse_from`'s prepend recurrence linear too);
  `concat(plan, plan)` -> the first extended with the second's bytes, the
  second consumed.
* **Unicode**: the plan works in the runtime's UTF-8 storage domain; its
  character count is the sum of its pieces' stored counts (a region's is
  `end - start`), its ASCII flag their conjunction, exactly as `rt_str_cat`
  computes them. Semantic indexing is untouched: plans are never indexed;
  anything that indexes materializes first. A non-ASCII region's byte span
  is located by the same forward seek (and `utf8SeekBytes` accounting)
  `rt_substr` performs. `vc-str-unicode-1` pins ASCII/BMP/astral pieces.
* **Final representation**: an ordinary `StrObj` built by
  `Vm::new_str_known`, indistinguishable from one `rt_str_cat` builds.

## List plan model

* **Pieces**: a leading List span (flat, or a plan consumed/extended) and
  elements (`list_append`'s second operand). `list_append` is the only List
  construction API, so a List plan only ever grows at its back.
* **Element theorem**: unchanged by construction -- plans are not types.
  `list_append` is only kept virtual when its List operand is statically
  List-typed (an untyped one keeps its eager, guarded `listappend`).
* **List[never]**: an empty literal `[]` is an ordinary flat span piece;
  `vc-list-empty-1` pins `[]`, a 0-step and a 3-step recurrence from `[]`.
* **Elements are GC-bearing**: `ListPlanObj`'s items are traced
  (`heap.rs`), `vc-list-gc-elements-1` builds a plan of freshly concatenated
  Strings under `BOTLISH_NATIVE_GC_STRESS=1`.
* **Final representation**: an ordinary `ListObj` via `Vm::new_list`.

## Uniqueness / fork semantics

A plan is extended in place, so it must have exactly one continuation.
`hir::construction::Linear` proves it per binding by counting, over the
binding's region, the most references evaluated along any normal or abrupt
path (`return`/`break`/`continue`/`fail`, and a `handle`'s handler after its
wrapped call): at most one per path. A reference inside a loop body the
binding is declared outside of counts as many; a capture by a nested block
disqualifies outright. Two exclusive branch references are fine (`if c:
return acc` / `f(concat(acc, x))` is the canonical recurrence).

**A fork is a materialization barrier** (spec item 13's preferred first
rule): `x = a + b; [x + c, x + d]` leaves `x` an ordinary flat value
(`vc-str-fork-1`, `vc-list-fork-1`; the analysis records the reason "fork:
referenced more than once on some path").

The runtime re-checks linearity twice over. `nir.rs`'s `validate_plans` runs
a forward "may have been consumed" dataflow over every function's CFG
(branches, back edges, handler spans) and rejects any NIR that could consume
a plan register twice; and every plan object carries a `consumed` flag that
makes a second read panic ("linearity violated") instead of silently reading
a stale plan. Neither has ever fired on lowered code.

## Materialization barriers

Every consumer that is not a plan position asks the ordinary `Expr` path
for a flat register, which materializes: a plan local's reference wanted
flat (`PiecesToFlat`), a plan parameter read flat (`construct ... flat` --
an identity pass-through when the argument was flat), a plan result
consumed by an ordinary use (`PlanCallResult`), a return from a
non-plan-result function. Audited barrier categories (census
`sites.txt`, per program):

| category | where it occurs in the corpus |
|---|---|
| return to exact callers that never extend the result | every recurrence's own exit (the one final materialization: `esc_from`, `clean_from`, `reverse_from`, `replace_from`, `scan_records`, `product_row(s)`) |
| storage into an aggregate (List element) | csv-family `scan_quoted`'s field and `scan_record`'s record, stored into the next level's List |
| flat-only native operation | `length(escaped)` in `repeat_uri` (via the materialized return), `encode_utf8(c)` |
| dynamic/open call | `hashtable`'s `ht_collect_pair` (reached only through `combine(...)`), `vc-str-open-1` |
| fork/shared use | none in the corpus; `vc-*-fork-*` |
| final observable result | the program value |
| unsupported branch join | none (joins are supported) |
| unknown escape (capture) | none in the corpus |

`nir.rs`'s `validate_plans` enforces the other direction structurally: a
plan register may be used only as a `construct` span piece, a `move` into
another plan register, an argument at a plan parameter (`call`/`callenv`/
`callmulti`/`tail`), or the `ret` of a `planresult=1` function. A guard, an
op, a native call, a dynamic call, a capture, a cell, a branch condition or
`retmulti` on a plan register is `NATIVE INVALID-NIR` (`vc-nir-2`..`6`, and
Rust unit tests). This caught one real lowering bug during development (a
plan passed to a scalar-replacement companion's `callmulti`, which the
first version of the validator did not yet allow) before it could run.

## Exact-call construction-summary mechanism

A **plan result** is the construction summary: "my result may be a
construction still in progress" crossing an exact call. It is given to an
instance that is (1) *closed* -- `hir::specialize::InstanceClosed`, M7.c's
own proof that every runtime route into it is a direct call this compilation
lowers -- (2) String/List-typed, and (3) called at least once in a plan
position. Its single compiled body (canonical and, for a Block-virtualized
instance, internal variant alike) `ret`s a maybe-plan register; every direct
caller's result register is a plan register, extended by a caller in a plan
position and materialized (`construct ... flat`) by any other.

Not inlining, not cloning, not re-specializing: the callee keeps its own
instance, key, and one compiled body; no companion function is emitted for
it; only its result's representation contract with its exact callers
changes. Its generic entry (the ordinary Value ABI, unreachable for a closed
instance) materializes defensively (`rt_plan_materialize`), and
`vc-nir-7` exercises exactly that path.

A **plan parameter** needs no closedness at all: it is "maybe-plan", so an
open caller or the generic entry simply passes an ordinary flat value, and
the body treats both alike.

Machine-call boundary (spec item 25): a pure compile-time summary suffices
inside one function, but the important cases genuinely need a private
runtime plan to cross calls -- a recurrence's plan crosses every self-tail
back edge, and `esc_bytes`'s runtime-built result crosses into `esc_char`
and `esc_from`. The private ABI is deliberate and checked: plan registers
are declared (`planregs=`, `planresult=1`), the validator types every call
edge, and nothing passes a plan where the ordinary String/List ABI is
expected. A fixed-shape callee summary (e.g. `hex_pair`'s exactly-two
pieces handed back as two registers, no object at all) would need a
multi-value return -- a second compiled variant of `hex_pair`, which spec
item 24 forbids; see "Residual materialization-barrier census".

Open/dynamic calls (spec item 26) materialize: an argument to `callvalue`
is always flat (`vc-str-open-1` pins the `construct ... flat` feeding the
`callvalue`), and an instance used as a Block value is not closed, so its
generic instance never returns a plan (in `vc-str-open-1` the exact-call
instance `wrap<str>` is a plan result, its value-used generic instance is
not).

## Runtime recurrence mechanism

`P0; P1 = concat(P0, X1); P2 = concat(P1, X2); ...` for a runtime-variable
count is a self-tail call carrying the plan in a plan-parameter register
across the back edge: iteration 1 turns the flat initial value into a fresh
plan (`construct str plan %acc %x`), every later iteration extends that same
object in place (`extensions` = N - 1, `plansCreated` = 1 in the probes),
and the exit materializes once. Growth is geometric (amortized O(1) per
byte/element; `growths` ~ log N). The same register carries the plan
through a binding sequence (`str_bind`), an `if` join (`str_branch`), and a
merge of a helper's own plan (`str_helper`, `str_chain3`).

## StringRegion interaction

A `substring` operand of a concat becomes a `region` piece: its three
operands are evaluated and bounds-checked exactly as the eager `substr`
would (`regioncheck` at the same point), but it is never allocated as a
String -- its bytes go straight into the construction. `string_replace`'s
`concat(done, substring(haystack, run_start, index))` is exactly this shape:
its 100 KB case drops from 6,694 allocations to 11. A substring bound to a
local and then concatenated is the same: `substring` is itself a one-piece
construction source, so `string_reverse`'s `character = substring(text,
index, index + 1)` / `concat(character, reversed)` never allocates the
character -- 10K characters: 20,023 allocations -> 11. StringRegion itself is
not redesigned; `hir::stringregion`'s own bindings/companions are left to
it (a binding it claims is never a plan local).

## URI helper chain analysis

Per `bench/uri-steady.bot`'s 2000 calls (4-string fixed corpus; census
`audit/m8a-virtual-construction/uri-steady/`):

| helper | Strings it constructs | where materialized before | after (plan state) | what remains |
|---|---|---|---|---|
| `hex_pair<generic>` | `concat(hex_digits[hi], hex_digits[lo])` | its own `strcat`, 6,500x | **plan result**: a fresh 2-byte plan per call (6,500 plans), returned to `esc_bytes` | a per-call private object: removable only by producer fusion / a fixed-shape multi-value return (forbidden: second variant) |
| `esc_bytes<generic>` | `concat(acc, concat("%", hex_pair(b)))` | 2 `strcat`s per escaped byte, 13,000x | `acc` **plan parameter**; the `"%"` and `hex_pair`'s plan are appended in place (first step anchors on `hex_pair`'s plan: no new object); **plan result** returned to `esc_char` | nothing materialized |
| `esc_char<generic>` | returns `c` or `esc_bytes(...)` | nothing of its own (forwards `esc_bytes`'s String) | **plan result**: forwards `esc_bytes`'s plan or the flat `c` | nothing |
| `esc_from<generic>` | `concat(acc, esc_char(c))` | 1 `strcat` per character, 14,000x | `acc` **plan parameter**; `esc_char`'s plan merged, a flat `c` appended; one fresh plan per call (2,000) | **one final materialization per call** (2,000), at its own exit |

* Intermediate String materializations on the path: **33,500 before, 0
  after** (per 2000 calls; the remaining 16,000 Strings are the 14,000
  `substring(text, i, i + 1)` characters -- `encode_utf8` needs them flat --
  and the 2,000 final results). Private plan objects: 8,500 (6,500
  `hex_pair` + 2,000 `esc_from` accumulators).
* String bytes copied: **176,000 before, 108,500 after** (the plan bytes
  include the final materialization and growth moves).
* Total allocations 61,510 -> 38,510; allocated bytes 2,544,568 ->
  1,970,568.
* Every helper stays `<generic>`; used instances 19/19, emitted functions
  17/17, guards 0/0 (`vc-identity-uri-1/2`). **Optimization quality became
  independent of specialization identity**: exactly the M-series lesson,
  now applied to construction state.

## List/multiple-return audit

**Repeated List construction in the frozen corpus** (not fabricated -- all
measured): `csv`'s `scan_records` (records, N rows) and `scan_record`
(fields, 4 per row) recurrences; `matmul`'s `product_row`/`product_rows`;
`csv_chunked`'s `chunked_append` completed-chunk list. All become plan
parameters/locals. `csv` 10,000 rows is the one where List copying
dominated: 50,065,012 List elements copied before, 56,390 after.
`csv_geometric`/`csv_records` already build with a MutableArray
GeometricBuilder (no List recurrence; only their quoted-field String
accumulator is affected). `hashtable`'s `list_append(acc, [key, value])`
runs only inside a Block reached through a dynamic call (`combine(...)`),
so it correctly stays eager. `matmul`'s rows are 2-32 elements: no
measurable effect. No benchmark's time is dominated by List construction
other than `csv`.

**Multiple-return (product-shaped) census** (`products.txt` per program;
spec items 55-57, no source change, no type change):

| site | shape | instance result / element theorem | exact callers | verdict |
|---|---|---|---|---|
| `csv.bot:37` `scan_unquoted` -> `[field, index]` (also `csv_chunked`, `csv_geometric`, `csv_records`) | 2 | `list[str, int]`; theorem `any` | forwarded by `scan_field`, bound by `scan_record`, read only as `list_get(_, 0)`/`list_get(_, 1)` | struct |
| `csv.bot:49` `scan_quoted` -> `[field, index + 1]` (same 4 programs) | 2 | `list[str, int]`; `any` | same | struct |
| `csv.bot:71/73` `scan_record` -> `[more, stop]` (csv, csv_chunked) | 2 | `list[List[str], int]`; `any` | `scan_records`: `list_get(_, 0/1)` only | struct |
| `csv_geometric.bot:54` etc. `geo_append`/`geo_new` -> `[storage, length]` (csv_geometric, csv_records) | 2 | `list[mutarray, int]`; `any` | passed on as builder state, read by `geo_finish` via `list_get(_, 0/1)` | struct (builder state record) |
| `csv_chunked` builder state `[completed, current, length]` | 3 | `list[List[mutarray], mutarray, int]`; `any` | passed on as state | struct |
| `hashtable.bot:374`, `csv_records.bot:453` `sample` -> 6/7-field demo result | 6-7 | `list[bool, ..., any]` | the program value | not a product (demo output) |

Every one of them **broadens the element theorem to `any`** (distinct field
types) -- exactly H2's hypothesized cost -- and every exact caller reads
fixed positions only. They are future struct refactors; M8.a changes none
of them and adds no typing for them. (Nearly all are already scalar-
replaced by `hir/escape.tcl`'s companion functions, so no List is even
allocated for their exact callers; the positional `list[...]` shape shown
above is a *pre-existing*, specialization-only, bounded aggregate fact of
`hir/types.tcl` -- `{list ELEM {P0 P1 ...}}` -- identical with M8.a on and
off, neither added nor consumed here.) Homogeneous `[x, x + 1]` keeps an
ordinary `List[int]` theorem (`vc-types-1`).

Where a product-shaped List meets a construction plan (`csv`'s field String
and record List stored into `[field, index]`/`[more, stop]`), the plan is
materialized at the storage -- "storage into an aggregate" in the barrier
census. Keeping it virtual through `hir/escape.tcl`'s scalar-replaced
fields is possible in principle (M8.b); with structs it would be ordinary.

## Scaling probes before/after

`bench/virtual-construction.tcl` (added): eight ordinary-source probes whose
repeat count N is a runtime argument of a self-recursive function; each
builds one String/List by ordinary concat/list_append and observes it once
(`length`/`list_length`). Cranelift, specialized, best of 5 runs, JIT
excluded; full output in `audit/m8a-virtual-construction/probes-opt{0,1}.txt`
(and the pre-implementation baseline, `probes-baseline-pre.txt`, identical
counts to `-opt 0`).

Copy volume -- the primary evidence (String bytes / List elements copied):

| probe | N=1000 off | N=1000 on | N=16000 off | N=16000 on | growth per 2x N, off -> on |
|---|---:|---:|---:|---:|---|
| `str_append` (`concat(acc, "ab")`) | 1,001,000 | 7,528 | 256,016,000 | 121,272 | 4.00x -> 2.00x |
| `str_prepend` (`concat("ab", acc)`) | 1,001,000 | 7,538 | 256,016,000 | 121,282 | 4.00x -> 2.00x |
| `str_helper` (`concat(acc, piece(i))`, piece a 3-piece concat) | 1,506,500 | 12,765 | 384,104,000 | 205,341 | 4.00x -> 2.00x |
| `str_chain3` (`concat(acc, c(i))`, c/b/a helper chain) | 2,011,000 | 16,004 | 512,176,000 | 257,412 | 4.00x -> 2.00x |
| `str_bind` (`x = concat(acc,"a"); y = concat(x,"b")`) | 2,001,000 | 7,528 | 512,016,000 | 121,272 | 4.00x -> 2.00x |
| `str_branch` (branch-local concats joined) | 1,501,500 | 7,528 | 384,024,000 | 121,272 | 4.00x -> 2.00x |
| `list_append` (`list_append(acc, i)`) | 499,500 | 2,020 | 127,992,000 | 32,380 | 4.00x -> 2.00x |
| `list_append2` (two appends per step) | 499,500 | 2,020 | 127,992,000 | 32,380 | 4.00x -> 2.00x |

Allocations and time at N = 16000 (final run):

| probe | allocations off | allocations on (flat + private plans) | plan extensions / materializations | time off | time on | speedup |
|---|---:|---:|---|---:|---:|---:|
| `str_append` | 16,000 | 2 (1 + 1) | 15,999 / 1 | 14.24 ms | 0.59 ms | 24.3x |
| `str_prepend` | 16,000 | 2 (1 + 1) | 15,999 / 1 | 8.45 ms | 0.76 ms | 11.2x |
| `str_helper` | 48,001 | 16,002 (2 + 16,000) | 16,000 / 1 | 18.05 ms | 2.45 ms | 7.4x |
| `str_chain3` | 64,001 | 16,002 (2 + 16,000) | 48,000 / 1 | 17.96 ms | 3.60 ms | 5.0x |
| `str_bind` | 32,000 | 2 (1 + 1) | 15,999 / 1 | 16.62 ms | 0.63 ms | 26.4x |
| `str_branch` | 24,000 | 2 (1 + 1) | 15,999 / 1 | 12.08 ms | 0.60 ms | 20.0x |
| `list_append` | 16,001 | 3 (2 + 1) | 15,999 / 1 | 83.99 ms | 0.49 ms | 171x |
| `list_append2` | 16,001 | 3 (2 + 1) | 7,999 / 1 | 89.99 ms | 0.24 ms | 371x |

Time now scales like copy volume: `str_append` 40.4 -> 586 us for 16x N
(14.5x) with the optimization on, 94.3 us -> 14.24 ms (151x) off. The eager
baseline's large-N *timings* vary between full runs (e.g. `str_append`
N = 16000 took 8.2 ms in one run and 14.2 ms in another, `str_prepend`
15.1 vs 8.5 ms) while its copy volume is exactly reproducible -- which is
why copy volume, not time, is the primary evidence here. The remaining
per-step plan objects in `str_helper`/`str_chain3` are each helper call's
own fresh plan (its construction summary crossing the call), absorbed into
the accumulator: one private object per call instead of one flat String
per concat (48,000 -> 16,000 objects, 0 intermediate flat Strings). The
copy numbers include everything: bytes written into the plan,
geometric-growth moves, and the final materialization (e.g. `str_append`
N = 16000: 32,000 output bytes, 121,272 copied = 3.8 bytes per output
byte).

Plan management is not the new dominant cost (spec items 34, 42): at the
smallest size, where copying is cheapest for the eager baseline, the plan
version is still faster on every probe (e.g. `str_append` N=1000: 94.3 ->
40.4 us, `list_append` 203.9 -> 29.8 us).

## Allocation/copy-volume before/after, and frozen workload timing

`audit/m8a-virtual-construction/tools/workloads.tcl` (added; output in
`workloads.txt`): identical source and binary, `-virtual-construction-opt`
0 vs 1, median of 5 independent `native::measure` sessions x best of 5 runs,
JIT excluded (the established `bench/uri-steady.tcl` methodology), measured
on an otherwise idle host. Corpus inputs are `bench/corpus.tcl`'s own
deterministic drivers; `ai_text_clean` uses `bench/ai_text_clean.tcl`'s
fixture families. Program values are identical off/on for every row.

| workload | time off | time on | speedup | allocations off -> on | allocated bytes off -> on | String allocs off -> on (+ private plans) | String bytes copied off -> on | List elems copied off -> on |
|---|---:|---:|---:|---|---|---|---|---|
| `ai_text_clean` ascii 100K chars | 157.02 ms | 25.06 ms | **6.27x** | 200,111 -> 100,070 | 5,008 MB -> 4.2 MB | 200,110 -> 100,062 (+7) | 5,000,150,383 -> 406,628 | 6 -> 6 |
| `ai_text_clean` emoji 100K chars | 174.49 ms | 24.36 ms | **7.16x** | 200,111 -> 100,070 | 5,601 MB -> 4.3 MB | 200,110 -> 100,062 (+7) | 5,593,385,128 -> 579,604 | 6 -> 6 |
| `ai_text_clean` ascii 10K chars | 5.88 ms | 2.22 ms | **2.65x** | 20,111 -> 10,070 | 50.8 MB -> 0.42 MB | 20,110 -> 10,062 (+7) | 50,015,383 -> 43,450 | 6 -> 6 |
| `string_reverse` 10K chars | 4.30 ms | 0.38 ms | **11.26x** | 20,023 -> 11 | 50.8 MB -> 10.8 KB | 20,022 -> 5 (+5) | 50,015,043 -> 31,261 | 5 -> 5 |
| `string_replace` 100 KB | 21.37 ms | 1.76 ms | **12.13x** | 6,694 -> 11 | 252.3 MB -> 0.11 MB | 6,693 -> 6 (+4) | 251,985,950 -> 434,587 | 5 -> 5 |
| `csv` 10,000 rows | 133.93 ms | 53.63 ms | **2.50x** | 497,818 -> 288,922 | 422.3 MB -> 13.1 MB | 437,798 -> 248,904 (+20,006) | 2,433,615 -> 753,405 | 50,065,012 -> 56,390 |
| `csv_geometric` 10,000 rows | 70.80 ms | 52.01 ms | 1.36x | 487,837 -> 308,943 | 22.4 MB -> 13.9 MB | 437,798 -> 248,904 (+10,000) | 2,433,615 -> 753,405 | 0 -> 0 |
| `csv_chunked` 10,000 rows | 82.80 ms | 52.38 ms | 1.58x | 478,134 -> 299,240 | 27.0 MB -> 18.5 MB | 437,798 -> 248,904 (+10,000) | 2,433,615 -> 753,405 | 12,090 -> 12,090 |
| `matmul` 32x32 | 168.4 us | 150.4 us | 1.12x | 1,171 -> 181 | 184.6 KB -> 31.6 KB | 0 -> 0 (+36 ListPlans) | 0 -> 0 | 18,500 -> 4,115 |
| **`uri-steady`** (2000 calls) | 5.18 ms | 4.44 ms | **1.17x** | 61,510 -> 38,510 | 2.54 MB -> 1.97 MB | 47,500 -> 16,000 (+8,500) | 176,000 -> 108,500 | 16,534 -> 16,534 |
| `refined-checks` | 333.4 us | 327.9 us | 1.02x | 23 -> 20 | 1,085 -> 1,064 B | 9 -> 4 (+2) | 21 -> 16 | 35 -> 35 |
| `fib` (control, no construction) | 132.0 us | 136.9 us | 0.96x | 0 -> 0 | -- | -- | -- | -- |
| `loop-count` (control) | 1.0 us | 1.0 us | 1.00x | 0 -> 0 | -- | -- | -- | -- |
| `sum-refined` (control) | 0.6 us | 0.6 us | 1.00x | 0 -> 0 | -- | -- | -- | -- |

(`fib`'s 0.96x is noise: its NIR and 394 machine-code bytes are identical
off and on.)

`bench/ai_text_clean.tcl` itself, unmodified, run under
`BOTLISH_NATIVE_VIRTUAL_CONSTRUCTION_OPT=0/1` (`ai_text_clean-opt{0,1}.txt`)
agrees: 100K ascii 156.91 -> 23.33 ms, punctuation 169.56 -> 23.98 ms,
emoji 169.90 -> 25.02 ms; per 10x input (10K -> 100K), copied bytes grow
98.5x off vs 9.9x on, and time 26.0x off vs 11.2x on.

`bench/uri-steady.tcl` itself, unmodified, 7 runs x 5 sessions, in two
separate batches of alternating off/on invocations: off medians 5,150.50 /
5,058.69 / 5,289.59 / 5,054.98 us, on 4,021.80 / 4,009.90 / 3,978.48 /
4,104.60 us -- **-17% to -22%** (`workloads.tcl`'s own run above: 1.17x).
(callgrind, JIT compilation included, 5 runs: 305.1 M -> 285.3 M
instructions, -6.5%; the larger time gain is consistent with the 23,000
fewer heap objects per run -- malloc/free and collection work are
memory-bound -- but that attribution is an inference, not a measurement.)

## Generic-helper identity before/after, and the M-series history

`uri-steady.bot`, the four URI helpers, from the reports' own recorded
artifacts (M7.a/M7.c's `functions.txt`, M0/M1/M3's timing tables) plus this
milestone's census; guard counting differs across early reports (M0/M1
counted `guard int` NIR ops only, later ones every guard), noted per row:

| milestone | helper identity | whole-program guards | whole-program machine bytes | `hex_pair`/`esc_bytes`/`esc_char`/`esc_from` bytes (guards) | intermediate String materializations / 2000 calls | median time |
|---|---|---:|---:|---|---:|---:|
| M0 | `<generic>` | 10 (`guard int`) | 8,167 | -- | 33,500 | 5,658.74 us |
| M1 | `<generic>` | 7 (`guard int`) | 7,155 | -- | 33,500 | 5,440.06 us |
| M2 | `<generic>` | -- | -- | -- | 33,500 | 5,123.96 us |
| M3 | `<generic>` | -- | 7,111 | -- | 33,500 | 6,136.44 us (M3's own run was contended; its report says so) |
| M7.a (= pre-M7.c) | `<generic>` | 14 | 7,055 | 484 (1) / 864 (3) / 516 (1) / 1004 (4) | 33,500 | -- |
| M7.c | `<generic>` | **0** | **5,746** | 378 (0) / 624 (0) / 448 (0) / 620 (0) | 33,500 | -- |
| M8.a off (today's tree) | `<generic>` | 0 | 5,746 | identical to M7.c | 33,500 | 5,055-5,290 us |
| **M8.a on** | **`<generic>`** | 0 | 6,145 | 453 (0) / 758 (0) / 486 (0) / 772 (0) | **0** (+8,500 private plans) | **3,978-4,105 us** |

Identity remained `<generic>` through every milestone; facts and code
improved substantially (M1-M7.c: guards 14 -> 0, machine code 8,167 ->
5,746 bytes); runtime moved little (5,659 -> ~5,150 us, ~10%, inside the
host's session noise for most individual steps). Materialization never
moved at all until M8.a, which takes it to zero on this path and moves
runtime by 17-22% -- the largest single step in the series -- **without**
changing identity (still `<generic>`, 19 used instances, 17 functions).

## Machine-code/guard effects

Guards: unchanged everywhere (0 -> 0 on `uri-steady`, 3 -> 3 on
`refined-checks`, every corpus program identical): plan values are
statically String/List-typed by construction, and an untyped concat operand
keeps its eager call's own guard (`vc-str-guarded-1`).

Machine code: `construct` builds a small stack array of piece words and
calls one helper (the eager op passed two registers), so every
construction-heavy function grows; NIR function counts are unchanged
everywhere. Whole-program machine-code bytes, off -> on (census
`functions.txt`, per function detail there):

| program | off | on | change |
|---|---:|---:|---:|
| `uri-steady` | 5,746 | 6,145 | +6.9% |
| `refined-checks` | 14,898 | 15,289 | +2.6% |
| `ai_text_clean` (demo driver) | 3,003 | 3,209 | +6.9% |
| `string_reverse` | 798 | 990 | +24.1% |
| `string_replace` | 2,322 | 2,618 | +12.7% |
| `csv` | 4,731 | 5,723 | +21.0% |
| `csv_geometric` | 5,333 | 5,626 | +5.5% |
| `csv_chunked` | 10,103 | 10,364 | +2.6% |
| `csv_records` | 21,624 | 21,917 | +1.4% |
| `matmul` | 4,160 | 4,734 | +13.8% |
| `hashtable` (no construction recognized) | 12,868 | 12,868 | 0 |

This is the cost side of the experiment; every program with the larger
growth is also one with a large runtime gain.

## GC/rooting consequences

Plans are ordinary heap objects in ordinary registers, so they are rooted by
the existing precise machinery (shadow stack / native stack maps) exactly
like any Value; `construct`'s operands are safepoint `LiveIn` like every
allocating op's (`roots.rs` def/use updated), so every piece -- String
owners, region bases, List sources, plan objects -- stays rooted for the
whole helper call. The collector marks a `ListPlanObj`'s items; a
`StrPlanObj` holds no Values. `object_size`/`free_object` know both kinds;
buffer growth is reported to the collection threshold
(`Heap::note_growth`). The one place a plan could meet code without stack
maps -- a plan-result function's generic entry -- roots it through
`temp_roots` while materializing.

`BOTLISH_NATIVE_GC_STRESS=1` (collect before every allocation) runs the
whole suite (below) plus focused tests of String plans (append, prepend,
regions, merges, plan results), List plans holding GC-bearing Strings, and
the URI chain.

## Focused tests

`tests/virtual-construction.test` (new, **44 tests**). Every value test is
differential across interp, compile, cranelift-generic, and cranelift with
`-virtual-construction-opt 0` and `1`:

* String (spec item 68): two flat strings (exactly the eager `strcat`);
  nested concat tree (one 4-piece flat construct, 1 String vs 3); StringRegion
  + String (1 String vs 2) and a region bound to a local first (reverse's
  shape: 1 String vs 12); region bounds error; binding across concat; fork
  -> materialization (reason recorded); branch join; runtime loop (linear vs
  quadratic copying, N and 4N); prepend recurrence; exact helper result;
  3-level helper chain (1 materialization vs 3); open-call barrier; empty
  pieces/accumulators/results; 1 MB result from 64 KB pieces; ASCII/BMP/
  astral pieces; error order (piece 1 ok, piece 2 errors, piece 3 never
  runs, the same message everywhere); an error midway through a recurrence;
  a handled failure after a plan argument was consumed; an untyped operand
  keeping its guard; an 11-piece construction (the runtime's spill path);
  top-level plan locals.
* List (spec item 69): List + element (exactly the eager `listappend`);
  nested appends (one flat construct); binding; fork; runtime loop (linear);
  exact helper returning a plan to its non-tail recursive caller; `[]` /
  List[never] starts; GC-bearing String elements under GC stress.
* Negative controls and invariants (items 70-72, 80): `[Int, Int]` keeps
  `List[int]`, `[Int, "foo"]` stays broad `list`, no arity type anywhere;
  every expression type, instance key and function count identical on/off;
  `uri-steady`'s four helpers stay `<generic>` with instance and function
  counts unchanged while String allocations fall 47,500 -> 16,000; which
  URI helpers are plan results/parameters.
* NIR plan discipline: a well-formed plan program; plan into an ordinary op;
  double consumption; plan `ret` without `planresult`; flat/plan construct
  destination mismatch; exclusive branches vs a join reuse; a plan-result
  function reached through its generic entry (materializes).
* GC stress: String plans (append, prepend, regions, merges, plan results)
  and the URI chain under `BOTLISH_NATIVE_GC_STRESS=1`.

Rust unit tests (`cargo test --release`): **69 passed** (60 existing + 9 new:
gap-buffer growth at both ends, linear amortized growth, the consumed-plan
tripwire, NIR `construct` parsing, family-specific pieces, plan-position
discipline, per-path linearity, self-tail redefinition).

Pre-existing tests changed (5 tests, 3 files, no expectation weakened):

* `native-alloc.test` `alloc-copies-2`, `alloc-sites-1`, `alloc-stress-1`
  and `native-string-traversal.test` `traversal-string-copy-accounting-1`
  test the *eager* ops' own accounting (rt_list_append's copy count, two
  distinct strcat sites, "every allocation is a List" under stress, the
  decodecharat/strcat byte reconciliation): pinned to
  `-virtual-construction-opt 0`, so they keep testing exactly what they
  were written for; the plan-mode counterparts are the new file's.
* `native-block-escape.test` `blockescape-region-companion-refined-checks-1`
  (subject: Block allocations, unchanged at 2) pins whole-program totals:
  updated to the new default, String 9 -> 4, total 23 -> 20, with the
  reason recorded in the test's comment.

## Full regression

`LANG=C.utf8 LC_ALL=C.utf8 tclsh9.0 tests/all.tcl` (both backends the
harness runs, `interp` and `compile`, each driving the native cases):

| run | files | interp | compile |
|---|---:|---:|---:|
| before M8.a (tree at the branch point) | 81 | 2298/2298 | 2298/2298 |
| after M8.a, normal | 82 | **2342/2342** | **2342/2342** |
| after M8.a, `BOTLISH_NATIVE_GC_STRESS=1` | 82 | **2342/2342** | **2342/2342** |

2342 = 2298 pre-existing + 44 new (`virtual-construction.test`); 0
skipped, 0 failed. `cargo test --release --manifest-path
native/Cargo.toml`: **69 passed**, 0 failed (60 existing + 9 new). Both
final suite runs started after the last source edit; the release backend
is the one built from this tree.

Intermediate runs during development that briefly showed failures in
`ascii.test`, `byte-set.test` or `applied-types.test` were two suites
running concurrently in one checkout and colliding on the fixed-name temporary
`.bot` files those tests write into the working tree (`makeFile`, e.g.
`byte-set-canonical.bot`, `refined-signature-load-byte.bot`); each of
those files passes on its own and in every uninterrupted full run, and none
of the failures involved construction. They are not counted above.

M1-M7.c.1 controls (spec item 79), all inside the full run and each also
run on its own: `conjunctive-entry-facts` 28/28, `empty-collection-
admissibility` 24/24, `symbolic-type-identity` 13/13, `hir-specialize`
27/27, `hir-range` 52/52, `hir-callable-target` 8/8, `typed-parameters`
50/50, `checked-domain-proof-provenance` 17/17, `hir-closed-call-params`
15/15, `typed-callable-escape` 35/35, `native-block-escape` 48/48,
`native-escape` 22/22, `native-uri-escape` 18/18, `source-types` 46/46,
`hir-aot` 32/32, `close-callers-convergence` 24/24 (M7.c.1's rollback),
`closed-closure-entry-facts` 32/32, `native-string-region` 26/26,
`native-string-view` 17/17, `applied-types` 51/51, `immutable-set` 68/68,
`loop-in` 31/31 (listloop), `lists` 12/12, `stdlib` 152/152.

## Abort/keep decision

**Keep, default on.** Against spec item 89's stop conditions:

1. General value propagation, not loop recognition -- yes (bindings,
   branches, helpers, non-tail recursion, and recurrences all by the same
   rules; no idiom matcher exists).
2. Source evaluation/error order unchanged -- yes (tests; the only
   theoretical difference is the unreachable 2^62 length ceiling's
   reporting step).
3. Final String/List representations unchanged -- yes (`new_str_known`/
   `new_list`; parity everywhere).
4. Runtime-variable chains stay virtual -- yes (plan parameters across
   self-tail back edges).
5. Exact helper boundaries preserve construction -- yes (plan results; the
   3-level chain materializes once).
6. Dynamic/open boundaries materialize -- yes (`vc-str-open-1`; open
   instances never return plans; generic entries materialize).
7. No specialization identity encodes plan state -- yes (keys, instance and
   function counts identical on/off).
8. No fixed-arity type -- yes.
9. Major algorithmic copy reduction -- yes: 4.00x -> 2.00x per doubling on
   every probe; up to 4,200x fewer bytes copied at N = 16000.
10. Intermediate allocation falls dramatically -- yes (e.g. 16,000 -> 2
    objects; `string_replace` 6,694 -> 11; `string_reverse` 20,023 -> 11;
    URI path 33,500 -> 0 intermediate Strings).
11. Substantial workload gains -- yes: `string_replace` 100 KB 12.1x,
    `string_reverse` 10K 11.3x, `ai_text_clean` 100K 6.3-7.2x, `csv`
    10,000 rows 2.5x, `uri-steady` 17-22% -- none of them noise-sized; the
    concat-free controls sit at 0.96-1.00x.
12. Full correctness and GC regressions pass -- yes (above).
13. Frozen source unchanged -- yes: no `.bot`/`.ir`/`lib/*.bot` file
    changed.

Is the gain large enough to justify a permanent compiler abstraction?
**Yes, plainly.** It is not "machine code shrank / a few percent": it
changes an algorithmic complexity class on every recurrence shape, turns
multi-GB copy volumes into KB, speeds up four of the frozen corpus
programs by 2.5-12.1x, and the URI benchmark by 17-22% -- the benchmark
every M-series milestone restructured without moving.

Costs, stated plainly: +1.4% to +24% machine code on construction-heavy
programs; ~4-48 ms more lowering time for the analysis (3-8% of native
lowering on the frozen corpus); a new instruction, two private heap kinds
and a NIR validator pass to maintain; no benefit under cranelift-generic
for recurrences (its unspecialized parameters are untyped, so they are
never plan parameters -- only its tree/binding flattening applies).

## Residual materialization-barrier census

Remaining materializations on the primary workloads, categorized (spec
items 73-74; per-site detail in each census `sites.txt`):

| workload | remaining allocation / copy | category |
|---|---|---|
| every recurrence | one flat String/List at the recurrence's exit (`esc_from`, `clean_from`, `reverse_from`, `replace_from`, `scan_records`) | final observable result / return to exact callers that never extend it -- the one materialization the semantics require |
| `uri-steady` | `hex_pair`'s fresh plan per escaped byte (6,500 / 2000 calls), absorbed (copied) into `esc_bytes`'s accumulator | **producer fusion residual** (a destination-passing `hex_pair`, or a fixed-shape multi-value return -- a second variant -- would remove it) |
| `uri-steady` | `esc_bytes`'s plan absorbed into `esc_from`'s (merge copy) | producer fusion residual |
| `uri-steady` | 14,000 one-character `substring`s | flat-only native operation (`encode_utf8(c)` needs a String) |
| `uri-steady` | 14,000 `encode_utf8` Lists | producer (not a construction; out of scope) |
| `ai_text_clean` | 100,000 one-character Strings from `peek` (`decodecharat`), each copied into the plan | **producer fusion residual** (the character passes through `clean_char` unchanged; only destination passing, or a region-valued traversal access, removes it) -- now 99.9% of its remaining allocations |
| `csv` family | quoted field Strings and record Lists stored into `[field, index]`/`[more, stop]` | storage into an aggregate (a product-shaped List, itself scalar-replaced by `hir/escape.tcl`) |
| `hashtable` | `list_append(acc, [key, value])` | dynamic/open call (`combine(...)`) |
| `byte::set` | collecting `listloop`'s own `listappend` accumulator | not attempted (compiler-generated construction inside a built-in loop form) |

No barrier is unexplained; no fork, unsupported join or unknown escape
occurs in the frozen corpus.

## Recommended M8.b scope (justified by the census above)

1. **Plans through scalar-replaced product fields**: let a plan cross
   `hir/escape.tcl`'s virtual `[field, index]` fields (csv family), or --
   better, and the planned source repair -- through struct fields once
   structs exist.
2. **Collecting `listloop` accumulator** as a List plan (the same
   `construct list plan`/`flat` pair; `byte::set` and any source
   `listloop`).
3. **Producer fusion for the measured residuals**, in order of measured
   weight: a region/char-valued traversal access flowing into a plan
   (`ai_text_clean`: 100,000 of 100,070 allocations), then destination
   passing for small fixed-shape helpers (`hex_pair`).
4. Not recommended from this evidence: plan-aware `length`/equality/
   indexing (no workload's plan is observed that way before its one
   materialization), general ropes, fork sharing (no fork in the corpus).

## Required architecture questions

1. **Layer?** Two: compile-time pieces in native lowering (native/lower.tcl,
   decided by hir/construction.tcl over specialized HIR), and a private
   runtime plan object (runtime/construct.rs) only where a construction
   crosses a back edge, an exact call, or a join -- carried in declared NIR
   plan registers.
2. **A Botlish semantic type?** No.
3. **What is delayed?** Materialization/copying only; every piece is
   evaluated strictly, in the original order.
4. **String segment kinds?** Flat String, existing plan (consumed),
   StringRegion `(base, start, end)`; literals are flat Strings.
5. **List segment kinds?** A leading List span (flat or plan) and single
   already-evaluated elements.
6. **Runtime-variable concatenations?** A plan parameter carries one runtime
   plan object across every self-tail back edge; each step extends it in
   place (amortized O(1) per byte/element); the exit materializes once.
7. **Without recognizing a loop idiom?** Yes.
8. **Unique continuation proven how?** `Linear`: at most one reference per
   execution path over the binding's region (loops, abrupt completions and
   handlers counted), no capture; re-checked by nir.rs's per-path
   consumption dataflow and a runtime consumed-flag tripwire.
9. **At a fork?** The binding is not a plan; it is materialized once, as
   eager lowering always did.
10. **What materializes a plan?** Any consumer that is not a plan position:
    a flat-only native, a List element/Result payload, a dynamic call, an
    exact call to a non-plan parameter, a return from a non-plan-result
    instance, the program result, an `if` condition, a loop body value.
11. **Survive a local function abstraction?** Yes (plan results/parameters).
12. **Survive an exact call?** Yes, both directions (argument into a plan
    parameter; result out of a closed plan-result instance).
13. **Construction summary or inlining?** Summary: the callee keeps its own
    instance and single compiled body; no body is copied, no variant added.
14. **Do hex_pair/esc_bytes/esc_char/esc_from remain `<generic>` while plans
    propagate?** Yes, all four.
15. **At an open/dynamic call?** Materialize (arguments are flat; an
    instance reachable that way never returns a plan).
16. **Any specialization key with virtual/flat state?** No.
17. **URI intermediate String materializations before?** 33,500 per 2000
    calls (16.75 per call).
18. **After?** 0 (plus 8,500 private plan objects: 6,500 `hex_pair`
    results, 2,000 `esc_from` accumulators).
19. **String bytes copied before/after?** 176,000 -> 108,500 per 2000 calls
    (URI; tiny strings). On concat-heavy workloads: e.g. `ai_text_clean`
    100K 5,000,150,383 -> 406,628; `string_reverse` 10K 50,015,043 ->
    31,261.
20. **StringRegion virtual through concat?** Yes -- directly as an operand
    and through a binding (region pieces).
21. **Final String representation unchanged?** Yes.
22. **Unicode/String semantics unchanged?** Yes.
23. **Repeated List copies in the focused probe before/after?** N = 16000:
    127,992,000 -> 32,380 elements copied; 16,001 -> 3 allocations.
24. **Final List representation unchanged?** Yes.
25. **List[never] unchanged?** Yes.
26. **Homogeneous `[x, y]` keeps `List[Int]`?** Yes (`pair<int>` ->
    `List[int]`).
27. **Heterogeneous `[x, "s"]` stays broad?** Yes (`list`).
28. **Any fixed-arity List type?** No (the pre-existing specialization-only
    positional aggregate fact is untouched and unconsumed).
29. **Copy growth before?** Quadratic: exactly 4.00x per doubling of N.
30. **After?** Linear: exactly 2.00x per doubling.
31. **O(n^2) hypothesis supported?** Yes, fully, for every recurrence shape.
32. **If not, what dominates?** n/a -- it did dominate wherever strings/lists
    grow beyond tens of elements.
33. **Runtime consistent with copy volume?** Yes: probe time scales ~2x per
    doubling on, 3-5x off; workload speedups track removed copy volume.
34. **Plan management dominant?** No: plans beat eager even at the smallest
    sizes (N = 1000); on the tiny-string URI workload callgrind puts
    `rt_construct` at ~12% of instructions, well below malloc/free combined
    (~30%). (An early version's per-call temporaries made it heavier than
    eager there -- 354.5 M vs 305.1 M instructions -- which is why the
    runtime decodes pieces into an inline array and copies straight into
    the anchor: 285.3 M in the final version.)
35. **Do the M-series' improved-but-generic helpers finally produce a large
    end-to-end speedup?** A real one: `uri-steady` 17-22% faster (the
    series' largest single step), still `<generic>`. Large (2.5-12.1x) on
    the concat-heavy corpus programs.
36. **Was materialization hiding the M-series gain?** Partly. On the URI
    path, M1-M7.c removed guards and code (14 -> 0 guards, -30% code) for
    ~10% time; removing the materializations gives another 17-22%. The
    rest of uri-steady's time is not construction at all (per-character
    substring/`encode_utf8`/classification calls and their 28,000
    remaining allocations per 2000 calls).
37. **New dominant-cost hypothesis?** Producers of complete temporaries:
    one-character Strings from traversal/substring and the `encode_utf8`
    List per character -- allocation count, not copy volume. That is
    producer fusion's territory (M8.b item 3).
38. **Worth retaining permanently?** Yes.
