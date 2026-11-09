//! Linux pthread stack discovery for the stack-overflow guard (guard.rs), for
//! x86-64 and AArch64 alike (pthread_getattr_np works the same on both): the
//! stack glibc reports, with the guard glibc reports directly below it.
//! Android AArch64 uses it too (ANDROID-AARCH64-TARGET-SUPPORT-MILESTONE-1.md):
//! Bionic's pthread_getattr_np, pthread_attr_getstack and getguardsize have
//! glibc's contract (a created thread's guard below its usable stack). The
//! worker and Rust/JIT helper frames use the same pthread stack and the
//! platform's ordinary C calling convention.
use crate::runtime::native_stack::{NativeStack, StackState};
use std::io;

pub fn current_stack() -> io::Result<NativeStack> {
    unsafe {
        let mut attr = std::mem::MaybeUninit::<libc::pthread_attr_t>::uninit();
        let rc = libc::pthread_getattr_np(libc::pthread_self(), attr.as_mut_ptr());
        if rc != 0 { return Err(io::Error::from_raw_os_error(rc)); }
        let mut attr = attr.assume_init();
        let mut base: *mut libc::c_void = std::ptr::null_mut();
        let mut size = 0usize;
        let mut guard = 0usize;
        let stack_rc = libc::pthread_attr_getstack(&attr, &mut base, &mut size);
        let guard_rc = libc::pthread_attr_getguardsize(&attr, &mut guard);
        libc::pthread_attr_destroy(&mut attr);
        if stack_rc != 0 { return Err(io::Error::from_raw_os_error(stack_rc)); }
        if guard_rc != 0 { return Err(io::Error::from_raw_os_error(guard_rc)); }
        let low_bound = base as usize;
        let high_bound = low_bound.checked_add(size).ok_or(io::Error::from(io::ErrorKind::InvalidData))?;
        let guard_low = low_bound.checked_sub(guard).ok_or(io::Error::from(io::ErrorKind::InvalidData))?;
        Ok(NativeStack { low_bound, high_bound, guard_low, saved_sp: None, state: StackState::Active })
    }
}

/// The kernel's id of the calling thread: what the guard (platform/guard.rs)
/// records for the thread it guards and compares in its handler. gettid is a
/// raw syscall, async-signal-safe.
#[inline(always)]
pub fn thread_token() -> usize {
    // SAFETY: gettid has no preconditions.
    unsafe { libc::syscall(libc::SYS_gettid) as usize }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn current_pthread_has_usable_stack_and_guard() {
        let stack = current_stack().unwrap();
        let local = 0u8;
        assert!(stack.contains(&local as *const u8 as usize, 1));
        assert!(stack.high_bound > stack.low_bound + 1024 * 1024);
        assert!(stack.guard_low < stack.low_bound);
        assert!(stack.is_guard_fault(stack.low_bound - 1));
    }
}
