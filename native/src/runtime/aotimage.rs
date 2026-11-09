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
use super::program::{LinkedProgram, Reader, Writer};
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
/// Vm and object field offsets it addresses directly, the helpers it calls
/// and the program record's layout (`abi_words`). The driver records its own
/// in the image and in every program record; the stub and every startup
/// refuse one recorded by a driver whose runtime differs from its own (a stub
/// and a driver from different builds), since that code would address fields
/// that are not there.
pub fn abi_fingerprint() -> u64 {
    ABI_FINGERPRINT
}

/// `abi_fingerprint`, evaluated when the runtime is compiled: FNV-1a over
/// `abi_words`' little-endian bytes. A constant, so that a runtime archive
/// states the fingerprint of the runtime it holds in its identity record
/// (`identity_record`) without running anything.
pub const ABI_FINGERPRINT: u64 = fingerprint_of(&ABI_SCALAR_WORDS, super::ops::HELPER_SIGNATURES);

/// The fingerprint's words before the helpers' (`abi_words`).
const ABI_SCALAR_WORDS: [u64; 26] = {
    use super::{bytesobj, strobj, value, vm};
    [
        std::mem::size_of::<Vm>() as u64,
        vm::VM_SS_TOP_OFFSET as u64,
        vm::VM_SS_LIMIT_OFFSET as u64,
        vm::VM_CONSTS_OFFSET as u64,
        vm::VM_ALLOC_SITE_OFFSET as u64,
        vm::VM_NATIVE_ROOTS_PTR_OFFSET as u64,
        vm::VM_NATIVE_ROOTS_LEN_OFFSET as u64,
        vm::VM_STATICS_OFFSET as u64,
        // Where generated code finds the running Vm's context area
        // (PER-THREAD-RUNTIME-STATE-MILESTONE-1.md): code of a runtime that
        // kept it elsewhere -- or in a process-wide data symbol -- never runs
        // on this one.
        vm::VM_CONTEXT_OFFSET as u64,
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
        super::framewalk::NATIVE_FRAME_ROOTS as u64,
        // The program record's layout (runtime::program's LinkedProgram):
        // a runtime that reads the record's words elsewhere -- its startup
        // policy among them -- refuses it here, before it reads them.
        std::mem::size_of::<LinkedProgram>() as u64,
        std::mem::offset_of!(LinkedProgram, startup) as u64,
    ]
};

/// FNV-1a over WORD's little-endian bytes, continuing HASH.
const fn fnv_word(mut hash: u64, word: u64) -> u64 {
    let bytes = word.to_le_bytes();
    let mut i = 0;
    while i < 8 {
        hash = (hash ^ bytes[i] as u64).wrapping_mul(0x0000_0100_0000_01b3);
        i += 1;
    }
    hash
}

/// The fingerprint of the scalar words SCALARS followed by the helpers
/// HELPERS: each name's bytes, one word each, then its
/// parameter count -- `abi_words`' order.
const fn fingerprint_of(scalars: &[u64], helpers: &[(&str, usize)]) -> u64 {
    let mut hash: u64 = 0xcbf2_9ce4_8422_2325;
    let mut i = 0;
    while i < scalars.len() {
        hash = fnv_word(hash, scalars[i]);
        i += 1;
    }
    let mut h = 0;
    while h < helpers.len() {
        let name = helpers[h].0.as_bytes();
        let mut b = 0;
        while b < name.len() {
            hash = fnv_word(hash, name[b] as u64);
            b += 1;
        }
        hash = fnv_word(hash, helpers[h].1 as u64);
        h += 1;
    }
    hash
}

/// What `abi_fingerprint` digests, word by word.
pub fn abi_words() -> Vec<u64> {
    let mut words: Vec<u64> = ABI_SCALAR_WORDS.to_vec();
    // The helpers' names and parameter counts, never their addresses: an
    // executable whose startup computes this (every executable's, through
    // runtime::program::read_linked) would otherwise keep every helper
    // linked, one that calls five of them too (ops.rs's
    // HELPER_SIGNATURES).
    for &(name, params) in super::ops::HELPER_SIGNATURES {
        words.extend(name.bytes().map(u64::from));
        words.push(params as u64);
    }
    words
}

/// The length of a runtime archive's identity record (`identity_record`).
pub const IDENTITY_LEN: usize = 160;

