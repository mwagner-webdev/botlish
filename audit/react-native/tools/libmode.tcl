# libmode.tcl -- a STAND-IN for a compiler facility Botlish did not have
# (REACT-NATIVE-TARGET-CENSUS.md, "Library mode"): a static library whose
# named C functions call Botlish functions. Nothing in the compiler is
# changed; this tool shows what such a mode has to produce and what it could
# reuse at the time.
#
# HISTORY. The compiler has its own library mode since
# NATIVE-LIBRARY-MILESTONE-1.md (`exported c fn`, `main.tcl
# -emit-native-library`), and this tool no longer runs against it: the
# startup crate it reads is gone (an executable starts from the program
# descriptor) and the botlish_entry_N symbols it calls are local to the
# program object. It runs at the census's revision (cc7e6e3b), where the
# mobile workflow still runs it (audit/react-native/README.md). Its first
# bullet below is the defect the milestone fixed: an export is the instance
# its top level's arguments made, specialized for their constants.
#
#   tclsh9.0 audit/react-native/tools/libmode.tcl -o DIR -prefix P \
#       ?-rust-target TRIPLE? ?-runtime DIR? FILE.bot NAME...
#
# writes DIR/libP_botlish.a, DIR/P_botlish.h and DIR/P_botlish.exports
# (one line per export: NAME C-SYMBOL {PARAM TYPE...} RESULT {ERRORS}).
#
# How (every step is a census finding, not a design):
#
#   * NAME is a top-level function of FILE whose parameters and result are
#     declared int, str or bool (or a unit result). Its declared signature
#     comes from the HIR (hir::signatures::of).
#   * Native lowering compiles only what the program reaches, so FILE's top
#     level must call every NAME with its declared types; the instance whose
#     `instance=` list is exactly those types is the one exported (NIR text).
#     Tiny exact-leaf inlining is turned off so that a one-line function
#     keeps a body of its own (BOTLISH_NATIVE_TINY_LEAF_INLINE_OPT=0).
#   * The executable link's generated startup crate (codegen/aot.rs
#     `startup`) is the only place the program's ProgramInfo, constant pool
#     and stack maps exist. A pass-through RUSTC captures it and program.o;
#     `new_vm` below is its closure body.
#   * Each export calls the function's generic entry botlish_entry_N(vm,
#     closure, args*): tagged Values in, a tagged Value (0 = an error is
#     pending) out, whatever raw or short ABI the direct function has.
#   * One Vm per thread, created on first use (the runtime's PROGRAM is
#     thread-local and a Vm is not Send). Botlish code runs on the caller's
#     thread and stack, with no overflow guard.
#   * The runtime library is libbotlish_native.rlib of -runtime (default
#     this checkout's native/target/release), built for -rust-target (the
#     host's by default). program.o is always the host's: the native
#     backend emits machine code for its own host only.

set root [file normalize [file join [file dirname [info script]] .. .. ..]]

proc usage {} {
    puts stderr "usage: tclsh9.0 libmode.tcl -o DIR -prefix P ?-rust-target TRIPLE? ?-runtime DIR? FILE.bot NAME..."
    exit 2
}

set out ""
set prefix ""
set rustTarget ""
set runtime [file join $root native target release]
while {[string match -* [lindex $argv 0]]} {
    set argv [lassign $argv option value]
    switch -- $option {
        -o { set out [file normalize $value] }
        -prefix { set prefix $value }
        -rust-target { set rustTarget $value }
        -runtime { set runtime [file normalize $value] }
        default { usage }
    }
}
set names [lassign $argv file]
if {$out eq "" || $file eq "" || ![llength $names] || ![regexp {^[a-z][a-z0-9_]*$} $prefix]} {
    usage
}

set ::env(BOTLISH_NATIVE_TINY_LEAF_INLINE_OPT) 0
source [file join $root native native.tcl]
core::useProgramRecursionLimit

set hir [surface::readProgramFile $file -warnings off -warning-channel ""]
hir::activate $hir

