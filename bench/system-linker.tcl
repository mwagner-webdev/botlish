# system-linker.tcl -- what the system linker costs, beside the rustc and
# stub linkers (SINGLE-EXECUTABLE-FFI-MILESTONE-1.md, "Link and startup
# benchmarks").
#
#   tclsh9.0 bench/system-linker.tcl ?-runs N? ?-single PATH?
#
# 1. Link, ms (best of RUNS): the driver's `object` (the program object
#    alone: Cranelift) and `executable` (object, startup and link) of a
#    program that calls no C and of one that calls libc and a static
#    library, with each linker that links it here; the system link's
#    command line; the program objects' sizes.
# 2. Executables: the file each linker makes of the two programs, as linked
#    and with `strip` (the stub's is never stripped: its image is appended),
#    and their dynamic dependencies.
# 3. Runs, ms (median of RUNS): the process's whole life for the program
#    that calls no C (startup to exit), a computation that allocates
#    (a 200000-element list of Strings, built and measured), the same under
#    BOTLISH_NATIVE_GC_STRESS=1 (a smaller one), and 200000 C calls.
# 4. With -single PATH (single/build.sh's executable): its size, the zip
#    entries' sizes, the first run that installs the native executables,
#    the first that also installs the runtime archive, a warm run, and
#    -version and -help.
set root [file dirname [file dirname [file normalize [info script]]]]
set args $argv
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]

set options [dict create -runs 5 -single ""]
foreach {option value} $args {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}
set runs [dict get $options -runs]
set host [core::cabi::hostTarget]
set windows [expr {$::tcl_platform(platform) eq "windows"}]
set work [file tempdir botlish-system-linker-bench]

proc writeFile {path text} {
    set f [open $path w]; fconfigure $f -encoding utf-8 -translation lf
    puts -nonewline $f $text; close $f
    return $path
}
# Milliseconds SCRIPT takes, best of RUNS (median with -median 1).
proc timed {script {median 0}} {
    set times {}
    for {set i 0} {$i < $::runs} {incr i} {
        set t [clock microseconds]
        uplevel 1 $script
        lappend times [expr {([clock microseconds] - $t) / 1000.0}]
    }
    set times [lsort -real $times]
    return [format %.1f [expr {$median ? [lindex $times [expr {[llength $times] / 2}]] : [lindex $times 0]}]]
}
proc withLinker {linker script} {
    set saved [array get ::env BOTLISH_NATIVE_LINKER]
    set ::env(BOTLISH_NATIVE_LINKER) $linker
    try {
        if {$::windows} { return [uplevel 1 [list ctool::withMsvc $script]] }
        return [uplevel 1 $script]
    } finally {
        if {$saved eq ""} { unset ::env(BOTLISH_NATIVE_LINKER) } else { set ::env(BOTLISH_NATIVE_LINKER) [lindex $saved 1] }
    }
}

# The programs: plain (portable output where the host has a Linux context),
# compute, and C (libc's labs and the fixture's bcf_add through a static
# library).
set io [dict get {linux-x86_64 linux linux-aarch64 linux macos-aarch64 darwin windows-x86_64 windows} $host]
set plain [writeFile [file join $work plain.bot] [string map [list IO $io] {import std::io
import std::IO::io

fn hello() errors std::io::WriteFailed:
    std::io::print_line("Hello, world!")

with context std::IO::io::create()

hello():
    on std::io::WriteFailed:
        unit
}]]
set compute [writeFile [file join $work compute.bot] {import std::list
import std::str

fn names(n: int):
    loop i from 0 to n:
        std::str::concat("item", "x")
names(200000).length()
}]
set stress [writeFile [file join $work stress.bot] {import std::list
import std::str

fn names(n: int):
    loop i from 0 to n:
        std::str::concat("item", "x")
names(2000).length()
}]
set lib [file join $work lib]
file mkdir $lib
ctool::staticLibrary $lib botlish_cffi_fixture [file join $root tests cffi fixture.c]
writeFile [file join $work m.bot] {import std::ffi::c

extern c library "botlish_cffi_fixture"

extern c fn labs(x: std::ffi::c::Long) -> std::ffi::c::Long
extern c fn add named "bcf_add"(a: std::ffi::c::Int, b: std::ffi::c::Int) -> std::ffi::c::Int
}
set cprog [writeFile [file join $work cprog.bot] {import std::ffi::c
import std::list
import m

fn calls(n: int):
    loop i from 0 to n:
        m::add(40, 2) + m::labs(0 - 2)
calls(200000).length()
}]

set linkers [list system]
if {[auto_execok rustc] ne ""} { lappend linkers rustc }
if {$host eq "linux-x86_64"} { lappend linkers stub }

