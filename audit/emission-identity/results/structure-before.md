## Structural audit: identity and feasibility

seeds 1-40; compiler: a copy of the tree whose hir/emission.tcl is the milestone's parent's (53a0d1b); the program and an edited version of it, every claim decided for 4 switch assignments with a fresh memo, with it off, and after the other version (the memo kept, two rounds); every emitter of both run for every argument tuple of every assignment (interp)

| seed | result |
|---|---|
| 1 | rejected 2, proven 8; shared names: h, e, f; edit: h (line 25): a symbol changed |
| 2 | rejected 2, proven 2; shared names: h, e; edit: nested h (line 30) removed |
| 3 | proven 8; shared names: e; edit: h (line 25): a symbol changed |
| 4 | FALSE CERTIFICATE (program, line 38): e (digit_token), s = true true, args = (): completes with {49 66}, which is not one token: accept 1 0 |
| 4 | FALSE CERTIFICATE (edited, line 38): e (digit_token), s = true true, args = (): completes with {49 66}, which is not one token: accept 1 0 |
| 4 | proven 6; shared names: h, e; edit: nested h (line 72) removed |
| 5 | HISTORY DIFFERS: edited, memo off, false false; edited, memo off, false true; edited, memo off, true false; edited, memo off, true true; program, memo off, false false; program, memo off, false true; program, memo off, true false; program, memo off, true true |
| 5 | FALSE CERTIFICATE (program, line 115): f (digit_token), s = true true, args = (): completes with 66, which is not one token: unrecognized digit_token start 0 |
| 5 | FALSE CERTIFICATE (program, line 35): e (pair_token), s = true true, args = (0): completes with {50 65 50}, which is not one token: accept 2 0 |
| 5 | FALSE CERTIFICATE (program, line 159): f (pair_token), s = true false, args = (): completes with 66, which is not one token: unrecognized pair_token start 0 |
| 5 | FALSE CERTIFICATE (edited, line 99): f (digit_token), s = true true, args = (): completes with 66, which is not one token: unrecognized digit_token start 0 |
| 5 | FALSE CERTIFICATE (edited, line 35): e (pair_token), s = true true, args = (0): completes with {50 65 50}, which is not one token: accept 2 0 |
| 5 | FALSE CERTIFICATE (edited, line 143): f (pair_token), s = true false, args = (): completes with 66, which is not one token: unrecognized pair_token start 0 |
| 5 | proven 14; shared names: h, e, f; edit: nested h (line 43) removed |
| 6 | HISTORY DIFFERS: edited after the other (round 1), false false; edited after the other (round 1), false true; edited after the other (round 1), true false; edited after the other (round 1), true true; edited after the other (round 2), false false; edited after the other (round 2), false true; edited after the other (round 2), true false; edited after the other (round 2), true true; edited, memo off, false false; edited, memo off, false true; edited, memo off, true false; edited, memo off, true true; program after the other (round 1), false false; program after the other (round 1), false true; program after the other (round 1), true false; program after the other (round 1), true true; program after the other (round 2), false false; program after the other (round 2), false true; program after the other (round 2), true false; program after the other (round 2), true true; program, memo off, false false; program, memo off, false true; program, memo off, true false; program, memo off, true true |
| 6 | FALSE CERTIFICATE (program, line 113): e (digit_token), s = true true, args = (): completes with 65, which is not one token: unrecognized digit_token start 0 |
| 6 | FALSE CERTIFICATE (edited, line 113): e (digit_token), s = true true, args = (): completes with 65, which is not one token: unrecognized digit_token start 0 |
| 6 | proven 8, rejected 2; shared names: h, g, f, e; edit: h (line 25): a symbol changed |
| 7 | rejected 4, proven 6; shared names: e; edit: g (line 29): a symbol changed |
| 8 | HISTORY DIFFERS: edited, memo off, false false; edited, memo off, false true; edited, memo off, true false; edited, memo off, true true; program, memo off, false false; program, memo off, false true; program, memo off, true false; program, memo off, true true |
| 8 | FALSE CERTIFICATE (program, line 51): e (digit_token), s = true true, args = (0 0): completes with {49 65}, which is not one token: accept 1 0 |
| 8 | FALSE CERTIFICATE (edited, line 51): e (digit_token), s = true true, args = (0 0): completes with {49 65}, which is not one token: accept 1 0 |
| 8 | proven 6, rejected 2; shared names: h, e; edit: h (line 25): a symbol changed |
| 9 | HISTORY DIFFERS: edited, memo off, false false; edited, memo off, false true; edited, memo off, true false; edited, memo off, true true; program, memo off, false false; program, memo off, false true; program, memo off, true false; program, memo off, true true |
| 9 | proven 14; shared names: h, g, e, f; edit: h (line 25): a symbol changed |
| 10 | rejected 6, proven 2; shared names: e; edit: g (line 78): a symbol changed |
| 11 | HISTORY DIFFERS: edited, memo off, false false; edited, memo off, false true; edited, memo off, true false; edited, memo off, true true |
| 11 | rejected 2, proven 4; shared names: h, g, e; edit: h (line 77): a symbol changed |
| 12 | proven 5, rejected 1; shared names: g, e; edit: g (line 40): a symbol changed |
| 13 | FALSE CERTIFICATE (program, line 53): e (pair_token), s = true true, args = (): completes with {65 65}, which is not one token: unrecognized pair_token start 0 |
| 13 | FALSE CERTIFICATE (edited, line 53): e (pair_token), s = true true, args = (): completes with {65 65}, which is not one token: unrecognized pair_token start 0 |
| 13 | proven 8; shared names: h, e; edit: h (line 41): a symbol changed |
| 14 | (discarded: edited: the erased program does not compile: <input>:110:17: function result does not prove declared type List[int]) |
| 15 | proven 6; shared names: h, e; edit: h (line 34): a symbol changed |
| 16 | proven 6; shared names: h, g, e; edit: h (line 47): a symbol changed |
| 17 | proven 14; shared names: h, g, e, f; edit: h (line 25): a symbol changed |
| 18 | proven 8, rejected 2; shared names: h, e, f; edit: nested h (line 70) removed |
| 19 | proven 8, rejected 2; shared names: h, f, g, e; edit: nested h (line 73) removed |
| 20 | proven 10; shared names: h, f, e; edit: h (line 40): a symbol changed |
| 21 | FALSE CERTIFICATE (edited, line 65): e (pair_token), s = true true, args = (): completes with 49, which is not one token: end pair_token second 1 |
| 21 | rejected 4, proven 2; shared names: h, e; edit: nested h (line 62) removed |
| 22 | FALSE CERTIFICATE (program, line 45): e (pair_token), s = true false, args = (): completes with {65 66}, which is not one token: unrecognized pair_token start 0 |
| 22 | FALSE CERTIFICATE (edited, line 41): e (pair_token), s = true false, args = (): completes with {65 66}, which is not one token: unrecognized pair_token start 0 |
| 22 | proven 6; shared names: h, g, e; edit: nested g (line 41) removed |
| 23 | proven 2, rejected 4; shared names: h, g, e; edit: h (line 34): a symbol changed |
| 24 | FALSE CERTIFICATE (edited, line 72): f (digit_token), s = true false, args = (): completes with 66, which is not one token: unrecognized digit_token start 0 |
| 24 | rejected 2, proven 4; shared names: e; edit: g (line 30): a symbol changed |
| 25 | HISTORY DIFFERS: edited, memo off, false false; edited, memo off, false true; edited, memo off, true false; edited, memo off, true true; program, memo off, false false; program, memo off, false true; program, memo off, true false; program, memo off, true true |
| 25 | FALSE CERTIFICATE (program, line 100): e (pair_token), s = true true, args = (0 0): completes with {49 50}, which is not one token: unrecognized pair_token second 1 |
| 25 | FALSE CERTIFICATE (edited, line 100): e (pair_token), s = true true, args = (0 0): completes with {49 50}, which is not one token: unrecognized pair_token second 1 |
| 25 | proven 6; shared names: h, e; edit: h (line 86): a symbol changed |
| 26 | FALSE CERTIFICATE (program, line 47): e (pair_token), s = true true, args = (): completes with {65 65}, which is not one token: unrecognized pair_token start 0 |
| 26 | FALSE CERTIFICATE (program, line 107): e (digit_token), s = true true, args = (): completes with 65, which is not one token: unrecognized digit_token start 0 |
| 26 | FALSE CERTIFICATE (edited, line 47): e (pair_token), s = true true, args = (): completes with {65 65}, which is not one token: unrecognized pair_token start 0 |
| 26 | FALSE CERTIFICATE (edited, line 98): e (digit_token), s = true true, args = (): completes with 65, which is not one token: unrecognized digit_token start 0 |
| 26 | rejected 2, proven 10; shared names: h, f, e; edit: nested h (line 98) removed |
| 27 | FALSE CERTIFICATE (edited, line 32): e (digit_token), s = true true, args = (): completes with 66, which is not one token: unrecognized digit_token start 0 |
| 27 | FALSE CERTIFICATE (edited, line 66): e (digit_token), s = true true, args = (): completes with 66, which is not one token: unrecognized digit_token start 0 |
| 27 | proven 4, rejected 2; shared names: e; edit: h (line 25): a symbol changed |
| 28 | HISTORY DIFFERS: edited, memo off, false false; edited, memo off, false true; edited, memo off, true false; edited, memo off, true true; program, memo off, false false; program, memo off, false true; program, memo off, true false; program, memo off, true true |
| 28 | FALSE CERTIFICATE (program, line 73): e (digit_token), s = true true, args = (): completes with 66, which is not one token: unrecognized digit_token start 0 |
| 28 | FALSE CERTIFICATE (edited, line 73): e (digit_token), s = true true, args = (): completes with 66, which is not one token: unrecognized digit_token start 0 |
| 28 | FALSE CERTIFICATE (edited, line 109): e (digit_token), s = true false, args = (): completes with 66, which is not one token: unrecognized digit_token start 0 |
| 28 | proven 10; shared names: h, e, f; edit: h (line 106): a symbol changed |
| 29 | FALSE CERTIFICATE (program, line 33): e (pair_token), s = true false, args = (): completes with 65, which is not one token: unrecognized pair_token start 0 |
| 29 | FALSE CERTIFICATE (edited, line 33): e (pair_token), s = true false, args = (): completes with 65, which is not one token: unrecognized pair_token start 0 |
| 29 | proven 6, rejected 2; shared names: h, e, f; edit: h (line 25): a symbol changed |
| 30 | proven 4, rejected 4; shared names: h, e, g; edit: h (line 25): a symbol changed |
| 31 | FALSE CERTIFICATE (program, line 103): e (digit_token), s = true true, args = (0): completes with {49 49}, which is not one token: accept 1 0 |
| 31 | FALSE CERTIFICATE (edited, line 103): e (digit_token), s = true true, args = (0): completes with {49 49}, which is not one token: accept 1 0 |
| 31 | proven 8; shared names: h, e; edit: g (line 38): a symbol changed |
| 32 | FALSE CERTIFICATE (program, line 37): e (digit_token), s = false true, args = (): completes with {}, which is not one token: end digit_token start 0 |
| 32 | FALSE CERTIFICATE (edited, line 37): e (digit_token), s = false true, args = (): completes with {}, which is not one token: end digit_token start 0 |
| 32 | proven 10; shared names: h, e, f; edit: h (line 25): a symbol changed |
| 33 | rejected 6, proven 2; shared names: g, e, f; edit: nested g (line 69) removed |
| 34 | proven 6; shared names: h, g, e; edit: nested h (line 97) removed |
| 35 | proven 10; shared names: h, e, f; edit: g (line 51): a symbol changed |
| 36 | HISTORY DIFFERS: edited, memo off, false false; edited, memo off, false true; edited, memo off, true false; edited, memo off, true true; program, memo off, false false; program, memo off, false true; program, memo off, true false; program, memo off, true true |
| 36 | FALSE CERTIFICATE (program, line 44): e (pair_token), s = true false, args = (0 0): completes with {65 65}, which is not one token: unrecognized pair_token start 0 |
| 36 | FALSE CERTIFICATE (edited, line 44): e (pair_token), s = true false, args = (0 0): completes with {65 65}, which is not one token: unrecognized pair_token start 0 |
| 36 | proven 6, rejected 2; shared names: h, e; edit: g (line 41): a symbol changed |
| 37 | HISTORY DIFFERS: edited, memo off, false false; edited, memo off, false true; edited, memo off, true false; edited, memo off, true true; program, memo off, false false; program, memo off, false true; program, memo off, true false; program, memo off, true true |
| 37 | FALSE CERTIFICATE (program, line 60): f (pair_token), s = true true, args = (0 1): completes with 65, which is not one token: unrecognized pair_token start 0 |
| 37 | FALSE CERTIFICATE (program, line 150): e (digit_token), s = true true, args = (0): completes with 65, which is not one token: unrecognized digit_token start 0 |
| 37 | FALSE CERTIFICATE (edited, line 60): f (pair_token), s = true true, args = (0 1): completes with 65, which is not one token: unrecognized pair_token start 0 |
| 37 | FALSE CERTIFICATE (edited, line 150): e (digit_token), s = true true, args = (0): completes with 65, which is not one token: unrecognized digit_token start 0 |
| 37 | proven 10, rejected 4; shared names: h, f, g, e; edit: g (line 42): a symbol changed |
| 38 | rejected 2, proven 4; shared names: h, e; edit: nested h (line 65) removed |
| 39 | HISTORY DIFFERS: edited after the other (round 1), false false; edited after the other (round 1), false true; edited after the other (round 1), true false; edited after the other (round 1), true true; edited after the other (round 2), false false; edited after the other (round 2), false true; edited after the other (round 2), true false; edited after the other (round 2), true true; program after the other (round 1), false false; program after the other (round 1), false true; program after the other (round 1), true false; program after the other (round 1), true true; program after the other (round 2), false false; program after the other (round 2), false true; program after the other (round 2), true false; program after the other (round 2), true true |
| 39 | FALSE CERTIFICATE (program, line 72): e (digit_token), s = true true, args = (): completes with 65, which is not one token: unrecognized digit_token start 0 |
| 39 | FALSE CERTIFICATE (edited, line 72): e (digit_token), s = true true, args = (): completes with 65, which is not one token: unrecognized digit_token start 0 |
| 39 | proven 10, rejected 2; shared names: h, g, e, f; edit: g (line 49): a symbol changed |
| 40 | proven 4, rejected 2; shared names: h, g, e; edit: g (line 45): a symbol changed |

| total | |
|---|---:|
| programs | 39 |
| claims | 330 |
| proven | 267 |
| rejected | 63 |
| not-proved | 0 |
| dependent | 0 |
| false certificate | 43 |
| history differs | 10 |
| rejected, confirmed | 63 |
| precision loss | 0 |
| discarded | 1 |
| runs | 2604 |
| parameterless claims | 178 |
| names of several functions | 104 |
| claims whose name is shared | 294 |
| edits removing a shadowing helper | 12 |
