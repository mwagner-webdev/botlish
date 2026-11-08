//! The bridge: the Rust half of the Botlish event-loop boundary
//! (HTTP-STACK-INTEGRATION-CENSUS.md, "Scheduling" and "Rust/C FFI";
//! HTTP-CLIENT-PACKAGE-MILESTONE-1.md, "The bridge").
//!
//! One rule organizes it: **Rust never decides when work runs.** Every line
//! of Rust code here runs inside a call a Botlish task made (`ffi::guard`),
//! on the thread that runs the Botlish event loop, with one exception: the
//! name resolver's worker threads (`crate::net`), which run `getaddrinfo`
//! and nothing else, and complete through a foreign wake.
//!
//! * `exec` is a bounded executor: `run(budget)` polls at most BUDGET of the
//!   futures that were ready when it started, each at most once, and
//!   reports how many are ready now. A wake enqueues; nothing is polled
//!   from a waker.
//! * `time` keeps Rust timers in the Botlish driver's clock (microseconds
//!   Botlish passes in): Hyper's `Timer`, the client's connect, idle and
//!   deadline timers become one earliest deadline, which a Botlish timer
//!   registration waits for.
//! * `io` never waits on a descriptor: an operation that would block parks
//!   its waker and asks Botlish for readiness interest; Botlish arms its
//!   own watch (event_loop_linux) and reports readiness back. A descriptor
//!   is closed only by Botlish, after it unwatched it.
//! * `notices` are how Rust tells a Botlish coroutine that a handle it
//!   waits on changed.
//!
//! A wake from a foreign thread enqueues under a mutex and, on the queue's
//! empty-to-non-empty edge, posts one record through the event loop's
//! integration ABI (`notify.c`), never calling Botlish.

pub mod exec;
pub mod ffi;
pub mod io;
pub mod notices;
pub mod slab;
pub mod stats;
pub mod time;

pub use exec::{spawn, TaskKey};
