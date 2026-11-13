# Vim syntax tests: no swap file beside a shared source (completion note)

`tests/syntax-highlighting.test`'s Vim tests failed when two copies of the
file ran at once, as `tests/local.tcl` runs them: the interp and compile
copies start together. Vim's swap file was the shared state. The helper
now runs Vim with `-n`, and a regression test runs it beside a Vim that
holds a swap file. This note is a correction of a test, not of Botlish: no
compiler, language, runtime or grammar file changed.

## 1. The original failure

EMISSION-BINDING-PROVENANCE-CORRECTNESS-MILESTONE-1.md recorded one failure
of `tests/local.tcl`: `sh-grammar-vim-fixture` on compile, whose `vim`
exited 1. The file passed when run alone, and its interp copy passed in the
same run. The report traced it to Vim's swap file and noted that
`sh-grammar-vim-corpus` had the same exposure.

## 2. Root cause

`shVimGroups` runs Vim on the source file in place: the fixture
(`editors/vscode/test/fixtures/sample.bot`), or `stdlib/actor.bot` and
`examples/dfa/csv/csv_strict.bot` for the corpus test. Its script and its
output (`check.vim`, `out.txt`) were already private, in a `file tempdir`
directory. But Vim, without `-n`, makes a swap file beside the file it
edits (`.sample.bot.swp`, created with `O_EXCL`), named for that file, and
so shared by every run of the same path. A second Vim that opens the file
while the first holds it finds that swap file. In `-es` mode it raises
E325 (ATTENTION), prints nothing, and exits 1: `exec` reported "child
process exited abnormally", `CHILDSTATUS PID 1`. Whichever copy's Vim
started second failed. An editor that has the fixture open, or a swap file
left by a crashed Vim, would fail the test the same way.

(The earlier report says the corpus test "edits stdlib/actor.bot in place".
It reads the file: the trace below shows Vim opening it read-only. Only the
swap file was written beside it.)

## 3. The command

Before (`shVimGroups`):

    exec vim -Nu NONE -i NONE -es -S [file join $dir check.vim] << ""

After:

    exec vim -Nu NONE -i NONE -n -es -S [file join $dir check.vim] << ""

## 4. Why the new invocation is safe for concurrent runs

`-n` turns off swap files: Vim makes none, and so neither creates one
beside the source nor looks for another Vim's. A noninteractive run that
reads a file and quits with `qa!` never needs one for recovery. With `-n`,
the one file Vim writes is the helper's private `out.txt`. Two runs of one
path now share only read access to that file.

`-n` changes nothing else. A Vim error still fails the test. A script error
exits 1 with and without `-n`. A `vim` that exits 1 fails all three Vim
tests, none of them skipped. The syntax file, the source, the positions
and the assertions are as before.

## 5. Other shared state

Vim's file operations, traced with `strace` (`openat`, `creat`, `mkdir`,
`rename`, `unlink`, `link`, `symlink`, `chmod`, `truncate`) over the
helper's exact script on the fixture:

| run | writes outside the helper's own directory | the source file |
|---|---|---|
| without `-n` | `.sample.bot.swp` (created twice, `O_CREAT\|O_EXCL`), a `.sample.bot.swx` probe, both unlinked again, and a `chmod` | read-only |
| with `-n` | none (its only write is `out.txt`) | read-only |

There is no backup, undo, viminfo (`-i NONE`) or session file, and nothing
under the home directory. The swap file was the only shared writable
state, so `-n` is enough, and the tests read the source in place. No
private copies are needed.

Found on the way, and not changed here:

* **`sh-grammar-vim-corpus` depends on an earlier test.** It calls
  `grammars::Declared`, which exists only after `sh-grammars-refuse-drift`'s
  `-setup` has sourced `tools/editor-grammars.tcl`. A whole run of the file
  always does that first, so `tests/local.tcl` and CI are not affected.
  Run alone (`-match sh-grammar-vim-corpus`), the test fails with "invalid
  command name grammars::Declared". This also affects
  `audit/syntax-highlighting/tools/mutate.tcl`, which runs each mutant's
  `!!` tests by `-match`. The corpus test fails there for every mutant,
  without ever reaching Vim. So `vim-declared-name-claimed`'s kill "by
  sh-grammar-vim-corpus" is not a real kill. Its kill by the fixture test
  is (Vim exited 0, and the test found the mismatched groups). A mutant
  only the corpus test could catch would be reported killed regardless.
* **The file has no golden census.** `syntax-highlighting.test` is one of
  nine test files with no `audit/golden/migration/census/` file, so none of
  its tests has a manifest row. The new test is in the same position: no
  row, run by `tests/local.tcl` like the file's other tests.

## 6. Concurrent reproducer results

**The command itself.** Two Vims started together with the helper's
script, on one file, repeated (a shell loop of two background `vim ... &`
and `wait`):

