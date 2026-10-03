# Direct Linux x86-64 syscalls: the machine boundary

## Outcome

Botlish can take an ordinary integer, encode it as an x86-64 machine-register
value, invoke an arbitrary Linux syscall through one generic raw syscall
operation, recover the raw `rax` result as an ordinary Botlish integer, and
the complete path is demonstrated with `getpid` -- without the compiler
knowing what `getpid` is:

```botlish
fn raw_getpid():
    abi::x86_64::to_int(
        linux::abi::syscall({
            rax: abi::x86_64::register64(39),
        })
    )
```

```
Botlish Int
    --abi::x86_64::register64-->  Register64      (ordinary Botlish, lib/abi/x86_64.bot)
    --linux::abi::syscall------>  `syscall`       (the one privileged operation)
    --> rax as a Register64
    --abi::x86_64::to_int------>  Botlish Int     (ordinary Botlish)
```

* `abi::x86_64::Register64` and both conversions are **ordinary Botlish**: a
  nominal struct whose one field is typed with a source-defined integer
  domain. Nothing about them is compiler-defined.
* `linux::abi::syscall` is the **only** privileged operation: a root native
  that knows the Linux x86-64 syscall *transport* convention (which register
  carries what) and no syscall. Natively it is a helper call whose body is a
  seven-register inline-asm `syscall`; the Tcl backends refuse it with an
  intentional `NATIVE-ONLY` error.
* The canonical form is **zero-allocation and check-free**: the compiled
  `register64` instance for a proven constant is a single `retmulti` of its
  argument (no comparison, no fail path, no BigInt -- the call to it remains,
  since tiny-leaf inlining does not take functions with `if`/`fail`), the
  register struct is never built, the result `Register64` is never built,
  and 1001 calls of `raw_getpid()` plus 1001 conversions allocate nothing
  (`native::allocationReport`: 0 objects).
* **Evidence of a real syscall**: the pid a standalone executable prints is
  exactly the pid its launching Tcl process sees for it; an in-process JIT
  run returns exactly the pid of its driver process; the executable's machine
  code contains exactly one `syscall` instruction (in the boundary function,
  after moving the words into rax, rdi, rsi, rdx, **r10**, r8, r9), and libc's
  `getpid` is not even linked.
* Two small language extensions were needed and are general: **nested
  namespaces** (`abi::x86_64`, `linux::abi`) and **qualified root natives**.
  One representation analysis was extended (escape analysis knows the
  syscall's register struct and result), and two pieces of generated-code
  waste the conversions exposed were removed generally: a decided `if`
  condition that provably has no effect is no longer evaluated (M6's
  documented "condition-expression purity" missing theorem, narrowest form),
  and a proven big Int constant such as `-9223372036854775808` (`0 - N` in
  source) is a static constant instead of a run-time negation that allocated
  on every evaluation.

## Source surface

### `abi::x86_64` (lib/abi/x86_64.bot)

```botlish
namespace abi::x86_64

error Register64BelowRange
error Register64AboveRange

type Register64Word = Int in -9223372036854775808..9223372036854775807

struct Register64:
    word: Register64Word

fn register64(value: int) -> Register64 errors Register64BelowRange, Register64AboveRange:
    if value < -9223372036854775808:
        fail Register64BelowRange
    elif value > 9223372036854775807:
        fail Register64AboveRange
    else:
        Register64 {word: value}

fn to_int(register: Register64) -> Register64Word:
    register.word
```

* `register64(value)`: accepts exactly `-2^63 <= value <= 2^63 - 1`; the
  register contents are that value's 64-bit two's-complement bit pattern.
  Anything else is the declared `Register64BelowRange` / `Register64AboveRange`
  -- the repository's normal checked-conversion semantics (byte::from_int's
  shape, EXPLICIT-ERROR-COMPLETIONS.md), never truncation. The call-specific
  completion proof (STATIC-COMPLETION-PROOFS.md) makes `register64(39)` need
  no handler and `register64(9223372036854775808)` a compile-time
  `KNOWN-ERROR`.
* `to_int(register)`: the register contents read as a signed 64-bit integer
  (`0x...27 -> 39`, `0xffffffffffffffff -> -1`), an ordinary
  arbitrary-precision Int. Its declared result `Register64Word` is a subtype
  of Int (its arithmetic is Int arithmetic, `to_int(r) + 1` past `2^63 - 1`
  does not wrap); declaring it only tells callers the true static fact, so
  `register64(to_int(r))` needs no handler. No errno or other meaning is read.
* **Why `abi::x86_64::to_int`, not `abi::to_int`.** The signed 64-bit reading
  is a property of this architecture's register word, and Botlish has no
  overloading: a portable `abi::to_int(abi::x86_64::Register64)` would tie
  the `abi` namespace to x86-64 (another architecture's register type could
  not be accepted without redefining it). Each architecture's transport
  layer owns its register type and its conversions; the later ABI-domain
  layer (`abi::I32`, ...) can choose its own spelling.
