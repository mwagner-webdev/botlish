# c-ffi.tcl -- what a C call costs natively (C-FFI.md, "Performance").
#
#   tclsh9.0 bench/c-ffi.tcl ?-runs N? ?-n N? ?-sizes LIST? ?-sha-sizes LIST?
#
# 1. Per call, ns: programs that each make N calls of the C FFI test fixture
#    (tests/cffi/fixture.c, compiled here with the host C compiler into a
#    private static archive) in a loop, reported per iteration beside the
#    same loop without the call, and their difference
#    (bench/c-pointer-borrowing.tcl's method; a call cheaper than the loop's
#    noise shows as a difference of a few ns either way):
#
#      count     bcf_count(): no argument, an unsigned long result (C
#                increments a static) -- the call itself
#      add       bcf_add(i, 1): two int arguments, an int result
#      big       bcf_echo_ulonglong(2^64 - 1): a 64-bit argument and result
#                beyond the small Int range (rt_ffi_int_word, rt_ffi_box_u64)
#      stack 12  bcf_stack_tail(...): twelve arguments, the last four on the
#                stack on AArch64 (six on x86-64), a long long result
#      stack 20  bcf_pick(19, ...): twenty narrow and wide arguments, twelve
#                on the stack on AArch64 (fourteen on x86-64; sixteen on
#                Win64), its long a 32-bit one under LLP64 (Windows)
#      read S    bcf_sum(data, 0) of an S-byte Bytes: one read exposure
#                (bytesaddr, keepalive), C touching no byte -- expected flat
#                in S (the storage is never copied)
#      write S   bcf_fill(m, 0, 0) of an S-byte MutableBytes, the write-back
#                discarded: one write exposure, whose detach copies S bytes
#                -- expected linear in S
#      va 2      bcf_vsum(2, a, b): a variadic call of two trailing ints
#                (VARIADICS-VERTICAL-SLICE-1.md), beside `add` -- on x86-64
#                System V through the %al stub, on Apple AArch64 on the
#                stack, on Win64 directly (no floating-point argument: no
#                stub)
#      va 11     bcf_vsum(11, ...): eleven trailing ints, the later ones on
#                the stack everywhere, beside `stack 12`
#      va 4.0    bcf_vscale(1.0, 4, ...): four trailing doubles after a
#                fixed double (%al = 5 on x86-64; on Win64 the doubles of the
#                first, third and fourth positions copied into rcx, r8 and r9
#                by its stub, WINDOWS-X86-64-MILESTONE-6.md)
#      va 1.0    bcf_vrecord1(7, 0.5): one trailing double, at the second
#                position (%al = 1; Win64's stub copies xmm1 into rdx)
#      va mixed  bcf_vrecord1(K, 0.5, a, 1.5, a, 2.5, a, 3.5): doubles and
#                ints alternating, past every Win64 register (the stub copies
#                xmm1 and xmm3)
#
# 2. SHA-256 through the package-owned static BoringSSL
#    (tests/cffi/boringssl.tcl; skipped when it is not built): sha256::digest
#    (examples/ffi/sha256/) of an S-byte input for each S in SHA-SIZES, per
#    call and as MB/s -- one read exposure of the input (no copy) and one
#    32-byte write exposure per digest.
#
# 3. Compile and link, ms (best of RUNS): native::evalHir of a program that
#    calls no C and of the same program calling one C function (front end
#    excluded: lowering, Cranelift and, for the C program, the system link
#    of a temporary executable and its run), and native::executable of
#    both (rustc linking the standalone executable; the C program also
#    links its library).
#
# Every per-call number is best of RUNS executions (cranelift, specialized),
# compilation and linking excluded: a program that calls C runs as a linked
# executable, its symbols resolved once by the system linker, so the loop
# makes direct calls with no lookup.

set root [file dirname [file dirname [file normalize [info script]]]]
set args $argv
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
source [file join $root tests cffi boringssl.tcl]

set runs 5
set n 100000
set sizes {64 65536 1048576}
# bcf_pick's long argument: the 64-bit value c-ffi.test passes, or its
# 32-bit one where long is 32 bits (LLP64: Windows).
set pickLong [expr {$::tcl_platform(platform) eq "windows" ? -1985229329 : -81985529216486895}]
set shaSizes {64 1024 65536 1048576}
foreach {option value} $args {
    switch -- $option {
        -runs { set runs $value }
        -n { set n $value }
        -sizes { set sizes $value }
        -sha-sizes { set shaSizes $value }
        default { error "unknown option $option" }
    }
}

