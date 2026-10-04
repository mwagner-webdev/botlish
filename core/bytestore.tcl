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
