//! `botlish-native aot-run NAME FILE.nir`: the program built as a standalone
//! executable and run as a command (AOT-RUN-MILESTONE-1.md).
//!
//! The executable is the one `executable` links -- the same program object,
//! runtime, link plan, linker and startup policy (codegen::aot's
//! `emit_executable`) -- written into a private directory this command
//! creates for itself alone (`private_dir`: a fresh name under the system's
//! temporary directory, created exclusively, owner-only on Unix), and run
//! there as a child process:
//!
//!   * its argument vector is the run's snapshot (`--argv-file`), argument
//!     zero included, byte for byte (on Windows the command line launch.rs
//!     writes for it);
//!   * its standard input, output and error, working directory and
//!     environment are this driver's -- the user's -- except the variables
//!     `--child-env FILE` restores (a packaged compiler's own settings, put
//!     back as the user had them: single/main.tcl);
//!   * nothing of its output passes through this process, and nothing of
//!     this command's goes to standard output or error: its lines (below)
//!     go to `--result PATH`.
//!
//! It is run only once it is linked: a failed compilation or link reports
//! its error and runs nothing, and the directory is new for every run, so
//! there is never an earlier executable to run instead. The directory is
//! removed when the child has ended (`--keep` keeps it, with the program's
//! NIR beside the executable, and says where).
//!
//! While the child runs, this driver waits for it and passes on what is
//! meant for it, as system(3) does: SIGINT and SIGQUIT come from the
//! terminal to the whole foreground process group, the child's included,
//! so they are not sent again; SIGTERM and SIGHUP, which a process is sent
//! by name, are forwarded to the child. If the process that started this
//! driver (main.tcl) ends first -- killed, its terminal gone -- the child is
//! sent SIGTERM (on Windows, terminated): the program never outlives the
//! command that ran it. A signal received before the child is started stops
//! the run there: nothing is started after an interruption. On Windows the
//! console's Ctrl+C and Ctrl+Break reach every process attached to it, the
//! child's included, and this driver ignores them while it waits.
//!
//! The result lines, one Tcl list each:
//!
//! ```text
//!   executable PATH             the executable built (before it runs)
//!   timing BUILD_US START_US    from this command's start to the executable
//!                               linked, and to the child started
//!   status exit CODE            the child exited with CODE
//!   status signal N NAME        the child was ended by signal N (Unix)
//!   kept DIR                    --keep: DIR and its files were kept
//!   interrupted N NAME          signal N came before the child was started:
//!                               nothing ran
//!   error ERRORCODE MESSAGE     the program could not be built or started
//! ```
//!
//! The driver's exit status is the child's (on Unix 128+N for a signal, the
//! convention of POSIX shells' `$?`), 1 for an error, 128+N for an
//! interruption.

use crate::{codegen, emit, emit_error, emit_link_error};
use botlish_native::{nir, runtime};
use runtime::show::tcl_list;
use std::path::PathBuf;
use std::time::Instant;

/// What `aot-run` was asked to do besides the program and its link search.
pub struct Options {
    /// The executable's file name (main.tcl: the source's name without its
    /// extension); `program` when it is no plain file name.
    pub name: String,
    pub startup: runtime::program::Startup,
    /// The child's argument vector, argument zero first.
    pub argv: Vec<Vec<u8>>,
    pub keep: bool,
    /// The child's environment: these variables set (Some) or removed
    /// (None) in this driver's.
    pub environment: Vec<(String, Option<std::ffi::OsString>)>,
    /// The process that started this driver (main.tcl: `[pid]`), whose end
    /// ends the run; this driver's parent when absent.
    pub parent: Option<u32>,
}

/// The `--child-env FILE` lines: `unset NAME`, or `set NAME HEX` with the
/// value's bytes in hexadecimal (UTF-8). Err for anything else.
pub fn parse_environment(text: &str) -> Result<Vec<(String, Option<std::ffi::OsString>)>, String> {
    let mut changes = Vec::new();
    for line in text.lines().filter(|l| !l.is_empty()) {
        let words: Vec<&str> = line.split(' ').collect();
        let valid_name = |name: &str| !name.is_empty() && !name.contains(['=', '\0']);
        match words.as_slice() {
            ["unset", name] if valid_name(name) => changes.push((name.to_string(), None)),
            ["set", name, hex] if valid_name(name) && hex.len() % 2 == 0 => {
                let bytes: Option<Vec<u8>> = (0..hex.len()).step_by(2).map(|i| u8::from_str_radix(&hex[i..i + 2], 16).ok()).collect();
                let value = bytes.and_then(|b| String::from_utf8(b).ok()).ok_or_else(|| format!("--child-env: {line:?} is no UTF-8 value in hexadecimal"))?;
                if value.contains('\0') {
                    return Err(format!("--child-env: the value of {name} holds a NUL"));
                }
                changes.push((name.to_string(), Some(value.into())));
            }
            _ => return Err(format!("--child-env: {line:?} is neither `unset NAME` nor `set NAME HEX`")),
        }
    }
    Ok(changes)
}

