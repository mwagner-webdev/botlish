//! botlish-runtime: the runtime archive of system-linked executables
//! (SINGLE-EXECUTABLE-FFI-MILESTONE-1.md, codegen/aot.rs's `link_system`).
//!
//! A static library of botlish-native's runtime (runtime/: values, the heap
//! and collector, the helpers the generated code calls, coroutines, the
//! stack guard, `aot::run`) and of Rust's standard library, built once with
//! the compiler, never when an application is linked. The host's linker
//! links it with the program object, the startup object (the program's
//! description, `botlish_program_description`) and the program's C
//! libraries into an ordinary executable, whose C startup calls `main`
//! below. No code generator is in it: the driver's Cranelift is not part of
//! botlish-native's library.

#[cfg(not(test))]
use botlish_native::runtime::aotimage;
#[cfg(not(test))]
use std::os::raw::{c_char, c_int};

/// The startup interface this archive implements: every startup object
/// refers to it (aotimage::LINKED_INTERFACE_SYMBOL), so one of another
/// revision fails to link.
#[unsafe(no_mangle)]
pub static botlish_runtime_startup_v1: u8 = 1;

#[cfg(not(test))]
unsafe extern "C" {
    /// The program's description, the startup object's
    /// (aotimage::LINKED_HEADER describes it).
    static botlish_program_description: u8;
}

/// The executable's `main`, called by the C runtime's startup (crt1's
/// `_start`, libSystem's, `mainCRTStartup`): the program, run with the
/// process's arguments (aotimage::linked_main). (Not in a test build of this
/// crate, `cargo test --lib`'s, whose harness has a `main` of its own.)
#[cfg(not(test))]
#[unsafe(no_mangle)]
pub extern "C" fn main(_argc: c_int, _argv: *const *const c_char) -> c_int {
    // SAFETY: the linker resolved botlish_program_description to the
    // startup object's description, the one object that defines it.
    unsafe {
        aotimage::linked_main(
            std::ptr::addr_of!(botlish_program_description),
            std::ptr::addr_of!(botlish_runtime_startup_v1),
        )
    }
}
