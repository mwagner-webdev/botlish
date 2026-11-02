//! Hyper's runtime traits, implemented by the bridge (no Tokio runtime).
//!
//! * `Exec` spawns onto the bridge's bounded executor: Hyper's HTTP/2
//!   background futures (the connection task, every server stream, the
//!   client's per-request pipes) become bridge tasks, polled only by
//!   Botlish-scheduled runs.
//! * `Timer` sleeps in the Botlish clock; `now()` is the Botlish clock too,
//!   so Hyper's own deadline arithmetic (HTTP/2 keep-alive, HTTP/1 header
//!   read timeout) is in the driver's time -- virtual under the
//!   deterministic driver.

use hs_bridge::time;
use std::future::Future;
use std::pin::Pin;
use std::task::{Context, Poll};
use std::time::{Duration, Instant};

#[derive(Clone, Copy, Default)]
pub struct Exec;

impl<F> hyper::rt::Executor<F> for Exec
where
    F: Future + 'static,
{
    fn execute(&self, future: F) {
        hs_bridge::spawn("hyper", async move {
            future.await;
        });
    }
}

#[derive(Clone, Copy, Default)]
pub struct Timer;

pub struct Sleep(time::Sleep);

impl Future for Sleep {
    type Output = ();
    fn poll(mut self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<()> {
        Pin::new(&mut self.0).poll(cx)
    }
}

impl hyper::rt::Sleep for Sleep {}

impl hyper::rt::Timer for Timer {
    fn sleep(&self, duration: Duration) -> Pin<Box<dyn hyper::rt::Sleep>> {
        Box::pin(Sleep(time::Sleep::after(duration)))
    }

    fn sleep_until(&self, deadline: Instant) -> Pin<Box<dyn hyper::rt::Sleep>> {
        Box::pin(Sleep(time::Sleep::until(time::micros_of(deadline))))
    }

    fn now(&self) -> Instant {
        time::instant_of(time::now())
    }

    fn reset(&self, sleep: &mut Pin<Box<dyn hyper::rt::Sleep>>, new_deadline: Instant) {
        if let Some(mut s) = sleep.as_mut().downcast_mut_pin::<Sleep>() {
            // Sleep is Unpin; reset in place.
            s.0.reset(time::micros_of(new_deadline));
            return;
        }
        *sleep = self.sleep_until(new_deadline);
    }
}
