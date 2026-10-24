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
    #[cfg(any(all(target_os = "linux", any(target_arch = "x86_64", target_arch = "aarch64")), all(target_os = "macos", target_arch = "aarch64"), all(windows, target_arch = "x86_64", target_env = "msvc")))]
    pub fn current() -> std::io::Result<Self> { super::platform::current_stack() }

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
        all(target_os = "linux", any(target_arch = "x86_64", target_arch = "aarch64")),
        all(target_os = "macos", target_arch = "aarch64"),
        all(windows, target_arch = "x86_64", target_env = "msvc")
    ))
}

/// Whether the shadow stack's depth check bounds Botlish recursion
/// (codegen::roots's `depth_reservation`) for code whose roots are in
/// native frames exactly when NATIVE_FRAME_ROOTS says so: unless they are
/// and the stack guard reports an exhausted stack, every function that
/// makes a Botlish call checks its depth in its prologue and fails with
/// NATIVE LIMIT STACK, an error its callers see (nir's call effects). Only
/// the fallback plan checks: its shadow stack, which holds the roots, is
/// the bound.
pub const fn depth_checked(native_frame_roots: bool) -> bool {
    !(native_frame_roots && native_stack_overflow_supported())
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

    /// Recursion is bounded by the guard wherever native frames hold the
    /// roots, by the shadow stack's depth check on the fallback plan.
    #[test]
    fn the_depth_is_checked_only_on_the_fallback_plan() {
        assert!(depth_checked(false), "the fallback plan's bound is the shadow stack's");
        assert_eq!(depth_checked(true), !native_stack_overflow_supported());
        assert_eq!(depth_checked(crate::runtime::framewalk::NATIVE_FRAME_ROOTS), !crate::runtime::framewalk::NATIVE_FRAME_ROOTS);
    }
}
