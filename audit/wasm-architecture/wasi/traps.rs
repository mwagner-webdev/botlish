//! WASM-ARCH PROTOTYPE (experiment W2): how each way a run can end looks to
//! the Wasmtime CLI host (exit status and the trap text a host classifies).
#[inline(never)]
fn deep(n: u64) -> u64 { let a = [n; 8]; if n == 0 { 0 } else { std::hint::black_box(&a); deep(n - 1) + a[3] } }
fn main() {
    match std::env::args().nth(1).as_deref() {
        Some("stack") => println!("{}", deep(10_000_000)),
        Some("oob") => unsafe { std::ptr::write_volatile(0xffff_fff0usize as *mut u64, 1) },
        Some("unreachable") => std::process::abort(),
        Some("oom") => { let mut v: Vec<Vec<u8>> = Vec::new(); loop { v.push(vec![1u8; 16 << 20]); } }
        Some("spin") => { let mut x = 0u64; loop { x = std::hint::black_box(x + 1); } }
        Some("exit3") => std::process::exit(3),
        _ => println!("ok"),
    }
}
