# single/package.tcl -- packs the single-file Botlish compiler
# (SINGLE-EXECUTABLE.md). single/build.sh runs it; run it directly to pack
# with a base kit and native build of your own:
#
#   BASEKIT single/package.tcl OUTPUT NATIVE-DIR
#
# BASEKIT is a zipfs-capable Tcl 9 executable with Tcl statically linked (a
# "zipkit" base: the static tclsh single/build.sh builds, or a prebuilt one);
# it runs this script and becomes the non-archive part of OUTPUT. NATIVE-DIR
# holds the native backend's botlish-native and botlish-aot-stub
# (native/target/release, or stripped copies of them). OUTPUT is BASEKIT with
# a zip archive attached, holding:
#
#   main.tcl              single/main.tcl, run at startup with the arguments
#   tcl_library/          BASEKIT's own Tcl script library
#   botlish/              main.tcl, LICENSE, core/, compiler/, hir/, surface/,
#                         service/ (main.tcl -check),
#                         native/*.tcl, stdlib/, compilerpedia/ (the engine,
#                         topics/ and generated/: -help) -- the compiler
#                         stack, at its checkout-relative paths -- and
#                         BUILD, the source revision -version prints
#   native-bin/           botlish-native, botlish-aot-stub, and ID (their
#                         digest, naming the directory single/main.tcl
#                         installs them in)
#
# Nothing else of the checkout goes in: no tests, benchmarks or tools.

if {[llength $argv] != 2} {
    puts stderr "usage: BASEKIT single/package.tcl OUTPUT NATIVE-DIR"
    exit 2
}
lassign $argv output nativeDir
set root [file dirname [file dirname [file normalize [info script]]]]
set output [file normalize $output]
if {[info commands zipfs] eq ""} {
    puts stderr "[info nameofexecutable] has no zipfs: a zipkit base needs Tcl 9 built with zipfs"
    exit 1
}

set stage [file tempdir botlish-single]
try {
    set app [file join $stage botlish]
    file mkdir $app
    # The compiler stack, at the paths main.tcl and its sources compute from
    # their own locations.
    foreach item {main.tcl LICENSE core compiler hir surface service stdlib} {
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

    set bin [file join $stage native-bin]
    file mkdir $bin
    set digest {}
    foreach name {botlish-native botlish-aot-stub} {
        set path [file join $nativeDir $name]
        if {![file isfile $path]} {
            throw {SINGLE PACKAGE} "missing $path: build the native backend first (cargo build --release --manifest-path native/Cargo.toml)"
        }
        file copy $path $bin
        set channel [open $path rb]
        lappend digest [format %08x [zlib crc32 [read $channel]]] [file size $path]
        close $channel
    }
    set channel [open [file join $bin ID] w]
    puts $channel [join $digest -]
    close $channel

    file copy [file join $root single main.tcl] [file join $stage main.tcl]
    file copy $::tcl_library [file join $stage tcl_library]

    file delete -force $output
    zipfs mkimg $output $stage $stage "" [info nameofexecutable]
} finally {
    file delete -force $stage
}
puts "single executable: $output ([file size $output] bytes)"
