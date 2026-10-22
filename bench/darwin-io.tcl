# darwin-io.tcl -- what platform IO costs natively: darwin (libSystem) on
# macOS, measured beside the same rows of linux (the syscall transports) on
# Linux (MACOS-AARCH64-MILESTONE-8.md, "Performance observations").
#
#   tclsh9.0 bench/darwin-io.tcl ?-runs N? ?-n N? ?-processes N?
#
# Each platform is measured on its own host, never one against the other: a
# macOS run reports darwin's rows, a Linux run linux's, and the two only
# show that neither has a catastrophic overhead of its own.
#
# 1. Per call, ns: programs that each make N calls in a loop, reported per
#    iteration beside the same loop without the call, and their difference
#    (bench/c-ffi.tcl's method). The loop runs RUNS times inside ONE process
#    (botlish-native bench: on macOS the program calls C, so it is linked as
#    an executable that repeats the run itself; on Linux it runs in the
#    driver), best of RUNS, so neither compilation, linking nor process
#    startup is in it. The program's standard output is /dev/null and its
#    standard input /dev/zero:
#
#      write 14 B       P::write(1, data), DATA a 14-byte Bytes: one C call
#                       (macOS) or syscall (Linux) with a read exposure
#                       (no copy) and the kernel's /dev/null write
#      write 64 KiB     the same with 65536 bytes: flat in the size (the
#                       exposure copies nothing and /dev/null reads nothing)
#      write EBADF      P::write(-1, data): the failure path (macOS: -1 and
#                       errno read through __error() and a native view)
#      read S           P::read(0, m) of an S-byte MutableBytes from
#                       /dev/zero: the write exposure's detach (a fresh
#                       S-byte storage, an S-byte copy -- Botlish's value
#                       semantics) and the kernel filling S bytes
#      read EBADF S     P::read(-1, m): the detach alone and the failure path
#                       (the kernel returns at once); read S minus this row
#                       is the kernel's and the C library's own cost
#      errno()          std::darwin::errno() alone (macOS)
#      print 14 B       std::io::print(text) with the platform's context
#                       installed: the portable path -- write_text's
#                       String-to-UTF-8 encoding into a List[Byte] (made at
#                       run time: the text reaches it as a parameter),
#                       write_all's Bytes from that List and its checks,
#                       one write; print minus `write 14 B` is that path's
#                       own cost (a constant text's encoding written in the
#                       loop itself would be folded into a static storage
#                       at compile time, so it is not measured alone)
#      print 4 KiB      the same with a 4096-byte text
#      print_line 13 B  std::io::print_line("Hello, world!"): + the appended
#                       newline (a new String)
#
# 2. Partial-write completion (macOS): print 4 KiB again with
#    tests/cffi/write-inject.c interposed on libSystem's write, every write
#    on descriptor 1 capped at L bytes (BCF_WRITE_LIMIT): 4096 / L writes per
#    print, each short one completed by std::darwin::io::write_all (the unwritten
#    suffix copied into a new List and Bytes). Without the cap, the
#    interposer's own pass-through cost is the baseline. Linux's syscalls
#    are not interposable (no libc call), so the row is macOS's.
#
# 3. Build and process, ms (best of RUNS; PROCESSES runs of each executable):
#    the front end of examples/io/hello-darwin.bot (hello.bot on Linux),
#    native::executable of it (NIR lowering, Cranelift, the system link of a
#    standalone executable), and the executable run as a process (startup,
#    one print_line, exit), beside an executable that does no IO at all.

set root [file dirname [file dirname [file normalize [info script]]]]
set args $argv
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]

set runs 5
set n 100000
set processes 50
foreach {option value} $args {
    switch -- $option {
        -runs { set runs $value }
        -n { set n $value }
        -processes { set processes $value }
        default { error "unknown option $option" }
    }
}

set host [core::cabi::hostTarget]
set os [dict get [core::cabi::target $host] os]
if {$os eq "macos"} {
    set platform darwin
} elseif {$os eq "linux"} {
    set platform linux
} else {
    puts "darwin-io: no platform IO module for $host"
    exit 0
}
set scratch [file tempdir botlish-bench-darwin-io-]

