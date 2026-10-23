//! The program descriptor: a compiled program's startup data as an explicit
//! compiler product (NATIVE-LIBRARY-MILESTONE-1.md, "The program
//! descriptor").
//!
//! Everything a Vm needs to run a compiled program besides its machine code
//! -- the program metadata (`ProgramInfo`), the constant pool, the
//! module-static count, every function's code size and stack-map table, and
//! for a native library its C exports and the canonical identity of every
//! declared error id -- is one `ProgramData`, encoded as bytes. The program
//! object `codegen::emit_object` writes carries it as two data objects:
//!
//! ```text
//!   botlish_program        a Descriptor: magic, format, the ABI
//!                          fingerprint, the encoded data's address and
//!                          length, the function count, then each
//!                          function's direct and generic entry address
//!                          (relocations the linker resolves)
//!   botlish_program_data   the encoded ProgramData
//! ```
//!
//! Every way a program starts builds its Vm here, by `build_vm`:
//!
//!   * a rustc-linked executable's generated startup crate (codegen/aot.rs's
//!     `startup`) names `botlish_program` and calls `start`;
//!   * a native library's instance creation (runtime::library) reads the
//!     library's own descriptor;
//!   * a stub-linked executable's loader (runtime::aotimage) builds the same
//!     Vm from its image, whose metadata is encoded by the same functions.
//!
//! So nothing generated in Rust holds program data, and a library's startup
//! needs no executable: the descriptor is data in the object, read by the
//! runtime the object is linked with. The format is private to one build:
//! the descriptor records the ABI fingerprint of the driver that wrote it,
//! and a runtime of another build refuses it.
use super::aot::ProgramEntry;
use super::constants::{self, Const};
use super::framemap::{FunctionMap, ProgramMap};
use super::metrics::AllocMode;
use super::value::{FloatType, Kind};
use super::vm::{EnumInfo, FunctionInfo, NativeInfo, ProgramInfo, ShapeInfo, Vm};
use crate::nir::{self, Boundary, OpCode};
use std::rc::Rc;

/// The first word of a descriptor: "BOTLPRG1".
pub const DESCRIPTOR_MAGIC: u64 = u64::from_le_bytes(*b"BOTLPRG1");
/// The descriptor's own format revision.
pub const DESCRIPTOR_FORMAT: u64 = 1;
/// The bytes of a descriptor before its function table.
pub const DESCRIPTOR_HEADER_BYTES: usize = 48;

/// A program descriptor as the program object lays it out (the module doc):
/// six words, then `count` pairs of code addresses (direct, generic entry).
#[repr(C)]
pub struct Descriptor {
    pub magic: u64,
    pub format: u64,
    pub fingerprint: u64,
    pub data: *const u8,
    pub data_len: u64,
    pub count: u64,
    pub code: [[usize; 2]; 0],
}

/// One function's code metadata: the sizes of its direct function and its
/// generic entry, and the direct function's safepoints (return-address
/// offset, live-root offsets).
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct FunctionMeta {
    pub direct_size: u32,
    pub entry_size: u32,
    pub safepoints: Vec<(u32, Vec<u32>)>,
}

/// A native library's export, as its runtime calls it (nir::ExportDecl).
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct ExportMeta {
    pub symbol: String,
    pub name: String,
    pub func: u32,
    pub params: Vec<Boundary>,
    pub result: Boundary,
}

/// Everything but the machine code (the module doc).
pub struct ProgramData {
    pub info: ProgramInfo,
    pub constants: Vec<Const>,
    pub statics: u32,
    pub functions: Vec<FunctionMeta>,
    /// The native library's C name, None for an ordinary program.
    pub library: Option<String>,
    pub exports: Vec<ExportMeta>,
    pub errors: Vec<(u32, String)>,
}

/// The program metadata of a NIR program, as every startup installs it.
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
    }
}

