#!/usr/bin/env tclsh9.0
# mutate.tcl -- mutation test of the MutableBytes / read(2) boundary
# (MUTABLE-BYTES.md).
#
#   tclsh9.0 audit/mutable-bytes/tools/mutate.tcl ?-only NAME? ?-list 1? ?-fuzz N?
#
# Each mutation breaks exactly one piece of the implementation in a scratch
# copy of the tree (never the repository), rebuilds the native backend when the
# mutant is Rust, and runs tests/abi-mutable-bytes.test against it (and, with
# -fuzz N, the differential fuzzer's read mode over N programs). A mutant is
# KILLED if any test (or the fuzzer) fails; the names of the failing tests are
# printed. A SURVIVOR is a boundary nothing tests: the run exits 1 if there is
# one.
#
# The failures a value-semantics-over-a-writable-buffer boundary is prone to:
#
#   clone-aliases            the detach hands back the very storage it was given
#                            (a logical copy aliases mutable storage): read
#                            then writes into the caller's own buffer
#   set-aliases              mutable_bytes_set writes into its operand instead of
#                            a fresh copy (an update visible through every copy)
#   read-does-not-detach     linux::read hands the kernel the caller's storage
#                            (the function argument is not copied)
#   freeze-shares            freeze flips the mutable object into a Bytes in
#                            place: a zero-copy freeze with no proof, so the
#                            "immutable" Bytes shares writable backing
#   from-bytes-shares        mutable_bytes_from_bytes reuses the Bytes' own
#                            storage as writable memory
#   clone-zeroes             the detach loses the contents (an untouched
#                            suffix would read as zeros)
#   address-one-late         the writable bridge points one byte past the payload
#   read-uses-bytes-bridge   the lowering emits the READABLE address op for the
#                            writable bridge
#   count-off-by-one         read's count register is the length + 1
#   count-unrelated          read's count is not the buffer's length (a
#                            constant 1)
#   no-keepalive             the lowering never emits the keepalive after a
#                            syscall (the backing is not kept alive)
#   result-is-the-original   read returns the pre-syscall buffer, not the one
#                            the kernel wrote
#   rax-is-write             read issues syscall number 1 instead of 0
#   libc-read                the syscall boundary, for syscall number 0, calls
#                            libc's read instead of executing the instruction
#   read-twice               read makes the syscall twice
#   prefix-is-suffix         freeze_prefix returns the LAST count bytes
#   equality-by-identity     two writable storages are equal iff the same object
#   hash-ignores-length      the native hash of a MutableBytes omits the count
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

# The library text of linux::read, the one place the Tcl-side mutants rewrite.
set readHead {fn read(fd: abi::I32, data: abi::MutableBytes) -> ReadResult:
    local = abi::mutable_bytes_copy(data)
    result = abi::x86_64::to_int(
        linux::abi::syscall({
            rax: abi::x86_64::register64(0),
            rdi: abi::x86_64::from_i32(fd),
            rsi: abi::x86_64::from_mutable_bytes(local),
            rdx: abi::x86_64::from_usize(abi::mutable_bytes_length(local)),
        })
    )
    ReadResult {result: result, data: local}}

