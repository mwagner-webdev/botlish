//! Linker-free standalone executables (SINGLE-EXECUTABLE.md): the program
//! image an executable carries, and the loader that runs it.
//!
//! `codegen::aot::emit_executable` links an executable two ways. The `rustc`
//! linker (the default) compiles a generated startup crate against
//! `libbotlish_native.rlib`, so it needs rustc and this checkout's
//! `native/target/release`. The `stub` linker needs neither: it copies the
//! prebuilt `botlish-aot-stub` executable (src/bin/botlish-aot-stub.rs, built
//! by the same `cargo build`: this runtime and a `main` that calls `main`
//! below) and appends this module's [`Image`] of the program to it:
//!
//! ```text
//!   [botlish-aot-stub ELF][image payload][payload length: u64 LE]["BOTLIMG1"]
//! ```
//!
//! The image is the Cranelift object's allocated sections -- the machine
//! code and the program's data, its descriptor among them
//! (runtime::program) -- laid out by `codegen::aot` with every reference
//! inside the image already resolved and the references that need a load
//! address left as [`Fixup`]s, plus where the program's `botlish_program`
//! record lies in it. At startup the stub reads the image back from its own
//! file (`/proc/self/exe`), maps the code into fresh memory next to its own
//! text (so a call to a runtime helper stays a direct `call rel32`), applies
//! the fixups, makes the code executable, and builds the Vm from the record
//! exactly as the rustc linker's startup does (`program::instantiate_linked`),
//! then `aot::run`. Nothing is compiled or interpreted at startup and the
//! machine code is the same Cranelift output either linker links.

use super::aot::ProgramEntry;
use super::program::{LinkedProgram, Reader, Startup, Writer};
use super::vm::Vm;
use std::io::{Read, Seek, SeekFrom};

/// The last 8 bytes of a stub-linked executable.
pub const MAGIC: &[u8; 8] = b"BOTLIMG1";
/// The payload's own format revision, its first word.
const FORMAT: u32 = 2;

/// What a load-time reference points at.
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub enum Target {
    /// A byte offset in the image.
    Local(u64),
    /// A runtime helper, by its index in `Image::imports`.
    Import(u32),
}

/// A reference the stub resolves once it knows where the image and its own
/// runtime helpers are.
#[derive(Clone, Debug, PartialEq, Eq)]
pub enum Fixup {
    /// The 8 bytes at image offset `at` become the target's address plus
    /// `addend` (an absolute data word, or a GOT slot).
    Abs64 { at: u64, target: Target, addend: i64 },
    /// The `call rel32` displacement at image offset `at` becomes
    /// `helper + addend - (image + at)` when the helper is within reach, and
    /// otherwise the same displacement to the image's trampoline for that
    /// helper (`jmp *GOT`, at image offset `trampoline`), which always is.
    Call32 { at: u64, import: u32, addend: i64, trampoline: u64 },
}

pub struct Image {
    /// The runtime helpers the code references, by name.
    pub imports: Vec<String>,
    /// The image's initialized bytes; it is `size` bytes long in memory, the
    /// rest zero (`.bss`).
    pub code: Vec<u8>,
    pub size: u64,
    /// `[0, executable)` is machine code (and trampolines), page-aligned;
    /// everything after it is writable data (the GOT, the program's data,
    /// the context area).
    pub executable: u64,
    pub fixups: Vec<Fixup>,
    /// The image offset of the program's `botlish_program` record
    /// (runtime::program's LinkedProgram), whose pointers the fixups
    /// relocate.
    pub program: u64,
}

/// A digest of the runtime ABI the generated code is compiled against: the
/// Vm and object field offsets it addresses directly and the helpers it
/// calls. The driver records its own in the image; the stub refuses an image
/// recorded by a driver whose runtime differs from its own (a stub and a
/// driver from different builds), since that code would address fields that
/// are not there.
pub fn abi_fingerprint() -> u64 {
    abi_fingerprint_for(RECORD_LAYOUT)
}

/// The program record's layout (runtime::program's LinkedProgram), as the
/// fingerprint covers it: its size and its startup policy's place.
const RECORD_LAYOUT: [u64; 2] =
    [std::mem::size_of::<LinkedProgram>() as u64, std::mem::offset_of!(LinkedProgram, startup) as u64];

