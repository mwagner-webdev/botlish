# Emission: dotenv interoperability census (milestone 1)

A census, not an implementation. It establishes, by running real
implementations on pinned versions, what a future pure-Botlish dotenv reader
and emitter must reproduce and what a portable emitter may write. The
evidence is `audit/dotenv-interoperability/` (its README.md is the manual);
the CI workflow `.github/workflows/dotenv-interoperability.yml` recomputes it
on Linux, macOS and Windows and fails on drift. Nothing in the compiler, the
standard library or any environment facility changed. The `emits/` probe
uses the compiler as it is.

Every statement below about what an implementation does is an observation of
that implementation in the census. Each is linked to its fixture (its id, its
bytes in `fixtures/corpus.jsonl`) and to the committed results under
`results/`. Where a statement rests on documentation or on reading source
rather than on a run, it says so.

## 1. Executive conclusion

* **There is a useful common subset, and it is narrow and precise.** Write
  `NAME="VALUE"` and end each line with LF.
  - NAME is an ASCII identifier `[A-Za-z_][A-Za-z0-9_]*`. It must not be a
    variable a shell or a runtime treats specially, and no two names may
    differ only by case.
  - VALUE may hold any Unicode scalar value except four characters
    (`"`, `\`, `$`, backtick), the C0 controls other than TAB, DEL and the C1
    controls.
  - Every one of the ten reference implementations reads such a file back
    exactly, Bash included. The evidence: 935 candidate encodings (section
    14) and 1,800 random multi-assignment files from the whole admissible
    domain (11,550 assignments). Not one value differed.
  - A multi-line extension admits LF under two conditions: the value does not
    start with a LF, and it holds no `#`, U+2028 or U+2029. It passes
    the same test (900 files).
  - Hosts: the single-line profile holds on Linux, macOS and Windows. The
    multi-line extension holds on Linux and macOS only. On Windows,
    dotenv.net reads every LF of a multi-line value as CRLF: it joins the
    lines with `Environment.NewLine`. So no multi-line value is portable
    there while dotenv.net is a consumer (section 19.1).
* **Some data has no portable encoding at all.**
  - The double quote, the backslash, the dollar sign, the backtick, CR, NUL
    and a value that starts with a LF have no encoding that every reference
    reads back.
  - The blockers are specific consumers: Java keeps single quotes literally,
    Node and npm dotenv keep backslashes, Bash, Bun, Python, Ruby and
    DotNetEnv expand `$`, and Bash keeps CR (section 15).
  - A portable emitter must refuse such values. It must never rewrite them.
* **The readers are deeply incompatible.**
  - Of 363 hand-written fixtures, 93 produce one outcome on all ten
    references. Of 600 generated feature combinations, 579 disagree
    somewhere, falling into 204 distinct partitions of the targets.
  - Even within one language they disagree. Node's own `util.parseEnv` and
    npm `dotenv` read `export<TAB>KEY=v` differently, and so do dotenv.net and
    DotNetEnv on almost everything.
  - The differences are common in real files. Laravel's `.env.example`
    reads differently in five implementations than in four
    (`${APP_NAME}`), and Open WebUI's in Java than in the other eight.
    7 of 19 public example files are read differently by some reference.
* **Bash is an acceptance test, not a parser.** A sourced file is shell
  code. Bash ran only the 269 hand fixtures (of 363) that the census's static
  classifier proved to be plain assignments, in a restricted shell with an
  empty `PATH`. It never ran a downloaded file.
* **The emitter can carry a useful `emits` claim today.** The Botlish
  compiler certifies an emitter of the single-line profile, and one of the
  multi-line extension written so that the recognizer's state follows the
  code's shape. It rejects all ten negative controls.
  - The natural multi-line emitter, whose state is a fold's intermediate, is
    not certified. That is a recorded precision limit: the checker relates no
    value to the recognizer's state.
  - The grammar says nothing about meaning. That every consumer reads the
    meaning intended is the census's runtime evidence, not a static proof
    (section 24).
* **Recommendation.**
  - A pure standard-library reader keeps the source: entries with spans,
    quoting and raw text. It projects them into maps per explicitly named
    dialect, and its default is the portable profile in strict form, never one
    existing dialect.
  - The emitter writes the portable profile and fails on anything outside it.
  - The compatibility linter is a separate package. It carries the census's
    compatibility knowledge as data validated in development, and needs no
    external runtime when it runs (sections 21 to 25).

## 2. Reference implementation selection

The selection the milestone named was kept, and verified against
popularity evidence gathered on 2026-11-14:
- npm's download API: last month, and the share per version for last week.
- NuGet's search index: total downloads.
- RubyGems: total downloads and downloads per version.
- deps.dev: dependent packages.

| ecosystem | reference | evidence | alternatives considered |
|---|---|---|---|
| Shell | GNU Bash (`source`) | the shell `set -a; . ./.env` idioms target | -- |
| Node.js built-in | `util.parseEnv` / `--env-file` (Node 26.13.1 LTS) | part of every Node installation | -- |
| Node.js ecosystem | npm `dotenv` 18.0.10 | 941.6 M downloads/month; 1,802 dependent packages (deps.dev) | `@dotenvx/dotenvx` 80 M/month (dotenv's author's successor, with its own parser); `dotenv-expand` 215 M (an add-on, not a parser) |
| Bun | built-in loader 1.4.4 | the runtime's only loader | -- |
| Python | `python-dotenv` 1.2.4 | 70,326 dependent packages (deps.dev); `environs` 275, `django-environ` 265 | -- |
| Ruby | `dotenv` 3.2.0 (bkeepers) | 572 M total downloads | -- |
| .NET | `dotenv.net` 4.2.0 (bolorundurowb) | 13.3 M total downloads | **`DotNetEnv` 3.2.0 (tonerdo): 32.9 M**, the most downloaded |
| Java | `dotenv-java` 3.2.0 (cdimascio) | 300 dependents (deps.dev); the older artifact `java-dotenv` 55 | `spring-dotenv` (4 dependents) uses dotenv-java |

**Supplemented, not replaced: DotNetEnv.** NuGet counts 2.5 times as many
downloads for DotNetEnv as for dotenv.net, so dotenv.net is not the most
representative .NET implementation. Both are references:
- dotenv.net because the milestone named it.
- DotNetEnv on the evidence.

The two .NET dialects differ more than any other pair (section 16).

**Version shares change which "baseline" matters.** npm dotenv's downloads
last week were 47% 16.x, 41% 17.x and 5% 18.x. Ruby dotenv's most
downloaded releases ever are 2.8.1 and 2.7.6. Each library is pinned at its
latest release, as the milestone asks. One older, widely deployed release of
each is a cross-version target (section 18).

**Not in the reference set, and important for mixed-language monorepos.**
These are recorded for a later census:
- PHP's `vlucas/phpdotenv`, Laravel's loader. Laravel's `.env.example` is
  among the real-world files.
- Docker Compose's `env_file`/`.env` reader (compose-go). Six of the 19
  real-world files are written for it.
- Go's `godotenv` and Rust's `dotenvy`.

## 3. Versions, configurations and APIs

All pins are in `versions.json` and the oracles' locks. `tools/setup.py
check-latest` re-queries the registries, and CI prints the result. On the
census date every pin was its registry's newest release.

| target | implementation, version | API used | configuration | writes process state? | evaluates code? |
|---|---|---|---|---|---|
| `bash` | GNU Bash 5.2.21 (Ubuntu 24.04) | `set -a; source fixture.env` | `bash --noprofile --norc -r`, empty `PATH`, private directory | its own shell only | yes, by design (section 5) |
| `node-builtin` | Node.js 26.13.1 | `util.parseEnv(text)` | file read as UTF-8 | no | no |
| `node-envfile` | Node.js 26.13.1 | `node --env-file=FILE` | fresh process per fixture | yes (its process) | no; reads `NODE_OPTIONS` from the file (documentation) |
| `node-dotenv` | dotenv 18.0.10 | `dotenv.parse(text)` | default parser | no | no |
| `bun` | Bun 1.4.4 | `bun --no-env-file --env-file=FILE` | fresh process, empty working directory | yes (its process) | no |
| `python` | python-dotenv 1.2.4 | `dotenv_values(path)` | `interpolate=True`, `encoding="utf-8"` (defaults) | no | no |
| `ruby` | dotenv 3.2.0 | `Dotenv.parse(path)` | `overwrite: false` (default) | no | **yes: `$(...)` runs a shell** (section 5) |
| `dotenvnet` | dotenv.net 4.2.0 | `DotEnv.Read(new DotEnvOptions(envFilePaths: [path]))` | library defaults | no (verified per fixture) | no |
| `dotnetenv` | DotNetEnv 3.2.0 | `Env.Load(path)` | defaults: set the environment, clobber | **yes**, so a fresh process per fixture | no |
| `java` | dotenv-java 3.2.0 | `Dotenv.configure().directory(d).filename(f).load()`, `entries(DECLARED_IN_ENV_FILE)` | defaults (throw if malformed) | no | no |

Runtimes on the baseline host: CPython 3.13, Ruby 3.3.6, Temurin 21 (locally
OpenJDK 21.0.12), .NET 10.0.404 (runtime 10.0.15). The configuration
targets and what they change are in section 16 and `results/configurations.md`:
- `node-dotenv-fast`: `parse(text, {fast: true})`.
- `python-nointerp`: `interpolate=False`.
- `ruby-trusted`: audited commands run.
- `dotenvnet-strict`: `WithExceptions()`.
- `dotenvnet-extended`: also `WithSupportExportSyntax().WithVariableExpansion()`.
- `java-lenient`: `ignoreIfMalformed()`.

**Java's three views.** dotenv-java exposes three readings of one load, and
the adapter records all three:
- `entries(DECLARED_IN_ENV_FILE)`: the file's own values.
- `get(key)`: what an application reads. It looks at `System.getenv` first.
- `entries()`: the file overlaid by the whole environment.

In the conflict mode they differ: `env-preset-assigned` declares
`from-file`, but `get` returns `from-environment`.

**Locks.**
- npm: `package-lock.json` (integrity hashes), installed with `npm ci
  --ignore-scripts`. Bun's binary is its platform package's file, so no
  install script runs.
- Python: `requirements.txt` with `--require-hashes`.
- Ruby: `Gemfile.lock` with Bundler's `CHECKSUMS`. The gem is installed by
  Bundler and run without it, so no Bundler variable reaches the parser.
- .NET: `packages.lock.json`, restored in locked mode.
- Java: the jar's SHA-256 in `versions.json` (Maven has no lock).
- Node: the release tarballs' SHA-256 from nodejs.org.

Nothing downloads an unversioned script.

## 4. Safety and environment isolation

The safety boundary is static and mechanical (`tools/safety.py`). Section 5
covers Bash. The other rules:

* **Ruby's command substitution never runs.** dotenv's
  `Dotenv::Substitutions::Command` finds an unescaped `$(...)`, substitutes
  variables into the command text, and runs it with `Kernel#``.
  - The adapter leaves the library's code untouched and answers only that
    final backtick call, on the Command module itself. It records the
    command and returns a placeholder.
  - Every other process-spawning method is disabled in the adapter process.
  - The census therefore observes *that* Ruby would execute a command, and
    which command: `cmd-variable-into-command` shows Ruby 3.2 running
    `echo fromfile`, with the file's variable already substituted.
  - The `ruby-trusted` configuration runs only the exact commands an audited
    fixture lists. `echo hi` becomes `hi`.
  - A dialect-compatible reader can keep the substitution as syntax, a
    `command` segment of the value, without evaluating it (section 22).
* **No runtime-control variable enters a real process.** A file is never
  loaded into a process (`node-envfile`, `bun`, `dotnetenv`) if it names, at
  a key position of any line, a variable a runtime obeys at startup:
  - variables with the prefixes `NODE_`, `BUN_`, `LD_`, `DYLD_`, `DOTNET_`,
    `PYTHON` and others;
  - the variables `JAVA_TOOL_OPTIONS`, `PATH`, `TZ` and others.

  Node reads `NODE_OPTIONS` from the `--env-file` itself (documentation).
  This conservative rule skipped three real-world files for the loading
  targets: they set `NODE_ENV`.
* **Controlled environments.**
  - **Clean mode:** a fixed `PATH`, a `HOME` that names no directory (so a
    value read from it is the same on every host), a private `TMPDIR`, and
    `LANG`/`LC_ALL` set to `C.UTF-8`.
  - **Conflict mode:** the clean mode plus `CENSUS_PRESET=from-environment`,
    `CENSUS_REF`, an empty `CENSUS_EMPTY_ENV` and `CENSUS_SPACES`. Only
    `fixtures/environment.py` and a few interpolation fixtures name them.
  - Every target's results record the exact environment it was given. Nothing
    inherited from the machine reaches an oracle.
  - Two runs of the whole census compare equal. The two sources of run
    dependence were found and closed: Bash's `$$`, and `HOME` returned by
    Ruby's environment-first rule.
* **Process state is checked, not assumed.** The pure-API adapters compare
  the process environment before and after each parse, and would record a
  change. None occurred.
* Every fixture is synthetic, and no value in the census is a secret.

## 5. Bash's special role

Bash does not parse dotenv: it executes the file. The census therefore uses
Bash only as an acceptance test of controlled files, the portable profile's
first of all.
- **What runs.** A fixture runs only when the static classifier proves it a
  sequence of plain assignments in an audited subset of the grammar:
  - `[export ]NAME=WORD` statements and comments;
  - words made of literal characters, single quotes, double quotes, ANSI-C
    quoting and plain parameter expansions;
  - no shell-special or host-dependent variable.
- **What never runs.** Commands, `$(`, backticks, `$((`, control operators,
  redirections and array assignments.
- **Unsafe is not wrong.** It means the file's meaning in Bash was not
  observed, and unobserved is never success. The classifier refused 94 hand
  fixtures: every bare key, every `KEY = value`, every hyphenated name.
- **Defense in depth.** A classified-safe fixture is sourced in a restricted
  shell with an empty `PATH` and a private directory. In the census,
  `A=$(touch ...)` in such a shell left no file. Downloaded files are never
  sourced (`run.py` refuses origin `realworld` for Bash).
- **What a file means in Bash.** `set -a; source fixture.env`, then every
  shell variable is printed NUL-delimited and diffed against an empty
  file's run. Values a process environment cannot carry are therefore
  visible:
  - Bash drops a NUL (`enc-nul-in-value`: `ab`);
  - it keeps a CR (`assign-crlf`: `1\r`);
  - it keeps invalid UTF-8 as bytes (`enc-invalid-ff`: `61 ff 62`).

  A successful exit is never taken to mean the intended value.

## 6. Shared fixture representation

A fixture is defined in Python (`fixtures/*.py`, pure data) and materialized
by `tools/corpus.py build` into one JSON line. The line holds:
- the stable id and the category;
- a description;
- the exact bytes (hex), their text if they are UTF-8, their SHA-256 and size;
- the author's intended assignments where a meaning is intended (133 of
  363 fixtures);
