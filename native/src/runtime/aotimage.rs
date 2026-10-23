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
//! The image holds exactly what the `rustc` linker's generated startup crate
//! compiles in -- the program metadata (`ProgramInfo`), the constant pool,
//! the module-static count, every function's code range and stack-map table
//! -- plus the machine code itself: the Cranelift object's allocated
//! sections, laid out by `codegen::aot` with every reference inside the
//! image already resolved and the references that need a load address left
//! as [`Fixup`]s. At startup the stub reads the image back from its own file
//! (`/proc/self/exe`), maps the code into fresh memory next to its own text
//! (so a call to a runtime helper stays a direct `call rel32`), applies the
//! fixups, makes the code executable, and builds the Vm exactly as the
//! generated startup crate does: `Vm::new`, `constants::install`, the
//! frame map, `aot::run`. Nothing is compiled or interpreted at startup and
//! the machine code is the same Cranelift output either linker links.

use super::aot::ProgramEntry;
use super::constants::Const;
use super::metrics::AllocMode;
use super::program::{self, FunctionMeta, Reader, Writer};
use super::vm::{ProgramInfo, Vm};
use std::io::{Read, Seek, SeekFrom};

/// The last 8 bytes of a stub-linked executable.
pub const MAGIC: &[u8; 8] = b"BOTLIMG1";
/// The payload's own format revision, its first word.
const FORMAT: u32 = 1;

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

/// One function's code in the image: its direct entry (with its stack maps)
/// and its generic entry, as image offsets and sizes in bytes.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct FunctionCode {
    pub direct: u64,
    pub direct_size: u32,
    pub entry: u64,
    pub entry_size: u32,
    pub safepoints: Vec<(u32, Vec<u32>)>,
}

pub struct Image {
    pub info: ProgramInfo,
    pub constants: Vec<Const>,
    pub statics: u32,
    /// The runtime helpers the code references, by name.
    pub imports: Vec<String>,
    /// The image's initialized bytes; it is `size` bytes long in memory, the
    /// rest zero (`.bss`).
    pub code: Vec<u8>,
    pub size: u64,
    /// `[0, executable)` is machine code (and trampolines), page-aligned;
    /// everything after it is writable data (the GOT, the context area).
    pub executable: u64,
    pub fixups: Vec<Fixup>,
    /// Indexed by NIR function id; function 0 is the program's entry.
    pub functions: Vec<FunctionCode>,
}

