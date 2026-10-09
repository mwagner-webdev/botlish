# lib/abi/bytes.bot (P4): replace's two IndexNotFound guards are one
# condition, an index outside 0..count-1 (milestone 4's merge check, whose
# probe this is). Probed at every boundary: below, first, last, one past,
# far past, the empty value, and a replacement that changes nothing.
program lib/abi/bytes.bot

probe replace {fn mb(s: str):
    abi::bytes::from_bytes(abi::bytes::from_list(str::encode_utf8(s)))
fn tryset(m: abi::bytes::MutableBytes, i: int) -> List[any] errors IndexNotFound:
    r = abi::bytes::replace(m, i, byte::from_int(88))
    [abi::bytes::mutable_length(r).value, abi::bytes::freeze(r) == abi::bytes::freeze(m)]
fn at(m: abi::bytes::MutableBytes, i: int):
    tryset(m, i):
        on IndexNotFound:
            []
m = mb("abc")
[at(m, 0 - 1), at(m, 0), at(m, 2), at(m, 3), at(m, 1000), at(abi::bytes::zeroed(abi::usize(0)), 0), at(mb("XYZ"), 0)]}
