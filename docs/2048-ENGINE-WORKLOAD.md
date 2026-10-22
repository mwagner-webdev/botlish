# 2048 engine: the first post-golden workload (full discovery)

The first workload of the post-golden stress-test series: a deterministic
2048 engine written in ordinary Botlish, with a demo, a golden suite and a
benchmark, built with full access to the repository, and recording, as it
happened, every place where reaching working code needed something a
Botlish user should not have needed. A later workload of the same kind will
be attempted with only the single-file executable and a compact prompt; this
report is the baseline that run is measured against, and the list of what
should change before it.

The running log the report is drawn from is
[audit/2048/surprise-log.md](../audit/2048/surprise-log.md) (S1-S25,
P1-P3, D1-D6): each entry was written when it happened.

## Outcome

* **A working, readable engine** in 277 lines (175 of code):
  [examples/games/2048/game2048.bot](../examples/games/2048/game2048.bot).
  It was correct on its first run (P2), and a 68-test golden suite, an
  independent Python oracle and a 20-mutant harness agree.
* **Two compiler correctness bugs found and fixed**, both BLOCKERs:
  * S19: native shadow-stack root slots were shared between a register
    defined by an instruction and a register live across that
    instruction, so the definition's store overwrote a live root. Under
    GC stress the demo crashed and a 25-line reduction computed a wrong
    value. Fixed in `native/src/codegen/roots.rs` (definition
    interference); two corpus programs had the same latent shape.
  * S24: specialized native lowering rejected a valid program with an
    internal error (`does not capture`, NATIVE BUG) when a
    de-closure-converted function's struct result was wanted as fields --
    the shape of every single-file program whose top-level functions read
    a program-level value and return a struct. Found by the
    single-executable smoke test (which can only use single files, S4).
    Fixed in `native/lower.tcl` with an internal scalar companion.
  Each has a Rust or Tcl regression that fails without the fix.
* **Performance is acceptable but not good**: 13-25 us per move natively
  (two VMs), 3-4x slower than CPython running the same rules on the same
  machine, because the
  obvious immutable program allocates ~169 objects (7.7 KB) per move and
  spends about half its time in the collector. Specialization buys nothing
  on this workload (S18).
* **The largest obstacles were not the language core** but the product
  surface around it: an application cannot have its own importable module
  (S4), a printing program shows nothing under `-backend cranelift` (S15),
  the interpreter cannot run a 200-deep recursion under main.tcl (S22),
  and the golden-test tooling assumes every test is a port of a Tcl test
  (S3). S4, S15 and S22 are resolved since (POST-2048-PRODUCT-FIXES.md).
* **Zero stdlib changes.** Several general operations were missed (Int to
  String, reverse, concat/flatten, sum, replace-at); each is recorded with
  its evidence below.

## Changes, by kind

| kind | change |
|---|---|
| 2048 implementation | `examples/games/2048/`: `game2048.bot` (engine module), `demo.bot`, `golden.bot` (suite), `bench.bot`, `run.tcl` (the private-library driver, D5); `bench/2048.tcl`; `tests/workload-2048.test`; `audit/2048/` (`oracle.py`, `mutants.txt`, `mutate.tcl`, `surprise-log.md`) |
| stdlib | none |
| test framework (`stdlib/test.bot`) | none |
| test tooling | `audit/golden/tools/perturb.tcl`: `-lib DIR` (perturb a suite against a library directory that holds a non-stdlib module); census rows for the new Tcl tests (`audit/golden/migration/census/workload-2048.tsv`, `native-root-liveness.tsv`) and the regenerated `tests/golden/manifest.tsv` |
| compiler correctness | `native/src/codegen/roots.rs`: a definition interferes with every managed register live after it; Rust test `definition_does_not_overwrite_a_live_root`; `tests/native-root-liveness.test` `root-def-interference-1`. `native/lower.tcl`: the internal scalar companion (`internalcompanion`: `InternalCompanionRef`, `InternalCompanionFunction`, `FlattenedVirtualScalarCall`) and `Call`'s flattened dispatch for a call whose result is wanted as fields; `tests/native-block-escape.test` `blockescape-scalar-companion-1..3` |
| compiler precision / optimization | none (findings only: S5, S7, S8, S9, S18) |
| CLI / docs / agent instructions | this report and its line in INDEX.md; NATIVE-AUDIT.md's root-interference definition marked corrected; an AGENTS.md section on the workload (where it lives, how it runs, what to re-run); no CLI change (findings S4, S15, S22). CI's scalar-asm-audit job will regenerate `audit/native-scalar-asm/` after the merge (the roots fix adds slots to `csv_records` and `hashtable`) |

## 1. Implementation

### Architecture

One module, `game2048` (one file, one namespace: IMPORTS.md), and three
programs that import it: the demo, the golden suite and the benchmark
program, all in `examples/games/2048/`. Because `import NAME` resolved only
to `stdlib/NAME.bot` (S4), the programs were compiled against a private library
directory -- a temporary copy of `stdlib/` with `game2048.bot` added -- that
`examples/games/2048/run.tcl` built; `tests/workload-2048.test` and
`bench/2048.tcl` used it too (D5). `run.tcl -hirx OUT FILE.bot` writes the
analyzed HIR, which `main.tcl` then runs with every option it has
(`-backend`, `-emit-nir`, `-emit-clif`, `-emit-native-executable`): the
library was needed only by the front end. **Since S4's fix** the engine is an
application module, the file beside its programs, and every entry point
compiles them as they are (`tclsh9.0 main.tcl -backend cranelift
examples/games/2048/demo.bot`); the private library is gone
(POST-2048-PRODUCT-FIXES.md).

```sh
tclsh9.0 examples/games/2048/run.tcl -suite                  # the golden suite, four backends
tclsh9.0 examples/games/2048/run.tcl -hirx /tmp/demo.hirx examples/games/2048/demo.bot
tclsh9.0 main.tcl -emit-native-executable /tmp/demo.hirx && /tmp/demo
tclsh9.0 bench/2048.tcl                                      # the performance report
```

