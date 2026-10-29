//! Standalone executable linking: Linux glibc on x86-64 (both linkers) and
//! AArch64 (the `rustc` linker), ELF; macOS on AArch64 (the `rustc` linker),
//! Mach-O (MACOS-AARCH64-MILESTONE-5.md); Windows on x86-64 with MSVC's
//! toolchain (the `rustc` linker), PE (WINDOWS-X86-64-MILESTONE-1.md).
//! Cranelift emits the program object in the host triple's format; a linker
//! turns it and the runtime into an executable. The executable needs neither
//! Tcl, rustc, the source nor this checkout: only the system's own libraries
//! (on Windows the C runtime is linked statically for it: `crt_args`).
//!
//! Three linkers, chosen by `BOTLISH_NATIVE_LINKER` (SINGLE-EXECUTABLE.md,
//! SINGLE-EXECUTABLE-FFI-MILESTONE-1.md; `chosen_linker`):
//!
//!   * `rustc` (the default): rustc compiles the fixed startup crate
//!     (`STARTUP`) and statically links our runtime
//!     (`libbotlish_native.rlib` beside the driver), through the system
//!     linker.
//!   * `stub`: no toolchain at all. The prebuilt `botlish-aot-stub` (this
//!     runtime and a loader, beside the driver or `BOTLISH_NATIVE_AOT_STUB`)
//!     is copied and the program's image appended to it: the object's
//!     sections laid out and relocated here, by `image` below, into a
//!     `runtime::aotimage::Image` the stub maps at startup. This is how the
//!     single-file compiler (single/) emits executables of programs that
//!     call no C.
//!   * `system`: the host's own C compiler driver (or link.exe) and nothing
//!     of Rust's. It links the program object -- whose `botlish_program`
//!     record is the program's startup data, as for every linker
//!     (runtime::program) -- and the precompiled runtime archive built with
//!     the compiler (native/runtime-archive: `libbotlish_runtime.a` beside
//!     the driver or `BOTLISH_NATIVE_RUNTIME`), whose `main` starts that
//!     record as the rustc startup crate does (`runtime::aot::linked_main`),
//!     with the program's link plan (`system_link_args`). This is how the
//!     single-file compiler links a program that calls C.
//!
//! `auto` is the single-file compiler's choice: the system linker for a
//! program that calls C, the stub linker for any other where the stub runs.
//!
//! All link the same machine code (`emit_object`) and start it the same way
//! (`runtime::aot::run`); `tests/aot-stub-linker.test` and
//! `tests/system-linker.test` run programs linked each way side by side.
//!
//! A program that calls C (C-FFI.md: `foreign` functions, `link` libraries)
//! needs the system linker to resolve its foreign symbols: the `rustc`
//! linker passes the program's link plan to it -- `-lNAME` for every
//! library, in the plan's order, and `-LDIR` for every `--link-dir` search
//! directory -- after the program object, in the platform linker's own
//! terms (`LinkerFlavor`): GNU ld's archive group on Linux, so the order of
//! the declarations never decides a static link; nothing of the kind on
//! macOS, whose ld searches every archive until nothing more resolves
//! (MACOS-AARCH64-MILESTONE-6.md). The `system` linker passes the same plan
//! to the same linker directly. The `stub` linker links no native library
//! and refuses such a program. An ordinary program's link is unchanged.
//!
//! On macOS nothing in the link is Mach-O-specific code of ours: rustc drives
//! the platform linker (the C compiler driver, Apple's ld) with the same
//! arguments, the object's symbols -- a C function's link symbol among them
//! -- carry Mach-O's `_` prefix because the object crate writes it, and the
//! linker signs the executable ad hoc, as it signs every arm64 executable it
//! links.
//!
//! On Windows nothing in the link is PE- or COFF-specific code of ours
//! either: the object is Cranelift's COFF (the `object` crate's, the same
//! bytes for the MSVC and the GNU environment), rustc links it with
//! Microsoft's `link.exe`, which it finds -- with the MSVC libraries and the
//! Windows SDK's import libraries -- by itself, without a Developer Command
//! Prompt, and the C runtime's startup (`mainCRTStartup`) is rustc's. An
//! executable's file name ends in `.exe` (`executable_path`).
use super::{ObjectProgram, emit_executable_object};
use crate::nir::{Link, Program};
use botlish_native::runtime::aotimage::{self, Fixup, Image, Target};
use botlish_native::runtime::program::Startup;
use std::collections::HashMap;
use std::ffi::OsString;
use std::fmt::Write;
use std::path::{Path, PathBuf};
use std::process::Command;

/// Why an executable was not linked: the message, and for the system
/// linker the failure's kind when it is no error of the program's link
/// plan -- `TOOLCHAIN` (no C compiler driver, no linker, not Microsoft's
/// link.exe) or `RUNTIME` (the runtime archive missing, damaged, of another
/// platform, or without the runtime this driver's code calls) -- the third
/// word of its error code
/// (`NATIVE LINK TOOLCHAIN`, `NATIVE AOT RUNTIME`; main.rs).
#[derive(Debug)]
pub struct LinkError {
    pub detail: Option<&'static str>,
    pub message: String,
}

impl From<String> for LinkError {
    fn from(message: String) -> LinkError {
        LinkError { detail: None, message }
    }
}

impl From<&str> for LinkError {
    fn from(message: &str) -> LinkError {
        LinkError { detail: None, message: message.to_string() }
    }
}

fn toolchain_error(message: String) -> LinkError {
    LinkError { detail: Some("TOOLCHAIN"), message }
}

fn runtime_error(message: String) -> LinkError {
    LinkError { detail: Some("RUNTIME"), message }
}

struct WorkDir(PathBuf);

impl WorkDir {
    /// A fresh directory beside DESTINATION (so the finished executable is
    /// published by a rename on the same filesystem).
    fn beside(destination: &Path) -> Result<WorkDir, String> {
        let parent = destination.parent().ok_or("output has no parent directory")?;
        let nonce = std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .map_err(|e| e.to_string())?
            .as_nanos();
        let work = parent.join(format!(".botlish-aot-{}-{nonce}", std::process::id()));
        std::fs::create_dir(&work).map_err(|e| format!("{}: {e}", work.display()))?;
        Ok(WorkDir(work))
    }
}

impl Drop for WorkDir {
    fn drop(&mut self) {
        // This directory was exclusively created by this invocation beside
        // the destination; it never contains user-owned files.
        let _ = std::fs::remove_dir_all(&self.0);
    }
}

/// The `rustc` linker's startup crate: the same text for every program. The
/// program object carries its own startup data -- its descriptor, code table
/// and `botlish_program` record, its startup policy among them
/// (runtime::program, NATIVE-LIBRARY-MILESTONE-1.md, "One startup";
/// MAIN-THREAD-STARTUP-MILESTONE-1.md) -- so the crate only names the record
/// and hands it to `aot::start_linked`, the system linker's startup too
/// (`aot::linked_main`), which reads the policy and builds the Vm on the
/// thread it names, as the stub linker's loader does.
const STARTUP: &str = "\
use botlish_native::runtime::{aot, program};
unsafe extern \"C\" {
    static botlish_program: program::LinkedProgram;
}
fn main() {
    // SAFETY: the record the program object defines, relocated by this link.
    std::process::exit(unsafe { aot::start_linked(&*std::ptr::addr_of!(botlish_program)) });
}
";

/// The stack a main-thread executable's main thread is linked with
/// (MAIN-THREAD-STARTUP-MILESTONE-1.md): 512 MiB, the most Apple's ld
/// gives an arm64 executable (`-stack_size must be <= 512MB on arm64
/// platforms`; MACOS-GRAPHICAL-MAIN-THREAD-CENSUS.md, section 11), in
/// LC_MAIN's `stacksize`. A reservation of address space, which the kernel
/// maps below the main thread with a one-page guard; nothing is allocated
/// at startup. A worker executable's stack is the worker's own
/// (BOTLISH_NATIVE_STACK_BYTES, 1 GiB by default), sized when it runs.
pub const MAIN_THREAD_STACK_BYTES: u64 = 512 << 20;

/// The arguments of a FLAVOR system linker's C compiler driver that an
/// executable started by STARTUP needs (`system_link_args`; the rustc
/// linker passes each as a `-C link-arg=`): for the main-thread policy on
/// Apple's ld, LC_MAIN's stack size, `-Wl,-stack_size,0x20000000`
/// (MAIN_THREAD_STACK_BYTES); nothing for the worker, and nothing for any
/// other linker (`emit_executable` refuses the main-thread policy for every
/// other target first).
fn startup_link_args(flavor: LinkerFlavor, startup: Startup) -> Vec<String> {
    match (flavor, startup) {
        (LinkerFlavor::Apple, Startup::MainThread) => vec![format!("-Wl,-stack_size,{MAIN_THREAD_STACK_BYTES:#x}")],
        _ => Vec::new(),
    }
}

/// Why an executable of PROGRAM cannot have the startup policy STARTUP:
/// None when it can (the worker everywhere, the main thread for a macOS
/// AArch64 target: codegen::target's `main_thread_startup`), else the
/// NATIVE UNSUPPORTED startup refusal, said before anything is linked or
/// written.
pub fn startup_refusal(program: &Program, startup: Startup) -> Option<String> {
    if startup == Startup::Worker {
        return None;
    }
    let triple = match super::target::executable_triple(program) {
        Ok(triple) => triple,
        Err(message) => return Some(message),
    };
    if super::target::main_thread_startup(&triple) {
        return None;
    }
    let target = program.target.as_ref().map_or(HOST_TARGET, |t| t.name.as_str());
    let why = match triple.operating_system {
        target_lexicon::OperatingSystem::Linux => {
            " On Linux, glibc reports no guard below the process's main thread's stack, and the stack-overflow guard runs only on a stack whose guard is confirmed (NATIVE-STACK-OVERFLOW.md)."
        }
        target_lexicon::OperatingSystem::Windows => {
            " On Windows, the main thread's stack is the 1 MiB link.exe reserves unless the link reserves more, which no Botlish link does yet."
        }
        _ => "",
    };
    Some(format!(
        "the startup policy main-thread is supported for macOS AArch64 native executables only, and this executable is for {target}.{why} No other target has had main-thread startup's acceptance (MAIN-THREAD-STARTUP-MILESTONE-1.md); the worker startup (-native-startup worker, the default) is supported on every target"
    ))
}

/// Whether PROGRAM calls C or names a native library (C-FFI.md): it is then
/// linked by the system linker, and run as an executable.
pub fn calls_c(program: &Program) -> bool {
    !program.foreigns.is_empty() || !program.links.is_empty()
}

/// Whether this host links executables: Linux glibc on x86-64 and AArch64
/// (ELF), macOS on AArch64 (Mach-O, MACOS-AARCH64-MILESTONE-5.md), Windows
/// on x86-64 with MSVC's toolchain (PE, WINDOWS-X86-64-MILESTONE-1.md: the
/// driver built for `x86_64-pc-windows-msvc`, never for MinGW's
/// `x86_64-pc-windows-gnu`, which is no native target). On every one the
/// program object is Cranelift's, in the host triple's object format, and
/// the rustc linker links it through the platform's own linker.
const EXECUTABLES: bool = cfg!(any(
    all(target_os = "linux", target_env = "gnu", any(target_arch = "x86_64", target_arch = "aarch64")),
    all(target_os = "macos", target_arch = "aarch64"),
    all(target_os = "windows", target_env = "msvc", target_arch = "x86_64")
));

/// Whether this host links a program that calls C (C-FFI.md): Linux glibc on
/// x86-64 and AArch64, with GNU ld's link plan; macOS on AArch64, with
/// Apple's (`LinkerFlavor`), where the Apple C ABI was validated against real
/// callees compiled by Apple clang (MACOS-AARCH64-MILESTONE-6.md); Windows
/// on x86-64 with MSVC's toolchain, with link.exe's, where the Win64 C ABI
/// was validated against callees compiled by MSVC's cl and ml64
/// (WINDOWS-X86-64-MILESTONE-2.md). Every host that links executables links
/// C calls today; a new one refuses them here, before the linker runs, until
/// its C ABI is validated.
const C_CALLS: bool = cfg!(any(
    all(target_os = "linux", target_env = "gnu", any(target_arch = "x86_64", target_arch = "aarch64")),
    all(target_os = "macos", target_arch = "aarch64"),
    all(target_os = "windows", target_env = "msvc", target_arch = "x86_64")
));

/// The file an executable emitted for DESTINATION is: DESTINATION itself,
/// except on Windows, where an executable's name ends in `.exe` and a
/// DESTINATION without an extension gets it (`fib` -> `fib.exe`), as
/// MinGW's gcc names its output; a name with an extension is kept as given.
/// Default and explicit names follow the same rule (main.tcl names the
/// executable of FILE.bot FILE: FILE.exe on Windows).
pub fn executable_path(destination: &Path) -> PathBuf {
    let extension = std::env::consts::EXE_EXTENSION;
    if extension.is_empty() || destination.extension().is_some() {
        destination.to_path_buf()
    } else {
        destination.with_extension(extension)
    }
}

/// The linker `BOTLISH_NATIVE_LINKER` names (the module doc).
#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub enum Linker {
    Rustc,
    Stub,
    System,
}

/// Whether this host has the stub linker (`link_stub`).
const STUB_LINKER: bool = cfg!(all(target_os = "linux", target_arch = "x86_64"));

/// The linker that links PROGRAM: `BOTLISH_NATIVE_LINKER`'s, rustc's when
/// it is unset or empty. `auto` decides by the program's link plan, never
/// by its source: the system linker for a program that calls C or declares
/// a library (`calls_c`), the stub for any other on a host that has it, the
/// system linker elsewhere. It never chooses rustc.
pub fn chosen_linker(program: &Program) -> Result<Linker, String> {
    match std::env::var("BOTLISH_NATIVE_LINKER") {
        Ok(name) => linker_named(Some(&name), program, STUB_LINKER),
        Err(std::env::VarError::NotPresent) => linker_named(None, program, STUB_LINKER),
        Err(e) => Err(format!("BOTLISH_NATIVE_LINKER: {e}")),
    }
}

/// The linker NAME (BOTLISH_NATIVE_LINKER's value; None when unset) means
/// for PROGRAM on a host that has the stub linker or not (STUB).
fn linker_named(name: Option<&str>, program: &Program, stub: bool) -> Result<Linker, String> {
    match name {
        None | Some("" | "rustc") => Ok(Linker::Rustc),
        Some("stub") => Ok(Linker::Stub),
        Some("system") => Ok(Linker::System),
        Some("auto") => Ok(if calls_c(program) || !stub { Linker::System } else { Linker::Stub }),
        Some(other) => Err(format!("unknown BOTLISH_NATIVE_LINKER {other:?} (known: rustc stub system auto)")),
    }
}

/// The search directories of a link (main.rs's `--link-dir` and
/// `--framework-dir`; main.tcl's -L DIR and -F DIR): where the linker looks
/// for a library it is given by name (-LDIR, /LIBPATH:DIR) and, on macOS,
/// for a framework (-FDIR), in order; and where the driver looks for a
/// static archive declared without a path (`resolve_link_plan`). The two
/// lists are kept apart: a framework directory is never a library one.
#[derive(Clone, Debug, Default, PartialEq, Eq)]
pub struct LinkSearch {
    pub libraries: Vec<String>,
    pub frameworks: Vec<String>,
}

#[cfg(test)]
impl LinkSearch {
    /// Library directories DIRS and no framework directory.
    pub fn libraries(dirs: &[String]) -> LinkSearch {
        LinkSearch { libraries: dirs.to_vec(), frameworks: Vec::new() }
    }
}

/// Links PROGRAM as a standalone executable at `executable_path(DESTINATION)`,
/// started by STARTUP (runtime::program's `Startup`, recorded in its program
/// record), and returns that path (absolute). A policy its target does not
/// support (`startup_refusal`) is refused before anything is written: an
/// executable already at the destination is left as it was.
pub fn emit_executable(program: &Program, destination: &Path, search: &LinkSearch, startup: Startup) -> Result<PathBuf, LinkError> {
    if let Some(message) = startup_refusal(program, startup) {
        return Err(LinkError { detail: Some("STARTUP"), message });
    }
    if !EXECUTABLES {
        return Err("executable emission requires Linux glibc on x86_64 or aarch64, macOS on aarch64, or Windows on x86_64 with the MSVC toolchain".into());
    }
    if calls_c(program) && !C_CALLS {
        return Err(format!(
            "native link failed: this program calls C or declares a C library ({}), and C calls are linked on Linux glibc (x86_64, aarch64), macOS (aarch64) and Windows (x86_64, MSVC) only: on this host executables of programs that call no C are supported, C calls not yet (C-FFI.md)",
            describe_link_plan(program)
        )
        .into());
    }
    let destination = std::path::absolute(executable_path(destination)).map_err(|e| e.to_string())?;
    match chosen_linker(program)? {
        Linker::Rustc => link_rustc(program, &destination, search, startup)?,
        Linker::Stub if calls_c(program) => {
            return Err(format!(
                "native link failed: this program calls C or declares a C library ({}), which only the system linker resolves, and the stub linker (BOTLISH_NATIVE_LINKER=stub) links no native library: link it with the system linker (BOTLISH_NATIVE_LINKER=system or auto, the single executable's: a C compiler driver and the runtime archive) or the rustc linker of a Botlish checkout (BOTLISH_NATIVE_LINKER=rustc; C-FFI.md)",
                describe_link_plan(program)
            )
            .into());
        }
        Linker::Stub => link_stub(program, &destination, startup)?,
        Linker::System => link_system(program, &destination, search, startup)?,
    }
    Ok(destination)
}

/// The C functions and libraries PROGRAM names, for messages: each library
/// as this host's linker is given it (`library_argument`).
fn describe_link_plan(program: &Program) -> String {
    describe_link_plan_for(LINKER, program)
}

fn describe_link_plan_for(flavor: LinkerFlavor, program: &Program) -> String {
    let mut parts = Vec::new();
    if !program.foreigns.is_empty() {
        let names: Vec<&str> = program.foreigns.iter().map(|f| f.symbol.as_str()).collect();
        parts.push(format!("symbols {}", names.join(", ")));
    }
    let libraries: Vec<String> = program
        .links
        .iter()
        .filter_map(|link| match link {
            Link::Library(name) => Some(library_argument(flavor, name)),
            Link::Static { archive: Some(path), .. } => Some(format!("{} (static)", path.written)),
            Link::Static { name, archive: None } => Some(format!("{} (static)", static_archive_name(flavor, name))),
            Link::Framework(_) => None,
        })
        .collect();
    if !libraries.is_empty() {
        parts.push(format!("libraries {}", libraries.join(" ")));
    }
    let frameworks: Vec<&str> = program.links.iter().filter_map(|l| if let Link::Framework(n) = l { Some(n.as_str()) } else { None }).collect();
    if !frameworks.is_empty() {
        parts.push(format!("frameworks {}", frameworks.join(" ")));
    }
    parts.join("; ")
}

