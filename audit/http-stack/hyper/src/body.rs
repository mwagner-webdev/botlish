//! Bodies at the Botlish boundary, in chunks, with one chunk of Rust-side
//! buffering in each direction.
//!
//! * Incoming (`Recv`): a pump task polls Hyper's `Incoming` for the next
//!   frame only when the previous chunk has been taken by Botlish
//!   (`take`). An unread chunk therefore stops the pump, the pump's
//!   silence stops Hyper polling the body, and Hyper's own flow control
//!   takes it from there (HTTP/1: the connection stops reading the socket;
//!   HTTP/2: the stream's window is not released, so the peer stops).
//! * Outgoing (`Outgoing`): Botlish offers one chunk at a time
//!   (`offer`): accepted only when the slot is empty; the body Hyper polls
//!   takes it and tells the producer (a SEND notice) that the slot is free.
//!   A peer that does not read stops Hyper polling, the slot stays full,
//!   and the Botlish producer waits.

use bytes::Bytes;
use hs_bridge::notices;
use http_body::{Body, Frame, SizeHint};
use std::collections::VecDeque;
use std::pin::Pin;
use std::sync::{Arc, Mutex};
use std::task::{Context, Poll, Waker};

/// Fault injection: the receive pump ignores the consumer.
pub const FAULT_UNBOUNDED_RECV: u32 = 512;

pub const K_READY: i64 = 1;
pub const K_HEAD: i64 = 2;
pub const K_DATA: i64 = 3;
pub const K_END: i64 = 4;
pub const K_SEND: i64 = 5;
pub const K_REQUEST: i64 = 6;
pub const K_ERROR: i64 = 9;

#[derive(Default)]
pub struct Recv {
    pub chunks: VecDeque<Bytes>,
    pub eof: bool,
    pub error: i64,
    pub pump: Option<Waker>,
    pub bytes: u64,
    pub chunk_count: u64,
    pub taken: u64,
    pub max_buffered: u64,
}

impl Recv {
    /// Copy up to CAP bytes of the buffered chunk into DST. n > 0 bytes,
    /// 0 when nothing is buffered yet, -1 at the end, an error.
    ///
    /// # Safety
    /// DST is valid for CAP bytes of writes during this call.
    pub unsafe fn take(&mut self, dst: *mut u8, cap: usize) -> i64 {
        if let Some(front) = self.chunks.front_mut() {
            let n = hs_bridge::ffi::copy_out(front, dst, cap);
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
        if self.error != 0 {
            return self.error;
        }
        if self.eof {
            return -1;
        }
        0
    }
}

pub type Shared<T> = Arc<Mutex<T>>;

/// Drive BODY into RECV, one chunk at a time, notifying HANDLE.
pub async fn pump<B>(handle: i64, recv: Shared<Recv>, mut body: B)
where
    B: Body<Data = Bytes> + Unpin,
    B::Error: std::fmt::Display,
{
    use http_body_util::BodyExt;
    let unbounded = hs_bridge::exec::fault() & FAULT_UNBOUNDED_RECV != 0;
    loop {
        // The negative control: take every frame Hyper has, whether or not
        // Botlish took the last one (no backpressure from the consumer).
        if !unbounded {
            std::future::poll_fn(|cx| {
            let mut r = recv.lock().unwrap();
            if r.chunks.is_empty() {
                Poll::Ready(())
            } else {
                r.pump = Some(cx.waker().clone());
                Poll::Pending
            }
            })
            .await;
        }
        match body.frame().await {
            Some(Ok(frame)) => {
                if let Ok(data) = frame.into_data() {
                    if data.is_empty() {
                        continue;
                    }
                    let mut r = recv.lock().unwrap();
                    r.bytes += data.len() as u64;
                    r.chunk_count += 1;
                    r.chunks.push_back(data);
                    let held: u64 = r.chunks.iter().map(|c| c.len() as u64).sum();
                    r.max_buffered = r.max_buffered.max(held);
                    drop(r);
                    notices::notify(handle, K_DATA, 0);
                }
            }
            None => {
                recv.lock().unwrap().eof = true;
                notices::notify(handle, K_END, 0);
                return;
            }
            Some(Err(_)) => {
                recv.lock().unwrap().error = hs_bridge::ffi::ERR_PROTOCOL;
                notices::notify(handle, K_ERROR, hs_bridge::ffi::ERR_PROTOCOL);
                return;
            }
        }
    }
}

#[derive(Default)]
pub struct Slot {
    pub chunk: Option<Bytes>,
    pub finished: bool,
    pub aborted: bool,
    pub body: Option<Waker>,
    pub producer: i64,
    pub accepted: u64,
    pub taken: u64,
}

pub struct Outgoing(pub Shared<Slot>);

impl Outgoing {
    pub fn new(producer: i64) -> (Outgoing, Shared<Slot>) {
        let s = Arc::new(Mutex::new(Slot { producer, ..Slot::default() }));
        (Outgoing(s.clone()), s)
    }

    /// A body that is already complete (BYTES, possibly empty).
    pub fn full(bytes: Bytes) -> Outgoing {
        let finished = Slot { chunk: (!bytes.is_empty()).then_some(bytes), finished: true, ..Slot::default() };
        Outgoing(Arc::new(Mutex::new(finished)))
    }
}

/// Offer one chunk: its length when the slot was empty, 0 when full.
pub fn offer(slot: &Shared<Slot>, data: Bytes) -> i64 {
    let mut s = slot.lock().unwrap();
    if s.finished || s.aborted {
        return hs_bridge::ffi::ERR_STALE;
    }
    if s.chunk.is_some() {
        return 0;
    }
    let n = data.len() as i64;
    s.accepted += n as u64;
    s.chunk = Some(data);
    if let Some(w) = s.body.take() {
        w.wake();
    }
    n
}

pub fn finish(slot: &Shared<Slot>) {
    let mut s = slot.lock().unwrap();
    s.finished = true;
    if let Some(w) = s.body.take() {
        w.wake();
    }
}

#[derive(Debug)]
pub struct Aborted;

impl std::fmt::Display for Aborted {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.write_str("body aborted")
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
                notices::notify(producer, K_SEND, 0);
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
        SizeHint::default()
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
