# POST-STRUCTURAL-FN DYNAMIC CALLABLE CENSUS


## Outcome

**9 compiled sites, 7 unique source expressions, 8,317 indirect calls per natural corpus run.**
`refined-checks.bot`'s scanner contributes 8,000 calls (96.1885%).
The three higher-order benchmarks contribute 317 calls; `uri-steady.bot`'s
compiled scanner never executes. No example adds an indirect call.

The audit can statically prove singleton code-target sets at 5 sites covering
101 executions (1.2144%). Sets of at most two cover 8 sites and
8,233 executions (98.9900%); four cover all 9 and all 8,317.
These proofs come from frozen HIR and closed source provenance, independently
of runtime observations. No target facts are fed back into the compiler.

The old exact-target oracle control remains economically significant:
**1,439,963 fewer foreground Ir/run (17.4572%)**
on current surface `refined-checks.bot`, with 1,200 fewer String allocations.
This is not a predicted finite-set lowering speedup. Measured existing callable
machinery across the corpus is 401,467 Ir; caller setup, `apply_op` dispatch,
and callee bodies are excluded from that deliberately partial attribution.

## Measurement boundary and compiler/source freeze

One natural run executes each executable source program once with its own
unchanged inputs. This is a corpus sum, not a frequency estimate for all Botlish
programs. The corpus has 31 source files and 30 executable programs. The declared
duplicate-binding error example is listed but has no executable sites.

Only this report and `audit/post-structural-fn-dynamic-census/` are added.
No production compiler, library, canonical source, scalar baseline, or historical
audit is edited. HIR, specialization keys/instances, lowering, NIR, representation,
allocation policy and register allocation retain their production behavior.
Counter hooks exist only in a scratch native crate, behind `BOTLISH_CENSUS`.
Cost profiles have these hooks **disabled**. A separate historical oracle control
patches only a scratch copy of `lib/web.bot`, explicitly outside headline counts.

All 30 production/audit-off object disassemblies **including instruction bytes
and relocations** agree. Instrumented/uninstrumented values, allocations, GC
counts and live-object counters agree. GC timing fields alone are normalized.
The committed scalar audit was regenerated into the new tree and all 39
assembly/VCode/summary files match byte for byte. Pre-existing untracked
`bench/refined-checks` and `examples/stdlib/ai_text_clean` are untouched.

## Canonical corpus and historical corpus exclusions

| Population | Files | Executable | Static callvalue | Dynamic callvalue |
| --- | --- | --- | --- | --- |
| Pre-dogfooding benchmarks (fib, loop-count, sum-refined, refined-checks, uri-steady) | 5 | 5 | 2 | 8000 |
| New higher-order benchmarks | 3 | 3 | 7 | 317 |
| Stdlib examples | 9 | 9 | 0 | 0 |
| Surface examples | 14 | 13 | 0 | 0 |
| Total | 31 | 30 | 9 | 8317 |

Enumeration is exactly sorted `bench/*.bot`, `examples/stdlib/*.bot`, and
`examples/surface/*.bot`. No `.ir`, audit snapshot, raw HIR/NIR test fixture or
synthetic workload enters these totals. The NIR files below are *outputs* of
today's ordinary frontend, never corpus inputs. `10-duplicate-binding.bot`
produces its declared `CORE SEMANTIC DUPLICATE` error before compilation.
Full filenames and Git blob IDs: [corpus.txt](audit/post-structural-fn-dynamic-census/out/corpus.txt)
and [static.jsonl](audit/post-structural-fn-dynamic-census/out/static.jsonl).

## Tooling and provenance

Frozen compiler commit: `a8a306f986809c0a8b54f4763013070f209c248c`.
Tcl 9.0.1; rustc 1.98.1 (48a229cea, 2026-09-01); Cranelift 0.135.2;
x86-64 Linux/System V under Ubuntu 24.04 WSL; release build with debug=1;
Valgrind 3.22.0; `LANG=C.utf8 LC_ALL=C.utf8`.
Compiler options are production defaults (`specialize=1`, `repr-opt=1`,
StringRegion enabled). Native measurement stack is 64 MiB.

Pipeline: `surface::readProgramFile` → `hir::lower` →
`native::buildProgramHir` → `native::lower::program`, matching `bench/bench.tcl`.
Source HIR types are also recorded to distinguish them from instance views.

Static census/NIR are reproduced twice byte-identically. Two independent natural
native executions produce identical counters, target sets and object counts.
Each independent Callgrind profile collects one natural run after one excluded
warmup, using the established `botlish_audit_run` anchor and JIT address map.
There are two profiles per program/control. JIT compilation and between-run
reset reclamation are excluded; GC *during* a run is included. No outer source
loops are added. Ir is executed machine instructions, not NIR operations.

Wall-clock corroboration: five sessions, one warmup plus twenty whole-program
runs each; median of session medians, compilation excluded. It is not used to
rank sites. Full host/toolchain, source SHA-256s, blob/tree IDs, executable hashes,
NIR hashes and mode details are in
[provenance.json](audit/post-structural-fn-dynamic-census/out/provenance.json).
[README](audit/post-structural-fn-dynamic-census/README.md) gives reproduction commands.

## Static callable census and per-program dynamic totals

