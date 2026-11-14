# http-macos.tcl -- the http package's native unit on macOS AArch64, as a
# link-feasibility probe (HTTP-MACOS-RUST-ARCHIVE-LINK-FEASIBILITY-
# MILESTONE-1.md, "The http unit"). Not the port: nothing here is a release
# recipe, and packages/http is not changed -- the unit is built from a copy
# with audit/rust-archive-link/http/macos.patch applied (Apple's socket()
# takes no SOCK_NONBLOCK or SOCK_CLOEXEC).
#
#   tclsh9.0 audit/rust-archive-link/tools/http-macos.tcl provider DIR
#       the pinned BoringSSL (packages/boringssl/PIN, tools/http-package.tcl's
#       fetch and checks) built with upstream's CMake, in one archive with
#       the provider's identity member: DIR/libbotlish_boringssl.a
#   tclsh9.0 audit/rust-archive-link/tools/http-macos.tcl unit PROVIDERDIR DIR ?testing?
#       the patched unit, built link-only against the provider's headers,
#       localized by tools/rust-unit.tcl: DIR/libbotlish_http.a, DIR/UNIT.txt
#   tclsh9.0 audit/rust-archive-link/tools/http-macos.tcl probe COMPILER UNITDIR PROVIDERDIR DIR
#       the probe programs (http/probe*.bot) linked and run: DIR/PROBE.txt
set here [file dirname [file normalize [info script]]]
set audit [file dirname $here]
set root [file dirname [file dirname $audit]]
source [file join $root tools http-package.tcl]
source [file join $here rlf.tcl]

proc Provider {dir} {
    global root
    set dir [file normalize $dir]
    set pin [httppkg::Pin]
    set commit [dict get $pin commit]
    set work [file join $dir work]
    file mkdir $work
    set src [httppkg::Fetch $pin [file join $work boringssl-$commit]]
    set build [file join $work build]
    file delete -force $build
    set flags "-ffile-prefix-map=$src=/boringssl -ffile-prefix-map=$build=/boringssl-build"
    exec cmake -S $src -B $build -GNinja {*}[dict get $pin cmake] \
        "-DCMAKE_C_FLAGS=$flags" "-DCMAKE_CXX_FLAGS=$flags" -DCMAKE_OSX_ARCHITECTURES=arm64 >@stderr 2>@stderr
    exec ninja -C $build {*}[dict get $pin targets] >@stderr 2>@stderr
    set id [httppkg::ProviderId]
    set identity [file join $work botlish_boringssl_identity.o]
    exec cc -O2 -Wall -Wextra -Werror -fPIC -DBOTLISH_BORINGSSL_ID=$id \
        -ffile-prefix-map=$root=/botlish -c [file join $root packages boringssl native identity.c] -o $identity
    set archive [file join $dir libbotlish_boringssl.a]
    file delete -force $archive
    rustunit::WithEnv {ZERO_AR_DATE 1} {
        exec libtool -static -D -no_warning_for_no_symbols -o $archive [file join $build libcrypto.a] [file join $build libssl.a] $identity 2>@stderr
    }
    file delete -force [file join $dir include]
    file copy [file join $src include] [file join $dir include]
    rlf::Write [file join $dir PROVIDER.txt] "[dict create pin $pin id $id sha256 [rlf::Sha256 $archive] size [file size $archive] cc [rlf::ToolVersion cc --version] cmake [rlf::ToolVersion cmake --version]]\n"
    return $archive
}

