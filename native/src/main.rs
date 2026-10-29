//! botlish-native: the native backend driver.
//!
//! ```text
//!   botlish-native run FILE.nir          compile (Cranelift JIT) and run
//!   botlish-native bench RUNS FILE.nir   compile once, run RUNS times
//!   botlish-native batch CALLS FILE.nir  time CALLS entries in one region
//!   botlish-native clif FILE.nir         print the Cranelift IR of every function
//!   botlish-native size FILE.nir         compile; print machine code sizes
//!   botlish-native roots FILE.nir        print each function's GC-root report
//!                                        (codegen::roots): NIR/raw/managed
//!                                        register counts, safepoints, root
//!                                        candidates, max simultaneous live
//!                                        roots, and the shadow-slot count
//!                                        they were colored into. Parses and
//!                                        analyzes only -- never compiles.
//!   botlish-native calls FILE.nir        print settled exact-call effects
//!                                        without compiling
//!   botlish-native object OUT FILE.nir   write a relocatable program object
//!   botlish-native executable OUT FILE.nir  link a standalone executable
//!                                        (--startup worker|main-thread: its
//!                                        startup policy, below)
//!                                        (Linux ELF, macOS AArch64 Mach-O,
//!                                        Windows x86-64 PE: OUT.exe for an
//!                                        OUT without an extension;
//!                                        BOTLISH_NATIVE_LINKER: rustc, the
//!                                        default, or stub: codegen/aot.rs)
//!   botlish-native library OUT NAME FILE.nir  write native library NAME's
//!                                        program object (codegen::library,
//!                                        NATIVE-LIBRARY-MILESTONE-1.md): the
//!                                        program's code, descriptor and record
//!                                        with local symbols, and the
//!                                        library's public C functions;
//!                                        native/native.tcl's native::library
//!                                        links it with the runtime
//!   botlish-native check FILE.nir        parse and validate only
//!   botlish-native link-plan FILE.nir    the program's link plan as this
//!                                        host links it (codegen::aot's
//!                                        resolve_link_plan; NATIVE-LINK-
//!                                        PLAN-MILESTONE-1.md): a line per
//!                                        dependency -- library NAME, archive
//!                                        NAME PATH declared|searched WHAT,
//!                                        framework NAME -- or the NATIVE
//!                                        LINK ARCHIVE failure a link would
//!                                        report; nothing is linked
//!   botlish-native system-linker         what the system linker would link
//!                                        with here: `flavor`, `tool` (the C
//!                                        driver or link.exe), `runtime` (the
//!                                        runtime archive and its machine),
//!                                        `libraries` (the archive's system
//!                                        libraries); exit status 1 when the
//!                                        tool or the archive is unusable
//!                                        (codegen/aot.rs)
//!   botlish-native fusion FILE.nir       what coroutine fusion did with each
//!                                        construction site (codegen::fusion,
//!                                        COROUTINE-FUSION-MILESTONE-1.md):
//!                                        one Tcl list per site, `fused` with
//!                                        what was inlined and eliminated, or
//!                                        `kept` with the reason; empty when
//!                                        fusion is off
//!   botlish-native fused FILE.nir        the NIR the program is after fusion
//!                                        (codegen::nirtext), what every other
//!                                        command compiles
//!   botlish-native target TRIPLE         how this driver reads a target
//!                                        triple: architecture, operating
//!                                        system, pointer width, object format,
//!                                        C calling convention, this host's
//!                                        triple, and whether code for it runs
//!                                        here (codegen/target.rs)
//! ```
//!
//! A program built for a target (NIR's `target "NAME" triple="TRIPLE"`) is
//! run (`run`, `bench`, `batch`) or emitted (`object`, `executable`) only on
//! that target's host: anything else is `error {NATIVE TARGET} ...`, before
//! any code is made, however much the two targets share (linux-aarch64 code
//! never runs on macOS arm64). The other commands show this host's view of
//! any program.
//!
//! `run`/`bench`/`batch` accept `--argv ARGS` or `--argv-file PATH` (anywhere
//! on the line; the file holds ARGS, for vectors too large for one command-line
//! argument -- Linux caps a single argument at 128 KiB): the
//! process argument snapshot `argv()` reads (core/process.tcl, ARGV.md), as
//! raw bytes -- ARGS is the comma-separated list of arguments, each written
//! `x` followed by the hexadecimal of its bytes (`x` alone is the empty
//! argument; the empty ARGS is no arguments at all), so invalid UTF-8 and
//! every other byte sequence is expressible. Without it the snapshot is the
//! one synthetic argument `botlish-runner` (runtime/vm.rs's DEFAULT_ARGV),
//! never this driver's own arguments.
//!
//! `--link-dir DIR` (anywhere on the line, repeatable, never empty; main.tcl's
//! `-L DIR`) adds DIR to the system linker's library search path (-LDIR) when a
//! program that calls C (C-FFI.md) is linked, and to the directories a static
//! archive declared without a path is found in; `--framework-dir DIR`
//! (main.tcl's `-F DIR`) adds DIR to Apple's ld's framework search path (-FDIR)
//! on macOS, and is passed to no other linker (NATIVE-LINK-PLAN-MILESTONE-1.md). Such a program -- one with
//! `foreign` functions or `link` libraries -- is never JIT-run: `run` and
//! `bench` link it as an executable (codegen/aot.rs, the same link
//! `executable` makes) into a private directory and run that, in the driver
//! protocol (runtime/aot.rs): its result lines come back through a file, and
//! its standard output and error are this driver's own. `batch` and
//! `--alloc` do not run one.
//!
//! `--startup worker|main-thread` (anywhere on the line, `executable` and
//! `object` only; once, or repeated with the same policy) is the
//! executable's startup policy (MAIN-THREAD-STARTUP-MILESTONE-1.md;
//! runtime::program's `Startup`), recorded in its program record:
//! `worker`, the default, runs the program on a worker thread of its own;
//! `main-thread` on the process's main thread, its stack reserved by the
//! link (512 MiB, LC_MAIN) -- for a macOS AArch64 target only, refused for
//! any other with `error {NATIVE UNSUPPORTED startup} ...` before anything
//! is written. A linked run (`run`/`bench` of a program that calls C) is
//! always the worker's.
//!
//! `--table-hash-key HEX` (anywhere on the line; 32 hexadecimal digits, the
//! two 64-bit key words K0 then K1) fixes the key of the private table hash
//! (HASHABLE-AND-KEYED-HASH.md) for this run instead of the one the runtime
//! draws from the system's random source: test harnesses only
//! (core::hashing::useTableHashKey, which native::RunDriver forwards), so
//! exact keyed hashes can be compared with an independent implementation.
//! Nothing in a program can set or read the key; a standalone executable has
//! no such option and always draws its own.
//!
//! `--result PATH` (anywhere on the line, any command) writes the output
//! lines below to PATH instead of standard output, which `run` then leaves
//! to the program alone: what it writes there (io::print_line, raw
//! write(2)s) is never mixed with, or taken for, a result line. main.tcl
//! runs programs so (native::evalHir's `-output inherit`), with the
//! driver's standard output and error its own.
//!
//! `run`/`bench` accept `--alloc off|summary|sites` (default `off`,
//! byte-identical to no instrumentation): see runtime/metrics.rs. For
//! `bench`, the report reflects the last of RUNS executions (Vm::reset
//! isolates each run's metrics from the previous one).
//!
//! FILE may be - for standard input. Output is UTF-8, one Tcl list per line:
//!
//! ```text
//!   value VALUE                 VALUE: the host runtime value (core/value.tcl)
//!   error ERRORCODE MESSAGE     a Botlish error, or {NATIVE ...} for backend failures
//!   timing COMPILE_US BEST_US RUNS COLLECTIONS    (bench, before the result)
//!   size TOTAL_BYTES {FUNCTION_BYTES...}          (size: per NIR function,
//!                                                  with its generic entry)
//!   alloc REPORT                                  (run/bench, --alloc != off:
//!                                                  runtime/metrics.rs's Tcl dict)
//! ```
//!
//! Native code runs on a worker thread with a large native stack, whose
//! exhaustion the stack guard (runtime/platform/) reports as NATIVE LIMIT
//! STACK and ends the process: on Linux (x86-64, AArch64) and macOS AArch64
//! a signal handler, on Windows x86-64 a vectored exception handler
//! (WINDOWS-X86-64-MILESTONE-4.md).

