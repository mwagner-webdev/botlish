# DFA-COROUTINE-EXPLORATION.md

Exploratory milestone 1 of declarative finite-state recognition in Botlish:
a deterministic finite automaton declared as such, statically checked, and
executed as an ordinary Botlish coroutine. JSON (RFC 8259) is the primary
workload; a scoped subset of YAML 1.2.2 is the stress test.

> A DFA is a statically verifiable recognizer whose execution semantics are
> those of an ordinary Botlish coroutine. The declaration states the valid
> transitions and the recognition boundaries; coroutines provide
> suspension, resumption, completion, errors, ownership and composition;
> coroutine fusion makes the result an ordinary native state machine where
> it can prove that safe.

The question this milestone answers: **what is the smallest declarative
addition that makes protocol recognition substantially more reliable than
ordinary coroutine code, without sacrificing its expressiveness,
composability or performance?**

The short answer, from the evidence below: a declaration of states and
symbol-set transitions -- consume and continue, accept, accept before the
symbol, accept or reject at the end of the input, delegate to an earlier
recognizer -- lowered before HIR to one ordinary coroutine function, with
one message type and two standard errors. That is enough to rule out every
structural mistake the census planted (13 of 13, at compile time) and to
compile to fused native code that allocates nothing per symbol: the
declared UTF-8 validator is faster than the hand-written coroutine and
procedural ones, and the declared JSON lexer, which recognizes all of RFC
8259's lexical grammar, runs within about 1.2 times the fusion milestone's
hand-written tokenizer of a subset of it. It is not yet ready to be made
permanent: its generated code costs more than twice the front-end time
of the hand-written equivalent and fused consumers of 25-35 KB of machine
code, a recognizer can leave only one symbol unread (YAML needs two), and
nothing in Botlish lets one driver be parameterized by a recognizer
without leaving fusion. Section 15 recommends **revise, then integrate**
-- and says what to revise.

## Contents

