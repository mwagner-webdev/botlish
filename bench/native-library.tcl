# native-library.tcl -- what a native library costs (NATIVE-LIBRARY-
# MILESTONE-1.md, section 12; WINDOWS-X86-64-MILESTONE-8.md, "Performance
# and size"): its build, its artifacts' sizes, loading it, an instance's
# creation and destruction, and the boundary's cost per call -- an Int, a
# Float64, a short and a longer String, an export that allocates, a
# declared error -- against a small C library of the same functions built
# by the host's own C compiler, plainly and under GC stress.
#
#   tclsh9.0 bench/native-library.tcl ?-calls N? ?-rounds R?
#
# Linux (cc, the shared library through dlopen) and Windows x86-64 (MSVC's
# cl, the DLL through LoadLibraryW, in vcvars64's environment). Every figure
# is the best of R rounds of N calls on this machine: compare figures of one
# run, not raw times of two hosts. Prints a table.

set root [file dirname [file dirname [file normalize [info script]]]]
source [file join $root core core.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
source [file join $root tests ctoolchain.tcl]
core::useBackend interp

set options [dict create -calls 200000 -rounds 5]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}
set windows [expr {$::tcl_platform(platform) eq "windows"}]
if {![native::hostSupports libraries] || ![ctool::available]} {
    puts "native-library bench: this host builds no native libraries, or has no C toolchain"
    exit 1
}

proc write {path text} {
    set channel [open $path w]
    fconfigure $channel -encoding utf-8 -translation lf
    puts -nonewline $channel $text
    close $channel
}

set dir [file tempdir botlish-native-library-bench]
set source {
import std::list
import std::str

error Negative:
    value: int

exported c fn add(a: int, b: int) -> int:
    a + b

exported c fn scale(x: Float64) -> Float64 errors NonFiniteFloat:
    x * 1.5

exported c fn echo(text: str) -> str:
    text

exported c fn words(n: int) -> int:
    if n < 0 or n > 100000:
        return 0
    xs = loop i from 0 to n:
        std::str::concat("w", "x")
    std::list::length(xs)

exported c fn fail_if(n: int) -> int errors Negative:
    if n < 0:
        fail Negative {value: n}
    n
}
write [file join $dir bench.bot] $source
set hir [surface::readProgramFile [file join $dir bench.bot] -warnings off -warning-channel ""]
set lib [file join $dir lib]
set started [clock milliseconds]
if {$windows} {
    set built [ctool::withMsvc [list native::library $hir -name bl -out $lib]]
} else {
    set built [native::library $hir -name bl -out $lib]
}
set buildMs [expr {[clock milliseconds] - $started}]

# The C reference: the same functions as C, the same calling convention
# (a status, the result through a pointer, a String as an owned malloc'd
# copy released by the library), in a shared library of its own.
set reference [file join $dir cref.c]
write $reference {#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#ifdef _WIN32
#define API __declspec(dllexport)
#else
#define API __attribute__((visibility("default")))
#endif
typedef struct { uint8_t *ptr; size_t len; } cref_bytes;
API int32_t cref_add(void *in, int64_t a, int64_t b, int64_t *out, void **e) { (void) in; (void) e; *out = a + b; return 0; }
API int32_t cref_scale(void *in, double x, double *out, void **e) { (void) in; (void) e; *out = x * 1.5; return 0; }
API int32_t cref_echo(void *in, const uint8_t *p, size_t n, cref_bytes *out, void **e) {
    (void) in; (void) e;
    out->ptr = malloc(n + 1); memcpy(out->ptr, p, n); out->ptr[n] = 0; out->len = n; return 0;
}
API int32_t cref_bytes_release(cref_bytes *b) { free(b->ptr); b->ptr = NULL; b->len = 0; return 0; }
API int32_t cref_words(void *in, int64_t n, int64_t *out, void **e) {
    (void) in; (void) e;
    char **xs = malloc(sizeof(char *) * (size_t) (n > 0 ? n : 1));
    for (int64_t i = 0; i < n; i++) { xs[i] = malloc(3); memcpy(xs[i], "wx", 3); }
    for (int64_t i = 0; i < n; i++) free(xs[i]);
    free(xs); *out = n; return 0;
}
API int32_t cref_fail_if(void *in, int64_t n, int64_t *out, void **e) { (void) in; if (n < 0) { if (e) *e = NULL; return 1; } *out = n; return 0; }
}
lassign [ctool::sharedLibrary $lib cref $reference] crefLibrary crefLink

