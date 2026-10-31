# fuzz.tcl -- a fuzzer of synchronous C callbacks (C-CALLBACK-MILESTONE-1.md,
# "Fuzzing").
#
#   tclsh9.0 audit/c-callbacks/tools/fuzz.tcl ?-n N? ?-seed S? ?-callbacks K?
#                                             ?-gc-stress 0|1? ?-backends LIST?
#                                             ?-keep 0|1? ?-verbose 0|1?
#
# Each of N programs has K random `callback c fn`s and, for each, a C driver
# generated as real C (a static archive in a private directory) that calls
# it, through a std::ffi::c::FnPtr parameter declared noescape, a random
# number of times with arguments the generator chose:
#
#   * a random C signature of up to sixteen parameters -- every C integer
#     class at its limits and in between, C _Bool, raw C floats and doubles
#     of any bit pattern (signaling NaNs with payloads, both infinities,
#     negative zero, subnormals), pointers -- interleaved, so some pass the
#     argument registers of every convention; a result of one of those
#     classes, a Float64 (C double) or unit;
#   * the callback hands every argument back to C (fz_record_*: an integer
#     as its value, a raw value as its bits read in Botlish, a pointer as
#     itself), and returns the first argument of its result's class, or a
#     constant the generator chose;
#   * sometimes it allocates (a List of Strings, its length checked) and
#     sometimes it calls C, which calls a second callback back -- nested in
#     the same execution environment -- whose answer it checks.
#
# C is the oracle: the driver compares every recorded word with the one it
# passed and the result with the one it expects (floating values by their
# bits), and returns how many were wrong; Botlish's own checks record a fault
# C counts too. A program's value must be a list of zeros, on each native
# backend of BACKENDS, also under GC stress with -gc-stress 1 (a collection
# at every allocation, the callback's included).
#
# The last line is "programs N callbacks C calls K disagreements X" (exit
# status 1 on any); every disagreement is printed with its directory, kept
# unless -keep is 0.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set options [dict create -n 4 -seed 1 -callbacks 4 -gc-stress 0 -backends {cranelift-generic cranelift} -keep 1 -verbose 0]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}
set ::argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]

proc pick {list} { return [lindex $list [expr {int(rand() * [llength $list])}]] }
proc chance {p} { return [expr {rand() < $p}] }
proc between {lo hi} { return [expr {$lo + int(rand() * ($hi - $lo + 1))}] }

# The classes: Botlish type, C type, {kind bits signed}.
set ::classes {
    schar {std::ffi::c::SChar {signed char} {int 8 1}}
    uchar {std::ffi::c::UChar {unsigned char} {int 8 0}}
    short {std::ffi::c::Short short {int 16 1}}
    ushort {std::ffi::c::UShort {unsigned short} {int 16 0}}
    int {std::ffi::c::Int int {int 32 1}}
    uint {std::ffi::c::UInt {unsigned int} {int 32 0}}
    longlong {std::ffi::c::LongLong {long long} {int 64 1}}
    ulonglong {std::ffi::c::ULongLong {unsigned long long} {int 64 0}}
    bool {std::ffi::c::Bool bool {bool 1 0}}
    rawfloat {std::ffi::c::RawFloat float {raw 32 0}}
    rawdouble {std::ffi::c::RawDouble double {raw 64 0}}
    pointer {std::ffi::c::Ptr[std::ffi::c::Void] {void *} {ptr 64 0}}
}
proc botlishType {c} { return [lindex [dict get $::classes $c] 0] }
proc cType {c} { return [lindex [dict get $::classes $c] 1] }
proc kindOf {c} { return [lindex [dict get $::classes $c] 2] }

set ::float32Patterns {0x00000000 0x80000000 0x3fc00000 0x7f800000 0xff800000 0x7fc00000 0x7fc00123 0xffc00456 0x7f800001 0x7fa00abc 0x00000001 0x807fffff 0x7f7fffff}
set ::float64Patterns {0x0000000000000000 0x8000000000000000 0x3ff8000000000000 0x7ff0000000000000 0xfff0000000000000 0x7ff8000000000000 0x7ff8000000000123 0xfff8000000000456 0x7ff0000000000001 0x7ff4000000000abc 0x0000000000000001 0x800fffffffffffff 0x7fefffffffffffff}

