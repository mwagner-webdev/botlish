# fuzz.tcl -- a small type-formation fuzzer of the C ABI type universe
# (C-ABI-TYPES.md).
#
#   tclsh9.0 audit/c-abi-types/tools/fuzz.tcl ?-n N? ?-seed S? ?-verbose 0|1?
#
# Each program is one of three shapes, drawn at random, with its expected
# outcome computed by an independent model in this file (never by asking the
# compiler):
#
#   pointer  a pointer type nested 0..5 deep over a random base pointee --
#            ffi::c::Void, a C scalar, an opaque struct, a function pointer
#            or (sometimes) an invalid one (int, str, List[int], an ordinary
#            struct, a non-C domain) -- then a chain of 1..6 operations
#            starting from ffi::c::null[T]() or the test fixture's address
#            N: clone, erase (a data pointer to Ptr[Void]), retype[U] (drawn
#            mostly from Ptr[Void], rarely from anything else, where the
#            model expects a rejection), finished by a function whose parameter is declared
#            with the type the model says the chain has, which returns the
#            address bits and the null test. The model tracks the static type
#            and the address: an invalid pointee or retype is a compile-time
#            TYPE/IMPRINT rejection, everything else runs on every backend
#            and must return the model's [address, null?].
#   scalar   a C integer scalar on a random target with a value at or just
#            past one of its bounds or inside it: admitted exactly when the
#            model's range (the target's data model, independently written
#            here) contains it, and then returned unchanged by every backend
#            that runs the target's programs on this host (backendsFor: all
#            four for the host's target, the Tcl backends for another).
#   imprint  a user function with imprint variables called with or without
#            explicit imprints, valid or not by the model's rules.
#
# The last line is "programs N disagreements D"; every disagreement is
# printed with its program.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set options [dict create -n 40 -seed 1 -verbose 0]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}
set ::argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
core::cabi::installTestFixture

expr {srand([dict get $options -seed])}
proc pick {list} { return [lindex $list [expr {int(rand() * [llength $list])}]] }
proc chance {p} { return [expr {rand() < $p}] }

set backends {interp compile cranelift-generic cranelift}

# The model's data models, written independently of core/cabi.tcl.
set modelWidths {
    linux-x86_64    {Char {8 1} Long 64}
    linux-aarch64   {Char {8 0} Long 64}
    macos-aarch64   {Char {8 1} Long 64}
    windows-x86_64  {Char {8 1} Long 32}
    windows-x86_64-gnu {Char {8 1} Long 32}
    windows-aarch64 {Char {8 1} Long 32}
}
proc modelRange {target name} {
    set w [dict get $::modelWidths $target]
    switch -- $name {
        Char { lassign [dict get $w Char] bits signed }
        SChar { set bits 8; set signed 1 }
        UChar { set bits 8; set signed 0 }
        Short { set bits 16; set signed 1 }
        UShort { set bits 16; set signed 0 }
        Int { set bits 32; set signed 1 }
        UInt { set bits 32; set signed 0 }
        Long { set bits [dict get $w Long]; set signed 1 }
        ULong { set bits [dict get $w Long]; set signed 0 }
        LongLong { set bits 64; set signed 1 }
        ULongLong { set bits 64; set signed 0 }
    }
    if {$signed} {
        return [list [expr {-(2 ** ($bits - 1))}] [expr {2 ** ($bits - 1) - 1}]]
    }
    return [list 0 [expr {2 ** $bits - 1}]]
}

set prelude {import ffi::c
import ffi_fixture
import binary

opaque struct SSL:
    tag: unit

opaque struct Ctx:
    tag: unit

struct Plain:
    x: int

}

set scalars {Char SChar UChar Short UShort Int UInt Long ULong LongLong ULongLong}
set fnSig {ffi::c::FnPtr[Fn{args: [ffi::c::Ptr[ffi::c::Void]], return: ffi::c::Int}]}

# A random pointee base: {SPELLING VALID}.
proc base {} {
    if {[chance 0.08]} {
        return [list [pick {int str List[int] Plain binary::U32}] 0]
    }
    return [list [pick [list ffi::c::Void ffi::c::[pick $::scalars] ffi::c::Bool SSL Ctx $::fnSig]] 1]
}

proc ptrOf {t} { return "ffi::c::Ptr\[$t\]" }