set host [file join $dir host.c]
write $host [string map [list CALLS [dict get $options -calls] ROUNDS [dict get $options -rounds]] {#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include "bl.h"
#ifdef _WIN32
#include <windows.h>
static double now(void) { LARGE_INTEGER f, c; QueryPerformanceFrequency(&f); QueryPerformanceCounter(&c); return (double) c.QuadPart / (double) f.QuadPart; }
static void *load(const char *path) { return (void *) LoadLibraryA(path); }
static void unload(void *m) { FreeLibrary((HMODULE) m); }
#define REF_IMPORT __declspec(dllimport)
#else
#include <dlfcn.h>
#include <time.h>
static double now(void) { struct timespec t; clock_gettime(CLOCK_MONOTONIC, &t); return (double) t.tv_sec + (double) t.tv_nsec * 1e-9; }
static void *load(const char *path) { return dlopen(path, RTLD_NOW | RTLD_LOCAL); }
static void unload(void *m) { dlclose(m); }
#define REF_IMPORT
#endif
typedef struct { uint8_t *ptr; size_t len; } cref_bytes;
REF_IMPORT int32_t cref_add(void *, int64_t, int64_t, int64_t *, void **);
REF_IMPORT int32_t cref_scale(void *, double, double *, void **);
REF_IMPORT int32_t cref_echo(void *, const uint8_t *, size_t, cref_bytes *, void **);
REF_IMPORT int32_t cref_bytes_release(cref_bytes *);
REF_IMPORT int32_t cref_words(void *, int64_t, int64_t *, void **);
REF_IMPORT int32_t cref_fail_if(void *, int64_t, int64_t *, void **);
#define N CALLS
#define R ROUNDS
static char longer[4097];
static bl_instance *in;
static double best(double (*f)(int), int which) {
    double b = 1e30;
    for (int r = 0; r < R; r++) { double t = f(which); if (t < b) b = t; }
    return b;
}
static double botlish(int which) {
    int64_t r = 0; double x = 0; bl_bytes out; bl_error *e = NULL;
    double t0 = now();
    for (int i = 0; i < N; i++) {
        switch (which) {
        case 0: bl_add(in, i, 2, &r, NULL); break;
        case 1: bl_scale(in, 2.0, &x, NULL); break;
        case 2: bl_echo(in, (const uint8_t *) "short text", 10, &out, NULL); bl_bytes_release(&out); break;
        case 3: bl_echo(in, (const uint8_t *) longer, 4096, &out, NULL); bl_bytes_release(&out); break;
        case 4: bl_words(in, 16, &r, NULL); break;
        case 5: bl_fail_if(in, -1, &r, &e); bl_error_release(&e); break;
        }
    }
    return (now() - t0) / N * 1e9;
}
static double reference(int which) {
    int64_t r = 0; double x = 0; cref_bytes out; void *e = NULL;
    double t0 = now();
    for (int i = 0; i < N; i++) {
        switch (which) {
        case 0: cref_add(NULL, i, 2, &r, NULL); break;
        case 1: cref_scale(NULL, 2.0, &x, NULL); break;
        case 2: cref_echo(NULL, (const uint8_t *) "short text", 10, &out, NULL); cref_bytes_release(&out); break;
        case 3: cref_echo(NULL, (const uint8_t *) longer, 4096, &out, NULL); cref_bytes_release(&out); break;
        case 4: cref_words(NULL, 16, &r, NULL); break;
        case 5: cref_fail_if(NULL, -1, &r, &e); break;
        }
    }
    return (now() - t0) / N * 1e9;
}
int main(int argc, char **argv) {
    /* ARGV[1]: a copy of the library under another name, which this
       process has not loaded: each load is a real one. */
    if (argc < 2) return 2;
    memset(longer, 'a', 4096);
    double load_best = 1e30, create_best = 1e30;
    for (int r = 0; r < R; r++) {
        double t0 = now();
        for (int i = 0; i < 20; i++) { void *m = load(argv[1]); if (m == NULL) return 3; unload(m); }
        double t = (now() - t0) / 20 * 1e6;
        if (t < load_best) load_best = t;
        t0 = now();
        for (int i = 0; i < 200; i++) { bl_instance *x; bl_create(&x, NULL); bl_destroy(x); }
        t = (now() - t0) / 200 * 1e6;
        if (t < create_best) create_best = t;
    }
    printf("load and unload\t%.1f us\n", load_best);
    printf("create and destroy\t%.1f us\n", create_best);
    if (bl_create(&in, NULL) != bl_STATUS_OK) return 1;
    const char *names[] = {"int (add)", "Float64 (scale)", "short str (echo, 10 bytes)", "longer str (echo, 4 KiB)", "allocating (words(16))", "declared error (fail_if)"};
    for (int w = 0; w < 6; w++)
        printf("%s\t%.1f ns\t%.1f ns\n", names[w], best(botlish, w), best(reference, w));
    bl_destroy(in);
    return 0;
}
}]
if {$windows} {
    set exe [file join $lib host.exe]
    ctool::msvc cl /nologo /O2 /W3 /std:c11 /MT /I[file nativename $lib] /Fo[file nativename [file join $dir host.obj]] \
        /Fe[file nativename $exe] [file nativename $host] [file nativename [dict get $built import]] [file nativename $crefLink]
} else {
    set exe [file join $dir host]
    exec cc -O2 -I$lib $host -L$lib -lbl -lcref -Wl,-rpath,$lib -ldl -o $exe
}

