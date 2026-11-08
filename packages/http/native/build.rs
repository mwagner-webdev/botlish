// The unit's build script:
//
// * notify.c: the weak reference to the Linux driver's botlish_event_post2
//   (a foreign-thread wake, the name resolver's, posts a record to the
//   program's loop through the event loop's integration ABI, version 2);
// * provider.rs: the reference to the BoringSSL provider's identity symbol
//   (packages/boringssl/native/identity.c), named by
//   BOTLISH_BORINGSSL_PROVIDER (the provider's tag and commit, as the
//   provider package's PIN gives them). The unit is compiled against that
//   provider's headers; linked with any other provider -- or none -- the
//   symbol is undefined and the link fails, instead of running silently
//   against other code (HTTP-SHIPPING-CENSUS.md's B2).
use std::io::Write;

fn main() {
    println!("cargo:rerun-if-changed=src/notify.c");
    println!("cargo:rerun-if-env-changed=BOTLISH_BORINGSSL_PROVIDER");
    cc::Build::new().file("src/notify.c").warnings(true).compile("botlish_http_notify");
    let id = std::env::var("BOTLISH_BORINGSSL_PROVIDER").unwrap_or_default();
    let ok = !id.is_empty() && id.bytes().all(|b| b.is_ascii_alphanumeric() || b == b'_');
    let out = std::path::Path::new(&std::env::var("OUT_DIR").unwrap()).join("provider.rs");
    let mut f = std::fs::File::create(out).unwrap();
    if !ok {
        writeln!(f, "compile_error!(\"BOTLISH_BORINGSSL_PROVIDER must name the BoringSSL provider (tools/package-repository.tcl and tests/cffi/http.tcl set it)\");").unwrap();
        return;
    }
    writeln!(f, "extern \"C\" {{ static botlish_boringssl_{id}: u8; }}").unwrap();
    writeln!(f, "/// The provider this unit was compiled against.").unwrap();
    writeln!(f, "pub const PROVIDER: &str = \"{id}\";").unwrap();
    writeln!(f, "/// Read the provider's identity symbol (its link-time presence is the check).").unwrap();
    writeln!(f, "pub fn check() {{ unsafe {{ std::ptr::read_volatile(std::ptr::addr_of!(botlish_boringssl_{id})); }} }}").unwrap();
}
