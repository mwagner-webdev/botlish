# syscall.tcl -- the static contract of the Linux syscall transports
# (core/linuxabi.tcl, LINUX-X86-64-SYSCALL.md, LINUX-SYSCALL-TRANSPORTS.md):
# the one argument of std::linux::abi::x86_64::syscall and of
# std::linux::abi::aarch64::syscall is a syscall-input description, an anonymous
# struct naming that architecture's Linux syscall registers, each holding the
# architecture's own Register64 (std::abi::x86_64::Register64,
# std::abi::aarch64::Register64).
#
#   hir::syscall::verify HIRVAR      diagnostics, part of hir::CheckOnce
#
# Botlish has no annotation for an anonymous struct type and no optional
# fields (STRUCTS.md: anonymous structs are inferred, never spelled, never
# width-subtyped), so a transport's parameter is checked here, against the
# argument's statically inferred struct type, instead of through a new
# general optional-field system:
#
#   * the argument's static type is an anonymous struct (a named struct, or a
#     struct value whose fields are not statically known, is TYPE);
#   * every field is one of the transport's registers -- rax rdi rsi rdx r10
#     r8 r9 on x86-64, x8 x0 x1 x2 x3 x4 x5 on AArch64 -- (any other is
#     UNKNOWN-FIELD, located at that field when the argument is a literal):
#     the syscall-input registers, never an arbitrary CPU register;
#   * the number register (rax, x8) is present (MISSING-FIELD); an omitted
#     argument register is zero (the lowering's job, native/lower.tcl);
#   * every field is statically the transport's own Register64 (TYPE): no
#     runtime check is ever inserted, and the native backend relies on it --
#     a Register64's word is a proven -2^63..2^63-1 Int (stdlib/abi/x86_64.bot,
#     stdlib/abi/aarch64.bot) -- and the architectures are never mixed (an
#     std::abi::aarch64::Register64 is no x86-64 register).
#
# And a transport is only ever *called*: a reference to one that is not the
# callee of a direct call is TYPE. It has no function value -- its parameter
# type cannot be spelled in an Fn{...} contract, and a dynamic call would
# have to find register fields by name at run time.
#
# Nothing here knows any syscall number or signature: the contract is each
# architecture's syscall transport convention only.

namespace eval hir::syscall {}

proc hir::syscall::verify {hirVar} {
    upvar 1 $hirVar hir
    set callees [dict create]
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "call"} continue
        dict set callees [dict get $node callee] 1
        lassign [dict get $node target] targetKind target
        if {$targetKind ne "native"} continue
        set name [dict get [hir::symbol $hir $target] name]
        if {![core::linuxabi::isSyscall $name] && ![core::bytestore::isBridge $name]} continue
        if {![dict get $node reachable]} continue
        # (The call's own problems with its transport: hir::CheckingCall.)
        hir::CheckingCall $e {VerifyCall hir $e $node}
    }
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "ref" || [dict exists $callees $e]} continue
        set b [dict get $node binding]
        if {$b eq ""} continue
        set binding [hir::binding $hir $b]
        if {[dict get $binding kind] ne "root"} continue
        if {[core::linuxabi::isSyscall [dict get $binding name]]} {
            set native [dict get $binding name]
            hir::Diagnose hir TYPE \
                "$native can only be called directly: it is the raw kernel transition, not a function value (its register-struct parameter has no Fn{...} spelling, and a register is never looked up by name at run time)" $e
        } elseif {[core::bytestore::isBridge [dict get $binding name]]} {
            set bridge [dict get $binding name]
            hir::Diagnose hir TYPE \
                "$bridge can only be called directly: it is the raw address bridge, not a function value (an address is taken from one [core::bytestore::bridgeType $bridge] at one call and consumed by the syscall that call feeds)" $e
        }
    }
}

# The problems of one call E (NODE) of a transport or an address bridge.
proc hir::syscall::VerifyCall {hirVar e node} {
    upvar 1 $hirVar hir
    set name [dict get [hir::symbol $hir [lindex [dict get $node target] 1]] name]
    if {[core::bytestore::isBridge $name]} {
        set problems [BytesProblems $hir $e $node]
    } else {
        set problems [Problems $hir $e $node]
    }
    foreach problem $problems {
        lassign $problem kind message expr origin
        if {$origin eq ""} {
            hir::Diagnose hir $kind $message $expr
        } else {
            hir::DiagnoseAt hir $kind $message $expr $origin
        }
    }
}

