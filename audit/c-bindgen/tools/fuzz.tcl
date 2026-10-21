# fuzz.tcl -- a fuzzer of the binding generator against an independent ABI
# model (C-BINDGEN.md, "Fuzzing").
#
#   tclsh9.0 audit/c-bindgen/tools/fuzz.tcl ?-n N? ?-seed S? ?-functions K?
#                                           ?-gc-stress 0|1? ?-keep 0|1?
#                                           ?-verbose 0|1?
#
# Each of N programs is a fresh C library: a header fz.h of K random
# declarations from the subset the generator binds, plus a few it must
# refuse, and its implementation fz.c. The fuzzer then runs the generator
# (tools/c-bindgen/lib.tcl, a profile whose headers are that directory) for
# the host's target, stages the generated binding beside a Botlish program
# calling every bound function once, compiles the binding and the shim, and
# runs the program on both native backends. What it checks, each against
# this file's own model -- its own table of what every C type is on LP64
# Linux, its own C arithmetic, never the generator's or the compiler's:
#
#   * every declaration it drew as representable is bound, under its own
#     name and its C link symbol (a `named` symbol for an asm label), and
#     every one it drew as unrepresentable (long double, a struct by value,
#     a va_list, a variadic function only a thunk could reach) is reported
#     unsupported with the expected blocker;
#   * every variadic prototype (`T f(FIXED..., ...)`, VARIADICS-VERTICAL-
#     SLICE-1.md) is bound directly as a variadic extern, and called once
#     with trailing arguments of drawn C types (every integer scalar, _Bool,
#     a handle pointer, a double from a Float64) that its genuine stdarg
#     body reads back with va_arg of the type C's default argument
#     promotions give;
#   * every bound function's ABI classes (the HIR foreign table: what the
#     generator's declaration means to the C FFI) are the model's for its C
#     signature: typedefs through the stdint/stddef names, enums by their
#     enumerators' signs, _Bool, C float and double (f32 and f64, also
#     through typedef chains; C-FLOAT-FFI-MILESTONE-1.md), pointers to opaque
#     structs and bytes;
#   * every constant (integer macros with every suffix and casts to the
#     typedefs, enumerators) has the model's C type and value;
#   * every call's result, and what C saw of every argument, equal the
#     model's -- including static inline functions through their thunks and
#     macro aliases through their symbols. A C float or double is compared
#     by its bits (C stores what it received; a floating result reaches C
#     again, as a double, to be read back as bits): a float argument is the
#     model's own rounding of the Float64 (an integer-arithmetic oracle, to
#     nearest, ties to even), a float result widened exactly.
#
# The last line is "programs N declarations D variadic V trailing T
# disagreements X" (V variadic prototypes called with T trailing arguments
# in all; the exit status is 1 on any disagreement); every disagreement is
# printed with its directory, kept unless -keep is 0.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set options [dict create -n 10 -seed 1 -functions 12 -gc-stress 0 -keep 1 -verbose 0]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}
set ::argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
source [file join $root tools c-bindgen lib.tcl]

proc pick {list} { return [lindex $list [expr {int(rand() * [llength $list])}]] }
proc chance {p} { return [expr {rand() < $p}] }
proc between {lo hi} { return [expr {$lo + int(rand() * ($hi - $lo + 1))}] }

set target [core::cabi::hostTarget]
set charSigned [expr {$target ne "linux-aarch64"}]

# The model: C spelling -> {ABI class, bits, signed, the ffi::c scalar} on
# LP64 Linux; the stdint/stddef names a header may use -> their C type.
set ctypes [dict create \
    char [list [expr {$charSigned ? "i8" : "u8"}] 8 $charSigned Char] \
    {signed char} {i8 8 1 SChar} {unsigned char} {u8 8 0 UChar} \
    short {i16 16 1 Short} {unsigned short} {u16 16 0 UShort} \
    int {i32 32 1 Int} {unsigned int} {u32 32 0 UInt} \
    long {i64 64 1 Long} {unsigned long} {u64 64 0 ULong} \
    {long long} {i64 64 1 LongLong} {unsigned long long} {u64 64 0 ULongLong}]
set stdints [dict create \
    int8_t {signed char} uint8_t {unsigned char} int16_t short uint16_t {unsigned short} \
    int32_t int uint32_t {unsigned int} int64_t long uint64_t {unsigned long} \
    size_t {unsigned long} ptrdiff_t long intptr_t long uintptr_t {unsigned long}]

# The C floating types: spelling -> {ABI class, bytes}.
set floatings [dict create float {f32 4} double {f64 8}]

