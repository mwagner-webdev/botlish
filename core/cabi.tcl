# cabi.tcl -- the C ABI value universe of namespace std::ffi::c (C-ABI-TYPES.md):
# the targets' data models, the C integer scalar categories, and the raw C
# address values with their operations.
#
# Targets and data models
# -----------------------
# A C integer type is an identity whose width and signedness are the
# target's, never the name's: `long` is 64 bits on LP64 (Linux, macOS) and
# 32 on LLP64 (Windows); plain `char` is signed on x86-64 everywhere and on
# Apple and Windows AArch64, unsigned on Linux AArch64. This table is
# Botlish's own target knowledge: ordinary compilation never asks a C
# compiler (the C header archaeology's ABI probe confirmed the Linux x86-64
# row; C-HEADER-ARCHAEOLOGY.md, items 52-55).
#
#   targets   NAME -> {os OS arch ARCH model MODEL charSigned 0|1
#             triple TRIPLE floating FLOATING-MODEL}
#   models    MODEL -> {char BITS short BITS int BITS long BITS longlong BITS
#             pointer BITS}
#   systems   OS -> its name in messages (Linux, macOS, Windows)
#   platforms NAMESPACE-ROOT -> OS: the standard namespace trees that are an
#             operating system's platform interface (std::linux -> linux,
#             std::darwin -> macos, std::windows -> windows)
#
# A target is an operating system *and* an architecture: linux-aarch64 and
# macos-aarch64 share an instruction set, a pointer width and a data model,
# and are still two targets (plain char differs, and so do the C calling
# convention, the object format and every platform interface). Nothing
# reads an operating system from an architecture, or the reverse. On
# Windows the C toolchain's ABI family is part of the target too:
# windows-x86_64 is MSVC's (x86_64-pc-windows-msvc), windows-x86_64-gnu
# MinGW-w64's (x86_64-pc-windows-gnu). Their rows agree today (LLP64, signed
# char, the Microsoft x64 convention), and they are still two targets: C
# facts a generator probed with one toolchain (C-BINDGEN-LAYOUTS.md: record
# layouts) are that toolchain's, never taken for the other's, and the two
# differ beyond this table (long double, bitfield allocation, the C
# runtime, import libraries).
#
# TRIPLE is the target's LLVM/Cranelift target triple (aarch64-apple-darwin),
# the one name the native backend knows it by: the driver compares it with
# its own host before it runs or emits machine code for a program built for
# the target, and Cranelift derives the target's C calling convention
# (AppleAarch64 for Apple AArch64, SystemV for Linux, WindowsFastcall for
# Windows) and object format (Mach-O, ELF, COFF) from it
# (native/src/codegen/clif.rs's c_call_conv). Botlish owns the triple;
# Cranelift owns what the triple means for a machine ABI.
#   scalars   SOURCE-NAME -> {c C-SPELLING width WIDTH-KEY signed 0|1|char}
#             (signed `char`: plain char, the target's charSigned)
#
# A scalar's resolved metadata (scalarInfo) is the plain dict {c SPELLING
# target TARGET bits N signed 0|1}: what a later C call lowering reads (width
# and signedness), carried by the type's own registry entry, never recovered
# from its name. _Bool, size_t and the other typedefs are deliberately
# absent here (C-ABI-TYPES.md, "What is not here"; std::ffi::c::Bool is
# Botlish's bool, hir/cabi.tcl).
#
# The C floating types (C-FLOAT-FFI-MILESTONE-1.md)
# -------------------------------------------------
# C `float` and `double` are foreign *representations*, not Botlish
# numbers: std::ffi::c::Float and std::ffi::c::Double (hir/cabi.tcl's {cfloat NAME})
# name the bits C reads and writes, and a Botlish program holds their values
# as its *carrier*, Float64, on both sides of the boundary. Every fact below
# is the C type's, never the carrier's: the two share a carrier and differ in
# width, alignment, ABI class, element stride and outbound conversion.
#
#   floatings        NAME -> {c C-SPELLING carrier CARRIER representation
#                    REP raw 0|1}: the C floating types, in declaration
#                    order (no `long double`: its representation differs by
#                    target -- x87 extended, binary128, binary64 -- and is a
#                    row of its own, with its own model entry, when it
#                    comes). REP names the model entry whose format and
#                    alignment the type has: a raw type's is its finite
#                    counterpart's (below), so the two can never differ in
#                    any C fact
#   floatingModels   MODEL -> NAME -> {format FORMAT align BYTES}: what a
#                    target's C compiler makes of each (a target row's
#                    `floating`); every supported target is IEEE (C11 Annex
#                    F: float is binary32, double binary64; the x86-64 and
#                    AArch64 psABIs and the Microsoft x64 convention align
#                    each to its size). A target whose layout differs --
#                    i386's 4-byte double alignment inside a struct -- is a
#                    model of its own, never a special case of this one
#   floatingFormats  FORMAT -> {bytes N class ABI-CLASS precision P
#                    maxExponent E}: the IEEE 754 interchange formats, the
#                    ABI transport class each travels in (hir/foreign.tcl,
#                    nir.rs's CAbi::F32/F64)
#
# The boundary rules are written once, here, for every place a C floating
# value crosses (an extern call's arguments and result, a layout field read
# from bytes or native memory, a layout field written), and the native
# runtime implements the same three (runtime/value.rs's foreign float
# helpers, codegen::clif's foreign call):
#
#   Admit   a C value (bits of FORMAT) enters Botlish: NaN and the
#           infinities are NonFiniteFloat (the payload names which), negative
#           zero is zero, and anything else is the carrier value it exactly is
#           (every finite binary32 is a binary64: widening never rounds)
#   Narrow  a carrier value leaves for FORMAT: binary64 exactly; binary32
#           rounded to nearest, ties to even, the result NonFiniteFloat when
#           it overflows to an infinity (never clamped to FLT_MAX), zero when
#           it underflows to a zero of either sign (a finite result), and a
#           subnormal when that is the nearest
#   Encode/Decode   Narrow and Admit with the bytes of a little-endian FORMAT
#
# Raw C floating values (RAW-C-FLOAT-FFI-MILESTONE-1.md)
# ------------------------------------------------------
# std::ffi::c::RawFloat and std::ffi::c::RawDouble are the same two C types
# without the admission: every binary32 or binary64 bit pattern is a value
# -- every NaN (sign and payload, quiet or signaling), both infinities, both
# zeros, every subnormal. Their carrier is a runtime kind of their own,
# rawfloat32 and rawfloat64 (core/type.tcl), never Float64, so a raw C type
# is a type of values too, as a C integer scalar is: the canonical type of
# std::ffi::c::RawFloat is rawfloat32 wherever it is written (hir/cabi.tcl).
# Crossing the boundary changes nothing: a raw argument is passed as, and a
# raw result or field is, exactly its bits (no Narrow, no Admit). The
# explicit operations of this namespace are the only way between a raw
# value and anything else:
#
#   std::ffi::c::raw::float_from_bits(b)     RawFloat   bits B (0..2^32-1)
#   std::ffi::c::raw::float_to_bits(x)       Int        X's bits, exactly
#   std::ffi::c::raw::float_to_float64(x)    Float64    Admit (NonFiniteFloat;
#                                                       -0 is 0.0, a binary32
#                                                       widened exactly)
#   std::ffi::c::raw::float_from_float64(x)  RawFloat   Narrow (to nearest,
#                                                       ties to even; an
#                                                       overflow NonFiniteFloat)
#   and double_from_bits, double_to_bits, double_to_float64,
#   double_from_float64 (total: every Float64 is a binary64)
#
# with the classifications the module writes over the bits (stdlib/ffi/c/
# raw.bot: finite?, nan?, infinite?, zero?, negative?). A raw value has no
# arithmetic, ordering, equality or hash: `==` and `hash` refuse
# it (core::value::equal, EQUALITY), as they refuse a pointer.
#
# Values
# ------
#   {cptr ADDRESS}   a raw C address (a data pointer or a function pointer:
#                    the two are distinct static types of this one runtime
#                    kind), ADDRESS its bits as a canonical unsigned decimal;
#                    0 is null. Opaque: no arithmetic, ordering, equality,
#                    hash or Int conversion exists for it, and the pointee
#                    identity is static only (nothing in the value names
#                    it). The Tcl backends have no machine addresses: null
#                    and the test fixture's addresses are its only sources.
#
# Operations (natives; the explicit imprints are hir/imprint.tcl's)
# ----------
#   std::ffi::c::null[T]()     Ptr[T]         a null pointer (imprinting T)
#   std::ffi::c::null?(p)      bool           whether P is null (any C address)
#   std::ffi::c::clone(p)      P's own type   a second alias of the same address
#   std::ffi::c::erase(p)      Ptr[Void]      the same bits, as void * (moves P)
#   std::ffi::c::retype[T](p)  Ptr[T]         the same bits of a Ptr[Void] (moves P)
#
# None of them reads memory, calls foreign code, allocates or retains
# anything: clone copies the address, never the pointee, and none of them
# changes a reference count.

