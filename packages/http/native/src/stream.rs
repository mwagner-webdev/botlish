//! Byte streams Hyper reads and writes.
//!
//! `FdStream` is a nonblocking connected socket. Reads and writes are plain
//! system calls; one that would block parks its waker in the bridge's
//! readiness registry, and Botlish arms the watch. Dropping it releases the
//! descriptor to Botlish, which unwatches and closes it.

use crate::bridge::io;
use std::io::ErrorKind;
use std::pin::Pin;
use std::task::{Context, Poll};

pub trait Stream: hyper::rt::Read + hyper::rt::Write + Unpin + Send + 'static {}
impl<T: hyper::rt::Read + hyper::rt::Write + Unpin + Send + 'static> Stream for T {}

pub type BoxStream = Box<dyn Stream>;

pub struct FdStream {
    fd: i32,
    shut: bool,
}

impl FdStream {
    pub fn new(socket: crate::net::Socket) -> FdStream {
        FdStream { fd: socket.into_fd(), shut: false }
    }

    pub fn fd(&self) -> i32 {
        self.fd
    }

    /// std::io face for the TLS adapter: a call that would block parks
    /// CX's waker and returns WouldBlock.
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
