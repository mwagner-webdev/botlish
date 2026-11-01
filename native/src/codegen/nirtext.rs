//! NIR text from a parsed program: the inverse of `nir::parse` for function
//! sections, so a program a pass rewrote (codegen::fusion) can be read as
//! the NIR it now is (`botlish-native fused`), and read back.
//!
//! Only functions are printed: a pass never changes a program's
//! declarations (natives, shapes, enums, contexts, foreign functions, links,
//! the target), so `program_text` keeps the original text's prelude -- every
//! line before the first `func` -- verbatim. Origins (`@ExprId`) print as
//! `@eN`, which `nir::parse` reads back to the same id.

use crate::nir::{CAbi, Function, Inst, Piece, Program, Reg};
use std::fmt::Write as _;

/// TEXT as a NIR string literal (native/lower.tcl's Quote).
pub fn quote(text: &str) -> String {
    let mut out = String::from("\"");
    for c in text.chars() {
        match c {
            '\\' => out.push_str("\\\\"),
            '"' => out.push_str("\\\""),
            '\n' => out.push_str("\\n"),
            '\r' => out.push_str("\\r"),
            '\t' => out.push_str("\\t"),
            c if (c as u32) < 32 || c as u32 == 127 => {
                let _ = write!(out, "\\u{{{:x}}}", c as u32);
            }
            c => out.push(c),
        }
    }
    out.push('"');
    out
}

fn cabi(c: CAbi) -> &'static str {
    match c {
        CAbi::I8 => "i8",
        CAbi::U8 => "u8",
        CAbi::I16 => "i16",
        CAbi::U16 => "u16",
        CAbi::I32 => "i32",
        CAbi::U32 => "u32",
        CAbi::I64 => "i64",
        CAbi::U64 => "u64",
        CAbi::Bool => "bool",
        CAbi::F32 => "f32",
        CAbi::F64 => "f64",
        CAbi::RawF32 => "rf32",
        CAbi::RawF64 => "rf64",
        CAbi::Ptr => "ptr",
        CAbi::Void => "void",
    }
}

fn regs(rs: &[Reg]) -> String {
    rs.iter().map(|r| format!(" %{r}")).collect()
}

fn positions(flags: &[bool]) -> String {
    flags.iter().enumerate().filter(|(_, b)| **b).map(|(i, _)| i.to_string()).collect::<Vec<_>>().join(" ")
}

/// The `func` header line of F.
pub fn header(f: &Function) -> String {
    let mut line = format!(
        "func {} {} params={} env={} regs={} pnames={} captures={}",
        f.id,
        quote(&f.name),
        f.params,
        if f.env { 1 } else { 0 },
        f.regs,
        quote(&f.pnames),
        f.captures
    );
    if f.results != 1 {
        let _ = write!(line, " results={}", f.results);
    }
    for (key, flags) in [
        ("rawregs", &f.raw_regs),
        ("planregs", &f.plan_regs),
        ("rawparams", &f.raw_params),
        ("shortregs", &f.short_regs),
        ("shortparams", &f.short_params),
        ("asciiregs", &f.ascii_regs),
        ("asciiparams", &f.ascii_params),
        ("i64regs", &f.i64_regs),
        ("u64regs", &f.u64_regs),
    ] {
        if flags.iter().any(|b| *b) {
            let _ = write!(line, " {key}={}", quote(&positions(flags)));
        }
    }
    for (key, flag) in [
        ("planresult", f.plan_result),
        ("rawresult", f.raw_result),
        ("shortresult", f.short_result),
        ("asciiresult", f.ascii_result),
    ] {
        if flag {
            let _ = write!(line, " {key}=1");
        }
    }
    line
}