namespace eval core::cabi {
    variable models [dict create \
        LP64  {char 8 short 16 int 32 long 64 longlong 64 pointer 64} \
        LLP64 {char 8 short 16 int 32 long 32 longlong 64 pointer 64}]
    variable targets [dict create \
        linux-x86_64    {os linux arch x86_64 model LP64 charSigned 1 triple x86_64-unknown-linux-gnu floating IEEE} \
        linux-aarch64   {os linux arch aarch64 model LP64 charSigned 0 triple aarch64-unknown-linux-gnu floating IEEE} \
        macos-x86_64    {os macos arch x86_64 model LP64 charSigned 1 triple x86_64-apple-darwin floating IEEE} \
        macos-aarch64   {os macos arch aarch64 model LP64 charSigned 1 triple aarch64-apple-darwin floating IEEE} \
        windows-x86_64  {os windows arch x86_64 model LLP64 charSigned 1 triple x86_64-pc-windows-msvc floating IEEE} \
        windows-x86_64-gnu {os windows arch x86_64 model LLP64 charSigned 1 triple x86_64-pc-windows-gnu floating IEEE} \
        windows-aarch64 {os windows arch aarch64 model LLP64 charSigned 1 triple aarch64-pc-windows-msvc floating IEEE}]
    variable systems [dict create linux Linux macos macOS windows Windows]
    # The standard namespace trees that are an operating system's platform
    # interface -- ROOT -> OS: the namespace ROOT and every namespace under
    # it are OS's, importable only for a target of OS (surface/modules.tcl's
    # PlatformCheck). Designated here, never inferred from a name:
    # `std::linux` (stdlib/linux.bot, stdlib/linux/*, the syscall transports
    # std::linux::abi::*), `std::darwin` (stdlib/darwin.bot, stdlib/darwin/*:
    # macOS's libSystem interface, MACOS-AARCH64-MILESTONE-8.md) and
    # `std::windows` (stdlib/windows.bot, stdlib/windows/*: Windows' kernel32
    # interface, WINDOWS-X86-64-MILESTONE-2.md). A root is a whole namespace
    # path: `std` itself is every system's (STD-NAMESPACE.md: the prefix says
    # who owns a namespace, not where it is available).
    variable platforms [dict create std::linux linux std::darwin macos std::windows windows]
    # In declaration (and HIR text) order.
    variable scalars [dict create \
        Char      {c char width char signed char} \
        SChar     {c {signed char} width char signed 1} \
        UChar     {c {unsigned char} width char signed 0} \
        Short     {c short width short signed 1} \
        UShort    {c {unsigned short} width short signed 0} \
        Int       {c int width int signed 1} \
        UInt      {c {unsigned int} width int signed 0} \
        Long      {c long width long signed 1} \
        ULong     {c {unsigned long} width long signed 0} \
        LongLong  {c {long long} width longlong signed 1} \
        ULongLong {c {unsigned long long} width longlong signed 0}]
    # The C floating types (the file header's "The C floating types"), in
    # declaration order, and what each target's C compiler makes of them.
    variable floatings [dict create \
        Float     {c float carrier Float64 representation Float raw 0} \
        Double    {c double carrier Float64 representation Double raw 0} \
        RawFloat  {c float carrier rawfloat32 representation Float raw 1} \
        RawDouble {c double carrier rawfloat64 representation Double raw 1}]
    variable floatingModels [dict create \
        IEEE {Float {format binary32 align 4} Double {format binary64 align 8}}]
    variable floatingFormats [dict create \
        binary32 {bytes 4 class f32 precision 24 maxExponent 127} \
        binary64 {bytes 8 class f64 precision 53 maxExponent 1023}]
    # The smallest magnitude that rounds to binary32's infinity: 2^128 -
    # 2^103, the midpoint between the largest finite binary32 (2^128 - 2^104)
    # and 2^128, which ties-to-even rounds up (the largest finite one's
    # significand is odd). A binary64 holds it exactly.
    variable binary32Overflow 340282356779733661637539395458142568448.0
    # The namespace whose intrinsic types these are.
    variable namespace std::ffi::c
}

proc core::cabi::targetNames {} {
    variable targets
    return [lsort [dict keys $targets]]
}

# The architectures of the targets (their `arch`), sorted: what an
# architecture-specific module file may be specific to (surface/modules.tcl's
# ModuleFile: stdlib/P.ARCH.bot).
proc core::cabi::architectures {} {
    variable targets
    return [lsort -unique [lmap name [dict keys $targets] {dict get $targets $name arch}]]
}

# The operating systems of the targets (their `os`), sorted.
proc core::cabi::operatingSystems {} {
    variable targets
    return [lsort -unique [lmap name [dict keys $targets] {dict get $targets $name os}]]
}

# The operating system whose platform interface the namespace NAME is part
# of -- NAME is a designated platform root (`platforms`) or under one --
# or "".
proc core::cabi::platformOf {name} {
    variable platforms
    dict for {root os} $platforms {
        if {$name eq $root || [string first ${root}:: $name] == 0} {
            return $os
        }
    }
    return ""
}

# The name of operating system OS in a message (macOS for macos).
proc core::cabi::systemName {os} {
    variable systems
    return [dict get $systems $os]
}

# 1 if the platform linker of target NAME links Apple frameworks
# (`extern c framework`, NATIVE-LINK-PLAN-MILESTONE-1.md): a macOS target's,
# Apple's ld, by its row's operating system. No other system's linker has
# frameworks, and nothing maps one to a library elsewhere.
proc core::cabi::linksFrameworks {name} {
    return [expr {[dict get [target $name] os] eq "macos"}]
}

proc core::cabi::isTarget {name} {
    variable targets
    return [dict exists $targets $name]
}

# The target metadata of NAME, with its data model's widths merged in.
proc core::cabi::target {name} {
    variable targets
    variable models
    if {![dict exists $targets $name]} {
        error "core::cabi: unknown C ABI target \"$name\" (known: [join [targetNames] {, }])"
    }
    set meta [dict get $targets $name]
    return [dict merge $meta [dict get $models [dict get $meta model]] [dict create name $name]]
}

# The target of the machine this process runs on, or "" if it is not one of
# the table's (the caller decides what that means: importing std::ffi::c then
# needs an explicit -target).
proc core::cabi::hostTarget {} {
    set os [string tolower $::tcl_platform(os)]
    switch -glob -- $os {
        linux { set os linux }
        darwin { set os macos }
        windows* { set os windows }
        default { return "" }
    }
    set arch [hostArchitecture]
    if {$arch eq ""} {
        return ""
    }
    set name $os-$arch
    if {[isTarget $name]} {
        return $name
    }
    return ""
}

# The architecture (a target's `arch`) of the machine this process runs on,
# or "" if it is none of the table's: arm64 (macOS's name) is aarch64.
proc core::cabi::hostArchitecture {} {
    switch -- [string tolower $::tcl_platform(machine)] {
        x86_64 - amd64 { return x86_64 }
        aarch64 - arm64 { return aarch64 }
    }
    return ""
}

# The target of operating system OS on the architecture of the machine this
# process runs on (linux-aarch64 on an arm64 Mac), or "" when there is none:
# what a tool on this host compiles a program of OS's platform for -- the
# host's own target on a host of OS. The test harnesses compile Linux
# programs (ones importing linux::*) so: on a Linux host it is exactly the
# default target; on another host the Tcl backends run the program, and the
# native ones refuse it (it is not the host's target).
proc core::cabi::systemTarget {os} {
    set name $os-[hostArchitecture]
    if {[isTarget $name]} {
        return $name
    }
    return ""
}

