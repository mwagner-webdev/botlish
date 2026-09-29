//! NIR: the backend-neutral native IR produced by native/lower.tcl.
//!
//! See native/lower.tcl for the format. This module parses and validates it;
//! it knows nothing about Cranelift.

use crate::runtime::value::Kind;
use std::collections::HashSet;
use std::fmt;
use crate::runtime::ops::{op_may_allocate, op_may_error};

pub type Reg = u32;
pub type Label = u32;
pub type FuncId = u32;

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum OpCode {
    IAdd,
    ISub,
    IMul,
    /// Euclidean modulo (core/primitives.tcl's modulo): 0 <= result < |b|.
    IMod,
    /// Bitwise AND/OR/XOR, two's-complement, total over every Int (never
    /// fails): core/scalarbits.tcl's `bit_and`/`bit_or`/`bit_xor`.
    IAnd,
    IOr,
    IXor,
    /// A << K / A >> K (K a nonnegative Int shift amount; RANGE if not):
    /// core/scalarbits.tcl's `shift_left`/`shift_right`.
    IShl,
    IShr,
    ILt,
    ILe,
    IGt,
    IGe,
    IEq,
    VEq,
    StrEq,
    ListNew,
    StrLen,
    Substr,
    StrLower,
    StrCat,
    ListLen,
    ListGet,
    ListAppend,
    /// List -> ImmutableSet, deduplicating by VEq's own rule (MINIMAL-
    /// IMMUTABLE-SET.md's `immutable_set_from_list`): O(n^2), the
    /// deliberately simple first representation -- no inline fast path
    /// (item 64), always a helper call (ops.rs's `rt_set_from_list`).
    SetFromList,
    /// SetFromList, at a call site native/lower.tcl's `NativeCallOp`
    /// (`equality-list`) has statically proven equality-total: the source
    /// List's own static element type is one of
    /// `hir::types::IsEqualityTotal`'s kinds (Int and every source-defined
    /// bounded-integer domain over it, Str, Bool, Unit, UnicodeChar), so
    /// every comparison this invocation's own dedup pass can ever perform
    /// is necessarily T x T for an equality-total T -- the runtime operands
    /// can never include a Block/Native/MutArray value, the only way
    /// `rt_set_from_list`'s own equality can raise EQUALITY (see ops.rs's
    /// `equal`). Same runtime helper (`rt_set_from_list`, unmodified) and
    /// same allocation behavior as `SetFromList`: this is purely an
    /// `op_may_error` classification split, not a new runtime operation
    /// (M4-EQUALITY-TOTAL-SETFROMLIST-EFFECT.md). Generic `SetFromList`
    /// itself remains unconditionally `may_error` -- this sibling opcode is
    /// only ever emitted for one particular, statically-proven call site,
    /// never for `immutable_set_from_list`'s own generic/dynamically-
    /// dispatched entry (native/lower.tcl's `NativeImpl`).
    SetFromListTotal,
    /// Total membership on an ImmutableSet operand (`immutable_set_contains`):
    /// false for an absent value, never an Error completion. Always a
    /// helper call (`rt_set_contains`), like SetFromList.
    SetContains,
    /// SetContains, at a call site native/lower.tcl's `NativeCallOp`
    /// (`equality-set`) has statically proven equality-total: the set's own
    /// applied element type and the needle's own static type are both one
    /// of `hir::types::IsEqualityTotal`'s kinds (Int and every source-
    /// defined bounded-integer domain over it, Str, Bool, Unit,
    /// UnicodeChar), so the runtime operands this specific invocation can
    /// ever pass to `rt_set_contains` can never include a Block/Native/
    /// MutArray value -- the only way that helper's own equality can raise
    /// EQUALITY (see ops.rs's `equal`). Same runtime helper
    /// (`rt_set_contains`, unmodified) as `SetContains`: this is purely an
    /// `op_may_error` classification split, not a new runtime operation
    /// (M3-EQUALITY-TOTAL-SETCONTAINS-EFFECT.md). Generic `SetContains`
    /// itself remains unconditionally `may_error` -- this sibling opcode is
    /// only ever emitted for one particular, statically-proven call site,
    /// never for `immutable_set_contains`'s own generic/dynamically-
    /// dispatched entry (native/lower.tcl's `NativeImpl`).
    SetContainsTotal,
    MutArrayAllocate,
    MutArrayCapacity,
    MutArrayGet,
    MutArraySet,
    MutArrayCopy,
    MutArrayFreeze,
    IsInt,
    IsStr,
    IsList,
    IsMutArray,
    IsOk,
    IsError,
    ResultValue,
    ResultError,
    /// The Unicode scalar value of a UnicodeChar operand, as an Int
    /// (char::codepoint/char_codepoint, core/unicodechar.tcl): total, never
    /// fails. A scalar value always fits the small-Int range, so the result
    /// is always an immediate small Int, never a BigInt.
    CharCodepoint,
    MkOk,
    MkError,
    /// Structural hash (core/hashing.tcl's hash): consistent with VEq,
    /// masked to 61 bits so the result never needs a BigInt. Bootstrap
    /// native, candidate for stdlib replacement: see core/hashing.tcl's
    /// header and ops.rs's `rt_hash`.
    Hash,
    /// Validates a StringRegion's bounds (base String, start, end: character
    /// indices) exactly as `Substr` would, without allocating or copying:
    /// UNIT on success, RANGE on failure. Emitted once, at the point in
    /// program order an ordinary `substr` call would have run, when
    /// native/lower.tcl's string-region lowering (see native/lower.tcl's
    /// "String regions" section and hir/stringregion.tcl) keeps a temporary
    /// substring as (base, start, end) registers instead of materializing a
    /// String. Strings are immutable, so a region proven valid here stays
    /// valid for as long as its registers are live.
    RegionCheck,
    /// Compares a validated StringRegion (base, start, end) against an
    /// ordinary String, character-for-character, with no allocation: the
    /// non-materializing counterpart of `StrEq` for one region-shaped
    /// operand (see hir/stringregion.tcl). Never fallible: RegionCheck
    /// already proved the region's bounds.
    RegionEq,
    /// Decodes the one Unicode scalar starting at a known UTF-8 byte offset
    /// of a String (base, byte_offset -- both ordinary tagged operands: the
    /// offset is always a small Int, so keeping it tagged costs nothing --
    /// no arithmetic-overflow check, no heap allocation, just a tag bit),
    /// returning it as a one-character String -- the same result an
    /// in-bounds `substring(base, i, i+1)` at the character index BYTE_OFFSET
    /// corresponds to would produce, without ever decoding BASE's prefix to
    /// find that byte offset (see native/lower.tcl's "String traversal"
    /// section and hir/traversal.tcl). Never fallible: callers only ever
    /// emit this at a byte offset already proven in range.
    DecodeCharAt,
    /// The UTF-8 byte length of a String's text (distinct from `StrLen`,
    /// which counts Unicode scalars): a plain field read, no scanning.
    /// Applied to `DecodeCharAt`'s own result, this gives the encoded
    /// width of the scalar just decoded, so a traversal can advance its
    /// carried byte offset by exactly that many bytes for the next
    /// iteration (see hir/traversal.tcl).
    StrByteLen,
    /// A String's UTF-8 encoding as a List of Ints, one per byte (each
    /// 0..255), in order (core/strings.tcl's `encode_utf8`): the general
    /// byte-level access Botlish's String type otherwise never exposes
    /// (String only ever counts/indexes by Unicode scalar -- see StrLen vs.
    /// StrByteLen above). Ordinary library code (e.g. percent-encoding)
    /// builds on this plus List/Int operations instead of needing its own
    /// native.
    StrUtf8Bytes,
    /// Tcl 9-compatible Unicode alpha/alnum character classification
    /// (core/tclcompat.tcl's `is_tcl_alpha`/`is_tcl_alnum`): the operand is
    /// a one-Unicode-scalar String (RANGE if not). TEMPORARY compatibility
    /// primitives -- see core/tclcompat.tcl's header -- not general
    /// character-class ops and not related to StrUtf8Bytes (classification
    /// is per Unicode scalar, never per UTF-8 byte).
    StrIsTclAlpha,
    StrIsTclAlnum,
    /// `StrIsTclAlpha`/`StrIsTclAlnum`'s non-materializing counterpart for a
    /// validated StringRegion operand (base, start, end -- exactly
    /// `RegionCheck`'s three operands): classifies the region's one Unicode
    /// scalar directly from BASE's text at the byte span [start, end)
    /// denotes, with no String ever allocated for it (see hir/
    /// stringregion.tcl's ConsumingParams and native/lower.tcl's "String
    /// regions" section). RANGE, exactly like the materializing ops, when
    /// the region is not exactly one Unicode scalar wide.
    StrRegionIsTclAlpha,
    StrRegionIsTclAlnum,
    /// Representation transitions and raw (untagged machine-integer)
    /// arithmetic/comparison: see the "Representation" section of
    /// native/lower.tcl. A raw operand/result is never a tagged Value: it
    /// carries no GC root (codegen never stores it to the shadow stack), so
    /// it must never itself be the payload of any of the ops above.
    RBox,
    RUnbox,
    RIAdd,
    RISub,
    RIMul,
    RILt,
    RILe,
    RIGt,
    RIGe,
    RIEq,
    /// Raw (untagged) shift, native/lower.tcl's RawEligibleShift: unlike
    /// IShl/IShr (always a helper call -- see the "Representation" section
    /// of native/lower.tcl), emitted only when range analysis proves the
    /// shifted value nonnegative and small, the shift amount a single
    /// already-known small value, and the result small too -- no BigInt
    /// case, no invalid-shift-amount case, so codegen (unlike IShl/IShr)
    /// lowers these directly to a host machine shift instruction, exactly
    /// like RIAdd/RISub/RIMul do for `+`/`-`/`*`.
    RIShr,
    RIShl,
}