/// One instruction of PROGRAM as NIR text (without its origin).
pub fn inst(program: &Program, inst: &Inst) -> String {
    match inst {
        Inst::Label(l) => format!("  label L{l}"),
        Inst::Int { dst, digits } => format!("    %{dst} = int {digits}"),
        Inst::RawInt { dst, digits } => format!("    %{dst} = rawint {digits}"),
        Inst::CWord { dst, digits } => format!("    %{dst} = cword {digits}"),
        Inst::ShortLit { dst, value } => format!("    %{dst} = shortlit {value}"),
        Inst::AsciiLit { dst, value } => format!("    %{dst} = asciilit {value}"),
        Inst::Str { dst, text } => format!("    %{dst} = str {}", quote(text)),
        Inst::Bytes { dst, bytes } => {
            let hex: String = bytes.iter().map(|b| format!("{b:02x}")).collect();
            format!("    %{dst} = bytes \"{hex}\"")
        }
        Inst::Char { dst, digits } => format!("    %{dst} = char {digits}"),
        Inst::Float { dst, ty, bits } => {
            let name = match ty {
                crate::runtime::value::FloatType::Float64 => "Float64",
                crate::runtime::value::FloatType::DecimalRounded => "DecimalRounded",
            };
            format!("    %{dst} = float {name} 0x{bits:016x}")
        }
        Inst::Enum { dst, index, case } => format!("    %{dst} = enum {index} {case}"),
        Inst::Bool { dst, value } => format!("    %{dst} = bool {value}"),
        Inst::Unit { dst } => format!("    %{dst} = unit"),
        Inst::Native { dst, native } => {
            format!("    %{dst} = native {}", quote(&program.natives[*native as usize].name))
        }
        Inst::FnValue { dst, func } => format!("    %{dst} = fnvalue {func}"),
        Inst::CallbackAddress { dst, callback } => format!("    %{dst} = cbaddr {callback}"),
        Inst::SelfClosure { dst } => format!("    %{dst} = self"),
        Inst::Capture { dst, index } => format!("    %{dst} = capture {index}"),
        Inst::StaticGet { dst, index } => format!("    %{dst} = staticget {index}"),
        Inst::StaticSet { index, value } => format!("    staticset {index} %{value}"),
        Inst::ContextLoad { dst, offset } => format!("    %{dst} = contextload {offset}"),
        Inst::ContextStore { offset, value } => format!("    contextstore {offset} %{value}"),
        Inst::Move { dst, src } => format!("    %{dst} = move %{src}"),
        Inst::Closure { dst, func, captures } => format!("    %{dst} = closure {func}{}", regs(captures)),
        Inst::Guard { kind, value, context } => format!("    guard {} %{value} {}", kind.name(), quote(context)),
        Inst::GuardBool { value } => format!("    guardbool %{value}"),
        Inst::Op { dst, op, args } => format!("    %{dst} = op {}{}", op.spelling(), regs(args)),
        Inst::Call { dst, func, args, .. } => format!("    %{dst} = call {func}{}", regs(args)),
        Inst::CallEnv { dst, func, closure, args, .. } => {
            format!("    %{dst} = callenv {func} %{closure}{}", regs(args))
        }
        Inst::CallValue { dst, callee, args } => format!("    %{dst} = callvalue %{callee}{}", regs(args)),
        Inst::ForeignCall { dst, foreign, args, exposed, discard, varargs } => {
            let mut line = format!("    %{dst} = foreigncall {foreign}{}", regs(args));
            let shown = positions(exposed).replace(' ', ",");
            if !shown.is_empty() {
                let _ = write!(line, " exposed={shown}");
            }
            if !varargs.is_empty() {
                let list: Vec<String> =
                    varargs.iter().map(|v| format!("{}:{}", cabi(v.class), cabi(v.promoted))).collect();
                let _ = write!(line, " varargs={}", list.join(","));
            }
            if *discard {
                line.push_str(" discard");
            }
            line
        }
        Inst::CallMulti { dsts, func, args, .. } => {
            format!("   {} = callmulti {func}{}", regs(dsts), regs(args))
        }
        Inst::CallEnvMulti { dsts, func, closure, args, .. } => {
            format!("   {} = callenvmulti {func} %{closure}{}", regs(dsts), regs(args))
        }
        Inst::Tail { args } => format!("    tail{}", regs(args)),
        Inst::TailEnv { closure, args } => format!("    tailenv %{closure}{}", regs(args)),
        Inst::Br { cond, then, otherwise } => format!("    br %{cond} L{then} L{otherwise}"),
        Inst::Switch { value, default, cases } => {
            let cases: Vec<String> = cases.iter().map(|(lo, hi, l)| format!("{lo}:{hi}:L{l}")).collect();
            format!("    switch %{value} L{default} {}", cases.join(" "))
        }
        Inst::Jump(l) => format!("    jump L{l}"),
        Inst::Ret(r) => format!("    ret %{r}"),
        Inst::RetMulti(rs) => format!("    retmulti{}", regs(rs)),
        Inst::Raise { kind, message } => format!("    raise {kind} {}", quote(message)),
        Inst::Unreachable => "    unreachable".to_string(),
        Inst::Fail { id, name, shape, payload } => {
            if payload.is_empty() {
                format!("    faildeclared {id} {}", quote(name))
            } else {
                format!("    faildeclared {id} {} {shape}{}", quote(name), regs(payload))
            }
        }
        Inst::DeclaredPayload { dst, index } => format!("    %{dst} = declaredpayload {index}"),
        Inst::DeclaredErrorEq { dst, id } => format!("    %{dst} = declarederroreq {id}"),
        Inst::ClearDeclaredError => "    cleardeclarederror".to_string(),
        Inst::PushErrorExit(l) => format!("    pusherrorexit L{l}"),
        Inst::PopErrorExit => "    poperrorexit".to_string(),
        Inst::Construct { dst, list, plan, pieces } => {
            let mut line = format!(
                "    %{dst} = construct {} {}",
                if *list { "list" } else { "str" },
                if *plan { "plan" } else { "flat" }
            );
            for piece in pieces {
                match piece {
                    Piece::Span(r) => {
                        let _ = write!(line, " %{r}");
                    }
                    Piece::Region(b, s, e) => {
                        let _ = write!(line, " region %{b} %{s} %{e}");
                    }
                    Piece::Elem(r) => {
                        let _ = write!(line, " elem %{r}");
                    }
                }
            }
            line
        }
        Inst::StructNew { dst, shape, fields } => format!("    %{dst} = structnew {shape}{}", regs(fields)),
        Inst::StructGet { dst, slot, value } => format!("    %{dst} = structget {slot} %{value}"),
        Inst::Reraise => "    reraise".to_string(),
    }
}

