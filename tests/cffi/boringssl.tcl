# boringssl.tcl -- the package-owned static BoringSSL the C FFI's SHA-256
# acceptance links (C-FFI.md, "BoringSSL").
#
#   tclsh9.0 tests/cffi/boringssl.tcl          build it (once) and print its
#                                              directory
#   source tests/cffi/boringssl.tcl            cffi::boringsslDir: the
#                                              directory, "" when not built
#
# The library is BoringSSL's pinned release -- the header archaeology's own
# (audit/c-header/profiles/boringssl.tcl: tag 0.20260929.0, its commit
# checked), fetched by audit/c-header/tools/fetch.tcl into Botlish's cache --
# built once with CMake and Ninja as the static libcrypto.a (and libssl.a
# and libdecrepit.a, whose symbols the binding generator's acceptance
# checks too), with BORINGSSL_PREFIX=botlish_bssl: every symbol it defines is prefixed
# (BoringSSL's own symbol-prefix build, BUILDING.md), so SHA256 is
# botlish_bssl_SHA256, which nothing but this build defines. A binding that
# names it (examples/ffi/sha256/boringssl.bot) can therefore never be
# satisfied by an ambient system OpenSSL: without this build the link fails.
#
# The directory is $BOTLISH_BORINGSSL_DIR when set, else
# boringssl/COMMIT-botlish_bssl under Botlish's cache directory
# ($BOTLISH_CACHE_DIR, $XDG_CACHE_HOME/botlish or ~/.cache/botlish); never
# the repository. It is test and example infrastructure: Botlish's compiler
# and runtime never build, fetch or need it, and a program reaches it only by
# its own `extern c library "crypto"` and the linker's -L.

namespace eval cffi {
    variable here [file dirname [file normalize [info script]]]
    variable prefix botlish_bssl
}

# Botlish's cache directory.
proc cffi::CacheDir {} {
    foreach {var sub} {BOTLISH_CACHE_DIR {} XDG_CACHE_HOME botlish} {
        if {[info exists ::env($var)] && $::env($var) ne ""} {
            return [file normalize [file join $::env($var) {*}$sub]]
        }
    }
    return [file normalize [file join [file home] .cache botlish]]
}

# The pinned commit of the profile.
proc cffi::Commit {} {
    variable here
    set profile [file join [file dirname [file dirname $here]] audit c-header profiles boringssl.tcl]
    set channel [open $profile r]
    set text [read $channel]
    close $channel
    if {![regexp {commit ([0-9a-f]{40})} $text -> commit]} {
        error "boringssl.tcl: no pinned commit in $profile"
    }
    return $commit
}

# Where the build lives (whether or not it exists).
proc cffi::BuildDir {} {
    variable prefix
    if {[info exists ::env(BOTLISH_BORINGSSL_DIR)] && $::env(BOTLISH_BORINGSSL_DIR) ne ""} {
        return [file normalize $::env(BOTLISH_BORINGSSL_DIR)]
    }
    return [file join [CacheDir] boringssl [Commit]-$prefix]
}

# The directory holding the built libcrypto.a, or "" when it is not built.
proc cffi::boringsslDir {} {
    set dir [BuildDir]
    return [expr {[file exists [file join $dir libcrypto.a]] ? $dir : ""}]
}

# Builds the library unless it is built; returns its directory.
proc cffi::Build {} {
    variable here
    variable prefix
    set dir [BuildDir]
    if {[boringsslDir] ne ""} {
        return $dir
    }
    set root [file dirname [file dirname $here]]
    exec [info nameofexecutable] [file join $root audit c-header tools fetch.tcl] boringssl >@stdout 2>@stderr
    source [file join $root audit c-header tools common.tcl]
    set source [file join [::chdr::sourcesDir] boringssl]
    file mkdir $dir
    # BoringSSL builds with -Werror. GCC 15 generating x86-64-v3 code (the
    # default of Ubuntu 26.04's amd64v3 packages, which GitHub's
    # ubuntu-26.04 runners install) reports a -Wstringop-overflow false
    # positive in keccak.cc.inc's left_encode, which writes at most 9 bytes.
    # That one diagnostic stays a warning, for GCC only (clang refuses the
    # option): CMake includes this file after BoringSSL's project(), when the
    # compiler is known.
    set include [file join $dir botlish-project-include.cmake]
    set channel [open $include w]
    puts $channel {add_compile_options("$<$<COMPILE_LANG_AND_ID:C,GNU>:-Wno-error=stringop-overflow>"
    "$<$<COMPILE_LANG_AND_ID:CXX,GNU>:-Wno-error=stringop-overflow>")}
    close $channel
    puts "boringssl: building libcrypto.a (BORINGSSL_PREFIX=$prefix) in $dir"
    exec cmake -S $source -B $dir -GNinja -DCMAKE_BUILD_TYPE=Release -DBORINGSSL_PREFIX=$prefix \
        -DCMAKE_PROJECT_INCLUDE=$include >@stdout 2>@stderr
    exec ninja -C $dir crypto ssl decrepit >@stdout 2>@stderr
    if {[boringsslDir] eq ""} {
        error "boringssl: the build produced no libcrypto.a in $dir"
    }
    return $dir
}

if {[info exists ::argv0] && [file normalize $::argv0] eq [file normalize [info script]]} {
    puts [cffi::Build]
}