### Representation

| concept | representation | why |
|---|---|---|
| board | `opaque struct Board: rows: List[List[int]]` | rows make a line a first-class List, which is what the algorithm consumes; no integer division (S2) rules out a flat 16-cell layout with `i div 4`; `opaque` gives the module sole construction authority, so the invariant is validated once and kept by construction (D1) |
| cell | `int`: `empty` (0) or a tile, a power of two >= 2 | enums are payload-free, so there is no Empty/Tile(n) sum; with 0, `std::list::get(xs, i, empty)` reads "the cell at i, or empty past the end", which makes padding and reversal total (D2) |
| board invariant | four rows of four cells, each empty or a tile | checked at the one public constructor, `board(rows) errors InvalidBoard` (`board_rows?`: three one-line predicates over `std::list::all?`); kept by construction everywhere else; not representable as a type (no fixed-length List, S7; a power of two is not a range) |
| game state | `struct Game: board: Board, score: int` | plain value; a move or a spawn returns a new one |
| direction | `enum Direction: Left, Right, Up, Down` | nominal, compared with `==` |
| position | `struct Position: row: Coordinate, column: Coordinate`, `type Coordinate = Int in 0..3` | an out-of-range position does not compile (P1) |
| spawn tile | `enum SpawnTile: Two, Four`, `value(tile) -> int` | an invalid spawn value does not compile |
| line result | `struct Slide: cells: List[int], score: int` | |
| move result | `struct Move: game: Game, gained: int, changed: bool` | |

### The line move

```botlish
fn merged(tiles: List[int]) -> Slide:
    nomethod fn from(i: int, done: Slide) -> Slide:
        if i >= std::list::length(tiles):
            return done
        tile = tiles.get(i, empty)
        if tiles.get(i + 1, empty) == tile:
            from(i + 2, Slide {cells: done.cells.append(tile * 2), score: done.score + tile * 2})
        else:
            from(i + 1, Slide {cells: done.cells.append(tile), score: done.score})
    from(0, Slide {cells: [], score: 0})

fn slide(cells: List[int]) -> Slide:
    tiles = loop cell in cells:
        if cell == empty:
            continue
        cell
    merge = tiles.merged()
    padded = loop i from 0 to std::list::length(cells):
        merge.cells.get(i, empty)
    Slide {cells: padded, score: merge.score}
```

Compact is a filtering loop; the merge is a self-recursive helper that
carries its position and the result so far (no loop carries state, S23) and
skips both tiles of a pair, which is what makes a produced tile unable to
merge again; padding is a counted loop over `get`'s default (D3).

### The board move and the score

A move looks at the board from its direction as four lines, each starting at
the cell the tiles slide toward, slides each line, and looks back:

```botlish
fn lines_toward(rows: List[List[int]], direction: Direction) -> List[List[int]]:
    if direction == Direction::Left:
        rows
    elif direction == Direction::Right:
        rows.each_reversed()
    elif direction == Direction::Up:
        rows.transposed()
    else:
        rows.transposed().each_reversed()
```

`rows_from` is its inverse (down: `lines.each_reversed().transposed()`).
Two involutions replace four algorithms or an index formula (D4); the
mutation `down-inverse-misordered` (reversing after transposing on the way
back) is caught. Each merge scores the tile it produces; a move's gain is the
sum of its four lines' scores, and `game.score` grows by exactly that.
`changed` is one value comparison, `moved != rows`.

### Spawn and game over

`spawn(game, at: Position, tile: SpawnTile) -> Game errors CellOccupied`. An
out-of-range position and a tile other than 2 or 4 are compile-time errors
(two `static compile:` tests pin them: `Type`); an occupied cell is the one
run-time error. "Only after a changed move" is a caller's rule: the engine
keeps no history.

```botlish
fn game_over?(game: Game) -> bool:
    rows = game.board.rows
    not rows.has_empty?() and not rows.equal_neighbours?() and not rows.transposed().equal_neighbours?()
```

A direct reading of the rule, not four trial moves.

### Public API

`board(rows)`, `empty_board()`, `rows(board)`, `cell(board, at)`,
`empty_positions(board)`, `reached?(board, tile)` (a tile of at least that
value: `reached?(board, 2048)` is "has 2048", and the game does not stop
there), `new_game()`, `move(game, direction)`, `spawn(game, at, tile)`,
`game_over?(game)`, `slide(cells)` (the line move, public because it is a
meaningful operation the suite tests directly) and `value(tile)`. Botlish
has no private module members, so the fifteen helpers are importable too
(S21).

### The demo

