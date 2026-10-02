# `loop-count` wall-clock: code placement, not the raw ABI

`bench/loop-count.bot` measured 732 ns (tagged ABI, A), 893 ns (eligibility-only
RawInt, B) and 1,063 ns (production, D) in `botlish-native bench`, while
executing *fewer* instructions with RawInt (13,039 -> 12,037 Ir) and smaller,
tighter code. This directory records why that is **not** a cost of the raw ABI.

## Machine

Intel Xeon @ 2.10 GHz, family 6 model 207 (Emerald Rapids, Golden Cove cores).
That core is not affected by the Skylake JCC erratum, so the first hypothesis
(a conditional jump crossing a 32-byte boundary) does not apply; it was also
not borne out by the data below (no jump-boundary rule separates fast from slow).

## What the three builds actually differ in

The hot loop is `drive`'s body plus a call of the folded-constant `work`
(`push rbp; mov rbp,rsp; mov eax,0xf; mov rsp,rbp; pop rbp; ret`). A has two
extra instructions per iteration (`shl`/`or`, the retag of the counter) and a
`sar` at entry; B and D do not. Nothing else differs: same stores, same
tag test and overflow check on the accumulator, same call/ret/jmp.

## Experiment 1: the real JIT, function alignment (`BOTLISH_FN_ALIGN`)

A scratch copy of `native/` with Cranelift's `log2_min_function_alignment` set
from an environment variable (not part of the repository), `nativebench`
(best of 7, 500 runs), ns:

| minimum function alignment | A tagged | B | C | D production |
|---|---:|---:|---:|---:|
| none (as shipped) | 731 | 904 | 904 | 1,062 |
| 16 bytes | 743 | 891 | 892 | 891 |
| 32 bytes | 727 | 888 | 888 | 888 |
| 64 bytes | 798 | 894 | 893 | 893 |

Moving the functions changes D by up to 19 % and A by up to 10 % with no change
to any instruction.

## Experiment 2: the real JIT, a few bytes of shift

Changing only the initial accumulator, `drive(500, N)`, changes the size of the
`<program>` function by a few bytes and so shifts `work` and `drive`:

| N | A | B | C | D |
|---|---:|---:|---:|---:|
| 0 | 741 | 894 | 1,063 | 1,027 |
| 5 | 731 | 898 | 1,063 | 1,063 |
| 100 | 737 | 896 | 1,062 | 1,062 |
| 70000 | 738 | 895 | 1,063 | 1,062 |
| 5000000000 | 728 | 897 | 894 | 895 |
| 3000000000000000 | 728 | 1,062 | 894 | 894 |

Identical loop code gives 728-741 or 894-897 or 1,062-1,063 depending only on
where it lands; the ordering of B and D flips between rows.

## Experiment 3: standalone assembly sweep (`tools/placement/`)

The JIT'd `work` + `drive` of the three builds, instruction for instruction, in
a C harness (gcc + rdtsc-free `clock_gettime`, best of 9 x 20,000 calls of 500
iterations), each placed at all 64 offsets from a 64-byte boundary
(`sweep.txt`), ns per 500-iteration call:

| | min | p25 | median | p75 | max | mean |
|---|---:|---:|---:|---:|---:|---:|
| A tagged | 729 | 920 | 1,157 | 1,228 | 1,246 | 1,076 |
| B eligibility only | 724 | 899 | 1,004 | 1,154 | 1,238 | 995 |
| D production | 726 | 901 | 971 | 1,176 | 1,592 | 1,037 |

The **best case is the same for all three (about 725 ns, 1.45 ns per
iteration)**; every variant is 1.2-1.6x slower at unlucky offsets; the means
are within 8 % and D's mean is *below* A's. The raw-ABI code is not
systematically slower; where each build lands decides the single-point number.
(1.45 ns per iteration is what three taken branches per iteration -- the call,
the `ret` and the loop `jmp` -- cost at about one taken branch per cycle; the
slow placements look like extra front-end bubbles. This is an interpretation,
not a measured mechanism.)

## What was ruled out, and what is not known

* Not the JCC erratum (wrong CPU), and no simple per-branch rule explains the
  slow offsets: whether a `call`/`ret`/`jmp` crosses or ends at a 16/32/64-byte
  boundary does not separate fast from slow (checked over the 192 placements).
* Not instruction count, register assignment or the planner's choices.
* The exact microarchitectural mechanism (decoded-uop cache, BTB, return
  prediction) is **undetermined**; this machine has no `perf`/hardware counters.

## Consequence

The wall-clock regression in `loop-count` is placement luck on a
sub-microsecond, 500-iteration run, not a cost of the RawInt ABI or of demand
suppression. It is a backend concern (code and loop alignment; Cranelift has a
function-alignment setting but no loop or branch alignment), recorded for the
later machine-code audit. Instruction counts remain the reliable per-program
figure; wall-clock differences under about +-50 % on runs this short should not
be attributed to the representation without a placement sweep.
