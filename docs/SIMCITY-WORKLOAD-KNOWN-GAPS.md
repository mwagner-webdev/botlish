# The SimCity workload's findings: what was fixed, and the known gaps

An independent agent built a SimCity-like game over the `raven` package
0.3.2 (eleven modules of Botlish, about 4,400 lines, a texture the game
draws itself, three headless suites, a benchmark and a save file) and wrote
a report of fourteen deficiencies, ordered by what each cost it. This
document evaluates that report against the repository, records what the
same change fixed, and lists the gaps that remain open, with their root
causes, so the next milestone can pick them up.

The report's claims fall into three groups:

* **Wrong, because our documentation said so** (five): the facility
  existed, and the compiler's own reference told the agent it did not.
* **Real defects** (five): a compiler budget that fails with the wrong
  message, a test report that cannot show a struct, and the Raven package's
  input model, error contract and documentation.
* **Known gaps, still open** (the rest): integer division, hoisting and
  mutual recursion, context-requiring functions as values, struct update,
  string operations. Each had been reported before.

## 1. The claims, one by one

| # | claim | verdict | root cause | now |
|---|---|---|---|---|
| 1 | Raven reports state, never a press | true of the package, not of Raven | the bridge recorded only widget callbacks; Raven's window event hook (keys, buttons, moves, the wheel) fell between "event consumption" and "notifications" (RAVEN-BINDINGS.md 7.1, C-CALLBACK-MILESTONE-1.md) | fixed (section 2) |
| 2 | a module wall at 38 distinct function values | true, misdiagnosed | the semantic-instance budget, 16 instances per callee (`hir/semantic.tcl`'s `maxPerBlock`); past it the call falls back to generic typing and the erasure check reports the 17th callable | open (3.1) |
| 3 | a failing test cannot show a struct | true | `std::test`'s `describe` has no case for a struct; Botlish has no reflection and no value-to-text intrinsic | open (3.2) |
| 4 | no file input or output | false | `std::io::fs` and `std::linux::fs` exist; `-help "read file"`, `-help std::io` and `backend.io` all said there was no file API (stale since WINDOWS-X86-64-MILESTONE-7.md) | docs fixed |
| 5 | no integer division | true | finding S2 of 2048-ENGINE-WORKLOAD.md, left open by POST-2048-PRODUCT-FIXES.md | open (3.3) |
| 6 | a context-requiring function cannot be a value | true, by design | context requirements are not part of function types (CONTEXTS.md, "Function values") | open (3.4) |
| 7 | no hoisting | true, but documented | strict reference determinism; mutual recursion is designed (MUTUAL-RECURSION.md) and not implemented | open (3.5) |
| 8 | the FFI's rules are undiscoverable | true | the package's sources cited five repository documents that ship nowhere; the binding gives non-string pointers no contract, so the agent wrote its own declarations | docs fixed; binding open (3.9) |
| 9 | `Usize`, `ULong` and `int` do not convert | false | `n.value` is a Usize's int, a C scalar is an Int domain; Compilerpedia's "There is no std::abi::to_int" read as "no conversion" | docs fixed; model open (3.8) |
| 10 | errors cannot be converted | false | `on Low: fail Mine` converts; nothing showed it. The seven `NonFiniteFloat` clauses came from `raven::events()` | fixed (docs; section 2) |
| 11 | no field assignment, no field by a runtime value | true | immutable structs by design; struct update syntax was Icy Tower's recommendation 5 and is unbuilt | open (3.6) |
| 12 | warnings cannot be turned off | false | `-warnings off` exists; per-warning suppression is absent by design. The `"<"` warning was ONE-CHAR-STRING-LITERAL, not METHOD-ELIGIBLE | no change (3.10) |
| 13 | no split, parse, trim or interpolation | partly | `std::int::from_string` parses an int; split, trim, search and interpolation are absent | open (3.7) |
| 14 | Raven has no key events, key state or wheel | true of the package | as 1 | fixed (section 2) |

## 2. What this change fixed

**Compilerpedia.** The stale pages are rewritten from the registry:
`capability.files` documents `std::io::fs` and the platform filesystems
(its ID kept), `backend.io` has a FILES section, the `std::io` page points
to them, `capability.input` documents `std::abi::bytes::decode_utf8`,
`capability.concurrency` documents `std::event_loop` and `std::actor`,
`capability.test-timeout` no longer says there is no timer,
`capability.assignment` names folds, `concept.c-ffi` says how C scalars and
`std::abi` values become ints, the `std::abi` page says `n.value` is the
conversion, and `task.handle-several-errors` shows converting an error. No
page names a repository document any more: the `docs:` header key is gone,
hand-written topics say what they meant, and the generator drops the
citations of standard-library comments (`cpt::Unreferenced`). Two checks
keep it so (`tools/compilerpedia.tcl check`): a rendered page that names a
design document fails, and so does a capability page whose alias names an
existing standard-library operation it does not relate. AGENTS.md's
Compilerpedia section adds the rule to cross-check the capability pages
whenever the standard library's public surface changes.

**The raven package, 0.4.0.**

* Raw input (bridge ABI 2): `window.watch_input(true)` installs the bridge
  as the window's event hook, which records `KeyPressed`, `KeyRepeated`,
  `KeyReleased`, `MousePressed`, `MouseReleased`, `MouseMoved` (the moves
  between two takes merged, their movement summed) and `Wheel`, with the
  pointer's position (`x`, `y`), the movement or scroll (`dx`, `dy`) and the
  modifiers, and always answers "not consumed": Raven delivers every event
  to its widgets as before (`raven-input` checks a button still clicked).
  A press is an event once per press, which is what the report's
  $600-a-second drain needed.
* The state: `key_down?`, `mouse_button_down?`, `modifiers_down`,
  `mouse_inside?` and `mouse_position` (through the context's native
  cells); and synthetic input for tests: `inject_move`, `inject_button`,
  `inject_wheel`, `inject_key_down`, `inject_key_up`.
* No more viral `NonFiniteFloat`: the bridge records finite numbers only (a
  spin box's infinity is a `ValueChanged` with `value` 1 and `number` 0.0),
  and `events()`, `rect()` and `mouse_position()` read them raw and admit
  them, declaring no error. A program's stale `errors NonFiniteFloat` or
  handler still compiles.
* Documentation: the module, README.md and GUIDE.md cite no repository
  document; GUIDE.md has "Keyboard, mouse and wheel" (with a checked,
  run test), "Saving and loading files" (`std::linux::fs`, checked) and
  pitfalls for presses and hand-written declarations of Raven's functions.

The release itself (`tools/package-build/author.sh build OUT -release
raven` in the pinned author image) has not been built in this change:
`packages/RELEASES.tsv` records 0.4.0 once it is.

## 3. The known gaps

### 3.1 The semantic-instance budget fails with the wrong message

`std::test::holds(name, description, predicate, body)` takes untyped
`predicate` and `body` parameters. A typed predicate (`fn check(p: P) ->
bool`) keeps its parameter contract only through a semantic instance of
`holds` keyed by that exact callable. `hir/semantic.tcl` allows
`maxPerBlock` 16 instances per callee; the seventeenth request is declined,
the call keeps its generic typing, and `hir::callables` reports
`"check_16" has typed parameter requirements that cannot be preserved
passed as an ordinary call argument`. Reproduced exactly: 16 distinct
`holds` calls compile, the 17th fails at `check_16`; 40 `std::test::value`
calls (zero-argument bodies, nothing to erase) compile.

* It is per callee, program-wide -- not per module, as the report
  concluded; splitting the registration into other functions does not
  help, splitting the program does (separate compilations).
* OPPORTUNISTIC-SEMANTIC-INSTANCES.md says "a budget never turns into a
  false error ... No budget was hit in the corpus": true of the corpus,
  which never calls `holds` more than three times in one program.
* The decline reason (`budget-block`) is recorded but never reported.

What a fix needs: at least a diagnostic that names the budget and the
callee when a declined request is what made the erasure; better, instances
keyed by a callable's contract rather than its identity, so that every
`P -> bool` predicate shares one instance (the erasure the instance
prevents depends on the contract, not on which function it is). Until
then: write the check into a zero-argument body, `std::test::value(name,
true, body)`.

### 3.2 A failing test cannot show what it got

`std::test::describe` renders Ints, Strings, Bools and Lists of them;
everything else is "a value with no text form", so a struct mismatch
prints two identical placeholders (GOLDEN-TEST-FRAMEWORK.md records it).
Both runtimes can print any value (the program's value is printed after a
run: `core::value::show`, show.rs), but no Botlish function can, and there
is no reflection to take a struct apart. A fix is a design decision: an
internal rendering intrinsic for `std::test` alone (the printer's text,
never a parse of it), or a matcher that takes the program's own rendering
function; whether display text may become observable to a program at all
is the question to settle first.

### 3.3 Integer division

`/` divides Float64 only; `mod`, `shift_right` and `bit_and` exist
(`capability.integer-division`). Reported by 2048 (S2), Icy Tower
(`hud::int_text` by subtraction) and now here (a 32-step restoring division
on every tile of every month). The design questions are the declared error
of a zero divisor (with the completion proofs that make a proven divisor
need no handler, as `mod` should too), the rounding (truncating and
Euclidean, consistent with `mod`), and the native lowering (one
instruction where both operands are machine-sized).

### 3.4 Functions that need a context cannot be values

CONTEXT-FUNCTION-VALUE is the documented frontier (CONTEXTS.md): a call
through an unknown function value could not prove its context installed,
and requirements are not part of function types. Its consequence the
report found: `std::test` cannot test anything that needs a context (a
file, Raven's `Ui`), because a case is a `Fn{args: [], return: Match}`.
Either function types gain a context component (with subtyping and
erasure rules), or `std::test` gains a way to run a case under the suite's
own contexts; both are language decisions.

### 3.5 No hoisting, and no mutual recursion

A binding is visible only after it is established
(`rule.forward-references`), so a file is ordered callee first, and two
functions that call each other cannot be written at all: `mutual:` groups
are designed (MUTUAL-RECURSION.md) and not implemented. The report's
reordering script is the cost of the first; the second is a hard limit for
recursive-descent parsers and state machines. Implementing `mutual:` is the
fix the design already chose; hoisting itself is rejected by
STRICT-REFERENCE-DETERMINISM.md.

### 3.6 Struct update

Every change to one field of a struct rebuilds all of them (Icy Tower's
`World` in `step`, the report's fifteen setters). STRUCT-DESTRUCTURING.md
sketches `value with { field: replacement }` and leaves it unspecified;
ICY-TOWER-VERTICAL-SLICE-1.md recommended it. Choosing a field by a run-time
value is reflection and stays out; a grid of attributes is better held as
one MutableArray indexed by `column * size + tile` than as one array per
attribute.

### 3.7 String operations

`std::str` has no split, trim, search (index of a substring) or
replacement, and there is no interpolation or format function
(`capability.string-formatting`). Every text format is a hand-written
scanner. `std::int::from_string` parses an Int strictly (a declared error,
no option type: `capability.null`).

### 3.8 Two models of ABI integers

`std::abi`'s sized values are nominal structs (`Usize {value:
UsizeValue}`, the conversion `n.value`, the creator `std::abi::usize(n)`),
while `std::ffi::c`'s scalars are Int domains (a `ULong` is an int; an int
enters one by a range proof). `std::abi::bytes::length` returns a `Usize`,
so the most common length in FFI code needs `.value` where a C length does
not. Unifying the two (domains for `std::abi` too, or a `length` that
returns an int domain) is a library decision with a migration of every
`.value`.

### 3.9 Raven: what the package still does not wrap

* **The file dialog.** `Rfile_dialog_open` runs a modal loop of its own
  (headless it waits for input that never comes) and takes a descriptor
  of C strings, which only C can build: a bridge function could, but it
  needs a desktop acceptance (a real window driven from outside) before it
  ships. Programs read a file name from a text input.
* **Textures, custom painting, virtual lists, event consumption.** Raven
  calls back for them inside a frame; a Botlish callback runs only during
  the C call it is passed to (C-CALLBACK-MILESTONE-1.md). They wait for
  retained registrations.
* **Typed characters and double clicks.** `R_EVENT_TEXT` (a codepoint) and
  a press's click count are not recorded; a text input reports text.
* **The binding's contracts.** The profile states `read noescape` for every
  `const char *`, and nothing for other pointers, so `Rfile_write`'s
  `const void *data` cannot borrow Bytes and `Rfile_read`'s result has no
  provenance. Files are the standard library's anyway (GUIDE.md section
  12). The generated binding's comments still cite C-BINDGEN.md: changing
  them means regenerating with the pinned toolchain (clang 21.1.8).

### 3.10 Warnings without a per-warning switch

By design (AGENTS.md, "Compiler warnings"): one policy per compilation,
`-warnings default|off|error`, no source suppression. The report's friction
is real -- METHOD-ELIGIBLE asks for `xs.get(i, d)` of a standard-library
function its caller cannot mark `nomethod`, and ONE-CHAR-STRING-LITERAL
fires on a one-character button label, where a String is what the API
takes -- and is evidence for those warnings' precision audits, not for a
suppression mechanism.

### 3.11 The process gap

Integer division, struct update and string operations were each reported
by an earlier workload and left open without a place that tracks them: a
workload's findings live in its own report. This document is that list
for now; the next workload should start from it, and close or re-confirm
each entry.
