# tagged-pointers.tcl -- what a C pointer and a byte exposure cost natively,
# before and after RN-ANDROID-TAGGED-POINTER-CORRECTNESS-MILESTONE-1.md
# (C address words of the target's encoding; byte exposures made by the C
# call itself, a machine word of the full width).
#
#   tclsh9.0 bench/tagged-pointers.tcl ?-root DIR? ?-runs N? ?-n N? ?-sizes LIST?
#
# -root DIR measures another checkout's compiler and native backend (its
# own native/target/release, built): run it once with -root at the commit
# before the change and once without, on the same quiet machine, and
# compare. The programs are the same text in both.
#
# 1. ns per iteration (best of RUNS runs of N iterations, cranelift,
#    specialized; the program a linked executable): each fold with the
#    trivial body `acc + 1`, with the operation, and their difference
#    (bench/c-ffi.tcl's method, over a fold that allocates nothing):
#
#      ptr result    bcf_address(): a C pointer result made a C address word
#                    (the fits check, the encode)
#      ptr argument  bcf_is_null(p): a C address word decoded for C
#      ptr echo      bcf_echo_ptr(p): decoded, then the result encoded
#      ptr same      bcf_same(p, q): two decodes
#      null?         std::ffi::c::null?(p): no C call, the word compared
#      handle        bcf_is_null(h.p): a pointer an installed context owns
#                    (an opaque resource handle, as Icy Tower's SDL session
#                    holds its window), observed and decoded on every use
#      read S        bcf_sum(data, 0) of an S-byte Bytes: one read exposure
#      write S       bcf_fill(m, 0, 0) of an S-byte MutableBytes: one write
#                    exposure (its private copy)
#      text 64       bcf_sum(data, 64) of a 64-byte Bytes made from a String:
#                    the exposure and C reading every byte
#      control       no C at all: an Int loop (mod, add) -- the value
#                    representation of everything that is not a pointer
#
# 2. Code: the CLIF of each pointer program (crc32 and bytes, compared by
#    eye or by the report between two runs: the default encoding's is
#    expected byte-identical where no exposure is made) and the size of a
#    linked executable of the `handle` program.

set options [dict create -root "" -runs 5 -n 200000 -sizes {64 65536}]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}
set argv {}
set root [dict get $options -root]
if {$root eq ""} {
    set root [file dirname [file dirname [file normalize [info script]]]]
}
set root [file normalize $root]
set runs [dict get $options -runs]
set n [dict get $options -n]
set sizes [dict get $options -sizes]
set ::env(BOTLISH_NATIVE_BIN) [file join $root native target release botlish-native]
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]

set scratch [file tempdir botlish-bench-tagged-]
ctool::staticLibrary $scratch botlish_cffi_fixture [file join $root tests cffi fixture.c] \
    {*}[expr {$::tcl_platform(platform) eq "windows" ? [list [file join $root tests cffi fixture-win64.asm]] : {}}]
set linkDirs [list $scratch]

proc writeFile {path text} {
    set channel [open $path w]
    fconfigure $channel -encoding utf-8 -translation lf
    puts -nonewline $channel $text
    close $channel
}

writeFile [file join $scratch bcf.bot] {import std::ffi::c

extern c library "botlish_cffi_fixture"

extern c fn address named "bcf_address"() -> std::ffi::c::Ptr[std::ffi::c::Void] independent
extern c fn is_null named "bcf_is_null"(p: std::ffi::c::Ptr[std::ffi::c::Void] noescape) -> std::ffi::c::Int
extern c fn echo_ptr named "bcf_echo_ptr"(p: std::ffi::c::Ptr[std::ffi::c::Void] noescape) -> std::ffi::c::Ptr[std::ffi::c::Void] alias p
extern c fn same named "bcf_same"(a: std::ffi::c::Ptr[std::ffi::c::Void] noescape, b: std::ffi::c::Ptr[std::ffi::c::Void] noescape) -> std::ffi::c::Int
extern c fn sum named "bcf_sum"(data: std::ffi::c::Ptr[std::ffi::c::UChar] read noescape, count: std::ffi::c::ULong) -> std::ffi::c::ULong
extern c fn fill named "bcf_fill"(out: std::ffi::c::Ptr[std::ffi::c::UChar] write noescape, count: std::ffi::c::ULong, seed: std::ffi::c::UChar) -> unit
}