set scratch [file tempdir botlish-bench-cffi-]
# The fixture, built as c-ffi.test builds it: the host's own C toolchain
# (tests/ctoolchain.tcl: cc and ar, or MSVC's cl, ml64 and lib on Windows,
# with fixture-win64.asm's assembly).
ctool::staticLibrary $scratch botlish_cffi_fixture [file join $root tests cffi fixture.c] \
    {*}[expr {$::tcl_platform(platform) eq "windows" ? [list [file join $root tests cffi fixture-win64.asm]] : {}}]
set boringssl [cffi::boringsslDir]
set linkDirs [concat [list $scratch] [expr {$boringssl eq "" ? {} : [list $boringssl]}]]

proc writeFile {path text} {
    set channel [open $path w]
    fconfigure $channel -encoding utf-8 -translation lf
    puts -nonewline $channel $text
    close $channel
}

# The fixture binding: what the benchmark calls of it.
writeFile [file join $scratch bcf.bot] {import std::ffi::c

extern c library "botlish_cffi_fixture"

extern c fn count named "bcf_count"() -> std::ffi::c::ULong
extern c fn add named "bcf_add"(a: std::ffi::c::Int, b: std::ffi::c::Int) -> std::ffi::c::Int
extern c fn echo_ulonglong named "bcf_echo_ulonglong"(x: std::ffi::c::ULongLong) -> std::ffi::c::ULongLong
extern c fn stack_tail named "bcf_stack_tail"(a: std::ffi::c::Long, b: std::ffi::c::Long, c: std::ffi::c::Long, d: std::ffi::c::Long, e: std::ffi::c::Long, f: std::ffi::c::Long, g: std::ffi::c::Long, h: std::ffi::c::Long, i: std::ffi::c::Long, j: std::ffi::c::Int, k: std::ffi::c::Short, l: std::ffi::c::SChar) -> std::ffi::c::LongLong
extern c fn pick named "bcf_pick"(which: std::ffi::c::Int, a1: std::ffi::c::SChar, a2: std::ffi::c::UChar, a3: std::ffi::c::Short, a4: std::ffi::c::UShort, a5: std::ffi::c::Int, a6: std::ffi::c::UInt, a7: std::ffi::c::Char, s8: std::ffi::c::SChar, s9: std::ffi::c::UChar, s10: std::ffi::c::Short, s11: std::ffi::c::SChar, s12: std::ffi::c::UShort, s13: std::ffi::c::Int, s14: std::ffi::c::SChar, s15: std::ffi::c::Long, s16: std::ffi::c::UChar, s17: std::ffi::c::Short, s18: std::ffi::c::UInt, s19: std::ffi::c::SChar) -> std::ffi::c::LongLong
extern c fn sum named "bcf_sum"(data: std::ffi::c::Ptr[std::ffi::c::UChar] read noescape, count: std::ffi::c::ULong) -> std::ffi::c::ULong
extern c fn fill named "bcf_fill"(out: std::ffi::c::Ptr[std::ffi::c::UChar] write noescape, count: std::ffi::c::ULong, seed: std::ffi::c::UChar) -> unit
extern c fn vsum named "bcf_vsum"(count: std::ffi::c::Int, variadic) -> std::ffi::c::LongLong
extern c fn vscale named "bcf_vscale"(factor: std::ffi::c::Double, count: std::ffi::c::Int, variadic) -> std::ffi::c::Double
extern c fn vrecord1 named "bcf_vrecord1"(kinds: std::ffi::c::ULongLong, variadic) -> std::ffi::c::Int

fn c_int(n: std::ffi::c::Int) -> std::ffi::c::Int:
    n
}
foreach file {boringssl.bot sha256.bot} {
    file copy -force [file join $root examples ffi sha256 $file] [file join $scratch $file]
}

set prelude "import std::abi\nimport std::abi::bytes\nimport std::byte\nimport std::ffi::c\nimport std::list\nimport bcf\n
fn pattern(n: int):
    loop i from 0 to n:
        std::byte::from_int(mod(i, 256))

"

# The HIR of the entry program TEXT, an application of the scratch
# directory.
proc compileApp {text} {
    set path [file join $::scratch main-[incr ::programs].bot]
    writeFile $path $text
    return [surface::readProgramFile $path -warnings off -cache ""]
}
set programs 0

# The program of SETUP and a loop of N iterations whose body is BODY (or
# BODY then 0, when DISCARDED).
proc program {setup body discarded n} {
    set inner [expr {$discarded ? "$body\n        0" : $body}]
    return "$::prelude\nfn f() -> int:\n    $setup\n    xs = loop i from 0 to $n:\n        $inner\n    std::list::length(xs)\n\nf()\n"
}

# The best time (microseconds) of the program TEXT.
proc best {text} {
    set hir [compileApp $text]
    native::withLinkDirs $::linkDirs {
        lassign [native::measure $hir $::runs] lower compile best
    }
    return $best
}