* **Why the error names are new.** Error names are global (hir/errordecls.tcl)
  and `BelowRange`/`AboveRange` are byte.bot's; reusing them would make
  `abi::x86_64` depend on `byte`. The two-error granularity is byte's.

### Register64 is transport, not a machine integer

It is a struct: `r + 5`, `r * 8`, `r < r` are the ordinary run-time TYPE
error any struct operand gets (`+: expected int, got abi::x86_64::Register64
{word: 20}`), identically on every backend. There is no wrapping, bitwise,
ordering, pointer or promotion API, and none was added. The language's
generic structural equality applies (`register64(1) == register64(1)`), as
for every struct. It prints as the nominal struct it is.

**Soundness without privacy.** Botlish has no private construction, and none
was added: any code can write `abi::x86_64::Register64 {word: x}`. That is
sound because a named construction must *statically prove* each field
admissible for its declared type, with no runtime guard (STRUCTS.md, "Named
struct construction"): `Register64 {word: 9223372036854775808}` and
`fn wrap(x: int): Register64 {word: x}` are compile-time TYPE errors. Every
Register64 that exists holds exactly one of the 2^64 bit patterns.

### `linux::abi::syscall` (core/linuxabi.tcl, hir/syscall.tcl)

```
linux::abi::syscall({rax: R, rdi: R, rsi: R, rdx: R, r10: R, r8: R, r9: R})
    -> abi::x86_64::Register64          R: abi::x86_64::Register64
```

| register | carries |
|---|---|
| `rax` | the syscall number (required) |
| `rdi` `rsi` `rdx` | arguments 1-3 |
| `r10` | argument 4 (not rcx: the `syscall` instruction overwrites rcx) |
| `r8` `r9` | arguments 5-6 |
| result | rax after the transition, raw |

* The argument is an anonymous struct literal (or any expression whose static
  type is such a struct). Botlish has no optional fields and no annotation for
  an anonymous struct type, so instead of building a general optional-field
  system, `hir/syscall.tcl` checks this one native's argument against its
  inferred struct type: every field must be one of the seven names
  (`UNKNOWN-FIELD` at the field otherwise -- `rbp`, `rcx`, `rsp`, `r11` are
  all rejected, never ignored), `rax` must be present (`MISSING-FIELD`), and
  every field must statically be a Register64 (`TYPE`: no run-time check is
  ever inserted). A named struct, a Register64 itself or an Int argument is
  `TYPE`; a wrong argument count is `ARITY`.
* **An omitted argument register is zero.** No caller writes six meaningless
  zeros: `linux::abi::syscall({rax: abi::x86_64::register64(39)})` is getpid.
* The result is the raw rax as a Register64: no negative-to-error mapping, no
  errno, no `-1` convention, no retry, no Result, no `pid_t`.
* It can only be **called directly**: a reference to it that is not a call's
  callee is TYPE (its parameter has no `Fn{...}` spelling, and a dynamic call
  would have to find registers by name at run time).
* Source spells it like a module function, but it is a **root native**
  registered under its qualified name. `surface/modules.tcl` loads no module
  for it and `surface/lower.tcl` resolves it to a root reference (no local
  binding can spell `::`, so it cannot be shadowed); a module `linux::abi`
  may exist for other members but may not define `syscall`
  (`SURFACE MODULE DUPLICATE-NATIVE`).

### Nested namespaces

`namespace a::b` declares the nested namespace `a::b`, which lives in
`lib/a/b.bot` (one directory per leading segment, never `::` in a file name,
so the Windows checkout works); `a::b::c` is member `c` of `a::b` in
expressions, types (`fn f(r: abi::x86_64::Register64)`) and named
constructions. `a` and `a::b` are unrelated modules: nesting is a naming
path, not containment. The change is four parser/loader procs
(`NamespaceDecl`, `Primary`, `TypeExpr`, `ModulePath`, and `TypeRefs`'
regex); everything downstream already treated a namespace as an opaque
string. The two tests that pinned "only one level" now pin the nested
meaning, and new ones cover nested files, struct types across nested
modules, and the three nested diagnostics (missing file, mismatched
declaration, unknown member).

## Effects

`linux::abi::syscall` interacts with the kernel, may block, may modify any
process or kernel state, may (with future pointer arguments) read or write
any memory, and returns different results for identical inputs. It is
treated accordingly at every layer, by default rather than by exception
(CLOSED-CALL-EFFECTS.md, the effects research for this milestone):

| layer | treatment |
|---|---|
| registry | `-context-free 0` (the default). A module binding initialized with a syscall is `MODULE-CONTEXT` (tested) -- today already because of the register-struct literal every call needs (a struct is not a context-free initializer); the native's own classification keeps it rejected if struct initializers are ever accepted |
| HIR | in no allowlist: no exact-value fact, never a decided comparison, never two calls considered the same value (SAME-RETURN-VALUE never compares calls), result range unknown |
| native lowering | always emits the op, including in statement position (a discarded call still runs; tested in NIR, CLIF and on the Tcl backends); never inlined, hoisted, merged or folded (no NIR optimizer exists) |
| NIR | `op_may_allocate` (a GC safepoint: the rax result may be boxed as a BigInt) and `op_may_error` (only a backend-bug path) |
| Cranelift | a real `call` of the helper: `trivially_has_side_effects`, a memory fence for alias analysis, never GVN'd/LICM'd/DCE'd, every caller-saved register clobbered (tested: two calls stay two calls, a discarded call stays) |
| the boundary | `asm!` with no `pure`/`nomem`/`readonly`: rustc/LLVM must assume it reads and writes all memory and is never removable |

Unknown memory effects are modeled strongly now, not deferred: at the
machine level a helper call is already an all-memory barrier, and HIR has no
memory-effect facts a future pointer syscall could invalidate (Botlish
values are immutable except MutableArray, whose contents HIR never assumes).

## Native implementation

### NIR and lowering (native/lower.tcl)

```
%w = op syscall_linux_x86_64 RAX RDI RSI RDX R10 R8 R9
```

Seven Int operands -- the Register64 words, each a proven `-2^63..2^63-1`
Int -- in the syscall convention's order, the Int 0 (one shared constant) for
an omitted argument register, and the raw rax as an Int. `SyscallCall`
evaluates the literal's fields in **written order** (struct-literal
semantics; tested), reads each register's word, and assembles the operands
in **register order**. The canonical getpid lowers to:

