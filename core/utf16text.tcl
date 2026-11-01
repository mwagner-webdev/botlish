# utf16text.tcl -- a String's UTF-16LE bytes, and the String of UTF-16LE
# bytes (UTF16-BYTE-STORAGE-MILESTONE-1.md): the UTF-16 sibling of
# core/utf8text.tcl, on the same byte storage.
#
#   std::byte_store::encode_utf16le(text) -> byte storage:
#       TEXT's Unicode scalar values encoded as UTF-16 code units (a scalar
#       above U+FFFF as its surrogate pair, high unit first), each unit
#       stored as two bytes, low byte first: exactly 2 bytes per unit. No
#       byte-order mark, no terminator, no normalization; U+0000 is the unit
#       0000 (the bytes 00 00), an ordinary character. Total: every String
#       has an encoding. Public spelling std::abi::bytes::encode_utf16le.
#   std::byte_store::decode_utf16le(storage) -> str, errors InvalidUtf16:
#       the String whose UTF-16LE encoding is STORAGE's bytes; the declared
#       builtin error InvalidUtf16 for any other byte sequence. Public
#       spelling std::abi::bytes::decode_utf16le(data: Bytes).
#
# Strict: a byte sequence is accepted exactly when it has an even length and
# its code units (each byte pair read low byte first) are well-formed UTF-16
# -- every high surrogate (D800..DBFF) followed at once by a low surrogate
# (DC00..DFFF), every low surrogate preceded at once by a high one. An odd
# byte count, an unpaired high or low surrogate (leading, trailing, reversed,
# doubled, before an ordinary unit) is InvalidUtf16, never a replacement
# character. So decode_utf16le(encode_utf16le(s)) == s for every String s,
# and the bytes of every storage decode_utf16le accepts are its result's
# encoding: the two are inverse bijections between Strings and their
# UTF-16LE encodings. FF FE is the character U+FEFF, never a byte-order mark
# to skip or to read the order from; the byte order is part of the format,
# never the host's (native/src/runtime/ops.rs writes and reads each unit's
# bytes explicitly, rt_str_encode_utf16le and rt_bytes_decode_utf16le).
#
# A Botlish String is Unicode text: its characters are scalar values, never
# a lone surrogate, so encoding cannot fail. A code unit is not a character:
# a scalar above U+FFFF is two units.
#
# It exists because Windows names are UTF-16 code units (std::windows::fs
# keeps a native path as its UTF-16LE bytes), and protocols and file formats
# on every platform use UTF-16LE: the conversion is a representation change
# of the language's own values, platform-free (no Windows call, no code
# page). The Tcl backends use Tcl's own strict utf-16le encoding, which is
# exactly this rule (tests/utf16-bytes.test pins it byte for byte).

namespace eval core::utf16text {}

# InvalidUtf16: a byte sequence that is not the UTF-16LE encoding of any
# String (std::abi::bytes::decode_utf16le). Declared here, after
# core/utf8text.tcl's InvalidUtf8 (core/core.tcl's load order), so that it is
# builtin error 13 and every existing builtin error keeps its id.
core::native::declareError InvalidUtf16

# std::byte_store::encode_utf16le(TEXT): the byte storage of TEXT's UTF-16LE
# encoding. TYPE for an operand that is not a String (the parameter type
# rules it out in a checked program).
proc core::utf16text::encode {text} {
    set s [core::value::strOf [core::value::expect str $text std::byte_store::encode_utf16le]]
    return [core::value::bytestore [binary encode hex [encoding convertto -profile strict utf-16le $s]]]
}

# std::byte_store::decode_utf16le(STORAGE): the String whose UTF-16LE
# encoding is the byte storage STORAGE (std::abi::bytes::decode_utf16le
# passes a Bytes' storage), else InvalidUtf16. TYPE for an operand that is
# not a byte storage.
proc core::utf16text::decode {storage} {
    core::value::expect bytestore $storage std::byte_store::decode_utf16le
    set raw [binary decode hex [core::value::bytestoreHex $storage]]
    if {[catch {encoding convertfrom -profile strict utf-16le $raw} text]} {
        core::native::failDeclared InvalidUtf16 \
            "std::abi::bytes::decode_utf16le: the bytes are not UTF-16LE (an odd byte count or an unpaired surrogate)"
    }
    return [core::value::str $text]
}

# std::byte_store::utf16le_units(STORAGE): the code units of STORAGE's byte
# pairs, each read low byte first, as a List of Ints (0..65535), unvalidated:
# a surrogate is a unit like any other. The bridge std::windows::fs's path
# syntax reads a native path's units through (its NativePath holds the
# UTF-16LE bytes): internal to the standard library
# (core::native::declareInternalMember, below; std::abi::bytes::utf16le_units
# is its typed wrapper, internal too). RANGE for an odd byte count (no
# caller passes one: a NativePath's bytes are whole units).
proc core::utf16text::units {storage} {
    core::value::expect bytestore $storage std::byte_store::utf16le_units
    set raw [binary decode hex [core::value::bytestoreHex $storage]]
    if {[string length $raw] % 2 != 0} {
        core::semanticError RANGE \
            "std::byte_store::utf16le_units: [string length $raw] bytes are no whole number of 16-bit units"
    }
    binary scan $raw su* values
    return [core::value::listOf [lmap u $values {core::value::intFromNumber $u}]]
}

core::native::register std::byte_store::encode_utf16le -arity 1 -impl core::utf16text::encode \
    -param-types {str} -result-type any -runtime bytestore-alloc -context-free 1
core::native::register std::byte_store::decode_utf16le -arity 1 -impl core::utf16text::decode \
    -param-types {any} -result-type str -runtime string-alloc -errors InvalidUtf16 \
    -context-free 1
core::native::register std::byte_store::utf16le_units -arity 1 -impl core::utf16text::units \
    -param-types {any} -result-type list -runtime list-alloc -context-free 1 \
    -result-shape {element-type int}
core::native::declareInternalMember std::byte_store::utf16le_units
core::native::declareInternalMember std::abi::bytes::utf16le_units
