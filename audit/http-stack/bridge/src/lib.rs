//! hs_bridge -- the Rust half of the census's Botlish/Rust boundary
//! (HTTP-STACK-INTEGRATION-CENSUS.md, "Rust/C FFI" and "Scheduling").
//!
//! One rule organizes it: **Rust never decides when work runs.** Every line
//! of Rust code here runs inside a call a Botlish task made (`ffi::guard`),
//! on the thread that runs the Botlish event loop:
//!
//! * `exec` is a bounded executor: `run(budget)` polls at most BUDGET of the
//!   futures that were ready when it started, each at most once, and
//!   reports how many are ready now. A wake enqueues; nothing is polled
//!   from a waker. Botlish yields (`std::event_loop::yield_now`) while work
//!   remains and waits on its registration when none does.
//! * `time` keeps Rust timers in the Botlish driver's clock (microseconds
//!   Botlish passes in): Hyper's `Timer` and quiche's deadlines become one
//!   earliest deadline, which a Botlish timer registration waits for.
//! * `io` never waits on a descriptor: an operation that would block parks
//!   its waker and asks Botlish for readiness interest; Botlish arms its
//!   own watch (event_loop_linux) and reports readiness back. A descriptor
//!   is closed only by Botlish, after it unwatched it.
//! * `notices` are how Rust tells a Botlish coroutine that a handle it
//!   waits on changed: Botlish drains them after each call and posts to
//!   the waiting coroutine's registration.
//!
//! The one exception is a wake from a foreign thread (a library's own
//! thread): it enqueues under a mutex and, on the queue's empty-to-non-empty
//! edge, posts one record through the event loop's integration ABI
//! (`notify.c`), never calling Botlish.

pub mod exec;
pub mod ffi;
pub mod io;
pub mod notices;
pub mod slab;
pub mod stats;
pub mod time;

pub use exec::{run, spawn, TaskKey};
pub use ffi::guard;
