# native-status.tcl -- what the native backend does on this host, against
# what it is recorded to do (MACOS-AARCH64-PORT-AUDIT.md, "Native status").
#
#   tclsh9.0 tests/platform/native-status.tcl ?-verbose 0|1?
#
# Runs one small probe per native capability -- the JIT, the GC's frame walk
# under stress, a native stack overflow (of the thread's stack and of a
# coroutine's), coroutines, a Linux syscall, a C call, byte storage exposed
# to the system C library, Darwin I/O (libSystem's read and write, errno,
# the portable std::io::IO through DarwinIO, an executable), Windows I/O
# (kernel32's WriteFile, the portable std::io::IO through WindowsIO, an
# executable), a program object and a standalone executable -- and of the
# target boundary (the driver's reading of the host target's triple, the C
# calling convention of a foreign signature and of a variadic call's, a
# program built for the other operating system of the host's architecture)
# and compares each outcome with the expectation
# recorded below for the host target (core::cabi::hostTarget).
# On Linux every capability is supported. On macOS arm64 and Windows x86-64
# some are not yet, and the expectation is the explicit refusal they fail
# with today: a
# capability that starts working (or fails differently) after a port
# milestone fails this check until its expectation is updated here, in the
# same change. A probe that kills the driver is recorded as such, never
# hidden. Prints a table of probe, expected and observed; exits 1 on any
# difference or on a host with no recorded expectations. Needs the native
# backend built (cargo build --release --manifest-path native/Cargo.toml).

set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname $here]]
source [file join $root native native.tcl]
source [file join $root tests binary-header.tcl]

set verbose 0
foreach {option value} $argv {
    switch -- $option {
        -verbose { set verbose $value }
        default {
            puts stderr "usage: tclsh9.0 tests/platform/native-status.tcl ?-verbose 0|1?"
            exit 2
        }
    }
}