/// How a FLAVOR linker is given the library LIBRARY (`extern c library
/// "LIBRARY"`): `-lLIBRARY`, which GNU ld and Apple's ld search the -L
/// directories for (libLIBRARY.so/.a, .dylib/.a); `LIBRARY.lib` for
/// link.exe, which searches its /LIBPATH directories and then the LIB
/// environment's (the SDK's and MSVC's own) for exactly that file -- a
/// static library or a DLL's import library.
fn library_argument(flavor: LinkerFlavor, library: &str) -> String {
    if flavor == LinkerFlavor::Msvc { format!("{library}.lib") } else { format!("-l{library}") }
}

/// The linker's own account of a failed link of a program that calls C:
/// the lines of rustc's STDERR the system linker wrote (its diagnostics,
/// never rustc's echo of the whole command line), else all of it. GNU ld,
/// lld and collect2 on Linux (`undefined reference to`, `cannot find -lNAME`,
/// `ld:` lines, and `ld.bfd:` ones where GCC runs GNU ld by that name, as
/// Ubuntu 26.04's does); Apple's ld and clang on macOS (`Undefined symbols for
/// architecture arm64:` and the `"_SYMBOL", referenced from:` line of each
/// symbol, `ld: library 'NAME' not found`, `ld: warning: ignoring file ...,
/// found architecture ...`, `clang: error: linker command failed`);
/// Microsoft's link.exe on Windows (`error LNK2019: unresolved external
/// symbol`, `fatal error LNK1120: N unresolved externals`, `fatal error
/// LNK1181: cannot open input file 'NAME.lib'`: every `LNKnnnn` error or
/// warning) and LLVM's `lld-link: error:`.
fn linker_diagnostics(stderr: &str) -> String {
    let lines: Vec<&str> = stderr
        .lines()
        .map(str::trim)
        .filter(|line| {
            line.contains("undefined reference")
                || line.contains("cannot find")
                || line.contains("ld:")
                || line.contains("ld.bfd:")
                || line.contains("ld.lld:")
                || line.starts_with("collect2")
                || line.contains("error: linking with")
                || line.contains("Undefined symbols for architecture")
                || line.contains("\", referenced from:")
                || line.contains("linker command failed")
                || line.contains("error LNK")
                || line.contains("warning LNK")
                || line.contains("lld-link:")
        })
        .filter(|line| !line.starts_with("= note: \"") && line.len() < 2000)
        .collect();
    if lines.is_empty() { stderr.to_string() } else { lines.join("\n") }
}

/// What a FLAVOR linker's DIAGNOSTICS mean when they are about the C runtime
/// rather than the program, said once after them. link.exe's unresolved
/// `__imp_NAME` is a reference compiled to be imported from a DLL: a C
/// library compiled for the dynamic C runtime (cl's `/MD`) refers to the
/// runtime's functions so, and a Botlish executable links the static release
/// C runtime and no other (`crt_args`), which defines NAME but no `__imp_NAME`
/// -- link.exe resolves such a reference itself (LNK4217) only when the
/// static runtime's NAME is linked anyway, so a `/MD` library links or not
/// by what else the program happens to pull in (WINDOWS-X86-64-MILESTONE-2.md,
/// "The C runtime"). Nothing for any other failure or linker.
fn link_hint(flavor: LinkerFlavor, diagnostics: &str) -> Option<&'static str> {
    if flavor == LinkerFlavor::Msvc && diagnostics.contains("unresolved external symbol __imp_") {
        return Some(
            "an unresolved __imp_ symbol is a reference compiled to be imported from a DLL: a C library compiled for the dynamic C runtime (cl /MD) refers to the runtime's functions so, and a Botlish executable links the static C runtime (/MT, cl's default) and no other: compile the library with /MT, or, for a function a DLL exports, link the DLL's import library",
        );
    }
    None
}

/// The `rustc` linker: a generated startup crate, compiled and linked
/// against this build's runtime library, started by STARTUP.
fn link_rustc(program: &Program, destination: &Path, search: &LinkSearch, startup: Startup) -> Result<(), LinkError> {
    let driver = std::env::current_exe().map_err(|e| e.to_string())?;
    let release = driver.parent().ok_or("cannot locate native runtime")?;
    let library = release.join("libbotlish_native.rlib");
    if !library.is_file() {
        return Err(format!(
            "runtime library missing: {}; run cargo build --release --manifest-path native/Cargo.toml",
            library.display()
        )
        .into());
    }
    let inputs = resolve_link_plan(program, search)?;
    log_plan(&inputs);
    let work = WorkDir::beside(destination)?;
    let object = emit_executable_object(program, startup).map_err(|e| e.message().to_string())?;
    let object_path = work.0.join("program.o");
    let source_path = work.0.join("startup.rs");
    // With the platform's executable suffix: MinGW's gcc would append .exe
    // to a name without one (link.exe keeps a name as given).
    let executable = work.0.join(format!("executable{}", std::env::consts::EXE_SUFFIX));
    std::fs::write(&object_path, &object.bytes).map_err(|e| e.to_string())?;
    std::fs::write(&source_path, STARTUP).map_err(|e| e.to_string())?;
    // rustc compiles the startup crate for the driver's own target, the one
    // the runtime library was built for, whatever rustc's own host is: a
    // Windows machine commonly has both Rust Windows host toolchains, and a
    // startup crate of the other one would not link against this runtime.
    let output = Command::new(std::env::var_os("RUSTC").unwrap_or_else(|| "rustc".into()))
        .arg("--edition=2024")
        .arg("--crate-name=botlish_program")
        .arg(format!("--target={}", target_lexicon::HOST))
        .args([
            "-C",
            "opt-level=2",
            "-C",
            "force-frame-pointers=yes",
            "-C",
            "relocation-model=pic",
        ])
        .arg("--extern")
        .arg(format!("botlish_native={}", library.display()))
        .arg("-L")
        .arg(format!("dependency={}", release.join("deps").display()))
        .arg("-C")
        .arg(format!("link-arg={}", object_path.display()))
        .args(link_plan_args(program, &inputs, search))
        .args(startup_link_args(LINKER, startup).into_iter().flat_map(|arg| ["-C".to_string(), format!("link-arg={arg}")]))
        .args(crt_args(program))
        .arg(&source_path)
        .arg("-o")
        .arg(&executable)
        .output()
        .map_err(|e| format!("cannot launch rustc to link executable: {e}"))?;
    if !output.status.success() {
        let stderr = String::from_utf8_lossy(&output.stderr);
        if calls_c(program) {
            let diagnostics = linker_diagnostics(&stderr);
            let hint = link_hint(LINKER, &diagnostics).map(|hint| format!("\n{hint}")).unwrap_or_default();
            return Err(format!(
                "native link failed: the system linker could not link this program with the C functions and libraries it declares ({}):\n{}{}",
                describe_link_plan(program),
                diagnostics,
                hint
            )
            .into());
        }
        return Err(format!("executable link failed ({}):\n{}", output.status, stderr).into());
    }
    // Publish only a successfully linked file, on the same filesystem. A
    // failed build leaves any previous executable intact.
    std::fs::rename(&executable, &destination).map_err(|e| format!("{}: {e}", destination.display()))?;
    Ok(())
}

/// The system linker a link plan is written for: the platform's, which
/// rustc drives through the C compiler driver (`cc`) on Unix and directly on
/// Windows.
#[derive(Clone, Copy, PartialEq, Eq, Debug)]
enum LinkerFlavor {
    /// GNU ld, gold or lld through gcc or clang: Linux.
    Gnu,
    /// Apple's ld through Apple clang: macOS.
    Apple,
    /// Microsoft's link.exe (or LLVM's lld-link in its place): Windows with
    /// the MSVC toolchain.
    Msvc,
}

/// This host's linker flavor.
const LINKER: LinkerFlavor = if cfg!(target_vendor = "apple") {
    LinkerFlavor::Apple
} else if cfg!(target_env = "msvc") {
    LinkerFlavor::Msvc
} else {
    LinkerFlavor::Gnu
};

/// The Microsoft C and C++ runtime libraries a Windows executable never
/// links: every one but the static release runtime it does link (`libcmt`,
/// `libvcruntime`, `libucrt`; `libcpmt` for C++) -- the dynamic runtimes
/// (`/MD`, `/MDd`: the import libraries of `VCRUNTIME140.dll`, the UCRT's
/// `ucrtbase.dll` and `MSVCP140.dll`) and the static debug one (`/MTd`).
const OTHER_MSVC_RUNTIMES: [&str; 12] = [
    "msvcrt.lib",
    "msvcrtd.lib",
    "vcruntime.lib",
    "vcruntimed.lib",
    "ucrt.lib",
    "ucrtd.lib",
    "libcmtd.lib",
    "libvcruntimed.lib",
    "libucrtd.lib",
    "msvcprt.lib",
    "msvcprtd.lib",
    "libcpmtd.lib",
];

/// rustc's arguments choosing PROGRAM's C runtime. On Windows (MSVC) every
/// executable links the static release C runtime (`+crt-static`: libcmt,
/// libvcruntime and the static UCRT), whether it calls C or not
/// (WINDOWS-X86-64-MILESTONE-2.md, "The C runtime"):
///
///   * it imports only the system's own DLLs -- kernel32 and the API sets
///     every Windows has -- and never `VCRUNTIME140.dll`, the Visual C++
///     redistributable's, which rustc's default dynamic runtime (`/MD`)
///     needs: a program that writes to the console through kernel32 runs on
///     a Windows without Visual Studio;
///   * one executable holds one C runtime. A C library brings the runtime it
///     was compiled for as default-library directives (`/DEFAULTLIB:MSVCRT`
///     for `/MD`, `LIBCMT` for `/MT`), and link.exe would otherwise link
///     both, warn (LNK4098) and give the library a second heap, a second
///     errno and a second set of stdio streams. So every other runtime's
///     library is excluded (`/NODEFAULTLIB:`, `OTHER_MSVC_RUNTIMES`): a
///     static library compiled with `/MT` (cl's default) shares the
///     executable's runtime; one compiled with `/MD` that calls the runtime
///     refers to it through `__imp_` imports, which link.exe resolves
///     against the static runtime only for a function something else
///     already linked (LNK4217), and otherwise fails to link (LNK2019,
///     NATIVE LINK, with `link_hint`'s explanation) -- never silently
///     linked with a second runtime. A DLL keeps the runtime it was linked
///     with, behind its own exports, as every Windows DLL does: one built
///     with `/MD` needs the Visual C++ redistributable where it runs, the
///     executable still does not.
///
/// Nothing elsewhere: Linux and macOS executables use the system's C
/// library as they always have.
fn crt_args(program: &Program) -> Vec<String> {
    crt_args_for(LINKER, program)
}

fn crt_args_for(flavor: LinkerFlavor, _program: &Program) -> Vec<String> {
    if flavor != LinkerFlavor::Msvc {
        return Vec::new();
    }
    let mut args = vec!["-C".to_string(), "target-feature=+crt-static".to_string()];
    for library in OTHER_MSVC_RUNTIMES {
        args.extend(["-C".to_string(), format!("link-arg=/NODEFAULTLIB:{library}")]);
    }
    args
}

/// rustc's arguments passing PROGRAM's resolved link plan INPUTS to this
/// host's system linker (`link_plan_args_for`).
fn link_plan_args(program: &Program, inputs: &[LinkInput], search: &LinkSearch) -> Vec<String> {
    link_plan_args_for(LINKER, program, inputs, search)
}

/// rustc's arguments passing PROGRAM's resolved link plan INPUTS
/// (`resolve_link_plan`) to a FLAVOR system linker: the library search
/// directories of SEARCH (`-LDIR`) and, for Apple's ld, its framework
/// directories (`-FDIR`), then every library and archive in the plan's
/// order -- a library by name, `-lNAME`, a static archive by its absolute
/// path, which the linker takes as it is, never searching -- for GNU ld
/// inside one linker group, for Apple's ld as they are, followed by every
/// framework, `-framework NAME`; for link.exe in its own spelling,
/// `/LIBPATH:DIR`, `NAME.lib` and the archive's path, and no group:
/// link.exe searches every library until nothing more resolves, in any
/// order. Nothing for a program that names none. Every directory and
/// archive is one argument, whatever it holds (a space, a leading `-`
/// inside an absolute path), and no name is anything but a name
/// (nir::is_link_name): nothing of the plan can become a linker option.
///
/// The group is GNU ld's (and gold's) way of resolving archives whatever
/// their order: they search an archive only for what is undefined when they
/// reach it, so without the group an archive declared before the archive
/// that needs it would leave its symbols undefined. Apple's ld needs none --
/// it keeps searching every static library while anything it could define
/// is undefined ("there is no need to specify a static library multiple
/// times", ld(1)) -- and rejects `--start-group` as an unknown option, so
/// its plan is the bare list (c-ffi.test's cf-link-order shows the order
/// does not matter there either).
///
/// A program that calls C is also linked with the C compiler driver's
/// default libraries (`-C default-linker-libraries=yes`: rustc passes no
/// `-nodefaultlibs`), which the driver appends after every argument, so the
/// libraries are followed by what a C program's link has after its own:
///
///   * GNU: libc, its as-needed dynamic loader and libgcc. rustc's own
///     system libraries come before its link arguments, and GNU ld drops an
///     as-needed library nothing has referenced yet: a static archive
///     needing a symbol only the loader defines (AArch64 glibc's
///     `__stack_chk_guard`, which BoringSSL's stack protector reads) or a
///     libgcc helper would otherwise fail to link.
///   * Apple: libSystem and clang's compiler runtime (`libclang_rt.osx.a`),
///     which rustc's `-nodefaultlibs` link leaves out, so C compiled by
///     clang finds the runtime helpers it may call as in a C program's
///     link. No test can see the runtime missing today: the one helper the
///     tests' C calls, `__isPlatformVersionAtLeast` (`__builtin_available`,
///     c-ffi.test's cf-availability-check), Rust's standard library defines
///     too, and it comes first. `ffi_link_plan_apple_has_no_gnu_flags`
///     pins the argument.
fn link_plan_args_for(flavor: LinkerFlavor, program: &Program, inputs: &[LinkInput], search: &LinkSearch) -> Vec<String> {
    let mut args = Vec::new();
    if !calls_c(program) {
        return args;
    }
    args.extend(["-C".to_string(), "default-linker-libraries=yes".to_string()]);
    let mut arg = |text: String| args.extend(["-C".to_string(), format!("link-arg={text}")]);
    let library = |input: &LinkInput| match input {
        LinkInput::Library(name) => Some(library_argument(flavor, name)),
        LinkInput::Archive { path, .. } => Some(path.to_string_lossy().into_owned()),
        LinkInput::Framework(_) => None,
    };
    if flavor == LinkerFlavor::Msvc {
        for dir in &search.libraries {
            arg(format!("/LIBPATH:{dir}"));
        }
        for text in inputs.iter().filter_map(library) {
            arg(text);
        }
        return args;
    }
    for dir in &search.libraries {
        arg(format!("-L{dir}"));
    }
    if flavor == LinkerFlavor::Apple {
        for dir in &search.frameworks {
            arg(format!("-F{dir}"));
        }
    }
    let libraries: Vec<String> = inputs.iter().filter_map(library).collect();
    if !libraries.is_empty() {
        let group = flavor == LinkerFlavor::Gnu;
        if group {
            arg("-Wl,--start-group".to_string());
        }
        for text in libraries {
            arg(text);
        }
        if group {
            arg("-Wl,--end-group".to_string());
        }
    }
    for input in inputs {
        if let LinkInput::Framework(name) = input {
            arg("-framework".to_string());
            arg(name.clone());
        }
    }
    args
}

// ------------------------------------------------------- resolving the plan

/// One input of a resolved link plan (`resolve_link_plan`), in the plan's
/// order: what the linker is given for one native dependency.
#[derive(Clone, Debug, PartialEq, Eq)]
pub enum LinkInput {
    /// A library the linker finds, shared or static: -lNAME (NAME.lib).
    Library(String),
    /// A static archive the driver found and checked (`check_static_archive`):
    /// its file, absolute, which the linker is given as it is.
    Archive { name: String, path: PathBuf, from: ArchiveSource },
    /// An Apple framework: -framework NAME.
    Framework(String),
}

/// Where a static archive of the resolved plan came from.
#[derive(Clone, Debug, PartialEq, Eq)]
pub enum ArchiveSource {
    /// `static at "WRITTEN"`: the file the program names.
    Declared(String),
    /// `static`: the first `static_archive_name` file of the library
    /// search directories, found in this one.
    Searched(PathBuf),
}

/// A failure of the link plan's own inputs (a declared static archive that
/// is missing, of another format or architecture, or no static archive at
/// all; a framework where no linker has one): `NATIVE LINK ARCHIVE`, found
/// before any linker runs (main.rs's emit_link_error).
fn archive_error(message: String) -> LinkError {
    LinkError { detail: Some("ARCHIVE"), message }
}

/// The file name a FLAVOR linker's static archive of library NAME has:
/// `libNAME.a` (GNU ld's and Apple's ld's archive for -lNAME), `NAME.lib`
/// (link.exe's, a name it shares with an import library: the members tell
/// them apart, `archive_facts`).
fn static_archive_name(flavor: LinkerFlavor, name: &str) -> String {
    if flavor == LinkerFlavor::Msvc { format!("{name}.lib") } else { format!("lib{name}.a") }
}

/// The shared libraries a FLAVOR linker would link for -lNAME instead of a
/// static archive, by file name in a search directory: what a missing static
/// archive's message names when one is there (a static declaration never
/// links one).
fn shared_library_names(flavor: LinkerFlavor, name: &str) -> Vec<String> {
    match flavor {
        LinkerFlavor::Gnu => vec![format!("lib{name}.so")],
        LinkerFlavor::Apple => vec![format!("lib{name}.dylib"), format!("lib{name}.tbd")],
        LinkerFlavor::Msvc => vec![format!("{name}.dll")],
    }
}

/// The object format and architecture a FLAVOR host links, as
/// `archive_facts` names a member's (HOST_MACHINE for this host).
fn flavor_machine(flavor: LinkerFlavor) -> &'static str {
    if flavor == LINKER {
        return HOST_MACHINE;
    }
    match flavor {
        LinkerFlavor::Gnu => "ELF x86-64",
        LinkerFlavor::Apple => "Mach-O arm64",
        LinkerFlavor::Msvc => "COFF x86-64",
    }
}

/// PROGRAM's link plan resolved for this host's linker
/// (NATIVE-LINK-PLAN-MILESTONE-1.md), before anything is linked:
///
///   * a library is the linker's to find (-lNAME, NAME.lib), as ever;
///   * a static library declared at a path (`static at PATH`) is that file:
///     PATH joined to the program's application root (the BASE the front end
///     recorded) unless it is absolute -- never the working directory, never
///     the compiler's own files -- checked by `check_static_archive`;
///   * a static library declared without a path (`static`) is the first
///     `static_archive_name` file in the library search directories, SEARCH's
///     (-L) first, then the toolchain's own (`default_library_dirs`), checked
///     the same way: never a shared library of that name, whichever comes
///     first, and no fallback to one when no archive is there;
///   * a framework is Apple's ld's (-framework NAME), and no other linker's.
///
/// A failure is the plan's (`archive_error`): nothing is linked, and no
/// other file is tried in the failing one's place.
pub fn resolve_link_plan(program: &Program, search: &LinkSearch) -> Result<Vec<LinkInput>, LinkError> {
    resolve_link_plan_with(LINKER, program, search, &mut || default_library_dirs(LINKER))
}

