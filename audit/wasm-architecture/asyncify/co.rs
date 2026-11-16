//! WASM-ARCH PROTOTYPE (experiment C-A): general coroutines on wasm through
//! Binaryen's Asyncify, with no JavaScript host, under Wasmtime.
//!
//! A minimal runtime that keeps the invariants the Botlish runtime would
//! need under Asyncify:
//!   * every coroutine has its own Asyncify buffer, its own linear-memory
//!     stack (the `__stack_pointer` region its suspended frames' spills stay
//!     in) and its own shadow-root segment (the GC roots of its frames);
//!   * a resume runs one segment: `segment` (never instrumented) switches the
//!     stack pointer and the root segment, calls the body through a function
//!     pointer (call_indirect) -- in rewind mode on a resume -- and stops the
//!     unwind when the body yields;
//!   * `co_yield` (never instrumented) starts the unwind, and on the rewind
//!     re-entry stops it and returns the message;
//!   * the collector scans the running chain's segments and, through each
//!     reachable coroutine object, a suspended coroutine's segment.
//! The "generated" functions below are hand-written to the ShadowOnly root
//! protocol (a frame of slots per function, a root stored at definition).
#![allow(static_mut_refs, clippy::missing_safety_doc, dangerous_implicit_autorefs)]
use std::ptr::null_mut;

type V = u64;
const NO_VALUE: V = 0;
const UNIT: V = 10;
const TRUE: V = 6;
const FALSE: V = 2;
fn int(n: i64) -> V {
    ((n << 1) | 1) as V
}
fn num(v: V) -> i64 {
    (v as i64) >> 1
}

#[link(wasm_import_module = "asyncify")]
unsafe extern "C" {
    fn start_unwind(data: *mut Data);
    fn stop_unwind();
    fn start_rewind(data: *mut Data);
    fn stop_rewind();
}
unsafe extern "C" {
    fn get_sp() -> usize;
    fn set_sp(sp: usize);
}

#[repr(C)]
struct Data {
    current: *mut u8,
    end: *mut u8,
}

// ---- heap ----
enum Body {
    List(Vec<V>),
    Str(String),
    Co(Box<Co>),
}
struct Obj {
    marked: bool,
    body: Body,
}
static mut OBJECTS: Vec<*mut Obj> = Vec::new();
static mut STRESS: bool = false;
static mut ALLOCATED: usize = 0;
static mut COLLECTIONS: usize = 0;
static mut LIVE_COROUTINES: usize = 0;
static mut CO_BYTES: usize = 0;

unsafe fn alloc(body: Body) -> V {
    unsafe {
        ALLOCATED += 1;
        if STRESS || ALLOCATED > 4096 {
            collect();
        }
        let o = Box::into_raw(Box::new(Obj { marked: false, body }));
        OBJECTS.push(o);
        o as V
    }
}
fn is_ptr(v: V) -> bool {
    v != 0 && v & 7 == 0
}
unsafe fn obj<'a>(v: V) -> &'a mut Obj {
    unsafe { &mut *(v as *mut Obj) }
}

// ---- shadow-root segments ----
struct Seg {
    slots: Vec<V>,
    top: usize,
}
impl Seg {
    fn new(n: usize) -> Seg {
        Seg { slots: vec![0; n], top: 0 }
    }
}
static mut MAIN_SEG: *mut Seg = null_mut();
static mut CUR_SEG: *mut Seg = null_mut();

#[inline(always)]
unsafe fn enter(n: usize) -> usize {
    unsafe {
        let s = &mut *CUR_SEG;
        let base = s.top;
        assert!(base + n <= s.slots.len(), "shadow segment exhausted");
        for i in 0..n {
            s.slots[base + i] = 0;
        }
        s.top += n;
        base
    }
}
#[inline(always)]
unsafe fn leave(base: usize) {
    unsafe { (*CUR_SEG).top = base }
}
#[inline(always)]
unsafe fn root(base: usize, i: usize, v: V) {
    unsafe { (*CUR_SEG).slots[base + i] = v }
}

// ---- coroutines ----
const FRESH: u8 = 0;
const RUNNING: u8 = 1;
const SUSPENDED: u8 = 2;
const COMPLETED: u8 = 3;
const FAILED: u8 = 4;
const RELEASED: u8 = 5;

