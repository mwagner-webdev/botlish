#!/usr/bin/env python3
"""migrate.py -- the mechanical part of the std:: migration (STD-NAMESPACE.md).

    python3 audit/stdlib-census/tools/migrate.py [--check] FILE...

Rewrites, in each FILE, the spellings of the standard library that changed
when every standard namespace moved below the compiler-owned root `std`
and lib/ became stdlib/, the directory of namespace std:

  imports    `import NS` and `import type NS::T` of a standard namespace NS
             become `import std::NS`, `import type std::NS::T`;
  qualified  `NS::member`, `NS::Type`, `NS::Error`, `a::b::c` with a
             standard first segment become `std::NS::...` -- program text,
             registered native names (`{native std::list::at}`), messages;
  quoted     `namespace "NS"` and `module "NS"` in expected messages;
  paths      lib/NAME.bot and the lib/ directory become stdlib/...;
  topics     Compilerpedia's module topic ids (`stdlib.module.NS`).

A spelling is rewritten only where its first segment is a standard
namespace's first segment and nothing that could make it part of a longer
name (an identifier character, `:`, `$`) precedes it, so `core::compiler::`,
`::tcltest::test` and `$list` are untouched, and an already migrated
`std::list::at` is never migrated twice (the rewrite is idempotent). Rust
and C sources are never given to it: their `str::`, `io::` and `char::` are
Rust's and C's (the runtime's messages were migrated by hand).

What it cannot see -- a namespace spelled as a bare single-segment word in
Tcl code (`qualifiedMembers str`), a name assembled from parts, a test whose
point was the old flat layout -- was migrated by hand, and each such change
is in the milestone's commit, not here. With --check, prints the files that
would change and exits 1 if any would.
"""

import re
import sys

# The first segments of every standard namespace before the migration
# (audit/stdlib-census/before.tsv: abi, abi::x86_64, linux::abi::x86_64, ...).
SEGMENTS = [
    "abi", "ascii", "binary", "byte", "byte_store", "char", "compiler",
    "coroutine", "darwin", "decimal_rounded", "ffi", "float64",
    "immutable_set", "io", "linux", "list", "mathish", "mutable_array",
    "mutable_byte_store", "mutable_vector", "str", "table_hash", "test",
    "web", "windows",
]
# Longest first: `byte_store` before `byte`.
SEG = "|".join(sorted(SEGMENTS, key=len, reverse=True))

# The top-level entries of lib/ (files and directories), for absolute and
# glob paths into it (`*/lib/list.bot`).
LIBRARY_ENTRIES = "abi|ascii|binary|byte|compiler|darwin|ffi|float64|io|linux|list|mathish|mutable_array|test|web|windows"

# A name may follow a Tcl string's escaped line break or tab ("...\nlist::at"):
# the escape's letter is no identifier character there.
ESCAPE = r"(?<=\\[nt])"
# `import` is a word of its own (not the end of `ca-namespace-import`), and
# an import's words are separated by spaces (a tab is a TSV column).
IMPORT = re.compile(r"(?:(?<![A-Za-z0-9_-])|%s)(import(?: +type)? +)(?=(?:%s)(?![A-Za-z0-9_]))" % (ESCAPE, SEG))
# A member may be a Tcl substitution in a generated program (`abi::${ctor}`).
QUALIFIED = re.compile(r"(?:(?<![A-Za-z0-9_:$])|%s)(?=(?:%s)::[A-Za-z_$])" % (ESCAPE, SEG))
QUOTED = re.compile(r"((?:namespace|module) \\?\")(?=(?:%s)\\?\")" % SEG)
# `the "list" namespace` (module headers, messages).
QUOTED_BEFORE = re.compile(r"(\\?\")(?=(?:%s)\\?\" namespace)" % SEG)
TOPIC = re.compile(r"(?<=stdlib\.module\.)(?=(?:%s)(?![A-Za-z0-9_:]))" % SEG)
RELATIVE_PATH = re.compile(r"(?<![A-Za-z0-9_./$-])lib/")
# `[file join $::projectRoot lib list.bot]`, `[file join $root lib]`: the
# library directory as a path component of a Tcl file join.
JOIN_PATH = re.compile(r"(?<=\bjoin )(\$[A-Za-z_:]+|\[[^\]]*\]) lib(?=[ \]])")
# `(imports are exact: `import std::abi::x86_64` does not import "abi")`.
NOT_IMPORTED = re.compile(r"(does not import \\?\")(?=(?:%s)\\?\")" % SEG)
# "an abi::bytes::Bytes" reads "a std::abi::bytes::Bytes".
ARTICLE = re.compile(r"(?<![A-Za-z])([Aa])n (?=std::)")
ABSOLUTE_PATH = re.compile(r"(?<=/)lib/(?=(?:%s)(?:\.|/))" % LIBRARY_ENTRIES)


def compile_rules(segments):
    """The rules for the namespace first segments SEGMENTS."""
    seg = "|".join(sorted(segments, key=len, reverse=True))
    return (
        re.compile(r"(?:(?<![A-Za-z0-9_-])|%s)(import(?: +type)? +)(?=(?:%s)(?![A-Za-z0-9_]))" % (ESCAPE, seg)),
        re.compile(r"(?:(?<![A-Za-z0-9_:$])|%s)(?=(?:%s)::[A-Za-z_$])" % (ESCAPE, seg)),
        re.compile(r"((?:namespace|module) \\?\")(?=(?:%s)\\?\")" % seg),
        re.compile(r"(\\?\")(?=(?:%s)\\?\" namespace)" % seg),
    )


def migrate_segments(text, segments):
    """The rewrite of the namespaces whose first segment is one of SEGMENTS
    only (a test's own library modules: --segments), no path or topic rule."""
    imports, qualified, quoted, quoted_before = compile_rules(segments)
    text = imports.sub(r"\1std::", text)
    text = qualified.sub("std::", text)
    text = quoted.sub(r"\1std::", text)
    text = quoted_before.sub(r"\1std::", text)
    return ARTICLE.sub(r"\1 ", text)


def migrate(text):
    text = IMPORT.sub(r"\1std::", text)
    text = QUALIFIED.sub("std::", text)
    text = QUOTED.sub(r"\1std::", text)
    text = QUOTED_BEFORE.sub(r"\1std::", text)
    text = TOPIC.sub("std::", text)
    text = RELATIVE_PATH.sub("stdlib/", text)
    text = ABSOLUTE_PATH.sub("stdlib/", text)
    text = JOIN_PATH.sub(r"\1 stdlib", text)
    text = NOT_IMPORTED.sub(r"\1std::", text)
    text = ARTICLE.sub(r"\1 ", text)
    return text


def main(argv):
    check = False
    segments = None
    while argv and argv[0].startswith("--"):
        if argv[0] == "--check":
            check = True
            argv = argv[1:]
        elif argv[0] == "--segments":
            # The names of library modules a test writes into its private
            # copy of the library: namespaces std::NAME now.
            segments = [n for n in argv[1].split(",") if n]
            argv = argv[2:]
        else:
            sys.exit("migrate.py: unknown option " + argv[0])
    changed = []
    for path in argv:
        try:
            with open(path, encoding="utf-8", newline="") as f:
                text = f.read()
        except UnicodeDecodeError:
            continue
        new = migrate(text) if segments is None else migrate_segments(text, segments)
        if new != text:
            changed.append(path)
            if not check:
                with open(path, "w", encoding="utf-8", newline="") as f:
                    f.write(new)
    for path in changed:
        print(path)
    return 1 if (check and changed) else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