/// NAME if it can be a file name in the private directory, else `program`.
fn file_name(name: &str) -> &str {
    if name.is_empty() || name == "." || name == ".." || name.contains(['/', '\\', '\0', ':']) {
        "program"
    } else {
        name
    }
}

/// A new directory for this run alone under the system's temporary
/// directory (std::env::temp_dir: $TMPDIR, GetTempPathW): created, never
/// found -- a name that exists already, whoever made it, is never used --
/// and on Unix readable, writable and searchable by its owner only, so no
/// other user can put a file in it or replace the executable before it
/// runs.
fn private_dir() -> std::io::Result<PathBuf> {
    static COUNTER: std::sync::atomic::AtomicU32 = std::sync::atomic::AtomicU32::new(0);
    let base = std::env::temp_dir();
    let mut last = None;
    for _ in 0..16 {
        let nonce = std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .map(|d| d.as_nanos())
            .unwrap_or(0);
        let count = COUNTER.fetch_add(1, std::sync::atomic::Ordering::Relaxed);
        let dir = base.join(format!("botlish-aot-run-{}-{nonce:x}-{count}", std::process::id()));
        #[cfg_attr(not(unix), allow(unused_mut))]
        let mut builder = std::fs::DirBuilder::new();
        #[cfg(unix)]
        {
            use std::os::unix::fs::DirBuilderExt;
            builder.mode(0o700);
        }
        match builder.create(&dir) {
            Ok(()) => return Ok(dir),
            Err(e) if e.kind() == std::io::ErrorKind::AlreadyExists => last = Some(e),
            Err(e) => return Err(std::io::Error::new(e.kind(), format!("{}: {e}", dir.display()))),
        }
    }
    Err(last.unwrap_or_else(|| std::io::Error::other("no fresh directory name")))
}

/// The private directory, removed when this value is dropped unless kept:
/// it holds nothing but what this run wrote.
struct Private {
    dir: PathBuf,
    keep: bool,
}

impl Drop for Private {
    fn drop(&mut self) {
        if !self.keep {
            let _ = std::fs::remove_dir_all(&self.dir);
        }
    }
}

/// How the child ended.
enum Ended {
    Exit(i64),
    #[cfg_attr(not(unix), allow(dead_code))]
    Signal(i32),
}

/// Builds PROGRAM (whose NIR is TEXT) into a private directory and runs it
/// as OPTIONS say; the driver's exit status (the module's doc).
pub fn run(program: &nir::Program, text: &str, options: Options, search: &codegen::aot::LinkSearch) -> i32 {
    let started = Instant::now();
    if options.argv.is_empty() {
        emit_error(
            &["NATIVE", "UNSUPPORTED", "aot-run"],
            "a program run as a command runs as a process, which has at least one argument: an empty argument vector cannot be given to it",
        );
        return 1;
    }
    #[cfg(unix)]
    signals::install();
    let watch = parent::Watch::start(options.parent);
    let private = match private_dir() {
        Ok(dir) => Private { dir, keep: options.keep },
        Err(e) => {
            emit_error(&["NATIVE", "IO"], &format!("cannot make the run's private directory: {e}"));
            return 1;
        }
    };
    let destination = private.dir.join(file_name(&options.name));
    if options.keep {
        let _ = std::fs::write(private.dir.join(format!("{}.nir", file_name(&options.name))), text);
    }
    let built = codegen::aot::emit_executable(program, &destination, search, options.startup);
    if let Some(stop) = interruption(&watch) {
        return stop;
    }
    let executable = match built {
        Ok(executable) => executable,
        Err(e) => {
            let code = if codegen::aot::calls_c(program) { "LINK" } else { "AOT" };
            emit_link_error(code, &e);
            if private.keep {
                emit(&tcl_list(&["kept".to_string(), private.dir.to_string_lossy().into_owned()]));
            }
            return 1;
        }
    };
    let build_us = started.elapsed().as_micros();
    emit(&tcl_list(&["executable".to_string(), executable.to_string_lossy().into_owned()]));
    let ended = match child::run(&executable, &options.argv, &options.environment, &watch, || {
        emit(&format!("timing {build_us} {}", started.elapsed().as_micros()));
    }) {
        Ok(ended) => ended,
        Err(child::Error::Arguments(message)) => {
            emit_error(&["NATIVE", "UNSUPPORTED", "aot-run"], &message);
            return 1;
        }
        Err(child::Error::System(message)) => {
            emit_error(&["NATIVE", "IO"], &format!("cannot run {}: {message}", executable.display()));
            return 1;
        }
        Err(child::Error::Interrupted) => {
            return interruption(&watch).unwrap_or(1);
        }
    };
    watch.finish();
    let status = match ended {
        Ended::Exit(code) => {
            emit(&format!("status exit {code}"));
            code as i32
        }
        Ended::Signal(n) => {
            emit(&tcl_list(&["status".to_string(), "signal".to_string(), n.to_string(), signal_name(n)]));
            128 + n
        }
    };
    if private.keep {
        emit(&tcl_list(&["kept".to_string(), private.dir.to_string_lossy().into_owned()]));
    }
    drop(private);
    status
}

