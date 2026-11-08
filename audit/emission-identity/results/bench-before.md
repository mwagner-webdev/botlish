## Emission checker costs

Compiler: a copy of the tree whose hir/emission.tcl is the milestone's parent's (53a0d1b); 5 fresh processes per program.

| program | claims | certified | checker ms (median, range) | summaries computed / reused | rounds |
|---|---:|---:|---|---|---:|
| JSON | 22 | 22 | 218 (205-311) | 140 / 60 | 44 |
| CSV | 52 | 52 | 549 (505-629) | 207 / 121 | 104 |

Compiled twice in one process (the memo kept):

| program | claims reused by the second compilation | checker ms, first / second |
|---|---:|---|
| JSON | 22 of 22 (certified: 22) | 210 / 30 |
| CSV | 52 of 52 (certified: 52) | 658 / 40 |
| 12 scopes, every name shared | 12 of 12 (certified: 12) | 10 / 2 |
| 12 scopes, names of their own | 12 of 12 (certified: 12) | 14 / 3 |