pub struct Co {
    state: u8,
    entry: unsafe extern "C" fn(*mut Co) -> V,
    args: Vec<V>,
    value: V,
    error: i64,
    rewinding: bool,
    abandoned: bool,
    data: Data,
    buffer: Vec<u8>,
    stack: Vec<u8>,
    sp: usize,
    seg: Seg,
    resumer: *mut Co,
}
static mut CURRENT: *mut Co = null_mut();
const STACK_BYTES: usize = 64 * 1024;
const BUFFER_BYTES: usize = 8 * 1024;
const SEG_SLOTS: usize = 1024;
static mut PENDING_ERROR: i64 = 0;
static mut UNWINDING: bool = false;

unsafe fn co_of<'a>(h: V) -> &'a mut Co {
    unsafe {
        match &mut obj(h).body {
            Body::Co(c) => c,
            _ => panic!("not a coroutine"),
        }
    }
}

unsafe fn create(entry: unsafe extern "C" fn(*mut Co) -> V, args: Vec<V>) -> V {
    unsafe {
        LIVE_COROUTINES += 1;
        CO_BYTES += STACK_BYTES + BUFFER_BYTES + SEG_SLOTS * 8;
        let co = Box::new(Co {
            state: FRESH,
            entry,
            args,
            value: UNIT,
            error: 0,
            rewinding: false,
            abandoned: false,
            data: Data { current: null_mut(), end: null_mut() },
            buffer: vec![0; BUFFER_BYTES],
            stack: vec![0; STACK_BYTES],
            sp: 0,
            seg: Seg::new(SEG_SLOTS),
            resumer: null_mut(),
        });
        alloc(Body::Co(co))
    }
}

/// One segment of coroutine H (never instrumented: the boundary that stops
/// an unwind and starts a rewind).
#[inline(never)]
#[unsafe(no_mangle)]
pub unsafe extern "C" fn segment(h: V) -> V {
    unsafe {
        let co: *mut Co = co_of(h);
        let c = &mut *co;
        c.resumer = CURRENT;
        CURRENT = co;
        let resumer_sp = get_sp();
        let resumer_seg = CUR_SEG;
        CUR_SEG = &mut c.seg;
        let resuming = c.state == SUSPENDED;
        c.state = RUNNING;
        let entry = c.entry;
        if resuming {
            set_sp(c.sp);
            c.rewinding = true;
            start_rewind(&mut c.data);
        } else {
            set_sp((c.stack.as_mut_ptr() as usize + STACK_BYTES) & !15);
        }
        let r = entry(co);
        let c = &mut *co;
        let suspended = UNWINDING;
        UNWINDING = false;
        if suspended {
            stop_unwind();
            c.sp = get_sp();
            c.state = SUSPENDED;
        }
        set_sp(resumer_sp);
        CUR_SEG = resumer_seg;
        CURRENT = c.resumer;
        c.resumer = null_mut();
        if suspended {
            return c.value;
        }
        if r == NO_VALUE {
            c.state = FAILED;
            c.error = PENDING_ERROR;
        } else {
            c.state = COMPLETED;
            c.value = r;
        }
        drop_resources(c);
        if r == NO_VALUE { NO_VALUE } else { r }
    }
}

unsafe fn drop_resources(c: &mut Co) {
    unsafe {
        if !c.stack.is_empty() {
            c.stack = Vec::new();
            c.buffer = Vec::new();
            c.seg = Seg::new(0);
            LIVE_COROUTINES -= 1;
            CO_BYTES -= STACK_BYTES + BUFFER_BYTES + SEG_SLOTS * 8;
        }
    }
}

/// The suspension point (never instrumented): the first call starts the
/// unwind; the rewind re-enters it, and it stops the rewind and answers the
/// message (NO_VALUE: the coroutine is abandoned, an error pending).
#[inline(never)]
#[unsafe(no_mangle)]
pub unsafe extern "C" fn co_yield(v: V) -> V {
    unsafe {
        let c = &mut *CURRENT;
        if c.rewinding {
            c.rewinding = false;
            stop_rewind();
            if c.abandoned {
                PENDING_ERROR = -1;
                return NO_VALUE;
            }
            return c.value;
        }
        c.value = v;
        let start = c.buffer.as_mut_ptr();
        c.data = Data { current: start, end: start.add(c.buffer.len()) };
        UNWINDING = true;
        start_unwind(&mut c.data);
        0
    }
}