mod codegen;
mod launch;
use botlish_native::{nir, runtime};

use codegen::{Backend, CompileOptions, CraneliftJit, Site};
use runtime::metrics::{kind_name, AllocMode, SiteStats};
use runtime::show::{tcl_list, tcl_value};
use runtime::value::NO_VALUE;
use runtime::vm::{ProgramInfo, Vm};
use std::io::{Read, Write};
use std::rc::Rc;
use std::sync::{Mutex, OnceLock};
use std::time::Instant;

/// The file `--result PATH` names: where emit writes instead of standard
/// output.
static RESULT: OnceLock<Mutex<std::fs::File>> = OnceLock::new();

fn main() {
    let args: Vec<String> = std::env::args().skip(1).collect();
    let args = match extract_result(&args) {
        Ok(args) => args,
        Err(message) => {
            emit_error(&["NATIVE", "IO"], &message);
            std::process::exit(2);
        }
    };
    let stack_size = std::env::var("BOTLISH_NATIVE_STACK_BYTES")
        .ok().and_then(|text| text.parse::<usize>().ok())
        .filter(|&size| size >= 1 << 20)
        .unwrap_or(1 << 30);
    let worker = std::thread::Builder::new().stack_size(stack_size).spawn(move || cli(&args)).expect("thread");
    let status = match worker.join() {
        Ok(status) => status,
        Err(panic) => {
            let message = panic
                .downcast_ref::<String>()
                .cloned()
                .or_else(|| panic.downcast_ref::<&str>().map(|s| s.to_string()))
                .unwrap_or_else(|| "panic".to_string());
            emit_error(&["NATIVE", "BUG"], &format!("the native backend panicked: {message}"));
            3
        }
    };
    #[cfg(all(windows, target_arch = "x86_64"))]
    if let Some(summary) = runtime::framewalk::windows::summary() {
        eprintln!("{summary}");
    }
    std::process::exit(status);
}

