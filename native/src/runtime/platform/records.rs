//! The stack-overflow guard's per-thread records (PER-THREAD-RUNTIME-STATE-
//! MILESTONE-1.md, "Stack guards"), shared by both exception models: the
//! POSIX signal handler (guard.rs) and Windows' vectored handler
//! (windows.rs).
//!
//! What is the process's and what is a thread's:
//!
//! * the process installs one fault handler (a disposition, a vectored
//!   handler), while at least one thread is guarded;
//! * every guarded thread owns one record here: its thread token, the stack
//!   it runs on now (published as a double buffer, so a fault at any
//!   instruction reads one consistent pair), the report's mode (the
//!   driver's or a standalone executable's), where the report goes, and a
//!   label the report starts with (empty but in the concurrent-VM harness,
//!   whose threads label their lines "vm N ").
//!
//! Several threads may be guarded at once, each with its own record; a
//! thread publishes only into its own (`publish` finds it through a
//! thread-local index, never another's), and the handler finds the
//! faulting thread's by scanning the table for its token: atomic loads
//! only, no lock, no allocation, no thread-local access (which may lazily
//! allocate in a shared object) -- async-signal-safe, and safe in a
//! vectored handler. A thread whose record is not found is unguarded: its
//! faults are never relabelled.
//!
//! A record is released when its guard drops, and when its thread ends
//! without dropping it (the thread-local index's destructor): a later
//! thread that receives the same token from the system never inherits it.
//! A thread already holding one cannot claim another; a claim that finds
//! its own token on a record it does not hold (one a dead thread of that
//! token left, which the destructor did not get to release) reclaims it.
use std::cell::Cell;
use std::io;
use std::sync::atomic::{AtomicBool, AtomicU8, AtomicUsize, Ordering};

/// How many threads may be guarded at once. A fixed table: the handler
/// scans it in place, and nothing grows it while a handler may read it.
pub const RECORDS: usize = 64;
/// The longest label a record holds.
pub const LABEL_BYTES: usize = 48;

/// A record's owner while it is free.
const FREE: usize = 0;
/// A record's owner while it is being claimed or released: no handler
/// claims a fault through it. No thread's token (Linux tids and Windows
/// thread ids are small, pthread_self an aligned address).
const CLAIMING: usize = usize::MAX;

pub struct Record {
    owner: AtomicUsize,
    /// Two slots of the stack the thread runs on now, each the pair its
    /// handler compares a fault with (POSIX: the guard's [low, end); Windows:
    /// the reservation's [low, high)), and the one in use.
    slots: [[AtomicUsize; 2]; 2],
    slot: AtomicUsize,
    executable: AtomicBool,
    /// Where the report goes (a file descriptor or a HANDLE), resolved when
    /// the guard is installed.
    destination: AtomicUsize,
    label_len: AtomicUsize,
    label: [AtomicU8; LABEL_BYTES],
}

#[allow(clippy::declare_interior_mutable_const)]
const EMPTY: Record = Record {
    owner: AtomicUsize::new(FREE),
    slots: [[AtomicUsize::new(0), AtomicUsize::new(0)], [AtomicUsize::new(0), AtomicUsize::new(0)]],
    slot: AtomicUsize::new(0),
    executable: AtomicBool::new(false),
    destination: AtomicUsize::new(0),
    label_len: AtomicUsize::new(0),
    label: [const { AtomicU8::new(0) }; LABEL_BYTES],
};

static TABLE: [Record; RECORDS] = [EMPTY; RECORDS];

/// This thread's record, as its index plus one (0: none). Its destructor
/// releases a record the thread ends holding.
struct Mine(Cell<usize>);

impl Drop for Mine {
    fn drop(&mut self) {
        let index = self.0.get();
        if index != 0 {
            free(index - 1);
        }
    }
}

thread_local! {
    static MINE: Mine = const { Mine(Cell::new(0)) };
}