# The bits of the binary32 nearest the finite double X, rounded to nearest,
# ties to even, by integer arithmetic on X's bits alone (a zero of either
# sign is +0); X must be below the binary32 overflow threshold.
proc narrow32 {x} {
    binary scan [binary format q $x] wu bits
    set negative [expr {$bits >> 63}]
    set e [expr {($bits >> 52) & 0x7ff}]
    set f [expr {$bits & 0xfffffffffffff}]
    if {$e == 0} {
        set m $f
        set exp -1074
    } else {
        set m [expr {$f | (1 << 52)}]
        set exp [expr {$e - 1075}]
    }
    if {$m == 0} { return 0 }
    set length 0
    for {set t $m} {$t > 0} {set t [expr {$t >> 1}]} { set length [expr {$length + 1}] }
    set q [expr {max($exp + $length - 1 - 23, -149)}]
    set shift [expr {$q - $exp}]
    if {$shift <= 0} {
        set k [expr {$m << -$shift}]
    } else {
        set k [expr {$m >> $shift}]
        set rest [expr {$m - ($k << $shift)}]
        set half [expr {1 << ($shift - 1)}]
        if {$rest > $half || ($rest == $half && ($k & 1))} { set k [expr {$k + 1}] }
    }
    if {$k == (1 << 24)} {
        set k [expr {1 << 23}]
        set q [expr {$q + 1}]
    }
    if {$k == 0} { return 0 }
    set out [expr {$k < (1 << 23) ? $k : ((($q + 150) << 23) | ($k - (1 << 23)))}]
    return [expr {($negative << 31) | $out}]
}

# The binary64 bits of the double X, and of the binary32 of bits B widened.
proc bits64 {x} {
    binary scan [binary format q $x] wu bits
    return $bits
}
proc widened {b} {
    binary scan [binary format iu $b] r x
    return $x
}

# A finite double for a floating argument, below 1e30 in magnitude (so twice
# it plus a half never overflows a float): ties of a binary32, subnormal
# binary32s, values a float cannot hold exactly, tiny negative numbers (a
# float's +0), arbitrary ones.
proc floatingValue {} {
    switch -- [between 0 5] {
        0 { return [pick {0.1 0.3333333333333333 16777217.0 1.0000000596046448 1.0000001788139343 1.401298464324817e-45 2.1019476964872256e-45 1.0e-40 -1.0e-50 0.0 -2.5}] }
        1 { return [expr {((1 << 23) | ([between 0 4194303] << 1) | 1) * 2.0 ** ([between -150 60]) * 0.5}] }
        2 { return [expr {[between 0 63] * 2.0 ** -149 + [between -1 1] * 2.0 ** -170}] }
        default { return [expr {(rand() - 0.5) * 2.0 ** [between -130 98]}] }
    }
}

proc bounds {ctype} {
    lassign [dict get $::ctypes $ctype] class bits signed
    if {$signed} { return [list [expr {-(2 ** ($bits - 1))}] [expr {2 ** ($bits - 1) - 1}]] }
    return [list 0 [expr {2 ** $bits - 1}]]
}

proc valueOf {ctype} {
    lassign [bounds $ctype] lo hi
    if {[chance 0.5]} {
        set v [pick [list $lo [expr {$lo + 1}] -1 0 1 [expr {$hi - 1}] $hi]]
        if {$v >= $lo && $v <= $hi} { return $v }
    }
    return [expr {$lo + entier(rand() * ($hi - $lo + 1))}]
}

# C's conversion of the unsigned 64-bit N to CTYPE.
proc convert {n ctype} {
    if {$ctype eq "_Bool"} { return [expr {$n != 0}] }
    lassign [dict get $::ctypes $ctype] class bits signed
    set v [expr {$n % (2 ** $bits)}]
    if {$signed && $v >= 2 ** ($bits - 1)} { set v [expr {$v - 2 ** $bits}] }
    return $v
}

