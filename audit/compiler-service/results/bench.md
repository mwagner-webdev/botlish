# Compiler service benchmark

## Environment

- date: 2026-10-22 14:48 UTC
- source revision: c7e4d4fd
- CPU: Intel(R) Xeon(R) Processor @ 2.10GHz, 4 processors; memory 15 GiB
- OS: Linux 6.18.44-fc-v140 x86_64
- Tcl: 9.0.1 (/usr/bin/tclsh9.0)
- rustc: rustc 1.97.0 (2d8144b78 2026-07-07)
- front end: 7ce4dd8810bef12b-3929461
- repeat: 5; workloads: arith csv 2048 icy 2048-golden
- environment: BOTLISH_HIR_CACHE unset unless stated, -warnings off unless stated, static scheduler default (batched)

## Fresh processes

Wall time of a whole process (fork, exec, Tcl start, the work, exit), ms.

| measurement | n | min | median | p90 | max |
|---|---:|---:|---:|---:|---:|
| tclsh9.0, empty script | 5 | 5.17 | 6.79 | 7.12 | 7.12 |
| load the compiler (compiler, surface, native: what main.tcl sources) | 5 | 76.9 | 79.7 | 90.2 | 90.2 |
| main.tcl -help cli.options (Compilerpedia only) | 5 | 154 | 191 | 217 | 217 |
| main.tcl -help "bounds proof" (a search) | 5 | 153 | 161 | 218 | 218 |
| arith: main.tcl -emit-hir-interchange, no cache | 5 | 122 | 127 | 169 | 169 |
| arith: main.tcl -emit-hir-interchange, warm cache (hit) | 5 | 83.4 | 98.9 | 123 | 123 |
| csv: main.tcl -emit-hir-interchange, no cache | 5 | 327 | 337 | 417 | 417 |
| csv: main.tcl -emit-hir-interchange, warm cache (hit) | 5 | 88.1 | 91.8 | 94.7 | 94.7 |
| 2048: main.tcl -emit-hir-interchange, no cache | 5 | 1355 | 1486 | 1715 | 1715 |
| 2048: main.tcl -emit-hir-interchange, warm cache (hit) | 5 | 138 | 142 | 179 | 179 |
| icy: main.tcl -emit-hir-interchange, no cache | 5 | 967 | 1069 | 1101 | 1101 |
| icy: main.tcl -emit-hir-interchange, warm cache (hit) | 5 | 248 | 266 | 285 | 285 |
| 2048-golden: main.tcl -emit-hir-interchange, no cache | 5 | 5885 | 5998 | 6500 | 6500 |
| 2048-golden: main.tcl -emit-hir-interchange, warm cache (hit) | 5 | 179 | 198 | 254 | 254 |

### What a persistent process would save

Per workload, N fresh processes (bench/twice.tcl) each load the compiler, then analyze the program three times: the first analysis pays Tcl's bytecode compilation of every compiler procedure it calls and an empty parse cache; the second has both warm; the third empties the parse cache again (bytecode still warm). ms.

| workload | load compiler | 1st analysis | 2nd (warm) | 3rd (parse cache emptied) |
|---|---:|---:|---:|---:|
| arith (median of 5) | 80.2 | 53.4 | 6.41 | 6.54 |
| csv (median of 5) | 84.3 | 345 | 204 | 222 |
| 2048 (median of 5) | 63.5 | 1416 | 1101 | 1512 |
| icy (median of 5) | 61.6 | 985 | 710 | 926 |
| 2048-golden (median of 5) | 60.4 | 5780 | 6233 | 7222 |

Resident set after loading the compiler in process: 15 MiB.

## Analysis in one warm process

The probe library's lenient analysis (cs::analyze: parse with recovery, load the modules, build the HIR, finish), the process already warm. "first" is the workload's first analysis with the loader's parse cache emptied; its phases are inclusive (parse-all-files is every surface::parse call, the entry's and the modules'; module loading includes parsing the modules; the HIR build includes every whole-program build the decisions make). Edits are made in a buffer (an overlay); before each repetition the edited file's cached ASTs are dropped, so its text is new to the loader as each keystroke's is, while the other files' ASTs stay cached.

