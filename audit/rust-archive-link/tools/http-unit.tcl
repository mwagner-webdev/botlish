# http-unit.tcl -- the real http unit (packages/http/native, crate
# botlish_http) built, localized and linked beside the Botlish runtime on
# this host (HTTP-MACOS-RUST-ARCHIVE-LINK-FEASIBILITY-MILESTONE-1.md,
# section 8). A link-feasibility check, not a port: no event-loop driver,
# no network.
#
#   tclsh9.0 audit/rust-archive-link/tools/http-unit.tcl OUTDIR ?-toolchain T?
#
# Linux (the control): tools/http-package.tcl's own provider archive and
# localized release unit, unchanged.
#
# macOS: what tools/http-package.tcl does on Linux, done with Apple's tools
# -- BoringSSL fetched by its pin (packages/boringssl/PIN, tag object and
# commit checked) and built by upstream's CMake for arm64; the unit built
# by cargo --locked (TOOLCHAIN, default the pinned author image's 1.97.0)
# in link-only mode against those headers, from a *copy* of
# packages/http/native with one portability change (net.rs: the socket's
# SOCK_NONBLOCK and SOCK_CLOEXEC, which Darwin's socket() and the libc
# crate's Apple targets do not have, set with fcntl after socket() instead);
# then localized by tools/rust-unit.tcl (Mach-O: ld -r -exported_symbols_list,
# keeping bh_*). The provider's two upstream archives and its identity
# object are linked as three archives (no merge on macOS yet).
#
# Both: the localized unit's global definitions must be exactly the bh_*
# functions abi.rs exports; a Botlish program (written into OUTDIR/probe,
# its archives declared `static at` beside it) that opens the bridge, asks
# the provider's API version, makes a client trusting the system bundle (a
# BoringSSL SSL_CTX, its store loaded) and closes everything is linked with
# both Botlish linkers and run. OUTDIR/RESULTS.txt records what happened.
set here [file dirname [file normalize [info script]]]
source [file join $here rustlink.tcl]
source [file join $rustlink::root tools http-package.tcl]

set out [lindex $argv 0]
if {$out eq ""} {
    puts stderr "usage: tclsh9.0 audit/rust-archive-link/tools/http-unit.tcl OUTDIR ?-toolchain T?"
    exit 2
}
set out [file normalize $out]
set opts [dict create -toolchain 1.97.0]
foreach {k v} [lrange $argv 1 end] { dict set opts $k $v }
file delete -force $out
file mkdir $out
set results [open [file join $out RESULTS.txt] w]
proc record {args} {
    puts $::results [join $args \t]
    flush $::results
    puts [join $args \t]
}

proc sha256 {path} {
    if {[auto_execok sha256sum] ne ""} { return [lindex [exec sha256sum $path] 0] }
    return [lindex [exec shasum -a 256 $path] 0]
}

# The C functions abi.rs exports (the unit's whole C ABI).
set abi [lsort -unique [lmap {- name} [regexp -all -inline {extern "C" fn (bh_[a-z_]+)} [exec cat [file join $rustlink::root packages http native src abi.rs]]] {set name}]]
record source-exports [llength $abi] [join $abi " "]

