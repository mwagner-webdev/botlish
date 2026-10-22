// collide.rs -- a full 64-bit collision of Botlish's public `hash` on Ints
// (HASHABLE-AND-KEYED-HASH.md, "Why post-mixing is insufficient").
//
//   rustc -O -o collide audit/hashable/tools/collide.rs && ./collide [THREADS] [DP_BITS]
//
// The public hash of an Int is FNV-1a (64-bit) over its kind tag (0) and its
// canonical decimal text (core/hashing.tcl), masked to 61 bits at the very
// end. This program finds two different Ints A and B whose *unmasked* FNV
// states are equal: then hash(A) == hash(B), and so are the public hashes of
// every value that holds them in the same place ([A] and [B], P {x: A} and
// P {x: B}), because a List element or a struct field is folded in as its
// 64-bit sub-hash. No function of hash(x) and a secret can separate A from B.
//
// Method: parallel collision search with distinguished points (van Oorschot
// and Wiener). The step maps a 64-bit state S to the FNV state of the Int
// whose value is S (unsigned, so up to 20 digits); a trail from a random
// start ends at a state whose low DP_BITS bits are zero. Two trails that end
// at the same distinguished point from different starts merged somewhere:
// walking them in step from equal remaining lengths finds the two different
// Ints whose next states are equal. Expected work: about sqrt(pi/2 * 2^64)
// steps, a few minutes on four cores. Deterministic for a given THREADS and
// DP_BITS (each thread's starts come from a fixed SplitMix64 stream), though
// which merge is found first depends on scheduling.

use std::collections::HashMap;
use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::{Arc, Mutex};

const FNV_OFFSET: u64 = 0xcbf29ce484222325;
const FNV_PRIME: u64 = 0x100000001b3;

#[inline]
fn step(s: u64) -> u64 {
    let mut buf = [0u8; 20];
    let mut n = s;
    let mut i = buf.len();
    loop {
        i -= 1;
        buf[i] = b'0' + (n % 10) as u8;
        n /= 10;
        if n == 0 {
            break;
        }
    }
    // The Int kind tag (0), then the decimal digits.
    let mut h = (FNV_OFFSET ^ 0).wrapping_mul(FNV_PRIME);
    for &b in &buf[i..] {
        h = (h ^ b as u64).wrapping_mul(FNV_PRIME);
    }
    h
}

fn splitmix(x: &mut u64) -> u64 {
    *x = x.wrapping_add(0x9e3779b97f4a7c15);
    let mut z = *x;
    z = (z ^ (z >> 30)).wrapping_mul(0xbf58476d1ce4e5b9);
    z = (z ^ (z >> 27)).wrapping_mul(0x94d049bb133111eb);
    z ^ (z >> 31)
}

/// The two different states whose steps agree, walking trails from A (LA
/// steps to the point) and B (LB steps), or None when one start lies on the
/// other's trail (no collision, only a shared trail).
fn resolve(mut a: u64, mut la: u64, mut b: u64, mut lb: u64) -> Option<(u64, u64)> {
    while la > lb {
        a = step(a);
        la -= 1;
    }
    while lb > la {
        b = step(b);
        lb -= 1;
    }
    if a == b {
        return None;
    }
    loop {
        let (na, nb) = (step(a), step(b));
        if na == nb {
            return Some((a, b));
        }
        a = na;
        b = nb;
    }
}

fn main() {
    let args: Vec<String> = std::env::args().collect();
    let threads: u64 = args.get(1).map(|s| s.parse().unwrap()).unwrap_or(4);
    let dp_bits: u32 = args.get(2).map(|s| s.parse().unwrap()).unwrap_or(26);
    let mask = (1u64 << dp_bits) - 1;
    let limit = 40u64 << dp_bits;
    let points: Arc<Mutex<HashMap<u64, (u64, u64)>>> = Arc::new(Mutex::new(HashMap::new()));
    let done = Arc::new(AtomicBool::new(false));
    let found: Arc<Mutex<Option<(u64, u64)>>> = Arc::new(Mutex::new(None));
    let mut handles = Vec::new();
    for t in 0..threads {
        let (points, done, found) = (points.clone(), done.clone(), found.clone());
        handles.push(std::thread::spawn(move || {
            let mut seed = 0x5eed_0000_0000_0000u64 ^ t;
            while !done.load(Ordering::Relaxed) {
                let start = splitmix(&mut seed);
                let mut s = start;
                let mut len = 0u64;
                while s & mask != 0 && len < limit {
                    s = step(s);
                    len += 1;
                }
                if s & mask != 0 {
                    continue;
                }
                let other = {
                    let mut map = points.lock().unwrap();
                    match map.get(&s) {
                        Some(&(os, ol)) if os != start => Some((os, ol)),
                        Some(_) => None,
                        None => {
                            map.insert(s, (start, len));
                            None
                        }
                    }
                };
                if let Some((os, ol)) = other {
                    if let Some(pair) = resolve(start, len, os, ol) {
                        *found.lock().unwrap() = Some(pair);
                        done.store(true, Ordering::Relaxed);
                    }
                }
            }
        }));
    }
    for h in handles {
        h.join().unwrap();
    }
    let (a, b) = found.lock().unwrap().unwrap();
    assert_ne!(a, b);
    assert_eq!(step(a), step(b));
    println!("{a} {b} {:#018x}", step(a));
}
