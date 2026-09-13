//! botlish-native: the native backend driver.
//!
//! ```text
//!   botlish-native run FILE.nir          compile (Cranelift JIT) and run
//!   botlish-native bench RUNS FILE.nir   compile once, run RUNS times
//!   botlish-native clif FILE.nir         print the Cranelift IR of every function
//!   botlish-native object OUT FILE.nir   write an object file (AOT smoke test)
//!   botlish-native check FILE.nir        parse and validate only
//! ```
//!
//! FILE may be - for standard input. Output is UTF-8, one Tcl list per line:
//!
//! ```text
//!   value VALUE                 VALUE: the host runtime value (core/value.tcl)
//!   error ERRORCODE MESSAGE     a Botlish error, or {NATIVE ...} for backend failures
//!   timing COMPILE_US BEST_US RUNS COLLECTIONS    (bench, before the result)
//! ```
//!
//! Native code runs on a thread with a large stack; the shadow stack bounds
//! the call depth (NATIVE LIMIT STACK).

mod codegen;
mod nir;
mod runtime;

use codegen::{Backend, CompileOptions, CraneliftJit};
use runtime::show::{tcl_list, tcl_value};
use runtime::value::NO_VALUE;
use runtime::vm::{FunctionInfo, NativeInfo, ProgramInfo, Vm};
use std::io::{Read, Write};
use std::rc::Rc;
use std::time::Instant;

fn main() {
    let args: Vec<String> = std::env::args().skip(1).collect();
    let worker = std::thread::Builder::new().stack_size(1 << 30).spawn(move || cli(&args)).expect("thread");
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
    std::process::exit(status);
}

fn emit(line: &str) {
    let mut out = std::io::stdout().lock();
    out.write_all(line.as_bytes()).unwrap();
    out.write_all(b"\n").unwrap();
    out.flush().unwrap();
}

fn emit_error(code: &[&str], message: &str) {
    let code: Vec<String> = code.iter().map(|s| s.to_string()).collect();
    emit(&tcl_list(&["error".to_string(), tcl_list(&code), message.to_string()]));
}

fn read(path: &str) -> Result<String, String> {
    if path == "-" {
        let mut text = String::new();
        std::io::stdin().read_to_string(&mut text).map_err(|e| e.to_string())?;
        return Ok(text);
    }
    std::fs::read_to_string(path).map_err(|e| format!("{path}: {e}"))
}

fn cli(args: &[String]) -> i32 {
    let usage = || {
        eprintln!("usage: botlish-native run|clif|check FILE.nir | bench RUNS FILE.nir | object OUT FILE.nir");
        2
    };
    let (command, rest) = match args.split_first() {
        Some((c, rest)) => (c.as_str(), rest),
        None => return usage(),
    };
    let (runs, file) = match (command, rest) {
        ("bench", [runs, file, ..]) => match runs.parse::<usize>() {
            Ok(n) if n > 0 => (n, file),
            _ => return usage(),
        },
        ("object", [_, file, ..]) => (1, file),
        ("run" | "clif" | "check", [file, ..]) => (1, file),
        _ => return usage(),
    };
    let text = match read(file) {
        Ok(text) => text,
        Err(e) => {
            emit_error(&["NATIVE", "IO"], &e);
            return 2;
        }
    };
    let program = match nir::parse(&text) {
        Ok(p) => p,
        Err(e) => {
            emit_error(&["NATIVE", "INVALID-NIR"], &e.to_string());
            return 0;
        }
    };
    match command {
        "check" => {
            emit("ok");
            0
        }
        "object" => {
            let out = &rest[0];
            match codegen::emit_object(&program) {
                Ok((bytes, pool)) => {
                    if let Err(e) = std::fs::write(out, &bytes) {
                        emit_error(&["NATIVE", "IO"], &e.to_string());
                        return 2;
                    }
                    emit(&tcl_list(&[
                        "object".to_string(),
                        out.clone(),
                        bytes.len().to_string(),
                        pool.entries.len().to_string(),
                    ]));
                    0
                }
                Err(e) => {
                    emit_error(&e.error_code().split(' ').collect::<Vec<_>>(), e.message());
                    0
                }
            }
        }
        _ => execute(command, &program, runs),
    }
}

fn program_info(program: &nir::Program) -> ProgramInfo {
    ProgramInfo {
        functions: program
            .functions
            .iter()
            .map(|f| FunctionInfo { arity: f.params as usize, pnames: f.pnames.clone() })
            .collect(),
        natives: program
            .natives
            .iter()
            .map(|n| NativeInfo { name: n.name.clone(), arity: n.arity, params: n.params.clone(), op: n.op })
            .collect(),
    }
}

fn execute(command: &str, program: &nir::Program, runs: usize) -> i32 {
    let started = Instant::now();
    let mut backend = CraneliftJit;
    let compiled = match backend.compile(program, &CompileOptions { clif: command == "clif" }) {
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

    let mut vm = Vm::new(Rc::new(program_info(program)));
    compiled.install_constants(&mut vm);
    let mut best = u128::MAX;
    let mut result = NO_VALUE;
    for run in 0..runs {
        if run > 0 {
            vm.reset();
        }
        let started = Instant::now();
        result = (compiled.entry)(&mut *vm);
        best = best.min(started.elapsed().as_micros());
        if result == NO_VALUE {
            break;
        }
    }
    if command == "bench" {
        emit(&format!("timing {compile_us} {best} {runs} {}", vm.heap.collections));
    }
    if result == NO_VALUE {
        let error = vm.error.take().unwrap_or(runtime::error::RtError::Bug(
            "native code failed without recording an error".to_string(),
        ));
        emit_error(&error.error_code(), &error.message());
        return 0;
    }
    match tcl_value(result) {
        Ok(value) => emit(&tcl_list(&["value".to_string(), value])),
        Err(error) => emit_error(&error.error_code(), &error.message()),
    }
    0
}
