#!/usr/bin/env tclsh9.0
# mutate.tcl -- mutation test of the Bytes / write(2) boundary (ABI-BYTES.md).
#
#   tclsh9.0 audit/abi-bytes/tools/mutate.tcl ?-only NAME? ?-list 1? ?-fuzz N?
#
# Each mutation breaks exactly one piece of the implementation in a scratch
# copy of the tree (never the repository), rebuilds the native backend when the
# mutant is Rust, and runs tests/abi-bytes.test against it (and, with -fuzz N,
# the differential fuzzer's write mode over N programs). A mutant is KILLED if
# any test (or the fuzzer) fails; the names of the failing tests are printed.
# A SURVIVOR is a boundary nothing tests: the run exits 1 if there is one.
#
# The first write syscall of a program that moves memory deserves strong
# boundary tests; these are the failures such a boundary is prone to:
#
#   length-off-by-one        the length accessor returns one too many
#   nul-as-terminator        creation stops at the first zero byte
#   payload-offset-by-one    the address bridge returns the payload address + 1
#   byte-masked-to-7-bits    creation stores byte & 0x7f
#   count-truncated          write's count register carries length mod 2^16
#                            (the same bug as truncating a Usize count to U32,
#                            which only a 4 GiB payload could expose: 2^16 is
#                            the smallest truncation this test file's large
#                            payloads reach)
#   no-keepalive             the lowering never emits the keepalive after a
#                            syscall (the backing is not kept alive)
#   address-in-rdx           the address register and the count register are
#                            swapped in the wrapper
#   libc-write               the syscall boundary, for syscall number 1, calls
#                            libc's write instead of executing the syscall
#                            instruction: output is identical, only the
#                            machine-level evidence can tell
#   write-twice              the wrapper makes the syscall twice
#   equality-by-identity     two storages are equal iff they are the same
#                            object (the native runtime's equality)
#   hash-ignores-length      the native hash omits the byte count
#   static-constant-ascii    a static byte constant is encoded as ASCII, not UTF-8
#
# Rust mutants reuse a copy of the already-built target directory, so each
# rebuild recompiles only the botlish-native crate.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set args $argv
set only ""
set listOnly 0
set fuzzPrograms 0
while {[lindex $args 0] in {-only -list -fuzz}} {
    switch -- [lindex $args 0] {
        -only { set only [lindex $args 1] }
        -list { set listOnly [lindex $args 1] }
        -fuzz { set fuzzPrograms [lindex $args 1] }
    }
    set args [lrange $args 2 end]
}