impl ProgramData {
    /// The data of PROGRAM, compiled with constant pool CONSTANTS and
    /// function metadata FUNCTIONS (codegen::emit_object's).
    pub fn of(program: &nir::Program, constants: Vec<Const>, functions: Vec<FunctionMeta>) -> ProgramData {
        ProgramData {
            info: program_info(program),
            constants,
            statics: program.statics,
            functions,
            library: program.library.clone(),
            exports: program
                .exports
                .iter()
                .map(|e| ExportMeta {
                    symbol: e.symbol.clone(),
                    name: e.name.clone(),
                    func: e.func,
                    params: e.params.clone(),
                    result: e.result,
                })
                .collect(),
            errors: program.errors.clone(),
        }
    }

    pub fn encode(&self) -> Vec<u8> {
        let mut w = Writer(Vec::new());
        encode_info(&mut w, &self.info);
        encode_constants(&mut w, &self.constants);
        w.u32(self.statics);
        w.len(self.functions.len());
        for f in &self.functions {
            w.u32(f.direct_size);
            w.u32(f.entry_size);
            encode_safepoints(&mut w, &f.safepoints);
        }
        w.opt_str(self.library.as_deref());
        w.len(self.exports.len());
        for e in &self.exports {
            w.str(&e.symbol);
            w.str(&e.name);
            w.u32(e.func);
            w.len(e.params.len());
            for p in &e.params {
                w.str(p.name());
            }
            w.str(e.result.name());
        }
        w.len(self.errors.len());
        for (id, name) in &self.errors {
            w.u32(*id);
            w.str(name);
        }
        w.0
    }

    pub fn decode(data: &[u8]) -> Result<ProgramData, String> {
        let mut r = Reader { data, at: 0 };
        let info = decode_info(&mut r)?;
        let constants = decode_constants(&mut r)?;
        let statics = r.u32()?;
        let mut functions = Vec::new();
        for _ in 0..r.len()? {
            let direct_size = r.u32()?;
            let entry_size = r.u32()?;
            functions.push(FunctionMeta { direct_size, entry_size, safepoints: decode_safepoints(&mut r)? });
        }
        let library = r.opt_str()?;
        let mut exports = Vec::new();
        for _ in 0..r.len()? {
            let symbol = r.str()?;
            let name = r.str()?;
            let func = r.u32()?;
            let params = (0..r.len()?).map(|_| r.boundary()).collect::<Result<Vec<_>, _>>()?;
            let result = r.boundary()?;
            if func as usize >= functions.len() {
                return Err(format!("export {symbol} names no function"));
            }
            exports.push(ExportMeta { symbol, name, func, params, result });
        }
        let mut errors = Vec::new();
        for _ in 0..r.len()? {
            errors.push((r.u32()?, r.str()?));
        }
        if r.at != data.len() {
            return Err("trailing bytes after the program data".to_string());
        }
        if functions.len() != info.functions.len() || functions.is_empty() {
            return Err("malformed program data".to_string());
        }
        Ok(ProgramData { info, constants, statics, functions, library, exports, errors })
    }
}

/// The program data and code addresses of the descriptor at DESCRIPTOR.
///
/// # Safety
/// DESCRIPTOR must point to a descriptor a program object holds (the module
/// doc), linked: its data pointer and table addresses relocated.
pub unsafe fn read(descriptor: *const Descriptor) -> Result<(ProgramData, Vec<[usize; 2]>), String> {
    if descriptor.is_null() {
        return Err("no program descriptor".to_string());
    }
    let d = unsafe { &*descriptor };
    if d.magic != DESCRIPTOR_MAGIC {
        return Err("not a Botlish program descriptor".to_string());
    }
    if d.format != DESCRIPTOR_FORMAT {
        return Err(format!("program descriptor format {}, this runtime reads format {DESCRIPTOR_FORMAT}", d.format));
    }
    if d.fingerprint != super::aotimage::abi_fingerprint() {
        return Err("the program was compiled for a different native runtime build".to_string());
    }
    let length = usize::try_from(d.data_len).map_err(|e| e.to_string())?;
    let bytes = unsafe { std::slice::from_raw_parts(d.data, length) };
    let data = ProgramData::decode(bytes)?;
    let count = usize::try_from(d.count).map_err(|e| e.to_string())?;
    if count != data.functions.len() {
        return Err("program descriptor function table does not match its data".to_string());
    }
    let code = unsafe { std::slice::from_raw_parts(d.code.as_ptr(), count) }.to_vec();
    Ok((data, code))
}