| Program | Used instances | call | callenv | callvalue | closure | capture | fnvalue | native | Dynamic callvalue | Dominant site |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| bench/fib.bot | 2 | 3 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | none |
| bench/lex-strategy.bot | 11 | 11 | 0 | 2 | 0 | 0 | 1 | 2 | 170 | S2 |
| bench/loop-count.bot | 3 | 2 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | none |
| bench/refined-checks.bot | 26 | 24 | 0 | 1 | 0 | 0 | 1 | 1 | 8000 | S3 |
| bench/source-checks.bot | 7 | 1 | 3 | 2 | 3 | 3 | 2 | 2 | 90 | S5 |
| bench/sum-refined.bot | 4 | 2 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | none |
| bench/test-selection.bot | 14 | 14 | 1 | 3 | 2 | 2 | 0 | 0 | 57 | S6 |
| bench/uri-steady.bot | 26 | 21 | 1 | 1 | 3 | 3 | 0 | 1 | 0 | none |
| examples/stdlib/ai_text_clean.bot | 6 | 9 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | none |
| examples/stdlib/csv.bot | 10 | 4 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | none |
| examples/stdlib/csv_chunked.bot | 20 | 12 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | none |
| examples/stdlib/csv_geometric.bot | 14 | 9 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | none |
| examples/stdlib/csv_records.bot | 58 | 84 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | none |
| examples/stdlib/hashtable.bot | 30 | 68 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | none |
| examples/stdlib/matmul.bot | 7 | 8 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | none |
| examples/stdlib/string_replace.bot | 4 | 7 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | none |
| examples/stdlib/string_reverse.bot | 3 | 6 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | none |
| examples/surface/01-arithmetic.bot | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | none |
| examples/surface/02-recursion.bot | 2 | 3 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | none |
| examples/surface/03-closure.bot | 4 | 1 | 1 | 0 | 1 | 2 | 0 | 0 | 0 | none |
| examples/surface/04-branch-value.bot | 2 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | none |
| examples/surface/05-shadowing.bot | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | none |
| examples/surface/06-list.bot | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | none |
| examples/surface/07-loop-break.bot | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | none |
| examples/surface/08-return.bot | 3 | 3 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | none |
| examples/surface/09-mutual-recursion.bot | 5 | 0 | 6 | 0 | 2 | 4 | 0 | 0 | 0 | none |
| examples/surface/11-boolean-operators.bot | 3 | 3 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | none |
| examples/surface/12-if-value.bot | 2 | 3 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | none |
| examples/surface/13-hygiene.bot | 2 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | none |
| examples/surface/14-modules.bot | 2 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | none |

The negative example has no used instances or generated sites. Counts are NIR
instructions, not source call expressions. `native` counts callable-value
materializations, not every inlined native operation. `callmulti` and
`callenvmulti` are separately preserved in `static.jsonl` (the displayed `call`
column does not silently include them). The benchmark total is exactly 9.

## Unique source sites versus compiled sites

| Source expression | Programs | Compiled sites | Dynamic executions |
| --- | --- | --- | --- |
| lib/list.bot:67 predicate(x) | bench/lex-strategy.bot | 1 | 38 |
| bench/lex-strategy.bot:57 classifier(c) | bench/lex-strategy.bot | 1 | 132 |
| lib/web.bot:128 predicate(char_at(i)) | bench/refined-checks.bot, bench/uri-steady.bot | 2 | 8000 |
| lib/list.bot:79 predicate(x) | bench/source-checks.bot, bench/test-selection.bot | 2 | 9 |
| bench/source-checks.bot:56 check(c) | bench/source-checks.bot | 1 | 84 |
| lib/list.bot:61 predicate(x) | bench/test-selection.bot | 1 | 52 |
| lib/list.bot:73 predicate(x) | bench/test-selection.bot | 1 | 2 |

Stable IDs below combine canonical program, source helper/location, instance
label and expression ID. `S1`–`S9` are table aliases; machine addresses are only
profile lookup keys. `e216` in two programs is two compiled sites. Code target
IDs are also scoped to their program.

Source-metadata observation: assembled surface HIR sometimes reports the entry
program's filename beside imported library line/node data (e.g. `list::any?`
at line 61). The source labels above were checked against `lib/list.bot` and
`lib/web.bot` definitions and module provenance, rather than trusting that
filename alone. This pre-existing attribution issue is reported, not fixed.

## Per-site results: static facts and dynamic populations