impl OpCode {
    pub fn parse(name: &str) -> Option<OpCode> {
        use OpCode::*;
        Some(match name {
            "iadd" => IAdd,
            "isub" => ISub,
            "imul" => IMul,
            "imod" => IMod,
            "iand" => IAnd,
            "ior" => IOr,
            "ixor" => IXor,
            "ishl" => IShl,
            "ishr" => IShr,
            "ilt" => ILt,
            "ile" => ILe,
            "igt" => IGt,
            "ige" => IGe,
            "ieq" => IEq,
            "veq" => VEq,
            "streq" => StrEq,
            "listnew" => ListNew,
            "strlen" => StrLen,
            "substr" => Substr,
            "strlower" => StrLower,
            "strcat" => StrCat,
            "listlen" => ListLen,
            "listget" => ListGet,
            "listappend" => ListAppend,
            "setfromlist" => SetFromList,
            "setfromlisttotal" => SetFromListTotal,
            "setcontains" => SetContains,
            "setcontainstotal" => SetContainsTotal,
            "mutarrayallocate" => MutArrayAllocate,
            "mutarraycapacity" => MutArrayCapacity,
            "mutarrayget" => MutArrayGet,
            "mutarrayset" => MutArraySet,
            "mutarraycopy" => MutArrayCopy,
            "mutarrayfreeze" => MutArrayFreeze,
            "isint" => IsInt,
            "isstr" => IsStr,
            "islist" => IsList,
            "ismutarray" => IsMutArray,
            "isok" => IsOk,
            "iserror" => IsError,
            "resultvalue" => ResultValue,
            "resulterror" => ResultError,
            "charcodepoint" => CharCodepoint,
            "mkok" => MkOk,
            "mkerror" => MkError,
            "hash" => Hash,
            "regioncheck" => RegionCheck,
            "regioneq" => RegionEq,
            "decodecharat" => DecodeCharAt,
            "strbytelen" => StrByteLen,
            "strutf8bytes" => StrUtf8Bytes,
            "strtclalpha" => StrIsTclAlpha,
            "strtclalnum" => StrIsTclAlnum,
            "strregiontclalpha" => StrRegionIsTclAlpha,
            "strregiontclalnum" => StrRegionIsTclAlnum,
            "rbox" => RBox,
            "runbox" => RUnbox,
            "riadd" => RIAdd,
            "risub" => RISub,
            "rimul" => RIMul,
            "rilt" => RILt,
            "rile" => RILe,
            "rigt" => RIGt,
            "rige" => RIGe,
            "rieq" => RIEq,
            "rishr" => RIShr,
            "rishl" => RIShl,
            _ => return None,
        })
    }

    /// Number of operands, or None for any.
    pub fn arity(self) -> Option<usize> {
        use OpCode::*;
        match self {
            ListNew => None,
            StrLen | StrLower | ListLen | MutArrayAllocate | MutArrayCapacity | IsInt | IsStr | IsList | IsMutArray
            | IsOk | IsError | ResultValue | ResultError | MkOk | MkError | Hash | RBox | RUnbox
            | StrByteLen | StrUtf8Bytes | StrIsTclAlpha | StrIsTclAlnum | CharCodepoint | SetFromList
            | SetFromListTotal => Some(1),
            Substr | MutArraySet | RegionCheck | StrRegionIsTclAlpha | StrRegionIsTclAlnum => Some(3),
            RegionEq => Some(4),
            MutArrayCopy => Some(5),
            _ => Some(2),
        }
    }

    /// 1 if OP's result is a raw (untagged) machine integer, not a Value.
    pub fn raw_result(self) -> bool {
        matches!(self, OpCode::RUnbox | OpCode::RIAdd | OpCode::RISub | OpCode::RIMul
            | OpCode::RIShr | OpCode::RIShl)
    }

    /// 1 if OP's operands are raw (untagged) machine integers, not Values.
    pub fn raw_operands(self) -> bool {
        use OpCode::*;
        matches!(self, RBox | RIAdd | RISub | RIMul | RILt | RILe | RIGt | RIGe | RIEq | RIShr | RIShl)
    }
}

#[derive(Clone, Debug)]
pub enum Inst {
    Label(Label),
    Int { dst: Reg, digits: String },
    /// A raw (untagged) machine-integer constant: DIGITS must fit an i64.
    /// native/lower.tcl emits this only when range analysis proves every
    /// value the register can hold fits the runtime's small-Int range, so
    /// `op rbox` of it never needs a check.
    RawInt { dst: Reg, digits: String },
    Str { dst: Reg, text: String },
    /// A UnicodeChar constant: DIGITS is the canonical decimal codepoint
    /// (must be a valid Unicode scalar value, never a surrogate -- see
    /// UNICODE-CHAR-LITERALS.md); codegen packs it as the immediate
    /// `make_char` word directly, no allocation and no runtime call.
    Char { dst: Reg, digits: String },
    Bool { dst: Reg, value: bool },
    Unit { dst: Reg },
    Native { dst: Reg, native: u32 },
    FnValue { dst: Reg, func: FuncId },
    SelfClosure { dst: Reg },
    Capture { dst: Reg, index: u32 },
    /// Reads module-static slot INDEX (runtime::vm::Vm's own `statics`
    /// table, MODULE-STATIC-RETAINED-VALUES.md): a module-retained
    /// immutable binding's stable, program-lifetime storage, disjoint from
    /// any function's own closure environment -- reachable from any
    /// function alike, never routed through Capture/CellGet. Emitted for
    /// every reference to a module-static binding, never only the function
    /// that first computes its value.
    StaticGet { dst: Reg, index: u32 },
    /// Writes VALUE into module-static slot INDEX: emitted once, at the
    /// exact point the binding's own initializer expression finishes
    /// evaluating (module initialization order, MODULE-STATIC-RETAINED-
    /// VALUES.md) -- never by any other instruction, and never read back by
    /// the same function through anything but a later StaticGet.
    StaticSet { index: u32, value: Reg },
    Move { dst: Reg, src: Reg },
    Cell { dst: Reg },
    CellSet { cell: Reg, value: Reg },
    CellGet { dst: Reg, cell: Reg },
    CellCheck { dst: Reg, cell: Reg, name: String },
    Closure { dst: Reg, func: FuncId, captures: Vec<Reg> },
    Guard { kind: Kind, value: Reg, context: String },
    GuardBool { value: Reg },
    Op { dst: Reg, op: OpCode, args: Vec<Reg> },
    Call { dst: Reg, func: FuncId, args: Vec<Reg>, may_error: bool, may_gc: bool },
    CallEnv { dst: Reg, func: FuncId, closure: Reg, args: Vec<Reg>, may_error: bool, may_gc: bool },
    CallValue { dst: Reg, callee: Reg, args: Vec<Reg> },
    /// A direct call of a scalar-replacement companion function (a function
    /// with `results` > 1: see Function::results): like Call, but the
    /// callee returns several tagged Values at once -- the fields of a
    /// fixed-shape aggregate whose canonical List object native/lower.tcl's
    /// escape analysis proved this call site never needs (see hir/escape.tcl
    /// and native/lower.tcl's "Scalar replacement" section). Never used for
    /// an ordinary (results == 1) function.
    CallMulti { dsts: Vec<Reg>, func: FuncId, args: Vec<Reg>, may_error: bool, may_gc: bool },
    /// CallMulti, with a closure (see CallEnv).
    CallEnvMulti { dsts: Vec<Reg>, func: FuncId, closure: Reg, args: Vec<Reg>, may_error: bool, may_gc: bool },
    Tail { args: Vec<Reg> },
    TailEnv { closure: Reg, args: Vec<Reg> },
    Br { cond: Reg, then: Label, otherwise: Label },
    Jump(Label),
    Ret(Reg),
    /// Returns several tagged Values at once: the terminator of a
    /// scalar-replacement companion function (Function::results > 1),
    /// exactly as many as it declares. Never used for a `results == 1`
    /// function (which always uses Ret).
    RetMulti(Vec<Reg>),
    Raise { kind: String, message: String },
    Unreachable,
    /// `fail NAME` (EXPLICIT-ERROR-COMPLETIONS.md): sets the pending
    /// declared-error id ID (native/lower.tcl's own per-program
    /// assignment, never 0) and returns NO_VALUE exactly like Raise --
    /// every ordinary call site's own `may_error` check already propagates
    /// that with no change of its own. NAME is kept only for the fallback
    /// RtError message if this ever reaches the program boundary uncaught.
    Fail { id: u32, name: String },
    /// True iff the pending declared-error id (runtime/vm.rs's
    /// `Vm::declared_error`) equals ID: a `handle`'s own per-handler
    /// dispatch test, evaluated only inside a PushErrorExit/PopErrorExit
    /// span, right after the wrapped call's own `may_error` check has
    /// already jumped there with NO_VALUE pending.
    DeclaredErrorEq { dst: Reg, id: u32 },
    /// Clears the pending declared-error id and its fallback RtError:
    /// emitted once a `handle`'s dispatch has matched, immediately before
    /// lowering that handler's own body.
    ClearDeclaredError,
    /// Redirects every `may_error` check's own error-exit target (Call/
    /// CallEnv/CallMulti/CallEnvMulti's own automatic check, an allocating
    /// Op, Raise, Unreachable, Fail -- codegen::clif's own `check`/
    /// `fail_with`) to LABEL instead of this function's ordinary
    /// error_exit, for every instruction up to the matching
    /// PopErrorExit: a `handle`'s own wrapped call needs no *lowering*
    /// change at all (still an ordinary Call/CallEnv/... instruction,
    /// still may_error=true) -- only where its own NO_VALUE check lands
    /// changes, to LABEL's own dispatch code instead of propagating
    /// straight out of the function. Nests (codegen::clif keeps a stack):
    /// a handled call whose own callee or arguments themselves contain
    /// another `handle` restores the outer target correctly once the
    /// inner PopErrorExit runs.
    PushErrorExit(Label),
    /// Ends the most recently pushed PushErrorExit's span, restoring
    /// whatever error-exit target was active before it (this function's
    /// own error_exit, or an outer PushErrorExit still pending).
    PopErrorExit,
    /// Virtual immutable construction (M8A-VIRTUAL-IMMUTABLE-CONSTRUCTION.md,
    /// runtime/construct.rs): `%d = construct str|list plan|flat PIECE...`.
    /// One instruction for every String/List construction the virtual-
    /// construction lowering emits, whatever its number of pieces: FLAT
    /// builds (or passes through) an ordinary flat String/List, PLAN builds
    /// or extends a private plan object held by a plan register (see
    /// Function::plan_regs and `validate_plans`). Always a possible
    /// allocation (GC safepoint) and possible failure (the collection-length
    /// ceiling eager concat/list_append also enforce).
    Construct { dst: Reg, list: bool, plan: bool, pieces: Vec<Piece> },
    /// Propagates whatever failure (a raw RtError or a declared one) is
    /// already pending, unchanged, to the current error-exit target: a
    /// `handle` whose own dispatch matched none of its handlers emits this
    /// once PopErrorExit has already restored the *outer* target, so the
    /// failure continues exactly as if this `handle` were not there --
    /// never constructing a new error the way Raise/Fail do.
    Reraise,
}