```
func 1 "abi::x86_64::register64" ... results=1
    retmulti %0
end
func 3 "raw_getpid" ...
    %0 = int 39 @e33
    %2 = callmulti 1 %0 @e31
    %3 = int 0 @e28
    %4 = op syscall_linux_x86_64 %2 %3 %3 %3 %3 %3 %3 @e28
    %5 = call 2 %4 @e26           ; to_int's fields variant: `ret %0`
    ret %5
end
```

### Representation: zero allocation

Semantic identity and physical representation are separate. Register64 is
an ordinary struct to every semantic layer; physically it is carried as its
one field, a tagged Int word in a register, by the existing struct scalar
replacement (STRUCT-SCALAR-REPLACEMENT.md, VALUE-TRANSPORT-MATERIALIZATION.md),
extended (hir/escape.tcl) with exactly the knowledge this transport needs:

* **The syscall's result is a construction.** `Classify` recognizes a
  `linux::abi::syscall` call as a local one-field Register64 construction,
  exactly as it recognizes the `list` native as a List construction: a
  consumer that takes fields (`to_int`'s `fields` variant, a projection, a
  virtual local, an exact return) gets the op's result register, never an
  object.
* **The register struct literal is never built.** Its fields are read by
  `SyscallCall` directly; a field that is a recognized Register64
  construction (a `register64(...)` call returning fields -- its companion is
  demanded, `RegisterWords` -- a literal, a nested syscall, an `if` of those)
  is read from its virtual fields; a Register64 held in a virtual local is
  read from the local (`wordUse` counts the field position as a projection
  in `UseVerdict`); only a Register64 that already exists as an object is
  read with `structget`.
* A Register64 materializes (`structnew`, a 40-byte StructObj plus its slot
  array) only at the existing materialization frontiers: stored in a List,
  compared or hashed, passed through an untyped or open boundary, or into a
  function whose every caller cannot supply fields. Measured: 1001 getpid
  calls and 1001 conversions, 0 allocations of any kind.
* **One syscall-specific frontier remains (pinned by a test).** A register
  struct *bound to a local* and then passed by name
  (`regs = {rax: ..., rdi: ...}; linux::abi::syscall(regs)`) is built as an
  object: the struct itself (only an inline literal argument is opened; an
  ordinary exact call would take the bound struct as fields), plus one
  Register64 per register (a `register64(...)` result nested in a bound
  literal is an opaque call result to scalar replacement -- a general
  limitation, VALUE-TRANSPORT-MATERIALIZATION.md). Two registers cost three
  objects; the same registers written inline cost none. Teaching
  `SyscallFields`/`UseVerdict` to open a single-use bound register literal
  would remove the first; the rest needs nested call results to be openable.
* **Int width.** A native small Int is 63-bit (`-2^62..2^62-1`), so a word
  outside that range is a heap BigInt while it is a tagged Int -- a property
  of the Int representation, not of Register64 (the source Int already was
  one). Literal words are static constants (no allocation); the helper reads
  BigInt operands as their i64 words and boxes rax as a BigInt only when it is
  outside the small range (`Vm::new_int`).

### Proven conversions emit no checks

