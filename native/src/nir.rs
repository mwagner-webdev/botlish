//! NIR: the backend-neutral native IR produced by native/lower.tcl.
//!
//! See native/lower.tcl for the format. This module parses and validates it;
//! it knows nothing about Cranelift.

use crate::runtime::value::Kind;
use std::collections::HashSet;
use std::fmt;

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
    MutArrayAllocate,
    MutArrayCapacity,
    MutArrayGet,
    MutArraySet,
    MutArrayCopy,
    MutArrayFreeze,
    IsInt,
    IsStr,
    IsList,
    IsOk,
    IsError,
    ResultValue,
    ResultError,
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
}

impl OpCode {
    pub fn parse(name: &str) -> Option<OpCode> {
        use OpCode::*;
        Some(match name {
            "iadd" => IAdd,
            "isub" => ISub,
            "imul" => IMul,
            "imod" => IMod,
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
            "mutarrayallocate" => MutArrayAllocate,
            "mutarraycapacity" => MutArrayCapacity,
            "mutarrayget" => MutArrayGet,
            "mutarrayset" => MutArraySet,
            "mutarraycopy" => MutArrayCopy,
            "mutarrayfreeze" => MutArrayFreeze,
            "isint" => IsInt,
            "isstr" => IsStr,
            "islist" => IsList,
            "isok" => IsOk,
            "iserror" => IsError,
            "resultvalue" => ResultValue,
            "resulterror" => ResultError,
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
            _ => return None,
        })
    }

    /// Number of operands, or None for any.
    pub fn arity(self) -> Option<usize> {
        use OpCode::*;
        match self {
            ListNew => None,
            StrLen | StrLower | ListLen | MutArrayAllocate | MutArrayCapacity | IsInt | IsStr | IsList
            | IsOk | IsError | ResultValue | ResultError | MkOk | MkError | Hash | RBox | RUnbox
            | StrByteLen | StrUtf8Bytes | StrIsTclAlpha | StrIsTclAlnum => Some(1),
            Substr | MutArraySet | RegionCheck => Some(3),
            RegionEq => Some(4),
            MutArrayCopy => Some(5),
            _ => Some(2),
        }
    }

    /// 1 if OP's result is a raw (untagged) machine integer, not a Value.
    pub fn raw_result(self) -> bool {
        matches!(self, OpCode::RUnbox | OpCode::RIAdd | OpCode::RISub | OpCode::RIMul)
    }