/// One piece of an `Inst::Construct`, in source order.
#[derive(Clone, Debug, PartialEq, Eq)]
pub enum Piece {
    /// A flat String/List, or an owned plan register of the same family
    /// (consumed by this instruction).
    Span(Reg),
    /// String only: a validated StringRegion (base, start, end).
    Region(Reg, Reg, Reg),
    /// List only: one already-evaluated element.
    Elem(Reg),
}

impl Piece {
    pub fn regs(&self) -> Vec<Reg> {
        match self {
            Piece::Span(r) | Piece::Elem(r) => vec![*r],
            Piece::Region(b, s, e) => vec![*b, *s, *e],
        }
    }
}

impl Inst {
    pub fn is_terminator(&self) -> bool {
        matches!(
            self,
            Inst::Tail { .. }
                | Inst::TailEnv { .. }
                | Inst::Br { .. }
                | Inst::Jump(_)
                | Inst::Ret(_)
                | Inst::RetMulti(_)
                | Inst::Raise { .. }
                | Inst::Unreachable
                | Inst::Fail { .. }
                | Inst::Reraise
        )
    }
}

pub struct Function {
    pub id: FuncId,
    pub name: String,
    pub params: u32,
    pub env: bool,
    pub regs: u32,
    pub pnames: String,
    pub captures: u32,
    /// The number of tagged Values this function returns: 1 for every
    /// ordinary function (the `func` header omits `results=`, and every
    /// `ret` returns one Reg); more than 1 only for a scalar-replacement
    /// companion function native/lower.tcl emits alongside a specialized
    /// instance's ordinary function, whose terminator is always RetMulti
    /// with exactly this many registers (see the "Scalar replacement"
    /// section of native/lower.tcl). Such a function is only ever reached
    /// through CallMulti/CallEnvMulti from other NIR functions this same
    /// compilation emits -- never through the generic entry (no closure or
    /// Block value ever points to it) -- so codegen's generic entry wrapper
    /// is a dead stub for it (see codegen/clif.rs's `define`).
    pub results: u32,
    /// Settled closed-call effect summary for this exact NIR function.
    pub may_error: bool,
    pub may_gc: bool,
    pub body: Vec<Inst>,
    /// The HIR expression each instruction in BODY (same index) originated
    /// from -- native/lower.tcl's trailing "@ExprId" annotation on nearly
    /// every emitted instruction (see native/lower.tcl's Emit/Assign).
    /// None for instructions with no annotation (Label, and some that never
    /// carry one). Purely informational to this backend: it is opaque here
    /// and only meaningful to the Tcl compiler that emitted it (see
    /// codegen::clif's Site table and native.tcl's allocation-site
    /// resolution) -- this backend does not and must not interpret it.
    pub origins: Vec<Option<u32>>,
    /// Registers native/lower.tcl has proven hold a raw (untagged) machine
    /// integer for the *whole* function, indexed by Reg (`raw_regs[r]`),
    /// declared once by the `rawregs=` header attribute rather than inferred
    /// per instruction: see validate's raw-consistency checks and the
    /// "Representation" section of native/lower.tcl. This lets a register
    /// have more than one definition site (an `if`-join's shared result
    /// register, a `tail`-rebound parameter slot) and still be checked, since
    /// the declaration -- not scan order -- says what it must be. A
    /// parameter register (index < params) declared raw is unboxed once, in
    /// the prologue (codegen::clif), from the tagged incoming argument.
    pub raw_regs: Vec<bool>,
    /// Registers native/lower.tcl declares may hold a private virtual-
    /// construction plan (`planregs=`, M8.a) -- "maybe-plan": such a
    /// register may equally hold an ordinary flat String/List, but nothing
    /// may read it as one. A parameter register (index < params) so
    /// declared accepts a plan argument from a direct call or self tail
    /// call. See `validate_plans` for the full discipline.
    pub plan_regs: Vec<bool>,
    /// Whether this function's result may be a plan (`planresult=1`): only
    /// ever a closed instance's, whose every caller is a direct call that
    /// knows it (native/lower.tcl); its generic entry materializes
    /// defensively (codegen::clif's `define`).
    pub plan_result: bool,
}

pub struct NativeDecl {
    pub name: String,
    pub arity: Option<usize>,
    pub params: Vec<Option<Kind>>,
    pub op: OpCode,
}

pub struct Program {
    pub natives: Vec<NativeDecl>,
    pub functions: Vec<Function>,
    /// The number of module-static slots this program uses (the header's
    /// own `statics=N`, MODULE-STATIC-RETAINED-VALUES.md): runtime::vm::Vm's
    /// own `statics` table is sized to this once, at program-install time,
    /// and every StaticGet/StaticSet's own `index` is checked against it
    /// (`validate`/`parse_inst`), exactly like a function's own `captures`
    /// bounds its Capture indices. Zero for a program with no module-static
    /// bindings.
    pub statics: u32,
}

#[derive(Debug)]
pub struct NirError {
    pub line: usize,
    pub message: String,
}

impl fmt::Display for NirError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "invalid NIR at line {}: {}", self.line, self.message)
    }
}

#[derive(Clone, Debug, PartialEq)]
enum Token {
    Word(String),
    Reg(Reg),
    Quoted(String),
    Pair(String, String),
}

/// TOKENS of the line, and its trailing "@ExprId" origin annotation, if any
/// (native/lower.tcl's Emit/Assign; see Function::origins). HIR expression
/// ids print as e.g. "e17" (one letter, hir.tcl's id namespace prefix, then
/// digits): the leading letter is skipped, not required, so a bare-digit
/// annotation (this backend's own NIR test fixtures) also parses. Anything
/// else not digits at all (e.g. a func header's "@program", never emitted
/// since lower.tcl only appends it when the region is not "program") yields
/// None, not an error: this annotation is optional and opaque to this
/// backend either way -- see codegen/mod.rs's Site doc comment.
fn tokenize(line: &str) -> Result<(Vec<Token>, Option<u32>), String> {
    let mut tokens = Vec::new();
    let mut chars = line.chars().peekable();
    loop {
        while chars.peek().is_some_and(|c| c.is_whitespace()) {
            chars.next();
        }
        let Some(&c) = chars.peek() else { break };
        if c == '@' {
            chars.next();
            if chars.peek().is_some_and(|c| c.is_ascii_alphabetic()) {
                chars.next();
            }
            let mut digits = String::new();
            while chars.peek().is_some_and(|c| c.is_ascii_digit()) {
                digits.push(chars.next().unwrap());
            }
            return Ok((tokens, digits.parse().ok()));
        }
        if c == '"' {
            chars.next();
            tokens.push(Token::Quoted(quoted(&mut chars)?));
            continue;
        }
        let mut word = String::new();
        while let Some(&c) = chars.peek() {
            if c.is_whitespace() {
                break;
            }
            if c == '=' && !word.is_empty() && word != "%" {
                chars.next();
                let value = if chars.peek() == Some(&'"') {
                    chars.next();
                    quoted(&mut chars)?
                } else {
                    let mut value = String::new();
                    while chars.peek().is_some_and(|c| !c.is_whitespace()) {
                        value.push(chars.next().unwrap());
                    }
                    value
                };
                tokens.push(Token::Pair(word.clone(), value));
                word.clear();
                break;
            }
            word.push(c);
            chars.next();
        }
        if word.is_empty() {
            continue;
        }
        if let Some(n) = word.strip_prefix('%') {
            tokens.push(Token::Reg(n.parse().map_err(|_| format!("bad register {word}"))?));
        } else {
            tokens.push(Token::Word(word));
        }
    }
    Ok((tokens, None))
}