# The C integer scalar names (std::ffi::c::NAME), in declaration order.
proc core::cabi::scalarNames {} {
    variable scalars
    return [dict keys $scalars]
}

# The resolved metadata of scalar NAME on TARGET: {c SPELLING target TARGET
# bits N signed 0|1}.
proc core::cabi::scalarInfo {name target} {
    variable scalars
    if {![dict exists $scalars $name]} {
        error "core::cabi: unknown C integer scalar \"$name\""
    }
    set meta [dict get $scalars $name]
    set t [core::cabi::target $target]
    set bits [dict get $t [dict get $meta width]]
    set signed [dict get $meta signed]
    if {$signed eq "char"} {
        set signed [dict get $t charSigned]
    }
    return [dict create c [dict get $meta c] target $target bits $bits signed $signed]
}

# The metadata of the scalar whose C spelling is SPELLING on TARGET (HIR
# text names a scalar so), or "" if there is none.
proc core::cabi::scalarInfoOf {spelling target} {
    variable scalars
    if {![isTarget $target]} {
        return ""
    }
    dict for {name meta} $scalars {
        if {[dict get $meta c] eq $spelling} {
            return [scalarInfo $name $target]
        }
    }
    return ""
}

# The exact mathematical value domain {interval LO HI} of a scalar with
# INFO (scalarInfo): two's complement for a signed one.
proc core::cabi::scalarDomain {info} {
    set bits [dict get $info bits]
    if {[dict get $info signed]} {
        return [list interval [expr {-(2 ** ($bits - 1))}] [expr {2 ** ($bits - 1) - 1}]]
    }
    return [list interval 0 [expr {2 ** $bits - 1}]]
}

# 1 if INFO is a well-formed scalar metadata dict (as a registry entry or HIR
# text carries it): a known target, and exactly the bits and signedness that
# target gives the C spelling. A registry entry read back from text is
# re-derived, never trusted.
proc core::cabi::validScalarInfo {info} {
    variable scalars
    if {[catch {dict size $info}] || [lsort [dict keys $info]] ne {bits c signed target}} {
        return 0
    }
    if {![isTarget [dict get $info target]]} {
        return 0
    }
    dict for {name meta} $scalars {
        if {[dict get $meta c] eq [dict get $info c]} {
            return [expr {[scalarInfo $name [dict get $info target]] eq $info}]
        }
    }
    return 0
}

# ---------------------------------------------------------------------------
# The C floating types (the file header's "The C floating types")

# The C floating type names (std::ffi::c::NAME), in declaration order.
proc core::cabi::floatingNames {} {
    variable floatings
    return [dict keys $floatings]
}

# 1 if NAME is the name of a C floating type (Float, Double).
proc core::cabi::isFloating {name} {
    variable floatings
    return [dict exists $floatings $name]
}

# 1 if C floating type NAME is a raw one (RawFloat, RawDouble: the file
# header's "Raw C floating values").
proc core::cabi::isRawFloating {name} {
    variable floatings
    return [expr {[dict exists $floatings $name] && [dict get $floatings $name raw]}]
}

# The C floating type whose carrier is the raw kind KIND (rawfloat32 ->
# RawFloat), or "".
proc core::cabi::rawFloatingOf {kind} {
    variable floatings
    dict for {name meta} $floatings {
        if {[dict get $meta raw] && [dict get $meta carrier] eq $kind} {
            return $name
        }
    }
    return ""
}

# The source spelling of the raw kind KIND (std::ffi::c::RawFloat).
proc core::cabi::rawName {kind} {
    variable namespace
    return "${namespace}::[rawFloatingOf $kind]"
}

# The IEEE 754 format of the raw kind KIND's bits (binary32, binary64): its C
# type's on every target (the representation's model entry; no target has
# another).
proc core::cabi::rawFormat {kind} {
    variable floatings
    variable floatingModels
    set rep [dict get $floatings [rawFloatingOf $kind] representation]
    return [dict get $floatingModels IEEE $rep format]
}

# The metadata of C floating type NAME on TARGET: {c SPELLING carrier
# CARRIER format FORMAT bytes N align A class CLASS raw 0|1 target TARGET} --
# its C spelling, its Botlish carrier type, the IEEE 754 format the target's
# C compiler gives it, its size and alignment there, the ABI transport class
# it travels in (a raw type's is its finite counterpart's: the same C type)
# and whether it is raw. Nothing here is derived from the carrier.
proc core::cabi::floatingInfo {name target} {
    variable floatings
    variable floatingModels
    variable floatingFormats
    if {![dict exists $floatings $name]} {
        error "core::cabi: unknown C floating type \"$name\""
    }
    set model [dict get [core::cabi::target $target] floating]
    set meta [dict get $floatings $name]
    set entry [dict get $floatingModels $model [dict get $meta representation]]
    set format [dict get $entry format]
    return [dict create c [dict get $meta c] carrier [dict get $meta carrier] format $format \
        bytes [dict get $floatingFormats $format bytes] align [dict get $entry align] \
        class [dict get $floatingFormats $format class] raw [dict get $meta raw] target $target]
}

# The facts of IEEE 754 interchange format FORMAT (binary32, binary64):
# {bytes N class ABI-CLASS precision P maxExponent E}.
proc core::cabi::formatInfo {format} {
    variable floatingFormats
    if {![dict exists $floatingFormats $format]} {
        error "core::cabi: unknown floating format \"$format\""
    }
    return [dict get $floatingFormats $format]
}

# The IEEE 754 format of a WIDTH-byte floating representation (a layout
# descriptor's `f WIDTH`), or "".
proc core::cabi::formatOfWidth {width} {
    variable floatingFormats
    dict for {format info} $floatingFormats {
        if {[dict get $info bytes] == $width} {
            return $format
        }
    }
    return ""
}

# Narrow: the carrier value X (a finite Tcl double, never negative zero)
# leaving for FORMAT -- {ok Y}, Y the Tcl double FORMAT holds, or {error
# NonFiniteFloat RESULT} when it has none. binary64 is exact. binary32 is
# rounded to nearest, ties to even (Tcl's `binary format r` is C's (float)
# conversion, IEEE's rounding: it clamps a magnitude beyond FLT_MAX to
# FLT_MAX, which is the correctly rounded result below binary32Overflow and
# never reached at or above it); a magnitude that rounds to an infinity is
# NonFiniteFloat with the infinity's sign, never clamped or saturated; a
# result that rounds to a zero of either sign is zero (a finite underflow,
# no error), and a subnormal stays one.
proc core::cabi::Narrow {format x} {
    variable binary32Overflow
    switch -- $format {
        binary64 {
            return [list ok $x]
        }
        binary32 {
            if {abs($x) >= $binary32Overflow} {
                if {$x > 0} {
                    return {error NonFiniteFloat PositiveInfinity}
                }
                return {error NonFiniteFloat NegativeInfinity}
            }
            binary scan [binary format r $x] r y
            return [list ok [expr {$y + 0.0}]]
        }
    }
    error "core::cabi::Narrow: unknown floating format \"$format\""
}

# The little-endian bytes (a Tcl byte string) of the carrier value X in
# FORMAT -- {ok BYTES} -- or Narrow's {error NonFiniteFloat RESULT}.
proc core::cabi::EncodeFloating {format x} {
    set narrowed [Narrow $format $x]
    if {[lindex $narrowed 0] ne "ok"} {
        return $narrowed
    }
    switch -- $format {
        binary32 { return [list ok [binary format r [lindex $narrowed 1]]] }
        binary64 { return [list ok [binary format q [lindex $narrowed 1]]] }
    }
}

