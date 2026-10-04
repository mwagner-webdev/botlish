# A fixed-width register bytecode compiled from NIR: opcode inventory and 64-bit fit

This is an assessment, not an implementation. It asks which opcodes a
per-function register interpreter for Botlish would need, how each NIR
instruction maps onto them, and whether every one of them fits a 64-bit
instruction word. Nothing in the compiler or runtime was changed.

The premises, as given:

* **The VM is compiled from NIR, never from HIR.** It sits beside Cranelift as a
  second consumer of `native::lowered`'s output (DIRECT-HIR-NATIVE-PATH.md,
  "Readiness for NIR -> bytecode"; COROUTINE-PREREQUISITES.md section 7).
* **Every NIR function gets its own register set**, addressed as an offset from
  the frame pointer, with at most 256 registers. The premise allowed a first
  version to keep NIR's register numbers; section 8 shows why v1 compacts them
  instead.
* **Each instruction is 64 bits.** A 128-bit format is explored in section 9.
* **The mnemonics are x86-flavoured** (`mov`, `call`, `ret`, `add`, `shl`,
  `shr`, `mul`, `jmp`, `test`, `jge`, ...), but without implicit registers and
  without flags other than ZF and CF.
* **NIR's rich operations keep their `op NAME` syntax** (`op mutarrayset ...`),
  so they read differently from basic register instructions. Builtins are
  expected to shrink over time as ordinary Botlish code replaces them.
* **Superinstructions come later**, written `super NAME ...`. Here they matter
  only where they change the choice of basic opcodes (section 10).
* **Out of scope:** register allocation, a JIT, quickening.

---

## 1. Verdict

1. **The 64-bit word works.** An 8-bit opcode and 8-bit register fields encode
   every NIR instruction. Every fixed-arity instruction fits one word except
   `op syscall`, which names 8 registers (72 bits) and so takes two words.
2. **Variable-length operand lists fit one word up to 4 to 7 registers.** This
   covers calls, `tail`, multi-value `ret`, `op listnew`, `op closure`,
   `op structnew` and `op construct`. The register count is implied by the
   callee, the shape or the function for every list except `listnew`, `callv`
   and `construct`, so no count field is needed. Longer lists take a head word
   plus operand words of 8 registers each. That applies to 1.0% of corpus
   instructions and 0.50% of test-suite instructions.
3. **256 registers per function are enough, but NIR's register numbers are
   not.** The canonical corpus never needs more than 86 registers, so NIR's
   numbering would fit there. The test suite, however, lowers 116 functions with more
   than 256 NIR registers (up to 10,797), from generated stress functions and
   one 256-element literal. Apart from that literal, at most 124 registers are
   ever live at once. So a liveness-based renumbering fits every other function
   into 256 slots: the greedy coloring `codegen::roots` already runs for root
   slots. The literal's `op listnew` alone reads 256 registers, so it has to be
   split into chunks. v1 therefore compacts every function's registers and
   chunks oversized lists, rather than adding a wide-register encoding
   (section 8).
4. **The opcode space is ample.** The design needs 65 basic opcodes and 54 rich
   (`op`) opcodes, 119 of 256. That leaves 64 for superinstructions and about 70
   for growth, such as the coroutine suspension instructions
   COROUTINE-PREREQUISITES.md section 7 requires.
5. **A 128-bit word is not worth it.** It doubles the bytes (corpus: 68 KB
   against 34 KB). It also only moves the variadic threshold: a `listnew` of a
   few hundred elements still overflows it, so the operand-word escape is needed
   anyway. A 64-bit word with optional operand words already gives "128 bits
   when needed" to the 0.5–1% of instructions that need it (section 9).
6. **The ZF/CF flag model works, under four rules:**
   * Only compares, `test` and predicate `op`s write flags, and they always
     write both.
   * Arithmetic never writes flags.
   * CF means "below" in the comparing instruction's own order, which is signed
     for Ints.
   * Flags never live across a label, a call or a rich operation.

   NIR fits this naturally. 184 of the 193 Bool results that compares and
   predicates produce in the corpus are read only by the immediately following
   `br` (section 3.5).
7. **Selection rather than encoding decides the dispatch count.** After a few
   selection rules (constants folded into immediates, dead constants and
   jumps-to-next dropped, `br` turned into one jcc), the corpus needs 0.73 VM
   instructions per NIR instruction, or 0.68 once compare-and-branch is fused.
   The test suite needs 0.67 and 0.64. All of these rules are local; none is
   register allocation (section 11).

---

## 2. What it looks like

`fib` from `bench/fib.bot`. NIR, from `native::nir`:

```
func 1 "fib" params=1 env=0 regs=14 ... rawregs="0 2 4 6 7 8 10 11 12 13" rawparams="0" rawresult=1
    %1 = int 2
    %2 = rawint 2
    %3 = op rilt %0 %2
    br %3 L0 L1
  label L0
    %4 = move %0
    jump L2
  label L1
    %5 = int 1
    %6 = rawint 1
    %7 = op risub %0 %6
    %8 = call 1 %7
    %9 = int 2
    %10 = rawint 2
    %11 = op risub %0 %10
    %12 = call 1 %11
    %13 = op riadd %8 %12
    %4 = move %13
    jump L2
  label L2
    ret %4
end
```

VM. The examples keep NIR's register numbers so they can be read against the
NIR; v1 compacts them (section 8). The `r` prefix marks a raw-Int register:

```
f1 fib:                       ; params=1, frame=14, raw parameter 0, raw result
        cmp     r0, 2
        jge     .L1
        mov     r4, r0
        jmp     .L2
.L1:    add     r7, r0, -1    ; written `sub r7, r0, 1`
        call    r8, f1, r7
        add     r11, r0, -2
        call    r12, f1, r11
        add     r13, r8, r12
        mov     r4, r13       ; `jump L2` to the next label: nothing emitted
.L2:    ret     r4
```

That is 11 instructions where NIR has 18 (labels excluded). The three dead
tagged `int` literals are gone. The three `rawint` literals became immediates.
`rilt` + `br` became `cmp` + `jge`, and the last jump fell through.

`dot` from `examples/stdlib/matmul.bot` adds tagged Ints, a rich operation, a
self tail call, and a raw register that arrives tagged:

