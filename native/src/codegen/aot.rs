//! Standalone executable linking: Linux glibc on x86-64 (both linkers) and
//! AArch64 (the `rustc` linker), ELF; macOS on AArch64 (the `rustc` linker),
//! Mach-O (MACOS-AARCH64-MILESTONE-5.md); Windows on x86-64 with MSVC's
//! toolchain (the `rustc` linker), PE (WINDOWS-X86-64-MILESTONE-1.md).
//! Cranelift emits the program object in the host triple's format; a linker
//! turns it and the runtime into an executable. The executable needs neither
//! Tcl, rustc, the source nor this checkout: only the system's own libraries
//! (on Windows the C runtime is linked statically for it: `crt_args`).
//!
//! Two linkers, chosen by `BOTLISH_NATIVE_LINKER` (SINGLE-EXECUTABLE.md):
//!
//!   * `rustc` (the default): rustc compiles a small data initializer and
//!     statically links our runtime (`libbotlish_native.rlib` beside the
//!     driver), through the system linker.
//!   * `stub`: no toolchain at all. The prebuilt `botlish-aot-stub` (this
//!     runtime and a loader, beside the driver or `BOTLISH_NATIVE_AOT_STUB`)
//!     is copied and the program's image appended to it: the object's
//!     sections laid out and relocated here, by `image` below, into a
//!     `runtime::aotimage::Image` the stub maps at startup. This is how the
//!     single-file compiler (single/) emits executables.
//!
//! Both link the same machine code (`emit_object`) and start it the same way
//! (`runtime::aot::run`); `tests/aot-stub-linker.test` runs programs linked
//! both ways side by side.
//!
//! A program that calls C (C-FFI.md: `foreign` functions, `link` libraries)
//! needs the system linker to resolve its foreign symbols: the `rustc`
//! linker passes the program's link plan to it -- `-lNAME` for every
//! library, in the plan's order, and `-LDIR` for every `--link-dir` search
//! directory -- after the program object, in the platform linker's own
//! terms (`LinkerFlavor`): GNU ld's archive group on Linux, so the order of
//! the declarations never decides a static link; nothing of the kind on
//! macOS, whose ld searches every archive until nothing more resolves
//! (MACOS-AARCH64-MILESTONE-6.md). The `stub` linker links no native library
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
use super::{Const, ObjectProgram, emit_object};
use crate::nir::Program;
use botlish_native::runtime::aotimage::{self, Fixup, FunctionCode, Image, Target};
use std::collections::HashMap;
use std::fmt::Write;
use std::path::{Path, PathBuf};
use std::process::Command;

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

