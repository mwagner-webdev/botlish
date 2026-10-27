"""oracle.py -- an independent JSON oracle for the emitter experiment
(EMITTER-COROUTINE-EXPLORATION.md, "Correctness"): CPython's json, made
strict, and nothing of Botlish's.

    python3 -I audit/emitter/tools/oracle.py < CASES > VERDICTS

Each input line is one case, ``KIND SYMBOLS [EXPECTED]``:

    KIND      unicode  SYMBOLS are Unicode scalar values (a text)
              bytes    SYMBOLS are bytes (UTF-8, decoded strictly first)
    SYMBOLS   comma-separated decimal Ints ('-' for none)
    EXPECTED  optional: the JSON value the text must denote, as JSON text in
              hexadecimal UTF-8 (canonical: the case's input value, written
              by the test harness with Python's own json.dumps)

and the output line is ``valid KIND`` (the parsed value's type, and
``equal`` / ``different`` when EXPECTED was given), or ``invalid REASON``.

Strictness: no NaN, Infinity or -Infinity (json accepts them by default),
object keys kept as pairs (duplicates are not merged, so equality compares
what was written), no unpaired surrogate in any decoded string (json accepts
"\\ud800": a strict JSON text denotes Unicode scalar values, RFC 8259
section 8.2), nothing but whitespace after the value, and for bytes,
UTF-8 that Python's strict decoder accepts.
"""

import json
import sys


def no_constant(name):
    raise ValueError("non-standard constant " + name)


def pairs(items):
    return ("object", tuple(items))


def canonical(value):
    """VALUE with objects as their pair tuples (json's object_pairs_hook
    already gives them; lists and scalars recursively)."""
    if isinstance(value, tuple) and len(value) == 2 and value[0] == "object":
        return ("object", tuple((k, canonical(v)) for k, v in value[1]))
    if isinstance(value, list):
        return [canonical(v) for v in value]
    return value


def strings(value):
    if isinstance(value, str):
        yield value
    elif isinstance(value, list):
        for v in value:
            yield from strings(v)
    elif isinstance(value, tuple) and len(value) == 2 and value[0] == "object":
        for k, v in value[1]:
            yield k
            yield from strings(v)


def parse(text):
    decoder = json.JSONDecoder(object_pairs_hook=pairs, parse_constant=no_constant, strict=True)
    value = decoder.decode(text)
    for s in strings(value):
        try:
            s.encode("utf-8")
        except UnicodeEncodeError:
            raise ValueError("unpaired surrogate in a string")
    return value


def kind_of(value):
    if isinstance(value, tuple):
        return "object"
    if isinstance(value, list):
        return "array"
    if value is None:
        return "null"
    if isinstance(value, bool):
        return "boolean"
    if isinstance(value, int):
        return "integer"
    if isinstance(value, float):
        return "float"
    return "string"


def verdict(line):
    fields = line.split()
    kind, symbols = fields[0], fields[1]
    codes = [] if symbols == "-" else [int(x) for x in symbols.split(",")]
    try:
        if kind == "bytes":
            if any(c < 0 or c > 255 for c in codes):
                return "invalid not a byte"
            text = bytes(codes).decode("utf-8")
        else:
            if any(c < 0 or c > 0x10FFFF or 0xD800 <= c <= 0xDFFF for c in codes):
                return "invalid not a scalar value"
            text = "".join(chr(c) for c in codes)
        value = parse(text)
    except (ValueError, UnicodeDecodeError) as e:
        return "invalid " + str(e).split("\n")[0].replace(" ", "_")[:60]
    out = "valid " + kind_of(value)
    if len(fields) > 2:
        expected = parse(bytes.fromhex(fields[2]).decode("utf-8"))
        out += " equal" if canonical(value) == canonical(expected) else " different"
    return out


def selftest():
    def case(kind, text, expected=None):
        codes = list(text.encode("utf-8")) if kind == "bytes" else [ord(c) for c in text]
        line = kind + " " + (",".join(map(str, codes)) or "-")
        if expected is not None:
            line += " " + expected.encode("utf-8").hex()
        return verdict(line)
    assert case("unicode", "123") == "valid integer"
    assert case("unicode", "-0") == "valid integer"
    assert case("unicode", "01").startswith("invalid")
    assert case("unicode", "1e+").startswith("invalid")
    assert case("unicode", "NaN").startswith("invalid")
    assert case("unicode", '"\\ud800"').startswith("invalid")
    assert case("unicode", '"\\ud83d\\ude00"') == "valid string"
    assert case("unicode", '{"a":1,"a":2}', '{"a":1,"a":2}') == "valid object equal"
    assert case("unicode", '{"a":1,"a":2}', '{"a":2}') == "valid object different"
    assert case("unicode", "[1,2]", "[1, 2]") == "valid array equal"
    assert case("unicode", "1 2").startswith("invalid")
    assert case("bytes", '"é"') == "valid string"
    assert verdict("bytes 34,192,175,34").startswith("invalid")
    assert verdict("unicode 34,55296,34").startswith("invalid")
    assert case("unicode", "12345678901234567890123", "12345678901234567890123") == "valid integer equal"
    print("selftest ok")


if __name__ == "__main__":
    if sys.argv[1:] == ["selftest"]:
        selftest()
    else:
        for line in sys.stdin:
            line = line.strip()
            if line:
                print(verdict(line))
