# The two fuzz seeds that did not terminate (seeds 100262 and 200167)

`tools/fuzz.tcl` (older generator) produced two programs that did not finish
within the runner's limits in the 3,100-program differential run. Their text is
in `seeds.txt`. **Neither is a compiler or ABI bug**: both are correct programs
whose exact (arbitrary-precision) result is astronomically large, they behave
the same in every backend, and the hang predates and is independent of the
RawInt ABI.

## Seed 100262: `f2(100, 100, 100)`

```
fn f2(a, b, c):
    if a < 3:  (c * 1000)
    else:      f2(a - 1, (c * b), (b + 1000)) + (((0 - 2^62) + c) - (c * 3))
```

The recursive call passes `(c * b)` as the new `b` and `(b + 1000)` as the new
`c`, so `b` follows `b_k = b_{k-1} * (b_{k-2} + 1000)`: the number of digits
grows like the Fibonacci numbers. Measured digits of `f2(a, 100, 100)` (native,
all four plans and the interpreter agree wherever the interpreter finishes):

| a | 10 | 15 | 20 | 22 | 24 | 26 | 30 | 34 | 36 | 38 |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| digits | 80 | 852 | 9,419 | 24,653 | 64,536 | 168,951 | 1,157,987 | 7,936,938 | 20,779,167 | 54,400,560 |

(×phi^2 = 2.618 per two levels). Native takes 0.03 s at a=20, 10 s at a=34 and
171 s at a=38 (multiplying multi-million-digit numbers); the interpreter 1.3 s
at a=20, 499 s at a=26. At the program's a=100 the result has about
10^20.7 digits: it cannot exist, in any backend, and there is nothing to
compare. `seed100262-agreement.txt`: at a=22 the interpreter and all four native
plans (tagged ABI, eligibility-only, mixed-raw, production) return the same
24,653-digit value (equal CRC-32), and at a=34 the four native plans return the
same 7,936,938-digit value.

## Seed 200167: `f2(49, 49, 9)`

`f2` recurses 24 times with `b -> b * b`, so `b` ends with 49^(2^24), a
94-million-bit (28.4-million-digit) number, and every level adds it into the
result. The digits double every two levels (a=13..21: 110, 218, 434, 867,
1,732; a=49: 28,356,786). It **does terminate**: native computes the complete
result in about 50 s (`seed200167-agreement.txt`): the four native plans (tagged
ABI, eligibility-only, mixed uses raw, production) return the same
28,356,786-digit value, equal CRC-32 3766412979. The runner had skipped it only
because its per-seed limit (20 s) is shorter than that, and under GC stress each
allocation forces a collection, which is slower still.

## Conclusion and what changed

* Not an ABI bug: tagged ABI, interpreter and every raw plan behave alike, agree
  on every value they can reach, and the compile steps take milliseconds
  (the work is in the runtime's BigInt multiplication, which is the language's
  arbitrary-precision semantics doing what it is specified to do). The
  language has no Int size limit, so there is no error to raise; behaviour on
  true memory exhaustion (a=100 needs ~10^20 digits) was not probed.
* The generator was at fault: a recursive helper fed `*` expressions back into
  its own non-measure arguments with a measure up to 700. `tools/fuzz.tcl` now
  builds those arguments with `+`/`-` only (`linexpression`), so every generated
  program terminates quickly. The previous results (1,500 + 1,499 + 299
  programs, 0 disagreements) stand for the old generator; a fresh run with the
  new generator is recorded in `RAW-INT-ABI.md` (Differential testing).
