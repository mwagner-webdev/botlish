//! Transfer (SENDABILITY-AND-VALUE-COPY-MILESTONE-1.md): the native codec of
//! `std::transfer`.
//!
//!   `transferencode %v %plan %fns`   rt_transfer_encode: the
//!                                    std::abi::bytes::Bytes of V's encoding
//!   `transferdecode %d %plan %fns`   rt_transfer_decode: the value the bytes
//!                                    of D hold, built of fresh objects of
//!                                    this Vm, or a declared refusal
//!
//! The format is core/transfer.tcl's, byte for byte: the Tcl backends'
//! codec is the reference, this one writes and reads exactly its bytes, so a
//! value crosses between any two backends. What differs is only how the
//! schema is read: native lowering resolves it, once per call site, into a
//! *plan* (native/lower.tcl's TransferPlan) whose struct shapes and enum
//! numbers are this program's own, and the plan is the String constant the
//! operation receives. Nothing of the plan enters the bytes.
//!
//! Both walks are iterative: a value's depth is bounded by memory, never by
//! the host's stack (a work stack of nodes, its values in `Vm::temp_roots`).
//!
//! Rooting. Encoding allocates nothing but its result until the end, and
//! runs Botlish code only through a `through` node's projection, a
//! collection point: every value whose encoding is still pending sits on
//! `temp_roots`, as do the function List and the value being projected, so
//! a collection there frees nothing the walk still reads. Decoding keeps
//! every value it has made (and not yet put into its container) on
//! `temp_roots`, a stack: a composite is built from its parts while they
//! are still rooted, then replaces them. The input's storage is rooted for
//! the whole decode (the reader reads its payload in place: objects never
//! move).
//!
//! Decoding trusts nothing: a count never exceeds what the remaining bytes
//! can hold (TransferMalformed) or the zero-size budget (TransferLimit), an
//! Int's length is bounded, every scalar is checked against its type, and no
//! malformed input reaches a panic or `NATIVE BUG`. A decoded value is built
//! with this Vm's own constructors only -- Strings, byte storage,
//! collections and their backings made anew, a set deduplicated by this
//! runtime's equality (ops::new_set_of), an owner's `through` rebuild
//! computing its own derived state -- and nothing of the bytes is kept.

use super::error::{
    RtError, ERR_TRANSFER_INVALID_VALUE, ERR_TRANSFER_LIMIT, ERR_TRANSFER_MALFORMED, ERR_TRANSFER_TYPE_MISMATCH,
    ERR_TRANSFER_VERSION,
};
use super::ops::{fail_builtin, new_array_of, new_set_of, rt_call_value};
use super::value::*;
use super::vm::{ProgramInfo, Vm};
use num_bigint::BigInt;
use num_traits::ToPrimitive;
use std::cmp::Ordering;
use std::rc::Rc;

fn vm<'a>(p: *mut Vm) -> &'a mut Vm {
    unsafe { &mut *p }
}

/// The four bytes every transfer starts with.
const MAGIC: &[u8; 4] = b"BOTX";
/// The format version this runtime reads (core::transfer's `version`).
const VERSION: u8 = 1;
/// The header's size: magic, version, fingerprint.
const HEADER: usize = 13;
/// The largest Int byte count a decode accepts (core::transfer's
/// `maxIntBytes`, 8 Mi bits).
const MAX_INT_BYTES: u64 = 1 << 20;
/// The zero-size elements one decode may make (`zeroBudget`).
const ZERO_BUDGET: i64 = 1 << 24;
/// The largest varuint (`maxVaruint`).
const MAX_VARUINT: u64 = (1 << 62) - 1;

// ---------------------------------------------------------------------------
// The plan

/// A resolved schema (native/lower.tcl's TransferPlan): its nodes, node 0
/// the root, with this program's shapes and enum numbers.
pub struct Plan {
    version: u8,
    fingerprint: u64,
    /// The shape of `std::abi::bytes::Bytes` (encode's result).
    bytes_shape: u32,
    nodes: Vec<Node>,
    /// The fewest bytes a value of each node takes (core::transfer::MinSizes).
    min: Vec<u64>,
}

enum Node {
    Unit,
    Bool,
    Char,
    Float64,
    Decimal,
    Raw32,
    Raw64,
    Str,
    /// An Int and the integer domains every value belongs to.
    Int(Vec<Domain>),
    /// A List of the element node, of the stated length if any.
    List { elem: usize, length: Option<u64> },
    Set(usize),
    Vector(usize),
    Array(usize),
    /// A struct of SHAPE (SLOTS fields), its fields in wire order as
    /// (slot, node).
    Struct { shape: u32, slots: usize, wire: Vec<(usize, usize)> },
    /// A case of enum NUMBER: CASES the case number of each sorted index,
    /// INDEX_OF its inverse (u32::MAX for no index).
    Enum { number: u32, cases: Vec<u32>, index_of: Vec<u32> },
    /// A one-field opaque struct of SHAPE holding a byte storage.
    Bytes(u32),
    MutBytes(u32),
    /// An opaque struct its owner projects to node R with function K and
    /// rebuilds with K + 1.
    Through { r: usize, k: usize },
}

enum Domain {
    Interval(Num, Num),
    /// Sorted ascending.
    Exact(Vec<Num>),
}

/// An integer bound of a domain: its value, and the value as an i128 when
/// it is one (the fast comparison).
struct Num {
    big: BigInt,
    small: Option<i128>,
}

impl Num {
    fn parse(token: &str) -> Result<Num, String> {
        let big: BigInt = token.parse().map_err(|_| format!("\"{token}\" is no integer"))?;
        let small = big.to_i128();
        Ok(Num { big, small })
    }
}

/// The plan of the String constant PLAN, parsed once per Vm (cached by the
/// constant's address) and checked against this program's shapes and
/// enums, so no plan can make the codec index past a table.
fn plan_of(p: *mut Vm, plan: Value) -> Result<Rc<Plan>, Value> {
    if heap_kind(plan) != KIND_STR {
        return Err(vm(p).fail(RtError::Bug("transfer: the plan operand is no String".into())));
    }
    let is_static = unsafe { (*(plan as *const Header)).is_static } != 0;
    if is_static {
        if let Some(cached) = vm(p).transfer_plans.get(&plan) {
            return Ok(cached.clone());
        }
    }
    let info = vm(p).info.clone();
    match parse_plan(str_of(plan).as_str(), &info) {
        Ok(parsed) => {
            let parsed = Rc::new(parsed);
            if is_static {
                vm(p).transfer_plans.insert(plan, parsed.clone());
            }
            Ok(parsed)
        }
        Err(message) => Err(vm(p).fail(RtError::Bug(format!("transfer: a malformed plan: {message}")))),
    }
}

fn parse_plan(text: &str, info: &ProgramInfo) -> Result<Plan, String> {
    let mut lines = text.split('\n');
    let head: Vec<&str> = lines.next().unwrap_or("").split(' ').collect();
    if head.len() != 4 || head[0] != "plan" {
        return Err("no plan header".into());
    }
    let version: u8 = head[1].parse().map_err(|_| "a bad version".to_string())?;
    if head[2].len() != 16 {
        return Err("a bad fingerprint".into());
    }
    let fingerprint = u64::from_str_radix(head[2], 16).map_err(|_| "a bad fingerprint".to_string())?;
    let bytes_shape = shape_number(head[3], info, Some(1))?;
    let lines: Vec<&str> = lines.collect();
    let count = lines.len();
    if count == 0 {
        return Err("no node".into());
    }
    let mut nodes = Vec::with_capacity(count);
    let mut min = Vec::with_capacity(count);
    for line in lines {
        let mut t = Tokens { tokens: line.split(' ').collect(), at: 0 };
        min.push(t.number(u64::MAX)?);
        let node = match t.next()? {
            "unit" => Node::Unit,
            "bool" => Node::Bool,
            "char" => Node::Char,
            "float64" => Node::Float64,
            "decimal" => Node::Decimal,
            "raw32" => Node::Raw32,
            "raw64" => Node::Raw64,
            "str" => Node::Str,
            "int" => {
                let n = t.number(u64::from(u32::MAX))?;
                let mut domains = Vec::new();
                for _ in 0..n {
                    match t.next()? {
                        "i" => {
                            let lo = Num::parse(t.next()?)?;
                            let hi = Num::parse(t.next()?)?;
                            domains.push(Domain::Interval(lo, hi));
                        }
                        "e" => {
                            let m = t.number(u64::from(u32::MAX))?;
                            let mut values = Vec::new();
                            for _ in 0..m {
                                values.push(Num::parse(t.next()?)?);
                            }
                            values.sort_by(|a, b| a.big.cmp(&b.big));
                            domains.push(Domain::Exact(values));
                        }
                        other => return Err(format!("an unknown integer domain \"{other}\"")),
                    }
                }
                Node::Int(domains)
            }
            "list" => {
                let elem = t.node(count)?;
                let length = match t.next()? {
                    "-1" => None,
                    token => Some(token.parse::<u64>().map_err(|_| format!("a bad length \"{token}\""))?),
                };
                Node::List { elem, length }
            }
            "set" => Node::Set(t.node(count)?),
            "vector" => Node::Vector(t.node(count)?),
            "array" => Node::Array(t.node(count)?),
            "struct" => {
                let shape_token = t.next()?;
                let slots = t.number(u64::from(u32::MAX))? as usize;
                let shape = shape_number(shape_token, info, Some(slots))?;
                let n = t.number(u64::from(u32::MAX))? as usize;
                if n != slots {
                    return Err(format!("a struct of {slots} fields with {n} on the wire"));
                }
                let mut wire = Vec::with_capacity(n);
                let mut seen = vec![false; slots];
                for _ in 0..n {
                    let slot = t.number(slots as u64 - 1)? as usize;
                    if std::mem::replace(&mut seen[slot], true) {
                        return Err(format!("slot {slot} twice on the wire"));
                    }
                    wire.push((slot, t.node(count)?));
                }
                Node::Struct { shape, slots, wire }
            }
            "enum" => {
                let number = t.number(u64::from(u32::MAX))? as u32;
                let Some(declared) = info.enums.get(number as usize) else {
                    return Err(format!("no enum {number}"));
                };
                let declared = declared.cases.len();
                let n = t.number(declared as u64)? as usize;
                let mut cases = Vec::with_capacity(n);
                let mut index_of = vec![u32::MAX; declared];
                for i in 0..n {
                    let case = t.number(declared as u64 - 1)? as u32;
                    if index_of[case as usize] != u32::MAX {
                        return Err(format!("case {case} of enum {number} twice"));
                    }
                    index_of[case as usize] = i as u32;
                    cases.push(case);
                }
                Node::Enum { number, cases, index_of }
            }
            "bytes" => Node::Bytes(shape_number(t.next()?, info, Some(1))?),
            "mutbytes" => Node::MutBytes(shape_number(t.next()?, info, Some(1))?),
            "through" => {
                let r = t.node(count)?;
                let k = t.number(u64::from(u32::MAX) - 1)? as usize;
                Node::Through { r, k }
            }
            other => return Err(format!("an unknown node \"{other}\"")),
        };
        if t.at != t.tokens.len() {
            return Err(format!("a node line with more than it says: \"{line}\""));
        }
        nodes.push(node);
    }
    Ok(Plan { version, fingerprint, bytes_shape, nodes, min })
}