set prelude "import std::abi\nimport std::abi::bytes\nimport std::byte\nimport std::ffi::c\nimport std::list\nimport std::str\nimport bcf\n
opaque context struct Handle:
    p: std::ffi::c::Ptr\[std::ffi::c::Void\]

fn handle() -> Handle:
    Handle {p: bcf::address()}

fn pattern(n: int):
    loop i from 0 to n:
        std::byte::from_int(mod(i, 256))

"
set programs 0

proc compileApp {text} {
    set path [file join $::scratch main-[incr ::programs].bot]
    writeFile $path $text
    return [surface::readProgramFile $path -warnings off -cache ""]
}

# The program of SETUP and a fold of N iterations whose body is BODY: a
# fold, so that the loop itself allocates nothing (a collecting loop's List
# would be most of what is measured).
proc program {setup body n} {
    return "$::prelude\nfn f(context h: Handle) -> int:\n    $setup\n    fold i from 0 to $n with intermediate acc 0:\n        $body\n\nwith context handle()\nf()\n"
}

proc best {text} {
    set hir [compileApp $text]
    native::withLinkDirs $::linkDirs {
        lassign [native::measure $hir $::runs] lower compile best
    }
    return $best
}

proc perCall {setup call} {
    set baseline [expr {1000.0 * [best [program $setup {acc + 1} $::n]] / $::n}]
    set t [expr {1000.0 * [best [program $setup $call $::n]] / $::n}]
    return [format "%10.2f %10.2f %10.2f" $baseline $t [expr {$t - $baseline}]]
}

set pointer {p = bcf::address()
    q = bcf::address()}
set cases [list \
    "ptr result" $pointer "r = bcf::address()\n        acc + 1" \
    "ptr argument" $pointer {acc + bcf::is_null(p)} \
    "ptr echo" $pointer "e = bcf::echo_ptr(p)\n        acc + 1" \
    "ptr same" $pointer {acc + bcf::same(p, q)} \
    "null?" $pointer "if std::ffi::c::null?(p):\n            acc\n        else:\n            acc + 1" \
    "handle" $pointer {acc + bcf::is_null(h.p)}]
foreach s $sizes {
    lappend cases "read $s" "data = std::abi::bytes::from_list(pattern($s))" {acc + bcf::sum(data, 0)}
}
foreach s $sizes {
    lappend cases "write $s" "m = std::abi::bytes::from_bytes(std::abi::bytes::from_list(pattern($s)))" "bcf::fill(m, 0, 0)\n        acc + 1"
}
lappend cases "text 64" "data = std::abi::bytes::from_list(std::str::encode_utf8(\"[string repeat abcdefgh 8]\"))" {acc + bcf::sum(data, 64)}
lappend cases control {k = 7} {acc + mod(i * k + 3, 1000003)}

try {
    puts "root: $root ([string trim [exec git -C $root log -1 --format=%h]]), driver [lindex [split [exec $::env(BOTLISH_NATIVE_BIN) runtime-abi] \n] 0]"
    puts "1. ns per iteration (best of $runs runs of $n iterations): the loop without the operation, with it, the difference"
    puts [format "  %-14s %10s %10s %10s" "" loop "+ op" op]
    foreach {label setup call} $cases {
        puts [format "  %-14s %s" $label [perCall $setup $call]]
    }
    puts ""
    puts "2. code: CLIF (crc32 bytes) of each operation's program, and a linked executable"
    foreach {label setup call} $cases {
        set hir [compileApp [program $setup $call 10]]
        set clif [native::clif $hir]
        puts [format "  %-14s %08x %8d" $label [zlib crc32 $clif] [string length $clif]]
    }
    set hir [compileApp [program $pointer {acc + bcf::is_null(h.p)} 10]]
    set exe [file join $scratch handle-exe]
    native::withLinkDirs $linkDirs {
        native::executable $hir $exe
    }
    puts [format "  %-14s %8d bytes (executable of the handle program)" executable [file size $exe]]
} finally {
    file delete -force $scratch
}