fn emit(line: &str) {
    if let Some(file) = RESULT.get() {
        let mut out = file.lock().unwrap_or_else(|poisoned| poisoned.into_inner());
        out.write_all(line.as_bytes()).unwrap();
        out.write_all(b"\n").unwrap();
        out.flush().unwrap();
        return;
    }
    let mut out = std::io::stdout().lock();
    out.write_all(line.as_bytes()).unwrap();
    out.write_all(b"\n").unwrap();
    out.flush().unwrap();
}

/// Pulls "--result PATH" out of ARGS (it may appear anywhere) and makes
/// PATH, created or truncated, where emit writes: the remaining arguments in
/// order. Err if PATH is missing or cannot be created.
fn extract_result(args: &[String]) -> Result<Vec<String>, String> {
    let mut out = Vec::with_capacity(args.len());
    let mut i = 0;
    while i < args.len() {
        if args[i] == "--result" {
            let path = args.get(i + 1).ok_or("--result needs a file")?;
            let file = std::fs::File::create(path).map_err(|e| format!("{path}: {e}"))?;
            #[cfg(any(all(target_os = "linux", any(target_arch = "x86_64", target_arch = "aarch64")), all(target_os = "macos", target_arch = "aarch64"), all(windows, target_arch = "x86_64", target_env = "msvc")))]
            runtime::platform::set_result_file(&file);
            RESULT.set(Mutex::new(file)).map_err(|_| "--result given twice".to_string())?;
            i += 2;
            continue;
        }
        out.push(args[i].clone());
        i += 1;
    }
    Ok(out)
}

fn emit_error(code: &[&str], message: &str) {
    let code: Vec<String> = code.iter().map(|s| s.to_string()).collect();
    emit(&tcl_list(&["error".to_string(), tcl_list(&code), message.to_string()]));
}

/// A failed link's error line: `NATIVE CODE`, with the system linker's
/// kind of failure after it when it has one (codegen::aot::LinkError):
/// NATIVE LINK TOOLCHAIN, NATIVE AOT RUNTIME, ...
fn emit_link_error(code: &str, error: &codegen::aot::LinkError) {
    match error.detail {
        Some("TOOLCHAIN") => emit_error(&["NATIVE", code, "TOOLCHAIN"], &error.message),
        Some("RUNTIME") => emit_error(&["NATIVE", code, "RUNTIME"], &error.message),
        Some("ARCHIVE") => emit_error(&["NATIVE", code, "ARCHIVE"], &error.message),
        // The startup policy its target does not support
        // (codegen::aot::startup_refusal): refused before the link, whatever
        // the program calls.
        Some("STARTUP") => emit_error(&["NATIVE", "UNSUPPORTED", "startup"], &error.message),
        _ => emit_error(&["NATIVE", code], &error.message),
    }
}

fn read(path: &str) -> Result<String, String> {
    if path == "-" {
        let mut text = String::new();
        std::io::stdin().read_to_string(&mut text).map_err(|e| e.to_string())?;
        return Ok(text);
    }
    std::fs::read_to_string(path).map_err(|e| format!("{path}: {e}"))
}

/// Pulls "--alloc MODE" out of ARGS (it may appear anywhere): the remaining
/// arguments in order, and the mode (Off if absent). None if "--alloc" is
/// given without a valid mode.
fn extract_alloc_mode(args: &[String]) -> Option<(Vec<String>, AllocMode)> {
    let mut mode = AllocMode::Off;
    let mut out = Vec::with_capacity(args.len());
    let mut i = 0;
    while i < args.len() {
        if args[i] == "--alloc" {
            mode = AllocMode::parse(args.get(i + 1)?)?;
            i += 2;
            continue;
        }
        out.push(args[i].clone());
        i += 1;
    }
    Some((out, mode))
}

/// Decodes `--argv`'s value (see the module doc): None if malformed.
fn parse_argv(text: &str) -> Option<Vec<Vec<u8>>> {
    if text.is_empty() {
        return Some(Vec::new());
    }
    text.split(',')
        .map(|word| {
            let hex = word.strip_prefix('x')?;
            if hex.len() % 2 != 0 {
                return None;
            }
            (0..hex.len())
                .step_by(2)
                .map(|i| u8::from_str_radix(hex.get(i..i + 2)?, 16).ok())
                .collect::<Option<Vec<u8>>>()
        })
        .collect()
}

/// Pulls "--argv ARGS" / "--argv-file PATH" out of ARGS (either may appear
/// anywhere): the remaining arguments in order, and the decoded snapshot
/// (None if absent). None if the option is given without a well-formed
/// value.
fn extract_argv(args: &[String]) -> Option<(Vec<String>, Option<Vec<Vec<u8>>>)> {
    let mut snapshot = None;
    let mut out = Vec::with_capacity(args.len());
    let mut i = 0;
    while i < args.len() {
        if args[i] == "--argv" {
            snapshot = Some(parse_argv(args.get(i + 1)?)?);
            i += 2;
            continue;
        }
        if args[i] == "--argv-file" {
            let text = std::fs::read_to_string(args.get(i + 1)?).ok()?;
            snapshot = Some(parse_argv(text.trim_end_matches('\n'))?);
            i += 2;
            continue;
        }
        out.push(args[i].clone());
        i += 1;
    }
    Some((out, snapshot))
}

