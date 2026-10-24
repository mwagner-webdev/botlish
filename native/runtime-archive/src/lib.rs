//! botlish-runtime: the runtime archive of system-linked executables
//! (SINGLE-EXECUTABLE-FFI-MILESTONE-1.md, codegen/aot.rs's `link_system`).
//!
//! A static library of botlish-native's runtime (runtime/: values, the heap
//! and collector, the helpers the generated code calls, coroutines, the
//! stack guard, `aot::run`) and of Rust's standard library, built once with
//! the compiler, never when an application is linked. The host's linker
//! links it with the program object -- which carries the program's startup
//! data, its `botlish_program` record (runtime::program) -- and the
//! program's C libraries into an ordinary executable, whose C startup calls
//! `main` below. No code generator is in it: the driver's Cranelift is not
//! part of botlish-native's library.

#[cfg(not(test))]
use botlish_native::runtime::{aot, program};
#[cfg(not(test))]
use std::os::raw::{c_char, c_int};

#[cfg(not(test))]
unsafe extern "C" {
    /// The program object's record (runtime::program::LinkedProgram), as
    /// the rustc linker's startup crate names it.
    static botlish_program: program::LinkedProgram;
}

/// The executable's `main`, called by the C runtime's startup (crt1's
/// `_start`, libSystem's, `mainCRTStartup`): the program, run with the
/// process's arguments (aot::linked_main). (Not in a test build of this
/// crate, `cargo test --lib`'s, whose harness has a `main` of its own.)
#[cfg(not(test))]
#[unsafe(no_mangle)]
pub extern "C" fn main(_argc: c_int, _argv: *const *const c_char) -> c_int {
    // SAFETY: the linker resolved botlish_program to the program object's
    // record, the one object that defines it, relocated by this link.
    unsafe { aot::linked_main(&*std::ptr::addr_of!(botlish_program)) }
}
