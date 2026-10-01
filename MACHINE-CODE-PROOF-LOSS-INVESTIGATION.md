# Bottom-up machine-code regression investigation

Investigation only. No compiler, runtime, library or canonical `.bot` change,
and no fix. Raw data, tools and reproduction:
[`audit/machine-code-proof-loss/`](audit/machine-code-proof-loss/README.md).

## Outcome

**The working hypothesis is wrong for `fib`, wrong for the struct and
transport milestones, and right for `refined-checks`, but in a different
window and with a different trigger than assumed.**

Every count below is callgrind instructions per steady-state run (Ir/run) on
**one** runtime binary. That is the frozen tree's runtime with the
post-R2.a census's audit patch. The committed historical NIR of each older
fence runs on it unchanged: `out/ir-series.txt`. Wall-clock time is used only
as a sanity check. It is too noisy on this host to rank anything.

| benchmark | old-good fence | old-good Ir/run | current Ir/run (`c251e7c`) | change | machine code |
|---|---|---:|---:|---:|---|
| `fib` | M9 `a3c0550` | 1,977,300 | **1,977,300** | 0 | byte-identical since `0c2dead` |
| `loop-count` | M9 `a3c0550` | 13,039 | **13,039** | 0 | byte-identical since `0c2dead` |
| `sum-refined` | M9 `a3c0550` | 12,437 | **12,437** | 0 | byte-identical since `0c2dead` (one function renamed in source) |
| `refined-checks` | R2 `e7d53b6` | 3,461,692 | **8,196,144** | **+136.8%** | different program shape since R2.a `63b2199`; byte-identical since `45f29dc` |

1. **`fib` never regressed.** Its machine code is the best it has ever been,
   and it has not changed since M9 (`0c2dead`, 243 bytes for `fib<int>`). It
   runs exactly M9's 1,977,300 instructions. The wall-clock spread between
   later reports (155–227 µs) comes from host noise over byte-identical code.
   What `fib` still pays per call is real, and it is diagnosed below as
   residual work, not loss (Case 1).
2. **The struct, struct-scalar-replacement and value-transport milestones
   changed no scalar machine code.** Their NIR is byte-identical to the
   pre-struct fence `84f4d68` for 11 of the 17 corpus programs. The six that
   changed (the four CSV programs, `hashtable` and `test-selection`) had their
   *source* refactored to structs by the structs milestone, and all six are
   byte-identical from struct scalar replacement to now. The scalar
   benchmarks' assembly is byte-identical across all three milestones.
   `refined-checks` moved by +0.05% over the whole window, all of it
   runtime-side (Case 6, "runtime").
3. **`refined-checks` really did lose ground: +136.8% against R2.** The loss
   arrived in one commit, R2.a (`63b2199`). That commit rewrote
   `lib/web.bot`'s `emailish?` from three hand-specialized scanners into one
   higher-order `scan_while(start, predicate)` plus a set-membership
   `local_char?`. The source still says, at each call site, exactly which
   predicate is passed. The compiler's **semantic layer still knows it**
   (`scan_while<int, native is_tcl_alpha>` and
   `scan_while<int, block(e239)/1 -> bool>`). **Codegen projection erases it:**
   * `hir::specialize` forces a value-capturing closure onto its generic key;
   * the closed-caller theorem joins
     `KeyType(block e239) = block` with `KeyType(native is_tcl_alpha) = native`
     into `any`.

   The result is a `callvalue` per character, a trampoline and a `guard str`,
   plus a one-character String materialized per character. That is
   diagnosis **B**. Measured on the current compiler, restoring the exact
   target in a scratch worktree removes **17.1%** (8,196,144 → 6,794,452) and
   restores R2's per-character cost on the TLD path (376 → 371 Ir/char).