- the environment modes it runs in;
- the commands the trusted Ruby configuration may run;
- the static safety classification.

The generated corpus keeps every line's construction (indent, `export`, key,
delimiter, quote, value atoms, trailer, line end). A disagreement can thus be
attributed to a feature, not only to bytes.

An observation (`results/<corpus>/<target>.json`, one line per fixture) holds
the status (`ok`, `error`, `not-run` with its reasons, or `adapter-failure`),
the effective key-to-value map, the error's class and message, warnings,
events and secondary views. Its meta records the runtime and library versions,
options and the supplied environments. The harness's reproduction command for
one fixture is `python3 -I tools/run.py --corpus hand --only ID --targets A,B`.
A missing value (`null`, python-dotenv's `KEY` line) and the empty string are
distinct throughout.

## 7. Syntax acceptance matrix

One fixture per principal feature: the value of one key as each reference
read it (clean mode; the last two rows in the conflict mode). Excerpted from
`results/matrix.md`, which is generated and lists 38 rows. The full per-fixture
classes are in `results/hand-differential.md`.

Key to the cells:
- `err`: the file was rejected.
- `--`: the key was not assigned.
- `nr`: the safety classification forbade running the fixture.
- Values are shown as read: `\\` is one backslash, `\n` a newline.

| feature (fixture) | bash | node-builtin | node-envfile | npm dotenv | bun | python | ruby | dotenv.net | DotNetEnv | java |
|---|---|---|---|---|---|---|---|---|---|---|
| `KEY` bare (`assign-bare`) | nr | -- | -- | -- | -- | _no value_ | (empty) | -- | err | err |
| `KEY = value` | nr | `value` | `value` | `value` | `value` | `value` | `value` | ` value` | `value` | `value` |
| `export KEY=value` | `value` | `value` | `value` | `value` | `value` | `value` | `value` | key `export KEY` | `value` | err |
| `export<TAB>KEY=value` | `value` | key `export\tKEY` | key `export\tKEY` | `value` | `value` | `value` | `value` | key `export\tKEY` | `value` | err |
| `KEY: value` | nr | -- | -- | `value` | `value` | -- | `value` | -- | err | err |
| CRLF line ends | `1\r` | `1` | `1` | `1` | `1` | `1` | `1` | `1` | `1` | `1` |
| `MY-KEY=value` | nr | `value` | `value` | `value` | `value` | `value` | -- | `value` | `value` | `value` |
| `CLÉ=value` | nr | `value` | `value` | -- | -- | `value` | -- | `value` | `value` | err |
| `KEY=value#notcomment` | `value#notcomment` | `value` | `value` | `value` | `value` | `value#notcomment` | `value` | `value#notcomment` | `value#notcomment` | `value` |
| `KEY='value'` | `value` | `value` | `value` | `value` | `value` | `value` | `value` | `value` | `value` | `'value'` |
| ``KEY=`value` `` | nr | `value` | `value` | `value` | `value` | `` `value` `` | `` `value` `` | `` `value` `` | `` `value` `` | `` `value` `` |
| `KEY="abc"def` | `abcdef` | `abc` | `abc` | `"abc"def` | `abc` | -- | `"abc"def` | `abc` | err | -- |
| `KEY="abc` (unterminated) | -- | `"abc` | `"abc` | `"abc` | `"abc` | -- | `"abc` | err | err | -- |
| `KEY="a\"b"` | `a"b` | `a\\` | `a\\` | `a\\"b` | `a\\"b` | `a"b` | `a"b` | `a"b` | `a"b` | `a\\"b` |
| `KEY=value   ` | `value` | `value` | `value` | `value` | `value` | `value` | `value` | `value   ` | `value` | `value` |
| `KEY="a\nb"` | `a\\nb` | `a`&#x23CE;`b` | `a`&#x23CE;`b` | `a`&#x23CE;`b` | `a`&#x23CE;`b` | `a`&#x23CE;`b` | `a\\nb` | `a\\nb` | `a`&#x23CE;`b` | `a\\nb` |
| `KEY="a\\b"` | `a\\b` | `a\\\\b` | `a\\\\b` | `a\\\\b` | `a\\\\b` | `a\\b` | `a\\b` | `a\\b` | `a\\b` | `a\\\\b` |
| `KEY="a\$b"` | `a$b` | `a\\$b` | `a\\$b` | `a\\$b` | `a$b` | `a\\$b` | `a$b` | `a\\$b` | `a$b` | `a\\$b` |
| `KEY=${BASE}` | `one` | `${BASE}` | `${BASE}` | `${BASE}` | `one` | `one` | `one` | `${BASE}` | `one` | `${BASE}` |
| `KEY='${BASE}-x'` | `${BASE}-x` | `${BASE}-x` | `${BASE}-x` | `${BASE}-x` | `one-x` | `one-x` | `${BASE}-x` | `${BASE}-x` | `${BASE}-x` | `'${BASE}-x'` |
| `KEY=${U:-fallback}` | `fallback` | literal | literal | literal | `fallback` | `fallback` | `:-fallback}` | literal | `fallback` | literal |
| `KEY=${LATER}` then `LATER=two` | (empty) | literal | literal | literal | `two` | (empty) | (empty) | literal | (empty) | literal |
| newline in single quotes | `line1`&#x23CE;`line2` | same | same | same | same | same | same | same | same | err |
| UTF-8 BOM before the first key | nr | key `﻿KEY` | key `﻿KEY` | `value` | `value` | `value` | `value` | `value` | `value` | err |
| invalid UTF-8 byte | bytes `61ff62` | `a�b` | `a�b` | `a�b` | `a�b` | err | err | `a�b` | `a�b` | err |
| NUL in a value | `ab` | `a\x00b` | `a` | `a\x00b` | `a\x00b` | `a\x00b` | `a\x00b` | `a\x00b` | err | `a\x00b` |
| `KEY=$(echo hi)` | nr | literal | literal | literal | literal | literal | **runs it** | literal | literal | literal |
| existing variable assigned (conflict) | file | file | **environment** | file | **environment** | file | **environment** | file | file | file (`get`: environment) |
| `${CENSUS_REF}` from the environment | expanded | literal | literal | literal | expanded | expanded | expanded | literal | expanded | literal |

"literal" means the text as written. In a newline cell, &#x23CE; marks the
newline the target produced.

## 8. Key and assignment rules

Observed rules (`names`, `assignment` categories):

* **Accepted key characters.**
  - ASCII identifiers are accepted everywhere.
  - Lowercase keys and keys differing only by case are distinct everywhere on
    Linux (`name-case-pair`, `dup-case`).
  - Dots and hyphens:
    - Bash refuses both: they are commands to it, so not run.
    - Ruby ignores a hyphenated key (`name-hyphen`) but accepts a dotted one.
    - The others accept both.
  - A leading digit (`name-digit-lead`): accepted by every parser but
    DotNetEnv, which rejects the file; Bash reads it as a command.
  - Non-ASCII letters (`name-latin1-range`) split the targets three ways:
    - accepted by Node, python-dotenv, dotenv.net and DotNetEnv;
    - silently ignored by npm dotenv, Bun and Ruby;
    - the whole file rejected by Java.
  - Node 26 accepts a key of digits only (`name-digits-only`); Node 24's and
    22's `--env-file` ignore it (section 18).
* **The delimiter.** `=` is universal. Spaces around it are trimmed by every
  parser but dotenv.net, which keeps a space after `=` in the value
  (`assign-space-after-eq`: ` value`). The YAML-style `KEY: value` is
  accepted by npm dotenv, Bun and Ruby, ignored by Node's built-in parser,
  python-dotenv and dotenv.net, and a file error for DotNetEnv and Java.
* **`export`.**
  - Accepted by Bash, Node, npm dotenv, Bun, python-dotenv, Ruby and
    DotNetEnv.
  - dotenv.net keeps it as part of the key (`export KEY`) unless
    `WithSupportExportSyntax`.
  - Java rejects the file.
  - Node's built-in parser and dotenv.net read `export<TAB>KEY` as a key
    containing the tab (`assign-export-tab`).
  - A later bare `export KEY` re-assigns `KEY` to no value in python-dotenv
    (`assign-export-bare-after`).
* **A bare `KEY`.**
  - python-dotenv: present with no value.
  - Ruby: the empty string.
  - Node, Bun and dotenv.net: ignored.
  - DotNetEnv and Java: the whole file rejected.
  - Bash: a command.
* **Line ends.** Every parser normalizes CRLF; Bash keeps the CR in the value
  (`assign-crlf`). An old-Mac CR-only file (`assign-cr-only`) splits the
  readers further (`results/hand-differential.md`).

## 9. Comments, quotes and whitespace

* **Comments.**
  - A whole-line `#` comment and an inline comment after a space agree
    everywhere.
  - A `#` directly after the value (`comment-inline-nospace`):
    - starts a comment for Node, npm dotenv, Bun, Ruby and Java;
    - is data for Bash, python-dotenv, dotenv.net and DotNetEnv.
  - A value starting with `#` (`comment-value-starts-hash`) is `#value` for
    Bash, python-dotenv and dotenv.net and empty for the other seven.
* **Single quotes.** Stripped by every reader but Java, which keeps them
  (`quote-single`: `'value'`). dotenv-java's quote stripping handles double
  quotes only (source reading: `QuotedStringValidator.stripQuotes`).
* **Double quotes** are stripped by every reader. What follows a closing
  quote (`quote-text-after-double`) has five readings:
  - `abc`
  - `abcdef` (Bash)
  - `"abc"def` (npm dotenv, Ruby)
  - not assigned (Python, Java)
  - a file error (DotNetEnv)
* **Backticks** are quotes to Node, npm dotenv and Bun, and data to the
  others. Bash would run them, so the census did not.
* **Unterminated quotes** (`quote-unterminated-double`):
  - Node, npm dotenv, Bun and Ruby keep the opening quote in the value;
  - python-dotenv skips the line with a warning;
  - dotenv.net and DotNetEnv reject the file (dotenv.net even with its
    default `ignoreExceptions`);
  - Java silently drops the entry, with no error, even in its default throwing
    configuration;
  - in Bash, the source fails.
* **Whitespace.**
  - Leading and trailing spaces of unquoted values are trimmed by every
    parser but dotenv.net, which keeps trailing ones (`ws-trailing-unquoted`).
  - Inside quotes, spaces, tabs, no-break spaces, em spaces and ideographic
    spaces are kept by all ten (`ws-*-double`, the portable `edge-space`
    category).

## 10. Escaping and interpolation

* **Escapes in double quotes divide the readers into fixed groups:**

  | escape | read as the escape's character | kept with its backslash |
  |---|---|---|
  | `\n` | Node (both), npm dotenv, Bun, python-dotenv, DotNetEnv | Bash, Ruby 3, dotenv.net, Java |
  | `\\` | Bash, python-dotenv, Ruby, dotenv.net, DotNetEnv | Node (both), npm dotenv, Bun, Java |
  | `\$` | Bash, Bun, Ruby, DotNetEnv | Node (both), npm dotenv, python-dotenv, dotenv.net, Java |

  Every one of the 46 escape fixtures has two or more readings. An escaped
  quote truncates the value in Node's own parser (`quote-escaped-double`:
  `a\`).
* **Interpolation is a dialect property.**
  - Never: Node's built-in parser, npm dotenv (expansion is the separate
    `dotenv-expand` package and not this target), dotenv.net (unless
    `WithVariableExpansion`) and Java.
  - Always: Bash, Bun, python-dotenv, Ruby and DotNetEnv. Each does it
    differently:
    - **A reference to a later key** (`interp-later`) resolves to the later
      value in Bun only (`two`). Elsewhere it is empty.
    - **`${NAME:-default}`** works in Bash, Bun, python-dotenv and DotNetEnv.
      Ruby reads `${NAME` and leaves `:-fallback}` (`interp-default`).
    - **Single quotes** suppress expansion except in Bun and python-dotenv
      (`interp-single-quoted`: `one-x`).
    - **Self-reference** (`dup-interp`, `KEY=first` then `KEY=${KEY}-second`)
      has three readings: `first-second` (Bash, Python, Ruby, DotNetEnv),
      the literal text, and Bun's `${KEY}-second-second`.
  - Existing variables: section 12.
* **Configuration matters.** Turning python-dotenv's `interpolate` off
  changes 70 hand observations; dotenv.net's extended configuration changes
  118 (`results/configurations.md`).

## 11. Multiline and Unicode behavior

* **Multiline values.**
  - A literal newline inside double quotes is read identically by all ten
    (`ml-double`, `ml-double-then-next`, `ml-pem`).
  - Inside single quotes all agree but Java, which rejects the file
    (`ml-single`).
  - dotenv-java's line accumulation is the fragile part (minimized in section
    14). A multi-line value is lost or rejected when:
    - it starts with a newline;
    - it starts with `#`;
    - its first line holds a `#` followed by U+2028 or U+2029.
* **Encoding.**
  - *Decoding:* every implementation reads UTF-8.
  - *Invalid UTF-8:* rejected by python-dotenv, Ruby and Java; replaced by
    U+FFFD in Node, npm dotenv, Bun, dotenv.net and DotNetEnv; kept as bytes
    by Bash.
  - *A UTF-8 BOM:* stripped by most readers. Node's built-in parser keeps it
    in the first key (`﻿KEY`), and Java rejects the file.
  - *NUL (`enc-nul-in-value`), observed under three different mechanisms:*
    - `node --env-file` truncates the value at NUL (a C string);
    - Bash drops the NUL;
    - DotNetEnv rejects the file.
  - *Normalization:* canonically equivalent but different spellings (NFC
    `é`, NFD `e`+U+0301) stay distinct everywhere, as keys and as values.
    Nobody normalizes.
  - *C1 controls:* DotNetEnv rejects every one but U+0085, even quoted.
* **Byte or string?** Process environments carry bytes (Bash, the loaders'
  C-level reading), and every library returns strings. A file that is not
  UTF-8, or that holds NUL, therefore has no common reading.

## 12. Duplicate-key behavior

Within one file, the last assignment wins everywhere. That holds for two or
three values, for duplicates separated by other lines, for duplicates with
different quoting, and for an empty second value (`dup-*`, one class each).
Duplicates disagree only where the second line is something else:
- a bare key (`dup-second-bare`): `first`, no value, empty or error;
- `export` (dotenv.net makes `export KEY` another key);
- a reference to the first (`dup-interp`, section 10);
- a duplicate after a malformed line (DotNetEnv and Java reject the file).

Case variants are distinct keys on Linux and macOS. On Windows the process
environment is case-insensitive, so the loading targets merge them
(section 19.1):
- `node --env-file` ends with the uppercase spelling and its value, in
  both orders (`dup-case`: `KEY=upper` then `key=lower`; `name-case-pair`:
  the reverse);
- Bun keeps the first spelling with the last value;
- DotNetEnv's environment holds the last value under both names.

The parse APIs keep both keys on every host.

**Precedence over the process environment** is the other duplicate question.
In the conflict mode, `env-preset-assigned` assigns a variable the
environment already has. The readings split by what the API is for:
- **The environment wins:** the loaders (`node --env-file`, Bun), Ruby's
  `parse` (its `overwrite: false` default) and dotenv-java's `get`.
- **The file wins:** the parse APIs (Node's `util.parseEnv`, npm dotenv,
  python-dotenv, dotenv.net) and DotNetEnv's default (clobbering) load.

The same split shows for interpolation of an environment-only variable
(`env-ref-only`). No precedence across multiple files was tested.

## 13. Errors and malformed files

A file is handled in one of four ways:
- **Rejected whole.** Java by default: 70 of 363 hand fixtures, among them
  every `export` line. DotNetEnv: 86 fixtures, its Superpower parser
  stopping at any unexpected token.
- **Rejected only for specific damage.** dotenv.net for an unterminated quote
  (9); python-dotenv and Ruby for invalid UTF-8 (9 each); Ruby also for a
  bare `export KEY` of an undefined key.
- **Accepted, every unparseable line skipped.** Node, npm dotenv, Bun and
  python-dotenv; python-dotenv also logs a warning, which the adapter records.
- **Silently partial.** Java drops an unterminated quoted entry without an
  error; `java-lenient` (`ignoreIfMalformed`) turns 61 of Java's rejections
  into partial maps.

Bash reports syntax errors on standard error and carries on. Stress inputs (a
100,000-byte value, a 10,000-byte key, 10,000 lines, 5,000 nested quotes)
caused no crash or timeout in any reference. They are recorded by digest.

## 14. Portable emission profile

**The search.** `tools/portable.py` writes every value of 26 categories
(alphanumerics, punctuation, shell metacharacters, whitespace at the edges,
`#`, `=`, every quote, backslash, `$`, literal `${NAME}`, command-looking
text, newline, CR, Unicode, Unicode separators, U+FEFF, controls, JSON, long
values, NUL) in ten candidate encodings:
- unquoted, plain or with every non-alphanumeric backslash-escaped;
- single quotes, plain or with POSIX `'\''` concatenation;
- double quotes: plain, with POSIX escapes, with only `"` escaped, or with
  `\n`/`\r`/`\t`;
- ANSI-C `$'...'`;
- backticks.

That is 935 files. A candidate passes for a sample only when every one of the
ten references returns status ok and exactly `{PORTABLE_KEY: value}`. Bash
counts: a candidate it may not run is unverified, hence not portable. Results:
`results/portable.md` and `results/portable/encodings.json`.

**The result.** Plain double quotes are universal for:
- alphanumerics and punctuation, URLs, shell metacharacters;
- inner spaces and tabs, leading and trailing whitespace, the empty string;
- `#`, `=`, the single quote;
- non-ASCII Unicode, the Unicode spaces and separators (U+00A0, U+2003,
  U+2028, U+2029, U+0085), U+FEFF inside a value;
- long values.

No other encoding covers as much. Escaping (`\"`, `\\`, `\$`) helps nowhere,
because each escape is read literally by some reference. Layouts:
- LF with or without a final newline, a leading comment line and blank lines
  between assignments are universal;
- CRLF is not (Bash);
- an `export` prefix is not (dotenv.net, Java).

**The profile** (`tools/portable.py`: `rule_key_ok`, `rule_value_ok`, `emit`):

```
document   = *assignment
assignment = NAME "=" DQUOTE *VCHAR DQUOTE LF
NAME       = (ALPHA / "_") *(ALPHA / DIGIT / "_")   ; ASCII only
VCHAR      = any Unicode scalar value except " \ $ ` , %x00-08, %x0A-1F, %x7F-9F
```

**Requirements outside the grammar.**
- No key may be a variable Bash or a restricted shell treats specially (`IFS`,
  `PATH`, `HOME`, `BASH_ENV`, ...).
- No key may be a variable a runtime obeys at startup (`NODE_*`, `LD_*`,
  `JAVA_TOOL_OPTIONS`, `PATH`, `TZ`, ...).
- Keys must differ case-insensitively.

**The multi-line extension.** VCHAR also admits LF when the value does not
start with one and holds no `#`, U+2028 or U+2029. A continuation line must
not read as an assignment of a runtime-control variable.

**The checks.** Six seeded round trips draw random maps of 1 to 12 keys from
each profile's whole admissible domain: astral characters, noncharacters,
every ASCII punctuation, U+FEFF, and LF in the extension. Each emits them and
reads them back through all ten references (`results/portable.md`):
- single-line seeds 1 to 3: 900 files, 5,716 assignments, **0 differences**;
- multi-line seeds 101 to 103: 900 files, 5,834 assignments,
  **0 differences**.

The first draft of the domain included C1 controls and unrestricted LF. The
round trips refuted it, and minimization (section 17) reduced the failures to
single characters:
- U+0099 in a quoted value: DotNetEnv rejects the file.
- `#` then a newline: dotenv-java reports unmatched quotes.

**On other hosts** (CI, section 19.1).
- macOS reads every candidate and every round trip exactly as Linux does.
  - The one exception is outside the profile: `/bin/bash` 3.2 stops reading
    the file at its first NUL.
- Windows reads the single-line profile exactly as well.
- The multi-line extension fails on Windows for one reason, stated
  exactly: dotenv.net reads each LF of a multi-line value as CRLF. CI
  requires that deviation and no other.
- So an emitter for consumers that include dotenv.net on Windows writes
  single-line values only.

## 15. Values that cannot be emitted portably

| category | best encoding and what breaks it | consumers that cause the restriction |
|---|---|---|
| `"` | single quotes: all but Java (keeps `'...'`); double-quote escapes keep the backslash in Node, npm dotenv, Bun, Java | Java; Node, npm dotenv, Bun |
| `\` | unquoted: all but Bash and Ruby (which unescape) | Bash, Ruby (and Node/Bun/Java keep it where the others unescape) |
| `$` | only a trailing `$` survives unquoted; `$NAME` expands in Bash, Bun, Python, Ruby, DotNetEnv; single quotes protect it except in Bun and Java | the expanding dialects, Java |
| literal `${NAME}`, `$(cmd)` | single quotes: all but Bun, Python and Java (`${NAME}`), Java (`$(...)`) | Bun, Python, Java; Ruby runs `$(...)` unquoted |
| backtick | single quotes: all but Java; Bash treats a backtick in double quotes as a command (unverifiable) | Java, Bash |
| CR | no encoding: `\r` escapes are read literally by Bash, Node, Ruby, dotenv.net and Java; a raw CR is a line end; Git for Windows' Bash deletes every CR | almost all |
| NUL | no encoding: Bash 5 drops it, Bash 3.2 (macOS) stops reading at it, `--env-file` truncates at it, DotNetEnv rejects it | Bash, Node `--env-file`, DotNetEnv, every process environment |
| C0 controls but TAB/LF, DEL, C1 | DotNetEnv rejects them in every quoting | DotNetEnv |
| LF as the first character, or with `#`/LS/PS | dotenv-java's line accumulation | Java |
| LF on Windows | dotenv.net reads it as CRLF (`Environment.NewLine`) | dotenv.net |
| non-ASCII keys, dotted or hyphenated keys | Bash (not names), npm dotenv/Bun/Ruby (ignored), Java (rejects) | several |

A portable emitter must fail on these, never transform them. The failure
categories it needs (section 23):
- an unportable key: a character, a reserved name, or a case-collision;
- an unportable value character: index and scalar value;
- an unportable placement: a leading LF, or a LF together with `#`/LS/PS.

## 16. Dialect classification

Each reference is its own dialect; no two of the ten produce identical
results on the hand corpus. They differ along a few independent axes, which
explicit dialect modes would have to state:

| axis | values (who) |
|---|---|
| interpolation | none (Node both, npm dotenv, dotenv.net default, Java) / shell-like with defaults (Bash, Bun, python-dotenv, DotNetEnv) / `$NAME` and `${NAME}` only (Ruby; plus command substitution) |
| `\n` in double quotes | newline (Node, npm dotenv, Bun, Python, DotNetEnv) / literal (Bash, Ruby 3, dotenv.net, Java) |
| single quotes | stripped, literal (most) / stripped, expanding (Bun, Python) / kept (Java) |
| `export` | prefix (most) / part of the key (dotenv.net default) / error (Java) |
| bare `KEY` | ignored (Node, Bun, dotenv.net) / no value (Python) / empty (Ruby) / error (DotNetEnv, Java) |
| `#` right after a value | comment (Node, npm dotenv, Bun, Ruby, Java) / data (Bash, Python, dotenv.net, DotNetEnv) |
| errors | skip the line (Node, npm dotenv, Bun, Python) / reject the file (Java, DotNetEnv) / reject on specific damage (dotenv.net, Ruby) |
| existing environment | file wins (parse APIs) / environment wins (loaders, Ruby, Java's `get`) |

**Within an ecosystem.**
- Node's `util.parseEnv` and `--env-file` share a parser but differ in 17
  observations. NUL truncation and environment precedence are properties of
  loading.
- npm dotenv's fast parser equals its default on every hand fixture.

**Commonness.** The differences common enough to justify modes are the ones
real files trip over (section 17):
- interpolation (Laravel, FastAPI);
- single quotes (Java against eight others on Open WebUI);
- unquoted values with spaces (cookiecutter-django: DotNetEnv and Java reject
  the file);
- inline comments.

The census recommends five dialect modes for a reader: `node` (util.parseEnv
and dotenv share most rules), `python`, `ruby`, `java` and `dotnet`
(DotNetEnv). Each is a parameterization of one syntax-preserving parser,
validated against the oracles. `bash` is not a reader mode. It is the
portable profile's acceptance test.

## 17. Differential and generated-corpus results

* **Hand corpus.** 363 fixtures; 93 have one outcome on all ten references.
  The kinds below are counted per fixture, and a fixture can have several:

  | kind | fixtures |
  |---|---:|
  | error behavior | 113 |
  | interpolation | 51 |
  | escape handling | 45 |
  | syntax acceptance | 43 |
  | value decoding | 25 |
  | key recognition | 19 |
  | encoding | 16 |
  | quote handling | 12 |
  | existing-environment precedence | 11 |
  | multiline handling | 9 |
  | duplicate precedence | 3 |

  Per-category agreement (`results/hand-summary.json`):
  - escapes: 0 of 46;
  - interpolation: 2 of 44;
  - quotes: 7 of 32;
  - assignment: 12 of 37;
  - names: 12 of 37;
  - whitespace: 12 of 31.
* **Generated corpus** (`generated/`, seed 20261114, generator v1). The 600
  files are bounded combinations of indent, `export`, key spelling,
  delimiter, quote, value atoms, trailer and line end. 579 disagree,
  partitioning the targets in 204 distinct ways.
* **Minimization.** One representative of each of the 40 most frequent
  partitions was minimized: batched delta debugging over lines, then
  characters, preserving the disagreement's witness (the same key with the
  same presence pattern, or the same error/ok split). This gave 35 distinct
  minimal files (`generated/minimized.jsonl`), now part of the permanent
  corpus, which CI runs. Examples:
  - `KEY=$X`: Bun expands, Node keeps.
  - `export<TAB>_K=`: npm dotenv strips the prefix, Node's parser keeps it.
  - `my-key=""\``: Node and npm dotenv read different values.
  - `KEY: `: npm dotenv and Bun assign, Node's parser does not.
  - `KEY=#`: Node and Python differ.
  - `y='`: dotenv.net rejects, Node accepts.

  An adapter crash is never minimized as a disagreement (the witness requires
  two observed outcomes).
* **Real-world files** (`results/realworld.md`; 19 public examples, 2 to 226
  assignments, pinned by commit). Every reference agrees on every key in 10
  of 19 files; 2 more agree among the targets that ran (the loaders skipped
  them for a `NODE_` variable, as they skipped cal.com). The disagreements:
  - **Laravel:** `MAIL_FROM_NAME="${APP_NAME}"` (and `VITE_APP_NAME`)
    expands in Bun, Python, Ruby and DotNetEnv only.
  - **FastAPI's template:** `DATABASE_URL` expands in the same four.
  - **Open WebUI:** single-quoted values keep their quotes in Java (6 of 25
    keys).
  - **netbox-docker:** the same quotes in Java (2 of 33 keys).
  - **cal.com:** 10 of 165 keys differ in Java.
  - **PostHog:** escaped PEM newlines (`\n` inside double quotes) are kept
    by Ruby, dotenv.net and Java.
  - **cookiecutter-django:** a Jinja line is read as a key by Node and
    dotenv.net, and DotNetEnv and Java reject the file.

  The intended consumer is usually a dialect outside the reference set
  (Docker Compose, phpdotenv) or a combination (`@next/env` is dotenv plus
  dotenv-expand).

## 18. Cross-version observations

`results/cross-version.md`, hand corpus, older release against the pinned
baseline:

| older target | differing observations | what changed |
|---|---:|---|
| Node 24.22.3 / 22.23.5 `util.parseEnv` | 0 / 0 | -- |
| Node 24 / 22 `--env-file` | 2 / 2 | a digits-only key is ignored before Node 26 |
| npm dotenv 17.4.2 / 16.6.1 | 0 / 0 | the parse function is unchanged across the most deployed majors |
| Bun 1.3.14 | 68 | `$(...)` loses its `$` (`KEY=$(echo hi)` reads `(echo hi)`); escapes, expansion |
| python-dotenv 1.0.1 | 6 | BOM kept in the first key; `KEY= # comment` read as `# comment` |
| Ruby dotenv 2.8.1 | 35 | `\n` in double quotes expands (3.x keeps it literal); bare keys ignored; lone CR handling |
| dotenv.net 3.2.1 | 83 | an inline comment after a quoted value swallows the rest of the file |
| dotenv-java 2.3.2 | 75 | a duplicate key rejects the file; an indented comment line does not (3.2.0 rejects it); multiline differs |

**Version policy.**
- A compatibility claim names exact versions.
- The linter's dialect data is versioned per target, with the release ranges
  it was validated against.
- Bun, Ruby dotenv (2 to 3), dotenv.net (3 to 4) and dotenv-java (2 to 3)
  need per-major models.
- Node's built-in parser and npm dotenv (16 to 18) were stable on this
  corpus.
- CI re-runs the census on the pins and reports newer releases; a newer
  release is adopted by re-running the census and committing the baseline,
  never silently.

## 19. CI verification

`.github/workflows/dotenv-interoperability.yml` runs on every push that
touches the audit, and on demand:
- **The Linux baseline job** installs every pin and runs the self-test and
  the whole census into a fresh tree. It compares the tree with the
  committed results under the baseline policy: any difference in status, map
  or error class, any version that differs from its pin, any adapter failure
  or missing oracle fails. It then runs the emits probe and prints the pins
  against the registries.
- **The macOS (arm64) and Windows (x86-64) jobs** run the same census on
  their host's runtimes:
  - macOS: `/bin/bash` 3.2.57.
  - Windows: Git for Windows' `usr\bin\bash.exe`, Bash 5.3.15
    (`x86_64-pc-cygwin`).

  They compare under the portable policy. Host differences are reported.
  Two things fail: a portable category that stops being universal, and a
  portable round trip that reads back differently. The one exception is a
  host's declared deviation (`compare.py`'s `HOST_DEVIATIONS`), which must
  then appear.
