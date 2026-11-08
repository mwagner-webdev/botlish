//! Bodies at the Botlish boundary, in chunks, with one chunk of Rust-side
//! buffering in each direction (the census's rule, kept).
//!
//! * Incoming (`Recv`): the exchange's pump polls Hyper's `Incoming` for
//!   the next frame only when the previous chunk has been taken by Botlish
//!   (`take`). An unread chunk therefore stops the pump, the pump's silence
//!   stops Hyper polling the body, and Hyper's own flow control takes it
//!   from there (HTTP/1.1: the connection stops reading the socket; HTTP/2:
//!   the stream's window is not released, so the peer stops sending).
//! * Outgoing (`Outgoing`): Botlish offers one chunk at a time (`offer`):
//!   accepted only when the slot is empty; the body Hyper polls takes it
//!   and tells the producer (a notice) that the slot is free. A peer that
//!   does not read stops Hyper polling, the slot stays full, and the
//!   Botlish producer waits. A body of declared length is framed with it
//!   (Content-Length) and must be exactly that long.

use bytes::Bytes;
use http_body::{Body, Frame, SizeHint};
use std::collections::VecDeque;
use std::pin::Pin;
use std::sync::{Arc, Mutex};
use std::task::{Context, Poll, Waker};

pub type Shared<T> = Arc<Mutex<T>>;

/// The incoming body as Botlish sees it.
#[derive(Default)]
pub struct Recv {
    pub chunks: VecDeque<Bytes>,
    pub eof: bool,
    /// The pump's waker, parked while a chunk waits for Botlish.
    pub pump: Option<Waker>,
    pub bytes: u64,
    pub chunk_count: u64,
    pub taken: u64,
    pub max_buffered: u64,
}

impl Recv {
    /// Bytes held now.
    pub fn held(&self) -> u64 {
        self.chunks.iter().map(|c| c.len() as u64).sum()
    }

    /// Copy up to CAP bytes of the front chunk into DST: the count (> 0),
    /// 0 when nothing is buffered, -1 at the end of the body.
    ///
    /// # Safety
    /// DST is valid for CAP bytes of writes during this call.
    pub unsafe fn take(&mut self, dst: *mut u8, cap: usize) -> i64 {
        if let Some(front) = self.chunks.front_mut() {
            let n = crate::bridge::ffi::copy_out(front, dst, cap);
            let _ = front.split_to(n);
            self.taken += n as u64;
            if front.is_empty() {
                self.chunks.pop_front();
                if let Some(w) = self.pump.take() {
                    w.wake();
                }
            }
            return n as i64;
        }
        if self.eof {
            return -1;
        }
        0
    }

    /// The size of the front chunk (what `take` would copy at most), 0
    /// when nothing is buffered, -1 at the end.
    pub fn front(&self) -> i64 {
        match self.chunks.front() {
            Some(c) => c.len() as i64,
            None if self.eof => -1,
            None => 0,
        }
    }
}

/// The outgoing body's one-chunk slot.
#[derive(Default)]
pub struct Slot {
    pub chunk: Option<Bytes>,
    pub finished: bool,
    pub aborted: bool,
    /// Hyper's poll of the body, parked while the slot is empty.
    pub body: Option<Waker>,
    /// The handle notified when the slot empties (the exchange).
    pub producer: i64,
    pub accepted: u64,
    pub taken: u64,
    /// The declared length, when the request declared one.
    pub length: Option<u64>,
    /// The exchange's task, waiting for the body to be finished before it
    /// starts the idle timer of the head wait.
    pub exchange: Option<Waker>,
}

pub struct Outgoing(pub Shared<Slot>);

/// What `offer` and `finish` answer besides success.
#[derive(Debug, PartialEq, Eq)]
pub enum OfferError {
    /// The body is finished or aborted.
    Closed,
    /// The chunk would take the body past its declared length.
    TooLong,
    /// `finish` before the declared length was reached.
    TooShort,
}