| ID / program | Source site / instance / expr | Provenance | Full inferred callee type in used instance | Audit-only static code-target set | Calls | Observed target count | Observed targets: counts; objects | Capturing? |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| S1 bench/lex-strategy.bot | lib/list.bot:67 predicate(x); list::all?<List[str], native>/i10 @e18 | HOF parameter | native | {native is_tcl_alnum} | 38 | 1 | Native is_tcl_alnum: 38; objects=1 | Native is_tcl_alnum: envless / Native |
| S2 bench/lex-strategy.bot | bench/lex-strategy.bot:57 classifier(c); classify<str, bool>/i3 @e119 | if/control-flow join | Fn{args: [any], return: any, errors: []} | {block e49} {native is_tcl_alnum} | 132 | 2 | Block e49 (lenient_ident_char?): 66; objects=1; Native is_tcl_alnum: 66; objects=1 | Block 2: envless / Native; Native is_tcl_alnum: envless / Native |
| S3 bench/refined-checks.bot | lib/web.bot:128 predicate(char_at(i)); scan_while<generic>/i20 @e216 | HOF parameter | any | {block e183} {native is_tcl_alpha} | 8,000 | 2 | Block e183 (local_char?): 6800; objects=1; Native is_tcl_alpha: 1200; objects=1 | Block 12: envless / Native; Native is_tcl_alpha: envless / Native |
| S4 bench/source-checks.bot | lib/list.bot:79 predicate(x); list::find<List[str], block>/i3 @e42 | HOF parameter | block | {block e114} | 6 | 1 | Block e114 (invalid_name?): 6; objects=1 | Block 6: yes, 1 runtime capture(s) |
| S5 bench/source-checks.bot | bench/source-checks.bot:56 check(c); classify_leading<generic>/i2 @e91 | List element | Fn{args: [any], return: any, errors: []} | {block e49} {block e55} {native is_tcl_alnum} {native is_tcl_alpha} | 84 | 4 | Block e49 (is_underscore?): 21; objects=1; Block e55 (is_hyphen?): 21; objects=1; Native is_tcl_alnum: 21; objects=1; Native is_tcl_alpha: 21; objects=1 | Block 2: envless / Native; Block 3: envless / Native; Native is_tcl_alnum: envless / Native; Native is_tcl_alpha: envless / Native |
| S6 bench/test-selection.bot | lib/list.bot:61 predicate(x); list::any?<any, block>/i6 @e6 | HOF parameter | block | {block e55} | 52 | 1 | Block e55 (changed?): 52; objects=2 | Block 5: yes, 1 runtime capture(s) |
| S7 bench/test-selection.bot | lib/list.bot:73 predicate(x); list::none?<List[str], block>/i7 @e31 | HOF parameter | block | {block e55} | 2 | 1 | Block e55 (changed?): 2; objects=1 | Block 5: yes, 1 runtime capture(s) |
| S8 bench/test-selection.bot | lib/list.bot:79 predicate(x); list::find<List[list], block>/i9 @e42 | HOF parameter | block | {block e98} | 3 | 1 | Block e98 (is_affected?): 3; objects=1 | Block 13: yes, 1 runtime capture(s) |
| S9 bench/uri-steady.bot | lib/web.bot:128 predicate(char_at(i)); scan_while<generic>/i20 @e216 | HOF parameter | any | {block e183} {native is_tcl_alpha} | 0 | 0 | 0 targets (unexecuted) | statically mixed Native/capturing Block |

No site has a production exact target. The eight executed sites have observed
sets equal to their independently recovered static sets. S9's two-element
static set strictly contains the empty observed set. There are no unknown static
sets after this audit's explicit source-provenance tracing. An observed
singleton alone is never treated as proof. Full caller witnesses and intermediate
unions: [proof-witnesses.txt](audit/post-structural-fn-dynamic-census/out/proof-witnesses.txt).
The trace follows immutable aliases, exact factory result types, compatible
branches/List elements, and known callers, including captured outer parameters.
It is a deliberately limited offline witness extractor, not a production pass
or a general soundness theorem for arbitrary programs.

## Structural Fn precision and error contracts

| Current callee knowledge | Compiled sites | Executions | Share |
| --- | --- | --- | --- |
| Structural Fn | 2 | 216 | 2.5971% |
| Bare block/native | 5 | 101 | 1.2144% |
| any | 2 | 8000 | 96.1885% |

The structural milestone does **not** make all nine instance parameters Fn.
The seven HOF sites still expose bare callable kinds or `any`; specialization
keys erase the exact callable arguments. Local List and strategy joins retain
`Fn{args: [any], return: bool, errors: []}` in whole-program/source HIR, and
`Fn{args: [any], return: any, errors: []}` in their used instance views.
This precision difference is also present in the prior structural-type audit;
it is not caused by instrumentation.

Both structural sites have `errors: []`; there are no nonempty structural Fn
error sets here. The other seven have no structural Fn error contract to count;
do not describe them as seven fully typed error-free Fn sites. Their recovered
actual predicates have no declared checked errors. `list::find` itself can
raise `NotFound`, independently of its predicate, and the canonical handlers
remain intact. No error-bearing control was invented.

## HOF ingress: every used instance and actual caller

| Site / contributing instance | Parameter | Actual caller | Full callable argument type | Immediate exact fact | Lexical captures | Offline union |
| --- | --- | --- | --- | --- | --- | --- |
| S1 list::all?<List[str], native>/i10 | predicate | fully_alnum?<str>/i9 @e164 | e172 : native is_tcl_alnum | native is_tcl_alnum | none / unknown for bare kind | {native is_tcl_alnum} |
| S3 scan_while<generic>/i20 | predicate | web::emailish?<str>/i19 @e298 | e301 : block(e183)/1 -> any | block e183 1 any | none / unknown for bare kind | {block e183} {native is_tcl_alpha} |
| S3 scan_while<generic>/i20 | predicate | tld?<generic>/i23 @e228 | e231 : native is_tcl_alpha | native is_tcl_alpha | none / unknown for bare kind | {block e183} {native is_tcl_alpha} |
| S4 list::find<List[str], block>/i3 | predicate | <program>/i0 @e151 | e154 : block(e114)/1 -> any | block e114 1 any | b9 | {block e114} |
| S6 list::any?<any, block>/i6 | predicate | affected?<list, block>/i4 @e75 | e80 : block | not exact here; trace outer callers | none / unknown for bare kind | {block e55} |
| S6 list::any?<any, block>/i6 | predicate | affected?<any, block>/i12 @e75 | e80 : block | not exact here; trace outer callers | none / unknown for bare kind | {block e55} |
| S7 list::none?<List[str], block>/i7 | predicate | <program>/i0 @e251 | e254 : block(e55)/1 -> any | block e55 1 any | b36 | {block e55} |
| S8 list::find<List[list], block>/i9 | predicate | first_affected<List[list], block>/i8 @e105 | e108 : block(e98)/1 -> any | block e98 1 any | b8 b50 | {block e98} |
| S9 scan_while<generic>/i20 | predicate | web::emailish?<generic>/i19 @e298 | e301 : block(e183)/1 -> any | block e183 1 any | b15 | {block e183} {native is_tcl_alpha} |
| S9 scan_while<generic>/i20 | predicate | tld?<generic>/i23 @e228 | e231 : native is_tcl_alpha | native is_tcl_alpha | none / unknown for bare kind | {block e183} {native is_tcl_alpha} |

