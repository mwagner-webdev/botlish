//! Structured runtime errors.
//!
//! Generated code and runtime helpers never format an error when it happens:
//! they record an `RtError` (keeping the offending values, which stay GC
//! roots) and return `NO_VALUE`, and every caller propagates that. The error
//! is rendered once, at the program boundary, as the error code and message
//! the reference runtime raises (core/errors.tcl).

use super::show::show;
use super::value::*;

#[derive(Debug, Clone)]
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
    /// A C function returned an address no C address word can hold
    /// (runtime/ffi.rs, C-FFI.md): never truncated or masked.
    ForeignAddress(String),
    /// A C function returned a _Bool result byte other than 0 or 1
    /// (runtime/ffi.rs, C-FFI.md): no C compiler produces one, so the
    /// declaration does not describe the function.
    ForeignBool(String),
    /// A C function broke its declared contract where a run can see it: a
    /// result declared an alias of a pointer argument that is not
    /// (runtime/ffi.rs, C-FFI.md).
    ContractViolation(String),
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
/// `NonFiniteFloat` (builtin error 4): a floating-point operation whose
/// result is not a finite number (runtime::ops's float operations,
/// FLOAT64-MILESTONE-1.md), or a C double that is not one entering Botlish
/// (codegen::clif's foreign-call results).
pub const ERR_NON_FINITE_FLOAT: u32 = BUILTIN_ERROR_ID_BASE + 4;
/// `UnrepresentableDecimal` (builtin error 9, after the binary errors): a quantization to a
/// DecimalRounded value whose decimal no binary64 holds to the requested
/// number of places (runtime::decimal's rt_decimal_round,
/// DECIMAL-ROUNDED-MILESTONE-1.md).
pub const ERR_UNREPRESENTABLE_DECIMAL: u32 = BUILTIN_ERROR_ID_BASE + 9;
/// `LengthMismatch` (builtin error 10): `list#with_length`'s List does not
/// have the length its imprint states (runtime::ops's rt_list_with_length,
/// LIST-CARDINALITY-REFINEMENTS.md).
pub const ERR_LENGTH_MISMATCH: u32 = BUILTIN_ERROR_ID_BASE + 10;
/// `InvalidIntegerText` (builtin error 11): `std::int::from_string`'s text is
/// not the canonical decimal text of an Int (runtime::inttext's
/// rt_str_to_int, NUMERIC-TEXT-BOUNDARY-MILESTONE-1.md).
pub const ERR_INVALID_INTEGER_TEXT: u32 = BUILTIN_ERROR_ID_BASE + 11;

/// Semantic error kinds of core/errors.tcl that NIR may raise.
pub const SEMANTIC_KINDS: &[&str] = &[
    "UNBOUND", "DUPLICATE", "NOT-CALLABLE", "ARITY", "NOT-BOOLEAN", "TYPE", "EQUALITY", "RANGE",
    "ARITHMETIC", "BREAK-OUTSIDE-LOOP", "CONTINUE-OUTSIDE-LOOP", "RETURN-OUTSIDE-CALLABLE", "UNCAUGHT-ERROR",
    // A -strict 0 program's rejected lockstep loop, replayed at run time
    // (native::lower::LockLoop, as hir::lower / core::forms::op-lockloop do).
    "LOCKSTEP-UNPROVEN", "LOCKSTEP-UNEQUAL",
    // A -strict 0 program's rejected linux::abi::x86_64::syscall register struct,
    // replayed at run time (native::lower::SyscallCall; hir/syscall.tcl).
    "UNKNOWN-FIELD", "MISSING-FIELD",
    // A -strict 0 program that failed context verification (CONTEXTS.md),
    // replayed when it starts (native::lower's ContextDiagnostic).
    "MISSING-CONTEXT", "DUPLICATE-CONTEXT", "NOT-A-CONTEXT", "CONTEXT-TYPE-NOT-EXACT",
    "CONTEXT-INSTALLATION-UNSUPPORTED", "CONTEXT-FUNCTION-VALUE", "CONTEXT-BINDING-COLLISION",
    "DUPLICATE-CONTEXT-PARAMETER",
    // Coroutine lifecycle states a checked program cannot reach (the affine
    // discipline, COROUTINES.md), kept as defensive runtime checks.
    "COROUTINE-RUNNING", "COROUTINE-STATE", "YIELD-OUTSIDE-COROUTINE",
    // A -strict 0 program's rejected binary operation, native view or
    // layout write (BINARY-LAYOUT.md, NATIVE-LAYOUT-VIEWS.md,
    // NATIVE-LAYOUT-WRITES.md), replayed at run time
    // (native::lower::LayoutCall).
    "BINARY-OPERAND", "LAYOUT-NATIVE-ONLY", "LAYOUT-FOREIGN-WRITE", "LAYOUT-OPERAND",
    // ... and a copy of a union (LAYOUT-UNIONS.md: no copied value).
    "LAYOUT-UNION",
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
            RtError::ForeignAddress(_) => vec!["NATIVE", "ADDRESS"],
            RtError::ForeignBool(_) => vec!["NATIVE", "BOOL"],
            RtError::ContractViolation(_) => vec!["NATIVE", "CONTRACT-VIOLATION"],
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
            RtError::Unsupported(message) | RtError::Bug(message) | RtError::ForeignAddress(message)
            | RtError::ForeignBool(message) | RtError::ContractViolation(message) => message.clone(),
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
