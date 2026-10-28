# single/package.tcl -- packs the Botlish compiler for distribution: the
# single-file compiler (SINGLE-EXECUTABLE.md) and the compiler archive of
# the macOS application (MACOS-AARCH64-MILESTONE-9.md). single/build.sh and
# single/macos/build.sh run it; run it directly to pack with a base kit and
# native build of your own:
#
#   BASEKIT single/package.tcl OUTPUT NATIVE-DIR
#   TCLSH   single/package.tcl -archive OUTPUT.zip NATIVE-DIR
#
# Both pack the same compiler, staged by one procedure (StageCompiler):
#
#   main.tcl              single/main.tcl, run at startup with the arguments
#   botlish/              main.tcl, LICENSE, core/, compiler/, hir/, surface/,
#                         service/ (main.tcl -check), lsp/ (main.tcl -lsp),
#                         native/*.tcl, stdlib/, compilerpedia/ (the engine,
#                         topics/ and generated/: -help) -- the compiler
#                         stack, at its checkout-relative paths -- and
#                         BUILD, the source revision -version prints
#   native-bin/ID         the native files' identity: each one's CRC and size
#
# The first form makes the single executable (Linux). BASEKIT is a
# zipfs-capable Tcl 9 executable with Tcl statically linked (a "zipkit" base:
# the static tclsh single/build.sh builds, or a prebuilt one); it runs this
# script and becomes the non-archive part of OUTPUT. NATIVE-DIR holds the
# native backend's botlish-native and botlish-aot-stub and the runtime
# archive libbotlish_runtime.a (native/target/release, or stripped copies of
# them). OUTPUT is BASEKIT with a zip archive attached, holding besides the
# above
#
#   tcl_library/          BASEKIT's own Tcl script library
#   native-bin/           botlish-native, botlish-aot-stub, the runtime
#                         archive libbotlish_runtime.a (the system linker's,
#                         SINGLE-EXECUTABLE-FFI-MILESTONE-1.md); ID names the
#                         directory single/main.tcl installs them in
#
# The second form (-archive) writes the compiler alone as an ordinary ZIP
# file: the macOS application's Contents/Resources/botlish.zip, which its
# launcher mounts at //zipfs:/app. Tcl and the native files are the
# application's own (its Tcl.framework, Contents/MacOS/botlish-native,
# Contents/Resources/libbotlish_runtime.a): no tcl_library, and native-bin
# holds only ID, of NATIVE-DIR's botlish-native and libbotlish_runtime.a --
# the files exactly as the application carries them, signed.
#
# Nothing else of the checkout goes in: no tests, benchmarks or tools.

set mode zipkit
if {[lindex $argv 0] eq "-archive"} {
    set mode archive
    set argv [lrange $argv 1 end]
}
if {[llength $argv] != 2} {
    puts stderr "usage: BASEKIT single/package.tcl OUTPUT NATIVE-DIR\n       TCLSH single/package.tcl -archive OUTPUT.zip NATIVE-DIR"
    exit 2
}
lassign $argv output nativeDir
set root [file dirname [file dirname [file normalize [info script]]]]
set output [file normalize $output]
if {[info commands zipfs] eq ""} {
    puts stderr "[info nameofexecutable] has no zipfs: packing needs Tcl 9 built with zipfs"
    exit 1
}

# Stages the compiler stack in APP (a new directory), at the paths main.tcl
# and its sources compute from their own locations, with its BUILD file.
proc StageCompiler {app} {
    global root
    file mkdir $app
    foreach item {main.tcl LICENSE core compiler hir surface service lsp stdlib} {
        file copy [file join $root $item] [file join $app $item]
    }
    file mkdir [file join $app native] [file join $app compilerpedia]
    foreach path [glob -directory [file join $root native] *.tcl] {
        file copy $path [file join $app native]
    }
    # Compilerpedia, the reference -help reads (COMPILERPEDIA.md): its
    # engine and its topic files; the notes and the tool are development
    # files.
    file copy [file join $root compilerpedia compilerpedia.tcl] [file join $app compilerpedia]
    foreach dir {topics generated} {
        file copy [file join $root compilerpedia $dir] [file join $app compilerpedia $dir]
    }
    # The source revision, for -version: the checkout's commit, marked when
    # the working tree differs from it.
    set revision unknown
    if {![catch {exec git -C $root rev-parse --short HEAD} commit]} {
        set revision $commit
        if {![catch {exec git -C $root status --porcelain --untracked-files=no} status] && $status ne ""} {
            append revision " (modified)"
        }
    }
    set channel [open [file join $app BUILD] w]
    puts $channel "commit $revision"
    close $channel
}

# The identity of the native files NAMES in DIR: each one's CRC and size,
# written to BIN/ID; with COPY the files are copied into BIN too.
proc StageNative {bin dir names copy} {
    file mkdir $bin
    set digest {}
    foreach name $names {
        set path [file join $dir $name]
        if {![file isfile $path]} {
            throw {SINGLE PACKAGE} "missing $path: build the native backend first (cargo build --release --manifest-path native/Cargo.toml)"
        }
        if {$copy} {
            file copy $path $bin
        }
        set channel [open $path rb]
        lappend digest [format %08x [zlib crc32 [read $channel]]] [file size $path]
        close $channel
    }
    set channel [open [file join $bin ID] w]
    puts $channel [join $digest -]
    close $channel
}

set stage [file tempdir botlish-single]
try {
    StageCompiler [file join $stage botlish]
    file copy [file join $root single main.tcl] [file join $stage main.tcl]
    file delete -force $output
    if {$mode eq "zipkit"} {
        StageNative [file join $stage native-bin] $nativeDir {botlish-native botlish-aot-stub libbotlish_runtime.a} 1
        file copy $::tcl_library [file join $stage tcl_library]
        zipfs mkimg $output $stage $stage "" [info nameofexecutable]
    } else {
        StageNative [file join $stage native-bin] $nativeDir {botlish-native libbotlish_runtime.a} 0
        zipfs mkzip $output $stage $stage
    }
} finally {
    file delete -force $stage
}
if {$mode eq "zipkit"} {
    puts "single executable: $output ([file size $output] bytes)"
} else {
    puts "compiler archive: $output ([file size $output] bytes)"
}