```
f1 dot:                       ; params=6; r3 is raw but its ABI position is tagged:
                              ; the call protocol unboxes it on entry (section 3.3)
        cmp     r3, r4
        jne     .L1
        ret     v5
.L1:    mov     v7, unit      ; dead; NIR's `if` join (only DCE of constants is assumed)
        box     v9, r3
        op listget v10, v0, v9
        op listget v11, v1, v9
        op listget v12, v11, v2
        mul     v13, v10, v12 ; Botlish Int: exact, BigInt on overflow
        add     r16, r3, 1    ; raw: proven not to overflow
        add     v17, v5, v13
        tail    v0, v1, v2, r16, r4, v17
```

The handler in matmul's program function. NIR's `pusherrorexit` and
`poperrorexit` become a handler table entry, not instructions:

```
f0 <program>:                 ; handlers: [entry, .A) -> .L0
        ...
        call    v32, f6, v15, v31
.A:     mov     v0, v32
        jmp     .L1
.L0:    cmp     err, 0x40000001     ; IndexNotFound (builtin error 1)
        jne     .L3
        clrerr
        op listnew v34
        mov     v0, v34
        jmp     .L1
.L3:    reraise                     ; no enclosing entry: the frame fails
.L1:    ret     v0
```

---

## 3. Machine model

### 3.1 Architectural state

The VM's architectural state is short, and none of it is an operand register:

* `pc`;
* the frame base `fp`;
* the running function, implied by the frame;
* `self`, the running closure, for an `env=1` function;
* the flags ZF and CF;
* the pending error. That is today's `Vm::error` and `Vm::declared_error`,
  whose id only `cmp err, ID` can read.

There is no accumulator, no instruction with an implicit operand, and no
addressable stack pointer: no `push`, no `pop`, no `rsp`. Frame records and
return addresses live in a separate control stack that no instruction can
address. COROUTINE-PREREQUISITES.md section 7 rule 2 requires exactly that:
register stacks must stay relocatable.

### 3.2 Registers and kinds

* A frame has `regs` slots of 64 bits at `fp + 8*r`. A register number is a
  byte.
* Each register has **one physical kind for the whole function**, taken from
  NIR's declarations:

  | prefix | kind | NIR | GC root |
  |---|---|---|---|
  | `v` | tagged Value (also plan registers, `planregs=`) | default | yes |
  | `r` | raw Int (signed i64, proven small) | `rawregs=` | no |
  | `s` | ShortString1 | `shortregs=` | no |
  | `a` | packed ASCII word | `asciiregs=` | no |

  The prefix is display only. The encoding carries just the number; the
  function's kind map says what it is. All four prefixes share one number
  space, the frame slot index, so `v3` and `r3` never both exist in one
  function. The disassembler separates prefix and number from the mnemonic by
  a space, as in `add v5, v3, v4`. In the assembler the prefix chooses the
  encoding of a shared mnemonic: `add v5, v3, v4` (Botlish Int) and
  `add r5, r3, r4` (machine word) are different opcodes. x86 does the same,
  where the register name picks the operand size (`add eax, ebx` against
  `add rax, rbx`). Mixing kinds is an assembly error, as it is a validation
  error in `nir.rs`.
* **GC roots.** The collector dereferences any word whose low three bits are
  zero, so it must never scan an `r`, `s` or `a` slot.
  * Each function has a static root bitmap: its `v` slots plus `self`.
  * A frame zeroes its `v` slots when it is pushed, so stale words from earlier
    frames are never scanned.
  * Every `v` slot of every frame is scanned. That over-retains dead values
    compared with native code's precise root slots, but is sound. Per-pc maps
    from `codegen::roots` could tighten it later.
* **A raw parameter at a tagged ABI position.** NIR can declare a parameter
  register raw while its ABI position stays tagged (in `rawregs=` but not
  `rawparams=`; `clif.rs` unboxes it in the prologue). The VM makes this part
  of the call protocol instead: the callee carries an *unbox-on-entry* mask,
  and the call handler shifts those arguments while copying them. Then there is
  no prologue code, and `tail` re-enters at pc 0 with values that are already
  raw (`nir.rs` checks that tail arguments have the parameter's kind).

### 3.3 Frames, calls and returns

* **Push.** A call pushes a frame record {function, call pc, caller `fp`,
  `self`} on the control stack. The callee's frame starts at `fp` plus the
  caller's frame size.
* **Arguments.** The call handler copies the argument words into the callee's
  registers `0..n-1`, applying the unbox-on-entry mask. No `mov` instructions
  are needed. Section 7 compares this with Lua-style argument windows.
* **Return.** The frame record stores the call's own pc. `ret` reads the
  destination register(s) from that call instruction, copies the result(s)
  there, and resumes after the call. The frame record therefore stores no
  destination.
* **Self tail call.** `tail` / `tailenv` performs a parallel copy of its
  arguments into `0..n-1`, rebinds `self` for `tailenv`, and jumps to pc 0. It
  is NIR's own back edge, and the only tail call NIR has.
* **Depth.** The depth check happens at push. Overflow is an ordinary,
  recoverable error, as COROUTINE-PREREQUISITES.md section 7 recommends.
* **Dynamic calls.** `callv` dispatches a closure *in the loop*: it checks
  arity and pushes a frame. A Native value goes to `invoke_native`. The VM never
  calls `rt_call_value`, which would re-enter Botlish code from a host frame
  (rule 1 of that section).
* **Discarded call-site flags.** NIR's per-call `may_error` and `may_gc` flags
  have no runtime role here: errors travel out of band (3.4) and every frame is
  scanned. The VM drops them.

### 3.4 Errors: a handler table, no status words

**Failing.** An instruction fails when:

* its helper returns `NO_VALUE`;
* a guard does not hold;
* it is `raise`, `fail`, `ud2` or `reraise`; or
* it is a call whose callee failed.

The pending error is recorded exactly as today.

**Handler lookup.** On failure the interpreter looks up the failing pc in the
function's handler table. Each entry maps a pc range `[start, end)` to a handler
pc, innermost first.

* If an entry covers the pc, execution continues at its handler.
* Otherwise the frame is popped and the lookup repeats at the caller's call pc.

**Why a table works.** NIR's `pusherrorexit` and `poperrorexit` are lexically
nested and purely static. `codegen::clif` keeps them as a compile-time stack,
and `nir.rs`'s plan-linearity check already computes the active handler per
instruction. So they become table entries, not instructions. The success path
costs nothing.

**What disappears:**

* The interpreter never stores `NO_VALUE` in a register.
* The (value, status) result pair of native code's failing raw, short and ascii
  functions (`clif.rs` `physical_results`) is not needed.

### 3.5 Flags

There are two flags, ZF and CF.

**Writers.** Only the instructions in this table write flags, and each writes
both:

| writer | ZF | CF |
|---|---|---|
| `cmp a, b` on `v` (Botlish Int, BigInt-exact) | a = b | a < b |
| `cmp a, b` on `r` (signed i64) | a = b | a < b |
| `cmp a, b` on `s` or `a` (word equality) | a = b | (meaningless; only `je`/`jne` are emitted) |
| `test a, b` on `v` (Bools) | not (a and b) | 0 |
| `cmp err, ID` | the pending declared error is ID | 0 |
| a predicate `op` (`op veq`, `op isok`, ...) | the predicate holds | 0 |

**Readers.** The condition codes are `je`/`jz`, `jne`/`jnz`, `jl`, `jge`,
`jle` and `jg`. They are read by the jcc instructions and by `set<cc>`.

| cc | condition |
|---|---|
| `e` | ZF |
| `ne` | not ZF |
| `l` | CF |
| `ge` | not CF |
| `le` | CF or ZF |
| `g` | not CF and not ZF |

**CF means "below in the compare's own order".** On x86, CF is unsigned borrow,
and signed order comes from SF≠OF. With only ZF and CF, signedness has to belong
to the comparing instruction instead of to the condition code. Every NIR
comparison is signed, because Botlish Ints are signed and NIR has no unsigned
compare. So the jumps that read CF are spelled `jl`/`jge`/`jle`/`jg`. If you
prefer x86's literal reading, `jb`/`jae`/`jc`/`jnc` can be assembler aliases of
the same encodings. An unsigned compare (`cmpu`) would be the way to get
unsigned order later; nothing needs it today.

**Polarity is x86's own.** As on x86, polarity differs between `cmp` (ZF =
equal) and `test` (ZF = the AND is zero, which here means false). So a Bool
branch reads `test v3, v3` / `jz .Lelse`, exactly the x86 idiom.