# A random argument of class C, as the 64-bit word C records for it: an
# integer's value two's complement in 64 bits (sign-extended), a _Bool 0 or
# 1, a raw value's bits, an address.
proc argumentWord {c} {
    lassign [kindOf $c] kind bits signed
    switch -- $kind {
        int {
            if {$signed} {
                set lo [expr {-(1 << ($bits - 1))}]
                set hi [expr {(1 << ($bits - 1)) - 1}]
            } else {
                set lo 0
                set hi [expr {(1 << $bits) - 1}]
            }
            set v [pick [list $lo $hi 0 1 [expr {$signed ? -1 : 2}] [between $lo $hi] [between $lo $hi]]]
            return [expr {$v & 0xffffffffffffffff}]
        }
        bool { return [between 0 1] }
        raw {
            if {$bits == 32} {
                return [expr {[chance 0.7] ? [pick $::float32Patterns] : int(rand() * 4294967296)}]
            }
            return [expr {[chance 0.7] ? [pick $::float64Patterns] : (int(rand() * 4294967296) << 32) | int(rand() * 4294967296)}]
        }
        ptr { return [pick [list 0 0x1000 0x7ffffffff000 [expr {int(rand() * 0x7fffffff) * 16}]]] }
    }
}

# The C expression of class C whose word is WORD.
proc cValue {c word} {
    lassign [kindOf $c] kind bits signed
    switch -- $kind {
        int {
            if {$signed && $word >= (1 << 63)} {
                set v [expr {$word - (1 << 64)}]
                if {$v == -(1 << 63)} { return "([cType $c])INT64_MIN" }
                return "([cType $c])(${v}LL)"
            }
            return "([cType $c])${word}ULL"
        }
        bool { return [expr {$word ? "true" : "false"}] }
        raw { return [expr {$bits == 32 ? "fz_f32(${word}u)" : "fz_f64(${word}ULL)"}] }
        ptr { return "(void *)(uintptr_t)${word}ULL" }
    }
}

# The Botlish statement handing parameter NAME (class C) back as record J.
proc recordStatement {name c j} {
    lassign [kindOf $c] kind bits signed
    switch -- $kind {
        int {
            if {$bits == 64 && !$signed} { return "    record_bits($j, $name)\n" }
            return "    record_int($j, $name)\n"
        }
        bool { return "    if $name:\n        record_int($j, 1)\n    else:\n        record_int($j, 0)\n" }
        raw {
            set stem [expr {$bits == 32 ? "float" : "double"}]
            return "    record_bits($j, std::ffi::c::raw::${stem}_to_bits($name))\n"
        }
        ptr { return "    record_pointer($j, $name)\n" }
    }
}

# A random callback: {PARAMS RESULT RESULTSOURCE REPS ALLOC NEST}, PARAMS a
# list of {CLASS WORD}, RESULT a class, float64 or unit, RESULTSOURCE the
# parameter index it echoes or {constant WORD}.
proc drawCallback {} {
    set names [dict keys $::classes]
    set params {}
    for {set i 0} {$i < [between 0 16]} {incr i} {
        set c [pick $names]
        lappend params [list $c [argumentWord $c]]
    }
    set result [pick [concat $names float64 unit]]
    set source ""
    if {$result ni {unit float64 pointer}} {
        set i 0
        foreach p $params {
            if {[lindex $p 0] eq $result} { set source $i; break }
            incr i
        }
    }
    if {$source eq ""} {
        set source [list constant [expr {$result eq "float64" ? 0x4004000000000000 : ($result in {unit pointer} ? 0 : [argumentWord $result])}]]
    }
    return [list $params $result $source [between 1 6] [expr {[chance 0.5] ? [between 1 40] : 0}] [chance 0.4]]
}

# The Botlish expression of the constant WORD of class C.
proc botlishConstant {c word} {
    lassign [kindOf $c] kind bits signed
    switch -- $kind {
        int {
            if {$signed && $word >= (1 << 63)} { return [expr {$word - (1 << 64)}] }
            if {$signed && $bits < 64 && $word >= (1 << ($bits - 1))} { return [expr {$word - (1 << 64)}] }
            return $word
        }
        bool { return [expr {$word ? "true" : "false"}] }
        raw { return "std::ffi::c::raw::[expr {$bits == 32 ? "float" : "double"}]_from_bits($word)" }
    }
}

proc writeFile {path text} {
    file mkdir [file dirname $path]
    set channel [open $path w]
    fconfigure $channel -encoding utf-8 -translation lf
    puts -nonewline $channel $text
    close $channel
}