# The pointer case: {SOURCE EXPECT}, EXPECT {reject} or {value TEXT}.
proc pointerCase {} {
    lassign [base] pointee valid
    for {set d [expr {int(rand() * 4)}]} {$d > 0} {incr d -1} {
        set pointee [ptrOf $pointee]
    }
    # Null, a small address, or one anywhere up to the fixture's largest
    # (2^59-1, what the native word holds): beyond 32 bits more often than not.
    set address [pick [list 0 0 [expr {int(rand() * 1000000) + 1}] \
        [expr {entier(rand() * (2 ** 59 - 1)) + 1}] [expr {2 ** 59 - 1}]]]
    set lines {}
    if {$address == 0} {
        lappend lines "    p0 = ffi::c::null\[$pointee\]()"
    } else {
        lappend lines "    p0 = ffi_fixture::address\[$pointee\]($address)"
    }
    set type [ptrOf $pointee]
    set ok $valid
    set i 0
    set steps [expr {1 + int(rand() * 6)}]
    for {set s 0} {$s < $steps} {incr s} {
        set next p[expr {$i + 1}]
        # Mostly valid chains: retype mostly from a Ptr[Void], rarely (a
        # rejection) from anything else.
        if {$type eq [ptrOf ffi::c::Void]} {
            set op [pick {clone retype retype erase}]
        } else {
            set op [expr {[chance 0.1] ? "retype" : [pick {clone erase erase}]}]
        }
        switch -- $op {
            clone {
                # clone observes: the source stays usable (and is used below).
                lappend lines "    $next = p$i.clone()"
                lappend lines "    k$i = p$i.null?()"
            }
            erase {
                lappend lines "    $next = ffi::c::erase(p$i)"
                set type [ptrOf ffi::c::Void]
            }
            retype {
                lassign [base] target targetValid
                lappend lines "    $next = ffi::c::retype\[$target\](p$i)"
                if {$type ne [ptrOf ffi::c::Void] || !$targetValid} {
                    set ok 0
                }
                set type [ptrOf $target]
            }
        }
        incr i
    }
    set source "${::prelude}fn take(p: $type) -> List\[int\]:\n    n = if p.null?():\n        1\n    else:\n        0\n    \[ffi_fixture::address_of(p), n\]\n\nfn f() -> List\[int\]:\n[join $lines \n]\n    take(p$i)\n\nf()\n"
    if {!$ok} {
        return [list $source reject]
    }
    return [list $source [list value "\[$address, [expr {$address == 0 ? 1 : 0}]\]"]]
}

# The scalar case.
proc scalarCase {} {
    set target [pick [dict keys $::modelWidths]]
    set name [pick $::scalars]
    lassign [modelRange $target $name] lo hi
    set value [pick [list $lo $hi [expr {$lo - 1}] [expr {$hi + 1}] [expr {$lo + int(rand() * 100)}]]]
    set source "import ffi::c\nfn f(x: ffi::c::$name) -> int:\n    x\n\nf($value)\n"
    set expect [expr {$value >= $lo && $value <= $hi ? [list value $value] : "reject"}]
    return [list $source $expect -target $target]
}

# The imprint case.
proc imprintCase {} {
    switch -- [pick {first explicit result-only bare count}] {
        first {
            set elem [pick {int str bool}]
            set literal [dict get {int 7 str {"s"} bool true} $elem]
            set source "fn wrap(xs: List\[T\]) -> List\[T\]:\n    xs\n\nfn take(ys: List\[$elem\]) -> int:\n    1\n\ntake(wrap(\[$literal\]))\n"
            return [list $source {value 1}]
        }
        explicit {
            set elem [pick {int str}]
            set other [pick {int str}]
            set literal [dict get {int 7 str {"s"}} $other]
            set source "fn wrap(xs: List\[T\]) -> List\[T\]:\n    xs\n\nfn take(ys: List\[$elem\]) -> int:\n    1\n\ntake(wrap\[$elem\](\[$literal\]))\n"
            return [list $source [expr {$elem eq $other ? {value 1} : "reject"}]]
        }
        result-only {
            set given [chance 0.5]
            set source "fn empty() -> List\[T\]:\n    \[\]\n\nfn take(ys: List\[int\]) -> int:\n    1\n\ntake(empty[expr {$given ? {[int]} : {}}]())\n"
            return [list $source [expr {$given ? {value 1} : "reject"}]]
        }
        bare {
            return [list "fn identity(x: T) -> T:\n    x\n\n1\n" reject]
        }
        count {
            set n [expr {1 + int(rand() * 3)}]
            set source "fn empty() -> List\[T\]:\n    \[\]\n\nx = empty\[[join [lrepeat $n int] {, }]\]()\n1\n"
            return [list $source [expr {$n == 1 ? {value 1} : "reject"}]]
        }
    }
}

set disagreements 0
for {set k 0} {$k < [dict get $options -n]} {incr k} {
    set kind [pick {pointer pointer pointer scalar imprint}]
    set case [${kind}Case]
    set args [lassign $case source expect]
    if {[catch {surface::compile $source -warnings off {*}$args} hir caught]} {
        set code [dict get $caught -errorcode]
        set got [expr {[lindex $code 0] in {CORE SURFACE} ? "reject" : "error: $hir"}]
    } else {
        # A program built for another target runs on the Tcl backends only:
        # the native driver refuses it (NATIVE TARGET).
        set outcomes [lsort -unique [lmap b [backendsFor [hir::cabi::targetOf $hir] $backends] {
            lrange [outcomeUnderHir $b $hir] 0 1
        }]]
        set got [expr {[llength $outcomes] == 1 ? [lindex $outcomes 0] : "backends disagree: $outcomes"}]
    }
    if {$got ne $expect} {
        incr disagreements
        puts "DISAGREE ($kind) expected $expect, got $got [expr {$args ne {} ? "($args)" : ""}]\n$source"
    } elseif {[dict get $options -verbose]} {
        puts "ok ($kind) $expect"
    }
}
puts "programs [dict get $options -n] disagreements $disagreements"