/// The fingerprint of this runtime build with a program record of layout
/// RECORD (`RECORD_LAYOUT` for this build's own).
fn abi_fingerprint_for(record: [u64; 2]) -> u64 {
    use super::{bytesobj, strobj, value, vm};
    let mut words: Vec<u64> = vec![
        std::mem::size_of::<Vm>() as u64,
        vm::VM_SS_TOP_OFFSET as u64,
        vm::VM_SS_LIMIT_OFFSET as u64,
        vm::VM_CONSTS_OFFSET as u64,
        vm::VM_ALLOC_SITE_OFFSET as u64,
        vm::VM_NATIVE_ROOTS_PTR_OFFSET as u64,
        vm::VM_NATIVE_ROOTS_LEN_OFFSET as u64,
        vm::VM_STATICS_OFFSET as u64,
        value::CLOSURE_CAPS_OFFSET as u64,
        value::LIST_LEN_OFFSET as u64,
        value::LIST_PTR_OFFSET as u64,
        value::STRUCT_PTR_OFFSET as u64,
        value::MUTARRAY_LEN_OFFSET as u64,
        value::MUTARRAY_PTR_OFFSET as u64,
        value::MUTARRAY_UNIQUE_OFFSET as u64,
        strobj::STR_TEXT_OFFSET as u64,
        strobj::STR_CHARS_OFFSET as u64,
        strobj::STR_BYTE_LEN_OFFSET as u64,
        strobj::STR_ASCII_OFFSET as u64,
        bytesobj::BYTES_PAYLOAD_OFFSET as u64,
        bytesobj::BYTES_LEN_OFFSET as u64,
        value::FLOAT_BITS_OFFSET as u64,
        // The GC root plan the code was generated for (stack maps and the
        // frame walk, or the shadow stack): a `fallback-roots` build's code
        // never runs on a runtime of the other plan.
        u64::from(super::framewalk::NATIVE_FRAME_ROOTS),
        // The program record's own layout (runtime::program's
        // LinkedProgram): its size and its startup policy's place, so a
        // record of another layout is refused by its fingerprint, the second
        // word, before any later word is read
        // (MAIN-THREAD-STARTUP-MILESTONE-1.md).
        record[0],
        record[1],
    ];
    // The helpers' names and parameter counts, never their addresses: an
    // executable whose startup computes this (every executable's, through
    // runtime::program::read_linked) would otherwise keep every helper
    // linked, one that calls five of them too (ops.rs's
    // HELPER_SIGNATURES).
    for &(name, params) in super::ops::HELPER_SIGNATURES {
        words.extend(name.bytes().map(u64::from));
        words.push(params as u64);
    }
    // FNV-1a over the words' little-endian bytes.
    let mut hash: u64 = 0xcbf2_9ce4_8422_2325;
    for byte in words.iter().flat_map(|w| w.to_le_bytes()) {
        hash = (hash ^ u64::from(byte)).wrapping_mul(0x0000_0100_0000_01b3);
    }
    hash
}

// ---------------------------------------------------------------- encoding

fn write_target(w: &mut Writer, t: Target) {
    match t {
        Target::Local(offset) => {
            w.u32(0);
            w.u64(offset);
        }
        Target::Import(index) => {
            w.u32(1);
            w.u64(u64::from(index));
        }
    }
}

fn read_target(r: &mut Reader) -> Result<Target, String> {
    Ok(match r.u32()? {
        0 => Target::Local(r.u64()?),
        _ => Target::Import(u32::try_from(r.u64()?).map_err(|e| e.to_string())?),
    })
}

impl Image {
    /// The payload: everything after the stub's own bytes but the trailer.
    pub fn encode(&self) -> Vec<u8> {
        let mut w = Writer(Vec::new());
        w.u32(FORMAT);
        w.u64(abi_fingerprint());
        w.len(self.imports.len());
        for name in &self.imports {
            w.str(name);
        }
        w.bytes(&self.code);
        w.u64(self.size);
        w.u64(self.executable);
        w.len(self.fixups.len());
        for fixup in &self.fixups {
            match *fixup {
                Fixup::Abs64 { at, target, addend } => {
                    w.u32(0);
                    w.u64(at);
                    write_target(&mut w, target);
                    w.i64(addend);
                }
                Fixup::Call32 { at, import, addend, trampoline } => {
                    w.u32(1);
                    w.u64(at);
                    w.u32(import);
                    w.i64(addend);
                    w.u64(trampoline);
                }
            }
        }
        w.u64(self.program);
        w.0
    }

