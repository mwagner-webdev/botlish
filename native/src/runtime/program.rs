//! The program descriptor: everything a Vm needs to run a compiled program
//! except its machine code (NATIVE-LIBRARY-MILESTONE-1.md, "One startup").
//!
//! The compiler emits it into the program object itself (codegen's
//! `emit_object`), beside the code, as data:
//!
//! ```text
//!   botlish_program      LinkedProgram: magic, the runtime ABI fingerprint,
//!                        the descriptor's address and length, the code
//!                        table's address and length, the startup policy
//!   botlish_descriptor   the encoded ProgramDescriptor (read-only bytes)
//!   botlish_code         one (direct, generic entry) address pair per NIR
//!                        function, relocated by whatever links the object
//! ```
//!
//! and every way a compiled program starts reads exactly that, through
//! [`instantiate_linked`]: an executable linked by rustc (a fixed startup
//! crate that names `botlish_program`), an executable linked by the stub
//! (runtime::aotimage, which finds the record in its relocated image) and a
//! native library (runtime::library, whose trampolines pass the record's
//! address). The descriptor is one compiler product shared by all three, so
//! nothing has to generate startup code per program or extract it from an
//! executable's link.
//!
//! The descriptor holds the program metadata (`ProgramInfo`), the constant
//! pool, the module-static count, each function's code sizes and stack maps
//! (with the code table they become the frame map), and a library's exports.
use super::aot::ProgramEntry;
use super::constants::{self, Const};
use super::framemap::{FunctionMap, ProgramMap};
use super::metrics::AllocMode;
use super::value::{FloatType, Kind};
use super::vm::{EnumInfo, FunctionInfo, NativeInfo, ProgramInfo, ShapeInfo, Vm};
use crate::nir::{self, Boundary, ExportDecl, OpCode};
use std::rc::Rc;

/// The first word of a `LinkedProgram`.
pub const LINKED_MAGIC: u64 = u64::from_le_bytes(*b"BOTLPRG1");
/// The descriptor's own format revision, its first word.
const FORMAT: u32 = 1;

/// The record the compiler emits as `botlish_program` (module doc). Its
/// layout is a contract between codegen (which writes it as data) and this
/// runtime: seven machine words, in this order. The ABI fingerprint covers
/// it (runtime::aotimage's `abi_fingerprint`: its size and the startup
/// word's offset), so a runtime of another layout refuses a record before
/// it reads past the fingerprint.
#[repr(C)]
pub struct LinkedProgram {
    pub magic: u64,
    pub fingerprint: u64,
    pub descriptor: *const u8,
    pub descriptor_len: usize,
    /// `2 * functions` addresses: function N's direct entry at `2N`, its
    /// generic entry at `2N + 1`.
    pub code: *const usize,
    pub functions: usize,
    /// The executable's startup policy, `Startup::word`: where `aot::run`
    /// runs the program. Always the worker's (0) in a native library's
    /// record, whose host calls it on its own thread.
    pub startup: u64,
}

/// Which thread an executable runs its program on (MAIN-THREAD-STARTUP-
/// MILESTONE-1.md): a property of the executable, fixed when it is emitted
/// (codegen::aot's `emit_executable`) and recorded in its program record's
/// `startup` word, never chosen by the environment it is started in, a
/// library it links or anything the program declares. The program's
/// meaning is the same under both; what differs is the thread and its
/// stack.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Startup {
    /// Word 0, the default: a worker thread of its own, whose stack
    /// `BOTLISH_NATIVE_STACK_BYTES` sizes (1 GiB by default), started and
    /// joined by the process's main thread (`aot::run`).
    Worker,
    /// Word 1: the thread that entered the executable's `main` -- the
    /// process's main thread -- on its own stack, whose size the link
    /// reserved (macOS's LC_MAIN, 512 MiB: codegen::aot's
    /// `MAIN_THREAD_STACK_BYTES`). macOS AArch64 executables only
    /// (`aot::MAIN_THREAD_STARTUP`): AppKit, and so SDL3's Cocoa video
    /// driver, works on no other thread.
    MainThread,
}

impl Startup {
    /// The record's word for this policy.
    pub const fn word(self) -> u64 {
        match self {
            Startup::Worker => 0,
            Startup::MainThread => 1,
        }
    }

    /// The policy a record's word WORD names, or why it names none.
    pub fn of_word(word: u64) -> Result<Startup, String> {
        match word {
            0 => Ok(Startup::Worker),
            1 => Ok(Startup::MainThread),
            other => Err(format!("the program record names an unknown startup policy ({other})")),
        }
    }