/// `resolve_link_plan` for a FLAVOR linker, whose default library
/// directories DEFAULTS gives (asked once, and only when a static library is
/// in none of SEARCH's).
fn resolve_link_plan_with(
    flavor: LinkerFlavor,
    program: &Program,
    search: &LinkSearch,
    defaults: &mut dyn FnMut() -> Vec<PathBuf>,
) -> Result<Vec<LinkInput>, LinkError> {
    let mut inputs = Vec::with_capacity(program.links.len());
    let mut default_dirs: Option<Vec<PathBuf>> = None;
    let machine = flavor_machine(flavor);
    for link in &program.links {
        match link {
            Link::Library(name) => inputs.push(LinkInput::Library(name.clone())),
            Link::Framework(name) => {
                if flavor != LinkerFlavor::Apple {
                    return Err(archive_error(format!(
                        "native link failed: framework {name:?} (`extern c framework`) is an Apple framework, which only macOS's linker links, and this program is linked for {HOST_TARGET}: a framework is never mapped to a library or linked for another operating system"
                    )));
                }
                inputs.push(LinkInput::Framework(name.clone()));
            }
            Link::Static { name, archive: Some(declared) } => {
                let written = Path::new(&declared.written);
                let path = if written.is_absolute() {
                    written.to_path_buf()
                } else if declared.base.is_empty() || !Path::new(&declared.base).is_absolute() {
                    return Err(archive_error(format!(
                        "native link failed: library {name:?} is declared static at {:?}, a path relative to the program's application root, and this program has none (it was compiled from text rather than from a file, or the declaration is a standard-library module's, which never names an application's file): name the archive by an absolute path, or compile the program from its file",
                        declared.written
                    )));
                } else {
                    Path::new(&declared.base).join(written)
                };
                let how = format!("declared at {:?}, relative to the application root {}", declared.written, declared.base);
                let how = if written.is_absolute() { format!("declared at {:?}", declared.written) } else { how };
                check_static_archive(flavor, machine, name, &path, &how)?;
                inputs.push(LinkInput::Archive { name: name.clone(), path, from: ArchiveSource::Declared(declared.written.clone()) });
            }
            Link::Static { name, archive: None } => {
                let file = static_archive_name(flavor, name);
                let mut dirs: Vec<PathBuf> = search.libraries.iter().map(|d| std::path::absolute(d).unwrap_or_else(|_| PathBuf::from(d))).collect();
                let mut found = dirs.iter().find(|d| d.join(&file).is_file()).cloned();
                if found.is_none() {
                    let more = default_dirs.get_or_insert_with(|| defaults());
                    for dir in more.iter() {
                        if !dirs.contains(dir) {
                            dirs.push(dir.clone());
                        }
                    }
                    found = dirs.iter().find(|d| d.join(&file).is_file()).cloned();
                }
                let Some(dir) = found else {
                    let shared: Vec<String> = dirs
                        .iter()
                        .flat_map(|d| shared_library_names(flavor, name).into_iter().map(move |f| d.join(f)))
                        .filter(|p| p.exists())
                        .map(|p| p.display().to_string())
                        .collect();
                    let searched: Vec<String> = dirs.iter().map(|d| d.display().to_string()).collect();
                    let shared_note = if shared.is_empty() {
                        String::new()
                    } else {
                        format!(" -- {} is a shared library of that name, which a static declaration never links", shared.join(", "))
                    };
                    return Err(archive_error(format!(
                        "native link failed: library {name:?} is declared static, and no static archive {file} is in the library search directories ({}){shared_note}: add the archive's directory (main.tcl -L DIR), or name its file (`extern c library {name:?} static at \"PATH\"`)",
                        if searched.is_empty() { "none".to_string() } else { searched.join(", ") }
                    )));
                };
                let path = dir.join(&file);
                check_static_archive(flavor, machine, name, &path, &format!("found in {}", dir.display()))?;
                inputs.push(LinkInput::Archive { name: name.clone(), path, from: ArchiveSource::Searched(dir) });
            }
        }
    }
    Ok(inputs)
}

/// Checks that PATH (HOW: where it came from, for messages) is a static
/// archive the FLAVOR linker links into an executable for MACHINE, library
/// NAME's: a regular, readable file, an `ar` archive (never a shared library,
/// a text stub, a linker script or a thin archive), every object member of
/// MACHINE's format and architecture (a Mach-O universal file's MACHINE
/// slice, on macOS), and no DLL import member -- a Windows import library is
/// a `.lib` too, and links the executable to a DLL, which a static
/// declaration never does.
fn check_static_archive(flavor: LinkerFlavor, machine: &str, name: &str, path: &Path, how: &str) -> Result<(), LinkError> {
    let what = format!("the static archive {} of library {name:?} ({how})", path.display());
    let metadata = match std::fs::metadata(path) {
        Ok(m) => m,
        Err(e) if e.kind() == std::io::ErrorKind::NotFound => {
            return Err(archive_error(format!("native link failed: {what} does not exist")));
        }
        Err(e) => return Err(archive_error(format!("native link failed: {what} cannot be read: {e}"))),
    };
    if !metadata.is_file() {
        return Err(archive_error(format!("native link failed: {what} is not a file")));
    }
    let facts = archive_facts(path, flavor).map_err(|why| archive_error(format!("native link failed: {what} is no static archive: {why}")))?;
    if let Some(other) = facts.machines.iter().find(|m| m.as_str() != machine) {
        return Err(archive_error(format!(
            "native link failed: {what} holds object code for {other}, and this program is linked for {HOST_TARGET} ({machine}): an archive of another architecture or object format never links"
        )));
    }
    if facts.machines.is_empty() {
        return Err(archive_error(format!("native link failed: {what} is no static archive: it holds no object file")));
    }
    if facts.imports > 0 {
        return Err(archive_error(format!(
            "native link failed: {what} is an import library: {} of its members import functions from a DLL, so linking it makes the executable load that DLL at run time, which a static declaration never does: link the library's static build (a .lib of object files, cl /MT), or declare the library without `static`",
            facts.imports
        )));
    }
    Ok(())
}

/// What a static archive holds, as linking it needs to know: the distinct
/// object formats and architectures of its object members (`archive_machine`'s
/// names), in first-seen order, and how many of its members import from a
/// DLL (Microsoft's short import members, and COFF objects with `.idata$`
/// sections: an import library's, long form).
#[derive(Debug, Default, PartialEq, Eq)]
struct ArchiveFacts {
    machines: Vec<String>,
    imports: usize,
}

/// The facts of the static archive at PATH for a FLAVOR linker: every
/// member read, its symbol and name tables skipped, LLVM bitcode or any
/// other non-object member ignored. A Mach-O universal ("fat") file is read
/// at its slice for the host's architecture when FLAVOR is Apple's (Apple's
/// ld picks that slice). Why the file is no static archive otherwise: a
/// shared library, a text-based stub, a GNU linker script, a thin archive.
fn archive_facts(path: &Path, flavor: LinkerFlavor) -> Result<ArchiveFacts, String> {
    let bytes = std::fs::read(path).map_err(|e| e.to_string())?;
    let be32 = |b: &[u8], i: usize| b.get(i..i + 4).map(|x| u32::from_be_bytes(x.try_into().unwrap()));
    let le32 = |b: &[u8], i: usize| b.get(i..i + 4).map(|x| u32::from_le_bytes(x.try_into().unwrap()));
    let le16 = |b: &[u8], i: usize| b.get(i..i + 2).map(|x| u16::from_le_bytes(x.try_into().unwrap()));
    let mut archive: &[u8] = &bytes;
    if matches!(be32(&bytes, 0), Some(0xcafe_babe | 0xcafe_babf)) {
        if flavor != LinkerFlavor::Apple {
            return Err("it is a Mach-O universal file, which only Apple's linker reads".to_string());
        }
        let wide = be32(&bytes, 0) == Some(0xcafe_babf);
        let count = be32(&bytes, 4).ok_or("damaged universal file")? as usize;
        let entry = if wide { 32 } else { 20 };
        let mut slices = Vec::new();
        for i in 0..count.min(64) {
            let at = 8 + i * entry;
            let cpu = be32(&bytes, at).ok_or("damaged universal file")?;
            let (offset, size) = if wide {
                let o = bytes.get(at + 8..at + 16).ok_or("damaged universal file")?;
                let n = bytes.get(at + 16..at + 24).ok_or("damaged universal file")?;
                (u64::from_be_bytes(o.try_into().unwrap()) as usize, u64::from_be_bytes(n.try_into().unwrap()) as usize)
            } else {
                (be32(&bytes, at + 8).ok_or("damaged universal file")? as usize, be32(&bytes, at + 12).ok_or("damaged universal file")? as usize)
            };
            slices.push((cpu, offset, size));
        }
        let arm64 = slices.iter().find(|(cpu, _, _)| *cpu == 0x0100_000c);
        let Some(&(_, offset, size)) = arm64 else {
            let cpus: Vec<String> = slices.iter().map(|(cpu, _, _)| format!("{cpu:#x}")).collect();
            return Err(format!("it is a Mach-O universal file without an arm64 slice (cpu types {})", cpus.join(", ")));
        };
        archive = bytes.get(offset..offset + size).ok_or("damaged universal file (a slice past its end)")?;
    }
    if !archive.starts_with(b"!<arch>\n") {
        let head = &archive[..archive.len().min(64)];
        let text = String::from_utf8_lossy(head);
        let why = if archive.starts_with(b"!<thin>\n") {
            "it is a GNU thin archive, whose members are other files: make a regular archive (ar rcs)".to_string()
        } else if head.starts_with(b"\x7fELF") && le16(head, 16) == Some(3) {
            "it is an ELF shared library".to_string()
        } else if head.starts_with(b"\x7fELF") {
            "it is an ELF file, not an archive of objects".to_string()
        } else if le32(head, 0) == Some(0xfeed_facf) && le32(head, 12) == Some(6) {
            "it is a Mach-O dynamic library".to_string()
        } else if le32(head, 0) == Some(0xfeed_facf) {
            "it is a Mach-O file, not an archive of objects".to_string()
        } else if text.starts_with("--- !tapi-tbd") || text.starts_with("--- !tapi") {
            "it is a text-based stub (.tbd) of a dynamic library".to_string()
        } else if ["GROUP", "INPUT", "/*", "OUTPUT_FORMAT"].iter().any(|w| text.trim_start().starts_with(w)) {
            "it is a GNU linker script".to_string()
        } else if head.starts_with(b"MZ") {
            "it is a Windows executable or DLL".to_string()
        } else {
            "no !<arch> header".to_string()
        };
        return Err(why);
    }
    let mut facts = ArchiveFacts::default();
    let length = archive.len();
    let mut at = 8usize;
    while at + 60 <= length {
        let header = &archive[at..at + 60];
        if &header[58..60] != b"`\n" {
            return Err("damaged static library (bad member header)".to_string());
        }
        let name = String::from_utf8_lossy(&header[..16]).trim_end().to_string();
        let size: usize = String::from_utf8_lossy(&header[48..58])
            .trim()
            .parse()
            .map_err(|_| "damaged static library (bad member size)".to_string())?;
        let mut data_at = at + 60;
        let mut data_size = size;
        if let Some(n) = name.strip_prefix("#1/").and_then(|n| n.parse::<usize>().ok()) {
            data_at += n;
            data_size = data_size.saturating_sub(n);
        }
        if data_at + data_size > length {
            return Err("damaged static library (a member past its end)".to_string());
        }
        let data = &archive[data_at..data_at + data_size];
        let special = name == "/" || name == "//" || name.starts_with("/SYM64/") || name.starts_with("__.SYMDEF");
        if !special && data.len() >= 20 {
            let machine = if data.starts_with(b"\x7fELF") {
                Some(match (data[4], le16(data, 18).unwrap_or(0)) {
                    (2, 62) => "ELF x86-64".to_string(),
                    (2, 183) => "ELF AArch64".to_string(),
                    (class, machine) => format!("ELF (class {class}, machine {machine})"),
                })
            } else if le32(data, 0) == Some(0xfeed_facf) {
                Some(match le32(data, 4).unwrap_or(0) {
                    0x0100_000c => "Mach-O arm64".to_string(),
                    0x0100_0007 => "Mach-O x86-64".to_string(),
                    cpu => format!("Mach-O (cpu type {cpu:#x})"),
                })
            } else if le16(data, 0) == Some(0) && le16(data, 2) == Some(0xffff) {
                facts.imports += 1;
                None
            } else if let Some(m @ (0x8664 | 0xaa64 | 0x14c)) = le16(data, 0) {
                let sections = le16(data, 2).unwrap_or(0) as usize;
                let optional = le16(data, 16).unwrap_or(0) as usize;
                let imports = (0..sections.min(4096)).any(|i| {
                    let h = 20 + optional + 40 * i;
                    data.get(h..h + 7) == Some(b".idata$".as_slice())
                });
                if imports {
                    facts.imports += 1;
                }
                Some(match m {
                    0x8664 => "COFF x86-64".to_string(),
                    0xaa64 => "COFF AArch64".to_string(),
                    _ => "COFF x86".to_string(),
                })
            } else {
                None
            };
            if let Some(machine) = machine {
                if !facts.machines.contains(&machine) {
                    facts.machines.push(machine);
                }
            }
        }
        at = (at + 60 + size).next_multiple_of(2);
    }
    Ok(facts)
}

/// The directories a FLAVOR linker searches for a library after the -L
/// ones, where a static archive declared without a path is looked for when
/// it is in none of those (`resolve_link_plan`), existing ones only, in the
/// linker's order:
///
///   * GNU: the C compiler driver's (`-print-search-dirs`: the -L
///     directories gcc and clang pass ld), then ld's own (its default linker
///     script's SEARCH_DIRs, `ld --verbose` of the driver's `ld`);
///   * Apple: ld(1)'s defaults, /usr/local/lib and /usr/lib (Apple's SDK
///     holds no third-party archive; Homebrew's is a -L directory);
///   * Microsoft: link.exe's, the LIB environment's directories.
///
/// None when the toolchain cannot be asked: the message of a missing archive
/// lists what was searched.
fn default_library_dirs(flavor: LinkerFlavor) -> Vec<PathBuf> {
    let mut dirs: Vec<PathBuf> = Vec::new();
    match flavor {
        LinkerFlavor::Gnu => {
            if let Ok(tool) = system_linker(flavor) {
                let ask = |args: &[&str]| Command::new(&tool).args(args).output().ok().map(|o| String::from_utf8_lossy(&o.stdout).into_owned());
                if let Some(text) = ask(&["-print-search-dirs"]) {
                    dirs.extend(gnu_driver_dirs(&text));
                }
                if let Some(ld) = ask(&["-print-prog-name=ld"]) {
                    let ld = ld.trim();
                    if !ld.is_empty() {
                        if let Ok(o) = Command::new(ld).arg("--verbose").output() {
                            dirs.extend(gnu_script_dirs(&String::from_utf8_lossy(&o.stdout)));
                        }
                    }
                }
            }
        }
        LinkerFlavor::Apple => dirs.extend(["/usr/local/lib", "/usr/lib"].map(PathBuf::from)),
        LinkerFlavor::Msvc => {
            if let Some(lib) = std::env::var_os("LIB") {
                dirs.extend(std::env::split_paths(&lib).filter(|d| !d.as_os_str().is_empty()));
            }
        }
    }
    let mut unique: Vec<PathBuf> = Vec::new();
    for dir in dirs {
        // Links resolved, so /lib and /usr/lib are one directory; on Windows
        // only made absolute: canonicalize's `\\?\` verbatim paths are no
        // paths to hand link.exe.
        let dir = if cfg!(windows) { std::path::absolute(&dir).unwrap_or(dir) } else { std::fs::canonicalize(&dir).unwrap_or(dir) };
        if dir.is_dir() && !unique.contains(&dir) {
            unique.push(dir);
        }
    }
    unique
}

/// The `libraries: =DIR:DIR...` line of a GCC or Clang driver's
/// `-print-search-dirs`.
fn gnu_driver_dirs(text: &str) -> Vec<PathBuf> {
    text.lines()
        .find_map(|line| line.strip_prefix("libraries: "))
        .map(|list| list.trim_start_matches('=').split(':').filter(|d| !d.is_empty()).map(PathBuf::from).collect())
        .unwrap_or_default()
}

/// The SEARCH_DIR("=DIR") directories of GNU ld's `--verbose` linker script
/// (`=` the sysroot, the root directory of a native toolchain).
fn gnu_script_dirs(text: &str) -> Vec<PathBuf> {
    let mut dirs = Vec::new();
    let mut rest = text;
    while let Some(at) = rest.find("SEARCH_DIR(\"") {
        rest = &rest[at + 12..];
        let Some(end) = rest.find("\")") else { break };
        let dir = rest[..end].trim_start_matches('=');
        if !dir.is_empty() {
            dirs.push(PathBuf::from(dir));
        }
        rest = &rest[end..];
    }
    dirs
}

/// The resolved plan INPUTS, one line per dependency, for the link's verbose
/// account (BOTLISH_NATIVE_LINK_LOG; `log_link`) and the driver's
/// `link-plan` report: which file each static archive is, and why.
pub fn describe_inputs(inputs: &[LinkInput]) -> Vec<String> {
    inputs
        .iter()
        .map(|input| match input {
            LinkInput::Library(name) => format!("library {name}: {}", library_argument(LINKER, name)),
            LinkInput::Archive { name, path, from: ArchiveSource::Declared(written) } => {
                format!("static {name}: {} (declared at {written:?})", path.display())
            }
            LinkInput::Archive { name, path, from: ArchiveSource::Searched(dir) } => {
                format!("static {name}: {} (found in {})", path.display(), dir.display())
            }
            LinkInput::Framework(name) => format!("framework {name}: -framework {name}"),
        })
        .collect()
}

/// Appends the resolved plan INPUTS to BOTLISH_NATIVE_LINK_LOG, when set
/// (the verbose mode of either linker).
fn log_plan(inputs: &[LinkInput]) {
    if inputs.is_empty() {
        return;
    }
    let Some(log) = std::env::var_os("BOTLISH_NATIVE_LINK_LOG").filter(|p| !p.is_empty()) else { return };
    let text: String = describe_inputs(inputs).iter().map(|line| format!("link plan: {line}\n")).collect();
    if let Ok(mut file) = std::fs::OpenOptions::new().create(true).append(true).open(&log) {
        let _ = std::io::Write::write_all(&mut file, text.as_bytes());
    }
}