# A copy of the shared library under a name this host never loads, for the
# load measurement.
set loadCopy [file join $lib [expr {$windows ? "blload.dll" : "libblload.so"}]]
file copy -force [dict get $built shared] $loadCopy

proc runHost {exe stress} {
    if {$stress} { set ::env(BOTLISH_NATIVE_GC_STRESS) 1 } else { unset -nocomplain ::env(BOTLISH_NATIVE_GC_STRESS) }
    try {
        return [string map {"\r" ""} [exec $exe [file nativename $::loadCopy]]]
    } finally {
        unset -nocomplain ::env(BOTLISH_NATIVE_GC_STRESS)
    }
}

set plain [runHost $exe 0]
set stressed [runHost $exe 1]

# The same work inside Botlish, for the boundary's share of a call: an
# executable that runs `add` and `words(16)` CALLS times in a fold carrying
# an Int (nothing collected), against the same executable running no
# iteration (its startup), best of ROUNDS each. (A program's loop may inline or fold what a C call cannot: this is
# what a call costs from Botlish code, not a measure of the same machine
# instructions.)
proc executableMicros {source rounds} {
    set path [file join $::dir loop.bot]
    write $path $source
    set exe [native::executable [surface::readProgramFile $path -warnings off -warning-channel ""] [file join $::dir loop]]
    set best 1e30
    for {set r 0} {$r < $rounds} {incr r} {
        set t0 [clock microseconds]
        exec $exe
        set t [expr {[clock microseconds] - $t0}]
        if {$t < $best} { set best $t }
    }
    return $best
}
set loopSource {
import std::list
import std::str

fn add(a: int, b: int) -> int:
    a + b

fn words(n: int) -> int:
    if n < 0 or n > 100000:
        return 0
    xs = loop i from 0 to n:
        std::str::concat("w", "x")
    std::list::length(xs)

fn run(calls: int, which: int) -> int:
    fold i from 0 to calls with intermediate total 0:
        if which == 0:
            total + add(i, 2) - i
        else:
            total + words(16)

run(CALLS, WHICH)
}
set calls [dict get $options -calls]
set rounds [dict get $options -rounds]
set inside {}
foreach which {0 1} {
    set empty [executableMicros [string map [list CALLS 0 WHICH $which] $loopSource] $rounds]
    set full [executableMicros [string map [list CALLS $calls WHICH $which] $loopSource] $rounds]
    lappend inside [format %.1f [expr {($full - $empty) * 1000.0 / $calls}]]
}

set shared [dict get $built shared]
puts "native library performance and size ([core::cabi::hostTarget], [dict get $options -calls] calls, best of [dict get $options -rounds])"
puts ""
puts "| Measure | Value |"
puts "|---|---:|"
puts "| build (native::library, five exports) | $buildMs ms |"
puts "| shared library ([file tail $shared]) | [file size $shared] bytes |"
if {$windows} {
    puts "| import library ([file tail [dict get $built import]]) | [file size [dict get $built import]] bytes |"
    set facts [native::pe::facts $shared]
    puts "| exported functions | [llength [dict get $facts exports]] |"
} else {
    puts "| static archive ([file tail [dict get $built static]]) | [file size [dict get $built static]] bytes |"
    set exports [lmap line [split [exec nm -D --defined-only $shared] \n] {if {[string match *bl_* $line]} {set line} else continue}]
    puts "| exported functions | [llength $exports] |"
    set locals [llength [lmap line [split [exec nm [dict get $built static]] \n] {if {[regexp {^\S+ [tTdDbBrR] } $line]} {set line} else continue}]]
    puts "| symbols defined in the archive's one object (the private runtime and the program) | $locals |"
}
puts "| C reference library ([file tail $crefLibrary]) | [file size $crefLibrary] bytes |"
foreach line [split $plain \n] {
    lassign [split $line \t] name value
    if {$name in {{load and unload} {create and destroy}}} {
        set under [lindex [split [lsearch -inline [split $stressed \n] "$name\t*"] \t] 1]
        puts "| $name | $value (GC stress: $under) |"
    }
}
puts ""
puts "| Call | Botlish | Botlish, GC stress | the C reference |"
puts "|---|---:|---:|---:|"
foreach line [split $plain \n] {
    lassign [split $line \t] name value ref
    if {$ref eq ""} continue
    set under [lindex [split [lsearch -inline [split $stressed \n] "$name\t*"] \t] 1]
    puts "| $name | $value | $under | $ref |"
}
puts ""
puts "| The same function called from Botlish code (an executable's loop, per iteration) | |"
puts "|---|---:|"
puts "| int (add) | [lindex $inside 0] ns |"
puts "| allocating (words(16)) | [lindex $inside 1] ns |"
file delete -force $dir
