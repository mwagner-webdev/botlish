//! Starting a linked program on Windows with a given argument vector
//! (WINDOWS-X86-64-MILESTONE-2.md, "Linked runs"; ARGV.md, "Windows").
//!
//! A program that calls C runs as an executable the driver links for the run
//! (main.rs's `run_linked`), started with the run's argument snapshot. A Unix
//! process receives an argument vector, so the driver passes the snapshot's
//! bytes as they are, argument zero included (`CommandExt::arg0`). A Windows
//! process receives one command line, which its C runtime splits; and
//! `std::process` writes that line with the executable's path as argument
//! zero, whatever the snapshot's is. So on Windows the driver writes the
//! command line itself and starts the executable with `CreateProcessW`,
//! naming the executable separately (`lpApplicationName`): no shell, no
//! `PATH` search, nothing joined naively.
//!
//! The line is written so that the executable's own split -- Rust's runtime's
//! (`std::env::args_os`), the modern Microsoft C runtime's rules, which
//! runtime/aot.rs's `process_argv` reads -- gives back every argument
//! exactly, as UTF-16, which `process_argv` encodes as WTF-8 again:
//!
//!   * argument zero is read by its own rule (quotes toggle, no escapes), so
//!     it is written between quotes and may hold anything but a quotation
//!     mark, which that rule cannot express;
//!   * every other argument is written between quotes, a quotation mark as
//!     `\"`, the backslashes right before one (or before the closing quote)
//!     doubled -- `std::process`'s own quoting of its arguments.
//!
//! Each snapshot argument is decoded from WTF-8 (`runtime::aot::
//! utf16_from_wtf8`), so a valid UTF-8 argument is its UTF-16 and an
//! unpaired surrogate's three-byte form is that surrogate. A snapshot
//! argument no Windows argument can be -- bytes that are no WTF-8, a NUL, a
//! quotation mark in argument zero -- is refused before anything runs, never
//! replaced; so is a line longer than a Windows command line may be.
//!
//! Only `command_line` and `utf16_arguments` are platform-independent (and
//! unit-tested on every host); `run` is Windows'.

// The command line's writer is Windows', but unit-tested on every host.
#![cfg_attr(not(windows), allow(dead_code))]

use botlish_native::runtime::aot::utf16_from_wtf8;

const QUOTE: u16 = b'"' as u16;
const BACKSLASH: u16 = b'\\' as u16;
const SPACE: u16 = b' ' as u16;

/// The longest command line `CreateProcessW` accepts, in UTF-16 code units
/// with its terminating NUL.
pub const COMMAND_LINE_LIMIT: usize = 32767;

/// The snapshot ARGV's arguments as UTF-16, or why one cannot be a Windows
/// argument.
pub fn utf16_arguments(argv: &[Vec<u8>]) -> Result<Vec<Vec<u16>>, String> {
    argv.iter()
        .enumerate()
        .map(|(i, bytes)| {
            let units = utf16_from_wtf8(bytes).ok_or_else(|| {
                format!("argument {i} of the argument vector is not WTF-8 (invalid UTF-8 that is no unpaired surrogate's form), and a Windows process's arguments are UTF-16: a linked run on Windows cannot pass it")
            })?;
            if units.contains(&0) {
                return Err(format!("argument {i} of the argument vector holds a NUL, which no Windows argument can (the command line is NUL-terminated)"));
            }
            Ok(units)
        })
        .collect()
}

/// The command line (without its terminating NUL) that a Windows program
/// splitting it by the Microsoft C runtime's rules reads as ARGV, argument
/// zero first.
pub fn command_line(argv: &[Vec<u16>]) -> Result<Vec<u16>, String> {
    let (zero, rest) = argv
        .split_first()
        .ok_or("a Windows process has at least one argument: an empty argument vector cannot be given to it")?;
    if zero.contains(&QUOTE) {
        return Err("argument zero of the argument vector holds a quotation mark, which a Windows command line cannot give a program's argument zero (it is read with no escapes: a quotation mark only opens or closes quoting)".to_string());
    }
    let mut line = Vec::with_capacity(argv.iter().map(|a| a.len() + 3).sum());
    line.push(QUOTE);
    line.extend_from_slice(zero);
    line.push(QUOTE);
    for argument in rest {
        line.push(SPACE);
        line.push(QUOTE);
        let mut backslashes = 0;
        for &unit in argument {
            if unit == BACKSLASH {
                backslashes += 1;
            } else {
                if unit == QUOTE {
                    // 2n+1 backslashes: n literal ones, then the quote.
                    line.extend(std::iter::repeat_n(BACKSLASH, backslashes + 1));
                }
                backslashes = 0;
            }
            line.push(unit);
        }
        // 2n backslashes before the closing quote: n literal ones.
        line.extend(std::iter::repeat_n(BACKSLASH, backslashes));
        line.push(QUOTE);
    }
    if line.len() >= COMMAND_LINE_LIMIT {
        return Err(format!(
            "the argument vector makes a command line of {} UTF-16 code units, and a Windows command line holds at most {} with its terminator",
            line.len(),
            COMMAND_LINE_LIMIT
        ));
    }
    Ok(line)
}