/// Function F of PROGRAM as a NIR `func` section, `end` included.
pub fn function(program: &Program, f: &Function) -> String {
    let mut text = header(f);
    text.push('\n');
    for (i, instruction) in f.body.iter().enumerate() {
        text.push_str(&inst(program, instruction));
        if let Some(Some(origin)) = f.origins.get(i) {
            if !matches!(instruction, Inst::Label(_)) {
                let _ = write!(text, " @e{origin}");
            }
        }
        text.push('\n');
    }
    text.push_str("end\n");
    text
}

/// PROGRAM as NIR text: ORIGINAL's header and declarations (every line
/// outside its `func` ... `end` sections, in order), then every function as
/// it now is.
pub fn program_text(original: &str, program: &Program) -> String {
    let mut text = String::new();
    let mut inside = false;
    for line in original.lines() {
        let trimmed = line.trim_start();
        if !inside && trimmed.starts_with("func ") {
            inside = true;
        } else if inside {
            if trimmed == "end" {
                inside = false;
            }
        } else {
            text.push_str(line);
            text.push('\n');
        }
    }
    for f in &program.functions {
        text.push_str(&function(program, f));
        text.push('\n');
    }
    text
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::nir;

    const SAMPLE: &str = concat!(
        "nir 1 call-effects=1 statics=0\n",
        "shape 0 named \"V\" fields=\"n\"\n",
        "\n",
        "func 0 \"<program>\" params=0 env=0 regs=2 pnames=\"\" captures=0 rawregs=\"0\"\n",
        "    %0 = rawint 10 @e43\n",
        "    %1 = call 1 %0 @e41\n",
        "    ret %1\n",
        "end\n",
        "func 1 \"f\" params=1 env=0 regs=9 pnames=\"m\" captures=0 rawregs=\"0 2\" rawparams=\"0\"\n",
        "    %1 = op rbox %0\n",
        "    %2 = rawint 3\n",
        "    %3 = str \"a\\\"b\\n\\u{1}\"\n",
        "    %4 = structnew 0 %1 @e7\n",
        "    pusherrorexit L1\n",
        "    %5 = op strlen %3\n",
        "    poperrorexit\n",
        "    jump L2\n",
        "  label L1\n",
        "    %6 = declarederroreq 3\n",
        "    br %6 L3 L4\n",
        "  label L3\n",
        "    cleardeclarederror\n",
        "    %5 = int -12345678901234567890\n",
        "    jump L2\n",
        "  label L4\n",
        "    reraise\n",
        "  label L2\n",
        "    %7 = structget 0 %4\n",
        "    %8 = op iadd %7 %5\n",
        "    ret %8\n",
        "end\n",
    );

    #[test]
    fn printed_functions_parse_back_to_the_same_text() {
        let program = nir::parse(SAMPLE).unwrap_or_else(|e| panic!("{e}"));
        let text = program_text(SAMPLE, &program);
        let again = nir::parse(&text).unwrap_or_else(|e| panic!("{e}\n{text}"));
        assert_eq!(program_text(SAMPLE, &again), text);
        assert!(text.contains("%1 = call 1 %0 @e41"), "{text}");
        assert!(text.contains("rawregs=\"0 2\" rawparams=\"0\""), "{text}");
        assert!(text.contains("%3 = str \"a\\\"b\\n\\u{1}\""), "{text}");
    }
}
