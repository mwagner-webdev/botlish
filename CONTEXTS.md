# Contexts: static execution-environment dependencies (first milestone)

```
import abi::bytes
import linux::io
import str

fn hello():
    message = abi::bytes::from_list(
        str::encode_utf8("Hello, world!\n")
    )
    linux::io::write(message)

with context linux::io::create()

hello()
```

> A context parameter declares a value from the current execution environment
> that this function directly uses. `with context EXPR` installs an inferred
> context value for subsequent execution in the current scope.

That is the whole model. A context is an ordinary Botlish value; what is new
is *where it comes from*: not from the caller's argument list but from the
execution environment, which the program establishes explicitly, and which
the compiler tracks statically. There is no registration, no container, no
lookup by name or string, and no service object: a function that uses a
context says so in its own signature, every function between it and the
program's entry derives the requirement without writing anything, and a
call that could run without the context installed is a compile-time error
that names the chain of calls that needs it.

This milestone is deliberately narrow: installation exists only at the entry
program's top level, a context is identified by its exact nominal type, and
the native lowering is one statically assigned slot per context type in the
program's writable data. Everything outside that is rejected with a
dedicated diagnostic rather than handled by a more general mechanism.

## Contents

1. Language
2. Static semantics
3. HIR
4. The Tcl backends
5. Native lowering
6. `linux::io`
7. Evidence (Hello World: NIR, CLIF, machine code, strace, allocations)
8. Tests, fuzzing, mutation testing, regression
9. Limitations and what remains
10. Milestone report (items 1-59)

---

## 1. Language

### `context struct`

```
context struct Clock:
    ticks: Tick

opaque context struct LinuxIO:
    stdin: FileDescriptor
    stdout: FileDescriptor
    stderr: FileDescriptor
```

`context` is a struct modifier, an entry in the parser's modifier table
beside `opaque` (`surface::parser::structModifiers`). It is one boolean
property of the one `structdecl` declaration -- `context 0|1` and
`contextSpan` on the AST node, `context 0|1` in the struct registry
(`hir::structs::isContext`), a `context` word in HIR text -- never a separate
declaration kind. It means exactly:

> a value of this type may be installed into the current execution
> environment and may satisfy a function's context dependency.

It does not mean opaque, mutable, resource, RAII, thread-local, singleton,
reference, effectful, privileged or heap-allocated. Opacity is the
independent `opaque` modifier (OPAQUE-STRUCTS.md): `context struct T:` is a
context whose representation anyone may construct and inspect; `opaque
context struct T:` combines both properties. The modifiers are
order-independent (`context opaque struct` parses the same), each may be
written once (`duplicate modifier "context" in this struct declaration`), and
the documented spelling is `opaque context struct`. A future `resource` is one
more table entry and one more boolean.

### `with context EXPR`

```
with context linux::io::create()
with context clock::create()
with context application::create()

run()
```

A declaration-like statement (`surface::parser::WithDecl`, AST node `with`
with `form context`): the word `with`, the word `context`, one expression.
No binding name, no type annotation, no list, no block, no colon -- each of
those is a located syntax error with its own message. The parser is shaped for
later `with` declarations that establish something until the end of the
lexical scope without a block (`with connection = db::connect()` is today the
syntax error `a "with NAME = EXPR" declaration does not exist yet`); only `with
context` exists.

### The context parameter section

```
fn now(context clock: Clock):
fn write(data: abi::bytes::Bytes, context io: LinuxIO):
fn render(request, flags :verbose, context io: LinuxIO, clock: Clock, random: Random):
```

A function's parameter list is a sequence of sections in one canonical order,
`ordinary* -> flags? -> context?` (`surface::parser::paramSectionOrder`); the
context section is last. It opens with the word `context` followed by a name,
and every entry is `NAME: Type` -- the type is required, because it is the
context's identity. A second `context` section, a `flags` section or a flag
after it, an untyped entry: `MALFORMED-CONTEXT-SECTION`, located at the
offender. `flags` is unchanged.

### Contextual words

`context` and `with` are not reserved. `context` is a modifier only before
`struct` (lookahead through the modifier table), a section marker only when
directly followed by a name inside a parameter list, and part of a `with`
declaration only after `with`; `with` starts a declaration only when directly
followed by a name, which no expression allows. Everywhere else they are
ordinary identifiers: `context = 1`, `context(x)`, `x.context`, a field
named `context`, `fn f(context)`, `fn f(context: int)`, `with = 2`,
`with(x)`, `x.with` all keep their meaning (`contexts-parse-contextual`,
`contexts-contextual-run`).

## 2. Static semantics

### Identity

