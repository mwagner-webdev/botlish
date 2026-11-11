## Structural audit: identity and feasibility

seeds 1-40; compiler: this checkout; the program and an edited version of it, every claim decided for 4 switch assignments with a fresh memo, with it off, and after the other version (the memo kept, two rounds); every emitter of both run for every argument tuple of every assignment (interp)

| seed | result |
|---|---|
| 1 | rejected 2, proven 8; shared names: h, e, f; edit: h (line 25): a symbol changed |
| 2 | rejected 2, proven 2; shared names: h, e; edit: nested h (line 30) removed |
| 3 | proven 8; shared names: e; edit: h (line 25): a symbol changed |
| 4 | rejected 2, proven 4; shared names: h, e; edit: nested h (line 72) removed |
| 5 | rejected 6, proven 8; shared names: h, e, f; edit: nested h (line 43) removed |
| 6 | proven 6, rejected 4; shared names: h, g, f, e; edit: h (line 25): a symbol changed |
| 7 | rejected 4, proven 6; shared names: e; edit: g (line 29): a symbol changed |
| 8 | proven 4, rejected 4; shared names: h, e; edit: h (line 25): a symbol changed |
| 9 | precision loss (program, line 113): e (digit_token), rejected, every run valid |
| 9 | precision loss (edited, line 113): e (digit_token), rejected, every run valid |
| 9 | proven 12, rejected 2; shared names: h, g, e, f; edit: h (line 25): a symbol changed |
| 10 | rejected 6, proven 2; shared names: e; edit: g (line 78): a symbol changed |
| 11 | rejected 2, proven 4; shared names: h, g, e; edit: h (line 77): a symbol changed |
| 12 | proven 5, rejected 1; shared names: g, e; edit: g (line 40): a symbol changed |
| 13 | proven 6, rejected 2; shared names: h, e; edit: h (line 41): a symbol changed |
| 14 | (discarded: edited: the erased program does not compile: <input>:110:17: function result does not prove declared type List[int] (result type: list)) |
| 15 | proven 6; shared names: h, e; edit: h (line 34): a symbol changed |
| 16 | proven 6; shared names: h, g, e; edit: h (line 47): a symbol changed |
| 17 | proven 14; shared names: h, g, e, f; edit: h (line 25): a symbol changed |
| 18 | proven 8, rejected 2; shared names: h, e, f; edit: nested h (line 70) removed |
| 19 | proven 8, rejected 2; shared names: h, f, g, e; edit: nested h (line 73) removed |
| 20 | proven 10; shared names: h, f, e; edit: h (line 40): a symbol changed |
| 21 | rejected 5, proven 1; shared names: h, e; edit: nested h (line 62) removed |
| 22 | proven 4, rejected 2; shared names: h, g, e; edit: nested g (line 41) removed |
| 23 | proven 2, rejected 4; shared names: h, g, e; edit: h (line 34): a symbol changed |
| 24 | rejected 3, proven 3; shared names: e; edit: g (line 30): a symbol changed |
| 25 | proven 4, rejected 2; shared names: h, e; edit: h (line 86): a symbol changed |
| 26 | rejected 6, proven 6; shared names: h, f, e; edit: nested h (line 98) removed |
| 27 | proven 2, rejected 4; shared names: e; edit: h (line 25): a symbol changed |
| 28 | proven 7, rejected 3; shared names: h, e, f; edit: h (line 106): a symbol changed |
| 29 | rejected 4, proven 4; shared names: h, e, f; edit: h (line 25): a symbol changed |
| 30 | proven 4, rejected 4; shared names: h, e, g; edit: h (line 25): a symbol changed |
| 31 | proven 6, rejected 2; shared names: h, e; edit: g (line 38): a symbol changed |
| 32 | rejected 2, proven 8; shared names: h, e, f; edit: h (line 25): a symbol changed |
| 33 | rejected 6, proven 2; shared names: g, e, f; edit: nested g (line 69) removed |
| 34 | proven 6; shared names: h, g, e; edit: nested h (line 97) removed |
| 35 | proven 10; shared names: h, e, f; edit: g (line 51): a symbol changed |
| 36 | proven 4, rejected 4; shared names: h, e; edit: g (line 41): a symbol changed |
| 37 | proven 6, rejected 8; shared names: h, f, g, e; edit: g (line 42): a symbol changed |
| 38 | rejected 2, proven 4; shared names: h, e; edit: nested h (line 65) removed |
| 39 | proven 8, rejected 4; shared names: h, g, e, f; edit: g (line 49): a symbol changed |
| 40 | proven 4, rejected 2; shared names: h, g, e; edit: g (line 45): a symbol changed |

| total | |
|---|---:|
| programs | 39 |
| claims | 330 |
| proven | 222 |
| rejected | 108 |
| not-proved | 0 |
| dependent | 0 |
| false certificate | 0 |
| history differs | 0 |
| rejected, confirmed | 106 |
| precision loss | 2 |
| discarded | 1 |
| runs | 2604 |
| parameterless claims | 178 |
| names of several functions | 104 |
| claims whose name is shared | 294 |
| edits removing a shadowing helper | 12 |