unsafe fn start(h: V) -> V {
    unsafe { segment(h) }
}
unsafe fn resume(h: V, msg: V) -> V {
    unsafe {
        let c = co_of(h);
        match c.state {
            SUSPENDED => {
                c.value = msg;
                segment(h)
            }
            COMPLETED => c.value,
            FAILED => {
                PENDING_ERROR = c.error;
                NO_VALUE
            }
            _ => panic!("bad resume"),
        }
    }
}
unsafe fn done(h: V) -> bool {
    unsafe { matches!(co_of(h).state, COMPLETED | FAILED | RELEASED) }
}
/// Abandonment: a suspended coroutine's pending yield fails; its frames run
/// their cleanups as they return the error.
unsafe fn abandon(h: V) {
    unsafe {
        let c = co_of(h);
        if c.state == SUSPENDED {
            c.abandoned = true;
            segment(h);
            PENDING_ERROR = 0;
        }
        release(h);
    }
}
unsafe fn release(h: V) {
    unsafe {
        let c = co_of(h);
        drop_resources(c);
        c.state = RELEASED;
    }
}

// ---- the collector ----
unsafe fn collect() {
    unsafe {
        COLLECTIONS += 1;
        ALLOCATED = 0;
        let mut stack: Vec<V> = Vec::new();
        // The running chain: the current segment and every resumer's.
        stack.extend_from_slice(&(*CUR_SEG).slots[..(*CUR_SEG).top]);
        let mut co = CURRENT;
        while !co.is_null() {
            stack.push(0); // (the coroutine objects of the chain are reached through the handles their resumers root)
            let r = (*co).resumer;
            let seg = if r.is_null() { MAIN_SEG } else { &mut (*r).seg as *mut Seg };
            stack.extend_from_slice(&(*seg).slots[..(*seg).top]);
            co = r;
        }
        stack.extend_from_slice(&LOG);
        while let Some(v) = stack.pop() {
            if !is_ptr(v) {
                continue;
            }
            let o = obj(v);
            if o.marked {
                continue;
            }
            o.marked = true;
            match &o.body {
                Body::List(xs) => stack.extend_from_slice(xs),
                Body::Str(_) => {}
                Body::Co(c) => {
                    stack.extend_from_slice(&c.args);
                    stack.push(c.value);
                    if c.state == SUSPENDED || c.state == RUNNING {
                        // A suspended coroutine's frames: its segment's slots.
                        stack.extend_from_slice(&c.seg.slots[..c.seg.top]);
                    }
                }
            }
        }
        OBJECTS.retain(|&o| {
            if (*o).marked {
                (*o).marked = false;
                true
            } else {
                if let Body::Co(c) = &mut (*o).body {
                    if !c.stack.is_empty() {
                        drop_resources(c);
                    }
                }
                drop(Box::from_raw(o));
                false
            }
        });
    }
}

static mut LOG: Vec<V> = Vec::new();
fn note(n: i64) {
    unsafe { LOG.push(int(n)) }
}

// ===================================================================
// The corpus, as generated code would be: frames of root slots.

// 1. counter(start, step): yields start, start+step, ... five times; -1.
#[inline(never)]
#[unsafe(no_mangle)]
pub unsafe extern "C" fn counter(c: *mut Co) -> V {
    unsafe {
        let (start, step) = (num((*c).args[0]), num((*c).args[1]));
        let mut acc = start;
        for _ in 0..5 {
            let m = co_yield(int(acc));
            if m == NO_VALUE {
                return NO_VALUE;
            }
            acc += step;
        }
        int(-1)
    }
}

// 2. nested: leaf / middle / down (recursive) / driver.
#[inline(never)]
#[unsafe(no_mangle)]
pub unsafe extern "C" fn leaf(n: i64) -> V {
    unsafe {
        if co_yield(int(n)) == NO_VALUE {
            return NO_VALUE;
        }
        int(n * 2)
    }
}
#[inline(never)]
#[unsafe(no_mangle)]
pub unsafe extern "C" fn middle(n: i64) -> V {
    unsafe {
        let a = leaf(n);
        if a == NO_VALUE {
            return NO_VALUE;
        }
        let b = leaf(n + 1);
        if b == NO_VALUE {
            return NO_VALUE;
        }
        int(num(a) + num(b))
    }
}
#[inline(never)]
#[unsafe(no_mangle)]
pub unsafe extern "C" fn down(depth: i64, n: i64) -> V {
    unsafe {
        if depth == 0 {
            return middle(n);
        }
        let r = down(depth - 1, n + 10);
        if r == NO_VALUE {
            return NO_VALUE;
        }
        if co_yield(r) == NO_VALUE {
            return NO_VALUE;
        }
        int(num(r) + 1)
    }
}
#[inline(never)]
#[unsafe(no_mangle)]
pub unsafe extern "C" fn down_thunk(c: *mut Co) -> V {
    unsafe { down(num((*c).args[0]), num((*c).args[1])) }
}
#[inline(never)]
#[unsafe(no_mangle)]
pub unsafe extern "C" fn driver(c: *mut Co) -> V {
    unsafe {
        let base = enter(1);
        let inner = create(down_thunk, vec![int(3), int(0)]);
        root(base, 0, inner);
        let x = start(inner);
        let limit = num((*c).args[0]);
        let mut acc = num(x);
        for _ in 0..limit {
            if co_yield(int(acc)) == NO_VALUE {
                leave(base);
                return NO_VALUE;
            }
            if done(inner) {
                break;
            }
            let v = resume(inner, UNIT);
            acc += num(v);
        }
        leave(base);
        int(acc)
    }
}

