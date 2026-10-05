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
            for c in str_of(v).as_str().chars() {
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
        Kind::UnicodeChar => {
            // Matches core::value::show's UnicodeChar rendering exactly
            // (core/value.tcl): single-quoted, the same escape vocabulary
            // as a character literal.
            out.push('\'');
            let c = char::from_u32(char_of(v)).expect("UnicodeChar payload is a valid Unicode scalar value");
            match c {
                '\\' => out.push_str("\\\\"),
                '\'' => out.push_str("\\'"),
                '\n' => out.push_str("\\n"),
                '\r' => out.push_str("\\r"),
                '\t' => out.push_str("\\t"),
                c => out.push(c),
            }
            out.push('\'');
        }
        Kind::List => {
            out.push('[');
            for (i, item) in list_of(v).items().iter().enumerate() {
                if i > 0 {
                    out.push_str(", ");
                }
                show_into(*item, out);
            }
            out.push(']');
        }
        Kind::Struct => {
            // Matches core::value::show's struct rendering exactly
            // (core/value.tcl): `{name: "Grace", age: 45}` for an anonymous
            // struct (fields in canonical order), `Person {name: "Ada",
            // age: 36}` for a named one (declared slot order).
            let obj = struct_of(v);
            let (name, fields, opaque) = current_program(|prog| {
                let shape = &prog.shapes[obj.shape as usize];
                (shape.name.clone(), shape.fields.clone(), shape.opaque)
            });
            if opaque {
                // An opaque struct (OPAQUE-STRUCTS.md) is rendered by its
                // nominal type only, as core::value::show does: normal
                // user-facing text never dumps a private representation.
                // (`tcl_value`, the host's runtime value, stays complete.)
                out.push_str(&format!("<opaque {}>", name.unwrap_or_default()));
                return;
            }
            if let Some(name) = name {
                out.push_str(&name);
                out.push(' ');
            }
            out.push('{');
            for (i, (field, item)) in fields.iter().zip(obj.fields().iter()).enumerate() {
                if i > 0 {
                    out.push_str(", ");
                }
                out.push_str(field);
                out.push_str(": ");
                show_into(*item, out);
            }
            out.push('}');
        }
        Kind::ImmutableSet => {
            // Matches core::value::show's ImmutableSet rendering exactly
            // (core/value.tcl): braces, punctuation only -- no semantic
            // ordering is implied (MINIMAL-IMMUTABLE-SET.md item 87).
            out.push('{');
            for (i, item) in set_of(v).items().iter().enumerate() {
                if i > 0 {
                    out.push_str(", ");
                }
                show_into(*item, out);
            }
            out.push('}');
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
        Kind::ByteStore => {
            // Matches core::value::show's bytestore rendering exactly: the
            // byte count and the bytes in lowercase hex. Reached only for a
            // storage shown on its own (internal tooling): an opaque
            // abi::Bytes renders as `<opaque abi::Bytes>` above and never
            // prints its storage.
            let bytes = bytes_of(v);
            out.push_str(&format!("<bytes {}: {}>", bytes.len(), hex_of(bytes)));
        }
        Kind::MutByteStore => {
            // Matches core::value::show's mutbytes rendering (internal tooling
            // only; an opaque abi::MutableBytes renders as
            // `<opaque abi::MutableBytes>` and never prints its storage).
            let bytes = mutbytes_of(v);
            out.push_str(&format!("<mutbytes {}: {}>", bytes.len(), hex_of(bytes)));
        }
    }
}

/// Lowercase hexadecimal text of BYTES, two digits per byte (core/value.tcl's
/// `{bytestore HEX}` text).
pub fn hex_of(bytes: &[u8]) -> String {
    let mut out = String::with_capacity(bytes.len() * 2);
    for b in bytes {
        out.push_str(&format!("{b:02x}"));
    }
    out
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
        Kind::Str => tcl_list(&["str".to_string(), str_of(v).as_str().to_string()]),
        Kind::Bool => tcl_list(&["bool".to_string(), (if v == TRUE { "true" } else { "false" }).to_string()]),
        Kind::Unit => "unit".to_string(),
        // Matches core::value::char's own representation exactly
        // ({UnicodeChar CODEPOINT}, core/value.tcl), so a value crossing
        // back to the Tcl host round-trips through core::ir::literalValue
        // unchanged.
        Kind::UnicodeChar => tcl_list(&["UnicodeChar".to_string(), char_of(v).to_string()]),
        Kind::List => {
            let items = list_of(v).items().iter().map(|item| tcl_value(*item)).collect::<Result<Vec<_>, _>>()?;
            tcl_list(&["list".to_string(), tcl_list(&items)])
        }
        Kind::Struct => {
            // Matches core::value::structOf's own representation exactly
            // ({struct {ID FIELD...} VALUES}, core/value.tcl).
            let obj = struct_of(v);
            let (name, fields) = current_program(|prog| {
                let shape = &prog.shapes[obj.shape as usize];
                (shape.name.clone().unwrap_or_default(), shape.fields.clone())
            });
            let mut shape_words = vec![name];
            shape_words.extend(fields);
            let items = obj.fields().iter().map(|item| tcl_value(*item)).collect::<Result<Vec<_>, _>>()?;
            tcl_list(&["struct".to_string(), tcl_list(&shape_words), tcl_list(&items)])
        }
        Kind::ImmutableSet => {
            // Matches core::value::immutableSet's own representation
            // exactly ({immutableSet ITEMS}, core/value.tcl).
            let items = set_of(v).items().iter().map(|item| tcl_value(*item)).collect::<Result<Vec<_>, _>>()?;
            tcl_list(&["immutableSet".to_string(), tcl_list(&items)])
        }
        // Matches core::value::bytestore's own representation exactly
        // ({bytestore HEX}, core/value.tcl).
        Kind::ByteStore => tcl_list(&["bytestore".to_string(), hex_of(bytes_of(v))]),
        // ({mutbytes HEX}, core/value.tcl).
        Kind::MutByteStore => tcl_list(&["mutbytes".to_string(), hex_of(mutbytes_of(v))]),
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
