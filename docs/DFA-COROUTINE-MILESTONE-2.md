# DFA-COROUTINE-MILESTONE-2.md

Milestone 2 of declarative finite-state recognition in Botlish: bounded
lookahead, economical lowering and integration into the ordinary compiler.
The exploration (DFA-COROUTINE-EXPLORATION.md, milestone 1) showed that a
recognizer declared as a deterministic finite automaton, checked
statically and executed as an ordinary coroutine, catches every structural
mistake its census planted and compiles to fused native code that allocates
nothing per symbol. It also found what kept it from being permanent: a
recognizer could leave only one symbol unread (YAML needs two), its
generated decision trees made compilation expensive, and it lived in a
preprocessor beside the compiler. This milestone resolves those three.

> A DFA should make the language of accepted input explicit and statically
> checkable, while remaining an ordinary coroutine at execution time. Its
> declaration should cost the programmer very little complexity and the
> compiled program very little machinery.

## Contents

1. [Result](#1-result)
2. [Starting evidence](#2-starting-evidence)
3. [Final syntax](#3-final-syntax)
4. [Recognition semantics](#4-recognition-semantics)
5. [Static guarantees](#5-static-guarantees)
6. [Unread-symbol ownership](#6-unread-symbol-ownership)
7. [Compiler integration](#7-compiler-integration)
8. [Intermediate representation](#8-intermediate-representation)
9. [Coroutine fusion](#9-coroutine-fusion)
10. [Reference interpreter census](#10-reference-interpreter-census)
11. [JSON results](#11-json-results)
12. [YAML results](#12-yaml-results)
13. [Diagnostics and tooling](#13-diagnostics-and-tooling)
14. [Native code evidence](#14-native-code-evidence)
15. [Performance](#15-performance)
16. [Regressions](#16-regressions)
17. [Side findings](#17-side-findings)
18. [Next steps](#18-next-steps)

## 1. Result

**Production language functionality.** `class` and `dfa` declarations are
part of Botlish: written in an ordinary module, checked by the compiler
where they are written, and lowered before HIR to ordinary coroutine
functions -- no preprocessor, no new runtime, no new coroutine operation,
no HIR or Core IR node. Concretely:

* **Bounded lookahead.** A recognizer completes with an Int, the number of
  symbols it was handed that are not part of its token: `accept` 0,
  `accept before N` N. N is a compile-time count the compiler bounds by
  what the recognizer has consumed, through calls too, so every recognizer
  has a static lookahead and never hands back a symbol before its first
  (section 4). The YAML counterexample is resolved: in flow context `a:b`
  is one plain scalar and `a: b` the scalar `a`, the indicator and `b`
  (section 12).
* **Static guarantees**: the exploration's seventeen checks adapted
  (determinism, defined rejection, explicit acceptance, finite control,
  alphabets, the end, integrity, names) plus the two lookahead checks; 17
  diagnostic kinds, each reported at the declaration with its related
  locations, each with a negative test and a Compilerpedia topic. The
  mistake census: all 13 structural mistakes and the 2 lookahead mistakes
  that break the bound caught by the compiler; the 3 lookahead mistakes
  that respect it (a wrong count is a wrong language) and 15 of 17 grammar
  mistakes caught by the differential tests; 2 grammar mistakes surviving
  both -- the same 2 as in the exploration (section 16).
* **Economical lowering.** A recognizer's transitions are one call of an
  internal root native over a constant table; native lowering turns it into
  a static byte table (bytes and ascii) or the new general NIR `switch`
  (Cranelift's `br_table` or a balanced search), never a call. Against
  the prototype on the same machine (section 15) the recognizers' own
  compile cost fell 3-5x at every stage -- a program using one recognizer
  of the JSON module spends 0.38 s in the front end (1.5-1.6 s, plus the
  preprocessor), the lexer's native lowering takes 0.53-0.77 s (1.5 s), its
  fused driver compile 33-46 ms (144 ms), its machine code 19.4 KB (29.1
  KB) -- while the fused code runs as fast: the JSON lexer at 14.1-14.5 ns
  per character (13.3-14.1), the validator at 25.5-26.5 (26.4-27.3), and
  json_number fed digits within 5% of the same recognizer written by
  hand. The JSON workloads' whole front end stays near 4 s: its drivers
  module, not its recognizers (about 20 ms), dominates it (section 17).
* **Integration.** Modules (qualified and rooted names, imports, a module's
  rejected recognizer dependent at its users), diagnostic recovery, syntax
  recovery, the front-end cache, HIR interchange, the Tcl compiler and both
  native modes; the compiler service and language server show hover,
  definition and references for states, classes and called recognizers.
* **Workloads.** The JSON demonstration (`examples/dfa/json/`) agrees with
  CPython's strict json on all 24,318 differential cases, whole and
  chunked, as the prototype did; YAML's subset (`examples/dfa/yaml/`) with
  its two-symbol plain scalar. Their drivers keep an explicit buffer of the
  recognizers' static lookahead.
* **Retired**: the exploration's preprocessor (`audit/dfa/tools/dfa.tcl`),
  its `.dfa` sources, generated modules and tests. One DFA compiler
  remains; the exploration's results stay as history.

Not done, with reasons: tail calls in the reference interpreter (deferred
by the milestone's rule: section 10); the Unicode library facilities
(a separate standard-library milestone: section 11); a warning for
discarded collecting loops and the method-decision build (separate
milestones: section 17); interprocedural fusion (out of scope: the factory
probe documents its cost).

## 2. Starting evidence

The exploration's prototype (`audit/dfa/tools/dfa.tcl`, a preprocessor of
`.dfa` files into generated `.bot` modules) established, and its reports
(`audit/dfa/results/`, `audit/dfa/evidence/`) recorded:

* **Static guarantees work.** All 13 structural mistakes of its census were
  diagnosed at compile time; 15 grammar mistakes were caught by the
  differential tests and 2 survived both (`results/mistakes.md`).
* **JSON conformance.** The JSON workload (RFC 8259's lexical grammar as
  declared recognizers, a structural layer with an explicit stack) agreed
  with a strict CPython oracle on 24,318 cases -- JSONTestSuite's
  `test_parsing` and generated, mutated texts -- whole and cut into random
  chunks (`results/differential.md`).
* **Native performance.** Fused, the declared JSON lexer ran at about 14 ns
  per character (the hand-written coroutine tokenizer of a subset of JSON:
  about 11), allocating nothing per symbol; the declared UTF-8 validator (8
  ns per byte) beat the hand-written coroutine and procedural ones (about 9).
* **The one-symbol limit.** A recognizer answered each symbol with a Bool
  (taken or not), so it could leave at most the symbol it was handed
  unread. YAML's flow plain scalar ends two symbols back at ": " -- the
  prototype accepted the declaration and recognized the wrong language
  (`a:` where YAML means `a`).
* **Compilation cost.** The generated JSON lexer module was about 2,000
  lines of nested `if`s: about 4.3 s of front end for the lexer workload
  (0.8 s for the hand-written imperative tokenizer), 1.5 s of native
  lowering, about 165 ms of the native driver's compile with fusion, and
  fused consumers of 29 KB (lexer) and 37 KB (validator) of machine code --
  fusion copies a recognizer's template per start and resume, and each
  template was a decision tree per state.
* **Composition.** A driver parameterized by a recognizer factory was
  expressible, but its handles leave the factory, so fusion keeps them on
  the general runtime (22x slower).

Re-measured on this milestone's machine with the exploration's own
benchmark (from a worktree of its final commit, e5286ad5), the numbers
reproduce (section 15).

## 3. Final syntax

A recognizer is declared in an ordinary `.bot` module that imports
`std::dfa`:

```
import std::dfa

class digit = '0'..'9'
class nonzero = '1'..'9'
class ws = ' ' '\t' '\n' '\r'
class after_value = ws ',' ']' '}'

dfa json_number over ascii:
    start:
        '-' -> minus
        '0' -> zero
        nonzero -> integer
    minus:
        '0' -> zero
        nonzero -> integer
    zero:
        '.' -> point
        'e' 'E' -> exponent
        after_value -> accept before
        end -> accept
    ...

dfa json_token over unicode:
    start:
        '{' '}' '[' ']' ':' ',' -> accept
        '"' -> call json_string then accept
        '-' digit -> call json_number then accept
        't' 'f' 'n' -> call json_literal then accept
```

and YAML's plain scalar (section 12) needs two symbols of lookahead:

```
    colon:
        plain '#' -> body
        ':' -> colon
        white line_break flow_indicator -> accept before 2
        end -> accept before 1
```

The grammar (surface/parser.tcl's header has it in full):

| form | meaning |
|---|---|
| `class NAME = ITEMS [except ITEMS]` | a named symbol set, top level or inside a `dfa` (before its states) |
| `dfa NAME over bytes\|ascii\|unicode:` | a recognizer; its states follow, the first the start |
| `STATE:` then `ITEMS -> ACTION` lines | a state and its transitions |
| ITEMS | symbols (`'a'`, `0x41`, a decimal code), ranges (`'0'..'9'`), classes (`digit`, `ns::digit`, `::ns::digit`), `any`, `end`, and in a transition a sequence (`"true"`) |
| `-> STATE` | consume the symbol and continue in STATE |
| `-> accept` | complete: every symbol supplied is part of the token |
| `-> accept before` / `before N` | complete, the last N symbols supplied (1 for `before`) not part of it |
| `end -> reject` | the end of the input fails here (the only explicit rejection) |
| `-> call D then STATE` / `then accept` | hand the symbol to the earlier recognizer D; continue in STATE when it completes, or complete with it |

Differences from the prototype:

* **No preprocessor.** `class` and `dfa` are declarations of the language,
  parsed with the module that holds them; the `.dfa` files and the
  generated modules are gone.
* **`accept before N`**, a compile-time count (section 4); `accept before 0`
  is `accept` (it compiles to the same table; allowing it costs nothing and
  keeps a generated or edited declaration regular).
* **No `=>`.** The prototype's non-consuming move (reconsider the symbol in
  another state) was unused by the workloads once calls existed; it is a
  syntax error that says so. Every transition now consumes its symbol,
  completes, or calls a recognizer that consumes it.
* **Explicit rejection only of the end** (`end -> reject`); an ordinary
  symbol is rejected by having no transition, as before.
* **`std::dfa`**, not the prototype's `dfa` module: `std::dfa::Symbol`,
  `std::dfa::UnrecognizedInput {recognizer, state, symbol}`,
  `std::dfa::UnexpectedEnd {recognizer, state}`. The payload names the
  recognizer (qualified for a module's: `json_lex::json_number`) as well as
  the state.
* **Classes are both**: top level (importable: `json_lex::digit`) and local
  to a recognizer (`class first = ns_char except indicator`), the local
  ones shadowing nothing and seen only by their recognizer.
* **Qualified and rooted references** to another module's classes and
  recognizers (`tokens::digit`, `::tokens::number`), checked like every
  qualified name: MISSING-IMPORT where written.
* **Hexadecimal symbols** (`0xC2`) are tokens of the lexer, accepted only in
  these declarations (an Int elsewhere is written in decimal: a syntax
  error says so).
* Every word of the syntax (`class`, `dfa`, `over`, `accept`, `before`,
  `reject`, `call`, `then`, `end`, `any`, `except`) stays an ordinary name
  outside a declaration.

Nothing else was added: no actions, priorities, longest match,
backtracking, regex syntax or second executor.

## 4. Recognition semantics

A recognizer `R` is one ordinary coroutine function

```
nomethod fn R(first: int, resume std::dfa::Symbol) -> int errors E
```

E being exactly the errors it can raise (UnrecognizedInput, UnexpectedEnd,
or both). Its protocol, in coroutine terms:

* **Construction** (`coroutine {step, first: u} = R(c)`) hands it the
  token's first symbol, eagerly, as every coroutine starts.
* **Each yield answers 0**: the symbol was taken and the recognizer needs
  more. The caller resumes it with `step(std::dfa::Symbol {code: c})`.
* **Completion** (`std::coroutine::done?(step)`) returns U, the number of
  the actual symbols it was supplied that are not part of the token:
  `accept` 0, `accept before N` N. The caller tells suspension from
  completion by the coroutine's own state, never by the value: a yield's
  0 and a completion's 0 are told apart by `done?`.
* **The end of the input** is the code -1, never a symbol. It is never
  counted: completing at the end with `accept before N` leaves the last N
  actual symbols unread, and an end that a state does not accept fails
  UnexpectedEnd. A chunk boundary is no end: the caller simply has not
  resumed yet.
* **Failure**: a symbol no transition of the current state takes (an
  out-of-alphabet value, a BigInt, a surrogate in a unicode recognizer)
  fails `std::dfa::UnrecognizedInput {recognizer, state, symbol}`; the end
  where nothing accepts, `std::dfa::UnexpectedEnd {recognizer, state}`. A
  state inside a sequence is named by its prefix (`start"tr"`). The
  position is the driver's: the recognizer keeps none.
* **Terminal states are stable** (COROUTINES.md): resuming a completed
  recognizer answers its count again and consumes nothing; resuming a
  failed one raises its error again. A recognizer that completes on its
  first symbol is done at construction, its count the construction's
  value.
* **A recognizer none of whose transitions suspends** (every token one
  symbol) has no yield, so -- Botlish having no coroutine without one --
  it is an ordinary function of its first symbol, called directly (a
  `coroutine` binding of it is the language's own
  COROUTINE-RHS-NOT-YIELDING).
* **Delegation.** `call D then accept` hands the current symbol to D (its
  first symbol) and completes with D's count. `call D then STATE` continues
  in STATE when D completes: with the symbol D left unread, if it left one,
  reconsidered in STATE at once (or the end); otherwise with the next. A
  recognizer holds no input, so a caller can reconsider only the current
  symbol: `then STATE` takes only a callee whose count is at most 1 on a
  symbol and 0 at the end (DFA-CALL-LOOKAHEAD otherwise; `then accept`
  passes any count on).

Everything above is ordinary coroutine semantics: eager construction,
typed resume messages, stable terminal results and failures, affine handles
released at their last use, deep yields (the callee's yield is the
caller's), and fusion. No coroutine operation was added.

### Why an Int and a count

The exploration's Bool said "the last symbol was taken". A count says how
many were not: the same information for 0 and 1, and the only extension
that lets a token end further back. The outward type stays one scalar
(`int`), so fusion transports it in a register (section 9). The
alternative of a record (`{taken: int, ...}`) would carry nothing more and
cost a struct per completion where escape analysis fails.

### The bound (static)

`accept before N` is bounded by what the recognizer has consumed. For each
state q, K(q) is the fewest symbols any path from the start to q consumes
(a goto counts 1, `call D then` counts D's own minimum). Then:

* on a symbol: N <= K(q) -- of the K(q) + 1 symbols supplied with this one,
  the token keeps at least one;
* at the end: N < K(q), or N = 0 -- the end is no symbol, and a token is
  empty only when no symbol was supplied at all.

DFA-UNREAD-BEYOND-INPUT otherwise. So a recognizer never claims to return
symbols before the beginning of its input, every token is nonempty unless
its input is, and every recognizer has a static maximum count -- its
*lookahead* -- computed through its calls: `then accept` passes the
callee's counts on (yaml_token's lookahead is 2, from yaml_plain_flow);
`then STATE` admits only callees that leave at most the current symbol. The
recognizer keeps no history: the bound is what the *driver* must buffer
(section 6). Nothing is backtracked, and no longest match is searched: the
declaration says where each token ends.

## 5. Static guarantees

The model is the exploration's: a recognizer is (S, Q, q0, d), d(q, s)
defined for every Int s, computed exactly by interval arithmetic into the
*effective table* (one partition of the Int line per state). Every check
reads the declaration or the effective table, never generated code. What
the compiler proves of every recognizer it accepts:

| property | statement | diagnostic |
|---|---|---|
| Determinism | the transitions of a state claim pairwise disjoint symbols (a sequence's states are a trie, so `"true"` and `"trap"` share `"tr"`) | DFA-AMBIGUOUS-TRANSITION, with the overlapping symbols and both transitions |
| Defined rejection | d is total: everything a state lists no transition for -- any Int -- fails UnrecognizedInput, the end UnexpectedEnd | (by construction: the table's default) |
| Explicit acceptance | the function completes normally only through an accepting transition, directly or through a call | (by construction: the lowering's only normal exits) |
| Progress | every transition consumes its symbol, completes, or calls a recognizer that consumes at least its first symbol (the bound forbids a recognizer to complete before consuming one) | (by construction; the prototype's DFA-NONPROGRESSING-CYCLE had only `=>` to catch, now gone) |
| Finite control | the state is a number and a position in an acyclic call chain | DFA-RECURSIVE-CALL, DFA-UNKNOWN-DFA (a recognizer calls only earlier ones) |
| Bounded lookahead | every count is within what the recognizer consumed; a reconsidering call's callee leaves at most the current symbol | DFA-UNREAD-BEYOND-INPUT, DFA-CALL-LOOKAHEAD |
| The end | a state that can complete before a symbol says what the end means; the end is never consumed | DFA-MISSING-END, DFA-END-CONSUMED |
| Alphabet discipline | written symbols are in the alphabet, bytes and characters are not confused, a callee reads the caller's symbols with the same meaning | DFA-ALPHABET, DFA-BYTE-CHARACTER, DFA-CALL-ALPHABET |
| Integrity | no unreachable state, no state from which every path rejects, no call whose callee rejects every symbol handed to it | DFA-UNREACHABLE-STATE, DFA-NO-ACCEPT, DFA-DEAD-TRANSITION |
| Names | states, classes and recognizers exist, are declared once, ranges are nonempty | DFA-UNKNOWN-STATE, DFA-UNKNOWN-CLASS, DFA-DUPLICATE, DFA-EMPTY-RANGE |

Seventeen kinds, the exploration's seventeen checks adapted: its 15
semantic kinds kept, DFA-SYNTAX now the parser's ordinary located syntax
errors (SURFACE SYNTAX, with messages for `=>`, a rejected symbol, a
missing `over`, ...), DFA-NONPROGRESSING-CYCLE gone with `=>`, and the two
lookahead checks new. Every one has a negative test (`tests/dfa.test`'s
`dfa-diag-*`, 33 cases with their locations and related locations) and a
Compilerpedia topic with a rejected example.

What the guarantees do **not** cover: that the declared language is the
intended one. A deterministic, well-formed recognizer can recognize the
wrong language -- the census's grammar mistakes (section 16) are exactly
that, and only conformance tests catch them. A declaration proves that the
recognizer is a finite automaton with defined behavior on every input; it
proves nothing about RFC 8259 or YAML 1.2.2.

## 6. Unread-symbol ownership

The input source advances monotonically: no rewind of a file, socket or
source coroutine. The **driver** -- the function that feeds a recognizer --
keeps the last L symbols it read, L the most any recognizer it runs leaves
unread (its static lookahead), and hands back what a token left unread to
the next token. The two workloads show both shapes.

**L = 1 (examples/dfa/json/json.bot).** json_lex's lookahead is 1: a
number or a literal ends before the symbol after it, and nothing is left
unread at the end. The buffer is the current symbol:

```
cursor[0]   the offset of the current symbol
cursor[1]   the current symbol (-1: the end of the input, no symbol)
cursor[2]   tokens so far
cursor[3]   the current token's count: 0 while it runs, then what it left unread
```

A recognizer is handed the current symbol; when it answers 0 the driver
reads the next. When it completes leaving one unread, that symbol stays
current -- the next token's first -- and nothing is read again; leaving
none, the driver reads the next (unless the current one was the end).

**L = 2 (examples/dfa/yaml/yaml.bot).** yaml_token's lookahead is 2 (a
plain scalar ends two symbols before the one after its `:`), so the
driver keeps a ring:

```
ring        the last two symbols read, symbol at offset P in slot P mod 2
cursor[0]   pos: the offset of the next symbol to hand over
cursor[1]   read: how many symbols the source has supplied
```

The next symbol is `ring[pos mod 2]` while pos < read (a symbol given
back), else the source's, kept in the ring; the end, -1, advances nothing
and is never kept. When a token completes leaving U unread, pos goes back
by U. The invariant `pos <= read <= pos + 2` holds because a recognizer
leaves unread at most what it was handed and at most its lookahead (the
static bound), so the symbols given back are still in the ring.

In both, no symbol is lost (each is read once from the source and kept
until handed over again), duplicated or assigned to two tokens (a token is
the interval [start, pos - U), the next starts at pos - U). Chunks are the
source's business: the source coroutine yields symbols across chunk
boundaries, an empty chunk yields none, and the driver never sees a
boundary. The JSON driver first used a ring too; keeping only the
current symbol where the lookahead is 1 was one of the three changes that
took the fused validator from 32-33 to 25.5-26.5 ns per character
(section 15).

### A standard-library helper?

Investigated and not added. The buffer cannot be a function: a function
that may yield is never a value (COROUTINES.md 37), so a helper cannot
resume the driver's source for it; a MutableArray parameter is a logical
copy (MUTABLE-ARRAY.md), so a helper cannot advance the driver's buffer in
place. A coroutine helper -- a buffered source that owns the source's
handle and takes "rewind U" messages -- is expressible, but the source's
handle then leaves the driver, and fusion keeps both on the general runtime
(the factory probe's cost: about 22x, section 15). The buffer is a few
lines per driver, and its size is the recognizers' static lookahead. A helper
becomes worthwhile when interprocedural fusion (COROUTINE-FUSION-
MILESTONE-1.md, "Limits") lets a handle cross a call; until then each
driver spells it out, as json.bot's four drivers and yaml.bot's two do.
Nothing makes a recognizer depend on where its symbols come from.

### Tested

tests/dfa.test and tests/dfa-workloads.test cover one-symbol unread (JSON
numbers and literals), two-symbol unread (YAML's ": "), three
(`arrow`: a run of a's and dashes ending before "-->"), the largest the
workloads declare; a token ending exactly at a chunk boundary and several
symbols before one (every split of every text, and random splits with
empty chunks); the end right after provisional input (`a:` at the end:
the scalar `a`, one symbol unread); consecutive tokens that each leave
symbols unread (`[12,345]`, `{a:b, c: d}`); a delegated recognizer's
unread symbols passed through `then accept` (`tail` calls `arrow`) and
reconsidered by `then STATE` (`pair` calls `digits`); and early failure
with provisional symbols buffered (`1.2.3`, `- a`).

## 7. Compiler integration

* **Parsing** (surface/parser.tcl): `class` and `dfa` are contextual
  declarations at a file's top level (`classdecl`, `dfadecl` AST nodes with
  a span for every name, item, arrow and action); malformed ones are
  located syntax errors, recovered from by the syntax recovery
  (surface/recover.tcl: a broken `dfa NAME` still declares NAME).
* **Checking** (surface/dfa.tcl's `expand`): the loader calls it on each
  file once the modules the file imports are loaded
  (surface/modules.tcl's ExpandDfas), with the registry of what those
  modules declared. It resolves names (local classes, the file's, imported
  ones by qualified or rooted name, MISSING-IMPORT for an unimported
  namespace, a recognizer whose namespace has a malformed statement
  dependent rather than unknown), builds the effective table and runs every
  check of section 5. A file declaring a recognizer must import `std::dfa`
  (MISSING-IMPORT at the first one otherwise).
* **Diagnostics** are reported at the declaration: a rejected declaration
  lowers to a HIR hole carrying its report (hir/resolve.tcl's ResolveHole),
  so each becomes an ordinary resolution diagnostic that taints its unit
  (DIAGNOSTIC-RECOVERY.md): code that uses a rejected recognizer is
  dependent and says nothing, independent errors elsewhere are reported
  with it, and no diagnostic ever comes from generated code.
* **Lowering** (surface/dfa.tcl's Nodes and Lower, called from
  surface/lower.tcl) writes HIR syntax nodes directly -- a handful per
  recognizer (section 8) -- before HIR: no HIR node kind, Core IR form or
  runtime operation knows recognizers. The generated functions' names hold
  a `#` (no source can spell them) and are `nomethod`, so they never take
  part in method resolution; the String constants the lowering writes are
  marked synthesized (no ONE-CHAR-STRING-LITERAL for a one-letter state).
* **Modules** behave as for any declaration: a recognizer is a module
  member reached by its qualified name, imported with its module, a
  module's diagnostics are its own, and the front-end cache keys a file by
  its text and its imports' (plus `surface::dfa::lowering`, a front-end
  input). HIR interchange carries a program with recognizers unchanged
  (`dfa-modules-interchange`).
* **The compiler service** analyzes a declaration as ordinary source: its
  diagnostics with ranges and related locations, and the facts of its names
  (section 13).

## 8. Intermediate representation

The exploration lowered each state to a decision tree of nested `if`s:
thousands of lines of Botlish that the front end type-checked, the range
analysis proved, native lowering lowered and fusion copied, only for
Cranelift to fold most of it. This milestone keeps the transition graph as
data until native code generation.

### The compact lowering

surface/dfa.tcl computes the effective table, numbers the states and the
distinct outcomes (completions, calls, rejections) as *codes*, and writes
each recognizer as two small functions:

```
NAME#run(state, c, resume std::dfa::Symbol) -> int    -- one step and the rest
    next = dfa#transition(state, c, TABLE)
    target = if next < STATES: next else: <complete, call or reject by code>
    m = yield 0
    NAME#run(target, m.code)
NAME(first, resume std::dfa::Symbol) -> int          -- the recognizer
```

`dfa#transition(state, c, TABLE)` (core/dfa.tcl) is an internal root
native whose last operand is a String constant: the table, one row per
state `{DEFAULT {LO...} {HI...} {CODE...}}`. It is pure, total and
allocation-free; the Tcl backends look the code up (a binary search), and
native lowering never calls it (below). `NAME#run`'s result is an Int that
encodes the completion for a caller: -2 (every symbol taken), c (the
current symbol left unread, or -1 at the end: what a caller can
reconsider) or -2 - U (U unread, which only `then accept` passes on). The
JSON lexer module is 219 lines of declarations and comments, lowered to about 25
functions with 11 transition calls; the exploration's generated module was
1,985 lines.

### The native dispatch

native/lower.tcl's DfaTransition expands a transition call at compile time
into control flow over its constant table, the form chosen per recognizer
(`-dfa-dispatch`, BOTLISH_NATIVE_DFA_DISPATCH):

* **table** -- the default for a recognizer whose transitions name only
  symbols in -1..255 (every bytes and ascii recognizer, and a unicode one
  such as json_token, whose other symbols all reject): one static byte
  table (16-bit entries when a code exceeds 255) indexed by state times 257
  plus the symbol (the end at index 0), read by `op rtabload8` or
  `rtabload16`; a symbol outside the byte range takes the row's default. A
  recognizer of one state skips the state's part of the index.
* **switch** -- the default otherwise (json_string's rows name
  U+0080..U+10FFFF) and on request: a multiway branch on the state, then
  one on the symbol over its row's intervals.
* **tree** -- nested comparisons, the exploration's shape, built here
  instead of in the front end (kept to measure).

### The NIR `switch`

The multiway branch is general NIR, not a DFA opcode:

```
switch %v LDEFAULT LO:HI:L ...
```

a terminator over a raw integer register with sorted, disjoint closed
intervals and a default (native/src/nir.rs: parsed, validated -- raw
operand, sorted, disjoint -- and walked by every analysis: liveness, roots,
fusion's copies and successor graph). codegen::clif's `switch` lowers it to
Cranelift's `br_table` when it is dense (at least 5 intervals over a span
of at most 4,096 values and at most 8 times the number of intervals) and to a balanced
binary search over the intervals otherwise. `rtabload8/16 %table %index`
are raw loads from a bytes constant's payload. Both are general: an enum
match or a coroutine resume dispatch could use them; this milestone uses
them only for transitions (section 17 says what else was measured).

## 9. Coroutine fusion

The recognizers use coroutine fusion unchanged (COROUTINE-FUSION-
MILESTONE-1.md); nothing in fusion knows recognizers.

* **One yield per recognizer.** `NAME#run`'s only suspension is `m = yield
  0`, after which it calls itself in tail position with the next state;
  calls to earlier recognizers are ordinary calls of their `#run`
  (a callee's yield is a deep yield of its caller). Fused into a driver,
  the chain is inlined once as a template: the transition, the yield's
  continuation and the self tail call become a loop over registers
  (`fused count ... inlined {{#5} number number#run} yields 1`:
  `dfa-lowering-fused-no-allocation`).
* **The count is a scalar.** The completion value is an Int, transported in
  a register like the yields' 0; a resume message's `code` is read with a
  `structget` of the fused message, never a boxed struct. A fused driver
  allocates nothing per symbol: ten symbols and a thousand cost the same
  allocations (the driver's own counter and the program's result List).
* **Compact dispatch shrinks the copies.** Fusion copies the template per
  start and resume; the template is now a table load and a code dispatch
  instead of a decision tree per state, so the fused lexer's machine code
  fell from 29.1 KB (prototype) to 19.4 KB, and the driver's compile
  with fusion from about 144 ms to 33-46 ms (section 15).
* **What fusion cannot follow** stays on the general runtime, as before and
  by design: a handle that leaves the function that constructs it. The
  factory probe (`composition.bot`, `dfa-json-composition`) keeps its
  recognizers on the general runtime -- about 23x slower than fused, the
  same ratio as the prototype's -- and that cost is the optimizer's
  interprocedural limit, not the recognizers'. A failed fusion is never a
  compilation error (`kept`, with its reason).

## 10. Reference interpreter census

The interpreter evaluates Core IR (`hir::lower`); the Tcl compiler compiles
HIR (DIRECT-HIR-NATIVE-PATH.md, "The Tcl compiler compiles HIR"), as
native lowering does. The census:

1. **Does Core IR represent tail-call intent?** No: core/ has no notion of
   a tail call; a call is a call.
2. **Can tail position be identified from Core IR?** Structurally, yes --
   the last expression of a lambda body through `if` branches -- but Core IR
   interleaves what makes a call not a tail call: an affine value's release
   emitted after the statement that last uses it (COROUTINES.md, "Release
   at the last use"), a handler-shaped catch around a call that releases on
   its error edge (`ReleasingOnError`), a handled call's `on` clauses. A
   tail-call analysis there would re-derive what HIR states.
3. **Does the Tcl compiler lower eligible tail calls?** Yes, and so does
   native lowering: `hir::aot::selfTailCalls` (hir/aot.tcl) finds a block's
   self tail calls outside loops, from HIR; the Tcl compiler turns such a
   proc body into `while 1 {... continue}` (compiler/compiler.tcl's
   CompileBlockBody/CompileCall), native lowering into a `tail` call. A
   recognizer's `NAME#run` is exactly such a call, so the Tcl compiler and
   the native backend run tokens of any length.
4. **Would a shared Core IR improvement benefit both?** No: the Tcl
   compiler does not read Core IR, so a Core IR tail-call form would serve
   the interpreter alone.
5. **Restrictions.** Error handling (a call inside a handled region is no
   tail call), releases after the call, and coroutine segments (a yield's
   continuation) all exclude calls; selfTailCalls already respects the
   first two from HIR, and a recognizer's tail call follows its yield.

**Decision: deferred**, by the milestone's rule: tail calls in the
interpreter would be interpreter-specific machinery, with no Core IR
benefit for the Tcl compiler. The remaining limit: the interpreter nests
one Tcl evaluation per symbol of a token, so its recursion limit bounds a
token -- 2,000 symbols run (`dfa-json-long-interp`); 20,000 do not, and the
tests that run them name the other backends. The bytecode VM supersedes
this. No alternative lowering was added for the interpreter.

## 11. JSON results

The JSON demonstration is ported whole to `examples/dfa/json/`:
`json_lex.bot` (RFC 8259's lexical grammar: numbers, literals, punctuation,
strings with every escape, `\u` escapes, UTF-8 validation over bytes, the
strict I-JSON surrogate rule as finite state, eleven recognizers),
`json.bot` (drivers over text, scalar values and UTF-8 bytes, the
structural layer with an explicit stack and the caller's depth and token
limits, string decoding), `conformance.bot` (the standalone program the
differential tool builds), `composition.bot` (the factory probe) and
`by_hand.bot` (json_number written by hand as an ordinary coroutine).

* **Differential** (`audit/dfa/tools/differential.tcl -suite
  JSONTestSuite/test_parsing -fuzz 2000 -seeds 1-12`,
  `audit/dfa/milestone-2/differential.md`): 24,318 cases -- JSONTestSuite's
  318 files and 24,000 generated, mostly mutated texts -- each validated
  whole and in random chunks, over bytes and (where valid UTF-8) over
  scalar values, against CPython's json made strict. **0 disagreements, 0
  whole/chunked disagreements**, the 2 documented resource limits (the
  oracle's recursion limit against our max_depth 1000), and every tally
  identical to the exploration's: replacing the Bool protocol with a count
  changed no verdict. The executable is built through the ordinary native
  executable path (10.2 s; the prototype's 12.1 s).
* **Token boundaries, separately from documents** (`dfa-json-boundaries`):
  `123,` is a number of 3 symbols leaving 1 unread; `01`, `1.2.3`,
  `123abc`, `truex` fail at the symbol that continues them (with the
  recognizer and state: `json_lex::json_number zero`); `1e+`, `1.`, `-`,
  `nul` at the end fail UnexpectedEnd in the state where the token stopped;
  a string ends at its closing quote leaving nothing unread. So a
  misplaced boundary cannot hide behind the structural parser.
* **The recognizers against their declarations** (`dfa-json-model`): every
  state's every transition (the reference interpreter's frontier) and
  random runs, on every backend -- over 1,000 cases in the test suite;
  5,508 in a longer run during development, 0 disagreements.
* **Chunking** (`dfa-json-chunks`): every split of seven texts and random
  splits with empty chunks, over text and bytes (splits inside escapes,
  UTF-8 characters, literals, and between a number and the symbol that ends
  it) give the unsplit text's verdict.
* **Documents** (`dfa-json-documents`, `dfa-json-bytes`, each checked
  against the oracle too): nesting, token order, trailing commas, several
  values, trailing content, a number as the input's last token and right
  before a bracket, overlong UTF-8, encoded surrogates, beyond U+10FFFF,
  truncation inside a character, a byte order mark.
* **Limits and long inputs**: nesting and token length bounded by the
  caller (`too deep`, `too long`); 20,000 tokens of which 10,000 numbers
  each ended by the symbol after it; a 20,000-symbol string token.
* **Unicode behavior**: unchanged -- RFC 8259's lone surrogate escapes are
  accepted by `json_string` and rejected by `json_string_strict`; decoding
  joins a surrogate pair and refuses a lone one (no lossy replacement).

The library facilities the exploration found missing (an Int scalar value
to UnicodeChar, strict UTF-8 decoding into a str, byte access to Bytes)
remain separate prerequisites of a complete JSON codec, not of recognition:
each is a native in both runtimes with a declared error (a surrogate or an
out-of-range value; malformed UTF-8), Compilerpedia notes and the stdlib
census -- a standard-library milestone of its own. Decoding returns scalar
values or UTF-8 bytes meanwhile; no validation was weakened.

## 12. YAML results

`examples/dfa/yaml/yaml_lex.bot` declares the exploration's YAML subset --
double-quoted scalars with every escape of YAML 1.2.2 section 5.7,
single-quoted scalars (`''` is a quote, so the closing quote needs one
symbol of lookahead), comments, flow indicators -- and the plain scalar of
one word in flow context (7.3.3) that the exploration could not declare:

* **ns-plain-first**: the first symbol is no indicator, or one of `- ? :`
  followed by a safe one;
* **ns-plain-char**: inside the scalar a `#` follows a non-blank symbol, so
  it is the scalar's; a `:` is the scalar's only when a safe symbol
  (ns-plain-safe: ns-char without flow indicators) follows it. A `:`
  followed by a blank, a line break, a flow indicator or the end is the
  mapping indicator, and the scalar ended before it -- **two symbols back**
  from the one that says so, one at the end of the input.

`yaml_plain_flow`'s `colon` state says exactly that: `white line_break
flow_indicator -> accept before 2`, `end -> accept before 1`, and the bound
check accepts it because every path to `colon` consumed at least two
symbols. `yaml_token` dispatches a token by its first symbol, reading a
`:`-led scalar itself (a call hands the callee the current symbol, and the
`:` would be behind it).

The results (`dfa-yaml-boundaries`, `dfa-yaml-plain-lookahead`):

| input | tokens |
|---|---|
| `{a:b, c: d}` | `{`, plain `a:b`, `,`, plain `c`, `:`, plain `d`, `}` |
| `a: ` | plain `a` (1 symbol, 2 unread), then `:` |
| `a:,` | plain `a`, `:`, `,` |
| `a:` (end) | plain `a` (1 unread), `:` |
| `a::b `, `a:: ` | plain `a::b`; plain `a:` then `:` |
| `x::y`, `:z`, `a:b:c` | one plain scalar each |
| `-: ` | plain `-`, then `:` |
| `- a` | rejected at the blank (a block entry is no flow scalar) |
| `"k":1` | double-quoted `"k"`, `:`, plain `1` (the driver's rule after a quoted key: ns-flow-map-adjacent-value) |

whatever the chunks (`dfa-yaml-chunks`: every split, so the two symbols a
scalar leaves unread are given back across chunk boundaries), with
comments, quoted scalars and line breaks between tokens
(`dfa-yaml-tokens`). The driver, `yaml.bot`'s `tokens`, buffers two
symbols: yaml_token's lookahead.

Out of the subset, by design and for stated reasons: block structure and
indentation (a stack of indentation levels), block scalars, multi-line
plain scalars, and plain scalars of several words -- `a  b` is one scalar
and `a  :` is not, and no fixed number of symbols tells them apart (the
blanks are unbounded), so a recognizer with bounded lookahead cannot end
that token; a parser can, by treating a blank run as a token of its own.
Bounded lookahead solves the problem milestone 1 found without becoming an
unrestricted parser.

## 13. Diagnostics and tooling

* **Compilerpedia** (`compilerpedia/topics/dfa.topic`): `concept.recognizers`
  -- the construct, deterministic transitions, explicit acceptance and
  implicit rejection, the end of the input against temporary suspension,
  unread counts and their bound, delegation, alphabets, what the
  guarantees do and do not cover, and how a recognizer is a coroutine
  that fusion compiles -- with an example that runs; and one `error.dfa-*`
  topic per diagnostic kind (17), each with a rejected example located
  where the compiler reports it. `tools/compilerpedia.tcl check` runs
  every example (809 topics, 606 examples, 0 problems).
* **Diagnostics** are structured entries (code, location, related
  locations: both transitions of an ambiguity, a class's declaration where
  a use fails, the declaration a later one duplicates) through the
  compiler's own facilities (DIAGNOSTIC-RECOVERY.md): every independent
  one reported in source order, none restating another, none from
  generated code. `tests/static-compile.test`'s census classifies the 17
  kinds (no `static compile:` block can produce them: a declaration is top
  level).
* **The compiler service** (`service::at`) answers, for a name in a
  declaration, from facts the checker recorded as it resolved
  (surface/dfa.tcl's `Fact`, carried by the HIR as `dfaNames`; the service
  resolves nothing itself): a **state** name (its declaration or a target)
  -- hover with the state's transitions as written, go to its declaration,
  its references; a **class** (declaration or use, another module's
  included) -- hover with its declaration, definition, references across
  files; a **called recognizer** -- hover with its alphabet, how much it
  can leave unread and its errors, definition in its module. A recognizer's
  own name is the binding of its coroutine function: hover shows its
  signature, and its calls from ordinary code are its references. The
  language server (lsp/) reaches all of it through `service::at`, adding
  nothing. Diagnostics carry their ranges and related ranges
  (`dfa-service-diagnostics`); a malformed declaration does not prevent
  the analysis of the rest of the file (syntax recovery, section 7).

## 14. Native code evidence

`audit/dfa/tools/evidence.tcl` compiles four workloads, fused and on the
general runtime, and keeps each consumer function's NIR, its machine code
(objdump of the program object) and fusion's report
(`audit/dfa/milestone-2/evidence/`; `summary.md` lists every helper each
one calls):

| workload | consumer | fused bytes | fused calls | general bytes | general calls | fusion inlined |
|---|---|---:|---:|---:|---:|---|
| utf8 | `validate_pattern` | 3,861 | 42 | 636 | 24 | utf8_text, utf8_char |
| lex | `json::lex_text` | 15,293 | 152 | 3,621 | 82 | json_token, json_string, json_escape, json_number, json_literal; the chunk source |
| validate-bytes | `json::validate_bytes` | 22,157 | 251 | 4,469 | 107 | json_token_bytes, json_string_bytes, json_escape, utf8_char, json_number, json_literal; the byte source; the structural coroutine |
| yaml | `yaml::tokens` | 28,541 | 225 | 6,085 | 110 | yaml_token, yaml_double_quoted, yaml_escape, yaml_comment, yaml_plain_flow, yaml_single_quoted; the chunk source |

What the code shows:

* **Every coroutine of every workload is fused** (`fused ... inlined`,
  no `kept`): a recognizer, the recognizers it calls (each a deep yield
  of its caller's chain) and the driver's own source coroutines. The fused
  consumers call no coroutine operation on the per-symbol path: their
  `rt_co_resume0` and `rt_co_failed` calls are fusion's cold paths (a
  resume after completion, a cached failure raised again), and the
  general variants' `rt_co_create`/`rt_co_resume`/`rt_closure_new`/
  `rt_struct_new` (a coroutine object, a resume message per symbol) are
  gone.
* **A transition is a table load or a branch, never a call.** No
  `dfa#transition` call survives native lowering
  (`dfa-lowering-native-dispatch`). The fused UTF-8 validator reads its
  transitions from two static byte tables: utf8_char's by `imul $0x101`
  (state times 257) and one `movzbq` from the table's payload (or the
  row's default for a symbol outside the byte range), utf8_text's, a
  recognizer of one state, by the `movzbq` alone. The lexer's 16 table
  loads serve its ascii rows (and json_token's, a unicode recognizer whose
  named symbols are all ASCII); json_string's rows name U+0080..U+10FFFF,
  so its transitions are NIR `switch`es on the state and then the symbol,
  sparse enough for codegen to emit balanced searches. YAML's recognizers are
  unicode with wide classes: 40 switches, three of them dense enough for
  `br_table` (`movslq (%rcx,%rax,4)` / `jmp *%rcx`).
* **Nothing is allocated per symbol.** The resume message is a fused
  register, the unread count an Int in a register; the fused lexer's
  allocations are the driver's cursor (a MutableArray of four counters)
  and its result -- 2 for 20,000 characters (section 15).
* **What remains per symbol** besides the load is the code dispatch
  after it (`if next < STATES ... `): an integer comparison materializes
  a tagged Bool (a `cmov`) that the branch then compares with true, a
  pattern Cranelift does not fold. That is the ordinary lowering of a
  comparison, shared with every program, not a recognizer cost: the
  hand-written json_number coroutine takes 3.8-3.9 ns per digit, the
  declared one 4.0-4.1 (section 15).
* **Fused code is larger than general code** -- a copy of the template
  per start and resume, as COROUTINE-FUSION-MILESTONE-1.md designed --
  but a third smaller than the prototype's for the same workload (the
  lexer's program 19.4 KB against 29.1 KB; the validator's 27.0 against
  37.1), because the template is a load and a code dispatch instead of a
  decision tree per state.

## 15. Performance

@@PERFORMANCE@@

## 16. Regressions

@@REGRESSIONS@@

## 17. Side findings

### Collecting loops

Still present. A `loop` is a collecting loop: its value is the List of its
body's last values. A source coroutine written naturally --

```
fn scalars(chunks: List[str]) -> int errors IndexNotFound:
    loop chunk in chunks:
        loop i from 0 to chunk.length():
            yield std::char::scalar_value(chunk.char_at(i))
    -1
```

-- builds the inner loop's List of yield results for every chunk and the
outer loop's List of those, and discards both: measured on 2,000 symbols in
two chunks, 8 allocations and 16,336 bytes against 2 and 96 with the
workaround (a `continue` as the outer body's last statement), fused or not,
and no warning. The examples keep the workaround, with its comment.

The narrow proof exists: a loop in statement position (not the last
expression of its block) has its value discarded by the language, and a
collecting loop whose List is an element of a discarded List is discarded
too. But a warning in this repository is a milestone of its own -- a
WARNINGS-*.md proof document, a Compilerpedia topic with its five sections,
a test file, a fuzzer, the warning gate over the corpus -- and the better
answer may not be a warning at all: lowering could simply not build a List
whose value is discarded (an immutable List has no identity, so eliding it
changes no behavior; it needs no escape analysis, only the statement
position). **Recorded as a separate milestone**, with this measurement and
both options; loop semantics are unchanged here.

### Method-call resolution

Generated recognizer functions are `nomethod` and named with a `#`: they
are never method candidates, and with the compact lowering a module of
recognizers adds a few functions, not thousands of lines. The cost the
exploration saw has a second, general cause, measured on json.bot (the
drivers module): its warm front end takes 2.45 s, of which 20 ms is
checking and lowering the recognizers and the rest two whole-program
builds of about 0.95 s -- one of them the method-call decision's
certificate build (`hir::buildStats`: builds 2, methodTrials 1). The same
module written with function-call syntax takes 1.41 s (builds 1). So a
program that uses method syntax pays one extra whole-program build, about
70% here, whatever its recognizers -- and the warning gate asks examples
for method syntax (METHOD-ELIGIBLE), so a warning-clean program pays it.
That deserves a **separate compiler milestone** (certifying the kind
filter's decisions in the final build rather than in a trial build, or
reusing the trial build's analyses); it was not worked around here, and
the measurements include it.

### Always-failing functions (KNOWN-ERROR)

An actual semantic rule, not an overzealous diagnostic: a call that can
never complete normally is rejected even under a handler
(STATIC-COMPLETION-PROOFS.md; Compilerpedia `rule.known-error`: "a
statically known failure is a mistake, not a branch"). A helper whose every
path fails (`fn reject(r, s, c) -> int errors UnrecognizedInput: fail ...`)
is therefore uncallable: every call of it is KNOWN-ERROR, whatever the
branch around it. The recognizers do not need one -- the lowering writes
each rejection as an inline `fail` in the code dispatch -- and by_hand.bot
writes its rejections where they happen. A narrowly justified correction
for ordinary code would be to let a function *declare* that it never
returns (a `-> never` result the checker proves), so that calling it is a
statement of intent rather than an accident; it is not part of this
milestone.

## 18. Next steps

* **Interprocedural fusion** is the one dependency that limits
  composition: a recognizer factory, a buffered-source helper and a
  generic driver all pass a handle across a call and fall back to the
  general runtime (section 15's factory row). When fusion can follow a
  handle into a callee, the buffer becomes a library helper and one driver
  serves every recognizer -- no change to recognizers is needed.
* **The Unicode library facilities** (an Int to UnicodeChar with its
  declared error, strict UTF-8 decoding into a str, byte access to Bytes):
  a standard-library milestone; then json.bot's decoder can return a str.
* **The interpreter's depth** goes away with the bytecode VM; nothing in
  the recognizers depends on it.
* **The emitter experiment.** A declaration now states, statically, the
  language of a token: its states, its symbol sets, where it ends and what
  it may leave unread. That is the knowledge an emitter needs to construct
  valid output -- choose a path through the states and a symbol from each
  set -- and to prove a value's text belongs to the language (a printed
  number is a `json_number` token). The extension points are the effective
  table (surface/dfa.tcl's model, exported per recognizer with its bound
  and errors), the codes (one per outcome) and the facts the compiler
  service already carries. Recommended first experiment: generate, from a
  declaration, the shortest accepted token of each state (a breadth-first
  walk of the effective table, as tests/dfa-support.tcl's frontier does)
  and check an ordinary formatting function's output against the
  recognizer -- recognition used as the oracle of emission -- before
  designing any bidirectional syntax. The declaration model needs no change
  for that; a grammar language that both parses and prints would, and is
  not proposed.
