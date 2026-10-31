#!/usr/bin/env python3
"""machofake.py -- synthetic Mach-O files for the bundle's negative controls
(audit/macos-release/, ICY-TOWER-MACOS-APP-MILESTONE-1.md): a header and the
load commands bundle.py reads (LC_BUILD_VERSION, LC_MAIN, the dylib
commands), with the facts a control changes -- the CPU type, the file type,
LC_MAIN's stack, the minimum macOS, the libraries -- and nothing that runs.

    python3 -I machofake.py OUT [--cpu arm64|x86_64] [--stack N|none]
        [--minos X.Y] [--dylib PATH]... [--fat] [--filetype N]
"""
import argparse
import struct
import sys

CPU = {"arm64": 0x0100000C, "x86_64": 0x01000007}


def version(text):
    parts = [int(p) for p in text.split(".")] + [0, 0]
    return (parts[0] << 16) | (parts[1] << 8) | parts[2]


def make(cpu="arm64", stack=536870912, minos="11.0", sdk="15.5", dylibs=None, filetype=2, fat=False):
    dylibs = ["/usr/lib/libSystem.B.dylib"] if dylibs is None else dylibs
    cmds = [struct.pack("<IIIIII", 0x32, 24, 1, version(minos), version(sdk), 0)]
    if stack is not None:
        cmds.append(struct.pack("<IIQQ", 0x80000028, 24, 0x4000, stack))
    for lib in dylibs:
        name = lib.encode() + b"\0"
        size = (24 + len(name) + 7) // 8 * 8
        cmds.append(struct.pack("<IIIIII", 0xC, size, 24, 2, 0x10000, 0x10000) + name.ljust(size - 24, b"\0"))
    body = b"".join(cmds)
    header = struct.pack("<IiiIIIII", 0xFEEDFACF, CPU[cpu], 0, filetype, len(cmds), len(body), 0x200085, 0)
    data = header + body + b"\0" * 64
    if fat:
        data = struct.pack(">II", 0xCAFEBABE, 1) + struct.pack(">iiIII", CPU[cpu], 0, 4096, len(data), 12) \
            + b"\0" * (4096 - 28) + data
    return data


def main(argv):
    p = argparse.ArgumentParser()
    p.add_argument("out")
    p.add_argument("--cpu", default="arm64")
    p.add_argument("--stack", default="536870912")
    p.add_argument("--minos", default="11.0")
    p.add_argument("--dylib", action="append")
    p.add_argument("--filetype", type=int, default=2)
    p.add_argument("--fat", action="store_true")
    a = p.parse_args(argv)
    data = make(a.cpu, None if a.stack == "none" else int(a.stack), a.minos, "15.5", a.dylib, a.filetype, a.fat)
    with open(a.out, "wb") as f:
        f.write(data)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
