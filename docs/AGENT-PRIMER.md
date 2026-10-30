# The primer: teaching habits before the first program

A documentation and discoverability change to Compilerpedia. It adds two
topics (`task.first-program`, the primer, and `task.accumulate`) and one rule
topic (`rule.else-if`), puts the primer's table at the top of the `-help`
overview and a pointer to it in the usage summary, adds diagnostic matchers
and aliases so that the habits it lists reach their pages, and extends five
pages. It changes no language semantics, diagnostic, warning, proof rule,
standard-library API or backend. COMPILERPEDIA.md is the architecture and
maintenance guide; IDIOMATIC-BOTLISH.md is the newcomer page this primer
precedes. Section 8 lists the follow-ups this work points at.

## 1. Why

Clean-room experiments -- agents given only the single-file Linux
executable, its Compilerpedia included, and asked to build programs --
showed three pitfalls in nearly every run:

1. METHOD-ELIGIBLE warnings on the agent's own helpers, each costing an
   extra edit-and-compile turn;
2. `if` and loop *expression* syntax (an inline conditional, a one-line
   block, `else if`, `for`/`while`);
3. the interaction of shadowing, block scope and immutability (a running
   total "updated" in a loop body, a result bound in each `if` branch).

Compilerpedia already documented all three (`rule.immutable-bindings` even
calls the loop total "a common surprise"). The earlier newcomer audit
(IDIOMATIC-BOTLISH.md, section 7) measured an agent *answering questions*
through `-help`; these experiments measured agents *writing programs*, and
there the documentation is reached only when the agent knows it does not
know. Botlish looks enough like Python that an agent writes these habits
with confidence and never looks them up, so the only feedback is the
diagnostic -- and for these habits the diagnostics were generic, pointed at
the wrong page, or did not exist.

## 2. What an agent hit before

Each row is a program an agent arriving from Python or JavaScript writes,
compiled before this change:

| Writes | Reported | `help:` line named |
|---|---|---|
| `s = if n < 0: -1 else: 1` | expected a new line and an indented block after ":" | `rule.indentation` (no word about a one-line `if` value) |
| `x = 1 if c else 2` | expected end of line, found "if" | `error.surface-syntax` |
| `else if` | expected ":" after "else", found "if" | `error.surface-syntax` |
| `for x in xs:`, `while c:` | expected end of line, found name "x" | `error.surface-syntax` |
| `count += 1` | expected an expression, found "=" | `error.surface-syntax` |
| `count = count + 1` | DUPLICATE | `error.duplicate` (not the rule page with the alternatives) |
| `r` bound in each `if` branch, used after | UNBOUND "r" | `error.unbound`, which did not list block scope as a cause |
| `total = total + x` in a loop body | **nothing: the program runs, value 0** | -- |
| `total(xs, 0)` for its own helper | METHOD-ELIGIBLE (no rewritten spelling) | `warning.method-eligible` |

And the reading side:

* The newcomer page (`principle.idiomatic-botlish`) did not mention the
  shadowing trap, and its item on control placement had no example.
* `-help for` found nothing (`for` is a stop word of the word search);
  `-help while` listed `error.coroutine-running` first; `+=`, `running
  total`, `getting started`, `primer` and `cheat sheet` found nothing.
* Nothing pointed at any of it before the first program: the overview's
  newcomer pointer was one line between the description and the indices,
  and the usage summary (what a bare invocation prints) named none.

## 3. What changed

### The primer, `task.first-program`

`compilerpedia/topics/tasks.topic`; aliases `primer`, `getting started`,
`quick start`, `cheat sheet`, `first program`, `before you start`, `common
mistakes`, `pitfalls`, `gotchas`.

* **AT A GLANCE** -- a twelve-row table, "you might write" against the
  Botlish form: `for`, `for ... range`, `while`, the inline conditional and
  `?:`, the one-line block, `else if`, `x = x + 1`/`+=`, the loop running
  total, a name bound in each branch, a functional call of one's own
  helper, a one-character String.
* **THE ONE THAT COMPILES** -- the running total as an accepted example
  whose stated value is 0, so the catalogue's check pins the surprise, then
  the accumulator passed on.
