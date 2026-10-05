# syscall.tcl -- the static contract of linux::abi::syscall (core/
# linuxabi.tcl, LINUX-X86-64-SYSCALL.md): its one argument is a syscall-
# input description, an anonymous struct naming Linux x86-64 syscall
# registers, each holding an abi::x86_64::Register64.
#
#   hir::syscall::verify HIRVAR      diagnostics, part of hir::CheckOnce
#
# Botlish has no annotation for an anonymous struct type and no optional
# fields (STRUCTS.md: anonymous structs are inferred, never spelled, never
# width-subtyped), so this one native's parameter is checked here, against
# the argument's statically inferred struct type, instead of through a new
# general optional-field system:
#
#   * the argument's static type is an anonymous struct (a named struct, or a
#     struct value whose fields are not statically known, is TYPE);
#   * every field is one of rax rdi rsi rdx r10 r8 r9 (any other is
#     UNKNOWN-FIELD, located at that field when the argument is a literal):
#     the syscall-input registers, never an arbitrary CPU register;
#   * rax, the syscall number, is present (MISSING-FIELD); an omitted
#     argument register is zero (the lowering's job, native/lower.tcl);
#   * every field is statically an abi::x86_64::Register64 (TYPE): no
#     runtime check is ever inserted, and the native backend relies on it --
#     a Register64's word is a proven -2^63..2^63-1 Int (lib/abi/x86_64.bot).
#
# And the native is only ever *called*: a reference to linux::abi::syscall
# that is not the callee of a direct call is TYPE. It has no function value
# -- its parameter type cannot be spelled in an Fn{...} contract, and a
# dynamic call would have to find register fields by name at run time.
#
# Nothing here knows any syscall number or signature: the contract is the
# x86-64 syscall transport convention only.

namespace eval hir::syscall {
    variable native linux::abi::syscall
}

proc hir::syscall::verify {hirVar} {
    upvar 1 $hirVar hir
    variable native
    set callees [dict create]
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "call"} continue
        dict set callees [dict get $node callee] 1
        lassign [dict get $node target] targetKind target
        if {$targetKind ne "native"} continue
        set name [dict get [hir::symbol $hir $target] name]
        if {$name ne $native && ![core::bytestore::isBridge $name]} continue
        if {![dict get $node reachable]} continue
        VerifyCall hir $e $node
    }
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "ref" || [dict exists $callees $e]} continue
        set b [dict get $node binding]
        if {$b eq ""} continue
        set binding [hir::binding $hir $b]
        if {[dict get $binding kind] ne "root"} continue
        if {[dict get $binding name] eq $native} {
            hir::Diagnose hir TYPE \
                "$native can only be called directly: it is the raw kernel transition, not a function value (its register-struct parameter has no Fn{...} spelling, and a register is never looked up by name at run time)" $e
        } elseif {[core::bytestore::isBridge [dict get $binding name]]} {
            set bridge [dict get $binding name]
            hir::Diagnose hir TYPE \
                "$bridge can only be called directly: it is the raw address bridge, not a function value (an address is taken from one [core::bytestore::bridgeType $bridge] at one call and consumed by the syscall that call feeds)" $e
        }
    }
}

# The problems of one call E (NODE) of either native of this file.
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
    variable native
    set args [dict get $node args]
    if {[llength $args] != 1} {
        return [list [list ARITY \
            "$native takes exactly one argument, the register struct {rax: ..., rdi: ..., ...} ([llength $args] given)" $e ""]]
    }
    set arg [lindex $args 0]
    set registers [core::linuxabi::registers]
    set expected "an anonymous struct of syscall registers, {rax: abi::x86_64::register64(NUMBER), rdi: ..., ...} (fields among [join $registers {, }]; rax required)"
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
    set registerType [core::linuxabi::registerType]
    dict for {name info} $fields {
        lassign $info fieldType nameOrigin valueOrigin
        if {$name ni $registers} {
            lappend problems [list UNKNOWN-FIELD \
                "\"$name\" is not a syscall register: $native's argument may name only [join $registers {, }] (the Linux x86-64 syscall number and its six argument registers; an omitted argument register is zero)" \
                $arg $nameOrigin]
            continue
        }
        if {$fieldType eq "never"} {
            continue
        }
        if {![hir::structs::declared $registerType] || ![hir::types::subtype $fieldType [list nstruct $registerType]]} {
            lappend problems [list TYPE \
                "syscall register \"$name\" must be an $registerType (abi::x86_64::register64(...), lib/abi/x86_64.bot): a register holds one 64-bit word, never an arbitrary value, and no run-time check is inserted; its type here is [hir::types::show $fieldType]" \
                $arg $valueOrigin]
        }
    }
    if {![dict exists $fields rax]} {
        lappend problems [list MISSING-FIELD \
            "$native's argument has no field \"rax\": rax carries the syscall number and is required (only the argument registers [join [lrange $registers 1 end] {, }] may be omitted, as zero)" $arg ""]
    }
    return $problems
}

# Every way call E (NODE) of an address bridge (abi::x86_64::from_bytes or
# abi::x86_64::from_mutable_bytes, core/bytestore.tcl) breaks its contract: a
# list of {KIND MESSAGE EXPR ORIGIN}, as Problems. A bridge takes exactly one
# argument, and it must statically be the bridge's own opaque struct -- an
# abi::Bytes for the readable bridge, an abi::MutableBytes for the writable
# one, never the other: no run-time check is ever inserted, and native
# lowering relies on it: it reads the struct's one storage field without
# looking at the value's kind. (An opaque struct cannot be forged: only
# module abi can construct one, OPAQUE-STRUCTS.md, so a static abi::Bytes
# always holds a byte storage and a static abi::MutableBytes a writable one.)
proc hir::syscall::BytesProblems {hir e node} {
    set native [dict get [hir::symbol $hir [lindex [dict get $node target] 1]] name]
    set bytesType [core::bytestore::bridgeType $native]
    set args [dict get $node args]
    if {[llength $args] != 1} {
        return [list [list ARITY \
            "$native takes exactly one argument, an $bytesType ([llength $args] given)" $e ""]]
    }
    set arg [lindex $args 0]
    set type [hir::typeOf $hir $arg]
    if {$type eq "never"} {
        return {}
    }
    if {![hir::structs::declared $bytesType] || ![hir::types::subtype $type [list nstruct $bytesType]]} {
        return [list [list TYPE \
            "the argument of $native must be an $bytesType ([expr {[core::bytestore::bridgeWritable $native] ? "abi::mutable_bytes(...)" : "abi::bytes(...)"}], lib/abi.bot): the address of an arbitrary value has no meaning, a readable Bytes is never a writable address and a MutableBytes is never a readable one, and no run-time check is inserted; its type here is [hir::types::show $type]" \
            $arg ""]]
    }
    return {}
}