fn quoted(chars: &mut std::iter::Peekable<std::str::Chars<'_>>) -> Result<String, String> {
    let mut text = String::new();
    loop {
        match chars.next() {
            None => return Err("unterminated string".into()),
            Some('"') => return Ok(text),
            Some('\\') => match chars.next() {
                Some('n') => text.push('\n'),
                Some('r') => text.push('\r'),
                Some('t') => text.push('\t'),
                Some('\\') => text.push('\\'),
                Some('"') => text.push('"'),
                Some('u') => {
                    if chars.next() != Some('{') {
                        return Err("bad \\u escape".into());
                    }
                    let mut hex = String::new();
                    loop {
                        match chars.next() {
                            Some('}') => break,
                            Some(c) => hex.push(c),
                            None => return Err("bad \\u escape".into()),
                        }
                    }
                    let code = u32::from_str_radix(&hex, 16).map_err(|_| "bad \\u escape")?;
                    text.push(char::from_u32(code).ok_or("bad \\u escape")?);
                }
                other => return Err(format!("bad escape {other:?}")),
            },
            Some(c) => text.push(c),
        }
    }
}

struct Parser {
    line: usize,
}

impl Parser {
    fn err<T>(&self, message: impl Into<String>) -> Result<T, NirError> {
        Err(NirError { line: self.line, message: message.into() })
    }
}

fn word(t: &Token) -> Option<&str> {
    if let Token::Word(w) = t { Some(w) } else { None }
}

pub fn parse(text: &str) -> Result<Program, NirError> {
    let mut p = Parser { line: 0 };
    let mut program = Program { natives: Vec::new(), functions: Vec::new(), statics: 0 };
    let mut current: Option<Function> = None;
    let mut seen_header = false;
    let mut call_effects = true;
    for (index, raw) in text.lines().enumerate() {
        p.line = index + 1;
        let (tokens, origin) = tokenize(raw).or_else(|m| p.err(m))?;
        if tokens.is_empty() || raw.trim_start().starts_with(';') {
            continue;
        }
        if !seen_header {
            if tokens.len() < 2 || tokens[0] != Token::Word("nir".into()) || tokens[1] != Token::Word("1".into()) {
                return p.err("expected \"nir 1\"");
            }
            let kv = pairs(&tokens);
            call_effects = kv.get("call-effects").map(|v| v != "0").unwrap_or(true);
            program.statics = match kv.get("statics") {
                Some(v) => v.parse().or_else(|_| p.err("bad statics count"))?,
                None => 0,
            };
            seen_header = true;
            continue;
        }
        let head = word(&tokens[0]).unwrap_or("");
        if current.is_none() {
            match head {
                "native" => program.natives.push(parse_native(&p, &tokens)?),
                "func" => current = Some(parse_func_header(&p, &tokens)?),
                _ => return p.err(format!("expected native or func, got {raw:?}")),
            }
            continue;
        }
        if head == "end" {
            program.functions.push(current.take().unwrap());
            continue;
        }
        let inst = parse_inst(&p, &tokens, &program)?;
        let f = current.as_mut().unwrap();
        f.body.push(inst);
        f.origins.push(origin);
    }
    if current.is_some() {
        return p.err("missing end");
    }
    validate(&program)?;
    summarize_call_effects(&mut program, call_effects);
    Ok(program)
}

fn summarize_call_effects(program: &mut Program, enabled: bool) {
    let n = program.functions.len();
    let mut local = vec![(false, false); n];
    for (i, f) in program.functions.iter().enumerate() {
        for inst in &f.body {
            match inst {
                Inst::Guard { .. } | Inst::GuardBool { .. } | Inst::CellCheck { .. }
                    | Inst::Raise { .. } | Inst::Fail { .. } | Inst::Reraise => local[i].0 = true,
                Inst::Op { op, .. } => {
                    local[i].0 |= op_may_error(*op);
                    local[i].1 |= op_may_allocate(*op);
                }
                Inst::Cell { .. } | Inst::Closure { .. } => local[i].1 = true,
                Inst::Construct { .. } => local[i] = (true, true),
                Inst::CallValue { .. } => local[i] = (true, true),
                _ => {}
            }
        }
    }
    let mut effects = local.clone();
    loop {
        let old = effects.clone();
        for (i, f) in program.functions.iter().enumerate() {
            let mut e = local[i];
            for inst in &f.body {
                let target = match inst {
                    Inst::Call { func, .. } | Inst::CallEnv { func, .. }
                        | Inst::CallMulti { func, .. } | Inst::CallEnvMulti { func, .. } => Some(*func as usize),
                    _ => None,
                };
                if let Some(target) = target {
                    e.0 |= old[target].0;
                    e.1 |= old[target].1;
                }
            }
            effects[i] = e;
        }
        if effects == old { break; }
    }
    for (i, f) in program.functions.iter_mut().enumerate() {
        (f.may_error, f.may_gc) = effects[i];
        for inst in &mut f.body {
            match inst {
                Inst::Call { func, may_error, may_gc, .. }
                    | Inst::CallEnv { func, may_error, may_gc, .. }
                    | Inst::CallMulti { func, may_error, may_gc, .. }
                    | Inst::CallEnvMulti { func, may_error, may_gc, .. } => {
                        (*may_error, *may_gc) = if enabled { effects[*func as usize] } else { (true, true) };
                    }
                _ => {}
            }
        }
    }
}

fn pairs(tokens: &[Token]) -> std::collections::HashMap<String, String> {
    tokens
        .iter()
        .filter_map(|t| if let Token::Pair(k, v) = t { Some((k.clone(), v.clone())) } else { None })
        .collect()
}

fn parse_native(p: &Parser, tokens: &[Token]) -> Result<NativeDecl, NirError> {
    let Some(Token::Quoted(name)) = tokens.get(1) else { return p.err("native needs a quoted name") };
    let kv = pairs(tokens);
    let arity = match kv.get("arity").map(String::as_str) {
        Some("*") => None,
        Some(n) => Some(n.parse().or_else(|_| p.err("bad arity"))?),
        None => return p.err("native needs arity="),
    };
    let params = kv
        .get("params")
        .map(|s| s.split_whitespace().map(|k| if k == "any" { Ok(None) } else { Kind::parse(k).map(Some).ok_or(()) }).collect())
        .unwrap_or(Ok(vec![]))
        .or_else(|_| p.err("bad params"))?;
    let op = kv.get("impl").and_then(|s| OpCode::parse(s)).map_or_else(|| p.err("bad impl"), Ok)?;
    Ok(NativeDecl { name: name.clone(), arity, params, op })
}

fn parse_func_header(p: &Parser, tokens: &[Token]) -> Result<Function, NirError> {
    let id = tokens.get(1).and_then(word).and_then(|w| w.parse().ok());
    let Some(id) = id else { return p.err("func needs an id") };
    let Some(Token::Quoted(name)) = tokens.get(2) else { return p.err("func needs a quoted name") };
    let kv = pairs(tokens);
    let num = |key: &str| -> Result<u32, NirError> {
        match kv.get(key).and_then(|v| v.parse().ok()) {
            Some(n) => Ok(n),
            None => p.err(format!("func needs {key}=")),
        }
    };
    let regs = num("regs")?;
    let results = match kv.get("results") {
        Some(v) => v.parse().or_else(|_| p.err("bad results"))?,
        None => 1,
    };
    let mut raw_regs = vec![false; regs as usize];
    if let Some(list) = kv.get("rawregs") {
        for tok in list.split_whitespace() {
            let r: usize = tok.parse().map_err(|_| ())
                .and_then(|r: usize| if r < regs as usize { Ok(r) } else { Err(()) })
                .or_else(|_| p.err::<usize>(format!("bad rawregs register {tok}")))?;
            raw_regs[r] = true;
        }
    }
    let mut plan_regs = vec![false; regs as usize];
    if let Some(list) = kv.get("planregs") {
        for tok in list.split_whitespace() {
            let r: usize = tok.parse().map_err(|_| ())
                .and_then(|r: usize| if r < regs as usize { Ok(r) } else { Err(()) })
                .or_else(|_| p.err::<usize>(format!("bad planregs register {tok}")))?;
            plan_regs[r] = true;
        }
    }
    let plan_result = kv.get("planresult").is_some_and(|v| v == "1");
    Ok(Function {
        id,
        name: name.clone(),
        params: num("params")?,
        env: num("env")? == 1,
        regs,
        pnames: kv.get("pnames").cloned().unwrap_or_default(),
        captures: num("captures")?,
        results,
        may_error: true,
        may_gc: true,
        body: Vec::new(),
        origins: Vec::new(),
        raw_regs,
        plan_regs,
        plan_result,
    })
}

