# Immutable module bindings

A module may contain the same ordinary immutable binding syntax used in a
function:

```botlish
namespace web

hex_digits = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"]

fn uri_escape_text(s):
    # hex_digits is the retained binding above.
    ...
```

A namespace remains a compile-time concept. `web::hex_digits` resolves through
the module scope and its stable `BindingId`, exactly as `web::uri_escape_text`
does. There is no namespace object, property lookup, or name lookup at run
time.

## Initialization and order

`surface::modules::LoadNamespace` still discovers dependencies from qualified
references and loads them dependency-first. `hir::resolve::ProgramSection`
puts every module section into the ordinary program roots in that order, with
source order preserved inside each module. Normal program evaluation then
executes each binding initializer once before the entry roots execute.

Within one module, an initializer may only read a preceding binding. A direct
forward read is the ordinary resolver's `CORE SEMANTIC UNBOUND` error, so
partially initialized values and value cycles are unavailable. Function
bodies retain their existing resolution rules: they may refer to module
bindings that will exist when the function is later called.

An error raised while evaluating a legal initializer uses normal Botlish error
completion propagation. There is no special module-constructor or
module-initialization exception path.

## Safety rule

`hir/modulebinding.tcl` validates each non-function module binding after
resolution and type inference. It proves two independent facts.

1. **Context-free initializer.** Literals, references, control flow, and
   statically resolved calls are walked by semantic identity. A direct Block
   call is inspected transitively; the visitation state makes recursive call
   graphs terminate. Natives opt in through
   `core::native::register -context-free 1`; an unclassified native is
   rejected with `CORE SEMANTIC MODULE-CONTEXT`. This admits String and List
   construction, arithmetic, and other explicitly classified operations, but
   does not require compiler evaluation or constant folding. Allocation alone
   is allowed.
2. **Transitively immutable retained value.** The proof records scalar kinds,
   every List element proof, and Block captures. `Int`, `Bool`, `Unit`,
   `String`, and structurally proven nested Lists are accepted. `MutableArray`
   is rejected directly and through a List with `CORE SEMANTIC
   MODULE-IMMUTABLE` (for example, `List element -> MutableArray`). Unknown
   result shapes are rejected conservatively. The proof is performed once
   during compilation; reads do not revalidate a retained value.

The value validator is intentionally small. It recognizes List construction
and `list_append`, plus direct ordinary function calls whose body can be
proved. It does not introduce a capability system, a constexpr interpreter,
lazy cells, mutable globals, or a new static-data representation.

## HIR, runtime, and GC lifetime

A module value is an ordinary HIR `bind` in its module `ScopeId`, with its
normal initializer `ExprId`, source `FileId`, and `BindingId`. No global-value
HIR node or NIR opcode was added. Module scopes are materialized with the
normal top-level program environment for the interpreter and Tcl compiler.
The native lowerer enters those scopes while lowering the program function,
so initialized managed values are normal live program values. A capturing
module function retains the value through its ordinary closure environment;
an envless direct function receives a lifted captured value as a direct hidden
argument. Native root liveness and GC safepoints treat these values as normal
managed roots, and temporary initializer intermediates are not retained just
because initialization occurs at startup.

## `web::hex_digits`

Before this change, `uri_escape_text` constructed the 16 String List in its
function body. It therefore constructed the table once for every invocation.
It is now the module binding in `lib/web.bot`.

For a native program that calls `uriEscape` twice with the same 16-character
input, `native::allocationReport` finds the `hex_digits` List allocation site:

| table construction | before | after |
|---|---:|---:|
| `hex_digits` List allocations | 2 | 1 |
| placement in NIR | `web::uri_escape_text` | `<program>` |

Thus for `N` calls, the table construction changes from `N` to `1`. The table
is not compiler static data and has no URI-specific opcode.

The representative unspecialized NIR after the change begins as follows:

```text
func 0 "<program>" ...
    ...
    %16 = op listnew %0 ... %15       # web::hex_digits, once
    %17 = closure 1 %16               # uri_escape_text, once
    %19 = callenv 1 %17 %18

func 1 "web::uri_escape_text" params=1 env=1 ... captures=1
    %1 = capture 0
```

`uri_escape_text` is therefore no longer envless: its one environment field
is `hex_digits`. The program makes one closure for it at startup, then uses
the existing statically known `callenv 1` form for each root call. Cranelift
CLIF resolves that form to a direct call of `botlish_fn_1`; it does not use
name dispatch. Its four nested helper closures remain per invocation, as they
were before the table move. The module-value capture adds no per-call closure
allocation.

With `-repr-opt 0`, the same two-call probe measured 8,644 B before and
8,666 B after. The program function changed from 311 B to 989 B (table and
startup closure); `web::uri_escape_text` changed from 1,150 B to 494 B. The
other helper functions were unchanged. These are structural audit data, not
an optimization target for this milestone.

## Regression coverage

`tests/surface-modules.test` covers scalar, String, List, nested List,
cross-module values, repeated module-value use, identity through qualified and
same-module references, transitive context rejection, mutable retention, and
forward-read rejection. It also checks the native startup NIR and allocation
site for `web::hex_digits`. Native GC-stress and the normal backend suites
cover normal liveness and backend parity.
