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
    /// `==` of two operands statically UnicodeChar (native/lower.tcl's
    /// NativeCallOp): word equality of the two immediates; never fails.
    CharEq,
    ListNew,
    StrLen,
    Substr,
    StrLower,
    StrCat,
    ListLen,
    ListGet,
    ListAppend,
    /// List -> ImmutableSet, deduplicating by VEq's own rule (MINIMAL-
    /// IMMUTABLE-SET.md's `immutable_set::from_list`): O(n^2), the
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
    /// never for `immutable_set::from_list`'s own generic/dynamically-
    /// dispatched entry (native/lower.tcl's `NativeImpl`).
    SetFromListTotal,
    /// Total membership on an ImmutableSet operand (`immutable_set::contains`):
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
    /// never for `immutable_set::contains`'s own generic/dynamically-
    /// dispatched entry (native/lower.tcl's `NativeImpl`).
    SetContainsTotal,
    MutArrayAllocate,
    MutArrayCapacity,
    MutArrayGet,
    MutArraySet,
    MutArrayCopy,
    MutArrayFreeze,
    /// The *Proven siblings (PROOF-FACT-CENSUS.md G1): the same operation as
    /// `ListGet`, `MutArrayGet`, `MutArraySet`, `Substr`, `MutArrayCopy` and
    /// `MutArrayFreeze` at a call site whose every bounds check
    /// hir/completions.tcl proved can never fail (BoundsProven): the indices
    /// are valid by proof, so there is no comparison, no declared-error
    /// completion and (not in `op_may_error`) no error exit. native/lower.tcl
    /// emits one only where that proof holds -- never for a call that merely
    /// handles or declares the error -- and every other (type/kind) check of
    /// the operation is still its own guard, emitted before. Same precedent as
    /// `SetContainsTotal`: the distinction is per opcode, because `op_may_error`
    /// is keyed by opcode.
    ListGetProven,
    MutArrayGetProven,
    MutArraySetProven,
    SubstrProven,
    MutArrayCopyProven,
    MutArrayFreezeProven,
    IsInt,
    IsStr,
    IsList,
    IsMutArray,
    IsOk,
    IsError,
    ResultValue,
    ResultError,
    /// The Unicode scalar value of a UnicodeChar operand, as an Int
    /// (char::scalar_value, core/unicodechar.tcl): total, never
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
    /// `str::char_at(S, I)` (core/strings.tcl): the Unicode scalar at
    /// character index I as a UnicodeChar immediate, never allocating. The
    /// checked form fails with the declared builtin error IndexNotFound for
    /// any I outside 0..chars (a BigInt included); the proven sibling is
    /// emitted only where hir/completions.tcl proved the index in range.
    /// An ASCII String is a byte read; otherwise the scalar is located by
    /// decoding forward from byte 0 (the seek `Substr` pays, counted in
    /// `utf8SeekBytes`).
    StrCharAt,
    StrCharAtProven,
    /// `argv()` (core/process.tcl, ARGV.md): the process argument snapshot
    /// of this run as a List of Strings -- every argument validated as UTF-8
    /// *by this operation* (never earlier), all or nothing. Takes no
    /// operands. When any argument is not valid UTF-8 it fails with the
    /// declared builtin error InvalidArgumentEncoding: it records the
    /// builtin error's NIR id (runtime/error.rs's `BUILTIN_ERROR_ID_BASE`
    /// plus the error's index) as the pending declared error, exactly as a
    /// `faildeclared` of that id does, so an enclosing `handle` matches it
    /// like any other declared error.
    Argv,
    /// `linux::abi::syscall` (core/linuxabi.tcl, LINUX-X86-64-SYSCALL.md):
    /// the raw Linux x86-64 kernel transition. Seven operands, the Ints
    /// (each proven in -2^63..2^63-1: an abi::x86_64::Register64's word)
    /// for RAX (the syscall number) and RDI, RSI, RDX, R10, R8, R9
    /// (arguments 1-6; native/lower.tcl passes the Int 0 for an argument
    /// the source omitted). The result is the raw RAX afterwards, read as a
    /// signed 64-bit Int -- no errno or other interpretation. Executes the
    /// `syscall` instruction itself (runtime/syscall.rs); never removed,
    /// merged or reordered (a helper call); Linux x86-64 targets only.
    SyscallLinuxX86_64,
    /// `byte_store::from_list` (core/bytestore.tcl, ABI-BYTES.md): the owned
    /// byte storage holding the bytes of a List of Ints in 0..255, eagerly
    /// copied (one allocation, or the shared static empty storage; a
    /// non-byte element is TYPE). One operand, the List.
    BytesFromList,
    /// `byte_store::byte_count`: the exact byte count of a storage, a small Int.
    /// One operand; TYPE if it is not a byte storage.
    BytesLen,
    /// `abi::x86_64::from_bytes`, the raw address bridge: the machine
    /// address of the first payload byte of a storage, as a small Int. One
    /// operand; never allocates. The address is meaningful only while the
    /// storage is live: native/lower.tcl pairs every use of it in a syscall
    /// with a `keepalive` of the storage after that syscall.
    BytesAddr,
    /// `mutable_byte_store::zeroed` (core/bytestore.tcl, MUTABLE-BYTES.md): a
    /// fresh writable storage of N zero bytes (one allocation; the shared
    /// static empty storage for N = 0). One operand, the Int N (RANGE outside
    /// 0..2^62-1).
    MBytesNew,
    /// `mutable_byte_store::from_storage`: a fresh writable copy of an immutable byte
    /// storage. One operand.
    MBytesFrom,
    /// `mutable_byte_store::count`: the fixed byte count of a writable
    /// storage, a small Int. One operand; TYPE unless it is a writable storage.
    MBytesLen,
    /// `mutable_byte_store::replace`: a fresh writable storage equal to the first
    /// operand with byte I (second operand, RANGE if not a valid index)
    /// replaced by the third (TYPE unless an Int in 0..255). The first
    /// operand is cloned and the clone written; it is never written itself.
    MBytesSet,
    /// `mutable_byte_store::detach`: a fresh writable storage equal to the
    /// operand (the "detach" before a writable foreign access).
    MBytesClone,
    /// `mutable_byte_store::freeze`: a fresh immutable byte storage holding the
    /// operand's current bytes (the shared static empty storage for none).
    MBytesFreeze,
    /// `mutable_byte_store::freeze_prefix`: the first N bytes (second operand, RANGE
    /// unless 0 <= N <= the length) of the first, as an immutable storage.
    MBytesFreezePrefix,
    /// `abi::x86_64::from_mutable_bytes`, the WRITABLE raw address bridge: the
    /// machine address of the first payload byte of a writable storage, as a
    /// small Int. One operand, which must be a KIND_MUTBYTES storage (TYPE
    /// otherwise: the readable and writable kinds are never interchanged).
    /// Never allocates. Like `bytesaddr`, every use of it in a syscall is
    /// paired by native/lower.tcl with a `keepalive` of the storage after it.
    MBytesAddr,
    /// `%u = op keepalive %b`: a use of %b that is never removed and does
    /// nothing, so %b stays a GC root until here. Result unit.
    KeepAlive,
    /// Coroutines (COROUTINES.md, runtime/coroutine.rs). `cocreate %t`: a
    /// fresh coroutine handle around the zero-argument Block %t (allocates).
    /// `costart %h`: the eager start, the body to its first outward boundary
    /// -- its value, or a failure with the body's unhandled error.
    /// `coresume %h %m` / `coresume0 %h`: the next segment, delivering %m (or
    /// unit) to the suspended yield; a terminal handle returns its cached
    /// result or raises its cached failure again. `coyield %v`: suspends the
    /// running coroutine with outward value %v; the result is the resume
    /// message. `codone %h`: Bool, the handle is completed or failed.
    /// `corelease %h`: %h's handle is dead from here (native/lower.tcl emits
    /// it after the last use the affine analysis found): frees what the
    /// coroutine holds, its stack first; result unit, never fails or
    /// allocates. Every one but `codone` and `corelease` is a GC safepoint
    /// (op_may_allocate): a segment runs
    /// arbitrary code, and while a coroutine is suspended others run and may
    /// collect, so a call that may suspend must have its roots in a stack map.
    CoCreate,
    CoStart,
    CoResume,
    CoResume0,
    CoYield,
    CoDone,
    CoRelease,
    /// `affinedrop %v %d`: the owner of the affine aggregate %v is dead from
    /// here (AFFINE-VALUES.md; native/lower.tcl emits it where the affine
    /// analysis put a release): releases every affine value %v owns, by the
    /// static drop descriptor %d (a String, runtime/affine.rs). Result unit;
    /// never fails or allocates (no safepoint), like `corelease`.
    AffineDrop,
    /// MutableVector (MUTABLE-VECTOR.md, runtime/mutvec.rs). A vector is a
    /// header over a copy-on-write backing; every mutation changes the
    /// header in place (its register never changes).
    ///   `mvfromlist %xs`       a fresh vector of a List's elements (allocates)
    ///   `mvlen %v`, `mvempty %v`  observations (never detach)
    ///   `mvat %v %i`           an element; IndexNotFound
    ///   `mvpush %v %x`         append (detaching a shared backing first)
    ///   `mvpop %v`, `mvtake %v %i`, `mvswap %v %i %x`  removal/exchange,
    ///                          the element moved out; IndexNotFound
    ///   `mvclear %v`           remove every (unrestricted) element
    ///   `mvshare %v %d`        a logical copy by share descriptor %d (a new
    ///                          header on the same backing; allocates)
    ///   `mvtolist %v`          an immutable List snapshot (allocates)
    ///   `mvtakefront %v`       a consuming loop's step (non-empty vector)
    ///   `mvcleardrop %v %d`    clear of affine elements, each dropped by %d
    ///   `mvswapdrop %v %i %x %d`  swap of affine elements; on IndexNotFound
    ///                          the replacement %x is dropped by %d
    /// Push/pop/take/swap/clear grow or detach the backing with Rust
    /// allocations only: no Botlish allocation, so no safepoint.
    MvFromList,
    MvLen,
    MvEmpty,
    MvAt,
    MvPush,
    MvPop,
    MvTake,
    MvSwap,
    MvClear,
    MvShare,
    MvToList,
    MvTakeFront,
    MvClearDrop,
    MvSwapDrop,
    /// `contextroot %h`: %h (a MutableVector header just installed in the
    /// context area, MUTABLE-VECTOR.md) is a GC root for the rest of the
    /// run. Never fails or allocates; result unit.
    ContextRoot,
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
    /// ShortString1 (SHORT-STRING.md): a String the compiler proved has at
    /// most one character, carried as one signed i64 -- `-1` is the empty
    /// String, `0..=0x10FFFF` (never a surrogate) is the one Unicode scalar
    /// value of a one-character String; U+0000 is `0`, never Empty. A
    /// ShortString1 register is a distinct physical kind (`shortregs=`):
    /// not a tagged Value (so never a GC root) and not a RawInt (so it can
    /// never be an operand of `riadd` and friends), even though both lower
    /// to an i64. These ops are its only transitions and consumers.
    ///
    /// Tagged String -> ShortString1: total and non-allocating. The operand
    /// is a String lowering already proved has at most one character, so no
    /// length check is performed (a debug build asserts it).
    StrToShort,
    /// ShortString1 -> tagged String: allocates the one-character (or empty)
    /// String the scalar stands for.
    ShortToStr,
    /// The character count of a ShortString1: 0 for Empty, 1 for One. The
    /// result is a raw Int.
    ShortLen,
    /// Equality of two ShortString1 values: scalar equality (Empty == Empty,
    /// One(a) == One(a)), a tagged Bool.
    ShortEq,
    /// The characters base[start..end) of a String (tagged base, start and
    /// end), as a ShortString1. Lowering emits it only after `regioncheck`
    /// validated the bounds and the width proof (end - start <= 1) holds, so
    /// it never fails.
    StrSliceShort,
    /// Packed ASCII (SHORT-STRING.md, tier A): a String the compiler proved
    /// is ASCII with at most eight characters, carried as one i64 in which
    /// byte i (bits 8i..8i+7) is `0x80 | c` for the character c at index i
    /// and 0 past the end. The high bit of each byte is the *presence* flag,
    /// so the word is canonical (equality is word equality), the empty
    /// String is 0, NUL is a present 0x80, the length is
    /// `(71 - clz(w)) >> 3`, and unpacking to string bytes is `w & 0x7f..7f`.
    /// An Ascii register is a distinct physical kind (`asciiregs=`).
    ///
    /// Tagged String -> Ascii: non-allocating; the operand is a String
    /// lowering already proved ASCII with at most eight characters.
    StrToAscii,
    /// Ascii -> tagged String: allocates the String the word stands for.
    AsciiToStr,
    /// The character count of an Ascii word, a raw Int in 0..=8.
    AsciiLen,
    /// Equality of two Ascii words: word equality, a tagged Bool.
    AsciiEq,
    /// Ascii -> ShortString1 for a word of at most one character (the
    /// caller's proof): 0 -> Empty (-1), else the character's scalar.
    AsciiToShort,
    /// Equality of an Ascii word (operand 0) and a ShortString1 (operand
    /// 1): true only when they are the same String (a scalar above 0x7F, or
    /// an Ascii word longer than one character, is simply unequal), a tagged
    /// Bool.
    AsciiShortEq,
}

