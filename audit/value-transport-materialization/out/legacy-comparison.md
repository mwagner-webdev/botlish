| probe | legacy | new default | Struct allocs | field-hops arg+ret | fn code bytes | stack ops | ns/iter (best of 5) |
|---|---|---|---|---|---|---|---|
| narrow-arg W=2 E=12 | virtual | object (200000 alloc) | 0 -> 200000 | 24 -> 0 | 1187 -> 1122 | 40 -> 38 | 17.0 -> 96.1 |
| narrow-arg W=2 E=16 | virtual | object (200000 alloc) | 0 -> 200000 | 32 -> 0 | 1443 -> 1330 | 48 -> 42 | 24.8 -> 98.9 |
| wide-return W=8 E=3 | virtual | object (200000 alloc) | 0 -> 200000 | 24 -> 0 | 1298 -> 1156 | 61 -> 39 | 13.7 -> 97.7 |
| direction-arg W=4 E=6 | virtual | object (200000 alloc) | 0 -> 200000 | 24 -> 0 | 1134 -> 1045 | 46 -> 41 | 12.0 -> 88.9 |
| direction-ret W=4 E=6 | virtual | object (200000 alloc) | 0 -> 200000 | 24 -> 0 | 969 -> 859 | 49 -> 25 | 11.6 -> 89.0 |
| direction-arg W=4 E=8 | virtual | object (200000 alloc) | 0 -> 200000 | 32 -> 0 | 1298 -> 1149 | 54 -> 43 | 14.1 -> 90.3 |
| direction-ret W=4 E=8 | virtual | object (200000 alloc) | 0 -> 200000 | 32 -> 0 | 1115 -> 945 | 57 -> 25 | 15.0 -> 93.8 |
| direction-ret W=6 E=4 | virtual | object (200000 alloc) | 0 -> 200000 | 24 -> 0 | 1108 -> 962 | 55 -> 31 | 12.1 -> 91.5 |
| mixed W=4 R=6 A=6 | virtual | object (200000 alloc) | 0 -> 200000 | 48 -> 0 | 1606 -> 1311 | 76 -> 39 | 20.8 -> 97.0 |
| mixed W=6 R=3 A=2 | object (200000 alloc) | virtual | 200000 -> 0 | 0 -> 30 | 1177 -> 1450 | 43 -> 77 | 93.6 -> 14.8 |
| branchy W=4 E=8 | virtual | object (199900 alloc) | 0 -> 199900 | 32 -> 0 | 1383 -> 1234 | 56 -> 47 | 14.3 -> 89.9 |
| nested-flat4 long-argument | virtual | object (200000 alloc) | 0 -> 200000 | 24 -> 0 | 1129 -> 1040 | 45 -> 40 | 11.5 -> 87.5 |
| nested-inner1 local | object (200000 alloc) | virtual | 200000 -> 0 | 0 -> 0 | 608 -> 516 | 39 -> 25 | 86.7 -> 4.1 |
| nested-inner1 return | object (200000 alloc) | virtual | 200000 -> 0 | 3 -> 4 | 703 -> 600 | 42 -> 29 | 85.8 -> 4.9 |
| nested-inner1 argument | object (200000 alloc) | virtual | 200000 -> 0 | 3 -> 4 | 782 -> 719 | 34 -> 25 | 85.3 -> 6.8 |
| nested-inner2 local | object (400000 alloc) | virtual | 400000 -> 0 | 0 -> 0 | 721 -> 516 | 47 -> 25 | 167.0 -> 4.1 |
| nested-inner2 return | object (400000 alloc) | virtual | 400000 -> 0 | 2 -> 4 | 763 -> 600 | 41 -> 29 | 165.8 -> 4.9 |
| nested-inner2 argument | object (400000 alloc) | virtual | 400000 -> 0 | 2 -> 4 | 947 -> 719 | 56 -> 25 | 172.5 -> 7.2 |
| nested-inner2 long-argument | object (400000 alloc) | object (200000 alloc) | 400000 -> 200000 | 12 -> 18 | 1267 -> 1147 | 66 -> 49 | 184.3 -> 94.5 |
| nested-deep local | object (400000 alloc) | virtual | 400000 -> 0 | 0 -> 0 | 730 -> 516 | 46 -> 25 | 163.1 -> 3.9 |
| nested-deep return | object (400000 alloc) | virtual | 400000 -> 0 | 2 -> 4 | 748 -> 600 | 35 -> 29 | 165.7 -> 4.9 |
| nested-deep argument | object (400000 alloc) | virtual | 400000 -> 0 | 2 -> 4 | 907 -> 719 | 51 -> 25 | 173.1 -> 6.9 |
| nested-deep long-argument | object (400000 alloc) | object (200000 alloc) | 400000 -> 200000 | 12 -> 18 | 1227 -> 1147 | 61 -> 49 | 179.0 -> 92.8 |