/// The identity record of a runtime built for the target TRIPLE: the bytes
///
///   BOTLISH-RUNTIME-IDENTITY v1 TRIPLE FINGERPRINT
///
/// (FINGERPRINT `ABI_FINGERPRINT` as 16 lowercase hexadecimal digits) and NUL
/// bytes up to IDENTITY_LEN. The runtime archive keeps it as a static
/// (native/runtime-archive), so that the compiler reads from an archive's
/// bytes -- without running any of it -- which target and runtime ABI it
/// was built for: a target support package's archive is accepted only for
/// its own target and this driver's ABI
/// (EXTERNAL-COMPILER-TOOLS-AND-TARGET-PACKAGES-MILESTONE-1.md, "Target
/// support packages"). The prefix is assembled from two pieces, so that it
/// occurs in a compiled runtime only in the record itself.
pub const fn identity_record(triple: &str) -> [u8; IDENTITY_LEN] {
    const FIRST: &[u8] = b"BOTLISH-RUNTIME";
    const SECOND: &[u8] = b"-IDENTITY v1 ";
    const HEX: &[u8; 16] = b"0123456789abcdef";
    let mut record = [0u8; IDENTITY_LEN];
    let mut at = 0;
    let mut i = 0;
    while i < FIRST.len() {
        record[at] = FIRST[i];
        at += 1;
        i += 1;
    }
    i = 0;
    while i < SECOND.len() {
        record[at] = SECOND[i];
        at += 1;
        i += 1;
    }
    let name = triple.as_bytes();
    assert!(name.len() + 64 < IDENTITY_LEN, "a target triple too long for the identity record");
    i = 0;
    while i < name.len() {
        record[at] = name[i];
        at += 1;
        i += 1;
    }
    record[at] = b' ';
    at += 1;
    let mut shift = 64;
    while shift > 0 {
        shift -= 4;
        record[at] = HEX[((ABI_FINGERPRINT >> shift) & 0xf) as usize];
        at += 1;
    }
    record
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
    /// The startup policy the program's record names (`program::linked_startup`).
    pub fn startup(&self) -> Result<super::program::Startup, String> {
        // SAFETY: as `instantiate`'s.
        unsafe { super::program::linked_startup(&*((self.base + self.program) as *const LinkedProgram)) }
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
    // The record's startup policy, as every executable's startup reads it
    // (aot::start_linked): only the worker on this host, which `run`
    // checks.
    let startup = match loaded.startup() {
        Ok(startup) => startup,
        Err(error) => {
            eprintln!("{error} (NATIVE STARTUP)");
            return 1;
        }
    };
    // (The record lies in the mapped image, which is never unmapped.)
    let record: &'static LinkedProgram = unsafe { &*((loaded.base + loaded.program) as *const LinkedProgram) };
    super::aot::run(startup, argv, Some(super::thread::linked_factory(record)), move || match loaded.instantiate() {
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

    /// The fingerprint covers the program record's layout -- its size and
    /// where its startup word is (MAIN-THREAD-STARTUP-MILESTONE-1.md) -- so
    /// a runtime that reads a record of another layout refuses it at the
    /// fingerprint, before it reads the startup policy.
    #[test]
    fn abi_fingerprint_covers_the_program_record() {
        let words = abi_words();
        let record = [std::mem::size_of::<LinkedProgram>() as u64, std::mem::offset_of!(LinkedProgram, startup) as u64];
        assert!(words.windows(2).any(|w| w == record), "{record:?} not among the fingerprint's words");
        assert_eq!(record, [56, 48]);
    }

    /// The constant fingerprint is FNV-1a over `abi_words`, as the
    /// fingerprint has always been computed: one value, whichever way it is
    /// read.
    #[test]
    fn abi_fingerprint_constant_is_the_digest_of_its_words() {
        let mut hash: u64 = 0xcbf2_9ce4_8422_2325;
        for byte in abi_words().iter().flat_map(|w| w.to_le_bytes()) {
            hash = (hash ^ u64::from(byte)).wrapping_mul(0x0000_0100_0000_01b3);
        }
        assert_eq!(hash, ABI_FINGERPRINT);
        assert_eq!(abi_fingerprint(), ABI_FINGERPRINT);
    }

    /// The identity record names the triple and the fingerprint, NUL-padded.
    #[test]
    fn identity_record_states_triple_and_fingerprint() {
        let record = identity_record("x86_64-unknown-linux-gnu");
        let text = std::str::from_utf8(&record).unwrap().trim_end_matches('\0');
        assert_eq!(text, format!("BOTLISH-RUNTIME-IDENTITY v1 x86_64-unknown-linux-gnu {:016x}", ABI_FINGERPRINT));
        assert!(record[text.len()..].iter().all(|&b| b == 0));
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
