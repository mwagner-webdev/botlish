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
    IsInt,
    IsStr,
    IsList,
    IsOk,
    IsError,
    ResultValue,
    ResultError,
    MkOk,
    MkError,
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
            "isint" => IsInt,
            "isstr" => IsStr,
            "islist" => IsList,
            "isok" => IsOk,
            "iserror" => IsError,
            "resultvalue" => ResultValue,
            "resulterror" => ResultError,
            "mkok" => MkOk,
            "mkerror" => MkError,
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
            StrLen | StrLower | ListLen | IsInt | IsStr | IsList | IsOk | IsError | ResultValue
            | ResultError | MkOk | MkError | RBox | RUnbox => Some(1),
            Substr => Some(3),
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
    Tail { args: Vec<Reg> },
    TailEnv { closure: Reg, args: Vec<Reg> },
    Br { cond: Reg, then: Label, otherwise: Label },
    Jump(Label),
    Ret(Reg),
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
    pub body: Vec<Inst>,
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

fn tokenize(line: &str) -> Result<Vec<Token>, String> {
    let mut tokens = Vec::new();
    let mut chars = line.chars().peekable();
    loop {
        while chars.peek().is_some_and(|c| c.is_whitespace()) {
            chars.next();
        }
        let Some(&c) = chars.peek() else { break };
        if c == '@' {
            // An origin annotation ends the instruction.
            break;
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
    Ok(tokens)
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
        let tokens = tokenize(raw).or_else(|m| p.err(m))?;
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
        current.as_mut().unwrap().body.push(inst);
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
    Ok(Function {
        id,
        name: name.clone(),
        params: num("params")?,
        env: num("env")? == 1,
        regs: num("regs")?,
        pnames: kv.get("pnames").cloned().unwrap_or_default(),
        captures: num("captures")?,
        body: Vec::new(),
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
    if let Some(Token::Reg(dst)) = tokens.first() {
        if tokens.get(1) != Some(&Token::Word("=".into())) {
            return p.err("expected =");
        }
        let dst = *dst;
        let rhs = tokens.get(2).and_then(word).unwrap_or("");
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
        // a Value, forward-computed from each register's one definition
        // (Move propagates its source's representation). Never true for a
        // register a Tail/TailEnv implicitly redefines (a function parameter
        // slot: always tagged, part of the generic ABI).
        let mut raw = vec![false; f.regs as usize];
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
                Inst::Ret(r) => used.push(*r),
            }
            if let Some(r) = used.iter().find(|r| **r >= f.regs) {
                return fail(ctx(format!("register %{r} out of range")));
            }
            match inst {
                Inst::RawInt { dst, .. } => raw[*dst as usize] = true,
                Inst::Move { dst, src } => raw[*dst as usize] = raw[*src as usize],
                Inst::Op { dst, op, args } => {
                    if let Some(a) = args.iter().find(|a| raw[**a as usize] != op.raw_operands()) {
                        let (is, want) = (raw[*a as usize], op.raw_operands());
                        return fail(ctx(format!(
                            "op {op:?}: operand %{a} is {}, must be {}",
                            if is { "raw" } else { "tagged" },
                            if want { "raw" } else { "tagged" }
                        )));
                    }
                    raw[*dst as usize] = op.raw_result();
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
    if program.functions.is_empty() || program.functions[0].params != 0 || program.functions[0].env {
        return fail("function 0 must be the program: no parameters, no environment".into());
    }
    Ok(())
}