For `register64(39)` the range analysis decides both bound comparisons, M6
already removed the branches and fail paths, and this milestone removes what
M6 deliberately left: the comparisons themselves, and the run-time
`0 - 9223372036854775808` that allocated a BigInt on *every call*:

* `native::lower::PureDecidedCondition`: an `if` whose outcome is decided
  and whose condition is a native comparison (`< <= > >= ==`) of operands that
  are Int constants, Int registers this function already holds (a parameter
  or an evaluated local: reading it is a register read) or `+ - *` of those
  -- with no runtime kind guard anywhere -- is not evaluated at all. Such an
  evaluation has no effect and cannot fail, so under a decided outcome it is
  dead code. This is M6's own missing theorem #1, in its narrowest form;
  every other decided condition is still evaluated for its effects.
* `native::lower::BigConstantResult`: an Int `+ - *` of integer constant
  expressions (literals, or `+ - *` of them -- a negative literal is `0 - N`)
  whose value is outside the small-Int range becomes that value as a static
  BigInt constant (the operands are still evaluated first; only the pure,
  total operation is dropped). Only source constants are folded: arithmetic
  on a parameter whose proven range happens to be one big value keeps its
  ordinary representation decision. A small result is left alone (raw
  arithmetic already computes it without allocating).

`register64(39)`'s instance is now `retmulti %0`; a dynamic `register64(n)`
compares `n` against two static constants. Existing programs: the same values
everywhere (full regression below); their NIR loses the dead comparisons M6
documented, and five pinned tests were updated to say so
(`checked-domain-q1-*` x2, `checked-domain-q3-real-nir-retains-above-range-check`,
`demand-tagged-only-result`, and `root-structural-2`: bench/loop-count.bot's
`work` needs 12 registers instead of 15).

### The boundary (native/src/runtime/syscall.rs)

```rust
#[unsafe(no_mangle)]
#[inline(never)]
pub unsafe extern "C" fn botlish_linux_x86_64_syscall(
    rax: i64, rdi: i64, rsi: i64, rdx: i64, r10: i64, r8: i64, r9: i64,
) -> i64 {
    let result: i64;
    unsafe {
        core::arch::asm!(
            "syscall",
            inlateout("rax") rax => result,
            in("rdi") rdi, in("rsi") rsi, in("rdx") rdx,
            in("r10") r10, in("r8") r8, in("r9") r9,
            lateout("rcx") _, lateout("r11") _,
            options(nostack),
        );
    }
    result
}
```

**This function is the true privileged boundary**, and the only place
Botlish executes a kernel transition. It is a generic seven-word register
bridge: it knows no syscall number, interprets no result, and is
`#[cfg(all(target_arch = "x86_64", target_os = "linux"))]`.

* **Why a helper.** Cranelift has neither a `syscall` instruction nor inline
  assembly, so the instruction lives in one Rust function with inline `asm!`.
  It is not a libc wrapper: it never calls `syscall(3)`, `getpid(2)` or
  anything else; the disassembly is a prologue, seven register moves,
  `syscall`, `ret`.
