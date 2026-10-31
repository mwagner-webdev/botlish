#!/usr/bin/env python3
# abi-check.py -- the C ABI of everything the Icy Tower game uses from SDL3,
# checked against the target's C compiler and SDL3's own headers
# (ICY-TOWER-MACOS-MILESTONE-1.md, "Generated ABI and layout checks").
#
#   python3 -I audit/icy-tower/tools/abi-check.py BINDING SDL_INCLUDE WORK [GAME]
#
# BINDING is a generated SDL3 binding (DIR/sdl3/*.bot: generated/c/sdl3/
# TARGET/, or build-macos.sh's, or a staged application's package
# APP/.bot_modules/sdl3), SDL_INCLUDE the pinned SDL3's include directory,
# WORK a scratch directory, GAME the game's directory (default
# examples/games/icy-tower). The tool reads, from the game's own
# sources (sdl.bot, game.bot, render.bot), every SDL function, constant and
# layout it uses, and from the binding the Botlish declaration of each, and
# writes a C++ translation unit that includes SDL3/SDL.h and compares the two
# with the compiler's own types: template deduction takes each function's
# parameter and result types from the header's prototype -- never the
# generator's parse, never a comment -- and std::is_same, sizeof, alignof
# and offsetof answer for each one. Every check prints a line, PASS or FAIL,
# and the facts it read (sizes, offsets, values, C type widths); the exit
# status is 1 on any FAIL. It is compiled and run by the host's clang++ (the
# target's: on the Mac, Apple clang for arm64-apple-macos), with no SDL
# library: nothing is called.
#
# What it checks:
#   * every parameter and the result of each SDL function the game calls:
#     a scalar is exactly the C type the binding's std::ffi::c type names
#     (Uint8 is unsigned char, SDL_WindowFlags unsigned long on Linux and
#     unsigned long long on macOS, an enum's underlying type its scalar); a
#     pointer is a pointer to that pointee (cv-qualifiers aside: Botlish
#     records no const);
#   * every SDL constant it uses: the value, and the type the binding's
#     converter gives it (an enumerator's underlying type);
#   * the layouts it reads native memory with: sdl.bot's own EventType
#     (SDL_Event's size, alignment and its Uint32 type at offset 0) and
#     KeyState (SDL_SCANCODE_COUNT one-byte bools), and the binding's
#     SDL_FRect (every field's offset and C float);
#   * the target's C scalar widths the binding relies on (bool, int, long,
#     long long, size_t, pointers, float) and char's signedness.
import os
import re
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
GAME = os.path.join(HERE, "..", "..", "..", "examples", "games", "icy-tower")

SCALARS = {
    "Char": "char", "SChar": "signed char", "UChar": "unsigned char",
    "Short": "short", "UShort": "unsigned short", "Int": "int", "UInt": "unsigned int",
    "Long": "long", "ULong": "unsigned long", "LongLong": "long long", "ULongLong": "unsigned long long",
    "Float": "float", "Double": "double", "Bool": "bool", "Void": "void",
}
CONVERTERS = {
    "c_char": "char", "c_schar": "signed char", "c_uchar": "unsigned char", "c_short": "short",
    "c_ushort": "unsigned short", "c_int": "int", "c_uint": "unsigned int", "c_long": "long",
    "c_ulong": "unsigned long", "c_long_long": "long long", "c_ulong_long": "unsigned long long",
}


def read(path):
    with open(path, encoding="utf-8") as f:
        return f.read()


def game_names():
    text = "".join(read(os.path.join(GAME, f)) + "\n" for f in ("sdl.bot", "game.bot", "render.bot"))
    # Code only: a comment may name an SDL function the game does not call
    # (sdl.bot's SDL_Log).
    code = "\n".join(line.split("#", 1)[0] for line in text.splitlines())
    return sorted(set(re.findall(r"\bSDL_[A-Za-z0-9_]+\b", code)))


def split_top(text):
    """TEXT split at its commas outside brackets and braces."""
    parts, depth, cur = [], 0, ""
    for ch in text:
        if ch in "[{(":
            depth += 1
        elif ch in "]})":
            depth -= 1
        if ch == "," and depth == 0:
            parts.append(cur)
            cur = ""
        else:
            cur += ch
    if cur.strip():
        parts.append(cur)
    return [p.strip() for p in parts if p.strip()]


def first_type(text):
    """The Botlish type TEXT starts with (its facts follow it after a space)."""
    depth = 0
    text = text.strip()
    for i, ch in enumerate(text):
        if ch in "[{(":
            depth += 1
        elif ch in "]})":
            depth -= 1
        elif ch == " " and depth == 0:
            return text[:i]
    return text


