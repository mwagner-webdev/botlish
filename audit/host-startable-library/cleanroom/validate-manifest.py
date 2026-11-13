#!/usr/bin/env python3
"""validate-manifest.py -- an external tool's view of an application library
(RN-HOST-STARTABLE-APPLICATION-LIBRARY-MILESTONE-1.md, "Cleanroom"): reads a
native library's manifest and nothing of the compiler -- no HIR, no source,
no Botlish -- and checks what a tool that needs an application relies on:
kind and schema 3, the application member and its C signature, every file's
SHA-256, and the shared object's dynamic symbol table defining NAME_main
(read from the ELF bytes). Prints one line per fact; exits 1 on any
violation.

    validate-manifest.py LIB/NAME.manifest.json
"""
import hashlib
import json
import os
import struct
import sys


def dynamic_symbols(path):
    """The defined dynamic symbols of the ELF64 little-endian file PATH."""
    data = open(path, "rb").read()
    if data[:4] != b"\x7fELF" or data[4] != 2 or data[5] != 1:
        raise ValueError("not an ELF64 little-endian file")
    shoff, = struct.unpack_from("<Q", data, 0x28)
    shentsize, shnum = struct.unpack_from("<HH", data, 0x3A)
    sections = [struct.unpack_from("<IIQQQQIIQQ", data, shoff + i * shentsize) for i in range(shnum)]
    names = set()
    for (_, kind, _, _, offset, size, link, _, _, entsize) in sections:
        if kind != 11:  # SHT_DYNSYM
            continue
        strings = sections[link]
        for i in range(size // entsize):
            name, info, _, shndx, _, _ = struct.unpack_from("<IBBHQQ", data, offset + i * entsize)
            if shndx == 0 or name == 0:
                continue
            end = data.index(b"\0", strings[4] + name)
            names.add(data[strings[4] + name:end].decode())
    return names


def main(path):
    manifest = json.load(open(path))
    directory = os.path.dirname(os.path.abspath(path))
    problems = []
    library = manifest.get("library", "")
    print("kind", manifest.get("kind"))
    print("schema", manifest.get("schema"))
    if manifest.get("kind") != "botlish-native-library" or manifest.get("schema") != 3:
        problems.append("not a schema 3 native library manifest (no application library's)")
    application = manifest.get("application") or {}
    print("application", application.get("symbol"), "|", application.get("c"))
    expected = "int32_t %s_main(int argc, char **argv, %s_error **error)" % (library, library)
    if application.get("symbol") != library + "_main" or application.get("c") != expected:
        problems.append("the application member does not name %s_main with its C signature" % library)
    for key in ("thread", "execution"):
        print(key, application.get(key))
    if application.get("thread") != "calling" or application.get("execution") != "blocking-to-completion":
        problems.append("the entry is not stated blocking, on the calling thread")
    for key, name in manifest.get("artifacts", {}).items():
        if name is None:
            continue
        digest = hashlib.sha256(open(os.path.join(directory, name), "rb").read()).hexdigest()
        ok = digest == manifest["sha256"].get(key)
        print("sha256", key, "ok" if ok else "MISMATCH")
        if not ok:
            problems.append("%s is not the file the manifest describes" % name)
    shared = manifest.get("artifacts", {}).get("shared")
    if shared:
        defined = dynamic_symbols(os.path.join(directory, shared))
        ok = library + "_main" in defined
        print("defines", library + "_main", "yes" if ok else "NO")
        if not ok:
            problems.append("%s does not define %s_main" % (shared, library))
    for problem in problems:
        print("PROBLEM", problem)
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1]))
