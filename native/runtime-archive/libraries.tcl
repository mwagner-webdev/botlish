# libraries.tcl -- the runtime archive's system libraries, as the driver
# passes them and as rustc accounts for them, compared
# (SINGLE-EXECUTABLE-FFI-MILESTONE-1.md, "The runtime archive").
#
#   tclsh9.0 native/runtime-archive/libraries.tcl
#
# The system linker passes the libraries codegen/aot.rs's
# `runtime_system_libraries` names after the runtime archive; rustc knows
# which ones the archive's code needs (`--print native-static-libs`). This
# builds native/runtime-archive with that flag (cargo relinks the archive in
# native/target/release: run it only where nothing is running the driver),
# reads the driver's `libraries` line of `botlish-native system-linker` and
# exits 1 unless the two are the same list. On Windows rustc's account
# also names the C runtime (`/defaultlib:...`), which is not one of the
# archive's libraries but the C runtime policy's (codegen/aot.rs's
# `crt_args_for`): those entries are left out of the comparison.
set native [file dirname [file dirname [file normalize [info script]]]]
set windows [expr {$::tcl_platform(platform) eq "windows"}]
set driver [file join $native target release botlish-native]
if {$windows} { append driver .exe }

set status [catch {
    exec cargo rustc --release --manifest-path [file join $native Cargo.toml] -p botlish-runtime -- --print native-static-libs 2>@1
} output]
if {$status && [lindex $::errorCode 0] ne "NONE"} {
    puts stderr "cargo rustc failed:\n$output"
    exit 1
}
set expected {}
foreach line [split $output \n] {
    if {[regexp {native-static-libs: (.*)$} [string trimright $line \r] -> libraries]} {
        set expected $libraries
    }
}
if {$expected eq ""} {
    puts stderr "rustc printed no native-static-libs line:\n$output"
    exit 1
}
if {$windows} {
    set expected [lmap library $expected {
        if {[string match -nocase /defaultlib:* $library]} continue
        set library
    }]
}

# The driver's facts; one that it cannot establish here (no linker on PATH)
# makes it exit 1, but every line is still printed.
catch {exec $driver system-linker} facts
set actual ""
set found 0
foreach line [split $facts \n] {
    set line [string trimright $line \r]
    if {[lindex $line 0] eq "libraries"} {
        set actual [lrange $line 1 end]
        set found 1
    }
}
if {!$found} {
    puts stderr "$driver system-linker printed no libraries line:\n$facts"
    exit 1
}
if {$expected ne $actual} {
    puts stderr "the runtime archive's system libraries changed: rustc says '$expected', the driver passes '$actual' (codegen/aot.rs's runtime_system_libraries)"
    exit 1
}
puts "runtime archive libraries: $actual (as rustc accounts for them)"
