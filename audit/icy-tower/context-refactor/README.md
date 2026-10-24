# audit/icy-tower/context-refactor/

The evidence of ICY-TOWER-CONTEXT-REFACTOR-CENSUS.md (docs/): Icy Tower's
SDL put behind a context, and what that showed about the language. The
refactored game itself is `examples/games/icy-tower/` and its executable
`audit/icy-tower/artifacts/icy-tower`, where the workload already keeps
them.

| path | what |
|---|---|
| `counts.txt` | the before/after counts (`tools/census.tcl` on commit 6df89a8e's tree and on the refactor) |
| `tools/census.tcl` | the counts: pointer clones, pointer-holding functions and structs, destructurings and constructions, calls carrying pointers across modules, SDL calls, views and edits, imports, context requirements -- from the front end's HIR, for any tree (`APP_DIR`, or `-rev REV`) |
| `tools/escape-candidates.tcl` | the warning candidate's measuring instrument (rules R1-R4 of the report's section 11), for any program |
| `tools/repro.tcl` | runs the reproducers and checks each against the expectations in its header (all four backends, or `check`) |
| `tools/sdltrace.c`, `tools/trace-compare.sh` | an LD_PRELOAD interposer logging every SDL call with its arguments, and the comparison of two executables' traces |
| `repro/` | the minimal reproducers, one issue each, no SDL: a1, a1b, a2 (a context cannot hold an affine value), b1 (mutable non-affine context state), b2 (pointers retained in native memory through a view), b2b (a bare view is no native context slot), c1, c1b, c2 (installation: no handler, no condition), c3 (affine is not linear), e1 (contexts compose as requirements, not ownership), f1 (the compiler bug fixed), g1 (a view leaks raw memory through an airlock) |
| `variants/ids/` | the same `sdl.bot` API retaining SDL through SDL's own window IDs, scratch memory per call |
| `variants/opaque-values/` | Design A: an opaque affine resource value instead of context state |
| `variants/canvas/` | a `context trait Canvas` between render.bot and SDL, and a recording canvas drawing frames on all four backends |
| `baseline/` | the original boundary's modules (commit 6df89a8e, verbatim): the regression fixture of the CONTEXT-RESOURCE-ESCAPE warning (MODULE-PRIVACY-AND-CONTEXT-ESCAPE-MILESTONE-1.md), which draws on it exactly the census's twelve warnings |
| `warning-census/` | the repository census of the warning candidate (`partition-a.*`: libraries, examples, benches, golden suites, bindings; `partition-b.*`: the Tcl tests' embedded programs and the fuzzers' programs) |

Every tool keeps its scratch files in a private temporary directory and
removes it.

The variants were written against the game at commit 4be79514, before
NUMERIC-TEXT-BOUNDARY-MILESTONE-1.md replaced `hud::int_text`,
`tenths_text`, `nearest` and `metres_text` with the standard library's
conversions; `variants/opaque-values/render.bot` and `variants/canvas/`
still call them. Build a variant beside that revision's pure modules
(`git show 4be79514:examples/games/icy-tower/hud.bot`, and `tower.bot`,
`options.bot` and `golden.bot` likewise), as their NOTES.md describe:
they are evidence measured there, not code to keep current.