fn startup(program: &Program, object: &ObjectProgram) -> String {
    let mut s = String::from(
        "#![allow(unused_imports)]\n\
         use botlish_native::{nir::OpCode, runtime::{aot, constants::{self, Const},\n\
         framemap::{FunctionMap, ProgramMap}, metrics::AllocMode, value::{FloatType, Kind, Value},\n\
         vm::{EnumInfo, FunctionInfo, NativeInfo, ProgramInfo, ShapeInfo, Vm}}};\n\
         use std::rc::Rc;\n\
         unsafe extern \"C\" {\n",
    );
    for f in &program.functions {
        writeln!(s, "fn botlish_fn_{}(); fn botlish_entry_{}();", f.id, f.id).unwrap();
    }
    s.push_str(
        "}\nextern \"C\" fn entry(vm: *mut Vm) -> Value {\n\
        let f: aot::ProgramEntry = unsafe { std::mem::transmute(botlish_fn_0 as *const ()) };\n\
        f(vm)\n}\nfn main() {\n\
        std::process::exit(aot::run(aot::process_argv(), || {\n\
        let info = ProgramInfo { functions: vec![\n",
    );
    for f in &program.functions {
        writeln!(
            s,
            "FunctionInfo {{ arity: {}, pnames: {:?}.into() }},",
            f.params, f.pnames
        )
        .unwrap();
    }
    s.push_str("], natives: vec![\n");
    for n in &program.natives {
        let params: Vec<String> = n
            .params
            .iter()
            .map(|kind| match kind {
                Some(k) => format!("Some(Kind::{k:?})"),
                None => "None".to_string(),
            })
            .collect();
        writeln!(
            s,
            "NativeInfo {{ name: {:?}.into(), arity: {:?}, params: vec![{}], op: OpCode::{:?} }},",
            n.name,
            n.arity,
            params.join(","),
            n.op
        )
        .unwrap();
    }
    s.push_str("], shapes: vec![\n");
    for shape in &program.shapes {
        let name = match &shape.name {
            Some(n) => format!("Some({n:?}.to_string())"),
            None => "None".to_string(),
        };
        writeln!(
            s,
            "ShapeInfo {{ name: {name}, fields: <Vec<&str>>::into_iter(vec!{:?}).map(String::from).collect(), opaque: {} }},",
            shape.fields, shape.opaque
        )
        .unwrap();
    }
    s.push_str("], enums: vec![\n");
    for e in &program.enums {
        writeln!(
            s,
            "EnumInfo {{ name: {:?}.to_string(), cases: vec!{:?}.into_iter().map(String::from).collect() }},",
            e.name, e.cases
        )
        .unwrap();
    }
    s.push_str("] };\nlet mut vm = Vm::new(Rc::new(info), AllocMode::Off);\nlet entries = vec![\n");
    for f in &program.functions {
        writeln!(s, "botlish_entry_{} as *const () as usize,", f.id).unwrap();
    }
    s.push_str("];\nconstants::install(&mut vm, &[\n");
    for c in &object.pool.entries {
        match c {
            Const::Str(text) => writeln!(s, "Const::Str({text:?}.into()),"),
            Const::Bytes(bytes) => {
                // A byte-string literal of \xNN escapes: compact however large
                // the static storage is, and exact for every byte (NUL, 0xff).
                let literal: String = bytes.iter().map(|b| format!("\\x{b:02x}")).collect();
                writeln!(s, "Const::Bytes(b\"{literal}\".to_vec()),")
            }
            Const::BigInt(text) => writeln!(s, "Const::BigInt({text:?}.into()),"),
            Const::Native(id) => writeln!(s, "Const::Native({id}),"),
            Const::FnValue(id) => writeln!(s, "Const::FnValue({id}),"),
            Const::Float(ty, bits) => writeln!(s, "Const::Float(FloatType::{ty:?}, {bits:#x}),"),
        }
        .unwrap();
    }
    writeln!(
        s,
        "], &entries, {});\nlet mut map = ProgramMap::new();",
        program.statics
    )
    .unwrap();
    for (id, f) in object.functions.iter().enumerate() {
        let points: Vec<String> = f
            .safepoints
            .iter()
            .map(|(pc, roots)| format!("({pc}, vec!{roots:?})"))
            .collect();
        writeln!(
            s,
            "let start = botlish_fn_{id} as *const () as usize;\n\
            map.push(FunctionMap {{ code_start: start, code_end: start + {}, safepoints: vec![{}] }});\n\
            let start = entries[{id}];\n\
            map.push(FunctionMap {{ code_start: start, code_end: start + {}, safepoints: vec![] }});",
            f.direct_size,
            points.join(","),
            f.entry_size
        )
        .unwrap();
    }
    s.push_str("map.finish();\nvm.set_framemap(Rc::new(map));\n(vm, entry as aot::ProgramEntry)\n})); }\n");
    s
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

/// Links PROGRAM as a standalone executable at `executable_path(DESTINATION)`
/// and returns that path (absolute).
pub fn emit_executable(program: &Program, destination: &Path, link_dirs: &[String]) -> Result<PathBuf, String> {
    if !EXECUTABLES {
        return Err("executable emission requires Linux glibc on x86_64 or aarch64, macOS on aarch64, or Windows on x86_64 with the MSVC toolchain".into());
    }
    if calls_c(program) && !C_CALLS {
        return Err(format!(
            "native link failed: this program calls C or declares a C library ({}), and C calls are linked on Linux glibc (x86_64, aarch64), macOS (aarch64) and Windows (x86_64, MSVC) only: on this host executables of programs that call no C are supported, C calls not yet (C-FFI.md)",
            describe_link_plan(program)
        ));
    }
    let destination = std::path::absolute(executable_path(destination)).map_err(|e| e.to_string())?;
    let linked = match std::env::var("BOTLISH_NATIVE_LINKER").as_deref() {
        Err(std::env::VarError::NotPresent) | Ok("" | "rustc") => link_rustc(program, &destination, link_dirs),
        Ok("stub") if calls_c(program) => Err(format!(
            "native link failed: this program calls C or declares a C library ({}), which only the system linker resolves, and the stub linker (BOTLISH_NATIVE_LINKER=stub, the single executable's) links no native library: link it with the rustc linker of a Botlish checkout whose native backend is built (BOTLISH_NATIVE_LINKER=rustc; C-FFI.md)",
            describe_link_plan(program)
        )),
        Ok("stub") => link_stub(program, &destination),
        Ok(other) => Err(format!("unknown BOTLISH_NATIVE_LINKER {other:?} (known: rustc stub)")),
        Err(e) => Err(format!("BOTLISH_NATIVE_LINKER: {e}")),
    };
    linked.map(|()| destination)
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
/// `ld:` lines); Apple's ld and clang on macOS (`Undefined symbols for
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
    std::fs::write(&source_path, startup(program, &object)).map_err(|e| e.to_string())?;
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
    let mut functions = Vec::with_capacity(program.functions.len());
    for (f, compiled) in program.functions.iter().zip(&object.functions) {
        let find = |name: String| defined.get(name.as_str()).copied().ok_or(format!("program object lacks {name}"));
        functions.push(FunctionCode {
            direct: find(format!("botlish_fn_{}", f.id))?,
            direct_size: compiled.direct_size,
            entry: find(format!("botlish_entry_{}", f.id))?,
            entry_size: compiled.entry_size,
            safepoints: compiled.safepoints.clone(),
        });
    }
    Ok(Image {
        info: crate::program_info(program),
        constants: object.pool.entries.clone(),
        statics: program.statics,
        imports,
        code,
        size,
        executable,
        fixups,
        functions,
    })
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
            "          collect2: error: ld returned 1 exit status\n",
        );
        let kept = linker_diagnostics(gnu);
        assert!(kept.contains("undefined reference to `botlish_no_such_symbol'"), "{kept:?}");
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
