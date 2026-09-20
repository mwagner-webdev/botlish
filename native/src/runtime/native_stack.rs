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

    #[cfg(all(target_arch = "x86_64", target_os = "linux"))]
    pub fn current() -> std::io::Result<Self> { super::platform::x86_64_linux::current_stack() }
}

/// The primary target has a pthread guard and an alternate signal stack.
pub const fn native_stack_overflow_supported() -> bool {
    cfg!(all(target_arch = "x86_64", target_os = "linux"))
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