/// When a signal came, or the parent ended, before the child was started:
/// the interruption reported and the exit status, so nothing is started.
fn interruption(watch: &parent::Watch) -> Option<i32> {
    #[cfg(unix)]
    if let Some(n) = signals::received() {
        emit(&tcl_list(&["interrupted".to_string(), n.to_string(), signal_name(n)]));
        return Some(128 + n);
    }
    if watch.parent_gone() {
        emit(&tcl_list(&["interrupted".to_string(), "0".to_string(), "parent".to_string()]));
        return Some(1);
    }
    None
}

/// The conventional name of signal N (SIGSEGV), or `SIGN` for one without.
pub fn signal_name(n: i32) -> String {
    #[cfg(unix)]
    {
        let names = [
            (libc::SIGHUP, "SIGHUP"),
            (libc::SIGINT, "SIGINT"),
            (libc::SIGQUIT, "SIGQUIT"),
            (libc::SIGILL, "SIGILL"),
            (libc::SIGTRAP, "SIGTRAP"),
            (libc::SIGABRT, "SIGABRT"),
            (libc::SIGBUS, "SIGBUS"),
            (libc::SIGFPE, "SIGFPE"),
            (libc::SIGKILL, "SIGKILL"),
            (libc::SIGUSR1, "SIGUSR1"),
            (libc::SIGSEGV, "SIGSEGV"),
            (libc::SIGUSR2, "SIGUSR2"),
            (libc::SIGPIPE, "SIGPIPE"),
            (libc::SIGALRM, "SIGALRM"),
            (libc::SIGTERM, "SIGTERM"),
            (libc::SIGXCPU, "SIGXCPU"),
            (libc::SIGXFSZ, "SIGXFSZ"),
            (libc::SIGSYS, "SIGSYS"),
        ];
        if let Some((_, name)) = names.iter().find(|(number, _)| *number == n) {
            return name.to_string();
        }
    }
    format!("SIG{n}")
}

/// The signals this driver receives while a run is under way (Unix).
#[cfg(unix)]
mod signals {
    use std::sync::atomic::{AtomicI32, Ordering};

    /// The running child's process ID, 0 before it is started.
    pub static CHILD: AtomicI32 = AtomicI32::new(0);
    static RECEIVED: AtomicI32 = AtomicI32::new(0);

    extern "C" fn handle(signal: libc::c_int) {
        RECEIVED.store(signal, Ordering::SeqCst);
        if signal == libc::SIGTERM || signal == libc::SIGHUP {
            let child = CHILD.load(Ordering::SeqCst);
            if child > 0 {
                // SAFETY: kill(2) is async-signal-safe.
                unsafe { libc::kill(child, signal) };
            }
        }
    }

    /// The handler for SIGINT, SIGQUIT, SIGTERM and SIGHUP: a handler, not
    /// SIG_IGN, so the child, whose exec(2) resets handlers, starts with
    /// these signals' default actions, as it would from a shell.
    pub fn install() {
        for signal in [libc::SIGINT, libc::SIGQUIT, libc::SIGTERM, libc::SIGHUP] {
            // SAFETY: a zeroed sigaction with a plain handler and an empty
            // mask is a valid argument; the handler only stores atomics and
            // calls kill(2).
            unsafe {
                let mut action: libc::sigaction = std::mem::zeroed();
                action.sa_sigaction = handle as *const () as usize;
                action.sa_flags = libc::SA_RESTART;
                libc::sigemptyset(&mut action.sa_mask);
                libc::sigaction(signal, &action, std::ptr::null_mut());
            }
        }
    }