# Draws program P's declarations. A scalar type is {spelling SPELLED ctype C}
# (SPELLED: a C type, a stdint name, a typedef of the header or an enum's
# typedef); every declaration a dict with its kind.
proc drawProgram {p k} {
    set typedefs {}
    set enums {}
    set n [between 1 4]
    for {set i 0} {$i < $n} {incr i} {
        set base [expr {[chance 0.5] ? [pick [dict keys $::stdints]] : [pick [dict keys $::ctypes]]}]
        lappend typedefs [dict create name fz_t$i base $base]
    }
    set n [between 0 2]
    for {set i 0} {$i < $n} {incr i} {
        set negative [chance 0.4]
        set values {}
        set v [expr {$negative ? -[between 1 1000] : [between 0 100]}]
        set count [between 1 4]
        for {set j 0} {$j < $count} {incr j} {
            lappend values $v
            incr v [between 1 1000]
        }
        lappend enums [dict create name fz_e$i values $values]
    }
    # Floating typedefs, possibly chained (fz_ft1 a typedef of fz_ft0).
    set ftypedefs {}
    set count [between 0 3]
    for {set i 0} {$i < $count} {incr i} {
        if {[llength $ftypedefs] && [chance 0.4]} {
            set of [pick $ftypedefs]
            lappend ftypedefs [dict create name fz_ft$i base [dict get $of name] ctype [dict get $of ctype]]
        } else {
            set ctype [pick {float double}]
            lappend ftypedefs [dict create name fz_ft$i base $ctype ctype $ctype]
        }
    }
    set ::ftypedefs $ftypedefs
    set decls {}
    for {set i 0} {$i < $k} {incr i} {
        set r [expr {rand()}]
        if {$r < 0.12} {
            lappend decls [dict create kind unsupported name fz_u$i shape [pick {longdouble struct va-list variadic-thunk}]]
            continue
        }
        if {$r < 0.2} {
            # A variadic prototype: one to three fixed parameters, and the
            # trailing arguments its one call passes (at most 16 seen values).
            # The last fixed parameter is va_start's, whose type must be its
            # own promoted type (C11 7.16.1.4): none narrower than int, and
            # no float (a double's).
            set params {}
            set n [between 1 3]
            for {set j 0} {$j < $n} {incr j} {
                set t [drawType $typedefs $enums 1]
                while {$j == $n - 1 && ([dict get $t kind] eq "bool"
                        || ([dict get $t kind] eq "floating" && [dict get $t ctype] eq "float")
                        || ([dict get $t kind] eq "scalar" && [lindex [dict get $::ctypes [dict get $t ctype]] 1] < 32))} {
                    set t [drawType $typedefs $enums 1]
                }
                lappend params $t
            }
            set trailing {}
            set count [pick [list 0 1 2 [between 3 8] [between 6 12]]]
            for {set j 0} {$j < $count} {incr j} {
                lappend trailing [drawTrailing]
            }
            set result [expr {[chance 0.15] ? [dict create kind void] : [drawType $typedefs $enums 0]}]
            set seen [expr {[llength $params] + [llength $trailing]}]
            lappend decls [dict create kind variadic name fz_v$i params $params trailing $trailing result $result \
                from [between -1 [expr {$seen - 1}]] add [between 0 1000]]
            continue
        }
        set params {}
        set count [pick [list 0 1 2 3 [between 4 9] [between 9 12]]]
        for {set j 0} {$j < $count} {incr j} {
            lappend params [drawType $typedefs $enums 1]
        }
        set result [expr {[chance 0.15] ? [dict create kind void] : [drawType $typedefs $enums 0]}]
        set kind [expr {$r < 0.28 ? "inline" : ($r < 0.34 ? "labeled" : "plain")}]
        lappend decls [dict create kind $kind name fz_f$i params $params result $result \
            from [expr {[llength $params] ? [between -1 [expr {[llength $params] - 1}]] : -1}] add [between 0 1000]]
    }
    # Object-like aliases of drawn plain functions.
    set aliases {}
    foreach d $decls {
        if {[dict get $d kind] eq "plain" && [chance 0.25]} {
            lappend aliases [dict create name [string map {fz_f fz_alias} [dict get $d name]] of [dict get $d name]]
        }
    }
    # Integer constants: literals with every suffix, casts to the typedefs.
    set constants {}
    set count [between 1 6]
    for {set i 0} {$i < $count} {incr i} {
        if {[chance 0.3] && [llength $typedefs]} {
            set t [pick $typedefs]
            set ctype [TypedefC $t]
            set v [valueOf $ctype]
            lappend constants [dict create name FZ_C$i text "((fz_t[lsearch $typedefs $t])($v))" ctype $ctype value $v]
            continue
        }
        lassign [pick {{"" int} {u {unsigned int}} {l long} {ul {unsigned long}} {ll {long long}} {ull {unsigned long long}}}] suffix ctype
        lassign [bounds $ctype] lo hi
        set v [between 0 [expr {min($hi, 2000000000)}]]
        if {[chance 0.2]} { set v $hi }
        set text $v$suffix
        if {$ctype eq "int" && [chance 0.3]} {
            set v [expr {-$v}]
            set text "($v)"
        }
        lappend constants [dict create name FZ_C$i text $text ctype $ctype value $v]
    }
    return [dict create typedefs $typedefs ftypedefs $ftypedefs enums $enums decls $decls aliases $aliases constants $constants]
}

proc TypedefC {t} {
    set base [dict get $t base]
    return [expr {[dict exists $::stdints $base] ? [dict get $::stdints $base] : $base}]
}

