//! macOS (Apple Silicon) thread-stack discovery for the stack-overflow guard
//! (guard.rs, MACOS-AARCH64-MILESTONE-4.md).
//!
//! libpthread reports each thread's stack: pthread_get_stackaddr_np is its
//! *highest* address (the stack grows down from there) and
//! pthread_get_stacksize_np its size. What lies at and below the reported
//! end is not reported (Darwin has no pthread_getattr_np), and the VM system
//! is asked instead (mach_vm_region, Mach's public VM interface), for one
//! mapping at a time. Observed on the macos-15 arm64 runners
//! (native/tests/native_stack.rs, MACOS-AARCH64-MILESTONE-4.md):
//!
//! * a created thread (Rust's thread::Builder makes Botlish's worker with
//!   libpthread's default attributes): the reported stack is accessible,
//!   its low end page-aligned, and directly below it lies the guard
//!   pthread_create protects at the bottom of the thread's own allocation,
//!   one 16 KiB VM page (a hit raises SIGBUS);
//! * the process's main thread: the reported size is the stack rlimit, and
//!   its lowest page is itself inaccessible -- the top of the kernel's
//!   inaccessible reservation below the main stack (a hit raises SIGSEGV).
//!
//! So the usable stack starts at the first accessible address at or above
//! the reported end, and its guard is the run of inaccessible mappings
//! directly below that: confirmed, never assumed. A stack with nothing
//! inaccessible below it (a thread made with a zero guard size, whose
//! stack then lies directly on another one) has no confirmed guard
//! (guard_low == low_bound), and OverflowGuard::install refuses it, as Linux
//! refuses a thread without a glibc guard. The pthread-reported end of a
//! stack is never taken for proof of what lies beyond it.
use crate::runtime::native_stack::{NativeStack, StackState};
use std::io;

pub fn current_stack() -> io::Result<NativeStack> {
    // SAFETY: both read the calling thread's own descriptor.
    let (high_bound, size) = unsafe {
        let thread = libc::pthread_self();
        (libc::pthread_get_stackaddr_np(thread) as usize, libc::pthread_get_stacksize_np(thread))
    };
    let reported_low = high_bound.checked_sub(size).filter(|&low| size > 0 && low > 0)
        .ok_or(io::Error::from(io::ErrorKind::InvalidData))?;
    let low_bound = usable_low(reported_low, high_bound);
    let guard_low = confirmed_guard_low(low_bound);
    Ok(NativeStack { low_bound, high_bound, guard_low, saved_sp: None, state: StackState::Active })
}

/// How many mappings the walks below step over at most: a guard and an
/// inaccessible reservation next to it are two (the main thread's).
const WALK_LIMIT: usize = 4;

/// The first accessible address at or above REPORTED_LOW, below HIGH: past
/// the inaccessible mappings at the reported bottom of a stack (the main
/// thread's lowest page).
fn usable_low(reported_low: usize, high: usize) -> usize {
    let mut low = reported_low;
    for _ in 0..WALK_LIMIT {
        match region(low) {
            Some((_, end, protection)) if protection == libc::VM_PROT_NONE && end < high => low = end,
            _ => break,
        }
    }
    low
}

/// The lowest address of the run of inaccessible mappings that ends at
/// LOW_BOUND, the stack's lowest usable address: the start of its confirmed
/// guard, or LOW_BOUND itself when the byte below the stack is accessible,
/// unmapped or cannot be queried.
fn confirmed_guard_low(low_bound: usize) -> usize {
    let mut guard_low = low_bound;
    for _ in 0..WALK_LIMIT {
        match region(guard_low - 1) {
            Some((start, end, protection)) if protection == libc::VM_PROT_NONE && end == guard_low => guard_low = start,
            _ => break,
        }
    }
    guard_low
}

/// libpthread's descriptor of the calling thread: what the guard records for
/// the thread it guards and compares in its handler. pthread_self is
/// async-signal-safe (POSIX), and on Darwin a read of the thread's own
/// thread-specific data.
#[inline(always)]
pub fn thread_token() -> usize {
    // SAFETY: pthread_self has no preconditions.
    unsafe { libc::pthread_self() as usize }
}