`list::any?` has one used predicate instance with **two actual compiled caller
instances**, both at source expression e75: `affected?<list, block>` and
`affected?<any, block>`. Their immediate arguments are bare `block`, not exact.
Tracing `changed?` through `select_affected`, and through `is_affected?`'s
capture from `first_affected`, reaches the exact `Block e55` factory result.
`select_affected` has two root callers (e236/e241, changed_a?/changed_b?);
`first_affected` has root caller e263. Each full root argument type is
`block(e55)/1 -> any`. The witness file records all intervening caller sites.
Thus a **single pass using only already-exact immediate ingress** covers 6 HOF
sites / 8,049 calls; propagating those ingress facts through the closed caller
chain covers all 7 HOF sites / 8,101 calls. Neither result needs List/if joins.

## scan_while and web::emailish? continuity

Two compiled predicate sites represent **one** library source expression,
`lib/web.bot:128`. Both used instances are `scan_while<generic>` (i20, e216).
Each has two known callers: local-part scanning passes exact `Block e183`
(`local_char?`), and TLD scanning passes exact `Native is_tcl_alpha`.
The static union is two targets in each program. In `refined-checks`, e183 is
envless; in `uri-steady` it captures a lexical value under this pipeline.

`refined-checks` executes 1,200 helper activations and 8,000 predicate dispatches:
6,800 to e183 and 1,200 to is_tcl_alpha. `uri-steady` executes zero helper
activations and zero predicate calls: its URI workload never calls emailish?.
The source aggregation is therefore 8,000 calls, **96.1885%** of all callvalue
executions. The scanner remains dominant. Potential scan-range lengths were
not separately profiled; inspected elements equal the 8,000 measured predicates.

## list::any?, list::all?, list::none? and list::find; early exit

| Helper / program | Used predicate instances | Static sites | Helper activations | Potential elements | Inspected / predicate calls | Static and observed set |
| --- | --- | --- | --- | --- | --- | --- |
| any? / test-selection | 1 | 1 | 31 | 54 | 52 | Block e55, capturing |
| all? / lex-strategy | 1 | 1 | 8 | 66 | 38 | Native is_tcl_alnum |
| none? / test-selection | 1 | 1 | 1 | 2 | 2 | Block e55, capturing |
| find / test-selection | 1 | 1 | 1 | 14 | 3 | Block e98, capturing |
| find / source-checks | 1 | 1 | 1 | 16 | 6 | Block e114, capturing |

Helper activations are measured direct NIR calls; potential lengths are
checked from the unchanged input literals and those activations, not estimated
from total runtime. `any?` traverses two complete groups-of-tests selections
(24 dependency slots each), plus the first three groups inspected by `find`
(6 slots): 54 possible, 52 inspected. `all?` receives 66 total characters but
inspects only 38 due to early false results. `find` inspects only 3/14 and 6/16.

The clean one-caller/one-target control is S1: `fully_alnum?` passes exact
`native is_tcl_alnum` at e164/e172. Its 38 calls contribute 4,446 measured Ir
in common/native callable machinery, with another 2,846 Ir in the remaining
dispatch-plus-callee subtree. Exact net savings are not measured for this
individual site. Singleton refinement would reach it without a multi-target test.

## Callable List site

`checks` is `List[Fn{args: [any], return: bool, errors: []}]` in whole-program
HIR. The used generic `classify_leading` view widens the element return to any;
the callee remains structural Fn. Its immutable literal contains exactly
`Native is_tcl_alpha`, `Native is_tcl_alnum`, envless `Block e49`
(`is_underscore?`) and envless `Block e55` (`is_hyphen?`). The literal union
proves four code targets without positional analysis.

22 `classify_leading` activations include one empty-name short circuit; 21
nonempty names invoke four checks each. S5 executes **84** calls, **21 per
target**, 1.0100% of all indirect calls. It accounts for 6,384 measured callable
machinery Ir (about 8.4% of this small program), versus 8,101 HOF dispatches
across the corpus. This is a real mixed-target acceptance case, but not the
main corpus-wide performance opportunity.

## If-selected strategy site

The strict branch is exact `native is_tcl_alnum`; the relaxed branch is
exact `block(e49)/1 -> bool` (`lenient_ident_char?`) in source HIR, and
`block(e49)/1 -> any` in the instance view. Their join is
`Fn{args: [any], return: bool, errors: []}` in source HIR and the same args/errors
with return any in the instance. The recoverable union is exactly those two
code targets, Native plus envless Block.