# The probes: NAME {KIND ARGUMENT ENVIRONMENT}. KIND driver runs
# botlish-native on a NIR fixture of native/tests/fixtures; program runs a
# Botlish program with native::evalHir; object writes its program object
# (native::object) and reports the object's header {FORMAT ARCHITECTURE
# KIND} (tests/binary-header.tcl); executable links it with
# native::executable, runs the executable and reports its header and the
# value it prints; target asks the driver how it
# reads the host target's triple (botlish-native target TRIPLE: its object
# format, C calling convention and whether code for it runs here);
# convention compiles the program to CLIF (native::clif: no C call runs) and
# reports the calling convention of each foreign C signature; other-target
# runs the program built for the other operating system's target of this
# host's architecture (macos-aarch64 on linux-aarch64, linux-aarch64 on
# macos-aarch64, linux-x86_64 on windows-x86_64); other-environment the
# program built for the other environment of this host's operating system
# and architecture (windows-x86_64-gnu, MinGW's, on windows-x86_64).
set fixtures [file join $root native tests fixtures]
set probes [dict create \
    jit [list program {fn fib(n):
    if n <= 1:
        return n

    fib(n - 1) + fib(n - 2)

fib(20)
} {}] \
    gc-frame-walk [list driver build400.nir {BOTLISH_NATIVE_GC_STRESS 1}] \
    stack-overflow [list driver stack_overflow.ir {BOTLISH_NATIVE_STACK_BYTES 4194304}] \
    stack-depth-limit [list driver stack_overflow.ir {}] \
    runtime-stack-overflow [list program {import std::mutable_array

# A List nested a million deep, built by a loop, compared with another:
# the runtime's equality (Rust) recurses once per level and exhausts the
# 16 MiB thread stack inside the runtime, not in Botlish code.
fn empty() -> List[any]:
    []

fn nest(n: int) -> List[any]:
    cell = std::mutable_array::create(1, empty())
    loop i from 0 to n:
        cell.set(0, [cell.at(0)])
    cell.at(0)

nest(1000000) == nest(1000000)
} {BOTLISH_NATIVE_STACK_BYTES 16777216}] \
    large-frame-overflow [list driver large_frame_overflow.nir {BOTLISH_NATIVE_STACK_BYTES 4194304}] \
    recursion-limit [list program {fn down(n: int) -> int:
    if n == 0:
        return 0

    1 + down(n - 1)

down(100000000)
} {}] \
    coroutine-stack-overflow [list program {struct Event:
    value: int

fn down(n: int) -> int:
    if n == 0:
        return 0

    1 + down(n - 1)

fn worker(depth: int) -> Event:
    yield Event {value: 0}
    return Event {value: down(depth)}

coroutine {step, first} = worker(100000000)
step().value
} {}] \
    coroutine [list program {struct Message:
    value: int

struct Event:
    value: int

fn worker(base: int, resume Message) -> Event:
    message = yield Event {value: base}
    return Event {value: message.value}

coroutine {step, first} = worker(10)
second = step(Message {value: 7})
[first.value, second.value]
} {}] \
    linux-syscall [list program {direct module
import std::abi
import std::abi::bytes
import std::linux

# A zero-byte write(2) to standard output through std::linux::sys, the host
# architecture's transport: 0 bytes written.
std::linux::write(std::abi::i32(1), std::abi::bytes::from_list([]))
} {}] \
    c-call [list program {import std::ffi::c

extern c fn labs(x: std::ffi::c::Long) -> std::ffi::c::Long

labs(-5)
} {}] \
    c-byte-borrow [list program {import std::abi
import std::abi::bytes
import std::byte
import std::ffi::c

extern c fn memcmp(a: std::ffi::c::Ptr[std::ffi::c::Void] read noescape, b: std::ffi::c::Ptr[std::ffi::c::Void] read noescape, n: std::ffi::c::ULongLong) -> std::ffi::c::Int
extern c fn memset(dst: std::ffi::c::Ptr[std::ffi::c::Void] write noescape, c: std::ffi::c::Int, n: std::ffi::c::ULongLong) -> std::ffi::c::Ptr[std::ffi::c::Void] alias dst

# Bytes and MutableBytes exposed to the system C library's memcmp (read
# noescape) and memset (write noescape: a private copy, the write-back
# value): [1, 200] sorts before the [200, 200] memset wrote, and the
# zeroed owner stays zeroed. size_t is declared unsigned long long, its
# width on every target (LP64's unsigned long, LLP64's unsigned long long).
a = std::abi::bytes::from_list([std::byte::from_int(1), std::byte::from_int(200)])
z = std::abi::bytes::zeroed(std::abi::usize(2))
c = std::abi::bytes::freeze(memset(z, 200, 2).dst)
[memcmp(a, c, 2) < 0, memcmp(c, a, 2) > 0, memcmp(a, a, 2), c == std::abi::bytes::from_list([std::byte::from_int(200), std::byte::from_int(200)]), memcmp(z, std::abi::bytes::from_list([std::byte::from_int(0), std::byte::from_int(0)]), 2)]
} {}] \
    darwin-read-write [list program {direct module
import std::abi
import std::abi::bytes
import std::darwin

# libSystem's write(2) of nothing to descriptor 1 (0 bytes, no errno) and
# read(2) of descriptor -1 (-1, EBADF = 9), through stdlib/darwin.bot.
w = std::darwin::write(1, std::abi::bytes::from_list([]))
r = std::darwin::read(-1, std::abi::bytes::zeroed(std::abi::usize(1)))
[w.count, w.errno, r.count, r.errno]
} {}] \
    darwin-errno [list program {direct module
import std::abi
import std::abi::bytes
import std::darwin

# Two failures in succession, each with its own errno read through __error():
# close of descriptor -1 (EBADF = 9), then of 9999 (EBADF again), and a
# success between them reporting 0.
a = std::darwin::close(-1)
b = std::darwin::write(2, std::abi::bytes::from_list([]))
c = std::darwin::close(9999)
[a.status, a.errno, b.count, b.errno, c.status, c.errno]
} {}] \
    darwin-io [list program {import std::io
import std::darwin::io

# The portable std::io::IO through the installed DarwinIO context: an empty print
# (no write at all) and the value saying it succeeded.
fn quiet() -> str errors std::io::WriteFailed:
    std::io::print("")
    "ok"

with context std::darwin::io::create()

quiet():
    on std::io::WriteFailed:
        "failed"
} {}] \
    darwin-executable [list executable {import std::io
import std::darwin::io

fn hello() errors std::io::WriteFailed:
    std::io::print_line("Hello, world!")

with context std::darwin::io::create()

hello():
    on std::io::WriteFailed:
        unit
} {}] \
    windows-write [list program {import std::abi
import std::abi::bytes
import std::windows

# kernel32's WriteFile of nothing to the process's standard output, through
# stdlib/windows.bot: TRUE, 0 bytes written, no last-error code.
r = std::windows::standard_handle(std::windows::StandardDevice::Output).write_file(std::abi::bytes::from_list([]))
[r.ok, r.count, r.last_error]
} {}] \
    windows-io [list program {import std::io
import std::windows::io

# The portable std::io::IO through the installed WindowsIO context: an empty
# print (no WriteFile at all) and the value saying it succeeded.
fn quiet() -> str errors std::io::WriteFailed:
    std::io::print("")
    "ok"

with context std::windows::io::create()

quiet():
    on std::io::WriteFailed:
        "failed"
} {}] \
    windows-executable [list executable {import std::io
import std::windows::io

fn hello() errors std::io::WriteFailed:
    std::io::print_line("Hello, world!")

with context std::windows::io::create()

hello():
    on std::io::WriteFailed:
        unit
} {}] \
    c-variadic [list convention {import std::ffi::c

extern c fn printf(format: std::ffi::c::Ptr[std::ffi::c::Char] noescape, variadic) -> std::ffi::c::Int

fn c_int(x: std::ffi::c::Int) -> std::ffi::c::Int:
    x

# A variadic C call's machine signature (VARIADICS-VERTICAL-SLICE-1.md): its
# convention where variadic calls are lowered, the codegen refusal where they
# are not (Windows x86-64). Compiled to CLIF only: nothing runs.
format = std::ffi::c::null[std::ffi::c::Char]()
printf(format, c_int(1))
} {}] \
    object [list object {fn fib(n):
    if n <= 1:
        return n

    fib(n - 1) + fib(n - 2)

fib(20)
} {}] \
    executable [list executable {fn fib(n):
    if n <= 1:
        return n

    fib(n - 1) + fib(n - 2)

fib(20)
} {}] \
    target [list target {} {}] \
    c-convention [list convention {import std::ffi::c

extern c fn labs(x: std::ffi::c::Long) -> std::ffi::c::Long
extern c fn abs(x: std::ffi::c::SChar) -> std::ffi::c::Int

labs(-5) + abs(-3)
} {}] \
    other-target [list other-target {import std::ffi::c

fn f(x: std::ffi::c::Char) -> int:
    x

f(1)
} {}] \
    other-environment [list other-environment {import std::ffi::c

fn f(x: std::ffi::c::Long) -> int:
    x

f(1)
} {}]]

