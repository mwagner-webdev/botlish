## Emission checker costs

Compiler: this checkout (53a0d1b with this milestone's hir/emission.tcl); 5 fresh processes per program.

| program | claims | certified | checker ms (median, range) | summaries computed / reused | rounds |
|---|---:|---:|---|---|---:|
| JSON | 22 | 22 | 230 (220-307) | 140 / 60 | 44 |
| CSV | 52 | 52 | 582 (539-674) | 207 / 121 | 104 |

Compiled twice in one process (the memo kept):

| program | claims reused by the second compilation | checker ms, first / second |
|---|---:|---|
| JSON | 22 of 22 (certified: 22) | 293 / 31 |
| CSV | 52 of 52 (certified: 52) | 545 / 39 |
| 12 scopes, every name shared | 0 of 12 (certified: 12) | 27 / 18 |
| 12 scopes, names of their own | 12 of 12 (certified: 12) | 27 / 5 |