S2 makes **132** calls: 66 per target across 16 `classify` activations.
The chosen classifier is invariant within each activation, selected before
the character loop. Its measured callable machinery is 10,032 Ir (about 3.1%
of lex-strategy), and its whole callvalue subtree is 21,356 Ir, including
callee bodies. Singleton-only refinement does not reach it; K=2 does.

## Code target versus closure environment identity; capturing closure sites

S6 (`any?`) observes **two closure objects, one code target e55**, over
changed_a and changed_b. These objects come from two factory activations over
different immutable sets. S7 (`none?`) observes only changed_a: one object/e55.
S8 (`find`) observes one object/e98, capturing changed_a through is_affected?.
S4 (`find` in source-checks) observes one object/e114, capturing valid_start?.
All four require a dynamic environment even with singleton code identity;
their hypothetical exact path is `callenv`. There are **63** such indirect calls.

Runtime capture counts can be smaller than lexical capture lists: envless
function references can be eliminated from the environment by existing code.
Object counts come from per-natural-run identity sets; they are not added
across sites (the same changed_a object occurs in S6 and S7). None of these
small closure-control programs collects during its natural run, so address
reuse cannot hide additional objects. Native/envless callable objects are
program constants, not per-call allocations.

## Target-cardinality distribution and K=1/2/4/8 coverage

| Observed population | Sites | Dynamic executions | Share |
| --- | --- | --- | --- |
| Singleton observed (also independently proved here) | 5 | 101 | 1.2144% |
| 2 observed targets | 2 | 8132 | 97.7756% |
| 3–4 observed targets | 1 | 84 | 1.0100% |
| >4 | 0 | 0 | 0% |
| Unexecuted / no observed population | 1 | 0 | 0% |
| Unresolved executed target | 0 | 0 | 0% |

Primary coverage uses **statically provable** sets, including the dormant two-target site:

| K | Static sites covered | Static-site % | Dynamic calls covered | Dynamic-call % |
| --- | --- | --- | --- | --- |
| 1 | 5 | 55.5556% | 101 | 1.2144% |
| 2 | 8 | 88.8889% | 8233 | 98.9900% |
| 4 | 9 | 100.0000% | 8317 | 100.0000% |
| 8 | 9 | 100.0000% | 8317 | 100.0000% |

K=1 has high *site* coverage and low *execution* coverage. K=2 reaches the
hot scanner and strategy; K=4 additionally reaches the List site. K=8 adds
nothing in this corpus. These are coverage observations, not a selected compiler
cap or an assumption that finite dispatch is free.

## Provenance-category aggregation

| Category | Compiled sites | Unique source sites | Dynamic calls | Share | Provably finite-covered calls |
| --- | --- | --- | --- | --- | --- |
| HOF parameter | 7 | 5 | 8101 | 97.4029% | 8101 |
| List element | 1 | 1 | 84 | 1.0100% | 84 |
| if/control-flow join | 1 | 1 | 132 | 1.5871% | 132 |
| other | 0 | 0 | 0 | 0.0000% | 0 |

## Top dynamic sites / Pareto distribution

| Rank | Site | Indirect calls | Share | Cumulative share | Attributed machinery Ir |
| --- | --- | --- | --- | --- | --- |
| 1 | S3 bench/refined-checks.bot scan_while | 8000 | 96.1885% | 96.1885% | 378400 |
| 2 | S2 bench/lex-strategy.bot classify | 132 | 1.5871% | 97.7756% | 10032 |
| 3 | S5 bench/source-checks.bot classify_leading | 84 | 1.0100% | 98.7856% | 6384 |
| 4 | S6 bench/test-selection.bot list::any? | 52 | 0.6252% | 99.4108% | 1820 |
| 5 | S1 bench/lex-strategy.bot list::all? | 38 | 0.4569% | 99.8677% | 4446 |
| 6 | S4 bench/source-checks.bot list::find | 6 | 0.0721% | 99.9399% | 210 |
| 7 | S8 bench/test-selection.bot list::find | 3 | 0.0361% | 99.9760% | 105 |
| 8 | S7 bench/test-selection.bot list::none? | 2 | 0.0240% | 100.0000% | 70 |
| 9 | S9 bench/uri-steady.bot scan_while | 0 | 0.0000% | 100.0000% | 0 |

By attributable machinery work the order is **S3, S2, S5, S1, S6, S4,
S8, S7, S9**: native-only S1 has fewer invocations than S6 but more measured
dispatch machinery. These are instruction counts, not a weighted score, and
say nothing against HOFs, Lists or closures as language features.

## Whole-corpus callable invocation totals

| Executed NIR form | Natural corpus total |
| --- | --- |
| call | 157689 |
| callenv | 12565 |
| callvalue | 8317 |
| callmulti | 3194 |
| callenvmulti | 0 |
| tail/tailenv backedges (separate) | 24840 |

Total non-tail emitted Block/callable invocations: **181,765**;
callvalue share **4.5757%**. Restricting the denominator to the requested
literal `call + callenv + callvalue` gives 178,571
and 4.6575%. Tail backedges are shown
separately because they have no call instruction. Inlined native primitives
are not counted as calls; this is not a source-level count of every operation.

## AOT status