/// The `stub` linker: the prebuilt `botlish-aot-stub` with the program's
/// image appended (runtime/aotimage.rs), started by STARTUP -- the worker
/// only: the stub is Linux x86-64's, where `emit_executable` refuses the
/// main-thread policy first, and refuses it itself too.
fn link_stub(program: &Program, destination: &Path, startup: Startup) -> Result<(), String> {
    // `image` lays out and relocates an ELF x86-64 object (its relocation
    // types and call trampolines are x86-64's), and the stub's loader is
    // built for x86-64 Linux only (runtime/aotimage.rs). No Mach-O stub:
    // macOS executables are the system linker's.
    if !cfg!(all(target_os = "linux", target_arch = "x86_64")) {
        return Err("the stub linker supports x86_64 Linux only: use BOTLISH_NATIVE_LINKER=rustc".into());
    }
    if startup != Startup::Worker {
        return Err(format!("the stub linker links worker-startup executables only, not the startup policy {}", startup.spelling()));
    }
    let stub = match std::env::var_os("BOTLISH_NATIVE_AOT_STUB") {
        Some(path) => PathBuf::from(path),
        None => {
            let driver = std::env::current_exe().map_err(|e| e.to_string())?;
            driver.parent().ok_or("cannot locate native runtime")?.join("botlish-aot-stub")
        }
    };
    let mut bytes = std::fs::read(&stub).map_err(|e| {
        format!(
            "runtime stub missing: {}: {e}; run cargo build --release --manifest-path native/Cargo.toml",
            stub.display()
        )
    })?;
    if bytes.ends_with(aotimage::MAGIC) {
        return Err(format!("{} already carries a program image: not a botlish-aot-stub", stub.display()));
    }
    let object = emit_executable_object(program, startup).map_err(|e| e.message().to_string())?;
    let payload = image(program, &object)?.encode();
    bytes.extend_from_slice(&payload);
    bytes.extend_from_slice(&aotimage::trailer(payload.len()));
    let work = WorkDir::beside(destination)?;
    let executable = work.0.join("executable");
    std::fs::write(&executable, &bytes).map_err(|e| e.to_string())?;
    #[cfg(unix)]
    {
        use std::os::unix::fs::PermissionsExt;
        std::fs::set_permissions(&executable, std::fs::Permissions::from_mode(0o755)).map_err(|e| e.to_string())?;
    }
    // Publish only a complete file, on the same filesystem, as link_rustc.
    std::fs::rename(&executable, destination).map_err(|e| format!("{}: {e}", destination.display()))?;
    Ok(())
}

// ------------------------------------------------------------ the system linker

/// The host's name in messages: the compilation target table's
/// (core/cabi.tcl).
const HOST_TARGET: &str = if cfg!(all(target_os = "linux", target_arch = "x86_64")) {
    "linux-x86_64"
} else if cfg!(all(target_os = "linux", target_arch = "aarch64")) {
    "linux-aarch64"
} else if cfg!(all(target_os = "macos", target_arch = "aarch64")) {
    "macos-aarch64"
} else if cfg!(all(target_os = "windows", target_arch = "x86_64")) {
    "windows-x86_64"
} else {
    "this host"
};

/// The runtime archive's file name beside the driver: Cargo's name for the
/// staticlib of native/runtime-archive on the host.
const RUNTIME_ARCHIVE: &str = if cfg!(target_env = "msvc") { "botlish_runtime.lib" } else { "libbotlish_runtime.a" };

/// The system libraries the runtime archive needs, after it, in the
/// FLAVOR linker's spelling: Rust's standard library's and the runtime's
/// own (rustc's `--print native-static-libs` for native/runtime-archive,
/// which native/runtime-archive/libraries.tcl compares with this list, as
/// `botlish-native system-linker` prints it: on every single-executable
/// build and in every host's system-linker CI job). On Windows the C
/// runtime is `system_link_args`'s: the static one, `crt_args_for`'s
/// policy; `legacy_stdio_definitions.lib` is the libc crate's (the
/// out-of-line printf family of its MSVC declarations), which
/// runtime::library's `malloc` and `free` link on every host.
fn runtime_system_libraries(flavor: LinkerFlavor) -> &'static [&'static str] {
    match flavor {
        LinkerFlavor::Gnu => &["-lgcc_s", "-lutil", "-lrt", "-lpthread", "-lm", "-ldl", "-lc"],
        LinkerFlavor::Apple => &["-liconv", "-lSystem", "-lc", "-lm"],
        LinkerFlavor::Msvc => &["legacy_stdio_definitions.lib", "kernel32.lib", "ntdll.lib", "userenv.lib", "ws2_32.lib", "dbghelp.lib"],
    }
}

/// The program the system linker runs: `cc` (the C compiler driver: GCC's
/// or Clang's on Linux, Apple clang through /usr/bin/cc on macOS) or
/// Microsoft's `link.exe` on Windows.
fn default_system_linker(flavor: LinkerFlavor) -> &'static str {
    if flavor == LinkerFlavor::Msvc { "link.exe" } else { "cc" }
}

/// FILE found the way this module looks for a tool: a name with a path
/// separator as it is, otherwise in PATH's directories in order, never in
/// the working directory (unless PATH names it); on Windows a name without
/// an extension with `.exe` too.
fn find_tool(file: &str) -> Option<PathBuf> {
    let named = Path::new(file);
    if named.components().count() > 1 || named.is_absolute() {
        return named.is_file().then(|| std::path::absolute(named).unwrap_or_else(|_| named.to_path_buf()));
    }
    let candidates: Vec<String> = if cfg!(windows) && named.extension().is_none() {
        vec![format!("{file}.exe"), file.to_string()]
    } else {
        vec![file.to_string()]
    };
    let path = std::env::var_os("PATH")?;
    for dir in std::env::split_paths(&path) {
        if dir.as_os_str().is_empty() {
            continue;
        }
        for candidate in &candidates {
            let found = dir.join(candidate);
            if found.is_file() {
                return Some(found);
            }
        }
    }
    None
}

/// How the host's packages provide a C toolchain, for the message that says
/// it is missing.
fn toolchain_remedy(flavor: LinkerFlavor) -> &'static str {
    match flavor {
        LinkerFlavor::Gnu => "install a C toolchain (Debian, Ubuntu: apt install gcc; Fedora: dnf install gcc)",
        LinkerFlavor::Apple => "install Apple's Command Line Tools (xcode-select --install) or Xcode",
        LinkerFlavor::Msvc => "run from a Visual Studio Developer Command Prompt (or after vcvars64.bat), whose environment puts Microsoft's link.exe on PATH and its libraries and the Windows SDK's in LIB",
    }
}

/// The system linker's program, resolved: `BOTLISH_NATIVE_SYSTEM_LINKER`
/// when set (a path, or a name searched for on PATH), else the flavor's
/// default. On Windows it must be Microsoft's link.exe (or LLVM's
/// lld-link): a Unix toolset on PATH has a `link` of its own.
fn system_linker(flavor: LinkerFlavor) -> Result<PathBuf, LinkError> {
    let (name, chosen) = match std::env::var("BOTLISH_NATIVE_SYSTEM_LINKER") {
        Ok(name) if !name.is_empty() => (name, " (BOTLISH_NATIVE_SYSTEM_LINKER)"),
        _ => (default_system_linker(flavor).to_string(), ""),
    };
    let what = if flavor == LinkerFlavor::Msvc { "Microsoft's linker" } else { "a C compiler driver" };
    let Some(tool) = find_tool(&name) else {
        return Err(toolchain_error(format!(
            "native link failed: the system linker needs {what} to link an executable for {HOST_TARGET}, and there is none: no {name}{chosen} {}. To link: {}, or name one with BOTLISH_NATIVE_SYSTEM_LINKER",
            if Path::new(&name).components().count() > 1 { "file" } else { "on PATH" },
            toolchain_remedy(flavor)
        )));
    };
    if flavor == LinkerFlavor::Msvc {
        // link.exe with no input prints its banner (lld-link its own name);
        // Git's or MSYS2's coreutils `link` neither.
        let probe = Command::new(&tool).output();
        let banner = probe.map(|o| format!("{}{}", String::from_utf8_lossy(&o.stdout), String::from_utf8_lossy(&o.stderr))).unwrap_or_default();
        if !banner.contains("Microsoft (R)") && !banner.contains("lld-link") {
            return Err(toolchain_error(format!(
                "native link failed: {} is not Microsoft's link.exe (a Unix toolset's `link`?), which the system linker needs to link an executable for {HOST_TARGET}: {}, or name it with BOTLISH_NATIVE_SYSTEM_LINKER",
                tool.display(),
                toolchain_remedy(flavor)
            )));
        }
    }
    Ok(tool)
}

/// The runtime archive the system linker links: `BOTLISH_NATIVE_RUNTIME`
/// when set, else the driver's own (`packaged_runtime_archive`). Checked
/// before anything is linked: a file, a static archive, of this host's
/// object format and architecture (`archive_machine`). That it holds the
/// helpers the program's code calls is the linker's to find
/// (`undefined_helper`), and the ABI it was built for the executable's own,
/// when it starts (the program record's fingerprint,
/// `runtime::program::read_linked`).
fn runtime_archive() -> Result<PathBuf, LinkError> {
    let (path, built) = match std::env::var_os("BOTLISH_NATIVE_RUNTIME").filter(|p| !p.is_empty()) {
        Some(path) => (PathBuf::from(path), RUNTIME_BUILT),
        None => {
            let driver = std::env::current_exe().map_err(|e| e.to_string())?;
            let bundles = cfg!(target_os = "macos");
            let path = packaged_runtime_archive(&driver, bundles).ok_or("cannot locate native runtime")?;
            (path, runtime_remedy(&driver, bundles))
        }
    };
    if !path.is_file() {
        return Err(runtime_error(format!(
            "native link failed: the runtime archive is missing: {}: the system linker links every executable with Botlish's precompiled runtime, and {built}",
            path.display()
        )));
    }
    match archive_machine(&path) {
        Ok(machine) if machine == HOST_MACHINE => Ok(path),
        Ok(machine) => Err(runtime_error(format!(
            "native link failed: the runtime archive {} is for {machine}, not this driver's {HOST_TARGET} ({HOST_MACHINE}): {built}",
            path.display()
        ))),
        Err(why) => Err(runtime_error(format!("native link failed: the runtime archive {} is unusable: {why}: {built}", path.display()))),
    }
}

/// Where a missing or unusable runtime archive comes from: a checkout's
/// build, or the distribution that carries one.
const RUNTIME_BUILT: &str = "the runtime archive is built with the compiler (cargo build --release --manifest-path native/Cargo.toml in a checkout; the single executable carries its own, and the macOS application its Contents/Resources/libbotlish_runtime.a)";
/// The same for a driver in the macOS application, whose user has no
/// checkout to build in: the application is damaged.
const RUNTIME_BUNDLED: &str = "the macOS application carries it as Contents/Resources/libbotlish_runtime.a: the application is incomplete or damaged (reinstall it)";

/// The remedy runtime_archive's failures name for the driver at DRIVER.
fn runtime_remedy(driver: &Path, bundles: bool) -> &'static str {
    if application_contents(driver, bundles).is_some() {
        RUNTIME_BUNDLED
    } else {
        RUNTIME_BUILT
    }
}

/// The Contents directory of the application bundle whose Contents/MacOS
/// holds the driver at DRIVER, with BUNDLES (macOS); None for a driver
/// anywhere else. Read from the driver's own path, never the working
/// directory's.
fn application_contents(driver: &Path, bundles: bool) -> Option<&Path> {
    let dir = driver.parent()?;
    let contents = dir.parent()?;
    let bundled = bundles
        && dir.file_name().is_some_and(|name| name == "MacOS")
        && contents.file_name().is_some_and(|name| name == "Contents");
    bundled.then_some(contents)
}

/// Where the driver at DRIVER keeps its runtime archive: beside it (a
/// checkout's native/target/release, the single executable's installed
/// copies), or, with BUNDLES (macOS) and a driver in an application bundle's
/// Contents/MacOS, in that bundle's Contents/Resources: the macOS
/// application's layout (MACOS-AARCH64-MILESTONE-9.md), whose MacOS
/// directory holds code only.
fn packaged_runtime_archive(driver: &Path, bundles: bool) -> Option<PathBuf> {
    match application_contents(driver, bundles) {
        Some(contents) => Some(contents.join("Resources").join(RUNTIME_ARCHIVE)),
        None => Some(driver.parent()?.join(RUNTIME_ARCHIVE)),
    }
}

/// This host's object format and architecture, as `archive_machine` names
/// an archive's.
const HOST_MACHINE: &str = if cfg!(all(target_os = "linux", target_arch = "x86_64")) {
    "ELF x86-64"
} else if cfg!(all(target_os = "linux", target_arch = "aarch64")) {
    "ELF AArch64"
} else if cfg!(all(target_os = "macos", target_arch = "aarch64")) {
    "Mach-O arm64"
} else if cfg!(all(target_os = "windows", target_arch = "x86_64")) {
    "COFF x86-64"
} else {
    "unsupported"
};

/// The object format and architecture of the first object file in the
/// static archive at PATH (`ar`'s format, which GNU, BSD/Apple and
/// Microsoft archives share: an `!<arch>` magic and 60-byte member
/// headers), its symbol tables, name tables and import members skipped.
fn archive_machine(path: &Path) -> Result<String, String> {
    use std::io::{Read, Seek, SeekFrom};
    let mut file = std::fs::File::open(path).map_err(|e| e.to_string())?;
    let length = file.metadata().map_err(|e| e.to_string())?.len();
    let mut magic = [0u8; 8];
    if file.read_exact(&mut magic).is_err() || &magic != b"!<arch>\n" {
        return Err("not a static library (no !<arch> header)".to_string());
    }
    let mut at = 8u64;
    for _ in 0..64 {
        if at + 60 > length {
            break;
        }
        let mut header = [0u8; 60];
        file.seek(SeekFrom::Start(at)).map_err(|e| e.to_string())?;
        file.read_exact(&mut header).map_err(|e| e.to_string())?;
        if &header[58..60] != b"`\n" {
            return Err("damaged static library (bad member header)".to_string());
        }
        let name = String::from_utf8_lossy(&header[..16]).trim_end().to_string();
        let size: u64 = String::from_utf8_lossy(&header[48..58])
            .trim()
            .parse()
            .map_err(|_| "damaged static library (bad member size)".to_string())?;
        let mut data_at = at + 60;
        let mut data_size = size;
        // BSD's long names: "#1/N", the name the member's first N bytes.
        if let Some(n) = name.strip_prefix("#1/").and_then(|n| n.parse::<u64>().ok()) {
            data_at += n;
            data_size = data_size.saturating_sub(n);
        }
        let special = name == "/" || name == "//" || name.starts_with("/SYM64/") || name.starts_with("__.SYMDEF");
        if !special && data_size >= 20 {
            let mut head = [0u8; 20];
            file.seek(SeekFrom::Start(data_at)).map_err(|e| e.to_string())?;
            file.read_exact(&mut head).map_err(|e| e.to_string())?;
            let u16_at = |i: usize| u16::from_le_bytes([head[i], head[i + 1]]);
            let u32_at = |i: usize| u32::from_le_bytes([head[i], head[i + 1], head[i + 2], head[i + 3]]);
            if &head[..4] == b"\x7fELF" {
                let machine = u16_at(18);
                return Ok(match (head[4], machine) {
                    (2, 62) => "ELF x86-64".to_string(),
                    (2, 183) => "ELF AArch64".to_string(),
                    (class, machine) => format!("ELF (class {class}, machine {machine})"),
                });
            }
            if u32_at(0) == 0xfeed_facf {
                return Ok(match u32_at(4) {
                    0x0100_000c => "Mach-O arm64".to_string(),
                    0x0100_0007 => "Mach-O x86-64".to_string(),
                    cpu => format!("Mach-O (cpu type {cpu:#x})"),
                });
            }
            if u16_at(0) == 0 && u16_at(2) == 0xffff {
                // A Microsoft import member (an import library's): no code.
            } else if let m @ (0x8664 | 0xaa64 | 0x14c) = u16_at(0) {
                return Ok(match m {
                    0x8664 => "COFF x86-64".to_string(),
                    0xaa64 => "COFF AArch64".to_string(),
                    _ => "COFF x86".to_string(),
                });
            }
        }
        at = (at + 60 + size).next_multiple_of(2);
    }
    Err("damaged static library (no object file found)".to_string())
}

/// The arguments of the FLAVOR system linker linking OBJECTS (the program
/// object), PROGRAM's link plan and the runtime archive
/// RUNTIME into OUTPUT: what rustc's own link of an executable passes the
/// platform linker, in the order the platform's static linking needs, as
/// separate arguments (never one shell string):
///
///   * GNU (gcc or clang driving ld): a position-independent executable
///     (`-pie`) with `--eh-frame-hdr` (Rust's unwinder reads it), full RELRO
///     and unused sections dropped (`--gc-sections`), as rustc links one;
///     the objects; the plan as `link_plan_args_for` gives it -- the `-L`
///     directories, the libraries in one archive group --; the runtime
///     archive; its system libraries. The driver appends its own default
///     libraries (libc, libgcc, the dynamic loader) after all of it, as for
///     any C program.
///   * Apple (clang driving Apple's ld): arm64, rustc's deployment target
///     (11.0) unless MACOSX_DEPLOYMENT_TARGET names one, `-dead_strip`; the
///     objects; `-L` and `-l` without a group; the runtime archive and its
///     system libraries.
///   * Microsoft (link.exe): a console executable, no incremental linking
///     (whose jump thunks would make a function's address another than its
///     code's, which the stack maps are keyed by), unreferenced code
///     dropped; the objects; `/LIBPATH:` and `NAME.lib`; the runtime
///     archive and its system libraries; the static release C runtime, every
///     other Microsoft runtime excluded (`crt_args_for`'s policy).
fn system_link_args(
    flavor: LinkerFlavor,
    objects: &[&Path],
    runtime: &Path,
    output: &Path,
    program: &Program,
    inputs: &[LinkInput],
    search: &LinkSearch,
    startup: Startup,
) -> Vec<OsString> {
    let mut args: Vec<OsString> = Vec::new();
    let mut push = |a: &str| args.push(a.into());
    match flavor {
        LinkerFlavor::Gnu => {
            for flag in ["-pie", "-Wl,--eh-frame-hdr", "-Wl,-z,relro,-z,now", "-Wl,--gc-sections"] {
                push(flag);
            }
        }
        LinkerFlavor::Apple => {
            push("-arch");
            push("arm64");
            if std::env::var_os("MACOSX_DEPLOYMENT_TARGET").is_none_or(|v| v.is_empty()) {
                push("-mmacosx-version-min=11.0");
            }
            push("-Wl,-dead_strip");
            for arg in startup_link_args(flavor, startup) {
                push(&arg);
            }
        }
        LinkerFlavor::Msvc => {
            for flag in ["/NOLOGO", "/SUBSYSTEM:CONSOLE", "/INCREMENTAL:NO", "/OPT:REF", "/OPT:ICF", "/NXCOMPAT", "/DYNAMICBASE"] {
                push(flag);
            }
        }
    }
    if flavor == LinkerFlavor::Msvc {
        let mut out = OsString::from("/OUT:");
        out.push(output);
        args.push(out);
    } else {
        args.push("-o".into());
        args.push(output.into());
    }
    args.extend(objects.iter().map(|o| o.as_os_str().to_owned()));
    // The plan exactly as the rustc linker passes it to the same linker,
    // rustc's own wrapping (`-C link-arg=`) taken off.
    let plan = link_plan_args_for(flavor, program, inputs, search);
    args.extend(plan.iter().filter_map(|a| a.strip_prefix("link-arg=")).map(OsString::from));
    args.push(runtime.into());
    args.extend(runtime_system_libraries(flavor).iter().map(OsString::from));
    if flavor == LinkerFlavor::Msvc {
        for library in ["libcmt.lib", "libvcruntime.lib", "libucrt.lib"] {
            args.push(library.into());
        }
        for library in OTHER_MSVC_RUNTIMES {
            args.push(format!("/NODEFAULTLIB:{library}").into());
        }
    }
    args
}