set prelude "import std::abi\nimport std::abi::bytes\nimport std::byte\nimport std::ffi::c\nimport std::io\nimport std::list\nimport std::str\nimport $platform\nimport $platform\::io\n
fn pattern(n: int):
    loop i from 0 to n:
        std::byte::from_int(mod(i, 256))

"

# The program of SETUP and a loop of N iterations whose body is BODY (or
# BODY then 0, when DISCARDED), with the platform's context installed. A
# program that calls the platform module itself is a direct module
# (DIRECT-MODULES.md); one that only prints is not.
proc program {setup body discarded n} {
    set inner [expr {$discarded ? "$body\n        0" : $body}]
    set marker [expr {[regexp "$::platform\::(write|read|errno)\\(" $body] ? "direct module\n" : ""}]
    return "$marker$::prelude\nfn f() -> int:\n    $setup\n    xs = loop i from 0 to $n:\n        $inner\n    std::list::length(xs)\n\nwith context $::platform\::io::create()\n\nf()\n"
}

# The best time (microseconds) of one run of the program TEXT, inside one
# process, its standard output /dev/null and its standard input /dev/zero;
# INJECTED environment variables ({NAME VALUE ...}) for the program's own
# process only.
proc best {text {injected {}}} {
    set hir [surface::compile $text -warnings off]
    set resultPath [file join $::scratch result]
    file delete $resultPath
    if {[llength $injected]} {
        # The executable the driver would link for the run, run here with the
        # driver protocol's variables (runtime/aot.rs), so that the variables
        # reach the program's process and not the system linker's (the write
        # interposer in cc and ld aborts the link).
        set exe [native::executable $hir [file join $::scratch injected]]
        exec env BOTLISH_NATIVE_RESULT=$resultPath BOTLISH_NATIVE_RUNS=$::runs \
            {*}[lmap {name value} $injected {string cat $name = $value}] $exe </dev/zero >/dev/null 2>/dev/null
    } else {
        set nirPath [file join $::scratch program.nir]
        set channel [open $nirPath w]
        fconfigure $channel -encoding utf-8 -translation lf
        puts -nonewline $channel [native::nir $hir]
        close $channel
        exec [native::binary] bench $::runs $nirPath --result $resultPath </dev/zero >/dev/null 2>/dev/null
    }
    set lines [split [core::ReadFile $resultPath] \n]
    set times [lsearch -inline $lines {times *}]
    if {$times eq ""} {
        error "no timing:\n[join $lines \n]"
    }
    return [expr {[tcl::mathfunc::min {*}[lrange $times 1 end]] / 1000.0}]
}

# "LOOP CALL DIFFERENCE": ns per iteration of the loop without and with the
# call, and their difference.
proc perCall {setup call discarded {injected {}}} {
    set baseline [expr {1000.0 * [best [program $setup 0 0 $::n] $injected] / $::n}]
    set t [expr {1000.0 * [best [program $setup $call $discarded $::n] $injected] / $::n}]
    return [format "%10.1f %10.1f %10.1f" $baseline $t [expr {$t - $baseline}]]
}

# The platform's spelling of a raw call: write's count, read's count, the
# failure's errno (darwin) or -errno (linux).
if {$platform eq "darwin"} {
    set writeCall {std::darwin::write(FD, data).count}
    set readCall {std::darwin::read(FD, m).count}
} else {
    set writeCall {std::linux::write(std::abi::i32(FD), data)}
    set readCall {std::linux::read(std::abi::i32(FD), m).result}
}

set text14 {text = "Hello, world!\n"}
set text4k "text = \"[string repeat x 4095]\\n\""
set bytes14 "$text14\n    data = std::abi::bytes::from_list(std::str::encode_utf8(text))"
set handled ":\n            on std::io::WriteFailed:\n                unit"

proc mutable {s} {
    return "m = std::abi::bytes::from_bytes(std::abi::bytes::from_list(pattern($s)))"
}