/// How a run of the linked program could not happen.
pub enum LaunchError {
    /// The argument vector is no Windows process's (NATIVE UNSUPPORTED).
    Arguments(String),
    /// The operating system refused to start it (NATIVE IO).
    System(String),
}

/// Runs EXECUTABLE with the argument vector ARGV (argument zero first, as
/// WTF-8 bytes), its standard input, output and error this process's own,
/// and waits for it: its exit code, as Windows reports it.
///
/// The environment is this process's, which `run_linked` has set for the
/// run. The standard handles are passed as inheritable duplicates
/// (`STARTF_USESTDHANDLES`), as `std::process` passes inherited ones, so a
/// redirected output reaches the same file or pipe; a missing one (null, or
/// `INVALID_HANDLE_VALUE`) is passed as it is.
#[cfg(windows)]
pub fn run(executable: &std::path::Path, argv: &[Vec<u8>]) -> Result<u32, LaunchError> {
    use std::os::windows::ffi::OsStrExt;
    use win32::*;
    let units = utf16_arguments(argv).map_err(LaunchError::Arguments)?;
    let mut line = command_line(&units).map_err(LaunchError::Arguments)?;
    line.push(0);
    let application: Vec<u16> = executable.as_os_str().encode_wide().chain([0]).collect();
    // SAFETY: plain Win32 calls on handles this function owns or borrows
    // for their duration; every structure is zero-initialized C data of
    // the documented layout, and every buffer is NUL-terminated.
    unsafe {
        let process = GetCurrentProcess();
        let mut duplicates: Vec<Handle> = Vec::new();
        let mut inheritable = |which: u32| -> Handle {
            let handle = GetStdHandle(which);
            if handle.is_null() || handle == INVALID_HANDLE_VALUE {
                return handle;
            }
            let mut duplicate: Handle = std::ptr::null_mut();
            if DuplicateHandle(process, handle, process, &mut duplicate, 0, 1, DUPLICATE_SAME_ACCESS) == 0 {
                return handle;
            }
            duplicates.push(duplicate);
            duplicate
        };
        let mut startup: StartupInfoW = std::mem::zeroed();
        startup.cb = std::mem::size_of::<StartupInfoW>() as u32;
        startup.flags = STARTF_USESTDHANDLES;
        startup.std_input = inheritable(STD_INPUT_HANDLE);
        startup.std_output = inheritable(STD_OUTPUT_HANDLE);
        startup.std_error = inheritable(STD_ERROR_HANDLE);
        let mut information: ProcessInformation = std::mem::zeroed();
        let created = CreateProcessW(
            application.as_ptr(),
            line.as_mut_ptr(),
            std::ptr::null_mut(),
            std::ptr::null_mut(),
            1,
            CREATE_UNICODE_ENVIRONMENT,
            std::ptr::null_mut(),
            std::ptr::null(),
            &mut startup,
            &mut information,
        );
        let error = GetLastError();
        for duplicate in duplicates {
            CloseHandle(duplicate);
        }
        if created == 0 {
            return Err(LaunchError::System(format!(
                "CreateProcessW of {} failed: {}",
                executable.display(),
                std::io::Error::from_raw_os_error(error as i32)
            )));
        }
        CloseHandle(information.thread);
        WaitForSingleObject(information.process, INFINITE);
        let mut code = 0u32;
        let got = GetExitCodeProcess(information.process, &mut code);
        let error = GetLastError();
        CloseHandle(information.process);
        if got == 0 {
            return Err(LaunchError::System(format!(
                "GetExitCodeProcess of {} failed: {}",
                executable.display(),
                std::io::Error::from_raw_os_error(error as i32)
            )));
        }
        Ok(code)
    }
}