/// Shape number TOKEN of PROGRAM, of FIELDS fields when given.
fn shape_number(token: &str, info: &ProgramInfo, fields: Option<usize>) -> Result<u32, String> {
    let n: u32 = token.parse().map_err(|_| format!("a bad shape \"{token}\""))?;
    let Some(shape) = info.shapes.get(n as usize) else {
        return Err(format!("no shape {n}"));
    };
    if let Some(fields) = fields {
        if shape.fields.len() != fields {
            return Err(format!("shape {n} has {} fields, not {fields}", shape.fields.len()));
        }
    }
    Ok(n)
}

struct Tokens<'a> {
    tokens: Vec<&'a str>,
    at: usize,
}

impl<'a> Tokens<'a> {
    fn next(&mut self) -> Result<&'a str, String> {
        let token = self.tokens.get(self.at).copied().ok_or_else(|| "a node line ends early".to_string())?;
        self.at += 1;
        Ok(token)
    }

    /// The next token, a number at most MAX.
    fn number(&mut self, max: u64) -> Result<u64, String> {
        let token = self.next()?;
        match token.parse::<u64>() {
            Ok(n) if n <= max => Ok(n),
            _ => Err(format!("a bad number \"{token}\"")),
        }
    }

    /// The next token, a node index of a plan of COUNT nodes.
    fn node(&mut self, count: usize) -> Result<usize, String> {
        Ok(self.number(count as u64 - 1)? as usize)
    }
}

// ---------------------------------------------------------------------------
// Why a walk stops

