# C-CONTEXTS-FREESTANDING-MILESTONE-1: statically resolved Botlish contexts in freestanding C, without a dependency-injection runtime

Completion report. The C backend (`main.tcl -emit-c`,
C-COMPILE-FREESTANDING-MILESTONE-1.md) now compiles Botlish programs that use
contexts, context traits, injected capabilities and context composition to
freestanding C11. A context struct is an ordinary C struct; `with context
EXPR` stores the value in an object of the run's own frame; every
function whose requirement is not empty takes one `T *` parameter per
context it requires; every call passes the callee's requirement on. There is
no registry, no lookup, no global context, no dispatch and no new runtime
service, and the generated C of an application's two configurations links
into one executable, hosted or with no C library at all.

> Contexts describe an application's dependencies and authority. The C
> backend translates those relationships; it does not invent a second
> context system.

Evidence is marked throughout as **[inspection]** (read in the code),
**[test]** (an assertion of `tests/c-compile.test`, which runs in the
ordinary suite), **[run]** (a compiler, linker or program actually run during
this milestone, with the command), **[emulated]** (run under qemu-user, an
emulator, not hardware) and **[design]** (an intention not implemented).
Nothing here was run on embedded hardware.

## Contents

1. Outcome and acceptance status
2. Existing context architecture census
3. Context representation in analyzed HIR
4. Comparison with the interpreter, the Tcl compiler and native lowering
5. C representation and generated-code examples
6. Context construction and installation
7. Transitive dependency handling
8. Context traits and dispatch
9. Context instance independence
10. Capability and authority preservation
11. Value, ownership, `place` and error semantics
12. Runtime-service manifest integration
13. Freestanding compilation and execution
14. Cross-backend parity tests
15. Supported and unsupported constructs; diagnostics
16. Existing regression results
17. Known limitations
18. Recommended next milestone
19. Files, and what to run when changing this

---

## 1. Outcome and acceptance status

**Implemented.** In `ccompile/ccompile.tcl` (no file of `hir/`, `core/`,
`surface/`, `compiler/` or `native/` changed):

* context structs as C structs (the backend refused them before);
* `context#install` as an object of the program function's frame;
* the transitive requirement (`requiredContexts`, computed by
  `hir/contexts.tcl`) as `T *` parameters of every instance's C
  function, passed on at every call (`ContextArgs`);
* `context#load` (a context parameter) as no C variable at all: its uses read
  through the pointer, a projection is `ctx_T->field`;
* the dead-code placeholder `context#unreachable` as the Tcl backends' own
  error, as a status (never a trap or an exit);
* a lenient HIR that failed context verification is refused with its first
  context diagnostic, as native lowering refuses to run one;
* `C UNSUPPORTED` that names a context struct and the reason (a member of an
  unsupported type, affine state) at each use;
* the header's reentrancy sentence now says what is true of each program.

Outside the compiler (`examples/c-freestanding/`): an application whose
dependencies are contexts (`contexts/`, section 5), a harness that runs two
generated programs interleaved in one executable (`harness/two_apps.c`), an
entry hook in the freestanding startup (`harness/linux_start.c`
`-DBOTLISH_START_ENTRY`), and a fourth demonstration in `demo.sh`.
`tests/c-compile.test` has 21 new tests (61 in all; section 14).

| # | acceptance criterion | status | evidence |
|---|---|---|---|
| 1 | real programs using contexts compile to freestanding C | met | [test] `cc-parity-contexts`, `-context-traits`, `-context-errors`, `-context-mod-zero`, `cc-ctx-application`; [run] section 5 |
| 2 | construction, injection and calls preserve existing semantics | met | [test] the four parity programs and the application against interp, compile and cranelift, gcc and clang at -O0 and -O2 |
| 3 | transitive dependencies without a runtime registry | met | [test] `cc-ctx-requirements-are-signatures`, the application (shop -> payment -> clock); [inspection] section 7 |
| 4 | statically resolved context-trait operations compile correctly | met | [test] `cc-parity-context-traits`, the application (two context traits); section 8 |
| 5 | two independent configurations coexist in one executable without unintended sharing | met | [test] `cc-ctx-two-apps`, `-two-apps-freestanding`, `-two-apps-cross`, `cc-ctx-installed-in-the-run`; [emulated] AArch64, RISC-V 64, s390x, ARMv7 |
| 6 | a nontrivial context program builds and runs with no libc, heap or Botlish runtime service | met | [test] `cc-ctx-two-apps-freestanding` (no undefined symbol), `cc-ctx-freestanding-objects`; [run] section 13 |
| 7 | declared-error propagation and capability rules preserved | met | [test] `cc-parity-context-errors`, the application's Declined path, `cc-ctx-unverified-refused`; section 10 |
| 8 | no weakening of value, `place`, ownership or identity semantics | met | section 11; [test] `cc-parity-contexts` (a context stored, returned, displayed) |
| 9 | manifests account for dependencies introduced through context calls | met | [test] `cc-ctx-manifest-transitive`, `cc-ctx-big-int-field`, `cc-ctx-application` (none) |
| 10 | unsupported cases reported explicitly, never malformed C | met | [test] `cc-ctx-unsupported`, `cc-ctx-unsupported-around-contexts` |
| 11 | existing C correctness tests and other-backend regressions pass | met | section 16 |

Criterion 5 met in the only sense the language gives it (section 9): an
application *instance* with its own dependencies is a Botlish entry program;
one program has exactly one execution environment.

## 2. Existing context architecture census

Established before the implementation, by reading CONTEXTS.md,
CONTEXT-TRAITS.md, RESTRICTED-CONTEXT-INJECTION-MILESTONE-1.md,
CONTEXT-OWNED-AFFINE-STATE-MILESTONE-1.md, `hir/contexts.tcl`,
`core/contexts.tcl`, `native/lower.tcl`'s context section and the context
test files, and by dumping the HIR of probe programs [inspection, run].

