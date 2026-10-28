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
use super::{ObjectProgram, emit_object};
use crate::nir::Program;
use botlish_native::runtime::aotimage::{self, Fixup, Image, Target};
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
/// and `botlish_program` record (runtime::program,
/// NATIVE-LIBRARY-MILESTONE-1.md, "One startup") -- so the crate only names
/// the record and hands it to `program::instantiate_linked` on the thread
/// `aot::run` starts, as the stub linker's loader and a native library do.
const STARTUP: &str = "\
use botlish_native::runtime::{aot, program};
unsafe extern \"C\" {
    static botlish_program: program::LinkedProgram;
}
fn main() {
    std::process::exit(aot::run(aot::process_argv(), || {
        // SAFETY: the record the program object defines, relocated by this link.
        match unsafe { program::instantiate_linked(&*std::ptr::addr_of!(botlish_program)) } {
            Ok(started) => started,
            Err(error) => {
                eprintln!(\"{error} (NATIVE STARTUP)\");
                std::process::exit(1);
            }
        }
    }));
}
";

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

/// Links PROGRAM as a standalone executable at `executable_path(DESTINATION)`
/// and returns that path (absolute).
pub fn emit_executable(program: &Program, destination: &Path, link_dirs: &[String]) -> Result<PathBuf, LinkError> {
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
        Linker::Rustc => link_rustc(program, &destination, link_dirs)?,
        Linker::Stub if calls_c(program) => {
            return Err(format!(
                "native link failed: this program calls C or declares a C library ({}), which only the system linker resolves, and the stub linker (BOTLISH_NATIVE_LINKER=stub) links no native library: link it with the system linker (BOTLISH_NATIVE_LINKER=system or auto, the single executable's: a C compiler driver and the runtime archive) or the rustc linker of a Botlish checkout (BOTLISH_NATIVE_LINKER=rustc; C-FFI.md)",
                describe_link_plan(program)
            )
            .into());
        }
        Linker::Stub => link_stub(program, &destination)?,
        Linker::System => link_system(program, &destination, link_dirs)?,
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
    if !program.links.is_empty() {
        let libraries: Vec<String> = program.links.iter().map(|l| library_argument(flavor, l)).collect();
        parts.push(format!("libraries {}", libraries.join(" ")));
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
/// against this build's runtime library.
fn link_rustc(program: &Program, destination: &Path, link_dirs: &[String]) -> Result<(), String> {
    let driver = std::env::current_exe().map_err(|e| e.to_string())?;
    let release = driver.parent().ok_or("cannot locate native runtime")?;
    let library = release.join("libbotlish_native.rlib");
    if !library.is_file() {
        return Err(format!(
            "runtime library missing: {}; run cargo build --release --manifest-path native/Cargo.toml",
            library.display()
        ));
    }
    let work = WorkDir::beside(destination)?;
    let object = emit_object(program).map_err(|e| e.message().to_string())?;
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
        .args(link_plan_args(program, link_dirs))
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
            ));
        }
        return Err(format!("executable link failed ({}):\n{}", output.status, stderr));
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

/// rustc's arguments passing PROGRAM's link plan to this host's system
/// linker (`link_plan_args_for`).
fn link_plan_args(program: &Program, link_dirs: &[String]) -> Vec<String> {
    link_plan_args_for(LINKER, program, link_dirs)
}

/// rustc's arguments passing PROGRAM's link plan to a FLAVOR system linker:
/// the search directories LINK_DIRS (`-LDIR`), then every library
/// `-lNAME`, in the plan's order -- for GNU ld inside one linker group,
/// for Apple's ld as they are; for link.exe in its own spelling,
/// `/LIBPATH:DIR` and `NAME.lib`, and no group: link.exe searches every
/// library until nothing more resolves, in any order. Nothing for a program
/// that names none.
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
fn link_plan_args_for(flavor: LinkerFlavor, program: &Program, link_dirs: &[String]) -> Vec<String> {
    let mut args = Vec::new();
    if !calls_c(program) {
        return args;
    }
    args.extend(["-C".to_string(), "default-linker-libraries=yes".to_string()]);
    if flavor == LinkerFlavor::Msvc {
        for dir in link_dirs {
            args.extend(["-C".to_string(), format!("link-arg=/LIBPATH:{dir}")]);
        }
        for library in &program.links {
            args.extend(["-C".to_string(), format!("link-arg={}", library_argument(flavor, library))]);
        }
        return args;
    }
    for dir in link_dirs {
        args.extend(["-C".to_string(), format!("link-arg=-L{dir}")]);
    }
    if !program.links.is_empty() {
        let group = flavor == LinkerFlavor::Gnu;
        if group {
            args.extend(["-C".to_string(), "link-arg=-Wl,--start-group".to_string()]);
        }
        for library in &program.links {
            args.extend(["-C".to_string(), format!("link-arg=-l{library}")]);
        }
        if group {
            args.extend(["-C".to_string(), "link-arg=-Wl,--end-group".to_string()]);
        }
    }
    args
}

/// The `stub` linker: the prebuilt `botlish-aot-stub` with the program's
/// image appended (runtime/aotimage.rs).
fn link_stub(program: &Program, destination: &Path) -> Result<(), String> {
    // `image` lays out and relocates an ELF x86-64 object (its relocation
    // types and call trampolines are x86-64's), and the stub's loader is
    // built for x86-64 Linux only (runtime/aotimage.rs). No Mach-O stub:
    // macOS executables are the system linker's.
    if !cfg!(all(target_os = "linux", target_arch = "x86_64")) {
        return Err("the stub linker supports x86_64 Linux only: use BOTLISH_NATIVE_LINKER=rustc".into());
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
    let object = emit_object(program).map_err(|e| e.message().to_string())?;
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
    link_dirs: &[String],
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
    let plan = link_plan_args_for(flavor, program, link_dirs);
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
fn link_system(program: &Program, destination: &Path, link_dirs: &[String]) -> Result<(), LinkError> {
    let runtime = runtime_archive()?;
    let tool = system_linker(LINKER)?;
    let work = WorkDir::beside(destination)
        .map_err(|e| format!("native link failed: cannot write the executable {}: {e}", destination.display()))?;
    let object = emit_object(program).map_err(|e| e.message().to_string())?;
    let object_path = work.0.join(if LINKER == LinkerFlavor::Msvc { "program.obj" } else { "program.o" });
    let executable = work.0.join(format!("executable{}", std::env::consts::EXE_SUFFIX));
    std::fs::write(&object_path, &object.bytes).map_err(|e| e.to_string())?;
    let args = system_link_args(LINKER, &[&object_path], &runtime, &executable, program, link_dirs);
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
            for dir in link_dirs.iter().filter(|dir| !Path::new(dir).is_dir()) {
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
        let args = link_plan_args_for(LinkerFlavor::Gnu, &program, &["/opt/lib".to_string()]);
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
        let args = link_plan_args_for(LinkerFlavor::Apple, &program, &["/opt/lib".to_string(), "rel dir".to_string()]);
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
        let args = link_plan_args_for(LinkerFlavor::Msvc, &program, &["C:\\opt\\lib".to_string(), "rel dir".to_string()]);
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
        assert_eq!(link_plan_args(&program, &[]), link_plan_args_for(expected, &program, &[]));
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
        let args = system_link_args(LinkerFlavor::Gnu, &objects, Path::new("/rt/libbotlish_runtime.a"), Path::new("/w d/executable"), &ffi, &["/opt/my lib".to_string()]);
        assert_eq!(
            texts(&args),
            [
                "-pie", "-Wl,--eh-frame-hdr", "-Wl,-z,relro,-z,now", "-Wl,--gc-sections", "-o", "/w d/executable",
                "/w d/program.o", "-L/opt/my lib", "-Wl,--start-group", "-lfirst", "-lsecond",
                "-Wl,--end-group", "/rt/libbotlish_runtime.a", "-lgcc_s", "-lutil", "-lrt", "-lpthread", "-lm", "-ldl", "-lc",
            ]
        );
        // The plan is the rustc linker's, unwrapped.
        let plan: Vec<String> = link_plan_args_for(LinkerFlavor::Gnu, &ffi, &["/opt/my lib".to_string()])
            .into_iter().filter_map(|a| a.strip_prefix("link-arg=").map(String::from)).collect();
        assert!(texts(&args).windows(plan.len()).any(|w| w == plan.as_slice()));
        // A program that calls no C: no plan, the rest as it was.
        let plain = system_link_args(LinkerFlavor::Gnu, &objects, Path::new("/rt/libbotlish_runtime.a"), Path::new("/w d/executable"), &plain_program(), &["/opt/my lib".to_string()]);
        assert!(texts(&plain).iter().all(|a| !a.starts_with("-L") && !a.contains("group") && a != "-lfirst"));
        assert_eq!(texts(&plain).len(), texts(&args).len() - 5);
    }

    /// Apple's: arm64 and the deployment target, -dead_strip, no GNU flag.
    #[test]
    fn system_link_args_apple_has_no_gnu_flags() {
        let ffi = crate::nir::parse(FFI_PROGRAM).unwrap_or_else(|e| panic!("{}", e.message));
        let objects = [Path::new("/w/program.o")];
        let args = texts(&system_link_args(LinkerFlavor::Apple, &objects, Path::new("/rt/libbotlish_runtime.a"), Path::new("/w/executable"), &ffi, &["/opt/lib".to_string()]));
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
        let args = texts(&system_link_args(LinkerFlavor::Msvc, &objects, Path::new("C:\\rt\\botlish_runtime.lib"), Path::new("C:\\w d\\executable.exe"), &ffi, &["C:\\opt lib".to_string()]));
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
        assert!(link_plan_args(&program, &["/opt/lib".to_string()]).is_empty());
    }
}