impl Outgoing {
    /// A streamed body (`offer`, `finish`), of LENGTH bytes when known.
    pub fn streamed(producer: i64, length: Option<u64>) -> (Outgoing, Shared<Slot>) {
        let s = Arc::new(Mutex::new(Slot { producer, length, ..Slot::default() }));
        (Outgoing(s.clone()), s)
    }

    /// A body that is already complete (BYTES, possibly empty).
    pub fn full(bytes: Bytes) -> Outgoing {
        let n = bytes.len() as u64;
        let finished = Slot {
            chunk: (!bytes.is_empty()).then_some(bytes),
            finished: true,
            accepted: n,
            length: Some(n),
            ..Slot::default()
        };
        Outgoing(Arc::new(Mutex::new(finished)))
    }

    pub fn slot(&self) -> Shared<Slot> {
        self.0.clone()
    }
}

/// Offer one chunk: its length when the slot was empty, 0 when full.
pub fn offer(slot: &Shared<Slot>, data: Bytes) -> Result<i64, OfferError> {
    let mut s = slot.lock().unwrap();
    if s.finished || s.aborted {
        return Err(OfferError::Closed);
    }
    if s.chunk.is_some() {
        return Ok(0);
    }
    let n = data.len() as u64;
    if let Some(length) = s.length {
        if s.accepted + n > length {
            return Err(OfferError::TooLong);
        }
    }
    if n == 0 {
        return Ok(0);
    }
    s.accepted += n;
    s.chunk = Some(data);
    if let Some(w) = s.body.take() {
        w.wake();
    }
    Ok(n as i64)
}

/// The slot has room for a chunk now.
pub fn has_room(slot: &Shared<Slot>) -> bool {
    let s = slot.lock().unwrap();
    s.chunk.is_none()
}

/// End the body. A declared length must have been reached.
pub fn finish(slot: &Shared<Slot>) -> Result<(), OfferError> {
    let mut s = slot.lock().unwrap();
    if s.aborted {
        return Err(OfferError::Closed);
    }
    if let Some(length) = s.length {
        if s.accepted != length {
            return Err(OfferError::TooShort);
        }
    }
    s.finished = true;
    if let Some(w) = s.body.take() {
        w.wake();
    }
    if let Some(w) = s.exchange.take() {
        w.wake();
    }
    Ok(())
}

#[derive(Debug)]
pub struct Aborted;

impl std::fmt::Display for Aborted {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.write_str("the request body was abandoned")
    }
}

impl std::error::Error for Aborted {}

impl Body for Outgoing {
    type Data = Bytes;
    type Error = Aborted;

    fn poll_frame(self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<Option<Result<Frame<Bytes>, Aborted>>> {
        let mut s = self.0.lock().unwrap();
        if let Some(chunk) = s.chunk.take() {
            s.taken += chunk.len() as u64;
            let producer = s.producer;
            drop(s);
            if producer > 0 {
                crate::bridge::notices::notify(producer, crate::client::NOTE_ROOM, 0);
            }
            return Poll::Ready(Some(Ok(Frame::data(chunk))));
        }
        if s.aborted {
            return Poll::Ready(Some(Err(Aborted)));
        }
        if s.finished {
            return Poll::Ready(None);
        }
        s.body = Some(cx.waker().clone());
        Poll::Pending
    }

    fn is_end_stream(&self) -> bool {
        let s = self.0.lock().unwrap();
        s.finished && s.chunk.is_none()
    }

    fn size_hint(&self) -> SizeHint {
        let s = self.0.lock().unwrap();
        match s.length {
            Some(n) => SizeHint::with_exact(n.saturating_sub(s.taken)),
            None => SizeHint::default(),
        }
    }
}

impl Drop for Outgoing {
    fn drop(&mut self) {
        let mut s = self.0.lock().unwrap();
        if !s.finished {
            s.aborted = true;
        }
    }
}
