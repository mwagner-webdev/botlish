# Language design principles

Normative principles that constrain Botlish's design: the rules a language
feature must keep, beyond the rules of any one feature. Each is stated once,
here; feature documents refer to it by name. A feature that would depart
from one needs an explicit language-design decision, recorded in that
feature's design document and in this one -- never a departure that falls
out of how the compiler happens to compute something.

1. SFIAE -- Substitution Failure Is An Error
2. One dependency graph, binding locks

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

## 2. One dependency graph, binding locks

> Ordinary dependencies are shared by identity within one resolved
> application. Their authors' declared constraints and locks remain binding.
> The package manager constructs one coherent dependency graph or rejects
> it; it never creates incompatible private instances or silently rewrites a
> dependency contract to make a program compile.

(SHARED-PACKAGE-DEPENDENCIES-MILESTONE-1.md.) The terms are distinct:

* a **package declaration** is a package's `botlish.json`: its name, its
  version, its direct dependencies and its locks;
* an **ordinary dependency edge** is one package (or the application)
  depending on another: declared, requested and locked, never discovered;
* a **locked requirement** is the exact release a package's author built
  and tested it with: the author's contract, which no consumer, no other
  package and no tool may change;
* a **canonical resolved instance** is the one installation of a package in
  the application's graph, at the one version every lock of it names, used
  by every scope that depends on it;
* **physical installation paths** (`.bot_modules/NAME`, a target view) are
  where an instance's files are, which is not what it is: its identity is
  its name in the graph, whatever directory holds it;
* **module and type identity** follows the instance: one instance, one
  module per namespace, one nominal type per declaration, one context type;
* **context installation authority** is unchanged: only the entry program
  installs contexts, and sharing a package grants no package that
  authority.

Consequences, which a feature must keep:

* No peer dependencies. A library declares what it uses like any
  dependency; it is shared because the graph has one instance of each
  package, never because it is declared differently or because the
  application installs it on the library's behalf.
* No override of a lock. The application cannot override a package's lock
  any more than a package can override the application's: a graph whose
  locks disagree is refused with every lock and the path that brings it.
* No fallback instance and no search: a conflict is never resolved by a
  second instance, by the first version visited, by linker order, by a
  version the compiler finds compiles, or by a package the program happens
  to see.
* No ambient visibility. Sharing an instance is not making it visible: a
  scope imports exactly the packages it depends on.
* Determinism: equal declarations, locks and artifacts give equal graphs
  and equal reports, whatever the order of declarations, repositories or
  traversal.

A feature that would depart from one of these -- a version range resolved
by search, an override, two instances of one package in one program -- is a
language-design decision, to be argued and recorded explicitly.

### Where it is enforced

* pm/graph.tcl (resolution: unification of exact locks, conflicts, cycles,
  artifact identity) and the commands that choose versions (`add`'s held
  version, `update`'s hold), pm/install.tcl (one directory per package, the
  graph file in the transaction).
* surface/modules.tcl's package graphs (BOT-MODULES-MILESTONE-1.md, "Target
  package trees" and the header's "Package graphs"): a scope of the graph
  sees the packages the graph says it uses, each the one instance named by
  its name.
* tests/package-manager.test's `pm-shared-*`, `pm-two-versions-conflict`,
  `pm-conflict-deterministic`; tests/bot-modules.test's `bm-graph-*`;
  tests/package-workloads.test's `pw-shared-*`; the mutants of
  audit/package-manager and audit/bot-modules that relax a lock, select a
  version silently or give a shared package two identities; the fuzzer
  audit/shared-dependencies/tools/fuzz.tcl against its independent
  resolver.