`demo.bot` plays one game with the corner strategy (try down, left, right,
up; take the first move that changes the board), spawning from a small
linear congruential generator with a fixed seed -- randomness lives in the
caller. It prints the first five boards, the final board, the score and the
largest tile: 316 moves, score 3888, largest tile 256. It prints through
`std::io::print_line`, so it runs only natively (S15: under `-backend cranelift`
main.tcl showed only its value until S15's fix); as an executable it takes
10 ms.

Since MACOS-AARCH64-MILESTONE-8.md (section 22) the demo is the application
module `demo_play.bot` -- everything above, its functions requiring
`std::io::IO` and naming no platform -- and one three-line entry per platform:
`demo.bot` installs Linux's context (`std::linux::io::create()`),
`demo-darwin.bot` macOS's (`std::darwin::io::create()`), and both call
`demo_play::main()`. The output is the same; on Linux the demo's NIR has
the same functions, instructions and registers as before, qualified by
`demo_play::`. The engine and the benchmark did not change (they do no
IO), and the workarounds the demo records stay.

### Size

| file | lines | code (no comments/blank) |
|---|---:|---:|
| engine `game2048.bot` | 277 | 175 |
| demo `demo.bot` | 180 | 124 |
| golden suite `golden.bot` | 564 | 399 |
| benchmark program `bench.bot` | 85 | 61 |
| driver `run.tcl` | 140 | 102 |
| `bench/2048.tcl` | 98 | 71 |
| `tests/workload-2048.test` | 175 | 140 |
| `audit/2048/oracle.py` | 103 | 69 |
| `audit/2048/mutate.tcl` + `mutants.txt` | 102 + 190 | 79 + 134 |

### API ceremony and collection census

The engine declares 5 structs (one opaque), 2 enums, 1 integer domain, 2
errors and 27 top-level functions (12 intended API, 15 helpers), plus 2
nested functions (the merge and sum recursions) and one `nomethod`. It has
no `proves` clause, no manual bounds check and no `std::list::at`: every
indexed read is one of 10 `std::list::get`s with a default. Collection
operations, by count: `std::list::get` 10, `std::list::length` 9, `loop x in xs` 12
(filter 1, map 6, search 5), counted `loop i from` 8, lockstep 2,
`std::list::append` 2 (the merge's accumulator), `std::list::all?` 2, MutableVector
`push` 1 and read-out 1. Reimplemented general operations: reverse,
transpose, replace-at, sum, flatten (each once in the engine; reverse,
transpose and sum again in the suite).

## 2. Correctness

**68 golden tests**, all passing on interp, compile, cranelift-generic and
cranelift with identical reports:

| area | tests | covers |
|---|---:|---|
| line | 16 | compaction, empty line, single merge, merge across a gap, compact-then-merge, three equal (start and end), four equal, four fours, two pairs, a produced tile that does not merge again (`[2,2,4,4] -> [4,8]`, 12), pair then singles (`[2,2,4,2] -> [4,4,2]`), produced tile next to an equal neighbour (`[8,4,2,2] -> [8,4,4]`), full without merge, already slid, large tiles; every case with its score |
| move | 13 | left, right, up, down on one board with explicit boards and gains; up/down merging columns; right merging from the right; unchanged move (board, gain 0, `changed` false); unchanged empty board; changed without a merge; score accumulation; unchanged move keeps the score; moving again merges produced tiles |
| spawn | 11 | Two, Four, two corners, occupied (`CellOccupied`), keeps the score, sum grows by the tile, empty positions (before, after a spawn, on a full board), position outside the board and an Int tile rejected at compile time |
| board | 11 | rows round trip, rejects a non-tile / 1 / a negative / a short row / three rows, accepts large tiles, construction and field access are the engine's (`OpaqueConstruction`, `OpaqueRepresentation`), `cell`, `reached?` |
| game over | 8 | full without a merge; not over with an empty cell, a horizontal pair, a vertical pair, a vertical pair at the edge; a new game; over with a 2048 tile; no move changes a game-over board |
| properties | 7 | right is mirrored left, up is flipped left, down is flipped right (each over seven sample boards); a move conserves the tile sum; a move scores exactly when it merges; a scoreless move is idempotent; `changed` iff the board differs |
| scenario | 2 | a short trace written out (spawn, up, spawn, left, spawn, up); a long game played to game over |

The property tests compute their expectations with structural relations the
suite writes itself (`mirrored`, `flipped`, `tile_sum`, `tile_count`), never
with a second engine. The long scenario (91 moves to game over, score 796)
has its expected final state from **an independent implementation**,
[audit/2048/oracle.py](../audit/2048/oracle.py): a flat 16-cell board,
explicit index lists per direction and an imperative merge with a "may
merge" flag. The benchmark's 100,000-move checksum also equals a Python
transcription of `bench.bot` over the oracle (P3).

One property the brief suggested is false: "moving left twice, the second
move does not change the result" -- `[2,2,2,2]` goes to `[4,4,0,0]` and then
`[8,0,0,0]`. The suite pins that counterexample and tests the true property
(a move that scored nothing is idempotent).

**Non-vacuity** (`audit/golden/tools/perturb.tcl`, then with `-lib DIR`; it now copies a suite's
application modules beside every perturbed copy, STD-NAMESPACE.md): with every
verdict inverted, 68 of 68 tests fail; with each alterable expectation
altered, 60 of 60 fail (8 have no literal to alter: 3 `std::test::holds`, 4
computed expectations, 1 empty List; invert covers them).

**Mutation** (`audit/2048/mutate.tcl`, 20 mutants of the engine): every
mutant is killed -- the brief's list (merge a produced tile again, a merged
pair's source reused, no compaction before or after merging, score by
source, right in left order, a wrong transpose, spawn into an occupied cell,
game over ignoring vertical/horizontal pairs or empty cells, `changed`
always true) and seven more (score not accumulated, gain of the first line
only, 1 as a tile, short rows accepted, `reached?` strict, empty positions
by column, a Four spawning 8). The harness found a weak test of mine: the
"horizontal merge" game-over board also had a vertical pair, so ignoring
horizontal pairs was caught only by the long scenario (S14, fixed).

**Backend agreement**: the suite's report, the benchmark's checksums (200
moves: 2002720; 100,000 moves: 1238344689) and the demo's game (316 moves,
3888) are identical on every backend.