# A drawn value type: a scalar (spelled one of several ways), _Bool, an
# enum, a C float or double (by its name or a typedef chain), or (a
# parameter) an opaque handle pointer or a read byte pointer.
proc drawType {typedefs enums param} {
    set r [expr {rand()}]
    if {$r < 0.1} { return [dict create kind bool spelled bool ctype _Bool] }
    if {$r < 0.18 && [llength $enums]} {
        set e [pick $enums]
        set ctype [expr {[lindex [lsort -integer [dict get $e values]] 0] < 0 ? "int" : "unsigned int"}]
        return [dict create kind scalar spelled [dict get $e name] ctype $ctype]
    }
    if {$param && $r < 0.26} { return [dict create kind handle spelled "fz_handle *"] }
    if {$param && $r < 0.32} { return [dict create kind bytes spelled "const unsigned char *"] }
    if {$r < 0.42} {
        if {[llength $::ftypedefs] && [chance 0.5]} {
            set t [pick $::ftypedefs]
            return [dict create kind floating spelled [dict get $t name] ctype [dict get $t ctype]]
        }
        set ctype [pick {float double}]
        return [dict create kind floating spelled $ctype ctype $ctype]
    }
    if {$r < 0.5 && [llength $typedefs]} {
        set t [pick $typedefs]
        return [dict create kind scalar spelled [dict get $t name] ctype [TypedefC $t]]
    }
    if {$r < 0.7} {
        set name [pick [dict keys $::stdints]]
        return [dict create kind scalar spelled $name ctype [dict get $::stdints $name]]
    }
    set ctype [pick [dict keys $::ctypes]]
    return [dict create kind scalar spelled $ctype ctype $ctype]
}

# A drawn trailing argument of a variadic call: an integer scalar of any C
# type, a _Bool, a handle pointer or a double (a Float64, which a variadic
# call passes as one). Its C type after the default argument promotions
# (what the callee's va_arg names) is the model's (promotedC).
proc drawTrailing {} {
    set r [expr {rand()}]
    if {$r < 0.1} { return [dict create kind bool ctype _Bool] }
    if {$r < 0.2} { return [dict create kind handle] }
    if {$r < 0.3} { return [dict create kind floating ctype double] }
    return [dict create kind scalar ctype [pick [dict keys $::ctypes]]]
}

# The C type a trailing argument T reaches a variadic callee as: an integer
# narrower than int (and _Bool) is int, every other one itself, a pointer a
# pointer (C11 6.5.2.2p6-7).
proc promotedC {t} {
    switch -- [dict get $t kind] {
        bool { return int }
        handle { return "fz_handle *" }
        floating { return double }
    }
    set ctype [dict get $t ctype]
    if {[lindex [dict get $::ctypes $ctype] 1] < 32} { return int }
    return $ctype
}

