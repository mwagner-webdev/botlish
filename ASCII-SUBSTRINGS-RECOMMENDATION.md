# Recommendation: should the next milestone prove that `substring` results are ASCII?

**Short answer: not as the next milestone, and not as framed.** On the
corpus it would change no instruction count, because the cost it appears to
attack (the allocation behind a runtime materialization) is not something an
ASCII proof removes, and the one thing it does enable -- virtualizing
multi-character ASCII slices -- has no workload in the corpus. Do a
measurement-only step first (below) and build the static half only if a real
workload shows up; put the effort on cheaper materialization instead.

All numbers are from this tree (`SHORT-STRING-TIERS.md` regime, with the demand
rule); the instrumentation counters live in a scratch build, not in the repo.

## What the milestone would be

Track "known ASCII" as a property independent of length, so that

* `substring(t, i, i + K)` of a text proven ASCII is ASCII with exactly `K`
  characters (K constant, or the existing induction step); and
* K <= 8 makes the slice a packed-ASCII value (tier A) via a new op
  `strsliceascii base start end` after the existing `regioncheck`.

Today `Mk` collapses every fact longer than 8 characters to `over:long`,
dropping the ASCII bit, so a long ASCII literal is no more informative than
an arbitrary String. The lattice change is small (keep `asc` for any length;
the tier rule is unchanged); soundness rests on literals, `substring` of an
ASCII text, and (optionally) `concat`/`lowercase` of ASCII operands, all of
which are immutable-value facts.

## What it would and would not buy

**It does not make materialization cheaper.** A packed value is materialized
by `asciitostr`, which allocates exactly as `shorttostr` does. The measured
~315 instructions per runtime materialization is two `malloc`s plus `Vm::alloc`
bookkeeping, not UTF-8 encoding. The earlier observation that 91 % of the
ShortString1 materializations are in fact ASCII is therefore a fact about the
alphabet, not about cost: proving it moves values between tiers without
touching the allocation.

**What it does buy**

1. *Multi-character ASCII slices without allocation.* `substring(t, i, i + 4)
   == "http"` becomes `regioncheck` + `strsliceascii` + `asciieq`: no `rt_substr`
   allocation, no `streq` call. This is the real prize, and it is the idiom of
   tokenizers, keyword matchers and protocol parsers.
2. Slightly cheaper one-character handling (no `first` field, no UTF-8
   decode on extraction; equality against an ASCII literal is `asciieq`, not
   `asciishorteq`).
3. Better joins: an ASCII slice joins an ASCII literal in tier A instead of
   degrading the whole position to ShortString1 or tagged.

## Evidence on the corpus

Static: 15 live `substring` sites in 11 programs.

| | sites with ASCII base text | result changes tier |
|---|---:|---|
| today | 4 (all `string_replace`, base is a short literal) | none |
| with ASCII kept for any length | 8 | 3 sites go ShortString1 -> packed, all width 1 (`refined-checks`, `csv`, `csv_records`) |
| **multi-character constant-width ASCII slices** | | **0** |

The heavy programs get no static proof at all: `uri-steady` takes its text
from `list_get(corpus, ...)`, `source-checks` and `ai_text_clean` from
parameters fed by other containers and calls, `lex-strategy` from the program
input. Facts do not survive containers, and the `uri-steady` corpus
deliberately includes non-ASCII text ("café", a CJK string).

Dynamic (counters in the slice helpers, one run per program, base text's
runtime `ascii` flag, by width):

| program | slices | width 1 | width 2..8 | base ASCII at run time |
|---|---:|---:|---:|---|
| uri-steady | 14,000 | 14,000 | 0 | 7,500 (54 %) |
| refined-checks | 10,803 | 10,800 | 0 | 4,803 (44 %) |
| lex-strategy | 198 | 198 | 0 | 186 (94 %) |
| csv_records | 144 | 126 | 18 | 100 % |
| csv | 43 | 37 | 6 | 100 % |
| string_replace | 20 | 8 (+7 empty) | 5 | 100 % |
| source-checks | 21 | 21 | 0 | 17 (81 %) |
| string_reverse | 11 | 11 | 0 | 100 % |

About 25,200 of 25,240 slices are width 1; **29 are width 2..8 (0.1 %)**, in
three tiny programs. About half of all slices have a non-ASCII base at run
time, so even a perfect dynamic guard would route half of this corpus to the
slow path. The multi-character case that justifies the milestone is present
in the corpus only in `csv`/`csv_records`/`string_replace` and only a handful
of times.

Expected effect on the corpus: nothing measurable. The three width-1 sites
that would change tier save the `first`-field load per extraction (a few
instructions); the 29 multi-character slices would each save roughly one
`rt_substr` allocation (~250-300 instructions) -- about 8,000 instructions
across programs whose steady-state counts are 20,000 to 100,000, and only if
the slice's consumer is a scalar comparison (the demand rule would otherwise
keep it tagged).

## Risks and costs

* Soundness is easy for literals and `substring`; it gets harder as producers
  are added (`lowercase` must be ASCII-preserving for ASCII input; `concat`
  needs length bounds the lattice does not have). Every added producer is new
  inference, which the previous milestones deliberately avoided.
* `strsliceascii` needs a bounds-checked, non-overrunning byte read (a helper;
  an inline load of eight bytes can run past the allocation).
* The ASCII bit survives only along the paths facts already follow (aliases,
  joins, closed calls). It does not cross containers, the dominant source of
  text in the corpus, and it never reaches program input.
* More tier-A positions mean more materialization frontiers; the demand rule
  must stay on, and the tiered-regime losses (`hashtable`, `string_replace`)
  show how quickly an unconsumed tier-A value becomes a regression.

## Recommended sequence

1. **Measurement-only step (days).** Add the counters above permanently as an
   audit mode and run them on realistic text-processing programs (a lexer, a
   CSV/INI/URL parser, `ai_text_clean` on real input), recording per slice
   width, base ASCII-ness and consumer (scalar compare vs stored). The go/no-go
   criterion: at least ~10 % of slices on a representative workload are
   width 2..8 *and* compared with literals *and* have a base the planner could
   prove or a dynamic guard could cheaply check.
2. **Only if (1) says yes: the static half (about a week).** Lattice change,
   `substring` rule, `strsliceascii` helper, fuzz generator extended with
   long ASCII literals and slices of width 2..8, the three corpus tier changes
   as a regression guard. Success: no corpus regression, zero allocations for
   a literal-compare tokenizer kernel in the test suite.
3. **Dynamic ASCII only on evidence from (1).** Entry-guarded specialization
   on `StrObj.ascii` (a one-load check at function entry choosing an
   all-packed body) is a much larger design (function multiversioning, code
   size, a second NIR variant per instance) and should be proposed separately.

## What I would do instead, in order of expected return

1. **Make the runtime materialization cheap.** It is the measured dominant
   cost: ~315 instructions x ~21,000 ShortString1 materializations in the
   corpus. Options that stay inside "no String-storage redesign" are limited
   to the interned table you asked me to remove; the real fix is a small-string
   representation (inline text in `StrObj` for <= 8 bytes, one allocation
   instead of two), which is a storage change and so its own milestone.
2. **Finish the demand rule's cost model** (allocation-weighted: producer
   allocation avoided versus runtime materializations, literals free). The use
   rule now in the tree fully recovers `refined-checks` and `hashtable`, but it
   also gives up `source-checks`' original gain, which a producer-aware model
   would keep.
3. Revisit ASCII provenance when a text-processing workload exists to
   measure it against.
