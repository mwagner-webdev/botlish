# rustlink.tcl -- the harness of HTTP-MACOS-RUST-ARCHIVE-LINK-FEASIBILITY-
# MILESTONE-1.md: builds the Rust fixture (audit/rust-archive-link/unit) in
# its variants, localizes it (tools/rust-unit.tcl), builds the C provider,
# assembles applications of the fixture's package as the package manager's
# installation lays them out (.bot_modules/rustlink, the archives at the
# paths the module declares), links the consumer programs with a Botlish
# linker and runs them. Sourced by tests/rust-archive-link.test and
# audit/rust-archive-link/tools/experiments.tcl; it runs on Linux (x86-64,
# AArch64) and on macOS (AArch64), the host's own target only.
#
#   rustlink::target                    the host's target (linux-x86_64, ...)
#   rustlink::format                    its object format (elf, macho)
#   rustlink::unit ?-notify weakdef|weakref|FILE? ?-toolchain T? ?-dir D?
#                                       the raw static library cargo built
#   rustlink::localized RAW ?-keep G? ?-require N? ?-out FILE?
#                                       the localized archive (rust-unit.tcl)
#   rustlink::exports                   the unit's C ABI (rl_*)
#   rustlink::surface NOTIFY            what the localized unit defines
#                                       globally: the C ABI, and with
#                                       weakdef the weak fallback
#   rustlink::provider ?-out FILE?      the provider's archive
#   rustlink::app DIR UNIT ?PROVIDER?   an application of the packages
#                                       rustlink and (unless PROVIDER is "")
#                                       rustlink_provider
#   rustlink::link APP PROGRAM ?-linker L?  {ok 1 exe PATH output TEXT} | {ok 0 error TEXT}
#   rustlink::run EXE                   {status N value {STR...} raw TEXT}
#   rustlink::copies EXE NAME           {global N local M}: definitions of NAME
#   rustlink::expected PROGRAM          the value a right run gives (its
#                                       toolchain line aside)
#
# Everything is built under Botlish's cache ($BOTLISH_CACHE_DIR,
# $XDG_CACHE_HOME/botlish or ~/.cache/botlish), in rust-archive-link/, never
# in the repository.
namespace eval rustlink {
    variable here [file dirname [file normalize [info script]]]
    variable fixture [file dirname $here]
    variable root [file dirname [file dirname $fixture]]
    variable exports {rl_close rl_digest rl_each rl_fail rl_notify rl_open rl_put rl_stats rl_text_free rl_text_new rl_toolchain rl_version}
}
source [file join $rustlink::root tools rust-unit.tcl]

proc rustlink::Fail {message} {
    return -code error -errorcode {RUSTLINK} "rustlink: $message"
}

proc rustlink::CacheDir {} {
    foreach {var sub} {BOTLISH_CACHE_DIR {} XDG_CACHE_HOME botlish} {
        if {[info exists ::env($var)] && $::env($var) ne ""} {
            return [file normalize [file join $::env($var) {*}$sub rust-archive-link]]
        }
    }
    return [file normalize [file join [file home] .cache botlish rust-archive-link]]
}

proc rustlink::target {} {
    set machine $::tcl_platform(machine)
    set arch [switch -- $machine {
        x86_64 - amd64 { string cat x86_64 }
        aarch64 - arm64 { string cat aarch64 }
        default { Fail "no target for machine $machine" }
    }]
    switch -- $::tcl_platform(os) {
        Linux { return linux-$arch }
        Darwin { return macos-$arch }
    }
    Fail "no target for $::tcl_platform(os)"
}

proc rustlink::format {} {
    return [expr {[string match macos-* [target]] ? "macho" : "elf"}]
}

proc rustlink::exports {} {
    variable exports
    return $exports
}

# The unit's global definitions once localized with NOTIFY's object:
# weakdef's fallback definition of botlish_event_post2 stays global (the
# final link must be able to override it); weakref's reference is no
# definition.
proc rustlink::surface {notify} {
    if {$notify eq "weakdef"} {
        return [lsort [list {*}[exports] botlish_event_post2]]
    }
    return [exports]
}

# Run SCRIPT in the caller's frame with the environment variables of VARS
# set, then put back exactly those variables.
proc rustlink::WithEnv {vars script} {
    set saved {}
    dict for {k v} $vars {
        dict set saved $k [expr {[info exists ::env($k)] ? [list 1 $::env($k)] : [list 0 {}]}]
        set ::env($k) $v
    }
    try {
        uplevel 1 $script
    } finally {
        dict for {k state} $saved {
            lassign $state had value
            if {$had} { set ::env($k) $value } else { unset -nocomplain ::env($k) }
        }
    }
}

proc rustlink::Options {defaults argv} {
    set opts $defaults
    foreach {k v} $argv {
        if {![dict exists $defaults $k]} {
            Fail "unknown option $k (known: [join [dict keys $defaults] {, }])"
        }
        dict set opts $k $v
    }
    return $opts
}