# The exported functions' declared signatures, from the entry program's own
# top-level bindings.
set signatures [dict create]
foreach e [dict get $hir roots] {
    set node [dict get $hir exprs $e]
    if {[dict get $node kind] ne "bind"} {
        continue
    }
    set binding [dict get $hir bindings [dict get $node binding]]
    if {[dict get $binding scope] ne [dict get $hir top]} {
        continue
    }
    set value [dict get $hir exprs [dict get $node value]]
    if {[dict get $value kind] ne "block"} {
        continue
    }
    dict set signatures [dict get $binding name] \
        [list [hir::signatures::of $hir [dict get $node value]] [dict get $value declaredResult]]
}

set exports {}
foreach name $names {
    if {![dict exists $signatures $name]} {
        error "$file: no top-level function \"$name\""
    }
    lassign [dict get $signatures $name] sig declaredResult
    set params {}
    foreach p [dict get $sig params] {
        set t [dict get $p declared]
        if {$t ni {int str bool}} {
            error "$name: parameter [dict get $p name] must be declared int, str or bool (it is \"$t\")"
        }
        lappend params [dict get $p name] $t
    }
    if {$declaredResult ni {int str bool unit}} {
        error "$name: the result must be declared int, str, bool or unit (it is \"$declaredResult\")"
    }
    lappend exports [list $name $params $declaredResult [dict get $sig errors]]
}

# Each export's NIR function: the instance with exactly its declared types.
set nir [native::nir $hir]
set ids [dict create]
foreach line [split $nir \n] {
    if {[regexp {^func (\d+) "([^"]*)" .*instance="([^"]*)"} $line -> id fname instance]} {
        dict lappend ids [list $fname $instance] $id
    }
}
foreach export $exports {
    lassign $export name params
    set instance [join [dict values $params] ", "]
    set key [list $name $instance]
    if {![dict exists $ids $key]} {
        error "$name: the program never calls it with its declared types ($instance), so native lowering compiled no such instance"
    }
    dict set entry $name [lindex [dict get $ids $key] 0]
}

# The startup crate and program object of an ordinary executable link.
set work [file tempdir]
set wrapper [file join $work rustc-capture.sh]
set f [open $wrapper w]
puts $f "#!/bin/sh\nfor a in \"\$@\"; do\n  case \"\$a\" in\n    *startup.rs) cp \"\$a\" [list [file join $work startup.rs]] ;;\n    link-arg=*program.o) cp \"\${a#link-arg=}\" [list [file join $work program.o]] ;;\n  esac\ndone\nexec rustc \"\$@\""
close $f
file attributes $wrapper -permissions 0755
set ::env(RUSTC) $wrapper
set ::env(BOTLISH_NATIVE_LINKER) rustc
native::executable $hir [file join $work program]
unset ::env(RUSTC)

set f [open [file join $work startup.rs]]
set startup [read $f]
close $f
set start [string first "fn main() \{" $startup]
set body [string first "let info = ProgramInfo" $startup]
set end [string first "(vm, entry as aot::ProgramEntry)" $startup]
if {$start < 0 || $body < 0 || $end < 0} {
    error "unexpected startup.rs shape"
}

proc rustParams {params} {
    set out {}
    dict for {p t} $params {
        switch -- $t {
            int { lappend out "$p: i64" }
            bool { lappend out "$p: bool" }
            str { lappend out "${p}_ptr: *const u8" "${p}_len: usize" }
        }
    }
    return $out
}

proc cParams {params} {
    set out {}
    dict for {p t} $params {
        switch -- $t {
            int { lappend out "int64_t $p" }
            bool { lappend out "bool $p" }
            str { lappend out "const uint8_t *${p}_ptr" "size_t ${p}_len" }
        }
    }
    return $out
}