/// The physical representation class of a register (`rawregs=`/`shortregs=`
/// declare the non-tagged ones). Distinct kinds are never interchangeable
/// even when two share a machine type.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum RegKind {
    Tagged,
    Raw,
    Short,
    Ascii,
}

impl RegKind {
    pub fn name(self) -> &'static str {
        match self {
            RegKind::Tagged => "tagged",
            RegKind::Raw => "raw",
            RegKind::Short => "short",
            RegKind::Ascii => "ascii",
        }
    }
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
            "chareq" => CharEq,
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
            "listgetproven" => ListGetProven,
            "mutarraygetproven" => MutArrayGetProven,
            "mutarraysetproven" => MutArraySetProven,
            "substrproven" => SubstrProven,
            "mutarraycopyproven" => MutArrayCopyProven,
            "mutarrayfreezeproven" => MutArrayFreezeProven,
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
            "strcharat" => StrCharAt,
            "strcharatproven" => StrCharAtProven,
            "argv" => Argv,
            "syscall_linux_x86_64" => SyscallLinuxX86_64,
            "bytesfromlist" => BytesFromList,
            "byteslen" => BytesLen,
            "bytesaddr" => BytesAddr,
            "keepalive" => KeepAlive,
            "cocreate" => CoCreate,
            "costart" => CoStart,
            "coresume" => CoResume,
            "coresume0" => CoResume0,
            "coyield" => CoYield,
            "codone" => CoDone,
            "corelease" => CoRelease,
            "affinedrop" => AffineDrop,
            "mvfromlist" => MvFromList,
            "mvlen" => MvLen,
            "mvempty" => MvEmpty,
            "mvat" => MvAt,
            "mvpush" => MvPush,
            "mvpop" => MvPop,
            "mvtake" => MvTake,
            "mvswap" => MvSwap,
            "mvclear" => MvClear,
            "mvshare" => MvShare,
            "mvtolist" => MvToList,
            "mvtakefront" => MvTakeFront,
            "mvcleardrop" => MvClearDrop,
            "mvswapdrop" => MvSwapDrop,
            "contextroot" => ContextRoot,
            "mbytesnew" => MBytesNew,
            "mbytesfrom" => MBytesFrom,
            "mbyteslen" => MBytesLen,
            "mbytesset" => MBytesSet,
            "mbytesclone" => MBytesClone,
            "mbytesfreeze" => MBytesFreeze,
            "mbytesfreezeprefix" => MBytesFreezePrefix,
            "mbytesaddr" => MBytesAddr,
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
            "strtoshort" => StrToShort,
            "shorttostr" => ShortToStr,
            "shortlen" => ShortLen,
            "shorteq" => ShortEq,
            "strsliceshort" => StrSliceShort,
            "strtoascii" => StrToAscii,
            "asciitostr" => AsciiToStr,
            "asciilen" => AsciiLen,
            "asciieq" => AsciiEq,
            "asciitoshort" => AsciiToShort,
            "asciishorteq" => AsciiShortEq,
            _ => return None,
        })
    }

    /// Number of operands, or None for any.
    pub fn arity(self) -> Option<usize> {
        use OpCode::*;
        match self {
            ListNew => None,
            Argv => Some(0),
            SyscallLinuxX86_64 => Some(7),
            StrLen | StrLower | ListLen | MutArrayAllocate | MutArrayCapacity | IsInt | IsStr | IsList | IsMutArray
            | IsOk | IsError | ResultValue | ResultError | MkOk | MkError | Hash | RBox | RUnbox
            | StrByteLen | StrUtf8Bytes | StrIsTclAlpha | StrIsTclAlnum | CharCodepoint | SetFromList
            | SetFromListTotal | StrToShort | ShortToStr | ShortLen | StrToAscii | AsciiToStr | AsciiLen
            | AsciiToShort | BytesFromList | BytesLen | BytesAddr | KeepAlive | MBytesNew | MBytesFrom | MBytesLen
            | MBytesClone | MBytesFreeze | MBytesAddr | CoCreate | CoStart | CoResume0 | CoYield | CoDone
            | CoRelease | MvFromList | MvLen | MvEmpty | MvPop | MvClear | MvToList | MvTakeFront | ContextRoot => Some(1),
            Substr | SubstrProven | MutArraySet | MutArraySetProven | MBytesSet | RegionCheck | StrRegionIsTclAlpha | StrRegionIsTclAlnum | StrSliceShort
            | MvSwap => Some(3),
            RegionEq | MvSwapDrop => Some(4),
            MutArrayCopy | MutArrayCopyProven => Some(5),
            _ => Some(2),
        }
    }

    /// 1 if OP's result is a raw (untagged) machine integer, not a Value.
    pub fn raw_result(self) -> bool {
        matches!(self, OpCode::RUnbox | OpCode::RIAdd | OpCode::RISub | OpCode::RIMul
            | OpCode::RIShr | OpCode::RIShl | OpCode::ShortLen | OpCode::AsciiLen)
    }

    /// 1 if OP's operands are raw (untagged) machine integers, not Values.
    pub fn raw_operands(self) -> bool {
        use OpCode::*;
        matches!(self, RBox | RIAdd | RISub | RIMul | RILt | RILe | RIGt | RIGe | RIEq | RIShr | RIShl)
    }

    /// The physical kind the operand at position I of OP must have.
    pub fn operand_kind_at(self, i: usize) -> RegKind {
        use OpCode::*;
        if self.raw_operands() {
            RegKind::Raw
        } else if matches!(self, ShortToStr | ShortLen | ShortEq) {
            RegKind::Short
        } else if matches!(self, AsciiToStr | AsciiLen | AsciiEq | AsciiToShort) {
            RegKind::Ascii
        } else if matches!(self, AsciiShortEq) {
            if i == 0 { RegKind::Ascii } else { RegKind::Short }
        } else {
            RegKind::Tagged
        }
    }

    /// The physical kind of OP's result.
    pub fn result_kind(self) -> RegKind {
        use OpCode::*;
        if self.raw_result() {
            RegKind::Raw
        } else if matches!(self, StrToShort | StrSliceShort | AsciiToShort) {
            RegKind::Short
        } else if matches!(self, StrToAscii) {
            RegKind::Ascii
        } else {
            RegKind::Tagged
        }
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
    /// A ShortString1 constant (`shortlit N`): -1 is the empty String, N in
    /// 0..=0x10FFFF (never a surrogate) the one-character String of that
    /// Unicode scalar value. U+0000 is `shortlit 0`, never Empty.
    ShortLit { dst: Reg, value: i64 },
    /// A packed-ASCII constant (`asciilit W`): W is the canonical word (see
    /// `OpCode::StrToAscii`), printed as a signed i64.
    AsciiLit { dst: Reg, value: i64 },
    Str { dst: Reg, text: String },
    /// A static byte-storage constant (`bytes "HEX"`): the bytes of lowercase
    /// hexadecimal text HEX (two digits per byte), a program-lifetime object
    /// installed at startup (never collected, never allocated at run time).
    /// native/lower.tcl emits it for an `abi::bytes::from_list` call whose every byte is
    /// known at compile time (ABI-BYTES.md).
    Bytes { dst: Reg, bytes: Vec<u8> },
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
    /// function alike, never routed through Capture. Emitted for
    /// every reference to a module-static binding, never only the function
    /// that first computes its value.
    StaticGet { dst: Reg, index: u32 },
    /// Writes VALUE into module-static slot INDEX: emitted once, at the
    /// exact point the binding's own initializer expression finishes
    /// evaluating (module initialization order, MODULE-STATIC-RETAINED-
    /// VALUES.md) -- never by any other instruction, and never read back by
    /// the same function through anything but a later StaticGet.
    StaticSet { index: u32, value: Reg },
    /// Reads the 64-bit word at byte OFFSET of the program's fixed context
    /// area (CONTEXTS.md): one scalar leaf of an installed context, a tagged
    /// immediate (small Int, Bool, Unit or UnicodeChar -- never a heap
    /// pointer, which is what makes the area need no GC root). The area is
    /// one writable data symbol of the program (`Program::context_bytes`),
    /// addressed directly: no Vm field, no lookup, no hidden argument.
    ContextLoad { dst: Reg, offset: u32 },
    /// Writes VALUE (such an immediate) to byte OFFSET of the context area:
    /// a `with context` installation, emitted only by the program function.
    ContextStore { offset: u32, value: Reg },
    Move { dst: Reg, src: Reg },
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
    /// ceiling eager str::concat/list::append also enforce).
    Construct { dst: Reg, list: bool, plan: bool, pieces: Vec<Piece> },
    /// `%d = structnew SHAPE %f0 %f1 ...` (STRUCTS.md): a struct value of the
    /// program's shape number SHAPE (a `shape` declaration) whose fields are
    /// the registers, exactly one per field of the shape and in the shape's
    /// SLOT order -- the lowering has already evaluated every field
    /// expression, in source order, before this instruction, so no partially
    /// initialized struct is ever observable. A possible allocation (GC
    /// safepoint); never fails. The struct object stores only its shape number
    /// and the field values: no names, no static types.
    StructNew { dst: Reg, shape: u32, fields: Vec<Reg> },
    /// `%d = structget SLOT %v`: field SLOT of the struct value %v. The slot
    /// is a constant the lowering resolved from the receiver's statically
    /// known shape; there is no lookup by name, and no check: %v is proven to
    /// be a struct whose shape has that slot. Total, never allocates.
    StructGet { dst: Reg, slot: u32, value: Reg },
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
    /// Raw Int ABI (RAW-INT-ABI.md): parameter positions (index < params,
    /// never the closure) whose *physical* incoming argument is a raw signed
    /// machine integer rather than a tagged Value (`rawparams=` header
    /// attribute). native/lower.tcl plans this once per exact closed
    /// instance from proven small Ranges; every position is also declared in
    /// `raw_regs`, and no prologue unboxing happens for it. Always
    /// `params` entries long. All false for an ordinary (tagged-ABI)
    /// function.
    pub raw_params: Vec<bool>,
    /// Whether the successful result is a raw signed machine integer
    /// (`rawresult=1`): `ret` returns a raw register. Errors are never
    /// encoded in the integer: a function that `may_error` returns the raw
    /// value together with a second status word (see
    /// codegen::clif's `physical_results`), one that cannot fail returns the
    /// bare integer.
    pub raw_result: bool,
    /// Registers native/lower.tcl declares ShortString1 (`shortregs=`,
    /// SHORT-STRING.md): a String proved to have at most one character,
    /// carried as one i64 (-1 Empty, else the scalar value). A distinct
    /// kind from `raw_regs` (RawInt) although both are non-root i64s: no
    /// register is in both, and the validator never lets one stand for the
    /// other. A parameter register declared here is defined short on entry.
    pub short_regs: Vec<bool>,
    /// ShortString1 ABI (`shortparams=`): parameter positions whose
    /// physical incoming argument is a ShortString1 scalar, every one also
    /// in `short_regs`. Always `params` entries long.
    pub short_params: Vec<bool>,
    /// Whether the successful result is a ShortString1 (`shortresult=1`).
    /// Like a raw result, errors never use the scalar: a function that
    /// `may_error` returns (value, status).
    pub short_result: bool,
    /// Registers declared packed ASCII (`asciiregs=`, SHORT-STRING.md tier
    /// A): a String proved ASCII with at most eight characters, one i64 in
    /// the canonical packed form. A third physical kind, disjoint from
    /// `raw_regs` and `short_regs`.
    pub ascii_regs: Vec<bool>,
    /// Packed-ASCII ABI (`asciiparams=`): parameter positions whose incoming
    /// argument is a packed word, every one also in `ascii_regs`.
    pub ascii_params: Vec<bool>,
    /// Whether the successful result is a packed word (`asciiresult=1`);
    /// like the other scalar results, a function that `may_error` returns
    /// (value, status).
    pub ascii_result: bool,
    /// Registers that hold an unboxed machine scalar rather than a tagged
    /// Value, of any physical kind (raw, short or ascii): never GC
    /// roots, never stored to the shadow stack. Derived once at parse time;
    /// codegen and root analysis read this, never the two declarations.
    pub scalar_regs: Vec<bool>,
}