# {NAME KIND FILE OLD NEW}: NEW replaces the single occurrence of OLD in FILE
# (KIND rust: rebuild afterwards).
set mutations {
    {length-off-by-one rust native/src/runtime/ops.rs
        {make_small(bytes_of(v).len() as i64)}
        {make_small(bytes_of(v).len() as i64 + 1)}}
    {nul-as-terminator rust native/src/runtime/ops.rs
        {    let r = vm(p).new_bytes(&bytes);
    vm(p).metrics.record_list_copy(bytes.len());}
        {    if let Some(zero) = bytes.iter().position(|b| *b == 0) { bytes.truncate(zero); }
    let r = vm(p).new_bytes(&bytes);
    vm(p).metrics.record_list_copy(bytes.len());}}
    {payload-offset-by-one rust native/src/runtime/bytesobj.rs
        {v + BYTES_PAYLOAD_OFFSET as u64}
        {v + BYTES_PAYLOAD_OFFSET as u64 + 1}}
    {byte-masked-to-7-bits rust native/src/runtime/ops.rs
        {Some(n) if (0..=255).contains(&n) => n as u8,}
        {Some(n) if (0..=255).contains(&n) => (n as u8) & 0x7f,}}
    {count-truncated tcl lib/linux.bot
        {fn write(fd: abi::I32, data: abi::Bytes) -> int:
    abi::x86_64::to_int(
        linux::abi::syscall({
            rax: abi::x86_64::register64(1),
            rdi: abi::x86_64::from_i32(fd),
            rsi: abi::x86_64::from_bytes(data),
            rdx: abi::x86_64::from_usize(abi::bytes_length(data)),
        })
    )}
        {fn trunc16(n: abi::Usize) -> abi::Usize:
    v = mod(n.value, 65536)
    if v > 65535:
        abi::Usize {value: 0}
    else:
        abi::Usize {value: v}

fn write(fd: abi::I32, data: abi::Bytes) -> int:
    abi::x86_64::to_int(
        linux::abi::syscall({
            rax: abi::x86_64::register64(1),
            rdi: abi::x86_64::from_i32(fd),
            rsi: abi::x86_64::from_bytes(data),
            rdx: abi::x86_64::from_usize(trunc16(abi::bytes_length(data))),
        })
    )}}
    {no-keepalive tcl native/lower.tcl
        {    foreach storage $kept {
        Assign fn "op keepalive $storage" $e
    }}
        {    foreach storage $kept {
    }}}
    {address-in-rdx tcl lib/linux.bot
        {            rsi: abi::x86_64::from_bytes(data),
            rdx: abi::x86_64::from_usize(abi::bytes_length(data)),}
        {            rdx: abi::x86_64::from_bytes(data),
            rsi: abi::x86_64::from_usize(abi::bytes_length(data)),}}
    {libc-write rust native/src/runtime/syscall.rs
        {    let result: i64;}
        {    if rax == 1 {
        unsafe extern "C" { fn write(fd: i32, buf: *const u8, n: usize) -> isize; }
        return unsafe { write(rdi as i32, rsi as *const u8, rdx as usize) as i64 };
    }
    let result: i64;}}
    {write-twice tcl lib/linux.bot
        {fn write(fd: abi::I32, data: abi::Bytes) -> int:
    abi::x86_64::to_int(}
        {fn write(fd: abi::I32, data: abi::Bytes) -> int:
    abi::x86_64::to_int(
        linux::abi::syscall({
            rax: abi::x86_64::register64(1),
            rdi: abi::x86_64::from_i32(fd),
            rsi: abi::x86_64::from_bytes(data),
            rdx: abi::x86_64::from_usize(abi::bytes_length(data)),
        })
    )
    abi::x86_64::to_int(}}
    {equality-by-identity rust native/src/runtime/ops.rs
        {Kind::ByteStore => bytes_of(a) == bytes_of(b),}
        {Kind::ByteStore => a == b,}}
    {hash-ignores-length rust native/src/runtime/ops.rs
        {            let h = fnv1a(h, &(bytes.len() as u64).to_le_bytes());
            fnv1a(h, bytes)}
        {            fnv1a(h, bytes)}}
    {static-constant-ascii tcl native/lower.tcl
        {return [list [binary encode hex [encoding convertto utf-8 [core::value::strOf [lindex $fact 1]]]]]}
        {return [list [binary encode hex [encoding convertto ascii [core::value::strOf [lindex $fact 1]]]]]}}
}

if {$listOnly} {
    foreach m $mutations { puts [lindex $m 0] }
    exit 0
}

set work [file tempdir abi-bytes-mutants]
set survivors {}
set killed 0
set ran 0

# A copy of the tree in DESTINATION. The built native backend (native/target) is
# copied for a Rust mutant (it is about to be rebuilt) and symbolically linked
# for a Tcl-only one (it is only read).
proc copyTree {destination copyTarget} {
    file mkdir $destination
    foreach entry {core hir surface compiler lib native tests examples main.tcl audit} {
        set source [file join $::root $entry]
        if {$entry eq "native"} {
            file mkdir [file join $destination native]
            foreach item [glob -directory $source -tails *] {
                if {$item eq "target"} {
                    if {$copyTarget} {
                        file copy $source/target $destination/native/target
                    } else {
                        file link -symbolic $destination/native/target $source/target
                    }
                } else {
                    file copy $source/$item $destination/native/$item
                }
            }
        } else {
            file copy $source [file join $destination $entry]
        }
    }
}

# Run SCRIPT with DIR as the working directory. tests/abi-bytes.test (tcltest)
# keeps its scratch, executable and output directories in the working
# directory, so every mutant runs in its own copy of the tree: two mutation
# runs started at once from the same directory would otherwise share and
# delete each other's files.
proc inDir {dir script} {
    set previous [pwd]
    cd $dir
    try {
        uplevel 1 $script
    } finally {
        cd $previous
    }
}

proc replaceOnce {path old new} {
    set channel [open $path r]
    fconfigure $channel -encoding utf-8
    set text [read $channel]
    close $channel
    set index [string first $old $text]
    if {$index < 0} {
        error "mutation target not found in $path: [string range $old 0 60]"
    }
    set text [string replace $text $index [expr {$index + [string length $old] - 1}] $new]
    set channel [open $path w]
    fconfigure $channel -encoding utf-8
    puts -nonewline $channel $text
    close $channel
}

foreach m $mutations {
    lassign $m name kind file old new
    if {$only ne "" && $only ne $name} continue
    incr ran
    set dir [file join $work $name]
    puts "== $name: copying the tree"
    copyTree $dir [expr {$kind eq "rust"}]
    replaceOnce [file join $dir $file] $old $new
    if {$kind eq "rust"} {
        puts "== $name: rebuilding the native backend"
        set status [catch {exec cargo build --release --manifest-path [file join $dir native Cargo.toml] 2>@1} output]
        if {$status} {
            puts "   BUILD FAILED: [string range $output end-600 end]"
            lappend survivors "$name (build failed)"
            continue
        }
    }
    # A mutant that does not even compile would be "killed" by every test
    # without proving anything: run the example once first and refuse such a
    # mutant (the example's compile-time errors print as "error:").
    set probe ""
    inDir $dir {
        catch {exec [info nameofexecutable] [file join $dir main.tcl] -backend cranelift [file join $dir examples linux write.bot] 2>@1} probe
    }
    if {[string match "*   error:*" $probe]} {
        puts "   INVALID MUTANT (does not compile): $name: [string range [lindex [split $probe \n] end] 0 200]"
        lappend survivors "$name (invalid: does not compile)"
        file delete -force $dir
        continue
    }
    set failing {}
    set output ""
    inDir $dir {
        catch {exec [info nameofexecutable] [file join $dir tests abi-bytes.test] 2>@1} output
    }
    foreach line [split $output \n] {
        if {[regexp {^==== (\S+) .*FAILED$} $line -> test]} { lappend failing $test }
    }
    set failing [lsort -unique $failing]
    set fuzzFailures 0
    if {$fuzzPrograms > 0} {
        inDir $dir {
            catch {exec [info nameofexecutable] [file join $dir audit abi-bytes tools fuzz.tcl] -mode write -n $fuzzPrograms -seed 7000 2>@1} fuzzOutput
        }
        regexp {failures ([0-9]+)} $fuzzOutput -> fuzzFailures
    }
    if {$failing eq "" && !$fuzzFailures} {
        puts "   SURVIVOR: $name"
        lappend survivors $name
    } else {
        incr killed
        puts "   killed: $name by [llength $failing] test(s) [lrange $failing 0 5]... fuzz failures $fuzzFailures"
    }
    file delete -force $dir
}
file delete -force $work
puts "abi-bytes-mutate mutants $ran killed $killed survivors [llength $survivors] {$survivors}"
exit [expr {[llength $survivors] ? 1 : 0}]