set rust [string range $startup 0 [expr {$start - 1}]]
append rust "fn new_vm() -> Box<Vm> \{\n" [string range $startup $body [expr {$end - 1}]] "vm\n\}\n"
append rust [string map [list @PREFIX@ $prefix] {
// ---- generated by audit/react-native/tools/libmode.tcl -------------------
use std::cell::RefCell;
use botlish_native::runtime::{ops, strobj::StrObj, value::{self as v, NO_VALUE}};

type Generic = unsafe extern "C" fn(*mut Vm, Value, *const Value) -> Value;

thread_local! {
    static VM: RefCell<Option<Box<Vm>>> = const { RefCell::new(None) };
    static LAST_ERROR: RefCell<(Vec<u8>, Vec<u8>)> = const { RefCell::new((Vec::new(), Vec::new())) };
}

#[repr(C)]
pub struct BotlishStr { pub ptr: *const u8, pub len: usize }

const OK: i32 = 0;
const ERROR: i32 = 1;
const INT_RANGE: i32 = 2;
const BAD_UTF8: i32 = 3;

fn with_vm(f: impl FnOnce(&mut Vm) -> i32) -> i32 {
    VM.with(|cell| {
        let mut slot = cell.borrow_mut();
        let vm = slot.get_or_insert_with(new_vm);
        f(vm)
    })
}

// A failed call: the error's identity (a declared error's canonical name, or
// the runtime error's code) and its message, kept for @PREFIX@_last_error.
fn fail(vm: &mut Vm) -> i32 {
    let (identity, message) = match vm.error.take() {
        Some(e) => {
            let message = vm.describe_error(&e);
            let declared = message.split("<error ").nth(1).and_then(|s| s.split(['>', ' ']).next()).map(str::to_string);
            let identity = if vm.declared_error != 0 { declared.unwrap_or_default() } else { e.error_code().join(" ") };
            (identity, message)
        }
        None => ("NATIVE BUG".to_string(), "native code failed without recording an error".to_string()),
    };
    ops::rt_clear_declared_error(vm);
    LAST_ERROR.with(|l| *l.borrow_mut() = (identity.into_bytes(), message.into_bytes()));
    ERROR
}

fn call(vm: &mut Vm, entry: Generic, args: &[Value]) -> Value {
    unsafe { entry(vm, 0, args.as_ptr()) }
}

fn str_arg(vm: &mut Vm, ptr: *const u8, len: usize) -> Option<Value> {
    let bytes = if len == 0 { &[][..] } else { unsafe { std::slice::from_raw_parts(ptr, len) } };
    let text = std::str::from_utf8(bytes).ok()?;
    let s = vm.new_str(text);
    vm.temp_roots.push(s);
    Some(s)
}

fn int_arg(vm: &mut Vm, n: i64) -> Value {
    let i = vm.new_int(n);
    vm.temp_roots.push(i);
    i
}

fn int_result(r: Value, out: *mut i64) -> i32 {
    let n = match v::int_small(r) {
        Some(n) => n,
        None => match i64::try_from(v::int_to_big(r)) { Ok(n) => n, Err(_) => return INT_RANGE },
    };
    unsafe { *out = n };
    OK
}

/// The identity and message of this thread's last failed call, borrowed
/// until its next one.
#[unsafe(no_mangle)]
pub extern "C" fn @PREFIX@_last_error(identity: *mut BotlishStr, message: *mut BotlishStr) {
    LAST_ERROR.with(|l| {
        let l = l.borrow();
        unsafe {
            *identity = BotlishStr { ptr: l.0.as_ptr(), len: l.0.len() };
            *message = BotlishStr { ptr: l.1.as_ptr(), len: l.1.len() };
        }
    })
}
}]

set header "/* ${prefix}_botlish.h -- generated by audit/react-native/tools/libmode.tcl from [file tail $file]\n"
append header "   (REACT-NATIVE-TARGET-CENSUS.md). Every function returns a status: 0 success;\n"
append header "   1 a Botlish error (${prefix}_last_error has its identity and message);\n"
append header "   2 an Int result outside int64; 3 a String argument that is not UTF-8.\n"
append header "   A String result borrows the Botlish heap until this thread's next call. */\n"
append header "#pragma once\n#include <stdbool.h>\n#include <stddef.h>\n#include <stdint.h>\n"
append header "#ifdef __cplusplus\nextern \"C\" \{\n#endif\n"
append header "#ifndef BOTLISH_STR_DEFINED\n#define BOTLISH_STR_DEFINED\ntypedef struct \{ const uint8_t *ptr; size_t len; \} BotlishStr;\n#endif\n"
append header "enum \{ ${prefix}_OK = 0, ${prefix}_ERROR = 1, ${prefix}_INT_RANGE = 2, ${prefix}_BAD_UTF8 = 3 \};\n"
append header "void ${prefix}_last_error(BotlishStr *identity, BotlishStr *message);\n"

