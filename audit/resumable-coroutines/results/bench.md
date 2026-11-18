<!-- bench/resumable-coroutines.tcl, 2026-11-17, the session's 4-core Linux x86-64 container; the stock driver (stackful, native-frame roots) and the fallback-roots driver of commit eda7d08 (resumable, ShadowOnly); run alone, after the golden sweeps. Times are this machine's, comparable within a table only. -->

# Resumable coroutines: performance report

Drivers: stackful /home/user/botlish/native/target/release/botlish-native, resumable /home/user/target-fallback/release/botlish-native; best of 3 runs.

## generator: 1,000,000 resumes of one generator

| configuration | best | allocations | frames (bytes) | coroutines | peak live | GCs (time) | maxrss | value |
|---|---:|---:|---:|---:|---:|---:|---:|---|
| stackful, fusion on | 3.08 ms | 0 | 0 (0 B) | 0 | 0 B | 0 (0.0 ms) | 13,316 KiB | {int 499999499999} |
| stackful, fusion off | 49.97 ms | 2 | 0 (0 B) | 1 | 152 B | 0 (0.0 ms) | 13,316 KiB | {int 499999499999} |
| resumable, fusion on | 2.38 ms | 0 | 0 (0 B) | 0 | 0 B | 0 (0.0 ms) | 13,408 KiB | {int 499999499999} |
| resumable, fusion off | 15.39 ms | 4 | 2 (96 B) | 1 | 248 B | 0 (0.0 ms) | 13,328 KiB | {int 499999499999} |

## many: 10,000 coroutines suspended at once

| configuration | best | allocations | frames (bytes) | coroutines | peak live | GCs (time) | maxrss | value |
|---|---:|---:|---:|---:|---:|---:|---:|---|
| stackful, fusion on | 174.85 ms | 30,005 | 0 (0 B) | 10,000 | 2,211,208 B | 93 (106.2 ms) | 53,132 KiB | {int 50025000} |
| stackful, fusion off | 258.52 ms | 30,005 | 0 (0 B) | 10,000 | 2,211,208 B | 93 (158.0 ms) | 53,220 KiB | {int 50025000} |
| resumable, fusion on | 3.54 ms | 50,005 | 20,000 (800,000 B) | 10,000 | 2,912,904 B | 1 (0.3 ms) | 15,064 KiB | {int 50025000} |
| resumable, fusion off | 2.53 ms | 50,005 | 20,000 (800,000 B) | 10,000 | 2,912,904 B | 1 (0.3 ms) | 14,908 KiB | {int 50025000} |

## deep-1: 20,000 resumes, each yield 1 yielding activations deep

| configuration | best | allocations | frames (bytes) | coroutines | peak live | GCs (time) | maxrss | value |
|---|---:|---:|---:|---:|---:|---:|---:|---|
| stackful, fusion on | 1.22 ms | 2 | 0 (0 B) | 1 | 160 B | 0 (0.0 ms) | 13,328 KiB | {int 399980001} |
| stackful, fusion off | 1.02 ms | 2 | 0 (0 B) | 1 | 160 B | 0 (0.0 ms) | 13,320 KiB | {int 399980001} |
| resumable, fusion on | 0.49 ms | 6 | 4 (160 B) | 1 | 320 B | 0 (0.0 ms) | 13,316 KiB | {int 399980001} |
| resumable, fusion off | 0.46 ms | 6 | 4 (160 B) | 1 | 320 B | 0 (0.0 ms) | 13,396 KiB | {int 399980001} |

## deep-10: 20,000 resumes, each yield 10 yielding activations deep

| configuration | best | allocations | frames (bytes) | coroutines | peak live | GCs (time) | maxrss | value |
|---|---:|---:|---:|---:|---:|---:|---:|---|
| stackful, fusion on | 1.35 ms | 2 | 0 (0 B) | 1 | 160 B | 0 (0.0 ms) | 13,304 KiB | {int 399980010} |
| stackful, fusion off | 1.02 ms | 2 | 0 (0 B) | 1 | 160 B | 0 (0.0 ms) | 13,316 KiB | {int 399980010} |
| resumable, fusion on | 1.27 ms | 15 | 13 (448 B) | 1 | 608 B | 0 (0.0 ms) | 13,312 KiB | {int 399980010} |
| resumable, fusion off | 1.24 ms | 15 | 13 (448 B) | 1 | 608 B | 0 (0.0 ms) | 13,312 KiB | {int 399980010} |

## deep-100: 20,000 resumes, each yield 100 yielding activations deep

| configuration | best | allocations | frames (bytes) | coroutines | peak live | GCs (time) | maxrss | value |
|---|---:|---:|---:|---:|---:|---:|---:|---|
| stackful, fusion on | 1.03 ms | 2 | 0 (0 B) | 1 | 160 B | 0 (0.0 ms) | 13,356 KiB | {int 399980100} |
| stackful, fusion off | 1.03 ms | 2 | 0 (0 B) | 1 | 160 B | 0 (0.0 ms) | 13,348 KiB | {int 399980100} |
| resumable, fusion on | 19.37 ms | 105 | 103 (3,328 B) | 1 | 3,488 B | 0 (0.0 ms) | 13,304 KiB | {int 399980100} |
| resumable, fusion off | 10.80 ms | 105 | 103 (3,328 B) | 1 | 3,488 B | 0 (0.0 ms) | 13,328 KiB | {int 399980100} |

## deep-1000: 20,000 resumes, each yield 1000 yielding activations deep

