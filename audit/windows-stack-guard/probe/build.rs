// The probe's C half (fixture.c), compiled by the target's C compiler:
// MSVC's cl on x86_64-pc-windows-msvc (the cc crate finds it), optimized as
// the release profile asks (/O2). Only on Windows, built there: a cross
// check from another host (cargo check --target) compiles no C.
fn main() {
    println!("cargo:rerun-if-changed=fixture.c");
    let windows = std::env::var("CARGO_CFG_TARGET_OS").as_deref() == Ok("windows");
    if windows && std::env::var("HOST") == std::env::var("TARGET") {
        cc::Build::new().file("fixture.c").compile("probe_fixture");
    }
}
