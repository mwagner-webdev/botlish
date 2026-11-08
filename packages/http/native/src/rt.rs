//! Hyper's runtime traits, implemented by the bridge (no Tokio runtime),
//! and the one future combinator the client needs.
//!
//! * `Exec` spawns onto the bridge's bounded executor: Hyper's HTTP/2
//!   background futures become bridge tasks, polled only by
//!   Botlish-scheduled runs.
//! * `Timer` sleeps in the Botlish clock; `now()` is the Botlish clock too.

use crate::bridge::time;
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
        crate::bridge::spawn("hyper", async move {
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
            s.0.reset(time::micros_of(new_deadline));
            return;
        }
        *sleep = self.sleep_until(new_deadline);
    }
}

/// FUTURE, unless the Botlish clock reaches DEADLINE first (then Err(())).
/// No deadline: FUTURE alone.
pub async fn until<F: Future>(deadline: Option<u64>, future: F) -> Result<F::Output, ()> {
    let Some(deadline) = deadline else { return Ok(future.await) };
    let mut future = std::pin::pin!(future);
    let mut sleep = time::Sleep::until(deadline);
    std::future::poll_fn(|cx| {
        if let Poll::Ready(v) = future.as_mut().poll(cx) {
            return Poll::Ready(Ok(v));
        }
        if Pin::new(&mut sleep).poll(cx).is_ready() {
            return Poll::Ready(Err(()));
        }
        Poll::Pending
    })
    .await
}

/// FUTURE, unless DELAY microseconds of the Botlish clock pass first.
/// Zero: no limit.
pub async fn within<F: Future>(delay: u64, future: F) -> Result<F::Output, ()> {
    let deadline = (delay > 0).then(|| time::now().saturating_add(delay));
    until(deadline, future).await
}