# The header and the implementation of program PROG.
proc cFiles {prog} {
    set h "#ifndef FZ_H\n#define FZ_H\n#include <stdarg.h>\n#include <stdbool.h>\n#include <stddef.h>\n#include <stdint.h>\n\n"
    append h "typedef struct fz_handle fz_handle;\nunsigned long long fz_seen_at(int i);\nfz_handle *fz_cell(int k);\n"
    append h "unsigned long long fz_handle_index(fz_handle *h);\nextern unsigned long long fz_seen\[16\];\n"
    append h "unsigned long long fz_dbits(double x);\n"
    foreach t [dict get $prog typedefs] { append h "typedef [dict get $t base] [dict get $t name];\n" }
    foreach t [dict get $prog ftypedefs] { append h "typedef [dict get $t base] [dict get $t name];\n" }
    foreach e [dict get $prog enums] {
        set items {}
        set i 0
        foreach v [dict get $e values] { lappend items "[string toupper [dict get $e name]]_$i = $v"; incr i }
        append h "typedef enum [dict get $e name] { [join $items {, }] } [dict get $e name];\n"
    }
    foreach c [dict get $prog constants] { append h "#define [dict get $c name] [dict get $c text]\n" }
    set c "#include \"fz/fz.h\"\n\nstruct fz_handle { int id; };\nstatic struct fz_handle fz_cells\[8\];\nunsigned long long fz_seen\[16\];\n"
    append c "unsigned long long fz_seen_at(int i) { return fz_seen\[i\]; }\nfz_handle *fz_cell(int k) { return &fz_cells\[k\]; }\n"
    append c "unsigned long long fz_handle_index(fz_handle *h) { return h ? (unsigned long long)(h - fz_cells) + 1 : 0; }\n"
    append c "unsigned long long fz_dbits(double x) { union { double d; unsigned long long u; } q; q.d = x; return q.u; }\n\n"
    foreach d [dict get $prog decls] {
        set name [dict get $d name]
        if {[dict get $d kind] eq "unsupported"} {
            switch -- [dict get $d shape] {
                longdouble { append h "long double ${name}(long double x);\n"; append c "long double ${name}(long double x) { return x; }\n" }
                struct { append h "typedef struct ${name}_s { int a; } ${name}_s;\nint ${name}(${name}_s s);\n"; append c "int ${name}(${name}_s s) { return s.a; }\n" }
                va-list { append h "int ${name}(int n, va_list ap);\n"; append c "int ${name}(int n, va_list ap) { (void)ap; return n; }\n" }
                variadic-thunk { append h "static inline int ${name}(int n, ...) { return n; }\n" }
            }
            continue
        }
        set formals {}
        set body {}
        set j 0
        foreach param [dict get $d params] {
            lappend formals "[dict get $param spelled] a$j"
            switch -- [dict get $param kind] {
                handle { append body "    fz_seen\[$j\] = fz_handle_index(a$j);\n" }
                bytes { append body "    fz_seen\[$j\] = a$j\[0\] + 256ull * a$j\[1\];\n" }
                floating {
                    if {[dict get $param ctype] eq "float"} {
                        append body "    { union { float f; unsigned int u; } q; q.f = a$j; fz_seen\[$j\] = q.u; }\n"
                    } else {
                        append body "    { union { double d; unsigned long long u; } q; q.d = a$j; fz_seen\[$j\] = q.u; }\n"
                    }
                }
                default { append body "    fz_seen\[$j\] = (unsigned long long)a$j;\n" }
            }
            incr j
        }
        if {[dict get $d kind] eq "variadic"} {
            # The genuine stdarg body: each trailing argument read with
            # va_arg of its promoted type, in order.
            lappend formals ...
            append body "    va_list ap;\n    va_start(ap, a[expr {$j - 1}]);\n"
            foreach t [dict get $d trailing] {
                if {[dict get $t kind] eq "handle"} {
                    append body "    fz_seen\[$j\] = fz_handle_index(va_arg(ap, fz_handle *));\n"
                } elseif {[dict get $t kind] eq "floating"} {
                    append body "    fz_seen\[$j\] = fz_dbits(va_arg(ap, double));\n"
                } else {
                    append body "    fz_seen\[$j\] = (unsigned long long)va_arg(ap, [promotedC $t]);\n"
                }
                incr j
            }
            append body "    va_end(ap);\n"
        }
        set result [dict get $d result]
        set rtype [expr {[dict get $result kind] eq "void" ? "void" : ([dict get $result kind] eq "handle" ? "fz_handle *" : [dict get $result spelled])}]
        if {[dict get $result kind] eq "floating"} {
            # Twice a floating argument plus a half, in double (the doubling
            # is exact, so a contraction to a fused multiply-add changes
            # nothing), then converted to the result type; without one, the
            # constant ADD + 0.5.
            if {[FloatingSource $d] >= 0} {
                append body "    return ($rtype)((double)a[FloatingSource $d] * 2.0 + 0.5);\n"
            } else {
                append body "    return ($rtype)[dict get $d add].5;\n"
            }
        } elseif {[dict get $result kind] ne "void"} {
            set base [expr {[dict get $d from] < 0 ? "0ull" : "fz_seen\[[dict get $d from]\]"}]
            append body "    return ($rtype)($base * 3ull + [dict get $d add]ull);\n"
        }
        if {$formals eq ""} { set formals void }
        set proto "$rtype ${name}([join $formals {, }])"
        switch -- [dict get $d kind] {
            inline { append h "static inline $proto {\n$body}\n" }
            labeled {
                append h "$proto __asm__(\"${name}_impl\");\n"
                append c "$proto {\n$body}\n"
            }
            plain - variadic {
                append h "$proto;\n"
                append c "$proto {\n$body}\n"
            }
        }
    }
    foreach a [dict get $prog aliases] { append h "#define [dict get $a name] [dict get $a of]\n" }
    append h "#endif\n"
    return [list $h $c]
}

# The index of the floating parameter of D a floating result is computed
# from: D's `from` when it names a fixed parameter that is floating, else
# -1 (a variadic call's trailing double is never the source).
proc FloatingSource {d} {
    set from [dict get $d from]
    if {$from >= 0 && $from < [llength [dict get $d params]]
            && [dict get [lindex [dict get $d params] $from] kind] eq "floating"} {
        return $from
    }
    return -1
}

# The model's ABI class of a drawn type.
proc abiClass {t} {
    switch -- [dict get $t kind] {
        void { return void }
        bool { return bool }
        handle - bytes { return ptr }
        floating { return [lindex [dict get $::floatings [dict get $t ctype]] 0] }
        default { return [lindex [dict get $::ctypes [dict get $t ctype]] 0] }
    }
}