/// Lines of a failed system link that say the driver has no linker to run
/// (rather than that the link failed): GCC's collect2, Clang's driver, and
/// macOS's tool shims without the Command Line Tools.
fn missing_linker_lines(output: &str) -> Option<String> {
    let lines: Vec<&str> = output
        .lines()
        .map(str::trim)
        .filter(|line| {
            line.contains("collect2: fatal error: cannot find")
                || (line.contains("unable to execute command") && line.contains("ld"))
                || line.contains("invalid linker name")
                || line.contains("xcrun: error: invalid active developer path")
                || line.contains("No developer tools were found")
                || line.contains("error: unable to find utility")
        })
        .collect();
    (!lines.is_empty()).then(|| lines.join("\n"))
}

/// What the system linker would link with on this host, by name: its
/// `flavor`, its `tool` (`system_linker`), the `runtime` archive
/// (`runtime_archive`: its path and machine) and the archive's system
/// `libraries` -- each a list of words, or why it is unusable.
pub fn system_linker_facts() -> Vec<(&'static str, Result<Vec<String>, LinkError>)> {
    let flavor = match LINKER {
        LinkerFlavor::Gnu => "gnu",
        LinkerFlavor::Apple => "apple",
        LinkerFlavor::Msvc => "msvc",
    };
    vec![
        ("flavor", Ok(vec![flavor.to_string(), HOST_TARGET.to_string()])),
        ("tool", system_linker(LINKER).map(|tool| vec![tool.display().to_string()])),
        ("runtime", runtime_archive().map(|path| vec![path.display().to_string(), HOST_MACHINE.to_string()])),
        ("libraries", Ok(runtime_system_libraries(LINKER).iter().map(|l| l.to_string()).collect())),
    ]
}

/// The link's account for `BOTLISH_NATIVE_LINK_LOG=FILE`, the system
/// linker's verbose mode: every link appends its command line -- the tool
/// and each argument, quoted where it holds a space -- its status and
/// everything the linker wrote to FILE. Messages never carry it: a failed
/// link's says what failed in the linker's own lines.
fn log_link(tool: &Path, args: &[OsString], status: &std::process::ExitStatus, text: &str) {
    let Some(log) = std::env::var_os("BOTLISH_NATIVE_LINK_LOG").filter(|p| !p.is_empty()) else { return };
    let quoted = |a: &std::ffi::OsStr| {
        let a = a.to_string_lossy();
        if a.contains(' ') || a.is_empty() { format!("'{a}'") } else { a.into_owned() }
    };
    let mut line = quoted(tool.as_os_str());
    for arg in args {
        line.push(' ');
        line.push_str(&quoted(arg));
    }
    let entry = format!("system linker: {line}\nstatus: {status}\n{text}");
    if let Ok(mut file) = std::fs::OpenOptions::new().create(true).append(true).open(&log) {
        let _ = std::io::Write::write_all(&mut file, entry.as_bytes());
    }
}

/// The first runtime helper (ops.rs's `HELPER_SIGNATURES`) a failed link's
/// output OUTPUT names as undefined, in GNU ld's, lld's, Apple ld's or
/// link.exe's words: the runtime archive then lacks what the program
/// object calls, so it is another build's (or no Botlish runtime at all).
fn undefined_helper(output: &str) -> Option<&'static str> {
    botlish_native::runtime::ops::HELPER_SIGNATURES.iter().map(|&(name, _)| name).find(|name| {
        output.contains(&format!("undefined reference to `{name}'"))
            || output.lines().any(|line| line.trim_end().ends_with(&format!("undefined symbol: {name}")))
            || output.contains(&format!("\"_{name}\", referenced from"))
            || output.contains(&format!("unresolved external symbol {name} "))
    })
}

/// The `system` linker: the program object (its startup data, the
/// `botlish_program` record, inside it) and the runtime archive, linked by
/// the host's own toolchain with the program's
/// link plan (the module doc; SINGLE-EXECUTABLE-FFI-MILESTONE-1.md). Needs
/// no rustc, no Rust library and no checkout: only `system_linker`, the
/// runtime archive (`runtime_archive`) and the libraries the program
/// declares.
fn link_system(program: &Program, destination: &Path, search: &LinkSearch, startup: Startup) -> Result<(), LinkError> {
    let runtime = runtime_archive()?;
    let tool = system_linker(LINKER)?;
    let inputs = resolve_link_plan(program, search)?;
    log_plan(&inputs);
    let work = WorkDir::beside(destination)
        .map_err(|e| format!("native link failed: cannot write the executable {}: {e}", destination.display()))?;
    let object = emit_executable_object(program, startup).map_err(|e| e.message().to_string())?;
    let object_path = work.0.join(if LINKER == LinkerFlavor::Msvc { "program.obj" } else { "program.o" });
    let executable = work.0.join(format!("executable{}", std::env::consts::EXE_SUFFIX));
    std::fs::write(&object_path, &object.bytes).map_err(|e| e.to_string())?;
    let args = system_link_args(LINKER, &[&object_path], &runtime, &executable, program, &inputs, search, startup);
    let output = Command::new(&tool)
        .args(&args)
        .output()
        .map_err(|e| toolchain_error(format!("native link failed: cannot run the system linker {}: {e}", tool.display())))?;
    let text = format!("{}{}", String::from_utf8_lossy(&output.stdout), String::from_utf8_lossy(&output.stderr));
    log_link(&tool, &args, &output.status, &text);
    if !output.status.success() {
        if let Some(lines) = missing_linker_lines(&text) {
            return Err(toolchain_error(format!(
                "native link failed: the system linker {} could not run a linker for {HOST_TARGET}:\n{lines}\nTo link: {}",
                tool.display(),
                toolchain_remedy(LINKER)
            )));
        }
        // No `main` at all: the C runtime's startup found none, so the
        // archive is no Botlish runtime archive (GNU ld's, Apple ld's,
        // link.exe's words).
        if text.contains("undefined reference to `main'")
            || text.contains("\"_main\", referenced from")
            || text.contains("unresolved external symbol main ")
            || text.contains("unresolved external symbol _main ")
        {
            return Err(runtime_error(format!(
                "native link failed: the runtime archive {} defines no main: it is no Botlish runtime archive: {}",
                runtime.display(),
                linker_diagnostics(&text)
            )));
        }
        if let Some(helper) = undefined_helper(&text) {
            return Err(runtime_error(format!(
                "native link failed: the runtime archive {} does not define the runtime helper {helper} this driver's code calls: it is another build's: {}",
                runtime.display(),
                linker_diagnostics(&text)
            )));
        }
        if calls_c(program) {
            let diagnostics = linker_diagnostics(&text);
            let mut hint = link_hint(LINKER, &diagnostics).map(|hint| format!("\n{hint}")).unwrap_or_default();
            // A link directory that is none is no error of the plan's (the
            // linker searches the others), but said after a failed link,
            // where it may be why a library was not found.
            for dir in search.libraries.iter().filter(|dir| !Path::new(dir).is_dir()) {
                write!(hint, "\nthe link directory {dir} (-L) is not a directory").unwrap();
            }
            return Err(format!(
                "native link failed: the system linker could not link this program with the C functions and libraries it declares ({}):\n{}{}",
                describe_link_plan(program),
                diagnostics,
                hint
            )
            .into());
        }
        return Err(format!("executable link failed ({}, system linker {}):\n{}", output.status, tool.display(), linker_diagnostics(&text)).into());
    }
    // Publish only a successfully linked file, on the same filesystem, as
    // link_rustc: a failed link leaves any previous executable intact.
    std::fs::rename(&executable, destination).map_err(|e| format!("{}: {e}", destination.display()))?;
    Ok(())
}

// The ELF64 x86-64 relocatable object `emit_object` writes: just what `image`
// reads of it.
const SHT_RELA: u32 = 4;
const SHT_NOBITS: u32 = 8;
const SHT_SYMTAB: u32 = 2;
const SHF_ALLOC: u64 = 2;
const SHF_EXECINSTR: u64 = 4;
const SHN_UNDEF: u16 = 0;
const SHN_LORESERVE: u16 = 0xff00;
const R_X86_64_64: u32 = 1;
const R_X86_64_PC32: u32 = 2;
const R_X86_64_PLT32: u32 = 4;
const R_X86_64_GOTPCREL: u32 = 9;
const R_X86_64_GOTPCRELX: u32 = 41;
const R_X86_64_REX_GOTPCRELX: u32 = 42;

struct Section {
    kind: u32,
    flags: u64,
    offset: usize,
    size: usize,
    link: usize,
    info: usize,
    align: u64,
    entsize: usize,
}

struct Symbol {
    name: String,
    section: u16,
    value: u64,
}

struct Rela {
    section: usize,
    offset: u64,
    kind: u32,
    symbol: usize,
    addend: i64,
}

fn read_object(bytes: &[u8]) -> Result<(Vec<Section>, Vec<Symbol>, Vec<Rela>), String> {
    let bad = || "malformed program object".to_string();
    let get = |at: usize, n: usize| bytes.get(at..at + n).ok_or_else(bad);
    let u16_at = |at: usize| get(at, 2).map(|b| u16::from_le_bytes(b.try_into().unwrap()));
    let u32_at = |at: usize| get(at, 4).map(|b| u32::from_le_bytes(b.try_into().unwrap()));
    let u64_at = |at: usize| get(at, 8).map(|b| u64::from_le_bytes(b.try_into().unwrap()));
    if bytes.len() < 64 || &bytes[0..4] != b"\x7fELF" || bytes[4] != 2 || bytes[5] != 1 || u16_at(0x12)? != 62 {
        return Err("program object is not an ELF64 x86-64 object".to_string());
    }
    let shoff = u64_at(0x28)? as usize;
    let shentsize = u16_at(0x3a)? as usize;
    let mut sections = Vec::new();
    for i in 0..u16_at(0x3c)? as usize {
        let h = shoff + i * shentsize;
        sections.push(Section {
            kind: u32_at(h + 4)?,
            flags: u64_at(h + 8)?,
            offset: u64_at(h + 0x18)? as usize,
            size: u64_at(h + 0x20)? as usize,
            link: u32_at(h + 0x28)? as usize,
            info: u32_at(h + 0x2c)? as usize,
            align: u64_at(h + 0x30)?.max(1),
            entsize: u64_at(h + 0x38)? as usize,
        });
    }
    let mut symbols = Vec::new();
    let symtab = sections.iter().find(|s| s.kind == SHT_SYMTAB && s.entsize > 0).ok_or_else(bad)?;
    let strtab = sections.get(symtab.link).ok_or_else(bad)?;
    for index in 0..symtab.size / symtab.entsize {
        let e = symtab.offset + index * symtab.entsize;
        let start = strtab.offset + u32_at(e)? as usize;
        let tail = bytes.get(start..strtab.offset + strtab.size).ok_or_else(bad)?;
        let end = tail.iter().position(|&c| c == 0).ok_or_else(bad)?;
        symbols.push(Symbol {
            name: String::from_utf8_lossy(&tail[..end]).into_owned(),
            section: u16_at(e + 6)?,
            value: u64_at(e + 8)?,
        });
    }
    let mut relas = Vec::new();
    for s in sections.iter().filter(|s| s.kind == SHT_RELA && s.entsize > 0) {
        for index in 0..s.size / s.entsize {
            let e = s.offset + index * s.entsize;
            let info = u64_at(e + 8)?;
            relas.push(Rela {
                section: s.info,
                offset: u64_at(e)?,
                kind: info as u32,
                symbol: (info >> 32) as usize,
                addend: u64_at(e + 16)? as i64,
            });
        }
    }
    Ok((sections, symbols, relas))
}

/// Lays out OBJECT's allocated sections as one image and relocates it, the
/// way a static linker relocates the same object into an executable:
///
/// ```text
///   [machine code][trampolines]  page-aligned: executable
///   [GOT][data][.bss]            writable
/// ```
///
/// A reference inside the image is resolved here, a PC-relative call to a
/// runtime helper becomes a `Call32` fixup (a direct call at load time, or
/// one through the helper's trampoline if the helper is out of rel32 reach),
/// and an absolute address (a data word, a GOT slot) an `Abs64` fixup.
/// GOT-relative loads of an image symbol are relaxed to `lea` when the
/// relocation allows it (`R_X86_64_[REX_]GOTPCRELX` on a `mov`, as GNU ld
/// and lld relax them: the context area's accesses, mod.rs's
/// `relax_context_got`); every other GOT-relative load gets a GOT slot.
fn image(program: &Program, object: &ObjectProgram) -> Result<Image, String> {
    let bytes = &object.bytes;
    let (sections, symbols, relas) = read_object(bytes)?;
    let unsupported = |r: &Rela| format!("unsupported relocation type {} against {}", r.kind, symbols[r.symbol].name);
    let allocated = |s: &Section| s.flags & SHF_ALLOC != 0;

    // Imports, in first-use order, and what each relocation needs.
    let mut imports: Vec<String> = Vec::new();
    let mut import_index: HashMap<String, u32> = HashMap::new();
    let mut calls: Vec<u32> = Vec::new();
    let mut got: Vec<Target> = Vec::new();
    let mut got_index: HashMap<Target, usize> = HashMap::new();
    let relaxable = |r: &Rela| -> bool {
        // `mov disp32(%rip), %reg` (opcode 0x8b, ModRM mod=00 rm=101) is
        // the instruction both GOTPCRELX relocations may rewrite to `lea`.
        let s = &sections[r.section];
        let at = s.offset + r.offset as usize;
        matches!(r.kind, R_X86_64_GOTPCRELX | R_X86_64_REX_GOTPCRELX)
            && symbols[r.symbol].section != SHN_UNDEF
            && r.offset >= 2
            && bytes.get(at - 2) == Some(&0x8b)
            && bytes.get(at - 1).is_some_and(|m| m & 0xc7 == 0x05)
    };
    // Symbols resolve to Local targets once laid out: until then, GOT keys
    // for image symbols are (section, value) pairs, packed into Local.
    let mut pre_target = |symbol: &Symbol, imports: &mut Vec<String>| -> Result<Target, String> {
        if symbol.section == SHN_UNDEF {
            let next = imports.len() as u32;
            let index = *import_index.entry(symbol.name.clone()).or_insert_with(|| {
                imports.push(symbol.name.clone());
                next
            });
            Ok(Target::Import(index))
        } else if symbol.section < SHN_LORESERVE && sections.get(symbol.section as usize).is_some_and(allocated) {
            Ok(Target::Local(((symbol.section as u64) << 48) | symbol.value))
        } else {
            Err(format!("program object symbol {} is not in an allocated section", symbol.name))
        }
    };
    let mut targets = Vec::with_capacity(relas.len());
    for r in &relas {
        if !sections.get(r.section).is_some_and(allocated) {
            continue;
        }
        let symbol = symbols.get(r.symbol).ok_or("malformed program object relocation")?;
        let target = pre_target(symbol, &mut imports)?;
        match (r.kind, target) {
            (R_X86_64_PLT32, Target::Import(i)) if !calls.contains(&i) => calls.push(i),
            (R_X86_64_GOTPCREL | R_X86_64_GOTPCRELX | R_X86_64_REX_GOTPCRELX, _) if !relaxable(r) => {
                got_index.entry(target).or_insert_with(|| {
                    got.push(target);
                    got.len() - 1
                });
            }
            _ => {}
        }
        targets.push(target);
    }
    // Every helper reached by a call has a trampoline, and so a GOT slot.
    for &i in &calls {
        got_index.entry(Target::Import(i)).or_insert_with(|| {
            got.push(Target::Import(i));
            got.len() - 1
        });
    }

    // Layout.
    let mut place: Vec<Option<u64>> = vec![None; sections.len()];
    let mut cursor = 0u64;
    let mut lay = |i: usize, s: &Section, cursor: &mut u64| {
        *cursor = cursor.next_multiple_of(s.align);
        place[i] = Some(*cursor);
        *cursor += s.size as u64;
    };
    for (i, s) in sections.iter().enumerate() {
        if allocated(s) && s.flags & SHF_EXECINSTR != 0 {
            lay(i, s, &mut cursor);
        }
    }
    cursor = cursor.next_multiple_of(16);
    let trampolines = cursor;
    cursor += 8 * calls.len() as u64;
    let executable = cursor.next_multiple_of(4096);
    let got_base = executable;
    cursor = got_base + 8 * got.len() as u64;
    for (i, s) in sections.iter().enumerate() {
        if allocated(s) && s.flags & SHF_EXECINSTR == 0 && s.kind != SHT_NOBITS {
            lay(i, s, &mut cursor);
        }
    }
    let initialized = cursor;
    for (i, s) in sections.iter().enumerate() {
        if allocated(s) && s.flags & SHF_EXECINSTR == 0 && s.kind == SHT_NOBITS {
            lay(i, s, &mut cursor);
        }
    }
    let size = cursor;

    let mut code = vec![0u8; initialized as usize];
    for (i, s) in sections.iter().enumerate() {
        if let (Some(at), true) = (place[i], s.kind != SHT_NOBITS) {
            let data = bytes.get(s.offset..s.offset + s.size).ok_or("malformed program object section")?;
            code[at as usize..at as usize + s.size].copy_from_slice(data);
        }
    }
    let local = |t: Target| -> Target {
        match t {
            Target::Local(packed) => {
                Target::Local(place[(packed >> 48) as usize].expect("allocated section") + (packed & 0xffff_ffff_ffff))
            }
            import => import,
        }
    };
    let rel32 = |code: &mut [u8], at: u64, value: i128| -> Result<(), String> {
        let value = i32::try_from(value).map_err(|_| "program image relocation out of rel32 range".to_string())?;
        code[at as usize..at as usize + 4].copy_from_slice(&value.to_le_bytes());
        Ok(())
    };
    let mut fixups = Vec::new();
    for (slot, &target) in got.iter().enumerate() {
        fixups.push(Fixup::Abs64 { at: got_base + 8 * slot as u64, target: local(target), addend: 0 });
    }
    let mut trampoline_of = HashMap::new();
    for (n, &i) in calls.iter().enumerate() {
        // jmp *GOT(%rip); int3; int3
        let at = trampolines + 8 * n as u64;
        let slot = got_base + 8 * got_index[&Target::Import(i)] as u64;
        code[at as usize..at as usize + 2].copy_from_slice(&[0xff, 0x25]);
        rel32(&mut code, at + 2, i128::from(slot) - i128::from(at + 6))?;
        code[at as usize + 6..at as usize + 8].copy_from_slice(&[0xcc, 0xcc]);
        trampoline_of.insert(i, at);
    }
    let applied = relas.iter().filter(|r| sections.get(r.section).is_some_and(allocated));
    for (r, &target) in applied.zip(&targets) {
        let at = place[r.section].expect("allocated section") + r.offset;
        let a = i128::from(r.addend);
        match (r.kind, local(target)) {
            (R_X86_64_64, resolved) => fixups.push(Fixup::Abs64 { at, target: resolved, addend: r.addend }),
            (R_X86_64_PC32 | R_X86_64_PLT32, Target::Local(s)) => rel32(&mut code, at, i128::from(s) + a - i128::from(at))?,
            (R_X86_64_PLT32, Target::Import(i)) => {
                fixups.push(Fixup::Call32 { at, import: i, addend: r.addend, trampoline: trampoline_of[&i] })
            }
            (R_X86_64_GOTPCREL | R_X86_64_GOTPCRELX | R_X86_64_REX_GOTPCRELX, resolved) => {
                if let (true, Target::Local(s)) = (relaxable(r), resolved) {
                    code[at as usize - 2] = 0x8d;
                    rel32(&mut code, at, i128::from(s) + a - i128::from(at))?;
                } else {
                    let slot = got_base + 8 * got_index[&target] as u64;
                    rel32(&mut code, at, i128::from(slot) + a - i128::from(at))?;
                }
            }
            _ => return Err(unsupported(r)),
        }
    }

    let defined: HashMap<&str, u64> = symbols
        .iter()
        .filter(|s| s.section != SHN_UNDEF && s.section < SHN_LORESERVE)
        .filter_map(|s| Some((s.name.as_str(), place.get(s.section as usize).copied().flatten()? + s.value)))
        .collect();
    let _ = (program, &object.functions);
    let record = defined.get("botlish_program").copied().ok_or("program object lacks botlish_program")?;
    Ok(Image { imports, code, size, executable, fixups, program: record })
}