# Admit: the FORMAT value whose bits are the unsigned integer BITS entering
# Botlish -- {ok X}, X the Tcl double it exactly is (negative zero made
# zero), or {error NonFiniteFloat RESULT} for NaN (NotANumber) or an
# infinity (of its sign). Every finite binary32 is a binary64, so X is
# exact.
proc core::cabi::AdmitBits {format bits} {
    switch -- $format {
        binary32 {
            set top [expr {($bits >> 23) & 0xff}]
            set fraction [expr {$bits & 0x7fffff}]
            set negative [expr {($bits >> 31) & 1}]
            set nonFinite 0xff
            binary scan [binary format iu $bits] r x
        }
        binary64 {
            set top [expr {($bits >> 52) & 0x7ff}]
            set fraction [expr {$bits & 0xfffffffffffff}]
            set negative [expr {($bits >> 63) & 1}]
            set nonFinite 0x7ff
            binary scan [binary format wu $bits] q x
        }
        default {
            error "core::cabi::AdmitBits: unknown floating format \"$format\""
        }
    }
    if {$top == $nonFinite} {
        if {$fraction != 0} {
            return {error NonFiniteFloat NotANumber}
        }
        if {$negative} {
            return {error NonFiniteFloat NegativeInfinity}
        }
        return {error NonFiniteFloat PositiveInfinity}
    }
    return [list ok [expr {$x + 0.0}]]
}

# Admit from the little-endian FORMAT value at byte AT of BYTES (a Tcl byte
# string holding it): AdmitBits's completion.
proc core::cabi::DecodeFloating {format bytes at} {
    switch -- $format {
        binary32 { binary scan $bytes @${at}iu bits }
        binary64 { binary scan $bytes @${at}wu bits }
        default { error "core::cabi::DecodeFloating: unknown floating format \"$format\"" }
    }
    return [AdmitBits $format $bits]
}

# The unsigned bit pattern of the FORMAT value the carrier value X narrows
# to, or "" when it narrows to no finite value (tests, the fuzz harness).
proc core::cabi::NarrowBits {format x} {
    set encoded [EncodeFloating $format $x]
    if {[lindex $encoded 0] ne "ok"} {
        return ""
    }
    switch -- $format {
        binary32 { binary scan [lindex $encoded 1] iu bits }
        binary64 { binary scan [lindex $encoded 1] wu bits }
    }
    return $bits
}

# The Botlish value of a completion COMPLETION of Narrow, AdmitBits or
# DecodeFloating, for the native or operation WHAT -- the carrier Float64
# value -- or WHAT's NonFiniteFloat (its payload naming the result).
proc core::cabi::FloatingValue {what completion} {
    if {[lindex $completion 0] eq "ok"} {
        return [core::value::float Float64 [lindex $completion 1]]
    }
    set result [lindex $completion 2]
    core::native::failDeclared NonFiniteFloat "$what: $result is not a finite number" [core::float::Payload $result]
}

# Narrows the carrier value V (a Float64) for FORMAT on behalf of WHAT:
# the Tcl double FORMAT holds, or WHAT's NonFiniteFloat.
proc core::cabi::NarrowValue {what format v} {
    set completion [Narrow $format [core::value::floatOf $v]]
    if {[lindex $completion 0] eq "ok"} {
        return [lindex $completion 1]
    }
    set result [lindex $completion 2]
    core::native::failDeclared NonFiniteFloat \
        "$what: [core::float::text $v] has no finite $format value (it rounds to an infinity)" [core::float::Payload $result]
}

# ---------------------------------------------------------------------------
# Raw C floating values (the file header's "Raw C floating values")
#
# A value is {KIND BITS}: KIND rawfloat32 or rawfloat64, BITS the bit pattern
# as a canonical unsigned decimal (0..2^32-1, 0..2^64-1).

# The largest bit pattern of FORMAT (binary32, binary64).
proc core::cabi::RawMaxBits {format} {
    return [expr {(1 << (8 * [dict get [formatInfo $format] bytes])) - 1}]
}

# The raw kind of FORMAT's values.
proc core::cabi::RawKindOf {format} {
    switch -- $format {
        binary32 { return rawfloat32 }
        binary64 { return rawfloat64 }
    }
    error "core::cabi::RawKindOf: unknown floating format \"$format\""
}

# The raw value of FORMAT whose bits are the unsigned integer BITS.
proc core::cabi::rawValue {format bits} {
    if {$bits < 0 || $bits > [RawMaxBits $format]} {
        error "core::cabi::rawValue: $bits is no $format bit pattern"
    }
    return [list [RawKindOf $format] [expr {$bits + 0}]]
}

# The bit pattern of the raw value V (an unsigned integer).
proc core::cabi::rawBitsOf {v} {
    set kind [core::value::kind $v]
    if {$kind ni {rawfloat32 rawfloat64}} {
        error "core::cabi::rawBitsOf: not a raw C floating value: \"$v\""
    }
    return [lindex $v 1]
}

# The display text of a raw C floating value (show.rs's must be the same):
# its C type and its bits, every hexadecimal digit of the format.
proc core::cabi::showRaw {v} {
    if {[lindex $v 0] eq "rawfloat32"} {
        return [format {<C float 0x%08llx>} [lindex $v 1]]
    }
    return [format {<C double 0x%016llx>} [lindex $v 1]]
}

# The raw value V of kind KIND, or a TYPE error naming WHAT.
proc core::cabi::RawOperand {kind v what} {
    if {[core::value::kind $v] ne $kind} {
        core::semanticError TYPE "$what: expected [rawName $kind], got [core::value::show $v]"
    }
    return [lindex $v 1]
}

# from_bits32 / from_bits64: the raw value of FORMAT whose
# bits are the Int N (its static type, the bit pattern domain, proves the
# range; an unchecked program out of it is RANGE).
proc core::cabi::rawFromBitsImpl {format n} {
    set n [core::value::intOf $n]
    if {$n < 0 || $n > [RawMaxBits $format]} {
        core::semanticError RANGE "$n is not a $format bit pattern (0..[RawMaxBits $format])"
    }
    return [rawValue $format $n]
}

# bits32 / bits64: the bits of the raw value V.
proc core::cabi::rawToBitsImpl {kind v} {
    return [core::value::intFromNumber [RawOperand $kind $v "[rawName $kind] bits"]]
}

# admit32 / admit64: Admit (the file header):
# the Float64 the bits stand for, or NonFiniteFloat.
proc core::cabi::rawToFloat64Impl {kind what v} {
    set bits [RawOperand $kind $v $what]
    return [FloatingValue $what [AdmitBits [rawFormat $kind] $bits]]
}

# narrow32 / narrow64: Narrow (the file
# header): the raw value of the bits a Float64 leaves Botlish as, or
# NonFiniteFloat (binary32 only).
proc core::cabi::rawFromFloat64Impl {format what v} {
    if {[core::value::kind $v] ne "Float64"} {
        core::semanticError TYPE "$what: expected Float64, got [core::value::show $v]"
    }
    set x [NarrowValue $what $format $v]
    switch -- $format {
        binary32 { binary scan [binary format r $x] iu bits }
        binary64 { binary scan [binary format q $x] wu bits }
    }
    return [rawValue $format $bits]
}

# The intrinsics of the raw values, internal to the standard library
# (core::native::declareInternalNamespace): the functions of std::ffi::c::raw
# (stdlib/ffi/c/raw.bot) are their public, declared spelling -- a bit
# pattern in its domain, a raw value of its own type -- and nothing else
# imports them. NAME32 is the binary32 operation, NAME64 the binary64 one.
#
#   std::ffi::rawfloat::from_bits32(n)     rawfloat32  bits N, as they are
#   std::ffi::rawfloat::bits32(x)          Int         X's bits
#   std::ffi::rawfloat::admit32(x)         Float64     Admit (NonFiniteFloat)
#   std::ffi::rawfloat::narrow32(x)        rawfloat32  Narrow (NonFiniteFloat)
#   ... and from_bits64, bits64, admit64, narrow64 (exact)
namespace eval core::cabi {
    # The internal namespace of the raw values' intrinsics.
    variable rawNamespace std::ffi::rawfloat
}
foreach {format kind width stem} {binary32 rawfloat32 32 float binary64 rawfloat64 64 double} {
    set ns $core::cabi::rawNamespace
    core::native::register ${ns}::from_bits$width -arity 1 \
        -impl [list core::cabi::rawFromBitsImpl $format] -param-types {int} -result-type $kind \
        -context-free 1 -nomethod 1
    core::native::register ${ns}::bits$width -arity 1 \
        -impl [list core::cabi::rawToBitsImpl $kind] -param-types [list $kind] -result-type int \
        -result-range [list interval 0 [core::cabi::RawMaxBits $format]] -context-free 1 -nomethod 1
    core::native::register ${ns}::admit$width -arity 1 \
        -impl [list core::cabi::rawToFloat64Impl $kind ${core::cabi::namespace}::raw::${stem}_to_float64] \
        -param-types [list $kind] -result-type Float64 -errors {NonFiniteFloat} -context-free 1 -nomethod 1
    core::native::register ${ns}::narrow$width -arity 1 \
        -impl [list core::cabi::rawFromFloat64Impl $format ${core::cabi::namespace}::raw::${stem}_from_float64] \
        -param-types {Float64} -result-type $kind \
        -errors [expr {$format eq "binary32" ? "NonFiniteFloat" : ""}] -context-free 1 -nomethod 1
}
core::native::declareInternalNamespace $core::cabi::rawNamespace
unset format kind width stem ns