/// Pulls "--table-hash-key HEX" out of ARGS (anywhere) and fixes the table
/// hash's key: the remaining arguments in order. None if the value is not
/// 32 hexadecimal digits.
fn extract_table_hash_key(args: &[String]) -> Option<Vec<String>> {
    let mut out = Vec::with_capacity(args.len());
    let mut i = 0;
    while i < args.len() {
        if args[i] == "--table-hash-key" {
            let hex = args.get(i + 1)?;
            if hex.len() != 32 || !hex.bytes().all(|b| b.is_ascii_hexdigit()) {
                return None;
            }
            let k0 = u64::from_str_radix(&hex[..16], 16).ok()?;
            let k1 = u64::from_str_radix(&hex[16..], 16).ok()?;
            runtime::ops::set_table_hash_key(k0, k1).ok()?;
            i += 2;
            continue;
        }
        out.push(args[i].clone());
        i += 1;
    }
    Some(out)
}

/// Pulls every "--link-dir DIR" and "--framework-dir DIR" out of ARGS
/// (anywhere): the remaining arguments in order, and the directories. Err if
/// one has no value or an empty one: an empty DIR would be a bare `-L` (or
/// `-F`), which GNU's and Apple's linker drivers read as taking their next
/// argument for the directory, or a bare `/LIBPATH:`, which link.exe refuses
/// (LNK1146).
fn extract_link_dirs(args: &[String]) -> Result<(Vec<String>, codegen::aot::LinkSearch), String> {
    let mut search = codegen::aot::LinkSearch::default();
    let mut out = Vec::with_capacity(args.len());
    let mut i = 0;
    while i < args.len() {
        if args[i] == "--link-dir" || args[i] == "--framework-dir" {
            let option = args[i].as_str();
            let dir = args.get(i + 1).ok_or_else(|| format!("{option} needs a directory"))?;
            if dir.is_empty() {
                return Err(format!("{option} needs a directory (found an empty one)"));
            }
            if option == "--link-dir" {
                search.libraries.push(dir.clone());
            } else {
                search.frameworks.push(dir.clone());
            }
            i += 2;
            continue;
        }
        out.push(args[i].clone());
        i += 1;
    }
    Ok((out, search))
}

/// Pulls every "--startup POLICY" out of ARGS (anywhere): the remaining
/// arguments in order, and the policy (None if absent). Err if one has no
/// value or names no policy, or two name different ones: an explicit
/// choice is never silently replaced.
fn extract_startup(args: &[String]) -> Result<(Vec<String>, Option<runtime::program::Startup>), String> {
    let mut startup = None;
    let mut out = Vec::with_capacity(args.len());
    let mut i = 0;
    while i < args.len() {
        if args[i] == "--startup" {
            let name = args.get(i + 1).ok_or("--startup needs a policy (worker or main-thread)")?;
            let policy = runtime::program::Startup::parse(name)
                .ok_or_else(|| format!("unknown startup policy {name:?} (known: worker main-thread)"))?;
            if startup.is_some_and(|given| given != policy) {
                return Err("--startup given twice with different policies".to_string());
            }
            startup = Some(policy);
            i += 2;
            continue;
        }
        out.push(args[i].clone());
        i += 1;
    }
    Ok((out, startup))
}