impl Record {
    /// The pair published last.
    #[inline(always)]
    pub fn words(&self) -> (usize, usize) {
        let slot = self.slot.load(Ordering::Acquire);
        (self.slots[slot][0].load(Ordering::Relaxed), self.slots[slot][1].load(Ordering::Relaxed))
    }

    pub fn executable(&self) -> bool {
        self.executable.load(Ordering::Relaxed)
    }

    pub fn destination(&self) -> usize {
        self.destination.load(Ordering::Relaxed)
    }

    /// The label, copied into BUFFER: its length.
    pub fn label(&self, buffer: &mut [u8; LABEL_BYTES]) -> usize {
        let len = self.label_len.load(Ordering::Relaxed).min(LABEL_BYTES);
        for (byte, stored) in buffer.iter_mut().zip(&self.label).take(len) {
            *byte = stored.load(Ordering::Relaxed);
        }
        len
    }

    #[inline(always)]
    fn publish(&self, words: (usize, usize)) {
        let next = self.slot.load(Ordering::Relaxed) ^ 1;
        self.slots[next][0].store(words.0, Ordering::Relaxed);
        self.slots[next][1].store(words.1, Ordering::Relaxed);
        self.slot.store(next, Ordering::Release);
    }
}

/// Claims a record for the calling thread, whose token is TOKEN: its
/// stack's pair WORDS published first, the report's mode, destination and
/// label. Its index; refused when the thread holds one already, when
/// LABEL is too long, or when every record is in use.
pub fn claim(token: usize, words: (usize, usize), executable: bool, destination: usize, label: &[u8]) -> io::Result<usize> {
    if label.len() > LABEL_BYTES {
        return Err(io::Error::new(io::ErrorKind::InvalidInput, format!("a guard label holds at most {LABEL_BYTES} bytes")));
    }
    if mine().is_some() {
        return Err(io::Error::new(io::ErrorKind::AlreadyExists, "this thread's stack-overflow guard is already installed"));
    }
    // A record a dead thread of this token left (released by no
    // destructor), else a free one.
    let found = TABLE
        .iter()
        .position(|r| r.owner.compare_exchange(token, CLAIMING, Ordering::AcqRel, Ordering::Relaxed).is_ok())
        .or_else(|| TABLE.iter().position(|r| r.owner.compare_exchange(FREE, CLAIMING, Ordering::AcqRel, Ordering::Relaxed).is_ok()));
    let Some(index) = found else {
        return Err(io::Error::new(io::ErrorKind::Other, format!("every one of the {RECORDS} stack-overflow guard records is in use")));
    };
    let record = &TABLE[index];
    record.slot.store(0, Ordering::Relaxed);
    record.slots[0][0].store(words.0, Ordering::Relaxed);
    record.slots[0][1].store(words.1, Ordering::Relaxed);
    record.executable.store(executable, Ordering::Relaxed);
    record.destination.store(destination, Ordering::Relaxed);
    for (stored, &byte) in record.label.iter().zip(label) {
        stored.store(byte, Ordering::Relaxed);
    }
    record.label_len.store(label.len(), Ordering::Relaxed);
    record.owner.store(token, Ordering::Release);
    MINE.with(|m| m.0.set(index + 1));
    Ok(index)
}

/// Releases record INDEX, the calling thread's: from now on no fault is
/// claimed through it.
pub fn release(index: usize) {
    MINE.with(|m| {
        if m.0.get() == index + 1 {
            m.0.set(0);
        }
    });
    free(index);
}

fn free(index: usize) {
    let record = &TABLE[index];
    record.owner.store(CLAIMING, Ordering::Release);
    record.label_len.store(0, Ordering::Relaxed);
    record.owner.store(FREE, Ordering::Release);
}

/// Makes WORDS the calling thread's published stack, when it holds a
/// record: never another thread's. Inlined, and only a thread-local read
/// and atomic stores.
#[inline(always)]
pub fn publish(words: (usize, usize)) {
    let index = MINE.with(|m| m.0.get());
    if index != 0 {
        TABLE[index - 1].publish(words);
    }
}