// 3. ticker(id, period): yields id*1000+acc six times.
#[inline(never)]
#[unsafe(no_mangle)]
pub unsafe extern "C" fn ticker(c: *mut Co) -> V {
    unsafe {
        let (id, period) = (num((*c).args[0]), num((*c).args[1]));
        let mut acc = 0;
        for _ in 0..6 {
            if co_yield(int(id * 1000 + acc)) == NO_VALUE {
                return NO_VALUE;
            }
            acc += period;
        }
        int(id)
    }
}

// 4. keeper(n): a List of n fresh Strings, held only in this frame's root
// slot across two suspensions while the main program allocates.
#[inline(never)]
#[unsafe(no_mangle)]
pub unsafe extern "C" fn keeper(c: *mut Co) -> V {
    unsafe {
        let n = num((*c).args[0]) as usize;
        let base = enter(2);
        let held = alloc(Body::List(Vec::new()));
        root(base, 0, held);
        for i in 0..n {
            let s = alloc(Body::Str(format!("item-{}", i * 7)));
            if let Body::List(xs) = &mut obj(held).body {
                xs.push(s);
            }
        }
        if co_yield(int(0)) == NO_VALUE {
            leave(base);
            return NO_VALUE;
        }
        let total: usize = match &obj(held).body {
            Body::List(xs) => xs.iter().map(|s| match &obj(*s).body { Body::Str(t) => t.len(), _ => 0 }).sum(),
            _ => 0,
        };
        if co_yield(int(total as i64)) == NO_VALUE {
            leave(base);
            return NO_VALUE;
        }
        let last = match &obj(held).body {
            Body::List(xs) => match &obj(xs[n - 1]).body { Body::Str(t) => t.len(), _ => 0 },
            _ => 0,
        };
        leave(base);
        int(last as i64)
    }
}
unsafe fn churn(rounds: i64) -> i64 {
    unsafe {
        let mut acc = 0;
        for i in 0..rounds {
            let base = enter(1);
            let junk = alloc(Body::List(Vec::new()));
            root(base, 0, junk);
            for j in 0..50 {
                let s = alloc(Body::Str(format!("junk{}", i + j)));
                if let Body::List(xs) = &mut obj(junk).body {
                    xs.push(s);
                }
            }
            acc += match &obj(junk).body { Body::List(xs) => xs.len() as i64, _ => 0 };
            leave(base);
        }
        acc
    }
}

// 5. cancellation: a holder that owns a "resource" (a cleanup it runs on
// every way out, completion and abandonment alike).
#[inline(never)]
#[unsafe(no_mangle)]
pub unsafe extern "C" fn holder(c: *mut Co) -> V {
    unsafe {
        let b = num((*c).args[0]);
        if co_yield(int(1)) == NO_VALUE {
            note(b);
            return NO_VALUE;
        }
        note(b + 1);
        if co_yield(int(2)) == NO_VALUE {
            note(b);
            return NO_VALUE;
        }
        note(b + 2);
        note(b);
        int(3)
    }
}
#[inline(never)]
#[unsafe(no_mangle)]
pub unsafe extern "C" fn inner_wait(_c: *mut Co) -> V {
    unsafe {
        if co_yield(int(1)) == NO_VALUE {
            note(600);
            return NO_VALUE;
        }
        note(602);
        note(600);
        int(1)
    }
}
#[inline(never)]
#[unsafe(no_mangle)]
pub unsafe extern "C" fn deep_waiter(c: *mut Co) -> V {
    unsafe {
        if inner_wait(c) == NO_VALUE {
            note(601);
            return NO_VALUE;
        }
        note(603);
        note(601);
        int(0)
    }
}