# ---------------------------------------------------------------------------
# Values

proc core::cabi::address {address} {
    return [list cptr $address]
}

proc core::cabi::addressOf {v} {
    core::value::expect cptr $v "C pointer"
    return [lindex $v 1]
}

# The display text of a C address value (show.rs's must be the same).
proc core::cabi::show {v} {
    return [format {<C pointer 0x%llx>} [lindex $v 1]]
}

proc core::cabi::nullImpl {} {
    return [address 0]
}

proc core::cabi::isNullImpl {p} {
    return [core::value::bool [expr {[addressOf $p] == 0}]]
}

# clone, erase and retype: the same address, unchanged (the static type is
# all that differs).
proc core::cabi::sameImpl {p} {
    addressOf $p
    return $p
}

# The test fixture's address reader (installTestFixture): the address bits of
# the C address P, an Int. Only a test process can name it.
proc core::cabi::fixtureAddressOfImpl {p} {
    return [core::value::intFromNumber [addressOf $p]]
}

# The test fixture's address constructor (installTestFixture): the C address
# whose bits are the Int N, 0 <= N < 2^59 (the range every backend
# represents; the native word keeps 60 bits).
proc core::cabi::fixtureAddressImpl {n} {
    set n [core::value::intOf $n]
    if {$n < 0 || $n >= 2 ** 59} {
        core::semanticError RANGE "C pointer test fixture: address $n is outside 0..2^59-1"
    }
    return [address $n]
}

core::native::register std::ffi::c::null -arity 0 -impl core::cabi::nullImpl \
    -result-type cptr -imprint {vars {T} params {} result {cptr {imprint T}}}
core::native::register std::ffi::c::null? -arity 1 -impl core::cabi::isNullImpl \
    -param-types {cptr} -result-type bool -ownership {observe}
core::native::register std::ffi::c::clone -arity 1 -impl core::cabi::sameImpl \
    -param-types {cptr} -result-type cptr -result-shape {same 0} -ownership {observe}
core::native::register std::ffi::c::erase -arity 1 -impl core::cabi::sameImpl \
    -param-types {cptr} -result-type cptr -ownership {move} \
    -imprint {vars {T} params {{cptr {imprint T}}} result {cptr void}}
core::native::register std::ffi::c::retype -arity 1 -impl core::cabi::sameImpl \
    -param-types {cptr} -result-type cptr -ownership {move} \
    -imprint {vars {T} params {{cptr void}} result {cptr {imprint T}}}

# The private C pointer test fixture (C-ABI-TYPES.md, "Testing"). This
# milestone has no source of a non-null pointer: no C call, no exported
# function. Tests that must see one call this from Tcl, in their own process,
# before compiling; it registers the namespace `ffi_fixture` with
#
#   ffi_fixture::address[T](n)          Ptr[T], the address N
#   ffi_fixture::function_address[F](n) FnPtr[F], the address N
#   ffi_fixture::address_of(p)          the address bits of any C pointer P,
#                                       an Int (observes P)
#   ffi_fixture::memory[T](data)        Ptr[T], the address of a fresh,
#                                       never-freed native copy of the bytes
#                                       of the std::abi::bytes::Bytes DATA, 64-byte
#                                       aligned: live memory a native view
#                                       can read (NATIVE-LAYOUT-VIEWS.md). The
#                                       Tcl backends have no native memory:
#                                       there it is a fresh non-null address
#                                       that nothing can read.
#   ffi_fixture::memory_bytes(p, n)     the N bytes of native memory at the
#                                       data pointer P (observed), as a List
#                                       of Ints: the oracle a native edit's
#                                       stores are checked with
#                                       (NATIVE-LAYOUT-WRITES.md), a copy
#                                       made with no layout and no view. The
#                                       Tcl backends refuse (NATIVE-ONLY).
#
# Nothing in the compiler, the libraries or main.tcl calls it, so no Botlish
# program outside a test process can name any of them: there is no public
# conversion between Ints and pointers. The native backend lowers them to the
# fixture-only NIR ops `cptrfixture` and `cptrfixtureaddress`
# (native/lower.tcl), which no other native lowers to.
proc core::cabi::installTestFixture {} {
    if {[core::native::isQualifiedNative ffi_fixture::address]} {
        return
    }
    core::native::register ffi_fixture::address -arity 1 -impl core::cabi::fixtureAddressImpl \
        -param-types {int} -result-type cptr -errors {} \
        -imprint {vars {T} params {int} result {cptr {imprint T}}}
    core::native::register ffi_fixture::function_address -arity 1 -impl core::cabi::fixtureAddressImpl \
        -param-types {int} -result-type cptr -errors {} \
        -imprint {vars {F} params {int} result {cfnptr {imprint F}}}
    core::native::register ffi_fixture::address_of -arity 1 -impl core::cabi::fixtureAddressOfImpl \
        -param-types {cptr} -result-type int -ownership {observe}
    core::native::register ffi_fixture::memory -arity 1 -impl core::cabi::fixtureMemoryImpl \
        -param-types {struct} -result-type cptr -errors {} -ownership {observe} \
        -imprint [list vars {T} params [list [list nstruct [core::bytestore::bytesType]]] result {cptr {imprint T}}]
    core::native::register ffi_fixture::memory_bytes -arity 2 -impl core::cabi::fixtureMemoryBytesImpl \
        -param-types {cptr int} -result-type list -ownership {observe observe}
}

# The Tcl backends' ffi_fixture::memory_bytes: no native memory to copy.
proc core::cabi::fixtureMemoryBytesImpl {p n} {
    addressOf $p
    core::semanticError NATIVE-ONLY \
        "ffi_fixture::memory_bytes copies live native memory, which only the native backends have"
}

# The Tcl backends' ffi_fixture::memory: a fresh non-null address (beyond
# the plain fixture addresses tests choose), never readable -- a native view
# of it is NATIVE-ONLY there.
proc core::cabi::fixtureMemoryImpl {data} {
    variable fixtureMemoryNext
    if {![info exists fixtureMemoryNext]} {
        set fixtureMemoryNext [expr {2 ** 52}]
    }
    core::binary::BytesOf $data ffi_fixture::memory
    set address $fixtureMemoryNext
    set fixtureMemoryNext [expr {$fixtureMemoryNext + 4096}]
    return [address $address]
}

# ---------------------------------------------------------------------------
# Foreign call contracts and temporary byte exposure (C-POINTER-BORROWING.md)
#
# A foreign call contract (core/native.tcl's -foreign; a future `extern c
# fn` declaration carries the same facts) is a C signature with two facts
# per pointer parameter:
#
#   access   read | write | unknown
#            what C may do through the pointer during the call: read only
#            (C const), or read and modify; unknown when the binding says
#            nothing
#   escape   proven-noescape | declared-noescape | captures | unknown
#            whether C may retain pointer provenance after the call
#            returns: never (proven by a tool, or declared by the binding's
#            author -- the same fact, two kinds of evidence), it may
#            (stores it, hands it to another thread, returns it), or
#            nobody said (treated exactly like captures)
#
# The two are independent: a `const char *` (read) may still be stored, and
# a writable pointer may be perfectly safe to expose for one synchronous
# call. Nothing here or anywhere reads either fact from a C type, a `const`,
# a parameter name or a function name: the contract says it, or it is
# unknown.
#
# Temporary byte exposure. A pointer parameter whose contract is noescape
# and whose access is known, and whose pointee is a byte-sized C type (Char,
# SChar, UChar) or Void, admits existing Botlish byte storage for the one
# call (hir/borrow.tcl decides it statically, and records the transport on
# the call):
#
#   std::abi::bytes::Bytes         read access only: C sees the bytes, which it
#                                  may not modify (an immutable value is never
#                                  written, whatever its physical storage is)
#   std::abi::bytes::MutableBytes  read access: its current bytes, as they are
#                                  (no copy); write access: a private copy of
#                                  them (the detach std::linux::read takes),
#                                  which C may read and modify, and which comes
#                                  back as the call's updated value of that
#                                  parameter (the call's result is then
#                                  {result: R, NAME:
#                                  std::abi::bytes::MutableBytes, ...})
#
# No pointer value exists for an exposure: nothing makes a std::ffi::c::Ptr of
# Botlish storage, and the address lives only as the call's argument. It
# ends when the call returns.
#
# On the Tcl backends there are no machine addresses: ForeignBoundary, the
# entry of every -foreign native's implementation, models an exposure as
# {exposure ID}, a handle into the call's own table of exposed bytes that the
# implementation reads (ExposedBytes) and, for a write exposure, writes
# (StoreExposed) -- and that is closed when the call returns, so a handle
# kept past the call can no longer reach anything. The native backend
# passes the storage's payload address (native/lower.tcl's BorrowCall).