# {NAME KIND FILE OLD NEW}: NEW replaces the first occurrence of OLD in FILE
# (KIND rust: rebuild afterwards).
set mutations {
    {clone-aliases rust native/src/runtime/ops.rs
        {    vm(p).metrics.record_list_copy(mutbytes_of(m).len());
    vm(p).new_mutbytes_with(mutbytes_of(m).len(), |init| init.push_slice(mutbytes_of(m)))
}
        {    m
}}
    {set-aliases rust native/src/runtime/ops.rs
        {let r = vm(p).new_mutbytes_with(len, |init| init.push_slice(mutbytes_of(m)));}
        {let r = m;}}
    {read-does-not-detach tcl lib/linux.bot
        {    local = abi::mutable_bytes_copy(data)}
        {    local = data}}
    {freeze-shares rust native/src/runtime/ops.rs
        {    vm(p).metrics.record_list_copy(mutbytes_of(m).len());
    vm(p).new_bytes_with(mutbytes_of(m).len(), |init| init.push_slice(mutbytes_of(m)))}
        {    unsafe { (*(m as *mut Header)).kind = KIND_BYTES };
    m}}
    {from-bytes-shares rust native/src/runtime/ops.rs
        {    vm(p).metrics.record_list_copy(bytes_of(v).len());
    vm(p).new_mutbytes_with(bytes_of(v).len(), |init| init.push_slice(bytes_of(v)))}
        {    unsafe { (*(v as *mut Header)).kind = KIND_MUTBYTES };
    v}}
    {clone-zeroes rust native/src/runtime/ops.rs
        {    vm(p).metrics.record_list_copy(mutbytes_of(m).len());
    vm(p).new_mutbytes_with(mutbytes_of(m).len(), |init| init.push_slice(mutbytes_of(m)))
}
        {    vm(p).metrics.record_list_copy(mutbytes_of(m).len());
    vm(p).new_mutbytes_with(mutbytes_of(m).len(), |init| init.push_zeros(mutbytes_of(m).len()))
}}
    {address-one-late rust native/src/runtime/ops.rs
        {let address = BytesObj::payload_address(m) as i64;}
        {let address = BytesObj::payload_address(m) as i64 + 1;}}
    {read-uses-bytes-bridge tcl native/lower.tcl
        {set bridgeOp [expr {[core::bytestore::bridgeWritable $native] ? "mbytesaddr" : "bytesaddr"}]}
        {set bridgeOp bytesaddr}}
    {count-off-by-one tcl lib/linux.bot
        {            rdx: abi::x86_64::from_usize(abi::mutable_bytes_length(local)),}
        {            rdx: abi::x86_64::from_usize(plus_one(abi::mutable_bytes_length(local))),}}
    {count-unrelated tcl lib/linux.bot
        {            rdx: abi::x86_64::from_usize(abi::mutable_bytes_length(local)),}
        {            rdx: abi::x86_64::from_usize(abi::usize(1)),}}
    {no-keepalive tcl native/lower.tcl
        {    foreach storage $kept {
        Assign fn "op keepalive $storage" $e
    }}
        {    foreach storage $kept {
    }}}
    {result-is-the-original tcl lib/linux.bot
        {    ReadResult {result: result, data: local}}
        {    ReadResult {result: result, data: data}}}
    {rax-is-write tcl lib/linux.bot
        {            rax: abi::x86_64::register64(0),
            rdi: abi::x86_64::from_i32(fd),
            rsi: abi::x86_64::from_mutable_bytes(local),}
        {            rax: abi::x86_64::register64(1),
            rdi: abi::x86_64::from_i32(fd),
            rsi: abi::x86_64::from_mutable_bytes(local),}}
    {libc-read rust native/src/runtime/syscall.rs
        {    let result: i64;}
        {    if rax == 0 {
        unsafe extern "C" { fn read(fd: i32, buf: *mut u8, n: usize) -> isize; }
        return unsafe { read(rdi as i32, rsi as *mut u8, rdx as usize) as i64 };
    }
    let result: i64;}}
    {read-twice tcl lib/linux.bot
        {    ReadResult {result: result, data: local}}
        {    result2 = abi::x86_64::to_int(
        linux::abi::syscall({
            rax: abi::x86_64::register64(0),
            rdi: abi::x86_64::from_i32(fd),
            rsi: abi::x86_64::from_mutable_bytes(local),
            rdx: abi::x86_64::from_usize(abi::mutable_bytes_length(local)),
        })
    )
    ReadResult {result: result2, data: local}}}
    {prefix-is-suffix rust native/src/runtime/ops.rs
        {init.push_slice(&mutbytes_of(m)[..count])}
        {init.push_slice(&mutbytes_of(m)[mutbytes_of(m).len() - count..])}}
    {equality-by-identity rust native/src/runtime/ops.rs
        {Kind::MutByteStore => mutbytes_of(a) == mutbytes_of(b),}
        {Kind::MutByteStore => a == b,}}
    {hash-ignores-length rust native/src/runtime/ops.rs
        {            let bytes = mutbytes_of(v);
            let h = fnv1a(h, &(bytes.len() as u64).to_le_bytes());
            fnv1a(h, bytes)}
        {            let bytes = mutbytes_of(v);
            fnv1a(h, bytes)}}
}

# count-off-by-one needs its helper function in the library: appended to the
# mutated file by the probe below.
set extraLibrary [dict create count-off-by-one {
fn plus_one(n: abi::Usize) -> abi::Usize:
    v = n.value + 1
    if v > 18446744073709551615:
        abi::Usize {value: 0}
    else:
        abi::Usize {value: v}
}]

if {$listOnly} {
    foreach m $mutations { puts [lindex $m 0] }
    exit 0
}

set work [file tempdir mutable-bytes-mutants]
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

# Run SCRIPT with DIR as the working directory. tests/abi-mutable-bytes.test (tcltest)
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
    if {[dict exists $::extraLibrary $name]} {
        set channel [open [file join $dir $file] a]
        fconfigure $channel -encoding utf-8
        puts -nonewline $channel [dict get $::extraLibrary $name]
        close $channel
    }
    if {$kind eq "rust"} {
        puts "== $name: rebuilding the native backend"
        set status [catch {exec cargo build --release --manifest-path [file join $dir native Cargo.toml] 2>@1} output]
        if {$status} {
            puts "   BUILD FAILED: [string range $output end-600 end]"
            lappend survivors "$name (build failed)"
            continue
        }
    }
    # A Tcl-side mutant that does not even compile would be "killed" by every
    # test without proving anything: run the example once first and refuse such
    # a mutant (the example's compile-time errors print as "error:"). A Rust
    # mutant cannot cause a compile error once the crate builds, and it may
    # legitimately break the example's run (a write one byte too long corrupts
    # the in-process runner's own output), so it is not probed.
    set probe ""
    if {$kind eq "tcl"} {
        inDir $dir {
            catch {exec [info nameofexecutable] [file join $dir main.tcl] -backend cranelift [file join $dir examples linux read-stdin.bot] 2>@1} probe
        }
    }
    if {[string match "*   error:*" $probe]} {
        set shown {}
        foreach line [split $probe \n] {
            if {[string match "*   error:*" $line]} { lappend shown [string trim $line] }
        }
        puts "   INVALID MUTANT (does not compile): $name: [string range [join $shown { | }] 0 400]"
        lappend survivors "$name (invalid: does not compile)"
        file delete -force $dir
        continue
    }
    set failing {}
    set output ""
    inDir $dir {
        catch {exec [info nameofexecutable] [file join $dir tests abi-mutable-bytes.test] 2>@1} output
    }
    foreach line [split $output \n] {
        if {[regexp {^==== (\S+) .*FAILED$} $line -> test]} { lappend failing $test }
    }
    set failing [lsort -unique $failing]
    set fuzzFailures 0
    if {$fuzzPrograms > 0} {
        inDir $dir {
            catch {exec [info nameofexecutable] [file join $dir audit mutable-bytes tools fuzz.tcl] -mode read -n $fuzzPrograms -seed 7000 2>@1} fuzzOutput
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
puts "mutable-bytes-mutate mutants $ran killed $killed survivors [llength $survivors] {$survivors}"
exit [expr {[llength $survivors] ? 1 : 0}]
