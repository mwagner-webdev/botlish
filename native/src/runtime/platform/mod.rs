//! The native stack's platform layer (MACOS-AARCH64-MILESTONE-4.md,
//! WINDOWS-X86-64-MILESTONE-4.md): how each host finds the bounds of the
//! current thread's stack and names a thread (`linux`, `macos`, `windows`),
//! and the stack-overflow guard that turns an exhausted stack into NATIVE
//! LIMIT STACK. The guard has one contract on every host -- `OverflowGuard`
//! installed on the thread that runs Botlish code for as long as it runs
//! it, in the driver's mode or an executable's; `set_result_file` for the
//! driver's `--result` file; the same line, `OVERFLOW_LINE`, and the same
//! exit statuses; nothing else ever relabelled -- and one mechanism per
//! exception model: POSIX signals on an alternate stack for Linux and macOS
//! (`guard`), a vectored exception handler for Windows' STATUS_STACK_OVERFLOW
//! (`windows`). runtime::native_stack is the one stack representation they
//! fill; everything above this module is host-independent.
#[cfg(all(target_os = "linux", any(target_arch = "x86_64", target_arch = "aarch64")))]
pub mod linux;
#[cfg(all(target_os = "macos", target_arch = "aarch64"))]
pub mod macos;
#[cfg(all(windows, target_arch = "x86_64", target_env = "msvc"))]
pub mod windows;
#[cfg(unix)]
mod guard;

#[cfg(unix)]
pub use guard::{published_stack, set_active_stack, set_result_file, OverflowGuard};
#[cfg(all(target_os = "linux", any(target_arch = "x86_64", target_arch = "aarch64")))]
pub use linux::{current_stack, thread_token};
#[cfg(all(target_os = "macos", target_arch = "aarch64"))]
pub use macos::{current_stack, thread_token};
#[cfg(all(windows, target_arch = "x86_64", target_env = "msvc"))]
pub use windows::{current_stack, set_result_file, thread_token, OverflowGuard};

/// What every host's guard writes for an exhausted stack: the driver's
/// result line for RtError::StackOverflow (runtime/error.rs), so that the
/// host reads it the ordinary way; a standalone executable writes the same
/// line to its standard error.
pub(crate) const OVERFLOW_LINE: &[u8] = b"error {NATIVE LIMIT STACK} {native stack exhausted: too many nested calls}\n";

#[cfg(test)]
mod tests {
    /// The guard's line is the driver's own line for RtError::StackOverflow.
    #[test]
    fn the_overflow_line_is_the_drivers_line_for_a_stack_overflow() {
        use crate::runtime::error::RtError;
        use crate::runtime::show::tcl_list;
        let error = RtError::StackOverflow;
        let code: Vec<String> = error.error_code().iter().map(|w| w.to_string()).collect();
        let line = tcl_list(&["error".to_string(), tcl_list(&code), error.message()]) + "\n";
        assert_eq!(line.as_bytes(), super::OVERFLOW_LINE);
    }
}
