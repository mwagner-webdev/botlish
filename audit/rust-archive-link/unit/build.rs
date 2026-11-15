// The fixture's build script, with no build dependency (std only):
//
// * the notification object: packages/http/native/src/notify.c -- the http
//   unit's own weak reference to botlish_event_post2 -- or the file
//   RUSTLINK_NOTIFY names, compiled by the host's C compiler ($CC, else
//   cc) into one archive that rustc bundles into the static library, as the
//   cc crate does for botlish_http (its paths mapped out; on Apple targets
//   the deployment target rustc's own, 11.0 unless
//   MACOSX_DEPLOYMENT_TARGET says otherwise);
// * RUSTLINK_RUSTC: the compiler's version, which rl_toolchain reports
//   (the unit and the Botlish runtime may be built by different rustc
//   versions; the tests say which).
use std::path::PathBuf;
use std::process::Command;

fn run(cmd: &mut Command) {
    let status = cmd.status().unwrap_or_else(|e| panic!("cannot run {cmd:?}: {e}"));
    assert!(status.success(), "{cmd:?} failed: {status}");
}

fn main() {
    let manifest = PathBuf::from(std::env::var("CARGO_MANIFEST_DIR").unwrap());
    let out = PathBuf::from(std::env::var("OUT_DIR").unwrap());
    let target = std::env::var("TARGET").unwrap();
    let notify = match std::env::var("RUSTLINK_NOTIFY") {
        Ok(path) if !path.is_empty() => PathBuf::from(path),
        _ => manifest.join("../../../packages/http/native/src/notify.c"),
    };
    let notify = notify.canonicalize().unwrap_or_else(|e| panic!("{}: {e}", notify.display()));
    println!("cargo:rerun-if-changed={}", notify.display());
    println!("cargo:rerun-if-env-changed=RUSTLINK_NOTIFY");
    println!("cargo:rerun-if-env-changed=CC");
    println!("cargo:rerun-if-env-changed=MACOSX_DEPLOYMENT_TARGET");

    let cc = std::env::var("CC").ok().filter(|s| !s.is_empty()).unwrap_or_else(|| "cc".to_string());
    let object = out.join("rustlink_notify.o");
    let dir = notify.parent().unwrap();
    let mut compile = Command::new(&cc);
    compile.args(["-O2", "-fPIC", "-Wall", "-Wextra", "-Werror", "-c"]);
    compile.arg(format!("-ffile-prefix-map={}=/rustlink", dir.display()));
    compile.arg(format!("-ffile-prefix-map={}=/out", out.display()));
    if target.contains("apple") {
        let min = std::env::var("MACOSX_DEPLOYMENT_TARGET").unwrap_or_else(|_| "11.0".to_string());
        compile.arg(format!("-mmacosx-version-min={min}"));
    }
    compile.arg(&notify).arg("-o").arg(&object);
    run(&mut compile);

    // One member, written deterministically (rustc copies the member into
    // the static library with its own deterministic header either way).
    let archive = out.join("librustlink_notify.a");
    let _ = std::fs::remove_file(&archive);
    let mut ar = Command::new("ar");
    if target.contains("apple") {
        ar.env("ZERO_AR_DATE", "1").arg("crs");
    } else {
        ar.arg("crsD");
    }
    ar.arg(&archive).arg(&object);
    run(&mut ar);
    println!("cargo:rustc-link-search=native={}", out.display());
    println!("cargo:rustc-link-lib=static=rustlink_notify");

    let rustc = std::env::var("RUSTC").unwrap_or_else(|_| "rustc".to_string());
    let version = Command::new(rustc).arg("--version").output().expect("rustc --version");
    let text = String::from_utf8_lossy(&version.stdout).trim().to_string();
    println!("cargo:rustc-env=RUSTLINK_RUSTC={text}");
}