# The raw static library of the fixture built by cargo --locked (TOOLCHAIN:
# a rustup toolchain, "" for cargo's default) with the notification object
# NOTIFY: weakdef (unit/notify-weakdef.c: a weak definition, the default --
# the mechanism that links with or without a provider on ELF and on Mach-O),
# weakref (packages/http/native/src/notify.c, http's weak reference) or a
# file. DIR: the cargo target directory (each
# variant its own by default; a fresh one for a reproducibility build).
# Paths are mapped out of the objects (the crate, the cargo home, the target
# directory, the checkout), as tools/http-package.tcl does for botlish_http.
proc rustlink::unit {args} {
    variable fixture
    variable root
    set opts [Options [dict create -notify weakdef -toolchain "" -dir ""] $args]
    set notify [dict get $opts -notify]
    switch -- $notify {
        weakref { set file [file join $root packages http native src notify.c] }
        weakdef { set file [file join $fixture unit notify-weakdef.c] }
        default { set file [file normalize $notify]; set notify custom-[file rootname [file tail $file]] }
    }
    set toolchain [dict get $opts -toolchain]
    set dir [dict get $opts -dir]
    if {$dir eq ""} {
        set dir [file join [CacheDir] cargo [target]-$notify-[expr {$toolchain eq "" ? "default" : $toolchain}]]
    }
    set dir [file normalize $dir]
    set crate [file join $fixture unit]
    set home [expr {[info exists ::env(CARGO_HOME)] && $::env(CARGO_HOME) ne "" ? $::env(CARGO_HOME) : [file join [file home] .cargo]}]
    set remap [list --remap-path-prefix=$crate=/botlish_rustlink --remap-path-prefix=$home=/cargo \
        --remap-path-prefix=$dir=/target --remap-path-prefix=[file normalize $root]=/botlish]
    set cmd [list cargo]
    if {$toolchain ne ""} {
        lappend cmd +$toolchain
    }
    lappend cmd build --release --locked --manifest-path [file join $crate Cargo.toml]
    set env [dict create CARGO_TARGET_DIR $dir RUSTFLAGS [join $remap " "] RUSTLINK_NOTIFY $file \
        SOURCE_DATE_EPOCH 0 CARGO_INCREMENTAL 0 ZERO_AR_DATE 1]
    WithEnv $env {
        if {[catch {exec {*}$cmd 2>@1} out]} {
            Fail "cargo failed: [join $cmd]\n$out"
        }
    }
    return [file join $dir release libbotlish_rustlink.a]
}

# RAW localized into OUT (default: beside RAW, librustlink.a); KEEP the
# global definitions kept (the C ABI and, where the unit defines it, the
# weak fallback botlish_event_post2, by default), REQUIRE those that must
# be.
proc rustlink::localized {raw args} {
    set opts [Options [dict create -keep {rl_* botlish_event_post2} -require [exports] -out ""] $args]
    set out [dict get $opts -out]
    if {$out eq ""} {
        set out [file join [file dirname $raw] localized librustlink.a]
    }
    rustunit::localize $raw $out -format [format] -keep [dict get $opts -keep] \
        -require [dict get $opts -require] -label botlish_rustlink -arch arm64
    return $out
}

# The provider's archive (provider/provider.c): one object, archived
# deterministically.
proc rustlink::provider {args} {
    variable fixture
    set opts [Options [dict create -out ""] $args]
    set out [dict get $opts -out]
    if {$out eq ""} {
        set out [file join [CacheDir] provider-[target] librustlink_provider.a]
    }
    set out [file normalize $out]
    file mkdir [file dirname $out]
    set object [file join [file dirname $out] rustlink_provider.o]
    set src [file join $fixture provider]
    set flags [list -O2 -fPIC -Wall -Wextra -Werror -ffile-prefix-map=$src=/provider]
    if {[format] eq "macho"} {
        lappend flags -mmacosx-version-min=11.0
    }
    exec cc {*}$flags -c [file join $src provider.c] -o $object
    file delete -force $out
    if {[format] eq "macho"} {
        WithEnv {ZERO_AR_DATE 1} {
            exec libtool -static -D -no_warning_for_no_symbols -o $out $object 2>@stderr
        }
    } else {
        exec ar rcsD $out $object
    }
    file delete $object
    return $out
}