    /// 1 if OP's operands are raw (untagged) machine integers, not Values.
    pub fn raw_operands(self) -> bool {
        use OpCode::*;
        matches!(self, RBox | RIAdd | RISub | RIMul | RILt | RILe | RIGt | RIGe | RIEq)
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
    Bool { dst: Reg, value: bool },
    Unit { dst: Reg },
    Native { dst: Reg, native: u32 },
    FnValue { dst: Reg, func: FuncId },
    SelfClosure { dst: Reg },
    Capture { dst: Reg, index: u32 },
    Move { dst: Reg, src: Reg },
    Cell { dst: Reg },
    CellSet { cell: Reg, value: Reg },
    CellGet { dst: Reg, cell: Reg },
    CellCheck { dst: Reg, cell: Reg, name: String },
    Closure { dst: Reg, func: FuncId, captures: Vec<Reg> },
    Guard { kind: Kind, value: Reg, context: String },
    GuardBool { value: Reg },
    Op { dst: Reg, op: OpCode, args: Vec<Reg> },
    Call { dst: Reg, func: FuncId, args: Vec<Reg> },
    CallEnv { dst: Reg, func: FuncId, closure: Reg, args: Vec<Reg> },
    CallValue { dst: Reg, callee: Reg, args: Vec<Reg> },
    /// A direct call of a scalar-replacement companion function (a function
    /// with `results` > 1: see Function::results): like Call, but the
    /// callee returns several tagged Values at once -- the fields of a
    /// fixed-shape aggregate whose canonical List object native/lower.tcl's
    /// escape analysis proved this call site never needs (see hir/escape.tcl
    /// and native/lower.tcl's "Scalar replacement" section). Never used for
    /// an ordinary (results == 1) function.
    CallMulti { dsts: Vec<Reg>, func: FuncId, args: Vec<Reg> },
    /// CallMulti, with a closure (see CallEnv).
    CallEnvMulti { dsts: Vec<Reg>, func: FuncId, closure: Reg, args: Vec<Reg> },
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
    let mut program = Program { natives: Vec::new(), functions: Vec::new() };
    let mut current: Option<Function> = None;
    let mut seen_header = false;
    for (index, raw) in text.lines().enumerate() {
        p.line = index + 1;
        let (tokens, origin) = tokenize(raw).or_else(|m| p.err(m))?;
        if tokens.is_empty() || raw.trim_start().starts_with(';') {
            continue;
        }
        if !seen_header {
            if tokens != [Token::Word("nir".into()), Token::Word("1".into())] {
                return p.err("expected \"nir 1\"");
            }
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
    Ok(program)
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
    Ok(Function {
        id,
        name: name.clone(),
        params: num("params")?,
        env: num("env")? == 1,
        regs,
        pnames: kv.get("pnames").cloned().unwrap_or_default(),
        captures: num("captures")?,
        results,
        body: Vec::new(),
        origins: Vec::new(),
        raw_regs,
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
            "call" => Inst::Call { dst, func: num(3)?, args: regs_from(4)? },
            "callenv" => Inst::CallEnv { dst, func: num(3)?, closure: reg(4)?, args: regs_from(5)? },
            "callvalue" => Inst::CallValue { dst, callee: reg(3)?, args: regs_from(4)? },
            "callmulti" => Inst::CallMulti { dsts, func: num(i)?, args: regs_from(i + 1)? },
            "callenvmulti" => {
                Inst::CallEnvMulti { dsts, func: num(i)?, closure: reg(i + 1)?, args: regs_from(i + 2)? }
            }
            other => return p.err(format!("unknown instruction {other}")),
        });
    }
    let head = tokens.first().and_then(word).unwrap_or("");
    Ok(match head {
        "label" => Inst::Label(label(1)?),
        "cellset" => Inst::CellSet { cell: reg(1)?, value: reg(2)? },
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
                Inst::Label(_) | Inst::Unreachable | Inst::Raise { .. } => {}
                Inst::Int { dst, .. }
                | Inst::RawInt { dst, .. }
                | Inst::Str { dst, .. }
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
                Inst::FnValue { dst, func: g } => {
                    match func(*g) {
                        Some(g) if !g.env => {}
                        _ => return fail(ctx(format!("fnvalue of {g}: not an environment-free function"))),
                    }
                    used.push(*dst);
                }
                Inst::Move { dst, src } => used.extend([*dst, *src]),
                Inst::CellSet { cell, value } => used.extend([*cell, *value]),
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
                Inst::Op { dst, op, args } => {
                    if op.arity().is_some_and(|n| n != args.len()) {
                        return fail(ctx(format!("op {op:?} takes {:?} operands", op.arity())));
                    }
                    used.push(*dst);
                    used.extend(args);
                }
                Inst::Call { dst, func: g, args } => {
                    match func(*g) {
                        Some(g) if !g.env && g.params as usize == args.len() => {}
                        _ => return fail(ctx(format!("call of {g}: bad target or arity"))),
                    }
                    used.push(*dst);
                    used.extend(args);
                }
                Inst::CallEnv { dst, func: g, closure, args } => {
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
                Inst::CallMulti { dsts, func: g, args } => {
                    match func(*g) {
                        Some(g) if !g.env && g.params as usize == args.len() && g.results as usize == dsts.len() => {}
                        _ => return fail(ctx(format!("callmulti of {g}: bad target, arity or result count"))),
                    }
                    used.extend(dsts);
                    used.extend(args);
                }
                Inst::CallEnvMulti { dsts, func: g, closure, args } => {
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
    Ok(())
}