1. **Declaration, construction, injection.** `context struct T:` (or
   `opaque context struct`) is one boolean of the one struct declaration
   (`hir::structs::isContext`); a context is constructed like any struct
   value (a literal, or any function returning one). `with context EXPR`
   installs EXPR's value; it is allowed only at the entry program's top level,
   as a statement (and in a thread entry's body). A function declares what it
   uses directly as a context parameter section, `fn f(x, context io: T)`;
   a call never mentions a context (`f(x)`).
2. **Context traits.** `context trait IO: fn write_text(text: str) -> unit`
   is an environment abstraction; a concrete context struct satisfies it
   structurally, through its own module's functions; at every top-level call
   the one installed context implementing it is selected (none:
   MISSING-CONTEXT; several: AMBIGUOUS-CONTEXT-IMPLEMENTATION), one selection
   per trait per program.
3. **Composition and transitive dependencies.** `direct(B)` is the context
   types block B's own region loads; `required(B)` is `direct(B)` united with
   `required(E)` for every block E that B's region calls, a least fixed point
   over the call graph, unreachable calls excluded (`hir::contexts::verify`).
   A context-trait implementation's own requirements are the requiring
   call's obligations.
4. **Resolution of context operations.** Entirely before any backend: an
   exact context's load is `context#load("ID")`; a context-trait operation is
   rewritten by the trait plan (`hir::traits::Plan`, build 2) into a direct
   call of the selected context's implementation, inside a clone of every
   function whose requirement includes the trait (`f<Trait=Context>`).
5. **Contextual calls in analyzed HIR.** Ordinary `call` nodes of `block`
   targets. The requirement is a field of each block (section 3); nothing on
   the call carries a context.
6. **What a context is.** An ordinary immutable value of a struct type,
   *placed* in the execution environment: a binding names it, nothing else
   reaches it. Not a reference, a singleton, a capability object or a
   service.
7. **Identity, state, lifetime.** Identity is the canonical identity of the
   context-struct type (`std::linux::io::LinuxIO`, `Clock`), nothing else; at
   most one installed value per type; available from its `with context` line
   to the end of the run; never replaced, never uninstalled. State is the
   value's fields, immutable, except collection members mutated in place and
   affine members the installation owns
   (CONTEXT-OWNED-AFFINE-STATE-MILESTONE-1.md).
8. **Several instances of one context type.** Impossible in one program:
   DUPLICATE-CONTEXT. Two providers of one context trait installed at once:
   every call needing the trait is AMBIGUOUS-CONTEXT-IMPLEMENTATION.
9. **Interaction with `place`, ownership, errors, specialization.** A context
   parameter is no owner (`hir::affine::IsContextBinding`): reaching into an
   installed context is a *context place*; affine state is observed where it
   is stored (AFFINE-CONTEXT-COPY-OUT otherwise). Errors cross context
   boundaries as for any call. The requirement is per block, so every
   specialized instance of a block has the same requirement; a trait clone is
   a block of its own with its own requirement.
10. **The other backends** (section 4): the Tcl backends keep one dict keyed
    by identity per run (`core::contexts::installed`, inside
    `core::contexts::fresh`); native lowering assigns each installed type a
    fixed slot in the Vm's context area and loads words from it, with no
    hidden argument.

**Which decisions are made before C lowering** [inspection]: all of them.
Every load names its identity in a literal; every installation's identity
is verified and recorded on the call (`installs ID`); every block carries
its sorted transitive requirement; every context-trait operation is a direct
call of its implementation in the monomorphized program; every inject block
is an `if true:` whose restriction has been proven. No backend reconstructs
a context relationship -- native lowering derives slot *layout* from the
installations, nothing more -- and the C backend reconstructs none either.

## 3. Context representation in analyzed HIR

The example application `examples/c-freestanding/contexts/store_bench.bot`
(section 5), as `main.tcl -hir` prints it (excerpt, long lines cut) [run]:

```
struct simclock::SimClock name SimClock ns simclock context fields start: int[simclock::HalfDay], offset: int[simclock::HalfDay]
struct terminal::Terminal name Terminal ns terminal context fields limit: int[payment::Amount], fee: int[payment::Cents]
trait clock::Clock context owner clock requires now() -> int[clock::Tick]
trait payment::Payment context owner payment requires authorize(amount: int[payment::Amount]) -> payment::Receipt errors payment::Declined
traitfn shop::sell (price: int[payment::Amount]) -> shop::Sale clones (shop::sell<payment::Payment=terminal::Terminal>)
traitfn terminal::authorize (amount: int[payment::Amount]) -> payment::Receipt clones (terminal::authorize<clock::Clock=simclock::SimClock>)
        e14 block s8 () ... contexts (simclock::SimClock) requires (simclock::SimClock) ...      simclock::now
                e16 call native(context#load) : simclock::SimClock
e25 bind b9 context#503 : simclock::SimClock
e29 call native(context#install) installs simclock::SimClock : unit
    e31 ref b9 context#503 : simclock::SimClock
    e40 block s10 () ... contextclone (clock::Clock=simclock::SimClock) contexts () requires (simclock::SimClock) ...
        e41 call block(e14) contexttrait clock::Clock.now witness simclock::SimClock : int[clock::Tick]
    e44 block s11 (b14 amount:...) ... contextclone (clock::Clock=simclock::SimClock) contexts (terminal::Terminal) requires (simclock::SimClock, terminal::Terminal) ...
    e63 block s14 (b18 price:...) ... contextclone (payment::Payment=terminal::Terminal) contexts () requires (simclock::SimClock, terminal::Terminal) ...
                e66 call block(e44) contexttrait payment::Payment.authorize witness terminal::Terminal : payment::Receipt
```

What the C backend reads [inspection]:

| HIR fact | read by | C |
|---|---|---|
| `hir::contexts::installId` of a `context#install` call | `Install` | `T ctx_T = VALUE;` in the program function |
| `hir::contexts::loadId` of a `context#load` call bound to a context parameter | `Bind`, `ContextValue` | the local names `(*ctx_T)`; no C variable |
| `requiredContexts` of the callee instance's block (`hir::contexts::required`) | `ContextArgs`, `Function` | the callee's pointer parameters and the arguments passed |
| `hir::structs::isContext`, `IsAffine`, `fieldTypes` | `StructAggregate`, `ContextRepr` | a C struct, or C UNSUPPORTED naming the context |
| an `if` with `injects` (an inject block) | nothing new: the ordinary `If` | its body, under `if (true)`'s constant condition |
| `context#unreachable` | `NativeCall` | its arguments, then the status `CORE SEMANTIC UNREACHABLE` |

The `contexttrait ... witness ...` annotation on a call is a record of the
plan, not something to act on: the call's target is the implementation's
block, and the C backend compiles it as the ordinary direct call it is.

## 4. Comparison with the interpreter, the Tcl compiler and native lowering

| | interp, compile (Tcl) | cranelift (native) | C (this milestone) |
|---|---|---|---|
| installed storage | `core::contexts::installed`, a dict keyed by identity, per run (`core::contexts::fresh`) | the running Vm's context area: one fixed slot per installed type, flattened to 64-bit leaves | an object of `PREFIX_program`'s frame, per run |
| install | `dict set installed ID VALUE` | `contextstore OFFSET %leaf` per leaf | `T ctx_T = VALUE;` |
| load | `dict get installed ID` | `contextload OFFSET` per projected leaf; an object built only where needed | the pointer parameter; a projection is `ctx_T->f` |
| how a function reaches it | the process-wide dict | the Vm argument every native function already receives | an explicit `T *` parameter per required context |
| a function's authority visible in its signature | no | no | yes: exactly `requiredContexts` |
| context traits, inject blocks | gone before the backend (monomorphized program; `if true:`) | gone | gone |
| unverified program | the semantic error when the load runs | the first context diagnostic at start | refused at compile time with the first context diagnostic |
| members it can hold | any value | small-domain Ints, Bool, unit, chars, enum cases, C address words, collection headers (CONTEXT-NATIVE-LOWERING-UNSUPPORTED otherwise) | any value C represents: Ints of any size (an unbounded field is a `botlish_rt_v1_int`), Bool, unit, enums, structs, List literals |

The C choice of explicit parameters over native's environment base pointer
is deliberate [design rationale, implemented]: one environment pointer would
hand every function every installed context, which is more than its
authority (section 10), and the brief asked for explicit, static
dependencies. The cost is one pointer argument per required context per
call (section 17); an optimizing C compiler removes all of it where it can
see the values (section 5).

A program native lowering refuses compiles to C: a context with an
unbounded Int field (`cc-ctx-big-int-field`) [test]. Native data holds no
GC root, so it cannot slot a value that may be a heap BigInt; C's installed
object is an ordinary value of the run's frame, valid for the run as every
runtime-service value is.

## 5. C representation and generated-code examples

### The example application

`examples/c-freestanding/contexts/` is one application and two
configurations of it:

| file | role |
|---|---|
| `clock.bot` | `context trait Clock: fn now() -> Tick` |
| `payment.bot` | `context trait Payment: fn authorize(amount: Amount) -> Receipt errors Declined`, the Receipt struct, the error |
| `terminal.bot` | `context struct Terminal` (limit, fee) and `authorize`, Payment's implementation; it calls `stamp()`, which needs a `clock::Clock` |
| `simclock.bot` | `context struct SimClock` (start, offset) implementing Clock: a test bench's clock |
| `rtc.bot` | `context struct Rtc` (hours, minutes) implementing Clock: a real-time clock's registers, converted to seconds |
| `shop.bot` | the application's logic: `sell` needs a `payment::Payment` and nothing else; `day` sells three items and totals them |
| `store_bench.bot` | installs `SimClock {start: 30000, offset: 600}` and `Terminal {limit: 500, fee: 3}`, runs `shop::day(120, 900, 480)` |
| `store_field.bot` | installs `Rtc {hours: 14, minutes: 34}` and `Terminal {limit: 1000, fee: 5}`, runs the same day |

The application asks for a Payment; the Payment implementation asks for a
Clock; the entry program chooses both. `shop.bot` names no terminal and no
clock, `terminal.bot` no clock implementation.

### The generated C of `store_bench.bot`

[run] `tclsh9.0 main.tcl -emit-c -out OUT examples/c-freestanding/contexts/store_bench.bot`
("runtime services: none"); the program function and three of its
functions, unedited:

```c
static store_bench_status store_bench_program(store_bench_shop_Day *out)
{
    store_bench_simclock_SimClock v_context_503_9 = ((store_bench_simclock_SimClock){.f_start = INT64_C(30000), .f_offset = INT64_C(600)});
    store_bench_simclock_SimClock ctx_simclock_SimClock = v_context_503_9;
    store_bench_terminal_Terminal v_context_563_11 = ((store_bench_terminal_Terminal){.f_limit = INT64_C(500), .f_fee = INT64_C(3)});
    store_bench_terminal_Terminal ctx_terminal_Terminal = v_context_563_11;
    store_bench_shop_Day r1;
    store_bench_status st2 = store_bench_1_shop_day_payment_Payment_terminal_Terminal(INT64_C(120), INT64_C(900), INT64_C(480), &ctx_simclock_SimClock, &ctx_terminal_Terminal, &r1);
    if (st2 != store_bench_OK) {
        return st2;
    }
    *out = r1;
    return store_bench_OK;
}

/* shop::sell<payment::Payment=terminal::Terminal> (i2 int) */
static store_bench_status store_bench_2_shop_sell_payment_Payment_terminal_Terminal(int64_t p_price_18, store_bench_simclock_SimClock *ctx_simclock_SimClock, store_bench_terminal_Terminal *ctx_terminal_Terminal, store_bench_shop_Sale *out)
{
    store_bench_payment_Receipt j1 = store_bench_payment_Receipt_zero;
    store_bench_status hst2 = store_bench_OK;
    store_bench_payment_Receipt r3;
    store_bench_status st4 = store_bench_3_terminal_authorize_clock_Clock_simclock_SimClock(p_price_18, ctx_simclock_SimClock, ctx_terminal_Terminal, &r3);
    if (st4 != store_bench_OK) {
        hst2 = st4;
        goto handler_1;
    }
    j1 = r3;
    goto handled_2;
    handler_1:
    if (hst2 == store_bench_E_payment_Declined) {
        *out = ((store_bench_shop_Sale){.f_ok = false, .f_paid = INT64_C(0), .f_fee = INT64_C(0), .f_stamp = INT64_C(0)});
        return store_bench_OK;
    } else {
        return hst2;
    }
    handled_2:;
    store_bench_payment_Receipt v_r_20 = j1;
    *out = ((store_bench_shop_Sale){.f_ok = true, .f_paid = (v_r_20).f_amount, .f_fee = (v_r_20).f_fee, .f_stamp = (v_r_20).f_stamp});
    return store_bench_OK;
}

/* terminal::authorize<clock::Clock=simclock::SimClock> (i3 int) */
static store_bench_status store_bench_3_terminal_authorize_clock_Clock_simclock_SimClock(int64_t p_amount_14, store_bench_simclock_SimClock *ctx_simclock_SimClock, store_bench_terminal_Terminal *ctx_terminal_Terminal, store_bench_payment_Receipt *out)
{
    if (p_amount_14 > ctx_terminal_Terminal->f_limit) {
        return store_bench_E_payment_Declined;
    }
    int64_t r1;
    store_bench_status st2 = store_bench_4_terminal_stamp_clock_Clock_simclock_SimClock(ctx_simclock_SimClock, &r1);
    if (st2 != store_bench_OK) {
        return st2;
    }
    *out = ((store_bench_payment_Receipt){.f_amount = p_amount_14, .f_fee = ctx_terminal_Terminal->f_fee, .f_stamp = r1});
    return store_bench_OK;
}

/* simclock::now (i5 generic) */
static store_bench_status store_bench_5_simclock_now(store_bench_simclock_SimClock *ctx_simclock_SimClock, int64_t *out)
{
    *out = (ctx_simclock_SimClock->f_start + ctx_simclock_SimClock->f_offset);
    return store_bench_OK;
}
```

`shop::revenue`, which needs no context, has no pointer parameter:
`static store_bench_status store_bench_6_shop_revenue(store_bench_shop_Sale p_a_2, store_bench_shop_Sale p_b_3, store_bench_shop_Sale p_c_4, int64_t *out)`.
`store_field.c` is the same application with `rtc::now` (`(r->f_hours *
INT64_C(3600)) + (r->f_minutes * INT64_C(60))`) where `simclock::now` was,
and its own Terminal value.

The rules [inspection] `ccompile::ContextName`, `ContextRepr`,
`ContextRequirement`, `ContextArgs`, `Install`, `ContextValue`:

* a context's C name is `ctx_` and its identity as a C identifier
  (`ctx_terminal_Terminal`), unique in the program; it is the installed
  object's name in the program function and the parameter's in every
  function, so the C reads like a conventional dependency parameter. Every
  global name the backend emits starts with `PREFIX_`, so no context name
  may: for a program named `ctx` (`ctx.bot`, whose types are `ctx_Clock`...)
  the stem is `cx_` (`cc-ctx-names-avoid-the-prefix` [test]; writing that
  test found the collision, `ctx_Clock *ctx_Clock`, before any code
  shipped);
* the parameters come after the ordinary ones, in the requirement's sorted
  identity order, before the result pointer;
* a required context that an instance's compiled code never uses (its use
  is in a branch the instance's facts rule out, or it is only declared) is
  marked `(void)ctx_T;`, and an installed context nothing uses likewise, so
  `-Wall -Wextra -Werror` holds;
* a projection of a context reads through the pointer (`ctx_T->f_limit`);
  a context used as a value copies `(*ctx_T)`, as any struct is passed.

What an optimizer makes of it [run] (`gcc -std=c11 -O2 -ffreestanding -c
store_bench.c`): `store_bench_run` is 78 bytes of constant stores into
`*value` (`movq $0x7788,0x18(%rdi)`: the stamp 30600); every call, pointer
and context disappeared. Explicit dependencies and direct calls are
transparent to the C compiler; a registry, a function-pointer table or a
global environment pointer would have hidden them.

## 6. Context construction and installation

* **Construction** is ordinary: a struct literal, or any function returning
  the context struct (`device::open(11)` in `cc-parity-contexts`), compiled
  like every other call [test].
* **Installation** declares `T ctx_T = VALUE;` where the top-level
  statement is, so the object exists from its `with context` line on --
  exactly the language's order (CONTEXTS.md, "Order"). A later constructor
  may use an earlier context: `with context gain_for()` after `with context
  open(11)` calls `gain_for(&ctx_Bus, &r)` before `ctx_Gain` is declared
  [test] `cc-parity-contexts`.
* **Where.** Only the program function installs. A thread entry's
  installation (the language's other place) is C UNSUPPORTED
  [inspection]: thread entries are started by `std::thread`, which C does not
  compile, so no compiled code reaches one.
* **An unverified program** (a `-strict 0` HIR carrying MISSING-CONTEXT,
  DUPLICATE-CONTEXT, CONTEXT-NOT-INJECTED, ...) is refused before anything
  is generated, with its first context diagnostic, located, as the front end
  reports it [test] `cc-ctx-unverified-refused`. So no generated load can
  lack its installation.

## 7. Transitive dependency handling

A function receives its *transitive* requirement -- the contexts it uses and
the ones its callees use -- because it must pass the latter on. That set is
`hir/contexts.tcl`'s `requiredContexts`; the C backend copies it into the
signature and computes nothing. Verification guarantees `required(callee)
⊆ required(caller)` for every call the caller's region makes, and
`required(callee) ⊆ installed` at every top-level call, so `ContextArgs`
always finds each pointer; if it did not, the backend fails with an internal
error rather than emit a call (it never has) [inspection].

The application's chain [test] `cc-ctx-application`, [run] section 5:

```
store_bench (installs SimClock, Terminal)
 -> shop::day<payment::Payment=terminal::Terminal>         requires SimClock, Terminal
 -> shop::sell<payment::Payment=terminal::Terminal>        requires SimClock, Terminal
 -> terminal::authorize<clock::Clock=simclock::SimClock>   requires SimClock, Terminal   (reads Terminal)
 -> terminal::stamp<clock::Clock=simclock::SimClock>       requires SimClock
 -> simclock::now                                          requires SimClock             (reads SimClock)
```

`cc-ctx-requirements-are-signatures` [test] pins the C parameter list of every
function of two corpus programs against the expected requirements, among
them a recursive function needing two contexts (`countdown`: Clock and Gain,
a self tail call that keeps them: `goto top`), a nested function (`inner`:
Rates), a constructor that needs an earlier context (`gain_for`: Bus) and
functions needing nothing (`open`, the program function).

## 8. Context traits and dispatch

Context traits never reach the C backend. The trait plan (CONTEXT-TRAITS.md,
"Specialization and lowering") clones every function whose requirement
includes a context trait for the program's one selection and turns each
operation into a direct call of the selected context's implementation; the
monomorphized program "contains no context-trait operation, binding, load
or type". The C backend compiles that program [test]:

* **trait requirements and implementations:** `clock.now()` is a C call of
  `simclock_now` (or `rtc_now`): `cc-ctx-application`;
* **nested trait requirements:** Payment's implementation needs Clock, a
  second context trait: the same test;
* **generic or specialized functions:** an ordinary trait's specialization
  whose implementation needs a context (`twice<Box>` requires Fee only
  because Box's `size` calls `charge_only`), selected by
  TRAIT-IMPLEMENTATION-CONTEXT-REQUIREMENTS-MILESTONE-1.md's graph:
  `cc-parity-context-traits`;
* **multiple implementations:** a program may declare several providers and
  install one (`OtherClock` declared, `SimClock` installed:
  `cc-parity-context-traits`); two configurations installing different
  implementations are two programs (section 9).

**No dynamic dispatch exists to translate** [inspection]. Selection is
static and per program; two installed providers of one trait make every call
needing it AMBIGUOUS-CONTEXT-IMPLEMENTATION, a compile-time error; a function
requiring a context can never be a value (CONTEXT-FUNCTION-VALUE), so no
indirect call reaches one. The backend therefore has no vtable, no function
pointer and no dispatch of any kind, and needs no C UNSUPPORTED case for
"dynamic" context traits: none exists in the language. The one placeholder
the plan leaves, `context#unreachable` (an operation no selection reaches),
compiles to its arguments followed by the Tcl backends' error as a status
[inspection]; no program the C backend compiles reaches it today -- its
producers are code the backend does not compile (a nested function never
called, a branch the facts rule out) and dead calls, whose `never` argument
is a rejected `static compile:` block's reified CompilerError, which carries
a String payload C does not compile.

## 9. Context instance independence

### What "an instance" is in Botlish

One program has one execution environment: at most one installed value per
context type, one selected implementation per context trait, installed by
the program's own top level. So within one program there cannot be two
instances of one dependency, and an embedding cannot hand a run a different
one. An *application instance with its own dependencies* is an entry program
that installs them: `store_bench.bot` and `store_field.bot` are the same
application (`shop.bot` and the modules it imports) installed two ways -- a
different implementation of `clock::Clock` (SimClock, Rtc) and a different
value of the same `terminal::Terminal` type (limit 500 / 1000, fee 3 / 5).

### The test

`harness/two_apps.c` links both generated programs (prefixes `store_bench`
and `store_field`) into one executable, runs them interleaved, A B B A A B,
prints each run's value and checks every run of a program against its first.
[run] hosted (gcc 13.3.0 and clang 18.1.3, -O2, the strict flags) and with
no C library (gcc, `-ffreestanding -nostdlib -static`, `linux_start.c
-DBOTLISH_START_ENTRY=two_apps_main`):

```
store_bench run 1: value: shop::Day {first: shop::Sale {ok: true, paid: 120, fee: 3, stamp: 30600}, second: shop::Sale {ok: false, paid: 0, fee: 0, stamp: 0}, third: shop::Sale {ok: true, paid: 480, fee: 3, stamp: 30600}, revenue: 600}
store_field run 1: value: shop::Day {first: shop::Sale {ok: true, paid: 120, fee: 5, stamp: 52440}, second: shop::Sale {ok: true, paid: 900, fee: 5, stamp: 52440}, third: shop::Sale {ok: true, paid: 480, fee: 5, stamp: 52440}, revenue: 1500}
store_field run 2: value: shop::Day {... revenue: 1500}
store_bench run 2: value: shop::Day {... revenue: 600}
store_bench run 3: value: shop::Day {... revenue: 600}
store_field run 3: value: shop::Day {... revenue: 1500}
repeated runs: identical
```

(the repeated lines are equal byte for byte; shortened here). The bench's
900 is declined (limit 500), the field's accepted (limit 1000); the stamps
are the two clocks' (30000 + 600; 14 h 34 min = 52440 s).

| property (brief, section 6) | evidence |
|---|---|
| each application receives its own dependencies | [test] `cc-ctx-two-apps`: every line equals the reference backends' value of its own program |
| state does not leak between instances | [test] every run equals its program's first run; `cc-ctx-installed-in-the-run`: no object of static storage duration in the generated C |
| injected implementations do not overwrite one another | [inspection] each installed context is an object of its own run's frame, never written after its installation; the two programs share no symbol (`cc-public-names-prefixed`) |
| call order does not change which context an application uses | [test] A after B, B after A and A after A all give each program's value |
| repeated invocation preserves the semantics | [test] three runs of each, identical |
| coexistence in one program image, not runs in isolation | [test] one executable, `cc-ctx-two-apps` (hosted, gcc and clang), `cc-ctx-two-apps-freestanding` (no libc, no undefined symbol), `cc-ctx-two-apps-cross` [emulated] |

The structural guarantee is the stronger one: an installed context is a
object of `PREFIX_program`'s frame, never file-scope storage, so no
second run and no other program can observe or replace it (the test reads
the generated C's file-scope declarations and finds no writable object).

### Is the `PREFIX_run` embedding API sufficient?

For independently configured applications, yes, unchanged: each
configuration is a program with its own prefix, and `PREFIX_run` gives each
run its own contexts. No adjustment of the entry-point model was needed.
What it does not offer, recorded rather than worked around [design]:

* **an embedding cannot supply a context.** The program installs its own;
  an application parameterized by its embedding is today one entry program
  per configuration. Letting the embedding pass installed contexts to
  `PREFIX_run` would be a language question first (an entry program that
  declares contexts it does not install), not a C one;
* **a shared module is compiled into each program.** Two configurations of
  one application carry two copies of `shop.bot`'s C (static functions under
  each prefix): there is no separately compiled module yet.

### Reentrancy, distinguished

| | status |
|---|---|
| independent context instances (two configurations in one image) | **established** (above) |
| sequentially reusable entry points (`PREFIX_run` again and again) | established: every run installs its contexts afresh in its own frame |
| reentrant execution (a run started while another is in progress, e.g. from an interrupt) | holds for a program whose functions read no top-level value -- its run writes no object of static storage duration, and `PREFIX.h` now says so -- and not for one that reads one (those are file-scope objects, as milestone 1 recorded; its header says "Not reentrant"). Contexts add no file-scope state either way. |
| concurrent execution (two threads) | **not claimed.** The generated C of a program reading no top-level value shares nothing writable, but nothing here was tested on threads, and a runtime-service provider (the reference Int arena) has its own state |

## 10. Capability and authority preservation

Contexts are authority, and the C makes it concrete [inspection, test]:

* **A function's C signature is its authority.** It receives a pointer to
  exactly the contexts in its transitive requirement, no more: the C
  compiler then enforces what the Botlish compiler proved -- a function has
  no name for any other context, and no global, registry or lookup exists
  through which it could find one. `cc-ctx-requirements-are-signatures`
  checks every function of two programs.
* **Injection narrows nothing at run time because it needs nothing at run
  time.** An inject block is checked before any backend
  (RESTRICTED-CONTEXT-INJECTION-MILESTONE-1.md); its calls pass only what
  their callees require, which the front end proved is within what the
  block injects. Inside `inject context Fee:`, the call `charge_only(6)`
  passes `&ctx_Fee` and nothing else, although the program has SimClock
  installed too (`cc-ctx-requirements-are-signatures`); `inject no
  context:` compiles to a block with no context in sight.
* **A context existing somewhere grants nothing.** An installed context
  nothing requires is never passed anywhere (`(void)ctx_Unused;` in the
  program function: `cc-parity-contexts`).
* **The runtime-service interface gained nothing** -- no lookup service, no
  context service -- so it opens no ambient path (section 12).
* **The language's diagnostics are unchanged and still decide.** The backend
  compiles only verified programs (`cc-ctx-unverified-refused`); every
  context rule (MISSING-CONTEXT, CONTEXT-NOT-INJECTED,
  CONTEXT-RETAINED-AUTHORITY, CONTEXT-FUNCTION-VALUE, ...) stays the front
  end's, before C.

Nothing writes through the pointers: the backend emits only reads of a
context. They are not `const`-qualified for one practical reason (section
16): GCC treats the address of an object passed to a pointer-to-const
parameter as a read of it, and GCC 15 reported an initialized installed
context "may be used uninitialized" there. For the actor and embedded
event-loop work the property that matters holds either way: a coroutine
frame or an actor handed `Clock *` and nothing else cannot reach a display
[design].

## 11. Value, ownership, `place` and error semantics

[inspection; test where named]

* **Value semantics.** A context is an immutable value. The installed object
  is never written after its installation; a context parameter is the
  pointee read in place; a use as a
  value (`grab()` returns `c`; `snap` stores it in a Snapshot; the program's
  value displays it) copies the struct, which is exactly Botlish's value
  semantics for an immutable struct: `cc-parity-contexts` returns and stores
  contexts, and every backend agrees. No pointer to a context escapes into a
  Botlish value; no non-`place` parameter became a reference (a context
  parameter is no ordinary parameter: its call arity is unchanged, and the
  pointer is the *installed storage*, which the language says the binding
  names -- CONTEXT-OWNED-AFFINE-STATE-MILESTONE-1.md).
* **Identity and lifetime.** One object per installed type per run, from its
  installation to the end of the run (`PREFIX_program`'s frame outlives every
  call that receives a pointer to it), never replaced.
* **`place`, mutation, affine state.** The C subset has no MutableVector,
  MutableArray or affine values, so a context that holds one -- the
  language's only mutable or owned context state -- is C UNSUPPORTED, naming
  the context and its member (`cc-ctx-unsupported`); nothing writes through
  the pointer until a milestone represents in-place collection mutation.
* **Declared errors** cross context boundaries as every status does: a
  `fail` inside an implementation two modules away (`terminal::authorize`'s
  `Declined`) is the status the application's handler tests
  (`cc-ctx-application`); two identities through two levels of context
  calls, handlers selecting by identity at the top level and in between
  (`cc-parity-context-errors`).
* **Run-time errors** inside a context operation (mod by a context field
  that is 0) end the run with Botlish's own code and message, as on every
  backend (`cc-parity-context-mod-zero`); nothing terminates the process.
* **Specialization.** A block's requirement is per block, so every instance
  of it takes the same pointers; a trait clone is a block with its own
  requirement.
* **Initialization, destruction.** Installation is the only initialization;
  contexts have no destruction (CONTEXT-OWNED-AFFINE-STATE-MILESTONE-1.md:
  no lifecycle), and the frame's end is the run's.

## 12. Runtime-service manifest integration

Nothing changed in the manifest's format or the runtime ABI (v1)
[inspection]. Contexts are not target obligations: a program installs its
own, so the embedding supplies nothing, and the manifest names no context.
What the code behind a context needs is listed exactly as for any code:

* a pure context program requires no service and gets no runtime header:
  both example configurations (`cc-ctx-application` [test]);
* a context whose implementation does arbitrary-precision arithmetic --
  reached only through a context trait, two calls below the top level --
  requires exactly `int.mul` in `meter.c` and `int.to_decimal` in its display
  unit, which are the symbols the C references (`cc-ctx-manifest-transitive`
  [test]; the manifest contains no "context");
* an unbounded Int field of a context is a `botlish_rt_v1_int`: the
  arithmetic on it requires `int.add`, `int.mul` (`cc-ctx-big-int-field`).

No `context_lookup` service exists or was needed.

## 13. Freestanding compilation and execution

[test, run] with gcc 13.3.0, clang 18.1.3, ld.lld 18.1.3:

* **Strict C11.** Every context program of the tests compiles under
  `-std=c11 -pedantic-errors -Wall -Wextra -Werror -Wshadow
  -Wstrict-prototypes -Wmissing-prototypes -Wconversion -Wsign-conversion
  -Wcast-qual -Wundef` with gcc and clang at -O0 and -O2.
* **No hosted library.** The example programs' objects and a corpus
  program's, compiled `-ffreestanding -O2` by gcc and clang, reference no
  symbol at all (`cc-ctx-freestanding-objects`). The two-application
  executable, `-ffreestanding -nostdlib -static` with `linux_start.c`, has no
  undefined symbol and runs (`cc-ctx-two-apps-freestanding`): no libc, no
  allocation, no thread library, no scheduler, no registry, no loader, no
  Botlish runtime, no provider.
* **Other targets, compiled** (`cc-ctx-cross-targets` [test]): the two
  configurations for thumbv6m-none-eabi (Cortex-M0), thumbv7m-none-eabi,
  riscv32-unknown-elf, riscv64-unknown-elf, msp430-none-elf (16-bit `int`
  and pointers), avr `-mmcu=atmega328p` (8-bit, 16-bit pointers),
  mips-unknown-elf, powerpc-unknown-elf (both big endian) and
  aarch64-none-elf, strict flags, -O2: every object compiles and references no
  Botlish symbol. What they leave undefined [run] is the toolchain's:
  `memset` on riscv32 (a zeroed struct), `__do_copy_data` on AVR (initialized
  data: the status tables); nothing on the others, i386 included.
* **Other targets, executed** [emulated] (`cc-ctx-two-apps-cross`, and the
  milestone-1 `ccCross` table): the no-libc two-application executable built
  by clang/lld for AArch64, RISC-V 64, s390x (big endian) and ARMv7 (with
  the cross libgcc) runs under qemu-user 8.2.2, and for i386 natively,
  printing the reference lines and `repeated runs: identical`. Emulation and
  a 32-bit mode of an x86-64 machine, not hardware.

Reproduce:

    examples/c-freestanding/demo.sh OUT          # section 4 of its output
    tclsh9.0 tests/c-compile.test -match 'cc-ctx-* cc-parity-context*'

## 14. Cross-backend parity tests

`tests/c-compile.test`, 21 new tests [test]:

| test | what |
|---|---|
| `cc-parity-contexts` | installation, transitive requirements, a constructor needing an earlier context, a context returned, stored, displayed, opaque; recursion (tail and tree), a nested function, an unused installed context and an unused parameter -- gcc, clang, -O0, -O2 against interp, compile, cranelift |
| `cc-parity-context-traits` | a selected context trait, a declared but uninstalled provider, inject blocks (two, one and no context), a Declined handled outside the implementation, an ordinary trait's specialization needing a context |
| `cc-parity-context-errors` | two declared identities through context calls, handlers at the top level and between |
| `cc-parity-context-mod-zero` | a run-time error inside a context operation |
| `cc-ctx-application` | both example configurations against every backend and their `# expect:` lines; no service, no runtime header |
| `cc-ctx-two-apps` | both in one hosted executable, interleaved, gcc and clang |
| `cc-ctx-two-apps-freestanding` | the same with no C library; no undefined symbol |
| `cc-ctx-two-apps-cross` | the same on the emulated architectures |
| `cc-ctx-freestanding-objects` | no symbol referenced by context programs' freestanding objects |
| `cc-ctx-cross-targets` | nine cross targets, 8- to 64-bit |
| `cc-ctx-requirements-are-signatures` | every function's pointer parameters equal its requirement; inject passes only the injected |
| `cc-ctx-names-avoid-the-prefix` | a program named `ctx` builds (contexts named `cx_`) |
| `cc-ctx-installed-in-the-run` | no writable file-scope object; five installations, all in the program function; the header's statement; "Not reentrant" where a function reads a top-level value |
| `cc-ctx-no-const-context-pointers` | no context pointer parameter or installed context is `const`-qualified (the GCC 15 diagnostic of section 16) |
| `cc-ctx-big-int-field` | an unbounded Int context field: C and the Tcl backends agree, native refuses (CONTEXT-NATIVE-LOWERING-UNSUPPORTED), services `int.add int.mul` |
| `cc-ctx-manifest-transitive` | a service needed only inside a context-trait implementation is listed; no context entry |
| `cc-ctx-unsupported` | String, MutableVector and C-pointer members: C UNSUPPORTED naming the context, at each use |
| `cc-ctx-unsupported-around-contexts` | portable I/O over Linux system calls, and a coroutine needing a context: C UNSUPPORTED at those constructs, not at the context |
| `cc-ctx-unverified-refused` | a lenient MISSING-CONTEXT HIR refused, no C |
| `cc-ctx-example-warning-clean` | the example compiles under `-warnings error` (it is not in the warning gate's corpus directories) |
| `cc-ctx-deterministic` | byte-identical output |

The parity programs run on interp, the Tcl compiler and cranelift (the
native backend built from this checkout) and on both C compilers at both
optimization levels; every result is one line. The census rows
(`audit/golden/migration/census/c-compile.tsv`) and the regenerated manifest
list the new tests (C generated and run by an external toolchain: not
expressible as golden tests).

## 15. Supported and unsupported constructs; diagnostics

| construct | C |
|---|---|
| `context struct`, `opaque context struct` of representable members | supported: a C struct |
| `with context EXPR` at the entry program's top level | supported: an object of the run's frame |
| a constructor that needs an earlier context | supported |
| context parameters, several per function | supported |
| transitive requirements, recursion, nested functions | supported |
| a context as a value: passed, stored in a struct, returned, displayed | supported (a copy) |
| context traits, several providers declared, one installed | supported (the trait plan's direct calls) |
| an implementation needing another context or context trait | supported |
| an ordinary trait's specialization needing a context | supported |
| `inject context ...:`, `inject no context:` | supported (no C needed) |
| declared errors and run-time errors through context calls | supported |
| a context with an unbounded Int member | supported (a `botlish_rt_v1_int`; native lowering refuses it) |
| `context#unreachable` | compiled to its arguments and a status; reached by no program C compiles today (section 8) |
| a context member of type String, List of unknown length, Float64, a function, `any` | C UNSUPPORTED, naming the context and the member |
| a context owning affine state (a C pointer, a coroutine, a MutableVector/MutableArray, a struct holding one) | C UNSUPPORTED, naming the context |
| a thread entry's installation | C UNSUPPORTED (threads are) |
| coroutines that need a context; `std::io` over Linux system calls | C UNSUPPORTED at the coroutine and I/O constructs, as before |
| dynamic dispatch of context operations | does not exist in the language |
| an unverified (lenient) program | refused with its first context diagnostic |

The diagnostics are the backend's existing C UNSUPPORTED, located at each use
-- the installation and every context parameter that needs the struct
[test] `cc-ctx-unsupported`:

    u.bot:7:14: the C backend cannot compile the context struct Named, whose field "name"
    has type str, yet (Compilerpedia's backend.c lists what it compiles); this is a limit
    of the backend, not a missing runtime service (C UNSUPPORTED)
    u.bot:9:14: the C backend cannot compile the context struct Dev, which owns affine
    state (a C pointer, a coroutine, or a struct or collection holding one) yet (...)

A struct whose registration fails is no longer left half-registered: each
later use is judged and reported again [inspection]. Compilerpedia's
`backend.c` gained a CONTEXTS section and `error.c-unsupported` no longer
lists contexts as unsupported (`tools/compilerpedia.tcl check`: 0 problems).

## 16. Existing regression results

[run] on this branch, Linux x86-64, Tcl 9.0.1, gcc 13.3.0, clang 18.1.3,
ld.lld 18.1.3, qemu-user 8.2.2, the cross libgcc 13 packages, the native
backend built from this checkout:

* `tests/c-compile.test`: 61 tests, 61 passed, none skipped -- the 40
  milestone-1 tests (40 of 40 on the same machine before the change) and the
  21 new ones (also after the CI fixes below).
* `tests/main-cli.test`: 72 passed.
* `tests/numeric-looking-names.test`: 5 passed (its `nl-no-string-ternary`
  reads `ccompile/`: no `expr` ternary of the new code selects a name).
* `tests/golden.test`: 9 passed.
* `tests/compilerpedia.test`: 43 passed; `tools/compilerpedia.tcl check`:
  1290 topics, 758 examples run, 0 problems.
* `tools/mutant-catalogs.tcl`: 90 catalogs, 3177 mutants, 0 problems.
* `audit/golden/migration/merge.tcl -check 1`: passes (13347 rows).
* `examples/c-freestanding/demo.sh`: all four demonstrations.

No file of `core/`, `hir/`, `surface/`, `compiler/` or `native/` changed, so
the other backends' behavior is untouched by construction; the parity tests
ran them on every context program.

### CI on the branch

[run] main's latest runs when the branch was made (715ce1e, the branch's
base): every test workflow of that commit was queued or in progress; the
latest completed `tests.yml` run of main (f2787af) and `static-decisions`
(163ed13) had passed, `ci tools` of 715ce1e passed. None of the tests below
exists on main, so no failure below is main's.

The first push of the branch (e5196aa) ran what a branch push starts:

| workflow | result |
|---|---|
| tests: the Linux x86-64 canary (`ubuntu-26.04`: the mutant catalogs, the warning gate, then the changed test files) | **failed**: 3 tests of `tests/c-compile.test` (cause 1) |
| tests (linux arm64): its canary (`ubuntu-24.04-arm`), `tests/c-compile.test` included | passed |
| tests (macos arm64): the smoke tier with its canary | **failed**: 1 test (cause 2); every other test of `tests/c-compile.test` passed on macOS |
| tests (windows x86-64): its canary | **failed**: the same test (cause 2) |
| icy-tower (windows x86-64), icy-tower (macos arm64) | passed |

**Cause 1: GCC 15's `-Wmaybe-uninitialized` of pointer-to-const
arguments.** `cc-parity-contexts`, `cc-ctx-freestanding-objects` and
`cc-ctx-names-avoid-the-prefix` -- three builds of one corpus program at
-O2 -- failed with

    prog.c:207:27: error: 'ctx_Gain' may be used uninitialized [-Werror=maybe-uninitialized]
      207 |         prog_status st3 = prog_10_tree((p_n_30 - INT64_C(1)), ctx_Gain, &r2);
    prog.c:200:20: note: by argument 2 of type 'const prog_Gain *' to 'prog_10_tree.constprop' declared here
    prog.c:50:21: note: 'ctx_Gain' declared here
       50 |     const prog_Gain ctx_Gain = v_context_1279_44;

in the recursive `tree`, whose context GCC had inlined three levels deep and
then called through a clone made for the context's constant contents
(`.constprop`). The object is initialized. [inspection] GCC's
`maybe_warn_pass_by_reference` (gcc/tree-ssa-uninit.cc, the GCC 15 branch)
takes the address of an object passed to a pointer-to-const parameter for
a read of it and checks no other pointer parameter (`else if
(!TYPE_READONLY (TREE_TYPE (argtype))) continue;`); after the propagation
it found no initializing store reaching the clone's call. [run] gcc 13.3.0
and 14.2.0 do not report it at any optimization level, and gcc 15 could not
be installed in this container, so the canary is the evidence. The fix:
neither the pointer parameters nor the installed objects are
`const`-qualified (`T *ctx_T`, `T ctx_T = ...;`). Nothing writes through
them -- the backend emits only reads -- so the qualifier documented an
invariant the backend keeps anyway; `cc-ctx-no-const-context-pointers`
pins the representation, and the comment of ccompile.tcl's Contexts section
says why.

**Cause 2: a Linux program compiled for the host's target.**
`cc-ctx-unsupported-around-contexts` compiled a program importing
`std::linux::io` for the host target, `UNSUPPORTED-PLATFORM` on macOS and
Windows. It now compiles it for `linuxTarget`, as AGENTS.md asks of every
test that compiles a Linux program.

The push of the fix (1802ecb) ran the same workflows again, and the full
`tests.yml` and `tests-arm64.yml` were dispatched on it:

| workflow | result at 1802ecb |
|---|---|
| tests: the Linux x86-64 canary (`ubuntu-26.04`, gcc 15) | passed: cause 1 is fixed |
| tests (windows x86-64): canary, root plans, smoke | passed: cause 2 is fixed |
| tests (linux arm64), dispatched: canary, golden shard 1/4 | passed |
| icy-tower (windows x86-64), icy-tower (macos arm64) | passed |
| tests, dispatched (the full run); tests (macos arm64); Windows' acceptance shards and system linker; arm64's other jobs | never started: still queued for runners when main moved and the branch merged it (next paragraph), which superseded them |

Main moved 20 commits meanwhile (FOLD-VIRTUAL-LIST-CONSTRUCTION-MILESTONE-1,
which changes `hir/construction.tcl` and `native/lower.tcl`; censuses; a
GC-stress job per Tcl backend pass in `tests.yml`). The branch merged it
(no conflict); on the merged tree [run] `tests/c-compile.test` 61 of 61,
`tests/main-cli.test` 72 of 72, `tests/golden.test` 9 of 9,
`tests/numeric-looking-names.test` 5 of 5, the manifest regenerated equal,
`tools/compilerpedia.tcl check` and `tools/mutant-catalogs.tcl` 0 problems.

That merge's push (5db4d23) passed what ran before main moved again: the
three canaries (Linux x86-64 with the mutant catalogs and the warning gate,
Linux arm64, Windows), both icy-tower workflows and `ci tools`. Main's next
commits (PM-7A, external tools and target support packages; the scalar
assembly audit corpus; no front-end change) merged without conflict as
f3b5898, with the same local checks passing (the native backend rebuilt
for main's driver changes), and its push superseded the rest.

[run] Every workflow of f3b5898 passed (the runners were saturated: the
round took about fourteen hours):

| workflow | result at f3b5898 |
|---|---|
| tests, dispatched (the full run: canary, interp, compile, cranelift and cranelift-generic coverage, golden 1-4, stub- and system-linked executables, Rust unit tests, the method-call oracle) | passed. Golden shard 1's first attempt failed before any test ran (`curl: (56) Recv failure: Connection reset by peer` fetching Tcl 9.0.1's package from archive.ubuntu.com); its re-run passed |
| tests (linux arm64), dispatched (the full run, both GC-stress jobs included) | passed |
| tests (macos arm64) | passed |
| tests (windows x86-64): canary, root plans, smoke, system linker, acceptance 1-4 (`full` is the opt-in `[ci-full]` tier) | passed |
| icy-tower (windows x86-64), icy-tower (macos arm64) | passed |
| ci tools, raven clean room, package reproducibility | passed |

Main had moved again during that round (method-call decision fixes F2-F4
with the NOT-CALLABLE diagnostic, depth-safe walks, unused context imports,
the http and boringssl packages): front-end changes, among them
`hir/contexts.tcl`, `hir/specialize.tcl`, `hir/range.tcl` and
`hir/types.tcl`, which the C backend reads, and none in `ccompile/` or its
tests. They merged without conflict as ef9e381e; on it [run] (the native
backend rebuilt) `tests/c-compile.test` 61 of 61 -- its parity tests run
the context programs on the new front end against interp, compile and
cranelift --, `tests/main-cli.test` 72 of 72, `tests/golden.test` 9 of 9,
`tests/numeric-looking-names.test` 5 of 5, the manifest regenerated equal,
`tools/compilerpedia.tcl check` and `tools/mutant-catalogs.tcl` (99
catalogs) 0 problems. Because those changes are the front end's, the merge
got a CI round of its own: every workflow its push started (d824f867, this
report's commit on top of ef9e381e), and the full `tests.yml` and
`tests-arm64.yml` dispatched on it.

[run] Every workflow of d824f867 passed (about twenty-three hours, the
runners saturated again):

| workflow | result at d824f867 |
|---|---|
| tests, dispatched (the full run) | passed |
| tests (linux arm64), dispatched (the full run, both GC-stress jobs included) | passed |
| tests (macos arm64): smoke, Linux control, system linker, Botlish.app and its jobs, main-thread startup, static SDL3, acceptance 1-5 | passed; acceptance shard 3/5 on its third attempt (next paragraph) |
| tests (windows x86-64): canary, root plans, smoke, system linker, acceptance 1-4 (`full` is the opt-in `[ci-full]` tier) | passed |
| icy-tower (windows x86-64), icy-tower (macos arm64) | passed |
| ci tools, raven clean room, package reproducibility | passed |

macOS acceptance shard 3/5 was cut off twice by its job's 75-minute limit,
both times with all of its 57 Tcl test files passed (in 4205.6 s and
4075.0 s) and its golden suites cut off while passing; its third attempt
passed. The runners, not the branch, made it slow. Main's own run at
0a518ba4 ran the same 57 files in 2978.6 s. Shard 3 loads no file the
branch changes: the branch changes nothing in `core/`, `hir/`, `surface/`,
`stdlib/`, `compiler/`, `native/`, `tests/helpers.tcl` or `main.tcl`, and
`ccompile/` is loaded only for `-emit-c`. In the second attempt the first
seven files (`actor.test` to `coroutine-fusion.test`, sixteen minutes) ran
at main's speed (0.94 to 1.09 times its time), and every later file, unrelated
ones alike, about 1.5 times slower. The other four shards took main's time
within a few minutes. And [run] four of shard 3's files take the same time
locally on b0fb9e63 (the branch's base) and on the branch merged with main
(`method-resolution.test` 120.0 and 123.5 s against 118.4 and 113.9 s,
`static-compile-expected-diagnostics.test` 62.8 and 63.1 s against 62.6
and 60.6 s, `struct-destructuring.test` 26.6 and 25.5 s against 26.5 and
23.7 s, `same-failure.test` 32.3 and 32.1 s against 32.7 and 31.0 s).

Main had moved meanwhile, to cfd6ecfa: emission identity and feasibility
(`hir/emission.tcl`, `tests/emission-claims.test`), the managed subprocess
census, the branch-push CI rules (a branch push now runs only each host's
canary), and `-aot-run` with Botlish.app as a Developer ID release
(`main.tcl`, the native driver, `single/`, the macOS release tooling).
Nothing of it is `ccompile/` or what the C backend reads (no backend reads
an emission claim; `main.tcl`'s `-emit-c` path is unchanged), so this merge
needs no CI round of its own, unlike the third, whose front-end changes
the C backend reads. It
merged without conflict as 9c6d963b; on it [run] (the native backend
rebuilt for main's driver changes) `tests/c-compile.test` 61 of 61,
`tests/main-cli.test` 72 of 72, `tests/golden.test` 9 of 9,
`tests/numeric-looking-names.test` 5 of 5, `tests/emission-claims.test`
123 of 123, the manifest regenerated equal, `tools/compilerpedia.tcl check`
(1295 topics, 763 examples) and `tools/mutant-catalogs.tcl` (101 catalogs,
3448 mutants) 0 problems, and `examples/c-freestanding/demo.sh` passed.
Main's latest finished runs (0a518ba4) were all green; its runs at
cfd6ecfa were queued.

## 17. Known limitations

* **The C subset bounds the contexts.** A context is compiled when its
  members are: no String, List of unknown length, Float64, function or
  affine member; no MutableVector or MutableArray, so no in-place context
  state (nothing writes through the pointer).
* **One environment per program** is the language's model: a second
  configuration is a second entry program, compiled with its own prefix, its
  shared modules compiled again into it (no separate compilation).
* **An embedding cannot supply a context** to `PREFIX_run` (section 9).
* **One pointer per required context per call.** A function deep in a call
  chain that requires several contexts passes each on; an environment struct
  would pass one pointer but grant every context to every function (section
  4). An optimizing C compiler removes the pointers where it sees the values
  (section 5); where it cannot, the cost is argument registers.
* **Reentrancy** as section 9: a run of a program whose functions read a
  top-level value is not reentrant; nothing is claimed about threads.
* **`context#unreachable`'s lowering is inspection-only** (section 8).
* **Not run on hardware**; no bare-metal (non-Linux) image linked; the
  cross executions are emulated.

## 18. Recommended next milestone

**Stackless coroutine frames in C**, as C-COMPILE-FREESTANDING-MILESTONE-1.md
recommended, now with contexts available to them. A fusable coroutine
(COROUTINE-FUSION-MILESTONE-1.md's conditions) becomes a C struct of its
live locals and a state enum, `resume` a `switch`. The context design
carries over directly [design]:

* a coroutine's frame keeps the `T *` pointers its construction's
  requirement names -- the language already fixes a coroutine's providers
  at its construction (COROUTINES.md, section 39: "a coroutine's code runs
  with the providers its construction selected") and keeps a coroutine
  constructed with more authority from being resumed inside an inject block
  (CONTEXT-RETAINED-AUTHORITY), so storing exactly the construction's
  pointers is the semantics;
* the frame cannot outlive the run whose frame holds the installed contexts,
  because a coroutine cannot outlive the program run that created it;
* then the event-loop milestone: `std::event_loop::Driver` implemented by a
  context over a target's event and clock services, so a simulated driver
  and a hardware driver are two entry programs of one application -- the
  shape `store_bench.bot` and `store_field.bot` already have.

Smaller, independent steps that would widen the context subset first:
MutableVector/MutableArray in C (in-place context state: writes through the
pointer the backend already passes), and Strings with an allocation
service.

## 19. Files, and what to run when changing this

* `ccompile/ccompile.tcl`: the Contexts section (`ContextDiagnosticKinds`,
  `ContextName`, `ContextRepr`, `ContextRequirement`, `ContextArgs`,
  `Install`, `ContextValue`), `Function` (the pointer parameters and their
  `(void)` marks), `BlockCall`, `Bind`, `NativeCall`'s `context#install`,
  `context#load` and `context#unreachable`, `Project`'s `->`,
  `StructAggregate`'s context messages, the header's reentrancy sentence,
  `Program`'s refusal of an unverified program.
* `examples/c-freestanding/contexts/`, `harness/two_apps.c`,
  `harness/linux_start.c` (`BOTLISH_START_ENTRY`), `demo.sh`, `README.md`.
* `tests/c-compile.test` (the corpus entries and the `cc-ctx-*` section),
  `audit/golden/migration/census/c-compile.tsv`,
  `audit/golden/migration/tcl-names.txt`, `tests/golden/manifest.tsv`
  (regenerated).
* `compilerpedia/topics/backends.topic` (`backend.c`),
  `compilerpedia/topics/errors-runtime.topic` (`error.c-unsupported`).

When changing any of it, run what AGENTS.md's "The C backend" lists --
`tests/c-compile.test` (its cross tests need clang, ld.lld, qemu-user and
the cross libgcc packages), `tests/main-cli.test`,
`tools/compilerpedia.tcl check`, `examples/c-freestanding/demo.sh` -- and,
for a change to what the backend reads of contexts (`requiredContexts`,
`installId`, `loadId`), the context test files
(`tests/contexts.test`, `tests/context-traits.test`,
`tests/restricted-injection.test`) to keep the facts it reads what they are.
