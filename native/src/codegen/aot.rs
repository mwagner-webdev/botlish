//! Linux x86-64/glibc executable linking. Cranelift emits the program object;
//! rustc compiles a small data initializer and statically links our runtime.
//! The executable needs neither Tcl, rustc, the source nor this checkout.
use super::{Const, ObjectProgram, emit_object};
use crate::nir::Program;
use std::fmt::Write;
use std::path::{Path, PathBuf};
use std::process::Command;

struct WorkDir(PathBuf);

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
         framemap::{FunctionMap, ProgramMap}, metrics::AllocMode, value::{Kind, Value},\n\
         vm::{FunctionInfo, NativeInfo, ProgramInfo, ShapeInfo, Vm}}};\n\
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
        use std::os::unix::ffi::OsStringExt;\n\
        let argv: Vec<Vec<u8>> = std::env::args_os().map(|a| a.into_vec()).collect();\n\
        std::process::exit(aot::run(argv, || {\n\
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
            "ShapeInfo {{ name: {name}, fields: vec!{:?}.into_iter().map(String::from).collect(), opaque: {} }},",
            shape.fields, shape.opaque
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

pub fn emit_executable(program: &Program, destination: &Path) -> Result<(), String> {
    if !cfg!(all(target_arch = "x86_64", target_os = "linux", target_env = "gnu")) {
        return Err("executable emission requires Linux x86_64 glibc".into());
    }
    let driver = std::env::current_exe().map_err(|e| e.to_string())?;
    let release = driver.parent().ok_or("cannot locate native runtime")?;
    let library = release.join("libbotlish_native.rlib");
    if !library.is_file() {
        return Err(format!(
            "runtime library missing: {}; run cargo build --release --manifest-path native/Cargo.toml",
            library.display()
        ));
    }
    let destination = std::path::absolute(destination).map_err(|e| e.to_string())?;
    let parent = destination.parent().ok_or("output has no parent directory")?;
    let nonce = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .map_err(|e| e.to_string())?
        .as_nanos();
    let work = parent.join(format!(".botlish-aot-{}-{nonce}", std::process::id()));
    std::fs::create_dir(&work).map_err(|e| format!("{}: {e}", work.display()))?;
    let work = WorkDir(work);
    let object = emit_object(program).map_err(|e| e.message().to_string())?;
    let object_path = work.0.join("program.o");
    let source_path = work.0.join("startup.rs");
    let executable = work.0.join("executable");
    std::fs::write(&object_path, &object.bytes).map_err(|e| e.to_string())?;
    std::fs::write(&source_path, startup(program, &object)).map_err(|e| e.to_string())?;
    let output = Command::new(std::env::var_os("RUSTC").unwrap_or_else(|| "rustc".into()))
        .arg("--edition=2024")
        .arg("--crate-name=botlish_program")
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
        .arg(&source_path)
        .arg("-o")
        .arg(&executable)
        .output()
        .map_err(|e| format!("cannot launch rustc to link executable: {e}"))?;
    if !output.status.success() {
        return Err(format!(
            "executable link failed ({}):\n{}",
            output.status,
            String::from_utf8_lossy(&output.stderr)
        ));
    }
    // Publish only a successfully linked file, on the same filesystem. A
    // failed build leaves any previous executable intact.
    std::fs::rename(&executable, &destination).map_err(|e| format!("{}: {e}", destination.display()))?;
    Ok(())
}