A context is identified by the canonical identity of its context-struct type
-- the struct declaration identity (`linux::io::LinuxIO`, `Clock` for an
entry program's own) -- and by nothing else. There is at most one installed
value of a type. There are no named instances, qualifiers, string keys or
registration ids, and the local parameter name is not part of identity:

```
fn a(context io: linux::io::LinuxIO): ...
fn b(context system_io: linux::io::LinuxIO): ...      the same context
```

Matching is exact and nominal: no traits, structural matching, covariance or
downcasts.

### Context parameters

Inside `fn write(data, context io: LinuxIO)`, `io` is an ordinary immutable
local of the function: it can be projected (where representation authority
allows), passed, compared, stored, captured by a closure, shadowed in a
nested scope. It is not a parameter: the function's `params`, its call arity
and its machine signature are those of its ordinary parameters (and flags):

```
write(data)                 the call; never write(data, io)
```

An extra argument is the ordinary `ARITY` error. Each entry is checked when
the function is resolved:

| diagnostic | when |
|---|---|
| `NOT-A-CONTEXT` | the type is not a `context struct` (an ordinary struct, a primitive) |
| `TYPE` | the type does not resolve |
| `DUPLICATE-CONTEXT-PARAMETER` | the same type twice in one function, whatever the local names (`fn bad(context a: Clock, b: Clock)`) |
| `CONTEXT-BINDING-COLLISION` | the local name is an ordinary parameter, a flag, or another context parameter of the same function |

A body binding of the same name is the ordinary `DUPLICATE` (one local
namespace); a nested scope may shadow it.

There is no other way to obtain a context: no `current()`, `resolve(T)`,
`context<T>()` or service lookup. A function that wants the value declares the
dependency.

### Installation

`with context EXPR` evaluates EXPR as any expression and installs its value.
The installed type is inferred from EXPR exactly as ordinary type inference
infers any expression; it must be exactly one context struct:

| diagnostic | when |
|---|---|
| `NOT-A-CONTEXT` | the type is a definite non-context type: an ordinary struct, an Int, a String, ... |
| `CONTEXT-TYPE-NOT-EXACT` | not one exact named struct: an anonymous struct, `any`, a union |
| `DUPLICATE-CONTEXT` | that type is already installed (`T is already installed in this scope`): no replacement, no shadowing, no last-one-wins |
| `CONTEXT-INSTALLATION-UNSUPPORTED` | anywhere but the entry program's top-level scope, as a statement: in a function, a loop, an `if` branch, an error handler, a closure, a module (the module loader's own check), an expression |

Installation is not construction: the context mechanism knows nothing about
how the value was made (`x = linux::io::create()` then `with context x` is the
same installation).

### Order

The top level runs in source order, module sections first (dependencies
before dependents) and then the entry program. A context is available from
its `with context` line onward and never earlier: a call above the line is
`MISSING-CONTEXT` even though the installation is in the file. Consecutive
installations run in order, and a later constructor may use an earlier
context; a constructor never sees the context it is building (nor a later
one). A module's own top-level code runs before the entry program installs
anything, so a module initializer that calls a context consumer is
`MISSING-CONTEXT`.

### Direct dependencies and transitive requirements

```
fn bottom(context io: LinuxIO): ...      direct      LinuxIO
fn middle(): bottom()                    transitive  LinuxIO
fn top(): middle()                       transitive  LinuxIO
```

Only a function that uses a context declares it. For every function (block)
the compiler computes

```
direct(B)    = the context types B's own region loads (its context parameters)
required(B)  = direct(B) ∪ ⋃ required(E) for every function E that B's region calls
```

a least fixed point, by breadth-first rounds over the previous round's sets
(`hir::contexts::verify`). Recursive and mutually recursive groups converge
(Botlish has no forward references, so a cycle arises through nested
functions: `fn a(n): fn b(m, context c: C): ... a(m - 1) ...; b(n)` gives both
`a` and `b` the requirement `C`). Nested functions are their own regions. The
requirement is a property of the function, not of a specialization: call
targets in HIR are resolved syntactically, so every instance of a block has
the same set.

Every top-level call must find `required(callee)` installed. Otherwise:

```
MISSING-CONTEXT: linux::io::LinuxIO is required by this call but is not installed here
(install it with "with context EXPR" before the call):
    a
     -> b
     -> c
     -> linux::io::write
        directly requires linux::io::LinuxIO
```

For each (function, type) the analysis records *why* -- `direct`, or the first
call (breadth-first, so the shortest chain, deterministically in source
order) through which the type arrived -- and the diagnostic follows it. The
derivation is kept in the HIR (§3) for tooling: `hir::contexts::of` answers
"what does f use and require", `hir::contexts::explain` "why does f require
T", and `tclsh9.0 main.tcl -contexts FILE.bot` prints both for a program.

Reachability, not source scanning, decides: a module that defines consumers,
an entry program with an unused consumer, a call in statically unreachable
code require nothing.

### Method syntax

`data.write()` is the ordinary call `write(data)` (METHOD-SUGAR.md). A context
is an obligation of the selected call, never an extra receiver or argument,
and a missing context is not evidence that a candidate does not fit:
`MISSING-CONTEXT` is one of `hir::MethodObligationKinds`, like an unhandled
declared error. With two visible candidates of the name, the consumer is
still chosen and its call fails as `MISSING-CONTEXT`, never
`NO-APPLICABLE-METHOD` (`contexts-method-sugar`).

### Function values: the higher-order frontier

Every call edge the analysis uses is exact by construction: the callee is a
block literal, a reference to an immutable binding that denotes a block (a
function, an alias `g = f`, a module function), or a native whose executable
body is a module function. An indirect call -- through a parameter, a field,
a list element -- could reach a function whose requirement the analysis cannot
see. This milestone closes that frontier at the other end:

> a function whose requirement is not empty may only be called, or bound to
> another name as a statement; any other use makes it a value and is
> `CONTEXT-FUNCTION-VALUE`.

Passing it, returning it (including as a body's or the program's final
statement), storing it in a struct or list, choosing it in an `if` value: all
rejected, closures over a consumer included (a closure that calls a consumer
requires its context too). Consequently every indirect call calls only
context-free functions, and needs nothing. Context requirements did not
become part of function types: the frontier is reported, not engineered
around.

### Opacity is independent

Context authority is not representation authority. Outside `linux::io`, a
function with `context io: linux::io::LinuxIO` holds an ordinary opaque value:
it can pass and compare it, and `io.stdout`, `{stdout} = io` and
`linux::io::LinuxIO {...}` are `OPAQUE-REPRESENTATION` /
`OPAQUE-CONSTRUCTION` exactly as for any opaque struct. A non-opaque context
struct is constructed and inspected by anyone.

