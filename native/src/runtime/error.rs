//! Structured runtime errors.
//!
//! Generated code and runtime helpers never format an error when it happens:
//! they record an `RtError` (keeping the offending values, which stay GC
//! roots) and return `NO_VALUE`, and every caller propagates that. The error
//! is rendered once, at the program boundary, as the error code and message
//! the reference runtime raises (core/errors.tcl).

use super::show::show;
use super::value::*;

#[derive(Debug)]
pub enum RtError {
    /// `core::value::expect`: CONTEXT: expected KIND, got VALUE.
    Type { context: String, expected: Kind, got: Value },
    /// A Result of the wrong tag (result-value, result-error).
    ResultTag { context: &'static str, expected_ok: bool, got: Value },
    NotBoolean { got: Value },
    NotCallable { got: Value },
    Equality { a: Value, b: Value },
    /// `core::hashing::hash`: a value with no defined equality also has no
    /// defined hash (same restriction as Equality, one value instead of two).
    Unhashable { value: Value },
    /// Any other semantic error whose message is fully known: RANGE, ARITY,
    /// UNBOUND, DUPLICATE, ...
    Semantic { kind: &'static str, message: String },
    StackOverflow,
    /// A value native code cannot hand back to the host (a Block).
    Unsupported(String),
    /// An internal invariant failed: a backend bug.
    Bug(String),
}

/// Semantic error kinds of core/errors.tcl that NIR may raise.
pub const SEMANTIC_KINDS: &[&str] = &[
    "UNBOUND", "DUPLICATE", "NOT-CALLABLE", "ARITY", "NOT-BOOLEAN", "TYPE", "EQUALITY", "RANGE",
    "ARITHMETIC", "BREAK-OUTSIDE-LOOP", "CONTINUE-OUTSIDE-LOOP", "RETURN-OUTSIDE-CALLABLE", "UNCAUGHT-ERROR",
];

pub fn semantic_kind(name: &str) -> Option<&'static str> {
    SEMANTIC_KINDS.iter().copied().find(|k| *k == name)
}

impl RtError {
    /// The error code, as a Tcl -errorcode list of words.
    pub fn error_code(&self) -> Vec<&'static str> {
        match self {
            RtError::Type { .. } | RtError::ResultTag { .. } => vec!["CORE", "SEMANTIC", "TYPE"],
            RtError::NotBoolean { .. } => vec!["CORE", "SEMANTIC", "NOT-BOOLEAN"],
            RtError::NotCallable { .. } => vec!["CORE", "SEMANTIC", "NOT-CALLABLE"],
            RtError::Equality { .. } | RtError::Unhashable { .. } => vec!["CORE", "SEMANTIC", "EQUALITY"],
            RtError::Semantic { kind, .. } => vec!["CORE", "SEMANTIC", kind],
            RtError::StackOverflow => vec!["NATIVE", "LIMIT", "STACK"],
            RtError::Unsupported(_) => vec!["NATIVE", "UNSUPPORTED", "value"],
            RtError::Bug(_) => vec!["NATIVE", "BUG"],
        }
    }

    pub fn message(&self) -> String {
        match self {
            RtError::Type { context, expected, got } => {
                format!("{context}: expected {}, got {}", expected.name(), show(*got))
            }
            RtError::ResultTag { context, expected_ok, got } => format!(
                "{context}: expected {} Result, got {}",
                if *expected_ok { "an ok" } else { "an error" },
                show(*got)
            ),
            RtError::NotBoolean { got } => format!("if condition must be a Boolean, got {}", show(*got)),
            RtError::NotCallable { got } => format!("cannot call non-callable value {}", show(*got)),
            RtError::Equality { a, b } => {
                format!("== is not defined for callables: {} == {}", show(*a), show(*b))
            }
            RtError::Unhashable { value } => {
                format!("hash is not defined for callables: {}", show(*value))
            }
            RtError::Semantic { message, .. } => message.clone(),
            RtError::StackOverflow => "native stack exhausted: too many nested calls".to_string(),
            RtError::Unsupported(message) | RtError::Bug(message) => message.clone(),
        }
    }

    /// Values the error refers to (GC roots while it is pending).
    pub fn values(&self) -> Vec<Value> {
        match self {
            RtError::Type { got, .. }
            | RtError::ResultTag { got, .. }
            | RtError::NotBoolean { got }
            | RtError::NotCallable { got } => vec![*got],
            RtError::Equality { a, b } => vec![*a, *b],
            RtError::Unhashable { value } => vec![*value],
            _ => vec![],
        }
    }
}