def binding_decls(binding):
    """{name: ("fn", params, result)} and {name: ("const", converter, value)} of the binding."""
    decls = {}
    for name in sorted(os.listdir(os.path.join(binding, "sdl3"))):
        if not name.endswith(".bot"):
            continue
        lines = read(os.path.join(binding, "sdl3", name)).splitlines()
        i = 0
        while i < len(lines):
            line = lines[i]
            m = re.match(r'^extern c fn (\w+)(?: named "\w+")?\((.*)$', line)
            if m:
                fname, rest = m.group(1), m.group(2)
                if rest == "":
                    body = []
                    i += 1
                    while not lines[i].startswith(") -> "):
                        body.append(lines[i])
                        i += 1
                    params_text, result = " ".join(body), lines[i][len(") -> "):]
                else:
                    params_text, result = rest.rsplit(") -> ", 1)
                params = []
                for p in split_top(params_text):
                    if p == "variadic":
                        params.append(("...", "variadic"))
                        continue
                    pname, ptype = p.split(":", 1)
                    params.append((pname.strip(), first_type(ptype)))
                decls[fname] = ("fn", params, first_type(result))
            m = re.match(r"^(SDL_\w+) = sdl3::ctypes::(\w+)\((-?\d+)\)$", line)
            if m:
                decls[m.group(1)] = ("const", m.group(2), int(m.group(3)))
            i += 1
    return decls


def binding_layout(binding, layout):
    text = read(os.path.join(binding, "sdl3", "layouts.bot"))
    m = re.search(r"^layout %s:\n((?:    .*\n)+)" % re.escape(layout), text, re.M)
    return parse_layout(m.group(1)) if m else None


def parse_layout(body):
    out = {"fields": []}
    for line in body.splitlines():
        words = line.split("#", 1)[0].split()
        if not words:
            continue
        if words[0] in ("size", "align"):
            out[words[0]] = int(words[1])
        elif words[0] == "field":
            # field NAME: TYPE at OFFSET, or field NAME: array N of TYPE at OFFSET
            name = words[1].rstrip(":")
            if words[2] == "array":
                out["fields"].append((name, ("array", int(words[3]), words[5]), int(words[7])))
            else:
                out["fields"].append((name, words[2], int(words[4])))
    return out


def game_layouts():
    text = read(os.path.join(GAME, "sdl.bot"))
    out = {}
    for m in re.finditer(r"^private layout (\w+):\n((?:    .*\n)+)", text, re.M):
        out[m.group(1)] = parse_layout(m.group(2))
    return out


def ctype(botlish):
    """The C++ type a Botlish C type names, or None (a pointer or a record)."""
    if botlish.startswith("std::ffi::c::"):
        return SCALARS.get(botlish[len("std::ffi::c::"):])
    return None


def pointee(botlish):
    m = re.fullmatch(r"std::ffi::c::Ptr\[(.+)\]", botlish)
    if not m:
        return None
    inner = m.group(1)
    if inner.startswith("sdl3::ctypes::"):
        return inner[len("sdl3::ctypes::"):]
    return ctype(inner)


