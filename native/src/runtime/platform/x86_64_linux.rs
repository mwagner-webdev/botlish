//! Linux pthread stack discovery. The worker and Rust/JIT helper frames
//! use the same pthread stack and the normal SysV ABI.
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

use std::sync::atomic::{AtomicI32, AtomicUsize, Ordering};
static ACTIVE_TID: AtomicI32 = AtomicI32::new(0);
static GUARD_LOW: AtomicUsize = AtomicUsize::new(0);
static USABLE_LOW: AtomicUsize = AtomicUsize::new(0);
const OVERFLOW_LINE: &[u8] = b"error {NATIVE LIMIT STACK} {native stack exhausted: too many nested calls}\n";

extern "C" fn fault_handler(signal: libc::c_int, info: *mut libc::siginfo_t, _: *mut libc::c_void) {
    // Only atomic loads, syscall, write, and _exit on the alternate stack.
    let tid = unsafe { libc::syscall(libc::SYS_gettid) as i32 };
    let address = unsafe { (*info).si_addr() as usize };
    if tid == ACTIVE_TID.load(Ordering::Relaxed)
        && address >= GUARD_LOW.load(Ordering::Relaxed)
        && address < USABLE_LOW.load(Ordering::Relaxed)
    {
        unsafe {
            libc::write(libc::STDOUT_FILENO, OVERFLOW_LINE.as_ptr().cast(), OVERFLOW_LINE.len());
            libc::_exit(0);
        }
    }
    // Re-execute the fault with its ordinary disposition. Never relabel an
    // unrelated memory error as stack overflow.
    unsafe {
        libc::signal(signal, libc::SIG_DFL);
        libc::raise(signal);
    }
}

pub struct OverflowGuard {
    _alt_stack: Vec<u8>,
    old_stack: libc::stack_t,
    old_segv: libc::sigaction,
    old_bus: libc::sigaction,
}

impl OverflowGuard {
    pub fn install(stack: &NativeStack) -> io::Result<Self> {
        if stack.guard_low == stack.low_bound {
            return Err(io::Error::new(io::ErrorKind::Unsupported, "pthread has no guard"));
        }
        let mut alt_stack = vec![0u8; 64 * 1024];
        unsafe {
            let mut old_stack = std::mem::zeroed();
            let new_stack = libc::stack_t {
                ss_sp: alt_stack.as_mut_ptr().cast(),
                ss_flags: 0,
                ss_size: alt_stack.len(),
            };
            if libc::sigaltstack(&new_stack, &mut old_stack) != 0 { return Err(io::Error::last_os_error()); }
            let mut action: libc::sigaction = std::mem::zeroed();
            action.sa_sigaction = fault_handler as *const () as usize;
            action.sa_flags = libc::SA_SIGINFO | libc::SA_ONSTACK;
            libc::sigemptyset(&mut action.sa_mask);
            let mut old_segv = std::mem::zeroed();
            let mut old_bus = std::mem::zeroed();
            if libc::sigaction(libc::SIGSEGV, &action, &mut old_segv) != 0 {
                libc::sigaltstack(&old_stack, std::ptr::null_mut());
                return Err(io::Error::last_os_error());
            }
            if libc::sigaction(libc::SIGBUS, &action, &mut old_bus) != 0 {
                libc::sigaction(libc::SIGSEGV, &old_segv, std::ptr::null_mut());
                libc::sigaltstack(&old_stack, std::ptr::null_mut());
                return Err(io::Error::last_os_error());
            }
            GUARD_LOW.store(stack.guard_low, Ordering::Relaxed);
            USABLE_LOW.store(stack.low_bound, Ordering::Relaxed);
            ACTIVE_TID.store(libc::syscall(libc::SYS_gettid) as i32, Ordering::Release);
            Ok(Self { _alt_stack: alt_stack, old_stack, old_segv, old_bus })
        }
    }
}

impl Drop for OverflowGuard {
    fn drop(&mut self) {
        ACTIVE_TID.store(0, Ordering::Release);
        unsafe {
            libc::sigaction(libc::SIGSEGV, &self.old_segv, std::ptr::null_mut());
            libc::sigaction(libc::SIGBUS, &self.old_bus, std::ptr::null_mut());
            libc::sigaltstack(&self.old_stack, std::ptr::null_mut());
        }
    }
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