    pub fn decode(data: &[u8]) -> Result<Image, String> {
        let mut r = Reader { data, at: 0 };
        let format = r.u32()?;
        if format != FORMAT {
            return Err(format!("program image format {format}, this runtime reads format {FORMAT}"));
        }
        if r.u64()? != abi_fingerprint() {
            return Err("program image was compiled for a different native runtime build".to_string());
        }
        let imports = (0..r.len()?).map(|_| r.str()).collect::<Result<Vec<_>, _>>()?;
        let code = r.bytes()?;
        let size = r.u64()?;
        let executable = r.u64()?;
        let mut fixups = Vec::new();
        for _ in 0..r.len()? {
            fixups.push(match r.u32()? {
                0 => Fixup::Abs64 { at: r.u64()?, target: read_target(&mut r)?, addend: r.i64()? },
                1 => Fixup::Call32 { at: r.u64()?, import: r.u32()?, addend: r.i64()?, trampoline: r.u64()? },
                tag => return Err(format!("unknown fixup tag {tag}")),
            });
        }
        let program = r.u64()?;
        if r.at != data.len() {
            return Err("trailing bytes after the program image".to_string());
        }
        if code.len() as u64 > size
            || executable > size
            || program.checked_add(std::mem::size_of::<LinkedProgram>() as u64).is_none_or(|end| end > size)
        {
            return Err("malformed program image".to_string());
        }
        Ok(Image { imports, code, size, executable, fixups, program })
    }

    /// The image appended to the executable at PATH (`/proc/self/exe` for a
    /// running stub).
    pub fn read_appended(path: &str) -> Result<Image, String> {
        let mut file = std::fs::File::open(path).map_err(|e| format!("{path}: {e}"))?;
        let length = file.seek(SeekFrom::End(0)).map_err(|e| e.to_string())?;
        let mut trailer = [0u8; 16];
        if length < 16 {
            return Err(format!("{path}: no program image (file too short)"));
        }
        file.seek(SeekFrom::Start(length - 16)).map_err(|e| e.to_string())?;
        file.read_exact(&mut trailer).map_err(|e| e.to_string())?;
        if &trailer[8..] != MAGIC {
            return Err(format!("{path}: no program image (this is the bare botlish-aot-stub, not an executable it linked)"));
        }
        let payload = u64::from_le_bytes(trailer[..8].try_into().unwrap());
        if payload > length - 16 {
            return Err(format!("{path}: truncated program image"));
        }
        file.seek(SeekFrom::Start(length - 16 - payload)).map_err(|e| e.to_string())?;
        let mut data = vec![0u8; usize::try_from(payload).map_err(|e| e.to_string())?];
        file.read_exact(&mut data).map_err(|e| e.to_string())?;
        Image::decode(&data)
    }
}

/// The trailer that follows a payload of PAYLOAD_LEN bytes.
pub fn trailer(payload_len: usize) -> [u8; 16] {
    let mut t = [0u8; 16];
    t[..8].copy_from_slice(&(payload_len as u64).to_le_bytes());
    t[8..].copy_from_slice(MAGIC);
    t
}

// ------------------------------------------------------------------ loading

/// An image mapped and relocated in this process: plain addresses and data,
/// so it can move to the thread `aot::run` starts.
pub struct Loaded {
    base: usize,
    program: usize,
}