| file | flags | pairs | both 0 | one exited 1 | swap file left |
|---|---|---:|---:|---:|---|
| sample.bot | (before) | 50 | 34 | 16 (8 the first, 8 the second) | no |
| sample.bot | `-n` | 50 + 200 | 250 | 0 | no |
| stdlib/actor.bot | (before) | 50 | 16 | 34 | no |
| stdlib/actor.bot | `-n` | 200 | 200 | 0 | no |

**Deterministic.** A Vim without `-n` keeps a copy of the fixture open in a
pipeline, so its swap file is present for the whole check. The helper's
command run beside it exits 1 every time without `-n`, and 0 every time
with it.

**The test file.** Pairs of `tclsh9.0 tests/syntax-highlighting.test`
processes started together, each with its own `-tmpdir`, per round:

| pair | before: rounds failed | after: rounds failed |
|---|---:|---:|
| fixture beside fixture (interp, interp) | 14 of 15 | 0 of 25 |
| corpus beside corpus | 15 of 15 | 0 of 25 |
| fixture beside corpus (different files: control) | 0 of 15 | 0 of 25 |
| the Vim tests on interp beside compile | 15 of 15 | 0 of 25 |

(The corpus runs also match `sh-grammars-refuse-drift`, for the reason in
section 5.) The fixture and the corpus files were unchanged after every
series (SHA-256), and no swap file remained beside any of them.

To run such a pair by hand:

```bash
export LANG=C.utf8 LC_ALL=C.utf8
for b in interp compile; do CORE_BACKEND=$b tclsh9.0 tests/syntax-highlighting.test -tmpdir "$(mktemp -d)" -match 'sh-grammars-refuse-drift sh-grammar-vim-*' & done; wait
```

**`tests/local.tcl tests/syntax-highlighting.test`**, the original setting
(interp and compile in parallel), repeated:

| | runs | failed |
|---|---:|---:|
| before | 20 | 15 (each time one copy's `sh-grammar-vim-*`, the other passing) |
| after | 20 | 0 |

## 7. The regression test and the file's results

`sh-grammar-vim-beside-swap-file` turns the failure into a deterministic
test of the real helper. It copies the fixture into a `file tempdir`
directory and opens it in a holder Vim without `-n`, a pipeline whose
standard input it keeps open. It waits until the holder answers a command
(`verbose echon "ready\n"`): Vim makes its swap file when it reads the
file, before it reads any command. It then checks that the swap file
exists, and runs `shVimGroups` on the same path with the fixture's
positions. It expects `{ready 1 {}}`: the holder answered, its swap file
was there, and the groups match the fixture's classes as in
`sh-grammar-vim-fixture`. A swap file beside the fixture itself would be
the defect this test exists for, so the holder opens a private copy. The
holder ends with `qa!` and the closing of its pipeline. It carries the same
`vimEditor` constraint as the other Vim tests.

* Against the old helper: failed 3 of 3 runs, "child process exited
  abnormally", `CHILDSTATUS ... 1`.
* With `-n`: passed 3 of 3 runs.
* With a `vim` that exits 1: `sh-grammar-vim-fixture`, `-corpus` and
  `-beside-swap-file` all fail.
* With no `vim` on PATH: the three are skipped (`vimEditor`).

The whole file, after the change: 27 passed, 1 skipped (`nodeTextMate`:
no `npm ci` in `editors/vscode` here) on interp and on compile, as before
plus the new test. The syntax-highlighting mutants the Vim tests kill,
`declared-name-qualified` and `vim-declared-name-claimed`, are still killed
by `sh-grammar-vim-fixture`, with Vim exiting 0 inside each run.
`tools/mutant-catalogs.tcl`: 108 catalogs, 3715 mutants, 0 problems.

## 8. Files changed

* `tests/syntax-highlighting.test`: `-n` in `shVimGroups`, with its
  reason; the new test `sh-grammar-vim-beside-swap-file`.
* `docs/TEST-VIM-CONCURRENT-ISOLATION-FIX.md`, and its line in
  `docs/INDEX.md`.

## 9. Remaining limitations

* The two findings of section 5 are open: the corpus test's dependence on
  `sh-grammars-refuse-drift` (and so its spurious kills in the mutation
  harness), and the missing census.
* The tests still read the shared sources in place. That is safe only
  while nothing writes them during a run. A test that edited one of them
  would need a private copy.
* Neovim's tests (`tests/lsp-neovim.test`) are not exposed. They open
  files only in a directory of their own process (`lsp-neovim-PID`, the
  fixture copied into it), so two runs never edit one path, and Neovim's
  swap files, named by the full path, never coincide. They were not run
  here (no Neovim).
* Windows does not run the Vim tests (`vimEditor`).
