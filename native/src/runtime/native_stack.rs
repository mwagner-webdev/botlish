use std::fmt;

/// Bounds for the active native thread stack.
///
/// This is the minimal Phase-B replacement for the remaining shadow recursion
/// depth bookkeeping on the supported x86_64/Linux path: the collector only
/// needs to know whether an address or frame pointer lies within the current
/// thread's stack, so it can stop the walk at the true native stack edge rather
/// than trying to infer that from an in-band shadow-depth token.
#[derive(Clone, Copy, Debug, Default)]
pub struct NativeStack {
    start: usize,
    end: usize,
}

impl NativeStack {
    /// Reads the current thread's natural stack bounds on Linux.
    pub fn current() -> Option<Self> {
        #[cfg(all(target_os = "linux", target_arch = "x86_64"))]
        {
            unsafe {
                let mut attr: libc::pthread_attr_t = std::mem::zeroed();
                if libc::pthread_getattr_np(libc::pthread_self(), &mut attr) != 0 {
                    return None;
                }
                let mut stackaddr: *mut libc::c_void = std::ptr::null_mut();
                let mut stacksize: usize = 0;
                if libc::pthread_attr_getstack(&attr, &mut stackaddr, &mut stacksize) != 0 {
                    let _ = libc::pthread_attr_destroy(&mut attr);
                    return None;
                }
                let _ = libc::pthread_attr_destroy(&mut attr);
                if stackaddr.is_null() || stacksize == 0 {
                    return None;
                }
                let start = stackaddr as usize;
                let end = start.saturating_add(stacksize);
                Some(Self { start, end })
            }
        }

        #[cfg(not(all(target_os = "linux", target_arch = "x86_64")))]
        {
            None
        }
    }

    pub fn contains_address(&self, addr: usize) -> bool {
        self.start <= addr && addr < self.end
    }

    pub fn contains_frame(&self, frame: usize) -> bool {
        self.contains_address(frame)
    }
}

impl fmt::Display for NativeStack {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "[{:#x}, {:#x})", self.start, self.end)
    }
}

#[cfg(all(test, target_os = "linux", target_arch = "x86_64"))]
mod proof {
    use std::ptr;

    #[repr(C)]
    #[derive(Copy, Clone)]
    struct SigJmpBuf {
        __jmpbuf: [libc::c_long; 8],
        __mask_was_saved: libc::c_int,
        __saved_mask: [libc::c_ulong; 16],
    }

    unsafe extern "C" {
        fn __sigsetjmp(env: *mut SigJmpBuf, savemask: libc::c_int) -> libc::c_int;
        fn siglongjmp(env: *mut SigJmpBuf, val: libc::c_int) -> !;
    }

    static mut PROBE_ENV: *mut SigJmpBuf = ptr::null_mut();
    static mut PROBE_GUARD_START: usize = 0;
    static mut PROBE_GUARD_END: usize = 0;

    unsafe extern "C" fn guard_page_handler(signum: libc::c_int, info: *mut libc::siginfo_t, _u: *mut libc::c_void) {
        let addr = (*info).si_addr() as usize;
        if PROBE_GUARD_START <= addr && addr < PROBE_GUARD_END {
            siglongjmp(PROBE_ENV, 1);
        }
        libc::raise(signum);
    }

    #[test]
    fn linux_guard_page_fault_proof() {
        unsafe {
            let mut attr: libc::pthread_attr_t = std::mem::zeroed();
            assert_eq!(libc::pthread_getattr_np(libc::pthread_self(), &mut attr), 0);

            let mut stackaddr: *mut libc::c_void = ptr::null_mut();
            let mut stacksize: usize = 0;
            let mut guardsize: usize = 0;
            assert_eq!(libc::pthread_attr_getstack(&attr, &mut stackaddr, &mut stacksize), 0);
            assert_eq!(libc::pthread_attr_getguardsize(&attr, &mut guardsize), 0);
            let _ = libc::pthread_attr_destroy(&mut attr);

            let guard_end = stackaddr as usize;
            let guard_start = guard_end.saturating_sub(guardsize);
            PROBE_GUARD_START = guard_start;
            PROBE_GUARD_END = guard_end;

            let mut old_alt: libc::stack_t = std::mem::zeroed();
            let _ = libc::sigaltstack(ptr::null(), &mut old_alt);

            let mut alt: libc::stack_t = std::mem::zeroed();
            let mut guard_stack = vec![0u8; libc::SIGSTKSZ.max(libc::MINSIGSTKSZ)];
            alt.ss_sp = guard_stack.as_mut_ptr().cast();
            alt.ss_size = guard_stack.len();
            alt.ss_flags = 0;
            assert_eq!(libc::sigaltstack(&alt, ptr::null_mut()), 0);
            std::mem::forget(guard_stack);

            let mut old_action: libc::sigaction = std::mem::zeroed();
            let mut action: libc::sigaction = std::mem::zeroed();
            libc::sigemptyset(&mut action.sa_mask);
            action.sa_sigaction = guard_page_handler as *const () as usize;
            action.sa_flags = libc::SA_SIGINFO | libc::SA_ONSTACK;
            assert_eq!(libc::sigaction(libc::SIGSEGV, &action, &mut old_action), 0);

            let mut env: SigJmpBuf = std::mem::zeroed();
            PROBE_ENV = &mut env;
            let recovered = if __sigsetjmp(&mut env, 1) == 0 {
                let fault = guard_start as *mut u8;
                std::ptr::write(fault, 1);
                panic!("fault did not trigger");
            } else {
                true
            };

            let _ = libc::sigaction(libc::SIGSEGV, &old_action, ptr::null_mut());
            let _ = libc::sigaltstack(&old_alt, ptr::null_mut());
            assert!(recovered, "guard page fault should be recovered by siglongjmp");
        }
    }
}
