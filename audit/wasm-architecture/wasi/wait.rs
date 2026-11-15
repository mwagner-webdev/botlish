//! WASM-ARCH PROTOTYPE (experiment W1): a persistent WASI program that waits
//! for external events -- timers and stdin readiness -- in the host, with no
//! busy-wait: one poll_oneoff per wait (what a std::wasi event-loop driver's
//! `block(deadline)` would do), the clock read with clock_time_get.
use std::io::Read;

#[repr(C)]
#[derive(Clone, Copy)]
struct Subscription {
    userdata: u64,
    tag: u8,
    _pad: [u8; 7],
    // clock: id u32, pad, timeout u64, precision u64, flags u16
    u: [u64; 4],
}
#[repr(C)]
#[derive(Clone, Copy, Default)]
struct Event {
    userdata: u64,
    error: u16,
    kind: u8,
    _pad: [u8; 5],
    nbytes: u64,
    flags: u16,
    _pad2: [u8; 6],
}
#[link(wasm_import_module = "wasi_snapshot_preview1")]
unsafe extern "C" {
    fn poll_oneoff(subs: *const Subscription, events: *mut Event, n: usize, out: *mut usize) -> u16;
    fn clock_time_get(id: u32, precision: u64, out: *mut u64) -> u16;
}
fn now() -> u64 {
    let mut t = 0u64;
    unsafe { clock_time_get(1, 1, &mut t) };
    t
}
fn clock_sub(id: u64, nanos: u64) -> Subscription {
    Subscription { userdata: id, tag: 0, _pad: [0; 7], u: [1 /* monotonic */, nanos, 1, 0] }
}
fn fd_read_sub(id: u64, fd: u32) -> Subscription {
    Subscription { userdata: id, tag: 1, _pad: [0; 7], u: [fd as u64, 0, 0, 0] }
}
/// The driver's block(deadline): wait for stdin or the deadline, whichever first.
fn block(timeout_ns: u64, watch_stdin: bool) -> Vec<u64> {
    let mut subs = vec![clock_sub(1, timeout_ns)];
    if watch_stdin {
        subs.push(fd_read_sub(2, 0));
    }
    let mut events = vec![Event::default(); subs.len()];
    let mut n = 0usize;
    let e = unsafe { poll_oneoff(subs.as_ptr(), events.as_mut_ptr(), subs.len(), &mut n) };
    assert_eq!(e, 0, "poll_oneoff errno {e}");
    events[..n].iter().map(|e| e.userdata).collect()
}
fn main() {
    let t0 = now();
    // Three timer waits of 700 ms each.
    for i in 0..3 {
        let fired = block(700_000_000, false);
        println!("timer {i}: {:?} at {} ms", fired, (now() - t0) / 1_000_000);
    }
    // Then wait for stdin (or a 5 s deadline), and read what arrived.
    let fired = block(5_000_000_000, true);
    let mut buf = [0u8; 64];
    let n = if fired.contains(&2) { std::io::stdin().read(&mut buf).unwrap_or(0) } else { 0 };
    println!("stdin ready {:?} at {} ms: {:?}", fired, (now() - t0) / 1_000_000, String::from_utf8_lossy(&buf[..n]).trim());
}