namespace eval core::cabi {
    variable accesses {read write unknown}
    variable escapes {proven-noescape declared-noescape captures unknown}
    # The exposures of the calls in progress: ID -> {access A hex HEX}.
    variable exposures [dict create]
    variable exposureCounter 0
}

proc core::cabi::accesses {} {
    variable accesses
    return $accesses
}

proc core::cabi::escapes {} {
    variable escapes
    return $escapes
}

# 1 if ESCAPE says the pointer does not outlive the call (either evidence).
proc core::cabi::isNoescape {escape} {
    return [expr {$escape in {proven-noescape declared-noescape}}]
}

# The normalized foreign call contract CONTRACT of native NAME of ARITY
# (core/native.tcl's -foreign), or a Tcl error: {vars V params {P...} result
# R provenance PR}, every P {name N type T} for a C value and {name N type T
# access A escape E} for a C pointer (a type {cptr ...} or {cfnptr ...}), an
# absent fact being `unknown`. Only a data pointer has an access; a write
# parameter's name is a field of the call's result, so it is never
# `result`.
#
# PR is the provenance of a data pointer result (C-FFI.md, "Pointer
# results"): `unknown` (the default: nothing is said), `independent` (never
# derived from an argument's pointer) or {alias NAME} (exactly the pointer
# argument NAME, a data pointer parameter of the result's own type: SHA256's
# `out`). A result that is not a data pointer has provenance unknown.
proc core::cabi::NormalizeForeign {name contract arity} {
    variable accesses
    variable escapes
    if {[catch {dict size $contract}] || ![dict exists $contract params] || ![dict exists $contract result]
            || [lmap key [dict keys $contract] {if {$key in {vars params result provenance variadic}} {continue} else {set key}}] ne {}} {
        error "core::native::register: bad -foreign \"$contract\" for \"$name\" (expected {vars {...} params {...} result R ?provenance PR? ?variadic 1?})"
    }
    set vars [dict getdef $contract vars {}]
    set params [dict get $contract params]
    # A variadic C function (VARIADICS-VERTICAL-SLICE-1.md) is a native of
    # any arity whose PARAMS are its fixed parameters, at least one: each
    # call passes them and any number of trailing arguments, each of its
    # own C type (hir::cabi::VariadicArgument).
    set variadic [dict getdef $contract variadic 0]
    if {$variadic ni {0 1} || ($variadic && ($arity ne "*" || [llength $params] == 0 || $vars ne {}))} {
        error "core::native::register: -foreign of \"$name\": a variadic contract is the fixed parameters (at least one, no imprint variable) of a native of arity *"
    }
    if {!$variadic && ($arity eq "*" || [llength $params] != $arity)} {
        error "core::native::register: -foreign of \"$name\" must describe its $arity parameter(s)"
    }
    set names {}
    set normalized {}
    foreach param $params {
        if {[catch {dict size $param}] || ![dict exists $param name] || ![dict exists $param type]} {
            error "core::native::register: bad -foreign parameter \"$param\" of \"$name\" (expected {name N type T ...})"
        }
        set pname [dict get $param name]
        set type [CanonicalTerm [dict get $param type]]
        if {![regexp {^[A-Za-z_][A-Za-z0-9_]*$} $pname] || $pname in $names} {
            error "core::native::register: -foreign parameter name \"$pname\" of \"$name\" is not a fresh name"
        }
        lappend names $pname
        set pointer [expr {[lindex $type 0] in {cptr cfnptr} && [llength $type] == 2}]
        foreach key [dict keys $param] {
            if {$key ni {name type access escape} || ($key in {access escape} && !$pointer)
                    || ($key eq "access" && [lindex $type 0] ne "cptr")} {
                error "core::native::register: -foreign parameter \"$pname\" of \"$name\" cannot have \"$key\" (access is a data pointer's fact, escape any pointer's)"
            }
        }
        set entry [dict create name $pname type $type]
        if {$pointer} {
            set access [dict getdef $param access "unknown"]
            set escape [dict getdef $param escape "unknown"]
            if {$access ni $accesses || $escape ni $escapes} {
                error "core::native::register: -foreign parameter \"$pname\" of \"$name\": access must be one of $accesses and escape one of $escapes"
            }
            if {$access eq "write" && $pname eq "result"} {
                error "core::native::register: -foreign write parameter of \"$name\" cannot be named \"result\": its updated bytes are the call result's field of its name, beside `result`"
            }
            dict set entry access $access
            dict set entry escape $escape
        }
        lappend normalized $entry
    }
    set result [CanonicalTerm [dict get $contract result]]
    set provenance [dict getdef $contract provenance "unknown"]
    if {$provenance ne "unknown"} {
        if {[lindex $result 0] ne "cptr" || [llength $result] != 2} {
            error "core::native::register: -foreign of \"$name\": only a data pointer result has a provenance"
        }
        if {[lindex $provenance 0] eq "alias" && [llength $provenance] == 2} {
            set target [lindex $provenance 1]
            set aliased [lsearch -exact -index 1 $normalized $target]
            if {$aliased < 0 || [dict get [lindex $normalized $aliased] type] ne $result} {
                error "core::native::register: -foreign of \"$name\": the result can alias only a data pointer parameter of its own type, and \"$target\" is none"
            }
        } elseif {$provenance ne "independent"} {
            error "core::native::register: -foreign of \"$name\": bad provenance \"$provenance\" (unknown, independent or {alias NAME})"
        }
    }
    set normalized [dict create vars $vars params $normalized result $result provenance $provenance]
    if {$variadic} {
        dict set normalized variadic 1
    }
    return $normalized
}

# The ABI class a trailing argument of a variadic C call is passed as, for
# the C integer scalar of metadata INFO ({c SPELLING target TARGET bits N
# signed 0|1}): C's default argument promotion on INFO's target. A type
# narrower than `int` becomes `int` (int represents every value of every
# narrower type on every target of the table, unsigned char and unsigned
# short included), any other keeps its own representation: iN or uN.
proc core::cabi::promoted {info} {
    set int [scalarInfo Int [dict get $info target]]
    set bits [dict get $info bits]
    if {$bits < [dict get $int bits]} {
        return i[dict get $int bits]
    }
    return [expr {[dict get $info signed] ? "i" : "u"}]$bits
}

# The ABI class a C _Bool trailing argument of a variadic call is passed as
# on TARGET: C's default argument promotion makes it an `int`. TARGET ""
# (a compilation that declares no C scalar) is any target's: every data
# model of the table has one `int` width.
proc core::cabi::promotedBool {target} {
    variable models
    if {$target ne ""} {
        return i[dict get [scalarInfo Int $target] bits]
    }
    set widths [lsort -unique [lmap {model widths} $models {dict get $widths int}]]
    if {[llength $widths] != 1} {
        error "core::cabi: the data models disagree on int's width; a _Bool trailing argument needs the compilation's target"
    }
    return i$widths
}

# The parameter index the result of CONTRACT aliases (provenance {alias
# NAME}), or -1.
proc core::cabi::AliasIndex {contract} {
    set provenance [dict get $contract provenance]
    if {[lindex $provenance 0] ne "alias"} {
        return -1
    }
    return [lsearch -exact -index 1 [dict get $contract params] [lindex $provenance 1]]
}