    /// The policy's name, as every interface spells it: the driver's
    /// `--startup`, native::executable's `-startup`, main.tcl's
    /// `-native-startup` and the startup report.
    pub const fn spelling(self) -> &'static str {
        match self {
            Startup::Worker => "worker",
            Startup::MainThread => "main-thread",
        }
    }

    /// The policy named NAME (`spelling`'s inverse).
    pub fn parse(name: &str) -> Option<Startup> {
        match name {
            "worker" => Some(Startup::Worker),
            "main-thread" => Some(Startup::MainThread),
            _ => None,
        }
    }
}

// The record is immutable data the linker relocated: sharing it between
// threads is sharing read-only memory.
unsafe impl Sync for LinkedProgram {}

/// One function's code sizes and stack maps (codegen::clif's DefineResult):
/// its direct entry's safepoints, as (return-address offset, root offsets).
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct FunctionShape {
    pub direct_size: u32,
    pub entry_size: u32,
    pub safepoints: Vec<(u32, Vec<u32>)>,
}

pub struct ProgramDescriptor {
    pub info: Rc<ProgramInfo>,
    pub constants: Vec<Const>,
    pub statics: u32,
    /// Indexed by NIR function id; function 0 is the program's entry.
    pub functions: Vec<FunctionShape>,
    /// A native library's exports (NIR's `export` declarations); empty for
    /// an executable.
    pub exports: Vec<ExportDecl>,
}

/// The runtime metadata of PROGRAM (`ProgramInfo`): what the JIT driver,
/// and through the descriptor every linked program, gives its Vm.
pub fn program_info(program: &nir::Program) -> ProgramInfo {
    ProgramInfo {
        functions: program
            .functions
            .iter()
            .map(|f| FunctionInfo { arity: f.params as usize, pnames: f.pnames.clone() })
            .collect(),
        natives: program
            .natives
            .iter()
            .map(|n| NativeInfo { name: n.name.clone(), arity: n.arity, params: n.params.clone(), op: n.op })
            .collect(),
        shapes: program
            .shapes
            .iter()
            .map(|s| ShapeInfo { name: s.name.clone(), fields: s.fields.clone(), opaque: s.opaque })
            .collect(),
        enums: program.enums.iter().map(|e| EnumInfo { name: e.name.clone(), cases: e.cases.clone() }).collect(),
        errors: program.errors.clone(),
    }
}

// ---------------------------------------------------------------- encoding

pub(crate) struct Writer(pub(crate) Vec<u8>);

impl Writer {
    pub(crate) fn u32(&mut self, v: u32) {
        self.0.extend_from_slice(&v.to_le_bytes());
    }
    pub(crate) fn u64(&mut self, v: u64) {
        self.0.extend_from_slice(&v.to_le_bytes());
    }
    pub(crate) fn i64(&mut self, v: i64) {
        self.0.extend_from_slice(&v.to_le_bytes());
    }
    pub(crate) fn len(&mut self, n: usize) {
        self.u64(n as u64);
    }
    pub(crate) fn bytes(&mut self, b: &[u8]) {
        self.len(b.len());
        self.0.extend_from_slice(b);
    }
    pub(crate) fn str(&mut self, s: &str) {
        self.bytes(s.as_bytes());
    }
    pub(crate) fn opt_str(&mut self, s: Option<&str>) {
        match s {
            Some(s) => {
                self.u32(1);
                self.str(s);
            }
            None => self.u32(0),
        }
    }
}

pub(crate) struct Reader<'a> {
    pub(crate) data: &'a [u8],
    pub(crate) at: usize,
}

impl<'a> Reader<'a> {
    pub(crate) fn take(&mut self, n: usize) -> Result<&'a [u8], String> {
        let end = self.at.checked_add(n).filter(|&end| end <= self.data.len()).ok_or("truncated program descriptor")?;
        let slice = &self.data[self.at..end];
        self.at = end;
        Ok(slice)
    }
    pub(crate) fn u32(&mut self) -> Result<u32, String> {
        Ok(u32::from_le_bytes(self.take(4)?.try_into().unwrap()))
    }
    pub(crate) fn u64(&mut self) -> Result<u64, String> {
        Ok(u64::from_le_bytes(self.take(8)?.try_into().unwrap()))
    }
    pub(crate) fn i64(&mut self) -> Result<i64, String> {
        Ok(i64::from_le_bytes(self.take(8)?.try_into().unwrap()))
    }
    pub(crate) fn len(&mut self) -> Result<usize, String> {
        usize::try_from(self.u64()?).map_err(|e| e.to_string())
    }
    pub(crate) fn bytes(&mut self) -> Result<Vec<u8>, String> {
        let n = self.len()?;
        Ok(self.take(n)?.to_vec())
    }
    pub(crate) fn str(&mut self) -> Result<String, String> {
        String::from_utf8(self.bytes()?).map_err(|e| e.to_string())
    }
    pub(crate) fn opt_str(&mut self) -> Result<Option<String>, String> {
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
    fn boundary(&mut self) -> Result<Boundary, String> {
        let word = self.str()?;
        Boundary::parse(&word).ok_or_else(|| format!("unknown boundary type {word:?}"))
    }
}