/// Mach's `vm_region_basic_info_data_64_t` (<mach/vm_region.h>, declared
/// under `#pragma pack(4)`): its count in `int`s is the flavor's
/// VM_REGION_BASIC_INFO_COUNT_64, 9.
#[repr(C, packed(4))]
#[derive(Default)]
struct RegionBasicInfo64 {
    protection: libc::vm_prot_t,
    max_protection: libc::vm_prot_t,
    inheritance: u32,
    shared: u32,
    reserved: u32,
    offset: u64,
    behavior: i32,
    user_wired_count: u16,
}

const VM_REGION_BASIC_INFO_64: i32 = 9;

unsafe extern "C" {
    /// `mach_task_self()` is a macro over this (<mach/mach_init.h>).
    static mach_task_self_: libc::mach_port_t;
    fn mach_vm_region(target_task: libc::mach_port_t, address: *mut u64, size: *mut u64, flavor: i32,
        info: *mut i32, count: *mut u32, object_name: *mut libc::mach_port_t) -> libc::kern_return_t;
}

/// The mapping that contains ADDRESS: its start, its end and its current
/// protection. None when ADDRESS is not mapped (mach_vm_region then reports
/// the next mapping above it) or the query fails.
pub fn region(address: usize) -> Option<(usize, usize, libc::vm_prot_t)> {
    let mut start = address as u64;
    let mut size = 0u64;
    let mut info = RegionBasicInfo64::default();
    let mut count = (std::mem::size_of::<RegionBasicInfo64>() / std::mem::size_of::<i32>()) as u32;
    let mut object_name: libc::mach_port_t = 0;
    // SAFETY: every out-parameter points at storage of the size COUNT
    // declares; this flavor names no object (OBJECT_NAME stays null).
    let kr = unsafe {
        mach_vm_region(mach_task_self_, &mut start, &mut size, VM_REGION_BASIC_INFO_64,
            (&mut info as *mut RegionBasicInfo64).cast(), &mut count, &mut object_name)
    };
    if kr != 0 || start > address as u64 {
        return None;
    }
    Some((start as usize, (start + size) as usize, info.protection))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn region_info_has_the_flavors_size() {
        assert_eq!(std::mem::size_of::<RegionBasicInfo64>(), 36);
    }

    #[test]
    fn region_reads_the_protection_of_a_mapping() {
        // SAFETY: a fresh private mapping of four pages: an accessible page,
        // then the three under test. The accessible page ends the guard walk
        // below `base` whatever else is mapped there (another test thread's
        // guard directly below once made the walk go on into it).
        unsafe {
            let page = libc::sysconf(libc::_SC_PAGESIZE) as usize;
            let below = libc::mmap(std::ptr::null_mut(), 4 * page, libc::PROT_READ | libc::PROT_WRITE,
                libc::MAP_PRIVATE | libc::MAP_ANONYMOUS, -1, 0) as usize;
            assert_ne!(below, libc::MAP_FAILED as usize);
            let base = below + page;
            assert_eq!(libc::mprotect(base as *mut libc::c_void, page, libc::PROT_NONE), 0);
            let (start, end, protection) = region(base + page / 2).expect("the guard is mapped");
            assert_eq!((start, end, protection), (base, base + page, libc::VM_PROT_NONE));
            let (start, _, protection) = region(base + page).expect("the rest is mapped");
            assert_eq!((start, protection), (base + page, libc::VM_PROT_READ | libc::VM_PROT_WRITE));
            assert_eq!(confirmed_guard_low(base + page), base);
            assert_eq!(confirmed_guard_low(base + 2 * page), base + 2 * page);
            // A reported bottom that is inaccessible is stepped over.
            assert_eq!(usable_low(base, base + 3 * page), base + page);
            assert_eq!(usable_low(base + page, base + 3 * page), base + page);
            libc::munmap(below as *mut libc::c_void, 4 * page);
        }
    }

    #[test]
    fn this_threads_stack_contains_the_stack_pointer_and_has_a_confirmed_guard() {
        let stack = current_stack().unwrap();
        let local = 0u8;
        assert!(stack.contains(&local as *const u8 as usize, 1));
        assert!(stack.guard_low < stack.low_bound);
        assert!(stack.is_guard_fault(stack.low_bound - 1));
    }
}