**GC stress**: the suite passes natively under `BOTLISH_NATIVE_GC_STRESS=1`.
The demo did not: its executable crashed (S19), which led to the roots fix.
After the fix the demo executable's output is byte-identical with and
without GC stress (pinned by `tests/workload-2048.test`), and the whole
test suite passes under GC stress: `BOTLISH_NATIVE_GC_STRESS=1 tclsh9.0
tests/local.tcl -all 1` -- every Tcl test on interp (7,522 passed) and
compile (7,518 passed, 4 skipped), and the 91 golden suites on all four
backends (4,690 / 4,690 / 4,597 / 4,699 tests), no failure. The same run
on the final tree (both fixes, `tests/workload-2048.test`, the new
block-escape tests and the extended `closure-escape.bot`): 7,529 and
7,525 Tcl tests (4 skipped), 91 golden suites with 4,691 / 4,691 / 4,598
/ 4,700 tests, no failure. Not run here: the AArch64 GC-stress run
AGENTS.md asks for after a root-lowering change (CI's tests-arm64.yml).

## 3. Compiler behavior

**HIR.** Every program builds with no diagnostic after the fixes recorded
in the log; the engine is warning-clean (its two warnings answered in the
code, S10). The front end proves:

* every `Position {row: r, column: c}` from `loop r from 0 to 4` and from
  `if r >= 0 and r <= 3 and ...` (through `and`, P1);
* `spawn`'s lockstep `loop row in old and r from 0 to std::list::length(old)`;
* the `CellOccupied` call sites a test handles are uncertain and need their
  handlers; an Int tile or a row 4 is a `Type` error at the call.

It does not prove: a descending loop's index (S5), anything from a named
constant (S8; resolved since, `0db2443`), anything about a List's length
through a parameter or a struct field (S7), or lockstep over a field
projection (S9). The engine therefore reads cells with `std::list::get` and a
default that never happens (10 calls), and spelled the board size as the
literal 4 (until S8's fix).

**Generic NIR (cranelift-generic) vs specialized NIR (cranelift).** Nearly
identical. Specialization's one visible win: `move` returns its `Move`
through `retmulti` (three registers) instead of allocating the struct.
Everything else is the same code with different instance labels: Ints stay
tagged (arbitrary precision with no range), Lists are heap objects either
way, and the throughput is the same (13.17 vs 13.29 us per move). The merge
helper's instance key is `int, any`: the declared `done: Slide` is not part
of it.

**Proofs that removed work.** `Coordinate` fields need no check anywhere
(and no run-time representation beyond the Int); the two lockstep loops
(`spawn`, `replaced`) are proven equal-length, so they have no run-time
length comparison; `move`'s exact call graph lets specialization return its
`Move` in registers. Collecting loops build their result through a
construction plan, one allocation per loop rather than per element.

**Missed facts with a native consequence.**

* `empty`, a module constant 0, is a `staticget` and a tagged `ieq` at
  every comparison, never a raw compare with 0 (S8).
* `std::list::get` is an out-of-line call with a pushed error exit
  (`pusherrorexit`/`declarederroreq`) per cell read: never inlined.
* A `loop x in xs` keeps its position register tagged (`ilt`/`iadd`, an
  inline small-Int fast path with `rt_int_cmp`/`rt_int_add` behind it),
  while a numeric `loop i from a to b` is raw (`rilt`/`riadd`).
* A loop whose value is discarded is lowered without a result List, but a
  loop that is the *body value* of such a loop is not: empty_positions'
  and equal_neighbours?'s inner loops build a List of `unit`s per row
  (`hir/aot.tcl`'s `discarded` marks "all but the last of a sequence, and
  the last of a loop body", never the last of a discarded collecting
  loop's body).
* `cell`'s `[]` default is a fresh `listnew` on every call (a constant
  List literal is rebuilt per call: LANGUAGE-LIBRARY-DEFICIENCIES.md item
  6).
* `loop at in found: at` (MutableVector to List) is an `mvtolist` copy and
  then a second, element-by-element List build.

**Retained bounds checks.** All of them, by construction: the engine reads
through `std::list::get`, whose `listget` checks the index and whose handler
turns `IndexNotFound` into the default; no read is proven, because no List
length is known where it is read (S7). The proofs the engine relies on are
about Positions and lockstep counts, not indexes.

**Codegen (CLIF).** `equal_neighbours?` calls `rt_list_len`,
`rt_list_get`, `rt_list_new`, `rt_construct` and two out-of-line
`std::list::get`s; its stack maps show four to six live root slots at each
call. No categorical pathology (nothing quadratic, no dynamic dispatch: the
one higher-order call, `std::list::all?`, is in validation only); the cost is
allocation.

**Allocations** (`native::allocationReport ... sites`, 1,000 moves): ~169
objects and 7.7 KB per move; top sites: `Position` structs built for every
cell of `empty_positions` (15 per move, materialized because one branch
pushes them), `cell`'s `[]` default (16 per move), the merge helper's
`Slide` and its `append` copy (22 per move), and one result List per
collecting loop.

**Correctness bug (S19), fixed.** `native/src/codegen/roots.rs` colours the
interference graph of shadow-stack root slots. Two registers interfered
only if they were both roots at one safepoint; but codegen stores a slotted
register into its slot at every definition. A register defined by a call
and a root only on the path that returns it (`choose`'s `m`, at a
`structnew`) never co-occurred with the loop's List (a root at the call, on
the loop path), so they shared a slot, and the store of the call's result
overwrote the List's root while the List was still live; the next
iteration's call collected it. The fix adds the standard rule: a definition
interferes with every managed register live after it. Cost: 2126 -> 2134
shadow slots over 550 corpus functions (+0.4%), in three programs (the demo,
`examples/stdlib/csv_records.bot`, `hashtable.bot`). Reduction took nine
programs, twenty-two optimization toggles (`ESCAPE_OPT=0` or
`STRUCT_OPT=0` hid it) and a gdb backtrace of a rustc-linked executable.

**Correctness bug (S24), fixed.** In an entry program, a top-level function
that reads a program-level value is a closure; hir/blockescape.tcl
de-closure-converts such closures (their captures become trailing
parameters of a capture-explicit *internal variant*), and a caller's
capture list is *flattened* accordingly: `main` captures `spawned`'s
captures instead of `spawned`. Every call of a converted binding must then
go through the flattened call. `Call` did so for an ordinary or a region
result, but skipped it when the caller wanted the struct result as fields
(scalar replacement), and that path evaluated `spawned` as a closure value
-- which the flattened list does not have: `native lowering: e12 does not
capture b2 (NATIVE BUG)`. The 11-line reproducer:

```botlish
empty = 0
struct Turn:
    game: int
    seed: int
fn spawned(game: int, seed: int) -> Turn:
    Turn {game: game + empty, seed: seed}
fn main() -> int:
    first = spawned(1, 2)
    first.game
main()
```

The fix adds the missing composition, an *internal scalar companion*
(`CompanionFunction`'s multi-value exits with `InternalFunction`'s
capture-explicit parameters, as the internal region companion already is
for String regions), and routes such calls to it. Only calls that used to
throw take the new path. The reproducer's NIR is now `main`'s internal
variant calling `spawned`'s internal scalar companion through `callmulti`:
no struct, no closure.

**Precision and performance findings deferred**: S5, S7, S8, S9 and the
native items above. None blocked the engine; S8 is the one worth fixing
before the paired run (a grid program names its size).

## 4. Performance

`bench.bot`'s `benchmark(moves, seed)` makes exactly MOVES moves: direction
and spawn from a generator seeded with `2048 + std::list::length(argv())`, a game
that is over scored and replaced, the result a checksum of every score,
gain and changed move. Nothing about the sequence is known at compile time.
`bench/2048.tcl` reports (best of 3, compilation excluded):

The measurements come from two sessions on two VMs (the session's
worker was restarted in between, onto a slower host); within a session
the numbers are stable to about 10%, across sessions they are not
comparable:

| backend | moves | session 1, us/move | session 2, us/move |
|---|---:|---:|---:|
| interp | 300 | 28,352 | 42,219-46,585 |
| compile (Tcl) | 3,000 | 2,161 | 3,129-3,346 |
| cranelift-generic | 100,000 | 13.17 | 21.3-24.2 |
| cranelift | 100,000 | 13.29 | 19.7-25.2 |
| CPython (same rules, flat list, imperative) | 100,000 | 4.55 | 5.63 |

The checksum is the same on every backend (3004291 for 300 moves,
31043367 for 3,000, 1238344689 for 100,000) and equals the Python
transcription's. In session 2 the roots fix (S19) was measured against
the unfixed native binary, alternating runs: 21.3-25.2 vs 20.9-23.5 us per
move, indistinguishable within the noise; it adds 4 shadow slots to the
demo and none to the engine's functions in the benchmark.

* Front end (parse, resolve, analyses) of the benchmark program: about 0.2
  s; of the golden suite (with its four `static compile:` sites): 4.3-4.8 s.
* Native lowering (NIR): 137 ms generic, 234 ms specialized; Cranelift:
  about 15 ms.
* Allocation and memory, 100,000 moves (specialized): 16.9 M objects, 771
  MB allocated (9.5 M Lists), peak live 23 K objects / 1.0 MB, 742 GC
  cycles, 628 ms of GC in a ~1.33 s run.
* Reference: the same rules and generator in CPython (flat list,
  imperative): 4.55 us per move.

The immutable representation stayed: it is clear, correct and fast enough
for a game (40,000-75,000 moves a second), and no mutable alternative was built,
because what the measurements implicate is how immutable code is lowered
(the six items above), not immutability: the peak working set is 1 MB.

## 5. Standard library

No stdlib change was made. What the engine and its programs needed:

| operation | where | classification |
|---|---|---|
| Int to decimal String | demo's `decimal` (stdlib/test.bot has its own private `int_text`: two copies of one primitive) | missing essential general primitive (S1) |
| integer division | demo's digits; a flat board layout | missing primitive (S2) |
| `reverse` | engine `reversed`, suite `mirrored` | convenience, but the natural spelling (`down from`) is not index-proven (S5) |
| concat / flatten | empty_positions (MutableVector), demo's `joined` | missing general primitive |
| sum / fold | engine `total`, suite `sum`, `tile_sum`, `tile_count` | missing general primitive (S23) |
| replace-at | engine `replaced` | convenience |
| transpose | engine `transposed`, suite `flipped` | game-adjacent; two rectangular helpers are not evidence for a matrix |
| a typed empty MutableVector | `no_positions()` | language (S6) |

Used and sufficient: `std::list::length`, `std::list::get` (10 calls: its default is
what makes fixed-size access total), `std::list::append`, `std::list::all?`, collecting
loops (filter, map, counted, lockstep), MutableVector `push` and read-out.
Awkward: `std::list::at` (never used: every use needed a handler or a guard),
`std::list::get` for an invariant the program keeps (a default that never
happens). Suspected missing but unnecessary: random numbers (the caller's
generator is two lines), a grid type, `max` (the demo asks
`reached?(board, p)` for descending powers).

## 6. Test framework

Used: `std::test::suite`, `std::test::value` (61), `std::test::holds` (3),
`std::test::rejects` (4), `std::test::report`. No custom matcher was needed; values
are compared as Lists of Ints because `describe` prints Lists but not
structs (D1). Suite-local helpers: `board_of`, `game_of`, `moved`, `slid`,
`at`, `with_tile`, `mirrored`, `flipped`, `sum`, `tile_sum`, `tile_count`,
`samples`, `directions`, `all_true?`, and the scenario's `cycle`,
`spawned`, `play`, `scenario`. Recurring ceremony: one nested function per
test (`fn name() -> T:` then `std::test::value("name", expected, name)`), a
fallback for every fallible constructor in a body (`board_of` falls back to
the empty board so a mistyped expectation fails visibly), and expectations
as nested List literals.

No framework change was made or needed. Considered and rejected: a board
matcher (Lists print fine), a property-test helper (seven ordinary tests
were enough). Tooling, not framework: the golden machinery assumes a port
of a Tcl test (S3), compiles suites with warnings off (S20), and
`perturb.tcl` needed `-lib` (the one tooling change).

## 7. Discovery

The complete log is [audit/2048/surprise-log.md](../audit/2048/surprise-log.md).
Its findings, ranked:

| # | finding | categories | severity | fixed |
|---|---|---|---|---|
| S19 | a definition overwrote a live root slot: crash / wrong value under GC stress | COMPILER-CORRECTNESS | BLOCKER | yes |
| S24 | a valid single-file program rejected by specialized native lowering (`does not capture`) | COMPILER-CORRECTNESS | BLOCKER | yes |
| S4 | no application module root; with the single executable, no module of one's own at all | LANGUAGE, CLI | MAJOR | yes (application modules: POST-2048-PRODUCT-FIXES.md) |
| S15 | program output discarded under `-backend cranelift`; Tcl backends cannot print | CLI, STDLIB, DOCUMENTATION | MAJOR | the CLI part, yes (POST-2048-PRODUCT-FIXES.md); the Tcl backends still cannot print |
| S22 | interp under main.tcl fails a 200-deep recursion | CLI | MAJOR | yes (POST-2048-PRODUCT-FIXES.md) |
| S18 | ~169 allocations and 7.7 KB per move, half the time in GC, ~3x CPython | COMPILER-PERFORMANCE | MAJOR | no |
| S1 | no Int-to-String | STDLIB, DOCUMENTATION | MODERATE | no |
| S2 | no integer division | LANGUAGE, DOCUMENTATION | MODERATE | no |
| S3 | golden tooling assumes ported Tcl tests | TEST-FRAMEWORK, DOCUMENTATION | MODERATE | worked around (D5) |
| S6 | an empty MutableVector needs a typed helper function | LANGUAGE, DIAGNOSTIC | MODERATE | no |
| S7 | a List's length is no fact through a parameter or field | LANGUAGE, COMPILER-PRECISION | MODERATE | no |
| S8 | a named Int constant is no fact inside functions | COMPILER-PRECISION | MODERATE | yes (`0db2443`) |
| S12 | a local or parameter named like an imported function makes method calls to it ambiguous | LANGUAGE, DIAGNOSTIC | MODERATE | no |
| S16 | every importer of io gets the stdlib's own two warnings | DIAGNOSTIC, STDLIB | MODERATE | yes |
| S21 | no private module members | LANGUAGE | MODERATE | no |
| S23 | loop-carried state needs recursion or a mutable place | LANGUAGE, STDLIB | MODERATE | no |
| S25 | a single-file program loses encapsulation and gets silent shadowing | LANGUAGE, DIAGNOSTIC | MODERATE | no |
| S5 | a descending loop's index is not proven | COMPILER-PRECISION, STDLIB | MINOR | no |
| S9 | lockstep over a field projection is unproven; "(expression)" | COMPILER-PRECISION, DIAGNOSTIC | MINOR | no |
| S11 | the warning gate cannot cover non-lib imports | TEST-FRAMEWORK | MINOR | no |
| S13 | bare `List` rejected; the raw kind is `list` | DIAGNOSTIC | MINOR | no |
| S20 | the golden runner hides a suite's warnings | TEST-FRAMEWORK | MINOR | answered in code |
| S10 | two warnings on the engine | DIAGNOSTIC | ONE-TIME-NOVELTY | answered in code |
| S17 | twelve METHOD-ELIGIBLE on the demo | DIAGNOSTIC | ONE-TIME-NOVELTY | answered in code |
| S14 | a weak game-over test | USER-ERROR | ONE-TIME-NOVELTY | yes |

By category (a finding may have several): COMPILER-CORRECTNESS 2,
COMPILER-PRECISION 4, COMPILER-PERFORMANCE 1, LANGUAGE 8, STDLIB 5, CLI 3,
DIAGNOSTIC 8, DOCUMENTATION 4, TEST-FRAMEWORK 3, USER-ERROR 1. By severity:
BLOCKER 2, MAJOR 4, MODERATE 11, MINOR 5, ONE-TIME-NOVELTY 3.

**Found with S8's fix** (`0db2443`; not counted above, not fixed, both
COMPILER-PRECISION, MINOR): S26, a collecting loop's elements' Ranges
never admit it as a declared `List[Coordinate]` (with a literal bound
too: S8's entry-program example); S27, a character bound to a name is
no exact element for `std::byte::set`'s literal-List proof.

**Wrong hypotheses** (S8, S12, S19): "module bindings are opaque to the
analyses" (it is any program-level binding); "a declared List parameter is
not a method candidate" (every binding is, and the first error reported is
not the earliest); several reduction guesses for S19 (the loop list from a
call, the struct nesting, the Choice wrapper) before the multi-result
shape was isolated.