# The C source and the Botlish program of CALLBACKS, and the expected value.
proc programOf {callbacks} {
    set c "#include <stdbool.h>\n#include <stdint.h>\n#include <string.h>\n\n"
    append c "static float fz_f32(uint32_t b) { float f; memcpy(&f, &b, 4); return f; }\n"
    append c "static double fz_f64(uint64_t b) { double d; memcpy(&d, &b, 8); return d; }\n"
    append c "static uint32_t fz_b32(float f) { uint32_t b; memcpy(&b, &f, 4); return b; }\n"
    append c "static uint64_t fz_b64(double d) { uint64_t b; memcpy(&b, &d, 8); return b; }\n"
    append c "static uint64_t records\[33\];\nstatic bool recorded\[33\];\n"
    append c "static void fz_reset(void) { memset(recorded, 0, sizeof recorded); }\n"
    append c "void fz_record_int(int j, long long v) { if (j >= 0 && j < 33) { records\[j\] = (uint64_t)v; recorded\[j\] = true; } }\n"
    append c "void fz_record_bits(int j, unsigned long long v) { if (j >= 0 && j < 33) { records\[j\] = v; recorded\[j\] = true; } }\n"
    append c "void fz_record_pointer(int j, void *p) { if (j >= 0 && j < 33) { records\[j\] = (uint64_t)(uintptr_t)p; recorded\[j\] = true; } }\n"
    append c "int fz_nest(int (*f)(int), int x) { return f(x); }\n\n"
    set bot "import std::ffi::c\nimport std::ffi::c::raw\nimport std::int\nimport std::list\nimport std::str\n\n"
    append bot "extern c library \"botlish_callback_fuzz\"\n\n"
    append bot "extern c fn record_int named \"fz_record_int\"(index: std::ffi::c::Int, value: std::ffi::c::LongLong) -> unit\n"
    append bot "extern c fn record_bits named \"fz_record_bits\"(index: std::ffi::c::Int, bits: std::ffi::c::ULongLong) -> unit\n"
    append bot "extern c fn record_pointer named \"fz_record_pointer\"(index: std::ffi::c::Int, p: std::ffi::c::Ptr\[std::ffi::c::Void\] noescape) -> unit\n"
    append bot "extern c fn nest named \"fz_nest\"(f: std::ffi::c::FnPtr\[Fn\{args: \[std::ffi::c::Int\], return: std::ffi::c::Int\}\] noescape, x: std::ffi::c::Int) -> std::ffi::c::Int\n"
    set callbackDecls ""
    set binds ""
    set calls {}
    set k 0
    foreach cb $callbacks {
        lassign $cb params result source reps alloc nesting
        set cparams [lmap p $params {cType [lindex $p 0]}]
        set cresult [dict getdef {unit void float64 double} $result [expr {$result in {unit float64} ? "" : [cType $result]}]]
        set bparams [lmap p $params {botlishType [lindex $p 0]}]
        set bresult [dict getdef {unit unit float64 std::ffi::c::Double} $result [expr {$result in {unit float64} ? "" : [botlishType $result]}]]
        set fnptr "std::ffi::c::FnPtr\[Fn\{args: \[[join $bparams {, }]\], return: $bresult\}\]"
        append bot "extern c fn drive_$k named \"fz_drive_$k\"(f: $fnptr noescape, reps: std::ffi::c::Int) -> std::ffi::c::Int\n"
        # The C driver.
        append c "int fz_drive_$k\($cresult (*f)([expr {$cparams eq {} ? "void" : [join $cparams {, }]}]), int reps) \{\n    int wrong = 0;\n"
        append c "    for (int r = 0; r < reps; r++) \{\n        fz_reset();\n"
        set args [lmap p $params {cValue [lindex $p 0] [lindex $p 1]}]
        set call "f([join $args {, }])"
        if {$result eq "unit"} {
            append c "        $call;\n"
        } else {
            append c "        $cresult got = $call;\n"
            if {[lindex $source 0] eq "constant"} {
                set word [lindex $source 1]
            } else {
                set word [lindex $params $source 1]
            }
            switch -- $result {
                float64 { append c "        if (fz_b64(got) != ${word}ULL) wrong++;\n" }
                rawdouble { append c "        if (fz_b64(got) != ${word}ULL) wrong++;\n" }
                rawfloat { append c "        if (fz_b32(got) != ${word}u) wrong++;\n" }
                pointer { append c "        if ((uint64_t)(uintptr_t)got != ${word}ULL) wrong++;\n" }
                default { append c "        if (got != [cValue $result $word]) wrong++;\n" }
            }
        }
        set j 0
        foreach p $params {
            append c "        if (!recorded\[$j\] || records\[$j\] != [lindex $p 1]ULL) wrong++;\n"
            incr j
        }
        append c "        if (recorded\[32\]) wrong++;\n    \}\n    return wrong;\n\}\n\n"
        # The callback.
        set names {}
        set j 0
        foreach p $params { lappend names "p$j: [botlishType [lindex $p 0]]"; incr j }
        append callbackDecls "callback c fn cb_$k\([join $names {, }]) -> $bresult:\n"
        set j 0
        foreach p $params { append callbackDecls [recordStatement p$j [lindex $p 0] $j]; incr j }
        if {$alloc > 0} {
            append callbackDecls "    if churn($alloc) != $alloc:\n        record_int(32, 1)\n"
        }
        if {$nesting} {
            append callbackDecls "    l = std::ffi::c::callback(leaf)\n    if nest(l, 5) != 6:\n        record_int(32, 1)\n"
        }
        if {$result eq "unit"} {
            append callbackDecls "    unit\n\n"
        } elseif {[lindex $source 0] eq "constant"} {
            append callbackDecls "    [expr {$result eq "float64" ? "2.5" : ($result eq "pointer" ? "std::ffi::c::null\[std::ffi::c::Void\]()" : [botlishConstant $result [lindex $source 1]])}]\n\n"
        } else {
            append callbackDecls "    p$source\n\n"
        }
        append binds "    c$k = std::ffi::c::callback(cb_$k)\n"
        lappend calls "drive_$k\(c$k, $reps)"
        incr k
    }
    append bot "\nfn churn(n: int) -> int:\n    xs = loop i from 0 to n:\n        std::str::concat(\"fuzz-item-\", std::int::to_string(i))\n    std::list::length(xs)\n\n"
    append bot "callback c fn leaf(x: std::ffi::c::Int) -> std::ffi::c::Int:\n    if churn(3) != 3 or x > 1000 or x < -1000:\n        return 0\n    x + 1\n\n"
    append bot $callbackDecls
    append bot "fn run():\n$binds    \[[join $calls {, }]\]\n\nrun()\n"
    set expected "\[[join [lrepeat [llength $callbacks] 0] {, }]\]"
    return [list $c $bot $expected]
}

