# EMITTER-COROUTINE-EXPLORATION.md

Grammar-constrained emission, exploratory milestone 1: can the declared
recognizers of DFA-COROUTINE-MILESTONE-2.md also constrain *production*, so
that output a program emits is guaranteed by the compiler to belong to the
declared language, while ordinary coroutines express the computation and
coroutine fusion removes the machinery?

> A recognizer determines whether supplied input belongs to a declared
> language. An emitter chooses symbols belonging to that language. Both
> should benefit from the same statically checked automaton, ordinary
> Botlish coroutine semantics, and native coroutine fusion.

The experiment is isolated in `audit/emitter/`: no file of `core/`, `hir/`,
`surface/`, `compiler/` or `native/` changed, and the language gained no
syntax. Its answer is **yes, for the lexical layer, statically, at no run-time
cost** -- with limits that are as instructive as the result, and that decide
the shape of a permanent version (section 17).

## Contents

1. [Result](#1-result)
2. [Starting architecture](#2-starting-architecture)
3. [Design alternatives](#3-design-alternatives)
4. [Chosen model](#4-chosen-model)
5. [Guarantees](#5-guarantees)
6. [Coroutine correspondence](#6-coroutine-correspondence)
7. [DFA correspondence](#7-dfa-correspondence)
8. [JSON numbers](#8-json-numbers)
9. [JSON strings](#9-json-strings)
10. [Complete JSON](#10-complete-json)
11. [Output boundaries](#11-output-boundaries)
12. [Correctness](#12-correctness)
13. [Native evidence](#13-native-evidence)
14. [Performance](#14-performance)
15. [Language impact](#15-language-impact)
16. [Security implications](#16-security-implications)
17. [Recommendation](#17-recommendation)
18. [Next steps](#18-next-steps)

Appendices: [A. Generation from the grammar](#a-generation-from-the-grammar),
[B. Relationship to reversible coroutines](#b-relationship-to-reversible-coroutines),
[C. Files](#c-files).

## 1. Result

**An emitter is an ordinary Botlish function whose yields are symbols**, run
inside whatever coroutine calls it. A directive comment associates it with a
declared recognizer -- the experiment's stand-in for syntax:

```
#: emits json_lex::json_number
fn integer(n: int) -> unit errors IndexNotFound:
    if n == 0:
        yield 48
    elif n < 0:
        yield 45
        magnitude(0 - n)
    else:
        magnitude(n)
    unit
```

and a **static emission checker** (`audit/emitter/tools/emitcheck.tcl`, about
1,200 lines of Tcl and 220 of comments) proves the claim:

> Every normal completion of a call of the function has yielded a sequence
> of symbols that the recognizer, fed them and then the end of the input,
> recognizes as exactly one token, nothing left unread.

It proves it by abstract interpretation of the function's HIR over the
recognizer's **effective table** -- surface/dfa.tcl's own analyzed model,
one exact partition of the Int line per state -- using the value facts the
compiler already proves (the range analysis native lowering reads), plus
set-precise facts it derives from branch conditions and from *guards*
(non-suspending recognizers, which are ordinary functions of one symbol).
Concretely:

* **Three JSON integer emitters** (section 8): `integer` computes its digits
  by comparisons with powers of ten (Botlish has no integer division), and
  every symbol is *proved* -- no check at run time; `integer_text` emits
  `std::int::to_string`'s text, each character passed through a guard
  declared from json_lex's own classes -- valid by a run-time check per
  symbol; `integer_trusted` is the same text unchecked, what an ordinary
  serializer writes, which the checker cannot prove (it has no contract for
  `to_string`'s text: census case `unguarded-text`), so it claims nothing.
* **Four JSON string emitters** (section 9), each with an explicit policy:
  Unicode output (raw characters, short escapes, `\u00XX` for other
  controls), ASCII-only output with strictly paired surrogate escapes (proved
  against json_lex's strict I-JSON grammar), UTF-8 bytes (proved against the
  bytes grammar, which validates UTF-8 as finite state), and a List of code
  points checked to be scalar values first.
* **Complete JSON texts** (section 10) from a value tree, streaming: a
  recursive serializer and an explicit-stack one, both proved against a
  lexical-stream grammar (`json_text`, declared from json_lex's recognizers:
  every token valid, every boundary valid, every token helper's token ending
  where the helper claims). A JSON text's nesting is not a regular language:
  structure is held to the integrated validator and CPython, not proved.
* **22 claims** in the experiment's program (`check_all.bot`), all proved;
  **31 census cases** (realistic mistakes, bad data and deliberate
  imprecisions, section 12): every lexical mistake rejected at compile
  time, with the yield's location and the grammar state's declaration as a
  related location; corrupted data caught by the checks the claims rely on;
  the four cases outside the guarantee (a wrong value, a text's structure, a
  non-terminating emitter) accepted, as the guarantee says.
* **Correctness evidence**: three property seeds of 671 outputs each
  (integers to 300 digits, texts of every scalar class to 2,000 characters,
  random value trees) on all five backends -- every output valid and
  denoting its case for CPython's strict json, one token of its recognizer
  for tests/dfa-support.tcl's independent reference interpreter, validated
  in-program by json.bot, and decoding back to its text: **0 failures**.
* **Native code** (section 13): fused, a statically checked emitter's code
  holds **no trace of its grammar** -- no table load, no switch, no
  transition -- and no coroutine object; the same emitter validated at run
  time by its recognizer (design A) carries the recognizer's table loads
  and switches per symbol.
* **Generation** (appendix A): the same emission automaton, walked breadth
  first, gives the shortest token through every transition of every
  recognizer -- 180 distinct coverage witnesses over fifteen recognizers,
  all accepted by the reference interpreter.

What it does **not** establish: the semantic round trip (`parse(emit(v)) ==
v`) is tested, never proved -- a valid token of the wrong value is outside
any grammar; a JSON text's structure is tested, never proved; and the
checker's facts are sets of single symbols, so where the grammar relates two
symbols (UTF-8's second byte after `E0`, a strict escape's digit after
`\ud`), the emitter must write the grammar's case split as branches for the
proof to go through (section 7). The guarantee rests on the soundness of the
range analysis, which until now decided only representations (section 16).

Recommendation (section 17): **revise, then integrate narrowly** -- an
`emits R` claim on a function declaration, proved by a HIR check after the
range analysis, with modular facts for parameters; no runtime, no new
operation, no new execution model.

## 2. Starting architecture

Reused, unchanged:

* **Declared recognizers** (DFA-COROUTINE-MILESTONE-2.md). surface/dfa.tcl's
  `expand` analyzes each declaration into a model: per state an *effective
  partition* `{SET ACTION}...` covering the whole Int line (goto, accept N,
  call D then T, reject), plus the entered states, distances and the
  callee facts. Every DFA check (determinism, defined rejection, explicit
  acceptance, finite control, bounded lookahead, the end, alphabets,
  integrity) has already run when an emitter is checked. The checker calls
  `expand` exactly as the loader does (surface/modules.tcl's
  `ExpandDfas`), in import order, and reads the models; its interval sets
  are surface/dfa.tcl's own (`Inter`, `Union`, `Minus`, `Norm`,
  `Universe`, `SetText`).
* **JSON's grammar** (examples/dfa/json/json_lex.bot): eleven recognizers,
  the one authoritative statement of JSON's lexical syntax. The emitters
  restate none of it. The experiment adds one module,
  `audit/emitter/json/json_grammar.bot`, whose declarations only compose
  json_lex's: `json_text` (whitespace, and a `json_lex::json_token` per
  token), its bytes twin, and two guards (`digit_symbol`, `nonzero_symbol`:
  one symbol of `json_lex::digit` / `json_lex::nonzero`).
* **Coroutines** (COROUTINES.md): eager construction, typed resume, deep
  yields, stable terminal results and failures, `done?`, affine handles
  released at their last use. An emitter's coroutine is a symbol *source* in
  std::dfa's protocol -- json.bot's drivers already consume sources of
  exactly this shape.
* **Coroutine fusion** (COROUTINE-FUSION-MILESTONE-1.md): an emitter driven in
  the function that constructs it compiles into that function.
* **HIR facts**: `hir::range` (per used specialization instance, the Range of
  every reachable Int expression, branch-narrowed, interprocedurally seeded),
  `hir::range::Paths` (the disjunctive form of a condition's `and`/`or`/`not`),
  `hir::exact`, `hir::coroutines::MayYield`, expression types and origins.

The standard library facilities DFA-COROUTINE-MILESTONE-2.md found missing
are still missing: no Int to UnicodeChar, no strict UTF-8 decoding into a
`str`, no integer division (POST-2048-PRODUCT-FIXES.md S2). The emitters
therefore read `str` input (`char_at`, `scalar_value`) and produce symbols
(Ints): scalar values or bytes. A sink that wants a `str` cannot build one
from scalar values; the sinks here collect Lists, fold a checksum, or encode
UTF-8 bytes and write them (section 10). This was isolated, not worked
around.

## 3. Design alternatives

### A. Ordinary emitter, recognizer validation

The emitter is any coroutine; the recognizer validates its output at run
time. Implemented three ways in `sinks.bot` and `bench_work.bot`:

* **incrementally** (`validated_integer`, `ints_validated`,
  `strings_validated`, `documents_validated`): each symbol is fed to the
  recognizer as it is emitted; a bad symbol fails `Invalid` *after* the
  symbols before it reached the sink;
* **buffered** (`buffered_integer`): the token is collected privately,
  validated, then handed on -- no invalid byte reaches the sink, at the cost
  of a buffer per token;
* **afterwards** (`documents_checked_after`): everything committed, then
  validated (json.bot's `validate_scalars`, structure included).

A gives a guarantee about *this run's* output, for every grammar the
recognizers can state and for structure too (json.bot's structural layer),
and costs a recognizer per symbol (section 14). It proves nothing about the
emitter: a bug shows on the input that triggers it, in production.

### B. Compiler-constrained emission (chosen, prototyped)

A claim associates the emitter with a recognizer; the compiler proves the
claim from the emitter's code. The emitted symbols are checked against the
declared transitions *statically*: a symbol whose possible values fall
outside its state's transitions, a completion in a state that does not
accept the end, a symbol after the token is complete, a symbol the token
ends before, a value that is no symbol -- each a compile-time diagnostic at
the yield. Value-dependent output is admitted by the facts the compiler has
(ranges, branch conditions, guards), never assumed. Sections 4-7.

### C. Grammar-directed emission operations

Expose the effective table to the emitter as safe transition operations:
the automaton state becomes a *value*, and each output operation takes a
state and a symbol and returns the next state (or fails), while the type
system or the compiler tracks which state a value is in -- typestate. The
experiment examined three forms and found that each collapses into A or B:

* **The state as an Int, each step checked at run time.** Streaming output
  happens at each step, but nothing prevents a state from being used twice:

  ```
  s1 = step(s0, '0')    # json_number: zero
  s2 = step(s0, '1')    # the same s0 again: the output is now "01"
  finish(s2)            # integer accepts the end: "success"
  ```

  The output `01` is no number, and every individual step was legal. A
  typestate is sound for streaming only if state values are *linear* (or at
  least affine: never duplicated). Botlish's affinity is compositional from
  one root, the coroutine handle (AFFINE-VALUES.md); making the state a
  handle makes it the recognizer itself -- design A.
* **The state as an accumulating value** (each step returns a new state
  holding the output so far): forking is harmless (each value carries its
  own history) but the output is a value, not a stream -- the opposite of
  the streaming requirement -- and every step allocates or copies.
* **The state as a type** (a nominal type per state, generated from the
  declaration): the same duplication problem, plus a type per state of
  every recognizer, and a join of two branches in different states is a
  type error with no useful message.

What survives of C is its useful half -- *grammar-directed queries*. A
guard (`json_grammar::digit_symbol(c)`, a recognizer of one symbol declared
from `json_lex::digit`) is a checked operation whose symbol set comes from
the grammar, not from a restated class, and B's checker uses its completion
as a fact (section 7). The state stays implicit: it is the program point,
which control flow already makes linear -- the reason B has no fork problem
at all.

### Assessment

| criterion | A: validation | B: static claims (chosen) | C: transition values |
|---|---|---|---|
| guarantee | this run's output, at run time | every run, at compile time | B's, only with linear state |
| duplicated grammar | none | none (guards reuse classes) | none |
| value-dependent output | any | proved, guarded, or rejected | checked per step |
| streaming | yes (incremental), or buffered | yes | requires linearity |
| run-time cost | a recognizer per symbol | none (the check is erased) | a lookup per step |
| compile-time cost | none | an analysis (section 14) | typestate inference |
| structure (nesting) | yes (a structural validator) | no (not regular) | no |
| ownership and contexts | unchanged | unchanged | needs a new affine root |
| where a mistake shows | at run time, at the bad symbol (incremental) | at compile time, at the yield | at run time, at the bad step |

B was chosen because it is the only design that guarantees *construction*
safety -- a property of the emitter, not of one output -- without changing
the language's ownership model, and because its implementation is
erasable: the emitter compiles to exactly the code it would without the
claim (the directive is a comment). A remains the right tool for what B
cannot state (structure; untrusted emitters of other origin) and is B's
oracle in the tests.

## 4. Chosen model

### The emission automaton

An abstract state is a set of **composite states**. A composite state is the
recognizer the emitter writes for (its *target*) in one of its states, plus
the stack of recognizers a `call D then T` transition entered -- innermost
last, each outer frame remembering its `then` (a state, or accept) -- or
`done`, the token complete. Calls are acyclic (DFA-RECURSIVE-CALL), so the
space is finite: json_text reaches 26 composite states, json_string_bytes
15 (appendix A).

A yield of the symbol set X from composite C partitions X by C's innermost
effective row, *exactly as the recognizer runs* (DFA-COROUTINE-MILESTONE-2.md,
section 4):

| row action | for the part Y of X it holds |
|---|---|
| `goto S` | C in S |
| `call D then T` | push D (the caller remembers T), hand Y to D's start row |
| `accept` (nothing unread) | pop: the caller continues in its T, or completes with the callee (`then accept`); the outermost recognizer: `done` |
| `accept before 1` | pop *leaving Y unread*: the caller reconsiders Y in T (or passes the count on); the outermost: a violation -- Y would not be part of the token (EMIT-BEYOND-TOKEN) |
| reject (implicit) | a violation (EMIT-REJECTED) |
| from `done` | a violation (EMIT-AFTER-TOKEN) |

A normal completion feeds the end (-1) the same way: every state must reach
`done` (EMIT-INCOMPLETE otherwise). `accept before N` for N >= 2 (YAML's
plain scalar) would require the emitter's last N symbols; it is not modeled
(a violation that says so) -- JSON's recognizers leave at most one.

`emitcheck::Step` and `Pop` are the one place the checker states DFA
meaning itself: about 100 lines restating section 4's run semantics over
interval sets, beside surface/dfa.tcl's `Lower`, which states it for
execution. A permanent version should derive both from one statement (the
lowering's codes already enumerate the outcomes: section 18).

### The walk

The checker interprets the emitter's HIR (the one native lowering compiles)
over these sets:

* **sequences** in order; **`if`** joins its branches, each entered with its
  condition's outcome as a fact, and a branch the facts make infeasible is
  skipped; a branch that cannot complete leaves its negation as a fact for
  what follows;
* **loops** to a fixed point (the state sets are finite); a counting domain
  with an exact start is *peeled*: its first iteration has the count at the
  start, every later one past it -- the `if i > 0:` separator idiom of every
  list printer;
* **`break`, `continue`, `return`** to their targets; **handlers** entered
  from every state the protected expression passed through (it may fail
  after yielding);
* **calls**: a yield (`coroutine#yield`) is a symbol; a call of a function
  that may yield (`hir::coroutines::MayYield`) is a *summary* -- the exit
  states of its body from each entry composite state, computed to a fixed
  point over rounds, so recursion is analyzed; a function that cannot yield
  changes nothing; a coroutine constructed inside an emitter is another
  coroutine, whose yields are not the emitter's.

### Symbol sets

A yielded expression's set of possible values is the intersection of:

1. its exact value (`hir::exact`), when it has one;
2. its Range (`hir::range::of`), the union over the emitter's used
   instances -- the range analysis's interprocedural seeding gives
   `hex_digit(n)` its `n` in 0..15 from its call sites;
3. a native's result *set* where an interval says too little:
   `std::char::scalar_value` is a Unicode scalar value, never a surrogate;
4. for a reference: what the summary's caller passed for that parameter (the
   checker is *call-site sensitive*: one hexadecimal-digit helper serves a
   nibble in 0..15 and one in 8..11), what its binding was bound to, and
   every path fact on it -- the outcomes of the conditions on the path that
   compare it with a constant, decomposed by `hir::range::Paths`, so
   `c == 34 or c == 92` false excludes both values (an interval cannot);
5. for `X + K`, `X - K`, `X.shift_right(K)`, `X.mod(K)`: X's set
   transformed exactly (mod keeps an interval that does not wrap).

A **guard** -- a call of a non-suspending recognizer with a binding as its
symbol -- leaves the fact that the binding is in what the recognizer
completes on, for the rest of the sequence, unless one of its handlers
completes normally.

### Diagnostics

Structured entries `{kind location message related}`: the yield or function
where the problem is, the problem with each composite state and its
symbols, the grammar states' declarations and the claim being checked as
related locations. Kinds:

| kind | meaning |
|---|---|
| EMIT-REJECTED | a yield may send symbols no transition of the state takes (values outside the alphabet included) |
| EMIT-BEYOND-TOKEN | a yield may send a symbol the token ends before: it would begin the next token |
| EMIT-AFTER-TOKEN | a yield after the token is complete |
| EMIT-INCOMPLETE | a normal completion while the token is incomplete |
| EMIT-BOUNDARY | a symbol that would continue a token a helper claims to emit whole |
| EMIT-END-SYMBOL | a yield of -1, the end, which is never a symbol |
| EMIT-NOT-SYMBOL | a yield of something not an Int |
| EMIT-BYTE-CHARACTER | a non-ASCII character's scalar value sent to a bytes recognizer (DFA-BYTE-CHARACTER's rule, for emitters) |
| EMIT-TERMINAL-VALUE | a coroutine root whose final value is not -1 |
| EMIT-UNUSED | a claimed emitter the program never calls: no facts, no check |
| EMIT-UNKNOWN-RECOGNIZER | a claim naming no declared recognizer |

For example (census case `leading-zero`: the first digit found as any other
digit, so it may be 0, and the next digit's yield is then in json_number's
`zero` state):

```
number_emit.bot:96:9: this yield may send symbols no transition takes:
    '0'..'9' in state zero of json_lex::json_number (EMIT EMIT-REJECTED)
    json_lex.bot:45:5: note: state zero of json_lex::json_number
    number_emit.bot:101:11: note: checking integer's claim to emit json_lex::json_number
```

and, for a serializer that drops a separator (`missing-separator`):

```
number_emit.bot:88:5: this yield may send a symbol that continues the
    json_lex::json_number token integer emitted (called at value_emit.bot:115:9),
    which claims to emit that token whole: the token would absorb it: '1'..'9'
    in state integer of json_lex::json_number (called by json_lex::json_token,
    then accept) (called by json_grammar::json_text, then between) (EMIT EMIT-BOUNDARY)
```

## 5. Guarantees

For an emitter F claimed to emit R, in a program the checker accepts:

| property | how | status |
|---|---|---|
| every normal completion of F has yielded exactly one R token, nothing unread (the claim) | the walk | **proved** |
| every prefix F yields is a prefix of some R token | every yield is checked, and the DFA checks guarantee every reachable state can still accept (DFA-NO-ACCEPT) | **proved** |
| F's token ends where F claims, inside any checked composition (no token absorbs the caller's next symbol) | EMIT-BOUNDARY at each claimed helper's exits | **proved** |
| a JSON text's lexical layer is valid: tokens and their boundaries | a serializer's claim of json_text | **proved** |
| the token's symbols are in the recognizer's alphabet: bytes are 0..255, scalar values are never surrogates | the alphabet is part of the effective table; scalar_value's set | **proved** |
| a symbol from data whose facts are too weak (to_string's text, a List of Ints) | a guard, or an explicit check that fails a declared error | **checked at run time**: the emitter fails rather than completing |
| the token denotes the intended value (`parse(emit(v)) == v`) | property tests, CPython, json.bot's decoder | **tested** |
| a JSON text's structure (separators, colons, matching brackets) | the integrated validator, CPython | **tested** (not regular) |
| F terminates | -- | **not claimed**: an emitter that never completes claims nothing |
| a sink's own failure, abandonment | ordinary coroutine semantics | **defined**: the prefix property holds; nothing is rolled back |

The proofs are relative to: the DFA declarations (a well-formed recognizer
of the wrong language passes: DFA-COROUTINE-MILESTONE-2.md section 5 and its
mistake census); the soundness of the range analysis and of the checker's own
fact rules; the one native result-set fact (scalar_value); and, as for
every program, the compiler and runtimes. Section 16 discusses the trust
boundary.

## 6. Coroutine correspondence

* **The protocol is std::dfa's source protocol.** An emitter's coroutine
  yields one symbol per segment and completes with -1, the end: exactly the
  sources json.bot's drivers already read (`scalars`, `bytes`, `codes`).
  Helpers are ordinary functions that yield (deep yields) and return `unit`:
  their return is never outward (COROUTINES.md 20). Only a root's completion
  is outward, and EMIT-TERMINAL-VALUE proves it is -1 -- the one value no
  consumer writes. No `yieldto`, no new coroutine operation, no change to
  terminal behavior.
* **Construction is eager**: the first symbol is the construction's value
  (`coroutine {step, first} = number_emit::integer_source(n)`), and an
  emitter whose first segment completes is done at construction. A token
  emitter cannot complete empty (a token recognizer's start state rejects
  the end); json_text, a token sequence, accepts the empty text.
* **Completion and resumption.** `done?` tells a symbol from the end;
  resuming a completed emitter answers -1 again and runs nothing
  (`emit-protocol-terminal`: three resumes after the end, `[-1, -1, -1]`).
* **Failure.** An emitter fails with ordinary declared errors (`NotAScalar`,
  `NotCanonical`, `IndexNotFound`), at any segment, after any prefix
  (`emit-protocol-failure-after-prefix`); the consumer's resume raises it, a
  later resume raises it again (stable failure). Partial output is never a
  claim: the claim is about completion, and the prefix property says what a
  failed emitter left behind is still a viable prefix.
* **Abandonment.** A consumer that stops resuming drops the handle; it is
  released at its last use (COROUTINES.md, "Release at the last use"), on a
  consumer's own failure too (`limited_text`'s SinkFull:
  `emit-protocol-sink-failure`). Nothing runs after abandonment.
* **Ownership.** Handles are affine, as for every coroutine. A reusable
  sink takes a handle by move (`sinks::drain`) -- which works, and costs
  fusion (section 14).
* **Contexts and authority.** An emitter needs none and has none: the
  emitters here are pure computations of their arguments. Authority is the
  consumer's: `demo.bot`'s consumer installs `std::linux::io::LinuxIO`,
  encodes each chunk of 64 symbols as UTF-8 and writes it
  (`emit-protocol-stream`); the emitter cannot write anything, anywhere.

## 7. DFA correspondence

The checker reads, per state, the effective partition the compiler built
from the declaration -- symbols, ranges, classes (`except` included),
sequences (a sequence's states are anonymous states of the trie), calls
and their start rows, the implicit rejection of everything unlisted -- and
nothing else. So an emitter is held to the language the *recognizer*
recognizes, by construction the same one, with nothing restated:

* **Classes are never restated.** The string emitters escape what their
  policy escapes (`c < 32 or c == 34 or c == 92`); the checker proves the
  rest is in json_string's local class `unescaped`. Forget the controls and
  it says which symbols of which state: `raw-controls`.
* **Escape syntax is never restated**: `\u` followed by fewer than four
  hexadecimal digits (`short-unicode-escape`), a backslash written raw
  (`raw-backslash`) or a lowercase digit off by one (`hex-digit-off-by-one`)
  are rejected in json_escape's states.
* **Acceptance is the declaration's**: a number may end where json_number
  accepts the end (`exponent-sign-end` and `minus-only` are rejected in
  `exponent_sign` and `minus`); a string ends at its closing quote, and the
  checker reports a symbol after it (`after-token`).
* **Boundaries are the declaration's** (section 11).
* **Alphabets are the declaration's**: a value past 255 is no byte
  (`byte-out-of-range`), a surrogate no scalar value (`surrogate-scalar`), a
  non-ASCII character's scalar value no byte (`bytes-unencoded`).

### Where the grammar leaks into the emitter

The facts are sets of single symbols, not relations between symbols. Where
a grammar constrains a symbol by an earlier one *through a value the
emitter computes both from*, the emitter must make the grammar's case split
visible as a branch, so that each yield's set is precise on its own path.
Two cases in the workload:

* **UTF-8.** utf8_char's second byte after `E0` is `A0..BF`, after `ED`
  `80..9F`, after `F0` `90..BF`, after `F4` `80..8F`. An encoder written by
  length (four branches) is correct, and the checker cannot prove it
  (`utf8-by-length`): after the lead `0xE0 + (v >> 12)` it knows the second
  byte only as `0x80 + ((v >> 6) mod 64)`, 80..BF, whatever the lead was:

  ```
  string_emit.bot:158:9: this yield may send symbols no transition takes:
      0x80..0x9F in state e0 of json_lex::utf8_char (called by
      json_lex::json_string_bytes, then body); 0xA0..0xBF in state ed of
      json_lex::utf8_char (called by json_lex::json_string_bytes, then body)
      (EMIT EMIT-REJECTED)
      json_lex.bot:121:5: note: state e0 of json_lex::utf8_char
      json_lex.bot:123:5: note: state ed of json_lex::utf8_char
  ```

  Written in utf8_char's lead classes -- E0, E1..EC, ED, EE..EF, F0, F1..F3,
  F4, nine branches with the range of v on each (`string_emit.bot`'s
  `utf8`) -- every byte is proved.
* **Strict escapes.** json_escape_strict accepts `\uD000`..`\uD7FF` (no
  surrogate) through its state `d2`, which checks the digit after `\ud`.
  `\uXXXX` of a BMP character written uniformly (`strict-escape-unsplit`) is
  correct and unprovable; string_ascii writes U+D000..U+D7FF on its own
  branch, and the surrogate pair arithmetic with each nibble's range
  (`8 + (u >> 18)`, `12 + ((u mod 1024) >> 8)`), and the strict grammar is
  proved.

Both cases restate a distinction of the grammar -- but *checked*: written
wrong, the branch is rejected. The alternative is a relational analysis (a
fact like "the second byte is A0..BF when the first is E0"), which neither
the range analysis nor this checker has; section 18 weighs it.

A third case is the same lesson about control flow: the grammar position
must be control flow, not data. `value_flat`, an explicit-stack serializer
with one loop, is correct, but which code runs next depends on the frame it
pops, so the checker cannot tell that a value never starts right after a
number (`flat-serializer`: rejected). `value_stacked` keeps the same stack
with two loops -- "start a value" and "after a value" -- and is proved
(section 10).

## 8. JSON numbers

`audit/emitter/json/number_emit.bot`. Integers only, as the task asked:
JSON's int production (`-? (0 | [1-9][0-9]*)`) without fraction or
exponent, for Botlish Ints of any magnitude.

| emitter | digits from | per-symbol run-time check | claim |
|---|---|---|---|
| `integer` | comparisons with multiples of each power of ten, most significant first | none | **proved** |
| `integer_text` | `std::int::to_string` | a guard per digit (`nonzero_symbol` for the first, `digit_symbol` after); failure `NotCanonical` | **proved** (with the checks) |
| `integer_trusted` | `std::int::to_string` | none | rejected (no directive in the module; `unguarded-text`) |

**Separating the digits from the proof.** `integer` has no division
(POST-2048-PRODUCT-FIXES.md S2), so a digit is found by comparisons:
`digit_at(r, p)` returns one of the constants 0..9 by a binary search over
`r >= k * p`, and `leading_digit_at` one of 1..9. The range analysis proves
those results ([0, 9] and [1, 9]) *whatever the arguments* -- and that is
all the syntax needs: the first digit is nonzero, the rest are digits, a
zero is a token of its own, a minus sign precedes a magnitude. That the
digits are *the right ones* is arithmetic the grammar knows nothing of; the
census shows both sides (`wrong-digit-value`: a 9 written as 8 is accepted --
a valid token of the wrong value -- and caught by the round trip;
`leading-digit-latent`: computing the first digit with `digit_at` is
rejected although correct arithmetic never makes it 0, because nothing
*proves* it is not 0).

**The canonical text.** `std::int::to_string` writes exactly a JSON integer
(NUMERIC-TEXT-BOUNDARY-MILESTONE-1.md: `0 | -?[1-9][0-9]*`), but that is a
fact of the native's implementation, not one the compiler has. `integer_text`
therefore states the token's structure as branches (zero alone; an optional
sign; a first digit guarded nonzero; further digits guarded) and the guards
make the claim provable. The guards restate no class: they are recognizers
declared from json_lex's `digit` and `nonzero`. They cannot fail (the text
is canonical), and they cost a table lookup per digit at run time (section
14). This is the honest mixed case: the syntax proof is static, given checks
the program performs.

**Coverage and round trips.** The property runs emit integers of every
magnitude class -- zero, small, 2^k +- 1 to 2^199, 10^k +- 1 to 10^59, random
digit strings to 300 digits, the i64 boundaries -- through all three
emitters and both validation sinks (incremental, buffered), on every
backend; CPython parses each output as an integer equal to the case (Python's
int is exact at any magnitude, so no floating-point oracle is involved).

## 9. JSON strings

`audit/emitter/json/string_emit.bot`. The grammar (json_string) says which
representations are valid; the emitter's **policy** chooses one:

| emitter | output | policy | claims proved |
|---|---|---|---|
| `string` | scalar values | raw except `"` `\` (escaped `\"` `\\`) and controls (`\b \f \n \r \t`, else `\u00XX`, lowercase); `/` raw | json_string, json_string_strict |
| `string_ascii` | scalar values, all ASCII | `string`'s, plus `\uXXXX` past U+007E and an escaped surrogate pair past U+FFFF | json_string, json_string_strict |
| `string_bytes` | UTF-8 bytes | `string`'s, raw characters in their UTF-8 bytes | json_string_bytes |
| `string_codes` | scalar values | `string`'s, over a List of Ints, each checked to be a scalar value first (`NotAScalar`) | json_string, json_string_strict |

* **Surrogates.** A UnicodeChar is never a surrogate, and the checker knows
  it (`scalar_value`'s result set), so `string` needs no check. A List of
  Ints may hold anything; `string_codes` checks `c < 0 or c > 0x10FFFF or
  (0xD800 <= c <= 0xDFFF)` and fails otherwise -- the check is what the proof
  rests on (`surrogate-scalar` drops its surrogate part: rejected;
  `unchecked-codes` drops it all: rejected, and -1 could be yielded, which
  is the end: EMIT-END-SYMBOL).
* **The strict and the permissive grammar stay distinct.** json_string (RFC
  8259) and json_string_strict (I-JSON) are separate declarations; an emitter
  claims either or both. `string_ascii` is proved strict, with the branches
  of section 7.
* **UTF-8 bytes.** json_string_bytes validates UTF-8 inside the token by
  calling utf8_char; the checker holds `string_bytes`'s encoder to it, so
  the bytes are valid UTF-8 by proof (no overlong form, no surrogate, nothing
  past U+10FFFF).
* **Semantic preservation.** For every text of the property runs (every
  scalar class: ASCII, `"` `\` `/`, every control, DEL, Latin, the BMP below
  and above the surrogates, U+D000..U+D7FF, supplementary characters; empty;
  2,000 characters), `decode(emit(text)) == text` holds three ways: json.bot's
  decoder in-program over scalar values (`string`, `string_ascii`) and over
  UTF-8 bytes (`string_bytes`, against `std::str::encode_utf8(text)`), and
  CPython's strict parse against the case's canonical JSON (written by the
  test harness with a policy no emitter has: every non-ASCII character
  escaped).
* **Chunk boundaries.** An emitter yields one symbol at a time, so a chunk
  boundary is the sink's: `chunked_stacked` hands a checksum chunks of 64
  symbols, splitting escapes and UTF-8 sequences anywhere, and its checksum
  equals the per-symbol one on every property case; json.bot validates each
  text cut into random chunks of 1-9 symbols.

## 10. Complete JSON

`audit/emitter/json/value_emit.bot`.

**The value.** Botlish has no sum type, so a JSON value is a struct with a
`kind` (an enum of seven cases) and a field for each kind's payload --
`number: int`, `text: str`, `items: List[Value]`, `keys: List[str]` -- the
unused ones empty; recursive struct types make the tree expressible. The cost
is real but small here: every node carries four fields, constructors fill
the unused ones, and nothing stops a Null node from carrying items (the
serializers ignore them). A sum type would remove that, but its absence did
not affect the design of emission; it was not added.

**Three serializers**, all streaming (yields, no document built):

| serializer | structure | fusion | claim |
|---|---|---|---|
| `value` | recursive: a value, then a separator or a closing bracket | kept on the general runtime (its yielding chain is recursive) | **proved** |
| `value_stacked` | an explicit stack of open containers, a loop "start a value" and an inner loop "after a value" | fused | **proved** |
| `value_flat` | the same stack, one loop over popped frames | fused | rejected (`flat-serializer`): the grammar position is data |

**What is proved** against json_grammar's `json_text`: each token is a valid
JSON token, each boundary is one the token accepts (a number or literal ends
before whitespace, `,`, `]`, `}` or the end), no token emitted by a helper
absorbs the next symbol, and the text does not end inside a token. **What
is not**: that separators, colons and brackets make a *document* --
`missing-colon` (two adjacent strings) and `unbalanced` (`[` closed by `}`)
are lexically valid and accepted by the checker; json.bot's structural
validator and CPython reject their output. JSON's nesting is a context-free
(indeed visibly pushdown) language; no declaration of the DFA milestone can
state it, and the experiment did not add one (section 18 says what would).

**Streaming and sinks** (`sinks.bot`): collecting (`collect_*`: a List), a
running checksum storing nothing (`digest_*`), the same in chunks of 64
(`chunked_stacked`), a sink with a limit that fails mid-token
(`limited_text`), a consumer that stops early (`prefix_text`), and a real
one (`demo.bot`: the Linux IO context, UTF-8 chunks to standard output,
CPython parsing what arrives). Per-symbol emission with sink-side chunking
is the protocol measured: fused, a yield is a register move (section 13),
and the buffer the sink adds costs 14% (`documents_chunked`, section 14), so
chunking in the emitter would only move that work; an emitter yielding
*chunks* (substrings) could not be checked at all -- the checker has no fact
about every character of a substring (a quantified fact), and the yield's
value is no symbol (EMIT-NOT-SYMBOL).

## 11. Output boundaries

A JSON number has no terminator: it ends before the symbol after it
(`accept before`) or at the end. A standalone emitter cannot -- and must not --
manufacture that symbol, and the checker never asks it to: a token emitter's
completion feeds *the end*, which json_number accepts in every state with a
complete token. What may follow is read off the declaration, not written
anywhere: the checker reports each claim's boundary, the symbols on which
every exit state ends the token (`accept before`), and whether the end may
(`emit-json-boundaries`):

```
emitter integer emits json_lex::json_number: after it, the end, or '\t'..'\n' '\r' ' ' ',' ']' '}'
emitter string emits json_lex::json_string: after it, nothing (the token completes on its own last symbol)
emitter value_stacked emits json_grammar::json_text: after it, the end only
```

-- json_lex's `after_value` class, recovered from the effective table: no
FOLLOW set restated.

**Composition** is where a boundary is enforced. A caller claiming
json_text calls `integer`; json_text's composite states continue inside
json_number when `integer` returns (the token is still open: it ends only
before its next symbol). The caller's next yield is then decided by
json_number's row: `,` pops it (the token ends before `,`, which json_text
reconsiders: a token of its own), a digit would continue it. The second is
lexically valid -- `[12` `34]` is the number `1234` -- and exactly the
mistake a lexical check misses; the checker reports it as **EMIT-BOUNDARY**
because `integer` claims a *whole* token: at a claimed helper's exit, the
frame of its token's recognizer carries an obligation that the next symbol
end it. A string's token ends on its own quote, so it carries none.

**The end of the input versus the end of a chunk** is the consumer's, as for
recognizers: an emitter never sees chunks. **The end versus early failure**:
a failed emitter's output stops at a viable prefix; a consumer that needs a
complete token or nothing must buffer (design A's buffered form, or a
transactional sink: appendix B).

**Token versus document.** A token claim is about one token; json_text's
claim is about a token sequence; neither is about a document.

## 12. Correctness

### The mistake census

`audit/emitter/tools/census.tcl` applies each of the 31 cases of
`audit/emitter/census/cases.txt` alone to the emitter modules, runs the
checker on `check_all.bot`, then runs the program on the Tcl compiler and
compares every probe's output with the unmutated program's, and a changed
one with the oracle (`audit/emitter/results/census.md`):

| case | mistake | static (EMIT-...) | observed | category |
|---|---|---|---|---|
| `plus-sign` | a `+` sign on a positive number | REJECTED | invalid output (probes 2, 10, 11, 17, 18) | 1 static |
| `minus-only` | a sign, then a return before the digits | INCOMPLETE, REJECTED | invalid output (probes 1, 10, 11, 18) | 1 static |
| `exponent-sign-end` | `1e+`: an exponent sign last | INCOMPLETE, REJECTED | invalid output (probes 1, 2, 10, 11, 17, 18) | 1 static |
| `leading-zero` | the first digit may be 0 (and is) | REJECTED | invalid output (probes 1, 2, 10, 11, 17, 18) | 1 static |
| `leading-digit-latent` | the first digit may be 0 (never is) | REJECTED | unchanged | 1 static |
| `digit-overflow` | a digit 0..10 (10 never reached) | REJECTED | unchanged | 1 static |
| `wrong-digit-value` | semantic: 9 written as 8 | accepted | valid, changed (probes 2) | 4 outside |
| `unguarded-text` | `to_string`'s text without guards | REJECTED | unchanged | 1 static |
| `weak-guard` | the first digit guarded by `digit_symbol` | REJECTED | unchanged | 1 static |
| `terminal-value` | a root completing with 0, not -1 | TERMINAL-VALUE | unchanged | 1 static |
| `end-as-symbol` | -1 yielded as a symbol | END-SYMBOL | invalid output (probes 0, 10, 11, 18) | 1 static |
| `unclosed-string` | no closing quotation mark | BOUNDARY, INCOMPLETE | invalid output (probes 6, 10, 11, 18) | 1 static |
| `after-token` | a space after the closing quote | AFTER-TOKEN | valid, changed (probes 6, 10, 11, 18) | 1 static |
| `raw-controls` | controls written raw | REJECTED | invalid output (probes 6, 9, 10, 11, 18) | 1 static |
| `raw-backslash` | the reverse solidus unescaped | AFTER-TOKEN, BOUNDARY, INCOMPLETE, REJECTED | valid, changed (probes 6) | 1 static |
| `short-unicode-escape` | `\u` with three digits | REJECTED | invalid output (probes 9) | 1 static |
| `hex-digit-off-by-one` | hex letters one too low | REJECTED | valid, changed (probes 7) | 1 static |
| `surrogate-scalar` | code points not checked for surrogates | REJECTED | unchanged | 1 static |
| `unchecked-codes` | code points not checked | END-SYMBOL, REJECTED | unchanged | 1 static |
| `bytes-unencoded` | scalar values sent as bytes | BYTE-CHARACTER, REJECTED | invalid output (probes 8) | 1 static |
| `byte-out-of-range` | a value past 255 sent as a byte | REJECTED | invalid output (probes 8) | 1 static |
| `utf8-by-length` | imprecise: UTF-8 by length (correct) | REJECTED | unchanged | 1 static |
| `strict-escape-unsplit` | imprecise: `\uD0xx` unsplit (correct) | REJECTED | unchanged | 1 static |
| `missing-separator` | no `,` between array elements | BOUNDARY, REJECTED | invalid output (probes 10) | 1 static |
| `missing-colon` | structure: no `:` after a key | accepted | invalid output (probes 10) | 4 outside |
| `unbalanced` | structure: `[` closed by `}` | accepted | invalid output (probes 10) | 4 outside |
| `flat-serializer` | imprecise: `value_flat` claimed (correct) | BOUNDARY, REJECTED | unchanged | 1 static |
| `never-completes` | vacuous: `1`, then ones forever | accepted | not run (never completes) | 4 outside |
| `corrupted-text` | dynamic: a letter appended to the text | accepted | fails: number_emit::NotCanonical | 2 dynamic |
| `surrogate-input` | failure: a surrogate in the input | accepted | fails: string_emit::NotAScalar | 3 failure |
| `member-out-of-range` | failure: a member read past the end | accepted | fails: IndexNotFound | 3 failure |

| category | cases |
|---|---:|
| 1 static | 24 |
| 2 dynamic | 1 |
| 3 failure | 2 |
| 4 outside | 4 |

The categories are the task's: (1) rejected statically; (2) accepted with a
check at run time that fails instead of completing with invalid output; (3)
accepted, the mistake able to make the emitter fail but never complete
invalidly; (4) outside what the guarantee covers.

* **Every lexical mistake is rejected statically** -- a forbidden symbol
  (`plus-sign`), a completion in a nonaccepting state (`minus-only`,
  `exponent-sign-end`, `unclosed-string`), a transition incompatible with the
  emitted value (`leading-zero`), a path that cannot reach acceptance
  (`short-unicode-escape`), the wrong alphabet (`bytes-unencoded`), a byte
  outside 0..255 (`byte-out-of-range`), a surrogate as a scalar value
  (`surrogate-scalar`), a violated boundary (`missing-separator`,
  `after-token`), the end yielded as a symbol (`end-as-symbol`), a wrong
  terminal value (`terminal-value`).
* **Latent mistakes are rejected too**: seven cases leave the probes' output
  unchanged. Three wait for an input the probes do not have
  (`surrogate-scalar` and `unchecked-codes`, a surrogate code point;
  `terminal-value`, a consumer that reads past the end); four never happen
  with this arithmetic or this `to_string` (`leading-digit-latent`,
  `digit-overflow`, `weak-guard`, `unguarded-text`) -- the code *could* emit
  an invalid token, and nothing in it says it cannot. A test suite sees none
  of the seven.
* **Bad data is caught where the claim relies on a check** (category 2:
  `corrupted-text`, a letter appended to `to_string`'s text, fails
  NotCanonical at the letter; the claim still holds), and **a failing code
  path never completes malformed** (category 3: `surrogate-input`, a
  surrogate among `string_codes`' values, fails NotAScalar after its
  prefix; `member-out-of-range` fails IndexNotFound after a key and its
  colon).
* **Three correct emitters are rejected** (`utf8-by-length`,
  `strict-escape-unsplit`, `flat-serializer`): the precision limits of
  section 7. They are the cost of soundness, stated as such.
* **Outside the guarantee, accepted**: a wrong value (`wrong-digit-value`),
  a document's structure (`missing-colon`, `unbalanced`), a non-terminating
  emitter (`never-completes`, which writes `1` then ones forever: every
  prefix valid, never complete, no claim). Note what is *not* in this row:
  an infinite run of zeros is rejected at its second zero, because every
  yield is checked, not only completion.

Several mistakes are reported more than once -- in the emitter's own claim
and in the claims of the serializers that call it -- which is right: each
claim is wrong. EXPECT lists the kinds that must be among them.

### Property-based and differential tests

`audit/emitter/tools/property.tcl` generates integers, texts and value trees
(`support.tcl`'s generator: magnitude classes, scalar classes, depth-limited
trees with empty containers, long strings, large integers, repeated keys),
writes one program that runs every emitter on every case, runs it on
interp, compile, cranelift-generic, cranelift and cranelift-unfused, and
requires:

1. every backend to produce the same outputs;
2. every output to be valid JSON denoting its case for the oracle
   (`audit/emitter/tools/oracle.py`: CPython's json made strict -- no NaN or
   Infinity, duplicate keys kept as pairs, no unpaired surrogate in a decoded
   string, strict UTF-8 -- comparing values against the case's canonical
   text);
3. every token or text to be exactly one token of its recognizer for the
   reference interpreter of tests/dfa-support.tcl, which reads the
   declarations themselves (items compared directly, sequences followed
   symbol by symbol, calls run as nested recognizers) -- nothing of
   surface/dfa.tcl, so not the checker's own model;
4. in-program: every text validated by json.bot (structure included), whole
   and in random chunks; every string decoding back to its text, over scalar
   values and over UTF-8 bytes; the checksum, the chunked checksum and the
   recursive serializer's checksum equal.

| seed | integers | texts | values | outputs held to the oracle and the reference | in-program checks | failures |
|---|---:|---:|---:|---:|---:|---:|
| 1 | 71 | 69 | 37 | 671 | 281 | 0 |
| 2 | 71 | 69 | 37 | 671 | 281 | 0 |
| 3 | 71 | 69 | 37 | 671 | 281 | 0 |

(Each seed takes 6-9 minutes, most of it native lowering of the one large
program on the three native backends.) The harness can fail: with
`-mutate wrong-digit-value` (a census case applied first), a run of seed 1
with 30 integers on the Tcl compiler reports every output that CPython reads
as a different value -- integers, and the texts holding them -- the census's
"valid, changed".

### Negative tests

`audit/emitter/tests/emitter.test` (35 tests): every diagnostic kind with its
location (and the message for most), the facts the checker relies on --
negation through `or`, scalar values and surrogates, the first iteration,
call-site sensitivity, guards, recursion -- each with the counter-case that
must be rejected; the coroutine protocol on every hosted backend (terminal
resumption, failure after a prefix, abandonment, a failing sink, every
prefix viable for the reference interpreter, design A's sinks); a real
streaming sink; a small property run; the witnesses; the native evidence.

## 13. Native evidence

`audit/emitter/tools/evidence.tcl` compiles bench_work.bot's workloads and
keeps each consumer function's fusion report, fused NIR and machine code
(fused and on the general runtime) in `audit/emitter/results/evidence/`;
`summary.md` lists, per consumer, its code bytes, calls, the helpers it
calls, and the table loads (`rtabload*`) and multiway branches (`switch`)
in its fused NIR -- what a recognizer's transitions lower to
(DFA-COROUTINE-MILESTONE-2.md, section 8):

| workload | fused bytes | calls | coroutine helpers | table loads | switches | general bytes | NIR lines, fused / general |
|---|---:|---:|---|---:|---:|---:|---:|
| `ints_static` (proved) | 5,687 | 63 | cold paths only | 0 | 0 | 1,311 | 763 / 199 |
| `ints_text` (guarded) | 3,223 | 51 | cold paths only | 0 | 0 | 1,447 | 560 / 211 |
| `ints_trusted` (unchecked) | 1,807 | 20 | cold path only | 0 | 0 | 1,303 | 345 / 199 |
| `ints_validated` (A) | 6,063 | 81 | cold paths only | 6 | 0 | 3,396 | 865 / 343 |
| `strings_static` (proved) | 3,071 | 19 | cold path only | 0 | 0 | 1,511 | 942 / 205 |
| `strings_validated` (A) | 7,975 | 71 | cold paths only | 4 | 6 | 2,999 | 1,516 / 311 |
| `documents_stacked` (proved) | 14,991 | 99 | cold paths only | 0 | 0 | 1,255 | 3,610 / 179 |
| `documents_validated` (A) | 31,863 | 260 | cold paths only | 24 | 12 | 2,599 | 5,482 / 293 |
| `documents_recursive` (proved) | 1,255 | 26 | `rt_co_create`, `rt_co_start`, `rt_co_resume0`, `rt_co_done`, `rt_co_release` | -- | -- | 1,255 | 179 / 179 |

("Cold paths": the fused consumer calls only `rt_co_resume0` and
`rt_co_failed`, fusion's paths for a resume after completion and a cached
failure raised again: COROUTINE-FUSION-MILESTONE-1.md. NIR lines are the
consumer function's; fused, it holds its emitters' inlined copies, which on
the general runtime are functions of their own.)

* **A proved emitter leaves no grammar behind.** `ints_static`,
  `strings_static` and `documents_stacked` have no table load, no switch and
  no `dfa#transition` anywhere in their programs (`emit-native-no-recognizer`):
  the check happened at compile time and the emitted symbols are computed
  values moved through registers. `ints_text`'s guards are the run-time
  checks it asked for: ordinary calls (two per program text) of the guard
  recognizers' functions, each one byte-table load (`rtabload8`) -- outside
  the consumer, so its column shows none.
* **Validation keeps its recognizer.** The design-A variants carry the
  recognizer's table loads and switches per symbol -- json_number's byte
  table, json_string's switches on its Unicode rows, json_text's and every
  callee's -- and roughly twice the code.
* **Fusion takes every emitter driven where it is constructed**: the reports
  (`*.report.txt`) inline the whole yielding chain -- `integer_source`,
  `integer`, `magnitude`; `string_source`, `string`, `character`, `control`,
  `hex_digit`; for documents, 24 inlined copies of 13 functions -- with no
  `kept`, and no
  coroutine object allocated (`emit-native-allocations`: 0 coroutine
  allocations for 50 tokens). Deep yields through helpers cost nothing.
* **What fusion keeps, by design**: the recursive serializer (`kept ... its
  yielding function value_emit::value is recursive`) and every emitter
  whose handle is passed to a function (`ints_drained`: `sinks::drain`).
  Both run on the general runtime -- a coroutine object, a stack and a
  switch per symbol -- and that is the optimizer's interprocedural limit
  (COROUTINE-FUSION-MILESTONE-1.md, "Limits"), not the emitters'. No
  emitter-specific workaround was added.

## 14. Performance

`audit/emitter/tools/bench.tcl` (`audit/emitter/results/bench.md`) runs
bench_work.bot's workloads natively on cranelift, fused and on the general
runtime: the best of 3 in-process runs, minimum and median over 3
interleaved rounds, in nanoseconds per emitted symbol -- a run's whole time,
the input's construction and every token's coroutine included, each symbol
folded into a checksum sink that stores nothing. The machine is a shared
4-core container (an Intel Xeon at 2.8 GHz): minima repeat within a few
percent, single medians less reliably (`strings_static`: 24.7 minimum, 38.4
median).

### Run time

| workload | what | symbols | general min | fused min | fused med |
|---|---|---:|---:|---:|---:|
| `ints_trusted` | `to_string`'s text, unchecked (the hand-written serializer) | 39,000 | 111.6 | **27.5** | 27.5 |
| `ints_text` | the same text, a guard per digit (proved) | 39,000 | 120.6 | **31.0** | 32.5 |
| `ints_validated` | `ints_trusted` fed to json_number as emitted (A) | 39,000 | 297.0 | **31.1** | 31.6 |
| `ints_static` | digits by comparisons (proved, no check) | 39,000 | 202.3 | **120.8** | 123.5 |
| `ints_drained` | `ints_static` through a reusable sink taking the handle | 39,000 | 319.0 | **322.9** (kept) | 341.8 |
| `strings_static` | `string` (proved) | 116,500 | 102.4 | **24.7** | 38.4 |
| `strings_validated` | `string` fed to json_string as emitted (A) | 116,500 | 264.7 | **29.3** | 29.9 |
| `strings_ascii` | `string_ascii` (proved; two symbols per character here) | 230,750 | 91.8 | **18.2** | 18.2 |
| `strings_bytes` | `string_bytes` (proved) | 150,500 | 96.6 | **20.5** | 21.6 |
| `documents_stacked` | `value_stacked` (proved) | 80,744 | 137.2 | **68.8** | 74.2 |
| `documents_validated` | `value_stacked` fed to json_text as emitted (A) | 80,744 | 315.5 | **83.2** | 84.8 |
| `documents_checked_after` | collected, then json.bot's `validate_scalars` (A, structure included) | 80,744 | 1,188.3 | **149.3** | 151.8 |
| `documents_recursive` | `value` (proved; recursive) | 80,744 | 125.5 | **132.6** (kept) | 137.8 |

Three more workloads isolate two costs (the same run's `documents_stacked`
measured 72.1, fused minimum):

| workload | what | symbols | general min | fused min | fused med |
|---|---|---:|---:|---:|---:|
| `ints_small_trusted` | `ints_trusted` below 10^9 (no BigInt) | 18,775 | 120.5 | **14.7** | 14.7 |
| `ints_small_static` | `ints_static` below 10^9 | 18,775 | 213.0 | **90.9** | 93.6 |
| `documents_chunked` | `documents_stacked`, the checksum fed in chunks of 64 (`chunked_stacked`) | 80,744 | 144.3 | **82.3** | 90.3 |

* **A proof costs nothing at run time.** A proved emitter is the emitter: the
  claim is erased, so "grammar-constrained" and "hand-written" are the same
  code and the same time (`strings_static` *is* the hand-written string
  serializer). What a design choice costs is what it makes the code do:
* **Run-time validation (design A)** costs 13% on integers (31.1 against
  27.5), 19% on strings (29.3 against 24.7) and 21% on documents (83.2
  against 68.8) -- fused, where the recognizer is a table load or a switch
  per symbol inlined beside the emitter (section 13); on the general runtime
  it doubles or triples the time (two coroutines per token). Validating
  afterwards with json.bot's structural validator (which also checks what B
  cannot: structure) costs 2.2x the emission (149.3).
* **A guard** costs what an incremental validation costs (31.0 against 31.1
  for integers): one call and one table load per symbol. It buys more: it
  never lets a bad symbol out, and it is the run-time half of a static
  proof rather than an observation of one run.
* **Arithmetic digits** (`integer`, proved with no check) are the slowest
  integer emitter: 4.4x `to_string` at 19-digit magnitudes and 6.2x below
  10^9 (90.9 against 14.7), where no value is a BigInt. So the BigInts are
  not the main cost (they add about a third per symbol at 19 digits, 120.8
  against 90.9): the per-digit search is (`digit_at`: up to four products,
  comparisons `r >= k * p` and a subtraction per digit, where `to_string`
  is one native conversion), with the vector of powers (three allocations
  per token, 6,002 for 2,000 tokens, against `to_string`'s one, its text).
  The cost is the missing division, not the proof: the proof needs only
  that each digit is one of ten constants.
* **A chunked sink** costs 14% over the per-symbol one (82.3 against 72.1
  in one run): the chunk buffer's store and load per symbol and a loop per
  64. The emitter is the same code; the checksums agree.
* **Fusion matters as much as for recognition**: fused against general,
  1.7-9.5x. What fusion keeps costs the general runtime's price: the
  recursive serializer (1.9x the explicit-stack one, fused) and the
  reusable sink (`ints_drained`: 2.7x the same emitter fused, a coroutine
  object per token and a stack switch per symbol) -- the interprocedural
  limit of
  COROUTINE-FUSION-MILESTONE-1.md, which also bounds recognizers.

### Allocations and code

| workload | allocations, general / fused | coroutine objects, general / fused | code bytes, general / fused |
|---|---:|---:|---:|
| `ints_trusted` (2,000 tokens) | 12,771 / 8,771 | 2,000 / 0 | 3,502 / 3,645 |
| `ints_text` | 12,771 / 8,771 | 2,000 / 0 | 5,536 / 6,236 |
| `ints_validated` | 55,771 / 8,771 | 4,000 / 0 | 7,721 / 9,074 |
| `ints_static` | 25,148 / 21,148 | 2,000 / 0 | 8,999 / 11,756 |
| `strings_static` (2,000 tokens) | 4,003 / **3** | 2,000 / 0 | 4,284 / 4,595 |
| `strings_validated` | 122,503 / **3** | 4,000 / 0 | 9,005 / 10,737 |
| `documents_stacked` (500 objects) | 33,518 / 33,516 | 1 / 0 | 15,957 / 24,638 |
| `documents_validated` | 114,264 / 33,516 | 2 / 0 | 26,290 / 45,269 |

Fused, a string token costs **no allocation** -- 3 for the whole run of
2,000 tokens (the run's own state and result), the emitter's yields and the
recognizer's resume messages living in registers. The integer workloads
allocate the text `to_string` returns (8,771: the BigInt magnitudes and
their texts), the arithmetic emitter its vector of powers and BigInt
products (21,148); the documents the tree they serialize and the explicit
stack's frames (33,516), the same fused or not. Fused code is larger -- a
copy of the emitter per construction and resume (COROUTINE-FUSION-
MILESTONE-1.md's design) -- by 4-54% for one emitter and 1.7x for an
emitter and a recognizer fused together (`documents_validated`).

### Compile time

| | ms |
|---|---:|
| the front end of a workload program (json_lex, json, every emitter module, sinks, bench_work) | 6,200-8,200 |
| native lowering | 480-2,180 |
| the driver's compile, fused | 6-110 |
| `check_all.bot` (22 claims): the front end | 5,260 |
| the specialization and range analysis the checker reads (native lowering computes them too) | 1,973 |
| the checker's walk | 3,239 |

The checker's walk -- about 150 ms per claim, in Tcl, every claim from
scratch, each helper re-analyzed per entry state and per argument context --
is a prototype's cost: a permanent check with modular facts analyzes each
function once per claim, not once per caller. Its inputs (the range
analysis) are what native lowering already computes; on the Tcl backends
they are new work.

## 15. Language impact

**What the prototype needed from the language: nothing.** Emitters are
ordinary functions, the claim is a comment, guards are ordinary recognizer
declarations, sinks are ordinary coroutine consumers. The checker reads HIR
and the DFA models; no syntax, type, HIR node, Core IR form, NIR
instruction, runtime operation or coroutine semantics changed.

**What a permanent version needs:**

* **A claim form.** A directive comment is no language. The natural form
  is a clause of the function declaration, beside `errors` and `proves`:
  `fn integer(n: int) -> unit errors IndexNotFound emits json_lex::json_number:`.
  It is a claim the compiler proves (like `proves`), resolved like any
  qualified name (MISSING-IMPORT, UNKNOWN-SYMBOL), carried by the HIR,
  printed by `hir::format`, read by `hir::read` and interchange.
* **A check after the range analysis.** The claim's proof needs the value
  facts native lowering already computes; the check runs where the
  analyses have run, on the HIR every backend compiles. Its diagnostics are
  ordinary entries (code, location, related locations) through the
  compiler's channels (DIAGNOSTIC-RECOVERY.md), each with a negative test and
  a Compilerpedia topic, and classified in tests/static-compile.test's
  census.
* **Modular facts** (section 17): the prototype's facts are whole-program --
  a function's Ranges are its used instances', and a helper's parameters
  are checked with what its callers pass. A library emitter is therefore
  checked anew in each program, and a function no program calls has no
  facts (EMIT-UNUSED). A permanent check should prove a claim from the
  function's *declaration* (parameter domains: an integer domain is a
  declared range; a refinement is a declared predicate) and use only what
  it declares, so that a claim proved once holds for every caller.
* **The checker's own facts.** The set facts of section 4 (negation through
  conditions, arithmetic on sets, call-site sets, result sets of natives)
  are a second fact system beside `hir::range`. Integrated, they belong in
  the range analysis (an interval-set Range would serve dead-branch
  elimination as well) or must be stated once, with the range analysis's
  own audit -- never maintained twice.

**Readability.** Side by side, conventional and constrained emission are
the same code -- the claim is one line. Conventional:

```
fn string(text: str) -> unit errors IndexNotFound:
    yield 34
    loop i from 0 to text.length():
        character(std::char::scalar_value(text.char_at(i)))
        continue
    yield 34
    unit
```

constrained (the code compiles to the same machine code: the claim is
erased once proved):

```
#: emits json_lex::json_string
fn string(text: str) -> unit errors IndexNotFound:
    yield 34
    loop i from 0 to text.length():
        character(std::char::scalar_value(text.char_at(i)))
        continue
    yield 34
    unit
```

and where they differ, the constrained form is *more* explicit, not less:
the UTF-8 encoder in nine branches (one per lead class, each with its range)
instead of four; `integer_text`'s structure (zero; sign; a nonzero first
digit; digits) instead of "copy the text"; the serializer's two loops. A
reviewer reads the claim instead of re-deriving JSON's lexical grammar from
the code, and a diagnostic names the state and its declaration. The cost is
paid where the checker is imprecise: an author who writes a correct
four-branch UTF-8 encoder is told it may be wrong, and must restructure (or
not claim). Line count is not the measure here: `string_emit.bot` is about
the same size with or without claims; what changes is that its correctness
argument moved from a comment to a proof.

## 16. Security implications

**What is guaranteed.** For every input value, statically: a string emitter
proved against json_string cannot complete with an unescaped quotation mark,
reverse solidus or control character in the token -- the classic injection of
a value into a JSON document; a byte emitter proved against
json_string_bytes cannot complete with invalid UTF-8 (no overlong form, no
encoded surrogate, nothing past U+10FFFF) -- the classic smuggling vector
between a validating and a non-validating parser; a number emitter cannot
complete with a non-number; a serializer proved against json_text cannot
emit a token that merges with its neighbor. These hold for inputs the tests
never generated, which is the difference from a well-tested serializer.

**What is not.** Structure (a missing colon, an unbalanced bracket: an
injection of structure through a structural bug is not excluded); values
(a wrong number is valid); termination and output size (an emitter may run
forever or emit without bound: a consumer that needs a bound imposes it, as
`limited_text` does); partial output (a failure or an abandonment leaves a
viable prefix in the sink: a consumer that forwards to a peer must buffer
or discard); side channels and timing.

**Trust boundary.** The claim is only as good as:

* **the grammar** -- a recognizer of the wrong language makes every emitter
  proved against it wrong in the same way (the DFA milestone's census: two
  grammar mistakes survive its differential tests);
* **the range analysis** -- until now a representation analysis: a wrong
  Range miscompiled (raw integers, dead-branch elimination); with emission
  claims, a wrong Range would also prove a false claim. Integrating makes its
  soundness a security property, and its audits (fuzzers, mutation) should be
  read as such;
* **the checker's rules** -- the set facts, the arithmetic on sets, the
  first-iteration rule, the native result sets (scalar_value), and Step and
  Pop's restatement of the run semantics: each is a place a bug would admit
  a false proof. The prototype's tests pin each rule with a counter-case,
  and the census's static row is evidence of power, not of soundness; a
  permanent version needs its own mutation audit (section 18);
* **the guards** -- a guard proves what the guard recognizer accepts, so a
  guard declared from the wrong class proves the wrong thing (`weak-guard`
  is rejected only because `digit_symbol`'s `0` then meets json_number's
  `zero` state);
* the compiler, the runtimes and the platform, as for every program.

An emitter's code may be wrong in ways the claim cannot see; it cannot be
wrong in the ways the claim names.

## 17. Recommendation

**Revise, then integrate narrowly.**

The experiment met its acceptance criteria:

* existing DFA declarations constrain emission without restating the
  grammar (section 7) -- the one new declaration composes json_lex's;
* working JSON integer, string and document emitters, associated with the
  existing number and string grammars (sections 8-10);
* defined semantics for completion, failure, partial streaming output,
  abandonment and terminal resumption, all ordinary coroutine semantics
  (section 6);
* a construction-safety guarantee beyond running the recognizer afterwards:
  every lexical mistake of the census rejected at compile time, latent
  ones included, for every input, at zero run-time cost (sections 12-14);
* negative tests of its scope, differential and round-trip evidence, native
  allocation and code evidence, fusion compatibility (sections 12-14).

It deserves permanent integration because it is the rare check that is
*both* stronger and cheaper than the alternative: design A pays per symbol
and finds a bug on the input that triggers it; B pays once at compile time
and finds it for all inputs -- with the same declaration, ordinary
coroutines, and fusion untouched. It should not be integrated as
prototyped, for three reasons the evidence makes concrete:

1. **Whole-program facts.** A claim proved from the facts of one program's
   uses is not a property of the function. The permanent check must prove a
   claim from the function's declared parameter types (integer domains,
   refinements) and the facts of its own body, as the range analysis does
   for declared contracts.
2. **Two fact systems.** The checker's set facts must live in (or be
   derived from) the range analysis, audited once.
3. **Two statements of the run semantics.** The emission automaton's step
   must come from the same statement as the recognizer's lowering.

The smallest viable production milestone is next.

## 18. Next steps

**Emission claims, milestone 1** (if accepted):

* the `emits R` clause (parser, HIR field, `hir::format`/`hir::read`,
  interchange, the front-end cache key unchanged: the clause is source);
* `hir/emission.tcl`: the check, after the range analysis, on modular facts
  (a function's declared parameter domains; no caller facts), with the
  diagnostic kinds of section 4 (EMIT-UNUSED disappears: no claim depends on
  callers), structured and located, each with a Compilerpedia topic, a
  negative test and a row in the static-compile census;
* interval-set Ranges in hir/range.tcl (negation, `!=`), or the checker's
  facts restated there once;
* the emission step derived from surface/dfa.tcl's `Codes` (one statement of
  call, accept and reconsideration for both the lowering and the check);
* a mutation audit of the check (`audit/emission/tools/mutate.tcl`: each
  rule's mutant killed by a test) and a fuzzer generating emitters with
  planted mistakes, as every analysis of the compiler has;
* JSON's emitters moved beside json_lex.bot in examples/dfa/json, the
  benchmark into bench/.

**Beyond it, not proposed here:**

* **Relational facts** for the cases of section 7 -- a fact of a symbol
  conditioned on an earlier one -- would accept the four-branch UTF-8
  encoder. The evidence says the cost (a relational domain in the range
  analysis) is not justified by the workload: the grammar-shaped encoder is
  as readable and proved today.
* **Structure.** JSON's nesting is a visibly pushdown language: brackets
  are the calls and returns of a stack the serializer's recursion mirrors.
  The checker's interprocedural summaries are exactly the machinery a check
  against a visibly pushdown grammar needs; a declaration form for one
  (`grammar` beside `dfa`?) is a language design of its own.
* **Interprocedural fusion** (DFA-COROUTINE-MILESTONE-2.md, "Next steps")
  would fuse the recursive serializer's general-runtime cost away and let a
  reusable sink take a handle -- no change to emitters.
* **Decimal and floating-point numbers** (DecimalRounded's text, Float64's)
  are emission policies of their own; json_number already states their
  syntax.

## A. Generation from the grammar

`audit/emitter/tools/witness.tcl` walks the same emission automaton
breadth-first (`emitcheck::Step`), one representative symbol per segment of
each composite state's row (a letter or digit where the segment has one),
and gives for each recognizer its shortest token and a coverage witness per
transition -- the shortest token that takes it -- each held to the reference
interpreter and, for JSON tokens, to the oracle
(`audit/emitter/results/witnesses.md`):

| recognizer | composite states | transitions | shortest token | witnesses accepted (reference) |
|---|---:|---:|---|---:|
| json_number | 9 | 17 | `0` | 13/13 |
| json_literal | 12 | 13 | `true` | 3/3 |
| json_string | 8 | 10 | `""` | 4/4 |
| json_string_strict | 17 | 21 | `""` | 6/6 |
| json_string_bytes | 15 | 24 | `""` | 11/11 |
| json_token | 27 | 41 | `,` | 21/21 |
| json_text | 26 | 52 | (the empty text) | 32/32 |
| utf8_char | 9 | 14 | `\xC2\x80` | 7/7 |

json_number's witnesses are `-0 -1 0 0e+0 0e0 0e00 0.0 0.0e0 0.00 1 1e0 1.0
10`; json_string_strict's include `"\udaaa\udcaa"` (a pair) and `"\ud0aa"`
(not one). This is a grammar-analysis capability -- test inputs, recognizer
coverage, examples for documentation -- not an emitter: the shortest valid
string of a state is no serialization of a value. What makes emission
interesting is the other direction, a value *directing* the choice of
transition with a proof that the path completes: sections 4-10. (json_text's
witnesses are not all JSON texts -- the empty text, a lone `,` -- because its
language is the lexical layer, weaker than a document: CPython accepts 25 of
32.)

## B. Relationship to reversible coroutines

Emission needs no reversible execution and no rollback: the claim is about
successful completion, and a failed or abandoned emitter's output is a viable
prefix the sink already holds. One use case for transactional output did
appear and is recorded for that work, not this: a consumer that must pass on
*a complete token or nothing* (to a peer that cannot handle a truncated
value) buffers a token today (design A's buffered form, `buffered_integer`);
with B, the buffer is needed only for failure atomicity -- never for
validity, which the claim already gives.

## C. Files

* `audit/emitter/tools/emitcheck.tcl` -- the emission checker (library and
  command line);
* `audit/emitter/json/` -- `json_grammar.bot` (json_text, guards: composed
  from json_lex), `number_emit.bot`, `string_emit.bot`, `value_emit.bot`
  (the emitters), `sinks.bot` (consumers and design A), `check_all.bot` (the
  program the claims are checked in), `bench_work.bot` (the benchmark
  workloads), `demo.bot` (streaming to standard output);
* `audit/emitter/tools/` -- `workspace.tcl` (the JSON workload's modules
  copied beside the emitters), `census.tcl` with `census/cases.txt`,
  `property.tcl` with `support.tcl` and `oracle.py`, `witness.tcl`,
  `bench.tcl`, `evidence.tcl`;
* `audit/emitter/tests/emitter.test` -- the tests (`tclsh9.0
  audit/emitter/tests/emitter.test`; not part of tests/local.tcl or CI);
* `audit/emitter/results/` -- `census.md`, `witnesses.md`, `bench.md`,
  `evidence/`.