#[cfg(all(target_arch = "x86_64", target_os = "linux"))]
impl Image {
    /// Maps the image next to this executable's own code and resolves its
    /// fixups against this runtime's helpers. The mapping lives as long as
    /// the process.
    pub fn load(self) -> Result<Loaded, String> {
        let helpers: std::collections::HashMap<&str, usize> =
            super::ops::helpers().into_iter().map(|(name, _, address)| (name, address as usize)).collect();
        let addresses = self
            .imports
            .iter()
            .map(|name| helpers.get(name.as_str()).copied().ok_or_else(|| format!("unknown runtime helper {name}")))
            .collect::<Result<Vec<usize>, String>>()?;
        let page = 4096usize;
        let size = usize::try_from(self.size).map_err(|e| e.to_string())?.max(1).next_multiple_of(page);
        let lowest = helpers.values().copied().min().unwrap_or(0);
        let base = map_near(lowest, size)?;
        unsafe {
            std::ptr::copy_nonoverlapping(self.code.as_ptr(), base as *mut u8, self.code.len());
        }
        let patch = |at: u64, bytes: &[u8]| -> Result<(), String> {
            let at = usize::try_from(at).map_err(|e| e.to_string())?;
            if at.checked_add(bytes.len()).is_none_or(|end| end > size) {
                return Err("program image fixup out of bounds".to_string());
            }
            unsafe { std::ptr::copy_nonoverlapping(bytes.as_ptr(), (base + at) as *mut u8, bytes.len()) };
            Ok(())
        };
        let address = |target: Target| -> Result<usize, String> {
            match target {
                Target::Local(offset) => Ok(base + usize::try_from(offset).map_err(|e| e.to_string())?),
                Target::Import(index) => {
                    addresses.get(index as usize).copied().ok_or_else(|| "program image import out of range".to_string())
                }
            }
        };
        for fixup in &self.fixups {
            match *fixup {
                Fixup::Abs64 { at, target, addend } => {
                    let value = (address(target)? as i64).wrapping_add(addend);
                    patch(at, &value.to_le_bytes())?;
                }
                Fixup::Call32 { at, import, addend, trampoline } => {
                    let place = (base as i128) + i128::from(at);
                    let direct = address(Target::Import(import))? as i128 + i128::from(addend) - place;
                    let displacement = match i32::try_from(direct) {
                        Ok(d) => d,
                        Err(_) => i32::try_from((base as i128) + i128::from(trampoline) + i128::from(addend) - place)
                            .map_err(|_| "program image trampoline out of reach".to_string())?,
                    };
                    patch(at, &displacement.to_le_bytes())?;
                }
            }
        }
        let executable = usize::try_from(self.executable).map_err(|e| e.to_string())?;
        if executable > 0
            && unsafe { libc::mprotect(base as *mut libc::c_void, executable, libc::PROT_READ | libc::PROT_EXEC) } != 0
        {
            return Err(format!("cannot make program code executable: {}", std::io::Error::last_os_error()));
        }
        Ok(Loaded { base, program: usize::try_from(self.program).map_err(|e| e.to_string())? })
    }
}

/// SIZE bytes of fresh read-write memory, preferably within a few hundred
/// MiB below ANCHOR (this executable's code), so the image's calls to runtime
/// helpers reach them with a rel32 displacement. Anywhere else is correct
/// too, only slower: out-of-reach calls go through the trampolines.
#[cfg(all(target_arch = "x86_64", target_os = "linux"))]
fn map_near(anchor: usize, size: usize) -> Result<usize, String> {
    let protection = libc::PROT_READ | libc::PROT_WRITE;
    let flags = libc::MAP_PRIVATE | libc::MAP_ANONYMOUS;
    for gap in [16usize << 20, 256 << 20, 1 << 30] {
        let Some(wanted) = anchor.checked_sub(size + gap).map(|a| a & !0xfff) else { continue };
        // MAP_FIXED_NOREPLACE fails rather than replace an existing
        // mapping; a kernel older than 4.17 takes it as a hint.
        let got = unsafe {
            libc::mmap(wanted as *mut libc::c_void, size, protection, flags | libc::MAP_FIXED_NOREPLACE, -1, 0)
        };
        if got == libc::MAP_FAILED {
            continue;
        }
        if got as usize == wanted {
            return Ok(wanted);
        }
        unsafe { libc::munmap(got, size) };
    }
    let got = unsafe { libc::mmap(std::ptr::null_mut(), size, protection, flags, -1, 0) };
    if got == libc::MAP_FAILED {
        return Err(format!("cannot map program code: {}", std::io::Error::last_os_error()));
    }
    Ok(got as usize)
}