#[cfg(test)]
mod tests {
    use super::*;

    /// PROGRAM's link plan resolved for a FLAVOR linker with no default
    /// library directory (its static libraries must be declared at a path).
    fn resolved(flavor: LinkerFlavor, program: &Program) -> Vec<LinkInput> {
        resolve_link_plan_with(flavor, program, &LinkSearch::default(), &mut Vec::new).unwrap_or_else(|e| panic!("{}", e.message))
    }

    /// rustc's link plan arguments of PROGRAM for a FLAVOR linker searching
    /// DIRS (`link_plan_args_for` of `resolved`).
    fn plan_args(flavor: LinkerFlavor, program: &Program, dirs: &[String]) -> Vec<String> {
        link_plan_args_for(flavor, program, &resolved(flavor, program), &LinkSearch::libraries(dirs))
    }

    /// A program that calls one C function and declares two libraries.
    const FFI_PROGRAM: &str = concat!(
        "nir 1 call-effects=1 statics=0\n",
        "link \"first\"\n",
        "link \"second\"\n",
        "foreign 0 \"c_add\" params=\"i32 i32\" result=i32 name=\"m::add\"\n\n",
        "func 0 \"<program>\" params=0 env=0 regs=3 pnames=\"\" captures=0\n",
        "    %0 = int 40\n    %1 = int 2\n    %2 = foreigncall 0 %0 %1\n    ret %2\nend\n",
    );

    /// GNU ld's link plan reaches the system linker as one group, in the
    /// plan's order, after the search directories: GNU ld and gold resolve a
    /// static archive only against what precedes it, so without the group
    /// an archive declared before the archive that needs it would leave its
    /// symbols undefined (lld, rustc's own x86-64 linker, does not care:
    /// tests/c-ffi.test's cf-link-order shows the group's effect where the
    /// linker is GNU ld). Linux's plan, byte for byte.
    #[test]
    fn ffi_link_plan_is_one_linker_group() {
        let program = crate::nir::parse(FFI_PROGRAM).unwrap_or_else(|e| panic!("{}", e.message));
        assert!(calls_c(&program));
        let args = plan_args(LinkerFlavor::Gnu, &program, &["/opt/lib".to_string()]);
        let links: Vec<&str> = args.iter().filter(|a| *a != "-C").map(String::as_str).collect();
        assert_eq!(
            links,
            vec![
                "default-linker-libraries=yes",
                "link-arg=-L/opt/lib",
                "link-arg=-Wl,--start-group",
                "link-arg=-lfirst",
                "link-arg=-lsecond",
                "link-arg=-Wl,--end-group"
            ]
        );
        assert_eq!(describe_link_plan_for(LinkerFlavor::Gnu, &program), "symbols c_add; libraries -lfirst -lsecond");
    }

    /// Apple's ld gets the same plan without GNU's group, which it rejects
    /// as an unknown option and does not need (it searches every archive
    /// until nothing more resolves): the C driver's default libraries, the
    /// search directories (a path with a space is one argument), the
    /// libraries in the plan's order. No GNU flag at all.
    #[test]
    fn ffi_link_plan_apple_has_no_gnu_flags() {
        let program = crate::nir::parse(FFI_PROGRAM).unwrap_or_else(|e| panic!("{}", e.message));
        let args = plan_args(LinkerFlavor::Apple, &program, &["/opt/lib".to_string(), "rel dir".to_string()]);
        let links: Vec<&str> = args.iter().filter(|a| *a != "-C").map(String::as_str).collect();
        assert_eq!(
            links,
            vec![
                "default-linker-libraries=yes",
                "link-arg=-L/opt/lib",
                "link-arg=-Lrel dir",
                "link-arg=-lfirst",
                "link-arg=-lsecond"
            ]
        );
        assert!(args.iter().all(|a| !a.contains("--start-group") && !a.contains("--end-group") && !a.contains("-Wl,")));
    }

    /// Microsoft's link.exe gets the plan in its own spelling: the C
    /// driver's default libraries kept, `/LIBPATH:DIR` for every search
    /// directory (a path with a space is one argument), `NAME.lib` for every
    /// library in the plan's order, and no GNU flag or group at all (link.exe
    /// resolves libraries in any order).
    #[test]
    fn ffi_link_plan_msvc_is_link_exes_spelling() {
        let program = crate::nir::parse(FFI_PROGRAM).unwrap_or_else(|e| panic!("{}", e.message));
        let args = plan_args(LinkerFlavor::Msvc, &program, &["C:\\opt\\lib".to_string(), "rel dir".to_string()]);
        let links: Vec<&str> = args.iter().filter(|a| *a != "-C").map(String::as_str).collect();
        assert_eq!(
            links,
            vec![
                "default-linker-libraries=yes",
                "link-arg=/LIBPATH:C:\\opt\\lib",
                "link-arg=/LIBPATH:rel dir",
                "link-arg=first.lib",
                "link-arg=second.lib"
            ]
        );
        assert!(args.iter().all(|a| !a.contains("-Wl,") && !a.contains("group") && !a.contains("link-arg=-l") && !a.contains("link-arg=-L")));
        // Messages name each library as link.exe is given it.
        assert_eq!(describe_link_plan_for(LinkerFlavor::Msvc, &program), "symbols c_add; libraries first.lib second.lib");
        assert_eq!(describe_link_plan_for(LinkerFlavor::Apple, &program), "symbols c_add; libraries -lfirst -lsecond");
    }

    /// The C runtime of an executable: on Windows (MSVC) the static release
    /// one, so that it imports no Visual C++ redistributable DLL, for every
    /// program, one that calls C included, and every other Microsoft runtime
    /// excluded from the link, so that a C library's default-library
    /// directive never brings a second one; nothing anywhere else.
    #[test]
    fn link_hint_explains_imports_of_the_dynamic_c_runtime() {
        // link.exe's words for a /MD library's runtime call in a static-CRT
        // executable (WINDOWS-X86-64-MILESTONE-2.md, "The C runtime").
        let md = "LINK : warning LNK4217: symbol 'malloc' defined in 'libucrt.lib(malloc.obj)' is imported by 'lib.lib(lib.obj)' in function 'f'\n\
                  lib.lib(lib.obj) : error LNK2019: unresolved external symbol __imp_strtol referenced in function f";
        let hint = link_hint(LinkerFlavor::Msvc, md).expect("a hint for __imp_");
        assert!(hint.contains("/MD") && hint.contains("/MT"), "{hint}");
        // Only for that: an ordinary unresolved symbol, another linker.
        assert_eq!(link_hint(LinkerFlavor::Msvc, "program.o : error LNK2019: unresolved external symbol botlish_nope referenced in function botlish_fn_0"), None);
        assert_eq!(link_hint(LinkerFlavor::Gnu, md), None);
        assert_eq!(link_hint(LinkerFlavor::Apple, md), None);
    }

    #[test]
    fn crt_is_static_and_alone_for_msvc_executables() {
        let ffi = crate::nir::parse(FFI_PROGRAM).unwrap_or_else(|e| panic!("{}", e.message));
        let text = FFI_PROGRAM.replace("link \"first\"\n", "").replace("link \"second\"\n", "")
            .replace("foreign 0 \"c_add\" params=\"i32 i32\" result=i32 name=\"m::add\"\n", "")
            .replace("%2 = foreigncall 0 %0 %1", "%2 = int 42");
        let plain = crate::nir::parse(&text).unwrap_or_else(|e| panic!("{}", e.message));
        for program in [&plain, &ffi] {
            let args = crt_args_for(LinkerFlavor::Msvc, program);
            assert_eq!(&args[..2], ["-C", "target-feature=+crt-static"]);
            let excluded: Vec<&str> = args[2..]
                .iter()
                .filter(|a| *a != "-C")
                .map(|a| a.strip_prefix("link-arg=/NODEFAULTLIB:").unwrap_or_else(|| panic!("{a}")))
                .collect();
            assert_eq!(excluded.len() * 2, args.len() - 2);
            // The dynamic runtimes, release and debug, and the static debug
            // one, C and C++; never the static release runtime linked.
            for library in ["msvcrt.lib", "vcruntime.lib", "ucrt.lib", "msvcrtd.lib", "libcmtd.lib", "libucrtd.lib", "msvcprt.lib"] {
                assert!(excluded.contains(&library), "{library} not excluded: {excluded:?}");
            }
            for library in ["libcmt.lib", "libvcruntime.lib", "libucrt.lib", "libcpmt.lib", "kernel32.lib"] {
                assert!(!excluded.contains(&library), "{library} excluded: {excluded:?}");
            }
        }
        for flavor in [LinkerFlavor::Gnu, LinkerFlavor::Apple] {
            assert!(crt_args_for(flavor, &plain).is_empty());
            assert!(crt_args_for(flavor, &ffi).is_empty());
        }
        assert_eq!(crt_args(&plain), crt_args_for(LINKER, &plain));
    }

    /// An executable's file: on Windows a name without an extension gets
    /// `.exe` (a name with one is kept), elsewhere every name is kept.
    #[test]
    fn executable_names_follow_the_platform() {
        let windows = cfg!(windows);
        let named = |p: &str| executable_path(Path::new(p)).to_string_lossy().into_owned();
        assert_eq!(named("dir/fib"), if windows { "dir/fib.exe" } else { "dir/fib" });
        assert_eq!(named("dir.v2/fib"), if windows { "dir.v2/fib.exe" } else { "dir.v2/fib" });
        assert_eq!(named("dir/fib.exe"), "dir/fib.exe");
        assert_eq!(named("dir/fib.bin"), "dir/fib.bin");
    }

    /// The host's flavor is its platform linker's: Apple's on macOS,
    /// Microsoft's on Windows (MSVC), GNU's on Linux.
    #[test]
    fn ffi_link_plan_flavor_is_the_hosts() {
        let expected = if cfg!(target_os = "macos") {
            LinkerFlavor::Apple
        } else if cfg!(target_env = "msvc") {
            LinkerFlavor::Msvc
        } else {
            LinkerFlavor::Gnu
        };
        assert_eq!(LINKER, expected);
        let program = crate::nir::parse(FFI_PROGRAM).unwrap_or_else(|e| panic!("{}", e.message));
        let inputs = resolved(expected, &program);
        assert_eq!(link_plan_args(&program, &inputs, &LinkSearch::default()), link_plan_args_for(expected, &program, &inputs, &LinkSearch::default()));
    }

    /// A failed link's message keeps the system linker's own lines --
    /// GNU ld's and lld's, Apple ld's undefined-symbol block and missing
    /// library -- and never rustc's echo of the command line.
    #[test]
    fn ffi_linker_diagnostics_keep_the_linkers_words() {
        let apple = concat!(
            "error: linking with `cc` failed: exit status: 1\n",
            "  |\n",
            "  = note: \"cc\" \"/w/symbols.o\" \"-lbotlish_cffi_fixture\" \"-o\" \"/w/executable\" \"-Wl,-dead_strip\"\n",
            "  = note: some arguments are omitted. use `--verbose` to show all linker arguments\n",
            "  = note: ld: library 'botlish_missing' not found\n",
            "          Undefined symbols for architecture arm64:\n",
            "            \"_botlish_no_such_symbol\", referenced from:\n",
            "                _botlish_fn_0 in program.o\n",
            "          ld: symbol(s) not found for architecture arm64\n",
            "          clang: error: linker command failed with exit code 1 (use -v to see invocation)\n",
        );
        let kept = linker_diagnostics(apple);
        for line in [
            "ld: library 'botlish_missing' not found",
            "Undefined symbols for architecture arm64:",
            "\"_botlish_no_such_symbol\", referenced from:",
            "ld: symbol(s) not found for architecture arm64",
            "clang: error: linker command failed with exit code 1 (use -v to see invocation)",
        ] {
            assert!(kept.lines().any(|l| l.ends_with(line)), "{line:?} not in {kept:?}");
        }
        assert!(!kept.contains("-dead_strip"), "{kept:?}");
        let gnu = concat!(
            "error: linking with `cc` failed: exit status: 1\n",
            "  = note: \"cc\" \"-m64\" \"-lmissing\"\n",
            "  = note: rust-lld: error: unable to find library -lmissing\n",
            "          /usr/bin/ld: program.o: in function `botlish_fn_0':\n",
            "          program.o:(.text+0x10): undefined reference to `botlish_no_such_symbol'\n",
            "          /usr/bin/x86_64-linux-gnu-ld.bfd: skipping incompatible /w/libforeign.a when searching for -lforeign\n",
            "          collect2: error: ld returned 1 exit status\n",
        );
        let kept = linker_diagnostics(gnu);
        assert!(kept.contains("undefined reference to `botlish_no_such_symbol'"), "{kept:?}");
        assert!(kept.contains("ld.bfd: skipping incompatible /w/libforeign.a when searching for -lforeign"), "{kept:?}");
        assert!(kept.contains("collect2: error: ld returned 1 exit status"), "{kept:?}");
        assert!(!kept.contains("\"-m64\""), "{kept:?}");
        // Microsoft's link.exe, as rustc reports it, and LLVM's lld-link.
        let msvc = concat!(
            "error: linking with `link.exe` failed: exit code: 1120\n",
            "  |\n",
            "  = note: \"C:\\\\VS\\\\link.exe\" \"/NOLOGO\" \"C:\\\\w\\\\program.o\" \"botlish_missing.lib\" \"/OUT:C:\\\\w\\\\executable.exe\"\n",
            "  = note: some arguments are omitted. use `--verbose` to show all linker arguments\n",
            "  = note: program.o : error LNK2019: unresolved external symbol botlish_no_such_symbol referenced in function botlish_fn_0\r\n",
            "          C:\\w\\executable.exe : fatal error LNK1120: 1 unresolved externals\r\n",
            "          LINK : fatal error LNK1181: cannot open input file 'botlish_missing.lib'\r\n",
            "          lld-link: error: could not open 'botlish_missing.lib': no such file or directory\n",
        );
        let kept = linker_diagnostics(msvc);
        for line in [
            "error LNK2019: unresolved external symbol botlish_no_such_symbol referenced in function botlish_fn_0",
            "fatal error LNK1120: 1 unresolved externals",
            "LINK : fatal error LNK1181: cannot open input file 'botlish_missing.lib'",
            "lld-link: error: could not open 'botlish_missing.lib': no such file or directory",
            "error: linking with `link.exe` failed: exit code: 1120",
        ] {
            assert!(kept.lines().any(|l| l.ends_with(line)), "{line:?} not in {kept:?}");
        }
        assert!(!kept.contains("/NOLOGO"), "{kept:?}");
    }

    fn plain_program() -> Program {
        let text = FFI_PROGRAM.replace("link \"first\"\n", "").replace("link \"second\"\n", "")
            .replace("foreign 0 \"c_add\" params=\"i32 i32\" result=i32 name=\"m::add\"\n", "")
            .replace("%2 = foreigncall 0 %0 %1", "%2 = int 42");
        crate::nir::parse(&text).unwrap_or_else(|e| panic!("{}", e.message))
    }

    fn texts(args: &[OsString]) -> Vec<String> {
        args.iter().map(|a| a.to_string_lossy().into_owned()).collect()
    }

    /// BOTLISH_NATIVE_LINKER's linkers: rustc when unset or empty; `auto`
    /// the system linker for a program that calls C (or declares a library
    /// only) and the stub for any other where there is one -- never rustc.
    #[test]
    fn linker_selection_auto_follows_the_link_plan() {
        let ffi = crate::nir::parse(FFI_PROGRAM).unwrap_or_else(|e| panic!("{}", e.message));
        let declares = crate::nir::parse(&FFI_PROGRAM.replace("link \"second\"\n", "")
            .replace("foreign 0 \"c_add\" params=\"i32 i32\" result=i32 name=\"m::add\"\n", "")
            .replace("%2 = foreigncall 0 %0 %1", "%2 = int 42")).unwrap_or_else(|e| panic!("{}", e.message));
        let plain = plain_program();
        assert!(calls_c(&declares) && !calls_c(&plain));
        for stub in [true, false] {
            for (name, linker) in [(None, Linker::Rustc), (Some(""), Linker::Rustc), (Some("rustc"), Linker::Rustc),
                (Some("stub"), Linker::Stub), (Some("system"), Linker::System)] {
                for program in [&ffi, &plain] {
                    assert_eq!(linker_named(name, program, stub), Ok(linker), "{name:?}");
                }
            }
            assert_eq!(linker_named(Some("auto"), &ffi, stub), Ok(Linker::System));
            assert_eq!(linker_named(Some("auto"), &declares, stub), Ok(Linker::System));
            assert_eq!(linker_named(Some("auto"), &plain, stub), Ok(if stub { Linker::Stub } else { Linker::System }));
        }
        assert_eq!(linker_named(Some("lld"), &plain, true), Err("unknown BOTLISH_NATIVE_LINKER \"lld\" (known: rustc stub system auto)".to_string()));
    }