# Every way call E (NODE, in HIR -- the program's, or one instance's view) of
# the native breaks its contract: a list of {KIND MESSAGE EXPR ORIGIN},
# ORIGIN "" for EXPR's own. hir::CheckOnce reports them (VerifyCall); native
# lowering (native/lower.tcl's SyscallCall) asks again of the HIR it lowers,
# so a -strict 0 program it compiles anyway replays the problem at run time
# instead of reading registers nothing proved.
#
# An inline literal argument is checked field by field, from each field's
# own name and value type, so the whole literal's type being `never` (one
# field cannot complete) hides nothing about its other fields; a field whose
# own value cannot complete has no register to check.
proc hir::syscall::Problems {hir e node} {
    set native [dict get [hir::symbol $hir [lindex [dict get $node target] 1]] name]
    set arch [core::linuxabi::transportOf $native]
    set label [core::linuxabi::transport $arch label]
    set abi [core::linuxabi::transport $arch abi]
    set registers [core::linuxabi::registers $native]
    set number [lindex $registers 0]
    set args [dict get $node args]
    if {[llength $args] != 1} {
        return [list [list ARITY \
            "$native takes exactly one argument, the register struct {$number: ..., [lindex $registers 1]: ..., ...} ([llength $args] given)" $e ""]]
    }
    set arg [lindex $args 0]
    set expected "an anonymous struct of syscall registers, {$number: ${abi}::register64(NUMBER), [lindex $registers 1]: ..., ...} (fields among [join $registers {, }]; $number required)"
    set fields {}
    if {[hir::kind $hir $arg] eq "struct" && ![hir::get $hir $arg named]} {
        # name -> {VALUE-TYPE NAME-ORIGIN VALUE-ORIGIN}
        set argNode [hir::node $hir $arg]
        foreach name [dict get $argNode names] field [dict get $argNode fields] \
                nameOrigin [dict get $argNode nameOrigins] valueOrigin [dict get $argNode fieldOrigins] {
            dict set fields $name [list [hir::typeOf $hir $field] $nameOrigin $valueOrigin]
        }
    } else {
        set type [hir::typeOf $hir $arg]
        if {$type eq "never"} {
            return {}
        }
        if {[hir::types::IsNamedStruct $type] || ![hir::types::IsStruct $type]} {
            return [list [list TYPE \
                "the argument of $native must be $expected; its type here is [hir::types::show $type]" $arg ""]]
        }
        foreach name [hir::types::StructLayout $type] {
            dict set fields $name [list [hir::types::StructField $type $name] "" ""]
        }
    }
    set problems {}
    set registerType [core::linuxabi::registerType $native]
    # The abi module's file, for the message (std::abi::x86_64 is
    # stdlib/abi/x86_64.bot: STD-NAMESPACE.md).
    set abiFile stdlib/[string map {:: /} [regsub {^std::} $abi {}]].bot
    dict for {name info} $fields {
        lassign $info fieldType nameOrigin valueOrigin
        if {$name ni $registers} {
            lappend problems [list UNKNOWN-FIELD \
                "\"$name\" is not a syscall register: $native's argument may name only [join $registers {, }] (the Linux $label syscall number and its six argument registers; an omitted argument register is zero)" \
                $arg $nameOrigin]
            continue
        }
        if {$fieldType eq "never"} {
            continue
        }
        if {![hir::structs::declared $registerType] || ![hir::types::subtype $fieldType [list nstruct $registerType]]} {
            lappend problems [list TYPE \
                "syscall register \"$name\" must be a $registerType (${abi}::register64(...), $abiFile): a register holds one 64-bit word, never an arbitrary value, and no run-time check is inserted; its type here is [hir::types::show $fieldType]" \
                $arg $valueOrigin]
        }
    }
    if {![dict exists $fields $number]} {
        lappend problems [list MISSING-FIELD \
            "$native's argument has no field \"$number\": $number carries the syscall number and is required (only the argument registers [join [lrange $registers 1 end] {, }] may be omitted, as zero)" $arg ""]
    }
    return $problems
}

# Every way call E (NODE) of an address bridge (ABI::from_bytes or
# ABI::from_mutable_bytes, ABI std::abi::x86_64 or std::abi::aarch64: core/
# bytestore.tcl) breaks its contract: a list of {KIND MESSAGE EXPR ORIGIN},
# as Problems. A bridge takes exactly one
# argument, and it must statically be the bridge's own opaque struct -- an
# std::abi::bytes::Bytes for the readable bridge, a std::abi::bytes::MutableBytes for the writable
# one, never the other: no run-time check is ever inserted, and native
# lowering relies on it: it reads the struct's one storage field without
# looking at the value's kind. (An opaque struct cannot be forged: only
# module abi can construct one, OPAQUE-STRUCTS.md, so a static std::abi::bytes::Bytes
# always holds a byte storage and a static std::abi::bytes::MutableBytes a writable one.)
proc hir::syscall::BytesProblems {hir e node} {
    set native [dict get [hir::symbol $hir [lindex [dict get $node target] 1]] name]
    set bytesType [core::bytestore::bridgeType $native]
    set args [dict get $node args]
    if {[llength $args] != 1} {
        return [list [list ARITY \
            "$native takes exactly one argument, a $bytesType ([llength $args] given)" $e ""]]
    }
    set arg [lindex $args 0]
    set type [hir::typeOf $hir $arg]
    if {$type eq "never"} {
        return {}
    }
    if {![hir::structs::declared $bytesType] || ![hir::types::subtype $type [list nstruct $bytesType]]} {
        return [list [list TYPE \
            "the argument of $native must be a $bytesType ([expr {[core::bytestore::bridgeWritable $native] ? "std::abi::bytes::zeroed(...)" : "std::abi::bytes::from_list(...)"}], stdlib/abi/bytes.bot): the address of an arbitrary value has no meaning, a readable Bytes is never a writable address and a MutableBytes is never a readable one, and no run-time check is inserted; its type here is [hir::types::show $type]" \
            $arg ""]]
    }
    return {}
}
