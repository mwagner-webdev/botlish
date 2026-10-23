"""oracle.py -- an independent oracle of the numeric/text boundary
(NUMERIC-TEXT-BOUNDARY-MILESTONE-1.md), written from the milestone's rules,
not from core/ or native/: Python's own integers, fractions and decimals.

    python3 -I audit/numeric-text/tools/oracle.py < CASES > EXPECTED

Each input line is one case, tab-separated, its kind first:

    int-to-string  N         the canonical decimal text of the Int N
    int-from-string  HEX     the Int whose canonical text is the UTF-8 text
                             of HEX, or "invalid"
    float-round  BITS        the Int nearest the binary64 of 64-bit pattern
                             BITS (hex), ties to the even Int
    dr-quantize  BITS P      the text of round(x, P) of the binary64 x of
                             BITS, with exactly P fraction digits (a
                             DecimalRounded value quantized at P and shown
                             at P), "-" only before a nonzero result

and the output line is the expected result's text. selftest checks the
rules on the milestone's examples.
"""

import fractions
import re
import struct
import sys

CANONICAL = re.compile(r"(?:0|-?[1-9][0-9]*)\Z", re.ASCII)


def double(bits_hex):
    return struct.unpack("<d", struct.pack("<Q", int(bits_hex, 16)))[0]


def int_from_string(text):
    # ASCII digits only: re.ASCII keeps [0-9] from matching other digits,
    # and \Z (not $) refuses a trailing newline.
    if not CANONICAL.match(text):
        return "invalid"
    return str(int(text))


def nearest_even(r):
    # round() of a Fraction is round half to even, exactly.
    return round(r)


def float_round(bits_hex):
    return str(nearest_even(fractions.Fraction(double(bits_hex))))


def text_at(r, p):
    k = nearest_even(r * 10 ** p)
    sign = "-" if k < 0 else ""
    digits = str(abs(k))
    if p == 0:
        return sign + digits
    digits = digits.rjust(p + 1, "0")
    return sign + digits[:-p] + "." + digits[-p:]


def dr_quantize(bits_hex, p):
    # The quantization's true value is round(x, P); shown at P it is itself.
    p = int(p)
    return text_at(fractions.Fraction(double(bits_hex)), p)


def answer(line):
    fields = line.rstrip("\n").split("\t")
    kind = fields[0]
    if kind == "int-to-string":
        return str(int(fields[1]))
    if kind == "int-from-string":
        return int_from_string(bytes.fromhex(fields[1]).decode("utf-8"))
    if kind == "float-round":
        return float_round(fields[1])
    if kind == "dr-quantize":
        return dr_quantize(fields[1], fields[2])
    raise ValueError("unknown case kind " + kind)


def bits(x):
    return "%016x" % struct.unpack("<Q", struct.pack("<d", x))[0]


def selftest():
    assert [int_from_string(t) for t in ["0", "7", "-7", "123456"]] == ["0", "7", "-7", "123456"]
    for bad in ["", "-", "+1", "01", "-01", "-0", "1.0", " 1", "1 ", "1x", "x1", "--1", "١", "1\n"]:
        assert int_from_string(bad) == "invalid", bad
    assert [float_round(bits(x)) for x in [0.0, 0.49, 0.5, 1.5, 2.5, 3.5, -0.5, -1.5, -2.5]] == \
        ["0", "0", "0", "2", "2", "4", "0", "-2", "-2"]
    assert float_round(bits(0.49999999999999994)) == "0"
    assert float_round(bits(2.5000000000000004)) == "3"
    d = fractions.Fraction
    assert text_at(d("1.245"), 2) == "1.24" and text_at(d("1.235"), 2) == "1.24"
    assert text_at(d("1.255"), 2) == "1.26" and text_at(d("-1.245"), 2) == "-1.24"
    assert text_at(d("0.005"), 2) == "0.00" and text_at(d("-0.04"), 1) == "0.0"
    assert text_at(d("2"), 0) == "2" and text_at(d("2"), 2) == "2.00" and text_at(d("0.295"), 2) == "0.30"
    print("oracle selftest ok")


if __name__ == "__main__":
    if sys.argv[1:] == ["selftest"]:
        selftest()
    else:
        for line in sys.stdin:
            if line.strip():
                print(answer(line))