impl Loaded {
    /// The startup policy of the image's record (`program::startup_of`),
    /// read before the program is started.
    pub fn startup(&self) -> Result<Startup, String> {
        // SAFETY: as `instantiate`; startup_of reads only the record itself.
        unsafe { super::program::startup_of(&*((self.base + self.program) as *const LinkedProgram)) }
    }

    /// The program's Vm and entry, built from its relocated record exactly as
    /// the `rustc` linker's startup builds them (`program::instantiate_linked`).
    /// Runs on the thread that runs the program.
    pub fn instantiate(self) -> Result<(Box<Vm>, ProgramEntry), String> {
        // SAFETY: the record lies in the mapped image (decode checked its
        // bounds), and load applied every fixup of its pointers.
        unsafe { super::program::instantiate_linked(&*((self.base + self.program) as *const LinkedProgram)) }
    }
}

/// `botlish-aot-stub`'s `main`: runs the image appended to this executable
/// with the process's own arguments. Returns the exit status.
#[cfg(all(target_arch = "x86_64", target_os = "linux"))]
pub fn main() -> i32 {
    let argv = super::aot::process_argv();
    let loaded = match Image::read_appended("/proc/self/exe").and_then(Image::load) {
        Ok(loaded) => loaded,
        Err(error) => {
            eprintln!("{error} (NATIVE STARTUP)");
            return 1;
        }
    };
    // The stub links no main-thread executable (codegen::aot refuses one
    // before linking): its record's policy is the worker's, or the image is
    // not one this driver made.
    match loaded.startup() {
        Ok(Startup::Worker) => {}
        Ok(Startup::MainThread) => {
            eprintln!("the stub linker's executables start their program on a worker: this image's record names the main-thread startup policy (NATIVE STARTUP)");
            return 1;
        }
        Err(error) => {
            eprintln!("{error} (NATIVE STARTUP)");
            return 1;
        }
    }
    super::aot::run(Startup::Worker, argv, move || match loaded.instantiate() {
        Ok(started) => started,
        Err(error) => {
            eprintln!("{error} (NATIVE STARTUP)");
            std::process::exit(1);
        }
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    fn sample() -> Image {
        Image {
            imports: vec!["rt_int_add".into(), "rt_raise".into()],
            code: vec![0xc3, 0x90, 0x90],
            size: 8192,
            executable: 4096,
            fixups: vec![
                Fixup::Abs64 { at: 4096, target: Target::Local(16), addend: -2 },
                Fixup::Abs64 { at: 4104, target: Target::Import(1), addend: 0 },
                Fixup::Call32 { at: 1, import: 0, addend: -4, trampoline: 64 },
            ],
            program: 4112,
        }
    }

    #[test]
    fn aot_image_round_trips() {
        let image = sample();
        let decoded = Image::decode(&image.encode()).expect("decode");
        assert_eq!(decoded.encode(), image.encode());
        assert_eq!(decoded.fixups, image.fixups);
        assert_eq!(decoded.imports, image.imports);
        assert_eq!(decoded.program, image.program);
    }

    /// The fingerprint covers the program record's layout: a runtime whose
    /// record were another -- the six words before the startup policy, say
    /// -- fingerprints differently, so neither reads the other's record
    /// (MAIN-THREAD-STARTUP-MILESTONE-1.md, "Runtime ABI compatibility").
    #[test]
    fn aot_fingerprint_covers_the_record_layout() {
        assert_eq!(RECORD_LAYOUT, [56, 48]);
        assert_eq!(abi_fingerprint(), abi_fingerprint_for(RECORD_LAYOUT));
        assert_ne!(abi_fingerprint(), abi_fingerprint_for([48, 40]));
        assert_ne!(abi_fingerprint(), abi_fingerprint_for([56, 0]));
    }

    #[test]
    fn aot_image_rejects_damage() {
        let bytes = sample().encode();
        assert!(Image::decode(&bytes[..bytes.len() - 1]).is_err());
        let mut longer = bytes.clone();
        longer.push(0);
        assert!(Image::decode(&longer).is_err());
        let mut other_abi = bytes.clone();
        other_abi[4] ^= 1;
        assert!(matches!(Image::decode(&other_abi), Err(e) if e.contains("different native runtime build")));
        let mut outside = sample();
        outside.program = outside.size;
        assert!(Image::decode(&outside.encode()).is_err());
    }

}
