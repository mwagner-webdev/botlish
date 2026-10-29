#!/usr/bin/env python3
# oracle.py -- an independent model of Botlish's two hashes
# (HASHABLE-AND-KEYED-HASH.md, "Correctness oracle").
#
#   python3 -I audit/hashable/tools/oracle.py selftest
#   python3 -I audit/hashable/tools/oracle.py hash K0 K1 < VALUES.jsonl
#
# It shares no code with the compiler or either runtime: it produces each
# value's canonical input from a JSON description of the value, by the
# encoding the report specifies, and folds it with its own FNV-1a and its own
# SipHash-c-d, written from the SipHash paper (Aumasson and Bernstein, 2012)
# and checked against its published SipHash-2-4 test vectors (`selftest`).
#
# `hash K0 K1` reads one value per line (UTF-8, whatever the locale) and
# prints, per line, the public hash and the table hash under the key K0, K1
# (decimal 64-bit words), both masked to 61 bits. A value is one of
#
#   {"int": "DECIMAL"}            {"str": "TEXT"}        {"bool": true}
#   {"unit": null}                {"char": CODEPOINT}    {"float": NUMBER}
#   {"bytes": [B, ...]}           {"mutbytes": [B, ...]}
#   {"enum": ["ENUM-ID", "CASE"]} {"list": [V, ...]}     {"set": [V, ...]}
#   {"result": [OK, V]}
#   {"struct": {"id": "ID", "fields": [["NAME", V], ...]}}
#   {"identity": {"id": "ID", "members": [V, ...]}}
#   {"identity": {"id": "ID", "associations": [[K, V], ...]}}
#
# a named struct's fields in declaration order (its slot order); an anonymous
# struct's ("id": "") in any order -- the oracle sorts them by code point, the
# one canonical layout of an anonymous struct. An `identity` is a value of a
# struct that declares its identity (REPRESENTATION-INDEPENDENT-VALUE-
# IDENTITY.md): only its entries are given, in any order, never its other
# fields.

import json
import struct
import sys

MASK64 = (1 << 64) - 1
MASK61 = (1 << 61) - 1
FNV_OFFSET = 0xCBF29CE484222325
FNV_PRIME = 0x100000001B3
TAGS = {"int": 0, "str": 1, "bool": 2, "unit": 3, "list": 4, "result": 5, "char": 6,
        "set": 7, "struct": 8, "bytes": 9, "mutbytes": 10, "enum": 11, "float": 12,
        "identity": 8}
# An identity's canonical input, after the struct's declaration identity:
# its form's tag, the entry count, the wrapping 64-bit sum of the entries'
# whole hashes (a pair's from its own input: the entry tag, then the key and
# the value as nested values).
IDENTITY_MEMBERS = 1
IDENTITY_ASSOCIATIONS = 2
IDENTITY_ENTRY = 3


def rotl(x, b):
    return ((x << b) | (x >> (64 - b))) & MASK64


def siphash(k0, k1, data, c, d):
    v = [k0 ^ 0x736F6D6570736575, k1 ^ 0x646F72616E646F6D,
         k0 ^ 0x6C7967656E657261, k1 ^ 0x7465646279746573]

    def sipround():
        v[0] = (v[0] + v[1]) & MASK64
        v[1] = rotl(v[1], 13) ^ v[0]
        v[0] = rotl(v[0], 32)
        v[2] = (v[2] + v[3]) & MASK64
        v[3] = rotl(v[3], 16) ^ v[2]
        v[0] = (v[0] + v[3]) & MASK64
        v[3] = rotl(v[3], 21) ^ v[0]
        v[2] = (v[2] + v[1]) & MASK64
        v[1] = rotl(v[1], 17) ^ v[2]
        v[2] = rotl(v[2], 32)

    n = len(data)
    padded = bytes(data) + bytes((8 - (n + 1) % 8) % 8) + bytes([n & 0xFF])
    for i in range(0, len(padded), 8):
        m = int.from_bytes(padded[i:i + 8], "little")
        v[3] ^= m
        for _ in range(c):
            sipround()
        v[0] ^= m
    v[2] ^= 0xFF
    for _ in range(d):
        sipround()
    return v[0] ^ v[1] ^ v[2] ^ v[3]


def fnv(data):
    h = FNV_OFFSET
    for b in data:
        h = ((h ^ b) * FNV_PRIME) & MASK64
    return h


def le64(n):
    return (n & MASK64).to_bytes(8, "little")


class Mode:
    """How a canonical input is folded: public (FNV-1a, a nested value as
    its sub-hash, texts bare) or table (SipHash-1-3 under a key, a nested
    value inline, texts prefixed by their length)."""

    def __init__(self, key=None):
        self.key = key

    def text(self, b):
        return b if self.key is None else le64(len(b)) + b

    def child(self, v):
        return le64(self.whole(v)) if self.key is None else encode(self, v)

    def whole(self, v):
        return self.fold(encode(self, v))

    def fold(self, data):
        return fnv(data) if self.key is None else siphash(self.key[0], self.key[1], data, 1, 3)

    def entry(self, k, v):
        return self.fold(bytes([IDENTITY_ENTRY]) + self.child(k) + self.child(v))


