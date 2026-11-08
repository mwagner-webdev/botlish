//! The runtime archive's target triple (cargo's TARGET), which its identity
//! record states (src/lib.rs, runtime::aotimage::identity_record).
fn main() {
    let target = std::env::var("TARGET").expect("cargo sets TARGET for a build script");
    println!("cargo:rustc-env=BOTLISH_RUNTIME_TRIPLE={target}");
    println!("cargo:rerun-if-changed=build.rs");
}