* **Two conventions, kept separate.** The boundary is entered through the
  platform function ABI (System V: its seven parameters -- rax, rdi, rsi,
  rdx, r10, r8, r9 words, in that order -- arrive in rdi, rsi, rdx, rcx, r8,
  r9 and on the stack); the asm constraints then place each word where the
  *kernel* convention wants it. Disassembled:
  `mov r11,r9; mov rax,rdi; mov r9,[rbp+0x10]; mov rdi,rsi; mov rsi,rdx;
  mov rdx,rcx; mov r10,r8; mov r8,r11; syscall`. Every word moves one
  register over: syscall argument 4 (the boundary's 5th parameter) arrives in
  r8 and goes to r10, while rcx -- which a function call would use for its
  4th argument, and which `syscall` itself overwrites -- carries argument 3
  into rdx. The test suite checks this routing by simulating the
  disassembly from the function's entry (below).
* **Clobbers.** `syscall` overwrites rcx (return rip) and r11 (saved rflags)
  and returns in rax: declared. Flags are not declared preserved. `nostack`:
  the kernel does not touch the user stack. Generated code reaches the
  boundary through `rt_linux_x86_64_syscall` (the value-conversion helper)
  with an ordinary Cranelift `call`, which already treats every caller-saved
  register (a superset of rax/rcx/r11) as clobbered; the kernel preserves the
  callee-saved ones. Nothing about clobbers reaches Botlish source.
* `rt_linux_x86_64_syscall(vm, rax..r9: Value) -> Value` reads each operand as
  its i64 word (a small Int, or a BigInt within i64: `register_word`), calls
  the boundary, and returns rax read signed (`rax_value`: `Vm::new_int`). An
  operand that is not such an Int -- impossible for a checked program, but an
  unchecked (`-strict 0`) program can build a Register64 whose word HIR
  rejected -- is a `TYPE` error before any transition, never a truncation.
* **Unchecked programs.** A `-strict 0` compilation keeps its diagnostics
  instead of raising them. Native lowering re-asks hir/syscall.tcl's
  `Problems` of the HIR it lowers and, for a call that broke the register
  contract, emits the diagnostic as a run-time error *instead of* the call
  (LockLoop's precedent): no syscall runs with a defaulted rax or a dropped
  register, and no register is read from a value nothing proved.

### Target gating

The native backend targets Linux x86-64 only today, and the assumption is
explicit at every layer of this operation rather than inherited: the
boundary is `cfg`-gated; code generation (`codegen/clif.rs`) refuses
`syscall_linux_x86_64` with `NATIVE CODEGEN` when the backend is built for any
other target; the NIR op, the helper and the register set are named for
Linux x86-64; and the register struct's names and Register64 type come from
one place (`core::linuxabi::registers`/`registerType`). No x32, i386, ARM or
AArch64 convention exists; another architecture would add its own transport
(its own register type under `abi::<arch>` and its own register contract)
rather than reinterpret this one.

## Tcl backends: an intentional refusal

The interp and compile backends cannot execute an x86-64 instruction, and do
not imitate a syscall with some other host facility (a Tcl `pid` would test
the wrong abstraction). The native's Tcl implementation raises:

```
linux::abi::syscall executes the x86-64 "syscall" instruction (a raw Linux kernel
transition) and is performed only by the native backend (cranelift, or a standalone
executable) on Linux x86-64; the Tcl backends (interp, compile) do not execute machine
instructions and do not imitate a syscall (CORE SEMANTIC NATIVE-ONLY)
```

`NATIVE-ONLY` is a new semantic kind (core/errors.tcl). Only the *call* is
refused, when it runs: a program that defines `raw_getpid` but never calls it
runs on every backend, and all of `abi::x86_64` (the pure conversions) runs
and is tested on all four backends. A discarded call is still refused (never
optimized away).

## Tests

`tests/linux-syscall.test` (37 tests; every one gives the same result
whatever `CORE_BACKEND` is, since each names its backends, and none
disturbs a suite-wide `BOTLISH_NATIVE_GC_STRESS`):

* **Registration:** one qualified root native, arity 1, struct parameter,
  Register64 result shape, no errors, not context-free, runtime tag
  `raw-syscall`; no getpid/read/write/open/errno or other linux/abi native
  exists.
* **Conversions, all four backends:** boundaries `0, 1, 39, -1, 2^63-1,
  -2^63` and both small-Int boundaries round-trip; `2^63, -2^63-1, 2^64-1,
  2^64, -2^64, 2^128` are rejected with the right error; constant proofs
  (in-range constants including both extremes need no handler; out-of-range
  constants are KNOWN-ERROR naming the violated bound even with a handler;
  an unprovable Int must be handled or declared); the round trip needs no
  handler; to_int's result is unbounded Int arithmetic; misuse as an integer
  is TYPE; direct construction must be proven.
* **Generated code for proven conversions:** `register64(39)`'s instance has
  no op, no fail path and no structnew; 1001 conversions allocate nothing; a
  dynamic instance's `-2^63` bound is a static constant (no `isub`).
* **The static contract:** UNKNOWN-FIELD (with its location), MISSING-FIELD,
  TYPE for non-Register64 fields (Int, List, untyped parameter) and
  non-register-struct arguments, ARITY, no function value, MODULE-CONTEXT for
  a module binding (and the native's own not-context-free classification),
  DUPLICATE-NATIVE for a module shadowing it; a field that cannot complete
  hides nothing about the others; a `-strict 0` program that broke the
  contract replays it natively (UNKNOWN-FIELD, TYPE, MISSING-FIELD) instead
  of running a syscall.
* **Tcl backends:** NATIVE-ONLY on interp and compile alike; definitions
  without calls run everywhere; a discarded call is refused.
* **getpid, natively (Linux x86-64):** positive and stable over three calls on
  `cranelift` and `cranelift-generic`; **in-process: equal to the pid of the
  driver process** (recorded by a wrapper that `exec`s the driver, keeping
  its pid -- both specialized and unspecialized); **standalone: equal to the
  pid Tcl's `open |exe` reports for the child, on two runs of one build,
  which have two different pids** (so the syscall runs at run time, never
  folded into the build); GC stress (virtual, stored-in-a-List and BigInt
  register words); every argument shape (register64 calls, Register64 locals,
  a typed Register64 parameter, a register struct in a variable, results
  used twice, stored, discarded); the canonical form allocates nothing over
  1001 calls (no register struct, no Register64, no BigInt); the example
  file itself runs (`[true, true]` natively, NATIVE-ONLY on the Tcl backends).
* **Backend evidence:** NIR -- one generic op, operands in register order
  (`{r8, rdi, rax}` written order becomes `rax rdi 0 0 0 r8 0`), fields
  evaluated in written order, `39` only as the literal's own constant, no
  `getpid` anywhere; CLIF -- a real call of `rt_linux_x86_64_syscall` with a
  stack map, two source calls are two calls, a discarded one stays; machine
  code (objdump) -- simulating the boundary function's instructions from its
  entry, `syscall` executes with rax = its first parameter and rdi, rsi, rdx,
  r10, r8, r9 = its second to seventh (any other instruction shape fails the
  test loudly rather than passing vacuously); the runtime helper's calls,
  resolved through the executable's GOT relocations, reach the boundary's
  address and never libc's `syscall(3)` (which Rust std imports anyway); the
  whole executable has exactly one `syscall` instruction; `getpid` is not an
  imported symbol.
* **Fuzz:** seeded in-suite fuzz of the pure round trip and its rejections
  against an independent Tcl oracle (3 x 120 values, ~30% out of range,
  clustered on both register bounds and both small-Int bounds; all four
  backends, plus GC stress natively).

Rust unit tests (`native/src/runtime/syscall.rs`, `cargo test`): the
boundary's getpid equals `std::process::id()`, is stable, and ignores
garbage in unused argument registers; register words of every Int
representation (small, BigInt, the i64 extremes); the helper returns rax as
an Int, reads BigInt operands, and never truncates a non-word operand (a
non-Int or 2^64 is TYPE); rax words are read signed (`-1`, `-38`, `-4095`,
`i64::MIN`, ... -- kernel error returns stay negative Ints), pinned without
making any other syscall.

**Only getpid runs in the suite.** As instructed, getpid (harmless,
argument-free) is the one live syscall any test executes, and nothing is
fuzzed against the kernel. getpid cannot observe argument routing, so that is
pinned statically (the machine-code simulation above). As a manual
development check only -- not part of the suite -- two calls without side
effects show the routing and the raw signed result end to end through
Botlish on both native backends:

```botlish
fn sys(nr: abi::x86_64::Register64, a1: abi::x86_64::Register64, a4: abi::x86_64::Register64):
    abi::x86_64::to_int(linux::abi::syscall({rax: nr, rdi: a1, r10: a4}))

# 100000: no such syscall, the kernel returns -ENOSYS and does nothing.
# 157 = prctl, option 39 = PR_GET_NO_NEW_PRIVS (a getter), which requires
# arguments 2-5 to be zero: r10 = 0 gives the flag (0), r10 = 1 -EINVAL.
[sys(r(100000), r(0), r(0)), sys(r(157), r(39), r(0)), sys(r(157), r(39), r(1))]
#  -> [-38, 0, -22]        (r: register64 with handlers)
```

The result changes only through r10 (argument 4), and with r10 = 0 the
omitted rsi, rdx and r8 must all have reached the kernel as zero; the kernel's
error returns arrive as raw negative Ints, never as libc's `-1`/errno.

`strace` is not a test dependency. As a manual development check, on a
standalone build of the getpid program (`-k` prints the user-space stack of
each traced syscall):

```
$ strace -f -e trace=getpid -k ./getpid
[pid  2320] getpid()                    = 2319
 > ./getpid(botlish_linux_x86_64_syscall+0x1f) [0x26fdf]
 > ./getpid(rt_linux_x86_64_syscall+0xcc) [0x270bc]
 > ./getpid(botlish_fn_3+0x4e) [0x7cd8c]        <- raw_getpid
 > ./getpid(botlish_fn_0+0x9) [0x7cce0]         <- the program
```

The kernel saw `getpid()` issued from the boundary function, called from the
helper, called from `raw_getpid`'s machine code -- no libc frame anywhere.
(The program runs on a worker thread, 2320, with its own large stack; getpid
correctly returns the process id, 2319.)

Updated tests: `surface-parser.test` (`double-colon` now a dangling `::`),
`surface-modules.test` (nested namespaces: 1 changed, 3 new), and the five
pinned dead-comparison counts above.

## Fuzz results

`audit/linux-x86-64-syscall/tools/fuzz.tcl` (pure conversions only: the
kernel transition is never fuzzed) checks, per seeded program, the dynamic
conversion of every value on every backend against the oracle, each of ten
values as a *constant* argument (in range: no diagnostic at all; out of
range: KNOWN-ERROR naming the right bound), and the round trip through a
typed parameter and `register64(to_int(r))`
(`audit/linux-x86-64-syscall/fuzz-result.txt`):

```
$ tclsh9.0 audit/linux-x86-64-syscall/tools/fuzz.tcl -n 200 -seed 1
register64-fuzz programs 200 values 40000 out-of-range 9975 constant-checks 2000 failures 0
    (interp, compile, cranelift-generic, cranelift)

$ tclsh9.0 audit/linux-x86-64-syscall/tools/fuzz.tcl -n 30 -seed 5001 -gc-stress 1 \
      -backends "cranelift-generic cranelift"
register64-fuzz programs 30 values 6000 out-of-range 1499 constant-checks 300 failures 0
```

Plus the in-suite seeded fuzz (3 x 120 values on four backends, one seed
again under GC stress): 0 failures.

## Regression

All on the final tree (this milestone merged with the then-current `main`,
which had gained flag parameters), Linux x86-64, Tcl 9.0.1, rustc 1.97:

| run | result |
|---|---|
| `CORE_BACKEND=interp tclsh9.0 tests/all.tcl` | 5047 tests: 5047 passed, 0 failed (18m35s) |
| `CORE_BACKEND=compile tclsh9.0 tests/all.tcl` | 5047 tests: 5043 passed, 4 skipped (the existing `coreScoping` constraint), 0 failed |
| `BOTLISH_NATIVE_GC_STRESS=1 tclsh9.0 tests/all.tcl` (interp) | 5047 tests: 5047 passed, 0 failed |
| `tclsh9.0 tests/native-coverage.tcl` | 5081 tests on cranelift: 2131 native, 2821 independent, 69 passed-partial, 60 unsupported (all pre-existing test-only natives and constructs), **0 failed** |
| `cargo test --release` | 151 + 28 passed, 0 failed |
| `tclsh9.0 main.tcl -backend interp` / `compile`, and CI's cranelift example list | all values as before (interp output byte-identical to the baseline) |

Before the merge, the same branch also passed every suite; the only failures
ever seen were the expected pins listed above (nested namespaces, the dead
comparisons), updated with the change.

## Review

The change was adversarially reviewed by four independent reviewers
(lowering and escape-analysis soundness; the Rust boundary, codegen and GC;
the front end and the static contract; requirements and test quality), and
each finding was checked by a separate skeptic. Fixed as a result:

* A register literal with a field that cannot complete (type `never`)
  skipped the contract check entirely, and native lowering then read
  registers from unproven values (a crash); the contract is now checked
  field by field.
* A `-strict 0` program that broke the contract was compiled anyway (a
  syscall with a defaulted rax, or an unproven read); it now replays the
  diagnostic at run time. The helper's non-word path is a TYPE error rather
  than an internal bug for the same reason.
* Tests made sharper: the module-binding test now also pins the native's own
  classification; the machine-code test simulates the boundary's register
  routing instead of checking set membership; a new test resolves the
  helper's calls through the GOT to prove it reaches the inline-asm
  boundary and never libc's `syscall(3)`; the syscall path's zero allocation
  and the bound-register-struct frontier are pinned; the example file runs;
  environment variables a test sets are restored (a suite-wide GC-stress run
  keeps its stress). A big-constant fold that was broader than intended
  (it folded range-derived points, changing two unrelated pinned tests) was
  narrowed to source constant expressions.
* Kept deliberately: two legacy test names (`...-still-emits-both-checks`)
  that the M5/M6 reports cite, with their descriptions updated, as M6 did.

## Milestone report

1. **Namespace additions.** `abi::x86_64` (lib/abi/x86_64.bot): struct
   `Register64`, functions `register64`, `to_int`; and, global by the
   language's rules, the type `Register64Word` (with its predicate native
   `Register64Word?`) and the errors `Register64BelowRange`,
   `Register64AboveRange`. `linux::abi`: the root native
   `linux::abi::syscall` (core/linuxabi.tcl); no module file. Language: nested
   namespaces and qualified root natives.
2. **Register64** is **ordinary Botlish** (a nominal struct over a
   source-defined domain). The compiler's only knowledge of it: the
   intrinsic's contract names it as the register type (core/linuxabi.tcl),
   and escape analysis knows it is the one-field shape the syscall reads and
   produces.
3. **Accepted domain of `register64(Int)`:** exactly `-2^63 <= value <= 2^63
   - 1`; `Register64BelowRange` below, `Register64AboveRange` above;
   statically decided where provable (no handler / KNOWN-ERROR).
4. **Conversion back:** `abi::x86_64::to_int(r)` is the register contents
   read as signed 64-bit two's complement, an ordinary arbitrary-precision
   Int (statically a `Register64Word`); no errno interpretation.
5. **AST/HIR/NIR representation:** no special representation for Register64
   (an ordinary `nstruct`); the syscall is an ordinary native `call` node in
   AST and HIR (its struct argument an ordinary `struct` node); NIR has one
   new op, `syscall_linux_x86_64`, with seven Int operands and an Int result.
6. **Native physical representation:** one tagged 64-bit word in a register
   (an immediate for `|v| < 2^62`, a static constant for a literal, else a
   BigInt pointer), the struct erased by scalar replacement; a `StructObj`
   only at materialization frontiers.
7. **Source signature:** `linux::abi::syscall({rax: R, rdi: R, rsi: R, rdx:
   R, r10: R, r8: R, r9: R}) -> abi::x86_64::Register64`, R =
   `abi::x86_64::Register64`, fields optional except `rax`.
8. **Omitted argument registers:** absent from the struct; lowering passes
   the Int 0 for each.
9. **Unknown register fields:** `UNKNOWN-FIELD`, at the field's name, by
   hir/syscall.tcl, at compile time on every backend.
10. **Lowering on Linux x86-64:** fields in written order -> words ->
    `op syscall_linux_x86_64` in register order -> a Cranelift call of
    `rt_linux_x86_64_syscall` -> `botlish_linux_x86_64_syscall` -> `syscall`.
11. **Direct `syscall` or helper:** a helper (two Rust functions; the inner
    one is the asm `syscall`).
12. **Why:** Cranelift has no `syscall` instruction and no inline assembly;
    the helper executes the instruction itself (no libc), and translates the
    function convention into the kernel convention explicitly.
13. **Clobbers/effects/memory:** asm-declared rcx/r11 clobbers, flags not
    preserved, all memory read/written (no `nomem`/`readonly`/`pure`); a
    Cranelift call (all caller-saved registers clobbered, memory fence,
    never removed or merged), a GC safepoint; HIR: not context-free, in no
    folding/decision/equality allowlist.
14. **Interpreter:** intentionally rejects the call (`CORE SEMANTIC
    NATIVE-ONLY`), interp and compile alike; the pure conversions run there.
15. **The getpid example:** examples/linux/getpid.bot (above).
16. **39 is data:** it appears only as the source literal (`int 39` in NIR);
    no compiler or runtime file mentions it outside a Rust unit test's
    `const GETPID: i64 = 39`.
17. **pid tests:** positive and stable; equal to the driver process's pid
    in-process; equal to the child pid Tcl observes for a standalone
    executable, two runs two different pids.
18. **Backend evidence:** NIR op, CLIF helper call with stack map, objdump
    of the boundary (moves into rax/rdi/rsi/rdx/r10/r8/r9, one `syscall` in
    the whole binary, no `getpid` import), Rust unit tests against
    `std::process::id()`.
19. **Conversion boundary tests:** see Tests.
20. **Fuzz results:** see Fuzz results.
21. **Full regression:** see Regression.
22. **Obstacles discovered for `I32`, `Usize`, borrowed memory:** (the next
    milestone, ABI-NUMERIC-DOMAINS.md, resolved the first three: one
    nominally typed encoder per ABI type, `abi::x86_64::from_i32` ...
    `from_usize`; upper-half unsigned values encoded as `v - 2^64` with
    Register64 unchanged; `.value` instead of an `abi::to_int`; global
    `AbiI32Value`-style domain names and one `AbiInteger*Range` error pair)
    * *No overloading.* `register64` takes an Int; `register64(abi::I32)`
      needs a decision (separate conversion functions, or type-directed
      behaviour) -- deliberately left open. The same holds for a portable
      `abi::to_int`.
    * *Unsigned words.* `abi::Usize` values `>= 2^63` are legitimate register
      contents that `register64(Int)` (signed domain) rejects: a Usize ->
      Register64 conversion must be a separate, deliberately bit-pattern
      encoding (`2^64 - 1` -> word `-1`), and `to_int` would need an
      unsigned counterpart for results.
    * *Global type and error names.* Source-defined `type` declarations and
      `error` names are global and unqualified; `abi::I32` cannot be a
      namespaced `type` declaration today (only structs are namespaced), and
      every conversion needs globally unique error names. Namespacing them is
      a type-system change this milestone did not make.
    * *No private construction.* Register64 is sound without privacy because
      every word is a valid register. A borrowed-memory value (an address
      and a length) is not: arbitrary `{address, length}` construction would
      forge pointers. `abi::Bytes` needs a construction only trusted code
      can perform (an opaque/private type) -- the first real type-system
      requirement on this path.
    * *Byte storage.* Strings are immutable single allocations (a stable
      address for a read-only borrow under the non-moving collector); there
      is no mutable byte buffer (MutableArray slots are 8-byte Values), so
      `abi::MutableBytes` for `read` needs a new runtime object.
    * *GC across the transition.* The call is a safepoint and the collector
      is non-moving, so a borrowed object stays valid if it is kept live;
      operand registers are spilled as roots at the call today, which is
      what a borrow needs -- but the borrow's lifetime must become explicit.
    * *Int width.* Small Ints are 63-bit, so register words in `2^62..2^63`
      are BigInts in transit (no allocation for constants; an i64 word read
      and boxing are in the helper).
    * *Representation frontier.* A register struct bound to a variable and
      passed by name materializes (an inline literal does not; Register64
      locals and parameters do not); a future wrapper library should write
      the register literal inline, or the frontier should be removed first.
