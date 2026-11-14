# audit/dotenv-interoperability

The evidence of EMISSION-DOTENV-INTEROPERABILITY-CENSUS-MILESTONE-1.md: how
real dotenv implementations read a file, which subset of key/value data every
one of them reads back exactly (the portable emission profile), and what a
future pure-Botlish reader, emitter and compatibility linter must know. No
Botlish compiler, standard-library or environment behavior is changed by
anything here; the `emits/` probe only *uses* the compiler.

## Layout

| path | what |
|---|---|
| `versions.json` | every pin not covered by an ecosystem lock (the Node runtimes, the dotenv-java jars, the .NET SDK), the host runtimes asserted, the newest releases on the census date |
| `oracles/` | one adapter per implementation, and its lock: `node-builtin/` (`util.parseEnv`; `dump.mjs` for `--env-file` and Bun), `node-dotenv/` (+`v16`, `v17`; `package-lock.json`), `bun/` (+`v1.3`), `python/` (`requirements*.txt` with hashes), `ruby/` (+`v2`; `Gemfile.lock` with `CHECKSUMS`), `dotnet/` (dotenv.net 4 and 3, DotNetEnv; `packages.lock.json`, `global.json`), `java/` |
| `fixtures/*.py` | the hand-written corpus (363 fixtures in 13 categories), materialized as `fixtures/corpus.jsonl` (exact bytes, SHA-256, safety) |
| `generated/` | the seeded generated corpus (`corpus.jsonl`, `config.json`) and its minimized disagreements (`minimized.jsonl`, part of the permanent corpus) |
| `realworld.json` | 19 public example files, pinned by commit and SHA-256 (their contents are never committed) |
| `emits/` | the portable profiles as Botlish declared recognizers and emitters claiming them, with negative controls (`mutants.txt`) |
| `tools/` | the harness (below) |
| `results/` | the committed baseline and the reports (below) |

## Running it

Everything installs into the census cache (`$DOTENV_CENSUS_HOME`, else
`~/.cache/botlish/dotenv-census`), never into the repository, and every
artifact is verified against its lock or `versions.json` before use.

```sh
python3 -I tools/setup.py install        # Node 26/24/22, npm dotenv, Bun, python-dotenv, Ruby dotenv, .NET adapters, dotenv-java
python3 -I tools/selftest.py             # no reference implementation needed
python3 -I tools/census.py all           # every corpus, every target, every report (about 2.5 minutes on 4 cores)
DOTENV_CENSUS_RESULTS=/tmp/fresh python3 -I tools/census.py all
python3 -I tools/compare.py --fresh /tmp/fresh --policy baseline   # what CI does
python3 -I tools/realworld.py run && python3 -I tools/realworld.py report
python3 -I tools/emits.py                # needs tclsh9.0 (AGENTS.md, "Installing Tcl 9")
python3 -I tools/setup.py check-latest   # the pins against the registries
```

One fixture on chosen targets: `python3 -I tools/run.py --corpus hand --only
quote-single --targets java,python --out /tmp/x`. A disagreement minimized:
`python3 -I tools/minimize.py disagree --corpus hand --id ID --targets A,B`.

The host runtimes (Bash, Python, Ruby, the JDK) are asserted against
`versions.json`; `--any-runtime` runs on others and records them.

## Tools

| tool | does |
|---|---|
| `setup.py` | installs and verifies the pins; `check-latest` |
| `corpus.py` | fixture definitions -> `fixtures/corpus.jsonl`; `check` |
| `safety.py` | the static classification: which fixtures Bash may source, which a loading runtime may load |
| `run.py` | the differential runner: corpus x targets x environment modes -> normalized observations |
| `analyze.py` | agreement classes, the disagreement taxonomy, the differential, configuration and cross-version reports |
| `portable.py` | the candidate-encoding search, the profile rules, `emit`, seeded round trips, the portable report |
| `generate.py` | the generated corpus and the minimization of its disagreements |
| `minimize.py` | batched delta debugging with a preserved witness |
| `realworld.py` | public example files: pin, fetch, run (pure parsers only), report without values |
| `emits.py` | the emits probe and its mutants |
| `census.py` | `all` (everything, in order) and the compact matrix |
| `compare.py` | a fresh tree against the baseline, under the CI policies |
| `selftest.py` | the harness's own checks |

## The targets