| Site | Used instance region status | Callable fact |
| --- | --- | --- |
| S1 | guarded | native |
| S2 | closed | Fn{args: [any], return: any, errors: []} |
| S3 | open | any |
| S4 | open | block |
| S5 | guarded | Fn{args: [any], return: any, errors: []} |
| S6 | guarded | block |
| S7 | guarded | block |
| S8 | open | block |
| S9 | open | any |

These are existing `hir::aot::analyzeRegion` results on each used instance
view. Region status includes the rest of the function and its checked-error /
representation issues: it is not solely a label on callvalue. A closed AOT
region (classify) can still use structurally known indirect dispatch. Scanner
parameters remain `any`/open; structural local joins no longer require an
unknown callable-kind semantic blocker. AOT policy is unchanged.

## Allocation observations

| Program | Natural heap Block creations | Indirect calls | Closure-creation relationship |
| --- | --- | --- | --- |
| refined-checks | 0 | 8000 | local_char? is an envless constant |
| lex-strategy | 0 | 170 | envless Block and Native constants |
| source-checks | 3 | 90 | classify_leading / valid_start? / invalid_name? closure chain |
| test-selection | 3 | 57 | two changed? environments and one is_affected? environment |
| uri-steady | 2 | 0 | closure values created despite zero indirect executions |

Successful `rt_call_value` dispatch itself makes **zero Botlish allocations**
on these paths. Block dispatch checks kind/arity then calls the generic entry;
Native dispatch checks the contract and invokes its operation. Callee work,
argument construction and closure creation are separate. In particular, the
8,000 scanner character Strings are created by `char_at` before dispatch, not
by rt_call_value. Exactness can expose existing StringRegion optimization,
but that is an additional consequence, not dispatch's own allocation cost.
Production `*.production.txt` files contain allocation summaries for every
executable program; instrumentation preserves them.

## Dispatch-cost attribution and instrumentation overhead

The exact shared helper paths are 28 self Ir per successful Block dispatch
and 46 per Native dispatch; `invoke_native` contributes 71 self Ir per Native,
and each used Block generic-entry trampoline contributes 7. These are counts
of the current compiled machine paths, cross-checked against every profile's
exclusive helper/entry totals in `report.py`, not arbitrary importance weights.
Per-site attribution multiplies the **measured** per-target invocation counts
by these verified fixed path lengths. This yields 35 Ir/Block and 117 Ir/Native
for the explicitly named machinery subset. It excludes caller argument-array
setup, guards in callee bodies, `apply_op`'s mixed dispatch/body instructions,
and the target body itself. It is not an exact recoverable-savings prediction.

Total: rt_call_value self 257,104 Ir + native contract/dispatch self 95,566 Ir
+ generic Block entries 48,797 Ir = **401,467 Ir**. Pure indirect-dispatch
**net optimization savings** cannot be isolated from all caller/callee changes
without a more specific counterfactual; that field is not measured here.

Callgrind's whole-program totals vary between independent processes. We stopped
interpretation and compared exclusive per-function work: all differences are
in libc malloc/free/realloc bookkeeping, unlink/consolidation, or memcpy paths.
Every generated-code and callable-runtime instruction count repeats exactly.
Thus whole totals are intervals, not claimed deterministic integers. Details:
[repeatability.txt](audit/post-structural-fn-dynamic-census/out/repeatability.txt).
The current reducer also sums recursive Callgrind contexts (`rt_call_value'2`)
and counts each machine call instruction once; the historical text reducer's
unmerged source-checks arcs must not be mistaken for separate static sites.
| Program | Uncounted profile Ir/run range | Attributed machinery Ir | Share of program Ir | Production median µs | Tracking / production time |
| --- | --- | --- | --- | --- | --- |
| bench/refined-checks.bot | 8,248,407–8,248,625 | 378400 | 4.5875% | 755.841 | 3.33× |
| bench/test-selection.bot | 37,778–37,878 | 1995 | 5.2739% | 3.296 | 4.36× |
| bench/source-checks.bot | 75,435–76,278 | 6594 | 8.6927% | 7.491 | 2.61× |
| bench/lex-strategy.bot | 321,726–322,384 | 14478 | 4.4955% | 30.464 | 2.60× |
| bench/uri-steady.bot | 44,165,203–44,193,373 | 0 | 0.0000% | 4675.376 | 3.08× |

Counter hooks record all emitted Block calls and allocate Rust-side BTreeMap /
identity-set entries; they allocate nothing in the Botlish heap, trigger no
Botlish GC and retain no Botlish roots. Their substantial overhead is why
counted execution times are never used as dispatch cost. Counter-only mode
was not measured separately. The audit-off timing controls and full samples
are in `timing.json`; short-run noise precludes conclusions from small
audit-off/production differences. Callgrind has its own execution overhead;
its wall time is not used.

Per-site inclusive subtrees (dispatch **plus callee**) are also measured.
Nested subtrees overlap: S4 includes some S5 work and S8 includes some S6.
They must not be summed as program overhead. These are supplied as body-work
context only; the exclusive machinery table avoids that double counting.
| Site | Inclusive subtree Ir range | Exclusive attributed machinery Ir |
| --- | --- | --- |
| S1 | 7,292–7,292 | 4446 |
| S2 | 21,356–21,356 | 10032 |
| S3 | 1,814,800–1,814,800 | 378400 |
| S4 | 21,367–22,210 | 210 |
| S5 | 15,319–15,319 | 6384 |
| S6 | 12,381–12,381 | 1820 |
| S7 | 558–558 | 70 |
| S8 | 2,561–2,561 | 105 |
| S9 | 0–0 | 0 |