**Research performed**: about 30 probe programs (scratch; one of the nine
S19 reproducers is kept as the regression), about ten docs read for semantics
(the reference's surface and natives sections, METHOD-SUGAR,
IMPORTS, WARNINGS-SAME-RETURN, WARNINGS-METHOD-ELIGIBLE, MINIMAL-APPLIED-LIST-
TYPES, LANGUAGE-LIBRARY-DEFICIENCIES, the golden README), and compiler or
tool source for: module resolution (`surface/modules.tcl`), library
location (`core/core.tcl`, `single/main.tcl`), the golden manifest
(`tests/golden.test`, `merge.tcl`), the JIT driver (`native/native.tcl`),
the range and exact-value analyses (`hir/range.tcl`,
`hir/exactvalue.tcl`), the discard fact (`hir/aot.tcl`), root planning and
multi-result calls (`roots.rs`, `clif.rs`). NIR was dumped about a dozen
times, CLIF once, allocation sites twice; one gdb session.

**Compiler source was needed to understand normal source behavior** for S4
(where modules may live), S8 (why a constant lost its value), S12 (why a
List is a callee candidate), S15 (where output went), S19 and S24. **Diagnostics
alone sufficed** for S5, S7 (an excellent one: it printed the facts it had),
S9 (with one guess), S10, S13, S17. **Docs alone sufficed** for the
warnings' intended answers (S10), Tcl installation, and the absence of
Int-to-String and division (once found in a deficiency report).