# The HIR type term TYPE in its canonical text (a list rebuilt at every
# level: {refined int {std::ffi::c::UChar}} is `refined int std::ffi::c::UChar`), the
# form types are compared in.
proc core::cabi::CanonicalTerm {type} {
    if {[llength $type] <= 1} {
        return [lindex $type 0]
    }
    if {[lindex $type 0] eq "fn" && [llength $type] == 2} {
        # A function signature (a FnPtr's, C-ABI-TYPES.md) is a dict whose
        # `args` is a list of types: one argument is a one-element list,
        # never a type of its own.
        set fields [lindex $type 1]
        dict set fields args [lmap arg [dict get $fields args] {CanonicalTerm $arg}]
        dict set fields return [CanonicalTerm [dict get $fields return]]
        return [list fn $fields]
    }
    return [lmap element $type {CanonicalTerm $element}]
}

# The pointer parameters of CONTRACT that may retain pointer authority past
# the call (escape captures or unknown), as {INDEX NAME ESCAPE}: the reasons
# a raw call of it is capability-escaping (the future `direct`, C-POINTER-
# BORROWING.md "direct"). A function pointer counts as any pointer does: a
# stored callback is retained authority.
proc core::cabi::RetainingParameters {contract} {
    set reasons {}
    set index 0
    foreach param [dict get $contract params] {
        if {[dict exists $param escape] && ![isNoescape [dict get $param escape]]} {
            lappend reasons [list $index [dict get $param name] [dict get $param escape]]
        }
        incr index
    }
    return $reasons
}

# The byte storage kind ("bytestore" or "mutbytes") a run-time value V owns
# when it is a std::abi::bytes::Bytes or std::abi::bytes::MutableBytes, else "".
proc core::cabi::OwnerKind {v} {
    if {[core::value::kind $v] ne "struct"} {
        return ""
    }
    set id [core::value::structId $v]
    if {$id eq [core::bytestore::bytesType] || $id eq [core::bytestore::mutableBytesType]} {
        set storage [core::value::structGet $v [core::bytestore::storageField]]
        return [core::value::kind $storage]
    }
    return ""
}

# The entry of the implementation IMPL of every -foreign native NAME on the
# Tcl backends (core/native.tcl wraps it): each argument that is byte
# storage at a pointer parameter is exposed for the call, as {exposure ID},
# and every exposure is closed when the call ends, normally or not. A write
# exposure's bytes after a normal return become the updated MutableBytes of
# its parameter, and the call's value {result: R, NAME: ...}. A failing call
# (a declared error, propagated) publishes nothing: the private copy C wrote
# is discarded, and the caller's own value never changed.
#
# What a static check proved is rechecked here only where a run-time value
# can show it (an unchecked, -strict 0 program): a byte owner at a parameter
# that may retain the pointer, whose access is unknown, or an immutable
# Bytes given write access, is refused (TYPE) before IMPL runs.
proc core::cabi::ForeignBoundary {name impl args} {
    variable exposures
    variable exposureCounter
    set contract [dict get [core::native::metadata $name] foreign]
    set callArgs {}
    set opened {}
    set writes {}
    foreach arg $args param [dict get $contract params] {
        if {[dict exists $param access]} {
            set kind [OwnerKind $arg]
        } else {
            set kind ""
        }
        if {$kind eq ""} {
            lappend callArgs $arg
            continue
        }
        set access [dict get $param access]
        set escape [dict get $param escape]
        if {![isNoescape $escape] || $access eq "unknown" || ($kind eq "bytestore" && $access eq "write")} {
            foreach id $opened {
                dict unset exposures $id
            }
            core::semanticError TYPE \
                "$name: byte storage cannot be exposed to parameter \"[dict get $param name]\" (access $access, escape $escape): only a noescape parameter of known access admits it, and an immutable Bytes only for reading"
        }
        set storage [core::value::structGet $arg [core::bytestore::storageField]]
        if {$kind eq "bytestore"} {
            set hex [core::value::bytestoreHex $storage]
        } else {
            set hex [core::value::mutbytesHex $storage]
        }
        set id [incr exposureCounter]
        dict set exposures $id [dict create access $access hex $hex]
        lappend opened $id
        if {$access eq "write"} {
            lappend writes [dict get $param name] $id
        }
        lappend callArgs [list exposure $id]
    }
    try {
        set result [{*}$impl {*}$callArgs]
        if {$writes eq ""} {
            return $result
        }
        set fields [dict create result $result]
        foreach {pname id} $writes {
            dict set fields $pname [core::value::structOf \
                [list [core::bytestore::mutableBytesType] [core::bytestore::storageField]] \
                [list [core::value::mutbytes [dict get $exposures $id hex]]]]
        }
        set names [lsort [dict keys $fields]]
        return [core::value::structOf [list {} {*}$names] [lmap n $names {dict get $fields $n}]]
    } finally {
        foreach id $opened {
            dict unset exposures $id
        }
    }
}

# The exposure ID of pointer argument P ({exposure ID}), or "" for a raw C
# address ({cptr ADDRESS}). CONTEXT names the operation for errors. An
# exposure that has ended (its call returned) is gone: using one is an
# internal error, never a read of stale bytes.
proc core::cabi::ExposureOf {p context} {
    variable exposures
    if {[lindex $p 0] eq "exposure" && [llength $p] == 2} {
        set id [lindex $p 1]
        if {![dict exists $exposures $id]} {
            error "$context: exposure $id has ended: an exposure lives only for the call it was made for"
        }
        return $id
    }
    addressOf $p
    return ""
}

# The COUNT bytes (a list of Ints) at OFFSET of pointer argument P, a read
# through the exposure. A raw C address on the Tcl backends reaches no
# memory: only a zero-byte access is possible.
proc core::cabi::ExposedBytes {p offset count context} {
    variable exposures
    set id [ExposureOf $p $context]
    if {$id eq ""} {
        if {$count != 0} {
            core::semanticError NATIVE-ONLY \
                "$context reads $count byte(s) through a raw C address, which only the native backend can do: the Tcl backends have no machine memory"
        }
        return {}
    }
    set hex [dict get $exposures $id hex]
    if {$offset < 0 || $offset + $count > [string length $hex] / 2} {
        error "$context: a read of $count byte(s) at $offset is outside the [expr {[string length $hex] / 2}] exposed bytes (a C operation's contract keeps it inside what its caller passes)"
    }
    if {$count == 0} {
        return {}
    }
    binary scan [binary decode hex [string range $hex [expr {2 * $offset}] [expr {2 * ($offset + $count) - 1}]]] cu* bytes
    return $bytes
}

# Writes BYTES (Ints in 0..255) at OFFSET through pointer argument P, a write
# exposure. A read exposure is never written: that would be C writing
# through a const pointer, which the contract rules out (an internal error
# here, where it can be seen; natively it would be undefined).
proc core::cabi::StoreExposed {p offset bytes context} {
    variable exposures
    set id [ExposureOf $p $context]
    if {$id eq ""} {
        if {[llength $bytes] != 0} {
            core::semanticError NATIVE-ONLY \
                "$context writes [llength $bytes] byte(s) through a raw C address, which only the native backend can do: the Tcl backends have no machine memory"
        }
        return
    }
    if {[dict get $exposures $id access] ne "write"} {
        error "$context: a write through read exposure $id: C may not modify what it was given to read"
    }
    set hex [dict get $exposures $id hex]
    set count [llength $bytes]
    if {$offset < 0 || $offset + $count > [string length $hex] / 2} {
        error "$context: a write of $count byte(s) at $offset is outside the [expr {[string length $hex] / 2}] exposed bytes"
    }
    if {$count == 0} {
        return
    }
    set new [binary encode hex [binary format cu* $bytes]]
    dict set exposures $id hex [string replace $hex [expr {2 * $offset}] [expr {2 * ($offset + $count) - 1}] $new]
}

