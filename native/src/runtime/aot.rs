//! Standalone executable startup. The initializer contains only constants,
//! function metadata and relocated stack maps; program instructions are
//! already machine code in the linked object.
//!
//! Process arguments (ARGV.md): the generated `main` collects the real
//! Linux argument vector -- the `argc`/`argv` glibc hands the process,
//! which Rust's runtime keeps and `std::env::args_os` returns as raw
//! `OsString`s, i.e. the exact bytes, never decoded -- into one owned
//! `Vec<Vec<u8>>` copy (it does not borrow the C startup array) and passes
//! it to `run`, which installs it in the Vm as the run's argument snapshot
//! before the program's entry function executes. Nothing is validated here:
//! UTF-8 validation belongs to the `argv()` operation (`ops.rs`'s
//! `rt_argv`), so malformed arguments cannot fail a program that never
//! asks for them. `argc == 0` yields an empty snapshot, and `argv()` an
//! empty List.
use super::error::RtError;
use super::metrics::AllocMode;
use super::show::show;
use super::value::{NO_VALUE, Value};
use super::vm::Vm;
use std::io::Write;

pub type ProgramEntry = extern "C" fn(*mut Vm) -> Value;

pub fn run(argv: Vec<Vec<u8>>, init: impl FnOnce() -> (Box<Vm>, ProgramEntry) + Send + 'static) -> i32 {
    let stack_size = std::env::var("BOTLISH_NATIVE_STACK_BYTES")
        .ok()
        .and_then(|text| text.parse::<usize>().ok())
        .filter(|&size| size >= 1 << 20)
        .unwrap_or(1 << 30);
    let worker = std::thread::Builder::new().stack_size(stack_size).spawn(move || {
        let (mut vm, entry) = init();
        vm.set_argv(argv);
        debug_assert!(matches!(vm.metrics.mode, AllocMode::Off));
        #[cfg(all(target_arch = "x86_64", target_os = "linux"))]
        let _guard = {
            let stack = super::native_stack::NativeStack::current().expect("pthread stack bounds");
            super::platform::x86_64_linux::OverflowGuard::install_executable(&stack).expect("pthread stack guard")
        };
        let result = entry(&mut *vm);
        if result == NO_VALUE {
            let error = vm
                .error
                .take()
                .unwrap_or_else(|| RtError::Bug("native code failed without recording an error".to_string()));
            eprintln!("{} ({})", error.message(), error.error_code().join(" "));
            return 1;
        }
        match writeln!(std::io::stdout().lock(), "{}", show(result)) {
            Ok(()) => 0,
            Err(error) => {
                eprintln!("{error} (NATIVE IO)");
                1
            }
        }
    });
    match worker {
        Ok(worker) => match worker.join() {
            Ok(status) => status,
            Err(_) => {
                eprintln!("native executable panicked (NATIVE BUG)");
                1
            }
        },
        Err(error) => {
            eprintln!("{error} (NATIVE STARTUP)");
            1
        }
    }
}