set manifest ""
foreach export $exports {
    lassign $export name params result errors
    set id [dict get $entry $name]
    set symbol ${prefix}_$name
    set rparams [rustParams $params]
    set cparams [cParams $params]
    switch -- $result {
        int { lappend rparams "out: *mut i64"; lappend cparams "int64_t *out" }
        bool { lappend rparams "out: *mut bool"; lappend cparams "bool *out" }
        str { lappend rparams "out: *mut BotlishStr"; lappend cparams "BotlishStr *out" }
    }
    append rust "\nunsafe extern \"C\" \{ #\[link_name = \"botlish_entry_$id\"\] fn entry_${name}(vm: *mut Vm, closure: Value, args: *const Value) -> Value; \}\n"
    append rust "#\[unsafe(no_mangle)\]\npub extern \"C\" fn $symbol\([join $rparams {, }]\) -> i32 \{\n"
    append rust "    with_vm(|vm| \{\n        let roots = vm.temp_roots.len();\n        let mut args: Vec<Value> = Vec::new();\n"
    dict for {p t} $params {
        switch -- $t {
            int { append rust "        args.push(int_arg(vm, $p));\n" }
            bool { append rust "        args.push(if $p \{ v::TRUE \} else \{ v::FALSE \});\n" }
            str {
                append rust "        match str_arg(vm, ${p}_ptr, ${p}_len) \{ Some(s) => args.push(s), None => \{ vm.temp_roots.truncate(roots); return BAD_UTF8 \} \}\n"
            }
        }
    }
    append rust "        let r = call(vm, entry_$name, &args);\n        vm.temp_roots.truncate(roots);\n"
    append rust "        if r == NO_VALUE \{ return fail(vm); \}\n"
    switch -- $result {
        int { append rust "        int_result(r, out)\n" }
        bool { append rust "        unsafe \{ *out = r == v::TRUE \};\n        OK\n" }
        str {
            append rust "        let obj = unsafe \{ StrObj::from_addr(r) \};\n"
            append rust "        unsafe \{ *out = BotlishStr \{ ptr: obj.text_ptr(), len: obj.len_bytes() \} \};\n        OK\n"
        }
        unit { append rust "        OK\n" }
    }
    append rust "    \})\n\}\n"
    append header "int32_t $symbol\([join $cparams {, }]\);\n"
    append manifest [list $name $symbol $params $result $errors] \n
}
append header "#ifdef __cplusplus\n\}\n#endif\n"

file mkdir $out
set library [file join $out lib${prefix}_botlish.a]
set f [open [file join $work library.rs] w]
puts -nonewline $f $rust
close $f
set command [list rustc --edition=2024 --crate-name=${prefix}_botlish --crate-type=staticlib \
    -C opt-level=2 -C force-frame-pointers=yes -C relocation-model=pic -C debuginfo=0 \
    --cap-lints allow \
    --extern botlish_native=[file join $runtime libbotlish_native.rlib] \
    -L dependency=[file join $runtime deps]]
if {$rustTarget ne ""} {
    lappend command --target $rustTarget
}
lappend command [file join $work library.rs] -o $library
exec {*}$command 2>@stderr
exec ar rs $library [file join $work program.o] 2>@stderr
foreach {name text} [list ${prefix}_botlish.h $header ${prefix}_botlish.exports $manifest ${prefix}_library.rs $rust] {
    set f [open [file join $out $name] w]
    puts -nonewline $f $text
    close $f
}
file delete -force $work
puts "library: $library ([llength $exports] exports)"