puts "# System linker benchmarks ($host, [clock format [clock seconds] -format %Y-%m-%d], best or median of $runs)"
puts ""
puts "## 1. Link, ms"
puts ""
puts "| program | object | [join [lmap l $linkers {set l}] { | }] |"
puts "|---|---:|[string repeat ---:| [llength $linkers]]"
set exes [dict create]
foreach {name path} [list plain $plain c $cprog compute $compute stress $stress] {
    set hir [surface::readProgramFile $path -warnings off -cache ""]
    set nir [native::nir $hir]
    set nirFile [writeFile [file join $work $name.nir] $nir]
    set object [timed {exec [native::binary] object [file join $work $name.o] $nirFile}]
    set row [list $name $object]
    foreach linker $linkers {
        if {$name eq "c" && $linker eq "stub"} { lappend row "refused"; continue }
        set ms [native::withLinkDirs [list $lib] {
            withLinker $linker {
                timed {native::executable $hir [file join $work $name.$linker]}
            }
        }]
        dict set exes $name $linker [native::executableFile [file join $work $name.$linker]]
        lappend row $ms
    }
    if {$name in {plain c}} { puts "| [join $row { | }] |" }
}
puts ""
# The system link's command line for the C program (BOTLISH_NATIVE_LINK_LOG),
# the work directory's paths shortened.
set log [file join $work link.log]
set ::env(BOTLISH_NATIVE_LINK_LOG) $log
native::withLinkDirs [list $lib] {
    withLinker system { native::executable [surface::readProgramFile $cprog -warnings off -cache ""] [file join $work c.logged] }
}
unset ::env(BOTLISH_NATIVE_LINK_LOG)
set f [open $log]; set text [read $f]; close $f
puts "The system link of the C program:"
puts ""
puts "    [string map [list $work WORK [file dirname [native::binary]] RELEASE] [lindex [split $text \n] 0]]"
puts ""
puts "Program objects: plain [file size [file join $work plain.o]] bytes, c [file size [file join $work c.o]] bytes."
puts ""

puts "## 2. Executables, bytes"
puts ""
puts "| program | linker | as linked | stripped | dynamic dependencies |"
puts "|---|---|---:|---:|---|"
foreach name {plain c} {
    foreach linker $linkers {
        if {![dict exists $exes $name $linker]} continue
        set exe [dict get $exes $name $linker]
        set stripped -
        if {$linker ne "stub" && !$windows && [auto_execok strip] ne ""} {
            file copy -force $exe $exe.stripped
            exec strip $exe.stripped
            set stripped [file size $exe.stripped]
        }
        set deps -
        if {[string match linux-* $host]} {
            set deps [join [lmap line [split [exec readelf -d $exe] \n] {
                if {![regexp {\(NEEDED\).*\[(.*)\]} $line -> n]} continue
                set n
            }] {, }]
        } elseif {[string match macos-* $host]} {
            set deps [join [lmap line [lrange [split [exec otool -L $exe] \n] 1 end] {file tail [lindex [string trim $line] 0]}] {, }]
        }
        puts "| $name | $linker | [file size $exe] | $stripped | $deps |"
    }
}
puts ""

puts "## 3. Runs, ms (median)"
puts ""
puts "| run | [join $linkers { | }] |"
puts "|---|[string repeat ---:| [llength $linkers]]"
foreach {label name vars} {
    "process life (prints a line)" plain {}
    "200000 Strings built" compute {}
    "2000 Strings under GC stress" stress {BOTLISH_NATIVE_GC_STRESS 1}
    "200000 C calls (labs, bcf_add)" c {}
} {
    set row [list $label]
    foreach linker $linkers {
        if {![dict exists $exes $name $linker]} { lappend row -; continue }
        set exe [dict get $exes $name $linker]
        lappend row [withEnvironment $vars { timed {exec $exe} 1 }]
    }
    puts "| [join $row { | }] |"
}
puts ""

set single [dict get $options -single]
if {$single ne ""} {
    puts "## 4. The single executable"
    puts ""
    puts "[file size $single] bytes."
    if {[auto_execok unzip] ne ""} {
        catch {exec unzip -lv $single 2>/dev/null} listing
        foreach line [split $listing \n] {
            if {[regexp {^\s*(\d+)\s+\S+\s+(\d+)\s+\S+\s+\S+\s+\S+\s+\S+\s+(native-bin/\S+)$} $line -> size compressed name]} {
                puts "  $name: $size bytes, $compressed compressed"
            }
        }
    }
    set app [file join $work single]
    file mkdir $app
    file copy $plain [file join $app hello.bot]
    set home [file join $work home]
    set ms [timed {
        file delete -force $home
        exec env -i HOME=$home $single -warnings off -backend compile $compute
    } 1]
    puts "  first run (installs the driver and the stub; a compile run): $ms ms"
    set ms [timed {exec env -i HOME=$home $single -warnings off -backend compile $compute} 1]
    puts "  warm compile run: $ms ms"
    set ms [timed {
        file delete -force [glob -nocomplain [file join $home .cache botlish native-* libbotlish_runtime.a]]
        exec env -i HOME=$home PATH=[file dirname [lindex [auto_execok cc] 0]] $single -warnings off -L $lib -emit-native-executable $cprog
    } 1]
    puts "  first link of a C program (installs the runtime archive, then links): $ms ms"
    set ms [timed {exec env -i HOME=$home PATH=[file dirname [lindex [auto_execok cc] 0]] $single -warnings off -L $lib -emit-native-executable $cprog} 1]
    puts "  warm link of the C program: $ms ms"
    set ms [timed {exec env -i HOME=$home $single -warnings off -emit-native-executable [file join $app hello.bot]} 1]
    puts "  warm stub link of the plain program: $ms ms"
    foreach option {-version -help} {
        set ms [timed {exec env -i HOME=[file join $work nohome] $single $option} 1]
        puts "  $option: $ms ms (installs nothing: [expr {![file exists [file join $work nohome]]}])"
    }
}
file delete -force $work
