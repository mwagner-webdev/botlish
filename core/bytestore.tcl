# bytestore.tcl -- the owned byte storage behind std::abi::Bytes (ABI-BYTES.md),
# and the raw address bridge that reads it.
#
# std::abi::Bytes (stdlib/abi/bytes.bot) is an opaque struct: an ordinary immutable Botlish
# value whose representation belongs to module `abi`. Its one field holds a
# *byte storage*, a runtime value of its own kind (core/value.tcl,
# {bytestore HEX}; natively one heap object, header + length + the bytes in
# one allocation): an immutable, finite, contiguous sequence of bytes with an
# exact length. Two root natives in the `byte_store` namespace build and
# measure it, and one per architecture (`std::abi::x86_64`, `std::abi::aarch64`: the
# architectures of core/linuxabi.tcl's syscall transports) reads its machine
# address:
#
#   std::byte_store::from_list(List[Byte]) -> byte storage
#       EAGER conversion: the result owns its own copy of the bytes; it is
#       not a view of the List and does not retain it. Every element must be
#       an Int in 0..255 and is stored exactly: no `mod 256`, no signed
#       reinterpretation, no character coercion (an element that is not such
#       an Int is a TYPE error). Nothing terminates the sequence: a 0
#       element is an ordinary byte.
#   std::byte_store::join(List[storage]) -> byte storage
#       The bytes of every storage of the List, in order, in one new
#       storage (WINDOWS-X86-64-MILESTONE-7.md).
#   std::byte_store::slice(storage, start, end) -> byte storage
#       The bytes START..END-1, in a new storage, or LowerUnderrun /
#       UpperOverrun (the one slice rule; WINDOWS-X86-64-MILESTONE-7.md).
#   std::byte_store::byte_count(storage) -> Int
#       The exact byte count, 0 <= n <= the runtime's collection-length
#       ceiling (the same enforced bound a String's or List's length has).
#   std::abi::x86_64::from_bytes(std::abi::Bytes) -> std::abi::x86_64::Register64
#   std::abi::aarch64::from_bytes(std::abi::Bytes) -> std::abi::aarch64::Register64
#       The one operation that needs a machine: the address of the first
#       byte of the Bytes' payload, as register contents of the
#       architecture whose transport consumes it. The address of a machine
#       object exists only on the native backend, so the Tcl backends refuse
#       the call (NATIVE-ONLY), exactly as they refuse the syscall
#       transports; nothing imitates an address.
#
# The writable counterpart (MUTABLE-BYTES.md) is a second, distinct runtime
# kind, `mutbytes` ({mutbytes HEX} in Tcl; KIND_MUTBYTES natively), behind
# std::abi::MutableBytes. A MutableBytes is a VALUE: no operation here ever
# changes a storage another value can observe. The family is
# std::mutable_byte_store's, and the bridges:
#
#   zeroed(n)                  n zero bytes
#   from_storage(storage)      an independent writable copy of an immutable
#                              byte storage
#   count(m)                   the (fixed) byte count
#   replace(m, i, b)           a storage equal to M except that byte I is B
#                              -- natively a fresh object cloned from M and
#                              then written; M itself is never written
#   detach(m)                  a fresh storage equal to M: the "detach" a
#                              writable foreign access (std::linux::read)
#                              takes before it writes (COW's detach, always
#                              taken)
#   freeze(m)                  the immutable byte storage holding M's current
#                              bytes (a copy)
#   freeze_prefix(m, n)        the first N bytes of M, likewise
#   std::abi::x86_64::from_mutable_bytes(std::abi::MutableBytes) -> Register64
#   std::abi::aarch64::from_mutable_bytes(std::abi::MutableBytes) -> Register64
#                              the WRITABLE address bridges
#
# None of them is context-free: a mutable value is never a compile-time
# constant, so no two logical values can ever share one writable static
# storage.
#
# `byte_store` is the family namespace of the storage kind (like
# immutable_set for ImmutableSet). Nothing outside module `abi` can turn a
# storage value into a std::abi::Bytes (constructing one is representation
# authority: OPAQUE-STRUCTS.md), and a storage value alone gives no address,
# so these natives cannot manufacture a pointer. There is deliberately no
# byte_store operation that reads or iterates the bytes; the ones that
# combine and cut them, join and slice (WINDOWS-X86-64-MILESTONE-7.md: a file
# read in chunks becomes one Bytes, a short write's unwritten rest is one),
# copy storages into a new one and read none into a Botlish value.

namespace eval core::bytestore {
    # The declaration identity of the opaque struct whose one field holds a
    # byte storage (stdlib/abi/bytes.bot) and that field's name: the compiler's
    # only knowledge of Bytes. Like core::linuxabi's register types, they
    # come from one place.
    variable bytesType std::abi::bytes::Bytes
    variable storageField storage
    # The writable counterpart: the declaration identity of std::abi::MutableBytes
    # (its one field is also named `storage`).
    variable mutableBytesType std::abi::bytes::MutableBytes
}

proc core::bytestore::mutableBytesType {} {
    variable mutableBytesType
    return $mutableBytesType
}