| measurement | n | min | median | p90 | max |
|---|---:|---:|---:|---:|---:|
| arith: first analysis (status ok, 1 whole-program builds) | 1 | 42.1 | 42.1 | 42.1 | 42.1 |
| &nbsp;&nbsp;phases: parse-all-files 5.48, module-load 1.11, module-parse 0.00, hir-build 30.3, finish 1.11 | | | | | |
| arith: unchanged, again | 5 | 4.32 | 4.45 | 5.31 | 5.31 |
| arith: after implementation edit (01-arithmetic.bot, status ok) | 5 | 4.33 | 5.18 | 7.25 | 7.25 |
| arith: after semantic-error edit (01-arithmetic.bot, status semantic) | 5 | 3.92 | 4.37 | 5.74 | 5.74 |
| arith: after syntax-error edit (01-arithmetic.bot, status syntax) | 5 | 1.23 | 1.28 | 1.82 | 1.82 |
| csv: first analysis (status ok, 1 whole-program builds) | 1 | 208 | 208 | 208 | 208 |
| &nbsp;&nbsp;phases: parse-all-files 41.1, module-load 15.5, module-parse 9.99, hir-build 150, finish 7.51 | | | | | |
| csv: unchanged, again | 5 | 165 | 208 | 238 | 238 |
| csv: after implementation edit (csv.bot, status ok) | 5 | 147 | 165 | 228 | 228 |
| csv: after interface edit (csv.bot, status ok) | 5 | 158 | 169 | 202 | 202 |
| csv: after semantic-error edit (csv.bot, status semantic) | 5 | 163 | 171 | 177 | 177 |
| csv: after syntax-error edit (csv.bot, status syntax) | 5 | 28.8 | 30.5 | 42.0 | 42.0 |
| 2048: first analysis (status ok, 2 whole-program builds) | 1 | 1276 | 1276 | 1276 | 1276 |
| &nbsp;&nbsp;phases: parse-all-files 319, module-load 386, module-parse 318, hir-build 847, finish 34.5 | | | | | |
| 2048: unchanged, again | 5 | 1017 | 1250 | 1363 | 1363 |
| 2048: after implementation edit (game2048.bot, status ok) | 5 | 1155 | 1233 | 1301 | 1301 |
| 2048: after interface edit (game2048.bot, status ok) | 5 | 1223 | 1287 | 1469 | 1469 |
| 2048: after semantic-error edit (game2048.bot, status semantic) | 5 | 755 | 847 | 961 | 961 |
| 2048: after syntax-error edit (game2048.bot, status loader) | 5 | 97.1 | 98.5 | 115 | 115 |
| icy: first analysis (status ok, 1 whole-program builds) | 1 | 1006 | 1006 | 1006 | 1006 |
| &nbsp;&nbsp;phases: parse-all-files 221, module-load 285, module-parse 218, hir-build 677, finish 34.2 | | | | | |
| icy: unchanged, again | 5 | 673 | 785 | 825 | 825 |
| icy: after implementation edit (tower.bot, status ok) | 5 | 890 | 1006 | 1176 | 1176 |
| icy: after interface edit (tower.bot, status ok) | 5 | 831 | 1014 | 1460 | 1460 |
| icy: after semantic-error edit (tower.bot, status semantic) | 5 | 810 | 904 | 1063 | 1063 |
| icy: after syntax-error edit (tower.bot, status loader) | 5 | 158 | 172 | 177 | 177 |
| 2048-golden: first analysis (status ok, 3 whole-program builds) | 1 | 6223 | 6223 | 6223 | 6223 |
| &nbsp;&nbsp;phases: parse-all-files 898, module-load 556, module-parse 423, hir-build 5013, finish 113 | | | | | |
| 2048-golden: unchanged, again | 5 | 6302 | 6994 | 7550 | 7550 |
| 2048-golden: after implementation edit (game2048.bot, status ok) | 5 | 7030 | 7441 | 7758 | 7758 |
| 2048-golden: after interface edit (game2048.bot, status ok) | 5 | 6991 | 7870 | 8015 | 8015 |
| 2048-golden: after semantic-error edit (game2048.bot, status semantic) | 5 | 4425 | 4793 | 4812 | 4812 |
| 2048-golden: after syntax-error edit (game2048.bot, status loader) | 5 | 632 | 644 | 765 | 765 |

## Front-end cache, in process

surface::modules::compileProgramFile with -cache DIR (strict, warnings off): a miss builds and stores the entry; a hit reads it, re-reads and compares every dependency, and decodes the HIR.