fn cli(args: &[String]) -> i32 {
    let usage = || {
        eprintln!("usage: botlish-native run|clif|vcode|size|roots|calls|check|fusion|fused FILE.nir [--alloc off|summary|sites] [--argv ARGS|--argv-file PATH] | bench RUNS FILE.nir [--alloc ...] | batch CALLS FILE.nir | object|executable OUT FILE.nir [--startup worker|main-thread] | library OUT NAME FILE.nir | link-plan FILE.nir | target TRIPLE | system-linker (each also [--result PATH], --link-dir DIR, --framework-dir DIR)");
        2
    };
    let Some(args) = extract_table_hash_key(args) else { return usage() };
    let (args, startup) = match extract_startup(&args) {
        Ok(split) => split,
        Err(message) => {
            eprintln!("botlish-native: {message}");
            return usage();
        }
    };
    let (args, link_dirs) = match extract_link_dirs(&args) {
        Ok(split) => split,
        Err(message) => {
            eprintln!("botlish-native: {message}");
            return usage();
        }
    };
    let Some((args, snapshot)) = extract_argv(&args) else { return usage() };
    let Some((args, alloc_mode)) = extract_alloc_mode(&args) else { return usage() };
    let args = &args[..];
    let (command, rest) = match args.split_first() {
        Some((c, rest)) => (c.as_str(), rest),
        None => return usage(),
    };
    if startup.is_some() && !matches!(command, "executable" | "object") {
        // The policy is an executable's: no other command makes one, and an
        // explicit choice is never ignored.
        eprintln!("botlish-native: --startup is an option of executable and object (an executable's startup policy), not of {command}");
        return usage();
    }
    let startup = startup.unwrap_or(runtime::program::Startup::Worker);
    if command == "system-linker" && rest.is_empty() {
        // What the system linker would link with here (codegen::aot's
        // `system_linker_facts`): inspectable discovery, and the runtime
        // archive's system libraries for the build's comparison with rustc's
        // `--print native-static-libs`.
        let mut failed = false;
        for (key, fact) in codegen::aot::system_linker_facts() {
            match fact {
                Ok(words) => emit(&tcl_list(&[vec![key.to_string()], words].concat())),
                Err(e) => {
                    failed = true;
                    emit(&tcl_list(&[key.to_string(), "error".to_string(), e.message]));
                }
            }
        }
        return i32::from(failed);
    }
    if command == "target" {
        // `target TRIPLE`: how this driver reads a target triple
        // (codegen::target::describe), for the front end's target table.
        return match rest {
            [triple] => match codegen::target::describe(triple) {
                Ok(words) => {
                    emit(&tcl_list(&words));
                    0
                }
                Err(e) => {
                    emit_error(&["NATIVE", "TARGET"], &e);
                    1
                }
            },
            _ => usage(),
        };
    }
    let (runs, file) = match (command, rest) {
        ("bench", [runs, file, ..]) => match runs.parse::<usize>() {
            Ok(n) if n > 0 => (n, file),
            _ => return usage(),
        },
        ("batch", [calls, file, ..]) => match calls.parse::<usize>() {
            Ok(n) if n > 0 => (n, file),
            _ => return usage(),
        },
        ("object" | "executable", [_, file, ..]) => (1, file),
        ("library", [_, _, file, ..]) => (1, file),
        ("run" | "clif" | "vcode" | "size" | "roots" | "calls" | "check" | "fusion" | "fused" | "link-plan", [file, ..]) => (1, file),
        _ => return usage(),
    };
    let text = match read(file) {
        Ok(text) => text,
        Err(e) => {
            emit_error(&["NATIVE", "IO"], &e);
            return 2;
        }
    };
    let mut program = match nir::parse(&text) {
        Ok(p) => p,
        Err(e) => {
            emit_error(&["NATIVE", "INVALID-NIR"], &e.to_string());
            return 0;
        }
    };
    // Coroutine fusion (codegen::fusion, COROUTINE-FUSION-MILESTONE-1.md):
    // every command sees the program code generation compiles.
    let fusion = if codegen::fusion::enabled() { codegen::fusion::fuse(&mut program) } else { Vec::new() };
    // BOTLISH_NATIVE_COROUTINE_FUSION_LOG=FILE appends the `fusion`
    // command's report of every program the driver loads: a census of a
    // whole test run (audit/coroutine-fusion/tools/census.tcl).
    if let Ok(path) = std::env::var("BOTLISH_NATIVE_COROUTINE_FUSION_LOG") {
        if !fusion.is_empty() {
            if let Ok(mut log) = std::fs::OpenOptions::new().create(true).append(true).open(&path) {
                // One write: concurrent drivers append whole reports.
                let _ = log.write_all(format!("{}\n", codegen::fusion::report(&fusion)).as_bytes());
            }
        }
    }
    if matches!(command, "run" | "bench" | "batch" | "object" | "executable" | "library" | "link-plan") {
        // Machine code to run or to keep is the host's own target's only
        // (codegen/target.rs). The diagnostic commands (clif, vcode, size,
        // roots, calls, check) still show this host's view of any program.
        if let Err(message) = codegen::target::check_host(&program) {
            emit_error(&["NATIVE", "TARGET"], &message);
            return 1;
        }
    }
    match command {
        "check" => {
            emit("ok");
            0
        }
        "fusion" => {
            emit(&codegen::fusion::report(&fusion));
            0
        }
        "fused" => {
            emit(codegen::nirtext::program_text(&text, &program).trim_end());
            0
        }
        "roots" => {
            emit(&codegen::roots::report(&program));
            0
        }
        "calls" => {
            emit(&call_effect_report(&program));
            0
        }
        "executable" => {
            // The file the executable is: OUT, or OUT.exe on Windows
            // (codegen::aot::executable_path), as given.
            let named = codegen::aot::executable_path(std::path::Path::new(&rest[0]));
            match codegen::aot::emit_executable(&program, &named, &link_dirs, startup) {
                Ok(_) => emit(&tcl_list(&["executable".to_string(), named.to_string_lossy().into_owned()])),
                Err(e) => {
                    let code = if codegen::aot::calls_c(&program) { "LINK" } else { "AOT" };
                    emit_link_error(code, &e);
                    return 1;
                }
            }
            0
        }
        "link-plan" => {
            // The program's link plan as this host links it
            // (codegen::aot::resolve_link_plan, NATIVE-LINK-PLAN-
            // MILESTONE-1.md): one line per dependency -- `library NAME`,
            // `archive NAME PATH declared WRITTEN` or `archive NAME PATH
            // searched DIR`, `framework NAME` -- or the failure a link
            // would report, before anything is linked.
            match codegen::aot::resolve_link_plan(&program, &link_dirs) {
                Ok(inputs) => {
                    for input in &inputs {
                        let words: Vec<String> = match input {
                            codegen::aot::LinkInput::Library(name) => vec!["library".into(), name.clone()],
                            codegen::aot::LinkInput::Framework(name) => vec!["framework".into(), name.clone()],
                            codegen::aot::LinkInput::Archive { name, path, from } => {
                                let (how, what) = match from {
                                    codegen::aot::ArchiveSource::Declared(written) => ("declared", written.clone()),
                                    codegen::aot::ArchiveSource::Searched(dir) => ("searched", dir.to_string_lossy().into_owned()),
                                };
                                vec!["archive".into(), name.clone(), path.to_string_lossy().into_owned(), how.into(), what]
                            }
                        };
                        emit(&tcl_list(&words));
                    }
                    0
                }
                Err(e) => {
                    emit_link_error("LINK", &e);
                    1
                }
            }
        }
        "library" => {
            let (out, name) = (&rest[0], &rest[1]);
            if !codegen::library::SUPPORTED {
                emit_error(&["NATIVE", "UNSUPPORTED", "library"], "native libraries are made on Linux glibc (x86_64, aarch64) only (NATIVE-LIBRARY-MILESTONE-1.md)");
                return 1;
            }
            if !nir::is_c_identifier(name) {
                emit_error(&["NATIVE", "LIBRARY"], &format!("library name {name:?} is not a C identifier"));
                return 1;
            }
            // A library's code bounds its own recursion: its host runs no
            // stack guard of ours (NATIVE-LIBRARY-MILESTONE-1.md, "Stack
            // safety").
            nir::check_stack_limit(&mut program);
            match codegen::emit_library_object(&program, name) {
                Ok(object) => {
                    if let Err(e) = std::fs::write(out, &object.bytes) {
                        emit_error(&["NATIVE", "IO"], &e.to_string());
                        return 2;
                    }
                    emit(&tcl_list(&["library".to_string(), out.clone(), object.bytes.len().to_string()]));
                    0
                }
                Err(e) => {
                    emit_error(&e.error_code().split(' ').collect::<Vec<_>>(), e.message());
                    1
                }
            }
        }
        "object" => {
            let out = &rest[0];
            if let Some(message) = codegen::aot::startup_refusal(&program, startup) {
                emit_error(&["NATIVE", "UNSUPPORTED", "startup"], &message);
                return 1;
            }
            match codegen::emit_executable_object(&program, startup) {
                Ok(object) => {
                    let bytes = object.bytes;
                    if let Err(e) = std::fs::write(out, &bytes) {
                        emit_error(&["NATIVE", "IO"], &e.to_string());
                        return 2;
                    }
                    emit(&tcl_list(&[
                        "object".to_string(),
                        out.clone(),
                        bytes.len().to_string(),
                        object.pool.entries.len().to_string(),
                    ]));
                    0
                }
                Err(e) => {
                    emit_error(&e.error_code().split(' ').collect::<Vec<_>>(), e.message());
                    0
                }
            }
        }
        "run" | "bench" | "batch" if codegen::aot::calls_c(&program) => {
            run_linked(command, &program, runs, alloc_mode, snapshot, &link_dirs)
        }
        _ => execute(command, &program, runs, alloc_mode, snapshot),
    }
}

