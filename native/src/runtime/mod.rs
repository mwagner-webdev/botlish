//! The Botlish native runtime: value representation, heap, errors and the
//! helper ABI generated code calls. Independent of Cranelift.

pub mod aot;
pub mod aotimage;
pub mod affine;
pub mod bytesobj;
pub mod constants;
pub mod construct;
pub mod coroutine;
pub mod decimal;
pub mod error;
pub mod ffi;
pub mod ffifixture;
pub mod framemap;
pub mod framewalk;
pub mod heap;
pub mod inttext;
pub mod metrics;
pub mod mutvec;
pub mod native_stack;
pub mod nview;
#[cfg(any(all(target_os = "linux", any(target_arch = "x86_64", target_arch = "aarch64")), all(target_os = "macos", target_arch = "aarch64"), all(windows, target_arch = "x86_64", target_env = "msvc")))]
pub mod platform;
pub mod ops;
pub mod show;
pub mod strobj;
pub mod syscall;
#[cfg(test)]
mod string_alloc_tests;
pub mod value;
pub mod vm;