/// The Vm of a program: its metadata INFO, constants CONSTANTS, STATICS
/// module-static slots, and its functions' code CODE (direct and generic
/// entry addresses, in function order) with their metadata FUNCTIONS. The
/// one construction every startup shares (the module doc): constants and
/// static slots installed, the stack-map table built from the linked code
/// addresses. No Botlish code has run.
pub fn build_vm(
    info: ProgramInfo,
    constants: &[Const],
    statics: u32,
    code: &[[usize; 2]],
    functions: &[FunctionMeta],
    alloc_mode: AllocMode,
) -> Box<Vm> {
    let vm = Vm::new(Rc::new(info), alloc_mode);
    install(vm, constants, statics, code, functions)
}

/// `build_vm`, for code that runs on NATIVE_STACK (runtime::library: the
/// calling thread's, which the caller found itself).
pub fn build_vm_on(
    info: ProgramInfo,
    constants: &[Const],
    statics: u32,
    code: &[[usize; 2]],
    functions: &[FunctionMeta],
    alloc_mode: AllocMode,
    native_stack: Option<super::native_stack::NativeStack>,
) -> Box<Vm> {
    let vm = Vm::with_stack(Rc::new(info), alloc_mode, native_stack);
    install(vm, constants, statics, code, functions)
}

fn install(mut vm: Box<Vm>, constants: &[Const], statics: u32, code: &[[usize; 2]], functions: &[FunctionMeta]) -> Box<Vm> {
    let entries: Vec<usize> = code.iter().map(|c| c[1]).collect();
    constants::install(&mut vm, constants, &entries, statics);
    let mut map = ProgramMap::new();
    for (c, f) in code.iter().zip(functions) {
        map.push(FunctionMap { code_start: c[0], code_end: c[0] + f.direct_size as usize, safepoints: f.safepoints.clone() });
        map.push(FunctionMap { code_start: c[1], code_end: c[1] + f.entry_size as usize, safepoints: vec![] });
    }
    map.finish();
    vm.set_framemap(Rc::new(map));
    vm
}

/// A rustc-linked executable's startup (codegen/aot.rs's `startup`): the Vm
/// of the program its object's DESCRIPTOR describes and the program's entry,
/// function 0's direct function. A descriptor this runtime cannot read ends
/// the process with a NATIVE STARTUP report.
pub fn start(descriptor: &Descriptor) -> (Box<Vm>, ProgramEntry) {
    match unsafe { read(descriptor) } {
        Ok((data, code)) => {
            let vm = build_vm(data.info, &data.constants, data.statics, &code, &data.functions, AllocMode::Off);
            // SAFETY: function 0 is the program, whose direct function has
            // the ProgramEntry signature (codegen::clif).
            let entry: ProgramEntry = unsafe { std::mem::transmute(code[0][0]) };
            (vm, entry)
        }
        Err(error) => {
            eprintln!("{error} (NATIVE STARTUP)");
            std::process::exit(1);
        }
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
        let end = self.at.checked_add(n).filter(|&end| end <= self.data.len()).ok_or("truncated program data")?;
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
        let name = self.str()?;
        Boundary::parse(&name).ok_or_else(|| format!("unknown boundary representation {name:?}"))
    }
}

/// The program metadata INFO.
pub(crate) fn encode_info(w: &mut Writer, info: &ProgramInfo) {
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
}

pub(crate) fn decode_info(r: &mut Reader) -> Result<ProgramInfo, String> {
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
    Ok(info)
}

