//! The compilation target as the native backend sees it.
//!
//! A program's target is the front end's (core/cabi.tcl): an operating
//! system *and* an architecture, named to the driver by its target triple
//! (NIR's `target "NAME" triple="TRIPLE"` line, present when the program's
//! HIR depends on its target). Two targets of one architecture are still two
//! targets: linux-aarch64 and macos-aarch64 share an instruction set, not an
//! operating system, a C ABI or an object format.
//!
//! Botlish owns the triple. Cranelift owns what it means for the machine
//! ABI: the C calling convention (`c_call_conv`), register assignment, stack
//! argument placement and the extension of narrow arguments. Nothing here
//! spells a register or a stack slot.
//!
//! Three kinds of call, three conventions:
//!
//!   * Botlish-to-Botlish calls (`clif::signature_n`): the ISA's default
//!     convention, `module.make_signature()`. Internal to one compilation;
//!     the platform C ABI does not bind them, and a foreign target never
//!     changes them.
//!   * runtime helper calls (`rt_*`, `clif::declare`): the ISA's default
//!     convention, which is the host's C convention -- the helpers are Rust
//!     `extern "C"` functions compiled for this host.
//!   * foreign C calls (`clif::c_signature`): the C convention of the target
//!     triple, `c_call_conv` -- AppleAarch64 for aarch64-apple-darwin,
//!     SystemV for Linux, WindowsFastcall for Windows. Machine code is only
//!     made for the host's own target (`check_host`), so this is the host's
//!     platform C convention, stated where foreign signatures are built
//!     instead of left implicit.

use cranelift_codegen::isa::CallConv;
use std::str::FromStr;
use target_lexicon::{OperatingSystem, Triple};

/// The C calling convention of a foreign C function on the platform of
/// TRIPLE: Cranelift's platform default for it (`CallConv::triple_default`),
/// AppleAarch64 on Apple AArch64, never the generic AArch64 SystemV one.
pub fn c_call_conv(triple: &Triple) -> CallConv {
    CallConv::triple_default(triple)
}

/// How many of a foreign C signature's integer-register parameters -- every
/// class but a double, counted in order -- carry their narrow integer's
/// extension attribute (`sext`/`uext`, `clif::c_signature`) in convention
/// CONV: every one, except under AppleAarch64, where only the eight passed
/// in registers do.
///
/// Apple's arm64 ABI ("Writing ARM64 code for Apple platforms") makes the
/// caller sign- or zero-extend an argument narrower than 32 bits to 32 bits
/// *in its register*, and gives an argument passed on the stack a slot of
/// its natural size, packed at its natural alignment (a `char` one byte):
/// a stack slot has nothing to extend into. Cranelift 0.135.2 implements
/// both, but stores an extended *stack* argument at the full register width
/// into its narrow slot (machinst/abi.rs `gen_call_args`: an 8-byte `str`
/// at a 1-, 2- or 4-byte slot's offset). Stored in parameter order, each
/// such store spills over into the next argument's slots before that
/// argument is stored, but the last one can write up to seven bytes past
/// the argument area, into the calling function's own frame -- in the
/// reduced case, the explicit stack slot right above it, the kind Botlish
/// keeps roots and call scratch in (MACOS-AARCH64-MILESTONE-6.md, section
/// 9). A parameter without an attribute
/// is stored at its natural width, which is exactly Apple's contract for a
/// stack argument, so the attribute is left off the stack-passed ones.
/// Cranelift 0.136.0 fixed the store the same way (its `get_ext_mode` takes
/// the argument's location and extends only register arguments under
/// AppleAarch64): with that upgrade this exception goes, which
/// `clif::apple_tests::ffi_apple_extended_stack_argument_defect_still_present`
/// will say by failing.
///
/// Every C ABI class a foreign call passes but a double is one
/// general-purpose register (an integer, a `_Bool`, a pointer: no
/// aggregate or 128-bit value), and a double takes a floating-point one
/// (FLOAT64-MILESTONE-1.md). AAPCS64's register assignment, which Apple
/// keeps, counts the two kinds separately: the first eight integer-register
/// parameters are x0-x7 however many doubles come before or between them
/// (v0-v7), and every later one is on the stack -- so the count is of those
/// parameters, never of a parameter's position. Botlish places nothing: the
/// slots and registers stay Cranelift's. Elsewhere every narrow parameter keeps its attribute (SysV
/// x86-64's stack slots are eight bytes, and Cranelift ignores the attribute
/// for Linux AArch64's AAPCS64, whose callee extends).
pub fn c_extended_parameters(conv: CallConv) -> usize {
    match conv {
        CallConv::AppleAarch64 => 8,
        _ => usize::MAX,
    }
}