fn parse_inst(p: &Parser, tokens: &[Token], program: &Program) -> Result<Inst, NirError> {
    let reg = |i: usize| -> Result<Reg, NirError> {
        match tokens.get(i) {
            Some(Token::Reg(r)) => Ok(*r),
            other => p.err(format!("expected a register, got {other:?}")),
        }
    };
    let regs_from = |i: usize| -> Result<Vec<Reg>, NirError> { (i..tokens.len()).map(reg).collect() };
    let num = |i: usize| -> Result<u32, NirError> {
        match tokens.get(i).and_then(word).and_then(|w| w.parse().ok()) {
            Some(n) => Ok(n),
            None => p.err("expected a number"),
        }
    };
    let label = |i: usize| -> Result<Label, NirError> {
        match tokens.get(i).and_then(word).and_then(|w| w.strip_prefix('L')).and_then(|n| n.parse().ok()) {
            Some(n) => Ok(n),
            None => p.err("expected a label"),
        }
    };
    let quoted = |i: usize| -> Result<String, NirError> {
        match tokens.get(i) {
            Some(Token::Quoted(s)) => Ok(s.clone()),
            _ => p.err("expected a quoted string"),
        }
    };
    if let Some(Token::Reg(_)) = tokens.first() {
        // One or more leading registers (more than one only for
        // callmulti/callenvmulti's dsts: see Inst::CallMulti) before "=".
        let mut dsts = Vec::new();
        let mut i = 0;
        while let Some(Token::Reg(r)) = tokens.get(i) {
            dsts.push(*r);
            i += 1;
        }
        if tokens.get(i) != Some(&Token::Word("=".into())) {
            return p.err("expected =");
        }
        i += 1;
        let rhs = tokens.get(i).and_then(word).unwrap_or("");
        i += 1;
        if rhs != "callmulti" && rhs != "callenvmulti" && dsts.len() != 1 {
            return p.err(format!("{rhs} takes exactly one destination register"));
        }
        let dst = dsts[0];
        // I is the index of the first operand after the rhs word: 3 for
        // every ordinary (single-dst) instruction below, exactly as the
        // literal indices already assumed; only callmulti/callenvmulti
        // (dsts.len() possibly > 1) need I itself, since their operands
        // start later when there is more than one destination register.
        return Ok(match rhs {
            "int" => {
                let digits = tokens.get(3).and_then(word).unwrap_or("").to_string();
                if digits.parse::<num_bigint::BigInt>().is_err() {
                    return p.err("bad int literal");
                }
                Inst::Int { dst, digits }
            }
            "rawint" => {
                let digits = tokens.get(3).and_then(word).unwrap_or("").to_string();
                if digits.parse::<i64>().is_err() {
                    return p.err("bad rawint literal (must fit an i64)");
                }
                Inst::RawInt { dst, digits }
            }
            "str" => Inst::Str { dst, text: quoted(3)? },
            "char" => {
                let digits = tokens.get(3).and_then(word).unwrap_or("").to_string();
                let Ok(codepoint) = digits.parse::<u32>() else { return p.err("bad char literal") };
                if !crate::runtime::value::is_valid_scalar(codepoint) {
                    return p.err("char literal is not a Unicode scalar value");
                }
                Inst::Char { dst, digits }
            }
            "bool" => match tokens.get(3).and_then(word) {
                Some("true") => Inst::Bool { dst, value: true },
                Some("false") => Inst::Bool { dst, value: false },
                _ => return p.err("bad bool"),
            },
            "unit" => Inst::Unit { dst },
            "native" => {
                let name = quoted(3)?;
                match program.natives.iter().position(|n| n.name == name) {
                    Some(i) => Inst::Native { dst, native: i as u32 },
                    None => return p.err(format!("undeclared native {name}")),
                }
            }
            "fnvalue" => Inst::FnValue { dst, func: num(3)? },
            "self" => Inst::SelfClosure { dst },
            "capture" => Inst::Capture { dst, index: num(3)? },
            "staticget" => {
                let index = num(3)?;
                if index >= program.statics {
                    return p.err(format!("bad static slot {index}"));
                }
                Inst::StaticGet { dst, index }
            }
            "move" => Inst::Move { dst, src: reg(3)? },
            "cell" => Inst::Cell { dst },
            "cellget" => Inst::CellGet { dst, cell: reg(3)? },
            "cellcheck" => Inst::CellCheck { dst, cell: reg(3)?, name: quoted(4)? },
            "closure" => Inst::Closure { dst, func: num(3)?, captures: regs_from(4)? },
            "op" => {
                let name = tokens.get(3).and_then(word).unwrap_or("");
                let Some(op) = OpCode::parse(name) else { return p.err(format!("unknown op {name}")) };
                Inst::Op { dst, op, args: regs_from(4)? }
            }
            "call" => Inst::Call { dst, func: num(3)?, args: regs_from(4)?, may_error: true, may_gc: true },
            "callenv" => Inst::CallEnv { dst, func: num(3)?, closure: reg(4)?, args: regs_from(5)?, may_error: true, may_gc: true },
            "callvalue" => Inst::CallValue { dst, callee: reg(3)?, args: regs_from(4)? },
            "callmulti" => Inst::CallMulti { dsts, func: num(i)?, args: regs_from(i + 1)?, may_error: true, may_gc: true },
            "callenvmulti" => {
                Inst::CallEnvMulti { dsts, func: num(i)?, closure: reg(i + 1)?, args: regs_from(i + 2)?, may_error: true, may_gc: true }
            }
            "declarederroreq" => Inst::DeclaredErrorEq { dst, id: num(3)? },
            "construct" => {
                let list = match tokens.get(3).and_then(word) {
                    Some("str") => false,
                    Some("list") => true,
                    _ => return p.err("construct needs str or list"),
                };
                let plan = match tokens.get(4).and_then(word) {
                    Some("flat") => false,
                    Some("plan") => true,
                    _ => return p.err("construct needs flat or plan"),
                };
                let mut pieces = Vec::new();
                let mut k = 5;
                while k < tokens.len() {
                    match &tokens[k] {
                        Token::Reg(r) => {
                            pieces.push(Piece::Span(*r));
                            k += 1;
                        }
                        Token::Word(w) if w == "region" && !list => {
                            pieces.push(Piece::Region(reg(k + 1)?, reg(k + 2)?, reg(k + 3)?));
                            k += 4;
                        }
                        Token::Word(w) if w == "elem" && list => {
                            pieces.push(Piece::Elem(reg(k + 1)?));
                            k += 2;
                        }
                        other => return p.err(format!("bad construct piece {other:?}")),
                    }
                }
                if pieces.is_empty() {
                    return p.err("construct needs at least one piece");
                }
                Inst::Construct { dst, list, plan, pieces }
            }
            other => return p.err(format!("unknown instruction {other}")),
        });
    }
    let head = tokens.first().and_then(word).unwrap_or("");
    Ok(match head {
        "label" => Inst::Label(label(1)?),
        "cellset" => Inst::CellSet { cell: reg(1)?, value: reg(2)? },
        "staticset" => {
            let index = num(1)?;
            if index >= program.statics {
                return p.err(format!("bad static slot {index}"));
            }
            Inst::StaticSet { index, value: reg(2)? }
        }
        "guard" => {
            let kind = tokens.get(1).and_then(word).and_then(Kind::parse);
            let Some(kind) = kind else { return p.err("bad guard kind") };
            Inst::Guard { kind, value: reg(2)?, context: quoted(3)? }
        }
        "guardbool" => Inst::GuardBool { value: reg(1)? },
        "tail" => Inst::Tail { args: regs_from(1)? },
        "tailenv" => Inst::TailEnv { closure: reg(1)?, args: regs_from(2)? },
        "br" => Inst::Br { cond: reg(1)?, then: label(2)?, otherwise: label(3)? },
        "jump" => Inst::Jump(label(1)?),
        "ret" => Inst::Ret(reg(1)?),
        "retmulti" => Inst::RetMulti(regs_from(1)?),
        "raise" => Inst::Raise {
            kind: tokens.get(1).and_then(word).unwrap_or("").to_string(),
            message: quoted(2)?,
        },
        "unreachable" => Inst::Unreachable,
        "faildeclared" => Inst::Fail { id: num(1)?, name: quoted(2)? },
        "cleardeclarederror" => Inst::ClearDeclaredError,
        "pusherrorexit" => Inst::PushErrorExit(label(1)?),
        "poperrorexit" => Inst::PopErrorExit,
        "reraise" => Inst::Reraise,
        other => return p.err(format!("unknown instruction {other}")),
    })
}