## Counterfactual ceilings and the remaining exact-target oracle

| Control on current refined-checks.bot | Foreground Ir/run (two profiles) | Mean saving vs corresponding production |
| --- | --- | --- |
| Production | 8,248,407–8,248,625 | — |
| Oracle exact scanner clones | 6,808,550–6,808,556 | 1,439,963 (17.4572%) |
| Production, StringRegion disabled | 10,209,898–10,210,914 | — |
| Oracle exact, StringRegion disabled | 9,680,415–9,681,858 | 529,269.5 |

The unchanged historical `exact-target.diff` is applied to a fresh scratch
copy only. It splits scan_while into scan_local and scan_alpha and substitutes
the statically known predicate at each existing caller. The canonical
`bench/refined-checks.bot` is byte-identical. This is the existing supported
oracle control, **not an implementation of bounded target sets or dispatch**.
All control values equal `[400, 0]`.

The no-StringRegion differential is 529,269.5 Ir; the remaining
910,693.5 Ir of the foreground differential is exposure of existing
StringRegion effects (an interaction decomposition, not two independent passes).
Strings fall from 8,004 to 6,804; Block allocations stay zero. Callee body work
and closure creation are not mislabeled as dispatch. Deferred reset/reclamation
and total lifecycle savings are **not measured** in this fresh census.

Wall-clock corroboration is 755.841 →
631.184 µs, median of five session medians,
16.4924% lower.
The instruction differential is the stronger economic evidence. Different
malloc layouts account for the small Ir intervals; no callable or generated
instruction count varies. No finite multi-target branch cost is assumed zero.

Generated JIT machine bytes (direct bodies plus generic entries): 8,935 production → 9,209 exact control, signed change +274 bytes. These are measured code sizes, not a proposed lowering budget.

## Singleton-only, HOF-ingress-only, local-LUB-only and combined ceilings

| Hypothetical scope | Sites | Executions | Execution coverage | Current attributable machinery Ir (not net savings) |
| --- | --- | --- | --- | --- |
| Provable singleton only | 5 | 101 | 1.2144% | 6651 |
| HOF immediate already-exact caller facts only | 6 | 8049 | 96.7777% | 383231 |
| HOF ingress through known caller chain | 7 | 8101 | 97.4029% | 385051 |
| Local Fn joins only (List + if/return-result) | 2 | 216 | 2.5971% | 16416 |
| Union of HOF ingress and local joins | 9 | 8317 | 100% | 401467 |
| Intersection / double-counted sites | 0 | 0 | 0% | 0 |

Singleton-only net Ir/runtime ceiling: **not measured**; 6,651 Ir is merely
the named current machinery at those 101 calls. K=2 and K=4 execution ceilings
are 8,233 and 8,317 respectively; their net savings are **not measured** because
no trusted finite-branch dispatch model was added. The scanner oracle gives
the broader recoverable opportunity conditional on achieving equivalent exact
facts and region exposure. It cannot be added to the machinery total.

Local-only tracing includes following choose_classifier's existing returned
Fn result and immutable aliases; it needs no HOF parameter ingress. No additional
returning-loop callable-collection provenance contributes a site here.
The same-code factory uses an existing exact Block result, not a new local
multi-target join. None of these offline facts modifies a compiler type.

## Historical comparison and stable-subset comparison

[POST-R2A-DYNAMIC-CENSUS](POST-R2A-DYNAMIC-CENSUS.md) measured the older
raw-IR era. [POST-MODULE-STATIC-EXACT-TARGET-CENSUS](POST-MODULE-STATIC-EXACT-TARGET-CENSUS.md)
reported 8,191,901 → 6,786,030 foreground Ir on `bench/refined-checks.ir`:
1,405,871 saved (17.16%), including 1,200 fewer Strings. The new source-only
control measures approximately 17.46%, so the opportunity remains of the same
order. This is **not** a pure compiler improvement/regression delta: the old
raw input, frontend route, corpus composition, runtime build/layout and host
measurement boundary differ. Today's baseline is 8.248M rather than 8.192M.

**Stable-subset comparison:** the motivating email workload's actual predicate
population still executes 6,800 local_char? + 1,200 is_tcl_alpha calls, and
the exact oracle still removes 1,200 Strings. Those natural counts are directly
comparable for that preserved workload. Absolute instruction totals across
the raw-IR/surface migration are not attributed to structural Fn. The original
five benchmark *names* form a current subset with two compiled sites but only
one executed site / 8,000 calls; old tooling's extra .ir rows are excluded.
The historical module audit omitted emailish? from uri-steady's compiled
program; today's surface pipeline contains a dormant scanner site. This is a
static corpus/pipeline difference, not an extra dynamic cost.

[HIGHER-ORDER-DOGFOODING](HIGHER-ORDER-DOGFOODING.md) added seven compiled
sites in three programs. They contribute 317 natural calls here, broadening
target provenance and environment cases while leaving scan_while dominant.
[STRUCTURAL-FUNCTION-TYPES](STRUCTURAL-FUNCTION-TYPES.md) kept all nine sites
and byte-identical generated code, while preserving local structural contracts.
This census reproduces its full type boundary outputs and the committed scalar
baseline. There is no evidence here of a structural-Fn code-generation change.

