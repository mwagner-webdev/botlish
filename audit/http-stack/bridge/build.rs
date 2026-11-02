// The weak reference to the Linux driver's botlish_event_post (notify.c):
// a foreign-thread wake posts a record through the integration ABI when the
// program links the driver, and is refused (ENOSYS) when it does not (the
// deterministic driver has no endpoints).
fn main() {
    println!("cargo:rerun-if-changed=src/notify.c");
    cc::Build::new().file("src/notify.c").warnings(true).compile("hs_notify");
}
