# single/main.tcl -- the entry script of the single-file Botlish compiler
# (SINGLE-EXECUTABLE.md).
#
# single/build.sh packs this file as the zipkit's main.tcl
# (//zipfs:/app/main.tcl), which Tcl 9's startup (TclZipfs_AppHook) runs with
# the executable's own arguments. The archive holds this repository's compiler
# stack under //zipfs:/app/botlish -- main.tcl, core/, compiler/, hir/,
# surface/, native/*.tcl, stdlib/ and compilerpedia/, at the same relative paths
# as in a checkout -- and the native backend's two Rust executables under
# //zipfs:/app/native-bin. This script
#
#   1. makes UTF-8 the system and standard-channel encoding (a checkout's
#      canonical setup is LANG=C.utf8, AGENTS.md; a single executable does not
#      ask its user for a locale),
#   2. unless the invocation is only the usage summary (no arguments), -help,
#      -version or the language server (-lsp, -lsp-worker: they analyze and
#      never reach a backend), installs the native executables, which the kernel cannot
#      run from inside the archive, into a per-build cache directory (once
#      per build: later runs find them there), and points the native backend
#      at them:
#      BOTLISH_NATIVE_BIN (native::binary) for the driver, and the `stub`
#      linker with BOTLISH_NATIVE_AOT_STUB for -emit-native-executable, which
#      therefore needs no rustc, linker or runtime library,
#   3. runs the checkout's own main.tcl, unchanged, with the same arguments:
#      every option main.tcl documents works the same way.

encoding system utf-8
foreach channel {stdin stdout stderr} {
    fconfigure $channel -encoding utf-8
}

namespace eval ::single {
    variable app [file dirname [file normalize [info script]]]
    variable executables {botlish-native botlish-aot-stub}
}

# The directories the native executables may be installed in, best first:
# $BOTLISH_CACHE_DIR, then $XDG_CACHE_HOME/botlish, then ~/.cache/botlish.
proc ::single::CacheRoots {} {
    set roots {}
    if {[info exists ::env(BOTLISH_CACHE_DIR)] && $::env(BOTLISH_CACHE_DIR) ne ""} {
        lappend roots $::env(BOTLISH_CACHE_DIR)
    }
    if {[info exists ::env(XDG_CACHE_HOME)] && [file pathtype $::env(XDG_CACHE_HOME)] eq "absolute"} {
        lappend roots [file join $::env(XDG_CACHE_HOME) botlish]
    }
    if {[info exists ::env(HOME)] && $::env(HOME) ne ""} {
        lappend roots [file join $::env(HOME) .cache botlish]
    }
    return $roots
}

# Copies the archive's native executables into DIR, unless they are there
# already. Each is written under a temporary name and renamed into place, so
# concurrent first runs never see (or run) a partial file.
proc ::single::Install {dir} {
    variable app
    variable executables
    file mkdir $dir
    foreach name $executables {
        set source [file join $app native-bin $name]
        set target [file join $dir $name]
        if {[file isfile $target] && [file size $target] == [file size $source]} continue
        set partial [file join $dir .$name.[pid].partial]
        try {
            file copy -force $source $partial
            file attributes $partial -permissions 0755
            file rename -force $partial $target
        } on error {message options} {
            file delete -force $partial
            return -options $options $message
        }
    }
}

# The directory holding this build's native executables, installed on first
# use. The build's id (//zipfs:/app/native-bin/ID: a digest of the
# executables, written by single/package.tcl) names the directory, so builds
# never share one. Without any usable cache directory, a private temporary one
# serves this run and is removed when it exits.
proc ::single::NativeDir {} {
    variable app
    set id [string trim [readFile [file join $app native-bin ID]]]
    foreach root [CacheRoots] {
        set dir [file join $root native-$id]
        if {![catch {Install $dir}]} {
            return $dir
        }
    }
    set dir [file tempdir botlish-native]
    Install $dir
    rename ::exit ::single::Exit
    proc ::exit {{status 0}} [string map [list @DIR@ [list $dir]] {
        catch {file delete -force @DIR@}
        ::single::Exit $status
    }]
    return $dir
}

# The usage summary, -help and -version run no program: they install
# nothing (main.tcl answers them before it loads the compiler). Nor does
# the language server or its worker (which starts as this executable, with
# -lsp-worker, whenever it is replaced), which never reach a backend.
if {$::argv ne "" && [lindex $::argv 0] ni {-help --help -h -version --version}
        && "-lsp" ni $::argv && "-lsp-worker" ni $::argv} {
    if {[catch {::single::NativeDir} ::single::nativeDir]} {
        puts stderr "botlish: cannot install the native backend: $::single::nativeDir"
        exit 2
    }
    set ::env(BOTLISH_NATIVE_BIN) [file join $::single::nativeDir botlish-native]
    set ::env(BOTLISH_NATIVE_AOT_STUB) [file join $::single::nativeDir botlish-aot-stub]
    set ::env(BOTLISH_NATIVE_LINKER) stub
}

set ::argv0 [info nameofexecutable]
source [file join $::single::app botlish main.tcl]