impl ProgramDescriptor {
    pub fn encode(&self) -> Vec<u8> {
        let mut w = Writer(Vec::new());
        w.u32(FORMAT);
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
        w.len(info.errors.len());
        for (id, name) in &info.errors {
            w.u32(*id);
            w.str(name);
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
        w.len(self.functions.len());
        for f in &self.functions {
            w.u32(f.direct_size);
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
        w.len(self.exports.len());
        for e in &self.exports {
            w.str(&e.symbol);
            w.u32(e.func);
            w.len(e.params.len());
            for p in &e.params {
                w.str(p.spelling());
            }
            w.str(e.result.spelling());
        }
        w.0
    }

    pub fn decode(data: &[u8]) -> Result<ProgramDescriptor, String> {
        let mut r = Reader { data, at: 0 };
        let format = r.u32()?;
        if format != FORMAT {
            return Err(format!("program descriptor format {format}, this runtime reads format {FORMAT}"));
        }
        let mut info =
            ProgramInfo { functions: Vec::new(), natives: Vec::new(), shapes: Vec::new(), enums: Vec::new(), errors: Vec::new() };
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
        for _ in 0..r.len()? {
            let id = r.u32()?;
            info.errors.push((id, r.str()?));
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
        let mut functions = Vec::new();
        for _ in 0..r.len()? {
            let direct_size = r.u32()?;
            let entry_size = r.u32()?;
            let mut safepoints = Vec::new();
            for _ in 0..r.len()? {
                let pc = r.u32()?;
                let roots = (0..r.len()?).map(|_| r.u32()).collect::<Result<Vec<_>, _>>()?;
                safepoints.push((pc, roots));
            }
            functions.push(FunctionShape { direct_size, entry_size, safepoints });
        }
        let mut exports = Vec::new();
        for _ in 0..r.len()? {
            let symbol = r.str()?;
            let func = r.u32()?;
            let params = (0..r.len()?).map(|_| r.boundary()).collect::<Result<Vec<_>, _>>()?;
            let result = r.boundary()?;
            exports.push(ExportDecl { symbol, func, params, result });
        }
        if r.at != data.len() {
            return Err("trailing bytes after the program descriptor".to_string());
        }
        if functions.is_empty() || functions.len() != info.functions.len() {
            return Err("malformed program descriptor".to_string());
        }
        if exports.iter().any(|e| e.func as usize >= functions.len() || e.func == 0) {
            return Err("program descriptor export out of range".to_string());
        }
        Ok(ProgramDescriptor { info: Rc::new(info), constants, statics, functions, exports })
    }
}

/// The program's Vm, made on the calling thread (the one its code will run
/// on: the Vm records that thread's stack): metadata, constants, statics and
/// the frame map of DESCRIPTOR, with CODE (function N's direct and generic
/// entry addresses) where the machine code is. Returns the Vm and the
/// program's entry (function 0's direct entry).
pub fn instantiate(descriptor: &ProgramDescriptor, code: &[(usize, usize)]) -> (Box<Vm>, ProgramEntry) {
    let mut vm = Vm::new(descriptor.info.clone(), AllocMode::Off);
    let entries: Vec<usize> = code.iter().map(|&(_, entry)| entry).collect();
    constants::install(&mut vm, &descriptor.constants, &entries, descriptor.statics);
    let mut map = ProgramMap::new();
    for (f, &(direct, entry)) in descriptor.functions.iter().zip(code) {
        map.push(FunctionMap { code_start: direct, code_end: direct + f.direct_size as usize, safepoints: f.safepoints.clone() });
        map.push(FunctionMap { code_start: entry, code_end: entry + f.entry_size as usize, safepoints: vec![] });
    }
    map.finish();
    vm.set_framemap(Rc::new(map));
    // SAFETY: code[0].0 is function 0's direct entry, which the compiler
    // emits with the ProgramEntry signature.
    let entry: ProgramEntry = unsafe { std::mem::transmute(code[0].0) };
    (vm, entry)
}

/// The startup policy of the linked record LINKED, checked: the magic and
/// this runtime's ABI fingerprint first (a record of another runtime build
/// may have another layout, whose startup word is not where this one reads
/// it: the fingerprint covers the record's layout), then the word itself --
/// a policy this runtime does not know is refused, never taken for the
/// default. Reads nothing the record points at: what an executable's
/// startup asks before it decides which thread builds the Vm
/// (`aot::start_linked`).
///
/// # Safety
/// LINKED must be readable as a `LinkedProgram`'s magic and fingerprint,
/// and, when both are this runtime's, as the whole record.
pub unsafe fn linked_startup(linked: &LinkedProgram) -> Result<Startup, String> {
    if linked.magic != LINKED_MAGIC {
        return Err("not a Botlish program record".to_string());
    }
    if linked.fingerprint != super::aotimage::abi_fingerprint() {
        return Err("the program was compiled for a different native runtime build".to_string());
    }
    Startup::of_word(linked.startup)
}

/// The descriptor and code table a linked record LINKED points at, checked:
/// the magic, this runtime's ABI fingerprint (a program object compiled
/// against another runtime build addresses fields that are not there), its
/// startup policy (`linked_startup`) and a code table of one pair per
/// described function.
///
/// # Safety
/// LINKED must be a `LinkedProgram` the compiler emitted, relocated by its
/// link (its pointers valid for their lengths).
pub unsafe fn read_linked(linked: &LinkedProgram) -> Result<(ProgramDescriptor, Vec<(usize, usize)>), String> {
    // SAFETY: the caller's contract.
    unsafe { linked_startup(linked) }?;
    // SAFETY: the caller's contract.
    let bytes = unsafe { std::slice::from_raw_parts(linked.descriptor, linked.descriptor_len) };
    let descriptor = ProgramDescriptor::decode(bytes)?;
    if linked.functions != descriptor.functions.len() {
        return Err("the program record's code table does not match its descriptor".to_string());
    }
    // SAFETY: the caller's contract.
    let words = unsafe { std::slice::from_raw_parts(linked.code, 2 * linked.functions) };
    let code = words.chunks_exact(2).map(|pair| (pair[0], pair[1])).collect();
    Ok((descriptor, code))
}

/// The Vm and entry of the linked program LINKED: `read_linked`, then
/// `instantiate`. The executables' one startup (codegen::aot's startup
/// crate, runtime::aotimage's loader).
///
/// # Safety
/// As `read_linked`.
pub unsafe fn instantiate_linked(linked: &LinkedProgram) -> Result<(Box<Vm>, ProgramEntry), String> {
    // SAFETY: the caller's contract.
    let (descriptor, code) = unsafe { read_linked(linked) }?;
    Ok(instantiate(&descriptor, &code))
}

#[cfg(test)]
mod tests {
    use super::*;

    fn sample() -> ProgramDescriptor {
        ProgramDescriptor {
            info: Rc::new(ProgramInfo {
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
                errors: vec![(1, "Rejected".into()), (0x4000_0001, "IndexNotFound".into())],
            }),
            constants: vec![
                Const::Str("h\u{e9}llo \u{1f600}".into()),
                Const::Bytes(vec![0, 255, 10]),
                Const::BigInt("-123456789012345678901234567890".into()),
                Const::Float(FloatType::Float64, 1.5f64.to_bits()),
                Const::Native(1),
                Const::FnValue(1),
            ],
            statics: 3,
            functions: vec![
                FunctionShape { direct_size: 16, entry_size: 8, safepoints: vec![(5, vec![0, 8])] },
                FunctionShape { direct_size: 4, entry_size: 4, safepoints: vec![] },
            ],
            exports: vec![ExportDecl { symbol: "lib_f".into(), func: 1, params: vec![Boundary::Int, Boundary::Str], result: Boundary::Unit }],
        }
    }

    #[test]
    fn program_descriptor_round_trips() {
        let descriptor = sample();
        let decoded = ProgramDescriptor::decode(&descriptor.encode()).expect("decode");
        assert_eq!(decoded.encode(), descriptor.encode());
        assert_eq!(decoded.constants, descriptor.constants);
        assert_eq!(decoded.functions, descriptor.functions);
        assert_eq!(decoded.exports, descriptor.exports);
        assert_eq!(decoded.info.natives[0].op, OpCode::StrLen);
        assert_eq!(decoded.info.natives[1].arity, None);
        assert_eq!(decoded.info.shapes[1].name.as_deref(), Some("m::Point"));
        assert!(decoded.info.shapes[1].opaque);
        assert_eq!(decoded.info.errors, descriptor.info.errors);
    }

    #[test]
    fn program_descriptor_rejects_damage() {
        let bytes = sample().encode();
        assert!(ProgramDescriptor::decode(&bytes[..bytes.len() - 1]).is_err());
        let mut longer = bytes.clone();
        longer.push(0);
        assert!(ProgramDescriptor::decode(&longer).is_err());
        let mut out_of_range = sample();
        out_of_range.exports[0].func = 7;
        assert!(ProgramDescriptor::decode(&out_of_range.encode()).is_err());
        let mut the_program = sample();
        the_program.exports[0].func = 0;
        assert!(ProgramDescriptor::decode(&the_program.encode()).is_err());
    }

    #[test]
    fn program_descriptor_op_spellings_round_trip() {
        // Every operation a NIR native can name survives the descriptor's
        // encoding by spelling (nir.rs's op_spellings!).
        for op in [OpCode::IAdd, OpCode::StrIsTclAlpha, OpCode::SyscallLinuxX86_64, OpCode::AsciiShortEq] {
            assert_eq!(OpCode::parse(op.spelling()), Some(op));
        }
    }

    /// A record whose magic or fingerprint is another's is refused before
    /// anything it points at is read.
    #[test]
    fn linked_program_refuses_a_foreign_record() {
        let bytes = sample().encode();
        let code = [0usize; 4];
        let mut linked = LinkedProgram {
            magic: LINKED_MAGIC,
            fingerprint: super::super::aotimage::abi_fingerprint(),
            descriptor: bytes.as_ptr(),
            descriptor_len: bytes.len(),
            code: code.as_ptr(),
            functions: 2,
            startup: Startup::Worker.word(),
        };
        assert!(unsafe { read_linked(&linked) }.is_ok());
        linked.fingerprint ^= 1;
        assert!(matches!(unsafe { read_linked(&linked) }, Err(e) if e.contains("different native runtime build")));
        linked.fingerprint ^= 1;
        linked.magic = 0;
        assert!(unsafe { read_linked(&linked) }.is_err());
        linked.magic = LINKED_MAGIC;
        linked.functions = 3;
        assert!(unsafe { read_linked(&linked) }.is_err());
    }

    /// The startup word: each policy's, read back; an unknown one refused by
    /// the policy read and by the whole record's, never taken for the
    /// default; a record of another magic or fingerprint refused before its
    /// word is read.
    #[test]
    fn linked_program_startup_policy() {
        let bytes = sample().encode();
        let code = [0usize; 4];
        let mut linked = LinkedProgram {
            magic: LINKED_MAGIC,
            fingerprint: super::super::aotimage::abi_fingerprint(),
            descriptor: bytes.as_ptr(),
            descriptor_len: bytes.len(),
            code: code.as_ptr(),
            functions: 2,
            startup: Startup::Worker.word(),
        };
        for policy in [Startup::Worker, Startup::MainThread] {
            linked.startup = policy.word();
            assert_eq!(unsafe { linked_startup(&linked) }, Ok(policy));
            assert!(unsafe { read_linked(&linked) }.is_ok());
            assert_eq!(Startup::parse(policy.spelling()), Some(policy));
        }
        assert_eq!((Startup::Worker.word(), Startup::MainThread.word()), (0, 1));
        for word in [2, 0x100, u64::MAX] {
            linked.startup = word;
            assert!(matches!(unsafe { linked_startup(&linked) }, Err(e) if e.contains("unknown startup policy")));
            assert!(unsafe { read_linked(&linked) }.is_err());
        }
        linked.startup = Startup::MainThread.word();
        linked.fingerprint ^= 1;
        assert!(matches!(unsafe { linked_startup(&linked) }, Err(e) if e.contains("different native runtime build")));
        linked.fingerprint ^= 1;
        linked.magic = 0;
        assert!(matches!(unsafe { linked_startup(&linked) }, Err(e) if e.contains("not a Botlish program record")));
        assert_eq!(Startup::parse("main"), None);
        assert_eq!(std::mem::size_of::<LinkedProgram>(), 56);
        assert_eq!(std::mem::offset_of!(LinkedProgram, startup), 48);
    }
}