The reference set (`common.REFERENCE`): `bash` (GNU Bash 5.2.21, `set -a;
source FILE` in a restricted shell), `node-builtin` (Node 26.13.1
`util.parseEnv`), `node-envfile` (`node --env-file`), `node-dotenv` (dotenv
18.0.10 `parse`), `bun` (Bun 1.4.4 `--env-file`), `python` (python-dotenv
1.2.4 `dotenv_values`), `ruby` (dotenv 3.2.0 `Dotenv.parse`), `dotenvnet`
(dotenv.net 4.2.0 `DotEnv.Read`), `dotnetenv` (DotNetEnv 3.2.0 `Env.Load`, a
supplement chosen on download evidence) and `java` (dotenv-java 3.2.0
`entries(DECLARED_IN_ENV_FILE)`). Configurations of the same libraries
(`node-dotenv-fast`, `python-nointerp`, `ruby-trusted`, `dotenvnet-strict`,
`dotenvnet-extended`, `java-lenient`) and one older widely deployed release
of each (`...@24`, `@22`, `@17`, `@16`, `@1.3`, `@1.0`, `@2`, `@3`) are
targets too. `tools/common.py` says exactly how each is run.

## Adapter protocol

A batch adapter takes `--manifest FILE --config NAME --target NAME`; the
manifest is `{"fixtures": [{"id", "path"}, ...]}`. It writes one JSON line
of `{"type": "meta", runtime, library, library_version, options}`, then one
line per fixture: `{"type": "result", id, status: ok|error, assignments:
[[key, value], ...], error: {class, message} | null, warnings, views,
events}`. Strings escape every UTF-16 unit outside printable ASCII, so lone
surrogates and controls cross losslessly; a value is `null` when the
library returns no value (python-dotenv's `KEY` line). A loading target
(`node-envfile`, `bun`) is run once per fixture with `dump.mjs`, and the
harness subtracts the environment it supplied; DotNetEnv, which writes the
process environment, runs in a fresh process per fixture.

The harness normalizes each observation (`run.py`): the map sorted by key,
paths scrubbed from messages, a map or view over 8 KB kept as its exact
SHA-256. A crashed adapter is resumed after the fixture that crashed it,
which is recorded `adapter-failure` -- never an implementation's behavior.

## Safety

* Bash runs a fixture only when `safety.py` proves it a plain-assignment
  file in an audited subset of Bash's grammar (no command, no `$(`, no
  backtick, no control operator or redirection, no shell-special or
  host-dependent variable), and even then in a restricted shell (`bash -r`)
  with an empty `PATH`, a private directory, a timeout. A downloaded file is
  never sourced, whatever its classification.
* Ruby's command substitution (`$(...)`) never runs: the adapter answers the
  library's backtick call on its Command module with a placeholder and
  records the command; every other way to start a process is disabled in the
  adapter process. The `ruby-trusted` configuration runs only the exact
  commands an audited fixture lists (`echo hi`).
* A file that names a variable a runtime obeys at startup (`NODE_OPTIONS`,
  `LD_PRELOAD`, `JAVA_TOOL_OPTIONS`, `PATH`, ...) at a key position is never
  loaded into a real process (`node-envfile`, `bun`, `dotnetenv`).
* Every oracle starts in a controlled environment, recorded with its
  results: the clean mode (a fixed `PATH`, a `HOME` that names no
  directory, a private `TMPDIR`, `LANG`/`LC_ALL=C.UTF-8`) and the conflict
  mode (the same plus `CENSUS_PRESET`, `CENSUS_REF`, `CENSUS_EMPTY_ENV`,
  `CENSUS_SPACES`). Nothing inherited from the machine reaches an oracle.
* Fixtures are synthetic; real-world files are kept out of the repository and
  reported without values.

## Results

| file | what |
|---|---|
| `results/hand/`, `generated/`, `minimized/`, `portable/` | the baseline: per target, every observation (one line per fixture), its meta and the environments supplied |
| `results/matrix.md` | the compact matrix: one fixture per principal feature, each reference target's reading |
| `results/hand-differential.md` | every hand fixture's agreement classes (also `generated-`, `minimized-`) |
| `results/*-summary.json` | the same, machine-readable, with the disagreement kinds |
| `results/configurations.md`, `results/cross-version.md` | configuration and version differences |
| `results/portable.md`, `results/portable/encodings.json` | the candidate encodings, the classification, layouts, keys, round trips |
| `results/realworld.md`, `.json` | the public example files: features, disagreements by key (values as digests) |
| `results/emits.json` | the emits probe's verdicts and mutants |

## CI

`.github/workflows/dotenv-interoperability.yml` runs on every push that
touches this directory: the Linux baseline (a fresh census compared with
`results/` under the baseline policy: any drift fails; the self-test; the
emits probe; the pins against the registries), macOS and Windows (the same
census under the portable policy: host differences are reported, a lost
portable category or a round trip that reads back differently fails) and the
real-world files. A missing or crashed oracle is never a pass.