/// The kernel32 functions and structures `run` uses, declared by hand from
/// their documented prototypes (the driver has no Windows bindings crate).
#[cfg(windows)]
#[allow(non_snake_case)]
mod win32 {
    pub type Handle = *mut std::ffi::c_void;
    pub const INVALID_HANDLE_VALUE: Handle = -1isize as Handle;
    pub const STD_INPUT_HANDLE: u32 = -10i32 as u32;
    pub const STD_OUTPUT_HANDLE: u32 = -11i32 as u32;
    pub const STD_ERROR_HANDLE: u32 = -12i32 as u32;
    pub const STARTF_USESTDHANDLES: u32 = 0x100;
    pub const DUPLICATE_SAME_ACCESS: u32 = 2;
    pub const CREATE_UNICODE_ENVIRONMENT: u32 = 0x400;
    pub const INFINITE: u32 = 0xFFFF_FFFF;

    /// STARTUPINFOW.
    #[repr(C)]
    pub struct StartupInfoW {
        pub cb: u32,
        pub reserved: *mut u16,
        pub desktop: *mut u16,
        pub title: *mut u16,
        pub x: u32,
        pub y: u32,
        pub x_size: u32,
        pub y_size: u32,
        pub x_count_chars: u32,
        pub y_count_chars: u32,
        pub fill_attribute: u32,
        pub flags: u32,
        pub show_window: u16,
        pub reserved2_size: u16,
        pub reserved2: *mut u8,
        pub std_input: Handle,
        pub std_output: Handle,
        pub std_error: Handle,
    }

    /// PROCESS_INFORMATION.
    #[repr(C)]
    pub struct ProcessInformation {
        pub process: Handle,
        pub thread: Handle,
        pub process_id: u32,
        pub thread_id: u32,
    }