/// Structural checks, so code generation can assume well-formed input.
fn validate(program: &Program) -> Result<(), NirError> {
    let fail = |message: String| Err(NirError { line: 0, message });
    for (i, f) in program.functions.iter().enumerate() {
        if f.id as usize != i {
            return fail(format!("function ids must be 0..n in order, got {} at {i}", f.id));
        }
    }
    let func = |id: FuncId| program.functions.get(id as usize);
    for f in &program.functions {
        let ctx = |m: String| format!("function {} ({}): {m}", f.id, f.name);
        if f.params > f.regs {
            return fail(ctx("params > regs".into()));
        }
        let mut labels = HashSet::new();
        for inst in &f.body {
            if let Inst::Label(l) = inst {
                if !labels.insert(*l) {
                    return fail(ctx(format!("label L{l} defined twice")));
                }
            }
        }
        if !f.body.last().is_some_and(Inst::is_terminator) {
            return fail(ctx("does not end in a terminator".into()));
        }
        // Which registers hold a raw (untagged) machine integer rather than
        // a Value: f.raw_regs's declaration (rawregs=, from native/lower.tcl,
        // which already knows the answer from hir::range/hir::induction), not
        // inferred here. Checking a declaration instead of inferring one
        // forward is what lets a register have more than one definition site
        // -- an `if`-join's shared result register, a `tail`-rebound
        // parameter slot -- and still be validated: every site just has to
        // agree with the same fixed answer, in whatever order it runs.
        let raw = &f.raw_regs;
        for inst in &f.body {
            let mut used: Vec<Reg> = Vec::new();
            let mut targets: Vec<Label> = Vec::new();
            match inst {
                Inst::Label(_) | Inst::Unreachable | Inst::Raise { .. }
                | Inst::Fail { .. } | Inst::ClearDeclaredError | Inst::PopErrorExit
                | Inst::Reraise => {}
                Inst::DeclaredErrorEq { dst, .. } => used.push(*dst),
                Inst::PushErrorExit(l) => targets.push(*l),
                Inst::Int { dst, .. }
                | Inst::RawInt { dst, .. }
                | Inst::Str { dst, .. }
                | Inst::Char { dst, .. }
                | Inst::Bool { dst, .. }
                | Inst::Unit { dst }
                | Inst::Native { dst, .. }
                | Inst::Cell { dst } => used.push(*dst),
                Inst::SelfClosure { dst } => {
                    if !f.env {
                        return fail(ctx("self in a function without environment".into()));
                    }
                    used.push(*dst);
                }
                Inst::Capture { dst, index } => {
                    if !f.env || *index >= f.captures {
                        return fail(ctx(format!("bad capture {index}")));
                    }
                    used.push(*dst);
                }
                // Slot bounds already checked at parse time (parse_inst),
                // against the program-level `statics` count -- there is no
                // per-function count to cross-check here, unlike Capture's
                // own `f.captures`.
                Inst::StaticGet { dst, .. } => used.push(*dst),
                Inst::FnValue { dst, func: g } => {
                    match func(*g) {
                        Some(g) if !g.env => {}
                        _ => return fail(ctx(format!("fnvalue of {g}: not an environment-free function"))),
                    }
                    used.push(*dst);
                }
                Inst::Move { dst, src } => used.extend([*dst, *src]),
                Inst::CellSet { cell, value } => used.extend([*cell, *value]),
                Inst::StaticSet { value, .. } => used.push(*value),
                Inst::CellGet { dst, cell } | Inst::CellCheck { dst, cell, .. } => used.extend([*dst, *cell]),
                Inst::Closure { dst, func: g, captures } => {
                    match func(*g) {
                        Some(g) if g.env && g.captures as usize == captures.len() => {}
                        _ => return fail(ctx(format!("closure of {g}: bad target or capture count"))),
                    }
                    used.push(*dst);
                    used.extend(captures);
                }
                Inst::Guard { value, .. } | Inst::GuardBool { value } => used.push(*value),
                Inst::Construct { dst, pieces, .. } => {
                    used.push(*dst);
                    for piece in pieces {
                        used.extend(piece.regs());
                    }
                }
                Inst::Op { dst, op, args } => {
                    if op.arity().is_some_and(|n| n != args.len()) {
                        return fail(ctx(format!("op {op:?} takes {:?} operands", op.arity())));
                    }
                    used.push(*dst);
                    used.extend(args);
                }
                Inst::Call { dst, func: g, args, .. } => {
                    match func(*g) {
                        Some(g) if !g.env && g.params as usize == args.len() => {}
                        _ => return fail(ctx(format!("call of {g}: bad target or arity"))),
                    }
                    used.push(*dst);
                    used.extend(args);
                }
                Inst::CallEnv { dst, func: g, closure, args, .. } => {
                    match func(*g) {
                        Some(g) if g.env && g.params as usize == args.len() => {}
                        _ => return fail(ctx(format!("callenv of {g}: bad target or arity"))),
                    }
                    used.extend([*dst, *closure]);
                    used.extend(args);
                }
                Inst::CallValue { dst, callee, args } => {
                    used.extend([*dst, *callee]);
                    used.extend(args);
                }
                Inst::CallMulti { dsts, func: g, args, .. } => {
                    match func(*g) {
                        Some(g) if !g.env && g.params as usize == args.len() && g.results as usize == dsts.len() => {}
                        _ => return fail(ctx(format!("callmulti of {g}: bad target, arity or result count"))),
                    }
                    used.extend(dsts);
                    used.extend(args);
                }
                Inst::CallEnvMulti { dsts, func: g, closure, args, .. } => {
                    match func(*g) {
                        Some(g) if g.env && g.params as usize == args.len() && g.results as usize == dsts.len() => {}
                        _ => return fail(ctx(format!("callenvmulti of {g}: bad target, arity or result count"))),
                    }
                    used.push(*closure);
                    used.extend(dsts);
                    used.extend(args);
                }
                Inst::Tail { args } | Inst::TailEnv { args, .. } => {
                    if args.len() != f.params as usize {
                        return fail(ctx("tail call arity".into()));
                    }
                    if let Inst::TailEnv { closure, .. } = inst {
                        if !f.env {
                            return fail(ctx("tailenv in a function without environment".into()));
                        }
                        used.push(*closure);
                    } else if f.env {
                        return fail(ctx("tail in a function with environment".into()));
                    }
                    used.extend(args);
                }
                Inst::Br { cond, then, otherwise } => {
                    used.push(*cond);
                    targets.extend([*then, *otherwise]);
                }
                Inst::Jump(l) => targets.push(*l),
                Inst::Ret(r) => {
                    if f.results != 1 {
                        return fail(ctx(format!("ret: function declares results={}, expected retmulti", f.results)));
                    }
                    used.push(*r);
                }
                Inst::RetMulti(rs) => {
                    if rs.len() != f.results as usize {
                        return fail(ctx(format!(
                            "retmulti: {} value(s), function declares results={}",
                            rs.len(),
                            f.results
                        )));
                    }
                    used.extend(rs);
                }
            }
            if let Some(r) = used.iter().find(|r| **r >= f.regs) {
                return fail(ctx(format!("register %{r} out of range")));
            }
            match inst {
                Inst::RawInt { dst, .. } => {
                    if !raw[*dst as usize] {
                        return fail(ctx(format!("rawint %{dst}: not declared in rawregs")));
                    }
                }
                Inst::Move { dst, src } => {
                    if raw[*dst as usize] != raw[*src as usize] {
                        return fail(ctx(format!(
                            "move %{dst} = %{src}: %{dst} is {}, %{src} is {}",
                            if raw[*dst as usize] { "raw" } else { "tagged" },
                            if raw[*src as usize] { "raw" } else { "tagged" }
                        )));
                    }
                }
                Inst::Op { dst, op, args } => {
                    if let Some(a) = args.iter().find(|a| raw[**a as usize] != op.raw_operands()) {
                        let (is, want) = (raw[*a as usize], op.raw_operands());
                        return fail(ctx(format!(
                            "op {op:?}: operand %{a} is {}, must be {}",
                            if is { "raw" } else { "tagged" },
                            if want { "raw" } else { "tagged" }
                        )));
                    }
                    if raw[*dst as usize] != op.raw_result() {
                        return fail(ctx(format!(
                            "op {op:?}: result %{dst} is declared {}, must be {}",
                            if raw[*dst as usize] { "raw" } else { "tagged" },
                            if op.raw_result() { "raw" } else { "tagged" }
                        )));
                    }
                }
                // A parameter register i < f.params declared raw is unboxed
                // once in the prologue (codegen::clif), so its representation
                // for the rest of the function -- including every backedge --
                // is raw: the i-th argument must already be raw too. Every
                // other rebound register (env=1's closure) stays ordinary
                // tagged, like any operand in the catch-all below.
                Inst::Tail { args } | Inst::TailEnv { args, .. } => {
                    if let Some((i, a)) = args.iter().enumerate().find(|(i, a)| raw[**a as usize] != raw[*i]) {
                        return fail(ctx(format!(
                            "tail argument {i} (%{a}) is {}, but parameter %{i} is declared {}",
                            if raw[*a as usize] { "raw" } else { "tagged" },
                            if raw[i] { "raw" } else { "tagged" }
                        )));
                    }
                    if let Inst::TailEnv { closure, .. } = inst {
                        if raw[*closure as usize] {
                            return fail(ctx(format!("tailenv closure %{closure} must be tagged")));
                        }
                    }
                }
                _ => {
                    if let Some(r) = used.iter().find(|r| raw[**r as usize]) {
                        return fail(ctx(format!(
                            "register %{r} is raw but used where a tagged Value is required"
                        )));
                    }
                }
            }
            if let Some(l) = targets.iter().find(|l| !labels.contains(l)) {
                return fail(ctx(format!("undefined label L{l}")));
            }
        }
    }
    if program.functions.is_empty() || program.functions[0].params != 0 || program.functions[0].env
            || program.functions[0].results != 1 {
        return fail("function 0 must be the program: no parameters, no environment, one result".into());
    }
    validate_plans(program)
}