* **A PROGRAM IN THE HOUSE STYLE** -- one complete program (an `if` chain
  with `elif`, a recursive accumulator called with method syntax, a
  `nomethod` function, a collecting loop, a bound `if` value), stated to
  compile with no warning (`@quiet`). Its first draft drew four
  ONE-CHAR-STRING-LITERAL warnings for one-letter grades, which is why the
  table has a row for `"x"`: a compiler-checked example is the only kind
  that cannot teach a warning.
* **WHEN THE COMPILER OBJECTS** -- read the `help:` line first; fix a
  warning's calls in one pass and decide at the declaration; `-check` to
  report without running.

It is a separate topic from `principle.idiomatic-botlish`, not more items
on it: that page is deliberately a short map (`cp-idiomatic-shape`: 8 to 12
items, under 800 words, one example), and the primer's job is different --
concrete wrong-to-right pairs and checked programs, read once before
writing.

### Shown before anything is looked up

* The `-help` overview (also what `--help` and `-h` print) opens with
  BEFORE YOU WRITE A PROGRAM: the primer's AT A GLANCE section, rendered
  by `compilerpedia::PrimerGlance` from the topic exactly as its page
  renders it -- a view, never a second copy of the table -- and the line
  `The whole page, with a checked program: botlish -help primer`. The
  newcomer line and the indices follow unchanged. The overview grew from
  36 to 57 lines.
* The usage summary says `Before writing a program, read: botlish -help
  primer` right after its description, before the options.

### Help lines that name the habit's page

New matchers, each exercised by a rejected example of its topic (the
catalogue check requires it):