# Whether a call of D declares NonFiniteFloat: a C float parameter or a C
# floating result (C-FLOAT-FFI-MILESTONE-1.md).
proc Fallible {d} {
    if {[dict get $d result kind] eq "floating"} { return 1 }
    foreach q [dict get $d params] {
        if {[dict get $q kind] eq "floating" && [dict get $q ctype] eq "float"} { return 1 }
    }
    return 0
}

# The program calling every bound function of PROG, and the model's value
# of it.
proc program {prog} {
    # A handle parameter has no contract (unknown escape, which retains):
    # calling one is direct authority, which the program acknowledges.
    # So does a pointer passed as a trailing argument of a variadic call.
    set direct 0
    set scalars {}
    foreach d [dict get $prog decls] {
        if {[dict get $d kind] eq "unsupported"} continue
        foreach q [concat [dict get $d params] [dict getdef $d trailing {}]] {
            if {[dict get $q kind] eq "handle"} { set direct 1 }
        }
        foreach q [dict getdef $d trailing {}] {
            if {[dict get $q kind] eq "scalar"} { lappend scalars [lindex [dict get $::ctypes [dict get $q ctype]] 3] }
        }
    }
    set text [expr {$direct ? "direct module\n\n" : ""}]
    append text "import abi\nimport abi::bytes\nimport byte\nimport ffi::c\nimport fz::fz\n"
    set thunks 0
    foreach d [dict get $prog decls] { if {[dict get $d kind] eq "inline"} { set thunks 1 } }
    if {$thunks} { append text "import fz::thunks::fz\n" }
    append text "\nfn bit(b: bool) -> int:\n    if b:\n        return 1\n    0\n\n"
    append text "fn byte_of(n: int) -> byte::Byte:\n    if n >= 0 and n <= 255:\n        return n\n    0\n\n"
    # A trailing argument of a variadic call carries its own C type: an
    # integer literal enters it through a converter of that scalar.
    foreach s [lsort -unique $scalars] {
        append text "fn c_$s\(n: ffi::c::$s) -> ffi::c::$s:\n    n\n\n"
    }
    set elements {}
    set model {}
    set calls [concat [dict get $prog decls] [lmap a [dict get $prog aliases] {
        set d [lsearch -inline -index 1 [lmap x [dict get $prog decls] {list $x [dict get $x name]}] [dict get $a of]]
        set d [lindex $d 0]
        dict set d name [dict get $a name]
        dict set d alias 1
        set d
    }]]
    set i 0
    foreach d $calls {
        if {[dict get $d kind] eq "unsupported"} continue
        set args {}
        set seen {}
        set values {}
        set j 0
        foreach param [dict get $d params] {
            switch -- [dict get $param kind] {
                bool {
                    set v [chance 0.5]
                    lappend args [expr {$v ? "true" : "false"}]
                    lappend seen $v
                }
                handle {
                    set cell [between 0 7]
                    append text "h${i}_$j = fz::fz::fz_cell($cell)\n"
                    lappend args h${i}_$j
                    lappend seen [expr {$cell + 1}]
                }
                bytes {
                    set a [between 0 255]
                    set b [between 0 255]
                    append text "b${i}_$j = abi::bytes::from_list(\[byte_of($a), byte_of($b)\])\n"
                    lappend args b${i}_$j
                    lappend seen [expr {$a + 256 * $b}]
                }
                floating {
                    set v [floatingValue]
                    lappend args [format %.16e $v]
                    lappend values $j $v
                    lappend seen [expr {[dict get $param ctype] eq "float" ? [narrow32 $v] : [bits64 $v]}]
                }
                default {
                    set v [valueOf [dict get $param ctype]]
                    lappend args $v
                    lappend seen [expr {$v % (2 ** 64)}]
                }
            }
            incr j
        }
        foreach t [dict getdef $d trailing {}] {
            switch -- [dict get $t kind] {
                bool {
                    set v [chance 0.5]
                    lappend args [expr {$v ? "true" : "false"}]
                    lappend seen $v
                }
                handle {
                    set cell [between 0 7]
                    append text "h${i}_$j = fz::fz::fz_cell($cell)\n"
                    lappend args h${i}_$j
                    lappend seen [expr {$cell + 1}]
                }
                floating {
                    set v [floatingValue]
                    lappend args [format %.16e $v]
                    lappend seen [bits64 $v]
                }
                default {
                    set v [valueOf [dict get $t ctype]]
                    lappend args "c_[lindex [dict get $::ctypes [dict get $t ctype]] 3]($v)"
                    lappend seen [expr {$v % (2 ** 64)}]
                }
            }
            incr j
        }
        set module [expr {[dict get $d kind] eq "inline" ? "fz::thunks::fz" : "fz::fz"}]
        set result [dict get $d result]
        set call "$module\::[dict get $d name]([join $args {, }])"
        if {[Fallible $d]} {
            # A C float argument or a C floating result declares
            # NonFiniteFloat (which no call here raises).
            switch -- [dict get $result kind] {
                void { set fallback unit }
                bool { set fallback false }
                floating { set fallback -7.0 }
                default { set fallback 0 }
            }
            append text "r$i = $call:\n    on NonFiniteFloat:\n        $fallback\n"
        } else {
            append text "r$i = $call\n"
        }
        set base [expr {[dict get $d from] < 0 ? 0 : [lindex $seen [dict get $d from]]}]
        set raw [expr {($base * 3 + [dict get $d add]) % (2 ** 64)}]
        switch -- [dict get $result kind] {
            void {}
            bool { lappend elements "bit(r$i)"; lappend model [convert $raw _Bool] }
            floating {
                # What C computed, in double, from what it received.
                set source [FloatingSource $d]
                if {$source >= 0} {
                    set x [dict get $values $source]
                    if {[dict get [lindex [dict get $d params] $source] ctype] eq "float"} {
                        set x [widened [narrow32 $x]]
                    }
                    set y [expr {$x * 2.0 + 0.5}]
                } else {
                    set y [expr {[dict get $d add] + 0.5}]
                }
                if {[dict get $result ctype] eq "float"} {
                    set y [widened [narrow32 $y]]
                }
                lappend elements "fz::fz::fz_dbits(r$i)"
                lappend model [bits64 $y]
            }
            default { lappend elements "r$i"; lappend model [convert $raw [dict get $result ctype]] }
        }
        # What C saw, read right after the call (the next call overwrites it).
        set k 0
        foreach s $seen {
            append text "s${i}_$k = fz::fz::fz_seen_at($k)\n"
            lappend elements s${i}_$k
            lappend model $s
            incr k
        }
        incr i
    }
    foreach c [dict get $prog constants] {
        lappend elements "fz::fz::[dict get $c name]"
        lappend model [dict get $c value]
    }
    append text "\[[join $elements {, }]\]\n"
    return [list $text "\[[join $model {, }]\]"]
}

