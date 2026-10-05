# bytestore.tcl -- the owned byte storage behind abi::Bytes (ABI-BYTES.md),
# and the raw address bridge that reads it.
#
# abi::Bytes (lib/abi.bot) is an opaque struct: an ordinary immutable Botlish
# value whose representation belongs to module `abi`. Its one field holds a
# *byte storage*, a runtime value of its own kind (core/value.tcl,
# {bytestore HEX}; natively one heap object, header + length + the bytes in
# one allocation): an immutable, finite, contiguous sequence of bytes with an
# exact length. Two root natives in the `byte_store` namespace build and
# measure it, and one in `abi::x86_64` reads its machine address:
#
#   byte_store::from_list(List[Byte]) -> byte storage
#       EAGER conversion: the result owns its own copy of the bytes; it is
#       not a view of the List and does not retain it. Every element must be
#       an Int in 0..255 and is stored exactly: no `mod 256`, no signed
#       reinterpretation, no character coercion (an element that is not such
#       an Int is a TYPE error). Nothing terminates the sequence: a 0
#       element is an ordinary byte.
#   byte_store::byte_count(storage) -> Int
#       The exact byte count, 0 <= n <= the runtime's collection-length
#       ceiling (the same enforced bound a String's or List's length has).
#   abi::x86_64::from_bytes(abi::Bytes) -> abi::x86_64::Register64
#       The one operation that needs a machine: the address of the first
#       byte of the Bytes' payload, as register contents. The address of a
#       machine object exists only on the native backend, so the Tcl
#       backends refuse the call (NATIVE-ONLY), exactly as they refuse
#       linux::abi::syscall; nothing imitates an address.
#
# The writable counterpart (MUTABLE-BYTES.md) is a second, distinct runtime
# kind, `mutbytes` ({mutbytes HEX} in Tcl; KIND_MUTBYTES natively), behind
# abi::MutableBytes. A MutableBytes is a VALUE: no operation here ever
# changes a storage another value can observe. The family is
#
#   byte_store::mutable_new(n)           n zero bytes
#   byte_store::mutable_from(storage)    an independent writable copy of an
#                                        immutable byte storage
#   byte_store::mutable_count(m)         the (fixed) byte count
#   byte_store::mutable_set(m, i, b)     a storage equal to M except that
#                                        byte I is B -- natively a fresh
#                                        object cloned from M and then
#                                        written; M itself is never written
#   byte_store::mutable_copy(m)          a fresh storage equal to M: the
#                                        "detach" a writable foreign access
#                                        (linux::read) takes before it
#                                        writes (COW's detach, always taken)
#   byte_store::freeze(m)                the immutable byte storage holding
#                                        M's current bytes (a copy)
#   byte_store::freeze_prefix(m, n)      the first N bytes of M, likewise
#   abi::x86_64::from_mutable_bytes(abi::MutableBytes) -> Register64
#                                        the WRITABLE address bridge
#
# None of them is context-free: a mutable value is never a compile-time
# constant, so no two logical values can ever share one writable static
# storage.
#
# `byte_store` is the family namespace of the storage kind (like
# immutable_set for ImmutableSet). Nothing outside module `abi` can turn a
# storage value into an abi::Bytes (constructing one is representation
# authority: OPAQUE-STRUCTS.md), and a storage value alone gives no address,
# so these two natives cannot manufacture a pointer. There is deliberately no
# byte_store operation that reads, slices or iterates the bytes.

namespace eval core::bytestore {
    # The declaration identity of the opaque struct whose one field holds a
    # byte storage (lib/abi.bot), that field's name, and the qualified name of
    # the raw address bridge: the compiler's only knowledge of Bytes. Like
    # core::linuxabi::registerType for Register64, they come from one place.
    variable bytesType abi::Bytes
    variable storageField storage
    variable addressNative abi::x86_64::from_bytes
    # The writable counterpart: the declaration identity of abi::MutableBytes
    # (its one field is also named `storage`) and its address bridge.
    variable mutableBytesType abi::MutableBytes
    variable mutableAddressNative abi::x86_64::from_mutable_bytes
}

proc core::bytestore::mutableBytesType {} {
    variable mutableBytesType
    return $mutableBytesType
}

proc core::bytestore::mutableAddressNative {} {
    variable mutableAddressNative
    return $mutableAddressNative
}

# The address bridges, as {NAME TYPE WRITABLE}: the root native, the opaque
# struct its one argument must statically be, and whether the address it
# yields is one the kernel may write through.
proc core::bytestore::bridges {} {
    variable bytesType
    variable addressNative
    variable mutableBytesType
    variable mutableAddressNative
    return [list [list $addressNative $bytesType 0] [list $mutableAddressNative $mutableBytesType 1]]
}