| measurement | n | min | median | p90 | max |
|---|---:|---:|---:|---:|---:|
| arith: miss (build + store) | 5 | 7.11 | 7.58 | 11.9 | 11.9 |
| arith: hit (read + check + decode), entry 44 KiB | 5 | 0.89 | 0.94 | 1.26 | 1.26 |
| csv: miss (build + store) | 5 | 195 | 209 | 232 | 232 |
| csv: hit (read + check + decode), entry 211 KiB | 5 | 7.80 | 8.04 | 11.0 | 11.0 |
| 2048: miss (build + store) | 5 | 1320 | 1439 | 1761 | 1761 |
| 2048: hit (read + check + decode), entry 1662 KiB | 5 | 71.3 | 73.2 | 85.3 | 85.3 |
| icy: miss (build + store) | 5 | 837 | 913 | 1052 | 1052 |
| icy: hit (read + check + decode), entry 630 KiB | 5 | 185 | 209 | 275 | 275 |
| 2048-golden: miss (build + store) | 5 | 7471 | 7716 | 8899 | 8899 |
| 2048-golden: hit (read + check + decode), entry 2093 KiB | 5 | 159 | 181 | 219 | 219 |

## Activation (hir::activate)

| pair | switch, µs (median of 200) | already active, µs (median of 200) |
|---|---:|---:|
| arith / csv | 10.0 | 1.00 |
| csv / 2048 | 17.0 | 1.00 |
| 2048 / icy | 27.0 | 1.00 |
| icy / 2048-golden | 11.0 | 1.00 |

## Position queries after analysis

cs::query at 200 evenly spaced positions of the entry file (activation first, as a service must), µs. Each query scans the HIR's expressions linearly (no position index exists).

| workload | expressions | median | p90 | max | positions with an expression |
|---|---:|---:|---:|---:|---:|
| arith | 11 | 27.0 | 58.0 | 926 | 66 |
| csv | 322 | 664 | 988 | 3798 | 104 |
| 2048 | 1777 | 1209 | 1851 | 15967 | 36 |
| icy | 1558 | 1214 | 2197 | 13523 | 70 |
| 2048-golden | 5374 | 7188 | 11062 | 54474 | 165 |

## Compilerpedia, in process

| measurement | ms |
|---|---:|
| first help-line lookup (topicForDiagnostic: header scan of the catalogue) | 53.2 |
| later help-line lookup (mean of 1000) | 0.01 |
| first search ("bounds proof": loads and parses every topic) | 182 |
| later search (mean of 20) | 0.01 |

## Native code generation

| measurement | n | min | median | p90 | max |
|---|---:|---:|---:|---:|---:|
| arith: NIR lowering (native::nir, Tcl) | 5 | 2.96 | 3.45 | 27.7 | 27.7 |
| arith: native::evalHir (lower, JIT in botlish-native, run) | 5 | 6.37 | 8.50 | 10.1 | 10.1 |
| csv: NIR lowering (native::nir, Tcl) | 5 | 87.5 | 96.2 | 142 | 142 |
| csv: native::evalHir (lower, JIT in botlish-native, run) | 5 | 99.1 | 102 | 131 | 131 |
| 2048: NIR lowering (native::nir, Tcl) | 5 | 586 | 634 | 690 | 690 |
| 2048: native::evalHir (lower, JIT in botlish-native, run) | 5 | 687 | 753 | 797 | 797 |
| icy: NIR lowering (native::nir, Tcl) | 5 | 523 | 576 | 600 | 600 |
| icy: native::evalHir (lower, JIT in botlish-native, run) | 5 | 626 | 692 | 716 | 716 |
| 2048-golden: NIR lowering (native::nir, Tcl) | 5 | 3845 | 4205 | 4385 | 4385 |
| 2048-golden: native::evalHir (lower, JIT in botlish-native, run) | 5 | 4065 | 4331 | 4740 | 4740 |

## Memory

| workload | HIR dict, KiB of text | interchange encoding, KiB |
|---|---:|---:|
| arith | 44 | 44 |
| csv | 201 | 201 |
| 2048 | 1581 | 784 |
| icy | 601 | 601 |
| 2048-golden | 2018 | 2018 |

Resident set of this process after everything above: 499 MiB.

