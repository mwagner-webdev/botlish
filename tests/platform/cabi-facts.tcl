# cabi-facts.tcl -- checks core/cabi.tcl's row for the host target against
# the host C compiler (C-ABI-TYPES.md; MACOS-AARCH64-PORT-AUDIT.md).
#
#   tclsh9.0 tests/platform/cabi-facts.tcl ?-cc COMPILER?
#
# Compiles and runs tests/platform/cabi-facts.c with COMPILER (default $CC,
# else cc) in a private temporary directory, and compares what it prints --
# the bit widths of char, short, int, long, long long and a pointer, whether
# plain char is signed, and each std::ffi::c scalar's width and signedness
# (core::cabi::scalarInfo), size_t's width with the pointer's (size_t is no
# std::ffi::c scalar) -- with core::cabi::target of core::cabi::hostTarget, the
# row a compilation for this host uses when it imports std::ffi::c. It also
# checks that the compiler's own target (COMPILER -dumpmachine: arm64-apple-
# darwin24.6.0 on a Mac) is the host target's operating system and
# architecture -- and on Windows its environment: windows-x86_64 is MSVC's
# (clang's x86_64-pc-windows-msvc; MinGW's gcc would check another row) --:
# the host default is the toolchain's host, not an architecture's other
# system. On Windows COMPILER is clang (CC=clang: cl has no -dumpmachine). Prints both and exits 1 on any difference, or
# when the host is not one of the table's targets. It reads the table; it
# changes nothing. Never an oracle of another target: it runs on, and
# checks, its own host's row only.

set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname $here]]
source [file join $root core core.tcl]

set cc [expr {[info exists ::env(CC)] && $::env(CC) ne "" ? $::env(CC) : "cc"}]
foreach {option value} $argv {
    switch -- $option {
        -cc { set cc $value }
        default {
            puts stderr "usage: tclsh9.0 tests/platform/cabi-facts.tcl ?-cc COMPILER?"
            exit 2
        }
    }
}

set host [core::cabi::hostTarget]
if {$host eq ""} {
    puts "FAIL: this host ($::tcl_platform(os) $::tcl_platform(machine)) is none of core::cabi's targets: [join [core::cabi::targetNames] {, }]"
    exit 1
}
set table [core::cabi::target $host]

set work [file tempdir botlish-cabi-facts]
try {
    set program [file join $work cabi-facts[expr {$::tcl_platform(platform) eq "windows" ? ".exe" : ""}]]
    exec $cc -o $program [file join $here cabi-facts.c] 2>@ stderr
    set measured [exec $program]
} finally {
    file delete -force $work
}

# The C compiler's own target, as {OS ARCH} of the table's names ("" for a
# part it does not name).
set machine [string tolower [exec $cc -dumpmachine]]
set machineArch [lindex [split $machine -] 0]
set machineArch [expr {$machineArch in {arm64 aarch64} ? "aarch64" : $machineArch in {x86_64 amd64} ? "x86_64" : ""}]
set machineOs [expr {[string match *darwin* $machine] || [string match *apple* $machine] ? "macos"
    : [string match *linux* $machine] ? "linux" : [string match *mingw* $machine] || [string match *windows* $machine] ? "windows" : ""}]

set scalars [dict create]
foreach name [core::cabi::scalarNames] {
    set info [core::cabi::scalarInfo $name $host]
    dict set scalars $name [list [dict get $info bits] [dict get $info signed]]
}

puts "host target:   $host ($::tcl_platform(os) $::tcl_platform(machine)), triple [dict get $table triple]"
puts "C compiler:    $cc, target $machine"
puts "core::cabi:    [dict filter $table key char short int long longlong pointer charSigned] scalars [list $scalars]"
puts "C toolchain:   $measured"
set differences {}
dict for {key value} $measured {
    switch -- $key {
        sizeT {
            if {$value != [dict get $table pointer]} {
                lappend differences "size_t: C $value bits, the table's pointer [dict get $table pointer]"
            }
        }
        sizeTSigned {
            if {$value != 0} { lappend differences "size_t: C signed" }
        }
        scalars {
            dict for {name facts} $value {
                if {![dict exists $scalars $name] || [dict get $scalars $name] ne $facts} {
                    lappend differences "std::ffi::c::$name: table {bits signed} [expr {[dict exists $scalars $name] ? [dict get $scalars $name] : {(none)}}], C $facts"
                }
            }
        }
        default {
            if {![dict exists $table $key] || [dict get $table $key] ne $value} {
                lappend differences "$key: table [expr {[dict exists $table $key] ? [dict get $table $key] : {(none)}}], C $value"
            }
        }
    }
}
if {$machineOs ne [dict get $table os] || $machineArch ne [dict get $table arch]} {
    lappend differences "target: the C compiler's is $machine ($machineOs $machineArch), the host default $host ([dict get $table os] [dict get $table arch])"
} elseif {$machineOs eq "windows"} {
    # The C toolchain's ABI family: the triple's environment.
    set machineEnv [expr {[string match *msvc* $machine] ? "msvc" : [string match *mingw* $machine] || [string match *gnu* $machine] ? "gnu" : ""}]
    set tableEnv [lindex [split [dict get $table triple] -] end]
    if {$machineEnv ne $tableEnv} {
        lappend differences "target: the C compiler's is $machine (environment [expr {$machineEnv eq "" ? "unknown" : $machineEnv}]), the host default $host's is $tableEnv"
    }
}
if {$differences ne ""} {
    puts "FAIL: core::cabi's $host row disagrees with the C toolchain: [join $differences {; }]"
    exit 1
}
puts "ok: core::cabi's $host row agrees with the C toolchain"
