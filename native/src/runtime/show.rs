//! Rendering values: Botlish display (core::value::show, for messages) and
//! the host's runtime value representation (core/value.tcl tagged Tcl lists),
//! which is how a native program hands its value back to Tcl.

use super::error::RtError;
use super::value::*;
use super::vm::current_program;

/// `core::value::show V` (without evidence: native strings carry none).
pub fn show(v: Value) -> String {
    let mut out = String::new();
    show_into(v, &mut out);
    out
}

fn show_into(v: Value, out: &mut String) {
    match kind_of(v) {
        Kind::Int => out.push_str(&int_text(v)),
        Kind::Str => {
            out.push('"');
            for c in str_of(v).text.chars() {
                match c {
                    '\\' => out.push_str("\\\\"),
                    '"' => out.push_str("\\\""),
                    '\n' => out.push_str("\\n"),
                    '\t' => out.push_str("\\t"),
                    c => out.push(c),
                }
            }
            out.push('"');
        }
        Kind::Bool => out.push_str(if v == TRUE { "true" } else { "false" }),
        Kind::Unit => out.push_str("unit"),
        Kind::List => {
            out.push('[');
            for (i, item) in list_of(v).items.iter().enumerate() {
                if i > 0 {
                    out.push_str(", ");
                }
                show_into(*item, out);
            }
            out.push(']');
        }
        Kind::Result => {
            let r = result_of(v);
            out.push_str(if r.ok { "ok(" } else { "error(" });
            show_into(r.payload, out);
            out.push(')');
        }
        Kind::Block => {
            let c = closure_of(v);
            let pnames = current_program(|p| p.functions[c.func as usize].pnames.clone());
            out.push_str(&format!("<block ({pnames})>"));
        }
        Kind::Native => {
            let n = unsafe { as_ref::<NativeObj>(v) };
            let name = current_program(|p| p.natives[n.native as usize].name.clone());
            out.push_str(&format!("<native {name}>"));
        }
        Kind::MutArray => {
            out.push_str(&format!("<mutable-array capacity={}>", mutarray_of(v).slots.len()));
        }
    }
}

pub fn int_text(v: Value) -> String {
    match int_small(v) {
        Some(n) => n.to_string(),
        None => int_to_big(v).to_string(),
    }
}

/// V as the host runtime value (a Tcl list such as `int 5` or `str {a b}`).
pub fn tcl_value(v: Value) -> Result<String, RtError> {
    Ok(match kind_of(v) {
        Kind::Int => tcl_list(&["int".to_string(), int_text(v)]),
        Kind::Str => tcl_list(&["str".to_string(), str_of(v).text.to_string()]),
        Kind::Bool => tcl_list(&["bool".to_string(), (if v == TRUE { "true" } else { "false" }).to_string()]),
        Kind::Unit => "unit".to_string(),
        Kind::List => {
            let items = list_of(v).items.iter().map(|item| tcl_value(*item)).collect::<Result<Vec<_>, _>>()?;
            tcl_list(&["list".to_string(), tcl_list(&items)])
        }
        Kind::Result => {
            let r = result_of(v);
            tcl_list(&[
                "result".to_string(),
                (if r.ok { "ok" } else { "error" }).to_string(),
                tcl_value(r.payload)?,
            ])
        }
        Kind::Native => {
            let n = unsafe { as_ref::<NativeObj>(v) };
            let name = current_program(|p| p.natives[n.native as usize].name.clone());
            tcl_list(&["native".to_string(), name])
        }
        Kind::Block => {
            return Err(RtError::Unsupported(format!(
                "the native backend cannot return a Block to the host: {}",
                show(v)
            )));
        }
        Kind::MutArray => {
            return Err(RtError::Unsupported(format!(
                "the native backend cannot return a MutableArray to the host (finalize it to a List first): {}",
                show(v)
            )));
        }
    })
}

/// WORDS as a Tcl list.
pub fn tcl_list(words: &[String]) -> String {
    words.iter().map(|w| tcl_element(w)).collect::<Vec<_>>().join(" ")
}

/// S quoted as one element of a Tcl list.
pub fn tcl_element(s: &str) -> String {
    if s.is_empty() {
        return "{}".to_string();
    }
    let special = |c: char| matches!(c, ' ' | '\t' | '\n' | '\r' | ';' | '$' | '[' | ']' | '{' | '}' | '"' | '\\');
    if !s.contains(special) && !s.starts_with('#') {
        return s.to_string();
    }
    // Every output record must stay on one line, so line breaks are escaped.
    if !s.contains(['\n', '\r']) && braces_ok(s) {
        return format!("{{{s}}}");
    }
    let mut out = String::with_capacity(s.len() + 8);
    for c in s.chars() {
        match c {
            '\n' => out.push_str("\\n"),
            '\t' => out.push_str("\\t"),
            '\r' => out.push_str("\\r"),
            c if special(c) || c == '#' => {
                out.push('\\');
                out.push(c);
            }
            c => out.push(c),
        }
    }
    out
}

/// Whether S can be written as {S}: no backslash, balanced braces.
fn braces_ok(s: &str) -> bool {
    let mut depth = 0i64;
    for c in s.chars() {
        match c {
            '\\' => return false,
            '{' => depth += 1,
            '}' => {
                depth -= 1;
                if depth < 0 {
                    return false;
                }
            }
            _ => {}
        }
    }
    depth == 0
}