/// `run`/`bench` of a program that calls C (C-FFI.md): linked as an
/// executable into a private directory, by the same link `executable`
/// makes, then run there in the driver protocol (runtime/aot.rs), its
/// result lines copied to this driver's. The program's standard input,
/// output and error are this driver's, and its argument vector is the
/// run's snapshot (`--argv`, else the default one). Returns the driver's
/// exit status.
fn run_linked(
    command: &str,
    program: &nir::Program,
    runs: usize,
    alloc_mode: AllocMode,
    snapshot: Option<Vec<Vec<u8>>>,
    link_dirs: &codegen::aot::LinkSearch,
) -> i32 {
    if command == "batch" || alloc_mode.enabled() {
        emit_error(
            &["NATIVE", "UNSUPPORTED", "foreign"],
            "a program that calls C runs as a linked executable: batch timing and allocation reports (--alloc) measure in-process JIT runs only",
        );
        return 0;
    }
    let started = Instant::now();
    let nonce = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .map(|d| d.as_nanos())
        .unwrap_or(0);
    let work = std::env::temp_dir().join(format!("botlish-run-{}-{nonce}", std::process::id()));
    if let Err(e) = std::fs::create_dir(&work) {
        emit_error(&["NATIVE", "IO"], &format!("{}: {e}", work.display()));
        return 2;
    }
    struct Cleanup(std::path::PathBuf);
    impl Drop for Cleanup {
        fn drop(&mut self) {
            // A directory this run created for itself alone.
            let _ = std::fs::remove_dir_all(&self.0);
        }
    }
    let _cleanup = Cleanup(work.clone());
    // Always the worker's startup: a linked run is the driver's way of
    // running a program that calls C, not an executable someone emitted
    // with a policy (MAIN-THREAD-STARTUP-MILESTONE-1.md).
    let executable = match codegen::aot::emit_executable(program, &work.join("program"), link_dirs, runtime::program::Startup::Worker) {
        Ok(executable) => executable,
        Err(e) => {
            emit_link_error("LINK", &e);
            return 0;
        }
    };
    let argv: Vec<Vec<u8>> = snapshot
        .unwrap_or_else(|| runtime::vm::DEFAULT_ARGV.iter().map(|a| a.as_bytes().to_vec()).collect());
    if argv.is_empty() {
        emit_error(
            &["NATIVE", "UNSUPPORTED", "foreign"],
            "a program that calls C runs as a process, which has at least one argument: an empty argument vector cannot be given to it",
        );
        return 0;
    }
    let result = work.join("result");
    let environment = [
        ("BOTLISH_NATIVE_RESULT", Some(result.clone().into_os_string())),
        ("BOTLISH_NATIVE_COMPILE_US", Some(started.elapsed().as_micros().to_string().into())),
        ("BOTLISH_NATIVE_RUNS", (command == "bench").then(|| runs.to_string().into())),
    ];
    let status = match run_linked_executable(&executable, &argv, &environment) {
        Ok(status) => status,
        Err(launch::LaunchError::Arguments(message)) => {
            emit_error(&["NATIVE", "UNSUPPORTED", "foreign"], &message);
            return 0;
        }
        Err(launch::LaunchError::System(message)) => {
            emit_error(&["NATIVE", "IO"], &format!("cannot run the linked program: {message}"));
            return 2;
        }
    };
    let lines = std::fs::read_to_string(&result).unwrap_or_default();
    if lines.is_empty() {
        emit_error(
            &["NATIVE", "BUG"],
            &format!("the linked program reported no result ({status})"),
        );
        return 3;
    }
    for line in lines.lines() {
        emit(line);
    }
    0
}

