"""oracle.py -- the independent JSON implementation the DFA prototype's
JSON layer is compared with (DFA-COROUTINE-EXPLORATION.md, "Correctness").

    python3 -I audit/dfa/tools/oracle.py < CASES > VERDICTS

Each input line is one case, its bytes in hexadecimal; each output line is
"accept" or "reject" for that case (a blank input line is the empty text).
The verdict is RFC 8259's, through CPython's json module made strict where
it is lenient by default:

  * the bytes are UTF-8, strictly (no surrogate, no overlong form, nothing
    past U+10FFFF), and decoded before parsing (json.loads would otherwise
    sniff UTF-16 and UTF-32 from the bytes);
  * NaN, Infinity and -Infinity are rejected (parse_constant);
  * control characters inside strings are rejected (strict=True, the
    default);
  * a byte order mark is rejected (json.loads refuses one in a str);
  * nesting beyond Python's recursion limit is reported "deep", not
    "reject": that is the oracle's own limit, not the grammar's.

An escaped lone surrogate ("\\ud800") is accepted, as RFC 8259's grammar
allows it (section 8.2: what software does with it is unpredictable).
"""

import json
import sys


def no_constants(name):
    raise ValueError("not JSON: " + name)


def verdict(data):
    try:
        text = data.decode("utf-8", errors="strict")
    except UnicodeDecodeError:
        return "reject"
    try:
        json.loads(text, parse_constant=no_constants)
    except RecursionError:
        return "deep"
    except ValueError:
        return "reject"
    return "accept"


def main():
    for line in sys.stdin:
        line = line.strip()
        print(verdict(bytes.fromhex(line)))


if __name__ == "__main__":
    main()