/// The virtual-construction plan discipline (M8.a), checked structurally so
/// codegen and the runtime can rely on it: a plan object never reaches any
/// operation that expects an ordinary String/List, and each plan is
/// consumed at most once along every path (so the runtime's in-place
/// extension is never observable).
///
/// A register declared in `planregs=` ("maybe-plan") may be *used* only as:
///   * a `span` piece of a `construct` (never a `region`/`elem` operand);
///   * the source of a `move` into another plan register;
///   * argument i of a `tail`/`tailenv` whose parameter register i is a
///     plan register, or of a `call`/`callenv` whose callee's parameter
///     register i is;
///   * the operand of `ret` in a `planresult=1` function.
/// Every other use -- a guard, an op, a native call, a Block/dynamic call,
/// a closure capture, a cell, `retmulti`, a branch condition -- is
/// rejected. Definitions: `construct ... plan` must define a plan register
/// and `construct ... flat` an ordinary one; a `call`/`callenv` of a
/// `planresult=1` function must define a plan register; a `move` from a
/// plan register must define one. (Any other definition of a plan register
/// stores an ordinary value, which a maybe-plan register may always hold.)
/// A plan register is never raw, and function 0 (the program) never has a
/// plan result.
///
/// Linearity: a forward "may have been consumed" dataflow over the CFG
/// (labels, branches, jumps, self-tail back edges to the entry, and a
/// handler's `pusherrorexit` label reachable from any instruction in its
/// span): every allowed use above consumes its register; a use of a
/// register that may already have been consumed on some path reaching it
/// is rejected; a (re)definition makes a register unconsumed again.
fn validate_plans(program: &Program) -> Result<(), NirError> {
    let fail = |message: String| Err(NirError { line: 0, message });
    for f in &program.functions {
        let ctx = |m: String| format!("function {} ({}): {m}", f.id, f.name);
        let plan = &f.plan_regs;
        if f.id == 0 && f.plan_result {
            return fail(ctx("the program function cannot have a plan result".into()));
        }
        if f.plan_result && f.results != 1 {
            return fail(ctx("planresult requires results=1".into()));
        }
        if let Some(r) = (0..f.regs as usize).find(|r| plan[*r] && f.raw_regs[*r]) {
            return fail(ctx(format!("register %{r} is declared both raw and plan")));
        }
        // Per instruction: the plan registers it consumes, or an error.
        let mut consumes: Vec<Vec<Reg>> = Vec::with_capacity(f.body.len());
        for inst in &f.body {
            let mut used: Vec<Reg> = Vec::new();
            let mut consumed: Vec<Reg> = Vec::new();
            let callee = |g: FuncId| &program.functions[g as usize];
            match inst {
                Inst::Construct { dst, plan: plan_mode, pieces, .. } => {
                    if plan[*dst as usize] != *plan_mode {
                        return fail(ctx(format!(
                            "construct %{dst}: a {} construct must define a {} register",
                            if *plan_mode { "plan" } else { "flat" },
                            if *plan_mode { "plan" } else { "non-plan" }
                        )));
                    }
                    for piece in pieces {
                        match piece {
                            Piece::Span(r) => {
                                if plan[*r as usize] {
                                    consumed.push(*r);
                                }
                                if f.raw_regs[*r as usize] {
                                    return fail(ctx(format!("construct piece %{r} is raw")));
                                }
                            }
                            Piece::Region(..) | Piece::Elem(_) => used.extend(piece.regs()),
                        }
                    }
                }
                Inst::Move { dst, src } => {
                    if plan[*src as usize] {
                        if !plan[*dst as usize] {
                            return fail(ctx(format!("move %{dst} = %{src}: plan register moved into a non-plan register")));
                        }
                        consumed.push(*src);
                    }
                }
                Inst::Tail { args } | Inst::TailEnv { args, .. } => {
                    for (i, a) in args.iter().enumerate() {
                        if plan[*a as usize] {
                            if !plan[i] {
                                return fail(ctx(format!("tail argument {i} (%{a}) is a plan, parameter %{i} is not")));
                            }
                            consumed.push(*a);
                        }
                    }
                    if let Inst::TailEnv { closure, .. } = inst {
                        used.push(*closure);
                    }
                }
                Inst::Call { dst, func: g, args, .. } | Inst::CallEnv { dst, func: g, args, .. } => {
                    let g = callee(*g);
                    for (i, a) in args.iter().enumerate() {
                        if plan[*a as usize] {
                            if !g.plan_regs[i] {
                                return fail(ctx(format!(
                                    "call of {}: argument {i} (%{a}) is a plan, the callee's parameter is not", g.id
                                )));
                            }
                            consumed.push(*a);
                        }
                    }
                    if g.plan_result && !plan[*dst as usize] {
                        return fail(ctx(format!("call of {}: its plan result %{dst} is not a plan register", g.id)));
                    }
                    if let Inst::CallEnv { closure, .. } = inst {
                        used.push(*closure);
                    }
                }
                Inst::Ret(r) => {
                    if plan[*r as usize] {
                        if !f.plan_result {
                            return fail(ctx(format!("ret %{r}: a plan returned from a function without planresult")));
                        }
                        consumed.push(*r);
                    }
                }
                Inst::Label(_) | Inst::Unreachable | Inst::Raise { .. } | Inst::Fail { .. }
                | Inst::ClearDeclaredError | Inst::PushErrorExit(_) | Inst::PopErrorExit | Inst::Reraise
                | Inst::Jump(_) | Inst::DeclaredErrorEq { .. } | Inst::Int { .. } | Inst::RawInt { .. }
                | Inst::Str { .. } | Inst::Char { .. } | Inst::Bool { .. } | Inst::Unit { .. }
                | Inst::Native { .. } | Inst::FnValue { .. } | Inst::SelfClosure { .. } | Inst::Capture { .. }
                | Inst::Cell { .. } | Inst::StaticGet { .. } => {}
                Inst::CellSet { cell, value } => used.extend([*cell, *value]),
                Inst::StaticSet { value, .. } => used.push(*value),
                Inst::CellGet { cell, .. } | Inst::CellCheck { cell, .. } => used.push(*cell),
                Inst::Closure { captures, .. } => used.extend(captures),
                Inst::Guard { value, .. } | Inst::GuardBool { value } => used.push(*value),
                Inst::Op { args, .. } => used.extend(args),
                Inst::CallValue { callee, args, .. } => {
                    used.push(*callee);
                    used.extend(args);
                }
                Inst::CallMulti { dsts, func: g, args, .. } | Inst::CallEnvMulti { dsts, func: g, args, .. } => {
                    // A companion's own fields are never plans; its
                    // parameters may be (the same plan parameters as every
                    // other lowering variant of its instance).
                    let g = callee(*g);
                    for (i, a) in args.iter().enumerate() {
                        if plan[*a as usize] {
                            if !g.plan_regs[i] {
                                return fail(ctx(format!(
                                    "callmulti of {}: argument {i} (%{a}) is a plan, the callee's parameter is not", g.id
                                )));
                            }
                            consumed.push(*a);
                        }
                    }
                    if let Some(d) = dsts.iter().find(|d| plan[**d as usize]) {
                        return fail(ctx(format!("callmulti result %{d} declared plan")));
                    }
                    if let Inst::CallEnvMulti { closure, .. } = inst {
                        used.push(*closure);
                    }
                }
                Inst::Br { cond, .. } => used.push(*cond),
                Inst::RetMulti(rs) => used.extend(rs),
            }
            if let Some(r) = used.iter().find(|r| plan[**r as usize]) {
                return fail(ctx(format!("plan register %{r} used where an ordinary value is required")));
            }
            consumes.push(consumed);
        }
        check_plan_linearity(f, &consumes).or_else(|m| fail(ctx(m)))?;
    }
    Ok(())
}

/// The linearity half of `validate_plans` (see its doc). CONSUMES holds,
/// per instruction of F, the plan registers it consumes.
fn check_plan_linearity(f: &Function, consumes: &[Vec<Reg>]) -> Result<(), String> {
    if consumes.iter().all(|c| c.is_empty()) {
        return Ok(());
    }
    let n = f.body.len();
    let regs = f.regs as usize;
    // Blocks: a label starts one; a terminator ends one.
    let mut label_index = std::collections::HashMap::new();
    let mut starts = vec![0usize];
    for (i, inst) in f.body.iter().enumerate() {
        if let Inst::Label(l) = inst {
            label_index.insert(*l, i);
            if i != 0 && !starts.contains(&i) {
                starts.push(i);
            }
        }
        if inst.is_terminator() && i + 1 < n && !starts.contains(&(i + 1)) {
            starts.push(i + 1);
        }
    }
    starts.sort_unstable();
    let block_of = |i: usize| starts.partition_point(|s| *s <= i) - 1;
    // The error-exit handler label active at each instruction (pusherrorexit/
    // poperrorexit are emitted lexically nested, codegen::clif's own stack).
    let mut handler: Vec<Option<Label>> = vec![None; n];
    let mut stack: Vec<Label> = Vec::new();
    for (i, inst) in f.body.iter().enumerate() {
        match inst {
            Inst::PushErrorExit(l) => stack.push(*l),
            Inst::PopErrorExit => {
                stack.pop();
            }
            _ => {}
        }
        handler[i] = stack.last().copied();
    }
    let nblocks = starts.len();
    let mut state_in: Vec<Option<Vec<bool>>> = vec![None; nblocks];
    state_in[0] = Some(vec![false; regs]);
    let mut work = vec![0usize];
    let merge = |slot: &mut Option<Vec<bool>>, s: &[bool]| -> bool {
        match slot {
            None => {
                *slot = Some(s.to_vec());
                true
            }
            Some(old) => {
                let mut changed = false;
                for (o, x) in old.iter_mut().zip(s) {
                    if *x && !*o {
                        *o = true;
                        changed = true;
                    }
                }
                changed
            }
        }
    };
    while let Some(b) = work.pop() {
        let mut state = state_in[b].clone().unwrap();
        let start = starts[b];
        let end = if b + 1 < nblocks { starts[b + 1] } else { n };
        let mut fallthrough = true;
        for i in start..end {
            let inst = &f.body[i];
            for r in &consumes[i] {
                if state[*r as usize] {
                    return Err(format!(
                        "plan register %{r} may be consumed twice (instruction {i}: {inst:?})"
                    ));
                }
                state[*r as usize] = true;
            }
            // A failing instruction inside a handler span reaches the
            // handler with whatever it has consumed so far.
            if let Some(l) = handler[i] {
                if let Some(&t) = label_index.get(&l) {
                    let tb = block_of(t);
                    if merge(&mut state_in[tb], &state) {
                        work.push(tb);
                    }
                }
            }
            let defs: Vec<Reg> = match inst {
                Inst::Tail { .. } | Inst::TailEnv { .. } => (0..f.params).collect(),
                Inst::CallMulti { dsts, .. } | Inst::CallEnvMulti { dsts, .. } => dsts.clone(),
                other => def_of(other).into_iter().collect(),
            };
            for d in defs {
                state[d as usize] = false;
            }
            let mut succs: Vec<usize> = Vec::new();
            match inst {
                Inst::Br { then, otherwise, .. } => {
                    for l in [then, otherwise] {
                        succs.push(block_of(label_index[l]));
                    }
                }
                Inst::Jump(l) => succs.push(block_of(label_index[l])),
                Inst::Tail { .. } | Inst::TailEnv { .. } => succs.push(0),
                _ => {}
            }
            if inst.is_terminator() {
                fallthrough = false;
            }
            for s in succs {
                if merge(&mut state_in[s], &state) {
                    work.push(s);
                }
            }
        }
        if fallthrough && b + 1 < nblocks && merge(&mut state_in[b + 1], &state) {
            work.push(b + 1);
        }
    }
    Ok(())
}

