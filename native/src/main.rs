//! botlish-native: the native backend driver.
//!
//! ```text
//!   botlish-native run FILE.nir          compile (Cranelift JIT) and run
//!   botlish-native bench RUNS FILE.nir   compile once, run RUNS times
//!   botlish-native clif FILE.nir         print the Cranelift IR of every function
//!   botlish-native size FILE.nir         compile; print machine code sizes
//!   botlish-native roots FILE.nir        print each function's GC-root report
//!                                        (codegen::roots): NIR/raw/managed
//!                                        register counts, safepoints, root
//!                                        candidates, max simultaneous live
//!                                        roots, and the shadow-slot count
//!                                        they were colored into. Parses and
//!                                        analyzes only -- never compiles.
//!   botlish-native object OUT FILE.nir   write an object file (AOT smoke test)
//!   botlish-native check FILE.nir        parse and validate only
//! ```
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
//! Native code runs on a thread with a large stack; the shadow stack bounds
//! the call depth (NATIVE LIMIT STACK).

mod codegen;
mod nir;
mod runtime;

use codegen::{Backend, CompileOptions, CraneliftJit, Site};
use runtime::metrics::{kind_name, AllocMode, SiteStats};
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

fn cli(args: &[String]) -> i32 {
    let usage = || {
        eprintln!("usage: botlish-native run|clif|size|roots|check FILE.nir [--alloc off|summary|sites] | bench RUNS FILE.nir [--alloc ...] | object OUT FILE.nir");
        2
    };
    let Some((args, alloc_mode)) = extract_alloc_mode(args) else { return usage() };
    let args = &args[..];
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
        ("run" | "clif" | "size" | "roots" | "check", [file, ..]) => (1, file),
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
        "roots" => {
            emit(&codegen::roots::report(&program));
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
        _ => execute(command, &program, runs, alloc_mode),
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

fn execute(command: &str, program: &nir::Program, runs: usize, alloc_mode: AllocMode) -> i32 {
    let started = Instant::now();
    let mut backend = CraneliftJit;
    let options = CompileOptions { clif: command == "clif", alloc_sites: alloc_mode.sites() };
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
    if command == "size" {
        let sizes: Vec<String> = compiled.code_sizes.iter().map(|n| n.to_string()).collect();
        let total: u32 = compiled.code_sizes.iter().sum();
        emit(&tcl_list(&["size".to_string(), total.to_string(), tcl_list(&sizes)]));
        return 0;
    }

    let mut vm = Vm::new(Rc::new(program_info(program)), alloc_mode);
    compiled.install_constants(&mut vm);
    let mut best = u128::MAX;
    let mut result = NO_VALUE;
    let mut nanos: Vec<u128> = Vec::with_capacity(runs);
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
    if alloc_mode.enabled() {
        let sites = alloc_mode.sites().then(|| sites_tcl(&compiled.sites, &vm.metrics.sites)).unwrap_or_default();
        emit(&format!("alloc {}", vm.metrics.to_tcl(&sites)));
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
