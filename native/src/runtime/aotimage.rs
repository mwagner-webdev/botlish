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
use super::constants::{self, Const};
use super::framemap::{FunctionMap, ProgramMap};
use super::metrics::AllocMode;
use super::value::{FloatType, Kind};
use super::vm::{EnumInfo, FunctionInfo, NativeInfo, ProgramInfo, ShapeInfo, Vm};
use crate::nir::OpCode;
use std::io::{Read, Seek, SeekFrom};
use std::rc::Rc;

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
/// are not there; so does a system-linked executable's runtime archive
/// (`read_linked`).
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
        // The GC root plan the code was generated for (stack maps and the
        // frame walk, or the shadow stack): a `fallback-roots` build's code
        // never runs on a runtime of the other plan.
        u64::from(super::framewalk::NATIVE_FRAME_ROOTS),
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

struct Writer(Vec<u8>);

impl Writer {
    fn u32(&mut self, v: u32) {
        self.0.extend_from_slice(&v.to_le_bytes());
    }
    fn u64(&mut self, v: u64) {
        self.0.extend_from_slice(&v.to_le_bytes());
    }
    fn i64(&mut self, v: i64) {
        self.0.extend_from_slice(&v.to_le_bytes());
    }
    fn len(&mut self, n: usize) {
        self.u64(n as u64);
    }
    fn bytes(&mut self, b: &[u8]) {
        self.len(b.len());
        self.0.extend_from_slice(b);
    }
    fn str(&mut self, s: &str) {
        self.bytes(s.as_bytes());
    }
    fn opt_str(&mut self, s: Option<&str>) {
        match s {
            Some(s) => {
                self.u32(1);
                self.str(s);
            }
            None => self.u32(0),
        }
    }
    fn target(&mut self, t: Target) {
        match t {
            Target::Local(offset) => {
                self.u32(0);
                self.u64(offset);
            }
            Target::Import(index) => {
                self.u32(1);
                self.u64(u64::from(index));
            }
        }
    }
}

struct Reader<'a> {
    data: &'a [u8],
    at: usize,
}

impl<'a> Reader<'a> {
    fn take(&mut self, n: usize) -> Result<&'a [u8], String> {
        let end = self.at.checked_add(n).filter(|&end| end <= self.data.len()).ok_or("truncated program image")?;
        let slice = &self.data[self.at..end];
        self.at = end;
        Ok(slice)
    }
    fn u32(&mut self) -> Result<u32, String> {
        Ok(u32::from_le_bytes(self.take(4)?.try_into().unwrap()))
    }
    fn u64(&mut self) -> Result<u64, String> {
        Ok(u64::from_le_bytes(self.take(8)?.try_into().unwrap()))
    }
    fn i64(&mut self) -> Result<i64, String> {
        Ok(i64::from_le_bytes(self.take(8)?.try_into().unwrap()))
    }
    fn len(&mut self) -> Result<usize, String> {
        usize::try_from(self.u64()?).map_err(|e| e.to_string())
    }
    fn bytes(&mut self) -> Result<Vec<u8>, String> {
        let n = self.len()?;
        Ok(self.take(n)?.to_vec())
    }
    fn str(&mut self) -> Result<String, String> {
        String::from_utf8(self.bytes()?).map_err(|e| e.to_string())
    }
    fn opt_str(&mut self) -> Result<Option<String>, String> {
        Ok(match self.u32()? {
            0 => None,
            _ => Some(self.str()?),
        })
    }
    fn kind(&mut self) -> Result<Option<Kind>, String> {
        match self.opt_str()? {
            None => Ok(None),
            Some(name) => Kind::parse(&name).map(Some).ok_or_else(|| format!("unknown kind {name:?}")),
        }
    }
    fn target(&mut self) -> Result<Target, String> {
        Ok(match self.u32()? {
            0 => Target::Local(self.u64()?),
            _ => Target::Import(u32::try_from(self.u64()?).map_err(|e| e.to_string())?),
        })
    }
}

