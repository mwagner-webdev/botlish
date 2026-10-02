//! Program-lifetime constants, shared by JIT and AOT startup.
use super::heap::object_size;
use super::value::*;
use super::vm::Vm;
use crate::nir::FuncId;

/// A constant generated code loads from the VM's constant table.
#[derive(Clone, Debug, PartialEq, Eq, Hash)]
pub enum Const {
    Str(String),
    BigInt(String),
    Native(u32),
    /// The closure of an environment-free function.
    FnValue(FuncId),
}

pub fn install(vm: &mut Vm, entries: &[Const], generic_entries: &[usize], static_count: u32) {
    let mut table = Vec::with_capacity(entries.len());
    let mut statics = Vec::new();
    for c in entries {
        let raw: *mut Header = match c {
            Const::Str(text) => StrObj::new_static(text),
            Const::BigInt(digits) => Box::into_raw(Box::new(BigIntObj {
                hdr: Header::new(KIND_BIGINT, true),
                n: digits.parse().expect("validated big Int literal"),
            })) as *mut Header,
            Const::Native(index) => Box::into_raw(Box::new(NativeObj {
                hdr: Header::new(KIND_NATIVE, true),
                native: *index,
            })) as *mut Header,
            Const::FnValue(func) => {
                let caps: Box<[Value]> = Box::new([]);
                Box::into_raw(Box::new(ClosureObj {
                    hdr: Header::new(KIND_CLOSURE, true),
                    func: *func,
                    arity: vm.info.functions[*func as usize].arity as u32,
                    code: generic_entries[*func as usize],
                    ncaps: 0,
                    caps: Box::into_raw(caps) as *mut Value,
                })) as *mut Header
            }
        };
        if vm.metrics.enabled() {
            let bytes = unsafe { object_size(raw) } as u64;
            vm.record_static_alloc(unsafe { (*raw).kind }, bytes);
        }
        table.push(raw as Value);
        statics.push(raw);
    }
    vm.set_constants(table, statics);
    vm.install_statics(static_count as usize);
}
