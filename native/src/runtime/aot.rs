//! Standalone executable startup. The initializer contains only constants,
//! function metadata and relocated stack maps; program instructions are
//! already machine code in the linked object.
//!
//! Process arguments (ARGV.md): the generated `main` collects the real
//! argument vector (`process_argv`) into one owned `Vec<Vec<u8>>` copy (it
//! does not borrow the C startup array) and passes it to `run`, which
//! installs it in the Vm as the run's argument snapshot before the program's
//! entry function executes. On Linux and macOS the vector is the
//! `argc`/`argv` the C runtime hands the process (glibc's, libSystem's),
//! which Rust's runtime keeps and `std::env::args_os` returns as raw
//! `OsString`s, i.e. the exact bytes, never decoded. On Windows a process
//! has one UTF-16 command line, which Rust's runtime splits into arguments
//! by the Microsoft C runtime's rules; each argument's UTF-16 code units are
//! encoded here as WTF-8 (`wtf8_from_utf16`), losslessly: valid UTF-16 is
//! its UTF-8, an unpaired surrogate the three bytes no valid UTF-8 holds.
//! Nothing is validated here: UTF-8 validation belongs to the `argv()`
//! operation (`ops.rs`'s `rt_argv`), so malformed arguments -- invalid UTF-8
//! on Linux, an unpaired surrogate on Windows -- cannot fail a program that
//! never asks for them. `argc == 0` yields an empty snapshot, and `argv()`
//! an empty List.
//!
//! The driver protocol (C-FFI.md, "Running a program that calls C"). The
//! driver runs a program that calls C by linking it as an executable -- the
//! one way its foreign symbols are resolved, by the system linker -- and
//! running that, with `BOTLISH_NATIVE_RESULT` naming a file: the executable
//! then reports exactly as `botlish-native run` does (result lines `value
//! V` / `error CODE MESSAGE` in the host value format, the overflow guard's
//! report among them) to that file instead of printing its value, and
//! leaves its standard output and error to the program. With
//! `BOTLISH_NATIVE_RUNS=N` it runs the program N times, as `bench` does,
//! reporting `times` and `timing` lines (`BOTLISH_NATIVE_COMPILE_US`, the
//! driver's compile and link time, is the timing line's first field). An
//! ordinary run of the executable, with neither variable, is unchanged.
use super::error::RtError;
use super::metrics::AllocMode;
use super::show::{show, tcl_list, tcl_value};
use super::value::{NO_VALUE, Value};
use super::vm::Vm;
use std::io::Write;

pub type ProgramEntry = extern "C" fn(*mut Vm) -> Value;

/// This process's own argument vector, argument zero first, as the run's
/// argument snapshot: the raw bytes of every argument on Unix, the WTF-8 of
/// every argument's UTF-16 on Windows (the module doc).
pub fn process_argv() -> Vec<Vec<u8>> {
    #[cfg(unix)]
    {
        use std::os::unix::ffi::OsStringExt;
        std::env::args_os().map(|a| a.into_vec()).collect()
    }
    #[cfg(windows)]
    {
        use std::os::windows::ffi::OsStrExt;
        std::env::args_os().map(|a| wtf8_from_utf16(a.encode_wide())).collect()
    }
}

/// The WTF-8 encoding of the UTF-16 code units UNITS (an argument of a
/// Windows command line): every surrogate pair and every other scalar value
/// as its UTF-8, and an unpaired surrogate -- which UTF-16 text may hold and
/// no Unicode scalar is -- as the three-byte form of its code unit
/// (U+D800-U+DFFF: `ED A0 80`..`ED BF BF`), which strict UTF-8 rejects. So
/// the encoding is lossless, a valid argument's bytes are exactly its UTF-8,
/// and `argv()` refuses an invalid one with the same declared error as
/// invalid UTF-8 on Linux. Written here rather than read from `OsString`'s
/// internal encoding, which Rust leaves unspecified.
pub fn wtf8_from_utf16(units: impl IntoIterator<Item = u16>) -> Vec<u8> {
    let mut bytes = Vec::new();
    for decoded in char::decode_utf16(units) {
        match decoded {
            Ok(c) => bytes.extend_from_slice(c.encode_utf8(&mut [0; 4]).as_bytes()),
            Err(e) => {
                let unit = e.unpaired_surrogate();
                bytes.extend_from_slice(&[0xE0 | (unit >> 12) as u8, 0x80 | ((unit >> 6) & 0x3F) as u8, 0x80 | (unit & 0x3F) as u8]);
            }
        }
    }
    bytes
}

/// The UTF-16 code units whose WTF-8 encoding (`wtf8_from_utf16`) is BYTES:
/// its exact inverse, for the driver writing a Windows command line from an
/// argument snapshot (WINDOWS-X86-64-MILESTONE-2.md, "Linked runs"). None
/// when BYTES encodes no units: bytes that are not well-formed generalized
/// UTF-8 (a stray or missing continuation byte, an overlong form, a value
/// past U+10FFFF), or a surrogate pair written as two three-byte surrogates
/// -- WTF-8 writes a pair as its scalar's four bytes, so decoding those six
/// bytes would give units that encode back to other bytes.
pub fn utf16_from_wtf8(bytes: &[u8]) -> Option<Vec<u16>> {
    let mut units = Vec::with_capacity(bytes.len());
    // Whether the last unit pushed was a lead surrogate written alone.
    let mut lone_lead = false;
    let mut i = 0;
    while i < bytes.len() {
        let first = bytes[i];
        let (length, initial, minimum) = match first {
            0x00..=0x7F => (1, first as u32, 0),
            0xC0..=0xDF => (2, (first & 0x1F) as u32, 0x80),
            0xE0..=0xEF => (3, (first & 0x0F) as u32, 0x800),
            0xF0..=0xF7 => (4, (first & 0x07) as u32, 0x1_0000),
            _ => return None,
        };
        let tail = bytes.get(i + 1..i + length)?;
        let mut code = initial;
        for &b in tail {
            if b & 0xC0 != 0x80 {
                return None;
            }
            code = (code << 6) | (b & 0x3F) as u32;
        }
        if code < minimum || code > 0x10_FFFF {
            return None;
        }
        i += length;
        if (0xD800..=0xDFFF).contains(&code) {
            if code >= 0xDC00 && lone_lead {
                return None;
            }
            lone_lead = code < 0xDC00;
            units.push(code as u16);
            continue;
        }
        lone_lead = false;
        let mut buffer = [0u16; 2];
        units.extend_from_slice(char::from_u32(code)?.encode_utf16(&mut buffer));
    }
    Some(units)
}