/// The one register INST defines, if any (Tail/CallMulti handled by the
/// caller).
fn def_of(inst: &Inst) -> Option<Reg> {
    match inst {
        Inst::Int { dst, .. } | Inst::RawInt { dst, .. } | Inst::Str { dst, .. } | Inst::Char { dst, .. }
        | Inst::Bool { dst, .. } | Inst::Unit { dst } | Inst::Native { dst, .. } | Inst::FnValue { dst, .. }
        | Inst::SelfClosure { dst } | Inst::Capture { dst, .. } | Inst::Move { dst, .. } | Inst::Cell { dst }
        | Inst::CellGet { dst, .. } | Inst::CellCheck { dst, .. } | Inst::Closure { dst, .. }
        | Inst::Op { dst, .. } | Inst::Call { dst, .. } | Inst::CallEnv { dst, .. } | Inst::CallValue { dst, .. }
        | Inst::DeclaredErrorEq { dst, .. } | Inst::Construct { dst, .. } => Some(*dst),
        _ => None,
    }
}

#[cfg(test)]
mod effect_tests {
    use super::*;

    fn function(effect_body: &str) -> String {
        format!("func 1 \"f\" params=0 env=0 regs=3 pnames=\"\" captures=0 rawregs=\"\"\n{effect_body}    ret %0\nend\n")
    }

    fn with_callee(body: &str, enabled: bool) -> Program {
        let flag = if enabled { 1 } else { 0 };
        let text = format!(
            "nir 1 call-effects={flag}\n\nfunc 0 \"<program>\" params=0 env=0 regs=1 pnames=\"\" captures=0 rawregs=\"\"\n    %0 = call 1\n    ret %0\nend\n{}",
            function(body)
        );
        parse(&text).unwrap()
    }

    #[test]
    fn call_effects_independence_matrix() {
        let cases = [
            ("    %0 = unit\n", (false, false)),
            ("    %1 = int 1\n    %2 = int 0\n    %0 = op imod %1 %2\n", (true, false)),
            ("    %1 = unit\n    %0 = op mkok %1\n", (false, true)),
            ("    %1 = str \"x\"\n    %2 = int 0\n    %0 = op substr %1 %2 %2\n", (true, true)),
        ];
        for (body, expected) in cases {
            let p = with_callee(body, true);
            assert_eq!((p.functions[1].may_error, p.functions[1].may_gc), expected);
            match &p.functions[0].body[0] {
                Inst::Call { may_error, may_gc, .. } => assert_eq!((*may_error, *may_gc), expected),
                _ => panic!("expected call"),
            }
        }
    }

    #[test]
    fn call_effects_propagate_transitively_and_recursively() {
        let text = concat!(
            "nir 1\n\n",
            "func 0 \"<program>\" params=0 env=0 regs=1 pnames=\"\" captures=0 rawregs=\"\"\n",
            "    %0 = call 1\n    ret %0\nend\n",
            "func 1 \"a\" params=0 env=0 regs=1 pnames=\"\" captures=0 rawregs=\"\"\n",
            "    %0 = call 2\n    ret %0\nend\n",
            "func 2 \"cycle\" params=0 env=0 regs=3 pnames=\"\" captures=0 rawregs=\"\"\n",
            "    %0 = unit\n    %1 = op mkok %0\n    %2 = call 2\n    ret %2\nend\n"
        );
        let p = parse(text).unwrap();
        assert!(p.functions.iter().all(|f| f.may_gc));
        assert!(p.functions.iter().all(|f| !f.may_error));
    }

    #[test]
    fn call_effects_off_keeps_call_bookkeeping_conservative() {
        let p = with_callee("    %0 = unit\n", false);
        assert_eq!((p.functions[1].may_error, p.functions[1].may_gc), (false, false));
        match &p.functions[0].body[0] {
            Inst::Call { may_error, may_gc, .. } => assert!(*may_error && *may_gc),
            _ => panic!("expected call"),
        }
    }
}
#[cfg(test)]
mod plan_tests {
    use super::*;

    fn message(r: Result<Program, NirError>) -> String {
        match r {
            Ok(_) => panic!("expected invalid NIR"),
            Err(e) => e.message,
        }
    }

    fn program(header: &str, body: &str) -> Result<Program, NirError> {
        parse(&format!(
            "nir 1\n\nfunc 0 \"<program>\" params=0 env=0 regs=8 pnames=\"\" captures=0{header}\n{body}\nend\n"
        ))
    }

    #[test]
    fn construct_parses_every_piece_kind() {
        let p = program(
            " planregs=\"2\"",
            "    %0 = str \"ab\"\n    %1 = int 0\n    %2 = construct str plan %0 region %0 %1 %1\n    %3 = construct str flat %2\n    ret %3",
        )
        .unwrap();
        match &p.functions[0].body[2] {
            Inst::Construct { list, plan, pieces, .. } => {
                assert!(!list && *plan);
                assert_eq!(pieces, &vec![Piece::Span(0), Piece::Region(0, 1, 1)]);
            }
            other => panic!("expected construct, got {other:?}"),
        }
        let l = program("", "    %0 = op listnew\n    %1 = int 1\n    %2 = construct list flat %0 elem %1\n    ret %2").unwrap();
        assert!(matches!(&l.functions[0].body[2], Inst::Construct { list: true, plan: false, .. }));
    }

    #[test]
    fn region_and_elem_pieces_are_family_specific() {
        assert!(program("", "    %0 = op listnew\n    %1 = int 0\n    %2 = construct list flat region %0 %1 %1\n    ret %2").is_err());
        assert!(program("", "    %0 = str \"a\"\n    %2 = construct str flat elem %0\n    ret %2").is_err());
    }

    #[test]
    fn plan_registers_only_reach_plan_positions() {
        let bad_op = program(" planregs=\"1\"", "    %0 = str \"a\"\n    %1 = construct str plan %0 %0\n    %2 = op strlen %1\n    ret %2");
        assert!(message(bad_op).contains("ordinary value"));
        let bad_ret = program(" planregs=\"1\"", "    %0 = str \"a\"\n    %1 = construct str plan %0 %0\n    ret %1");
        assert!(bad_ret.is_err());
        let bad_region = program(" planregs=\"1\"", "    %0 = str \"a\"\n    %1 = construct str plan %0 %0\n    %2 = int 0\n    %3 = construct str flat region %1 %2 %2\n    ret %3");
        assert!(bad_region.is_err());
    }

    #[test]
    fn a_plan_is_consumed_at_most_once_per_path() {
        let twice = program(
            " planregs=\"1\"",
            "    %0 = str \"a\"\n    %1 = construct str plan %0 %0\n    %2 = construct str flat %1\n    %3 = construct str flat %1\n    ret %3",
        );
        assert!(message(twice).contains("consumed twice"));
        let branches = program(
            " planregs=\"1\"",
            "    %0 = str \"a\"\n    %4 = bool true\n    %1 = construct str plan %0 %0\n    br %4 L0 L1\n  label L0\n    %2 = construct str flat %1\n    ret %2\n  label L1\n    %3 = construct str flat %1\n    ret %3",
        );
        assert!(branches.is_ok(), "one consumption on each of two exclusive paths");
    }

    #[test]
    fn a_plan_parameter_is_redefined_by_a_self_tail_call() {
        let text = concat!(
            "nir 1\n\n",
            "func 0 \"<program>\" params=0 env=0 regs=2 pnames=\"\" captures=0\n",
            "    %0 = str \"\"\n    %1 = call 1 %0\n    ret %1\nend\n",
            "func 1 \"f\" params=1 env=0 regs=4 pnames=\"acc\" captures=0 planregs=\"0 2\"\n",
            "    %1 = bool false\n    br %1 L0 L1\n  label L0\n    %3 = construct str flat %0\n    ret %3\n",
            "  label L1\n    %2 = construct str plan %0 %0\n    tail %2\nend\n"
        );
        // %0 is consumed twice by `construct str plan %0 %0` itself.
        assert!(parse(text).is_err());
        let ok = text.replace("construct str plan %0 %0", "construct str plan %0 %3").replace("regs=4", "regs=5");
        let ok = ok.replace("  label L1\n", "  label L1\n    %3 = str \"x\"\n");
        assert!(parse(&ok).is_ok(), "{:?}", parse(&ok).err().map(|e| e.message));
    }
}
