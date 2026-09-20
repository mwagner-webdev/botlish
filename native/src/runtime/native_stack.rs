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
