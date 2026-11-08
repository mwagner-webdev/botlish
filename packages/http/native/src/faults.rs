//! Fault injection, for the test unit only (feature `testing`, never in a
//! released archive). A production build compiles every check to `false`:
//! no environment variable, no export and no state can change its
//! behavior. The test unit's `bh_t_set_fault` sets the bits; each is a
//! negative control of a rule the tests check (HTTP-CLIENT-PACKAGE-
//! MILESTONE-1.md, "Negative controls").

/// A foreign wake enqueues but never posts (the executor sleeps on).
pub const LOST_FOREIGN_WAKE: u32 = 1;
/// A run ignores its budget and its snapshot (an unbounded executor batch).
pub const UNBOUNDED_RUN: u32 = 2;
/// A run skips the generation check of a wake.
pub const WAKE_STALE_CHECK: u32 = 4;
/// Work an application call made ready never kicks the executor.
pub const NO_KICK: u32 = 8;
/// Releasing an object does not cancel its tasks.
pub const RELEASE_LEAKS_TASKS: u32 = 128;
/// Handles are looked up by index alone (a stale handle reaches a reused slot).
pub const INDEX_ONLY: u32 = 256;
/// The receive pump ignores the consumer (no backpressure).
pub const UNBOUNDED_RECV: u32 = 512;

#[cfg(feature = "testing")]
static BITS: std::sync::atomic::AtomicU32 = std::sync::atomic::AtomicU32::new(0);

#[cfg(feature = "testing")]
pub fn set(bits: u32) {
    BITS.store(bits, std::sync::atomic::Ordering::Relaxed);
}

#[cfg(feature = "testing")]
pub fn bits() -> u32 {
    BITS.load(std::sync::atomic::Ordering::Relaxed)
}

#[inline]
pub fn on(bit: u32) -> bool {
    #[cfg(feature = "testing")]
    {
        bits() & bit != 0
    }
    #[cfg(not(feature = "testing"))]
    {
        let _ = bit;
        false
    }
}