/// The constant pool CONSTANTS.
pub(crate) fn encode_constants(w: &mut Writer, constants: &[Const]) {
    w.len(constants.len());
    for c in constants {
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
}

pub(crate) fn decode_constants(r: &mut Reader) -> Result<Vec<Const>, String> {
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
    Ok(constants)
}

/// A function's safepoint table.
pub(crate) fn encode_safepoints(w: &mut Writer, safepoints: &[(u32, Vec<u32>)]) {
    w.len(safepoints.len());
    for (pc, roots) in safepoints {
        w.u32(*pc);
        w.len(roots.len());
        for root in roots {
            w.u32(*root);
        }
    }
}

pub(crate) fn decode_safepoints(r: &mut Reader) -> Result<Vec<(u32, Vec<u32>)>, String> {
    let mut safepoints = Vec::new();
    for _ in 0..r.len()? {
        let pc = r.u32()?;
        let roots = (0..r.len()?).map(|_| r.u32()).collect::<Result<Vec<_>, _>>()?;
        safepoints.push((pc, roots));
    }
    Ok(safepoints)
}

#[cfg(test)]
mod tests {
    use super::*;

    fn sample() -> ProgramData {
        ProgramData {
            info: ProgramInfo {
                functions: vec![FunctionInfo { arity: 0, pnames: String::new() }, FunctionInfo { arity: 2, pnames: "a b".into() }],
                natives: vec![NativeInfo { name: "std::str::length".into(), arity: Some(1), params: vec![Some(Kind::Str)], op: OpCode::StrLen }],
                shapes: vec![ShapeInfo { name: None, fields: vec!["code".into()], opaque: false }],
                enums: vec![EnumInfo { name: "Color".into(), cases: vec!["Red".into()] }],
            },
            constants: vec![Const::Str("x".into()), Const::FnValue(1), Const::BigInt("-123456789012345678901234567890".into())],
            statics: 2,
            functions: vec![
                FunctionMeta { direct_size: 16, entry_size: 8, safepoints: vec![(5, vec![0, 8])] },
                FunctionMeta { direct_size: 4, entry_size: 4, safepoints: vec![] },
            ],
            library: Some("lib".into()),
            exports: vec![ExportMeta {
                symbol: "lib_f".into(),
                name: "f".into(),
                func: 1,
                params: vec![Boundary::Int, Boundary::Str],
                result: Boundary::Unit,
            }],
            errors: vec![(1, "Rejected".into()), (0x4000_0001, "IndexNotFound".into())],
        }
    }

    #[test]
    fn program_data_round_trips() {
        let data = sample();
        let decoded = ProgramData::decode(&data.encode()).expect("decode");
        assert_eq!(decoded.encode(), data.encode());
        assert_eq!(decoded.exports, data.exports);
        assert_eq!(decoded.errors, data.errors);
        assert_eq!(decoded.functions, data.functions);
        assert_eq!(decoded.library.as_deref(), Some("lib"));
    }

    #[test]
    fn program_data_rejects_damage() {
        let bytes = sample().encode();
        assert!(ProgramData::decode(&bytes[..bytes.len() - 1]).is_err());
        let mut longer = bytes.clone();
        longer.push(0);
        assert!(ProgramData::decode(&longer).is_err());
    }

    #[test]
    fn a_descriptor_is_read_back() {
        let data = sample();
        let bytes = data.encode();
        let mut words: Vec<usize> = vec![
            DESCRIPTOR_MAGIC as usize,
            DESCRIPTOR_FORMAT as usize,
            super::super::aotimage::abi_fingerprint() as usize,
            bytes.as_ptr() as usize,
            bytes.len(),
            2,
        ];
        assert_eq!(words.len() * 8, DESCRIPTOR_HEADER_BYTES);
        words.extend([0x1000, 0x2000, 0x3000, 0x4000]);
        let (read_back, code) = unsafe { read(words.as_ptr() as *const Descriptor) }.expect("read");
        assert_eq!(code, vec![[0x1000, 0x2000], [0x3000, 0x4000]]);
        assert_eq!(read_back.exports, data.exports);
        words[2] ^= 1;
        assert!(matches!(unsafe { read(words.as_ptr() as *const Descriptor) }, Err(e) if e.contains("different native runtime build")));
        words[2] ^= 1;
        words[0] = 0;
        assert!(unsafe { read(words.as_ptr() as *const Descriptor) }.is_err());
    }
}