# The outcome text of HIR on BACKEND: the value, or "error CODE MESSAGE".
proc outcome {backend hir} {
    lassign [outcomeUnderHir $backend $hir] tag value message
    if {$tag eq "value"} { return $value }
    return "$tag $value $message"
}

expr {srand([dict get $options -seed])}
set scratch [file tempdir botlish-callback-fuzz-]
set programs 0
set callbackCount 0
set callCount 0
set disagreements 0
set canRun [expr {[auto_execok cc] ne "" && ![catch {native::binary}] && [testConstraint nativeCCalls]
    && [testConstraint nativeCCallbacks] && [testConstraint cLinker]}]
if {!$canRun} {
    puts "this host does not run C callbacks (or has no C compiler or native backend): nothing to fuzz"
    puts "programs 0 callbacks 0 calls 0 disagreements 0"
    exit 0
}
for {set p 0} {$p < [dict get $options -n]} {incr p} {
    set dir [file join $scratch p$p]
    file mkdir $dir
    set problem ""
    set callbacks [lmap i [lrepeat [dict get $options -callbacks] 0] {drawCallback}]
    lassign [programOf $callbacks] csource main expected
    writeFile [file join $dir fz.c] $csource
    writeFile [file join $dir main.bot] $main
    if {[dict get $options -gc-stress]} { set ::env(BOTLISH_NATIVE_GC_STRESS) 1 }
    if {[catch {
        exec cc -c -O2 -fPIC [file join $dir fz.c] -o [file join $dir fz.o]
        exec ar rcs [file join $dir libbotlish_callback_fuzz.a] [file join $dir fz.o]
    } message]} {
        append problem "\nthe C library did not build: $message"
    } elseif {[catch {surface::compile $main main.bot -warnings off} hir]} {
        append problem "\nthe program did not compile: $hir"
    } else {
        native::withLinkDirs [list $dir] {
            foreach backend [dict get $options -backends] {
                set got [outcome $backend $hir]
                if {$got ne $expected} {
                    append problem "\non $backend: expected $expected\n  got $got"
                }
            }
        }
    }
    unset -nocomplain ::env(BOTLISH_NATIVE_GC_STRESS)
    incr programs
    incr callbackCount [llength $callbacks]
    foreach cb $callbacks { incr callCount [lindex $cb 3] }
    set problem [string trim $problem]
    if {$problem ne ""} {
        incr disagreements
        puts "DISAGREEMENT program $p ($dir):\n$problem"
        if {![dict get $options -keep]} { file delete -force $dir }
    } else {
        if {[dict get $options -verbose]} { puts "program $p: ok" }
        file delete -force $dir
    }
}
if {$disagreements == 0} { file delete -force $scratch }
puts "programs $programs callbacks $callbackCount calls $callCount disagreements $disagreements"
exit [expr {$disagreements > 0}]