4. **The largest remaining cost is a different, independent gap (C).**
   6,800 one-character Strings per run (52.9% of the counterfactual's Ir) stay
   materialized after the fix. `local_char?` consumes them through
   `immutable_set_contains`, which is not a StringRegion consumer.
5. **One shared loss point explains four of the six traced symptoms.** It is
   codegen projection in `hir::specialize`: the GenericKey collapse for
   value-capturing closures, plus `KeyType`'s erasure of exact callable
   identity. It accounts for `scan_while`'s `callvalue`, `local_char?`'s
   trampoline and guard, the TLD path's materialization, and the historical
   `check<generic>` window, now closed. The same erasure turns every exact
   callable argument in the corpus into `callvalue` (6 of the 8 `callvalue`
   sites have an exact callable in their semantic instance), for example
   `list::any?<List[str], block>` in `test-selection`, whose semantic instance
   is `list::any?<List[str], block(e55)/1 -> bool>`. `fib`'s residuals are
   independent of it (C, A, D).

**Recommended first fix:** carry exact callable identity through codegen
projection for closed instances. That is root-cause restoration. It is the
largest measured item. Every other `refined-checks` repair depends on it.
See [Recommended fix order](#recommended-fix-order).

## Scope and non-goals

* **Frozen:** struct virtualization, transport scoring, nesting cuts,
  materialization frontiers, `callmulti`/`retmulti` transport, fields
  variants. Nothing in `hir/`, `native/`, `core/`, `lib/` or `bench/` was
  edited.
* **No source changes:** canonical `.bot` programs and `lib/web.bot` are
  untouched. The one library rewrite measured here lives only in a scratch
  worktree, and it measures a ceiling.
* **No fixes:** every repair below is listed, ranked and scoped, and none is
  implemented.
* **No census:** six cases were traced deeply, plus controls.
* **No historical rebuild campaign:** no old compiler was rebuilt. Old
  machine code comes from the committed corpus. Old dynamic counts come from
  the NIR earlier censuses committed, re-run on today's runtime, which needs
  no old compiler.

## Frozen compiler fence

| | |
|---|---|
| tree | `c251e7c641030d1859fd032aa5a2a0e318bdf4fc`: value transport (`795eaef`) plus the CI regeneration of `audit/native-scalar-asm/`. This was `origin/main` when work started |
| toolchain | Tcl 9.0.1 (`tclsh9.0`), rustc 1.98.1, Cranelift 0.135.2, valgrind 3.22, objdump 2.42, `LANG=C.utf8 LC_ALL=C.utf8` |
| native build | `cargo build --release --manifest-path native/Cargo.toml` (unmodified) |
| audit build | `audit/post-r2a-dynamic-census/tools/build-audit-native.sh`: a copy of `native/` plus the audit patch, in a scratch directory |

## Historical artifact methodology

The clone was shallow (51 commits). It was unshallowed to the full
301-commit history before any archaeology. Two kinds of committed evidence
were used:

1. **Machine code.** `audit/native-scalar-asm/` holds `objdump -dr -M intel`
   of `native::object` for every `bench/*` and `examples/stdlib/*` program. A
   GitHub Action (`e76dc1b`) regenerates it after compiler changes. Every
   regeneration commit used here touches only `audit/`, and its parent is the
   compiler revision its own `README.md` records under "git commit". That is
   the provenance rule. One regeneration fails it: `f44fd3c` records
   `e486461` but sits on `c4024de`, so its provenance is ambiguous and it is
   not used.
2. **Dynamic counts and NIR.** The post-R2.a census (`2b82c5b`) and the
   post-module-statics census (`ac64bb4`) committed the NIR and callgrind
   census of `refined-checks` for pre-R2, R2, R2.a, R2.a.2, R2.a.3 and module
   statics. Each was emitted from a worktree of that fence. Those NIR files
   were re-run here on the current runtime.
   * The four fences the post-R2.a census profiled reproduce within 0.2%:
     pre-R2 5,430,486 → 5,430,485, R2 3,461,691 → 3,461,692, R2.a
     10,967,390 → 10,968,983 and R2.a.2 9,375,454 → 9,392,986.
   * The two fences the post-module-statics census profiled, on its newer
     binary, come out 0.5% higher. That is the runtime-side delta in Case 6.

Functions are matched by source function and role, not by NIR number:
* R2's `scan_local`/`scan_alpha` correspond to `scan_while` at its local and
  TLD call sites;
* `is_emailish` corresponds to `emailish?`;
* the region `char_at` and the materializing `char_at` are distinct NIR
  functions of one source function.

## Old-good commit/artifact map

| artifact | old-good compiler fence | committed in | relation | path | program / function |
|---|---|---|---|---|---|
| fib asm | `a3c0550` (M9 `6512c14` + its test fix) | `0c2dead` (CI, 17 min later) | immediate child | `audit/native-scalar-asm/bench/fib.asm` | `fib<int>` |
| fib asm, pre-M9 (comparison only) | `e32ea1a` | `caf8ca7` (CI) | immediate child | same | `fib<int>` |
| loop-count / sum-refined asm | `a3c0550` | `0c2dead` | immediate child | `bench/loop-count.asm`, `bench/sum-refined.asm` | `drive`, `work`, `sum`/`refined_sum`, `step` |
| refined-checks asm, M9 / pre-R2 | `a3c0550` | `0c2dead` | immediate child | `bench/refined-checks.asm` | `check`, scanners |
| **refined-checks asm, old-good** | **`e7d53b6` (R2)** | **`844c37e`** (CI, 48 min later) | immediate child | same | `scan_local`, `scan_alpha`, `char_at`, `is_emailish` |
| refined-checks asm, first bad | `63b2199` (R2.a) | `f508532` (CI) | immediate child | same | `scan_while`, `is_local_char` |
| refined-checks asm, `check<generic>` | `569ca4e` (R2.a.1 merge) | `bf40b58` (CI) | immediate child | same | `check<generic>` |
| refined-checks asm, recovery | `f037c7d` (module statics) | `924482b` (CI) | immediate child | same | `check<int, int, str, str>` |
| refined-checks NIR + callgrind, R2 and neighbours | `0c2dead`, `e7d53b6`, `63b2199`, `b472022` | `2b82c5b` (same day) | later commit, generated from worktrees of those fences (its README) | `audit/post-r2a-dynamic-census/profiles/history/*` | whole program |
| refined-checks NIR + callgrind, R2.a.3 / module statics | `6dbcfdb`, `924482b` | `ac64bb4` | later commit, same method | `audit/post-module-static-exact-target-census/profiles/{hist-frozen-r2a3,prod}` | whole program |
| pre-struct NIR snapshot | `84f4d68` | `bee7c03` | later commit (structs report: "before = the parent fence `84f4d68`") | `audit/structs/out/nir-before/` | every corpus program |

## Current assembly generation method

`tclsh9.0 native/generate-scalar-audit.tcl -outdir SCRATCH` on `c251e7c`.
This is the same script and configuration the committed corpus uses:
* `surface::readProgramFile`;
* `native::object`, which runs `native::prepareHir` then `native::lowered`;
* specialization on (`-specialize 1`), `-repr-opt 1`, all default
  `native::lower` options (tiny-leaf inlining, string regions, block escape,
  virtual construction, struct scalar replacement, value transport at their
  defaults);
* Cranelift x86-64 System V;
* disassembly `objdump -dr --no-show-raw-insn -M intel` of the unlinked
  object.

The output is **byte-identical** to the committed `audit/native-scalar-asm/`
except for the generating-commit line (`out/regen-identity.txt`). So the
committed corpus at `c251e7c` *is* the current assembly.

The benchmark's own code path matches it. `bench/bench.tcl` calls
`native::measure`, which calls `native::nir`, the same `native::lowered`. The
JIT therefore compiles the same NIR the object writer does. Dynamic counts
use that NIR (`tools/emit-nir.tcl` → `profile-nir.sh`), and the JIT address
map attributes every executed instruction to its function.

## Selected regression cases

Candidates came from machine-code differences only. Benchmark deltas were not
used to pick them.

| # | program / function | why selected |
|---|---|---|
| 1 | `fib` / `fib<int>` | required. Turned out to be a *non*-regression; its per-call residue is diagnosed anyway |
| 2 | `refined-checks` / `scan_while<generic>` | new `callvalue` + `rt_call_value` per character (old-good: direct region consumers) |
| 3 | `refined-checks` / `char_at<generic>` (materializing) | new `rt_substr` per character (old-good: region companion, no String) |
| 4 | `refined-checks` / `local_char?<generic>` | new generic-entry trampoline + `guard str` per local-part character |
| 5 | `refined-checks` / scanner Int indices (`scan_while`, `char_at`, `domain?`) | tagged compare, Bool word, overflow-checked add per character although every caller is known |
| 6 | `refined-checks` / `check<int, int, str, str>` | the refinement-proof case, plus a closed historical `check<generic>` despecialization window; also hosts the runtime-only residue |

Considered and not traced as regressions:
* M8.a's code growth in `matmul`'s `product_row` (596 → 812 B), `csv`'s
  `scan_quoted` (770 → 1063 B) and `ai_text_clean`'s `clean_from`. All of
  these are measured *faster* (M8.a: matmul 1.12×, csv 2.50×,
  ai_text_clean 2.65–7.16×). This is the "larger is not worse" control.
* The structs milestone's temporary growth of the CSV scanners and HashTable
  rehash (`46d658d`). Struct scalar replacement brought every affected
  function back to its exact pre-struct size (`b370d52`), and allocation
  counts back to the parent's.
* `test-selection`. Its NIR changed only because its canonical source was
  refactored to a struct at the structs milestone; it is aggregate work, not
  scalar.

## Machine-code symptom taxonomy

TYPE-GUARD, RANGE-GUARD, TAGGING, UNTAGGING, GENERIC-ARITH, GENERIC-CALL,
INDIRECT-CALL, TRAMPOLINE, ERROR-PATH, MATERIALIZATION, MOVE/COPY,
SPILL/RELOAD, RETURN-ABI, OTHER, as specified. Here *tag test* means the
`and`/`test reg,1`/`jne` small-Int check. *Bool word* means a comparison
materialized as `mov r,2; cmovCC r,[rip+TRUE]; cmp r,6; je`. A *root store*
is a `mov [rsp+k],reg` into a GC root slot.

## Case 1: `fib<int>`

```
CASE: bench/fib.bot / fib<int>

Observed benchmark direction:
    No regression. Ir/run 1,977,300 at M9 and now. The wall clock varies
    155-227 us across reports with byte-identical code (host noise).

Last known good fence:
    M9, a3c0550 = current. Best-ever fib code (394 -> 292 bytes total).

Old assembly artifact:
    commit: 0c2dead (and caf8ca7 for the pre-M9 comparison)
    path:   audit/native-scalar-asm/bench/fib.asm

Current artifact:
    audit/native-scalar-asm/bench/fib.asm at c251e7c (regenerated
    byte-identically); cases/fib/current-c251e7c.asm.
    Config: specialize 1, repr-opt 1, Cranelift, native::object.

Machine-code regression:
    none. old-good == current, byte for byte.

Residual per internal call (49 instructions; leaf 20):
    TAGGING 4, UNTAGGING 2, TYPE-GUARD 4, ERROR-PATH/GENERIC-ARITH 3 + cold
    rt_int_add, SPILL 4 root stores + 1 slot zero, frame 13, VM-pointer
    moves 3.

Facts that would eliminate it:
    (a) result(fib) in [0, 2^21] for n in [0, 22]  -> tag test, overflow,
        rt_int_add path, 2 result root stores, slot zeroing
    (b) "every caller passes a small Int" (entry Range [0, 22]) usable as a
        raw-Int parameter ABI -> 4 retag + 1-2 untag
    (c) "an rbox result is never a heap reference" -> 2 argument root stores
    (d) none (backend): the base case needs no frame

Old NIR / metadata:
    machine code and VCode byte-identical since 0c2dead (NIR was not
    committed at that fence; M9-INSTANCE-ENTRY-INT-FACTS.md shows M9's NIR
    diff, and Ir is identical)

Current NIR (cases/fib/current.nir):
    %1 = op runbox %0; rilt %1 2; risub; %9 = op rbox %8; call 1 %9;
    ... %16 = op iadd %10 %15

Current specialization key:
    fib<int> (KeyType int), closed, not generic

Current semantic instance:
    s0 fib<int> -> int (valid)

Current type/range/exact/refinement facts:
    n: int, entry Range [0, 22]; result Range [-inf, +inf];
    no exact value; no refinement

Earliest loss point:
    none (nothing was lost). Earliest *missing* fact: hir::range's result
    summary for a self-recursive instance (never derived).

Diagnosis:
    E for the history. Residues: (a) C, (b) A, (c) D, (d) D.

Existing mechanism that could recover it:
    (a) partially: hir::range result summaries (work<int> -> [7,7] in
        loop-count), plus a decreasing bounded measure
    (b) yes: hir::range entry Ranges + InstanceClosed; no ABI consumes them
    (c) yes: NIR states rbox
    (d) no (Cranelift has no shrink-wrapping)

Likely focused repair:
    see Fib investigation

Not implemented in this milestone.
```

## Case 2: `refined-checks` / `scan_while<generic>` (indirect predicate call)

```
CASE: bench/refined-checks.bot / lib/web.bot emailish?'s scan_while

Observed benchmark direction:
    3,461,692 -> 8,196,144 Ir/run vs R2 (+136.8%); scan_while's two call
    sites carry 88.1% of the program.

Last known good fence:
    R2, e7d53b6 (first bad: R2.a, 63b2199)

Old assembly artifact:
    commit: 844c37e
    path:   audit/native-scalar-asm/bench/refined-checks.asm,
            botlish_fn_11 scan_local<generic> / fn_13 scan_alpha<generic>
            (cases/refined-checks/old-good-r2-844c37e-scanners.asm)

Current artifact:
    c251e7c botlish_fn_13 scan_while<generic>
    (cases/refined-checks/current-c251e7c-scanners.asm)

Machine-code regression (per character):
    INDIRECT-CALL: call rt_call_value (225.5 Ir/call incl. 30.7 dispatch,
                   the callee's generic entry and the predicate itself)
                   replaces inline region-consumer calls
    TRAMPOLINE:    botlish_entry_12 (local_char?'s generic entry), 7 Ir
    TYPE-GUARD:    guard str in local_char? (Case 4)
    MATERIALIZATION: char_at -> rt_substr (Case 3)
    ERROR-PATH:    test rax,rax after the callvalue
    SPILL:         2 root stores for the callvalue's argument vector
    Local part:  319 -> 831 Ir/char (6,800 chars/run)
    TLD part:    376 -> 1,307 Ir/char (1,200 chars/run)

Fact that would eliminate it:
    "at scan_while's call site in emailish?, predicate == local_char? (block
    e239, envless); at tld?'s, predicate == native is_tcl_alpha", plus a
    codegen instance per such target.

Old NIR / metadata (R2, history/r2/program.nir):
    %5 %6 %7 = callmulti 10 %0 %2           (char_at region companion)
    %8 = op strregiontclalnum %5 %6 %7      (inlined local-char test)
    %12 = op regioneq %5 %6 %7 "."  ...     (5 inlined equality tests)
    tail %47 %1 %2

Current NIR:
    %7 = call 11 %4 %3                      (materializing char_at)
    %8 = callvalue %1 %7
    %13 = op iadd %4 %11 ; jump L0

Current specialization key:
    scan_while<generic>, key <any, any>; InstanceClosed 1;
    closed-caller theorem "int any"

Current semantic instance (after native::prepareHir):
    scan_while<int, block(e239)/1 -> bool> -> int  (valid)
    scan_while<int, native is_tcl_alpha>  -> int   (valid)

Current type/range/exact/refinement facts:
    the call-site argument HIR types are exact (`block e183/e239 1 any`,
    `native is_tcl_alpha`: post-module-statics targetgraph-prod.txt and
    prepare-census); the parameter's binding type in the codegen view is
    `any`

Earliest loss point:
    hir::specialize codegen projection:
      (1) Handle forces GenericKey on a call to a value-capturing closure
          (scan_while captures v : str);
      (2) ClosedCallerFacts contributes KeyType(typeOf(arg)) per caller,
          so block e239 -> block and native is_tcl_alpha -> native, and the
          lub is any.
    Even without (1), KeyType alone erases the identity: probe
    hof-single-exact gives apply_loop<block, int, int> + callvalue for one
    site and one target.

Diagnosis:
    B (FACT LOST BY CODEGEN PROJECTION); the regression's trigger is a
    source rewrite (E): R2.a introduced the higher-order shape.

Existing mechanism that could recover it:
    yes: semantic instances (exact per site); exact-call lowering, StringRegion
    and blockescape already consume exact targets (counterfactual). Missing
    piece: codegen keys / closed-caller theorems that keep callable identity.

Likely focused repair:
    keep exact callable identity through codegen projection (Recommended
    fix order #1)

Not implemented in this milestone.
```

Side by side, one local-part character (old-good R2 `scan_local` vs current
`scan_while`, prologue and epilogue omitted):

```
R2 scan_local (844c37e)                         current scan_while (c251e7c)
-----------------------                         ----------------------------
and/test/jne  tag test i,n                      and/test/jne  tag test i,n          (same)
cmp; cmovge [rip]; cmp rcx,6; je  Bool word     cmp; cmovl [rip]; cmp rcx,6; je     (same)
call char_at<generic> (region companion)        call char_at<generic> (MATERIALIZING)
  -> regioncheck, 84 Ir incl.                     -> iadd + rt_substr, 629 Ir incl.
test rax,rax; je   completion                   test rax,rax; je   completion       (same)
call rt_str_region_is_tcl_alnum  81 Ir          mov [rsp+0x20],rax; mov [rsp+0x28],rax   root stores (NEW)
cmp rax,6; je                                   lea rcx,[rsp+0x28]; mov edx,1; mov rsi,pred
up to 5 x call rt_str_region_eq  ~85 Ir          call rt_call_value   225 Ir (NEW: INDIRECT-CALL)
  (inlined `c == "."` ... chain)                   -> botlish_entry_12 trampoline (NEW)
                                                   -> guard str (NEW)
                                                   -> rt_is_tcl_alnum on a String
                                                   -> rt_set_contains on a String (1,200/run)
                                                test rax,rax; jne  completion
                                                cmp rax,6; je
tag test + add 2 + seto + rt_int_add path       tag test + add 2 + seto + rt_int_add path (same)
tail (jmp)                                      jmp (counted loop)
```

## Case 3: `refined-checks` / `char_at<generic>` (materializing variant)

```
CASE: bench/refined-checks.bot / emailish?'s char_at (NIR fn 11)

Observed benchmark direction:
    8,000 rt_substr per run = 4,763,609 Ir (58.1%) including allocation
    (between-run reclamation is excluded from every count here);
    R2: 3 rt_substr per run, all in esc_from, none in the scanners.

Last known good fence:   R2, e7d53b6
Old assembly artifact:    844c37e botlish_fn_10 char_at<generic> (region
                          companion: regioncheck + retmulti)
Current artifact:         c251e7c botlish_fn_11 char_at<generic> (rt_substr)

Machine-code regression:
    MATERIALIZATION: call rt_substr (595 Ir/call) per scanned character, in
    place of rt_str_region_check (38 Ir) + region triple;
    + frame 13 + overflow-checked i + 1 + root stores 4 per call
    (char_at's own 272,000 Ir self, 34 Ir per call).

Fact that would eliminate it:
    "every consumer of char_at(i)'s String here is a StringRegion consumer":
      TLD part (1,200/run):  the consumer is is_tcl_alpha -- a region
                             consumer (strregiontclalpha) -- if exact.
      local part (6,800/run): the consumer is local_char? = is_tcl_alnum (a
                             region consumer) OR immutable_set_contains (not
                             one).

Old NIR / metadata:  callmulti 10 ... retmulti %1 %0 %4 (region triple)
Current NIR:         %5 = op substr %1 %0 %4; ret %5
Current specialization key: char_at<generic>, theorem int, InstanceClosed 1
Current semantic instance:  char_at<int> -> str (valid)
Current facts:       hir::stringregion: the callvalue consumer is opaque;
                     with exact targets: ConsumingShape rejects local_char?<str>
                     at immutable_set_contains (post-module-statics census
                     stringregion-cf-exact.txt)

Earliest loss point:
    TLD half: the same hir::specialize projection as Case 2. The consumer
              is invisible because the callee is not exact.
    local half: hir::stringregion ConsumingShape -- set membership was
              never a region consumer.

Diagnosis:
    TLD half B; local half C (genuinely missing consumer). Trigger E (R2.a
    replaced `c == "." or ...` with immutable_set_contains).

Existing mechanism that could recover it:
    TLD half: yes -- the counterfactual's scan_alpha uses
              rt_str_region_is_tcl_alpha, 371 Ir/char (R2: 376).
    local half: no -- 6,800 rt_substr remain in the counterfactual
              (3,592,318 Ir, 52.9%).

Likely focused repair:
    #1 (exact identity), then a set-membership region consumer (#3)

Not implemented in this milestone.
```

## Case 4: `refined-checks` / `local_char?<generic>` (trampoline and kind guard)

```
CASE: lib/web.bot emailish?'s local_char?

Observed benchmark direction:
    6,800 calls/run, every one through the generic entry: entry self 47,600
    Ir, direct self 201,200 Ir. Did not exist at R2 (folded into
    scan_local's region tests).

Machine-code regression (per call):
    TRAMPOLINE: botlish_entry_12 (push, mov, load argv[0], call, ret)
    TYPE-GUARD: test rsi,7; jne; movzx al,[rsi]; cmp al,2; sete; test; jne
                -> rt_type_error   (guard str "is_tcl_alnum")
    GENERIC-CALL: reached only through rt_call_value (Case 2)

Fact that would eliminate it:
    c : str. The only call site passes char_at(i), whose HIR type is str.
    The guard exists because the call is not exact, so the callee is
    entered through its kind-agnostic generic entry.

Current NIR:       func 12 "local_char?" instance="generic":
                   guard str %0 "is_tcl_alnum"
Counterfactual:    func 12 "local_char?" instance="str", no guard, direct
                   call (cases/refined-checks/cf-exact-scanners.nir)
Current semantic instance: local_char?<str> -> bool (valid)
Current key:       local_char?<generic>, InstanceClosed 0 (correctly: it is
                   a value that escapes into callvalue)

Earliest loss point: same as Case 2 (hir::specialize projection)
Diagnosis:           B
Existing mechanism:  yes (semantic instance local_char?<str>; ordinary
                     specialization once the call is exact)
Likely focused repair: none of its own; follows from #1
Not implemented in this milestone.
```

## Case 5: `refined-checks` / scanner Int indices

```
CASE: scan_while's i, char_at's i + 1, domain?'s j

Observed benchmark direction:
    Unchanged from R2: R2's scan_local had the same tagged ige/iadd. It is
    a residual, not a regression. Upper bound ~2.1% of the program
    (post-R2.a census: range <-> blockescape).

Machine-code pattern (per character):
    TYPE-GUARD   and/test/jne on i,n before the compare (+ rt_int_cmp path)
    TAGGING      Bool word: mov ecx,2; cmovl [rip]; cmp rcx,6; je
    ERROR-PATH   tag test + add + seto/test/je + rt_int_add path on i+1
                 (twice: scan_while and char_at)
    SPILL        root store of the new i

Fact that would eliminate it:
    i in [0, n] (n = length(v) is small): every caller is known (start = 0
    from emailish?, i from tld?, which domain? feeds j + 1 with j in
    [start, n)).

Current facts:
    hir::specialize::closed (InstanceClosed) = 1 for char_at, scan_while,
    tld?, domain?; hir::range::OpenInstances = open for all four
    (out/facts/openness-refined-checks.txt) -> every entry Range [-inf, +inf]

Earliest loss point:
    hir::range::OpenInstances uses hir::aot::materializedBlocks (every bind
    of a capturing closure "materializes"), not the finer InstanceClosed
    proof hir::specialize already computed. R2's report found the same
    first loss.

Diagnosis:           A (fact exists above NIR, the Range pass ignores it)
Existing mechanism:  yes -- InstanceClosed + hir::range's ordinary
                     caller propagation
Likely focused repair: OpenInstances consults InstanceClosed for
                     generic closure instances (#2)
Not implemented in this milestone.
```

Control: `sum-refined`'s `step` captures only an Int. `Handle`'s
"scalar Int captures" exemption keys it `step<int>`, closed and not
Range-open (`out/facts/openness-sum-refined.txt`). `scan_while` captures
`v : str`, so the same rule sends it to the generic key.

## Case 6: `refined-checks` / `check` (refinement proofs, a closed despecialization window, runtime residue)

```
CASE: bench/refined-checks.bot / check

Observed benchmark direction:
    check self 25,258 Ir/run at R2, at R2.a and now; 46,880 at R2.a.2 and
    R2.a.3 (check<generic>; R2.a.1's committed asm is already check<generic>).

Refinement proofs (the benchmark's purpose):
    inner `emailish?(s)`  -- statically redundant: NO runtime call (current
                             NIR: L3 is `bool true`; 800 emailish? calls/run,
                             all from the outer test)
    `UriQueryValue?(q)`   -- proven by q's type: NO runtime call (`bool true`)
    Both survive since R2. No refinement proof is lost anywhere.

Historical window (closed):
    R2.a.1 (d20a69a, merged as 569ca4e; asm bf40b58): check<generic>,
      n entry [-inf, +inf]
      cause: local_extra_chars, a module value, was reached by capture, so
      emailish? became a closure, check captured it, and Handle's
      GenericKey collapse for value-capturing closures applied. That is the
      SAME projection rule as Case 2.
    module statics (f037c7d, asm 924482b): check<int, int, str, str>,
      n [0, 400] again.

Current residue per iteration (cases/refined-checks/check-current-*.asm):
    TAGGING/ERROR-PATH: acc + hit tagged add + overflow + rt_int_add path
        fact: acc <= 400 - n (relational) -- C (interval domain cannot hold it;
        same as loop-count's total and sum-refined's acc)
    SPILL: invariant s and q re-stored to root slots on every back edge; the
        immediate `hit` (1 or 3) stored to a root slot -- D (codegen::roots
        roots every non-raw register at each definition)
    The outer emailish?(s) call is loop-invariant (s never changes in
        check's self-tail recursion): only loop-invariant code motion over
        a pure call could hoist it. That is a new optimizer, out of scope,
        and not a regression.

Runtime residue (E):
    The same module-statics NIR costs 8,191,901 on its own census binary and
    8,236,097 on today's runtime (+0.54%): Vm::alloc::<StrObj> +3 Ir per
    allocation, rt_call_value restructured. Current NIR is 40,000 Ir cheaper
    (scan_while lost a guardbool to intrinsic contracts), so the net change
    is +0.05%. native/src changed in da45034 (AOT executables), 47e7a29,
    80ed8ec and fe9d6e8/5ddf3a8/8f651e5 (structs). Not bisected: it is
    below this milestone's threshold and is not a proof loss.

Diagnosis:  control for refinement (no loss); window B (closed);
            residues C, D, E
```

## Fib investigation

Per run: 57,313 calls, 28,656 internal and 28,657 leaf (`n < 2`). Executed
instructions: 28,656 × 49 + 28,657 × 20 = 1,977,284, which is exactly
`fib`'s self cost (`out/profiles/fib.bot/census.txt`).

Current `fib<int>` (`c251e7c` = `0c2dead`), annotated:

```
push rbp; mov rbp,rsp; sub rsp,0x30          frame
mov [rsp+0x10],rbx; [+0x18],r12; [+0x20],r13 frame: callee-saved spills  (every call, leaf too)
mov rbx,rdi                                  VM pointer staged in a callee-saved reg
mov QWORD PTR [rsp+0x8],0x0                  SPILL: root-slot zeroing (every call)
mov rax,rsi; sar rax,1                       UNTAGGING n            (runbox)
cmp rax,0x2; jl base                         raw n < 2             (rilt)   -- ideal
mov rsi,rax; sub rsi,1; mov r13,rax          n - 1 raw             (risub)  -- ideal
shl rsi,1; or rsi,1                          TAGGING n-1           (rbox)   for the call ABI
mov [rsp],rsi                                SPILL: root store of a small Int argument
mov rdi,rbx; call fib<int>                   direct recursive call -- ideal
mov r12,rax; mov [rsp],rax                   SPILL: root store of result 1 (live across call 2)
mov rsi,r13; sub rsi,2; shl rsi,1; or rsi,1  n - 2 raw, TAGGING
mov [rsp+0x8],rsi                            SPILL: root store of a small Int argument
mov rdi,rbx; call fib<int>
mov [rsp+0x8],rax                            SPILL: root store of result 2
mov rcx,r12; and rcx,rax; test rcx,1; jne    TYPE-GUARD: both results small Ints?
lea rcx,[rax-1]; mov..; add rax,rcx          tagged add
seto cl; test cl,cl; je done                 ERROR-PATH: overflow check
... call rt_int_add                           GENERIC-ARITH (cold: BigInt or overflow)
base: mov rax,rsi                            return n (tagged)
restore rbx,r12,r13; add rsp; mov rsp,rbp; pop rbp; ret
```

A hand-written x86-64 `fib` is `cmp edi,2; jl .b; push rbx; push rbp; …;
lea edi,[rbx-1]; call fib; mov ebp,eax; lea edi,[rbx-2]; call fib; add
eax,ebp; …; ret`. That is about 14 instructions per internal call and
`cmp/jl/mov/ret` (4) per leaf.

The same per-call view of what M9 already fixed (pre-M9 `caf8ca7` vs now):

```
pre-M9 (caf8ca7)                              M9 = current
test rsi,1; jne; call rt_int_cmp ...          mov rax,rsi; sar rax,1
mov r9d,2; cmp rsi,5; cmovl r9,[rip]          cmp rax,2
cmp r9,6; je                                  jl
sar; sub; shl; or ... (twice, re-derived)     sub (raw, hoisted runbox)
```

**Approximate dynamic amplification.** These are per-run estimates from the
instruction classes in `out/profiles/fib.bot/mix.txt`, not measured
counterfactuals:

| residue | per internal call | per leaf call | per run | share | fact | class |
|---|---:|---:|---:|---:|---|---|
| frame + callee-saved spills on leaf calls | – | ~15 | ~430,000 | ~22% | none (needs shrink-wrapping) | D |
| tag test + overflow + `lea` + 2 result root stores + slot zeroing | ~10 | 1 | ~344,000 | ~17% | result ∈ [0, 2^21] | C |
| retag ×2 (4) + untag (1–2) | ~5 | ~2 | ~172,000 | ~9% | raw-Int ABI from entry Range [0,22] | A |
| 2 argument root stores | 2 | – | 57,312 | 2.9% | `rbox` output is an immediate | D |

**Required fib questions**

6. *Worse now?* Nothing. `fib<int>` is byte-identical to the old-good M9 code.
   Against pre-M9 it is better: the tagged `n < 2` with an `rt_int_cmp` path
   and a Bool word became `sar; cmp; jl`, a 16.9% Ir reduction.
7. *Per recursive call?* The residues above are all per call: 49
   instructions per internal call and 20 per leaf.
8. *Is the broader behavior in NIR already?* Yes, every residue is explicit
   in NIR:
   * `op runbox %0`, `op rbox %8`/`%13` (tagging);
   * `op iadd %10 %15` (tagged add);
   * `call 1 %9` with a tagged argument.

   Cranelift does what NIR asks. The exception is the root stores of `rbox`
   results, which `codegen::roots` adds although NIR shows them immediate.
9. *Semantic instances?* `s0 fib<int> -> int` (valid). It is the only one.
10. *Codegen key?* `fib<int>`, KeyType `int`. It is closed, not generic.
    The entry Range is [0, 22]; the result Range is [-∞, +∞].
11. *Exact scalar/int fact lost?* No. `n : int ∈ [0, 22]` survives source →
    HIR → `hir::range` → NIR (`rilt`, `risub`). The result Range was never
    derived: hir::range has successful-result summaries for exact callees
    (loop-count's `work<int>` → [7, 7]), but a self-recursive result widens
    to unknown.
12. *Direct call replaced by a general path?* No. Both recursive calls are
    direct (`call 1`, `R_X86_64_PLT32 botlish_fn_1`).
13. *Wrapper/trampoline?* No. `botlish_entry_1` (the host-facing generic
    entry) exists and is never executed (entry invocations 0).
14. *Where does old-good stop being reconstructible?* Nowhere: current is
    old-good. The earliest *missing* fact for the residue is `hir::range`'s
    result summary for `fib<int>` (C). The earliest *unexploited* fact is the
    entry Range at the call ABI (A).

## Refined-checks investigation

**What the benchmark tests survives.** The inner `emailish?(s)` and
`UriQueryValue?(q)` are statically decided in `check`'s NIR and never run
(Case 6). The loss is entirely *inside* `emailish?`'s implementation: what
it costs to run the predicate once.

Same-binary series (`out/ir-series.txt`). Materializations are
`rt_substr` calls from each census minus the 3 that `esc_from` makes at every
fence:

| fence | Ir/run | vs R2 | Strings materialized by `char_at` per run | predicate dispatch |
|---|---:|---:|---:|---|
| pre-R2 (M9) `0c2dead` | 5,430,485 | +56.9% | 0 | native body, duplicated per call site |
| **R2** `e7d53b6` | **3,461,692** | — | **0** | direct region consumers |
| R2.a `63b2199` | 10,968,983 | +216.9% | 9,200 | `callvalue` (9,200/run) |
| R2.a.2 `b472022` | 9,392,986 | +171.3% | 9,200 | `callvalue` (9,200/run) |
| R2.a.3 `6dbcfdb` | 8,581,377 | +147.9% | 8,000 | `callvalue` (8,000/run) |
| module statics `924482b` | 8,236,097 | +137.9% | 8,000 | `callvalue` (8,000/run) |
| **current** `c251e7c` | **8,196,144** | **+136.8%** | **8,000** | `callvalue` (8,000/run) |
| counterfactual: exact targets (scratch) | 6,794,452 | +96.3% | 6,800 | direct |

**Required refined-check questions**

15. *Runtime checks present now and absent at R2:*
    * the `guard str` in `local_char?`'s generic body (6,800/run);
    * `rt_call_value`'s callee-kind/arity dispatch (8,000/run);
    * the completion test after each `callvalue` (8,000/run).

    The tag tests and Bool words on the scanner indices, the completion test
    after `char_at`, and the overflow check on `i + 1` were already present at
    R2. The bounds check moved from `rt_str_region_check` (10,000/run at R2)
    into `rt_substr` (8,000/run) plus 2,800 region checks.
16. *Proof that makes each redundant:*
    * `guard str`: the exact callee plus the argument type (`char_at(i) : str`);
    * dispatch and its completion test: the exact callee identity at each
      `scan_while` call site.
17. *In range analysis?* Not applicable to these: callable identity is not a
    Range fact. For the Case 5 index checks, `hir::range` does not hold the
    proof (OpenInstances), although `InstanceClosed` does.
18. *In refinement analysis?* The benchmark's refinements are held and used.
    The new checks are not refinement checks.
19. *In the semantic instance?* Yes. After `native::prepareHir`, the
    semantic layer has
    * `scan_while<int, block(e239)/1 -> bool>`,
    * `scan_while<int, native is_tcl_alpha>`,
    * `local_char?<str>`, `char_at<int>`, `tld?<int>` and `domain?<int>`

    (`out/facts/prepare-census-refined-checks.txt`).
20. *Retained by specialization?* No. `scan_while<generic>`, key
    `<any, any>`, closed-caller theorem `int any`.
21. *Exploited by NIR?* No: `callvalue %1 %7`, `call 11` (materializing),
    `guard str`.
22. *Stage responsible for the surviving checks:* `hir::specialize`'s codegen
    projection (`Handle`'s GenericKey collapse, `KeyType`, `ClosedCallerFacts`'
    KeyType join). The remaining materialization of the local part belongs to
    `hir::stringregion`'s `ConsumingShape` (no set-membership consumer).

## Improved numerical controls

| control | improved when | what it retains | layer where it diverges from the regressed case |
|---|---|---|---|
| `loop-count` `drive<int, int>`, `work<int>` | M9: 17,545 → 13,039 Ir (−25.7%), retained exactly | `i` entry [0, 500] raw (`rile`, `risub`); `work`'s result **exact [7, 7]** replaces the call result in `total + work(i)` | top-level, envless: specialized key, closed, not Range-open. `scan_while` is a value-capturing closure: generic key, Range-open |
| `fib<int>`'s argument arithmetic | M9: −16.9% | entry [0, 22]: raw compare, raw `n-1`/`n-2` | same as Case 1: only the *result* is missing |
| `sum-refined` `step<int>` | M9 capture seeds | key `step<int>` despite being a closure (Int-only captures are exempt) | the exemption is exactly what `scan_while` (captures `v : str`) misses |
| `matmul` `dot<List[int], List[List[int]], int, int, int, int>` | M8.a (whole program 1.12×), unchanged since | `k`, `count` raw (`rieq`, `riadd`); products tagged because elements are genuinely unbounded | top-level self-tail function: fully keyed |
| CSV/HashTable struct workloads | struct scalar replacement: −6.6% to −27.4% vs structs | struct values virtualized again | aggregate representation: not on the scalar path at all |

**Required control questions**

23. *Improved workloads:* `loop-count` (−25.7% Ir) and `fib` (−16.9%) at M9;
    `matmul` (1.12×) and the concat-heavy programs at M8.a; the CSV/HashTable
    struct workloads at struct scalar replacement. Over the struct/transport
    window no *scalar* workload moved in either direction, because its NIR is
    byte-identical.
24. *Facts they retain:* entry Int Ranges on keyed (non-generic) closed
    instances, through the self-tail fixpoint (M9). Exact result summaries
    of non-recursive exact callees. Int captures through closure keys.
25. *Where improved and regressed cases diverge:* at **instance selection in
    `hir::specialize`**. A keyed instance keeps its facts. A value-capturing
    closure is forced onto the generic key, and two consequences follow:
    1. `hir::range` treats the generic instance as open, and drops the entry
       Ranges (Case 5).
    2. A callable argument's identity, already reduced to a kind by
       `KeyType` everywhere, is joined to `any` (Cases 2–4).
26. *Support for the despecialization hypothesis?* For the struct/transport
    window and for `fib`, the comparison **weakens** it: nothing was
    despecialized there. For `refined-checks` it **supports** the mechanism:
    a precise semantic instance sits behind a broad codegen instance. But
    the projection rules involved are old. `KeyType`'s callable erasure dates
    from `a6ada2d` (specialization itself), and the value-capturing-closure
    GenericKey rule from `53c8a15` (2026-09-20). A source rewrite made them
    matter. In the traced windows only one compiler change removed a fact the
    compiler used before: R2.a.1's module-value capture, which made `check`
    generic. That window is closed.

## Assembly → NIR findings

Every traced pattern is already explicit in NIR:
* `callvalue`;
* `op substr`;
* `guard str`;
* `op iadd`/`op ilt` on tagged registers;
* `op rbox`, `op runbox`.

Cranelift lowered each as requested. Two backend-side items are real (D):
* **`codegen::roots` roots `rbox` results and tagged Int constants.** They
  are immediates by construction (`clif.rs`: `RBox` is `ishl 1; bor 1`).
  This costs 2 root stores per internal `fib` call and `check`'s `hit` store.
* **No shrink-wrapping.** `fib`'s leaf calls execute the full callee-saved
  prologue and epilogue.

Cranelift is not responsible for any regression.

## NIR → specialization findings

* `scan_while`, `char_at`, `tld?` and `domain?` are compiled under
  `<generic>` keys because they are value-capturing closures (`Handle`:
  "aggregate and managed captures retain the generic entry"). M7.c's
  closed-caller theorem then restores *kinds* (`int`) for their Int
  parameters, but never Ranges and never callable identity.
* `local_char?` is `<generic>` because it is only reached through `callvalue`.
  It is correctly not closed.
* `fib<int>`, `drive<int, int>`, `check<int, int, str, str>` and `dot<…>`
  are keyed and closed. Their NIR is as specific as their facts allow.
* No case showed an instance compiled under a broader *kind* than its
  callers pass. The broadening is in **callable identity** (Cases 2–4) and in
  **Range availability for generic instances** (Case 5).

## Specialization → semantic-instance findings

Semantic instances are precise wherever native code is broad:

| program | semantic instance | codegen instance |
|---|---|---|
| refined-checks | `scan_while<int, block(e239)/1 -> bool>`, `scan_while<int, native is_tcl_alpha>` | `scan_while<generic>` |
| refined-checks | `local_char?<str>` | `local_char?<generic>` |
| refined-checks | `char_at<int>`, `tld?<int>`, `domain?<int>` | `…<generic>` + theorem `int` |
| test-selection | `list::any?<List[str], block(e55)/1 -> bool>` | `list::any?<List[str], block>` + `callvalue` |
| lex-strategy | `list::all?<List[str], native is_tcl_alnum>` | `list::all?<List[str], native>` + `callvalue` |
| source-checks | `list::find<List[str], block(e114)/1 -> bool>` | `list::find<List[str], block>` + `callvalue` |
| probe `hof-single-exact` | `apply_loop<block(e2)/1 -> int, int, int>` | `apply_loop<block, int, int>` + `callvalue` |
| probe `hof-capturing` | `scan_while<int, native is_tcl_alpha>` | `scan_while<generic>`, theorem `int native` |

This is the direct test of §37: **the semantic instance is precise, and the
codegen instance is broad.** Separating "semantic precision" from "codegen
representation" (`hir/semantic.tcl`: "hir::specialize::KeyType is
deliberately untouched") classified exact callable identity as
representation-irrelevant. `KeyType`'s own comment says so: "a call through
either is the same indirect callvalue". That premise holds only *because* the
key erases the identity. With the identity kept, the call is direct and every
consumer downstream (exact-call facts, StringRegion, blockescape, tiny-leaf
inlining) sees it. The `hof-single-exact` probe shows the erasure is
universal: one site, one target, no captures, and the call is still
`callvalue`.

## Range-proof findings

| range | source → HIR range → specialization → NIR → machine | where it stops |
|---|---|---|
| `fib.n` [0, 22] | proven, kept, raw in NIR and machine code | — (survives) |
| `fib` result | never proven (self-recursive result widens) | `hir::range` result summary: C |
| `check.n` [0, 400] | proven, kept, raw | — (survives since module statics) |
| `check.acc`, `drive.total` | [0, +∞]: relational bound not expressible | interval domain: C |
| `scan_while.i`, `char_at.i`, `domain?.j` | closed callers known; Range `[-∞, +∞]` | `hir::range::OpenInstances` ignores `InstanceClosed`: A |
| `dot.k`, `drive.i` | proven, raw | — (survives) |

## Refinement-proof findings

Type refinement (`emailish?` → `str[Emailish]`) and the exact-value
refinement of `q` (`str[UriQueryValue]`) both reach codegen. The
redundant-check branch and the `UriQueryValue?` test fold to `bool true` in
`check<int, int, str, str>`'s NIR. The codegen key erases `q`'s refinement
(`str`), but the decision is already made in the instance's overlay, so
nothing is lost. `refined-checks` has **no** refinement-proof loss. Its
regression is in callable-identity and representation facts *inside* the
predicate.

## Exact-call findings

* Exact *direct* calls survive everywhere: `fib`, `check → emailish?`,
  `emailish? → scan_while/domain?`, `tld? → scan_while`.
* Exact *callable arguments* never survive to a call. That holds in every
  program and every probe. The corpus has 8 `callvalue` sites in 4
  canonical programs (`refined-checks` 1, `test-selection` 3,
  `lex-strategy` 2, `source-checks` 2). 6 of them have an exact callable in
  their semantic instance:
  * `refined-checks`' `scan_while`;
  * `test-selection`'s `list::any?`, `list::none?` and `list::find`
    (`block(e55)`, `block(e94)`);
  * `lex-strategy`'s `list::all?<List[str], native is_tcl_alnum>`;
  * `source-checks`' `list::find<List[str], block(e114)>`.

  The other two (`source-checks`' List-held checks, `lex-strategy`'s
  `classify`) are genuinely dynamic.

## Codegen-sharing findings

`scan_while<generic>` is shared by two semantically distinct instances: an
exact Botlish predicate and an exact native.

* *What sharing saves:* one ~500-byte function.
* *What sharing costs:*
  * per character: one `rt_call_value` dispatch (30.7 Ir self, 225.5
    inclusive) and one completion test;
  * on the local part: a trampoline and a `guard str`;
  * on the TLD part: a String materialization, because the TLD consumer
    becomes opaque.

  The measured cost is 1,401,692 Ir/run (17.1%). The historical
  `check<generic>` shared one generic body between all callers for the same
  reason (value-capturing closure), and cost 21,622 Ir/run (0.25%).

## Wrapper/trampoline findings

* `local_char?`'s generic entry (`botlish_entry_12`) runs 6,800 times per
  run, only because `callvalue` targets generic entries.
* No companion, fields, fields+companion or struct-transport variant appears
  on any traced scalar path.
* `char_at`'s two NIR functions (region companion fn 10, materializing
  fn 11) are both legitimate. Each serves call sites that do or do not
  consume a region.
* Every `botlish_entry_*` of `fib`, `loop-count` and `sum-refined` has 0
  executions (`sum-refined`'s `step<generic>` is materialized but never
  entered).

## `native::prepareHir` (§36)

`prepareHir` attaches `web::emailish?` (and `uri_escape_text`) and re-checks
the HIR. It is **exonerated** for every traced case.

* Its re-check *creates* the precise semantic instances of the email
  closures: 2 semantic instances before, 19 after.
* It does not broaden any exact call. `check`'s `emailish?(s)` becomes a
  direct `call 9`.

It broadens one semantic instance. `check`'s generic-body self-call goes
from `check<int, int, str, any>` to `check<int, int, any, any>`. The native
`emailish?` declares its parameter `str`, while the attached
`web::emailish?` has no parameter contract (`hir::signatures::entryTypes`
is empty). So after the call, the generic body no longer has `s : str`.
This has no codegen effect: the codegen instance is
`check<int, int, str, str>`, keyed by the program's own call sites, with no
guard.

## Earliest loss points

| case | earliest point where old-good and current diverge (or the fact first goes missing) |
|---|---|
| 1 `fib` | none diverges; result Range is never derived (`hir::range`) |
| 2 `scan_while` callvalue | `hir::specialize`: GenericKey for value-capturing closures, then `ClosedCallerFacts` joins `KeyType`s; `KeyType` alone erases identity |
| 3 `char_at` materialization | TLD: as Case 2. Local: `hir::stringregion::ConsumingShape` (set membership) |
| 4 `local_char?` guard/trampoline | as Case 2 |
| 5 scanner indices | `hir::range::OpenInstances` (materialization test instead of `InstanceClosed`) |
| 6 `check` | none now; historical window lost at the same `Handle` GenericKey rule as Case 2 |

## Diagnosis-class summary

**27. Count by class** (each traced symptom once):

* **A**, fact exists above NIR and is unexploited: 2. `fib`'s raw-Int ABI;
  the scanner index Ranges.
* **B**, fact lost by codegen projection: 4. `scan_while`'s `callvalue`;
  `local_char?`'s trampoline and guard; the TLD-path materialization; the
  historical `check<generic>`.
* **C**, fact never recovered: 3. `fib`'s result Range; the local-part
  materialization (set membership); `check`'s accumulator bound.
* **D**, backend / machine lowering: 2. `rbox`/immediate root stores;
  no shrink-wrapping on `fib`'s leaf calls.
* **E**, not a proof-loss regression: 3. `fib`'s timing "regression"
  (identical code); the runtime-side +0.54% on identical NIR; the R2.a
  source rewrite as the trigger.

**28. Dominant class:** B, by both count and measured cost. It accounts for
the whole −17.1% counterfactual, and the remaining C cost cannot be reached
until B is fixed. C is the largest cost that remains after B.

**29. One shared loss point?** Yes: `hir::specialize`'s projection of
semantic facts onto codegen keys, in two coupled rules.
1. A value-capturing closure gets the generic key.
2. `KeyType` (also inside `ClosedCallerFacts`) erases callable identity.

They explain Cases 2, 3 (TLD), 4 and the historical Case 6 window. Case 5 is
the same generic keying seen through `hir::range`'s openness test.

**30. Independent cases:**
* `fib` (all residues);
* the local-part set-membership materialization;
* accumulator bounds;
* the runtime-side residue.

## Existing mechanisms capable of recovering each fact

| lost/missing fact | can the compiler already derive it? | where | why it does not reach machine code / what is missing |
|---|---|---|---|
| exact predicate at each `scan_while` site | **yes** | HIR argument types; `hir::semantic` (post-`prepareHir`) instances | codegen keys and closed-caller theorems carry kinds only |
| `local_char?`'s parameter is `str` | **yes** | semantic `local_char?<str>`; `char_at` result type | only usable once the call is exact |
| TLD characters can stay regions | **yes** | `hir::stringregion` (is_tcl_alpha is a consumer) | consumer invisible behind `callvalue` |
| local characters can stay regions | **no** | — | minimal missing piece: set membership as a StringRegion consumer (region hashing/equality against a set of Strings) |
| scanner index Ranges | **yes** | `hir::specialize::closed` (InstanceClosed) + `hir::range` caller propagation | `OpenInstances` uses the coarser materialization test |
| `fib` result ∈ [0, 2^21] | **partially** | `hir::range` result summaries (non-recursive callees), entry Range [0, 22], `hir::induction`'s termination reasoning | minimal missing analysis: depth-bounded (non-widening) result iteration for a self-recursive instance whose Int argument strictly decreases within a finite proven Range |
| `fib` raw-Int arguments | **yes** | entry Range [0, 22], InstanceClosed, `RawParams` (self-tail only, prologue unbox) | the call ABI is uniformly tagged; no raw-parameter entry exists |
| `rbox` output not a heap reference | **yes** | NIR (`op rbox`) | `codegen::roots` treats every non-raw register as managed-capable |
| `check.acc ≤ 400 - n` | **no** | — | relational domain (out of scope everywhere so far) |

## Likely focused repairs (not implemented)

| # | repair | rank | fixes | risk surface / other paths affected |
|---|---|---|---|---|
| 1 | **Carry exact callable identity through codegen projection for closed instances.** Give `KeyType` (and `ClosedCallerFacts`' per-caller contribution) an exact callable key component when the callee instance is closed and its callable arguments are exact (`block E` / `native N`). Allow per-target keys for value-capturing closures whose captures blockescape flattens. Lower a call through a parameter whose key is exact as a direct `call`/`callenv`/`native` | root-cause restoration | Cases 2, 3 (TLD), 4; −17.1% measured on `refined-checks` | instance count (bounded by distinct exact targets, keep a budget); M7.c's rule that `CloseCallers` creates no instance after the fixpoint (identity must enter at `Handle`, not in the theorem pass); StringRegion, blockescape and tiny-leaf inlining all re-run on more exact calls; affects the `callvalue` sites of `test-selection` and `lex-strategy` (higher-order `list::*` helpers). A native-lowering-only devirtualization caps at the dispatch share (~6%, post-module-statics census) and misses the region exposure |
| 2 | `hir::range::OpenInstances` consults `InstanceClosed` for generic closure instances | local exploitation of an existing fact | Case 5, ≤ ~2% | soundness rests on blockescape's RefsAsCalls proof, already trusted by M7.c; ordering is fine (`hir::specialize::closed` exists before `hir::range` runs) |
| 3 | Set membership (`immutable_set_contains`/`setcontainstotal`) on a one-character region: a StringRegion consumer with a region-aware runtime lookup | new analysis + runtime (root cause for C) | Case 3 local half: up to 6,800 Strings, ≤ 52.9% of post-#1 Ir | hashing/equality must match String hashing exactly; the runtime set API; only useful after #1 |
| 4 | `codegen::roots`: never root `rbox` results or tagged Int constants | local exploitation (backend) | `fib` 2 stores/internal call (~2.9%), `check`'s `hit`; general | stack-map/root tests that pin slot counts (`tests/native-root-liveness.test`) |
| 5 | Depth-bounded result summaries for self-recursive Int functions with a strictly decreasing argument in a finite proven Range | root-cause analysis (C) | `fib`'s tagged add, overflow, result roots (~17% est.) | widening/termination soundness in `hir::range`; analysis time on large Ranges (needs a budget) |
| 6 | Raw-Int parameter/result ABI for closed instances whose entry Range fits small | local exploitation (A), ABI change | `fib` retag/untag (~9% est.), the same residue in `drive`/`check` | generic entries must keep the tagged ABI; JIT/AOT entry trampolines; GC (raw is never a root, which helps) |
| 7 | Leaf fast path / shrink-wrapping | backend (D) | `fib`'s leaf frames (~22% est.) | Cranelift territory; out of scope for a proof milestone |

No peephole workaround is proposed: every symptom traced to a missing or
erased fact.

## Cases that disproved the despecialization hypothesis

* **`fib`**: no despecialization and no regression at all. Every per-call
  cost is either a fact never derived (result Range) or an ABI/backend
  residue M9 already documented.
* **The struct / struct-scalar-replacement / value-transport window**:
  * no scalar NIR changed;
  * `refined-checks`' +0.05% is runtime allocation-path cost on identical
    NIR;
  * struct scalar replacement recovered the aggregate regressions the
    structs milestone introduced: per-function sizes and allocation counts
    are back to the pre-struct values.
* **`refined-checks`' trigger**: the loss did not come from a compiler
  milestone removing a fact. It came from R2.a's source rewrite exposing a
  long-standing projection rule. The *mechanism* matches the hypothesis
  (precise semantic instance, broad codegen instance). The *cause* is
  partly E.

## Regression introduction windows

| regression | last known good | first known bad | between | status |
|---|---|---|---|---|
| `refined-checks` predicate dispatch + materialization (+216.9% at first) | R2 `e7d53b6` (asm `844c37e`; 3,461,692 Ir) | R2.a `63b2199` (asm `f508532`; 10,968,983 Ir) | one commit: the `lib/web.bot` rewrite (`scan_while(start, predicate)`, `immutable_set_contains`) | partially recovered by R2.a.2, R2.a.3, module statics and intrinsic contracts; still +136.8% |
| `check<generic>` (lost `n ∈ [0, 400]`; +21,622 Ir) | R2.a `63b2199` | R2.a.1 `d20a69a`, merged as `569ca4e` (asm `bf40b58`) | R2.a.1's module-fn bridge reachability (`local_extra_chars` reached by capture) | **closed** at module statics `f037c7d` (asm `924482b`) |
| struct-era CSV scanner / HashTable rehash growth | `84f4d68` | structs `bee7c03` (asm `46d658d`) | source refactor to structs | **closed** at struct scalar replacement `90e9e97` (asm `b370d52`): per-function sizes equal `84f4d68`'s |
| runtime allocation path +0.54% on identical NIR | module statics' census binary (`native/src` as of `924482b`) | current | `native/src` changes in `da45034`, `47e7a29`, `80ed8ec`, `fe9d6e8`/`5ddf3a8`/`8f651e5` | open, E, not bisected (below threshold) |
| `fib` | — | — | — | no regression (M9 `0c2dead` best, unchanged) |

## Required historical questions

1. **Which commits/fences contain the old-good code?** `fib`, `loop-count`,
   `sum-refined`: M9, compiler `a3c0550`. `refined-checks`: R2, compiler
   `e7d53b6`. The pre-struct fence for the NIR comparison is `84f4d68`.
2. **Where are the committed assembly artifacts?**
   `audit/native-scalar-asm/bench/{fib,loop-count,sum-refined,refined-checks}.asm`
   at `0c2dead` (M9) and `844c37e` (R2); historical NIR and callgrind
   censuses under `audit/post-r2a-dynamic-census/profiles/history/` and
   `audit/post-module-static-exact-target-census/profiles/`.
3. **Same commit or shortly after?** Shortly after. Each assembly
   regeneration is the CI commit immediately following its compiler fence
   (`0c2dead` 17 minutes after `a3c0550`, `844c37e` 48 minutes after
   `e7d53b6`). The historical NIR/callgrind censuses were committed later
   (`2b82c5b`, `ac64bb4`), generated from worktrees of the named fences.
4. **How was provenance established?**
   * Each regeneration's `README.md` names its generating commit, and that
     commit equals the regeneration's parent.
   * Regeneration commits touch only `audit/`.
   * `f44fd3c`, where these disagree, was excluded.
   * The censuses' own READMEs name the worktree fences.
   * Re-running the committed historical NIR on today's runtime reproduced
     the committed counts within 0.2% for unchanged-runtime fences.
   * Regenerating the current corpus reproduced the committed assembly
     byte-for-byte.
5. **Narrowest known intervals:** see the table above. The `refined-checks`
   regression is pinned to a single commit (`e7d53b6` → `63b2199`).

## Recommended fix order

1. **Exact callable identity through codegen projection** (#1). This is the
   only *regression* the investigation found with a compiler-side root
   cause. It is the largest measured item (−17.1%), it is shared by four
   symptoms, and it is a prerequisite for #3. Acceptance for the focused
   milestone:
   * `scan_while`'s two sites lower to direct calls;
   * `local_char?<str>` has no guard;
   * the TLD scan uses region consumers (371 Ir/char, R2 level);
   * `refined-checks` ≤ ~6.8 M Ir/run;
   * no instance is created after `CloseCallers`;
   * the corpus's other `callvalue` sites are re-audited.
2. **Range openness consults `InstanceClosed`** (#2). Small and low-risk,
   on the same closures. It can ride with #1.
3. **Set-membership region consumer** (#3). This is the largest remaining
   `refined-checks` cost, and it is new machinery.
4. **`rbox`/immediate root stores** (#4). Small, general, backend-local.
5. **Self-recursive result Ranges** (#5), then **raw-Int ABI** (#6), for
   `fib`-like kernels. These are improvements, not regression repairs.
6. Backend frame work (#7) is outside a proof-loss milestone.

## Readiness for focused optimization milestone

**Ready.** Each lost or missing fact has:
* a named earliest loss point (function and rule);
* a statement of whether existing machinery derives it;
* a measured or estimated payoff.

The next milestone can be one focused fix (#1, optionally with #2) with a
measurable acceptance target. It needs no new search: the counterfactual
already measures #1's ceiling on the current compiler. `fib` needs no
regression repair at all. Its residues are improvement work with their own,
independent root causes.

## Reproduction

```sh
export LANG=C.utf8 LC_ALL=C.utf8
cargo build --release --manifest-path native/Cargo.toml
bash audit/machine-code-proof-loss/tools/run-all.sh /tmp/mcpl-scratch
```

`run-all.sh` regenerates the assembly corpus and diffs it. It replays the
committed-history size tables, emits NIR, dumps facts per layer, builds the
audit binary in scratch, profiles every program and historical NIR, and
measures the exact-target counterfactual in a scratch worktree. A second
full run reproduced every non-callgrind artifact byte-for-byte, and every
Ir/run total within 220 Ir. The committed `out/profiles/` are the first run,
the one this report quotes.

## Summary table

| case | machine symptom | required fact | earliest loss | diagnosis | existing recovery mechanism? |
|---|---|---|---|---|---|
| 1 `fib<int>` | none vs old-good; per internal call: tag test + overflow + `rt_int_add` path + 2 result root stores, slot zeroing | result ∈ [0, 2^21] for n ∈ [0, 22] | never derived: `hir::range` self-recursive result summary | C (history: E) | partially: result summaries exist for non-recursive callees; needs depth-bounded recursion |
| 1 `fib<int>` | +4 retag (`shl`/`or`) per internal call, +1 untag per call | callers pass small Ints (entry [0, 22]) | not consumed: uniform tagged call ABI | A | yes: `hir::range` entry Range + InstanceClosed; no raw-param ABI |
| 1 `fib<int>` | +2 argument root stores per internal call | `rbox` result is an immediate | `codegen::roots` | D | yes: explicit in NIR |
| 1 `fib<int>` | full frame + 3 callee-saved spills on 28,657 leaf calls | none | backend (no shrink-wrapping) | D | no |
| 2 `scan_while` | `callvalue` → `rt_call_value` per character (8,000/run) | predicate is exactly `local_char?` / `is_tcl_alpha` per call site | `hir::specialize`: closure GenericKey + `KeyType`/`ClosedCallerFacts` erase callable identity | B (trigger E: R2.a rewrite) | yes: HIR argument types and semantic instances are exact; −17.1% measured |
| 3 `char_at` (TLD) | `rt_substr` per TLD character (1,200/run) | consumer is `is_tcl_alpha` (a region consumer) | as Case 2 | B | yes: StringRegion, once exact (371 Ir/char = R2) |
| 3 `char_at` (local) | `rt_substr` per local character (6,800/run) | consumer only tests alnum / set membership | `hir::stringregion` ConsumingShape: no set-membership consumer | C | no: needs a set-membership region consumer |
| 4 `local_char?` | generic-entry trampoline + `guard str` (6,800/run) | `c : str`, callee exact | as Case 2 | B | yes: semantic `local_char?<str>` |
| 5 scanner indices | tag tests, Bool word, overflow-checked `i + 1` per character | `i ∈ [0, n]` (all callers known) | `hir::range::OpenInstances` ignores InstanceClosed | A | yes: InstanceClosed + Range caller propagation |
| 6 `check` (history) | `check<generic>`: tagged `n` compare/sub, +21,622 Ir/run | `n ∈ [0, 400]`, keyed instance | `hir::specialize` closure GenericKey (as Case 2) | B (closed at module statics) | yes (recovered) |
| 6 `check` | tagged `acc + hit` + overflow; invariant `s`/`q` and immediate `hit` re-rooted per iteration | `acc ≤ 400 − n`; immediates/invariants need no re-store | interval domain; `codegen::roots` | C; D | no (relational); yes (NIR) |
| runtime | +0.54% Ir on identical NIR (allocation path) | — | `native/src` runtime changes since `924482b` | E | n/a |
