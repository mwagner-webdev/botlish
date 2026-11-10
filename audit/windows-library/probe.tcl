# probe.tcl -- the COFF/linker census of WINDOWS-X86-64-MILESTONE-8.md
# (section 3): how a Botlish native library becomes a Windows DLL, and why
# no static COFF library is shipped. Evidence for the report, not a test
# tier: it records what MSVC's tools do (every row printed) and fails only
# when it cannot run. Real Windows x86-64 with Visual Studio's x64 tools
# (vswhere, vcvars64.bat) and the native backend built:
#
#   tclsh9.0 audit/windows-library/probe.tcl ?-out DIR?
#
# Two libraries, `one` and `two`, from two programs that both define an
# error Negative and export twice() and tag(), are built:
#
#   E1  the production path (native::library: botlish-native library-dll,
#       a module-definition file, link.exe /DLL): the DLL's export table as
#       dumpbin reads it, its imports, and a C host that loads it with
#       LoadLibraryW and asks GetProcAddress for public and internal names;
#   E2  the same object and runtime archive linked with /EXPORT: options in
#       place of the module-definition file: the export tables compared;
#   E3  linked with neither: what the runtime archive and the program object
#       export by themselves (their .drectve directives);
#   E4  the import library lib.exe makes from the module-definition file
#       alone, against link.exe's;
#   E5  static libraries: each program object merged with the runtime
#       archive by lib.exe (one_static.lib, two_static.lib): one alone in an
#       executable, both in one executable (link.exe's duplicate symbols),
#       and both with /FORCE:MULTIPLE -- which links, one runtime copy
#       answering for both libraries, and isolation then fails (a buffer of
#       one released through two);
#   E6  the candidate mechanism for a sound static library: every symbol a
#       library's objects define, but its public functions, renamed with a
#       prefix of its own (llvm-objcopy --redefine-syms, when LLVM is
#       installed), the objects archived again; both in one executable.