enum Stop {
    /// A refusal of the bytes: the declared builtin error.
    Refuse(Refusal),
    /// A call or an allocation failed: its error is pending.
    Failed,
    /// An invariant of the compiler's broken (a value of another kind than
    /// its static type, a function list too short).
    Bug(String),
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
enum Refusal {
    Malformed,
    Version,
    TypeMismatch,
    InvalidValue,
    Limit,
}

impl Refusal {
    fn id_and_name(self) -> (u32, &'static str) {
        match self {
            Refusal::Malformed => (ERR_TRANSFER_MALFORMED, "TransferMalformed"),
            Refusal::Version => (ERR_TRANSFER_VERSION, "TransferVersion"),
            Refusal::TypeMismatch => (ERR_TRANSFER_TYPE_MISMATCH, "TransferTypeMismatch"),
            Refusal::InvalidValue => (ERR_TRANSFER_INVALID_VALUE, "TransferInvalidValue"),
            Refusal::Limit => (ERR_TRANSFER_LIMIT, "TransferLimit"),
        }
    }
}

impl From<Refusal> for Stop {
    fn from(r: Refusal) -> Stop {
        Stop::Refuse(r)
    }
}

/// The operation's result of a walk that stopped.
fn stopped(p: *mut Vm, stop: Stop) -> Value {
    match stop {
        Stop::Refuse(r) => {
            let (id, name) = r.id_and_name();
            fail_builtin(p, id, name)
        }
        Stop::Failed => NO_VALUE,
        Stop::Bug(message) => vm(p).fail(RtError::Bug(format!("transfer: {message}"))),
    }
}

/// Function K of the List FNS (a `through` node's projection or rebuild).
fn function(fns: Value, k: usize) -> Result<Value, Stop> {
    if heap_kind(fns) != KIND_LIST {
        return Err(Stop::Bug("the function operand is no List".into()));
    }
    list_of(fns).items().get(k).copied().ok_or_else(|| Stop::Bug(format!("no function {k}")))
}

/// Runs F on X (a `through` function: one argument, total); X must be
/// rooted by the caller.
fn call(p: *mut Vm, f: Value, x: Value) -> Result<Value, Stop> {
    let r = rt_call_value(p, f, 1, &x);
    if r == NO_VALUE { Err(Stop::Failed) } else { Ok(r) }
}

// ---------------------------------------------------------------------------
// Encoding

/// `transferencode %v %plan %fns`: the std::abi::bytes::Bytes of VALUE's
/// encoding (core::transfer::encode's bytes), or the failure of an owner's
/// projection.
#[unsafe(no_mangle)]
pub extern "C" fn rt_transfer_encode(p: *mut Vm, value: Value, plan: Value, fns: Value) -> Value {
    let plan = match plan_of(p, plan) {
        Ok(plan) => plan,
        Err(failed) => return failed,
    };
    let base = vm(p).temp_roots.len();
    vm(p).temp_roots.push(fns);
    let encoded = encode(p, &plan, value, fns);
    vm(p).temp_roots.truncate(base);
    let out = match encoded {
        Ok(out) => out,
        Err(stop) => return stopped(p, stop),
    };
    // Nothing of the value is needed now: the bytes are Rust memory.
    let storage = vm(p).new_bytes(&out);
    if storage == NO_VALUE {
        return NO_VALUE;
    }
    vm(p).temp_roots.push(storage);
    let r = vm(p).new_struct(plan.bytes_shape, vec![storage]);
    vm(p).temp_roots.truncate(base);
    r
}

/// The bytes of VALUE by PLAN. Every value still to be written is on
/// `temp_roots` (above the caller's mark), its node in NODES, the next one
/// last: a projection may collect.
fn encode(p: *mut Vm, plan: &Plan, value: Value, fns: Value) -> Result<Vec<u8>, Stop> {
    let mut out = Vec::with_capacity(64);
    out.extend_from_slice(MAGIC);
    out.push(plan.version);
    out.extend_from_slice(&plan.fingerprint.to_le_bytes());
    let mut nodes: Vec<usize> = vec![0];
    vm(p).temp_roots.push(value);
    while let Some(n) = nodes.pop() {
        let v = *vm(p).temp_roots.last().expect("a pending value per pending node");
        if let Node::Through { r, k } = plan.nodes[n] {
            // V stays rooted, in its place, while its owner projects it.
            let projected = call(p, function(fns, k)?, v)?;
            *vm(p).temp_roots.last_mut().expect("the projected value's place") = projected;
            nodes.push(r);
            continue;
        }
        vm(p).temp_roots.pop();
        // From here to the next iteration nothing allocates or runs code: V
        // and what it holds are read in place.
        match &plan.nodes[n] {
            Node::Unit => expect(v == UNIT, v, "unit")?,
            Node::Bool => {
                expect(v == TRUE || v == FALSE, v, "Bool")?;
                out.push((v == TRUE) as u8);
            }
            Node::Int(_) => {
                expect(is_small(v) || heap_kind(v) == KIND_BIGINT, v, "Int")?;
                put_int(&mut out, v);
            }
            Node::Char => {
                expect(is_char(v), v, "UnicodeChar")?;
                put_varuint(&mut out, char_of(v) as u64);
            }
            Node::Float64 => {
                expect(heap_kind(v) == KIND_FLOAT, v, "Float64")?;
                out.extend_from_slice(&float_bits(v).to_le_bytes());
            }
            Node::Decimal => {
                expect(heap_kind(v) == KIND_DECIMAL, v, "DecimalRounded")?;
                out.extend_from_slice(&float_bits(v).to_le_bytes());
            }
            Node::Raw32 => {
                expect(heap_kind(v) == KIND_RAWF32, v, "RawFloat")?;
                out.extend_from_slice(&(raw_bits(v) as u32).to_le_bytes());
            }
            Node::Raw64 => {
                expect(heap_kind(v) == KIND_RAWF64, v, "RawDouble")?;
                out.extend_from_slice(&raw_bits(v).to_le_bytes());
            }
            Node::Str => {
                expect(heap_kind(v) == KIND_STR, v, "String")?;
                let text = str_of(v).as_bytes();
                put_varuint(&mut out, text.len() as u64);
                out.extend_from_slice(text);
            }
            Node::List { elem, .. } => {
                expect(heap_kind(v) == KIND_LIST, v, "List")?;
                push_items(p, &mut out, &mut nodes, *elem, list_of(v).items().iter().copied());
            }
            Node::Set(elem) => {
                expect(heap_kind(v) == KIND_SET, v, "ImmutableSet")?;
                push_items(p, &mut out, &mut nodes, *elem, set_of(v).items().iter().copied());
            }
            Node::Vector(elem) => {
                expect(heap_kind(v) == KIND_MUTVEC, v, "MutableVector")?;
                push_items(p, &mut out, &mut nodes, *elem, super::mutvec::mutvec_of(v).backing.iter().copied());
            }
            Node::Array(elem) => {
                expect(heap_kind(v) == KIND_MUTARRAY, v, "MutableArray")?;
                push_items(p, &mut out, &mut nodes, *elem, mutarray_of(v).items().iter().copied());
            }
            Node::Struct { shape, slots, wire } => {
                let fields = struct_fields(v, *shape, *slots)?;
                for &(slot, node) in wire.iter().rev() {
                    nodes.push(node);
                    vm(p).temp_roots.push(fields[slot]);
                }
            }
            Node::Enum { number, index_of, .. } => {
                expect(is_enum(v), v, "enum case")?;
                let (e, case) = enum_parts(v);
                let index = index_of.get(case as usize).copied().unwrap_or(u32::MAX);
                if e != *number || index == u32::MAX {
                    return Err(Stop::Bug(format!("an enum word {v:#x} of no case of enum {number}")));
                }
                put_varuint(&mut out, index as u64);
            }
            Node::Bytes(shape) => {
                let storage = struct_fields(v, *shape, 1)?[0];
                expect(heap_kind(storage) == KIND_BYTES, storage, "byte storage")?;
                let payload = bytes_of(storage);
                put_varuint(&mut out, payload.len() as u64);
                out.extend_from_slice(payload);
            }
            Node::MutBytes(shape) => {
                let storage = struct_fields(v, *shape, 1)?[0];
                expect(heap_kind(storage) == KIND_MUTBYTES, storage, "writable byte storage")?;
                let payload = mutbytes_of(storage);
                put_varuint(&mut out, payload.len() as u64);
                out.extend_from_slice(payload);
            }
            Node::Through { .. } => unreachable!("projected above"),
        }
    }
    Ok(out)
}

/// The count of ITEMS (an exact-size iterator) written, and every item
/// pushed, of node ELEM, the first last (popped first).
fn push_items(
    p: *mut Vm,
    out: &mut Vec<u8>,
    nodes: &mut Vec<usize>,
    elem: usize,
    items: impl DoubleEndedIterator<Item = Value> + ExactSizeIterator,
) {
    put_varuint(out, items.len() as u64);
    let roots = &mut vm(p).temp_roots;
    roots.reserve(items.len());
    nodes.reserve(items.len());
    for item in items.rev() {
        nodes.push(elem);
        roots.push(item);
    }
}

/// Err (a broken invariant) unless OK: V should be WHAT.
fn expect(ok: bool, v: Value, what: &str) -> Result<(), Stop> {
    if ok { Ok(()) } else { Err(Stop::Bug(format!("a value {v:#x} where its type states a {what}"))) }
}

/// The SLOTS fields of V, a struct of SHAPE.
fn struct_fields<'a>(v: Value, shape: u32, slots: usize) -> Result<&'a [Value], Stop> {
    if heap_kind(v) != KIND_STRUCT || struct_of(v).shape != shape || struct_of(v).fields().len() != slots {
        return Err(Stop::Bug(format!("a value {v:#x} where its type states a struct of shape {shape}")));
    }
    Ok(struct_of(v).fields())
}

fn put_varuint(out: &mut Vec<u8>, mut n: u64) {
    while n >= 0x80 {
        out.push((n as u8 & 0x7f) | 0x80);
        n >>= 7;
    }
    out.push(n as u8);
}

/// The Int V: its byte count and minimal two's complement, little-endian
/// (none for 0).
fn put_int(out: &mut Vec<u8>, v: Value) {
    if let Some(n) = int_small(v) {
        if n == 0 {
            out.push(0);
            return;
        }
        // The bits of the magnitude besides the sign (!n is -n - 1).
        let m = if n < 0 { !n } else { n } as u64;
        let count = (64 - m.leading_zeros()) as usize / 8 + 1;
        put_varuint(out, count as u64);
        out.extend_from_slice(&n.to_le_bytes()[..count]);
    } else {
        // (num-bigint's signed bytes are the minimal two's complement.)
        let bytes = big_of(v).to_signed_bytes_le();
        put_varuint(out, bytes.len() as u64);
        out.extend_from_slice(&bytes);
    }
}

// ---------------------------------------------------------------------------
// Decoding

/// `transferdecode %d %plan %fns`: the value the bytes of DATA (a
/// std::abi::bytes::Bytes) hold, or the declared error refusing them, or the
/// failure of an owner's rebuild.
#[unsafe(no_mangle)]
pub extern "C" fn rt_transfer_decode(p: *mut Vm, data: Value, plan: Value, fns: Value) -> Value {
    let plan = match plan_of(p, plan) {
        Ok(plan) => plan,
        Err(failed) => return failed,
    };
    let base = vm(p).temp_roots.len();
    vm(p).temp_roots.push(data);
    vm(p).temp_roots.push(fns);
    let decoded = decode(p, &plan, data, fns);
    vm(p).temp_roots.truncate(base);
    match decoded {
        // (Returned at once: nothing allocates before the caller has it.)
        Ok(v) => v,
        Err(stop) => stopped(p, stop),
    }
}

/// The decoder's instructions, last first (core::transfer::Decode's).
enum Work {
    /// Decode a value of node N.
    Decode(usize),
    /// Decode COUNT values of node N.
    Repeat(usize, u64),
    /// Build the composite of node N from the K values last made.
    Build(usize, usize),
    /// Rebuild the opaque struct of `through` node N from the value last made.
    Rebuild(usize),
}

/// The input bytes and where the decoder is in them.
struct Reader<'a> {
    raw: &'a [u8],
    pos: usize,
    /// The zero-size elements still allowed.
    budget: i64,
}

impl<'a> Reader<'a> {
    fn left(&self) -> usize {
        self.raw.len() - self.pos
    }

    fn byte(&mut self) -> Result<u8, Refusal> {
        let b = *self.raw.get(self.pos).ok_or(Refusal::Malformed)?;
        self.pos += 1;
        Ok(b)
    }

    fn take(&mut self, count: u64) -> Result<&'a [u8], Refusal> {
        if count > self.left() as u64 {
            return Err(Refusal::Malformed);
        }
        let bytes = &self.raw[self.pos..self.pos + count as usize];
        self.pos += count as usize;
        Ok(bytes)
    }

    fn take8(&mut self) -> Result<u64, Refusal> {
        Ok(u64::from_le_bytes(self.take(8)?.try_into().expect("eight bytes")))
    }

    fn varuint(&mut self) -> Result<u64, Refusal> {
        let mut value: u128 = 0;
        for i in 0..10 {
            let b = self.byte()?;
            value |= ((b & 0x7f) as u128) << (7 * i);
            if b & 0x80 == 0 {
                if b == 0 && i > 0 {
                    return Err(Refusal::Malformed);
                }
                if value > MAX_VARUINT as u128 {
                    return Err(Refusal::Limit);
                }
                return Ok(value as u64);
            }
        }
        Err(Refusal::Malformed)
    }

    /// Admits COUNT elements of at least MIN bytes each.
    fn admit(&mut self, count: u64, min: u64) -> Result<(), Refusal> {
        if min > 0 {
            if count > self.left() as u64 / min {
                return Err(Refusal::Malformed);
            }
            return Ok(());
        }
        // COUNT < 2^62 and the budget >= 0 here: no overflow.
        self.budget -= count as i64;
        if self.budget < 0 {
            return Err(Refusal::Limit);
        }
        Ok(())
    }

    /// The next Int, checked minimal and in every one of DOMAINS.
    fn int(&mut self, domains: &[Domain]) -> Result<IntVal, Refusal> {
        let count = self.varuint()?;
        if count > MAX_INT_BYTES {
            return Err(Refusal::Limit);
        }
        let n = if count == 0 {
            IntVal::Small(0)
        } else {
            let bytes = self.take(count)?;
            let count = bytes.len();
            let last = bytes[count - 1];
            if count == 1 && last == 0 {
                return Err(Refusal::InvalidValue);
            }
            if count > 1 {
                let below = bytes[count - 2];
                if (last == 0 && below & 0x80 == 0) || (last == 0xff && below & 0x80 != 0) {
                    return Err(Refusal::InvalidValue);
                }
            }
            if count <= 8 {
                let fill = if last & 0x80 != 0 { 0xff } else { 0 };
                let mut word = [fill; 8];
                word[..count].copy_from_slice(bytes);
                IntVal::Small(i64::from_le_bytes(word))
            } else {
                IntVal::Big(BigInt::from_signed_bytes_le(bytes))
            }
        };
        for domain in domains {
            let inside = match domain {
                Domain::Interval(lo, hi) => compare(&n, lo) != Ordering::Less && compare(&n, hi) != Ordering::Greater,
                Domain::Exact(values) => values.binary_search_by(|b| compare(&n, b).reverse()).is_ok(),
            };
            if !inside {
                return Err(Refusal::InvalidValue);
            }
        }
        Ok(n)
    }
}