# The recorded outcomes: HOST-TARGET -> NAME -> {value TEXT} (exactly) or
# {error CODE MESSAGE-GLOB}. A program object is the host's object format
# and architecture everywhere, and so is a standalone executable, which
# prints its value: on macos-aarch64 a Mach-O executable since milestone 5
# (MACOS-AARCH64-MILESTONE-5.md), where until then emission was refused
# (`executable emission requires Linux glibc on x86_64 or aarch64 (NATIVE
# AOT)`). A C call (libc's labs, through the platform linker) is linked and
# runs, returning 5, on every host: on macos-aarch64 since milestone 6
# (MACOS-AARCH64-MILESTONE-6.md), where until then it was refused before the
# linker ran (NATIVE LINK, "C calls are linked on Linux glibc only"). Byte
# storage exposed to the system C library (memcmp reading two buffers,
# memset writing a private copy) gives the same values everywhere: on
# macos-aarch64 checked since milestone 7 (MACOS-AARCH64-MILESTONE-7.md).
# Darwin I/O (stdlib/darwin.bot, stdlib/darwin/io.bot: libSystem's write, read,
# close and the thread's errno; the portable std::io::IO through DarwinIO; a
# Mach-O executable printing through it) runs on macos-aarch64 since
# milestone 8 (MACOS-AARCH64-MILESTONE-8.md), and is refused everywhere else
# before anything runs: `darwin` is the macOS platform's namespace
# (UNSUPPORTED-PLATFORM), as `linux` is Linux's. A
# native stack overflow is NATIVE LIMIT STACK on
# every host, the thread's stack and a coroutine's alike: on macos-aarch64
# since milestone 4 (MACOS-AARCH64-MILESTONE-4.md), where until then the
# driver died in Rust's stack-overflow abort (the thread's stack) or of
# SIGBUS (a coroutine's).
#
# On windows-x86_64 (WINDOWS-X86-64-MILESTONE-1.md, MSVC's toolchain) the
# JIT, the collector -- with the fallback root plan, no frame walk -- program
# objects (COFF) and standalone executables (PE) work; a program built for
# Linux or for windows-x86_64-gnu (MinGW's environment) is NATIVE TARGET.
# Since milestone 2 (WINDOWS-X86-64-MILESTONE-2.md) a C call is linked by
# link.exe and runs, returning 5, and byte storage exposed to the C library
# gives the values every other host gives -- until then both were refused
# before the linker ran (NATIVE LINK, "C calls are linked on Linux glibc
# (x86_64, aarch64) and macOS (aarch64) only") -- and Windows I/O
# (stdlib/windows.bot, stdlib/windows/io.bot: kernel32's GetStdHandle, WriteFile
# and GetLastError; the portable std::io::IO through WindowsIO; a PE executable
# printing through it) runs, refused everywhere else (`windows` is the
# Windows platform's namespace: UNSUPPORTED-PLATFORM). A variadic C call is
# still a codegen error on Windows (no Win64 variadic lowering), as are
# coroutines (NATIVE UNSUPPORTED); there is no stack guard. Since milestone 3
# (WINDOWS-X86-64-MILESTONE-3.md) the collector finds the roots in native
# frames (gc-frame-walk: Windows' unwinder across Rust frames), and a
# function with a Botlish call checks its stack pointer against the thread's
# stack instead of the shadow stack's depth: so the 4 MiB stack of the
# stack-overflow probe ends in NATIVE LIMIT STACK too, where until then it
# killed the driver before the shadow stack's depth check fired (Rust's own
# stack overflow report, recorded as the probe's NATIVE BUG). The
# recursion-limit probe is the same limit reached by a compiled program whose
# functions cannot otherwise fail: the check's failure is a call's error
# there (nir's call effects), and until milestone 1 a caller that did not
# check for it crashed in rt_int_add.
#
# Since milestone 2 (MACOS-AARCH64-MILESTONE-2.md) a program importing a
# Linux namespace does not compile for macos-aarch64 at all
# (UNSUPPORTED-PLATFORM), where it used to compile with Linux's
# stdlib/linux/sys.aarch64.bot and fail at run time; the target, convention
# and other-target probes record the target boundary.
set linux [dict create \
    jit {value 6765} \
    gc-frame-walk [list value [list str [string repeat xy 400]]] \
    stack-overflow {error {NATIVE LIMIT STACK} {native stack exhausted: too many nested calls}} \
    runtime-stack-overflow {error {NATIVE LIMIT STACK} {native stack exhausted: too many nested calls}} \
    large-frame-overflow {error {NATIVE LIMIT STACK} {native stack exhausted: too many nested calls}} \
    recursion-limit {error {NATIVE LIMIT STACK} {native stack exhausted: too many nested calls}} \
    coroutine-stack-overflow {error {NATIVE LIMIT STACK} {native stack exhausted: too many nested calls}} \
    coroutine {value {[10, 7]}} \
    linux-syscall {value 0} \
    c-call {value 5} \
    c-byte-borrow {value {[true, true, 0, true, 0]}} \
    darwin-read-write {error {SURFACE MODULE UNSUPPORTED-PLATFORM} {*namespace "std::darwin" belongs to the macOS platform (the standard namespace std::darwin and every namespace under it)*unavailable for target linux-*}} \
    darwin-errno {error {SURFACE MODULE UNSUPPORTED-PLATFORM} {*namespace "std::darwin" belongs to the macOS platform*unavailable for target linux-*}} \
    darwin-io {error {SURFACE MODULE UNSUPPORTED-PLATFORM} {*namespace "std::darwin::io" belongs to the macOS platform*unavailable for target linux-*}} \
    darwin-executable {error {SURFACE MODULE UNSUPPORTED-PLATFORM} {*namespace "std::darwin::io" belongs to the macOS platform*unavailable for target linux-*}} \
    windows-write {error {SURFACE MODULE UNSUPPORTED-PLATFORM} {*namespace "std::windows" belongs to the Windows platform (the standard namespace std::windows and every namespace under it)*unavailable for target linux-*}} \
    windows-io {error {SURFACE MODULE UNSUPPORTED-PLATFORM} {*namespace "std::windows::io" belongs to the Windows platform*unavailable for target linux-*}} \
    windows-executable {error {SURFACE MODULE UNSUPPORTED-PLATFORM} {*namespace "std::windows::io" belongs to the Windows platform*unavailable for target linux-*}} \
    target {value {format elf c-call-conv system_v runs 1}} \
    c-convention {value {labs system_v abs system_v}} \
    c-variadic {value {printf system_v}} \
    other-target {error {NATIVE TARGET} {this program was built for target macos-* and native code runs only on its own target's host*matching architecture is not a matching target*}}]
set expected [dict create \
    linux-x86_64 [dict merge $linux {
        object {value {elf x86_64 relocatable}}
        executable {value {{elf x86_64 shared} 6765}}
    }] \
    linux-aarch64 [dict merge $linux {
        object {value {elf aarch64 relocatable}}
        executable {value {{elf aarch64 shared} 6765}}
    }] \
    macos-aarch64 [dict create \
        jit {value 6765} \
        gc-frame-walk [list value [list str [string repeat xy 400]]] \
        stack-overflow {error {NATIVE LIMIT STACK} {native stack exhausted: too many nested calls}} \
        runtime-stack-overflow {error {NATIVE LIMIT STACK} {native stack exhausted: too many nested calls}} \
        large-frame-overflow {error {NATIVE LIMIT STACK} {native stack exhausted: too many nested calls}} \
        recursion-limit {error {NATIVE LIMIT STACK} {native stack exhausted: too many nested calls}} \
        coroutine-stack-overflow {error {NATIVE LIMIT STACK} {native stack exhausted: too many nested calls}} \
        coroutine {value {[10, 7]}} \
        linux-syscall {error {SURFACE MODULE UNSUPPORTED-PLATFORM} {*namespace "std::linux" belongs to the Linux platform*unavailable for target macos-aarch64 (macOS on aarch64)*}} \
        c-call {value 5} \
        c-byte-borrow {value {[true, true, 0, true, 0]}} \
        darwin-read-write {value {[0, 0, -1, 9]}} \
        darwin-errno {value {[-1, 9, 0, 0, -1, 9]}} \
        darwin-io {value {"ok"}} \
        darwin-executable {value {{macho arm64 execute} {Hello, world!
unit}}} \
        windows-write {error {SURFACE MODULE UNSUPPORTED-PLATFORM} {*namespace "std::windows" belongs to the Windows platform*unavailable for target macos-aarch64 (macOS on aarch64)*}} \
        windows-io {error {SURFACE MODULE UNSUPPORTED-PLATFORM} {*namespace "std::windows::io" belongs to the Windows platform*unavailable for target macos-aarch64 (macOS on aarch64)*}} \
        windows-executable {error {SURFACE MODULE UNSUPPORTED-PLATFORM} {*namespace "std::windows::io" belongs to the Windows platform*unavailable for target macos-aarch64 (macOS on aarch64)*}} \
        object {value {macho arm64 object}} \
        executable {value {{macho arm64 execute} 6765}} \
        target {value {format macho c-call-conv apple_aarch64 runs 1}} \
        c-convention {value {labs apple_aarch64 abs apple_aarch64}} \
        c-variadic {value {printf apple_aarch64}} \
        other-target {error {NATIVE TARGET} {this program was built for target linux-aarch64 (aarch64-unknown-linux-gnu)*Both are aarch64, but a matching architecture is not a matching target*}}] \
    windows-x86_64 [dict create \
        jit {value 6765} \
        gc-frame-walk [list value [list str [string repeat xy 400]]] \
        stack-overflow {error {NATIVE LIMIT STACK} {native stack exhausted: too many nested calls}} \
        stack-depth-limit {error {NATIVE LIMIT STACK} {native stack exhausted: too many nested calls}} \
        runtime-stack-overflow {error {NATIVE LIMIT STACK} {native stack exhausted: too many nested calls}} \
        large-frame-overflow {error {NATIVE LIMIT STACK} {native stack exhausted: too many nested calls}} \
        recursion-limit {error {NATIVE LIMIT STACK} {native stack exhausted: too many nested calls}} \
        coroutine-stack-overflow {error {NATIVE UNSUPPORTED value} {native coroutines need stack switching, implemented for Linux x86-64 and AArch64 and macOS AArch64 only*}} \
        coroutine {error {NATIVE UNSUPPORTED value} {native coroutines need stack switching, implemented for Linux x86-64 and AArch64 and macOS AArch64 only*}} \
        linux-syscall {error {SURFACE MODULE UNSUPPORTED-PLATFORM} {*namespace "std::linux" belongs to the Linux platform*unavailable for target windows-x86_64 (Windows on x86_64)*}} \
        c-call {value 5} \
        c-byte-borrow {value {[true, true, 0, true, 0]}} \
        darwin-read-write {error {SURFACE MODULE UNSUPPORTED-PLATFORM} {*namespace "std::darwin" belongs to the macOS platform*unavailable for target windows-x86_64 (Windows on x86_64)*}} \
        darwin-errno {error {SURFACE MODULE UNSUPPORTED-PLATFORM} {*namespace "std::darwin" belongs to the macOS platform*unavailable for target windows-x86_64 (Windows on x86_64)*}} \
        darwin-io {error {SURFACE MODULE UNSUPPORTED-PLATFORM} {*namespace "std::darwin::io" belongs to the macOS platform*unavailable for target windows-x86_64 (Windows on x86_64)*}} \
        darwin-executable {error {SURFACE MODULE UNSUPPORTED-PLATFORM} {*namespace "std::darwin::io" belongs to the macOS platform*unavailable for target windows-x86_64 (Windows on x86_64)*}} \
        windows-write {value {[true, 0, 0]}} \
        windows-io {value {"ok"}} \
        windows-executable {value {{pe x86_64 executable} {Hello, world!
unit}}} \
        object {value {coff x86_64 object}} \
        executable {value {{pe x86_64 executable} 6765}} \
        target {value {format coff c-call-conv windows_fastcall runs 1}} \
        c-convention {value {labs windows_fastcall abs windows_fastcall}} \
        c-variadic {error {NATIVE CODEGEN} {*variadic C call of printf: no variadic call lowering for the windows_fastcall convention*}} \
        other-target {error {NATIVE TARGET} {this program was built for target linux-x86_64 (x86_64-unknown-linux-gnu)*Both are x86_64, but a matching architecture is not a matching target*}} \
        other-environment {error {NATIVE TARGET} {this program was built for target windows-x86_64-gnu (x86_64-pc-windows-gnu)*Both are x86_64 windows, but the C toolchain environment is part of the target: gnu for this program, msvc here*}}]]

# The outcome of running SCRIPT with ENVIRONMENT ({NAME VALUE ...}) set:
# {value TEXT} or {error CODE MESSAGE}.
proc outcome {environment script} {
    set saved {}
    foreach {name value} $environment {
        lappend saved $name [expr {[info exists ::env($name)] ? [list $::env($name)] : {}}]
        set ::env($name) $value
    }
    try {
        set code [catch {uplevel 1 $script} result options]
    } finally {
        foreach {name value} $saved {
            if {$value eq {}} { unset ::env($name) } else { set ::env($name) [lindex $value 0] }
        }
    }
    if {$code == 0} {
        return [list value $result]
    }
    set errorCode [dict get $options -errorcode]
    if {[lindex $errorCode 0] eq "NATIVE"} {
        return [list error [lrange $errorCode 0 2] $result]
    }
    return [list error $errorCode $result]
}

# The observed outcome of probe NAME.
proc observe {name} {
    global probes fixtures
    lassign [dict get $probes $name] kind argument environment
    switch -- $kind {
        driver {
            return [outcome $environment {
                lindex [native::Outcome [native::Driver run [core::ReadFile [file join $fixtures $argument]]]]
            }]
        }
        program {
            return [outcome $environment {
                core::formatValue [native::evalHir [surface::compile $argument -warnings off]]
            }]
        }
        target {
            return [outcome $environment {
                dict filter [native::targetFacts [dict get [core::cabi::target [core::cabi::hostTarget]] triple]] \
                    key format c-call-conv runs
            }]
        }
        convention {
            return [outcome $environment {
                foreignConventions [native::clif [surface::compile $argument -warnings off]]
            }]
        }
        other-environment {
            return [outcome $environment {
                core::formatValue [native::evalHir [surface::compile $argument -warnings off -target windows-x86_64-gnu]]
            }]
        }
        other-target {
            set host [dict get [core::cabi::target [core::cabi::hostTarget]] os]
            set other [expr {$host eq "linux" ? "macos" : "linux"}]-[core::cabi::hostArchitecture]
            return [outcome $environment {
                core::formatValue [native::evalHir [surface::compile $argument -warnings off -target $other]]
            }]
        }
        object {
            set work [file tempdir botlish-native-status]
            try {
                return [outcome $environment {
                    set path [file join $work probe.o]
                    native::object [surface::compile $argument -warnings off] $path
                    binaryHeader $path
                }]
            } finally {
                file delete -force $work
            }
        }
        executable {
            set work [file tempdir botlish-native-status]
            try {
                return [outcome $environment {
                    set path [native::executable [surface::compile $argument -warnings off] [file join $work probe]]
                    list [binaryHeader $path] [string trim [exec $path]]
                }]
            } finally {
                file delete -force $work
            }
        }
    }
}

# {SYMBOL CONVENTION ...}: the calling convention of every foreign C
# function's signature in the CLIF text CLIF (`; u0:N = NAME (C SYMBOL)`, or
# a variadic call's `; u0:N = NAME (%al=K stub of C SYMBOL)` on x86-64
# System V, then a function's `fnK = u0:N sigM` and its `sigM = (...) -> ...
# CONV`).
proc foreignConventions {clif} {
    set symbols [dict create]
    foreach {- ref symbol} [regexp -all -inline -line {^; (u0:[0-9]+) = \S+ \((?:%al=[0-9]+ stub of )?C (\S+)\)$} $clif] {
        dict set symbols $ref $symbol
    }
    set result [dict create]
    foreach function [split [string map [list "\n\}\n" \x00] $clif] \x00] {
        set sigs [dict create]
        foreach {- sig conv} [regexp -all -inline -line {^\s+(sig[0-9]+) = .* (\S+)$} $function] {
            dict set sigs $sig $conv
        }
        foreach {- ref sig} [regexp -all -inline -line {^\s+fn[0-9]+ = (?:colocated )?(u0:[0-9]+) (sig[0-9]+)$} $function] {
            if {[dict exists $symbols $ref] && [dict exists $sigs $sig]} {
                dict set result [dict get $symbols $ref] [dict get $sigs $sig]
            }
        }
    }
    return $result
}

proc matches {expectation observed} {
    if {[lindex $expectation 0] ne [lindex $observed 0]} {
        return 0
    }
    if {[lindex $expectation 0] eq "value"} {
        return [expr {[lindex $expectation 1] eq [lindex $observed 1]}]
    }
    return [expr {[lindex $expectation 1] eq [lindex $observed 1]
        && [string match [lindex $expectation 2] [lindex $observed 2]]}]
}

# A probe's outcome for the table: at most one line, and no more than 100
# characters of it.
proc brief {outcome} {
    set text [join $outcome " "]
    set text [lindex [split $text \n] 0]
    if {[string length $text] > 100} { set text "[string range $text 0 96]..." }
    return $text
}

set host [core::cabi::hostTarget]
if {![dict exists $expected $host]} {
    puts "FAIL: no native expectations recorded for host target \"$host\" ($::tcl_platform(os) $::tcl_platform(machine))"
    exit 1
}
puts "native status on $host ($::tcl_platform(os) $::tcl_platform(machine)), driver [native::binary]"
set differences 0
dict for {name expectation} [dict get $expected $host] {
    set observed [observe $name]
    set ok [matches $expectation $observed]
    if {!$ok} { incr differences }
    puts [format "%-4s %-15s expected: %s" [expr {$ok ? "ok" : "FAIL"}] $name [brief $expectation]]
    if {!$ok || $verbose} {
        puts [format "%-4s %-15s observed: %s" "" "" [brief $observed]]
        if {!$ok} {
            puts "     full observed outcome:\n[join [lmap line [split [join $observed { }] \n] {string cat {       } $line}] \n]"
        }
    }
}
if {$differences} {
    puts "FAIL: $differences native capabilities do not behave as recorded for $host: if a port milestone changed one on purpose, record its new outcome in tests/platform/native-status.tcl (and MACOS-AARCH64-PORT-AUDIT.md)"
    exit 1
}
puts "ok: every native capability behaves as recorded for $host"