proc writeFile {path text} {
    file mkdir [file dirname $path]
    set channel [open $path w]
    fconfigure $channel -encoding utf-8 -translation lf
    puts -nonewline $channel $text
    close $channel
}

# The checks of the generation of PROG (report rows, foreign table, constant
# types) against the model: a list of problems.
proc checkGeneration {prog result hir} {
    set problems {}
    set rows [::cbind::generate::readTsv [dict get $result files report.tsv]]
    set foreign [hir::foreign::declarations $hir]
    foreach d [dict get $prog decls] {
        set name [dict get $d name]
        if {![dict exists $rows "function $name"]} {
            lappend problems "$name: no report row"
            continue
        }
        set row [dict get $rows "function $name"]
        if {[dict get $d kind] eq "unsupported"} {
            set want [dict get {longdouble long-double struct by-value-aggregate va-list va-list variadic-thunk variadic} [dict get $d shape]]
            if {[lindex $row 2] ne "unsupported" || $want ni [split [lindex $row 4] ,]} {
                lappend problems "$name: expected unsupported $want, the report says [lrange $row 2 4]"
            }
            continue
        }
        set status [expr {[dict get $d kind] eq "inline" ? "thunk" : "direct"}]
        if {[lindex $row 2] ne $status} {
            lappend problems "$name: expected $status, the report says [lrange $row 2 5]"
            continue
        }
        set module [expr {$status eq "thunk" ? "fz::thunks::fz" : "fz::fz"}]
        set key $module\::$name
        if {![dict exists $foreign $key]} {
            lappend problems "$name: not in the compiled binding's foreign table"
            continue
        }
        set f [dict get $foreign $key]
        set symbol [expr {[dict get $d kind] eq "labeled" ? "${name}_impl" : ($status eq "thunk" ? "botlish_fz_$name" : $name)}]
        if {[dict get $f symbol] ne $symbol} {
            lappend problems "$name: symbol [dict get $f symbol], the model's $symbol"
        }
        set abi [dict create params [lmap p [dict get $d params] {abiClass $p}] result [abiClass [dict get $d result]]]
        if {[dict get $d kind] eq "variadic"} {
            dict set abi variadic 1
        }
        if {[dict get $f abi] ne $abi} {
            lappend problems "$name: ABI [dict get $f abi], the model's $abi"
        }
    }
    foreach a [dict get $prog aliases] {
        set key fz::fz::[dict get $a name]
        if {![dict exists $foreign $key] || [dict get $foreign $key symbol] ne [dict get $a of]} {
            lappend problems "[dict get $a name]: not bound as an alias of [dict get $a of]"
        }
    }
    foreach c [dict get $prog constants] {
        set row [dict get $rows "macro [dict get $c name]"]
        set want "ffi::c::[lindex [dict get $::ctypes [dict get $c ctype]] 3]"
        if {[lindex $row 2] ne "constant" || [lindex $row 4] ne $want || [lindex $row 5] ne "[dict get $c ctype] [dict get $c value]"} {
            lappend problems "[dict get $c name]: expected $want [dict get $c ctype] [dict get $c value], the report says [lrange $row 2 5]"
        }
    }
    return $problems
}

