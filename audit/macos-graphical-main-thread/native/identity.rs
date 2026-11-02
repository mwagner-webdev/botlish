//! identity.rs -- a plain Rust `main` (MACOS-GRAPHICAL-MAIN-THREAD-CENSUS.md,
//! section 3): the fixture's report from Rust's own main thread and from a
//! std thread, the control for what a Rust runtime's startup does to thread
//! identity before any Botlish code. Built by tools/census.py with rustc
//! against libmtprobe.a.
unsafe extern "C" {
    fn mtp_mark(stage: i32) -> i32;
}

fn main() {
    // SAFETY: the fixture's functions take a stage number and only report.
    let on_main = unsafe { mtp_mark(0) };
    let on_thread = std::thread::spawn(|| unsafe { mtp_mark(19) }).join().unwrap();
    println!("[{on_main}, {on_thread}]");
}