    /// The last signal received, if any.
    pub fn received() -> Option<i32> {
        match RECEIVED.load(Ordering::SeqCst) {
            0 => None,
            n => Some(n),
        }
    }
}

/// The watch of the process that started this driver: when it ends while a
/// run is under way, the child is ended too.
mod parent {
    use std::sync::Arc;
    use std::sync::atomic::{AtomicBool, Ordering};

    pub struct Watch {
        gone: Arc<AtomicBool>,
        done: Arc<AtomicBool>,
        #[cfg_attr(not(windows), allow(dead_code))]
        pub pid: Option<u32>,
    }

    impl Watch {
        /// On Unix a thread notices this driver being given another parent
        /// (getppid(2): the parent's end reparents it), polling every 100
        /// ms; a PARENT given that is not this driver's parent has ended
        /// already. On Windows the child's wait watches PARENT's process
        /// (child::run).
        pub fn start(parent: Option<u32>) -> Watch {
            let gone = Arc::new(AtomicBool::new(false));
            let done = Arc::new(AtomicBool::new(false));
            #[cfg(unix)]
            {
                // SAFETY: getppid(2) cannot fail.
                let original = unsafe { libc::getppid() };
                if parent.is_some_and(|p| p as libc::pid_t != original) {
                    gone.store(true, Ordering::SeqCst);
                }
                let (g, d) = (gone.clone(), done.clone());
                std::thread::spawn(move || {
                    while !d.load(Ordering::SeqCst) {
                        std::thread::sleep(std::time::Duration::from_millis(100));
                        // SAFETY: as above.
                        if unsafe { libc::getppid() } != original {
                            g.store(true, Ordering::SeqCst);
                            let child = super::signals::CHILD.load(Ordering::SeqCst);
                            if child > 0 {
                                // SAFETY: kill(2) of the child this driver started.
                                unsafe { libc::kill(child, libc::SIGTERM) };
                            }
                            return;
                        }
                    }
                });
            }
            Watch { gone, done, pid: parent }
        }

        pub fn parent_gone(&self) -> bool {
            self.gone.load(Ordering::SeqCst)
        }

        #[cfg_attr(not(windows), allow(dead_code))]
        pub fn mark_gone(&self) {
            self.gone.store(true, Ordering::SeqCst);
        }

        pub fn finish(&self) {
            self.done.store(true, Ordering::SeqCst);
        }
    }
}

/// Starting the child and waiting for it.
mod child {
    use super::Ended;

    pub enum Error {
        /// The argument vector is no Windows process's.
        #[cfg_attr(not(windows), allow(dead_code))]
        Arguments(String),
        /// The operating system refused to start it.
        System(String),
        /// A signal came, or the parent ended, as it was being started.
        #[cfg_attr(not(unix), allow(dead_code))]
        Interrupted,
    }

    #[cfg(unix)]
    pub fn run(
        executable: &std::path::Path,
        argv: &[Vec<u8>],
        environment: &[(String, Option<std::ffi::OsString>)],
        watch: &super::parent::Watch,
        started: impl FnOnce(),
    ) -> Result<Ended, Error> {
        use std::os::unix::ffi::OsStrExt;
        use std::os::unix::process::{CommandExt, ExitStatusExt};
        use std::sync::atomic::Ordering;
        let (first, rest) = argv.split_first().expect("aot-run checks for argument zero");
        let mut command = std::process::Command::new(executable);
        command.arg0(std::ffi::OsStr::from_bytes(first)).args(rest.iter().map(|a| std::ffi::OsStr::from_bytes(a)));
        for (name, value) in environment {
            match value {
                Some(value) => command.env(name, value),
                None => command.env_remove(name),
            };
        }
        if super::signals::received().is_some() || watch.parent_gone() {
            return Err(Error::Interrupted);
        }
        let mut child = command.spawn().map_err(|e| Error::System(e.to_string()))?;
        super::signals::CHILD.store(child.id() as i32, Ordering::SeqCst);
        // A SIGTERM or SIGHUP that came while it was being started, before
        // the handler could forward it, and a parent that ended then.
        if let Some(signal) = super::signals::received().filter(|&s| s == libc::SIGTERM || s == libc::SIGHUP) {
            // SAFETY: kill(2) of the child just started.
            unsafe { libc::kill(child.id() as i32, signal) };
        }
        if watch.parent_gone() {
            // SAFETY: as above.
            unsafe { libc::kill(child.id() as i32, libc::SIGTERM) };
        }
        started();
        let status = child.wait().map_err(|e| Error::System(e.to_string()))?;
        super::signals::CHILD.store(0, Ordering::SeqCst);
        if let Some(code) = status.code() {
            return Ok(Ended::Exit(code as i64));
        }
        Ok(Ended::Signal(status.signal().unwrap_or(0)))
    }