/// A decoded Int, before its value exists.
enum IntVal {
    Small(i64),
    Big(BigInt),
}

fn compare(n: &IntVal, bound: &Num) -> Ordering {
    match (n, bound.small) {
        (IntVal::Small(n), Some(b)) => (*n as i128).cmp(&b),
        (IntVal::Small(n), None) => BigInt::from(*n).cmp(&bound.big),
        (IntVal::Big(n), _) => n.cmp(&bound.big),
    }
}

/// Pushes the value V just made (NO_VALUE: an allocation failed) onto the
/// values stack.
fn made(p: *mut Vm, v: Value) -> Result<(), Stop> {
    if v == NO_VALUE {
        return Err(Stop::Failed);
    }
    vm(p).temp_roots.push(v);
    Ok(())
}

/// The value DATA's bytes hold by PLAN. The values made and not yet in their
/// containers are on `temp_roots` (above the caller's mark: DATA and FNS),
/// the last made last.
fn decode(p: *mut Vm, plan: &Plan, data: Value, fns: Value) -> Result<Value, Stop> {
    if heap_kind(data) != KIND_STRUCT || struct_of(data).fields().len() != 1 {
        return Err(Stop::Bug("the data operand is no std::abi::bytes::Bytes".into()));
    }
    let storage = struct_of(data).fields()[0];
    if heap_kind(storage) != KIND_BYTES {
        return Err(Stop::Bug("the data operand holds no byte storage".into()));
    }
    // (Read in place: DATA is rooted for the whole decode, and objects never
    // move.)
    let raw = bytes_of(storage);
    if raw.len() < HEADER || &raw[..4] != MAGIC {
        return Err(Refusal::Malformed.into());
    }
    if raw[4] != VERSION {
        return Err(Refusal::Version.into());
    }
    if u64::from_le_bytes(raw[5..HEADER].try_into().expect("eight bytes")) != plan.fingerprint {
        return Err(Refusal::TypeMismatch.into());
    }
    let mut r = Reader { raw, pos: HEADER, budget: ZERO_BUDGET };
    let mark = vm(p).temp_roots.len();
    let mut work = vec![Work::Decode(0)];
    while let Some(w) = work.pop() {
        let n = match w {
            Work::Decode(n) => n,
            Work::Repeat(n, count) => {
                if count > 1 {
                    work.push(Work::Repeat(n, count - 1));
                }
                work.push(Work::Decode(n));
                continue;
            }
            Work::Build(n, k) => {
                build(p, plan, n, k)?;
                continue;
            }
            Work::Rebuild(n) => {
                let Node::Through { k, .. } = plan.nodes[n] else { unreachable!("a rebuild of a through node") };
                // The representation stays rooted, in its place, while its
                // owner rebuilds the struct from it.
                let x = *vm(p).temp_roots.last().expect("the representation made");
                let rebuilt = call(p, function(fns, k + 1)?, x)?;
                *vm(p).temp_roots.last_mut().expect("the representation's place") = rebuilt;
                continue;
            }
        };
        match &plan.nodes[n] {
            Node::Unit => made(p, UNIT)?,
            Node::Bool => {
                let b = r.byte()?;
                if b > 1 {
                    return Err(Refusal::InvalidValue.into());
                }
                made(p, bool_value(b == 1))?;
            }
            Node::Int(domains) => {
                let v = match r.int(domains)? {
                    IntVal::Small(n) => vm(p).new_int(n),
                    IntVal::Big(n) => vm(p).new_big(n),
                };
                made(p, v)?;
            }
            Node::Char => {
                let c = r.varuint()?;
                if c > MAX_SCALAR as u64 || (SURROGATE_LO as u64..=SURROGATE_HI as u64).contains(&c) {
                    return Err(Refusal::InvalidValue.into());
                }
                made(p, make_char(c as u32))?;
            }
            Node::Float64 | Node::Decimal => {
                let bits = r.take8()?;
                if (bits >> 52) & 0x7ff == 0x7ff {
                    return Err(Refusal::InvalidValue.into());
                }
                let decimal = matches!(plan.nodes[n], Node::Decimal);
                if !decimal && bits == 0x8000_0000_0000_0000 {
                    return Err(Refusal::InvalidValue.into());
                }
                let ty = if decimal { FloatType::DecimalRounded } else { FloatType::Float64 };
                // (Finite: admitted; a DecimalRounded's negative zero is its
                // zero, as core::decimal::value makes it.)
                let admitted = ty.admit(f64::from_bits(bits)).expect("a finite binary64");
                made(p, vm(p).new_float(ty, admitted))?;
            }
            Node::Raw32 => {
                let bits = u32::from_le_bytes(r.take(4)?.try_into().expect("four bytes"));
                made(p, vm(p).new_raw_float(CFloatFormat::Binary32, bits as u64))?;
            }
            Node::Raw64 => {
                let bits = r.take8()?;
                made(p, vm(p).new_raw_float(CFloatFormat::Binary64, bits))?;
            }
            Node::Str => {
                let count = r.varuint()?;
                let utf8 = r.take(count)?;
                let Ok(text) = std::str::from_utf8(utf8) else {
                    return Err(Refusal::InvalidValue.into());
                };
                made(p, vm(p).new_str(text))?;
            }
            Node::Bytes(shape) | Node::MutBytes(shape) => {
                let count = r.varuint()?;
                let payload = r.take(count)?;
                let storage = if matches!(plan.nodes[n], Node::Bytes(_)) {
                    vm(p).new_bytes(payload)
                } else {
                    vm(p).new_mutbytes_with(payload.len(), |init| init.push_slice(payload))
                };
                made(p, storage)?;
                let s = vm(p).new_struct(*shape, vec![storage]);
                if s == NO_VALUE {
                    return Err(Stop::Failed);
                }
                *vm(p).temp_roots.last_mut().expect("the storage's place") = s;
            }
            Node::List { elem, length } => {
                let count = r.varuint()?;
                if length.is_some_and(|length| count != length) {
                    return Err(Refusal::InvalidValue.into());
                }
                collection(&mut r, &mut work, plan, n, *elem, count)?;
            }
            Node::Set(elem) | Node::Vector(elem) | Node::Array(elem) => {
                let count = r.varuint()?;
                collection(&mut r, &mut work, plan, n, *elem, count)?;
            }
            Node::Struct { wire, .. } => {
                work.push(Work::Build(n, wire.len()));
                for &(_, child) in wire.iter().rev() {
                    work.push(Work::Decode(child));
                }
            }
            Node::Enum { number, cases, .. } => {
                let index = r.varuint()?;
                let Some(&case) = cases.get(index as usize).filter(|_| index < cases.len() as u64) else {
                    return Err(Refusal::InvalidValue.into());
                };
                made(p, make_enum(*number, case))?;
            }
            Node::Through { r: rep, .. } => {
                work.push(Work::Rebuild(n));
                work.push(Work::Decode(*rep));
            }
        }
    }
    if r.pos != raw.len() {
        return Err(Refusal::Malformed.into());
    }
    if vm(p).temp_roots.len() != mark + 1 {
        return Err(Stop::Bug("the decoder made more than one value".into()));
    }
    Ok(vm(p).temp_roots.pop().expect("the decoded value"))
}

/// Schedules the COUNT elements of node ELEM of the collection of node N,
/// after admitting them.
fn collection(r: &mut Reader, work: &mut Vec<Work>, plan: &Plan, n: usize, elem: usize, count: u64) -> Result<(), Stop> {
    r.admit(count, plan.min[elem])?;
    // An admitted count is at most the bytes left or the zero-size budget:
    // it fits a usize.
    work.push(Work::Build(n, count as usize));
    if count > 0 {
        work.push(Work::Repeat(elem, count));
    }
    Ok(())
}

