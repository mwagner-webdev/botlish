//! Byte streams Hyper reads and writes.
//!
//! * `FdStream`: a nonblocking socket Botlish handed over. Reads and writes
//!   are plain system calls; one that would block parks its waker in the
//!   bridge's readiness registry, and Botlish arms the watch. Dropping it
//!   releases the descriptor to Botlish, which unwatches and closes it.
//! * `MemPipe`: a bounded in-memory duplex, for the deterministic driver
//!   (no descriptors there). Each direction holds at most CAPACITY bytes:
//!   a full pipe makes the writer wait, as a full socket buffer does.

use hs_bridge::io;
use std::collections::VecDeque;
use std::io::{Error, ErrorKind};
use std::pin::Pin;
use std::sync::{Arc, Mutex};
use std::task::{Context, Poll, Waker};

pub trait Stream: hyper::rt::Read + hyper::rt::Write + Unpin + Send + 'static {}
impl<T: hyper::rt::Read + hyper::rt::Write + Unpin + Send + 'static> Stream for T {}

pub type BoxStream = Box<dyn Stream>;

pub struct FdStream {
    fd: i32,
    shut: bool,
}

impl FdStream {
    pub fn new(fd: i32) -> FdStream {
        FdStream { fd, shut: false }
    }

    pub fn fd(&self) -> i32 {
        self.fd
    }

    /// std::io adapter for synchronous-style users (the TLS adapter): a
    /// call that would block parks CX's waker and returns WouldBlock.
    pub fn read_sync(&mut self, cx: &mut Context<'_>, buf: &mut [u8]) -> std::io::Result<usize> {
        io::read(self.fd, buf, cx.waker())
    }

    pub fn write_sync(&mut self, cx: &mut Context<'_>, buf: &[u8]) -> std::io::Result<usize> {
        io::write(self.fd, buf, cx.waker())
    }
}

impl Drop for FdStream {
    fn drop(&mut self) {
        io::release(self.fd);
    }
}

fn would_block<T>(r: std::io::Result<T>) -> Poll<std::io::Result<T>> {
    match r {
        Err(e) if e.kind() == ErrorKind::WouldBlock => Poll::Pending,
        other => Poll::Ready(other),
    }
}

impl hyper::rt::Read for FdStream {
    fn poll_read(mut self: Pin<&mut Self>, cx: &mut Context<'_>, mut buf: hyper::rt::ReadBufCursor<'_>) -> Poll<std::io::Result<()>> {
        let n = unsafe {
            let raw = buf.as_mut();
            let slice = std::slice::from_raw_parts_mut(raw.as_mut_ptr().cast::<u8>(), raw.len());
            match would_block(self.read_sync(cx, slice)) {
                Poll::Ready(Ok(n)) => n,
                Poll::Ready(Err(e)) => return Poll::Ready(Err(e)),
                Poll::Pending => return Poll::Pending,
            }
        };
        unsafe { buf.advance(n) };
        Poll::Ready(Ok(()))
    }
}

impl hyper::rt::Write for FdStream {
    fn poll_write(mut self: Pin<&mut Self>, cx: &mut Context<'_>, buf: &[u8]) -> Poll<std::io::Result<usize>> {
        would_block(self.write_sync(cx, buf))
    }

    fn poll_flush(self: Pin<&mut Self>, _cx: &mut Context<'_>) -> Poll<std::io::Result<()>> {
        Poll::Ready(Ok(()))
    }

    fn poll_shutdown(mut self: Pin<&mut Self>, _cx: &mut Context<'_>) -> Poll<std::io::Result<()>> {
        if !self.shut {
            self.shut = true;
            unsafe { libc::shutdown(self.fd, libc::SHUT_WR) };
        }
        Poll::Ready(Ok(()))
    }
}

#[derive(Default)]
struct Half {
    bytes: VecDeque<u8>,
    closed: bool,
    reader: Option<Waker>,
    writer: Option<Waker>,
}

pub struct MemPipe {
    rx: Arc<Mutex<Half>>,
    tx: Arc<Mutex<Half>>,
    capacity: usize,
}

/// Two connected ends, each direction holding at most CAPACITY bytes.
pub fn mem_pair(capacity: usize) -> (MemPipe, MemPipe) {
    let a = Arc::new(Mutex::new(Half::default()));
    let b = Arc::new(Mutex::new(Half::default()));
    (
        MemPipe { rx: a.clone(), tx: b.clone(), capacity },
        MemPipe { rx: b, tx: a, capacity },
    )
}

impl Drop for MemPipe {
    fn drop(&mut self) {
        for half in [&self.rx, &self.tx] {
            let mut h = half.lock().unwrap();
            h.closed = true;
            if let Some(w) = h.reader.take() {
                w.wake();
            }
            if let Some(w) = h.writer.take() {
                w.wake();
            }
        }
    }
}

impl hyper::rt::Read for MemPipe {
    fn poll_read(self: Pin<&mut Self>, cx: &mut Context<'_>, mut buf: hyper::rt::ReadBufCursor<'_>) -> Poll<std::io::Result<()>> {
        let mut h = self.rx.lock().unwrap();
        if h.bytes.is_empty() {
            if h.closed {
                return Poll::Ready(Ok(()));
            }
            h.reader = Some(cx.waker().clone());
            return Poll::Pending;
        }
        let n = buf.remaining().min(h.bytes.len());
        let chunk: Vec<u8> = h.bytes.drain(..n).collect();
        buf.put_slice(&chunk);
        if let Some(w) = h.writer.take() {
            w.wake();
        }
        Poll::Ready(Ok(()))
    }
}

impl hyper::rt::Write for MemPipe {
    fn poll_write(self: Pin<&mut Self>, cx: &mut Context<'_>, buf: &[u8]) -> Poll<std::io::Result<usize>> {
        let mut h = self.tx.lock().unwrap();
        if h.closed {
            return Poll::Ready(Err(Error::from(ErrorKind::BrokenPipe)));
        }
        let room = self.capacity.saturating_sub(h.bytes.len());
        if room == 0 {
            h.writer = Some(cx.waker().clone());
            return Poll::Pending;
        }
        let n = room.min(buf.len());
        h.bytes.extend(&buf[..n]);
        if let Some(w) = h.reader.take() {
            w.wake();
        }
        Poll::Ready(Ok(n))
    }

    fn poll_flush(self: Pin<&mut Self>, _cx: &mut Context<'_>) -> Poll<std::io::Result<()>> {
        Poll::Ready(Ok(()))
    }

    fn poll_shutdown(self: Pin<&mut Self>, _cx: &mut Context<'_>) -> Poll<std::io::Result<()>> {
        let mut h = self.tx.lock().unwrap();
        h.closed = true;
        if let Some(w) = h.reader.take() {
            w.wake();
        }
        Poll::Ready(Ok(()))
    }
}