# The address bridges, as {NAME TYPE WRITABLE ARCH}: the root native, the
# opaque struct its one argument must statically be, whether the address it
# yields is one the kernel may write through, and the architecture whose
# Register64 it returns (core/linuxabi.tcl's transports): a readable and a
# writable bridge per architecture, `ABI::from_bytes` and
# `ABI::from_mutable_bytes` in the transport's own abi namespace.
proc core::bytestore::bridges {} {
    variable bytesType
    variable mutableBytesType
    set bridges {}
    foreach arch [core::linuxabi::architectures] {
        set ns [core::linuxabi::transport $arch abi]
        lappend bridges [list ${ns}::from_bytes $bytesType 0 $arch] \
            [list ${ns}::from_mutable_bytes $mutableBytesType 1 $arch]
    }
    return $bridges
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

# The architecture (core/linuxabi.tcl) whose Register64 the bridge NAME
# returns, or "".
proc core::bytestore::bridgeArch {name} {
    foreach bridge [bridges] {
        if {[lindex $bridge 0] eq $name} {
            return [lindex $bridge 3]
        }
    }
    return ""
}

# The Register64 declaration identity the bridge NAME returns.
proc core::bytestore::bridgeRegisterType {name} {
    return [core::linuxabi::transport [bridgeArch $name] registerType]
}

proc core::bytestore::bytesType {} {
    variable bytesType
    return $bytesType
}

proc core::bytestore::storageField {} {
    variable storageField
    return $storageField
}

# The storage of List[Byte] L, eagerly. Raises TYPE for a non-List argument
# and for any element that is not an Int in 0..255.
proc core::bytestore::fromList {l} {
    set items [core::value::items [core::value::expect list $l std::byte_store::from_list]]
    set codes {}
    set position 0
    foreach item $items {
        if {[core::value::kind $item] ne "int"} {
            core::semanticError TYPE \
                "std::byte_store::from_list: element $position must be a byte (an Int in 0..255), got [core::value::show $item]"
        }
        set n [core::value::intOf $item]
        if {$n < 0 || $n > 255} {
            core::semanticError TYPE \
                "std::byte_store::from_list: element $position must be a byte (an Int in 0..255), got $n"
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
    core::value::expect bytestore $storage std::byte_store::byte_count
    return [core::value::intFromNumber [core::value::bytestoreLength $storage]]
}

proc core::bytestore::addressImpl {name data} {
    set label [core::linuxabi::transport [bridgeArch $name] label]
    core::semanticError NATIVE-ONLY \
        "$name produces the machine address of [expr {[bridgeWritable $name] ? "a writable byte buffer" : "a byte buffer"}], which exists only in the native backend (cranelift, or a standalone executable) on Linux $label; the Tcl backends (interp, compile) have no machine addresses and do not imitate one"
}

# The storage of the bytes of every storage of List L, in order
# (WINDOWS-X86-64-MILESTONE-7.md): one new storage, the empty one when every
# part is empty. TYPE for an element that is not a byte storage (lib/abi/
# bytes.bot's wrapper passes only the storages of Bytes values).
proc core::bytestore::join {l} {
    set hex ""
    set position 0
    foreach item [core::value::items [core::value::expect list $l std::byte_store::join]] {
        if {[core::value::kind $item] ne "bytestore"} {
            core::semanticError TYPE \
                "std::byte_store::join: element $position must be a byte storage, got [core::value::show $item]"
        }
        append hex [core::value::bytestoreHex $item]
        incr position
    }
    return [core::value::bytestore $hex]
}

# The storage of STORAGE's bytes START..END-1 (WINDOWS-X86-64-MILESTONE-7.md:
# the bytes a short write left unwritten), by the one slice rule
# (core::native::checkSlice): LowerUnderrun or UpperOverrun unless 0 <= START
# <= END <= the byte count.
proc core::bytestore::slice {storage start end} {
    core::value::expect bytestore $storage std::byte_store::slice
    set from [core::value::intOf [core::value::expect int $start std::byte_store::slice]]
    set to [core::value::intOf [core::value::expect int $end std::byte_store::slice]]
    core::native::checkSlice std::byte_store::slice $from $to [core::value::bytestoreLength $storage]
    set hex [core::value::bytestoreHex $storage]
    return [core::value::bytestore [string range $hex [expr {2 * $from}] [expr {2 * $to - 1}]]]
}

core::native::register std::byte_store::from_list -arity 1 -impl core::bytestore::fromList \
    -param-types {list} -result-type any -runtime {bytestore-alloc} -context-free 1
core::native::register std::byte_store::join -arity 1 -impl core::bytestore::join \
    -param-types {list} -result-type any -runtime {bytestore-alloc} -context-free 1
core::native::register std::byte_store::slice -arity 3 -impl core::bytestore::slice \
    -param-types {any int int} -result-type any -runtime {bytestore-alloc range-check} -context-free 1 \
    -errors {LowerUnderrun UpperOverrun}
core::native::register std::byte_store::byte_count -arity 1 -impl core::bytestore::length \
    -param-types {any} -result-type int -result-range collection-length -context-free 1


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
    core::value::expect int $count std::mutable_byte_store::zeroed
    set n [core::value::intOf $count]
    if {$n < 0 || $n > [maxLength]} {
        core::semanticError RANGE \
            "std::mutable_byte_store::zeroed: the length must be in 0..[maxLength], got $n"
    }
    # The text of 2n digits is only built when the caller really asks for
    # that many bytes (the Tcl backends are the reference, not the fast path).
    if {$n > 1073741824} {
        core::semanticError RANGE \
            "std::mutable_byte_store::zeroed: a $n-byte MutableBytes does not fit the Tcl backends' representation"
    }
    return [core::value::mutbytes [string repeat 00 $n]]
}

proc core::bytestore::mutableFrom {storage} {
    core::value::expect bytestore $storage std::mutable_byte_store::from_storage
    return [core::value::mutbytes [core::value::bytestoreHex $storage]]
}

proc core::bytestore::mutableCount {m} {
    MutableOperand $m std::mutable_byte_store::count
    return [core::value::intFromNumber [core::value::mutbytesLength $m]]
}

# The storage M with byte INDEX replaced by BYTE. The index must designate a
# byte and BYTE must be in 0..255 (stdlib/abi/bytes.bot's wrapper proves both; a
# violation here is a RANGE/TYPE error, never a wrap or a write elsewhere).
proc core::bytestore::mutableSet {m index byte} {
    set hex [MutableOperand $m std::mutable_byte_store::replace]
    core::value::expect int $index std::mutable_byte_store::replace
    core::value::expect int $byte std::mutable_byte_store::replace
    set i [core::value::intOf $index]
    set b [core::value::intOf $byte]
    if {$b < 0 || $b > 255} {
        core::semanticError TYPE "std::mutable_byte_store::replace: the value must be a byte (an Int in 0..255), got $b"
    }
    set count [expr {[string length $hex] / 2}]
    if {$i < 0 || $i >= $count} {
        core::semanticError RANGE "std::mutable_byte_store::replace: index $i is outside 0..[expr {$count - 1}]"
    }
    set at [expr {2 * $i}]
    return [core::value::mutbytes [string replace $hex $at [expr {$at + 1}] [format %02x $b]]]
}

proc core::bytestore::mutableCopy {m} {
    # In Tcl the value already is independent of every other: the copy is the
    # value itself.
    MutableOperand $m std::mutable_byte_store::detach
    return $m
}

proc core::bytestore::freeze {m} {
    return [core::value::bytestore [MutableOperand $m std::mutable_byte_store::freeze]]
}

proc core::bytestore::freezePrefix {m count} {
    set hex [MutableOperand $m std::mutable_byte_store::freeze_prefix]
    core::value::expect int $count std::mutable_byte_store::freeze_prefix
    set n [core::value::intOf $count]
    set total [expr {[string length $hex] / 2}]
    if {$n < 0 || $n > $total} {
        core::semanticError RANGE "std::mutable_byte_store::freeze_prefix: the count must be in 0..$total, got $n"
    }
    return [core::value::bytestore [string range $hex 0 [expr {2 * $n - 1}]]]
}

core::native::register std::mutable_byte_store::zeroed -arity 1 -impl core::bytestore::mutableNew \
    -param-types {int} -result-type any -runtime {bytestore-alloc}
core::native::register std::mutable_byte_store::from_storage -arity 1 -impl core::bytestore::mutableFrom \
    -param-types {any} -result-type any -runtime {bytestore-alloc}
core::native::register std::mutable_byte_store::count -arity 1 -impl core::bytestore::mutableCount \
    -param-types {any} -result-type int -result-range collection-length
core::native::register std::mutable_byte_store::replace -arity 3 -impl core::bytestore::mutableSet \
    -param-types {any int int} -result-type any -runtime {bytestore-alloc}
core::native::register std::mutable_byte_store::detach -arity 1 -impl core::bytestore::mutableCopy \
    -param-types {any} -result-type any -runtime {bytestore-alloc}
core::native::register std::mutable_byte_store::freeze -arity 1 -impl core::bytestore::freeze \
    -param-types {any} -result-type any -runtime {bytestore-alloc}
core::native::register std::mutable_byte_store::freeze_prefix -arity 2 -impl core::bytestore::freezePrefix \
    -param-types {any int} -result-type any -runtime {bytestore-alloc}

# The raw address bridges (ABI-BYTES.md, MUTABLE-BYTES.md). Not
# context-free: an address is a property of one run's memory, never a
# compile-time or module-initialization value. Only ever called, with an
# argument that statically is the bridge's own opaque struct -- a std::abi::Bytes
# for from_bytes, a std::abi::MutableBytes for from_mutable_bytes
# (hir/syscall.tcl).
foreach bridge [core::bytestore::bridges] {
    set name [lindex $bridge 0]
    core::native::register $name -arity 1 -impl [list core::bytestore::addressImpl $name] \
        -param-types {struct} -result-type struct -runtime {raw-address} \
        -result-shape [list named-struct [core::bytestore::bridgeRegisterType $name]]
}
unset bridge name