    /// GNU's system link, argument by argument: rustc's executable flags, the
    /// program object, the plan exactly as the rustc linker hands it to the same
    /// linker (the -L directories, one group, the plan's order), the runtime
    /// archive and its system libraries -- each a separate argument, a path
    /// with a space one of them.
    #[test]
    fn system_link_args_gnu() {
        let ffi = crate::nir::parse(FFI_PROGRAM).unwrap_or_else(|e| panic!("{}", e.message));
        let objects = [Path::new("/w d/program.o")];
        let args = system_link_args(LinkerFlavor::Gnu, &objects, Path::new("/rt/libbotlish_runtime.a"), Path::new("/w d/executable"), &ffi, &resolved(LinkerFlavor::Gnu, &ffi), &LinkSearch::libraries(&["/opt/my lib".to_string()]), Startup::Worker);
        assert_eq!(
            texts(&args),
            [
                "-pie", "-Wl,--eh-frame-hdr", "-Wl,-z,relro,-z,now", "-Wl,--gc-sections", "-o", "/w d/executable",
                "/w d/program.o", "-L/opt/my lib", "-Wl,--start-group", "-lfirst", "-lsecond",
                "-Wl,--end-group", "/rt/libbotlish_runtime.a", "-lgcc_s", "-lutil", "-lrt", "-lpthread", "-lm", "-ldl", "-lc",
            ]
        );
        // The plan is the rustc linker's, unwrapped.
        let plan: Vec<String> = plan_args(LinkerFlavor::Gnu, &ffi, &["/opt/my lib".to_string()])
            .into_iter().filter_map(|a| a.strip_prefix("link-arg=").map(String::from)).collect();
        assert!(texts(&args).windows(plan.len()).any(|w| w == plan.as_slice()));
        // A program that calls no C: no plan, the rest as it was.
        let plain = system_link_args(LinkerFlavor::Gnu, &objects, Path::new("/rt/libbotlish_runtime.a"), Path::new("/w d/executable"), &plain_program(), &resolved(LinkerFlavor::Gnu, &plain_program()), &LinkSearch::libraries(&["/opt/my lib".to_string()]), Startup::Worker);
        assert!(texts(&plain).iter().all(|a| !a.starts_with("-L") && !a.contains("group") && a != "-lfirst"));
        assert_eq!(texts(&plain).len(), texts(&args).len() - 5);
    }

    /// Apple's: arm64 and the deployment target, -dead_strip, no GNU flag.
    #[test]
    fn system_link_args_apple_has_no_gnu_flags() {
        let ffi = crate::nir::parse(FFI_PROGRAM).unwrap_or_else(|e| panic!("{}", e.message));
        let objects = [Path::new("/w/program.o")];
        let args = texts(&system_link_args(LinkerFlavor::Apple, &objects, Path::new("/rt/libbotlish_runtime.a"), Path::new("/w/executable"), &ffi, &resolved(LinkerFlavor::Apple, &ffi), &LinkSearch::libraries(&["/opt/lib".to_string()]), Startup::Worker));
        assert_eq!(&args[..2], ["-arch", "arm64"]);
        assert!(args.contains(&"-Wl,-dead_strip".to_string()));
        let tail: Vec<&str> = args.iter().skip_while(|a| *a != "/w/program.o").map(String::as_str).collect();
        assert_eq!(tail, ["/w/program.o", "-L/opt/lib", "-lfirst", "-lsecond", "/rt/libbotlish_runtime.a", "-liconv", "-lSystem", "-lc", "-lm"]);
        assert!(args.iter().all(|a| !a.contains("group") && !a.contains("-pie") && !a.contains("--")));
    }

    /// Microsoft's: link.exe's own spelling, no incremental linking (its
    /// thunks would move a function's address off its code), the static
    /// release C runtime and every other one excluded, as for the rustc
    /// linker's executables (`crt_args_for`).
    #[test]
    fn system_link_args_msvc() {
        let ffi = crate::nir::parse(FFI_PROGRAM).unwrap_or_else(|e| panic!("{}", e.message));
        let objects = [Path::new("C:\\w\\program.obj")];
        let args = texts(&system_link_args(LinkerFlavor::Msvc, &objects, Path::new("C:\\rt\\botlish_runtime.lib"), Path::new("C:\\w d\\executable.exe"), &ffi, &resolved(LinkerFlavor::Msvc, &ffi), &LinkSearch::libraries(&["C:\\opt lib".to_string()]), Startup::Worker));
        for flag in ["/NOLOGO", "/SUBSYSTEM:CONSOLE", "/INCREMENTAL:NO", "/OPT:REF", "/OUT:C:\\w d\\executable.exe"] {
            assert!(args.contains(&flag.to_string()), "{flag} not in {args:?}");
        }
        let tail: Vec<&str> = args.iter().skip_while(|a| !a.ends_with("program.obj")).map(String::as_str).collect();
        assert_eq!(
            &tail[..12],
            ["C:\\w\\program.obj", "/LIBPATH:C:\\opt lib", "first.lib", "second.lib", "C:\\rt\\botlish_runtime.lib",
             "legacy_stdio_definitions.lib", "kernel32.lib", "ntdll.lib", "userenv.lib", "ws2_32.lib", "dbghelp.lib", "libcmt.lib"]
        );
        let excluded: Vec<&str> = args.iter().filter_map(|a| a.strip_prefix("/NODEFAULTLIB:")).collect();
        assert_eq!(excluded, OTHER_MSVC_RUNTIMES);
        assert!(args.iter().all(|a| !a.starts_with("-l") && !a.starts_with("-L") && !a.contains("-Wl,")));
    }

    /// The main-thread startup's link: LC_MAIN's stack size, 512 MiB, on
    /// Apple's ld (the system linker's argument, the rustc linker's
    /// `-C link-arg=`), and nothing for the worker or for any other linker;
    /// the rest of Apple's link as the worker's (MAIN-THREAD-STARTUP-
    /// MILESTONE-1.md).
    #[test]
    fn main_thread_startup_link_args() {
        assert_eq!(MAIN_THREAD_STACK_BYTES, 0x2000_0000);
        assert_eq!(startup_link_args(LinkerFlavor::Apple, Startup::MainThread), ["-Wl,-stack_size,0x20000000"]);
        for flavor in [LinkerFlavor::Apple, LinkerFlavor::Gnu, LinkerFlavor::Msvc] {
            assert!(startup_link_args(flavor, Startup::Worker).is_empty());
        }
        assert!(startup_link_args(LinkerFlavor::Gnu, Startup::MainThread).is_empty());
        assert!(startup_link_args(LinkerFlavor::Msvc, Startup::MainThread).is_empty());
        let objects = [Path::new("/w/program.o")];
        let link = |program: &Program, startup| {
            texts(&system_link_args(LinkerFlavor::Apple, &objects, Path::new("/rt/libbotlish_runtime.a"), Path::new("/w/executable"),
                program, &resolved(LinkerFlavor::Apple, program), &LinkSearch::default(), startup))
        };
        for program in [plain_program(), crate::nir::parse(FFI_PROGRAM).unwrap_or_else(|e| panic!("{}", e.message))] {
            let main = link(&program, Startup::MainThread);
            let worker = link(&program, Startup::Worker);
            assert_eq!(main.iter().filter(|a| a.contains("stack_size")).collect::<Vec<_>>(), ["-Wl,-stack_size,0x20000000"]);
            assert!(worker.iter().all(|a| !a.contains("stack_size")));
            assert_eq!(main.iter().filter(|a| !a.contains("stack_size")).collect::<Vec<_>>(), worker.iter().collect::<Vec<_>>());
            // Before the output and the objects, with the driver's own flags.
            let at = main.iter().position(|a| a.contains("stack_size")).unwrap();
            assert!(at < main.iter().position(|a| a == "-o").unwrap());
        }
    }

    /// The main-thread policy is refused for every target but macOS AArch64,
    /// before anything is linked, with the target and the reason; the worker
    /// never is.
    #[test]
    fn main_thread_startup_refusal() {
        let program = |target: Option<(&str, &str)>| {
            let line = target.map_or(String::new(), |(name, triple)| format!("target \"{name}\" triple=\"{triple}\"\n"));
            crate::nir::parse(&format!(
                "nir 1 call-effects=1 statics=0\n{line}\nfunc 0 \"<program>\" params=0 env=0 regs=1 pnames=\"\" captures=0\n    %0 = int 42\n    ret %0\nend\n"
            ))
            .unwrap_or_else(|e| panic!("{}", e.message))
        };
        let macos = program(Some(("macos-aarch64", "aarch64-apple-darwin")));
        assert_eq!(startup_refusal(&macos, Startup::MainThread), None);
        for (name, triple, why) in [
            ("linux-x86_64", "x86_64-unknown-linux-gnu", "glibc reports no guard"),
            ("linux-aarch64", "aarch64-unknown-linux-gnu", "glibc reports no guard"),
            ("windows-x86_64", "x86_64-pc-windows-msvc", "1 MiB link.exe reserves"),
            ("macos-x86_64", "x86_64-apple-darwin", "macOS AArch64 native executables only"),
        ] {
            let other = program(Some((name, triple)));
            let refusal = startup_refusal(&other, Startup::MainThread).unwrap_or_else(|| panic!("{name} accepted"));
            assert!(refusal.contains("macOS AArch64 native executables only") && refusal.contains(name) && refusal.contains(why), "{refusal}");
            assert!(refusal.contains("-native-startup worker"), "{refusal}");
            assert_eq!(startup_refusal(&other, Startup::Worker), None);
        }
        // A program every target shares is the host's.
        let shared = program(None);
        assert_eq!(startup_refusal(&shared, Startup::MainThread).is_none(), botlish_native::runtime::aot::MAIN_THREAD_STARTUP);
        assert_eq!(startup_refusal(&shared, Startup::Worker), None);
    }

    /// One member of an `ar` archive: its 60-byte header and data, padded to
    /// an even length.
    fn member(name: &str, data: &[u8]) -> Vec<u8> {
        let mut m = format!("{name:<16}{:<12}{:<6}{:<6}{:<8}{:<10}`\n", 0, 0, 0, 644, data.len()).into_bytes();
        m.extend_from_slice(data);
        if m.len() % 2 == 1 {
            m.push(b'\n');
        }
        m
    }

    fn archive_file(members: &[Vec<u8>]) -> PathBuf {
        let mut bytes = b"!<arch>\n".to_vec();
        for m in members {
            bytes.extend_from_slice(m);
        }
        let path = std::env::temp_dir().join(format!("botlish-archive-test-{}-{}.a", std::process::id(), members.len() * 7 + bytes.len()));
        std::fs::write(&path, bytes).unwrap();
        path
    }

    /// The driver's own runtime archive is beside it, except in a macOS
    /// application bundle, whose Contents/MacOS holds code only: there it
    /// is the bundle's Contents/Resources/ one.
    #[test]
    fn packaged_runtime_archive_follows_the_driver() {
        let at = |driver: &str, bundles: bool| packaged_runtime_archive(Path::new(driver), bundles).unwrap();
        let archive = RUNTIME_ARCHIVE;
        assert_eq!(at("/a/native/target/release/botlish-native", true), Path::new("/a/native/target/release").join(archive));
        assert_eq!(at("/x/My Apps/Botlish.app/Contents/MacOS/botlish-native", true), Path::new("/x/My Apps/Botlish.app/Contents/Resources").join(archive));
        // Only on a host that has bundles, and only in Contents/MacOS.
        assert_eq!(at("/x/Botlish.app/Contents/MacOS/botlish-native", false), Path::new("/x/Botlish.app/Contents/MacOS").join(archive));
        assert_eq!(at("/x/Other/MacOS/botlish-native", true), Path::new("/x/Other/MacOS").join(archive));
        assert_eq!(at("MacOS/botlish-native", true), Path::new("MacOS").join(archive));
    }

    /// A runtime archive missing from the macOS application is the
    /// application's damage (reinstall it), never a build to run: its user
    /// has no checkout and no Rust. Every other driver names the build.
    #[test]
    fn runtime_remedy_is_the_distributions() {
        let bundled = runtime_remedy(Path::new("/x/My Apps/Botlish.app/Contents/MacOS/botlish-native"), true);
        assert!(bundled.contains("reinstall"), "{bundled}");
        for toolchain in ["cargo", "rustc", "rustup", "Rust"] {
            assert!(!bundled.contains(toolchain), "{bundled}");
        }
        assert_eq!(runtime_remedy(Path::new("/x/Botlish.app/Contents/MacOS/botlish-native"), false), RUNTIME_BUILT);
        assert_eq!(runtime_remedy(Path::new("/a/native/target/release/botlish-native"), true), RUNTIME_BUILT);
    }

    /// The runtime archive's first object names its format and
    /// architecture, whatever symbol and name tables (GNU's, BSD's, Microsoft's
    /// import members) come before it; anything else is damaged.
    #[test]
    fn runtime_archive_machine_is_its_first_objects() {
        let mut elf = vec![0u8; 64];
        elf[..4].copy_from_slice(b"\x7fELF");
        elf[4] = 2;
        let with = |e: &mut Vec<u8>, machine: u16| e[18..20].copy_from_slice(&machine.to_le_bytes());
        let mut x86 = elf.clone();
        with(&mut x86, 62);
        let mut arm = elf.clone();
        with(&mut arm, 183);
        let mut macho = vec![0u8; 32];
        macho[..4].copy_from_slice(&0xfeed_facfu32.to_le_bytes());
        macho[4..8].copy_from_slice(&0x0100_000cu32.to_le_bytes());
        let mut import = vec![0u8; 32];
        import[2..4].copy_from_slice(&0xffffu16.to_le_bytes());
        let mut coff = vec![0u8; 32];
        coff[..2].copy_from_slice(&0x8664u16.to_le_bytes());
        let cases = [
            (vec![member("/", &[0; 12]), member("//", b"a_long_member_name.o/\n"), member("/0", &x86)], Ok("ELF x86-64")),
            (vec![member("/", &[0; 12]), member("x.o/", &arm)], Ok("ELF AArch64")),
            (vec![member("__.SYMDEF SORTED", &[0; 8]), member("#1/12", &[b"name.o\0\0\0\0\0\0".as_slice(), &macho].concat())], Ok("Mach-O arm64")),
            (vec![member("/", &[0; 8]), member("/", &[0; 8]), member("//", b"x\0"), member("k.dll/", &import), member("a.o/", &coff)], Ok("COFF x86-64")),
            (vec![member("/", &[0; 8])], Err("damaged static library (no object file found)")),
        ];
        for (members, expected) in cases {
            let path = archive_file(&members);
            let got = archive_machine(&path);
            let _ = std::fs::remove_file(&path);
            assert_eq!(got.as_deref().map_err(String::as_str), expected);
        }
        let path = std::env::temp_dir().join(format!("botlish-archive-test-{}-text", std::process::id()));
        std::fs::write(&path, b"not an archive at all").unwrap();
        assert_eq!(archive_machine(&path), Err("not a static library (no !<arch> header)".to_string()));
        let _ = std::fs::remove_file(&path);
    }

    /// A failed link's undefined runtime helper, in each linker's words, is
    /// the runtime archive's fault; an undefined symbol of the program's own
    /// plan, or a helper's name inside another, is not.
    #[test]
    fn undefined_helper_names_the_runtime_helper() {
        for output in [
            "/usr/bin/ld: program.o: in function `botlish_fn_0':\n(.text+0x1c): undefined reference to `rt_int_add'",
            "ld.lld: error: undefined symbol: rt_int_add\n>>> referenced by program.o",
            "Undefined symbols for architecture arm64:\n  \"_rt_int_add\", referenced from:\n      _botlish_fn_0 in program.o",
            "program.obj : error LNK2019: unresolved external symbol rt_int_add referenced in function botlish_fn_0",
        ] {
            assert_eq!(undefined_helper(output), Some("rt_int_add"), "{output}");
        }
        assert_eq!(undefined_helper("undefined reference to `botlish_no_such_symbol'"), None);
        assert_eq!(undefined_helper("undefined reference to `rt_int_add_twice'"), None);
        // One helper's name is another's prefix (rt_co_resume, rt_co_resume0).
        assert_eq!(undefined_helper("ld.lld: error: undefined symbol: rt_co_resume0\n>>> referenced by program.o"), Some("rt_co_resume0"));
    }

    /// The linker's words that mean no linker could run, not a failed link.
    #[test]
    fn missing_linker_is_a_toolchain_failure() {
        for line in [
            "collect2: fatal error: cannot find 'ld'",
            "clang: error: unable to execute command: Executable \"ld\" doesn't exist!",
            "xcrun: error: invalid active developer path (/Library/Developer/CommandLineTools), missing xcrun at: /Library/Developer/CommandLineTools/usr/bin/xcrun",
            "xcode-select: note: No developer tools were found, requesting install.",
            "xcrun: error: unable to find utility \"ld\", not a developer tool or in PATH",
            "clang: error: invalid linker name in argument '-fuse-ld=lld'",
        ] {
            assert_eq!(missing_linker_lines(&format!("noise\n  {line}\n")), Some(line.to_string()));
        }
        assert_eq!(missing_linker_lines("/usr/bin/ld: cannot find -lnope: No such file or directory\ncollect2: error: ld returned 1 exit status"), None);
    }

    /// A missing toolchain's remedy is the platform's C toolchain, never
    /// Rust: the system linker runs no Rust, and a packaged compiler's user
    /// has none (MACOS-AARCH64-MILESTONE-9.md).
    #[test]
    fn toolchain_remedy_is_the_platforms() {
        for flavor in [LinkerFlavor::Gnu, LinkerFlavor::Apple, LinkerFlavor::Msvc] {
            let remedy = toolchain_remedy(flavor).to_lowercase();
            assert!(!remedy.contains("rust") && !remedy.contains("cargo"), "{remedy}");
        }
        assert!(toolchain_remedy(LinkerFlavor::Apple).contains("xcode-select --install"));
        assert!(toolchain_remedy(LinkerFlavor::Gnu).contains("apt install gcc"));
    }

    /// An ordinary program passes the linker nothing.
    #[test]
    fn ffi_link_plan_is_empty_without_c() {
        let text = FFI_PROGRAM.replace("link \"first\"\n", "").replace("link \"second\"\n", "")
            .replace("foreign 0 \"c_add\" params=\"i32 i32\" result=i32 name=\"m::add\"\n", "")
            .replace("%2 = foreigncall 0 %0 %1", "%2 = int 42");
        let program = crate::nir::parse(&text).unwrap_or_else(|e| panic!("{}", e.message));
        assert!(!calls_c(&program));
        assert!(link_plan_args(&program, &[], &LinkSearch::libraries(&["/opt/lib".to_string()])).is_empty());
    }

    // ------------------------------------- the link plan (NATIVE-LINK-PLAN-MILESTONE-1.md)

    /// FFI_PROGRAM with its link plan replaced by the header lines LINKS.
    fn with_links(links: &str) -> Program {
        let text = FFI_PROGRAM.replace("link \"first\"\nlink \"second\"\n", links);
        crate::nir::parse(&text).unwrap_or_else(|e| panic!("{}", e.message))
    }

    /// A private scratch directory of this test process, removed when the
    /// value is dropped -- also when its test fails.
    struct Scratch(PathBuf);

    impl std::ops::Deref for Scratch {
        type Target = PathBuf;
        fn deref(&self) -> &PathBuf {
            &self.0
        }
    }

    impl Drop for Scratch {
        fn drop(&mut self) {
            let _ = std::fs::remove_dir_all(&self.0);
        }
    }

    fn scratch(name: &str) -> Scratch {
        let dir = std::env::temp_dir().join(format!("botlish-link-plan-{}-{name}", std::process::id()));
        let _ = std::fs::remove_dir_all(&dir);
        std::fs::create_dir_all(&dir).unwrap();
        Scratch(dir)
    }