# The implementation of every `extern c fn`'s native on the Tcl backends
# (C-FFI.md, "Backends"): there is no machine to call C on, so the call is
# refused -- after core::cabi::ForeignBoundary opened (and then closes) its
# exposures, so a refused call publishes nothing. Nothing fabricates an
# address or imitates the C function.
#
# The boundary's own conversions come first, as on every backend: a Float64
# argument of a C float parameter that rounds to no finite binary32 fails
# the call with NonFiniteFloat before anything would call C (Narrow; the
# conversion is the declaration's, not the machine's).
proc core::cabi::ExternImpl {display args} {
    set meta [core::native::metadata extern#$display]
    set classes [dict get $meta extern abi params]
    foreach v $args class $classes {
        if {$class eq "f32"} {
            NarrowValue $display binary32 $v
        }
    }
    core::semanticError NATIVE-ONLY \
        "$display is a C function (extern c fn): calling it runs only on the native backends (cranelift, cranelift-generic, a native executable), which link and call the C library; the Tcl backends have no machine to call it on"
}

# The replay of a byte exposure the static check refused, for an unchecked
# (-strict 0) program on the interpreter (hir/lower.tcl lowers such a call to
# a call of it, after the arguments; the Tcl compiler and native lowering
# emit the same error themselves): a run-time TYPE error with the
# refusal's message. Internal: `#` is no name source can spell.
proc core::cabi::refusedNative {} { return foreign#refused }

proc core::cabi::RefusedImpl {message args} {
    core::semanticError TYPE [core::value::strOf $message]
}

core::native::register [core::cabi::refusedNative] -arity * -impl core::cabi::RefusedImpl \
    -result-type any -result-shape never

# ---------------------------------------------------------------------------
# The private borrow test fixture (C-POINTER-BORROWING.md, "The fixture").
# There is no C call yet: tests that must see a foreign operation use these
# synthetic, synchronous ones, which read and write the bytes they are given
# through the pointer -- natively through the real payload address
# (native/src/runtime/ops.rs's rt_ffi_fixture_*), on the Tcl backends through
# the exposure. installBorrowFixture registers them in the calling (test)
# process only, like installTestFixture: nothing in the compiler, the
# libraries or main.tcl calls it, so no program outside a test can name
# them. Their contracts cover every access x escape combination a borrow
# decision reads:
#
#   read[T](data, count) -> List[int]           the COUNT bytes at DATA
#   read_reentrant[T](data, count) -> List[int] the same, after letting
#                                               Botlish collect and allocate
#                                               (a foreign operation that
#                                               runs Botlish code mid-call)
#   fill[T](out, count, seed) -> unit           writes byte i = (SEED + 37 i)
#                                               mod 256, i < COUNT
#   fill_checked(out, count, limit) -> unit errors UpperOverrun
#                                               writes min(COUNT, LIMIT)
#                                               bytes (91 + 37 i) mod 256,
#                                               then fails if COUNT > LIMIT
#   copy(dst, src, count) -> unit               DST[i] = SRC[i], i < COUNT
#   mixed(input, state, output, count) -> ULong OUTPUT[i] = INPUT[COUNT-1-i];
#                                               the sum of INPUT's bytes;
#                                               STATE is a userdata pointer
#                                               it may retain (it touches
#                                               nothing through it)
#
# with read_proven, read_retained (captures), read_unknown (escape unknown),
# read_unspecified (no facts) and read_unknown_access (noescape, access
# unknown) beside read, and fill_proven, fill_retained and fill_unknown
# beside fill.

namespace eval core::cabi {
    # NAME -> {BEHAVIOR VARS PARAMS RESULT ERRORS}; parameter facts as in a
    # -foreign contract. T is the pointee where a variable names it.
    variable borrowFixture {}
}

proc core::cabi::BorrowFixtureTable {} {
    set uchar {refined int {std::ffi::c::UChar}}
    set ulong {refined int {std::ffi::c::ULong}}
    set count [list name count type $ulong]
    set table {}
    foreach {suffix facts} {
        "" {access read escape declared-noescape}
        _proven {access read escape proven-noescape}
        _reentrant {access read escape declared-noescape}
        _retained {access read escape captures}
        _unknown {access read escape unknown}
        _unspecified {}
        _unknown_access {escape declared-noescape}
    } {
        set behavior [expr {$suffix eq "_reentrant" ? "read-reentrant" : "read"}]
        lappend table read$suffix [list $behavior {T} \
            [list [dict merge [list name data type {cptr {imprint T}}] $facts] $count] {list int} {}]
    }
    foreach {suffix escape} {"" declared-noescape _proven proven-noescape _retained captures _unknown unknown} {
        lappend table fill$suffix [list fill {T} \
            [list [list name out type {cptr {imprint T}} access write escape $escape] $count \
                [list name seed type $uchar]] unit {}]
    }
    lappend table fill_checked [list fill-checked {} \
        [list [list name out type [list cptr $uchar] access write escape declared-noescape] $count \
            [list name limit type $ulong]] unit {UpperOverrun}]
    lappend table copy [list copy {} \
        [list [list name dst type [list cptr $uchar] access write escape declared-noescape] \
            [list name src type [list cptr $uchar] access read escape declared-noescape] $count] unit {}]
    lappend table mixed [list mixed {} \
        [list [list name input type [list cptr $uchar] access read escape declared-noescape] \
            [list name state type {cptr void} escape captures] \
            [list name output type [list cptr $uchar] access write escape declared-noescape] $count] $ulong {}]
    return $table
}

# The fixture natives' names (ffi_fixture::NAME) and behaviors, in
# registration order: what native/lower.tcl maps to its fixture ops.
proc core::cabi::borrowFixture {} {
    set result {}
    foreach {name entry} [BorrowFixtureTable] {
        lappend result ffi_fixture::$name [lindex $entry 0]
    }
    return $result
}

proc core::cabi::installBorrowFixture {} {
    if {[core::native::isQualifiedNative ffi_fixture::read]} {
        return
    }
    foreach {name entry} [BorrowFixtureTable] {
        lassign $entry behavior vars params result errors
        set kinds [lmap p $params {expr {[lindex [dict get $p type] 0] in {cptr cfnptr} ? "any" : "int"}}]
        core::native::register ffi_fixture::$name -arity [llength $params] \
            -impl [list core::cabi::FixtureImpl $behavior ffi_fixture::$name] \
            -param-types $kinds -result-type any -errors $errors \
            -ownership [lrepeat [llength $params] observe] \
            -foreign [dict create vars $vars params $params result $result]
    }
}

# The Tcl model of fixture BEHAVIOR (core::cabi::BorrowFixtureTable), given
# the arguments as ForeignBoundary passes them (an exposure or a raw address
# for a pointer, an Int otherwise).
proc core::cabi::FixtureImpl {behavior name args} {
    set ints [lmap a $args {if {[lindex $a 0] eq "int"} {core::value::intOf $a} else {string cat ""}}]
    switch -- $behavior {
        read - read-reentrant {
            set bytes [ExposedBytes [lindex $args 0] 0 [lindex $ints 1] $name]
            return [core::value::listOf [lmap b $bytes {core::value::intFromNumber $b}]]
        }
        fill {
            lassign $ints - count seed
            set bytes {}
            for {set i 0} {$i < $count} {set i [expr {$i + 1}]} {
                lappend bytes [expr {($seed + 37 * $i) % 256}]
            }
            StoreExposed [lindex $args 0] 0 $bytes $name
            return [core::value::unit]
        }
        fill-checked {
            lassign $ints - count limit
            set n [expr {min($count, $limit)}]
            set bytes {}
            for {set i 0} {$i < $n} {set i [expr {$i + 1}]} {
                lappend bytes [expr {(91 + 37 * $i) % 256}]
            }
            StoreExposed [lindex $args 0] 0 $bytes $name
            if {$count > $limit} {
                core::native::failDeclared UpperOverrun "$name: $count byte(s) asked, $limit allowed"
            }
            return [core::value::unit]
        }
        copy {
            set count [lindex $ints 2]
            StoreExposed [lindex $args 0] 0 [ExposedBytes [lindex $args 1] 0 $count $name] $name
            return [core::value::unit]
        }
        mixed {
            set count [lindex $ints 3]
            ExposureOf [lindex $args 1] $name
            set input [ExposedBytes [lindex $args 0] 0 $count $name]
            StoreExposed [lindex $args 2] 0 [lreverse $input] $name
            return [core::value::intFromNumber [tcl::mathop::+ 0 {*}$input]]
        }
    }
    error "core::cabi::FixtureImpl: unknown behavior $behavior"
}