**Lifetime: flags are block-local and short-lived.** A writer's flags may be
read only by the run of consumers (`jcc`, `set<cc>`) that immediately follows
it in the same block. They are undefined after any other instruction and at
every label. This has three consequences:

* frames never save flags;
* calls and future suspension points never preserve them;
* fusing a writer with its consumer needs no liveness analysis.

NIR satisfies the rule without change. In the corpus, 184 of the 193 Bool
results of compares and predicates are read only by a `br`, and each of those
`br`s directly follows its producer. The other 9 feed a `ret`, a `move` or a
`listnew`; they use `set<cc>`.

### 3.6 x86 features deliberately left out

| x86 feature | VM | why |
|---|---|---|
| two-operand destructive forms (`add rax, rbx`) | three-operand, `add d, a, b` | NIR is three-address; two-operand forms would add a `mov` per operation. Intel's APX adds exactly such "new data destination" forms to x86-64. |
| arithmetic writes flags | it never does | APX's `{nf}` "no flags" variants address the same wart. Only compares, `test` and predicates write flags (3.5). |
| SF, OF, PF, AF; partial flag updates (`inc` keeps CF) | ZF and CF, both always written | signedness belongs to the compare |
| implicit registers: `mul`/`div` (rdx:rax), shift counts (cl), string ops (rsi/rdi/rcx), `loop`, `rep` | every operand explicit | |
| `push`/`pop`/`enter`/`leave`, an addressable `rsp` | frames managed by `call`/`ret` only | relocatable register stacks; frames the collector scans through a static bitmap |
| partial registers (`al`, `ax`, 32-bit zero-extension) | every register is one 64-bit word of one kind | |
| memory operands on any instruction, SIB addressing, `lea` | `mov` alone reads named spaces: `const[k]`, `static[k]`, `cap[k]`, struct field `[v + k]` | no instruction exposes an address (COROUTINE-PREREQUISITES.md section 7 rule 2) |
| `mul` (unsigned, widening) vs `imul` | one `mul`: signed, three-operand, same width | there is no unsigned or widening multiply in Botlish |
| `div`/`idiv` | none; `mod` (Euclidean) is explicit | NIR has no division |
| `inc`/`dec`, `neg`, `not` | `add d, a, ±1`; NIR has no negation or not | |
| `int n`, faults | `raise`, `fail`, `ud2`, `reraise` | |
| variable-length prefixed encoding | fixed 64-bit words (plus operand words for long lists) | |

What is kept: Intel operand order (destination first), `mov` for every data
movement, `cmp`/`test` + jcc, `set<cc>`, `ud2` for "cannot happen", and the
mnemonics themselves.

---

## 4. The instruction word

**Layout.** A little-endian `u64`. Byte 0 is the opcode. The bytes after it are
operand fields in assembly order, destination first. Immediates and indices sit
in the high bytes. A 32-bit index always occupies bytes 4–7, so it is one
aligned load.

**Length.** Every instruction's length follows from its head word alone:

* one word for every form except the `.x` forms;
* `1 + ceil(n/8)` words for an `.x` form, whose head word carries the count `n`.

That keeps disassembly, validation and a later superinstruction pass simple.

**Formats** (bytes after the opcode):

| format | layout | used by |
|---|---|---|
| `N` | — | `ud2`, `reraise`, `clrerr`, `nop` |
| `R1`..`R7` | 1–7 register bytes | `mov`, `box`/`unbox`, three-address arithmetic, `cmp`, `test`, `ret`, `tail`, most `op`s |
| `RI` | reg, imm48 (sign-extended) | `mov d, imm`, `cmp a, imm` |
| `RRI` | reg, reg, imm40 | `add d, a, imm`, shifts by an immediate |
| `RK` | reg, —, —, idx32 | `const[k]`, `static[k]`, `cap[k]`, `cmp err, ID`, `fail ID`, `raise` (kind byte, message index) |
| `RRK` | reg, reg, —, idx32 | struct field `[v + k]` |
| `J` | —, —, —, off32 (words, signed, from this instruction) | `jmp`, jcc |
| `CC` | reg, cc | `set<cc>` |
| `G` | reg, kind, —, ctx32 | `guard` |
| `C` | f16, then 5 registers: destinations, then arguments | `call` |
| `CE` | f16, k, then 4 registers | `callenv` |
| `CV` | d, c, n, then 4 registers | `callv` |
| `L` | d, n, then 5 registers | `op listnew` |
| `O` | d, id16, then 4 registers | `op closure` (function id), `op structnew` (shape) |
| `K` | d, mode/npieces, kindmask, then 4 registers | `op construct` |
| `.x` | count and 32-bit id in the head; operands in following words, 8 registers per word | the long form of every variadic |