pub fn run(argv: Vec<Vec<u8>>, init: impl FnOnce() -> (Box<Vm>, ProgramEntry) + Send + 'static) -> i32 {
    let stack_size = std::env::var("BOTLISH_NATIVE_STACK_BYTES")
        .ok()
        .and_then(|text| text.parse::<usize>().ok())
        .filter(|&size| size >= 1 << 20)
        .unwrap_or(1 << 30);
    let protocol = std::env::var_os("BOTLISH_NATIVE_RESULT").filter(|p| !p.is_empty());
    let worker = std::thread::Builder::new().stack_size(stack_size).spawn(move || {
        let (mut vm, entry) = init();
        vm.set_argv(argv);
        debug_assert!(matches!(vm.metrics.mode, AllocMode::Off));
        if let Some(path) = protocol {
            return driver_protocol(std::path::Path::new(&path), &mut vm, entry);
        }
        #[cfg(any(all(target_os = "linux", any(target_arch = "x86_64", target_arch = "aarch64")), all(target_os = "macos", target_arch = "aarch64"), all(windows, target_arch = "x86_64", target_env = "msvc")))]
        let _guard = {
            let stack = super::native_stack::NativeStack::current().expect("the thread's stack bounds");
            super::platform::OverflowGuard::install_executable(&stack).expect("the stack-overflow guard")
        };
        let result = entry(&mut *vm);
        if result == NO_VALUE {
            let error = vm
                .error
                .take()
                .unwrap_or_else(|| RtError::Bug("native code failed without recording an error".to_string()));
            eprintln!("{} ({})", vm.describe_error(&error), error.error_code().join(" "));
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
    let status = match worker {
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
    };
    // BOTLISH_NATIVE_UNWIND_CHECK's account (runtime::framewalk).
    #[cfg(all(windows, target_arch = "x86_64"))]
    if let Some(summary) = super::framewalk::windows::summary() {
        eprintln!("{summary}");
    }
    status
}

/// Runs the program as `botlish-native run` (or `bench`) would and writes its
/// result lines to PATH (the header's "driver protocol"). Returns the exit
/// status: 0 whenever the result lines were written, a program error
/// included.
fn driver_protocol(path: &std::path::Path, vm: &mut Vm, entry: ProgramEntry) -> i32 {
    let mut file = match std::fs::File::create(path) {
        Ok(file) => file,
        Err(error) => {
            eprintln!("{}: {error} (NATIVE IO)", path.display());
            return 2;
        }
    };
    #[cfg(any(all(target_os = "linux", any(target_arch = "x86_64", target_arch = "aarch64")), all(target_os = "macos", target_arch = "aarch64"), all(windows, target_arch = "x86_64", target_env = "msvc")))]
    let _guard = {
        super::platform::set_result_file(&file);
        let stack = super::native_stack::NativeStack::current().expect("the thread's stack bounds");
        super::platform::OverflowGuard::install(&stack).expect("the stack-overflow guard")
    };
    let runs = std::env::var("BOTLISH_NATIVE_RUNS").ok().and_then(|n| n.parse::<usize>().ok()).filter(|n| *n > 0);
    let mut lines = Vec::new();
    let mut result = NO_VALUE;
    let mut nanos = Vec::new();
    let mut best = u128::MAX;
    for run in 0..runs.unwrap_or(1) {
        if run > 0 {
            vm.reset();
        }
        let started = std::time::Instant::now();
        result = entry(&mut *vm);
        let elapsed = started.elapsed();
        nanos.push(elapsed.as_nanos().to_string());
        best = best.min(elapsed.as_micros());
        if result == NO_VALUE {
            break;
        }
    }
    if let Some(runs) = runs {
        let compile = std::env::var("BOTLISH_NATIVE_COMPILE_US").unwrap_or_else(|_| "0".to_string());
        lines.push(format!("times {}", nanos.join(" ")));
        lines.push(format!("timing {compile} {best} {runs} {}", vm.heap.collections));
    }
    if result == NO_VALUE {
        let error = vm
            .error
            .take()
            .unwrap_or_else(|| RtError::Bug("native code failed without recording an error".to_string()));
        let code: Vec<String> = error.error_code().iter().map(|w| w.to_string()).collect();
        lines.push(tcl_list(&["error".to_string(), tcl_list(&code), vm.describe_error(&error)]));
    } else {
        match tcl_value(result) {
            Ok(value) => lines.push(tcl_list(&["value".to_string(), value])),
            Err(error) => {
                let code: Vec<String> = error.error_code().iter().map(|w| w.to_string()).collect();
                lines.push(tcl_list(&["error".to_string(), tcl_list(&code), error.message()]));
            }
        }
    }
    for line in lines {
        if writeln!(file, "{line}").is_err() {
            return 2;
        }
    }
    0
}
