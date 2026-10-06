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

/// The NIR id of builtin error number INDEX (core::native::declareError's
/// declaration order, from 0): native/lower.tcl's `ErrorId` assigns exactly
/// these to the errors the runtime itself declares, far above the dense
/// 1-based ids of a program's own `error` declarations.
pub const BUILTIN_ERROR_ID_BASE: u32 = 0x4000_0000;
/// `InvalidArgumentEncoding`, the error of `argv()` (builtin error 0).
pub const ERR_INVALID_ARGUMENT_ENCODING: u32 = BUILTIN_ERROR_ID_BASE;
/// `IndexNotFound`, the error of `list::at`, `mutable_array::at` and
/// `mutable_array::set` (builtin error 1): the index does not designate an
/// element.
pub const ERR_INDEX_NOT_FOUND: u32 = BUILTIN_ERROR_ID_BASE + 1;
/// `LowerUnderrun` (builtin error 2): a slice bound below its interval
/// (runtime::ops's `check_slice`, core::native::checkSlice).
pub const ERR_LOWER_UNDERRUN: u32 = BUILTIN_ERROR_ID_BASE + 2;
/// `UpperOverrun` (builtin error 3): a slice bound above its interval.
pub const ERR_UPPER_OVERRUN: u32 = BUILTIN_ERROR_ID_BASE + 3;

/// Semantic error kinds of core/errors.tcl that NIR may raise.
pub const SEMANTIC_KINDS: &[&str] = &[
    "UNBOUND", "DUPLICATE", "NOT-CALLABLE", "ARITY", "NOT-BOOLEAN", "TYPE", "EQUALITY", "RANGE",
    "ARITHMETIC", "BREAK-OUTSIDE-LOOP", "CONTINUE-OUTSIDE-LOOP", "RETURN-OUTSIDE-CALLABLE", "UNCAUGHT-ERROR",
    // A -strict 0 program's rejected lockstep loop, replayed at run time
    // (native::lower::LockLoop, as hir::lower / core::forms::op-lockloop do).
    "LOCKSTEP-UNPROVEN", "LOCKSTEP-UNEQUAL",
    // A -strict 0 program's rejected linux::abi::syscall register struct,
    // replayed at run time (native::lower::SyscallCall; hir/syscall.tcl).
    "UNKNOWN-FIELD", "MISSING-FIELD",
    // A -strict 0 program that failed context verification (CONTEXTS.md),
    // replayed when it starts (native::lower's ContextDiagnostic).
    "MISSING-CONTEXT", "DUPLICATE-CONTEXT", "NOT-A-CONTEXT", "CONTEXT-TYPE-NOT-EXACT",
    "CONTEXT-INSTALLATION-UNSUPPORTED", "CONTEXT-FUNCTION-VALUE", "CONTEXT-BINDING-COLLISION",
    "DUPLICATE-CONTEXT-PARAMETER",
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
