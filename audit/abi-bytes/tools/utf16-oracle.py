"""utf16-oracle.py -- an independent oracle of UTF-16LE on byte storage
(UTF16-BYTE-STORAGE-MILESTONE-1.md), written from the milestone's rules by
plain arithmetic on integers, not from core/ or native/ and not with a codec
library (selftest checks it against Python's own utf-16-le codec, a third
implementation).

    python3 -I audit/abi-bytes/tools/utf16-oracle.py < CASES > EXPECTED
    python3 -I audit/abi-bytes/tools/utf16-oracle.py selftest

Each input line is one case, tab-separated, its kind first:

    encode  S1,S2,...   the UTF-16LE bytes (lowercase hex, "" for none) of the
                        String whose Unicode scalar values are S1, S2, ...
                        (decimal; the field may be empty)
    decode  HEX         the scalar values (decimal, comma-separated) of the
                        String whose UTF-16LE encoding is the bytes HEX, or
                        "invalid"

and the output line is the expected result.
"""

import random
import sys


def is_scalar(c):
    return 0 <= c <= 0x10FFFF and not (0xD800 <= c <= 0xDFFF)


def units_of_scalars(scalars):
    out = []
    for c in scalars:
        if not is_scalar(c):
            raise ValueError("not a Unicode scalar value: %d" % c)
        if c < 0x10000:
            out.append(c)
        else:
            v = c - 0x10000
            out.append(0xD800 + (v >> 10))
            out.append(0xDC00 + (v & 0x3FF))
    return out


def encode(scalars):
    data = bytearray()
    for u in units_of_scalars(scalars):
        data.append(u & 0xFF)
        data.append(u >> 8)
    return bytes(data)


def decode(data):
    """The scalars DATA encodes, or None when it is no UTF-16LE encoding."""
    if len(data) % 2 != 0:
        return None
    units = [data[i] | (data[i + 1] << 8) for i in range(0, len(data), 2)]
    scalars = []
    i = 0
    while i < len(units):
        u = units[i]
        if 0xD800 <= u <= 0xDBFF:
            if i + 1 < len(units) and 0xDC00 <= units[i + 1] <= 0xDFFF:
                scalars.append(0x10000 + ((u - 0xD800) << 10) + (units[i + 1] - 0xDC00))
                i += 2
                continue
            return None
        if 0xDC00 <= u <= 0xDFFF:
            return None
        scalars.append(u)
        i += 1
    return scalars


def answer(line):
    fields = line.rstrip("\n").split("\t")
    kind = fields[0]
    if kind == "encode":
        text = fields[1] if len(fields) > 1 else ""
        scalars = [int(x) for x in text.split(",")] if text else []
        return encode(scalars).hex()
    if kind == "decode":
        hex_text = fields[1] if len(fields) > 1 else ""
        result = decode(bytes.fromhex(hex_text))
        if result is None:
            return "invalid"
        return ",".join(str(c) for c in result)
    raise ValueError("unknown case kind %r" % kind)


def selftest():
    vectors = [
        ([], ""),
        ([0x41], "4100"),
        ([0], "0000"),
        ([0xE9], "e900"),
        ([0x20AC], "ac20"),
        ([0x1F600], "3dd800de"),
        ([0xFFFD], "fdff"),
        ([0xFEFF], "fffe"),
        ([0x10FFFF], "ffdbffdf"),
    ]
    for scalars, hex_text in vectors:
        assert encode(scalars).hex() == hex_text, (scalars, encode(scalars).hex())
        assert decode(bytes.fromhex(hex_text)) == scalars, hex_text
    for bad in ["41", "410042", "00d8", "00dc", "00d84100", "410000d8", "00dc00d8",
                "00d800d8", "00dc00dc", "00d800d800dc", "fdff00dc"]:
        assert decode(bytes.fromhex(bad)) is None, bad
    # Against Python's own codec, on random scalars and random bytes.
    rng = random.Random(7)
    for _ in range(20000):
        n = rng.randrange(0, 12)
        scalars = []
        for _ in range(n):
            pool = rng.randrange(4)
            if pool == 0:
                scalars.append(rng.randrange(0, 0x80))
            elif pool == 1:
                scalars.append(rng.choice([rng.randrange(0x80, 0xD800), rng.randrange(0xE000, 0x10000)]))
            else:
                scalars.append(rng.randrange(0x10000, 0x110000))
        text = "".join(chr(c) for c in scalars)
        assert encode(scalars) == text.encode("utf-16-le"), scalars
        data = bytes(rng.randrange(256) for _ in range(rng.randrange(0, 9)))
        if rng.randrange(2):
            # Bias toward surrogate units: half the units' high bytes D8..DF.
            data = bytearray(data)
            for i in range(1, len(data), 2):
                if rng.randrange(2):
                    data[i] = rng.randrange(0xD8, 0xE0)
            data = bytes(data)
        try:
            theirs = [ord(c) for c in data.decode("utf-16-le", "strict")]
        except UnicodeDecodeError:
            theirs = None
        assert decode(data) == theirs, (data.hex(), decode(data), theirs)
    print("selftest ok")


def main():
    if sys.argv[1:] == ["selftest"]:
        selftest()
        return
    out = []
    for line in sys.stdin:
        if line.strip():
            out.append(answer(line))
    sys.stdout.write("\n".join(out) + ("\n" if out else ""))


if __name__ == "__main__":
    main()