## 8. CLI

**Useful as is**: `-emit-nir` and `-emit-clif` on a `.hirx` (both modes,
with `-backend cranelift-generic`); `-emit-native-executable`, which made
the demo's output visible and gave gdb named functions; `-warnings
default|error`; HIR interchange as the bridge from a private library to
every main.tcl option; `native::allocationReport`, `native::measure` and
`native::roots` (Tcl API only, no CLI flag); the `BOTLISH_NATIVE_*_OPT=0`
toggles (undocumented in the CLI, decisive for S19).

**Questions no tool could answer**, ranked by how much they would have
saved:

1. *What does the compiler know here?* -- the Range and exact value of an
   expression at a line ("`size` is unknown here: not a local of this
   function"), the type it inferred where a check failed (S6, S8).
2. *Why does this allocate?* -- per allocation site: the value, why it is
   materialized (escapes, a default argument, an undiscarded loop), how
   often (S18).
3. *Which names compete for this method call, and why is each a
   candidate?* (S12).
4. *Where does a module named N come from, and how do I add one?* (S4).
5. *Why is this bounds check / handler still needed?* -- the index proof's
   view of `std::list::at(xs, i)` (S5, S7).
6. *Which function is botlish_fn_28?* (S19: a NIR dump answered it).
7. *Why did this function not specialize better?* -- instance keys and what
   they drop (`int, any`).

**Searches a command should replace**: the native registry for "is there an
Int-to-String" (a stdlib inventory with absences); module resolution
source; the golden manifest tooling; the JIT driver's output handling.

**Single-executable mode** could not have supported this investigation as
it went: it cannot import a module of the program's own (S4), so the
engine, the demo and the suite have to be one file each (S25), and that
form is what found S24. `-emit-nir`, `-emit-clif`, executables and the
`BOTLISH_NATIVE_*` environment toggles work there too (they are read by
the packed `native/*.tcl`); allocation reports, `native::measure` and
`native::roots` are Tcl API only, so not reachable from its command line.

**Stale or misleading output**: `-backend cranelift` printing a printing
program's value and nothing else (S15); the reference's "Known limitations"
saying `and`/`or`/`not` add no refinements (they do, P1); `main.tcl` with no
arguments runs four `.ir` examples instead of printing usage, and `-help`
is an unknown option.

## 9. Documentation and the future prompt

**Gaps**: where application modules go (nowhere, S4); that there is no
division and no Int-to-String (stated only in a deficiency report and a
helper's comment); that output needs the native backend and, there, an
executable; that a loop cannot carry state, and the idioms instead (S23);
what a golden suite that ports nothing should do (S3).

**Especially useful**: AGENTS.md's Tcl install recipe and its "what to run
when you change X" map (it named the right audits for the roots fix);
docs/README.md section 17 (surface syntax, one place); METHOD-SUGAR.md and
IMPORTS.md for the method rules; the warning documents, which state the
intended answers.

**Facts for the compact prompt** (core semantics a newcomer cannot
discover by failing):

* bindings are immutable; loops collect and cannot carry state: accumulate
  with a self-recursive helper (a tail call is a loop natively) or a
  MutableVector place;
* there is no division and no Int-to-String;
* `x.f(a)` is `f(x, a)` for any visible `f` -- including a local binding
  named `f`, whatever its type;
* `std::list::get(xs, i, default)` is the total read; `std::list::at` needs a proof
  or a handler, and only ascending counted loops and guards prove;
* a List's length is not part of its type; `type T = Int in a..b` is, and
  comparisons and counted loops prove it;
* struct and opaque struct syntax, enums are payload-free, errors and
  `on` handlers, `-> list` for a heterogeneous List.

**Not for the prompt** (tooling should expose them): which index shapes are
proven (a diagnostic hint), why a method call is ambiguous (the
diagnostic), what an expression's facts are (a query), allocation causes,
the golden-suite mechanics, warning answers (the warning documents, linked
from the warning).

**Terminology an agent will misread**: "module" (only `stdlib/`), "stdlib"
vs "library" (the same directory), `list` vs `List[T]`, "discarded"
(statement position only), `get` vs `at`, "context" (an installed
capability, not a parameter).

**Hard to infer**: that a non-function binding is a method candidate; that
a named constant does not carry its value into a function; that output is
native-only.

## 10. Language ergonomics

**Most natural**: the line move as compact / merge / pad; `changed` as one
value comparison; the direction-as-viewpoint pair `lines_toward` /
`rows_from`; opaque struct construction authority; domain-typed positions;
enums for direction and spawn tile; `static compile:` tests for "this must
not compile"; validation as three predicates over `std::list::all?`.

**Least natural**: anything that accumulates (recursion with a `nomethod`
helper and an accumulator struct, S23); flattening nested loops through a
MutableVector with a typed-empty helper (S6); decimal output by repeated
subtraction (S1, S2); fixed-size reads through `get` defaults (S7).

**Narrative coherence**: strong in the engine's line and board sections
and in `game_over?`, which read as the rules. **Index-heavy**: the merge
helper (`i + 1`, `i + 2`), `reversed` (`n - 1 - i`), `replaced`; all small.
**Ceremony**: `nomethod` on position-first helpers (3), the typed empty
vector, a fallback value for every fallible constructor in a test body,
the private-library driver.

**Readability review** (reading the engine without the compiler in mind).
The move algorithm reads as a story: "view the board from the direction,
slide every line, view it back", and a slide is "drop the empties, merge
pairs once, pad". The transformations are named (`lines_toward`,
`rows_from`, `transposed`, `each_reversed`); representation is localized
in the opaque `Board` and `rows`/`cell`; no proof appears in the source at
all -- the `Coordinate` domain is the only static fact written down, and
it is the rule ("a position is on the board"). What reads as compiler
appeasement: `nomethod` on the merge helper (a warning's answer), the
`no_positions()` typed-empty helper (S6), the literal `4` where `size`
was meant (S8), and `get` defaults that never happen (S7). It looks like
2048, not like a workaround.

**Abstractions considered and rejected**: a `Line` struct of four named
cells (case analysis instead of an algorithm); a flat 16-cell List (no
division); a MutableArray board (no measurement asked for it: the working
set is 1 MB and the cost is allocation, not copying); a matrix module (two
rectangular helpers are not evidence).

**No anonymous functions**: did not hurt; the one higher-order use
(`std::list::all?(cell?)`) reads better with a named predicate. **Value-oriented
state transitions** felt natural: `move` and `spawn` return new games, and
tests compare values. **Loop constructs** were sufficient for traversal and
insufficient for accumulation. **No overloading**: no friction (one
`value`, one `rows`). **Method sugar** mattered: the engine reads as
`rows.transposed().each_reversed()`, and the warnings push toward it -- but
it is also the source of S12.

## 11. Before the paired run

**Fix before the near-neighbor run** (each would otherwise contaminate the
experiment with a tooling failure rather than ordinary unfamiliarity):

1. S15: show a program's output under `-backend cranelift` (the driver
   already has it; main.tcl drops it), and say in the reference that
   output needs the native backend. **Resolved** (POST-2048-PRODUCT-FIXES.md):
   main.tcl runs a native program with its own standard output and error
   (`native::evalHir -output inherit`, `botlish-native --result`).
2. S22: raise main.tcl's Tcl recursion limit as the golden runner does.
   **Resolved**: both call `core::useProgramRecursionLimit`.
3. S4: a way for a program to have its own module, at least next to the
   entry file, usable from the single executable -- or, if that stays out,
   say so in the prompt and the reference. **Resolved**: application
   modules, the files beside the entry file (IMPORTS.md).
4. S8: a named program-level Int constant as an exact fact inside
   functions (`hir/range.tcl`'s `ref` case can consult
   `hir::exact::IntOf`). Resolved in `0db2443`: `hir::range::BindingRange`,
   shared by the range analysis and the completion walk, reads a
   binding no walk of the function binds as the exact Int it is bound
   to; the engine names its size again; tests in
   tests/exact-value-facts.test (`ev-outer-*`),
   range-and-contract-values.bot and tests/static-economics.test
   (`se-equal-outer-constant`).
5. S1: an Int-to-String in the stdlib (the test framework and every
   printing program reimplement it).
6. S12: either exclude bindings whose static type is not callable from
   method candidates, or make the diagnostic name the reason.
7. S16: the stdlib's own warnings should not reach a program that imports
   it -- today `-warnings error` rejects every program that imports `io`
   for two literals in `stdlib/io.bot`. **Resolved** (b94e3d0): `stdlib/io.bot`
   appends the newline as a character, `text.append_char('\n')`, with the
   new `std::str::append_char`; regressions in `tests/portable-io.test`,
   `tests/workload-2048.test` (`workload-2048-strict-warnings`: the
   engine, demo, suite and benchmark compile under `-warnings error`) and
   `tests/str-append-char.test`.

S24 is fixed already: it would have stopped the restricted agent's first
single-file native build with an internal error.

**Leave unfixed** (they distinguish learning from hand-holding): no
division, no fold, the typed-empty-vector idiom, the descending-loop index
proof, METHOD-ELIGIBLE's volume, the golden manifest's port assumption (the
paired agent will not use it), no private members, the allocation rate.

**Recommended near-neighbor workload: the 15-puzzle.** It keeps what made
2048 informative -- a 4x4 grid of Ints, nominal directions, value-state
transitions, a validated board invariant, a deterministic engine with
randomness outside, game-over/solved predicates, scenario tests -- and
changes the algorithm: moves are swaps of the blank with a neighbour rather
than slides and merges, legality depends on the blank's position (bounds
the type system can carry), solvability is a parity computation (an
accumulation: S23 again) and a shuffle needs a generator. Lights Out is
too small (XOR toggles), Sokoban adds a second entity kind and rule tables
that would change the representation question, Minesweeper adds flood fill
(recursion depth, S22) that would test the interpreter more than transfer.

**Expected traps for the restricted agent**: a module of its own (S4), and
with it silent shadowing between its helpers and its tests and no opaque
encapsulation (S25); printing (S15); deep recursion on interp (S22); method
ambiguity from a local name (S12); a typed empty vector (S6); `std::list::at`
proofs and a named size (S5, S8); Int-to-String (S1). A tooling failure is a trap whose fix
needs information only compiler source holds today (S4, S8, S12, S15, S22);
ordinary unfamiliarity is one the diagnostic or the reference answers
(S5, S6, S7, S9, S13).

## 12. Single executable

`single/build.sh` built it (a static Tcl 9.0.1 base kit from the pinned
source tarball, its checksum verified; 7.6 MB). Copied to an empty
directory outside the repository and run with an empty environment
(`env -i`, no PATH):

* **The demo's HIR**, built in the checkout (`run.tcl -hirx`), through
  `botlish -emit-native-executable demo.hirx`: the stub-linked executable
  prints exactly the pinned output, also under GC stress. `botlish -backend
  cranelift demo.hirx` shows only `value: unit` (S15).
* **One source file** -- the engine and the demo concatenated, the only
  way a single-executable user can use the engine (S4) -- compiled from
  source by the single executable: identical output, also under GC stress.
  This is how S24 was found: before the fix the build stopped with
  `native lowering: e1692 does not capture b325 (NATIVE BUG)`.
* **The suite in one file**: 66 passed, 2 failed on all four backends --
  the two tests that `Board`'s construction and fields belong to the
  engine, which cannot hold when the engine and its user are one entry
  program (S25), after renaming two suite functions that silently
  shadowed engine functions.
* **A module beside the program**: `unknown namespace "game2048": no such
  module file //zipfs:/app/botlish/lib/game2048.bot and no intrinsics of
  that namespace (SURFACE MODULE UNKNOWN-NAMESPACE)` -- accurate, and it
  names the only place a module can live, inside the executable.

Packaging works; what the single executable could not do is let a program
have more than one file. **Since S4's fix** it can: in an empty directory
holding the single executable and copies of `demo.bot`, `game2048.bot` and
`golden.bot`, `botlish -backend cranelift demo.bot` prints the whole game
(S15) and the suite passes 68 of 68 on all four backends -- the two
opacity tests included, since the engine is a module again
(POST-2048-PRODUCT-FIXES.md).