def encode(mode, v):
    (kind, x), = v.items()
    out = bytes([TAGS[kind]])
    if kind == "int":
        out += mode.text(str(int(x)).encode())
    elif kind == "str":
        out += mode.text(x.encode("utf-8"))
    elif kind == "bool":
        out += bytes([1 if x else 0])
    elif kind == "unit":
        pass
    elif kind == "char":
        out += mode.text(str(x).encode())
    elif kind == "float":
        out += struct.pack("<d", float(x))
    elif kind in ("bytes", "mutbytes"):
        out += le64(len(x)) + bytes(x)
    elif kind == "enum":
        out += mode.text(x[0].encode()) + b"\xff" + mode.text(x[1].encode())
    elif kind == "list":
        out += le64(len(x)) + b"".join(mode.child(e) for e in x)
    elif kind == "result":
        out += bytes([1 if x[0] else 0]) + mode.child(x[1])
    elif kind == "struct":
        fields = x["fields"]
        if x["id"] == "":
            fields = sorted(fields, key=lambda f: [ord(c) for c in f[0]])
        out += mode.text(x["id"].encode()) + le64(len(fields))
        for name, value in fields:
            out += mode.text(name.encode()) + mode.child(value)
    elif kind == "identity":
        out += mode.text(x["id"].encode())
        if "members" in x:
            total = sum(mode.whole(e) for e in x["members"])
            out += bytes([IDENTITY_MEMBERS]) + le64(len(x["members"])) + le64(total)
        else:
            total = sum(mode.entry(k, e) for k, e in x["associations"])
            out += bytes([IDENTITY_ASSOCIATIONS]) + le64(len(x["associations"])) + le64(total)
    elif kind == "set":
        combined = 0
        for e in x:
            combined ^= mode.whole(e)
        out += le64(len(x)) + le64(combined)
    else:
        raise ValueError(f"unknown kind {kind}")
    return out


def selftest():
    key = bytes(range(16))
    k0 = int.from_bytes(key[:8], "little")
    k1 = int.from_bytes(key[8:], "little")
    # The SipHash paper's appendix: the 15-byte message 00..0e.
    assert siphash(k0, k1, bytes(range(15)), 2, 4) == 0xA129CA6149BE45E5
    # The reference implementation's vectors (vectors.h, vectors_sip64):
    # the empty message and the 8-byte message 00..07.
    assert siphash(k0, k1, b"", 2, 4) == 0x726FDB47DD0E0E31
    assert siphash(k0, k1, bytes(range(8)), 2, 4) == 0x93F5F5799A932462
    # SipHash-1-3, the variant both runtimes use: Rust's core library's
    # published vectors (library/core/tests/hash/sip.rs, test_siphash_1_3),
    # the empty message and the 1-byte message 00.
    assert siphash(k0, k1, b"", 1, 3) == 0xABAC0158050FC4DC
    assert siphash(k0, k1, bytes(range(1)), 1, 3) == 0xC9F49BF37D57CA93
    # FNV-1a's published test vector ("a").
    assert fnv(b"a") == 0xAF63DC4C8601EC8C
    # An identity's input is the same in any order of its entries, and its
    # pairs are units: swapping two values across keys changes it.
    for mode in (Mode(), Mode((k0, k1))):
        a = {"identity": {"id": "m::M", "associations": [[{"int": "1"}, {"str": "x"}], [{"int": "2"}, {"str": "y"}]]}}
        b = {"identity": {"id": "m::M", "associations": [[{"int": "2"}, {"str": "y"}], [{"int": "1"}, {"str": "x"}]]}}
        c = {"identity": {"id": "m::M", "associations": [[{"int": "1"}, {"str": "y"}], [{"int": "2"}, {"str": "x"}]]}}
        assert mode.whole(a) == mode.whole(b) != mode.whole(c)
        s1 = {"identity": {"id": "m::S", "members": [{"int": "1"}, {"int": "2"}]}}
        s2 = {"identity": {"id": "m::S", "members": [{"int": "2"}, {"int": "1"}]}}
        assert mode.whole(s1) == mode.whole(s2)
    print("selftest ok")


def main():
    if sys.argv[1:] == ["selftest"]:
        selftest()
        return
    if len(sys.argv) != 4 or sys.argv[1] != "hash":
        sys.exit("usage: oracle.py selftest | hash K0 K1 < VALUES.jsonl")
    key = (int(sys.argv[2]), int(sys.argv[3]))
    # The bytes, decoded as UTF-8: never the locale's encoding (Windows'
    # code page would read a non-ASCII String as other text).
    for line in sys.stdin.buffer.read().decode("utf-8").split("\n"):
        if not line.strip():
            continue
        v = json.loads(line)
        public = Mode().whole(v) & MASK61
        table = Mode(key).whole(v) & MASK61
        print(public, table)


if __name__ == "__main__":
    main()