---

## 5. Opcode inventory

There are three layers:

* **Basic instructions** are machine-like operations on words, Ints, flags and
  control.
* **Rich operations** (`op NAME`) are runtime-library operations on heap
  objects: today's builtins, implemented by the existing `ops.rs` helpers.
* **Superinstructions** (`super NAME`) are exact contractions of basic
  sequences (section 10).

`op` and `super` are assembly syntax. Every operation still gets its own primary
opcode, so a rich operation costs one dispatch, not two.

### 5.1 Data movement (8)

| VM | NIR | semantics | format |
|---|---|---|---|
| `mov d, s` | `move` | copy a word (same kind) | R2 |
| `mov d, imm` | `int`, `rawint`, `bool`, `unit`, `char`, `shortlit`, `asciilit` | load a pre-encoded word, sign-extended from 48 bits | RI |
| `mov d, const[k]` | `str`, a wide `int`, `native`, `fnvalue`, a 7–8 character `asciilit` | the program constant table (native's `Vm::consts`) | RK |
| `mov d, static[k]` | `staticget` | module-static slot | RK |
| `mov static[k], s` | `staticset` | | RK |
| `mov d, cap[k]` | `capture` | capture `k` of `self` | RK |
| `mov d, self` | `self` | the running closure | R1 |
| `mov d, [s + k]` | `structget` | field slot `k` of struct `s`; constant slot, no check (the shape is proven) | RRK |

**Immediates are written as values; the assembler encodes them by the
destination's kind.**

* `mov v3, 42` stores the tagged word 85.
* `mov r3, 42` stores 42.
* `mov v3, true` and `mov v3, unit` store 6 and 10; `mov v3, 'x'` stores the
  `UnicodeChar` word.
* `mov s3, 'x'` and `mov a3, "ab"` store ShortString1 and packed-ASCII words.

The 48-bit field holds:

* every tagged Int with |n| < 2^46;
* every `UnicodeChar` and ShortString1;
* packed-ASCII words of up to 6 characters;
* every raw Int below 2^47 in magnitude.

Anything wider goes to `const[k]`. Of the corpus's 866 `int`/`rawint`
literals, none is wider than 16 bits. In the test suite, 2,047 of 211,515 are
wider than the immediate field and use `const[k]`.

### 5.2 Representation transitions (2)

| VM | NIR | semantics |
|---|---|---|
| `box v, r` | `op rbox` | v = 2r + 1 (r proven small) |
| `unbox r, v` | `op runbox` | r = v >> 1, arithmetic (v proven a small Int) |

`box` is x86's `lea v, [r*2+1]`, and `unbox` is `sar r, v, 1`. They get their
own mnemonics so that every kind crossing is greppable. The ShortString1 and
packed-ASCII transitions allocate or decode strings, so they are rich
operations (5.7).

### 5.3 Arithmetic (20)

| VM | operands | NIR | semantics |
|---|---|---|---|
| `add`, `sub`, `mul` | `v, v, v` | `iadd`, `isub`, `imul` | exact Botlish Int. Inline fast path when both operands are small and the word operation does not overflow (as `clif.rs` `int_arith` does); otherwise `rt_int_*`, which may allocate a BigInt (a GC safepoint). Never fails. |
| `add` | `v, v, imm` | `iadd` or `isub` with a constant | the same, with the immediate stored as 2k so it adds directly to a tagged word |
| `mod` | `v, v, v` | `imod` | Euclidean, 0 ≤ r < \|b\|; ARITHMETIC on zero |
| `and`, `or`, `xor` | `v, v, v` | `iand`, `ior`, `ixor` | two's complement, exact; tagged-word fast path (`clif.rs` `int_bitop`) |
| `shl`, `sar` | `v, v, v` | `ishl`, `ishr` | exact; RANGE on an invalid shift amount; may allocate |
| `add`, `sub`, `mul` | `r, r, r` | `riadd`, `risub`, `rimul` | two's-complement i64. NIR's range proofs rule out overflow; on overflow the result is unspecified, and a debug build may trap. |
| `add` | `r, r, imm` | `riadd` or `risub` with a constant | |
| `shl`, `sar`, `shr` | `r, r, r` and `r, r, imm` | `rishl`; `rishr` → `sar` | x86 semantics. `shr` is the logical shift. NIR emits `rishr` only for a proven non-negative operand, where `shr` and `sar` agree, so `shr` has no NIR source today. It is kept for future intrinsics (bit manipulation on raw words). |

Two encoding notes:

* `sub d, a, imm` is accepted and assembled as `add d, a, -imm`. That saves two
  opcodes; the disassembler prints `add`.
* Botlish's `shift_right` is arithmetic, so the Int shift is honestly `sar`.
  `shr` exists only for raw words.

Not included, because NIR has no source for them: raw `mod`/`and`/`or`/`xor`,
`v` immediates for anything other than `add`, `neg`, `not`, `div`. Each is one
opcode away if a producer appears.

### 5.4 Compare, test, flags and branches (14)

| VM | NIR | notes |
|---|---|---|
| `cmp v, v` | `ilt`, `ile`, `igt`, `ige`, `ieq` | both small: compare the words (tagging preserves order); otherwise `rt_int_cmp`. Never fails or allocates. |
| `cmp v, imm` | the same with a constant | immediate stored tagged |
| `cmp r, r` | `rilt`, `rile`, `rigt`, `rige`, `rieq`; also `shorteq` (`s`) and `asciieq` (`a`) | signed word compare; ShortString1 and packed ASCII are canonical, so word equality is String equality |
| `cmp r, imm` | the same with a constant (`cmp s3, 'a'`) | |
| `test v, v` | `br` on a Bool register | ZF = not (a and b); with TRUE = 6 and FALSE = 2 that is `(a & b & 4) == 0` |
| `cmp err, ID` | `declarederroreq` | |
| `set<cc> v` | a compare or predicate result needed as a value | v = TRUE/FALSE; one opcode with a cc field |
| `jmp L` | `jump` | x86 spelling; NIR spells it `jump` |
| `je`, `jne`, `jl`, `jge`, `jle`, `jg` | `br` | six opcodes rather than one with a cc field, so threaded dispatch keeps one branch site per condition |

How `br` is selected:

* **Fall-through.** NIR always emits `br %c Lthen Lelse` immediately followed by
  `label Lthen` (306 of 306 in the corpus). So a `br` becomes one inverted jcc
  to `Lelse` and falls through.
* **Compare or predicate condition.** When `%c` comes from the directly
  preceding compare or predicate, that instruction writes the flags and `%c` is
  never materialized.
* **Any other Bool.** A Bool from a join `move`, a call or a parameter (73 of 306
  in the corpus) becomes `test v, v` / `jz`.
* **Jump to the next label.** A `jump` to the label that comes next is not
  emitted (317 of 512 jumps in the corpus).

### 5.5 Calls and returns (13)

| VM | NIR | inline limit |
|---|---|---|
| `call d, fN, args...` and `call (d0, d1, ...), fN, args...` | `call`, `callmulti` | destinations (the callee's `results=`) plus arguments (its `params=`) ≤ 5; function id < 65,536 |
| `call.x` | the same, longer | 32-bit function id; operand words |
| `callenv d, fN, k, args...` (also multi) | `callenv`, `callenvmulti` | ≤ 4 after the closure register `k` |
| `callenv.x` | | |
| `callv d, c, args...` | `callvalue` | ≤ 4; explicit count, since the arity is dynamic and checked (ARITY) |
| `callv.x` | | |
| `tail args...` | `tail` | ≤ 7 (the count is the function's `params=`) |
| `tail.x` | | |
| `tailenv k, args...` | `tailenv` | ≤ 6 |
| `tailenv.x` | | |
| `ret v` | `ret` | |
| `ret v0, v1, ...` | `retmulti` | ≤ 7 (the function's `results=`) |
| `ret.x` | | |

Single- and multi-result calls share one opcode because the callee's `results=`
says how many leading registers are destinations. A `planresult=1` function
reached through `callv` materializes its result on return, as native's generic
entry does.

### 5.6 Errors and guards (7)

| VM | NIR | semantics |
|---|---|---|
| `guard KIND, v, "ctx"` | `guard` | TYPE error with the context string unless `v` has kind KIND (12 kinds: a 4-bit field) |
| `guard bool, v` | `guardbool` | NOT-BOOLEAN unless `v` is a Bool |
| `raise KIND, "msg"` | `raise` | KIND indexes `SEMANTIC_KINDS` (error.rs); the message is a constant |
| `fail NAME` | `faildeclared` | 32-bit declared error id (builtins at 0x40000000 + i); the name comes from the program's error table |
| `ud2` | `unreachable` | BUG error naming the running function |
| `reraise` | `reraise` | fails with the pending error unchanged; the handler lookup at its own pc finds the outer entry, because NIR emits it after `poperrorexit` |
| `clrerr` | `cleardeclarederror` | |

`cmp err, ID` (5.4) is the eighth error-related instruction. The `guard` +
`op` pairs (`guard mutarray` + `op mutarrayset` is the most frequent) are
superinstruction candidates, not a reason to fold guards into rich operations.

### 5.7 Rich operations: `op` (54)

Legend:

* **P**: a predicate. It writes ZF and has no destination; `set<cc>`
  materializes the result if needed.
* **F**: may fail.
* **A**: may allocate, so it is a GC safepoint. The F and A columns follow
  `op_may_error` and `op_may_allocate` in `ops.rs` and what `clif.rs` checks.

The interpreter checks every helper's result for `NO_VALUE` anyway. That check
costs one compare, so a static "cannot fail" classification never matters for
correctness.

| `op` | operands → result | P | F | A | NIR |
|---|---|---|---|---|---|
| `strlen` | v ← str | | | | `strlen` |
| `substr` | v ← str, i, j | | F | A | `substr` |
| `strlower` | v ← str | | F¹ | A | `strlower` |
| `strcat` | v ← str, str | | F | A | `strcat` |
| `strbytelen` | v ← str | | | | `strbytelen` |
| `strutf8bytes` | v ← str | | F | A | `strutf8bytes` |
| `decodecharat` | v ← str, byte offset | | | A | `decodecharat` |
| `streq` | str, str | P | | | `streq` |
| `regioncheck` | v ← base, i, j | | F | | `regioncheck` |
| `regioneq` | base, i, j, str (4 registers) | P | | | `regioneq` |
| `strtclalpha`, `strtclalnum` | str | P | F | | `strtclalpha`, `strtclalnum` |
| `strregiontclalpha`, `strregiontclalnum` | base, i, j | P | F | | the region forms |
| `strtoshort` | s ← str | | | | `strtoshort` |
| `shorttostr` | v ← s | | | A | `shorttostr` |
| `shortlen` | r ← s | | | | `shortlen` |
| `strsliceshort` | s ← base, i, j | | | | `strsliceshort` |
| `strtoascii` | a ← str | | | | `strtoascii` |
| `asciitostr` | v ← a | | | A | `asciitostr` |
| `asciilen` | r ← a | | | | `asciilen` |
| `asciitoshort` | s ← a | | | | `asciitoshort` |
| `asciishorteq` | a, s | P | | | `asciishorteq` |
| `listnew`, `listnew.x` | v ← n elements (count explicit; ≤ 5 inline) | | F | A | `listnew` |
| `listlen` | v ← list | | | | `listlen` |
| `listget` | v ← list, i | | F | | `listget` (inline fast path as in `clif.rs` `list_get`) |
| `listappend` | v ← list, x | | F | A | `listappend` |
| `setfromlist` | v ← list | | F | A | `setfromlist` and `setfromlisttotal` |
| `setcontains` | set, x | P | F | | `setcontains` and `setcontainstotal` |
| `mutarrayallocate` | v ← n | | F | A | |
| `mutarraycapacity` | v ← m | | | | |
| `mutarrayget` | v ← m, i | | F | | |
| `mutarrayset` | v ← m, i, x | | F | | |
| `mutarraycopy` | v ← dst, i, src, j, n (6 registers) | | F | | |
| `mutarrayfreeze` | v ← m, n | | F | A | |
| `veq` | x, y | P | F | | `veq` (EQUALITY on callables) |
| `hash` | v ← x | | F | | `hash` |
| `is KIND` | x | P | | | `isint`, `isstr`, `islist`, `ismutarray` (one opcode, kind field) |
| `isok`, `iserror` | x | P | | | `isok`, `iserror` |
| `resultvalue`, `resulterror` | v ← result | | F | | |
| `mkok`, `mkerror` | v ← x | | | A | |
| `charcodepoint` | v ← char | | | | `charcodepoint` |
| `closure`, `closure.x` | v ← fN, captures (count is fN's `captures=`; ≤ 4 inline) | | | A | `closure` |
| `structnew`, `structnew.x` | v ← shape, fields (count from the shape; ≤ 4 inline) | | | A | `structnew` |
| `construct`, `construct.x` | v ← str/list, flat/plan, pieces (a kind bit per piece; ≤ 4 registers inline) | | F | A | `construct` |
| `argv` | v ← | | F | A | `argv` |
| `syscall` | v ← nr, a1..a6 (8 registers: always 2 words) | | F | A | `syscall_linux_x86_64` |

¹ `clif.rs` checks `strlower`'s result for the collection-length ceiling;
`op_may_error` does not list it. The VM checks it either way.

The `*total` variants differ from their generic forms only in `op_may_error`,
which feeds effect analysis. They call the same helper (`ops.rs` `apply_op`),
so each pair is one VM opcode.

**Why these are rich operations.** These are the builtins that are meant to
shrink. Keeping them in their own opcode block (5.9) means that retiring one
renumbers nothing in the basic ISA. Some, such as `listget`, `mutarrayget`,
`mutarrayset`, `listlen`, `strlen` and the allocators, are likely to remain as
primitives once Botlish code replaces the rest, and could then move into the
basic layer. Moving one is only a mnemonic change, never an encoding change.

### 5.8 NIR that becomes metadata, not instructions

| NIR | VM |
|---|---|
| `label` | resolved branch offsets |
| `pusherrorexit` / `poperrorexit` | handler table entries (3.4) |
| `@ExprId` origins | a pc → origin table, for allocation-site attribution (`Vm::alloc_site`) and diagnostics |
| `func` header: `params`, `env`, `regs`, `captures`, `results`, `pnames`, the kind lists, `planresult`, `instance` | function table, root bitmap, unbox-on-entry mask |
| `native` declarations | constant table entries plus the native table that `callv` and `invoke_native` use |
| `shape` declarations | the shape table |
| `statics=N` | the size of the static table |
| per-call `may_error`/`may_gc`; the `*total` split | dropped (3.3, 5.7) |

All 42 `Inst` variants and all 80 `OpCode`s of `nir.rs` are accounted for in
5.1–5.8.

### 5.9 Opcode budget

| block | opcodes |
|---|---:|
| data movement | 8 |
| representation | 2 |
| arithmetic | 20 |
| compare, test, flags, branches | 14 |
| calls and returns | 13 |
| errors and guards | 7 |
| `nop` | 1 |
| **basic** | **65** |
| **rich (`op`)** | **54** |
| superinstructions (`super`), reserved | 64 |
| free | 73 |

A numbering that keeps the layers apart: `0x00–0x5F` basic (96 slots),
`0x60–0xBF` rich (96 slots), `0xC0–0xFF` super. The future coroutine
instructions (`yield`, `resume`; COROUTINE-PREREQUISITES.md section 7 rule 3
says they must be real instructions, not helpers) belong in the basic block.

---

## 6. Does each instruction fit in 64 bits?

| instruction shape | bits needed | fits |
|---|---:|---|
| three-address ALU, `cmp`, `test`, `box`, `mov` | 32 | yes |
| register plus 48-bit immediate | 64 | yes |
| two registers plus 40-bit immediate | 64 | yes |
| constant, static, capture or error index (32 bits) | 64 | yes: 2^32 entries |
| `jmp` / jcc (32-bit word offset) | 64 | yes: ±2^31 words. Corpus maximum distance 75 instructions, 327 in the test suite |
| `guard` (register, kind, 32-bit context index) | 64 | yes |
| `op regioneq` (4 registers, no destination) | 40 | yes |
| `op mutarraycopy` (destination + 5) | 56 | yes |
| `op syscall` (destination + 7) | 72 | **no**: always a head word plus one operand word |
| `call`: f16 + (results + params) registers | 24 + 8n | for n ≤ 5. Corpus: 290 of 306 calls have ≤ 4 arguments |
| `callenv`: f16 + closure + n | 32 + 8n | for n ≤ 4 |
| `callv`: destination, callee, count + n | 32 + 8n | for n ≤ 4 |
| `tail` / multi-value `ret`: n | 8 + 8n | for n ≤ 7 |
| `op listnew`: destination, count + n | 24 + 8n | for n ≤ 5 |
| `op closure` / `op structnew`: destination, id16 + n | 32 + 8n | for n ≤ 4 |
| `op construct`: destination, mode/count, kind mask + n | 32 + 8n | for n ≤ 4 registers |

Measured with these limits (section 12 has the method):

| | corpus | test suite |
|---|---:|---:|
| VM instructions after selection | 4,245 | 518,720 |
| needing operand words | 41 (1.0%) | 2,611 (0.50%) |
| … of which `call` / `callmulti` / `tail` / `listnew` / `structnew` / `construct` / `ret` / `syscall` | 16 / 14 / 2 / 8 / 0 / 1 / 0 / 0 | 816 / 787 / 92 / 767 / 56 / 51 / 7 / 35 |
| 64-bit words in total | 4,294 (34,352 bytes) | 522,239 (4,177,912 bytes) |

The function id gets 16 bits inline. The largest id in either set is
59, and `call.x` carries 32 bits for programs past 65,536 functions.
Shape ids (16 bits inline), constant indices (32), static slots (32), capture
indices (32) and declared-error ids (31 bits used) all have room to spare.

---

## 7. Variable operand lists: operand words, not argument windows

COROUTINE-PREREQUISITES.md section 7 suggested Lua's argument-window
convention: arguments in consecutive registers at the top of the caller's frame,
which then becomes the base of the callee's frame. Without a register
allocator, that is the wrong trade.

| | operand words (recommended) | argument windows | side tables |
|---|---|---|---|
| encoding | head word, then 8 registers per extra word | `call d, fN, base`: always one word | `call d, fN, list#`: always one word |
| with NIR register numbering | arguments stay where NIR put them | the VM compiler must `mov` every argument into the window: **one extra dispatch per argument** | arguments stay |
| work in the call handler | n register copies (needed anyway to fill the callee frame) | none | n copies, plus one indirection to a separate table |
| needs a register allocator to be cheap | no | yes: only targeting values into the window removes the `mov`s | no |
| instruction stream | not strictly uniform (rare `.x` forms) | uniform | uniform, operands elsewhere |

With NIR numbering a window adds one `mov` per argument. The corpus's 374 calls
pass 784 arguments (mean 2.1), so that is 784 extra instructions on top of
3,459, or +23%. Operand words add one load per 8 arguments inside a dispatch
that happens anyway, and only for the 0.5–1% of instructions that need them.
Copying also fits coroutines, which will exist by the time the VM is built.
Each coroutine has its own register stack (COROUTINE-PREREQUISITES.md
section 7), so starting or resuming one passes values into a *different*
stack. A window requires the callee frame to sit directly above the caller's
in the same stack, which cannot hold across that boundary. Copying works the
same within one stack and across two, so calls and coroutine transfers share
one argument protocol.

Windows would only become attractive once an allocator places values directly
into the window. A `call.w d, fN, base` form could then be added beside `call`
for same-stack calls without changing anything else.

---

## 8. The 256-register limit

The question here is whether NIR's own numbering fits 256 registers:

| | corpus | test suite |
|---|---:|---:|
| functions | 237 | 22,654 |
| NIR registers per function: median / p99 / max | 14 / 64 / 86 | 11 / 114 / 10,797 |
| functions with more than 256 NIR registers | 0 | 116 |
| largest simultaneously live register set | 22 | 258 (the 256-element literal); 124 otherwise |
| slots after greedy interference coloring (kinds kept apart) | max 20 | 257 (the literal); 122 otherwise |

**NIR's numbering.** NIR assigns one register per value, never reusing one, so
its register count grows with function length, not with live values. The
functions above 256 are:

* generated stress functions: the tiny-leaf inlining pressure tests' `caller`
  (up to 7,682 registers) and long straight-line `f` functions in the
  csv-records, hashtable and mutable-array tests (up to 10,797);
* a program of many syscall and ABI checks (386);
* the byte and ASCII tests' 256-element literal (545).

Apart from the literal, the live set stays small. The 10,797-register function
never has more than 5 values live, because each value dies right after its one
use.

**Decision for v1: compact every function.** NIR numbers would fit 256 slots
for every corpus function and 99.5% of test-suite functions, but compaction is
applied universally, not only above 256:

* **What it is.** Registers are renumbered by liveness. This is the
  interference coloring that `codegen::roots` already performs for shadow
  slots: Cranelift-free, already tested, but kept in the binary's `codegen`
  module rather than the library (COROUTINE-PREREQUISITES.md section 7 notes
  the same).
  * It keeps each slot's kind fixed by coloring tagged and scalar registers
    separately, so root bitmaps stay static.
  * Parameters stay at `0..params-1`.
  * It is renumbering, not register allocation: no spilling, no splitting, no
    coalescing.
* **Why everywhere.** It saves memory: the mean frame shrinks from 16.1 to 5.8
  slots in the corpus (11.0 to 4.0 median in the test suite). Every coroutine
  keeps a register stack, so smaller frames make coroutines cheaper to create
  and to keep suspended. It also means a single register-numbering path, and
  fewer stale values for the collector to retain and scan.
* **Speed.** The effect on speed is probably small. Calls zero fewer slots,
  but that is a few stores per call against the call's other costs (11).
* **Debugging.** The disassembler cannot show NIR's numbers any more. A
  per-function slot → NIR register map in the debug side tables (beside the
  pc → origin table, 5.8) restores them.

**The one case compaction cannot fix** is an instruction that by itself reads
more live registers than fit. The test suite has one such program: the literal
`[0, 1, ..., 255]`, whose `op listnew` reads 256 element registers at once and
so needs 257 slots even after coloring. Byte and lookup tables of that size are
ordinary code, so this needs a rule, not an encoding.

* **The rule:** split a `listnew` (or `construct`) of more than about 200
  operands into chunks. Build each chunk with `op listnew` as soon as its last
  element is defined, then join the chunks with one `op construct list flat`
  of `span` pieces.
* **Why it is safe:** the elements are already-evaluated values, so building a
  chunk early is unobservable, except that allocation reports count the
  intermediate Lists.
* **Where it belongs:** the VM compiler can find the chunk points when the
  elements are straight-line definitions (this literal is 256 `int`s).
  `native/lower.tcl` can do it in general, because it still knows the literal's
  structure. The resulting NIR is valid for Cranelift too.

Rejected alternatives:

* **A wide-register prefix word**, x86's REX idea: a prefix that supplies the
  high bits of each register field of the next instruction. It works, but it
  puts a mode into every handler's decode path for a case compaction removes.
* **A spill area** reached by `mov d, frame[k]`: needs scratch registers and
  extra `mov`s.

---

## 9. The 128-bit format, explored

A 128-bit word could be laid out as a 16-bit opcode with fourteen 8-bit
register fields, or as a 16-bit opcode with three 16-bit register fields and a
64-bit immediate.

What it buys:

* **Fewer operand words.** The second slot is needed only for lists of more than
  11–14 registers: 4 corpus instructions and 320 in the test suite, almost all
  `listnew`.
* **No 256-register question** with 16-bit fields.
* **Full 64-bit immediates**, so no constant entries for wide scalars.
* **A 16-bit opcode space** for superinstructions.

What it costs:

* **Twice the bytecode.** The corpus needs 67,984 bytes against 34,352
  (8.3 MB against 4.2 MB for the test suite). That doubles the data cache
  footprint of hot loops; the instruction cache is unaffected, since
  bytecode is data. Every instruction but the variadic overflows uses at most
  64 of the 128 bits (section 6).
* **Variadics still overflow.** A `listnew` of a few hundred elements, a
  `syscall` with 16-bit registers, or a long `tail` overflows 128 bits too, so
  the escape mechanism remains.
* **Decode is not faster.** Fields are still extracted by shift and mask; a
  16-byte fetch is two loads or one vector load.

Each 128-bit benefit has a cheaper 64-bit answer:

| 128-bit benefit | 64-bit answer |
|---|---|
| fewer operand words | operand words for the 0.5–1% that need them |
| 16-bit registers | compaction (8) |
| 64-bit immediates | `const[k]`; no literal in the corpus needs more than 16 bits |
| superinstruction space | 64 reserved opcodes, plus 73 free (10) |

**Recommendation:** 64-bit words. The format is in effect "64 bits, 128 when
needed", because a head word plus one operand word *is* a 128-bit instruction,
paid only by the instructions that need it.

---

## 10. Superinstructions: what they change now

A superinstruction is an exact contraction of a sequence of basic instructions:
the same results, the same flags written, and errors at the same component
with the same handler. It is written `super NAME operands` and lives in the
reserved opcode block.

Six decisions in the basic set exist because of them:

1. **Three-operand forms in the base.** With two-operand x86 forms, `mov` +
   arithmetic would be the most common pair to fuse. Three-address forms make
   that pair disappear instead of needing a superinstruction.
2. **Register–immediate forms in the base** for `mov`, `add`, `cmp` and raw
   shifts. Constants are 27% of NIR instructions in the corpus (1,273 of
   4,716). Folding them at selection time removes the next most common pair
   (`mov $k` + use), so no superinstruction slots are spent on it.
3. **`cmp` and jcc stay separate in the base.** Compare-and-branch
   (`super cmp.jl a, b, L`: opcode, two registers, a 40-bit offset) is the first
   superinstruction to add. It covers 233 jcc in the corpus, every one directly
   after its flag writer. Putting it in the base would multiply opcodes by the
   six condition codes and turn flags into a special case.
4. **Flag lifetime is block-local and adjacent** (3.5). So fusion needs no
   analysis, and a fused form simply also writes the flags.
5. **The handler region is per pc** (3.4). So fusion is legal inside one block
   and one handler range, and an error inside a fused instruction is attributed
   to its component through the origin table.
6. **The instruction length is derivable from the head word**, so a fusion pass
   can walk the instruction stream.

**64 bits holds the useful fusions.** Adjacent pairs in the corpus point
to `cmp`/predicate + jcc (233), `mov` + `jmp` (the `if` join: 190 of the
195 remaining jumps follow a `mov`), `call` + `ret` (48), `guard` +
`op mutarray*` (37) and `call` + `guard` (31). A loop latch
`add r, r, imm; cmp r, r; jl L` still fits: opcode, three registers, an 8-bit
immediate and a 24-bit offset. That is another reason the 128-bit format is unnecessary.

---

## 11. Interpreter efficiency notes

These are static counts. No interpreter exists, so nothing dynamic was
measured.

| | NIR | VM |
|---|---:|---:|
| corpus (17 programs), instructions excluding labels | 4,716 | 3,459 (0.73) |
| … with `cmp`/predicate + jcc fused | | 3,226 (0.68) |
| test suite (4,510 distinct programs) | 626,639 | 417,873 (0.67) |
| … with `cmp`/predicate + jcc fused | | 400,306 (0.64) |

Where the reduction comes from, in the corpus:

| cause | instructions |
|---|---:|
| dead constant definitions dropped (NIR emits an `int`/`rawint` pair per literal; 355 of 438 `rawint` are dead) | 441 |
| constants folded into a `mov d, imm` that replaces a `move` | 338 |
| constants folded into a register–immediate operand | 204 |
| `jump` to the next label | 317 |
| `pusherrorexit` / `poperrorexit` moved into the handler table | 30 |

What adds instructions: a `br` on a Bool register becomes `test` + jcc (73), and
a `br` whose neither target falls through would need an extra `jmp` (none in
the corpus).

Per-instruction cost:

* **Decode** is one aligned 64-bit load plus shifts. A register operand is one
  scaled-index load (`[fp + r*8]`).
* **Flags** are a local of the dispatch loop, so they stay in a host register.
  They are never stored to a frame (3.5).
* **Tagged Int arithmetic and comparison** keep `clif.rs`'s inline fast paths:
  both-small test, word operation, overflow check. The `rt_int_*` helpers run
  only for BigInts.
* **Errors** cost nothing on the success path: the handler table is consulted
  only on failure.
* **Calls** cost the argument copies plus zeroing the callee's `v` slots.
  Zeroing is proportional to the frame size: 16.1 slots on average with NIR
  numbering, 5.8 after compaction (8). That is a few stores per call, so its
  speed effect is probably small; compaction is chosen mainly for memory.
  Per-pc root maps could remove the zeroing altogether.
* **Bytecode size** is 34 KB for the whole corpus, far inside L2, and its hot
  loops fit L1.

---

## 12. Method

**NIR sources**, all from the current tree through the production entry point
`native::nir`:

* the 17 canonical programs (`bench/*.bot` and `examples/stdlib/*.bot`, read
  with `surface::readProgramFile`);
* every program the test suite lowers. These were captured with a temporary,
  uncommitted hook in `native::lowered` that wrote each NIR text to a file,
  while `CORE_BACKEND=compile tclsh9.0 tests/all.tcl` ran:
  9,333 captures, 4,510 distinct.

**Selection rules counted** (sections 5 and 11):

* drop pure constant definitions with no use;
* fold a constant whose only uses are as the constant operand of
  `iadd`/`isub`/`riadd`/`risub`/`rishl`/`rishr` or a compare, or whose single
  use is a `move`;
* drop a `jump` to the next label;
* a `br` becomes one jcc after an adjacent single-use compare or predicate, or
  `test` + jcc otherwise.

**Fit** applies the inline limits of section 6, with counts implied by
`params=`/`results=`/`captures=`/shape where section 5 says so.

**Liveness** is backward dataflow over NIR's CFG: labels, `br`/`jump`, self
`tail` back edges to entry, and an edge from every instruction inside a
`pusherrorexit` span to its handler. The "largest live set" is the maximum,
over instructions, of live-in ∪ defs ∪ live-out. Coloring is greedy in register
order, tagged and scalar kinds separately, parameters fixed.

The scripts were throwaway Python over the NIR text and are not committed.

---

## 13. Decisions

Settled after review of the first version of this document:

1. **Register prefixes stay.** `v`/`r`/`s`/`a` share one slot-number space and
   pick the encoding of a shared mnemonic (`add v5, v3, v4` vs
   `add r5, r3, r4`). No suffixed mnemonics (3.2).
2. **CF means "below in the compare's own order"**, and the jumps that read it
   are `jl`/`jge`/`jle`/`jg`. Signedness belongs to the compare, not to the
   condition code; an unsigned `cmpu` is the extension point if one is ever
   needed (3.5).
3. **Predicates write ZF, not a Bool register.** This is the canonical design
   throughout (3.5, 5.4, 5.7). `set<cc>` materializes a Bool for the roughly 5%
   of predicate results that are used as values.
4. **Operand words, not argument windows**, from v1 on (7). Coroutines will
   exist when the VM is built, and copying is the one argument protocol that
   works both within a register stack and across two. This revises
   COROUTINE-PREREQUISITES.md section 7's suggestion.
5. **Liveness compaction for every function** in v1, mainly to save memory
   (8). It also handles the functions above 256 NIR registers; oversized
   `listnew`/`construct` operand lists are chunked.
6. **`shr` stays** for future intrinsics, although NIR has no source for it
   today (`rishr` maps to `sar`) (5.3).
7. **Opcode blocks** `0x00–0x5F` basic, `0x60–0xBF` rich, `0xC0–0xFF` super,
   so retiring builtins never renumbers the basic ISA (5.9).