/// The calling thread's record, if it holds one (not async-signal-safe:
/// a thread-local read).
pub fn mine() -> Option<&'static Record> {
    match MINE.with(|m| m.0.get()) {
        0 => None,
        index => Some(&TABLE[index - 1]),
    }
}

/// The record of the thread whose token is TOKEN, if it holds one: atomic
/// loads only (async-signal-safe; the handlers' lookup).
#[inline(always)]
pub fn find(token: usize) -> Option<&'static Record> {
    if token == FREE || token == CLAIMING {
        return None;
    }
    TABLE.iter().find(|r| r.owner.load(Ordering::Acquire) == token)
}

/// How many threads are guarded now (tests, the concurrent-VM harness).
pub fn in_use() -> usize {
    TABLE.iter().filter(|r| !matches!(r.owner.load(Ordering::Acquire), FREE | CLAIMING)).count()
}

#[cfg(test)]
mod tests {
    use super::*;

    /// Two threads hold two records, each publishing only into its own and
    /// found only by its own token; a second claim on one thread is refused;
    /// a record is free again after its thread releases it, and after a
    /// thread ends holding one.
    #[test]
    fn records_are_per_thread() {
        let token = |n: usize| 0x5150_0000 + n * 8;
        let a = claim(token(1), (10, 20), false, 1, b"vm 0 ").expect("a claims");
        assert!(claim(token(1), (10, 20), false, 1, b"").is_err(), "one record per thread");
        let (sender, receiver) = std::sync::mpsc::channel();
        let (go, wait) = std::sync::mpsc::channel::<()>();
        let other = std::thread::spawn(move || {
            let b = claim(token(2), (30, 40), true, 2, b"vm 1 ").expect("b claims");
            sender.send(b).unwrap();
            wait.recv().unwrap();
            publish((31, 41));
            sender.send(b).unwrap();
            wait.recv().unwrap();
            // Ends holding its record: the destructor frees it.
        });
        let b = receiver.recv().unwrap();
        assert_ne!(a, b);
        assert_eq!(find(token(1)).map(|r| r.words()), Some((10, 20)));
        assert_eq!(find(token(2)).map(|r| r.words()), Some((30, 40)));
        publish((11, 21));
        assert_eq!(find(token(2)).map(|r| r.words()), Some((30, 40)), "a publication changes only the publisher's record");
        go.send(()).unwrap();
        receiver.recv().unwrap();
        assert_eq!(find(token(1)).map(|r| r.words()), Some((11, 21)), "the other thread's publication leaves this one's");
        assert_eq!(find(token(2)).map(|r| r.words()), Some((31, 41)));
        let mut label = [0u8; LABEL_BYTES];
        let len = find(token(2)).unwrap().label(&mut label);
        assert_eq!(&label[..len], b"vm 1 ");
        assert!(find(token(2)).unwrap().executable());
        go.send(()).unwrap();
        other.join().unwrap();
        assert!(find(token(2)).is_none(), "a thread that ends holding a record releases it");
        release(a);
        assert!(find(token(1)).is_none());
        assert!(mine().is_none());
        assert!(find(FREE).is_none() && find(CLAIMING).is_none());
    }

    /// A token a dead thread's record still carries is reclaimed, never
    /// shared: the new thread's claim takes that record over.
    #[test]
    fn a_reused_token_reclaims_a_stale_record() {
        let token = 0x7a70_0000;
        let stale = std::thread::spawn(move || {
            let index = claim(token, (1, 2), false, 1, b"old ").unwrap();
            // As if its destructor never ran: forget the thread's index.
            MINE.with(|m| m.0.set(0));
            index
        })
        .join()
        .unwrap();
        assert_eq!(find(token).map(|r| r.words()), Some((1, 2)), "the stale record");
        let fresh = std::thread::spawn(move || {
            let index = claim(token, (5, 6), false, 1, b"").unwrap();
            let words = find(token).map(|r| r.words());
            release(index);
            (index, words)
        })
        .join()
        .unwrap();
        assert_eq!(fresh, (stale, Some((5, 6))), "the same record, the new thread's stack");
        assert!(find(token).is_none());
    }
}