/// Runs the linked EXECUTABLE with the argument vector ARGV (argument zero
/// first), byte for byte, and ENVIRONMENT's variables set (or removed, for
/// None) in its environment, and waits for it: how it ended, for messages.
/// Its standard input, output and error are this driver's.
#[cfg(unix)]
fn run_linked_executable(
    executable: &std::path::Path,
    argv: &[Vec<u8>],
    environment: &[(&str, Option<std::ffi::OsString>)],
) -> Result<String, launch::LaunchError> {
    use std::os::unix::ffi::OsStrExt;
    use std::os::unix::process::CommandExt;
    let (first, rest) = argv.split_first().expect("run_linked checks for argument zero");
    let mut child = std::process::Command::new(executable);
    child.arg0(std::ffi::OsStr::from_bytes(first)).args(rest.iter().map(|a| std::ffi::OsStr::from_bytes(a)));
    for (name, value) in environment {
        match value {
            Some(value) => child.env(name, value),
            None => child.env_remove(name),
        };
    }
    child.status().map(|status| status.to_string()).map_err(|e| launch::LaunchError::System(e.to_string()))
}

/// A Windows process has no argument vector of its own, only a command
/// line: launch.rs writes the one the program's runtime splits back into
/// ARGV, argument zero included, and starts it with CreateProcessW
/// (ARGV.md, "Windows"). The environment is this driver's, with
/// ENVIRONMENT's variables set or removed first.
#[cfg(windows)]
fn run_linked_executable(
    executable: &std::path::Path,
    argv: &[Vec<u8>],
    environment: &[(&str, Option<std::ffi::OsString>)],
) -> Result<String, launch::LaunchError> {
    // Checked before the environment changes: a refused vector runs nothing.
    launch::command_line(&launch::utf16_arguments(argv).map_err(launch::LaunchError::Arguments)?)
        .map_err(launch::LaunchError::Arguments)?;
    for (name, value) in environment {
        // SAFETY: the driver is single-threaded here -- it compiled and
        // linked the program on this thread and starts no other -- and
        // exits after the run, so nothing else reads its environment.
        unsafe {
            match value {
                Some(value) => std::env::set_var(name, value),
                None => std::env::remove_var(name),
            }
        }
    }
    let code = launch::run(executable, argv)?;
    Ok(format!("exit code: {code} ({code:#010x})"))
}

fn call_effect_report(program: &nir::Program) -> String {
    let mut matrix = [[0_u32; 2]; 2];
    let mut lines = Vec::new();
    for (caller, function) in program.functions.iter().enumerate() {
        for inst in &function.body {
            let (callee, may_error, may_gc) = match inst {
                nir::Inst::Call { func, may_error, may_gc, .. }
                | nir::Inst::CallEnv { func, may_error, may_gc, .. }
                | nir::Inst::CallMulti { func, may_error, may_gc, .. }
                | nir::Inst::CallEnvMulti { func, may_error, may_gc, .. } =>
                    (*func, *may_error, *may_gc),
                _ => continue,
            };
            matrix[may_error as usize][may_gc as usize] += 1;
            lines.push(format!(
                "call caller={} caller_name={:?} callee={} callee_name={:?} may_error={} may_gc={}",
                caller, function.name, callee, program.functions[callee as usize].name, may_error, may_gc,
            ));
        }
    }
    let total: u32 = matrix.iter().flatten().sum();
    lines.insert(0, format!(
        "exact_calls={} false_false={} false_true={} true_false={} true_true={} completion_checks_removed={} call_safepoints_removed={}",
        total,
        matrix[0][0],
        matrix[0][1],
        matrix[1][0],
        matrix[1][1],
        matrix[0][0] + matrix[0][1],
        matrix[0][0] + matrix[1][0],
    ));
    lines.join("\n")
}

pub fn program_info(program: &nir::Program) -> ProgramInfo {
    runtime::program::program_info(program)
}