impl Image {
    /// The payload: everything after the stub's own bytes but the trailer.
    pub fn encode(&self) -> Vec<u8> {
        let mut w = Writer(Vec::new());
        w.u32(FORMAT);
        w.u64(abi_fingerprint());
        let info = &self.info;
        w.len(info.functions.len());
        for f in &info.functions {
            w.len(f.arity);
            w.str(&f.pnames);
        }
        w.len(info.natives.len());
        for n in &info.natives {
            w.str(&n.name);
            match n.arity {
                Some(arity) => {
                    w.u32(1);
                    w.len(arity);
                }
                None => w.u32(0),
            }
            w.len(n.params.len());
            for kind in &n.params {
                w.opt_str(kind.map(Kind::name));
            }
            w.str(n.op.spelling());
        }
        w.len(info.shapes.len());
        for s in &info.shapes {
            w.opt_str(s.name.as_deref());
            w.len(s.fields.len());
            for field in &s.fields {
                w.str(field);
            }
            w.u32(u32::from(s.opaque));
        }
        w.len(info.enums.len());
        for e in &info.enums {
            w.str(&e.name);
            w.len(e.cases.len());
            for case in &e.cases {
                w.str(case);
            }
        }
        w.len(self.constants.len());
        for c in &self.constants {
            match c {
                Const::Str(text) => {
                    w.u32(0);
                    w.str(text);
                }
                Const::Bytes(bytes) => {
                    w.u32(1);
                    w.bytes(bytes);
                }
                Const::BigInt(digits) => {
                    w.u32(2);
                    w.str(digits);
                }
                Const::Native(index) => {
                    w.u32(3);
                    w.u32(*index);
                }
                Const::FnValue(func) => {
                    w.u32(4);
                    w.u32(*func);
                }
                Const::Float(ty, bits) => {
                    w.u32(5);
                    w.str(ty.prefix());
                    w.u64(*bits);
                }
            }
        }
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
                    w.target(target);
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
            w.len(f.safepoints.len());
            for (pc, roots) in &f.safepoints {
                w.u32(*pc);
                w.len(roots.len());
                for root in roots {
                    w.u32(*root);
                }
            }
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
        let mut info = ProgramInfo { functions: Vec::new(), natives: Vec::new(), shapes: Vec::new(), enums: Vec::new() };
        for _ in 0..r.len()? {
            let arity = r.len()?;
            info.functions.push(FunctionInfo { arity, pnames: r.str()? });
        }
        for _ in 0..r.len()? {
            let name = r.str()?;
            let arity = match r.u32()? {
                0 => None,
                _ => Some(r.len()?),
            };
            let params = (0..r.len()?).map(|_| r.kind()).collect::<Result<Vec<_>, _>>()?;
            let spelling = r.str()?;
            let op = OpCode::parse(&spelling).ok_or_else(|| format!("unknown native operation {spelling:?}"))?;
            info.natives.push(NativeInfo { name, arity, params, op });
        }
        for _ in 0..r.len()? {
            let name = r.opt_str()?;
            let fields = (0..r.len()?).map(|_| r.str()).collect::<Result<Vec<_>, _>>()?;
            let opaque = r.u32()? != 0;
            info.shapes.push(ShapeInfo { name, fields, opaque });
        }
        for _ in 0..r.len()? {
            let name = r.str()?;
            let cases = (0..r.len()?).map(|_| r.str()).collect::<Result<Vec<_>, _>>()?;
            info.enums.push(EnumInfo { name, cases });
        }
        let mut constants = Vec::new();
        for _ in 0..r.len()? {
            constants.push(match r.u32()? {
                0 => Const::Str(r.str()?),
                1 => Const::Bytes(r.bytes()?),
                2 => Const::BigInt(r.str()?),
                3 => Const::Native(r.u32()?),
                4 => Const::FnValue(r.u32()?),
                5 => {
                    let prefix = r.str()?;
                    let ty = FloatType::of_prefix(&prefix).ok_or_else(|| format!("unknown float type {prefix}"))?;
                    Const::Float(ty, r.u64()?)
                }
                tag => return Err(format!("unknown constant tag {tag}")),
            });
        }
        let statics = r.u32()?;
        let imports = (0..r.len()?).map(|_| r.str()).collect::<Result<Vec<_>, _>>()?;
        let code = r.bytes()?;
        let size = r.u64()?;
        let executable = r.u64()?;
        let mut fixups = Vec::new();
        for _ in 0..r.len()? {
            fixups.push(match r.u32()? {
                0 => Fixup::Abs64 { at: r.u64()?, target: r.target()?, addend: r.i64()? },
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
            let mut safepoints = Vec::new();
            for _ in 0..r.len()? {
                let pc = r.u32()?;
                let roots = (0..r.len()?).map(|_| r.u32()).collect::<Result<Vec<_>, _>>()?;
                safepoints.push((pc, roots));
            }
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

// ------------------------------------------------- system-linked executables

/// The first 8 bytes of a system-linked executable's program description
/// (SINGLE-EXECUTABLE-FFI-MILESTONE-1.md): the data object
/// `botlish_program_description` that `codegen::aot`'s startup object
/// defines and the runtime archive's `main` reads. Its revision is the last
/// byte, as the stub image's trailer's.
pub const LINKED_MAGIC: &[u8; 8] = b"BOTLSYS1";

/// The startup interface's symbol: the runtime archive defines it (one byte,
/// its revision) and every startup object refers to it, so a startup object
/// and an archive of different interface revisions fail to *link* (an
/// undefined `botlish_runtime_startup_v1`), before anything runs. Its name
/// changes with `LINKED_MAGIC`'s revision.
pub const LINKED_INTERFACE_SYMBOL: &str = "botlish_runtime_startup_v1";

/// The description's fixed header: the magic, the function count N, the
/// metadata length, the interface symbol's address. Then 2N addresses (each
/// function's direct entry `botlish_fn_I` and its generic entry
/// `botlish_entry_I`, by NIR id: the linker's relocations), then the
/// metadata: an [`Image`] with no machine code, no imports and no fixups
/// (the code is the executable's own, already linked), whose functions'
/// sizes and stack maps the addresses complete.
pub const LINKED_HEADER: usize = 32;

/// Bounds of a description's counts, far above any program: a description
/// that claims more is damaged, and is never read.
const LINKED_MAX_FUNCTIONS: u64 = 1 << 24;
const LINKED_MAX_METADATA: u64 = 1 << 36;

impl Image {
    /// The image of a program the system linker links: its metadata alone.
    /// FUNCTIONS carry sizes and stack maps; their offsets are unused (the
    /// description's addresses replace them).
    pub fn linked(info: ProgramInfo, constants: Vec<Const>, statics: u32, functions: Vec<FunctionCode>) -> Image {
        Image { info, constants, statics, imports: Vec::new(), code: Vec::new(), size: 0, executable: 0, fixups: Vec::new(), functions }
    }

    /// The bytes of `botlish_program_description` before the linker fills
    /// in its addresses (all zero here: each is a relocation's), and the
    /// offsets of the slots to relocate: the interface symbol's, then every
    /// function's direct and generic entry, by NIR id.
    pub fn linked_description(&self) -> (Vec<u8>, usize, Vec<(usize, usize)>) {
        let metadata = self.encode();
        let n = self.functions.len();
        let mut bytes = Vec::with_capacity(LINKED_HEADER + 16 * n + metadata.len());
        bytes.extend_from_slice(LINKED_MAGIC);
        bytes.extend_from_slice(&(n as u64).to_le_bytes());
        bytes.extend_from_slice(&(metadata.len() as u64).to_le_bytes());
        bytes.extend_from_slice(&0u64.to_le_bytes());
        let slots = (0..n).map(|i| (LINKED_HEADER + 16 * i, LINKED_HEADER + 16 * i + 8)).collect();
        bytes.resize(LINKED_HEADER + 16 * n, 0);
        bytes.extend_from_slice(&metadata);
        (bytes, LINKED_HEADER - 8, slots)
    }
}

/// Reads the program description at DESCRIPTION, linked into this
/// executable, whose interface slot must hold INTERFACE (the archive's own
/// `botlish_runtime_startup_v1`): the program, ready to instantiate. Every
/// count is checked before it is used, the metadata is decoded with the
/// stub image's checks (`Image::decode`: format, ABI fingerprint, bounds),
/// and it must hold no machine code of its own.
///
/// # Safety
/// DESCRIPTION is the address of a `botlish_program_description` the
/// system linker linked (LINKED_HEADER bytes at least; the header's counts
/// say how many more are there).
pub unsafe fn read_linked(description: *const u8, interface: *const u8) -> Result<Loaded, String> {
    let word = |at: usize| -> u64 { unsafe { std::ptr::read_unaligned(description.add(at).cast::<u64>()) } };
    let magic = unsafe { std::slice::from_raw_parts(description, 8) };
    if magic != LINKED_MAGIC {
        return Err(if magic[..7] == LINKED_MAGIC[..7] {
            format!("program description revision {:?}, this runtime reads revision {:?}", magic[7] as char, LINKED_MAGIC[7] as char)
        } else {
            "no program description (damaged executable)".to_string()
        });
    }
    let (n, length) = (word(8), word(16));
    if n == 0 || n > LINKED_MAX_FUNCTIONS || length > LINKED_MAX_METADATA {
        return Err("malformed program description".to_string());
    }
    if word(24) != interface as u64 {
        return Err("program description is linked against another runtime's startup interface".to_string());
    }
    let (n, length) = (n as usize, length as usize);
    let addresses: Vec<u64> = (0..2 * n).map(|i| word(LINKED_HEADER + 8 * i)).collect();
    let metadata = unsafe { std::slice::from_raw_parts(description.add(LINKED_HEADER + 16 * n), length) };
    let image = Image::decode(metadata)?;
    if !image.code.is_empty() || !image.imports.is_empty() || !image.fixups.is_empty() || image.size != 0 {
        return Err("program description carries machine code: a stub image, not a linked program".to_string());
    }
    if image.functions.len() != n || image.info.functions.len() != n {
        return Err("program description's function table does not match its program".to_string());
    }
    let mut functions = image.functions;
    for (i, f) in functions.iter_mut().enumerate() {
        (f.direct, f.entry) = (addresses[2 * i], addresses[2 * i + 1]);
        if f.direct == 0 || f.entry == 0 {
            return Err("program description has an unlinked function address".to_string());
        }
    }
    Ok(Loaded { base: 0, info: image.info, constants: image.constants, statics: image.statics, functions })
}

/// The runtime archive's `main` (native/runtime-archive): what Rust's own
/// startup does to the process (`aot::rust_process_setup`), then the
/// program linked beside it, read from DESCRIPTION and run with the
/// process's own arguments by `aot::run`, as the rustc linker's generated
/// `main` and the stub's run theirs, and the process ends as theirs do
/// (`std::process::exit`, which flushes Rust's standard output). A
/// description it cannot read (`read_linked`) is reported as NATIVE STARTUP,
/// status 1; a panic outside the program's own thread is status 101, as a
/// Rust `main`'s.
///
/// # Safety
/// As `read_linked`.
pub unsafe fn linked_main(description: *const u8, interface: *const u8) -> i32 {
    let status = std::panic::catch_unwind(|| -> i32 {
        super::aot::rust_process_setup();
        let argv = super::aot::process_argv();
        match unsafe { read_linked(description, interface) } {
            Ok(loaded) => super::aot::run(argv, move || loaded.instantiate()),
            Err(error) => {
                eprintln!("{error} (NATIVE STARTUP)");
                1
            }
        }
    });
    match status {
        Ok(status) => std::process::exit(status),
        Err(_) => {
            let _ = std::io::Write::flush(&mut std::io::stdout());
            101
        }
    }
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
    /// The program's Vm and entry, built as the `rustc` linker's generated
    /// startup builds them (codegen/aot.rs's `startup`). Runs on the thread
    /// that runs the program.
    pub fn instantiate(self) -> (Box<Vm>, ProgramEntry) {
        let base = self.base;
        let mut vm = Vm::new(Rc::new(self.info), AllocMode::Off);
        let entries: Vec<usize> = self.functions.iter().map(|f| base + f.entry as usize).collect();
        constants::install(&mut vm, &self.constants, &entries, self.statics);
        let mut map = ProgramMap::new();
        for f in &self.functions {
            let start = base + f.direct as usize;
            map.push(FunctionMap {
                code_start: start,
                code_end: start + f.direct_size as usize,
                safepoints: f.safepoints.clone(),
            });
            let start = base + f.entry as usize;
            map.push(FunctionMap { code_start: start, code_end: start + f.entry_size as usize, safepoints: vec![] });
        }
        map.finish();
        vm.set_framemap(Rc::new(map));
        let entry: ProgramEntry = unsafe { std::mem::transmute(base + self.functions[0].direct as usize) };
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

    /// A linked description (the system linker's startup object's data)
    /// with the addresses the linker would have filled in.
    fn linked_bytes(interface: *const u8) -> Vec<u8> {
        let mut image = sample();
        image.code.clear();
        image.imports.clear();
        image.fixups.clear();
        let image = Image::linked(image.info, image.constants, image.statics, image.functions);
        let (mut bytes, interface_slot, slots) = image.linked_description();
        bytes[interface_slot..interface_slot + 8].copy_from_slice(&(interface as u64).to_le_bytes());
        for (i, (direct, entry)) in slots.into_iter().enumerate() {
            bytes[direct..direct + 8].copy_from_slice(&(0x1000 * (i as u64 + 1)).to_le_bytes());
            bytes[entry..entry + 8].copy_from_slice(&(0x1000 * (i as u64 + 1) + 0x800).to_le_bytes());
        }
        bytes
    }

    #[test]
    fn linked_description_round_trips() {
        static INTERFACE: u8 = 1;
        let bytes = linked_bytes(&INTERFACE);
        let loaded = unsafe { read_linked(bytes.as_ptr(), &INTERFACE) }.expect("read");
        assert_eq!(loaded.base, 0);
        assert_eq!(loaded.statics, 3);
        assert_eq!(loaded.info.functions[1].pnames, "a b");
        assert_eq!(loaded.constants, sample().constants);
        let addresses: Vec<(u64, u32, u64, u32)> = loaded.functions.iter().map(|f| (f.direct, f.direct_size, f.entry, f.entry_size)).collect();
        assert_eq!(addresses, [(0x1000, 16, 0x1800, 8), (0x2000, 4, 0x2800, 4)]);
        assert_eq!(loaded.functions[0].safepoints, vec![(5, vec![0, 8])]);
    }

    /// Every damage a description can have is refused before anything of it
    /// is used: another revision, no magic, counts out of bounds, another
    /// runtime's interface, an unlinked address, another runtime build's
    /// fingerprint, a stub image (with code) in its place, a function table
    /// that does not match.
    #[test]
    fn linked_description_rejects_damage() {
        static INTERFACE: u8 = 1;
        static OTHER: u8 = 1;
        let good = linked_bytes(&INTERFACE);
        let refused = |bytes: &[u8]| unsafe { read_linked(bytes.as_ptr(), &INTERFACE) }.err().expect("refused");
        let mut revision = good.clone();
        revision[7] = b'2';
        assert!(refused(&revision).contains("revision '2'"), "{}", refused(&revision));
        let mut magic = good.clone();
        magic[0] = b'X';
        assert_eq!(refused(&magic), "no program description (damaged executable)");
        let mut count = good.clone();
        count[8..16].copy_from_slice(&0u64.to_le_bytes());
        assert_eq!(refused(&count), "malformed program description");
        assert!(unsafe { read_linked(good.as_ptr(), &OTHER) }.err().unwrap().contains("another runtime's startup interface"));
        let mut unlinked = good.clone();
        unlinked[LINKED_HEADER..LINKED_HEADER + 8].copy_from_slice(&0u64.to_le_bytes());
        assert_eq!(refused(&unlinked), "program description has an unlinked function address");
        let mut fingerprint = good.clone();
        fingerprint[LINKED_HEADER + 32 + 4] ^= 1;
        assert!(refused(&fingerprint).contains("different native runtime build"));
        // A stub image's payload (machine code, fixups) in a description.
        let payload = sample().encode();
        let mut stub = good[..LINKED_HEADER + 32].to_vec();
        stub[16..24].copy_from_slice(&(payload.len() as u64).to_le_bytes());
        stub.extend_from_slice(&payload);
        assert!(refused(&stub).contains("carries machine code"));
        // A header that claims a function the metadata does not have: the
        // address table then overlaps the metadata, which no longer decodes
        // or no longer matches.
        let mut table = good.clone();
        table[8..16].copy_from_slice(&3u64.to_le_bytes());
        table.extend_from_slice(&[0; 16]);
        assert!(unsafe { read_linked(table.as_ptr(), &INTERFACE) }.is_err());
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