// 6. gen(n): yields 0..n.
#[inline(never)]
#[unsafe(no_mangle)]
pub unsafe extern "C" fn generator(c: *mut Co) -> V {
    unsafe {
        let n = num((*c).args[0]);
        let mut acc = 0;
        for i in 0..n {
            if co_yield(int(i)) == NO_VALUE {
                return NO_VALUE;
            }
            acc += i;
        }
        let _ = acc;
        int(-1)
    }
}
#[inline(never)]
#[unsafe(no_mangle)]
pub unsafe extern "C" fn small_holder(c: *mut Co) -> V {
    unsafe {
        let i = num((*c).args[0]);
        let base = enter(1);
        let xs = alloc(Body::List(vec![int(i), int(i + 1), int(i + 2)]));
        root(base, 0, xs);
        if co_yield(int(i)) == NO_VALUE {
            leave(base);
            return NO_VALUE;
        }
        let n = match &obj(xs).body { Body::List(v) => v.len() as i64, _ => 0 };
        leave(base);
        int(n + i)
    }
}

// 7. later(n): two yields, then fails (error code n) when n > 3.
#[inline(never)]
#[unsafe(no_mangle)]
pub unsafe extern "C" fn later(c: *mut Co) -> V {
    unsafe {
        let n = num((*c).args[0]);
        if co_yield(int(n)) == NO_VALUE {
            return NO_VALUE;
        }
        if co_yield(int(n + 1)) == NO_VALUE {
            return NO_VALUE;
        }
        if n > 3 {
            PENDING_ERROR = n;
            return NO_VALUE;
        }
        int(n)
    }
}

#[inline(never)]
#[unsafe(no_mangle)]
pub unsafe extern "C" fn recurse(n: i64) -> i64 {
    // A frame with a 64-byte local the optimizer cannot remove.
    let mut a = [0u8; 64];
    unsafe { std::ptr::write_volatile(&mut a[(n as usize) % 64], n as u8) };
    if n == 0 { return 0 }
    let r = unsafe { recurse(n - 1) };
    r + unsafe { std::ptr::read_volatile(&a[(n as usize) % 64]) } as i64
}
#[inline(never)]
#[unsafe(no_mangle)]
pub unsafe extern "C" fn recurse_thunk(c: *mut Co) -> V {
    unsafe { int(recurse(num((*c).args[0]))) }
}

fn show(vs: &[V]) -> String {
    let xs: Vec<String> = vs.iter().map(|v| match *v {
        TRUE => "true".into(),
        FALSE => "false".into(),
        v => num(v).to_string(),
    }).collect();
    format!("[{}]", xs.join(", "))
}
fn b(x: bool) -> V {
    if x { TRUE } else { FALSE }
}