# An application in DIR: the consumer programs at its root, the package
# rustlink at .bot_modules/rustlink with its unit archive UNIT and, unless
# PROVIDER is "", the package rustlink_provider with the provider's archive
# PROVIDER, each archive at the path its module declares (as the package
# manager's installation lays them out).
proc rustlink::app {dir unit {provider ""}} {
    variable fixture
    file delete -force $dir
    set pkg [file join $dir .bot_modules rustlink]
    file mkdir [file join $pkg native]
    foreach f [glob -directory [file join $fixture consumer] *.bot] {
        file copy $f $dir
    }
    file copy [file join $fixture package rustlink.bot] $pkg
    file copy $unit [file join $pkg native librustlink.a]
    if {$provider ne ""} {
        set prov [file join $dir .bot_modules rustlink_provider]
        file mkdir [file join $prov native]
        file copy [file join $fixture provider package rustlink_provider.bot] $prov
        file copy $provider [file join $prov native librustlink_provider.a]
    }
    return [file normalize $dir]
}

# Link PROGRAM (a .bot file of APP) into an executable with LINKER (rustc,
# system): {ok 1 exe PATH} or {ok 0 error TEXT}.
proc rustlink::link {app program args} {
    variable root
    set opts [Options [dict create -linker rustc] $args]
    set exe [file join $app [file rootname $program]]
    file delete -force $exe
    set here [pwd]
    cd $app
    try {
        WithEnv [dict create BOTLISH_NATIVE_LINKER [dict get $opts -linker] LANG C.utf8 LC_ALL C.utf8] {
            set failed [catch {exec [info nameofexecutable] [file join $root main.tcl] -warnings off -emit-native-executable $program 2>@1} out]
        }
    } finally {
        cd $here
    }
    if {$failed || ![file exists $exe]} {
        return [dict create ok 0 error $out]
    }
    return [dict create ok 1 exe $exe output $out]
}

# Run EXE: its exit status and, through the driver protocol
# (BOTLISH_NATIVE_RESULT), its value as a list of strings.
proc rustlink::run {exe} {
    set result [file join [file dirname $exe] [file tail $exe].result]
    file delete -force $result
    WithEnv [dict create BOTLISH_NATIVE_RESULT $result] {
        set status 0
        if {[catch {exec $exe 2>@1} out opts]} {
            set code [dict get $opts -errorcode]
            set status [expr {[lindex $code 0] eq "CHILDSTATUS" ? [lindex $code 2] : -1}]
            if {[lindex $code 0] eq "CHILDKILLED"} { set status "signal [lindex $code 2]" }
        }
    }
    set raw ""
    set value {}
    if {[file exists $result]} {
        set f [open $result r]
        set raw [read $f]
        close $f
        foreach line [split $raw \n] {
            if {[lindex $line 0] eq "value" && [lindex $line 1 0] eq "list"} {
                set value [lmap item [lindex $line 1 1] {lindex $item 1}]
            }
        }
    }
    return [dict create status $status value $value raw $raw output $out]
}

# The definitions of symbol NAME (a C name) in EXE: how many are global and
# how many local (nm: an upper-case or lower-case type).
proc rustlink::copies {exe name} {
    if {[format] eq "macho"} {
        set sym _$name
        set listed [rustunit::MachoNm $exe]
    } else {
        set sym $name
        set listed [rustunit::Nm $exe]
    }
    set global 0
    set local 0
    foreach line [split $listed \n] {
        if {[llength $line] != 3 || [lindex $line 2] ne $sym} continue
        set type [lindex $line 1]
        if {$type in {U u w v}} continue
        if {[string is upper $type]} { incr global } else { incr local }
    }
    return [dict create global $global local $local]
}

# What PROGRAM's right run lists, with its toolchain line (the unit's rustc
# version) taken out.
proc rustlink::expected {program} {
    set common [list {version 1} {digest items=3 unique=2 bytes=20 longest=10 fnv1a=ddc03a852782f54b} \
        {runtime work 188890} {churn 5700} {panics 2} {unit allocator counts the unit only}]
    switch -- $program {
        without_provider.bot { return [list {*}$common {notify without provider -38}] }
        with_provider.bot { return [list {*}$common {notify with provider 0}] }
    }
    Fail "no expectation for $program"
}

# VALUE without its toolchain line, and the line.
proc rustlink::Toolchain {value} {
    set rest {}
    set tool ""
    foreach item $value {
        if {[string match "toolchain *" $item]} { set tool [string range $item 10 end] } else { lappend rest $item }
    }
    return [list $rest $tool]
}

# One case: link PROGRAM of APP with LINKER and run it: {link ok|failed,
# error TEXT, status N, value {...}, toolchain T, verdict pass|fail|link}.
proc rustlink::case {app program linker} {
    set l [link $app $program -linker $linker]
    if {![dict get $l ok]} {
        return [dict create link failed error [dict get $l error] status "" value {} toolchain "" verdict link exe ""]
    }
    set r [run [dict get $l exe]]
    lassign [Toolchain [dict get $r value]] rest tool
    set verdict [expr {[dict get $r status] == 0 && $rest eq [expected $program] ? "pass" : "fail"}]
    return [dict create link ok error "" status [dict get $r status] value [dict get $r value] toolchain $tool \
        verdict $verdict exe [dict get $l exe] output [dict get $r output]]
}
