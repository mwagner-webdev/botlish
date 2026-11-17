//! Bounds and ownership of a native execution stack.
#[allow(dead_code)] // Suspended is reserved for future coroutine stacks.
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum StackState { Active, Suspended }

#[derive(Clone, Copy, Debug)]
pub struct NativeStack {
    pub low_bound: usize,
    pub high_bound: usize,
    pub guard_low: usize,
    #[allow(dead_code)] // Dormant until a stack can be suspended.
    pub saved_sp: Option<usize>,
    pub state: StackState,
}

impl NativeStack {
    pub fn contains(&self, address: usize, size: usize) -> bool {
        address >= self.low_bound && address.checked_add(size).is_some_and(|end| end <= self.high_bound)
    }

    #[allow(dead_code)] // Also exercised by the bounds tests.
    pub fn is_guard_fault(&self, address: usize) -> bool {
        self.state == StackState::Active && address >= self.guard_low && address < self.low_bound
    }

    /// The calling thread's own stack, as its host reports it
    /// (runtime::platform): on Linux and macOS with the guard confirmed below
    /// it; on Windows the whole reservation the system made for it, which
    /// grows by Windows' own guard page (no guard range: `guard_low ==
    /// low_bound`, platform/windows.rs).
    #[cfg(any(any(all(target_os = "linux", any(target_arch = "x86_64", target_arch = "aarch64")), all(target_os = "android", target_arch = "aarch64")), all(target_os = "macos", target_arch = "aarch64"), all(windows, target_arch = "x86_64", target_env = "msvc")))]
    pub fn current() -> std::io::Result<Self> { super::platform::current_stack() }

    /// The lowest stack pointer a library's checked frame may run at on this
    /// stack (codegen::clif's `prologue_stack_limit`; NATIVE-LIBRARY-
    /// MILESTONE-1.md, "Stack safety"): its low bound plus a reserve of an
    /// eighth of its size, at least 64 KiB and at most 1 MiB. Below a checked
    /// frame there may run one more Botlish frame (allocated and probed
    /// before it checks), frames that make no Botlish call, the runtime's
    /// helpers (the collector's marking is iterative) and, when the check
    /// fails, the way back to the host.
    pub fn stack_limit(&self) -> usize {
        let size = self.high_bound.saturating_sub(self.low_bound);
        self.low_bound + (size / 8).clamp(64 << 10, 1 << 20)
    }
}

/// The hosts whose stack-overflow guard turns an exhausted native stack into
/// NATIVE LIMIT STACK (runtime::platform): Linux x86-64 and AArch64 and macOS
/// AArch64 (MACOS-AARCH64-MILESTONE-4.md: a signal handler on an alternate
/// stack) and Windows x86-64 with MSVC's toolchain
/// (WINDOWS-X86-64-MILESTONE-4.md: a vectored handler of
/// STATUS_STACK_OVERFLOW in the thread's stack guarantee). Generated code
/// probes every page of a frame larger than one (codegen::stack_probes), so
/// no frame steps over the system's guard. Together with the native-frame
/// GC walk (runtime::framewalk's NATIVE_FRAME_ROOTS) it replaces the shadow
/// stack's depth check (codegen::roots's `depth_reservation` needs both).
pub const fn native_stack_overflow_supported() -> bool {
    cfg!(any(
        any(all(target_os = "linux", any(target_arch = "x86_64", target_arch = "aarch64")), all(target_os = "android", target_arch = "aarch64")),
        all(target_os = "macos", target_arch = "aarch64"),
        all(windows, target_arch = "x86_64", target_env = "msvc")
    ))
}

/// Native-frame roots and the stack guard are two capabilities, but a host
/// with the first needs the second: with the roots in native frames nothing
/// else bounds recursion (the shadow stack holds nothing, and its depth
/// check is the fallback plan's). A new host starts on the fallback plan.
const _: () = assert!(
    !super::framewalk::NATIVE_FRAME_ROOTS || native_stack_overflow_supported(),
    "native-frame GC roots need the native stack guard"
);

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn bounds_exclude_guard_and_check_end_before_dereference() {
        let stack = NativeStack { low_bound: 0x2000, high_bound: 0x4000, guard_low: 0x1000,
            saved_sp: None, state: StackState::Active };
        assert!(stack.contains(0x2000, 8));
        assert!(stack.contains(0x3ff8, 8));
        assert!(!stack.contains(0x3ff9, 8));
        assert!(!stack.contains(0x1ff8, 8));
        assert!(stack.is_guard_fault(0x1000));
        assert!(stack.is_guard_fault(0x1fff));
        assert!(!stack.is_guard_fault(0x2000));
        assert!(!stack.is_guard_fault(0));
        let suspended = NativeStack { state: StackState::Suspended, ..stack };
        assert!(!suspended.is_guard_fault(0x1fff));
    }

    /// Recursion is bounded by the guard on both root plans of every host
    /// the native backend runs on: a depth token exists only where nothing
    /// but the shadow stack bounds it (runtime::capabilities).
    #[test]
    fn the_depth_is_checked_only_without_the_guard() {
        use crate::runtime::capabilities::{RootMode, RuntimeCapabilities};
        let host = RuntimeCapabilities::host();
        assert_eq!(host.stack_guard, native_stack_overflow_supported());
        assert_eq!(host.prologue_may_fail(), !native_stack_overflow_supported());
        if let RootMode::ShadowOnly { depth_token } = host.root_mode() {
            assert_eq!(depth_token, !native_stack_overflow_supported());
        }
    }
}
