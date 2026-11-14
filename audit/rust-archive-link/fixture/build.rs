// The unit's build script: the C shim (src/notify.c, and src/fallback.c
// when the provider reference is a weak definition), compiled by the C
// compiler in $CC (else cc) and bundled into the staticlib, as the http
// unit's build script bundles its notify.c -- without the cc crate, so the
// fixture has no dependency at all.
//
// RLF_NOTIFY chooses how notify.c reaches the provider's rlfp_post:
//   weakdef  (default) a weak definition in fallback.c returning -ENOSYS,
//            which a provider's strong definition replaces at link time
//   weakref  a weak reference, tested for null (the http unit's notify.c)
//   strong   a plain reference: no provider, no link
use std::path::Path;
use std::process::Command;

fn main() {
    for f in ["src/notify.c", "src/fallback.c"] {
        println!("cargo:rerun-if-changed={f}");
    }
    println!("cargo:rerun-if-env-changed=RLF_NOTIFY");
    println!("cargo:rerun-if-env-changed=CC");
    println!("cargo:rerun-if-env-changed=CFLAGS");
    let mode = std::env::var("RLF_NOTIFY").unwrap_or_else(|_| "weakdef".into());
    let define = match mode.as_str() {
        "weakdef" => "RLF_NOTIFY_WEAKDEF",
        "weakref" => "RLF_NOTIFY_WEAKREF",
        "strong" => "RLF_NOTIFY_STRONG",
        other => panic!("RLF_NOTIFY={other}: weakdef, weakref or strong"),
    };
    let out = std::env::var("OUT_DIR").unwrap();
    let out = Path::new(&out);
    let cc = std::env::var("CC").unwrap_or_else(|_| "cc".into());
    let extra: Vec<String> = std::env::var("CFLAGS").unwrap_or_default().split_whitespace().map(String::from).collect();
    let mut sources = vec!["src/notify.c"];
    if mode == "weakdef" {
        sources.push("src/fallback.c");
    }
    let mut objects = Vec::new();
    for src in &sources {
        let obj = out.join(Path::new(src).file_stem().unwrap()).with_extension("o");
        let status = Command::new(&cc)
            .args(["-O2", "-fPIC", "-Wall", "-Wextra", "-Werror", "-c"])
            .arg(format!("-D{define}"))
            .args(&extra)
            .arg(src)
            .arg("-o")
            .arg(&obj)
            .status()
            .expect("running the C compiler");
        assert!(status.success(), "compiling {src}");
        objects.push(obj);
    }
    let lib = out.join("librlf_shim.a");
    let _ = std::fs::remove_file(&lib);
    // ar's deterministic mode where the host's ar has it (GNU, llvm-ar);
    // Apple's ar zeroes dates under ZERO_AR_DATE. The tool (rust-unit.tcl)
    // sets both.
    let ar = std::env::var("AR").unwrap_or_else(|_| "ar".into());
    let flags = if std::env::var("TARGET").unwrap_or_default().contains("apple") { "rcs" } else { "rcsD" };
    let status = Command::new(&ar).arg(flags).arg(&lib).args(&objects).status().expect("running ar");
    assert!(status.success(), "archiving the shim");
    println!("cargo:rustc-link-search=native={}", out.display());
    println!("cargo:rustc-link-lib=static=rlf_shim");
}
