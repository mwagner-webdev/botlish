# Language design principles

Normative principles that constrain Botlish's design: the rules a language
feature must keep, beyond the rules of any one feature. Each is stated once,
here; feature documents refer to it by name. A feature that would depart
from one needs an explicit language-design decision, recorded in that
feature's design document and in this one -- never a departure that falls
out of how the compiler happens to compute something.

1. SFIAE -- Substitution Failure Is An Error

## 1. SFIAE -- Substitution Failure Is An Error

> **Failure to satisfy a selected operation's obligations is an error, not
> an invitation to select another operation.**

Precisely: once an operation is selected according to its established
applicability rules, failure to discharge its obligations makes that
operation invalid. It does not cause the compiler to search for an
alternative operation.

The name is a mnemonic, contrasting with C++'s SFINAE ("substitution failure
is not an error"), under which a failure inside a candidate removes it from
consideration so that another is chosen. It is not C++ terminology adopted,
nor a claim that Botlish substitutes templates: Botlish has no templates and
no conventional function overloading (METHOD-SUGAR.md, "Several
candidates").

### Applicability and obligations

Two questions, answered separately and in this order:

* **Applicability: which operation does the program denote?** Answered by
  the language's explicit applicability rules, from the call's arguments
  and the visible declarations. Two selections exist today. Method syntax:
  `x.f(args)` is the one visible function `f` whose ordinary call
  `f(x, args)` is valid (METHOD-SUGAR.md) -- its arity, its flags, the
  receiver's and the arguments' admission by the declared and inferred
  parameter contracts, domains and refinements, native parameter kinds,
  nominal and structural struct types and trait constraints, imprinting,
  the validity of the callee's semantic instance for the argument types,
  and the place and ownership requirements that admit the supplied
  arguments (METHOD-RESOLUTION-CORRECTNESS-MILESTONE-1.md, "What judging a
  candidate needs"). And a context-trait operation: it is the
  implementation of the one installed context that satisfies the trait
  (CONTEXT-TRAITS.md, "Selection").
* **Obligations: can the selected operation be used here?** What it
  requires of the place and the environment where it is called, beyond
  its arguments:
  * its declared errors are handled or admitted where it is called
    (`UNHANDLED-ERROR`), and it is not proven to always fail
    (`KNOWN-ERROR`);
  * the contexts it requires are installed where the call runs
    (`MISSING-CONTEXT`), and each context trait it requires has exactly one
    installed implementation (`MISSING-CONTEXT` for none,
    `AMBIGUOUS-CONTEXT-IMPLEMENTATION` for several; CONTEXTS.md,
    CONTEXT-TRAITS.md);
  * the direct authority it uses is acknowledged or mediated by the calling
    module (`DIRECT`, DIRECT-MODULES.md).

A failed obligation is a diagnostic of the selected operation's call. It
never

* removes an otherwise applicable candidate,
* prefers one applicable candidate to another,
* resolves an ambiguity between applicable candidates,
* makes the operation a program denotes depend on its environment (what is
  installed, what handles an error, which module mediates), or
* introduces an implicit fallback or a ranking.

### Rationale

What a call means should be readable at the call: from its arguments and
the visible declarations, by rules the language states. Obligations are
facts of the environment the call runs in. If they selected operations,
installing a second context, removing a handler or moving a call into
another function would silently change which function runs instead of
producing an error; the error the programmer sees would be about some
other candidate than the operation they meant; and explaining a call would
need the whole environment. Under SFIAE a failed obligation is reported
where it is, about the operation the call denotes, and the remedies are
the explicit ones: discharge the obligation (install, handle, mediate) or
name the operation (the qualified spelling).

### Examples

**Declared errors.** `alpha::g(x: int) -> int errors alpha::Bad` and
`beta::g(x: int) -> int`, both imported: `n.g()` on an Int is
`AMBIGUOUS-METHOD-CALL` (alpha::g, beta::g) whether or not anything handles
`alpha::Bad` -- never beta::g because it raises nothing. With `gamma::g(x:
str)` in beta's place, the call is alpha::g's, and an unhandled `alpha::Bad`
is its `UNHANDLED-ERROR`.

**Context requirements.** `alpha::f(x: int, context e: env::Env)` and
`beta::f(x: int)`, both imported, with two contexts `ca::CA` and `cb::CB`
implementing the context trait `env::Env`:

```
with context ca::CA {k: 1}
with context cb::CB {k: 100}
7.f()                 # AMBIGUOUS-METHOD-CALL (alpha::f, beta::f)
```

The call is just as ambiguous with one of them installed, or none: what is
installed decides nothing. `beta::f(7)` says which is meant. With
`gamma::f(x: str)` in beta's place, `7.f()` is alpha::f's call under every
installation: it runs with one provider, is `MISSING-CONTEXT` with none and
`AMBIGUOUS-CONTEXT-IMPLEMENTATION` with both -- never `NO-APPLICABLE-METHOD`,
never gamma::f -- exactly the diagnostics of the qualified `alpha::f(7)`
(`tests/method-resolution.test`, `mr-sfiae-*`).

**Competing context implementations.** The provider of a required context
trait is the one installed context that implements it (CONTEXT-TRAITS.md,
"Selection"): two are ambiguous, with no ranking. A provider whose
implementation needs a context nobody installed is still a provider: alone,
the call is `MISSING-CONTEXT` through the implementation; beside another
provider, the call is ambiguous -- the other is not chosen because this one
cannot be used (`ct-implementation-obligations-select-nothing`).

### Boundary

* **Applicability still rules candidates out.** Method syntax considers
  every visible candidate and rejects those whose ordinary call is not
  valid; a rejected candidate's diagnostics are why it is not applicable
  (listed by `NO-APPLICABLE-METHOD` when none is), never errors of the
  program. SFIAE concerns the obligations of an operation that is
  applicable: it does not make every unsuccessful trial a user-visible
  error, and it does not turn an established applicability check (an
  argument's ownership role, a place, an instance's validity) into an
  obligation because a candidate failed it.
* **Meaning, not execution strategy.** An implementation may fall back from
  a specialized to a general way of running the same operation when it
  cannot prove a precondition (coroutine fusion keeping the general runtime,
  a semantic instance declined at its budget): what the program denotes is
  unchanged, so no operation is selected.
* **Explicit observation is no implicit selection.** `static compile:`
  (STATIC-COMPILE.md) reifies a block's rejection as an ordinary
  `std::compiler::CompilerError`, which the program handles in code it
  writes. The compiler selects nothing; a handler that runs other code is
  the program's own, visible decision, made by a feature designed for it.

### Future features

SFIAE is a design constraint on every future feature that involves
selection, fallback, effects, capabilities, contextual dependencies or
other obligations -- overloading, default implementations, trait-method
resolution, effect handlers, capability-dependent behavior. Botlish
deliberately offers no substitution-failure-driven fallback for
obligations: a mechanism that would select a different operation because
another one failed an environmental or post-selection obligation is a
language-design decision, to be argued and recorded explicitly, and is
never to arise from an implementation detail (such as a diagnostic counted
as a candidate's problem).

### Where it is enforced

* The method-call decision (`hir/methods.tcl`): a candidate is judged by
  its call's own problems, the diagnostics whose `subject` is the call
  (`hir::CheckingCall`), minus `hir::methods::ObligationKinds` --
  `UNHANDLED-ERROR`, `KNOWN-ERROR`, `UNDECLARED-ERROR`, `MISSING-CONTEXT`,
  `AMBIGUOUS-CONTEXT-IMPLEMENTATION`, `DIRECT` and the ambiguity check
  itself. The same list says which diagnostics reject no argument of a call
  for diagnostic recovery (`hir/recovery.tcl`).
* Context-trait selection (`hir::contexts::Obligations`): providers by
  satisfaction alone; the selected implementation's requirements are
  obligations of the call.
* SFIAE-MILESTONE-1.md has the evidence: the tests above,
  `dr-obligations-reject-no-argument`, the method-call oracle's
  `-contexts 1` (`audit/method-resolution/tools/oracle.tcl`) and the
  mutants that restore obligations as evidence against a candidate.