impl Function {
    /// The physical kind of register R.
    pub fn kind_of(&self, r: Reg) -> RegKind {
        if self.raw_regs[r as usize] {
            RegKind::Raw
        } else if self.short_regs[r as usize] {
            RegKind::Short
        } else if self.ascii_regs[r as usize] {
            RegKind::Ascii
        } else {
            RegKind::Tagged
        }
    }

    /// Whether this function uses the packed-ASCII ABI anywhere.
    pub fn has_ascii_abi(&self) -> bool {
        self.ascii_result || self.ascii_params.iter().any(|b| *b)
    }

    /// Whether the successful result is an unboxed scalar of any kind (a
    /// function that can fail then returns it with a status word).
    pub fn scalar_result(&self) -> bool {
        self.raw_result || self.short_result || self.ascii_result
    }

    /// Whether this function uses the ShortString1 ABI anywhere.
    pub fn has_short_abi(&self) -> bool {
        self.short_result || self.short_params.iter().any(|b| *b)
    }

    /// Whether this function uses a scalar (raw Int or ShortString1) calling
    /// convention anywhere: such a function has no Block value and no
    /// dynamic caller.
    pub fn has_scalar_abi(&self) -> bool {
        self.has_raw_abi() || self.has_short_abi() || self.has_ascii_abi()
    }

    /// The name of the scalar ABI this function uses (for diagnostics).
    pub fn scalar_abi_name(&self) -> &'static str {
        if self.has_raw_abi() {
            "raw Int ABI"
        } else if self.has_short_abi() {
            "ShortString1 ABI"
        } else {
            "packed ASCII ABI"
        }
    }

    /// The physical kind of the incoming argument at parameter position I.
    pub fn param_kind(&self, i: usize) -> RegKind {
        if self.raw_params[i] {
            RegKind::Raw
        } else if self.short_params[i] {
            RegKind::Short
        } else if self.ascii_params[i] {
            RegKind::Ascii
        } else {
            RegKind::Tagged
        }
    }

    /// The physical kind of the successful result.
    pub fn result_kind(&self) -> RegKind {
        if self.raw_result {
            RegKind::Raw
        } else if self.short_result {
            RegKind::Short
        } else if self.ascii_result {
            RegKind::Ascii
        } else {
            RegKind::Tagged
        }
    }

    /// Whether this function uses the raw Int ABI anywhere (a raw parameter
    /// or a raw result): such a function has no Block value and no generic
    /// dispatch path -- native/lower.tcl plans it only for an exact closed
    /// instance -- so `fnvalue`/`closure` of it is rejected by `validate`.
    pub fn has_raw_abi(&self) -> bool {
        self.raw_result || self.raw_params.iter().any(|b| *b)
    }
}

pub struct NativeDecl {
    pub name: String,
    pub arity: Option<usize>,
    pub params: Vec<Option<Kind>>,
    pub op: OpCode,
}

/// A struct shape declaration (`shape N anon fields="a b"` / `shape N named
/// "Name" fields="a b"`): static program metadata the runtime keeps once
/// per shape (runtime::vm::ShapeInfo), never per object. An anonymous
/// shape's fields are its canonical (sorted) field set; a named shape's are
/// its declaration's slot order. Shape numbers are dense, in order. A named
/// shape may carry `opaque=1` (the declaration is an `opaque struct`,
/// OPAQUE-STRUCTS.md): a rendering fact only, see `ShapeInfo::opaque`.
pub struct ShapeDecl {
    pub name: Option<String>,
    pub fields: Vec<String>,
    pub opaque: bool,
}

/// One statically assigned context slot (`context N "ID" offset=O words=W
/// fields="..."`, CONTEXTS.md): the installed value of context-struct ID
/// lives, flattened to W scalar words in FIELDS' order (dotted paths through
/// nested structs), at byte offset O of the context area. Program metadata
/// for listings and validation; codegen reads only offsets.
pub struct ContextDecl {
    pub name: String,
    pub offset: u32,
    pub words: u32,
    pub fields: Vec<String>,
}

