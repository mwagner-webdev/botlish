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

    /// The calling thread's own stack, as its host reports it, with the guard
    /// confirmed below it (runtime::platform).
    #[cfg(any(all(target_os = "linux", any(target_arch = "x86_64", target_arch = "aarch64")), all(target_os = "macos", target_arch = "aarch64")))]
    pub fn current() -> std::io::Result<Self> { super::platform::current_stack() }

    /// The calling thread's own stack on Windows: the range the system
    /// reserved for it (`GetCurrentThreadStackLimits`), with no guard
    /// confirmed (`guard_low == low_bound`): Windows has no stack guard of
    /// Botlish's yet. Its bounds limit the frame walk and give the stack
    /// limit (`stack_limit`).
    #[cfg(all(windows, target_arch = "x86_64"))]
    pub fn current() -> std::io::Result<Self> {
        let (mut low, mut high) = (0, 0);
        // SAFETY: writes the two bounds.
        unsafe { windows_sys::Win32::System::Threading::GetCurrentThreadStackLimits(&mut low, &mut high) };
        Ok(NativeStack { low_bound: low, high_bound: high, guard_low: low, saved_sp: None, state: StackState::Active })
    }

    /// The lowest stack pointer a frame that checks its stack
    /// (`stack_limit_checked`) may run at on this stack: its low bound plus
    /// an eighth of its size, at least 64 KiB and at most 1 MiB. Below a
    /// checked frame there may run one more Botlish frame (allocated and
    /// probed before it checks), frames that make no Botlish call, the
    /// runtime's helpers (the collector's marking is iterative) and what
    /// Windows keeps for itself at a stack's end (its guard page and the
    /// thread's stack guarantee, 20 KiB for a Rust thread).
    pub fn stack_limit(&self) -> usize {
        let size = self.high_bound.saturating_sub(self.low_bound);
        self.low_bound + (size / 8).clamp(64 << 10, 1 << 20)
    }
}

/// Linux x86-64 and AArch64, macOS AArch64 (MACOS-AARCH64-MILESTONE-4.md):
/// the thread's stack bounds and guard, the stack-overflow guard's handler
/// on an alternate signal stack (runtime::platform), stack probes in
/// generated code (codegen::isa) and the native-frame GC walk
/// (runtime::framewalk's NATIVE_FRAME_ROOTS) together replace the shadow
/// stack's depth check (codegen::roots's `depth_reservation` needs both).
/// Not Windows yet: there generated code probes its stack (Windows commits
/// it page by page) and a check of the stack pointer bounds Botlish
/// recursion (`stack_limit_checked`), but nothing reports a native stack
/// exhausted otherwise (WINDOWS-X86-64-MILESTONE-1.md, -3.md).
pub const fn native_stack_overflow_supported() -> bool {
    cfg!(any(all(target_os = "linux", any(target_arch = "x86_64", target_arch = "aarch64")), all(target_os = "macos", target_arch = "aarch64")))
}

/// Whether the shadow stack's depth check bounds Botlish recursion
/// (codegen::roots's `depth_reservation`) for code whose roots are in
/// native frames exactly when NATIVE_FRAME_ROOTS says so: unless they are
/// and the stack guard reports an exhausted stack, every function that
/// makes a Botlish call checks its depth in its prologue and fails with
/// NATIVE LIMIT STACK, an error its callers see (nir's call effects).
pub const fn depth_checked(native_frame_roots: bool) -> bool {
    !(native_frame_roots && native_stack_overflow_supported())
}

/// Whether the depth check is a check of the stack pointer: where native
/// frames hold the roots but no guard reports an exhausted stack (Windows
/// x86-64, until its stack guard). There every function that makes a
/// Botlish call compares its stack pointer with the Vm's stack limit
/// (`NativeStack::stack_limit`) and fails with NATIVE LIMIT STACK below it
/// (codegen::clif's `prologue_stack_limit`): no shadow stack exists. On the
/// fallback plan the shadow stack holds the roots, and its end is the bound.
pub const fn stack_limit_checked(native_frame_roots: bool) -> bool {
    native_frame_roots && depth_checked(native_frame_roots)
}

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
}