set root [file dirname [file dirname [file dirname [file normalize [info script]]]]]
set options [dict create -out ""]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}
source [file join $root core core.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
source [file join $root tests ctoolchain.tcl]
core::useBackend interp

if {$::tcl_platform(platform) ne "windows" || ![ctool::available]} {
    puts "probe: needs Windows with MSVC's x64 tools (vswhere, vcvars64.bat)"
    exit 1
}

set out [dict get $options -out]
if {$out eq ""} {
    set out [file tempdir botlish-windows-library-probe]
}
file mkdir $out
puts "probe directory: $out"
set driver [native::binary]
set runtime [file join [file dirname $driver] botlish_runtime.lib]
puts "driver: $driver"
puts "runtime archive: $runtime ([file size $runtime] bytes)"

proc row {name text} {
    puts [format "%-28s %s" $name $text]
    flush stdout
}

proc write {path text} {
    set channel [open $path w]
    fconfigure $channel -encoding utf-8 -translation lf
    puts -nonewline $channel $text
    close $channel
}

# MSVC's tool TOOL with ARGS in vcvars64's environment: {STATUS OUTPUT}.
proc msvc {tool args} {
    set status [catch {ctool::msvc $tool {*}$args 2>@1} output]
    return [list $status $output]
}

proc firstLines {text n} {
    return [join [lrange [split [string map {"\r" ""} $text] \n] 0 [expr {$n - 1}]] " | "]
}

# The names dumpbin /exports lists for PE file PATH.
proc dumpbinExports {path} {
    lassign [msvc dumpbin /nologo /exports [file nativename $path]] status text
    return [lmap {- name} [regexp -all -inline -line {^\s+\d+\s+[0-9A-F]+\s+[0-9A-F]{8}\s+(\S+)} $text] {set name}]
}

set sources {
one {
import std::str

error Negative:
    value: int

exported c fn twice(n: int) -> int errors Negative:
    if n < 0:
        fail Negative {value: n}
    n * 2

exported c fn tag(text: str) -> str:
    std::str::concat("first:", text)
}
two {
import std::str
import std::list

error Negative:
    value: int
    why: str

exported c fn twice(n: int) -> int errors Negative:
    if n < 0:
        fail Negative {value: n, why: "second"}
    xs = loop i from 0 to n:
        i
    std::list::length(xs) * 3

exported c fn tag(text: str) -> str:
    std::str::concat(text, ":second")
}
}

set systemLibraries {legacy_stdio_definitions.lib kernel32.lib ntdll.lib userenv.lib ws2_32.lib dbghelp.lib}
set crt {libcmt.lib libvcruntime.lib libucrt.lib}
set noOther [lmap l {msvcrt.lib msvcrtd.lib vcruntime.lib vcruntimed.lib ucrt.lib ucrtd.lib libcmtd.lib libvcruntimed.lib libucrtd.lib} {string cat /NODEFAULTLIB:$l}]

# ---- E1: the production path, and each library's program object.
set built [dict create]
set public [dict create]
foreach {name source} $sources {
    set dir [file join $out $name]
    file mkdir $dir
    write [file join $dir $name.bot] $source
    set hir [surface::readProgramFile [file join $dir $name.bot] -warnings off -warning-channel ""]
    set started [clock milliseconds]
    dict set built $name [ctool::withMsvc [list native::library $hir -name $name -out $dir]]
    row "E1 $name build" "[expr {[clock milliseconds] - $started}] ms: [file size [dict get $built $name shared]]-byte DLL, [file size [dict get $built $name import]]-byte import library"
    set records [dict get $built $name exports]
    dict set public $name [native::library::PublicNames $name $records]
    write [file join $dir $name.nir] [native::nir $hir -exports [lmap r $records {
        dict create symbol ${name}_[dict get $r name] block [dict get $r block] params [lmap {p t} [dict get $r params] {set t}] result [dict get $r result]
    }]]
    exec $driver library [file join $dir $name.program.obj] $name [file join $dir $name.nir]
    set exports [dumpbinExports [dict get $built $name shared]]
    row "E1 $name exports" "[llength $exports] (public functions: [llength [dict get $public $name]]; equal: [expr {[lsort $exports] eq [lsort [dict get $public $name]]}])"
    set facts [native::pe::facts [dict get $built $name shared]]
    row "E1 $name imports" [join [dict get $facts imports] {, }]
    row "E1 $name TLS callbacks" "[llength [dict get $facts tlsCallbacks]], entry point RVA [format 0x%x [dict get $facts entry]]"
    lassign [msvc dumpbin /nologo /headers [file nativename [dict get $built $name shared]]] status headers
    foreach pattern {{size of stack reserve} {DLL characteristics} {Dynamic base} {NX compatible} {High Entropy Virtual Addresses}} {
        foreach line [split [string map {"\r" ""} $headers] \n] {
            if {[string match -nocase "*$pattern*" $line]} {
                row "E1 $name header" [string trim $line]
                break
            }
        }
    }
}

# A C host that loads `one` with LoadLibraryW and asks for public and
# internal names.
set hostDir [file join $out host]
file mkdir $hostDir
file copy -force [dict get $built one shared] $hostDir
set internal {botlish_library_call botlish_library_create botlish_program botlish_descriptor botlish_fn_0 botlish_entry_0
    rt_fail_declared rt_alloc_str main DllMain rust_begin_unwind}
write [file join $hostDir load.c] "#include <windows.h>
#include <stdio.h>
static const char *names\[\] = {[join [lmap n [concat [dict get $public one] $internal] {string cat \"$n\"}] {, }]};
int main(void) {
    HMODULE m = LoadLibraryW(L\"one.dll\");
    if (m == NULL) { printf(\"LoadLibraryW failed: %lu\\n\", GetLastError()); return 1; }
    for (size_t i = 0; i < sizeof names / sizeof *names; i++)
        printf(\"%s %s\\n\", names\[i\], GetProcAddress(m, names\[i\]) ? \"found\" : \"not-found\");
    printf(\"FreeLibrary %d\\n\", FreeLibrary(m));
    return 0;
}
"
lassign [msvc cl /nologo /W3 /Fe[file nativename [file join $hostDir load.exe]] /Fo[file nativename [file join $hostDir load.obj]] [file nativename [file join $hostDir load.c]]] status text
if {$status} {
    row "E1 GetProcAddress host" "did not build: [firstLines $text 4]"
} else {
    set lines [split [string map {"\r" ""} [exec [file join $hostDir load.exe]]] \n]
    set found [lmap l $lines {if {[lindex $l 1] ne "found"} continue; lindex $l 0}]
    set publicFound [lmap n [dict get $public one] {if {$n in $found} {set n} else continue}]
    set internalFound [lmap n $internal {if {$n in $found} {set n} else continue}]
    row "E1 GetProcAddress" "public found [llength $publicFound] of [llength [dict get $public one]]; internal found [llength $internalFound] of [llength $internal][expr {$internalFound eq "" ? "" : " ($internalFound)"}]"
}

# ---- E2: /EXPORT options instead of the module-definition file.
set dir [file join $out one]
set exportArgs [lmap n [dict get $public one] {string cat /EXPORT:$n}]
lassign [msvc link /NOLOGO /DLL /MACHINE:X64 /INCREMENTAL:NO /OPT:REF /OPT:ICF /NXCOMPAT /DYNAMICBASE \
    /OUT:[file nativename [file join $dir e2.dll]] /IMPLIB:[file nativename [file join $dir e2.lib]] {*}$exportArgs \
    [file nativename [file join $dir one.program.obj]] [file nativename $runtime] {*}$systemLibraries {*}$crt {*}$noOther] status text
if {$status} {
    row "E2 /EXPORT link" "failed: [firstLines $text 6]"
} else {
    set e2 [dumpbinExports [file join $dir e2.dll]]
    row "E2 /EXPORT exports" "[llength $e2]; the same names as the .def build: [expr {[lsort $e2] eq [lsort [dumpbinExports [dict get $built one shared]]]}]; the DLL's name in its export directory: [dict get [native::pe::facts [file join $dir e2.dll]] exportName]"
}

# ---- E3: neither: what the inputs export by themselves.
lassign [msvc link /NOLOGO /DLL /MACHINE:X64 /INCREMENTAL:NO /OPT:REF /NXCOMPAT /DYNAMICBASE \
    /OUT:[file nativename [file join $dir e3.dll]] \
    [file nativename [file join $dir one.program.obj]] [file nativename $runtime] {*}$systemLibraries {*}$crt {*}$noOther] status text
if {$status} {
    row "E3 no exports" "link failed: [firstLines $text 6]"
} else {
    set e3 [dumpbinExports [file join $dir e3.dll]]
    row "E3 no exports" "[llength $e3] exported; import library made: [file exists [file join $dir e3.lib]]; link said: [firstLines $text 3]"
}
lassign [msvc dumpbin /nologo /directives [file nativename [file join $dir one.program.obj]]] status text
row "E3 object directives" [expr {[regexp -nocase {/EXPORT} $text] ? "the program object has /EXPORT directives" : "the program object has no /EXPORT directive"}]

# ---- E4: lib.exe's import library from the .def alone.
write [file join $dir e4.def] "LIBRARY one.dll\nEXPORTS\n[join [lmap n [dict get $public one] {string cat "    " $n}] \n]\n"
lassign [msvc lib /NOLOGO /MACHINE:X64 /DEF:[file nativename [file join $dir e4.def]] /OUT:[file nativename [file join $dir e4.lib]]] status text
if {$status} {
    row "E4 lib /DEF" "failed: [firstLines $text 4]"
} else {
    set a [lsort [native::pe::importLibrary [file join $dir e4.lib]]]
    set b [lsort [native::pe::importLibrary [dict get $built one import]]]
    row "E4 lib /DEF" "import objects equal to link's: [expr {[dict get [native::pe::importLibrary [file join $dir e4.lib]] imports] eq [dict get [native::pe::importLibrary [dict get $built one import]] imports]}]"
}

# ---- E5: static libraries merged by lib.exe.
set host5 [file join $out static]
file mkdir $host5
foreach name {one two} {
    lassign [msvc lib /NOLOGO /OUT:[file nativename [file join $host5 ${name}_static.lib]] \
        [file nativename [file join $out $name $name.program.obj]] [file nativename $runtime]] status text
    row "E5 $name static library" [expr {$status ? "lib.exe failed: [firstLines $text 4]" : "[file size [file join $host5 ${name}_static.lib]] bytes"}]
    file copy -force [file join $out $name $name.h] $host5
}
write [file join $host5 both.c] {#include <stdio.h>
#include <string.h>
#include "one.h"
#include "two.h"
int main(void) {
    one_instance *a; two_instance *b; int64_t r1 = 0, r2 = 0; one_bytes oa;
    if (one_create(&a, NULL) || two_create(&b, NULL)) { printf("create failed\n"); return 1; }
    one_twice(a, 21, &r1, NULL); two_twice(b, 21, &r2, NULL);
    one_tag(a, (const uint8_t *) "z", 1, &oa, NULL);
    int32_t cross = two_bytes_release((two_bytes *) &oa);
    printf("twice: %lld %lld; one's buffer released through two: %d%s\n", (long long) r1, (long long) r2, (int) cross,
        cross == 0 ? " (accepted: one runtime answers for both)" : " (refused)");
    if (cross != 0) one_bytes_release(&oa);
    one_destroy(a); two_destroy(b);
    return 0;
}
}
write [file join $host5 one_only.c] {#include <stdio.h>
#include "one.h"
int main(void) {
    one_instance *a; int64_t r = 0;
    if (one_create(&a, NULL)) return 1;
    one_twice(a, 21, &r, NULL);
    printf("twice: %lld\n", (long long) r);
    one_destroy(a);
    return 0;
}
}
proc staticHost {dir name source libs extra} {
    lassign [msvc cl /nologo /W3 /c /Done_API= /Dtwo_API= /I[file nativename $dir] /Fo[file nativename [file join $dir $name.obj]] [file nativename [file join $dir $source]]] status text
    if {$status} { return [list compile $text] }
    lassign [msvc link /NOLOGO /OUT:[file nativename [file join $dir $name.exe]] [file nativename [file join $dir $name.obj]] \
        {*}[lmap l $libs {file nativename [file join $dir $l]}] {*}$::systemLibraries {*}$::crt {*}$::noOther {*}$extra] status text
    if {$status} { return [list link $text] }
    set status [catch {exec [file join $dir $name.exe] 2>@1} output]
    return [list [expr {$status ? "run-failed" : "ran"}] "$text\n$output"]
}
lassign [staticHost $host5 one_only one_only.c {one_static.lib} {}] outcome text
row "E5 one static, alone" "$outcome: [firstLines [string trim $text] 3]"
lassign [staticHost $host5 both both.c {one_static.lib two_static.lib} {}] outcome text
set duplicates [regexp -all {LNK2005} $text]
row "E5 both static" "$outcome: $duplicates LNK2005 (already defined) errors; first: [firstLines [lindex [regexp -inline -line {^.*LNK2005.*$} $text] 0] 1]"
lassign [staticHost $host5 forced both.c {one_static.lib two_static.lib} {/FORCE:MULTIPLE}] outcome text
row "E5 both, /FORCE:MULTIPLE" "$outcome: [regexp -all {LNK4006} $text] LNK4006 warnings; [firstLines [lindex [split [string trim $text] \n] end] 1]"

# ---- E6: the candidate: private symbols renamed per library (LLVM's
# objcopy), the objects archived again.
set llvm ""
foreach candidate [list [auto_execok llvm-objcopy] {C:/Program Files/LLVM/bin/llvm-objcopy.exe}] {
    if {$candidate ne "" && [file exists [lindex $candidate 0]]} { set llvm [file dirname [lindex $candidate 0]]; break }
}
if {$llvm eq ""} {
    row "E6 renamed static" "skipped: no llvm-objcopy"
} else {
    set host6 [file join $out renamed]
    file mkdir $host6
    foreach name {one two} {
        set work [file join $host6 $name]
        file mkdir $work
        # The runtime archive's members, each extracted by lib.exe to a name
        # of ours (their own names are a Rust build's absolute paths).
        lassign [msvc lib /NOLOGO /LIST [file nativename $runtime]] status listing
        set members [lsearch -all -inline -not -exact [split [string map {"\r" ""} $listing] \n] ""]
        set objects [list [file join $out $name $name.program.obj]]
        set index 0
        foreach member $members {
            set extracted [file join $work m[incr index].obj]
            lassign [msvc lib /NOLOGO /EXTRACT:$member /OUT:[file nativename $extracted] [file nativename $runtime]] status text
            if {!$status} { lappend objects $extracted }
        }
        # A short import object (the standard library's and windows-sys'
        # raw-dylib imports: Sig1 0, Sig2 0xFFFF, Version 0) names a DLL's
        # function: kept as it is, its symbols never renamed.
        set imports {}
        set plain {}
        foreach object $objects {
            set channel [open $object rb]
            set head [read $channel 6]
            close $channel
            if {[binary scan $head susu sig1 sig2] == 2 && $sig1 == 0 && $sig2 == 0xffff
                    && [binary scan $head @4su version] == 1 && $version == 0} {
                lappend imports $object
            } else {
                lappend plain $object
            }
        }
        set objects $plain
        set renamedObjects($name) $imports
        set defined {}
        foreach object $objects {
            catch {exec [file join $llvm llvm-nm.exe] --defined-only --extern-only --format=just-symbols $object} names
            lappend defined {*}[split [string map {"\r" ""} $names] \n]
        }
        set defined [lsort -unique [lmap n $defined {if {$n eq "" || $n in [dict get $public $name] || [string match *:* $n]} continue; set n}]]
        write [file join $host6 $name.map] [join [lmap n $defined {string cat $n " " ${name}__ $n}] \n]\n
        set failed 0
        foreach object $objects {
            set renamed [file join $work [file tail $object].renamed.obj]
            if {[catch {exec [file join $llvm llvm-objcopy.exe] --redefine-syms=[file join $host6 $name.map] $object $renamed} message]} {
                incr failed
            } else {
                lappend renamedObjects($name) $renamed
            }
        }
        lassign [msvc lib /NOLOGO /OUT:[file nativename [file join $host6 ${name}_static.lib]] {*}[lmap o $renamedObjects($name) {file nativename $o}]] status text
        row "E6 $name renamed" "[llength $defined] defined symbols renamed in [llength $objects] objects ([expr {$failed}] failed), [llength $imports] import objects kept; archive: [expr {$status ? "failed [firstLines $text 3]" : "[file size [file join $host6 ${name}_static.lib]] bytes"}]"
        file copy -force [file join $out $name $name.h] $host6
    }
    file copy -force [file join $host5 both.c] $host6
    lassign [staticHost $host6 both both.c {one_static.lib two_static.lib} {}] outcome text
    row "E6 both renamed static" "$outcome: [regexp -all {LNK2005} $text] LNK2005, [regexp -all {LNK2019} $text] LNK2019; [firstLines [lindex [split [string trim $text] \n] end] 1]"
}
puts "probe done"