## Residual unknown sites and hypothetical lowering classes

| Future class (evidence only) | Sites | Dynamic calls |
| --- | --- | --- |
| Singleton Native | S1 | 38 |
| Singleton envless Block | none | 0 |
| Singleton capturing Block | S4, S6, S7, S8 | 63 |
| Finite Native-only | none | 0 |
| Finite Block-only | none | 0 |
| Finite mixed Native/Block | S2, S3, S5, S9 | 8216 |
| Unknown | none | 0 |

There are no observed mixed envless/capturing Block-only populations. The
executed finite mixed cases use envless Blocks; S9 statically includes a
capturing Block but has no observed executions. Four static finite mixed sites,
three executed. A K=1 cap leaves S2/S3/S5/S9 (8,216 calls); K=2 leaves S5
(84 calls); K=4 leaves none. HOF-only leaves S2/S5; local-only leaves the seven
HOF sites. No site remains unknown due to genuinely absent/open target
provenance in this closed corpus. That does not establish a closed-world
property for future callers, external input or arbitrary Botlish programs.

## Evidence for bounded codeTargets and branch-once lowering

The observed cases support investigating the proposed theorem: seed exact
Native/Block references with singleton code identities; union compatible local
Fn joins; recover callable-parameter facts from all known instance callers;
forget only target identity when a bound is exceeded or provenance is open.
This would cover the two-target scanner/strategy, four-target immutable List,
one-target native all?, and capturing any?/none?/find controls. The proof must
keep code identity separate from environment identity. It must also address
the actual bare/any HOF parameter boundary: assuming every current site already
has structural Fn would miss 8,101 calls.

All **7 HOF sites / 8,101 executions** call a parameter invariant for the
whole helper activation. Their static cardinalities are five singletons and
two two-target scanner sites (one dormant); the only executed multi-target
HOF site supplies 8,000 calls across 1,200 activations. Branch-once evaluation
is therefore relevant evidence, not yet a selected lowering. The local strategy
adds one invariant site / 132 calls across 16 activations. The List loop changes
its callable each element. No branch-once code, multiversioning or target-set
algorithm is implemented.

## Full regression and benchmark parity

`cargo build --release --manifest-path native/Cargo.toml` succeeded.
`LANG=C.utf8 LC_ALL=C.utf8 tclsh9.0 tests/all.tcl` passed:

| Backend run | Total | Passed | Skipped | Failed |
|---|---:|---:|---:|---:|
| interp | 2,718 | 2,718 | 0 | 0 |
| compile | 2,718 | 2,718 | 0 | 0 |
| Combined executions | 5,436 | 5,436 | 0 | 0 |

Each run sourced 93 test files, including native checks with the native backend
built. `tclsh9.0 bench/bench.tcl -runs 1` passed all 8 canonical programs with
interp/compile/Cranelift agreement and no unsupported rows. Separate native
instrumentation preservation checks pass for all 30 executable corpus sources.
Logs: [tests.txt](audit/post-structural-fn-dynamic-census/out/tests.txt),
[parity.txt](audit/post-structural-fn-dynamic-census/out/parity.txt),
[preservation.json](audit/post-structural-fn-dynamic-census/out/preservation.json).
No production native stack/root/allocation implementation was edited.

## Recommended next implementation scope

The evidence supports a small correctness step around singleton caller
ingress, accepting both the one-native all? control and same-code/different-env
capturing controls. Its economic reach is only 1.2144% of current indirect calls.
A performance milestone must also address the scanner's two-target ingress:
K=2 reaches 98.9900% of executions, with the existing exact oracle showing the
potential value of exposing callee facts to existing optimizations. K=4 adds
the real callable-List control. This scopes evidence for later work; it does
not choose a target-set algorithm, cap policy, guard structure or lowering.

## Compact factual summary

```text
Static callvalue sites: 9
Unique source callvalue expressions: 7
Dynamic callvalue executions per canonical run: 8,317

Statically provable singleton coverage: 5/9 sites; 101/8,317 calls (1.2144%)
Statically provable <=2-target coverage: 8/9 sites; 8,233/8,317 calls (98.9900%)
Statically provable <=4-target coverage: 9/9 sites; 8,317/8,317 calls (100%)
Statically provable <=8-target coverage: 9/9 sites; 8,317/8,317 calls (100%)

Dynamic calls from HOF ingress: 8,101
Dynamic calls from callable List: 84
Dynamic calls from if/control-flow joins: 132
Dynamic calls from other causes: 0

Largest site: refined-checks.bot / scan_while / e216; 8,000 calls
Largest provenance category: HOF parameter; 8,101 calls

Capturing-Block indirect calls: 63
Envless-Block indirect calls: 6,908
Native indirect calls: 1,346
Mixed finite-target sites: 4 static; 3 executed

Sites remaining Unknown after obvious audit-only target propagation: 0

Measured optimization ceiling:
  Existing exact-scanner oracle: 1,439,963 mean foreground Ir/run saved
  on refined-checks.bot (17.4572%); 1,200 fewer Strings/run.
  Bounded finite-dispatch net savings: not measured.
  Named existing callable machinery: 401,467 Ir across the corpus;
  this is attributable current work, not a promised optimization saving.
```