/// The operating system family of OS, as targets distinguish them.
fn os_family(os: OperatingSystem) -> String {
    if os.is_like_darwin() {
        return "darwin".to_string();
    }
    match os {
        OperatingSystem::Linux => "linux".to_string(),
        OperatingSystem::Windows => "windows".to_string(),
        other => other.to_string(),
    }
}

/// Whether machine code for TARGET runs on HOST: the same architecture, the
/// same operating system *and* the same environment -- the C toolchain's ABI
/// family, which on Windows tells MSVC's `x86_64-pc-windows-msvc` from
/// MinGW-w64's `x86_64-pc-windows-gnu` (core/cabi.tcl: windows-x86_64 and
/// windows-x86_64-gnu are two targets, and this driver, built for one of
/// them, links executables with that one's C runtime and linker only). A
/// matching architecture (or pointer width) is not a matching target, and
/// neither is a matching architecture and operating system.
pub fn same_target(target: &Triple, host: &Triple) -> bool {
    target.architecture == host.architecture
        && os_family(target.operating_system) == os_family(host.operating_system)
        && target.environment == host.environment
}

/// TEXT as a target triple, or why it is not one.
pub fn parse_triple(text: &str) -> Result<Triple, String> {
    Triple::from_str(text).map_err(|e| format!("invalid target triple \"{text}\": {e}"))
}

/// Ok if PROGRAM was built for this host (or for no target in particular),
/// else the NATIVE TARGET refusal's message: the driver runs and emits
/// machine code for its own host only, and never treats a program built for
/// another target as the host's.
pub fn check_host(program: &crate::nir::Program) -> Result<(), String> {
    let Some(target) = &program.target else { return Ok(()) };
    let triple = parse_triple(&target.triple)?;
    let host = Triple::host();
    if same_target(&triple, &host) {
        return Ok(());
    }
    let shared = if triple.architecture != host.architecture {
        String::new()
    } else if os_family(triple.operating_system) == os_family(host.operating_system) {
        format!(
            " Both are {} {}, but the C toolchain environment is part of the target: {} for this program, {} here.",
            host.architecture,
            os_family(host.operating_system),
            triple.environment,
            host.environment
        )
    } else {
        format!(" Both are {}, but a matching architecture is not a matching target.", host.architecture)
    };
    Err(format!(
        "this program was built for target {} ({}), and native code runs only on its own target's host: \
         this host is {host}.{shared} Compile the program for this host (main.tcl -target, or the host's \
         default), or run it on a Tcl backend",
        target.name, target.triple
    ))
}

/// The driver's `target TRIPLE` report, a Tcl list: TRIPLE's architecture,
/// operating system, pointer width, object format and C calling convention
/// as Cranelift and target-lexicon read them, the host's triple, and whether
/// machine code for TRIPLE runs here.
pub fn describe(text: &str) -> Result<Vec<String>, String> {
    let triple = parse_triple(text)?;
    let host = Triple::host();
    let pointer = triple.pointer_width().map(|w| w.bits().to_string()).unwrap_or_else(|_| "unknown".into());
    Ok(vec![
        "target".into(),
        text.to_string(),
        "arch".into(),
        triple.architecture.to_string(),
        "os".into(),
        os_family(triple.operating_system),
        "pointer".into(),
        pointer,
        "format".into(),
        triple.binary_format.to_string(),
        "c-call-conv".into(),
        c_call_conv(&triple).to_string(),
        "host".into(),
        host.to_string(),
        "runs".into(),
        if same_target(&triple, &host) { "1" } else { "0" }.into(),
    ])
}

#[cfg(test)]
mod tests {
    use super::*;

    fn conv(text: &str) -> CallConv {
        c_call_conv(&parse_triple(text).unwrap())
    }

    // The triples of core/cabi.tcl's seven targets (tests/target-model.test
    // checks the table's triples against this driver's `target` report).
    #[test]
    fn c_call_conv_is_the_platform_c_convention_of_each_target() {
        assert_eq!(conv("aarch64-apple-darwin"), CallConv::AppleAarch64);
        assert_eq!(conv("aarch64-unknown-linux-gnu"), CallConv::SystemV);
        assert_eq!(conv("x86_64-unknown-linux-gnu"), CallConv::SystemV);
        assert_eq!(conv("x86_64-apple-darwin"), CallConv::SystemV);
        assert_eq!(conv("x86_64-pc-windows-msvc"), CallConv::WindowsFastcall);
        assert_eq!(conv("x86_64-pc-windows-gnu"), CallConv::WindowsFastcall);
        assert_eq!(conv("aarch64-pc-windows-msvc"), CallConv::WindowsFastcall);
    }