pub struct Program {
    pub natives: Vec<NativeDecl>,
    pub shapes: Vec<ShapeDecl>,
    pub functions: Vec<Function>,
    /// The size in bytes of the program's context area (the header's
    /// `contexts=N`, CONTEXTS.md): one zero-initialized, 8-byte-aligned,
    /// writable, linker-local data object holding every context slot. Zero
    /// for a program without contexts (no data object is emitted).
    pub context_bytes: u32,
    pub contexts: Vec<ContextDecl>,
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
    let mut program = Program {
        natives: Vec::new(),
        shapes: Vec::new(),
        functions: Vec::new(),
        statics: 0,
        context_bytes: 0,
        contexts: Vec::new(),
    };
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
            program.context_bytes = match kv.get("contexts") {
                Some(v) => v.parse().or_else(|_| p.err("bad contexts size"))?,
                None => 0,
            };
            if program.context_bytes % 8 != 0 {
                return p.err("the context area size must be a multiple of 8 bytes");
            }
            seen_header = true;
            continue;
        }
        let head = word(&tokens[0]).unwrap_or("");
        if current.is_none() {
            match head {
                "native" => program.natives.push(parse_native(&p, &tokens)?),
                "shape" => {
                    let shape = parse_shape(&p, &tokens)?;
                    if shape.0 as usize != program.shapes.len() {
                        return p.err(format!("shape numbers must be dense and in order, got {}", shape.0));
                    }
                    program.shapes.push(shape.1);
                }
                "context" => {
                    let decl = parse_context(&p, &tokens)?;
                    if decl.0 as usize != program.contexts.len() {
                        return p.err(format!("context slot numbers must be dense and in order, got {}", decl.0));
                    }
                    let end = decl.1.offset as u64 + 8 * decl.1.words as u64;
                    if decl.1.offset % 8 != 0 || end > program.context_bytes as u64 {
                        return p.err(format!("context slot {} lies outside the {}-byte context area", decl.0,
                            program.context_bytes));
                    }
                    program.contexts.push(decl.1);
                }
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
                Inst::Guard { .. } | Inst::GuardBool { .. }
                    | Inst::Raise { .. } | Inst::Fail { .. } | Inst::Reraise => local[i].0 = true,
                Inst::Op { op, .. } => {
                    local[i].0 |= op_may_error(*op);
                    local[i].1 |= op_may_allocate(*op);
                }
                Inst::Closure { .. } => local[i].1 = true,
                Inst::StructNew { .. } => local[i].1 = true,
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
    // A raw-result callee (RAW-INT-ABI.md) has no error sentinel in its
    // result word, so its call sites must know exactly whether it can fail
    // (and so whether a status word follows the value): its own settled
    // summary decides that even with call effects disabled, which otherwise
    // forces every call site to check.
    let raw_results: Vec<bool> = program.functions.iter().map(|f| f.scalar_result()).collect();
    for (i, f) in program.functions.iter_mut().enumerate() {
        (f.may_error, f.may_gc) = effects[i];
        for inst in &mut f.body {
            match inst {
                Inst::Call { func, may_error, may_gc, .. }
                    | Inst::CallEnv { func, may_error, may_gc, .. }
                    | Inst::CallMulti { func, may_error, may_gc, .. }
                    | Inst::CallEnvMulti { func, may_error, may_gc, .. } => {
                        (*may_error, *may_gc) = if enabled {
                            effects[*func as usize]
                        } else {
                            (if raw_results[*func as usize] { effects[*func as usize].0 } else { true }, true)
                        };
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

/// `shape N anon fields="a b ..."` or `shape N named "Name" fields="a b ..."`.

/// `context N "ID" offset=O words=W fields="P1 P2 ..."` (CONTEXTS.md).
fn parse_context(p: &Parser, tokens: &[Token]) -> Result<(u32, ContextDecl), NirError> {
    let slot = match tokens.get(1).and_then(word).map(str::parse::<u32>) {
        Some(Ok(n)) => n,
        _ => return p.err("context needs a slot number"),
    };
    let name = match tokens.get(2) {
        Some(Token::Quoted(q)) => q.clone(),
        _ => return p.err("context needs a quoted type identity"),
    };
    let kv = pairs(tokens);
    let number = |key: &str| -> Result<u32, NirError> {
        match kv.get(key).map(|v| v.parse::<u32>()) {
            Some(Ok(n)) => Ok(n),
            _ => p.err(format!("context needs {key}=N")),
        }
    };
    let offset = number("offset")?;
    let words = number("words")?;
    let fields: Vec<String> = kv.get("fields").map(|f| f.split_whitespace().map(String::from).collect()).unwrap_or_default();
    if words == 0 || fields.len() != words as usize {
        return p.err(format!("context {name} needs one field path per word ({words} words)"));
    }
    Ok((slot, ContextDecl { name, offset, words, fields }))
}

fn parse_shape(p: &Parser, tokens: &[Token]) -> Result<(u32, ShapeDecl), NirError> {
    let Some(index) = tokens.get(1).and_then(word).and_then(|w| w.parse::<u32>().ok()) else {
        return p.err("shape needs a number");
    };
    let (name, _next) = match tokens.get(2).and_then(word) {
        Some("anon") => (None, 3),
        Some("named") => match tokens.get(3) {
            Some(Token::Quoted(name)) if !name.is_empty() => (Some(name.clone()), 4),
            _ => return p.err("a named shape needs a quoted declaration name"),
        },
        _ => return p.err("shape must be anon or named"),
    };
    let kv = pairs(tokens);
    let Some(fields) = kv.get("fields") else { return p.err("shape needs fields=") };
    let fields: Vec<String> = fields.split_whitespace().map(str::to_string).collect();
    let mut seen = HashSet::new();
    for f in &fields {
        if !seen.insert(f) {
            return p.err(format!("shape field {f} is declared twice"));
        }
    }
    if name.is_none() {
        let mut sorted = fields.clone();
        sorted.sort();
        if sorted != fields {
            return p.err("an anonymous shape's fields must be in canonical (sorted) order");
        }
    }
    let opaque = match kv.get("opaque").map(String::as_str) {
        None | Some("0") => false,
        Some("1") => true,
        Some(_) => return p.err("shape opaque= must be 0 or 1"),
    };
    if opaque && name.is_none() {
        return p.err("an anonymous shape cannot be opaque");
    }
    Ok((index, ShapeDecl { name, fields, opaque }))
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
    let params = num("params")?;
    let mut raw_params = vec![false; params as usize];
    if let Some(list) = kv.get("rawparams") {
        for tok in list.split_whitespace() {
            let r: usize = tok.parse().map_err(|_| ())
                .and_then(|r: usize| if r < params as usize { Ok(r) } else { Err(()) })
                .or_else(|_| p.err::<usize>(format!("bad rawparams position {tok}")))?;
            raw_params[r] = true;
        }
    }
    let raw_result = kv.get("rawresult").is_some_and(|v| v == "1");
    let mut short_regs = vec![false; regs as usize];
    if let Some(list) = kv.get("shortregs") {
        for tok in list.split_whitespace() {
            let r: usize = tok.parse().map_err(|_| ())
                .and_then(|r: usize| if r < regs as usize { Ok(r) } else { Err(()) })
                .or_else(|_| p.err::<usize>(format!("bad shortregs register {tok}")))?;
            short_regs[r] = true;
        }
    }
    let mut short_params = vec![false; params as usize];
    if let Some(list) = kv.get("shortparams") {
        for tok in list.split_whitespace() {
            let r: usize = tok.parse().map_err(|_| ())
                .and_then(|r: usize| if r < params as usize { Ok(r) } else { Err(()) })
                .or_else(|_| p.err::<usize>(format!("bad shortparams position {tok}")))?;
            short_params[r] = true;
        }
    }
    let short_result = kv.get("shortresult").is_some_and(|v| v == "1");
    let mut ascii_regs = vec![false; regs as usize];
    if let Some(list) = kv.get("asciiregs") {
        for tok in list.split_whitespace() {
            let r: usize = tok.parse().map_err(|_| ())
                .and_then(|r: usize| if r < regs as usize { Ok(r) } else { Err(()) })
                .or_else(|_| p.err::<usize>(format!("bad asciiregs register {tok}")))?;
            ascii_regs[r] = true;
        }
    }
    let mut ascii_params = vec![false; params as usize];
    if let Some(list) = kv.get("asciiparams") {
        for tok in list.split_whitespace() {
            let r: usize = tok.parse().map_err(|_| ())
                .and_then(|r: usize| if r < params as usize { Ok(r) } else { Err(()) })
                .or_else(|_| p.err::<usize>(format!("bad asciiparams position {tok}")))?;
            ascii_params[r] = true;
        }
    }
    let ascii_result = kv.get("asciiresult").is_some_and(|v| v == "1");
    let scalar_regs: Vec<bool> = (0..regs as usize).map(|r| raw_regs[r] || short_regs[r] || ascii_regs[r]).collect();
    Ok(Function {
        id,
        name: name.clone(),
        params,
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
        raw_params,
        raw_result,
        short_regs,
        short_params,
        short_result,
        ascii_regs,
        ascii_params,
        ascii_result,
        scalar_regs,
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
            "shortlit" => {
                let text = tokens.get(3).and_then(word).unwrap_or("");
                let Ok(value) = text.parse::<i64>() else { return p.err("bad shortlit literal") };
                if !(value == -1 || (0..=0x10FFFF).contains(&value)
                    && crate::runtime::value::is_valid_scalar(value as u32)) {
                    return p.err("shortlit must be -1 (Empty) or a Unicode scalar value");
                }
                Inst::ShortLit { dst, value }
            }
            "asciilit" => {
                let text = tokens.get(3).and_then(word).unwrap_or("");
                let Ok(value) = text.parse::<i64>() else { return p.err("bad asciilit literal") };
                if !crate::runtime::value::is_canonical_ascii_word(value as u64) {
                    return p.err("asciilit must be a canonical packed-ASCII word");
                }
                Inst::AsciiLit { dst, value }
            }
            "str" => Inst::Str { dst, text: quoted(3)? },
            "bytes" => {
                let text = quoted(3)?;
                if text.len() % 2 != 0 || !text.bytes().all(|b| b.is_ascii_digit() || (b'a'..=b'f').contains(&b)) {
                    return p.err("bytes must be lowercase hexadecimal text of whole bytes");
                }
                let bytes = (0..text.len() / 2)
                    .map(|i| u8::from_str_radix(&text[2 * i..2 * i + 2], 16).expect("validated hexadecimal"))
                    .collect();
                Inst::Bytes { dst, bytes }
            }
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
            "structnew" => {
                let shape = num(3)?;
                let Some(decl) = program.shapes.get(shape as usize) else {
                    return p.err(format!("structnew of undeclared shape {shape}"));
                };
                let fields = regs_from(4)?;
                if fields.len() != decl.fields.len() {
                    return p.err(format!(
                        "structnew of shape {shape} needs {} field register(s), got {}",
                        decl.fields.len(),
                        fields.len()
                    ));
                }
                Inst::StructNew { dst, shape, fields }
            }
            "structget" => Inst::StructGet { dst, slot: num(3)?, value: reg(4)? },
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
            "contextload" => {
                let offset = num(3)?;
                if offset % 8 != 0 || offset as u64 + 8 > program.context_bytes as u64 {
                    return p.err(format!("bad context offset {offset}"));
                }
                Inst::ContextLoad { dst, offset }
            }
            "move" => Inst::Move { dst, src: reg(3)? },
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
        "staticset" => {
            let index = num(1)?;
            if index >= program.statics {
                return p.err(format!("bad static slot {index}"));
            }
            Inst::StaticSet { index, value: reg(2)? }
        }
        "contextstore" => {
            let offset = num(1)?;
            if offset % 8 != 0 || offset as u64 + 8 > program.context_bytes as u64 {
                return p.err(format!("bad context offset {offset}"));
            }
            Inst::ContextStore { offset, value: reg(2)? }
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
        // The raw Int ABI (RAW-INT-ABI.md) is a calling convention of an
        // ordinary single-result function that is never the program and
        // never a Block value: every raw parameter register is also a
        // declared raw register (it is defined raw on entry), a companion
        // (results != 1) keeps the tagged ABI, and a plan-result function
        // (whose result is a String/List) can have raw parameters but never
        // a raw result.
        if f.has_raw_abi() {
            if f.id == 0 {
                return fail(ctx("the program function cannot use the raw Int ABI".into()));
            }
            if f.results != 1 || (f.raw_result && f.plan_result) {
                return fail(ctx("the raw Int ABI requires an ordinary single-result function".into()));
            }
            if let Some(i) = (0..f.params as usize).find(|i| f.raw_params[*i] && !f.raw_regs[*i]) {
                return fail(ctx(format!("rawparams position {i} is not declared in rawregs")));
            }
        }
        // The ShortString1 ABI (SHORT-STRING.md) has the same discipline: a
        // calling convention of an ordinary single-result function that is
        // never the program and never a Block value, and a register is never
        // both RawInt and ShortString1.
        if f.has_short_abi() {
            if f.id == 0 {
                return fail(ctx("the program function cannot use the ShortString1 ABI".into()));
            }
            if f.results != 1 || (f.short_result && f.plan_result) {
                return fail(ctx("the ShortString1 ABI requires an ordinary single-result function".into()));
            }
            if let Some(i) = (0..f.params as usize).find(|i| f.short_params[*i] && !f.short_regs[*i]) {
                return fail(ctx(format!("shortparams position {i} is not declared in shortregs")));
            }
            if f.raw_result && f.short_result {
                return fail(ctx("a result cannot be both raw and short".into()));
            }
            if let Some(i) = (0..f.params as usize).find(|i| f.short_params[*i] && f.raw_params[*i]) {
                return fail(ctx(format!("parameter {i} is declared both rawparams and shortparams")));
            }
        }
        if let Some(i) = (0..f.params as usize).find(|i| f.short_regs[*i] && !f.short_params[*i]) {
            return fail(ctx(format!("parameter register %{i} is declared short but is not a shortparams position")));
        }
        if let Some(r) = (0..f.regs as usize).find(|r| f.raw_regs[*r] && f.short_regs[*r]) {
            return fail(ctx(format!("register %{r} is declared both raw and short")));
        }
        // The packed-ASCII ABI (tier A): the same discipline again.
        if f.has_ascii_abi() {
            if f.id == 0 {
                return fail(ctx("the program function cannot use the packed ASCII ABI".into()));
            }
            if f.results != 1 || (f.ascii_result && f.plan_result) {
                return fail(ctx("the packed ASCII ABI requires an ordinary single-result function".into()));
            }
            if let Some(i) = (0..f.params as usize).find(|i| f.ascii_params[*i] && !f.ascii_regs[*i]) {
                return fail(ctx(format!("asciiparams position {i} is not declared in asciiregs")));
            }
            if [f.raw_result, f.short_result, f.ascii_result].iter().filter(|b| **b).count() > 1 {
                return fail(ctx("a result cannot be of two scalar kinds".into()));
            }
            if let Some(i) = (0..f.params as usize)
                .find(|i| f.ascii_params[*i] && (f.raw_params[*i] || f.short_params[*i])) {
                return fail(ctx(format!("parameter {i} is declared in two scalar ABIs")));
            }
        }
        if let Some(i) = (0..f.params as usize).find(|i| f.ascii_regs[*i] && !f.ascii_params[*i]) {
            return fail(ctx(format!("parameter register %{i} is declared ascii but is not an asciiparams position")));
        }
        if let Some(r) = (0..f.regs as usize)
            .find(|r| [f.raw_regs[*r], f.short_regs[*r], f.ascii_regs[*r]].iter().filter(|b| **b).count() > 1) {
            return fail(ctx(format!("register %{r} is declared in two scalar kinds")));
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
        let kind = |r: Reg| f.kind_of(r);
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
                | Inst::ShortLit { dst, .. }
                | Inst::AsciiLit { dst, .. }
                | Inst::Str { dst, .. }
                | Inst::Bytes { dst, .. }
                | Inst::Char { dst, .. }
                | Inst::Bool { dst, .. }
                | Inst::Unit { dst }
                | Inst::Native { dst, .. } => used.push(*dst),
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
                // Offsets were checked against the context area at parse time.
                Inst::ContextLoad { dst, .. } => used.push(*dst),
                Inst::FnValue { dst, func: g } => {
                    match func(*g) {
                        Some(g) if g.has_scalar_abi() => {
                            return fail(ctx(format!("fnvalue of {}: it uses the {} and has no Block value", g.id,
                                g.scalar_abi_name())));
                        }
                        Some(g) if !g.env => {}
                        _ => return fail(ctx(format!("fnvalue of {g}: not an environment-free function"))),
                    }
                    used.push(*dst);
                }
                Inst::Move { dst, src } => used.extend([*dst, *src]),
                Inst::StaticSet { value, .. } => used.push(*value),
                Inst::ContextStore { value, .. } => used.push(*value),
                Inst::Closure { dst, func: g, captures } => {
                    match func(*g) {
                        Some(g) if g.has_scalar_abi() => {
                            return fail(ctx(format!("closure of {}: it uses the {} and has no Block value", g.id,
                                g.scalar_abi_name())));
                        }
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
                Inst::StructNew { dst, fields, .. } => {
                    used.push(*dst);
                    used.extend(fields);
                }
                Inst::StructGet { dst, value, .. } => used.extend([*dst, *value]),
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
                Inst::ShortLit { dst, .. } => {
                    if kind(*dst) != RegKind::Short {
                        return fail(ctx(format!("shortlit %{dst}: not declared in shortregs")));
                    }
                }
                Inst::AsciiLit { dst, .. } => {
                    if kind(*dst) != RegKind::Ascii {
                        return fail(ctx(format!("asciilit %{dst}: not declared in asciiregs")));
                    }
                }
                // Call-site agreement with the callee's *physical* signature
                // (RAW-INT-ABI.md, SHORT-STRING.md): argument i has exactly
                // the physical kind of the callee's parameter i, and the
                // destination the kind of the callee's result. A mismatch is
                // a lowering bug, never a silent conversion. Positions past
                // the callee's declared list (a hidden trailing parameter)
                // are ordinary tagged Values.
                Inst::Call { dst, func: g, args, .. } | Inst::CallEnv { dst, func: g, args, .. } => {
                    let callee = func(*g).expect("target checked above");
                    for (i, a) in args.iter().enumerate() {
                        let want = if i < callee.params as usize { callee.param_kind(i) } else { RegKind::Tagged };
                        if kind(*a) != want {
                            return fail(ctx(format!(
                                "call of {g}: argument {i} (%{a}) is {}, but the callee's parameter is {}",
                                kind(*a).name(),
                                want.name()
                            )));
                        }
                    }
                    if kind(*dst) != callee.result_kind() {
                        return fail(ctx(format!(
                            "call of {g}: result %{dst} is {}, but the callee's result is {}",
                            kind(*dst).name(),
                            callee.result_kind().name()
                        )));
                    }
                    if let Inst::CallEnv { closure, .. } = inst {
                        if kind(*closure) != RegKind::Tagged {
                            return fail(ctx(format!("callenv closure %{closure} must be tagged")));
                        }
                    }
                }
                Inst::Ret(r) => {
                    if kind(*r) != f.result_kind() {
                        return fail(ctx(format!(
                            "ret %{r}: it is {}, but the function's result is {}",
                            kind(*r).name(),
                            f.result_kind().name()
                        )));
                    }
                }
                Inst::Move { dst, src } => {
                    if kind(*dst) != kind(*src) {
                        return fail(ctx(format!(
                            "move %{dst} = %{src}: %{dst} is {}, %{src} is {}",
                            kind(*dst).name(),
                            kind(*src).name()
                        )));
                    }
                }
                Inst::Op { dst, op, args } => {
                    if let Some((i, a)) = args.iter().enumerate().find(|(i, a)| kind(**a) != op.operand_kind_at(*i)) {
                        return fail(ctx(format!(
                            "op {op:?}: operand %{a} is {}, must be {}",
                            kind(*a).name(),
                            op.operand_kind_at(i).name()
                        )));
                    }
                    if kind(*dst) != op.result_kind() {
                        return fail(ctx(format!(
                            "op {op:?}: result %{dst} is declared {}, must be {}",
                            kind(*dst).name(),
                            op.result_kind().name()
                        )));
                    }
                }
                // A parameter register i < f.params declared raw or short is
                // defined in that kind on entry (unboxed once in the
                // prologue, or already a scalar for a scalar-ABI position),
                // so its representation for the rest of the function --
                // including every backedge -- is that kind: the i-th
                // argument must already have it too. Every other rebound
                // register (env=1's closure) stays ordinary tagged, like
                // any operand in the catch-all below.
                Inst::Tail { args } | Inst::TailEnv { args, .. } => {
                    if let Some((i, a)) = args.iter().enumerate().find(|(i, a)| kind(**a) != kind(*i as Reg)) {
                        return fail(ctx(format!(
                            "tail argument {i} (%{a}) is {}, but parameter %{i} is declared {}",
                            kind(*a).name(),
                            kind(i as Reg).name()
                        )));
                    }
                    if let Inst::TailEnv { closure, .. } = inst {
                        if kind(*closure) != RegKind::Tagged {
                            return fail(ctx(format!("tailenv closure %{closure} must be tagged")));
                        }
                    }
                }
                _ => {
                    if let Some(r) = used.iter().find(|r| kind(**r) != RegKind::Tagged) {
                        return fail(ctx(format!(
                            "register %{r} is {} but used where a tagged Value is required",
                            kind(*r).name()
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
/// a closure capture, `retmulti`, a branch condition -- is
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
        if let Some(r) = (0..f.regs as usize).find(|r| plan[*r] && f.scalar_regs[*r]) {
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
                                if f.scalar_regs[*r as usize] {
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
                | Inst::Jump(_) | Inst::DeclaredErrorEq { .. } | Inst::Int { .. } | Inst::RawInt { .. } | Inst::ShortLit { .. }
                | Inst::AsciiLit { .. }
                | Inst::Str { .. } | Inst::Bytes { .. } | Inst::Char { .. } | Inst::Bool { .. } | Inst::Unit { .. }
                | Inst::Native { .. } | Inst::FnValue { .. } | Inst::SelfClosure { .. } | Inst::Capture { .. }
                | Inst::StaticGet { .. } | Inst::ContextLoad { .. } => {}
                Inst::StaticSet { value, .. } => used.push(*value),
                Inst::ContextStore { value, .. } => used.push(*value),
                Inst::Closure { captures, .. } => used.extend(captures),
                Inst::Guard { value, .. } | Inst::GuardBool { value } => used.push(*value),
                Inst::Op { args, .. } => used.extend(args),
                Inst::StructNew { fields, .. } => used.extend(fields),
                Inst::StructGet { value, .. } => used.push(*value),
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
        Inst::Int { dst, .. } | Inst::RawInt { dst, .. } | Inst::ShortLit { dst, .. } | Inst::AsciiLit { dst, .. } | Inst::Str { dst, .. } | Inst::Bytes { dst, .. } | Inst::Char { dst, .. }
        | Inst::Bool { dst, .. } | Inst::Unit { dst } | Inst::Native { dst, .. } | Inst::FnValue { dst, .. }
        | Inst::SelfClosure { dst } | Inst::Capture { dst, .. } | Inst::Move { dst, .. }
        | Inst::Closure { dst, .. }
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

#[cfg(test)]
mod struct_tests {
    use super::*;

    fn text(shapes: &str, body: &str) -> String {
        format!(
            "nir 1\n{shapes}\nfunc 0 \"<program>\" params=0 env=0 regs=6 pnames=\"\" captures=0 rawregs=\"\"\n{body}\nend\n"
        )
    }

    fn message(t: String) -> String {
        match parse(&t) {
            Ok(_) => panic!("expected invalid NIR"),
            Err(e) => e.message,
        }
    }

    const SHAPES: &str = "shape 0 anon fields=\"x y\"\nshape 1 named \"Point\" fields=\"y x\"\n";

    #[test]
    fn shapes_and_struct_ops_parse() {
        let p = parse(&text(
            SHAPES,
            "    %0 = int 1\n    %1 = int 2\n    %2 = structnew 0 %0 %1\n    %3 = structget 1 %2\n    ret %3",
        ))
        .unwrap();
        assert_eq!(p.shapes.len(), 2);
        assert_eq!(p.shapes[0].name, None);
        assert_eq!(p.shapes[1].name.as_deref(), Some("Point"));
        assert_eq!(p.shapes[1].fields, vec!["y".to_string(), "x".to_string()]);
        assert!(matches!(&p.functions[0].body[2], Inst::StructNew { shape: 0, .. }));
        assert!(matches!(&p.functions[0].body[3], Inst::StructGet { slot: 1, .. }));
    }

    #[test]
    fn an_opaque_named_shape_parses_and_an_ordinary_one_is_not_opaque() {
        // OPAQUE-STRUCTS.md: `opaque=1` is a rendering fact on a named shape.
        let p = parse(&text(
            "shape 0 named \"geo::Point\" fields=\"x y\"\nshape 1 named \"token::Token\" opaque=1 fields=\"v\"\n",
            "    %0 = unit\n    ret %0",
        ))
        .unwrap();
        assert!(!p.shapes[0].opaque);
        assert!(p.shapes[1].opaque);
        let body = "    %0 = unit\n    ret %0";
        assert!(message(text("shape 0 anon opaque=1 fields=\"x\"\n", body)).contains("anonymous shape cannot be opaque"));
        assert!(message(text("shape 0 named \"T\" opaque=2 fields=\"x\"\n", body)).contains("0 or 1"));
    }

    #[test]
    fn malformed_shapes_are_rejected() {
        let body = "    %0 = unit\n    ret %0";
        assert!(message(text("shape 0 anon fields=\"y x\"\n", body)).contains("canonical"));
        assert!(message(text("shape 0 anon fields=\"x x\"\n", body)).contains("twice"));
        assert!(message(text("shape 1 anon fields=\"x\"\n", body)).contains("dense"));
        assert!(message(text("shape 0 named fields=\"x\"\n", body)).contains("quoted"));
        assert!(message(text("shape 0 weird fields=\"x\"\n", body)).contains("anon or named"));
    }

    #[test]
    fn structnew_checks_shape_and_arity() {
        assert!(message(text(SHAPES, "    %0 = int 1\n    %1 = structnew 7 %0 %0\n    ret %1")).contains("undeclared"));
        assert!(message(text(SHAPES, "    %0 = int 1\n    %1 = structnew 0 %0\n    ret %1")).contains("field register"));
    }

    #[test]
    fn the_empty_struct_is_a_zero_field_shape() {
        let p = parse(&text(
            "shape 0 anon fields=\"\"\n",
            "    %0 = structnew 0\n    ret %0",
        ))
        .unwrap();
        assert!(p.shapes[0].fields.is_empty());
    }
}

/// The raw Int ABI (RAW-INT-ABI.md): the physical-signature metadata, its
/// validation (call-site and `ret` agreement, no Block value) and the
/// call-site effect rule for a raw-result callee.
#[cfg(test)]
mod raw_abi_tests {
    use super::*;

    fn message(r: Result<Program, NirError>) -> String {
        match r {
            Ok(_) => panic!("expected invalid NIR"),
            Err(e) => e.message,
        }
    }

    const PROGRAM: &str = "func 0 \"<program>\" params=0 env=0 regs=1 pnames=\"\" captures=0 rawregs=\"\"\n    %0 = unit\n    ret %0\nend\n\n";

    /// Function 1: `n + 1` with a raw parameter and a raw result (BODY_TAIL
    /// replaces the final `ret` line so a test can make it fail instead).
    fn callee(tail: &str) -> String {
        format!(
            "func 1 \"callee\" params=1 env=0 regs=3 pnames=\"n\" captures=0 rawregs=\"0 1 2\" rawparams=\"0\" rawresult=1\n    %1 = rawint 1\n    %2 = op riadd %0 %1\n{tail}end\n\n"
        )
    }

    fn program(effects: u32, rest: &str) -> String {
        format!("nir 1 call-effects={effects}\n\n{PROGRAM}{rest}")
    }

    #[test]
    fn matching_raw_call_parses() {
        // function 2 passes a raw parameter and boxes the raw result
        let text = program(
            1,
            &format!(
                "{}func 2 \"caller\" params=1 env=0 regs=3 pnames=\"x\" captures=0 rawregs=\"0 1\" rawparams=\"0\"\n    %1 = call 1 %0\n    %2 = op rbox %1\n    ret %2\nend\n",
                callee("    ret %2\n")
            ),
        );
        let p = parse(&text).unwrap_or_else(|e| panic!("{}", e.message));
        assert!(p.functions[1].raw_params[0] && p.functions[1].raw_result);
        assert!(p.functions[1].has_raw_abi() && !p.functions[0].has_raw_abi());
    }

    #[test]
    fn tagged_argument_to_raw_parameter_is_a_bug() {
        let text = program(
            1,
            &format!(
                "{}func 2 \"caller\" params=1 env=0 regs=3 pnames=\"x\" captures=0 rawregs=\"1\"\n    %1 = call 1 %0\n    %2 = op rbox %1\n    ret %2\nend\n",
                callee("    ret %2\n")
            ),
        );
        let m = message(parse(&text));
        assert!(m.contains("argument 0") && m.contains("tagged"), "{m}");
    }

    /// Function 1: `n + 1` with *tagged* parameter and result: what a RawInt-
    /// eligible position the demand analysis suppressed looks like.
    fn tagged_callee() -> String {
        "func 1 \"callee\" params=1 env=0 regs=3 pnames=\"n\" captures=0 rawregs=\"\"\n    %1 = int 1\n    %2 = op iadd %0 %1\n    ret %2\nend\n\n".to_string()
    }

    #[test]
    fn suppressed_position_is_tagged_on_both_sides() {
        // A position kept tagged by the demand analysis: neither the callee's
        // header nor the caller's call carries a raw register for it.
        let text = program(
            1,
            &format!(
                "{}func 2 \"caller\" params=1 env=0 regs=2 pnames=\"x\" captures=0 rawregs=\"\"\n    %1 = call 1 %0\n    ret %1\nend\n",
                tagged_callee()
            ),
        );
        let p = parse(&text).unwrap_or_else(|e| panic!("{}", e.message));
        assert!(!p.functions[1].has_raw_abi() && !p.functions[1].raw_params[0]);
    }

    #[test]
    fn raw_argument_to_a_suppressed_tagged_parameter_is_a_bug() {
        // The caller still passes the argument raw although the callee's
        // plan kept that parameter tagged: caller/callee disagree.
        let text = program(
            1,
            &format!(
                "{}func 2 \"caller\" params=1 env=0 regs=2 pnames=\"x\" captures=0 rawregs=\"0\" rawparams=\"0\"\n    %1 = call 1 %0\n    ret %1\nend\n",
                tagged_callee()
            ),
        );
        let m = message(parse(&text));
        assert!(m.contains("argument 0") && m.contains("raw"), "{m}");
    }

    #[test]
    fn raw_destination_for_a_suppressed_tagged_result_is_a_bug() {
        let text = program(
            1,
            &format!(
                "{}func 2 \"caller\" params=1 env=0 regs=3 pnames=\"x\" captures=0 rawregs=\"1\"\n    %1 = call 1 %0\n    %2 = op rbox %1\n    ret %2\nend\n",
                tagged_callee()
            ),
        );
        let m = message(parse(&text));
        assert!(m.contains("result %1") && m.contains("raw"), "{m}");
    }

    #[test]
    fn tagged_destination_for_raw_result_is_a_bug() {
        let text = program(
            1,
            &format!(
                "{}func 2 \"caller\" params=1 env=0 regs=2 pnames=\"x\" captures=0 rawregs=\"0\" rawparams=\"0\"\n    %1 = call 1 %0\n    ret %1\nend\n",
                callee("    ret %2\n")
            ),
        );
        let m = message(parse(&text));
        assert!(m.contains("result %1") && m.contains("tagged"), "{m}");
    }

    #[test]
    fn ret_of_wrong_representation_is_a_bug() {
        // a raw-result function returning a tagged register
        let text = program(
            1,
            "func 1 \"c\" params=1 env=0 regs=2 pnames=\"n\" captures=0 rawregs=\"0\" rawparams=\"0\" rawresult=1\n    %1 = op rbox %0\n    ret %1\nend\n",
        );
        let m = message(parse(&text));
        assert!(m.contains("ret %1"), "{m}");
        // and a tagged-result function returning a raw register
        let text = program(
            1,
            "func 1 \"c\" params=0 env=0 regs=1 pnames=\"\" captures=0 rawregs=\"0\"\n    %0 = rawint 1\n    ret %0\nend\n",
        );
        let m = message(parse(&text));
        assert!(m.contains("ret %0"), "{m}");
    }

    #[test]
    fn raw_parameter_must_be_a_declared_raw_register() {
        let text = program(
            1,
            "func 1 \"c\" params=1 env=0 regs=3 pnames=\"n\" captures=0 rawregs=\"1 2\" rawparams=\"0\" rawresult=1\n    %1 = rawint 1\n    %2 = rawint 2\n    ret %2\nend\n",
        );
        let m = message(parse(&text));
        assert!(m.contains("rawparams position 0"), "{m}");
    }

    #[test]
    fn a_raw_abi_function_has_no_block_value() {
        let text = program(
            1,
            &format!(
                "{}func 2 \"caller\" params=0 env=0 regs=2 pnames=\"\" captures=0 rawregs=\"\"\n    %0 = fnvalue 1\n    %1 = unit\n    ret %1\nend\n",
                callee("    ret %2\n")
            ),
        );
        let m = message(parse(&text));
        assert!(m.contains("raw Int ABI"), "{m}");
    }

    #[test]
    fn program_function_cannot_be_raw() {
        let m = message(parse(
            "nir 1\n\nfunc 0 \"<program>\" params=0 env=0 regs=1 pnames=\"\" captures=0 rawregs=\"0\" rawresult=1\n    %0 = rawint 1\n    ret %0\nend\n",
        ));
        assert!(m.contains("program"), "{m}");
    }

    /// With call effects disabled every ordinary call site must check, but a
    /// raw-result callee has no error sentinel: its call site follows the
    /// callee's own settled `may_error`.
    #[test]
    fn raw_result_call_site_follows_the_callee_even_without_call_effects() {
        let caller = "func 2 \"caller\" params=1 env=0 regs=3 pnames=\"x\" captures=0 rawregs=\"0 1\" rawparams=\"0\"\n    %1 = call 1 %0\n    %2 = op rbox %1\n    ret %2\nend\n";
        let site = |p: &Program| match &p.functions[2].body[0] {
            Inst::Call { may_error, .. } => *may_error,
            other => panic!("{other:?}"),
        };
        for effects in [0u32, 1u32] {
            let ok = parse(&program(effects, &format!("{}{caller}", callee("    ret %2\n"))))
                .unwrap_or_else(|e| panic!("{}", e.message));
            assert!(!ok.functions[1].may_error);
            assert!(!site(&ok), "a cannot-fail raw callee is never checked (effects={effects})");
            // A callee that can fail (a raise) is checked at every call site.
            let failing = parse(&program(effects, &format!("{}{caller}", callee("    raise TYPE \"x\"\n"))))
                .unwrap_or_else(|e| panic!("{}", e.message));
            assert!(failing.functions[1].may_error);
            assert!(site(&failing), "a raw callee that can fail is checked (effects={effects})");
        }
    }
}

/// The ShortString1 physical kind (SHORT-STRING.md): `shortregs=`,
/// `shortparams=`/`shortresult=`, the `shortlit` constant and the short ops.
/// A ShortString1 is a distinct kind from RawInt although both are i64: the
/// validator never lets one stand for the other, and never silently inserts a
/// conversion.
#[cfg(test)]
mod short_string_tests {
    use super::*;

    fn message(r: Result<Program, NirError>) -> String {
        match r {
            Ok(_) => panic!("expected invalid NIR"),
            Err(e) => e.message,
        }
    }

    const PROGRAM: &str = "func 0 \"<program>\" params=0 env=0 regs=1 pnames=\"\" captures=0 rawregs=\"\"\n    %0 = unit\n    ret %0\nend\n\n";

    fn program(rest: &str) -> String {
        format!("nir 1 call-effects=1\n\n{PROGRAM}{rest}")
    }

    /// Function 1: a ShortString1 parameter and result, identity.
    const CALLEE: &str = "func 1 \"callee\" params=1 env=0 regs=1 pnames=\"s\" captures=0 shortregs=\"0\" shortparams=\"0\" shortresult=1\n    ret %0\nend\n\n";

    fn parses(text: &str) -> Program {
        parse(text).unwrap_or_else(|e| panic!("{}", e.message))
    }

    #[test]
    fn short_literals_and_ops_parse() {
        let p = parses(&program(
            "func 1 \"f\" params=0 env=0 regs=5 pnames=\"\" captures=0 rawregs=\"3\" shortregs=\"0 1\"\n    %0 = shortlit -1\n    %1 = shortlit 955\n    %2 = op shorteq %0 %1\n    %3 = op shortlen %1\n    %4 = op rbox %3\n    ret %4\nend\n",
        ));
        assert!(p.functions[1].short_regs[0] && p.functions[1].short_regs[1]);
        assert!(p.functions[1].scalar_regs[0] && p.functions[1].scalar_regs[3] && !p.functions[1].scalar_regs[2]);
    }

    #[test]
    fn nul_is_a_one_character_string_and_the_top_scalar_is_valid() {
        // U+0000 is `shortlit 0` (a one-character String), distinct from
        // Empty (-1); U+10FFFF is the highest scalar value.
        let p = parses(&program(
            "func 1 \"f\" params=0 env=0 regs=3 pnames=\"\" captures=0 shortregs=\"0 1 2\" shortresult=1\n    %0 = shortlit 0\n    %1 = shortlit 1114111\n    %2 = shortlit -1\n    ret %0\nend\n",
        ));
        assert!(p.functions[1].short_result);
    }

    #[test]
    fn short_literals_outside_the_domain_are_rejected() {
        for bad in ["-2", "1114112", "55296", "57343", "x"] {
            let m = message(parse(&program(&format!(
                "func 1 \"f\" params=0 env=0 regs=1 pnames=\"\" captures=0 shortregs=\"0\"\n    %0 = shortlit {bad}\n    ret %0\nend\n"
            ))));
            assert!(m.contains("shortlit"), "{bad}: {m}");
        }
    }

    #[test]
    fn shortlit_needs_a_short_register() {
        let m = message(parse(&program(
            "func 1 \"f\" params=0 env=0 regs=1 pnames=\"\" captures=0\n    %0 = shortlit 5\n    ret %0\nend\n",
        )));
        assert!(m.contains("not declared in shortregs"), "{m}");
    }

    #[test]
    fn short_is_not_raw_int() {
        // A ShortString1 operand of riadd is rejected: the common i64
        // machine type is an implementation detail.
        let m = message(parse(&program(
            "func 1 \"f\" params=0 env=0 regs=3 pnames=\"\" captures=0 rawregs=\"2\" shortregs=\"0 1\"\n    %0 = shortlit 1\n    %1 = shortlit 2\n    %2 = op riadd %0 %1\n    %0 = shortlit 0\n    ret %2\nend\n",
        )));
        assert!(m.contains("operand") && m.contains("short") && m.contains("raw"), "{m}");
        // ... and a RawInt operand of a short op.
        let m = message(parse(&program(
            "func 1 \"f\" params=0 env=0 regs=3 pnames=\"\" captures=0 rawregs=\"0\" shortregs=\"1\"\n    %0 = rawint 1\n    %1 = shortlit 2\n    %2 = op shorteq %0 %1\n    ret %2\nend\n",
        )));
        assert!(m.contains("operand") && m.contains("raw") && m.contains("short"), "{m}");
        // A raw/short move is a bug, not a conversion.
        let m = message(parse(&program(
            "func 1 \"f\" params=0 env=0 regs=2 pnames=\"\" captures=0 rawregs=\"0\" shortregs=\"1\"\n    %0 = rawint 1\n    %1 = move %0\n    ret %1\nend\n",
        )));
        assert!(m.contains("move"), "{m}");
    }

    #[test]
    fn a_register_is_never_both_raw_and_short() {
        let m = message(parse(&program(
            "func 1 \"f\" params=0 env=0 regs=1 pnames=\"\" captures=0 rawregs=\"0\" shortregs=\"0\"\n    %0 = rawint 1\n    ret %0\nend\n",
        )));
        assert!(m.contains("both raw and short"), "{m}");
    }

    #[test]
    fn a_short_value_is_not_a_tagged_value() {
        // A short register where a tagged Value is required (a list element).
        let m = message(parse(&program(
            "func 1 \"f\" params=0 env=0 regs=2 pnames=\"\" captures=0 shortregs=\"0\"\n    %0 = shortlit 1\n    %1 = op listnew %0\n    ret %1\nend\n",
        )));
        assert!(m.contains("short") && m.contains("tagged"), "{m}");
    }

    #[test]
    fn matching_short_call_parses() {
        let p = parses(&program(&format!(
            "{CALLEE}func 2 \"caller\" params=0 env=0 regs=3 pnames=\"\" captures=0 shortregs=\"0 1\"\n    %0 = shortlit 955\n    %1 = call 1 %0\n    %2 = op shorttostr %1\n    ret %2\nend\n"
        )));
        assert!(p.functions[1].short_params[0] && p.functions[1].short_result);
        assert!(p.functions[1].has_short_abi() && !p.functions[1].has_raw_abi() && p.functions[1].has_scalar_abi());
        assert!(!p.functions[0].has_scalar_abi());
    }

    #[test]
    fn tagged_argument_to_short_parameter_is_a_bug() {
        let m = message(parse(&program(&format!(
            "{CALLEE}func 2 \"caller\" params=1 env=0 regs=3 pnames=\"x\" captures=0 shortregs=\"1\"\n    %1 = call 1 %0\n    %2 = op shorttostr %1\n    ret %2\nend\n"
        ))));
        assert!(m.contains("argument 0") && m.contains("tagged") && m.contains("short"), "{m}");
    }

    #[test]
    fn short_argument_to_a_tagged_parameter_is_a_bug() {
        let tagged = "func 1 \"callee\" params=1 env=0 regs=1 pnames=\"s\" captures=0\n    ret %0\nend\n\n";
        let m = message(parse(&program(&format!(
            "{tagged}func 2 \"caller\" params=0 env=0 regs=2 pnames=\"\" captures=0 shortregs=\"0\"\n    %0 = shortlit 1\n    %1 = call 1 %0\n    ret %1\nend\n"
        ))));
        assert!(m.contains("argument 0") && m.contains("short") && m.contains("tagged"), "{m}");
    }

    #[test]
    fn a_raw_argument_cannot_feed_a_short_parameter() {
        let m = message(parse(&program(&format!(
            "{CALLEE}func 2 \"caller\" params=0 env=0 regs=3 pnames=\"\" captures=0 rawregs=\"0\" shortregs=\"1\"\n    %0 = rawint 1\n    %1 = call 1 %0\n    %2 = op shorttostr %1\n    ret %2\nend\n"
        ))));
        assert!(m.contains("argument 0") && m.contains("raw") && m.contains("short"), "{m}");
    }

    #[test]
    fn short_destination_for_a_tagged_result_is_a_bug() {
        let tagged = "func 1 \"callee\" params=0 env=0 regs=1 pnames=\"\" captures=0\n    %0 = str \"a\"\n    ret %0\nend\n\n";
        let m = message(parse(&program(&format!(
            "{tagged}func 2 \"caller\" params=0 env=0 regs=1 pnames=\"\" captures=0 shortregs=\"0\"\n    %0 = call 1\n    ret %0\nend\n"
        ))));
        assert!(m.contains("result %0") && m.contains("short") && m.contains("tagged"), "{m}");
    }

    #[test]
    fn tagged_destination_for_a_short_result_is_a_bug() {
        let m = message(parse(&program(&format!(
            "{CALLEE}func 2 \"caller\" params=0 env=0 regs=2 pnames=\"\" captures=0 shortregs=\"0\"\n    %0 = shortlit 1\n    %1 = call 1 %0\n    ret %1\nend\n"
        ))));
        assert!(m.contains("result %1") && m.contains("tagged") && m.contains("short"), "{m}");
    }

    #[test]
    fn ret_kind_must_match_the_function_result() {
        let m = message(parse(&program(
            "func 1 \"c\" params=0 env=0 regs=1 pnames=\"\" captures=0 shortregs=\"0\" shortresult=0\n    %0 = shortlit 1\n    ret %0\nend\n",
        )));
        assert!(m.contains("ret %0"), "{m}");
        let m = message(parse(&program(
            "func 1 \"c\" params=0 env=0 regs=1 pnames=\"\" captures=0 shortresult=1\n    %0 = str \"a\"\n    ret %0\nend\n",
        )));
        assert!(m.contains("ret %0"), "{m}");
    }

    #[test]
    fn a_short_parameter_register_must_be_a_shortparams_position() {
        let m = message(parse(&program(
            "func 1 \"c\" params=1 env=0 regs=1 pnames=\"s\" captures=0 shortregs=\"0\"\n    ret %0\nend\n",
        )));
        assert!(m.contains("not a shortparams position"), "{m}");
        let m = message(parse(&program(
            "func 1 \"c\" params=1 env=0 regs=1 pnames=\"s\" captures=0 shortparams=\"0\"\n    ret %0\nend\n",
        )));
        assert!(m.contains("shortparams position 0 is not declared in shortregs"), "{m}");
    }

    #[test]
    fn a_short_abi_function_has_no_block_value() {
        let m = message(parse(&program(&format!(
            "{CALLEE}func 2 \"caller\" params=0 env=0 regs=2 pnames=\"\" captures=0\n    %0 = fnvalue 1\n    %1 = unit\n    ret %1\nend\n"
        ))));
        assert!(m.contains("ShortString1 ABI"), "{m}");
    }

    #[test]
    fn the_program_function_cannot_use_the_short_abi() {
        let m = message(parse(
            "nir 1\n\nfunc 0 \"<program>\" params=0 env=0 regs=1 pnames=\"\" captures=0 shortregs=\"0\" shortresult=1\n    %0 = shortlit 1\n    ret %0\nend\n",
        ));
        assert!(m.contains("program function"), "{m}");
    }

    #[test]
    fn tail_arguments_follow_the_parameter_kind() {
        let m = message(parse(&program(
            "func 1 \"loop\" params=1 env=0 regs=2 pnames=\"s\" captures=0 shortregs=\"0\" shortparams=\"0\" shortresult=1\n    %1 = str \"a\"\n    tail %1\nend\n",
        )));
        assert!(m.contains("tail argument 0") && m.contains("tagged") && m.contains("short"), "{m}");
        parses(&program(
            "func 1 \"loop\" params=1 env=0 regs=1 pnames=\"s\" captures=0 shortregs=\"0\" shortparams=\"0\" shortresult=1\n    tail %0\nend\n",
        ));
    }

    /// A short-result callee has no error sentinel in its result word: its
    /// call sites follow its own settled `may_error` even with call effects
    /// disabled, exactly like a raw-result callee.
    #[test]
    fn short_result_call_site_follows_the_callee_even_without_call_effects() {
        let caller = "func 2 \"caller\" params=1 env=0 regs=3 pnames=\"x\" captures=0 shortregs=\"0 1\" shortparams=\"0\"\n    %1 = call 1 %0\n    %2 = op shorttostr %1\n    ret %2\nend\n";
        for effects in [0, 1] {
            let text = format!("nir 1 call-effects={effects}\n\n{PROGRAM}{CALLEE}{caller}");
            let p = parses(&text);
            let site = |p: &Program| match &p.functions[2].body[0] {
                Inst::Call { may_error, .. } => *may_error,
                other => panic!("{other:?}"),
            };
            assert!(!site(&p), "a cannot-fail short callee is never checked (effects={effects})");
        }
    }
}

/// The packed-ASCII physical kind (SHORT-STRING.md, tier A): `asciiregs=`,
/// `asciiparams=`/`asciiresult=`, the `asciilit` constant and the ascii ops,
/// a third kind distinct from RawInt and ShortString1.
#[cfg(test)]
mod packed_ascii_tests {
    use super::*;

    const PROGRAM: &str = "func 0 \"<program>\" params=0 env=0 regs=1 pnames=\"\" captures=0 rawregs=\"\"\n    %0 = unit\n    ret %0\nend\n\n";

    fn whole(rest: &str) -> String {
        format!("nir 1 call-effects=1\n\n{PROGRAM}{rest}")
    }

    fn rejected(rest: &str) -> String {
        match parse(&whole(rest)) {
            Ok(_) => panic!("expected invalid NIR:\n{rest}"),
            Err(e) => e.message,
        }
    }

    fn accepted(rest: &str) -> Program {
        parse(&whole(rest)).unwrap_or_else(|e| panic!("{}", e.message))
    }

    const CALLEE: &str = "func 1 \"callee\" params=1 env=0 regs=1 pnames=\"s\" captures=0 asciiregs=\"0\" asciiparams=\"0\" asciiresult=1\n    ret %0\nend\n\n";

    #[test]
    fn ascii_literals_and_ops_parse() {
        // "ab" = 0xE2E1 = 58081; the empty word is 0; a full word is negative.
        let p = accepted(
            "func 1 \"f\" params=0 env=0 regs=7 pnames=\"\" captures=0 rawregs=\"4\" asciiregs=\"0 1 2\" shortregs=\"3\"\n    %0 = asciilit 58081\n    %1 = asciilit 0\n    %2 = asciilit -1664107662228069663\n    %3 = op asciitoshort %1\n    %4 = op asciilen %0\n    %5 = op asciieq %0 %2\n    %6 = op asciishorteq %0 %3\n    ret %5\nend\n",
        );
        let f = &p.functions[1];
        assert!(f.ascii_regs[0] && f.ascii_regs[1] && f.ascii_regs[2] && !f.ascii_regs[3]);
        assert_eq!(f.kind_of(0), RegKind::Ascii);
        assert_eq!(f.kind_of(3), RegKind::Short);
        assert!(f.scalar_regs[0] && f.scalar_regs[3] && f.scalar_regs[4]);
    }

    #[test]
    fn non_canonical_words_are_rejected() {
        // 97: a payload byte without its presence flag; 256: byte 1 without
        // flag and byte 0 absent; 57600 (0xE100): a present byte after an
        // absent one; 225000: a payload byte (0x6E) without its flag. (-1 is
        // *valid*: eight DEL characters.)
        for bad in ["97", "256", "57600", "225000"] {
            let m = rejected(&format!(
                "func 1 \"f\" params=0 env=0 regs=1 pnames=\"\" captures=0 asciiregs=\"0\"\n    %0 = asciilit {bad}\n    ret %0\nend\n"
            ));
            assert!(m.contains("asciilit"), "{bad}: {m}");
        }
    }

    #[test]
    fn asciilit_needs_an_ascii_register() {
        let m = rejected("func 1 \"f\" params=0 env=0 regs=1 pnames=\"\" captures=0\n    %0 = asciilit 225\n    ret %0\nend\n");
        assert!(m.contains("not declared in asciiregs"), "{m}");
    }

    #[test]
    fn ascii_is_neither_raw_nor_short() {
        // An Ascii operand of riadd is rejected; a Short operand of asciieq too.
        let m = rejected(
            "func 1 \"f\" params=0 env=0 regs=3 pnames=\"\" captures=0 rawregs=\"2\" asciiregs=\"0 1\"\n    %0 = asciilit 225\n    %1 = asciilit 226\n    %2 = op riadd %0 %1\n    ret %2\nend\n",
        );
        assert!(m.contains("operand") && m.contains("ascii") && m.contains("raw"), "{m}");
        let m = rejected(
            "func 1 \"f\" params=0 env=0 regs=3 pnames=\"\" captures=0 asciiregs=\"0\" shortregs=\"1\"\n    %0 = asciilit 225\n    %1 = shortlit 97\n    %2 = op asciieq %0 %1\n    ret %2\nend\n",
        );
        assert!(m.contains("operand") && m.contains("short") && m.contains("ascii"), "{m}");
        // asciishorteq wants (ascii, short) in that order.
        let m = rejected(
            "func 1 \"f\" params=0 env=0 regs=3 pnames=\"\" captures=0 asciiregs=\"0\" shortregs=\"1\"\n    %0 = asciilit 225\n    %1 = shortlit 97\n    %2 = op asciishorteq %1 %0\n    ret %2\nend\n",
        );
        assert!(m.contains("operand"), "{m}");
        // A move between kinds is a bug, not a conversion.
        let m = rejected(
            "func 1 \"f\" params=0 env=0 regs=2 pnames=\"\" captures=0 asciiregs=\"0\" shortregs=\"1\"\n    %0 = asciilit 225\n    %1 = move %0\n    ret %1\nend\n",
        );
        assert!(m.contains("move"), "{m}");
    }

    #[test]
    fn a_register_is_in_one_scalar_kind_only() {
        let m = rejected(
            "func 1 \"f\" params=0 env=0 regs=1 pnames=\"\" captures=0 shortregs=\"0\" asciiregs=\"0\"\n    %0 = asciilit 225\n    ret %0\nend\n",
        );
        assert!(m.contains("two scalar kinds"), "{m}");
    }

    #[test]
    fn an_ascii_value_is_not_a_tagged_value() {
        let m = rejected(
            "func 1 \"f\" params=0 env=0 regs=2 pnames=\"\" captures=0 asciiregs=\"0\"\n    %0 = asciilit 225\n    %1 = op listnew %0\n    ret %1\nend\n",
        );
        assert!(m.contains("ascii") && m.contains("tagged"), "{m}");
    }

    #[test]
    fn matching_ascii_call_parses_and_reports_the_abi() {
        let p = accepted(&format!(
            "{CALLEE}func 2 \"caller\" params=0 env=0 regs=3 pnames=\"\" captures=0 asciiregs=\"0 1\"\n    %0 = asciilit 58081\n    %1 = call 1 %0\n    %2 = op asciitostr %1\n    ret %2\nend\n"
        ));
        let f = &p.functions[1];
        assert!(f.ascii_params[0] && f.ascii_result && f.has_ascii_abi());
        assert!(f.has_scalar_abi() && !f.has_short_abi() && !f.has_raw_abi());
        assert_eq!(f.scalar_abi_name(), "packed ASCII ABI");
    }

    #[test]
    fn tagged_short_or_raw_arguments_cannot_feed_an_ascii_parameter() {
        let m = rejected(&format!(
            "{CALLEE}func 2 \"caller\" params=1 env=0 regs=3 pnames=\"x\" captures=0 asciiregs=\"1\"\n    %1 = call 1 %0\n    %2 = op asciitostr %1\n    ret %2\nend\n"
        ));
        assert!(m.contains("argument 0") && m.contains("tagged") && m.contains("ascii"), "{m}");
        let m = rejected(&format!(
            "{CALLEE}func 2 \"caller\" params=0 env=0 regs=3 pnames=\"\" captures=0 shortregs=\"0\" asciiregs=\"1\"\n    %0 = shortlit 97\n    %1 = call 1 %0\n    %2 = op asciitostr %1\n    ret %2\nend\n"
        ));
        assert!(m.contains("argument 0") && m.contains("short") && m.contains("ascii"), "{m}");
    }

    #[test]
    fn a_result_is_of_one_scalar_kind_only() {
        let m = rejected(
            "func 1 \"f\" params=0 env=0 regs=1 pnames=\"\" captures=0 asciiregs=\"0\" asciiresult=1 shortresult=1\n    %0 = asciilit 225\n    ret %0\nend\n",
        );
        assert!(m.contains("two scalar kinds"), "{m}");
    }

    #[test]
    fn the_program_function_cannot_use_the_ascii_abi() {
        let src = "nir 1 call-effects=1\n\nfunc 0 \"<program>\" params=0 env=0 regs=1 pnames=\"\" captures=0 asciiregs=\"0\" asciiresult=1\n    %0 = asciilit 225\n    ret %0\nend\n";
        let m = match parse(src) {
            Ok(_) => panic!("expected invalid NIR"),
            Err(e) => e.message,
        };
        assert!(m.contains("program"), "{m}");
    }

    #[test]
    fn a_block_value_of_an_ascii_function_is_a_bug() {
        let m = rejected(&format!(
            "{CALLEE}func 2 \"caller\" params=0 env=0 regs=1 pnames=\"\" captures=0\n    %0 = fnvalue 1\n    ret %0\nend\n"
        ));
        assert!(m.contains("packed ASCII ABI"), "{m}");
    }

    #[test]
    fn tail_arguments_keep_the_ascii_kind() {
        let m = rejected(
            "func 1 \"f\" params=1 env=0 regs=2 pnames=\"s\" captures=0 asciiregs=\"0\" asciiparams=\"0\" asciiresult=1\n    %1 = op strtoascii %0\n    tail %1\nend\n",
        );
        assert!(!m.is_empty());
    }
}