    #[link(name = "kernel32")]
    unsafe extern "system" {
        pub fn CreateProcessW(
            application_name: *const u16,
            command_line: *mut u16,
            process_attributes: *mut std::ffi::c_void,
            thread_attributes: *mut std::ffi::c_void,
            inherit_handles: i32,
            creation_flags: u32,
            environment: *mut std::ffi::c_void,
            current_directory: *const u16,
            startup_info: *mut StartupInfoW,
            process_information: *mut ProcessInformation,
        ) -> i32;
        pub fn GetStdHandle(which: u32) -> Handle;
        pub fn GetCurrentProcess() -> Handle;
        pub fn DuplicateHandle(
            source_process: Handle,
            source: Handle,
            target_process: Handle,
            target: *mut Handle,
            desired_access: u32,
            inherit: i32,
            options: u32,
        ) -> i32;
        pub fn WaitForSingleObject(handle: Handle, milliseconds: u32) -> u32;
        pub fn GetExitCodeProcess(process: Handle, code: *mut u32) -> i32;
        pub fn CloseHandle(handle: Handle) -> i32;
        pub fn GetLastError() -> u32;
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    /// The split a Windows program's runtime makes of LINE: Rust's
    /// `std::env::args_os` on Windows (library/std's `parse_lp_cmd_line`),
    /// the modern Microsoft C runtime's rules, transcribed here as the
    /// reader `command_line` writes for -- argument zero up to the first
    /// unquoted space or tab, quotes toggling and nothing escaped; then
    /// spaces and tabs separating arguments outside quotes, backslashes
    /// literal unless a quote follows them (2n: n and a quote that toggles,
    /// 2n+1: n and a literal quote), `""` inside quotes a literal quote.
    fn split(line: &[u16]) -> Vec<Vec<u16>> {
        const TAB: u16 = b'\t' as u16;
        let mut arguments = Vec::new();
        let mut units = line.iter().copied().peekable();
        let mut current = Vec::new();
        let mut quoted = false;
        for unit in units.by_ref() {
            match unit {
                QUOTE => quoted = !quoted,
                SPACE | TAB if !quoted => break,
                _ => current.push(unit),
            }
        }
        arguments.push(std::mem::take(&mut current));
        while units.peek().is_some_and(|&u| u == SPACE || u == TAB) {
            units.next();
        }
        let mut quoted = false;
        while let Some(unit) = units.next() {
            match unit {
                SPACE | TAB if !quoted => {
                    arguments.push(std::mem::take(&mut current));
                    while units.peek().is_some_and(|&u| u == SPACE || u == TAB) {
                        units.next();
                    }
                }
                BACKSLASH => {
                    let mut count = 1;
                    while units.peek() == Some(&BACKSLASH) {
                        units.next();
                        count += 1;
                    }
                    if units.peek() == Some(&QUOTE) {
                        current.extend(std::iter::repeat_n(BACKSLASH, count / 2));
                        if count % 2 == 1 {
                            units.next();
                            current.push(QUOTE);
                        }
                    } else {
                        current.extend(std::iter::repeat_n(BACKSLASH, count));
                    }
                }
                QUOTE if quoted => match units.peek() {
                    Some(&QUOTE) => {
                        current.push(QUOTE);
                        units.next();
                    }
                    Some(_) => quoted = false,
                    None => break,
                },
                QUOTE => quoted = true,
                _ => current.push(unit),
            }
        }
        if !current.is_empty() || quoted {
            arguments.push(current);
        }
        arguments
    }

    fn wide(text: &str) -> Vec<u16> {
        text.encode_utf16().collect()
    }

    /// Every argument comes back exactly through the split: spaces, tabs,
    /// quotes, backslash runs before a quote, inside and at the end, the
    /// empty argument (first, last, alone), `%PATH%`, UNC paths, non-ASCII
    /// and astral text, unpaired surrogates; argument zero with spaces,
    /// tabs, backslashes and empty.
    #[test]
    fn launch_command_line_round_trips_through_the_runtimes_split() {
        let arguments = [
            "", "a", "a b", "a\tb", "\"", "\"\"", "a\"b", "\\", "\\\\", "a\\", "a\\\\", "a\\\"", "\\\"",
            "\\\\\"\\", "C:\\Program Files\\x\\", "\\\\server\\share\\dir\\", "%PATH%", "  lead", "trail  ",
            "\u{e9}t\u{e9}", "e\u{301}", "\u{1f600}", "\u{10ffff}", "--", "-a=b c", "'single'", "^&|<>()",
        ];
        let zeros = ["C:\\tools\\program.exe", "program", "dir with space\\p.exe", "tab\there", "", "\\\\?\\C:\\x", "\u{1f600}"];
        for zero in zeros {
            for count in [0, 1, 2, arguments.len()] {
                let mut argv = vec![wide(zero)];
                argv.extend(arguments.iter().take(count).map(|a| wide(a)));
                assert_eq!(split(&command_line(&argv).unwrap()), argv, "{zero:?} with {count} arguments");
            }
            for argument in arguments {
                for (before, after) in [("", ""), ("x", ""), ("", "x"), ("\\", "\\"), ("\"", "\"")] {
                    let argv = vec![wide(zero), wide(&format!("{before}{argument}{after}")), wide("")];
                    assert_eq!(split(&command_line(&argv).unwrap()), argv, "{zero:?} {argument:?}");
                }
            }
        }
        let surrogates = vec![wide("p"), vec![0xD800], vec![0x61, 0xDC00, 0x62], vec![0xDE00, 0xD83D]];
        assert_eq!(split(&command_line(&surrogates).unwrap()), surrogates);
        // A pseudo-random sample of arguments over the units that matter.
        let mut state = 0x9e37_79b9_7f4a_7c15u64;
        let mut next = || {
            state ^= state << 13;
            state ^= state >> 7;
            state ^= state << 17;
            state
        };
        for _ in 0..5000 {
            let count = (next() % 5) as usize;
            let mut argv = vec![wide("prog")];
            for _ in 0..count {
                let length = (next() % 8) as usize;
                argv.push((0..length).map(|_| [QUOTE, BACKSLASH, SPACE, b'\t' as u16, b'a' as u16, 0xD800][(next() % 6) as usize]).collect());
            }
            assert_eq!(split(&command_line(&argv).unwrap()), argv, "{argv:x?}");
        }
    }

    /// What no Windows argument vector can be is refused, never written
    /// approximately: no argument zero, a quotation mark in it, bytes that
    /// are no WTF-8, a NUL, a line past the system's limit.
    #[test]
    fn launch_refuses_what_a_windows_command_line_cannot_hold() {
        assert!(command_line(&[]).is_err());
        assert!(command_line(&[wide("a\"b")]).unwrap_err().contains("quotation mark"));
        assert!(utf16_arguments(&[b"p".to_vec(), b"a\xffb".to_vec()]).unwrap_err().contains("argument 1"));
        assert!(utf16_arguments(&[b"p".to_vec(), b"a\0b".to_vec()]).unwrap_err().contains("NUL"));
        assert_eq!(
            utf16_arguments(&[b"p".to_vec(), "\u{e9}".as_bytes().to_vec(), b"\xED\xA0\x80".to_vec()]).unwrap(),
            vec![wide("p"), wide("\u{e9}"), vec![0xD800]]
        );
        let long = vec![wide("p"), vec![b'x' as u16; COMMAND_LINE_LIMIT]];
        assert!(command_line(&long).unwrap_err().contains("at most"));
        let fits = vec![wide("p"), vec![b'x' as u16; COMMAND_LINE_LIMIT - 7]];
        assert_eq!(command_line(&fits).unwrap().len(), COMMAND_LINE_LIMIT - 1);
    }
}