# 1 if NAME is the qualified name of an address bridge.
proc core::bytestore::isBridge {name} {
    foreach bridge [bridges] {
        if {[lindex $bridge 0] eq $name} {
            return 1
        }
    }
    return 0
}

# The opaque struct type (declaration identity) the bridge NAME takes, or "".
proc core::bytestore::bridgeType {name} {
    foreach bridge [bridges] {
        if {[lindex $bridge 0] eq $name} {
            return [lindex $bridge 1]
        }
    }
    return ""
}

# 1 if the bridge NAME hands out a writable address.
proc core::bytestore::bridgeWritable {name} {
    foreach bridge [bridges] {
        if {[lindex $bridge 0] eq $name} {
            return [lindex $bridge 2]
        }
    }
    return 0
}

proc core::bytestore::bytesType {} {
    variable bytesType
    return $bytesType
}

proc core::bytestore::storageField {} {
    variable storageField
    return $storageField
}

proc core::bytestore::addressNative {} {
    variable addressNative
    return $addressNative
}

# The storage of List[Byte] L, eagerly. Raises TYPE for a non-List argument
# and for any element that is not an Int in 0..255.
proc core::bytestore::fromList {l} {
    set items [core::value::items [core::value::expect list $l byte_store::from_list]]
    set codes {}
    set position 0
    foreach item $items {
        if {[core::value::kind $item] ne "int"} {
            core::semanticError TYPE \
                "byte_store::from_list: element $position must be a byte (an Int in 0..255), got [core::value::show $item]"
        }
        set n [core::value::intOf $item]
        if {$n < 0 || $n > 255} {
            core::semanticError TYPE \
                "byte_store::from_list: element $position must be a byte (an Int in 0..255), got $n"
        }
        lappend codes $n
        incr position
    }
    if {$codes eq ""} {
        return [core::value::bytestore ""]
    }
    return [core::value::bytestore [binary encode hex [binary format c* $codes]]]
}

proc core::bytestore::length {storage} {
    core::value::expect bytestore $storage byte_store::byte_count
    return [core::value::int [core::value::bytestoreLength $storage]]
}

proc core::bytestore::addressImpl {data} {
    core::semanticError NATIVE-ONLY \
        "abi::x86_64::from_bytes produces the machine address of a byte buffer, which exists only in the native backend (cranelift, or a standalone executable) on Linux x86-64; the Tcl backends (interp, compile) have no machine addresses and do not imitate one"
}

core::native::register byte_store::from_list -arity 1 -impl core::bytestore::fromList \
    -param-types {list} -result-type any -runtime {bytestore-alloc} -context-free 1
core::native::register byte_store::byte_count -arity 1 -impl core::bytestore::length \
    -param-types {any} -result-type int -result-range collection-length -context-free 1

# The raw address bridge (ABI-BYTES.md). Not context-free: an address is a
# property of one run's memory, never a compile-time or module-initialization
# value. The argument must statically be an abi::Bytes (hir/syscall.tcl).
core::native::register [core::bytestore::addressNative] -arity 1 -impl core::bytestore::addressImpl \
    -param-types {struct} -result-type struct -runtime {raw-address} \
    -result-shape [list named-struct [core::linuxabi::registerType]]

# ---------------------------------------------------------------------------
# The writable storage kind (MUTABLE-BYTES.md). In Tcl every value is
# immutable, so "an update returns a new storage" is simply what an update
# is, and independence of logical copies holds by construction.

# The largest byte count a storage may have: the runtime's collection-length
# ceiling (native/src/runtime/ops.rs's MAX_COLLECTION_LENGTH, 2^62 - 1).
proc core::bytestore::maxLength {} {
    return 4611686018427387903
}

proc core::bytestore::MutableOperand {v context} {
    core::value::expect mutbytes $v $context
    return [core::value::mutbytesHex $v]
}

# n zero bytes. RANGE for a count outside 0..the ceiling; TYPE for a non-Int.
proc core::bytestore::mutableNew {count} {
    core::value::expect int $count byte_store::mutable_new
    set n [core::value::intOf $count]
    if {$n < 0 || $n > [maxLength]} {
        core::semanticError RANGE \
            "byte_store::mutable_new: the length must be in 0..[maxLength], got $n"
    }
    # The text of 2n digits is only built when the caller really asks for
    # that many bytes (the Tcl backends are the reference, not the fast path).
    if {$n > 1073741824} {
        core::semanticError RANGE \
            "byte_store::mutable_new: a $n-byte MutableBytes does not fit the Tcl backends' representation"
    }
    return [core::value::mutbytes [string repeat 00 $n]]
}