try {
    puts "$platform IO on $host"
    puts ""
    puts "1. ns per iteration (best of $runs runs of $n iterations in one process): the loop without the call, with it, the difference"
    puts [format "  %-16s %10s %10s %10s" "" loop "+ call" call]
    puts [format "  %-16s %s" "write 14 B" [perCall $bytes14 [string map {FD 1} $writeCall] 0]]
    puts [format "  %-16s %s" "write 64 KiB" [perCall {data = std::abi::bytes::from_list(pattern(65536))} [string map {FD 1} $writeCall] 0]]
    puts [format "  %-16s %s" "write EBADF" [perCall $bytes14 [string map {FD -1} $writeCall] 0]]
    foreach s {64 4096 65536} {
        puts [format "  %-16s %s" "read $s" [perCall [mutable $s] [string map {FD 0} $readCall] 0]]
    }
    foreach s {64 4096 65536} {
        puts [format "  %-16s %s" "read EBADF $s" [perCall [mutable $s] [string map {FD -1} $readCall] 0]]
    }
    if {$platform eq "darwin"} {
        puts [format "  %-16s %s" "errno()" [perCall {x = 0} {std::darwin::errno()} 0]]
    }
    puts [format "  %-16s %s" "print 14 B" [perCall $text14 "std::io::print(text)$handled" 1]]
    puts [format "  %-16s %s" "print 4 KiB" [perCall $text4k "std::io::print(text)$handled" 1]]
    puts [format "  %-16s %s" "print_line 13 B" [perCall {x = 0} "std::io::print_line(\"Hello, world!\")$handled" 1]]
    puts ""

    if {$platform eq "darwin" && [auto_execok cc] ne ""} {
        set inject [file join $scratch libbcf_write_inject.dylib]
        exec cc -dynamiclib -O2 [file join $root tests cffi write-inject.c] -o $inject
        puts "2. partial-write completion: print 4 KiB, every write on descriptor 1 capped at L bytes (ns per print)"
        puts [format "  %-16s %10s %10s %10s" "" loop "+ call" call]
        foreach limit {0 2048 1024 512} {
            set injected [list DYLD_INSERT_LIBRARIES $inject BCF_WRITE_FD 1 BCF_WRITE_LIMIT $limit]
            set label [expr {$limit == 0 ? "no cap (1 write)" : "L $limit ([expr {4096 / $limit}] writes)"}]
            puts [format "  %-16s %s" $label [perCall $text4k "std::io::print(text)$handled" 1 $injected]]
        }
    } else {
        puts "2. partial-write completion: macOS only (libSystem's write is interposable; Linux's syscalls are not)"
    }
    puts ""

    set hello [file join $root examples io [expr {$platform eq "darwin" ? "hello-darwin.bot" : "hello.bot"}]]
    set front {}
    set build {}
    set exe [file join $scratch hello]
    set quiet [file join $scratch quiet]
    set quietHir [surface::compile "x = 40\nx + 2\n" -warnings off]
    for {set r 0} {$r < $runs} {incr r} {
        lappend front [expr {[lindex [time {set hir [surface::readProgramFile $hello -warnings off -cache ""]}] 0] / 1000.0}]
        lappend build [expr {[lindex [time {set exe [native::executable $hir [file join $scratch hello]]}] 0] / 1000.0}]
    }
    set quiet [native::executable $quietHir $quiet]
    foreach {label path} [list hello $exe "no IO" $quiet] {
        set wall {}
        for {set p 0} {$p < $processes} {incr p} {
            lappend wall [expr {[lindex [time {exec $path >/dev/null 2>/dev/null}] 0] / 1000.0}]
        }
        set process($label) [tcl::mathfunc::min {*}$wall]
    }
    puts "3. build and process, ms (best of $runs builds, $processes processes):"
    puts [format "  front end %8.1f   native::executable %8.1f   process: hello %6.2f, no IO %6.2f" \
        [tcl::mathfunc::min {*}$front] [tcl::mathfunc::min {*}$build] $process(hello) $process(no\ IO)]
} finally {
    file delete -force $scratch
}