## 3. HIR

The source forms become two explicit operations, internal root natives
(`core/contexts.tcl`) whose names contain `#`, which source cannot spell --
so no program can name, alias or call them:

```
with context EXPR          bind context#START EXPR              (a hygienic temporary)
                           call ^context#install (ref context#START)
context io: T              bind io (call ^context#load "T")     first in the body
```

`context#load`'s argument is the canonical type identity as a String literal
(its result type is that named struct: the native's `-result-shape
{context-struct 0}`, `hir::types::ShapeResult`); `context#install`'s type is
the inferred type of its argument, recorded on the call as `context ID` once
verified. Both stay distinguishable through every analysis; the native
backend turns them into stores and loads of a fixed slot, never into a
generic global assignment. They are calls of natives with the registry's
maximally conservative defaults (never folded, merged, removed, reordered or
decided), so no analysis treats them as anything they are not.

What HIR keeps after `hir::check` (`hir::contexts::verify`):

```
block expr   contextParams     {{name io context linux::io::LinuxIO} ...}
             directContexts    sorted identities (its region's loads)
             requiredContexts  sorted identities (transitive)
call expr    context ID        on a verified installation
hir          contexts          {blocks ... installs {{CALL ID} ...}
                                reasons {BLOCK -> ID -> direct | {call CALL CALLEE}}}
```

HIR text prints the requirement on every block that has one, the modifier on
the struct line and the identity on every verified installation (`installs
ID`), and `hir::parse` reads all three back (round trip exact). Native slot
assignment reads only facts HIR text carries -- the installations' identities
and the loads' literal keys, never the `contexts` table -- so a HIR read back
from text compiles to the same slots:

```
struct linux::io::LinuxIO name LinuxIO ns linux::io opaque context fields stdin: ..., stdout: ..., stderr: ...
e509 block s110 (b119 data:abi::bytes::Bytes) captures () ... contexts (linux::io::LinuxIO) requires (linux::io::LinuxIO) ...
    e510 bind b121 io : linux::io::LinuxIO
        e511 call native(context#load) : linux::io::LinuxIO
            e512 ref b120 context#load : native context#load
            e513 const str linux::io::LinuxIO : str
e545 block s113 () captures () ... contexts () requires (linux::io::LinuxIO) ...
e555 bind b131 context#1628 : linux::io::LinuxIO
e558 call native(context#install) installs linux::io::LinuxIO : unit
```

and `main.tcl -contexts` prints the summary:

```
contextstruct linux::io::LinuxIO opaque
contextinstall e558 linux::io::LinuxIO
contextparam e509 io linux::io::LinuxIO
contextparam e521 io linux::io::LinuxIO
contextparam e533 io linux::io::LinuxIO
function linux::io::write e509 direct-contexts (linux::io::LinuxIO) required-contexts (linux::io::LinuxIO)
...
function hello e545 direct-contexts () required-contexts (linux::io::LinuxIO)
why hello requires linux::io::LinuxIO:
    hello
     -> linux::io::write
        directly requires linux::io::LinuxIO
```

Core IR (the Tcl backends' input) is the same two calls; nothing in core IR's
forms changed.

## 4. The Tcl backends

The interpreter and the Tcl compiler implement the environment as one dict
keyed by canonical identity (`core::contexts::installed`): `context#install`
puts the value under its own runtime nominal identity (`core::value::structId`
-- static typing proved it is the installed type), and `context#load` reads
it. That map is these backends' implementation of the semantics, not a
language facility: no other key, no enumeration, no replacement, no API.
`core::evalProgram` runs every program inside `core::contexts::fresh`, so a run
starts empty and the previous environment is restored afterwards. A `-strict
0` program that failed verification fails with the same semantic error when
the operation runs (`MISSING-CONTEXT` at the load, `DUPLICATE-CONTEXT` at the
second install), never with an arbitrary value. The Tcl compiler compiles the
same native calls; it needed no change.

## 5. Native lowering

### Layout and slot assignment

One context area per program: a single zero-initialized, 8-byte-aligned,
writable, linker-local data object, `botlish_context_area`
(`codegen/clif.rs`'s `declare`; in `.bss` of a standalone executable). Every
context type the program installs gets one slot in it, assigned at compile
time in installation (program) order (`native::lower::ContextSlots`, from the
program's top-level installations and the identity each installs), at a
fixed byte offset, flattened: one 64-bit word per scalar leaf of the struct,
nested structs inlined, in declared field order (`ContextLeaves`). NIR states
it in its header:

```
nir 1 call-effects=1 statics=0 contexts=24
context 0 "linux::io::LinuxIO" offset=0 words=3 fields="stdin.raw.value stdout.raw.value stderr.raw.value"
```

| offset | word |
|---|---|
| 0 | `stdin.raw.value`, the tagged small Int 0 |
| 8 | `stdout.raw.value`, the tagged small Int 1 |
| 16 | `stderr.raw.value`, the tagged small Int 2 |

24 bytes, alignment 8, a local `O .bss` symbol of size 0x18 in the executable.
Each word is the leaf's ordinary tagged Value -- which, by the eligibility
rule, is never a pointer -- so a load yields a register in the representation
every other NIR instruction expects, and nothing in the area is a GC root.

### Eligibility: `StaticContextEligible`

A context type can live in a fixed slot when every leaf of its flattened
layout is a value whose tagged word is never a heap pointer:

* an Int whose declared domain fits the small-Int representation
  (`hir::range::fitsSmall` of the field type's interval: `abi::I32Value`,
  `Int in 0..1000`, `byte::Byte`, ...);
* a Bool, Unit, or UnicodeChar (immediates);
* a nested named struct whose leaves are all eligible (flattened; a
  recursive layout is not).

Anything else -- an unbounded Int (possibly a BigInt), a String, a List, a
Block, a `MutableArray`, `abi::bytes::Bytes` (its storage is a heap object),
`any` -- would put a GC-managed reference in program data, which nothing roots
or traces. Native compilation of a program that installs such a context fails
with

```
CONTEXT-NATIVE-LOWERING-UNSUPPORTED: context Named cannot currently be stored in a
fixed native context slot because field "name" has type str, a value that may be
(or contain) a GC-managed heap object, and fixed program data holds no GC root
```

(error code `NATIVE UNSUPPORTED CONTEXT-NATIVE-LOWERING-UNSUPPORTED`, located
at the installation). The Tcl backends run the same program. Nothing is
boxed, pointed to, looked up or moved to TLS instead.

### Installation

`with context EXPR` (the program function only) evaluates EXPR in ordinary
order and stores its leaves: `contextstore OFFSET %leaf`. The value is the
hygienic temporary's; when hir/escape.tcl holds it as fields -- the
installation counts as a structural use of it (`ctxUse`), like a projection --
the leaves are those fields and no object is built (a literal installation
stores its field registers directly: `contexts-native-allocations`, 0
allocations); otherwise the object is read with `structget` (Hello World:
§7).

### Loads

A context parameter's `bind io (call context#load "T")` loads nothing: native
lowering records the local as `{context T}` (`Bind`), and each use reads
exactly the words it needs:

* a projection chain that ends at a leaf -- `io.stdout.raw.value` -- is one
  `contextload OFFSET` (`Project`, `ContextPath`, `ContextAt`);
* a sub-struct passed to a callee that receives it as fields -- `io.stdout.raw`
  to `linux::write`'s `fd` -- is its leaves' loads (`TryFields`,
  `ContextFields`; hir/escape.tcl's `ContextArgShape` gives such an argument
  the shape of its static type, so the callee's parameter can be
  virtualized);
* only a use that needs the physical object (passing `io` itself to a function
  that keeps it whole, storing it, capturing it, returning it) materializes
  one, from loads, with `structnew` -- where an ordinary struct of that shape
  would be materialized.

A register defined only by `contextload` is never a GC root
(`codegen/roots.rs`): the word is an immediate.

### Addressing

Codegen (`codegen/clif.rs`'s `context_addr`) turns an offset into the area's
fixed address plus a constant displacement. In the AOT object the data
symbol is linker-local; Cranelift's x86-64 backend materializes any symbol
address in PIC code as `movq sym@GOTPCREL(%rip)` (cranelift-codegen
`LoadExtName`) and cranelift-object records it as `R_X86_64_GOTPCREL`, which
would cost a GOT load before every access. Investigated as item 93 asks: the
symbol is local and never preemptible, so the very same instruction may carry
`R_X86_64_REX_GOTPCRELX`, the relocation that lets the linker rewrite
`movq sym@GOTPCREL(%rip), %reg` into `leaq sym(%rip), %reg`.
`codegen::relax_context_got` changes exactly those relocations (against this
one symbol, on exactly that `REX.W 8B /r` instruction) after the object is
emitted, and the linker relaxes them: the executable contains `lea
0x...(%rip),%reg  # <botlish_context_area>`, PC-relative, no GOT. In the JIT,
which places data and code independently (a rel32 reach cannot be vouched
for), the same symbol is addressed by its absolute address (`movabs`).
Either way it is a fixed program address: no Vm field, no lookup.

The relaxed form is `lea` of the area plus a displacement on the load (`mov
0x8(%r9),%rsi`), two instructions; Cranelift does not fold a `symbol_value`
into a RIP-relative load operand, so a single `mov 0x...(%rip)` is not
reachable without a Cranelift change.

### No hidden argument, no reserved register, no presence tag

Calls are untouched: a function's NIR parameter list is its ordinary
parameters (and flags), and nothing anywhere adds an operand for a context.
No register is reserved: the area's address is materialized where it is used
and the register allocator treats it like any other temporary. There is no
presence flag, no null check and no failure path on a load: hir/contexts.tcl
proved every load is preceded by its installation. A `-strict 0` program that
failed context verification raises its first context diagnostic when it
starts (`native::lower::ContextDiagnostic`); no code whose loads were not
proven runs.

## 6. `linux::io`

`lib/linux/io.bot`, namespace `linux::io`:

```
opaque struct FileDescriptor:
    raw: abi::I32

opaque context struct LinuxIO:
    stdin: FileDescriptor
    stdout: FileDescriptor
    stderr: FileDescriptor

fn create() -> LinuxIO:
    LinuxIO {
        stdin: FileDescriptor {raw: abi::i32(0)},
        stdout: FileDescriptor {raw: abi::i32(1)},
        stderr: FileDescriptor {raw: abi::i32(2)},
    }

fn write(data: abi::bytes::Bytes, context io: LinuxIO) -> int:
    linux::write(io.stdout.raw, data)

fn write_error(data: abi::bytes::Bytes, context io: LinuxIO) -> int:
    linux::write(io.stderr.raw, data)

fn read(data: abi::bytes::MutableBytes, context io: LinuxIO) -> linux::ReadResult:
    linux::read(io.stdin.raw, data)
```

* `LinuxIO` is one context -- the process I/O environment -- holding the three
  standard descriptors; there is no StdinContext/StdoutContext/StderrContext.
* `FileDescriptor` is a proof-bearing token: "this value is a Linux
  file-descriptor token minted by the owning Linux I/O abstraction", its
  machine token an `abi::I32`. It does not claim the descriptor is open or
  stays open. Both structs are opaque: outside `linux::io` nobody can
  construct, project or destructure them, and there are no accessors (`.raw`,
  integer conversion, `stdout(io)`, `current()`).
* **Minting needs no new mechanism.** `opaque struct` already makes
  `linux::io` the only code that can build a `FileDescriptor`, so `create`
  legitimately mints the tokens 0, 1, 2. The constants are in `abi::I32`'s
  domain, so the existing call-specific completion proofs need no handler
  and emit no range branch; nothing in the compiler knows these integers.
  Future `socket`/`openat` results may motivate a broader proof-minting
  design; not now.
* The consumers project `io.stdout.raw` directly -- they are in the owning
  module -- and every external effect still flows `linux::io::write ->
  linux::write -> linux::abi::syscall -> syscall`. No libc, no errno mapping
  (results are the kernel's raw signed values), no compiler knowledge of
  write(2) or read(2), no new syscall code. `linux::write(fd, data)` and
  `linux::read(fd, data)` are unchanged: the explicit low-level layer.
* `read` reuses `linux::read` exactly: one syscall, the caller's buffer
  unchanged, the detached updated buffer in the result.
* Not here: `resource`, close/ownership, RAII, buffering, short-write
  completion, mutable contexts, substitutable (trait) contexts, `direct`
  policy.

## 7. Evidence: the Hello World

`examples/linux/context-hello.bot` (the program at the top).

### Output

```
$ tclsh9.0 main.tcl -emit-native-executable examples/linux/context-hello.bot
$ ./context-hello > out; od -c out
0000000   H   e   l   l   o   ,       w   o   r   l   d   !  \n   1   4  \n
```

Descriptor 1 receives exactly `Hello, world!\n`; the `14\n` after it is the
standalone runner's own result line (the program's value, the 14 bytes
written), as in the earlier ABI-byte milestones. Descriptor 2 receives nothing
(`contexts-native-executable-hello`).

### strace

```
$ strace -f -k -e trace=write ./context-hello > /dev/null
write(1, "Hello, world!\n", 14)   = 14
 > context-hello(botlish_linux_x86_64_syscall+0x1f)
 > context-hello(rt_linux_x86_64_syscall+0x493)
 > context-hello(botlish_fn_7+0xd1)          linux::write
 > context-hello(botlish_fn_9+0x24)          linux::io::write
 > context-hello(botlish_fn_10+0x19)         hello
 > context-hello(botlish_fn_0+0x6a)          <program>
 ...
write(1, "14\n", 3)               = 3
 > libc.so.6(__write+0x4d)                   (the runner's own result line)
```

The program's write comes from the raw syscall boundary, called by the runtime
helper, called by `linux::write`, called by `linux::io::write`, called by
`hello`: no libc write frame in that stack (`contexts-native-strace`).

### NIR

```
nir 1 call-effects=1 statics=0 contexts=24
context 0 "linux::io::LinuxIO" offset=0 words=3 fields="stdin.raw.value stdout.raw.value stderr.raw.value"

func 0 "<program>" params=0 ...
    %0 = call 8                          linux::io::create()
    %1 = structget 0 %0  ...             its three leaves
    contextstore 0 %3
    contextstore 8 %6
    contextstore 16 %9
    %11 = call 10                        hello(): no operand
    ret %11

func 9 "linux::io::write" params=1 ... pnames="data.0" instance="abi::bytes::Bytes"
    %1 = contextload 8                   stdout's descriptor word
    %2 = call 7 %1 %0                    linux::write(fd.0, data.0)
    ret %2

func 10 "hello" params=0 ...
    %0 = bytes "48656c6c6f2c20776f726c64210a"
    %1 = call 9 %0                       linux::io::write(message): one operand
    ret %1
```

`linux::write`'s instance takes `fd` as fields (`pnames="fd.0 data.0"`): the
argument `io.stdout.raw` is supplied straight from the slot, so no `abi::I32`
object exists either (`contexts-native-nir-hello`).

### CLIF

```
; function 9 "linux::io::write": botlish_fn_9
function u0:98(i64, i64) -> i64 system_v {         (vm, data): no context parameter
    gv0 = symbol userextname0                        the context area
    fn0 = colocated u0:94 sig0                       linux::write
block0:
    v4 = symbol_value.i64 gv0
    v5 = load.i64 notrap aligned v4+8                stdout, offset 8
    v7 = call fn0(v0, v5, v6), stack_map=[i64 @ ss0+0]

; function 10 "hello": botlish_fn_10
function u0:100(i64) -> i64 system_v {             (vm)
    v5 = call fn0(v0, v4)                            linux::io::write(vm, message)
```

(`-emit-clif` shows the JIT's CLIF, where `gv0` is an absolute symbol; the
object's is `colocated`.) The intermediate caller's call has the same shape it
has without any context (`contexts-native-clif`,
`contexts-native-no-hidden-argument`).

### Machine code and relocation

```
botlish_fn_9 (linux::io::write):
   push   %rbp
   mov    %rsp,%rbp
   sub    $0x10,%rsp
   mov    %rsi,(%rsp)                    data's root slot
   mov    %rsi,%rdx
   lea    0x6655(%rip),%r9               # <botlish_context_area>   PC-relative
   mov    0x8(%r9),%rsi                  stdout's descriptor
   call   <botlish_fn_7>                 linux::write
   ...
$ objdump -t context-hello | grep botlish_context_area
00000000000893b8 l     O .bss  0000000000000018 botlish_context_area
$ objdump -r program.o | grep botlish_context_area
... R_X86_64_REX_GOTPCRELX  botlish_context_area-0x0000000000000004     (x2: install, write)
```

No extra argument register, no helper call, no hash or TLS lookup, no heap
traversal, no reserved register, no GOT load (`contexts-native-machine-code`,
`contexts-native-object-relocation`). The program function's install is
`lea botlish_context_area(%rip),%rsi; mov %rax,(%rsi); mov %rdx,0x8(%rsi);
mov %rcx,0x10(%rsi)`.

### Cost of `context io: LinuxIO` in the writer

Exactly the required load: `lea` of the area and one `mov` of the stdout word.
The other two fields are never read, no `LinuxIO`, `FileDescriptor` or
`abi::I32` is materialized, and the loaded word is not stored to a root slot.

### Allocations

Measured with `native::allocationReport` (`contexts-native-allocations`):

| what | objects |
|---|---|
| a literal installation and any number of reads (`with context Counter {...}`, 50 recursive reads) | **0** |
| a three-level chain to a consumer of a literal installation | **0** |
| the Hello World | **7**, all `Struct`: `linux::io::create`'s own LinuxIO, three FileDescriptors and three `abi::I32`s, once |
| `linux::io::write`, per call (1 call vs 20 calls of the same program) | **0** (9 = 9) |
| context installation itself, context load | **0** |

The 7 are the constructor's, not the context mechanism's: the existing
optimizer never returns a zero-parameter function's struct result as fields
(hir/escape.tcl's `generic` rule for the one instance such a function has),
so `create()` returns a physical `LinuxIO` (and builds the `abi::I32`s inside
it), which the installation then reads. A literal installation allocates
nothing. The unspecialized baseline (`cranelift-generic`) carries no struct as
fields across a call, so there `linux::io::write` materializes the `abi::I32`
it passes (one object per call) -- the baseline's documented limitation.

## 8. Tests, fuzzing, mutation testing

* `tests/contexts.test` (74 tests; programs on interp, compile,
  cranelift-generic and cranelift): grammar and contextual words, modifier
  and section errors, surface lowering, the registry and HIR text round trip,
  `NOT-A-CONTEXT` / `CONTEXT-TYPE-NOT-EXACT` / `DUPLICATE-CONTEXT` /
  `CONTEXT-INSTALLATION-UNSUPPORTED` (function, loop, branch, handler, nested
  function, module), installation through a binding and a constructor,
  identity by type, source order, constructor order (and its reversal),
  multiple types, module initializers, arity, binding collisions, duplicate
  parameter types, context locals as ordinary values, method syntax with two
  candidates, the three-level chain and its exact diagnostic, unused and
  unreachable consumers, recursion and a cycle through a nested function,
  tooling (`of`, `explain`, `summary`), function values (passing, returning,
  storing, `if`-chosen, aliases), non-opaque contexts, opacity exactness,
  the `linux::io` surface, no context API, the Tcl backends' `NATIVE-ONLY`
  syscall, the descriptors 0/1/2 inside the owner, `-strict 0` replay on all
  four backends, the per-run environment, and the native evidence of §7
  (NIR, no hidden argument, CLIF, eligibility, allocations, GC stress, the
  standalone executable on descriptors 0/1/2 with stdin redirected and GC
  stress, machine code, relocations, strace, the JIT's absolute addressing),
  plus a bounded fuzzer run.
* `tests/opaque-struct.test` and `tests/stdlib-namespaces.test`: updated where
  they pinned that `context` did not exist (the AST keys of `structdecl`, the
  rejected `opaque context struct`, the root-native inventory, which now names
  the two internal `#` operations separately).
* Rust: `codegen::context_area_tests` -- the `context` header and instructions
  parse and validate (offsets, alignment, area bounds), the object references
  the area only through relaxable `REX_GOTPCRELX` relocations, and the JIT
  reads and writes the area.
* `audit/contexts/tools/fuzz.tcl`: generated programs with 0..3 context types
  (opaque or not), direct consumers with random local names, intermediate
  callers, self-recursion, cycles through nested functions (context on the
  inner or the outer function), constructors needing an earlier context,
  installations as literals, bindings and constructor calls, in random order
  (missing, duplicated), and unused consumers; an independent oracle computes
  every function's direct and transitive set, the first error in source
  order, and the value. Results: §10 item 50.
* `audit/contexts/tools/mutate.tcl`: 26 mutants of the implementation, each
  run against the fuzzer and the test file in a scratch tree. Results: §10
  item 51.

Results (Linux x86-64, Tcl 9.0.1, a clean copy of the tree):

| Run | Result |
|---|---|
| `audit/contexts/tools/fuzz.tcl -n 400 -seed 20261006` (interp, compile, cranelift-generic, cranelift) | 400 programs (291 accepted, 109 rejected), 0 disagreements |
| `audit/contexts/tools/mutate.tcl -n 30` | 26 mutants, 26 killed, 0 survivors |
| `CORE_BACKEND=interp tclsh9.0 tests/all.tcl` | 5847 tests, 0 failed |
| `CORE_BACKEND=compile tclsh9.0 tests/all.tcl` | 5847 tests, 5843 passed, 4 skipped (`bindings.test`, as before), 0 failed |
| `tests/native-coverage.tcl` (the suite on cranelift) | 5881 tests: 2462 native, 3288 independent, 71 passed-partial, 60 unsupported (the same 60 as `main`'s last CI run), 0 failed |
| `BOTLISH_NATIVE_GC_STRESS=1`, `CORE_BACKEND=interp` suite | 5847 tests, 0 failed |
| `BOTLISH_NATIVE_GC_STRESS=1`, `CORE_BACKEND=compile`, `contexts.test` | 74 tests, 0 failed |
| `cargo test --release` (native/) | 183 + 31 passed, 0 failed |
| `native/generate-scalar-audit.tcl` | the 13 audited programs' assembly, VCode and listings byte-identical to the committed corpus (only the README's commit and rustc lines differ) |

Two gaps were found along the way and closed. The first mutation run had one
survivor, `alias-calls-not-followed` (a call through an alias `g = f` not
counted as a call of `f`): no test called a context-requiring function through
an alias; `contexts-alias-calls` now does. And the first native-coverage run
failed `contexts-registry-roundtrip` on cranelift: native slot assignment read
the installations from the `contexts` analysis table, which HIR text does not
carry, so a HIR read back from text (`hir::parse`, a `.hir` file) installed
nothing. Each installation's identity is now part of HIR text (`installs
ID`), slot assignment reads it from the installations themselves, and the
round-trip test runs the re-read HIR on every backend in every suite (and the
mutant `installed-identity-not-in-hir-text` checks that it would notice). The scalar-assembly result is the "no cost for
programs without contexts" evidence: a program that installs nothing gets no
context area, no header line and no different instruction.

## 9. Limitations and what remains

* Installation only at the entry program's top level; no nested, function-
  local, dynamic or overriding installation, no test doubles by replacement.
* Exact nominal identity; no traits, no substitutable contexts.
  (Since CONTEXT-TRAITS.md: a context parameter may have a context-trait
  type, satisfied structurally by the one installed context that implements
  it; exact nominal contexts are unchanged.)
* Function values that need a context are rejected (`CONTEXT-FUNCTION-
  VALUE`), aliases aside; requirements are not part of function types.
* Native slots only for layouts of non-pointer leaves; a context holding a
  String, a List, a Bytes, or an unbounded Int is native-unsupported.
* PC-relative access is `lea` + displaced load (Cranelift does not fold a
  symbol into a load); the JIT uses absolute addresses.
* `linux::io::create()` allocates its 7 objects once (§7).
* The native area is process-wide for the main execution domain; there is no
  TLS or actor-local base.

---

## 10. Milestone report

1. **Struct-modifier grammar.** `structDecl = { structModifier } "struct" IDENT
   ":" NEWLINE INDENT structField {structField} DEDENT`, `structModifier =
   "opaque" | "context"`; order-independent, each at most once; canonical
   `opaque context struct`.
2. **Contextual?** Yes. `context` is a modifier only before `struct`, a
   parameter-section marker only when followed by a name, part of a
   declaration only after `with`; `with` only when followed by a name. Both
   remain ordinary names everywhere else.
3. **AST of `context struct`.** The one `structdecl` node with `context 0|1`
   and `contextSpan` beside `opaque`/`opaqueSpan`; no new kind.
4. **AST of `with context`.** A `with` node `{form context formSpan value}`.
5. **Context-section grammar.** `contextSection = "context" contextDecl { ","
   contextDecl }`, `contextDecl = IDENT ":" typeExpr`; the AST `function` node
   has `contexts` ({name nameSpan type typeSpan} dicts in written order).
6. **Order.** `ordinary* -> flags? -> context?`; the context section is last
   (`MALFORMED-CONTEXT-SECTION` otherwise). `flags` unchanged.
7. **Multiple contexts.** One section, several entries: `context io: LinuxIO,
   clock: Clock`.
8. **Duplicate context parameters.** Same type twice:
   `DUPLICATE-CONTEXT-PARAMETER`; a name equal to a parameter, flag or other
   context parameter: `CONTEXT-BINDING-COLLISION`; a body binding of the name:
   `DUPLICATE`.
9. **Installation type inference.** EXPR's ordinary inferred type; exactly one
   named context struct, else `NOT-A-CONTEXT` (definite non-context type) or
   `CONTEXT-TYPE-NOT-EXACT` (anonymous struct, `any`, union).
10. **Duplicate installation.** `DUPLICATE-CONTEXT: T is already installed in
    this scope`, statically; at run time too under `-strict 0`.
11. **Context key.** The canonical struct declaration identity
    (`linux::io::LinuxIO`); nothing else.
12. **Entry-top-level restriction.** `CONTEXT-INSTALLATION-UNSUPPORTED` in a
    function, loop, branch, handler, closure, module or expression.
13. **Source-order scoping.** Available from the `with context` line onward;
    a constructor never sees its own or a later context; modules initialize
    before any installation.
14. **HIR.** `bind context#N EXPR` + `call ^context#install (ref context#N)`;
    `bind io (call ^context#load "T")` at the start of the body; facts on block
    and call nodes and in `hir contexts` (§3); HIR text carries the block and
    installation facts, so a HIR read back from text runs on every backend.
15. **Direct requirement.** `directContexts` of a block: the types its own
    region loads (its context parameters).
16. **Transitive requirement.** `requiredContexts`: least fixed point over
    exact call edges, breadth-first, with a recorded reason per (block, type).
17. **Recursion.** Converges by ordinary fixed-point propagation (self
    recursion, and cycles through nested functions with the context on either
    side; Botlish has no forward references for other mutual recursion).
18. **Unreachable consumers.** Require nothing: defined-but-uncalled
    functions, imported modules, statically unreachable calls.
19. **Higher-order frontier.** Every analysed edge is exact; a function with
    a non-empty requirement cannot become a value (`CONTEXT-FUNCTION-VALUE`),
    so every indirect call is context-free. No context effects in function
    types.
20. **Missing-context diagnostic.** `MISSING-CONTEXT: T is required by this
    call but is not installed here ...` followed by the chain `a -> b -> c ->
    linux::io::write` and `directly requires T`, at the top-level call.
21. **Interpreter.** A per-run dict keyed by identity behind the two internal
    natives (§4).
22. **Tcl compiler.** The same natives, the same per-run environment; no
    compiler change.
23. **Native layout.** One area `botlish_context_area`, one slot per installed
    type, one 8-byte tagged word per flattened leaf; LinuxIO = 24 bytes at
    offset 0: stdin 0, stdout 8, stderr 16; alignment 8; `.bss`.
24. **Slot assignment.** Compile time, in installation order, contiguous
    (`ContextSlots`).
25. **Native eligibility.** Every flattened leaf an Int with a small-Int
    declared domain, a Bool, Unit or a UnicodeChar; no recursive layout.
26. **Unsupported diagnostic.** `NATIVE UNSUPPORTED
    CONTEXT-NATIVE-LOWERING-UNSUPPORTED`: `context T cannot currently be
    stored in a fixed native context slot because field "f" ...`.
27. **No hidden argument.** NIR `params=`/operands, CLIF signatures and
    machine code of every function and call are those of the ordinary
    parameters; hello calls `linux::io::write` with one operand; `top`/`middle`
    calls have none (§7).
28. **No reserved register.** The area address is a per-use temporary
    (`lea ...(%rip),%r9` here, `%rsi` in the program function).
29. **Lowering.** `contextload OFF` / `contextstore OFF %v` -> `symbol_value`
    of the area + `load`/`store` at OFF; AOT: `lea sym(%rip)` after the
    linker relaxes `R_X86_64_REX_GOTPCRELX`; JIT: absolute address.
30. **FileDescriptor.** `opaque struct FileDescriptor: raw: abi::I32`.
31. **LinuxIO.** `opaque context struct LinuxIO: stdin/stdout/stderr:
    FileDescriptor`.
32. **create.** §6: the three literal tokens, no handler, no range check.
33. **Why opaque construction suffices.** Only `linux::io` can build a
    FileDescriptor, so the module's own constructor is the minting authority;
    no generic proof-minting feature was needed.
34. **write.** `fn write(data: abi::bytes::Bytes, context io: LinuxIO) -> int:
    linux::write(io.stdout.raw, data)`.
35. **Stderr.** `write_error`, the same over `io.stderr.raw`.
36. **Stdin.** `fn read(data: abi::bytes::MutableBytes, context io: LinuxIO)
    -> linux::ReadResult: linux::read(io.stdin.raw, data)`.
37. **No descriptor accessors.** `linux::io` exports exactly `create`, `read`,
    `write`, `write_error` (`contexts-linux-io-surface`).
38. **Hello World.** `examples/linux/context-hello.bot` (top of this file).
39. **Output.** `Hello, world!\n` on descriptor 1, then the runner's `14\n`.
40. **strace.** `write(1, "Hello, world!\n", 14) = 14` from
    `botlish_linux_x86_64_syscall` <- `rt_linux_x86_64_syscall` <-
    `linux::write` <- `linux::io::write` <- `hello`; no libc frame.
41. **NIR.** §7.
42. **CLIF.** §7.
43. **Assembly/relocation.** §7: `lea 0x6655(%rip),%r9 #
    <botlish_context_area>; mov 0x8(%r9),%rsi`; `R_X86_64_REX_GOTPCRELX`
    in the object; a local 24-byte `.bss` object.
44. **Allocations.** create 7 (once, the constructor's), installation 0,
    load 0, write 0 per call, a three-level chain 0 (§7).
45. **Three-level implicit-transitive test.** `contexts-transitive-chain`,
    `contexts-missing-chain`.
46. **Consecutive multi-context test.** `contexts-multiple-types`.
47. **Constructor-order test.** `contexts-constructor-order`.
48. **Duplicate-context test.** `contexts-duplicate-install`.
49. **Opaque-context interaction.** `contexts-opacity-exact`,
    `contexts-non-opaque-context`.
50. **Fuzz results.** 400 generated programs, each on all four backends: 291
    accepted, 109 rejected, 0 disagreements with the oracle (§8).
51. **Mutation results.** 26 mutants, 26 killed (one survivor of the first
    run, through an alias call, killed by the test added for it) (§8).
52. **Full regression.** interp and compile suites 5847 tests, 0 failed;
    native coverage 5881 tests, 0 failed, no new unsupported test; GC stress
    5847 tests, 0 failed; `cargo test` clean; the scalar-assembly corpus
    unchanged (§8).
53. **Limitations.** §9.
54. **Before dynamic/nested contexts.** Lexical installation scopes (an
    installed set per scope, restored at scope exit), and a lowering for
    them: a fixed slot no longer suffices when a nested scope can install a
    second value of a type (save/restore of the slot at scope boundaries, or
    a context base); verification over scopes instead of top-level
    statements; replacement semantics decided.
55. **Before actor-local contexts.** The same compile-time layout addressed
    from an actor-local base (a register or TLS) instead of the PC-relative
    process symbol -- a lowering change only; no source change.
56. **Before trait-based contexts.** Eager one-way traits, so a concrete
    context (`LinuxIO`) satisfies a weaker trait (`IO`), and identity by trait
    in requirements; substitutable contexts (fakes) then follow from
    installation, not from runtime registration.
57. **Before mutable contexts.** A semantics of state owned by an installed
    value (and its interaction with immutable value semantics), and a native
    representation that can hold heap references (rooted context storage).
58. **Before `resource struct` / RAII.** The `resource` modifier (one more
    table entry), resource `with NAME = EXPR` declarations (the parser's `with`
    form is ready), cleanup at scope exit and ownership; descriptors from
    `openat`/`socket` as resources.
59. **Before `direct` restrictions.** A policy layer that lets application
    code prefer contextual APIs (`linux::io`) and restricts raw operations
    (`linux::write`, `linux::abi::syscall`) to designated modules.