/// The "sites" entry of Metrics::to_tcl: SITES (codegen::clif's compile-time
/// table, one per allocating instruction) joined with STATS (Vm::alloc's
/// per-run counts, keyed by the same 1-based site id). Ids present in STATS
/// but not SITES (impossible unless the two are mismatched) are skipped
/// rather than panicking, since this is only ever assembled internally
/// right after compiling and running the same program.
fn sites_tcl(sites: &[Site], stats: &std::collections::HashMap<u32, SiteStats>) -> String {
    let mut ids: Vec<&u32> = stats.keys().collect();
    ids.sort();
    let entries: Vec<String> = ids
        .into_iter()
        .filter_map(|&id| {
            let site = sites.get(id as usize - 1)?;
            let s = &stats[&id];
            Some(tcl_list(&[
                "id".to_string(),
                id.to_string(),
                "funcId".to_string(),
                site.func.to_string(),
                "func".to_string(),
                site.func_name.clone(),
                "hirExpr".to_string(),
                site.hir_expr.map(|e| e.to_string()).unwrap_or_default(),
                "operation".to_string(),
                site.operation.to_string(),
                "objectKind".to_string(),
                kind_name(site.object_kind).to_string(),
                "allocations".to_string(),
                s.allocations.to_string(),
                "allocatedBytes".to_string(),
                s.allocated_bytes.to_string(),
            ]))
        })
        .collect();
    tcl_list(&entries)
}

fn execute(command: &str, program: &nir::Program, runs: usize, alloc_mode: AllocMode, snapshot: Option<Vec<Vec<u8>>>) -> i32 {
    let started = Instant::now();
    let mut backend = CraneliftJit;
    let options = CompileOptions {
        clif: command == "clif",
        vcode: command == "vcode",
        alloc_sites: alloc_mode.sites(),
        count_accesses: alloc_mode.enabled(),
    };
    let compiled = match backend.compile(program, &options) {
        Ok(c) => c,
        Err(e) => {
            emit_error(&e.error_code().split(' ').collect::<Vec<_>>(), e.message());
            return 0;
        }
    };
    let compile_us = started.elapsed().as_micros();
    if command == "clif" {
        emit(compiled.clif.as_deref().unwrap_or(""));
        return 0;
    }
    if command == "vcode" {
        emit(compiled.vcode.as_deref().unwrap_or(""));
        return 0;
    }
    if command == "size" {
        let sizes: Vec<String> = compiled.code_sizes.iter().map(|n| n.to_string()).collect();
        let total: u32 = compiled.code_sizes.iter().sum();
        emit(&tcl_list(&["size".to_string(), total.to_string(), tcl_list(&sizes)]));
        return 0;
    }

    let mut vm = Vm::new(Rc::new(program_info(program)), alloc_mode);
    if let Some(snapshot) = snapshot {
        vm.set_argv(snapshot);
    }
    compiled.install_constants(&mut vm);
    vm.set_framemap(compiled.framemap.clone());
    #[cfg(any(all(target_os = "linux", any(target_arch = "x86_64", target_arch = "aarch64")), all(target_os = "macos", target_arch = "aarch64"), all(windows, target_arch = "x86_64", target_env = "msvc")))]
    let _overflow_guard = {
        let stack = runtime::native_stack::NativeStack::current().expect("the thread's stack bounds");
        runtime::platform::OverflowGuard::install(&stack).expect("the stack-overflow guard")
    };

    let mut best = u128::MAX;
    let mut result = NO_VALUE;
    let mut nanos: Vec<u128> = Vec::with_capacity(runs);
    if command == "batch" {
        result = (compiled.entry)(&mut *vm);
        vm.reset();
        let started = Instant::now();
        for _ in 0..runs {
            result = (compiled.entry)(&mut *vm);
            if result == NO_VALUE {
                break;
            }
        }
        let elapsed = started.elapsed().as_nanos();
        emit(&format!("batch {runs} {elapsed} {:.3}", elapsed as f64 / runs as f64));
    } else {
        for run in 0..runs {
            if run > 0 {
                vm.reset();
            }
            let started = Instant::now();
            result = (compiled.entry)(&mut *vm);
            let elapsed = started.elapsed();
            nanos.push(elapsed.as_nanos());
            best = best.min(elapsed.as_micros());
            if result == NO_VALUE {
                break;
            }
        }
        if command == "bench" {
            // Diagnostic-only, additive: per-run nanosecond timings for a
            // best/median distribution alongside the existing best-only
            // "timing" line, whose contract is unchanged.
            let times: Vec<String> = nanos.iter().map(|n| n.to_string()).collect();
            emit(&format!("times {}", times.join(" ")));
            emit(&format!("timing {compile_us} {best} {runs} {}", vm.heap.collections));
        }
    }
    if alloc_mode.enabled() {
        let sites = alloc_mode.sites().then(|| sites_tcl(&compiled.sites, &vm.metrics.sites)).unwrap_or_default();
        emit(&format!("alloc {}", vm.metrics.to_tcl(&sites)));
    }
    if result == NO_VALUE {
        let error = vm.error.take().unwrap_or(runtime::error::RtError::Bug(
            "native code failed without recording an error".to_string(),
        ));
        emit_error(&error.error_code(), &vm.describe_error(&error));
        return 0;
    }
    match tcl_value(result) {
        Ok(value) => emit(&tcl_list(&["value".to_string(), value])),
        Err(error) => emit_error(&error.error_code(), &error.message()),
    }
    0
}
