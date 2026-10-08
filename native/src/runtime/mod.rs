//! The Botlish native runtime: value representation, heap, errors and the
//! helper ABI generated code calls. Independent of Cranelift.

pub mod aot;
pub mod affine;
pub mod bytesobj;
pub mod constants;
pub mod construct;
pub mod coroutine;
pub mod error;
pub mod framemap;
pub mod framewalk;
pub mod heap;
pub mod metrics;
pub mod native_stack;
#[cfg(all(target_arch = "x86_64", target_os = "linux"))]
pub mod platform;
pub mod ops;
pub mod show;
pub mod strobj;
pub mod syscall;
#[cfg(test)]
mod string_alloc_tests;
pub mod value;
pub mod vm;
