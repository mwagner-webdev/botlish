# utf8text.tcl -- the String of UTF-8 bytes (WINDOWS-X86-64-MILESTONE-7.md):
# std::str::encode_utf8's inverse, for a byte storage.
#
#   std::byte_store::decode_utf8(storage) -> str, errors InvalidUtf8:
#       the String whose UTF-8 encoding is STORAGE's bytes; the declared
#       builtin error InvalidUtf8 for any other byte sequence. Its public
#       spelling is std::abi::bytes::decode_utf8(data: Bytes), the typed
#       wrapper (stdlib/abi/bytes.bot): a List of bytes is decoded as
#       std::abi::bytes::decode_utf8(std::abi::bytes::from_list(bytes)).
#
# Strict: a sequence is accepted exactly when it is the UTF-8 encoding of a
# sequence of Unicode scalar values -- what Rust's std::str::from_utf8
# accepts, and what argv() decodes (core/process.tcl's Decode): an overlong
# form, an encoded surrogate (ED A0 80..ED BF BF, which WTF-8 uses for an
# unpaired UTF-16 surrogate), a value above U+10FFFF, a truncated sequence or
# a stray continuation byte is InvalidUtf8, never a replacement character.
# So decode_utf8(from_list(encode_utf8(s))) == s for every String s, and
# the bytes of every Bytes decode_utf8 accepts are its result's encoding: the two
# are inverse bijections between Strings and their encodings. A 0 byte is
# U+0000, an ordinary character. No BOM is skipped, no normalization made.
# native/src/runtime/ops.rs's rt_bytes_decode_utf8 decodes by the same rule.
#
# It exists because a name the operating system returns is bytes (Linux,
# Darwin) or UTF-16 (Windows, transcoded to UTF-8 by std::windows::fs): the
# textual layer of a path needs the String of such a name when it has one,
# and an explicit failure when it has none (std::io::path::NotText).

namespace eval core::utf8text {}

# InvalidUtf8: a byte sequence that is not the UTF-8 encoding of any String
# (std::abi::bytes::decode_utf8). Declared here, after core/inttext.tcl's
# InvalidIntegerText (core/core.tcl's load order), so that it is builtin
# error 12 and every existing builtin error keeps its id.
core::native::declareError InvalidUtf8

# std::byte_store::decode_utf8(STORAGE): the String whose UTF-8 encoding is
# the byte storage STORAGE (std::abi::bytes::decode_utf8 passes a Bytes'
# storage), else InvalidUtf8. TYPE for an operand that is not a byte storage
# (the wrapper's parameter type rules it out in a checked program).
proc core::utf8text::decode {storage} {
    core::value::expect bytestore $storage std::byte_store::decode_utf8
    set raw [binary decode hex [core::value::bytestoreHex $storage]]
    if {[catch {encoding convertfrom -profile strict utf-8 $raw} text]} {
        core::native::failDeclared InvalidUtf8 \
            "std::abi::bytes::decode_utf8: the bytes are not UTF-8 (an invalid, overlong, surrogate or truncated sequence)"
    }
    return [core::value::str $text]
}

core::native::register std::byte_store::decode_utf8 -arity 1 -impl core::utf8text::decode \
    -param-types {any} -result-type str -runtime string-alloc -errors InvalidUtf8 \
    -context-free 1