| Message | Now names |
|---|---|
| `expected end of line, found "if"` (Python's `a if c else b`) | `rule.if-placement` |
| `expected ":" after "else", found "if"` | `rule.else-if` (new) |
| `expected an expression, found "="` (`+=`, `-=`) | `rule.immutable-bindings` |
| `duplicate binding "NAME" in the same lexical scope` | `rule.immutable-bindings` |

`error.duplicate` stays the code's page and lists the binding rule under
SPECIFIC RULES; its rejected example became the duplicate-error case (the
check requires a code page's rejected examples to name the code page).
`rule.else-if` is a topic of its own rather than a matcher on
`concept.if-expressions` for the same reason: that concept's existing
rejected `1 + if` example would have had to name it.

Two messages cannot be told apart by text, so their pages changed instead:
`rule.indentation` now says that "expected a new line and an indented block
after ':'" is most often a one-line `if` or loop written as a value (with
a rejected example), and `error.unbound` lists "bound inside an `if` branch,
a loop body or a handler, used after it" as a likely cause, with the
rejected program and the bound-`if` fix. `rule.names` names C's `?:` as the
commonest stray `?`. `rule.immutable-bindings`, `concept.loops` and
`concept.if-expressions` link the new pages and state the silent case.

### Search

* Exact aliases, looked up before the word search (so a stop word does not
  matter): `for`, `while`, `for x in xs`, `for i in range`, `while true`
  (`concept.loops`); `else if`, `elseif`, `elsif` (`rule.else-if`); `+=`,
  `x += 1`, `-=`, `compound assignment` (`capability.assignment`).
* `task.accumulate` -- running totals: the trap, then the accumulator
  passed on (a maximum), a count by a collecting loop and its length, and a
  total kept in a one-element MutableArray; aliases `running total`,
  `accumulator`, `sum a list`, `count matches`, ...
* As IDIOMATIC-BOTLISH.md decided for the newcomer page, the primer's
  summary names no other language: `-help python`, `javascript` and `rust`
  find what they found before. The generic keywords `first` and `start`
  were dropped after they put the primer into broad word-search lists.

### After

The same programs as section 2:

| Writes | `help:` line now names |
|---|---|
| `s = if n < 0: -1 else: 1` | `rule.indentation`, which now leads with this case |
| `x = 1 if c else 2` | `rule.if-placement` |
| `else if` | `rule.else-if` |
| `count += 1` | `rule.immutable-bindings` |
| `count = count + 1` | `rule.immutable-bindings` |
| `r` bound in each branch | `error.unbound`, which now names the cause |
| `c ? 1 : 2` | `rule.names`, which now names the `?:` habit |
| `for x in xs:`, `while c:` | `error.surface-syntax` (unchanged: section 8.2) |
| `total = total + x` in a loop | still nothing (section 8.1); the overview's table names it first |

## 4. Tests

* `tests/compilerpedia.test`: `cp-primer-queries` (the primer's aliases
  find it; `for`, `while`, `else if`, `+=`, `x += 1`, `running total`, `sum
  a list` find their pages), `cp-primer-overview` (the overview's block is
  the primer's section as its page shows it, before the indices, ending in
  `-help primer`), `cp-diagnostic-habits` (each habit program is compiled
  and its first diagnostic's help line is the page the table promises; a
  duplicate error keeps `error.duplicate`).
* `tests/main-cli.test`: `cli-help-overview-primer` (the order of the
  overview's blocks, the usage line before the options, `-help primer`).
* Census rows for the four tests (`audit/golden/migration/census/`), the
  names file and the regenerated manifest (four new rows, `merge.tcl -check
  1` clean).

Run: `tools/compilerpedia.tcl check` (1083 topics, 666 examples, 0
problems), `tests/compilerpedia.test` (42 of 42), `tests/main-cli.test` (64
of 64), the Compilerpedia tests of `tests/compiler-service.test` and
`tests/lsp.test`. The native backend was not built in the container, so the
examples ran on interp and compile (none of the new ones names a native
backend); `tests/golden-duplicates.test`'s `gd-skips-only-duplicates` fails
there with and without this change, because the enums test it runs expects
all four backends.

## 5. Not changed

No diagnostic message, code or order; no warning; no parser, resolver or
backend file. `main.tcl` gained one usage line and `compilerpedia.tcl` one
procedure. The help-line lookup still reads only the topics' header lines.
`principle.idiomatic-botlish` is unchanged and still the answer to `best
practices`.

## 6. How to measure it

The change is a hypothesis about agent behaviour, so it should be measured
the way the problem was found: the same clean-room tasks, the packed
executable built from this revision against one built from the revision
before, several runs each, counting per run

* compile iterations caused by each of the three pitfalls (and by
  ONE-CHAR-STRING-LITERAL),
* whether the agent ran `-help` (or `--help`) before its first program, and
  whether it opened `-help primer`,
* programs that finished with a silently wrong value from the loop or
  branch trap -- the outcome a help line can never catch.

If agents still skip the overview, the lever is the delivery (section
8.3); if they read it and still slip, the content.

## 7. Maintaining it

COMPILERPEDIA.md, section 9, "The primer": a row is a habit seen in
practice, not a rule summary; keep the table within 76 columns and short
enough for the overview; give a habit whose message can be told apart a
matcher (and a `cp-diagnostic-habits` case). A new pitfall from a future
experiment goes into the table, and into the measurement above.

## 8. Follow-ups

Ordered by how many agent turns each would save, as far as the experiments
show. The first three need compiler changes, made for the user's sake on
their own merits: COMPILERPEDIA.md forbids changing a diagnostic for
Compilerpedia's sake, and each goes through the process AGENTS.md sets for
its area.

### 8.1 A diagnostic for the silent trap

The running total and the branch "update" compile and give a wrong value,
so no help line and no page reached after the fact can catch them; only
the primer, read beforehand, can. A proof-backed warning could: a binding
in a nested scope (an `if` branch, a loop body, a handler) of a name the
enclosing scope of the same function binds, whose initializer reads that
outer binding, and which is never read afterwards -- not by a later
statement of its scope and not as the scope's value where that value is
used. Every part of that is a fact the compiler has (hygiene already
renames a shadowing binding `NAME#N`; references are resolved), so it
would satisfy AGENTS.md's "backed by a compiler proof".

Before designing it:

* **Census.** Count, over the warning gate's corpus, the nested bindings
  hygiene renamed that read the binding they shadow, and how many are never
  read afterwards. That number is the warning's false-positive budget; a
  text search cannot take it (a field named like an outer binding looks the
  same).
* **The language question it raises.** concept.bindings allows shadowing in
  a nested scope on purpose. A warning keeps that; a rule forbidding a
  nested binding from reading the name it shadows would not. The census
  decides which is defensible, and the design document has to say why.
* If it lands, the primer's row changes from "compiles" to the warning's
  code, `task.accumulate`'s trap gets an `@warn`, and the warning's topic
  needs the five sections and both kinds of examples.

### 8.2 Messages that say what to write for absent forms

`error.surface-syntax` states that "most messages for absent forms say what
to write instead"; the forms agents write most do not. A parser that
recognized them could say so where it fails:

| Form | Today | Could say |
|---|---|---|
| `for x in xs:` | expected end of line, found name "x" | Botlish has no `for`: write `loop x in xs:` |
| `while c:` | expected end of line, found ... | no `while`: `loop:` with `break` |
| `x = a if c else b` | expected end of line, found "if" | no inline conditional: bind `x = if c:` on its own lines |
| `else if c:` | expected ":" after "else", found "if" | write `elif c:` |
| `x += 1` | expected an expression, found "=" | no compound assignment: a binding is immutable |
| `c ? a : b` | unexpected character "?" | no `?:` operator |

`for` and `while` are not keywords, so the parser can recognize them only
where a statement starts with the name followed by something that cannot
follow a name there; that is the parser's own recovery boundary
(DIAGNOSTIC-RECOVERY.md), and the change has to keep the recovery and
`tests/diagnostic-recovery.test` as they are. Each new message needs its
census classification and a Compilerpedia matcher; the rejected examples
whose `@message` pins the old text move with it.

### 8.3 UNBOUND that says the binding ended with its block

`unbound name "r"` already has clauses for a forward reference and an enum
case. The resolver knows when a binding of the name exists in a scope that
has ended before the use; a clause such as `"r" is bound only inside the if
branch at 3:9, which ends before this use` would let a matcher route the
case to `rule.immutable-bindings`, and tell the agent the fix without a
lookup. The clause must be deterministic, and the binding's location is
data: a `related` origin, never only text in the message (as AGENTS.md
asks of a diagnostic with further locations, and as the compiler service
reads them: COMPILER-SERVICE-MILESTONE-1.md).

### 8.4 METHOD-ELIGIBLE with the rewritten call

The warning proves that the method spelling parses and resolves to the same
function (the round-trip law, WARNINGS-METHOD-ELIGIBLE.md). Printing that
spelling (`call to total is eligible for method syntax: [1, 2, 3].total(0)`)
would let an agent apply it without reading the page, turning a turn of
investigation into a mechanical edit. Whether a warning may show its
rewrite is a decision of its own: two other warnings refuse a fix on
purpose; this one has the proof a fix needs. `tests/method-eligible.test`
and its fuzzer would pin the printed spelling against the round-trip law.
The primer's advice (decide at the declaration) avoids the warning
altogether, which is cheaper still.

### 8.5 Delivery

* **The packed executable's smoke test.** `single/smoke-test.sh` checks a
  few packed `-help` queries; adding `primer=task.first-program` keeps the
  primer shipping. It needs `single/build.sh` to verify, which this change
  did not run.
* **Language names.** IDIOMATIC-BOTLISH.md kept other languages' names out
  of the newcomer page's summary so that `-help rust` stays one page. The
  primer is the one page about other languages' habits; whether `-help
  python` and `-help javascript` (which find nothing today) should open it
  is a search decision to make with `cp-idiomatic-names-no-language`.
* **Page length.** The primer is 170 lines, 66 of them RELATED. An agent
  reads every line it is shown; if measurement shows RELATED costs more
  than it helps on long pages, a compact rendering is a renderer change,
  not a content one.

### 8.6 Further tasks

The questions IDIOMATIC-BOTLISH.md's audit found answered only by near
matches ("returning several values", "loop in expression position") and the
next experiments' pitfalls are task pages or aliases in waiting: add each
as a task that answers it, with an example, rather than as a new item on
the newcomer page.