def main(argv):
    global GAME
    if len(argv) not in (3, 4):
        print("usage: abi-check.py BINDING SDL_INCLUDE WORK [GAME]", file=sys.stderr)
        return 2
    binding, include, work = argv[:3]
    if len(argv) == 4:
        GAME = argv[3]
    os.makedirs(work, exist_ok=True)
    decls = binding_decls(binding)
    names = game_names()
    lines = []
    checks = 0
    missing = []

    def check(expr, label):
        nonlocal checks
        checks += 1
        lines.append('    report(%s, "%s");' % (expr, label.replace('"', '\\"')))

    def fact(fmt, expr):
        lines.append('    std::printf("FACT %s\\n", %s);' % (fmt, expr))

    for name in names:
        if name not in decls:
            if name not in ("SDL_Event", "SDL_FRect", "SDL_Renderer", "SDL_Window"):
                missing.append(name)
            continue
        kind = decls[name][0]
        if kind == "fn":
            _, params, result = decls[name]
            f = "decltype(&%s)" % name
            check("std::tuple_size_v<args_of<%s>> == %d" % (f, len(params)), "%s takes %d parameters" % (name, len(params)))
            for i, (pname, ptype) in enumerate(params):
                c = ctype(ptype)
                label = "%s parameter %d (%s): %s" % (name, i + 1, pname, ptype)
                arg = "std::tuple_element_t<%d, args_of<%s>>" % (i, f) if i < len(params) else None
                if c is not None:
                    check("same_scalar<%s, %s>()" % (arg, c), label)
                else:
                    pt = pointee(ptype)
                    if pt is None:
                        check("false", label + " (no rule for this Botlish type)")
                    else:
                        check("same_pointee<%s, %s>()" % (arg, pt), label)
            label = "%s result: %s" % (name, result)
            if result == "unit":
                check("std::is_void_v<result_of<%s>>" % f, label)
            elif ctype(result) is not None:
                check("same_scalar<result_of<%s>, %s>()" % (f, ctype(result)), label)
            elif pointee(result) is not None:
                check("same_pointee<result_of<%s>, %s>()" % (f, pointee(result)), label)
            else:
                check("false", label + " (no rule for this Botlish type)")
        else:
            _, converter, value = decls[name]
            c = CONVERTERS.get(converter)
            check("(long long)(%s) == %dLL" % (name, value), "%s is %d" % (name, value))
            check("same_scalar<decltype(%s), %s>()" % (name, c or "void"), "%s is a %s (sdl3::ctypes::%s)" % (name, c, converter))
            fact("%s = %%lld" % name, "(long long)(%s)" % name)

    # sdl.bot's layouts of native memory, and the binding's SDL_FRect.
    layouts = game_layouts()
    ev = layouts.get("EventType")
    if ev:
        check("sizeof(SDL_Event) == %d" % ev["size"], "sdl.bot's EventType: sizeof(SDL_Event) is %d" % ev["size"])
        check("alignof(SDL_Event) == %d" % ev["align"], "sdl.bot's EventType: alignof(SDL_Event) is %d" % ev["align"])
        for fname, ftype, off in ev["fields"]:
            check("offsetof(SDL_Event, type) == %d" % off, "sdl.bot's EventType.%s: SDL_Event's type at offset %d" % (fname, off))
            check("same_scalar<decltype(SDL_Event::type), %s>()" % ctype(ftype), "sdl.bot's EventType.%s: SDL_Event's type is %s" % (fname, ftype))
        fact("sizeof(SDL_Event) = %zu, alignof = %zu, offsetof(type) = %zu", "sizeof(SDL_Event), alignof(SDL_Event), offsetof(SDL_Event, type)")
    ks = layouts.get("KeyState")
    if ks:
        (fname, (_, n, etype), off), = ks["fields"]
        check("SDL_SCANCODE_COUNT == %d && %d == %d" % (n, n, ks["size"]), "sdl.bot's KeyState: SDL_SCANCODE_COUNT (%d) one-byte keys" % n)
        check("sizeof(bool) == sizeof(%s)" % ctype(etype), "sdl.bot's KeyState: a key (C bool) is read as %s" % etype)
    fr = binding_layout(binding, "SDL_FRect")
    if fr:
        check("sizeof(SDL_FRect) == %d && alignof(SDL_FRect) == %d" % (fr["size"], fr["align"]), "the binding's SDL_FRect: size %d, align %d" % (fr["size"], fr["align"]))
        for fname, ftype, off in fr["fields"]:
            check("offsetof(SDL_FRect, %s) == %d && same_scalar<decltype(SDL_FRect::%s), %s>()" % (fname, off, fname, ctype(ftype)),
                  "the binding's SDL_FRect.%s: %s at %d" % (fname, ftype, off))
    for c in ("bool", "int", "long", "long long", "size_t", "void *", "float", "double"):
        fact("sizeof(%s) = %%zu" % c, "sizeof(%s)" % c)
    fact("char is %s", '(char)-1 < 0 ? "signed" : "unsigned"')
    fact("Uint64 is %s", 'std::is_same_v<Uint64, unsigned long> ? "unsigned long" : std::is_same_v<Uint64, unsigned long long> ? "unsigned long long" : "?"')

    cpp = os.path.join(work, "abi-check.cpp")
    with open(cpp, "w", encoding="utf-8") as f:
        f.write("""// GENERATED by audit/icy-tower/tools/abi-check.py: the game's SDL3 ABI
// against SDL3's headers and this compiler (see the tool's comment).
#include <SDL3/SDL.h>
#include <cstddef>
#include <cstdio>
#include <tuple>
#include <type_traits>

template <typename> struct signature;
template <typename R, typename... A> struct signature<R (*)(A...)> {
    using result = R;
    using args = std::tuple<A...>;
};
template <typename F> using args_of = typename signature<F>::args;
template <typename F> using result_of = typename signature<F>::result;

// T is the C scalar S: an enum by its underlying type.
template <typename T, typename S> constexpr bool same_scalar() {
    using U = std::remove_cv_t<T>;
    if constexpr (std::is_enum_v<U>) return std::is_same_v<std::underlying_type_t<U>, S>;
    else return std::is_same_v<U, S>;
}
// T is a pointer to P (cv-qualifiers aside).
template <typename T, typename P> constexpr bool same_pointee() {
    if constexpr (!std::is_pointer_v<T>) return false;
    else return same_scalar<std::remove_pointer_t<T>, P>() ||
        std::is_same_v<std::remove_cv_t<std::remove_pointer_t<T>>, P>;
}

static int failures;
static void report(bool ok, const char *what) {
    std::printf("%s %s\\n", ok ? "PASS" : "FAIL", what);
    failures += !ok;
}

int main() {
""")
        f.write("\n".join(lines))
        f.write("""
    std::printf("%d checks, %d failed\\n", """ + str(checks) + """, failures);
    return failures ? 1 : 0;
}
""")
    print("abi-check: %d SDL names used by the game, %d checks -> %s" % (len(names), checks, cpp))
    if missing:
        print("FAIL: the binding declares none of: " + " ".join(missing))
    exe = os.path.join(work, "abi-check")
    cxx = os.environ.get("CXX", "clang++")
    build = subprocess.run([cxx, "-std=c++17", "-I", include, "-o", exe, cpp], capture_output=True, text=True)
    if build.returncode != 0:
        print(build.stdout + build.stderr)
        print("FAIL: the check does not compile")
        return 1
    run = subprocess.run([exe], capture_output=True, text=True)
    sys.stdout.write(run.stdout)
    return 1 if run.returncode or missing else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