    #[test]
    fn apple_aarch64_is_not_the_linux_aarch64_convention() {
        assert_ne!(conv("aarch64-apple-darwin"), conv("aarch64-unknown-linux-gnu"));
    }

    #[test]
    fn same_architecture_is_not_same_target() {
        let linux = parse_triple("aarch64-unknown-linux-gnu").unwrap();
        let macos = parse_triple("aarch64-apple-darwin").unwrap();
        let x86 = parse_triple("x86_64-unknown-linux-gnu").unwrap();
        assert!(!same_target(&macos, &linux));
        assert!(!same_target(&linux, &macos));
        assert!(!same_target(&x86, &linux));
        assert!(same_target(&linux, &linux));
        assert!(same_target(&macos, &parse_triple("arm64-apple-darwin").unwrap()));
    }

    /// Windows x86-64 with MSVC's toolchain and with MinGW-w64's are two
    /// targets: one architecture, one operating system, one C convention,
    /// two environments. A driver built for one never runs or links code for
    /// the other.
    #[test]
    fn the_windows_environments_are_two_targets() {
        let msvc = parse_triple("x86_64-pc-windows-msvc").unwrap();
        let gnu = parse_triple("x86_64-pc-windows-gnu").unwrap();
        assert_eq!(c_call_conv(&msvc), c_call_conv(&gnu));
        assert!(!same_target(&gnu, &msvc));
        assert!(!same_target(&msvc, &gnu));
        assert!(same_target(&msvc, &msvc));
        assert!(same_target(&gnu, &gnu));
        // Linux and macOS are unchanged: their triples' environments agree
        // with this driver's own on those hosts.
        assert!(same_target(&parse_triple("x86_64-unknown-linux-gnu").unwrap(), &parse_triple("x86_64-unknown-linux-gnu").unwrap()));
        assert!(!same_target(&parse_triple("x86_64-unknown-linux-gnu").unwrap(), &msvc));
    }

    /// The table's target of this driver's own host runs here, and the other
    /// Windows environment, on a Windows host, is refused with its reason.
    #[test]
    fn the_host_runs_its_own_target_only() {
        let host = Triple::host();
        assert!(same_target(&host, &host));
        if host.operating_system == OperatingSystem::Windows {
            let other = if host.environment.to_string() == "msvc" { "x86_64-pc-windows-gnu" } else { "x86_64-pc-windows-msvc" };
            let d = describe(other).unwrap();
            assert_eq!(d[d.iter().position(|x| x == "runs").unwrap() + 1], "0");
        }
    }

    /// A program built for the other environment of this host's own
    /// architecture and operating system (Windows: MinGW's for an MSVC
    /// driver; Linux: musl's for a glibc one) is refused before any code is
    /// made, and the refusal names the environments.
    #[cfg(any(target_os = "linux", target_os = "windows"))]
    #[test]
    fn another_environment_of_the_hosts_system_is_refused() {
        let host = Triple::host().to_string();
        let other = match host.as_str() {
            "x86_64-pc-windows-msvc" => "x86_64-pc-windows-gnu".to_string(),
            "x86_64-pc-windows-gnu" => "x86_64-pc-windows-msvc".to_string(),
            linux => linux.replace("-gnu", "-musl"),
        };
        let body = "func 0 \"<program>\" params=0 env=0 regs=1 pnames=\"\" captures=0\n    %0 = int 7\n    ret %0\nend\n";
        let program = crate::nir::parse(&format!("nir 1\ntarget \"other\" triple=\"{other}\"\n\n{body}")).unwrap();
        let message = check_host(&program).unwrap_err();
        assert!(message.contains("but the C toolchain environment is part of the target"), "{message}");
        let own = crate::nir::parse(&format!("nir 1\ntarget \"own\" triple=\"{host}\"\n\n{body}")).unwrap();
        assert!(check_host(&own).is_ok());
    }

    #[test]
    fn describe_reports_the_targets_facts() {
        let d = describe("aarch64-apple-darwin").unwrap();
        let get = |k: &str| d[d.iter().position(|x| x == k).unwrap() + 1].clone();
        assert_eq!(get("arch"), "aarch64");
        assert_eq!(get("os"), "darwin");
        assert_eq!(get("pointer"), "64");
        assert_eq!(get("format"), "macho");
        assert_eq!(get("c-call-conv"), "apple_aarch64");
        assert!(describe("not a triple at all").is_err());
    }
}