# "LOOP CALL DIFFERENCE": ns per iteration of the loop without and with
# the call, and their difference (within the loop's noise, a few ns either
# way, when the call costs less than that).
proc perCall {setup call discarded} {
    set baseline [expr {1000.0 * [best [program $setup 0 0 $::n]] / $::n}]
    set t [expr {1000.0 * [best [program $setup $call $discarded $::n]] / $::n}]
    return [format "%10.1f %10.1f %10.1f" $baseline $t [expr {$t - $baseline}]]
}

try {
    puts "1. ns per iteration (best of $runs runs of $n iterations): the loop without the call, with it, the difference"
    puts [format "  %-14s %10s %10s %10s" "" loop "+ call" call]
    puts [format "  %-14s %s" count [perCall {x = 0} {bcf::count()} 0]]
    puts [format "  %-14s %s" add [perCall {x = 0} {bcf::add(i, 1)} 0]]
    puts [format "  %-14s %s" big [perCall {x = 0} {bcf::echo_ulonglong(18446744073709551615)} 0]]
    puts [format "  %-14s %s" "stack 12" [perCall {x = 0} {bcf::stack_tail(1, 2, 3, 4, 5, 6, 7, 8, 9, -10, -11, -12)} 0]]
    puts [format "  %-14s %s" "stack 20" [perCall {x = 0} "bcf::pick(19, -2, 253, -1234, 65244, -123456789, 4275878552, 1, -4, 247, -30000, -128, 48879, -2000000000, 127, $pickLong, 128, -2, 2147483649, -1)" 0]]
    foreach s $sizes {
        puts [format "  %-14s %s" "read $s" [perCall "data = std::abi::bytes::from_list(pattern($s))" {bcf::sum(data, 0)} 0]]
    }
    foreach s $sizes {
        puts [format "  %-14s %s" "write $s" [perCall "m = std::abi::bytes::from_bytes(std::abi::bytes::from_list(pattern($s)))" {bcf::fill(m, 0, 0)} 1]]
    }
    puts [format "  %-14s %s" "va 2" [perCall {a = bcf::c_int(1)} {bcf::vsum(2, a, a)} 0]]
    puts [format "  %-14s %s" "va 11" [perCall {a = bcf::c_int(1)} {bcf::vsum(11, a, a, a, a, a, a, a, a, a, a, a)} 0]]
    puts [format "  %-14s %s" "va 4.0" [perCall {x = 0} "y = bcf::vscale(1.0, 4, 0.5, 1.5, 2.5, 3.5):\n            on NonFiniteFloat:\n                0.0" 1]]
    puts [format "  %-14s %s" "va 1.0" [perCall {x = 0} {bcf::vrecord1(7, 0.5)} 0]]
    puts [format "  %-14s %s" "va mixed" [perCall {a = bcf::c_int(1)} {bcf::vrecord1(118953751, 0.5, a, 1.5, a, 2.5, a, 3.5)} 0]]
    puts ""
    if {$boringssl eq ""} {
        puts "2. SHA-256: skipped (the package-owned BoringSSL is not built: tclsh9.0 tests/cffi/boringssl.tcl)"
    } else {
        puts "2. SHA-256 (BoringSSL, static), per digest (best of $runs runs):"
        foreach s $shaSizes {
            set count [expr {max(4, min($n, 67108864 / max($s, 1)))}]
            set setup "data = std::abi::bytes::from_list(pattern($s))"
            set baseline [best "import sha256\n[program $setup 0 0 $count]"]
            set t [best "import sha256\n[program $setup {sha256::digest(data)} 1 $count]"]
            set us [expr {($t - $baseline) / $count}]
            puts [format "  %-10s %10.2f us  %8.1f MB/s  (%d digests)" "$s B" $us [expr {$us > 0 ? $s / $us : 0}] $count]
        }
    }
    puts ""
    puts "3. compile and link, ms (best of $runs):"
    set plain [compileApp "x = 40\nx + 2\n"]
    set calling [compileApp "import std::ffi::c\nimport bcf\n\nbcf::add(40, 2)\n"]
    foreach {label hir} [list "no C" $plain "calls C" $calling] {
        set run {}
        set exe {}
        for {set r 0} {$r < $runs} {incr r} {
            native::withLinkDirs $linkDirs {
                lappend run [expr {[lindex [time {native::evalHir $hir}] 0] / 1000.0}]
                set path [file join $scratch exe-$r]
                lappend exe [expr {[lindex [time {native::executable $hir $path}] 0] / 1000.0}]
            }
        }
        puts [format "  %-8s native::evalHir %8.1f   native::executable %8.1f" $label \
            [tcl::mathfunc::min {*}$run] [tcl::mathfunc::min {*}$exe]]
    }
} finally {
    file delete -force $scratch
}