fn main() {
    unsafe {
        STRESS = std::env::var("GC_STRESS").is_ok_and(|v| v == "1");
        let main_seg = Box::into_raw(Box::new(Seg::new(1 << 16)));
        MAIN_SEG = main_seg;
        CUR_SEG = main_seg;
        let which = std::env::args().nth(1).unwrap_or_default();
        let base = enter(32);
        match which.as_str() {
            "1" => {
                let a = create(counter, vec![int(0), int(1)]);
                root(base, 0, a);
                let bb = create(counter, vec![int(100), int(10)]);
                root(base, 1, bb);
                let a0 = start(a);
                let b0 = start(bb);
                let a1 = resume(a, UNIT);
                let b1 = resume(bb, UNIT);
                let b2 = resume(bb, UNIT);
                let a2 = resume(a, UNIT);
                let a3 = resume(a, UNIT);
                let b3 = resume(bb, UNIT);
                println!("{}", show(&[a0, b0, a1, b1, b2, a2, a3, b3, b(done(a))]));
            }
            "2" => {
                let o = create(driver, vec![int(10)]);
                root(base, 0, o);
                let mut out = vec![start(o)];
                for _ in 0..7 {
                    out.push(resume(o, UNIT));
                }
                out.push(b(done(o)));
                println!("{}", show(&out));
            }
            "3" => {
                let mut tasks: Vec<V> = Vec::new();
                for i in 0..4 {
                    let t = create(ticker, vec![int(i), int(i + 1)]);
                    root(base, i as usize, t);
                    start(t);
                    tasks.push(t);
                }
                let mut out = Vec::new();
                for k in [0usize, 3, 1, 3, 2, 0, 0, 3, 1, 2] {
                    let t = tasks.remove(k);
                    out.push(resume(t, UNIT));
                    tasks.push(t);
                }
                println!("{}", show(&out));
            }
            "4" => {
                let k = create(keeper, vec![int(2000)]);
                root(base, 0, k);
                let z = start(k);
                let c1 = churn(400);
                let t = resume(k, UNIT);
                let c2 = churn(400);
                let last = resume(k, UNIT);
                println!("{} collections {}", show(&[z, int(c1), t, int(c2), last, b(done(k))]), COLLECTIONS);
            }
            "5" => {
                // completion, abandonment, deep abandonment, and an unreachable
                // suspended coroutine reclaimed by the collector.
                let h = create(holder, vec![int(100)]);
                root(base, 0, h);
                start(h);
                resume(h, UNIT);
                resume(h, UNIT);
                let h2 = create(holder, vec![int(110)]);
                root(base, 1, h2);
                start(h2);
                resume(h2, UNIT);
                note(119);
                abandon(h2);
                let d = create(deep_waiter, vec![]);
                root(base, 2, d);
                start(d);
                abandon(d);
                let lost = create(holder, vec![int(900)]);
                start(lost);
                let before = LIVE_COROUTINES;
                collect();
                println!("{} live coroutines {} -> {}", show(&LOG), before, LIVE_COROUTINES);
            }
            "6a" => {
                let g = create(generator, vec![int(1_000_000)]);
                root(base, 0, g);
                let mut acc = num(start(g));
                for _ in 0..999_999 {
                    acc += num(resume(g, UNIT));
                }
                println!("{acc}");
            }
            "6b" => {
                let n = 10_000;
                let list = alloc(Body::List(Vec::new()));
                root(base, 0, list);
                for i in 0..n {
                    let t = create(small_holder, vec![int(i)]);
                    if let Body::List(xs) = &mut obj(list).body {
                        xs.push(t);
                    }
                    start(t);
                }
                let peak = CO_BYTES;
                let pages = core::arch::wasm32::memory_size(0);
                let mut sum = 0;
                let xs: Vec<V> = match &obj(list).body { Body::List(xs) => xs.clone(), _ => vec![] };
                for t in xs {
                    sum += num(resume(t, UNIT));
                }
                println!("{sum} coroutine bytes at peak {peak} linear memory {} MiB", pages * 64 / 1024);
            }
            "7" => {
                let d = create(later, vec![int(7)]);
                root(base, 0, d);
                let d0 = start(d);
                let d1 = resume(d, UNIT);
                let d2 = resume(d, UNIT);
                let e2 = if d2 == NO_VALUE { int(-PENDING_ERROR) } else { d2 };
                let d3 = resume(d, UNIT);
                let e3 = if d3 == NO_VALUE { int(-PENDING_ERROR - 1000) } else { d3 };
                println!("{}", show(&[d0, d1, e2, e3, b(done(d))]));
            }
            "8" => {
                // A coroutine whose ordinary (non-yielding) recursion outgrows
                // its 64 KiB linear-memory stack: nothing traps, and the
                // memory below the stack -- another coroutine's buffers -- is
                // overwritten.
                let victim = create(generator, vec![int(3)]);
                root(base, 0, victim);
                start(victim);
                let probe = co_of(victim).seg.slots.as_ptr() as usize;
                let deep = create(recurse_thunk, vec![int(2000)]);
                root(base, 1, deep);
                let lo = co_of(deep).stack.as_ptr() as usize;
                println!("victim segment at {probe:#x}, deep stack [{lo:#x}, {:#x})", lo + STACK_BYTES);
                let r = start(deep);
                println!("deep returned {} without a trap", num(r));
                let vs = co_of(victim).seg.slots.iter().filter(|&&v| v != 0).count();
                let vstack = co_of(victim).stack.as_ptr() as usize;
                println!("victim stack at {vstack:#x}; nonzero words now in the victim's root segment: {vs}");
                let a = resume(victim, UNIT);
                let b2 = resume(victim, UNIT);
                println!("victim resumed: {} {}", num(a), num(b2));
            }
            "9" => {
                // The same recursion on the main stack (wasm-ld puts the
                // stack first: it grows toward address 0).
                println!("main stack pointer {:#x}", get_sp());
                let n: i64 = std::env::args().nth(2).map(|a| a.parse().unwrap()).unwrap_or(20000);
                println!("recurse({n}) = {}", recurse(n));
            }
            _ => println!("usage: co 1|2|3|4|5|6a|6b|7|8|9"),
        }
        leave(base);
    }
}