/// Replaces the K values last made by the composite of node N they are the
/// parts of, in wire order. The parts stay rooted until the composite holds
/// them.
fn build(p: *mut Vm, plan: &Plan, n: usize, k: usize) -> Result<(), Stop> {
    let roots = &vm(p).temp_roots;
    let parts: Vec<Value> = roots[roots.len() - k..].to_vec();
    let v = match &plan.nodes[n] {
        Node::List { .. } => vm(p).new_list(parts),
        // The receiver's own set: its members deduplicated by this runtime's
        // equality (bytes holding one member twice decode to the set).
        Node::Set(_) => new_set_of(p, &parts),
        Node::Vector(_) => super::mutvec::new_vector_of(p, parts),
        Node::Array(_) => new_array_of(p, Rc::from(parts)),
        Node::Struct { shape, slots, wire } => {
            let mut fields = vec![UNIT; *slots];
            for (&(slot, _), &part) in wire.iter().zip(parts.iter()) {
                fields[slot] = part;
            }
            vm(p).new_struct(*shape, fields)
        }
        _ => return Err(Stop::Bug("a build of a node that is no composite".into())),
    };
    if v == NO_VALUE {
        return Err(Stop::Failed);
    }
    let roots = &mut vm(p).temp_roots;
    roots.truncate(roots.len() - k);
    roots.push(v);
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::nir::OpCode;
    use crate::runtime::error::BUILTIN_ERROR_ID_BASE;
    use crate::runtime::metrics::{AllocMode, GcReason};
    use crate::runtime::vm::{EnumInfo, NativeInfo, ShapeInfo};

    /// A program's tables: SHAPES (name, fields), ENUMS (name, cases) and
    /// NATIVES (name, op), each native of one parameter.
    fn program(shapes: &[(Option<&str>, &[&str])], enums: &[(&str, &[&str])], natives: &[(&str, OpCode)]) -> Rc<ProgramInfo> {
        Rc::new(ProgramInfo {
            functions: Vec::new(),
            natives: natives
                .iter()
                .map(|(name, op)| NativeInfo { name: name.to_string(), arity: Some(1), params: vec![None], op: *op })
                .collect(),
            shapes: shapes
                .iter()
                .map(|(name, fields)| ShapeInfo {
                    name: name.map(String::from),
                    fields: fields.iter().map(|f| f.to_string()).collect(),
                    opaque: false,
                    identity: None,
                    tree: None,
                })
                .collect(),
            enums: enums
                .iter()
                .map(|(name, cases)| EnumInfo { name: name.to_string(), cases: cases.iter().map(|c| c.to_string()).collect() })
                .collect(),
            errors: Vec::new(),
        })
    }

    /// A Vm of INFO whose every allocation collects first and whose freed
    /// objects are poisoned: a value the codec failed to root is caught.
    fn stressed(info: Rc<ProgramInfo>) -> Box<Vm> {
        let mut vm = Vm::new(info, AllocMode::Summary);
        vm.heap.set_stress_for_test(true);
        vm.heap.set_poison_for_test(true);
        vm
    }

    /// V, kept rooted for the rest of the test.
    fn root(vm: &mut Vm, v: Value) -> Value {
        assert_ne!(v, NO_VALUE, "an allocation failed: {:?}", vm.error.as_ref().map(|e| e.message()));
        vm.temp_roots.push(v);
        v
    }

    fn list(vm: &mut Vm, items: Vec<Value>) -> Value {
        let v = vm.new_list(items);
        root(vm, v)
    }

    fn string(vm: &mut Vm, text: &str) -> Value {
        let v = vm.new_str(text);
        root(vm, v)
    }

    /// A Bytes struct of SHAPE holding BYTES.
    fn bytes_value(vm: &mut Vm, shape: u32, bytes: &[u8]) -> Value {
        let storage = vm.new_bytes(bytes);
        root(vm, storage);
        let v = vm.new_struct(shape, vec![storage]);
        root(vm, v)
    }

    /// The payload of the Bytes struct V.
    fn payload(v: Value) -> Vec<u8> {
        bytes_of(struct_of(v).fields()[0]).to_vec()
    }

    fn native_value(vm: &mut Vm, index: u32) -> Value {
        let v = vm.alloc(crate::runtime::value::NativeObj { hdr: Header::new(KIND_NATIVE, false), native: index }, 0);
        root(vm, v)
    }

    /// Encodes V by PLAN (a String made here) with FNS: the bytes, or the
    /// declared error id the operation failed with (0: another failure).
    fn encode_bytes(vm: &mut Vm, plan: &str, v: Value, fns: Value) -> Result<Vec<u8>, u32> {
        let plan = string(vm, plan);
        let p: *mut Vm = vm;
        let r = rt_transfer_encode(p, v, plan, fns);
        if r == NO_VALUE {
            let id = vm.declared_error;
            vm.error = None;
            vm.declared_error = 0;
            return Err(id);
        }
        root(vm, r);
        Ok(payload(r))
    }

    /// Decodes BYTES by PLAN with FNS: the value (rooted), or the declared
    /// error id it was refused with (0: another failure, which fails the
    /// test unless ALLOW_OTHER).
    fn decode_bytes(vm: &mut Vm, bytes_shape: u32, plan: &str, bytes: &[u8], fns: Value) -> Result<Value, u32> {
        let data = bytes_value(vm, bytes_shape, bytes);
        let plan = string(vm, plan);
        let p: *mut Vm = vm;
        let before = vm.temp_roots.len();
        let r = rt_transfer_decode(p, data, plan, fns);
        assert_eq!(vm.temp_roots.len(), before, "decode leaves the roots as it found them");
        if r == NO_VALUE {
            let id = vm.declared_error;
            if id == 0 {
                panic!("a decode failed with no declared error: {:?}", vm.error.as_ref().map(|e| e.message()));
            }
            vm.error = None;
            vm.declared_error = 0;
            return Err(id);
        }
        Ok(root(vm, r))
    }

    const MALFORMED: u32 = BUILTIN_ERROR_ID_BASE + 14;
    const VERSION_ID: u32 = BUILTIN_ERROR_ID_BASE + 15;
    const MISMATCH: u32 = BUILTIN_ERROR_ID_BASE + 16;
    const INVALID: u32 = BUILTIN_ERROR_ID_BASE + 17;
    const LIMIT: u32 = BUILTIN_ERROR_ID_BASE + 18;

    const FP: &str = "0123456789abcdef";

    fn header() -> Vec<u8> {
        let mut h = b"BOTX\x01".to_vec();
        h.extend_from_slice(&0x0123456789abcdefu64.to_le_bytes());
        h
    }

    fn with_header(body: &[u8]) -> Vec<u8> {
        let mut b = header();
        b.extend_from_slice(body);
        b
    }

    /// The fields of the rich value's anonymous struct of every scalar and
    /// collection form.
    const MIX: &[&str] = &["f00", "f01", "f02", "f03", "f04", "f05", "f06", "f07", "f08", "f09", "f10", "f11", "f12", "f13", "f14"];

    // The rich value's schema, numbered by each program's tables: an
    // anonymous struct {a: List[Point], b: {f00 ... f14}} of every node form.
    fn rich_plan(bytes: u32, anon: u32, point: u32, mbytes: u32, color: u32, mix: u32) -> String {
        [
            format!("plan 1 {FP} {bytes}"),
            format!("39 struct {anon} 2 2 0 1 1 3"),
            "1 list 2 -1".to_string(),
            // Point {y, x, label} on the wire as label, x, y.
            format!("3 struct {point} 3 3 2 4 1 5 0 6"),
            format!("38 struct {mix} 15 15 0 6 1 4 2 7 3 8 4 9 5 10 6 11 7 12 8 13 9 14 10 15 11 16 12 17 13 18 14 19"),
            "1 str".to_string(),
            "1 int 1 i 0 1000".to_string(),
            "1 int 0".to_string(),
            "8 float64".to_string(),
            "1 bool".to_string(),
            // Color {Red, Green, Blue}: sorted Blue, Green, Red.
            format!("1 enum {color} 3 2 1 0"),
            "1 char".to_string(),
            "1 set 4".to_string(),
            "1 vector 6".to_string(),
            "1 array 20".to_string(),
            format!("1 mutbytes {mbytes}"),
            "4 raw32".to_string(),
            "8 raw64".to_string(),
            "8 decimal".to_string(),
            "0 unit".to_string(),
            "1 list 6 2".to_string(),
            format!("1 bytes {bytes}"),
        ]
        .join("\n")
    }

    const BIG: &str = "-370370367037037036703703703670";

    /// The rich value in VM (shapes and enum numbers as given).
    fn rich_value(vm: &mut Vm, bytes: u32, anon: u32, point: u32, mbytes: u32, color: u32, mix: u32) -> Value {
        let mut points = Vec::new();
        for (i, label) in ["héllo😀", "", "x"].iter().enumerate() {
            let label = string(vm, label);
            let y = vm.new_big(BIG.parse::<BigInt>().unwrap() * BigInt::from(i as i64 + 1));
            root(vm, y);
            let p = vm.new_struct(point, vec![y, make_small(3 * i as i64), label]);
            points.push(root(vm, p));
        }
        let a = list(vm, points);
        let s = string(vm, "set");
        let s2 = string(vm, "members");
        let set = crate::runtime::ops::new_set_of(vm, &[s, s2, s]);
        root(vm, set);
        let vector = super::super::mutvec::new_vector_of(vm, vec![make_small(-1), make_small(0), make_small(1 << 40)]);
        root(vm, vector);
        let e1 = bytes_value(vm, bytes, b"one");
        let e2 = bytes_value(vm, bytes, b"");
        let array = new_array_of(vm, Rc::from(vec![e1, e2]));
        root(vm, array);
        let mb = vm.new_mutbytes_with(3, |init| init.push_slice(&[0, 255, 7]));
        root(vm, mb);
        let mbs = vm.new_struct(mbytes, vec![mb]);
        root(vm, mbs);
        let f = vm.new_float(FloatType::Float64, (-2.5f64).to_bits());
        root(vm, f);
        let r32 = vm.new_raw_float(CFloatFormat::Binary32, 0x7fc0_0001);
        root(vm, r32);
        let r64 = vm.new_raw_float(CFloatFormat::Binary64, 0x8000_0000_0000_0000);
        root(vm, r64);
        let d = vm.new_float(FloatType::DecimalRounded, 0.1f64.to_bits());
        root(vm, d);
        let pair = list(vm, vec![make_small(7), make_small(8)]);
        let name = string(vm, "mix");
        let b = vm.new_struct(
            mix,
            vec![
                make_small(42),
                name,
                f,
                TRUE,
                make_enum(color, 2),
                make_char(0x1F600),
                set,
                vector,
                array,
                mbs,
                r32,
                r64,
                d,
                UNIT,
                pair,
            ],
        );
        root(vm, b);
        let v = vm.new_struct(anon, vec![a, b]);
        root(vm, v)
    }

    /// Checks V is the rich value in VM's numbering.
    fn check_rich(vm: &Vm, v: Value, bytes: u32, anon: u32, point: u32, mbytes: u32, color: u32, mix: u32) {
        let _ = vm;
        assert_eq!(struct_of(v).shape, anon);
        let [a, b] = struct_of(v).fields() else { panic!("two fields") };
        let points = list_of(*a).items();
        assert_eq!(points.len(), 3);
        for (i, (&p, label)) in points.iter().zip(["héllo😀", "", "x"]).enumerate() {
            assert_eq!(struct_of(p).shape, point);
            let f = struct_of(p).fields();
            assert_eq!(*big_of(f[0]), BIG.parse::<BigInt>().unwrap() * BigInt::from(i as i64 + 1));
            assert_eq!(f[1], make_small(3 * i as i64));
            assert_eq!(str_of(f[2]).as_str(), label);
        }
        assert_eq!(struct_of(*b).shape, mix);
        let t = struct_of(*b).fields();
        assert_eq!(t.len(), 15);
        assert_eq!(t[0], make_small(42));
        assert_eq!(str_of(t[1]).as_str(), "mix");
        assert_eq!(float_bits(t[2]), (-2.5f64).to_bits());
        assert_eq!(t[3], TRUE);
        assert_eq!(t[4], make_enum(color, 2));
        assert_eq!(t[5], make_char(0x1F600));
        let members: Vec<&str> = set_of(t[6]).items().iter().map(|&m| str_of(m).as_str()).collect();
        assert_eq!(members, ["set", "members"]);
        let elements: Vec<Value> = super::super::mutvec::elements(t[7]).collect();
        assert_eq!(elements, [make_small(-1), make_small(0), make_small(1 << 40)]);
        let slots = mutarray_of(t[8]).items();
        assert_eq!(slots.len(), 2);
        assert_eq!(struct_of(slots[0]).shape, bytes);
        assert_eq!(payload(slots[0]), b"one");
        assert_eq!(payload(slots[1]), b"");
        assert_eq!(struct_of(t[9]).shape, mbytes);
        assert_eq!(heap_kind(struct_of(t[9]).fields()[0]), KIND_MUTBYTES);
        assert_eq!(mutbytes_of(struct_of(t[9]).fields()[0]), [0, 255, 7]);
        assert_eq!(heap_kind(t[10]), KIND_RAWF32);
        assert_eq!(raw_bits(t[10]), 0x7fc0_0001);
        assert_eq!(raw_bits(t[11]), 0x8000_0000_0000_0000);
        assert_eq!(heap_kind(t[12]), KIND_DECIMAL);
        assert_eq!(float_bits(t[12]), 0.1f64.to_bits());
        assert_eq!(t[13], UNIT);
        assert_eq!(list_of(t[14]).items(), [make_small(7), make_small(8)]);
    }

    #[test]
    fn transfer_rich_value_between_independent_vms() {
        // The sender's program: Bytes 0, anonymous {a b} 2, Point 1,
        // MutableBytes 3; Color is enum 0.
        let sender = program(
            &[(Some("std::abi::bytes::Bytes"), &["storage"]), (Some("Point"), &["y", "x", "label"]), (None, &["a", "b"]), (Some("std::abi::bytes::MutableBytes"), &["storage"]), (None, MIX)],
            &[("Color", &["Red", "Green", "Blue"])],
            &[],
        );
        let encoded = {
            let mut vm = stressed(sender);
            let v = rich_value(&mut vm, 0, 2, 1, 3, 0, 4);
            let fns = list(&mut vm, vec![]);
            let encoded = encode_bytes(&mut vm, &rich_plan(0, 2, 1, 3, 0, 4), v, fns).expect("encodes");
            // Encoding is deterministic and leaves the value as it was.
            assert_eq!(encode_bytes(&mut vm, &rich_plan(0, 2, 1, 3, 0, 4), v, fns), Ok(encoded.clone()));
            check_rich(&vm, v, 0, 2, 1, 3, 0, 4);
            encoded
            // (The sender's Vm, every object it made, is dropped here.)
        };
        assert_eq!(&encoded[..5], b"BOTX\x01");
        // The receiver: another program numbering the same declarations
        // otherwise.
        let receiver = program(
            &[(None, &["a", "b"]), (Some("Other"), &["z"]), (None, MIX), (Some("std::abi::bytes::MutableBytes"), &["storage"]), (Some("Point"), &["y", "x", "label"]), (Some("std::abi::bytes::Bytes"), &["storage"])],
            &[("Other", &["X"]), ("Color", &["Red", "Green", "Blue"])],
            &[],
        );
        let mut vm = stressed(receiver);
        let plan = rich_plan(5, 0, 4, 3, 1, 2);
        let fns = list(&mut vm, vec![]);
        let one = decode_bytes(&mut vm, 5, &plan, &encoded, fns).expect("decodes");
        let two = decode_bytes(&mut vm, 5, &plan, &encoded, fns).expect("decodes");
        vm.collect_for_test(GcReason::Explicit);
        check_rich(&vm, one, 5, 0, 4, 3, 1, 2);
        check_rich(&vm, two, 5, 0, 4, 3, 1, 2);
        // The decoded mutable values are values of their own.
        let p: *mut Vm = &mut *vm;
        let v1 = struct_of(struct_of(one).fields()[1]).fields()[7];
        let v2 = struct_of(struct_of(two).fields()[1]).fields()[7];
        let x = string(&mut vm, "pushed");
        assert_eq!(super::super::mutvec::rt_mv_push(p, v1, x), UNIT);
        assert_eq!(super::super::mutvec::elements(v1).count(), 4);
        assert_eq!(super::super::mutvec::elements(v2).count(), 3);
        let a1 = struct_of(struct_of(one).fields()[1]).fields()[8];
        let replacement = bytes_value(&mut vm, 5, b"new");
        assert_eq!(crate::runtime::ops::rt_mutarray_set(p, a1, make_small(1), replacement), UNIT);
        let a2 = struct_of(struct_of(two).fields()[1]).fields()[8];
        assert_eq!(payload(mutarray_of(a2).items()[1]), b"");
        vm.collect_for_test(GcReason::Explicit);
        // Re-encoding the received value in the receiver's numbering gives
        // the sender's bytes.
        assert_eq!(encode_bytes(&mut vm, &plan, two, fns), Ok(encoded));
    }

    #[test]
    fn transfer_ints_are_minimal_twos_complement() {
        let info = program(&[(Some("std::abi::bytes::Bytes"), &["storage"])], &[], &[]);
        let mut vm = stressed(info);
        let plan = format!("plan 1 {FP} 0\n1 list 1 -1\n1 int 0");
        let fns = list(&mut vm, vec![]);
        // (core::transfer::Int's bytes.)
        let cases: &[(&str, &[u8])] = &[
            ("0", &[0]),
            ("1", &[1, 1]),
            ("-1", &[1, 0xff]),
            ("127", &[1, 0x7f]),
            ("128", &[2, 0x80, 0]),
            ("-128", &[1, 0x80]),
            ("-129", &[2, 0x7f, 0xff]),
            ("300", &[2, 0x2c, 1]),
            ("4611686018427387903", &[8, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x3f]),
            ("4611686018427387904", &[8, 0, 0, 0, 0, 0, 0, 0, 0x40]),
            ("-4611686018427387905", &[8, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xbf]),
            ("9223372036854775808", &[9, 0, 0, 0, 0, 0, 0, 0, 0x80, 0]),
            ("-9223372036854775808", &[8, 0, 0, 0, 0, 0, 0, 0, 0x80]),
            ("-9223372036854775809", &[9, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x7f, 0xff]),
            ("18446744073709551616", &[9, 0, 0, 0, 0, 0, 0, 0, 0, 1]),
        ];
        for (text, want) in cases {
            let n: BigInt = text.parse().unwrap();
            let v = vm.new_big(n.clone());
            root(&mut vm, v);
            let xs = list(&mut vm, vec![v]);
            let bytes = encode_bytes(&mut vm, &plan, xs, fns).unwrap();
            let mut expected = header();
            expected[5..13].copy_from_slice(&0x0123456789abcdefu64.to_le_bytes());
            expected.push(1);
            expected.extend_from_slice(want);
            assert_eq!(bytes, expected, "{text}");
            let back = decode_bytes(&mut vm, 0, &plan, &bytes, fns).unwrap();
            assert_eq!(int_to_big(list_of(back).items()[0]), n, "{text}");
        }
    }

    #[test]
    fn transfer_through_owner_functions() {
        // A `through` node whose projection is mutable_vector#to_list and
        // whose rebuild is std::mutable_vector::from_list.
        let natives: &[(&str, OpCode)] = &[("to", OpCode::MvToList), ("from", OpCode::MvFromList)];
        let info = program(&[(Some("std::abi::bytes::Bytes"), &["storage"])], &[], natives);
        let plan = format!("plan 1 {FP} 0\n1 list 1 -1\n1 through 2 0\n1 list 3 -1\n1 str");
        let encoded = {
            let mut vm = stressed(info.clone());
            let mut vectors = Vec::new();
            for n in 0..3 {
                let mut items = Vec::new();
                for i in 0..n {
                    items.push(string(&mut vm, &format!("s{i}")));
                }
                let v = super::super::mutvec::new_vector_of(&mut *vm, items);
                vectors.push(root(&mut vm, v));
            }
            let xs = list(&mut vm, vectors);
            let to = native_value(&mut vm, 0);
            let from = native_value(&mut vm, 1);
            let fns = list(&mut vm, vec![to, from]);
            encode_bytes(&mut vm, &plan, xs, fns).unwrap()
        };
        assert_eq!(encoded, with_header(&[3, 0, 1, 2, b's', b'0', 2, 2, b's', b'0', 2, b's', b'1']));
        let mut vm = stressed(info);
        let to = native_value(&mut vm, 0);
        let from = native_value(&mut vm, 1);
        let fns = list(&mut vm, vec![to, from]);
        let back = decode_bytes(&mut vm, 0, &plan, &encoded, fns).unwrap();
        vm.collect_for_test(GcReason::Explicit);
        let vectors = list_of(back).items();
        assert_eq!(vectors.len(), 3);
        for (n, &v) in vectors.iter().enumerate() {
            assert_eq!(heap_kind(v), KIND_MUTVEC);
            let texts: Vec<String> = super::super::mutvec::elements(v).map(|s| str_of(s).as_str().to_string()).collect();
            assert_eq!(texts, (0..n).map(|i| format!("s{i}")).collect::<Vec<_>>());
        }
    }

    #[test]
    fn transfer_owner_failure_is_the_operations_failure() {
        // An owner function that fails (a native called with the wrong
        // number of arguments: ARITY) fails the encode with its error.
        let info = Rc::new(ProgramInfo {
            functions: Vec::new(),
            natives: vec![NativeInfo { name: "bad".into(), arity: Some(2), params: vec![None, None], op: OpCode::ListGet }],
            shapes: vec![ShapeInfo { name: Some("std::abi::bytes::Bytes".into()), fields: vec!["storage".into()], opaque: false, identity: None, tree: None }],
            enums: Vec::new(),
            errors: Vec::new(),
        });
        let mut vm = stressed(info);
        let plan = format!("plan 1 {FP} 0\n1 through 1 0\n1 int 0");
        let bad = native_value(&mut vm, 0);
        let fns = list(&mut vm, vec![bad, bad]);
        let before = vm.temp_roots.len();
        let p: *mut Vm = &mut *vm;
        let plan_value = string(&mut vm, &plan);
        let before = before + 1;
        assert_eq!(rt_transfer_encode(p, make_small(1), plan_value, fns), NO_VALUE);
        assert_eq!(vm.temp_roots.len(), before);
        assert_eq!(vm.declared_error, 0);
        assert!(vm.error.as_ref().is_some_and(|e| e.message().contains("expects 2 argument")), "{:?}", vm.error.as_ref().map(|e| e.message()));
        vm.error = None;
        // And a rebuild that fails fails the decode the same way.
        let r = {
            let data = bytes_value(&mut vm, 0, &with_header(&[1, 1]));
            rt_transfer_decode(p, data, plan_value, fns)
        };
        assert_eq!(r, NO_VALUE);
        assert_eq!(vm.declared_error, 0);
        assert!(vm.error.is_some());
        vm.error = None;
    }

    #[test]
    fn transfer_refuses_malformed_bytes() {
        let info = program(&[(Some("std::abi::bytes::Bytes"), &["storage"]), (None, &["a", "b", "c", "d"])], &[("Color", &["Red", "Green", "Blue"])], &[]);
        let mut vm = stressed(info);
        let fns = list(&mut vm, vec![]);
        let ints = format!("plan 1 {FP} 0\n1 list 1 -1\n1 int 0");
        let valid = with_header(&[3, 1, 1, 2, 0x7f, 0xff, 2, 0x2c, 1]);
        assert!(decode_bytes(&mut vm, 0, &ints, &valid, fns).is_ok());
        // Every proper prefix is cut short.
        for n in 0..valid.len() {
            assert_eq!(decode_bytes(&mut vm, 0, &ints, &valid[..n], fns).err(), Some(MALFORMED), "prefix {n}");
        }
        let check = |vm: &mut Vm, plan: &str, body: &[u8], want: Option<u32>| {
            let got = decode_bytes(vm, 0, plan, &with_header(body), fns).err();
            assert_eq!(got, want, "{plan:?} {body:?}");
        };
        // Trailing bytes.
        check(&mut vm, &ints, &[0, 0], Some(MALFORMED));
        // The header.
        let mut wrong = valid.clone();
        wrong[0] = b'C';
        assert_eq!(decode_bytes(&mut vm, 0, &ints, &wrong, fns).err(), Some(MALFORMED));
        let mut wrong = valid.clone();
        wrong[4] = 2;
        assert_eq!(decode_bytes(&mut vm, 0, &ints, &wrong, fns).err(), Some(VERSION_ID));
        let mut wrong = valid.clone();
        wrong[12] ^= 1;
        assert_eq!(decode_bytes(&mut vm, 0, &ints, &wrong, fns).err(), Some(MISMATCH));
        // Counts: more elements than bytes left; varuints not minimal, too
        // long, too large.
        check(&mut vm, &ints, &[5, 1, 1], Some(MALFORMED));
        check(&mut vm, &ints, &[0x80, 0], Some(MALFORMED));
        check(&mut vm, &ints, &[0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0], Some(MALFORMED));
        check(&mut vm, &ints, &[0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x7f], Some(LIMIT));
        check(&mut vm, &ints, &[0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x3f], Some(MALFORMED));
        // Ints: not minimal, too long.
        check(&mut vm, &ints, &[1, 1, 0], Some(INVALID));
        check(&mut vm, &ints, &[1, 2, 1, 0], Some(INVALID));
        check(&mut vm, &ints, &[1, 2, 0xff, 0xff], Some(INVALID));
        check(&mut vm, &ints, &[1, 2, 0x80, 0], None);
        check(&mut vm, &ints, &[1, 0x81, 0x80, 0x40], Some(LIMIT));
        // Integer domains: an interval with bignum bounds and an exact set.
        let domains = format!("plan 1 {FP} 0\n1 list 1 -1\n1 int 2 i -1180591620717411303424 1180591620717411303424 e 3 240 0 16");
        check(&mut vm, &domains, &[2, 1, 16, 1, 0xf0], Some(INVALID));
        check(&mut vm, &domains, &[2, 1, 16, 2, 0xf0, 0], None);
        check(&mut vm, &domains, &[1, 1, 17], Some(INVALID));
        let wide = format!("plan 1 {FP} 0\n1 list 1 -1\n1 int 1 i -1180591620717411303424 1180591620717411303424");
        // 2^69 is inside, 2^71 and -2^71 outside.
        check(&mut vm, &wide, &[1, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0x20], None);
        check(&mut vm, &wide, &[1, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0x80], Some(INVALID));
        check(&mut vm, &wide, &[1, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0x80, 0], Some(INVALID));
        // Scalars.
        let scalars = format!("plan 1 {FP} 0\n11 struct 1 4 4 0 1 1 2 2 3 3 4\n1 bool\n1 char\n8 float64\n1 enum 0 3 2 1 0");
        let good = |c: &[u8], f: f64, e: u8| {
            let mut body = vec![1];
            body.extend_from_slice(c);
            body.extend_from_slice(&f.to_bits().to_le_bytes());
            body.push(e);
            body
        };
        check(&mut vm, &scalars, &good(&[0x41], 1.5, 2), None);
        let mut b = good(&[0x41], 1.5, 2);
        b[0] = 2;
        check(&mut vm, &scalars, &b, Some(INVALID));
        check(&mut vm, &scalars, &good(&[0x80, 0xb0, 0x03], 1.5, 2), Some(INVALID));
        check(&mut vm, &scalars, &good(&[0x80, 0x80, 0x44], 1.5, 2), Some(INVALID));
        check(&mut vm, &scalars, &good(&[0xff, 0xff, 0x43], 1.5, 2), None);
        check(&mut vm, &scalars, &good(&[0x41], f64::NAN, 2), Some(INVALID));
        check(&mut vm, &scalars, &good(&[0x41], f64::INFINITY, 2), Some(INVALID));
        check(&mut vm, &scalars, &good(&[0x41], -0.0, 2), Some(INVALID));
        check(&mut vm, &scalars, &good(&[0x41], 1.5, 3), Some(INVALID));
        let mut short = good(&[0x41], 1.5, 2);
        short.pop();
        check(&mut vm, &scalars, &short, Some(MALFORMED));
        // A DecimalRounded's negative zero is its zero; a NaN is no value.
        let decimal = format!("plan 1 {FP} 0\n8 decimal");
        let zero = decode_bytes(&mut vm, 0, &decimal, &with_header(&(-0.0f64).to_bits().to_le_bytes()), fns).unwrap();
        assert_eq!(float_bits(zero), 0);
        check(&mut vm, &decimal, &f64::NAN.to_bits().to_le_bytes(), Some(INVALID));
        // Strings: strict UTF-8.
        let strs = format!("plan 1 {FP} 0\n1 str");
        check(&mut vm, &strs, &[2, 0xc3, 0x28], Some(INVALID));
        check(&mut vm, &strs, &[3, 0xed, 0xa0, 0x80], Some(INVALID));
        check(&mut vm, &strs, &[2, 0xc0, 0x80], Some(INVALID));
        check(&mut vm, &strs, &[2, 0xc3, 0xa9], None);
        check(&mut vm, &strs, &[3, 0xc3, 0xa9], Some(MALFORMED));
        // A List's stated length.
        let pair = format!("plan 1 {FP} 0\n1 list 1 2\n1 int 0");
        check(&mut vm, &pair, &[2, 0, 0], None);
        check(&mut vm, &pair, &[3, 0, 0, 0], Some(INVALID));
        // Zero-size elements draw on the budget.
        let units = format!("plan 1 {FP} 0\n1 list 1 -1\n0 unit");
        check(&mut vm, &units, &[0x80, 0x80, 0x80, 0x08], None);
        check(&mut vm, &units, &[0x81, 0x80, 0x80, 0x08], Some(LIMIT));
        let nested = format!("plan 1 {FP} 0\n1 list 1 -1\n1 list 2 -1\n0 unit");
        check(&mut vm, &nested, &[2, 0x80, 0x80, 0x80, 0x04, 0x80, 0x80, 0x80, 0x04], None);
        check(&mut vm, &nested, &[2, 0x80, 0x80, 0x80, 0x04, 0x81, 0x80, 0x80, 0x04], Some(LIMIT));
    }

    /// No byte string decodes to anything but a value or a declared refusal:
    /// mutations of a valid encoding, decoded (the sender's numbering).
    #[test]
    fn transfer_decoding_mutated_bytes_never_breaks() {
        let info = program(
            &[(Some("std::abi::bytes::Bytes"), &["storage"]), (Some("Point"), &["y", "x", "label"]), (None, &["a", "b"]), (Some("std::abi::bytes::MutableBytes"), &["storage"]), (None, MIX)],
            &[("Color", &["Red", "Green", "Blue"])],
            &[],
        );
        let mut vm = Vm::new(info, AllocMode::Summary);
        let plan = rich_plan(0, 2, 1, 3, 0, 4);
        let v = rich_value(&mut vm, 0, 2, 1, 3, 0, 4);
        let fns = list(&mut vm, vec![]);
        let valid = encode_bytes(&mut vm, &plan, v, fns).unwrap();
        let mark = vm.temp_roots.len();
        let mut seed: u64 = 0x9e37_79b9_7f4a_7c15;
        let mut next = || {
            seed ^= seed << 13;
            seed ^= seed >> 7;
            seed ^= seed << 17;
            seed
        };
        let mut outcomes = [0usize; 6];
        for round in 0..20_000 {
            let mut bytes = valid.clone();
            let edits = 1 + next() % 3;
            for _ in 0..edits {
                let at = 13 + (next() as usize) % (bytes.len() - 13);
                match next() % 4 {
                    0 => bytes[at] = next() as u8,
                    1 => bytes[at] ^= 1 << (next() % 8),
                    2 => bytes.truncate(at),
                    _ => bytes.insert(at, next() as u8),
                }
                if bytes.len() <= 13 {
                    break;
                }
            }
            match decode_bytes(&mut vm, 0, &plan, &bytes, fns) {
                Ok(_) => outcomes[0] += 1,
                Err(id) => {
                    assert!((MALFORMED..=LIMIT).contains(&id), "round {round}: error {id:#x}");
                    outcomes[(id - MALFORMED + 1) as usize] += 1;
                }
            }
            vm.temp_roots.truncate(mark);
        }
        assert!(outcomes[0] > 0 && outcomes[1] > 0 && outcomes[4] > 0, "{outcomes:?}");
    }

    /// A value's depth is bounded by memory, not by the host's stack.
    #[test]
    fn transfer_deep_trees_iteratively() {
        let info = program(&[(Some("std::abi::bytes::Bytes"), &["storage"]), (Some("Node"), &["kids"])], &[], &[]);
        let plan = format!("plan 1 {FP} 0\n1 struct 1 1 1 0 1\n1 list 0 -1");
        let depth = 100_000;
        let encoded = {
            let mut vm = Vm::new(info.clone(), AllocMode::Summary);
            let mut node = {
                let kids = list(&mut vm, vec![]);
                let n = vm.new_struct(1, vec![kids]);
                root(&mut vm, n)
            };
            for _ in 1..depth {
                let kids = list(&mut vm, vec![node]);
                let n = vm.new_struct(1, vec![kids]);
                node = root(&mut vm, n);
                // (Only the newest node needs rooting: it holds the rest.)
                let len = vm.temp_roots.len();
                vm.temp_roots.swap(len - 3, len - 1);
                vm.temp_roots.truncate(len - 2);
            }
            let fns = list(&mut vm, vec![]);
            encode_bytes(&mut vm, &plan, node, fns).unwrap()
        };
        assert_eq!(encoded.len(), 13 + depth);
        let mut vm = Vm::new(info, AllocMode::Summary);
        let fns = list(&mut vm, vec![]);
        let mut node = decode_bytes(&mut vm, 0, &plan, &encoded, fns).unwrap();
        vm.collect_for_test(GcReason::Explicit);
        let mut seen = 1;
        loop {
            let kids = list_of(struct_of(node).fields()[0]).items();
            if kids.is_empty() {
                break;
            }
            node = kids[0];
            seen += 1;
        }
        assert_eq!(seen, depth);
    }

    /// A static plan constant is parsed once per Vm; a malformed one is a
    /// compiler bug, never a panic.
    #[test]
    fn transfer_plans_are_cached_and_checked() {
        let info = program(&[(Some("std::abi::bytes::Bytes"), &["storage"])], &[], &[]);
        let mut vm = Vm::new(info, AllocMode::Summary);
        let p: *mut Vm = &mut *vm;
        let text = format!("plan 1 {FP} 0\n1 int 0");
        let constant = crate::runtime::strobj::StrObj::new_static(&text) as Value;
        let fns = list(&mut vm, vec![]);
        let r = rt_transfer_encode(p, make_small(5), constant, fns);
        assert_ne!(r, NO_VALUE);
        assert_eq!(vm.transfer_plans.len(), 1);
        let r = rt_transfer_encode(p, make_small(6), constant, fns);
        assert_ne!(r, NO_VALUE);
        assert_eq!(vm.transfer_plans.len(), 1);
        for bad in [
            "",
            "plan 1 0123 0\n1 int 0",
            &format!("plan 1 {FP} 7\n1 int 0"),
            &format!("plan 1 {FP} 0\n1 list 5 -1"),
            &format!("plan 1 {FP} 0\n1 struct 0 2 2 0 0 1 0"),
            &format!("plan 1 {FP} 0\n1 enum 0 1 0"),
            &format!("plan 1 {FP} 0\n1 int 0 extra"),
            &format!("plan 1 {FP} 0\n1 frob"),
        ] {
            let plan = string(&mut vm, bad);
            assert_eq!(rt_transfer_encode(p, make_small(5), plan, fns), NO_VALUE, "{bad:?}");
            assert!(matches!(vm.error, Some(RtError::Bug(_))), "{bad:?}");
            vm.error = None;
        }
        // A value of another kind than its plan states is a bug too.
        let plan = string(&mut vm, &format!("plan 1 {FP} 0\n1 str"));
        assert_eq!(rt_transfer_encode(p, make_small(5), plan, fns), NO_VALUE);
        assert!(matches!(vm.error, Some(RtError::Bug(_))));
        vm.error = None;
        unsafe { crate::runtime::heap::free_object(constant as *mut Header) };
    }
}
