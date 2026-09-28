#!/usr/bin/env python3
"""Build a fresh audit crate. Never writes native/ or historical audits.

The profile hooks are the existing post-R2a patch. Optional census hooks
emit counters before NIR calls in an explicit, separate instrumentation mode.
No HIR, specialization, NIR or production source is modified.
"""
import pathlib, shutil, subprocess, sys

root = pathlib.Path.cwd()
work = pathlib.Path(sys.argv[1]).resolve()
assert not work.exists() or '--rebuild' in sys.argv, f"Use a fresh scratch directory: {work}"
crate = work / 'native-audit'
crate.mkdir(parents=True, exist_ok=True)
for name in ['Cargo.toml', 'Cargo.lock', 'src']:
    src = root / 'native' / name
    if src.is_dir(): shutil.copytree(src, crate/name, dirs_exist_ok=True)
    else: shutil.copy2(src, crate/name)
patch = root/'audit/post-r2a-dynamic-census/tools/audit-native.patch'
subprocess.run(['patch', '-p1', '-d', str(crate), '-i', str(patch)], check=True)

def edit(path, old, new):
    p = crate/path
    text = p.read_text()
    assert text.count(old) == 1, (path, old[:80], text.count(old))
    p.write_text(text.replace(old, new))

edit('src/codegen/clif.rs', '    fn inst(&mut self, inst: &Inst) -> Result<(), BackendError> {', '''
    fn inst(&mut self, inst: &Inst) -> Result<(), BackendError> {
        // Audit-only: no allocation in the Botlish heap; no safepoint.
        // Completely absent from generated code unless explicitly enabled.
        if std::env::var_os("BOTLISH_CENSUS").is_some() {
            let info = match inst {
                Inst::Call { func, .. } => Some((1, *func, None)),
                Inst::CallEnv { func, closure, .. } => Some((2, *func, Some(*closure))),
                Inst::CallValue { callee, .. } => Some((3, 0, Some(*callee))),
                Inst::CallMulti { func, .. } => Some((4, *func, None)),
                Inst::CallEnvMulti { func, closure, .. } => Some((5, *func, Some(*closure))),
                Inst::Tail { .. } | Inst::TailEnv { .. } => Some((6, self.f.id, None)),
                _ => None,
            };
            if let Some((kind, target, value)) = info {
                let site = ((self.f.id as u64) << 32) | self.f.origins.get(self.current_index).copied().flatten().unwrap_or(0) as u64;
                let site = self.iconst(site);
                let kind = self.iconst(kind);
                let target = self.iconst(target as u64);
                let value = value.map(|r| self.get(r)).unwrap_or_else(|| self.iconst(0));
                let r = self.helper_ref(self.symbols.helpers["rt_census"]);
                self.b.ins().call(r, &[self.vm, site, kind, target, value]);
            }
        }
''')
edit('src/runtime/ops.rs', '        h!(rt_call_value, 4),', '        h!(rt_call_value, 4),\n        h!(rt_census, 5),')
p = crate/'src/runtime/ops.rs'
p.write_text(p.read_text() + r'''

// Audit-only counters. Identity sets store raw addresses but do not dereference
// them later, retain objects, or allocate anything in the Botlish heap.
type CensusKey = (u64, u64, String, usize);
type CensusValue = (u64, std::collections::BTreeSet<u64>);
static CENSUS: std::sync::Mutex<std::collections::BTreeMap<CensusKey, CensusValue>> =
    std::sync::Mutex::new(std::collections::BTreeMap::new());

#[unsafe(no_mangle)]
pub extern "C" fn rt_census(p: *mut Vm, site: u64, kind: u64, target: u64, value: Value) -> Value {
    let (name, caps) = if kind == 3 {
        match heap_kind(value) {
            KIND_CLOSURE => { let c = closure_of(value); (format!("Block {}", c.func), c.ncaps) },
            KIND_NATIVE => {
                let index = unsafe { as_ref::<NativeObj>(value) }.native as usize;
                (format!("Native {}", vm(p).info.natives[index].name), 0)
            },
            _ => ("Unknown".to_owned(), 0),
        }
    } else { (format!("Block {target}"), 0) };
    let mut map = CENSUS.lock().unwrap();
    let entry = map.entry((site, kind, name, caps)).or_default();
    entry.0 += 1;
    if kind == 3 { entry.1.insert(value); }
    UNIT
}

pub fn census_dump() {
    if let Ok(path) = std::env::var("BOTLISH_CENSUS_OUT") {
        use std::fmt::Write;
        let mut out = String::from("fid\texpr\tkind\ttarget\tcaptures\tcalls\tobjects\n");
        for ((site, kind, name, caps), (count, objects)) in CENSUS.lock().unwrap().iter() {
            writeln!(out, "{}\te{}\t{}\t{}\t{}\t{}\t{}", site >> 32, site & 0xffffffff, kind, name, caps, count, objects.len()).unwrap();
        }
        std::fs::write(path, out).unwrap();
    }
}
''')
edit('src/main.rs', '    if alloc_mode.enabled() {', '    runtime::ops::census_dump();\n    if alloc_mode.enabled() {')
subprocess.run(['cargo','build','--release','--offline','--manifest-path',str(crate/'Cargo.toml'),
                '--target-dir', str(work/'target')], check=True)
print(work/'target/release/botlish-native')