set format [rustlink::format]
set native [file join $out probe native]
file mkdir $native
if {$format eq "elf"} {
    # The production path, as tools/http-package.tcl builds a release.
    set archives [httppkg::ProviderArchives]
    set unit [httppkg::Unit]
    file copy $unit [file join $native libbotlish_http.a]
    file copy [file join $archives libbotlish_boringssl.a] [file join $native libbotlish_boringssl.a]
    set links "extern c library \"botlish_http\" static at \"native/libbotlish_http.a\"\nextern c library \"botlish_boringssl\" static at \"native/libbotlish_boringssl.a\"\nextern c library \"stdc++\"\n"
    record path production "tools/http-package.tcl (Linux)"
} else {
    set toolchain [dict get $opts -toolchain]
    set pin [httppkg::Pin]
    set commit [dict get $pin commit]
    set cache [file join [rustlink::CacheDir] http-macos]
    set src [httppkg::Fetch $pin [file join $cache src boringssl-$commit]]
    record boringssl [dict get $pin tag] $commit
    set build [file join $cache build-boringssl]
    set lib [file join $cache provider lib]
    if {![file exists [file join $lib libssl.a]]} {
        file delete -force $build
        set flags "-ffile-prefix-map=$src=/boringssl -ffile-prefix-map=$build=/boringssl-build"
        exec cmake -S $src -B $build -GNinja {*}[dict get $pin cmake] -DCMAKE_OSX_ARCHITECTURES=arm64 \
            -DCMAKE_OSX_DEPLOYMENT_TARGET=11.0 "-DCMAKE_C_FLAGS=$flags" "-DCMAKE_CXX_FLAGS=$flags" >@stdout 2>@stderr
        exec ninja -C $build {*}[dict get $pin targets] >@stdout 2>@stderr
        file mkdir $lib
        foreach l {crypto ssl} {
            file copy -force [file join $build lib$l.a] [file join $lib lib$l.a]
        }
    }
    foreach l {crypto ssl} {
        record provider-archive lib$l.a [file size [file join $lib lib$l.a]] [sha256 [file join $lib lib$l.a]]
    }
    # The identity object, in an archive of its own.
    set id [httppkg::ProviderId]
    set idobj [file join $cache identity.o]
    exec cc -O2 -Wall -Wextra -Werror -mmacosx-version-min=11.0 -DBOTLISH_BORINGSSL_ID=$id \
        -c [file join $rustlink::root packages boringssl native identity.c] -o $idobj
    file delete -force [file join $native libbotlish_boringssl_identity.a]
    rustlink::WithEnv {ZERO_AR_DATE 1} {
        exec libtool -static -D -o [file join $native libbotlish_boringssl_identity.a] $idobj 2>@stderr
    }
    foreach l {crypto ssl} {
        file copy [file join $lib lib$l.a] [file join $native lib$l.a]
    }
    # The unit: a copy of the crate, the one portability change applied.
    set crate [file join $cache crate]
    file delete -force $crate
    file mkdir $crate
    foreach item {Cargo.toml Cargo.lock build.rs src} {
        file copy [file join $rustlink::root packages http native $item] $crate
    }
    set net [file join $crate src net.rs]
    set f [open $net r]; set text [read $f]; close $f
    set old {    let fd = unsafe { libc::socket(family, libc::SOCK_STREAM | libc::SOCK_NONBLOCK | libc::SOCK_CLOEXEC, 0) };
    if fd < 0 {
        let code = errno();
        return Err(ConnectError { code, text: os_text(code), addr: Some(*addr) });
    }}
    set new {    let fd = unsafe { libc::socket(family, libc::SOCK_STREAM, 0) };
    if fd < 0 {
        let code = errno();
        return Err(ConnectError { code, text: os_text(code), addr: Some(*addr) });
    }
    // macOS (HTTP-MACOS-RUST-ARCHIVE-LINK-FEASIBILITY-MILESTONE-1.md's
    // build of a copy): no SOCK_NONBLOCK or SOCK_CLOEXEC; the same flags
    // after socket().
    unsafe {
        let fl = libc::fcntl(fd, libc::F_GETFL);
        libc::fcntl(fd, libc::F_SETFL, fl | libc::O_NONBLOCK);
        libc::fcntl(fd, libc::F_SETFD, libc::FD_CLOEXEC);
    }}
    if {[string first $old $text] < 0} {
        error "http-unit: net.rs no longer holds the socket call this check adapts"
    }
    set f [open $net w]; puts -nonewline $f [string map [list $old $new] $text]; close $f
    record path modified "a copy of packages/http/native, net.rs's socket flags set by fcntl"
    set stub [file join $cache stub-bssl]
    file mkdir [file join $stub lib]
    foreach l {crypto ssl} {
        set f [open [file join $stub lib lib$l.a] wb]; puts -nonewline $f "!<arch>\n"; close $f
    }
    set target [file join $cache cargo]
    file delete -force $target
    set home [expr {[info exists ::env(CARGO_HOME)] && $::env(CARGO_HOME) ne "" ? $::env(CARGO_HOME) : [file join [file home] .cargo]}]
    set env [dict create BORING_BSSL_PATH $stub BORING_BSSL_INCLUDE_PATH [file join $src include] \
        BOTLISH_BORINGSSL_PROVIDER $id CARGO_TARGET_DIR $target MACOSX_DEPLOYMENT_TARGET 11.0 \
        RUSTFLAGS "--remap-path-prefix=$crate=/botlish_http --remap-path-prefix=$home=/cargo --remap-path-prefix=$target=/target" \
        CFLAGS "-ffile-prefix-map=$crate=/botlish_http -ffile-prefix-map=$target=/target" SOURCE_DATE_EPOCH 0 CARGO_INCREMENTAL 0]
    set dev [exec xcode-select -p]
    foreach candidate [list [file join $dev Toolchains XcodeDefault.xctoolchain usr lib] [file join $dev usr lib]] {
        if {[file exists [file join $candidate libclang.dylib]]} {
            dict set env LIBCLANG_PATH $candidate
            break
        }
    }
    record rustc [exec rustc +$toolchain --version]
    rustlink::WithEnv $env {
        exec cargo +$toolchain build --release --locked --manifest-path [file join $crate Cargo.toml] >@stdout 2>@stderr
    }
    set raw [file join $target release libbotlish_http.a]
    record raw-unit [file size $raw] [sha256 $raw] "[llength [rustunit::globals $raw -format macho]] global definitions"
    set unit [file join $native libbotlish_http.a]
    rustunit::localize $raw $unit -format macho -keep {bh_*} -label botlish_http -member botlish_http.o
    record ld-r-form $rustunit::macho(form) [join $rustunit::macho(tried) "; "]
    set links "extern c library \"botlish_http\" static at \"native/libbotlish_http.a\"\nextern c library \"crypto\" static at \"native/libcrypto.a\"\nextern c library \"ssl\" static at \"native/libssl.a\"\nextern c library \"botlish_boringssl_identity\" static at \"native/libbotlish_boringssl_identity.a\"\nextern c library \"c++\"\n"
}
set unit [file join $native libbotlish_http.a]
set globals [rustunit::globals $unit -format $format]
set undefined [rustunit::undefined $unit -format $format]
record localized-unit [file size $unit] [sha256 $unit] "[llength $globals] global definitions"
record surface-equals-abi [expr {$globals eq $abi}] [join [lmap s $globals {expr {$s in $abi ? [continue] : $s}}] " "]
record undefined-count [llength $undefined]
foreach probe {botlish_event_post2 rust_eh_personality ___gxx_personality_v0 __gxx_personality_v0 SSL_CTX_new} {
    record undefined-$probe [expr {$probe in $undefined}]
}
record undefined-provider-identity [llength [lsearch -all -glob $undefined botlish_boringssl_*]]