proc Unit {providerDir dir testing} {
    global root audit
    set providerDir [file normalize $providerDir]
    set dir [file normalize $dir]
    set kind [expr {$testing ? "testing" : "release"}]
    set work [file join $dir work]
    file delete -force $work
    file mkdir $work
    # A copy of the unit's crate with the macOS patch.
    set crate [file join $work botlish_http]
    file copy [file join $root packages http native] $crate
    file delete -force [file join $crate target]
    exec patch -p1 -d $crate -i [file join $audit http macos.patch] >@stderr
    # Link-only BoringSSL: the provider's headers, archives holding one
    # empty object (Apple's ar makes no archive without a member).
    set stub [file join $work stub-bssl]
    file mkdir [file join $stub lib]
    rlf::Write [file join $stub empty.c] "/* empty: link-only BoringSSL */\nint botlish_http_link_only_stub;\n"
    foreach lib {crypto ssl} {
        exec cc -c -o [file join $stub $lib-empty.o] [file join $stub empty.c]
        rustunit::WithEnv {ZERO_AR_DATE 1} {
            exec libtool -static -D -o [file join $stub lib lib$lib.a] [file join $stub $lib-empty.o] 2>@stderr
        }
    }
    set targetDir [file join $work cargo]
    set home [expr {[info exists ::env(CARGO_HOME)] && $::env(CARGO_HOME) ne "" ? $::env(CARGO_HOME) : [file join [file home] .cargo]}]
    set remap [list --remap-path-prefix=$crate=/botlish_http --remap-path-prefix=$home=/cargo \
        --remap-path-prefix=$targetDir=/target --remap-path-prefix=[file normalize $root]=/botlish]
    set env [dict create BORING_BSSL_PATH $stub BORING_BSSL_INCLUDE_PATH [file join $providerDir include] \
        BOTLISH_BORINGSSL_PROVIDER [httppkg::ProviderId] CARGO_TARGET_DIR $targetDir RUSTFLAGS [join $remap " "] \
        CFLAGS "-ffile-prefix-map=$crate=/botlish_http -ffile-prefix-map=$targetDir=/target" \
        SOURCE_DATE_EPOCH 0 CARGO_INCREMENTAL 0 ZERO_AR_DATE 1]
    set cmd [list cargo build --release --locked --manifest-path [file join $crate Cargo.toml]]
    if {$testing} { lappend cmd --features testing }
    rlf::Log "http unit $kind: [join $cmd]"
    rustunit::WithEnv $env {
        exec {*}$cmd >@stderr 2>@stderr
    }
    set raw [file join $targetDir release libbotlish_http.a]
    set unit [file join $dir libbotlish_http.a]
    set exports [rustunit::Localize macos-aarch64 $raw $unit {bh_*} [file join $work localize]]
    set surface [rustunit::Surface macos-aarch64 $unit]
    rlf::Write [file join $dir UNIT.txt] "[dict create kind $kind exports $exports surface $surface raw [file size $raw] sha256 [rlf::Sha256 $unit] size [file size $unit] rustc [rlf::ToolVersion rustc --version] ld [rlf::ToolVersion ld -v] sdk [rlf::ToolVersion xcrun --show-sdk-version]]\n"
    if {$surface ne $exports} {
        error "http-macos: the localized unit defines [llength $surface] global symbols, its exports are [llength $exports]"
    }
    return $unit
}

proc Probe {compiler unitDir providerDir dir} {
    global audit
    set dir [file normalize $dir]
    file delete -force $dir
    file mkdir [file join $dir native]
    file copy [file join [file normalize $unitDir] libbotlish_http.a] [file join $dir native]
    file copy [file join [file normalize $providerDir] libbotlish_boringssl.a] [file join $dir native]
    exec cc -O2 -Wall -Wextra -Werror -c [file join $audit http notify-stub.c] -o [file join $dir notify-stub.o]
    exec libtool -static -o [file join $dir native libnotify_stub.a] [file join $dir notify-stub.o] 2>@stderr
    set report {}
    foreach program {probe probe-stubbed probe-testing} {
        if {![file exists [file join $audit http $program.bot]]} continue
        file copy -force [file join $audit http $program.bot] $dir
        foreach linker {rustc system} {
            set r [rlf::Control $compiler $dir $program $linker]
            set message [dict get $r message]
            set lines [lmap l [split $message \n] {expr {[regexp -nocase {undefined|duplicate|error:|warning:|ld:} $l] ? [string trim $l] : [continue]}}]
            lappend report "$program, linker $linker: built [dict get $r built] status [dict get $r status] value {[dict get $r value]}"
            foreach l [lrange $lines 0 11] { lappend report "    $l" }
            if {[dict get $r built]} {
                set exe [file join $dir $program]
                lappend report "    personality definitions: [lmap {n t} [rlf::Symbols macho $exe] {expr {$n eq "rust_eh_personality" ? $t : [continue]}}]"
                lappend report "    sha256 [rlf::Sha256 $exe] size [file size $exe]"
                file rename -force $exe $exe-$linker
            }
        }
    }
    rlf::Write [file join $dir PROBE.txt] [join $report \n]\n
    puts [join $report \n]
}

switch -- [lindex $argv 0] {
    provider { puts [Provider [lindex $argv 1]] }
    unit { puts [Unit [lindex $argv 1] [lindex $argv 2] [expr {[lindex $argv 3] eq "testing"}]] }
    probe { Probe [lindex $argv 1] [lindex $argv 2] [lindex $argv 3] [lindex $argv 4] }
    default {
        puts stderr "usage: http-macos.tcl provider DIR | unit PROVIDERDIR DIR ?testing? | probe COMPILER UNITDIR PROVIDERDIR DIR"
        exit 2
    }
}