proc core::bytestore::mutableFrom {storage} {
    core::value::expect bytestore $storage byte_store::mutable_from
    return [core::value::mutbytes [core::value::bytestoreHex $storage]]
}

proc core::bytestore::mutableCount {m} {
    MutableOperand $m byte_store::mutable_count
    return [core::value::int [core::value::mutbytesLength $m]]
}

# The storage M with byte INDEX replaced by BYTE. The index must designate a
# byte and BYTE must be in 0..255 (lib/abi.bot's wrapper proves both; a
# violation here is a RANGE/TYPE error, never a wrap or a write elsewhere).
proc core::bytestore::mutableSet {m index byte} {
    set hex [MutableOperand $m byte_store::mutable_set]
    core::value::expect int $index byte_store::mutable_set
    core::value::expect int $byte byte_store::mutable_set
    set i [core::value::intOf $index]
    set b [core::value::intOf $byte]
    if {$b < 0 || $b > 255} {
        core::semanticError TYPE "byte_store::mutable_set: the value must be a byte (an Int in 0..255), got $b"
    }
    set count [expr {[string length $hex] / 2}]
    if {$i < 0 || $i >= $count} {
        core::semanticError RANGE "byte_store::mutable_set: index $i is outside 0..[expr {$count - 1}]"
    }
    set at [expr {2 * $i}]
    return [core::value::mutbytes [string replace $hex $at [expr {$at + 1}] [format %02x $b]]]
}

proc core::bytestore::mutableCopy {m} {
    # In Tcl the value already is independent of every other: the copy is the
    # value itself.
    MutableOperand $m byte_store::mutable_copy
    return $m
}

proc core::bytestore::freeze {m} {
    return [core::value::bytestore [MutableOperand $m byte_store::freeze]]
}

proc core::bytestore::freezePrefix {m count} {
    set hex [MutableOperand $m byte_store::freeze_prefix]
    core::value::expect int $count byte_store::freeze_prefix
    set n [core::value::intOf $count]
    set total [expr {[string length $hex] / 2}]
    if {$n < 0 || $n > $total} {
        core::semanticError RANGE "byte_store::freeze_prefix: the count must be in 0..$total, got $n"
    }
    return [core::value::bytestore [string range $hex 0 [expr {2 * $n - 1}]]]
}

proc core::bytestore::mutableAddressImpl {data} {
    core::semanticError NATIVE-ONLY \
        "abi::x86_64::from_mutable_bytes produces the machine address of a writable byte buffer, which exists only in the native backend (cranelift, or a standalone executable) on Linux x86-64; the Tcl backends (interp, compile) have no machine addresses and do not imitate one"
}

core::native::register byte_store::mutable_new -arity 1 -impl core::bytestore::mutableNew \
    -param-types {int} -result-type any -runtime {bytestore-alloc}
core::native::register byte_store::mutable_from -arity 1 -impl core::bytestore::mutableFrom \
    -param-types {any} -result-type any -runtime {bytestore-alloc}
core::native::register byte_store::mutable_count -arity 1 -impl core::bytestore::mutableCount \
    -param-types {any} -result-type int -result-range collection-length
core::native::register byte_store::mutable_set -arity 3 -impl core::bytestore::mutableSet \
    -param-types {any int int} -result-type any -runtime {bytestore-alloc}
core::native::register byte_store::mutable_copy -arity 1 -impl core::bytestore::mutableCopy \
    -param-types {any} -result-type any -runtime {bytestore-alloc}
core::native::register byte_store::freeze -arity 1 -impl core::bytestore::freeze \
    -param-types {any} -result-type any -runtime {bytestore-alloc}
core::native::register byte_store::freeze_prefix -arity 2 -impl core::bytestore::freezePrefix \
    -param-types {any int} -result-type any -runtime {bytestore-alloc}

# The writable address bridge: like from_bytes, never context-free (an
# address is a property of one run's memory) and only ever called, with an
# argument that statically is an abi::MutableBytes (hir/syscall.tcl).
core::native::register [core::bytestore::mutableAddressNative] -arity 1 \
    -impl core::bytestore::mutableAddressImpl \
    -param-types {struct} -result-type struct -runtime {raw-address} \
    -result-shape [list named-struct [core::linuxabi::registerType]]