1. [Result](#1-result)
2. [Design alternatives](#2-design-alternatives)
3. [Chosen model](#3-chosen-model)
4. [Static guarantees](#4-static-guarantees)
5. [Coroutine correspondence](#5-coroutine-correspondence)
6. [Input protocol](#6-input-protocol)
7. [JSON implementation](#7-json-implementation)
8. [Composition](#8-composition)
9. [Unicode findings](#9-unicode-findings)
10. [Correctness](#10-correctness)
11. [Native evidence](#11-native-evidence)
12. [Performance](#12-performance)
13. [YAML findings](#13-yaml-findings)
14. [Language impact](#14-language-impact)
15. [Recommendation](#15-recommendation)
16. [Files](#16-files)

## 1. Result

**Implemented** (all under `audit/dfa/`, an isolated prototype: nothing in
`core/`, `hir/`, `surface/`, `compiler/` or `native/` loads it, and
`tests/local.tcl` and CI do not run it):

* **The DFA front end** (`audit/dfa/tools/dfa.tcl`, about 1,700 lines of
  Tcl). A `.dfa` file is an ordinary Botlish module with two more kinds of
  top-level declaration, `class` and `dfa`; the front end checks every
  declaration, reports every independent problem as a structured
  diagnostic in the compiler's own representation
  (`core::raiseDiagnostics` entries with `location` and `related` spans,
  `CORE SEMANTIC DFA-...` codes), and replaces each `dfa` by ordinary
  Botlish: one coroutine function and one helper. Everything else passes
  through. The generated module is committed and checked to be current,
  like the C binding generator's output.
* **Static checks** (section 4): determinism (disjoint symbol sets per
  state, exact interval arithmetic over the alphabet), defined rejection
  (every symbol a state does not list, and every value outside the
  alphabet, fails with a standard error), explicit acceptance, progress
  (no cycle of non-consuming moves any symbol can take), finite control
  (no recursion among recognizers), the end of the input (a state that
  ends a token before a symbol must say what the end means), alphabet
  discipline (bytes are not characters), reachability, acceptance from
  every reachable state, and non-consuming transitions that can only
  reject. Seventeen diagnostic codes.
* **The lowering** (section 5): a recognizer is an ordinary coroutine
  function `NAME(first: int, resume dfa::Symbol) -> bool` whose only
  operations are comparisons, one `yield`, a self tail call, `return` and
  `fail`. It inherits every property of COROUTINES.md unchanged and fuses
  (COROUTINE-FUSION-MILESTONE-1.md) where its handle stays in one function.
  No new runtime, scheduler, HIR node, native operation or ownership rule.
* **JSON** (section 7): RFC 8259's whole lexical grammar in 162 lines of
  declarations (`json_lex.dfa`: numbers, the three literals, strings with
  every escape, punctuation, UTF-8 over bytes, an I-JSON strict variant
  that rejects unpaired surrogate escapes), a lexer over chunked input, a
  structural validator with an explicit bounded stack, and a decoder of
  string tokens that pairs surrogates and refuses unpaired ones.
* **YAML** (section 13): double- and single-quoted scalars, comments, and
  a counterexample -- the flow plain scalar -- that a recognizer leaving
  one symbol unread cannot get right.
* **Evidence**: 47 tests in three files (front end, JSON, YAML); a
  simulator of the declarations that checks the generated code on five
  backends (1,558 model-based cases for JSON alone); JSONTestSuite (318
  files) and 24,000 generated cases against CPython's `json` made strict;
  a census of 30 realistic mistakes; native evidence and a benchmark.

**Measured**: see sections 10-12. In brief: every JSONTestSuite `y_` file
accepted and every `n_` file rejected, no disagreement with the oracle in
24,318 cases, the same verdict for every chunking; fused recognizers
allocate nothing per symbol and make no coroutine switch; the declared
UTF-8 validator is the fastest of the three validators measured; the
declared JSON lexer is 5 times faster than the imperative probe and within
about 1.2 times the hand-written coroutine tokenizer. (It was 3.7 times
slower until a nested collecting loop in the drivers' source coroutine --
ordinary Botlish, not the DFA -- was found to build a List of every
symbol's yield: section 12.)

**Not achieved, and why** (sections 8, 12, 13):

* *Token kinds.* A recognizer answers only "accepted, last symbol taken or
  not"; the driver learns a token's kind from its first symbol. A
  recognizer that classifies (integer or fraction) would need accept
  labels, which the protocol has no room for without a sum type.
* *Lookahead beyond one symbol.* `accept before` leaves the current symbol
  unread; YAML's `a: b` needs the scalar to end two symbols back.
* *Actions.* A recognizer computes nothing but its verdict: decoding a
  string is a second pass over the recognized token, in ordinary code.
* *One driver for any recognizer.* Expressible (a factory returning the
  started handle), but the handle then leaves its function and fusion
  keeps the general runtime for every token's recognizer (sections 8
  and 12).
* *Compile time and code size.* The generated decision trees are large
  NIR (more than twice the front-end time of the same recognizer written
  by hand), and fusion copies them per start and resume (section 12).
* *The reference interpreter* has no tail calls: one symbol is one nested
  call there, so a token is bounded by its evaluation depth (3,000 symbols
  ran, 20,000 did not), exactly as for the imperative probe (section 10).

## 2. Design alternatives

Three surfaces, the same recognizer: a JSON number token (RFC 8259 section
6) that ends at a symbol that may follow a value, or at the end of the
input.

### A. Restricted coroutine declarations

An ordinary coroutine function, marked as a recognizer, whose body the
compiler reads as a graph. Botlish has no mutable variables, so the natural
style keeps the state in the suspension point and factors repeated parts
into helpers that yield themselves -- exactly what the fusion milestone's
`tokens.bot` does. `audit/dfa/json/by_hand.bot` is that style written
correctly (it agrees with the declaration on every model case, section 10);
under a hypothetical `recognizer fn` marker:

```botlish
recognizer fn number_by_hand(first: int, resume dfa::Symbol) -> bool errors dfa::UnrecognizedInput, dfa::UnexpectedEnd:
    lead = if first == 45:
        next()
    else:
        first
    if lead == -1:
        fail dfa::UnexpectedEnd {state: "by_hand.start"}
    if not digit?(lead):
        fail dfa::UnrecognizedInput {state: "by_hand.start", symbol: lead}
    after = if lead == 48:
        next()
    else:
        digits()
    if after == 46:
        return fraction()
    if after == 101 or after == 69:
        return exponent()
    ends("by_hand.integer", after)
```

plus `next`, `digits`, `ends`, `exponent` and `fraction` (65 lines without
comments). What a compiler could check: that the body uses only the
fragment (comparisons of the symbol, yields, calls of other recognizer
helpers, `return`, `fail`), that no `if` without `else` falls through on a
symbol, that no branch is shadowed by earlier ones (code is deterministic
by evaluation order, so the code analogue of an ambiguous transition is a
branch that can never be taken), and that every path reaches a yield, a
return or a fail. Every such check would be a statement about *code
paths*: the range analysis can recover the partition each `if` chain makes
(hir::range already proves comparisons), but the diagnostic would point
at a branch and explain it through the conditions before it.

Assessment. Compact and composable (it *is* ordinary code), no second
language. But the guarantees are weak where it matters: the state is
implicit (there is no table to read, review or test against), a marker
would change what `if` means (an `if` without `else` would have to reject
rather than fall through), and the hazards are still written by hand --
by_hand.bot spells out two `fail`s at every point that rejects, because a
function that always fails cannot be called (`KNOWN-ERROR`), and a symbol
missing from `after_value?` is a silent rejection of valid input, not a
diagnostic.

### B. Declarative DFA blocks (the prototype)

```
class digit = '0'..'9'
class nonzero = '1'..'9'
class after_value = ' ' '\t' '\n' '\r' ',' ']' '}'

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
    integer:
        digit -> integer
        '.' -> point
        'e' 'E' -> exponent
        after_value -> accept before
        end -> accept
    point:
        digit -> fraction
    fraction:
        digit -> fraction
        'e' 'E' -> exponent
        after_value -> accept before
        end -> accept
    exponent:
        '+' '-' -> exponent_sign
        digit -> exponent_digits
    exponent_sign:
        digit -> exponent_digits
    exponent_digits:
        digit -> exponent_digits
        after_value -> accept before
        end -> accept
```

(The recognizer is 35 lines: RFC 8259's grammar, line by line.) States,
symbol sets and transitions are data; their order means nothing, so
determinism is a property the compiler checks rather than an artifact of
evaluation order; what is not listed is rejected; acceptance is written
where it happens.

Assessment. Readable as a table, reviewable against a grammar, checkable,
and lowered to the code A would have written. A second, small language
(about a dozen contextual words), not a lexer generator: no regular
expressions, no actions, no longest match, no priorities.

### C. Library-oriented construction

A table as a value, run by a library coroutine:

```botlish
number = std::dfa::machine("start", [
    std::dfa::state("start", [std::dfa::on([45], "minus"), std::dfa::on([48], "zero"), std::dfa::range(49, 57, "integer")]),
    std::dfa::state("minus", [std::dfa::on([48], "zero"), std::dfa::range(49, 57, "integer")]),
    ...
])
coroutine {step, first} = std::dfa::run(number, c)
```

Assessment. No syntax at all. But Botlish evaluates nothing at compile time
(`static compile:` decides whether syntax compiles; it evaluates no
expression), so every check -- overlap, unknown state names (strings),
reachability, progress -- would run when the table is built, at run time:
a malformed table is a failure in production, not a diagnostic. The run is
an interpreter of the table: per symbol a lookup in a value the compiler
cannot see through (fusion would fuse the interpreter loop, not the
automaton), and a module-level table is a value initializer with its own
cost. It gives the least knowledge to the compiler of the three, which is
the opposite of this milestone's aim.

### Against the criteria

| criterion | A: restricted coroutine | B: `dfa` block | C: library table |
|---|---|---|---|
| compact, readable ordinary programs | the program *is* the recognizer; state implicit | a table beside the code; the code that uses it is ordinary | lists of calls; names as strings |
| little type machinery | none | none (one message struct, two errors) | a table type |
| compile-time reasoning without a secondary language | a fragment of the language, path-sensitive | a small declarative language, symbol-set arithmetic | none: run time |
| static checking with actual guarantees | shadowed branches, fall-through; no progress or acceptance guarantee without restricting loops and calls | determinism, defined rejection, acceptance, progress, finite control, boundaries (section 4) | none statically |
| composition with functions and coroutines | ordinary | `call` within declarations; the result is an ordinary coroutine | through the library's run coroutine |
| text and binary with one abstraction | yes | yes: `over bytes`, `over unicode`, `over ascii` | yes |
| no implicit authority or runtime machinery | yes | yes: lowered to ordinary code | an interpreter at run time |
| clear diagnostic locations | at code paths | at the transition, with the symbols | none |

B is the only one whose guarantees do not depend on how the code happens to
be written, and the only one that gives the compiler a table it can both
check and lower freely (section 5: the search order is the lowering's
choice because the declaration proved the sets disjoint). The prototype is
B.

## 3. Chosen model

### Why a front-end stage, not the parser (yet)

The prototype checks and lowers declarations *before* the compiler sees
the file and hands it ordinary Botlish, the way `tools/c-bindgen.tcl`
generates ordinary bindings. That keeps the compiler unchanged and keeps
the syntax provisional: putting `dfa` in `surface/parser.tcl`, even gated,
would make it a front-end input (the HIR cache key, the interchange
fingerprint), add seventeen codes to the static-compile census and require a
Compilerpedia topic for each, for a construct this report does not yet
recommend shipping as it is. Nothing the experiment measures depends on
where the lowering runs: the compiler compiles exactly the code a
surface-level lowering would produce. What it does lose -- the compiler
service and the language server do not see `.dfa` files; a compile error
in passthrough code points into the generated file -- is what integration
would add (section 14).

### The language

```
class NAME = ITEMS [except ITEMS]               -- top level, or first in a dfa
dfa NAME over ALPHABET:                          -- bytes | unicode | ascii
    class NAME = ITEMS [except ITEMS]
    STATE:                                       -- the first state starts
        ITEMS -> STATE                           -- consume, continue
        ITEMS -> accept                          -- consume, complete
        ITEMS -> accept before                   -- leave unread, complete
        ITEMS -> reject                          -- reject (explicitly)
        ITEMS -> call DFA then STATE             -- delegate, then continue
        ITEMS -> call DFA then accept            -- delegate, and complete with it
        ITEMS => STATE                           -- reconsider in STATE
ITEMS = ITEM { [","] ITEM }
ITEM  = 'c' | 'c'..'d' | N | N..M | CLASS | any | end | "sequence"
```

* **Alphabets.** `bytes` is 0..255; `unicode` is the Unicode scalar values
  (0..0x10FFFF without the surrogates U+D800..U+DFFF, which a Botlish
  `UnicodeChar` can never be); `ascii` is 0..127, whose symbols mean the
  same in both, so an `ascii` recognizer can be called from either (JSON's
  numbers, literals and escapes are shared by the byte and the text
  lexers). A range that spans the surrogate gap means its scalar values
  (`0x5D..0x10FFFF`, RFC 8259's `unescaped`, is written as the RFC writes
  it); a symbol or range wholly outside the alphabet is an error, and a
  non-ASCII character literal in a bytes recognizer is an error of its own
  (`'é'` is two UTF-8 code units, not a byte). Grapheme clusters are never
  symbols.
* **`end`** is the end of the input. It is not a symbol of any alphabet,
  cannot be consumed (`end -> STATE` is an error), and may accept, reject
  or be reconsidered.
* **Classes** are symbol sets: items, minus `except` items, defined before
  use (Botlish's own rule), possibly `any` (the alphabet).
* **Sequences** (`"true" -> word_end`) are sugar for a chain of anonymous
  states, one per symbol; the keywords of a grammar read as they are
  written.
* **Calls** hand the current symbol to an earlier recognizer and wait for
  it to complete; `then STATE` continues (reconsidering the callee's
  unread symbol, if it left one), `then accept` completes with it. Only
  earlier recognizers can be called, so no call recurs.
* **No actions.** A transition computes nothing. What a recognizer
  produces is its verdict, and where the token ends.

## 4. Static guarantees

### The model

A recognizer is (Σ, Q, q0, δ): Σ its alphabet, Q its declared states (and
the anonymous states of its sequences), q0 the first, δ(q, s) the action of
state q on s, for **every integer s** (a symbol, the end -1, or any other
value a caller sends). The front end computes δ exactly from the
declaration: symbol sets are finite unions of intervals, and every set
operation is exact interval arithmetic.

### What the front end proves of every recognizer it accepts

| property | statement | how |
|---|---|---|
| **Determinism** | in every state, the written transitions claim pairwise disjoint symbol sets: at most one applies to any symbol | interval intersection of every pair (`DFA-AMBIGUOUS-TRANSITION`, with the overlapping symbols and both transitions) |
| **Defined rejection** | δ is total: every integer maps to exactly one action; a symbol no transition takes, and every value outside the alphabet, fails `dfa::UnrecognizedInput {state, symbol}`; the end where no transition takes it fails `dfa::UnexpectedEnd {state}` | the unclaimed remainder of the whole integer line is an explicit rejection in the effective table; the lowering's search covers the whole line |
| **Explicit acceptance** | the generated function completes normally only through an `accept`, `accept before` or `end -> accept` transition (directly, or through a call that does); reaching a state accepts nothing | the lowering's only normal exits are those codes |
| **Progress** | each segment of the coroutine (its construction, each resume) consumes the symbol it was handed, or completes, or fails: no symbol can make a cycle of non-consuming moves (`=>`, and calls whose callee completes before the symbol) | the effective table follows every non-consuming move per symbol subset and reports a revisit (`DFA-NONPROGRESSING-CYCLE`, with the cycle and its symbols); a cycle that no single symbol can take is no cycle |
| **Finite control** | the recognizer's whole state is a state number and the position in an acyclic call chain: bounded by the number of states times the depth of the call graph; its memory is constant; each symbol costs one search over its state's table | only earlier recognizers are called (`DFA-RECURSIVE-CALL`, `DFA-UNKNOWN-DFA`); non-consuming moves are resolved at compile time; no action computes anything |
| **The end of the input** | a state that can complete before a symbol says what the end means there | `DFA-MISSING-END` unless the state lists `end` |
| **Alphabet discipline** | written symbols are in the alphabet; bytes and characters are not confused; a callee reads the caller's symbols with the same meaning | `DFA-ALPHABET`, `DFA-BYTE-CHARACTER`, `DFA-CALL-ALPHABET` |

and three properties that are not guarantees about the language but about
the declaration's integrity, reported as errors:

| code | what | why an error |
|---|---|---|
| `DFA-UNREACHABLE-STATE` | no transition from the start leads to the state | in a declaration, an unreachable state specifies nothing; in the census, forgetting every transition into the exponent was caught only this way |
| `DFA-NO-ACCEPT` | a reachable state from which every path ends in a rejection (the start: the recognizer accepts nothing) | it is equivalent to omitting the state; a forgotten closing quote is exactly this |
| `DFA-DEAD-TRANSITION` | a non-consuming transition (`=>`, a call) whose every symbol its target rejects at once | it is equivalent to omitting it |

Is an unreachable state ever harmless? In a code module, an unused function
is ordinary (Botlish does not reject one). In a declaration whose every
state is a node of one graph, the prototype found none: the cases where a
state is legitimately unused (a variant under construction) are better
served by not declaring it. A partial dead transition -- `'0'..'9' =>
digits` where `digits` takes only `'1'..'9'` -- is *not* reported: its
other symbols are meaningful, and the rejection of `'0'` is defined. The
three could be warnings instead (Botlish's warnings are backed by proofs,
and these are exact); they are errors here because a declaration has no
reason to contain them.

### Diagnostics

Every independent diagnostic is reported (DIAGNOSTIC-RECOVERY.md's rule),
in source order, and none restates another: a recognizer whose transitions
do not resolve (a bad symbol, an unknown name) is not analyzed further, a
recognizer that calls one with diagnostics is not analyzed at all, and a
state whose only way forward is a reported cycle is not also reported as
never accepting. For

```
class digit = '0'..'9'
class after_value = ' ' ',' ']' '}'

dfa number over ascii:
    start:
        '-' -> minus
        '0' -> zero
        digit -> integer
    ...
```

the front end reports

```
number.dfa:8:9: two transitions of state start in number claim '0': a recognizer takes at most one transition per symbol
    '0' -> zero (number.dfa:7:9)
    digit -> integer (number.dfa:8:9) (DFA-AMBIGUOUS-TRANSITION)
```

and, once that is fixed (`'1'..'9' -> integer`), the rest of the same
draft:

```
number.dfa:11:5: state zero of number accepts before a symbol but does not say what the end of the input means: write "end -> accept" (the input may end here) or "end -> reject" (DFA-MISSING-END)
number.dfa:15:9: number can move without consuming forever: on '.' it goes integer => integer and never takes a symbol, accepts or rejects (DFA-NONPROGRESSING-CYCLE)
number.dfa:18:5: state fraction of number is never reached: no transition from the start state leads to it (DFA-UNREACHABLE-STATE)
```

The draft has a fourth mistake no check reports: `minus: digit ->
integer` accepts `-01`. That is the scope of the guarantees.

### What the guarantees catch: the mistake census

`audit/dfa/tools/mistakes.tcl` applies each of 30 realistic mistakes
(`mistakes.txt`) to `json_lex.dfa` alone. If the front end reports a
diagnostic, it is caught statically; otherwise the mutated lexer is built
and run against JSONTestSuite and 3,000 generated cases with the strict
oracle (section 10). `audit/dfa/results/mistakes.md` has every row; by
kind:

| kind | mistakes | caught statically | caught by the tests | survived |
|---|---:|---:|---:|---:|
| structure: overlaps, unreachable or never-accepting states, typos, dead or recursive delegation | 8 | 8 | -- | 0 |
| boundary: the end forgotten or consumed | 2 | 2 | -- | 0 |
| progress: a non-consuming cycle | 1 | 1 | -- | 0 |
| alphabet: a character for a byte, a unicode callee of a bytes recognizer | 2 | 2 | -- | 0 |
| grammar: a well-formed automaton for the wrong language | 17 | 0 | 15 | 2 |

The two survivors are equivalent at the level the census measures:
`no-boundary` (a number may be followed by anything) changes where a bad
document is rejected -- the next token's recognizer or the structural
layer rejects what the number's boundary used to -- but not whether, so the
document-level differential cannot see it; json.test's token-level
`json-boundaries` does (`123abc` is then a number followed by an
unrecognized symbol, not an unrecognized number). `utf8-lead-c0` (the
overlong leads C0 and C1 accepted by `utf8_char`) is masked by every
caller, which hands `utf8_char` only C2..F4.

So: **every mistake in the structure of the declaration was a compile-time
diagnostic, and no mistake in the grammar was** -- as designed. A
deterministic, well-defined recognizer can implement the wrong language;
the conformance corpus and the differential fuzzer found 15 of the 17
grammar mistakes (several only once the harness exercised the unicode
lexer and injected UTF-8 edge sequences, both added after the first census
run left four survivors). The same mistakes in by_hand.bot's ordinary
coroutine code would all be grammar mistakes in this sense: nothing about
an ambiguous branch, a missing end, a fall-through or a cycle is visible
to the compiler there.

### The scope of the guarantee

* It is about the declaration and the code generated from it. The
  generator is a trusted component of the prototype; its output is tested
  against a simulator of the declarations (section 10), not proved.
* It says nothing about the code that drives a recognizer: the drivers,
  the structural validator and the decoder are ordinary Botlish with
  ordinary guarantees.
* It does not include resource limits: a recognizer uses constant memory
  whatever it reads, but how long a token may be, or how deep a document,
  is the caller's policy (section 7).

## 5. Coroutine correspondence

A recognizer is an ordinary coroutine function; nothing about it is
special at run time.

| recognition | coroutine | as lowered |
|---|---|---|
| the first symbol | the construction's argument | `coroutine {step, first} = json_lex::json_number(c)` runs the start state on `c` |
| a symbol taken, more needed | a `yield` | `m = yield true`: suspend; the resume's message is the next symbol |
| the next symbol | a resume with one `dfa::Symbol` | `step(dfa::Symbol {code: c})` |
| accepted | the root's `return` | `true` (the last symbol is part of the token) or `false` (it is not: the caller still holds it) |
| rejected | an unhandled `fail` | `dfa::UnrecognizedInput {state, symbol}`, `dfa::UnexpectedEnd {state}` |
| finished? | `std::coroutine::done?` | true once accepted or rejected |
| after the end | the stable terminal result or error | a later resume returns the same verdict, or raises the same error, and runs nothing |
| abandoned | release at the last use, or on an early exit | a driver that stops early (an error elsewhere) releases the recognizer like any coroutine |
| delegation | a deep yield through an ordinary call | `-> call json_escape then body` is a call of json_escape's run function inside json_string's: its yields suspend the whole coroutine |

There is no `NeedMore`, `Accepted` or `Rejected`: suspension, return and
failure already distinguish them. There is no `yieldto`: delegation is an
ordinary call (section 8).

### The lowering

`json_lex.dfa`'s `json_string_bytes` becomes (`json_lex.bot`; the
generator also writes the effective table as a comment above each
recognizer):

```botlish
fn dfa_json_string_bytes(state: int, c: int, resume dfa::Symbol) -> int errors dfa::UnrecognizedInput, dfa::UnexpectedEnd:
    next = if state < 1:
        if c < 34:
            3
        else:
            if c < 35:
                1
            else:
                3
    else:
        if c < 92:
            if c < 34:
                if c < 32:
                    4
                else:
                    1
            else:
                if c < 35:
                    2
                else:
                    1
        else:
            ...
    target = if next < 2:
        next
    else:
        if next == 2:
            return -2
        elif next == 4:
            dfa_json_escape(0, c)
            1
        elif next == 5:
            dfa_utf8_char(0, c)
            1
        else:
            if c == -1:
                fail dfa::UnexpectedEnd {state: dfa_json_string_bytes_state(next)}
            fail dfa::UnrecognizedInput {state: dfa_json_string_bytes_state(next), symbol: c}
    m = yield true
    dfa_json_string_bytes(target, m.code)

fn json_string_bytes(first: int, resume dfa::Symbol) -> bool errors dfa::UnrecognizedInput, dfa::UnexpectedEnd:
    dfa_json_string_bytes(0, first) == -2
```

Every choice in it was made for a measured reason:

* **The state is an integer parameter and the next state a self tail
  call.** Botlish has no mutable variable, and a function per state would
  need mutual recursion (no forward references) and would be recursive
  (which fusion refuses). A self tail call is a NIR `tail`: a loop, which
  fusion inlines as a loop.
* **One suspension point.** Every consuming transition reaches the same
  `yield`. A fused resume branches on which yield the coroutine is
  suspended at, one comparison per yield (COROUTINE-FUSION-MILESTONE-1.md
  4.2); a yield per transition would make that linear in the transitions.
* **A balanced search, in any order.** The declaration proved the sets
  disjoint, so the lowering is free to test them in the order of a search
  tree: log2 of a state's segments per symbol, log2 of the states for the
  state.
* **Leaves are integer codes; each call is written once.** A state number,
  accept, accept-before, a call, or a rejection; calls and rejections are
  handled after the search. A call written at each of its leaves was
  inlined by fusion once per leaf (json_token's template shrank from 6,387
  to 3,486 NIR instructions).
* **The run function returns an Int; the outward value is a Bool.** -2
  when the last symbol was taken, else the unread symbol. The first
  version returned a two-field struct from every run, and a call returned
  it across a function boundary: native lowering materialized it before
  fusion could replace it, one allocation per delegated token (600 per
  2,000 bytes of UTF-8). The Int costs nothing; and since every yield of a
  recognizer means "taken", its outward value is a plain Bool -- which also
  removed the placeholder a struct-valued yield had to carry (a coroutine's
  yields and return share one type: COROUTINES.md 19).
* **A rejection is raised by the recognizer.** The state's name comes from
  a small non-yielding helper; the `fail` is in the recognizer, because a
  function that always fails cannot be called (`KNOWN-ERROR`: a
  statically known failure is illegal even when handled).

## 6. Input protocol

* **Symbols** are Ints: a byte, a scalar value or an ASCII code, as the
  alphabet says. The message is `dfa::Symbol {code: int}` (a protocol is
  a struct: COROUTINES.md 13); fusion passes it as a register.
* **The end of the input is -1**, sent explicitly. A chunk boundary is not
  the end: a driver sends the symbols of every chunk and -1 once, at the
  real end. -1 is outside every alphabet, and so is any other value a
  caller might send by mistake: -2, 256 to a bytes recognizer, 0xD800 to
  a unicode one -- each fails `UnrecognizedInput`, never anything else.
* **The first symbol is the construction's argument.** A one-symbol token
  (`,`) completes during the construction (`done?` is true at once:
  COROUTINES.md 17); a token that rejects its first symbol fails there.
* **Chunk boundaries** are invisible to a recognizer: it is resumed once
  per symbol, so where the chunks split is the driver's business. json.bot
  reads its chunks through a source coroutine (`scalars`, `bytes`) whose
  final result, -1, is stable: every resume after the end answers the
  end.
* **Delimiter ownership.** A token that ends at a symbol of its own (a
  string's closing quote, punctuation) completes with `true`: the symbol
  is the token's. A token that ends only at the first symbol after it (a
  number, a literal) completes with `false`: the symbol was never
  consumed, and the driver -- which sent it and still holds it -- hands it
  to the next token. Nothing is pushed back and nothing is read twice; the
  rule is one symbol, deterministic, and stated by the declaration (`accept
  before`).
* **Bounded lookahead of one symbol.** That is also the protocol's limit:
  a token that can only be known to have ended two symbols ago cannot be
  declared (section 13).

## 7. JSON implementation

### Lexical recognizers (`audit/dfa/json/json_lex.dfa`)

| recognizer | over | from RFC 8259 | states |
|---|---|---|---:|
| `json_number` | ascii | number, section 6 | 9 |
| `json_literal` | ascii | `true` `false` `null`, section 3 | 12 |
| `json_escape` | ascii | escape, section 7 | 6 |
| `json_string` | unicode | string, section 7 (`unescaped` = %x20-21 / %x23-5B / %x5D-10FFFF) | 2 |
| `utf8_char` | bytes | one UTF-8 character after its lead byte (RFC 3629, section 4) | 8 |
| `json_string_bytes` | bytes | the string over UTF-8 (section 8.1) | 2 |
| `utf8_text` | bytes | valid UTF-8 as a whole | 1 |
| `json_token`, `json_token_bytes` | unicode, bytes | one token: a dispatcher | 1 |
| `json_escape_strict`, `json_string_strict` | ascii, unicode | strings without unpaired surrogate escapes (RFC 7493, 2.1) | 15, 2 |

The UTF-8 recognizer is RFC 3629's table, row for row:

```
dfa utf8_char over bytes:
    lead:
        0xC2..0xDF -> tail1
        0xE0 -> e0
        0xE1..0xEC 0xEE..0xEF -> tail2
        0xED -> ed
        0xF0 -> f0
        0xF1..0xF3 -> tail3
        0xF4 -> f4
    e0:
        0xA0..0xBF -> tail1
    ed:
        0x80..0x9F -> tail1
    f0:
        0x90..0xBF -> tail2
    f4:
        0x80..0x8F -> tail2
    tail3:
        0x80..0xBF -> tail2
    tail2:
        0x80..0xBF -> tail1
    tail1:
        0x80..0xBF -> accept
```

**Token boundaries.** A number or literal ends at a symbol of
FOLLOW(value) -- whitespace, `,`, `]`, `}` -- or at the end, and is
rejected at any other continuation: `01` fails at the `1` (state
`json_number.zero`), `1.2.3` at the second `.` (`json_number.fraction`),
`123abc` at the `a`, `truex` at the `x`, `{1:2}` at the `:` -- never "a
token followed by another". `123,` is accepted with the `,` unread;
`-0.25e+3]` with the `]` unread; `1e+` and `1.` at the end are
`UnexpectedEnd` in `json_number.exponent_sign` and `json_number.point`.
(json.test's `json-boundaries` pins each.) The boundary is defense in
depth for a document: the structural layer would reject `1 2` anyway; it
is what makes the token recognizer correct on its own.

### Structure (`audit/dfa/json/json.bot`)

JSON nests, so a document is not a regular language: no finite automaton
recognizes it, and the prototype does not pretend one does. The
structural validator is an ordinary coroutine fed one token per resume,
whose control state is an explicit stack of what the document expects next
(a value, `,` or `]`, a key, `:`, `,` or `}`, the end): RFC 8259's
`JSON-text = ws value ws` as a pushdown automaton, bounded by `max_depth`
(when a container opens, the stack holds one entry per open container
above the document's end).
Trailing commas, missing separators, several top-level values, trailing
content and an empty document are structural errors at the token that
breaks the grammar, with what it expected.

### Drivers

`validate_text` (a str in chunks), `validate_bytes` (UTF-8 bytes in
chunks), `validate_scalars` (scalar values) and `lex_text` (tokens only)
run a source coroutine, one recognizer per token and the structural
coroutine from one function, which keeps every handle in it so that all of
them fuse. They also hold the limits: `max_token` (a token's symbols) and
`max_depth`. Four drivers that differ in one line each, because a driver
cannot be handed its source or its recognizer (section 8).

### Decoding

`decode_text` and `decode_bytes` turn one recognized string token into
its value: the scalar values, or the UTF-8 bytes (raw bytes are already
validated UTF-8; an escape is encoded). An escaped surrogate pair is one
scalar; an unpaired surrogate escape fails `UnpairedSurrogate {at}` --
never a silent U+FFFD. RFC 8259 allows such an escape syntactically
(section 8.2), so the default recognizer accepts it and the decoder is
where it fails; `json_string_strict` rejects it lexically, for I-JSON.
Neither decoder can produce a str (section 9).

### Deviations from RFC 8259, and choices it leaves open

* A byte order mark is rejected (8.1 allows ignoring one; JSONTestSuite's
  `i_structure_UTF-8_BOM_empty_object` is implementation-defined).
* Numbers are recognized, not converted: there is no range or precision
  limit (section 9 allows one), and JSONTestSuite's huge numbers are
  accepted.
* Duplicate object keys are accepted (section 4: names SHOULD be unique).
* Nesting is limited by `max_depth` (section 9 allows a limit).
* Unpaired surrogate escapes are accepted by `json_string`, rejected by
  `json_string_strict` and by the decoders.

## 8. Composition

### What ordinary coroutine semantics already express

| pattern | how | finite-state? | fused? |
|---|---|---|---|
| **Sequential**: one recognizer completes, the next begins | the driver constructs a recognizer per token, in a loop; the unread symbol of one is the first of the next | each token's recognizer is | yes: one construction site in a loop |
| **Delegating**: a recognizer selects a child, waits for it, continues | `-> call CHILD then STATE`: an ordinary call of the child's run function, whose yields suspend the whole coroutine (a deep yield); `then accept` makes it a tail call | yes, while calls go only to earlier recognizers: the composed control state is the product of an acyclic call chain | yes: the child is inlined into the template |
| **Independent cooperation**: several recognizers keep their own state, a caller coordinates them | the drivers: a source coroutine, a token recognizer and the structural coroutine, alive together, resumed by one function | each recognizer is; the structure is a pushdown automaton | yes: all three in one frame |

No `yieldto` was needed. Delegation is exactly what deep yields provide: a
child recognizer is a function that yields; calling it suspends whatever
coroutine is running; it returns to its caller when it completes. The
unread-symbol rule composes: a child that completes before a symbol
returns that symbol, and the parent reconsiders it.

### Where composition stops being finite-state

| composition | what it needs | how the prototype treats it |
|---|---|---|
| calls among recognizers, acyclic | nothing more: still a DFA (the product) | allowed |
| a recognizer that calls itself | an unbounded stack | `DFA-RECURSIVE-CALL`; only earlier recognizers can be called |
| JSON's nesting | a stack, which the grammar requires | ordinary code: an explicit, bounded stack (`json::structure`) |
| the same nesting as recursive descent | the coroutine's own call stack | ordinary code (`recursive.bot`): correct, and kept on the general runtime by fusion ("its yielding function recursive::value is recursive") |
| YAML's indentation | a counter, and a stack of them | ordinary code (section 13) |

So the DFA stops exactly where the language does; past that point the
right tool is ordinary code with an explicit stack, which fusion still
fuses, rather than recursion, which it cannot.

### The awkward case: one driver for any recognizer

json.bot's three validators differ in two lines: the source and the
recognizer. A driver cannot take its recognizer as a parameter, because
a function that may yield never becomes a value (COROUTINES.md 37: the
yield effect follows only exact calls). The concrete failing example is a
driver whose recognizer is a parameter,
`fn first_taken(recognizer: Fn{args: [int], return: bool, errors: [...]}, c: int)`
with `coroutine {first} = recognizer(c)` in its body, called as
`first_taken(json_lex::json_number, 49)`: rejected twice, `UNWRAPPED-YIELD`
at the argument ("json_lex::json_number may suspend, so it cannot become a
function value") and `COROUTINE-RHS-NOT-YIELDING` at the construction (a
coroutine is started from a direct call of a named function only).

What works with existing semantics is a *factory*: a function that
constructs the recognizer and returns the started handle does not yield
(the construction is a boundary) and is an ordinary value, and a handle
moves through results and fields (AFFINE-VALUES.md).
`audit/dfa/json/composition.bot`:

```botlish
struct Started:
    step: Coroutine{args: [dfa::Symbol], return: bool, errors: [dfa::UnrecognizedInput, dfa::UnexpectedEnd]}
    first: bool

fn token(c: int) -> Started errors dfa::UnrecognizedInput, dfa::UnexpectedEnd:
    coroutine {step, first} = json_lex::json_token(c)
    Started {step: step, first: first}

fn lex_with(make: Fn{args: [int], return: Started, errors: [dfa::UnrecognizedInput, dfa::UnexpectedEnd]}, chunks: List[str], max_token: int) -> json::Summary errors ...:
    ...
        {step: feed, first} = make(c)
    ...
```

It is correct on every backend -- and the handle leaves the factory, so
fusion keeps every token's recognizer on the general runtime ("its handle
reaches `retmulti %2 %3`, which fusion does not follow"): section 12
measures what that costs per character. This is
the fusion milestone's first future-work item (interprocedural closed
graphs, section 13 there) seen from the other side, and not a reason for
a new control-flow construct: the semantics are there; the optimizer
does not follow them across a function boundary.

### Does recognizing DFA structure help fusion?

Not as a prerequisite: fusion fused every generated recognizer without
knowing it was one. What the declaration does give the lowering is the
freedom to choose the code shape fusion handles best (one suspension
point, the search order) -- and two things it could give fusion later: a
dense state number makes a resume dispatch a candidate for a jump table
(the fusion milestone's `switch` item), and a recognizer's statically
known "always consumes" or "always completes" facts (the generator already
computes them) would let a driver's `done?` tests fold.

## 9. Unicode findings

Reassessing what `json_tokens.bot` reported missing:

| need | status | consequence here |
|---|---|---|
| Int -> UnicodeChar (`std::char::from_scalar_value`) | **still missing** | a decoded string cannot become a str: `decode_text` returns scalar values. `\b` and `\f` have no character literal either (the lexer's escapes are `\\ \' \n \r \t`) |
| UTF-8 bytes -> str | **missing** (there is `std::str::encode_utf8`, no decode) | the byte lexer validates UTF-8 but cannot hand the text on as a str; `decode_bytes` returns bytes |
| reading one byte of a `Bytes` | **missing** (no accessor; only binary layouts) | byte input travels as `List[int]` |
| integer division | missing (`/` divides Float64s) | UTF-8 encoding uses `shift_right` and `mod` |
| UTF-8 validation of bytes | **expressible**, declaratively (`utf8_char`, `utf8_text`), fused, faster than the hand-written validators (7.8 ns per byte against 9.0 and 9.2: section 12) | -- |
| surrogates | scalar values exclude them by construction (`unicode` alphabet, `UnicodeChar`); escaped surrogates are syntax (RFC 8259) and are paired, or refused, by the decoder | no lossy path anywhere |

None of these is a defect of the DFA design; the first two are the
standard-library primitives a JSON library needs before it can return
strings. The precise additions this work justifies: `std::char::
from_scalar_value(n: int) -> UnicodeChar errors NotAScalarValue` (total
over 0..0x10FFFF minus the surrogates, failing elsewhere) and
`std::str::decode_utf8(data: Bytes) -> str errors InvalidUtf8` (strict:
no replacement character). String construction cost (`append_char` per
character) was not measured: no decoder here builds a str.

## 10. Correctness

### Tests (run by hand: `tclsh9.0 audit/dfa/tests/NAME.test`)

| file | tests | what |
|---|---:|---|
| `frontend.test` | 29 | one case per diagnostic code, with exact locations; overlaps through classes; cycles only a symbol can take; structured entries and the raised error; no cascades; the committed output current; determinism of generation; the facts the front end derives; numeric-looking state names kept as written; the lowering's shape |
| `json.test` | 13 | the model-based cases (below); the report's token-boundary table; 28 documents and 11 byte documents with exact verdicts, each also checked against the oracle; every split of several texts; the depth and token-length limits; 20,000 tokens and a 20,000-symbol token; decoding; the strict surrogate rule; the hand-written recognizer against the declaration |
| `yaml.test` | 5 | the model-based cases; the subset's cases; the counterexample |

**Model-based testing of the lowering.** `audit/dfa/tests/support.tcl`
simulates a declaration directly from its effective table -- sharing
nothing with the generated code -- and generates, for every entered state
of every recognizer, one case per symbol class of its table (each class's
first, last and a middle symbol, and a value outside the alphabet),
followed by the end of the input, plus random sequences from valid
prefixes. That covers every accepting transition class, every rejecting
category and the end of the input in every state by construction. The
generated drivers run every case on five backends (the interpreter, the
Tcl compiler, cranelift-generic, cranelift fused and cranelift unfused)
and every outcome -- accepted after how many symbols, taken or not, or
which error in which state at which symbol -- must equal the
simulator's: 1,558 JSON cases and 855 YAML cases, all equal. The
json_number cases run against by_hand.bot agree too (423 cases, five
backends: the same outcome at the same symbol, each with its own state
names).

**Differential testing.** `audit/dfa/tools/differential.tcl` builds
`conformance.bot` as a standalone executable and runs it on every case
twice -- whole and in random chunks of 1 to 7 bytes -- and, for valid
UTF-8, a third time through the unicode recognizers; the oracle is
CPython's `json` made strict (`audit/dfa/tools/oracle.py`: strict UTF-8
decoded first, NaN and Infinity refused, control characters refused).

| corpus | cases | result |
|---|---:|---|
| JSONTestSuite `test_parsing` (y_ must accept, n_ must reject) | 318 | 95/95 y_ accepted, 186/186 n_ rejected, 2 n_ rejected by the depth limit (100,000 nested arrays, and 50,000 nested arrays and objects never closed; the oracle's recursion limit too), the 35 i_ verdicts listed in the report; 0 disagreements |
| generated, seeds 1-12, 2,000 each (a quarter with a UTF-8 edge case injected into a string, 60% then mutated at the byte level) | 24,000 | 8,861 accepted, 15,139 rejected; 0 disagreements |
| the cases that are valid UTF-8, again through the unicode recognizers | 17,810 | 8,977 accepted, 8,833 rejected; 0 disagreements |
| every case, whole against chunked | 24,318 | 0 disagreements |

The report is `audit/dfa/results/differential.md` (`differential.tcl
-suite JSONTestSuite/test_parsing -fuzz 2000 -seeds 1-12`; JSONTestSuite
at commit 1ef36fa0).

**Streaming.** The same text gives the same verdict under every partition
tried: json.test's `json-partitions` splits several texts at every
position and at random positions into many chunks (over bytes the splits
fall inside UTF-8 characters, escapes and numbers), and every differential
case is also run in random chunks. By construction a chunk boundary
cannot matter to a recognizer -- it is resumed once per symbol -- so these
test the drivers.

**Resource limits.** A recognizer uses constant memory: it keeps no input
and nothing grows (a 20,000-symbol string token allocates nothing). The
drivers bound what is the caller's policy: `max_token` fails
`TokenTooLong` at the token's start once a token exceeds it, before it
completes; `max_depth` fails `TooDeep` at the container that exceeds it
(json.test's `json-limits`: 33 levels against 32 fail, 32 pass; the first
version of the bound, a multiple of the stack length, let 33 pass -- a bug
the test found).

**Backends.** Every backend agrees on every case it runs, with one
difference that is backend support, not semantics: the reference
interpreter does not eliminate self tail calls, so each symbol of a token
is a nested evaluation there, and its evaluation depth bounds a token's
length: under main.tcl's recursion limit a 3,000-symbol token ran and a
20,000-symbol one failed (`TCL LIMIT STACK`), where the Tcl compiler and
both native backends run 20,000. The imperative probe
(`json_tokens.bot`), which recurses per character too, fails on the same
20,000-character string on the interpreter in the same way.

**Bugs the tests found** (all fixed): the end symbol merged into an
implicit rejection interval (end of input reported as an unrecognized
symbol); the structural depth bound; a dead-transition and a
never-accepting cascade after a cycle; the per-token allocation of the
first protocol.

## 11. Native evidence

`audit/dfa/tools/evidence.tcl` writes `audit/dfa/evidence/`: per
workload, the fusion report, the NIR before and after fusion, and the
machine code of the consumer function fused and unfused
(`summary.md`).

What fusion does with the generated recognizers:

```
fused validate_pattern {inlined {{#7} json_lex::utf8_text json_lex::dfa_utf8_text json_lex::dfa_utf8_char} yields 2 ... template 613 copied 1882 unboxed 2}
fused json::lex_text {inlined {{#14} json::scalars} yields 1 ... template 69 copied 242}
fused json::lex_text {inlined {{#15} json_lex::json_token json_lex::dfa_json_token json_lex::dfa_json_string json_lex::dfa_json_escape json_lex::dfa_json_number json_lex::dfa_json_literal} yields 4 ... template 3477 copied 6987}
fused json::validate_bytes {inlined {{#21} json::structure} yields 1 ... template 335 copied 1040}
```

* **Every site fuses.** The token recognizer and everything it delegates
  to is one template with one yield per suspending recognizer (string,
  escape, number, literal); each recognizer's self tail call is a loop in
  it; the source and the structural coroutine are templates of their own
  in the same frame.
* **No coroutine machinery on the success path.** The coroutine helpers
  left in fused code are each copy's failure pad (`rt_co_failed`) and the
  raise stub of each start and resume (`rt_co_resume0` of the failure
  object): the same as in the fusion milestone, on failure paths only.
* **No allocation per symbol or per token.** Fused, `lex_text` makes 5
  allocations for a whole run (its four cells and its result), and
  `validate_text` 7 (with the structural stack); the declared UTF-8
  validator makes none (section 12, "Resources"). The `dfa::Symbol`
  messages and the Bool answers are registers. On the general runtime the
  same programs allocate a coroutine object and a stack per token and a
  boxed message per resume.
* **The cost is size.** The fused `json::lex_text` is 25 KB of machine
  code (3.2 KB unfused); `json::validate_bytes` 35 KB (4.0 KB). The
  decision trees are large NIR (nested `if` values lower to a move and a
  jump per level, which Cranelift removes), and fusion copies a template
  per start and per resume.

The rest of the numbers are section 12's.

## 12. Performance

`audit/dfa/tools/bench.tcl` measures as `bench/coroutine-fusion.tcl` does:
natively on cranelift, each program fused (the default) and on the
general runtime (fusion off), the best of five in-process runs in each of
five interleaved driver processes, at 2,000, 20,000 and 200,000 items;
with `-instructions 1`, callgrind's instruction count per item: the count
at the middle size minus at the smallest, over the items between.
`audit/dfa/tools/micro.tcl` measures one recognizer alone. Their reports
are `audit/dfa/results/bench.md` and `micro.md`. The times below are the
medians at 20,000 items on a shared four-core container (x86-64,
2.8 GHz), where a time scatters by 10-20% from run to run.

The instruction counts needed care. Counting the whole process at two
sizes does not cancel the compile out:
the same program's count varied by up to 320,000 instructions from one
process to the next (compiling `json_lex`'s NIR is most of its 584
million), up to 18 instructions per item over an 18,000-item span -- the
prototype's first counts moved by that much between runs. So a program
that makes no coroutine object is counted over its execution only
(callgrind collects inside the driver's `execute` and not inside the
compile it calls), which varies by about a thousand instructions, under
0.1 per item. A coroutine object runs on a stack of its own, and callgrind
loses track of `execute` at the first switch (it then counts about one
instruction per item), so the general runtime -- and the fused programs
that still make coroutine objects -- are counted whole, where the
variation is under 1% of their thousands of instructions per item. Each
count says which (`run` or `process`).

### Tokenizing

The input is a JSON-like text, a 57-character piece of 28 tokens repeated
(`{"a": [1, -2.5, 30], "b\"c": {"d": 400}, "e": [6.0, 7]}, `). Every
tokenizer but the imperative one counts its tokens.

| workload | what it runs | fused ns/char | general ns/char | general / fused | instructions/char (fused) |
|---|---|---:|---:|---:|---:|
| `imperative` | `json_tokens.bot`: recursive functions over the text, building a List of Token structs | 76.4 | -- | -- | 986 |
| `coroutine` | `tokens.bot`: a character source and hand-written recognizer coroutines for a subset of the grammar (no exponent, literal or escape check) | 11.3 | 277 | 24.4 | 160 |
| `dfa-lex` | `json::lex_text`: `json_token` and what it calls, RFC 8259's whole lexical grammar, declared | 13.5 | 336 | 24.9 | 209 |
| `dfa-lex-sites` | the same recognizers; the driver decides the kind (punctuation inline, a construction site per kind) | 13.9 | 228 | 16.5 | 210 |
| `dfa-lex-factory` | the same; the recognizer a parameter (`composition::lex_with`) | 334 | 390 | 1.2 | 2,408 (whole process) |
| `dfa-validate` | `dfa-lex` and the structural layer (an explicit stack) | 26.1 | 431 | 16.5 | 348 |
| `dfa-validate-recursive` | the structural layer as recursive descent | 81.0 | 430 | 5.3 | 881 (whole process) |

* **Declared against hand-written.** The declared lexer runs within 1.2
  times the hand-written coroutine tokenizer (13.5 against 11.3 ns per
  character; 209 against 160 instructions) while checking the whole
  grammar where `tokens.bot` checks a subset, and it reads its input as a
  List of chunks where `tokens.bot` reads one String. Recognizer for
  recognizer the declared code is the cheaper (below, "One recognizer
  alone").
* **The imperative probe** is 5.7 times slower (4.6 at the minimum), but
  it also builds what the others only count: a Token struct per token
  (9,806 allocations against 5). It is what a lexer that returns its
  tokens costs today, not a measure of dispatch.
* **Where the kind is decided costs nothing fused.** `dfa-lex` starts the
  `json_token` dispatcher for every token, a comma included;
  `dfa-lex-sites` compares the first symbol in the driver and starts a
  recognizer only for strings, numbers and literals. Fused, the two are
  the same speed (13.5 and 13.9 ns, 209 and 210 instructions). On the
  general runtime the difference is a coroutine per punctuation token
  (9,801 coroutine objects against 3,501; 336 against 228 ns). This
  refuted the first hypothesis for the lexer's then 3.7-times gap, which
  was the collecting loop below.
* **A recognizer passed as a value is the general runtime.** The factory
  pattern (section 8) runs at 334 ns per character fused, 25 times
  `dfa-lex`: its handle leaves the factory, so fusion keeps every token's
  recognizer on the general runtime (9,800 coroutine objects, 38,155
  allocations). Interprocedural fusion is what it needs (section 15).
* **The structural layer** costs about as much as lexing: validation is
  26.1 ns per character, 12.6 more than lexing alone; the structural
  coroutine is resumed once per token and keeps its stack in a
  MutableVector (`rt_mv_push` and `rt_mv_pop` are calls). Written as
  recursive descent it is 3.1 times slower (81.0): a recursive yielding
  function stays on the general runtime, so the structural coroutine is a
  real coroutine object and every token handed to it a boxed message
  (9,812 allocations), while the recognizers under it still fuse.
* **Fusion is worth the same to declared and hand-written coroutines**:
  14 to 25 times (`dfa-lex` 24.9 and `coroutine` 24.4; `utf8-dfa` 15.9
  and `utf8-coroutine` 14.4).

### UTF-8 validation

Per byte of the fusion milestone's pattern input (a repeating mix of 1- to
4-byte characters), validated by:

| workload | what it runs | fused ns/byte | general ns/byte | instructions/byte (fused) |
|---|---|---:|---:|---:|
| `utf8-procedural` | the fusion milestone's hand-written loop | 9.22 | -- | 131 |
| `utf8-coroutine` | the fusion milestone's hand-written coroutine | 9.03 | 130 | 109 |
| `utf8-dfa` | `json_lex.dfa`'s declared `utf8_text` | 7.83 | 124 | 97 |

The declared validator is the fastest of the three and executes the
fewest instructions. Its states are the RFC 3629 table's rows -- a lead
byte with unusual continuation bounds (E0, ED, F0, F4) leads to a state of
its own -- and each state's lowering is a balanced search over its byte
ranges. The hand-written versions compute a lead byte's length and its
continuation bounds and then carry them, in a mutable array or as
arguments. Fused, the declared one allocates nothing at all.

### One recognizer alone

`micro.tcl` resumes one recognizer N times with the same symbol (fused).
The instructions are the difference of two sizes, so the cost of a symbol
alone; the time is the median over five driver processes (a tight loop's
time depends on where its machine code lands: in some runs one process of
the five ran a number recognizer up to twice as slow as the others):

| recognizer | instructions/symbol | ns/symbol |
|---|---:|---:|
| `json_number`, declared (`1` then digits) | 30 | 2.06 |
| `number_by_hand`, the same written by hand | 49 | 3.83 |
| `json_string`, declared, unicode (`"` then `a`s) | 29 | 2.36 |

The declared number recognizer executes fewer instructions per digit than
the hand-written one, though its fused template is almost four times as
large (1,461 NIR instructions against 394). Fusion's report says why: once
its helpers are inlined, the hand-written recognizer has ten suspension
points (every call of `next`, from `digits`, `fraction` and `exponent`),
and a resume dispatches among them, a comparison per yield; the generated
one has a single yield, its state a register that its balanced search
reads. That is section 5's lowering decision ("one suspension point")
measured. The gap between the two lexers above is therefore not the
recognizers' code; it is the grammar the declared lexer checks and
`tokens.bot` does not.

### The collecting loop

The declared lexer was first measured at 41 ns per character, 3.7 times
the hand-written tokenizer. The `dfa-lex-sites` experiment ruled out the
dispatch, and the recognizer micro-benchmark ruled out the generated code;
a callgrind profile then showed a `rt_construct` call per symbol. The
drivers' source coroutines (`json::scalars`, `bytes`, `codes`) were
written

```
fn scalars(chunks: List[str]) -> int errors IndexNotFound:
    loop chunk in chunks:
        loop i from 0 to std::str::length(chunk):
            yield std::char::scalar_value(std::str::char_at(chunk, i))
    -1
```

and the inner `loop` is the outer loop's body value, so the outer loop
collects it: a List of every inner iteration's value -- here, of every
yield's result -- built and thrown away. A `continue` after the inner loop
makes the outer body's value nothing to collect, and the lexer went from
41 to 13.5 ns per character. This is ordinary Botlish, not the DFA
(section 15, "Side findings").

### Resources

At 20,000 items (`bench.md`, "Resources"):

| workload | variant | allocations | coroutine objects | machine code bytes | front end ms | lowering ms | driver compile ms |
|---|---|---:|---:|---:|---:|---:|---:|
| `coroutine` | fused | 3 | 0 | 6,672 | 352 | 162 | 12 |
| `coroutine` | general | 31,505 | 3,501 | 6,763 | 352 | 162 | 9 |
| `dfa-lex` | fused | 5 | 0 | 29,101 | 4,280 | 1,511 | 165 |
| `dfa-lex` | general | 28,357 | 9,801 | 22,771 | 4,280 | 1,493 | 35 |
| `dfa-validate` | fused | 7 | 0 | 37,107 | 4,613 | 2,141 | 186 |
| `utf8-coroutine` | fused | 1 | 0 | 3,783 | 218 | 132 | 11 |
| `utf8-dfa` | fused | 0 | 0 | 8,406 | 2,583 | 500 | 18 |

* **State representation.** Fused, a recognizer's control state is an Int
  in a register: the run function's `state` parameter, which the self tail
  call turns into a loop variable, beside fusion's own state register
  (which yield is suspended). The `dfa::Symbol` message and the Bool answer
  are registers. On the general runtime each token is a coroutine object
  with its own stack, each resume a stack switch and a boxed message.
* **The handoff.** Delegating a token to a recognizer, and a recognizer to
  the one it calls (`json_token` to `json_string` to `json_escape`), is a
  jump in the fused template: no measurable cost (`dfa-lex` against
  `dfa-lex-sites`). On the general runtime the handoff is the whole cost,
  about 300 ns per character.
* **Compile time.** The front end takes 4.3 s for `dfa-lex` against 0.35 s
  for `tokens.bot`, almost all of it the generated module: `json_lex.bot`
  is 1,985 lines, and every program that imports it pays for all of it
  (`utf8-dfa` imports it for `utf8_text` and pays 2.6 s). Recognizer for
  recognizer, the generated code costs the front end more than twice the
  hand-written equivalent (`micro.md`, medians of seven interleaved
  compiles: 130 ms for `by_hand.bot`, 87 lines, against 307 ms for
  `json_number` generated alone, 455 lines; 287 ms in another run).
  Native lowering is 1.5 s; the driver's compile 165 ms fused against 35
  ms unfused (fusion's copies).
* **Code size.** The whole fused `dfa-lex` program is 29 KB of machine
  code (23 KB unfused, 6.7 KB for `tokens.bot`); its consumer function
  alone is 25 KB fused and 3.2 KB unfused (section 11). The decision trees
  are large NIR -- an `if` value per level, a move and a jump each, which
  Cranelift removes -- and fusion copies a recognizer's template once per
  start and once per resume.

The cost of the construct is compile time and code size, not run time
(section 15, "What to revise first").

## 13. YAML findings

`audit/dfa/yaml/yaml_lex.dfa` declares a scoped subset of YAML 1.2.2 to
find what JSON's grammar does not expose. `yaml.test` checks it (model-
based cases on five backends, and the subset's own cases).

**DFA-recognizable**:

* **Double-quoted scalars** (7.3.1) with every escape of 5.7: `\x` and two
  hex digits, `\u` four, `\U` eight (an eight-digit escape's last four
  states are shared with `\u`'s), the one-letter escapes, an escaped
  blank or line break; line breaks inside the scalar (folding is the
  value's business, not the token's).
* **Single-quoted scalars** (7.3.2), where `''` is one quote: the closing
  quote is known only at the symbol after it, which `accept before`
  expresses exactly -- one symbol of lookahead.
* **Comments** (6.6): `#` and the rest of the line, ending before the
  break.

**Not finite-state** (and not attempted): indentation is a count, and the
block structure a stack of counts; a block scalar (`|`, `>`) continues
while its lines are indented at least as far as its first line, a number
the recognizer would have to receive as a parameter (no fixed set of
states holds it unless indentation is bounded); multi-line plain scalars
fold according to the same indentation. These are ordinary code: a
line-oriented driver with counters and an explicit stack, calling
recognizers for what is inside a line.

**The counterexample: two symbols of lookahead.** In flow context `a:b` is
one plain scalar and `a: b` is the scalar `a` followed by the mapping
indicator (7.3.3, ns-plain-char: a `:` belongs to the scalar only if the
symbol after it is "safe"). A recognizer reading `a:` cannot know whether
the `:` is its own until it sees the next symbol, and if that is a space,
the scalar ended *before* the `:` -- two symbols ago. `accept before`
leaves one symbol unread. `yaml_plain_flow` is the best declaration the
construct allows; the front end accepts it (it is deterministic and
well-defined), and it is wrong: on `a: b` it accepts `a:` (yaml.test's
`yaml-two-symbol-lookahead`). The same holds for ` #` (a comment after a
plain scalar ends it before the blank).

What it would take: `accept before N` -- the token ended N symbols before
the current one, with N bounded per recognizer (here 2) -- an answer that
says how many symbols are unread (an Int rather than a Bool), and a
driver that keeps the last N symbols. Lookahead k stays finite-state (a
k-symbol window is part of the state), so the static guarantees survive;
the protocol and every driver change. Plain scalars also show that a
token's grammar depends on its context (flow or block: in block context
`,` `[` `]` `{` `}` are part of a plain scalar): two recognizers, chosen by
the code that knows the context -- the declaration has no parameters, and
needs none for this.

YAML needed no more general coroutine composition: everything that is not
finite-state is ordinary code above the recognizers, as for JSON's
structure.

## 14. Language impact

What integrating the construct into the compiler would change, if it were
recommended as it stands:

* **Grammar.** Two top-level declarations, `class` and `dfa`, and the
  contextual words `over`, `bytes`, `unicode`, `ascii`, `accept`,
  `before`, `reject`, `call`, `then`, `end`, `any`, `except` -- each
  meaningful only inside a declaration, like `static compile` or
  `extern c`. The arrows `->` and `=>` (`=>` is a new token).
* **Lowering, not HIR.** The lowering produces ordinary syntax (functions,
  `if`, `yield`, `return`, `fail`), so it belongs before HIR
  (`surface/lower.tcl`, or a desugaring pass beside it): no HIR node, no
  Core IR form, no NIR instruction, no runtime operation -- the constraints
  COROUTINES.md imposes on coroutines hold for recognizers for free.
  Compilation isolation and HIR interchange need nothing: the declarations
  leave no registry behind, only functions.
* **Types.** None new. A recognizer is `Fn`-shaped like any coroutine root:
  `(first: int, resume std::dfa::Symbol) -> bool errors
  std::dfa::UnrecognizedInput, std::dfa::UnexpectedEnd`.
* **Errors.** One standard family in a standard module, `std::dfa`
  (`Symbol`, `UnrecognizedInput {state, symbol}`, `UnexpectedEnd
  {state}`), rather than errors generated per recognizer: a composing
  driver handles one identity for every recognizer it delegates to (the
  JSON drivers do), and the payload's `state` (qualified,
  `json_number.zero`) says which. A recognizer declares exactly the errors
  it can raise (`UnexpectedEnd` only if some state rejects the end).
* **Diagnostics.** Seventeen codes (`DFA-SYNTAX`, `DFA-DUPLICATE`,
  `DFA-UNKNOWN-STATE`, `DFA-UNKNOWN-CLASS`, `DFA-UNKNOWN-DFA`,
  `DFA-ALPHABET`, `DFA-BYTE-CHARACTER`, `DFA-EMPTY-RANGE`,
  `DFA-END-CONSUMED`, `DFA-AMBIGUOUS-TRANSITION`,
  `DFA-NONPROGRESSING-CYCLE`, `DFA-UNREACHABLE-STATE`, `DFA-NO-ACCEPT`,
  `DFA-DEAD-TRANSITION`, `DFA-MISSING-END`, `DFA-RECURSIVE-CALL`,
  `DFA-CALL-ALPHABET`), already in the compiler's structured form; each
  would need its Compilerpedia topic with a rejected example (the
  examples are the frontend.test cases) and a row in
  `tests/static-compile.test`'s census (a `static compile:` block can hold
  a recognizer, so most would be recoverable `std::compiler::
  DiagnosticCode` cases).
* **Tools.** The compiler service and the language server would see
  declarations (today they see the generated module); hover over a state
  could show its effective table, which the front end already computes.
* **Documentation.** A `concept.recognizer` topic; COROUTINES.md would
  gain a note that a recognizer is a coroutine.

## 15. Recommendation

**Revise, then integrate.** The model holds: a declared DFA *is* an
ordinary coroutine, inherits every coroutine guarantee unchanged, fuses
into native code that allocates nothing and switches nothing, and buys a
class of static guarantees no coroutine code has. The census caught every
structural mistake at compile time and none of the grammar mistakes --
the right division of labor between a compiler and a conformance suite.
It should not be made permanent as it stands, because the experiment
found protocol decisions that would be breaking to change later, and
costs a permanent construct should not freeze in.

### The smallest addition

The answer to this milestone's question, as the evidence shapes it:

* **A `dfa NAME over ALPHABET:` declaration** (`bytes`, `unicode`,
  `ascii`) of **classes** (items, `except`, `any`), **states**, and five
  transition forms: `-> STATE`, `-> accept`, `-> accept before`, `end ->
  accept` / `end -> reject`, `-> call DFA then STATE|accept` (and
  sequences for keywords). About a dozen contextual words, no regular
  expressions, priorities, longest match or actions.
* **Lowered before HIR to one ordinary coroutine function per
  recognizer**: no HIR node, no runtime, no scheduler, no ownership rule;
  the lowering free to choose its search order because the declaration is
  proven deterministic.
* **`std::dfa`**: the message `Symbol` and the two errors
  `UnrecognizedInput {state, symbol}` and `UnexpectedEnd {state}`, shared
  by every recognizer.
* **The seventeen checks of section 4**, as compiler diagnostics.

Two forms of the prototype are *not* in it: `=>` (reconsider in another
state) and `-> reject` on symbols. Neither JSON nor YAML needed them --
calls and sequences covered every factoring the grammars asked for -- and
`=>` is the main source of the non-progress the checker must rule out.
They can be added when a grammar needs them; `end -> reject` stays (it is
how a state answers `DFA-MISSING-END`).

### What to revise first

1. **Decide the lookahead protocol before anything depends on it.** A
   Bool answer is one unread symbol. YAML's plain scalars need two, and
   `accept before N` changes the answer to a count and every driver with
   it. Either make the answer the unread count now (Bool is its 0/1 case)
   or record one-symbol lookahead as a permanent limit. The prototype
   recommends the count, bounded per recognizer and computed by the
   compiler.
2. **Cut the lowering's compile-time and code-size cost.** Nested `if`
   values are large NIR (a move and a jump per level), the front end
   spends more than twice the hand-written equivalent's time on them, and
   fusion copies them per start and resume (25-35 KB fused consumers).
   What coroutine lowering lacks is a multiway branch: a NIR `switch`
   (Cranelift's `br_table`) would serve the state dispatch and fusion's
   resume dispatch alike (the fusion milestone's own future-work item), so
   it is general code generation, not DFA-specific. A table-driven
   lowering for `bytes`/`ascii` recognizers is the alternative to
   measure against it.
3. **Leave token kinds out until a workload needs them.** The driver
   learns a token's kind from its first symbol at no measured cost
   (`dfa-lex-sites`, section 12). A recognizer whose alternatives share a
   first symbol (an integer or a fraction) would need accept labels, and
   with them a result type that differs from its yields' -- the outward
   type rule (COROUTINES.md 19) is what forced the Bool answer, and is
   what labels would have to work within.

### Prerequisites outside the construct

* **Interprocedural fusion** (COROUTINE-FUSION-MILESTONE-1.md section 13):
  a reusable recognizer library is drivers parameterized by recognizers,
  and today that is the general runtime for every token. No control-flow
  construct is needed -- the factory pattern already expresses it.
* **`std::char::from_scalar_value` and `std::str::decode_utf8`** (section
  9): without them a JSON library cannot return strings.
* **Tail calls in the reference interpreter**, or a loop lowering for it:
  without them a long token exceeds its evaluation depth.

### What not to add

`yieldto` (deep yields already delegate); a DFA runtime, interpreter or
table value (option C); recognizer values (a recognizer is a coroutine
root, and the factory pattern covers passing one); actions in the first
version (decoding is a second pass over the recognized token, and an
action language is where a recognizer stops being finite-state and the
guarantees stop being simple); per-recognizer error types (one family
composes).

### Side findings about the language

Not about DFAs, found by this workload:

* **A collecting loop in a generator collects its yields.** A nested
  `loop` whose value is the outer loop's body value builds a List of every
  inner iteration's value -- in a coroutine, of every yield's message.
  json.bot's source coroutine did this, and it cost the lexer two thirds
  of its time (an element per symbol). Nothing reports it; a warning backed by
  the collecting-loop analysis ("a collecting loop's List that is
  collected only to be discarded") would.
* **Method syntax is priced by the program's size.** A method call with
  several candidates is decided by trial builds of the whole program
  (METHOD-SUGAR.md); 91 such calls in json.bot cost 1.9 s of front-end
  time beside a 2,000-line generated module (and a test driver's cost
  fell from 10 s to 1.8 s written with qualified calls). Generated code
  should never use method syntax; ordinary code next to large modules
  pays for it. The warnings point the other way: `METHOD-ELIGIBLE`
  reports the qualified calls that saved the time (63 in json.bot) and the
  generated self tail calls (9 in json_lex.bot, `dfa_json_number(target,
  m.code)`). An integrated lowering would declare its run functions and
  state helpers `nomethod fn`, which also takes them out of every
  method-call decision (a `nomethod` function is no candidate at all); the
  prototype's generated code does not yet.
* **A function that always fails cannot be called** (`KNOWN-ERROR`), so a
  rejection cannot be factored into a helper: every rejecting site writes
  its own `fail`. A generator works around it (a helper returns the state
  name); hand-written recognizers repeat themselves.

## 16. Files

| file | what |
|---|---|
| `audit/dfa/tools/dfa.tcl` | the front end: parsing, checks, effective tables, lowering, `generate`/`check`/`describe` |
| `audit/dfa/json/json_lex.dfa`, `json_lex.bot`, `dfa.bot` | the JSON recognizers, their generated module, the support module |
| `audit/dfa/json/json.bot` | drivers, structural validator, decoders |
| `audit/dfa/json/by_hand.bot` | json_number written by hand as an ordinary coroutine |
| `audit/dfa/json/composition.bot` | one driver for any recognizer, through a factory |
| `audit/dfa/json/recursive.bot` | the structural layer as recursive descent |
| `audit/dfa/json/conformance.bot` | the standalone program of the differential runs |
| `audit/dfa/json/example.bot` | the workload in one `main.tcl` run |
| `audit/dfa/yaml/yaml_lex.dfa`, `yaml_lex.bot` | the YAML subset |
| `audit/dfa/tests/frontend.test`, `json.test`, `yaml.test`, `support.tcl` | the tests, the simulator, the model-based cases |
| `audit/dfa/tools/differential.tcl`, `oracle.py` | JSONTestSuite and fuzzing against CPython's json made strict |
| `audit/dfa/tools/mistakes.tcl`, `mistakes.txt` | the mistake census |
| `audit/dfa/tools/evidence.tcl`, `audit/dfa/evidence/` | native evidence |
| `audit/dfa/tools/bench.tcl`, `micro.tcl` | the performance report; one recognizer alone, and the front end's cost of one |
| `audit/dfa/results/` | `differential.md`, `mistakes.md`, `bench.md`, `micro.md` |