    #[cfg(windows)]
    pub fn run(
        executable: &std::path::Path,
        argv: &[Vec<u8>],
        environment: &[(String, Option<std::ffi::OsString>)],
        watch: &super::parent::Watch,
        started: impl FnOnce(),
    ) -> Result<Ended, Error> {
        // Checked before the environment changes: a refused vector runs
        // nothing.
        crate::launch::command_line(&crate::launch::utf16_arguments(argv).map_err(Error::Arguments)?).map_err(Error::Arguments)?;
        for (name, value) in environment {
            // SAFETY: the driver's only other thread is the parent watch's
            // (none on Windows), and it exits after the run, so nothing else
            // reads its environment.
            unsafe {
                match value {
                    Some(value) => std::env::set_var(name, value),
                    None => std::env::remove_var(name),
                }
            }
        }
        let spawned = crate::launch::spawn(executable, argv).map_err(|e| match e {
            crate::launch::LaunchError::Arguments(m) => Error::Arguments(m),
            crate::launch::LaunchError::System(m) => Error::System(m),
        })?;
        started();
        let code = crate::launch::wait_watching(spawned, watch.pid, || watch.mark_gone()).map_err(|e| match e {
            crate::launch::LaunchError::Arguments(m) => Error::Arguments(m),
            crate::launch::LaunchError::System(m) => Error::System(m),
        })?;
        Ok(Ended::Exit(code as i64))
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::path::Path;

    #[test]
    fn aot_run_file_names_are_plain() {
        assert_eq!(file_name("hello"), "hello");
        assert_eq!(file_name("ünï cödé"), "ünï cödé");
        for bad in ["", ".", "..", "a/b", "a\\b", "c:x", "nul\0"] {
            assert_eq!(file_name(bad), "program", "{bad:?}");
        }
    }

    #[test]
    fn aot_run_child_environment_lines() {
        let changes = parse_environment("unset BOTLISH_NATIVE_LINKER\nset BOTLISH_NATIVE_BIN 2f612062\n").unwrap();
        assert_eq!(changes, vec![
            ("BOTLISH_NATIVE_LINKER".to_string(), None),
            ("BOTLISH_NATIVE_BIN".to_string(), Some("/a b".into())),
        ]);
        for bad in ["unset", "set A", "set A 1", "set A zz", "remove A", "unset A=B", "set A ff"] {
            assert!(parse_environment(bad).is_err(), "{bad:?}");
        }
    }

    #[test]
    fn aot_run_private_directories_are_new_and_private() {
        let a = private_dir().unwrap();
        let b = private_dir().unwrap();
        assert_ne!(a, b);
        #[cfg(unix)]
        {
            use std::os::unix::fs::PermissionsExt;
            assert_eq!(std::fs::metadata(&a).unwrap().permissions().mode() & 0o777, 0o700);
        }
        for dir in [a, b] {
            drop(Private { dir: dir.clone(), keep: false });
            assert!(!dir.exists());
        }
    }

    #[test]
    fn aot_run_signal_names() {
        #[cfg(unix)]
        {
            assert_eq!(signal_name(libc::SIGSEGV), "SIGSEGV");
            assert_eq!(signal_name(libc::SIGTERM), "SIGTERM");
        }
        assert_eq!(signal_name(77), "SIG77");
    }

    #[test]
    fn aot_run_never_runs_a_path_it_did_not_make() {
        // The executable's path is inside the private directory, under the
        // file name given (or `program`): never a name that escapes it.
        let dir = Path::new("/tmp/x");
        for name in ["../../bin/sh", "/bin/sh", "..", "sub/x"] {
            assert_eq!(dir.join(file_name(name)), dir.join("program"));
        }
    }
}