expr {srand([dict get $options -seed])}
set scratch [file tempdir botlish-cbindgen-fuzz-]
set programs 0
set declarations 0
set variadics 0
set trailingArgs 0
set disagreements 0
set config [::chdr::toolchain::configFor $target]
for {set p 0} {$p < [dict get $options -n]} {incr p} {
    set prog [drawProgram $p [dict get $options -functions]]
    set dir [file join $scratch p$p]
    lassign [cFiles $prog] h c
    writeFile [file join $dir src include fz fz.h] $h
    writeFile [file join $dir src fz.c] $c
    set profile [::cbind::profile::Validate [dict create name fz path [file join $dir profile] \
        headers [dict create library fz source [list local [file join $dir src]] includeDirs include \
            public {include/fz/*} entry {fz/fz.h}] \
        targets [list $target] libraries {{names {fz}}} \
        evidence none]]
    writeFile [dict get $profile path] "# a fuzz program's binding profile\n[list dict create {*}$profile]\n"
    # Every byte parameter is read noescape (C reads two bytes): the
    # binding author's statement, one per function.
    set contracts [dict create]
    foreach d [dict get $prog decls] {
        if {[dict get $d kind] eq "unsupported"} continue
        set j 0
        foreach q [dict get $d params] {
            if {[dict get $q kind] eq "bytes"} { dict set contracts [dict get $d name] a$j {read noescape} }
            incr j
        }
    }
    foreach a [dict get $prog aliases] {
        if {[dict exists $contracts [dict get $a of]]} { dict set contracts [dict get $a name] [dict get $contracts [dict get $a of]] }
    }
    dict set profile contracts $contracts
    set problem ""
    if {[catch {::cbind::generate::run $profile $target} result]} {
        set problem "generation failed: $result"
    } else {
        ::cbind::generate::write [dict get $result files] [file join $dir out] fz
        lassign [program $prog] main expected
        set app [file join $dir app]
        ::cbind::generate::stage $profile $target "" $app [file join $dir out]
        writeFile [file join $app main.bot] $main
        set lib [file join $dir lib]
        file mkdir $lib
        set tool [dict create includeDirs [list [file join $dir src include]] defines {} undefines {} flags {}]
        lassign [::chdr::toolchain::object $config $tool [file join $dir src fz.c] [file join $lib fz.o] {-O2 -fPIC}] ok stderr
        lassign [::chdr::toolchain::archive $config [list [file join $lib fz.o]] [file join $lib libfz.a]] ok2 stderr2
        set shim [::cbind::generate::buildShim $profile $target [file join $dir shim] [file join $dir out]]
        if {!$ok || !$ok2} {
            set problem "the C library did not build: $stderr $stderr2"
        } elseif {[catch {surface::readProgramFile [file join $app main.bot] -warnings off -cache ""} hir]} {
            set problem "the program did not compile: $hir"
        } else {
            set problem [join [checkGeneration $prog $result $hir] \n]
            if {[dict get $options -gc-stress]} { set ::env(BOTLISH_NATIVE_GC_STRESS) 1 }
            native::withLinkDirs [concat [list $lib] [expr {$shim eq "" ? {} : [list $shim]}]] {
                foreach backend {cranelift cranelift-generic} {
                    lassign [outcomeUnderHir $backend $hir] tag value message
                    if {$tag ne "value" || $value ne $expected} {
                        append problem "\n$backend: expected $expected\n  got $tag $value $message"
                    }
                }
            }
            unset -nocomplain ::env(BOTLISH_NATIVE_GC_STRESS)
        }
    }
    incr programs
    incr declarations [expr {[llength [dict get $prog decls]] + [llength [dict get $prog aliases]] + [llength [dict get $prog constants]]}]
    foreach d [dict get $prog decls] {
        if {[dict get $d kind] eq "variadic"} {
            incr variadics
            incr trailingArgs [llength [dict get $d trailing]]
        }
    }
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
puts "programs $programs declarations $declarations variadic $variadics trailing $trailingArgs disagreements $disagreements"
exit [expr {$disagreements > 0}]