# The probe program.
set ll std::ffi::c::LongLong
set f [open [file join $out probe probe.bot] w]
puts $f "# A link-feasibility probe of the http unit (written by audit/rust-archive-link/tools/http-unit.tcl)."
puts $f "import std::abi\nimport std::abi::bytes\nimport std::ffi::c\n"
puts -nonewline $f $links
puts $f "
extern c fn bh_open(flags: $ll) -> $ll
extern c fn bh_close() -> $ll
extern c fn bh_provider() -> $ll
extern c fn bh_client(versions: $ll, connect_us: $ll, idle_us: $ll, max_per_origin: $ll, max_header_bytes: $ll, pool_idle_us: $ll, window: $ll, system_trust: $ll, anchors: std::ffi::c::Ptr\[std::ffi::c::Void\] read noescape, anchors_len: std::ffi::c::ULong) -> $ll
extern c fn bh_release(h: $ll) -> $ll
extern c fn bh_stats(buf: std::ffi::c::Ptr\[std::ffi::c::Void\] write noescape, cap: std::ffi::c::ULong) -> $ll

fn positive(x: int) -> int:
    if x > 0:
        return 1
    0

opened = bh_open(0)
again = bh_open(0)
api = bh_provider()
none = std::abi::bytes::freeze(std::abi::bytes::zeroed(std::abi::usize(0)))
client = bh_client(0, 0, 0, 8, 65536, 0, 65535, 1, none, 0)
s = bh_stats(std::abi::bytes::zeroed(std::abi::usize(168)), 168)
released = bh_release(client)
closed = bh_close()
\[opened, again, positive(api), positive(client), s.result, released, closed\]"
close $f
set expected {0 -90003 1 1 168}
foreach linker {rustc system} {
    set l [rustlink::link [file join $out probe] probe.bot -linker $linker]
    if {![dict get $l ok]} {
        record link-$linker failed [string map {\n " | "} [string range [dict get $l error] 0 1500]]
        continue
    }
    set exe [dict get $l exe]
    foreach line [split [dict get $l output] \n] {
        if {[regexp -nocase {warning} $line]} {
            record link-warning-$linker [string range $line 0 300]
        }
    }
    file rename -force $exe $exe-$linker
    set exe $exe-$linker
    set r [rustlink::run $exe]
    set value [lindex [regexp -inline {value \{list \{(.*)\}\}} [dict get $r raw]] 1]
    set ints [lmap item $value {lindex $item 1}]
    set p [rustlink::copies $exe rust_eh_personality]
    record link-$linker ok status [dict get $r status] value $ints \
        verdict [expr {[dict get $r status] == 0 && [lrange $ints 0 4] eq $expected ? "pass" : "fail"}] \
        personality "[dict get $p global] global [dict get $p local] local" bytes [file size $exe]
    if {[dict get $r status] != 0} {
        record output-$linker [string map {\n " | "} [string range [dict get $r output] 0 1500]]
    }
}
close $results