/// A digest of the runtime ABI the generated code is compiled against: the
/// Vm and object field offsets it addresses directly and the helpers it
/// calls. The driver records its own in the image; the stub refuses an image
/// recorded by a driver whose runtime differs from its own (a stub and a
/// driver from different builds), since that code would address fields that
/// are not there.
pub fn abi_fingerprint() -> u64 {
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
    ];
    for (name, params, _) in super::ops::helpers() {
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
//
// The metadata (program info, constants, safepoints) is encoded by the
// functions every program descriptor uses (runtime::program); the image adds
// its code, imports and fixups.

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
        program::encode_info(&mut w, &self.info);
        program::encode_constants(&mut w, &self.constants);
        w.u32(self.statics);
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
        w.len(self.functions.len());
        for f in &self.functions {
            w.u64(f.direct);
            w.u32(f.direct_size);
            w.u64(f.entry);
            w.u32(f.entry_size);
            program::encode_safepoints(&mut w, &f.safepoints);
        }
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
        let info = program::decode_info(&mut r)?;
        let constants = program::decode_constants(&mut r)?;
        let statics = r.u32()?;
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
        let mut functions = Vec::new();
        for _ in 0..r.len()? {
            let direct = r.u64()?;
            let direct_size = r.u32()?;
            let entry = r.u64()?;
            let entry_size = r.u32()?;
            let safepoints = program::decode_safepoints(&mut r)?;
            functions.push(FunctionCode { direct, direct_size, entry, entry_size, safepoints });
        }
        if r.at != data.len() {
            return Err("trailing bytes after the program image".to_string());
        }
        if code.len() as u64 > size || executable > size || functions.is_empty() {
            return Err("malformed program image".to_string());
        }
        Ok(Image { info, constants, statics, imports, code, size, executable, fixups, functions })
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
    info: ProgramInfo,
    constants: Vec<Const>,
    statics: u32,
    functions: Vec<FunctionCode>,
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
        Ok(Loaded { base, info: self.info, constants: self.constants, statics: self.statics, functions: self.functions })
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
    /// The program's Vm and entry, built by the construction every startup
    /// shares (runtime::program's `build_vm`) from the image's code where
    /// the stub mapped it. Runs on the thread that runs the program.
    pub fn instantiate(self) -> (Box<Vm>, ProgramEntry) {
        let base = self.base;
        let code: Vec<[usize; 2]> =
            self.functions.iter().map(|f| [base + f.direct as usize, base + f.entry as usize]).collect();
        let meta: Vec<FunctionMeta> = self
            .functions
            .iter()
            .map(|f| FunctionMeta { direct_size: f.direct_size, entry_size: f.entry_size, safepoints: f.safepoints.clone() })
            .collect();
        let vm = program::build_vm(self.info, &self.constants, self.statics, &code, &meta, AllocMode::Off);
        // SAFETY: function 0 is the program (codegen::clif's ProgramEntry).
        let entry: ProgramEntry = unsafe { std::mem::transmute(code[0][0]) };
        (vm, entry)
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
    super::aot::run(argv, move || loaded.instantiate())
}

#[cfg(test)]
mod tests {
    use super::*;
    use super::super::value::{FloatType, Kind};
    use super::super::vm::{EnumInfo, FunctionInfo, NativeInfo, ShapeInfo};
    use crate::nir::OpCode;

    fn sample() -> Image {
        Image {
            info: ProgramInfo {
                functions: vec![FunctionInfo { arity: 0, pnames: String::new() }, FunctionInfo { arity: 2, pnames: "a b".into() }],
                natives: vec![
                    NativeInfo { name: "std::str::length".into(), arity: Some(1), params: vec![Some(Kind::Str)], op: OpCode::StrLen },
                    NativeInfo { name: "list".into(), arity: None, params: vec![None], op: OpCode::ListNew },
                ],
                shapes: vec![
                    ShapeInfo { name: None, fields: vec!["a".into(), "b".into()], opaque: false },
                    ShapeInfo { name: Some("m::Point".into()), fields: vec!["x".into()], opaque: true },
                ],
                enums: vec![EnumInfo { name: "Color".into(), cases: vec!["Red".into(), "Green".into()] }],
            },
            constants: vec![
                Const::Str("h\u{e9}llo \u{1f600}".into()),
                Const::Bytes(vec![0, 255, 10]),
                Const::BigInt("-123456789012345678901234567890".into()),
                Const::Float(FloatType::Float64, 1.5f64.to_bits()),
                Const::Native(1),
                Const::FnValue(1),
            ],
            statics: 3,
            imports: vec!["rt_int_add".into(), "rt_raise".into()],
            code: vec![0xc3, 0x90, 0x90],
            size: 8192,
            executable: 4096,
            fixups: vec![
                Fixup::Abs64 { at: 4096, target: Target::Local(16), addend: -2 },
                Fixup::Abs64 { at: 4104, target: Target::Import(1), addend: 0 },
                Fixup::Call32 { at: 1, import: 0, addend: -4, trampoline: 64 },
            ],
            functions: vec![
                FunctionCode { direct: 0, direct_size: 16, entry: 16, entry_size: 8, safepoints: vec![(5, vec![0, 8])] },
                FunctionCode { direct: 32, direct_size: 4, entry: 40, entry_size: 4, safepoints: vec![] },
            ],
        }
    }

    #[test]
    fn aot_image_round_trips() {
        let image = sample();
        let decoded = Image::decode(&image.encode()).expect("decode");
        assert_eq!(decoded.encode(), image.encode());
        assert_eq!(decoded.constants, image.constants);
        assert_eq!(decoded.fixups, image.fixups);
        assert_eq!(decoded.functions, image.functions);
        assert_eq!(decoded.info.natives[0].op, OpCode::StrLen);
        assert_eq!(decoded.info.natives[1].arity, None);
        assert_eq!(decoded.info.shapes[1].name.as_deref(), Some("m::Point"));
        assert!(decoded.info.shapes[1].opaque);
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
    }

    #[test]
    fn aot_image_op_spellings_round_trip() {
        // Every operation a NIR native can name survives the image's encoding
        // by spelling (nir.rs's op_spellings!).
        for op in [OpCode::IAdd, OpCode::StrIsTclAlpha, OpCode::SyscallLinuxX86_64, OpCode::AsciiShortEq] {
            assert_eq!(OpCode::parse(op.spelling()), Some(op));
        }
    }
}