    /// An ELF64 object header of MACHINE (62 x86-64, 183 AArch64) and type
    /// KIND (1 relocatable, 3 shared).
    fn elf(machine: u16, kind: u16) -> Vec<u8> {
        let mut e = vec![0u8; 64];
        e[..4].copy_from_slice(b"\x7fELF");
        e[4] = 2;
        e[16..18].copy_from_slice(&kind.to_le_bytes());
        e[18..20].copy_from_slice(&machine.to_le_bytes());
        e
    }

    /// A relocatable ELF object of the machine a GNU-flavor link is for
    /// (`flavor_machine`: the host's on Linux AArch64, x86-64 elsewhere).
    fn gnu_object() -> Vec<u8> {
        elf(if flavor_machine(LinkerFlavor::Gnu) == "ELF AArch64" { 183 } else { 62 }, 1)
    }

    /// An ELF object of the other Linux architecture than `gnu_object`'s.
    fn foreign_gnu_object() -> (Vec<u8>, &'static str) {
        if flavor_machine(LinkerFlavor::Gnu) == "ELF AArch64" { (elf(62, 1), "ELF x86-64") } else { (elf(183, 1), "ELF AArch64") }
    }

    /// An archive file NAME in DIR of MEMBERS.
    fn archive_at(dir: &Path, name: &str, members: &[Vec<u8>]) -> PathBuf {
        let mut bytes = b"!<arch>\n".to_vec();
        for m in members {
            bytes.extend_from_slice(m);
        }
        let path = dir.join(name);
        std::fs::write(&path, bytes).unwrap();
        path
    }

    /// The header lines of every kind of dependency parse into the plan, in
    /// order; anything else is invalid NIR -- a name that could be an
    /// option, a path a source could not write, a framework with a
    /// library's words.
    #[test]
    fn link_plan_header_lines_parse() {
        let program = with_links(concat!(
            "link \"m\"\n",
            "link \"SDL3\" static\n",
            "link \"fx\" static path=\"native/lib fx.a\" base=\"/app root\"\n",
            "framework \"Cocoa\"\n",
        ));
        assert_eq!(
            program.links,
            vec![
                Link::Library("m".into()),
                Link::Static { name: "SDL3".into(), archive: None },
                Link::Static {
                    name: "fx".into(),
                    archive: Some(crate::nir::ArchivePath { written: "native/lib fx.a".into(), base: "/app root".into() })
                },
                Link::Framework("Cocoa".into()),
            ]
        );
        // A plan of static libraries or frameworks only, calling nothing, is
        // still a program that calls C: the system linker's, never the stub's.
        let declares_only = |links: &str| {
            let text = FFI_PROGRAM
                .replace("link \"first\"\nlink \"second\"\n", links)
                .replace("foreign 0 \"c_add\" params=\"i32 i32\" result=i32 name=\"m::add\"\n", "")
                .replace("%2 = foreigncall 0 %0 %1", "%2 = int 42");
            crate::nir::parse(&text).unwrap_or_else(|e| panic!("{}", e.message))
        };
        for links in ["link \"z\" static\n", "link \"z\" static path=\"libz.a\" base=\"/a\"\n", "framework \"Metal\"\n"] {
            let program = declares_only(links);
            assert!(program.foreigns.is_empty() && calls_c(&program), "{links}");
            assert_eq!(linker_named(Some("auto"), &program, true), Ok(Linker::System), "{links}");
        }
        for bad in [
            "link \"-Wl,--wrap=x\"\n",
            "link \"\"\n",
            "link \"x\" shared\n",
            "link \"x\" static path=\"\" base=\"/a\"\n",
            "link \"x\" static path=\"a\\\\b.a\" base=\"/a\"\n",
            "link \"x\" static path=\"dir/\" base=\"/a\"\n",
            "link \"x\" static base=\"/a\" path=\"x.a\"\n",
            "framework \"Cocoa\" static\n",
            "framework \"-framework\"\n",
        ] {
            let text = FFI_PROGRAM.replace("link \"first\"\nlink \"second\"\n", bad);
            assert!(crate::nir::parse(&text).is_err(), "{bad:?} parsed");
        }
    }

    /// Every dependency kind as each linker is given it: a static archive by
    /// its absolute path inside GNU's group, among Apple's libraries, as a
    /// link.exe input; a framework as Apple's `-framework NAME` pair after
    /// the libraries, with -F directories after the -L ones; frameworks and
    /// framework directories are Apple's alone.
    #[test]
    fn link_plan_static_archives_and_frameworks_lower_per_linker() {
        let dir = scratch("lower");
        let path = archive_at(&dir, "libfx.a", &[member("fx.o/", &gnu_object())]);
        let inputs = vec![
            LinkInput::Library("m".into()),
            LinkInput::Archive { name: "fx".into(), path: path.clone(), from: ArchiveSource::Declared("libfx.a".into()) },
            LinkInput::Framework("Cocoa".into()),
        ];
        let program = with_links("link \"m\"\nlink \"fx\" static\nframework \"Cocoa\"\n");
        let search = LinkSearch { libraries: vec!["/opt/lib".into()], frameworks: vec!["/opt/My Frameworks".into()] };
        let shown = |args: Vec<String>| args.into_iter().filter(|a| a != "-C").collect::<Vec<_>>();
        let fx = format!("link-arg={}", path.display());
        assert_eq!(
            shown(link_plan_args_for(LinkerFlavor::Apple, &program, &inputs, &search)),
            ["default-linker-libraries=yes", "link-arg=-L/opt/lib", "link-arg=-F/opt/My Frameworks", "link-arg=-lm", &fx, "link-arg=-framework", "link-arg=Cocoa"]
        );
        let unframed = vec![inputs[0].clone(), inputs[1].clone()];
        assert_eq!(
            shown(link_plan_args_for(LinkerFlavor::Gnu, &program, &unframed, &search)),
            ["default-linker-libraries=yes", "link-arg=-L/opt/lib", "link-arg=-Wl,--start-group", "link-arg=-lm", &fx, "link-arg=-Wl,--end-group"]
        );
        assert_eq!(
            shown(link_plan_args_for(LinkerFlavor::Msvc, &program, &unframed, &search)),
            ["default-linker-libraries=yes", "link-arg=/LIBPATH:/opt/lib", "link-arg=m.lib", &fx]
        );
        // The system linker's arguments carry the same plan, unwrapped: the
        // archive one argument, a framework two.
        let objects = [Path::new("/w/program.o")];
        let args = texts(&system_link_args(LinkerFlavor::Apple, &objects, Path::new("/rt/libbotlish_runtime.a"), Path::new("/w/executable"), &program, &inputs, &search, Startup::Worker));
        let tail: Vec<&str> = args.iter().skip_while(|a| *a != "/w/program.o").map(String::as_str).collect();
        assert_eq!(&tail[..8], ["/w/program.o", "-L/opt/lib", "-F/opt/My Frameworks", "-lm", path.to_str().unwrap(), "-framework", "Cocoa", "/rt/libbotlish_runtime.a"]);
        // Frameworks never reach another linker: resolution refuses them.
        for flavor in [LinkerFlavor::Gnu, LinkerFlavor::Msvc] {
            let error = resolve_link_plan_with(flavor, &with_links("framework \"Cocoa\"\n"), &LinkSearch::default(), &mut Vec::new).unwrap_err();
            assert_eq!(error.detail, Some("ARCHIVE"));
            assert!(error.message.contains("Apple framework"), "{}", error.message);
        }
        assert_eq!(
            describe_link_plan_for(LinkerFlavor::Gnu, &with_links("link \"m\"\nlink \"z\" static\nlink \"fx\" static path=\"native/libfx.a\" base=\"/a\"\nframework \"Metal\"\n")),
            "symbols c_add; libraries -lm libz.a (static) native/libfx.a (static); frameworks Metal"
        );
    }

    /// A declared archive is its path joined to the application root (an
    /// absolute path as it is), never the working directory's: so a written
    /// path that starts with `-` is still an absolute path, never an option.
    /// A relative path without a root is refused, as is a missing file.
    #[test]
    fn link_plan_declared_archives_resolve_from_the_application_root() {
        let root = scratch("root dir ü");
        std::fs::create_dir_all(root.join("native")).unwrap();
        let fx = archive_at(&root.join("native"), "-libfx.a", &[member("fx.o/", &gnu_object())]);
        // As native/lower.tcl's Quote writes a path into NIR text.
        let quoted = |p: &Path| p.display().to_string().replace('\\', "\\\\");
        let base = quoted(&root);
        let gnu = |links: &str| resolve_link_plan_with(LinkerFlavor::Gnu, &with_links(links), &LinkSearch::default(), &mut Vec::new);
        let inputs = gnu(&format!("link \"fx\" static path=\"native/-libfx.a\" base=\"{base}\"\n")).unwrap_or_else(|e| panic!("{}", e.message));
        assert_eq!(inputs, vec![LinkInput::Archive { name: "fx".into(), path: root.join("native/-libfx.a"), from: ArchiveSource::Declared("native/-libfx.a".into()) }]);
        let args = plan_args(LinkerFlavor::Gnu, &with_links(&format!("link \"fx\" static path=\"native/-libfx.a\" base=\"{base}\"\n")), &[]);
        assert!(args.iter().filter_map(|a| a.strip_prefix("link-arg=")).all(|a| a.starts_with("-Wl,") || Path::new(a).is_absolute()), "{args:?}");
        let absolute = gnu(&format!("link \"fx\" static path=\"{}\" base=\"\"\n", fx.display().to_string().replace('\\', "/"))).unwrap_or_else(|e| panic!("{}", e.message));
        let fx = PathBuf::from(fx.display().to_string().replace('\\', "/"));
        assert!(matches!(&absolute[0], LinkInput::Archive { path, .. } if *path == fx));
        for (links, words) in [
            ("link \"fx\" static path=\"native/-libfx.a\" base=\"\"\n".to_string(), "has none"),
            ("link \"fx\" static path=\"native/-libfx.a\" base=\"relative/root\"\n".to_string(), "has none"),
            (format!("link \"fx\" static path=\"native/missing.a\" base=\"{base}\"\n"), "does not exist"),
            (format!("link \"fx\" static path=\"native\" base=\"{base}\"\n"), "is not a file"),
        ] {
            let error = gnu(&links).unwrap_err();
            assert_eq!(error.detail, Some("ARCHIVE"), "{links}");
            assert!(error.message.contains(words), "{links}: {}", error.message);
        }
    }

    /// A static library declared without a path is the first libNAME.a of the
    /// -L directories, then of the toolchain's (asked once, and only when no
    /// -L directory has one) -- never a shared library of that name, which
    /// the refusal names when it is there instead.
    #[test]
    fn link_plan_searched_archives_never_take_a_shared_library() {
        let first = scratch("search-first");
        let second = scratch("search-second");
        let system = scratch("search-system");
        std::fs::write(first.join("libfx.so"), elf(62, 3)).unwrap();
        archive_at(&second, "libfx.a", &[member("fx.o/", &gnu_object())]);
        let program = with_links("link \"fx\" static\n");
        let search = LinkSearch::libraries(&[first.display().to_string(), second.display().to_string()]);
        let mut asked = 0;
        let found = resolve_link_plan_with(LinkerFlavor::Gnu, &program, &search, &mut || {
            asked += 1;
            vec![system.to_path_buf()]
        })
        .unwrap_or_else(|e| panic!("{}", e.message));
        assert_eq!(asked, 0);
        assert_eq!(found, vec![LinkInput::Archive { name: "fx".into(), path: second.join("libfx.a"), from: ArchiveSource::Searched(second.clone()) }]);
        // Only the shared library on the -L path: the toolchain's directories
        // are asked, and an archive there is taken.
        let only = LinkSearch::libraries(&[first.display().to_string()]);
        let none = resolve_link_plan_with(LinkerFlavor::Gnu, &program, &only, &mut || {
            asked += 1;
            vec![system.to_path_buf()]
        })
        .unwrap_err();
        assert_eq!(asked, 1);
        assert!(none.message.contains("libfx.so is a shared library") && none.message.contains(&system.display().to_string()), "{}", none.message);
        archive_at(&system, "libfx.a", &[member("fx.o/", &gnu_object())]);
        let defaulted = resolve_link_plan_with(LinkerFlavor::Gnu, &program, &only, &mut || vec![system.to_path_buf()]).unwrap_or_else(|e| panic!("{}", e.message));
        assert!(matches!(&defaulted[0], LinkInput::Archive { from: ArchiveSource::Searched(d), .. } if *d == *system));
        // Each linker's names: libNAME.a; NAME.lib for link.exe.
        assert_eq!(static_archive_name(LinkerFlavor::Apple, "SDL3"), "libSDL3.a");
        assert_eq!(static_archive_name(LinkerFlavor::Msvc, "SDL3-static"), "SDL3-static.lib");
    }

    /// What a static declaration's file must be: an archive of objects of
    /// the linked machine, and no import library -- never a shared
    /// library, a text stub, a linker script, a thin archive or another
    /// architecture's objects.
    #[test]
    fn link_plan_archive_facts_refuse_what_is_no_static_archive() {
        let dir = scratch("facts");
        let check = |name: &str, bytes: &[u8], flavor: LinkerFlavor| -> Result<(), String> {
            let path = dir.join(name);
            std::fs::write(&path, bytes).unwrap();
            check_static_archive(flavor, flavor_machine(flavor), "fx", &path, "test").map_err(|e| e.message)
        };
        let archive = |members: &[Vec<u8>]| {
            let mut bytes = b"!<arch>\n".to_vec();
            for m in members {
                bytes.extend_from_slice(m);
            }
            bytes
        };
        let mut macho_dylib = vec![0u8; 32];
        macho_dylib[..4].copy_from_slice(&0xfeed_facfu32.to_le_bytes());
        macho_dylib[4..8].copy_from_slice(&0x0100_000cu32.to_le_bytes());
        macho_dylib[12..16].copy_from_slice(&6u32.to_le_bytes());
        let mut macho_object = macho_dylib.clone();
        macho_object[12..16].copy_from_slice(&1u32.to_le_bytes());
        let mut coff = vec![0u8; 20 + 40];
        coff[..2].copy_from_slice(&0x8664u16.to_le_bytes());
        coff[2..4].copy_from_slice(&1u16.to_le_bytes());
        coff[20..28].copy_from_slice(b".text\0\0\0");
        let mut idata = coff.clone();
        idata[20..28].copy_from_slice(b".idata$5");
        let mut short_import = vec![0u8; 32];
        short_import[2..4].copy_from_slice(&0xffffu16.to_le_bytes());
        let ok = |r: Result<(), String>| r.unwrap_or_else(|e| panic!("{e}"));
        let refused = |r: Result<(), String>, words: &str| {
            let e = r.unwrap_err();
            assert!(e.contains(words), "{words:?} not in {e}");
        };
        ok(check("gnu.a", &archive(&[member("/", &[0; 8]), member("fx.o/", &gnu_object())]), LinkerFlavor::Gnu));
        refused(check("so.a", &elf(62, 3), LinkerFlavor::Gnu), "ELF shared library");
        refused(check("thin.a", b"!<thin>\n", LinkerFlavor::Gnu), "thin archive");
        refused(check("script.a", b"/* GNU ld script */\nGROUP ( libfx.so.1 )\n", LinkerFlavor::Gnu), "linker script");
        let (foreign, foreign_machine) = foreign_gnu_object();
        refused(check("arm.a", &archive(&[member("fx.o/", &foreign)]), LinkerFlavor::Gnu), foreign_machine);
        refused(check("mixed.a", &archive(&[member("a.o/", &gnu_object()), member("b.o/", &foreign)]), LinkerFlavor::Gnu), foreign_machine);
        refused(check("empty.a", &archive(&[member("/", &[0; 8])]), LinkerFlavor::Gnu), "no object file");
        ok(check("apple.a", &archive(&[member("__.SYMDEF SORTED", &[0; 8]), member("#1/8", &[b"fx.o\0\0\0\0".as_slice(), &macho_object].concat())]), LinkerFlavor::Apple));
        refused(check("dylib.a", &macho_dylib, LinkerFlavor::Apple), "Mach-O dynamic library");
        refused(check("tbd.a", b"--- !tapi-tbd\ntbd-version: 4\n", LinkerFlavor::Apple), "text-based stub");
        refused(check("elf.a", &archive(&[member("fx.o/", &gnu_object())]), LinkerFlavor::Apple), "ELF");
        ok(check("static.lib", &archive(&[member("/", &[0; 8]), member("fx.obj/", &coff)]), LinkerFlavor::Msvc));
        refused(check("import.lib", &archive(&[member("/", &[0; 8]), member("fx.dll/", &short_import), member("fx.dll/", &idata)]), LinkerFlavor::Msvc), "import library: 2 of its members");
        refused(check("longimport.lib", &archive(&[member("fx.dll/", &idata)]), LinkerFlavor::Msvc), "import library");
        refused(check("dll.lib", b"MZ\x90\0", LinkerFlavor::Msvc), "Windows executable or DLL");
        // A universal file: its arm64 slice, on Apple's linker only.
        let slice = archive(&[member("#1/8", &[b"fx.o\0\0\0\0".as_slice(), &macho_object].concat())]);
        let mut fat = Vec::new();
        fat.extend_from_slice(&0xcafe_babeu32.to_be_bytes());
        fat.extend_from_slice(&2u32.to_be_bytes());
        let offset = 4096u32;
        for (cpu, at) in [(0x0100_0007u32, offset), (0x0100_000cu32, offset)] {
            for word in [cpu, 0, at, slice.len() as u32, 12] {
                fat.extend_from_slice(&word.to_be_bytes());
            }
        }
        fat.resize(offset as usize, 0);
        fat.extend_from_slice(&slice);
        ok(check("fat.a", &fat, LinkerFlavor::Apple));
        refused(check("fat-gnu.a", &fat, LinkerFlavor::Gnu), "universal file");
        let mut x86_only = fat.clone();
        x86_only[8 + 20..8 + 24].copy_from_slice(&0x0100_0007u32.to_be_bytes());
        refused(check("fat-x86.a", &x86_only, LinkerFlavor::Apple), "without an arm64 slice");
    }

    /// The toolchain's own library directories, from the C driver's and GNU
    /// ld's words.
    #[test]
    fn link_plan_default_dirs_read_the_toolchains_words() {
        let gcc = "install: /usr/lib/gcc/x86_64-linux-gnu/13/\nprograms: =/usr/libexec/gcc\nlibraries: =/usr/lib/gcc/x86_64-linux-gnu/13/:/lib/x86_64-linux-gnu/:/usr/lib/\n";
        assert_eq!(gnu_driver_dirs(gcc), ["/usr/lib/gcc/x86_64-linux-gnu/13/", "/lib/x86_64-linux-gnu/", "/usr/lib/"].map(PathBuf::from));
        let ld = "SEARCH_DIR(\"=/usr/local/lib/x86_64-linux-gnu\"); SEARCH_DIR(\"=/usr/local/lib\"); SEARCH_DIR(\"/opt/x\");";
        assert_eq!(gnu_script_dirs(ld), ["/usr/local/lib/x86_64-linux-gnu", "/usr/local/lib", "/opt/x"].map(PathBuf::from));
        assert!(gnu_driver_dirs("no such line").is_empty());
    }
}