- **The real-world job** fetches the pinned example files, parses them with
  the pure targets and compares with `results/realworld.json`.

Every job uploads its fresh tree and comparison.

The first runs' results are recorded in section 19.1.

### 19.1 Recorded runs

**Run 4** ([43577660873](https://github.com/mwagner-webdev/botlish/actions/runs/43577660873),
commit fbbe8cd1):

| job | runner | result | census step |
|---|---|---|---|
| census, baseline policy | ubuntu-24.04 | passed | 3 min 28 s |
| census, portable policy | macos-15 (arm64) | passed | 5 min 42 s |
| census, portable policy | windows-2025 (x86-64) | cancelled by the next push | - |
| real-world files | ubuntu-24.04 | passed | 2 s |

- **Linux.**
  - The fresh tree equals `results/` exactly: every status, map and error
    class, in every corpus and mode.
  - Every pin is as recorded.
  - The emits probe certified the four claims, rejected the fold claim and
    rejected all ten mutants.
- **Real-world files.** Every reading equals `results/realworld.json`.

**macOS** (Bash 3.2.57; every other target at its pin):
- **The profile holds.** The classification of all 26 categories equals
  Linux's. All six round trips (11,550 assignments) read back exactly on
  every reference.
- **Every other observation equals the baseline,** in all four corpora and
  both modes, except Bash's reading of NUL. Bash 3.2 stops reading the file
  at its first NUL byte:
  - `enc-nul-in-value` (`KEY=a<NUL>b`) is `a`;
  - `enc-nul-in-double` assigns nothing (the quote never closes);
  - `enc-nul-in-comment` (a comment holding a NUL, then `KEY=value`) assigns
    nothing;
  - the nine `pe-*-nul-0` encodings behave the same way.

  Bash 5.2 drops the byte instead (`ab`). NUL was already outside the
  profile, so nothing about the profile changes.
- **An added variable.** macOS adds `__CF_USER_TEXT_ENCODING` to every
  process. The loading targets now subtract a control run on an empty file,
  and record what the host added (`host_added_variables` in each result's
  meta).

**Windows** (Git for Windows' Bash 5.3.15; every other target at its pin).
These are the partial trees of the cancelled jobs of runs 3 and 4: every
corpus and four of the six round trips. Run 6 (commit 266f8bec) is the
first complete Windows run, and this entry records it once it ends.
- **Single-line round trips** (seeds 1 to 3): every reference but Bash read
  every file back exactly. Bash differed only by `BASH_MONOSECONDS`, which
  the harness now ignores.
- **Multi-line extension.** dotenv.net reads every LF of a multi-line value
  as CRLF. That is 40 hand observations in each of its three
  configurations, 30 portable ones and 259 of 300 files of round-trip seed
  101, and every one is exactly that reading. This is `compare.py`'s one
  declared deviation for Windows.
- **Bash deletes CR.** Git for Windows' Bash deletes every CR byte of the
  sourced file, quoted or not:
  - `assign-crlf` reads `1` and `2` (Linux Bash: `1\r`, `2\r`);
  - `assign-cr-only` (`A=1\rB=2\r`) reads `A` as `1B=2`;
  - a CR inside double quotes disappears (`enc-lone-cr-in-double`: `ab`).

  CR was already outside the profile.
- **Case.** The environment is case-insensitive: four observations each
  for `node --env-file`, Bun and DotNetEnv (section 12).
- **Ruby.** `ruby`'s `name-shell-special-home` and `-path` read the clean
  environment itself. On Windows that environment needs a real `HOME` and
  `PATH`, and it is recorded with the results.
- **ruby-trusted.** The audited commands run through the host's command
  interpreter, which on Windows is `cmd.exe`:
  - `cmd-nested`'s `echo $(echo inner)` prints its argument literally;
  - `cmd-arithmetic` records no executed command and assigns nothing. The
    cause was not determined; it is a configuration target, not a
    reference.
- **Two harness defects** came out of these trees and are fixed:
  - Bash 5.3's clock variable was counted as an assignment.
  - A `declare -p` process per variable made the 10,000-assignment fixture
    time out.

  Neither fix changed a Linux observation.

**Earlier runs**, each superseded by the fix it exposed:
- run 1: the macOS job on macos-14 was cancelled before it started.
- run 2: the real-world report wrote into a results root that did not
  exist.
- run 3: on macOS, `__CF_USER_TEXT_ENCODING` turned into an assignment of
  every loading-target observation, and the round-trip step stopped the
  census.
- run 5: cancelled by the next push.

## 20. Existing linter landscape

Checked on 2026-11-14 against the projects' current sources and registries:

| tool | state | formatting/style | duplicates | template comparison | schema | semantic parsing | cross-runtime compatibility |
|---|---|---|---|---|---|---|---|
| dotenv-linter/dotenv-linter (Rust) | maintained; v4.0.0 2025-10-18 | yes (14 checks: delimiter, quotes, spaces, ordering, trailing whitespace, substitution key, ...) | yes | `diff` of files | yes (v4 `SchemaViolation`) | its own reading | no |
| wemake-services/dotenv-linter (Python) | maintained; 0.9.0 2026-07-31 | yes (spacing, quotes, EOL, comments in values) | yes | no | no | its own FST parser | no |
| dotenv-safe (npm) | 9.1.0, 2024-02 | no | no | `.env.example` keys present in the environment | no | npm dotenv | no |
| dotenv-checker (npm) | 1.1.7, 2024-08 | no | no | sync with a schema file, can rewrite | key list | npm dotenv | no |
| dotenv-diff (npm) | 3.5.2, 2026-11-08 | no | yes | `.env` against `.env.example`, code scan for usage | annotations | its own | no |
| env-sentinel (npm) | 1.4.0, 2025-10 | lint | yes | schema-based | yes | its own | no |
| `@dotenvx/dotenvx` | 2.38.2, 2026-10 | no | no | no | no | its own (expansion, command substitution) | by replacement: one runner injects one parser's result into any language's process |

None checks whether a file means the same to the consumers a repository
actually has. dotenvx removes the question by replacing every consumer's
parser with its own, which a mixed-language monorepo whose services load
their own `.env` files cannot always do. **Semantic agreement across an
explicitly selected set of runtime consumers is absent from current tooling.**
Style, duplicates, template comparison and schemas are well served; a new
linter should not re-implement them as differentiation.

## 21. Requirements for a future compatibility linter

**Scope.**
- Compatibility diagnostics for a configured target set: the targets and
  their versions are explicit, in a project file.
- Duplicate keys, including the ones only some targets collapse.
- Comparison with `.env.example`: missing and extra keys, compared by each
  target's key recognition, not by a regex.
- Syntax that one target accepts and another does not.
- Values that targets read differently.
- A portable rewrite when one exists (the profile of section 14), and an
  explanation when none does (section 15).

**Out of scope.** No schema language, no application-code analysis, no
secret detection, no environment mutation, no process management.

**Diagnostics** distinguish syntax disagreement (a target skips, rejects or
misparses the line) from semantic disagreement (all accept, the values
differ). The census suggests these codes:

| code | trigger | evidence |
|---|---|---|
| `DOTENV-COMPAT-EXPANSION` | `$NAME`/`${NAME}` read literally by some targets, expanded by others | `interp-braced`, Laravel |
| `DOTENV-COMPAT-ESCAPE` | a backslash escape read differently | `esc-*`, PostHog |
| `DOTENV-COMPAT-QUOTE` | single quotes or backticks kept by some targets | `quote-single` (Java), Open WebUI |
| `DOTENV-COMPAT-EXPORT` | `export` rejected or made part of the key | `assign-export` |
| `DOTENV-COMPAT-KEY` | a key some targets ignore or reject | `name-hyphen`, `name-latin1-range` |
| `DOTENV-COMPAT-COMMENT` | a `#` that is a comment to some targets, data to others | `comment-inline-nospace` |
| `DOTENV-COMPAT-REJECTED` | a target rejects the whole file | cookiecutter-django (DotNetEnv, Java) |
| `DOTENV-COMPAT-COMMAND` | `$(...)` some target would execute | `cmd-*` (Ruby) |
| `DOTENV-COMPAT-ENCODING` | not UTF-8, BOM, NUL, CR | `enc-*` |
| `DOTENV-COMPAT-DUPLICATE` | a duplicate whose winner depends on the target | `dup-second-bare` |

**Example.** A diagnostic as the census's data would produce it for
`interp-braced`:

```
.env:2 DOTENV-COMPAT-EXPANSION KEY
  node-dotenv 18, node 26 util.parseEnv, dotenv-java 3.2: literal text (7 characters)
  bun 1.4, python-dotenv 1.2, ruby dotenv 3.2, DotNetEnv 3.2: expanded from BASE
  no portable rewrite: "$" has no encoding every target reads literally
```

**Secrets.** Print keys and positions and explain the syntax. Never print a
value by default; when values must be compared, show their length and a
digest, as `results/realworld.md` does. Never log the environment, and never
store values in reports. Value-revealing output needs an explicit flag.

## 22. Recommended Botlish reader representation

A map-returning parser cannot serve the linter. It loses duplicates, quote
styles, `export`, raw text and positions, and every disagreement above lives
in one of those. The census recommends two layers, both pure.

1. **A syntax-preserving document** read from bytes:
   - **Lines and line ends, with spans.**
   - **Entries.** Each entry holds:
     - an optional `export`;
     - the key's spelling and span;
     - the delimiter (`=`, `:`, spaces);
     - the value's raw text and span;
     - its quote style (none, single, double, backtick, unterminated);
     - its segments: literal text, escape, `$NAME`, `${NAME...}` with its
       operator, `$(...)` kept as syntax and never evaluated;
     - a trailing comment.
   - **Other lines:** comments, blank lines, and malformed lines with a
     diagnostic.
   - **Decoding diagnostics** for invalid UTF-8, a BOM and NUL. The reader
     works on bytes and decodes UTF-8 strictly, because the targets disagree
     on everything else.
2. **A semantic projection per dialect.** It maps the document to an ordered
   assignment map: missing values distinct from empty ones, duplicates
   resolved by the dialect's rule, interpolation resolved symbolically
   against an explicitly supplied environment map (never the process's).
   The projection reports which lines the dialect skipped or rejected.

The default projection is the **portable profile, strict**: anything outside
it is a diagnostic, not a guess. The dialect projections (`node`, `python`,
`ruby`, `java`, `dotnet`) are explicit options. Each is validated against its
oracle on the census corpus before it ships. A dialect's projection of a file
the dialect rejects is an error with the dialect's reason, not a map.

## 23. Recommended emitter grammar and API

**Grammar:** section 14.

**API.**
- `emit_portable(pairs) errors UnportableKey, UnportableValue,
  DuplicateKey`. It writes `NAME="VALUE"\n` lines, keys checked against the
  reserved sets and for case-insensitive uniqueness.
- An optional `multiline` flag selects the extension.
- Dialect emitters are possible but not needed for portability: every
  portable file is already read identically.

**Failure values.**
- `UnportableKey {at, reason}`: a character, a reserved name, or a case
  collision.
- `UnportableValue {key, at, value}`: the scalar value that has no encoding.

Never a replacement, an escape the census showed unread, a truncation at
NUL, or a missing value written as empty.

**Streaming.** The emitter yields one assignment at a time. A missing value
cannot be written portably at all, since five readings exist for a bare key,
so it is an error.

## 24. Interaction with `emits` and coroutine streaming

`emits/` holds the evidence:
- `dotenv_portable.bot`: the profiles as declared recognizers over Unicode
  scalar values.
- `dotenv_emit.bot`: emitters claiming them.
- `dotenv_emit_fold.bot`: the variant the checker rejects.
- `mutants.txt`: ten negative controls.

`tools/emits.py` runs them through the compiler's own certification
(`results/emits.json`):

| claim | verdict |
|---|---|
| `assignment` emits `assignment` and `assignment_ml` | proven |
| `document` emits `document` | proven |
| `assignment_lines` (multi-line, state follows the code) emits `assignment_ml` | proven |
| `assignment_ml` (multi-line, mode carried by a fold) emits `assignment_ml` | **rejected** (EMIT-REJECTED) |

All ten mutants are killed by the checker's verdict, never by a compile
error:
- an unguarded value character;
- a missing terminator or closing quote;
- a yielded `$`;
- an empty key written;
- a digit first in a key;
- a first line allowed to be empty;
- `#` allowed after a LF;
- a LF claimed under the single-line grammar;
- a LF yielded first.

**What the probe shows about the checker's precision.**
- The fold version is correct code that the checker cannot certify. It
  carries the value's mode (nothing yet, plain, marked, after a LF) in a
  fold's intermediate, and the recognizer state at a yield depends on that
  value. The checker tracks interval facts of values and the recognizer's
  states, but no relation between them.
- Writing the value as its lines, a one-line value through the single-line
  guard and a multi-line one with its first line peeled off the loop, makes
  the state follow the code's shape. That is certified.
- A helper called on the first line was not enough. Its zero-iteration exit
  stays possible, because the walk enters it without the caller's
  `first.length() > 0`. The loop had to be inline.
- The first attempt also showed that Botlish has no mutable binding. A
  `mode = 3` inside a branch is a new binding, and the original "mode"
  emitter silently refused every LF. The checker certified it correctly: it
  never yields a LF.

**Three guarantees, distinguished.**
- **A, grammar validity.** Every output is in the profile's language. This
  is what the certificate proves, from the declaration alone.
- **B, round-trip validity.** The Botlish reader reconstructs the
  assignments. This needs the reader and tests, not a recognizer.
- **C, external semantic validity.** Every target reconstructs them. This is
  the census's runtime evidence (section 14), for the pinned versions only.

A regular recognizer cannot prove what `\n` or `$` means to Bun.

**Streaming.**
- The emitters are ordinary functions yielding scalar values: they stream by
  construction (the CSV milestone's pattern). A UTF-8 byte emitter is the
  same construction over bytes (`csv_utf8.bot` has one), and its result value
  is independent of what it yields.
- The reader can consume a coroutine source line by line. The one piece of
  state crossing lines is an open quote. The dialects' multi-line rules,
  python-dotenv's lookahead for a closing quote included, need bounded
  lookahead or a buffered value. What the typed coroutine-source census
  decides about typed sources is all the reader needs; nothing here needs a
  new language feature.

## 25. Proposed implementation milestones

**EMISSION-DOTENV-READER-AND-EMITTER-MILESTONE-1.** A pure Botlish package.
Acceptance:
- **The portable emitter** with its `emits` certificate, its failure
  values, and the seeded round trips, run in CI against the pinned oracles:
  - the single-line profile with zero differences on Linux, macOS and
    Windows;
  - the multi-line extension with zero differences on Linux and macOS, and
    on Windows with exactly dotenv.net's CRLF reading, no other difference.
- **The syntax-preserving reader.** It reads every fixture without a crash.
  Its strict portable projection accepts exactly the portable corpus and
  diagnoses the rest.
- **Dialect projections** `node` and `python` first, as the largest
  ecosystems. Each must equal its oracle on every applicable hand, generated
  and minimized fixture. Any exception is listed with its reason, and none
  may be a value difference.
- **Purity.** No environment access, no command execution, no process state.
- **Agreement.** The interpreter and the native backends agree.

**EMISSION-DOTENV-COMPAT-LINTER-MILESTONE-1.** An independent Botlish CLI on
that library. Acceptance:
- **Diagnostics** of section 21 for a configured target set, with correct
  source positions.
- **Duplicates and template comparison.** Duplicate detection, and
  `.env.example` comparison by each target's key recognition.
- **Output.** Machine-readable diagnostics; safe default output that prints
  no value; CI exit statuses.
- **Self-contained.** No external runtime in ordinary use. The dialect models
  are data generated from the census and checked against the oracles in the
  linter's own CI.
- **Validation suite.** The census corpus, plus the real-world files as a
  regression suite.

**EMISSION-DOTENV-STDLIB-INTEGRATION-MILESTONE-1.** The proven reader and
emitter move into the standard library (`std::dotenv`), without the
linter's dialect data. No environment management in this sequence.

**Workloads for those milestones**, from the real-world census and the
stress fixtures:
- small: about 1 KB, 10 to 40 assignments (Laravel, FastAPI);
- medium: 12 to 18 KB, 70 to 230 assignments, heavily commented (Supabase,
  cal.com, Appwrite, Outline);
- large generated: 10,000 assignments, about 110 KB (`bad-many-lines`);
- one 100 KB value;
- PEM-style multi-line values (`ml-pem`).

The census's batch adapters read the 363 hand fixtures in under a second
each. Process-per-fixture targets are slower: DotNetEnv takes about 12 s for
both modes. Correctness, not speed, governed the harness.

## 26. Remaining uncertainties

* **Hosts.** macOS and Windows are CI's runners (section 19.1), one image
  each.
  - The Windows Bash is Git for Windows', not a distribution's.
  - Each reading recorded there is a fact of those versions on those
    images.
* **Consumers outside the reference set**: Docker Compose, PHP phpdotenv,
  Go, Rust and dotenvx. Several real-world files are written for them.
* **dotenv-expand and `@next/env`.** The expansion layer most Node
  applications actually use (Next.js, NestJS) is not a target. npm dotenv
  alone does not expand.
* **Windows Bash** (Git for Windows) runs on an emulation layer. The census
  did not audit its restricted mode and its program lookup separately. The
  static classifier remains the safety boundary there.
* **Coverage is finite.** The generated corpus samples combinations; it does
  not enumerate them. Real-world coverage is 19 files.
* **Versions.** The census holds for the pinned versions; section 18 shows
  how much a major release can change.

## Final evaluation questions

1. **Is there a useful common dotenv subset?** Yes:
   - **Shape:** `NAME="VALUE"` with LF line ends.
   - **Keys:** ASCII identifiers that are not reserved by a shell or a
     runtime and that differ case-insensitively.
   - **Values:** any Unicode scalar value but `"`, `\`, `$`, backtick, the C0
     controls other than TAB, DEL and the C1 controls.
   - **Multi-line extension:** LF, subject to the restrictions of section 14.

   The evidence is every candidate and 1,800 random files on all ten
   references, Bash included, with zero differences on Linux and macOS.
   On Windows the single-line profile has zero differences too. The
   multi-line extension does not hold there: dotenv.net reads its LFs as
   CRLF.
2. **What cannot be represented universally?** The double quote (Java,
   Node/npm dotenv/Bun), the backslash (Bash, Ruby against Node/Bun/Java),
   `$` and literal templates (the expanding dialects and Java), the backtick
   (Java, Bash), CR (nearly all), NUL (Bash, Node `--env-file`, DotNetEnv,
   every process environment), controls (DotNetEnv), a leading LF (Java),
   and non-identifier keys.
3. **How incompatible are the readers?** Only 93 of 363 targeted fixtures
   agree across all ten; 579 of 600 combinations disagree. Interpolation,
   escapes, quotes, `export`, bare keys, comment placement and the error
   policy are common enough, and visible in real files, to justify explicit
   modes.
4. **What should Botlish's default reader do?** Parse a broad syntax into a
   syntax-preserving document. Its default projection is the strict portable
   profile, with compatibility diagnostics for everything outside it. It
   does not target one existing dialect: no dialect is a superset of the
   others, and choosing one would silently misread files written for the
   rest. Dialect projections are explicit.
5. **Can the emitter carry a useful `emits` claim?** Yes, for the single-line
   profile and for the multi-line extension written so that the state
   follows the code. What is proven is grammar validity: key spelling,
   delimiter, quoting, the excluded characters, the extension's ordering
   rules, line termination, any number of assignments. Reserved names and
   case-insensitive uniqueness are not regular per line and need a runtime
   check. The meaning to each consumer is semantic evidence, re-run in CI.
6. **What would a compatibility linter find that conventional linters miss?**
   Files every style linter accepts but consumers read differently:
   - `MAIL_FROM_NAME="${APP_NAME}"`: four consumers expand it, five keep the
     text (Laravel).
   - `KEY='value'`: Java keeps the quotes (Open WebUI).
   - `KEY="a\nb"`: four keep the backslash.
   - `KEY=value#x`: a comment to five, data to four.
   - `export KEY=value`: Java rejects the file; dotenv.net names the key
     `export KEY`.
   - `KEY=$(cmd)`: Ruby executes it.
   - `KEY=${LATER}` before `LATER=two`: only Bun resolves it.
   - `KEY` alone: five different readings.
7. **Can the linter work without external runtimes?** Yes. The dialect
   models (the axes of section 16, parameterizing one syntax-preserving
   parser) are data, generated and validated against the pinned oracles in
   the linter's development CI on this census's corpus. The released binary
   carries the models and the version ranges they were validated for. A
   model outside its range is reported as unvalidated, never assumed.
8. **Is a pure standard-library reader/emitter justified?** Yes, for the
   portable profile: the emitter with its certificate and failure values,
   and the syntax-preserving reader with the strict portable projection.
   That is a small, stable contract with no dialect data. The dialect models,
   the compatibility diagnostics and the version tables change with external
   releases. They belong in the separately versioned compatibility package.
9. **What is the smallest credible next milestone?** The portable emitter
   (certified, round-tripped against the pinned oracles on three hosts) and
   the syntax-preserving reader with the strict portable projection and one
   dialect projection (`node`), each validated fixture-by-fixture against its
   oracle. That is section 25's first milestone, reduced to one dialect.