| configuration | best | allocations | frames (bytes) | coroutines | peak live | GCs (time) | maxrss | value |
|---|---:|---:|---:|---:|---:|---:|---:|---|
| stackful, fusion on | 1.03 ms | 2 | 0 (0 B) | 1 | 160 B | 0 (0.0 ms) | 13,316 KiB | {int 399981000} |
| stackful, fusion off | 1.03 ms | 2 | 0 (0 B) | 1 | 160 B | 0 (0.0 ms) | 13,312 KiB | {int 399981000} |
| resumable, fusion on | 122.12 ms | 1,005 | 1,003 (32,128 B) | 1 | 32,288 B | 0 (0.0 ms) | 13,328 KiB | {int 399981000} |
| resumable, fusion off | 123.71 ms | 1,005 | 1,003 (32,128 B) | 1 | 32,288 B | 0 (0.0 ms) | 13,316 KiB | {int 399981000} |

## dfa: a declared recognizer over 1,000,000 symbols

| configuration | best | allocations | frames (bytes) | coroutines | peak live | GCs (time) | maxrss | value |
|---|---:|---:|---:|---:|---:|---:|---:|---|
| stackful, fusion on | 3.53 ms | 2 | 0 (0 B) | 0 | 96 B | 0 (0.0 ms) | 13,316 KiB | {list {{int 1} {int 0}}} |
| stackful, fusion off | 137.80 ms | 1,000,007 | 0 (0 B) | 2 | 1,048,760 B | 38 (27.5 ms) | 13,320 KiB | {list {{int 1} {int 0}}} |
| resumable, fusion on | 3.48 ms | 2 | 0 (0 B) | 0 | 96 B | 0 (0.0 ms) | 13,316 KiB | {list {{int 1} {int 0}}} |
| resumable, fusion off | 88.02 ms | 1,000,013 | 6 (208 B) | 2 | 1,048,864 B | 38 (26.2 ms) | 13,328 KiB | {list {{int 1} {int 0}}} |

## churn: 100,000 constructions released suspended

| configuration | best | allocations | frames (bytes) | coroutines | peak live | GCs (time) | maxrss | value |
|---|---:|---:|---:|---:|---:|---:|---:|---|
| stackful, fusion on | 5.38 ms | 100,000 | 0 (0 B) | 0 | 1,048,600 B | 3 (2.9 ms) | 13,316 KiB | {int 4999950000} |
| stackful, fusion off | 25.13 ms | 300,000 | 0 (0 B) | 100,000 | 12,440 B | 1562 (9.5 ms) | 13,392 KiB | {int 4999950000} |
| resumable, fusion on | 5.28 ms | 100,000 | 0 (0 B) | 0 | 1,048,600 B | 3 (2.0 ms) | 13,328 KiB | {int 4999950000} |
| resumable, fusion off | 25.79 ms | 500,000 | 200,000 (7,200,000 B) | 100,000 | 1,048,608 B | 25 (10.6 ms) | 13,348 KiB | {int 4999950000} |

## loop-sleepers: 10,000 mostly idle tasks sleeping 5 times each (std::event_loop, deterministic driver)

| configuration | best | allocations | frames (bytes) | coroutines | peak live | GCs (time) | maxrss | value |
|---|---:|---:|---:|---:|---:|---:|---:|---|
| stackful, fusion on | 319.54 ms | 70,086 | 0 (0 B) | 10,000 | 7,751,040 B | 49 (102.8 ms) | 59,192 KiB | {int 29430} |
| stackful, fusion off | 355.07 ms | 70,086 | 0 (0 B) | 10,000 | 7,751,040 B | 49 (100.1 ms) | 59,212 KiB | {int 29430} |
| resumable, fusion on | 124.88 ms | 150,086 | 80,000 (2,880,000 B) | 10,000 | 8,113,920 B | 3 (9.1 ms) | 27,112 KiB | {int 29430} |
| resumable, fusion off | 119.04 ms | 150,086 | 80,000 (2,880,000 B) | 10,000 | 8,113,920 B | 3 (8.7 ms) | 27,196 KiB | {int 29430} |

## loop-yielders: 100 tasks yielding 1,000 times each (std::event_loop, deterministic driver)

| configuration | best | allocations | frames (bytes) | coroutines | peak live | GCs (time) | maxrss | value |
|---|---:|---:|---:|---:|---:|---:|---:|---|
| stackful, fusion on | 25.19 ms | 286 | 0 (0 B) | 100 | 26,752 B | 1 (0.0 ms) | 13,632 KiB | {int 1000} |
| stackful, fusion off | 24.87 ms | 286 | 0 (0 B) | 100 | 26,752 B | 1 (0.0 ms) | 13,356 KiB | {int 1000} |
| resumable, fusion on | 20.49 ms | 586 | 300 (12,000 B) | 100 | 31,200 B | 0 (0.0 ms) | 13,784 KiB | {int 1000} |
| resumable, fusion off | 18.41 ms | 586 | 300 (12,000 B) | 100 | 31,200 B | 0 (0.0 ms) | 13,584 KiB | {int 1000} |

## Machine code of the yielding functions (fusion off)

| workload | functions | stackful | resumable | ratio |
|---|---:|---:|---:|---:|
| generator | 2 | 371 B | 1,275 B | 3.44 |
| many | 2 | 340 B | 1,213 B | 3.57 |
| deep | 3 | 827 B | 2,456 B | 2.97 |
| dfa | 6 | 2,648 B | 5,428 B | 2.05 |
| churn | 2 | 296 B | 1,200 B | 4.05 |
| loop-sleepers | 4 | 814 B | 2,762 B | 3.39 |
| loop-yielders | 3 | 319 B | 1,721 B | 5.39 |
